import { useMemo, useState, type FormEvent } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { ArrowLeftRight, LoaderCircle, Plus, Trash2, X } from "lucide-react";
import { getParties, getPaymentAllocationReview, reallocatePayment } from "../../data/repository";
import { newIdempotencyKey } from "../../lib/api";
import { formatDateTime, formatKind, formatMoney } from "../../lib/format";
import type { OutstandingDocument, PaymentAllocationInput, PaymentDirection, PaymentRecord } from "../../types";
import { EmptyState } from "../../components/EmptyState";
import { LoadingBlock } from "../../components/LoadingBlock";
import { StatusBadge } from "../../components/StatusBadge";

interface Props {
  businessId: string;
  locationId: string;
  canReview: boolean;
}

interface AllocationDraft {
  key: string;
  documentId: string;
  amount: string;
}

interface DocumentOption extends OutstandingDocument {
  availableMinor: number;
}

function amountInput(minor: number): string {
  return (minor / 100).toFixed(2);
}

function amountMinor(value: string): number {
  const amount = Number(value);
  return Number.isFinite(amount) && amount >= 0 ? Math.round(amount * 100) : 0;
}

export function PaymentAllocationPanel({ businessId, locationId, canReview }: Props) {
  const queryClient = useQueryClient();
  const [direction, setDirection] = useState<"ALL" | PaymentDirection>("ALL");
  const [partyId, setPartyId] = useState("");
  const [selected, setSelected] = useState<PaymentRecord | null>(null);
  const [rows, setRows] = useState<AllocationDraft[]>([]);
  const [reason, setReason] = useState("");
  const [idempotencyKey, setIdempotencyKey] = useState(() => newIdempotencyKey());
  const [message, setMessage] = useState<string | null>(null);

  const parties = useQuery({
    queryKey: ["parties", businessId],
    queryFn: () => getParties(businessId),
    enabled: canReview,
  });
  const review = useQuery({
    queryKey: ["payment-allocation-review", businessId, locationId, direction, partyId],
    queryFn: () => getPaymentAllocationReview(businessId, locationId, { direction: direction === "ALL" ? undefined : direction, partyId: partyId || undefined }),
    enabled: canReview,
  });

  const documentOptions = useMemo<DocumentOption[]>(() => {
    if (!selected) return [];
    const expectedType = selected.direction === "RECEIPT" ? "SALE" : "PURCHASE";
    const options = new Map<string, DocumentOption>();
    for (const document of review.data?.outstandingDocuments ?? []) {
      if (document.documentType !== expectedType || document.partyId !== selected.party) continue;
      options.set(document.documentId, { ...document, availableMinor: document.dueTotalMinor });
    }
    for (const allocation of selected.allocations) {
      const existing = options.get(allocation.documentId);
      const documentTotalMinor = allocation.documentTotalMinor ?? existing?.grandTotalMinor ?? 0;
      const documentPaidTotalMinor = allocation.documentPaidTotalMinor ?? existing?.paidTotalMinor ?? 0;
      const dueTotalMinor = allocation.documentDueTotalMinor ?? existing?.dueTotalMinor ?? Math.max(0, documentTotalMinor - documentPaidTotalMinor);
      options.set(allocation.documentId, {
        documentType: allocation.documentType,
        documentId: allocation.documentId,
        number: allocation.documentNumber ?? existing?.number ?? allocation.documentId,
        documentDate: existing?.documentDate ?? selected.paymentDate,
        partyId: selected.party,
        partyName: existing?.partyName,
        grandTotalMinor: documentTotalMinor,
        paidTotalMinor: documentPaidTotalMinor,
        dueTotalMinor,
        availableMinor: dueTotalMinor + allocation.amountMinor,
      });
    }
    return [...options.values()].sort((left, right) => left.number.localeCompare(right.number));
  }, [review.data?.outstandingDocuments, selected]);

  const draftedTotal = rows.reduce((sum, row) => sum + amountMinor(row.amount), 0);
  const remaining = selected ? selected.amountMinor - draftedTotal : 0;
  const duplicateDocument = new Set(rows.map((row) => row.documentId).filter(Boolean)).size !== rows.filter((row) => row.documentId).length;
  const invalidRow = rows.some((row) => {
    if (!row.documentId || amountMinor(row.amount) <= 0) return true;
    const option = documentOptions.find((document) => document.documentId === row.documentId);
    return !option || amountMinor(row.amount) > option.availableMinor;
  });
  const validationError = !selected
    ? null
    : rows.length === 0
      ? "Add at least one document allocation."
      : duplicateDocument
        ? "Use each document only once."
        : invalidRow
          ? "Every allocation needs a document and a positive amount within that document’s available balance."
          : draftedTotal > selected.amountMinor
            ? "Allocations cannot exceed the payment amount."
            : draftedTotal !== selected.amountMinor
              ? `Assign the full payment amount. ${formatMoney(Math.abs(remaining))} remains ${remaining >= 0 ? "unassigned" : "over-assigned"}.`
              : !reason.trim()
                ? "Enter a reason for this reallocation."
                : null;

  const reallocate = useMutation({
    mutationFn: () => {
      if (!canReview) throw new Error("Only an owner or manager can reallocate payments.");
      if (!selected || validationError) throw new Error(validationError ?? "Review the allocation before saving.");
      const allocations: PaymentAllocationInput[] = rows.map((row) => ({
        documentType: selected.direction === "RECEIPT" ? "SALE" : "PURCHASE",
        documentId: row.documentId,
        amountMinor: amountMinor(row.amount),
      }));
      return reallocatePayment({ paymentId: selected.id, allocations, reason: reason.trim(), idempotencyKey });
    },
    onSuccess: async () => {
      setMessage(`Payment ${selected?.reference ?? selected?.id ?? ""} reallocated.`.replace("  ", " "));
      setSelected(null);
      setRows([]);
      setReason("");
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: ["payment-allocation-review"] }),
        queryClient.invalidateQueries({ queryKey: ["entries"] }),
        queryClient.invalidateQueries({ queryKey: ["parties"] }),
        queryClient.invalidateQueries({ queryKey: ["ledger"] }),
        queryClient.invalidateQueries({ queryKey: ["dashboard"] }),
      ]);
    },
  });

  function openPayment(payment: PaymentRecord) {
    setSelected(payment);
    setRows(payment.allocations.length
      ? payment.allocations.map((allocation) => ({ key: newIdempotencyKey(), documentId: allocation.documentId, amount: amountInput(allocation.amountMinor) }))
      : [{ key: newIdempotencyKey(), documentId: "", amount: "" }]);
    setReason("");
    setIdempotencyKey(newIdempotencyKey());
    setMessage(null);
    reallocate.reset();
  }

  function updateRow(key: string, patch: Partial<AllocationDraft>) {
    setRows((current) => current.map((row) => row.key === key ? { ...row, ...patch } : row));
  }

  function submit(event: FormEvent) {
    event.preventDefault();
    if (!validationError) reallocate.mutate();
  }

  if (!canReview) return null;

  const partyName = (id: string) => parties.data?.find((party) => party.id === id)?.name ?? id;

  return (
    <section className="panel register-section allocation-panel" id="payment-allocations">
      <div className="panel-heading simple"><div><p className="folio-kicker">Reconciliation</p><h2>Payment allocation review</h2><p>Review receipts and supplier payments, then replace a payment&apos;s document allocations as one audited action.</p></div><ArrowLeftRight /></div>
      <div className="filter-row allocation-filters">
        <label className="compact-select">Direction<select value={direction} onChange={(event) => { setDirection(event.target.value as typeof direction); setSelected(null); }}><option value="ALL">All payments</option><option value="RECEIPT">Customer receipts</option><option value="PAYMENT">Supplier payments</option></select></label>
        <label className="compact-select">Party<select value={partyId} onChange={(event) => { setPartyId(event.target.value); setSelected(null); }}><option value="">All parties</option>{(parties.data ?? []).map((party) => <option key={party.id} value={party.id}>{party.name}</option>)}</select></label>
        <button type="button" className="text-button" disabled={review.isFetching} onClick={() => void review.refetch()}>{review.isFetching ? "Refreshing…" : "Refresh"}</button>
      </div>
      {message ? <p className="invitation-success" role="status">{message}</p> : null}
      {review.isLoading ? <LoadingBlock label="Loading payment allocations…" /> : review.error ? <div role="alert"><p className="form-error">Could not load payment allocations.</p><button type="button" className="text-button" onClick={() => void review.refetch()}>Try again</button></div> : review.data ? (
        <>
          <dl className="allocation-totals"><div><dt>Payments</dt><dd>{review.data.totals.paymentCount}</dd></div><div><dt>Payment total</dt><dd>{formatMoney(review.data.totals.paymentTotalMinor)}</dd></div><div><dt>Allocated</dt><dd>{formatMoney(review.data.totals.allocatedTotalMinor)}</dd></div><div><dt>Unallocated</dt><dd>{formatMoney(review.data.totals.unallocatedTotalMinor)}</dd></div><div><dt>Document dues</dt><dd>{formatMoney(review.data.totals.outstandingTotalMinor)}</dd></div></dl>
          {review.data.payments.length ? (
            <div className="table-scroll"><table><caption className="sr-only">Payments available for allocation review</caption><thead><tr><th>Payment</th><th>Party</th><th>Date</th><th>Direction</th><th className="amount-cell">Amount</th><th className="amount-cell">Allocated</th><th className="amount-cell">Unallocated</th><th><span className="sr-only">Actions</span></th></tr></thead><tbody>{review.data.payments.map((payment) => <tr key={payment.id}><td><strong>{payment.reference ?? payment.id}</strong><small>{payment.method}</small></td><td>{partyName(payment.party)}</td><td>{formatDateTime(payment.paymentDate)}</td><td><StatusBadge tone={payment.direction === "RECEIPT" ? "positive" : "warning"}>{formatKind(payment.direction)}</StatusBadge></td><td className="amount-cell">{formatMoney(payment.amountMinor)}</td><td className="amount-cell">{formatMoney(payment.allocatedTotalMinor)}</td><td className="amount-cell">{formatMoney(payment.unallocatedTotalMinor)}</td><td><button type="button" className="text-button" onClick={() => openPayment(payment)}>Review</button></td></tr>)}</tbody></table></div>
          ) : <EmptyState title="No payments to review" detail="Change the filters or post a payment first." />}
          <details className="outstanding-documents"><summary>Outstanding sale and purchase documents ({review.data.totals.outstandingDocumentCount})</summary>{review.data.outstandingDocuments.length ? <div className="table-scroll"><table><thead><tr><th>Document</th><th>Party</th><th>Type</th><th>Date</th><th className="amount-cell">Total</th><th className="amount-cell">Due</th></tr></thead><tbody>{review.data.outstandingDocuments.slice(0, 100).map((document) => <tr key={`${document.documentType}-${document.documentId}`}><td><strong>{document.number}</strong><small>{document.documentId}</small></td><td>{document.partyName ?? partyName(document.partyId ?? "")}</td><td>{formatKind(document.documentType)}</td><td>{formatDateTime(document.documentDate)}</td><td className="amount-cell">{formatMoney(document.grandTotalMinor)}</td><td className="amount-cell">{formatMoney(document.dueTotalMinor)}</td></tr>)}</tbody></table></div> : <p className="muted-copy">No outstanding documents match these filters.</p>}</details>
        </>
      ) : null}

      {selected ? (
        <section className="panel allocation-editor" role="dialog" aria-label={`Reallocate payment ${selected.reference ?? selected.id}`}>
          <header className="panel-heading simple"><div><p className="folio-kicker">Replace allocation plan</p><h2>Reallocate {formatMoney(selected.amountMinor)}</h2><p>{formatKind(selected.direction)} · {partyName(selected.party)} · {selected.method}</p></div><button type="button" className="icon-button" aria-label="Close allocation editor" onClick={() => setSelected(null)}><X /></button></header>
          <form className="manual-form" onSubmit={submit}>
            <p className="field-note">Existing allocations are released before the new plan is applied atomically. The full payment must be assigned, and every document must belong to this party and location.</p>
            <div className="allocation-rows">{rows.map((row, index) => {
              const option = documentOptions.find((document) => document.documentId === row.documentId);
              return <div className="allocation-row" key={row.key}><label>Document<select value={row.documentId} onChange={(event) => updateRow(row.key, { documentId: event.target.value })} required><option value="">Select document</option>{documentOptions.map((document) => <option key={document.documentId} value={document.documentId}>{document.number} · {formatMoney(document.availableMinor)} available</option>)}</select></label><label>Amount (₹)<input type="number" min="0.01" max={option ? option.availableMinor / 100 : undefined} step="0.01" value={row.amount} onChange={(event) => updateRow(row.key, { amount: event.target.value })} required /></label><button type="button" className="icon-button bordered" aria-label={`Remove allocation ${index + 1}`} onClick={() => setRows((current) => current.filter((item) => item.key !== row.key))}><Trash2 /></button></div>;
            })}</div>
            <button type="button" className="secondary-button" onClick={() => setRows((current) => [...current, { key: newIdempotencyKey(), documentId: "", amount: "" }])}><Plus />Add document</button>
            <dl className="amount-breakdown"><div><dt>Payment amount</dt><dd>{formatMoney(selected.amountMinor)}</dd></div><div><dt>New allocated total</dt><dd>{formatMoney(draftedTotal)}</dd></div><div className={remaining === 0 ? "" : "outstanding"}><dt>{remaining >= 0 ? "Remaining to assign" : "Over-assigned"}</dt><dd>{formatMoney(Math.abs(remaining))}</dd></div></dl>
            <label>Reason<textarea value={reason} onChange={(event) => setReason(event.target.value)} maxLength={240} rows={2} placeholder="Why is this allocation changing?" required /></label>
            {validationError ? <p className="form-error" role="alert">{validationError}</p> : null}
            {reallocate.error ? <p className="form-error" role="alert">{reallocate.error.message}</p> : null}
            <div className="review-actions"><button type="button" className="secondary-button" onClick={() => setSelected(null)}>Cancel</button><button type="submit" className="primary-button" disabled={reallocate.isPending || Boolean(validationError)}>{reallocate.isPending ? <LoaderCircle className="spin" /> : <ArrowLeftRight />}{reallocate.isPending ? "Reallocating…" : "Confirm reallocation"}</button></div>
          </form>
        </section>
      ) : null}
    </section>
  );
}
