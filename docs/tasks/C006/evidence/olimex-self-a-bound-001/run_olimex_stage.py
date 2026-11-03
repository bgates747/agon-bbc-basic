"""Observe and execute one explicitly selected, already granted C006 stage.

This stops on the first uncertain observation. It never invokes a successor,
retries input, resets, flashes or cleans up an unknown foreground program.
"""
from pathlib import Path
import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import time


def clean(raw):
    text = raw.decode('ascii')
    text = re.sub(r'W3DDBG MODE_PACKET_BEGIN ms=\d+ mode=0 suppress=0\n\r', '', text)
    text = re.sub(r'W3DDBG MODE_PACKET_END ms=\d+ mode=0\n\r', '', text)
    return text.replace('\n\r', '\n').replace('\r\n', '\n')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--bundle', type=Path, required=True)
    p.add_argument('--config', type=Path, required=True)
    p.add_argument('--lease', required=True)
    p.add_argument('--capture', type=Path, required=True)
    p.add_argument('--record', type=Path, required=True)
    p.add_argument('--stage', required=True)
    a = p.parse_args()
    assert re.fullmatch(r'compile-(?:[1-9]|10|11)|run-[1-9]|self-[ab]', a.stage)
    bundle = a.bundle.resolve(strict=True)
    fixture = json.loads((bundle/'fixture.json').read_text())
    cases = json.loads((bundle/'cases.json').read_text())
    capture = a.capture.resolve(strict=True)
    assert (capture.parent/'ready').is_file() and not (capture.parent/'stop').exists()
    record = a.record.resolve()
    record.mkdir(parents=True, exist_ok=False)
    shutil.copy2(__file__, record/'run_olimex_stage.py')
    cursor = len(capture.read_bytes())
    initial_cursor = cursor
    report = dict(stage=a.stage, started_epoch=time.time(), passed=False,
                  physical_hardware=True, capture=str(capture), capture_start=cursor)

    def save():
        (record/'results.json').write_text(json.dumps(report, indent=2)+'\n')

    def step(label, *args):
        command = [sys.executable, str(Path(__file__).with_name('olimex_step.py')),
                   '--config', str(a.config.resolve()), '--bundle', str(bundle),
                   '--lease', a.lease, '--record', str(record/label), *args]
        with (record/(label+'.stdout')).open('w') as out, (record/(label+'.stderr')).open('w') as err:
            subprocess.run(command, check=True, stdout=out, stderr=err)

    def observe(token, seconds):
        nonlocal cursor
        deadline = time.monotonic()+seconds
        while True:
            raw = capture.read_bytes()[cursor:]
            at = raw.find(token)
            if at >= 0:
                end = cursor+at+len(token)
                found = capture.read_bytes()[cursor:end]
                cursor = end
                report.setdefault('observations', []).append(dict(token=token.decode(), epoch=time.time(), end=end))
                save()
                return clean(found)
            if time.monotonic() >= deadline:
                raise TimeoutError('Observation bound expired; no further dispatch: '+repr(token))
            time.sleep(.1)

    def status(label):
        step(label, 'status')
        d = record/label
        listener = json.loads((d/'listener-status.stdout').read_text())
        worker = json.loads((d/'worker-status.stdout').read_text())
        keys = json.loads((d/'keyboard-status.stdout').read_text())
        assert listener['online'] and listener['protocol'] == 2 and not listener['pending']
        assert worker['phase'] == 0
        assert keys['ready'] and keys['physical_neutral'] and keys['pending'] == keys['held'] == 0

    try:
        status('entry-status')
        step('listener-exit', 'exit')
        prompt = fixture['result_path']+' *'
        returned = observe(prompt.encode(), 15)
        assert returned == 'SD service stopped.\n'+prompt, repr(returned)
        # Complete mode records can follow the prompt; observe() removes only
        # those exact known records in later correlated windows.
        command = 'EXEC '+fixture['fixture_path']+'/'+a.stage+'.txt'
        marker = a.stage.upper().replace('-', '_')
        if a.stage.startswith('run-'):
            marker = 'NATIVE_'+a.stage.split('-')[1]
        begin = 'BBC_BEGIN_'+marker+'\n'
        end = 'BBC_END_'+marker+'\n'
        step('invoke', 'type', command)
        entered = observe(begin.replace('\n', '\r\n').encode(), 60)
        assert entered == command+'\n'+begin, repr(entered)
        compiling = not a.stage.startswith('run-')
        if compiling:
            ready = observe(b'Source file: ', 120)
            assert ready == 'Source file: ', repr(ready)
            source, target = fixture['filename_inputs'][a.stage]
            step('source-input', 'type', source)
            ready = observe(b'Output file: ', 30)
            assert ready == source+'\nOutput file: ', repr(ready)
            step('output-input', 'type', target)
            report['last_input_emission_return_epoch'] = time.time()
            save()
            body = observe(end.replace('\n', '\r\n').encode(), 5400 if a.stage.startswith('self-') else 600)
            if a.stage.startswith('compile-') and int(a.stage.split('-')[1]) >= 10:
                i = int(a.stage.split('-')[1])
                oracle = (bundle.parent/'live-regressions-001'/f'compile-{i}.log').read_text()
                diagnostic = next(line for line in oracle.splitlines() if line.startswith(f'nreg-{i}.bas:'))
                diagnostic = source+diagnostic[len(f'nreg-{i}.bas'):]
                expected_body = target+'\n'+diagnostic+'\n'+end
                expected_file = bundle/'payload'/f'reject-{i}.dat'
            else:
                expected_body = target+'\nWrote '+target+'\n'+end
                expected_file = bundle/'payload/compiler.bin' if a.stage.startswith('self-') else bundle/'expected'/f'case-{a.stage.split("-")[1]}.dat'
            assert body == expected_body, repr(body)
        else:
            i = int(a.stage.split('-')[1])
            body = observe(end.replace('\n', '\r\n').encode(), 120)
            assert body == cases[i]['expected']+end, repr(body)
        report['completion_observed_epoch'] = time.time()
        listener = observe(b'Escape returns to MOS.\r\n', 30)
        assert listener == ('Fast transfer: no CRCs or whole-file verification.\n'
                            'sdserve-v0.3.0-b2026-10-25-05-14-41Z (draft), root /\n'
                            'Escape returns to MOS.\n'), repr(listener)
        status('returned-status')
        if compiling:
            output = record/'output.dat'
            step('output-get', 'get', target, str(output))
            assert output.read_bytes() == expected_file.read_bytes()
            report.update(all_output_bytes_equal=True, image_bytes=output.stat().st_size,
                          image_sha256=hashlib.sha256(output.read_bytes()).hexdigest())
        elif a.stage == 'run-8':
            output = record/'native-test.dat'
            step('file-get', 'get', fixture['result_path']+'/native-test.dat', str(output))
            assert output.read_bytes() == (bundle/'expected/native-test.dat').read_bytes()
            report['file_io_bytes_equal'] = True
        report['passed'] = True
        print('Physical stage passed:', a.stage, flush=True)
    except BaseException as error:
        report['failure'] = repr(error)
        raise
    finally:
        report.update(finished_epoch=time.time(), capture_end=len(capture.read_bytes()))
        (record/'console.bin').write_bytes(capture.read_bytes()[initial_cursor:report['capture_end']])
        save()


if __name__ == '__main__':
    main()
