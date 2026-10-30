#!/usr/bin/env python3
"""Observe a live macOS/Linux test process. Resource observations are not a GPU pass.

Attach after startup if necessary; the report explicitly records its observation
window and cannot provide an unobserved startup baseline or GPU allocation size.
"""
import argparse
import json
import statistics
import subprocess
import sys
import time
from pathlib import Path


def ps(pid, fields):
    result = subprocess.run(['ps', '-p', str(pid), '-o', fields],
                            capture_output=True, text=True, check=False)
    if result.returncode == 1 and not result.stdout.strip():
        return None
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or 'ps failed')
    return result.stdout.strip()


def process_identity(pid):
    if sys.platform == 'linux':
        try:
            directory = Path('/proc') / str(pid)
            executable = (directory / 'exe').readlink()
            # comm may contain spaces or parentheses; fields after its last ')'
            # begin at state (field 3), so starttime (field 22) has index 19.
            fields = (directory / 'stat').read_text().rsplit(')', 1)[1].split()
            return str(executable), 'linux_start_ticks=' + fields[19]
        except (FileNotFoundError, ProcessLookupError):
            return None
    return ps(pid, 'lstart=,comm=')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--pid', type=int, required=True)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--interval', type=float, default=10)
    parser.add_argument('--timeout-seconds', type=float, default=7200)
    args = parser.parse_args()
    assert sys.platform in ('darwin', 'linux') and args.pid > 0
    assert args.interval >= 1 and args.timeout_seconds >= args.interval
    binary = args.binary.resolve()
    identity = process_identity(args.pid)
    assert identity and (identity[0] == str(binary) if sys.platform == 'linux'
                         else identity.endswith(str(binary))), 'PID does not match the requested test binary'
    args.output.mkdir(parents=True, exist_ok=True)
    report_path = args.output / 'resources.json'
    report_path.unlink(missing_ok=True)
    samples = []
    started = time.monotonic()
    reason = 'observation_timeout'
    with (args.output / 'resources.jsonl').open('w') as stream:
        while time.monotonic() - started < args.timeout_seconds:
            current = process_identity(args.pid)
            if current is None:
                reason = 'observed_process_exit'
                break
            if current != identity:
                reason = 'pid_identity_changed'
                break
            metrics = ps(args.pid, 'rss=,%cpu=')
            if metrics is None:
                reason = 'observed_process_exit'
                break
            rss, cpu = metrics.split()
            sample = {'seconds': time.monotonic() - started,
                      'rss_bytes': int(rss) * 1024, 'ps_cpu_percent': float(cpu)}
            samples.append(sample)
            stream.write(json.dumps(sample) + '\n')
            stream.flush()
            time.sleep(args.interval)
    assert samples, 'No resource samples collected'
    first = [s['rss_bytes'] for s in samples if s['seconds'] <= 60]
    last = [s['rss_bytes'] for s in samples if s['seconds'] >= samples[-1]['seconds'] - 60]
    report = {
        'scope': 'Observed process RSS and ps CPU only; no startup baseline, GPU memory measurement, exit-code or leak acceptance',
        'system': sys.platform,
        'pid': args.pid, 'binary': str(binary), 'process_identity': identity,
        'observation_end': reason, 'observation_seconds': time.monotonic() - started,
        'sample_count': len(samples), 'interval_seconds': args.interval,
        'rss_min_bytes': min(s['rss_bytes'] for s in samples),
        'rss_max_bytes': max(s['rss_bytes'] for s in samples),
        'rss_first_window_median_bytes': statistics.median(first),
        'rss_last_window_median_bytes': statistics.median(last),
        'rss_window_median_change_bytes': statistics.median(last) - statistics.median(first),
        'samples': samples,
    }
    report_path.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: value for key, value in report.items() if key != 'samples'}), flush=True)


if __name__ == '__main__':
    main()
