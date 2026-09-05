import { useQuery } from "@tanstack/react-query";
import {
  ArrowDownLeft,
  ArrowUpRight,
  Boxes,
  IndianRupee,
  MessageCircleMore,
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
import { getDashboard, getEntries, getProducts } from "../data/repository";
import { formatDateTime, formatKind, formatMoney } from "../lib/format";

export function OverviewPage() {
  const { bootstrap, locationId, openAssistant } = useWorkspace();
  const dashboard = useQuery({
    queryKey: ["dashboard", bootstrap.business.id, locationId],
    queryFn: () => getDashboard(bootstrap.business.id, locationId),
  });
  const entries = useQuery({
    queryKey: ["entries", bootstrap.business.id, locationId],
    queryFn: () => getEntries(bootstrap.business.id, locationId),
  });
  const products = useQuery({
    queryKey: ["products", bootstrap.business.id, locationId],
    queryFn: () => getProducts(bootstrap.business.id, locationId),
  });
  const location = bootstrap.locations.find((candidate) => candidate.id === locationId);

  if (dashboard.isLoading) return <LoadingBlock />;
  if (dashboard.error || !dashboard.data) {
    return <EmptyState title="Dashboard unavailable" detail="We couldn’t load this location. Check your connection and try again." />;
  }

  const lowStock = products.data?.filter(
    (product) => Number(product.onHand) <= Number(product.reorderLevel),
  ) ?? [];

  return (
    <>
      <PageHeader
        eyebrow={`${location?.name ?? "Location"} · ${new Intl.DateTimeFormat("en-IN", { weekday: "long", day: "numeric", month: "long" }).format(new Date())}`}
        title={`Namaste, ${bootstrap.user.name.split(" ")[0]}`}
        description="Here’s what needs your attention today. All figures are for the selected location."
        actions={<button className="primary-button" onClick={openAssistant}><Sparkles />Tell DukaanAI</button>}
      />

      <section className="metrics-grid" aria-label="Today’s business summary">
        <MetricCard label="Sales" valueMinor={dashboard.data.salesMinor} hint="Posted today" icon={TrendingUp} tone="blue" />
        <MetricCard label="Collected" valueMinor={dashboard.data.collectionsMinor} hint="Cash, UPI and bank" icon={ArrowDownLeft} tone="green" />
        <MetricCard label="You will receive" valueMinor={dashboard.data.receivableMinor} hint="Customer outstanding" icon={IndianRupee} tone="amber" />
        <MetricCard label="You will pay" valueMinor={dashboard.data.payableMinor} hint="Supplier outstanding" icon={ArrowUpRight} tone="red" />
      </section>

      <section className="dashboard-grid">
        <article className="panel ai-summary-card">
          <div className="panel-heading">
            <div><span className="summary-glyph"><Sparkles /></span><div><p className="eyebrow">Daily summary</p><h2>Business at a glance</h2></div></div>
            <span className="as-of">As of {formatDateTime(dashboard.data.asOf)}</span>
          </div>
          <p className="summary-copy">{dashboard.data.summary}</p>
          <div className="summary-stats">
            <div><span>Estimated gross profit</span><strong>{formatMoney(dashboard.data.grossProfitMinor)}</strong></div>
            <div><span>Expenses today</span><strong>{formatMoney(dashboard.data.expensesMinor)}</strong></div>
            <div><span>Low-stock products</span><strong>{dashboard.data.lowStockCount}</strong></div>
          </div>
          <p className="estimate-note">Profit is an operational estimate based on available stock cost.</p>
        </article>

        <article className="panel attention-panel">
          <div className="panel-heading simple"><div><h2>Needs attention</h2><p>Act before these become a problem.</p></div></div>
          <div className="attention-list">
            <button type="button"><span className="attention-icon amber"><PackageX /></span><span><strong>{lowStock.length} products are low on stock</strong><small>Review reorder levels</small></span><span className="arrow">→</span></button>
            <button type="button"><span className="attention-icon blue"><Users /></span><span><strong>₹1,24,000 due from Ramesh</strong><small>Reminder due today</small></span><span className="arrow">→</span></button>
            <button type="button"><span className="attention-icon green"><MessageCircleMore /></span><span><strong>3 customer reminders ready</strong><small>Review before sharing</small></span><span className="arrow">→</span></button>
          </div>
        </article>
      </section>

      <section className="dashboard-grid lower">
        <article className="panel recent-panel">
          <div className="panel-heading simple"><div><h2>Recent entries</h2><p>Latest posted activity at {location?.name}.</p></div><a href="/entries">View all</a></div>
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
          ) : <EmptyState title="No entries yet" detail="Record your first sale, purchase, payment or expense." />}
        </article>

        <article className="panel stock-panel">
          <div className="panel-heading simple"><div><h2>Low stock</h2><p>Based on each product’s reorder level.</p></div><Boxes /></div>
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
