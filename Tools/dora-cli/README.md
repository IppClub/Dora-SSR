# Dora SSR Development CLI

English | [简体中文](README.zh-CN.md)

A Python-based development tool for the Dora SSR game engine that supports TypeScript, Rust, and Wa workflows from one CLI.

## Overview

This tool provides a streamlined workflow for Dora SSR projects. It handles TypeScript API generation and compilation, plus Rust and Wa WASM build/upload/run flows through one command-line interface.

## Requirements

### Prerequisites

1. **Dora SSR Game Engine**: Must be running locally on your machine
2. **Web IDE**: The Dora SSR Web IDE must be open and running in the background
3. **uv**: Recommended for installing and running the CLI as a tool

### Setup Steps

1. **Start the Dora SSR Game Engine**
   - Launch the Dora SSR game engine on your local machine
   - Ensure it's running and accessible

2. **Open the Web IDE**
   - Open the Dora SSR Web IDE in your browser
   - Keep it running in the background during development
   - The Web IDE provides the development environment and handles the TypeScript compilation

3. **Install the CLI**
   ```bash
   uv tool install Tools/dora-cli
   ```

   Or run it without installing:
   ```bash
   uvx --from Tools/dora-cli dora --help
   ```

## Usage

### Commands

The tool supports the following command groups:

- `dora ts`: TypeScript project initialization, build, and run
- `dora rust`: Rust WASM build/upload/run helpers
- `dora wa`: Wa WASM build/upload/run helpers
- `dora stop`: Stop the currently running Dora SSR target

#### TypeScript

Initialize a project:

```bash
dora ts init [options]
```

Build a project:

```bash
dora ts build
```

Run a project:

```bash
dora ts run
```

Build and run:

```bash
dora ts buildrun
```

Stop:

```bash
dora stop
```

#### Rust WASM

Build a Rust WASM project:

```bash
dora rust build
```

Build, upload, and run it in Dora SSR:

```bash
dora rust run Hello --host 192.168.3.1
```

`Hello` is the destination folder name in the Dora SSR resource tree. The generated `.wasm` file will be uploaded there and run from that location.

Upload the latest built `.wasm` without rebuilding:

```bash
dora rust upload Hello --host 192.168.3.1
```

#### Wa WASM

Build a Wa project:

```bash
dora wa build
```

Build, upload, and run it in Dora SSR:

```bash
dora wa run Hello --host 192.168.3.1
```

`Hello` is the destination folder name in the Dora SSR resource tree. The generated `.wasm` file will be uploaded there and run from that location.

Upload the latest built `.wasm` without rebuilding:

```bash
dora wa upload Hello --host 192.168.3.1
```

#### TypeScript Init (`init`)
Sets up a new TypeScript project with all necessary API definitions.

```bash
dora ts init [options]
```

**Options:**
- `-l, --language`: API language for initialization (zh-Hans|en, default: zh-Hans)

**Example:**
```bash
dora ts init -l en
```

#### TypeScript Build (`build`)
Compiles the TypeScript project and reports compilation status.

```bash
dora ts build
```

**Options:**
- `-f, --file`: File or directory to build (optional, default: current directory)
- `-p, --project`: Project directory (optional, default: current directory)

#### TypeScript Run (`run`)
Starts the project in the Dora SSR engine.

```bash
dora ts run
```

#### TypeScript Build and Run (`buildrun`)
Compiles the TypeScript project and then immediately starts it in the Dora SSR engine. This is a convenience command that combines `build` and `run` in sequence.

```bash
dora ts buildrun
```

**Options:**
- `-f, --file`: File or directory to build (optional, default: current directory)
- `--entry`: Lua entry file used for running (optional, default: `init.lua`)

**Example:**
```bash
# If you specify a target file, only the target file will be built, not the entire project. Then the project will be run from the init program entry.
# This allows faster building and running when the project is large.
dora ts buildrun -f src/module.ts
```

### Global Options

- `-p, --project`: Explicit project directory. This makes the tool usable from anywhere, which is important when installed through `uv tool`.
- `--host`: Dora SSR host (default: `127.0.0.1`)
- `--port`: Dora SSR port (default: `8866`)
- `--timeout`: HTTP timeout in seconds

Command-specific options:

- `init`: `-l, --language`
- `build`: `-f, --file`
- `run`: `--entry`
- `buildrun`: `-f, --file`, `--entry`

These can also be configured with environment variables:

```bash
export DORA_PROJECT=/path/to/my-game
export DORA_HOST=127.0.0.1
export DORA_PORT=8866
export DORA_TIMEOUT=10
```

You can inspect command-specific help with:

```bash
dora ts build --help
dora rust run --help
```

## Workflow

### TypeScript Workflow

1. **Initialize** your project:
   ```bash
   dora ts init
   ```

2. **Write TypeScript code** in your project directory. Your project should at least have a `init.ts` (or `init.tsx`) file.

3. **Build** your project:
   ```bash
   dora ts build
   ```

4. **Run** your project:
   ```bash
   dora ts run
   ```

   Or use **buildrun** to build and run in one step:
   ```bash
   dora ts buildrun
   ```

5. **Iterate**: Make changes, rebuild, and run again

6. **Stop** when done running:
   ```bash
   dora stop
   ```

### Rust Workflow

1. **Build** your Rust WASM project:
   
   ```bash
   dora rust build
   ```
   
2. **Build, upload and run** it in Dora SSR:
   
   ```bash
   dora rust run Hello --host 192.168.3.1
   ```
   `Hello` is the destination folder name in the Dora SSR resource tree.
   
3. **Upload without rebuilding** when needed:
   ```bash
   dora rust upload Hello --host 192.168.3.1
   ```

4. **Stop** when done running:
   
   ```bash
   dora stop
   ```

### Wa Workflow

1. **Build** your Wa project:
   ```bash
   dora wa build
   ```

2. **Build, upload and run** it in Dora SSR:
   
   ```bash
   dora wa run Hello --host 192.168.3.1
   ```
   `Hello` is the destination folder name in the Dora SSR resource tree.
   
3. **Upload without rebuilding** when needed:
   ```bash
   dora wa upload Hello --host 192.168.3.1
   ```

4. **Stop** when done running:
   ```bash
   dora stop
   ```

## Project Structure

After initialization, your project will have the following structure:

```text
my-game/
├── API/                   # Generated TypeScript API definitions
│   ├── Dora.d.ts
│   ├── Platformer.d.ts
│   ├── UI/
│   └── ...
├── tsconfig.json          # TypeScript configuration
├── init.ts                # Your TypeScript entry
└── init.lua               # Generated Lua entry after build
```

The CLI itself can live anywhere once installed with `uv tool`. It now operates on the current working directory by default instead of the tool's own installation directory.

## API Languages

The tool supports two API languages:

- **zh-Hans**: Chinese (Simplified) API documentation
- **en**: English API documentation

Choose your preferred language during initialization using the `-l` flag.

## Troubleshooting

### Common Issues

1. **Connection Refused**: Ensure the Dora SSR engine is running and the Web IDE is open
2. **Port 8866 Unavailable**: Check if the engine's running port is available
3. **Command Not Responding**: Verify the Web IDE is running
4. **Compilation Errors**: Check your TypeScript code for syntax errors

## License

Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

This software is provided under the MIT License. See the license header in `dora.py` for full details.

## Support

For issues and questions related to the Dora SSR engine, please refer to the Dora SSR documentation and community resources.
