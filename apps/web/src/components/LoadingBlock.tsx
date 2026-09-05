export function LoadingBlock({ label = "Loading business data…" }: { label?: string }) {
  return (
    <div className="loading-block" aria-live="polite" aria-busy="true">
      <span className="loading-dot" aria-hidden="true" />
      <span className="loading-dot" aria-hidden="true" />
      <span className="loading-dot" aria-hidden="true" />
      <span className="sr-only">{label}</span>
    </div>
  );
}
