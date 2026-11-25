import { afterEach, describe, expect, it, vi } from "vitest";
import { screen, within } from "@testing-library/react";
import { StockPage } from "./StockPage";
import { jsonResponse, mockApi, workspaceWithRole } from "../test/apiMocks";
import { renderWithWorkspace } from "../test/renderWorkspace";

afterEach(() => vi.unstubAllGlobals());

const valuationResponse = {
  inventory: { total_quantity: "2", average_cost_minor: 12500, total_value_minor: 25000, known_value_minor: 25000, costing_complete: true },
  sales: { posted_sale_count: 1, line_count: 1, net_sales_minor: 30000, cogs_minor: 25000, gross_profit_minor: 5000, missing_cost_line_count: 0, costing_complete: true },
  results: [],
};

describe("StockPage", () => {
  it("shows API stock quantities and distinguishes low and out-of-stock products", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/products/": () => jsonResponse({
        results: [
          { id: "p1", name: "Shirt", sku: "SHIRT", base_unit: "PIECE", stock_quantity: "12.5", low_stock_threshold: "5", packs: [{ id: "pack1", retail_price_minor: 120000, wholesale_price_minor: 90000 }] },
          { id: "p2", name: "Soap", sku: "SOAP", base_unit: "PIECE", stock_quantity: "2", low_stock_threshold: "5", packs: [{ id: "pack2", retail_price_minor: 3000, wholesale_price_minor: 2500 }] },
          { id: "p3", name: "Comb", sku: "COMB", base_unit: "PIECE", stock_quantity: "0", low_stock_threshold: "3", packs: [{ id: "pack3", retail_price_minor: 2000, wholesale_price_minor: 1500 }] },
        ],
      }),
      "GET /api/v1/reports/stock/": () => jsonResponse({ results: [] }),
      "GET /api/v1/reports/valuation/": () => jsonResponse(valuationResponse),
    }));

    renderWithWorkspace(<StockPage />);

    const shirtRow = (await screen.findByText("Shirt")).closest("tr");
    const soapRow = screen.getByText("Soap").closest("tr");
    const combRow = screen.getByText("Comb").closest("tr");
    expect(shirtRow).not.toBeNull();
    expect(soapRow).not.toBeNull();
    expect(combRow).not.toBeNull();
    expect(within(shirtRow!).getByText("12.5")).toBeInTheDocument();
    expect(within(shirtRow!).getByText("In stock")).toBeInTheDocument();
    expect(within(soapRow!).getByText("2")).toBeInTheDocument();
    expect(within(soapRow!).getByText("Low stock")).toBeInTheDocument();
    expect(within(combRow!).getByText("0")).toBeInTheDocument();
    expect(within(combRow!).getByText("Out of stock")).toBeInTheDocument();
  });

  it("shows cashiers retail stock without wholesale prices, valuation or management controls", async () => {
    const fetchMock = mockApi({
      "GET /api/v1/products/": () => jsonResponse({
        results: [{
          id: "p1", name: "Shirt", sku: "SHIRT", base_unit: "PIECE", stock_quantity: "12.5", low_stock_threshold: "5",
          packs: [{ id: "pack1", retail_price_minor: 120000, wholesale_price_minor: 90000 }],
        }],
      }),
      "GET /api/v1/reports/stock/": () => jsonResponse({ results: [] }),
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<StockPage />, workspaceWithRole("CASHIER"));

    expect(await screen.findByText("Shirt")).toBeInTheDocument();
    expect(screen.getByRole("heading", { name: "Stock" })).toBeInTheDocument();
    expect(screen.getByText("₹1,200")).toBeInTheDocument();
    expect(screen.queryByText("₹900")).not.toBeInTheDocument();
    expect(screen.queryByText("Wholesale")).not.toBeInTheDocument();
    expect(screen.queryByText(/Weighted-average stock value/i)).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: /Import CSV/i })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: /Add product/i })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: /Transfer stock/i })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Adjust" })).not.toBeInTheDocument();
    expect(fetchMock.mock.calls.some(([input]) => String(input).includes("/api/v1/reports/valuation/"))).toBe(false);
  });

  it("keeps wholesale, weighted-average valuation and stock management controls for managers", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/products/": () => jsonResponse({
        results: [{
          id: "p1", name: "Shirt", sku: "SHIRT", base_unit: "PIECE", stock_quantity: "2", low_stock_threshold: "5",
          packs: [{ id: "pack1", retail_price_minor: 120000, wholesale_price_minor: 90000 }],
        }],
      }),
      "GET /api/v1/reports/stock/": () => jsonResponse({ results: [] }),
      "GET /api/v1/reports/valuation/": () => jsonResponse(valuationResponse),
    }));

    renderWithWorkspace(<StockPage />, workspaceWithRole("MANAGER"));

    expect(await screen.findByText("Shirt")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Add product/i })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Transfer stock/i })).toBeInTheDocument();
    expect(screen.getByText("Wholesale")).toBeInTheDocument();
    expect(screen.getByText("₹900")).toBeInTheDocument();
    expect(await screen.findByText("Weighted-average stock value")).toBeInTheDocument();
    expect(screen.getByText("₹250")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Import CSV" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Adjust" })).toBeInTheDocument();
  });
});
