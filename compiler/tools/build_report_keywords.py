"""Adapt read-only interpreter keyword data for REPORT; never compile BBC source."""
from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
def main():
 source=ROOT/'include/bbc-ez80/MAIN.Z80';text=source.read_text();block=text.split('KEYWDS:',1)[1].split('KEYWDL',1)[0];raw=bytearray();rows=[]
 for line in block.splitlines():
  line=line.split(';',1)[0].strip()
  if not line:continue
  if m:=re.fullmatch(r'DEFB\s+([0-9A-F]+)H',line):
   value=int(m[1],16);assert value<256;raw.append(value);rows.append(f'    .byte 0x{value:02x}')
  elif m:=re.fullmatch(r"DEFM\s+'([^']*)'",line):
   raw.extend(m[1].encode('ascii'));rows.append('    .ascii '+json.dumps(m[1]))
  else:raise AssertionError(line)
 mapping=(ROOT/'bin/basic.map').read_text();match=re.search(r'0x([0-9a-f]+)\s+KEYWDS\b',mapping);assert match
 offset=int(match[1],16)-0x40000;binary=(ROOT/'bin/basic.bin').read_bytes();assert binary[offset:offset+len(raw)]==raw
 token_source=ROOT/'include/bbc-ez80/TOKENIDS.Z80';wrap=re.search(r'TWRTK\s+EQU\s+0([0-9A-Fa-f]+)h',token_source.read_text());assert wrap and int(wrap[1],16)==17
 output=ROOT/'compiler/runtime/report_keywords.inc';output.write_text('; Read-only data adapted from include/bbc-ez80/MAIN.Z80 KEYWDS.\n; (C) COPYRIGHT R.T.RUSSELL 1981-2025; repository license.txt applies.\n; THE NAME BBC BASIC IS USED WITH THE PERMISSION OF THE BRITISH\n; BROADCASTING CORPORATION AND IS NOT TRANSFERRABLE TO A FORKED OR DERIVED WORK.\n; Byte identity checked against pinned bin/basic.bin, not interpreter RAM.\n'+f'; Source SHA256 {hashlib.sha256(source.read_bytes()).hexdigest()}\n'+'.equ report_wrap_last,17\nerr_keywords:\n'+'\n'.join(rows)+'\n.equ err_keyword_length,.-err_keywords\n    .byte 255,255 ; Original DEFW -1 sentinel, excluded from search length.\n')
 print(json.dumps(dict(bytes=len(raw),reference_binary_byte_match=True,reference_offset=offset,source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),include_sha256=hashlib.sha256(output.read_bytes()).hexdigest()),indent=2))
if __name__=='__main__':main()
