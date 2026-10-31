#!/usr/bin/env python3
"""Compare GL direct-target and compatibility blit on the same Linux scene.

The benchmark alternates A/B order, uses the production GodotNode lifecycle,
and records Dora/bgfx profiler samples plus process resources. Virtual GPU
results are functional and directional evidence, never physical-GPU proof.
"""
import argparse
import hashlib
import json
import os
import platform
import re
import statistics
import subprocess
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[3]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--binary", type=Path, required=True)
parser.add_argument("--library", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
parser.add_argument("--repetitions", type=int, default=2)
args = parser.parse_args()
assert sys.platform == "linux" and 1 <= args.repetitions <= 10

binary = args.binary.resolve()
library = args.library.resolve()
output = args.output.resolve()
assert binary.is_file() and library.is_file()
output.mkdir(parents=True, exist_ok=False)


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def percentile(values, fraction):
    ordered = sorted(values)
    if not ordered:
        return None
    return ordered[min(len(ordered) - 1, round((len(ordered) - 1) * fraction))]


def summarize(values):
    return {
        "samples": len(values),
        "median": statistics.median(values) if values else None,
        "p95": percentile(values, 0.95),
        "min": min(values) if values else None,
        "max": max(values) if values else None,
    }


artifacts = {str(path): digest(path) for path in (binary, library)}
environment = os.environ.copy()
for key in list(environment):
    if key.startswith(("DORA_GODOT_TEST_", "DORA_BUILD_", "DORA_GODOT_PROFILER_", "DORA_GODOT_RESOURCE_")):
        environment.pop(key)
environment.update(
    DORA_GODOT_SKIP_BUILD="1",
    DORA_GODOT_SKIP_PREBOOT_ABI="1",
    DORA_GODOT_LIBRARY=str(library),
    DORA_GODOT_DORA_BINARY=str(binary),
    DORA_GODOT_TEST_AUDIO="1",
    DORA_GODOT_TEST_CONTROLLER="1",
    DORA_GODOT_TEST_RESIZE="1",
    DORA_GODOT_TEST_CANCEL_RESIZE="1",
    DORA_GODOT_TEST_ALIASES="1",
    DORA_GODOT_TEST_RESERVATION="1",
    DORA_GODOT_GL_METRICS="1",
)

report = output / "verification.json"
try:
    subprocess.run(
        [sys.executable, str(root / "Tools/Godot/verify_package.py"), str(library.parent),
         "--output", str(output / "package-verification.json")],
        cwd=root, check=True, env=environment,
    )
    subprocess.run(
        [sys.executable, str(root / "Tools/Godot/tests/runtime_abi.py"),
         "--library", str(library), "--backend", "EGL", "--require-audio",
         "--output", str(output / "abi-preboot")],
        cwd=root, check=True, env=environment,
    )
    cases = []
    for buffers in (2, 3, 4):
        for repetition in range(args.repetitions):
            modes = ("direct", "blit") if repetition % 2 == 0 else ("blit", "direct")
            for order, mode in enumerate(modes):
                case = output / f"buffers-{buffers}-rep-{repetition + 1}-{mode}"
                profiler = case / "profiler.jsonl"
                resources = case / "resources.json"
                case.mkdir(parents=True)
                case_env = environment | {
                    "DORA_GODOT_TEST_BUFFERS": str(buffers),
                    "DORA_GODOT_NODE_RESULTS": str(case),
                    "DORA_GODOT_GL_DIRECT": "1" if mode == "direct" else "0",
                    "DORA_GODOT_PROFILER_LOG": str(profiler),
                    "DORA_GODOT_RESOURCE_METRICS": str(resources),
                }
                command = [
                    sys.executable, str(root / "Tools/Godot/tests/with_weston.py"),
                    "--logs", str(case / "weston"), "--",
                    "bash", "Tools/Godot/test_linux.sh",
                ]
                with (case / "driver.log").open("w") as log:
                    subprocess.run(command, cwd=root, env=case_env, stdout=log,
                                   stderr=subprocess.STDOUT, check=True, timeout=900)
                result = json.loads((case / "verification.json").read_text())
                assert result["passed"] and result["platform"] == "Linux EGL"
                raw_log = (case / "run.log").read_text()
                transports = [
                    {"mode": item[0], "policy": item[1], "blits": int(item[2]),
                     "direct_publications": int(item[3]), "gpu_timer": bool(int(item[4])),
                     "gpu_timer_reliable": bool(int(item[5])),
                     "blit_gpu_time_ns": int(item[6]), "blit_gpu_samples": int(item[7]),
                     "blit_gpu_rejected": int(item[8])}
                    for item in re.findall(
                        r"DORA_GODOT_GL_TRANSPORT phase=close mode=(direct|blit) policy=([^ ]+).*?blits=(\d+) direct_publications=(\d+) gpu_timer=(\d+) gpu_timer_reliable=(\d+) blit_gpu_time_ns=(\d+) blit_gpu_samples=(\d+) blit_gpu_rejected=(\d+)",
                        raw_log,
                    )
                ]
                assert transports and all(item["mode"] == mode for item in transports), transports
                if mode == "direct":
                    assert all(item["blits"] == 0 and item["direct_publications"] > 0
                               and item["blit_gpu_time_ns"] == 0 and item["blit_gpu_samples"] == 0
                               for item in transports)
                else:
                    assert all(item["blits"] > 0 and item["direct_publications"] == 0 for item in transports)
                profiler_samples = []
                for line in profiler.read_text().splitlines():
                    payload = json.loads(line)
                    if payload.get("name") == "Profiler" and isinstance(payload.get("info"), dict):
                        profiler_samples.append(payload["info"])
                assert len(profiler_samples) >= 5, len(profiler_samples)
                resource = json.loads(resources.read_text())
                assert resource["exit_code"] == 0
                cases.append({
                    "buffers": buffers,
                    "repetition": repetition + 1,
                    "order": order + 1,
                    "mode": mode,
                    "report": str(case / "verification.json"),
                    "frames": result["frames"],
                    "renderer": result["godot_renderer"],
                    "transport": transports,
                    "profiler_samples": len(profiler_samples),
                    "avg_gpu_ms": summarize([float(item["avgGPU"]) for item in profiler_samples]),
                    "avg_cpu_ms": summarize([float(item["avgCPU"]) for item in profiler_samples]),
                    "fps": summarize([float(item["currentFPS"]) for item in profiler_samples]),
                    "texture_memory_bytes": summarize([int(item["textureMemory"]) for item in profiler_samples]),
                    "blit_gpu_time_ns": sum(item["blit_gpu_time_ns"] for item in transports),
                    "blit_gpu_samples": sum(item["blit_gpu_samples"] for item in transports),
                    "blit_gpu_rejected": sum(item["blit_gpu_rejected"] for item in transports),
                    "resources": resource,
                })
                assert all(digest(Path(path)) == value for path, value in artifacts.items())

    aggregates = {}
    for mode in ("direct", "blit"):
        selected = [case for case in cases if case["mode"] == mode]
        measured_time = sum(case["blit_gpu_time_ns"] for case in selected)
        measured_samples = sum(case["blit_gpu_samples"] for case in selected)
        aggregates[mode] = {
            "runs": len(selected),
            "gpu_ms_median_of_run_medians": summarize([case["avg_gpu_ms"]["median"] for case in selected]),
            "cpu_ms_median_of_run_medians": summarize([case["avg_cpu_ms"]["median"] for case in selected]),
            "fps_median_of_run_medians": summarize([case["fps"]["median"] for case in selected]),
            "texture_memory_peak_bytes": summarize([case["texture_memory_bytes"]["max"] for case in selected]),
            "wall_seconds": summarize([case["resources"]["wall_seconds"] for case in selected]),
            "max_rss_kib": summarize([case["resources"]["max_rss_kib"] for case in selected]),
            "measured_blit_gpu_time_ns": summarize([case["blit_gpu_time_ns"] for case in selected]),
            "measured_blit_gpu_samples": measured_samples,
            "measured_blit_gpu_ns_per_sample": measured_time / measured_samples if measured_samples else None,
            "rejected_blit_gpu_samples": sum(case["blit_gpu_rejected"] for case in selected),
        }
    blit_transports = [item for case in cases if case["mode"] == "blit" for item in case["transport"]]
    gpu_timer_supported = any(item["gpu_timer"] for item in blit_transports)
    gpu_timer_available = any(item["gpu_timer"] and item["gpu_timer_reliable"]
                              and item["blit_gpu_samples"] > 0 for item in blit_transports)
    report.write_text(json.dumps({
        "passed": True,
        "scope": "Same-scene Linux EGL GodotNode direct-vs-blit A/B; virtual GPU is not physical-GPU proof",
        "system": platform.platform(),
        "machine": platform.machine(),
        "artifacts": artifacts,
        "repetitions": args.repetitions,
        "order_alternated": True,
        "gpu_timer_available": gpu_timer_available,
        "gpu_timer_supported": gpu_timer_supported,
        "default_policy_changed": False,
        "cases": cases,
        "aggregates": aggregates,
    }, indent=2) + "\n")
    print("Linux EGL direct-vs-blit A/B: PASS")
except BaseException as error:
    report.unlink(missing_ok=True)
    (output / "failure.json").write_text(json.dumps({
        "passed": False,
        "type": type(error).__name__,
        "error": str(error),
    }, indent=2) + "\n")
    raise
