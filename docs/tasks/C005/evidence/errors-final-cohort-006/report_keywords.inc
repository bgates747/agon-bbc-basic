; Read-only data adapted from include/bbc-ez80/MAIN.Z80 KEYWDS.
; (C) COPYRIGHT R.T.RUSSELL 1981-2025; repository license.txt applies.
; THE NAME BBC BASIC IS USED WITH THE PERMISSION OF THE BRITISH
; BROADCASTING CORPORATION AND IS NOT TRANSFERRABLE TO A FORKED OR DERIVED WORK.
; Byte identity checked against pinned bin/basic.bin, not interpreter RAM.
; Source SHA256 7e45831c9ef2073f86143a0a14046459bec16fac91bb5257431f26c8008e3a45
.equ report_wrap_last,17
err_keywords:
    .byte 0x80
    .ascii "AND"
    .byte 0x94
    .ascii "ABS"
    .byte 0x95
    .ascii "ACS"
    .byte 0x96
    .ascii "ADVAL"
    .byte 0x97
    .ascii "ASC"
    .byte 0x98
    .ascii "ASN"
    .byte 0x99
    .ascii "ATN"
    .byte 0x9a
    .ascii "BGET "
    .byte 0xd5
    .ascii "BPUT "
    .byte 0x0f
    .ascii "BY "
    .byte 0xfb
    .ascii "COLOUR"
    .byte 0xfb
    .ascii "COLOR"
    .byte 0xd6
    .ascii "CALL"
    .byte 0xc8
    .ascii "CASE"
    .byte 0xd7
    .ascii "CHAIN"
    .byte 0xbd
    .ascii "CHR$"
    .byte 0xd8
    .ascii "CLEAR "
    .byte 0xd9
    .ascii "CLOSE "
    .byte 0xda
    .ascii "CLG "
    .byte 0xdb
    .ascii "CLS "
    .byte 0x9b
    .ascii "COS"
    .byte 0x9c
    .ascii "COUNT "
    .byte 0x01
    .ascii "CIRCLE"
    .byte 0xdc
    .ascii "DATA"
    .byte 0x9d
    .ascii "DEG"
    .byte 0xdd
    .ascii "DEF"
    .byte 0x81
    .ascii "DIV"
    .byte 0xde
    .ascii "DIM"
    .byte 0xdf
    .ascii "DRAW"
    .byte 0xe1
    .ascii "ENDPROC "
    .byte 0xce
    .ascii "ENDWHILE "
    .byte 0xcb
    .ascii "ENDCASE "
    .byte 0xcd
    .ascii "ENDIF "
    .byte 0xe0
    .ascii "END "
    .byte 0xe2
    .ascii "ENVELOPE"
    .byte 0x8b
    .ascii "ELSE"
    .byte 0xa0
    .ascii "EVAL"
    .byte 0x9e
    .ascii "ERL "
    .byte 0x85
    .ascii "ERROR"
    .byte 0xc5
    .ascii "EOF "
    .byte 0x82
    .ascii "EOR"
    .byte 0x9f
    .ascii "ERR "
    .byte 0x10
    .ascii "EXIT "
    .byte 0xa1
    .ascii "EXP"
    .byte 0xa2
    .ascii "EXT "
    .byte 0x02
    .ascii "ELLIPSE"
    .byte 0xe3
    .ascii "FOR"
    .byte 0xa3
    .ascii "FALSE "
    .byte 0x03
    .ascii "FILL"
    .byte 0xa4
    .ascii "FN"
    .byte 0xe5
    .ascii "GOTO"
    .byte 0xbe
    .ascii "GET$"
    .byte 0xa5
    .ascii "GET"
    .byte 0xe4
    .ascii "GOSUB"
    .byte 0xe6
    .ascii "GCOL"
    .byte 0x93
    .ascii "HIMEM "
    .byte 0xe8
    .ascii "INPUT"
    .byte 0xe7
    .ascii "IF"
    .byte 0xbf
    .ascii "INKEY$"
    .byte 0xa6
    .ascii "INKEY"
    .byte 0xa8
    .ascii "INT"
    .byte 0xa7
    .ascii "INSTR("
    .byte 0x0c
    .ascii "INSTALL"
    .byte 0x86
    .ascii "LINE"
    .byte 0x92
    .ascii "LOMEM "
    .byte 0xea
    .ascii "LOCAL"
    .byte 0xc0
    .ascii "LEFT$("
    .byte 0xa9
    .ascii "LEN"
    .byte 0xe9
    .ascii "LET"
    .byte 0xab
    .ascii "LOG"
    .byte 0xaa
    .ascii "LN"
    .byte 0xc1
    .ascii "MID$("
    .byte 0xeb
    .ascii "MODE"
    .byte 0x83
    .ascii "MOD"
    .byte 0xec
    .ascii "MOVE"
    .byte 0x04
    .ascii "MOUSE"
    .byte 0xed
    .ascii "NEXT"
    .byte 0xac
    .ascii "NOT"
    .byte 0xee
    .ascii "ON"
    .byte 0x87
    .ascii "OFF "
    .byte 0xca
    .ascii "OF "
    .byte 0x05
    .ascii "ORIGIN"
    .byte 0x84
    .ascii "OR"
    .byte 0x8e
    .ascii "OPENIN"
    .byte 0xae
    .ascii "OPENOUT"
    .byte 0xad
    .ascii "OPENUP"
    .byte 0xff
    .ascii "OSCLI"
    .byte 0xcc
    .ascii "OTHERWISE"
    .byte 0xf1
    .ascii "PRINT"
    .byte 0x90
    .ascii "PAGE "
    .byte 0x8f
    .ascii "PTR "
    .byte 0xaf
    .ascii "PI "
    .byte 0xf0
    .ascii "PLOT"
    .byte 0xb0
    .ascii "POINT("
    .byte 0x11
    .ascii "POINT "
    .byte 0xf2
    .ascii "PROC"
    .byte 0xb1
    .ascii "POS "
    .byte 0x0e
    .ascii "PUT"
    .byte 0x06
    .ascii "QUIT "
    .byte 0xf8
    .ascii "RETURN "
    .byte 0xf5
    .ascii "REPEAT"
    .byte 0xf6
    .ascii "REPORT "
    .byte 0xf3
    .ascii "READ"
    .byte 0xf4
    .ascii "REM"
    .byte 0xf9
    .ascii "RUN "
    .byte 0xb2
    .ascii "RAD"
    .byte 0xf7
    .ascii "RESTORE"
    .byte 0xc2
    .ascii "RIGHT$("
    .byte 0xb3
    .ascii "RND "
    .byte 0x07
    .ascii "RECTANGLE"
    .byte 0x88
    .ascii "STEP"
    .byte 0xb4
    .ascii "SGN"
    .byte 0xb5
    .ascii "SIN"
    .byte 0xb6
    .ascii "SQR"
    .byte 0x89
    .ascii "SPC"
    .byte 0xc3
    .ascii "STR$"
    .byte 0xc4
    .ascii "STRING$("
    .byte 0xd4
    .ascii "SOUND"
    .byte 0xfa
    .ascii "STOP "
    .byte 0xc6
    .ascii "SUM"
    .byte 0x08
    .ascii "SWAP"
    .byte 0x09
    .ascii "SYS"
    .byte 0xb7
    .ascii "TAN"
    .byte 0x8a
    .ascii "TAB("
    .byte 0x8c
    .ascii "THEN"
    .byte 0x91
    .ascii "TIME "
    .byte 0x0a
    .ascii "TINT("
    .byte 0xb8
    .ascii "TO"
    .byte 0xfc
    .ascii "TRACE"
    .byte 0xb9
    .ascii "TRUE "
    .byte 0xfd
    .ascii "UNTIL"
    .byte 0xba
    .ascii "USR"
    .byte 0xef
    .ascii "VDU"
    .byte 0xbb
    .ascii "VAL"
    .byte 0xbc
    .ascii "VPOS "
    .byte 0xc7
    .ascii "WHILE"
    .byte 0xc9
    .ascii "WHEN"
    .byte 0x0b
    .ascii "WAIT "
    .byte 0xfe
    .ascii "WIDTH"
    .byte 0xcf
    .ascii "PTR"
    .byte 0xd1
    .ascii "TIME"
    .byte 0xd3
    .ascii "HIMEM"
    .byte 0xd2
    .ascii "LOMEM"
    .byte 0xd0
    .ascii "PAGE"
    .byte 0x12
    .ascii "No such "
    .byte 0x13
    .ascii "Bad "
    .byte 0x14
    .ascii " range"
    .byte 0x15
    .ascii "variable"
    .byte 0x16
    .ascii "Out of"
    .byte 0x17
    .ascii "No "
    .byte 0x18
    .ascii " space"
    .byte 0x19
    .ascii "Not in a "
    .byte 0x1a
    .ascii " loop"
    .byte 0x1b
    .ascii " not "
.equ err_keyword_length,.-err_keywords
    .byte 255,255 ; Original DEFW -1 sentinel, excluded from search length.
