import type { LucideIcon } from "lucide-react";
import { formatMoney } from "../lib/format";

type Tone = "neutral" | "primary" | "positive" | "attention" | "danger";

interface Props {
  label: string;
  valueMinor?: number;
  value?: string;
  hint: string;
  icon: LucideIcon;
  tone?: Tone;
}

export function MetricCard({ label, valueMinor, value, hint, icon: Icon, tone = "neutral" }: Props) {
  return (
    <article className={`metric-card ${tone}`}>
      <Icon className="metric-icon" aria-hidden="true" />
      <div>
        <p className="metric-label">{label}</p>
        <strong>{value ?? formatMoney(valueMinor ?? 0)}</strong>
        <p className="metric-hint">{hint}</p>
      </div>
    </article>
  );
}
