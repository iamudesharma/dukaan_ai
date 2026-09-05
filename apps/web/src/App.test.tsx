import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { TestProviders } from "./test/TestProviders";
import App from "./App";

describe("DukaanAI web console", () => {
  it("opens on an operational dashboard instead of a marketing page", async () => {
    render(<TestProviders><App /></TestProviders>);
    expect(await screen.findByRole("heading", { name: /Namaste, Amit/i })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Tell DukaanAI/i })).toBeInTheDocument();
    expect(screen.getByText("You will receive")).toBeInTheDocument();
  });
});
