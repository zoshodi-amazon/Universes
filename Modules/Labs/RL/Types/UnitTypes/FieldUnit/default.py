"""FieldUnit [Solid] — Shared constrained string aliases (5 params). All bounded.

Irreducible field types used across >=2 phases. Single source of truth.
No BaseModel — these are type aliases for pydantic constr validation.
"""
from pydantic import constr

RunId = constr(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)
"""8-char hex run identifier — auto-generated UUID prefix."""

Ticker = constr(pattern=r"^[A-Z0-9\-./]{1,16}$", min_length=1, max_length=16)
"""Ticker symbol — uppercase alphanumeric with separators, e.g. AAPL, BTC-USD."""

FilePath = constr(min_length=1, max_length=512, pattern=r"^[A-Za-z0-9_\-./]+$")
"""Validated file path — alphanumeric with path separators, max 512 chars."""

DirPath = constr(min_length=1, max_length=256, pattern=r"^[A-Za-z0-9_\-./]+$")
"""Validated directory path — alphanumeric with path separators, max 256 chars."""

ISODate = constr(pattern=r"^\d{4}-\d{2}-\d{2}", min_length=10, max_length=32)
"""ISO 8601 date string — YYYY-MM-DD prefix, up to 32 chars for full datetime."""
