# Dora SSR Wa 包

[English](README.md) | 简体中文

一个用于将 Wa-lang 集成到 Dora SSR 游戏引擎中的语言绑定项目。

## 关于本项目

这个项目连接了两个有趣的开源项目：

- **Dora SSR**：一个面向多种设备快速开发游戏的通用游戏引擎。它内置 Web IDE，支持在手机、开源掌机等设备上直接开发游戏。
- **Wa-lang**：一个专为 WebAssembly 设计的通用编程语言。Wa-lang 致力于提供一种简单、可靠、静态类型且适合高性能场景的语言。

本仓库提供 Dora SSR 的 Wa 语言绑定，以及用于展示 Dora-Wa 集成能力的测试和示例项目。

## 仓库内容

- Dora SSR 引擎 API 的 Wa 语言绑定
- 展示 Dora-Wa 集成与使用方式的测试和示例项目

## 安装

- 安装 Dora SSR 引擎

    参考 [Dora SSR 安装指南](https://dora-ssr.net/docs/tutorial/quick-start)

- 安装 Wa-lang 编译器

    参考 [Wa-lang 上手指南](https://wa-lang.org/tutorial/)

## 使用方法

1. 第一步：创建新的 Dora SSR 游戏项目

    - 确保已经安装 Dora SSR 引擎和 Wa-lang 编译器。
    - 启动 Dora SSR 软件，并在浏览器中打开 Web IDE。
    - 在左侧游戏资源树中，打开 `Workspace` 的右键菜单。
    - 点击 `New` 菜单项，创建一个名为 `Hello` 的文件夹。

2. 第二步：编写 Wa 游戏代码

    - 在命令行中创建新的 Wa 项目。

      ```sh
      wa init -n hello_dora --wasi
      cd hello_dora
      ```

    - 将 `hello_dora/wa.mod` 中的 `name` 字段改为 `init`。

    - 把本仓库 `vendor/dora` 目录中的整个模块复制到 `hello_dora/vendor/dora`。

    - 在 `src/main.wa` 中编写代码。

      ```wa
      import "dora"

      func init() {
          // create a sprite
          sprite := dora.NewSpriteWithFile("Image/logo.png")

          // create a root node of the game scene tree
          root := dora.NewNode()

          // mount the sprite to the root node of the game scene tree
          root.AddChild(sprite.Node)

          // receive and process tap event to move the sprite
          root.OnTapBegan(func(touch: dora.Touch) {
              sprite.PerformDef(dora.ActionDefMoveTo(
                  1.0,                  // duration, unit is second
                  sprite.GetPosition(), // start position
                  touch.GetLocation(),  // end position
                  dora.EaseOutBack,     // easing function
              ), false)
          })
      }
      ```

    - 将其构建成 WASM 文件。

      ```sh
      wa build -optimize
      ```

    - 上传到引擎中运行。在 Dora SSR Web IDE 中，打开游戏资源树中新建目录 `Hello` 的右键菜单，点击 `Upload`，选择编译得到的 `output/init.wasm` 文件。

    - 或者安装统一的 [dora-cli](https://github.com/IppClub/Dora-SSR/blob/main/Tools/dora-cli/README.zh-CN.md) 工具，在 Dora SSR 仓库目录中运行 `uv tool install Tools/dora-cli`，然后执行 `dora wa run Hello --host 192.168.3.1`。这里的 IP 地址是 Dora SSR Web IDE 的地址，`Hello` 是 Dora SSR 资源树中的目标目录名。

3. 第三步：运行游戏

    点击编辑器右下角的 `🎮` 图标，然后点击 `Run`，或者按 `Ctrl + r`。

4. 第四步：发布游戏

    - 在左侧游戏资源树中打开刚创建项目目录的右键菜单，点击 `Download`。
    - 等待浏览器弹出打包后项目文件的下载提示。

## 文档

- [Dora SSR 文档](https://github.com/ippclub/dora-ssr)
- [Wa-lang 文档](https://wa-lang.org)

## 开发状态

当前项目仍在持续开发中，因为 Wa-lang 和 Dora SSR 都还在演进。Wa-lang 目前仍处于工程试验阶段，我们也在持续扩展两者的集成能力。

## 贡献

欢迎贡献，包括但不限于：

- 改进语言绑定
- 添加新功能
- 创建更多示例
- 修复 bug
- 改进文档

欢迎提交 Pull Request 或创建 Issue。

## 许可证

MIT

## 联系方式

- Dora SSR 相关问题: [Dora SSR GitHub Issues](https://github.com/ippclub/dora-ssr)
- Wa-lang 相关问题: [Wa-lang GitHub Issues](https://github.com/wa-lang/wa)
- 绑定项目相关问题: 请在本仓库中创建 issue
