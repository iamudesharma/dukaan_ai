import { afterEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { CsvImportPanel } from "./CsvImportPanel";
import { TestProviders } from "../../test/TestProviders";
import { jsonResponse, mockApi, requestBody } from "../../test/apiMocks";

afterEach(() => vi.unstubAllGlobals());

describe("CsvImportPanel", () => {
  it("requires dry-run, preparation, and an explicit confirmation before reporting success", async () => {
    const user = userEvent.setup();
    const onChanged = vi.fn(async () => undefined);
    const fetchMock = mockApi({
      "POST /api/v1/imports/products/": (init) => {
        const body = init?.body as FormData;
        if (body.get("dry_run") === "true") {
          return jsonResponse({
            dry_run: true, kind: "PRODUCT", duplicate_strategy: "UPDATE",
            row_count: 1, valid_row_count: 1, error_count: 0,
            created_count: 1, updated_count: 0, skipped_count: 0,
            errors: [], preview: [{ row: 2, action: "CREATE" }],
          });
        }
        return jsonResponse({
          id: "job1", business: "b1", kind: "PRODUCT", status: "READY", duplicate_strategy: "UPDATE",
          row_count: 1, valid_row_count: 1, error_count: 0, created_count: 0, updated_count: 0, skipped_count: 0,
          errors: [], original_filename: "products.csv",
        }, 201);
      },
      "POST /api/v1/imports/job1/confirm/": () => jsonResponse({
        replayed: false,
        job: {
          id: "job1", business: "b1", kind: "PRODUCT", status: "COMPLETED", duplicate_strategy: "UPDATE",
          row_count: 1, valid_row_count: 1, error_count: 0, created_count: 1, updated_count: 0, skipped_count: 0,
          errors: [], original_filename: "products.csv",
        },
      }),
    });
    vi.stubGlobal("fetch", fetchMock);

    render(<TestProviders><CsvImportPanel businessId="b1" initialKind="PRODUCT" canImport onClose={vi.fn()} onChanged={onChanged} /></TestProviders>);
    const fileInput = screen.getByLabelText("CSV file") as HTMLInputElement;
    fireEvent.change(fileInput, { target: { files: [new File(["name\nShirt\n"], "products.csv", { type: "text/csv" })] } });
    expect(fileInput.files?.[0]?.name).toBe("products.csv");
    expect(fileInput.checkValidity()).toBe(true);
    await user.click(screen.getByRole("button", { name: "Review CSV" }));

    expect(await screen.findByText("Dry-run preview")).toBeInTheDocument();
    expect(fetchMock).toHaveBeenCalledTimes(1);
    expect(screen.queryByRole("button", { name: "Confirm import" })).not.toBeInTheDocument();
    expect(onChanged).not.toHaveBeenCalled();

    await user.click(screen.getByRole("button", { name: "Prepare import" }));
    expect(await screen.findByText("Snapshot prepared")).toBeInTheDocument();
    expect(fetchMock).toHaveBeenCalledTimes(2);
    expect(onChanged).not.toHaveBeenCalled();

    await user.click(screen.getByRole("button", { name: "Confirm import" }));
    expect(await screen.findByText("Import confirmed")).toBeInTheDocument();
    expect(onChanged).toHaveBeenCalledTimes(1);
    const confirmCall = fetchMock.mock.calls.find(([input]) => String(input).endsWith("/api/v1/imports/job1/confirm/"));
    expect(requestBody(confirmCall?.[1])).toEqual({ idempotency_key: "import-job1" });
  });

  it("shows row errors and blocks preparation when the dry run is invalid", async () => {
    const user = userEvent.setup();
    const fetchMock = mockApi({
      "POST /api/v1/imports/parties/": () => jsonResponse({
        dry_run: true, kind: "PARTY", duplicate_strategy: "UPDATE",
        row_count: 1, valid_row_count: 0, error_count: 1, created_count: 0, updated_count: 0, skipped_count: 0,
        errors: [{ row: 2, errors: { kind: ["Must be CUSTOMER, SUPPLIER, or BOTH."] } }], preview: [],
      }),
    });
    vi.stubGlobal("fetch", fetchMock);

    render(<TestProviders><CsvImportPanel businessId="b1" initialKind="PARTY" canImport onClose={vi.fn()} onChanged={vi.fn()} /></TestProviders>);
    const fileInput = screen.getByLabelText("CSV file") as HTMLInputElement;
    fireEvent.change(fileInput, { target: { files: [new File(["name,kind\nRamesh,UNKNOWN\n"], "parties.csv", { type: "text/csv" })] } });
    expect(fileInput.files?.[0]?.name).toBe("parties.csv");
    expect(fileInput.checkValidity()).toBe(true);
    await user.click(screen.getByRole("button", { name: "Review CSV" }));

    expect(await screen.findByText("Fix these CSV rows before continuing")).toBeInTheDocument();
    expect(screen.getByText(/Must be CUSTOMER/)).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Prepare import" })).toBeDisabled();
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it("does not render or upload for a cashier", () => {
    const fetchMock = mockApi({});
    vi.stubGlobal("fetch", fetchMock);
    render(<TestProviders><CsvImportPanel businessId="b1" initialKind="PRODUCT" canImport={false} onClose={vi.fn()} onChanged={vi.fn()} /></TestProviders>);
    expect(screen.queryByRole("heading", { name: /Import products/ })).not.toBeInTheDocument();
    expect(fetchMock).not.toHaveBeenCalled();
  });
});
