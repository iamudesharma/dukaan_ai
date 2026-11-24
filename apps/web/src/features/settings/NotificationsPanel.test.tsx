import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { NotificationsPanel } from "./NotificationsPanel";
import { TestProviders } from "../../test/TestProviders";
import { emptyResponse, jsonResponse, mockApi, requestBody } from "../../test/apiMocks";

afterEach(() => vi.unstubAllGlobals());

const locations = [{ id: "l1", name: "Main Shop" }];
const scheduledReminder = {
  id: "reminder1", business: "b1", location: "l1", kind: "USER", title: "Stock check", body: "Count shirts",
  scheduled_at: "2027-01-01T10:00:00Z", status: "SCHEDULED", dedupe_key: "web-1", data: {}, metadata: {},
};

function renderPanel() {
  return render(<TestProviders><NotificationsPanel userId="u1" businessId="b1" locationId="l1" locations={locations} /></TestProviders>);
}

describe("NotificationsPanel", () => {
  it("registers a write-only device token and schedules a reminder without inline delivery", async () => {
    const user = userEvent.setup();
    let created = false;
    const fetchMock = mockApi({
      "GET /api/v1/integrations/notifications/devices/": () => jsonResponse([{ id: "device1", business: "b1", location: "l1", platform: "WEB", status: "ACTIVE", token_suffix: "…1234", last_seen_at: "2026-11-24T10:00:00Z", metadata: {} }]),
      "POST /api/v1/integrations/notifications/devices/": (init) => {
        expect(requestBody(init)).toMatchObject({ business_id: "b1", location_id: "l1", fcm_token: "private-fcm-token", platform: "WEB" });
        return jsonResponse({ id: "device1", business: "b1", location: "l1", platform: "WEB", status: "ACTIVE", token_suffix: "…oken", last_seen_at: "2026-11-24T10:00:00Z", metadata: {} }, 201);
      },
      "GET /api/v1/integrations/notifications/reminders/": () => jsonResponse(created ? [scheduledReminder] : []),
      "POST /api/v1/integrations/notifications/reminders/": (init) => {
        const body = requestBody(init);
        expect(body).toMatchObject({ business_id: "b1", location_id: "l1", title: "Stock check", body: "Count shirts" });
        expect(String(body.dedupe_key)).toMatch(/^web-/);
        expect(new Date(String(body.scheduled_at)).toISOString()).toBe(new Date("2027-01-01T10:00").toISOString());
        created = true;
        return jsonResponse(scheduledReminder, 201);
      },
    });
    vi.stubGlobal("fetch", fetchMock);

    renderPanel();
    expect(await screen.findByText("WEB · …1234")).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: "Register device" }));
    await user.type(screen.getByLabelText("FCM registration token"), "private-fcm-token");
    await user.click(within(screen.getByRole("form", { name: "Register push device" })).getByRole("button", { name: "Register device" }));
    expect(await screen.findByText(/Device registered/)).toBeInTheDocument();
    expect(screen.queryByDisplayValue("private-fcm-token")).not.toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "New reminder" }));
    await user.type(screen.getByLabelText("Title"), "Stock check");
    await user.type(screen.getByLabelText("Message"), "Count shirts");
    const dateTime = screen.getByLabelText("Date and time");
    await user.clear(dateTime);
    await user.type(dateTime, "2027-01-01T10:00");
    await user.click(within(screen.getByRole("form", { name: "Reminder details" })).getByRole("button", { name: "Schedule reminder" }));

    expect(await screen.findByText(/This page did not send a push notification/)).toBeInTheDocument();
    expect(await screen.findByText("Stock check")).toBeInTheDocument();
    expect(fetchMock.mock.calls.every(([input]) => !String(input).includes("fcm.googleapis.com"))).toBe(true);
  });

  it("edits and cancels a scheduled reminder through PATCH and DELETE", async () => {
    const user = userEvent.setup();
    let current = scheduledReminder;
    const fetchMock = mockApi({
      "GET /api/v1/integrations/notifications/devices/": () => jsonResponse([]),
      "GET /api/v1/integrations/notifications/reminders/": () => jsonResponse([current]),
      "PATCH /api/v1/integrations/notifications/reminders/reminder1/": (init) => {
        expect(requestBody(init)).toEqual({ title: "Stock check updated", body: "Count shirts", scheduled_at: new Date(scheduledReminder.scheduled_at).toISOString() });
        current = { ...current, title: "Stock check updated" };
        return jsonResponse(current);
      },
      "DELETE /api/v1/integrations/notifications/reminders/reminder1/": () => emptyResponse(),
    });
    vi.stubGlobal("fetch", fetchMock);

    renderPanel();
    await user.click(await screen.findByRole("button", { name: "Edit" }));
    const title = screen.getByLabelText("Title");
    await user.clear(title);
    await user.type(title, "Stock check updated");
    await user.click(within(screen.getByRole("form", { name: "Reminder details" })).getByRole("button", { name: "Save reminder" }));
    expect(await screen.findByText("Stock check updated")).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Cancel reminder" }));
    await waitFor(() => expect(fetchMock.mock.calls.some(([input, init]) => String(input).endsWith("/api/v1/integrations/notifications/reminders/reminder1/") && init?.method === "DELETE")).toBe(true));
  });

  it("shows backend FCM configuration failures and disabled-delivery guidance", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/integrations/notifications/devices/": () => jsonResponse([{ id: "device1", business: "b1", location: "l1", platform: "WEB", status: "ACTIVE", token_suffix: "…1234", last_seen_at: "2026-11-24T10:00:00Z", metadata: {} }]),
      "GET /api/v1/integrations/notifications/reminders/": () => jsonResponse([
        { ...scheduledReminder, id: "failed1", status: "FAILED", last_error: "FCM service-account credentials are not configured." },
        { ...scheduledReminder, id: "skipped1", title: "Skipped reminder", status: "SKIPPED", last_error: "" },
      ]),
    }));

    renderPanel();
    expect(await screen.findByText(/Delivery failed: FCM service-account credentials are not configured/)).toBeInTheDocument();
    expect(screen.getByText(/Push notifications may be disabled or FCM credentials may be missing or invalid/)).toBeInTheDocument();
  });

  it("opts a device out without exposing its full token", async () => {
    const user = userEvent.setup();
    const fetchMock = mockApi({
      "GET /api/v1/integrations/notifications/devices/": () => jsonResponse([{ id: "device1", business: "b1", location: "l1", platform: "WEB", status: "ACTIVE", token_suffix: "…1234", last_seen_at: "2026-11-24T10:00:00Z", metadata: {} }]),
      "DELETE /api/v1/integrations/notifications/devices/device1/": () => emptyResponse(),
      "GET /api/v1/integrations/notifications/reminders/": () => jsonResponse([]),
    });
    vi.stubGlobal("fetch", fetchMock);

    renderPanel();
    await user.click(await screen.findByRole("button", { name: "Opt out" }));
    await waitFor(() => expect(fetchMock.mock.calls.some(([input, init]) => String(input).endsWith("/api/v1/integrations/notifications/devices/device1/") && init?.method === "DELETE")).toBe(true));
    expect(screen.queryByDisplayValue(/private-fcm-token/)).not.toBeInTheDocument();
  });
});
