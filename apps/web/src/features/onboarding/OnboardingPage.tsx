import { useState, type FormEvent } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { LoaderCircle, ShieldCheck, Store } from "lucide-react";
import { createBusiness } from "../../data/repository";
import { ApiError } from "../../lib/api";
import { InvitationAcceptPanel } from "../invitations/InvitationAcceptPanel";

export function OnboardingPage() {
  const queryClient = useQueryClient();
  const [name, setName] = useState("");
  const [legalName, setLegalName] = useState("");
  const [locationName, setLocationName] = useState("Main Shop");
  const [gstin, setGstin] = useState("");
  const [stateCode, setStateCode] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  async function submit(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setMessage(null);
    try {
      await createBusiness({
        name,
        legalName: legalName || undefined,
        locationName: locationName || undefined,
        gstin: gstin.trim().toUpperCase() || undefined,
        stateCode: stateCode.trim() || undefined,
      });
      await queryClient.invalidateQueries({ queryKey: ["me"] });
      await queryClient.invalidateQueries({ queryKey: ["bootstrap"] });
    } catch (error) {
      setMessage(
        error instanceof ApiError
          ? error.detail.message || "Could not create your shop."
          : "Could not create your shop.",
      );
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <main className="auth-layout">
      <section className="auth-brand" aria-labelledby="onboarding-title">
        <div className="brand-mark large" aria-hidden="true"><Store /></div>
        <p className="folio-kicker on-hero">One last step</p>
        <h1 id="onboarding-title">Set up your shop</h1>
        <p>This creates your workspace and its first location. You can add more locations later.</p>
        <div className="trust-note"><ShieldCheck aria-hidden="true" /> Only you can see this business. Nothing is shared until you invite your team.</div>
      </section>
      <section className="auth-card" aria-label="Set up your shop">
        <form onSubmit={submit}>
          <Store className="auth-icon" aria-hidden="true" />
          <h2>Shop details</h2>
          <label htmlFor="shop-name">Shop name</label>
          <input
            id="shop-name"
            value={name}
            onChange={(event) => setName(event.target.value)}
            placeholder="e.g. Gupta Traders"
            required
          />
          <label htmlFor="shop-legal-name">Registered name (optional)</label>
          <input
            id="shop-legal-name"
            value={legalName}
            onChange={(event) => setLegalName(event.target.value)}
            placeholder="As printed on your GST certificate"
          />
          <label htmlFor="shop-location">First location (optional)</label>
          <input
            id="shop-location"
            value={locationName}
            onChange={(event) => setLocationName(event.target.value)}
            placeholder="Main Shop"
          />
          <label htmlFor="shop-gstin">GSTIN (optional)</label>
          <input
            id="shop-gstin"
            value={gstin}
            onChange={(event) => setGstin(event.target.value)}
            placeholder="07AAAAA0000A1Z5"
            maxLength={15}
          />
          <label htmlFor="shop-state">State code (optional)</label>
          <input
            id="shop-state"
            value={stateCode}
            onChange={(event) => setStateCode(event.target.value.replace(/\D/g, "").slice(0, 2))}
            placeholder="07"
            maxLength={2}
            inputMode="numeric"
          />
          <button className="primary-button full" disabled={submitting || !name.trim()}>
            {submitting ? <LoaderCircle className="spin" aria-hidden="true" /> : null}
            Create my shop
          </button>
        </form>
        {message ? <p className="form-error" role="alert">{message}</p> : null}
        <InvitationAcceptPanel compact onAccepted={async () => { await queryClient.invalidateQueries({ queryKey: ["me"] }); await queryClient.invalidateQueries({ queryKey: ["bootstrap"] }); }} />
        <p className="payment-disclaimer">DukaanAI records payment information. It does not collect, hold, or transfer money.</p>
      </section>
    </main>
  );
}
