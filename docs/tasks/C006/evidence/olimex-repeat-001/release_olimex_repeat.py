"""Release only a completed C006 repeat after observed cleanup and fresh checks.

Requires the actual passed native stage, preservation readbacks, restored CLI,
mirror-off receipt and closed capture receipts. It never stops unknown work,
types commands, resets, retries or fabricates an old observation timestamp.
"""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import time
import urllib.request

ROOT = Path(__file__).resolve().parents[3]
ENV = ROOT.parent/'agon-dev-env'
EXTENDER = ROOT.parent/'agon-extender'


def read(path):
    return json.loads(path.read_text())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--physical', type=Path, required=True)
    p.add_argument('--bundle', type=Path, required=True)
    a = p.parse_args()
    physical = a.physical.resolve(strict=True)
    grant = read(physical/'grant.json')
    config = read(physical/'config.json')
    full = read(EXTENDER/'agents/release001/live-preparation-r01/config.json')
    stage = read(physical/'stages/self-b/results.json')
    assert stage['passed'] and stage['physical_hardware'] and stage['all_output_bytes_equal']
    output = physical/'stages/self-b/output.dat'
    assert hashlib.sha256(output.read_bytes()).hexdigest() == stage['image_sha256']
    preserved = read(physical/'cleanup-preserved/results.json')
    assert preserved['passed']
    assert preserved['verified_files']['/autoexec.txt']['sha256'] == grant['entry_observation']['components']['startup_sha256']
    assert preserved['verified_files']['/emos/sdserve.bin']['sha256'] == grant['entry_observation']['components']['listener_sha256']
    cli = read(physical/'cleanup-cli-observation.json')
    assert cli['actual_cli_verified'] and cli['native_mode_observed'] == 0
    assert cli['incoming_directory_restored'] == grant['entry_observation']['incoming_directory']
    for name, text in [('cleanup-text-cursor', 'VDU 4 23 1 1 23 1 3'), ('cleanup-mirror-off', 'VDU 3')]:
        receipt = read(physical/name/'receipt.json')
        assert receipt['completed'] and receipt['submitted_text'] == text
    captures = list(physical.glob('capture-*'))
    assert len(captures) == 2
    for capture in captures:
        receipt = read(capture/'receipt.json')
        assert receipt['completed'] and receipt['port_open_observed']
    assert not (physical/'release-observation.json').exists()
    helper = [str(ENV/'.venv/bin/python'), str(ENV/'cross-agent/olimex-bench/bench_lease.py')]
    owner = ['--owner', 'bbc-basic', '--lease', grant['lease']]

    def owned():
        return subprocess.run(helper+['assert-owner']+owner, check=True, capture_output=True, text=True)

    def get(path):
        owned()
        with urllib.request.urlopen(config['extender_url']+path, timeout=15) as response:
            return json.load(response)

    owned()
    command = [str(ROOT/'.venv/bin/python'), str(Path(__file__).with_name('olimex_step.py')),
               '--config', str(physical/'config.json'), '--bundle', str(a.bundle.resolve()),
               '--lease', grant['lease'], '--record', str(physical/'release-status'), 'status']
    subprocess.run(command, check=True)
    status = physical/'release-status'
    keys = read(status/'keyboard-status.stdout')
    listener = read(status/'listener-status.stdout')
    worker = read(status/'worker-status.stdout')
    assert keys['ready'] and keys['physical_neutral'] and keys['pending'] == keys['held'] == 0
    assert keys['boot'] == read(physical/'entry-status/keyboard-status.stdout')['boot']
    assert not listener['online'] and not listener['pending'] and worker['phase'] == 0
    display = get('/display/status')
    controller = get('/controller/status')
    assert display['mode'] == 0
    ports = {}
    for port in [config['mainboard_serial'], full['p4']['stable_port']]:
        Path(port).resolve(strict=True)
        result = subprocess.run(['fuser', port], capture_output=True, text=True)
        assert result.returncode == 1 and not result.stdout.strip(), (port, result.stdout, result.stderr)
        ports[port] = dict(ownerless=True, returncode=result.returncode)
    resources = dict(epoch=time.time(), keyboard=keys, listener=listener, worker=worker,
                     display=display, controller=controller, ports=ports,
                     actual_cli_observation=cli, owned_readers_closed=True,
                     no_reset_flash_mode_or_startup_change=True, no_optical_pass=True)
    (physical/'final-resources.json').write_text(json.dumps(resources, indent=2)+'\n')
    provenance = {k:'Retained verified grant identity; BBC made no firmware writes. '+v
                  for k, v in grant['entry_observation']['component_provenance'].items()}
    provenance['startup_sha256'] = 'Fresh complete staged GET in repeat cleanup; independently equal grant bytes; not written.'
    provenance['listener_sha256'] = 'Fresh complete staged GET in repeat cleanup; canonical22968B independently equal grant bytes; not written.'
    checks = ['no_workload', 'no_transfer', 'no_serial_readers', 'no_reset_holders',
              'cli_verified', 'input_ready_neutral', 'listener_offline', 'staged_job_idle', 'restoration_verified']
    observation = dict(schema='olimex-bench-observation-v1', bench='olimex', epoch=time.time(),
        observer='bbc-basic', lease=grant['lease'], checks={key:True for key in checks},
        evidence=[str(physical/'final-resources.json'), str(physical/'cleanup-preserved/results.json'),
                  str(physical/'cleanup-cli-observation.json'), str(physical/'stages/self-b/results.json')],
        components=grant['entry_observation']['components'], component_provenance=provenance,
        disposition='One actual physical repeat passed with complete identical image. Original directory/modes and text/cursor restored, VDU3 mirroroff, both readers closed, neutral idle/offline services and ownerlessUSB fresh. Startup/listener exact readbacks; firmware retained unchanged, no optical/performance claim. No reset/replay/flash/startup/mode/wiring change; SD remains in Agon.')
    path = physical/'release-observation.json'
    path.write_text(json.dumps(observation, indent=2)+'\n')
    owned()
    result = subprocess.run(helper+['release']+owner+['--idle-evidence', str(path)], check=True,
                            capture_output=True, text=True)
    (physical/'release-result.json').write_text(result.stdout)
    released = json.loads(result.stdout)
    print(json.dumps(dict(released=released['released'], generation=released['generation'],
                          next_request=released['next_request'])))


if __name__ == '__main__':
    main()
