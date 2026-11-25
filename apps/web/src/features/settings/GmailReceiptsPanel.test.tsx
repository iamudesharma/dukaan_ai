import { afterEach, describe, expect, it, vi } from "vitest";
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { GmailReceiptsPanel } from "./GmailReceiptsPanel";
import { TestProviders } from "../../test/TestProviders";
import { jsonResponse, mockApi, requestBody } from "../../test/apiMocks";
import { render } from "@testing-library/react";

afterEach(() => {
  vi.unstubAllGlobals();
  vi.restoreAllMocks();
});

describe("GmailReceiptsPanel", () => {
  it("shows connection, recent messages and an extracted review preview", async () => {
    const user = userEvent.setup();
    const fetchMock = mockApi({
      "GET /api/v1/integrations/gmail/status/": () => jsonResponse({ connected: true, email: "shop@example.com" }),
      "GET /api/v1/integrations/gmail/messages/": () => jsonResponse({
        results: [{ id: "m1", subject: "Invoice 42", snippet: "Payment receipt for fabric", received_at: "2026-11-24T09:00:00Z" }],
      }),
      "POST /api/v1/integrations/gmail/import/": () => jsonResponse({
        import_id: "import1",
        status: "READY_FOR_REVIEW",
        extracted: { kind: "SALE", direction: "INCOMING", party_name: "Ramesh", amount_minor: 120000, reference: "INV-42", confidence: 0.92 },
        preview: "Sale receipt from Ramesh",
      }),
    });
    vi.stubGlobal("fetch", fetchMock);

    render(<TestProviders><GmailReceiptsPanel businessId="b1" locationId="l1" canUseGmail /></TestProviders>);

    expect(await screen.findByText("shop@example.com")).toBeInTheDocument();
    expect(await screen.findByRole("heading", { name: "Invoice 42" })).toBeInTheDocument();
    expect(screen.getByText(/Importing never posts to your books/)).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: "Import for review" }));

    expect(await screen.findByText("Extracted for review")).toBeInTheDocument();
    expect(screen.getByText("Not posted")).toBeInTheDocument();
    expect(screen.getByText("Sale · Incoming")).toBeInTheDocument();
    expect(screen.getByText("Ramesh")).toBeInTheDocument();
    expect(screen.getByText("₹1,200")).toBeInTheDocument();
    expect(screen.getByText("Sale receipt from Ramesh")).toBeInTheDocument();
    const importCall = fetchMock.mock.calls.find(([input]) => String(input).endsWith("/api/v1/integrations/gmail/import/"));
    expect(requestBody(importCall?.[1])).toEqual({ message_id: "m1", business_id: "b1", location_id: "l1" });
  });

  it("opens the backend authorization URL in a new tab when connecting", async () => {
    const user = userEvent.setup();
    const open = vi.fn(() => null);
    vi.stubGlobal("open", open);
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/integrations/gmail/status/": () => jsonResponse({ connected: false }),
      "GET /api/v1/integrations/gmail/connect/": () => jsonResponse({ authorization_url: "https://accounts.google.com/o/oauth?shop=1" }),
    }));

    render(<TestProviders><GmailReceiptsPanel businessId="b1" locationId="l1" canUseGmail /></TestProviders>);

    await user.click(await screen.findByRole("button", { name: "Connect Gmail" }));
    await waitFor(() => expect(open).toHaveBeenCalledWith("https://accounts.google.com/o/oauth?shop=1", "_blank", "noopener,noreferrer"));
  });

  it("does not render or load Gmail without owner/manager access", () => {
    const fetchMock = mockApi({});
    vi.stubGlobal("fetch", fetchMock);

    render(<TestProviders><GmailReceiptsPanel businessId="b1" locationId="l1" /></TestProviders>);

    expect(screen.queryByRole("heading", { name: "Gmail receipts" })).not.toBeInTheDocument();
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("shows a useful error when recent messages cannot load", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/integrations/gmail/status/": () => jsonResponse({ connected: true, email: "shop@example.com" }),
      "GET /api/v1/integrations/gmail/messages/": () => jsonResponse({ message: "Gmail unavailable" }, 500),
    }));

    render(<TestProviders><GmailReceiptsPanel businessId="b1" locationId="l1" canUseGmail /></TestProviders>);

    expect(await screen.findByText("Could not load recent messages. Check your connection and try again.")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Try again" })).toBeInTheDocument();
  });
});
