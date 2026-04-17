# Dora SSR

[English](README.md) | 简体中文

&emsp;&emsp;Dora SSR 是一个面向多种设备快速开发 2D 游戏的游戏引擎。它内置了易用的开发工具链，支持在手机、开源掌机等设备上直接进行游戏开发。

## 主要特性

- 基于树节点结构管理游戏场景。
- 提供 2D 平台游戏基础功能，包括游戏逻辑和 AI 开发框架。
- 提供易用的 ECS 模块进行游戏实体管理。
- 支持文件读写、资源加载等操作的异步处理。
- 升级版 Lua 绑定，支持继承和扩展底层 C++ 对象。
- 支持 Yuescript，一种表达力强且简洁的 Lua 方言。
- 支持 Teal，一种静态类型的 Lua 方言。
- 支持 TypeScript，一种带有强大类型检查能力的 JavaScript 超集。
- 支持 TSX，可在脚本中嵌入 XML/HTML 风格文本，与 TypeScript 配合使用。
- 支持 Rust 语言，通过内置 WASM 运行时和 Rust 绑定运行。
- 支持 2D 骨骼动画和物理引擎。
- 内置开箱即用的 Web IDE，提供文件管理、代码检查、补全、高亮和定义跳转。
- 支持异步操作 SQLite，用于实时查询和管理大型游戏配置数据。
- 支持读取 Excel 表格数据并同步到 SQLite 表。
- 支持 Yarn Spinner 语言，便于编写复杂的游戏剧情系统。
- 内置机器学习算法框架，用于创新玩法开发。
- 提供矢量图形渲染 API，可直接渲染 SVG 文件而无需 CSS。
- 内置 ImGui，便于创建调试工具和 UI 界面。
- 支持 FLAC、OGG、MP3 和 WAV 多格式音频播放。
- 支持 True Type 字体渲染和基础排版。
- 提供可用于创作你自己游戏的开放美术资源和游戏 IP: ["Luv Sense Digital"](https://luv-sense-digital.readthedocs.io)。

<br>

## 安装

### Android

- 1\. 在运行游戏的设备上下载并安装 [APK](https://github.com/ippclub/Dora-SSR/releases/latest)。
- 2\. 运行软件，并在局域网内通过 PC、平板或其他开发设备的浏览器访问软件显示的服务器地址。
- 3\. 开始开发游戏。

### Windows

- 1\. 确保你已安装适用于 Visual Studio 2022 的 X86 Visual C++ Redistributable，即 MSVC 运行时包 `vc_redist.x86`。可从 [Microsoft 官网](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170) 下载。
- 2\. 下载并解压 [软件](https://github.com/ippclub/Dora-SSR/releases/latest)。
- 3\. 运行软件，并通过浏览器访问软件显示的服务器地址。
- 4\. 开始开发游戏。

### macOS

- 1\. 下载并解压 [软件](https://github.com/ippclub/Dora-SSR/releases/latest)。也可以通过 [Homebrew](https://brew.sh) 安装：
	```sh
	brew install --cask ippclub/tap/dora-ssr
	```
- 2\. 运行软件，并通过浏览器访问软件显示的服务器地址。
- 3\. 开始开发游戏。

### Linux

- 1\. 通过 PPA 安装。
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
- 2\. 运行软件，并通过浏览器访问软件显示的服务器地址。
- 3\. 开始开发游戏。

### 构建游戏引擎

- 关于 Dora SSR 项目的构建说明，请参考[官方文档](https://dora-ssr.net/docs/tutorial/dev-configuration)。

<br>

## 快速开始

1. 第一步：创建新项目

    - 在浏览器中，打开 Dora Dora 编辑器左侧 `Workspace` 的右键菜单。
    - 点击 `New` 菜单项，创建一个名为 `Hello` 的文件夹。

2. 第二步：编写游戏代码

    - 在命令行中创建一个新的 Rust 项目。

      ```sh
      rustup target add wasm32-wasi
      cargo new hello-dora --name init
      cd hello-dora
      cargo add dora_ssr
      ```

    - 在 `src/main.rs` 中编写代码。

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

    - 将其构建成 WASM 文件。

      ```sh
      cargo build --release --target wasm32-wasi
      ```

    - 上传到引擎中运行。在 Dora SSR Web IDE 中，打开游戏资源树里新建目录 `Hello` 的右键菜单，点击 `Upload`，选择编译得到的 `init.wasm` 文件。

    - 或者安装统一的 [dora-cli](https://github.com/IppClub/Dora-SSR/blob/main/Tools/dora-cli) 工具，在 Rust 项目目录中运行 `uv tool install Tools/dora-cli`，然后执行 `dora rust run Hello --host 192.168.3.1`。这里的 IP 地址是 Dora SSR Web IDE 的地址，`Hello` 是 Dora SSR 资源树中的目标目录名。

3. 第三步：运行游戏

    点击编辑器右下角的 `🎮` 图标，然后点击 `Run`，或者按 `Ctrl + r`。

4. 第四步：发布游戏

    - 在左侧游戏资源树中打开刚创建项目目录的右键菜单，点击 `Download`。
    - 等待浏览器弹出打包后项目文件的下载提示。

如需更详细的教程，请参考[官方文档](https://dora-ssr.net)。

<br>

## 社区

- [Discord](https://discord.gg/ydJVuZhh)
- [QQ 群: 512620381](https://qm.qq.com/cgi-bin/qm/qr?k=7siAhjlLaSMGLHIbNctO-9AJQ0bn0G7i&jump_from=webapi&authKey=Kb6tXlvcJ2LgyTzHQzKwkMxdsQ7sjERXMJ3g10t6b+716pdKClnXqC9bAfrFUEWa)

<br>

## 许可证

Dora SSR 使用 MIT 许可证。
