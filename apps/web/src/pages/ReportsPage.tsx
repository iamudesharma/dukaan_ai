import { useQuery } from "@tanstack/react-query";
import { BarChart3, CalendarDays, Download, IndianRupee, Landmark, PackageCheck, ReceiptIndianRupee, TrendingUp } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { LoadingBlock } from "../components/LoadingBlock";
import { PageHeader } from "../components/PageHeader";
import { getDashboard, getStockReport } from "../data/repository";
import { formatMoney } from "../lib/format";

const reportCards = [
  { name: "Day book", detail: "Every inflow and outflow", icon: CalendarDays },
  { name: "Sales report", detail: "Invoices, items and collections", icon: TrendingUp },
  { name: "Purchase report", detail: "Bills, suppliers and payments", icon: ReceiptIndianRupee },
  { name: "Party ledger", detail: "Receivables and payables", icon: Landmark },
  { name: "Stock valuation", detail: "Quantity and estimated value", icon: PackageCheck },
  { name: "GST summary", detail: "Taxable value and tax components", icon: IndianRupee },
];

export function ReportsPage() {
  const { bootstrap, locationId } = useWorkspace();
  const query = useQuery({
    queryKey: ["dashboard", bootstrap.business.id, locationId],
    queryFn: () => getDashboard(bootstrap.business.id, locationId),
  });
  const stock = useQuery({
    queryKey: ["stock-report", bootstrap.business.id, locationId],
    queryFn: () => getStockReport(bootstrap.business.id, locationId),
  });
  return (
    <>
      <PageHeader eyebrow="Grounded in posted entries" title="Reports" description="Operational views for decisions and reconciliation. Profit is an estimate, not statutory accounting." actions={<><button className="secondary-button"><CalendarDays />This month</button><button className="primary-button"><Download />Export</button></>} />
      {query.isLoading ? <LoadingBlock /> : query.data ? (
        <section className="report-highlight">
          <div><p className="eyebrow">Selected period</p><h2>Business pulse</h2><p>Sales, collection and estimated margin from your posted records.</p></div>
          <div className="report-highlight-values"><div><span>Sales</span><strong>{formatMoney(query.data.salesMinor)}</strong></div><div><span>Collected</span><strong>{formatMoney(query.data.collectionsMinor)}</strong></div><div><span>Estimated gross profit</span><strong>{formatMoney(query.data.grossProfitMinor)}</strong></div></div>
        </section>
      ) : null}
      <section className="report-grid" aria-label="Available reports">
        {reportCards.map(({ name, detail, icon: Icon }) => <button type="button" className="report-card" key={name}><span><Icon /></span><div><strong>{name}</strong><small>{detail}</small></div><BarChart3 className="report-arrow" /></button>)}
      </section>
      <section className="panel" aria-label="Stock report">
        <div className="panel-heading simple"><div><h2>Stock report</h2><p>Live server quantities for this location.</p></div><PackageCheck /></div>
        {stock.isLoading ? <LoadingBlock /> : stock.data?.length ? (
          <ul>{stock.data.slice(0, 20).map((row) => <li key={row.productId}>{row.name} — {row.quantity} {row.unit}{row.isLowStock ? " · low" : ""}</li>)}</ul>
        ) : <p>No stock rows for this location.</p>}
      </section>
    </>
  );
}
