"""Finish only the remaining prepared C006 small stages, stopping on failure.

The two manually completed case0 stages and compile-1 must already be retained.
Each child independently checks the lease, actual prompts/CLI, full outputs and
listener return. No retry, self-compilation or cleanup is dispatched here.
"""
from pathlib import Path
import argparse
import json
import shutil
import subprocess
import sys
import time


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--bundle', type=Path, required=True)
    p.add_argument('--config', type=Path, required=True)
    p.add_argument('--lease', required=True)
    p.add_argument('--capture', type=Path, required=True)
    p.add_argument('--physical', type=Path, required=True)
    a = p.parse_args()
    physical = a.physical.resolve(strict=True)
    assert json.loads((physical/'compile-0-result.json').read_text())['all_output_bytes_equal']
    assert json.loads((physical/'run-0-result.json').read_text())['output_matches']
    assert json.loads((physical/'stages/compile-1/results.json').read_text())['passed']
    stages = [f'compile-{i}' for i in range(2, 12)]+[f'run-{i}' for i in range(1, 10)]
    record = physical/'small-cohort'
    record.mkdir(exist_ok=False)
    shutil.copy2(__file__, record/'run_olimex_small.py')
    report = dict(started_epoch=time.time(), planned_stages=stages, completed_stages=[], passed=False)
    try:
        for stage in stages:
            command = [sys.executable, str(Path(__file__).with_name('run_olimex_stage.py')),
                       '--bundle', str(a.bundle.resolve()), '--config', str(a.config.resolve()),
                       '--lease', a.lease, '--capture', str(a.capture.resolve()),
                       '--record', str(physical/'stages'/stage), '--stage', stage]
            report['attempted_stage'] = stage
            (record/'results.json').write_text(json.dumps(report, indent=2)+'\n')
            subprocess.run(command, check=True)
            result = json.loads((physical/'stages'/stage/'results.json').read_text())
            assert result['passed']
            report['completed_stages'].append(stage)
        report['passed'] = True
    except BaseException as error:
        report['failure'] = repr(error)
        raise
    finally:
        report['finished_epoch'] = time.time()
        (record/'results.json').write_text(json.dumps(report, indent=2)+'\n')


if __name__ == '__main__':
    main()
