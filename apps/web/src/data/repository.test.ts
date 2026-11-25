import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import {
  acceptInvitation,
  cancelReminder,
  confirmCommand,
  confirmCsvImport,
  connectGmail,
  createCsvImportJob,
  createInvitation,
  createPayment,
  createReminder,
  disconnectGmail,
  downloadSaleInvoicePdf,
  dryRunCsvImport,
  getAuthCapabilities,
  getDashboard,
  getEntries,
  getGmailMessages,
  getOpenDocuments,
  getParties,
  getParty,
  getPaymentAllocationReview,
  getProducts,
  getValuationReport,
  importGmailReceipt,
  interpretCommand,
  listInvitations,
  listNotificationDevices,
  listReminders,
  MAX_RECEIPT_BYTES,
  pollAssistantProposal,
  reallocatePayment,
  registerNotificationDevice,
  revokeAllSessions,
  revokeInvitation,
  unregisterNotificationDevice,
  updateReminder,
  uploadReceiptAttachment,
} from "./repository";
import { emptyResponse, jsonResponse, mockApi, requestBody } from "../test/apiMocks";

describe("web repository API contracts", () => {
  beforeEach(() => localStorage.clear());
  afterEach(() => vi.unstubAllGlobals());

  it("maps explicit dashboard minor units without multiplying and preserves null profit", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/reports/dashboard/": () => jsonResponse({
        as_of: "2026-11-24",
        today: { sales_minor: 123456, expenses_minor: 7890, sales: 999 },
        books: {
          receipts_minor: 45678,
          receivable_minor: 23456,
          payable_minor: 34567,
          cash_flow_minor: -12345,
          receipts: 999,
        },
        low_stock_count: 7,
        gross_profit_minor: null,
        summary: "A grounded daily summary.",
      }),
    }));

    await expect(getDashboard("b1", "l1")).resolves.toEqual({
      asOf: "2026-11-24",
      salesMinor: 123456,
      collectionsMinor: 45678,
      expensesMinor: 7890,
      cashFlowMinor: -12345,
      receivableMinor: 23456,
      payableMinor: 34567,
      lowStockCount: 7,
      grossProfitMinor: null,
      summary: "A grounded daily summary.",
    });
  });

  it("loads only cashier-safe entry collections when requested", async () => {
    const fetchMock = mockApi({
      "GET /api/v1/sales/": () => jsonResponse([{
        id: "s1", number: "S-1", status: "POSTED", customer: { name: "Ramesh" },
        grand_total_minor: 120000, due_total_minor: 0, posted_at: "2026-11-24T10:00:00Z",
      }]),
      "GET /api/v1/payments/": () => jsonResponse([{
        id: "payment1", reference: "R-1", status: "POSTED", direction: "RECEIPT",
        party: { name: "Ramesh" }, amount_minor: 5000, payment_date: "2026-11-24T09:00:00Z",
      }]),
    });
    vi.stubGlobal("fetch", fetchMock);

    await expect(getEntries("b1", "l1", ["SALE", "PAYMENT_IN"])).resolves.toMatchObject([
      { kind: "SALE", number: "S-1" },
      { kind: "PAYMENT_IN", number: "R-1" },
    ]);
    expect(fetchMock.mock.calls.some(([input]) => String(input).includes("/api/v1/purchases/"))).toBe(false);
    expect(fetchMock.mock.calls.some(([input]) => String(input).includes("/api/v1/expenses/"))).toBe(false);
  });

  it("redacts wholesale prices and supplier parties for cashier lookups", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/products/": () => jsonResponse({
        results: [{
          id: "p1", name: "Shirt", base_unit: "PIECE",
          packs: [{ id: "pack1", retail_price_minor: 120000, wholesale_price_minor: 90000 }],
        }],
      }),
      "GET /api/v1/parties/": () => jsonResponse({
        results: [
          { id: "customer", name: "Ramesh", kind: "BOTH", receivable_minor: 1000, payable_minor: 9000, price_tier: "WHOLESALE" },
          { id: "supplier", name: "Sharma Suppliers", kind: "SUPPLIER", payable_minor: 5000 },
        ],
      }),
    }));

    await expect(getProducts("b1", "l1", { includeWholesalePrices: false })).resolves.toMatchObject([
      { retailPriceMinor: 120000, wholesalePriceMinor: 0 },
    ]);
    await expect(getParties("b1", { customersOnly: true })).resolves.toEqual([{
      id: "customer", name: "Ramesh", phone: undefined, kind: "CUSTOMER",
      receivableMinor: 1000, payableMinor: 0, priceTier: "RETAIL",
    }]);
  });

  it("uploads receipt bytes as multipart data and polls OCR into the existing proposal shape", async () => {
    const bytes = new Uint8Array([0xff, 0xd8, 0xff, 0xe0, 0x01, 0x02]);
    const file = new File([bytes], "receipt.jpg", { type: "image/jpeg" });
    let polls = 0;
    const fetchMock = mockApi({
      "POST /api/v1/assistant/attachments/upload/": (init) => {
        expect(init?.body).toBeInstanceOf(FormData);
        const body = init?.body as FormData;
        expect(body.get("business_id")).toBe("b1");
        expect(body.get("kind")).toBe("IMAGE");
        expect(body.get("mime")).toBe("image/jpeg");
        expect(body.get("size_bytes")).toBe(String(bytes.length));
        const uploaded = body.get("file");
        expect(uploaded).toBeInstanceOf(File);
        expect(new Headers(init?.headers).get("content-type")).toBeNull();
        return jsonResponse({
          id: "attachment1", business: "b1", kind: "IMAGE", mime: "image/jpeg",
          size_bytes: bytes.length, status: "READY",
        }, 201);
      },
      "POST /api/v1/assistant/proposals/from-image/": (init) => {
        expect(requestBody(init)).toEqual({
          attachment_id: "attachment1", business_id: "b1", location_id: "l1", locale: "en-IN",
        });
        return jsonResponse({
          id: "proposal1", version: 1, status: "DRAFT", command_type: "UNSUPPORTED",
          content: "", payload: {}, blocking_questions: ["Your image or PDF is being read."],
        }, 201);
      },
      "GET /api/v1/assistant/proposals/proposal1/": () => {
        polls += 1;
        if (polls === 1) {
          return jsonResponse({
            id: "proposal1", version: 1, status: "DRAFT", command_type: "UNSUPPORTED",
            content: "", payload: {}, blocking_questions: ["Your image or PDF is being read."],
          });
        }
        return jsonResponse({
          id: "proposal1", version: 2, status: "READY", command_type: "SALE",
          content: "Sold one shirt to Ramesh",
          payload: {
            customer_id: "customer1",
            lines: [{ pack_id: "pack1", quantity: "1", unit_price_minor: 120000 }],
            grand_total_minor: 120000,
            paid_amount_minor: 120000,
          },
          warnings: ["Check the recognized text before confirming."],
          blocking_questions: [],
        });
      },
      "GET /api/v1/products/": () => jsonResponse({
        results: [{ id: "product1", name: "Shirt", base_unit: "PIECE", packs: [{ id: "pack1" }] }],
      }),
      "GET /api/v1/parties/": () => jsonResponse({
        results: [{ id: "customer1", name: "Ramesh", kind: "CUSTOMER" }],
      }),
    });
    vi.stubGlobal("fetch", fetchMock);

    const attachment = await uploadReceiptAttachment({ businessId: "b1", file });
    expect(attachment).toMatchObject({ id: "attachment1", status: "READY", sizeBytes: bytes.length });
    const uploaded = (fetchMock.mock.calls[0][1]?.body as FormData).get("file") as File;
    const uploadedBytes = await new Promise<ArrayBuffer>((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result as ArrayBuffer);
      reader.onerror = () => reject(reader.error);
      reader.readAsArrayBuffer(uploaded);
    });
    expect(new Uint8Array(uploadedBytes)).toEqual(bytes);

    const pending = await pollAssistantProposal({
      proposalId: "proposal1", businessId: "b1", locationId: "l1", intervalMs: 0,
    });
    expect(polls).toBe(2);
    expect(pending).toMatchObject({
      commandType: "SALE", status: "READY", partyName: "Ramesh", totalMinor: 120000,
      lines: [{ productName: "Shirt", quantity: "1", unitPriceMinor: 120000 }],
    });
  });

  it("rejects unsupported and oversized receipt files before uploading", async () => {
    const fetchMock = mockApi({});
    vi.stubGlobal("fetch", fetchMock);

    await expect(uploadReceiptAttachment({
      businessId: "b1",
      file: new File(["text"], "receipt.txt", { type: "text/plain" }),
    })).rejects.toThrow(/JPEG, PNG, or PDF/i);
    await expect(uploadReceiptAttachment({
      businessId: "b1",
      file: new File([new Uint8Array(MAX_RECEIPT_BYTES + 1)], "large.pdf", { type: "application/pdf" }),
    })).rejects.toThrow(/8 MB/i);
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("uses stock_quantity, including zero, before legacy quantity fields", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/products/": () => jsonResponse({
        results: [
          {
            id: "p1",
            name: "Shirt",
            sku: "SHIRT",
            base_unit: "PIECE",
            stock_quantity: "12.500",
            on_hand: "999",
            low_stock_threshold: "5",
            tax_rate_bps: 1800,
            packs: [{ id: "pack1", retail_price_minor: 120000, wholesale_price_minor: 90000 }],
          },
          {
            id: "p2",
            name: "Soap",
            base_unit: "PIECE",
            stock_quantity: "0",
            quantity_on_hand: "50",
            low_stock_threshold: "3",
            packs: [],
          },
          {
            id: "p3",
            name: "Legacy item",
            base_unit: "PIECE",
            quantity_on_hand: "4",
            packs: [],
          },
        ],
      }),
    }));

    const products = await getProducts("b1", "l1");
    expect(products.map((product) => product.onHand)).toEqual(["12.500", "0", "4"]);
    expect(products[0]).toMatchObject({ packId: "pack1", reorderLevel: "5", retailPriceMinor: 120000 });
  });

  it("maps party balances and phone_e164 on list and detail responses", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/parties/": () => jsonResponse({
        results: [{
          id: "party1",
          name: "Ramesh",
          kind: "BOTH",
          phone_e164: "+919876543210",
          receivable_minor: 12345,
          payable_minor: 6789,
          price_tier: "WHOLESALE",
        }],
      }),
      "GET /api/v1/parties/party1/": () => jsonResponse({
        id: "party1",
        name: "Ramesh",
        kind: "BOTH",
        phone_e164: "+919876543210",
        receivable_minor: 12345,
        payable_minor: 6789,
        price_tier: "WHOLESALE",
      }),
    }));

    const expected = {
      id: "party1",
      name: "Ramesh",
      phone: "+919876543210",
      kind: "BOTH",
      receivableMinor: 12345,
      payableMinor: 6789,
      priceTier: "WHOLESALE",
    };
    await expect(getParties("b1")).resolves.toEqual([expected]);
    await expect(getParty("b1", "party1")).resolves.toEqual(expected);
  });

  it("loads only posted, outstanding documents for the selected party and direction", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/sales/": () => jsonResponse([
        { id: "s1", number: "S-1", status: "POSTED", customer_id: "c1", grand_total_minor: 10000, due_total_minor: 2500 },
        { id: "s2", number: "S-2", status: "POSTED", customer_id: "c2", grand_total_minor: 10000, due_total_minor: 2500 },
        { id: "s3", number: "S-3", status: "POSTED", customer_id: "c1", grand_total_minor: 10000, due_total_minor: 0 },
        { id: "s4", number: "S-4", status: "REVERSED", customer_id: "c1", grand_total_minor: 10000, due_total_minor: 2500 },
      ]),
      "GET /api/v1/purchases/": () => jsonResponse([
        { id: "p1", number: "P-1", status: "POSTED", supplier_id: "vendor1", grand_total_minor: 20000, due_total_minor: 5000 },
      ]),
    }));

    await expect(getOpenDocuments("b1", "l1", "c1", "RECEIPT")).resolves.toMatchObject([
      { id: "s1", kind: "SALE", partyId: "c1", outstandingMinor: 2500 },
    ]);
    await expect(getOpenDocuments("b1", "l1", "vendor1", "PAYMENT")).resolves.toMatchObject([
      { id: "p1", kind: "PURCHASE", partyId: "vendor1", outstandingMinor: 5000 },
    ]);
  });

  it("sends sale_id for receipts and purchase_id for supplier payments", async () => {
    const fetchMock = mockApi({
      "POST /api/v1/payments/": () => jsonResponse({ id: "payment1" }, 201),
    });
    vi.stubGlobal("fetch", fetchMock);

    await createPayment({ businessId: "b1", locationId: "l1", partyId: "c1", direction: "RECEIPT", saleId: "s1", amountMinor: 1000 });
    await createPayment({ businessId: "b1", locationId: "l1", partyId: "v1", direction: "PAYMENT", purchaseId: "p1", amountMinor: 2000 });

    const bodies = fetchMock.mock.calls.map(([, init]) => requestBody(init));
    expect(bodies[0]).toMatchObject({ direction: "RECEIPT", sale_id: "s1", amount_minor: 1000 });
    expect(bodies[0]).not.toHaveProperty("purchase_id");
    expect(bodies[1]).toMatchObject({ direction: "PAYMENT", purchase_id: "p1", amount_minor: 2000 });
    expect(bodies[1]).not.toHaveProperty("sale_id");
  });

  it("maps purchase assistant lines and supplier fields, then confirms as a purchase", async () => {
    const fetchMock = mockApi({
      "POST /api/v1/assistant/proposals/": () => jsonResponse({
        id: "proposal1",
        version: 2,
        status: "READY",
        command_type: "PURCHASE",
        content: "Bought 2.5 metres from supplier for ₹4,000 each",
        payload: {
          supplier_id: "vendor1",
          new_supplier_name: "",
          lines: [{ pack_id: "pack1", quantity: "2.5", unit_cost_minor: 4000 }],
          paid_amount_minor: 1500,
          tax_amount_minor: 0,
        },
        warnings: [],
        blocking_questions: [],
      }, 201),
      "GET /api/v1/products/": () => jsonResponse({
        results: [{ id: "product1", name: "Fabric", base_unit: "METRE", stock_quantity: "10", packs: [{ id: "pack1" }] }],
      }),
      "GET /api/v1/parties/": () => jsonResponse({
        results: [{ id: "vendor1", name: "Sharma Suppliers", kind: "SUPPLIER", payable_minor: 500 }],
      }),
      "POST /api/v1/assistant/proposals/proposal1/confirm/": () => jsonResponse({
        proposal: { confirmed_result_type: "operations.purchase" },
        result: {
          id: "purchase1",
          number: "P-1",
          status: "POSTED",
          grand_total_minor: 10000,
          due_total_minor: 8500,
          posted_at: "2026-11-24T10:00:00Z",
        },
      }),
    });
    vi.stubGlobal("fetch", fetchMock);

    const proposal = await interpretCommand("b1", "l1", "Bought fabric");
    expect(proposal).toMatchObject({
      commandType: "PURCHASE",
      intent: "RECORD_PURCHASE",
      partyId: "vendor1",
      partyName: "Sharma Suppliers",
      totalMinor: 10000,
      paidMinor: 1500,
      outstandingMinor: 8500,
      lines: [{ productName: "Fabric", quantity: "2.5", unitPriceMinor: 4000, lineTotalMinor: 10000 }],
      effects: { stock: ["Increase Fabric stock by 2.5 metre"] },
    });

    await expect(confirmCommand("b1", proposal)).resolves.toMatchObject({
      id: "purchase1",
      kind: "PURCHASE",
      totalMinor: 10000,
      outstandingMinor: 8500,
    });
  });

  it("preserves expense commands and treats an expense as paid with no stock effect", async () => {
    vi.stubGlobal("fetch", mockApi({
      "POST /api/v1/assistant/proposals/": () => jsonResponse({
        id: "proposal2",
        version: 1,
        status: "READY",
        command_type: "EXPENSE",
        payload: { category: "Electricity", payee: "Power board", amount_minor: 250000 },
        warnings: [],
        blocking_questions: [],
      }, 201),
      "GET /api/v1/products/": () => jsonResponse([]),
      "GET /api/v1/parties/": () => jsonResponse([]),
      "POST /api/v1/assistant/proposals/proposal2/confirm/": () => jsonResponse({
        result: { id: "expense1", number: "E-1", total_minor: 250000, status: "POSTED" },
      }),
    }));

    const proposal = await interpretCommand("b1", "l1", "Paid electricity ₹2,500");
    expect(proposal).toMatchObject({
      commandType: "EXPENSE",
      intent: "RECORD_EXPENSE",
      partyName: "Power board",
      totalMinor: 250000,
      paidMinor: 250000,
      outstandingMinor: 0,
      lines: [],
      effects: { stock: [] },
    });
    await expect(confirmCommand("b1", proposal)).resolves.toMatchObject({ kind: "EXPENSE", totalMinor: 250000, outstandingMinor: 0 });
  });

  it("never produces NaN totals from malformed assistant quantities or prices", async () => {
    vi.stubGlobal("fetch", mockApi({
      "POST /api/v1/assistant/proposals/": () => jsonResponse({
        id: "proposal3",
        version: 1,
        status: "DRAFT",
        command_type: "SALE",
        payload: { lines: [{ pack_id: "missing", quantity: "not-a-number", unit_price_minor: "invalid" }] },
      }, 201),
      "GET /api/v1/products/": () => jsonResponse([]),
      "GET /api/v1/parties/": () => jsonResponse([]),
    }));

    const proposal = await interpretCommand("b1", "l1", "malformed");
    expect(proposal.status).toBe("NEEDS_DETAILS");
    expect(proposal.totalMinor).toBe(0);
    expect(proposal.lines[0]).toMatchObject({ quantity: "0", unitPriceMinor: 0, lineTotalMinor: 0 });
    expect(Number.isNaN(proposal.outstandingMinor)).toBe(false);
  });

  it("maps Gmail review-only endpoints without implying a ledger posting", async () => {
    const fetchMock = mockApi({
      "GET /api/v1/integrations/gmail/connect/": () => jsonResponse({ authorization_url: "https://accounts.google.com/o/oauth" }),
      "GET /api/v1/integrations/gmail/messages/": () => jsonResponse({
        results: [{ id: "m1", subject: "Invoice 42", snippet: "Thanks for your payment", received_at: "2026-11-24T09:00:00Z" }],
      }),
      "POST /api/v1/integrations/gmail/import/": () => jsonResponse({
        import_id: "import1",
        status: "READY_FOR_REVIEW",
        extracted: { kind: "SALE", direction: "INCOMING", party_name: "Ramesh", amount_minor: 120000, reference: "INV-42", confidence: 0.92 },
        preview: "Sale receipt from Ramesh",
      }),
      "DELETE /api/v1/integrations/gmail/": () => emptyResponse(),
    });
    vi.stubGlobal("fetch", fetchMock);

    await expect(connectGmail()).resolves.toEqual({ authorizationUrl: "https://accounts.google.com/o/oauth" });
    await expect(getGmailMessages()).resolves.toMatchObject([{ id: "m1", subject: "Invoice 42", receivedAt: "2026-11-24T09:00:00Z" }]);
    await expect(importGmailReceipt({ messageId: "m1", businessId: "b1", locationId: "l1" })).resolves.toMatchObject({
      importId: "import1",
      status: "READY_FOR_REVIEW",
      extracted: { kind: "SALE", amountMinor: 120000, confidence: 0.92 },
      preview: "Sale receipt from Ramesh",
    });
    const importCall = fetchMock.mock.calls.find(([input]) => String(input).endsWith("/api/v1/integrations/gmail/import/"));
    expect(requestBody(importCall?.[1])).toEqual({ message_id: "m1", business_id: "b1", location_id: "l1" });
    await disconnectGmail();
  });

  it("maps auth capabilities including the separate dev OTP flag", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/auth/capabilities/": () => jsonResponse({ password: true, otp: true, dev_otp: false }),
    }));
    await expect(getAuthCapabilities()).resolves.toEqual({ password: true, otp: true, devOtp: false });
  });

  it("keeps CSV dry-run, snapshot preparation, and confirmation as separate requests", async () => {
    const file = new File(["name,sku\nShirt,SHIRT\n"], "catalog.csv", { type: "text/csv" });
    const fetchMock = mockApi({
      "POST /api/v1/imports/products/": (init) => {
        const body = init?.body as FormData;
        expect(body.get("business_id")).toBe("b1");
        expect(body.get("duplicate_strategy")).toBe("UPDATE");
        expect((body.get("file") as File).name).toBe("catalog.csv");
        if (body.get("dry_run") === "true") {
          return jsonResponse({
            dry_run: true, kind: "PRODUCT", duplicate_strategy: "UPDATE",
            row_count: 2, valid_row_count: 1, error_count: 1,
            created_count: 1, updated_count: 0, skipped_count: 0,
            errors: [{ row: 3, errors: { gst_bps: ["Enter a whole number."] } }],
            preview: [{ row: 2, action: "CREATE" }],
          });
        }
        expect(body.get("dry_run")).toBe("false");
        return jsonResponse({
          id: "job1", business: "b1", kind: "PRODUCT", status: "READY", duplicate_strategy: "UPDATE",
          row_count: 2, valid_row_count: 1, error_count: 1, created_count: 0, updated_count: 0, skipped_count: 0,
          errors: [{ row: 3, errors: { gst_bps: ["Enter a whole number."] } }], original_filename: "catalog.csv",
        }, 201);
      },
      "POST /api/v1/imports/job1/confirm/": (init) => {
        expect(new Headers(init?.headers).get("idempotency-key")).toBe("import:job1");
        expect(requestBody(init)).toEqual({ idempotency_key: "import:job1" });
        return jsonResponse({
          replayed: false,
          job: {
            id: "job1", business: "b1", kind: "PRODUCT", status: "COMPLETED", duplicate_strategy: "UPDATE",
            row_count: 2, valid_row_count: 1, error_count: 1, created_count: 1, updated_count: 0, skipped_count: 0,
            errors: [{ row: 3, errors: { gst_bps: ["Enter a whole number."] } }], original_filename: "catalog.csv",
          },
        });
      },
    });
    vi.stubGlobal("fetch", fetchMock);

    await expect(dryRunCsvImport({ businessId: "b1", kind: "PRODUCT", file, duplicateStrategy: "UPDATE" })).resolves.toEqual({
      dryRun: true, kind: "PRODUCT", duplicateStrategy: "UPDATE",
      rowCount: 2, validRowCount: 1, errorCount: 1, createdCount: 1, updatedCount: 0, skippedCount: 0,
      errors: [{ row: 3, errors: { gstBps: ["Enter a whole number."] } }],
      preview: [{ row: 2, action: "CREATE" }],
    });
    await expect(createCsvImportJob({ businessId: "b1", kind: "PRODUCT", file, duplicateStrategy: "UPDATE" })).resolves.toMatchObject({ id: "job1", status: "READY", originalFilename: "catalog.csv" });
    await expect(confirmCsvImport("job1", "import:job1")).resolves.toMatchObject({ replayed: false, job: { status: "COMPLETED", createdCount: 1 } });
    expect(fetchMock).toHaveBeenCalledTimes(3);
  });

  it("downloads invoice PDFs as binary files with the server filename", async () => {
    const fetchMock = mockApi({
      "GET /api/v1/invoices/sales/sale1/pdf/": (init) => {
        expect(new Headers(init?.headers).get("accept")).toBe("application/pdf");
        return Promise.resolve(new Response("%PDF-1.7 invoice", {
          status: 200,
          headers: { "Content-Type": "application/pdf", "Content-Disposition": 'attachment; filename="INV-1.pdf"' },
        }));
      },
    });
    vi.stubGlobal("fetch", fetchMock);

    const download = await downloadSaleInvoicePdf("sale1");
    expect(download.filename).toBe("INV-1.pdf");
    expect(download.blob.type).toBe("application/pdf");
    await expect(download.blob.text()).resolves.toContain("%PDF-1.7");
  });

  it("maps weighted-average valuation without fabricating missing costs or profit", async () => {
    const fetchMock = mockApi({
      "GET /api/v1/reports/valuation/": () => {
        return jsonResponse({
          inventory: { total_quantity: "7", average_cost_minor: null, total_value_minor: null, known_value_minor: 0, costing_complete: false },
          sales: { posted_sale_count: 1, line_count: 1, net_sales_minor: 20000, cogs_minor: 0, gross_profit_minor: null, missing_cost_line_count: 1, costing_complete: false },
          results: [{ product_id: "p1", name: "Shirt", unit: "PIECE", quantity: "7", average_cost_minor: null, total_value_minor: null, known_value_minor: 0, unknown_cost_quantity: "7", costing_complete: false }],
        });
      },
    });
    vi.stubGlobal("fetch", fetchMock);

    const report = await getValuationReport("b1", "l1", { dateFrom: "2026-11-01", dateTo: "2026-11-24" });
    expect(report.inventory).toMatchObject({ totalValueMinor: null, knownValueMinor: 0, costingComplete: false });
    expect(report.sales).toMatchObject({ grossProfitMinor: null, missingCostLineCount: 1 });
    expect(report.results[0]).toMatchObject({ averageCostMinor: null, unknownCostQuantity: "7" });
    expect(fetchMock.mock.calls[0][0]).toContain("date_from=2026-11-01");
    expect(fetchMock.mock.calls[0][0]).toContain("date_to=2026-11-24");
  });

  it("maps allocation review and sends an idempotent full-payment reallocation plan", async () => {
    const fetchMock = mockApi({
      "GET /api/v1/payments/allocation-review/": () => jsonResponse({
        results: [{
          id: "payment1", business: "b1", location: "l1", party: "party1", direction: "RECEIPT", method: "CASH",
          amount_minor: 15000, reference: "R-1", payment_date: "2026-11-24", status: "POSTED",
          allocated_total_minor: 15000, unallocated_total_minor: 0,
          allocations: [{ id: "a1", sale: "sale1", amount_minor: 15000, document_type: "SALE", document_id: "sale1", document_number: "S-1", document_total_minor: 30000, document_paid_total_minor: 15000, document_due_total_minor: 15000 }],
        }],
        totals: { payment_count: 1, payment_total_minor: 15000, allocated_total_minor: 15000, unallocated_total_minor: 0, outstanding_document_count: 1, outstanding_total_minor: 15000 },
        outstanding_documents: [{ document_type: "SALE", document_id: "sale1", number: "S-1", document_date: "2026-11-24", party_id: "party1", party_name: "Ramesh", grand_total_minor: 30000, paid_total_minor: 15000, due_total_minor: 15000 }],
      }),
      "POST /api/v1/payments/payment1/reallocate/": (init) => {
        expect(new Headers(init?.headers).get("idempotency-key")).toBe("reallocate:payment1:1");
        expect(requestBody(init)).toEqual({
          reason: "Correct invoice",
          idempotency_key: "reallocate:payment1:1",
          allocations: [
            { document_type: "SALE", document_id: "sale1", amount_minor: 10000 },
            { document_type: "SALE", document_id: "sale2", amount_minor: 5000 },
          ],
        });
        return jsonResponse({ id: "payment1", amount_minor: 15000, allocated_total_minor: 15000, unallocated_total_minor: 0, allocations: [] });
      },
    });
    vi.stubGlobal("fetch", fetchMock);

    const review = await getPaymentAllocationReview("b1", "l1", { direction: "RECEIPT", partyId: "party1" });
    expect(review.payments[0]).toMatchObject({ allocatedTotalMinor: 15000, unallocatedTotalMinor: 0, allocations: [{ documentId: "sale1", amountMinor: 15000 }] });
    expect(review.outstandingDocuments[0]).toMatchObject({ dueTotalMinor: 15000, partyName: "Ramesh" });
    await expect(reallocatePayment({
      paymentId: "payment1",
      allocations: [{ documentType: "SALE", documentId: "sale1", amountMinor: 10000 }, { documentType: "SALE", documentId: "sale2", amountMinor: 5000 }],
      reason: "Correct invoice",
      idempotencyKey: "reallocate:payment1:1",
    })).resolves.toMatchObject({ id: "payment1", allocatedTotalMinor: 15000 });
  });

  it("maps invitation create/list/revoke/accept without persisting the one-time token", async () => {
    const invitation = {
      id: "invite1", business: "b1", invitee_phone: "+919876543210", role: "CASHIER", locations: ["l1"],
      status: "PENDING", expires_at: "2026-12-01T10:00:00Z", inviter: "owner1",
    };
    const fetchMock = mockApi({
      "POST /api/v1/invitations/": (init) => {
        expect(requestBody(init)).toEqual({ business: "b1", invitee_phone: "+919876543210", role: "CASHIER", locations: ["l1"] });
        return jsonResponse({ ...invitation, token: "one-time-token-that-is-long-enough" }, 201);
      },
      "GET /api/v1/invitations/": () => jsonResponse([invitation]),
      "POST /api/v1/invitations/invite1/revoke/": () => jsonResponse({ ...invitation, status: "REVOKED" }),
      "POST /api/v1/invitations/accept/": (init) => {
        expect(requestBody(init)).toEqual({ token: "one-time-token-that-is-long-enough" });
        return jsonResponse({ ...invitation, status: "ACCEPTED", accepted_by: "invitee1" });
      },
    });
    vi.stubGlobal("fetch", fetchMock);

    await expect(createInvitation({ business: "b1", inviteePhone: "+919876543210", role: "CASHIER", locations: ["l1"] })).resolves.toMatchObject({ token: "one-time-token-that-is-long-enough", inviteePhone: "+919876543210" });
    const listed = await listInvitations("b1");
    expect(listed[0]).not.toHaveProperty("token");
    await expect(revokeInvitation("invite1")).resolves.toMatchObject({ status: "REVOKED" });
    await expect(acceptInvitation("one-time-token-that-is-long-enough")).resolves.toMatchObject({ status: "ACCEPTED", acceptedBy: "invitee1" });
  });

  it("maps session revocation and notification device/reminder CRUD contracts", async () => {
    const fetchMock = mockApi({
      "POST /api/v1/auth/sessions/revoke-all/": (init) => {
        expect(requestBody(init)).toEqual({ password: "CurrentPass123!" });
        return jsonResponse({ detail: "All sessions have been revoked.", token_version: 2 });
      },
      "GET /api/v1/integrations/notifications/devices/": () => jsonResponse([{ id: "device1", business: "b1", location: "l1", platform: "WEB", status: "ACTIVE", token_suffix: "…1234", last_seen_at: "2026-11-24T10:00:00Z", metadata: {} }]),
      "POST /api/v1/integrations/notifications/devices/": (init) => {
        expect(requestBody(init)).toMatchObject({ business_id: "b1", location_id: "l1", platform: "WEB", metadata: { source: "web-console" } });
        expect(requestBody(init).fcm_token).toBe("private-fcm-token");
        return jsonResponse({ id: "device1", business: "b1", location: "l1", platform: "WEB", status: "ACTIVE", token_suffix: "…oken", last_seen_at: "2026-11-24T10:00:00Z", metadata: {} }, 201);
      },
      "DELETE /api/v1/integrations/notifications/devices/device1/": () => emptyResponse(),
      "GET /api/v1/integrations/notifications/reminders/": () => jsonResponse([{ id: "reminder1", business: "b1", location: "l1", kind: "USER", title: "Stock check", body: "Count shirts", scheduled_at: "2026-11-25T10:00:00Z", status: "SCHEDULED", dedupe_key: "web-1", data: {}, metadata: {}, last_error: "" }]),
      "POST /api/v1/integrations/notifications/reminders/": (init) => {
        expect(requestBody(init)).toEqual({ business_id: "b1", location_id: "l1", title: "Stock check", body: "Count shirts", scheduled_at: "2026-11-25T10:00:00Z", dedupe_key: "web-1" });
        return jsonResponse({ id: "reminder1", business: "b1", location: "l1", kind: "USER", title: "Stock check", body: "Count shirts", scheduled_at: "2026-11-25T10:00:00Z", status: "SCHEDULED", dedupe_key: "web-1", data: {}, metadata: {} }, 201);
      },
      "PATCH /api/v1/integrations/notifications/reminders/reminder1/": (init) => {
        expect(requestBody(init)).toEqual({ title: "Stock check updated", scheduled_at: "2026-11-26T10:00:00Z" });
        return jsonResponse({ id: "reminder1", business: "b1", kind: "USER", title: "Stock check updated", body: "Count shirts", scheduled_at: "2026-11-26T10:00:00Z", status: "SCHEDULED", dedupe_key: "web-1", data: {}, metadata: {} });
      },
      "DELETE /api/v1/integrations/notifications/reminders/reminder1/": () => emptyResponse(),
    });
    vi.stubGlobal("fetch", fetchMock);

    await expect(revokeAllSessions("CurrentPass123!")).resolves.toEqual({ detail: "All sessions have been revoked.", tokenVersion: 2 });
    await expect(listNotificationDevices()).resolves.toMatchObject([{ tokenSuffix: "…1234", status: "ACTIVE" }]);
    await expect(registerNotificationDevice({ businessId: "b1", locationId: "l1", fcmToken: "private-fcm-token", platform: "WEB" })).resolves.toMatchObject({ id: "device1" });
    await unregisterNotificationDevice("device1");
    await expect(listReminders()).resolves.toMatchObject([{ title: "Stock check", status: "SCHEDULED" }]);
    await expect(createReminder({ businessId: "b1", locationId: "l1", title: "Stock check", body: "Count shirts", scheduledAt: "2026-11-25T10:00:00Z", dedupeKey: "web-1" })).resolves.toMatchObject({ id: "reminder1" });
    await expect(updateReminder("reminder1", { title: "Stock check updated", scheduledAt: "2026-11-26T10:00:00Z" })).resolves.toMatchObject({ title: "Stock check updated" });
    await cancelReminder("reminder1");
  });
});
