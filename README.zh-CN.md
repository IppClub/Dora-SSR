<img src='Assets/Image/logo.png' alt='Dorothy SSR' width='200px'/>

# Dorothy SSR

#### [English](README.md)  | 中文

&emsp;&emsp;Dorothy SSR是一个用于多种设备上快速开发2D游戏的游戏引擎。它内置易用的开发工具链，支持在手机、开源掌机等设备上直接进行游戏开发。

|Android|Linux|Windows|macOS|iOS|
|:-:|:-:|:-:|:-:|:-:|
|[![Android](https://github.com/pigpigyyy/Dorothy-SSR/actions/workflows/android.yml/badge.svg)](https://github.com/pigpigyyy/Dorothy-SSR/actions/workflows/android.yml)|[![Linux](https://github.com/pigpigyyy/Dorothy-SSR/actions/workflows/linux.yml/badge.svg)](https://github.com/pigpigyyy/Dorothy-SSR/actions/workflows/linux.yml)|[![Windows](https://github.com/pigpigyyy/Dorothy-SSR/actions/workflows/windows.yml/badge.svg)](https://github.com/pigpigyyy/Dorothy-SSR/actions/workflows/windows.yml)|[![macOS](https://github.com/pigpigyyy/Dorothy-SSR/actions/workflows/macos.yml/badge.svg)](https://github.com/pigpigyyy/Dorothy-SSR/actions/workflows/macos.yml)|[![iOS](https://github.com/pigpigyyy/Dorothy-SSR/actions/workflows/ios.yml/badge.svg)](https://github.com/pigpigyyy/Dorothy-SSR/actions/workflows/ios.yml)|

<br>

## 主要特点

- 基于树形结点结构管理游戏场景。

- 基础的2D平台游戏功能，包括游戏逻辑和AI开发框架。

- 易用的ECS模块，便于游戏实体管理。

- 异步处理的文件读写、资源加载等操作。

- 升级的Lua绑定，支持继承和扩展底层C++对象。

- 支持Yuescript语言，强表达力且简洁的Lua方言。

- 支持Teal语言，编译到Lua的静态类型语言。

- 支持Rust语言，运行在内置的WASM绑定和VM上。

- 2D骨骼动画和物理引擎支持。

- 内置开箱即用的Web IDE，提供文件管理，代码检查、补全、高亮和定义跳转。

- 支持异步操作SQLite，进行大量游戏配置数据的实时查询和写入。

- 支持Excel表格数据读取，支持同步到SQLite库表。

- 提供矢量图形渲染API，可直接渲染无CSS的SVG格式文件。

- 内置ImGui，便于创建调试工具和UI界面。

- 支持FLAC、OGG、MP3和WAV多格式音频播放。

- 支持True Type字体的渲染和基础排版。

- 提供可用于制作自己游戏的开放美术素材和游戏IP —— [《灵数奇缘》](http://luvsensedigital.org)。

&emsp;&emsp;<img src='Assets/Image/LSD.jpg' alt='LSD' width='300px'/>

<br>

## 安装

- 快速上手

  - Android
    - 1、在游戏的运行终端下载并安装[APK](https://github.com/pigpigyyy/Dorothy-SSR/releases/latest)包。
    - 2、运行软件，通过局域网内的PC（平板或其他开发设备）的浏览器访问软件显示的服务器地址。
    - 3、开始游戏开发。

  - Windows
    - 1、下载并运行[软件](https://github.com/pigpigyyy/Dorothy-SSR/releases/latest)。
    
    - 2、运行软件，通过浏览器访问软件显示的服务器地址。
    
    - 3、开始游戏开发。

- 硬核开发  
  进行Dorothy SSR项目开发的安装配置，详见[官方文档](施工中)。

<br>

## 快速入门

1. 第一步：创建一个新项目

   - 在浏览器中，打开Dora Dora编辑器左侧游戏资源树的右键菜单。
   - 点击菜单项`New`，选择新建文件夹。

2. 第二步：编写游戏代码

   - 在项目文件夹下新建游戏入口代码文件，名字为`init.yue`。

   - 编写Hello World代码：

```moonscript
_ENV = Dorothy!

with Sprite "Image/logo.png"
  \addTo Director.entry
  \schedule once ->
    for i = 3, 1, -1
      print i
      sleep 1
    print "Hello World!"
    \perform Sequence(
      Scale 0.1, 1, 0.5
      Scale 0.5, 0.5, 1, Ease.OutBack
    )
```

3. 第三步：运行游戏

   点击编辑器右下角`🎮`图标，然后点击菜单项`Run`。或者按下组合键`Ctrl + r`。

4. 第四步：发布游戏

   - 通过编辑器左侧游戏资源树，打开刚才新建的项目文件夹的右键菜单，点击`Download`选项。

   - 等待浏览器弹出已打包项目文件的下载提示。


更详细的教程，请查看[官方文档](施工中)。

<br>

## 示例项目

- [示例项目 - Loli War](https://github.com/pigpigyyy/Dorothy-SSR/tree/main/Assets/Script/Game/Loli%20War)

![Loli War](Assets/Image/LoliWar.gif)

<br>

- [示例项目 - Zombie Escape](https://github.com/pigpigyyy/Dorothy-SSR/tree/main/Assets/Script/Game/Zombie%20Escape)

<img src='Assets/Image/ZombieEscape.png' alt='Zombie Escape' width='800px'/>

<br>

- [示例项目 - Dismentalism](https://github.com/pigpigyyy/Dorothy-SSR/tree/main/Assets/Script/Game/Dismantlism)

<img src='Assets/Image/Dismentalism.png' alt='Dismentalism' width='800px'/>

<br>

- [示例项目 - Luv Sense Digital](https://e.coding.net/project-lsd/lsd/game.git)

<img src='Assets/Image/LuvSenseDigital.png' alt='Luv Sense Digital' width='800px'/>

<br>

## 文档

- [API参考](施工中)
- [开发指南](施工中)
- [教程](施工中)

<br>

## 社区

- [社交媒体](施工中)
- [开发者聊天室](施工中)

<br>

## 贡献

欢迎参与Dorothy SSR的开发和维护。请查看[贡献指南](CONTRIBUTING.zh-CN.md)了解如何提交Issue和Pull Request。

<br>

## 许可证

Dorothy SSR使用[MIT许可证](LICENSE)。
