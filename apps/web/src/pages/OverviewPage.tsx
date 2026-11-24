import { useQuery } from "@tanstack/react-query";
import {
  ArrowDownLeft,
  ArrowUpRight,
  Boxes,
  IndianRupee,
  PackageX,
  Sparkles,
  TrendingUp,
  Users,
} from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { EmptyState } from "../components/EmptyState";
import { LoadingBlock } from "../components/LoadingBlock";
import { MetricCard } from "../components/MetricCard";
import { PageHeader } from "../components/PageHeader";
import { StatusBadge } from "../components/StatusBadge";
import { getDashboard, getEntries, getParties, getProducts, getValuationReport } from "../data/repository";
import { formatDateTime, formatKind, formatMoney } from "../lib/format";

function localDateKey(date: Date): string {
  const pad = (part: number) => String(part).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}

export function OverviewPage() {
  const { bootstrap, access, locationId, openAssistant } = useWorkspace();
  const todayKey = localDateKey(new Date());
  const dashboard = useQuery({
    queryKey: ["dashboard", bootstrap.user.id, bootstrap.business.id, locationId],
    queryFn: () => getDashboard(bootstrap.business.id, locationId),
    enabled: !access.isCashier,
  });
  const valuation = useQuery({
    queryKey: ["valuation", "overview", bootstrap.user.id, bootstrap.business.id, locationId, todayKey],
    queryFn: () => getValuationReport(bootstrap.business.id, locationId, { dateFrom: todayKey, dateTo: todayKey }),
    enabled: access.canViewMargins,
  });
  const entries = useQuery({
    queryKey: ["entries", bootstrap.user.id, bootstrap.business.id, locationId, access.isCashier ? "cashier" : "operations"],
    queryFn: () => getEntries(
      bootstrap.business.id,
      locationId,
      access.isCashier ? ["SALE", "PAYMENT_IN"] : undefined,
    ),
  });
  const products = useQuery({
    queryKey: ["products", bootstrap.user.id, bootstrap.business.id, locationId],
    queryFn: () => getProducts(bootstrap.business.id, locationId, { includeWholesalePrices: access.canViewWholesalePrices }),
  });
  const parties = useQuery({
    queryKey: ["parties", bootstrap.user.id, bootstrap.business.id],
    queryFn: () => getParties(bootstrap.business.id, { customersOnly: access.isCashier }),
  });
  const location = bootstrap.locations.find((candidate) => candidate.id === locationId);

  if (!access.isCashier && dashboard.isLoading) return <LoadingBlock />;
  if (!access.isCashier && (dashboard.error || !dashboard.data)) {
    return <EmptyState title="Dashboard unavailable" detail="We couldn’t load this location. Check your connection and try again." />;
  }
  if (access.isCashier && entries.isLoading) return <LoadingBlock />;
  if (access.isCashier && entries.error) {
    return <EmptyState title="Sales unavailable" detail="We couldn’t load sales for this location. Check your connection and try again." />;
  }

  const lowStock = products.data?.filter(
    (product) => Number(product.onHand) <= Number(product.reorderLevel),
  ) ?? [];
  const today = new Date().toDateString();
  const postedEntries = (entries.data ?? []).filter((entry) =>
    entry.status === "POSTED" && new Date(entry.occurredAt).toDateString() === today,
  );
  const cashierSalesMinor = postedEntries
    .filter((entry) => entry.kind === "SALE")
    .reduce((sum, entry) => sum + entry.totalMinor, 0);
  const cashierCollectionsMinor = postedEntries
    .filter((entry) => entry.kind === "PAYMENT_IN")
    .reduce((sum, entry) => sum + entry.totalMinor, 0);
  const salesMinor = access.isCashier ? cashierSalesMinor : dashboard.data?.salesMinor ?? 0;
  const collectionsMinor = access.isCashier ? cashierCollectionsMinor : dashboard.data?.collectionsMinor ?? 0;
  const receivableMinor = access.isCashier
    ? (parties.data ?? []).reduce((sum, party) => sum + party.receivableMinor, 0)
    : dashboard.data?.receivableMinor ?? 0;
  const lowStockCount = access.isCashier ? lowStock.length : dashboard.data?.lowStockCount ?? 0;
  const grossProfitMinor = valuation.data ? valuation.data.sales.grossProfitMinor : dashboard.data?.grossProfitMinor ?? null;
  const topDebtor = (parties.data ?? [])
    .filter((party) => party.receivableMinor > 0)
    .sort((a, b) => b.receivableMinor - a.receivableMinor)[0];

  return (
    <>
      <PageHeader
        eyebrow={`${location?.name ?? "Location"} · ${new Intl.DateTimeFormat("en-IN", { weekday: "long", day: "numeric", month: "long" }).format(new Date())}`}
        title={`Namaste, ${bootstrap.user.name.split(" ")[0]}`}
        description={access.isCashier ? "Here’s what needs your attention today. Sales and customer balances are for the selected location." : "Here’s what needs your attention today. All figures are for the selected location."}
        actions={<button className="primary-button" onClick={openAssistant}><Sparkles />Tell DukaanAI</button>}
      />

      <section className="metrics-grid" aria-label="Today’s business summary">
        <MetricCard label="Sales" valueMinor={salesMinor} hint="Posted today" icon={TrendingUp} tone="neutral" />
        <MetricCard label="Collected" valueMinor={collectionsMinor} hint="Cash, UPI and bank" icon={ArrowDownLeft} tone="positive" />
        <MetricCard label="You will receive" valueMinor={receivableMinor} hint="Customer outstanding" icon={IndianRupee} tone="attention" />
        {access.canViewSuppliers ? <MetricCard label="You will pay" valueMinor={dashboard.data?.payableMinor ?? 0} hint="Supplier outstanding" icon={ArrowUpRight} tone="attention" /> : null}
      </section>

      <section className="dashboard-grid">
        <article className="panel ai-summary-card ledger-proof">
          <div className="panel-heading">
            <div><span className="summary-glyph"><Sparkles /></span><div><p className="folio-kicker on-hero">01 · Daily summary</p><h2>Business at a glance</h2></div></div>
            <span className="as-of">{access.isCashier ? "Updated just now" : `As of ${formatDateTime(dashboard.data?.asOf ?? new Date().toISOString())}`}</span>
          </div>
          <p className="summary-copy">{access.isCashier ? "Today’s sales, collections and customer outstanding for this location." : dashboard.data?.summary}</p>
          <div className="summary-stats">
            {access.canViewMargins ? <div><span>Gross profit today</span><strong>{valuation.isLoading ? "…" : grossProfitMinor == null ? "Not available" : formatMoney(grossProfitMinor)}</strong></div> : null}
            {access.canRecordExpenses ? <div><span>Expenses today</span><strong>{formatMoney(dashboard.data?.expensesMinor ?? 0)}</strong></div> : null}
            {access.canViewMargins ? <div><span>Net cash flow</span><strong>{formatMoney(dashboard.data?.cashFlowMinor ?? 0)}</strong></div> : null}
            <div><span>Low-stock products</span><strong>{lowStockCount}</strong></div>
          </div>
          {access.canViewMargins ? <p className="estimate-note">{valuation.error ? "Gross profit could not be refreshed from weighted-average costing." : grossProfitMinor == null ? "Gross profit is unavailable until every sold line has a known cost." : "Based on weighted-average cost of today’s posted sales."}</p> : null}
        </article>

        <article className="attention-panel">
          <div className="panel-heading simple"><div><p className="folio-kicker">02 · Ledger</p><h2>Needs attention</h2><p>Act before these become a problem.</p></div></div>
          <div className="attention-list">
            <button type="button"><span className="attention-icon attention"><PackageX /></span><span><strong>{lowStock.length} products are low on stock</strong><small>Review reorder levels</small></span><span className="arrow">→</span></button>
            {topDebtor ? (
              <button type="button"><span className="attention-icon primary"><Users /></span><span><strong>{formatMoney(topDebtor.receivableMinor)} due from {topDebtor.name}</strong><small>Largest customer outstanding</small></span><span className="arrow">→</span></button>
            ) : null}
            {access.canViewSuppliers && (dashboard.data?.payableMinor ?? 0) > 0 ? (
              <button type="button"><span className="attention-icon positive"><IndianRupee /></span><span><strong>{formatMoney(dashboard.data?.payableMinor ?? 0)} to pay suppliers</strong><small>Across recorded purchases</small></span><span className="arrow">→</span></button>
            ) : null}
          </div>
        </article>
      </section>

      <section className="dashboard-grid lower">
        <article className="panel register-section recent-panel">
          <div className="panel-heading simple"><div><p className="folio-kicker">03 · Timeline</p><h2>Recent entries</h2><p>Latest posted activity at {location?.name}.</p></div><a href="/entries">View all</a></div>
          {entries.isLoading ? <LoadingBlock /> : entries.data?.length ? (
            <div className="compact-entry-list">
              {entries.data.slice(0, 5).map((entry) => (
                <div className="compact-entry" key={entry.id}>
                  <span className={`entry-kind-icon ${entry.kind.toLowerCase()}`}>{entry.kind === "SALE" || entry.kind === "PAYMENT_IN" ? <ArrowDownLeft /> : <ArrowUpRight />}</span>
                  <div><strong>{entry.partyName}</strong><span>{formatKind(entry.kind)} · {formatDateTime(entry.occurredAt)}</span></div>
                  <div className="entry-amount"><strong>{formatMoney(entry.totalMinor)}</strong>{entry.outstandingMinor > 0 ? <StatusBadge tone="warning">{formatMoney(entry.outstandingMinor)} due</StatusBadge> : <StatusBadge tone="positive">Paid</StatusBadge>}</div>
                </div>
              ))}
            </div>
          ) : <EmptyState title="No entries yet" detail={access.isCashier ? "Record your first sale or customer payment." : "Record your first sale, purchase, payment or expense."} />}
        </article>

        <article className="panel register-section stock-panel">
          <div className="panel-heading simple"><div><p className="folio-kicker">04 · Register</p><h2>Low stock</h2><p>Based on each product’s reorder level.</p></div><Boxes /></div>
          <div className="stock-list">
            {lowStock.slice(0, 4).map((product) => (
              <div key={product.id}><div><strong>{product.name}</strong><span>{product.sku}</span></div><div><strong>{product.onHand}</strong><span>{product.unit}s left</span></div></div>
            ))}
          </div>
        </article>
      </section>
    </>
  );
}
