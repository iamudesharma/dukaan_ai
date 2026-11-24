import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import {
  CheckCircle2,
  FileClock,
  RotateCcw,
  ShieldAlert,
  Sparkles,
  type LucideIcon,
} from "lucide-react";
import { useWorkspace } from "../app/WorkspaceContext";
import { EmptyState } from "../components/EmptyState";
import { LoadingBlock } from "../components/LoadingBlock";
import { PageHeader } from "../components/PageHeader";
import { StatusBadge } from "../components/StatusBadge";
import { listActivity } from "../data/repository";
import { formatDateTime } from "../lib/format";
import type { ActivityEvent } from "../types";

const iconFor = (eventType: string): LucideIcon => {
  if (eventType.includes("revers")) return RotateCcw;
  if (eventType.startsWith("assistant")) return Sparkles;
  if (eventType.includes("posted") || eventType.includes("recorded")) return CheckCircle2;
  return FileClock;
};

const SOURCE_LABELS: Record<string, string> = {
  API: "Manual",
  ASSISTANT: "AI assisted",
  SYSTEM: "System",
};

const filters: Array<{ label: string; match: (event: ActivityEvent) => boolean }> = [
  { label: "All activity", match: () => true },
  { label: "Transactions", match: (event) => event.aggregateType !== "AssistantProposal" },
  { label: "Assistant", match: (event) => event.aggregateType === "AssistantProposal" },
];

export function ActivityPage() {
  const { bootstrap, locationId } = useWorkspace();
  const [filter, setFilter] = useState(filters[0].label);
  const activity = useQuery({
    queryKey: ["activity", bootstrap.business.id, locationId],
    queryFn: () => listActivity(bootstrap.business.id, locationId),
  });

  if (activity.isLoading) return <LoadingBlock />;

  const events = (activity.data ?? []).filter(
    filters.find((candidate) => candidate.label === filter)?.match ?? (() => true),
  );

  return (
    <>
      <PageHeader eyebrow="01 · Immutable audit trail" title="Activity" description="Important actions, reversals, sign-ins and permission changes are recorded with their source and actor." />
      <section className="panel activity-panel">
        <div className="activity-filter">
          {filters.map((candidate) => (
            <button
              key={candidate.label}
              className={candidate.label === filter ? "active" : undefined}
              onClick={() => setFilter(candidate.label)}
            >
              {candidate.label}
            </button>
          ))}
        </div>
        {activity.error ? (
          <EmptyState title="Activity unavailable" detail="We couldn’t load the audit trail. Check your connection and try again." />
        ) : events.length ? (
          <div className="activity-list">
            {events.map((event) => {
              const Icon = iconFor(event.eventType);
              const source = SOURCE_LABELS[event.source] ?? event.source;
              return (
                <article key={event.id}>
                  <span className="activity-icon"><Icon /></span>
                  <div>
                    <h3>{event.eventType.replace(/[._]/g, " ")}</h3>
                    <p>{event.aggregateType} · {event.aggregateId.slice(0, 8)}</p>
                    <span>{event.actorName ?? "System"}</span>
                  </div>
                  <div>
                    <StatusBadge tone={event.source === "ASSISTANT" ? "warning" : "neutral"}>{source}</StatusBadge>
                    <time>{formatDateTime(event.createdAt)}</time>
                  </div>
                </article>
              );
            })}
          </div>
        ) : (
          <EmptyState title="No activity yet" detail="Posted entries, reversals and assistant confirmations will appear here." />
        )}
        <div className="audit-note"><ShieldAlert /><p>Audit events are append-only. Posted financial and stock records are corrected with linked reversals rather than silent edits.</p></div>
      </section>
    </>
  );
}
