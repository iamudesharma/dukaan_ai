import type { Bootstrap, Role } from "../types";

export interface WorkspaceAccess {
  role: Role;
  isOwner: boolean;
  isManager: boolean;
  isCashier: boolean;
  canViewReports: boolean;
  canViewActivity: boolean;
  canViewSettings: boolean;
  canManageTeam: boolean;
  canEditBusinessSettings: boolean;
  canUseGmail: boolean;
  canViewSuppliers: boolean;
  canManageParties: boolean;
  canRecordPurchases: boolean;
  canRecordExpenses: boolean;
  canRecordSupplierPayments: boolean;
  canRecordCustomerReceipts: boolean;
  canReverseEntries: boolean;
  canExport: boolean;
  canManageStock: boolean;
  canViewWholesalePrices: boolean;
  canViewStockValuation: boolean;
  canViewMargins: boolean;
}

function hasPermission(permissions: readonly string[], permission: string): boolean {
  return permissions.includes("*") || permissions.includes(permission);
}

export function getWorkspaceAccess(bootstrap: Bootstrap): WorkspaceAccess {
  const permissions = bootstrap.permissions ?? [];
  const declaredRoles = [bootstrap.business.role, bootstrap.user.role];
  const hasManagementPermission = hasPermission(permissions, "operations") || hasPermission(permissions, "reports");
  const hasCashierPermission = ["sales", "receipts", "stock", "customers"].some((permission) => permissions.includes(permission));
  // A cashier grant always wins over stale or broader role/permission data.
  const isCashier = declaredRoles.includes("CASHIER")
    || (!hasPermission(permissions, "*") && !hasManagementPermission && hasCashierPermission);
  const role: Role = isCashier
    ? "CASHIER"
    : bootstrap.business.role ?? bootstrap.user.role;
  const isOwner = !isCashier && (role === "OWNER" || hasPermission(permissions, "*"));
  const isManager = !isCashier && (
    role === "MANAGER"
    || hasPermission(permissions, "operations")
    || hasPermission(permissions, "reports")
  );
  const canManageOperations = isOwner || isManager;

  return {
    role,
    isOwner,
    isManager,
    isCashier,
    canViewReports: canManageOperations,
    canViewActivity: canManageOperations,
    canViewSettings: canManageOperations,
    canManageTeam: isOwner,
    canEditBusinessSettings: isOwner,
    canUseGmail: isOwner || isManager,
    canViewSuppliers: canManageOperations,
    canManageParties: canManageOperations,
    canRecordPurchases: canManageOperations,
    canRecordExpenses: canManageOperations,
    canRecordSupplierPayments: canManageOperations,
    canRecordCustomerReceipts: true,
    canReverseEntries: canManageOperations,
    canExport: canManageOperations,
    canManageStock: canManageOperations,
    canViewWholesalePrices: canManageOperations,
    canViewStockValuation: canManageOperations,
    canViewMargins: canManageOperations,
  };
}
