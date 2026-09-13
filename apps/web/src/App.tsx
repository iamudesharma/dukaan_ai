import { useEffect, useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { Route, Routes } from "react-router-dom";
import { WorkspaceProvider } from "./app/WorkspaceContext";
import { AppShell } from "./components/AppShell";
import { EmptyState } from "./components/EmptyState";
import { LoadingBlock } from "./components/LoadingBlock";
import { getBootstrap } from "./data/repository";
import { AuthGate } from "./features/auth/AuthGate";
import { OnboardingWizard } from "./features/onboarding/OnboardingWizard";
import { ApiError } from "./lib/api";
import { canSee } from "./lib/permissions";
import { ActivityPage } from "./pages/ActivityPage";
import { EntriesPage } from "./pages/EntriesPage";
import { NotFoundPage } from "./pages/NotFoundPage";
import { OverviewPage } from "./pages/OverviewPage";
import { PartiesPage } from "./pages/PartiesPage";
import { ReportsPage } from "./pages/ReportsPage";
import { SettingsPage } from "./pages/SettingsPage";
import { StockPage } from "./pages/StockPage";
import { TeamPage } from "./pages/TeamPage";

function AuthenticatedApp() {
  const queryClient = useQueryClient();
  const bootstrap = useQuery({ queryKey: ["bootstrap"], queryFn: getBootstrap, retry: 1 });
  const [onboarded, setOnboarded] = useState(false);

  useEffect(() => {
    const refresh = () => void queryClient.invalidateQueries();
    window.addEventListener("dukaanai:demo-updated", refresh);
    return () => window.removeEventListener("dukaanai:demo-updated", refresh);
  }, [queryClient]);

  if (bootstrap.isLoading) {
    return <main className="full-page-state"><LoadingBlock label="Opening your business…" /><p>Opening your business…</p></main>;
  }
  const needsOnboarding = bootstrap.error instanceof ApiError && bootstrap.error.status === 404;
  if (needsOnboarding && !onboarded) {
    return <OnboardingWizard onDone={() => { setOnboarded(true); void bootstrap.refetch(); }} />;
  }
  if (bootstrap.error || !bootstrap.data) {
    return <main className="full-page-state"><EmptyState title="We couldn’t open your business" detail={bootstrap.error?.message ?? "Please sign in again or check your connection."} /></main>;
  }
  if (!bootstrap.data.locations.length) {
    return <main className="full-page-state"><EmptyState title="Add your first location" detail="A location is required before recording any business activity." /></main>;
  }

  const permissions = bootstrap.data.permissions ?? [];
  const showReports = canSee(permissions, "reports");
  const showManage = canSee(permissions, "manage");
  const noAccess = <main className="full-page-state"><EmptyState title="No access" detail="Your role cannot open this section." /></main>;

  return (
    <WorkspaceProvider bootstrap={bootstrap.data}>
      <AppShell>
        <Routes>
          <Route path="/" element={<OverviewPage />} />
          <Route path="/entries" element={<EntriesPage />} />
          <Route path="/stock" element={<StockPage />} />
          <Route path="/parties" element={<PartiesPage />} />
          <Route path="/reports" element={showReports ? <ReportsPage /> : noAccess} />
          <Route path="/team" element={showManage ? <TeamPage /> : noAccess} />
          <Route path="/activity" element={showManage ? <ActivityPage /> : noAccess} />
          <Route path="/settings" element={showManage ? <SettingsPage /> : noAccess} />
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </AppShell>
    </WorkspaceProvider>
  );
}

export default function App() {
  return <AuthGate><AuthenticatedApp /></AuthGate>;
}
