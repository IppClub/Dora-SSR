# Dora SSR 开发 CLI

[English](README.md) | 简体中文

一个基于 Python 的开发工具，用于 Dora SSR 游戏引擎，统一支持 TypeScript、Rust 和 Wa 的开发辅助工作流。

## 概述

该工具为 Dora SSR 项目提供统一的命令行工作流，负责 TypeScript API 初始化与编译，以及 Rust / Wa 的 WASM 构建、上传和运行。

## 要求

### 前置条件

1. **Dora SSR 游戏引擎**：必须在本地机器上运行
2. **Web IDE**：Dora SSR Web IDE 必须在后台打开并运行
3. **uv**：推荐用于安装和运行该 CLI 工具

### 设置步骤

1. **启动 Dora SSR 游戏引擎**
   - 在本地机器上启动 Dora SSR 游戏引擎
   - 确保它正在运行并可以访问

2. **打开 Web IDE**
   - 在浏览器中打开 Dora SSR Web IDE
   - 在开发过程中保持引擎在后台运行
   - Web IDE 提供开发环境并处理 TypeScript 编译

3. **安装 CLI 工具**
   ```bash
   uv tool install ./Tools/dora-cli
   ```

   或者不安装，直接运行：
   ```bash
   uvx --from ./Tools/dora-cli dora --help
   ```

## 使用方法

### 命令

该工具支持以下命令组：

- `dora ts`：TypeScript 项目的初始化、构建与运行
- `dora rust`：Rust WASM 的构建、上传与运行辅助
- `dora wa`：Wa WASM 的构建、上传与运行辅助
- `dora stop`：停止当前 Dora SSR 运行目标

#### TypeScript

初始化项目：

```bash
dora ts init [选项]
```

构建项目：

```bash
dora ts build
```

运行项目：

```bash
dora ts run
```

构建并运行：

```bash
dora ts buildrun
```

停止运行：

```bash
dora stop
```

#### Rust WASM

构建 Rust WASM 项目：

```bash
dora rust build
```

构建、上传并运行：

```bash
dora rust run Hello --host 192.168.3.1
```

这里的 `Hello` 是 Dora SSR 资源树中的目标目录名。生成的 `.wasm` 文件会上传到该目录并从这里运行。

不重新构建，仅上传最近生成的 `.wasm`：

```bash
dora rust upload Hello --host 192.168.3.1
```

#### Wa WASM

构建 Wa 项目：

```bash
dora wa build
```

构建、上传并运行：

```bash
dora wa run Hello --host 192.168.3.1
```

这里的 `Hello` 是 Dora SSR 资源树中的目标目录名。生成的 `.wasm` 文件会上传到该目录并从这里运行。

不重新构建，仅上传最近生成的 `.wasm`：

```bash
dora wa upload Hello --host 192.168.3.1
```

#### TypeScript 初始化 (`init`)
设置一个新的 TypeScript 项目，包含所有必要的 API 定义。

```bash
dora ts init [选项]
```

**选项：**
- `-l, --language`: 初始化时的 API 语言 (zh-Hans|en, 默认: zh-Hans)

**示例：**
```bash
dora ts init -l en
```

#### TypeScript 构建 (`build`)
编译 TypeScript 项目并报告编译状态。

```bash
dora ts build
```

**选项：**
- `-f, --file`: 要构建的文件或目录（可选，默认：当前目录）
- `-p, --project`: 项目目录（可选，默认：当前目录）

#### TypeScript 运行 (`run`)
在 Dora SSR 引擎中启动项目。

```bash
dora ts run
```

#### TypeScript 构建并运行 (`buildrun`)
编译 TypeScript 项目，然后立即在 Dora SSR 引擎中启动它。这是一个便捷命令，按顺序组合了 `build` 和 `run`。

```bash
dora ts buildrun
```

**选项：**
- `-f, --file`: 要构建的文件或目录（可选，默认：当前目录）
- `--entry`: 运行时使用的 Lua 入口文件（可选，默认：`init.lua`）

**示例：**
```bash
# 注意指定目标文件后，只会进行目标文件的构建，然后从 init 程序入口运行，不会构建整个项目。
# 这样在项目较大时，可以更快地进行构建和运行。
dora ts buildrun -f src/module.ts
```

### 全局选项

- `-p, --project`: 显式指定项目目录。通过 `uv tool` 安装后，这个选项可以让你在任意目录操作项目。
- `--host`: Dora SSR 主机地址（默认：`127.0.0.1`）
- `--port`: Dora SSR 端口（默认：`8866`）
- `--timeout`: HTTP 超时时间，单位秒

命令专属选项：

- `init`: `-l, --language`
- `build`: `-f, --file`
- `run`: `--entry`
- `buildrun`: `-f, --file`, `--entry`

这些选项也可以通过环境变量配置：

```bash
export DORA_PROJECT=/path/to/my-game
export DORA_HOST=127.0.0.1
export DORA_PORT=8866
export DORA_TIMEOUT=10
```

你也可以查看某个子命令自己的帮助：

```bash
dora ts build --help
dora rust run --help
```

## 工作流程

### TypeScript 工作流

1. **初始化**你的项目：
   ```bash
   dora ts init
   ```

2. **编写 TypeScript 代码**在你的项目目录中。你的项目至少应该有一个 `init.ts`（或 `init.tsx`）文件。

3. **构建**你的项目：
   ```bash
   dora ts build
   ```

4. **运行**你的项目：
   
   ```bash
   dora ts run
   ```
   
   或者使用 **buildrun** 一步完成构建和运行：
   ```bash
   dora ts buildrun
   ```
   
5. **迭代**：进行更改，重新构建，然后再次运行

6. **停止**运行完成时：
   ```bash
   dora stop
   ```

### Rust 工作流

1. **构建** Rust WASM 项目：
   
   ```bash
   dora rust build
   ```
   
2. **构建、上传并运行**到 Dora SSR：
   
   ```bash
   dora rust run Hello --host 192.168.3.1
   ```
   这里的 `Hello` 是 Dora SSR 资源树中的目标目录名。
   
3. **只上传不重新构建**：
   ```bash
   dora rust upload Hello --host 192.168.3.1
   ```

4. **停止**运行完成时：
   ```bash
   dora stop
   ```

### Wa 工作流

1. **构建** Wa 项目：
   ```bash
   dora wa build
   ```

2. **构建、上传并运行**到 Dora SSR：
   ```bash
   dora wa run Hello --host 192.168.3.1
   ```
   这里的 `Hello` 是 Dora SSR 资源树中的目标目录名。

3. **只上传不重新构建**：
   ```bash
   dora wa upload Hello --host 192.168.3.1
   ```

4. **停止**运行完成时：
   ```bash
   dora stop
   ```

## 项目结构

初始化后，你的项目将具有以下结构：

```text
my-game/
├── API/                   # 生成的 TypeScript API 定义
│   ├── Dora.d.ts
│   ├── Platformer.d.ts
│   ├── UI/
│   └── ...
├── tsconfig.json          # TypeScript 配置
├── init.ts                # 你的 TypeScript 入口
└── init.lua               # 构建后生成的 Lua 入口
```

通过 `uv tool` 安装后，CLI 本身可以位于任意位置。它现在默认操作当前工作目录，而不是工具自己的安装目录。

## API 语言

该工具支持两种 API 语言：

- **zh-Hans**：中文（简体）API 文档
- **en**：英文 API 文档

在初始化时使用 `-l` 标志选择你喜欢的语言。

## 故障排除

### 常见问题

1. **连接被拒绝**：确保 Dora SSR 引擎正在运行且 Web IDE 已打开
2. **端口 8866 不可用**：检查引擎的运行端口是否可用
3. **命令无响应**：验证 Web IDE 是否正在运行
4. **编译错误**：检查你的 TypeScript 代码是否有语法错误

## 许可证

Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

本软件在 MIT 许可证下提供。有关完整详细信息，请参阅 `dora.py` 中的许可证标头。

## 支持

有关 Dora SSR 引擎的问题和疑问，请参考 Dora SSR 文档和社区资源。
