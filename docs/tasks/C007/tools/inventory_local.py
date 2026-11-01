"""Record source identities for C007; does not execute or qualify BASIC tests."""

import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[4]
REVISION = "ccd09af"
PATHS = [
    "license.txt",
    "compiler/compiler.bas",
    "compiler/tools/test_compiler.py",
    "compiler/tests/golden.s",
    "docs/tasks/C002/tools/test_numeric.py",
    "docs/tasks/C002/numeric.s",
    "tests/conformance/README.md",
    "tests/conformance/l1_core.bas",
    "tests/conformance/l2_edge.bas",
    "tests/conformance/l3a_stress.bas",
    "tests/conformance/l3b_fileio.bas",
    "tests/conformance/l4a_eval.bas",
    "tests/conformance/l4b_float.bas",
    "tests/conformance/l4c_localdim.bas",
    "tests/conformance/l5e_memchurn.bas",
    "tests/conformance/l5g_stateedge.bas",
    "tests/locals.bas",
    "tests/byreftest.bas",
    "tests/counttest.bas",
    "tests/loopbench.bas",
    "tests/nscantest.bas",
    "tests/nscan.bas",
    "tests/recurse.bas",
    "tests/mult_benchmarks.bas",
    "tests/index_benchmarks.bas",
    "tests/demos/life.bas",
    "tests/demos/mandlebrot.bas",
]


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def main():
    revision = git("rev-parse", REVISION).decode().strip()
    records = []
    for path in PATHS:
        content = git("show", f"{revision}:{path}")
        assert (ROOT / path).read_bytes() == content, f"changed since search: {path}"
        records.append({
            "path": path,
            "git_blob": git("rev-parse", f"{revision}:{path}").decode().strip(),
            "last_change_commit": git("log", "-1", "--format=%H", revision,
                                      "--", path).decode().strip(),
            "sha256": hashlib.sha256(content).hexdigest(),
            "bytes": len(content),
        })
    output = ROOT / "docs/tasks/C007/evidence/local-inventory.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps({
        "task": "C007",
        "search_date": "2026-11-01",
        "repository": "https://github.com/bgates747/agon-bbc-basic",
        "revision": revision,
        "execution_status": "source inventory only; no new BASIC executions",
        "files": records,
    }, indent=2) + "\n")
    print(f"Recorded {len(records)} source identities at {revision}")


if __name__ == "__main__":
    main()
