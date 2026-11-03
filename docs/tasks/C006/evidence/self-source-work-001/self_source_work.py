"""Count frozen source bytes/prefix lengths and a static index-move bound.

No BASIC parsing, compilation, numeric oracle, execution or device access.
Seven traversals are a source-review finding, not a runtime measurement.
"""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[3]
source = ROOT/'docs/tasks/C006/evidence/olimex-fixture-001/payload/compiler.bas'
qualified = json.loads((ROOT/'docs/tasks/C005/evidence/packed-source-002/results.json').read_text())
data = source.read_bytes()
sha = hashlib.sha256(data).hexdigest()
assert sha == qualified['source_sha256']
assert b'\r' not in data and data.endswith(b'\n') and data.isascii()
lines = data.splitlines()
symbols = int(qualified['counters'].split(':')[1])
prefixes = sum(len(line)*(len(line)+1)//2 for line in lines)
print(json.dumps(dict(
    scope='Offline static counts/bounds; no instruction, progress or time measurement',
    source_sha256=sha, source_bytes=len(data), source_lines=len(lines),
    expected_complete_source_traversals=7, complete_source_byte_visits=7*len(data),
    line_payload_bytes=sum(map(len, lines)),
    cumulative_line_prefix_payload_lengths_one_traversal=prefixes,
    cumulative_line_prefix_payload_lengths_seven_traversals=7*prefixes,
    symbols_in_completed_emulator_run=symbols,
    sorted_index_worst_case_shifted_bytes_for_that_count=symbols*(symbols-1),
    actual_shift_count_measured=False, executed_instruction_counts_retained=False,
    physical_compiler_progress_established=False), indent=2))
