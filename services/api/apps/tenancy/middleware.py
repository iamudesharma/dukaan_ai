from django.db import connection

from apps.tenancy import rls


class TenantScopeMiddleware:
    """Scope the DB connection to the verified caller.

    - Session-authenticated requests (admin console): Django's
      authentication middleware runs before this one, so ``request.user``
      is already the verified user. Scope is derived from the membership
      table under a self-only read, never from client input.
    - Token API requests: DRF authentication runs later, inside the view,
      and establishes scope from the verified JWT itself.
    - Anonymous requests: no scope is set; RLS hides every tenant row.

    The previous request's scope is cleared when the response is done so a
    pooled connection never leaks one tenant into the next request. Scope
    is intentionally NOT cleared on entry: test ``force_authenticate`` and
    other pre-authenticated harnesses establish scope before dispatch, and
    production token auth establishes it during the view.
    """

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        user = getattr(request, "user", None)
        if user is not None and getattr(user, "is_authenticated", False):
            rls.establish_scope(
                connection,
                user,
                subject=getattr(user, "supabase_user_id", None),
            )
        try:
            return self.get_response(request)
        finally:
            rls.clear_tenant_scope(connection)
