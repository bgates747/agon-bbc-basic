# Bootstrap resource closure design notes

The current interpreted-host headroom measurement does not prove that the native
compiler can fit beside its own metadata and output. The actual7cac4bba self-source
probe exhausts4096 address fixups at physical line108, preserving its old output
in1459.137s (`evidence/errors-source-gap-001`). The next actual self-source
probe, after language closure, must measure generated size, symbols, fixups and
RAM. This note records the isolated BBC streaming emitter and its qualification.
The live compiler remains unchanged; no native self-source size result is claimed.

## Current constraints and proposed boundary

1. The live emitter owns a65536-byte output buffer plus4096 fixup records. Native
   self-compilation must share Agon RAM with the executing compiler, its metadata,
   private string/activation workspace and embedded templates. Enlarging both
   tables blindly is not a resource proof. The prepared DATA frontend statically
   has242 private binding candidates and187 definitions; this is only an inventory.
2. A measured need can justify layout, validation and output passes, all in BBC
   BASIC. Layout builds the symbol/address map without buffering code or storing
   per-reference fixups. Validation resolves all references before the destination
   is opened. Output emits exact bytes directly through BPUT. Reset parser/counters
   deterministically on each pass and verify layout identity.
3. Repeated labels must look up the existing symbol and verify its final address.
   Current helper exports overwrite `csaddr%(csnum%-1)` after PROClabel; they must
   instead use the actual resolved label index. Export aliases, heap endpoints and
   entry trampolines need explicit address definitions so pass validation compares
   final values rather than an intermediate cpc address.
4. Templates need emission-time rebasing and bridge substitution. Current numeric,
   control and activation emitters copy bytes then patch the buffer; control and
   activation also rewind cpc for external bridge operands. A common BBC emitter
   can walk sorted internal relocation offsets and fixed bridge slots and emit
   final24-bit operands directly. Do not use a host compiler or an interpreter
   engine to avoid this work.
5. Preserve transactional compile validation and exact existing executable bytes.
   Check source/output failure paths, malformed programs, repeated compilation,
   symbols/addresses across passes, all template GNU links and representative
   complete old images. Streaming is an implementation/resource change, not a
   BBC language extension or permission to change observable output.
6. Measure the resulting native compiler's actual heap/arena/code limits. If it
   cannot hold its own binding/symbol tables and owned strings, refine storage
   with measured evidence before claiming C005 closure or C006 self-hosting.

## Static numbered-line pressure before the next source probe

The promoted DATA source has1962 numbered lines, exceeding the1024-symbol cap before
counting its emitted control/variable/runtime labels. PROCnumberlabel currently
creates a symbol for every numbered line. This is an explicit static gap, not a
measured native image result. A BBC prescan can collect numeric GOTO/GOSUB targets
and retain addresses only for referenced numbered lines, while still validating
all source numbers/order and named-label duplicates. RESTORE targets remain a
separate DATA address map. Qualify forward/backward/nested branches, missing
lines and unchanged old images; do not silently drop a valid branch target.

## Pass invariants and emission-time library rebasing

1. Keep the completed layout pass's binding table, signatures, inferred FN kinds,
   discovered feature flags and maximum numeric/string pool sizes. Replaying the
   source must not rebuild the binding order with different formal/global indices.
   Reset lexical/parser counters, source position, flow IDs and activation parse
   state; require identical final layout and aliases before opening the output.
2. Define aliases at their final addresses through one routine. Existing export
   calls first create a label at cpc then overwrite its address; that temporary
   definition cannot be compared during a validation pass. Replace every direct
   csaddr%(csnum%-1) alias update with an explicit final-address definition.
3. Keep an explicit entry-chain address starting at the original header body.
   Control/activation, error initialisation and DATA reset wrap that address in
   order. Define $start once at the completed outer entry. Later passes must not
   read the final $start map value as though it were the original body address.
4. A BBC template emitter can accept a raw image pointer/size and a package ID;
   selecting that package's existing global relocation array needs no array-formal
   language extension. Walk sorted internal relocations and external bridge slots,
   emitting final three-byte operands directly. Validation/output use the completed
   symbol map; layout counts operands without retaining reference records.
5. A bounded referenced-target set can collect numeric GOTO/GOSUB and constant
   THEN/ELSE targets, plus a distinct tag for constant RESTORE targets, during the
   existing signature prescan. Only referenced numbered addresses need symbols;
   validate all numbering/order and named-label duplicates independently. DATA
   aliases are global, while ordinary branches retain the current PROC/FN scope.
6. Measure symbol/binding counts and native RAM after these changes. A larger
   finite table needs capacity/rejection evidence and real headroom, not an assumed
   unlimited host. These notes refine C005's resource experiment; none constitutes
   an implemented streaming emitter or successful self-source compilation.

## Prepared BBC streaming experiment

An isolated candidate now lives in `streaming/compiler.bas`, generated by
`streaming/integrate.py` from the separately qualifying source-handler candidate.
No live source or completed error cohort is changed. It replaces the65536-byte
output buffer and4096 per-reference records with three BBC passes: layout,
reference/address validation, then direct BPUT output. Final aliases and the
entry wrapper chain have explicit definitions. A common BBC template emitter
merges original internal relocations with external bridge operands at their
original offsets; no post-write seek/patch is needed.

The prescan records only numeric GOTO/GOSUB/THEN/ELSE and RESTORE constants in
separate8192-byte bitsets, excluding strings, comments and DATA. All numbering
still validates; named labels still participate in duplicate checks. The sorted
symbol capacity is4096; scalar/array bindings remain256 pending an actual
self-source count. Static inventory is248 private binding-name candidates and205
definitions, not a compiler test or native fit result. This experiment is not
qualified or promoted; complete output identity, failures before OPENOUT and
actual self-source/native RAM remain its evidence requirements.

The prepared resource cohort includes numeric forward/backward/THEN/ELSE and
scoped targets, early RESTORE addresses, quoted/comment decoys, missing targets,
duplicate labels/numbers, an unrolled integer-store executable exceeding65536 bytes,2048
named labels and4097-label rejection. Large pure-capacity fixtures have explicit
known output rather than a claimed reference execution; conventional smaller
cases use the actual BBC oracle. The retained old-image baseline remains the
independent opcode/layout comparison. No result is claimed before execution.

The prepared common emitter caches the next internal operand and walks raw-byte
spans between internal/external addresses. Layout counts template size; validation
checks bridge resolution/order/address sizes without copying raw spans; the output
pass BPUTs each span directly. This avoids an extra BBC procedure/function call
per template byte while preserving byte order. Runtime packer proofs retain the
sorted, disjoint operand precondition. This is still an unexecuted candidate.

Routine definition positions are already ordered by the signature prescan. The
candidate now advances a scope cursor when the next definition's physical line
arrives, instead of scanning every routine on every source line. It adds no
metadata table or new language behavior. Scope/branch tests must prove the same
boundaries; no performance result is claimed from this unexecuted change.

The large-output fixture uses650 repeated integer stores and checks actual file
size above65536 plus native output650. This exercises code/operand addresses
across the old boundary with a short source. The real self-source inventory
will independently exercise the compiler's full embedded DATA catalog.

`streaming/probe_source.py` prepares a resource probe with optional BBC progress
PRINTs in its host driver. The target input stays the exact supplied compiler
source. It records phase/line/code/symbol/binding counts and failed/interrupted
runs, retaining old output on failures; an optional layout-only mode never
claims a generated compiler. A full successful resource image is still distinct
from C006's unmodified-main generation chain. These workflows have not run yet.

The unrolled resource run using fc67e57c was deliberately stopped during its large
case after observing slow interpreted validation; its first four compiles and
five rejection diagnostics are retained separately, with no native-phase/pass
claim. Candidate8eeea648 batches opcode counts, words, numeric packets, strings,
zero workspaces and DATA headers; its smoke180.807s retains identical complete
old images. A subsequent candidate uses length-aware semicolon BPUT for words /
strings. Source-line reading is also being prepared with the existing CR/LF,
NUL and255-byte checks inline, avoiding a BBC routine call per source byte.
These are compiler implementation changes; each revision needs fresh identity /
source-validation checks before promotion. No alternate BBC numeric format is used.

## Reader and repeated-image qualification

Candidate1b3e4b33 inlines the old source-character reader without changing CR, LF,
CRLF, NUL, maximum line length or final-newline handling. The complete39-case
baseline passes in196.992s, including15 native executions, rejection/output
preservation, deterministic repeat and GNU golden-image equality. Exact source,
driver, logs and results are frozen in `evidence/stream-reader-baseline-001`.
The earlier f11b3e22 word/string BPUT smoke passes180.881s with all four complete
old images identical (`stream-string-writes-smoke-001`). The larger resource
cohort is running on1b3e4b33; no resource or source-fit result is claimed yet.

## Withdrawn metadata-storage preparation

A mistaken static reading treated native string-array elements as256-byte slots.
The actual qualified MEMORY.md, FNmemwidth and memory/strings runtimes use
five-byte descriptors with separately owned contents. Thus csname$(4095) has
20480 element bytes plus its array descriptor and actual allocated text, not1MB
of fixed payload. The suggested private text packing was prepared but never
executed or promoted; its files are removed and that motivation is withdrawn.
Actual heap/code/arena use still needs measurement. No native failure or result
is attributed to this mistaken inventory.

## Interpreted bootstrap name-lookup experiment

MAIN.Z80 LOCATE/LOC1/LOC2 selects a dynamic-variable chain from the first name
character and then searches it linearly. Nearly all compiler private variables
currently begin with c, concentrating their host lookups in that chain. A separate
source-preparation experiment will remove that redundant prefix consistently
from private variable identifiers, preserving quoted text, DATA, REM, PROC/FN
names, source line numbers and the compiler algorithms. The result remains the
actual BBC compiler source, suitable for unchanged-main generations if qualified.
Fresh whole-image comparison and reference/native tests must establish behavior;
no speed benefit is claimed before measurement. This affects compiler-private
identifiers, not admitted user syntax or BBC variable lookup semantics.

## Complete resource cohort

Exact1b3e4b33 passes the full12-source cohort in3613.441s: six native executions,
six rejected sources, deterministic repeat, numeric/string GNU links and output
preservation. Its70076-byte unrolled executable prints650. The2048-label image
prints many-labels;4097 labels reject at physical4097,column8 before opening the
output. Four fresh separately numbered BBC oracles are retained; the shared
reference harness's counter is zero because those outputs were supplied from
the separate actual probes. All four complete smaller images remain identical
to the promoted7cac4bba baseline. `evidence/stream-resource-002` retains exact
inputs, images, logs, links and hashes. This is functional controller time, not
an Agon performance benchmark or self-source/native-memory result.

The identifier-only690fd519 smoke is now running. Reverse renaming has already
reproduced1b3e4b33 exactly; quoted text, DATA and comments are unchanged. No timing
or execution result is claimed yet for690fd519.

The690fd519 name-only smoke passes54.687s, with all four complete executables
identical to the promoted old-image baseline, four fresh actual BBC probes,
rejection/output preservation, repeat and GNU numeric/string links. This
compares to180.881s for the earlier f11b3e22 same-shape smoke (the intervening
reader revision has its separate39-case evidence). It measures this controller
workflow, not a standalone Agon benchmark or a controlled attribution of every
saved second. `stream-names-smoke-001` freezes source, map, outputs and proof.
The full39-case baseline on690fd519 is running before the self-source attempt.

Exact690fd519 passes the full39-case/15-native baseline86.029s, including
rejections, deterministic repeat and GNU golden equality, retained in
`stream-names-baseline-001`. The otherwise identical prefixed1b3e4b33 baseline
was196.992s; both are Pi5 automated CLI controller durations, with no hardware
calibration. The actual690fd519 source probe `stream-source-001` is now active
with explicit host-only PRINT instrumentation and unchanged target input.
Its next result must establish real source/resource limits; no native compiler
or source fit is claimed before that result.

## Self-source duplicate-helper rejection and correction

Actual690fd519 source scanning rejects at physical1655,column20: Duplicate
definition count. Counters0code/0symbols/204definitions/35bindings; old output is
unchanged. Duration371.199s, retained in `stream-source-001`. The new parameterised
byte-count helper accidentally shared the original bare slice-count parser's
name. The interpreter-host cohorts can distinguish those forms, but the admitted
compiler signature map requires unique routine names. No layout or native size
is inferred from this failed prescan.

The emitter helper is renamed PROCcodecount, leaving the existing slice parser
PROCcount unchanged. Source preparation now checks distinct PROC/FN names within
each family. Fixed prefixed source d5144921 and private-name source508a74f2 retain
2188 lines/208 unique definitions/248 private names. The fixed smoke passes57.312s
and all four complete old images remain identical (`stream-names-smoke-002`).
Six retained C003 slice/search/repetition/assignment/error fixtures are now being
rechecked against fresh BBC oracles before baseline and a new self-source probe.

The fixed508a74f2 six-source count-consumer cohort passes97.969s against fresh
BBC results: LEFT$/RIGHT$/MID$ explicit counts and starts, INSTR start, STRING$
repetition, scalar slice assignment/self-aliasing and SFIX overflow ordering.
All six native executions, repeat and GNU numeric/string links pass; frozen in
`stream-counts-001`. The complete39-case baseline is now running.

The corrected508a74f2 full39-case/15-native baseline passes86.013s, including
source validation, rejection preservation, repeat and GNU golden equality,
frozen in `stream-names-baseline-002`. The six targeted count-consumer results
and unchanged four-image smoke establish this name correction's scope; no
whole resource-cohort rerun on508a74f2 is invented. A new exact self-source
probe follows this qualified checkpoint.
