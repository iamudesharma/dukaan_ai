import { apiRequest, newIdempotencyKey } from "../lib/api";
import { demoMode } from "../lib/supabase";
import type {
  AssistantProposal,
  Bootstrap,
  Business,
  DashboardSummary,
  Entry,
  GstRegistration,
  LedgerReport,
  Location,
  LocationInput,
  ManualSaleInput,
  Membership,
  MeProfile,
  Party,
  PartyInput,
  Product,
  ProductInput,
  ProposalRevision,
  ProposalSummary,
  PurchaseLineInput,
  Role,
  StockRow,
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
      paid_amount_minor: input.paidMinor,
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

// ---------------------------------------------------------------------------
// Auth (beyond login/OTP already in AuthGate + refresh in lib/api)
// ---------------------------------------------------------------------------

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
  return { id: String(row.id), name: String(row.name), legalName: String(row.legalName ?? row.name), currency: "INR", timezone: "Asia/Kolkata" };
}

export async function getBusiness(id: string): Promise<Business> {
  if (demoMode) {
    await delay();
    return demoBootstrap.business;
  }
  const row = await apiRequest<Record<string, unknown>>(`/api/v1/businesses/${id}/`);
  return { id: String(row.id), name: String(row.name), legalName: String(row.legalName ?? row.name), currency: "INR", timezone: "Asia/Kolkata" };
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
    packId: String(pack.id ?? row.id),
    name: String(row.name),
    sku: String(row.sku ?? ""),
    unit: String(row.baseUnit ?? "piece").toLowerCase(),
    onHand: "0",
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
          name: p.name,
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
    phone: row.phoneE164 ? String(row.phoneE164) : undefined,
    kind: String(row.kind ?? "CUSTOMER") as Party["kind"],
    receivableMinor: 0,
    payableMinor: 0,
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
