import { describe, expect, it } from "vitest";
import { getWorkspaceAccess } from "./permissions";
import { bootstrap, workspaceWithRole } from "../test/apiMocks";

describe("workspace permissions", () => {
  it("gives owners management access and team controls", () => {
    const access = getWorkspaceAccess(workspaceWithRole("OWNER"));

    expect(access.isOwner).toBe(true);
    expect(access.canViewReports).toBe(true);
    expect(access.canManageTeam).toBe(true);
    expect(access.canUseGmail).toBe(true);
    expect(access.canRecordPurchases).toBe(true);
  });

  it("gives managers operations, reports, settings and Gmail without team controls", () => {
    const access = getWorkspaceAccess(workspaceWithRole("MANAGER"));

    expect(access.isManager).toBe(true);
    expect(access.canViewReports).toBe(true);
    expect(access.canViewSettings).toBe(true);
    expect(access.canUseGmail).toBe(true);
    expect(access.canRecordPurchases).toBe(true);
    expect(access.canManageTeam).toBe(false);
    expect(access.canEditBusinessSettings).toBe(false);
  });

  it("keeps cashier sales, receipts, retail stock and customers usable", () => {
    const access = getWorkspaceAccess(workspaceWithRole("CASHIER"));

    expect(access.isCashier).toBe(true);
    expect(access.canRecordCustomerReceipts).toBe(true);
    expect(access.canViewReports).toBe(false);
    expect(access.canViewSettings).toBe(false);
    expect(access.canManageTeam).toBe(false);
    expect(access.canUseGmail).toBe(false);
    expect(access.canViewSuppliers).toBe(false);
    expect(access.canRecordPurchases).toBe(false);
    expect(access.canRecordExpenses).toBe(false);
    expect(access.canRecordSupplierPayments).toBe(false);
    expect(access.canReverseEntries).toBe(false);
    expect(access.canManageStock).toBe(false);
    expect(access.canViewWholesalePrices).toBe(false);
    expect(access.canViewStockValuation).toBe(false);
    expect(access.canViewMargins).toBe(false);
  });

  it("treats a cashier business role as authoritative over stale owner data", () => {
    const workspace = workspaceWithRole("OWNER", {
      business: { ...bootstrap.business, role: "CASHIER" },
      permissions: ["*"],
    });

    expect(getWorkspaceAccess(workspace).isCashier).toBe(true);
    expect(getWorkspaceAccess(workspace).canViewReports).toBe(false);
  });

  it("recognizes cashier permission lists even when role data is stale", () => {
    const workspace = workspaceWithRole("OWNER", {
      permissions: ["sales", "receipts", "stock", "customers"],
    });
    const access = getWorkspaceAccess(workspace);

    expect(access.isCashier).toBe(true);
    expect(access.canRecordPurchases).toBe(false);
    expect(access.canViewWholesalePrices).toBe(false);
  });

  it("uses the business role when permissions are absent", () => {
    const workspace: typeof bootstrap = {
      ...bootstrap,
      user: { ...bootstrap.user, role: "OWNER" },
      business: { ...bootstrap.business, role: "MANAGER" },
      permissions: [],
    };
    const access = getWorkspaceAccess(workspace);

    expect(access.role).toBe("MANAGER");
    expect(access.canViewReports).toBe(true);
    expect(access.canUseGmail).toBe(true);
    expect(access.canManageTeam).toBe(false);
  });
});
