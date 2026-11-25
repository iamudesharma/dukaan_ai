import type { OfflineDraft, OfflineDraftScope } from "../types";

const databaseName = "dukaanai-drafts";
const storeName = "drafts";

export type OfflineDraftInput = Omit<
  OfflineDraft,
  keyof OfflineDraftScope | "id" | "capturedAt" | "syncState"
>;

function openDatabase(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(databaseName, 1);
    request.onupgradeneeded = () => {
      const db = request.result;
      if (!db.objectStoreNames.contains(storeName)) {
        db.createObjectStore(storeName, { keyPath: "id" });
      }
    };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

function assertScope(scope: OfflineDraftScope): void {
  if (!scope.userId.trim() || !scope.businessId.trim()) {
    throw new Error("A user and business are required to save offline drafts.");
  }
}

function belongsToScope(value: unknown, scope: OfflineDraftScope): value is OfflineDraft {
  if (!value || typeof value !== "object" || Array.isArray(value)) return false;
  const draft = value as Partial<OfflineDraft>;
  return draft.userId === scope.userId
    && draft.businessId === scope.businessId
    && typeof draft.id === "string"
    && typeof draft.locationId === "string"
    && typeof draft.capturedAt === "string"
    && (draft.kind === "assistant"
      || draft.kind === "sale"
      || draft.kind === "purchase"
      || draft.kind === "expense"
      || draft.kind === "payment")
    && Boolean(draft.content)
    && typeof draft.content === "object"
    && !Array.isArray(draft.content)
    && (draft.syncState === "LOCAL_ONLY"
      || draft.syncState === "UPLOADING"
      || draft.syncState === "READY_TO_REVIEW"
      || draft.syncState === "FAILED");
}

export async function saveOfflineDraft(
  scope: OfflineDraftScope,
  draft: OfflineDraftInput,
): Promise<OfflineDraft> {
  assertScope(scope);
  const stored: OfflineDraft = {
    ...draft,
    ...scope,
    id: crypto.randomUUID(),
    capturedAt: new Date().toISOString(),
    syncState: "LOCAL_ONLY",
  };
  const db = await openDatabase();
  try {
    await new Promise<void>((resolve, reject) => {
      const request = db.transaction(storeName, "readwrite").objectStore(storeName).put(stored);
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  } finally {
    db.close();
  }
  return stored;
}

export async function listOfflineDrafts(scope: OfflineDraftScope): Promise<OfflineDraft[]> {
  assertScope(scope);
  const db = await openDatabase();
  try {
    const drafts = await new Promise<unknown[]>((resolve, reject) => {
      const request = db.transaction(storeName, "readonly").objectStore(storeName).getAll();
      request.onsuccess = () => resolve(request.result as unknown[]);
      request.onerror = () => reject(request.error);
    });
    // Unscoped legacy drafts and malformed rows stay quarantined in IndexedDB:
    // they are never returned to a workspace or eligible for submission.
    return drafts
      .filter((draft): draft is OfflineDraft => belongsToScope(draft, scope))
      .sort((a, b) => b.capturedAt.localeCompare(a.capturedAt));
  } finally {
    db.close();
  }
}

export async function removeOfflineDraft(scope: OfflineDraftScope, id: string): Promise<void> {
  assertScope(scope);
  const db = await openDatabase();
  try {
    await new Promise<void>((resolve, reject) => {
      const store = db.transaction(storeName, "readwrite").objectStore(storeName);
      const read = store.get(id);
      read.onsuccess = () => {
        if (!belongsToScope(read.result, scope)) {
          resolve();
          return;
        }
        const remove = store.delete(id);
        remove.onsuccess = () => resolve();
        remove.onerror = () => reject(remove.error);
      };
      read.onerror = () => reject(read.error);
    });
  } finally {
    db.close();
  }
}
