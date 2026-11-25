export type Role = "OWNER" | "MANAGER" | "CASHIER";

export interface UserProfile {
  id: string;
  name: string;
  phone: string;
  role: Role;
}

export interface Business {
  id: string;
  name: string;
  legalName: string;
  gstin?: string;
  currency: "INR";
  timezone: "Asia/Kolkata";
  role?: Role;
}

export interface BusinessDetail extends Business {
  legal_name?: string;
  gstEnabled?: boolean;
  negativeStockAllowed?: boolean;
  role?: Role;
}

export interface LocationInput {
  business: string;
  name: string;
  code: string;
  address?: string;
  stateCode?: string;
  state_code?: string;
  gstRegistration?: string | null;
}

export interface GstRegistration {
  id: string;
  business: string;
  gstin: string;
  legalName: string;
  address?: string;
  stateCode?: string;
  invoicePrefix?: string;
}

export interface Membership {
  id: string;
  user: string;
  business: string;
  role: Role;
  locations: string[];
  isActive?: boolean;
}

export interface MeProfile {
  id: string;
  phone: string;
  displayName: string;
  memberships: Array<{ businessId: string; businessName: string; role: Role }>;
}

export interface StockRow {
  productId: string;
  name: string;
  unit: string;
  quantity: string;
  lowStockThreshold?: string;
  isLowStock?: boolean;
}

export interface LedgerEntry {
  id: string;
  account: string;
  amountMinor: number;
  note?: string;
  occurredAt: string;
}

export interface LedgerReport {
  partyId: string;
  balance: number;
  entries: LedgerEntry[];
}

export interface ActivityEvent {
  id: string;
  eventType: string;
  aggregateType: string;
  aggregateId: string;
  locationId?: string;
  actorName?: string;
  source: string;
  metadata: Record<string, unknown>;
  createdAt: string;
}

export interface ProposalSummary {
  id: string;
  version: number;
  status: string;
  commandType?: string;
  content?: string;
  createdAt?: string;
}

export interface ProposalRevision {
  version: number;
  snapshot: unknown;
  createdAt: string;
}

export interface ProductInput {
  business: string;
  name: string;
  sku?: string;
  baseUnit?: string;
  trackInventory?: boolean;
  hsnSac?: string;
  taxRateBps?: number;
  lowStockThreshold?: string;
  packs: Array<{
    id?: string;
    name: string;
    conversionFactor?: string;
    retailPriceMinor: number;
    wholesalePriceMinor: number;
  }>;
}

export interface PartyInput {
  business: string;
  name: string;
  kind: Party["kind"];
  phoneE164?: string;
  gstin?: string;
  stateCode?: string;
  address?: string;
}

export interface PurchaseLineInput {
  packId: string;
  quantity: string;
  unitCostMinor: number;
}

export interface TransferLineInput {
  packId: string;
  quantity: string;
}

export interface Location {
  id: string;
  name: string;
  code: string;
  stateCode: string;
}

export interface Bootstrap {
  user: UserProfile;
  business: Business;
  locations: Location[];
  permissions: string[];
}

export interface DashboardSummary {
  asOf: string;
  salesMinor: number;
  collectionsMinor: number;
  expensesMinor: number;
  cashFlowMinor: number;
  receivableMinor: number;
  payableMinor: number;
  lowStockCount: number;
  grossProfitMinor: number | null;
  summary: string;
}

export type EntryKind = "SALE" | "PURCHASE" | "PAYMENT_IN" | "PAYMENT_OUT" | "EXPENSE";
export type EntryStatus = "POSTED" | "REVERSED" | "DRAFT";

export interface Entry {
  id: string;
  number: string;
  kind: EntryKind;
  partyName: string;
  occurredAt: string;
  totalMinor: number;
  outstandingMinor: number;
  status: EntryStatus;
  paymentMode?: string;
}

export interface Product {
  id: string;
  packId: string;
  name: string;
  sku: string;
  unit: string;
  onHand: string;
  reorderLevel: string;
  isLowStock?: boolean;
  retailPriceMinor: number;
  wholesalePriceMinor: number;
  gstRateBps: number;
}

export interface ManualSaleInput {
  businessId: string;
  locationId: string;
  customerId?: string;
  customerName?: string;
  productId: string;
  packId: string;
  productName: string;
  quantity: string;
  unitPriceMinor: number;
  paidMinor: number;
  paymentMode: "CASH" | "UPI" | "CARD" | "BANK" | "OTHER";
  priceMode: "RETAIL" | "WHOLESALE";
}

export interface Party {
  id: string;
  name: string;
  phone?: string;
  kind: "CUSTOMER" | "SUPPLIER" | "BOTH";
  receivableMinor: number;
  payableMinor: number;
  priceTier: "RETAIL" | "WHOLESALE";
}

export interface AssistantLine {
  productId?: string;
  productName: string;
  quantity: string;
  unit: string;
  unitPriceMinor: number;
  lineTotalMinor: number;
  proposedNew?: boolean;
}

export type AssistantCommandType =
  | "SALE"
  | "PURCHASE"
  | "PAYMENT"
  | "EXPENSE"
  | "TRANSFER"
  | "UNKNOWN"
  | "UNSUPPORTED";

export interface AssistantProposal {
  id: string;
  version: number;
  status: "DRAFT" | "NEEDS_DETAILS" | "READY" | "CONFIRMED" | "CANCELLED" | "EXPIRED" | "FAILED";
  commandType: AssistantCommandType;
  intent: "RECORD_SALE" | "RECORD_PURCHASE" | "RECORD_PAYMENT" | "RECORD_EXPENSE" | "UNSUPPORTED";
  paymentDirection?: "RECEIPT" | "PAYMENT";
  sourceText: string;
  partyId?: string;
  partyName?: string;
  partyProposedNew?: boolean;
  lines: AssistantLine[];
  totalMinor: number;
  paidMinor: number;
  outstandingMinor: number;
  taxMinor: number;
  locationId: string;
  warnings: string[];
  questions: string[];
  effects: {
    stock: string[];
    ledger: string;
  };
}

export interface AssistantAttachment {
  id: string;
  businessId: string;
  kind: "IMAGE";
  mime: string;
  sizeBytes: number;
  status: "READY" | "FAILED";
  proposalId?: string;
  createdAt?: string;
}

export interface OpenDocument {
  id: string;
  kind: "SALE" | "PURCHASE";
  number: string;
  partyId: string;
  partyName: string;
  occurredAt: string;
  totalMinor: number;
  outstandingMinor: number;
}

export interface AuthCapabilities {
  password: boolean;
  otp: boolean;
  devOtp: boolean;
}

export interface GmailStatus {
  connected: boolean;
  email?: string;
}

export interface GmailMessage {
  id: string;
  subject: string;
  snippet: string;
  receivedAt: string;
}

export interface GmailReceiptExtraction {
  kind: string;
  direction: string;
  partyName?: string;
  amountMinor: number;
  reference?: string;
  confidence?: number;
}

export interface GmailImportResult {
  importId: string;
  status: string;
  extracted: GmailReceiptExtraction;
  preview: unknown;
}

export interface OfflineDraftScope {
  userId: string;
  businessId: string;
}

export interface OfflineDraft extends OfflineDraftScope {
  id: string;
  kind: "assistant" | "sale" | "purchase" | "expense" | "payment";
  locationId: string;
  content: Record<string, unknown>;
  capturedAt: string;
  syncState: "LOCAL_ONLY" | "UPLOADING" | "READY_TO_REVIEW" | "FAILED";
}

export type ImportKind = "PRODUCT" | "PARTY";
export type ImportDuplicateStrategy = "UPDATE" | "SKIP";
export type ImportStatus = "READY" | "INVALID" | "COMPLETED" | "FAILED";
export type ImportPreviewAction = "CREATE" | "UPDATE" | "SKIP";

export interface ImportRowError {
  row: number;
  errors: Record<string, string[]>;
}

export interface ImportPreviewRow {
  row: number;
  action: ImportPreviewAction;
}

export interface ImportCounts {
  rowCount: number;
  validRowCount: number;
  errorCount: number;
  createdCount: number;
  updatedCount: number;
  skippedCount: number;
}

export interface CsvImportDryRun extends ImportCounts {
  dryRun: true;
  kind: ImportKind;
  duplicateStrategy: ImportDuplicateStrategy;
  errors: ImportRowError[];
  preview: ImportPreviewRow[];
}

export interface ImportJob extends ImportCounts {
  id: string;
  business: string;
  kind: ImportKind;
  status: ImportStatus;
  duplicateStrategy: ImportDuplicateStrategy;
  errors: ImportRowError[];
  originalFilename: string;
  createdAt?: string;
  updatedAt?: string;
  confirmedAt?: string;
}

export interface ImportConfirmation {
  job: ImportJob;
  replayed: boolean;
}

export interface InvoiceDownload {
  blob: Blob;
  filename: string;
}

export interface ValuationProductRow {
  productId: string;
  name: string;
  unit: string;
  quantity: string;
  averageCostMinor: number | null;
  totalValueMinor: number | null;
  knownValueMinor: number;
  unknownCostQuantity: string;
  costingComplete: boolean;
}

export interface ValuationReport {
  inventory: {
    totalQuantity: string;
    averageCostMinor: number | null;
    totalValueMinor: number | null;
    knownValueMinor: number;
    costingComplete: boolean;
  };
  sales: {
    postedSaleCount: number;
    lineCount: number;
    netSalesMinor: number;
    cogsMinor: number;
    grossProfitMinor: number | null;
    missingCostLineCount: number;
    costingComplete: boolean;
  };
  results: ValuationProductRow[];
}

export type PaymentDirection = "RECEIPT" | "PAYMENT";
export type PaymentAllocationDocumentType = "SALE" | "PURCHASE";

export interface PaymentAllocation {
  id: string;
  sale?: string;
  purchase?: string;
  amountMinor: number;
  documentType: PaymentAllocationDocumentType;
  documentId: string;
  documentNumber?: string;
  documentTotalMinor?: number;
  documentPaidTotalMinor?: number;
  documentDueTotalMinor?: number;
}

export interface PaymentRecord {
  id: string;
  business: string;
  location: string;
  party: string;
  direction: PaymentDirection;
  method: string;
  amountMinor: number;
  reference?: string;
  note?: string;
  paymentDate: string;
  status: string;
  allocations: PaymentAllocation[];
  allocatedTotalMinor: number;
  unallocatedTotalMinor: number;
}

export interface OutstandingDocument {
  documentType: PaymentAllocationDocumentType;
  documentId: string;
  number: string;
  documentDate: string;
  partyId?: string;
  partyName?: string;
  grandTotalMinor: number;
  paidTotalMinor: number;
  dueTotalMinor: number;
}

export interface PaymentAllocationReview {
  payments: PaymentRecord[];
  totals: {
    paymentCount: number;
    paymentTotalMinor: number;
    allocatedTotalMinor: number;
    unallocatedTotalMinor: number;
    outstandingDocumentCount: number;
    outstandingTotalMinor: number;
  };
  outstandingDocuments: OutstandingDocument[];
}

export interface PaymentAllocationInput {
  documentType: PaymentAllocationDocumentType;
  documentId: string;
  amountMinor: number;
}

export type InvitationStatus = "PENDING" | "ACCEPTED" | "REVOKED" | "EXPIRED";

export interface Invitation {
  id: string;
  business: string;
  inviteePhone: string;
  role: Role;
  locations: string[];
  status: InvitationStatus;
  expiresAt: string;
  inviter: string;
  acceptedBy?: string;
  acceptedAt?: string;
  revokedAt?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface InvitationCreateResult extends Invitation {
  /** Returned only by the create response. Never cache or persist this value. */
  token: string;
}

export interface NotificationDevice {
  id: string;
  business: string;
  location?: string;
  platform: "ANDROID" | "IOS" | "WEB";
  status: "ACTIVE" | "DISABLED";
  tokenSuffix: string;
  lastSeenAt: string;
  unregisteredAt?: string;
  metadata: Record<string, unknown>;
  createdAt?: string;
  updatedAt?: string;
}

export type ReminderStatus = "SCHEDULED" | "QUEUED" | "SENT" | "FAILED" | "CANCELLED" | "SKIPPED";

export interface Reminder {
  id: string;
  business: string;
  location?: string;
  kind: "USER" | "DOMAIN";
  title: string;
  body: string;
  scheduledAt: string;
  status: ReminderStatus;
  dedupeKey: string;
  data: Record<string, unknown>;
  metadata: Record<string, unknown>;
  queuedAt?: string;
  sentAt?: string;
  cancelledAt?: string;
  lastError?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface ReminderInput {
  businessId: string;
  locationId?: string;
  title: string;
  body: string;
  scheduledAt: string;
  dedupeKey?: string;
}

export interface ApiErrorShape {
  code: string;
  message: string;
  fields?: Record<string, string[]>;
  request_id?: string;
  retryable?: boolean;
}
