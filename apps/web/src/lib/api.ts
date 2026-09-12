import type { ApiErrorShape } from "../types";
import { accessToken, getRefreshToken, setTokens, clearTokens } from "./supabase";

const apiUrl = ((import.meta.env.VITE_API_URL as string | undefined) ?? "http://127.0.0.1:8000")
  .replace(/\/$/, "");

export class ApiError extends Error {
  readonly status: number;
  readonly detail: ApiErrorShape;

  constructor(status: number, detail: ApiErrorShape) {
    super(detail.message);
    this.name = "ApiError";
    this.status = status;
    this.detail = detail;
  }
}

function camelize(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(camelize);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>).map(([key, item]) => [
        key.replace(/_([a-z])/g, (_match, letter: string) => letter.toUpperCase()),
        camelize(item),
      ]),
    );
  }
  return value;
}

interface RequestOptions extends Omit<RequestInit, "body"> {
  body?: unknown;
  idempotencyKey?: string;
}

async function refreshAccessToken(): Promise<string | null> {
  const refresh = getRefreshToken();
  if (!refresh) return null;
  try {
    const res = await fetch(`${apiUrl}/api/v1/auth/refresh/`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refresh }),
    });
    if (!res.ok) return null;
    const data = await res.json();
    if (data.access) {
      setTokens({ access: data.access, refresh: data.refresh ?? refresh });
      return data.access;
    }
  } catch {
    // fall through
  }
  return null;
}

function errorMessage(value: unknown): string | undefined {
  if (typeof value === "string") return value;
  if (Array.isArray(value)) {
    for (const item of value) {
      const message = errorMessage(item);
      if (message) return message;
    }
    return undefined;
  }
  if (value && typeof value === "object") {
    const record = value as Record<string, unknown>;
    if (typeof record.message === "string") return record.message;
    if (typeof record.detail === "string") return record.detail;
    for (const item of Object.values(record)) {
      const message = errorMessage(item);
      if (message) return message;
    }
  }
  return undefined;
}

export async function apiRequest<T>(path: string, options: RequestOptions = {}): Promise<T> {
  let token = await accessToken();
  const headers = new Headers(options.headers);
  headers.set("Accept", "application/json");
  headers.set("X-Client", "dukaanai-web/0.1.0");
  if (options.body !== undefined) headers.set("Content-Type", "application/json");
  if (token) headers.set("Authorization", `Bearer ${token}`);
  if (options.idempotencyKey) headers.set("Idempotency-Key", options.idempotencyKey);

  let response = await fetch(`${apiUrl}${path}`, {
    ...options,
    headers,
    body: options.body === undefined ? undefined : JSON.stringify(options.body),
  });

  if (response.status === 401 && token) {
    const newToken = await refreshAccessToken();
    if (newToken) {
      headers.set("Authorization", `Bearer ${newToken}`);
      response = await fetch(`${apiUrl}${path}`, {
        ...options,
        headers,
        body: options.body === undefined ? undefined : JSON.stringify(options.body),
      });
    } else {
      // The session is no longer refreshable; force a clean sign-in.
      clearTokens();
    }
  }

  if (!response.ok) {
    const fallback: ApiErrorShape = {
      code: `http_${response.status}`,
      message: "The request could not be completed.",
      retryable: response.status >= 500,
    };
    let detail = fallback;
    try {
      const raw = (await response.json()) as Record<string, unknown>;
      const envelope = raw.error as Record<string, unknown> | undefined;
      const server = envelope?.detail;
      const message = errorMessage(server) ?? errorMessage(raw.detail);
      detail = {
        ...fallback,
        message: message ?? fallback.message,
        code: envelope?.code ? String(envelope.code) : fallback.code,
        ...(raw.fields ? { fields: raw.fields as Record<string, string[]> } : {}),
      };
    } catch {
      // A safe normalized response is returned for non-JSON upstream failures.
    }
    throw new ApiError(response.status, detail);
  }

  if (response.status === 204) return undefined as T;
  return response.json().then((value) => camelize(value) as T);
}

export function newIdempotencyKey(): string {
  return crypto.randomUUID();
}
