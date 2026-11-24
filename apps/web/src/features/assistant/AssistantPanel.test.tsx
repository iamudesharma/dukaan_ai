import { afterEach, describe, expect, it, vi } from "vitest";
import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useWorkspace } from "../../app/WorkspaceContext";
import { AssistantPanel } from "./AssistantPanel";
import { jsonResponse, mockApi, requestBody, workspaceWithRole } from "../../test/apiMocks";
import { renderWithWorkspace } from "../../test/renderWorkspace";

afterEach(() => vi.unstubAllGlobals());

function AssistantHarness() {
  const { openAssistant } = useWorkspace();
  return (
    <>
      <button type="button" onClick={openAssistant}>Open assistant</button>
      <AssistantPanel />
    </>
  );
}

describe("AssistantPanel purchase flow", () => {
  it("reviews supplier and unit cost details and confirms with purchase UI copy", async () => {
    const user = userEvent.setup();
    const fetchMock = mockApi({
      "POST /api/v1/assistant/proposals/": () => jsonResponse({
        id: "proposal1",
        version: 1,
        status: "READY",
        command_type: "PURCHASE",
        content: "Bought 2.5 metres of fabric from Sharma Suppliers",
        payload: {
          supplier_id: "vendor1",
          lines: [{ pack_id: "pack1", quantity: "2.5", unit_cost_minor: 4000 }],
          paid_amount_minor: 1500,
        },
        warnings: [],
        blocking_questions: [],
      }, 201),
      "GET /api/v1/products/": () => jsonResponse({
        results: [{ id: "product1", name: "Fabric", base_unit: "METRE", stock_quantity: "10", packs: [{ id: "pack1" }] }],
      }),
      "GET /api/v1/parties/": () => jsonResponse({
        results: [{ id: "vendor1", name: "Sharma Suppliers", kind: "SUPPLIER" }],
      }),
      "POST /api/v1/assistant/proposals/proposal1/confirm/": () => jsonResponse({
        proposal: { confirmed_result_type: "operations.purchase" },
        result: { id: "purchase1", number: "P-1", status: "POSTED", grand_total_minor: 10000, due_total_minor: 8500 },
      }),
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<AssistantHarness />);
    await user.click(screen.getByRole("button", { name: "Open assistant" }));
    await user.type(screen.getByLabelText("Sale, purchase, payment or expense"), "Bought fabric from Sharma Suppliers");
    await user.click(screen.getByRole("button", { name: "Review what will be recorded" }));

    expect(await screen.findByRole("heading", { name: "Purchase" })).toBeInTheDocument();
    expect(screen.getByText("Sharma Suppliers")).toBeInTheDocument();
    expect(screen.getByText(/2.5 metre × ₹40/)).toBeInTheDocument();
    expect(screen.getByText("Increase Fabric stock by 2.5 metre")).toBeInTheDocument();
    expect(screen.getByText("Add ₹85 to the supplier's payable balance")).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Record purchase ₹100" }));
    expect(await screen.findByText("P-1 was recorded successfully.")).toBeInTheDocument();
    const confirmCall = fetchMock.mock.calls.find(([input]) => String(input).endsWith("/proposal1/confirm/"));
    expect(requestBody(confirmCall?.[1])).toMatchObject({ version: 1 });
    expect(requestBody(confirmCall?.[1]).idempotency_key).toBe("proposal:proposal1:v1");
  });

  it("hides purchase examples and blocks cashier text purchase proposals", async () => {
    const user = userEvent.setup();
    const fetchMock = mockApi({
      "POST /api/v1/assistant/proposals/": () => jsonResponse({
        id: "proposal1", version: 1, status: "READY", command_type: "PURCHASE", content: "Bought fabric",
        payload: { supplier_id: "vendor1", lines: [{ pack_id: "pack1", quantity: "1", unit_cost_minor: 400000 }], grand_total_minor: 400000 },
        warnings: [], blocking_questions: [],
      }, 201),
      "GET /api/v1/products/": () => jsonResponse({
        results: [{ id: "product1", name: "Fabric", base_unit: "METRE", packs: [{ id: "pack1" }] }],
      }),
      "GET /api/v1/parties/": () => jsonResponse({
        results: [{ id: "vendor1", name: "Sharma Suppliers", kind: "SUPPLIER" }],
      }),
      "POST /api/v1/assistant/proposals/proposal1/cancel/": () => jsonResponse({ id: "proposal1", status: "CANCELLED" }),
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<AssistantHarness />, workspaceWithRole("CASHIER"));
    await user.click(screen.getByRole("button", { name: "Open assistant" }));

    expect(screen.getByLabelText("Sale or customer receipt")).toBeInTheDocument();
    expect(screen.queryByText(/Bought 2.5 metres from Sharma Suppliers/i)).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "View past proposals" })).not.toBeInTheDocument();
    await user.type(screen.getByLabelText("Sale or customer receipt"), "Bought fabric from Sharma Suppliers");
    await user.click(screen.getByRole("button", { name: "Review what will be recorded" }));

    expect(await screen.findByText("Cashiers can only record sales and customer receipts with the assistant.")).toBeInTheDocument();
    expect(screen.queryByRole("heading", { name: "Purchase" })).not.toBeInTheDocument();
    expect(fetchMock.mock.calls.some(([input]) => String(input).endsWith("/proposal1/cancel/"))).toBe(true);
  });

  it("uploads raw receipt bytes, polls OCR and opens the existing sale review", async () => {
    const user = userEvent.setup();
    const file = new File([new Uint8Array([0xff, 0xd8, 0xff, 0xe0])], "sale.jpg", { type: "image/jpeg" });
    const fetchMock = mockApi({
      "POST /api/v1/assistant/attachments/upload/": (init) => {
        expect(init?.body).toBeInstanceOf(FormData);
        expect((init?.body as FormData).get("file")).toBeInstanceOf(File);
        expect(((init?.body as FormData).get("file") as File).name).toBe(file.name);
        expect(((init?.body as FormData).get("file") as File).type).toBe(file.type);
        return jsonResponse({ id: "attachment1", business: "b1", kind: "IMAGE", mime: "image/jpeg", size_bytes: file.size, status: "READY" }, 201);
      },
      "POST /api/v1/assistant/proposals/from-image/": (init) => {
        expect(requestBody(init)).toEqual({ attachment_id: "attachment1", business_id: "b1", location_id: "l1", locale: "en-IN" });
        return jsonResponse({
          id: "proposal1", version: 1, status: "DRAFT", command_type: "UNSUPPORTED", content: "", payload: {},
          blocking_questions: ["Your image or PDF is being read."],
        }, 201);
      },
      "GET /api/v1/assistant/proposals/proposal1/": () => jsonResponse({
        id: "proposal1", version: 2, status: "READY", command_type: "SALE", content: "Sold one shirt to Ramesh",
        payload: {
          customer_id: "customer1",
          lines: [{ pack_id: "pack1", quantity: "1", unit_price_minor: 120000 }],
          grand_total_minor: 120000, paid_amount_minor: 120000,
        },
        warnings: [], blocking_questions: [],
      }),
      "GET /api/v1/products/": () => jsonResponse({
        results: [{ id: "product1", name: "Shirt", base_unit: "PIECE", packs: [{ id: "pack1" }] }],
      }),
      "GET /api/v1/parties/": () => jsonResponse({
        results: [{ id: "customer1", name: "Ramesh", kind: "CUSTOMER" }],
      }),
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<AssistantHarness />, workspaceWithRole("OWNER"));
    await user.click(screen.getByRole("button", { name: "Open assistant" }));
    const fileInput = screen.getByLabelText("Receipt file") as HTMLInputElement;
    const openFile = vi.spyOn(fileInput, "click");
    await user.click(screen.getByRole("button", { name: /Scan bill/i }));
    expect(openFile).toHaveBeenCalled();
    await user.upload(fileInput, file);

    expect(await screen.findByRole("heading", { name: "Sale" })).toBeInTheDocument();
    expect(screen.getByText("Ramesh")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Record sale ₹1,200" })).toBeEnabled();
    expect(fetchMock.mock.calls.some(([input]) => String(input).endsWith("/proposal1/"))).toBe(true);
  });

  it("lets cashiers scan sale receipts but labels the control accordingly", async () => {
    const user = userEvent.setup();
    const file = new File([new Uint8Array([0x89, 0x50, 0x4e, 0x47])], "sale.png", { type: "image/png" });
    vi.stubGlobal("fetch", mockApi({
      "POST /api/v1/assistant/attachments/upload/": () => jsonResponse({ id: "attachment1", kind: "IMAGE", mime: "image/png", size_bytes: file.size, status: "READY" }, 201),
      "POST /api/v1/assistant/proposals/from-image/": () => jsonResponse({
        id: "proposal1", version: 1, status: "DRAFT", command_type: "UNSUPPORTED", content: "", payload: {},
        blocking_questions: ["Your image or PDF is being read."],
      }, 201),
      "GET /api/v1/assistant/proposals/proposal1/": () => jsonResponse({
        id: "proposal1", version: 2, status: "READY", command_type: "SALE", content: "Sold one shirt",
        payload: { lines: [{ pack_id: "pack1", quantity: "1", unit_price_minor: 120000 }], grand_total_minor: 120000 },
        warnings: [], blocking_questions: [],
      }),
      "GET /api/v1/products/": () => jsonResponse({
        results: [{ id: "product1", name: "Shirt", base_unit: "PIECE", packs: [{ id: "pack1" }] }],
      }),
      "GET /api/v1/parties/": () => jsonResponse({ results: [] }),
    }));

    renderWithWorkspace(<AssistantHarness />, workspaceWithRole("CASHIER"));
    await user.click(screen.getByRole("button", { name: "Open assistant" }));

    expect(screen.getByRole("button", { name: /Scan sale receipt/i })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Attach a sale receipt" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Photograph a sale receipt" })).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: /Scan bill/i })).not.toBeInTheDocument();
    const cameraInput = screen.getByLabelText("Receipt camera") as HTMLInputElement;
    const openCamera = vi.spyOn(cameraInput, "click");
    await user.click(screen.getByRole("button", { name: "Photograph a sale receipt" }));
    expect(openCamera).toHaveBeenCalled();
    await user.upload(screen.getByLabelText("Receipt file"), file);

    expect(await screen.findByRole("heading", { name: "Sale" })).toBeInTheDocument();
  });

  it("rejects cashier OCR purchase proposals without exposing supplier review controls", async () => {
    const user = userEvent.setup();
    const file = new File([new Uint8Array([1, 2, 3])], "purchase.pdf", { type: "application/pdf" });
    const fetchMock = mockApi({
      "POST /api/v1/assistant/attachments/upload/": () => jsonResponse({ id: "attachment1", kind: "IMAGE", mime: "application/pdf", size_bytes: file.size, status: "READY" }, 201),
      "POST /api/v1/assistant/proposals/from-image/": () => jsonResponse({
        id: "proposal1", version: 1, status: "DRAFT", command_type: "UNSUPPORTED", content: "", payload: {},
        blocking_questions: ["Your image or PDF is being read."],
      }, 201),
      "GET /api/v1/assistant/proposals/proposal1/": () => jsonResponse({
        id: "proposal1", version: 2, status: "READY", command_type: "PURCHASE", content: "Bought fabric",
        payload: { supplier_id: "vendor1", lines: [{ pack_id: "pack1", quantity: "1", unit_cost_minor: 400000 }], grand_total_minor: 400000 },
        warnings: [], blocking_questions: [],
      }),
      "GET /api/v1/products/": () => jsonResponse({
        results: [{ id: "product1", name: "Fabric", base_unit: "METRE", packs: [{ id: "pack1" }] }],
      }),
      "GET /api/v1/parties/": () => jsonResponse({
        results: [{ id: "vendor1", name: "Sharma Suppliers", kind: "SUPPLIER" }],
      }),
      "POST /api/v1/assistant/proposals/proposal1/cancel/": () => jsonResponse({ id: "proposal1", status: "CANCELLED" }),
    });
    vi.stubGlobal("fetch", fetchMock);

    renderWithWorkspace(<AssistantHarness />, workspaceWithRole("CASHIER"));
    await user.click(screen.getByRole("button", { name: "Open assistant" }));
    await user.upload(screen.getByLabelText("Receipt file"), file);

    expect(await screen.findByText(/Cashiers can scan sale receipts only/i)).toBeInTheDocument();
    expect(screen.queryByRole("heading", { name: "Purchase" })).not.toBeInTheDocument();
    expect(screen.queryByText("Sharma Suppliers")).not.toBeInTheDocument();
    expect(fetchMock.mock.calls.some(([input]) => String(input).endsWith("/proposal1/cancel/"))).toBe(true);
  });

  it("shows a terminal OCR error instead of leaving the receipt in progress", async () => {
    const user = userEvent.setup();
    const file = new File([new Uint8Array([1, 2, 3])], "blank.png", { type: "image/png" });
    vi.stubGlobal("fetch", mockApi({
      "POST /api/v1/assistant/attachments/upload/": () => jsonResponse({ id: "attachment1", kind: "IMAGE", mime: "image/png", size_bytes: file.size, status: "READY" }, 201),
      "POST /api/v1/assistant/proposals/from-image/": () => jsonResponse({
        id: "proposal1", version: 1, status: "DRAFT", command_type: "UNSUPPORTED", content: "", payload: {},
        blocking_questions: ["Your image or PDF is being read."],
      }, 201),
      "GET /api/v1/assistant/proposals/proposal1/": () => jsonResponse({
        id: "proposal1", version: 2, status: "DRAFT", command_type: "UNSUPPORTED", content: "", payload: {},
        blocking_questions: ["We couldn't find any text in the image or PDF. Please upload a clearer one."],
      }),
    }));

    renderWithWorkspace(<AssistantHarness />, workspaceWithRole("OWNER"));
    await user.click(screen.getByRole("button", { name: "Open assistant" }));
    await user.upload(screen.getByLabelText("Receipt file"), file);

    expect(await screen.findByText("We couldn't find any text in the image or PDF. Please upload a clearer one.")).toBeInTheDocument();
    expect(screen.queryByText(/Reading .*This can take/i)).not.toBeInTheDocument();
  });
});
