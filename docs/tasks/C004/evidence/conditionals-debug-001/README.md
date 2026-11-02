# Conditional loader-order correction

Initial full compilation exposed an insertion numbered9485 placed before9480 ENDPROC in text. BASIC loads lines by number, making the ELSE-line-target handling unreachable. The corrected prototype is ordered before repeating full qualification. No failed run is counted as a pass.
