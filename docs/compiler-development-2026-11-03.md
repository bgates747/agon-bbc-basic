# Compiler development — 2026-11-03

The compact compiler now completes source layout inside executable RAM, but its
mandatory initialization storage cannot fit beside that executable. Retain the
measured layout and reduce private storage/code further; no native compiler or
self-hosting result exists yet. Pi5 automated CLI work is authorized; Oryx stays
offline and no physical test is implied.

## Actual compact-source layout and allocation bound

Exact2f81c6fb completes layout339291 bytes, body265236 (prior body390190), with
2078 symbols/213 definitions/254 bindings. Private heap limitA7F00 leaves86437
bytes. Handwritten inventory of its exact typed DIM shapes and pinned assembled
templates gives112761 mandatory payload bytes before array headers, owned string
contents and allocation overhead: a26324-byte minimum deficit. It cannot initialize.
After phase2 begins, deliberately stop only the owned CLI rather than spend two
further passes writing that unusable image. Controller1366.536s is a partial-run
measurement, not successful compile time. Original output remains unchanged.
compact-source-001 retains raw failure/log/source/provenance and an explicit
layout/disposition/bound record. No output pass, native initialization or native
compiler generation is claimed.

## Private zero-tail qualification

Prepared14e56cee stores465 initialized control bytes and streams the unchanged
8192-byte zero tail. Template storage saves8192 and source text19104 bytes;
actual native fit is not inferred. Start nine actual-reference/native cases,
requiring complete output identity with2f81c6fb. All runtime capacity, public
numeric/string semantics and original control-image bytes remain unchanged.

Zero-tail14e56cee passes nine native programs118.267s against actual BBC outputs,
repeat/GNU and all nine complete2f81c6fb images. Freeze zero-tail-frontend-001.
Refine bounded private symbol packing (three-byte addresses/two-byte sorted
indices) and sparse reusable numbered-target pages in COMPACTION.md before
implementation. Accepted source-program numbers/types and capacities do not change.
