# Conversion qualification setup corrections

These are failed setup/fixture attempts, not passing qualification.

1. The assembler correctly rejected JR M in the first HEXSTR adaptation. The
   reference uses RET M; the wrapper needs JP M to reach its length/preservation
   epilogue. The corrected source uses JP M.
2. The packer's new relative --output option initially failed while recording
   provenance. Resolved output paths now use the repository's absolute root.
   An accidentally launched first smoke run consequently read stale DATA and
   stopped with Type mismatch at line 4020. It was interrupted and restarted
   only after successful generation. The corrected mixed smoke passed.
3. The general reference harness renumbers inputs, so a GOTO 30 test could not
   be embedded in it. That case now runs as an explicit native-only unreachable
   conversion check. The retained reference log shows the fixture's No such line.
4. The first broad compile hit the default 180-second guard after 17 successful
   program compilations. The repeated run uses --timeout 360; source/runtime
   behavior was unchanged. Its invalid @% fixture diagnostic was also corrected
   to the parser's existing Expected a name, confirmed from statement parsing.
