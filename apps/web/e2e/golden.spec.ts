/** Golden path: signup → business → product → manual sale → Today.
 *
 * Run: `npm run e2e` with the API up (`make api-run`, sqlite is fine).
 * The web dev server is started automatically unless DUKAAN_NO_WEBSERVER
 * is set. Uses system Chrome (`channel: "chrome"`), so no Playwright
 * browser download is required.
 */
import { expect, test } from "@playwright/test";

const apiBase = process.env.DUKAAN_API_URL ?? "http://127.0.0.1:8000";

function uniquePhone(): string {
  const suffix = String(Math.floor(1000000 + Math.random() * 9000000));
  return `+91999${suffix}`;
}

async function api(path: string, init: RequestInit = {}) {
  const response = await fetch(`${apiBase}${path}`, {
    ...init,
    headers: { "Content-Type": "application/json", ...(init.headers ?? {}) },
  });
  if (!response.ok) {
    throw new Error(`API ${init.method ?? "GET"} ${path} → ${response.status}: ${await response.text()}`);
  }
  return response.json();
}

test("new phone number signs up, opens a business, and sees a sale on Today", async ({
  page,
}) => {
  const phone = uniquePhone();
  const password = "E2eSecure123!";

  const signup = (await api("/api/v1/auth/signup/", {
    method: "POST",
    body: JSON.stringify({ phone, password, display_name: "E2E Owner" }),
  })) as { access: string; refresh: string };

  await page.addInitScript(
    ({ access, refresh }) => {
      localStorage.setItem("dukaan_access_token", access);
      localStorage.setItem("dukaan_refresh_token", refresh);
    },
    { access: signup.access, refresh: signup.refresh },
  );

  // No business yet → the onboarding wizard opens the first business.
  await page.goto("/");
  await page.getByLabel("Business name").fill("E2E General Store");
  await page.getByRole("button", { name: "Create business" }).click();
  await expect(page.getByText("E2E General Store")).toBeVisible({ timeout: 15_000 });

  const auth = { Authorization: `Bearer ${signup.access}` };
  const bootstrap = (await api("/api/v1/bootstrap/", { headers: auth })) as {
    business: { id: string };
    locations: Array<{ id: string }>;
  };
  const businessId = bootstrap.business.id;
  const locationId = bootstrap.locations[0].id;

  const product = (await api("/api/v1/products/", {
    method: "POST",
    headers: auth,
    body: JSON.stringify({
      business: businessId,
      name: "E2E Shirt",
      sku: "E2E-SHIRT",
      base_unit: "PIECE",
      packs: [
        {
          name: "piece",
          conversion_factor: 1,
          retail_price_minor: 80000,
          wholesale_price_minor: 75000,
        },
      ],
    }),
  })) as { id: string };

  // Opening stock so the manual sale never hits negative-stock review.
  await api("/api/v1/stock/adjustments/", {
    method: "POST",
    headers: auth,
    body: JSON.stringify({
      business_id: businessId,
      location_id: locationId,
      product_id: product.id,
      quantity_delta: "10",
      movement_type: "OPENING",
      reason: "E2E opening stock",
      idempotency_key: `e2e-opening-${Date.now()}`,
    }),
  });

  // Record the sale through the real manual-sale form.
  await page.goto("/entries");
  await page.getByRole("button", { name: "Manual sale" }).click();
  await page.getByLabel("Product").selectOption(product.id);
  await page.getByLabel("Quantity").fill("2");
  await page.getByLabel("Paid now").fill("1600");
  await page.getByRole("button", { name: "Review sale" }).click();
  await page.getByRole("button", { name: /Record sale/ }).click();
  await expect(page.getByText(/recorded successfully/)).toBeVisible({ timeout: 15_000 });
  await page.getByRole("button", { name: "Done" }).click();

  // The sale is visible on Today.
  await page.goto("/");
  await expect(page.getByText("₹1,600.00")).toBeVisible({ timeout: 15_000 });
  void locationId;
});
