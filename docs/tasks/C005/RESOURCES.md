# Initial bootstrap resource checkpoint

The compiler now admits256 shared PROC/FN definitions and transfers only the
logical bytes of a string FN result. Its sorted symbol index preserves complete
output bytes while reducing label-lookup work. These changes remove an observed
source limit; arrays, I/O, error handlers and self-hosting remain unfinished.

## Implementation and evidence

1. The completed C004 source has140 definitions. The original self-source probe
   rejects the128-definition cap in295.201s, preserving existing output. A
   capacity-only prototype reaches `Unsupported statement ON` in780.740s.
   These retained probes are not native self-compilation evidence.
2. The shared signature tables now hold256 entries. Return collection skips
   DATA/REM payloads. A separate sorted integer index accelerates symbol lookup;
   symbol insertion order, addresses, duplicate detection and case sensitivity
   remain unchanged. The compiler and all these algorithms remain BBC BASIC.
3. The string runtime appends `rt_strcopy` at623:633 bytes total, two relocations.
   HL points to a length-prefixed source and DE to a disjoint/identical256-byte
   destination. Copy LEN+1 bytes; preserve IX/IY/SP; AF/BC/DE/HL are volatile;
   return A0/Z/NC. Caller-prefix snapshots still save full256-byte string slots.
4. The direct copy ABI passes in1.068s, FN smoke in92.787s, three independent
   string-consumer/slice programs in230.767s and baseline39/15 in62.095s.
   `evidence/capacity-copy-001` freezes that earlier bounded-copy prototype.
5. The original256-routine batch compiled two images and rejected257/DATA cases,
   then hit its900s guard during a fresh repeat. It is partial, not passed.
   `evidence/resources-linear-in-progress` preserves its driver/log/images/status.
6. The indexed prototype passes all five cases in611.470s:256-routine native
   execution, empty/max/NUL string FN results,257 rejection and two DATA-return
   scan rejections. Fresh repeat and independent numeric/string links pass.
   Both complete executables match the earlier linear-lookup images byte for byte.
   Baseline39/15 and GNU golden pass in66.030s. See `resources-indexed-001`.
7. Exact promotion is SHA256
   `0f0884ca11790d51c991cee68d8caa180e21f0fdecf512b7dcf341bbc7fafc4c`,
   1564 ordered loader-safe lines. All four live runtime packers reproduce it.
   Live baseline65.921s, resource smoke102.772s and four carrier checks74.472s
   pass; `resources-promotion-001` retains those selected results. NUM/control/activation/vendor
   sources remain unchanged. No human, hardware or benchmark-speed claim follows.

## Separate array preparation

1. `memory-abi-001` freezes a734-byte/83-relocation helper and passing1.016s native
   ABI: wide zeroing, exact bounds/overflow, widths/strides,16 dimensions, early
   checks, failure atomicity, guards and index/stack preservation. No array syntax
   is admitted by that helper test or by its placement in the task directory.
2. `array-reference-001` contains actual interpreted observations. Repeated DIM
   and raw-target mutation contradict the initial simplified DIM reading. The
   ARRAY contract and unintegrated frontend must follow the reference evidence
   before language qualification/promotion. The live compatibility matrix still
   lists arrays/DIM/indirection as unsupported.
