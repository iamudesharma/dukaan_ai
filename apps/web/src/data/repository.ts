import { apiRequest, newIdempotencyKey } from "../lib/api";
import { demoMode } from "../lib/supabase";
import type {
  AssistantProposal,
  Bootstrap,
  DashboardSummary,
  Entry,
  ManualSaleInput,
  Party,
  Product,
} from "../types";
import {
  confirmDemoProposal,
  demoBootstrap,
  demoDashboard,
  getDemoState,
  interpretDemoCommand,
} from "./demo";

const delay = (milliseconds = 180) => new Promise((resolve) => setTimeout(resolve, milliseconds));

function minorFrom(record: Record<string, unknown>, minorKey: string, majorKey: string): number {
  const minor = record[minorKey];
  if (minor !== undefined && minor !== null) return Number(minor);
  const major = record[majorKey];
  return Math.round(Number(major ?? 0) * 100);
}

function recordList(value: unknown): Record<string, unknown>[] {
  if (Array.isArray(value)) return value as Record<string, unknown>[];
  if (value && typeof value === "object") {
    const results = (value as Record<string, unknown>).results;
    if (Array.isArray(results)) return results as Record<string, unknown>[];
  }
  return [];
}

export async function getBootstrap(): Promise<Bootstrap> {
  if (demoMode) {
    await delay();
    return demoBootstrap;
  }
  return apiRequest<Bootstrap>("/api/v1/bootstrap/");
}

export async function getDashboard(
  businessId: string,
  locationId: string,
): Promise<DashboardSummary> {
  if (demoMode) {
    await delay();
    return demoDashboard();
  }
  const params = new URLSearchParams({ location_id: locationId });
  const raw = await apiRequest<Record<string, unknown>>(
    `/api/v1/reports/dashboard/?business_id=${businessId}&${params}`,
  );
  const today = (raw.today ?? {}) as Record<string, unknown>;
  const books = (raw.books ?? {}) as Record<string, unknown>;
  return {
    asOf: String(raw.asOf ?? new Date().toISOString()),
    salesMinor: minorFrom(today, "salesMinor", "sales"),
    collectionsMinor: minorFrom(books, "receiptsMinor", "receipts"),
    expensesMinor: minorFrom(today, "expensesMinor", "expenses"),
    receivableMinor: minorFrom(books, "receivableMinor", "receivable"),
    payableMinor: minorFrom(books, "payableMinor", "payable"),
    lowStockCount: Number(raw.lowStockCount ?? 0),
    grossProfitMinor: minorFrom(books, "grossProfitMinor", "grossProfit"),
    summary: String(raw.summary ?? "Your figures are based on posted entries for this location."),
  };
}

export async function getEntries(businessId: string, locationId: string): Promise<Entry[]> {
  if (demoMode) {
    await delay();
    return getDemoState().entries;
  }
  const params = new URLSearchParams({ business_id: businessId, location_id: locationId });
  const [sales, purchases, payments, expenses] = await Promise.all([
    apiRequest<unknown>(`/api/v1/sales/?${params}`),
    apiRequest<unknown>(`/api/v1/purchases/?${params}`),
    apiRequest<unknown>(`/api/v1/payments/?${params}`),
    apiRequest<unknown>(`/api/v1/expenses/?${params}`),
  ]);
  const convert = (rows: Record<string, unknown>[], kind: Entry["kind"]): Entry[] => rows.map((row) => {
    const party = (row.customer ?? row.supplier ?? row.party) as Record<string, unknown> | string | undefined;
    const partyName = typeof party === "object" ? String(party.name ?? "") : "";
    const totalMinor = kind === "EXPENSE"
      ? minorFrom(row, "totalMinor", "total")
      : kind === "PAYMENT_IN" || kind === "PAYMENT_OUT"
        ? minorFrom(row, "amountMinor", "amount")
        : minorFrom(row, "grandTotalMinor", "grandTotal");
    return {
      id: String(row.id),
      number: String(row.number ?? row.reference ?? "—"),
      kind,
      partyName: partyName || String(row.partyName ?? "Cash customer"),
      occurredAt: String(row.postedAt ?? row.paymentDate ?? row.createdAt ?? new Date().toISOString()),
      totalMinor,
      outstandingMinor: minorFrom(row, "dueTotalMinor", "dueTotal"),
      status: String(row.status ?? "POSTED") as Entry["status"],
      paymentMode: String(row.method ?? row.paymentMethod ?? "") || undefined,
    };
  });
  const paymentRows = recordList(payments);
  return [
    ...convert(recordList(sales), "SALE"),
    ...convert(recordList(purchases), "PURCHASE"),
    ...convert(paymentRows.filter((row) => row.direction === "RECEIPT"), "PAYMENT_IN"),
    ...convert(paymentRows.filter((row) => row.direction !== "RECEIPT"), "PAYMENT_OUT"),
    ...convert(recordList(expenses), "EXPENSE"),
  ].sort((a, b) => b.occurredAt.localeCompare(a.occurredAt));
}

export async function getProducts(businessId: string, locationId: string): Promise<Product[]> {
  if (demoMode) {
    await delay();
    return getDemoState().products;
  }
  const params = new URLSearchParams({ business_id: businessId, location_id: locationId });
  const response = await apiRequest<unknown>(`/api/v1/products/?${params}`);
  return recordList(response).map((row) => {
    const packs = Array.isArray(row.packs) ? row.packs as Record<string, unknown>[] : [];
    const pack = packs[0] ?? {};
    return {
      id: String(row.id),
      packId: String(pack.id ?? row.defaultPackId ?? row.id),
      name: String(row.name),
      sku: String(row.sku ?? ""),
      unit: String(row.baseUnit ?? row.unit ?? "PIECE").toLowerCase(),
      onHand: String(row.onHand ?? row.quantityOnHand ?? row.stock ?? "0"),
      reorderLevel: String(row.lowStockThreshold ?? row.reorderLevel ?? "0"),
      retailPriceMinor: minorFrom(pack, "retailPriceMinor", "retailPrice"),
      wholesalePriceMinor: minorFrom(pack, "wholesalePriceMinor", "wholesalePrice"),
      gstRateBps: row.taxRateBps !== undefined
        ? Number(row.taxRateBps)
        : Math.round(Number(row.taxRate ?? 0) * 100),
    };
  });
}

export async function getParties(businessId: string): Promise<Party[]> {
  if (demoMode) {
    await delay();
    return getDemoState().parties;
  }
  const response = await apiRequest<unknown>(`/api/v1/parties/?business_id=${businessId}`);
  return recordList(response).map((row) => ({
    id: String(row.id),
    name: String(row.name),
    phone: row.phoneE164 ? String(row.phoneE164) : undefined,
    kind: String(row.kind ?? "CUSTOMER") as Party["kind"],
    receivableMinor: minorFrom(row, "receivableMinor", "receivableBalance"),
    payableMinor: minorFrom(row, "payableMinor", "payableBalance"),
    priceTier: String(row.priceTier ?? "RETAIL") as Party["priceTier"],
  }));
}

export async function interpretCommand(
  businessId: string,
  locationId: string,
  text: string,
): Promise<AssistantProposal> {
  if (demoMode) {
    await delay(550);
    return interpretDemoCommand(text, locationId);
  }
  const raw = await apiRequest<Record<string, unknown>>(
    "/api/v1/assistant/proposals/",
    {
      method: "POST",
      body: { business_id: businessId, input_type: "TEXT", content: text, location_id: locationId, locale: "en-IN" },
    },
  );
  return mapProposal(raw, businessId, locationId, text);
}

export async function reviseCommand(
  businessId: string, proposal: AssistantProposal, text?: string,
): Promise<AssistantProposal> {
  if (demoMode) {
    const revised = interpretDemoCommand(text ?? proposal.sourceText, proposal.locationId);
    return { ...revised, id: proposal.id, version: proposal.version + 1 };
  }
  const raw = await apiRequest<Record<string, unknown>>(
    `/api/v1/assistant/proposals/${proposal.id}/revise/`,
    { method: "POST", body: { version: proposal.version, ...(text === undefined ? {} : { content: text }) } },
  );
  return mapProposal(raw, businessId, proposal.locationId, text ?? proposal.sourceText);
}

async function mapProposal(
  raw: Record<string, unknown>, businessId: string, locationId: string, text: string,
): Promise<AssistantProposal> {
  if (raw.intent && Array.isArray(raw.lines)) return raw as unknown as AssistantProposal;

  const payload = (raw.payload ?? {}) as Record<string, unknown>;
  const rawLines = Array.isArray(payload.lines) ? payload.lines as Record<string, unknown>[] : [];
  const [products, parties] = await Promise.all([
    getProducts(businessId, locationId),
    getParties(businessId),
  ]);
  const lines = rawLines.map((line) => {
    const packId = String(line.packId ?? "");
    const product = products.find((candidate) => candidate.packId === packId);
    const quantity = String(line.quantity ?? "1");
    const unitPriceMinor = minorFrom(line, "unitPriceMinor", "unitPrice");
    return {
      productId: product?.id,
      productName: product?.name ?? "Product",
      quantity,
      unit: product?.unit ?? "piece",
      unitPriceMinor,
      lineTotalMinor: Math.round(Number(quantity) * unitPriceMinor),
    };
  });
  const totalMinor = lines.reduce((sum, line) => sum + line.lineTotalMinor, 0);
  const paidMinor = minorFrom(payload, "paidMinor", "paidAmount");
  const customerId = payload.customerId ? String(payload.customerId) : undefined;
  const party = parties.find((candidate) => candidate.id === customerId);
  const warnings = Array.isArray(raw.warnings) ? raw.warnings.map(String) : [];
  const questions = Array.isArray(raw.blockingQuestions) ? raw.blockingQuestions.map(String) : [];
  return {
    id: String(raw.id),
    version: Number(raw.version ?? 1),
    status: raw.status === "READY" ? "READY" : "NEEDS_DETAILS",
    intent: String(raw.commandType ?? "SALE") === "SALE" ? "RECORD_SALE" : "RECORD_EXPENSE",
    sourceText: String(raw.content ?? text),
    partyId: customerId,
    partyName: party?.name ?? (payload.newCustomerName ? String(payload.newCustomerName) : undefined),
    partyProposedNew: Boolean(payload.newCustomerName),
    lines,
    totalMinor,
    paidMinor,
    outstandingMinor: Math.max(0, totalMinor - paidMinor),
    taxMinor: minorFrom(payload, "taxMinor", "taxAmount"),
    locationId,
    warnings,
    questions,
    effects: {
      stock: lines.map((line) => `Reduce ${line.productName} stock by ${line.quantity} ${line.unit}`),
      ledger: totalMinor > paidMinor
        ? `Add ₹${((totalMinor - paidMinor) / 100).toLocaleString("en-IN")} to the customer's outstanding balance`
        : "No outstanding balance",
    },
  };
}

export async function confirmCommand(
  businessId: string,
  proposal: AssistantProposal,
): Promise<Entry> {
  if (demoMode) {
    await delay(650);
    return confirmDemoProposal(proposal);
  }
  const idempotencyKey = `proposal:${proposal.id}:v${proposal.version}`;
  const response = await apiRequest<{ result: Record<string, unknown> }>(
    `/api/v1/assistant/proposals/${proposal.id}/confirm/`,
    {
      method: "POST",
      idempotencyKey,
      body: { version: proposal.version, idempotency_key: idempotencyKey },
    },
  );
  const result = response.result;
  return {
    id: String(result.id),
    number: String(result.number),
    kind: "SALE",
    partyName: proposal.partyName ?? "Cash customer",
    occurredAt: String(result.postedAt ?? new Date().toISOString()),
    totalMinor: minorFrom(result, "grandTotalMinor", "grandTotal"),
    outstandingMinor: minorFrom(result, "dueTotalMinor", "dueTotal"),
    status: "POSTED",
    paymentMode: proposal.paidMinor > 0 ? "CASH" : undefined,
  };
}

export async function recordManualSale(input: ManualSaleInput): Promise<Entry> {
  if (demoMode) {
    await delay(500);
    const quantity = Number(input.quantity);
    const totalMinor = Math.round(quantity * input.unitPriceMinor);
    return confirmDemoProposal({
      id: crypto.randomUUID(),
      version: 1,
      status: "READY",
      intent: "RECORD_SALE",
      sourceText: "Manual sale form",
      partyId: input.customerId,
      partyName: input.customerName,
      lines: [{
        productId: input.productId,
        productName: input.productName,
        quantity: input.quantity,
        unit: "piece",
        unitPriceMinor: input.unitPriceMinor,
        lineTotalMinor: totalMinor,
      }],
      totalMinor,
      paidMinor: input.paidMinor,
      outstandingMinor: totalMinor - input.paidMinor,
      taxMinor: 0,
      locationId: input.locationId,
      warnings: [],
      questions: [],
      effects: {
        stock: [`Reduce ${input.productName} stock by ${input.quantity}`],
        ledger: totalMinor > input.paidMinor
          ? `Add ₹${((totalMinor - input.paidMinor) / 100).toLocaleString("en-IN")} to the customer's outstanding balance`
          : "No outstanding balance",
      },
    });
  }

  const response = await apiRequest<Record<string, unknown>>("/api/v1/sales/", {
    method: "POST",
    idempotencyKey: newIdempotencyKey(),
    body: {
      business_id: input.businessId,
      location_id: input.locationId,
      customer_id: input.customerId ?? null,
      price_mode: input.priceMode,
      tax_inclusive: true,
      lines: [{
        pack_id: input.packId,
        quantity: input.quantity,
        unit_price_minor: input.unitPriceMinor,
        discount_minor: 0,
      }],
      paid_minor: input.paidMinor,
      payment_method: input.paymentMode,
    },
  });
  return {
    id: String(response.id),
    number: String(response.number),
    kind: "SALE",
    partyName: input.customerName ?? "Cash customer",
    occurredAt: String(response.postedAt ?? new Date().toISOString()),
    totalMinor: Number(response.grandTotalMinor),
    outstandingMinor: Number(response.dueTotalMinor),
    status: "POSTED",
    paymentMode: input.paymentMode,
  };
}
