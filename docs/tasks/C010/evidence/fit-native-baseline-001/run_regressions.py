"""Reuse C006 qualification in the C010-owned isolated automated profile."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import shutil
import sys

ROOT = Path(__file__).resolve().parents[3]
TASK = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--suite', choices=['baseline', 'representative'], required=True)
    parser.add_argument('--native', type=Path, required=True)
    parser.add_argument('--name', required=True)
    args = parser.parse_args()
    assert args.name.replace('-', '').isalnum()
    script = ROOT/'docs/tasks/C006'/('native_baseline.py' if args.suite == 'baseline' else 'regressions.py')
    spec = importlib.util.spec_from_file_location('retained_harness', script)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    # The original harness is unchanged. Only its destination/profile constants
    # are selected here; fixtures, CPU work and assertions remain its own.
    module.TASK = TASK
    module.PROFILE = ROOT/'.emulator/c010-fit'
    cli = TASK/'build/observer-target/release/agon-cli-emulator'
    sys.argv = [str(script), '--native', str(args.native), '--cli', str(cli), '--name', args.name]
    if args.suite == 'baseline':
        sys.argv += ['--reference', str(TASK/'evidence/fit-hosted-baseline-002')]
    print('Retained harness SHA256', hashlib.sha256(script.read_bytes()).hexdigest(), flush=True)
    same_images = []
    try:
        module.main()
        if args.suite == 'representative':
            for i in range(10):
                fresh = TASK/'evidence'/args.name/f'p{i}.dat'
                old = ROOT/'docs/tasks/C006/evidence/live-regressions-001'/f'p{i}.dat'
                assert fresh.read_bytes() == old.read_bytes(), i
                same_images.append(i)
    finally:
        evidence = TASK/'evidence'/args.name
        if evidence.exists():
            shutil.copyfile(__file__, evidence/'run_regressions.py')
            metadata = dict(retained_harness=str(script.relative_to(ROOT)),
                retained_harness_sha256=hashlib.sha256(script.read_bytes()).hexdigest(),
                observer_sha256=hashlib.sha256(cli.read_bytes()).hexdigest(),
                compiler_source_sha256=hashlib.sha256((TASK/'candidate-fit.bas').read_bytes()).hexdigest(),
                identical_representative_full_images=same_images,
                scope='Original C006 assertions with explicit C010 destination/profile selection')
            (evidence/'execution.json').write_text(json.dumps(metadata, indent=2)+'\n')
            (evidence/'manifest.json').write_text(json.dumps({p.name:hashlib.sha256(p.read_bytes()).hexdigest()
                for p in sorted(evidence.iterdir()) if p.is_file() and p.name!='manifest.json'},indent=2)+'\n')


if __name__ == '__main__':
    main()
