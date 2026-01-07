# Dora SSR TypeScript Development Tool

English | [简体中文](README.zh-CN.md)

A Python-based development tool for the Dora SSR game engine that enables TypeScript development with full IntelliSense support and hot-reload capabilities in external code editors.

## Overview

This tool provides a streamlined workflow for developing games and applications using the Dora SSR game engine with TypeScript. It handles API generation, TypeScript compilation, and project management through a simple command-line interface.

## Requirements

### Prerequisites

1. **Dora SSR Game Engine**: Must be running locally on your machine
2. **Web IDE**: The Dora SSR Web IDE must be open and running in the background
3. **Python 3**: Required to run the development tool

### Setup Steps

1. **Start the Dora SSR Game Engine**
   - Launch the Dora SSR game engine on your local machine
   - Ensure it's running and accessible

2. **Open the Web IDE**
   - Open the Dora SSR Web IDE in your browser
   - Keep it running in the background during development
   - The Web IDE provides the development environment and handles the TypeScript compilation

3. **Install Python Dependencies**
   ```bash
   pip3 install requests
   ```

## Usage

### Commands

The tool supports the following commands:

#### Initialize Project (`init`)
Sets up a new TypeScript project with all necessary API definitions.

```bash
./dora.py init [options]
```

**Options:**
- `-l, --language`: API language for initialization (zh-Hans|en, default: zh-Hans)

**Example:**
```bash
./dora.py init -l en
```

#### Build Project (`build`)
Compiles the TypeScript project and reports compilation status.

```bash
./dora.py build
# or just
./dora.py
```

**Options:**
- `-f, --file`: File or directory to build (optional, default: current directory)

#### Run Project (`run`)
Starts the project in the Dora SSR engine.

```bash
./dora.py run
```

#### Build and Run (`buildrun`)
Compiles the TypeScript project and then immediately starts it in the Dora SSR engine. This is a convenience command that combines `build` and `run` in sequence.

```bash
./dora.py buildrun
```

**Options:**
- `-f, --file`: File or directory to build (optional, default: current directory)

**Example:**
```bash
# If you specify a target file, only the target file will be built, not the entire project. Then the project will be run from the init program entry.
# This allows faster building and running when the project is large.
./dora.py buildrun -f src/module.ts
```

#### Stop Project (`stop`)
Stops the currently running project.

```bash
./dora.py stop
```

## Workflow

### Typical Development Workflow

1. **Initialize** your project:
   ```bash
   ./dora.py init
   ```

2. **Write TypeScript code** in your project directory. Your project should at least have a `init.ts` (or `init.tsx`) file.

3. **Build** your project:
   ```bash
   ./dora.py build
   ```

4. **Run** your project:
   ```bash
   ./dora.py run
   ```

   Or use **buildrun** to build and run in one step:
   ```bash
   ./dora.py buildrun
   ```

5. **Iterate**: Make changes, rebuild, and run again

6. **Stop** when done running:
   ```bash
   ./dora.py stop
   ```

## Project Structure

After initialization, your project will have the following structure:

```
dora-ts/
├── API/                   # Generated TypeScript API definitions
│   ├── Dora.d.ts
│   ├── Platformer.d.ts
│   ├── UI/
│   └── ...
├── tsconfig.json          # TypeScript configuration
├── dora.py                # This development tool
└── README.md              # This file
```

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