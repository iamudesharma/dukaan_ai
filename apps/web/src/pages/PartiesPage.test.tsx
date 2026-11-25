import { afterEach, describe, expect, it, vi } from "vitest";
import { screen, within } from "@testing-library/react";
import { PartiesPage } from "./PartiesPage";
import { jsonResponse, mockApi, workspaceWithRole } from "../test/apiMocks";
import { renderWithWorkspace } from "../test/renderWorkspace";

afterEach(() => vi.unstubAllGlobals());

describe("PartiesPage", () => {
  it("renders receivable, payable and phone_e164 values returned by the API", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/parties/": () => jsonResponse({
        results: [{
          id: "party1",
          name: "Ramesh Traders",
          kind: "BOTH",
          phone_e164: "+919876543210",
          receivable_minor: 123400,
          payable_minor: 6800,
        }],
      }),
    }));

    renderWithWorkspace(<PartiesPage />);

    const heading = await screen.findByRole("heading", { name: "Ramesh Traders" });
    const card = heading.closest("article");
    expect(card).not.toBeNull();
    expect(within(card!).getByText("+919876543210")).toBeInTheDocument();
    expect(within(card!).getByText("₹1,234")).toBeInTheDocument();
    expect(within(card!).getByText("₹68")).toBeInTheDocument();
  });

  it("shows cashiers customers only and hides supplier balances and party management", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/parties/": () => jsonResponse({
        results: [
          { id: "customer", name: "Ramesh", kind: "CUSTOMER", receivable_minor: 123400, payable_minor: 0 },
          { id: "both", name: "Dual Role", kind: "BOTH", receivable_minor: 5000, payable_minor: 6800 },
          { id: "supplier", name: "Sharma Suppliers", kind: "SUPPLIER", receivable_minor: 0, payable_minor: 9000 },
        ],
      }),
    }));

    renderWithWorkspace(<PartiesPage />, workspaceWithRole("CASHIER"));

    expect(await screen.findByRole("heading", { name: "Ramesh" })).toBeInTheDocument();
    expect(screen.getByRole("heading", { name: "Customers" })).toBeInTheDocument();
    expect(screen.getByRole("heading", { name: "Dual Role" })).toBeInTheDocument();
    expect(screen.getAllByText("customer")).toHaveLength(2);
    expect(screen.queryByRole("heading", { name: "Sharma Suppliers" })).not.toBeInTheDocument();
    expect(screen.queryByText("You will pay")).not.toBeInTheDocument();
    expect(screen.queryByText("₹68")).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: /Add party/i })).not.toBeInTheDocument();
  });

  it("keeps supplier parties and balances available to managers", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/parties/": () => jsonResponse({
        results: [{ id: "supplier", name: "Sharma Suppliers", kind: "SUPPLIER", payable_minor: 9000 }],
      }),
    }));

    renderWithWorkspace(<PartiesPage />, workspaceWithRole("MANAGER"));

    expect(await screen.findByRole("heading", { name: "Sharma Suppliers" })).toBeInTheDocument();
    expect(screen.getAllByText("You will pay")).toHaveLength(2);
    expect(screen.getAllByText("₹90")).toHaveLength(2);
    expect(screen.getByRole("button", { name: /Add party/i })).toBeInTheDocument();
  });
});
