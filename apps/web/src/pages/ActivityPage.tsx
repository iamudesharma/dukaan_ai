import { CheckCircle2, FileClock, LogIn, RotateCcw, ShieldAlert, Sparkles } from "lucide-react";
import { PageHeader } from "../components/PageHeader";
import { StatusBadge } from "../components/StatusBadge";

const events = [
  { id: "1", icon: CheckCircle2, title: "Sale KB/26-27/001042 posted", detail: "Meena Textiles · ₹1,860 · Karol Bagh", actor: "Neha Verma", time: "10:42 AM", source: "Manual" },
  { id: "2", icon: Sparkles, title: "Assistant proposal confirmed", detail: "Ramesh Kumar · 3 shirts · ₹2,400", actor: "Amit Sharma", time: "10:31 AM", source: "AI assisted" },
  { id: "3", icon: RotateCcw, title: "Payment reversal completed", detail: "Reason: duplicate cash receipt", actor: "Neha Verma", time: "Yesterday, 6:18 PM", source: "Manual" },
  { id: "4", icon: LogIn, title: "New sign-in", detail: "Android device · Delhi, India", actor: "Vijay Singh", time: "Yesterday, 9:02 AM", source: "Security" },
];

export function ActivityPage() {
  return (
    <>
      <PageHeader eyebrow="Immutable audit trail" title="Activity" description="Important actions, reversals, sign-ins and permission changes are recorded with their source and actor." />
      <section className="panel activity-panel">
        <div className="activity-filter"><button className="active">All activity</button><button>Transactions</button><button>Team & security</button><button>Assistant</button></div>
        <div className="activity-list">{events.map(({ id, icon: Icon, title, detail, actor, time, source }) => <article key={id}><span className="activity-icon"><Icon /></span><div><h3>{title}</h3><p>{detail}</p><span>{actor}</span></div><div><StatusBadge tone={source === "Security" ? "warning" : "neutral"}>{source}</StatusBadge><time>{time}</time></div></article>)}</div>
        <div className="audit-note"><ShieldAlert /><p>Audit events are append-only. Posted financial and stock records are corrected with linked reversals rather than silent edits.</p></div>
      </section>
    </>
  );
}
