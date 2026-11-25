import { vi } from "vitest";
import type { Bootstrap, Role } from "../types";

export const bootstrap: Bootstrap = {
  user: { id: "u1", name: "Amit Sharma", phone: "+919876543210", role: "OWNER" },
  business: {
    id: "b1",
    name: "Gupta Traders",
    legalName: "Gupta Traders",
    currency: "INR",
    timezone: "Asia/Kolkata",
  },
  locations: [{ id: "l1", name: "Main Shop", code: "MAIN", stateCode: "07" }],
  permissions: ["*"],
};

export function workspaceWithRole(role: Role, overrides: Partial<Bootstrap> = {}): Bootstrap {
  const permissions = role === "OWNER"
    ? ["*"]
    : role === "MANAGER"
      ? ["operations", "reports"]
      : ["sales", "receipts", "stock", "customers"];
  return {
    ...bootstrap,
    user: { ...bootstrap.user, role },
    business: { ...bootstrap.business, role },
    permissions,
    ...overrides,
  };
}

export function jsonResponse(body: unknown, status = 200): Promise<Response> {
  return Promise.resolve(new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  }));
}

export function emptyResponse(status = 204): Promise<Response> {
  return Promise.resolve(new Response(null, { status }));
}

type ApiHandler = (init?: RequestInit) => Promise<Response> | Response;

export function mockApi(handlers: Record<string, ApiHandler>) {
  return vi.fn((input: RequestInfo | URL, init?: RequestInit) => {
    const url = typeof input === "string" ? input : input.toString();
    const path = url.replace(/^https?:\/\/[^/]+/, "");
    const method = (init?.method ?? "GET").toUpperCase();
    const routes = Object.entries(handlers).sort(([left], [right]) => right.length - left.length);
    for (const [route, handler] of routes) {
      const [routeMethod, routePath] = route.split(" ");
      if (method === routeMethod && path.startsWith(routePath)) return handler(init);
    }
    return jsonResponse({ error: { code: "not_found", detail: "no handler" } }, 404);
  });
}

export function requestBody(init: RequestInit | undefined): Record<string, unknown> {
  return JSON.parse(String(init?.body ?? "{}")) as Record<string, unknown>;
}
