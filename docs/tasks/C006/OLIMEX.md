# C006 historical Olimex qualification

The original compiler completed12 compiler and10 generated-program cases and
two physical self-source generations with whole-image equality. Generations7
and8 were released. These are historical outcomes, not current bench procedures
or a statement of installed firmware/custody.

The sole authoritative reference for bench preparation, scheduling, access,
execution, recovery, restoration and check-in is the
[Extender Olimex bench guide](../../../../agon-extender/docs/operations/olimex-bench/README.md). Follow its linked instructions.
No local operating sequence is maintained here.

Results: C006/evidence/olimex-deployment-001, olimex-small-001,
olimex-self-a-bound-001, olimex-self-a-late-001 and olimex-repeat-001 retain
actual inputs, results, byte comparisons and the original timeout/late completion.
[First workload inputs](OLIMEX-R01.md) and [repeat inputs](OLIMEX-R02.md)
retain application-specific image and memory information.

## Compiler memory evidence

For source6597a0df, the checked324275-byte seed occupies&40000..&8F2B2.
Its explicit private heap is&8F2B3..&A7EFF (101453 bytes), activation arena
&A7F00..&AFEFF (32768 bytes), and guarded user-memory end&B0000 retains the
256-byte gap at&AFF00. Control records, scalar payloads and expression pools
already occur inside the static image. Private DIM/string contents use the
explicit heap; LOCAL snapshots use the arena. Native self-source execution
has passed on the pinned CLI and twice on this hardware. Fresh MEM in both
grants places user memory at&040000..&0BBFFF and MOS stack at&0BF800..&0BFFFF.
These actual workloads fit; stack high-water and arbitrary recursion are not
qualified by that result.

Native calls additionally use the MOS-provided ADL stack and preserve/restore
entry SP. Read-only EMOS source inspection finds exec24 calling the ADL entry
without installing a separate program stack; defines.h reserves2048 stack bytes,
and the startup source initializes SP from the linked stack symbol. These source
observations do not establish installed firmware memory or maximum stack usage.
