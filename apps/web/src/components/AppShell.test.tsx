import { afterEach, describe, expect, it, vi } from "vitest";
import { screen, within } from "@testing-library/react";
import { AppShell } from "./AppShell";
import { renderWithWorkspace } from "../test/renderWorkspace";
import { workspaceWithRole } from "../test/apiMocks";

afterEach(() => vi.unstubAllGlobals());

describe("AppShell role-aware navigation", () => {
  it("shows owner management pages", () => {
    renderWithWorkspace(<AppShell><div>Workspace</div></AppShell>, workspaceWithRole("OWNER"));
    const navigation = within(screen.getByRole("navigation", { name: "Main navigation" }));

    expect(navigation.getByRole("link", { name: "Reports" })).toBeInTheDocument();
    expect(navigation.getByRole("link", { name: "Team & locations" })).toBeInTheDocument();
    expect(navigation.getByRole("link", { name: "Activity" })).toBeInTheDocument();
    expect(navigation.getByRole("link", { name: "Settings" })).toBeInTheDocument();
  });

  it("shows manager reports, activity and settings but not team controls", () => {
    renderWithWorkspace(<AppShell><div>Workspace</div></AppShell>, workspaceWithRole("MANAGER"));
    const navigation = within(screen.getByRole("navigation", { name: "Main navigation" }));

    expect(navigation.getByRole("link", { name: "Reports" })).toBeInTheDocument();
    expect(navigation.getByRole("link", { name: "Activity" })).toBeInTheDocument();
    expect(navigation.getByRole("link", { name: "Settings" })).toBeInTheDocument();
    expect(navigation.queryByRole("link", { name: "Team & locations" })).not.toBeInTheDocument();
  });

  it("keeps cashier navigation to sales, retail stock and customers", () => {
    renderWithWorkspace(<AppShell><div>Workspace</div></AppShell>, workspaceWithRole("CASHIER"));
    const navigation = within(screen.getByRole("navigation", { name: "Main navigation" }));

    expect(navigation.getByRole("link", { name: "Overview" })).toBeInTheDocument();
    expect(navigation.getByRole("link", { name: "Entries" })).toBeInTheDocument();
    expect(navigation.getByRole("link", { name: "Stock" })).toBeInTheDocument();
    expect(navigation.getByRole("link", { name: "Customers" })).toBeInTheDocument();
    expect(navigation.queryByRole("link", { name: "Reports" })).not.toBeInTheDocument();
    expect(navigation.queryByRole("link", { name: "Team & locations" })).not.toBeInTheDocument();
    expect(navigation.queryByRole("link", { name: "Activity" })).not.toBeInTheDocument();
    expect(navigation.queryByRole("link", { name: "Settings" })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: /Search business/i })).not.toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Ask \/ Add/i })).toBeInTheDocument();
  });
});
