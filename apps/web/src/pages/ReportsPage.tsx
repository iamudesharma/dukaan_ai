import { useMemo, useState } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import {
  BarChart3,
  CalendarDays,
  Download,
  IndianRupee,
  Landmark,
  PackageCheck,
  ReceiptIndianRupee,
  TrendingUp,
} from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { EmptyState } from "../components/EmptyState";
import { LoadingBlock } from "../components/LoadingBlock";
import { PageHeader } from "../components/PageHeader";
import {
  createExportJob,
  downloadExportJob,
  downloadReportCsv,
  getDashboard,
  getDayBook,
  getDocumentReport,
  getGstReport,
  getPartyBalances,
  getStockValuation,
  waitForExportJob,
} from "../data/repository";
import { formatMoney } from "../lib/format";
import type { ReportKind } from "../types";

type Period = "today" | "7d" | "month" | "custom";

const reportCards: Array<{ name: string; detail: string; icon: typeof BarChart3; kind: ReportKind }> = [
  { name: "Day book", detail: "Every inflow and outflow", icon: CalendarDays, kind: "day-book" },
  { name: "Sales report", detail: "Invoices, items and collections", icon: TrendingUp, kind: "sales" },
  { name: "Purchase report", detail: "Bills, suppliers and payments", icon: ReceiptIndianRupee, kind: "purchases" },
  { name: "Party ledger", detail: "Receivables and payables", icon: Landmark, kind: "party-balances" },
  { name: "Stock valuation", detail: "Quantity and estimated value", icon: PackageCheck, kind: "stock-valuation" },
  { name: "GST summary", detail: "Taxable value and tax components", icon: IndianRupee, kind: "gst" },
];

const periods: Array<{ label: string; value: Period }> = [
  { label: "This month", value: "month" },
  { label: "Last 7 days", value: "7d" },
  { label: "Today", value: "today" },
  { label: "Custom", value: "custom" },
];

function isoDate(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

function periodRange(period: Period, customFrom: string, customTo: string) {
  const today = new Date();
  if (period === "today") return { from: isoDate(today), to: isoDate(today) };
  if (period === "7d") {
    const start = new Date(today);
    start.setDate(start.getDate() - 6);
    return { from: isoDate(start), to: isoDate(today) };
  }
  if (period === "month") {
    const start = new Date(today.getFullYear(), today.getMonth(), 1);
    return { from: isoDate(start), to: isoDate(today) };
  }
  return { from: customFrom || undefined, to: customTo || undefined };
}

export function ReportsPage() {
  const { bootstrap, locationId } = useWorkspace();
  const [active, setActive] = useState<ReportKind>("day-book");
  const [period, setPeriod] = useState<Period>("month");
  const [customFrom, setCustomFrom] = useState("");
  const [customTo, setCustomTo] = useState("");
  const [groupBy, setGroupBy] = useState<"day" | "party" | "product">("day");
  const range = useMemo(
    () => periodRange(period, customFrom, customTo),
    [period, customFrom, customTo],
  );
  const dashboard = useQuery({
    queryKey: ["dashboard", bootstrap.business.id, locationId],
    queryFn: () => getDashboard(bootstrap.business.id, locationId),
  });
  const report = useQuery({
    queryKey: ["report", active, bootstrap.business.id, locationId, range.from, range.to, groupBy],
    queryFn: async () => {
      const query = { businessId: bootstrap.business.id, locationId, ...range };
      switch (active) {
        case "day-book":
          return { kind: "day-book" as const, data: await getDayBook(query) };
        case "sales":
          return { kind: "sales" as const, data: await getDocumentReport(query, "sales", groupBy) };
        case "purchases":
          return { kind: "purchases" as const, data: await getDocumentReport(query, "purchases", groupBy) };
        case "party-balances":
          return { kind: "party-balances" as const, data: await getPartyBalances(query) };
        case "stock-valuation":
          return { kind: "stock-valuation" as const, data: await getStockValuation(query) };
        default:
          return { kind: "gst" as const, data: await getGstReport(query) };
      }
    },
  });
  const exportMutation = useMutation({
    mutationFn: () =>
      downloadReportCsv({
        businessId: bootstrap.business.id,
        locationId,
        report: active,
        groupBy: active === "sales" || active === "purchases" ? groupBy : undefined,
        ...range,
      }),
  });
  const pdfExport = useMutation({
    mutationFn: async () => {
      const job = await createExportJob({
        businessId: bootstrap.business.id,
        report: active,
        format: "PDF",
        locationId,
        from: range.from,
        to: range.to,
        groupBy: active === "sales" || active === "purchases" ? groupBy : undefined,
      });
      const ready = await waitForExportJob(job.id);
      if (ready.status !== "READY") {
        throw new Error(ready.error || "The PDF export could not be generated.");
      }
      await downloadExportJob(ready);
    },
  });

  const isGrouped = active === "sales" || active === "purchases";

  return (
    <>
      <PageHeader
        eyebrow="Grounded in posted entries"
        title="Reports"
        description="Operational views for decisions and reconciliation. Profit is an estimate, not statutory accounting."
        actions={
          <>
            <label className="compact-select">
              <span>Period</span>
              <select value={period} onChange={(event) => setPeriod(event.target.value as Period)}>
                {periods.map((item) => (
                  <option key={item.value} value={item.value}>
                    {item.label}
                  </option>
                ))}
              </select>
            </label>
            <button
              className="primary-button"
              onClick={() => exportMutation.mutate()}
              disabled={exportMutation.isPending}
            >
              <Download />
              {exportMutation.isPending ? "Exporting…" : "Export CSV"}
            </button>
            <button
              className="secondary-button"
              onClick={() => pdfExport.mutate()}
              disabled={pdfExport.isPending}
            >
              <Download />
              {pdfExport.isPending ? "Preparing PDF…" : "Export PDF"}
            </button>
          </>
        }
      />
      {period === "custom" ? (
        <section className="panel">
          <div className="two-fields">
            <label>
              From
              <input type="date" value={customFrom} onChange={(event) => setCustomFrom(event.target.value)} />
            </label>
            <label>
              To
              <input type="date" value={customTo} onChange={(event) => setCustomTo(event.target.value)} />
            </label>
          </div>
        </section>
      ) : null}
      {dashboard.isLoading ? (
        <LoadingBlock />
      ) : dashboard.data ? (
        <section className="report-highlight">
          <div>
            <p className="eyebrow">Live pulse</p>
            <h2>Business pulse</h2>
            <p>Today’s sales with posted collections and estimated margin.</p>
          </div>
          <div className="report-highlight-values">
            <div><span>Sales today</span><strong>{formatMoney(dashboard.data.salesMinor)}</strong></div>
            <div><span>Collected (posted)</span><strong>{formatMoney(dashboard.data.collectionsMinor)}</strong></div>
            <div><span>Estimated gross profit (posted)</span><strong>{formatMoney(dashboard.data.grossProfitMinor)}</strong></div>
          </div>
        </section>
      ) : null}
      <section className="report-grid" aria-label="Available reports">
        {reportCards.map(({ name, detail, icon: Icon, kind }) => (
          <button
            type="button"
            className={`report-card${active === kind ? " active" : ""}`}
            key={kind}
            aria-pressed={active === kind}
            onClick={() => setActive(kind)}
          >
            <span><Icon /></span>
            <div><strong>{name}</strong><small>{detail}</small></div>
            <BarChart3 className="report-arrow" />
          </button>
        ))}
      </section>
      <section className="panel data-panel" aria-label="Report results">
        <div className="panel-heading simple">
          <div>
            <h2>{reportCards.find((card) => card.kind === active)?.name}</h2>
            <p>
              {range.from ?? "Start"} to {range.to ?? "today"}
              {isGrouped ? " · grouped by selection" : ""}
            </p>
          </div>
          {isGrouped ? (
            <label className="compact-select">
              <span>Group by</span>
              <select value={groupBy} onChange={(event) => setGroupBy(event.target.value as typeof groupBy)}>
                <option value="day">Day</option>
                <option value="party">Party</option>
                <option value="product">Product</option>
              </select>
            </label>
          ) : null}
        </div>
        {report.isLoading ? <LoadingBlock /> : null}
        {report.error ? <p className="form-error" role="alert">{(report.error as Error).message}</p> : null}
        {report.data?.kind === "day-book" ? (
          <>
            <div className="mini-metrics">
              <div><div><span>Receipts</span><strong>{formatMoney(report.data.data.summary.receiptsMinor)}</strong></div></div>
              <div><div><span>Payments out</span><strong>{formatMoney(report.data.data.summary.paymentsMinor)}</strong></div></div>
              <div><div><span>Expenses</span><strong>{formatMoney(report.data.data.summary.expensesMinor)}</strong></div></div>
              <div><div><span>Net cash</span><strong>{formatMoney(report.data.data.summary.netCashMinor)}</strong></div></div>
            </div>
            {report.data.data.entries.length ? (
              <div className="table-scroll">
                <table>
                  <thead><tr><th>Date</th><th>Type</th><th>Reference</th><th>Party</th><th className="amount-cell">Amount</th></tr></thead>
                  <tbody>
                    {report.data.data.entries.map((entry, index) => (
                      <tr key={`${entry.kind}-${entry.number}-${index}`}>
                        <td>{entry.date}</td>
                        <td><strong>{entry.kind.replace("_", " ")}</strong></td>
                        <td>{entry.number}</td>
                        <td>{entry.partyName}</td>
                        <td className="amount-cell"><strong>{entry.direction === "IN" ? "+" : "−"}{formatMoney(entry.amountMinor)}</strong></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ) : <EmptyState title="No entries in this period" detail="Change the period or record new activity." />}
          </>
        ) : null}
        {report.data && (report.data.kind === "sales" || report.data.kind === "purchases") ? (
          <>
            <p>
              <strong>{report.data.data.totals.count}</strong> documents · Taxable {formatMoney(report.data.data.totals.taxableMinor)} ·
              Tax {formatMoney(report.data.data.totals.taxMinor)} · Total {formatMoney(report.data.data.totals.grandTotalMinor)}
            </p>
            {report.data.data.rows.length ? (
              <div className="table-scroll">
                <table>
                  <thead><tr><th>{report.data.kind === "sales" ? "Sales" : "Purchases"}</th><th>Count</th><th className="amount-cell">Taxable</th><th className="amount-cell">Tax</th><th className="amount-cell">Total</th><th className="amount-cell">Due</th></tr></thead>
                  <tbody>
                    {report.data.data.rows.map((row) => (
                      <tr key={row.key}>
                        <td><strong>{row.label}</strong>{row.quantity ? <small>{row.quantity} units</small> : null}</td>
                        <td>{row.count}</td>
                        <td className="amount-cell">{formatMoney(row.taxableMinor)}</td>
                        <td className="amount-cell">{formatMoney(row.taxMinor)}</td>
                        <td className="amount-cell"><strong>{formatMoney(row.grandTotalMinor)}</strong></td>
                        <td className="amount-cell">{formatMoney(row.dueMinor)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ) : <EmptyState title="No documents in this period" detail="Change the period or record new activity." />}
          </>
        ) : null}
        {report.data?.kind === "party-balances" ? (
          report.data.data.rows.length ? (
            <div className="table-scroll">
              <table>
                <thead><tr><th>Party</th><th>Phone</th><th className="amount-cell">You will receive</th><th className="amount-cell">You will pay</th></tr></thead>
                <tbody>
                  {report.data.data.rows.map((row) => (
                    <tr key={row.partyId}>
                      <td><strong>{row.name}</strong><small>{row.kind.toLowerCase()}</small></td>
                      <td>{row.phone || "—"}</td>
                      <td className="amount-cell">{formatMoney(row.receivableMinor)}</td>
                      <td className="amount-cell">{formatMoney(row.payableMinor)}</td>
                    </tr>
                  ))}
                  <tr>
                    <td colSpan={2}><strong>Total</strong></td>
                    <td className="amount-cell"><strong>{formatMoney(report.data.data.totals.receivableMinor)}</strong></td>
                    <td className="amount-cell"><strong>{formatMoney(report.data.data.totals.payableMinor)}</strong></td>
                  </tr>
                </tbody>
              </table>
            </div>
          ) : <EmptyState title="No parties yet" detail="Add customers and suppliers to see balances." />
        ) : null}
        {report.data?.kind === "stock-valuation" ? (
          report.data.data.rows.length ? (
            <div className="table-scroll">
              <table>
                <thead><tr><th>Product</th><th>On hand</th><th className="amount-cell">Cost value</th><th className="amount-cell">Retail value</th></tr></thead>
                <tbody>
                  {report.data.data.rows.map((row) => (
                    <tr key={row.productId}>
                      <td><strong>{row.name}</strong><small>{row.unit.toLowerCase()}</small></td>
                      <td>{row.quantity}</td>
                      <td className="amount-cell">{row.stockValueCostMinor === null ? "—" : formatMoney(row.stockValueCostMinor)}</td>
                      <td className="amount-cell">{row.stockValueRetailMinor === null ? "—" : formatMoney(row.stockValueRetailMinor)}</td>
                    </tr>
                  ))}
                  <tr>
                    <td colSpan={2}><strong>Total</strong></td>
                    <td className="amount-cell"><strong>{formatMoney(report.data.data.totals.costValueMinor)}</strong></td>
                    <td className="amount-cell"><strong>{formatMoney(report.data.data.totals.retailValueMinor)}</strong></td>
                  </tr>
                </tbody>
              </table>
            </div>
          ) : <EmptyState title="No inventory products" detail="Add products to see valuation." />
        ) : null}
        {report.data?.kind === "gst" ? (
          <>
            <p>
              B2B {report.data.data.b2b.count} invoices · B2C {report.data.data.b2c.count} invoices ·
              Output tax {formatMoney(report.data.data.output.totals.taxMinor)} · Input tax {formatMoney(report.data.data.input.totals.taxMinor)}
            </p>
            {(["output", "input"] as const).map((side) => (
              <div key={side}>
                <h3>{side === "output" ? "Output tax (sales)" : "Input tax (purchases)"}</h3>
                {report.data?.kind === "gst" && report.data.data[side].rows.length ? (
                  <div className="table-scroll">
                    <table>
                      <thead><tr><th>Rate</th><th className="amount-cell">Taxable</th><th className="amount-cell">CGST</th><th className="amount-cell">SGST</th><th className="amount-cell">IGST</th></tr></thead>
                      <tbody>
                        {report.data.data[side].rows.map((row) => (
                          <tr key={`${side}-${row.rateBps}`}>
                            <td><strong>{row.rateBps / 100}%</strong></td>
                            <td className="amount-cell">{formatMoney(row.taxableMinor)}</td>
                            <td className="amount-cell">{formatMoney(row.cgstMinor)}</td>
                            <td className="amount-cell">{formatMoney(row.sgstMinor)}</td>
                            <td className="amount-cell">{formatMoney(row.igstMinor)}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                ) : <p>No {side === "output" ? "sales" : "purchases"} with GST in this period.</p>}
              </div>
            ))}
          </>
        ) : null}
        {exportMutation.error ? (
          <p className="form-error" role="alert">{exportMutation.error.message}</p>
        ) : null}
        {pdfExport.error ? (
          <p className="form-error" role="alert">{pdfExport.error.message}</p>
        ) : null}
      </section>
    </>
  );
}
