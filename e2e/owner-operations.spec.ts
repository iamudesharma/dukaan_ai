import { expect, test } from "./support/mock-api";

test("an owner reviews and posts a manual sale, then downloads its invoice PDF", async ({ page, api }) => {
  await api.signIn(page);
  await page.getByRole("navigation", { name: "Main navigation" }).getByRole("link", { name: "Entries" }).click();
  await page.getByRole("button", { name: "Manual sale" }).click();

  const dialog = page.getByRole("dialog", { name: "Record a sale" });
  await expect(dialog).toBeVisible();
  await dialog.getByLabel(/^Product/).selectOption("product-1");
  await dialog.getByLabel(/^Customer/).selectOption("party-1");
  await dialog.getByLabel("Quantity").fill("2");
  await dialog.getByLabel("Unit price").fill("125");
  await dialog.getByLabel("Paid now").fill("100");
  await dialog.getByRole("button", { name: "Review sale" }).click();

  await expect(dialog.getByText("Check before recording")).toBeVisible();
  await expect(dialog.getByText("Reduce E2E Shirt stock by 2")).toBeVisible();
  await expect(dialog.getByText("Add ₹150 to E2E Customer's outstanding balance")).toBeVisible();
  expect(api.sales, "Reviewing a sale must not post it").toHaveLength(0);

  await dialog.getByRole("button", { name: "Record sale ₹250" }).click();
  await expect(dialog.getByRole("status")).toContainText("INV-001 recorded successfully.");
  await dialog.getByRole("button", { name: "Done" }).click();

  await expect(page.getByText("INV-001", { exact: true })).toBeVisible();
  await expect(page.getByRole("cell", { name: "E2E Customer", exact: true })).toBeVisible();
  const saleCall = api.calls.find((call) => call.path === "/api/v1/sales/" && call.method === "POST");
  expect(saleCall?.body).toMatchObject({
    business_id: "business-1",
    location_id: "location-1",
    customer_id: "party-1",
    price_mode: "RETAIL",
    paid_amount_minor: 10000,
    payment_method: "CASH",
    lines: [
      {
        pack_id: "pack-1",
        quantity: "2",
        unit_price_minor: 12500,
      },
    ],
  });

  const downloadPromise = page.waitForEvent("download");
  await page.getByRole("button", { name: "Download invoice PDF for INV-001" }).click();
  const download = await downloadPromise;
  expect(download.suggestedFilename()).toBe("INV-001.pdf");
  expect(api.calls.some((call) => call.path === "/api/v1/invoices/sales/sale-1/pdf/")).toBe(true);
});

test("CSV import requires dry-run, snapshot preparation, and explicit confirmation", async ({ page, api }) => {
  await api.signIn(page);
  await page.getByRole("navigation", { name: "Main navigation" }).getByRole("link", { name: "Stock & transfers" }).click();
  await page.getByRole("button", { name: "Import CSV" }).click();

  const panel = page.getByRole("region", { name: "Import products CSV" });
  await expect(panel).toBeVisible();
  await panel.getByLabel("CSV file").setInputFiles({
    name: "e2e-products.csv",
    mimeType: "text/csv",
    buffer: Buffer.from("name,sku,retail_price_minor,wholesale_price_minor\nE2E CSV Shirt,CSV-1,12500,10000\n"),
  });
  await panel.getByRole("button", { name: "Review CSV" }).click();

  await expect(panel.getByRole("heading", { name: "Dry-run preview" })).toBeVisible();
  await expect(panel.getByText("Ready to prepare")).toBeVisible();
  expect(api.importJob, "A dry run must not create an import job").toBeNull();
  const dryRunCall = api.calls.find(
    (call) => call.path === "/api/v1/imports/products/" && String(call.body).includes('name="dry_run"\r\n\r\ntrue'),
  );
  expect(dryRunCall).toBeTruthy();

  await panel.getByRole("button", { name: "Prepare import" }).click();
  await expect(panel.getByRole("heading", { name: "Snapshot prepared" })).toBeVisible();
  await expect(panel.getByText("Ready to confirm")).toBeVisible();
  expect(api.importJob?.status).toBe("READY");
  expect(api.calls.some((call) => call.path === "/api/v1/imports/import-1/confirm/")).toBe(false);

  await panel.getByRole("button", { name: "Confirm import" }).click();
  await expect(panel.getByRole("heading", { name: "Import confirmed" })).toBeVisible();
  expect(api.importJob?.status).toBe("COMPLETED");
  const confirmCall = api.calls.find(
    (call) => call.path === "/api/v1/imports/import-1/confirm/" && call.method === "POST",
  );
  expect(confirmCall?.body).toEqual({ idempotency_key: "import-import-1" });
});
