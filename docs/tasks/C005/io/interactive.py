"""Drive real MOS line editing through CLI stdin key events, using its wrapper."""
from pathlib import Path
import subprocess
import time


def run(profile: Path, autoexec: str, keyboard_steps, marker: str, log_name: str,
        timeout_seconds=120):
    (profile/'sdcard/autoexec.txt').write_bytes(autoexec.replace('\n', '\r\n').encode('ascii'))
    log_path = profile/log_name
    with log_path.open('w') as log:
        process = subprocess.Popen(['./fab-agon-emulator', '-u', '-z'], cwd=profile,
            stdin=subprocess.PIPE, stdout=log, stderr=subprocess.STDOUT)
        step = 0
        try:
            deadline = time.monotonic()+timeout_seconds
            while time.monotonic() < deadline:
                output = log_path.read_text(errors='replace')
                if step < len(keyboard_steps) and keyboard_steps[step][0] in output:
                    text = keyboard_steps[step][1]
                    process.stdin.write((text+'\n').encode('ascii'))
                    process.stdin.flush()
                    step += 1
                if marker in output:
                    assert step == len(keyboard_steps), (step, output)
                    break
                if process.poll() is not None:
                    raise AssertionError(f'CLI exited before {marker}: {output}')
                time.sleep(0.1)
            else:
                raise AssertionError(f'Timeout waiting for {marker}; see {log_path}')
        finally:
            process.stdin.close()
            try:
                process.wait(timeout=4)
            except subprocess.TimeoutExpired:
                process.terminate()
                try:
                    process.wait(timeout=4)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()
    return log_path.read_text(errors='replace')
