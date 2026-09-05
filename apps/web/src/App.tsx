import { useEffect } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { Route, Routes } from "react-router-dom";
import { WorkspaceProvider } from "./app/WorkspaceContext";
import { AppShell } from "./components/AppShell";
import { EmptyState } from "./components/EmptyState";
import { LoadingBlock } from "./components/LoadingBlock";
import { getBootstrap } from "./data/repository";
import { AuthGate } from "./features/auth/AuthGate";
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

  useEffect(() => {
    const refresh = () => void queryClient.invalidateQueries();
    window.addEventListener("dukaanai:demo-updated", refresh);
    return () => window.removeEventListener("dukaanai:demo-updated", refresh);
  }, [queryClient]);

  if (bootstrap.isLoading) {
    return <main className="full-page-state"><LoadingBlock label="Opening your business…" /><p>Opening your business…</p></main>;
  }
  if (bootstrap.error || !bootstrap.data) {
    return <main className="full-page-state"><EmptyState title="We couldn’t open your business" detail={bootstrap.error?.message ?? "Please sign in again or check your connection."} /></main>;
  }
  if (!bootstrap.data.locations.length) {
    return <main className="full-page-state"><EmptyState title="Add your first location" detail="A location is required before recording any business activity." /></main>;
  }

  return (
    <WorkspaceProvider bootstrap={bootstrap.data}>
      <AppShell>
        <Routes>
          <Route path="/" element={<OverviewPage />} />
          <Route path="/entries" element={<EntriesPage />} />
          <Route path="/stock" element={<StockPage />} />
          <Route path="/parties" element={<PartiesPage />} />
          <Route path="/reports" element={<ReportsPage />} />
          <Route path="/team" element={<TeamPage />} />
          <Route path="/activity" element={<ActivityPage />} />
          <Route path="/settings" element={<SettingsPage />} />
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </AppShell>
    </WorkspaceProvider>
  );
}

export default function App() {
  return <AuthGate><AuthenticatedApp /></AuthGate>;
}
