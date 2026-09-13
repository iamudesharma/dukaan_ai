import { useMemo, useState, type FormEvent } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { MessageCircleMore, Plus, Search, Users, X } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { EmptyState } from "../components/EmptyState";
import { LoadingBlock } from "../components/LoadingBlock";
import { PageHeader } from "../components/PageHeader";
import { StatusBadge } from "../components/StatusBadge";
import {
  createParty,
  createReminder,
  getParties,
  getPartyLedger,
  postOpeningBalance,
} from "../data/repository";
import { formatMoney } from "../lib/format";

export function PartiesPage() {
  const { bootstrap, locationId } = useWorkspace();
  const [search, setSearch] = useState("");
  const [adding, setAdding] = useState(false);
  const [ledgerPartyId, setLedgerPartyId] = useState<string | null>(null);
  const [name, setName] = useState("");
  const [kind, setKind] = useState<"CUSTOMER" | "SUPPLIER" | "BOTH">("CUSTOMER");
  const [phone, setPhone] = useState("");
  const [openingMinor, setOpeningMinor] = useState("0");
  const [openingSide, setOpeningSide] = useState<"RECEIVABLE" | "PAYABLE">("RECEIVABLE");
  const queryClient = useQueryClient();
  const query = useQuery({
    queryKey: ["parties", bootstrap.business.id],
    queryFn: () => getParties(bootstrap.business.id),
  });
  const ledger = useQuery({
    queryKey: ["ledger", bootstrap.business.id, ledgerPartyId],
    queryFn: () => getPartyLedger(bootstrap.business.id, ledgerPartyId as string, locationId),
    enabled: ledgerPartyId !== null,
  });
  const [reminderNotice, setReminderNotice] = useState<string | null>(null);
  const remind = useMutation({
    mutationFn: async (partyId: string) => {
      const reminder = await createReminder({
        businessId: bootstrap.business.id,
        partyId,
        locationId,
      });
      const text = reminder.message;
      try {
        if (navigator.share) await navigator.share({ text });
        else await navigator.clipboard.writeText(text);
        setReminderNotice(`Reminder ready to share: ${text}`);
      } catch {
        setReminderNotice(text);
      }
      return reminder;
    },
  });
  const create = useMutation({
    mutationFn: async () => {
      const created = await createParty({
        business: bootstrap.business.id,
        name,
        kind,
        ...(phone ? { phoneE164: phone } : {}),
      }) as unknown as { id: string };
      const amount = Math.round(Number(openingMinor || 0) * 100);
      if (amount > 0) {
        await postOpeningBalance({
          businessId: bootstrap.business.id,
          locationId,
          partyId: String((created as { id: string }).id),
          account: openingSide,
          amountMinor: amount,
          note: "Opening balance",
        });
      }
      return created;
    },
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["parties"] });
      setAdding(false);
      setName("");
      setPhone("");
      setOpeningMinor("0");
    },
  });

  function submitAdd(event: FormEvent) {
    event.preventDefault();
    if (name.trim()) create.mutate();
  }
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
        actions={<button className="primary-button" onClick={() => setAdding(true)}><Plus />Add party</button>}
      />
      {adding ? (
        <section className="panel" role="dialog" aria-label="Add party">
          <form className="manual-form" onSubmit={submitAdd}>
            <div className="two-fields">
              <label>Name<input value={name} onChange={(e) => setName(e.target.value)} required placeholder="Party name" /></label>
              <label>Kind<select value={kind} onChange={(e) => setKind(e.target.value as typeof kind)}><option value="CUSTOMER">Customer</option><option value="SUPPLIER">Supplier</option><option value="BOTH">Both</option></select></label>
            </div>
            <div className="two-fields">
              <label>Phone<input value={phone} onChange={(e) => setPhone(e.target.value)} placeholder="+91…" /></label>
              <label>Opening balance<input type="number" min="0" step="0.01" value={openingMinor} onChange={(e) => setOpeningMinor(e.target.value)} /></label>
            </div>
            <label className="compact-select">Opening side<select value={openingSide} onChange={(e) => setOpeningSide(e.target.value as typeof openingSide)}><option value="RECEIVABLE">They owe me (receivable)</option><option value="PAYABLE">I owe them (payable)</option></select></label>
            <div className="review-actions">
              <button type="button" className="secondary-button" onClick={() => setAdding(false)}>Cancel</button>
              <button className="primary-button" disabled={!name.trim() || create.isPending}>{create.isPending ? "Saving…" : "Save party"}</button>
            </div>
            {create.error ? <p className="form-error" role="alert">{create.error.message}</p> : null}
          </form>
        </section>
      ) : null}
      <section className="balance-callouts">
        <article className="receive"><span>You will receive</span><strong>{formatMoney(toReceive)}</strong><small>Across {parties.filter((p) => p.receivableMinor > 0).length} parties</small></article>
        <article className="pay"><span>You will pay</span><strong>{formatMoney(toPay)}</strong><small>Across {parties.filter((p) => p.payableMinor > 0).length} parties</small></article>
      </section>
      <section className="panel data-panel">
        <div className="filter-row">
          <label className="inline-search wide"><Search /><span className="sr-only">Search parties</span><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search name or phone" /></label>
        </div>
        {reminderNotice ? <p role="status" className="field-note">{reminderNotice}</p> : null}
        {query.isLoading ? <LoadingBlock /> : parties.length ? (
          <div className="party-grid">
            {parties.map((party) => (
              <article className="party-card" key={party.id}>
                <div className="party-card-top"><span className="party-avatar"><Users /></span><div><h3>{party.name}</h3><p>{party.phone ?? "No phone added"}</p></div><StatusBadge>{party.kind.toLowerCase()}</StatusBadge></div>
                <div className="party-balances">
                  <div><span>You will receive</span><strong className="receive-text">{formatMoney(party.receivableMinor)}</strong></div>
                  <div><span>You will pay</span><strong className="pay-text">{formatMoney(party.payableMinor)}</strong></div>
                </div>
                <div className="party-actions"><button type="button" onClick={() => setLedgerPartyId(party.id)}>View ledger</button><button type="button" disabled={remind.isPending} onClick={() => remind.mutate(party.id)}><MessageCircleMore />{remind.isPending ? "Preparing…" : "Share reminder"}</button></div>
              </article>
            ))}
          </div>
        ) : <EmptyState title="No parties found" detail="Add a customer or supplier to start a ledger." />}
      </section>
      {ledgerPartyId ? (
        <section className="panel" role="dialog" aria-label="Party ledger">
          <header className="panel-heading simple">
            <div><h2>Ledger</h2><p>Receivables and payables for this party.</p></div>
            <button className="icon-button" aria-label="Close ledger" onClick={() => setLedgerPartyId(null)}><X /></button>
          </header>
          {ledger.isLoading ? <LoadingBlock /> : ledger.data ? (
            <div>
              <p><strong>Balance: {formatMoney(ledger.data.balance)}</strong></p>
              {ledger.data.entries.length ? (
                <ul>{ledger.data.entries.slice(0, 50).map((entry) => <li key={entry.id}>{entry.account} · {formatMoney(entry.amountMinor)} · {entry.occurredAt}</li>)}</ul>
              ) : <p>No ledger entries yet.</p>}
            </div>
          ) : <p>Could not load the ledger.</p>}
        </section>
      ) : null}
    </>
  );
}
