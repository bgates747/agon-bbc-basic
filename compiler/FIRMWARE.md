# Firmware defaults

Use the Author's pinned firmware for new qualification and deployments. Existing
qualification records describe their original versions; they do not establish a
pass on these defaults. See the [November8 audit](../docs/tasks/C012/REPORT.md).

1. Alexe, Olimex and Console8 VDP: [VDPlet v0.1.2-alpha](https://github.com/bgates747/agon-vdplet/releases/tag/v0.1.2-alpha).
   Use the release firmware and verify SHA256SUMS. Selected firmware is1100304
   bytes, SHA256b004570b607b45bbd6e87a3c704b65b23d3221981db3aac6cf2578aa22d766e3.
2. Alexe and Console8 MOS: [Eirene3.1.0_uart0_rc_3](https://github.com/bgates747/eirene-mos/releases/tag/3.1.0_uart0_rc_3).
   Use mos-rc3.bin from the release ZIP,100879 bytes, SHA256
   d7a51147f3381cd68d56f3fbe4605434a897dfae1b049269afeba09ec2b7eb50.
3. Olimex MOS: Extender's latest approved integrated EMOS with current Eirene
   enhancements. Resolve its current exact selector with the scheduling agent;
   bare RC3 is not an EMOS replacement. Identify and justify any necessary
   firmware exception in a scheduling request.
4. Reuse verified matching installed firmware; do not reflash just to repeat a
   test. Unknown installed state is not a pass. Existing hardware permissions,
   custody, no-emulator restriction and human gates remain in force.
5. C008 manual checks and C011 benchmark pilot still need actual results on
   recorded defaults. Regenerate C011 clock.dat after MOS/reboot changes, check
   clock behavior, retain raw ticks and do not mix firmware/display modes or
   competing async producers across a pair. No measured speedup is established.
