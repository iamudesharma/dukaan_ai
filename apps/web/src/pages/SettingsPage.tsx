import { useState, type FormEvent } from "react";
import { Bell, Building2, Check, FileText, Languages, LockKeyhole, Save } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { PageHeader } from "../components/PageHeader";

export function SettingsPage() {
  const { bootstrap } = useWorkspace();
  const [saved, setSaved] = useState(false);
  function save(event: FormEvent) {
    event.preventDefault();
    setSaved(true);
    window.setTimeout(() => setSaved(false), 2500);
  }
  return (
    <>
      <PageHeader eyebrow="Business preferences" title="Settings" description="Defaults help you move faster, but every transaction remains reviewable before posting." />
      <form className="settings-layout" onSubmit={save}>
        <nav className="settings-nav" aria-label="Settings sections"><a href="#business" className="active"><Building2 />Business profile</a><a href="#invoices"><FileText />GST & invoices</a><a href="#language"><Languages />Language</a><a href="#notifications"><Bell />Notifications</a><a href="#security"><LockKeyhole />Security</a></nav>
        <div className="settings-sections">
          <section className="panel settings-section" id="business"><div className="section-icon"><Building2 /></div><div className="settings-heading"><h2>Business profile</h2><p>Shown on invoices and reports.</p></div><div className="form-grid"><label>Display name<input defaultValue={bootstrap.business.name} /></label><label>Legal name<input defaultValue={bootstrap.business.legalName} /></label><label>Currency<select defaultValue="INR"><option value="INR">INR — Indian Rupee</option></select></label><label>Timezone<select defaultValue="Asia/Kolkata"><option value="Asia/Kolkata">Asia/Kolkata</option></select></label></div></section>
          <section className="panel settings-section" id="invoices"><div className="section-icon"><FileText /></div><div className="settings-heading"><h2>GST & invoices</h2><p>One GST registration is shared across locations in the MVP.</p></div><div className="form-grid"><label>GSTIN<input defaultValue={bootstrap.business.gstin} maxLength={15} /></label><label>Price entry<select defaultValue="inclusive"><option value="inclusive">Tax inclusive</option><option value="exclusive">Tax exclusive</option></select></label><label>Invoice prefix<input defaultValue="KB" /></label><label>Financial year<input value="April to March" readOnly /></label></div><p className="field-note">Final invoice numbers are allocated by the server only when an entry is posted online.</p></section>
          <section className="panel settings-section" id="language"><div className="section-icon"><Languages /></div><div className="settings-heading"><h2>Language</h2><p>Assistant input can mix Hindi, Hinglish and English regardless of this choice.</p></div><div className="choice-row"><label><input type="radio" name="language" defaultChecked />English</label><label><input type="radio" name="language" />हिन्दी</label></div></section>
          <section className="panel settings-section" id="notifications"><div className="section-icon"><Bell /></div><div className="settings-heading"><h2>Notifications</h2><p>Sensitive balances are hidden from lock-screen text by default.</p></div><div className="toggle-list"><label><span><strong>Daily business summary</strong><small>At 8:30 PM for your active locations</small></span><input type="checkbox" defaultChecked /></label><label><span><strong>Low-stock alerts</strong><small>When stock reaches its product threshold</small></span><input type="checkbox" defaultChecked /></label><label><span><strong>Due reminders</strong><small>Prompt you to review before sharing</small></span><input type="checkbox" defaultChecked /></label></div></section>
          <div className="settings-save"><span role="status">{saved ? <><Check />Settings saved</> : null}</span><button className="primary-button"><Save />Save settings</button></div>
        </div>
      </form>
    </>
  );
}
