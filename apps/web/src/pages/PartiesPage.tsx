import { useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { MessageCircleMore, Plus, Search, Users } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { EmptyState } from "../components/EmptyState";
import { LoadingBlock } from "../components/LoadingBlock";
import { PageHeader } from "../components/PageHeader";
import { StatusBadge } from "../components/StatusBadge";
import { getParties } from "../data/repository";
import { formatMoney } from "../lib/format";

export function PartiesPage() {
  const { bootstrap } = useWorkspace();
  const [search, setSearch] = useState("");
  const query = useQuery({
    queryKey: ["parties", bootstrap.business.id],
    queryFn: () => getParties(bootstrap.business.id),
  });
  const parties = useMemo(() => (query.data ?? []).filter((party) =>
    `${party.name} ${party.phone ?? ""}`.toLowerCase().includes(search.toLowerCase()),
  ), [query.data, search]);
  const toReceive = parties.reduce((sum, party) => sum + party.receivableMinor, 0);
  const toPay = parties.reduce((sum, party) => sum + party.payableMinor, 0);

  return (
    <>
      <PageHeader
        eyebrow="Customers & suppliers"
        title="Parties"
        description="See every balance in plain language. A party can be a customer, supplier, or both."
        actions={<button className="primary-button"><Plus />Add party</button>}
      />
      <section className="balance-callouts">
        <article className="receive"><span>You will receive</span><strong>{formatMoney(toReceive)}</strong><small>Across {parties.filter((p) => p.receivableMinor > 0).length} parties</small></article>
        <article className="pay"><span>You will pay</span><strong>{formatMoney(toPay)}</strong><small>Across {parties.filter((p) => p.payableMinor > 0).length} parties</small></article>
      </section>
      <section className="panel data-panel">
        <div className="filter-row">
          <label className="inline-search wide"><Search /><span className="sr-only">Search parties</span><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search name or phone" /></label>
        </div>
        {query.isLoading ? <LoadingBlock /> : parties.length ? (
          <div className="party-grid">
            {parties.map((party) => (
              <article className="party-card" key={party.id}>
                <div className="party-card-top"><span className="party-avatar"><Users /></span><div><h3>{party.name}</h3><p>{party.phone ?? "No phone added"}</p></div><StatusBadge>{party.kind.toLowerCase()}</StatusBadge></div>
                <div className="party-balances">
                  <div><span>You will receive</span><strong className="receive-text">{formatMoney(party.receivableMinor)}</strong></div>
                  <div><span>You will pay</span><strong className="pay-text">{formatMoney(party.payableMinor)}</strong></div>
                </div>
                <div className="party-actions"><button type="button">View ledger</button><button type="button"><MessageCircleMore />Share reminder</button></div>
              </article>
            ))}
          </div>
        ) : <EmptyState title="No parties found" detail="Add a customer or supplier to start a ledger." />}
      </section>
    </>
  );
}
