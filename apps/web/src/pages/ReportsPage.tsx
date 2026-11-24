import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { BarChart3, CalendarDays, IndianRupee, Landmark, PackageCheck, ReceiptIndianRupee, TrendingUp } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { LoadingBlock } from "../components/LoadingBlock";
import { PageHeader } from "../components/PageHeader";
import { StatusBadge } from "../components/StatusBadge";
import { NotFoundPage } from "./NotFoundPage";
import { getStockReport, getValuationReport } from "../data/repository";
import { formatMoney } from "../lib/format";
import { PaymentAllocationPanel } from "../features/operations/PaymentAllocationPanel";

const reportCards = [
  { name: "Day book", detail: "Every inflow and outflow", icon: CalendarDays },
  { name: "Sales report", detail: "Invoices, items and collections", icon: TrendingUp },
  { name: "Purchase report", detail: "Bills, suppliers and payments", icon: ReceiptIndianRupee },
  { name: "Party ledger", detail: "Receivables and payables", icon: Landmark },
  { name: "Stock valuation", detail: "Weighted-average cost and gross profit", icon: PackageCheck },
  { name: "GST summary", detail: "Taxable value and tax components", icon: IndianRupee },
];

function dateInput(date: Date): string {
  const pad = (part: number) => String(part).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}

function monthRange(): { from: string; to: string } {
  const now = new Date();
  return { from: dateInput(new Date(now.getFullYear(), now.getMonth(), 1)), to: dateInput(now) };
}

export function ReportsPage() {
  const { bootstrap, access, locationId } = useWorkspace();
  const [range, setRange] = useState(monthRange);
  const invalidRange = Boolean(range.from && range.to && range.from > range.to);
  const valuation = useQuery({
    queryKey: ["valuation", bootstrap.business.id, locationId, range.from, range.to],
    queryFn: () => getValuationReport(bootstrap.business.id, locationId, { dateFrom: range.from || undefined, dateTo: range.to || undefined }),
    enabled: access.canViewReports && !access.isCashier && !invalidRange,
  });
  const stock = useQuery({
    queryKey: ["stock-report", bootstrap.business.id, locationId],
    queryFn: () => getStockReport(bootstrap.business.id, locationId),
    enabled: access.canViewReports && !access.isCashier,
  });
  const sales = valuation.data?.sales;
  const inventory = valuation.data?.inventory;

  if (!access.canViewReports || access.isCashier) return <NotFoundPage />;

  return (
    <>
      <PageHeader eyebrow="01 · Grounded in posted entries" title="Reports" description="Operational views for decisions and reconciliation. Gross profit uses weighted-average cost and is not statutory accounting." actions={<button type="button" className="secondary-button" onClick={() => setRange(monthRange())}><CalendarDays />This month</button>} />
      {valuation.isLoading ? <LoadingBlock /> : valuation.error ? (
        <section className="panel"><p className="form-error" role="alert">Could not load valuation and gross profit. {invalidRange ? "The start date must not be after the end date." : "Check your connection and try again."}</p><button type="button" className="text-button" disabled={invalidRange} onClick={() => void valuation.refetch()}>Try again</button></section>
      ) : valuation.data ? (
        <section className="report-highlight" aria-label="Selected period profit summary">
          <div><p className="folio-kicker on-hero">Selected period</p><h2>Business pulse</h2><p>Net sales and gross profit from posted sales in this date range. Unknown costs are never treated as zero.</p></div>
          <div className="report-highlight-values"><div><span>Net sales</span><strong>{formatMoney(sales?.netSalesMinor ?? 0)}</strong></div><div><span>Known COGS</span><strong>{formatMoney(sales?.cogsMinor ?? 0)}</strong></div><div><span>Gross profit</span><strong>{sales?.grossProfitMinor === null || !sales ? "Not available" : formatMoney(sales.grossProfitMinor)}</strong></div></div>
        </section>
      ) : null}
      <section className="report-grid" aria-label="Available reports">
        {reportCards.map(({ name, detail, icon: Icon }) => name === "Stock valuation"
          ? <button type="button" className="report-card" key={name} onClick={() => document.getElementById("valuation")?.scrollIntoView({ block: "start" })}><span><Icon /></span><div><strong>{name}</strong><small>{detail}</small></div><BarChart3 className="report-arrow" /></button>
          : <button type="button" className="report-card" key={name}><span><Icon /></span><div><strong>{name}</strong><small>{detail}</small></div><BarChart3 className="report-arrow" /></button>)}
      </section>
      <section className="panel register-section valuation-panel" id="valuation">
        <div className="panel-heading simple"><div><p className="folio-kicker">Weighted average</p><h2>Stock valuation & gross profit</h2><p>Inventory value uses server-side weighted-average costing. Date filters apply to sales profit, not current stock.</p></div><PackageCheck /></div>
        <div className="filter-row valuation-filters"><label>From<input type="date" value={range.from} onChange={(event) => setRange((current) => ({ ...current, from: event.target.value }))} /></label><label>To<input type="date" value={range.to} onChange={(event) => setRange((current) => ({ ...current, to: event.target.value }))} /></label><button type="button" className="secondary-button" onClick={() => setRange({ from: "", to: "" })}>All time</button></div>
        {invalidRange ? <p className="form-error" role="alert">The start date must not be after the end date.</p> : null}
        {valuation.data && inventory && sales ? (
          <>
            <dl className="valuation-metrics"><div><dt>Stock value</dt><dd>{inventory.totalValueMinor === null ? "Not fully costed" : formatMoney(inventory.totalValueMinor)}</dd><small>{inventory.totalValueMinor === null ? `${formatMoney(inventory.knownValueMinor)} known value` : `${inventory.totalQuantity} units`}</small></div><div><dt>Weighted-average cost</dt><dd>{inventory.averageCostMinor === null ? "Not available" : formatMoney(inventory.averageCostMinor)}</dd><small>Per base unit</small></div><div><dt>Posted sales</dt><dd>{sales.postedSaleCount}</dd><small>{sales.lineCount} sale lines</small></div><div><dt>Gross profit</dt><dd>{sales.grossProfitMinor === null ? "Not available" : formatMoney(sales.grossProfitMinor)}</dd><small>{sales.costingComplete ? "All sale costs known" : `${sales.missingCostLineCount} sale lines missing cost`}</small></div></dl>
            {!inventory.costingComplete ? <p className="warning-card"><PackageCheck aria-hidden="true" />Some stock has no known cost. Its value is excluded rather than estimated at zero.</p> : null}
            {!sales.costingComplete ? <p className="warning-card"><TrendingUp aria-hidden="true" />Gross profit is unavailable until every sold line in this period has a known cost.</p> : null}
            {valuation.data.results.length ? <div className="table-scroll"><table><caption className="sr-only">Weighted-average inventory valuation by product</caption><thead><tr><th>Product</th><th>Quantity</th><th className="amount-cell">Average cost</th><th className="amount-cell">Stock value</th><th>Costing</th></tr></thead><tbody>{valuation.data.results.map((row) => <tr key={row.productId}><td><strong>{row.name}</strong><small>{row.productId}</small></td><td>{row.quantity} {row.unit}</td><td className="amount-cell">{row.averageCostMinor === null ? "—" : formatMoney(row.averageCostMinor)}</td><td className="amount-cell">{row.totalValueMinor === null ? `${formatMoney(row.knownValueMinor)} known` : formatMoney(row.totalValueMinor)}</td><td><StatusBadge tone={row.costingComplete ? "positive" : "warning"}>{row.costingComplete ? "Complete" : `${row.unknownCostQuantity} unknown`}</StatusBadge></td></tr>)}</tbody></table></div> : <p className="muted-copy">No inventory products to value.</p>}
          </>
        ) : null}
      </section>
      <PaymentAllocationPanel businessId={bootstrap.business.id} locationId={locationId} canReview={access.canViewReports && !access.isCashier} />
      <section className="panel register-section" aria-label="Stock report">
        <div className="panel-heading simple"><div><p className="folio-kicker">Live quantities</p><h2>Stock report</h2><p>Live server quantities for this location.</p></div><PackageCheck /></div>
        {stock.isLoading ? <LoadingBlock /> : stock.data?.length ? <ul>{stock.data.slice(0, 20).map((row) => <li key={row.productId}>{row.name} — {row.quantity} {row.unit}{row.isLowStock ? " · low" : ""}</li>)}</ul> : <p>No stock rows for this location.</p>}
      </section>
    </>
  );
}
