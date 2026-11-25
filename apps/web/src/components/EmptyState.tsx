import { Inbox } from "lucide-react";

export function EmptyState({ title, detail, kicker = "Nothing here yet" }: { title: string; detail: string; kicker?: string }) {
  return (
    <div className="empty-state">
      <Inbox aria-hidden="true" />
      <p className="folio-kicker">{kicker}</p>
      <h3>{title}</h3>
      <p>{detail}</p>
    </div>
  );
}
