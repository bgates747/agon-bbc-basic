# Firmware defaults

Use the Author's pinned firmware for new qualification and deployments. Existing
qualification records describe their original versions; they do not establish a
pass on these defaults. See the [November8 audit](../docs/tasks/C012/REPORT.md).

1. Alexe and Console8 VDP: [VDPlet v0.1.2-alpha](https://github.com/bgates747/agon-vdplet/releases/tag/v0.1.2-alpha).
   Use the release firmware and verify SHA256SUMS. Selected firmware is1100304
   bytes, SHA256b004570b607b45bbd6e87a3c704b65b23d3221981db3aac6cf2578aa22d766e3.
2. Alexe and Console8 MOS: [Eirene3.1.0_uart0_rc_3](https://github.com/bgates747/eirene-mos/releases/tag/3.1.0_uart0_rc_3).
   Use mos-rc3.bin from the release ZIP,100879 bytes, SHA256
   d7a51147f3381cd68d56f3fbe4605434a897dfae1b049269afeba09ec2b7eb50.
3. All Olimex firmware selection and bench procedures are governed solely by
   the [Extender bench guide](../../agon-extender/docs/operations/olimex-bench/README.md).
4. Existing no-emulator restrictions and application test scope remain unchanged.
5. C008 manual checks and C011 benchmark pilot still need actual results on
   recorded defaults. Regenerate C011 clock.dat after MOS/reboot changes, check
   clock behavior, retain raw ticks and do not mix firmware/display modes or
   competing async producers across a pair. No measured speedup is established.
