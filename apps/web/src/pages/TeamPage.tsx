import { Building2, MapPin, Plus, ShieldCheck, UserCog, Users } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { PageHeader } from "../components/PageHeader";
import { StatusBadge } from "../components/StatusBadge";

const team = [
  { id: "1", name: "Amit Sharma", phone: "+91 98765 43210", role: "Owner", locations: "All locations", status: "Active" },
  { id: "2", name: "Neha Verma", phone: "+91 98991 22018", role: "Manager", locations: "Karol Bagh, Lajpat Nagar", status: "Active" },
  { id: "3", name: "Vijay Singh", phone: "+91 98180 44032", role: "Cashier", locations: "Karol Bagh", status: "Active" },
];

export function TeamPage() {
  const { bootstrap } = useWorkspace();
  return (
    <>
      <PageHeader eyebrow="Access control" title="Team & locations" description="Invite each person with their own phone number. Access can be revoked without waiting for a token to expire." actions={<button className="primary-button"><Plus />Invite member</button>} />
      <section className="team-layout">
        <article className="panel data-panel">
          <div className="panel-heading simple"><div><h2>Team members</h2><p>Roles are rechecked for every request.</p></div><Users /></div>
          <div className="team-list">{team.map((member) => <div key={member.id}><span className="avatar">{member.name.split(" ").map((part) => part[0]).join("")}</span><div className="team-name"><strong>{member.name}</strong><span>{member.phone}</span></div><div><span className="cell-label">Role</span><strong>{member.role}</strong></div><div><span className="cell-label">Locations</span><strong>{member.locations}</strong></div><StatusBadge tone="positive">{member.status}</StatusBadge><button className="icon-button bordered" aria-label={`Manage ${member.name}`}><UserCog /></button></div>)}</div>
        </article>
        <aside className="team-side">
          <article className="panel"><div className="panel-heading simple"><div><h2>Locations</h2><p>Writes always belong to one location.</p></div><Building2 /></div><div className="location-list">{bootstrap.locations.map((location) => <div key={location.id}><span><MapPin /></span><div><strong>{location.name}</strong><small>Code {location.code} · State {location.stateCode}</small></div><StatusBadge tone="positive">Active</StatusBadge></div>)}</div><button className="secondary-button full"><Plus />Add location</button></article>
          <article className="role-note"><ShieldCheck /><div><strong>Cashier privacy</strong><p>Cashiers cannot see costs, margins, supplier operations, exports or other locations.</p></div></article>
        </aside>
      </section>
    </>
  );
}
