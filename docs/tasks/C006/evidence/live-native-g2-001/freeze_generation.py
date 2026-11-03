"""Retain one completed generation without freezing an active cohort's status."""
from pathlib import Path
import argparse
import hashlib
import json
import shutil

TASK = Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--run', type=Path, required=True)
    p.add_argument('--stage', choices=['g0', 'g1', 'g2', 'repeat'], required=True)
    p.add_argument('--name', required=True)
    a = p.parse_args()
    run = a.run.resolve(strict=True)
    result = json.loads((run / 'results.json').read_text())
    assert a.stage in result['completed_stages']
    image = run / (a.stage+'.dat')
    assert digest(image) == result['generation_hashes'][a.stage]
    assert digest(run / 'compiler.bas') == result['compiler_sha256']
    expected = run / 'expected-image.dat'
    assert expected.is_file() and image.read_bytes() == expected.read_bytes()
    log = (run / (a.stage+'.log')).read_text()
    assert 'Wrote self-'+a.stage+'.bin\n' in log
    if a.stage != 'g0':
        assert 'SELF_STATUS:0\n' in log
    else:
        assert result['unmodified_interpreted_main_executed']
        assert 'SELF_G0_DONE' in log and '*BYE' in log
    out = TASK / 'evidence' / a.name
    out.mkdir(parents=True, exist_ok=False)
    for name in ['compiler.bas', 'bootstrap.py', 'expected-image.dat', a.stage+'.dat',
                 a.stage+'.log', a.stage+'-commands.txt', a.stage+'-keyboard.json']:
        shutil.copy2(run / name, out / name)
    shutil.copy2(__file__, out / 'freeze_generation.py')
    report = dict(scope='Completed generation snapshot; full active chain is separate',
        original_cohort=str(run), completed_stage=a.stage,
        compiler_sha256=result['compiler_sha256'], image_sha256=digest(image),
        image_bytes=image.stat().st_size, matches_previously_qualified_image=True,
        unmodified_interpreted_main=(a.stage == 'g0'),
        controller_seconds=result['controller_seconds'][a.stage],
        inputs=result['inputs'], hardware_validation=False, performance_benchmark=False)
    (out / 'results.json').write_text(json.dumps(report, indent=2)+'\n')
    (out / 'manifest.json').write_text(json.dumps({q.name:digest(q) for q in out.iterdir()
        if q.is_file()}, indent=2)+'\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
