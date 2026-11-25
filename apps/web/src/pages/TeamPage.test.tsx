import { afterEach, describe, expect, it, vi } from "vitest";
import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { TeamPage } from "./TeamPage";
import { jsonResponse, mockApi, requestBody, workspaceWithRole } from "../test/apiMocks";
import { renderWithWorkspace } from "../test/renderWorkspace";

afterEach(() => {
  vi.unstubAllGlobals();
  vi.restoreAllMocks();
});

const invitation = {
  id: "invite1", business: "b1", invitee_phone: "+919876543210", role: "CASHIER", locations: ["l1"],
  status: "PENDING", expires_at: "2026-12-01T10:00:00Z", inviter: "owner1",
};

describe("TeamPage invitations", () => {
  it("creates a phone-matched invitation and shows its one-time token for copying", async () => {
    const user = userEvent.setup();
    const writeText = vi.fn(async () => undefined);
    Object.defineProperty(navigator, "clipboard", { configurable: true, value: { writeText } });
    const fetchMock = mockApi({
      "GET /api/v1/memberships/": () => jsonResponse([]),
      "GET /api/v1/invitations/": () => jsonResponse([]),
      "POST /api/v1/invitations/": (init) => {
        expect(requestBody(init)).toEqual({ business: "b1", invitee_phone: "+919876543210", role: "CASHIER", locations: ["l1"] });
        return jsonResponse({ ...invitation, token: "one-time-invitation-token-long-enough" }, 201);
      },
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<TeamPage />);
    await user.click(screen.getByRole("button", { name: "Invite member" }));
    await user.type(screen.getByLabelText("Mobile number with country code"), "+919876543210");
    await user.click(screen.getByRole("button", { name: "Create invitation" }));

    const token = await screen.findByLabelText("One-time invitation token");
    expect(token).toHaveValue("one-time-invitation-token-long-enough");
    expect(screen.getByText(/shown only once/i)).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: "Copy token" }));
    expect(writeText).toHaveBeenCalledWith("one-time-invitation-token-long-enough");
    expect(await screen.findByRole("button", { name: "Token copied" })).toBeInTheDocument();
    expect(localStorage.getItem("dukaan_invitation_token")).toBeNull();
  });

  it("lists invitations without tokens and revokes a pending invitation", async () => {
    const user = userEvent.setup();
    vi.spyOn(window, "confirm").mockReturnValue(true);
    let revoked = false;
    const fetchMock = mockApi({
      "GET /api/v1/memberships/": () => jsonResponse([]),
      "GET /api/v1/invitations/": () => jsonResponse([{ ...invitation, status: revoked ? "REVOKED" : "PENDING" }]),
      "POST /api/v1/invitations/invite1/revoke/": () => { revoked = true; return jsonResponse({ ...invitation, status: "REVOKED" }); },
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<TeamPage />);
    const table = await screen.findByRole("table");
    expect(within(table).getByText("+919876543210")).toBeInTheDocument();
    expect(within(table).queryByDisplayValue(/token/i)).not.toBeInTheDocument();
    await user.click(within(table).getByRole("button", { name: "Revoke" }));

    await waitFor(() => expect(fetchMock.mock.calls.some(([input]) => String(input).endsWith("/api/v1/invitations/invite1/revoke/"))).toBe(true));
    expect(await screen.findByText("REVOKED")).toBeInTheDocument();
  });

  it.each(["MANAGER", "CASHIER"] as const)("blocks %s from team and invitation data", (role) => {
    const fetchMock = mockApi({});
    vi.stubGlobal("fetch", fetchMock);
    renderWithWorkspace(<TeamPage />, workspaceWithRole(role));
    expect(screen.getByRole("heading", { name: "Page not found" })).toBeInTheDocument();
    expect(fetchMock).not.toHaveBeenCalled();
  });
});
