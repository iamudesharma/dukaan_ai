import { useState, type FormEvent } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Check, X } from "lucide-react";
import { useWorkspace } from "../../app/WorkspaceContext";
import { createExpense, createPayment, createPurchase, getParties, getProducts } from "../../data/repository";

interface Props {
  kind: "purchase" | "payment" | "expense" | null;
  onClose: () => void;
}

export function QuickEntryDialog({ kind, onClose }: Props) {
  const { bootstrap, locationId } = useWorkspace();
  const queryClient = useQueryClient();
  const [partyId, setPartyId] = useState("");
  const [packId, setPackId] = useState("");
  const [quantity, setQuantity] = useState("1");
  const [amount, setAmount] = useState("");
  const [category, setCategory] = useState("Shop expense");
  const [direction, setDirection] = useState<"RECEIPT" | "PAYMENT">("RECEIPT");
  const [message, setMessage] = useState<string | null>(null);

  const parties = useQuery({
    queryKey: ["parties", bootstrap.business.id],
    queryFn: () => getParties(bootstrap.business.id),
    enabled: kind !== null,
  });
  const products = useQuery({
    queryKey: ["products", bootstrap.business.id, locationId],
    queryFn: () => getProducts(bootstrap.business.id, locationId),
    enabled: kind === "purchase",
  });

  const post = useMutation({
    mutationFn: async () => {
      const amountMinor = Math.round(Number(amount || 0) * 100);
      if (kind === "purchase") {
        return createPurchase({
          businessId: bootstrap.business.id,
          locationId,
          supplierId: partyId,
          lines: [{ packId, quantity, unitCostMinor: amountMinor }],
        });
      }
      if (kind === "payment") {
        return createPayment({
          businessId: bootstrap.business.id,
          locationId,
          partyId,
          direction,
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
      await queryClient.invalidateQueries();
    },
  });

  if (!kind) return null;

  function submit(event: FormEvent) {
    event.preventDefault();
    setMessage(null);
    post.mutate();
  }

  return (
    <div className="dialog-backdrop" onMouseDown={(event) => { if (event.currentTarget === event.target) onClose(); }}>
      <section className="manual-dialog" role="dialog" aria-modal="true" aria-labelledby="quick-entry-title">
        <header><div><p className="eyebrow">Manual entry</p><h2 id="quick-entry-title">Record a {kind}</h2></div><button className="icon-button" onClick={onClose} aria-label="Close form"><X /></button></header>
        {message ? (
          <div className="manual-success" role="status"><span><Check /></span><h3>{message}</h3><button className="primary-button full" onClick={onClose}>Done</button></div>
        ) : (
          <form className="manual-form" onSubmit={submit}>
            {kind !== "expense" ? (
              <label>Party<select value={partyId} onChange={(e) => setPartyId(e.target.value)} required><option value="">Select party</option>{parties.data?.map((p) => <option key={p.id} value={p.id}>{p.name}</option>)}</select></label>
            ) : null}
            {kind === "purchase" ? (
              <>
                <label>Product<select value={packId} onChange={(e) => setPackId(e.target.value)} required><option value="">Select product</option>{products.data?.map((p) => <option key={p.id} value={p.packId}>{p.name}</option>)}</select></label>
                <div className="two-fields">
                  <label>Quantity<input type="number" min="0.001" step="0.001" value={quantity} onChange={(e) => setQuantity(e.target.value)} required /></label>
                  <label>Unit cost (₹)<input type="number" min="0" step="0.01" value={amount} onChange={(e) => setAmount(e.target.value)} required /></label>
                </div>
              </>
            ) : null}
            {kind === "payment" ? (
              <>
                <label className="compact-select">Direction<select value={direction} onChange={(e) => setDirection(e.target.value as typeof direction)}><option value="RECEIPT">Money in (receipt)</option><option value="PAYMENT">Money out (payment)</option></select></label>
                <label>Amount (₹)<input type="number" min="0.01" step="0.01" value={amount} onChange={(e) => setAmount(e.target.value)} required /></label>
              </>
            ) : null}
            {kind === "expense" ? (
              <>
                <label>Category<input value={category} onChange={(e) => setCategory(e.target.value)} required /></label>
                <label>Amount (₹)<input type="number" min="0.01" step="0.01" value={amount} onChange={(e) => setAmount(e.target.value)} required /></label>
              </>
            ) : null}
            <button className="primary-button full" disabled={post.isPending}>{post.isPending ? "Recording…" : `Record ${kind}`}</button>
            {post.error ? <p className="form-error" role="alert">{post.error.message}</p> : null}
          </form>
        )}
      </section>
    </div>
  );
}
