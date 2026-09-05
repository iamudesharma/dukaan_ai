import type { ApiErrorShape } from "../types";
import { accessToken } from "./supabase";

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

export async function apiRequest<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const token = await accessToken();
  const headers = new Headers(options.headers);
  headers.set("Accept", "application/json");
  headers.set("X-Client", "dukaanai-web/0.1.0");
  if (options.body !== undefined) headers.set("Content-Type", "application/json");
  if (token) headers.set("Authorization", `Bearer ${token}`);
  if (options.idempotencyKey) headers.set("Idempotency-Key", options.idempotencyKey);

  const response = await fetch(`${apiUrl}${path}`, {
    ...options,
    headers,
    body: options.body === undefined ? undefined : JSON.stringify(options.body),
  });

  if (!response.ok) {
    const fallback: ApiErrorShape = {
      code: `http_${response.status}`,
      message: "The request could not be completed.",
      retryable: response.status >= 500,
    };
    let detail = fallback;
    try {
      const raw = await response.json();
      const server = raw.error?.detail;
      detail = {
        ...fallback,
        ...(raw.error ? {} : raw),
        ...(server && typeof server === "object" && server.message
          ? { message: String(server.message), code: String(server.code ?? raw.error.code) }
          : typeof server === "string" ? { message: server, code: raw.error.code } : {}),
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
