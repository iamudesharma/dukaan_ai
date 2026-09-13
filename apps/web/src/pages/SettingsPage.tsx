import { useEffect, useState, type FormEvent } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Bell, Building2, Check, FileText, Languages, LockKeyhole, Save } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { PageHeader } from "../components/PageHeader";
import {
  changePassword,
  createGstRegistration,
  getBusiness,
  getNotificationPrefs,
  listGstRegistrations,
  logoutAll,
  updateBusiness,
  updateGstRegistration,
  updateMe,
  updateNotificationPrefs,
} from "../data/repository";
import { clearTokens } from "../lib/supabase";

export function SettingsPage() {
  const { bootstrap } = useWorkspace();
  const queryClient = useQueryClient();
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [name, setName] = useState(bootstrap.business.name);
  const [legalName, setLegalName] = useState(bootstrap.business.legalName);
  const [gstin, setGstin] = useState(bootstrap.business.gstin ?? "");
  const [displayName, setDisplayName] = useState(bootstrap.user.name);
  const [priceMode, setPriceMode] = useState<"RETAIL" | "WHOLESALE">("RETAIL");
  const [invoicePrefix, setInvoicePrefix] = useState("");
  const [oldPassword, setOldPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [securityMessage, setSecurityMessage] = useState<string | null>(null);

  const gst = useQuery({
    queryKey: ["gst", bootstrap.business.id],
    queryFn: () => listGstRegistrations(bootstrap.business.id),
  });
  const business = useQuery({
    queryKey: ["business", bootstrap.business.id],
    queryFn: () => getBusiness(bootstrap.business.id),
  });
  const prefs = useQuery({
    queryKey: ["notification-prefs", bootstrap.business.id],
    queryFn: () => getNotificationPrefs(bootstrap.business.id),
  });
  const togglePref = useMutation({
    mutationFn: (patch: Parameters<typeof updateNotificationPrefs>[1]) =>
      updateNotificationPrefs(bootstrap.business.id, patch),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["notification-prefs"] });
    },
  });

  useEffect(() => {
    if (business.data?.defaultPriceMode) setPriceMode(business.data.defaultPriceMode);
  }, [business.data?.defaultPriceMode]);
  useEffect(() => {
    if (gst.data?.[0]?.invoicePrefix) setInvoicePrefix(gst.data[0].invoicePrefix);
  }, [gst.data]);

  const saveBusiness = useMutation({
    mutationFn: async () => {
      const updated = await updateBusiness(bootstrap.business.id, {
        name,
        legalName,
        defaultPriceMode: priceMode,
      });
      if (displayName.trim() && displayName.trim() !== bootstrap.user.name) {
        await updateMe(displayName.trim());
      }
      const existing = gst.data?.[0];
      if (gstin.trim()) {
        if (existing) {
          await updateGstRegistration(existing.id, {
            gstin: gstin.trim(),
            ...(invoicePrefix.trim() ? { invoicePrefix: invoicePrefix.trim() } : {}),
          });
        } else {
          await createGstRegistration({ business: bootstrap.business.id, gstin: gstin.trim(), legalName });
        }
      }
      return updated;
    },
    onSuccess: async () => {
      await queryClient.invalidateQueries();
      setSaved(true);
      setError(null);
      window.setTimeout(() => setSaved(false), 2500);
    },
    onError: (err) => setError(err instanceof Error ? err.message : "Could not save settings."),
  });

  const signOutEverywhere = useMutation({
    mutationFn: async () => {
      try {
        await logoutAll();
      } finally {
        clearTokens();
        window.location.reload();
      }
    },
  });

  const savePassword = useMutation({
    mutationFn: () => changePassword(oldPassword, newPassword),
    onSuccess: () => {
      setSecurityMessage("Password updated.");
      setOldPassword("");
      setNewPassword("");
    },
    onError: (err) => setSecurityMessage(err instanceof Error ? err.message : "Could not update password."),
  });

  function save(event: FormEvent) {
    event.preventDefault();
    saveBusiness.mutate();
  }

  function submitPassword(event: FormEvent) {
    event.preventDefault();
    if (oldPassword && newPassword) savePassword.mutate();
  }

  return (
    <>
      <PageHeader eyebrow="Business preferences" title="Settings" description="Defaults help you move faster, but every transaction remains reviewable before posting." />
      <form className="settings-layout" onSubmit={save}>
        <nav className="settings-nav" aria-label="Settings sections"><a href="#business" className="active"><Building2 />Business profile</a><a href="#invoices"><FileText />GST & invoices</a><a href="#language"><Languages />Language</a><a href="#notifications"><Bell />Notifications</a><a href="#security"><LockKeyhole />Security</a></nav>
        <div className="settings-sections">
          <section className="panel settings-section" id="business"><div className="section-icon"><Building2 /></div><div className="settings-heading"><h2>Business profile</h2><p>Shown on invoices and reports.</p></div><div className="form-grid"><label>Display name<input value={name} onChange={(e) => setName(e.target.value)} /></label><label>Legal name<input value={legalName} onChange={(e) => setLegalName(e.target.value)} /></label><label>Your display name<input value={displayName} onChange={(e) => setDisplayName(e.target.value)} /></label><label>Currency<select defaultValue="INR"><option value="INR">INR — Indian Rupee</option></select></label><label>Timezone<select defaultValue="Asia/Kolkata"><option value="Asia/Kolkata">Asia/Kolkata</option></select></label></div></section>
          <section className="panel settings-section" id="invoices"><div className="section-icon"><FileText /></div><div className="settings-heading"><h2>GST & invoices</h2><p>One GST registration is shared across locations in the MVP.</p></div><div className="form-grid"><label>GSTIN<input value={gstin} onChange={(e) => setGstin(e.target.value)} maxLength={15} /></label><label>Price entry<select value={priceMode} onChange={(e) => setPriceMode(e.target.value as "RETAIL" | "WHOLESALE")}><option value="RETAIL">Retail prices by default</option><option value="WHOLESALE">Wholesale prices by default</option></select></label><label>Invoice prefix<input value={invoicePrefix} onChange={(e) => setInvoicePrefix(e.target.value)} placeholder={gst.data?.[0]?.invoicePrefix ?? "INV"} maxLength={8} /></label><label>Financial year<input value="April to March" readOnly /></label></div><p className="field-note">Final invoice numbers are allocated by the server only when an entry is posted online.</p></section>
          <section className="panel settings-section" id="language"><div className="section-icon"><Languages /></div><div className="settings-heading"><h2>Language</h2><p>Assistant input can mix Hindi, Hinglish and English regardless of this choice.</p></div><div className="choice-row"><label><input type="radio" name="language" defaultChecked />English</label><label><input type="radio" name="language" />हिन्दी</label></div></section>
          <section className="panel settings-section" id="notifications"><div className="section-icon"><Bell /></div><div className="settings-heading"><h2>Notifications</h2><p>Sensitive balances are hidden from lock-screen text by default.</p></div><div className="toggle-list"><label><span><strong>Daily business summary</strong><small>At 8:30 PM for your active locations</small></span><input type="checkbox" checked={prefs.data?.dailySummary ?? true} onChange={(e) => togglePref.mutate({ dailySummary: e.target.checked })} /></label><label><span><strong>Low-stock alerts</strong><small>When stock reaches its product threshold</small></span><input type="checkbox" checked={prefs.data?.lowStockAlerts ?? true} onChange={(e) => togglePref.mutate({ lowStockAlerts: e.target.checked })} /></label><label><span><strong>Due reminders</strong><small>Prompt you to review before sharing</small></span><input type="checkbox" checked={prefs.data?.dueReminders ?? true} onChange={(e) => togglePref.mutate({ dueReminders: e.target.checked })} /></label></div></section>
          <section className="panel settings-section" id="security"><div className="section-icon"><LockKeyhole /></div><div className="settings-heading"><h2>Security</h2><p>Change your password. Forgot it? Use OTP sign-in instead.</p></div>
            <div className="form-grid">
              <label>Current password<input type="password" value={oldPassword} onChange={(e) => setOldPassword(e.target.value)} /></label>
              <label>New password<input type="password" value={newPassword} onChange={(e) => setNewPassword(e.target.value)} /></label>
            </div>
            <div className="review-actions"><button type="button" className="secondary-button" disabled={savePassword.isPending || !oldPassword || !newPassword} onClick={submitPassword}>{savePassword.isPending ? "Updating…" : "Update password"}</button><button type="button" className="secondary-button" disabled={signOutEverywhere.isPending} onClick={() => { if (window.confirm("Sign out on every device, including this one?")) signOutEverywhere.mutate(); }}>{signOutEverywhere.isPending ? "Signing out…" : "Sign out everywhere"}</button></div>
            {securityMessage ? <p role="status">{securityMessage}</p> : null}
          </section>
          {error ? <p className="form-error" role="alert">{error}</p> : null}
          <div className="settings-save"><span role="status">{saved ? <><Check />Settings saved</> : null}</span><button className="primary-button" disabled={saveBusiness.isPending}><Save />{saveBusiness.isPending ? "Saving…" : "Save settings"}</button></div>
        </div>
      </form>
    </>
  );
}
