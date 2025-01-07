<div align="center"><img src='Assets/Image/logo.png' alt='Dora SSR' width='200px'/></div>

# 多萝珍奇引擎（Dora SSR）

#### [English](README.md)  | 中文

&emsp;&emsp;Dora SSR 是一个用于多种设备上快速开发游戏的游戏引擎。它内置易用的 Web IDE 开发工具链，支持在手机、开源掌机等设备上直接进行游戏开发。

| 类别 | 徽章 |
| - | - |
| 提供游戏开发工具 | ![Static Badge](https://img.shields.io/badge/C%2B%2B20-Game_Engine-d5a64c?logo=c%2B%2B) ![Static Badge](https://img.shields.io/badge/ReactJS-Web_IDE-00d8ff?logo=react) |
| 支持编程语言 | ![Static Badge](https://img.shields.io/badge/Rust-WASM-e36f39?logo=rust) ![Static Badge](https://img.shields.io/badge/Wa-WASM-e36f39?logo=data%3Aimage%2Fsvg%2Bxml%3Bcharset%3Dutf-8%3Bbase64%2CPHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjMwMCIgdmlld0JveD0iMCAwIDMwMCAzMDAiIGZpbGw9Im5vbmUiCiAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cGF0aCBmaWxsLXJ1bGU9ImV2ZW5vZGQiIGNsaXAtcnVsZT0iZXZlbm9kZCIgZD0iTTAgMjBDMCA4Ljk1NDMgOC45NTQzIDAgMjAgMEg4MEM5MS4wNDYgMCAxMDAgOC45NTQzIDEwMCAyMFYyNFY4MFYxMDBIMjAwVjgwVjI0VjIwQzIwMCA4Ljk1NDMgMjA4Ljk1NCAwIDIyMCAwSDI4MEMyOTEuMDQ2IDAgMzAwIDguOTU0MyAzMDAgMjBWNDRWODBWMjgwQzMwMCAyOTEuMDQ2IDI5MS4wNDYgMzAwIDI4MCAzMDBIMjBDOC45NTQzIDMwMCAwIDI5MS4wNDYgMCAyODBWODBWNDRWMjBaIiBmaWxsPSIjMDBCNUFCIi8%2BCiAgPHBhdGggZD0iTTUwIDU1QzUyLjc2MTQgNTUgNTUgNTIuNzYxNCA1NSA1MEM1NSA0Ny4yMzg2IDUyLjc2MTQgNDUgNTAgNDVDNDcuMjM4NiA0NSA0NSA0Ny4yMzg2IDQ1IDUwQzQ1IDUyLjc2MTQgNDcuMjM4NiA1NSA1MCA1NVoiIGZpbGw9IndoaXRlIi8%2BCiAgPHBhdGggZD0iTTI1MCA1NUMyNTIuNzYxIDU1IDI1NSA1Mi43NjE0IDI1NSA1MEMyNTUgNDcuMjM4NiAyNTIuNzYxIDQ1IDI1MCA0NUMyNDcuMjM5IDQ1IDI0NSA0Ny4yMzg2IDI0NSA1MEMyNDUgNTIuNzYxNCAyNDcuMjM5IDU1IDI1MCA1NVoiIGZpbGw9IndoaXRlIi8%2BCiAgPHBhdGggZD0iTTE1MCAxODBMMTg0IDIxNEwyMTggMTgwTTE1MCAxODBMMTE2IDIxNEw4MiAxODAiIGZpbGw9Im5vbmUiIHN0cm9rZT0id2hpdGUiIHN0cm9rZS13aWR0aD0iOCIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIi8%2BCjwvc3ZnPgo%3D) ![Static Badge](https://img.shields.io/badge/Lua-Scripting-blue?logo=lua) ![Static Badge](https://img.shields.io/badge/TypeScript-Script-blue?logo=typescript) ![Static Badge](https://img.shields.io/badge/TSX-Scripting-blue?logo=typescript) ![Static Badge](https://img.shields.io/badge/Teal-Scripting-blue) ![Static Badge](https://img.shields.io/badge/YueScript-Script-blue?logo=data%3Aimage%2Fsvg%2Bxml%3Bcharset%3Dutf-8%3Bbase64%2CPD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8%2BCjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI%2BCjxzdmcgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDM3OCAzMjYiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSIgeG1sbnM6c2VyaWY9Imh0dHA6Ly93d3cuc2VyaWYuY29tLyIgc3R5bGU9ImZpbGwtcnVsZTpldmVub2RkO2NsaXAtcnVsZTpldmVub2RkO3N0cm9rZS1saW5lam9pbjpyb3VuZDtzdHJva2UtbWl0ZXJsaW1pdDoyOyI%2BCiAgICA8ZyB0cmFuc2Zvcm09Im1hdHJpeCgxLDAsMCwxLC0yOTguNCwtNTguMykiPgogICAgICAgIDxnPgogICAgICAgICAgICA8cGF0aCBkPSJNNDE2LjgsMzIyLjVDNDEzLjEsMzIzLjMgNDA4LjcsMzI0LjEgNDA1LjEsMzI0LjhDNDA1LjYsMzIyLjggNDA3LDMxNyA0MDgsMzEzLjNMNDA1LjIsMzEwLjRMNDAxLjksMzI0LjlDNDAxLjksMzI1LjEgNDAxLjgsMzI1LjMgNDAxLjYsMzI1LjVMMzk1LjYsMzMxLjJMMzk4LDMzMy44TDQwNC4xLDMyOEM0MDQuMywzMjcuOCA0MDQuNCwzMjcuNyA0MDQuNiwzMjcuN0w0MTkuMywzMjUuMkw0MTYuOCwzMjIuNVoiIHN0eWxlPSJmaWxsOnJnYigxODAsMTcyLDE0Myk7ZmlsbC1ydWxlOm5vbnplcm87Ii8%2BCiAgICAgICAgICAgIDxwYXRoIGQ9Ik00MzIuNCwzNTEuN0M0MzAuNSwzNTQuNCA0MjguMiwzNTUuNiA0MjQuNiwzNTMuMkM0MjEsMzUwLjcgNDIxLjIsMzQ4IDQyMywzNDUuNEw0MzAuNywzMzQuMkw0MjcuOCwzMzIuMkw0MjAsMzQzLjZDNDE3LjIsMzQ3LjYgNDE3LjcsMzUxLjUgNDIzLjIsMzU1LjNDNDI5LjEsMzU5LjMgNDMyLjksMzU3LjcgNDM1LjQsMzU0TDQ0My4xLDM0Mi43TDQ0MC4xLDM0MC43TDQzMi40LDM1MS43WiIgc3R5bGU9ImZpbGw6cmdiKDE4MCwxNzIsMTQzKTtmaWxsLXJ1bGU6bm9uemVybzsiLz4KICAgICAgICAgICAgPHBhdGggZD0iTTQ0OC4xLDM2OS4xTDQ2Mi41LDM3NC44TDQ2My45LDM3Mi43TDQ1Mi4zLDM2OEw0NTUsMzYxLjJMNDY1LjYsMzY1LjRMNDY2LjUsMzYzTDQ1NiwzNTguOEw0NTguNCwzNTIuOUw0NjkuNCwzNTcuM0w0NzAuMywzNTVMNDU2LjEsMzQ5LjNMNDQ4LjEsMzY5LjFaIiBzdHlsZT0iZmlsbDpyZ2IoMTgwLDE3MiwxNDMpO2ZpbGwtcnVsZTpub256ZXJvOyIvPgogICAgICAgICAgICA8cGF0aCBkPSJNNDkwLjYsMzU5LjZDNDg1LjksMzU4LjggNDgyLjQsMzYwLjQgNDgxLjgsMzYzLjhDNDgxLjMsMzY2LjggNDgzLDM2OC43IDQ4OC4xLDM3MUM0OTIuMSwzNzIuOCA0OTMuMywzNzQgNDkyLjksMzc2LjNDNDkyLjUsMzc4LjUgNDkwLjUsMzc5LjQgNDg3LjUsMzc4LjlDNDg0LjYsMzc4LjQgNDgyLjgsMzc2LjcgNDgyLjcsMzc0LjFMNDc5LjIsMzczLjVDNDc4LjksMzc3LjQgNDgxLjYsMzgwLjMgNDg2LjgsMzgxLjNDNDkyLjUsMzgyLjMgNDk1LjgsMzgwLjIgNDk2LjQsMzc2LjdDNDk2LjksMzczLjggNDk1LjcsMzcxLjUgNDg5LjgsMzY4LjhDNDg2LjEsMzY3LjEgNDg0LjksMzY2LjIgNDg1LjIsMzY0LjNDNDg1LjUsMzYyLjUgNDg3LjEsMzYxLjYgNDg5LjksMzYyLjFDNDkyLjksMzYyLjYgNDk0LDM2NC4yIDQ5NCwzNjYuM0w0OTcuNCwzNjYuOUM0OTgsMzYzLjYgNDk2LjEsMzYwLjYgNDkwLjYsMzU5LjZaIiBzdHlsZT0iZmlsbDpyZ2IoMTgwLDE3MiwxNDMpO2ZpbGwtcnVsZTpub256ZXJvOyIvPgogICAgICAgICAgICA8cGF0aCBkPSJNNTIyLjMsMzgxLjFDNTE3LjEsMzgxLjMgNTE1LjMsMzc3LjEgNTE1LjIsMzcyLjdDNTE1LDM2OC4zIDUxNi44LDM2NC4zIDUyMS42LDM2NC4xQzUyNS4zLDM2NCA1MjYuOCwzNjUuNyA1MjcuNSwzNjhMNTMxLDM2Ny45QzUzMC40LDM2NC40IDUyNy42LDM2MS40IDUyMS42LDM2MS42QzUxNC40LDM2MS45IDUxMS4zLDM2Ny4xIDUxMS41LDM3Mi44QzUxMS43LDM3OS4xIDUxNC43LDM4My44IDUyMi4zLDM4My41QzUyOC40LDM4My4zIDUzMC45LDM4MCA1MzEuNSwzNzYuNUw1MjgsMzc2LjZDNTI3LjQsMzc5IDUyNiwzODEgNTIyLjMsMzgxLjFaIiBzdHlsZT0iZmlsbDpyZ2IoMTgwLDE3MiwxNDMpO2ZpbGwtcnVsZTpub256ZXJvOyIvPgogICAgICAgICAgICA8cGF0aCBkPSJNNTYzLjcsMzcwLjdDNTYzLDM2Ny45IDU2MS41LDM2Ni41IDU1OC44LDM2Ni41QzU2MC42LDM2NS40IDU2Mi4zLDM2My42IDU2MS41LDM2MC42QzU2MC42LDM1Ny4xIDU1NywzNTYgNTUyLjYsMzU3LjJMNTQzLjcsMzU5LjVMNTQ5LDM4MC4xTDU1Mi40LDM3OS4yTDU1MCwzNzBMNTU0LjEsMzY4LjlDNTU4LDM2Ny45IDU1OS41LDM2OC43IDU2MC4yLDM3MS41TDU2MC4zLDM3MS45QzU2MC45LDM3NC4xIDU2MS40LDM3NS45IDU2MiwzNzYuN0w1NjUuNCwzNzUuOEM1NjQuOCwzNzQuNyA1NjQuMywzNzIuOSA1NjMuOCwzNzFMNTYzLjcsMzcwLjdaTTU1My44LDM2Ni41TDU0OS40LDM2Ny42TDU0Ny43LDM2MC45TDU1Mi44LDM1OS42QzU1NS42LDM1OC45IDU1Ny42LDM1OS41IDU1OC4xLDM2MS42QzU1OC44LDM2NC41IDU1Ni44LDM2NS44IDU1My44LDM2Ni41WiIgc3R5bGU9ImZpbGw6cmdiKDE4MCwxNzIsMTQzKTtmaWxsLXJ1bGU6bm9uemVybzsiLz4KICAgICAgICAgICAgPGcgdHJhbnNmb3JtPSJtYXRyaXgoMC45MTA1LC0wLjQxMzYsMC40MTM2LDAuOTEwNSwtOTYuMTEyNSwyNzIuNzE3KSI%2BCiAgICAgICAgICAgICAgICA8cmVjdCB4PSI1NzcuNCIgeT0iMzQ4LjMiIHdpZHRoPSIzLjUiIGhlaWdodD0iMjEuMyIgc3R5bGU9ImZpbGw6cmdiKDE4MCwxNzIsMTQzKTsiLz4KICAgICAgICAgICAgPC9nPgogICAgICAgICAgICA8cGF0aCBkPSJNNTk3LDMzNi42TDU4OS44LDM0MS41TDYwMS44LDM1OS4xTDYwNC43LDM1Ny4xTDU5OS42LDM0OS43TDYwMy41LDM0N0M2MDcuOCwzNDQuMSA2MDkuNiwzNDAuMyA2MDcuMiwzMzYuOEM2MDUuMSwzMzMuNiA2MDAuOSwzMzMuOSA1OTcsMzM2LjZaTTYwMi4xLDM0NS4xTDU5OC40LDM0Ny43TDU5NC4yLDM0MS41TDU5OCwzMzguOUM2MDAuNiwzMzcuMSA2MDMsMzM2LjkgNjA0LjQsMzM4LjlDNjA2LDM0MS4zIDYwNC43LDM0My4zIDYwMi4xLDM0NS4xWiIgc3R5bGU9ImZpbGw6cmdiKDE4MCwxNzIsMTQzKTtmaWxsLXJ1bGU6bm9uemVybzsiLz4KICAgICAgICAgICAgPHBhdGggZD0iTTYyNi42LDMxMy40TDYyNC43LDMxMS42TDYxMi4xLDMyNC44TDYxNCwzMjYuNUw2MTksMzIxLjJMNjMyLjYsMzM0LjJMNjM1LjEsMzMxLjZMNjIxLjUsMzE4LjdMNjI2LjYsMzEzLjRaIiBzdHlsZT0iZmlsbDpyZ2IoMTgwLDE3MiwxNDMpO2ZpbGwtcnVsZTpub256ZXJvOyIvPgogICAgICAgICAgICA8cGF0aCBkPSJNNTQxLjIsNjAuMkM1MzkuMSw1OS45IDUzNyw1OS42IDUzNC45LDU5LjNMNTM0LjksNzQuMkM1NTcuMyw5OC40IDU3MS44LDEzMC4xIDU3My45LDE2NS4xTDQzNS43LDE2NS4xQzQzNS43LDE2NS4xIDQyMS43LDE2NS44IDQyMS43LDE3Ny40QzQyMS43LDE4OS41IDQzMi44LDE5MS41IDQzNS42LDE5MS41TDUwNSwxOTEuNUM1MDUsMTkxLjUgNTEzLjcsMTkxIDUxMy43LDE5Ny42QzUxMy43LDIwMy45IDUwNy4zLDIwMy42IDUwNS4xLDIwMy42TDM2My42LDIwMy42QzM3NC42LDEyOS4zIDQzMi44LDcwLjQgNTA2LjcsNTguM0M0MjcsNjIuNSAzNjIuNSwxMjQuOCAzNTQuOCwyMDMuNkwzMTMuNywyMDMuNkMzMTMuNywyMDMuNiAyOTguNCwyMDEuOCAyOTguNCwyMTUuMUMyOTguNCwyMjguNCAzMDkuOSwyMjcuOSAzMTMuMSwyMjcuOUwzNTQuMiwyMjcuOUMzNTUuNywyNTYuMiAzNjQuNiwyODIuNyAzNzguOSwzMDUuM0wzNzksMzA1LjJDMzcwLjIsMjg3LjMgMzY0LjUsMjY3LjYgMzYyLjQsMjQ2LjhMNDM3LjcsMjQ2LjhDNDQxLjMsMjQ2LjggNDUxLjQsMjQ2LjMgNDUxLjQsMjM0LjZDNDUxLjQsMjIzIDQzOSwyMjIuNyA0MzksMjIyLjdMMzM3LjIsMjIyLjdDMzM3LjIsMjIyLjcgMzI4LjMsMjIzLjQgMzI4LjMsMjE2LjNDMzI4LjMsMjA5LjIgMzM0LjEsMjA4LjkgMzM2LjcsMjA4LjlMNTI3LjIsMjA4LjlDNTI3LjIsMjA4LjkgNTQxLjgsMjEwLjUgNTQxLjgsMTk3QzU0MS44LDE4NSA1MjksMTg1LjUgNTI0LjMsMTg1LjVMNDU5LjIsMTg1LjVDNDU5LjIsMTg1LjUgNDQ5LjUsMTg1LjkgNDQ5LjUsMTc4LjZDNDQ5LjUsMTcxLjMgNDU3LjcsMTcxLjcgNDU5LjEsMTcxLjdMNTczLjgsMTcxLjdMNTczLjgsMTczLjlDNTczLjgsMjEyLjQgNTU4LjksMjQ3LjUgNTM0LjUsMjczLjdDNTEyLjksMjk3IDQ4My44LDMxMy4zIDQ1MSwzMTguOEM0NTcuMywzMjIuNyA0NjMuOSwzMjYuMSA0NzAuOCwzMjlDNDk0LjcsMzIyLjIgNTE2LjQsMzEwIDUzNC40LDI5My44QzU0OS4xLDI4MC42IDU2MS40LDI2NC42IDU3MC41LDI0Ni44TDY0MS42LDI0Ni44TDY0MS42LDI0MC4xTDU3My43LDI0MC4xQzU4Mi44LDIxOS45IDU4Ny45LDE5Ny41IDU4Ny45LDE3My45TDU4Ny45LDE3MS43TDY1My44LDE3MS43QzY1OC45LDE4Ni42IDY2MS43LDIwMi41IDY2MS43LDIxOS4xQzY2MS43LDI0Ni42IDY1NC4xLDI3Mi40IDY0MC44LDI5NC41TDY1MiwzMDMuNkM2NjcuMiwyNzkgNjc2LDI1MC4xIDY3NiwyMTkuMUM2NzYuNCwxMzkuMiA2MTcuOCw3Mi42IDU0MS4yLDYwLjJaTTQyMy45LDIzNS4zQzQyMy45LDI0MS44IDQxNy42LDI0Mi4yIDQxNy42LDI0Mi4yTDM2Mi4yLDI0Mi4yQzM2MS45LDIzNy45IDM2MS43LDIzMy42IDM2MS43LDIyOS4zTDM2MS43LDIyNy45TDQxOC4yLDIyNy45QzQxOS4yLDIyOCA0MjMuOSwyMjguOCA0MjMuOSwyMzUuM1pNNTg4LjIsMTY1LjFDNTg2LjQsMTMyLjcgNTc1LjEsMTAyLjkgNTU2LjksNzguNEM2MDAuMiw5MS4yIDYzNS4zLDEyMy41IDY1MS45LDE2NS4xTDU4OC4yLDE2NS4xWiIgc3R5bGU9ImZpbGw6cmdiKDE4MCwxNzIsMTQzKTtmaWxsLXJ1bGU6bm9uemVybzsiLz4KICAgICAgICA8L2c%2BCiAgICA8L2c%2BCjwvc3ZnPgo%3D) |
| 支持运行平台 | ![Android](https://github.com/ippclub/Dora-SSR/actions/workflows/android.yml/badge.svg) ![Linux](https://github.com/ippclub/Dora-SSR/actions/workflows/linux.yml/badge.svg) ![Windows](https://github.com/ippclub/Dora-SSR/actions/workflows/windows.yml/badge.svg) ![macOS](https://github.com/ippclub/Dora-SSR/actions/workflows/macos.yml/badge.svg) ![iOS](https://github.com/ippclub/Dora-SSR/actions/workflows/ios.yml/badge.svg) |

<div align='center'><img src='Docs/static/img/3.png' alt='Playground' width='500px'/></div>

## 目录

- [主要特点](#主要特点)
- [示例项目](#示例项目)
- [安装配置](#安装配置)
	- [Android](#android)
	- [Windows](#windows)
	- [macOS](#macos)
	- [Linux](#linux)
- [快速上手](#快速上手)
- [文档](#文档)
- [社区](#社区)
- [贡献](#贡献)
- [许可证](#许可证)

<br>

## 主要特点

|功能|描述|
|-|-|
|跨平台支持|支持原生运行的架构：<br>**Android** (x86_64, armv7, arm64)<br>**Windows** (x86)<br>**Linux** (x86_64, arm64)<br>**iOS** (arm64)<br>**macOS** (x86_64, arm64)|
|树形节点|基于树形节点结构管理游戏场景。|
|ECS|易用的 [ECS](https://dora-ssr.net/zh-Hans/docs/tutorial/using-ecs) 模块，便于游戏实体管理。|
|异步处理|异步处理的文件读写、资源加载等操作。|
|Lua|升级的 Lua 绑定，支持继承和扩展底层 C++ 对象。|
|YueScript|支持 [YueScript](https://yuescript.org) 语言，强表达力且简洁的 Lua 方言。|
|Teal|支持 [Teal](https://github.com/teal-language/tl) 语言，编译到 Lua 的静态类型语言。|
|TypeScript|支持 [TypeScript](https://www.typescriptlang.org) 语言，一门静态类型的 JavaScript 语言的超集，添加了强大的类型检查功能。（通过 [TSTL](https://typescripttolua.github.io)）|
|TSX|支持 [TSX](https://dora-ssr.net/zh-Hans/docs/tutorial/Language%20Tutorial/using-tsx)，允许在脚本中嵌入类似 XML/HTML 的文本，与 TypeScript 一起使用。|
|Rust|支持 [Rust](https://www.rust-lang.org) 语言，运行在内置的 WASM 运行时和 [Rust 绑定](https://lib.rs/crates/dora-ssr)上。|
|Wa|支持 [Wa](https://wa-lang.org) 语言，一门简单可靠、静态类型的语言，运行在内置的 WASM 运行时和 [Wa 绑定](https://github.com/IppClub/Dora-SSR/tree/main/Tools/dora-wa) 上。|
|2D 骨骼动画|支持 2D 骨骼动画，包括：[Spine2D](https://github.com/EsotericSoftware/spine-runtimes)、[DragonBones](https://github.com/DragonBones/DragonBonesCPP) 以及内置系统。|
|2D 物理引擎|支持 2D 物理引擎，使用 [PlayRho](https://github.com/louis-langholtz/PlayRho)。|
|Web IDE|内置开箱即用的 Web IDE，提供文件管理，代码检查、补全、高亮和定义跳转。 <br><br><div align='center'><img src='Docs/static/img/dora-on-android.jpg' alt='LSD' width='500px'/></div>|
|数据库|支持异步操作 [SQLite](https://www.sqlite.org)，进行大量游戏配置数据的实时查询和写入。|
|Excel|支持 Excel 表格数据读取，支持同步到 SQLite 库表。|
|CSS 布局|提供游戏场景通过 CSS 进行自适应的 Flex 布局的功能（通过 [Yoga](https://github.com/facebook/yoga)）。|
|特效系统|支持 [Effekseer](https://effekseer.github.io/en) 特效系统的功能。|
|瓦片地图|支持 [Tiled Map Editor](http://www.mapeditor.org) 制作的 TMX 地图文件的解析和渲染。|
|Yarn Spinner|支持 [Yarn Spinner](https://www.yarnspinner.dev) 语言，便于编写复杂的游戏故事系统。|
|机器学习|内置用于创新游戏玩法的机器学习算法框架。|
|矢量图形|提供矢量图形渲染 API，可直接渲染无 CSS 的 SVG 格式文件（通过 [NanoVG](https://github.com/memononen/nanovg)）。|
|ImGui|内置 [ImGui](https://github.com/ocornut/imgui)，便于创建调试工具和 UI 界面。|
|音频|支持 FLAC、OGG、MP3 和 WAV 多格式音频播放。|
|True Type|支持 True Type 字体的渲染和基础排版。|
|2D 平台游戏|支持 [2D 平台游戏](https://dora-ssr.net/zh-Hans/docs/example/Platformer%20Tutorial/start) 的基本功能，包括游戏逻辑和 AI 开发框架。|
|L·S·D|提供可用于制作自己游戏的开放美术素材和游戏 IP —— [《灵数奇缘》](https://luv-sense-digital.readthedocs.io)。<br><br><div align='center'><img src='Docs/static/img/LSD.jpg' alt='LSD' width='400px'/></div>|

<br>

## 示例项目

- [示例项目 - Loli War](Assets/Script/Game/Loli%20War)

<div align='center'><img src='Docs/static/img/LoliWar.gif' alt='Loli War' width='400px'/></div>

<br>

- [示例项目 - Zombie Escape](Assets/Script/Game/Zombie%20Escape)

<div align='center'><img src='Docs/static/img/ZombieEscape.png' alt='Zombie Escape' width='800px'/></div>

<br>

- [示例项目 - Dismentalism](Assets/Script/Game/Dismantlism)

<div align='center'><img src='Docs/static/img/Dismentalism.png' alt='Dismentalism' width='800px'/></div>

<br>

- [示例项目 - Luv Sense Digital](https://github.com/IppClub/LSD)

<div align='center'><img src='Docs/static/img/LuvSenseDigital.png' alt='Luv Sense Digital' width='800px'/></div>

<br>

## 安装配置

### Android

- 1、在游戏的运行终端下载并安装 [APK](https://github.com/ippclub/Dora-SSR/releases/latest) 包。
- 2、运行软件，通过局域网内的 PC（平板或其他开发设备）的浏览器访问软件显示的服务器地址。
- 3、开始游戏开发。

### Windows

- 1、请确保您已安装 Visual Studio 2022 的 X86 Visual C++ 可再发行组件包（包含 MSVC 编译的程序所需运行时的 vc_redist.x86 补丁），以运行此应用程序。您可以从[微软网站](https://learn.microsoft.com/zh-cn/cpp/windows/latest-supported-vc-redist?view=msvc-170)下载。
- 2、下载并解压[软件](https://github.com/ippclub/Dora-SSR/releases/latest)。
- 3、运行软件，通过浏览器访问软件显示的服务器地址。
- 4、开始游戏开发。

### macOS

- 1、下载并解压[软件](https://github.com/ippclub/Dora-SSR/releases/latest)。或者也可以通过 [Homebrew](https://brew.sh) 使用下面命令进行软件安装。
	```sh
	brew install --cask ippclub/tap/dora-ssr
	```
- 2、运行软件，通过浏览器访问软件显示的服务器地址。
- 3、开始游戏开发。

### Linux

- 1、安装软件：
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
- 2、运行软件，通过浏览器访问软件显示的服务器地址。
- 3、开始游戏开发。

### 编译构建引擎

- 要自行编译构建 Dora SSR 项目，详见[官方文档](https://dora-ssr.net/zh-Hans/docs/tutorial/dev-configuration)。

<br>

## 快速上手

- 第一步：创建一个新项目
	- 在浏览器中，打开 Dora Dora 编辑器左侧游戏资源树的右键菜单。
	- 点击菜单项 `新建`，选择新建文件夹。

- 第二步：编写游戏代码
	- 在项目文件夹下新建游戏入口代码文件，选择 Lua  (YueScript, Teal, TypeScript 或 TSX) 语言命名为 `init`。
	- 编写 Hello World 代码：

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

- **Yuescript**

&emsp;&emsp;有关 Dora SSR 所支持的 Yuescript 这门小众语言的故事在[这里](https://dora-ssr.net/zh-Hans/blog/2024/4/17/a-moon-script-tale)。
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

&emsp;&emsp;使用 TSX 语言来创建 Dora SSR 的游戏场景是一个比较容易上手的选择。新手教程可以参见[这里](https://dora-ssr.net/zh-Hans/blog/2024/4/25/tsx-dev-intro)。

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

&emsp;&emsp;Dora SSR 也支持使用 Rust 语言来编写游戏代码，编译为 WASM 文件，命名为 `init.wasm` 再上传到引擎中加载运行。详情见[这里](https://dora-ssr.net/zh-Hans/blog/2024/4/15/rusty-game-dev)。

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

- 第三步：运行游戏

&emsp;&emsp;点击编辑器右下角 `🎮` 图标，然后点击菜单项 `运行`。或者按下组合键 `Ctrl + r`。

- 第四步：发布游戏
	- 通过编辑器左侧游戏资源树，打开刚才新建的项目文件夹的右键菜单，点击 `下载` 选项。
	- 等待浏览器弹出已打包项目文件的下载提示。

&emsp;&emsp;更详细的教程，请查看[官方文档](https://dora-ssr.net/zh-Hans/docs/tutorial/quick-start)。

<br>

## 文档

- [API参考](https://dora-ssr.net/zh-Hans/docs/api/intro)
- [教程](https://dora-ssr.net/zh-Hans/docs/tutorial/quick-start)

<br>

## 社区

- [QQ群：512620381](https://qm.qq.com/cgi-bin/qm/qr?k=7siAhjlLaSMGLHIbNctO-9AJQ0bn0G7i&jump_from=webapi&authKey=Kb6tXlvcJ2LgyTzHQzKwkMxdsQ7sjERXMJ3g10t6b+716pdKClnXqC9bAfrFUEWa)
- [Discord](https://discord.gg/ZfNBSKXnf9)

<br>

## 贡献

&emsp;&emsp;欢迎参与 Dora SSR 的开发和维护。请查看[贡献指南](CONTRIBUTING.zh-CN.md)了解如何提交 Issue 和 Pull Request。

<br>

## Dora SSR 项目现已加入开放原子开源基金会

&emsp;&emsp;我们很高兴地宣布，Dora SSR 项目现已成为开放原子开源基金会的捐赠和孵化期项目。这一新的发展阶段标志着我们致力于建设一个更开放、更协作的游戏开发环境的坚定承诺。

### 关于开放原子开源基金会

&emsp;&emsp;开放原子开源基金会（Open Atom Foundation）是一个非盈利组织，旨在支持和推广开源技术的发展。在该基金会的大家庭中，Dora SSR 会利用更广泛的资源和社区支持，以推动项目的发展和创新。更多信息请查看[基金会官网](https://openatom.org/)。

<div align='center'><img src='Docs/static/img/cheer.png' alt='Cheer' width='500px'/></div>

<br>

## 许可证

&emsp;&emsp;Dora SSR 使用 [MIT 许可证](LICENSE)。

> [!NOTE]
> 请注意，Dora SSR 集成了 Spine 运行时库，这是一个**商业软件**。在你的项目中使用 Spine 运行时需要获取 Esoteric Software 提供有效的商业许可证。有关获取许可证的更多详细信息，请访问  [Spine 官方网站](http://esotericsoftware.com/)。<br>
> 请确保遵守所有许可要求，再在项目中使用 Spine 运行时。或者可以使用同样集成的开源的 **DragonBones** 系统作为动画系统的替代方案。如果你只需要创建比较简单的动画，也可以使用 Dora SSR 提供的 Model 动画模块看是否能满足需要。
