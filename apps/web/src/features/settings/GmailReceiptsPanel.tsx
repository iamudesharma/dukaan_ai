import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Check, FileText, Link2, LoaderCircle, Mail, Unplug } from "lucide-react";
import { connectGmail, disconnectGmail, getGmailMessages, getGmailStatus, importGmailReceipt } from "../../data/repository";
import type { GmailImportResult } from "../../types";
import { LoadingBlock } from "../../components/LoadingBlock";
import { StatusBadge } from "../../components/StatusBadge";
import { formatDateTime, formatKind, formatMoney } from "../../lib/format";

interface Props {
  businessId: string;
  locationId: string;
  canUseGmail?: boolean;
}

function confidenceLabel(confidence: number | undefined): string | null {
  if (confidence === undefined) return null;
  const percentage = confidence <= 1 ? confidence * 100 : confidence;
  return `${Math.round(percentage)}% confidence`;
}

export function GmailReceiptsPanel({ businessId, locationId, canUseGmail = false }: Props) {
  const queryClient = useQueryClient();
  const [imports, setImports] = useState<Record<string, GmailImportResult>>({});
  const [importingId, setImportingId] = useState<string | null>(null);

  const status = useQuery({
    queryKey: ["gmail-status", businessId],
    queryFn: getGmailStatus,
    enabled: canUseGmail,
  });
  const messages = useQuery({
    queryKey: ["gmail-messages", businessId],
    queryFn: getGmailMessages,
    enabled: canUseGmail && status.data?.connected === true,
  });

  const connect = useMutation({
    mutationFn: () => {
      if (!canUseGmail) throw new Error("Your role cannot connect Gmail.");
      return connectGmail();
    },
    onSuccess: ({ authorizationUrl }) => {
      window.open(authorizationUrl, "_blank", "noopener,noreferrer");
    },
  });
  const disconnect = useMutation({
    mutationFn: disconnectGmail,
    onSuccess: async () => {
      setImports({});
      await queryClient.invalidateQueries({ queryKey: ["gmail-status", businessId] });
      await queryClient.invalidateQueries({ queryKey: ["gmail-messages", businessId] });
    },
  });
  const importReceipt = useMutation({
    mutationFn: (messageId: string) => {
      if (!canUseGmail) throw new Error("Your role cannot import Gmail receipts.");
      return importGmailReceipt({ messageId, businessId, locationId });
    },
    onMutate: (messageId) => setImportingId(messageId),
    onSuccess: (result, messageId) => {
      setImports((current) => ({ ...current, [messageId]: result }));
    },
    onSettled: () => setImportingId(null),
  });

  if (!canUseGmail) return null;

  return (
    <section className="panel settings-section" id="gmail">
      <div className="section-icon"><Mail /></div>
      <div className="settings-heading">
        <h2>Gmail receipts</h2>
        <p>Read receipt emails and extract details for review. Importing never posts to your books.</p>
      </div>

      {status.isLoading ? <LoadingBlock label="Loading Gmail connection…" /> : status.error ? (
        <div role="alert">
          <p className="form-error">Could not load the Gmail connection. Check your connection and try again.</p>
          <button type="button" className="text-button" onClick={() => void status.refetch()}>Try again</button>
        </div>
      ) : status.data?.connected ? (
        <div className="gmail-connection">
          <div><StatusBadge tone="positive"><Check />Connected</StatusBadge>{status.data.email ? <span>{status.data.email}</span> : null}</div>
          <button type="button" className="secondary-button" disabled={disconnect.isPending} onClick={() => disconnect.mutate()}>
            {disconnect.isPending ? <LoaderCircle className="spin" /> : <Unplug />}
            {disconnect.isPending ? "Disconnecting…" : "Disconnect"}
          </button>
        </div>
      ) : (
        <div className="gmail-connection">
          <div><StatusBadge>Not connected</StatusBadge><span>Connect Gmail to review recent receipt emails.</span></div>
          <button type="button" className="primary-button" disabled={connect.isPending} onClick={() => connect.mutate()}>
            {connect.isPending ? <LoaderCircle className="spin" /> : <Link2 />}
            {connect.isPending ? "Opening Gmail…" : "Connect Gmail"}
          </button>
        </div>
      )}

      {connect.error ? <p className="form-error" role="alert">{connect.error.message}</p> : null}
      {disconnect.error ? <p className="form-error" role="alert">{disconnect.error.message}</p> : null}

      {status.data?.connected ? (
        <div className="gmail-messages">
          <div className="panel-heading simple">
            <div><h3>Recent messages</h3><p>Only the latest 20 messages are shown.</p></div>
            <button type="button" className="text-button" disabled={messages.isFetching} onClick={() => void messages.refetch()}>
              {messages.isFetching ? "Refreshing…" : "Refresh"}
            </button>
          </div>
          {messages.isLoading ? <LoadingBlock label="Loading recent Gmail messages…" /> : messages.error ? (
            <div role="alert">
              <p className="form-error">Could not load recent messages. Check your connection and try again.</p>
              <button type="button" className="text-button" onClick={() => void messages.refetch()}>Try again</button>
            </div>
          ) : messages.data?.length ? (
            <div className="gmail-message-list">
              {messages.data.map((message) => {
                const result = imports[message.id];
                return (
                  <article className="gmail-message" key={message.id}>
                    <div className="gmail-message-copy">
                      <span className="gmail-message-icon"><FileText aria-hidden="true" /></span>
                      <div>
                        <h3>{message.subject}</h3>
                        <time dateTime={message.receivedAt}>{formatDateTime(message.receivedAt)}</time>
                        <p>{message.snippet}</p>
                      </div>
                    </div>
                    <button
                      type="button"
                      className="secondary-button"
                      disabled={importReceipt.isPending}
                      onClick={() => importReceipt.mutate(message.id)}
                    >
                      {importingId === message.id ? <LoaderCircle className="spin" /> : null}
                      {importingId === message.id ? "Extracting…" : result ? "Import again" : "Import for review"}
                    </button>
                    {result ? (
                      <div className="gmail-preview" aria-live="polite">
                        <div className="gmail-preview-heading">
                          <strong>Extracted for review</strong>
                          <StatusBadge tone="warning">Not posted</StatusBadge>
                        </div>
                        <dl>
                          <div><dt>Type</dt><dd>{formatKind(result.extracted.kind)} · {formatKind(result.extracted.direction)}</dd></div>
                          <div><dt>Party</dt><dd>{result.extracted.partyName ?? "Not identified"}</dd></div>
                          <div><dt>Amount</dt><dd>{formatMoney(result.extracted.amountMinor)}</dd></div>
                          <div><dt>Reference</dt><dd>{result.extracted.reference ?? "—"}</dd></div>
                          {confidenceLabel(result.extracted.confidence) ? <div><dt>Confidence</dt><dd>{confidenceLabel(result.extracted.confidence)}</dd></div> : null}
                        </dl>
                        {typeof result.preview === "string" ? <p>{result.preview}</p> : result.preview ? <pre>{JSON.stringify(result.preview, null, 2)}</pre> : null}
                        <p className="field-note">Review these details before recording anything in Entries.</p>
                      </div>
                    ) : null}
                  </article>
                );
              })}
            </div>
          ) : <p className="muted-copy">No recent receipt messages found.</p>}
        </div>
      ) : null}
      {importReceipt.error ? <p className="form-error" role="alert">{importReceipt.error.message}</p> : null}
    </section>
  );
}
