import { useMemo, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Download, Filter, Plus, Search } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { EmptyState } from "../components/EmptyState";
import { LoadingBlock } from "../components/LoadingBlock";
import { PageHeader } from "../components/PageHeader";
import { StatusBadge } from "../components/StatusBadge";
import { getEntries, reverseDocument } from "../data/repository";
import { formatDateTime, formatKind, formatMoney } from "../lib/format";
import type { EntryKind } from "../types";
import { ManualSaleDialog } from "../features/entries/ManualSaleDialog";
import { QuickEntryDialog } from "../features/entries/QuickEntryDialog";

const entryCollection: Record<Exclude<EntryKind, "PAYMENT_IN" | "PAYMENT_OUT"> | "PAYMENT", "sales" | "purchases" | "payments" | "expenses"> = {
  SALE: "sales",
  PURCHASE: "purchases",
  PAYMENT: "payments",
  EXPENSE: "expenses",
};

function collectionFor(kind: EntryKind) {
  if (kind === "PAYMENT_IN" || kind === "PAYMENT_OUT") return "payments" as const;
  return entryCollection[kind as keyof typeof entryCollection];
}

const filters: Array<{ label: string; value: "ALL" | EntryKind }> = [
  { label: "All", value: "ALL" },
  { label: "Sales", value: "SALE" },
  { label: "Purchases", value: "PURCHASE" },
  { label: "Payments in", value: "PAYMENT_IN" },
  { label: "Payments out", value: "PAYMENT_OUT" },
  { label: "Expenses", value: "EXPENSE" },
];

export function EntriesPage() {
  const { bootstrap, locationId, openAssistant } = useWorkspace();
  const [filter, setFilter] = useState<"ALL" | EntryKind>("ALL");
  const [search, setSearch] = useState("");
  const [manualSaleOpen, setManualSaleOpen] = useState(false);
  const [quickKind, setQuickKind] = useState<"purchase" | "payment" | "expense" | null>(null);
  const query = useQuery({
    queryKey: ["entries", bootstrap.business.id, locationId],
    queryFn: () => getEntries(bootstrap.business.id, locationId),
  });
  const queryClient = useQueryClient();
  const [reversingId, setReversingId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const reverse = useMutation({
    mutationFn: ({ id, kind, reason }: { id: string; kind: EntryKind; reason: string }) =>
      reverseDocument(collectionFor(kind), id, reason),
    onSuccess: () => queryClient.invalidateQueries(),
    onSettled: () => setReversingId(null),
    onError: (err) => setError(err instanceof Error ? err.message : "Could not reverse this entry."),
  });
  const visible = useMemo(() => (query.data ?? []).filter((entry) => {
    if (filter !== "ALL" && entry.kind !== filter) return false;
    return `${entry.partyName} ${entry.number}`.toLowerCase().includes(search.toLowerCase());
  }), [filter, query.data, search]);

  return (
    <>
      <PageHeader
        eyebrow="Operations"
        title="Entries"
        description="A single timeline for sales, purchases, payments and expenses. Posted entries are corrected through reversals."
        actions={<><button className="secondary-button"><Download />Export</button><button className="secondary-button" onClick={() => setManualSaleOpen(true)}><Plus />Manual sale</button><button className="secondary-button" onClick={() => setQuickKind("purchase")}><Plus />Purchase</button><button className="secondary-button" onClick={() => setQuickKind("payment")}><Plus />Payment</button><button className="secondary-button" onClick={() => setQuickKind("expense")}><Plus />Expense</button><button className="primary-button" onClick={openAssistant}><Plus />Ask / Add</button></>}
      />
      <section className="panel data-panel">
        <div className="filter-row">
          <div className="tabs" role="tablist" aria-label="Entry type">
            {filters.map((item) => <button key={item.value} role="tab" aria-selected={filter === item.value} className={filter === item.value ? "active" : ""} onClick={() => setFilter(item.value)}>{item.label}</button>)}
          </div>
          <label className="inline-search"><Search /><span className="sr-only">Search entries</span><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Party or invoice" /></label>
          <button className="icon-button bordered" aria-label="More filters"><Filter /></button>
        </div>
        {query.isLoading ? <LoadingBlock /> : visible.length ? (
          <div className="table-scroll">
            <table>
              <thead><tr><th>Entry</th><th>Party / details</th><th>Date</th><th>Payment</th><th>Status</th><th className="amount-cell">Amount</th><th><span className="sr-only">Actions</span></th></tr></thead>
              <tbody>{visible.map((entry) => (
                <tr key={entry.id}>
                  <td><strong>{formatKind(entry.kind)}</strong><small>{entry.number}</small></td>
                  <td>{entry.partyName}</td>
                  <td>{formatDateTime(entry.occurredAt)}</td>
                  <td>{entry.paymentMode ?? "—"}</td>
                  <td>{entry.status === "REVERSED" ? <StatusBadge tone="neutral">Reversed</StatusBadge> : entry.outstandingMinor > 0 ? <StatusBadge tone="warning">{formatMoney(entry.outstandingMinor)} due</StatusBadge> : <StatusBadge tone="positive">Paid</StatusBadge>}</td>
                  <td className="amount-cell"><strong>{formatMoney(entry.totalMinor)}</strong></td>
                  <td>{entry.status !== "REVERSED" ? (
                    <button
                      type="button"
                      className="text-button"
                      disabled={reversingId === entry.id}
                      onClick={() => {
                        const reason = window.prompt("Reason for reversal (required)?", "Duplicate entry");
                        if (!reason) return;
                        setError(null);
                        setReversingId(entry.id);
                        reverse.mutate({ id: entry.id, kind: entry.kind, reason });
                      }}
                    >{reversingId === entry.id ? "Reversing…" : "Reverse"}</button>
                  ) : null}</td>
                </tr>
              ))}</tbody>
            </table>
            {error ? <p className="form-error" role="alert">{error}</p> : null}
          </div>
        ) : <EmptyState title="No matching entries" detail="Change the filters or record a new entry." />}
      </section>
      <ManualSaleDialog open={manualSaleOpen} onClose={() => setManualSaleOpen(false)} />
      <QuickEntryDialog kind={quickKind} onClose={() => setQuickKind(null)} />
    </>
  );
}
