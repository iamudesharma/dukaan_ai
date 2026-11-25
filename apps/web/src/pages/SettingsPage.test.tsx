import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { SettingsPage } from "./SettingsPage";
import { jsonResponse, mockApi, requestBody, workspaceWithRole } from "../test/apiMocks";
import { renderWithWorkspace } from "../test/renderWorkspace";

beforeEach(() => localStorage.clear());
afterEach(() => {
  vi.unstubAllGlobals();
  vi.restoreAllMocks();
});

describe("SettingsPage", () => {
  it("continues to save the business profile with PATCH", async () => {
    const user = userEvent.setup();
    const fetchMock = mockApi({
      "GET /api/v1/gst-registrations/": () => jsonResponse([]),
      "GET /api/v1/integrations/gmail/status/": () => jsonResponse({ connected: false }),
      "GET /api/v1/integrations/notifications/devices/": () => jsonResponse([]),
      "GET /api/v1/integrations/notifications/reminders/": () => jsonResponse([]),
      "PATCH /api/v1/businesses/b1/": () => jsonResponse({ id: "b1", name: "Gupta Traders Updated", legal_name: "Gupta Traders" }),
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<SettingsPage />);

    const name = screen.getByLabelText("Display name");
    await user.clear(name);
    await user.type(name, "Gupta Traders Updated");
    await user.click(screen.getByRole("button", { name: "Save settings" }));

    await waitFor(() => expect(screen.getByText("Settings saved")).toBeInTheDocument());
    const patchCall = fetchMock.mock.calls.find(([input]) => String(input).endsWith("/api/v1/businesses/b1/"));
    expect(patchCall?.[1]?.method).toBe("PATCH");
    expect(requestBody(patchCall?.[1])).toEqual({ name: "Gupta Traders Updated", legal_name: "Gupta Traders" });
  });

  it("shows managers Gmail and security settings with owner-only fields disabled", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/gst-registrations/": () => jsonResponse([]),
      "GET /api/v1/integrations/gmail/status/": () => jsonResponse({ connected: false }),
      "GET /api/v1/integrations/notifications/devices/": () => jsonResponse([]),
      "GET /api/v1/integrations/notifications/reminders/": () => jsonResponse([]),
    }));

    renderWithWorkspace(<SettingsPage />, workspaceWithRole("MANAGER"));

    expect(await screen.findByRole("heading", { name: "Gmail receipts" })).toBeInTheDocument();
    expect(screen.getByLabelText("Display name")).toHaveAttribute("readonly");
    expect(screen.getByLabelText("GSTIN")).toHaveAttribute("readonly");
    expect(screen.queryByRole("button", { name: "Save settings" })).not.toBeInTheDocument();
    expect(screen.getByText(/Only the owner can change business profile/i)).toBeInTheDocument();
  });

  it("does not load settings or Gmail data for a cashier", () => {
    const fetchMock = mockApi({});
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<SettingsPage />, workspaceWithRole("CASHIER"));

    expect(screen.getByRole("heading", { name: "Page not found" })).toBeInTheDocument();
    expect(screen.queryByRole("heading", { name: "Gmail receipts" })).not.toBeInTheDocument();
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("requires the current password and clears local tokens after all sessions are revoked", async () => {
    const user = userEvent.setup();
    const replace = vi.fn();
    vi.stubGlobal("location", { ...window.location, replace });
    vi.spyOn(window, "confirm").mockReturnValue(true);
    localStorage.setItem("dukaan_access_token", "access");
    localStorage.setItem("dukaan_refresh_token", "refresh");
    const fetchMock = mockApi({
      "GET /api/v1/gst-registrations/": () => jsonResponse([]),
      "GET /api/v1/integrations/gmail/status/": () => jsonResponse({ connected: false }),
      "GET /api/v1/integrations/notifications/devices/": () => jsonResponse([]),
      "GET /api/v1/integrations/notifications/reminders/": () => jsonResponse([]),
      "POST /api/v1/auth/sessions/revoke-all/": (init) => {
        expect(requestBody(init)).toEqual({ password: "CurrentPass123!" });
        return jsonResponse({ detail: "All sessions have been revoked.", token_version: 2 });
      },
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<SettingsPage />);
    const revokeButton = screen.getByRole("button", { name: "Revoke all sessions" });
    expect(revokeButton).toBeDisabled();
    await user.type(screen.getByLabelText("Current password to revoke sessions"), "CurrentPass123!");
    await user.click(revokeButton);

    await waitFor(() => expect(replace).toHaveBeenCalledWith("/"));
    expect(localStorage.getItem("dukaan_access_token")).toBeNull();
    expect(localStorage.getItem("dukaan_refresh_token")).toBeNull();
  });

  it("clears revoked tokens after a successful password change", async () => {
    const user = userEvent.setup();
    const replace = vi.fn();
    vi.stubGlobal("location", { ...window.location, replace });
    localStorage.setItem("dukaan_access_token", "access");
    localStorage.setItem("dukaan_refresh_token", "refresh");
    const fetchMock = mockApi({
      "GET /api/v1/gst-registrations/": () => jsonResponse([]),
      "GET /api/v1/integrations/gmail/status/": () => jsonResponse({ connected: false }),
      "GET /api/v1/integrations/notifications/devices/": () => jsonResponse([]),
      "GET /api/v1/integrations/notifications/reminders/": () => jsonResponse([]),
      "POST /api/v1/auth/password/change/": (init) => {
        expect(requestBody(init)).toEqual({
          old_password: "CurrentPass123!",
          new_password: "ReplacementPass456!",
        });
        return jsonResponse({ detail: "Password updated." });
      },
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<SettingsPage />);
    await user.type(screen.getByLabelText("Current password"), "CurrentPass123!");
    await user.type(screen.getByLabelText("New password"), "ReplacementPass456!");
    await user.click(screen.getByRole("button", { name: "Update password" }));

    await waitFor(() => expect(replace).toHaveBeenCalledWith("/"));
    expect(localStorage.getItem("dukaan_access_token")).toBeNull();
    expect(localStorage.getItem("dukaan_refresh_token")).toBeNull();
  });

  it("keeps tokens and shows the backend error when session password verification fails", async () => {
    const user = userEvent.setup();
    vi.spyOn(window, "confirm").mockReturnValue(true);
    localStorage.setItem("dukaan_access_token", "access");
    localStorage.setItem("dukaan_refresh_token", "refresh");
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/gst-registrations/": () => jsonResponse([]),
      "GET /api/v1/integrations/gmail/status/": () => jsonResponse({ connected: false }),
      "GET /api/v1/integrations/notifications/devices/": () => jsonResponse([]),
      "GET /api/v1/integrations/notifications/reminders/": () => jsonResponse([]),
      "POST /api/v1/auth/sessions/revoke-all/": () => jsonResponse({ detail: "Current password or a valid verification code is required." }, 400),
    }));

    renderWithWorkspace(<SettingsPage />);
    await user.type(screen.getByLabelText("Current password to revoke sessions"), "WrongPass");
    await user.click(screen.getByRole("button", { name: "Revoke all sessions" }));

    expect(await screen.findByRole("alert")).toHaveTextContent("Current password or a valid verification code is required.");
    expect(localStorage.getItem("dukaan_access_token")).toBe("access");
    expect(localStorage.getItem("dukaan_refresh_token")).toBe("refresh");
  });
});
