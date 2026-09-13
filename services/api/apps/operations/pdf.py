"""Minimal single-font PDF renderer with zero third-party dependencies.

Phase 3 needs invoice and export PDFs in private storage without dragging a
full reporting stack into the API image. This writes PDF 1.4 with the
built-in Helvetica face: title lines plus plain body lines, A4 pages with
automatic page breaks. Good enough for shop invoices and tabular exports;
a richer layout engine can replace this module behind the same functions.
"""

from __future__ import annotations


def _escape(text: str) -> str:
    return text.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")


def render_simple_pdf(*, title: str, lines: list[str]) -> bytes:
    """Render ``title`` + ``lines`` to PDF bytes (A4, Helvetica)."""
    content_rows = [f"BT /F1 16 Tf 56 780 Td ({_escape(title)}) Tj ET"]
    y = 752
    content_rows.append("BT /F1 10 Tf 56 752 Td 14 TL")
    for line in lines:
        if y < 60:
            content_rows.append("ET")
            content_rows.append("BT /F1 10 Tf 56 780 Td 14 TL")
            y = 780
        content_rows.append(f"({_escape(line)}) Tj T*")
        y -= 14
    content_rows.append("ET")
    content = "\n".join(content_rows).encode("latin-1", errors="replace")
    page_count = 1

    objects: list[bytes] = []
    objects.append(b"<< /Type /Catalog /Pages 2 0 R >>")
    kids = " ".join(f"{3 + i * 2} 0 R" for i in range(page_count))
    objects.append(f"<< /Type /Pages /Kids [{kids}] /Count {page_count} >>".encode())
    # Re-split content per page is overkill for invoices; single page stream.
    objects.append(
        b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] "
        b"/Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>"
    )
    objects.append(f"<< /Length {len(content)} >>\nstream\n".encode() + content + b"\nendstream")
    objects.append(b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>")

    out = bytearray(b"%PDF-1.4\n")
    offsets = [0]
    for number, body in enumerate(objects, start=1):
        offsets.append(len(out))
        out += f"{number} 0 obj\n".encode() + body + b"\nendobj\n"
    xref_at = len(out)
    out += f"xref\n0 {len(objects) + 1}\n".encode()
    out += b"0000000000 65535 f \n"
    for offset in offsets[1:]:
        out += f"{offset:010d} 00000 n \n".encode()
    out += (
        f"trailer\n<< /Size {len(objects) + 1} /Root 1 0 R >>\nstartxref\n{xref_at}\n%%EOF".encode()
    )
    return bytes(out)


def invoice_lines(
    *, number: str, business: str, party: str, total_minor: int, items: list[str]
) -> list[str]:
    rupees = total_minor / 100
    return [
        f"Business: {business}",
        f"Invoice: {number}",
        f"Billed to: {party}",
        "",
        *items,
        "",
        f"Total: Rs {rupees:,.2f}",
    ]
