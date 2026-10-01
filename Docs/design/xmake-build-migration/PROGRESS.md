# Dora-SSR xmake 单一构建描述迁移进度

> 总体状态：本地构建迁移与旧系统清理收尾完成；桌面、Android、iOS、Web 与生成 IDE 已落地；远端 CI、干净新主机与生产发布门禁独立保留
> 更新日期：2026-10-01
> 方案文档：[PLAN.md](./PLAN.md)

## 状态说明

| 状态 | 含义 |
| --- | --- |
| ⬜ 未开始 | 尚未进入实现 |
| 🟡 进行中 | 已开始，但验收门禁尚未全部满足 |
| 🟠 受阻 | 存在明确阻塞项，当前不能继续 |
| ✅ 完成 | 实现和对应运行时/产物验收均已完成 |
| ➖ 不适用 | 经记录确认不需要实施 |

进度不能仅凭代码已提交或 CI 编译成功更新为“完成”；必须附上方案要求的运行时和产物证据。

## 1. 总览

| 阶段 | 状态 | 完成度 | 验收摘要 | 证据 |
| --- | --- | ---: | --- | --- |
| M0 基线冻结与验收清单 | 🟡 进行中 | 70% | 六平台命令/输出/发行包已形成基线；完整编译参数快照待补 | `BASELINE.md`、`xmake audit-manifests` |
| M1 根级 xmake 与依赖自举 | 🟡 进行中 | 95% | 根配置、feature options、Go/Rust/Emscripten 自举与 doctor 已验证；CI 日志待完成 | `xmake.lua`、`Projects/xmake/dependencies/host_tools.lua`、`Projects/xmake/packages/`、`Projects/xmake/tasks/doctor.lua` |
| M2 Web/Apple 可行性原型 | 🟡 进行中 | 90% | macOS 与 iOS simulator `.app` 已真实启动；Web Release 已通过浏览器初始化；VS/Xcode generator 均已贯通到 xmake 构建；后续交互断点已由用户豁免 | `Projects/xmake/engine.lua`、本表实施证据 |
| M3 共享源清单与生成规则 | 🟡 进行中 | 95% | engine manifest、host tolua++ 和统一引擎 target 已完成；Love/Web 清单及 fixtures 已迁入 Lua，旧 Web CMake 清单已移除；独立 clean checkout 仍待验收 | `Projects/xmake/manifests/engine.lua`、`Projects/xmake/rules/generated_lua.lua`、`Projects/xmake/web/` |
| M4 桌面平台迁移 | 🟡 进行中 | 95% | macOS、Linux arm64/x86_64 与 Windows x86 的 Debug/Release 均已构建并运行；macOS universal ZIP 与 Linux x86_64/ARM64 AppImage 已构建并启动；VS/Xcode 生成工程可构建 | `Projects/xmake/engine.lua`、`Projects/xmake/dependencies/native_runtime.lua`、`Projects/xmake/tasks/package.lua`、本表实施证据 |
| M5 移动平台迁移 | 🟡 进行中 | 95% | Android 已验收；iOS arm64 device/simulator 的 Debug/Release 构建、ZIP/IPA 和 ad-hoc 签名通过，模拟器 Debug/Release 已启动；生产签名、真机和 Intel 模拟器运行仍待发布验收 | `Projects/xmake/android/`、`Projects/xmake/ios/README.md`、本表实施证据 |
| M6 Web 全量迁移 | 🟡 进行中 | 95% | 主构建、core/preset/custom、pthread、Love probes、Rust、AudioWorklet 和打包已迁入 xmake；完整 preset 浏览器与正式 pthread Love Player 回归通过；授权 complex、实验 main-worker 和发布环境验收独立保留 | `Projects/xmake/web/`、`Projects/xmake/tasks/web.lua`、本表实施证据 |
| M7 打包、发布与 CI 收敛 | 🟡 进行中 | 80% | 各平台本地构建/打包入口已收敛到 xmake；iOS ZIP/IPA 与 Web profiles/pthread 包检查通过；对应 CI 描述已切换并通过静态校验，远端 CI、生产签名与 tag dry run 待完成 | `Projects/xmake/tasks/package.lua`、`.github/workflows/`、本表实施证据 |
| M8 旧系统移除 | ✅ 完成 | 100% | 旧手工工程、共享 CMake 与 17 个冗余依赖脚本已移除；入口、CI、文档与 IDE 生成已更新；跨平台构建/打包及 Xcode/MSBuild 实际调用通过 | `Projects/xmake/tasks/native.lua`、本表收尾证据 |

## 2. 已确认决策

| ID | 决策 | 状态 | 日期 | 备注 |
| --- | --- | --- | --- | --- |
| D01 | xmake 是唯一 Native 构建描述源 | ✅ | 2026-09-30 | C/C++/ObjC/ObjC++ 构建事实最终只在 xmake 中维护 |
| D02 | 使用 xmake latest，不固定版本 | ✅ | 2026-09-30 | 构建日志必须记录实际版本 |
| D03 | Go、Rust、Emscripten等可管理依赖由 xmake 自动安装 | ✅ | 2026-09-30 | 优先使用 host package 和 `system = false` |
| D04 | Gradle、Cargo、Go Modules、pnpm 保留 | ✅ | 2026-09-30 | xmake 负责统一编排，不重新实现生态工具 |
| D05 | Dora Xcode/VS 工程改为生成物，不提交 | ✅ | 2026-09-30 | .NET 和第三方 vendored 工程不在删除范围 |
| D06 | 大量构建 shell/batch 迁入 xmake target/rule/task | ✅ | 2026-09-30 | 独立 JS 测试继续保留 |
| D07 | 运行时和发布产物是完成门禁 | ✅ | 2026-09-30 | 不能仅凭静态检查或编译成功完成阶段 |
| D08 | 源文件扩展名必须表达真实语言 | ✅ | 2026-09-30 | 禁止用 `/TP`/`-x c++` 掩盖伪 C；改 `.cpp` 或修成真正 C；`.c` 在 Windows 保持 `/TC` |
| D09 | Android 采用 xmake → 真实 CMake target → Gradle/NDK 构建 | ✅ | 2026-09-30 | xmake 唯一维护源清单和依赖；保留薄 CMake 适配器，让 Studio 使用原生项目模型、构建与调试 |
| D10 | 后续迁移不再要求 IDE 交互断点验证 | ✅ | 2026-10-01 | 用户明确豁免；保留构建、产物和必要启动验证，不将豁免记为调试已验证 |

## 3. 当前资产基线

### 3.1 Native 构建描述

| 项目 | 当前状态 | 迁移目标 | 状态 |
| --- | --- | --- | --- |
| `Projects/CMake/DoraEngineSources.cmake` | 原共享清单已移除 | `Projects/xmake/manifests/engine.lua` | ✅ |
| `Projects/CMake/DoraGeneratedSources.cmake` | 原生成描述已移除 | `Projects/xmake/rules/generated_lua.lua` | ✅ |
| `Projects/CMake/DoraLoveSources.cmake` | Love 源清单 | `Projects/xmake/web/manifest.lua`，原文件已移除 | ✅ |
| `Projects/CMake/DoraWebLinkSources.cmake` | Web 链接源清单 | `Projects/xmake/web/manifest.lua`，原文件已移除 | ✅ |
| `Projects/Linux/CMakeLists.txt` | 原 CMake 与 makefile 已移除 | `Projects/xmake/engine.lua`、`Projects/xmake/dependencies/vendor.lua` | ✅ |
| `Projects/Android/Dora/app/CMakeLists.txt` | 已改为薄适配器，无手工 Native 清单 | `Projects/xmake/android/export.lua` 从 xmake target 导出真实 CMake graph | ✅ |
| `Projects/Web/CMakeLists.txt` | Web 主目标和测试目标 | `Projects/xmake/web/targets.lua` + prepare/runtime/task，原描述已移除 | ✅ |
| `Projects/Emscripten/CMakeLists.txt` | 旧 Emscripten 目标 | 已删除，正式 Player 合并到 `Projects/xmake/web/` | ✅ |
| macOS/iOS Xcode 工程 | 手工工程已移除，平台资源保留 | `xmake dora-ide` 生成/直接构建 | ✅ |
| Windows Dora solution/project | 手工工程已移除，RC/图标保留 | `xmake dora-ide` / `vsxmake` 生成 | ✅ |

### 3.2 第三方 xmake 资产

| 依赖 | 当前文件 | 目标动作 | 状态 |
| --- | --- | --- | --- |
| SDL2 | `Source/3rdParty/SDL2/xmake.lua` | 纳入根构建，清理外层重复脚本 | 🟡 |
| bgfx/shaderc | `Source/3rdParty/bgfx/xmake.lua` | 纳入根构建，保持 host/target 与平台选项 | 🟡 |
| Love | `Source/3rdParty/Love/xmake.lua` | 纳入根构建并复用唯一源清单 | 🟡 |
| Theora | `Source/3rdParty/theora/xmake.lua` | 纳入根构建 | 🟡 |
| Ogg | `Source/3rdParty/ogg/xmake.lua` | 纳入根构建 | 🟡 |
| LuaSocket | `Source/3rdParty/LuaSocket/xmake.lua` | 纳入根构建并处理平台/Web 差异 | 🟡 |

### 3.3 构建脚本盘点

当前 `Tools/build-scripts` 跟踪：23 个 `.sh`、10 个 `.bat`、37 个 `.mjs`、1 个 `.lua`。

| 分类 | 示例 | 目标 | 状态 |
| --- | --- | --- | --- |
| 依赖构建 | `build_lib_sdl2*`、`build_lib_bgfx*`、`build_lib_love*`、`build_lib_theora*` | xmake dependency targets/packages | ⬜ |
| 平台依赖汇总 | `build_lib_macos.sh`、`build_lib_android.sh`、`build_lib_windows.bat` | target dependency graph | ⬜ |
| 平台主构建 | `build_macos.sh`、`build_linux.sh`、`build_windows.bat`、`build_web.sh` | 标准 `xmake` build | ⬜ |
| 本地运行 | `run_macos.sh`、`run_linux.sh`、`run_windows.bat` | `xmake run` | ⬜ |
| 环境检查 | `check_build_env*`、`check_web_build_env.sh` | `xmake doctor` | ⬜ |
| 打包 | `package_appimage.sh`、Web package `.mjs` | xmake package task 调度 | ⬜ |
| 浏览器/契约测试 | `check_web_*.mjs`、`test_web_*.mjs` | 保留 JS，接入 `xmake test web` | ⬜ |

## 4. 阶段任务

### M0：基线冻结与验收清单

| ID | 任务 | 状态 | 完成标准 | 证据 |
| --- | --- | --- | --- | --- |
| M0.1 | 盘点跟踪的 CMake、xmake、IDE 工程和构建脚本 | ✅ | 清单写入 PLAN/PROGRESS | 2026-09-30 初始文档 |
| M0.2 | 记录所有平台 Debug/Release 命令和输出路径 | ✅ | 六个平台均有当前基线 | `BASELINE.md` 第 1–2 节 |
| M0.3 | 导出宏、链接库、framework、PCH 和逐文件参数 | ⬜ | 可自动对照新旧构建 | — |
| M0.4 | 记录发布 ZIP/APK/AppImage/Web 包结构 | ✅ | 有可复核清单或脚本 | `BASELINE.md` 第 3 节；现有 workflow/检查器 |
| M0.5 | 建立 source/option parity 检查 | 🟡 | 差异会使 CI 失败 | engine 580 项已由 `xmake audit-manifests` 强制检查；option parity 待补 |
| M0.6 | 决定 PR #129 的处置方式 | ✅ | 记录关闭、替代或复用范围 | 当前决策：xmake 为唯一构建描述，Android 保留由其生成的 CMake 后端；复用遗漏项审计结论，本轮未修改远端 PR |

### M1：根级 xmake 与依赖自举

| ID | 任务 | 状态 | 完成标准 | 证据 |
| --- | --- | --- | --- | --- |
| M1.1 | 创建根 `xmake.lua` 和模块目录 | ✅ | `xmake f` 可加载项目 | macOS arm64 Debug configure 通过 |
| M1.2 | 定义 debug/release、platform、arch 和 feature options | ✅ | 配置矩阵可查询 | `Projects/xmake/options.lua`；`xmake show` |
| M1.3 | 接入 Go host package | ✅ | 无系统 Go 时可完成安装并输出版本 | `system=false` 安装至 `~/.xmake/packages/g/go/1.27.1`；Windows VM 由 xmake 受管 Go/32 位 MinGW 从源码生成 x86 `wa.dll` |
| M1.4 | 接入 Rust/rustup host package | ✅ | 无系统 Rust 时可完成安装及目标添加 | `system=false` 安装 Rust/rustup；Windows VM 的 xmake target 自动安装 rustup host toolchain、添加 `i686-pc-windows-msvc` 并生成 Debug/Release `dora_runtime.lib` |
| M1.5 | 接入 Emscripten host package | ✅ | Wasm 配置可发现 emcc | `dora-emscripten` 6.0.0 由 xmake 安装；`dora-host-tools` 实际执行受管 `emcc --version` 成功 |
| M1.6 | 实现 `xmake doctor` | ✅ | 系统依赖报告含路径、版本和修复指引 | macOS arm64、Windows 11 ARM64、Ubuntu 24.04 ARM64 均已运行；Android 检查 SDK/NDK/CMake/build-tools，使用 Studio JBR 17 后 0 errors / 0 warnings |
| M1.7 | latest xmake 版本日志 | 🟡 | 本地和 CI 日志均可见 | `dora-build-info`/doctor 已输出；CI 尚未切换 |

### M2：高风险可行性原型

| ID | 任务 | 状态 | 完成标准 | 证据 |
| --- | --- | --- | --- | --- |
| M2.1 | xmake Web Player 原型 | ✅ | 浏览器可启动并通过代表性 fixture | 正式 Web targets 已替代旧原型；完整 preset Chrome 渲染/输入/网络/存储/音频及 1 reload 通过，core/custom smoke 通过 |
| M2.2 | xmake macOS App 原型 | ✅ | `.app` 资源完整且真实启动 | arm64 Debug 全量构建成功；资源、bundle ID、最低系统版本和签名均核验；应用进程真实启动并持续存活 10 秒 |
| M2.3 | xmake iOS simulator 原型 | ✅ | simulator 构建并启动 | arm64 Debug `.app` 安装到 iPhone 17 Pro / iOS 26.5 simulator；Dora PID 9334 active-visible，SDL UIKit window 与真实 UI 截图通过 |
| M2.4 | IDE generator 原型 | ✅ | Xcode/VS 生成工程可调用 xmake 构建；交互断点豁免 | Windows MSBuild 与 macOS xcodebuild 已调回 xmake 并成功构建；2026-10-01 用户豁免交互断点门禁 |
| M2.5 | 原型评审 | ⬜ | 明确继续、调整或停止迁移 | — |

### M3：共享源清单和生成规则

| ID | 任务 | 状态 | 完成标准 | 证据 |
| --- | --- | --- | --- | --- |
| M3.1 | 迁移 engine source manifest | 🟡 | 全平台只读取一个引擎源清单 | 580/580 路径、唯一性和存在性审计通过；统一 `Dora` target 已读取该清单，平台 NFD 实现由 target 定向替换 |
| M3.2 | 迁移 Love/Web manifests | ✅ | 平台扩展不复制通用清单 | `Projects/xmake/web/manifest.lua` 管理 portable Love/link/probe 清单，`targets.lua` 按 profile 过滤通用 engine manifest；运行时不读取 CMake；core/preset/custom 均已构建 |
| M3.3 | 迁移 tolua++ codegen rule | ✅ | 删除生成文件后 clean build 成功 | Windows 11 ARM64 host：xmake 编译静态 Lua 5.1/LFS 生成器；删除 5 个输出后全部重建，内容差异仅为既有生成时间戳；二次执行命中增量缓存 |
| M3.4 | 迁移通用 include/define/options | 🟡 | 与基线 parity 检查一致 | 首个 `Dora` target 已迁入公共 include、define 与 C/C++ 标准；完整自动 parity 待补 |
| M3.5 | 迁移逐文件编译选项 | 🟡 | Jolt、PCH 排除等均有自动检查 | Jolt 源已独立应用 no-RTTI/no-exception/FP-contract 选项；Windows PCH parity 待补 |

### M4：桌面平台

| ID | 任务 | 状态 | 完成标准 | 证据 |
| --- | --- | --- | --- | --- |
| M4.1 | Linux x86_64 | ✅ | Debug/Release 构建并启动 | Ubuntu 24.04 ARM64 + Rosetta VM 中完成 x86_64 Debug/Release 全量交叉构建；两份 ELF 均在 Xwayland 会话持续运行 10 秒并正常清理 |
| M4.2 | Linux aarch64 | ✅ | Release 构建并运行 | Ubuntu 24.04 ARM64 VM Debug/Release ELF 均已构建；Release 在 GDM Xwayland 会话完成 SoLoud/AgentStorage 初始化并持续存活 10 秒后正常清理 |
| M4.3 | Linux AppImage | ✅ | 包内容检查并真实启动 | x86_64 66 MiB 与 ARM64 65 MiB AppImage 均通过依赖闭包、Web IDE 资源和目标架构检查；x86_64 经 Rosetta、ARM64 以 GDM 普通用户运行，后者输出 `Dora Dora is ready!` 并持续运行 60 秒 |
| M4.4 | Windows x86 | ✅ | Debug/Release 构建并在 Windows 运行 | Windows 11 ARM64 VM 已用 VS x86 工具链完成 Debug/Release 全量编译、链接与多轮 10 秒启动 smoke；Rust/Wa runtime 改为 xmake 从跟踪源码生成后，Debug 与 Release 包暂存内容均再次启动 10 秒 |
| M4.5 | Windows VS 集成 | ✅ | `vsxmake` 工程可构建；交互断点豁免 | VS 2026 solution 与 Dora project 已生成，MSBuild 成功调用 xmake Release；用户豁免 IDE 断点验证 |
| M4.6 | macOS arm64/x86_64 | ✅ | Debug/Release 分架构通过 | arm64/x86_64 Debug/Release `.app` 均已构建；四项均通过架构/签名检查和真实启动 |
| M4.7 | macOS universal | ✅ | universal `.app` 启动并通过包检查 | x86_64/arm64 Mach-O、严格签名、ZIP 完整性与 LaunchServices 10 秒启动均通过 |

### M5：移动平台

| ID | 任务 | 状态 | 完成标准 | 证据 |
| --- | --- | --- | --- | --- |
| M5.1 | iOS arm64 device | ✅ | 构建、签名配置和 device 链接通过 | 2026-10-01 Debug/Release 的 Rust、Wa、vendor、Dora 均由 xmake 源码构建，生成 App 与 IPA；本地 ad-hoc 签名验证通过。生产证书、描述文件匹配和真机安装未验证 |
| M5.2 | iOS simulator | 🟡 | arm64/x86_64 所需配置与启动通过 | arm64 Debug/Release 的 Rust/Wa/vendor/Dora 均由 xmake 构建、打包，在 iPhone 17 Pro / iOS 26.5 安装启动并显示真实 UI；x86_64 Debug 已构建链接，运行仍待 Intel host；交互断点已豁免 |
| M5.3 | Android arm64-v8a | ✅ | APK 安装、冷启动和 smoke 通过 | 生成式 CMake 编译的新 Debug 与本地测试签名 Release APK 均安装、冷启动、渲染；Debug 触摸进入游戏，Release 新建对话框完整文本输入后取消，无 Native Fatal |
| M5.4 | Android armeabi-v7a | ✅ | Native 构建和 APK 包内容正确 | 真实 CMake graph 的 Debug/Release 构建通过，Rust 由 xmake 生成；APK/AAB 均含 ARM EABI5 引擎、SDL、共享 STL 与 Wa 库 |
| M5.5 | Android x86_64 | 🟡 | emulator 构建和启动通过 | x86_64 Native C/C++、Rust Debug/Release 与 gomobile AAR 构建并进入 APK；Apple Silicon emulator 不含 x86_64 QEMU，运行门禁待原生 x86_64 host 补齐 |
| M5.6 | Gradle/xmake 接口 | ✅ | 无手工复制步骤，增量构建正确 | Gradle 自动配置 xmake 并导出真实 CMake graph；Ninja 编译 C/C++，xmake 生成 Lua/Rust/Wa；不再暂存引擎 jniLibs；缺失 Wa AAR 的首次 Studio Sync 自举通过 |
| M5.7 | Android Studio Native 调试与 IDE 增量构建 | ✅ | IDE 中 C++ 源码行断点、符号/源码映射、调用栈，以及 Run/Debug 自动触发增量重建均通过 | 正式工程 Studio Run 构建并安装含临时 C++ probe 的 APK，设备包哈希与 IDE 产物一致；移除 probe 后 Studio Debug 自动重编，实际命中 `Director.cpp:395`，调用栈与变量可见；正式三 ABI Debug/Release 通过 |

### M6：Web 全量迁移

| ID | 任务 | 状态 | 完成标准 | 证据 |
| --- | --- | --- | --- | --- |
| M6.1 | Dora Web Player | ✅ | loader、package、preview 检查通过 | core/preset/custom Release 通过包结构与浏览器 smoke；preset 的完整渲染/输入/网络/存储/音频/1 reload 检查通过，unexpected browser errors=0 |
| M6.2 | Love Web Player | ✅ | graphics、shader、runtime fixture 通过 | xmake 单线程产物在 Chrome 154 通过 LoveNode runtime、graphics、shader 和 audio fixture（各 1 reload）；custom Player 的真实 LoveNode 初始化通过 |
| M6.3 | pthread/main worker | 🟡 | shared-memory profile 浏览器验证通过 | pthread Player/正式 Love Player 已构建；隔离内存检查通过；诊断版及无诊断 Release Love Player 的 import/start/stop/失败恢复通过；默认关闭的实验 main-worker 仅迁移实现，不声称已通过运行门禁 |
| M6.4 | AudioWorklet/音频 | ✅ | audio fixture 和状态测试通过 | 新 mixer 的 Node DSP（codec/filter/3D/control/lifecycle/memory isolation）通过；Chrome Worklet 的主线程阻塞、暂停/恢复、停止和关闭，在普通 HTTP 与 COOP/COEP 均通过；Love audio reload 与状态测试通过 |
| M6.5 | 输入与复杂项目 | 🟡 | mouse/touch/keyboard 和复杂项目通过 | preset Chrome 全套 keyboard/mouse/wheel、场景四象限 mouse/touch、多点触摸/cancel、Gamepad、IME/文件选择通过；没有下载或使用外部授权复杂项目 |
| M6.6 | Web 性能基线 | 🟡 | 无已确认的显著回退 | 本机 SwiftShader 空闲复验：cold 3730.9 ms / warm 983.6 ms、gzip 3507844 B，通过既有 5 秒门禁与 1 reload 内存检查；其他设备/正式发布基线仍待验收 |
| M6.7 | Web 发布包 | ✅ | HTTP 启动、资源和缓存行为通过 | 包结构、forbidden deps、preview、hash assets、HTTP 初始化、lazy assets、IDBFS 和 reload 检查通过；远端发布/CI 为 M7 门禁 |

### M7：打包、发布与 CI

| ID | 任务 | 状态 | 完成标准 | 证据 |
| --- | --- | --- | --- | --- |
| M7.1 | CI dependency bootstrap | 🟡 | xmake 自动解析 host tools | Windows/Linux/Android/iOS/Web jobs 已迁移到受管 host tools，Web 不再重复安装 SDK/Go/Rust/CMake；本机 iOS/Web 源码构建通过，远端 runner 的无缓存自举仍待验证 |
| M7.2 | CI platform jobs | 🟡 | Android/iOS/Linux/macOS/Web/Windows 全绿 | Windows/Linux/macOS/Android 主分支 Native job 与 Android tag job 描述已调用 xmake；Android NDK 26.1 显式安装、签名参数由 package task 传递；相关 YAML 经 `actionlint` 检查，远端 CI 与其他平台仍待验证 |
| M7.3 | AppImage package task | ✅ | 产物可启动，依赖检查通过 | x86_64/ARM64 均由 `xmake dora-package --platform=linux --arch=<arch> --mode=release` 产出并真实启动；按 host 缓存/重试下载 appimagetool、按 target 选择 runtime；AppDir 权限统一为普通用户可读 |
| M7.4 | macOS ZIP package task | ✅ | bundle、架构和签名状态正确 | `xmake dora-package --platform=macosx --mode=release`；universal executable、ad-hoc deep signing、ZIP 内容与真实启动通过 |
| M7.5 | Windows ZIP package task | ✅ | exe、DLL、Assets 布局正确 | Windows 11 ARM64 VM 运行 ARM64 原生 xmake，从源码构建 x86 Rust/Wa runtime 后打包 Release；58 MiB ZIP 通过 `unzip -tq`，根目录含 exe、DLL、Web runtime、dora-wa 与 Love shader，包暂存目录在 Windows 启动 10 秒，无多余前缀或 macOS 元数据 |
| M7.6 | Android release package | 🟡 | APK/AAB 与签名流程正确 | 正式 xmake→CMake 后端复验：三 ABI 未签名 APK、本地测试签名 APK/AAB 均成功；签名验证、ARM64 Release 冷启动/文本输入通过；生产签名和远端分发待补 |
| M7.7 | Web release package | 🟡 | 包内容和浏览器启动通过 | core/preset/custom、pthread 包由统一 task 暂存；包结构/依赖泄漏/preview、core/custom HTTP smoke、完整 preset 浏览器及正式 pthread Love Player 通过；远端 CI/发布尚未运行 |
| M7.8 | tag 等价 dry run | ⬜ | 所有 release artifact 成功生成 | — |
| M7.9 | iOS ZIP/IPA package | 🟡 | SDK/mode 隔离、签名、包结构和设备运行 | arm64 simulator/device Debug/Release App 与 ZIP/IPA 均成功；ad-hoc 签名和模拟器启动通过；生产身份、描述文件与真机分发仍待发布门禁 |

### M8：旧系统移除

| ID | 任务 | 状态 | 完成标准 | 证据 |
| --- | --- | --- | --- | --- |
| M8.1 | 删除手工维护的 Dora CMake 描述 | ✅ | Android 只保留薄适配器/生成物；其余平台移除重复描述 | Linux 与共享 CMake 两份清单已删除；审计仅检查 canonical manifest，不保留第二份源清单 |
| M8.2 | 删除 Dora Xcode 工程 | ✅ | 由 xmake 生成且文档已更新 | `dora-ide` 生成 macOS/iOS simulator 工程，两者 xcodebuild Debug 通过 |
| M8.3 | 删除 Dora Windows solution/project | ✅ | 由 `vsxmake` 生成且文档已更新 | 官方原生 ARM64 xmake 3.1.1 生成成功，MSBuild 实际调用 xmake 并链接成功；RC 资源与 PE32 产物通过 |
| M8.4 | 删除冗余 shell/batch | ✅ | 全仓无有效引用，保留项有理由 | 移除 16 个 build_lib 脚本及旧 Cargo target helper；平台入口与 tolua wrappers 只转发 xmake，保留独立测试、资源生成和 Wa source sync |
| M8.5 | 清理 CI 依赖安装 | ✅ | 不重复安装 Go/Rust；Android 保留 Gradle 所需 CMake | Docs/UI/共享 Web 资产及 macOS release 的遗漏已收口；全 workflows actionlint 通过；远端执行单独待验收 |
| M8.6 | 更新开发和打包文档 | ✅ | 所有用户路径以 xmake 为入口 | 双语开发/游戏打包教程及 engine skill 引用同步；两种语言 Docusaurus production build 通过 |
| M8.7 | 全仓旧路径审计 | ✅ | 旧命令、旧输出目录和旧工程无残留 | 活跃入口无旧工程依赖；设计历史记录与旧 ignored build cache 路径仅作历史证据保留；.NET/第三方工程不在删除范围 |

## 5. 平台验收矩阵

| 平台 | Configure | Debug | Release | Runtime | Package | CI | 总状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Linux x86_64 | ✅ | ✅ | ✅ | ✅ | ✅ | ⬜ | 🟡 |
| Linux aarch64 | ✅ | ✅ | ✅ | ✅ | ✅ | ⬜ | 🟡 |
| Windows x86 | ✅ | ✅ | ✅ | ✅ | ✅ | ⬜ | 🟡 |
| macOS arm64 | ✅ | ✅ | ✅ | ✅ | ✅ | ⬜ | 🟡 |
| macOS x86_64 | ✅ | ✅ | ✅ | ✅ | ✅ | ⬜ | 🟡 |
| macOS universal | ✅ | ➖ | ✅ | ✅ | ✅ | ⬜ | 🟡 |
| iOS simulator | ✅ | ✅ | ⬜ | ✅ | ➖ | ⬜ | 🟡 |
| iOS device | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Android arm64-v8a | ✅ | ✅ | ✅ | ✅ | ✅ | ⬜ | 🟡 |
| Android armeabi-v7a | ✅ | ✅ | ✅ | ➖ | ✅ | ⬜ | 🟡 |
| Android x86_64 | ✅ | ✅ | ✅ | ⬜ | ✅ | ⬜ | 🟡 |
| Web single-thread | ✅ | ⬜ | ✅ | 🟡 | ⬜ | ⬜ | 🟡 |
| Web pthread | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |

## 6. 当前风险与阻塞

| ID | 类型 | 描述 | 状态 | 缓解措施 |
| --- | --- | --- | --- | --- |
| R01 | 高风险 | Web CMake 包含大量 profile、fixture 和链接选项 | 开放 | M2 先做可运行原型，M6 才全量迁移 |
| R02 | 高风险 | Apple bundle、资源、签名和 IDE generator 语义可能遗漏 | 缓解中 | macOS/iOS 原型和旧工程设置对照；Xcode 生成工程已完成 Release 构建与运行验证 |
| R03 | 中风险 | 过渡期 xmake 与旧构建描述并存会漂移 | 开放 | 自动 parity 检查，平台验收后立即删除旧路径 |
| R04 | 中风险 | latest xmake 变化可能首先影响 generator 或跨平台工具链 | 已接受 | 记录版本，以全平台 CI 和运行时门禁兜底 |
| R05 | 中风险 | 自动安装 Rust/Go 与系统版本混用 | 缓解中 | host package 使用 `system = false`，doctor 输出实际路径；macOS runtime target 固定使用受管 rustup 的 Cargo proxy，避免独立 Rust package 看不到交叉目标标准库 |
| R06 | 中风险 | 迁移脚本时把测试逻辑错误重写为 Lua | 开放 | JS 测试保留，xmake 只调度 |
| R07 | 已决策 | PR #129 与统一构建描述方向需协调 | 已处理 | 使用 xmake 单一描述，Android 保留生成式 CMake；复用 PR 审计结论，远端 PR 未修改 |
| R08 | 中风险 | vendored xmake 描述原先未覆盖 SDL2 Linux，且第三方目标跨平台实编译状态不一致 | 缓解中 | 已补 Linux 源集和 Wayland 协议生成；继续在 Linux/Windows VM 做逐目标实编译 |
| R09 | 中风险 | xmake-repo 的 Emscripten 6.0.0 间接源码构建 Python 3.14.3，在 Xcode 27 SDK 下因 `dup3`/`pipe2` availability + `-Werror` 失败 | 已缓解 | 仓库内 `dora-emscripten` 包仍从官方 emsdk 6.0.0 安装，但以 host Python 直接运行 emsdk，避免构建无关的 Python 副本；受管 emcc 已验证 |
| R10 | 中风险 | 历史工程可能用编译器参数把 `.c` 当 C++，掩盖扩展名与真实语言不一致 | 已缓解 | 已禁止 `/TP` 绕过并在 Windows 对 `.c` 保持 `/TC`；Xrt wrapper 已通过 Clang C11 契约测试，MSVC C11 强制重编记录为 `/TP=0`、`/TC=31` |
| R11 | 中风险 | macOS 上遗留 `ANDROID_NDK_HOME=ndk-bundle` 会选择已无法稳定运行的 GCC 4.9 ARM archiver | 已缓解 | Android package task 优先使用 versioned NDK 26.1.10909125；其 LLVM archiver已完成 armeabi-v7a 全量归档与 APK 打包 |
| R12 | 中风险 | 源树中预生成的 macOS Rust/Go 静态库可能只有单一架构，导致 x86_64/universal 链接失败 | 已缓解 | `dora-rust-runtime`/`dora-wa-runtime` 按 target arch/mode 从源构建薄 archive，Dora 只链接 `build/runtime` 产物；universal 仅在最终 app 层合并 |
| R13 | 中风险 | Linux 交叉打包时若按 target 架构下载 appimagetool，宿主无法执行该工具 | 已缓解 | appimagetool 按 host 架构下载，并通过 `ARCH=<target>` 选择 AppImage runtime；ARM64 host 生成并启动 x86_64 AppImage 已验证 |
| R14 | 环境限制 | Apple Silicon Android Emulator 仅携带 aarch64/armel QEMU，不能启动 x86_64 system image | 开放 | x86_64 `.so` 已完成 Debug/Release 构建和 APK 结构验证；运行门禁必须在原生 x86_64 host/emulator 完成，不以 ARM64 结果替代 |
| R15 | 高风险 | 本地已有但未跟踪的 Rust/Wa 预构建库会掩盖 clean checkout 构建缺口 | 缓解中 | Windows 与 Android Rust/Wa 已由 xmake 从跟踪源码生成；Android 三 ABI Debug/Release 重新链接、打包，ARM64 模拟器已启动；iOS arm64/x86_64 simulator Debug 已从源码生成并链接，arm64 已启动；iOS device/Release 和隔离 clean checkout 仍需验证 |
| R16 | 中风险 | Android Studio 的项目模型与一键重建可能遗漏 Native 输入 | 已缓解 | 正式 xmake→CMake graph、Gradle Wa 依赖与 CMake Lua/Rust 准备任务已接入；Studio Sync/Run/Debug、源码 probe 重建安装、行断点与调用栈均通过；原手工 Android CMake 清单已替换 |

当前没有达到“受阻”状态的阶段；尚未开始实现不视为阻塞。

## 7. 下一步

按顺序执行：

1. Android 正式生成式接入已完成 Studio Sync/Run/Debug 门禁；接下来将 iOS device/Release 的 Rust/Wa 输入纳入 xmake 自举并验证；Android 在原生 x86_64 host 补 emulator 运行，补生产签名/分发验收；对移动平台做隔离 clean checkout 验收；
2. 接入 Web 代表性 fixture，并补齐 loader/package checker；
3. IDE 交互断点验证已由用户豁免，不再作为后续迁移工作；
4. 运行远端全平台 CI 与 tag 等价 dry run；Linux 两架构 AppImage、Windows ZIP 已有本地 VM 验收，不替代远端结果。

## 8. 实施证据

### 2026-09-30 / M1.1–M1.7、M3.1

| 环境 | xmake | 执行与结果 | 未验证项 |
| --- | --- | --- | --- |
| macOS arm64 / Xcode 27 | 3.0.8+20260323 | `xmake f -c -y -p macosx -a arm64 -m debug`；managed Go 1.27.1、Rust/Cargo 1.96.1；`doctor --platform=host` 0 error/0 warning；manifest 580/580 | 引擎 target、App bundle 和运行时 |
| Windows 11 ARM64 VM / VS 2026 x86 toolchain | 3.1.1 ARM64 | `xmake f -c -y -p windows -a x86 -m debug`；managed Go 1.27.1、Rust/Cargo 1.96.1；doctor 0 error/1 optional MSBuild warning；manifest 580/580 | 引擎 target、EXE 和运行时 |
| Ubuntu 24.04 ARM64 VM / GCC 13.3 | 3.1.1+20260930 | `xmake f -c -y -p linux -a arm64 -m debug`；managed Go 1.27.1、Rust/Cargo 1.96.1；doctor 0 error/0 warning；manifest 580/580 | 引擎 target、ELF 和运行时 |

Windows-on-ARM 必须使用原生 ARM64 xmake；x64 xmake 在仿真层中会把 host package 解析为 x64，导致其安装的 Rust 工具链无法运行。Linux VM 中 `/usr/bin/xmake` 仍是 2.8.7，因此本轮显式使用 `/usr/local/bin/xmake` 的 latest 构建。

### 2026-09-30 / vendored dependency graph

环境：macOS arm64，xmake 3.0.8+20260323，Debug。

执行命令：`xmake build SDL2`、`xmake build bgfx`、`xmake build love`、`xmake build theoradec`。

结果：全部编译并归档成功；产物位于 `build/macosx/arm64/debug/`，包括 `libSDL2.a`、`libbgfx.a`、`liblove.a` 和 `libtheoradec.a`。编译仅出现第三方源码在 Xcode 27 下的弃用/转换警告。

运行时验证：尚未接入 Dora 引擎 target，因此本条只证明 vendored 目标已进入根 xmake 构建图，不计为平台运行时完成。

### 2026-09-30 / M3.3 host codegen

环境：Windows 11 ARM64 VM，原生 xmake 3.1.1，项目目标为 Windows x86 Debug。

执行命令：`xmake build dora-lua-bindings`；随后删除 `LuaBinding.cpp`、`LuaBindingWeb.cpp`、`LuaCode.cpp`、`LuaCodeWeb.cpp`、`TealCompiler.cpp` 并再次执行相同命令。

结果：xmake 直接编译 Lua 5.1、LuaFileSystem 和 `Projects/xmake/tools/tolua_main.c`，无需 `build.bat`、`lua51.dll` 或 `lfs.dll`；五个文件均从空缺状态重建成功。与备份逐行比较，仅生成器原有的日期行变化；Windows 换行已归一化为 LF。紧接着的无变更执行未再次运行生成器，证明依赖缓存生效。

### 2026-09-30 / M1.5 Emscripten 自举

环境：macOS arm64，xmake 3.0.8+20260323，Wasm Release 配置。

执行命令：`xmake f -c -y -p wasm -a wasm32 -m release`、`xmake build dora-host-tools`。

结果：仓库内 `dora-emscripten` package 从官方 emsdk 6.0.0 源归档安装，以现有 host Python 完成 `emsdk.py install/activate`；`dora-host-tools` 在 xmake package 环境中成功执行 `emcc --version`。这避免了上游 xmake-repo recipe 为 Emscripten 间接源码构建 Python 3.14.3 时与 macOS 26.6/Xcode 27 SDK 的 availability 冲突。

未验证项：Web 引擎 target、链接产物和浏览器运行时仍属于 M2.1/M6，不因工具链可发现而视为完成。

### 2026-09-30 / Windows vendored SDL2

环境：Windows 11 ARM64 VM，原生 xmake 3.1.1，VS 2026 x86 工具链，Windows x86 Debug。

执行命令：`xmake build SDL2`。

结果：vendored SDL2 目标完成实际编译和归档，生成 `SDL2.lib`；耗时约 64.7 秒。该结果只覆盖第三方库层，不代表 Windows 引擎 EXE 或运行时通过。

### 2026-09-30 / M2.2、M4.6 macOS arm64 Debug

环境：macOS arm64，Xcode 27，xmake 3.0.8+20260323，Debug。

执行命令：`xmake f -c -y -p macosx -a arm64 -m debug`、`xmake build Dora`、`xmake build --linkonly Dora`、`codesign --verify --deep --strict --verbose=2 build/macosx/arm64/debug/Dora.app`、`open -n build/macosx/arm64/debug/Dora.app`。

结果：统一 `Dora` target 完成 580 项引擎源、SDL2、bgfx、Love、Theora 及生成绑定的全量编译和链接，生成原生 arm64 `Dora.app`。bundle identifier 为 `IppClub.DoraSSR`，Info.plist 最低系统版本和 Mach-O `minos` 均为 12.0；重新链接后深度严格签名校验通过。

产物：`build/macosx/arm64/debug/Dora.app`；`Contents/Resources` 含 `Audio`、`Doc`、`Font`、`Image`、`Script`、`Shader`、`dora-wa`、`www`、`LICENSES`、`gamecontrollerdb.txt`、`AppIcon.icns` 与 `Assets.car`。

运行时验证：通过 LaunchServices 启动该 bundle，精确匹配的 Dora 进程连续存活 10 秒后由验证脚本终止；未触碰机器上另一个既有 Dora 进程。

未验证项：macOS x86_64、universal、ZIP 包内容与 CI 仍待完成，因此 M4.6 保持进行中。

### 2026-09-30 / M4.6 macOS arm64 Release

环境：macOS arm64，Xcode 27；全量构建使用 xmake 3.0.8+20260323，随后升级至当前稳定版 3.1.1+20260827 做增量复验；Release。

执行命令：`xmake f -c -y -p macosx -a arm64 -m release`、`xmake build Dora`、`codesign --verify --deep --strict --verbose=2 build/macosx/arm64/release/Dora.app`、`open -n build/macosx/arm64/release/Dora.app`。

结果：Release 全量编译、链接和 bundle 生成成功，耗时约 207 秒；可执行文件为 arm64 Mach-O，bundle identifier 为 `IppClub.DoraSSR`，深度严格签名校验通过。Homebrew 升级到 xmake 3.1.1 后，相同配置的增量复验 3.5 秒完成且无重建错误。

运行时验证：通过 LaunchServices 启动精确 Release bundle，PID 33236 连续存活 10 秒后由验证命令终止；未触碰其他 Dora 进程。

未验证项：macOS x86_64、universal、ZIP 包结构和 CI。

### 2026-09-30 / M2.1、M6.1 Web 单线程 Release

环境：macOS arm64 host，xmake 3.0.8+20260323，受管 Emscripten 6.0.0，headless Chrome。

执行命令：`xmake f -c -y -p wasm -a wasm32 -m release`、`xmake build Dora`；随后从 `build/wasm/wasm32/release` 启动 HTTP 服务并用 headless Chrome 打开入口页。

结果：统一 `Dora` target 完成全量编译和链接；生成约 24 KiB HTML、830 KiB JavaScript、80 MiB Wasm 和 39 MiB data。浏览器中 loading 元素正常隐藏，canvas 尺寸与 cursor 已由运行时设置，未出现 JavaScript exception、Wasm abort 或 Emscripten 启动失败。

运行时验证：该结果证明浏览器已进入引擎初始化，不等同于图形、音频、输入、Love、pthread 或复杂项目 fixture 全部通过；黑色 canvas 仅作为启动 smoke，不作为渲染验收。

未验证项：现有 Web checker/package 流程接入、代表性 fixture、pthread、AudioWorklet、输入、复杂项目和发布包缓存行为。

### 2026-09-30 / M4.2 Linux ARM64 Debug

环境：Ubuntu 24.04 ARM64 VM，GCC 13.3，xmake 3.1.1+20260930，GDM Xwayland `DISPLAY=:1024`。

执行命令：`/usr/local/bin/xmake f -c -y -p linux -a arm64 -m debug`、`/usr/local/bin/xmake build Dora`；以桌面会话用户启动生成的 ELF 并观察 10 秒。

结果：生成原生 AArch64 ELF，`ldd` 所列动态依赖均可解析。运行时完成 EGL/Mesa、BGFX、SoLoud SDL2 静态后端和 AgentStorage 初始化，进程持续存活 10 秒后由 smoke 脚本终止并正常清理。

产物：VM 临时工作区的 `build/linux/arm64/debug/Dora`。

当时未验证项：Linux x86_64、AppImage 内容与启动；后续已在 M4.1/M4.3 完成，不影响本条 ARM64 Debug 证据的独立性。

### 2026-09-30 / M4.2 Linux ARM64 Release

环境：Ubuntu 24.04 ARM64 VM，GCC 13.3，xmake 3.1.1+20260930，GDM Xwayland `DISPLAY=:1024`。

执行命令：`/usr/local/bin/xmake f -y -p linux -a arm64 -m release`、`/usr/local/bin/xmake build Dora`；以 GDM 桌面会话用户和 dummy SDL 音频后端运行 10 秒。

结果：Release 全量编译和链接成功，耗时约 859 秒。生成约 101 MiB 的原生 AArch64 ELF；启动日志确认 SoLoud 使用 SDL2 static backend 完成初始化、AgentStorage 数据库完成初始化，10 秒观察期内进程持续存活，随后收到 timeout 的 TERM 并完整执行引擎清理。

运行时验证：smoke 返回预期的 `124`（由 10 秒 timeout 结束），日志无崩溃或动态库缺失；这同时验证 Release 输出目录需要向桌面会话用户开放执行权限，测试脚本已显式处理。

当时未验证项：Linux x86_64、AppImage 内容与启动；后续已在 M4.1/M4.3 完成。

### 2026-09-30 / M2.3、M5.2 iOS arm64 simulator Debug

环境：macOS arm64 host，Xcode 27 / iPhoneSimulator 27.0 SDK，iPhone 17 Pro 模拟器（iOS 26.5），xmake 3.0.8+20260323。

执行命令：`xmake f -c -y -p iphoneos -a arm64 --appledev=simulator -m debug`、`xmake build Dora`、`xcrun simctl install booted build/iphoneos/arm64/debug/Dora.app`、`xcrun simctl launch booted IppClub.DoraSSR`。

结果：统一 target 完成全量编译、链接和 `Dora.app` 生成。补齐了 iOS/模拟器专用 host codegen、NFD 排除、SDL framework 边界与 `Security.framework`；产物为 arm64 simulator Mach-O，bundle identifier 为 `IppClub.DoraSSR`，资源 bundle 约 263 MiB。

运行时验证：CoreSimulator 日志确认 launch 成功、PID 9334 处于 `running-active-Visible`，SDL UIKit window 成为 key window；运行截图 `build/ios-xmake-running.png` 显示 Dora 本地作品界面和可用的中文 UI。

兼容性说明：旧 Xcode 工程声明 iOS 13.0；Xcode 27 对该最低版本发出 libc++ 不再支持警告，并在当前 simulator Mach-O 中记录 `minos 14.0`。本轮未主动提升项目最低版本，device/旧系统兼容性需在发布门禁中用受支持 Xcode 版本继续验证。

未验证项：simulator x86_64、iOS device 构建/签名和 Release。

### 2026-09-30 / M4.4 Windows x86 Debug 与真实 C 验证

环境：Windows 11 ARM64 Parallels VM，原生 ARM64 xmake 3.1.1，Visual Studio 2026 x86 target toolchain。

执行命令：`xmake f -y -p windows -a x86 -m debug`、`xmake build Dora`；随后在最新语言配置下强制重编 `dora-tolua` 并记录 verbose MSVC 命令，再启动 `Dora.exe --asset Assets` 观察 10 秒。

结果：统一 target 完成 Windows x86 Debug 全量编译和链接，生成 `Dora.exe` 并复制 `wa.dll`。为匹配既有工程修正了 Debug 静态 runtime 与 iterator ABI；LuaSocket 的内部 `io.h` 改为无系统头冲突的 `luasocket_io.h`。真实 C 门禁中 31 个 `.c` 单元均以 `-std:c11 /TC` 编译，日志统计 `/TP=0`、`/TC=31`；`XrtNetwork.c` 另由 Clang C11 契约测试和完整 Windows target 构建覆盖。

运行时验证：最新 overlay 下两次启动均在 10 秒观察窗口内持续存活，验证脚本随后终止进程；`Dora.exe` 和 `wa.dll` 均存在于 `build/windows/x86/debug/`。

未验证项：输入/网络交互式 fixture、ZIP 包和 `vsxmake` 调试工程。

### 2026-09-30 / M4.4 Windows x86 Release

环境：Windows 11 ARM64 Parallels VM，原生 ARM64 xmake 3.1.1，Visual Studio 2026 x86 target toolchain，Release。

执行命令：`xmake f -y -p windows -a x86 -m release`、`xmake build Dora`；随后运行 `Dora.exe --asset Assets` 观察 10 秒。刷新最终 overlay 后再次增量构建并重复启动。

结果：Release 全量编译和链接成功，耗时约 1672 秒，生成 `Dora.exe` 与 `wa.dll`。最终 overlay 增量复验重编 SDL2、重建 host `dora-tolua.exe` 并重链 Dora，36.6 秒完成；SDL 已使用 `/utf-8`，不再出现此前的 C4819 源码编码警告，LOVE Box2D 也不再向 MSVC 传入无效 `-std:c++11`。

运行时验证：全量结果和最终 overlay 结果分别启动，PID 6248 与 8088 均在 10 秒窗口后仍存活，再由 smoke 脚本终止。

未验证项：交互式输入/网络 fixture、ZIP 包和 `vsxmake` 调试工程。

### 2026-09-30 / M2.4、M4.5 Windows VS generator

环境：Windows 11 ARM64 VM，xmake 3.1.1，Visual Studio 2026 Community / MSBuild 18.6.3，目标架构 x86。

执行命令：`xmake project -k vsxmake -m "debug,release" -a x86 <output>`；再以 MSBuild 对生成的 `Dora.vcxproj` 执行 `Build /p:Configuration=release /p:Platform=x86`。

结果：生成 `Dora-SSR.sln`、Dora 与全部依赖的 `.vcxproj`、filters 和 custom targets。MSBuild 的 `_XmakeConfig` 和 `_XmakeBuild` 明确回调项目根 xmake，Release 增量构建 3.1 秒完成，MSBuild 总计 0 warning / 0 error。

未验证项：Visual Studio GUI 内源码浏览、断点命中与调试启动。

### 2026-09-30 / M2.4 macOS Xcode generator

环境：macOS arm64，xmake 3.1.1+20260827，Xcode 27，Release。

执行命令：`xmake project -k xcode -m 'debug,release' -a arm64 build/xcode-final`；随后执行 `xcodebuild -project build/xcode-final/Dora-SSR.xcodeproj -target Dora -configuration release ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO build`。

结果：生成的 `Dora-SSR.xcodeproj` 含 23 个可浏览 target、Debug/Release 配置和对应 schemes。xmake 3.1.1 的 Xcode generator 原生不支持 `object`/`phony` product type；项目现仅在 IDE 元数据生成进程中将它们映射为 `static`/`binary`，生成工程的 shell phase 启动新 xmake 进程后仍恢复真实 `object`/`phony` 语义。常规 `xmake show` 已复核 `openmpt` 为 `object`、`dora-lua-bindings` 为 `phony`。

构建与运行时验证：`xcodebuild` 的 `Xmake Build` phase 明确执行 xmake configure/build，完成 arm64 Release 全量构建，xmake 用时约 197 秒，最终 `** BUILD SUCCEEDED **`。生成目录中的 `Dora.app` 保留完整资源、`IppClub.DoraSSR` bundle identifier 和 arm64 Mach-O；LaunchServices 启动 PID 42031，连续存活 10 秒后由验证命令终止。

未验证项：Xcode GUI 内断点命中、Debug scheme 启动与 iOS 生成工程；因此 M2.4 保持进行中。

### 2026-09-30 / M5.3–M5.6 Android Debug 三 ABI 与运行时

环境：macOS arm64 host；全量构建使用 xmake 3.0.8+20260323，并由当前稳定版 3.1.1+20260827 做三 ABI 增量复验；Android NDK 26.1.10909125 / API 28，Android Studio JBR；Android 14 ARM64 emulator。

执行命令：`xmake dora-package --platform=android --mode=debug`；随后使用 `aapt dump badging`、`unzip -l` 和 `file` 检查 APK，再以 `adb install -r`、`am force-stop`、`am start -W` 完成冷启动。

结果：task 依次构建 armeabi-v7a、arm64-v8a、x86_64，自动将 `libmain.so`/`libSDL2.so` 暂存到 Gradle `jniLibs` 输入并调用 wrapper 生成 `app-debug.apk`，无手工复制。升级到 xmake 3.1.1 后相同任务约 18 秒完成三 ABI 增量复验，APK SHA-256 保持 `60e0a3c1b354ff57782f19b4cbddd2e7185f74d2ab7c53a5c0623f3607e319a1`。APK 的 `minSdkVersion` 为 28；三个 `libmain.so` 分别被识别为 ARM EABI5、AArch64 和 x86-64 ELF。

兼容性修正：旧 `ANDROID_NDK_HOME` 指向 `ndk-bundle`，其 GCC 4.9 `arm-linux-androideabi-ar` 会在当前 Apple Silicon/macOS 上触发 libc++ 初始化终止。package task 现优先使用 versioned NDK 26.1 的 `llvm-ar`；armeabi-v7a 在该工具链下全量构建和归档通过，并保留真正的 C11/C++ 编译模式。

运行时验证：APK 在 ARM64 emulator 冷启动，`MainActivity` 为 top resumed activity，PID 在 10 秒观察后仍存活；logcat 出现 `Dora is ready!` 且无 Native abort/FATAL。截图 `build/android-xmake-running.png` 显示本地项目页；ADB 触摸点击 Play 后 `build/android-xmake-play.png` 显示游戏战斗画面，证明触摸分发、Native 渲染和打包资源可用。

未验证项：x86_64 emulator 启动、Android Release APK/AAB、发布签名、文本输入和 CI。

### 2026-09-30 / M4.6–M4.7、M7.4 macOS x86_64 与 universal ZIP

环境：Apple Silicon macOS host，Rosetta 2，Xcode 27，xmake 3.1.1+20260827，Release。

首次直接切换到 x86_64 后，C/C++ 全量编译到达链接阶段，但源树中的 `Source/Rust/lib/macOS/libdora_runtime.a` 与 `Source/3rdParty/Wa/Lib/macOS/libwa.a` 均只有 arm64 slice。迁移没有通过忽略架构或复用错误 archive 绕过，而是新增 `dora-rust-runtime` 与 `dora-wa-runtime`：前者使用 xmake 受管 rustup/Cargo 按 `x86_64-apple-darwin` 或 `aarch64-apple-darwin` 构建，后者使用受管 Go 按 `GOARCH=amd64/arm64`、`-buildmode=c-archive` 构建，输出统一落在 `build/runtime/macosx/<arch>/<mode>/`。Dora 不再读取这两份忽略在源树中的预生成 macOS archive。

分架构执行命令：`xmake f -c -y -p macosx -a x86_64 -m release`、`xmake build Dora`。结果：两份 x86_64 runtime archive 的 `lipo -info` 均为 x86_64；Dora 完成链接并生成原生 x86_64 Mach-O。严格深度签名校验通过，经 LaunchServices/Rosetta 启动的 PID 50786 连续存活 10 秒后由验证命令终止。

打包执行命令：`xmake dora-package --platform=macosx --mode=release`。task 独立构建 arm64 与 x86_64 app，以 `lipo` 合并最终可执行文件，复制资源后进行 ad-hoc deep signing，并用 `ditto` 生成 `build/package/macosx/release/dora-ssr-macos-universal.zip`。

产物与运行时验证：`build/package/macosx/release/Dora.app/Contents/MacOS/Dora` 的架构为 `x86_64 arm64`；`codesign --verify --deep --strict` 与 `unzip -tq` 均通过。ZIP 含主可执行文件、`Info.plist`、Web Player `runtime.json` 与 Love shader 等代表性资源。Universal app 经 LaunchServices 启动后 PID 52270 连续存活 10 秒，再由验证命令终止。

补充 Debug 验证：`xmake f -c -y -p macosx -a x86_64 -m debug && xmake build Dora` 完成全量构建，耗时约 105 秒。`Dora.app` 为 x86_64 Mach-O，严格深度签名校验通过；LaunchServices/Rosetta 启动 PID 56696，连续存活 10 秒后由验证命令终止。至此 M4.6 的 arm64/x86_64 Debug/Release 分架构门禁全部完成。

边界：本地包使用 ad-hoc 签名；Developer ID 签名、公证和 CI 发布仍属于 M7 后续门禁。

### 2026-09-30 / M4.1、M4.3、M7.3 Linux x86_64 与 AppImage

环境：Ubuntu 24.04 ARM64 Parallels VM，Rosetta for Linux，GCC 13.3 x86_64 cross toolchain，GDM Xwayland `DISPLAY=:1024`，xmake 3.1.1+dev.a99b04b47。

构建执行命令：`XMAKE_ROOT=y PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig /usr/local/bin/xmake f -c -y -p linux -a x86_64 -m <debug|release> --cross=x86_64-linux-gnu-`、`/usr/local/bin/xmake build Dora`。Debug 与 Release 全量构建分别耗时 466.433 秒和 418.952 秒。两份产物均为 x86-64 PIE ELF，解释器为 `/lib64/ld-linux-x86-64.so.2`；`lddtree -l` 的依赖全部解析为 x86_64 运行库。

受管运行时：`dora-rust-runtime` 使用 xmake 受管 rustup/Cargo 和 `x86_64-unknown-linux-gnu` target 生成 `libdora_runtime.a`，`dora-wa-runtime` 使用受管 Go、`GOOS=linux`、`GOARCH=amd64` 与 cross `CC` 生成 `libwa.a`；Dora 不再链接源树中的 Linux 预生成 archive。latest xmake 的回调沙箱不再隐式暴露完整 `io`/扩展 `os` 对象，生成规则已改为不依赖该隐式全局，bgfx bin2c 改用 xmake `core.base.binutils.bin2c`，对应 standalone targets 和完整构建均通过。

运行时验证：Debug/Release 分别复制到可执行临时路径，以 Xwayland、GDM session DBus 和 dummy SDL 音频运行 10 秒。两次均完成 Mesa/BGFX、SoLoud SDL2 static backend、AgentStorage 与资源加载，timeout 返回预期的 124，并执行引擎清理；Release 日志记录 `[DoraAudioTrace] SoLoud initialized` 与 `[AgentStorage] ready`。

打包执行命令：`xmake dora-package --platform=linux --arch=x86_64 --mode=release`。task 从 `lddtree` 收集非系统、非图形运行库，以 `patchelf` 写入 `$ORIGIN/../lib` RPATH，复制 Assets/Web IDE、AppRun、desktop 与 icon，再生成 `build/package/linux/x86_64/release/dora-ssr-linux-x86_64.AppImage`。交叉打包首次发现 target 架构版 appimagetool 无法在 ARM64 host 执行；任务现按 host 下载 aarch64 appimagetool，并设置 `ARCH=x86_64` 生成目标 runtime。

产物与运行时验证：AppImage 为 66 MiB x86-64 static PIE，SHA-256 为 `8d7f7b48f4df11d4451071a867bbfb21a70c6d59638c1018ef4e39fd8b7d1232`；AppDir 为 209 MiB，包含 `usr/bin/dora-ssr`、Web IDE `Assets/www/index.html`、AppRun、desktop/icon 以及 DBus/systemd/C++ 等打包依赖。`lddtree` 仅将 glibc、loader 与 GLES/GLdispatch 保留为系统/图形依赖。由于 ARM64 guest 的 binfmt 不接管 static AppImage runtime，验证显式执行 `/media/psf/RosettaLinux/rosetta <AppImage>` 并设置 `APPIMAGE_EXTRACT_AND_RUN=1`；AppImage 自身完成解包和 AppRun 启动，10 秒内输出 `Dora is ready!`，timeout 返回预期的 124。

真实 C 门禁：本轮 Linux 构建中的 `XrtNetwork.c`、Lua、wasm3、zlib、SDL 等均由 C 编译步骤直接完成；结合 Windows verbose 强制重编的 `/TP=0`、`/TC=31` 记录，当前迁移不再用编译器参数掩盖伪 C。后续发现依赖 C++ 语法的 `.c` 时，必须改名为 `.cpp` 或修成真正 C。

未验证项：Linux x86_64 CI；Linux ARM64 AppImage；AppImage 在原生 x86_64 Linux（无 Rosetta）上的第二环境复验。

### 2026-09-30 / M5.3–M5.6、M7.6 Android Release 三 ABI

环境：Apple Silicon macOS host，xmake 3.1.1+20260827，Android NDK 26.1.10909125 / API 28，Gradle 8.2 / compileSdk 34；运行环境为 Android 15 ARM64 emulator。

执行命令：`xmake dora-package --platform=android --mode=release`。task 依次完成 armeabi-v7a、arm64-v8a、x86_64 Release Native 构建，将各 ABI 的 `libmain.so`/`libSDL2.so` 暂存为 Gradle `jniLibs` 输入，再执行 `assembleRelease`。armeabi-v7a 继续使用已验证的串行构建规避 Apple host 的 32-bit xmake compiler-cache 崩溃，其余 ABI 正常复用缓存。

打包结果：仓库未配置生产签名凭据，Gradle 按规范生成 `Projects/Android/Dora/app/build/outputs/apk/release/app-release-unsigned.apk`；package task 现明确识别该文件名，不再错误要求 `app-release.apk`。产物为 359 MiB，SHA-256 `c573656eb249498acd327e6efd6cf331698597c4927d9734ba2a61c1f78029b9`，`unzip -tq` 通过，package/version 为 `org.ippclub.dorassr` / `1.9.3`，minSdk 28、targetSdk 34。APK 中六个 Native 文件分别识别为 ARM EABI5、AArch64、x86-64 ELF；`apksigner verify` 对正式产物返回缺少签名，符合其 unsigned 状态。

运行时验证：为验证 Release 二进制而不污染正式产物，复制 APK 并仅用 Android 默认 debug keystore 生成本地测试签名副本，`apksigner verify --print-certs` 确认 v3 签名。该副本在 Android 15 ARM64 AVD 冷安装/冷启动，`MainActivity` 成为 `topResumedActivity`，PID 3147 在 15 秒后仍存活，`dumpsys activity lastanr` 为 `<no ANR has occurred since boot>`；日志依次出现 SoLoud SDL2 static、AgentStorage ready 与 `Dora is ready!`，截图 `build/android-release-api35.png` 显示已渲染的 Dora Local 项目页。

环境边界：首次 API 34 headless AVD 出现 Android `system_server` ANR，虽 Dora 已在后台渲染且进程存活，该轮没有作为通过证据；换用 API 35 AVD 冷启动后无 ANR，以上证据均来自第二轮。Apple Silicon emulator 安装只包含 aarch64/armel QEMU，即使 SDK Manager提供 x86_64 system image也不能在该 host 上运行；因此 x86_64 emulator 门禁保持未完成。

未验证项：生产 keystore/CI secret 注入、AAB、Play 签名、x86_64 emulator 和 Release 文本输入/复杂项目 fixture。

### 2026-09-30 / M7.5 Windows x86 ZIP

环境：Windows 11 ARM64 Parallels VM，xmake v3.1.1+HEAD.3ba37a0d4 原生 ARM64，VS x86 工具链，仓库位于 Parallels 共享目录。共享目录访问授权通过后，Release 对象文件持续生成，完整构建与打包任务退出码为 0。

执行命令：`C:\App\XmakeArm64\xmake\xmake.exe dora-package --platform=windows --mode=release`。任务配置并构建 x86 Release，暂存 `Dora.exe`、`wa.dll`、Web IDE、dora-wa、通用 Assets 与 Love shader，再用 7-Zip 生成平铺 ZIP；重复执行通过，并过滤 `.DS_Store`/AppleDouble 元数据。

产物：`build/package/windows/x86/release/dora-ssr-windows-x86.zip`，59 MiB，SHA-256 `621a226d73397d4207f1487fbe5504945363d3ef341ce8136e96d48cdf504c1e`。`unzip -tq` 无错误；包根包含 `Dora.exe`、`wa.dll`、`www/web-player/runtime.json`、`dora-wa/wa.mod`、`Shader/Love/varying.def.sc`，无 `stage/`、`Assets/` 前缀，且无 macOS 元数据文件。

当时的运行时边界：同一 Windows x86 Release 目标此前已在 VM 中完成 10 秒启动 smoke；本次仅对该版 ZIP 做了结构和完整性检查。后续 Windows CI/tag 入口已切换，并在新 Rust/Wa 依赖图下重新构建与验证，见下方追加记录。

### 2026-09-30 / M7.1–M7.2、M8.5 Windows/Linux CI 切换

Windows 主分支 workflow 已从 `build_windows.bat` 改为 `xmake f -y -p windows -a x86 -m debug` 与 `xmake build Dora`；原有仅在 tag 条件下执行、但 workflow 实际不监听 tag 的重复打包/发布段已删除。tag 发布在 `release.yml` 中改为 `xmake dora-package --platform=windows --mode=release`，复用通过本地 VM 验收的 ZIP 任务。两个 Native job 不再独立安装 Go/Rust；MinGW32 仍供 Go cgo 使用。

Windows 本地复验：Windows 11 ARM64 VM、xmake v3.1.1+HEAD.3ba37a0d4 原生 ARM64、VS 2026 x86 编译器，在 Parallels 共享工作区执行上述两条主分支 CI 命令，Debug 全量构建、链接 `build/windows/x86/debug/Dora.exe` 成功，`xmake` 报 `build ok, spent 1029.672s`，进程退出码 0。此处未重新做运行时启动；先前 M4.4 的启动 smoke 与本次编译验证为不同证据。

Linux 主分支 workflow 改用 latest xmake 配置/构建 Debug，PR/ci 分支 AppImage 与 tag 发布改由 `xmake dora-package --platform=linux --arch=<x86_64|arm64> --mode=release` 生成。`aarch64` 发行文件名与 xmake `arm64` 架构参数在 matrix 中显式映射。Linux Native jobs 移除旧 CMake、系统 Lua/tolua++、独立 Go/Rust 准备；`pkg-config`、音频/窗口系统开发库、`pax-utils`/`patchelf` 等仍保留。macOS 主分支 Debug job 已改用 `xmake f`/`xmake build Dora`；macOS tag 发布仍保留旧路径，需先解决生产签名等价。五份改动的 workflow 经 `actionlint` 与 `git diff --check` 通过。

当时的未验证项：GitHub-hosted runner 的依赖自举与全量 CI、Linux ARM64 AppImage 产物和启动、tag 等价 dry run。其后 Linux ARM64 AppImage 已在本地 VM 通过；远端 CI 与 tag dry run 仍未完成。

### 2026-09-30 / M1.3–M1.4、M4.4、M7.1–M7.5 Windows runtime 自举

clean checkout 审计发现原 Windows Dora xmake target 仍直接链接 `Source/Rust/Lib/Windows/dora_runtime.lib`、复制 `Source/3rdParty/Wa/Lib/Windows/wa.dll`，这两个大文件未被 Git 跟踪。本地旧缓存会掩盖 CI 缺口。已添加 `dora-rust-runtime` 与 `dora-wa-runtime` 目标，Dora 改为依赖并链接 `build/runtime/windows/x86/<mode>/` 生成物。Rust 从跟踪源码用受管 rustup 安装 host toolchain、添加 `i686-pc-windows-msvc` target，Cargo 目标目录优先使用本地 `CARGO_TARGET_DIR`/`LOCALAPPDATA` 以避开共享盘 archive 临时文件故障。Wa 从跟踪的 vendor/Go 源以 `GOOS=windows`、`GOARCH=386`、`CGO_ENABLED=1` 和 32 位 MinGW GCC 生成 DLL。

环境：Windows 11 ARM64 Parallels VM，xmake v3.1.1+HEAD.3ba37a0d4 原生 ARM64，VS 2026 x86 编译器与 `i686-w64-mingw32` GCC。执行 `xmake f -y -p windows -a x86 -m debug`，分别构建 Wa/Rust runtime 与 Dora：Wa DLL 15 MiB，Debug Rust `.lib` 284 MiB，Dora 重新链接为 PE32 x86；三步退出码均为 0。首次 rustup `target add` 暴露 host toolchain 未安装，修复为同一 xmake task 显式安装并选择 stable host toolchain 后，Rust 构建耗时 120.5 秒，Dora 增量链接耗时 34.094 秒。新 DLL 与目标输出目录的 SHA-256 相同，且不同于旧源树预构建 DLL。新 Debug exe 在 VM 启动持续 10 秒后由 smoke 脚本清理。

Release 执行 `xmake dora-package --platform=windows --mode=release`，从源码生成 Release Rust `.lib` 7.8 MiB 和 Wa DLL 15 MiB，Dora 链接并打包退出码 0。当前 ZIP 位于 `build/package/windows/x86/release/dora-ssr-windows-x86.zip`，约 58 MiB，SHA-256 `d0bf545b1064cae152f1b836fe8cf1dc11c009fbbf337bf4cbd62687d30cf749`；`unzip -tq` 无错误，包内 `Dora.exe`/`wa.dll` 为 PE32 x86，关键 Web/dora-wa/Shader 文件位于预期顶层，无 macOS 元数据。包暂存目录中的 Wa DLL 与新 runtime 输出哈希一致；直接从暂存目录启动 Release exe，进程持续 10 秒后清理。

未验证项：真正隔离的 clean checkout、GitHub-hosted Windows runner、Windows 发布签名（若需要）与完整 tag dry run；本地新目标的源码构建和链接不能替代远端 CI。

### 2026-09-30 / M4.3、M7.3 Linux ARM64 AppImage

环境：Ubuntu 24.04 ARM64 Parallels VM（with Rosetta），原生 AArch64 Linux 编译，xmake v3.1.1+dev.a99b04b47，GDM Xwayland `DISPLAY=:1024`。另一台 Ubuntu ARM64 VM 缺少 `patchelf`/`lddtree`，尝试安装时其既有 Python post-install hooks 因 `dput`、`hplip-data` 等 dpkg 文件清单缺失而失败；因此改用系统依赖齐全的 Rosetta VM 验收，不把 apt 错误计为 Dora 构建失败。

执行命令：`xmake dora-package --platform=linux --arch=arm64 --mode=release`。ARM64 Release 全量编译、链接成功；第一次生成 AppImage 后发现 Parallels 共享目录把资源复制成 owner-only `0600`，普通用户无法自解包/读取。task 已在组装前对 AppDir 执行 `chmod -R a+rX`，保证资源可读、目录可进入。重试中 GitHub continuous `appimagetool` 下载曾报 curl 56；task 现按 host 架构将完整下载缓存到 `build/tools`，先下载至临时文件并对网络错误重试，避免下次重打包重复下载或复用半成品。修复后同一命令退出码 0。

产物：`build/package/linux/arm64/release/dora-ssr-linux-aarch64.AppImage`，65 MiB，AArch64 static PIE，SHA-256 `3f5f8fb506db152ec9a784a5e0d2120f06dd7588b48f38bd04208bb2155680c7`；AppDir 约 228 MiB。`lddtree -l` 依赖闭包可解析，除 loader、glibc 与系统 GLES/GLdispatch 外，C++、DBus、systemd 等运行库从 AppDir `usr/lib` 解析；包含 `Assets/www/index.html`、`www/web-player/runtime.json` 与 `dora-wa/wa.mod`。复验 AppDir 的资源为 `0644`，`AppRun`/引擎可执行文件为 `0755`。

运行时验证：将新版 AppImage 复制到 VM `/tmp`，以 GDM 图形会话普通用户、`APPIMAGE_EXTRACT_AND_RUN=1` 和 SDL dummy 音频在 Xwayland 启动；日志出现 SoLoud SDL2 static、AgentStorage ready 与 `Dora Dora is ready!`，进程持续到 60 秒有界超时（预期状态 124），随后无残留进程。首版 root 身份 12/30 秒 smoke 仅到初始化、普通用户自解包失败，不作为通过证据；最终通过证据来自权限修复后的普通用户复验。

未验证项：该 AppImage 在独立原生 ARM64 发行环境、真实音频输出与 GitHub-hosted ARM64 runner 的二次验收。

### 2026-09-30 / M5.2 iOS simulator runtime 源码自举与共享目录复验

环境：macOS arm64、xmake v3.1.1+20260827、Xcode 27 / iPhoneSimulator 27.0 SDK、iPhone 17 Pro / iOS 26.5 simulator。Windows 11 ARM64 Parallels VM 用于共享目录读访问复验。

执行命令：`xmake f -p iphoneos -a arm64 --appledev=simulator -m debug -y`；`xmake build dora-rust-runtime dora-wa-runtime`；`xmake build Dora`；`xcrun simctl install booted build/iphoneos/arm64/debug/Dora.app`；`xcrun simctl launch booted IppClub.DoraSSR`。Rust/Wa 输出改为 `build/runtime/iphoneos/<device|simulator>/<arch>/<mode>/`，避免设备与模拟器 arm64 产物相互覆盖；Dora 链接该输出，不再链接 `Source/Rust/Lib/iOS-Simulator` 与 `Source/3rdParty/Wa/Lib/iOS-Simulator` 中未跟踪的预构建静态库。

结果：Rust `libdora_runtime.a` 144 MiB 与 Wa `libwa.a` 18 MiB 从跟踪源码生成，`lipo -info` 均为 arm64；`xmake build Dora` 完成重新链接和 `.app` 生成，`file` 确认 Dora 为 arm64 Mach-O。新 `.app` 在模拟器安装与启动成功，`launchctl list` 继续显示 `UIKitApplication:IppClub.DoraSSR` PID 82595、状态 0。Windows VM 的 `prlctl exec --current-user cmd /c 'dir \\Mac\Home\Workspace\Dora-SSR\xmake.lua'` 返回退出码 0 并列出文件，先前共享目录授权阻塞已解除。

随后执行 `xmake f -p iphoneos -a x86_64 --appledev=simulator -m debug -y`、`xmake build dora-rust-runtime dora-wa-runtime` 和 `xmake build Dora`。首次链接发现把 x86_64 模拟器 Wa 当 `darwin/amd64` 构建会引用 iOS SDK 不提供的 `_fdopendir$INODE64`、`_readdir_r$INODE64`。改用 Go `ios/amd64` 并显式向 cgo clang 传 `-arch x86_64` 后，重建的 Wa 改为引用无后缀符号，完整 Dora x86_64 Debug 全量构建、链接及 `.app` 生成退出码 0。首次改用 `ios/amd64` 时未指定 clang 架构，汇编器错误地按 arm64 解析 x86 指令；已由相同架构参数修复。Xcode 27 对 iOS 13 最低版本仍有 libc++ 不再支持的警告，需单独评估最低版本策略。

未验证项：x86_64 simulator 真实启动（当前 Apple Silicon simulator 为 arm64）、iOS device、Release、真实设备签名/启动与独立 clean checkout；Android Rust/Wa AAR 仍依赖未跟踪的本地旧产物。

### 2026-09-30 / M5.3-M5.6、M7.1-M7.2、M7.6 Android Rust/Wa 源码自举与 APK/AAB

环境：macOS arm64 host、xmake v3.1.1+20260827、Android SDK 34 / NDK 26.1.10909125 API 28、Android 15 arm64-v8a `Pixel_7_API_35_arm64-v8a` emulator。xmake 的 Android Rust target 从跟踪的 `Source/Rust` 和 `Tools/dora-rust` 源码调用受管 rustup/Cargo，按 armv7、arm64、x86_64 三 target 使用 NDK LLVM clang/archiver；Dora 改为链接 `build/runtime/android/<ABI>/<mode>/libdora_runtime.a`。Wa target 使用受管 Go 安装固定版 gomobile，将跟踪的 Wa 源复制到临时构建目录，生成去除旧 x86 ABI 的 `build/runtime/android/wa.aar`；Gradle 只消费 `app/build/xmake-aar/wa.aar`，不再读取未跟踪的 `Source/3rdParty/Wa/Lib/Android/wa.aar`。`dora-package` 同时暂存三 ABI JNI 库与跟踪的 dora-wa 模块/vendor 资源。

执行命令：`xmake dora-package --platform=android --mode=debug`；以本机调试密钥设置四个 `DORA_ANDROID_SIGNING_*` 环境变量分别执行 `xmake dora-package --platform=android --mode=release` 和 `xmake dora-package --platform=android --mode=release --format=aab`。三次 package 均退出码 0；Wa AAR 二次目标构建命中增量缓存。Debug APK 约 484 MiB，Release APK 约 288 MiB、SHA-256 `623ab86a47835ead2beff70061bc8467c866c7e4201f5cb42532324b261056c9`，AAB 约 209 MiB、SHA-256 `5652edf5064db30dfc54a5735f293d4bc5d3e8a5b568007383597966e42ee616`。产物副本保存在 `build/package/android/debug/app-debug.apk`、`build/package/android/release/app-release.apk` 和 `build/package/android/release/app-release.aab`。

结构/签名：Wa AAR 和 Debug/Release APK 的 ZIP 完整性检查通过，均含 arm64-v8a、armeabi-v7a、x86_64 的 `libgojni.so`；APK 还包含各 ABI 的 `libmain.so`、`libSDL2.so`。AAB ZIP 检查通过，`base/lib` 中有相同三 ABI 库和 `base/assets/www/web-player/runtime.json`。`apksigner verify` 确认 APK v2 签名有效；`jarsigner -verify` 确认 AAB 签名有效，所报自签、1024 位密钥和无时间戳警告属于本地旧调试密钥，不能用于生产发布。

运行时：Debug 与本地测试签名 Release APK 在 API 35 arm64 模拟器覆盖安装、冷启动，进程持续运行；日志有 SDL main、SoLoud SDL2 static 和 AgentStorage 初始化，无 ANR/Fatal。两次截图均显示 Dora 本地游戏列表；Debug 通过 `adb shell input tap` 进入 AI Fighter 游戏，画面和虚拟触控按钮出现，进程仍存活。截图在 `build/package/android/debug/dora-xmake-debug.png`、`dora-xmake-tap.png` 与 `build/package/android/release/dora-xmake-release.png`。

CI/空间：`.github/workflows/android.yml` 与 tag release 的 Android job 已改为 xmake 打包入口，移除单独的 Go/Rust/gomobile/tolua 安装/生成步骤，显式安装 versioned NDK；两份 YAML 通过 `actionlint`，远端 job 尚未运行。本机磁盘不足导致首次模拟器启动被拒；另存 APK/AAB 后用 Gradle 官方 `./gradlew clean` 清理两轮可重建 `app/build` 中间产物，产物副本与截图保留。首次 Wa vendor 资源暂存多嵌套一层的副本已移到系统废纸篓（可恢复），修正后的 `os.cp` 布局复验无 `vendor/vendor`。

未验证项：隔离 clean checkout、GitHub-hosted Android runner、生产密钥签名/Play 上传、AAB 在 bundletool/分发渠道安装、x86_64 Android emulator 的真实启动与完整文本输入。

### 2026-09-30 / M5.7 Android Studio Native 调试实测

环境：macOS arm64、xmake 3.1.1+20260827、Android NDK 26.1.10909125 / API 28、Android 15 `Pixel_7_API_35_arm64-v8a` 模拟器、Android Studio 的 Dora Gradle 工程。此前清理了 Debug Native 产物，本轮以 `xmake f -q -y -p android -a arm64-v8a -m debug --ndk=/Users/Jin/Library/Android/sdk/ndk/26.1.10909125 --ndk_sdkver=28` 和 `xmake build -j 6 Dora` 重新构建；`build/android/arm64-v8a/debug/libmain.so` 为带 `.debug_info`、`.debug_line`、`.symtab` 的未剥离 ELF。为单独验证 IDE 调试，本轮手工暂存该库、`libSDL2.so` 与 Wa AAR 到 `app/build`，随后 `./gradlew assembleDebug --offline` 成功，APK 安装并启动，进程 PID 2988。

在 Android Studio 选择 Native Only 附加该进程。`idea.log` 显示 LLDB 把 `app/build/xmake-jniLibs/arm64-v8a` 加入符号搜索路径并完成附加。设置 `libmain.so` 中 `Dora::Director::doLogic()` 的符号断点后，IDE 实际停在该函数，打开 `Director.cpp`，调用栈显示 `Dora::Director::doLogic()`、`Dora::Application::mainLogic(...)` 等帧；这证明 Android Studio 的 LLDB 调试不以 CMake 编译为必要条件。验证用断点已移除并恢复进程。

限制：同一文件的 `Director.cpp:395` 源码行断点显示未解析；编辑器提示该文件不属于项目 target，具体是源路径映射还是项目模型问题尚未定位。现有 `app/build.gradle` 仅消费暂存的 `jniLibs`/AAR，没有 Gradle 调用 xmake 的反向依赖，因此直接点击 IDE Run/Debug 不会保证 C++ 改动被重建。本轮手工暂存只用于隔离验证，不能当作正式工作流验收；M5.7 与 Android CMake 移除门禁均保持未完成。

### 2026-09-30 / M5.7 xmake 源清单生成 Android Studio CMake 模型原型

环境：macOS arm64、xmake 3.1.1+20260827、Android Studio / Gradle、NDK 26.1.10909125、API 35 arm64 模拟器。原型文件放在忽略目录 `build/android-ide-prototype/`，仅在验证期间将其 `CMakeLists.txt` 临时接入 `app/build.gradle`，结束后已移除临时 Gradle 配置。

做法：运行 `xmake l Docs/design/xmake-build-migration/android-ide-model-prototype.lua`，通过 xmake 项目 API 读取 `Dora` target 的 580 个源文件，生成仅供 IDE 建模的 CMake 静态目标，使用 `EXCLUDE_FROM_ALL` 避免 Gradle 构建第二份引擎。CMake 配置通过；`./gradlew :app:generateJsonModelDebug --offline` 和 `:app:assembleDebug --offline` 均成功，四个 ABI 的 Native 模型生成，arm64 `compile_commands.json` 含 `Source/Basic/Director.cpp`，APK 构建没有编译该模型目标的 580 个源文件。Studio Gradle Sync 成功；直接打开真实路径 `Source/Basic/Director.cpp` 时不再提示“不属于项目 target”，但通过 `app/src/main/cpp` 符号链接打开的同名文件仍提示该警告。模型仅导出源文件和一个 include 路径，因此 IDE 中出现大量缺失头文件/宏的误报，尚不满足索引验收。

调试验证：安装上述 APK 并以 Native Only 附加 arm64 进程，真实源码路径的 `Director.cpp:395` 行断点仍显示未解析。对打包前的未剥离 `app/build/xmake-jniLibs/arm64-v8a/libmain.so` 检查：`llvm-nm -C` 能找到 `Dora::Director::doLogic()`（地址 `0x2cd01cc`），但 `llvm-addr2line -f -C -e <libmain.so> 0x2cd01cc` 返回函数名与 `??:0`；`.debug_info`/`.debug_line` 节虽存在，不能据此认定 C++ 源码行号已生成。当前根 `xmake.lua` 只声明 debug/release mode，未添加 xmake 的 `mode.debug` 规则或等效 C++ 调试符号配置。这是行断点未解析的直接可复现原因之一；在修复符号后仍需复测源码路径映射。

结论：xmake 可以作为 Android Studio CMake 项目模型的源清单来源，无须手工维护第二份源文件列表；但“模型可导入”不等于“IDE 调试链路通过”。保留现有 Android CMake，先补 Debug C++ 行号信息，再验证行断点、完整 include/define 索引与 Gradle 自动触发 xmake 增量重建。此次未改动正式构建入口。

### 2026-09-30 / M5.7 Debug 行断点、索引与 Gradle 增量任务补验

在 `Projects/xmake/engine.lua` 的 Android Debug 分支显式设置 `set_symbols("debug")`，重新配置并全量构建 arm64-v8a Dora。`Director.cpp.o` 出现 `.debug_info` 与 `.debug_line`；新 `libmain.so` 的 `Dora::Director::doLogic()` 地址 `0x2cd01fc` 经 `llvm-addr2line -f -C` 解析到 `Source/Basic/Director.cpp:392`（旧库同一检查返回 `??:0`）。Debug APK 重新打包、安装到 API 35 arm64 模拟器后，Android Studio 使用 Native Only 附加进程，真实源码路径的 `Director.cpp:395` 行断点从未解析变为已解析并实际命中；停靠行、`Dora::Director::doLogic()` → `Dora::Application::mainLogic(...)` 调用栈和 `this` 变量均在 IDE 中可见。Detect Automatically 会尝试 Java+Native 双调试器附加，在 Native 断点先暂停应用时 Java 附加可能超时，因此此验收使用 Native Only。

生成器增加 `config.load()`，确保读取 Android 配置后的 target；输出 579 个 Android 源文件、22 个 include 目录及 target defines。临时接入 Gradle 后，`:app:generateJsonModelDebug --offline` 为四个 ABI 生成模型，arm64 `compile_commands.json` 的 `Director.cpp` 含对应 `-I`/`-D`，Studio Sync 成功；IDE 显示的 C++ 错误数从 333 降到 2，剩余提示尚未逐项核查。CMake 目标仍为 `EXCLUDE_FROM_ALL`，未让 Gradle 编译第二份引擎。

Gradle 增量任务也单独做了临时接线实验：在 `mergeDebugJniLibFolders` 之前执行 xmake Debug arm64 配置、`xmake build Dora` 与库暂存。第一次仅更新 `Director.cpp` 时间戳时，xmake 重编该目标并重链；由于二进制内容不变，Gradle 正确将 APK 视为 up-to-date。随后临时增加一空行改变源码行信息，`:app:assembleDebug --offline` 执行 xmake 重编/重链、`mergeDebugJniLibFolders`、`mergeDebugNativeLibs`、`stripDebugDebugSymbols`、`packageDebug`，均成功；恢复该空行后重复构建，同样成功重新打包。原型使用本机 xmake 路径且只覆盖 arm64，验证后已从 `app/build.gradle` 移除；`Director.cpp` 内容已恢复。正式 Gradle 工程目前**不会**自动触发 xmake，且生成式 CMake 模型仍须手工生成/临时接入；这两项是 M5.7 保持进行中的原因。

### 2026-09-30 / M5.6-M5.7 Android 正式 xmake → CMake → Gradle 接入

本条取代前述仅 IDE 建模/暂存 jniLibs 的原型结论。`app/CMakeLists.txt` 已由手工源/依赖清单改为薄适配器：按 Gradle ABI/variant 建立隔离 xmake 配置，`Projects/xmake/android/export.lua` 递归读取 Dora 的 14 个 Android C/C++ target，导出真实 CMake libraries、源文件、语言标准、include/define、Jolt 逐文件选项和链接依赖。C/C++ 的唯一编译后端为 Gradle 的 CMake/Ninja/NDK；xmake 自定义 target 仍负责 Lua bindings、Rust archive 和 Wa AAR。不再读取暂存的引擎 jniLibs 或 vendor 预编译引擎库，`dora-package` 不再事先构建第二份 C++ 引擎。

环境：macOS arm64、xmake 3.1.1+20260827、Studio JBR 17.0.7、Gradle 8.2 / AGP 8.2.2、NDK 26.1.10909125、CMake 3.22.1、native API 28；运行设备为 API 35 arm64 模拟器。`xmake doctor --platform=android` 0 errors / 0 warnings；SDK components、JDK 与受管 Go/Rust 工具均有路径和版本。Android workflow 与 release workflow 显式安装 CMake 3.22.1；两份文件 `actionlint` 通过，尚未执行远端 CI。

构建证据：隔离 CMake configure 导出 14 个 target；arm64 Debug 的 `:app:assembleDebug --offline -Pdora.android.abis=arm64-v8a` 从新 CMake 目录执行约 1320 个 Ninja 步骤并成功。默认三 ABI 的 `xmake dora-package --platform=android --mode=debug` 与直接 Gradle Debug 均通过；`compile_commands.json` 中 Director 使用真实 `Source/` 路径与 Debug 行号参数，XrtNetwork.c 使用 Clang GNU C11，Jolt 保留 `JPH_NO_FORCE_INLINE` 与 no-RTTI/no-exceptions。显式共享 STL runtime 依赖使 APK 的三 ABI 各含 `libmain.so`、`libSDL2.so`、`libc++_shared.so` 和 Wa 的 `libgojni.so`。

Studio 验收：移走 Wa runtime/staged AAR 与 arm64 Debug Rust archive，在 `Director.cpp` 临时增加导出 probe 后点击 Studio Run；构建自动恢复依赖并安装新 APK。设备拉取的 base APK 与 `app/build/intermediates/apk/debug/app-debug.apk` SHA-256 同为 `fa25a40fb50257e399274dff5800ed6a3938198a0d2a73997701262f7ae311ed`，实际设备库包含 probe，证明 IDE Run 安装的是重建结果。删除 probe 后点击 Studio Debug，自动重编并以 Native Only 实际命中 `Director.cpp:395`，C++ 调用栈和 `this` 可见。验证断点已删除，Director 源内容已恢复，IDE 设备选择的跟踪配置已还原。

首次 Sync 缺口及修复：移走 staged Wa AAR 后，旧的仅 `builtBy` 依赖无法让 Studio 的模型导入生成文件，出现 Null extracted folder。现在 Gradle 配置阶段只在该 AAR 缺失时调用 xmake 初始化；再次从缺失状态执行 Studio Sync，AAR 自动恢复，界面显示绿色完成与 `BUILD SUCCESSFUL in 6s`。正常构建仍通过 `prepareXmakeAndroid` 检查 Go/module 更新。CMake 准备任务用文件锁序列化共享 Lua/Rust 输出；Lua 输出清单来自同一 xmake target，内容变化才更新构建目录内 stamp，不把跟踪源文件标为 GENERATED/BYPRODUCTS，避免 Ninja clean 删除源文件。

运行验收：Studio 新 Debug APK 冷启动 `Status: ok`，PID 4328，SDL main、SoLoud SDL2 static 与 AgentStorage 初始化成功；截图显示 Local 游戏页，经触摸 Play 进入 AI Fighter，有正常渲染与虚拟按钮，进程持续存活，进程日志无 Fatal/native signal。模拟器曾显示 System UI 无响应对话框（不是 Dora ANR），选择 Wait 后恢复，随后的游戏触摸通过。截图：`build/android-xmake-runtime.png`、`build/android-xmake-game.png`。验证完成后停止应用并关闭模拟器。

文档：`Projects/xmake/android/README.md` 给出 Studio 与 CLI 操作、SDK/JDK 要求、xmake 可执行文件覆盖、ABI 筛选、签名参数和各构建后端职责。未验证：无缓存新主机/隔离 clean checkout、Linux/Windows Android host、生产签名/分发、原生 x86_64 emulator 运行；这些不以本机 ARM64 结果替代。

### 2026-10-01 / iOS 与 Web 正式构建迁移

用户明确豁免后续交互断点验证。本轮不启动 IDE 调试器，仍验证构建、包、真实模拟器与 HTTP 浏览器。

iOS：`xmake dora-package --platform=ios --appledev=<device|simulator> --mode=<debug|release>`，四组 arm64 配置均完成源码构建（Lua codegen、vendor、Rust、Wa、Dora）和打包。Debug 使用 `-O0`、Release 使用 iOS `-Os`，两者保留调试符号；配置、runtime 和输出均按 SDK/架构/mode 隔离。device IPA 为 `Payload/Dora.app`，`unzip -tq` 与 `codesign --verify --deep --strict` 通过。默认 ad-hoc，不能以此声称真机可安装或可发布。生产签名接口接收已安装证书/描述文件，嵌入原 CMS 描述文件并使用其 entitlements 重新签名；没有使用真实生产身份验收。

最终四组打包复验日志为 `build/ios-final-matrix.log`。Debug 与 Release App 都在 iPhone 17 Pro / iOS 26.5 simulator 安装启动，最终 PID 85650/85417，`launchctl list` 持续存活，截图 `build/ios-xmake-debug-final.png`、`build/ios-xmake-release-final.png` 显示真实 Dora Local UI。结束后已关闭该测试模拟器。此前构建日志为 `build/ios-{device,simulator}-{debug,release}-migration.log`；x86_64 simulator Debug 已构建链接，但本轮不声称 Intel simulator 启动通过。

Web：`Projects/xmake/web/{options,config,manifest,targets,prepare,runtime}.lua` 和 `Projects/xmake/tasks/web.lua` 取代正式及旧 Emscripten CMake 图。保留 profile、feature overrides、pthread、Love support/probes/正式 Player、独立 AudioWorklet Wasm、Rust music/3D、fixture/hash manifest、字体、授权复杂项目与 Studio 隔离接口；现有 shell 只转发，gallery 不再另走 CMake。删除六份重复 Web CMake 描述，不删除运行源码与 JS 测试工具。`ios.yml`、`web.yml` 及 release Web job 改用 xmake latest，同本地入口；actionlint、shell/Node syntax 与 diff whitespace 检查通过，远端 CI 尚未执行。

环境：macOS arm64、xmake 3.1.1+20260827、Xcode 27、受管 Emscripten 6.0.0、Go 1.27.1、Rust/Cargo 1.96.1、Chrome 154.0.8037.58。`xmake dora-web-env` 为 0 errors / 0 warnings。

真实构建：单线程 dora-preset、core、custom（LOVE/MODEL_3D/MUSIC/BUILTIN_LIBS/PHYSICS_2D 开启）以及 pthread dora-preset Release 均链接成功。custom Rust archive 与完整 Player 进入链接，浏览器 LoveNode、3D 和 music bindings smoke 通过；core 浏览器确认可选模块未泄漏并持续 running。另在 `build/web-rust-pthread-check` 从源码通过 pthread Rust standard library/atomics 构建（136.224 秒）；这不是完整 pthread+Rust Player 浏览器验收。

core Debug 完整 engine/Player 构建及最小项目浏览器 smoke 也通过：`build/web-core-debug.log`、`build/xmake-web-core-debug-smoke.log`。`check_web_player_output.mjs` 专用于默认 preset（要求 builtin libraries 和 preset modules），不能直接作为 core 的验收工具。

包检查：构建 probe、Player、Love pthread 包、preview、builtin libraries、forbidden dependencies 均通过；单线程不含 shared memory，pthread 显式允许。链接 targetdir 改为相对路径后，JS/Wasm 不再泄漏本机 `/Users/Jin` 路径。保留的 CMake 产物与 xmake 产物在 DPR=2 得到完全相同的 ImGui 像素边界，因此更新失效的精确测试基线（仍校验位置、裁剪和像素数量，DPR round-trip 后的字体烘焙状态也纳入 DPR=1 基线）；按键测试移除错误的 macOS nativeVirtualKeyCode=65（实际为 NumpadDecimal），key-up/down 使用相同 portable A 键。未保留猜测性的 SDL 事件代码改动。

增量：修复可选 nil 导致 dependency values 序列紧缩、字典/boolean 不能可靠比较的问题；prepare/Rust 的 feature/config 使用稠密字符串值。core 第二次原样构建 1.168 秒，无资源生成或 relink；仅 touch 生成的 `dora-web-features.js` 后自动 relink（12.153 秒），不重编 engine。测试只触碰 build-owned 文件，没有编辑用户源文件来制造增量变更。

音频与 Love：新 mixer 的 Node DSP 全套测试通过；普通 HTTP 与 COOP/COEP 的 Chrome AudioWorklet 阻塞/暂停/恢复/停止/关闭通过。Love graphics/shader/runtime/audio 均通过 1 reload。诊断版补齐 FS/IDBFS exports；Release 外置符号图定位失败项目后的 `malloc` 越界：`LoveNode::createProbe` 在 init 失败时 raw delete 了仍由 Director 的 `RefVector` 持有的节点。修复为 managed/cleanup 后由持有者正常释放；正式无诊断优化版在三个独立 Chrome profile 连续通过 import/start/stop/错误清理/恢复。日志 `build/xmake-love-pthread-repeat.log`。测试器添加浏览器异常输出及 CDP 超时，避免 runtime 卡住时测试永久挂起。

Lua codegen 补齐此前未声明的 Touch `fromMouse/mouseButton/clickCount`，同步双语 TypeScript/Teal 声明；否则 fresh bindings 会把 scene mouse input 错判为 touch。新增 Tools/tolua++ header 与生成器源码依赖，SDK/mode 配置共享加锁的生成依赖记录，host generator 可执行文件按 mode 隔离，避免并行配置覆盖相同输出。

最终 Love graphics/shader/runtime/audio 各 1 reload 复验通过，日志为 `build/xmake-love-{graphics,shader,runtime,audio}-final.log`。音频 probe 的 pre-js 快照原先可能在 Wasm exports 初始化之前被调用；现在等待 running/start 后才提供快照，没有吞掉运行期错误。正式 pthread Player 又独立通过一次，日志 `build/xmake-love-player-final.log`。

完整 preset 浏览器：`DORA_WEB_RELOADS=1 node Tools/build-scripts/check_web_browser.mjs result/dora-web-player build/xmake-web-browser-final.png` 退出码 0。渲染、DPR=2、readback、lazy assets、网络 Fetch、包导入、IDBFS、键鼠/触摸/Gamepad/IME/文件选择/Clipboard/Pointer Lock、visibility/audio、stop 和 reload 生命周期全部通过；unexpected errors=0、lifecycle warnings=0。默认包最终重新生成后又通过一次，cold=3999.5 ms、warm=873.8 ms、gzip=3507844 B；文件 `build/web-startup-performance.json`。并行编译/多个 Chrome 测试曾使 5 秒门禁超时，最终复验在空闲主机运行，没有放宽该门禁。

保留的发布门禁：生产签名与真机、Intel simulator 运行、远端 CI/干净新主机、授权 complex game 与实验 main-worker 完整运行、正式性能与 tag dry run。旧 native Xcode/Windows/Linux 工程和未调用的历史 dependency shells 属全局 M8 清理，不作为新 iOS/Web 入口的构建依赖。

Release/APK/AAB 复验：`xmake dora-package --platform=android --mode=release` 从新 CMake Release 目录为三个 ABI 各执行约 1320 个 Ninja 步骤，生成 `app/build/outputs/apk/release/app-release-unsigned.apk`，ZIP 完整性检查通过。随后使用本机 Android debug keystore 验证同一 package task 的签名接口：signed APK 约 196 MiB，SHA-256 `14433c1617f165f32f9970a1288f15f05e769e387f9d81a31c032e8e28489fa0`，`apksigner` 确认 v2 有效；`--format=aab` 生成约 163 MiB 的 AAB，SHA-256 `2eb468c32469a3f37dad063c3d92a2fa0d8fa365ff4147aa133b5b1590692ec7`，ZIP 与 `jarsigner` 验证通过。AAB 的 `base/lib` 与 APK 均具三 ABI 的引擎、SDL2、共享 STL 和 gomobile 库；ELF 头对应 ARM EABI5、AArch64、x86-64。AAB 自签、1024-bit key 和无时间戳警告属于旧本地测试密钥，不能视为生产发布签名。

新 signed Release APK 安装成功，冷启动 `Status: ok / COLD / TotalTime: 1106ms`，PID 3042。Local 页面资源正常，SoLoud 初始化成功，进程日志无 Fatal/native signal。通过触摸 New → New game，系统键盘出现，`XmakeIntegrationTest` 完整进入文本框；隐藏键盘后点击 Cancel，返回仍为 7 项的原游戏列表，没有创建测试项目。截图：`build/android-xmake-release.png`、`build/android-xmake-input.png`、`build/android-xmake-input-cancel.png`。生产密钥、Play 上传、bundletool 分发安装与 x86_64 emulator 运行仍未验证。

日志：`build/android-gradle-release-validation.log`、`build/android-gradle-release-signed-validation.log`、`build/android-gradle-aab-validation.log`。共享引擎 `xmake audit-manifests` 再次通过 580/580 路径审计；`git diff --check` 通过。导出同一配置时 CMake 内容及时间戳不变；导出器禁止把 `.c` 源强制声明为 C++。

最终增量门禁：恢复全部源码后的三 ABI Debug 构建成功，再执行完全无源码变更的 `:app:assembleDebug --offline --console=plain`，`BUILD SUCCESSFUL in 44s`，39 个 task 中 32 个 up-to-date，其余仅配置/准备检查。三个 `libmain.so` 的时间戳和大小前后完全一致；Native merge、strip、APK packaging 全部 up-to-date，没有引擎重编/重链。日志为 `build/android-gradle-debug-incremental-validation.log` 和 `build/android-gradle-debug-noop-validation.log`。三个最终 Debug 库均含 `dora_rust_init` 而不含临时 probe；Director 源码无差异。Release 输入测试也已取消，应用与模拟器均停止；仅移除本次可重建的旧依赖备份和设备拉取副本，保留正式产物与证据。

### 2026-10-01 / 构建实现归入 Projects

按用户要求将原根目录 `xmake/` 的 28 个文件整体迁入 `Projects/xmake/`；根目录保留 `xmake.lua`，原命令与产物位置不变。同步修改 Lua includes/imports、host generator 源路径、增量输入、受管 package repository、Android CMake export/prepare/重配置监听、七个平台 CI 路径过滤、Web capability checker 与文档。模块计算仓库根目录改用 `os.projectdir()`，不再依赖移动前的父目录层级。旧空目录已移除，未删除构建源码。

迁移后验证：manifest 580/580 审计通过；Web build probe 和 Release Player 构建/链接通过；iOS arm64 simulator Debug 配置及 build-info 通过；Android arm64 Debug 在独立 CMake 目录导出 14 个 target、生成 Ninja 图并执行 `dora_xmake_prepare` 成功；Love capability 19 模块检查、全 workflows actionlint、Node syntax 和 diff whitespace 检查通过。日志为 `build/xmake-relocation-{web,web-player,ios,android,android-prepare,capabilities}.log`。本次目录调整未重新执行全平台完整构建矩阵或远端 CI，不以配置通过替代这些验收。

使用迁移后的 `dora-web` 重新打包（本次快速回归不构建 Love probes），默认 preset Player 静态包检查通过，真实 Chrome HTTP smoke 持续 running；日志 `build/xmake-relocation-web-{stage,output,browser}.log`。此前完整浏览器回归证据仍在上一节，本次仅复验目录调整后的启动。

### 2026-10-01 / M8 旧工程与脚本收尾

删除范围：macOS/iOS 手工 `.xcodeproj`、Windows Dora `.sln/.vcxproj/.filters/.user`、Linux CMake/makefile、共享 engine/generated CMake 清单、无人引用的旧 Emscripten bootstrap/shell，以及 16 个 `build_lib_*` 和 `setup_cargo_target_windows.bat`。Windows RC/header/icon、Apple plist/storyboard/assets、Android Gradle/CMake 薄入口与 Web 实际运行源码保留；第三方和独立 .NET 工程不在删除范围。旧工程中的本地改动和用户配置备份在 `build/legacy-projects.wIRxKC/`（约 2 MiB）；误随备份复制的旧编译产物已删除，原目录旧产物未动。跟踪文件的原版另可从 Git 恢复。

统一入口：`dora-build`/`dora-run` 将 Native 配置按平台、SDK、架构、mode 隔离；`dora-run` 转发参数并指定仓库 Assets，不停止其他进程；`dora-ide` 生成 Xcode/vsxmake/compile_commands 至 `build/ide/`。iOS Xcode 工程自动补齐 simulator SDK 与 application rule 的输出路径。旧 `build_*`/`run_*`、环境检查、AppImage 和 tolua++ shell/batch 转发这些 task/target，不再维护第二套依赖图。`audit-manifests` 校验唯一清单的 580 个文件、规范路径、重复项和核心覆盖，不依赖已删除的旧清单。

本次已通过的门禁：

- macOS arm64 Debug 完整构建；生成的 Xcode 工程实际 `xcodebuild` Debug 成功；`run_macos.sh cli --help` 参数转发与真实 CLI 成功。
- iOS arm64 simulator 新生成 Xcode 工程实际 Debug 构建成功；交互断点按用户决策豁免。
- macOS Release universal ZIP 打包成功，`lipo -archs` 为 `x86_64 arm64`，`codesign --verify --deep --strict` 与 ZIP 完整性检查通过。
- Android 新 `build_android.sh debug` 入口完成 Gradle APK，包含 arm64-v8a、armeabi-v7a、x86_64 的 `libmain.so` / SDL / Go runtime。
- Linux arm64 新 `dora-build` Debug 构建成功（602.217 秒），真实 CLI help 成功，compile_commands 生成成功。新 GCC 暴露 glsl_optimizer 的 POSIX `strdup` 声明需求，修为该 Linux C target 的 `gnu11`，仍按 C 编译。
- Linux `package_appimage.sh` 实际 Release 打包成功，自解包执行真实 CLI help 成功；`run_linux.sh cli --help` 完整转发/构建/运行也通过。
- Windows 官方原生 ARM64 xmake 的 `dora-ide` 生成成功；doctor 正确发现 Visual Studio 2026 与 i686 MinGW，0 errors / 0 warnings。生成 solution 必须将 Dora 设为 IDE 默认构建目标；已修正此前全 target default=false 导致 solution 空构建的问题。最终 solution 的 MSBuild 实际调用 `xmake build ... Dora`，C 库重编和 Dora 链接通过（xmake 42.5 秒，MSBuild 49.10 秒，0 errors / 0 warnings），不是空构建。错误使用模拟 x64 xmake 时，Native task 在安装前明确拒绝并提示使用 ARM64 版，实际负向测试通过。
- Windows x86 新 Native task 完整 Debug 编译/链接成功（922.172 秒），Windows RC 图标资源实际编译；产物为 PE32 Intel 80386，包含 `.rsrc`。第三方 C target 在 MSVC 下统一为 C11 + `/TC`，防止 c99 fallback 误当 C++。生成 VS 的 Assets 参数使用 `$(XmakeProjectDir)` 并 XML 引号转义，不依赖共享目录临时盘符。
- Windows `build_windows.bat debug` 增量构建通过（9.563 秒）；`run_windows.bat cli --help` 构建并执行真实 PE 返回 0（构建 8.375 秒）。Windows GUI 子系统没有把 help 文本写入本次捕获的 stdout，因此不把无输出误写成已观察到 CLI 文本。
- Windows 运行脚本的负向测试 `cli __xmake_invalid_command__` 中，真实 PE 返回 1，xmake 与 batch 正确传播非零状态；日志显示实际 executable / Assets / CLI 参数，确认不是只启动后就忽略失败。
- Gallery gates、Web audio state 与现有 dora-preset Release AudioWorklet WASM 实际回归测试通过；CI 路径过滤器去重并保留真实 Web 源码触发。
- tolua++ 新 shell wrapper 实际执行成功；XRT wrapper 的真正 C11/C++ header 编译测试通过；macOS doctor 0 errors / 0 warnings；非法 jobs 参数正确拒绝。
- 全 workflows `actionlint`、shell syntax、`git diff --check`、双语 Docusaurus production build 通过。构建/打包教程、engine development skill 与 CI 入口同步；其他设计文档中的历史日志不改写。

环境与复验注意：macOS xmake 3.1.1+20260827 / Xcode 27；Linux Lima xmake 3.0.7 / GCC 15；Windows ARM64 xmake 3.1.1+HEAD.3ba37a0d4 / VS 2026 / MinGW GCC 15.1。Windows ARM64 的旧默认 x64 xmake 在模拟层错误选择 x64 Rust；官方 ARM64 xmake 3.1.1 已校验 SHA-256 并放入 VM 本地隔离工具目录，未覆盖原安装。Windows ARM64 必须用原生 ARM64 xmake；文档与 Native task 的明确错误提示已补充，未保留无效的包架构覆盖绕过。Parallels 共享盘的临时盘符变化会改变绝对 include 路径，复验用临时 SUBST 保持同一盘符，退出后清理映射；这不是项目对固定盘符的依赖。

日志：`build/xmake-final-*.log`。本次启动的 Linux/Windows 测试 VM 验证后关闭，测试临时盘符清理；旧工程配置备份保留，未提交或推送。远端 CI/无缓存新主机、生产签名与分发、真机和 tag dry run 仍是独立发布门禁，不因本次本地清理而标为完成。

### 2026-10-01 / packaging 归入 Projects

将根目录 `packaging/` 整体移至 `Projects/packaging/`；AppRun 与 desktop 文件内容、源文件权限不变。Linux xmake 打包任务的资源路径和 AppImage workflow 的 push / pull_request 路径过滤同步更新，旧根目录已移除。其余 CI 无旧路径引用，无需修改。

验证：全 workflows `actionlint`、路径过滤去重、AppRun shell syntax、`git diff --check` 通过；仓库现有引用全部使用新路径。Linux arm64 Release 实际 `xmake dora-package --platform=linux --arch=arm64 --mode=release` 打包成功，AppDir 中两份资源与新位置源文件逐字节一致，生成 AppImage 的 `--appimage-extract-and-run cli --help` 返回 0 并输出 CLI 帮助。日志为 `build/xmake-packaging-relocation-{linux,cli}.log`。验证后关闭本次启动的 Lima VM；未提交、推送或执行远端 CI。

### 2026-10-01 / Android 干净 checkout 绑定生成修复

远端 Android CI `36803673281`（提交 `280db5fa7`）在 CMake 配置阶段失败：`missing Android native source: Source/Lua/LuaBinding.cpp`。Go/gomobile 准备已越过此前失败点。导出器此前依赖 `target:fileconfig(file).always_added` 判断缺失绑定，未能识别干净 checkout 中不存在的生成文件；改为直接检查 `dora-lua-bindings` 声明的五份输出，缺失时先执行生成，再导出 CMake target 图。

本地复验使用待提交 Git tree 的隔离归档（约 256 MiB），没有原工作区的生成文件或构建缓存：首次 xmake export 自动生成全部绑定，导出 14 个 Android target；将五份输出移到测试备份后，直接配置正式 Android CMake 入口，NDK 26.1 / CMake 3.22.1 / arm64-v8a Debug 再次自动生成，配置与 Ninja 图生成成功。五份输出均非空，排除生成时间注释后与首次输出一致，Touch source 检查通过。日志：`build/android-clean-export-config.log`、`build/android-clean-export.log`、`build/android-clean-cmake.log`。本次没有在隔离目录重编完整 APK；完整 Linux host APK 交由新提交的 Android CI 复验。

用户授权将剩余变更一起提交：Touch 鼠标来源/按键/连击声明及 tolua header、LoveNode 失败初始化生命周期修复随本次修正提交；其他 detached worktree 的变更不在本次工作区范围内。

### 2026-10-01 / 验证统一到 main

`ci/xmake-migration` 的提交已全部包含于 `main`，`git merge --ff-only` 返回 Already up to date，不创建无意义的 merge commit。AppImage workflow 移除 `ci/**` push 入口及仅验证分支打包的条件；main / PR / 手动触发统一构建、校验并下载当前提交的 Web IDE 资产，双架构执行 Release AppImage 打包及上传。Debug 继续由独立 Linux workflow 验证，避免在 AppImage workflow 冗余构建。旧远端验证分支保留历史，后续不再用它触发验证。

同步修复 lddtree 探测和执行的 Python 环境：优先系统 bin 路径，避免 hosted Python 缺少发行版 pyelftools。用前置 `python3 -S` 的隔离 wrapper 复现 `ModuleNotFoundError: elftools`；同一环境下新 task 实际 arm64 Release AppImage 打包成功，自解包运行 CLI help 返回 0。日志：`build/lddtree-hosted-python-negative.log`、`build/xmake-main-appimage-validation.log`、`build/xmake-main-appimage-cli.log`。actionlint、main/PR/manual workflow 路径检查、diff whitespace 检查通过。新 main CI 的远端 AppImage 产物仍须独立验收。

## 9. 证据记录模板

### M9 / 统一任务入口与外部测试迁移：🟡 进行中

- 盘点主项目构建、测试及隐藏路径引用；保留 Dora-Example 已有未提交 Studio 测试改动。
- 接入远端默认分支最新 HEAD 的测试依赖、统一 xmake 构建/打包/测试命令，迁移 Web/IDE 脚本与夹具。
- 更新双方 CI、内部调用和操作文档；逐套件实际验证，未通过前不标记完成。

2026-10-01 实施与验收记录（本地未提交）：

- 已删除整个 `Tools/build-scripts`，无兼容 wrapper；四个正式 Web 打包/画廊工具位于 `Projects/xmake/tools/web`，Wa 构建/同步编排改用 Lua task + 受管 Go target，源码收集 Python 属于正式工具。
- 109 个测试/夹具文件迁至 `/Users/Jin/Workspace/Dora/Dora-Example/Test`；其中 Native 包含 18 个 C++ 测试入口，主体及原内嵌测试块外移。`Source/Test/Test.{cpp,h}` 注册接口保留。独立 Node/Lua/Python/原型浏览器测试外移；生态包内测试及生产模板保持原结构。
- Dora-Example 原有 `.gitignore`、DoraStudio runner 与多项测试文件的本地改动保持原样；新增文件不覆盖既有文件。主引擎基线 `f608c863d46ccf7ea9d51a5dc52ddb571fbfee69`，测试基线 `4cc17420a53b7501370a0b19389b263c26a9678a`，均含本次未提交修改，结果 JSON 另记录 dirty 标记。
- `git ls-remote --symref ... HEAD` 证实外部默认分支为 master；获取逻辑跟随远端 HEAD，不硬编码 main、不锁 commit、不回退旧缓存。显式本地路径保持 dirty checkout；受管输入按本次最新 SHA 建独立 worktree，避免并发更新正在编译的输入。
- 主仓库 9 个 CI 工作流与实际消费方（Studio、Web IDE、Docs、当前教程及工程开发 Skill）已改用根 task。外部新增 `engine-tests.yml`：master 的测试变化验证主引擎最新 main，PR 验证提议中的测试代码，无旧引擎矩阵。

本机 macOS ARM64，xmake v3.1.1+20260827；外部套件使用 `DORA_TEST_REPO=/Users/Jin/Workspace/Dora/Dora-Example`：

| 验证 | 实际结果 / 日志（均在主仓库 build 下） |
| --- | --- |
| `xmake dora-test` | 7 个契约用例全部通过，含 Lua UTF-8；`xmake-external-contract.log` |
| `xmake dora-web --jobs=4` | 普通 preset Release 构建、链接、分发通过，未获取测试仓库；`xmake-web-production.log` |
| `xmake dora-web --tests --jobs=4` | 外部夹具与 Love probes 实际编译、链接通过；`xmake-web-external.log` |
| `xmake dora-test --suite=web` | 4 项全部通过，WebAssembly、Player 包、能力及 forbidden deps；`xmake-external-web-checks.log` |
| `DORA_WEB_RELOADS=1 xmake dora-test --case=check_web_browser -- result/dora-web-player build/xmake-external-web-browser.png` | Chrome 154，渲染/输入/音频/网络/存储/stop/reload 全流程通过，unexpected errors=0，lifecycle warnings=0；`xmake-external-browser.log` |
| `xmake dora-wa-web` + `dora-test --case=check_wa_web -- result/dora-wa-web` | 真正生成 wasm 并通过浏览器 Wa smoke；`xmake-wa-web.log` |
| `xmake dora-wa-sync --source=/Users/Jin/Workspace/wa --dry-run` | 验证源路径通过；未替换 vendor 源码，真实同步未执行；`xmake-wa-sync.log` |
| `xmake dora-studio` | 专用引擎构建与宿主 manifest/导出/Fetch streaming 门禁通过；`xmake-studio.log` |
| `xmake dora-build --tests --jobs=4` | 外部 C++ / .inc 编译、完整 Debug 链接及 App 生成通过，117.068 秒；不代表 18 项交互/压力测试逐项运行；`xmake-native-external.log` |
| `xmake dora-build --mode=debug --jobs=4` | 无外部测试的 Native 完整 Debug 重编/链接通过，113.084 秒；`xmake-native-production.log` |
| `xmake dora-ide --platform=macosx --kind=xcode` | 包含新增工具 target 的 IDE 工程生成成功；`xmake-ide-migration.log` |
| Android arm64-v8a Debug 图导出 | 14 个 C/C++ target，`DORA_TEST=0`，无外部测试源路径；`xmake-android-migration.log`；未重建 APK |
| `dora-web-game` / `dora-web-preview` / `dora-web-rollback` | 真实生成游戏包和两版预览，回滚到前版通过；缺少前版时明确拒绝；相应 packaging/preview/rollback 日志 |
| `dora-test --case=check_web_preview -- result/dora-web-player` | release/hash/MIME/cache/atomic pointer/rollback 门禁全部通过；`xmake-external-preview.log` |
| `dora-test --suite=art` | 3 项 Python 图集回归全部通过；`xmake-art-tests.log` |
| `xmake dora-web-env` / `audit-manifests` | 受管工具 0 errors / 0 warnings，579 个唯一且存在的引擎源；`xmake-web-env.log` |
| 静态检查 | 两仓 `git diff --check`、所有迁移 JS/CJS 的 Node syntax、manifest 路径存在性、双方 actionlint 通过 |

保留的红灯与未验收项：

- Web IDE 完整套件初跑 31 项，29 通过；原 CLI 用例路径修复后最终完整复验 31 项，30 通过、1 失败（`xmake-external-webide-final.log`）。剩余 `test-agent-render-window` 断言 composer 使用 `Color.Background`，当前正式组件使用 `Color.BackgroundDark`；不改正式 UI、不降低断言来伪装绿色。
- 既有 `studio -- --no-build` 测试 337 项，265 通过、72 失败，包括旧 `Studio/apps/server/*.mjs` 路径及缺少构建输出；属于现有测试与当前 Go 服务结构/产物不一致，不是迁移 runner 路径丢失。其既有未提交测试改动未改写。
- 附加浏览器 API 契约能够找到迁移后的工具、打包并启动，但在默认 MUSIC=OFF preset 上要求 `Dora.Audio.renderMusicAsync` 而失败；需单独处理 profile-aware API 预期，不删除断言。
- 原型浏览器套件已迁移并接入 task，未重新启动静态服务/准备 Playwright 后跑全套；现有 DoraStudio 完整 build/browser 未验收；C++ 测试此轮只验证编译接入。
- 真实 Wa 同步、发行画廊全量重建、iOS/Windows/Linux 完整平台构建及远端 CI 未在此轮重新执行；已有 M8 证据与本次验证分开。
- 必须先发布 Dora-Example 再发布引擎；未提交/推送，不能将改过的 CI 标成远端通过。M9 的实现已落地，验收因上述既有测试红灯与发布门禁保持进行中。
- `xmake dora-test-deps` 已实际下载远端默认分支 HEAD `4cc17420...` 并创建独立 worktree；由于远端尚无本次 `Test/manifest.json`，按设计明确失败并提示发布或使用本地路径，没有退回旧测试套件。首次 main 分支假设通过实际 fetch 被纠正为跟随 remote HEAD；clone/worktree 缓存约 108 MiB，位于忽略的 build/tests。

### 2026-10-01 / M9 测试红灯修复（替代上述本地失败状态）

没有改正式 UI 或降低运行时安全门禁；修复的是测试与当前实现、构建输入的契约漂移：

- Web IDE 样式断言对齐 `56668eb67` 的当前设计：外层 composer 与 transcript 共用 Background，带边框的输入面保持 BackgroundDark。分别验证两层，不再把旧内层颜色当当前产品契约。
- Web API 期望按实际 `modules.musicGenerator` 声明生成，仅在关闭 Music 时排除条件注册的 `Audio.renderMusicAsync`。开启时仍严格要求存在；缺失 capability 声明直接失败。新增回归测试验证 ON/OFF 与缺失声明，其他必需 API 不减少。
- Studio runner 默认先 `pnpm -r build`，刷新文档、合同、编译器及 Web 产物；不把正式宿主/服务器发布打包当作单元测试前置条件。`--no-build` 明确只用于已有当前产物。
- 45 个导入已删除 Node 服务模块的实现级测试完整保留至外部 `Test/DoraStudio/legacy-node`，包括原有 agent-model-route 和 queue 未提交改动；没有删除内容或恢复旧 Node 服务。当前后端由新增 `backend-go.test.mjs` 调用真实 `go test -race -count=1 -json ./...` 验收，并按 `backend-contract.json` 强制检查 15 个当前服务测试分组确实通过。这不是每条旧 Node 内部断言一对一保留的声明。
- 前端 harness 统一 React 解析，消除两个 React 实例造成的假 hook 错误；夹具补齐三层额度、可信 Music 支持文件与 Player engineVersion。更新租约主动中断用户运行、草稿可编辑但发送受限、显式产物必须匹配当前 revision 等已实现行为，并保留负向检查。TSTL 禁止引用 IDE 源码，但不误拒绝 pnpm 共用 node_modules 的物理路径。
- 主仓 UI CI 与外部测试 CI 新增 Studio 全套检查、稳定版 Go 和 Studio 冻结依赖安装。只更新配置，未推送或声称远端运行通过。

最终本地证据（测试库仍使用明确的本地路径，两个仓库均未提交）：

| 命令 / 套件 | 结果 | 日志 |
| --- | --- | --- |
| `xmake dora-test` | 8/8 个用例通过，包括新 API profile 正反向测试 | `build/contract-tests-fixed.log` |
| `xmake dora-test --suite=web-ide` | 31/31，通过真实 CLI、编译协议、运行时准备等 | `build/webide-tests-fixed.log` |
| `xmake dora-test --suite=studio -- --no-build`（预先已构建） | 293/293，0 failed / 0 skipped；其中 Go wrapper 实际验收 15 个 race 分组 | `build/studio-tests-fixed-final.log` |
| `pnpm --dir Studio install --frozen-lockfile` + `xmake dora-test --suite=studio` | 冻结安装、默认 workspace 全构建后再验收，293/293；Go 15 组实际通过（10.155 秒） | `build/studio-test-install.log`、`build/studio-tests-build-final.log` |
| `xmake dora-test --suite=web` | 4/4，Player/WASM/能力/依赖门禁复验通过 | `build/web-tests-fixed.log` |
| 独立 `go test -race -count=1 ./...` | 当前 Go 服务测试通过（10.209 秒） | `build/studio-go-tests.log` |
| `check_web_api_contract -- result/dora-web-player` | MUSIC=OFF，真实 Chrome 运行并输出 `DORA_WEB_API_CONTRACT_PASSED` | `build/web-api-contract-fixed.log` |
| `check_web_api_contract -- result/dora-studio-agent-engine` | MUSIC=ON，同一 API 检查器真实 Chrome 通过，未遗漏 Music API | `build/web-api-music-on-fixed.log` |
| 静态检查 | 两仓 diff check、全部迁移/当前测试 JS syntax、45 个 archive 文件存在性及双方 actionlint 通过 | 本地命令输出 |

本次解决的是已报告红灯；不把单元/集成测试等同完整 Studio 浏览器验收，也不改变上一条的跨平台、生产发布及真实 Wa 同步证据边界。旧失败日志保留用于追溯，当前状态以此条为准。

### 2026-10-01 / M9 删除失效 Node 后端测试

- 按用户确认，删除 Dora-Example 中 45 个依赖已移除 Node 服务模块的测试，不再保留 `Test/DoraStudio/legacy-node/`；上条存档状态由本条取代。
- 删除前核对目录文件与登记清单完全一致，并确认每个文件仍引用旧 `apps/server/` 模块。有效前端测试及当前 Go 验收组未删除；Go 的旧数据/失效 schema 拒绝测试仍属于有效安全回归。
- 清理 `backend-contract.json` 中的旧测试清单，更新 README 和 Go 验收输出。包含此前未提交修改的完整删除前副本移入本机废纸篓 `/Users/Jin/.Trash/dora-obsolete-tests-zAICL7/legacy-node`，可恢复，不属于项目源码。
- 复验：`DORA_TEST_REPO=/Users/Jin/Workspace/Dora/Dora-Example xmake dora-test --suite=studio -- --no-build`，293/293 通过、0 失败、0 跳过；其中实际执行 15 组 Go 验收并启用 race detection。证据：`build/studio-tests-obsolete-removed.log`。
- 两仓 `git diff --check` 及 Go 验收入口 JS 语法检查通过；本次未提交、未推送，远程 CI 未验证。

### 2026-10-01 / M9 首轮远端 CI 入口修复

- 已发布基线：Dora-SSR `73176014d`、Dora-Example `6396cca`。主仓首轮 Android、iOS、macOS、Linux、Web、Docs 通过；Windows、UI CI、Linux AppImage 失败。测试仓 Web 通过，contracts 在原生测试引擎成功编译后因 Web IDE 产物缺失失败。
- Windows：外部 runner 的 Node `--import` 路径改用 `pathToFileURL(...).href`，修复盘符被当作 `d:` URL scheme 的错误。
- UI/AppImage：真实复现 `xmake -P ../.. dora-test` 被解析为默认 build；改为任务名先行的 `xmake dora-test -P ../..`，同步修复 UI workflow、所有 Web IDE package scripts 与 Docs gallery/test 入口。不通过安装无关 SDL2/Rust 依赖来掩盖解析错误。
- 外部 Web IDE 完整验收：xmake 自动执行 `pnpm build`，准备 Web runtime 与 Vite 产物后才运行套件，修复干净 CI 缺失 `build/index.html` 和 HTML runtime 的问题；保留全部 31 个检查。
- 新增外部契约回归：扫描嵌套入口参数顺序，并在独立临时配置目录从 Web IDE 子目录执行测试列表，确认不触发平台探测/引擎依赖安装。
- 本地 macOS 验证：contract 9/9、完整 Web IDE 31/31、嵌套目录 Studio 293/293 通过；AppImage 失败入口对应的 `pnpm test:web-runtime-preparation` 及另一个 pnpm 单测入口通过。证据：`build/ci-contract-fixed.log`、`build/ci-webide-fixed.log`、`build/ci-studio-entrypoint-fixed.log`、`build/ci-runtime-preparation-fixed.log`。
- 两仓 diff check、外部 runner JS syntax 和双方 actionlint 通过。本轮修复尚未提交/推送；Windows 虚拟机 Tools 无法建立执行会话，未声称 Windows 本机复验通过；远端 CI 仍需重跑验收。

### 2026-10-01 / M9 Studio 干净 CI 前置依赖修复

- 第二轮基线 Dora-SSR `27fd2132c` / Dora-Example `a8e0486`：UI CI 已通过入口/契约阶段，随后在 Studio 构建中因未生成 `Assets/Doc/en/Tutorial` 失败（run `36824076363`）。这是干净 checkout 前置条件缺失，不是旧 Node 测试复发。
- `dora-test --suite=studio` 默认在独立 `build/studio-tests/.xmake-config` 配置 xmake 托管 Emscripten，不编译完整 Player；辅助 Lua 入口从 host-tools 获取 SDK 环境并设置 `STUDIO_EMCC` / `STUDIO_EMXX`，避免下一阶段依赖开发机全局 emcc。
- 同一入口先执行规范 Docs 生成器，再运行完整 Studio build/test。`-- --no-build` 与 `--list` 不安装 SDK 或重新生成产物，继续要求调用者已有有效构建。
- 外部测试仓新增真实回归：在没有 Assets/Doc 的临时 checkout 中运行规范教程生成器，检查双语 Lua 教程输出；原有参数顺序和嵌套目录列表回归继续通过。
- macOS 实测：默认完整 Studio 流程 293/293 通过（含实际 Go race 验收）；入口/干净文档回归 3/3 通过，证据 `build/ci-studio-prerequisites-fixed.log`。本轮修复尚未提交/推送，远端复验待后续提交。

### 2026-10-01 / M9 统一测试 CI 归属

- 按用户最新决定，删除 Dora-Example 的 `.github/workflows/engine-tests.yml`，结束外部测试仓的独立 CI；历史双仓 CI 记录保留追溯，以本条为当前归属。
- Dora-Example 继续保存测试源与本地 runner，Dora-SSR 保留现有构建、打包及测试工作流并拉取最新测试版本。本次不迁移 GitHub runner 或配置 GPU 测试机。
- 只改测试仓不会自动触发主仓 CI；需本地验证或手动触发 Dora-SSR 对应 workflow。方案与测试 README 已同步说明该边界。
- 本次删除的是 workflow 配置，不删除测试代码；可通过 Git 恢复。尚未提交/推送，因此远端已运行的旧任务不受本地删除影响。

每次更新进度时追加一条：

```text
日期：YYYY-MM-DD
任务：M?.?
提交/PR：<SHA 或 URL>
环境：<OS、架构、设备/浏览器、xmake 版本>
执行命令：<精确命令>
结果：<通过/失败及关键输出>
产物：<路径、架构、哈希或包内容>
运行时验证：<启动、设备、浏览器或截图证据>
未验证项：<明确列出>
```

## 10. 更新规则

- 任务开始时改为 🟡，不要预先标记完成；
- 同一阻塞重复且无法继续时才改为 🟠，并记录阻塞条件；
- 只有完成标准和证据都齐全时改为 ✅；
- 平台矩阵每一列必须独立更新；
- CI、运行时、设备和发布验证必须分开记录；
- 任何范围、技术决策或完成标准变化，都要先更新 PLAN，再更新本表。
