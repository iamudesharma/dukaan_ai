import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { AuthGate } from "./AuthGate";
import { TestProviders } from "../../test/TestProviders";
import { jsonResponse, mockApi, requestBody } from "../../test/apiMocks";

afterEach(() => {
  localStorage.clear();
  vi.unstubAllGlobals();
});

describe("AuthGate capabilities", () => {
  it("offers OTP sign-in when the API enables it, without requiring dev mode", async () => {
    const user = userEvent.setup();
    const fetchMock = mockApi({
      "GET /api/v1/auth/capabilities/": () => jsonResponse({ password: true, otp: true, dev_otp: false }),
      "POST /api/v1/auth/otp/send/": () => jsonResponse({ dev_otp: "123456" }),
    });
    vi.stubGlobal("fetch", fetchMock);

    render(<TestProviders><AuthGate><div>Signed in content</div></AuthGate></TestProviders>);

    await user.click(await screen.findByRole("button", { name: "Use a one-time code instead" }));
    const phone = screen.getByLabelText("Mobile number");
    await user.clear(phone);
    await user.type(phone, "+919876543210");
    await user.click(screen.getByRole("button", { name: "Send code" }));

    expect(await screen.findByRole("heading", { name: "Enter the 6-digit code" })).toBeInTheDocument();
    expect(screen.queryByText(/Dev OTP/)).not.toBeInTheDocument();
    const sendCall = fetchMock.mock.calls.find(([input]) => String(input).endsWith("/api/v1/auth/otp/send/"));
    expect(requestBody(sendCall?.[1])).toEqual({ phone: "+919876543210" });
  });

  it("starts with OTP when password sign-in is disabled", async () => {
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/auth/capabilities/": () => jsonResponse({ password: false, otp: true, dev_otp: true }),
    }));

    render(<TestProviders><AuthGate><div>Signed in content</div></AuthGate></TestProviders>);

    expect(await screen.findByRole("heading", { name: "Sign in with a one-time code" })).toBeInTheDocument();
    expect(screen.queryByRole("heading", { name: "Sign in with password" })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Use a password instead" })).not.toBeInTheDocument();
  });

  it("keeps the password reset flow available when password auth is enabled", async () => {
    const user = userEvent.setup();
    vi.stubGlobal("fetch", mockApi({
      "GET /api/v1/auth/capabilities/": () => jsonResponse({ password: true, otp: false, dev_otp: false }),
      "POST /api/v1/auth/password/reset/": () => jsonResponse({ dev_otp: "654321" }),
    }));

    render(<TestProviders><AuthGate><div>Signed in content</div></AuthGate></TestProviders>);

    await user.click(await screen.findByRole("button", { name: "Forgot password?" }));
    expect(screen.getByRole("heading", { name: "Reset your password" })).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: "Send reset code" }));
    expect(await screen.findByRole("heading", { name: "Choose a new password" })).toBeInTheDocument();
  });
});
