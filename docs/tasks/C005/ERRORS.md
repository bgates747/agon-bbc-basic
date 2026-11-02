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
qualify the source audit; they do not prove the unimplemented native recovery.

## Proposed native recovery boundary, not yet implemented

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
