import { useState, type FormEvent } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { LoaderCircle, Store } from "lucide-react";
import { createBusiness, updateMe } from "../../data/repository";

interface Props {
  onDone: () => void;
}

export function OnboardingWizard({ onDone }: Props) {
  const queryClient = useQueryClient();
  const [businessName, setBusinessName] = useState("");
  const [displayName, setDisplayName] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (!businessName.trim()) return;
    setSubmitting(true);
    setMessage(null);
    try {
      await createBusiness({ name: businessName.trim() });
      if (displayName.trim()) {
        try {
          await updateMe(displayName.trim());
        } catch {
          // Display name is a nicety; the business is what matters.
        }
      }
      await queryClient.invalidateQueries({ queryKey: ["bootstrap"] });
      onDone();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Could not create your business.");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <main className="auth-layout">
      <section className="auth-brand" aria-labelledby="onboarding-title">
        <div className="brand-mark large" aria-hidden="true"><Store /></div>
        <p className="eyebrow">DukaanAI</p>
        <h1 id="onboarding-title">Open your first business.</h1>
        <p>Your shop, stock and team live under one business. A main location is created for you.</p>
      </section>
      <section className="auth-card" aria-label="Create business">
        <form onSubmit={submit}>
          <label htmlFor="business-name">Business name</label>
          <input
            id="business-name"
            value={businessName}
            onChange={(event) => setBusinessName(event.target.value)}
            placeholder="Sharma Garments"
            required
            maxLength={160}
          />
          <label htmlFor="owner-name">Your name (optional)</label>
          <input
            id="owner-name"
            value={displayName}
            onChange={(event) => setDisplayName(event.target.value)}
            placeholder="Amit Sharma"
            maxLength={120}
          />
          <button className="primary-button full" disabled={submitting || !businessName.trim()}>
            {submitting ? <LoaderCircle className="spin" aria-hidden="true" /> : null}
            {submitting ? "Creating…" : "Create business"}
          </button>
          {message ? <p className="form-error" role="alert">{message}</p> : null}
        </form>
      </section>
    </main>
  );
}
