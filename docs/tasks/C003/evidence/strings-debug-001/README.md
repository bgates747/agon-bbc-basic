# String core first smoke failure

The empty opcode-prefix call used for raw context pointers reached the existing
PROCbytes FOR loop with zero text length. BBC executes that reversed-bound loop
once, so it inserted EF before each pointer and corrupted the context layout.
The smoke test correctly failed with `No room`. The corrected emitter skips
empty opcode strings. Review also found that concatenation needed an explicit
24-bit BC reset before LDIR; byte-only B clearing is insufficient in ADL.
No result from this source is accepted as qualification.
