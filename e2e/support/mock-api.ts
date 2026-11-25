import { expect, test as base, type BrowserContext, type Page, type Route } from "@playwright/test";

const WEB_ORIGIN = "http://127.0.0.1:4173";
const API_ORIGIN = "http://127.0.0.1:8000";
const INVITATION_TOKEN = "e2e-invitation-token-1234567890";
const OWNER_PHONE = "+919876500001";
const CASHIER_PHONE = "+919876500002";

const corsHeaders = {
  "Access-Control-Allow-Origin": WEB_ORIGIN,
  "Access-Control-Allow-Methods": "GET,POST,PATCH,DELETE,OPTIONS",
  "Access-Control-Allow-Headers":
    "Accept,Authorization,Content-Type,Idempotency-Key,X-Client",
  "Access-Control-Expose-Headers": "Content-Disposition",
  "Access-Control-Max-Age": "600",
};

type Role = "OWNER" | "MANAGER" | "CASHIER";

interface Sale {
  id: string;
  number: string;
  customer: { id: string; name: string };
  grand_total_minor: number;
  due_total_minor: number;
  paid_total_minor: number;
  posted_at: string;
  status: string;
  payment_method: string;
}

interface ApiCall {
  method: string;
  path: string;
  body: unknown;
}

interface ImportJob {
  id: string;
  business: string;
  kind: "PRODUCT" | "PARTY";
  status: "READY" | "COMPLETED";
  duplicate_strategy: "UPDATE" | "SKIP";
  row_count: number;
  valid_row_count: number;
  error_count: number;
  created_count: number;
  updated_count: number;
  skipped_count: number;
  errors: unknown[];
  original_filename: string;
}

export class MockApi {
  role: Role = "OWNER";
  workspaceExists = true;
  sales: Sale[] = [];
  invitations: Array<Record<string, unknown>> = [];
  importJob: ImportJob | null = null;
  calls: ApiCall[] = [];
  unexpected: string[] = [];
  blockedExternalRequests: string[] = [];
  forbiddenCashierRequests: string[] = [];

  async install(context: BrowserContext): Promise<void> {
    // Context-level routing also covers additional tabs, so no page can escape
    // the hermetic API boundary.
    await context.route("**/*", async (route) => {
      const request = route.request();
      const url = new URL(request.url());

      if (url.origin === WEB_ORIGIN) {
        await route.continue();
        return;
      }
      if (url.origin !== API_ORIGIN || !url.pathname.startsWith("/api/v1/")) {
        this.blockedExternalRequests.push(request.url());
        await route.abort("blockedbyclient");
        return;
      }
      if (request.method() === "OPTIONS") {
        await route.fulfill({ status: 204, headers: corsHeaders });
        return;
      }

      await this.handleApi(route, url.pathname);
    });
  }

  async signIn(page: Page): Promise<void> {
    await page.addInitScript(() => {
      // Seed once per tab so a full-page reload after session revocation does
      // not accidentally authenticate the browser again.
      if (sessionStorage.getItem("dukaan_e2e_session_seeded")) return;
      localStorage.setItem("dukaan_access_token", "e2e-access-token");
      localStorage.setItem("dukaan_refresh_token", "e2e-refresh-token");
      sessionStorage.setItem("dukaan_e2e_session_seeded", "true");
    });
    await page.goto("/");
    await expect(page.getByRole("navigation", { name: "Main navigation" })).toBeVisible();
  }

  private async handleApi(route: Route, path: string): Promise<void> {
    const request = route.request();
    const method = request.method();
    let body: unknown = null;
    if (method === "POST" || method === "PATCH" || method === "PUT") {
      const raw = request.postData() ?? "";
      try {
        body = JSON.parse(raw);
      } catch {
        body = raw;
      }
    }
    this.calls.push({ method, path, body });

    const managerOnlyPaths = [
      "/api/v1/reports/dashboard/",
      "/api/v1/reports/valuation/",
      "/api/v1/payments/allocation-review/",
      "/api/v1/purchases/",
      "/api/v1/expenses/",
      "/api/v1/memberships/",
      "/api/v1/invitations/",
      "/api/v1/gst-registrations/",
      "/api/v1/integrations/gmail/status/",
    ];
    if (
      this.role === "CASHIER" &&
      managerOnlyPaths.includes(path)
    ) {
      this.forbiddenCashierRequests.push(`${method} ${path}`);
    }

    const json = (value: unknown, status = 200) =>
      route.fulfill({ status, json: value, headers: corsHeaders });

    if (path === "/api/v1/auth/capabilities/" && method === "GET") {
      return json({ password: true, otp: false, dev_otp: false });
    }
    if (
      (path === "/api/v1/auth/login/" || path === "/api/v1/auth/signup/") &&
      method === "POST"
    ) {
      if (path.endsWith("/signup/")) {
        this.workspaceExists = false;
        this.role = "OWNER";
      }
      return json(
        {
          access: "e2e-access-token",
          refresh: "e2e-refresh-token",
          onboarding_required: !this.workspaceExists,
        },
        201,
      );
    }
    if (path === "/api/v1/auth/refresh/" && method === "POST") {
      return json({ access: "e2e-access-token" });
    }
    if (path === "/api/v1/auth/logout/" && method === "POST") {
      return route.fulfill({ status: 204, headers: corsHeaders });
    }
    if (path === "/api/v1/auth/sessions/revoke-all/" && method === "POST") {
      return json({ detail: "All sessions have been revoked.", token_version: 2 });
    }

    if (path === "/api/v1/me/" && method === "GET") {
      return json({
        id: this.role === "CASHIER" ? "cashier-user" : "owner-user",
        phone: this.role === "CASHIER" ? CASHIER_PHONE : OWNER_PHONE,
        display_name: this.role === "CASHIER" ? "E2E Cashier" : "E2E Owner",
        memberships: this.workspaceExists
          ? [
              {
                business_id: "business-1",
                business_name: "E2E General Store",
                role: this.role,
              },
            ]
          : [],
      });
    }
    if (path === "/api/v1/bootstrap/" && method === "GET") {
      if (!this.workspaceExists) {
        return json(
          {
            error: {
              code: "onboarding_required",
              detail: { message: "Create your shop to continue." },
            },
          },
          404,
        );
      }
      return json(this.bootstrap());
    }
    if (path === "/api/v1/businesses/" && method === "POST") {
      this.workspaceExists = true;
      this.role = "OWNER";
      return json(
        {
          id: "business-1",
          name: "E2E General Store",
          legal_name: "E2E General Store",
        },
        201,
      );
    }

    if (path === "/api/v1/reports/dashboard/" && method === "GET") {
      return json({
        as_of: "2026-11-24T10:00:00Z",
        today: { sales_minor: 0, expenses_minor: 0 },
        books: {
          receipts_minor: 0,
          cash_flow_minor: 0,
          receivable_minor: 0,
          payable_minor: 0,
        },
        low_stock_count: 0,
        gross_profit_minor: null,
        summary: "Hermetic E2E figures.",
      });
    }
    if (path === "/api/v1/reports/valuation/" && method === "GET") {
      return json({
        inventory: {
          total_quantity: "20",
          average_cost_minor: 8000,
          total_value_minor: 160000,
          known_value_minor: 160000,
          costing_complete: true,
        },
        sales: {
          posted_sale_count: this.sales.length,
          line_count: this.sales.length,
          net_sales_minor: this.sales.reduce((sum, sale) => sum + sale.grand_total_minor, 0),
          cogs_minor: 0,
          gross_profit_minor: null,
          missing_cost_line_count: 0,
          costing_complete: false,
        },
        results: [],
      });
    }
    if (path === "/api/v1/reports/stock/" && method === "GET") {
      return json({
        results: [
          {
            product_id: "product-1",
            name: "E2E Shirt",
            unit: "piece",
            quantity: "20",
            low_stock_threshold: "2",
            is_low_stock: false,
          },
        ],
      });
    }
    if (path === "/api/v1/reports/party-ledger/" && method === "GET") {
      return json({ party_id: "party-1", balance: 0, entries: [] });
    }
    if (path === "/api/v1/payments/allocation-review/" && method === "GET") {
      return json({
        payments: [],
        totals: {
          payment_count: 0,
          payment_total_minor: 0,
          allocated_total_minor: 0,
          unallocated_total_minor: 0,
          outstanding_document_count: 0,
          outstanding_total_minor: 0,
        },
        outstanding_documents: [],
      });
    }

    if (path === "/api/v1/products/" && method === "GET") {
      return json({
        results: [
          {
            id: "product-1",
            name: "E2E Shirt",
            sku: "E2E-SHIRT",
            base_unit: "PIECE",
            stock_quantity: "20",
            low_stock_threshold: "2",
            is_low_stock: false,
            tax_rate_bps: 0,
            packs: [
              {
                id: "pack-1",
                retail_price_minor: 12500,
                wholesale_price_minor: 10000,
              },
            ],
          },
        ],
      });
    }
    if (path === "/api/v1/parties/" && method === "GET") {
      return json({
        results: [
          {
            id: "party-1",
            name: "E2E Customer",
            phone_e164: "+919876500003",
            kind: "CUSTOMER",
            receivable_minor: 0,
            payable_minor: 0,
            price_tier: "RETAIL",
          },
          {
            id: "party-2",
            name: "E2E Supplier",
            phone_e164: "+919876500004",
            kind: "SUPPLIER",
            receivable_minor: 0,
            payable_minor: 50000,
            price_tier: "WHOLESALE",
          },
        ],
      });
    }
    if (path === "/api/v1/sales/" && method === "GET") {
      return json({ results: this.sales });
    }
    if (path === "/api/v1/sales/" && method === "POST") {
      const payload = body as {
        lines: Array<{ quantity: string; unit_price_minor: number }>;
        paid_amount_minor: number;
        customer_id: string | null;
        payment_method: string;
      };
      const totalMinor = payload.lines.reduce(
        (sum, line) => sum + Math.round(Number(line.quantity) * line.unit_price_minor),
        0,
      );
      const sale: Sale = {
        id: "sale-1",
        number: "INV-001",
        customer: { id: payload.customer_id ?? "walk-in", name: "E2E Customer" },
        grand_total_minor: totalMinor,
        due_total_minor: totalMinor - payload.paid_amount_minor,
        paid_total_minor: payload.paid_amount_minor,
        posted_at: "2026-11-24T10:00:00Z",
        status: "POSTED",
        payment_method: payload.payment_method,
      };
      this.sales = [sale];
      return json(sale, 201);
    }
    if (path === "/api/v1/invoices/sales/sale-1/pdf/" && method === "GET") {
      return route.fulfill({
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/pdf",
          "Content-Disposition": 'attachment; filename="INV-001.pdf"',
        },
        body: Buffer.from("%PDF-1.4\n1 0 obj\n<< /Type /Catalog >>\nendobj\n%%EOF\n"),
      });
    }
    if (
      ["/api/v1/purchases/", "/api/v1/payments/", "/api/v1/expenses/"].includes(path) &&
      method === "GET"
    ) {
      return json({ results: [] });
    }

    if (
      (path === "/api/v1/imports/products/" || path === "/api/v1/imports/parties/") &&
      method === "POST"
    ) {
      const multipart = String(body ?? "");
      const dryRun = multipart.includes('name="dry_run"\r\n\r\ntrue');
      const kind = path.includes("/products/") ? "PRODUCT" : "PARTY";
      if (dryRun) {
        return json({
          dry_run: true,
          kind,
          duplicate_strategy: "UPDATE",
          row_count: 1,
          valid_row_count: 1,
          error_count: 0,
          created_count: 1,
          updated_count: 0,
          skipped_count: 0,
          errors: [],
          preview: [{ row: 2, action: "CREATE" }],
        });
      }
      this.importJob = {
        id: "import-1",
        business: "business-1",
        kind,
        status: "READY",
        duplicate_strategy: "UPDATE",
        row_count: 1,
        valid_row_count: 1,
        error_count: 0,
        created_count: 1,
        updated_count: 0,
        skipped_count: 0,
        errors: [],
        original_filename: "e2e-products.csv",
      };
      return json(this.importJob, 201);
    }
    if (path === "/api/v1/imports/import-1/confirm/" && method === "POST") {
      if (!this.importJob) return json({ detail: "Import not found." }, 404);
      this.importJob = { ...this.importJob, status: "COMPLETED" };
      return json({ job: this.importJob, replayed: false });
    }

    if (path === "/api/v1/memberships/" && method === "GET") {
      return json({
        results: [
          {
            id: "membership-1",
            user: "owner-user",
            business: "business-1",
            role: "OWNER",
            locations: ["location-1"],
          },
        ],
      });
    }
    if (path === "/api/v1/invitations/" && method === "GET") {
      return json({ results: this.invitations });
    }
    if (path === "/api/v1/invitations/" && method === "POST") {
      const payload = body as { invitee_phone: string; role: Role; locations: string[] };
      const invitation = {
        id: "invitation-1",
        business: "business-1",
        invitee_phone: payload.invitee_phone,
        role: payload.role,
        locations: payload.locations,
        status: "PENDING",
        expires_at: "2026-12-01T10:00:00Z",
        inviter: "owner-user",
        created_at: "2026-11-24T10:00:00Z",
        token: INVITATION_TOKEN,
      };
      this.invitations = [invitation];
      return json(invitation, 201);
    }
    if (path === "/api/v1/invitations/accept/" && method === "POST") {
      const payload = body as { token: string };
      if (payload.token !== INVITATION_TOKEN) {
        return json({ detail: "Invalid invitation token." }, 400);
      }
      this.workspaceExists = true;
      this.role = "CASHIER";
      return json({ ...this.invitations[0], status: "ACCEPTED" });
    }
    if (path === "/api/v1/invitations/invitation-1/revoke/" && method === "POST") {
      this.invitations = this.invitations.map((invitation) => ({
        ...invitation,
        status: "REVOKED",
      }));
      return json(this.invitations[0]);
    }

    if (path === "/api/v1/gst-registrations/" && method === "GET") {
      return json({ results: [] });
    }
    if (path === "/api/v1/integrations/gmail/status/" && method === "GET") {
      return json({ connected: false });
    }
    if (
      path === "/api/v1/integrations/notifications/devices/" ||
      path === "/api/v1/integrations/notifications/reminders/"
    ) {
      return json({ results: [] });
    }
    if (path === "/api/v1/assistant/proposals/" && method === "GET") {
      return json({ results: [] });
    }

    this.unexpected.push(`${method} ${path}`);
    return json(
      { error: { code: "e2e_unmocked_route", detail: `No mock for ${method} ${path}` } },
      500,
    );
  }

  private bootstrap() {
    const isCashier = this.role === "CASHIER";
    return {
      user: {
        id: isCashier ? "cashier-user" : "owner-user",
        name: isCashier ? "E2E Cashier" : "E2E Owner",
        phone: isCashier ? CASHIER_PHONE : OWNER_PHONE,
        role: this.role,
      },
      business: {
        id: "business-1",
        name: "E2E General Store",
        legal_name: "E2E General Store",
        currency: "INR",
        timezone: "Asia/Kolkata",
        role: this.role,
      },
      locations: [{ id: "location-1", name: "Main Shop", code: "MAIN", state_code: "07" }],
      permissions: isCashier
        ? ["sales", "receipts", "stock", "customers"]
        : this.role === "MANAGER"
          ? ["operations", "reports"]
          : ["*"],
    };
  }
}

export const test = base.extend<{ api: MockApi }>({
  api: async ({ context }, use) => {
    const api = new MockApi();
    await api.install(context);
    await use(api);
    expect(api.unexpected, "Every API request must have an explicit hermetic mock").toEqual([]);
    expect(api.blockedExternalRequests, "No test may contact an external service").toEqual([]);
  },
});

export { expect };
