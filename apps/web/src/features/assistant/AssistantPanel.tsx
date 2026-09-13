import { useEffect, useRef, useState, type FormEvent } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import {
  AlertTriangle,
  Check,
  ChevronRight,
  LoaderCircle,
  Mic,
  PackageMinus,
  Paperclip,
  ReceiptIndianRupee,
  Sparkles,
  UserRound,
  X,
} from "lucide-react";
import { useWorkspace } from "../../app/WorkspaceContext";
import { cancelProposal, confirmCommand, getProposalRevisions, interpretCommand, listProposals, pollProposal, reviseCommand, uploadAttachment } from "../../data/repository";
import { formatMoney } from "../../lib/format";
import { saveOfflineDraft } from "../../lib/offlineDrafts";
import type { AssistantProposal } from "../../types";
import { StatusBadge } from "../../components/StatusBadge";

const example = "Ramesh bought 3 shirts for ₹2,400, paid ₹1,500, ₹900 pending.";

function intentLabel(intent: AssistantProposal["intent"]): string {
  switch (intent) {
    case "RECORD_PURCHASE":
      return "Purchase";
    case "RECORD_PAYMENT":
      return "Payment";
    case "RECORD_EXPENSE":
      return "Expense";
    default:
      return "Sale";
  }
}

export function AssistantPanel() {
  const { assistantOpen, closeAssistant, bootstrap, locationId, openManualSale } = useWorkspace();
  const [text, setText] = useState("");
  const [proposal, setProposal] = useState<AssistantProposal | null>(null);
  const [editing, setEditing] = useState(false);
  const [success, setSuccess] = useState<string | null>(null);
  const [offlineMessage, setOfflineMessage] = useState<string | null>(null);
  const [polling, setPolling] = useState(false);
  const [attachedFiles, setAttachedFiles] = useState<Array<{ id: string; name: string }>>([]);
  const [uploadState, setUploadState] = useState<"idle" | "working" | "error">("idle");
  const inputRef = useRef<HTMLTextAreaElement>(null);
  const fileRef = useRef<HTMLInputElement>(null);
  const queryClient = useQueryClient();

  const interpret = useMutation({
    mutationFn: (sourceText: string) => proposal
      ? reviseCommand(bootstrap.business.id, proposal, sourceText)
      : interpretCommand(bootstrap.business.id, locationId, sourceText),
    onSuccess: (nextProposal) => { setProposal(nextProposal); setEditing(false); confirm.reset(); },
  });
  const interpretMedia = useMutation({
    mutationFn: async ({ files, note }: { files: Array<{ id: string; name: string }>; note: string }) => {
      const kind = files.some((file) => /\.(mp3|m4a|wav|ogg|webm)$/i.test(file.name)) ? "VOICE" : "IMAGE";
      return interpretCommand(bootstrap.business.id, locationId, note, {
        inputType: kind,
        attachmentIds: files.map((file) => file.id),
      });
    },
    onSuccess: async (nextProposal) => {
      setProposal(nextProposal);
      setEditing(false);
      confirm.reset();
      setAttachedFiles([]);
      if (nextProposal.status === "PROCESSING") {
        setPolling(true);
        try {
          const ready = await pollProposal(
            bootstrap.business.id,
            locationId,
            nextProposal.sourceText,
            nextProposal.id,
          );
          setProposal(ready);
        } catch {
          // The proposal stays visible; the user can refresh it manually.
        } finally {
          setPolling(false);
        }
      }
    },
  });
  const confirm = useMutation({
    mutationFn: (readyProposal: AssistantProposal) => confirmCommand(bootstrap.business.id, readyProposal),
    onSuccess: async (entry) => {
      setSuccess(`${entry.number} was recorded successfully.`);
      await queryClient.invalidateQueries();
    },
  });

  const refresh = useMutation({
    mutationFn: (current: AssistantProposal) => reviseCommand(bootstrap.business.id, current),
    onSuccess: (next) => { setProposal(next); confirm.reset(); },
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
      setOfflineMessage(null);
      setAttachedFiles([]);
      setUploadState("idle");
      setPolling(false);
      interpret.reset();
      interpretMedia.reset();
      confirm.reset();
    }
  }, [assistantOpen]);

  if (!assistantOpen) return null;

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (!text.trim() && !attachedFiles.length) return;
    setOfflineMessage(null);
    if (!navigator.onLine) {
      await saveOfflineDraft({
        kind: "assistant",
        locationId,
        content: { sourceText: text.trim() },
      });
      setOfflineMessage("Saved on this device. Review and confirm it after you reconnect.");
      return;
    }
    if (attachedFiles.length) {
      interpretMedia.mutate({ files: attachedFiles, note: text.trim() });
      return;
    }
    interpret.mutate(text.trim());
  }

  async function attachFiles(files: FileList | null) {
    if (!files?.length) return;
    setUploadState("working");
    try {
      const uploaded: Array<{ id: string; name: string }> = [];
      for (const file of Array.from(files).slice(0, 5)) {
        const attachment = await uploadAttachment(bootstrap.business.id, file);
        uploaded.push({ id: attachment.id, name: attachment.originalName ?? file.name });
      }
      setAttachedFiles((current) => [...current, ...uploaded]);
      setUploadState("idle");
    } catch {
      setUploadState("error");
    }
  }

  const location = bootstrap.locations.find((candidate) => candidate.id === locationId);

  return (
    <div className="assistant-backdrop" role="presentation" onMouseDown={(event) => {
      if (event.currentTarget === event.target) closeAssistant();
    }}>
      <section className="assistant-panel" role="dialog" aria-modal="true" aria-labelledby="assistant-title">
        <header className="assistant-header">
          <div className="assistant-title-wrap">
            <span className="assistant-glyph"><Sparkles aria-hidden="true" /></span>
            <div>
              <p className="eyebrow">Ask / Add</p>
              <h2 id="assistant-title">Tell DukaanAI what happened</h2>
            </div>
          </div>
          <button className="icon-button" onClick={closeAssistant} aria-label="Close assistant"><X /></button>
        </header>

        <div className="assistant-body">
          {(!proposal || editing) && !success ? (
            <>
              <div className="scope-strip">
                <span>Recording at</span>
                <strong>{location?.name}</strong>
                <span className="dot-separator">•</span>
                <span>Nothing changes before you confirm</span>
              </div>
              <form onSubmit={submit}>
                <label htmlFor="assistant-command">Sale, purchase, payment or expense</label>
                <div className="assistant-input-wrap">
                  <textarea
                    id="assistant-command"
                    ref={inputRef}
                    value={text}
                    onChange={(event) => setText(event.target.value)}
                    placeholder="Type naturally in Hindi, Hinglish or English…"
                    rows={5}
                  />
                  <div className="assistant-input-actions">
                    <button type="button" className="quiet-icon-button" aria-label="Attach a bill or receipt" title="Attach a bill or receipt (photo, PDF, audio)" onClick={() => fileRef.current?.click()}><Paperclip /></button>
                    <input
                      ref={fileRef}
                      type="file"
                      className="sr-only"
                      multiple
                      accept="image/jpeg,image/png,image/webp,application/pdf,audio/mpeg,audio/mp4,audio/wav,audio/ogg,audio/webm"
                      aria-label="Attach a bill or receipt"
                      onChange={(event) => { void attachFiles(event.target.files); event.target.value = ""; }}
                    />
                    <button type="button" className="quiet-icon-button" aria-label="Speak a command" title="Speak a command"><Mic /></button>
                  </div>
                </div>
                {attachedFiles.length ? (
                  <ul className="attached-list" aria-label="Attached bills">
                    {attachedFiles.map((file) => (
                      <li key={file.id}>
                        <Paperclip aria-hidden="true" />
                        <span>{file.name}</span>
                        <button type="button" className="text-button" aria-label={`Remove ${file.name}`} onClick={() => setAttachedFiles((current) => current.filter((item) => item.id !== file.id))}>Remove</button>
                      </li>
                    ))}
                  </ul>
                ) : null}
                {uploadState === "working" ? <p role="status">Uploading bill…</p> : null}
                {uploadState === "error" ? <p className="form-error" role="alert">Photos, PDFs and audio under 10 MB are supported.</p> : null}
                <button type="button" className="example-command" onClick={() => setText(example)}>
                  <span>Try an example</span>
                  <q>{example}</q>
                </button>
                <button className="primary-button full" disabled={(!text.trim() && !attachedFiles.length) || interpret.isPending || interpretMedia.isPending || uploadState === "working"}>
                  {interpret.isPending || interpretMedia.isPending ? <LoaderCircle className="spin" aria-hidden="true" /> : <Sparkles aria-hidden="true" />}
                  {interpret.isPending || interpretMedia.isPending ? "Understanding…" : "Review what will be recorded"}
                </button>
              </form>
              {interpret.error ? <p className="form-error" role="alert">{interpret.error.message}</p> : null}
              {interpretMedia.error ? <p className="form-error" role="alert">{interpretMedia.error.message}</p> : null}
              {offlineMessage ? <p className="offline-success" role="status">{offlineMessage}</p> : null}
              <div className="capture-options" aria-label="Other ways to add an entry">
                <button type="button"><Mic />Speak<span>Voice command</span></button>
                <button type="button" onClick={() => fileRef.current?.click()}><ReceiptIndianRupee />Scan bill<span>Photo or PDF</span></button>
                <button type="button" onClick={() => { closeAssistant(); openManualSale(); }}><ChevronRight />Manual<span>Use a form</span></button>
              </div>
              <button type="button" className="text-button" onClick={() => void loadHistory()}>View past proposals</button>
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

          {proposal && !editing && !success ? (
            <div className="review-content">
              <div className="review-heading">
                <div>
                  <p className="eyebrow">Review version {proposal.version}</p>
                  <h3>{intentLabel(proposal.intent)}</h3>
                </div>
                <StatusBadge tone={proposal.status === "READY" ? "positive" : "warning"}>
                  {proposal.status === "READY" ? "Ready" : proposal.status === "PROCESSING" ? "Reading…" : "Needs details"}
                </StatusBadge>
              </div>
              {polling ? <p role="status">Reading the attached bill… the review appears automatically.</p> : null}
              {(proposal.attachments ?? []).length ? (
                <p className="field-note">
                  From {proposal.attachments!.map((file) => file.name).join(", ")} — verify the amounts before recording.
                </p>
              ) : null}

              <div className="review-party">
                <UserRound aria-hidden="true" />
                <div><span>Party</span><strong>{proposal.partyName ?? "Not identified"}</strong></div>
                {proposal.partyProposedNew ? <StatusBadge tone="warning">New</StatusBadge> : <StatusBadge>Matched</StatusBadge>}
              </div>

              <div className="review-lines">
                <p className="section-label">Items</p>
                {proposal.lines.length ? proposal.lines.map((line, index) => (
                  <div className="review-line" key={`${line.productName}-${index}`}>
                    <span className="line-icon"><PackageMinus aria-hidden="true" /></span>
                    <div className="line-main">
                      <strong>{line.productName}</strong>
                      <span>{line.quantity} {line.unit} × {formatMoney(line.unitPriceMinor)}</span>
                    </div>
                    <strong>{formatMoney(line.lineTotalMinor)}</strong>
                  </div>
                )) : <p className="muted-copy">Add a product before confirming.</p>}
              </div>

              <dl className="amount-breakdown">
                <div><dt>Total</dt><dd>{formatMoney(proposal.totalMinor)}</dd></div>
                {proposal.taxMinor > 0 ? <div><dt>Included GST</dt><dd>{formatMoney(proposal.taxMinor)}</dd></div> : null}
                <div><dt>Paid now</dt><dd>{formatMoney(proposal.paidMinor)}</dd></div>
                <div className="outstanding"><dt>Pending</dt><dd>{formatMoney(proposal.outstandingMinor)}</dd></div>
              </dl>

              <div className="effects-card">
                <p className="section-label">After confirmation</p>
                {proposal.effects.stock.map((effect) => <p key={effect}><PackageMinus aria-hidden="true" />{effect}</p>)}
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
                  disabled={proposal.status !== "READY" || confirm.isPending || refresh.isPending}
                  onClick={() => confirm.mutate(proposal)}
                >
                  {confirm.isPending ? <LoaderCircle className="spin" aria-hidden="true" /> : <Check aria-hidden="true" />}
                  {confirm.isPending ? "Recording…" : `Record ${intentLabel(proposal.intent).toLowerCase()} ${formatMoney(proposal.totalMinor)}`}
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
              <p className="eyebrow">Saved</p>
              <h3>Everything is recorded</h3>
              <p>{success}</p>
              <p className="success-detail">Stock, payment and outstanding balance were updated together.</p>
              <button className="primary-button full" onClick={closeAssistant}>Done</button>
            </div>
          ) : null}
        </div>
      </section>
    </div>
  );
}
