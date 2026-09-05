import type {
  AssistantProposal,
  Bootstrap,
  DashboardSummary,
  Entry,
  Party,
  Product,
} from "../types";

const now = new Date();
const isoAt = (hoursAgo: number) => new Date(now.getTime() - hoursAgo * 3_600_000).toISOString();

export const demoBootstrap: Bootstrap = {
  user: {
    id: "user-demo-owner",
    name: "Amit Sharma",
    phone: "+91 98765 43210",
    role: "OWNER",
  },
  business: {
    id: "business-demo",
    name: "Sharma Garments",
    legalName: "Sharma Garments",
    gstin: "07ABCDE1234F1Z5",
    currency: "INR",
    timezone: "Asia/Kolkata",
  },
  locations: [
    { id: "location-karol-bagh", name: "Karol Bagh", code: "KB", stateCode: "07" },
    { id: "location-lajpat-nagar", name: "Lajpat Nagar", code: "LN", stateCode: "07" },
  ],
  permissions: ["*"],
};

export const initialEntries: Entry[] = [
  {
    id: "sale-1042",
    number: "KB/26-27/001042",
    kind: "SALE",
    partyName: "Meena Textiles",
    occurredAt: isoAt(1),
    totalMinor: 186000,
    outstandingMinor: 86000,
    status: "POSTED",
    paymentMode: "UPI",
  },
  {
    id: "payment-331",
    number: "REC/000331",
    kind: "PAYMENT_IN",
    partyName: "Ramesh Kumar",
    occurredAt: isoAt(2.3),
    totalMinor: 150000,
    outstandingMinor: 0,
    status: "POSTED",
    paymentMode: "CASH",
  },
  {
    id: "purchase-884",
    number: "PUR/000884",
    kind: "PURCHASE",
    partyName: "National Garments",
    occurredAt: isoAt(5),
    totalMinor: 1245000,
    outstandingMinor: 745000,
    status: "POSTED",
    paymentMode: "BANK",
  },
  {
    id: "expense-206",
    number: "EXP/000206",
    kind: "EXPENSE",
    partyName: "Shop electricity",
    occurredAt: isoAt(7),
    totalMinor: 12800,
    outstandingMinor: 0,
    status: "POSTED",
    paymentMode: "UPI",
  },
];

export const initialProducts: Product[] = [
  {
    id: "product-shirt-blue",
    packId: "pack-shirt-blue-piece",
    name: "Men's cotton shirt — blue",
    sku: "SH-BLU-M",
    unit: "piece",
    onHand: "18",
    reorderLevel: "10",
    retailPriceMinor: 89900,
    wholesalePriceMinor: 72000,
    gstRateBps: 500,
  },
  {
    id: "product-shirt-white",
    packId: "pack-shirt-white-piece",
    name: "Men's cotton shirt — white",
    sku: "SH-WHT-M",
    unit: "piece",
    onHand: "7",
    reorderLevel: "10",
    retailPriceMinor: 89900,
    wholesalePriceMinor: 72000,
    gstRateBps: 500,
  },
  {
    id: "product-jeans",
    packId: "pack-jeans-piece",
    name: "Regular fit jeans",
    sku: "JN-RG-32",
    unit: "piece",
    onHand: "26",
    reorderLevel: "8",
    retailPriceMinor: 149900,
    wholesalePriceMinor: 118000,
    gstRateBps: 1200,
  },
  {
    id: "product-kurti",
    packId: "pack-kurti-piece",
    name: "Printed cotton kurti",
    sku: "KT-PR-M",
    unit: "piece",
    onHand: "4",
    reorderLevel: "12",
    retailPriceMinor: 119900,
    wholesalePriceMinor: 90000,
    gstRateBps: 500,
  },
];

export const initialParties: Party[] = [
  {
    id: "party-ramesh",
    name: "Ramesh Kumar",
    phone: "+91 98111 22334",
    kind: "CUSTOMER",
    receivableMinor: 124000,
    payableMinor: 0,
    priceTier: "RETAIL",
  },
  {
    id: "party-meena",
    name: "Meena Textiles",
    phone: "+91 99102 12012",
    kind: "BOTH",
    receivableMinor: 86000,
    payableMinor: 212000,
    priceTier: "WHOLESALE",
  },
  {
    id: "party-national",
    name: "National Garments",
    phone: "+91 98100 55667",
    kind: "SUPPLIER",
    receivableMinor: 0,
    payableMinor: 745000,
    priceTier: "WHOLESALE",
  },
];

interface DemoState {
  entries: Entry[];
  products: Product[];
  parties: Party[];
}

const key = "dukaanai-demo-state-v1";

export function getDemoState(): DemoState {
  const stored = localStorage.getItem(key);
  if (stored) {
    try {
      return JSON.parse(stored) as DemoState;
    } catch {
      localStorage.removeItem(key);
    }
  }
  return {
    entries: structuredClone(initialEntries),
    products: structuredClone(initialProducts),
    parties: structuredClone(initialParties),
  };
}

function saveDemoState(state: DemoState): void {
  localStorage.setItem(key, JSON.stringify(state));
  window.dispatchEvent(new Event("dukaanai:demo-updated"));
}

export function resetDemoState(): void {
  localStorage.removeItem(key);
  window.dispatchEvent(new Event("dukaanai:demo-updated"));
}

export function demoDashboard(): DashboardSummary {
  const state = getDemoState();
  const sales = state.entries
    .filter((entry) => entry.kind === "SALE" && entry.status === "POSTED")
    .reduce((sum, entry) => sum + entry.totalMinor, 0);
  const collections = state.entries
    .filter((entry) => entry.kind === "PAYMENT_IN" && entry.status === "POSTED")
    .reduce((sum, entry) => sum + entry.totalMinor, 0);
  const expenses = state.entries
    .filter((entry) => entry.kind === "EXPENSE" && entry.status === "POSTED")
    .reduce((sum, entry) => sum + entry.totalMinor, 0);
  return {
    asOf: new Date().toISOString(),
    salesMinor: sales,
    collectionsMinor: collections,
    expensesMinor: expenses,
    receivableMinor: state.parties.reduce((sum, party) => sum + party.receivableMinor, 0),
    payableMinor: state.parties.reduce((sum, party) => sum + party.payableMinor, 0),
    lowStockCount: state.products.filter(
      (product) => Number(product.onHand) <= Number(product.reorderLevel),
    ).length,
    grossProfitMinor: Math.round(sales * 0.28),
    summary:
      "Collections are healthy today. Two products need attention, and Ramesh's balance is still outstanding.",
  };
}

function parseRupees(input: string): number[] {
  const normalized = input.replace(/,/g, "");
  const currencyAmounts = [...normalized.matchAll(/(?:₹|rs\.?|inr)\s*(\d+(?:\.\d{1,2})?)/gi)]
    .map((match) => Math.round(Number(match[1]) * 100))
    .filter((amount) => Number.isFinite(amount) && amount > 0);
  if (currencyAmounts.length) return currencyAmounts;
  return [...normalized.matchAll(/\b(\d+(?:\.\d{1,2})?)\b/g)]
    .map((match) => Math.round(Number(match[1]) * 100))
    .filter((amount) => Number.isFinite(amount) && amount > 0);
}

export function interpretDemoCommand(sourceText: string, locationId: string): AssistantProposal {
  const lower = sourceText.toLocaleLowerCase("en-IN");
  const amounts = parseRupees(sourceText);
  const isPurchase = /bought from|purchase|kharid|खरीद/.test(lower);
  const isExpense = /expense|खर्च|bill paid|rent|bijli/.test(lower);
  const isPayment = /paid me|payment received|jama kiye|दिया/.test(lower) && !/bought|sale/.test(lower);
  const intent = isExpense
    ? "RECORD_EXPENSE"
    : isPurchase
      ? "RECORD_PURCHASE"
      : isPayment
        ? "RECORD_PAYMENT"
        : "RECORD_SALE";
  const ramesh = /ramesh|रमेश/.test(lower);
  const shirts = /shirt|शर्ट/.test(lower);
  const quantityMatch = sourceText.match(/(\d+(?:\.\d+)?)\s*(?:shirt|piece|pc|शर्ट)/i);
  const quantity = quantityMatch?.[1] ?? (shirts ? "3" : "1");
  let totalMinor = amounts[0] ?? 0;
  let paidMinor = amounts[1] ?? (intent === "RECORD_SALE" ? totalMinor : 0);
  let outstandingMinor = amounts[2] ?? Math.max(0, totalMinor - paidMinor);

  if (ramesh && shirts && amounts.length >= 3) {
    totalMinor = amounts[0];
    paidMinor = amounts[1];
    outstandingMinor = amounts[2];
  }

  const quantityNumber = Number(quantity) || 1;
  const unitPriceMinor = quantityNumber > 0 ? Math.round(totalMinor / quantityNumber) : totalMinor;
  const questions: string[] = [];
  if (!totalMinor) questions.push("What is the total amount?");
  if (intent === "RECORD_SALE" && !shirts) questions.push("Which product was sold?");

  return {
    id: crypto.randomUUID(),
    version: 1,
    status: questions.length ? "NEEDS_DETAILS" : "READY",
    intent,
    sourceText,
    partyId: ramesh ? "party-ramesh" : undefined,
    partyName: ramesh ? "Ramesh Kumar" : undefined,
    lines: shirts
      ? [
          {
            productId: "product-shirt-blue",
            productName: "Men's cotton shirt — blue",
            quantity,
            unit: "piece",
            unitPriceMinor,
            lineTotalMinor: totalMinor,
          },
        ]
      : [],
    totalMinor,
    paidMinor,
    outstandingMinor,
    taxMinor: 0,
    locationId,
    warnings: paidMinor + outstandingMinor !== totalMinor
      ? ["Paid and pending amounts do not match the total. Please review them."]
      : [],
    questions,
    effects: {
      stock: shirts ? [`Reduce shirt stock by ${quantity} pieces`] : [],
      ledger: outstandingMinor > 0
        ? `Add ₹${(outstandingMinor / 100).toLocaleString("en-IN")} to the customer's outstanding balance`
        : "No outstanding balance",
    },
  };
}

export function confirmDemoProposal(proposal: AssistantProposal): Entry {
  if (proposal.status !== "READY") throw new Error("Proposal is not ready to confirm.");
  const state = getDemoState();
  const entry: Entry = {
    id: crypto.randomUUID(),
    number: `KB/26-27/${String(state.entries.length + 1043).padStart(6, "0")}`,
    kind: proposal.intent === "RECORD_PURCHASE"
      ? "PURCHASE"
      : proposal.intent === "RECORD_PAYMENT"
        ? "PAYMENT_IN"
        : proposal.intent === "RECORD_EXPENSE"
          ? "EXPENSE"
          : "SALE",
    partyName: proposal.partyName ?? "Cash customer",
    occurredAt: new Date().toISOString(),
    totalMinor: proposal.totalMinor,
    outstandingMinor: proposal.outstandingMinor,
    status: "POSTED",
    paymentMode: proposal.paidMinor > 0 ? "CASH" : undefined,
  };
  state.entries.unshift(entry);

  if (entry.kind === "SALE") {
    for (const line of proposal.lines) {
      const product = state.products.find((candidate) => candidate.id === line.productId);
      if (product) product.onHand = String(Number(product.onHand) - Number(line.quantity));
    }
    const party = state.parties.find((candidate) => candidate.id === proposal.partyId);
    if (party) party.receivableMinor += proposal.outstandingMinor;
  }

  saveDemoState(state);
  return entry;
}
