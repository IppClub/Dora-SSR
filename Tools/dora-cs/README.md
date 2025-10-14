# Dora-CS

#### English | [中文](README.zh-CN.md)

C# language support for Dora SSR Engine.

## Overview

This project provides C# language bindings for the [Dora SSR](https://github.com/IppClub/Dora-SSR) engine. By compiling the core C++ functionality of the Dora SSR engine into a binary dynamic library (DLL) and exporting a standard C ABI interface, then importing it in C# through P/Invoke technology and wrapping it into C#-idiomatic interfaces, developers can use C# for game development.

## Architecture

```
C++ Core Engine (Dora SSR)
    ↓ Compilation
Dynamic Link Library (Dora.dll)
    ↓ Export C ABI
C Language Interface
    ↓ P/Invoke
C# Wrapper Layer (DoraCS)
    ↓
C# Game Code
```

## Project Structure

- **Dora/** - C++ core engine project, compiles to `Dora.dll` dynamic library
- **DoraCS/** - C# wrapper project, contains P/Invoke bindings and C# API wrappers
  - `Dora/` - Wrapped C# interface classes
  - `Program.cs` - Example entry point
- **CSharpGen/** - C# binding code generation tool
  - `Dora.h` - IDL (Interface Definition Language) file for parsing and generating bindings
  - `gen.yue` - Code generation script that automatically generates C# binding code
  - `lulpeg.lua` - PEG parsing library
- **build/** - Build output directory
  - `Debug/` - Debug configuration build artifacts
  - `Release/` - Release configuration build artifacts

## Requirements

- **Operating System**: Windows
- **Development Tool**: Visual Studio 2022 or later
- **.NET Version**: .NET 8.0
- **C++ Toolset**: Visual Studio C++ toolset (v143 or later)

## Build Instructions

1. **Open Solution**

   Open the `Dora.sln` solution file with Visual Studio.

2. **Build Dora Project**

   In Solution Explorer, right-click the `Dora` project and select "Build".

   This step compiles the C++ core engine and generates the `Dora.dll` dynamic library.

3. **Build DoraCS Project**

   After the Dora project builds successfully, right-click the `DoraCS` project and select "Build".

   This step compiles the C# wrapper layer project.

4. **Run Project**

   Set `DoraCS` as the startup project and press F5 to run.

> **Note**: You must follow the above order - build the Dora project first, then the DoraCS project, as DoraCS depends on Dora.dll.

## Code Generation Tool

The **CSharpGen** directory contains tools for automatically generating C# binding code:

- **Dora.h** - An IDL (Interface Definition Language) file that describes the API of the Dora SSR engine
- **gen.yue** - A code generation script written in YueScript that parses `Dora.h` and automatically generates C# P/Invoke binding code
- **lulpeg.lua** - A PEG (Parsing Expression Grammar) parsing library used to parse the IDL file

When the Dora SSR engine's interfaces change, you can use this tool to synchronize and update the C# binding code, ensuring the DoraCS project stays consistent with the engine core.

## Quick Start

After building, you can start writing game code from the `DoraCS/Program.cs` file. Here's a simple example:

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

## API Documentation

The `Dora/` directory in the DoraCS project contains all wrapped C# interface classes, mainly including:

- **Core Classes**
  - `Node` - Scene node base class
  - `Director` - Director class, controls game main loop
  - `Scheduler` - Scheduler
  - `Content` - Resource management

- **Graphics Rendering**
  - `Sprite` - Sprite
  - `DrawNode` - Draw node
  - `Label` - Text label
  - `Camera` - Camera

- **Animation**
  - `Action` - Action system
  - `Animation` - Animation
  - `Spine` - Spine skeletal animation
  - `DragonBone` - DragonBone skeletal animation

- **Physics Engine**
  - `PhysicsWorld` - Physics world
  - `Body` - Rigid body
  - `Joint` - Joint

- **Audio**
  - `Audio` - Audio manager
  - `AudioSource` - Audio source

- **Platformer**
  - `Platformer.PlatformWorld` - Platform game world
  - `Platformer.Unit` - Game unit

- **Machine Learning**
  - `QLearner` - Q-Learning learner
  - `C45` - C4.5 decision tree

- **Others**
  - `Entity` - ECS entity component system
  - `DB` - Database access
  - `HttpClient` - HTTP client
  - `ImGui` - ImGui library

## Features

- **High Performance**: Direct calls to C++ core engine, near-native performance
- **Type Safety**: Complete C# type wrappers
- **Easy to Use**: API design follows C# language conventions
- **Feature Complete**: Covers all core features of Dora SSR engine
- **Cross-Platform Potential**: Based on standard C ABI, easy to extend to other platforms

## License

Please refer to the license of the main Dora SSR project.

## Links

- [Dora SSR Main Project](https://github.com/IppClub/Dora-SSR)
- [Dora SSR Documentation](https://dora-ssr.net)

## Contributing

Issues and Pull Requests are welcome!

---

**Enjoy game development with C#!**
