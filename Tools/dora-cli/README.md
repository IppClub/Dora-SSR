# Dora SSR Development CLI

English | [简体中文](README.zh-CN.md)

A Python-based development tool for the Dora SSR game engine. It provides one project workflow for TypeScript, YueScript, Teal, XML, and Lua entry execution, plus a separate WASM workflow for Rust and Wa.

## Requirements

1. Start the Dora SSR game engine.
2. Open the Dora SSR Web IDE and keep it running.
3. Install the CLI:

```bash
uv tool install Dora-SSR/Tools/dora-cli
```

Or run it without installing:

```bash
uvx --from ./Tools/dora-cli dora --help
```

## Command Model

Project commands:

```bash
dora init
dora build
dora run
dora buildrun
dora stop
```

WASM commands:

```bash
dora wasm build rust
dora wasm run rust Hello
dora wasm upload rust Hello
dora wasm build wa
dora wasm run wa Hello
dora wasm upload wa Hello
```

`Hello` is the destination folder in the Dora SSR resource tree.

## Project Workflow

Initialize a TypeScript-capable project:

```bash
dora init
dora init -l en
```

Build all detected project sources:

```bash
dora build
```

The default project build detects and builds source types in this order:

```text
TypeScript -> YueScript -> Teal -> XML
```

Build selected files:

```bash
dora build -f src/main.ts
dora build -f src/system.yue -f src/types.tl -f ui/main.xml
```

Build a selected language:

```bash
dora build --lang ts
dora build --lang yue
dora build --lang tl
dora build --lang xml
```

Run the Lua entry:

```bash
dora run
dora run --entry main.lua
```

Build and run:

```bash
dora buildrun
dora buildrun -f src/main.ts
dora buildrun -f src/system.yue -f src/types.tl -f ui/main.xml
dora buildrun --entry main.lua
```

Stop the running project:

```bash
dora stop
```

## WASM Workflow

Build a Rust or Wa WASM project:

```bash
dora wasm build rust
dora wasm build wa
```

Build, upload, and run:

```bash
dora wasm run rust Hello --host 192.168.3.1
dora wasm run wa Hello --host 192.168.3.1
```

Upload the latest built `.wasm` without rebuilding:

```bash
dora wasm upload rust Hello --host 192.168.3.1
dora wasm upload wa Hello --host 192.168.3.1
```

Upload and run:

```bash
dora wasm upload rust Hello --run
dora wasm upload wa Hello --run
```

## Options

Common options:

- `-p, --project`: Project directory. Defaults to the current working directory.
- `--host`: Dora SSR host. Defaults to `127.0.0.1`.
- `--port`: Dora SSR port. Defaults to `8866`.
- `--timeout`: HTTP timeout in seconds. Defaults to `10`.

`init` options:

- `-l, --language`: TypeScript API language (`zh-Hans` or `en`). Defaults to `zh-Hans`.

`build` and `buildrun` options:

- `-f, --file`: File or directory to build. Can be passed more than once.
- `--lang`: `auto`, `all`, `ts`, `yue`, `tl`, or `xml`. Defaults to `auto`.
- `--entry`: Lua entry file for `buildrun`. Defaults to `init.lua`.

Environment variables:

```bash
export DORA_PROJECT=/path/to/my-game
export DORA_HOST=127.0.0.1
export DORA_PORT=8866
export DORA_TIMEOUT=10
```

## Project Structure

After `dora init`, a TypeScript project has:

```text
my-game/
├── API/
├── tsconfig.json
├── init.ts
└── init.lua
```

## Troubleshooting

- Connection refused: ensure Dora SSR and the Web IDE are running.
- Compilation errors: check the source file reported by the engine.
- WASM upload fails: verify the target folder and `--host` value.

## License

Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

This software is provided under the MIT License. See the license header in `dora.py` for full details.
