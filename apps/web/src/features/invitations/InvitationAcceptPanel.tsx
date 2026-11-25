import { useState, type FormEvent } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { CheckCircle2, Link2, LoaderCircle } from "lucide-react";
import { acceptInvitation } from "../../data/repository";

interface Props {
  onAccepted?: () => void | Promise<unknown>;
  compact?: boolean;
}

export function InvitationAcceptPanel({ onAccepted, compact = false }: Props) {
  const queryClient = useQueryClient();
  const [token, setToken] = useState("");
  const [message, setMessage] = useState<string | null>(null);
  const accept = useMutation({
    mutationFn: () => acceptInvitation(token.trim()),
    onSuccess: (invitation) => {
      setToken("");
      setMessage(`Invitation accepted. You now have ${invitation.role.toLowerCase()} access to the business.`);
      void Promise.resolve(onAccepted?.()).catch(() => undefined);
      void queryClient.invalidateQueries({ queryKey: ["me"] });
      void queryClient.invalidateQueries({ queryKey: ["bootstrap"] });
      accept.reset();
    },
  });

  function submit(event: FormEvent) {
    event.preventDefault();
    setMessage(null);
    if (token.trim()) accept.mutate();
  }

  return (
    <section className={compact ? "invitation-accept compact" : "panel invitation-accept"} aria-labelledby="accept-invitation-title">
      <div className="panel-heading simple"><div><Link2 aria-hidden="true" /><h2 id="accept-invitation-title">Accept a team invitation</h2><p>Paste the one-time token from your shop owner.</p></div></div>
      <form className="manual-form" onSubmit={submit}>
        <label>Invitation token<input type="text" inputMode="text" autoComplete="off" spellCheck={false} value={token} onChange={(event) => { setToken(event.target.value); setMessage(null); }} placeholder="Paste the one-time token" minLength={20} maxLength={128} required /></label>
        <p className="field-note">Sign in with the mobile number the owner invited. The backend checks that verified phone against the invitation; a token alone cannot change access.</p>
        {accept.error ? <p className="form-error" role="alert">{accept.error.message}</p> : null}
        {message ? <p className="invitation-success" role="status"><CheckCircle2 aria-hidden="true" />{message}</p> : null}
        <div className="review-actions"><button type="submit" className="primary-button" disabled={accept.isPending || token.trim().length < 20}>{accept.isPending ? <LoaderCircle className="spin" /> : <CheckCircle2 />}{accept.isPending ? "Accepting…" : "Accept invitation"}</button></div>
      </form>
    </section>
  );
}
