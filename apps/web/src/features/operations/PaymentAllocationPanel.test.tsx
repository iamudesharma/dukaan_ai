import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { PaymentAllocationPanel } from "./PaymentAllocationPanel";
import { TestProviders } from "../../test/TestProviders";
import { jsonResponse, mockApi, requestBody } from "../../test/apiMocks";

afterEach(() => vi.unstubAllGlobals());

const payment = {
  id: "payment1", business: "b1", location: "l1", party: "party1", direction: "RECEIPT", method: "CASH",
  amount_minor: 15000, reference: "R-1", payment_date: "2026-11-24", status: "POSTED",
  allocated_total_minor: 15000, unallocated_total_minor: 0,
  allocations: [{ id: "a1", sale: "sale1", amount_minor: 15000, document_type: "SALE", document_id: "sale1", document_number: "S-1", document_total_minor: 30000, document_paid_total_minor: 15000, document_due_total_minor: 15000 }],
};
const review = {
  results: [payment],
  totals: { payment_count: 1, payment_total_minor: 15000, allocated_total_minor: 15000, unallocated_total_minor: 0, outstanding_document_count: 2, outstanding_total_minor: 45000 },
  outstanding_documents: [
    { document_type: "SALE", document_id: "sale1", number: "S-1", document_date: "2026-11-20", party_id: "party1", party_name: "Ramesh", grand_total_minor: 30000, paid_total_minor: 15000, due_total_minor: 15000 },
    { document_type: "SALE", document_id: "sale2", number: "S-2", document_date: "2026-11-21", party_id: "party1", party_name: "Ramesh", grand_total_minor: 30000, paid_total_minor: 0, due_total_minor: 30000 },
  ],
};

describe("PaymentAllocationPanel", () => {
  it("requires a reviewed full allocation and reason before an idempotent reallocation", async () => {
    const user = userEvent.setup();
    const fetchMock = mockApi({
      "GET /api/v1/parties/": () => jsonResponse({ results: [{ id: "party1", name: "Ramesh", kind: "CUSTOMER" }] }),
      "GET /api/v1/payments/allocation-review/": () => jsonResponse(review),
      "POST /api/v1/payments/payment1/reallocate/": (init) => {
        expect(new Headers(init?.headers).get("idempotency-key")).toBeTruthy();
        expect(requestBody(init)).toMatchObject({
          reason: "Correct invoice allocation",
          allocations: [
            { document_type: "SALE", document_id: "sale1", amount_minor: 10000 },
            { document_type: "SALE", document_id: "sale2", amount_minor: 5000 },
          ],
        });
        expect(requestBody(init).idempotency_key).toBe(new Headers(init?.headers).get("idempotency-key"));
        return jsonResponse({ ...payment, allocations: [], allocated_total_minor: 15000, unallocated_total_minor: 0 });
      },
    });
    vi.stubGlobal("fetch", fetchMock);

    render(<TestProviders><PaymentAllocationPanel businessId="b1" locationId="l1" canReview /></TestProviders>);
    await user.click(await screen.findByRole("button", { name: "Review" }));
    const dialog = screen.getByRole("dialog");
    const confirmButton = within(dialog).getByRole("button", { name: "Confirm reallocation" });
    expect(confirmButton).toBeDisabled();

    const amounts = within(dialog).getAllByLabelText("Amount (₹)");
    await user.clear(amounts[0]);
    await user.type(amounts[0], "100");
    await user.click(within(dialog).getByRole("button", { name: "Add document" }));
    await user.selectOptions(within(dialog).getAllByLabelText("Document")[1], "sale2");
    const nextAmounts = within(dialog).getAllByLabelText("Amount (₹)");
    await user.type(nextAmounts[1], "50");
    await user.type(within(dialog).getByLabelText("Reason"), "Correct invoice allocation");
    expect(confirmButton).toBeEnabled();
    expect(fetchMock.mock.calls.some(([input]) => String(input).endsWith("/reallocate/"))).toBe(false);

    await user.click(confirmButton);
    expect(await screen.findByText(/reallocated/)).toBeInTheDocument();
    await waitFor(() => expect(fetchMock.mock.calls.some(([input]) => String(input).endsWith("/api/v1/payments/payment1/reallocate/"))).toBe(true));
  });

  it("does not load allocation or supplier data for a cashier", () => {
    const fetchMock = mockApi({});
    vi.stubGlobal("fetch", fetchMock);
    render(<TestProviders><PaymentAllocationPanel businessId="b1" locationId="l1" canReview={false} /></TestProviders>);
    expect(screen.queryByRole("heading", { name: "Payment allocation review" })).not.toBeInTheDocument();
    expect(fetchMock).not.toHaveBeenCalled();
  });
});
