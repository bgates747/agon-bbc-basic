# Numeric output guard calibration

The live regression batch reached p25 (26 successful compilations) before the
old 180-second compile guard expired. No semantic assertion failed. Its repeat
uses --timeout 360; the common output harness now defaults to 360 based on
this observed batch size and the earlier conversion-batch guard expiry.
This attempt is retained separately and is not a passing qualification.
