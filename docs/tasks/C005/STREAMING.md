# Bootstrap resource closure design notes

The current interpreted-host headroom measurement does not prove that the native
compiler can fit beside its own metadata and output. The actual7cac4bba self-source
probe exhausts4096 address fixups at physical line108, preserving its old output
in1459.137s (`evidence/errors-source-gap-001`). The next actual self-source
probe, after language closure, must measure generated size, symbols, fixups and
RAM. This note records a possible bounded streaming emitter if those measurements
require it; no streaming implementation or size result is claimed.

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
duplicate labels/numbers, a DATA-backed executable exceeding65536 bytes,2048
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
