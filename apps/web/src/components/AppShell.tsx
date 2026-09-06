import { useEffect, useState, type ReactNode } from "react";
import {
  Activity,
  BarChart3,
  Boxes,
  Building2,
  ChevronDown,
  CircleHelp,
  CloudOff,
  FileClock,
  LayoutDashboard,
  Menu,
  Plus,
  ReceiptText,
  Search,
  Settings,
  Sparkles,
  Store,
  Users,
  X,
} from "lucide-react";
import { NavLink, useLocation } from "react-router-dom";
import { useWorkspace } from "../app/WorkspaceContext";
import { clearTokens, demoMode, getAccessToken } from "../lib/supabase";
import { AssistantPanel } from "../features/assistant/AssistantPanel";

const primaryNavigation = [
  { to: "/", label: "Overview", icon: LayoutDashboard },
  { to: "/entries", label: "Entries", icon: ReceiptText },
  { to: "/stock", label: "Stock & transfers", icon: Boxes },
  { to: "/parties", label: "Parties", icon: Users },
  { to: "/reports", label: "Reports", icon: BarChart3 },
];

const adminNavigation = [
  { to: "/team", label: "Team & locations", icon: Building2 },
  { to: "/activity", label: "Activity", icon: Activity },
  { to: "/settings", label: "Settings", icon: Settings },
];

const pageNames: Record<string, string> = {
  "/": "Overview",
  "/entries": "Entries",
  "/stock": "Stock & transfers",
  "/parties": "Parties",
  "/reports": "Reports",
  "/team": "Team & locations",
  "/activity": "Activity",
  "/settings": "Settings",
};

export function AppShell({ children }: { children: ReactNode }) {
  const { bootstrap, locationId, setLocationId, openAssistant } = useWorkspace();
  const [menuOpen, setMenuOpen] = useState(false);
  const [online, setOnline] = useState(navigator.onLine);
  const location = useLocation();

  useEffect(() => {
    const onOnline = () => setOnline(true);
    const onOffline = () => setOnline(false);
    window.addEventListener("online", onOnline);
    window.addEventListener("offline", onOffline);
    return () => {
      window.removeEventListener("online", onOnline);
      window.removeEventListener("offline", onOffline);
    };
  }, []);

  useEffect(() => setMenuOpen(false), [location.pathname]);

  async function signOut() {
    try {
      await fetch("/api/v1/auth/logout/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${await getAccessToken() ?? ""}`,
        },
        body: JSON.stringify({ refresh: localStorage.getItem("dukaan_refresh_token") }),
      });
    } catch {
      // Still clear local tokens on network failure.
    }
    clearTokens();
    window.location.reload();
  }

  const nav = (items: typeof primaryNavigation) => items.map(({ to, label, icon: Icon }) => (
    <NavLink key={to} to={to} end={to === "/"} className={({ isActive }) => isActive ? "nav-link active" : "nav-link"}>
      <Icon aria-hidden="true" />
      <span>{label}</span>
    </NavLink>
  ));

  return (
    <div className="app-shell">
      {!online ? (
        <div className="offline-banner" role="status"><CloudOff aria-hidden="true" />Offline — new entries will be saved as drafts only.</div>
      ) : null}
      <aside className={menuOpen ? "sidebar open" : "sidebar"}>
        <div className="sidebar-brand">
          <span className="brand-mark"><Store aria-hidden="true" /></span>
          <div><strong>DukaanAI</strong><span>Business console</span></div>
          <button className="icon-button sidebar-close" onClick={() => setMenuOpen(false)} aria-label="Close navigation"><X /></button>
        </div>

        <nav aria-label="Main navigation">
          <p className="nav-heading">Workspace</p>
          {nav(primaryNavigation)}
          <p className="nav-heading second">Manage</p>
          {nav(adminNavigation)}
        </nav>

        <div className="sidebar-footer">
          <button type="button" className="support-link"><CircleHelp aria-hidden="true" />Help & support</button>
          <div className="user-card">
            <span className="avatar">AS</span>
            <div><strong>{bootstrap.user.name}</strong><span>{bootstrap.user.role.toLowerCase()}</span></div>
            {!demoMode ? (
              <button className="icon-button" aria-label="Sign out" title="Sign out" onClick={() => void signOut()}><ChevronDown /></button>
            ) : null}
          </div>
        </div>
      </aside>

      {menuOpen ? <button className="mobile-scrim" aria-label="Close navigation" onClick={() => setMenuOpen(false)} /> : null}

      <div className="main-column">
        <header className="topbar">
          <div className="topbar-start">
            <button className="icon-button mobile-menu" onClick={() => setMenuOpen(true)} aria-label="Open navigation"><Menu /></button>
            <div className="desktop-page-name"><span>{bootstrap.business.name}</span><strong>{pageNames[location.pathname] ?? "DukaanAI"}</strong></div>
          </div>
          <label className="location-picker">
            <span>Location</span>
            <select value={locationId} onChange={(event) => setLocationId(event.target.value)}>
              {bootstrap.locations.map((item) => <option key={item.id} value={item.id}>{item.name}</option>)}
            </select>
            <ChevronDown aria-hidden="true" />
          </label>
          <div className="topbar-actions">
            <button className="search-button" type="button"><Search aria-hidden="true" /><span>Search business</span><kbd>⌘ K</kbd></button>
            {demoMode ? <span className="demo-pill">Demo data</span> : null}
            <button className="primary-button compact" onClick={openAssistant}><Sparkles aria-hidden="true" />Ask / Add</button>
          </div>
        </header>

        <main className="page-content">{children}</main>

        <nav className="mobile-bottom-nav" aria-label="Mobile navigation">
          <NavLink to="/" end><LayoutDashboard /><span>Today</span></NavLink>
          <NavLink to="/entries"><ReceiptText /><span>Entries</span></NavLink>
          <button className="mobile-add" onClick={openAssistant}><Plus /><span>Ask/Add</span></button>
          <NavLink to="/stock"><Boxes /><span>Stock</span></NavLink>
          <NavLink to="/parties"><Users /><span>Parties</span></NavLink>
        </nav>
      </div>
      <AssistantPanel />
    </div>
  );
}
