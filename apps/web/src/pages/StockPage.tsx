import { useMemo, useState, type FormEvent } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { ArrowLeftRight, Boxes, PackagePlus, Search, X } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { EmptyState } from "../components/EmptyState";
import { LoadingBlock } from "../components/LoadingBlock";
import { PageHeader } from "../components/PageHeader";
import { StatusBadge } from "../components/StatusBadge";
import { adjustStock, createProduct, createTransfer, getProducts, getStockReport } from "../data/repository";
import { formatMoney } from "../lib/format";

export function StockPage() {
  const { bootstrap, locationId } = useWorkspace();
  const [search, setSearch] = useState("");
  const [showOnly, setShowOnly] = useState<"all" | "low" | "out">("all");
  const [adding, setAdding] = useState(false);
  const [transferring, setTransferring] = useState(false);
  const [adjustingId, setAdjustingId] = useState<string | null>(null);
  const [productName, setProductName] = useState("");
  const [sku, setSku] = useState("");
  const [retail, setRetail] = useState("");
  const [wholesale, setWholesale] = useState("");
  const [toLocation, setToLocation] = useState("");
  const [transferPack, setTransferPack] = useState("");
  const [transferQty, setTransferQty] = useState("1");
  const [delta, setDelta] = useState("1");
  const [reason, setReason] = useState("");
  const queryClient = useQueryClient();
  const query = useQuery({
    queryKey: ["products", bootstrap.business.id, locationId],
    queryFn: () => getProducts(bootstrap.business.id, locationId),
  });
  const report = useQuery({
    queryKey: ["stock-report", bootstrap.business.id, locationId],
    queryFn: () => getStockReport(bootstrap.business.id, locationId),
  });
  const addProduct = useMutation({
    mutationFn: () => createProduct({
      business: bootstrap.business.id,
      name: productName,
      sku: sku || undefined,
      baseUnit: "PIECE",
      packs: [{
        name: "Default pack",
        retailPriceMinor: Math.round(Number(retail || 0) * 100),
        wholesalePriceMinor: Math.round(Number(wholesale || 0) * 100),
      }],
    }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["products"] });
      await queryClient.invalidateQueries({ queryKey: ["stock-report"] });
      setAdding(false);
      setProductName("");
      setSku("");
      setRetail("");
      setWholesale("");
    },
  });
  const transfer = useMutation({
    mutationFn: () => createTransfer({
      businessId: bootstrap.business.id,
      fromLocationId: locationId,
      toLocationId: toLocation,
      lines: [{ packId: transferPack, quantity: transferQty }],
    }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["products"] });
      setTransferring(false);
    },
  });
  const adjust = useMutation({
    mutationFn: ({ productId }: { productId: string }) => adjustStock({
      businessId: bootstrap.business.id,
      locationId,
      productId,
      quantityDelta: delta,
      reason: reason || "Manual correction",
    }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["products"] });
      await queryClient.invalidateQueries({ queryKey: ["stock-report"] });
      setAdjustingId(null);
      setDelta("1");
      setReason("");
    },
  });
  const products = useMemo(() => (query.data ?? []).filter((product) => {
    if (!`${product.name} ${product.sku}`.toLowerCase().includes(search.toLowerCase())) return false;
    if (showOnly === "low") return Number(product.onHand) <= Number(product.reorderLevel);
    if (showOnly === "out") return Number(product.onHand) <= 0;
    return true;
  }), [query.data, search, showOnly]);
  const stockValue = products.reduce((sum, product) => sum + Number(product.onHand) * product.wholesalePriceMinor, 0);
  const lowStock = products.filter((product) => Number(product.onHand) <= Number(product.reorderLevel));

  return (
    <>
      <PageHeader
        eyebrow="Inventory"
        title="Stock & transfers"
        description="Products are shared across the business; quantities and movements always belong to one location."
        actions={<><button className="secondary-button" onClick={() => setTransferring(true)}><ArrowLeftRight />Transfer stock</button><button className="primary-button" onClick={() => setAdding(true)}><PackagePlus />Add product</button></>}
      />
      {adding ? (
        <section className="panel" role="dialog" aria-label="Add product">
          <form className="manual-form" onSubmit={(e: FormEvent) => { e.preventDefault(); if (productName.trim()) addProduct.mutate(); }}>
            <div className="two-fields">
              <label>Name<input value={productName} onChange={(e) => setProductName(e.target.value)} required /></label>
              <label>SKU<input value={sku} onChange={(e) => setSku(e.target.value)} /></label>
            </div>
            <div className="two-fields">
              <label>Retail price<input type="number" min="0" step="0.01" value={retail} onChange={(e) => setRetail(e.target.value)} required /></label>
              <label>Wholesale price<input type="number" min="0" step="0.01" value={wholesale} onChange={(e) => setWholesale(e.target.value)} required /></label>
            </div>
            <div className="review-actions">
              <button type="button" className="secondary-button" onClick={() => setAdding(false)}>Cancel</button>
              <button className="primary-button" disabled={addProduct.isPending}>{addProduct.isPending ? "Saving…" : "Save product"}</button>
            </div>
            {addProduct.error ? <p className="form-error" role="alert">{addProduct.error.message}</p> : null}
          </form>
        </section>
      ) : null}
      {transferring ? (
        <section className="panel" role="dialog" aria-label="Transfer stock">
          <form className="manual-form" onSubmit={(e: FormEvent) => { e.preventDefault(); if (toLocation && transferPack) transfer.mutate(); }}>
            <div className="two-fields">
              <label>Product<select value={transferPack} onChange={(e) => setTransferPack(e.target.value)} required><option value="">Select product</option>{(query.data ?? []).map((p) => <option key={p.id} value={p.packId}>{p.name}</option>)}</select></label>
              <label>To location<select value={toLocation} onChange={(e) => setToLocation(e.target.value)} required><option value="">Select location</option>{bootstrap.locations.filter((l) => l.id !== locationId).map((l) => <option key={l.id} value={l.id}>{l.name}</option>)}</select></label>
            </div>
            <label>Quantity<input type="number" min="0.001" step="0.001" value={transferQty} onChange={(e) => setTransferQty(e.target.value)} required /></label>
            <div className="review-actions">
              <button type="button" className="secondary-button" onClick={() => setTransferring(false)}>Cancel</button>
              <button className="primary-button" disabled={transfer.isPending}>{transfer.isPending ? "Posting…" : "Post transfer"}</button>
            </div>
            {transfer.error ? <p className="form-error" role="alert">{transfer.error.message}</p> : null}
          </form>
        </section>
      ) : null}
      {report.data?.length ? (
        <section className="panel"><p><strong>{report.data.filter((r) => r.isLowStock).length} low-stock rows</strong> in the server stock report.</p></section>
      ) : null}
      <section className="mini-metrics">
        <div><span className="mini-icon blue"><Boxes /></span><div><span>Products</span><strong>{products.length}</strong></div></div>
        <div><span className="mini-icon amber"><Boxes /></span><div><span>Low stock</span><strong>{lowStock.length}</strong></div></div>
        <div><span className="mini-icon green"><Boxes /></span><div><span>Stock value at wholesale price</span><strong>{formatMoney(stockValue)}</strong></div></div>
      </section>
      <section className="panel data-panel">
        <div className="filter-row">
          <label className="inline-search wide"><Search /><span className="sr-only">Search products</span><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search product, SKU or barcode" /></label>
          <label className="compact-select">Show<select value={showOnly} onChange={(e) => setShowOnly(e.target.value as typeof showOnly)}><option value="all">All products</option><option value="low">Low stock</option><option value="out">Out of stock</option></select></label>
        </div>
        {query.isLoading ? <LoadingBlock /> : products.length ? (
          <div className="table-scroll">
            <table>
              <thead><tr><th>Product</th><th>On hand</th><th>Reorder at</th><th>Retail</th><th>Wholesale</th><th>GST</th><th>Status</th><th><span className="sr-only">Actions</span></th></tr></thead>
              <tbody>{products.map((product) => {
                const low = Number(product.onHand) <= Number(product.reorderLevel);
                return <tr key={product.id}>
                  <td><strong>{product.name}</strong><small>{product.sku}</small></td>
                  <td><strong>{product.onHand}</strong> {product.unit}</td>
                  <td>{product.reorderLevel} {product.unit}</td>
                  <td>{formatMoney(product.retailPriceMinor)}</td>
                  <td>{formatMoney(product.wholesalePriceMinor)}</td>
                  <td>{product.gstRateBps / 100}%</td>
                  <td>{low ? <StatusBadge tone="warning">Low stock</StatusBadge> : <StatusBadge tone="positive">In stock</StatusBadge>}</td>
                  <td>{adjustingId === product.id ? (
                    <form className="inline-search" onSubmit={(e: FormEvent) => { e.preventDefault(); adjust.mutate({ productId: product.id }); }}>
                      <input aria-label="Quantity delta" type="number" step="0.001" value={delta} onChange={(e) => setDelta(e.target.value)} style={{ width: 72 }} />
                      <input aria-label="Reason" value={reason} onChange={(e) => setReason(e.target.value)} placeholder="Reason" style={{ width: 110 }} />
                      <button className="text-button" disabled={adjust.isPending}>Save</button>
                      <button className="icon-button" aria-label="Cancel adjustment" type="button" onClick={() => setAdjustingId(null)}><X /></button>
                    </form>
                  ) : <button type="button" className="text-button" onClick={() => setAdjustingId(product.id)}>Adjust</button>}</td>
                </tr>;
              })}</tbody>
            </table>
          </div>
        ) : <EmptyState title="No products found" detail="Add a product or change your search." />}
      </section>
    </>
  );
}
