# Initial procedure and LOCAL tranche

The qualified first activation implementation adds scalar by-value PROC arguments and
LOCAL save/restore. FN result typing and caller-expression preservation follow
in a separate qualified tranche under C004. Neither is silently treated as GOSUB.

1. Prescan line-leading DEF PROC signatures in BBC BASIC, collecting forward
   calls, formal scalar types and lexical activation scopes. Stage all actual
   arguments before binding formals. Reject duplicate/unsupported formal modes,
   array parameters and unqualified declaration placements clearly.
2. Distinct PROC/LOCAL control markers own prior scalar/string bindings and a
   bounded LIFO arena. Save formal values before argument evaluation, preserving
   actual-BASIC snapshot behavior. Newly created formal/LOCAL bindings remain
   defined after return. Install zero/empty locals and fresh owned255-byte string
   buffers; restore prior descriptors/values in reverse order without rolling
   back unrelated global writes.
3. Preserve declaration-line skipping and multiline fall-through. ENDPROC must
   unwind recognised LOCAL records and require a PROC marker; it must not use
   RETURN/GOSUB semantics or skip an unfinished loop/GOSUB marker. Scope all
   named/numeric branch labels and reject cross-activation targets.
4. Reserve the private arena after emitted code and runtime workspace, initialise
   its pointers at native entry and check the user-RAM ceiling. It is not a second
   numeric representation, a source interpreter or a global string-heap rollback.
5. Qualify forward/recursive/nested calls, swapped arguments, all scalar types,
   dynamic locals, repeated/new bindings, strings/ownership, marker errors,
   declaration fall-through, bounds and deterministic output against actual BASIC.
   Recheck prior loop/conditional/string behavior before exact live promotion.
6. Experiments belong in C004/activations. FN, RETURN parameters, arrays and
   LOCAL ERROR/DATA remain clearly unsupported until their recorded tranches.

## Promoted ABI and limits

1. Source/runtime SHA and evidence are recorded in C004.md. The runtime is502
   bytes/27 relocations with compiler-patched control/numeric bridges. Save/install/
   bind/leave preserve IX/IY/SP; AF/BC/DE/HL are otherwise volatile. Save returns
   HL=record, bind consumes a constant formal ordinal plus IY=actual buffer.
2. Records contain flag/data pointers, type and old physical payload/descriptor.
   Numeric records are14 bytes; string records269 including a private255-byte
   capacity. Newly absent bindings are created before the snapshot, so they stay
   defined after restoration. Context is checked before LOCAL creation.
3. The32768-byte arena follows emitted code and bounded string workspace; the
   native entry resets its pointers and preserves MOS DE. No arena padding is
   emitted. Shared control capacity is256 records, including PROC/LOCAL/GOSUB/loops.
4. No-argument forms omit parentheses. Definitions begin their physical statement
   line (after optional numbering);128 definitions and16 scalar arguments are
   admitted. Labels from each definition through the next are activation-scoped;
   branches across these scopes fail compilation. Empty lists, RETURN/array
   parameters and LOCAL ERROR/DATA remain unsupported.
5. Exact full prototype, supplemental, ABI and selected live results are separate
   in C004 evidence. FN prefix/runtime experiments are not yet promoted.
