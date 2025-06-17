<div align="center"><img src='Docs/static/img/site/dora.svg' alt='Dora SSR' width='200px'/></div>

# Dora SSR (多萝珍奇引擎)

#### English | [中文](README.zh-CN.md)

[![IppClub](https://img.shields.io/badge/IppClub-Certified-11A7E2?logo=data%3Aimage%2Fsvg%2Bxml%3Bcharset%3Dutf-8%3Bbase64%2CPHN2ZyB2aWV3Qm94PSIwIDAgMjg4IDI3NCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWw6c3BhY2U9InByZXNlcnZlIiBzdHlsZT0iZmlsbC1ydWxlOmV2ZW5vZGQ7Y2xpcC1ydWxlOmV2ZW5vZGQ7c3Ryb2tlLWxpbmVqb2luOnJvdW5kO3N0cm9rZS1taXRlcmxpbWl0OjIiPjxwYXRoIGQ9Im0xNDYgMzEgNzIgNTVWMzFoLTcyWiIgc3R5bGU9ImZpbGw6I2Y2YTgwNjtmaWxsLXJ1bGU6bm9uemVybyIvPjxwYXRoIGQ9Im0xNjkgODYtMjMtNTUgNzIgNTVoLTQ5WiIgc3R5bGU9ImZpbGw6I2VmN2EwMDtmaWxsLXJ1bGU6bm9uemVybyIvPjxwYXRoIGQ9Ik0yNiAzMXY1NWg4MEw4MSAzMUgyNloiIHN0eWxlPSJmaWxsOiMwN2ExN2M7ZmlsbC1ydWxlOm5vbnplcm8iLz48cGF0aCBkPSJNMTA4IDkydjExMmwzMS00OC0zMS02NFoiIHN0eWxlPSJmaWxsOiNkZTAwNWQ7ZmlsbC1ydWxlOm5vbnplcm8iLz48cGF0aCBkPSJNMCAyNzR2LTUyaDk3bC0zMyA1MkgwWiIgc3R5bGU9ImZpbGw6I2Y2YTgwNjtmaWxsLXJ1bGU6bm9uemVybyIvPjxwYXRoIGQ9Im03NyAyNzQgNjctMTA3djEwN0g3N1oiIHN0eWxlPSJmaWxsOiNkZjI0MzM7ZmlsbC1ydWxlOm5vbnplcm8iLz48cGF0aCBkPSJNMTUyIDI3NGgyOWwtMjktNTN2NTNaIiBzdHlsZT0iZmlsbDojMzM0ODVkO2ZpbGwtcnVsZTpub256ZXJvIi8%2BPHBhdGggZD0iTTE5MSAyNzRoNzl2LTUySDE2N2wyNCA1MloiIHN0eWxlPSJmaWxsOiM0ZTI3NWE7ZmlsbC1ydWxlOm5vbnplcm8iLz48cGF0aCBkPSJNMjg4IDEwMGgtMTdWODVoLTEzdjE1aC0xN3YxM2gxN3YxNmgxM3YtMTZoMTd2LTEzWiIgc3R5bGU9ImZpbGw6I2M1MTgxZjtmaWxsLXJ1bGU6bm9uemVybyIvPjxwYXRoIGQ9Im0yNiA4NiA1Ni01NUgyNnY1NVoiIHN0eWxlPSJmaWxsOiMzMzQ4NWQ7ZmlsbC1ydWxlOm5vbnplcm8iLz48cGF0aCBkPSJNOTMgMzFoNDJsLTMwIDI5LTEyLTI5WiIgc3R5bGU9ImZpbGw6IzExYTdlMjtmaWxsLXJ1bGU6bm9uemVybyIvPjxwYXRoIGQ9Ik0xNTggMTc2Vjg2bC0zNCAxNCAzNCA3NloiIHN0eWxlPSJmaWxsOiMwMDU5OGU7ZmlsbC1ydWxlOm5vbnplcm8iLz48cGF0aCBkPSJtMTA2IDU5IDQxLTEtMTItMjgtMjkgMjlaIiBzdHlsZT0iZmlsbDojMDU3Y2I3O2ZpbGwtcnVsZTpub256ZXJvIi8%2BPHBhdGggZD0ibTEyNCAxMDAgMjItNDEgMTIgMjctMzQgMTRaIiBzdHlsZT0iZmlsbDojNGUyNzVhO2ZpbGwtcnVsZTpub256ZXJvIi8%2BPHBhdGggZD0ibTEwNiA2MCA0MS0xLTIzIDQxLTE4LTQwWiIgc3R5bGU9ImZpbGw6IzdiMTI4NTtmaWxsLXJ1bGU6bm9uemVybyIvPjxwYXRoIGQ9Im0xMDggMjA0IDMxLTQ4aC0zMXY0OFoiIHN0eWxlPSJmaWxsOiNiYTAwNzc7ZmlsbC1ydWxlOm5vbnplcm8iLz48cGF0aCBkPSJtNjUgMjc0IDMzLTUySDBsNjUgNTJaIiBzdHlsZT0iZmlsbDojZWY3YTAwO2ZpbGwtcnVsZTpub256ZXJvIi8%2BPHBhdGggZD0iTTc3IDI3NGg2N2wtNDAtNDUtMjcgNDVaIiBzdHlsZT0iZmlsbDojYTgxZTI0O2ZpbGwtcnVsZTpub256ZXJvIi8%2BPHBhdGggZD0iTTE2NyAyMjJoNThsLTM0IDUyLTI0LTUyWiIgc3R5bGU9ImZpbGw6IzExYTdlMjtmaWxsLXJ1bGU6bm9uemVybyIvPjxwYXRoIGQ9Im0yNzAgMjc0LTQ0LTUyLTM1IDUyaDc5WiIgc3R5bGU9ImZpbGw6IzA1N2NiNztmaWxsLXJ1bGU6bm9uemVybyIvPjxwYXRoIGQ9Ik0yNzUgNTVoLTU3VjBoMjV2MzFoMzJ2MjRaIiBzdHlsZT0iZmlsbDojZGUwMDVkO2ZpbGwtcnVsZTpub256ZXJvIi8%2BPHBhdGggZD0iTTE4NSAzMWg1N3Y1NWgtMjVWNTVoLTMyVjMxWiIgc3R5bGU9ImZpbGw6I2M1MTgxZjtmaWxsLXJ1bGU6bm9uemVybyIvPjwvc3ZnPg%3D%3D&labelColor=fff)](https://ippclub.org) [![Static Badge](https://img.shields.io/badge/Open_Atom_Foundation-Incubation-blue)](https://openatom.org/project/RJHufNnSKtDZ) [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/IppClub/Dora-SSR)

Dora SSR is a game engine for rapid development of games on various devices. It has a built-in easy-to-use Web IDE development tool chain that supports direct game development on mobile phones, open source handhelds and other devices.

<div align='center'><img src='Docs/static/img/article/detail.svg' alt='intro' width='700px'/></div>

<br/>

| Category | Badges |
| - | - |
| Provided Game Dev Tools | ![Static Badge](https://img.shields.io/badge/C%2B%2B20-Game_Engine-d5a64c?logo=c%2B%2B)<br>![Static Badge](https://img.shields.io/badge/Rust-Game_Engine-d5a64c?logo=rust)<br>![Static Badge](https://img.shields.io/badge/ReactJS-Web_IDE-00d8ff?logo=react) |
| Supported Languages | ![Static Badge](https://img.shields.io/badge/Lua-Script-blue?logo=lua)<br>![Static Badge](https://img.shields.io/badge/TypeScript-Script-blue?logo=typescript)<br>![Static Badge](https://img.shields.io/badge/TSX-Script-blue?logo=typescript)<br>![Static Badge](https://img.shields.io/badge/Teal-Script-blue?logo=data:image/svg+xml;charset=utf-8;base64,PHN2ZyB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDUxMiA1MTIiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgPGRlZnM+CiAgICA8bGluZWFyR3JhZGllbnQgaWQ9ImdyYWQiIHgxPSIwJSIgeTE9IjEwMCUiIHgyPSIxMDAlIiB5Mj0iMCUiPgogICAgICA8c3RvcCBvZmZzZXQ9IjAlIiBzdG9wLWNvbG9yPSIjMDA4MDgwIiAvPgogICAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiMwMGQ0ZDQiIC8+CiAgICA8L2xpbmVhckdyYWRpZW50PgogIDwvZGVmcz4KICA8cGF0aAogICAgZmlsbD0idXJsKCNncmFkKSIKICAgIGQ9IgogICAgICBNIDI1NiwwCiAgICAgIEEgMjU2LDI1NiAwIDEsMSAyNTUuOSwwCiAgICAgIFoKICAgICAgTSAyNTAsMTEwCiAgICAgIGggMTQwCiAgICAgIHYgMTQwCiAgICAgIGggLTE0MAogICAgICBaCiAgICAiCiAgICBmaWxsLXJ1bGU9ImV2ZW5vZGQiCiAgLz4KPC9zdmc+Cg==)<br>![Static Badge](https://img.shields.io/badge/YueScript-Script-blue?logo=data:image/svg+xml;charset=utf-8;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PCFET0NUWVBFIHN2ZyBQVUJMSUMgIi0vL1czQy8vRFREIFNWRyAxLjEvL0VOIiAiaHR0cDovL3d3dy53My5vcmcvR3JhcGhpY3MvU1ZHLzEuMS9EVEQvc3ZnMTEuZHRkIj48c3ZnIHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIHZpZXdCb3g9IjAgMCAxMjUxIDg5NyIgdmVyc2lvbj0iMS4xIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB4bWw6c3BhY2U9InByZXNlcnZlIiB4bWxuczpzZXJpZj0iaHR0cDovL3d3dy5zZXJpZi5jb20vIiBzdHlsZT0iZmlsbC1ydWxlOmV2ZW5vZGQ7Y2xpcC1ydWxlOmV2ZW5vZGQ7c3Ryb2tlLWxpbmVqb2luOnJvdW5kO3N0cm9rZS1taXRlcmxpbWl0OjI7Ij48cGF0aCBkPSJNODA0LjM3LDYuMjljLTYuOTYsLTAuOTkgLTEzLjkxLC0xLjk5IC0yMC44NywtMi45OGwwLDQ5LjM2Yzc0LjIxLDgwLjE3IDEyMi4yNSwxODUuMTkgMTI5LjIsMzAxLjE0bC00NTcuODQsMGMwLDAgLTQ2LjM4LDIuMzIgLTQ2LjM4LDQwLjc1YzAsMzguNDMgMzYuNzcsNDYuNzEgNDYuMDUsNDYuNzFsMjI5LjkxLDBjMCwwIDI4LjgyLC0xLjY2IDI4LjgyLDIwLjIxYy0wLDIxLjg3IC0yMS4yLDE5Ljg4IC0yOC40OSwxOS44OGwtNDY4Ljc3LDBjMzYuNDUsLTI0Ni4xNSAyMjkuMjYsLTQ0MS4yNyA0NzQuMDgsLTQ4MS4zNmMtMjY0LjA0LDEzLjkxIC00NzcuNzIsMjIwLjMxIC01MDMuMjMsNDgxLjM2bC0xMzYuMTYsMGMtMCwwIC01MC42OSwtNS45NiAtNTAuNjksMzguMWMtMCw0NC4wNiAzOC4xLDQyLjQgNDguNyw0Mi40bDEzNi4xNiwwYzQuOTcsOTMuNzUgMzQuNDUsMTgxLjU1IDgxLjgzLDI1Ni40MmwwLjMzLC0wLjMzYy0yOS4xNSwtNTkuMyAtNDguMDQsLTEyNC41NiAtNTQuOTksLTE5My40N2wyNDkuNDYsMGMxMS45MywwIDQ1LjM5LC0xLjY2IDQ1LjM5LC00MC40MmMtMCwtMzguNzYgLTQxLjA4LC0zOS40MiAtNDEuMDgsLTM5LjQybC0zMzcuMjYsMGMtMCwwIC0yOS40OCwyLjMyIC0yOS40OCwtMjEuMmMtMCwtMjMuNTIgMTkuMjEsLTI0LjUyIDI3LjgzLC0yNC41Mmw2MzEuMSwwYy0wLDAgNDguMzcsNS4zIDQ4LjM3LC0zOS40MmMtMCwtMzkuNzUgLTQyLjQsLTM4LjEgLTU3Ljk4LC0zOC4xbC0yMTUuNjcsMGMtMCwwIC0zMi4xMywxLjMzIC0zMi4xMywtMjIuODZjLTAsLTI0LjE5IDI3LjE3LC0yMi44NiAzMS44LC0yMi44NmwzNzkuOTksMGwtMCw3LjI5Yy0wLDEyNy41NSAtNDkuMzYsMjQzLjgzIC0xMzAuMiwzMzAuNjNjLTcxLjU2LDc3LjE5IC0xNjcuOTYsMTMxLjE5IC0yNzYuNjMsMTQ5LjQxYzIwLjg3LDEyLjkyIDQyLjc0LDI0LjE4IDY1LjYsMzMuNzljNzkuMTgsLTIyLjUzIDE1MS4wNywtNjIuOTQgMjEwLjcsLTExNi42MWM0OC43LC00My43MyA4OS40NSwtOTYuNzQgMTE5LjYsLTE1NS43MWwyMzUuNTUsMGwtMCwtMjIuMmwtMjI0Ljk0LDBjMzAuMTUsLTY2LjkyIDQ3LjA0LC0xNDEuMTMgNDcuMDQsLTIxOS4zMWwtMCwtNy4yOWwyMTguMzIsMGMxNi45LDQ5LjM2IDI2LjE3LDEwMi4wNCAyNi4xNywxNTcuMDNjLTAsOTEuMSAtMjUuMTgsMTc2LjU4IC02OS4yNCwyNDkuNzlsMzcuMSwzMC4xNWM1MC4zNiwtODEuNSA3OS41MSwtMTc3LjI0IDc5LjUxLC0yNzkuOTRjMS4zMywtMjY0LjcgLTE5Mi44MSwtNDg1LjM0IC00NDYuNTgsLTUyNi40MlptLTM4OC42LDU4MC4wOWMtMCwyMS41MyAtMjAuODcsMjIuODYgLTIwLjg3LDIyLjg2bC0xODMuNTMsMGMtMC45OSwtMTQuMjUgLTEuNjYsLTI4LjQ5IC0xLjY2LC00Mi43NGwtMCwtNC42NGwxODcuMTgsMGMzLjMxLDAuMzMgMTguODgsMi45OCAxOC44OCwyNC41MlptNTQ0LjMxLC0yMzIuNTZjLTUuOTYsLTEwNy4zNCAtNDMuNCwtMjA2LjA2IC0xMDMuNjksLTI4Ny4yM2MxNDMuNDUsNDIuNCAyNTkuNzMsMTQ5LjQxIDMxNC43MiwyODcuMjNsLTIxMS4wMywwWiIgc3R5bGU9ImZpbGw6I2I0YWM4ZjtmaWxsLXJ1bGU6bm9uemVybzsiLz48L3N2Zz4=)<br>![Static Badge](https://img.shields.io/badge/Blockly-Visual_Script-blue?logo=data:image/svg+xml;charset=utf-8;base64,PHN2ZyB3aWR0aD0iMTI5IiBoZWlnaHQ9IjE0NCIgdmlld0JveD0iMCAwIDEyOSAxNDQiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgPHBhdGggZD0iTTE2IDBINzJWMTQ0SDE2QzcuMTYzNDQgMTQ0IDAgMTM2LjgzNyAwIDEyOFYxNkMwIDcuMTYzNDQgNy4xNjM0NCAwIDE2IDBaIiBmaWxsPSIjNDI4NUY0Ii8+CiAgPHBhdGggZD0iTTcyIDBIMTEzQzEyMi45NDEgMCAxMjkgNy4wNTg4NyAxMjkgMTZWMTI4QzEyOSAxMzYuOTQxIDEyMi45NDEgMTQ0IDExMyAxNDRINzJWMFoiIGZpbGw9IiNDMUM5RDQiLz4KICA8cGF0aCBkPSJNNDUgNDBWMTA0QzQ1IDEwNiA0Ny41IDEwNy4yIDQ5LjUgMTA2TDgyLjUgODZDODQuNSA4NC44IDg0LjUgODEuMiA4Mi41IDgwTDQ5LjUgNjBDNDcuNSA1OC44IDQ1IDYwIDQ1IDYyVjQwWiIgZmlsbD0iI0MxQzlENCIvPgo8L3N2Zz4K)<br>![Static Badge](https://img.shields.io/badge/Wa-WASM-e36f39?logo=data%3Aimage%2Fsvg%2Bxml%3Bcharset%3Dutf-8%3Bbase64%2CPHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjMwMCIgdmlld0JveD0iMCAwIDMwMCAzMDAiIGZpbGw9Im5vbmUiCiAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cGF0aCBmaWxsLXJ1bGU9ImV2ZW5vZGQiIGNsaXAtcnVsZT0iZXZlbm9kZCIgZD0iTTAgMjBDMCA4Ljk1NDMgOC45NTQzIDAgMjAgMEg4MEM5MS4wNDYgMCAxMDAgOC45NTQzIDEwMCAyMFYyNFY4MFYxMDBIMjAwVjgwVjI0VjIwQzIwMCA4Ljk1NDMgMjA4Ljk1NCAwIDIyMCAwSDI4MEMyOTEuMDQ2IDAgMzAwIDguOTU0MyAzMDAgMjBWNDRWODBWMjgwQzMwMCAyOTEuMDQ2IDI5MS4wNDYgMzAwIDI4MCAzMDBIMjBDOC45NTQzIDMwMCAwIDI5MS4wNDYgMCAyODBWODBWNDRWMjBaIiBmaWxsPSIjMDBCNUFCIi8%2BCiAgPHBhdGggZD0iTTUwIDU1QzUyLjc2MTQgNTUgNTUgNTIuNzYxNCA1NSA1MEM1NSA0Ny4yMzg2IDUyLjc2MTQgNDUgNTAgNDVDNDcuMjM4NiA0NSA0NSA0Ny4yMzg2IDQ1IDUwQzQ1IDUyLjc2MTQgNDcuMjM4NiA1NSA1MCA1NVoiIGZpbGw9IndoaXRlIi8%2BCiAgPHBhdGggZD0iTTI1MCA1NUMyNTIuNzYxIDU1IDI1NSA1Mi43NjE0IDI1NSA1MEMyNTUgNDcuMjM4NiAyNTIuNzYxIDQ1IDI1MCA0NUMyNDcuMjM5IDQ1IDI0NSA0Ny4yMzg2IDI0NSA1MEMyNDUgNTIuNzYxNCAyNDcuMjM5IDU1IDI1MCA1NVoiIGZpbGw9IndoaXRlIi8%2BCiAgPHBhdGggZD0iTTE1MCAxODBMMTg0IDIxNEwyMTggMTgwTTE1MCAxODBMMTE2IDIxNEw4MiAxODAiIGZpbGw9Im5vbmUiIHN0cm9rZT0id2hpdGUiIHN0cm9rZS13aWR0aD0iOCIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIi8%2BCjwvc3ZnPgo%3D)<br>![Static Badge](https://img.shields.io/badge/Rust-WASM-e36f39?logo=rust) |
| Supported Platforms | ![Android](https://github.com/ippclub/Dora-SSR/actions/workflows/android.yml/badge.svg)<br>![Linux](https://github.com/ippclub/Dora-SSR/actions/workflows/linux.yml/badge.svg)<br>![Windows](https://github.com/ippclub/Dora-SSR/actions/workflows/windows.yml/badge.svg)<br>![macOS](https://github.com/ippclub/Dora-SSR/actions/workflows/macos.yml/badge.svg)<br>![iOS](https://github.com/ippclub/Dora-SSR/actions/workflows/ios.yml/badge.svg) |

<div align='center'><img src='Docs/static/img/art/casual/3.png' alt='Playground' width='500px'/></div>

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
|Wa|Supports the [Wa](https://wa-lang.org) language, a simple, reliable, and statically typed language running on the built-in WASM runtime with [Wa bindings](https://github.com/IppClub/Dora-SSR/tree/main/Tools/dora-wa).|
|Rust|Supports the [Rust](https://www.rust-lang.org) language, running on the built-in WASM runtime with [Rust bindings](https://lib.rs/crates/dora-ssr).|
|Blockly|Supports a Scratch-like visual language, ideal for beginners to learn how to code.<br><br><div align='center'><img src='Docs/static/img/showcase/blockly.jpg' alt='Blockly' width='500px'/></div>|
|2D Animation|2D skeletal animations support with [Spine2D](https://github.com/EsotericSoftware/spine-runtimes), [DragonBones](https://github.com/DragonBones/DragonBonesCPP) and a builtin system.|
|2D Physics|2D physics engine support with [PlayRho](https://github.com/louis-langholtz/PlayRho).|
|Web IDE|Built-in out-of-the-box Web IDE, providing file management, code inspection, completion, highlighting and definition jump. <br><br><div align='center'><img src='Docs/static/img/article/dora-on-android.jpg' alt='dora on android' width='500px'/></div>|
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
|L·S·D|Provides open art resources and game IPs that can be used to create your own games - ["Luv Sense Digital"](https://luv-sense-digital.readthedocs.io).<br><br><div align='center'><img src='Docs/static/img/showcase/LSD.jpg' alt='LSD' width='300px'/></div>|

<br>

## Example Projects

- [Sample Project - Loli War](https://github.com/IppClub/Dora-Demo/tree/main/Loli%20War)

<div align='center'><img src='Docs/static/img/showcase/LoliWar.gif' alt='Loli War' width='400px'/></div>

<br>

- [Sample Project - Zombie Escape](https://github.com/IppClub/Dora-Demo/tree/main/Zombie%20Escape)

<div align='center'><img src='Docs/static/img/showcase/ZombieEscape.png' alt='Zombie Escape' width='800px'/></div>

<br>

- [Example Project - Dismentalism](https://github.com/IppClub/Dora-Demo/tree/main/Dismantlism)

<div align='center'><img src='Docs/static/img/showcase/Dismentalism.png' alt='Dismentalism' width='800px'/></div>

<br>

- [Example Project - Luv Sense Digital](https://github.com/IppClub/LSD)

<div align='center'><img src='Docs/static/img/showcase/LuvSenseDigital.png' alt='Luv Sense Digital' width='800px'/></div>

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
	- In the browser, open the right-click menu of the `Workspace` on the left side of the Dora Dora editor.
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
import { Sprite, Ease, Scale, Sequence, sleep } from 'Dora';

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
import { React, toNode } from 'DoraX';
import { Ease } from 'Dora';

toNode(
  <sprite file='Image/logo.png'>
    <sequence>
      <event name="Count" param="3"/>
      <delay time={1}/>
      <event name="Count" param="2"/>
      <delay time={1}/>
      <event name="Count" param="1"/>
      <delay time={1}/>
      <scale time={0.1} start={1} stop={0.5}/>
      <scale time={0.5} start={0.5} stop={1} easing={Ease.OutBack}/>
    </sequence>
  </sprite>
)?.slot("Count", (_, param) => print(param));
```

- **Wa**

	You can use Wa as a scripting language that runs on the built-in WASM runtime with hot reloading dev experience.

```go
import "dora"

func init {
  sprite := dora.NewSpriteWithFile("Image/logo.png")
  sprite.RunActionDef(
    dora.ActionDefSequence(&[]dora.ActionDef{
      dora.ActionDefEvent("Count", "3"),
      dora.ActionDefDelay(1),
      dora.ActionDefEvent("Count", "2"),
      dora.ActionDefDelay(1),
      dora.ActionDefEvent("Count", "1"),
      dora.ActionDefDelay(1),
      dora.ActionDefScale(0.1, 1, 0.5, dora.EaseLinear),
      dora.ActionDefScale(0.5, 0.5, 1, dora.EaseOutBack),
    }),
    false,
  )
  sprite.Slot("Count", func(stack: dora.CallStack) {
    stack.Pop()
    param, _ := stack.PopStr()
    dora.Println(param)
  })
}
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

<div align='center'><img src='Docs/static/img/art/casual/cheer.png' alt='Playground' width='500px'/></div>

<br>

## License

Dora SSR uses the [MIT License](LICENSE).

> [!NOTE]
> Please note that Dora SSR integrates the Spine Runtime library, which is a **commercial software**. The use of Spine Runtime in your projects requires a valid commercial license from Esoteric Software. For more details on obtaining the license, please visit the [official Spine website](http://esotericsoftware.com/).<br>
> Make sure to comply with all licensing requirements when using Spine Runtime in your projects. Alternatively, you can use the integrated open-source **DragonBones** system as an animation system replacement. If you only need to create simpler animations, you may also explore the Model animation module provided by Dora SSR to see if it meets your needs.
