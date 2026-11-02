# Live string core qualification

The exact promoted compiler passes the baseline assembly oracle, string and
numeric transcript suites, raw string storage and independent links. The two
expression batches cover initial precedence cases and targeted errors/newer
numeric expressions. The example/limit batch has one execution and two rejected
sources. The expanded direct ABI probe additionally checks complete failed
allocation descriptor/context state, all 15 remaining guard bytes, and same-buffer
concatenation. All runs used the Pi5 CLI fixture, sequentially.

See summary.json for counts and measured host qualification durations, each
subdirectory for source/logs/results, and manifest.json for retained-file hashes.
Binary snapshots use .dat without changing their bytes; reports retain original
build paths. The first ABI source version is retained in abi/; the expanded
version is in abi-expanded/. Numeric library source/vendor/license remain
unchanged. No new benchmark, graphical human or hardware validation is claimed.

An ad-hoc archival script selected the parent expression build directory after
a successful 12-case batch. The selected report did not exist; files were copied
from the actual batch-000 directory without rerunning or changing results.
The first limit batch put a rejection first, violating the shared harness's
repeat-first-success convention. Its failed assertion is retained separately;
the corrected fixture order passed. Neither event changed compiler/runtime code.

New string tranche changes remain uncommitted for review. The pre-tranche
scalar checkpoint and evidence cleanup are pushed through 58feb04 on the
existing development branch. Main is unchanged.
