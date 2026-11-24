import { afterEach, describe, expect, it, vi } from "vitest";
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { EntriesPage } from "./EntriesPage";
import { jsonResponse, mockApi, workspaceWithRole } from "../test/apiMocks";
import { renderWithWorkspace } from "../test/renderWorkspace";

afterEach(() => {
  vi.unstubAllGlobals();
  vi.restoreAllMocks();
});

const sale = {
  id: "s1",
  number: "S-1",
  status: "POSTED",
  customer: { name: "Ramesh" },
  grand_total_minor: 120000,
  due_total_minor: 0,
  posted_at: "2026-11-24T10:00:00Z",
};

describe("EntriesPage role controls", () => {
  it("keeps cashier sales and receipts usable without purchase, expense or reversal controls", async () => {
    const fetchMock = mockApi({
      "GET /api/v1/sales/": () => jsonResponse([sale]),
      "GET /api/v1/payments/": () => jsonResponse([]),
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<EntriesPage />, workspaceWithRole("CASHIER"));

    expect(await screen.findByText("S-1")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Manual sale/i })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Customer payment/i })).toBeInTheDocument();
    expect(screen.getByRole("tab", { name: "Sales" })).toBeInTheDocument();
    expect(screen.getByRole("tab", { name: "Payments in" })).toBeInTheDocument();
    expect(screen.queryByRole("tab", { name: "Purchases" })).not.toBeInTheDocument();
    expect(screen.queryByRole("tab", { name: "Payments out" })).not.toBeInTheDocument();
    expect(screen.queryByRole("tab", { name: "Expenses" })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: /^Purchase$/i })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: /^Expense$/i })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: /Export/i })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Reverse" })).not.toBeInTheDocument();
    expect(fetchMock.mock.calls.some(([input]) => String(input).includes("/api/v1/purchases/"))).toBe(false);
    expect(fetchMock.mock.calls.some(([input]) => String(input).includes("/api/v1/expenses/"))).toBe(false);
  });

  it("lets a cashier download a sale invoice PDF without exposing management controls", async () => {
    const user = userEvent.setup();
    const createObjectURL = vi.fn(() => "blob:invoice-1");
    const revokeObjectURL = vi.fn();
    const originalCreate = URL.createObjectURL;
    const originalRevoke = URL.revokeObjectURL;
    URL.createObjectURL = createObjectURL;
    URL.revokeObjectURL = revokeObjectURL;
    vi.spyOn(HTMLAnchorElement.prototype, "click").mockImplementation(() => undefined);
    const fetchMock = mockApi({
      "GET /api/v1/sales/": () => jsonResponse([sale]),
      "GET /api/v1/payments/": () => jsonResponse([]),
      "GET /api/v1/invoices/sales/s1/pdf/": () => Promise.resolve(new Response("%PDF-1.7", { headers: { "Content-Type": "application/pdf", "Content-Disposition": 'attachment; filename="S-1.pdf"' } })),
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<EntriesPage />, workspaceWithRole("CASHIER"));
    await user.click(await screen.findByRole("button", { name: "Download invoice PDF for S-1" }));

    await waitFor(() => expect(createObjectURL).toHaveBeenCalled());
    expect(revokeObjectURL).toHaveBeenCalledWith("blob:invoice-1");
    expect(screen.queryByRole("button", { name: "Reverse" })).not.toBeInTheDocument();
    URL.createObjectURL = originalCreate;
    URL.revokeObjectURL = originalRevoke;
  });

  it("keeps purchase, expense, export and reversal controls for managers", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/sales/": () => jsonResponse([sale]),
      "GET /api/v1/purchases/": () => jsonResponse([]),
      "GET /api/v1/payments/": () => jsonResponse([]),
      "GET /api/v1/expenses/": () => jsonResponse([]),
    }));

    renderWithWorkspace(<EntriesPage />, workspaceWithRole("MANAGER"));

    expect(await screen.findByText("S-1")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /^Purchase$/i })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /^Expense$/i })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /^Payment$/i })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Export/i })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Reverse" })).toBeInTheDocument();
  });
});
