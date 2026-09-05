import { beforeEach, describe, expect, it } from "vitest";
import { confirmDemoProposal, getDemoState, interpretDemoCommand, resetDemoState } from "./demo";

describe("demo assistant safety contract", () => {
  beforeEach(() => resetDemoState());

  it("extracts the canonical Ramesh sale without treating quantity as money", () => {
    const proposal = interpretDemoCommand(
      "Ramesh bought 3 shirts for ₹2,400, paid ₹1,500, ₹900 pending.",
      "location-karol-bagh",
    );

    expect(proposal.status).toBe("READY");
    expect(proposal.intent).toBe("RECORD_SALE");
    expect(proposal.lines[0].quantity).toBe("3");
    expect(proposal.totalMinor).toBe(240_000);
    expect(proposal.paidMinor).toBe(150_000);
    expect(proposal.outstandingMinor).toBe(90_000);
  });

  it("does not mutate books or stock until explicit confirmation", () => {
    const before = getDemoState();
    const proposal = interpretDemoCommand(
      "Ramesh bought 3 shirts for ₹2,400, paid ₹1,500, ₹900 pending.",
      "location-karol-bagh",
    );

    expect(getDemoState()).toEqual(before);

    const entry = confirmDemoProposal(proposal);
    const after = getDemoState();
    expect(entry.totalMinor).toBe(240_000);
    expect(after.entries).toHaveLength(before.entries.length + 1);
    expect(after.products.find((product) => product.id === "product-shirt-blue")?.onHand).toBe("15");
    expect(after.parties.find((party) => party.id === "party-ramesh")?.receivableMinor).toBe(214_000);
  });

  it("blocks incomplete commands at the review stage", () => {
    const proposal = interpretDemoCommand("Sold something", "location-karol-bagh");
    expect(proposal.status).toBe("NEEDS_DETAILS");
    expect(proposal.questions).toContain("What is the total amount?");
    expect(() => confirmDemoProposal(proposal)).toThrow("not ready");
  });
});
