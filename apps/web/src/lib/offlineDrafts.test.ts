import { afterEach, describe, expect, it, vi } from "vitest";
import { listOfflineDrafts, removeOfflineDraft, saveOfflineDraft } from "./offlineDrafts";
import type { OfflineDraft } from "../types";

function mockIndexedDb() {
  const rows = new Map<string, unknown>();
  const request = <T>(operation: () => T) => {
    const pending = {
      result: undefined as T | undefined,
      error: null as DOMException | null,
      onsuccess: null as ((event: Event) => void) | null,
      onerror: null as ((event: Event) => void) | null,
    };
    queueMicrotask(() => {
      try {
        pending.result = operation();
        pending.onsuccess?.(new Event("success"));
      } catch (error) {
        pending.error = error as DOMException;
        pending.onerror?.(new Event("error"));
      }
    });
    return pending;
  };
  const store = {
    put: (value: OfflineDraft) => request(() => {
      rows.set(value.id, value);
      return value.id;
    }),
    getAll: () => request(() => Array.from(rows.values())),
    get: (id: string) => request(() => rows.get(id)),
    delete: (id: string) => request(() => {
      rows.delete(id);
      return undefined;
    }),
  };
  const db = {
    objectStoreNames: { contains: () => true },
    transaction: () => ({ objectStore: () => store }),
    close: vi.fn(),
  };
  const open = vi.fn(() => request(() => db));
  vi.stubGlobal("indexedDB", { open });
  return { rows, open, db };
}

const scope = { userId: "u1", businessId: "b1" };

function storedDraft(id: string, draftScope = scope): OfflineDraft {
  return {
    ...draftScope,
    id,
    kind: "sale",
    locationId: "l1",
    content: { productId: "p1" },
    capturedAt: "2026-11-24T10:00:00.000Z",
    syncState: "LOCAL_ONLY",
  };
}

afterEach(() => vi.unstubAllGlobals());

describe("offline draft scoping", () => {
  it("stores user and business scope with every new draft", async () => {
    mockIndexedDb();

    const saved = await saveOfflineDraft(scope, {
      kind: "sale",
      locationId: "l1",
      content: { productId: "p1" },
    });

    expect(saved).toMatchObject({ ...scope, kind: "sale", syncState: "LOCAL_ONLY" });
  });

  it("lists only the active user and business and quarantines legacy rows", async () => {
    const { rows } = mockIndexedDb();
    rows.set("own", storedDraft("own"));
    rows.set("other-user", storedDraft("other-user", { userId: "u2", businessId: "b1" }));
    rows.set("other-business", storedDraft("other-business", { userId: "u1", businessId: "b2" }));
    rows.set("legacy", {
      id: "legacy",
      kind: "sale",
      locationId: "l1",
      content: { secret: "unscoped" },
      capturedAt: "2026-11-25T10:00:00.000Z",
      syncState: "LOCAL_ONLY",
    });
    rows.set("malformed", { ...storedDraft("malformed"), content: null });

    await expect(listOfflineDrafts(scope)).resolves.toEqual([storedDraft("own")]);
  });

  it("does not delete another user's or business's draft", async () => {
    const { rows } = mockIndexedDb();
    rows.set("other-user", storedDraft("other-user", { userId: "u2", businessId: "b1" }));
    rows.set("other-business", storedDraft("other-business", { userId: "u1", businessId: "b2" }));

    await removeOfflineDraft(scope, "other-user");
    await removeOfflineDraft(scope, "other-business");

    expect(rows.size).toBe(2);
  });

  it("removes a draft only when both scope fields match", async () => {
    const { rows } = mockIndexedDb();
    rows.set("own", storedDraft("own"));

    await removeOfflineDraft(scope, "own");

    expect(rows.has("own")).toBe(false);
  });

  it("refuses to write an unscoped draft", async () => {
    const { open } = mockIndexedDb();

    await expect(saveOfflineDraft({ userId: "", businessId: "b1" }, {
      kind: "sale",
      locationId: "l1",
      content: {},
    })).rejects.toThrow(/user and business/i);
    expect(open).not.toHaveBeenCalled();
  });
});
