import { useState, type FormEvent } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Bell, Building2, Check, FileText, Languages, LockKeyhole, LogOut, Mail, Save } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { PageHeader } from "../components/PageHeader";
import { NotFoundPage } from "./NotFoundPage";
import { changePassword, createGstRegistration, listGstRegistrations, revokeAllSessions, updateGstRegistration } from "../data/repository";
import { apiRequest } from "../lib/api";
import { clearTokens } from "../lib/supabase";
import { GmailReceiptsPanel } from "../features/settings/GmailReceiptsPanel";
import { NotificationsPanel } from "../features/settings/NotificationsPanel";

export function SettingsPage() {
  const { bootstrap, access, locationId } = useWorkspace();
  const queryClient = useQueryClient();
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [name, setName] = useState(bootstrap.business.name);
  const [legalName, setLegalName] = useState(bootstrap.business.legalName);
  const [gstin, setGstin] = useState(bootstrap.business.gstin ?? "");
  const [oldPassword, setOldPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [revokePassword, setRevokePassword] = useState("");
  const [securityMessage, setSecurityMessage] = useState<string | null>(null);
  const [securityError, setSecurityError] = useState<string | null>(null);

  const gst = useQuery({
    queryKey: ["gst", bootstrap.user.id, bootstrap.business.id],
    queryFn: () => listGstRegistrations(bootstrap.business.id),
    enabled: access.canViewSettings,
  });

  const saveBusiness = useMutation({
    mutationFn: async () => {
      if (!access.canEditBusinessSettings) throw new Error("Only the owner can change business settings.");
      const updated = await apiRequest<Record<string, unknown>>(`/api/v1/businesses/${bootstrap.business.id}/`, {
        method: "PATCH",
        body: { name, legal_name: legalName },
      });
      const existing = gst.data?.[0];
      if (gstin.trim()) {
        if (existing) {
          await updateGstRegistration(existing.id, { gstin: gstin.trim() });
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

  const savePassword = useMutation({
    mutationFn: () => changePassword(oldPassword, newPassword),
    onSuccess: () => {
      // Password change revokes every previous access/refresh token. Re-enter
      // through the normal sign-in flow instead of retaining stale credentials.
      clearTokens();
      queryClient.clear();
      window.location.replace("/");
    },
    onError: (err) => {
      setSecurityMessage(null);
      setSecurityError(err instanceof Error ? err.message : "Could not update password.");
    },
  });

  const revokeSessions = useMutation({
    mutationFn: () => revokeAllSessions(revokePassword),
    onSuccess: () => {
      clearTokens();
      queryClient.clear();
      window.location.replace("/");
    },
    onError: (err) => {
      setSecurityMessage(null);
      setSecurityError(err instanceof Error ? err.message : "Could not revoke sessions.");
    },
  });

  function save(event?: FormEvent) {
    event?.preventDefault();
    if (access.canEditBusinessSettings) saveBusiness.mutate();
  }

  function submitPassword(event?: FormEvent) {
    event?.preventDefault();
    if (oldPassword && newPassword) savePassword.mutate();
  }

  function submitRevokeSessions(event: FormEvent) {
    event.preventDefault();
    setSecurityError(null);
    setSecurityMessage(null);
    if (!revokePassword) return;
    if (window.confirm("Revoke every signed-in session, including this one? You will need to sign in again.")) {
      revokeSessions.mutate();
    }
  }

  if (!access.canViewSettings) return <NotFoundPage />;

  return (
    <>
      <PageHeader eyebrow="01 · Business preferences" title="Settings" description="Defaults help you move faster, but every transaction remains reviewable before posting." />
      <div className="settings-layout">
        <nav className="settings-nav" aria-label="Settings sections"><a href="#business" className="active"><Building2 />Business profile</a><a href="#invoices"><FileText />GST & invoices</a>{access.canUseGmail ? <a href="#gmail"><Mail />Gmail receipts</a> : null}<a href="#language"><Languages />Language</a><a href="#notifications"><Bell />Notifications</a><a href="#security"><LockKeyhole />Security</a></nav>
        <div className="settings-sections">
          <section className="panel settings-section" id="business"><div className="section-icon"><Building2 /></div><div className="settings-heading"><h2>Business profile</h2><p>Shown on invoices and reports.</p></div><div className="form-grid"><label>Display name<input value={name} onChange={(e) => setName(e.target.value)} readOnly={!access.canEditBusinessSettings} /></label><label>Legal name<input value={legalName} onChange={(e) => setLegalName(e.target.value)} readOnly={!access.canEditBusinessSettings} /></label><label>Currency<select defaultValue="INR"><option value="INR">INR — Indian Rupee</option></select></label><label>Timezone<select defaultValue="Asia/Kolkata"><option value="Asia/Kolkata">Asia/Kolkata</option></select></label></div></section>
          <section className="panel settings-section" id="invoices"><div className="section-icon"><FileText /></div><div className="settings-heading"><h2>GST & invoices</h2><p>One GST registration is shared across locations in the MVP.</p></div><div className="form-grid"><label>GSTIN<input value={gstin} onChange={(e) => setGstin(e.target.value)} maxLength={15} readOnly={!access.canEditBusinessSettings} /></label><label>Price entry<select defaultValue="inclusive"><option value="inclusive">Tax inclusive</option><option value="exclusive">Tax exclusive</option></select></label><label>Invoice prefix<input defaultValue={gst.data?.[0]?.invoicePrefix ?? "KB"} readOnly /></label><label>Financial year<input value="April to March" readOnly /></label></div><p className="field-note">Final invoice numbers are allocated by the server only when an entry is posted online.</p></section>
          <GmailReceiptsPanel businessId={bootstrap.business.id} locationId={locationId} canUseGmail={access.canUseGmail} />
          <section className="panel settings-section" id="language"><div className="section-icon"><Languages /></div><div className="settings-heading"><h2>Language</h2><p>Assistant input can mix Hindi, Hinglish and English regardless of this choice.</p></div><div className="choice-row"><label><input type="radio" name="language" defaultChecked />English</label><label><input type="radio" name="language" />हिन्दी</label></div></section>
          <NotificationsPanel userId={bootstrap.user.id} businessId={bootstrap.business.id} locationId={locationId} locations={bootstrap.locations} />
          <section className="panel settings-section" id="security"><div className="section-icon"><LockKeyhole /></div><div className="settings-heading"><h2>Security</h2><p>Change your password. Forgot it? Use OTP sign-in instead.</p></div>
            <div className="form-grid">
              <label>Current password<input type="password" value={oldPassword} onChange={(e) => setOldPassword(e.target.value)} /></label>
              <label>New password<input type="password" value={newPassword} onChange={(e) => setNewPassword(e.target.value)} /></label>
            </div>
            <div className="review-actions"><button type="button" className="secondary-button" disabled={savePassword.isPending || !oldPassword || !newPassword} onClick={() => submitPassword()}>{savePassword.isPending ? "Updating…" : "Update password"}</button></div>
            <div className="security-divider"><h3>All devices</h3><p>Revoking sessions signs out this browser and every other signed-in device. Your password is verified by the server before access is revoked.</p></div>
            <form className="revoke-sessions-form" onSubmit={submitRevokeSessions}>
              <label>Current password to revoke sessions<input type="password" autoComplete="current-password" value={revokePassword} onChange={(event) => setRevokePassword(event.target.value)} required /></label>
              <div className="review-actions"><button type="submit" className="secondary-button" disabled={revokeSessions.isPending || !revokePassword}><LogOut />{revokeSessions.isPending ? "Revoking…" : "Revoke all sessions"}</button></div>
            </form>
            {securityError ? <p className="form-error" role="alert">{securityError}</p> : null}
            {securityMessage ? <p role="status">{securityMessage}</p> : null}
          </section>
          {error ? <p className="form-error" role="alert">{error}</p> : null}
          <div className="settings-save"><span role="status">{saved ? <><Check />Settings saved</> : null}</span>{access.canEditBusinessSettings ? <button type="button" className="primary-button" disabled={saveBusiness.isPending} onClick={() => save()}><Save />{saveBusiness.isPending ? "Saving…" : "Save settings"}</button> : <p className="field-note">Only the owner can change business profile and GST settings.</p>}</div>
        </div>
      </div>
    </>
  );
}
