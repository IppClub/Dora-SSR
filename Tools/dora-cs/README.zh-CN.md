# Dora-CS

#### [English](README.md) | 中文

Dora SSR 引擎的 C# 语言支持工程。

## 项目简介

本项目为 [Dora SSR](https://github.com/IppClub/Dora-SSR) 引擎提供 C# 语言绑定支持。通过将 Dora SSR 引擎的核心 C++ 功能编译为二进制动态库（DLL），并导出标准的 C 语言 ABI 接口，然后在 C# 中通过 P/Invoke 技术进行导入并封装为符合 C# 语言习惯的接口，使开发者能够使用 C# 语言进行游戏开发。

## 架构说明

```
C++ 核心引擎 (Dora SSR)
    ↓ 编译
动态链接库 (Dora.dll)
    ↓ 导出 C ABI
C 语言接口
    ↓ P/Invoke
C# 封装层 (DoraCS)
    ↓
C# 游戏代码
```

## 项目结构

- **Dora/** - C++ 核心引擎项目，编译生成 `Dora.dll` 动态链接库
- **DoraCS/** - C# 封装项目，包含 P/Invoke 绑定和 C# API 封装
  - `Dora/` - 封装的 C# 接口类
  - `Program.cs` - 示例入口程序
- **CSharpGen/** - C# 绑定代码生成工具
  - `Dora.h` - IDL（接口定义语言）文件，用于解析和生成绑定代码
  - `gen.yue` - 代码生成脚本，自动生成 C# 绑定代码
  - `lulpeg.lua` - PEG 解析库
- **build/** - 编译输出目录
  - `Debug/` - Debug 配置的编译产物
  - `Release/` - Release 配置的编译产物

## 环境要求

- **操作系统**: Windows
- **开发工具**: Visual Studio 2022 或更高版本
- **.NET 版本**: .NET 8.0
- **C++ 工具集**: Visual Studio C++ 工具集（v143 或更高）

## 构建步骤

1. **打开解决方案**

   使用 Visual Studio 打开 `Dora.sln` 解决方案文件。

2. **构建 Dora 项目**

   在解决方案资源管理器中，右键点击 `Dora` 项目，选择"生成"。

   此步骤将编译 C++ 核心引擎并生成 `Dora.dll` 动态链接库。

3. **构建 DoraCS 项目**

   在 Dora 项目构建成功后，右键点击 `DoraCS` 项目，选择"生成"。

   此步骤将编译 C# 封装层项目。

4. **运行项目**

   设置 `DoraCS` 为启动项目，按 F5 运行。

> **注意**: 必须按照上述顺序先构建 Dora 项目，再构建 DoraCS 项目，因为 DoraCS 依赖于 Dora.dll。

## 代码生成工具

**CSharpGen** 目录包含了用于自动生成 C# 绑定代码的工具：

- **Dora.h** - 这是一个 IDL（接口定义语言）文件，描述了 Dora SSR 引擎的 API 接口定义
- **gen.yue** - 使用 YueScript 编写的代码生成脚本，用于解析 `Dora.h` 并自动生成 C# 的 P/Invoke 绑定代码
- **lulpeg.lua** - PEG（Parsing Expression Grammar）解析库，用于解析 IDL 文件

当 Dora SSR 引擎的接口发生变化时，可以使用此工具同步更新 C# 绑定代码，确保 DoraCS 项目与引擎核心保持一致。

## 快速开始

构建完成后，您可以从 `DoraCS/Program.cs` 文件开始编写游戏代码。以下是一个简单的示例：

```csharp
using Dora;
using System.Collections;

App.Run(() =>
{
    var node = new Sprite(Nvg.GetDoraSSR(1.0f));
    node.Schedule(Co.Once(run));
    IEnumerator run()
    {
        for (int i = 3; i >= 1; i--)
        {
            Log.Print($"{i}");
            yield return new WaitForSeconds(1.0);
        }
        Log.Print("Hello World");
        node.PerformDef(ActionDef.Sequence(
        [
            ActionDef.Scale(0.1f, 1.0f, 0.5f, EaseType.Linear),
            ActionDef.Scale(0.5f, 0.5f, 1.0f, EaseType.OutBack),
        ]), false);
    }
});
```

## API 文档

DoraCS 项目中的 `Dora/` 目录包含了所有封装的 C# 接口类，主要包括：

- **核心类**
  - `Node` - 场景节点基类
  - `Director` - 导演类，控制游戏主循环
  - `Scheduler` - 调度器
  - `Content` - 资源管理

- **图形渲染**
  - `Sprite` - 精灵
  - `DrawNode` - 绘图节点
  - `Label` - 文本标签
  - `Camera` - 相机

- **动画**
  - `Action` - 动作系统
  - `Animation` - 动画
  - `Spine` - Spine 骨骼动画
  - `DragonBone` - DragonBone 骨骼动画

- **物理引擎**
  - `PhysicsWorld` - 物理世界
  - `Body` - 刚体
  - `Joint` - 关节

- **音频**
  - `Audio` - 音频管理器
  - `AudioSource` - 音频源

- **平台游戏**
  - `Platformer.PlatformWorld` - 平台游戏世界
  - `Platformer.Unit` - 游戏单位

- **机器学习**
  - `QLearner` - Q-Learning 学习器
  - `C45` - C4.5 决策树

- **其他**
  - `Entity` - ECS 实体组件系统
  - `DB` - 数据库访问
  - `HttpClient` - HTTP 客户端
  - `ImGui` - ImGui 界面库

## 技术特点

- **高性能**: 直接调用 C++ 核心引擎，性能接近原生
- **类型安全**: 提供完整的 C# 类型封装
- **易于使用**: 符合 C# 语言习惯的 API 设计
- **功能完整**: 涵盖 Dora SSR 引擎的所有核心功能
- **跨平台潜力**: 基于标准 C ABI，便于扩展到其他平台

## 许可证

请参考 Dora SSR 主项目的许可证。

## 相关链接

- [Dora SSR 主项目](https://github.com/IppClub/Dora-SSR)
- [Dora SSR 文档](https://dora-ssr.net)

## 贡献

欢迎提交 Issue 和 Pull Request！

---

**享受使用 C# 进行游戏开发的乐趣！**

