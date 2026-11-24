from __future__ import annotations

import csv
import hashlib
import io
import re
from dataclasses import dataclass
from decimal import Decimal, InvalidOperation

from django.conf import settings
from rest_framework.exceptions import APIException, ValidationError

from apps.catalog.models import Party, Product

from .models import ImportJob

DEFAULT_MAX_BYTES = 2 * 1024 * 1024
DEFAULT_MAX_ROWS = 5_000
MAX_CELL_CHARS = 4_096
MAX_BIGINTEGER = 9_223_372_036_854_775_807

PRODUCT_HEADERS = {
    "name",
    "sku",
    "base_unit",
    "hsn_sac",
    "gst_bps",
    "low_stock_threshold",
    "pack_name",
    "pack_conversion",
    "retail_price_minor",
    "wholesale_price_minor",
}
PRODUCT_REQUIRED_HEADERS = {"name"}
PRODUCT_PACK_HEADERS = {
    "pack_name",
    "pack_conversion",
    "retail_price_minor",
    "wholesale_price_minor",
}
PRODUCT_HEADER_ALIASES = {
    "hsn": "hsn_sac",
    "tax_rate_bps": "gst_bps",
    "conversion_factor": "pack_conversion",
    "retail_minor": "retail_price_minor",
    "wholesale_minor": "wholesale_price_minor",
}

PARTY_HEADERS = {"name", "kind", "phone", "gstin", "state", "address"}
PARTY_REQUIRED_HEADERS = {"name", "kind"}
PARTY_HEADER_ALIASES = {
    "phone_e164": "phone",
    "state_code": "state",
}

PHONE_RE = re.compile(r"^\+[1-9][0-9]{7,14}$")
GSTIN_RE = re.compile(r"^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$")
STATE_RE = re.compile(r"^[0-9]{2}$")
INTEGER_RE = re.compile(r"^[0-9]+$")
DECIMAL_RE = re.compile(r"^[+-]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)$")


class UploadTooLarge(APIException):
    status_code = 413
    default_code = "upload_too_large"
    default_detail = "The CSV exceeds the configured upload limit."


class TooManyRows(APIException):
    status_code = 413
    default_code = "row_limit_exceeded"
    default_detail = "The CSV exceeds the configured row limit."


@dataclass(frozen=True)
class ParsedCSV:
    rows: list[dict]
    errors: list[dict]
    row_count: int
    original_filename: str
    file_sha256: str
    file_size_bytes: int

    @property
    def valid_row_count(self) -> int:
        return len(self.rows)


def _max_bytes() -> int:
    return max(1, int(getattr(settings, "IMPORT_MAX_BYTES", DEFAULT_MAX_BYTES)))


def _max_rows() -> int:
    return max(1, int(getattr(settings, "IMPORT_MAX_ROWS", DEFAULT_MAX_ROWS)))


def _safe_filename(value: str | None) -> str:
    name = (value or "upload.csv").replace("\\", "/").rsplit("/", 1)[-1]
    name = "".join(character if character.isprintable() else "_" for character in name)
    return name.strip()[:255] or "upload.csv"


def _read_upload(uploaded) -> tuple[bytes, str]:
    declared_size = getattr(uploaded, "size", None)
    if declared_size is not None and int(declared_size) > _max_bytes():
        raise UploadTooLarge()
    try:
        uploaded.seek(0)
        payload = uploaded.read(_max_bytes() + 1)
    except (OSError, ValueError) as exc:
        raise ValidationError({"file": "The uploaded CSV could not be read."}) from exc
    if len(payload) > _max_bytes():
        raise UploadTooLarge()
    return payload, _safe_filename(getattr(uploaded, "name", None))


def _headers_for(kind: str) -> tuple[set[str], set[str], dict[str, str]]:
    if kind == ImportJob.Kind.PRODUCT:
        return PRODUCT_HEADERS, PRODUCT_REQUIRED_HEADERS, PRODUCT_HEADER_ALIASES
    if kind == ImportJob.Kind.PARTY:
        return PARTY_HEADERS, PARTY_REQUIRED_HEADERS, PARTY_HEADER_ALIASES
    raise ValidationError({"kind": "Must be PRODUCT or PARTY."})


def _validate_headers(raw_headers: list[str], kind: str) -> list[str]:
    allowed, required, aliases = _headers_for(kind)
    headers: list[str] = []
    seen: set[str] = set()
    unknown: list[str] = []
    duplicates: list[str] = []
    for raw in raw_headers:
        name = raw.strip().lower()
        name = aliases.get(name, name)
        if not name:
            unknown.append(raw or "<empty>")
            continue
        if name in seen:
            duplicates.append(name)
            continue
        seen.add(name)
        headers.append(name)
        if name not in allowed:
            unknown.append(raw)
    problems: dict[str, list[str]] = {}
    missing = sorted(required - seen)
    if missing:
        problems["headers"] = [f"Missing required column(s): {', '.join(missing)}."]
    if unknown:
        problems["headers"] = [
            *problems.get("headers", []),
            f"Unknown column(s): {', '.join(unknown)}.",
        ]
    if duplicates:
        problems["headers"] = [
            *problems.get("headers", []),
            f"Duplicate column(s): {', '.join(duplicates)}.",
        ]
    if kind == ImportJob.Kind.PRODUCT:
        present_pack_headers = PRODUCT_PACK_HEADERS & seen
        if present_pack_headers and present_pack_headers != PRODUCT_PACK_HEADERS:
            missing_pack = sorted(PRODUCT_PACK_HEADERS - seen)
            problems["headers"] = [
                *problems.get("headers", []),
                "Product pack columns must be supplied together; missing "
                f"{', '.join(missing_pack)}.",
            ]
    if problems:
        raise ValidationError(problems)
    return headers


def _text(
    raw: str,
    field: str,
    errors: dict[str, list[str]],
    *,
    required: bool = False,
    max_length: int,
) -> str:
    if len(raw) > MAX_CELL_CHARS:
        errors.setdefault(field, []).append(f"Must be at most {MAX_CELL_CHARS} characters.")
        return ""
    if "\x00" in raw:
        errors.setdefault(field, []).append("Must not contain NUL characters.")
        return ""
    value = raw.strip()
    if required and not value:
        errors.setdefault(field, []).append("This field is required.")
    if len(value) > max_length:
        errors.setdefault(field, []).append(f"Must be at most {max_length} characters.")
    return value


def _decimal(
    raw: str,
    field: str,
    errors: dict[str, list[str]],
    *,
    max_digits: int,
    decimal_places: int,
    minimum: Decimal,
    required: bool = False,
) -> str:
    value = raw.strip()
    if not value:
        if required:
            errors.setdefault(field, []).append("This field is required when a pack is supplied.")
        return ""
    if len(value) > 64:
        errors.setdefault(field, []).append("Number is too long.")
        return ""
    if not DECIMAL_RE.fullmatch(value):
        errors.setdefault(field, []).append("Enter a valid decimal number.")
        return ""
    try:
        number = Decimal(value)
        if not number.is_finite():
            raise InvalidOperation
        quantum = Decimal(1).scaleb(-decimal_places)
        normalized = number.quantize(quantum)
        if number != normalized:
            errors.setdefault(field, []).append(
                f"Must have at most {decimal_places} decimal places."
            )
            return ""
        if normalized < minimum:
            errors.setdefault(field, []).append(f"Must be at least {minimum}.")
            return ""
        integer_digits = max(normalized.adjusted() + 1, 0) if normalized else 0
        if integer_digits > max_digits - decimal_places:
            errors.setdefault(field, []).append(
                f"Must contain at most {max_digits} digits in total."
            )
            return ""
    except (InvalidOperation, ValueError, OverflowError):
        errors.setdefault(field, []).append("Enter a valid decimal number.")
        return ""
    return format(normalized, "f")


def _integer(
    raw: str,
    field: str,
    errors: dict[str, list[str]],
    *,
    maximum: int,
    minimum: int = 0,
    required: bool = False,
) -> int:
    value = raw.strip()
    if not value:
        if required:
            errors.setdefault(field, []).append("This field is required when a pack is supplied.")
        return 0
    if not INTEGER_RE.fullmatch(value):
        errors.setdefault(field, []).append("Enter a whole number.")
        return 0
    try:
        number = int(value)
    except ValueError:
        errors.setdefault(field, []).append("Enter a valid whole number.")
        return 0
    if number < minimum or number > maximum:
        errors.setdefault(field, []).append(f"Must be between {minimum} and {maximum}.")
    return number


def _product_row(values: dict[str, str], row_number: int) -> tuple[dict | None, dict | None]:
    errors: dict[str, list[str]] = {}
    name = _text(values.get("name", ""), "name", errors, required=True, max_length=180)
    sku = _text(values.get("sku", ""), "sku", errors, max_length=64)
    base_unit = values.get("base_unit", "PIECE").strip().upper() or "PIECE"
    if base_unit not in Product.Unit.values:
        errors.setdefault("base_unit", []).append(
            f"Must be one of: {', '.join(Product.Unit.values)}."
        )
    hsn_sac = _text(values.get("hsn_sac", ""), "hsn_sac", errors, max_length=12)
    gst_bps = _integer(
        values.get("gst_bps", "0") or "0",
        "gst_bps",
        errors,
        maximum=10_000,
    )
    low_stock_threshold = _decimal(
        values.get("low_stock_threshold", "0") or "0",
        "low_stock_threshold",
        errors,
        max_digits=18,
        decimal_places=3,
        minimum=Decimal("0"),
    )

    pack = None
    if values.get("pack_name", "").strip() or any(
        values.get(field, "").strip() for field in PRODUCT_PACK_HEADERS - {"pack_name"}
    ):
        pack_name = _text(
            values.get("pack_name", ""), "pack_name", errors, required=True, max_length=80
        )
        pack_conversion = _decimal(
            values.get("pack_conversion", ""),
            "pack_conversion",
            errors,
            max_digits=18,
            decimal_places=6,
            minimum=Decimal("0.000001"),
            required=True,
        )
        retail_price_minor = _integer(
            values.get("retail_price_minor", ""),
            "retail_price_minor",
            errors,
            maximum=MAX_BIGINTEGER,
            required=True,
        )
        wholesale_price_minor = _integer(
            values.get("wholesale_price_minor", ""),
            "wholesale_price_minor",
            errors,
            maximum=MAX_BIGINTEGER,
            required=True,
        )
        pack = {
            "name": pack_name,
            "conversion_factor": pack_conversion,
            "retail_price_minor": retail_price_minor,
            "wholesale_price_minor": wholesale_price_minor,
        }

    if errors:
        return None, {"row": row_number, "errors": errors}
    return {
        "_row": row_number,
        "name": name,
        "sku": sku,
        "base_unit": base_unit,
        "hsn_sac": hsn_sac,
        "gst_bps": gst_bps,
        "low_stock_threshold": low_stock_threshold,
        "pack": pack,
    }, None


def _party_row(values: dict[str, str], row_number: int) -> tuple[dict | None, dict | None]:
    errors: dict[str, list[str]] = {}
    name = _text(values.get("name", ""), "name", errors, required=True, max_length=180)
    kind = values.get("kind", "").strip().upper()
    if kind not in Party.Kind.values:
        errors.setdefault("kind", []).append(f"Must be one of: {', '.join(Party.Kind.values)}.")
    phone = _text(values.get("phone", ""), "phone", errors, max_length=20)
    if phone and not PHONE_RE.fullmatch(phone):
        errors.setdefault("phone", []).append(
            "Enter an E.164 phone number, for example +919876543210."
        )
    gstin = _text(values.get("gstin", ""), "gstin", errors, max_length=15).upper()
    if gstin and not GSTIN_RE.fullmatch(gstin):
        errors.setdefault("gstin", []).append("Enter a valid 15-character GSTIN.")
    state = _text(values.get("state", ""), "state", errors, max_length=2)
    if state and not STATE_RE.fullmatch(state):
        errors.setdefault("state", []).append("Enter a two-digit state code.")
    address = _text(values.get("address", ""), "address", errors, max_length=MAX_CELL_CHARS)
    if errors:
        return None, {"row": row_number, "errors": errors}
    return {
        "_row": row_number,
        "name": name,
        "kind": kind,
        "phone": phone,
        "gstin": gstin,
        "state": state,
        "address": address,
    }, None


def parse_csv(uploaded, kind: str) -> ParsedCSV:
    """Read and validate an uploaded CSV without retaining its raw bytes."""
    payload, filename = _read_upload(uploaded)
    try:
        text = payload.decode("utf-8-sig", errors="strict")
    except UnicodeDecodeError as exc:
        raise ValidationError({"file": "The CSV must be valid UTF-8."}) from exc

    try:
        reader = csv.reader(io.StringIO(text, newline=""), strict=True)
        raw_headers = next(reader)
    except StopIteration as exc:
        raise ValidationError({"file": "The CSV is empty."}) from exc
    except csv.Error as exc:
        raise ValidationError({"file": f"The CSV is malformed: {exc}."}) from exc

    headers = _validate_headers(raw_headers, kind)
    rows: list[dict] = []
    errors: list[dict] = []
    row_count = 0
    validate_row = _product_row if kind == ImportJob.Kind.PRODUCT else _party_row
    try:
        for raw_row in reader:
            if not raw_row or all(not cell.strip() for cell in raw_row):
                continue
            row_count += 1
            if row_count > _max_rows():
                raise TooManyRows()
            row_number = reader.line_num
            if len(raw_row) != len(headers):
                errors.append(
                    {
                        "row": row_number,
                        "errors": {
                            "_row": [
                                f"Expected {len(headers)} columns but received {len(raw_row)}."
                            ]
                        },
                    }
                )
                continue
            values = dict(zip(headers, raw_row, strict=True))
            normalized, error = validate_row(values, row_number)
            if error:
                errors.append(error)
            elif normalized is not None:
                rows.append(normalized)
    except csv.Error as exc:
        raise ValidationError(
            {"file": f"The CSV is malformed near line {reader.line_num}: {exc}."}
        ) from exc

    if row_count == 0:
        raise ValidationError({"file": "The CSV must contain at least one data row."})
    return ParsedCSV(
        rows=rows,
        errors=errors,
        row_count=row_count,
        original_filename=filename,
        file_sha256=hashlib.sha256(payload).hexdigest(),
        file_size_bytes=len(payload),
    )
