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
  receivableMinor: number;
  payableMinor: number;
  lowStockCount: number;
  grossProfitMinor: number;
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

export interface AssistantProposal {
  id: string;
  version: number;
  status: "NEEDS_DETAILS" | "READY" | "CONFIRMED" | "FAILED";
  intent: "RECORD_SALE" | "RECORD_PURCHASE" | "RECORD_PAYMENT" | "RECORD_EXPENSE";
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

export interface OfflineDraft {
  id: string;
  kind: "assistant" | "sale" | "purchase" | "expense" | "payment";
  locationId: string;
  content: Record<string, unknown>;
  capturedAt: string;
  syncState: "LOCAL_ONLY" | "UPLOADING" | "READY_TO_REVIEW" | "FAILED";
}

export interface ApiErrorShape {
  code: string;
  message: string;
  fields?: Record<string, string[]>;
  request_id?: string;
  retryable?: boolean;
}
