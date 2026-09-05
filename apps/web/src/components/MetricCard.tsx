import type { LucideIcon } from "lucide-react";
import { formatMoney } from "../lib/format";

interface Props {
  label: string;
  valueMinor?: number;
  value?: string;
  hint: string;
  icon: LucideIcon;
  tone?: "blue" | "green" | "amber" | "red";
}

export function MetricCard({ label, valueMinor, value, hint, icon: Icon, tone = "blue" }: Props) {
  return (
    <article className="metric-card">
      <div className={`metric-icon ${tone}`}><Icon aria-hidden="true" /></div>
      <div>
        <p className="metric-label">{label}</p>
        <strong>{value ?? formatMoney(valueMinor ?? 0)}</strong>
        <p className="metric-hint">{hint}</p>
      </div>
    </article>
  );
}
