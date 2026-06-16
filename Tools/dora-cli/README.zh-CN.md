# Dora SSR 开发 CLI

[English](README.md) | 简体中文

一个基于 Python 的 Dora SSR 游戏引擎开发工具。它把 TypeScript、YueScript、Teal、XML 和 Lua 入口运行收敛成一套项目工作流，并把 Rust / Wa 的 WASM 构建上传单独放到 WASM 工作流里。

## 要求

1. 启动 Dora SSR 游戏引擎。
2. 打开 Dora SSR Web IDE，并保持它在后台运行。
3. 安装 CLI：

```bash
uv tool install Dora-SSR/Tools/dora-cli
```

也可以不安装直接运行：

```bash
uvx --from ./Tools/dora-cli dora --help
```

## 命令模型

项目命令：

```bash
dora init
dora build
dora run
dora buildrun
dora stop
```

WASM 命令：

```bash
dora wasm build rust
dora wasm run rust Hello
dora wasm upload rust Hello
dora wasm build wa
dora wasm run wa Hello
dora wasm upload wa Hello
```

`Hello` 是 Dora SSR 资源树中的目标目录。

## 项目工作流

初始化支持 TypeScript 的项目：

```bash
dora init
dora init -l en
```

构建检测到的所有项目源码：

```bash
dora build
```

默认项目构建会按这个顺序检测并构建源码：

```text
TypeScript -> YueScript -> Teal -> XML
```

构建指定文件：

```bash
dora build -f src/main.ts
dora build -f src/system.yue -f src/types.tl -f ui/main.xml
```

构建指定语言：

```bash
dora build --lang ts
dora build --lang yue
dora build --lang tl
dora build --lang xml
```

运行 Lua 入口：

```bash
dora run
dora run --entry main.lua
```

构建并运行：

```bash
dora buildrun
dora buildrun -f src/main.ts
dora buildrun -f src/system.yue -f src/types.tl -f ui/main.xml
dora buildrun --entry main.lua
```

停止当前运行项目：

```bash
dora stop
```

## WASM 工作流

构建 Rust 或 Wa WASM 项目：

```bash
dora wasm build rust
dora wasm build wa
```

构建、上传并运行：

```bash
dora wasm run rust Hello --host 192.168.3.1
dora wasm run wa Hello --host 192.168.3.1
```

不重新构建，上传最近生成的 `.wasm`：

```bash
dora wasm upload rust Hello --host 192.168.3.1
dora wasm upload wa Hello --host 192.168.3.1
```

上传并运行：

```bash
dora wasm upload rust Hello --run
dora wasm upload wa Hello --run
```

## 选项

通用选项：

- `-p, --project`: 项目目录，默认是当前工作目录。
- `--host`: Dora SSR 主机地址，默认是 `127.0.0.1`。
- `--port`: Dora SSR 端口，默认是 `8866`。
- `--timeout`: HTTP 超时时间，单位秒，默认是 `10`。

`init` 选项：

- `-l, --language`: TypeScript API 语言（`zh-Hans` 或 `en`），默认是 `zh-Hans`。

`build` 和 `buildrun` 选项：

- `-f, --file`: 要构建的文件或目录，可以传入多次。
- `--lang`: `auto`、`all`、`ts`、`yue`、`tl` 或 `xml`，默认是 `auto`。
- `--entry`: `buildrun` 使用的 Lua 入口，默认是 `init.lua`。

环境变量：

```bash
export DORA_PROJECT=/path/to/my-game
export DORA_HOST=127.0.0.1
export DORA_PORT=8866
export DORA_TIMEOUT=10
```

## 项目结构

执行 `dora init` 后，TypeScript 项目会包含：

```text
my-game/
├── API/
├── tsconfig.json
├── init.ts
└── init.lua
```

## 故障排除

- 连接被拒绝：确认 Dora SSR 和 Web IDE 正在运行。
- 编译错误：查看引擎返回的具体源码文件错误。
- WASM 上传失败：检查目标目录和 `--host` 参数。

## 许可证

Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

本软件在 MIT 许可证下提供。完整信息见 `dora.py` 文件头部的许可证说明。
