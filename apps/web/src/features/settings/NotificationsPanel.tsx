import { useMemo, useState, type FormEvent } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Bell, Clock3, LoaderCircle, Pencil, Plus, Smartphone, Trash2, X } from "lucide-react";
import {
  cancelReminder,
  createReminder,
  listNotificationDevices,
  listReminders,
  registerNotificationDevice,
  unregisterNotificationDevice,
  updateReminder,
} from "../../data/repository";
import { newIdempotencyKey } from "../../lib/api";
import { formatDateTime } from "../../lib/format";
import type { NotificationDevice, Reminder, ReminderStatus } from "../../types";
import { LoadingBlock } from "../../components/LoadingBlock";
import { StatusBadge } from "../../components/StatusBadge";

interface Props {
  userId: string;
  businessId: string;
  locationId: string;
  locations: Array<{ id: string; name: string }>;
}

function toLocalDateTime(value?: string): string {
  const date = value ? new Date(value) : new Date(Date.now() + 60 * 60 * 1000);
  if (Number.isNaN(date.getTime())) return "";
  const pad = (part: number) => String(part).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

function reminderTone(status: ReminderStatus): "positive" | "warning" | "danger" | "neutral" {
  if (status === "SENT") return "positive";
  if (status === "SCHEDULED" || status === "QUEUED") return "warning";
  if (status === "FAILED") return "danger";
  return "neutral";
}

export function NotificationsPanel({ userId, businessId, locationId, locations }: Props) {
  const queryClient = useQueryClient();
  const [deviceFormOpen, setDeviceFormOpen] = useState(false);
  const [fcmToken, setFcmToken] = useState("");
  const [platform, setPlatform] = useState<NotificationDevice["platform"]>("WEB");
  const [deviceLocation, setDeviceLocation] = useState(locationId);
  const [reminderFormOpen, setReminderFormOpen] = useState(false);
  const [editing, setEditing] = useState<Reminder | null>(null);
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [scheduledAt, setScheduledAt] = useState(() => toLocalDateTime());
  const [reminderLocation, setReminderLocation] = useState(locationId);
  const [dedupeKey, setDedupeKey] = useState(() => newIdempotencyKey());
  const [message, setMessage] = useState<string | null>(null);

  const devices = useQuery({
    queryKey: ["notification-devices", userId],
    queryFn: listNotificationDevices,
  });
  const reminders = useQuery({
    queryKey: ["reminders", userId],
    queryFn: listReminders,
  });
  const businessDevices = useMemo(() => (devices.data ?? []).filter((device) => device.business === businessId), [businessId, devices.data]);
  const businessReminders = useMemo(() => (reminders.data ?? []).filter((reminder) => reminder.business === businessId), [businessId, reminders.data]);

  const register = useMutation({
    mutationFn: () => registerNotificationDevice({ businessId, locationId: deviceLocation || undefined, fcmToken: fcmToken.trim(), platform }),
    onSuccess: async () => {
      setFcmToken("");
      setDeviceFormOpen(false);
      setMessage("Device registered. Push delivery still happens in the background.");
      register.reset();
      await queryClient.invalidateQueries({ queryKey: ["notification-devices", userId] });
    },
  });
  const unregister = useMutation({
    mutationFn: unregisterNotificationDevice,
    onSuccess: async () => {
      setMessage("Device notifications disabled.");
      await queryClient.invalidateQueries({ queryKey: ["notification-devices", userId] });
    },
  });

  function openCreate() {
    setEditing(null);
    setTitle("");
    setBody("");
    setScheduledAt(toLocalDateTime());
    setReminderLocation(locationId);
    setDedupeKey(newIdempotencyKey());
    setReminderFormOpen(true);
    setMessage(null);
  }

  function openEdit(reminder: Reminder) {
    setEditing(reminder);
    setTitle(reminder.title);
    setBody(reminder.body);
    setScheduledAt(toLocalDateTime(reminder.scheduledAt));
    setReminderLocation(reminder.location ?? "");
    setReminderFormOpen(true);
    setMessage(null);
  }

  const saveReminder = useMutation({
    mutationFn: () => {
      const date = new Date(scheduledAt);
      if (Number.isNaN(date.getTime())) throw new Error("Choose a valid reminder date and time.");
      if (date.getTime() <= Date.now()) throw new Error("Choose a reminder time in the future.");
      if (editing) {
        return updateReminder(editing.id, { title: title.trim(), body: body.trim(), scheduledAt: date.toISOString() });
      }
      return createReminder({
        businessId,
        locationId: reminderLocation || undefined,
        title: title.trim(),
        body: body.trim(),
        scheduledAt: date.toISOString(),
        dedupeKey: `web-${dedupeKey}`,
      });
    },
    onSuccess: async () => {
      setReminderFormOpen(false);
      setEditing(null);
      setMessage(editing ? "Reminder updated. Delivery remains scheduled in the background." : "Reminder scheduled. This page did not send a push notification.");
      await queryClient.invalidateQueries({ queryKey: ["reminders", userId] });
    },
  });
  const cancel = useMutation({
    mutationFn: cancelReminder,
    onSuccess: async () => {
      setMessage("Reminder cancelled.");
      await queryClient.invalidateQueries({ queryKey: ["reminders", userId] });
    },
  });

  function submitReminder(event: FormEvent) {
    event.preventDefault();
    if (title.trim() && body.trim() && scheduledAt) saveReminder.mutate();
  }

  function deliveryDetail(reminder: Reminder): string {
    if (reminder.lastError && (reminder.status === "FAILED" || reminder.status === "SCHEDULED")) {
      return `${reminder.status === "FAILED" ? "Delivery failed" : "Delivery will retry"}: ${reminder.lastError}`;
    }
    if (reminder.status === "SKIPPED") {
      const matched = businessDevices.some((device) => device.status === "ACTIVE" && (!reminder.location || !device.location || device.location === reminder.location));
      return matched
        ? "Delivery was skipped. Push notifications may be disabled or FCM credentials may be missing or invalid on the server."
        : "No active device matched this business and location, so delivery was skipped.";
    }
    if (reminder.status === "SENT") return "Delivered to at least one registered device.";
    if (reminder.status === "CANCELLED") return "Cancelled. No further delivery will be attempted.";
    if (reminder.status === "QUEUED") return "Queued for background delivery.";
    return "Scheduled for background delivery.";
  }

  return (
    <section className="panel settings-section notification-settings" id="notifications">
      <div className="section-icon"><Bell /></div>
      <div className="settings-heading"><h2>Notifications</h2><p>Register a push device and schedule durable reminders. Sensitive balances never need to appear in lock-screen text.</p></div>
      <div className="review-callout"><Clock3 aria-hidden="true" /><div><strong>Scheduling never sends inline</strong><p>Reminders are delivered later by the background worker. If FCM is disabled or its credentials are missing or invalid, the backend marks delivery skipped or failed and shows its safe message below.</p></div></div>

      <div className="notification-subsection">
        <div className="panel-heading simple"><div><h3>Push devices</h3><p>Full FCM tokens are write-only. Only the last four characters are shown here.</p></div><button type="button" className="secondary-button" onClick={() => { setDeviceFormOpen((open) => !open); setMessage(null); }}><Plus />Register device</button></div>
        {deviceFormOpen ? (
          <form className="manual-form notification-form" aria-label="Register push device" onSubmit={(event) => { event.preventDefault(); if (fcmToken.trim()) register.mutate(); }}>
            <div className="two-fields"><label>FCM registration token<input type="password" autoComplete="off" spellCheck={false} value={fcmToken} onChange={(event) => setFcmToken(event.target.value)} minLength={8} required placeholder="Paste a token from your mobile or web app" /></label><label>Platform<select value={platform} onChange={(event) => setPlatform(event.target.value as NotificationDevice["platform"])}><option value="WEB">Web</option><option value="ANDROID">Android</option><option value="IOS">iOS</option></select></label></div>
            <label>Location scope<select value={deviceLocation} onChange={(event) => setDeviceLocation(event.target.value)}><option value="">All locations in this business</option>{locations.map((location) => <option key={location.id} value={location.id}>{location.name}</option>)}</select></label>
            {register.error ? <p className="form-error" role="alert">{register.error.message}</p> : null}
            <div className="review-actions"><button type="button" className="secondary-button" onClick={() => { setDeviceFormOpen(false); setFcmToken(""); }}>Cancel</button><button type="submit" className="primary-button" disabled={register.isPending || fcmToken.trim().length < 8}>{register.isPending ? <LoaderCircle className="spin" /> : <Smartphone />}{register.isPending ? "Registering…" : "Register device"}</button></div>
          </form>
        ) : null}
        {devices.isLoading ? <LoadingBlock label="Loading push devices…" /> : devices.error ? <div role="alert"><p className="form-error">Could not load push devices.</p><button type="button" className="text-button" onClick={() => void devices.refetch()}>Try again</button></div> : businessDevices.length ? (
          <ul className="notification-list">{businessDevices.map((device) => <li key={device.id}><span className="notification-icon"><Smartphone aria-hidden="true" /></span><div><strong>{device.platform} · {device.tokenSuffix}</strong><small>{device.location ? locations.find((location) => location.id === device.location)?.name ?? device.location : "All locations"} · Last seen {formatDateTime(device.lastSeenAt)}</small></div><StatusBadge tone={device.status === "ACTIVE" ? "positive" : "neutral"}>{device.status === "ACTIVE" ? "Active" : "Disabled"}</StatusBadge>{device.status === "ACTIVE" ? <button type="button" className="text-button" disabled={unregister.isPending && unregister.variables === device.id} onClick={() => unregister.mutate(device.id)}><Trash2 />{unregister.isPending && unregister.variables === device.id ? "Disabling…" : "Opt out"}</button> : null}</li>)}</ul>
        ) : <p className="muted-copy">No push devices registered for this business.</p>}
        {unregister.error ? <p className="form-error" role="alert">{unregister.error.message}</p> : null}
      </div>

      <div className="notification-subsection">
        <div className="panel-heading simple"><div><h3>Reminders</h3><p>Create, edit, or cancel your scheduled reminders for this business.</p></div><div className="notification-header-actions"><button type="button" className="text-button" disabled={reminders.isFetching} onClick={() => void reminders.refetch()}>{reminders.isFetching ? "Refreshing…" : "Refresh"}</button><button type="button" className="primary-button" onClick={openCreate}><Plus />New reminder</button></div></div>
        {reminderFormOpen ? (
          <form className="manual-form notification-form" aria-label="Reminder details" onSubmit={submitReminder}>
            <div className="panel-heading simple"><div><h3>{editing ? "Edit reminder" : "Schedule reminder"}</h3><p>{editing ? "Only scheduled reminders can be changed." : "The worker delivers this later to matching active devices."}</p></div><button type="button" className="icon-button" aria-label="Close reminder form" onClick={() => setReminderFormOpen(false)}><X /></button></div>
            <label>Title<input value={title} onChange={(event) => setTitle(event.target.value)} maxLength={120} required /></label>
            <label>Message<textarea value={body} onChange={(event) => setBody(event.target.value)} maxLength={500} rows={3} required /></label>
            <div className="two-fields"><label>Date and time<input type="datetime-local" value={scheduledAt} onChange={(event) => setScheduledAt(event.target.value)} required /></label><label>Location scope<select value={reminderLocation} disabled={Boolean(editing)} onChange={(event) => setReminderLocation(event.target.value)}><option value="">All locations in this business</option>{locations.map((location) => <option key={location.id} value={location.id}>{location.name}</option>)}</select></label></div>
            {saveReminder.error ? <p className="form-error" role="alert">{saveReminder.error.message}</p> : null}
            <div className="review-actions"><button type="button" className="secondary-button" onClick={() => setReminderFormOpen(false)}>Cancel</button><button type="submit" className="primary-button" disabled={saveReminder.isPending || !title.trim() || !body.trim() || !scheduledAt}>{saveReminder.isPending ? <LoaderCircle className="spin" /> : <Clock3 />}{saveReminder.isPending ? "Saving…" : editing ? "Save reminder" : "Schedule reminder"}</button></div>
          </form>
        ) : null}
        {reminders.isLoading ? <LoadingBlock label="Loading reminders…" /> : reminders.error ? <div role="alert"><p className="form-error">Could not load reminders.</p><button type="button" className="text-button" onClick={() => void reminders.refetch()}>Try again</button></div> : businessReminders.length ? (
          <ul className="notification-list reminder-list">{businessReminders.map((reminder) => <li key={reminder.id}><span className="notification-icon"><Clock3 aria-hidden="true" /></span><div><strong>{reminder.title}</strong><p>{reminder.body}</p><small>{reminder.kind === "DOMAIN" ? "Automatic event" : "Your reminder"} · {formatDateTime(reminder.scheduledAt)}</small><small className="delivery-detail">{deliveryDetail(reminder)}</small></div><StatusBadge tone={reminderTone(reminder.status)}>{reminder.status}</StatusBadge>{reminder.kind === "USER" && reminder.status === "SCHEDULED" ? <div className="reminder-actions"><button type="button" className="text-button" disabled={saveReminder.isPending} onClick={() => openEdit(reminder)}><Pencil />Edit</button><button type="button" className="text-button" disabled={cancel.isPending && cancel.variables === reminder.id} onClick={() => cancel.mutate(reminder.id)}><Trash2 />{cancel.isPending && cancel.variables === reminder.id ? "Cancelling…" : "Cancel reminder"}</button></div> : null}</li>)}</ul>
        ) : <p className="muted-copy">No reminders scheduled for this business.</p>}
        {cancel.error ? <p className="form-error" role="alert">{cancel.error.message}</p> : null}
      </div>
      {message ? <p className="invitation-success" role="status">{message}</p> : null}
    </section>
  );
}
