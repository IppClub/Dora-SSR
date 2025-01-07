<div align="center"><img src='Assets/Image/logo.png' alt='Dora SSR' width='200px'/></div>

# Dora SSR (多萝珍奇引擎)

#### English | [中文](README.zh-CN.md)

Dora SSR is a game engine for rapid development of games on various devices. It has a built-in easy-to-use Web IDE development tool chain that supports direct game development on mobile phones, open source handhelds and other devices.

| Category | Badges |
| - | - |
| Provided Game Dev Tools | ![Static Badge](https://img.shields.io/badge/C%2B%2B20-Game_Engine-d5a64c?logo=c%2B%2B) ![Static Badge](https://img.shields.io/badge/ReactJS-Web_IDE-00d8ff?logo=react) |
| Supported Languages | ![Static Badge](https://img.shields.io/badge/Rust-WASM-e36f39?logo=rust) ![Static Badge](https://img.shields.io/badge/Wa-WASM-e36f39?logo=data%3Aimage%2Fsvg%2Bxml%3Bcharset%3Dutf-8%3Bbase64%2CPHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjMwMCIgdmlld0JveD0iMCAwIDMwMCAzMDAiIGZpbGw9Im5vbmUiCiAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cGF0aCBmaWxsLXJ1bGU9ImV2ZW5vZGQiIGNsaXAtcnVsZT0iZXZlbm9kZCIgZD0iTTAgMjBDMCA4Ljk1NDMgOC45NTQzIDAgMjAgMEg4MEM5MS4wNDYgMCAxMDAgOC45NTQzIDEwMCAyMFYyNFY4MFYxMDBIMjAwVjgwVjI0VjIwQzIwMCA4Ljk1NDMgMjA4Ljk1NCAwIDIyMCAwSDI4MEMyOTEuMDQ2IDAgMzAwIDguOTU0MyAzMDAgMjBWNDRWODBWMjgwQzMwMCAyOTEuMDQ2IDI5MS4wNDYgMzAwIDI4MCAzMDBIMjBDOC45NTQzIDMwMCAwIDI5MS4wNDYgMCAyODBWODBWNDRWMjBaIiBmaWxsPSIjMDBCNUFCIi8%2BCiAgPHBhdGggZD0iTTUwIDU1QzUyLjc2MTQgNTUgNTUgNTIuNzYxNCA1NSA1MEM1NSA0Ny4yMzg2IDUyLjc2MTQgNDUgNTAgNDVDNDcuMjM4NiA0NSA0NSA0Ny4yMzg2IDQ1IDUwQzQ1IDUyLjc2MTQgNDcuMjM4NiA1NSA1MCA1NVoiIGZpbGw9IndoaXRlIi8%2BCiAgPHBhdGggZD0iTTI1MCA1NUMyNTIuNzYxIDU1IDI1NSA1Mi43NjE0IDI1NSA1MEMyNTUgNDcuMjM4NiAyNTIuNzYxIDQ1IDI1MCA0NUMyNDcuMjM5IDQ1IDI0NSA0Ny4yMzg2IDI0NSA1MEMyNDUgNTIuNzYxNCAyNDcuMjM5IDU1IDI1MCA1NVoiIGZpbGw9IndoaXRlIi8%2BCiAgPHBhdGggZD0iTTE1MCAxODBMMTg0IDIxNEwyMTggMTgwTTE1MCAxODBMMTE2IDIxNEw4MiAxODAiIGZpbGw9Im5vbmUiIHN0cm9rZT0id2hpdGUiIHN0cm9rZS13aWR0aD0iOCIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIi8%2BCjwvc3ZnPgo%3D) ![Static Badge](https://img.shields.io/badge/Lua-Scripting-blue?logo=lua) ![Static Badge](https://img.shields.io/badge/TypeScript-Script-blue?logo=typescript) ![Static Badge](https://img.shields.io/badge/TSX-Scripting-blue?logo=typescript) ![Static Badge](https://img.shields.io/badge/Teal-Scripting-blue) ![Static Badge](https://img.shields.io/badge/YueScript-Script-blue?logo=data%3Aimage%2Fsvg%2Bxml%3Bcharset%3Dutf-8%3Bbase64%2CPD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8%2BCjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI%2BCjxzdmcgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDM3OCAzMjYiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSIgeG1sbnM6c2VyaWY9Imh0dHA6Ly93d3cuc2VyaWYuY29tLyIgc3R5bGU9ImZpbGwtcnVsZTpldmVub2RkO2NsaXAtcnVsZTpldmVub2RkO3N0cm9rZS1saW5lam9pbjpyb3VuZDtzdHJva2UtbWl0ZXJsaW1pdDoyOyI%2BCiAgICA8ZyB0cmFuc2Zvcm09Im1hdHJpeCgxLDAsMCwxLC0yOTguNCwtNTguMykiPgogICAgICAgIDxnPgogICAgICAgICAgICA8cGF0aCBkPSJNNDE2LjgsMzIyLjVDNDEzLjEsMzIzLjMgNDA4LjcsMzI0LjEgNDA1LjEsMzI0LjhDNDA1LjYsMzIyLjggNDA3LDMxNyA0MDgsMzEzLjNMNDA1LjIsMzEwLjRMNDAxLjksMzI0LjlDNDAxLjksMzI1LjEgNDAxLjgsMzI1LjMgNDAxLjYsMzI1LjVMMzk1LjYsMzMxLjJMMzk4LDMzMy44TDQwNC4xLDMyOEM0MDQuMywzMjcuOCA0MDQuNCwzMjcuNyA0MDQuNiwzMjcuN0w0MTkuMywzMjUuMkw0MTYuOCwzMjIuNVoiIHN0eWxlPSJmaWxsOnJnYigxODAsMTcyLDE0Myk7ZmlsbC1ydWxlOm5vbnplcm87Ii8%2BCiAgICAgICAgICAgIDxwYXRoIGQ9Ik00MzIuNCwzNTEuN0M0MzAuNSwzNTQuNCA0MjguMiwzNTUuNiA0MjQuNiwzNTMuMkM0MjEsMzUwLjcgNDIxLjIsMzQ4IDQyMywzNDUuNEw0MzAuNywzMzQuMkw0MjcuOCwzMzIuMkw0MjAsMzQzLjZDNDE3LjIsMzQ3LjYgNDE3LjcsMzUxLjUgNDIzLjIsMzU1LjNDNDI5LjEsMzU5LjMgNDMyLjksMzU3LjcgNDM1LjQsMzU0TDQ0My4xLDM0Mi43TDQ0MC4xLDM0MC43TDQzMi40LDM1MS43WiIgc3R5bGU9ImZpbGw6cmdiKDE4MCwxNzIsMTQzKTtmaWxsLXJ1bGU6bm9uemVybzsiLz4KICAgICAgICAgICAgPHBhdGggZD0iTTQ0OC4xLDM2OS4xTDQ2Mi41LDM3NC44TDQ2My45LDM3Mi43TDQ1Mi4zLDM2OEw0NTUsMzYxLjJMNDY1LjYsMzY1LjRMNDY2LjUsMzYzTDQ1NiwzNTguOEw0NTguNCwzNTIuOUw0NjkuNCwzNTcuM0w0NzAuMywzNTVMNDU2LjEsMzQ5LjNMNDQ4LjEsMzY5LjFaIiBzdHlsZT0iZmlsbDpyZ2IoMTgwLDE3MiwxNDMpO2ZpbGwtcnVsZTpub256ZXJvOyIvPgogICAgICAgICAgICA8cGF0aCBkPSJNNDkwLjYsMzU5LjZDNDg1LjksMzU4LjggNDgyLjQsMzYwLjQgNDgxLjgsMzYzLjhDNDgxLjMsMzY2LjggNDgzLDM2OC43IDQ4OC4xLDM3MUM0OTIuMSwzNzIuOCA0OTMuMywzNzQgNDkyLjksMzc2LjNDNDkyLjUsMzc4LjUgNDkwLjUsMzc5LjQgNDg3LjUsMzc4LjlDNDg0LjYsMzc4LjQgNDgyLjgsMzc2LjcgNDgyLjcsMzc0LjFMNDc5LjIsMzczLjVDNDc4LjksMzc3LjQgNDgxLjYsMzgwLjMgNDg2LjgsMzgxLjNDNDkyLjUsMzgyLjMgNDk1LjgsMzgwLjIgNDk2LjQsMzc2LjdDNDk2LjksMzczLjggNDk1LjcsMzcxLjUgNDg5LjgsMzY4LjhDNDg2LjEsMzY3LjEgNDg0LjksMzY2LjIgNDg1LjIsMzY0LjNDNDg1LjUsMzYyLjUgNDg3LjEsMzYxLjYgNDg5LjksMzYyLjFDNDkyLjksMzYyLjYgNDk0LDM2NC4yIDQ5NCwzNjYuM0w0OTcuNCwzNjYuOUM0OTgsMzYzLjYgNDk2LjEsMzYwLjYgNDkwLjYsMzU5LjZaIiBzdHlsZT0iZmlsbDpyZ2IoMTgwLDE3MiwxNDMpO2ZpbGwtcnVsZTpub256ZXJvOyIvPgogICAgICAgICAgICA8cGF0aCBkPSJNNTIyLjMsMzgxLjFDNTE3LjEsMzgxLjMgNTE1LjMsMzc3LjEgNTE1LjIsMzcyLjdDNTE1LDM2OC4zIDUxNi44LDM2NC4zIDUyMS42LDM2NC4xQzUyNS4zLDM2NCA1MjYuOCwzNjUuNyA1MjcuNSwzNjhMNTMxLDM2Ny45QzUzMC40LDM2NC40IDUyNy42LDM2MS40IDUyMS42LDM2MS42QzUxNC40LDM2MS45IDUxMS4zLDM2Ny4xIDUxMS41LDM3Mi44QzUxMS43LDM3OS4xIDUxNC43LDM4My44IDUyMi4zLDM4My41QzUyOC40LDM4My4zIDUzMC45LDM4MCA1MzEuNSwzNzYuNUw1MjgsMzc2LjZDNTI3LjQsMzc5IDUyNiwzODEgNTIyLjMsMzgxLjFaIiBzdHlsZT0iZmlsbDpyZ2IoMTgwLDE3MiwxNDMpO2ZpbGwtcnVsZTpub256ZXJvOyIvPgogICAgICAgICAgICA8cGF0aCBkPSJNNTYzLjcsMzcwLjdDNTYzLDM2Ny45IDU2MS41LDM2Ni41IDU1OC44LDM2Ni41QzU2MC42LDM2NS40IDU2Mi4zLDM2My42IDU2MS41LDM2MC42QzU2MC42LDM1Ny4xIDU1NywzNTYgNTUyLjYsMzU3LjJMNTQzLjcsMzU5LjVMNTQ5LDM4MC4xTDU1Mi40LDM3OS4yTDU1MCwzNzBMNTU0LjEsMzY4LjlDNTU4LDM2Ny45IDU1OS41LDM2OC43IDU2MC4yLDM3MS41TDU2MC4zLDM3MS45QzU2MC45LDM3NC4xIDU2MS40LDM3NS45IDU2MiwzNzYuN0w1NjUuNCwzNzUuOEM1NjQuOCwzNzQuNyA1NjQuMywzNzIuOSA1NjMuOCwzNzFMNTYzLjcsMzcwLjdaTTU1My44LDM2Ni41TDU0OS40LDM2Ny42TDU0Ny43LDM2MC45TDU1Mi44LDM1OS42QzU1NS42LDM1OC45IDU1Ny42LDM1OS41IDU1OC4xLDM2MS42QzU1OC44LDM2NC41IDU1Ni44LDM2NS44IDU1My44LDM2Ni41WiIgc3R5bGU9ImZpbGw6cmdiKDE4MCwxNzIsMTQzKTtmaWxsLXJ1bGU6bm9uemVybzsiLz4KICAgICAgICAgICAgPGcgdHJhbnNmb3JtPSJtYXRyaXgoMC45MTA1LC0wLjQxMzYsMC40MTM2LDAuOTEwNSwtOTYuMTEyNSwyNzIuNzE3KSI%2BCiAgICAgICAgICAgICAgICA8cmVjdCB4PSI1NzcuNCIgeT0iMzQ4LjMiIHdpZHRoPSIzLjUiIGhlaWdodD0iMjEuMyIgc3R5bGU9ImZpbGw6cmdiKDE4MCwxNzIsMTQzKTsiLz4KICAgICAgICAgICAgPC9nPgogICAgICAgICAgICA8cGF0aCBkPSJNNTk3LDMzNi42TDU4OS44LDM0MS41TDYwMS44LDM1OS4xTDYwNC43LDM1Ny4xTDU5OS42LDM0OS43TDYwMy41LDM0N0M2MDcuOCwzNDQuMSA2MDkuNiwzNDAuMyA2MDcuMiwzMzYuOEM2MDUuMSwzMzMuNiA2MDAuOSwzMzMuOSA1OTcsMzM2LjZaTTYwMi4xLDM0NS4xTDU5OC40LDM0Ny43TDU5NC4yLDM0MS41TDU5OCwzMzguOUM2MDAuNiwzMzcuMSA2MDMsMzM2LjkgNjA0LjQsMzM4LjlDNjA2LDM0MS4zIDYwNC43LDM0My4zIDYwMi4xLDM0NS4xWiIgc3R5bGU9ImZpbGw6cmdiKDE4MCwxNzIsMTQzKTtmaWxsLXJ1bGU6bm9uemVybzsiLz4KICAgICAgICAgICAgPHBhdGggZD0iTTYyNi42LDMxMy40TDYyNC43LDMxMS42TDYxMi4xLDMyNC44TDYxNCwzMjYuNUw2MTksMzIxLjJMNjMyLjYsMzM0LjJMNjM1LjEsMzMxLjZMNjIxLjUsMzE4LjdMNjI2LjYsMzEzLjRaIiBzdHlsZT0iZmlsbDpyZ2IoMTgwLDE3MiwxNDMpO2ZpbGwtcnVsZTpub256ZXJvOyIvPgogICAgICAgICAgICA8cGF0aCBkPSJNNTQxLjIsNjAuMkM1MzkuMSw1OS45IDUzNyw1OS42IDUzNC45LDU5LjNMNTM0LjksNzQuMkM1NTcuMyw5OC40IDU3MS44LDEzMC4xIDU3My45LDE2NS4xTDQzNS43LDE2NS4xQzQzNS43LDE2NS4xIDQyMS43LDE2NS44IDQyMS43LDE3Ny40QzQyMS43LDE4OS41IDQzMi44LDE5MS41IDQzNS42LDE5MS41TDUwNSwxOTEuNUM1MDUsMTkxLjUgNTEzLjcsMTkxIDUxMy43LDE5Ny42QzUxMy43LDIwMy45IDUwNy4zLDIwMy42IDUwNS4xLDIwMy42TDM2My42LDIwMy42QzM3NC42LDEyOS4zIDQzMi44LDcwLjQgNTA2LjcsNTguM0M0MjcsNjIuNSAzNjIuNSwxMjQuOCAzNTQuOCwyMDMuNkwzMTMuNywyMDMuNkMzMTMuNywyMDMuNiAyOTguNCwyMDEuOCAyOTguNCwyMTUuMUMyOTguNCwyMjguNCAzMDkuOSwyMjcuOSAzMTMuMSwyMjcuOUwzNTQuMiwyMjcuOUMzNTUuNywyNTYuMiAzNjQuNiwyODIuNyAzNzguOSwzMDUuM0wzNzksMzA1LjJDMzcwLjIsMjg3LjMgMzY0LjUsMjY3LjYgMzYyLjQsMjQ2LjhMNDM3LjcsMjQ2LjhDNDQxLjMsMjQ2LjggNDUxLjQsMjQ2LjMgNDUxLjQsMjM0LjZDNDUxLjQsMjIzIDQzOSwyMjIuNyA0MzksMjIyLjdMMzM3LjIsMjIyLjdDMzM3LjIsMjIyLjcgMzI4LjMsMjIzLjQgMzI4LjMsMjE2LjNDMzI4LjMsMjA5LjIgMzM0LjEsMjA4LjkgMzM2LjcsMjA4LjlMNTI3LjIsMjA4LjlDNTI3LjIsMjA4LjkgNTQxLjgsMjEwLjUgNTQxLjgsMTk3QzU0MS44LDE4NSA1MjksMTg1LjUgNTI0LjMsMTg1LjVMNDU5LjIsMTg1LjVDNDU5LjIsMTg1LjUgNDQ5LjUsMTg1LjkgNDQ5LjUsMTc4LjZDNDQ5LjUsMTcxLjMgNDU3LjcsMTcxLjcgNDU5LjEsMTcxLjdMNTczLjgsMTcxLjdMNTczLjgsMTczLjlDNTczLjgsMjEyLjQgNTU4LjksMjQ3LjUgNTM0LjUsMjczLjdDNTEyLjksMjk3IDQ4My44LDMxMy4zIDQ1MSwzMTguOEM0NTcuMywzMjIuNyA0NjMuOSwzMjYuMSA0NzAuOCwzMjlDNDk0LjcsMzIyLjIgNTE2LjQsMzEwIDUzNC40LDI5My44QzU0OS4xLDI4MC42IDU2MS40LDI2NC42IDU3MC41LDI0Ni44TDY0MS42LDI0Ni44TDY0MS42LDI0MC4xTDU3My43LDI0MC4xQzU4Mi44LDIxOS45IDU4Ny45LDE5Ny41IDU4Ny45LDE3My45TDU4Ny45LDE3MS43TDY1My44LDE3MS43QzY1OC45LDE4Ni42IDY2MS43LDIwMi41IDY2MS43LDIxOS4xQzY2MS43LDI0Ni42IDY1NC4xLDI3Mi40IDY0MC44LDI5NC41TDY1MiwzMDMuNkM2NjcuMiwyNzkgNjc2LDI1MC4xIDY3NiwyMTkuMUM2NzYuNCwxMzkuMiA2MTcuOCw3Mi42IDU0MS4yLDYwLjJaTTQyMy45LDIzNS4zQzQyMy45LDI0MS44IDQxNy42LDI0Mi4yIDQxNy42LDI0Mi4yTDM2Mi4yLDI0Mi4yQzM2MS45LDIzNy45IDM2MS43LDIzMy42IDM2MS43LDIyOS4zTDM2MS43LDIyNy45TDQxOC4yLDIyNy45QzQxOS4yLDIyOCA0MjMuOSwyMjguOCA0MjMuOSwyMzUuM1pNNTg4LjIsMTY1LjFDNTg2LjQsMTMyLjcgNTc1LjEsMTAyLjkgNTU2LjksNzguNEM2MDAuMiw5MS4yIDYzNS4zLDEyMy41IDY1MS45LDE2NS4xTDU4OC4yLDE2NS4xWiIgc3R5bGU9ImZpbGw6cmdiKDE4MCwxNzIsMTQzKTtmaWxsLXJ1bGU6bm9uemVybzsiLz4KICAgICAgICA8L2c%2BCiAgICA8L2c%2BCjwvc3ZnPgo%3D) |
| Supported Platforms | ![Android](https://github.com/ippclub/Dora-SSR/actions/workflows/android.yml/badge.svg) ![Linux](https://github.com/ippclub/Dora-SSR/actions/workflows/linux.yml/badge.svg) ![Windows](https://github.com/ippclub/Dora-SSR/actions/workflows/windows.yml/badge.svg) ![macOS](https://github.com/ippclub/Dora-SSR/actions/workflows/macos.yml/badge.svg) ![iOS](https://github.com/ippclub/Dora-SSR/actions/workflows/ios.yml/badge.svg) |

<div align='center'><img src='Docs/static/img/3.png' alt='Playground' width='500px'/></div>

## Table of Contents

- [Key Features](#key-features)
- [Example Projects](#example-projects)
- [Installation](#installation)
	- [Android](#android)
	- [Windows](#windows)
	- [macOS](#macos)
	- [Linux](#linux)
- [Quick Start](#quick-start)
- [Documentation](#documentation)
- [Community](#community)
- [Contribute](#contribute)
- [License](#license)

<br>

## Key Features

|Feature|Description|
|-|-|
|Cross-Platform|Supported native architectures:<br>**Android** (x86_64, armv7, arm64)<br>**Windows** (x86)<br>**Linux** (x86_64, arm64)<br>**iOS** (arm64)<br>**macOS** (x86_64, arm64)|
|Node Based|Manages game scenes based on tree node structure.|
|ECS|Easy-to-use [ECS](https://dora-ssr.net/docs/tutorial/using-ecs) module for efficient game entity management.|
|Multi-threaded|Asynchronous processing of file read and write, resource loading and other operations.|
|Lua|Upgraded Lua binding with support for inheriting and extending low-level C++ objects.|
|YueScript|Supports [YueScript](https://yuescript.org) language, strong expressive and concise Lua dialect.|
|Teal|Supports for the [Teal](https://github.com/teal-language/tl) language, a statically typed dialect for Lua.|
|TypeScript|Supports [TypeScript](https://www.typescriptlang.org), a statically typed superset of JavaScript that adds powerful type checking (with [TSTL](https://typescripttolua.github.io)).|
|TSX|Supports [TSX](https://dora-ssr.net/docs/tutorial/Language%20Tutorial/using-tsx), allows embedding XML/HTML-like text within scripts, used with TypeScript.|
|Rust|Supports the [Rust](https://www.rust-lang.org) language, running on the built-in WASM runtime with [Rust bindings](https://lib.rs/crates/dora-ssr).|
|Wa|Supports the [Wa](https://wa-lang.org) language, a simple, reliable, and statically typed language running on the built-in WASM runtime with [Wa bindings](https://github.com/IppClub/Dora-SSR/tree/main/Tools/dora-wa).|
|2D Animation|2D skeletal animations support with [Spine2D](https://github.com/EsotericSoftware/spine-runtimes), [DragonBones](https://github.com/DragonBones/DragonBonesCPP) and a builtin system.|
|2D Physics|2D physics engine support with [PlayRho](https://github.com/louis-langholtz/PlayRho).|
|Web IDE|Built-in out-of-the-box Web IDE, providing file management, code inspection, completion, highlighting and definition jump. <br><br><div align='center'><img src='Docs/static/img/dora-on-android.jpg' alt='LSD' width='500px'/></div>|
|Database|Supports asynchronous operation of [SQLite](https://www.sqlite.org) for real-time query and managing large game configuration data.|
|Excel|Supports reading Excel spreadsheet data and synchronizing it to SQLite tables.|
|CSS Layout|Provides the function of adaptive Flex layout for game scenes through CSS (with [Yoga](https://github.com/facebook/yoga)).|
|Effect System|Support the functions of [Effekseer](https://github.com/effekseer/Effekseer) game effects system.|
|Tilemap|Supports the [Tiled Map Editor](http://www.mapeditor.org) TMX map file parsing and rendering.|
|Yarn Spinner|Supports the [Yarn Spinner](https://www.yarnspinner.dev) language, making it easy to write complex game story systems.|
|ML|Built-in machine learning algorithm framework for innovative gameplay.|
|Vector Graphics|Provides vector graphics rendering API, which can directly render SVG format files without CSS (with [NanoVG](https://github.com/memononen/nanovg)).|
|ImGui|Built-in [ImGui](https://github.com/ocornut/imgui), easy to create debugging tools and UI interface.|
|Audio|Supports FLAC, OGG, MP3 and WAV multi-format audio playback.|
|True Type|Supports True Type font rendering and basic typesetting.|
|2D Platformer|Basic [2D platformer](https://dora-ssr.net/docs/example/Platformer%20Tutorial/start) game functions, including game logic and AI development framework.|
|L·S·D|Provides open art resources and game IPs that can be used to create your own games - ["Luv Sense Digital"](https://luv-sense-digital.readthedocs.io).<br><br><div align='center'><img src='Docs/static/img/LSD.jpg' alt='LSD' width='300px'/></div>|

<br>

## Example Projects

- [Sample Project - Loli War](Assets/Script/Game/Loli%20War)

<div align='center'><img src='Docs/static/img/LoliWar.gif' alt='Loli War' width='400px'/></div>

<br>

- [Sample Project - Zombie Escape](Assets/Script/Game/Zombie%20Escape)

<div align='center'><img src='Docs/static/img/ZombieEscape.png' alt='Zombie Escape' width='800px'/></div>

<br>

- [Example Project - Dismentalism](Assets/Script/Game/Dismantlism)

<div align='center'><img src='Docs/static/img/Dismentalism.png' alt='Dismentalism' width='800px'/></div>

<br>

- [Example Project - Luv Sense Digital](https://github.com/IppClub/LSD)

<div align='center'><img src='Docs/static/img/LuvSenseDigital.png' alt='Luv Sense Digital' width='800px'/></div>

<br>

## Installation

### Android

- 1\. Download and install the [APK](https://github.com/ippclub/Dora-SSR/releases/latest) package on the running terminal for games.
- 2\. Run the software, and access the server address displayed by the software through the browser of a PC (tablet or other development device) on the LAN.
- 3\. Start game development.

### Windows

- 1\. Ensure that you have the X86 Visual C++ Redistributable for Visual Studio 2022 (the MSVC runtime package vc_redist.x86) installed to run the application. You can download it from the [Microsoft website](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170).
- 2\. Download and decompress the [software](https://github.com/ippclub/Dora-SSR/releases/latest).
- 3\. Run the software and access the server address displayed by the software through a browser.
- 4\. Start game development.

### macOS

- 1\. Download and decompress the [software](https://github.com/ippclub/Dora-SSR/releases/latest). Or you can get software using [Homebrew](https://brew.sh) with:
	```sh
	brew install --cask ippclub/tap/dora-ssr
	```
- 2\. Run the software and access the server address displayed by the software through a browser.
- 3\. Start game development.

### Linux

- 1\. Installation from PPA.
	- Ubuntu Jammy
	```sh
	sudo add-apt-repository ppa:ippclub/dora-ssr
	sudo apt update
	sudo apt install dora-ssr
	```
	- Debian Bookworm
	```sh
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 9C7705BF
	sudo add-apt-repository -S "deb https://ppa.launchpadcontent.net/ippclub/dora-ssr/ubuntu jammy main"
	sudo apt update
	sudo apt install dora-ssr
	```
- 2\. Run the software and access the server address displayed by the software through a browser.
- 3\. Start game development.

### Build Game Engine

- For the building instructions of Dora SSR project, see [Official Documents](https://dora-ssr.net/docs/tutorial/dev-configuration) for details.

<br>

## Quick Start

- Step One: Create a new project
	- In the browser, open the right-click menu of the game resource tree on the left side of the Dora Dora editor.
	- Click on the menu item `New` and choose to create a new folder.
- Step Two: Write game code
	- Create a new game entry code file of Lua (YueScript, Teal, TypeScript or TSX) under the project folder, named `init`.
	- Write Hello World code:

- **Lua**

```lua
local _ENV = Dora

local sprite = Sprite("Image/logo.png")
sprite:once(function()
  for i = 3, 1, -1 do
    print(i)
    sleep(1)
  end
  print("Hello World")
  sprite:perform(Sequence(
    Scale(0.1, 1, 0.5),
    Scale(0.5, 0.5, 1, Ease.OutBack)
  ))
end)
```

- **Teal**

```lua
local sleep <const> = require("sleep")
local Ease <const> = require("Ease")
local Scale <const> = require("Scale")
local Sequence <const> = require("Sequence")
local Sprite <const> = require("Sprite")

local sprite = Sprite("Image/logo.png")
if not sprite is nil then
  sprite:once(function()
    for i = 3, 1, -1 do
      print(i)
      sleep(1)
    end
    print("Hello World")
    sprite:perform(Sequence(
      Scale(0.1, 1, 0.5),
      Scale(0.5, 0.5, 1, Ease.OutBack)
    ))
  end)
end
```

- **YueScript**

	The story of YueScript, a niche language supported by Dora SSR, can be found [here](https://dora-ssr.net/blog/2024/4/17/a-moon-script-tale).

```moonscript
_ENV = Dora

with Sprite "Image/logo.png"
   \once ->
     for i = 3, 1, -1
       print i
       sleep 1
     print "Hello World!"
     \perform Sequence(
       Scale 0.1, 1, 0.5
       Scale 0.5, 0.5, 1, Ease.OutBack
     )
```

- **TypeScript**

```typescript
import {Sprite, Ease, Scale, Sequence, sleep} from 'Dora';

const sprite = Sprite("Image/logo.png");
if (sprite) {
  sprite.once(() => {
    for (let i of $range(3, 1, -1)) {
      print(i);
      sleep(1);
    }
    print("Hello World");
    sprite.perform(Sequence(
      Scale(0.1, 1, 0.5),
      Scale(0.5, 0.5, 1, Ease.OutBack)
    ))
  });
}
```

- **TSX**

	A much easier approach for building a game scene in Dora SSR. Take the tutorials [here](https://dora-ssr.net/blog/2024/4/25/tsx-dev-intro).

```tsx
import {React, toNode, toAction, useRef} from 'DoraX';
import {Ease, Sprite, once, sleep} from 'Dora';

const sprite = useRef<Sprite.Type>();

const onUpdate = once(() => {
  for (let i of $range(3, 1, -1)) {
    print(i);
    sleep(1);
  }
  print("Hello World");
  sprite.current?.perform(toAction(
    <sequence>
      <scale time={0.1} start={1} stop={0.5}/>
      <scale time={0.5} start={0.5} stop={1} easing={Ease.OutBack}/>
    </sequence>
  ));
});

toNode(
  <sprite
    ref={sprite}
    file='Image/logo.png'
    onUpdate={onUpdate}
  />
);
```

- **Rust**

	You can write code in Rust, build it into WASM file named `init.wasm`, upload it to engine to run. View details [here](https://dora-ssr.net/blog/2024/4/15/rusty-game-dev).

```rust
use dora_ssr::*;

fn main () {
  let mut sprite = match Sprite::with_file("Image/logo.png") {
    Some(sprite) => sprite,
    None => return,
  };
  let mut sprite_clone = sprite.clone();
  sprite.schedule(once(move |mut co| async move {
    for i in (1..=3).rev() {
      p!("{}", i);
      sleep!(co, 1.0);
    }
    p!("Hello World");
    sprite_clone.perform_def(ActionDef::sequence(&vec![
      ActionDef::scale(0.1, 1.0, 0.5, EaseType::Linear),
      ActionDef::scale(0.5, 0.5, 1.0, EaseType::OutBack),
    ]));
  }));
}
```

- Step Three: Run the game

	Click the `🎮` icon in the lower right corner of the editor, then click the menu item `Run`. Or press the key combination `Ctrl + r`.

- Step Four: Publish the game
	- Open the right-click menu of the project folder just created through the game resource tree on the left side of the editor and click the `Download` option.
	- Wait for the browser to pop up a download prompt for the packaged project file.

For more detailed tutorials, please check [official documents](https://Dora-ssr.net/docs/tutorial/quick-start).

<br>

## Documentation

- [API Reference](https://Dora-ssr.net/docs/api/intro)
- [Tutorial](https://Dora-ssr.net/docs/tutorial/quick-start)

<br>

## Community

- [Discord](https://discord.gg/ZfNBSKXnf9)
- [QQ Group: 512620381](https://qm.qq.com/cgi-bin/qm/qr?k=7siAhjlLaSMGLHIbNctO-9AJQ0bn0G7i&jump_from=webapi&authKey=Kb6tXlvcJ2LgyTzHQzKwkMxdsQ7sjERXMJ3g10t6b+716pdKClnXqC9bAfrFUEWa)

<br>

## Contribute

Welcome to participate in the development and maintenance of Dora SSR. Please see [Contributing Guidelines](CONTRIBUTING.md) to learn how to submit Issues and Pull Requests.

<br>

## Dora SSR Joins the Open Atom Foundation

We are delighted to announce that the Dora SSR project has officially become a donation and incubation project under the Open Atom Foundation. This new stage of development signifies our steadfast commitment to building a more open and collaborative gaming development environment.

### About the Open Atom Foundation

The Open Atom Foundation is a non-profit organization dedicated to supporting and promoting the development of open-source technologies. Within this foundation's community, Dora SSR will utilize broader resources and community support to propel the project's development and innovation. For more information, please visit the [foundation's official website](https://openatom.org/).

<div align='center'><img src='Docs/static/img/cheer.png' alt='Playground' width='500px'/></div>

<br>

## License

Dora SSR uses the [MIT License](LICENSE).

> [!NOTE]
> Please note that Dora SSR integrates the Spine Runtime library, which is a **commercial software**. The use of Spine Runtime in your projects requires a valid commercial license from Esoteric Software. For more details on obtaining the license, please visit the [official Spine website](http://esotericsoftware.com/).<br>
> Make sure to comply with all licensing requirements when using Spine Runtime in your projects. Alternatively, you can use the integrated open-source **DragonBones** system as an animation system replacement. If you only need to create simpler animations, you may also explore the Model animation module provided by Dora SSR to see if it meets your needs.