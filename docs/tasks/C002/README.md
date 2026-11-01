# C002 numeric runtime experiment

This experiment executes an isolated BBC numeric package in a standalone MOS
program and compares its packed results/errors with actual BASIC V evaluation.
The compiler remains BBC BASIC; these assembly routines are its prospective
runtime and Python only orchestrates qualification.

From the project root, first provision/verify the shared automated profile with
the live compiler test runner, then run numeric qualification:

```bash
.venv/bin/python compiler/tools/test_compiler.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
.venv/bin/python docs/tasks/C002/tools/test_numeric.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
```

The CLI binary must be host-native. [The compiler runbook](../../../compiler/README.md)
gives its reproducible source build command. The numeric runner accepts
`--toolchain` for the AgonDev bin directory. It reuses the canonical generated
`.emulator/` launcher and refuses to run if its CLI does not match the argument.
Run these commands sequentially: they own the same automated profile.

The BASIC reference source and packed fixture are generated under ignored
`build/`. Each fixture record is 18 bytes: selector, alias flag, five-byte left,
five-byte right, expected error code and five-byte expected result. The native
probe reads only the first 12 bytes; expectations are compared by the harness.
For errors, the expected result is the unchanged left operand. Conversions
are compared with integer assignment (SFIX) and division by one (SFLOAT).

Successful output includes a JSON report with input hashes, status counts and
duration. A case mismatch fails qualification and is retained in the report.
Selected reports, cases, oracle source, fixture bytes and logs are retained in
`evidence/`; build products/listings remain disposable. [ABI.md](ABI.md)
documents the pointer, stack, packing and error contracts, and
[vendor provenance](vendor/PROVENANCE.md) identifies the exact reusable source.

This tranche does not enable compiler expressions or demonstrate self-hosting.
Its results are automated eZ80/MOS qualification, not physical hardware timing.
