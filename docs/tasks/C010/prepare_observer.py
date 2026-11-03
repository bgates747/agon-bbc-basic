"""Prepare an isolated CLI VDP-protocol observer; never edit upstream sources.

Only the CLI's host peer changes: acknowledge MODE, consume GCOL/PLOT packets,
and tee CPU UART output bytes. No renderer or BASIC arithmetic is implemented.
"""
from pathlib import Path
import difflib
import hashlib
import json
import shutil
import subprocess

TASK = Path(__file__).resolve().parent
UPSTREAM = Path('/Agon/fab-agon-emulator')
OUT = TASK / 'build/observer-source'
assert not OUT.exists()
files = subprocess.check_output(['git', '-C', str(UPSTREAM), 'ls-files', '-z']).decode().split('\0')
for name in files:
    if name and (UPSTREAM / name).is_file():
        target = OUT / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(UPSTREAM / name, target)
path = OUT / 'agon-cli-emulator/src/main.rs'
original = path.read_text()
recorder = '''
// C010 test-only observer. CPU output is recorded before the fake VDP sees it.
// This does not implement a renderer or alter the eZ80/MOS/BASIC execution.
fn c010_record(byte: u8) {
    use std::sync::{Mutex, OnceLock};
    static OUTPUT: OnceLock<Mutex<Option<std::fs::File>>> = OnceLock::new();
    let output = OUTPUT.get_or_init(|| Mutex::new(
        std::env::var_os("BBC_C010_WIRE").map(|p| std::fs::File::create(p).unwrap())));
    if let Some(ref mut file) = *output.lock().unwrap() {
        file.write_all(&[byte]).unwrap();
    }
}
'''
source = original.replace('// Fake VDP.', recorder + '\n// Fake VDP.', 1)
anchor = '                // VDP system control\n'
packets = '''                // C010 protocol-only peer: consume whole graphics commands.
                0x12 => { for _ in 0..2 { rx_from_ez80.recv().unwrap(); } }
                0x19 => { for _ in 0..5 { rx_from_ez80.recv().unwrap(); } }
                0x16 => {
                    let mode = rx_from_ez80.recv().unwrap();
                    // Deterministic mode-info acknowledgement. No pixel rendering.
                    let (w, h, cols, rows, colors): (u16,u16,u8,u8,u8) =
                        if mode == 8 { (320,240,40,30,64) } else if mode == 1 { (640,480,80,60,4) } else { (640,480,80,60,16) };
                    send_bytes(tx_to_ez80, &vec![0x86,7,w as u8,(w>>8) as u8,
                        h as u8,(h>>8) as u8,cols,rows,colors]);
                }
'''
assert source.count(anchor) == 1
source = source.replace(anchor, packets + anchor)
needle = '        self.sender.send(byte).unwrap();'
assert source.count(needle) == 1
source = source.replace(needle, '        c010_record(byte);\n' + needle)
path.write_text(source)
(TASK / 'wire-observer.patch').write_text(''.join(difflib.unified_diff(
    original.splitlines(keepends=True), source.splitlines(keepends=True),
    fromfile='a/agon-cli-emulator/src/main.rs', tofile='b/agon-cli-emulator/src/main.rs')))
(TASK / 'build/observer-source.json').write_text(json.dumps(dict(
    upstream_commit=subprocess.check_output(['git','-C',str(UPSTREAM),'rev-parse','HEAD']).decode().strip(),
    upstream_main_sha256=hashlib.sha256(original.encode()).hexdigest(),
    observer_main_sha256=hashlib.sha256(source.encode()).hexdigest(),
    scope='Host CLI protocol observer only; not rendered graphics validation'),indent=2)+'\n')
print(OUT)
