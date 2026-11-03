# C006 physical qualification run c006-r01

This finite run tests the qualified native BBC-written compiler and its outputs
on the shared Olimex, without changing installed firmware or normal startup.
This plan alone grants no custody and records no physical result. The frozen
offline bundle and fresh Extender grant identify the exact inputs and bench.

## Inputs and memory

1. Bundle: `docs/tasks/C006/evidence/olimex-fixture-001/`. Its `manifest.json` pins
   every payload, expected result, case specification and command file. The
   preparation tool admits only completed four-generation, baseline39,
   representative12 and error39 evidence with matching source/image identities.
   Manifest SHA256:
   `05149bd76c5f23f8f6bf97c8db7bde3871e858a1e579a55784f05dd3a84d4787`.
   There are40 uploads/441398 total bytes, including111810-byte source and
   the324275-byte compiler. Ten expected program images total102941 bytes.
   Planned generated-image retrieval adds648550 bytes for the two self-compiles,
   two preserved41-byte rejection outputs and the5-byte file fixture.
2. Source SHA256:
   `6597a0df3f99b4f43c42bff1cdbc59f5fdf730c57837f3d4112a598fbfbe5fb8`.
   Standalone compiler:324275 bytes, SHA256
   `299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0`.
3. The full static image (including emitted runtime, initialized control frames,
   scalar storage, expression pools and string workspaces) occupies
   &40000..&8F2B2. Private heap is&8F2B3..&A7EFF (101453 bytes), activation
   arena&A7F00..&AFEFF (32768 bytes), guard&AFF00..&AFFFF (256 bytes).
   There is no additional application BSS above this bound or in MOSlet memory.
   Self-source output is streamed to a file rather than buffered in RAM.
4. Entry preserves/restores the inherited MOS ADL stack/registers; the runtime
   does not install a private CPU stack or change interrupts/MBASE. Actual
   generation equality proves this workload on the pinned CLI, not installed
   EMOS stack high-water or arbitrary recursion safety. No worst-case CPU stack
   usage has been measured. Record fresh installed MEM before invocation and
   reconcile any incompatible map with Extender; do not equate free MOS heap
   with stack capacity or use generic upper-RAM freedoms.

## Finite operation sequence

1. Reserve C006 using this absolute plan path, receive Extender's explicit fresh
   grant and current component/configuration provenance, then assert the lease
   immediately before each target operation. Preserve the incoming directory,
   display mode/route, startup, listener, firmware and wiring. Obtain actual
   CLI, neutral admitted input, listener offline/no pending and idle worker.
2. Use the maintained joined-DTR/RTS passive serial reader. At verified CLI
   enable VDU2, emit a fresh printable sentinel, and require its actual capture
   before treating Legacy text as observed. Record MEM and reconcile its map.
   Port-open and keyboard-drained receipts alone are insufficient.
3. Start `EMOS sdserve --fast /` only from the observed CLI. Require protocol2,
   use pinned staged tools, create only the declared fresh fixture/result roots,
   upload all declared payloads (including both existing-output sentinels),
   independently retrieve and compare every uploaded file. Resolve each worker
   before the next operation. Never overwrite a currently open EXEC file.
4. EXIT via a fresh metadata connection and observe offline/no pending plus
   actual CLI. Invoke each verified compile-N.txt exactly once, gate each of its
   two filename inputs on the actual new prompt, and require the correlated
   compile end marker and admitted listener before retrieval. All12 compiler
   returns are expected0, including the two caught diagnostics. Compare ten
   complete output binaries with the frozen emulator outputs and both rejection
   outputs with their prior sentinels; retain diagnostics and raw console bytes.
5. For each of the ten accepted programs invoke its verified run-N.txt once
   after listener EXIT and observed CLI. Require its exact visible output and
   end marker/listener return. Retrieve native-test.dat and require exactly
   FF74657874. No benchmark loop or extra workload is included.
6. At observed CLI invoke self-a.txt once using the deployed compiler. Observe
   its actual source/output prompts and completion; retrieve self-a.bin and
   require all324275 bytes equal the qualified seed. Then invoke self-b.txt
   once using that hardware-produced compiler on the same exact source, and
   require a second complete matching image. Do not infer an unexecuted pass.
7. Retain each invocation, keyboard journal, raw capture, transfer job and
   byte-comparison result with start/end observation times. Close/reopen the
   maintained bounded capture only at verified CLI between long stages,
   qualifying each new capture with a fresh sentinel.

## Timing and stop boundaries

1. All source/build preparation is offline before reservation. Exact bundle
   byte totals and manifest identity are supplied with the reservation. Retained
   staged-transfer measurements are43.24s upload and243.20s download for1.1MB;
   these give transfer planning context only, not a guarantee for many files.
   Allow roughly10–20 minutes for setup, individual verified transfers and
   prompt handling, with actual durations recorded separately.
2. There is no comparable installed physical compiler timing. Native unlimited-
   speed CLI self-source takes about1997 controller seconds; it is not a
   physical estimate. Revise the second physical pass estimate from the first
   observed hardware pass. Host elapsed last-input-to-observed-completion is
   reported with printer mirroring and observation latency, not as CPU time.
3. Observation bounds:600 seconds for one small compilation,120 seconds for a
   small generated program,5400 seconds for each self-source compilation.
   These deliberately generous operational bounds are not calibrated performance
   promises or deadlines that authorize interruption. Before each long stage
   establish a fresh capture with7200-second lifetime and ample remaining time.
4. Any missing/ambiguous prompt, unexpected application/MOS diagnostic, nonzero
   return, unexpected bytes, reset/admission boundary or observation-bound expiry
   stops subsequent dispatch. Preserve current lease, foreground state and all
   journals; report to Extender for reconciliation. Never automatically reset,
   repeat RUN/SAVE, create a new request for uncertain work, discard spools or
   infer CLI return from silence. Use the original maintained status/resume
   mechanism only for an existing uncertain transfer.

## Restoration and release

1. After known application return finish retrieval, exit the listener with fresh
   offline/no-pending observation, restore the incoming directory and text/cursor
   state through admitted CLI, disable VDU2 with VDU3, close owned capture/input
   sessions and confirm no owned transfer/job/reader/reset holder remains.
   Leave installed payloads/results only in the declared project roots.
2. Preserve mode/route and startup bytes. No flash, reset, SD unmount/eject,
   startup change, keyboard-source change or production installation is planned.
   Allow about5 minutes for actual clean-state verification/handback, separately
   from offline analysis. An uncertain application keeps custody until resolved.
3. Retain a fresh lease-bound physical clean-state observation with component
   hashes/provenance, release through the canonical helper, then notify Extender
   immediately with the durable handback. Report physical functionality,
   automated emulator evidence and human/optical acceptance separately.
