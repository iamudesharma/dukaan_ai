import { useEffect, useRef, useState, type ChangeEvent, type FormEvent } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import {
  AlertTriangle,
  Camera,
  Check,
  ChevronRight,
  LoaderCircle,
  Mic,
  PackageMinus,
  PackagePlus,
  Paperclip,
  ReceiptIndianRupee,
  Sparkles,
  UserRound,
  X,
} from "lucide-react";
import { useWorkspace } from "../../app/WorkspaceContext";
import { cancelProposal, confirmCommand, createProposalFromImage, getProposalRevisions, interpretCommand, listProposals, pollAssistantProposal, reviseCommand, uploadReceiptAttachment } from "../../data/repository";
import { formatMoney } from "../../lib/format";
import { saveOfflineDraft } from "../../lib/offlineDrafts";
import type { WorkspaceAccess } from "../../lib/permissions";
import type { AssistantProposal, EntryKind } from "../../types";
import { StatusBadge } from "../../components/StatusBadge";

const saleExample = "Ramesh bought 3 shirts for ₹2,400, paid ₹1,500, ₹900 pending.";
const purchaseExample = "Bought 2.5 metres from Sharma Suppliers for ₹4,000 each.";

function commandLabel(commandType: AssistantProposal["commandType"]): string {
  switch (commandType) {
    case "SALE": return "Sale";
    case "PURCHASE": return "Purchase";
    case "PAYMENT": return "Payment";
    case "EXPENSE": return "Expense";
    default: return "Entry";
  }
}

function canUseAssistantProposal(proposal: AssistantProposal, access: WorkspaceAccess): boolean {
  switch (proposal.commandType) {
    case "SALE":
      return true;
    case "PURCHASE":
      return access.canRecordPurchases;
    case "EXPENSE":
      return access.canRecordExpenses;
    case "PAYMENT":
      return proposal.paymentDirection === "PAYMENT"
        ? access.canRecordSupplierPayments
        : access.canRecordCustomerReceipts;
    default:
      return false;
  }
}

export function AssistantPanel() {
  const { assistantOpen, closeAssistant, bootstrap, access, locationId } = useWorkspace();
  const [text, setText] = useState("");
  const [proposal, setProposal] = useState<AssistantProposal | null>(null);
  const [editing, setEditing] = useState(false);
  const [success, setSuccess] = useState<string | null>(null);
  const [successKind, setSuccessKind] = useState<EntryKind | null>(null);
  const [offlineMessage, setOfflineMessage] = useState<string | null>(null);
  const [accessError, setAccessError] = useState<string | null>(null);
  const [ocrPhase, setOcrPhase] = useState<"uploading" | "reading" | null>(null);
  const [ocrFileName, setOcrFileName] = useState<string | null>(null);
  const [ocrError, setOcrError] = useState<string | null>(null);
  const inputRef = useRef<HTMLTextAreaElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const cameraInputRef = useRef<HTMLInputElement>(null);
  const ocrAbortRef = useRef<AbortController | null>(null);
  const queryClient = useQueryClient();
  const lookupOptions = {
    customersOnly: access.isCashier,
    includeWholesalePrices: access.canViewWholesalePrices,
  };

  function closePanel() {
    ocrAbortRef.current?.abort();
    closeAssistant();
  }

  const scanReceipt = useMutation({
    mutationFn: async (file: File) => {
      const controller = new AbortController();
      ocrAbortRef.current = controller;
      setOcrPhase("uploading");
      setOcrFileName(file.name);
      const attachment = await uploadReceiptAttachment({ businessId: bootstrap.business.id, file });
      if (attachment.status !== "READY") throw new Error("The receipt upload was not accepted. Please try again.");
      setOcrPhase("reading");
      const pending = await createProposalFromImage({
        attachmentId: attachment.id,
        businessId: bootstrap.business.id,
        locationId,
        lookupOptions,
      });
      const ready = await pollAssistantProposal({
        proposalId: pending.id,
        businessId: bootstrap.business.id,
        locationId,
        lookupOptions,
        signal: controller.signal,
      });
      if (ready.status === "CONFIRMED" || ready.status === "CANCELLED" || ready.status === "EXPIRED" || ready.status === "FAILED") {
        throw new Error("This receipt proposal is no longer open. Please scan it again.");
      }
      if ((ready.commandType === "UNKNOWN" || ready.commandType === "UNSUPPORTED") && ready.questions.length) {
        throw new Error(ready.questions[0]);
      }
      if (!canUseAssistantProposal(ready, access)) {
        await cancelProposal(ready.id, ready.version).catch(() => undefined);
        throw new Error(access.isCashier
          ? "Cashiers can scan sale receipts only. This file was not opened for purchase or expense entry."
          : "This receipt cannot be recorded with your current role.");
      }
      return ready;
    },
    onSuccess: (readyProposal) => {
      setProposal(readyProposal);
      setEditing(false);
      setAccessError(null);
      setOcrError(null);
      confirm.reset();
    },
    onError: (error) => {
      if (ocrAbortRef.current?.signal.aborted || (error instanceof Error && error.name === "AbortError")) return;
      setOcrError(error instanceof Error ? error.message : "We couldn’t read this receipt. Please try again.");
    },
    onSettled: () => {
      setOcrPhase(null);
      setOcrFileName(null);
      ocrAbortRef.current = null;
    },
  });

  const interpret = useMutation({
    mutationFn: (sourceText: string) => proposal
      ? reviseCommand(bootstrap.business.id, proposal, sourceText, lookupOptions)
      : interpretCommand(bootstrap.business.id, locationId, sourceText, lookupOptions),
    onSuccess: (nextProposal) => {
      if (!canUseAssistantProposal(nextProposal, access)) {
        setProposal(null);
        setText("");
        setAccessError(access.isCashier
          ? "Cashiers can only record sales and customer receipts with the assistant."
          : "Your role cannot record this kind of entry.");
        void cancelProposal(nextProposal.id, nextProposal.version).catch(() => undefined);
        return;
      }
      setProposal(nextProposal);
      setEditing(false);
      setAccessError(null);
      confirm.reset();
    },
  });
  const confirm = useMutation({
    mutationFn: (readyProposal: AssistantProposal) => {
      if (!canUseAssistantProposal(readyProposal, access)) {
        throw new Error("Your role cannot record this kind of entry.");
      }
      return confirmCommand(bootstrap.business.id, readyProposal);
    },
    onSuccess: async (entry) => {
      setSuccess(`${entry.number} was recorded successfully.`);
      setSuccessKind(entry.kind);
      await queryClient.invalidateQueries();
    },
  });

  const refresh = useMutation({
    mutationFn: (current: AssistantProposal) => reviseCommand(bootstrap.business.id, current, undefined, lookupOptions),
    onSuccess: (next) => {
      if (!canUseAssistantProposal(next, access)) {
        setProposal(null);
        setAccessError("Your role cannot record this kind of entry.");
        void cancelProposal(next.id, next.version).catch(() => undefined);
        return;
      }
      setProposal(next);
      setAccessError(null);
      confirm.reset();
    },
  });

  const [historyOpen, setHistoryOpen] = useState(false);
  const [history, setHistory] = useState<Awaited<ReturnType<typeof listProposals>>>([]);
  const [revisions, setRevisions] = useState<Awaited<ReturnType<typeof getProposalRevisions>>>([]);
  const cancel = useMutation({
    mutationFn: (current: AssistantProposal) => cancelProposal(current.id, current.version),
    onSuccess: () => { setProposal(null); setText(""); },
  });

  async function loadHistory() {
    setHistoryOpen(true);
    try {
      setHistory(await listProposals());
    } catch {
      setHistory([]);
    }
  }

  async function loadRevisions(current: AssistantProposal) {
    try {
      setRevisions(await getProposalRevisions(current.id));
    } catch {
      setRevisions([]);
    }
  }

  useEffect(() => {
    if (!assistantOpen) return;
    const timer = window.setTimeout(() => inputRef.current?.focus(), 60);
    return () => window.clearTimeout(timer);
  }, [assistantOpen]);

  useEffect(() => {
    if (!assistantOpen) {
      setProposal(null);
      setEditing(false);
      refresh.reset();
      setSuccess(null);
      setSuccessKind(null);
      setOfflineMessage(null);
      setAccessError(null);
      setOcrError(null);
      interpret.reset();
      confirm.reset();
      scanReceipt.reset();
    }
  }, [assistantOpen]);

  useEffect(() => () => ocrAbortRef.current?.abort(), []);

  useEffect(() => {
    ocrAbortRef.current?.abort();
    setProposal(null);
    setEditing(false);
    setSuccess(null);
    setSuccessKind(null);
    setOfflineMessage(null);
    setAccessError(null);
    setOcrError(null);
    setOcrPhase(null);
    setOcrFileName(null);
    setText("");
    interpret.reset();
    confirm.reset();
    refresh.reset();
    scanReceipt.reset();
  }, [access.isCashier, bootstrap.business.id, bootstrap.user.id]);

  if (!assistantOpen) return null;

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (!text.trim() || scanReceipt.isPending) return;
    setOfflineMessage(null);
    setAccessError(null);
    setOcrError(null);
    if (!navigator.onLine) {
      await saveOfflineDraft(
        { userId: bootstrap.user.id, businessId: bootstrap.business.id },
        {
          kind: "assistant",
          locationId,
          content: { sourceText: text.trim() },
        },
      );
      setOfflineMessage("Saved on this device. Review and confirm it after you reconnect.");
      return;
    }
    interpret.mutate(text.trim());
  }

  const location = bootstrap.locations.find((candidate) => candidate.id === locationId);
  const example = access.isCashier ? saleExample : purchaseExample;
  const proposalAllowed = proposal ? canUseAssistantProposal(proposal, access) : false;

  function startReceiptScan(file: File) {
    if (scanReceipt.isPending) return;
    setAccessError(null);
    setOcrError(null);
    if (!navigator.onLine) {
      setOcrError("Reconnect to the internet before scanning a receipt.");
      return;
    }
    ocrAbortRef.current?.abort();
    scanReceipt.mutate(file);
  }

  function selectReceipt(event: ChangeEvent<HTMLInputElement>) {
    const file = event.currentTarget.files?.[0];
    event.currentTarget.value = "";
    if (file) startReceiptScan(file);
  }

  return (
    <div className="assistant-backdrop" role="presentation" onMouseDown={(event) => {
      if (event.currentTarget === event.target) closePanel();
    }}>
      <section className="assistant-panel" role="dialog" aria-modal="true" aria-labelledby="assistant-title">
        <header className="assistant-header">
          <div className="assistant-title-wrap">
            <span className="assistant-glyph"><Sparkles aria-hidden="true" /></span>
            <div>
              <p className="folio-kicker">Ask / Add</p>
              <h2 id="assistant-title">Tell DukaanAI what happened</h2>
            </div>
          </div>
          <button className="icon-button" onClick={closePanel} aria-label="Close assistant"><X /></button>
        </header>

        <div className="assistant-body">
          {(!proposal || !proposalAllowed || editing) && !success ? (
            <>
              <div className="scope-strip">
                <span>Recording at</span>
                <strong>{location?.name}</strong>
                <span className="dot-separator">•</span>
                <span>Nothing changes before you confirm</span>
              </div>
              <form onSubmit={submit}>
                <input
                  ref={fileInputRef}
                  type="file"
                  hidden
                  accept="image/jpeg,image/png,application/pdf"
                  aria-label="Receipt file"
                  onChange={selectReceipt}
                />
                <input
                  ref={cameraInputRef}
                  type="file"
                  hidden
                  accept="image/jpeg,image/png"
                  capture="environment"
                  aria-label="Receipt camera"
                  onChange={selectReceipt}
                />
                <label htmlFor="assistant-command">{access.isCashier ? "Sale or customer receipt" : "Sale, purchase, payment or expense"}</label>
                <div className="assistant-input-wrap">
                  <textarea
                    id="assistant-command"
                    ref={inputRef}
                    value={text}
                    onChange={(event) => setText(event.target.value)}
                    placeholder={access.isCashier ? "Record a sale or customer payment…" : "Type naturally in Hindi, Hinglish or English…"}
                    rows={5}
                    disabled={scanReceipt.isPending}
                  />
                  <div className="assistant-input-actions">
                    <button type="button" className="quiet-icon-button" aria-label={access.isCashier ? "Attach a sale receipt" : "Attach a bill or receipt"} title={access.isCashier ? "Attach a sale receipt" : "Attach a bill or receipt"} disabled={scanReceipt.isPending} onClick={() => fileInputRef.current?.click()}><Paperclip /></button>
                    <button type="button" className="quiet-icon-button" aria-label={access.isCashier ? "Photograph a sale receipt" : "Photograph a bill or receipt"} title={access.isCashier ? "Photograph a sale receipt" : "Photograph a bill or receipt"} disabled={scanReceipt.isPending} onClick={() => cameraInputRef.current?.click()}><Camera /></button>
                    <button type="button" className="quiet-icon-button" aria-label="Speak a command" title="Speak a command"><Mic /></button>
                  </div>
                </div>
                <button type="button" className="example-command" onClick={() => setText(example)}>
                  <span>Try an example</span>
                  <q>{example}</q>
                </button>
                <button className="primary-button full" disabled={!text.trim() || interpret.isPending || scanReceipt.isPending}>
                  {interpret.isPending ? <LoaderCircle className="spin" aria-hidden="true" /> : <Sparkles aria-hidden="true" />}
                  {interpret.isPending ? "Understanding…" : "Review what will be recorded"}
                </button>
              </form>
              {interpret.error ? <p className="form-error" role="alert">{interpret.error.message}</p> : null}
              {accessError ? <p className="form-error" role="alert">{accessError}</p> : null}
              {ocrError ? <p className="form-error" role="alert">{ocrError}</p> : null}
              {ocrPhase ? (
                <div className="warning-card" role="status" aria-live="polite">
                  <LoaderCircle className="spin" aria-hidden="true" />
                  <span>{ocrPhase === "uploading" ? `Uploading ${ocrFileName}…` : `Reading ${ocrFileName}… This can take a few seconds.`}</span>
                </div>
              ) : null}
              {offlineMessage ? <p className="offline-success" role="status">{offlineMessage}</p> : null}
              <div className="capture-options" aria-label="Other ways to add an entry">
                <button type="button"><Mic />Speak<span>Voice command</span></button>
                <button type="button" disabled={scanReceipt.isPending} onClick={() => fileInputRef.current?.click()}><ReceiptIndianRupee />{access.isCashier ? "Scan sale receipt" : "Scan bill"}<span>Photo or PDF</span></button>
                <button type="button"><ChevronRight />Manual<span>Use a form</span></button>
              </div>
              {!access.isCashier ? <button type="button" className="text-button" onClick={() => void loadHistory()}>View past proposals</button> : null}
              {historyOpen ? (
                <div>
                  {history.length ? (
                    <ul>{history.slice(0, 20).map((item) => <li key={item.id}>{item.status} · v{item.version}{item.content ? ` · ${item.content.slice(0, 60)}` : ""}</li>)}</ul>
                  ) : <p className="muted-copy">No past proposals.</p>}
                  <button type="button" className="text-button" onClick={() => setHistoryOpen(false)}>Hide history</button>
                </div>
              ) : null}
            </>
          ) : null}

          {proposal && proposalAllowed && !editing && !success ? (
            <div className="review-content">
              <div className="review-heading">
                <div>
                  <p className="folio-kicker">Review · version {proposal.version}</p>
                  <h3>{commandLabel(proposal.commandType)}</h3>
                </div>
                <StatusBadge tone={proposal.status === "READY" ? "positive" : "warning"}>
                  {proposal.status === "READY" ? "Ready" : "Needs details"}
                </StatusBadge>
              </div>

              <div className="review-party">
                <UserRound aria-hidden="true" />
                <div><span>Party</span><strong>{proposal.partyName ?? "Not identified"}</strong></div>
                {proposal.partyProposedNew ? <StatusBadge tone="warning">New</StatusBadge> : <StatusBadge>Matched</StatusBadge>}
              </div>

              {proposal.commandType === "SALE" || proposal.commandType === "PURCHASE" ? (
                <div className="review-lines">
                  <p className="section-label">Items</p>
                  {proposal.lines.length ? proposal.lines.map((line, index) => (
                    <div className="review-line" key={`${line.productName}-${index}`}>
                      <span className="line-icon">{proposal.commandType === "PURCHASE" ? <PackagePlus aria-hidden="true" /> : <PackageMinus aria-hidden="true" />}</span>
                      <div className="line-main">
                        <strong>{line.productName}</strong>
                        <span>{line.quantity} {line.unit} × {formatMoney(line.unitPriceMinor)}</span>
                      </div>
                      <strong>{formatMoney(line.lineTotalMinor)}</strong>
                    </div>
                  )) : <p className="muted-copy">Add a product before confirming.</p>}
                </div>
              ) : null}

              <dl className="amount-breakdown">
                <div><dt>Total</dt><dd>{formatMoney(proposal.totalMinor)}</dd></div>
                {proposal.taxMinor > 0 ? <div><dt>Included GST</dt><dd>{formatMoney(proposal.taxMinor)}</dd></div> : null}
                <div><dt>Paid now</dt><dd>{formatMoney(proposal.paidMinor)}</dd></div>
                <div className="outstanding"><dt>Pending</dt><dd>{formatMoney(proposal.outstandingMinor)}</dd></div>
              </dl>

              <div className="effects-card">
                <p className="section-label">After confirmation</p>
                {proposal.effects.stock.map((effect) => <p key={effect}>{proposal.commandType === "PURCHASE" ? <PackagePlus aria-hidden="true" /> : <PackageMinus aria-hidden="true" />}{effect}</p>)}
                <p><ReceiptIndianRupee aria-hidden="true" />{proposal.effects.ledger}</p>
              </div>

              {proposal.questions.map((question) => (
                <div className="warning-card" key={question}><AlertTriangle aria-hidden="true" /><span>{question}</span></div>
              ))}
              {proposal.warnings.map((warning) => (
                <div className="warning-card" key={warning}><AlertTriangle aria-hidden="true" /><span>{warning}</span></div>
              ))}

              <div className="review-actions">
                <button type="button" className="secondary-button" disabled={confirm.isPending || refresh.isPending} onClick={() => { setText(proposal.sourceText); setEditing(true); }}>Edit command</button>
                <button
                  type="button"
                  className="primary-button"
                  disabled={!proposalAllowed || proposal.status !== "READY" || confirm.isPending || refresh.isPending}
                  onClick={() => confirm.mutate(proposal)}
                >
                  {confirm.isPending ? <LoaderCircle className="spin" aria-hidden="true" /> : <Check aria-hidden="true" />}
                  {confirm.isPending ? "Recording…" : `Record ${commandLabel(proposal.commandType).toLowerCase()} ${formatMoney(proposal.totalMinor)}`}
                </button>
              </div>
              <button type="button" className="secondary-button" disabled={refresh.isPending || confirm.isPending}
                onClick={() => refresh.mutate(proposal)}>
                {refresh.isPending ? "Refreshing…" : "Refresh and review"}
              </button>
              <div className="review-actions">
                <button type="button" className="text-button" onClick={() => { void loadRevisions(proposal); }}>View revisions{revisions.length ? ` (${revisions.length})` : ""}</button>
                <button type="button" className="text-button" disabled={cancel.isPending} onClick={() => cancel.mutate(proposal)}>{cancel.isPending ? "Cancelling…" : "Cancel proposal"}</button>
              </div>
              {revisions.length ? (
                <ul>{revisions.map((rev) => <li key={rev.version}>v{rev.version} · {rev.createdAt}</li>)}</ul>
              ) : null}
              {cancel.error ? <p className="form-error" role="alert">{cancel.error.message}</p> : null}
              {refresh.error ? <p className="form-error" role="alert">{refresh.error.message}</p> : null}
              {confirm.error ? <p className="form-error" role="alert">{confirm.error.message}</p> : null}
            </div>
          ) : null}

          {success ? (
            <div className="success-state" role="status">
              <span className="success-icon"><Check aria-hidden="true" /></span>
              <p className="folio-kicker">Saved</p>
              <h3>Everything is recorded</h3>
              <p>{success}</p>
              <p className="success-detail">{successKind === "EXPENSE" ? "The expense is now in your entries timeline." : successKind === "PAYMENT_IN" || successKind === "PAYMENT_OUT" ? "The payment and party balance were updated together." : "Stock, payment and outstanding balance were updated together."}</p>
              <button className="primary-button full" onClick={closePanel}>Done</button>
            </div>
          ) : null}
        </div>
      </section>
    </div>
  );
}
