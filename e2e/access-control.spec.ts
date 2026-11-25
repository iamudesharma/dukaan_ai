import { expect, test } from "./support/mock-api";

test("an invited cashier accepts access and cannot see manager navigation or private data", async ({ page, context, api }) => {
  await api.signIn(page);
  const navigation = page.getByRole("navigation", { name: "Main navigation" });
  await navigation.getByRole("link", { name: "Team & locations" }).click();
  await page.getByRole("button", { name: "Invite member" }).click();
  await page.getByLabel("Mobile number with country code").fill("+919876500002");
  await page.getByRole("combobox", { name: "Role", exact: true }).selectOption("CASHIER");
  await page.getByRole("button", { name: "Create invitation" }).click();

  const token = await page.getByLabel("One-time invitation token").inputValue();
  expect(token.length).toBeGreaterThanOrEqual(20);
  await page.getByRole("button", { name: "Done" }).click();

  // The mock tokens are identity-neutral; /me/ and /bootstrap/ are the role
  // authority, exactly as they are for the real client.
  api.workspaceExists = false;
  api.role = "CASHIER";
  const cashier = await context.newPage();
  await cashier.goto("/");
  await expect(cashier.getByRole("heading", { name: "Set up your shop" })).toBeVisible();
  await cashier.getByLabel("Invitation token").fill(token);
  const acceptanceResponse = cashier.waitForResponse(
    (response) => response.url().endsWith("/api/v1/invitations/accept/") && response.request().method() === "POST",
  );
  await cashier.getByRole("button", { name: "Accept invitation" }).click();
  expect((await acceptanceResponse).ok()).toBe(true);

  const cashierNavigation = cashier.getByRole("navigation", { name: "Main navigation" });
  await expect(cashierNavigation.getByRole("link", { name: "Customers" })).toBeVisible();
  await expect(cashierNavigation.getByRole("link", { name: "Reports" })).toHaveCount(0);
  await expect(cashierNavigation.getByRole("link", { name: "Team & locations" })).toHaveCount(0);
  await expect(cashierNavigation.getByRole("link", { name: "Activity" })).toHaveCount(0);
  await expect(cashierNavigation.getByRole("link", { name: "Settings" })).toHaveCount(0);

  await cashier.goto("/reports");
  await expect(cashier.getByRole("heading", { name: "Page not found" })).toBeVisible();
  await cashier.goto("/team");
  await expect(cashier.getByRole("heading", { name: "Page not found" })).toBeVisible();

  await cashierNavigation.getByRole("link", { name: "Entries" }).click();
  await expect(cashier.getByRole("tab", { name: "Purchases" })).toHaveCount(0);
  await expect(cashier.getByRole("tab", { name: "Expenses" })).toHaveCount(0);
  await expect(cashier.getByRole("button", { name: "Purchase" })).toHaveCount(0);
  await expect(cashier.getByRole("button", { name: "Expense" })).toHaveCount(0);

  await cashierNavigation.getByRole("link", { name: "Stock" }).click();
  await expect(cashier.getByRole("columnheader", { name: "Wholesale" })).toHaveCount(0);
  await expect(cashier.getByRole("button", { name: "Add product" })).toHaveCount(0);

  await cashierNavigation.getByRole("link", { name: "Customers" }).click();
  await expect(cashier.getByRole("heading", { name: "E2E Customer" })).toBeVisible();
  await expect(cashier.getByRole("heading", { name: "E2E Supplier" })).toHaveCount(0);
  await expect(cashier.getByText("You will pay", { exact: true })).toHaveCount(0);

  expect(api.forbiddenCashierRequests).toEqual([]);
});

test("revoking all sessions verifies the password, clears tokens, and returns to sign-in", async ({ page, api }) => {
  await api.signIn(page);
  await page.getByRole("navigation", { name: "Main navigation" }).getByRole("link", { name: "Settings" }).click();
  await expect(page.getByRole("heading", { name: "Settings" })).toBeVisible();

  await page.getByLabel("Current password to revoke sessions").fill("E2eCurrentPassword123!");
  page.once("dialog", (dialog) => dialog.accept());
  await page.getByRole("button", { name: "Revoke all sessions" }).click();

  await expect(page.getByRole("heading", { name: "Sign in with password" })).toBeVisible();
  const tokens = await page.evaluate(() => ({
    access: localStorage.getItem("dukaan_access_token"),
    refresh: localStorage.getItem("dukaan_refresh_token"),
  }));
  expect(tokens).toEqual({ access: null, refresh: null });
  const revokeCall = api.calls.find(
    (call) => call.path === "/api/v1/auth/sessions/revoke-all/" && call.method === "POST",
  );
  expect(revokeCall?.body).toEqual({ password: "E2eCurrentPassword123!" });
});
