import { apiRequest, apiRequestFile, newIdempotencyKey } from "../lib/api";
import type {
  ActivityEvent,
  AssistantCommandType,
  AssistantAttachment,
  AssistantProposal,
  AuthCapabilities,
  Bootstrap,
  Business,
  CsvImportDryRun,
  DashboardSummary,
  Entry,
  EntryKind,
  GmailImportResult,
  GmailMessage,
  GmailReceiptExtraction,
  GmailStatus,
  GstRegistration,
  ImportConfirmation,
  ImportCounts,
  ImportDuplicateStrategy,
  ImportJob,
  ImportKind,
  ImportPreviewAction,
  ImportRowError,
  Invitation,
  InvitationCreateResult,
  InvoiceDownload,
  LedgerReport,
  Location,
  LocationInput,
  ManualSaleInput,
  Membership,
  MeProfile,
  NotificationDevice,
  OpenDocument,
  OutstandingDocument,
  Party,
  PartyInput,
  PaymentAllocation,
  PaymentAllocationInput,
  PaymentAllocationReview,
  PaymentDirection,
  PaymentRecord,
  Product,
  ProductInput,
  ProposalRevision,
  ProposalSummary,
  PurchaseLineInput,
  Reminder,
  ReminderInput,
  Role,
  StockRow,
  TransferLineInput,
  ValuationProductRow,
  ValuationReport,
} from "../types";

function finiteNumber(value: unknown): number | null {
  if (value === undefined || value === null || value === "") return null;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function minorFrom(
  record: Record<string, unknown>,
  minorKey: string,
  majorKey: string,
  fallback = 0,
): number {
  const explicitMinor = finiteNumber(record[minorKey]);
  if (explicitMinor !== null) return Math.round(explicitMinor);
  const legacyMajor = finiteNumber(record[majorKey]);
  if (legacyMajor !== null) return Math.round(legacyMajor * 100);
  return fallback;
}

function nullableMinorFrom(
  record: Record<string, unknown>,
  minorKey: string,
  majorKey: string,
): number | null {
  if (record[minorKey] === null) return null;
  const explicitMinor = finiteNumber(record[minorKey]);
  if (explicitMinor !== null) return Math.round(explicitMinor);
  const legacyMajor = finiteNumber(record[majorKey]);
  return legacyMajor === null ? null : Math.round(legacyMajor * 100);
}

function nullableApiMinorFrom(
  record: Record<string, unknown>,
  camelKey: string,
  snakeKey: string,
): number | null {
  const value = apiField(record, camelKey, snakeKey);
  if (value === null) return null;
  const parsed = finiteNumber(value);
  return parsed === null ? null : Math.round(parsed);
}

function asRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, unknown>
    : {};
}

function apiField(row: Record<string, unknown>, camelKey: string, snakeKey: string): unknown {
  return row[camelKey] !== undefined ? row[camelKey] : row[snakeKey];
}

function countFrom(value: unknown): number {
  return Math.max(0, Math.round(finiteNumber(value) ?? 0));
}

function stringList(value: unknown): string[] {
  return Array.isArray(value) ? value.map(String) : [];
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
  return apiRequest<Bootstrap>("/api/v1/bootstrap/");
}

export async function getDashboard(
  businessId: string,
  locationId: string,
): Promise<DashboardSummary> {
  const params = new URLSearchParams({ location_id: locationId });
  const raw = await apiRequest<Record<string, unknown>>(
    `/api/v1/reports/dashboard/?business_id=${businessId}&${params}`,
  );
  const today = asRecord(raw.today);
  const books = asRecord(raw.books);
  return {
    asOf: String(raw.asOf ?? new Date().toISOString()),
    salesMinor: minorFrom(today, "salesMinor", "sales"),
    collectionsMinor: minorFrom(books, "receiptsMinor", "receipts"),
    expensesMinor: minorFrom(today, "expensesMinor", "expenses"),
    cashFlowMinor: minorFrom(books, "cashFlowMinor", "cashFlow"),
    receivableMinor: minorFrom(books, "receivableMinor", "receivable"),
    payableMinor: minorFrom(books, "payableMinor", "payable"),
    lowStockCount: Math.round(finiteNumber(raw.lowStockCount) ?? 0),
    grossProfitMinor: nullableMinorFrom(raw, "grossProfitMinor", "grossProfit"),
    summary: String(raw.summary ?? "Your figures are based on posted entries for this location."),
  };
}

export async function getEntries(
  businessId: string,
  locationId: string,
  kinds: readonly EntryKind[] = ["SALE", "PURCHASE", "PAYMENT_IN", "PAYMENT_OUT", "EXPENSE"],
): Promise<Entry[]> {
  // Slim rows (no line items): the list only shows headers.
  const params = new URLSearchParams({ business_id: businessId, location_id: locationId, brief: "1" });
  const requested = new Set(kinds);
  const wantsPayments = requested.has("PAYMENT_IN") || requested.has("PAYMENT_OUT");
  const [sales, purchases, payments, expenses] = await Promise.all([
    requested.has("SALE") ? apiRequest<unknown>(`/api/v1/sales/?${params}`) : Promise.resolve([]),
    requested.has("PURCHASE") ? apiRequest<unknown>(`/api/v1/purchases/?${params}`) : Promise.resolve([]),
    wantsPayments ? apiRequest<unknown>(`/api/v1/payments/?${params}`) : Promise.resolve([]),
    requested.has("EXPENSE") ? apiRequest<unknown>(`/api/v1/expenses/?${params}`) : Promise.resolve([]),
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
    ...(requested.has("SALE") ? convert(recordList(sales), "SALE") : []),
    ...(requested.has("PURCHASE") ? convert(recordList(purchases), "PURCHASE") : []),
    ...(requested.has("PAYMENT_IN")
      ? convert(paymentRows.filter((row) => row.direction === "RECEIPT"), "PAYMENT_IN")
      : []),
    ...(requested.has("PAYMENT_OUT")
      ? convert(paymentRows.filter((row) => row.direction !== "RECEIPT"), "PAYMENT_OUT")
      : []),
    ...(requested.has("EXPENSE") ? convert(recordList(expenses), "EXPENSE") : []),
  ].sort((a, b) => b.occurredAt.localeCompare(a.occurredAt));
}

export async function getOpenDocuments(
  businessId: string,
  locationId: string,
  partyId: string,
  direction: "RECEIPT" | "PAYMENT",
): Promise<OpenDocument[]> {
  const collection = direction === "RECEIPT" ? "sales" : "purchases";
  const partyKey = direction === "RECEIPT" ? "customer" : "supplier";
  const partyIdKey = direction === "RECEIPT" ? "customerId" : "supplierId";
  const kind: OpenDocument["kind"] = direction === "RECEIPT" ? "SALE" : "PURCHASE";
  const params = new URLSearchParams({
    business_id: businessId,
    location_id: locationId,
    page_size: "200",
  });
  const response = await apiRequest<unknown>(`/api/v1/${collection}/?${params}`);
  return recordList(response)
    .filter((row) => row.status === undefined || String(row.status).toUpperCase() === "POSTED")
    .map((row) => {
      const relatedParty = asRecord(row[partyKey] ?? row.party);
      const documentPartyId = String(row[partyIdKey] ?? row.partyId ?? relatedParty.id ?? "");
      const outstandingMinor = minorFrom(row, "dueTotalMinor", "dueTotal", minorFrom(row, "outstandingMinor", "outstanding"));
      return {
        id: String(row.id),
        kind,
        number: String(row.number ?? row.reference ?? row.id),
        partyId: documentPartyId,
        partyName: String(relatedParty.name ?? row.partyName ?? ""),
        occurredAt: String(row.postedAt ?? row.documentDate ?? row.createdAt ?? ""),
        totalMinor: minorFrom(row, "grandTotalMinor", "grandTotal"),
        outstandingMinor,
      };
    })
    .filter((document) =>
      document.partyId === partyId
      && document.outstandingMinor > 0,
    )
    .sort((a, b) => b.occurredAt.localeCompare(a.occurredAt));
}

export async function getProducts(
  businessId: string,
  locationId: string,
  options: { includeWholesalePrices?: boolean } = {},
): Promise<Product[]> {
  // Pickers need the whole catalog: bounded page, not the 50 default.
  const params = new URLSearchParams({ business_id: businessId, location_id: locationId, page_size: "200" });
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
      onHand: String(row.stockQuantity ?? row.onHand ?? row.quantityOnHand ?? row.stock ?? "0"),
      reorderLevel: String(row.lowStockThreshold ?? row.reorderLevel ?? "0"),
      isLowStock: typeof row.isLowStock === "boolean" ? row.isLowStock : undefined,
      retailPriceMinor: minorFrom(pack, "retailPriceMinor", "retailPrice"),
      wholesalePriceMinor: options.includeWholesalePrices === false
        ? 0
        : minorFrom(pack, "wholesalePriceMinor", "wholesalePrice"),
      gstRateBps: row.taxRateBps !== undefined
        ? Number(row.taxRateBps)
        : Math.round(Number(row.taxRate ?? 0) * 100),
    };
  });
}

function mapParty(row: Record<string, unknown>, customersOnly = false): Party {
  const kind = String(row.kind ?? "CUSTOMER") as Party["kind"];
  return {
    id: String(row.id),
    name: String(row.name),
    phone: row.phoneE164 !== undefined
      ? String(row.phoneE164)
      : row.phone !== undefined ? String(row.phone) : undefined,
    kind: customersOnly && kind === "BOTH" ? "CUSTOMER" : kind,
    receivableMinor: minorFrom(row, "receivableMinor", "receivableBalance"),
    payableMinor: customersOnly ? 0 : minorFrom(row, "payableMinor", "payableBalance"),
    priceTier: customersOnly ? "RETAIL" : String(row.priceTier ?? "RETAIL") as Party["priceTier"],
  };
}

export async function getParties(
  businessId: string,
  options: { customersOnly?: boolean } = {},
): Promise<Party[]> {
  // Pickers need the whole address book: bounded page, not the 50 default.
  const response = await apiRequest<unknown>(`/api/v1/parties/?business_id=${businessId}&page_size=200`);
  return recordList(response)
    .filter((row) => !options.customersOnly || String(row.kind ?? "CUSTOMER") !== "SUPPLIER")
    .map((row) => mapParty(row, options.customersOnly));
}

export interface ProposalLookupOptions {
  customersOnly?: boolean;
  includeWholesalePrices?: boolean;
  skipLookups?: boolean;
}

export const MAX_RECEIPT_BYTES = 8 * 1024 * 1024;
export const RECEIPT_MIME_TYPES = ["image/jpeg", "image/png", "application/pdf"] as const;

export async function uploadReceiptAttachment(input: {
  businessId: string;
  file: File;
}): Promise<AssistantAttachment> {
  const mime = input.file.type.toLowerCase();
  if (!RECEIPT_MIME_TYPES.includes(mime as typeof RECEIPT_MIME_TYPES[number])) {
    throw new Error("Choose a JPEG, PNG, or PDF receipt.");
  }
  if (input.file.size <= 0) {
    throw new Error("The selected file is empty.");
  }
  if (input.file.size > MAX_RECEIPT_BYTES) {
    throw new Error("The receipt must be 8 MB or smaller.");
  }
  const body = new FormData();
  body.append("business_id", input.businessId);
  body.append("kind", "IMAGE");
  body.append("mime", mime);
  body.append("size_bytes", String(input.file.size));
  body.append("file", input.file, input.file.name);
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/assistant/attachments/upload/", {
    method: "POST",
    body,
  });
  return {
    id: String(raw.id),
    businessId: String(raw.businessId ?? raw.business ?? input.businessId),
    kind: "IMAGE",
    mime: String(raw.mime ?? mime),
    sizeBytes: Number(raw.sizeBytes ?? input.file.size),
    status: String(raw.status ?? "READY").toUpperCase() === "FAILED" ? "FAILED" : "READY",
    proposalId: raw.proposalId ? String(raw.proposalId) : undefined,
    createdAt: raw.createdAt ? String(raw.createdAt) : undefined,
  };
}

export async function createProposalFromImage(input: {
  attachmentId: string;
  businessId: string;
  locationId: string;
  locale?: string;
  lookupOptions?: ProposalLookupOptions;
}): Promise<AssistantProposal> {
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/assistant/proposals/from-image/", {
    method: "POST",
    body: {
      attachment_id: input.attachmentId,
      business_id: input.businessId,
      location_id: input.locationId,
      locale: input.locale ?? "en-IN",
    },
  });
  const pending = String(raw.status ?? "").toUpperCase() === "DRAFT" && !String(raw.content ?? "").trim();
  return mapProposal(raw, input.businessId, input.locationId, "", {
    ...input.lookupOptions,
    skipLookups: pending || input.lookupOptions?.skipLookups,
  });
}

function receiptProposalIsTerminal(raw: Record<string, unknown>): boolean {
  const status = String(raw.status ?? "").toUpperCase();
  if (status !== "DRAFT") return true;
  if (String(raw.content ?? "").trim()) return true;
  const questions = Array.isArray(raw.blockingQuestions) ? raw.blockingQuestions.map(String) : [];
  // OCR failures replace the processing placeholder with a durable question.
  return questions.length > 0 && !questions.some((question) => /being read/i.test(question));
}

function waitForPoll(intervalMs: number, signal?: AbortSignal): Promise<void> {
  return new Promise((resolve, reject) => {
    if (signal?.aborted) {
      reject(new DOMException("OCR polling was cancelled.", "AbortError"));
      return;
    }
    const timer = window.setTimeout(() => {
      signal?.removeEventListener("abort", onAbort);
      resolve();
    }, intervalMs);
    const onAbort = () => {
      window.clearTimeout(timer);
      reject(new DOMException("OCR polling was cancelled.", "AbortError"));
    };
    signal?.addEventListener("abort", onAbort, { once: true });
  });
}

export async function pollAssistantProposal(input: {
  proposalId: string;
  businessId: string;
  locationId: string;
  lookupOptions?: ProposalLookupOptions;
  signal?: AbortSignal;
  intervalMs?: number;
  maxAttempts?: number;
  onWaiting?: (attempt: number) => void;
}): Promise<AssistantProposal> {
  const intervalMs = input.intervalMs ?? 1500;
  const maxAttempts = Math.max(1, input.maxAttempts ?? 80);
  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    if (input.signal?.aborted) {
      throw new DOMException("OCR polling was cancelled.", "AbortError");
    }
    const raw = await apiRequest<Record<string, unknown>>(
      `/api/v1/assistant/proposals/${input.proposalId}/`,
      { signal: input.signal },
    );
    input.onWaiting?.(attempt);
    const terminal = receiptProposalIsTerminal(raw);
    const proposal = await mapProposal(raw, input.businessId, input.locationId, "", {
      ...input.lookupOptions,
      skipLookups: !terminal || !String(raw.content ?? "").trim() || input.lookupOptions?.skipLookups,
    });
    if (terminal) return proposal;
    if (attempt === maxAttempts) break;
    await waitForPoll(intervalMs, input.signal);
  }
  throw new Error("Reading the receipt took too long. Please try again.");
}

export async function interpretCommand(
  businessId: string,
  locationId: string,
  text: string,
  options: ProposalLookupOptions = {},
): Promise<AssistantProposal> {
  const raw = await apiRequest<Record<string, unknown>>(
    "/api/v1/assistant/proposals/",
    {
      method: "POST",
      body: { business_id: businessId, input_type: "TEXT", content: text, location_id: locationId, locale: "en-IN" },
    },
  );
  return mapProposal(raw, businessId, locationId, text, options);
}

export async function reviseCommand(
  businessId: string, proposal: AssistantProposal, text?: string,
  options: ProposalLookupOptions = {},
): Promise<AssistantProposal> {
  const raw = await apiRequest<Record<string, unknown>>(
    `/api/v1/assistant/proposals/${proposal.id}/revise/`,
    { method: "POST", body: { version: proposal.version, ...(text === undefined ? {} : { content: text }) } },
  );
  return mapProposal(raw, businessId, proposal.locationId, text ?? proposal.sourceText, options);
}

function normalizeCommandType(value: unknown): AssistantCommandType {
  switch (String(value ?? "").toUpperCase()) {
    case "SALE":
    case "RECORD_SALE":
      return "SALE";
    case "PURCHASE":
    case "RECORD_PURCHASE":
      return "PURCHASE";
    case "PAYMENT":
    case "RECORD_PAYMENT":
      return "PAYMENT";
    case "EXPENSE":
    case "RECORD_EXPENSE":
      return "EXPENSE";
    case "TRANSFER":
      return "TRANSFER";
    case "UNSUPPORTED":
      return "UNSUPPORTED";
    default:
      return "UNKNOWN";
  }
}

function intentForCommand(commandType: AssistantCommandType): AssistantProposal["intent"] {
  switch (commandType) {
    case "SALE": return "RECORD_SALE";
    case "PURCHASE": return "RECORD_PURCHASE";
    case "PAYMENT": return "RECORD_PAYMENT";
    case "EXPENSE": return "RECORD_EXPENSE";
    default: return "UNSUPPORTED";
  }
}

function safeQuantity(value: unknown): string {
  const quantity = finiteNumber(value);
  return quantity !== null && quantity >= 0 ? String(quantity) : "0";
}

function multiplyMinor(quantity: unknown, unitMinor: number): number {
  const count = finiteNumber(quantity) ?? 0;
  const total = count * unitMinor;
  return Number.isFinite(total) ? Math.round(total) : 0;
}

function mapAssistantStatus(value: unknown): AssistantProposal["status"] {
  switch (String(value ?? "").toUpperCase()) {
    case "DRAFT": return "NEEDS_DETAILS";
    case "READY": return "READY";
    case "CONFIRMED": return "CONFIRMED";
    case "CANCELLED": return "CANCELLED";
    case "EXPIRED": return "EXPIRED";
    case "FAILED": return "FAILED";
    default: return "NEEDS_DETAILS";
  }
}

async function mapProposal(
  raw: Record<string, unknown>, businessId: string, locationId: string, text: string,
  options: ProposalLookupOptions = {},
): Promise<AssistantProposal> {
  const commandType = normalizeCommandType(raw.commandType ?? raw.intent);
  const intent = intentForCommand(commandType);

  // Older deployments returned the already-normalized UI shape. Preserve it,
  // but still attach the command type and guard all arithmetic.
  if (raw.intent && Array.isArray(raw.lines)) {
    const lines = (raw.lines as Record<string, unknown>[]).map((line) => {
      const quantity = safeQuantity(line.quantity);
      const unitPriceMinor = Math.round(finiteNumber(line.unitPriceMinor) ?? 0);
      return {
        productId: line.productId ? String(line.productId) : undefined,
        productName: String(line.productName ?? "Product"),
        quantity,
        unit: String(line.unit ?? "piece"),
        unitPriceMinor,
        lineTotalMinor: Math.round(finiteNumber(line.lineTotalMinor) ?? multiplyMinor(quantity, unitPriceMinor)),
        proposedNew: Boolean(line.proposedNew),
      };
    });
    const totalMinor = Math.round(finiteNumber(raw.totalMinor) ?? lines.reduce((sum, line) => sum + line.lineTotalMinor, 0));
    const paidMinor = Math.round(finiteNumber(raw.paidMinor) ?? 0);
    return {
      ...(raw as unknown as AssistantProposal),
      commandType,
      intent,
      status: mapAssistantStatus(raw.status),
      lines,
      totalMinor,
      paidMinor,
      outstandingMinor: Math.max(0, totalMinor - paidMinor),
      taxMinor: Math.round(finiteNumber(raw.taxMinor) ?? 0),
    };
  }

  const payload = asRecord(raw.payload);
  const rawLines = Array.isArray(payload.lines) ? payload.lines as Record<string, unknown>[] : [];
  const [products, parties] = options.skipLookups ? [[], []] : await Promise.all([
    getProducts(businessId, locationId, { includeWholesalePrices: options.includeWholesalePrices }),
    getParties(businessId, { customersOnly: options.customersOnly }),
  ]);
  const lines = rawLines.map((line) => {
    const packId = String(line.packId ?? "");
    const product = products.find((candidate) => candidate.packId === packId || candidate.id === String(line.productId ?? ""));
    const quantity = safeQuantity(line.quantity);
    const preferredPriceKey = commandType === "PURCHASE" ? "unitCostMinor" : "unitPriceMinor";
    const preferredMajorKey = commandType === "PURCHASE" ? "unitCost" : "unitPrice";
    const alternateMinorKey = commandType === "PURCHASE" ? "unitPriceMinor" : "unitCostMinor";
    const alternateMajorKey = commandType === "PURCHASE" ? "unitPrice" : "unitCost";
    const unitPriceMinor = minorFrom(
      line,
      preferredPriceKey,
      preferredMajorKey,
      minorFrom(line, alternateMinorKey, alternateMajorKey),
    );
    return {
      productId: product?.id ?? (line.productId ? String(line.productId) : undefined),
      productName: product?.name ?? String(line.productName ?? line.description ?? "Product"),
      quantity,
      unit: product?.unit ?? String(line.unit ?? "piece"),
      unitPriceMinor,
      lineTotalMinor: minorFrom(line, "lineTotalMinor", "lineTotal", multiplyMinor(quantity, unitPriceMinor)),
      proposedNew: Boolean(line.proposedNew),
    };
  });
  const lineTotal = lines.reduce((sum, line) => sum + line.lineTotalMinor, 0);
  const explicitTotal = commandType === "EXPENSE"
    ? finiteNumber(payload.totalMinor) ?? finiteNumber(payload.amountMinor)
    : finiteNumber(payload.grandTotalMinor) ?? finiteNumber(payload.totalMinor);
  const totalMinor = Math.round(explicitTotal ?? lineTotal);
  const rawPaidMinor = finiteNumber(payload.paidMinor) ?? finiteNumber(payload.paidAmountMinor);
  const paidMinor = commandType === "EXPENSE" ? totalMinor : Math.round(rawPaidMinor ?? 0);
  const outstandingMinor = Math.max(0, totalMinor - paidMinor);
  const customerId = payload.customerId ? String(payload.customerId) : undefined;
  const supplierId = payload.supplierId ? String(payload.supplierId) : undefined;
  const partyId = customerId ?? supplierId ?? (payload.partyId ? String(payload.partyId) : undefined);
  const party = parties.find((candidate) => candidate.id === partyId);
  const newPartyName = payload.newCustomerName ?? payload.newSupplierName;
  const partyName = party?.name
    ?? (newPartyName ? String(newPartyName) : undefined)
    ?? (payload.customerName ? String(payload.customerName) : undefined)
    ?? (payload.supplierName ? String(payload.supplierName) : undefined)
    ?? (payload.partyName ? String(payload.partyName) : undefined)
    ?? (payload.payee ? String(payload.payee) : undefined);
  const warnings = Array.isArray(raw.warnings) ? raw.warnings.map(String) : [];
  const questions = Array.isArray(raw.blockingQuestions) ? raw.blockingQuestions.map(String) : [];
  const paymentDirection = payload.direction === "PAYMENT" || payload.direction === "RECEIPT"
    ? payload.direction
    : undefined;
  const stockEffects = commandType === "SALE"
    ? lines.map((line) => `Reduce ${line.productName} stock by ${line.quantity} ${line.unit}`)
    : commandType === "PURCHASE"
      ? lines.map((line) => `Increase ${line.productName} stock by ${line.quantity} ${line.unit}`)
      : [];
  const outstandingRupees = (outstandingMinor / 100).toLocaleString("en-IN");
  const totalRupees = (totalMinor / 100).toLocaleString("en-IN");
  const ledger = commandType === "SALE"
    ? outstandingMinor > 0
      ? `Add ₹${outstandingRupees} to the customer's outstanding balance`
      : "No customer balance remains outstanding"
    : commandType === "PURCHASE"
      ? outstandingMinor > 0
        ? `Add ₹${outstandingRupees} to the supplier's payable balance`
        : "No supplier balance remains outstanding"
      : commandType === "EXPENSE"
        ? `Record ₹${totalRupees} as a business expense`
        : commandType === "PAYMENT"
          ? `Record ₹${totalRupees} as money ${paymentDirection === "PAYMENT" ? "paid out" : "received"}`
          : "Resolve the command details before confirmation";

  return {
    id: String(raw.id),
    version: Number(raw.version ?? 1),
    status: mapAssistantStatus(raw.status),
    commandType,
    intent,
    paymentDirection,
    sourceText: String(raw.content ?? text),
    partyId,
    partyName,
    partyProposedNew: Boolean(newPartyName),
    lines,
    totalMinor,
    paidMinor,
    outstandingMinor,
    taxMinor: minorFrom(payload, "taxMinor", "taxAmount", minorFrom(payload, "taxTotalMinor", "taxTotal")),
    locationId,
    warnings,
    questions,
    effects: { stock: stockEffects, ledger },
  };
}

export async function confirmCommand(
  businessId: string,
  proposal: AssistantProposal,
): Promise<Entry> {
  const idempotencyKey = `proposal:${proposal.id}:v${proposal.version}`;
  const response = await apiRequest<{ result: Record<string, unknown>; proposal?: Record<string, unknown> }>(
    `/api/v1/assistant/proposals/${proposal.id}/confirm/`,
    {
      method: "POST",
      idempotencyKey,
      body: { version: proposal.version, idempotency_key: idempotencyKey },
    },
  );
  const result = asRecord(response.result);
  const confirmedProposal = asRecord(response.proposal);
  const resultType = String(confirmedProposal.confirmedResultType ?? "");
  const commandType = resultType.includes("purchase")
    ? "PURCHASE"
    : resultType.includes("expense")
      ? "EXPENSE"
      : normalizeCommandType(proposal.commandType);
  const kind: Entry["kind"] = commandType === "PURCHASE"
    ? "PURCHASE"
    : commandType === "EXPENSE"
      ? "EXPENSE"
      : commandType === "PAYMENT"
        ? proposal.paymentDirection === "PAYMENT" ? "PAYMENT_OUT" : "PAYMENT_IN"
        : "SALE";
  const relatedParty = asRecord(result.customer ?? result.supplier ?? result.party);
  return {
    id: String(result.id),
    number: String(result.number ?? result.reference ?? result.id),
    kind,
    partyName: proposal.partyName ?? String(relatedParty.name ?? result.payee ?? (kind === "PURCHASE" ? "Supplier" : kind === "EXPENSE" ? "Expense" : "Cash customer")),
    occurredAt: String(result.postedAt ?? result.paymentDate ?? result.createdAt ?? new Date().toISOString()),
    totalMinor: kind === "EXPENSE"
      ? minorFrom(result, "totalMinor", "total")
      : kind === "PAYMENT_IN" || kind === "PAYMENT_OUT"
        ? minorFrom(result, "amountMinor", "amount")
        : minorFrom(result, "grandTotalMinor", "grandTotal"),
    outstandingMinor: kind === "EXPENSE" || kind === "PAYMENT_IN" || kind === "PAYMENT_OUT"
      ? 0
      : minorFrom(result, "dueTotalMinor", "dueTotal"),
    status: String(result.status ?? "POSTED") as Entry["status"],
    paymentMode: String(result.method ?? result.paymentMethod ?? "") || (proposal.paidMinor > 0 ? "CASH" : undefined),
  };
}

export async function recordManualSale(input: ManualSaleInput): Promise<Entry> {

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
// Auth. Every call goes through apiRequest so it honours VITE_API_URL.
// ---------------------------------------------------------------------------

export interface AuthResult {
  access: string;
  refresh: string;
  onboardingRequired: boolean;
}

export async function getAuthCapabilities(): Promise<AuthCapabilities> {
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/auth/capabilities/");
  return {
    password: Boolean(raw.password),
    otp: Boolean(raw.otp),
    devOtp: Boolean(raw.devOtp),
  };
}

function toAuthResult(raw: Record<string, unknown>): AuthResult {
  return {
    access: String(raw.access),
    refresh: String(raw.refresh),
    onboardingRequired: Boolean(raw.onboardingRequired),
  };
}

export async function signup(
  phone: string,
  password: string,
  displayName?: string,
): Promise<AuthResult> {
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/auth/signup/", {
    method: "POST",
    body: { phone, password, ...(displayName ? { display_name: displayName } : {}) },
  });
  return toAuthResult(raw);
}

export async function login(phone: string, password: string): Promise<AuthResult> {
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/auth/login/", {
    method: "POST",
    body: { phone, password },
  });
  return toAuthResult(raw);
}

export async function sendOtp(phone: string): Promise<string | undefined> {
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/auth/otp/send/", {
    method: "POST",
    body: { phone },
  });
  return raw.devOtp as string | undefined;
}

export async function verifyOtp(phone: string, otp: string): Promise<AuthResult> {
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/auth/otp/verify/", {
    method: "POST",
    body: { phone, otp },
  });
  return toAuthResult(raw);
}

export async function logout(refresh: string | null): Promise<void> {
  await apiRequest("/api/v1/auth/logout/", {
    method: "POST",
    body: { ...(refresh ? { refresh } : {}) },
  });
}

export async function changePassword(oldPassword: string, newPassword: string) {
  await apiRequest("/api/v1/auth/password/change/", {
    method: "POST",
    body: { old_password: oldPassword, new_password: newPassword },
  });
}

export async function revokeAllSessions(currentPassword: string): Promise<{ detail: string; tokenVersion: number }> {
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/auth/sessions/revoke-all/", {
    method: "POST",
    body: { password: currentPassword },
  });
  return {
    detail: String(raw.detail ?? "All sessions have been revoked."),
    tokenVersion: countFrom(raw.tokenVersion),
  };
}

export async function requestPasswordReset(phone: string): Promise<string | undefined> {
  const res = await apiRequest<Record<string, unknown>>("/api/v1/auth/password/reset/", {
    method: "POST",
    body: { phone },
  });
  return res.devOtp as string | undefined;
}

export async function confirmPasswordReset(phone: string, otp: string, newPassword: string) {
  await apiRequest("/api/v1/auth/password/reset/confirm/", {
    method: "POST",
    body: { phone, otp, new_password: newPassword },
  });
}

// ---------------------------------------------------------------------------
// Common
// ---------------------------------------------------------------------------

export async function getMe(): Promise<MeProfile> {
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
  const res = await apiRequest<unknown>("/api/v1/businesses/");
  return recordList(res).map((row) => ({
    id: String(row.id),
    name: String(row.name),
    legalName: String(row.legalName ?? row.name),
    currency: "INR" as const,
    timezone: "Asia/Kolkata" as const,
  }));
}

export async function createBusiness(input: {
  name: string;
  legalName?: string;
  gstin?: string;
  stateCode?: string;
  locationName?: string;
}): Promise<Business> {
  const row = await apiRequest<Record<string, unknown>>("/api/v1/businesses/", {
    method: "POST",
    body: {
      name: input.name,
      legal_name: input.legalName ?? input.name,
      ...(input.locationName ? { location_name: input.locationName } : {}),
      ...(input.stateCode ? { state_code: input.stateCode } : {}),
      ...(input.gstin ? { gstin: input.gstin } : {}),
    },
  });
  return { id: String(row.id), name: String(row.name), legalName: String(row.legalName ?? row.name), currency: "INR", timezone: "Asia/Kolkata" };
}

export async function getBusiness(id: string): Promise<Business> {
  const row = await apiRequest<Record<string, unknown>>(`/api/v1/businesses/${id}/`);
  return { id: String(row.id), name: String(row.name), legalName: String(row.legalName ?? row.name), currency: "INR", timezone: "Asia/Kolkata" };
}

export async function listLocations(businessId: string): Promise<Location[]> {
  const res = await apiRequest<unknown>(`/api/v1/locations/?business_id=${businessId}`);
  return recordList(res).map((row) => ({
    id: String(row.id),
    name: String(row.name),
    code: String(row.code ?? ""),
    stateCode: String(row.stateCode ?? ""),
  }));
}

export async function createLocation(input: LocationInput): Promise<Location> {
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
  await apiRequest(`/api/v1/locations/${id}/`, { method: "DELETE" });
}

export async function listGstRegistrations(businessId: string): Promise<GstRegistration[]> {
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
  return apiRequest<unknown>("/api/v1/memberships/", { method: "POST", body: input });
}

export async function updateMembership(id: string, patch: { role?: Role; locations?: string[] }) {
  return apiRequest<unknown>(`/api/v1/memberships/${id}/`, { method: "PATCH", body: patch });
}

export async function deleteMembership(id: string) {
  await apiRequest(`/api/v1/memberships/${id}/`, { method: "DELETE" });
}

function mapInvitation(row: Record<string, unknown>): Invitation {
  return {
    id: String(row.id),
    business: String(row.business ?? ""),
    inviteePhone: String(row.inviteePhone ?? ""),
    role: String(row.role) as Role,
    locations: stringList(row.locations),
    status: String(row.status) as Invitation["status"],
    expiresAt: String(row.expiresAt ?? ""),
    inviter: String(row.inviter ?? ""),
    acceptedBy: row.acceptedBy ? String(row.acceptedBy) : undefined,
    acceptedAt: row.acceptedAt ? String(row.acceptedAt) : undefined,
    revokedAt: row.revokedAt ? String(row.revokedAt) : undefined,
    createdAt: row.createdAt ? String(row.createdAt) : undefined,
    updatedAt: row.updatedAt ? String(row.updatedAt) : undefined,
  };
}

export async function listInvitations(businessId: string): Promise<Invitation[]> {
  const response = await apiRequest<unknown>(`/api/v1/invitations/?business_id=${encodeURIComponent(businessId)}`);
  return recordList(response).map(mapInvitation);
}

export async function createInvitation(input: {
  business: string;
  inviteePhone: string;
  role: Role;
  locations?: string[];
  expiresAt?: string;
}): Promise<InvitationCreateResult> {
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/invitations/", {
    method: "POST",
    body: {
      business: input.business,
      invitee_phone: input.inviteePhone,
      role: input.role,
      locations: input.locations ?? [],
      ...(input.expiresAt ? { expires_at: input.expiresAt } : {}),
    },
  });
  if (!raw.token) throw new Error("The invitation token was not returned. Please create the invitation again.");
  return { ...mapInvitation(raw), token: String(raw.token) };
}

export async function revokeInvitation(id: string): Promise<Invitation> {
  const raw = await apiRequest<Record<string, unknown>>(`/api/v1/invitations/${id}/revoke/`, { method: "POST" });
  return mapInvitation(raw);
}

export async function acceptInvitation(token: string): Promise<Invitation> {
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/invitations/accept/", {
    method: "POST",
    body: { token },
  });
  return mapInvitation(raw);
}

// ---------------------------------------------------------------------------
// Catalog: product / party CRUD + detail
// ---------------------------------------------------------------------------

export async function getProduct(id: string): Promise<Product | null> {
  const row = await apiRequest<Record<string, unknown>>(`/api/v1/products/${id}/`);
  const packs = Array.isArray(row.packs) ? (row.packs as Record<string, unknown>[]) : [];
  const pack = packs[0] ?? {};
  return {
    id: String(row.id),
    packId: String(pack.id ?? row.id),
    name: String(row.name),
    sku: String(row.sku ?? ""),
    unit: String(row.baseUnit ?? row.unit ?? "piece").toLowerCase(),
    onHand: String(row.stockQuantity ?? row.onHand ?? row.quantityOnHand ?? row.stock ?? "0"),
    reorderLevel: String(row.lowStockThreshold ?? row.reorderLevel ?? "0"),
    isLowStock: typeof row.isLowStock === "boolean" ? row.isLowStock : undefined,
    retailPriceMinor: minorFrom(pack, "retailPriceMinor", "retailPrice"),
    wholesalePriceMinor: minorFrom(pack, "wholesalePriceMinor", "wholesalePrice"),
    gstRateBps: row.taxRateBps !== undefined ? Number(row.taxRateBps) : 0,
  };
}

export async function createProduct(input: ProductInput) {
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
  await apiRequest(`/api/v1/products/${id}/`, { method: "DELETE" });
}

export async function getParty(businessId: string, id: string): Promise<Party | null> {
  const row = await apiRequest<Record<string, unknown>>(`/api/v1/parties/${id}/?business_id=${businessId}`);
  return mapParty(row);
}

export async function createParty(input: PartyInput) {
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
  await apiRequest(`/api/v1/parties/${id}/`, { method: "DELETE" });
}

// ---------------------------------------------------------------------------
// Catalog CSV imports: dry runs and job preparation never write catalog rows.
// ---------------------------------------------------------------------------

export const MAX_CSV_BYTES = 2 * 1024 * 1024;

function mapImportErrors(value: unknown): ImportRowError[] {
  if (!Array.isArray(value)) return [];
  return value.map((item) => {
    const row = asRecord(item);
    const errors = Object.entries(asRecord(row.errors)).map(([field, messages]) => [
      field,
      Array.isArray(messages) ? messages.map(String) : [String(messages)],
    ] as const);
    return { row: countFrom(row.row), errors: Object.fromEntries(errors) };
  });
}

function mapImportCounts(row: Record<string, unknown>): ImportCounts {
  return {
    rowCount: countFrom(apiField(row, "rowCount", "row_count")),
    validRowCount: countFrom(apiField(row, "validRowCount", "valid_row_count")),
    errorCount: countFrom(apiField(row, "errorCount", "error_count")),
    createdCount: countFrom(apiField(row, "createdCount", "created_count")),
    updatedCount: countFrom(apiField(row, "updatedCount", "updated_count")),
    skippedCount: countFrom(apiField(row, "skippedCount", "skipped_count")),
  };
}

function mapImportJob(row: Record<string, unknown>): ImportJob {
  return {
    id: String(row.id),
    business: String(row.business ?? ""),
    kind: String(row.kind) as ImportKind,
    status: String(row.status) as ImportJob["status"],
    duplicateStrategy: String(row.duplicateStrategy ?? "UPDATE") as ImportDuplicateStrategy,
    ...mapImportCounts(row),
    errors: mapImportErrors(row.errors),
    originalFilename: String(row.originalFilename ?? "catalog.csv"),
    createdAt: row.createdAt ? String(row.createdAt) : undefined,
    updatedAt: row.updatedAt ? String(row.updatedAt) : undefined,
    confirmedAt: row.confirmedAt ? String(row.confirmedAt) : undefined,
  };
}

function validateCsvFile(file: File): void {
  if (!file.name.toLowerCase().endsWith(".csv")) {
    throw new Error("Choose a CSV file with a .csv extension.");
  }
  if (file.size <= 0) throw new Error("The selected CSV is empty.");
  if (file.size > MAX_CSV_BYTES) throw new Error("The CSV must be 2 MB or smaller.");
}

async function uploadCsvImport(input: {
  businessId: string;
  kind: ImportKind;
  file: File;
  duplicateStrategy: ImportDuplicateStrategy;
  dryRun: boolean;
}): Promise<CsvImportDryRun | ImportJob> {
  validateCsvFile(input.file);
  const path = input.kind === "PRODUCT" ? "products" : "parties";
  const body = new FormData();
  body.append("business_id", input.businessId);
  body.append("dry_run", String(input.dryRun));
  body.append("duplicate_strategy", input.duplicateStrategy);
  body.append("file", input.file, input.file.name);
  const raw = await apiRequest<Record<string, unknown>>(`/api/v1/imports/${path}/`, {
    method: "POST",
    body,
  });
  if (input.dryRun || raw.dryRun === true) {
    const preview = Array.isArray(raw.preview) ? raw.preview as Record<string, unknown>[] : [];
    return {
      dryRun: true,
      kind: String(raw.kind ?? input.kind) as ImportKind,
      duplicateStrategy: String(raw.duplicateStrategy ?? input.duplicateStrategy) as ImportDuplicateStrategy,
      ...mapImportCounts(raw),
      errors: mapImportErrors(raw.errors),
      preview: preview.map((item) => ({
        row: countFrom(item.row),
        action: String(item.action) as ImportPreviewAction,
      })),
    };
  }
  return mapImportJob(raw);
}

export function dryRunCsvImport(input: {
  businessId: string;
  kind: ImportKind;
  file: File;
  duplicateStrategy: ImportDuplicateStrategy;
}): Promise<CsvImportDryRun> {
  return uploadCsvImport({ ...input, dryRun: true }) as Promise<CsvImportDryRun>;
}

export function createCsvImportJob(input: {
  businessId: string;
  kind: ImportKind;
  file: File;
  duplicateStrategy: ImportDuplicateStrategy;
}): Promise<ImportJob> {
  return uploadCsvImport({ ...input, dryRun: false }) as Promise<ImportJob>;
}

export async function confirmCsvImport(
  jobId: string,
  idempotencyKey = `import-${jobId}`,
): Promise<ImportConfirmation> {
  const raw = await apiRequest<Record<string, unknown>>(`/api/v1/imports/${jobId}/confirm/`, {
    method: "POST",
    idempotencyKey,
    body: { idempotency_key: idempotencyKey },
  });
  return { job: mapImportJob(asRecord(raw.job)), replayed: Boolean(raw.replayed) };
}

export async function downloadSaleInvoicePdf(saleId: string): Promise<InvoiceDownload> {
  const file = await apiRequestFile(`/api/v1/invoices/sales/${saleId}/pdf/`, {
    headers: { Accept: "application/pdf" },
  });
  if (file.blob.type && !file.blob.type.toLowerCase().includes("application/pdf")) {
    throw new Error("The invoice endpoint did not return a PDF. Please try again.");
  }
  return { ...file, filename: file.filename.endsWith(".pdf") ? file.filename : `${file.filename}.pdf` };
}

// ---------------------------------------------------------------------------
// Operations: detail / create / reverse for all documents
// ---------------------------------------------------------------------------

export async function getDocument(collection: "sales" | "purchases" | "payments" | "expenses" | "transfers", id: string) {
  return apiRequest<unknown>(`/api/v1/${collection}/${id}/`);
}

export async function reverseDocument(
  collection: "sales" | "purchases" | "payments" | "expenses" | "transfers",
  id: string,
  reason: string,
) {
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
  saleId?: string;
  purchaseId?: string;
  method?: string;
  amountMinor: number;
  note?: string;
}) {
  return apiRequest<unknown>("/api/v1/payments/", {
    method: "POST",
    idempotencyKey: newIdempotencyKey(),
    body: {
      business_id: input.businessId,
      location_id: input.locationId,
      party_id: input.partyId,
      direction: input.direction,
      ...(input.saleId ? { sale_id: input.saleId } : {}),
      ...(input.purchaseId ? { purchase_id: input.purchaseId } : {}),
      method: input.method ?? "CASH",
      amount_minor: input.amountMinor,
      ...(input.note ? { note: input.note } : {}),
      idempotency_key: newIdempotencyKey(),
    },
  });
}

function optionalNumber(value: unknown): number | undefined {
  const parsed = finiteNumber(value);
  return parsed === null ? undefined : parsed;
}

function mapPaymentAllocation(row: Record<string, unknown>): PaymentAllocation {
  const sale = row.sale ? String(row.sale) : undefined;
  const purchase = row.purchase ? String(row.purchase) : undefined;
  return {
    id: String(row.id),
    sale,
    purchase,
    amountMinor: minorFrom(row, "amountMinor", "amount"),
    documentType: String(row.documentType ?? (sale ? "SALE" : "PURCHASE")) as PaymentAllocation["documentType"],
    documentId: String(row.documentId ?? sale ?? purchase ?? ""),
    documentNumber: row.documentNumber ? String(row.documentNumber) : undefined,
    documentTotalMinor: optionalNumber(row.documentTotalMinor),
    documentPaidTotalMinor: optionalNumber(row.documentPaidTotalMinor),
    documentDueTotalMinor: optionalNumber(row.documentDueTotalMinor),
  };
}

function mapPaymentRecord(row: Record<string, unknown>): PaymentRecord {
  const allocations = Array.isArray(row.allocations)
    ? (row.allocations as Record<string, unknown>[]).map(mapPaymentAllocation)
    : [];
  const allocatedTotalMinor = minorFrom(
    row,
    "allocatedTotalMinor",
    "allocated_total",
    allocations.reduce((sum, allocation) => sum + allocation.amountMinor, 0),
  );
  return {
    id: String(row.id),
    business: String(row.business ?? ""),
    location: String(row.location ?? ""),
    party: String(row.party ?? ""),
    direction: String(row.direction) as PaymentDirection,
    method: String(row.method ?? ""),
    amountMinor: minorFrom(row, "amountMinor", "amount"),
    reference: row.reference ? String(row.reference) : undefined,
    note: row.note ? String(row.note) : undefined,
    paymentDate: String(row.paymentDate ?? row.createdAt ?? ""),
    status: String(row.status ?? "POSTED"),
    allocations,
    allocatedTotalMinor,
    unallocatedTotalMinor: minorFrom(row, "unallocatedTotalMinor", "unallocated_total", Math.max(0, minorFrom(row, "amountMinor", "amount") - allocatedTotalMinor)),
  };
}

function mapOutstandingDocument(row: Record<string, unknown>): OutstandingDocument {
  return {
    documentType: String(row.documentType) as OutstandingDocument["documentType"],
    documentId: String(row.documentId),
    number: String(row.number ?? row.documentId),
    documentDate: String(row.documentDate ?? ""),
    partyId: row.partyId ? String(row.partyId) : undefined,
    partyName: row.partyName ? String(row.partyName) : undefined,
    grandTotalMinor: minorFrom(row, "grandTotalMinor", "grand_total"),
    paidTotalMinor: minorFrom(row, "paidTotalMinor", "paid_total"),
    dueTotalMinor: minorFrom(row, "dueTotalMinor", "due_total"),
  };
}

export async function getPaymentAllocationReview(
  businessId: string,
  locationId: string,
  options: { direction?: PaymentDirection; partyId?: string; status?: string } = {},
): Promise<PaymentAllocationReview> {
  const params = new URLSearchParams({ business_id: businessId, location_id: locationId });
  if (options.direction) params.set("direction", options.direction);
  if (options.partyId) params.set("party_id", options.partyId);
  params.set("status", options.status ?? "POSTED");
  const raw = await apiRequest<Record<string, unknown>>(`/api/v1/payments/allocation-review/?${params}`);
  const totals = asRecord(raw.totals);
  const outstanding = Array.isArray(raw.outstandingDocuments)
    ? raw.outstandingDocuments as Record<string, unknown>[]
    : [];
  return {
    payments: recordList(raw).map(mapPaymentRecord),
    totals: {
      paymentCount: countFrom(totals.paymentCount),
      paymentTotalMinor: minorFrom(totals, "paymentTotalMinor", "payment_total"),
      allocatedTotalMinor: minorFrom(totals, "allocatedTotalMinor", "allocated_total"),
      unallocatedTotalMinor: minorFrom(totals, "unallocatedTotalMinor", "unallocated_total"),
      outstandingDocumentCount: countFrom(totals.outstandingDocumentCount),
      outstandingTotalMinor: minorFrom(totals, "outstandingTotalMinor", "outstanding_total"),
    },
    outstandingDocuments: outstanding.map(mapOutstandingDocument),
  };
}

export async function reallocatePayment(input: {
  paymentId: string;
  allocations: PaymentAllocationInput[];
  reason: string;
  idempotencyKey: string;
}): Promise<PaymentRecord> {
  const raw = await apiRequest<Record<string, unknown>>(`/api/v1/payments/${input.paymentId}/reallocate/`, {
    method: "POST",
    idempotencyKey: input.idempotencyKey,
    body: {
      reason: input.reason,
      idempotency_key: input.idempotencyKey,
      allocations: input.allocations.map((allocation) => ({
        document_type: allocation.documentType,
        document_id: allocation.documentId,
        amount_minor: allocation.amountMinor,
      })),
    },
  });
  return mapPaymentRecord(raw);
}

export async function createExpense(input: {
  businessId: string;
  locationId: string;
  category: string;
  amountMinor: number;
  paymentMode?: string;
  note?: string;
}) {
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

function mapValuationProduct(row: Record<string, unknown>): ValuationProductRow {
  return {
    productId: String(row.productId ?? ""),
    name: String(row.name ?? ""),
    unit: String(row.unit ?? ""),
    quantity: String(row.quantity ?? "0"),
    averageCostMinor: nullableApiMinorFrom(row, "averageCostMinor", "average_cost_minor"),
    totalValueMinor: nullableApiMinorFrom(row, "totalValueMinor", "total_value_minor"),
    knownValueMinor: minorFrom({ value: apiField(row, "knownValueMinor", "known_value_minor") }, "value", "value"),
    unknownCostQuantity: String(row.unknownCostQuantity ?? "0"),
    costingComplete: Boolean(row.costingComplete),
  };
}

export async function getValuationReport(
  businessId: string,
  locationId: string,
  options: { dateFrom?: string; dateTo?: string } = {},
): Promise<ValuationReport> {
  const params = new URLSearchParams({ business_id: businessId, location_id: locationId });
  if (options.dateFrom) params.set("date_from", options.dateFrom);
  if (options.dateTo) params.set("date_to", options.dateTo);
  const raw = await apiRequest<Record<string, unknown>>(`/api/v1/reports/valuation/?${params}`);
  const inventory = asRecord(raw.inventory);
  const sales = asRecord(raw.sales);
  const rows = Array.isArray(raw.results) ? raw.results as Record<string, unknown>[] : [];
  return {
    inventory: {
      totalQuantity: String(inventory.totalQuantity ?? "0"),
      averageCostMinor: nullableApiMinorFrom(inventory, "averageCostMinor", "average_cost_minor"),
      totalValueMinor: nullableApiMinorFrom(inventory, "totalValueMinor", "total_value_minor"),
      knownValueMinor: minorFrom({ value: apiField(inventory, "knownValueMinor", "known_value_minor") }, "value", "value"),
      costingComplete: Boolean(inventory.costingComplete),
    },
    sales: {
      postedSaleCount: countFrom(sales.postedSaleCount),
      lineCount: countFrom(sales.lineCount),
      netSalesMinor: minorFrom({ value: apiField(sales, "netSalesMinor", "net_sales_minor") }, "value", "value"),
      cogsMinor: minorFrom({ value: apiField(sales, "cogsMinor", "cogs_minor") }, "value", "value"),
      grossProfitMinor: nullableApiMinorFrom(sales, "grossProfitMinor", "gross_profit_minor"),
      missingCostLineCount: countFrom(sales.missingCostLineCount),
      costingComplete: Boolean(sales.costingComplete),
    },
    results: rows.map(mapValuationProduct),
  };
}

export async function getPartyLedger(businessId: string, partyId: string, locationId?: string): Promise<LedgerReport> {
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
  return apiRequest<Record<string, unknown>>(`/api/v1/assistant/proposals/${id}/`);
}

export async function getProposalRevisions(id: string): Promise<ProposalRevision[]> {
  const res = await apiRequest<unknown>(`/api/v1/assistant/proposals/${id}/revisions/`);
  const rows = Array.isArray(res) ? (res as Record<string, unknown>[]) : recordList(res);
  return rows.map((row) => ({ version: Number(row.version ?? 0), snapshot: row.snapshot, createdAt: String(row.createdAt ?? "") }));
}

export async function cancelProposal(id: string, version: number) {
  return apiRequest<unknown>(`/api/v1/assistant/proposals/${id}/cancel/`, {
    method: "POST",
    body: { version },
  });
}

// ---------------------------------------------------------------------------
// Gmail receipts: extraction is review-only and never posts to the books.
// ---------------------------------------------------------------------------

export async function getGmailStatus(): Promise<GmailStatus> {
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/integrations/gmail/status/");
  return {
    connected: Boolean(raw.connected),
    email: raw.email ? String(raw.email) : undefined,
  };
}

export async function connectGmail(): Promise<{ authorizationUrl: string }> {
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/integrations/gmail/connect/");
  return { authorizationUrl: String(raw.authorizationUrl) };
}

export async function disconnectGmail(): Promise<void> {
  await apiRequest("/api/v1/integrations/gmail/", { method: "DELETE" });
}

export async function getGmailMessages(): Promise<GmailMessage[]> {
  const response = await apiRequest<unknown>("/api/v1/integrations/gmail/messages/?max_results=20");
  return recordList(response).map((row) => ({
    id: String(row.id),
    subject: String(row.subject ?? "(No subject)"),
    snippet: String(row.snippet ?? ""),
    receivedAt: String(row.receivedAt ?? ""),
  }));
}

export async function importGmailReceipt(input: {
  messageId: string;
  businessId: string;
  locationId: string;
}): Promise<GmailImportResult> {
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/integrations/gmail/import/", {
    method: "POST",
    body: {
      message_id: input.messageId,
      business_id: input.businessId,
      location_id: input.locationId,
    },
  });
  const extracted = asRecord(raw.extracted);
  const extraction: GmailReceiptExtraction = {
    kind: String(extracted.kind ?? "RECEIPT"),
    direction: String(extracted.direction ?? "UNKNOWN"),
    partyName: extracted.partyName ? String(extracted.partyName) : undefined,
    amountMinor: minorFrom(extracted, "amountMinor", "amount"),
    reference: extracted.reference ? String(extracted.reference) : undefined,
    confidence: finiteNumber(extracted.confidence) ?? undefined,
  };
  return {
    importId: String(raw.importId),
    status: String(raw.status ?? "READY_FOR_REVIEW"),
    extracted: extraction,
    preview: raw.preview,
  };
}

// ---------------------------------------------------------------------------
// Notification devices and durable reminders. Scheduling never sends inline.
// ---------------------------------------------------------------------------

function mapNotificationDevice(row: Record<string, unknown>): NotificationDevice {
  return {
    id: String(row.id),
    business: String(row.business ?? ""),
    location: row.location ? String(row.location) : undefined,
    platform: String(row.platform ?? "WEB") as NotificationDevice["platform"],
    status: String(row.status ?? "ACTIVE") as NotificationDevice["status"],
    tokenSuffix: String(row.tokenSuffix ?? ""),
    lastSeenAt: String(row.lastSeenAt ?? ""),
    unregisteredAt: row.unregisteredAt ? String(row.unregisteredAt) : undefined,
    metadata: asRecord(row.metadata),
    createdAt: row.createdAt ? String(row.createdAt) : undefined,
    updatedAt: row.updatedAt ? String(row.updatedAt) : undefined,
  };
}

function mapReminder(row: Record<string, unknown>): Reminder {
  return {
    id: String(row.id),
    business: String(row.business ?? ""),
    location: row.location ? String(row.location) : undefined,
    kind: String(row.kind ?? "USER") as Reminder["kind"],
    title: String(row.title ?? ""),
    body: String(row.body ?? ""),
    scheduledAt: String(row.scheduledAt ?? ""),
    status: String(row.status ?? "SCHEDULED") as Reminder["status"],
    dedupeKey: String(row.dedupeKey ?? ""),
    data: asRecord(row.data),
    metadata: asRecord(row.metadata),
    queuedAt: row.queuedAt ? String(row.queuedAt) : undefined,
    sentAt: row.sentAt ? String(row.sentAt) : undefined,
    cancelledAt: row.cancelledAt ? String(row.cancelledAt) : undefined,
    lastError: row.lastError ? String(row.lastError) : undefined,
    createdAt: row.createdAt ? String(row.createdAt) : undefined,
    updatedAt: row.updatedAt ? String(row.updatedAt) : undefined,
  };
}

export async function listNotificationDevices(): Promise<NotificationDevice[]> {
  const response = await apiRequest<unknown>("/api/v1/integrations/notifications/devices/");
  return recordList(response).map(mapNotificationDevice);
}

export async function registerNotificationDevice(input: {
  businessId: string;
  locationId?: string;
  fcmToken: string;
  platform: NotificationDevice["platform"];
}): Promise<NotificationDevice> {
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/integrations/notifications/devices/", {
    method: "POST",
    body: {
      business_id: input.businessId,
      location_id: input.locationId ?? null,
      fcm_token: input.fcmToken,
      platform: input.platform,
      metadata: { source: "web-console" },
    },
  });
  return mapNotificationDevice(raw);
}

export async function unregisterNotificationDevice(id: string): Promise<void> {
  await apiRequest(`/api/v1/integrations/notifications/devices/${id}/`, { method: "DELETE" });
}

export async function listReminders(): Promise<Reminder[]> {
  const response = await apiRequest<unknown>("/api/v1/integrations/notifications/reminders/");
  return recordList(response).map(mapReminder);
}

export async function createReminder(input: ReminderInput): Promise<Reminder> {
  const raw = await apiRequest<Record<string, unknown>>("/api/v1/integrations/notifications/reminders/", {
    method: "POST",
    body: {
      business_id: input.businessId,
      location_id: input.locationId ?? null,
      title: input.title,
      body: input.body,
      scheduled_at: input.scheduledAt,
      ...(input.dedupeKey ? { dedupe_key: input.dedupeKey } : {}),
    },
  });
  return mapReminder(raw);
}

export async function updateReminder(
  id: string,
  patch: { title?: string; body?: string; scheduledAt?: string },
): Promise<Reminder> {
  const raw = await apiRequest<Record<string, unknown>>(`/api/v1/integrations/notifications/reminders/${id}/`, {
    method: "PATCH",
    body: {
      ...(patch.title !== undefined ? { title: patch.title } : {}),
      ...(patch.body !== undefined ? { body: patch.body } : {}),
      ...(patch.scheduledAt !== undefined ? { scheduled_at: patch.scheduledAt } : {}),
    },
  });
  return mapReminder(raw);
}

export async function cancelReminder(id: string): Promise<void> {
  await apiRequest(`/api/v1/integrations/notifications/reminders/${id}/`, { method: "DELETE" });
}

// ---------------------------------------------------------------------------
// Tenancy: the append-only audit trail behind the Activity screen
// ---------------------------------------------------------------------------

export async function listActivity(
  businessId: string,
  locationId?: string,
): Promise<ActivityEvent[]> {
  const params = new URLSearchParams({ business_id: businessId });
  if (locationId) params.set("location_id", locationId);
  const res = await apiRequest<unknown>(`/api/v1/audit-events/?${params}`);
  return recordList(res).map((row) => ({
    id: String(row.id),
    eventType: String(row.eventType ?? ""),
    aggregateType: String(row.aggregateType ?? ""),
    aggregateId: String(row.aggregateId ?? ""),
    locationId: row.location ? String(row.location) : undefined,
    actorName: row.actorName ? String(row.actorName) : undefined,
    source: String(row.source ?? "API"),
    metadata: (row.metadata ?? {}) as Record<string, unknown>,
    createdAt: String(row.createdAt ?? ""),
  }));
}
