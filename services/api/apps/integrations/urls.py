from django.urls import path

from .views import (
    GmailCallbackView,
    GmailConnectView,
    GmailDisconnectView,
    GmailImportsView,
    GmailImportView,
    GmailMessagesView,
    GmailStatusView,
    NotificationDeviceListCreateView,
    NotificationDeviceUnregisterView,
    ReminderDetailView,
    ReminderListCreateView,
)

urlpatterns = [
    path("integrations/gmail/status/", GmailStatusView.as_view(), name="gmail-status"),
    path("integrations/gmail/connect/", GmailConnectView.as_view(), name="gmail-connect"),
    path("integrations/gmail/callback/", GmailCallbackView.as_view(), name="gmail-callback"),
    path("integrations/gmail/", GmailDisconnectView.as_view(), name="gmail-disconnect"),
    path("integrations/gmail/messages/", GmailMessagesView.as_view(), name="gmail-messages"),
    path("integrations/gmail/import/", GmailImportView.as_view(), name="gmail-import"),
    path("integrations/gmail/imports/", GmailImportsView.as_view(), name="gmail-imports"),
    path(
        "integrations/notifications/devices/",
        NotificationDeviceListCreateView.as_view(),
        name="notification-devices",
    ),
    path(
        "integrations/notifications/devices/<uuid:device_id>/",
        NotificationDeviceUnregisterView.as_view(),
        name="notification-device-unregister",
    ),
    path(
        "integrations/notifications/reminders/",
        ReminderListCreateView.as_view(),
        name="notification-reminders",
    ),
    path(
        "integrations/notifications/reminders/<uuid:reminder_id>/",
        ReminderDetailView.as_view(),
        name="notification-reminder-detail",
    ),
]
