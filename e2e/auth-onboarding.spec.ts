import { expect, test } from "./support/mock-api";

test("a new owner can sign up, onboard, and reach role-aware navigation", async ({ page, api }) => {
  await page.goto("/");

  await expect(page.getByRole("heading", { name: "Sign in with password" })).toBeVisible();
  await page.getByRole("button", { name: "Create a new account" }).click();
  await page.getByLabel("Mobile number").fill("+919876500010");
  await page.getByLabel("Display name").fill("E2E New Owner");
  await page.getByLabel("Password", { exact: true }).fill("E2ePassword123!");
  await page.getByRole("button", { name: "Create account", exact: true }).click();

  await expect(page.getByRole("heading", { name: "Set up your shop" })).toBeVisible();
  await page.getByLabel("Shop name").fill("E2E New Shop");
  await page.getByLabel("First location (optional)").fill("Main Shop");
  await page.getByRole("button", { name: "Create my shop" }).click();

  const navigation = page.getByRole("navigation", { name: "Main navigation" });
  await expect(navigation.getByRole("link", { name: "Overview" })).toBeVisible();
  await expect(navigation.getByRole("link", { name: "Reports" })).toBeVisible();
  await expect(navigation.getByRole("link", { name: "Team & locations" })).toBeVisible();
  await expect(navigation.getByRole("link", { name: "Settings" })).toBeVisible();
  await expect(page.getByRole("heading", { name: "Namaste, E2E" })).toBeVisible();

  const businessCall = api.calls.find((call) => call.path === "/api/v1/businesses/" && call.method === "POST");
  expect(businessCall?.body).toMatchObject({
    name: "E2E New Shop",
    legal_name: "E2E New Shop",
    location_name: "Main Shop",
  });
});
