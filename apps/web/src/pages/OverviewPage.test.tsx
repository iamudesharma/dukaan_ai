import { afterEach, describe, expect, it, vi } from "vitest";
import { screen, within } from "@testing-library/react";
import { OverviewPage } from "./OverviewPage";
import { jsonResponse, mockApi, workspaceWithRole } from "../test/apiMocks";
import { renderWithWorkspace } from "../test/renderWorkspace";

afterEach(() => vi.unstubAllGlobals());

describe("OverviewPage", () => {
  it("renders explicit minor-unit dashboard values and a nullable profit state", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/reports/dashboard/": () => jsonResponse({
        as_of: "2026-11-24T10:00:00Z",
        today: { sales_minor: 123400, expenses_minor: 25000 },
        books: { receipts_minor: 100000, receivable_minor: 50000, payable_minor: 30000, cash_flow_minor: -12345 },
        low_stock_count: 7,
        gross_profit_minor: null,
        summary: "Today's posted figures are ready.",
      }),
      "GET /api/v1/reports/valuation/": () => jsonResponse({
        inventory: { costing_complete: true, total_value_minor: 0, known_value_minor: 0, average_cost_minor: null, total_quantity: "0" },
        sales: { posted_sale_count: 1, line_count: 1, net_sales_minor: 123400, cogs_minor: 0, gross_profit_minor: null, missing_cost_line_count: 1, costing_complete: false },
        results: [],
      }),
      "GET /api/v1/sales/": () => jsonResponse([]),
      "GET /api/v1/purchases/": () => jsonResponse([]),
      "GET /api/v1/payments/": () => jsonResponse([]),
      "GET /api/v1/expenses/": () => jsonResponse([]),
      "GET /api/v1/products/": () => jsonResponse([]),
      "GET /api/v1/parties/": () => jsonResponse([]),
    }));

    renderWithWorkspace(<OverviewPage />);

    expect(await screen.findByText("Today's posted figures are ready.")).toBeInTheDocument();
    expect(screen.getByText("₹1,234")).toBeInTheDocument();
    expect(screen.getByText("₹1,000")).toBeInTheDocument();
    expect(screen.getByText("Not available")).toBeInTheDocument();
    expect(screen.getByText("Gross profit is unavailable until every sold line has a known cost.")).toBeInTheDocument();
    expect(screen.getByText("Net cash flow")).toBeInTheDocument();
    expect(screen.getByText(/₹123/)).toBeInTheDocument();
    expect(screen.getByText("7")).toBeInTheDocument();
  });

  it("uses the valuation endpoint for today’s weighted-average gross profit", async () => {
    const fetchMock = mockApi({
      "GET /api/v1/reports/dashboard/": () => jsonResponse({ as_of: "2026-11-24", today: { sales_minor: 80000, expenses_minor: 0 }, books: {}, gross_profit_minor: null, summary: "Posted figures." }),
      "GET /api/v1/reports/valuation/": () => jsonResponse({
        inventory: { costing_complete: true, total_value_minor: 60000, known_value_minor: 60000, average_cost_minor: 10000, total_quantity: "6" },
        sales: { posted_sale_count: 1, line_count: 1, net_sales_minor: 80000, cogs_minor: 40000, gross_profit_minor: 40000, missing_cost_line_count: 0, costing_complete: true },
        results: [],
      }),
      "GET /api/v1/sales/": () => jsonResponse([]),
      "GET /api/v1/purchases/": () => jsonResponse([]),
      "GET /api/v1/payments/": () => jsonResponse([]),
      "GET /api/v1/expenses/": () => jsonResponse([]),
      "GET /api/v1/products/": () => jsonResponse([]),
      "GET /api/v1/parties/": () => jsonResponse([]),
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<OverviewPage />);
    expect(await screen.findByText("Gross profit today")).toBeInTheDocument();
    expect(screen.getByText("₹400")).toBeInTheDocument();
    expect(screen.getByText("Based on weighted-average cost of today’s posted sales.")).toBeInTheDocument();
    expect(fetchMock.mock.calls.find(([input]) => String(input).includes("/api/v1/reports/valuation/"))?.[0]).toContain("date_from=");
  });

  it("builds a cashier-safe overview without requesting manager reports", async () => {
    const fetchMock = mockApi({
      "GET /api/v1/sales/": () => jsonResponse([{
        id: "s1", number: "S-1", status: "POSTED", customer: { name: "Ramesh" },
        grand_total_minor: 123400, due_total_minor: 20000, posted_at: new Date().toISOString(),
      }]),
      "GET /api/v1/payments/": () => jsonResponse([{
        id: "payment1", reference: "R-1", status: "POSTED", direction: "RECEIPT",
        party: { name: "Ramesh" }, amount_minor: 5000, payment_date: new Date().toISOString(),
      }]),
      "GET /api/v1/products/": () => jsonResponse({
        results: [{
          id: "p1", name: "Shirt", sku: "SHIRT", base_unit: "PIECE", stock_quantity: "2", low_stock_threshold: "5",
          packs: [{ id: "pack1", retail_price_minor: 120000, wholesale_price_minor: 90000 }],
        }],
      }),
      "GET /api/v1/parties/": () => jsonResponse({
        results: [
          { id: "customer", name: "Ramesh", kind: "CUSTOMER", receivable_minor: 50000, payable_minor: 0 },
          { id: "vendor", name: "Sharma Suppliers", kind: "SUPPLIER", receivable_minor: 0, payable_minor: 30000 },
        ],
      }),
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<OverviewPage />, workspaceWithRole("CASHIER"));

    expect(await screen.findByText("Today’s sales, collections and customer outstanding for this location.")).toBeInTheDocument();
    expect(within(screen.getByText("Sales").closest("article")!).getByText("₹1,234")).toBeInTheDocument();
    expect(within(screen.getByText("Collected").closest("article")!).getByText("₹50")).toBeInTheDocument();
    expect(within(screen.getByText("You will receive").closest("article")!).getByText("₹500")).toBeInTheDocument();
    expect(screen.getByText("1 products are low on stock")).toBeInTheDocument();
    expect(screen.queryByText("You will pay")).not.toBeInTheDocument();
    expect(screen.queryByText("Gross profit today")).not.toBeInTheDocument();
    expect(screen.queryByText("Expenses today")).not.toBeInTheDocument();
    expect(screen.queryByText("Net cash flow")).not.toBeInTheDocument();
    expect(screen.queryByText(/to pay suppliers/i)).not.toBeInTheDocument();
    expect(fetchMock.mock.calls.some(([input]) => String(input).includes("/api/v1/reports/dashboard/"))).toBe(false);
    expect(fetchMock.mock.calls.some(([input]) => String(input).includes("/api/v1/reports/valuation/"))).toBe(false);
    expect(fetchMock.mock.calls.some(([input]) => String(input).includes("/api/v1/purchases/"))).toBe(false);
    expect(fetchMock.mock.calls.some(([input]) => String(input).includes("/api/v1/expenses/"))).toBe(false);
  });
});
