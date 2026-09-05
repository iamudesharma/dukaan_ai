import { useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { ArrowLeftRight, Boxes, PackagePlus, Search } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { EmptyState } from "../components/EmptyState";
import { LoadingBlock } from "../components/LoadingBlock";
import { PageHeader } from "../components/PageHeader";
import { StatusBadge } from "../components/StatusBadge";
import { getProducts } from "../data/repository";
import { formatMoney } from "../lib/format";

export function StockPage() {
  const { bootstrap, locationId } = useWorkspace();
  const [search, setSearch] = useState("");
  const query = useQuery({
    queryKey: ["products", bootstrap.business.id, locationId],
    queryFn: () => getProducts(bootstrap.business.id, locationId),
  });
  const products = useMemo(() => (query.data ?? []).filter((product) =>
    `${product.name} ${product.sku}`.toLowerCase().includes(search.toLowerCase()),
  ), [query.data, search]);
  const stockValue = products.reduce((sum, product) => sum + Number(product.onHand) * product.wholesalePriceMinor, 0);
  const lowStock = products.filter((product) => Number(product.onHand) <= Number(product.reorderLevel));

  return (
    <>
      <PageHeader
        eyebrow="Inventory"
        title="Stock & transfers"
        description="Products are shared across the business; quantities and movements always belong to one location."
        actions={<><button className="secondary-button"><ArrowLeftRight />Transfer stock</button><button className="primary-button"><PackagePlus />Add product</button></>}
      />
      <section className="mini-metrics">
        <div><span className="mini-icon blue"><Boxes /></span><div><span>Products</span><strong>{products.length}</strong></div></div>
        <div><span className="mini-icon amber"><Boxes /></span><div><span>Low stock</span><strong>{lowStock.length}</strong></div></div>
        <div><span className="mini-icon green"><Boxes /></span><div><span>Stock value at wholesale price</span><strong>{formatMoney(stockValue)}</strong></div></div>
      </section>
      <section className="panel data-panel">
        <div className="filter-row">
          <label className="inline-search wide"><Search /><span className="sr-only">Search products</span><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search product, SKU or barcode" /></label>
          <label className="compact-select">Show<select defaultValue="all"><option value="all">All products</option><option value="low">Low stock</option><option value="out">Out of stock</option></select></label>
        </div>
        {query.isLoading ? <LoadingBlock /> : products.length ? (
          <div className="table-scroll">
            <table>
              <thead><tr><th>Product</th><th>On hand</th><th>Reorder at</th><th>Retail</th><th>Wholesale</th><th>GST</th><th>Status</th></tr></thead>
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
                </tr>;
              })}</tbody>
            </table>
          </div>
        ) : <EmptyState title="No products found" detail="Add a product or change your search." />}
      </section>
    </>
  );
}
