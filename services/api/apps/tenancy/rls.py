"""PostgreSQL Row Level Security scope helpers.

Every tenant-owned table carries an immutable ``business_id`` (or inherits
one from a parent row). Policies are created by migration with
``FORCE ROW LEVEL SECURITY`` so they apply to table owners as well as the
application role: every connection must carry a request scope, set only
from server-verified values (the authenticated user and their memberships).

Session settings used:

- ``app.current_user_id`` — the internal user UUID. Lets a connection read
  its own membership rows (bootstrap) but nothing else.
- ``app.business_ids`` — comma-separated business UUIDs the caller may
  access, or ``*`` for staff operator work (admin console only).
- ``app.current_subject`` — reserved for future direct-JWT database paths;
  set for auditability but not referenced by any policy yet.

Fail-closed default: with no settings present every policy evaluates to
NULL and the connection sees no tenant rows.

Pooling requirement: settings are connection-local. Use direct connections
or session-mode pooling. Transaction-mode pooling discards ``SET`` between
statements and is NOT supported — see the deploy runbook.

Two tables are intentionally outside RLS:

- ``common_user`` — identity bootstrap is the trust anchor. Authentication
  must resolve the caller before any scope exists, so users stay under
  application-layer membership checks (no user-listing endpoints exist).
- ``django_session`` — random session keys only, no tenant data.
"""

from __future__ import annotations

import uuid

BUSINESS_IDS_SETTING = "app.business_ids"
USER_ID_SETTING = "app.current_user_id"
SUBJECT_SETTING = "app.current_subject"
STAFF_WILDCARD = "*"

DEFAULT_APP_ROLE = "dukaan_app"

# (child_table, parent_table, parent_fk) for tables that inherit tenancy.
CHILD_TABLES = [
    ("catalog_productpack", "catalog_product", "product_id"),
    ("operations_saleline", "operations_sale", "sale_id"),
    ("operations_purchaseline", "operations_purchase", "purchase_id"),
    ("operations_paymentallocation", "operations_payment", "payment_id"),
    ("operations_stocktransferline", "operations_stocktransfer", "transfer_id"),
    ("assistant_proposalrevision", "assistant_assistantproposal", "proposal_id"),
]

# Tables with a direct business_id column (tenancy_outboxevent included;
# its policy additionally hides business-less system rows from tenants).
DIRECT_TABLES = [
    "tenancy_gstregistration",
    "tenancy_location",
    "tenancy_membership",
    "tenancy_idempotencyrecord",
    "tenancy_auditevent",
    "tenancy_outboxevent",
    "catalog_party",
    "catalog_product",
    "operations_documentsequence",
    "operations_sale",
    "operations_purchase",
    "operations_payment",
    "operations_expense",
    "operations_stockbalance",
    "operations_stockmovement",
    "operations_partyledgerentry",
    "operations_stocktransfer",
    "assistant_assistantproposal",
]


def _setting(name: str) -> str:
    return f"current_setting('{name}', true)"


def _scope_ids() -> str:
    # UUID-shaped entries only: the staff wildcard '*' must not reach the
    # ::uuid cast, which would abort the whole statement.
    uuid_pattern = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
    return (
        "COALESCE((SELECT array_agg(entry::uuid) FROM "
        f"unnest(string_to_array(NULLIF({_setting(BUSINESS_IDS_SETTING)}, ''), ',')) "
        f"AS entry WHERE entry ~ '{uuid_pattern}'), '{{}}'::uuid[])"
    )


def _wildcard() -> str:
    return f"{_setting(BUSINESS_IDS_SETTING)} = '{STAFF_WILDCARD}'"


def _in_scope(column: str = "business_id") -> str:
    return f"{column} = ANY ({_scope_ids()})"


def direct_policy() -> tuple[str, str]:
    expr = f"{_wildcard()} OR {_in_scope()}"
    return expr, expr


def business_policy() -> tuple[str, str]:
    # Inserts use a server-generated UUID that onboarding adds to the scope
    # before the row is created (see BusinessSerializer.create).
    expr = f"{_wildcard()} OR (id = ANY ({_scope_ids()}))"
    return expr, expr


def membership_policy() -> tuple[str, str]:
    using = f"{_wildcard()} OR {_in_scope()} OR (user_id::text = {_setting(USER_ID_SETTING)})"
    # The self-read clause must not allow joining a new business: inserts and
    # business changes require the business to already be in scope.
    check = f"{_wildcard()} OR {_in_scope()}"
    return using, check


def child_policy(parent_table: str, parent_fk: str) -> tuple[str, str]:
    expr = (
        f"{_wildcard()} OR EXISTS (SELECT 1 FROM {parent_table} AS parent "
        f"WHERE parent.id = {parent_fk} AND {_in_scope('parent.business_id')})"
    )
    return expr, expr


def outbox_policy() -> tuple[str, str]:
    # Rows without a business are system-level and visible to the privileged
    # dispatcher (staff scope) only; tenant connections always carry one.
    expr = f"{_wildcard()} OR (business_id IS NOT NULL AND {_in_scope()})"
    return expr, expr


def validate_business_ids(business_ids) -> list[str]:
    return [str(uuid.UUID(str(candidate))) for candidate in business_ids]


def _quote(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def _is_postgres(connection) -> bool:
    return connection.vendor == "postgresql"


def read_scope(connection) -> dict[str, str | None]:
    """Snapshot the current scope settings for later restoration."""
    if not _is_postgres(connection):
        return {}
    with connection.cursor() as cursor:
        cursor.execute(
            f"SELECT {_setting(BUSINESS_IDS_SETTING)}, "
            f"{_setting(USER_ID_SETTING)}, {_setting(SUBJECT_SETTING)}"
        )
        business_ids, user_id, subject = cursor.fetchone()
    return {"business_ids": business_ids, "user_id": user_id, "subject": subject}


def _apply_snapshot(connection, snapshot) -> None:
    with connection.cursor() as cursor:
        for setting, value in (
            (BUSINESS_IDS_SETTING, snapshot.get("business_ids")),
            (USER_ID_SETTING, snapshot.get("user_id")),
            (SUBJECT_SETTING, snapshot.get("subject")),
        ):
            if value is None:
                cursor.execute(f"RESET {setting}")
            else:
                cursor.execute(f"SET {setting} = {_quote(str(value))}")


def restore_scope(connection, snapshot) -> None:
    """Restore a snapshot taken by read_scope. No-op off Postgres."""
    if not _is_postgres(connection):
        return
    _apply_snapshot(connection, snapshot)


def set_tenant_scope(connection, *, user_id=None, subject=None, business_ids=()) -> None:
    """Apply request scope to this connection. All values are server-derived:
    the user comes from the verified token/session and the business list from
    the membership table. No-op on non-Postgres backends."""
    if not _is_postgres(connection):
        return
    with connection.cursor() as cursor:
        if subject is not None:
            cursor.execute(f"SET {SUBJECT_SETTING} = {_quote(str(subject))}")
        if user_id is not None:
            cursor.execute(f"SET {USER_ID_SETTING} = {_quote(str(uuid.UUID(str(user_id))))}")
        ids = list(business_ids)
        if len(ids) == 1 and ids[0] == STAFF_WILDCARD:
            cursor.execute(f"SET {BUSINESS_IDS_SETTING} = {_quote(STAFF_WILDCARD)}")
        else:
            cursor.execute(
                f"SET {BUSINESS_IDS_SETTING} = {_quote(','.join(validate_business_ids(ids)))}"
            )


def set_staff_scope(connection) -> None:
    """Wildcard scope for privileged server-side work (migrations support,
    seeding, dispatch, tests). Never derive this from client input."""
    set_tenant_scope(connection, business_ids=[STAFF_WILDCARD])


def active_business_ids(connection, user) -> list[str]:
    """Server-derived business list for a verified user.

    Two phases, both on the given connection. Membership rows are readable
    via the self-read clause, which yields candidate businesses; those
    candidates then become the scope, under which only active businesses are
    kept. Raw SQL (not the ORM) so this works on any connection, including
    dedicated role connections outside the Django connection registry.
    Client-supplied business ids are never trusted.
    """
    if not _is_postgres(connection):
        from apps.tenancy.models import Membership

        return [
            str(pk)
            for pk in Membership.objects.filter(user=user, is_active=True, business__is_active=True)
            .order_by("created_at")
            .values_list("business_id", flat=True)
        ]
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT business_id FROM tenancy_membership WHERE user_id = %s AND is_active",
            [str(user.pk)],
        )
        candidates = [str(row[0]) for row in cursor.fetchall()]
    if not candidates:
        return []
    set_tenant_scope(
        connection,
        user_id=user.pk,
        business_ids=candidates,
    )
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT id FROM tenancy_business WHERE id = ANY (%s) AND is_active",
            [candidates],
        )
        return [str(row[0]) for row in cursor.fetchall()]


def establish_scope(connection, user, *, subject=None) -> list[str]:
    """Set user + business scope for a verified user; returns the ids set.

    The business list is read under the user's own identity (via the
    membership self-read clause) before the business scope is finalised, so
    the lookup itself cannot leak other tenants.
    """
    set_tenant_scope(connection, user_id=user.pk, subject=subject, business_ids=[])
    businesses = active_business_ids(connection, user)
    set_tenant_scope(connection, user_id=user.pk, subject=subject, business_ids=businesses)
    return businesses


def expand_tenant_scope(connection, business_id) -> None:
    """Add a server-created business to the current connection scope, used
    during onboarding before the first membership row exists."""
    if not _is_postgres(connection):
        return
    business_id = str(uuid.UUID(str(business_id)))
    with connection.cursor() as cursor:
        cursor.execute(f"SELECT {_setting(BUSINESS_IDS_SETTING)}")
        current = cursor.fetchone()[0] or ""
    if current == STAFF_WILDCARD:
        return
    ids = [candidate for candidate in current.split(",") if candidate]
    if business_id not in ids:
        ids.append(business_id)
    with connection.cursor() as cursor:
        cursor.execute(f"SET {BUSINESS_IDS_SETTING} = {_quote(','.join(ids))}")


def clear_tenant_scope(connection) -> None:
    if not _is_postgres(connection):
        return
    with connection.cursor() as cursor:
        for setting in (BUSINESS_IDS_SETTING, USER_ID_SETTING, SUBJECT_SETTING):
            cursor.execute(f"RESET {setting}")
