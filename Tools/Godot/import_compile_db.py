#!/usr/bin/env python3
"""Convert an audited Godot SCons compile DB into a standalone xmake manifest."""

from __future__ import annotations

import argparse
import json
import re
import shlex
from collections import Counter, defaultdict
from pathlib import Path
from native_variants import variant_target


ROOT = Path(__file__).resolve().parents[2]


def lua(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def stage(source: str) -> str:
    if source.startswith("modules/dora_bridge/"):
        return "godot-dora-bridge"
    top = source.split("/", 1)[0]
    return {
        "drivers": "godot-drivers",
        "servers": "godot-servers",
        "scene": "godot-scene",
        "modules": "godot-modules",
        "main": "godot-main-platform",
        "platform": "godot-main-platform",
    }.get(top, "godot-core")


def parse(entry: dict[str, str], include_roots: dict[str, str] | None = None) -> tuple[str, tuple[str, ...], str]:
    args = shlex.split(entry["command"])
    compiler = Path(args[0]).name
    source = entry["file"].replace("\\", "/")
    flags: list[str] = []
    seen_includes: set[str] = set()
    web = "-DWEB_ENABLED" in args
    ios = "-DIOS_ENABLED" in args
    d3d12 = "-DD3D12_ENABLED" in args
    sdk = args[args.index("-isysroot") + 1] if ios else None
    index = 1
    while index < len(args):
        arg = args[index]
        # Architecture, API level and SDK roots belong to the xmake toolchain.
        # In particular, Android's clang -target must not bake one host's NDK
        # command into the portable per-source flag manifest.
        if arg in {"-o", "-arch", "-isysroot", "-target", "--target", "--sysroot"}:
            index += 2
            continue
        if arg == "-c" or arg == source:
            index += 1
            continue
        # iOS SDK headers and deployment targets come from the selected xcode
        # toolchain. Keep each include in place: hoisting SDK headers to global
        # includedirs can change priority relative to bundled dependencies.
        if ios and (arg == "-MMD" or arg.startswith(
                ("-mios-simulator-version-min=", "-miphoneos-version-min="))):
            index += 1
            continue
        if ios and arg == "-MT":
            index += 2
            continue
        if sdk and arg.startswith("-I" + sdk + "/"):
            arg = "-I@SDK@/" + arg[len("-I" + sdk + "/"):]
        for option, root in (include_roots or {}).items():
            if arg.startswith("-I" + root + "/"):
                arg = "-I@CONFIG:" + option + "@/" + arg[len("-I" + root + "/"):]
                break
        # Godot adds this only for editor completion. Relative Homebrew emcc
        # symlinks can turn it into a nonexistent project-relative path;
        # Emscripten supplies its own sysroot for every actual compilation.
        if web and arg.startswith("-I") and "/cache/sysroot/" in arg:
            index += 1
            continue
        if arg in {"-std=gnu17", "-std=gnu++17"}:
            index += 1
            continue
        if arg.startswith(("-mmacosx-version-min=", "--target=", "--sysroot=", "-O")) or arg in {
            "-fno-color-diagnostics",
            "-fno-diagnostics-color",
        }:
            index += 1
            continue
        if arg.startswith("-I") and len(arg) > 2 and not arg.startswith("-I@") and not Path(arg[2:]).is_absolute():
            arg = "-I@GODOT@/" + arg[2:]
        # Clang searches duplicate include directories at their first position.
        # xmake's flag uniquing keeps the last occurrence instead, so remove
        # exact duplicates for every platform while retaining upstream priority.
        if arg.startswith("-I"):
            if arg in seen_includes:
                index += 1
                continue
            seen_includes.add(arg)
        flags.append(arg)
        index += 1
    if ".gen." in source:
        flags.append("-I@GODOT@/" + str(Path(source).parent).replace("\\", "/"))
    suffix = Path(source).suffix
    if suffix.lower() == ".s":
        language = "asflags"
    elif suffix == ".m":
        language = "mflags"
    elif suffix == ".mm":
        language = "mxxflags"
    else:
        language = "cxxflags" if compiler.endswith("++") else "cflags"
    return stage(source), tuple(flags), language


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("compile_db", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--variant", required=True, help="Manifest/wrapper identity, e.g. linux")
    parser.add_argument("--object-platform", required=True, help="SCons object suffix, e.g. linuxbsd")
    parser.add_argument("--generated-root", type=Path, default=Path("build/godot-xmake/generated"),
                        help="Project-relative codegen directory for this platform profile")
    parser.add_argument("--include-root", action="append", default=[], metavar="OPTION=PATH",
                        help="Replace an audited external include root with an xmake string option")
    args = parser.parse_args()
    assert not args.generated_root.is_absolute(), "Generated root must remain project-relative"
    include_roots = {}
    for value in args.include_root:
        option, separator, root = value.partition("=")
        if not separator or not re.fullmatch(r"[a-z][a-z0-9_]*", option) or not Path(root).is_absolute():
            parser.error("--include-root requires a lowercase xmake option and an absolute root")
        include_roots[option] = root.rstrip("/\\")
    entries = json.loads(args.compile_db.read_text(encoding="utf-8"))
    source_counts = Counter(entry["file"].replace("\\", "/") for entry in entries)
    groups: dict[tuple[str, tuple[str, ...], str], list[str]] = defaultdict(list)
    for entry in entries:
        key = parse(entry, include_roots)
        source = entry["file"].replace("\\", "/")
        if source_counts[source] > 1:
            key = (variant_target(source, key[1]), key[1], key[2])
        groups[key].append(source)

    lines = [
        "-- Generated by Tools/Godot/import_compile_db.py from an audited 4.6-stable SCons baseline.",
        "-- This manifest is a migration input; production xmake builds do not read SCons state.",
        'local godot_root = path.join(os.projectdir(), "Source/3rdParty/Godot")',
        f'local generated_root = DORA_GODOT_GENERATED_ROOT or path.join(os.projectdir(), {lua(args.generated_root.as_posix())})',
        "local function source(relative)",
        '    local project_prefix = "@PROJECT@/"',
        "    if relative:sub(1, #project_prefix) == project_prefix then",
        "        return path.join(os.projectdir(), relative:sub(#project_prefix + 1))",
        "    end",
        '    if relative:find(".gen.", 1, true) then',
        "        -- Relative DSL paths preserve file flags before the generated file exists.",
        "        return path.relative(path.join(generated_root, relative), os.scriptdir())",
        "    end",
        "    return path.join(godot_root, relative)",
        "end",
        "local function flag(value)",
        '    if is_mode("debug") and value == "-DNDEBUG" then return "-DDEBUG_ENABLED" end',
    ]
    for option in sorted(include_roots):
        lines += [
            f'    local external_prefix = {lua("-I@CONFIG:" + option + "@/")}',
            "    if value:sub(1, #external_prefix) == external_prefix then",
            # DSL helpers cannot call sandbox-only assert(). The runtime
            # target validates this required option in its on_load hook.
            f'        local root = get_config({lua(option)}) or ""',
            '        return "-I" .. path.join(root, value:sub(#external_prefix + 1))',
            "    end",
        ]
    lines += [
        '    local prefix = "-I@GODOT@/"',
        "    if value:sub(1, #prefix) == prefix then",
        '        return "-I" .. path.join(godot_root, value:sub(#prefix + 1))',
        "    end",
        "    return value",
        "end",
        "",
    ]
    order = lambda item: (item[0][0], item[0][2], item[1][0])
    for (target_name, flags, language), files in sorted(groups.items(), key=order):
        ordered = sorted(files)
        for offset in range(0, len(ordered), 64):
            lines.append(f"target({lua(target_name)})")
            lines.append("    add_files(")
            for filename in ordered[offset : offset + 64]:
                lines.append(f"        source({lua(filename)}),")
            lines.append(f"        {{{language} = {{")
            for flag in flags:
                lines.append(f"            flag({lua(flag)}),")
            lines.append("        }, always_added = true}")
            lines.append("    )")
            lines.append("target_end()")
            lines.append("")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("\n".join(lines), encoding="utf-8")
    print(
        f"wrote {len(entries)} compile actions, {len(source_counts)} unique sources "
        f"and {len(groups)} flag groups to {args.output}"
    )


if __name__ == "__main__":
    main()
