# Reading the retained qualification evidence

Current case lists, reports and execution logs define a test's actual scope.
An artifact's presence in a snapshot does not establish that it was executed,
passed, promoted, or reviewed by a human.

1. Initial resource archives include complete top-level snapshots of disposable
   build directories. Those directories also held earlier C004 experiments;
   some snapshots therefore include older resume logs and independently linked
   `.dat` files. These are retained context, not extra executions attributed to
   the enclosing run. Use that run's `cases.json`, `results.json`, compiler hash,
   driver, compile/native log markers and reported link bases as authoritative.
2. `resources-linear-in-progress` is explicitly partial/time-limited. Its two
   complete images are compared with `resources-indexed-001`; it is not a full
   qualification pass. `array-reference-002` likewise records a reference stall,
   with completed observations separated from the unfinished case.
3. `resources-promotion-001` reports selected checks of the exact live source.
   Full prototype and selected live coverage retain their separate scope.
4. Later array archives select only the current scripts, inputs, execution logs,
   images, reports and independently linked modules at the reported bases.
   Manifests establish retained-file identity; they do not broaden test scope.
