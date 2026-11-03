#!/usr/bin/env python3
"""Read-only validation for Dora's vendored Godot source tree."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
VENDOR_SOURCE = (ROOT / "Source/3rdParty/Godot").resolve()
UPSTREAM_COMMIT = "89cea143987d564363e15d207438530651d943ac"
UPSTREAM_ARCHIVE_SHA256 = "b451eaa16d3abe0c7430e9ce1c4e83b146e5670e5b683dd8995c931fc82b57a0"

BRIDGE_HEADERS = (
    "GodotBridge.h",
    "GodotBridgeProject.h",
    "GodotBridgeGL.h",
    "GodotBridgeAudio.h",
    "GodotBridgeGLTargets.h",
    "GodotBridgeD3D12.h",
    "GodotBridgeMetalTargets.h",
    "GodotBridgeViewport.h",
    "GodotBridgeOutput.h",
    "GodotBridgeIME.h",
    "GodotBridgeAndroid.h",
    "GodotAudioQueue.h",
)


def _contains(source: Path, relative: str, marker: str) -> None:
    path = source / relative
    assert path.is_file(), f"missing vendored Godot file: {path}"
    assert marker in path.read_text(), f"missing Dora integration marker in {path}: {marker}"


def verify_common(source: Path) -> Path:
    source = source.resolve()
    assert source == VENDOR_SOURCE, f"LibGodot must build from the vendored source: {VENDOR_SOURCE}"
    provenance = json.loads((source / "UPSTREAM.json").read_text())
    assert provenance["upstream_commit"] == UPSTREAM_COMMIT
    assert provenance["source_archive_sha256"] == UPSTREAM_ARCHIVE_SHA256
    assert (source / "LICENSE.txt").is_file()
    assert (source / "COPYRIGHT.txt").is_file()

    module = source / "modules/dora_bridge"
    assert (module / "config.py").is_file()
    for name in BRIDGE_HEADERS:
        host = ROOT / "Source/Godot" / name
        vendored = module / name
        assert host.read_bytes() == vendored.read_bytes(), f"bridge header drift: {name}"

    for relative, marker in (
        ("main/main.cpp", "// Dora manual render timing"),
        ("main/main.cpp", "// Dora threadless audio shutdown"),
        ("platform/macos/libgodot_macos.mm", "dora-metal"),
        ("platform/linuxbsd/libgodot_linuxbsd.cpp", "dora-gl"),
        ("platform/windows/libgodot_windows.cpp", "dora-gl"),
        ("drivers/d3d12/rendering_context_driver_d3d12.cpp", "// Dora D3D12 WARP validation adapter"),
        ("servers/rendering/renderer_rd/forward_mobile/render_forward_mobile.cpp", "// Dora ARM64 WARP shadow receiver compatibility"),
        ("scene/resources/particle_process_material.h", "// Dora particle-key semantic hashing"),
        ("drivers/metal/rendering_device_driver_metal.mm", "// Dora embedded Metal: no asynchronous library compilation past shutdown."),
    ):
        _contains(source, relative, marker)
    return source


def verify_android(source: Path) -> None:
    source = verify_common(source)
    for relative, marker in (
        ("platform/android/detect.py", '"supported": ["mono", "library"]'),
        ("platform/android/java_godot_lib_jni.cpp", "// Dora embedded Android ownership"),
        ("modules/camera/camera_android.cpp", "// Dora embedded orientation"),
        ("platform/android/os_android.cpp", "// Dora host filesystem resources"),
        ("scene/main/window.cpp", "Dora owns offscreen size"),
    ):
        _contains(source, relative, marker)


def verify_ios(source: Path) -> None:
    source = verify_common(source)
    for relative, marker in (
        ("platform/ios/detect.py", '"supported": ["metal", "mono", "library"]'),
        ("drivers/apple_embedded/os_apple_embedded.mm", "Dora GodotInstance has already finalized the loop."),
        ("drivers/metal/rendering_context_driver_metal.mm", "Dora simulator: timed presentation is unavailable in the SDK."),
        ("servers/rendering/renderer_rd/effects/metal_fx.h", "!defined(IOS_SIMULATOR)"),
    ):
        _contains(source, relative, marker)


def verify_web(source: Path) -> None:
    source = verify_common(source)
    for relative, marker in (
        ("platform/web/detect.py", '"supported": ["library"]'),
        ("platform/web/SCsub", "# Dora embedded Web library: the host owns main and all frame scheduling."),
        ("platform/web/audio_driver_web.cpp", "// Dora: unused Web driver."),
        ("platform/web/js/libs/library_godot_os.js", "// Dora embedded user:// persistence."),
    ):
        _contains(source, relative, marker)
