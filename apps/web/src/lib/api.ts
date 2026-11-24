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
      setTokens({ access: data.access, refresh });
      return data.access;
    }
  } catch {
    // fall through
  }
  return null;
}

async function sendRequest(path: string, options: RequestOptions): Promise<Response> {
  let token = await accessToken();
  const headers = new Headers(options.headers);
  const isFormData = typeof FormData !== "undefined" && options.body instanceof FormData;
  if (!headers.has("Accept")) headers.set("Accept", "application/json");
  headers.set("X-Client", "dukaanai-web/0.1.0");
  if (options.body !== undefined && !isFormData) headers.set("Content-Type", "application/json");
  if (token) headers.set("Authorization", `Bearer ${token}`);
  if (options.idempotencyKey) headers.set("Idempotency-Key", options.idempotencyKey);
  const requestBody = options.body === undefined
    ? undefined
    : isFormData ? options.body as FormData : JSON.stringify(options.body);

  let response = await fetch(`${apiUrl}${path}`, {
    ...options,
    headers,
    body: requestBody,
  });

  if (response.status === 401 && token) {
    const newToken = await refreshAccessToken();
    if (newToken) {
      headers.set("Authorization", `Bearer ${newToken}`);
      response = await fetch(`${apiUrl}${path}`, {
        ...options,
        headers,
        body: requestBody,
      });
    }
  }
  return response;
}

function messageFromDetail(value: unknown): string | null {
  if (typeof value === "string" && value.trim()) return value;
  if (!value || typeof value !== "object" || Array.isArray(value)) return null;
  const record = value as Record<string, unknown>;
  if (typeof record.message === "string" && record.message.trim()) return record.message;
  for (const [field, messages] of Object.entries(record)) {
    const text = Array.isArray(messages) ? messages.find((item) => typeof item === "string") : messages;
    if (typeof text === "string" && text.trim()) return field === "detail" ? text : `${field}: ${text}`;
  }
  return null;
}

async function normalizedError(response: Response): Promise<ApiErrorShape> {
  const fallback: ApiErrorShape = {
    code: `http_${response.status}`,
    message: "The request could not be completed.",
    retryable: response.status >= 500,
  };
  try {
    const raw = await response.json();
    const server = raw.error?.detail;
    const message = messageFromDetail(server) ?? messageFromDetail(raw.detail) ?? messageFromDetail(raw);
    const code = raw.error?.code ?? raw.code ?? (server && typeof server === "object" ? server.code : undefined);
    const fields = (server && typeof server === "object" ? server : raw.fields) as Record<string, string[]> | undefined;
    return {
      ...fallback,
      ...(raw.error ? {} : raw),
      ...(message ? { message } : {}),
      ...(code ? { code: String(code) } : {}),
      ...(fields && !Array.isArray(fields) && typeof fields === "object" ? { fields } : {}),
    };
  } catch {
    // A safe normalized response is returned for non-JSON upstream failures.
    return fallback;
  }
}

export async function apiRequest<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const response = await sendRequest(path, options);
  if (!response.ok) throw new ApiError(response.status, await normalizedError(response));
  if (response.status === 204) return undefined as T;
  return response.json().then((value) => camelize(value) as T);
}

export interface DownloadedFile {
  blob: Blob;
  filename: string;
}

/** Binary counterpart to apiRequest, retaining auth refresh and normalized errors. */
export async function apiRequestFile(
  path: string,
  options: RequestOptions = {},
): Promise<DownloadedFile> {
  const response = await sendRequest(path, options);
  if (!response.ok) throw new ApiError(response.status, await normalizedError(response));
  const disposition = response.headers.get("Content-Disposition") ?? "";
  const encodedName = disposition.match(/filename\*=UTF-8''([^;]+)/i)?.[1];
  const quotedName = disposition.match(/filename="([^"]+)"/i)?.[1];
  let decodedName = quotedName ?? "download";
  if (encodedName) {
    try { decodedName = decodeURIComponent(encodedName); } catch { /* Keep the safe quoted fallback. */ }
  }
  const filename = decodedName.split(/[\\/]/).pop() || "download";
  return { blob: await response.blob(), filename };
}

export function newIdempotencyKey(): string {
  return crypto.randomUUID();
}
