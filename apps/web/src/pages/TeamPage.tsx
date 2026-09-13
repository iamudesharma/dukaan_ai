import { useState, type FormEvent } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Building2, MapPin, Plus, ShieldCheck, UserCog, Users } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { PageHeader } from "../components/PageHeader";
import { StatusBadge } from "../components/StatusBadge";
import { LoadingBlock } from "../components/LoadingBlock";
import {
  createInvitation,
  createLocation,
  listInvitations,
  listMemberships,
  revokeInvitation,
  revokeMembership,
  updateMembership,
} from "../data/repository";
import type { Role } from "../types";

export function TeamPage() {
  const { bootstrap } = useWorkspace();
  const [inviting, setInviting] = useState(false);
  const [addingLocation, setAddingLocation] = useState(false);
  const [phone, setPhone] = useState("");
  const [role, setRole] = useState<Role>("CASHIER");
  const [inviteLocations, setInviteLocations] = useState<string[]>([]);
  const [inviteToken, setInviteToken] = useState<string | null>(null);
  const [locationName, setLocationName] = useState("");
  const [locationCode, setLocationCode] = useState("");
  const queryClient = useQueryClient();

  const members = useQuery({
    queryKey: ["memberships", bootstrap.business.id],
    queryFn: () => listMemberships(bootstrap.business.id),
  });
  const invitations = useQuery({
    queryKey: ["invitations", bootstrap.business.id],
    queryFn: () => listInvitations(bootstrap.business.id, "PENDING"),
  });

  const invite = useMutation({
    mutationFn: () =>
      createInvitation({
        business: bootstrap.business.id,
        phoneE164: phone.replace(/[\s()-]/g, ""),
        role,
        locations: inviteLocations,
      }),
    onSuccess: async (invitation) => {
      await queryClient.invalidateQueries({ queryKey: ["invitations"] });
      setInviteToken(invitation.token ?? null);
      setPhone("");
      setInviteLocations([]);
    },
  });

  const remove = useMutation({
    mutationFn: (id: string) => revokeMembership(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["memberships"] }),
  });

  const changeRole = useMutation({
    mutationFn: ({ id, next }: { id: string; next: Role }) =>
      updateMembership(id, { role: next }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["memberships"] }),
  });

  const cancelInvite = useMutation({
    mutationFn: (id: string) => revokeInvitation(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["invitations"] }),
  });

  const addLocation = useMutation({
    mutationFn: () =>
      createLocation({ business: bootstrap.business.id, name: locationName, code: locationCode }),
    onSuccess: async () => {
      await queryClient.invalidateQueries();
      setAddingLocation(false);
      setLocationName("");
      setLocationCode("");
    },
  });

  function submitInvite(event: FormEvent) {
    event.preventDefault();
    if (phone.trim()) invite.mutate();
  }

  function submitLocation(event: FormEvent) {
    event.preventDefault();
    if (locationName.trim() && locationCode.trim()) addLocation.mutate();
  }

  function toggleInviteLocation(id: string) {
    setInviteLocations((current) =>
      current.includes(id) ? current.filter((item) => item !== id) : [...current, id],
    );
  }

  return (
    <>
      <PageHeader eyebrow="Access control" title="Team & locations" description="Invite each person with their own phone number. They join after signing in with that number. Access can be revoked without waiting for a token to expire." actions={<button className="primary-button" onClick={() => { setInviting(true); setInviteToken(null); invite.reset(); }}><Plus />Invite member</button>} />
      {inviting ? (
        <section className="panel" role="dialog" aria-label="Invite member">
          <form className="manual-form" onSubmit={submitInvite}>
            <div className="two-fields">
              <label>Phone number<input value={phone} onChange={(e) => setPhone(e.target.value)} required placeholder="+91 98765 43210" inputMode="tel" /></label>
              <label>Role<select value={role} onChange={(e) => setRole(e.target.value as Role)}><option value="MANAGER">Manager</option><option value="CASHIER">Cashier</option></select></label>
            </div>
            <fieldset>
              <legend>Locations this member can use (owners always see everything)</legend>
              <div className="choice-row">
                {bootstrap.locations.map((location) => (
                  <label key={location.id}>
                    <input
                      type="checkbox"
                      checked={inviteLocations.includes(location.id)}
                      onChange={() => toggleInviteLocation(location.id)}
                    />
                    {location.name}
                  </label>
                ))}
              </div>
            </fieldset>
            <div className="review-actions">
              <button type="button" className="secondary-button" onClick={() => setInviting(false)}>Cancel</button>
              <button className="primary-button" disabled={invite.isPending}>{invite.isPending ? "Inviting…" : "Send invite"}</button>
            </div>
            {invite.error ? <p className="form-error" role="alert">{invite.error.message}</p> : null}
            {inviteToken ? (
              <p role="status" className="invite-token">
                Share this one-time accept link with the new member: <code>{inviteToken}</code>
              </p>
            ) : null}
          </form>
        </section>
      ) : null}
      <section className="team-layout">
        <article className="panel data-panel">
          <div className="panel-heading simple"><div><h2>Team members</h2><p>Roles are rechecked for every request.</p></div><Users /></div>
          {members.isLoading ? <LoadingBlock /> : (members.data ?? []).length ? (
            <div className="team-list">{members.data!.map((member) => (
              <div key={member.id}>
                <span className="avatar">{(member.userName ?? member.userPhone ?? member.role).slice(0, 1).toUpperCase()}</span>
                <div className="team-name">
                  <strong>{member.userName || member.userPhone || "Member"}</strong>
                  <span>{member.userPhone ?? member.user}</span>
                </div>
                <div>
                  <span className="cell-label">Role</span>
                  <select
                    aria-label={`Role for ${member.userName ?? member.userPhone ?? "member"}`}
                    value={member.role}
                    disabled={member.role === "OWNER" || changeRole.isPending}
                    onChange={(event) => changeRole.mutate({ id: member.id, next: event.target.value as Role })}
                  >
                    <option value="OWNER">Owner</option>
                    <option value="MANAGER">Manager</option>
                    <option value="CASHIER">Cashier</option>
                  </select>
                </div>
                <div><span className="cell-label">Locations</span><strong>{member.locations.length ? member.locations.join(", ") : "All"}</strong></div>
                {member.role === "OWNER" ? null : (
                  <button className="icon-button bordered" aria-label={`Revoke ${member.userName ?? member.userPhone ?? "member"}`} title="Revoke access and sign them out" onClick={() => { if (window.confirm("Revoke this member's access and sign them out?")) remove.mutate(member.id); }}><UserCog /></button>
                )}
              </div>
            ))}</div>
          ) : <p>No team members yet — send an invite by phone number.</p>}
        </article>
        <aside className="team-side">
          <article className="panel">
            <div className="panel-heading simple"><div><h2>Pending invites</h2><p>Expire after 7 days.</p></div></div>
            {invitations.isLoading ? <LoadingBlock /> : (invitations.data ?? []).length ? (
              <ul>
                {invitations.data!.map((invitation) => (
                  <li key={invitation.id}>
                    <div><strong>{invitation.phoneE164}</strong><small>{invitation.role.toLowerCase()} · expires {invitation.expiresAt.slice(0, 10)}</small></div>
                    <button type="button" className="text-button" onClick={() => cancelInvite.mutate(invitation.id)}>Revoke</button>
                  </li>
                ))}
              </ul>
            ) : <p>No pending invites.</p>}
          </article>
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
