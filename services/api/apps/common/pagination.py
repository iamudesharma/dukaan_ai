"""Shared pagination for list endpoints.

Every list endpoint must be bounded: the mobile client runs on low-end
Android over patchy 4G, and unbounded arrays grow with the business. Both
the Flutter (`_rows`) and React (`recordList`) clients accept the standard
DRF envelope `{"count","next","previous","results"}`, so paginating a
viewset is a compatible change.
"""

from rest_framework.pagination import PageNumberPagination


class StandardResultsPagination(PageNumberPagination):
    page_size = 50
    page_size_query_param = "page_size"
    max_page_size = 200
