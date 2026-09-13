import { apiRequest, apiUrl, newIdempotencyKey } from "../lib/api";
import { accessToken, demoMode, getRefreshToken } from "../lib/supabase";
import type {
  ActivityEvent,
  AssistantProposal,
  Attachment,
  Bootstrap,
  Business,
  DashboardSummary,
  DayBookReport,
  DocumentReport,
  Entry,
  ExportJob,
  GstReport,
  GstRegistration,
  Invitation,
  LedgerReport,
  Location,
  LocationInput,
  ManualSaleInput,
  Membership,
  MeProfile,
  NotificationPrefs,
  Party,
  PartyBalancesReport,
  PartyInput,
  Product,
  ProductInput,
  ProposalRevision,
  ProposalSummary,
  PurchaseLineInput,
  Reminder,
  ReminderSuggestion,
  ReportGroupRow,
  ReportKind,
  Role,
  StockMovementRow,
  StockRow,
  StockValuationReport,
  TransferLineInput,
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
  const dash = (record: Record<string, unknown>, key: string) => Number(record[key] ?? 0);
  return {
    asOf: String(raw.asOf ?? new Date().toISOString()),
    salesMinor: dash(today, "sales"),
    collectionsMinor: dash(books, "receipts"),
    expensesMinor: dash(today, "expenses"),
    receivableMinor: dash(books, "receivable"),
    payableMinor: dash(books, "payable"),
    lowStockCount: Number(raw.lowStockCount ?? 0),
    grossProfitMinor: dash(books, "grossProfitMinor"),
    summary: String(raw.summary ?? "Your figures are based on posted entries for this location."),
  };
}

export async function getEntries(
  businessId: string,
  locationId: string,
  options: { from?: string; to?: string; status?: string } = {},
): Promise<Entry[]> {
  if (demoMode) {
    await delay();
    return getDemoState().entries;
  }
  const params = new URLSearchParams({ business_id: businessId, location_id: locationId });
  if (options.from) params.set("from", options.from);
  if (options.to) params.set("to", options.to);
  if (options.status) params.set("status", options.status);
  const [sales, purchases, payments, expenses] = await Promise.all([
    apiRequest<unknown>(`/api/v1/sales/?${params}`),
    apiRequest<unknown>(`/api/v1/purchases/?${params}`),
    apiRequest<unknown>(`/api/v1/payments/?${params}`),
    apiRequest<unknown>(`/api/v1/expenses/?${params}`),
  ]);
  const convert = (rows: Record<string, unknown>[], kind: Entry["kind"]): Entry[] => rows.map((row) => {
    const nestedParty = row.customer ?? row.supplier ?? row.party;
    const nestedName = typeof nestedParty === "object" && nestedParty !== null
      ? String((nestedParty as Record<string, unknown>).name ?? "")
      : "";
    const partyName = String(
      row.customerName ?? row.supplierName ?? row.partyName ?? nestedName ?? "",
    );
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
      occurredAt: String(
        row.occurredAt ?? row.postedAt ?? row.paymentDate ?? row.createdAt ?? new Date().toISOString(),
      ),
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
      packId: String(row.defaultPackId ?? pack.id ?? row.id),
      name: String(row.name),
      sku: String(row.sku ?? ""),
      unit: String(row.baseUnit ?? row.unit ?? "PIECE").toLowerCase(),
      onHand: String(row.stockQuantity ?? row.onHand ?? row.quantityOnHand ?? row.stock ?? "0"),
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
    phone: row.phone ?? row.phoneE164 ? String(row.phone ?? row.phoneE164) : undefined,
    kind: String(row.kind ?? "CUSTOMER") as Party["kind"],
    receivableMinor: Number(row.receivableMinor ?? 0),
    payableMinor: Number(row.payableMinor ?? 0),
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
    const unitPriceMinor = minorFrom(line, "unitPriceMinor", "unitPrice") ||
      minorFrom(line, "unitCostMinor", "unitCost");
    return {
      productId: product?.id,
      productName: product?.name ?? "Product",
      quantity,
      unit: product?.unit ?? "piece",
      unitPriceMinor,
      lineTotalMinor: Math.round(Number(quantity) * unitPriceMinor),
    };
  });
  const linesTotalMinor = lines.reduce((sum, line) => sum + line.lineTotalMinor, 0);
  const commandType = String(raw.commandType ?? "SALE");
  const intent = commandType === "PURCHASE"
    ? "RECORD_PURCHASE"
    : commandType === "PAYMENT"
      ? "RECORD_PAYMENT"
      : commandType === "EXPENSE"
        ? "RECORD_EXPENSE"
        : "RECORD_SALE";
  // Payments and expenses carry a single amount instead of item lines.
  const amountMinor = minorFrom(payload, "amountMinor", "amount");
  const totalMinor = lines.length || intent === "RECORD_SALE" || intent === "RECORD_PURCHASE"
    ? linesTotalMinor
    : amountMinor;
  const paidMinor = intent === "RECORD_PAYMENT" || intent === "RECORD_EXPENSE"
    ? amountMinor
    : minorFrom(payload, "paidMinor", "paidAmount");
  const partyId = payload.customerId ?? payload.supplierId ?? payload.partyId;
  const partyIdText = partyId !== undefined && partyId !== null ? String(partyId) : undefined;
  const party = parties.find((candidate) => candidate.id === partyIdText);
  const proposedName = payload.newCustomerName ?? payload.newSupplierName;
  const warnings = Array.isArray(raw.warnings) ? raw.warnings.map(String) : [];
  const questions = Array.isArray(raw.blockingQuestions) ? raw.blockingQuestions.map(String) : [];
  const status = raw.status === "READY" ? "READY" : raw.status === "CONFIRMED" ? "CONFIRMED" : "NEEDS_DETAILS";
  return {
    id: String(raw.id),
    version: Number(raw.version ?? 1),
    status,
    intent,
    sourceText: String(raw.content ?? text),
    partyId: partyIdText,
    partyName: party?.name ?? (proposedName ? String(proposedName) : undefined),
    partyProposedNew: Boolean(proposedName),
    lines,
    totalMinor,
    paidMinor,
    outstandingMinor: Math.max(0, totalMinor - paidMinor),
    taxMinor: minorFrom(payload, "taxMinor", "taxAmount"),
    locationId,
    warnings,
    questions,
    effects: {
      stock: intent === "RECORD_SALE"
        ? lines.map((line) => `Reduce ${line.productName} stock by ${line.quantity} ${line.unit}`)
        : intent === "RECORD_PURCHASE"
          ? lines.map((line) => `Add ${line.productName} stock by ${line.quantity} ${line.unit}`)
          : [],
      ledger: intent === "RECORD_PAYMENT"
        ? `Settle ${formatMinor(totalMinor)} against the oldest pending bill`
        : intent === "RECORD_EXPENSE"
          ? `Record ${formatMinor(totalMinor)} as a business expense`
          : totalMinor > paidMinor
            ? `Add ${formatMinor(totalMinor - paidMinor)} to the party's outstanding balance`
            : "No outstanding balance",
    },
  };
}

function formatMinor(minor: number): string {
  return `₹${(minor / 100).toLocaleString("en-IN")}`;
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
  const direction = String(result.direction ?? "");
  const kind = proposal.intent === "RECORD_PURCHASE"
    ? "PURCHASE"
    : proposal.intent === "RECORD_PAYMENT"
      ? direction === "PAYMENT" ? "PAYMENT_OUT" : "PAYMENT_IN"
      : proposal.intent === "RECORD_EXPENSE"
        ? "EXPENSE"
        : "SALE";
  const totalMinor = kind === "EXPENSE"
    ? Number(result.totalMinor ?? proposal.totalMinor)
    : kind === "PAYMENT_IN"
      ? Number(result.amountMinor ?? proposal.totalMinor)
      : Number(result.grandTotalMinor ?? proposal.totalMinor);
  return {
    id: String(result.id),
    number: String(result.number ?? result.reference ?? "—"),
    kind,
    partyName: proposal.partyName ?? "Cash customer",
    occurredAt: String(result.occurredAt ?? result.postedAt ?? new Date().toISOString()),
    totalMinor,
    outstandingMinor: Number(result.dueTotalMinor ?? proposal.outstandingMinor ?? 0),
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
      paid_amount_minor: input.paidMinor,
      payment_method: input.paymentMode,
    },
  });
  return {
    id: String(response.id),
    number: String(response.number),
    kind: "SALE",
    partyName: input.customerName ?? "Cash customer",
    occurredAt: String(response.occurredAt ?? response.postedAt ?? new Date().toISOString()),
    totalMinor: Number(response.grandTotalMinor),
    outstandingMinor: Number(response.dueTotalMinor),
    status: "POSTED",
    paymentMode: input.paymentMode,
  };
}

// ---------------------------------------------------------------------------
// Auth: OTP, password, signup and logout all speak to the same API base URL.
// ---------------------------------------------------------------------------

export interface AuthTokens {
  access: string;
  refresh: string;
}

export async function sendOtp(phone: string): Promise<string | undefined> {
  if (demoMode) {
    await delay();
    return "123456";
  }
  const res = await apiRequest<Record<string, unknown>>("/api/v1/auth/otp/send/", {
    method: "POST",
    body: { phone },
  });
  return res.devOtp ? String(res.devOtp) : undefined;
}

export async function login(phone: string, password: string): Promise<AuthTokens> {
  if (demoMode) {
    await delay();
    return { access: "demo-access", refresh: "demo-refresh" };
  }
  const res = await apiRequest<Record<string, unknown>>("/api/v1/auth/login/", {
    method: "POST",
    body: { phone, password },
  });
  return { access: String(res.access ?? ""), refresh: String(res.refresh ?? "") };
}

export async function verifyOtp(phone: string, otp: string): Promise<AuthTokens> {
  if (demoMode) {
    await delay();
    return { access: "demo-access", refresh: "demo-refresh" };
  }
  const res = await apiRequest<Record<string, unknown>>("/api/v1/auth/otp/verify/", {
    method: "POST",
    body: { phone, otp },
  });
  return { access: String(res.access ?? ""), refresh: String(res.refresh ?? "") };
}

export async function updateMe(displayName: string): Promise<MeProfile> {
  if (demoMode) {
    await delay();
    return { id: "user-demo", phone: "+91 98765 43210", displayName, memberships: [] };
  }
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/me/", {
    method: "PATCH",
    body: { display_name: displayName },
  });
  return {
    id: String(raw.id),
    phone: String(raw.phone ?? ""),
    displayName: String(raw.displayName ?? ""),
    memberships: [],
  };
}

export async function logoutAll(): Promise<void> {
  if (demoMode) {
    await delay(120);
    return;
  }
  const refresh = getRefreshToken();
  await apiRequest("/api/v1/auth/logout-all/", {
    method: "POST",
    body: refresh ? { refresh } : {},
  });
}

export async function logout(): Promise<void> {
  if (demoMode) {
    await delay(120);
    return;
  }
  const refresh = getRefreshToken();
  await apiRequest("/api/v1/auth/logout/", {
    method: "POST",
    body: refresh ? { refresh } : {},
  });
}

export async function signup(phone: string, password: string, displayName?: string) {
  if (demoMode) {
    await delay();
    return { access: "demo-access", refresh: "demo-refresh" };
  }
  return apiRequest<{ access: string; refresh: string }>("/api/v1/auth/signup/", {
    method: "POST",
    body: { phone, password, ...(displayName ? { display_name: displayName } : {}) },
  });
}

export async function changePassword(oldPassword: string, newPassword: string) {
  if (demoMode) {
    await delay();
    return;
  }
  await apiRequest("/api/v1/auth/password/change/", {
    method: "POST",
    body: { old_password: oldPassword, new_password: newPassword },
  });
}

export async function requestPasswordReset(phone: string): Promise<string | undefined> {
  if (demoMode) {
    await delay();
    return "123456";
  }
  const res = await apiRequest<Record<string, unknown>>("/api/v1/auth/password/reset/", {
    method: "POST",
    body: { phone },
  });
  return res.devOtp as string | undefined;
}

export async function confirmPasswordReset(phone: string, otp: string, newPassword: string) {
  if (demoMode) {
    await delay();
    return;
  }
  await apiRequest("/api/v1/auth/password/reset/confirm/", {
    method: "POST",
    body: { phone, otp, new_password: newPassword },
  });
}

// ---------------------------------------------------------------------------
// Common
// ---------------------------------------------------------------------------

export async function getMe(): Promise<MeProfile> {
  if (demoMode) {
    await delay();
    return { id: "user-demo", phone: "+91 98765 43210", displayName: "Demo Owner", memberships: [] };
  }
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/me/");
  return {
    id: String(raw.id),
    phone: String(raw.phone ?? ""),
    displayName: String(raw.displayName ?? ""),
    memberships: (Array.isArray(raw.memberships) ? raw.memberships : []).map((m) => {
      const row = m as Record<string, unknown>;
      return { businessId: String(row.businessId), businessName: String(row.businessName), role: String(row.role) as Role };
    }),
  };
}

// ---------------------------------------------------------------------------
// Tenancy: businesses / locations / GST registrations / memberships
// ---------------------------------------------------------------------------

export async function listBusinesses(): Promise<Business[]> {
  if (demoMode) {
    await delay();
    return [demoBootstrap.business];
  }
  const res = await apiRequest<unknown>("/api/v1/businesses/");
  return recordList(res).map((row) => ({
    id: String(row.id),
    name: String(row.name),
    legalName: String(row.legalName ?? row.name),
    currency: "INR" as const,
    timezone: "Asia/Kolkata" as const,
  }));
}

export async function createBusiness(input: { name: string; legalName?: string }): Promise<Business> {
  if (demoMode) {
    await delay();
    return { ...demoBootstrap.business, id: crypto.randomUUID(), name: input.name };
  }
  const row = await apiRequest<Record<string, unknown>>("/api/v1/businesses/", {
    method: "POST",
    body: { name: input.name, legal_name: input.legalName ?? input.name },
  });
  return {
    id: String(row.id),
    name: String(row.name),
    legalName: String(row.legalName ?? row.name),
    currency: "INR",
    timezone: "Asia/Kolkata",
    defaultPriceMode: row.defaultPriceMode === "WHOLESALE" ? "WHOLESALE" : "RETAIL",
  };
}

export async function updateBusiness(
  id: string,
  patch: { name?: string; legalName?: string; defaultPriceMode?: "RETAIL" | "WHOLESALE" },
): Promise<Business> {
  if (demoMode) {
    await delay();
    return { ...demoBootstrap.business, id, name: patch.name ?? demoBootstrap.business.name };
  }
  const row = await apiRequest<Record<string, unknown>>(`/api/v1/businesses/${id}/`, {
    method: "PATCH",
    body: {
      ...(patch.name !== undefined ? { name: patch.name } : {}),
      ...(patch.legalName !== undefined ? { legal_name: patch.legalName } : {}),
      ...(patch.defaultPriceMode ? { default_price_mode: patch.defaultPriceMode } : {}),
    },
  });
  return {
    id: String(row.id),
    name: String(row.name),
    legalName: String(row.legalName ?? row.name),
    currency: "INR",
    timezone: "Asia/Kolkata",
    defaultPriceMode: row.defaultPriceMode === "WHOLESALE" ? "WHOLESALE" : "RETAIL",
  };
}

export async function getBusiness(id: string): Promise<Business> {
  if (demoMode) {
    await delay();
    return demoBootstrap.business;
  }
  const row = await apiRequest<Record<string, unknown>>(`/api/v1/businesses/${id}/`);
  return {
    id: String(row.id),
    name: String(row.name),
    legalName: String(row.legalName ?? row.name),
    currency: "INR",
    timezone: "Asia/Kolkata",
    defaultPriceMode: row.defaultPriceMode === "WHOLESALE" ? "WHOLESALE" : "RETAIL",
  };
}

export async function listLocations(businessId: string): Promise<Location[]> {
  if (demoMode) {
    await delay();
    return demoBootstrap.locations;
  }
  const res = await apiRequest<unknown>(`/api/v1/locations/?business_id=${businessId}`);
  return recordList(res).map((row) => ({
    id: String(row.id),
    name: String(row.name),
    code: String(row.code ?? ""),
    stateCode: String(row.stateCode ?? ""),
  }));
}

export async function createLocation(input: LocationInput): Promise<Location> {
  if (demoMode) {
    await delay();
    return { id: crypto.randomUUID(), name: input.name, code: input.code, stateCode: input.stateCode ?? input.state_code ?? "" };
  }
  const row = await apiRequest<Record<string, unknown>>("/api/v1/locations/", {
    method: "POST",
    idempotencyKey: newIdempotencyKey(),
    body: {
      business: input.business,
      name: input.name,
      code: input.code,
      ...(input.address ? { address: input.address } : {}),
      ...(input.stateCode ?? input.state_code ? { state_code: input.stateCode ?? input.state_code } : {}),
      ...(input.gstRegistration ? { gst_registration: input.gstRegistration } : {}),
    },
  });
  return { id: String(row.id), name: String(row.name), code: String(row.code ?? ""), stateCode: String(row.stateCode ?? "") };
}

export async function updateLocation(id: string, patch: Partial<LocationInput>): Promise<Location> {
  if (demoMode) {
    await delay();
    return { id, name: patch.name ?? "Location", code: patch.code ?? "", stateCode: "" };
  }
  const row = await apiRequest<Record<string, unknown>>(`/api/v1/locations/${id}/`, {
    method: "PATCH",
    body: {
      ...(patch.name ? { name: patch.name } : {}),
      ...(patch.code ? { code: patch.code } : {}),
      ...(patch.address ? { address: patch.address } : {}),
      ...(patch.stateCode ?? patch.state_code ? { state_code: patch.stateCode ?? patch.state_code } : {}),
    },
  });
  return { id: String(row.id), name: String(row.name), code: String(row.code ?? ""), stateCode: String(row.stateCode ?? "") };
}

export async function deleteLocation(id: string) {
  if (demoMode) {
    await delay();
    return;
  }
  await apiRequest(`/api/v1/locations/${id}/`, { method: "DELETE" });
}

export async function listGstRegistrations(businessId: string): Promise<GstRegistration[]> {
  if (demoMode) {
    await delay();
    return [];
  }
  const res = await apiRequest<unknown>(`/api/v1/gst-registrations/?business_id=${businessId}`);
  return recordList(res).map((row) => ({
    id: String(row.id),
    business: String(row.business),
    gstin: String(row.gstin ?? ""),
    legalName: String(row.legalName ?? ""),
    address: row.address ? String(row.address) : undefined,
    stateCode: row.stateCode ? String(row.stateCode) : undefined,
    invoicePrefix: row.invoicePrefix ? String(row.invoicePrefix) : undefined,
  }));
}

export async function createGstRegistration(input: { business: string; gstin: string; legalName?: string; stateCode?: string; invoicePrefix?: string }) {
  if (demoMode) {
    await delay();
    return { id: crypto.randomUUID(), ...input, legalName: input.legalName ?? "" };
  }
  return apiRequest<unknown>("/api/v1/gst-registrations/", {
    method: "POST",
    body: {
      business: input.business,
      gstin: input.gstin,
      ...(input.legalName ? { legal_name: input.legalName } : {}),
      ...(input.stateCode ? { state_code: input.stateCode } : {}),
      ...(input.invoicePrefix ? { invoice_prefix: input.invoicePrefix } : {}),
    },
  });
}

export async function updateGstRegistration(id: string, patch: { gstin?: string; legalName?: string; stateCode?: string; invoicePrefix?: string }) {
  if (demoMode) {
    await delay();
    return patch;
  }
  return apiRequest<unknown>(`/api/v1/gst-registrations/${id}/`, {
    method: "PATCH",
    body: {
      ...(patch.gstin ? { gstin: patch.gstin } : {}),
      ...(patch.legalName ? { legal_name: patch.legalName } : {}),
      ...(patch.stateCode ? { state_code: patch.stateCode } : {}),
      ...(patch.invoicePrefix ? { invoice_prefix: patch.invoicePrefix } : {}),
    },
  });
}

export async function listMemberships(businessId: string): Promise<Membership[]> {
  if (demoMode) {
    await delay();
    return [];
  }
  const res = await apiRequest<unknown>(`/api/v1/memberships/?business_id=${businessId}`);
  return recordList(res).map((row) => ({
    id: String(row.id),
    user: String(row.user),
    userName: row.userName ? String(row.userName) : undefined,
    userPhone: row.userPhone ? String(row.userPhone) : undefined,
    business: String(row.business),
    role: String(row.role) as Role,
    locations: Array.isArray(row.locations) ? (row.locations as unknown[]).map(String) : [],
  }));
}

export async function createMembership(input: { business: string; user: string; role: Role; locations?: string[] }) {
  if (demoMode) {
    await delay();
    return { id: crypto.randomUUID(), ...input };
  }
  return apiRequest<unknown>("/api/v1/memberships/", { method: "POST", body: input });
}

export async function updateMembership(id: string, patch: { role?: Role; locations?: string[] }) {
  if (demoMode) {
    await delay();
    return patch;
  }
  return apiRequest<unknown>(`/api/v1/memberships/${id}/`, { method: "PATCH", body: patch });
}

export async function deleteMembership(id: string) {
  if (demoMode) {
    await delay();
    return;
  }
  await apiRequest(`/api/v1/memberships/${id}/`, { method: "DELETE" });
}

export async function revokeMembership(id: string): Promise<Membership> {
  if (demoMode) {
    await delay();
    return {
      id,
      user: "demo-user",
      business: "demo-business",
      role: "CASHIER",
      locations: [],
      isActive: false,
    };
  }
  const row = await apiRequest<Record<string, unknown>>(`/api/v1/memberships/${id}/revoke/`, {
    method: "POST",
  });
  return {
    id: String(row.id),
    user: String(row.user),
    userName: row.userName ? String(row.userName) : undefined,
    userPhone: row.userPhone ? String(row.userPhone) : undefined,
    business: String(row.business),
    role: String(row.role) as Role,
    locations: Array.isArray(row.locations) ? (row.locations as unknown[]).map(String) : [],
    isActive: Boolean(row.isActive ?? true),
  };
}

export async function listInvitations(businessId: string, status?: string): Promise<Invitation[]> {
  if (demoMode) {
    await delay();
    return [];
  }
  const params = new URLSearchParams({ business_id: businessId, ...(status ? { status } : {}) });
  const res = await apiRequest<unknown>(`/api/v1/invitations/?${params}`);
  return recordList(res).map((row) => ({
    id: String(row.id),
    business: String(row.business),
    phoneE164: String(row.phoneE164 ?? ""),
    role: String(row.role) as Role,
    locations: Array.isArray(row.locations) ? (row.locations as unknown[]).map(String) : [],
    status: String(row.status ?? "PENDING") as Invitation["status"],
    expiresAt: String(row.expiresAt ?? ""),
    createdAt: String(row.createdAt ?? ""),
  }));
}

export async function createInvitation(input: {
  business: string;
  phoneE164: string;
  role: Role;
  locations?: string[];
}): Promise<Invitation & { token?: string }> {
  if (demoMode) {
    await delay();
    return {
      id: crypto.randomUUID(),
      business: input.business,
      phoneE164: input.phoneE164,
      role: input.role,
      locations: input.locations ?? [],
      status: "PENDING",
      expiresAt: new Date(Date.now() + 7 * 86400000).toISOString(),
      createdAt: new Date().toISOString(),
    };
  }
  const row = await apiRequest<Record<string, unknown>>("/api/v1/invitations/", {
    method: "POST",
    body: {
      business: input.business,
      phone_e164: input.phoneE164,
      role: input.role,
      locations: input.locations ?? [],
    },
  });
  return {
    id: String(row.id),
    business: String(row.business),
    phoneE164: String(row.phoneE164 ?? ""),
    role: String(row.role) as Role,
    locations: Array.isArray(row.locations) ? (row.locations as unknown[]).map(String) : [],
    status: String(row.status ?? "PENDING") as Invitation["status"],
    expiresAt: String(row.expiresAt ?? ""),
    createdAt: String(row.createdAt ?? ""),
    token: row.token ? String(row.token) : undefined,
  };
}

export async function revokeInvitation(id: string): Promise<void> {
  if (demoMode) {
    await delay();
    return;
  }
  await apiRequest(`/api/v1/invitations/${id}/revoke/`, { method: "POST" });
}

// ---------------------------------------------------------------------------
// Catalog: product / party CRUD + detail
// ---------------------------------------------------------------------------

export async function getProduct(id: string): Promise<Product | null> {
  if (demoMode) {
    await delay();
    return getDemoState().products.find((p) => p.id === id) ?? null;
  }
  const row = await apiRequest<Record<string, unknown>>(`/api/v1/products/${id}/`);
  const packs = Array.isArray(row.packs) ? (row.packs as Record<string, unknown>[]) : [];
  const pack = packs[0] ?? {};
  return {
    id: String(row.id),
    packId: String(row.defaultPackId ?? pack.id ?? row.id),
    name: String(row.name),
    sku: String(row.sku ?? ""),
    unit: String(row.baseUnit ?? "piece").toLowerCase(),
    onHand: String(row.stockQuantity ?? "0"),
    reorderLevel: String(row.lowStockThreshold ?? "0"),
    retailPriceMinor: minorFrom(pack, "retailPriceMinor", "retailPrice"),
    wholesalePriceMinor: minorFrom(pack, "wholesalePriceMinor", "wholesalePrice"),
    gstRateBps: row.taxRateBps !== undefined ? Number(row.taxRateBps) : 0,
  };
}

export async function createProduct(input: ProductInput) {
  if (demoMode) {
    await delay();
    return { id: crypto.randomUUID(), ...input };
  }
  return apiRequest<unknown>("/api/v1/products/", {
    method: "POST",
    idempotencyKey: newIdempotencyKey(),
    body: {
      business: input.business,
      name: input.name,
      ...(input.sku ? { sku: input.sku } : {}),
      base_unit: input.baseUnit ?? "PIECE",
      track_inventory: input.trackInventory ?? true,
      ...(input.hsnSac ? { hsn_sac: input.hsnSac } : {}),
      tax_rate_bps: input.taxRateBps ?? 0,
      low_stock_threshold: input.lowStockThreshold ?? "0",
      packs: input.packs.map((p) => ({
        name: p.name,
        conversion_factor: p.conversionFactor ?? "1",
        retail_price_minor: p.retailPriceMinor,
        wholesale_price_minor: p.wholesalePriceMinor,
      })),
    },
  });
}

export async function updateProduct(id: string, patch: Partial<ProductInput>) {
  if (demoMode) {
    await delay();
    return patch;
  }
  return apiRequest<unknown>(`/api/v1/products/${id}/`, {
    method: "PATCH",
    body: {
      ...(patch.name ? { name: patch.name } : {}),
      ...(patch.sku !== undefined ? { sku: patch.sku } : {}),
      ...(patch.lowStockThreshold !== undefined ? { low_stock_threshold: patch.lowStockThreshold } : {}),
      ...(patch.taxRateBps !== undefined ? { tax_rate_bps: patch.taxRateBps } : {}),
      ...(patch.packs ? {
        packs: patch.packs.map((p) => ({
          ...(p.id ? { id: p.id } : {}),
          ...(p.name ? { name: p.name } : {}),
          retail_price_minor: p.retailPriceMinor,
          wholesale_price_minor: p.wholesalePriceMinor,
        })),
      } : {}),
    },
  });
}

export async function deleteProduct(id: string) {
  if (demoMode) {
    await delay();
    return;
  }
  await apiRequest(`/api/v1/products/${id}/`, { method: "DELETE" });
}

export async function getParty(businessId: string, id: string): Promise<Party | null> {
  if (demoMode) {
    await delay();
    return getDemoState().parties.find((p) => p.id === id) ?? null;
  }
  const row = await apiRequest<Record<string, unknown>>(`/api/v1/parties/${id}/?business_id=${businessId}`);
  return {
    id: String(row.id),
    name: String(row.name),
    phone: row.phone ?? row.phoneE164 ? String(row.phone ?? row.phoneE164) : undefined,
    kind: String(row.kind ?? "CUSTOMER") as Party["kind"],
    receivableMinor: Number(row.receivableMinor ?? 0),
    payableMinor: Number(row.payableMinor ?? 0),
    priceTier: "RETAIL",
  };
}

export async function createParty(input: PartyInput) {
  if (demoMode) {
    await delay();
    return { id: crypto.randomUUID(), ...input };
  }
  return apiRequest<unknown>("/api/v1/parties/", {
    method: "POST",
    idempotencyKey: newIdempotencyKey(),
    body: {
      business: input.business,
      name: input.name,
      kind: input.kind,
      ...(input.phoneE164 ? { phone_e164: input.phoneE164 } : {}),
      ...(input.gstin ? { gstin: input.gstin } : {}),
      ...(input.stateCode ? { state_code: input.stateCode } : {}),
      ...(input.address ? { address: input.address } : {}),
    },
  });
}

export async function updateParty(id: string, patch: Partial<PartyInput>) {
  if (demoMode) {
    await delay();
    return patch;
  }
  return apiRequest<unknown>(`/api/v1/parties/${id}/`, {
    method: "PATCH",
    body: {
      ...(patch.name ? { name: patch.name } : {}),
      ...(patch.kind ? { kind: patch.kind } : {}),
      ...(patch.phoneE164 !== undefined ? { phone_e164: patch.phoneE164 } : {}),
      ...(patch.gstin !== undefined ? { gstin: patch.gstin } : {}),
    },
  });
}

export async function deleteParty(id: string) {
  if (demoMode) {
    await delay();
    return;
  }
  await apiRequest(`/api/v1/parties/${id}/`, { method: "DELETE" });
}

// ---------------------------------------------------------------------------
// Operations: detail / create / reverse for all documents
// ---------------------------------------------------------------------------

export async function getDocument(collection: "sales" | "purchases" | "payments" | "expenses" | "transfers", id: string) {
  if (demoMode) {
    await delay();
    return null;
  }
  return apiRequest<unknown>(`/api/v1/${collection}/${id}/`);
}

export async function reverseDocument(
  collection: "sales" | "purchases" | "payments" | "expenses" | "transfers",
  id: string,
  reason: string,
) {
  if (demoMode) {
    await delay();
    const state = getDemoState();
    const entry = state.entries.find((e) => e.id === id);
    if (entry) {
      entry.status = "REVERSED";
      localStorage.setItem("dukaanai-demo-state-v1", JSON.stringify(state));
      window.dispatchEvent(new Event("dukaanai:demo-updated"));
    }
    return entry ?? null;
  }
  const idempotencyKey = `reverse:${collection}:${id}`;
  return apiRequest<unknown>(`/api/v1/${collection}/${id}/reverse/`, {
    method: "POST",
    idempotencyKey,
    body: { reason, idempotency_key: idempotencyKey },
  });
}

export async function createPurchase(input: {
  businessId: string;
  locationId: string;
  supplierId: string;
  lines: PurchaseLineInput[];
  paidMinor?: number;
  paymentMode?: string;
}) {
  if (demoMode) {
    await delay(500);
    return confirmDemoProposal({
      id: crypto.randomUUID(), version: 1, status: "READY", intent: "RECORD_PURCHASE",
      sourceText: "Manual purchase", partyId: input.supplierId, lines: [], totalMinor: 0,
      paidMinor: input.paidMinor ?? 0, outstandingMinor: 0, taxMinor: 0, locationId: input.locationId,
      warnings: [], questions: [], effects: { stock: [], ledger: "" },
    });
  }
  const response = await apiRequest<Record<string, unknown>>("/api/v1/purchases/", {
    method: "POST",
    idempotencyKey: newIdempotencyKey(),
    body: {
      business_id: input.businessId,
      location_id: input.locationId,
      supplier_id: input.supplierId,
      lines: input.lines.map((l) => ({ pack_id: l.packId, quantity: l.quantity, unit_cost_minor: l.unitCostMinor })),
      paid_amount_minor: input.paidMinor ?? 0,
      payment_method: input.paymentMode ?? "CASH",
      idempotency_key: newIdempotencyKey(),
    },
  });
  return response;
}

export async function createPayment(input: {
  businessId: string;
  locationId: string;
  partyId: string;
  direction: "RECEIPT" | "PAYMENT";
  method?: string;
  amountMinor: number;
  note?: string;
}) {
  if (demoMode) {
    await delay(400);
    return confirmDemoProposal({
      id: crypto.randomUUID(), version: 1, status: "READY", intent: "RECORD_PAYMENT",
      sourceText: "Manual payment", partyId: input.partyId, lines: [], totalMinor: input.amountMinor,
      paidMinor: input.amountMinor, outstandingMinor: 0, taxMinor: 0, locationId: input.locationId,
      warnings: [], questions: [], effects: { stock: [], ledger: "" },
    });
  }
  return apiRequest<unknown>("/api/v1/payments/", {
    method: "POST",
    idempotencyKey: newIdempotencyKey(),
    body: {
      business_id: input.businessId,
      location_id: input.locationId,
      party_id: input.partyId,
      direction: input.direction,
      method: input.method ?? "CASH",
      amount_minor: input.amountMinor,
      ...(input.note ? { note: input.note } : {}),
      idempotency_key: newIdempotencyKey(),
    },
  });
}

export async function createExpense(input: {
  businessId: string;
  locationId: string;
  category: string;
  amountMinor: number;
  paymentMode?: string;
  note?: string;
}) {
  if (demoMode) {
    await delay(400);
    return confirmDemoProposal({
      id: crypto.randomUUID(), version: 1, status: "READY", intent: "RECORD_EXPENSE",
      sourceText: input.category, lines: [], totalMinor: input.amountMinor,
      paidMinor: input.amountMinor, outstandingMinor: 0, taxMinor: 0, locationId: input.locationId,
      warnings: [], questions: [], effects: { stock: [], ledger: "" },
    });
  }
  return apiRequest<unknown>("/api/v1/expenses/", {
    method: "POST",
    idempotencyKey: newIdempotencyKey(),
    body: {
      business_id: input.businessId,
      location_id: input.locationId,
      category: input.category,
      amount_minor: input.amountMinor,
      payment_method: input.paymentMode ?? "CASH",
      ...(input.note ? { note: input.note } : {}),
      idempotency_key: newIdempotencyKey(),
    },
  });
}

export async function listTransfers(businessId: string, locationId: string) {
  if (demoMode) {
    await delay();
    return [];
  }
  const params = new URLSearchParams({ business_id: businessId, location_id: locationId });
  return recordList(await apiRequest<unknown>(`/api/v1/transfers/?${params}`));
}

export async function createTransfer(input: {
  businessId: string;
  fromLocationId: string;
  toLocationId: string;
  lines: TransferLineInput[];
  note?: string;
}) {
  if (demoMode) {
    await delay(400);
    return { id: crypto.randomUUID(), ...input };
  }
  return apiRequest<unknown>("/api/v1/transfers/", {
    method: "POST",
    idempotencyKey: newIdempotencyKey(),
    body: {
      business_id: input.businessId,
      from_location_id: input.fromLocationId,
      to_location_id: input.toLocationId,
      lines: input.lines.map((l) => ({ pack_id: l.packId, quantity: l.quantity })),
      ...(input.note ? { note: input.note } : {}),
      idempotency_key: newIdempotencyKey(),
    },
  });
}

export async function adjustStock(input: {
  businessId: string;
  locationId: string;
  productId: string;
  quantityDelta: string;
  reason: string;
}) {
  if (demoMode) {
    await delay();
    return { id: crypto.randomUUID(), ...input };
  }
  return apiRequest<unknown>("/api/v1/stock/adjustments/", {
    method: "POST",
    idempotencyKey: newIdempotencyKey(),
    body: {
      business_id: input.businessId,
      location_id: input.locationId,
      product_id: input.productId,
      quantity_delta: input.quantityDelta,
      reason: input.reason,
      idempotency_key: newIdempotencyKey(),
    },
  });
}

export async function postOpeningBalance(input: {
  businessId: string;
  locationId: string;
  partyId: string;
  account: "RECEIVABLE" | "PAYABLE";
  amountMinor: number;
  note?: string;
}) {
  if (demoMode) {
    await delay();
    return { id: crypto.randomUUID(), ...input };
  }
  return apiRequest<unknown>("/api/v1/party-ledger/opening-balances/", {
    method: "POST",
    idempotencyKey: newIdempotencyKey(),
    body: {
      business_id: input.businessId,
      location_id: input.locationId,
      party_id: input.partyId,
      account: input.account,
      amount_minor: input.amountMinor,
      ...(input.note ? { note: input.note } : {}),
      idempotency_key: newIdempotencyKey(),
    },
  });
}

export async function getStockReport(businessId: string, locationId: string): Promise<StockRow[]> {
  if (demoMode) {
    await delay();
    return getDemoState().products.map((p) => ({
      productId: p.id, name: p.name, unit: p.unit, quantity: p.onHand,
      lowStockThreshold: p.reorderLevel, isLowStock: Number(p.onHand) <= Number(p.reorderLevel),
    }));
  }
  const params = new URLSearchParams({ business_id: businessId, location_id: locationId });
  const res = await apiRequest<Record<string, unknown>>(`/api/v1/reports/stock/?${params}`);
  const rows = Array.isArray(res.results) ? (res.results as Record<string, unknown>[]) : [];
  return rows.map((row) => ({
    productId: String(row.productId),
    name: String(row.name ?? ""),
    unit: String(row.unit ?? ""),
    quantity: String(row.quantity ?? "0"),
    lowStockThreshold: row.lowStockThreshold !== undefined ? String(row.lowStockThreshold) : undefined,
    isLowStock: Boolean(row.isLowStock),
  }));
}

export async function getPartyLedger(businessId: string, partyId: string, locationId?: string): Promise<LedgerReport> {
  if (demoMode) {
    await delay();
    const party = getDemoState().parties.find((p) => p.id === partyId);
    return { partyId, balance: (party?.receivableMinor ?? 0) - (party?.payableMinor ?? 0), entries: [] };
  }
  const params = new URLSearchParams({ business_id: businessId, party_id: partyId, ...(locationId ? { location_id: locationId } : {}) });
  const res = await apiRequest<Record<string, unknown>>(`/api/v1/reports/party-ledger/?${params}`);
  const entries = (Array.isArray(res.entries) ? res.entries : []) as Record<string, unknown>[];
  return {
    partyId: String(res.partyId ?? partyId),
    balance: Number(res.balance ?? 0),
    entries: entries.map((e) => ({
      id: String(e.id),
      account: String(e.account ?? ""),
      amountMinor: Number(e.amountMinor ?? 0),
      note: e.note ? String(e.note) : undefined,
      occurredAt: String(e.occurredAt ?? ""),
    })),
  };
}

// ---------------------------------------------------------------------------
// Assistant: history + cancel (interpret/revise/confirm already exist)
// ---------------------------------------------------------------------------

export async function listProposals(): Promise<ProposalSummary[]> {
  if (demoMode) {
    await delay();
    return [];
  }
  const res = await apiRequest<unknown>("/api/v1/assistant/proposals/");
  return recordList(res).map((row) => ({
    id: String(row.id),
    version: Number(row.version ?? 1),
    status: String(row.status ?? ""),
    commandType: row.commandType ? String(row.commandType) : undefined,
    content: row.content ? String(row.content) : undefined,
    createdAt: row.createdAt ? String(row.createdAt) : undefined,
  }));
}

export async function getProposal(id: string): Promise<Record<string, unknown> | null> {
  if (demoMode) {
    await delay();
    return null;
  }
  return apiRequest<Record<string, unknown>>(`/api/v1/assistant/proposals/${id}/`);
}

export async function getProposalRevisions(id: string): Promise<ProposalRevision[]> {
  if (demoMode) {
    await delay();
    return [];
  }
  const res = await apiRequest<unknown>(`/api/v1/assistant/proposals/${id}/revisions/`);
  const rows = Array.isArray(res) ? (res as Record<string, unknown>[]) : recordList(res);
  return rows.map((row) => ({ version: Number(row.version ?? 0), snapshot: row.snapshot, createdAt: String(row.createdAt ?? "") }));
}

export async function cancelProposal(id: string, version: number) {
  if (demoMode) {
    await delay();
    return { id, version, status: "CANCELLED" };
  }
  return apiRequest<unknown>(`/api/v1/assistant/proposals/${id}/cancel/`, {
    method: "POST",
    body: { version },
  });
}

// ---------------------------------------------------------------------------
// Reports: day book, sales/purchases, GST, party balances, stock valuation,
// stock movements and CSV export.
// ---------------------------------------------------------------------------

export interface ReportQuery {
  businessId: string;
  locationId?: string;
  from?: string;
  to?: string;
}

function reportParams(query: ReportQuery, extra: Record<string, string> = {}): URLSearchParams {
  const params = new URLSearchParams({ business_id: query.businessId, ...extra });
  if (query.locationId) params.set("location_id", query.locationId);
  if (query.from) params.set("from", query.from);
  if (query.to) params.set("to", query.to);
  return params;
}

function mapDayBook(raw: Record<string, unknown>): DayBookReport {
  const summary = (raw.summary ?? {}) as Record<string, unknown>;
  const entries = Array.isArray(raw.entries)
    ? (raw.entries as Record<string, unknown>[]).map((entry) => ({
        date: String(entry.date ?? ""),
        kind: String(entry.kind ?? ""),
        number: String(entry.number ?? ""),
        partyName: String(entry.partyName ?? ""),
        direction: String(entry.direction ?? "IN") as "IN" | "OUT",
        amountMinor: Number(entry.amountMinor ?? 0),
        status: String(entry.status ?? "POSTED"),
      }))
    : [];
  return {
    from: raw.from ? String(raw.from) : undefined,
    to: raw.to ? String(raw.to) : undefined,
    summary: {
      salesMinor: Number(summary.salesMinor ?? 0),
      purchasesMinor: Number(summary.purchasesMinor ?? 0),
      receiptsMinor: Number(summary.receiptsMinor ?? 0),
      paymentsMinor: Number(summary.paymentsMinor ?? 0),
      expensesMinor: Number(summary.expensesMinor ?? 0),
      netCashMinor: Number(summary.netCashMinor ?? 0),
    },
    entries,
  };
}

function mapGroupRow(row: Record<string, unknown>): ReportGroupRow {
  return {
    key: String(row.key ?? ""),
    label: String(row.label ?? ""),
    count: Number(row.count ?? 0),
    quantity: row.quantity !== undefined ? String(row.quantity) : undefined,
    taxableMinor: Number(row.taxableMinor ?? 0),
    taxMinor: Number(row.taxMinor ?? 0),
    grandTotalMinor: Number(row.grandTotalMinor ?? 0),
    paidMinor: Number(row.paidMinor ?? 0),
    dueMinor: Number(row.dueMinor ?? 0),
  };
}

function mapDocumentReport(raw: Record<string, unknown>): DocumentReport {
  return {
    from: raw.from ? String(raw.from) : undefined,
    to: raw.to ? String(raw.to) : undefined,
    groupBy: String(raw.groupBy ?? "day") as DocumentReport["groupBy"],
    totals: mapGroupRow((raw.totals ?? {}) as Record<string, unknown>),
    rows: Array.isArray(raw.rows)
      ? (raw.rows as Record<string, unknown>[]).map(mapGroupRow)
      : [],
  };
}

function demoDayBook(): DayBookReport {
  const state = getDemoState();
  const total = (kind: Entry["kind"]) =>
    state.entries.filter((entry) => entry.kind === kind).reduce((sum, entry) => sum + entry.totalMinor, 0);
  const receipts = total("PAYMENT_IN");
  const payments = total("PAYMENT_OUT");
  const expenses = total("EXPENSE");
  return {
    summary: {
      salesMinor: total("SALE"),
      purchasesMinor: total("PURCHASE"),
      receiptsMinor: receipts,
      paymentsMinor: payments,
      expensesMinor: expenses,
      netCashMinor: receipts - payments - expenses,
    },
    entries: state.entries.map((entry) => ({
      date: entry.occurredAt.slice(0, 10),
      kind: entry.kind,
      number: entry.number,
      partyName: entry.partyName,
      direction: entry.kind === "SALE" || entry.kind === "PAYMENT_IN" ? ("IN" as const) : ("OUT" as const),
      amountMinor: entry.totalMinor,
      status: entry.status,
    })),
  };
}

function demoDocumentReport(kind: "sales" | "purchases", groupBy: string): DocumentReport {
  const wanted = kind === "sales" ? "SALE" : "PURCHASE";
  const rows = getDemoState()
    .entries.filter((entry) => entry.kind === wanted)
    .map<ReportGroupRow>((entry) => ({
      key: entry.id,
      label: groupBy === "party" ? entry.partyName : entry.occurredAt.slice(0, 10),
      count: 1,
      taxableMinor: entry.totalMinor,
      taxMinor: 0,
      grandTotalMinor: entry.totalMinor,
      paidMinor: entry.totalMinor - entry.outstandingMinor,
      dueMinor: entry.outstandingMinor,
    }));
  const totals = rows.reduce<ReportGroupRow>(
    (accumulator, row) => ({
      key: "totals",
      label: "Total",
      count: accumulator.count + 1,
      taxableMinor: accumulator.taxableMinor + row.taxableMinor,
      taxMinor: accumulator.taxMinor + row.taxMinor,
      grandTotalMinor: accumulator.grandTotalMinor + row.grandTotalMinor,
      paidMinor: accumulator.paidMinor + row.paidMinor,
      dueMinor: accumulator.dueMinor + row.dueMinor,
    }),
    { key: "totals", label: "Total", count: 0, taxableMinor: 0, taxMinor: 0, grandTotalMinor: 0, paidMinor: 0, dueMinor: 0 },
  );
  return { groupBy: groupBy as DocumentReport["groupBy"], totals, rows };
}

export async function getDayBook(query: ReportQuery): Promise<DayBookReport> {
  if (demoMode) {
    await delay();
    return demoDayBook();
  }
  const raw = await apiRequest<Record<string, unknown>>(
    `/api/v1/reports/day-book/?${reportParams(query)}`,
  );
  return mapDayBook(raw);
}

export async function getDocumentReport(
  query: ReportQuery,
  kind: "sales" | "purchases",
  groupBy: "day" | "party" | "product",
): Promise<DocumentReport> {
  if (demoMode) {
    await delay();
    return demoDocumentReport(kind, groupBy);
  }
  const raw = await apiRequest<Record<string, unknown>>(
    `/api/v1/reports/${kind}/?${reportParams(query, { group_by: groupBy })}`,
  );
  return mapDocumentReport(raw);
}

function mapGstSide(side: Record<string, unknown>) {
  const rows = Array.isArray(side.rows)
    ? (side.rows as Record<string, unknown>[]).map((row) => ({
        rateBps: Number(row.rateBps ?? 0),
        taxableMinor: Number(row.taxableMinor ?? 0),
        cgstMinor: Number(row.cgstMinor ?? 0),
        sgstMinor: Number(row.sgstMinor ?? 0),
        igstMinor: Number(row.igstMinor ?? 0),
        taxMinor: Number(row.taxMinor ?? 0),
      }))
    : [];
  const totals = (side.totals ?? {}) as Record<string, unknown>;
  return {
    rows,
    totals: {
      taxableMinor: Number(totals.taxableMinor ?? 0),
      cgstMinor: Number(totals.cgstMinor ?? 0),
      sgstMinor: Number(totals.sgstMinor ?? 0),
      igstMinor: Number(totals.igstMinor ?? 0),
      taxMinor: Number(totals.taxMinor ?? 0),
    },
  };
}

export async function getGstReport(query: ReportQuery): Promise<GstReport> {
  if (demoMode) {
    await delay();
    const empty = { rows: [], totals: { taxableMinor: 0, cgstMinor: 0, sgstMinor: 0, igstMinor: 0, taxMinor: 0 } };
    return {
      output: { ...empty },
      input: { ...empty },
      b2b: { count: 0, taxableMinor: 0, taxMinor: 0 },
      b2c: { count: 0, taxableMinor: 0, taxMinor: 0 },
    };
  }
  const raw = await apiRequest<Record<string, unknown>>(`/api/v1/reports/gst/?${reportParams(query)}`);
  const b2b = (raw.b2b ?? {}) as Record<string, unknown>;
  const b2c = (raw.b2c ?? {}) as Record<string, unknown>;
  return {
    from: raw.from ? String(raw.from) : undefined,
    to: raw.to ? String(raw.to) : undefined,
    output: mapGstSide((raw.output ?? {}) as Record<string, unknown>),
    input: mapGstSide((raw.input ?? {}) as Record<string, unknown>),
    b2b: { count: Number(b2b.count ?? 0), taxableMinor: Number(b2b.taxableMinor ?? 0), taxMinor: Number(b2b.taxMinor ?? 0) },
    b2c: { count: Number(b2c.count ?? 0), taxableMinor: Number(b2c.taxableMinor ?? 0), taxMinor: Number(b2c.taxMinor ?? 0) },
  };
}

export async function getPartyBalances(query: ReportQuery): Promise<PartyBalancesReport> {
  if (demoMode) {
    await delay();
    const parties = getDemoState().parties;
    return {
      rows: parties.map((party) => ({
        partyId: party.id,
        name: party.name,
        kind: party.kind,
        phone: party.phone ?? "",
        receivableMinor: party.receivableMinor,
        payableMinor: party.payableMinor,
      })),
      totals: {
        receivableMinor: parties.reduce((sum, party) => sum + party.receivableMinor, 0),
        payableMinor: parties.reduce((sum, party) => sum + party.payableMinor, 0),
      },
    };
  }
  const raw = await apiRequest<Record<string, unknown>>(
    `/api/v1/reports/party-balances/?${reportParams(query)}`,
  );
  const totals = (raw.totals ?? {}) as Record<string, unknown>;
  return {
    totals: {
      receivableMinor: Number(totals.receivableMinor ?? 0),
      payableMinor: Number(totals.payableMinor ?? 0),
    },
    rows: Array.isArray(raw.rows)
      ? (raw.rows as Record<string, unknown>[]).map((row) => ({
          partyId: String(row.partyId ?? ""),
          name: String(row.name ?? ""),
          kind: String(row.kind ?? ""),
          phone: String(row.phone ?? ""),
          receivableMinor: Number(row.receivableMinor ?? 0),
          payableMinor: Number(row.payableMinor ?? 0),
        }))
      : [],
  };
}

export async function getStockValuation(query: ReportQuery): Promise<StockValuationReport> {
  if (demoMode) {
    await delay();
    const products = getDemoState().products;
    return {
      rows: products.map((product) => ({
        productId: product.id,
        name: product.name,
        unit: product.unit,
        quantity: product.onHand,
        costPerBaseUnitMinor: String(product.wholesalePriceMinor),
        stockValueCostMinor: Math.round(Number(product.onHand) * product.wholesalePriceMinor),
        retailPerBaseUnitMinor: String(product.retailPriceMinor),
        stockValueRetailMinor: Math.round(Number(product.onHand) * product.retailPriceMinor),
      })),
      totals: {
        costValueMinor: products.reduce((sum, product) => sum + Math.round(Number(product.onHand) * product.wholesalePriceMinor), 0),
        retailValueMinor: products.reduce((sum, product) => sum + Math.round(Number(product.onHand) * product.retailPriceMinor), 0),
        knownCostRows: products.length,
      },
    };
  }
  const raw = await apiRequest<Record<string, unknown>>(
    `/api/v1/reports/stock-valuation/?${reportParams(query)}`,
  );
  const totals = (raw.totals ?? {}) as Record<string, unknown>;
  return {
    totals: {
      costValueMinor: Number(totals.costValueMinor ?? 0),
      retailValueMinor: Number(totals.retailValueMinor ?? 0),
      knownCostRows: Number(totals.knownCostRows ?? 0),
    },
    rows: Array.isArray(raw.rows)
      ? (raw.rows as Record<string, unknown>[]).map((row) => ({
          productId: String(row.productId ?? ""),
          name: String(row.name ?? ""),
          unit: String(row.unit ?? ""),
          quantity: String(row.quantity ?? "0"),
          costPerBaseUnitMinor: row.costPerBaseUnitMinor != null ? String(row.costPerBaseUnitMinor) : null,
          stockValueCostMinor: row.stockValueCostMinor != null ? Number(row.stockValueCostMinor) : null,
          retailPerBaseUnitMinor: row.retailPerBaseUnitMinor != null ? String(row.retailPerBaseUnitMinor) : null,
          stockValueRetailMinor: row.stockValueRetailMinor != null ? Number(row.stockValueRetailMinor) : null,
        }))
      : [],
  };
}

export async function getStockMovements(
  query: ReportQuery & { productId?: string; movementType?: string },
): Promise<StockMovementRow[]> {
  if (demoMode) {
    await delay();
    return [];
  }
  const extra: Record<string, string> = {};
  if (query.productId) extra.product_id = query.productId;
  if (query.movementType) extra.movement_type = query.movementType;
  const raw = await apiRequest<unknown>(`/api/v1/stock/movements/?${reportParams(query, extra)}`);
  return recordList(raw).map((row) => ({
    id: String(row.id ?? ""),
    location: String(row.location ?? ""),
    product: String(row.product ?? ""),
    movementType: String(row.movementType ?? ""),
    quantity: String(row.quantity ?? "0"),
    sourceType: String(row.sourceType ?? ""),
    sourceId: String(row.sourceId ?? ""),
    note: row.note ? String(row.note) : undefined,
    occurredAt: String(row.occurredAt ?? ""),
  }));
}

function triggerDownload(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

export async function downloadReportCsv(
  query: ReportQuery & { report: ReportKind; groupBy?: string },
): Promise<void> {
  const extra: Record<string, string> = { report: query.report };
  if (query.groupBy) extra.group_by = query.groupBy;
  if (demoMode) {
    await delay();
    triggerDownload(
      new Blob(["key,label,count,grand_total_minor\n"], { type: "text/csv;charset=utf-8" }),
      `${query.report}.csv`,
    );
    return;
  }
  const token = await accessToken();
  const response = await fetch(`${apiUrl}/api/v1/reports/export/?${reportParams(query, extra)}`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });
  if (!response.ok) {
    throw new Error("The export could not be generated.");
  }
  triggerDownload(await response.blob(), `${query.report}.csv`);
}

export async function listActivity(
  businessId: string,
  options: { kind?: string; locationId?: string; limit?: number; offset?: number } = {},
): Promise<{ results: ActivityEvent[]; count: number }> {
  if (demoMode) {
    await delay();
    return { results: [], count: 0 };
  }
  const params = new URLSearchParams({ business_id: businessId });
  if (options.kind && options.kind !== "all") params.set("kind", options.kind);
  if (options.locationId) params.set("location_id", options.locationId);
  params.set("limit", String(options.limit ?? 50));
  params.set("offset", String(options.offset ?? 0));
  const res = await apiRequest<{ results: Record<string, unknown>[]; count: number }>(
    `/api/v1/activity/?${params}`,
  );
  return {
    count: Number(res.count ?? 0),
    results: res.results.map((row) => ({
      id: String(row.id),
      eventType: String(row.eventType ?? ""),
      aggregateType: String(row.aggregateType ?? ""),
      actorName: row.actorName ? String(row.actorName) : null,
      source: String(row.source ?? ""),
      metadata: (row.metadata ?? {}) as Record<string, unknown>,
      createdAt: String(row.createdAt ?? ""),
    })),
  };
}

export async function getNotificationPrefs(businessId: string): Promise<NotificationPrefs> {
  if (demoMode) {
    await delay();
    return {
      pushEnabled: true,
      smsEnabled: true,
      whatsappEnabled: false,
      dailySummary: true,
      lowStockAlerts: true,
      dueReminders: true,
    };
  }
  const row = await apiRequest<Record<string, unknown>>(
    `/api/v1/notification-preferences/?business_id=${businessId}`,
  );
  return {
    pushEnabled: Boolean(row.pushEnabled),
    smsEnabled: Boolean(row.smsEnabled),
    whatsappEnabled: Boolean(row.whatsappEnabled),
    dailySummary: Boolean(row.dailySummary),
    lowStockAlerts: Boolean(row.lowStockAlerts),
    dueReminders: Boolean(row.dueReminders),
  };
}

export async function updateNotificationPrefs(
  businessId: string,
  patch: Partial<NotificationPrefs>,
): Promise<NotificationPrefs> {
  if (demoMode) {
    await delay();
    return getNotificationPrefs(businessId);
  }
  const body: Record<string, unknown> = { business_id: businessId };
  if (patch.pushEnabled !== undefined) body.push_enabled = patch.pushEnabled;
  if (patch.smsEnabled !== undefined) body.sms_enabled = patch.smsEnabled;
  if (patch.whatsappEnabled !== undefined) body.whatsapp_enabled = patch.whatsappEnabled;
  if (patch.dailySummary !== undefined) body.daily_summary = patch.dailySummary;
  if (patch.lowStockAlerts !== undefined) body.low_stock_alerts = patch.lowStockAlerts;
  if (patch.dueReminders !== undefined) body.due_reminders = patch.dueReminders;
  const row = await apiRequest<Record<string, unknown>>("/api/v1/notification-preferences/", {
    method: "PATCH",
    body,
  });
  return {
    pushEnabled: Boolean(row.pushEnabled),
    smsEnabled: Boolean(row.smsEnabled),
    whatsappEnabled: Boolean(row.whatsappEnabled),
    dailySummary: Boolean(row.dailySummary),
    lowStockAlerts: Boolean(row.lowStockAlerts),
    dueReminders: Boolean(row.dueReminders),
  };
}

export async function listReminderSuggestions(businessId: string): Promise<ReminderSuggestion[]> {
  if (demoMode) {
    await delay();
    return [];
  }
  const res = await apiRequest<{ results: Record<string, unknown>[] }>(
    `/api/v1/reminders/suggestions/?business_id=${businessId}`,
  );
  return res.results.map((row) => ({
    type: String(row.type ?? "OVERDUE"),
    partyId: String(row.partyId ?? ""),
    partyName: String(row.partyName ?? ""),
    amountMinor: Number(row.amountMinor ?? 0),
    message: String(row.message ?? ""),
  }));
}

export async function createReminder(input: {
  businessId: string;
  partyId: string;
  channel?: string;
  locationId?: string;
}): Promise<Reminder> {
  if (demoMode) {
    await delay();
    return {
      id: crypto.randomUUID(),
      partyId: input.partyId,
      channel: input.channel ?? "SHARE",
      message: "Reminder prepared.",
      amountMinor: 0,
      status: "SENT",
      createdAt: new Date().toISOString(),
    };
  }
  const row = await apiRequest<Record<string, unknown>>("/api/v1/reminders/", {
    method: "POST",
    body: {
      business_id: input.businessId,
      party_id: input.partyId,
      channel: input.channel ?? "SHARE",
      ...(input.locationId ? { location_id: input.locationId } : {}),
    },
  });
  return {
    id: String(row.id),
    partyId: row.party ? String(row.party) : undefined,
    partyName: row.partyName ? String(row.partyName) : undefined,
    channel: String(row.channel ?? "SHARE"),
    message: String(row.message ?? ""),
    amountMinor: Number(row.amountMinor ?? 0),
    status: String(row.status ?? "PENDING") as Reminder["status"],
    sentAt: row.sentAt ? String(row.sentAt) : undefined,
    createdAt: String(row.createdAt ?? ""),
  };
}

export async function createExportJob(input: {
  businessId: string;
  report: string;
  format: "CSV" | "PDF";
  locationId?: string;
  from?: string;
  to?: string;
  groupBy?: string;
}): Promise<ExportJob> {
  if (demoMode) {
    await delay();
    return {
      id: crypto.randomUUID(),
      report: input.report,
      format: input.format,
      status: "READY",
      downloadUrl: null,
      createdAt: new Date().toISOString(),
    };
  }
  const row = await apiRequest<Record<string, unknown>>("/api/v1/exports/", {
    method: "POST",
    body: {
      business_id: input.businessId,
      report: input.report,
      format: input.format,
      ...(input.locationId ? { location_id: input.locationId } : {}),
      ...(input.from ? { from_date: input.from } : {}),
      ...(input.to ? { to_date: input.to } : {}),
      ...(input.groupBy ? { group_by: input.groupBy } : {}),
    },
  });
  return toExportJob(row);
}

export async function getExportJob(id: string): Promise<ExportJob> {
  if (demoMode) {
    await delay();
    return {
      id,
      report: "sales",
      format: "CSV",
      status: "READY",
      downloadUrl: null,
      createdAt: new Date().toISOString(),
    };
  }
  return toExportJob(await apiRequest<Record<string, unknown>>(`/api/v1/exports/${id}/`));
}

function toExportJob(row: Record<string, unknown>): ExportJob {
  return {
    id: String(row.id),
    report: String(row.report ?? ""),
    format: String(row.format ?? "CSV"),
    status: String(row.status ?? "PENDING") as ExportJob["status"],
    error: row.error ? String(row.error) : undefined,
    downloadUrl: row.downloadUrl ? String(row.downloadUrl) : null,
    createdAt: String(row.createdAt ?? ""),
  };
}

async function downloadAuthenticated(path: string, filename: string): Promise<void> {
  const token = await accessToken();
  const response = await fetch(`${apiUrl}${path}`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });
  if (!response.ok) throw new Error("The file could not be downloaded.");
  triggerDownload(await response.blob(), filename);
}

export async function downloadExportJob(job: ExportJob): Promise<void> {
  if (demoMode || !job.downloadUrl) return;
  const suffix = job.format === "PDF" ? "pdf" : "csv";
  await downloadAuthenticated(job.downloadUrl, `${job.report}.${suffix}`);
}

export async function waitForExportJob(id: string, attempts = 20): Promise<ExportJob> {
  for (let i = 0; i < attempts; i++) {
    const job = await getExportJob(id);
    if (job.status === "READY" || job.status === "FAILED") return job;
    await delay(1000);
  }
  return getExportJob(id);
}

export async function createSaleInvoice(saleId: string): Promise<Attachment> {
  if (demoMode) {
    await delay();
    return { id: crypto.randomUUID(), kind: "sale-invoice", status: "READY", downloadUrl: null, createdAt: new Date().toISOString() };
  }
  return toAttachment(
    await apiRequest<Record<string, unknown>>(`/api/v1/sales/${saleId}/invoice/`, {
      method: "POST",
    }),
  );
}

export async function getAttachment(id: string): Promise<Attachment> {
  if (demoMode) {
    await delay();
    return { id, kind: "sale-invoice", status: "READY", downloadUrl: null, createdAt: new Date().toISOString() };
  }
  return toAttachment(await apiRequest<Record<string, unknown>>(`/api/v1/attachments/${id}/`));
}

function toAttachment(row: Record<string, unknown>): Attachment {
  return {
    id: String(row.id),
    kind: String(row.kind ?? ""),
    sale: row.sale ? String(row.sale) : undefined,
    status: String(row.status ?? "PENDING") as Attachment["status"],
    downloadUrl: row.downloadUrl ? String(row.downloadUrl) : null,
    createdAt: String(row.createdAt ?? ""),
  };
}

export async function waitForAttachment(id: string, attempts = 20): Promise<Attachment> {
  for (let i = 0; i < attempts; i++) {
    const attachment = await getAttachment(id);
    if (attachment.status === "READY" || attachment.status === "FAILED") return attachment;
    await delay(1000);
  }
  return getAttachment(id);
}

export async function downloadAttachmentFile(attachment: Attachment): Promise<void> {
  if (demoMode || !attachment.downloadUrl) return;
  await downloadAuthenticated(attachment.downloadUrl, `invoice-${attachment.sale ?? attachment.id}.pdf`);
}
