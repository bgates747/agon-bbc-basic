# Source error-handler compatibility before implementation

Native recovery must follow the reference's actual stack behavior. Source audit
shows that an error resets stack pointers rather than running ordinary LOCAL
restoration. Actual reference probes must settle the resulting binding and
string ownership effects before implementing recovery. No native error-handler
language is promoted by this document.

## Pinned source contract

1. EXEC.Z80 ONERR saves old ERRTRP/ONERSP as LOCAL records for ON ERROR LOCAL,
   then captures the resulting stack pointer. Global ON ERROR sets ONERSP0.
   OFF clears both. The handler body starts after the declaration; installation
   skips the remaining physical line. LOCAL ERROR itself is a no-op.
2. MAIN.Z80 ERROR sets the error text, resets SP to ONERSP or SPL, finds the
   source line and stores ERR/ERL. Error0 bypasses a trap. ERRTRP is not disabled
   on entry. Do not introduce implicit recursion prevention or normal LOCAL
   restoration when the reference discards records instead.
3. EXEC.Z80 THROW evaluates the number, uses its low byte and evaluates a string.
   REPORT terminates at NUL; embedded zero can truncate the reported message.
   String FN pointer carriers require the same audit as filename consumers.
4. Test global and local handlers, locals declared before/after installation,
   nested calls/loops, retained handlers, code wrapping, message/line behavior,
   OFF and fatal zero. Verify string contents after subsequent LOCAL allocation:
   native private local buffers cannot be discarded while bindings point into
   reused arena storage. Preserve the observed value with valid owned storage.
5. `errors/reference.py` owns the first actual observations. It runs the pinned
   interpreter through the canonical CLI wrapper; source inference is not itself
   a test result. Scope/results belong in the retained evidence and dated log.

## First actual observations

`error-reference-001` passes9 cases in1.105s. Global handlers see changed numeric
and string locals; they remain valid after another string LOCAL allocation. In a
FN, LOCAL before ON ERROR LOCAL restores on normal return; LOCAL after it is
discarded and its changed value persists after return. String contents persist
after later calls. The same handler catches successive errors. LOCAL ERROR is a
no-op; ERROR257 reports1, ERROR-1 reports255 and REPORT stops at embedded NUL.
ERL names the actual failing definition line, not the caller's line. These results
qualify the source audit; the later native ABI and language cohorts provide
separate implementation evidence.

## Native recovery boundary and source integration contract

1. A handler state holds the native target, local/global mode, saved GOSUB depth,
   captured CPU SP, typed-control top and activation-arena top. LOCAL installation
   saves the previous state in ordinary five-byte LOCAL records so normal FN/PROC
   exits restore it. Installation is valid under a loop marker or at main level;
   do not impose act_save's narrower top-marker precondition without a probe.
2. Error dispatch records ERR/message/ERL and keeps the handler enabled. For a
   local handler it discards control/arena records above the captured checkpoint;
   global/fatal paths use the entry stack and root control/arena bounds. Retained
   records remain available for ordinary return. Do not restore discarded values.
3. Before reclaiming private arena storage, inspect discarded string LOCAL records.
   If the current binding points into the reclaimed arena, copy its current bytes
   into independently owned global storage and replace that descriptor. Repeated
   LOCAL records for the same binding must not rescue obsolete prior contents.
   Empty descriptors need valid future allocation behavior as well. Failure to
   obtain space is fatal error0, not recursive trap entry.
4. Source lines need native location marks only for programs using handler/error
   facilities. A prescan must detect tokens outside quoted strings, DATA and REM.
   Preserve conventional line numbers; define the line-numberless dialect's ERL
   explicitly. Successful FN/PROC/GOSUB return must restore the caller location,
   while errors retain the failing callee location. REPORT stops at NUL.
5. The runtime needs explicit patched control/arena/heap/entry/depth pointers and
   typed-control/string bridges. This is a new standalone adapter with an auditable
   ABI, not a copied interpreter parser. Qualify native guard/stack/ownership
   behavior and differential nested handlers before promotion.

`error-reference-002` passes8 additional cases in11.436s. ON ERROR LOCAL installs
at root and under a FOR marker. Earlier local strings restore while discarded
inner local strings persist; later owned LOCAL allocation does not change them.
LOCAL OFF restores the prior handler on normal return. Error-number conversion
fails before message-FN effects. Actual ERROR0, wrapped256 and OFF paths bypass
the handler, print the message/line and return to BASIC's prompt; keyboard BYE
finishes each session. No native-handler result is inferred from these probes.

## Standalone helper experiment, not language promotion

`errors/errors.s` first packaged1511 bytes/116 internal ADL24 relocations and
passes two independent link checks. Its explicit patch slots connect control,
activation bounds, heap/string helpers, saved entry SP and exit. Four opaque5-byte
LOCAL state snapshots preserve normal restoration; error transfer instead rescues
current lost string values and discards records. Fatal exits skip value rescue.
The native ABI probe now passes1.020s; source-handler language and self-hosting
remain unqualified. The BBC frontend is prepared but has not integrated this module.

Conventional ERL uses the supplied BASIC line number (0..65279). The proposed
line-numberless dialect uses0 when the failing physical line has no BASIC number;
compile diagnostics continue to use physical file positions. Uncaught errors
need the actual reference leading CRLF, REPORT text, optional ` at line n` and
trailing CRLF before returning to MOS; source handlers still get REPORT without
an implicit newline. A small unsigned16 metadata formatter implements line output
without replacing the BBC numeric representation/package. The unqualified helper
now includes this formatter; its ABI probe must cover65279 and NUL truncation.

`error-abi-001` qualifies root/loop LOCAL installation, global/local CPU/control/
arena transfer, retained handlers, fatal zero, numeric discard versus earlier
normal restoration, repeated/max255/empty string rescue and growth, subsequent
arena overwrites, full line packet, REPORT NUL truncation and line65279 display.
The complete probe and exact module/other runtime metadata are retained.

## Frontend integration and startup REPORT correction

The first2079-line source SHA cbd443a1 passes two exact numbered programs163.859s
and an initial six-program cohort374.876s, with independent complete runtime and
entry/bridge checks. The later initial-REPORT probe shows ERR=0, ERL=0 and the
pinned `(C) Copyright R.T.Russell 2025` notice followed by CR/LF/LF. The original
empty-message startup assumption was wrong; preserve this quirk rather than
modernising its date or omitting its output.

The1559-byte/118-relocation adapter now copies that33-byte notice at entry; its
revised ABI probe passes including actual notice output. A three-INSTR prescan
filter avoids character-by-character keyword work on lines containing none of
ERR/ERL/REPORT, while the existing quote/comment/word checks still determine the
feature flag. Exact source SHA5a8cc4f6 passes the first six-program cohort357.251s;
all six complete runtimes, twelve error configuration bridges, four activation
bridges, numeric/control bridge and entry/arena/heap/saved-SP targets match.
`errors-cohort-001` retains this source; earlier evidence retains its older scope.
No source-handler language is promoted yet. Cohorts use a fresh pinned BASIC per
reference program and fixed explicit line numbers, preventing shared DATA/error
state and keeping ERL comparisons meaningful. Fixture @EXIT@ is instantiated as
END for the native program and MOS BYE for the reference only; it is not syntax.

## REPORT token dependency correction

MAIN.Z80 REPORT calls TEXT/OUT, which expands token bytes instead of writing every
byte directly. Seven actual reference cases1.016s show AND/ABS/CIRCLE/OSCLI and
compressed error fragments, with LF specifically bypassing token expansion and
NUL still terminating the message. The earlier raw-byte reporter was incomplete.

The corrected2481-byte/126-relocation adapter includes an altered OUT path and an
858-byte private copy of KEYWDS, byte-checked against the pinned basic.bin at
&42F15. `report_keywords.inc` retains the original1981–2025 copyright and naming
notice; repository license applies. `build_report_keywords.py` adapts assembly
data, not BASIC programs. No interpreter address/state/parser is linked. Private
MOS output replaces OUTCHR's COUNT/WIDTH dependency; those language controls remain
outside this admission. Exact token spacing and the TEXTLF exception are retained.
The revised native ABI (`error-abi-003`,1.017s) prints the actual notice, token
expansion, NUL-truncated messages and default fatal line format while preserving
all earlier checkpoint/ownership checks. Its BBC source SHA8bb1dd9a is experimental;
prior cohorts remain scoped to their earlier helper and are rerun for this source.

A final one-program high-byte sweep complements the seven diagnostic REPORT
cases:128 successive local handlers report CHAR128..255 through the actual
reference and native paths. Its result is not yet claimed. A separate I/O cohort
is prepared for real keyboard Escape17 recovery (old string preserved, ERL40)
and eight-handle cleanup after caught END and uncaught ERROR.

## WHILE re-evaluation attribution correction

The final33rd-index case fails with native ERL40 versus actual ERL60. The full
failed cohort is retained in `errors-loop-attribution-failure-001`; changing the
oracle to40 would hide an observable divergence. Source audit shows ENDWH1 calls
EXPRI directly without XEQ updating CURLIN, so a direct failing re-evaluation
belongs to ENDWHILE. Five fresh reference probes1.069s additionally establish
that a normally returning FN in that condition resets attribution to the WHILE
line, while same-line WHILE/REPEAT/FOR body failures belong to their body line.

The corrected source SHA44533e0d changes only line11220: it omits the extra WHILE
condition-entry mark, retaining the existing marks for REPEAT. Initial WHILE
still has its ordinary statement mark; normal FN returns retain their existing
caller mark, preserving the observed reference quirk. Subsequent body statements
already carry their own correct marks. No error-runtime or numeric code changes.
Earlier0..29 cohorts contain no WHILE and retain their exact qualification scope;
new30..38 cohorts include direct/FN-return conditions, all three same-line bodies
and the128-high-byte REPORT sweep. Their results are pending. Selected unchanged
old images and the full compact baseline must be checked on this exact source
before promotion. There is no new dynamic source-line extension or interpreter fix.

## Held Escape at handler entry

The first real keyboard I/O cohort exposes actual reference ERL30 (handler),
versus native40 (INPUT), while both preserve the old string and Escape text.
`errors-escape-attribution-failure-001` retains all three compiled programs and
those observations; file cleanup had not executed. OSLINE jumps to LTRAP1, which
clears FLAGS but leaves a held KEYDOWN/KEYASCII visible. XEQ selects the handler's
CURLIN then TRAP can raise Escape again before its first statement. It is a
held-key mechanism, not an unconditional rule that every Escape names a handler.

A direct MOS probe2.070s returns editline1B, sysvar ASCII1B and down01. The new
49-byte err_trap helper polls documented MOS sysvars5/18h at native handler entry,
with IX/IY/SP preserved on ordinary return. It raises17 again while Escape is
held; released/no/other keys return. No interpreter FLAGS/keyboard globals are
linked. A mandatory entry source mark also handles an empty/comment body. General
asynchronous Escape elsewhere remains unqualified; this admission covers line
input and source-handler entry, not every interpreter keyboard safe point.

Exact source SHA7cac4bba embeds2530 bytes/128 relocations and24 exported addresses.
The complete previous2481-byte module prefix independently rebuilds identically;
its native ABI passes1.068s (`error-abi-004`). Actual resumed I/O checks pass8.127s:
Escape ERR/ERL/old string/REPORT match, a caught handler reads its still-open file,
and caught END/uncaught ERROR release all eight handles. Exact driver/source/image
identity is verified before reuse. This8.127s excludes completed compilation.
An obsolete literal40 assertion and an IO signature crossing its first relocation
are fixture/checker failures retained with the final evidence; neither changes the
actual reference oracle. Core-handler and baseline requalification remain pending.

## Development promotion and exact qualification scope

The2111-line BBC source SHA7cac4bba is copied verbatim to compiler/compiler.bas.
It has197 definitions and250 static private binding-name candidates; the latter
is an inventory, not self-source acceptance. The2530-byte/128-relocation module
and licensed keyword include promote to compiler/runtime/errors.s and
report_keywords.inc; the runtime packer and table generator promote to
compiler/tools with only their host root/default paths adapted. Target compilation
still takes place entirely in BBC BASIC. No numeric vendor/interpreter source changes.

The retained conventional corpus covers39 programs across exact earlier versions:
0..29 at8bb1dd9a, corrected30..38 at44533e0d, plus selected full-image equivalence
24/25. This is not labelled a full39-case rerun on7cac4bba. The held-key addition
has an independent identical old-module prefix proof, current native ABI1.068s,
current CORE6 fresh-reference/repeat/link checks386.004s, two modern ERL0 programs
136.623s and the resumed three-program I/O checks8.127s. The exact current source
also passes the39-case/15-native compact baseline and assembly golden86.851s.
Nine exclusions and output preservation retain their44533e0d evidence; current
baseline also covers malformed source and EVAL. The existing C004 LOCAL ERROR
negative fixture becomes LOCAL DATA because LOCAL ERROR is now the admitted no-op.

All eight live runtime packers and the live keyword generator reproduce the exact
promoted source (`errors-repack-001`). Source-copy identity and complete package
rebasing qualify this promotion; a separate selected live-path check is recorded
when executed. The Author's waiver permits this development checkpoint, not a
claim of human/hardware review. C005 resource closure remains open. Full native
compiler execution of the39-case corpus is prepared under C006; it is not yet
claimed. No new benchmark or physical result is implied by these controller times.
