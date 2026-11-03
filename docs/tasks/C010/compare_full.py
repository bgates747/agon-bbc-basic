"""Freeze exact full-program stream equality from two completed actual CPU runs."""
from pathlib import Path
import hashlib
import json
import shutil

TASK = Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    evidence = TASK/'evidence/full-pair-001'
    assert not evidence.exists()
    reports = {}
    for name in ['full-native-002','full-reference-001']:
        directory = TASK/'evidence'/name
        for filename,expected in json.loads((directory/'manifest.json').read_text()).items():
            assert digest(directory/filename) == expected,(name,filename)
        reports[name] = json.loads((directory/'results.json').read_text())
        assert reports[name]['completed'] and reports[name]['key_supplied_after_final_plot']
        assert reports[name]['plots'] == reports[name]['gcol_commands']
    native = TASK/'evidence/full-native-002'
    reference = TASK/'evidence/full-reference-001'
    assert (native/'graphics.dat').read_bytes() == (reference/'graphics.dat').read_bytes()
    a,b = reports.values()
    assert a['source_sha256'] == b['source_sha256'] == '1eb897c8ef3aecc99910e0352eba6d32064ebc4aef9e7bd32e9952b0878b43de'
    assert a['reference_sha256'] == b['reference_sha256']
    assert a['observer_sha256'] == b['observer_sha256'] and a['mos_sha256'] == b['mos_sha256']
    assert a['plots'] == b['plots'] and a['graphics_bytes'] == b['graphics_bytes']
    report = dict(completed=True,whole_graphics_stream_identical=True,
        source_sha256=a['source_sha256'],native_image_sha256=a['image_sha256'],
        plots=a['plots'],gcol_commands=a['gcol_commands'],graphics_bytes=a['graphics_bytes'],
        graphics_sha256=digest(native/'graphics.dat'),
        key_supplied_only_after_last_plot_both=True,mode1_and_normal_return_both=True,
        input_cohorts=list(reports),reference_sha256=a['reference_sha256'],
        observer_sha256=a['observer_sha256'],mos_sha256=a['mos_sha256'],
        rendered_validation=False,human_validation=False,performance_benchmark=False,
        scope='Full unchanged source; actual reference/native CPU execution and UART packets')
    evidence.mkdir()
    shutil.copyfile(__file__,evidence/'compare_full.py')
    (evidence/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    (evidence/'manifest.json').write_text(json.dumps({p.name:digest(p)
        for p in sorted(evidence.iterdir()) if p.name!='manifest.json'},indent=2)+'\n')
    print(json.dumps(report),flush=True)


if __name__ == '__main__':
    main()
