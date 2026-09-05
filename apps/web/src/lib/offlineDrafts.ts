import type { OfflineDraft } from "../types";

const databaseName = "dukaanai-drafts";
const storeName = "drafts";

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

export async function saveOfflineDraft(
  draft: Omit<OfflineDraft, "id" | "capturedAt" | "syncState">,
): Promise<OfflineDraft> {
  const stored: OfflineDraft = {
    ...draft,
    id: crypto.randomUUID(),
    capturedAt: new Date().toISOString(),
    syncState: "LOCAL_ONLY",
  };
  const db = await openDatabase();
  await new Promise<void>((resolve, reject) => {
    const request = db.transaction(storeName, "readwrite").objectStore(storeName).put(stored);
    request.onsuccess = () => resolve();
    request.onerror = () => reject(request.error);
  });
  db.close();
  return stored;
}

export async function listOfflineDrafts(): Promise<OfflineDraft[]> {
  const db = await openDatabase();
  const drafts = await new Promise<OfflineDraft[]>((resolve, reject) => {
    const request = db.transaction(storeName, "readonly").objectStore(storeName).getAll();
    request.onsuccess = () => resolve(request.result as OfflineDraft[]);
    request.onerror = () => reject(request.error);
  });
  db.close();
  return drafts.sort((a, b) => b.capturedAt.localeCompare(a.capturedAt));
}

export async function removeOfflineDraft(id: string): Promise<void> {
  const db = await openDatabase();
  await new Promise<void>((resolve, reject) => {
    const request = db.transaction(storeName, "readwrite").objectStore(storeName).delete(id);
    request.onsuccess = () => resolve();
    request.onerror = () => reject(request.error);
  });
  db.close();
}
