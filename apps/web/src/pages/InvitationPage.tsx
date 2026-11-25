import { useQueryClient } from "@tanstack/react-query";
import { PageHeader } from "../components/PageHeader";
import { InvitationAcceptPanel } from "../features/invitations/InvitationAcceptPanel";

export function InvitationPage() {
  const queryClient = useQueryClient();
  return (
    <>
      <PageHeader eyebrow="01 · Join a workspace" title="Accept invitation" description="Use a one-time token from a shop owner to add this business to your account." />
      <InvitationAcceptPanel onAccepted={async () => { await Promise.all([queryClient.invalidateQueries({ queryKey: ["me"] }), queryClient.invalidateQueries({ queryKey: ["bootstrap"] })]); }} />
    </>
  );
}
