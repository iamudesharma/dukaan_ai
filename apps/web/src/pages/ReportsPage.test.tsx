import { afterEach, describe, expect, it, vi } from "vitest";
import { screen, within } from "@testing-library/react";
import { ReportsPage } from "./ReportsPage";
import { jsonResponse, mockApi, workspaceWithRole } from "../test/apiMocks";
import { renderWithWorkspace } from "../test/renderWorkspace";

afterEach(() => vi.unstubAllGlobals());

const valuation = {
  inventory: { total_quantity: "6", average_cost_minor: 10000, total_value_minor: 60000, known_value_minor: 60000, costing_complete: true },
  sales: { posted_sale_count: 1, line_count: 1, net_sales_minor: 80000, cogs_minor: 40000, gross_profit_minor: 40000, missing_cost_line_count: 0, costing_complete: true },
  results: [{ product_id: "p1", name: "Shirt", unit: "PIECE", quantity: "6", average_cost_minor: 10000, total_value_minor: 60000, known_value_minor: 60000, unknown_cost_quantity: "0", costing_complete: true }],
};

function handlers(overrides: Record<string, () => Promise<Response>> = {}) {
  return {
    "GET /api/v1/reports/valuation/": () => jsonResponse(valuation),
    "GET /api/v1/reports/stock/": () => jsonResponse({ results: [] }),
    "GET /api/v1/parties/": () => jsonResponse({ results: [] }),
    "GET /api/v1/payments/allocation-review/": () => jsonResponse({ results: [], totals: { payment_count: 0, payment_total_minor: 0, allocated_total_minor: 0, unallocated_total_minor: 0, outstanding_document_count: 0, outstanding_total_minor: 0 }, outstanding_documents: [] }),
    ...overrides,
  };
}

describe("ReportsPage valuation", () => {
  it("shows weighted-average stock value and gross profit for managers", async () => {
    const fetchMock = mockApi(handlers());
    vi.stubGlobal("fetch", fetchMock);
    renderWithWorkspace(<ReportsPage />, workspaceWithRole("MANAGER"));

    const profitSummary = await screen.findByRole("region", { name: "Selected period profit summary" });
    expect(within(profitSummary).getAllByText("₹400")).toHaveLength(2);
    const valuationSection = screen.getByRole("heading", { name: "Stock valuation & gross profit" }).closest("section")!;
    expect(within(valuationSection).getByText("Weighted-average cost")).toBeInTheDocument();
    expect(within(valuationSection).getAllByText("₹100")).toHaveLength(2);
    expect(within(valuationSection).getAllByText("₹600")).toHaveLength(2);
    expect(screen.getByRole("heading", { name: "Payment allocation review" })).toBeInTheDocument();
    expect(fetchMock.mock.calls.some(([input]) => String(input).includes("/api/v1/reports/valuation/"))).toBe(true);
  });

  it("does not fabricate gross profit when sale costing is incomplete", async () => {
    vi.stubGlobal("fetch", mockApi(handlers({
      "GET /api/v1/reports/valuation/": () => jsonResponse({
        ...valuation,
        sales: { ...valuation.sales, gross_profit_minor: null, missing_cost_line_count: 1, costing_complete: false },
      }),
    })));
    renderWithWorkspace(<ReportsPage />, workspaceWithRole("MANAGER"));

    expect(await screen.findByText("Gross profit is unavailable until every sold line in this period has a known cost.")).toBeInTheDocument();
    expect(screen.getAllByText("Not available").length).toBeGreaterThan(0);
  });

  it("does not query valuation, margins, or allocation data for a cashier", () => {
    const fetchMock = mockApi({});
    vi.stubGlobal("fetch", fetchMock);
    renderWithWorkspace(<ReportsPage />, workspaceWithRole("CASHIER"));
    expect(screen.getByRole("heading", { name: "Page not found" })).toBeInTheDocument();
    expect(fetchMock).not.toHaveBeenCalled();
  });
});
