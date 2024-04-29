---
sidebar_position: 7
---

# Package Your Game as a Standalone Application

This tutorial will guide you through the process of packaging your game project as a standalone software package using the Dora SSR game engine, making it independent of the Dora SSR development support tools and Web IDE functionality.

### 1. Prepare Game Assets

Before packaging, ensure that all game assets are correctly placed in the `Assets` directory of your game project. This includes:

- **Art Assets**: Such as images and animations.
- **Audio Files**: Including music and sound effects.
- **Font Files**: All fonts used in the game.
- **Program Scripts**: Including scripts in Lua, Yuescript, Teal, TS, or WASM binary program files.

These assets are essential components of the game's operation and must be included in the final application package.

### 2. Streamline the Assets Directory

In the `Assets` directory, the `Script/Lib` subdirectory contains development support scripts and component libraries provided by the Dora SSR engine, which must be retained as they may be referenced by the game program. Other directories and content can be considered for deletion to reduce the size of the final application package, as long as it does not affect the game’s operation.

### 3. Set Resource Search Path

When developing and testing games with Dora SSR's Web IDE, the engine will by default insert the following paths into the resource search path before running:

1. **Game project root directory/Script**
2. **Game project root directory**
3. **Engine built-in resource root directory/Script/Lib**
4. **Engine built-in resource root directory/Script/Lib/Dora/zh-Hans**

To ensure that the resource search path of your independently packaged game remains consistent, you may need to insert the following code at the very beginning of the script code of the entry program. This ensures a consistent script module loading order. Here is an example with Lua language as the program entry (init file):

```lua title="init.lua"
local Path <const> = require("Path")
local Content <const> = require("Content")

local currentScriptPath = Path:getScriptPath(...)
Content.searchPaths = {
	Path(currentScriptPath, "Script"),
	Path(currentScriptPath),
	Path(Content.assetPath, "Script", "Lib"),
	Path(Content.assetPath, "Script", "Lib", "Dora", "zh-Hans")
}
```

### 4. Building and Packaging Process

The packaging process mainly involves the following steps:

#### a. Configure Packaging Settings
Through the application development IDE of the target platform (such as Xcode, Android Studio, or Visual Studio), locate configuration options including application name, icon, version number, package name, and app signature. Modify these as needed according to your project requirements. These settings are crucial for app recognition and distribution in various app stores.

#### b. Build the Project
Use the application development IDE of the target platform (such as Xcode, Android Studio, or Visual Studio) to build the project. Usually, the correct compiler options provided by the Dora SSR engine's default settings are sufficient. If there are additional optimization needs for the application, adjustments and modifications can be made accordingly. You can refer to the build instructions shown [here](/docs/tutorial/dev-configuration).

#### c. Package the Application
After building, package the executable file and all necessary resource files together. This may include compressing files into a .zip file or using the application development IDE to automatically create an installer.

#### d. Test the Application
Test the packaged application on the target platform to ensure that all functions are working correctly and no resources are missing or incorrect.

### 5. Distribution and Release

Once packaging and testing are completed, your game application is ready for distribution and release. You can choose to release it on various gaming platforms or set up your own download site for players to download.

By following these steps, you can ensure that your game project successfully transitions into a standalone game application, free from the constraints of the Dora SSR development environment tools, providing players with a smooth and stable gaming experience.