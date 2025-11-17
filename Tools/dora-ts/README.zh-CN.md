# Dora SSR TypeScript 开发工具

[English](README.md) | 简体中文

一个基于 Python 的开发工具，用于 Dora SSR 游戏引擎，支持 TypeScript 开发，提供完整的 IntelliSense 支持和热重载功能，可在外部代码编辑器中使用。

## 概述

该工具为使用 Dora SSR 游戏引擎和 TypeScript 开发游戏和应用程序提供了简化的开发流程。它通过简单的命令行界面处理 API 生成、TypeScript 编译和项目管理。

## 要求

### 前置条件

1. **Dora SSR 游戏引擎**：必须在本地机器上运行
2. **Web IDE**：Dora SSR Web IDE 必须在后台打开并运行
3. **Python 3**：运行开发工具所需

### 设置步骤

1. **启动 Dora SSR 游戏引擎**
   - 在本地机器上启动 Dora SSR 游戏引擎
   - 确保它正在运行并可以访问

2. **打开 Web IDE**
   - 在浏览器中打开 Dora SSR Web IDE
   - 在开发过程中保持引擎在后台运行
   - Web IDE 提供开发环境并处理 TypeScript 编译

3. **安装 Python 依赖**
   ```bash
   pip3 install requests
   ```

## 使用方法

### 命令

该工具支持以下命令：

#### 初始化项目 (`init`)
设置一个新的 TypeScript 项目，包含所有必要的 API 定义。

```bash
./dora.py init [选项]
```

**选项：**
- `-l, --language`: 初始化时的 API 语言 (zh-Hans|en, 默认: zh-Hans)

**示例：**
```bash
./dora.py init -l en
```

#### 构建项目 (`build`)
编译 TypeScript 项目并报告编译状态。

```bash
./dora.py build
# 或者直接
./dora.py
```

**选项：**
- `-f, --file`: 要构建的文件或目录（可选，默认：当前目录）

#### 运行项目 (`run`)
在 Dora SSR 引擎中启动项目。

```bash
./dora.py run
```

#### 构建并运行 (`buildrun`)
编译 TypeScript 项目，然后立即在 Dora SSR 引擎中启动它。这是一个便捷命令，按顺序组合了 `build` 和 `run`。

```bash
./dora.py buildrun
```

**选项：**
- `-f, --file`: 要构建的文件或目录（可选，默认：当前目录）

**示例：**
```bash
# 注意指定目标文件后，只会进行目标文件的构建，然后从 init 程序入口运行，不会构建整个项目。
# 这样在项目较大时，可以更快地进行构建和运行。
./dora.py buildrun -f src/module.ts
```

#### 停止项目 (`stop`)
停止当前正在运行的项目。

```bash
./dora.py stop
```

## 工作流程

### 典型开发工作流程

1. **初始化**你的项目：
   ```bash
   ./dora.py init
   ```

2. **编写 TypeScript 代码**在你的项目目录中。你的项目至少应该有一个 `init.ts`（或 `init.tsx`）文件。

3. **构建**你的项目：
   ```bash
   ./dora.py build
   ```

4. **运行**你的项目：
   ```bash
   ./dora.py run
   ```

   或者使用 **buildrun** 一步完成构建和运行：
   ```bash
   ./dora.py buildrun
   ```

5. **迭代**：进行更改，重新构建，然后再次运行

6. **停止**运行完成时：
   ```bash
   ./dora.py stop
   ```

## 项目结构

初始化后，你的项目将具有以下结构：

```
dora-ts/
├── API/                   # 生成的 TypeScript API 定义
│   ├── Dora.d.ts
│   ├── Platformer.d.ts
│   ├── UI/
│   └── ...
├── tsconfig.json          # TypeScript 配置
├── dora.py                # 此开发工具
└── README.md              # 此文件
```

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

Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

本软件在 MIT 许可证下提供。有关完整详细信息，请参阅 `dora.py` 中的许可证标头。

## 支持

有关 Dora SSR 引擎的问题和疑问，请参考 Dora SSR 文档和社区资源。

