import { useMemo, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Download, Filter, Plus, Search, X } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { EmptyState } from "../components/EmptyState";
import { LoadingBlock } from "../components/LoadingBlock";
import { PageHeader } from "../components/PageHeader";
import { StatusBadge } from "../components/StatusBadge";
import {
  createSaleInvoice,
  downloadAttachmentFile,
  getDocument,
  getEntries,
  reverseDocument,
  waitForAttachment,
} from "../data/repository";
import { formatDateTime, formatKind, formatMoney } from "../lib/format";
import type { Entry, EntryKind } from "../types";
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
  const { bootstrap, locationId, openAssistant, openManualSale } = useWorkspace();
  const [filter, setFilter] = useState<"ALL" | EntryKind>("ALL");
  const [search, setSearch] = useState("");
  const [from, setFrom] = useState("");
  const [to, setTo] = useState("");
  const [selected, setSelected] = useState<Entry | null>(null);
  const [invoiceState, setInvoiceState] = useState<"idle" | "working" | "error">("idle");
  const [quickKind, setQuickKind] = useState<"purchase" | "payment" | "expense" | null>(null);
  const query = useQuery({
    queryKey: ["entries", bootstrap.business.id, locationId, from, to],
    queryFn: () => getEntries(bootstrap.business.id, locationId, { from: from || undefined, to: to || undefined }),
  });
  const detail = useQuery({
    queryKey: ["entry-detail", selected?.id],
    queryFn: () => getDocument(collectionFor(selected!.kind), selected!.id),
    enabled: selected !== null,
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
        actions={<><button className="secondary-button"><Download />Export</button><button className="secondary-button" onClick={openManualSale}><Plus />Manual sale</button><button className="secondary-button" onClick={() => setQuickKind("purchase")}><Plus />Purchase</button><button className="secondary-button" onClick={() => setQuickKind("payment")}><Plus />Payment</button><button className="secondary-button" onClick={() => setQuickKind("expense")}><Plus />Expense</button><button className="primary-button" onClick={openAssistant}><Plus />Ask / Add</button></>}
      />
      <section className="panel data-panel">
        <div className="filter-row">
          <div className="tabs" role="tablist" aria-label="Entry type">
            {filters.map((item) => <button key={item.value} role="tab" aria-selected={filter === item.value} className={filter === item.value ? "active" : ""} onClick={() => setFilter(item.value)}>{item.label}</button>)}
          </div>
          <label className="inline-search"><Search /><span className="sr-only">Search entries</span><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Party or invoice" /></label>
          <label className="compact-select"><span>From</span><input type="date" value={from} onChange={(event) => setFrom(event.target.value)} /></label>
          <label className="compact-select"><span>To</span><input type="date" value={to} onChange={(event) => setTo(event.target.value)} /></label>
          <button className="icon-button bordered" aria-label="More filters" title="More filters arrive with Phase 3 exports"><Filter /></button>
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
                  <td><div className="row-actions"><button type="button" className="text-button" onClick={() => setSelected(entry)}>View</button>{entry.status !== "REVERSED" ? (
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
                  ) : null}</div></td>
                </tr>
              ))}</tbody>
            </table>
            {error ? <p className="form-error" role="alert">{error}</p> : null}
          </div>
        ) : <EmptyState title="No matching entries" detail="Change the filters or record a new entry." />}
      </section>
      {selected ? (
        <section className="panel" role="dialog" aria-label="Entry detail">
          <div className="panel-heading simple">
            <div>
              <h2>{formatKind(selected.kind)} · {selected.number}</h2>
              <p>{selected.partyName} · {formatDateTime(selected.occurredAt)}</p>
            </div>
            <button className="icon-button" aria-label="Close detail" onClick={() => setSelected(null)}><X /></button>
          </div>
          <div className="mini-metrics">
            <div><div><span>Total</span><strong>{formatMoney(selected.totalMinor)}</strong></div></div>
            <div><div><span>Outstanding</span><strong>{formatMoney(selected.outstandingMinor)}</strong></div></div>
            <div><div><span>Status</span><strong>{selected.status}</strong></div></div>
            <div><div><span>Payment</span><strong>{selected.paymentMode ?? "—"}</strong></div></div>
          </div>
          {detail.isLoading ? <LoadingBlock /> : null}
          {detail.data && Array.isArray((detail.data as Record<string, unknown>).lines) ? (
            <div className="table-scroll">
              <table>
                <thead><tr><th>Item</th><th>Quantity</th><th className="amount-cell">Rate</th><th className="amount-cell">Line total</th></tr></thead>
                <tbody>
                  {((detail.data as Record<string, unknown>).lines as Record<string, unknown>[]).map((line, index) => (
                    <tr key={String(line.id ?? index)}>
                      <td>{String(line.description ?? "Item")}</td>
                      <td>{String(line.quantity ?? "")}</td>
                      <td className="amount-cell">{formatMoney(Number(line.unitPriceMinor ?? line.unitCostMinor ?? 0))}</td>
                      <td className="amount-cell">{formatMoney(Number(line.lineTotalMinor ?? 0))}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : null}
          {selected.kind === "SALE" ? (
            <div className="review-actions">
              <button
                type="button"
                className="secondary-button"
                disabled={invoiceState === "working"}
                onClick={async () => {
                  setInvoiceState("working");
                  try {
                    const attachment = await createSaleInvoice(selected.id);
                    const ready = await waitForAttachment(attachment.id);
                    if (ready.status !== "READY") throw new Error("Invoice is not ready yet.");
                    await downloadAttachmentFile(ready);
                    setInvoiceState("idle");
                  } catch {
                    setInvoiceState("error");
                  }
                }}
              >
                {invoiceState === "working" ? "Preparing invoice…" : "Download invoice (PDF)"}
              </button>
              {invoiceState === "error" ? <span className="form-error" role="alert">Invoice could not be prepared.</span> : null}
            </div>
          ) : null}
        </section>
      ) : null}
      <QuickEntryDialog kind={quickKind} onClose={() => setQuickKind(null)} />
    </>
  );
}
