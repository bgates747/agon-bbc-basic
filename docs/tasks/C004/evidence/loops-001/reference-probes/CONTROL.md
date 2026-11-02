# Typed loop control records

Loops require runtime state separate from numeric/string expression temporaries.
The selected design uses bounded typed records, with distinct GOSUB markers so
an unfinished loop cannot be mistaken for a return address. Recursive entries
receive independent limit/step copies rather than static per-site state.

1. Each record has32 bytes: type at0, reserved1, body/test pointer at2..4,
   FOR variable pointer5..7, physical width8, five-byte limit9..13, five-byte
   step14..18, negative-step flag19; bytes20..31 reserved. All pointers are ADL24.
   A256-record private area and explicit next-free pointer provide a checked
   resource bound. The executable's start trampoline resets it on every entry.
2. Types1/2/3/4 are REPEAT/WHILE/FOR/GOSUB. REPEAT and WHILE closing sites check
   the top marker before evaluating their condition. GOSUB installs type4 and
   RETURN requires it, preserving reference errors when loops remain above it.
   PROC/FN will extend this contract; they must not share GOSUB exits.
3. Native loop code retains lexical pairing (32 source nesting entries).
   REPEAT starts a marker then labels its body. UNTIL converts its expression
   with SFIX and repeats through the recorded body pointer while false.
   WHILE starts a marker whose pointer denotes its condition, and ENDWHILE
   returns there without pushing another marker. False WHILE pops and exits.
4. FOR stores its initial binding before evaluating limit then optional step.
   The two completed five-byte values are copied into its new record; default
   step is integer1. Its body always executes once. NEXT adds step using the
   qualified numeric adapter, performs the destination conversion, stores exact
   physical bytes, and compares the resulting full numeric value with the
   captured limit. A byte variable's stored low byte does not narrow the full
   value used by that immediate comparison. Negative step terminates on <;
   otherwise on >. NEXT named-variable search may discard intervening FOR
   records, preserving the reference's distinct mismatch errors.
5. Runtime helpers preserve IX/IY/SP on ordinary return; repeat paths discard
   exactly their own native CALL continuation before jumping to the recorded
   native loop position. Numeric calls use a relocated local trampoline patched
   to the qualified adapter. Failure returns carry/A and never jumps through
   interpreter state. Explicit source scope and qualification must establish
   every admitted form before promotion; this document alone is not evidence.
