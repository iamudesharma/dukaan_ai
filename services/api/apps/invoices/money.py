"""Exact integer-paise formatting for invoice output.

Invoice amounts never pass through ``float``: rupees and paise are split with
integer arithmetic, and tax rates are formatted from basis points with Decimal.
"""

from __future__ import annotations

from decimal import Decimal

_ONES = (
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
    "ten",
    "eleven",
    "twelve",
    "thirteen",
    "fourteen",
    "fifteen",
    "sixteen",
    "seventeen",
    "eighteen",
    "nineteen",
)
_TENS = ("", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety")
_INDIAN_SCALES = ("thousand", "lakh", "crore", "arab")


def format_money(amount_minor: int) -> str:
    """Render integer paise as grouped rupees, retaining both decimal places."""
    sign = "-" if amount_minor < 0 else ""
    rupees, paise = divmod(abs(amount_minor), 100)
    return f"{sign}{rupees:,}.{paise:02d}"


def format_rupees(amount_minor: int) -> str:
    """Render an amount with an ASCII currency marker supported by base PDF fonts."""
    formatted = format_money(amount_minor)
    if formatted.startswith("-"):
        return f"-Rs. {formatted[1:]}"
    return f"Rs. {formatted}"


def format_rate_percent(tax_rate_bps: int) -> str:
    """Render basis points as an exact percentage without binary floating point."""
    percent = (Decimal(tax_rate_bps) / Decimal(100)).normalize()
    return format(percent, "f")


def format_half_rate_percent(tax_rate_bps: int) -> str:
    """Render the CGST/SGST rate (half of the total GST rate) exactly."""
    percent = (Decimal(tax_rate_bps) / Decimal(200)).normalize()
    return format(percent, "f")


def _under_one_thousand(value: int) -> str:
    if value < 20:
        return _ONES[value]
    if value < 100:
        tens, ones = divmod(value, 10)
        return f"{_TENS[tens]} {_ONES[ones]}" if ones else _TENS[tens]
    hundreds, remainder = divmod(value, 100)
    words = f"{_ONES[hundreds]} hundred"
    return f"{words} {_under_one_thousand(remainder)}" if remainder else words


def _integer_in_words(value: int) -> str:
    """Render a non-negative integer using Indian lakh/crore grouping."""
    if value < 1_000:
        return _under_one_thousand(value)

    parts: list[str] = []
    quotient, remainder = divmod(value, 1_000)
    if remainder:
        parts.append(_under_one_thousand(remainder))

    scale_index = 0
    while quotient:
        quotient, group = divmod(quotient, 100)
        if group:
            if scale_index < len(_INDIAN_SCALES):
                scale = _INDIAN_SCALES[scale_index]
            else:
                # BigIntegerField permits values beyond normal invoice sizes.
                # Keep such values exact instead of silently losing digits.
                scale = f"ten power {3 + scale_index * 2}"
            parts.append(f"{_under_one_thousand(group)} {scale}")
        scale_index += 1
    return " ".join(reversed(parts))


def amount_in_words(amount_minor: int) -> str:
    """Render an integer-paise amount in Indian-style words, including paise."""
    sign = "Minus " if amount_minor < 0 else ""
    rupees, paise = divmod(abs(amount_minor), 100)
    rupees_words = _integer_in_words(rupees).title()
    if paise:
        paise_words = _integer_in_words(paise).title()
        return f"{sign}{rupees_words} Rupees and {paise_words} Paise Only"
    return f"{sign}{rupees_words} Rupees Only"
