import { useRef, useState, type FormEvent } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Ban, Building2, Check, Copy, Link2, MapPin, Plus, ShieldCheck, UserCog, Users, X } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { PageHeader } from "../components/PageHeader";
import { StatusBadge } from "../components/StatusBadge";
import { LoadingBlock } from "../components/LoadingBlock";
import {
  createInvitation,
  createLocation,
  createMembership,
  deleteMembership,
  listInvitations,
  listMemberships,
  revokeInvitation,
} from "../data/repository";
import { formatDateTime } from "../lib/format";
import type { Invitation, InvitationCreateResult, Role } from "../types";
import { NotFoundPage } from "./NotFoundPage";

function invitationTone(status: Invitation["status"]): "positive" | "warning" | "danger" | "neutral" {
  if (status === "ACCEPTED") return "positive";
  if (status === "PENDING") return "warning";
  if (status === "REVOKED") return "danger";
  return "neutral";
}

export function TeamPage() {
  const { bootstrap, access } = useWorkspace();
  const [inviting, setInviting] = useState(false);
  const [addingExisting, setAddingExisting] = useState(false);
  const [addingLocation, setAddingLocation] = useState(false);
  const [inviteePhone, setInviteePhone] = useState("");
  const [inviteRole, setInviteRole] = useState<Role>("CASHIER");
  const [selectedLocations, setSelectedLocations] = useState<string[]>(() => bootstrap.locations.map((location) => location.id));
  const [issued, setIssued] = useState<InvitationCreateResult | null>(null);
  const [copied, setCopied] = useState(false);
  const [tokenError, setTokenError] = useState<string | null>(null);
  const tokenInput = useRef<HTMLInputElement>(null);
  const [userId, setUserId] = useState("");
  const [role, setRole] = useState<Role>("CASHIER");
  const [locationName, setLocationName] = useState("");
  const [locationCode, setLocationCode] = useState("");
  const [revokingId, setRevokingId] = useState<string | null>(null);
  const queryClient = useQueryClient();

  const members = useQuery({
    queryKey: ["memberships", bootstrap.user.id, bootstrap.business.id],
    queryFn: () => listMemberships(bootstrap.business.id),
    enabled: access.canManageTeam,
  });
  const invitations = useQuery({
    queryKey: ["invitations", bootstrap.user.id, bootstrap.business.id],
    queryFn: () => listInvitations(bootstrap.business.id),
    enabled: access.isOwner,
  });

  const invite = useMutation({
    mutationFn: () => {
      if (!access.isOwner) throw new Error("Only the owner can invite team members.");
      if (inviteRole !== "OWNER" && selectedLocations.length === 0) {
        throw new Error("Select at least one location for a manager or cashier.");
      }
      return createInvitation({
        business: bootstrap.business.id,
        inviteePhone,
        role: inviteRole,
        locations: selectedLocations,
      });
    },
    onSuccess: (result) => {
      setIssued(result);
      setCopied(false);
      setTokenError(null);
      setInviteePhone("");
      void queryClient.invalidateQueries({ queryKey: ["invitations"] });
    },
  });

  const revoke = useMutation({
    mutationFn: (id: string) => {
      if (!access.isOwner) throw new Error("Only the owner can revoke invitations.");
      return revokeInvitation(id);
    },
    onMutate: (id) => setRevokingId(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["invitations"] }),
    onSettled: () => setRevokingId(null),
  });

  const addExisting = useMutation({
    mutationFn: () => createMembership({ business: bootstrap.business.id, user: userId, role }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["memberships"] });
      setAddingExisting(false);
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

  function submitInvitation(event: FormEvent) {
    event.preventDefault();
    if (inviteePhone.trim()) invite.mutate();
  }

  function submitExisting(event: FormEvent) {
    event.preventDefault();
    if (userId.trim()) addExisting.mutate();
  }

  function submitLocation(event: FormEvent) {
    event.preventDefault();
    if (locationName.trim() && locationCode.trim()) addLocation.mutate();
  }

  function closeInvitation() {
    if (invite.isPending) return;
    setInviting(false);
    invite.reset();
    setIssued(null);
    setCopied(false);
    setTokenError(null);
    setSelectedLocations(bootstrap.locations.map((location) => location.id));
  }

  async function copyToken() {
    if (!issued) return;
    try {
      await navigator.clipboard.writeText(issued.token);
      setCopied(true);
      setTokenError(null);
    } catch {
      tokenInput.current?.focus();
      tokenInput.current?.select();
      setTokenError("Automatic copy failed. The token is selected so you can copy it manually.");
    }
  }

  if (!access.canManageTeam || !access.isOwner) return <NotFoundPage />;

  return (
    <>
      <PageHeader
        eyebrow="01 · Access control"
        title="Team & locations"
        description="Invite people with their phone number, choose their role and locations, and revoke access when needed."
        actions={<button className="primary-button" onClick={() => setInviting(true)}><Plus />Invite member</button>}
      />
      {inviting ? (
        <section className="panel invitation-panel" aria-label="Invite member">
          {issued ? (
            <div className="issued-invitation">
              <div className="panel-heading simple"><div><Link2 aria-hidden="true" /><h2>Copy the one-time invitation token</h2><p>This token is shown only once and is not stored in the browser. Send it privately to {issued.inviteePhone}.</p></div><StatusBadge tone="warning">Shown once</StatusBadge></div>
              <label>One-time invitation token<input ref={tokenInput} type="text" readOnly autoComplete="off" spellCheck={false} value={issued.token} onFocus={(event) => event.currentTarget.select()} /></label>
              <p className="field-note">The invitee must sign in with the matching mobile number before accepting. The invitation expires {formatDateTime(issued.expiresAt)}.</p>
              {tokenError ? <p className="form-error" role="alert">{tokenError}</p> : null}
              <div className="review-actions"><button type="button" className="secondary-button" onClick={closeInvitation}>Done</button><button type="button" className="primary-button" onClick={() => void copyToken()}>{copied ? <Check /> : <Copy />}{copied ? "Token copied" : "Copy token"}</button></div>
            </div>
          ) : (
            <form className="manual-form" onSubmit={submitInvitation}>
              <div className="panel-heading simple"><div><p className="folio-kicker">Phone-matched access</p><h2>Invite a team member</h2><p>The backend accepts the token only for the signed-in user whose verified phone matches this invitation.</p></div><button type="button" className="icon-button" aria-label="Close invitation" disabled={invite.isPending} onClick={closeInvitation}><X /></button></div>
              <div className="two-fields">
                <label>Mobile number with country code<input value={inviteePhone} onChange={(event) => setInviteePhone(event.target.value)} inputMode="tel" autoComplete="tel" placeholder="+919876543210" required /></label>
                <label>Role<select value={inviteRole} onChange={(event) => setInviteRole(event.target.value as Role)}><option value="CASHIER">Cashier</option><option value="MANAGER">Manager</option><option value="OWNER">Owner</option></select></label>
              </div>
              <fieldset className="location-options"><legend>Location access</legend><p>Owners can access every active location. Managers and cashiers need at least one selected location.</p><div>{bootstrap.locations.map((location) => <label key={location.id}><input type="checkbox" checked={selectedLocations.includes(location.id)} onChange={(event) => setSelectedLocations((current) => event.target.checked ? [...current, location.id] : current.filter((id) => id !== location.id))} /><span><strong>{location.name}</strong><small>{location.code}</small></span></label>)}</div></fieldset>
              <p className="field-note">The invitation expires in 7 days unless the server configuration says otherwise.</p>
              {invite.error ? <p className="form-error" role="alert">{invite.error.message}</p> : null}
              <div className="review-actions"><button type="button" className="secondary-button" disabled={invite.isPending} onClick={closeInvitation}>Cancel</button><button type="submit" className="primary-button" disabled={invite.isPending || !inviteePhone.trim()}>{invite.isPending ? "Creating…" : "Create invitation"}</button></div>
            </form>
          )}
        </section>
      ) : null}
      <div className="team-layout">
        <div className="team-main">
          <article className="panel register-section data-panel">
            <div className="panel-heading simple"><div><p className="folio-kicker">02 · Roster</p><h2>Team members</h2><p>Roles are rechecked for every request.</p></div><Users /></div>
            {members.isLoading ? <LoadingBlock /> : members.error ? <p className="form-error" role="alert">{members.error.message}</p> : (members.data ?? []).length ? (
              <div className="team-list">{members.data!.map((member) => (
                <div key={member.id}>
                  <span className="avatar">{member.role.slice(0, 1)}</span>
                  <div className="team-name"><strong>{member.user}</strong><span>{member.id}</span></div>
                  <div><span className="cell-label">Role</span><strong>{member.role}</strong></div>
                  <div><span className="cell-label">Locations</span><strong>{member.locations.length ? member.locations.join(", ") : member.role === "OWNER" ? "All" : "None"}</strong></div>
                  <button className="icon-button bordered" aria-label={`Revoke ${member.user}`} onClick={() => remove.mutate(member.id)}><UserCog /></button>
                </div>
              ))}</div>
            ) : <p>No team members yet.</p>}
            <details className="existing-user-form" open={addingExisting} onToggle={(event) => setAddingExisting(event.currentTarget.open)}><summary>Add an existing user by ID</summary>{addingExisting ? <form className="manual-form" onSubmit={submitExisting}><div className="two-fields"><label>User ID<input value={userId} onChange={(event) => setUserId(event.target.value)} required placeholder="User UUID" /></label><label>Role<select value={role} onChange={(event) => setRole(event.target.value as Role)}><option value="OWNER">Owner</option><option value="MANAGER">Manager</option><option value="CASHIER">Cashier</option></select></label></div>{addExisting.error ? <p className="form-error" role="alert">{addExisting.error.message}</p> : null}<div className="review-actions"><button type="button" className="secondary-button" onClick={() => setAddingExisting(false)}>Cancel</button><button className="primary-button" disabled={addExisting.isPending}>{addExisting.isPending ? "Adding…" : "Add user"}</button></div></form> : null}</details>
          </article>
          <article className="panel register-section data-panel">
            <div className="panel-heading simple"><div><p className="folio-kicker">03 · Invitations</p><h2>Pending and past invitations</h2><p>Tokens are never included in this list. Revoke pending invitations here.</p></div><Link2 /></div>
            {invitations.isLoading ? <LoadingBlock /> : invitations.error ? <p className="form-error" role="alert">{invitations.error.message}</p> : invitations.data?.length ? (
              <div className="table-scroll"><table><thead><tr><th>Invitee</th><th>Role</th><th>Locations</th><th>Expires</th><th>Status</th><th><span className="sr-only">Actions</span></th></tr></thead><tbody>{invitations.data.map((item) => <tr key={item.id}><td><strong>{item.inviteePhone}</strong><small>{item.id}</small></td><td>{item.role}</td><td>{item.role === "OWNER" ? "All" : item.locations.length ? item.locations.map((id) => bootstrap.locations.find((location) => location.id === id)?.name ?? id).join(", ") : "None"}</td><td>{formatDateTime(item.expiresAt)}</td><td><StatusBadge tone={invitationTone(item.status)}>{item.status}</StatusBadge></td><td>{item.status === "PENDING" ? <button type="button" className="text-button" disabled={revokingId === item.id} onClick={() => { if (window.confirm("Revoke this invitation? Its token will stop working.")) revoke.mutate(item.id); }}><Ban />{revokingId === item.id ? "Revoking…" : "Revoke"}</button> : null}</td></tr>)}</tbody></table></div>
            ) : <p>No invitations yet. Create one to share secure access.</p>}
            {revoke.error ? <p className="form-error" role="alert">{revoke.error.message}</p> : null}
          </article>
        </div>
        <aside className="team-side">
          <article className="panel"><div className="panel-heading simple"><div><p className="folio-kicker">04 · Places</p><h2>Locations</h2><p>Writes always belong to one location.</p></div><Building2 /></div><div className="location-list">{bootstrap.locations.map((location) => <div key={location.id}><span><MapPin /></span><div><strong>{location.name}</strong><small>Code {location.code} · State {location.stateCode}</small></div><StatusBadge tone="positive">Active</StatusBadge></div>)}</div>
            {addingLocation ? (
              <form className="manual-form" onSubmit={submitLocation}>
                <div className="two-fields"><label>Name<input value={locationName} onChange={(event) => setLocationName(event.target.value)} required /></label><label>Code<input value={locationCode} onChange={(event) => setLocationCode(event.target.value)} required /></label></div>
                <div className="review-actions"><button type="button" className="secondary-button" onClick={() => setAddingLocation(false)}>Cancel</button><button className="primary-button" disabled={addLocation.isPending}>{addLocation.isPending ? "Saving…" : "Save"}</button></div>
                {addLocation.error ? <p className="form-error" role="alert">{addLocation.error.message}</p> : null}
              </form>
            ) : <button className="secondary-button full" onClick={() => setAddingLocation(true)}><Plus />Add location</button>}
          </article>
          <article className="role-note"><ShieldCheck /><div><strong>Cashier privacy</strong><p>Cashiers cannot see costs, margins, supplier operations, exports or other locations.</p></div></article>
        </aside>
      </div>
    </>
  );
}
