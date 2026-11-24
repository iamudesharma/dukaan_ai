import type { ReactNode } from "react";
import { useQuery } from "@tanstack/react-query";
import { Route, Routes } from "react-router-dom";
import { useWorkspace, WorkspaceProvider } from "./app/WorkspaceContext";
import { AppShell } from "./components/AppShell";
import { EmptyState } from "./components/EmptyState";
import { LoadingBlock } from "./components/LoadingBlock";
import { getBootstrap, getMe } from "./data/repository";
import { AuthGate } from "./features/auth/AuthGate";
import { OnboardingPage } from "./features/onboarding/OnboardingPage";
import { ActivityPage } from "./pages/ActivityPage";
import { EntriesPage } from "./pages/EntriesPage";
import { InvitationPage } from "./pages/InvitationPage";
import { NotFoundPage } from "./pages/NotFoundPage";
import { OverviewPage } from "./pages/OverviewPage";
import { PartiesPage } from "./pages/PartiesPage";
import { ReportsPage } from "./pages/ReportsPage";
import { SettingsPage } from "./pages/SettingsPage";
import { StockPage } from "./pages/StockPage";
import { TeamPage } from "./pages/TeamPage";

function LoadingScreen({ label }: { label: string }) {
  return <main className="full-page-state"><LoadingBlock label={label} /><p>{label}</p></main>;
}

function RequireAccess({ allowed, children }: { allowed: boolean; children: ReactNode }) {
  return allowed ? children : <NotFoundPage />;
}

function WorkspaceRoutes() {
  const { access } = useWorkspace();
  return (
    <Routes>
      <Route path="/" element={<OverviewPage />} />
      <Route path="/entries" element={<EntriesPage />} />
      <Route path="/stock" element={<StockPage />} />
      <Route path="/parties" element={<PartiesPage />} />
      <Route path="/reports" element={<RequireAccess allowed={access.canViewReports}><ReportsPage /></RequireAccess>} />
      <Route path="/team" element={<RequireAccess allowed={access.canManageTeam}><TeamPage /></RequireAccess>} />
      <Route path="/activity" element={<RequireAccess allowed={access.canViewActivity}><ActivityPage /></RequireAccess>} />
      <Route path="/settings" element={<RequireAccess allowed={access.canViewSettings}><SettingsPage /></RequireAccess>} />
      <Route path="/invitation" element={<InvitationPage />} />
      <Route path="*" element={<NotFoundPage />} />
    </Routes>
  );
}

function AuthenticatedApp() {
  const me = useQuery({ queryKey: ["me"], queryFn: getMe, retry: 1 });
  const hasWorkspace = (me.data?.memberships.length ?? 0) > 0;
  const bootstrap = useQuery({
    queryKey: ["bootstrap"],
    queryFn: getBootstrap,
    enabled: hasWorkspace,
    retry: 1,
  });

  if (me.isLoading) {
    return <LoadingScreen label="Checking your workspace…" />;
  }
  if (me.error || !me.data) {
    return (
      <main className="full-page-state">
        <EmptyState
          title="We couldn’t load your account"
          detail={me.error?.message ?? "Please sign in again or check your connection."}
        />
      </main>
    );
  }
  if (!hasWorkspace) {
    return <OnboardingPage />;
  }
  if (bootstrap.isLoading) {
    return <LoadingScreen label="Opening your business…" />;
  }
  if (bootstrap.error || !bootstrap.data) {
    return (
      <main className="full-page-state">
        <EmptyState
          title="We couldn’t open your business"
          detail={bootstrap.error?.message ?? "Please sign in again or check your connection."}
        />
      </main>
    );
  }
  if (!bootstrap.data.locations.length) {
    return (
      <main className="full-page-state">
        <EmptyState
          title="Add your first location"
          detail="A location is required before recording any business activity. Ask the business owner to add one."
        />
      </main>
    );
  }

  return (
    <WorkspaceProvider bootstrap={bootstrap.data}>
      <AppShell>
        <WorkspaceRoutes />
      </AppShell>
    </WorkspaceProvider>
  );
}

export default function App() {
  return <AuthGate><AuthenticatedApp /></AuthGate>;
}
