import { afterEach, describe, expect, it, vi } from "vitest";
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { QuickEntryDialog } from "./QuickEntryDialog";
import { jsonResponse, mockApi, requestBody, workspaceWithRole } from "../../test/apiMocks";
import { renderWithWorkspace } from "../../test/renderWorkspace";

afterEach(() => vi.unstubAllGlobals());

const partiesResponse = {
  results: [
    { id: "c1", name: "Ramesh", kind: "CUSTOMER" },
    { id: "c2", name: "Paid Customer", kind: "CUSTOMER" },
    { id: "v1", name: "Sharma Suppliers", kind: "SUPPLIER" },
  ],
};

const salesResponse = [
  { id: "s1", number: "S-1", status: "POSTED", customer_id: "c1", grand_total_minor: 10000, due_total_minor: 2500 },
  { id: "s2", number: "S-2", status: "POSTED", customer_id: "c2", grand_total_minor: 10000, due_total_minor: 0 },
  { id: "s3", number: "S-3", status: "POSTED", customer_id: "c1", grand_total_minor: 10000, due_total_minor: 0 },
];

describe("QuickEntryDialog payments", () => {
  it("does not open purchase or expense forms for cashiers", async () => {
    const onClose = vi.fn();
    const fetchMock = mockApi({});
    vi.stubGlobal("fetch", fetchMock);

    const { unmount } = renderWithWorkspace(
      <QuickEntryDialog kind="purchase" onClose={onClose} />,
      workspaceWithRole("CASHIER"),
    );
    await waitFor(() => expect(onClose).toHaveBeenCalled());
    unmount();

    renderWithWorkspace(<QuickEntryDialog kind="expense" onClose={onClose} />, workspaceWithRole("CASHIER"));
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("requires an outstanding sale and sends sale_id for a receipt", async () => {
    const user = userEvent.setup();
    const fetchMock = mockApi({
      "GET /api/v1/parties/": () => jsonResponse(partiesResponse),
      "GET /api/v1/sales/": () => jsonResponse(salesResponse),
      "POST /api/v1/payments/": () => jsonResponse({ id: "payment1" }, 201),
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<QuickEntryDialog kind="payment" onClose={vi.fn()} />);

    const recordButton = screen.getByRole("button", { name: "Record payment" });
    expect(recordButton).toBeDisabled();
    await screen.findByRole("option", { name: "Ramesh" });
    await user.selectOptions(screen.getByLabelText("Party"), "c1");
    const documentSelect = await screen.findByLabelText("Outstanding sale") as HTMLSelectElement;
    expect(withinDocumentOptions(documentSelect)).toEqual(["Select an outstanding sale", "S-1 · ₹25 outstanding"]);
    expect(recordButton).toBeDisabled();

    await user.selectOptions(documentSelect, "s1");
    await user.type(screen.getByLabelText("Amount (₹)"), "25");
    await user.click(recordButton);

    expect(await screen.findByText("Recorded successfully.")).toBeInTheDocument();
    const paymentCall = fetchMock.mock.calls.find(([input]) => String(input).endsWith("/api/v1/payments/"));
    expect(requestBody(paymentCall?.[1])).toMatchObject({
      party_id: "c1",
      direction: "RECEIPT",
      sale_id: "s1",
      amount_minor: 2500,
    });
    expect(requestBody(paymentCall?.[1])).not.toHaveProperty("purchase_id");
  });

  it("limits cashier payments to customer receipts", async () => {
    const user = userEvent.setup();
    const fetchMock = mockApi({
      "GET /api/v1/parties/": () => jsonResponse(partiesResponse),
      "GET /api/v1/sales/": () => jsonResponse(salesResponse),
      "POST /api/v1/payments/": () => jsonResponse({ id: "payment1" }, 201),
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<QuickEntryDialog kind="payment" onClose={vi.fn()} />, workspaceWithRole("CASHIER"));

    expect(screen.getByRole("heading", { name: "Record a receipt" })).toBeInTheDocument();
    expect(screen.queryByLabelText("Direction")).not.toBeInTheDocument();
    expect(screen.queryByRole("option", { name: "Sharma Suppliers" })).not.toBeInTheDocument();
    await screen.findByRole("option", { name: "Ramesh" });
    await user.selectOptions(screen.getByLabelText("Party"), "c1");
    await user.selectOptions(await screen.findByLabelText("Outstanding sale"), "s1");
    await user.type(screen.getByLabelText("Amount (₹)"), "25");
    await user.click(screen.getByRole("button", { name: "Record receipt" }));

    expect(await screen.findByText("Recorded successfully.")).toBeInTheDocument();
    const paymentCall = fetchMock.mock.calls.find(([input]) => String(input).endsWith("/api/v1/payments/"));
    expect(requestBody(paymentCall?.[1])).toMatchObject({ direction: "RECEIPT", sale_id: "s1" });
    expect(fetchMock.mock.calls.some(([input]) => String(input).includes("/api/v1/purchases/"))).toBe(false);
  });

  it("loads purchases for the payment direction and sends purchase_id", async () => {
    const user = userEvent.setup();
    const fetchMock = mockApi({
      "GET /api/v1/parties/": () => jsonResponse(partiesResponse),
      "GET /api/v1/sales/": () => jsonResponse([]),
      "GET /api/v1/purchases/": () => jsonResponse([
        { id: "p1", number: "P-1", status: "POSTED", supplier_id: "v1", grand_total_minor: 20000, due_total_minor: 5000 },
      ]),
      "POST /api/v1/payments/": () => jsonResponse({ id: "payment2" }, 201),
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<QuickEntryDialog kind="payment" onClose={vi.fn()} />);

    await screen.findByRole("option", { name: "Sharma Suppliers" });
    await user.selectOptions(screen.getByLabelText("Party"), "v1");
    await user.selectOptions(screen.getByLabelText("Direction"), "PAYMENT");
    const documentSelect = await screen.findByLabelText("Outstanding purchase");
    await user.selectOptions(documentSelect, "p1");
    await user.type(screen.getByLabelText("Amount (₹)"), "50");
    await user.click(screen.getByRole("button", { name: "Record payment" }));

    expect(await screen.findByText("Recorded successfully.")).toBeInTheDocument();
    const paymentCall = fetchMock.mock.calls.find(([input]) => String(input).endsWith("/api/v1/payments/"));
    expect(requestBody(paymentCall?.[1])).toMatchObject({
      party_id: "v1",
      direction: "PAYMENT",
      purchase_id: "p1",
      amount_minor: 5000,
    });
    expect(requestBody(paymentCall?.[1])).not.toHaveProperty("sale_id");
  });

  it("shows a meaningful empty state when the party has no outstanding sale", async () => {
    const user = userEvent.setup();
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/parties/": () => jsonResponse(partiesResponse),
      "GET /api/v1/sales/": () => jsonResponse(salesResponse),
    }));

    renderWithWorkspace(<QuickEntryDialog kind="payment" onClose={vi.fn()} />);

    await screen.findByRole("option", { name: "Paid Customer" });
    await user.selectOptions(screen.getByLabelText("Party"), "c2");
    expect(await screen.findByText("No outstanding sales for this party at this location.")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Record payment" })).toBeDisabled();
  });

  it("shows an error and retry action when outstanding documents cannot load", async () => {
    const user = userEvent.setup();
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/parties/": () => jsonResponse(partiesResponse),
      "GET /api/v1/sales/": () => jsonResponse({ message: "Sales unavailable" }, 500),
    }));

    renderWithWorkspace(<QuickEntryDialog kind="payment" onClose={vi.fn()} />);

    await screen.findByRole("option", { name: "Ramesh" });
    await user.selectOptions(screen.getByLabelText("Party"), "c1");
    expect(await screen.findByText("Could not load outstanding sales. Check your connection and try again.")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Try again" })).toBeInTheDocument();
    await waitFor(() => expect(screen.getByRole("button", { name: "Record payment" })).toBeDisabled());
  });
});

function withinDocumentOptions(select: HTMLSelectElement): string[] {
  return Array.from(select.options, (option) => option.textContent ?? "");
}
