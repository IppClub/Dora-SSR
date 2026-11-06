#!/usr/bin/env python3
"""Generate Godot build-time sources into the isolated xmake build tree."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import os
import shutil
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "Source/3rdParty/Godot"
DEFAULT_PROFILE = ROOT / "Projects/xmake/godot/template_release.json"


class Node:
    def __init__(self, value: object):
        self.value = value

    @property
    def path(self) -> str:
        return str(self.value)

    @property
    def name(self) -> str:
        return Path(str(self.value)).name

    def read(self) -> object:
        return self.value

    def __str__(self) -> str:
        return str(self.value)


def call(builder, target: Path, sources: list[object], env: dict[str, object] | None = None) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    builder([Node(target)], [source if isinstance(source, Node) else Node(source) for source in sources], env or {})


def digest(inputs: list[Path], settings: dict[str, object]) -> str:
    sha = hashlib.sha256()
    sha.update(json.dumps(settings, sort_keys=True, separators=(",", ":")).encode())
    for source in sorted(set(inputs)):
        sha.update(source.relative_to(ROOT).as_posix().encode())
        sha.update(hashlib.sha256(source.read_bytes()).digest())
    return sha.hexdigest()


def write_binary_header(target: Path, source: Path, prefix: str, constants: list[str]) -> None:
    import methods

    buffer = source.read_bytes()
    target.parent.mkdir(parents=True, exist_ok=True)
    with methods.generated_wrapper(str(target)) as file:
        for constant in constants:
            file.write(f"#define {constant}\n")
        file.write(f"\ninline constexpr const unsigned char {prefix}[] = {{\n")
        file.write(f"    {methods.format_buffer(buffer, 1)}\n")
        file.write("};\n")


def generate(output: Path, profile: dict[str, object]) -> list[Path]:
    sys.path.insert(0, str(GODOT))
    os.chdir(GODOT)

    import methods
    from core import core_builders
    from core.extension import make_interface_dumper, make_interface_header, make_wrappers
    from core.input import input_builders
    from core.object import make_virtuals
    from core.profiling import profiling_builders
    from main import main_builders
    from modules import modules_builders
    from scene.theme import default_theme_builders
    from scene.theme.icons import default_theme_icons_builders
    import gles3_builders
    import glsl_builders
    from servers.rendering.storage import make_ltc_lut

    platform_spec = importlib.util.spec_from_file_location(
        "godot_platform_builders", GODOT / "platform/platform_builders.py"
    )
    assert platform_spec and platform_spec.loader
    platform_builders = importlib.util.module_from_spec(platform_spec)
    platform_spec.loader.exec_module(platform_builders)

    outputs: list[Path] = []

    def out(relative: str) -> Path:
        target = output / relative
        outputs.append(target)
        return target

    call(make_ltc_lut.run, out("servers/rendering/storage/ltc_lut.gen.h"), [
        GODOT / "servers/rendering/storage/make_ltc_lut.py",
        GODOT / "servers/rendering/storage/ltc/ltc_lut1.dds",
        GODOT / "servers/rendering/storage/ltc/ltc_lut2.dds",
    ])
    call(core_builders.disabled_class_builder, out("core/disabled_classes.gen.h"), [Node([])])
    call(core_builders.version_info_builder, out("core/version_generated.gen.h"), [Node(methods.get_version_info(""))])
    call(core_builders.version_hash_builder, out("core/version_hash.gen.cpp"), [Node({"git_hash": "", "git_timestamp": 0})])
    call(core_builders.encryption_key_builder, out("core/script_encryption_key.gen.cpp"), [Node("")])
    call(
        core_builders.make_certs_header,
        out("core/io/certs_compressed.gen.h"),
        [GODOT / "thirdparty/certs/ca-bundle.crt", Node(True), Node("")],
    )
    call(core_builders.make_authors_header, out("core/authors.gen.h"), [GODOT / "AUTHORS.md"])
    call(core_builders.make_donors_header, out("core/donors.gen.h"), [GODOT / "DONORS.md"])
    call(core_builders.make_license_header, out("core/license.gen.h"), [GODOT / "COPYRIGHT.txt", GODOT / "LICENSE.txt"])
    call(
        input_builders.make_default_controller_mappings,
        out("core/input/default_controller_mappings.gen.cpp"),
        [Path("core/input/gamecontrollerdb.txt"), Path("core/input/godotcontrollerdb.txt")],
    )
    call(
        profiling_builders.profiler_gen_builder,
        out("core/profiling/profiling.gen.h"),
        [],
        {
            "profiler": profile["profiler"],
            "profiler_sample_callstack": profile["profiler_sample_callstack"],
            "profiler_track_memory": profile["profiler_track_memory"],
        },
    )
    call(make_virtuals.run, out("core/object/gdvirtual.gen.h"), [])
    call(make_wrappers.run, out("core/extension/ext_wrappers.gen.h"), [])
    interface = GODOT / "core/extension/gdextension_interface.json"
    call(make_interface_header.run, out("core/extension/gdextension_interface.gen.h"), [interface])
    call(make_interface_dumper.run, out("core/extension/gdextension_interface_dump.gen.h"), [interface])

    call(main_builders.make_splash, out("main/splash.gen.h"), [GODOT / "main/splash.png"])
    call(main_builders.make_app_icon, out("main/app_icon.gen.h"), [GODOT / "main/app_icon.png"])

    enabled_modules = list(profile["enabled_modules"])
    all_modules = {
        path.parent.name: f"modules/{path.parent.name}"
        for path in sorted((GODOT / "modules").glob("*/register_types.h"))
        if not profile.get("register_enabled_only") or path.parent.name in enabled_modules
    }
    call(modules_builders.modules_enabled_builder, out("modules/modules_enabled.gen.h"), [Node(enabled_modules)])
    call(modules_builders.register_module_types_builder, out("modules/register_module_types.gen.cpp"), [Node(all_modules)])

    platforms = [path.parent.parent.name for path in sorted((GODOT / "platform").glob("*/api/api.h"))]
    call(platform_builders.register_platform_apis_builder, out("platform/register_platform_apis.gen.cpp"), [Node(platforms)])
    for icon in sorted((GODOT / "platform").glob("*/export/*.svg")):
        if icon.name not in {"logo.svg", "run_icon.svg"}:
            continue
        call(platform_builders.export_icon_builder, out(icon.relative_to(GODOT).as_posix().replace(".svg", "_svg.gen.h")), [icon])

    call(
        default_theme_builders.make_fonts_header,
        out("scene/theme/default_font.gen.h"),
        [GODOT / "thirdparty/fonts/OpenSans_SemiBold.woff2"],
    )
    theme_icons = sorted((GODOT / "scene/theme/icons").glob("*.svg"))
    call(default_theme_icons_builders.make_default_theme_icons_action, out("scene/theme/default_theme_icons.gen.h"), theme_icons)

    gles_root = GODOT / "drivers/gles3/shaders"
    gles_sources = [
        gles_root / name
        for name in (
            "canvas.glsl", "feed.glsl", "scene.glsl", "sky.glsl",
            "canvas_occlusion.glsl", "canvas_sdf.glsl", "particles.glsl",
            "particles_copy.glsl", "skeleton.glsl", "tex_blit.glsl",
        )
    ]
    gles_sources += [shader for shader in sorted((gles_root / "effects").glob("*.glsl")) if not shader.name.endswith("_inc.glsl")]
    for shader in gles_sources:
        target = out(shader.relative_to(GODOT).as_posix() + ".gen.h")
        target.parent.mkdir(parents=True, exist_ok=True)
        gles3_builders.build_gles3_header(str(target), str(shader))

    rd_root = GODOT / "servers/rendering/renderer_rd/shaders"
    for shader in sorted(rd_root.glob("*_inc.glsl")):
        target = out(shader.relative_to(GODOT).as_posix() + ".gen.h")
        target.parent.mkdir(parents=True, exist_ok=True)
        glsl_builders.build_raw_header(str(target), str(shader))
    for shader in sorted(rd_root.rglob("*.glsl")):
        if shader.name.endswith("_inc.glsl"):
            continue
        target = out(shader.relative_to(GODOT).as_posix() + ".gen.h")
        target.parent.mkdir(parents=True, exist_ok=True)
        glsl_builders.build_rd_header(str(target), str(shader))

    write_binary_header(
        out("servers/rendering/renderer_rd/effects/smaa_area_tex.gen.h"),
        GODOT / "thirdparty/smaa/AreaTex.png",
        "area_tex_png",
        ["AREATEX_WIDTH 160", "AREATEX_HEIGHT 560", "AREATEX_PITCH (AREATEX_WIDTH * 2)", "AREATEX_SIZE (AREATEX_HEIGHT * AREATEX_PITCH)"],
    )
    write_binary_header(
        out("servers/rendering/renderer_rd/effects/smaa_search_tex.gen.h"),
        GODOT / "thirdparty/smaa/SearchTex.png",
        "search_tex_png",
        ["SEARCHTEX_WIDTH 64", "SEARCHTEX_HEIGHT 16", "SEARCHTEX_PITCH SEARCHTEX_WIDTH", "SEARCHTEX_SIZE (SEARCHTEX_HEIGHT * SEARCHTEX_PITCH)"],
    )
    return outputs


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=ROOT / "build/godot-xmake/generated")
    parser.add_argument("--profile", type=Path, default=DEFAULT_PROFILE)
    parser.add_argument("--disable-module", action="append", default=[])
    args = parser.parse_args()
    output = args.output.resolve()
    profile_path = args.profile.resolve()
    profile = json.loads(profile_path.read_text(encoding="utf-8"))
    for name in args.disable_module:
        if name not in profile["enabled_modules"]:
            parser.error("Cannot disable unknown module: " + name)
        profile["enabled_modules"].remove(name)
    inputs = [Path(__file__), profile_path]
    inputs += [path for path in GODOT.rglob("*.py") if path.is_file()]
    inputs += [path for suffix in ("*.glsl", "*.svg") for path in GODOT.rglob(suffix)]
    inputs += [
        GODOT / name
        for name in (
            "AUTHORS.md", "DONORS.md", "COPYRIGHT.txt", "LICENSE.txt",
            "thirdparty/certs/ca-bundle.crt", "thirdparty/fonts/OpenSans_SemiBold.woff2",
            "thirdparty/smaa/AreaTex.png", "thirdparty/smaa/SearchTex.png",
            "main/splash.png", "main/app_icon.png", "core/input/gamecontrollerdb.txt",
            "core/input/godotcontrollerdb.txt", "core/extension/gdextension_interface.json",
            "servers/rendering/storage/ltc/ltc_lut1.dds", "servers/rendering/storage/ltc/ltc_lut2.dds",
        )
    ]
    fingerprint = digest(inputs, profile)
    state = output / ".xmake-codegen.json"
    if state.is_file():
        previous = json.loads(state.read_text(encoding="utf-8"))
        expected = [output / item for item in previous.get("outputs", [])]
        if previous.get("fingerprint") == fingerprint and expected and all(path.is_file() for path in expected):
            print(f"Godot xmake codegen unchanged: {len(expected)} outputs")
            return

    output.mkdir(parents=True, exist_ok=True)
    # Generate off-tree and publish only changed bytes. Changing the generator
    # without changing its output must not invalidate every compiler receipt.
    outputs = []
    changed = 0
    with tempfile.TemporaryDirectory(prefix=".godot-codegen-", dir=output.parent) as temporary:
        staging = Path(temporary)
        for generated in generate(staging, profile):
            target = output / generated.relative_to(staging)
            if target.is_symlink():
                raise RuntimeError("Generated output must not be a symlink: " + str(target))
            if not target.is_file() or target.read_bytes() != generated.read_bytes():
                target.parent.mkdir(parents=True, exist_ok=True)
                os.replace(generated, target)
                changed += 1
            outputs.append(target)
    payload = {
        "fingerprint": fingerprint,
        "generator": "Tools/Godot/generate_xmake_sources.py",
        "profile": profile_path.relative_to(ROOT).as_posix(),
        "inputs": len(set(inputs)),
        "outputs": [path.relative_to(output).as_posix() for path in outputs],
    }
    state.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"Godot xmake codegen generated: {len(outputs)} outputs, {changed} changed")


if __name__ == "__main__":
    main()
