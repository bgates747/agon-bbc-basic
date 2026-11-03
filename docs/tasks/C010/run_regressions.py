"""Reuse C006 qualification in the C010-owned isolated automated profile."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
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
    module.PROFILE = ROOT/'.emulator/c010-wire'
    cli = TASK/'build/observer-target/release/agon-cli-emulator'
    sys.argv = [str(script), '--native', str(args.native), '--cli', str(cli), '--name', args.name]
    if args.suite == 'baseline':
        sys.argv += ['--reference', str(TASK/'evidence/hosted-baseline-001')]
    print('Retained harness SHA256', hashlib.sha256(script.read_bytes()).hexdigest(), flush=True)
    module.main()


if __name__ == '__main__':
    main()
