<p align="center">
  <img src='Assets/Image/logo.png' alt='Dora SSR' width='300px'/>
</p>

# 多萝珍奇引擎（Dora SSR）

#### [English](README.md)  | 中文

![Static Badge](https://img.shields.io/badge/C%2B%2B20-Game_Engine-yellow?logo=c%2B%2B) ![Static Badge](https://img.shields.io/badge/ReactJS-Web_IDE-00d8ff?logo=react&logoColor=white) ![Static Badge](https://img.shields.io/badge/Rust-Scripting-e36f39?logo=rust) ![Static Badge](https://img.shields.io/badge/Lua-Scripting-blue?logo=lua) ![Static Badge](https://img.shields.io/badge/Teal-Scripting-blue) ![Static Badge](https://img.shields.io/badge/YueScript-Scripting-blue) ![Static Badge](https://img.shields.io/badge/TypeScript-Scripting-blue?logo=typescript&logoColor=white) ![Static Badge](https://img.shields.io/badge/TSX-Scripting-blue?logo=typescript&logoColor=white)
 ![Android](https://github.com/ippclub/Dora-SSR/actions/workflows/android.yml/badge.svg) ![Linux](https://github.com/ippclub/Dora-SSR/actions/workflows/linux.yml/badge.svg) ![Windows](https://github.com/ippclub/Dora-SSR/actions/workflows/windows.yml/badge.svg) ![macOS](https://github.com/ippclub/Dora-SSR/actions/workflows/macos.yml/badge.svg) ![iOS](https://github.com/ippclub/Dora-SSR/actions/workflows/ios.yml/badge.svg)

&emsp;&emsp;Dora SSR是一个用于多种设备上快速开发2D游戏的游戏引擎。它内置易用的开发工具链，支持在手机、开源掌机等设备上直接进行游戏开发。

<img src='Site/static/img/3.png' alt='Playground' width='600px'/>

## Dora SSR 项目现已加入开放原子开源基金会

&emsp;&emsp;我们很高兴地宣布，Dora SSR 项目现已成为开放原子开源基金会的官方捐赠和孵化筹备期项目。这一新的发展阶段标志着我们致力于建设一个更开放、更协作的游戏开发环境的坚定承诺。

### 关于开放原子开源基金会

&emsp;&emsp;开放原子开源基金会（Open Atom Foundation）是一个非盈利组织，旨在支持和推广开源技术的发展。在该基金会的大家庭中，Dora SSR 会利用更广泛的资源和社区支持，以推动项目的发展和创新。更多信息请查看[基金会官网](https://openatom.org/)。

## 主要特点

- 基于树形结点结构管理游戏场景。

- 基础的2D平台游戏功能，包括游戏逻辑和AI开发框架。

- 易用的ECS模块，便于游戏实体管理。

- 异步处理的文件读写、资源加载等操作。

- 升级的Lua绑定，支持继承和扩展底层C++对象。

- 支持Yuescript语言，强表达力且简洁的Lua方言。

- 支持Teal语言，编译到Lua的静态类型语言。

- 支持 TypeScript，一门静态类型的 JavaScript 语言的超集，添加了强大的类型检查功能。

- 支持 TSX，允许在脚本中嵌入类似 XML/HTML 的文本，与 TypeScript 一起使用。

- 支持Rust语言，运行在内置的WASM绑定和VM上。

- 2D骨骼动画和物理引擎支持。

- 内置开箱即用的Web IDE，提供文件管理，代码检查、补全、高亮和定义跳转。

- 支持异步操作SQLite，进行大量游戏配置数据的实时查询和写入。

- 支持Excel表格数据读取，支持同步到SQLite库表。

- 内置用于创新游戏玩法的机器学习算法框架。

- 支持Yarn Spinner语言，便于编写复杂的游戏故事系统。

- 提供矢量图形渲染API，可直接渲染无CSS的SVG格式文件。

- 内置ImGui，便于创建调试工具和UI界面。

- 支持FLAC、OGG、MP3和WAV多格式音频播放。

- 支持True Type字体的渲染和基础排版。

- 提供可用于制作自己游戏的开放美术素材和游戏IP —— [《灵数奇缘》](https://luv-sense-digital.readthedocs.io)。

&emsp;&emsp;<img src='Assets/Image/LSD.jpg' alt='LSD' width='300px'/>

<br>

## 安装配置

- 快速上手

  - Android
    - 1、在游戏的运行终端下载并安装[APK](https://github.com/ippclub/Dora-SSR/releases/latest)包。

    - 2、运行软件，通过局域网内的PC（平板或其他开发设备）的浏览器访问软件显示的服务器地址。

    - 3、开始游戏开发。

  - Windows、macOS
    - 1、下载并运行[软件](https://github.com/ippclub/Dora-SSR/releases/latest)。
      - 在macOS上也可以通过 Homebrew 进行软件安装。
          ```sh
          brew tap ippclub/dora-ssr
          brew install --cask dora-ssr
          ```

    - 2、运行软件，通过浏览器访问软件显示的服务器地址。

    - 3、开始游戏开发。
    
  - Linux
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

- 引擎项目开发

  进行Dora SSR项目开发的安装配置，详见[官方文档](https://Dora-ssr.net/zh-Hans/docs/tutorial/dev-configuration)。

<br>

## 快速入门

1. 第一步：创建一个新项目

   - 在浏览器中，打开Dora Dora编辑器左侧游戏资源树的右键菜单。

   - 点击菜单项`New`，选择新建文件夹。

2. 第二步：编写游戏代码

   - 在项目文件夹下新建游戏入口代码文件，选择 Lua  (Yuescript, Teal, Typescript 或 TSX) 语言命名为`init`。

   - 编写Hello World代码：

- **Lua**
```lua
local _ENV = Dora()

local sprite = Sprite("Image/logo.png")
sprite:schedule(once(function()
  for i = 3, 1, -1 do
    print(i)
    sleep(1)
  end
  print("Hello World")
  sprite:perform(Sequence(
    Scale(0.1, 1, 0.5),
    Scale(0.5, 0.5, 1, Ease.OutBack)
  ))
end))
```

- **Teal**
```lua
local sleep <const> = require("sleep")
local Ease <const> = require("Ease")
local Scale <const> = require("Scale")
local Sequence <const> = require("Sequence")
local once <const> = require("once")
local Sprite <const> = require("Sprite")

local sprite = Sprite("Image/logo.png")
if not sprite is nil then
  sprite:schedule(once(function()
    for i = 3, 1, -1 do
      print(i)
      sleep(1)
    end
    print("Hello World")
    sprite:perform(Sequence(
      Scale(0.1, 1, 0.5),
      Scale(0.5, 0.5, 1, Ease.OutBack)
    ))
  end))
end
```
- **Yuescript**
```moonscript
_ENV = Dora!

with Sprite "Image/logo.png"
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
- **Typescript**
```typescript
import {Sprite, Ease, Scale, Sequence, once, sleep} from 'dora';

const sprite = Sprite("Image/logo.png");
if (sprite) {
  sprite.schedule(once(() => {
    for (let i of $range(3, 1, -1)) {
      print(i);
      sleep(1);
    }
    print("Hello World");
    sprite.perform(Sequence(
      Scale(0.1, 1, 0.5),
      Scale(0.5, 0.5, 1, Ease.OutBack)
    ))
  }));
}
```
- **TSX**
```tsx
import { React, toNode, useRef } from 'dora-x';
import { ActionDef, Ease, Sprite, once, sleep } from 'dora';

const actionRef = useRef<ActionDef.Type>();
const spriteRef = useRef<Sprite.Type>();

const onUpdate = once(() => {
  for (let i of $range(3, 1, -1)) {
    print(i);
    sleep(1);
  }
  print("Hello World");
  if (actionRef.current && spriteRef.current) {
    spriteRef.current.perform(actionRef.current);
  }
});

toNode(
  <sprite
    ref={spriteRef}
    file='Image/logo.png'
    onUpdate={onUpdate}
  >
    <action ref={actionRef}>
      <sequence>
        <scale time={0.1} start={1} stop={0.5}/>
        <scale time={0.5} start={0.5} stop={1} easing={Ease.OutBack}/>
      </sequence>
    </action>
  </sprite>
);
```
- 也支持使用 **Rust** 来编写游戏代码，编译为 WASM 文件，命名为 `init.wasm` 再上传到引擎中加载运行。
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

3. 第三步：运行游戏

   点击编辑器右下角`🎮`图标，然后点击菜单项`Run`。或者按下组合键`Ctrl + r`。

4. 第四步：发布游戏

   - 通过编辑器左侧游戏资源树，打开刚才新建的项目文件夹的右键菜单，点击`Download`选项。

   - 等待浏览器弹出已打包项目文件的下载提示。


更详细的教程，请查看[官方文档](https://Dora-ssr.net/zh-Hans/docs/tutorial/quick-start)。

<br>

## 示例项目

- [示例项目 - Loli War](https://github.com/ippclub/Dora-SSR/tree/main/Assets/Script/Game/Loli%20War)

![Loli War](Assets/Image/LoliWar.gif)

<br>

- [示例项目 - Zombie Escape](https://github.com/ippclub/Dora-SSR/tree/main/Assets/Script/Game/Zombie%20Escape)

<img src='Assets/Image/ZombieEscape.png' alt='Zombie Escape' width='800px'/>

<br>

- [示例项目 - Dismentalism](https://github.com/ippclub/Dora-SSR/tree/main/Assets/Script/Game/Dismantlism)

<img src='Assets/Image/Dismentalism.png' alt='Dismentalism' width='800px'/>

<br>

- [示例项目 - Luv Sense Digital](https://e.coding.net/project-lsd/lsd/game.git)

<img src='Assets/Image/LuvSenseDigital.png' alt='Luv Sense Digital' width='800px'/>

<br>

## 文档

- [API参考](https://Dora-ssr.net/zh-Hans/docs/api/intro)
- [教程](https://Dora-ssr.net/zh-Hans/docs/tutorial/quick-start)

<br>

## 社区

- [Discord](https://discord.gg/ZfNBSKXnf9)
- [QQ群：512620381](https://qm.qq.com/cgi-bin/qm/qr?k=7siAhjlLaSMGLHIbNctO-9AJQ0bn0G7i&jump_from=webapi&authKey=Kb6tXlvcJ2LgyTzHQzKwkMxdsQ7sjERXMJ3g10t6b+716pdKClnXqC9bAfrFUEWa)

<br>

## 贡献

欢迎参与Dora SSR的开发和维护。请查看[贡献指南](CONTRIBUTING.zh-CN.md)了解如何提交Issue和Pull Request。

<br>

## 许可证

Dora SSR使用[MIT许可证](LICENSE)。原为Dorothy SSR项目，项目名称现处于更名程序中。
