import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { TestProviders } from "./test/TestProviders";
import App from "./App";

const bootstrapPayload = {
  user: { id: "u1", name: "Amit Sharma", phone: "+919876543210", role: "OWNER" },
  business: {
    id: "b1",
    name: "Gupta Traders",
    legal_name: "Gupta Traders",
    currency: "INR",
    timezone: "Asia/Kolkata",
  },
  locations: [{ id: "l1", name: "Main Shop", code: "MAIN", state_code: "07" }],
  permissions: ["*"],
};

function jsonResponse(body: unknown, status = 200) {
  return Promise.resolve(
    new Response(JSON.stringify(body), {
      status,
      headers: { "Content-Type": "application/json" },
    }),
  );
}

function mockApi(handlers: Record<string, () => Promise<Response>>) {
  return vi.fn((input: RequestInfo | URL, init?: RequestInit) => {
    const url = typeof input === "string" ? input : input.toString();
    const path = url.replace(/^https?:\/\/[^/]+/, "");
    const method = (init?.method ?? "GET").toUpperCase();
    for (const [route, handler] of Object.entries(handlers)) {
      const [routeMethod, routePath] = route.split(" ");
      if (method === routeMethod && path.startsWith(routePath)) return handler();
    }
    return jsonResponse({ error: { code: "not_found", detail: "no handler" } }, 404);
  });
}

describe("DukaanAI web console", () => {
  beforeEach(() => {
    localStorage.clear();
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it("asks a signed-out visitor to sign in", async () => {
    vi.stubGlobal("fetch", mockApi({}));

    render(<TestProviders><App /></TestProviders>);

    expect(await screen.findByRole("heading", { name: /Sign in with password/i })).toBeInTheDocument();
    expect(screen.getByLabelText(/Mobile number/i)).toBeInTheDocument();
  });

  it("sends credentials to the configured API and opens the console", async () => {
    localStorage.setItem("dukaan_access_token", "stored-access");
    localStorage.setItem("dukaan_refresh_token", "stored-refresh");
    const fetchMock = mockApi({
      "GET /api/v1/me/": () =>
        jsonResponse({
          id: "u1",
          phone: "+919876543210",
          display_name: "Amit Sharma",
          memberships: [{ business_id: "b1", business_name: "Gupta Traders", role: "OWNER" }],
        }),
      "GET /api/v1/bootstrap/": () => jsonResponse(bootstrapPayload),
      "GET /api/v1/reports/dashboard/": () =>
        jsonResponse({ as_of: "2026-09-11", today: { sales: 0 }, books: {} }),
      "GET /api/v1/reports/valuation/": () =>
        jsonResponse({ inventory: { costing_complete: true, total_value_minor: 0, known_value_minor: 0, average_cost_minor: null, total_quantity: "0" }, sales: { posted_sale_count: 0, line_count: 0, net_sales_minor: 0, cogs_minor: 0, gross_profit_minor: 0, missing_cost_line_count: 0, costing_complete: true }, results: [] }),
      "GET /api/v1/sales/": () => jsonResponse([]),
      "GET /api/v1/purchases/": () => jsonResponse([]),
      "GET /api/v1/payments/": () => jsonResponse([]),
      "GET /api/v1/expenses/": () => jsonResponse([]),
      "GET /api/v1/products/": () => jsonResponse([]),
      "GET /api/v1/parties/": () => jsonResponse([]),
    });
    vi.stubGlobal("fetch", fetchMock);

    render(<TestProviders><App /></TestProviders>);

    expect(await screen.findByRole("heading", { name: /Namaste, Amit/i })).toBeInTheDocument();
    expect(screen.getByText("You will receive")).toBeInTheDocument();
    expect(fetchMock.mock.calls.some(([input]) => String(input).includes("/api/v1/bootstrap/"))).toBe(true);
  });

  it.each(["reports", "team", "settings", "activity"])("blocks a cashier from directly opening /%s", async (path) => {
    localStorage.setItem("dukaan_access_token", "stored-access");
    const fetchMock = mockApi({
      "GET /api/v1/me/": () =>
        jsonResponse({
          id: "u1",
          phone: "+919876543210",
          display_name: "Amit Sharma",
          memberships: [{ business_id: "b1", business_name: "Gupta Traders", role: "CASHIER" }],
        }),
      "GET /api/v1/bootstrap/": () => jsonResponse({
        ...bootstrapPayload,
        user: { ...bootstrapPayload.user, role: "CASHIER" },
        permissions: ["sales", "receipts", "stock", "customers"],
      }),
    });
    vi.stubGlobal("fetch", fetchMock);

    render(<TestProviders initialEntries={[`/${path}`]}><App /></TestProviders>);

    expect(await screen.findByRole("heading", { name: "Page not found" })).toBeInTheDocument();
    expect(fetchMock.mock.calls.every(([input]) => !/\/(reports|memberships|gst-registrations|audit-events)\//.test(String(input)))).toBe(true);
  });

  it("lets a cashier open the dedicated invitation acceptance panel", async () => {
    localStorage.setItem("dukaan_access_token", "stored-access");
    const fetchMock = mockApi({
      "GET /api/v1/me/": () => jsonResponse({
        id: "u1", phone: "+919876543210", display_name: "Amit Sharma",
        memberships: [{ business_id: "b1", business_name: "Gupta Traders", role: "CASHIER" }],
      }),
      "GET /api/v1/bootstrap/": () => jsonResponse({
        ...bootstrapPayload,
        user: { ...bootstrapPayload.user, role: "CASHIER" },
        permissions: ["sales", "receipts", "stock", "customers"],
      }),
    });
    vi.stubGlobal("fetch", fetchMock);

    render(<TestProviders initialEntries={["/invitation"]}><App /></TestProviders>);

    expect(await screen.findByRole("heading", { name: "Accept a team invitation" })).toBeInTheDocument();
    expect(fetchMock.mock.calls.every(([input]) => !/\/(memberships|invitations|audit-events)\//.test(String(input)))).toBe(true);
  });

  it("walks a brand-new account through shop onboarding", async () => {
    localStorage.setItem("dukaan_access_token", "stored-access");
    const fetchMock = mockApi({
      "GET /api/v1/me/": () =>
        jsonResponse({ id: "u1", phone: "+919876543210", display_name: "", memberships: [] }),
      "POST /api/v1/businesses/": () =>
        jsonResponse({ id: "b9", name: "Gupta Traders", legal_name: "Gupta Traders" }, 201),
    });
    vi.stubGlobal("fetch", fetchMock);

    render(<TestProviders><App /></TestProviders>);

    expect(await screen.findByRole("heading", { name: /Set up your shop/i })).toBeInTheDocument();
    await userEvent.type(screen.getByLabelText(/Shop name/i), "Gupta Traders");
    await userEvent.type(screen.getByLabelText(/GSTIN/i), "07AAAAA0000A1Z5");
    await userEvent.click(screen.getByRole("button", { name: /Create my shop/i }));

    await waitFor(() => {
      const call = fetchMock.mock.calls.find(([input]) =>
        String(input).endsWith("/api/v1/businesses/"),
      );
      expect(call).toBeTruthy();
      expect(JSON.parse(String(call?.[1]?.body))).toMatchObject({
        name: "Gupta Traders",
        gstin: "07AAAAA0000A1Z5",
      });
    });
  });
});
