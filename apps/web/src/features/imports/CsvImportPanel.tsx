import { useEffect, useRef, useState, type FormEvent } from "react";
import { useMutation } from "@tanstack/react-query";
import { CheckCircle2, FileSpreadsheet, LoaderCircle, Upload, X } from "lucide-react";
import {
  confirmCsvImport,
  createCsvImportJob,
  dryRunCsvImport,
  MAX_CSV_BYTES,
} from "../../data/repository";
import type {
  CsvImportDryRun,
  ImportConfirmation,
  ImportDuplicateStrategy,
  ImportJob,
  ImportKind,
  ImportRowError,
} from "../../types";
import { StatusBadge } from "../../components/StatusBadge";

interface Props {
  businessId: string;
  initialKind: ImportKind;
  canImport: boolean;
  onClose: () => void;
  onChanged: () => void | Promise<unknown>;
}

const kindLabel: Record<ImportKind, string> = { PRODUCT: "products", PARTY: "parties" };

function errorFieldLabel(field: string): string {
  return field.replace(/([a-z])([A-Z])/g, "$1 $2").replaceAll("_", " ");
}

function ImportErrors({ errors }: { errors: ImportRowError[] }) {
  const errorSummary = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (errors.length) errorSummary.current?.focus();
  }, [errors]);
  if (!errors.length) return null;
  return (
    <div ref={errorSummary} className="import-errors" role="alert" tabIndex={-1} aria-labelledby="import-error-title">
      <h3 id="import-error-title">Fix these CSV rows before continuing</h3>
      <p>{errors.length} {errors.length === 1 ? "row has" : "rows have"} validation errors. Nothing has been imported.</p>
      <ul>
        {errors.map((error) => (
          <li key={`${error.row}-${Object.keys(error.errors).join("-")}`}>
            <strong>Row {error.row}</strong>
            <ul>{Object.entries(error.errors).map(([field, messages]) => (
              <li key={field}><span>{field === "_row" ? "CSV structure" : errorFieldLabel(field)}</span>: {messages.join(" ")}</li>
            ))}</ul>
          </li>
        ))}
      </ul>
    </div>
  );
}

function ImportSummary({ value }: { value: CsvImportDryRun | ImportJob | ImportConfirmation["job"] }) {
  return (
    <dl className="import-summary">
      <div><dt>Rows</dt><dd>{value.rowCount}</dd></div>
      <div><dt>Valid</dt><dd>{value.validRowCount}</dd></div>
      <div><dt>Create</dt><dd>{value.createdCount}</dd></div>
      <div><dt>Update</dt><dd>{value.updatedCount}</dd></div>
      <div><dt>Skip</dt><dd>{value.skippedCount}</dd></div>
      <div><dt>Errors</dt><dd>{value.errorCount}</dd></div>
    </dl>
  );
}

export function CsvImportPanel({ businessId, initialKind, canImport, onClose, onChanged }: Props) {
  const [kind, setKind] = useState<ImportKind>(initialKind);
  const [file, setFile] = useState<File | null>(null);
  const [duplicateStrategy, setDuplicateStrategy] = useState<ImportDuplicateStrategy>("UPDATE");
  const [preview, setPreview] = useState<CsvImportDryRun | null>(null);
  const [job, setJob] = useState<ImportJob | null>(null);
  const [confirmation, setConfirmation] = useState<ImportConfirmation | null>(null);

  const review = useMutation({
    mutationFn: () => {
      if (!canImport) throw new Error("Only an owner or manager can import catalog CSV files.");
      if (!file) throw new Error("Choose a CSV file first.");
      return dryRunCsvImport({ businessId, kind, file, duplicateStrategy });
    },
    onSuccess: (result) => {
      setPreview(result);
      setJob(null);
      setConfirmation(null);
    },
  });

  const prepare = useMutation({
    mutationFn: () => {
      if (!canImport) throw new Error("Only an owner or manager can import catalog CSV files.");
      if (!file) throw new Error("Choose a CSV file first.");
      return createCsvImportJob({ businessId, kind, file, duplicateStrategy });
    },
    onSuccess: setJob,
  });

  const confirm = useMutation({
    mutationFn: () => {
      if (!canImport) throw new Error("Only an owner or manager can confirm imports.");
      if (!job) throw new Error("Prepare the import before confirming it.");
      return confirmCsvImport(job.id);
    },
    onSuccess: async (result) => {
      setConfirmation(result);
      await onChanged();
    },
  });

  function sourceChanged() {
    setPreview(null);
    setJob(null);
    setConfirmation(null);
    review.reset();
    prepare.reset();
    confirm.reset();
  }

  function submitReview(event: FormEvent) {
    event.preventDefault();
    review.mutate();
  }

  function reset() {
    setFile(null);
    sourceChanged();
  }

  if (!canImport) return null;

  const displayedErrors = confirmation?.job.errors ?? job?.errors ?? preview?.errors ?? [];
  const busy = review.isPending || prepare.isPending || confirm.isPending;

  return (
    <section className="panel import-panel" aria-label={`Import ${kindLabel[kind]} CSV`}>
      <header className="panel-heading simple">
        <div><p className="folio-kicker">Reviewed before written</p><h2>Import {kindLabel[kind]} from CSV</h2><p>Dry-run first, prepare a snapshot, then explicitly confirm the catalog changes.</p></div>
        <button type="button" className="icon-button" aria-label="Close CSV import" onClick={onClose}><X /></button>
      </header>

      {confirmation ? (
        <div className="import-complete" role="status">
          <CheckCircle2 aria-hidden="true" />
          <h3>Import confirmed</h3>
          <p>{confirmation.replayed ? "This confirmation was safely replayed." : "The validated snapshot has been applied to your catalog."}</p>
          <ImportSummary value={confirmation.job} />
          <div className="review-actions"><button type="button" className="secondary-button" onClick={reset}>Import another file</button><button type="button" className="primary-button" onClick={onClose}>Done</button></div>
        </div>
      ) : (
        <>
          <form className="manual-form import-form" onSubmit={submitReview}>
            <div className="two-fields">
              <label>Import type<select value={kind} disabled={busy || Boolean(preview)} onChange={(event) => { setKind(event.target.value as ImportKind); sourceChanged(); }}><option value="PRODUCT">Products</option><option value="PARTY">Parties</option></select></label>
              <label>Existing matches<select value={duplicateStrategy} disabled={busy || Boolean(preview)} onChange={(event) => { setDuplicateStrategy(event.target.value as ImportDuplicateStrategy); sourceChanged(); }}><option value="UPDATE">Update existing rows</option><option value="SKIP">Skip existing rows</option></select></label>
            </div>
            <label>CSV file<input type="file" accept=".csv,text/csv" disabled={busy || Boolean(preview)} onChange={(event) => { setFile(event.target.files?.[0] ?? null); sourceChanged(); }} /></label>
            <p className="field-note">UTF-8 CSV, up to {Math.round(MAX_CSV_BYTES / 1024 / 1024)} MB and 5,000 data rows. The server validates every row.</p>
            <details className="csv-template"><summary>Accepted CSV columns</summary><code>{kind === "PRODUCT" ? "name,sku,base_unit,hsn_sac,gst_bps,low_stock_threshold,pack_name,pack_conversion,retail_price_minor,wholesale_price_minor" : "name,kind,phone,gstin,state,address"}</code><p>{kind === "PRODUCT" ? "Only name is required. If you use pack columns, include all four pack columns together. Prices are in paise." : "Name and kind are required. Kind must be CUSTOMER, SUPPLIER, or BOTH. Phone must include the country code."}</p></details>
            <div className="review-actions"><button type="button" className="secondary-button" onClick={onClose}>Cancel</button><button type="submit" className="primary-button" disabled={!file || busy}>{review.isPending ? <LoaderCircle className="spin" /> : <Upload />}{review.isPending ? "Reviewing…" : preview ? "Review again" : "Review CSV"}</button></div>
          </form>
          {review.error ? <p className="form-error" role="alert">{review.error.message}</p> : null}

          {preview ? (
            <div className="import-review" aria-live="polite">
              <div className="panel-heading simple"><div><h3>Dry-run preview</h3><p>No job or catalog row was written. Counts show the planned changes for {file?.name}.</p></div><StatusBadge tone={preview.errorCount ? "danger" : "positive"}>{preview.errorCount ? `${preview.errorCount} errors` : "Ready to prepare"}</StatusBadge></div>
              <ImportSummary value={preview} />
              <ImportErrors errors={displayedErrors} />
              {preview.preview.length ? (
                <div className="table-scroll"><table><caption className="sr-only">Planned action for each valid CSV row</caption><thead><tr><th>CSV row</th><th>Planned action</th></tr></thead><tbody>{preview.preview.slice(0, 100).map((row) => <tr key={row.row}><td>{row.row}</td><td><StatusBadge tone={row.action === "CREATE" ? "positive" : row.action === "UPDATE" ? "warning" : "neutral"}>{row.action === "CREATE" ? "Create" : row.action === "UPDATE" ? "Update" : "Skip"}</StatusBadge></td></tr>)}</tbody></table></div>
              ) : null}
              {preview.preview.length > 100 ? <p className="field-note">Showing the first 100 planned rows. All {preview.validRowCount} valid rows are included in the prepared snapshot.</p> : null}
              {!job ? (
                <div className="review-callout"><FileSpreadsheet aria-hidden="true" /><div><strong>Next: prepare the validated snapshot</strong><p>This saves the normalized rows for confirmation but still does not change products or parties.</p></div></div>
              ) : null}
              {job ? (
                <div className="prepared-import">
                  <div className="panel-heading simple"><div><h3>Snapshot prepared</h3><p>Job {job.id} · {job.originalFilename}</p></div><StatusBadge tone={job.status === "READY" ? "positive" : "danger"}>{job.status === "READY" ? "Ready to confirm" : job.status}</StatusBadge></div>
                  <ImportErrors errors={job.errors} />
                  <p className="field-note">Preview counts are estimates. The server recomputes final create, update, and skip counts when you confirm.</p>
                </div>
              ) : null}
              <div className="review-actions">
                <button type="button" className="secondary-button" disabled={busy} onClick={reset}>Choose another file</button>
                {!job ? <button type="button" className="secondary-button" disabled={busy || preview.errorCount > 0 || preview.validRowCount === 0} onClick={() => prepare.mutate()}>{prepare.isPending ? <LoaderCircle className="spin" /> : <FileSpreadsheet />}{prepare.isPending ? "Preparing…" : "Prepare import"}</button> : null}
                {job ? <button type="button" className="primary-button" disabled={busy || job.status !== "READY" || job.errorCount > 0} onClick={() => confirm.mutate()}>{confirm.isPending ? <LoaderCircle className="spin" /> : <CheckCircle2 />}{confirm.isPending ? "Confirming…" : "Confirm import"}</button> : null}
              </div>
            </div>
          ) : null}
          {prepare.error ? <p className="form-error" role="alert">{prepare.error.message}</p> : null}
          {confirm.error ? <p className="form-error" role="alert">{confirm.error.message}</p> : null}
        </>
      )}
    </section>
  );
}
