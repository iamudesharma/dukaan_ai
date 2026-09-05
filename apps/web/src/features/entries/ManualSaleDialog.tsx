import { useEffect, useMemo, useState, type FormEvent } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { AlertTriangle, Check, LoaderCircle, PackageMinus, ReceiptText, X } from "lucide-react";
import { useWorkspace } from "../../app/WorkspaceContext";
import { getParties, getProducts, recordManualSale } from "../../data/repository";
import { formatMoney } from "../../lib/format";
import { saveOfflineDraft } from "../../lib/offlineDrafts";
import type { ManualSaleInput } from "../../types";

interface Props {
  open: boolean;
  onClose: () => void;
}

export function ManualSaleDialog({ open, onClose }: Props) {
  const { bootstrap, locationId } = useWorkspace();
  const products = useQuery({ queryKey: ["products", bootstrap.business.id, locationId], queryFn: () => getProducts(bootstrap.business.id, locationId), enabled: open });
  const parties = useQuery({ queryKey: ["parties", bootstrap.business.id], queryFn: () => getParties(bootstrap.business.id), enabled: open });
  const [productId, setProductId] = useState("");
  const [customerId, setCustomerId] = useState("");
  const [quantity, setQuantity] = useState("1");
  const [unitPrice, setUnitPrice] = useState("");
  const [paid, setPaid] = useState("0");
  const [priceMode, setPriceMode] = useState<"RETAIL" | "WHOLESALE">("RETAIL");
  const [paymentMode, setPaymentMode] = useState<ManualSaleInput["paymentMode"]>("CASH");
  const [reviewing, setReviewing] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const queryClient = useQueryClient();
  const selectedProduct = products.data?.find((product) => product.id === productId);
  const selectedCustomer = parties.data?.find((party) => party.id === customerId);
  const unitPriceMinor = Math.round(Number(unitPrice || 0) * 100);
  const paidMinor = Math.round(Number(paid || 0) * 100);
  const totalMinor = Math.round(Number(quantity || 0) * unitPriceMinor);
  const dueMinor = totalMinor - paidMinor;
  const valid = Boolean(selectedProduct && Number(quantity) > 0 && unitPriceMinor >= 0 && paidMinor >= 0 && dueMinor >= 0 && (dueMinor === 0 || selectedCustomer));

  const input = useMemo<ManualSaleInput | null>(() => selectedProduct ? ({
    businessId: bootstrap.business.id,
    locationId,
    customerId: selectedCustomer?.id,
    customerName: selectedCustomer?.name,
    productId: selectedProduct.id,
    packId: selectedProduct.packId,
    productName: selectedProduct.name,
    quantity,
    unitPriceMinor,
    paidMinor,
    paymentMode,
    priceMode,
  }) : null, [bootstrap.business.id, locationId, paidMinor, paymentMode, priceMode, quantity, selectedCustomer, selectedProduct, unitPriceMinor]);

  const post = useMutation({
    mutationFn: (sale: ManualSaleInput) => recordManualSale(sale),
    onSuccess: async (entry) => {
      setMessage(`${entry.number} recorded successfully.`);
      await queryClient.invalidateQueries();
    },
  });

  useEffect(() => {
    if (!open) {
      setReviewing(false);
      setMessage(null);
      setProductId("");
      setCustomerId("");
      setQuantity("1");
      setUnitPrice("");
      setPaid("0");
      post.reset();
    }
  }, [open]);

  if (!open) return null;

  function chooseProduct(id: string) {
    setProductId(id);
    const product = products.data?.find((candidate) => candidate.id === id);
    if (product) {
      const price = priceMode === "WHOLESALE" ? product.wholesalePriceMinor : product.retailPriceMinor;
      setUnitPrice((price / 100).toFixed(2));
    }
  }

  function choosePriceMode(mode: "RETAIL" | "WHOLESALE") {
    setPriceMode(mode);
    if (selectedProduct) {
      const price = mode === "WHOLESALE" ? selectedProduct.wholesalePriceMinor : selectedProduct.retailPriceMinor;
      setUnitPrice((price / 100).toFixed(2));
    }
  }

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (!input || !valid) return;
    if (!navigator.onLine) {
      await saveOfflineDraft({ kind: "sale", locationId, content: input as unknown as Record<string, unknown> });
      setMessage("Saved on this device as a draft. Nothing was posted.");
      return;
    }
    post.mutate(input);
  }

  return (
    <div className="dialog-backdrop" onMouseDown={(event) => { if (event.currentTarget === event.target) onClose(); }}>
      <section className="manual-dialog" role="dialog" aria-modal="true" aria-labelledby="manual-sale-title">
        <header><div><p className="eyebrow">Manual entry</p><h2 id="manual-sale-title">Record a sale</h2></div><button className="icon-button" onClick={onClose} aria-label="Close sale form"><X /></button></header>
        {message ? (
          <div className="manual-success" role="status"><span><Check /></span><h3>{message}</h3><p>{navigator.onLine ? "Stock and outstanding balances were updated together." : "Review and post it after reconnecting."}</p><button className="primary-button full" onClick={onClose}>Done</button></div>
        ) : reviewing && input ? (
          <form className="manual-review" onSubmit={submit}>
            <div className="review-callout"><ReceiptText /><div><strong>Check before recording</strong><p>This will post online and cannot be silently edited later.</p></div></div>
            <dl>
              <div><dt>Customer</dt><dd>{selectedCustomer?.name ?? "Walk-in customer"}</dd></div>
              <div><dt>Product</dt><dd>{selectedProduct?.name}</dd></div>
              <div><dt>Quantity</dt><dd>{quantity} {selectedProduct?.unit}</dd></div>
              <div><dt>Unit price</dt><dd>{formatMoney(unitPriceMinor)}</dd></div>
              <div><dt>Total</dt><dd>{formatMoney(totalMinor)}</dd></div>
              <div><dt>Paid now</dt><dd>{formatMoney(paidMinor)} · {paymentMode}</dd></div>
              <div className="due"><dt>Pending</dt><dd>{formatMoney(dueMinor)}</dd></div>
            </dl>
            <div className="effects-card"><p><PackageMinus />Reduce {selectedProduct?.name} stock by {quantity}</p><p><ReceiptText />{dueMinor ? `Add ${formatMoney(dueMinor)} to ${selectedCustomer?.name}'s outstanding balance` : "No outstanding balance"}</p></div>
            <div className="review-actions"><button type="button" className="secondary-button" onClick={() => setReviewing(false)}>Back and edit</button><button className="primary-button" disabled={post.isPending}>{post.isPending ? <LoaderCircle className="spin" /> : <Check />}{post.isPending ? "Recording…" : `Record sale ${formatMoney(totalMinor)}`}</button></div>
            {post.error ? <p className="form-error" role="alert">{post.error.message}</p> : null}
          </form>
        ) : (
          <form className="manual-form" onSubmit={(event) => { event.preventDefault(); if (valid) setReviewing(true); }}>
            <div className="segmented-control" aria-label="Price type"><button type="button" className={priceMode === "RETAIL" ? "active" : ""} onClick={() => choosePriceMode("RETAIL")}>Retail</button><button type="button" className={priceMode === "WHOLESALE" ? "active" : ""} onClick={() => choosePriceMode("WHOLESALE")}>Wholesale</button></div>
            <label>Product<select value={productId} onChange={(event) => chooseProduct(event.target.value)} required><option value="">Select product</option>{products.data?.map((product) => <option value={product.id} key={product.id}>{product.name} · {product.onHand} in stock</option>)}</select></label>
            <label>Customer <span className="optional">Optional for fully paid sales</span><select value={customerId} onChange={(event) => setCustomerId(event.target.value)}><option value="">Walk-in customer</option>{parties.data?.filter((party) => party.kind !== "SUPPLIER").map((party) => <option value={party.id} key={party.id}>{party.name}</option>)}</select></label>
            <div className="two-fields"><label>Quantity<input type="number" min="0.001" step="0.001" value={quantity} onChange={(event) => setQuantity(event.target.value)} required /></label><label>Unit price<input type="number" min="0" step="0.01" value={unitPrice} onChange={(event) => setUnitPrice(event.target.value)} required /></label></div>
            <div className="two-fields"><label>Paid now<input type="number" min="0" step="0.01" max={totalMinor / 100} value={paid} onChange={(event) => setPaid(event.target.value)} required /></label><label>Payment method<select value={paymentMode} onChange={(event) => setPaymentMode(event.target.value as ManualSaleInput["paymentMode"])}><option>CASH</option><option>UPI</option><option>CARD</option><option>BANK</option><option>OTHER</option></select></label></div>
            {dueMinor > 0 && !selectedCustomer ? <div className="warning-card"><AlertTriangle /><span>Select a customer to record {formatMoney(dueMinor)} as pending.</span></div> : null}
            <div className="sale-total"><span>Sale total</span><strong>{formatMoney(totalMinor)}</strong><small>{dueMinor > 0 ? `${formatMoney(dueMinor)} pending` : "Fully paid"}</small></div>
            <button className="primary-button full" disabled={!valid}>Review sale</button>
          </form>
        )}
      </section>
    </div>
  );
}
