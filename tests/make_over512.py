#!/usr/bin/env python3
from pathlib import Path

out = Path("over512.bbc")
out.write_bytes(b"\x00\xff\xff" + (b"X" * (600 * 1024)))

print(f"Wrote {out} ({out.stat().st_size} bytes)")

