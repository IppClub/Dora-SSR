<p align="center">
  <img src='Assets/Image/logo.png' alt='Dora SSR' width='300px'/>
</p>

# Dora SSR

#### English | [中文](README.zh-CN.md)

&emsp;&emsp;Dora SSR is a game engine for rapid development of 2D games on various devices. It has a built-in easy-to-use development tool chain that supports direct game development on mobile phones, open source handhelds and other devices.

|Android|Linux|Windows|macOS|iOS|
|:-:|:-:|:-:|:-:|:-:|
|[![Android](https://github.com/ippclub/Dora-SSR/actions/workflows/android.yml/badge.svg)](https://github.com/ippclub/Dora-SSR/actions/workflows/android.yml)|[![Linux](https://github.com/ippclub/Dora-SSR/actions/workflows/linux.yml/badge.svg)](https://github.com/ippclub/Dora-SSR/actions/workflows/linux.yml)|[![Windows](https://github.com/ippclub/Dora-SSR/actions/workflows/windows.yml/badge.svg)](https://github.com/ippclub/Dora-SSR/actions/workflows/windows.yml)|[![macOS](https://github.com/ippclub/Dora-SSR/actions/workflows/macos.yml/badge.svg)](https://github.com/ippclub/Dora-SSR/actions/workflows/macos.yml)|[![iOS](https://github.com/ippclub/Dora-SSR/actions/workflows/ios.yml/badge.svg)](https://github.com/ippclub/Dora-SSR/actions/workflows/ios.yml)|

<img src='Site/static/img/3.png' alt='Playground' width='600px'/>

## Key Features

- Manages game scenes based on tree node structure.

- Basic 2D platform game functions, including game logic and AI development framework.

- Easy-to-use ECS module for game entity management.

- Asynchronous processing of file read and write, resource loading and other operations.

- Upgraded Lua binding with support for inheriting and extending low-level C++ objects.

- Supports Yuescript language, strong expressive and concise Lua dialect.

- Supports for the Teal language, a statically typed dialect for Lua.

- Supports TypeScript, a statically typed superset of JavaScript that adds powerful type checking.

- Supports TSX, allows embedding XML/HTML-like text within scripts, used with TypeScript.

- Supports the Rust language, running on the built-in WASM runtime with Rust bindings.

- 2D skeletal animation and physics engine support.

- Built-in out-of-the-box Web IDE, providing file management, code inspection, completion, highlighting and definition jump.

- Supports asynchronous operation of SQLite for real-time query and managing large game configuration data.

- Supports reading Excel spreadsheet data and synchronizing it to SQLite tables.

- Supports the Yarn Spinner language, making it easy to write complex game story systems.

- Built-in machine learning algorithm framework for innovative gameplay.

- Provides vector graphics rendering API, which can directly render SVG format files without CSS.

- Built-in ImGui, easy to create debugging tools and UI interface.

- Supports FLAC, OGG, MP3 and WAV multi-format audio playback.

- Supports True Type font rendering and basic typesetting.

- Provides open art resources and game IPs that can be used to create your own games - ["Luv Sense Digital"](http://luvsensedigital.org).

&emsp;&emsp;<img src='Assets/Image/LSD.jpg' alt='LSD' width='300px'/>

<br>

## Installation

- Quick start

  - Android
     - 1. Download and install the [APK](https://github.com/ippclub/Dora-SSR/releases/latest) package on the running terminal for games.

     - 2. Run the software, and access the server address displayed by the software through the browser of a PC (tablet or other development device) on the LAN.

     - 3. Start game development.

  - Windows, macOS

     - 1. Download and run the [software](https://github.com/ippclub/Dora-SSR/releases/latest).
          - Get software on macOS with Homebrew using
          ```sh
          brew tap ippclub/dora-ssr
          brew install --cask dora-ssr
          ```

     - 2. Run the software and access the server address displayed by the software through a browser.

     - 3. Start game development.

- Engine project development

   For the installation and configuration of Dora SSR project development, see [Official Documents](https://Dora-ssr.net/docs/tutorial/dev-configuration) for details.

<br>

## Quick Start

1. Step 1: Create a new project

    - In the browser, open the right-click menu of the game resource tree on the left side of the Dora Dora editor.

    - Click on the menu item `New` and choose to create a new folder.

2. Step 2: Write game code

    - Create a new game entry code file of Yuescript under the project folder, named `init`.

    - Write Hello World code:

```moonscript
_ENV = Dora!

with Sprite "Image/logo.png"
   \addTo Director.entry
   \schedule once ->
     for i = 3, 1, -1
       print i
       sleep 1
     print "Hello World!"
     \perform Sequence(
       Scale 0.1, 1, 0.5
       Scale 0.5, 0.5, 1, Ease. OutBack
     )
```

3. Step 3: Run the game

    Click the `🎮` icon in the lower right corner of the editor, then click the menu item `Run`. Or press the key combination `Ctrl + r`.

4. Step 4: Publish the game

    - Open the right-click menu of the project folder just created through the game resource tree on the left side of the editor and click the `Download` option.

    - Wait for the browser to pop up a download prompt for the packaged project file.


For more detailed tutorials, please check [official documents](https://Dora-ssr.net/docs/tutorial/quick-start).

<br>

## Example Projects

- [Sample Project - Loli War](https://github.com/ippclub/Dora-SSR/tree/main/Assets/Script/Game/Loli%20War)

![Loli War](Assets/Image/LoliWar.gif)

<br>

- [Sample Project - Zombie Escape](https://github.com/ippclub/Dora-SSR/tree/main/Assets/Script/Game/Zombie%20Escape)

<img src='Assets/Image/ZombieEscape.png' alt='Zombie Escape' width='800px'/>

<br>

- [Example Project - Dismentalism](https://github.com/ippclub/Dora-SSR/tree/main/Assets/Script/Game/Dismantlism)

<img src='Assets/Image/Dismentalism.png' alt='Dismentalism' width='800px'/>

<br>

- [Example Project - Luv Sense Digital](https://e.coding.net/project-lsd/lsd/game.git)

<img src='Assets/Image/LuvSenseDigital.png' alt='Luv Sense Digital' width='800px'/>

<br>

## Documentation

- [API Reference](https://Dora-ssr.net/docs/api/intro)
- [Tutorial](https://Dora-ssr.net/docs/tutorial/quick-start)

<br>

## Community

- [Discord](https://discord.gg/ydJVuZhh)
- [QQ Group: 512620381](https://qm.qq.com/cgi-bin/qm/qr?k=7siAhjlLaSMGLHIbNctO-9AJQ0bn0G7i&jump_from=webapi&authKey=Kb6tXlvcJ2LgyTzHQzKwkMxdsQ7sjERXMJ3g10t6b+716pdKClnXqC9bAfrFUEWa)

<br>

## Contribute

Welcome to participate in the development and maintenance of Dora SSR. Please see [Contributing Guidelines](CONTRIBUTING.md) to learn how to submit Issues and Pull Requests.

<br>

## License

Dora SSR uses the [MIT License](LICENSE).
