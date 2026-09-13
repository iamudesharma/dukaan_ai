import { useEffect, useRef, useState, type ReactNode } from "react";
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
import { NavLink, useLocation, useNavigate } from "react-router-dom";
import { useWorkspace } from "../app/WorkspaceContext";
import { clearTokens, demoMode } from "../lib/supabase";
import { logout, searchAll, type SearchResults } from "../data/repository";
import { canSee } from "../lib/permissions";
import { AssistantPanel } from "../features/assistant/AssistantPanel";
import { ManualSaleDialog } from "../features/entries/ManualSaleDialog";

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
  const { bootstrap, locationId, setLocationId, openAssistant, manualSaleOpen, closeManualSale } = useWorkspace();
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
      await logout();
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
  const permissions = bootstrap.permissions ?? [];
  const showReports = canSee(permissions, "reports");
  const showManage = canSee(permissions, "manage");

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
          {nav(primaryNavigation.filter((item) => item.to !== "/reports" || showReports))}
          {showManage ? (
            <>
              <p className="nav-heading second">Manage</p>
              {nav(adminNavigation)}
            </>
          ) : null}
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
            <GlobalSearch />
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
      <ManualSaleDialog open={manualSaleOpen} onClose={closeManualSale} />
    </div>
  );
}

function GlobalSearch() {
  const { bootstrap } = useWorkspace();
  const navigate = useNavigate();
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<SearchResults | null>(null);
  const [searching, setSearching] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (!open) return;
    const timer = window.setTimeout(() => inputRef.current?.focus(), 60);
    return () => window.clearTimeout(timer);
  }, [open ]);

  useEffect(() => {
    const onKey = (event: KeyboardEvent) => {
      if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
        event.preventDefault();
        setOpen((current) => !current);
      }
      if (event.key === "Escape") setOpen(false);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

  useEffect(() => {
    const trimmed = query.trim();
    if (trimmed.length < 2) {
      setResults(null);
      setSearching(false);
      return;
    }
    setSearching(true);
    const timer = window.setTimeout(() => {
      searchAll(bootstrap.business.id, trimmed)
        .then(setResults)
        .catch(() => setResults(null))
        .finally(() => setSearching(false));
    }, 250);
    return () => window.clearTimeout(timer);
  }, [query, bootstrap.business.id]);

  function go(to: string) {
    setOpen(false);
    setQuery("");
    setResults(null);
    navigate(to);
  }

  const empty =
    results !== null &&
    !results.parties.length &&
    !results.products.length &&
    !results.documents.length;

  return (
    <>
      <button className="search-button" type="button" onClick={() => setOpen(true)}>
        <Search aria-hidden="true" />
        <span>Search business</span>
        <kbd>⌘ K</kbd>
      </button>
      {open ? (
        <div className="assistant-backdrop" role="presentation" onMouseDown={(event) => {
          if (event.currentTarget === event.target) setOpen(false);
        }}>
          <section className="assistant-panel" role="dialog" aria-modal="true" aria-label="Search business">
            <div className="assistant-input-wrap">
              <input
                ref={inputRef}
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                placeholder="Parties, products, invoice numbers… (min 2 letters)"
                aria-label="Search business"
              />
            </div>
            {searching ? <p role="status">Searching…</p> : null}
            {empty ? <p className="muted-copy">Nothing found. Searches cover names, phones, SKUs and invoice numbers.</p> : null}
            {results && results.parties.length ? (
              <div>
                <p className="section-label">Parties</p>
                <ul>
                  {results.parties.map((party) => (
                    <li key={party.id}>
                      <button type="button" className="text-button" onClick={() => go("/parties")}>
                        {party.name} · {party.kind.toLowerCase()}
                      </button>
                    </li>
                  ))}
                </ul>
              </div>
            ) : null}
            {results && results.products.length ? (
              <div>
                <p className="section-label">Products</p>
                <ul>
                  {results.products.map((product) => (
                    <li key={product.id}>
                      <button type="button" className="text-button" onClick={() => go("/stock")}>
                        {product.name}{product.sku ? ` · ${product.sku}` : ""}
                      </button>
                    </li>
                  ))}
                </ul>
              </div>
            ) : null}
            {results && results.documents.length ? (
              <div>
                <p className="section-label">Entries</p>
                <ul>
                  {results.documents.map((document) => (
                    <li key={document.id}>
                      <button type="button" className="text-button" onClick={() => go("/entries")}>
                        {document.number} · {document.party}
                      </button>
                    </li>
                  ))}
                </ul>
              </div>
            ) : null}
          </section>
        </div>
      ) : null}
    </>
  );
}
