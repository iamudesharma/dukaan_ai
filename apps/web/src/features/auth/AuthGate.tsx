import { useEffect, useState, type FormEvent, type ReactNode } from "react";
import { KeyRound, LoaderCircle, Phone, ShieldCheck, Store } from "lucide-react";
import type { Session } from "@supabase/supabase-js";
import { demoMode, supabase } from "../../lib/supabase";

interface Props {
  children: ReactNode;
}

export function AuthGate({ children }: Props) {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(!demoMode);
  const [phone, setPhone] = useState("+91");
  const [otp, setOtp] = useState("");
  const [step, setStep] = useState<"phone" | "otp">("phone");
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  useEffect(() => {
    if (demoMode || !supabase) {
      setLoading(false);
      return;
    }
    void supabase.auth.getSession().then(({ data }) => {
      setSession(data.session);
      setLoading(false);
    });
    const { data } = supabase.auth.onAuthStateChange((_event, nextSession) => {
      setSession(nextSession);
      setLoading(false);
    });
    return () => data.subscription.unsubscribe();
  }, []);

  async function submitPhone(event: FormEvent) {
    event.preventDefault();
    if (!supabase) {
      setMessage("Supabase configuration is missing. Set the web environment variables.");
      return;
    }
    setSubmitting(true);
    setMessage(null);
    const normalized = phone.replace(/[\s()-]/g, "");
    const { error } = await supabase.auth.signInWithOtp({ phone: normalized });
    setSubmitting(false);
    if (error) setMessage(error.message);
    else setStep("otp");
  }

  async function submitOtp(event: FormEvent) {
    event.preventDefault();
    if (!supabase) return;
    setSubmitting(true);
    setMessage(null);
    const normalized = phone.replace(/[\s()-]/g, "");
    const { error } = await supabase.auth.verifyOtp({ phone: normalized, token: otp, type: "sms" });
    setSubmitting(false);
    if (error) setMessage(error.message);
  }

  if (loading) {
    return (
      <main className="auth-layout" aria-busy="true">
        <LoaderCircle className="spin" aria-hidden="true" />
        <p>Checking your secure session…</p>
      </main>
    );
  }

  if (demoMode || session) return <>{children}</>;

  return (
    <main className="auth-layout">
      <section className="auth-brand" aria-labelledby="welcome-title">
        <div className="brand-mark large" aria-hidden="true"><Store /></div>
        <p className="eyebrow">DukaanAI</p>
        <h1 id="welcome-title">Your business, clearly organised.</h1>
        <p>Sign in securely with the phone number linked to your business.</p>
        <div className="trust-note"><ShieldCheck aria-hidden="true" /> Your books and stock can only change after an explicit action.</div>
      </section>
      <section className="auth-card" aria-label="Sign in">
        {step === "phone" ? (
          <form onSubmit={submitPhone}>
            <Phone className="auth-icon" aria-hidden="true" />
            <h2>Phone sign in</h2>
            <p>We’ll send a one-time code to verify it’s you.</p>
            <label htmlFor="phone">Mobile number</label>
            <input
              id="phone"
              inputMode="tel"
              autoComplete="tel"
              value={phone}
              onChange={(event) => setPhone(event.target.value)}
              placeholder="+91 98765 43210"
              required
            />
            <button className="primary-button full" disabled={submitting}>
              {submitting ? <LoaderCircle className="spin" aria-hidden="true" /> : null}
              Send OTP
            </button>
          </form>
        ) : (
          <form onSubmit={submitOtp}>
            <KeyRound className="auth-icon" aria-hidden="true" />
            <h2>Enter the 6-digit code</h2>
            <p>Sent to {phone}. It may take a few seconds.</p>
            <label htmlFor="otp">One-time code</label>
            <input
              id="otp"
              inputMode="numeric"
              autoComplete="one-time-code"
              value={otp}
              onChange={(event) => setOtp(event.target.value.replace(/\D/g, "").slice(0, 6))}
              placeholder="000000"
              required
              minLength={6}
            />
            <button className="primary-button full" disabled={submitting || otp.length !== 6}>
              {submitting ? <LoaderCircle className="spin" aria-hidden="true" /> : null}
              Verify and continue
            </button>
            <button type="button" className="text-button" onClick={() => setStep("phone")}>Use another number</button>
          </form>
        )}
        {message ? <p className="form-error" role="alert">{message}</p> : null}
        <p className="payment-disclaimer">DukaanAI records payment information. It does not collect, hold, or transfer money.</p>
      </section>
    </main>
  );
}
