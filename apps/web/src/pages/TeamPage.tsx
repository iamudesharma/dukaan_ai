import { useState, type FormEvent } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Building2, MapPin, Plus, ShieldCheck, UserCog, Users } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { PageHeader } from "../components/PageHeader";
import { StatusBadge } from "../components/StatusBadge";
import { LoadingBlock } from "../components/LoadingBlock";
import { createLocation, createMembership, deleteMembership, listMemberships } from "../data/repository";
import type { Role } from "../types";

export function TeamPage() {
  const { bootstrap } = useWorkspace();
  const [inviting, setInviting] = useState(false);
  const [addingLocation, setAddingLocation] = useState(false);
  const [userId, setUserId] = useState("");
  const [role, setRole] = useState<Role>("CASHIER");
  const [locationName, setLocationName] = useState("");
  const [locationCode, setLocationCode] = useState("");
  const queryClient = useQueryClient();

  const members = useQuery({
    queryKey: ["memberships", bootstrap.business.id],
    queryFn: () => listMemberships(bootstrap.business.id),
  });

  const invite = useMutation({
    mutationFn: () => createMembership({ business: bootstrap.business.id, user: userId, role }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["memberships"] });
      setInviting(false);
      setUserId("");
    },
  });

  const remove = useMutation({
    mutationFn: (id: string) => deleteMembership(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["memberships"] }),
  });

  const addLocation = useMutation({
    mutationFn: () => createLocation({ business: bootstrap.business.id, name: locationName, code: locationCode }),
    onSuccess: async () => {
      await queryClient.invalidateQueries();
      setAddingLocation(false);
      setLocationName("");
      setLocationCode("");
    },
  });

  function submitInvite(event: FormEvent) {
    event.preventDefault();
    if (userId.trim()) invite.mutate();
  }

  function submitLocation(event: FormEvent) {
    event.preventDefault();
    if (locationName.trim() && locationCode.trim()) addLocation.mutate();
  }

  return (
    <>
      <PageHeader eyebrow="Access control" title="Team & locations" description="Invite each person with their own phone number. Access can be revoked without waiting for a token to expire." actions={<button className="primary-button" onClick={() => setInviting(true)}><Plus />Invite member</button>} />
      {inviting ? (
        <section className="panel" role="dialog" aria-label="Invite member">
          <form className="manual-form" onSubmit={submitInvite}>
            <div className="two-fields">
              <label>User ID (phone user)<input value={userId} onChange={(e) => setUserId(e.target.value)} required placeholder="User UUID" /></label>
              <label>Role<select value={role} onChange={(e) => setRole(e.target.value as Role)}><option value="OWNER">Owner</option><option value="MANAGER">Manager</option><option value="CASHIER">Cashier</option></select></label>
            </div>
            <div className="review-actions">
              <button type="button" className="secondary-button" onClick={() => setInviting(false)}>Cancel</button>
              <button className="primary-button" disabled={invite.isPending}>{invite.isPending ? "Inviting…" : "Invite"}</button>
            </div>
            {invite.error ? <p className="form-error" role="alert">{invite.error.message}</p> : null}
          </form>
        </section>
      ) : null}
      <section className="team-layout">
        <article className="panel data-panel">
          <div className="panel-heading simple"><div><h2>Team members</h2><p>Roles are rechecked for every request.</p></div><Users /></div>
          {members.isLoading ? <LoadingBlock /> : (members.data ?? []).length ? (
            <div className="team-list">{members.data!.map((member) => (
              <div key={member.id}>
                <span className="avatar">{member.role.slice(0, 1)}</span>
                <div className="team-name"><strong>{member.user}</strong><span>{member.id}</span></div>
                <div><span className="cell-label">Role</span><strong>{member.role}</strong></div>
                <div><span className="cell-label">Locations</span><strong>{member.locations.length ? member.locations.join(", ") : "All"}</strong></div>
                <button className="icon-button bordered" aria-label={`Revoke ${member.user}`} onClick={() => remove.mutate(member.id)}><UserCog /></button>
              </div>
            ))}</div>
          ) : <p>No team members yet — invite by user ID.</p>}
        </article>
        <aside className="team-side">
          <article className="panel"><div className="panel-heading simple"><div><h2>Locations</h2><p>Writes always belong to one location.</p></div><Building2 /></div><div className="location-list">{bootstrap.locations.map((location) => <div key={location.id}><span><MapPin /></span><div><strong>{location.name}</strong><small>Code {location.code} · State {location.stateCode}</small></div><StatusBadge tone="positive">Active</StatusBadge></div>)}</div>
            {addingLocation ? (
              <form className="manual-form" onSubmit={submitLocation}>
                <div className="two-fields">
                  <label>Name<input value={locationName} onChange={(e) => setLocationName(e.target.value)} required /></label>
                  <label>Code<input value={locationCode} onChange={(e) => setLocationCode(e.target.value)} required /></label>
                </div>
                <div className="review-actions">
                  <button type="button" className="secondary-button" onClick={() => setAddingLocation(false)}>Cancel</button>
                  <button className="primary-button" disabled={addLocation.isPending}>{addLocation.isPending ? "Saving…" : "Save"}</button>
                </div>
                {addLocation.error ? <p className="form-error" role="alert">{addLocation.error.message}</p> : null}
              </form>
            ) : <button className="secondary-button full" onClick={() => setAddingLocation(true)}><Plus />Add location</button>}
          </article>
          <article className="role-note"><ShieldCheck /><div><strong>Cashier privacy</strong><p>Cashiers cannot see costs, margins, supplier operations, exports or other locations.</p></div></article>
        </aside>
      </section>
    </>
  );
}
