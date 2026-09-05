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
import { confirmCommand, interpretCommand, reviseCommand } from "../../data/repository";
import { formatMoney } from "../../lib/format";
import { saveOfflineDraft } from "../../lib/offlineDrafts";
import type { AssistantProposal } from "../../types";
import { StatusBadge } from "../../components/StatusBadge";

const example = "Ramesh bought 3 shirts for ₹2,400, paid ₹1,500, ₹900 pending.";

export function AssistantPanel() {
  const { assistantOpen, closeAssistant, bootstrap, locationId } = useWorkspace();
  const [text, setText] = useState("");
  const [proposal, setProposal] = useState<AssistantProposal | null>(null);
  const [editing, setEditing] = useState(false);
  const [success, setSuccess] = useState<string | null>(null);
  const [offlineMessage, setOfflineMessage] = useState<string | null>(null);
  const inputRef = useRef<HTMLTextAreaElement>(null);
  const queryClient = useQueryClient();

  const interpret = useMutation({
    mutationFn: (sourceText: string) => proposal
      ? reviseCommand(bootstrap.business.id, proposal, sourceText)
      : interpretCommand(bootstrap.business.id, locationId, sourceText),
    onSuccess: (nextProposal) => { setProposal(nextProposal); setEditing(false); confirm.reset(); },
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
      interpret.reset();
      confirm.reset();
    }
  }, [assistantOpen]);

  if (!assistantOpen) return null;

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (!text.trim()) return;
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
    interpret.mutate(text.trim());
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
                    <button type="button" className="quiet-icon-button" aria-label="Attach a bill or receipt" title="Attach a bill or receipt"><Paperclip /></button>
                    <button type="button" className="quiet-icon-button" aria-label="Speak a command" title="Speak a command"><Mic /></button>
                  </div>
                </div>
                <button type="button" className="example-command" onClick={() => setText(example)}>
                  <span>Try an example</span>
                  <q>{example}</q>
                </button>
                <button className="primary-button full" disabled={!text.trim() || interpret.isPending}>
                  {interpret.isPending ? <LoaderCircle className="spin" aria-hidden="true" /> : <Sparkles aria-hidden="true" />}
                  {interpret.isPending ? "Understanding…" : "Review what will be recorded"}
                </button>
              </form>
              {interpret.error ? <p className="form-error" role="alert">{interpret.error.message}</p> : null}
              {offlineMessage ? <p className="offline-success" role="status">{offlineMessage}</p> : null}
              <div className="capture-options" aria-label="Other ways to add an entry">
                <button type="button"><Mic />Speak<span>Voice command</span></button>
                <button type="button"><ReceiptIndianRupee />Scan bill<span>Photo or PDF</span></button>
                <button type="button"><ChevronRight />Manual<span>Use a form</span></button>
              </div>
            </>
          ) : null}

          {proposal && !editing && !success ? (
            <div className="review-content">
              <div className="review-heading">
                <div>
                  <p className="eyebrow">Review version {proposal.version}</p>
                  <h3>{proposal.intent === "RECORD_SALE" ? "Sale" : proposal.intent.replaceAll("_", " ").toLowerCase()}</h3>
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
                  {confirm.isPending ? "Recording…" : `Record sale ${formatMoney(proposal.totalMinor)}`}
                </button>
              </div>
              <button type="button" className="secondary-button" disabled={refresh.isPending || confirm.isPending}
                onClick={() => refresh.mutate(proposal)}>
                {refresh.isPending ? "Refreshing…" : "Refresh and review"}
              </button>
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
