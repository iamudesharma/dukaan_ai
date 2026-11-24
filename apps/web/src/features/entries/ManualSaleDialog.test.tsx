import { afterEach, describe, expect, it, vi } from "vitest";
import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { ManualSaleDialog } from "./ManualSaleDialog";
import { jsonResponse, mockApi, workspaceWithRole } from "../../test/apiMocks";
import { renderWithWorkspace } from "../../test/renderWorkspace";

afterEach(() => vi.unstubAllGlobals());

const productsResponse = {
  results: [{
    id: "p1", name: "Shirt", sku: "SHIRT", base_unit: "PIECE", stock_quantity: "12.5", low_stock_threshold: "5",
    packs: [{ id: "pack1", retail_price_minor: 120000, wholesale_price_minor: 90000 }],
  }],
};

const partiesResponse = {
  results: [
    { id: "customer", name: "Ramesh", kind: "CUSTOMER" },
    { id: "supplier", name: "Sharma Suppliers", kind: "SUPPLIER" },
  ],
};

describe("ManualSaleDialog role controls", () => {
  it("keeps cashier sales retail-only and excludes suppliers", async () => {
    const user = userEvent.setup();
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/products/": () => jsonResponse(productsResponse),
      "GET /api/v1/parties/": () => jsonResponse(partiesResponse),
    }));

    renderWithWorkspace(<ManualSaleDialog open onClose={vi.fn()} />, workspaceWithRole("CASHIER"));

    await screen.findByRole("option", { name: /Shirt/ });
    expect(screen.queryByRole("button", { name: "Wholesale" })).not.toBeInTheDocument();
    expect(screen.queryByRole("option", { name: "Sharma Suppliers" })).not.toBeInTheDocument();
    await user.selectOptions(screen.getByLabelText("Product"), "p1");
    await screen.findByRole("option", { name: "Ramesh" });
    await user.selectOptions(screen.getByLabelText(/Customer/), "customer");
    expect(screen.getByLabelText("Unit price")).toHaveValue(1200);
    expect(screen.getByRole("button", { name: "Review sale" })).toBeEnabled();
  });

  it("keeps wholesale sale pricing available to managers", async () => {
    const user = userEvent.setup();
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/products/": () => jsonResponse(productsResponse),
      "GET /api/v1/parties/": () => jsonResponse(partiesResponse),
    }));

    renderWithWorkspace(<ManualSaleDialog open onClose={vi.fn()} />, workspaceWithRole("MANAGER"));

    await screen.findByRole("option", { name: /Shirt/ });
    await user.selectOptions(screen.getByLabelText("Product"), "p1");
    await user.click(screen.getByRole("button", { name: "Wholesale" }));
    expect(screen.getByLabelText("Unit price")).toHaveValue(900);
  });
});
