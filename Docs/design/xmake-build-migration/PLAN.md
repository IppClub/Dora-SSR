# Dora-SSR xmake 单一构建定义迁移方案

> 状态：方案已实施，本地收尾完成；远端 CI 与生产发布门禁待验收
> 更新日期：2026-10-01
> 配套进度表：[PROGRESS.md](./PROGRESS.md)

2026-10-01 收尾范围：移除旧手工 Xcode/VS/Linux CMake 工程和冗余依赖脚本，保留 Apple/Windows 平台资源、Android Gradle 与薄 CMake 适配器，以及独立测试/资源生成工具。根目录 `xmake.lua` 保留；实现集中在 `Projects/xmake/`。桌面统一使用 `xmake dora-build` / `dora-run`，IDE 使用 `dora-ide` 生成至被忽略的 `build/ide/`，发行包使用 `dora-package`。旧 shell/batch 公共入口仅作兼容转发，不再维护构建图。下文旧文件统计为迁移前基线，不代表仍保留这些工程。

## 1. 背景

Dora-SSR 在迁移开始时（2026-09-30）同时维护多套 Native 构建描述和平台编排逻辑：

- CMake 负责 Linux、Android、Web/Emscripten，以及共享的引擎源文件清单；
- xmake 负责 SDL2、bgfx、Love、Theora、Ogg、LuaSocket 等第三方库的跨平台构建；
- macOS、iOS 和 Windows 仍存在提交到仓库的 Xcode/Visual Studio 工程；
- `Tools/build-scripts` 下有 23 个 shell、10 个 batch、37 个 JavaScript 和 1 个 Lua 脚本，分别承担依赖检查、编译、运行、测试和打包；
- Rust、Go、Gradle、pnpm 等生态工具由外层脚本和 CI 分别安装、调用。

这种结构的主要问题不是工具数量本身，而是同一项 Native 构建事实可能同时存在于 CMake、xmake、IDE 工程和 shell/batch 脚本中。源文件、平台宏、逐文件编译参数、链接库、资源目录或输出路径变化时，容易出现只更新一处的配置漂移。

迁移前已跟踪的主要构建描述规模如下（当前实施状态见进度表）：

| 构建描述 | 行数 | 主要职责 |
| --- | ---: | --- |
| `Projects/Web/CMakeLists.txt` | 874 | Web Player、Love、pthread、AudioWorklet、资源和测试目标 |
| `Projects/Android/Dora/app/CMakeLists.txt` | 684 | Android Native、多 ABI、JNI 和依赖链接 |
| `Projects/CMake/*.cmake` | 822 | 引擎、Love、生成代码及 Web 链接源清单 |
| `Projects/Emscripten/CMakeLists.txt` | 358 | 旧 Emscripten 目标 |
| `Projects/Linux/CMakeLists.txt` | 162 | Linux Native 主程序 |
| `Source/3rdParty/bgfx/xmake.lua` | 1175 | bgfx、shaderc 及平台差异 |
| 其余第三方 `xmake.lua` | 592 | SDL2、Love、Theora、Ogg、LuaSocket |

## 2. 已确认的技术决策

1. **xmake 是唯一的 Native 构建描述源。**
   C、C++、Objective-C、Objective-C++、平台宏、编译参数、链接关系、生成代码依赖和 Native 产物路径最终只在 xmake 中维护。
2. **使用 xmake latest。**
   不固定 xmake 版本；CI 和本地文档使用最新稳定版，并在构建日志中记录 `xmake --version`。
3. **由 xmake 管理可自动安装的构建依赖。**
   Go、Rust、rustup、Emscripten 等可通过 xmake-repo 获取的 host 工具使用 `add_requires(..., {host = true, system = false})` 声明和安装。
4. **保留外部生态的原生工具。**
   Gradle、Cargo、Go Modules、pnpm、Xcode SDK、Visual Studio 和平台签名工具仍承担各自生态职责；xmake 负责声明依赖、选择工具链和统一编排，而不是重新实现它们。
5. **IDE 工程是生成物，不是构建真相。**
   Xcode 和 Visual Studio 工程由 xmake 生成或集成，生成文件不提交；CI 直接调用 xmake，避免 IDE generator 形成第二套行为。
6. **构建脚本按职责迁移，不逐行翻译。**
   编译图进入 target/rule/package，环境诊断进入 task，运行进入 `xmake run`，打包进入 package task；独立的 JavaScript 浏览器测试继续保留，由 xmake 调度。
7. **以运行时和发行产物作为验收边界。**
   “xmake 构建成功”只证明编译层通过，不等价于平台迁移完成。
8. **Android 保留 Gradle/CMake 的原生构建链路。**
   xmake 按 ABI 与 Debug/Release 配置生成真实 CMake target 图，Gradle 通过 CMake/Ninja 调用 NDK 编译 C/C++。CMake 入口只负责工具链与生成器接线，不维护源文件、宏、逐文件参数或依赖清单；Lua 绑定、Rust 和 Wa 的自定义步骤仍由 xmake 管理。
9. **交互断点验收豁免。**
   2026-10-01 用户明确要求不再验证 IDE 交互断点，继续完成 iOS 与 Web 迁移；后续保留构建、资源、签名检查和运行验证。豁免不表示调试行为已验证。

## 3. 目标与非目标

### 3.1 目标

- 建立一个根级 `xmake.lua`，覆盖 Dora Native 引擎和所有受支持平台；
- 将源文件、宏、逐文件选项、依赖、链接和资源配置集中到可复用的 Lua 模块；
- 让新环境执行 xmake 后能自动解析和安装 Go、Rust、Emscripten等可管理依赖；
- 用 `xmake doctor` 统一检查不可自动安装的系统 SDK、签名环境和平台工具；
- 用统一命令完成 configure、build、run、test 和 package；
- 删除 Dora 自身重复维护的 CMake 构建清单和提交的 Xcode/Visual Studio 工程；Android 保留薄 CMake 接入层与生成的构建图；
- 显著减少 `Tools/build-scripts` 中重复的 shell/batch 构建脚本；
- 保持现有平台、CI、Web 运行时和发布产物能力不回退。

### 3.2 非目标

- 不替换 Gradle 的 APK/AAB、Manifest、资源合并和签名职责；
- 不替换 Cargo、Go Modules 或 pnpm 的语言包管理职责；
- 不重写现有 `.mjs` 浏览器测试、Web 打包器和检查器；
- 不删除 `Tools/dora-cs` 的 .NET solution 或第三方 vendored IDE 文件；
- 不在迁移中顺带升级第三方库、改变引擎 ABI 或调整平台最低版本；
- 不以减少文件数量为由合并无关测试、发布或运维逻辑。

## 4. 目标架构

建议结构：

```text
xmake.lua
Projects/xmake/
  options.lua
  engine.lua
  generated.lua
  manifests/
    engine.lua
    love.lua
    web.lua
  dependencies/
    sdl2.lua
    bgfx.lua
    love.lua
    theora.lua
    ogg.lua
    luasocket.lua
    wa.lua
    rust.lua
  platforms/
    apple.lua
    android.lua
    linux.lua
    wasm.lua
    windows.lua
  rules/
    generated_lua.lua
    apple_bundle.lua
    web_assets.lua
  tasks/
    doctor.lua
    package.lua
    test.lua
    release.lua
```

模块职责：

- `manifests/` 只描述源文件集合，避免在平台文件中重复长清单；
- `dependencies/` 定义 vendored 库目标、host/target 工具以及依赖产物；
- `platforms/` 只声明平台差异，不复制通用引擎配置；
- `rules/` 描述有输入、输出和增量语义的生成流程；
- `tasks/` 编排诊断、测试、打包和发布，不承载编译参数真相。

> 实现注：2026-10-01 按用户要求将构建实现集中到 `Projects/xmake/`，与已有平台工程归类一致。根目录保留 `xmake.lua` 入口，可继续直接执行原构建命令；`build/` 仍仅存放被忽略的构建产物。

### 4.1 源文件语言真实性

- 文件扩展名必须表达真实编译语言：C++ 源使用 `.cpp`/`.mm`，C 源使用 `.c`/`.m`；
- 不允许用 MSVC `/TP`、Clang/GCC `-x c++` 等全局或逐文件参数，把包含 C++ 语法的“伪 C”文件继续伪装成 `.c`；
- 迁移中发现伪 C 时，要么改名为 `.cpp` 并同步唯一源清单，要么移除 C++ 语法、按目标 C 标准修正为真正的 C；
- 合并式第三方 C 源可使用与旧构建一致的 GNU C 扩展（当前为 GNU C11），但不能因此获得 C++ 语义；
- Windows 对 `.c` 显式保持 `/TC`，用于尽早暴露语言标注错误。语言修正后必须至少通过 Clang/GCC C 编译和 MSVC C 编译之一，并由跨平台构建继续兜底。

## 5. 统一命令体验

目标命令如下：

```sh
# 环境诊断
xmake doctor

# 桌面平台
xmake f -p macosx -a arm64 -m debug
xmake
xmake run Dora

xmake f -p windows -a x86 -m release
xmake

xmake f -p linux -a x86_64 -m release
xmake

# 移动平台
xmake f -p iphoneos -a arm64 --appledev=simulator -m debug
xmake

xmake f -p android -a arm64-v8a -m release
xmake
xmake dora-package --platform=android --mode=release

# Web
xmake f -p wasm -m release
xmake
xmake test web
```

具体命令名称可在实现阶段微调，但不得重新引入每个平台独立的源文件、宏或链接配置。

## 6. 构建依赖管理

### 6.1 xmake 自动管理

优先使用 xmake-repo 声明 host 工具；如果上游 package 的间接依赖在受支持 host 上不可构建，则在仓库内维护最小包装 package，但工具本体仍从官方发行源安装：

```lua
add_requires("go", {host = true, system = false})
add_requires("rust", {host = true, system = false})

if is_plat("wasm") then
    add_requires("emscripten", {host = true, system = false})
end
```

要求：

- 下载和缓存由 xmake 管理，不写入系统工具目录；
- host 工具与 target 产物明确分离；
- CI 缓存 xmake package 目录，但缓存命中不是构建正确性的前提；
- 构建日志记录实际使用的 xmake、Go、Rust、Cargo、Emscripten 和编译器版本；
- 使用 xmake latest 时，依赖解析变化必须由完整平台 CI 和运行时回归兜底。

### 6.2 系统环境检查

以下依赖默认只检查，不自动安装：

- macOS/iOS：Xcode、SDK、签名身份、必要的 simulator runtime；
- Windows：Visual Studio Build Tools、Windows SDK；
- Android：Android SDK、必要的 build-tools/platform、JDK、Gradle wrapper 可用性；
- Linux：发行版运行时和 AppImage 打包所需的系统工具；
- 发布：证书、令牌、远程仓库权限。

`xmake doctor` 应输出：

- 检查项名称、发现的路径和版本；
- `OK`、`WARN` 或 `ERROR`；
- 缺失项的最小修复指引；
- 当前平台不适用项应跳过，而不是报错。

## 7. 平台迁移设计

### 7.1 Linux

- 将 `Projects/Linux/CMakeLists.txt` 的 Dora 主程序、链接库、宏和 Jolt/SDL/SoLoud 差异迁入 xmake；
- 保持 x86_64 与 aarch64 输出布局兼容 AppImage 和发行版打包；
- `xmake run Dora` 必须使用正确的 Assets 路径；
- 验收包括普通二进制启动和 AppImage 启动，不以链接成功为终点。

### 7.2 Windows

- 迁移 Win32/x86 目标、MSVC runtime、PCH、逐文件 PCH 排除、资源文件和链接排除参数；
- 所有 `.c` 源保持 MSVC C 模式；不得以 `/TP` 绕过错误，发现伪 C 时按 4.1 节改名或修正源码；
- xmake 直接构建为 CI 真相；`vsxmake` 工程只用于 Visual Studio 浏览、调试和 IntelliSense；
- 保持 `Dora.exe`、`wa.dll` 和运行目录布局；
- 必须在 Windows VM/实体机启动并完成输入、网络和资源加载 smoke test。

### 7.3 macOS

- 使用 `xcode.application` 或等价 xmake Apple rule 构建 `.app`；
- 迁移 Info.plist、Assets.xcassets、资源目录、framework、bundle identifier 和最低系统版本；
- 保持 arm64、x86_64 和 universal 构建；
- 显式保留 `LUA_USE_MACOSX`、Jolt 逐文件参数等旧工程语义；
- Debug 必须可运行，Release 必须验证 ZIP 内 bundle 布局和签名状态。

### 7.4 iOS

- 使用 xmake 的 `iphoneos` device/simulator 配置；
- 分离 device 与 simulator 输出，防止同架构产物互相污染；
- 迁移 storyboard、Info.plist、Assets.xcassets、framework、最低 iOS 版本和设备族；
- 验证 simulator 启动；device 构建和签名作为发布前门禁。

### 7.5 Android

- xmake 为每个 ABI/构建类型导出 Native CMake target 图；Gradle/CMake/Ninja 使用 NDK 实际编译 `.so` 与 C/C++ 静态依赖；
- Gradle wrapper 负责 Native 增量构建，以及 APK/AAB、Manifest、资源、Java/Kotlin 和签名；
- `app/CMakeLists.txt` 保留为薄入口；生成文件位于各 ABI/variant 的 `.cxx` 构建目录，每个配置使用独立的 `XMAKE_CONFIGDIR`，不覆盖仓库当前 xmake 配置；
- 支持 arm64-v8a、armeabi-v7a 和 x86_64；
- Native 配置使用与 Gradle `minSdkVersion 28` 一致的 NDK API 28，并优先选择已验证的 versioned NDK 26.1.10909125，不能被指向旧 `ndk-bundle` 的遗留环境变量覆盖；桌面 NFD/DBus 实现不得进入 Android 源集，pthread 使用 Android libc 提供的实现而不链接不存在的独立 `libpthread`；
- `xmake dora-package --platform=android --mode=<debug|release>` 调用 Gradle wrapper，由其完成默认三 ABI 构建与打包；不再预编译或暂存第二份 C/C++ 引擎库；
- CMake 构建前调用 xmake 的 Lua 绑定与 Rust target，并序列化共享生成器输出；Gradle 的 `prepareXmakeAndroid` task 负责 xmake-managed Go/Wa AAR 与相关资源；
- Android Studio 的 Native 调试属于完整接入门禁：保留匹配的未剥离 `.so` 供 LLDB 查找，实际命中 C++ 行断点并检查调用栈和变量；从 IDE Run/Debug 入口修改 C++ 后，Gradle/CMake 自动增量重建并安装新产物；
- 验收包括 APK 安装、冷启动、触摸/文本输入、资源加载和 Native 崩溃检查；原手写 Android 源清单由生成图替换，薄 CMake 接入层长期保留。

### 7.6 Web/Wasm

- 迁移 `Projects/Web/CMakeLists.txt` 中所有 profile、导出函数、preload、shell、pthread、AudioWorklet 和测试目标；
- 保留现有 JavaScript 检查器及浏览器 fixture，由 `xmake test web` 调用；
- 明确 host 工具、target 静态库和不同 Web profile 的输出隔离；
- Web 是最高风险迁移项，必须先做原型验证，再进入全量迁移；
- 验收必须包含浏览器启动、图形、音频、输入、Love、复杂项目、pthread 和打包产物检查。

## 8. shell/batch 脚本收敛策略

### 8.1 应迁入 xmake 的逻辑

| 当前职责 | 目标表达 |
| --- | --- |
| `build_lib_sdl2/bgfx/love/theora*` | dependency targets/packages |
| `build_lib_<platform>*` | target dependency graph 和平台配置 |
| `build_<platform>*` | 标准 `xmake` build |
| `run_<platform>*` | `xmake run` 和 target run 配置 |
| `check_build_env*` | `xmake doctor` |
| tolua++ 绑定生成 | 声明输入/输出的 codegen rule |
| AppImage、ZIP、Web staging | package task |
| CI 中重复的安装步骤 | `xmake require` / configure/build |

### 8.2 应继续保留的逻辑

- `.mjs` 浏览器测试、资源生成器和包内容检查器；
- Gradle wrapper 和 Android 工程；
- Cargo.toml、Cargo.lock、Go module/vendor、pnpm lockfile；
- 与仓库构建无关的发行版同步或系统部署脚本；
- 必须在外部环境执行的签名和发布操作。

保留的工具应由 xmake task 调用，但不应为了“只剩 Lua 文件”而重写。

## 9. 增量迁移阶段

### M0：基线冻结与验收清单

- 记录所有平台现有命令、产物路径、CI job 和发布包结构；
- 保存 Debug/Release 宏、链接库、framework、逐文件参数和资源清单；
- 建立 generated-source clean build、`git diff --check` 和 source-manifest parity 检查；
- PR #129 作为迁移清单参考，在 xmake 架构方向确认后不继续扩大 CMake 覆盖。

### M1：根级 xmake 骨架与依赖自举

- 新增根 `xmake.lua` 和模块目录；
- 增加 mode、platform、arch 和 feature options；
- 接入 Go、Rust、Emscripten等可管理 host 工具；
- 实现 `xmake doctor`；
- latest xmake 版本写入构建日志。

### M2：高风险可行性原型

- Web：构建一个可运行的 Dora Web Player，并通过代表性浏览器 smoke test；
- Apple：构建 macOS App 和 iOS simulator App，验证资源、bundle 和启动；
- 任一原型无法达到旧构建行为时，先解决架构问题，不继续扩大迁移范围。

### M3：共享源清单和生成规则

- 建立唯一 engine/Love/Web source manifest；
- 迁移 tolua++ 生成规则，保证缺失生成文件时的 clean build 顺序；
- 迁移通用 include、define、warning 和逐文件选项；
- 过渡期自动检查 xmake 与旧 CMake/IDE 工程的源和关键参数差异。

### M4：桌面平台

- 完成 Linux、Windows、macOS Debug/Release；
- 完成运行和基础打包；
- 将对应 `build_*`、`build_lib_*`、`run_*` 脚本切换为 xmake 或删除；
- CI 默认路径切换为 xmake，但旧路径保留到运行时验收完成。

### M5：移动平台

- 完成 iOS device/simulator；
- 完成 Android 三 ABI 与 Gradle 打包；
- 完成 simulator/device/emulator/实体设备验证；
- 删除移动平台重复的 Native 构建描述。

### M6：Web 全量迁移

- 迁移全部 Web profile 和 fixture target；
- 通过所有静态检查与真实浏览器回归；
- 验证 Web Player、Love Player、pthread、音频、输入和发布包；
- 删除 Web/Emscripten CMake 描述。

### M7：打包、发布与 CI 收敛

- 将 AppImage、ZIP、Web stage、release artifact 生成接入 xmake task；
- CI 统一为 doctor/require/configure/build/test/package；
- 实际执行一次等价 tag 构建或 release dry run；
- 验证所有产物路径、命名、架构和包内容。

### M8：旧构建系统移除

- 删除 Dora 自有重复 CMake 描述；保留 Android 薄入口，由 xmake 生成实际构建图；
- 删除提交的 Dora Xcode/Visual Studio 工程；
- 删除失去职责的 shell/batch 脚本和 CI 安装步骤；
- 更新开发、打包和贡献文档；
- 全仓搜索旧路径、旧命令和废弃输出目录引用。

## 10. 验收门禁

每个平台只有同时满足以下条件才可标记为“完成”：

1. xmake latest 在干净环境完成依赖解析和 clean build；
2. Debug 与 Release 均构建成功；
3. 生成绑定文件预先删除后仍能正确重建；
4. 产物架构、宏、链接库、framework、资源和输出路径符合基线；
5. 对应 CI job 通过；
6. 真实运行环境 smoke test 通过；
7. 对发布平台，打包和包内容检查通过；
8. 旧构建入口移除后，全仓无有效引用；
9. 未吸收无关工作区改动。

平台专项运行时证据：

| 平台 | 最低运行时证据 |
| --- | --- |
| Linux | Native 启动 + AppImage 启动 |
| Windows | VM/实体机启动 + 输入/网络/资源 smoke |
| macOS | `.app` 启动 + Release ZIP/bundle 检查 |
| iOS | simulator 启动 + device 构建/签名检查 |
| Android | APK 安装和冷启动 + 输入与 Native 日志检查 |
| Web | HTTP 页面启动 + 图形/音频/输入/Love/pthread 浏览器回归 |

## 11. 风险与控制

| 风险 | 控制措施 |
| --- | --- |
| Web 编译成功但浏览器行为回退 | Web 原型先行；保留完整浏览器 fixture 和真实 HTTP 验证 |
| Apple bundle 或签名语义遗漏 | 对照旧工程设置；分别验证 Debug、Release、device、simulator |
| 过渡期双清单漂移 | 建立自动 parity 检查；每个平台验收后立即删除旧描述 |
| xmake task 退化成 shell 命令集合 | 编译逻辑必须使用 target/rule/package，task 只做编排 |
| latest xmake 行为变化 | 记录实际版本；全平台 CI、运行时测试和发布 dry run 作为兼容门禁 |
| 自动安装工具与系统工具混用 | host package 使用 `system = false`；doctor 输出实际路径和版本 |
| CI 通过但发行包失败 | 单独执行 tag 等价构建和包内容检查 |
| 清理时误删独立工程 | 只删除 Dora Native 自有工程；保留 .NET 与第三方 vendored 文件 |

## 12. 回退策略

- 每个平台在完成运行时验收前保留旧构建入口；
- 新旧构建产物使用不同目录，禁止互相复用中间文件；
- CI 在切换默认路径前保留一个短期 legacy 对照 job；
- 每个迁移 PR 只覆盖一个明确阶段或平台，可独立回退；
- 不在同一 PR 中同时迁移构建系统、升级依赖和修改运行时功能。

## 13. 完成定义

只有满足以下全部条件，项目才达到 xmake 单一 Native 构建定义：

- Dora 自有 Native 源清单与编译/链接规则仅维护在 xmake；Android Gradle 消费自动生成的 CMake 构建图，薄入口不重复维护这些规则；
- 所有受支持平台均从同一 xmake 源清单和规则构建；
- 可管理的 host 依赖由 xmake 自动安装，系统依赖由 doctor 明确诊断；
- CI、开发、测试和发布文档都以 xmake 为唯一 Native 入口；
- 旧 shell/batch 构建入口已删除或缩减为确有必要的外部生态包装；
- 全平台编译、运行、浏览器、设备和发行产物证据齐全。
