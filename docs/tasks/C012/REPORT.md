# Pinned firmware compatibility audit — November 8, 2026

The current compiler, reference interpreter, editor and fixtures have no identified
mandatory firmware exception by source/API inspection. Exact release firmware
checksums pass. None is newly runtime-qualified on this firmware pair: no target,
emulator, flash operation or installed-state readback occurred. The important
remaining gates are manual keyboard/graphics/file checks and clock validation;
the old text-only automated harness is not evidence for these new defaults.

## Verified selections

1. VDPlet v0.1.2-alpha release firmware vdp-vdplet-0.1.2-alpha.bin:
   1100304 bytes, SHA256
   b004570b607b45bbd6e87a3c704b65b23d3221981db3aac6cf2578aa22d766e3.
   Verified directly against downloaded release SHA256SUMS. Four downloaded
   checksum-listed artifacts pass; compressed debug ELF/map and other unneeded
   assets were not downloaded or claimed verified. Retained release metadata
   identifies source b6c7c58331bf4cbbd54dbc4a1301c124e5963622 and the UART repair.
2. Eirene3.1.0_uart0_rc_3 release ZIP hash matches its published .sha256:
   9c8a9a28b0f597e6a9294d806491ffca3902c16cf1876b092ae8944f65368061.
   Extracted mos-rc3.bin is100879 bytes and matches the Author's exact
   d7a51147f3381cd68d56f3fbe4605434a897dfae1b049269afeba09ec2b7eb50.
   Source97311c437093e416342a6c836cf9914f2ced027d; source inspection uses the
   matching release ZIP, not the current working checkout.
3. Olimex selector snapshot is retained from Extender's current standard.
   At audit time it selects integrated EMOS Eirene r04,131072 bytes,
   a25f1612f4aaa542c5488cf3266d968ad3d1d61e9df3b5ce2c680650f5d7a2ca.
   This is a scheduler-owned desired selection, not proof of installed hardware
   bytes and not a substitute for Alexe/Console8's bare RC3. Reconsult the live
   selector when reserving: future owner defaults may advance.

## Current candidates

Exact sizes/hashes are retained in evidence/audit-001/results.json. Manual
package verification checks52 payload entries plus manifest (53 total); benchmark
verification checks10 payload entries plus manifest (11 total). Files already on
cards/emulator SD were not reread; previous deployment receipts remain historical.

| Candidate | Inspection result | Remaining qualification |
| --- | --- | --- |
| Live compiler source70d3c5c6 / native40e4ae06 | Compatible interfaces by inspection; no asynchronous UART extension dependency | C008 actual load/prompts, file compile/run, numeric/strings/control/error cases on declared defaults |
| Generated standalone runtimes / manual tests00–11 | Same MOS I/O and legacy VDU interface; CPU-only numeric/control/memory routines have no VDPlet API dependency | Existing numerical equivalence is historical; repeat selected target tests before claiming new-pair validation |
| Mandelbrot exact source1eb897c8 / nativebad741db | MODE8, GCOL and PLOT handlers present; mode reply path retained | Full visible drawing, key wait, MODE1 return; Author's prior success does not identify this new firmware pair |
| Reference BASIC a1ae6d38 | Uses legacy synchronous output, file/keyboard APIs and sysvars retained in RC3 | Text load/run, errors and input; no new reference behavior result |
| Bundled nano editor051fcacb | MOS sysvars/getkey/editline/file functions retained; normal mode3 supported | Actual editor draw/navigation/save/exit; no new human result |
| C011 suite2cb67aac / checks6f8ff63c | No async25h/42h/43h dependency; same graphics/file interfaces | Still not compiled/run on target; Author pilot/correctness before timings |
| C011297-byte clock helper2f6e5564 | API08 returns current sysvars pointer; clock remains four bytes at offset0 | Regenerate clock.dat after firmware/reboot, check advancement and actual clock scale; source inspection is not timer qualification |
| Historical automated CLI qualification tooling | Old source/runtime evidence valid only for recorded inputs; default wrapper/text-only peer does not bind this release firmware pair | Do not run unchanged and label it new-default qualification. Any future emulator tranche needs explicit scope, Oryx custody, correct firmware and existing human gates |
| C009 anonymous labels | Unimplemented proposal, no runnable candidate | No firmware exception or test implied |

## Interface findings

1. Compiler runtime calls MOS00 getkey,08 sysvars,09 editline and0A–0E handle
   file functions, plus ordinary RST10/RST18 output. RC3 retains those public
   slots and register-preservation bridges. Its replacement of trial async
   42h/43h with25h does not require migration of these synchronous clients.
   No private absolute ROM routine address or direct VDPlet SDK import is
   introduced by our current runtime. Existing third-party/reference code
   retains its own declared interfaces; this is not whole-binary disassembly.
2. Native filename buffers end in CR. RC3's release source mos_file.c,
   resolvePath, still accepts control-character termination, so this is not
   silently assuming NUL-only filenames. Actual file semantics/paths still
   need target checking. Existing long-filename admissions remain unchanged.
3. RC3 sysvars retain clock offset00 (four bytes), VDP protocol flags04,
   keycode17 and keydown18. Native MODE waits on bit4 of flags04; MOS MODE
   replies still set the mode flag. GET/Escape handling still needs actual
   keyboard tests. No claim of a fresh Escape timing/latency pass follows.
4. Release-linked VDU dispatch/mode source hashes match firmware-source.json
   for vdu_stream_processor.h and vdu.h. Source handling still includes VDU18
   GCOL,22 MODE,25 PLOT and sendModeInformation replies. Retained build source
   agon_screen.h includes MODE8 at320x240/64 colours, modes1/3 and their
   legacy screen mappings. Its inspected hash is recorded separately; it is
   not incorrectly equated to the manifest's mode_sha256 (which names vdu.h).
   Receiver RX recovery is present; no promise of rendering/throughput follows.
5. Clock unit is nominal centiseconds, updated by2 per VBlank in RC3 interrupt
   source. RC3 release warns that an asynchronous producer waiting for CTS
   inside the ISR can delay VBlank, RX and keyboard. CBAS does not start that
   producer, but concurrent output from another producer would invalidate a
   quiet timing comparison. C011's double sampling cannot prove clock accuracy
   or recover missed/delayed ticks. Keep raw ticks, fix the display/firmware
   configuration, and validate clock behavior before interpreting elapsed
   seconds. Millisecond-or-better resolution is not established here.
6. Released VDPlet has pixels/text96/borrowed rows/read bytes, with async worker,
   counted return and PCM sink disabled. CBAS requires none of those optional
   worker extensions. No request to enable them or use a private image follows.

## Disposition and reproducibility

The audit brief was committed/pushed as9255326 before artifact retrieval or
inspection. audit.py verifies release bytes, package contents and candidate
identities in a short offline run. Initial audit development mistakenly mapped
mode_sha256 to agon_screen.h; that assertion stopped before evidence publication
or any target operation. Builder provenance establishes the correct file vdu.h;
the corrected check passes. Unauthenticated VDP release access returned404;
configured authenticated gh retrieved the official release, not a substitute.

No required firmware exception is identified. Current development guidance now
binds the Author's pins and records unresolved runtime gates in C008/C011.
Frozen historical packages/evidence are unchanged; their old runbooks are not
proof of installed firmware and the old claim that no firmware change is needed
is conditional on already matching today's defaults. No card, emulator profile,
startup file or component-owner source is modified. Hardware and test permissions
remain separate; no reservation or new run starts solely from this audit.
