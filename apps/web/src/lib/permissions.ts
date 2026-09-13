/** Role-based UI gating mirrors the backend permission contract.
 *
 * Bootstrap permissions are ["*"] for owners, a capability list for cashiers
 * (sales, receipts, stock, customers), and ["operations", "reports"] for
 * managers. The API still enforces every boundary; this only hides UI.
 */
export function canSee(permissions: string[], section: "reports" | "manage"): boolean {
  if (permissions.includes("*")) return true;
  if (section === "reports") return permissions.includes("reports");
  return false;
}
