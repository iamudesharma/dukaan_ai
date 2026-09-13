import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { CheckCircle2, FileClock, RotateCcw, ShieldAlert, Sparkles } from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { EmptyState } from "../components/EmptyState";
import { LoadingBlock } from "../components/LoadingBlock";
import { PageHeader } from "../components/PageHeader";
import { StatusBadge } from "../components/StatusBadge";
import { listActivity } from "../data/repository";
import { formatMoney } from "../lib/format";

const filters = [
  { value: "all", label: "All activity" },
  { value: "transactions", label: "Transactions" },
  { value: "team", label: "Team & security" },
  { value: "assistant", label: "Assistant" },
] as const;

type Filter = (typeof filters)[number]["value"];

function iconFor(eventType: string) {
  if (eventType.includes("revers")) return RotateCcw;
  if (eventType.startsWith("assistant")) return Sparkles;
  if (eventType.startsWith("membership") || eventType.startsWith("invitation") || eventType.startsWith("auth")) {
    return ShieldAlert;
  }
  if (eventType.startsWith("sale") || eventType.startsWith("purchase") || eventType.startsWith("payment")) {
    return CheckCircle2;
  }
  return FileClock;
}

function titleFor(eventType: string, metadata: Record<string, unknown>): string {
  const number = metadata.number ?? metadata.reference;
  const party = metadata.customer_name ?? metadata.supplier_name ?? metadata.party_name;
  const amount = metadata.grand_total_minor ?? metadata.amount_minor ?? metadata.total_minor;
  const parts = [eventType.replaceAll(".", " ").replaceAll("_", " ")];
  if (number) parts.push(String(number));
  if (party) parts.push(`· ${String(party)}`);
  if (typeof amount === "number") parts.push(`· ${formatMoney(amount)}`);
  return parts.join(" ");
}

export function ActivityPage() {
  const { bootstrap } = useWorkspace();
  const [kind, setKind] = useState<Filter>("all");
  const activity = useQuery({
    queryKey: ["activity", bootstrap.business.id, kind],
    queryFn: () => listActivity(bootstrap.business.id, { kind }),
  });

  return (
    <>
      <PageHeader eyebrow="Immutable audit trail" title="Activity" description="Important actions, reversals, sign-ins and permission changes are recorded with their source and actor." />
      <section className="panel activity-panel">
        <div className="activity-filter" role="tablist" aria-label="Activity filters">
          {filters.map((filter) => (
            <button
              key={filter.value}
              role="tab"
              aria-selected={kind === filter.value}
              className={kind === filter.value ? "active" : ""}
              onClick={() => setKind(filter.value)}
            >
              {filter.label}
            </button>
          ))}
        </div>
        {activity.isLoading ? (
          <LoadingBlock label="Loading activity…" />
        ) : activity.error ? (
          <EmptyState title="Activity could not be loaded" detail={activity.error.message} />
        ) : (activity.data?.results ?? []).length ? (
          <div className="activity-list">
            {activity.data!.results.map((event) => {
              const Icon = iconFor(event.eventType);
              const time = event.createdAt ? new Date(event.createdAt).toLocaleString("en-IN", { day: "numeric", month: "short", hour: "numeric", minute: "2-digit" }) : "";
              return (
                <article key={event.id}>
                  <span className="activity-icon"><Icon /></span>
                  <div>
                    <h3>{titleFor(event.eventType, event.metadata)}</h3>
                    <p>{event.aggregateType}</p>
                    <span>{event.actorName ?? "System"}</span>
                  </div>
                  <div>
                    <StatusBadge tone={event.source === "ASSISTANT" ? "neutral" : "neutral"}>{event.source}</StatusBadge>
                    <time>{time}</time>
                  </div>
                </article>
              );
            })}
          </div>
        ) : (
          <EmptyState title="No activity yet" detail="Post a sale or invite a team member and it will appear here." />
        )}
        <div className="audit-note"><ShieldAlert /><p>Audit events are append-only. Posted financial and stock records are corrected with linked reversals rather than silent edits.</p></div>
      </section>
    </>
  );
}
