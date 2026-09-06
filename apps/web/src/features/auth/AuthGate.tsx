import { useEffect, useState, type FormEvent, type ReactNode } from "react";
import { KeyRound, LoaderCircle, LogOut, Phone, ShieldCheck, Store, UserPlus } from "lucide-react";
import { demoMode, getAccessToken, setTokens, clearTokens } from "../../lib/supabase";

interface Props {
  children: ReactNode;
}

interface AuthState {
  authenticated: boolean;
  loading: boolean;
}

export function AuthGate({ children }: Props) {
  const [auth, setAuth] = useState<AuthState>({
    authenticated: demoMode,
    loading: !demoMode,
  });
  const [phone, setPhone] = useState("+91");
  const [otp, setOtp] = useState("");
  const [password, setPassword] = useState("");
  const [displayName, setDisplayName] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [step, setStep] = useState<"phone" | "otp" | "password" | "signup" | "reset" | "reset-confirm">("phone");
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [devOtp, setDevOtp] = useState<string | null>(null);

  useEffect(() => {
    if (demoMode) {
      setAuth({ authenticated: true, loading: false });
      return;
    }
    const token = getAccessToken();
    setAuth({ authenticated: !!token, loading: false });
  }, []);

  async function submitPhone(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setMessage(null);
    setDevOtp(null);
    const normalized = phone.replace(/[\s()-]/g, "");
    try {
      const res = await fetch("/api/v1/auth/otp/send/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone: normalized }),
      });
      const data = await res.json();
      if (!res.ok) {
        setMessage(data.detail ?? "Could not send code.");
      } else {
        setStep("otp");
        if (data.dev_otp) setDevOtp(data.dev_otp);
      }
    } catch {
      setMessage("Network error. Please try again.");
    } finally {
      setSubmitting(false);
    }
  }

  async function submitLogin(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setMessage(null);
    const normalized = phone.replace(/[\s()-]/g, "");
    try {
      const res = await fetch("/api/v1/auth/login/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone: normalized, password }),
      });
      const data = await res.json();
      if (!res.ok) {
        setMessage(data.detail ?? "Invalid phone or password.");
      } else {
        setTokens({ access: data.access, refresh: data.refresh });
        setAuth({ authenticated: true, loading: false });
      }
    } catch {
      setMessage("Network error. Please try again.");
    } finally {
      setSubmitting(false);
    }
  }

  async function submitOtp(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setMessage(null);
    const normalized = phone.replace(/[\s()-]/g, "");
    try {
      const res = await fetch("/api/v1/auth/otp/verify/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone: normalized, otp }),
      });
      const data = await res.json();
      if (!res.ok) {
        setMessage(data.detail ?? "Invalid code.");
      } else {
        setTokens({ access: data.access, refresh: data.refresh });
        setAuth({ authenticated: true, loading: false });
      }
    } catch {
      setMessage("Network error. Please try again.");
    } finally {
      setSubmitting(false);
    }
  }

  async function submitSignup(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setMessage(null);
    const normalized = phone.replace(/[\s()-]/g, "");
    try {
      const res = await fetch("/api/v1/auth/signup/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone: normalized, password, ...(displayName ? { display_name: displayName } : {}) }),
      });
      const data = await res.json();
      if (!res.ok) {
        setMessage(data.detail ?? "Could not create your account.");
      } else {
        setTokens({ access: data.access, refresh: data.refresh });
        setAuth({ authenticated: true, loading: false });
      }
    } catch {
      setMessage("Network error. Please try again.");
    } finally {
      setSubmitting(false);
    }
  }

  async function submitPasswordResetRequest(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setMessage(null);
    setDevOtp(null);
    const normalized = phone.replace(/[\s()-]/g, "");
    try {
      const res = await fetch("/api/v1/auth/password/reset/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone: normalized }),
      });
      const data = await res.json();
      if (!res.ok) {
        setMessage(data.detail ?? "Could not send a reset code.");
      } else {
        setStep("reset-confirm");
        if (data.dev_otp) setDevOtp(data.dev_otp);
      }
    } catch {
      setMessage("Network error. Please try again.");
    } finally {
      setSubmitting(false);
    }
  }

  async function submitPasswordResetConfirm(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setMessage(null);
    const normalized = phone.replace(/[\s()-]/g, "");
    try {
      const res = await fetch("/api/v1/auth/password/reset/confirm/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone: normalized, otp, new_password: newPassword }),
      });
      const data = await res.json();
      if (!res.ok) {
        setMessage(data.detail ?? "Invalid code.");
      } else {
        setMessage("Password has been reset. Sign in with your new password.");
        setStep("password");
      }
    } catch {
      setMessage("Network error. Please try again.");
    } finally {
      setSubmitting(false);
    }
  }

  async function logout() {
    try {
      const refresh = localStorage.getItem("dukaan_refresh_token");
      await fetch("/api/v1/auth/logout/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${getAccessToken() ?? ""}`,
        },
        body: JSON.stringify({ refresh }),
      });
    } catch {
      // ignore
    }
    clearTokens();
    setAuth({ authenticated: false, loading: false });
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
    return (
      <>
        <button
          className="auth-signout"
          onClick={logout}
          aria-label="Sign out"
          style={{ position: "fixed", top: 12, right: 12, zIndex: 1000 }}
        >
          <LogOut aria-hidden="true" size={16} /> Sign out
        </button>
        {children}
      </>
    );
  }

  return (
    <main className="auth-layout">
      <section className="auth-brand" aria-labelledby="welcome-title">
        <div className="brand-mark large" aria-hidden="true"><Store /></div>
        <p className="eyebrow">DukaanAI</p>
        <h1 id="welcome-title">Your business, clearly organised.</h1>
        <p>Sign in securely with your phone number.</p>
        <div className="trust-note"><ShieldCheck aria-hidden="true" /> Your books and stock can only change after an explicit action.</div>
      </section>
      <section className="auth-card" aria-label="Sign in">
        {step === "phone" ? (
          <form onSubmit={submitPhone}>
            <Phone className="auth-icon" aria-hidden="true" />
            <h2>Phone sign in</h2>
            <p>We'll send a one-time code or use your password.</p>
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
            <label htmlFor="password">Password (optional)</label>
            <input
              id="password"
              type="password"
              autoComplete="current-password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              placeholder="Leave blank for OTP"
            />
            <button className="primary-button full" disabled={submitting} onClick={() => {
              if (password) {
                void submitPhone(new Event("submit") as unknown as FormEvent);
              }
            }}>
              {submitting ? <LoaderCircle className="spin" aria-hidden="true" /> : null}
              {password ? "Sign in with password" : "Send OTP"}
            </button>
            {password ? (
              <button type="button" className="text-button" onClick={() => setPassword("")}>
                Use OTP instead
              </button>
            ) : (
              <button type="button" className="text-button" onClick={() => setStep("password")}>
                Use password
              </button>
            )}
            <button type="button" className="text-button" onClick={() => setStep("signup")}>
              Create a new account
            </button>
            <button type="button" className="text-button" onClick={() => setStep("reset")}>
              Forgot password?
            </button>
          </form>
        ) : step === "signup" ? (
          <form onSubmit={submitSignup}>
            <UserPlus className="auth-icon" aria-hidden="true" />
            <h2>Create your account</h2>
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
              placeholder="Choose a password"
              required
            />
            <button className="primary-button full" disabled={submitting}>
              {submitting ? <LoaderCircle className="spin" aria-hidden="true" /> : null}
              Create account
            </button>
            <button type="button" className="text-button" onClick={() => setStep("phone")}>
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
            <button type="button" className="text-button" onClick={() => setStep("phone")}>
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
              placeholder="Choose a new password"
              required
            />
            <button className="primary-button full" disabled={submitting || otp.length !== 6 || !newPassword}>
              {submitting ? <LoaderCircle className="spin" aria-hidden="true" /> : null}
              Reset password
            </button>
            <button type="button" className="text-button" onClick={() => setStep("phone")}>Back to sign in</button>
          </form>
        ) : step === "password" ? (
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
            <button type="button" className="text-button" onClick={() => { setStep("phone"); setPassword(""); }}>
              Use OTP instead
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
        {devOtp ? (
          <p className="dev-otp" role="status">Dev OTP: <code>{devOtp}</code></p>
        ) : null}
        {message ? <p className="form-error" role="alert">{message}</p> : null}
        <p className="payment-disclaimer">DukaanAI records payment information. It does not collect, hold, or transfer money.</p>
      </section>
    </main>
  );
}
