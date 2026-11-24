import { useEffect, useState, type FormEvent } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Check, X } from "lucide-react";
import { useWorkspace } from "../../app/WorkspaceContext";
import { LoadingBlock } from "../../components/LoadingBlock";
import { createExpense, createPayment, createPurchase, getOpenDocuments, getParties, getProducts } from "../../data/repository";
import { formatMoney } from "../../lib/format";

interface Props {
  kind: "purchase" | "payment" | "expense" | null;
  onClose: () => void;
}

export function QuickEntryDialog({ kind, onClose }: Props) {
  const { bootstrap, access, locationId } = useWorkspace();
  const queryClient = useQueryClient();
  const [partyId, setPartyId] = useState("");
  const [packId, setPackId] = useState("");
  const [quantity, setQuantity] = useState("1");
  const [amount, setAmount] = useState("");
  const [category, setCategory] = useState("Shop expense");
  const [direction, setDirection] = useState<"RECEIPT" | "PAYMENT">("RECEIPT");
  const [documentId, setDocumentId] = useState("");
  const [message, setMessage] = useState<string | null>(null);
  const [formError, setFormError] = useState<string | null>(null);
  const kindAllowed = kind === "payment"
    ? access.canRecordCustomerReceipts
    : kind === "purchase"
      ? access.canRecordPurchases
      : kind === "expense"
        ? access.canRecordExpenses
        : false;
  const canSelectPaymentDirection = kind !== "payment" || access.canRecordSupplierPayments;
  const entryLabel = kind === "payment" && access.isCashier ? "receipt" : kind;

  const parties = useQuery({
    queryKey: ["parties", bootstrap.user.id, bootstrap.business.id],
    queryFn: () => getParties(bootstrap.business.id, { customersOnly: access.isCashier }),
    enabled: kindAllowed,
  });
  const products = useQuery({
    queryKey: ["products", bootstrap.user.id, bootstrap.business.id, locationId],
    queryFn: () => getProducts(bootstrap.business.id, locationId, { includeWholesalePrices: access.canViewWholesalePrices }),
    enabled: kindAllowed && kind === "purchase",
  });
  const openDocuments = useQuery({
    queryKey: ["open-documents", bootstrap.user.id, bootstrap.business.id, locationId, partyId, direction],
    queryFn: () => getOpenDocuments(bootstrap.business.id, locationId, partyId, direction),
    enabled: kindAllowed && kind === "payment" && Boolean(partyId),
  });

  useEffect(() => {
    if (access.isCashier) setDirection("RECEIPT");
  }, [access.isCashier]);

  useEffect(() => {
    if (kind && !kindAllowed) onClose();
  }, [kind, kindAllowed, onClose]);

  useEffect(() => {
    setDocumentId("");
    setFormError(null);
  }, [partyId, direction, kind]);

  const selectedDocument = openDocuments.data?.find((document) => document.id === documentId);
  const amountMinor = Math.round(Number(amount || 0) * 100);

  const post = useMutation({
    mutationFn: async () => {
      if (!kindAllowed) throw new Error("Your role cannot record this entry.");
      if (kind === "payment" && direction === "PAYMENT" && !access.canRecordSupplierPayments) {
        throw new Error("Your role cannot record supplier payments.");
      }
      if (!Number.isFinite(amountMinor) || amountMinor <= 0) {
        throw new Error("Enter an amount greater than zero.");
      }
      if (kind === "purchase") {
        if (!partyId || !packId) throw new Error("Select a supplier and product.");
        return createPurchase({
          businessId: bootstrap.business.id,
          locationId,
          supplierId: partyId,
          lines: [{ packId, quantity, unitCostMinor: amountMinor }],
        });
      }
      if (kind === "payment") {
        if (!partyId || !documentId || !selectedDocument) {
          throw new Error("Select an outstanding sale or purchase for this party.");
        }
        if (amountMinor > selectedDocument.outstandingMinor) {
          throw new Error(`The amount cannot exceed the outstanding ${formatMoney(selectedDocument.outstandingMinor)}.`);
        }
        return createPayment({
          businessId: bootstrap.business.id,
          locationId,
          partyId,
          direction,
          ...(direction === "RECEIPT" ? { saleId: documentId } : { purchaseId: documentId }),
          amountMinor,
        });
      }
      return createExpense({
        businessId: bootstrap.business.id,
        locationId,
        category,
        amountMinor,
      });
    },
    onSuccess: async () => {
      setMessage("Recorded successfully.");
      setFormError(null);
      await queryClient.invalidateQueries();
    },
  });

  if (!kind || !kindAllowed) return null;

  function submit(event: FormEvent) {
    event.preventDefault();
    if (!kindAllowed || (kind === "payment" && direction === "PAYMENT" && !access.canRecordSupplierPayments)) return;
    setMessage(null);
    setFormError(null);
    if (kind === "payment" && (!partyId || !documentId)) {
      setFormError("Select a party and an outstanding document before recording this payment.");
      return;
    }
    post.mutate();
  }

  const documentLabel = direction === "RECEIPT" ? "sale" : "purchase";

  return (
    <div className="dialog-backdrop" onMouseDown={(event) => { if (event.currentTarget === event.target) onClose(); }}>
      <section className="manual-dialog" role="dialog" aria-modal="true" aria-labelledby="quick-entry-title">
        <header><div><p className="folio-kicker">Manual entry</p><h2 id="quick-entry-title">Record a {entryLabel}</h2></div><button className="icon-button" onClick={onClose} aria-label="Close form"><X /></button></header>
        {message ? (
          <div className="manual-success" role="status"><span><Check /></span><h3>{message}</h3><button className="primary-button full" onClick={onClose}>Done</button></div>
        ) : (
          <form className="manual-form" onSubmit={submit}>
            {kind !== "expense" ? (
              <>
                <label>Party
                  <select value={partyId} onChange={(event) => setPartyId(event.target.value)} required disabled={parties.isLoading}>
                    <option value="">{parties.isLoading ? "Loading parties…" : "Select party"}</option>
                    {parties.data?.filter((party) => kind === "purchase"
                      ? party.kind !== "CUSTOMER"
                      : access.isCashier ? party.kind !== "SUPPLIER" : true).map((party) => <option key={party.id} value={party.id}>{party.name}</option>)}
                  </select>
                </label>
                {parties.error ? <p className="form-error" role="alert">Could not load parties. Check your connection and try again.</p> : null}
              </>
            ) : null}
            {kind === "purchase" ? (
              <>
                <label>Product<select value={packId} onChange={(event) => setPackId(event.target.value)} required disabled={products.isLoading}><option value="">{products.isLoading ? "Loading products…" : "Select product"}</option>{products.data?.map((product) => <option key={product.id} value={product.packId}>{product.name}</option>)}</select></label>
                {products.error ? <p className="form-error" role="alert">Could not load products. Check your connection and try again.</p> : null}
                <div className="two-fields">
                  <label>Quantity<input type="number" min="0.001" step="0.001" value={quantity} onChange={(event) => setQuantity(event.target.value)} required /></label>
                  <label>Unit cost (₹)<input type="number" min="0" step="0.01" value={amount} onChange={(event) => setAmount(event.target.value)} required /></label>
                </div>
              </>
            ) : null}
            {kind === "payment" ? (
              <>
                {canSelectPaymentDirection ? <label className="compact-select">Direction<select value={direction} onChange={(event) => setDirection(event.target.value as typeof direction)}><option value="RECEIPT">Money in (receipt)</option><option value="PAYMENT">Money out (payment)</option></select></label> : null}
                {!partyId ? (
                  <p className="field-note">Select a party to load their outstanding {documentLabel}s.</p>
                ) : openDocuments.isLoading ? (
                  <LoadingBlock label={`Loading outstanding ${documentLabel}s…`} />
                ) : openDocuments.error ? (
                  <div role="alert">
                    <p className="form-error">Could not load outstanding {documentLabel}s. Check your connection and try again.</p>
                    <button type="button" className="text-button" onClick={() => void openDocuments.refetch()}>Try again</button>
                  </div>
                ) : openDocuments.data?.length ? (
                  <label>Outstanding {documentLabel}
                    <select value={documentId} onChange={(event) => setDocumentId(event.target.value)} required>
                      <option value="">Select an outstanding {documentLabel}</option>
                      {openDocuments.data.map((document) => (
                        <option key={document.id} value={document.id}>
                          {document.number} · {formatMoney(document.outstandingMinor)} outstanding
                        </option>
                      ))}
                    </select>
                  </label>
                ) : (
                  <p className="field-note" role="status">No outstanding {documentLabel}s for this party at this location.</p>
                )}
                <label>Amount (₹)
                  <input
                    type="number"
                    min="0.01"
                    max={selectedDocument ? selectedDocument.outstandingMinor / 100 : undefined}
                    step="0.01"
                    value={amount}
                    onChange={(event) => setAmount(event.target.value)}
                    required
                  />
                </label>
                {selectedDocument ? <p className="field-note">{formatMoney(selectedDocument.outstandingMinor)} remains outstanding on {selectedDocument.number}.</p> : null}
              </>
            ) : null}
            {kind === "expense" ? (
              <>
                <label>Category<input value={category} onChange={(event) => setCategory(event.target.value)} required /></label>
                <label>Amount (₹)<input type="number" min="0.01" step="0.01" value={amount} onChange={(event) => setAmount(event.target.value)} required /></label>
              </>
            ) : null}
            <button
              className="primary-button full"
              disabled={post.isPending || parties.isLoading || products.isLoading || (kind === "payment" && (!partyId || !documentId))}
            >
              {post.isPending ? "Recording…" : `Record ${entryLabel}`}
            </button>
            {formError ? <p className="form-error" role="alert">{formError}</p> : null}
            {post.error ? <p className="form-error" role="alert">{post.error.message}</p> : null}
          </form>
        )}
      </section>
    </div>
  );
}
