# 欢迎来到 Dora SSR ！

![logo:250](../image/dora-toto.png)

&emsp;&emsp;祝贺您发现了这个宝藏！Dora SSR 是一个专注在多种移动设备上快速开发游戏的软件。游戏的开发工具链也包含其中，只需要一个运行设备（如：手机，开源游戏掌机），以及一台任意的编码工具（如：PC、平板），打开软件和浏览器就能立即开始制作游戏。

## 主要特性

Dora SSR 引擎的功能丰富，主要特性包括（可点击链接前往教程）：

- 基于[树形结点](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/setup-scene)结构管理游戏场景。
- 基础的 [2D 平台游戏](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/example/Platformer%20Tutorial/start)功能，包括游戏逻辑和 AI 开发框架。
- 易用的 [ECS](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/using-ecs) 模块，便于游戏实体管理。
- [异步处理](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/using-update/#%E7%A4%BA%E4%BE%8B%E6%89%A7%E8%A1%8C%E4%B8%80%E4%B8%AA%E5%85%A8%E5%B1%80%E5%8D%8F%E7%A8%8B%E4%BB%BB%E5%8A%A1)的文件读写、资源加载等操作。
- 升级的 Lua 绑定，支持继承和扩展底层 C++ 对象。
- 支持 [YueScript](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/Language%20Tutorial/yuescript-15min) 语言，强表达力且简洁的 Lua 方言。
- 支持 [Teal](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/Language%20Tutorial/teal-tutorial) 语言，编译到 Lua 的静态类型语言。
- 支持 [TypeScript](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/Language%20Tutorial/Using%20TypeScript%20in%20Dora/try-tstl) 语言，一门静态类型的 JavaScript 语言的超集，添加了强大的类型检查功能。
- 支持 [TSX](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/Language%20Tutorial/using-tsx)，允许在脚本中嵌入类似 XML/HTML 的文本，与 TypeScript 一起使用。
- 支持 [Wa](https://wa-lang.org) 语言，一门简单、可靠、静态类型的语言，运行在内置的 [WASM 绑定](https://github.com/IppClub/Dora-SSR/tree/main/Tools/dora-wa) 和运行时上。
- 支持 [Rust](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/blog/2024/4/15/rusty-game-dev) 语言，运行在内置的 WASM 绑定和运行时上。
- 2D [骨骼动画](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/Using%20Nodes/using-playable)和[物理引擎](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/Using%20Nodes/using-physics-1)支持。
- 内置开箱即用的 Web IDE，提供文件管理，代码检查、补全、高亮和定义跳转。
- 支持异步操作 [SQLite](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/Managing%20Game%20Data/using-database)，进行大量游戏配置数据的实时查询和写入。
- 支持 [Excel](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/Managing%20Game%20Data/using-excel) 表格数据读取，支持同步到SQLite库表。
- 提供游戏场景通过 CSS 进行自适应的 [Flex 布局](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/adapting-to-screen#32-%E4%BD%BF%E7%94%A8-css-flex-%E5%B8%83%E5%B1%80)的功能。
- 支持 [Effekseer](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/Using%20Nodes/using-effect) 特效系统的功能。
- 支持 [Tiled Map Editor](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/Using%20Nodes/using-tilemap) 制作的 TMX 地图文件的解析和渲染。
- 内置用于创新游戏玩法的[机器学习](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/Using%20Machine%20Learning/using-decision-tree)算法框架。
- 支持 [Yarn Spinner](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/Writing%20Game%20Dialogue/introduction-to-yarn) 语言，便于编写复杂的游戏故事系统。
- 提供[矢量图形](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/Using%20Nodes/using-vg-node)渲染 API，可直接渲染无 CSS 的 SVG 格式文件。
- 内置 [ImGui](https://ippclub.atomgit.net/Dora-SSR/zh-Hans/docs/tutorial/using-imgui)，便于创建调试工具和UI界面。
- 支持 FLAC、OGG、MP3 和 WAV 多格式音频播放。
- 支持 True Type 字体的渲染和基础排版。
- 提供可用于制作自己游戏的开放美术素材和游戏 IP —— [《灵数奇缘》](https://luv-sense-digital.readthedocs.io)。

## 参与社区

&emsp;&emsp;我们希望您能够利用 Dora SSR 游戏引擎，释放您的创造力，制作出令人惊叹的游戏。在这个过程中，如果您遇到任何问题或者有任何建议，都欢迎您与我们联系，我们将全力为您提供支持。

&emsp;&emsp;感谢您选择 Dora SSR 游戏引擎，让我们一起创造无限可能吧！

* [QQ群：512620381](https://qm.qq.com/cgi-bin/qm/qr?k=7siAhjlLaSMGLHIbNctO-9AJQ0bn0G7i&jump_from=webapi&authKey=Kb6tXlvcJ2LgyTzHQzKwkMxdsQ7sjERXMJ3g10t6b+716pdKClnXqC9bAfrFUEWa)
