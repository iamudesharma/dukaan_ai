import { useEffect, useState, type FormEvent, type ReactNode } from "react";
import { KeyRound, LoaderCircle, Phone, ShieldCheck, Store, UserPlus } from "lucide-react";
import {
  getAuthCapabilities,
  login as loginRequest,
  requestPasswordReset,
  confirmPasswordReset,
  sendOtp,
  signup as signupRequest,
  verifyOtp,
} from "../../data/repository";
import { ApiError } from "../../lib/api";
import { getAccessToken, setTokens } from "../../lib/supabase";
import type { AuthCapabilities } from "../../types";

interface Props {
  children: ReactNode;
}

interface AuthState {
  authenticated: boolean;
  loading: boolean;
}

// The API is the source of truth for available sign-in methods. Development
// OTP display is a separate capability and never controls whether OTP is shown.
const fallbackCapabilities: AuthCapabilities = { password: true, otp: false, devOtp: false };

function errorMessage(error: unknown, fallback: string): string {
  if (error instanceof ApiError) return error.detail.message || fallback;
  return fallback;
}

export function AuthGate({ children }: Props) {
  const [auth, setAuth] = useState<AuthState>({ authenticated: false, loading: true });
  const [phone, setPhone] = useState("+91");
  const [otp, setOtp] = useState("");
  const [password, setPassword] = useState("");
  const [displayName, setDisplayName] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [step, setStep] = useState<
    "password" | "otp" | "otp-verify" | "signup" | "reset" | "reset-confirm"
  >("password");
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [devOtp, setDevOtp] = useState<string | null>(null);
  const [capabilities, setCapabilities] = useState<AuthCapabilities>(fallbackCapabilities);

  useEffect(() => {
    setAuth({ authenticated: !!getAccessToken(), loading: false });
  }, []);

  useEffect(() => {
    if (auth.loading || auth.authenticated) return;
    let active = true;
    void getAuthCapabilities()
      .then((next) => {
        if (!active) return;
        setCapabilities(next);
        setStep((current) => current === "password" && !next.password && next.otp ? "otp" : current);
      })
      .catch(() => {
        // Keep password sign-in available if capability discovery is offline.
      });
    return () => { active = false; };
  }, [auth.authenticated, auth.loading]);

  const normalizedPhone = () => phone.replace(/[\s()-]/g, "");

  function returnToSignIn() {
    setStep(capabilities.password ? "password" : capabilities.otp ? "otp" : "password");
    setMessage(null);
  }

  async function submitLogin(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setMessage(null);
    try {
      const result = await loginRequest(normalizedPhone(), password);
      setTokens({ access: result.access, refresh: result.refresh });
      setAuth({ authenticated: true, loading: false });
    } catch (error) {
      setMessage(errorMessage(error, "Invalid phone number or password."));
    } finally {
      setSubmitting(false);
    }
  }

  async function submitOtpRequest(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setMessage(null);
    setDevOtp(null);
    try {
      const code = await sendOtp(normalizedPhone());
      setStep("otp-verify");
      if (code) setDevOtp(code);
    } catch (error) {
      setMessage(errorMessage(error, "Could not send a code to this number."));
    } finally {
      setSubmitting(false);
    }
  }

  async function submitOtp(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setMessage(null);
    try {
      const result = await verifyOtp(normalizedPhone(), otp);
      setTokens({ access: result.access, refresh: result.refresh });
      setAuth({ authenticated: true, loading: false });
    } catch (error) {
      setMessage(errorMessage(error, "Invalid or expired code."));
    } finally {
      setSubmitting(false);
    }
  }

  async function submitSignup(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setMessage(null);
    try {
      const result = await signupRequest(
        normalizedPhone(),
        password,
        displayName || undefined,
      );
      setTokens({ access: result.access, refresh: result.refresh });
      setAuth({ authenticated: true, loading: false });
    } catch (error) {
      setMessage(errorMessage(error, "Could not create your account."));
    } finally {
      setSubmitting(false);
    }
  }

  async function submitPasswordResetRequest(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setMessage(null);
    setDevOtp(null);
    try {
      const code = await requestPasswordReset(normalizedPhone());
      setStep("reset-confirm");
      if (code) setDevOtp(code);
    } catch (error) {
      setMessage(errorMessage(error, "Could not send a reset code."));
    } finally {
      setSubmitting(false);
    }
  }

  async function submitPasswordResetConfirm(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setMessage(null);
    try {
      await confirmPasswordReset(normalizedPhone(), otp, newPassword);
      setPassword("");
      setOtp("");
      setNewPassword("");
      returnToSignIn();
      setMessage("Password has been reset. Sign in with your new password.");
    } catch (error) {
      setMessage(errorMessage(error, "Invalid or expired code."));
    } finally {
      setSubmitting(false);
    }
  }

  if (auth.loading) {
    return (
      <main className="auth-layout" aria-busy="true">
        <LoaderCircle className="spin" aria-hidden="true" />
        <p>Checking your secure session…</p>
      </main>
    );
  }

  if (auth.authenticated) {
    return <>{children}</>;
  }

  return (
    <main className="auth-layout">
      <section className="auth-brand" aria-labelledby="welcome-title">
        <div className="brand-mark large" aria-hidden="true"><Store /></div>
        <p className="folio-kicker on-hero">DukaanAI</p>
        <h1 id="welcome-title">Your business, clearly organised.</h1>
        <p>Sign in securely with your phone number.</p>
        <div className="trust-note"><ShieldCheck aria-hidden="true" /> Your books and stock can only change after an explicit action.</div>
      </section>
      <section className="auth-card" aria-label="Sign in">
        {step === "password" ? (
          <form onSubmit={submitLogin}>
            <UserPlus className="auth-icon" aria-hidden="true" />
            <h2>Sign in with password</h2>
            <label htmlFor="phone-2">Mobile number</label>
            <input
              id="phone-2"
              inputMode="tel"
              autoComplete="tel"
              value={phone}
              onChange={(event) => setPhone(event.target.value)}
              placeholder="+91 98765 43210"
              required
            />
            <label htmlFor="password-2">Password</label>
            <input
              id="password-2"
              type="password"
              autoComplete="current-password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              placeholder="Your password"
              required
            />
            <button className="primary-button full" disabled={submitting}>
              {submitting ? <LoaderCircle className="spin" aria-hidden="true" /> : null}
              Sign in
            </button>
            {capabilities.otp ? (
              <button type="button" className="text-button" onClick={() => setStep("otp")}>
                Use a one-time code instead
              </button>
            ) : null}
            {capabilities.password ? (
              <button type="button" className="text-button" onClick={() => setStep("signup")}>
                Create a new account
              </button>
            ) : null}
            {capabilities.password ? (
              <button type="button" className="text-button" onClick={() => setStep("reset")}>
                Forgot password?
              </button>
            ) : null}
          </form>
        ) : step === "signup" ? (
          <form onSubmit={submitSignup}>
            <UserPlus className="auth-icon" aria-hidden="true" />
            <h2>Create your account</h2>
            <p>You&apos;ll set up your shop in the next step.</p>
            <label htmlFor="signup-phone">Mobile number</label>
            <input
              id="signup-phone"
              inputMode="tel"
              autoComplete="tel"
              value={phone}
              onChange={(event) => setPhone(event.target.value)}
              placeholder="+91 98765 43210"
              required
            />
            <label htmlFor="signup-name">Display name</label>
            <input
              id="signup-name"
              autoComplete="name"
              value={displayName}
              onChange={(event) => setDisplayName(event.target.value)}
              placeholder="Your name"
            />
            <label htmlFor="signup-password">Password</label>
            <input
              id="signup-password"
              type="password"
              autoComplete="new-password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              placeholder="At least 8 characters"
              minLength={8}
              required
            />
            <button className="primary-button full" disabled={submitting}>
              {submitting ? <LoaderCircle className="spin" aria-hidden="true" /> : null}
              Create account
            </button>
            <button type="button" className="text-button" onClick={returnToSignIn}>
              Back to sign in
            </button>
          </form>
        ) : step === "reset" ? (
          <form onSubmit={submitPasswordResetRequest}>
            <KeyRound className="auth-icon" aria-hidden="true" />
            <h2>Reset your password</h2>
            <p>We&apos;ll send a code to {phone || "your number"}.</p>
            <label htmlFor="reset-phone">Mobile number</label>
            <input
              id="reset-phone"
              inputMode="tel"
              autoComplete="tel"
              value={phone}
              onChange={(event) => setPhone(event.target.value)}
              placeholder="+91 98765 43210"
              required
            />
            <button className="primary-button full" disabled={submitting}>
              {submitting ? <LoaderCircle className="spin" aria-hidden="true" /> : null}
              Send reset code
            </button>
            <button type="button" className="text-button" onClick={returnToSignIn}>
              Back to sign in
            </button>
          </form>
        ) : step === "reset-confirm" ? (
          <form onSubmit={submitPasswordResetConfirm}>
            <KeyRound className="auth-icon" aria-hidden="true" />
            <h2>Choose a new password</h2>
            <label htmlFor="reset-otp">One-time code</label>
            <input
              id="reset-otp"
              inputMode="numeric"
              autoComplete="one-time-code"
              value={otp}
              onChange={(event) => setOtp(event.target.value.replace(/\D/g, "").slice(0, 6))}
              placeholder="000000"
              required
              minLength={6}
            />
            <label htmlFor="reset-new-password">New password</label>
            <input
              id="reset-new-password"
              type="password"
              autoComplete="new-password"
              value={newPassword}
              onChange={(event) => setNewPassword(event.target.value)}
              placeholder="At least 8 characters"
              minLength={8}
              required
            />
            <button className="primary-button full" disabled={submitting || otp.length !== 6 || !newPassword}>
              {submitting ? <LoaderCircle className="spin" aria-hidden="true" /> : null}
              Reset password
            </button>
            <button type="button" className="text-button" onClick={returnToSignIn}>
              Back to sign in
            </button>
          </form>
        ) : step === "otp-verify" ? (
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
            <button type="button" className="text-button" onClick={() => setStep("otp")}>
              Use another number
            </button>
          </form>
        ) : (
          <form onSubmit={submitOtpRequest}>
            <Phone className="auth-icon" aria-hidden="true" />
            <h2>Sign in with a one-time code</h2>
            <p>We&apos;ll send a 6-digit code to your phone.</p>
            <label htmlFor="otp-phone">Mobile number</label>
            <input
              id="otp-phone"
              inputMode="tel"
              autoComplete="tel"
              value={phone}
              onChange={(event) => setPhone(event.target.value)}
              placeholder="+91 98765 43210"
              required
            />
            <button className="primary-button full" disabled={submitting}>
              {submitting ? <LoaderCircle className="spin" aria-hidden="true" /> : null}
              Send code
            </button>
            {capabilities.password ? (
              <button type="button" className="text-button" onClick={returnToSignIn}>
                Use a password instead
              </button>
            ) : null}
          </form>
        )}
        {capabilities.devOtp && devOtp ? (
          <p className="dev-otp" role="status">Dev OTP: <code>{devOtp}</code></p>
        ) : null}
        {!capabilities.password && !capabilities.otp ? (
          <p className="form-error" role="alert">Sign-in is temporarily unavailable. Please try again later.</p>
        ) : null}
        {message ? <p className="form-error" role="alert">{message}</p> : null}
        <p className="payment-disclaimer">DukaanAI records payment information. It does not collect, hold, or transfer money.</p>
      </section>
    </main>
  );
}
