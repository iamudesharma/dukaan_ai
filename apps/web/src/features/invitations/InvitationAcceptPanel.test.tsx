import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { InvitationAcceptPanel } from "./InvitationAcceptPanel";
import { TestProviders } from "../../test/TestProviders";
import { jsonResponse, mockApi, requestBody } from "../../test/apiMocks";

afterEach(() => vi.unstubAllGlobals());

describe("InvitationAcceptPanel", () => {
  it("accepts only by token and explains the backend phone match", async () => {
    const user = userEvent.setup();
    const onAccepted = vi.fn(async () => undefined);
    const fetchMock = mockApi({
      "POST /api/v1/invitations/accept/": (init) => {
        expect(requestBody(init)).toEqual({ token: "one-time-invitation-token-long-enough" });
        return jsonResponse({ id: "invite1", business: "b1", invitee_phone: "+919876543210", role: "MANAGER", locations: ["l1"], status: "ACCEPTED", expires_at: "2026-12-01T10:00:00Z", inviter: "owner1" });
      },
    });
    vi.stubGlobal("fetch", fetchMock);

    render(<TestProviders><InvitationAcceptPanel onAccepted={onAccepted} /></TestProviders>);
    expect(screen.getByText(/backend checks that verified phone/i)).toBeInTheDocument();
    await user.type(screen.getByLabelText("Invitation token"), "one-time-invitation-token-long-enough");
    await user.click(screen.getByRole("button", { name: "Accept invitation" }));

    expect(await screen.findByText(/manager access to the business/i)).toBeInTheDocument();
    expect(onAccepted).toHaveBeenCalledTimes(1);
    expect(screen.getByLabelText("Invitation token")).toHaveValue("");
  });

  it("surfaces invalid, expired, or phone-mismatched invitation errors", async () => {
    const user = userEvent.setup();
    vi.stubGlobal("fetch", mockApi({
      "POST /api/v1/invitations/accept/": () => jsonResponse({ detail: "Invalid, expired, or unavailable invitation." }, 400),
    }));
    render(<TestProviders><InvitationAcceptPanel /></TestProviders>);
    await user.type(screen.getByLabelText("Invitation token"), "one-time-invitation-token-long-enough");
    await user.click(screen.getByRole("button", { name: "Accept invitation" }));
    expect(await screen.findByRole("alert")).toHaveTextContent("Invalid, expired, or unavailable invitation.");
  });
});
