import createClient, { type ClientOptions } from "openapi-fetch";

import type { paths } from "./types";

export type DukaanApiClient = ReturnType<
  typeof createClient<paths, never>
>;

/** Low-level generated-contract client. Authentication remains the caller's responsibility. */
export function createDukaanClient(
  baseUrl: string,
  options: Omit<ClientOptions, "baseUrl"> = {},
): DukaanApiClient {
  return createClient<paths, never>({
    ...options,
    baseUrl: baseUrl.replace(/\/$/, ""),
  });
}
