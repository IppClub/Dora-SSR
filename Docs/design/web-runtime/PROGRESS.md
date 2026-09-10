# Dora Web 运行时开发进度

本文用于跟踪 [Dora Web 运行时适配设计](./README.md) 的阶段状态、任务依赖、验证证据和阻塞项。

最后更新：2026-09-09

## 1. 状态规则

| 状态 | 含义 |
| --- | --- |
| 未开始 | 尚无实现或验证工作 |
| 进行中 | 已进入实现，但尚未达到验收标准 |
| 待验证 | 实现已完成，仍缺要求的构建、浏览器或设备证据 |
| 已完成 | 实现、自动测试、要求的运行证据和文档均已具备 |
| 阻塞 | 存在明确且当前无法绕过的外部或技术阻断 |
| 延后 | 已明确不属于当前里程碑，但仍保留后续计划 |
| 不适用 | 经设计确认无需实现，并记录原因 |

更新要求：

- “已完成”必须填写提交、测试输出、截图、报告或 CI URL；空证据不能标记完成。
- CMake 配置通过、编译通过、WASM 实例化、首帧出现和功能正确分别记录。
- 渲染、坐标、Canvas、shader 和文字任务必须附截图或像素证据。
- 输入、音频、持久化和页面生命周期任务必须附真实浏览器或设备证据。
- 本地 Chrome 结果不能外推 Firefox、Safari 或移动浏览器。
- PR #122 的原型结果只作为研究证据，不直接计入本方案的实现完成度。
- 状态变更时同步更新本文日期、阶段总览、任务行和验证记录。
- 负责人未确定时保持“未分配”，不虚构负责人或完成日期。

## 2. 阶段总览

| 阶段 | 目标 | 状态 | 完成度 | 阶段门槛 |
| --- | --- | --- | ---: | --- |
| D0 | 产品边界、架构与原型审计 | 已完成 | 100% | 设计、进度表、PR #122 审查结论已记录 |
| P0 | 干净、可复现的 Web 构建 | 进行中 | 89% | CI 产出可实例化的最小 WASM 包 |
| P1 | 最小 Web Player 与主循环 | 已完成 | 100% | 浏览器显示首帧并可可靠启动/停止 |
| P2 | manifest、资源、网络与持久化 | 已完成 | 100% | 游戏按需加载且存档刷新后恢复 |
| P3 | 输入、音频与页面生命周期 | 进行中 | 60% | 桌面和移动核心交互通过 |
| P4 | Dora 子系统覆盖与发布工具 | 进行中 | 90% | Player 首版能力和发布 profile 达标 |
| P5 | LoveNode Web 兼容 | 进行中 | 95% | 基础 Love fixture、非阻塞启动、复杂图形、shader、音频长稳及复杂项目输入锁定通过；指定 Balatro 包已完成牌局到商店、真实存档及 20 次 reload，尚缺该复杂项目自身的 30 分钟长稳 |
| P6 | Web Workspace | 延后 | 0% | 导入、编译、运行和错误恢复闭环 |
| P7 | 发布矩阵与长期维护 | 进行中 | 29% | 正式发布门禁、文档和兼容矩阵闭合 |

总完成度只按任务验收结果统计，不按代码行数或开发时间估算。

## 3. D0：设计与基线审计

目标：明确产品边界，吸收已有原型经验，并建立可执行的任务和证据规则。

| ID | 任务 | 依赖 | 状态 | 负责人 | 验收标准 | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| D0-01 | 审查 PR #122 的范围、架构与已知限制 | 无 | 已完成 | Codex | 区分平台层、Love 兼容层、诊断代码与未验证声明 | [PR #122](https://github.com/IppClub/Dora-SSR/pull/122)；2026-09-08 本地只读审查 |
| D0-02 | 验证 PR #122 的干净构建前提 | D0-01 | 已完成 | Codex | 从干净 worktree 执行构建并记录首个失败与补充生成后的结果 | 2026-09-08：缺少 `LuaBinding.cpp`、`LuaCode.cpp`、`TealCompiler.cpp` 导致 CMake 失败；补生成后 macOS 编译约 60% 时遇到 Love/Dora `physics/Body.h` 大小写路径冲突；临时 worktree 已清理 |
| D0-03 | 确定 Web Player 优先、Workspace 与 Love 后置 | D0-01 | 已完成 | Codex | 产品边界、首版目标和非目标明确 | [设计 §1—4](./README.md#1-最终决策) |
| D0-04 | 建立架构、阶段、验收和进度跟踪文档 | D0-03 | 已完成 | Codex | README 与 PROGRESS 互链，阶段和完成定义一致 | 本目录文档；`git diff --check` |

## 4. P0：可复现 Web 构建

目标：从干净 checkout 生成最小、可实例化、可由 CI 重建的 Dora WASM 产物。

| ID | 任务 | 依赖 | 状态 | 负责人 | 验收标准 | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| P0-01 | 抽取 Linux/Web 共享 CMake engine source target | D0-04 | 已完成 | Codex | 不解析其他 CMake 文件文本；Linux 与 Web 使用同一受控 source list | `Projects/CMake/DoraEngineSources.cmake`；与改动前 Linux 578 项 source list 做规范化 `diff`，无差异 |
| P0-02 | 将 tolua++ 生成纳入 Web 构建依赖 | P0-01 | 已完成 | Codex | 干净 checkout 自动生成三个 Lua binding 源文件 | `DoraGeneratedSources.cmake`；独立 CMake harness 实际执行 `dora-lua-bindings`，三个输出均成功生成 |
| P0-03 | 固定 Emscripten/Rust/Go/Node/CMake 工具链 | P0-01 | 已完成 | Codex | 本地和 CI 版本一致，版本漂移可见 | `Projects/Web/toolchain.env` 与 `check_web_build_env.sh`；本机默认工具链按预期拒绝，隔离安装 Emscripten 3.1.74/Rust 1.85.1/Go 1.24.3/Node 22.14.0/CMake 3.30.5 后五项精确通过，并用相同环境完成 release Player 构建与浏览器测试 |
| P0-04 | 建立可裁剪的 minimal Player feature profile | P0-01 | 已完成 | Codex | 默认覆盖 Dora 2D 游戏，模块可由开关裁剪 | `DORA_WEB_PROFILE` 提供 `core`、默认 `dora-preset` 与 `custom`；2D Physics、Entity、Platformer、标准 Lua 库分别可配置且依赖关系在 CMake 配置期校验；共享 binding 使用 compile guard 去除未启用 API；Chrome 152 中 Loli War、Zombie Escape、Dismantlism 均完成真实启动与持续运行 smoke |
| P0-05 | 完成 Rust `wasm32-unknown-emscripten` 构建 | P0-03 | 已完成 | Codex | static library 从干净 target 构建并链接，无本机缓存依赖 | 全新安装 Rust 1.85.1 与 `wasm32-unknown-emscripten` target 后完成 release static library 并链接 Emscripten 3.1.74 probe；固定 `image=0.25.9`、替换两个 1.87+ API，构建脚本使用 `--locked` 防止依赖漂移 |
| P0-06 | 生成最小 HTML/JS/WASM 包 | P0-02、P0-04、P0-05 | 已完成 | Codex | WASM 可在 Node/browser 中实例化，导出 API 与设计一致 | 标准构建同时产出 probe 与真实 Player HTML/JS/WASM/data；Player 在本机 HTTP 浏览器执行 Lua bootstrap 并显示 DrawNode 首帧 |
| P0-07 | 建立产物静态检查和体积报告 | P0-06 | 已完成 | Codex | 检查文件、符号、禁止依赖、raw/gzip/brotli 大小 | 三个检查器覆盖完整性、WASM、Canvas、生命周期导出、manifest 与资产精确匹配、20 MiB gzip 门禁、pthread/shared memory、Asyncify、动态链接、原生工件、构建路径、凭据和高风险模块误链接标记；`dependency-report.json` 全部为空/false；加入 P4-06 feature profile 后，锁定 Emscripten 3.1.74 的 minimal Player 为 2,285,262 B gzip/1,940,159 B brotli |
| P0-08 | 建立 Ubuntu/macOS Web CI | P0-07 | 待验证 | Codex | 双平台新 checkout 完整构建成功，Ubuntu 上传 artifact | `.github/workflows/web.yml` 已配置 Ubuntu/macOS 固定工具链矩阵、全量构建、静态门禁和 Ubuntu Headless Chrome 像素冒烟；`actionlint` 与 YAML 解析通过，尚未在 GitHub Actions 运行 |
| P0-09 | 完成 macOS 开发者构建冒烟 | P0-06 | 已完成 | Codex | 不发生大小写 include 冲突，文档命令可复现 | macOS 26.6.2 上无 Asyncify 的 minimal Player 及 bgfx/WebGL2 依赖链接成功，无 Love/Dora include 冲突；Xcode 26.6 arm64 Debug 原生目标在当前改动后重新全量构建并 `BUILD SUCCEEDED` |

## 5. P1：最小 Web Player

目标：浏览器中启动 Dora、运行最小 Lua 场景并稳定提交首帧。

| ID | 任务 | 依赖 | 状态 | 负责人 | 验收标准 | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| P1-01 | 实现 WebApplication 生命周期状态机 | P0-06 | 已完成 | Codex | Booting/Ready/Running/Stopping/Stopped/Faulted 转换可测 | HTML/DOM 暴露六态契约和 `doraStop`；真实浏览器验证 running→stopping→stopped 并确认对象释放；缺失 manifest 验证 faulted 状态与用户可见错误文案 |
| P1-02 | 实现单线程浏览器主循环 | P1-01 | 已完成 | Codex | SDL event、logic、render、`bgfx::frame()` 顺序固定 | `Application.cpp` 的 Emscripten callback 已在真实 Player 连续运行，Lua 首帧后保持稳定，无同步 while-loop 阻塞 |
| P1-03 | 初始化 SDL Canvas 与 bgfx WebGL2 | P1-02 | 已完成 | Codex | WebGL2 context 创建，清屏 fixture 通过 | SDL Canvas、bgfx HTML5 context 和 WebGL2 链接运行通过；浏览器显示深色清屏背景及绿色 DrawNode fixture |
| P1-04 | 支持 resize、DPR 和 fullscreen 尺寸更新 | P1-03 | 已完成 | Codex | CSS/drawable/visual size 在缩放和全屏后正确 | Chrome 152 模拟 DPR 2：800×600 时 visual=800×600、buffer=1600×1200，动态改为 1000×650 后为 2000×1300；双击 Canvas 进入全屏后 `fullscreen=true` 且 drawable 保持 2×，再次双击恢复 1280×720/2560×1440 与 false，全程无 warning/error |
| P1-05 | 启动 LuaEngine 和最小 `init.lua` | P1-02 | 已完成 | Codex | Hello World 场景运行并产生首帧 | `Projects/Web/runtime-assets/Script/init.lua` 在浏览器打印 ready，并通过 DrawNode 绘制 360×180 绿色矩形 |
| P1-06 | 完成 Sprite/Label 基础视觉冒烟 | P1-03、P1-05 | 已完成 | Codex | 固定截图与基线一致，无上下颠倒或 DPR 偏差 | minimal binding 与 demo fixture 已接入 Sprite/Label；游戏包使用 logo 和从仓库字体裁出的 46,748 B 子集；`check_web_browser.mjs` 在固定 1280×720 截图中断言 logo、绿色 DrawNode 和白色 Label 的颜色/位置区间，Chrome 152 本机通过且无错误 |
| P1-07 | 实现可重复启动、停止和错误页 | P1-01、P1-05 | 已完成 | Codex | 连续 20 次 reload 无旧 callback、节点或 GPU 资源残留 | 锁定工具链 Player 在 Headless Chrome 连续 20 次 reload，每次恰好一个 ready 且首帧像素通过；强制 GC 前后 document 1→1、node 17→17、listener 29→29、JS heap 1,879,188→1,867,696 B，无 error、context lost、context 数量耗尽或 OOM；stop/fault 路径已有独立浏览器证据 |
| P1-08 | 建立 Headless Chromium 首帧测试 | P1-06 | 已完成 | Codex | CI 静态服务器中启动、等待 ready、截图并断言像素 | `check_web_browser.mjs` 使用 Node 内置 HTTP/CDP/PNG 解码，无额外 npm 依赖；本机 Chrome 152 通过，CI Ubuntu job 已接入并上传 `dora-web-browser-smoke`，外部 workflow 运行仍由 P0-08 跟踪 |

## 6. P2：资源、网络与持久化

目标：不依赖全量 preload，按 manifest 安全加载游戏，并持久化设置和存档。

| ID | 任务 | 依赖 | 状态 | 负责人 | 验收标准 | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| P2-01 | 定义并解析 `dora-web-manifest.json` v1 | P1-05 | 已完成 | Codex | 格式、版本、profile、entry、size、hash 校验完整 | `web-loader.js` 校验格式/版本/engine/profile/entry、路径、重复项、同源 URL、文件数/大小和 SHA-256；`check_web_loader.mjs` 含合法及 6 类拒绝用例 |
| P2-02 | 实现 WebContent 虚拟路径 | P2-01 | 已完成 | Codex | `/builtin`、`/game`、`/user`、`/tmp` 行为与设计一致 | Chrome 152 在真实 Player 断言 `/builtin/README.txt`、`/game/init.lua`、三个 `/user` 持久目录和会话级 `/tmp`；导入 staging 位于同一 IDBFS mount，reload 恢复通过 |
| P2-03 | 实现按需 Fetch 和并发去重 | P2-02 | 已完成 | Codex | 同一资源并发请求只下载一次，失败可重试 | Web `Content.loadAsync*()` 在 `/game` 文件缺失时调用 `WebAssetLoader`；`fetchPath()` 校验 manifest 后原子挂载并按路径共享 Promise。Node 测试证明非启动资源不预取、两次并发只请求一次、首次 503 后可重试；Chrome 152 真实 Player 依次请求 hash `init.lua` 与 `lazy.txt`，Lua 校验内容后进入 running 并显示首帧 |
| P2-04 | 接入浏览器缓存与版本失效 | P2-03 | 已完成 | Codex | hash 资源长期缓存，manifest 更新后不读旧内容 | manifest 固定 `no-cache`、hash 资源固定 `force-cache`；Node 测试切换 v2 manifest/hash 后替换旧 entry、删除被移除的 lazy 文件并证明旧 MEMFS 内容不可复用 |
| P2-05 | 实现 Fetch HttpClient adapter | P1-01 | 已完成 | Codex | GET/POST、状态码、超时、取消、进度和大小限制通过 | `WebHttp.cpp` 使用异步 Emscripten Fetch，按 client 隔离 request/cancel/stop 并设 64 MiB response、512 MiB download 上限；Chrome 152 通过 `DoraWebNetwork` 验证 GET、POST、418 状态、timeout、cancel、流式进度、64 MiB 硬上限和同源门禁 |
| P2-06 | 明确禁用浏览器入站 HttpServer | P2-05 | 已完成 | Codex | start/startWS 返回 unsupported，脚本端获得明确能力状态 | C++ `start/startWS` 返回 false；Player host script 的 `DoraWebNetwork.capabilities`/`Module.doraWebCapabilities` 明确标记 HTTP/WS server=false 并返回 `browser pages cannot bind inbound TCP/HTTP ports`，Chrome 断言通过 |
| P2-07 | 挂载 IDBFS 并实现启动恢复 | P1-01 | 已完成 | Codex | ready 前完成 populate，刷新后设置与存档恢复 | preRun 在 Dora main 前挂载 `/user` 并等待 `syncfs(true)`，随后创建 saves/settings/projects；浏览器写入、flush、刷新、populate、读取往返通过 |
| P2-08 | 实现写入批处理、sync 和失败恢复 | P2-07 | 已完成 | Codex | 写入不会每帧 sync；配额和 sync 失败可报告 | `doraQueueUserStorageSync()` 250 ms debounce、共享 Promise、并发去重和 in-flight 后续 flush 均由 Node 覆盖；QuotaExceeded 映射、失败清状态重试通过，Chrome 合批写入后 reload 内容一致 |
| P2-09 | 实现 `.dora` 安全导入 | P2-02、P2-07 | 已完成 | Codex | 路径、大小、数量、重复项检查和原子安装通过 | `web-package.js` 在写盘前检查 ZIP header/范围/CRC、路径/NFC+大小写重复、symlink、加密/ZIP64、文件配额和 `dora-package.json`；Node 负向用例及 staging/rename/sync rollback 通过；Chrome 152 在真实 IDBFS 安装压缩 fixture 后 reload 读取一致，不自动执行代码 |
| P2-10 | 建立独立游戏发布打包脚本 | P2-01、P2-04 | 已完成 | Codex | 生成 hash 资源、manifest 和可直接托管目录 | `package_web_game.mjs` 递归收集、拒绝符号链接/危险路径、限制文件大小并生成 hash 资产与原子 manifest；标准 Player 包已通过 HTTP 直接托管 |

## 7. P3：输入、音频与页面生命周期

目标：桌面和移动浏览器能够正确交互、播放音频并从页面状态变化中恢复。

| ID | 任务 | 依赖 | 状态 | 负责人 | 验收标准 | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| P3-01 | 接入键盘和焦点释放 | P1-04 | 已完成 | Codex | key down/up、失焦合成释放和重复键语义通过 | Chrome 152 通过 CDP 真实 keyDown/keyUp 驱动 Dora `Keyboard` 状态；按下后触发 `blur`，宿主合成释放且 Lua 状态和宿主 pressedKeys 均归零 |
| P3-02 | 接入鼠标、Pointer 和滚轮 | P1-04 | 已完成 | Codex | DPR/缩放/全屏下坐标一致 | Chrome 152 真实 SDL/Dora 状态验证左键 down/up、wheel 和 320×240 坐标；结合 P1-04 的 DPR 2、resize/fullscreen 原子尺寸证据通过，边界限于桌面 Chromium |
| P3-03 | 接入多点触摸和触点 ID | P1-04 | 进行中 | Codex | Android/iOS 浏览器按下、移动、取消、释放通过 | Chrome 152 触摸仿真通过双触点 distinct ID、移动、释放及 `touchCancel` 合成释放；Android/iOS 真机尚未验证 |
| P3-04 | 接入 Gamepad | P3-01 | 待验证 | Codex | 连接、断开、按键、轴和失焦恢复通过 | minimal Lua binding 已暴露 `Controller`；Chrome 152 在浏览器 Gamepad API 边界注入 standard mapping 设备，经 Emscripten SDL/Dora 验证连接、A 键、leftx 轴、失焦强制归零、后台松开后恢复和带按下状态断连；仍缺真实 Gamepad 人工证据 |
| P3-05 | 建立 AudioContext 用户手势解锁 | P1-05 | 已完成 | Codex | 解锁前状态明确，点击/触摸后可播放 | `DoraWebPlatform` 在 key/pointer 手势或显式调用时恢复 SDL2 AudioContext；Chrome 152 断言解锁后 `audioUnlocked=true`、context=`running` 并完成 Dora WAV 播放 |
| P3-06 | 接入 WAV/OGG 和基础混音 | P3-05 | 已完成 | Codex | 播放、暂停、循环、音量、停止通过 | 构建生成确定性 PCM16 WAV 和内嵌 Vorbis OGG fixture，Chrome 152 中 Dora `Audio` 对两种格式完成加载/play/stop，并对循环、暂停和 globalVolume 完成断言；生成不依赖宿主 ffmpeg |
| P3-07 | 修正音频设备和 callback 生命周期 | P3-06 | 已完成 | Codex | 快速重启和设备恢复不调用旧 WASM 指针 | SoLoud SDL2 static backend 使用每设备 data；device lock 内先清 generation/SoLoud 指针再 close，避免全局设备串扰和旧 userdata；Web stop 先清空/断开 ScriptProcessor callback，Chrome 断言 SDL audio/AudioContext 均关闭，20 次 reload 无生命周期 warning 或 DOM/listener 增长；macOS 原生 backend 编译链接通过 |
| P3-08 | 处理 visibility、suspend 和 resume | P1-07、P3-07 | 待验证 | Codex | 前后台切换后逻辑、输入、画面和音频状态符合配置 | Web 主循环在 suspend 时继续泵送 SDL/任务队列，但冻结 Dora logic/render、`bgfx::frame()` 和帧计时；Chrome 152 显式验证隐藏期 engine frame 不增长、恢复后继续增长且重置 delta 基线，并通过第二个真实 tab 的 hidden→visible、输入释放、AudioContext suspended→running、恢复后完整测试和像素检查；移动端/Safari 与系统设备中断待测 |
| P3-09 | 接入文件选择回退 | P2-09 | 待验证 | Codex | File System Access API 和 `<input>` 两条路径可用 | `DoraWebPlatform.pickFiles()` 已实现两条路径；Chrome 通过真实 file chooser/CDP 选入 6 B `.dora` 验证 `<input>` 回退，替换 `showOpenFilePicker` 后验证原生适配契约；仍缺支持 File System Access 的真实 OS chooser 人工证据 |
| P3-10 | 评估 IME、虚拟键盘、剪贴板和鼠标锁 | P3-01、P3-02 | 已完成 | Codex | 形成能力矩阵并实现首版选定子集 | `DoraWebPlatform.capabilities` 按浏览器特性暴露 IME/virtualKeyboard/clipboard/pointerLock/音频格式；Chrome 152 获得明确 Clipboard 权限后完成 write/read 往返，真实点击后 Canvas 获取并退出 Pointer Lock；移动端差异由 P7 跟踪 |

## 8. P4：Dora 子系统与 Player 发布

目标：完成普通 Dora Web 游戏首版支持，并形成可维护的 profile 与发布门禁。

| ID | 任务 | 依赖 | 状态 | 负责人 | 验收标准 | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| P4-01 | RenderTarget、blend、scissor、stencil | P1-06 | 已完成 | Codex | 固定 fixture 截图和 readback 通过 | minimal Lua binding 暴露 RenderTarget/BlendFunc/ClipNode/ScissorNode；`build/web-browser-smoke-p4.png` 与 `build/web-render-target-readback.png`；192×192 readback 精确命中背景 24,064 px、blend 7,680 px、stencil 3,584 px、32×48 scissor 1,536 px；20 次 reload 与 macOS arm64 Debug 回归通过 |
| P4-02 | 粒子、Spine、DragonBones、NanoVG | P4-01 | 已完成 | Codex | 每个模块最小 fixture 和释放回归通过 | minimal binding 与 manifest 按需资源已覆盖四个模块；固定截图分别命中 Particle 255 px、Spine 2,480 px、DragonBones 3,077 px、NanoVG 背景 14,400 px/裁剪 4,800 px；20 次 reload 后 DOM/listener 不增长且无生命周期 warning/非预期 error；锁定工具链、静态门禁和 macOS arm64 Debug 回归通过 |
| P4-03 | PlayRho 2D 物理 | P1-05 | 已完成 | Codex | 确定性模拟和调试绘制通过 | Web minimal 只加入 2D wrapper 并以 `DORA_NO_3D_PHYSICS` 排除 Jolt bridge；Chrome 验证动态质量、重力、静态碰撞与 raycast，debug draw 命中静态地面 3,401 px/休眠动态体 1,452 px；20 次 reload、禁止 Jolt 标记、锁定工具链与 macOS 原生回归通过 |
| P4-04 | ImGui/基础系统 UI | P4-01 | 已完成 | Codex | 输入捕获、缩放、字体和裁剪正确 | minimal binding 暴露基础窗口、文字、按钮、样式、裁剪和 item bounds，并以 system scheduler 替换字体；Chrome DPR 1/2 截图验证 1280×720/2560×1440 缓冲、窗口和裁剪按钮物理像素倍增；按钮点击不泄漏到 Dora 场景输入；20 次 reload、锁定工具链、静态门禁和 macOS arm64 Debug 回归通过 |
| P4-05 | 评估 3D、Jolt、视频和高级纹理 | P4-01 | 已完成 | Codex | 每项形成支持/延后/不适用结论和证据 | 3D/Jolt/视频均明确延后且由发布产物标记门禁保持不入 minimal；RGBA8/D24S8 支持，浮点附件为按能力条件支持候选，压缩纹理需格式变体/回退后再承诺；Chrome WebGL2 报告记录 renderer、limits、float framebuffer 与 S3TC/ETC/ASTC/PVRTC 扩展并由 CI 上传 |
| P4-06 | 完成 minimal/full feature profile | P4-02、P4-03、P4-05 | 已完成 | Codex | 运行时能力查询与实际链接模块一致 | CMake 生成并发布 `dora-web-features.json` v1；宿主可从 `DoraWebPlatform.features`、`DoraWebFeatures` 与 `Module.doraWebFeatures` 查询同一 active profile；静态检查 required/excluded 模块，Chrome 验证三入口一致；`minimal` 可用，未验收的 `full` 明确 `available: false` 且配置时失败 |
| P4-07 | 达到首包和启动性能预算 | P2-10、P4-06 | 已完成 | Codex | 记录 raw/gzip/brotli 和启动分段，达到或修订预算 | Performance marks 与 Navigation/Resource Timing 生成 `web-startup-performance.json`；Chrome 152 锁定工具链冷启动 2,808.2 ms、热启动 872.7 ms，runtime gzip 2,285,357 B，低于 5 s/2 s/20 MiB；热启动 runtime 与游戏资产缓存命中，20 次 reload 无 DOM/listener 增长或生命周期 warning |
| P4-08 | 完成普通 Dora 示例兼容集 | P3-08、P4-06 | 已完成 | Codex | 选定 Lua/Yue/Teal 示例在目标浏览器通过 | manifest 同时发布 Lua Sprite、YueScript DrawNode、Teal Label 源码与预生成 Lua；静态门禁验证五个按需资产和生成来源，Chrome 152 各产生唯一日志并命中 1,189 px Sprite、4,900 px DrawNode、585 px Label；20 次 reload 后无 DOM/listener 增长或生命周期 warning |
| P4-09 | 完成 30–60 分钟 Player soak | P4-08 | 已完成 | Codex | 内存无单调增长，音频和 reload 稳定 | `DORA_WEB_SOAK_SECONDS` 生成逐分钟 frame/heap/DOM/listener/error 趋势和门禁；Chrome 152 完成 1,800.015 秒、31 样本，frame 31→108,027，documents/nodes/listeners 恒定 1/17/37，heap 2,276,520→3,381,040 B、斜率 37,660 B/min，无新增 error/lifecycle warning；同次运行含 20 reload、最终像素与 stop 清理 |
| P4-10 | 发布 Web Player preview | P4-07、P4-08、P4-09 | 待验证 | Codex | 可公开访问，版本、限制和部署说明完整 | CI/本地已生成不可变版本目录、入口指针、缓存/MIME/CSP 契约、英中文档和回滚工具；打包根入口在生成 CSP 下通过 Chrome；尚无公共 URL 与托管端 header/P75 证据 |

## 9. P5：LoveNode Web 兼容

目标：在不污染 Web 平台核心和 bgfx 通用层的前提下，逐级验证 LoveNode。

| ID | 任务 | 依赖 | 状态 | 负责人 | 验收标准 | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| P5-01 | 建立 Love Web capability matrix | P4-10 | 已完成 | Codex | 模块和 API 明确支持、限制、延后状态 | `love-capabilities.json` 覆盖 19 个实际注册模块和 4 个 graphics group；CI 检查状态、milestone/reason、CMake 排除和 `loveNode=false`，不把候选 adapter 标成可用 |
| P5-02 | 基础回调、Image、Font 和输入 | P5-01 | 已完成 | Codex / #54 | 标准 Love fixture 无 Dora 专用调用可运行 | `dora-web-love-support` 静态库与 `dora-web-love-link-probe` 完成非发布 Wasm 链接；无 Dora API 的 Lua fixture 验证 Runtime 生命周期、load/update/draw、键鼠触摸、ImageData、TrueType Font、math/data；锁定 Node 22.14.0 与 Chrome 152 首次运行及 20 次 reload 通过，`build/web-love-runtime-report.json` |
| P5-03 | 定义 `love.load` 非阻塞启动契约 | P5-02 | 已完成 | Codex / #55 | 普通/大型加载不冻结页面，扩展要求明确 | Web `LoveNode` 每帧以 50,000 条指令预算恢复 load coroutine，纯 Lua 自动让出并支持 Dora 扩展 `love.bootYield()`；浏览器 fixture 覆盖完成、异常、pending-close、同步兼容和事件循环心跳，Chrome 152 首次运行及 20 次 reload 通过；原生 Xcode arm64 Debug 全量构建通过 |
| P5-04 | Canvas、Mesh、SpriteBatch、ParticleSystem | P5-02 | 已完成 | Codex / #56 | 截图、坐标和资源释放通过 | 真实 `LoveNode`/bgfx fixture 验证可读 Canvas 与像素回读、静态 Mesh、两实例 SpriteBatch、暂停 ParticleSystem；Chrome 152 首次运行及 20 次 reload 共 21 次渲染和 21 次资源释放通过，`build/web-love-graphics-report.json` 与 `build/web-love-graphics.png` |
| P5-05 | 独立 Love shader 翻译层 | P5-04 | 已完成 | Codex / #57 | fixture 覆盖 varying/uniform/sampler/precision/坐标 | Web 专用 shaderc 路径绕过浏览器 Wasm 中不收敛的 Mesa optimizer，并独立打包 uniform 反射；GLSL1/GLSL3 fixture 的 varying、数值 uniform、额外 Image sampler、precision、屏幕坐标与 Love y-down 顶点坐标均由 Canvas 像素回读及截图验证；Chrome 152 首次运行与 20 次 reload、逐次资源释放通过，`build/web-love-shader-report.json` 与 `build/web-love-shader.png` |
| P5-06 | shader 失败与可选降级策略 | P5-05 | 已完成 | Codex / #58 | 默认显式失败；允许降级时用户可见且由包声明 | WebGL2 预检在创建 bgfx 资源前同步编译并链接 shader；翻译、driver compile、driver link 与 `validateShader` 负向 fixture 均携带稳定阶段，编译诊断映射到 Love pixel 第 3 行并保留 ESSL 字节数/浏览器日志；默认 `explicit-error`、`silentFallback=false`，可选 package fallback 明确 `available=false`；Chrome 152 首次运行与 20 次 reload 每类失败 21 次，随后成功出图/释放均通过，`build/web-love-shader-report.json` |
| P5-07 | Love 音频和资源生命周期 soak | P5-02、P3-07 | 已完成 | Codex / #59 | reload、停止、多实例和长时间运行通过 | 独立非发布 fixture 覆盖 WAV static、OGG stream、SoundData、clone 及 play/pause/resume/seek/stop/loop/volume/pitch；Chrome 152 首次运行与 20 次 reload 共 21 次实例重建、隔离清理和最终清理通过；30 分钟 31 样本中 frame 19→108,010，DOM/listener 恒定，heap 斜率 42,151 B/min，页面错误 0；`build/web-love-audio-report.json` |
| P5-08 | 固定复杂项目验证输入 | P5-03、P5-06、P5-07 | 已完成 | Codex / #60 | 记录版本、源码修改、Dora 扩展和测试步骤 | 按用户指定改为本地 `balatro_fixed.dora`：标准 ZIP、56,676,652 B、305 个条目、archive SHA-256 `6814cfed…f57765b`、版本 1.0.1o-FULL；只读 verifier 校验完整性、路径安全、精确哈希、入口和 Love/Dora 边界。探针只直接启动 `main.lua`，不执行含 `LoveNode` 的 `init.lua`；来源基线未记录，不能宣称未修改原版，包内容不得提交或分发 |
| P5-09 | 执行 Balatro 或等价复杂项目验证 | P5-08、P7-07 | 进行中 | Codex / #61 | 选定流程、画面、输入、音频和持续运行证据齐全 | 指定包已在独立 pthread profile 的 COOP/COEP 页面通过启动、主菜单、鼠标开局、盲注、选牌、出牌、弃牌、结算及商店；由游戏自身 `save_run()` 和 save-manager thread 写入真实 profile/save，IDBFS reload 恢复后连续 20 次重载均通过。末轮释放后 graphics/source/AudioFile/voice 归零、DOM/listener 无增长、页面异常为 0；仅剩指定复杂项目自身的 30 分钟长稳未执行 |
| P5-10 | 将复杂项目 probe 收敛为正式 Love player | P5-09 | 已完成 | Codex / #61 | 独立产物可安全导入、启动、停止 Love `.dora`，且不内置验收包 | `love-pthread-player` 强制 pthread/COOP/COEP，浏览器安全检查并原子安装根含 `main.lua` 的 Love 包到 IDBFS，支持稳定项目 ID、最近项目、非阻塞音频解锁、错误恢复、停止和存档同步；锁定 Emscripten 3.1.74 构建、静态门禁及无授权 fixture 的 Headless Chrome 导入/重启/失败恢复通过，用户指定 Balatro 完成真实导入、启动画面与 Stop 返回；发布目录不含 `.dora`/Balatro |

## 10. P6：Web Workspace

目标：在 Player 稳定后增加浏览器内导入、编译、运行和错误恢复。

| ID | 任务 | 依赖 | 状态 | 负责人 | 验收标准 | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| P6-01 | Workspace 项目列表和生命周期 | P4-10、P2-09 | 延后 | 未分配 | 导入、启动、停止、删除和重开行为明确 | — |
| P6-02 | Yue/Teal 浏览器编译 | P6-01 | 延后 | 未分配 | 编译、错误定位和取消通过 | — |
| P6-03 | Wa 独立 Worker/WASM | P6-01 | 延后 | 未分配 | 延迟下载，不阻塞 Player/Workspace 主循环 | — |
| P6-04 | 运行错误和源码映射 UI | P6-02 | 延后 | 未分配 | Lua/Yue/Teal/Wa 错误能定位源文件 | — |
| P6-05 | 多项目、重载和旧回调隔离 | P6-01、P6-04 | 延后 | 未分配 | 连续切换项目无资源、handler 或存档串扰 | — |
| P6-06 | Workspace 浏览器矩阵 | P6-03、P6-05 | 延后 | 未分配 | 支持路径和 fallback 在目标浏览器验证 | — |

## 11. P7：发布和长期维护

目标：建立可重复发布、兼容矩阵、升级策略和回归责任边界。

| ID | 任务 | 依赖 | 状态 | 负责人 | 验收标准 | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| P7-01 | Chrome/Edge/Firefox/Safari 桌面矩阵 | P4-10 | 进行中 | Codex | 核心 Player 用例全部有版本化证据 | Chrome 152.0.7977.82 与 Edge 152.0.4191.66 完整 CDP/20 reload 通过；Firefox 未安装；Safari 26.6.2 WebDriver 因未开启远程自动化待验证；#49 |
| P7-02 | Chrome Android 与 Safari iOS 核心矩阵 | P4-10 | 未开始 | 未分配 | 启动、触摸、音频、存档、恢复通过 | — |
| P7-03 | 原生五平台回归 | P4-10 | 未开始 | 未分配 | Web 条件分支未破坏既有构建和核心测试 | — |
| P7-04 | 发布版本和缓存升级策略 | P2-04、P4-10 | 已完成 | Codex | runtime/manifest/assets 可原子升级和回滚 | 浏览器 `/game` staging/backup 原子交换与 superseded request 隔离；不可变 `releases/<id>`、原子入口、previous 回滚、逐文件 SHA-256、缓存/MIME HTTP 测试；#51 |
| P7-05 | 用户部署、兼容和排错文档 | P7-01、P7-02 | 未开始 | 未分配 | Docusaurus 英中页面与实际能力一致 | — |
| P7-06 | 建立性能和体积趋势门禁 | P4-07 | 已完成 | Codex | CI 记录趋势并对超预算变化报警 | `performance-baseline.json`、`check_web_performance.mjs`、`web-performance-trend.json`；正向与超限负向测试、actionlint/YAML 通过 |
| P7-07 | 评估 iframe、PWA 与 pthread profile | P7-01、P7-02 | 进行中 | Codex / #61 | 分别形成部署约束和是否实施的决策 | 已实现默认关闭的 `DORA_WEB_PTHREADS` 独立构建，使用 `-pthread`、`USE_PTHREADS=1` 和 4 worker pool；Chrome 152 在 COOP/COEP 下确认 `crossOriginIsolated=true`、`SharedArrayBuffer=true` 并运行 Balatro 存档线程，静态门禁要求 shared memory、SharedArrayBuffer 和 Atomics 同时存在。默认发布仍为单线程；iframe/PWA 决策与面向用户的部署文档尚未完成 |

## 12. 当前问题与风险

| ID | 类型 | 项目 | 当前状态 | 下一步 |
| --- | --- | --- | --- | --- |
| R-01 | 构建 | PR #122 漏掉被忽略 Lua binding 的生成步骤 | 已确认，不阻塞设计 | P0-02 纳入构建图并用干净 CI 证明 |
| R-02 | 构建 | Love 与 Dora 的 `physics/Body.h` 在大小写不敏感文件系统冲突 | 已确认，不阻塞 Player minimal | P0-09 修正 include 边界；Love 任务在 P5 再验证 |
| R-03 | 架构 | Async 全部同步内联会改变回调时序并冻结页面 | 初版平台队列已实现并由浏览器探针验证 | `Source/Web/WebTaskQueue` 通过逐任务 event-loop callback 延迟执行，Async 支持取消代次；P2/P3 仍需为 Fetch/解码接 Promise/Worker，CPU 重任务不能停留在主线程 |
| R-04 | 体积 | 全量 Dora/Love/Assets 会造成过大首包 | P0 minimal 已缓解，full profile 仍待控制 | `/builtin` 仅保留 bootstrap，游戏资源按 manifest 预取/按需 Fetch；P0 minimal 排除编译器、Love、物理、3D、Wasm 与 Rust bridge，加入 P3 输入/音频首批能力后锁定 Emscripten 3.1.74 下为 1.89 MiB gzip；P4-06/P4-07 继续约束 full profile |
| R-05 | 渲染 | Love shader 翻译依赖较深 bgfx fork | 已收口 | P5-05 将 Love 语义保留在 adapter，仅在 Dora Web target 的 shaderc 边界跳过会卡死浏览器主线程的 Mesa optimizer 并生成反射；P5-06 在 LoveNode Web adapter 中于 bgfx 资源创建前完成 WebGL2 编译/链接预检，renderer 通用层仍不变，错误显式返回且可选降级保持关闭 |
| R-06 | 音频 | WebAudio 旧 callback 在设备重建后可能访问释放对象 | 已关闭 | P3-07 已使 SoLoud SDL2 backend 按设备持有 generation/cancel 状态并在关闭时失效 callback；P5-07 再以 21 次 Love 实例重建/隔离/清理、20 次 reload 和 30 分钟 soak 证明无旧 voice/resource 遗留或生命周期错误 |
| R-07 | 兼容 | coroutine 本身不能保证 `love.load` 主动 yield | 已解决 | P5-03 以 Lua 指令预算自动让出，并提供显式 `love.bootYield()`；长时间原生 C 调用仍要求异步化或拆分 |
| R-08 | 浏览器 | Safari/移动端存储、音频和生命周期差异 | 待实测 | P3 和 P7 分设备记录，不从桌面外推 |
| R-09 | 安全 | 导入项目代码与宿主页面同权限执行 | 已定义边界 | 独立 origin、CSP、导入前检查和用户确认 |
| R-10 | 架构 | 同步 XRT adapter 依赖全局 Asyncify，而 Rust 使用 Wasm exceptions | P0/P2 minimal 已解除 | minimal binding 不暴露同步 XRT API；HttpClient 和 host script 网络契约均使用异步 Fetch，Player 无全局 Asyncify/Rust bridge并通过浏览器回归；静态门禁继续默认拒绝 Asyncify |
| R-11 | 兼容 | Headless SwiftShader 下 bgfx 格式探测和旧 WebAudio backend 产生大量非致命 warning | 已确认，不阻塞 P1 | smoke 单独拒绝 error、WebGL context 丢失/耗尽和 OOM；P3-05/P3-07 迁移 AudioWorklet，P4-01 审计 bgfx WebGL format probe，避免把已知能力探测噪声误报为 reload 泄漏 |
| R-12 | 架构 | 用户指定的 Balatro 包用 `love.thread` 运行存档管理器 | 已缓解 | 独立 pthread profile 与 COOP/COEP/SharedArrayBuffer 浏览器运行已通过；worker 文件写入经主 runtime 合批同步 IDBFS，真实存档 reload 与 20 次重载通过；默认 profile 保持隔离，iframe/PWA 部署约束继续由 P7-07 跟踪 |

当前没有需要外部输入才能开始 P0 的阻塞项。风险不等于阻塞；只有无法继续相应任务时才把任务状态改为“阻塞”。

## 13. 验证记录

| 日期 | 代码/对象 | 验证层级 | 结果 | 证据与边界 |
| --- | --- | --- | --- | --- |
| 2026-09-08 | PR #122 `7ee95e66a9dffdfa40298badef76205d4ac277ad` | GitHub 状态 | 未通过合并门槛 | Draft；仅 DCO `ACTION_REQUIRED`；没有 Emscripten Actions run |
| 2026-09-08 | PR #122 干净临时 worktree | 本地构建配置 | 失败，已定位 | Rust target 安装后执行 `Tools/build-scripts/build_emscripten.sh`；CMake 缺三个生成源文件；不是当前 main 的构建结论 |
| 2026-09-08 | PR #122 + 本地生成 bindings | macOS Emscripten 编译 | 失败，已定位 | 继续至约 60%，Love `physics/Body.h` 命中 Dora `Physics/Body.h`；不外推 Ubuntu；临时 worktree 与临时 Rust target 已清理 |
| 2026-09-08 | Web runtime README/PROGRESS | 文档检查 | 已完成 | 相对链接、任务依赖、状态规则和设计边界已建立；未实现 Web runtime |
| 2026-09-08 | 当前工作树 Web build probe | 本地静态与实例化检查 | 通过 | macOS 26.6.2；本机漂移工具链 Emscripten 5.0.5/Rust 1.95.0/Node 25.9.0/CMake 4.3.1，仅作诊断；Node 完成 WASM validate/compile/instantiate；JS 21005 B raw/6549 B gzip/6027 B brotli，WASM 14302 B raw/6547 B gzip/5684 B brotli |
| 2026-09-08 | 当前工作树 Web engine compile gate | Emscripten 对象编译 | 通过 | 共享 578 项 engine 清单过滤 8 项原生/Love backend，并追加 `WebTaskQueue.cpp`；共 571 个对象构建至 100%；不是已链接 Player 的证据 |
| 2026-09-08 | 当前工作树 Web build probe | 本机 HTTP 浏览器运行 | 通过 | Codex in-app browser；页面显示 `Dora SSR Web build probe ready (deferred task verified)`；HTTP 对 HTML/JS/WASM 均返回 200；只证明探针和 event-loop 延迟时序，不证明 Dora 首帧 |
| 2026-09-08 | 当前工作树 macOS Dora | 原生回归构建 | 通过 | macOS 26.6.2、Xcode 26.6；`ARCHS=arm64 ONLY_ACTIVE_ARCH=YES`、Dora Debug target，结果 `BUILD SUCCEEDED`；工作树含用户原有未提交改动，不等同干净 CI |
| 2026-09-09 | 当前工作树真实 Web Player | Emscripten release 链接 | 通过 | 本机漂移工具链，仅作诊断；576 个 engine 对象，bgfx/WebGL、Theora、SoLoud SDL2 static、Rust runtime 均完成链接；输出 HTML/JS/WASM/data |
| 2026-09-09 | `result/dora-web-player` | 静态产物与体积门禁 | 通过 | Node 25.9.0 验证 WASM、Canvas、生命周期与 lazy asset bridge 导出、manifest 启动/非启动资产大小与 SHA-256；gzip 7,838,849 B，brotli quality 6 为 6,362,137 B，低于 20 MiB gzip 初始预算 |
| 2026-09-09 | `Projects/Web/runtime-assets/Script/init.lua` | 本机 HTTP 浏览器运行 | 通过 | Codex in-app browser；2560×1440 Canvas，日志出现 `Dora SSR Web Player bootstrap script ready`，画面显示居中绿色矩形；仅验证单一 Chromium 环境，不外推浏览器矩阵 |
| 2026-09-09 | Web Player lifecycle | 本机 HTTP 浏览器运行 | 部分通过 | DOM 状态达到 running；`?dora-test-stop=1` 后达到 stopped，日志确认 Director、LuaEngine、Audio、Renderer、BGFX 等释放；faulted 和 20 次 reload 待验证 |
| 2026-09-09 | Web manifest demo game | 本机 HTTP 浏览器运行 | 通过 | 浏览器请求 manifest 与 hash Lua 启动资产，校验后挂载 `/game/init.lua`；日志出现 `manifest game ready` 并显示绿色 DrawNode |
| 2026-09-09 | Web lifecycle fault path | 本机 HTTP 浏览器运行 | 通过 | 请求不存在的 manifest 后 DOM 达到 faulted，页面显示 `manifest request failed (404)`；浏览器控制台的 abort/RuntimeError 为预期终止证据 |
| 2026-09-09 | Web Player reload smoke | 本机 HTTP 浏览器运行 | 部分通过 | 连续 20 次 reload 全部达到 running，新增 20 条且每次仅一条 manifest ready 日志，无新增 console error；最终 test-stop 达到 stopped 并输出对象销毁日志；未直接测量 GPU/JS/WASM 内存残留 |
| 2026-09-09 | IDBFS persistence | 本机 HTTP 浏览器运行 | 通过 | preRun 等待 IDBFS populate 后才启动；写入 `/user/settings/web-test.txt` 并 `syncfs(false)`，新页面再次 populate 后读取值一致，DOM 测试状态为 passed |
| 2026-09-09 | 当前工作树 Web lazy asset | Chrome 152.0.7977.82 浏览器集成 | 通过 | macOS 26.6.2 arm64；本机 HTTP Player；网络事件仅先取 hash `init.lua`，Lua `Content:loadAsync("lazy.txt")` 后再取 hash `lazy.txt`；内容断言、running、绿色 DrawNode 首帧通过且无 page error。`check_web_loader.mjs` 同时覆盖并发去重与失败重试 |
| 2026-09-09 | 当前工作树 Web/原生回归 | 本机构建与静态门禁 | 通过 | 漂移工具链 Web release 完整重建；WASM 18 imports/11 exports；Player gzip 7,838,849 B、brotli 6,362,137 B；Xcode 26.6 macOS arm64 Debug `BUILD SUCCEEDED`。固定版本 CI 尚未运行 |
| 2026-09-09 | `result/dora-web-player` | 禁止依赖与可发布性门禁 | 通过 | 规范化 C++/Rust 源路径后全量 release 重建；无 shared memory/pthread、动态链接段、原生库、用户构建路径或凭据样式内容；人为向 build/result 注入 stale hash 文件后执行增量构建，两处旧文件均被清除且资产与 manifest 精确一致；负向测试确认未授权 Asyncify 被拒绝，R-10 显式放行后生成 `dependency-report.json` |
| 2026-09-09 | 当前工作树 Web CI | Workflow 静态验证 | 部分通过 | Ubuntu/macOS 固定工具链矩阵已配置，Emscripten setup action 已迁移到维护中的 `emscripten-core/setup-emsdk@v15`；`actionlint` 与 Ruby YAML 解析通过；GitHub Actions 尚未运行 |
| 2026-09-09 | `result/dora-web-player` | Chrome 152.0.7977.82 重编译后冒烟 | 通过 | macOS 26.6.2 arm64、本机 HTTP、1280×720 Canvas；DOM 达到 running，依次请求 hash `init.lua` 与 `lazy.txt`，日志出现 `lazy asset verified`，无 page error |
| 2026-09-09 | 当前工作树 Web player | Emscripten release、静态门禁、Chrome 与原生回归 | 通过 | 本机漂移工具链仅作诊断；Player 不链接 Rust bridge且无全局 Asyncify，WASM/manifest/禁止依赖门禁通过，含 Sprite/Label 后 gzip 1,868,297 B、brotli 1,591,181 B；Chrome 152 禁用缓存后 runtime、manifest、hash 启动/按需资源均返回 200；Xcode 26.6 macOS arm64 Debug 全量及后续增量构建均 `BUILD SUCCEEDED`。固定版本 GitHub Actions 尚未运行 |
| 2026-09-09 | 当前工作树 P1-04 | Chrome 152.0.7977.82 resize/DPR/fullscreen | 通过 | macOS 26.6.2；DPR 2 下 800×600→1000×650 动态缩放时引擎 visual 与 CSS 一致、buffer 始终 2×；Canvas 双击进入全屏记录 1512×949/3024×1898、`fullscreen=true`，再次双击恢复 1280×720/2560×1440、false；无 console warning/error。仅验证桌面 Chromium，不外推 Safari/Firefox/移动端 |
| 2026-09-09 | 当前工作树 P1-06/P1-08 | Chrome 152.0.7977.82 Headless Sprite/Label fixture | 通过 | macOS 26.6.2 arm64、本机漂移 Node 25.9.0、fixed 1280×720 viewport；`check_web_browser.mjs result/dora-web-player` 启动 no-store 静态服务器，经 CDP 等待 `lazy asset, Sprite and Label verified`，无 console/page error；截图写入 `build/web-browser-smoke.png`，像素断言命中绿色区域 63,505 px、logo 黄色 4,840 px、Label 白色 1,097 px；Ubuntu CI 已接入但尚未运行 |
| 2026-09-09 | 当前工作树 P0 固定工具链 | macOS 隔离环境全量 Release 与 Chrome 152.0.7977.82 | 通过 | `/tmp` 全新安装 Emscripten 3.1.74、Rust 1.85.1 + `wasm32-unknown-emscripten`、Node 22.14.0、CMake 3.30.5，系统 Go 1.24.3；先发现 `image 0.25.10` MSRV 1.88 和两处 `usize::is_multiple_of` 兼容缺口，修正后 `build_web.sh` 完成 Rust/probe/engine/Player；含 `.dora` 和 Web 网络契约的锁定 Node 静态/禁止依赖门禁及 Headless Chrome 像素冒烟通过，gzip 1,906,986 B、brotli 1,612,947 B；输出位于 `result/dora-web-*-exact`，外部 Ubuntu/macOS Actions 尚未运行 |
| 2026-09-09 | 当前工作树 P1-07 | Chrome 152.0.7977.82 Headless reload/内存冒烟 | 通过 | macOS 26.6.2 arm64、锁定 Node 22.14.0、Emscripten 3.1.74 Player；`DORA_WEB_RELOADS=20 check_web_browser.mjs` 连续 20 次 reload 各产生唯一 ready 并保持固定像素；强制 GC 前后 documents 1→1、nodes 17→17、listeners 29→29、JS heap 1,879,188→1,867,696 B；3,280 条已知 bgfx/WebAudio warning 中 lifecycle warning 为 0，console/page error 为 0 |
| 2026-09-09 | 当前工作树 P2-09 | Chrome 152.0.7977.82 `.dora`/IDBFS 集成 | 通过 | macOS 26.6.2 arm64；静态测试服务器提供运行时生成的 Deflate `.dora`，浏览器 `inspectPackage()` 验证后在 `/user/projects/browser-import` 完成 staging/rename/sync，reload 后 `init.lua` 内容一致；随后 20 次额外 reload 仍保持唯一 ready、像素和内存门禁，无 lifecycle warning/error；临时 Chrome profile 随测试删除 |
| 2026-09-09 | 当前工作树 P2-02/P2-04/P2-08 | Node + Chrome 152.0.7977.82 存储/缓存集成 | 通过 | 锁定 Node 22.14.0；Node 覆盖 manifest no-cache/hash force-cache、v2 remount 清旧文件、IDBFS debounce/并发/二次 flush/配额映射/失败重试；Chrome 断言六个虚拟路径并验证合批写入 reload 恢复 |
| 2026-09-09 | 当前工作树 P2-05/P2-06 | Emscripten 3.1.74 + Chrome 152.0.7977.82 网络集成 | 通过 | macOS 26.6.2 arm64、锁定 Node 22.14.0；真实 Player 通过 GET/POST/418/timeout/cancel/stream progress/size/origin 和 HTTP/WS server unsupported 契约，20 次 reload 后 documents 1→1、nodes 17→17、listeners 29→29、JS heap 1,946,028→1,887,244 B，lifecycle warning 与非预期 error 均为 0；最终 gzip 1,906,986 B、brotli 1,612,947 B |
| 2026-09-09 | 当前工作树 P3-01—P3-10 | Emscripten 3.1.74 + Chrome 152.0.7977.82 输入/音频/宿主集成 | 部分通过 | macOS 26.6.2 arm64、锁定 Rust 1.85.1/Go 1.24.3/Node 22.14.0/CMake 3.30.5；`check_web_browser.mjs result/dora-web-player-exact` 通过 Dora 键盘、失焦释放、鼠标/滚轮、多点触摸/取消、Gamepad API 边界注入后的连接/A 键/leftx 轴/失焦归零/恢复/断连、SDL2 AudioContext 解锁、WAV/OGG play/loop/pause/volume/stop、显式 engine frame 冻结/恢复、真实 tab 前后台 AudioContext suspend/resume、原生 picker mock、真实 `<input>` file chooser、Clipboard 往返、Pointer Lock 和 stop 清理；suspend 期间 logic/render/`bgfx::frame()` 停止但任务队列继续泵送，resume 重置 delta 基线；stop 后 SDL audio/AudioContext 均不可达，20 次 reload 后 documents 1→1、nodes 17→17、listeners 37→37、JS heap 2,174,456→2,042,680 B，lifecycle warning 0、非预期 error 0；静态/禁止依赖门禁通过，gzip 1,987,121 B、brotli 1,683,786 B，Xcode 26.6 macOS arm64 Debug 原生回归 `BUILD SUCCEEDED`。Gamepad 为 API 边界模拟而非真实硬件；File System Access OS chooser、Safari/移动端和系统音频中断尚未验证 |
| 2026-09-09 | 当前工作树 P4-01 | Emscripten 3.1.74 + Chrome 152.0.7977.82 RenderTarget 渲染集成 | 通过 | macOS 26.6.2 arm64、锁定 Rust 1.85.1/Go 1.24.3/Node 22.14.0/CMake 3.30.5；192×192 RenderTarget 使用显式 alpha blend、`ScissorNode` 与 `ClipNode`，最终截图命中离屏合成 13,536 px、stencil 2,016 px、scissor 864 px；真实 readback PNG 命中背景 24,064 px、blend 7,680 px、stencil 3,584 px、scissor 1,536 px 且边界为 x=24…55/y=128…175；20 次 reload 后 documents 1→1、nodes 17→17、listeners 37→37、JS heap 2,196,188→2,059,048 B，lifecycle warning 0、非预期 error 0；Player gzip 1,992,119 B、brotli 1,686,883 B；`build/web-browser-smoke-p4.png`、`build/web-render-target-readback.png`；Xcode 26.6 macOS arm64 Debug `BUILD SUCCEEDED`。外部 CI 和其他浏览器仍由 P0-08/P7 跟踪 |
| 2026-09-09 | 当前工作树 P4-02 | Emscripten 3.1.74 + Chrome 152.0.7977.82 高级 2D 渲染集成 | 通过 | macOS 26.6.2 arm64、锁定 Rust 1.85.1/Go 1.24.3/Node 22.14.0/CMake 3.30.5；manifest 按需加载确定性 Particle/Spine/DragonBones/NanoVG fixture，固定截图命中 Particle 255 px、Spine 2,480 px、DragonBones 3,077 px、NanoVG 背景 14,400 px 与裁剪区 4,800 px；20 次 reload 后 documents 1→1、nodes 17→17、listeners 37→37、JS heap 2,360,384→2,217,936 B，lifecycle warning 0、非预期 error 0；Player gzip 2,184,088 B、brotli 1,850,619 B；`build/web-browser-smoke-p4.png`；静态/禁止依赖门禁与 Xcode 26.6 macOS arm64 Debug `BUILD SUCCEEDED`。外部 CI 和其他浏览器仍由 P0-08/P7 跟踪 |
| 2026-09-09 | 当前工作树 P4-03 | Emscripten 3.1.74 + Chrome 152.0.7977.82 PlayRho 2D 物理集成 | 通过 | macOS 26.6.2 arm64、锁定 Rust 1.85.1/Go 1.24.3/Node 22.14.0/CMake 3.30.5；真实 PhysicsWorld 验证动态刚体质量、重力下落、静态地面碰撞与 raycast，最终 debug draw 命中静态地面 3,401 px、休眠动态体 1,452 px；Web minimal 以 `DORA_NO_3D_PHYSICS` 排除同文件 3D bridge，发布检查确认 `dora_3d_physics_`/`JoltPhysics` 标记为空；20 次 reload 后 documents 1→1、nodes 17→17、listeners 37→37、JS heap 2,393,160→2,249,608 B，lifecycle warning 0、非预期 error 0；Player gzip 2,282,721 B、brotli 1,936,990 B；`build/web-browser-smoke-p4.png`；Xcode 26.6 macOS arm64 Debug `BUILD SUCCEEDED`。外部 CI 和其他浏览器仍由 P0-08/P7 跟踪 |
| 2026-09-09 | 当前工作树 P4-04 | Emscripten 3.1.74 + Chrome 152.0.7977.82 ImGui/基础系统 UI 集成 | 通过 | macOS 26.6.2 arm64、锁定 Rust 1.85.1/Go 1.24.3/Node 22.14.0/CMake 3.30.5；自定义 22px 字体、固定窗口、文字、按钮和 72px 裁剪 fixture 在 DPR 1/2 下通过，截图分别为 1280×720/2560×1440，窗口像素边界由 x=20…239/y=283…419 放大至 x=41…478/y=567…838；点击只触发一次且未进入 Dora scene touch；20 次 reload 后 documents 1→1、nodes 17→17、listeners 37→37、JS heap 2,399,500→2,253,468 B，lifecycle warning 0、非预期 error 0；Player gzip 2,284,909 B、brotli 1,939,809 B；`build/web-browser-smoke-p4-reload20.png` 与 `build/web-browser-smoke-p4-reload20-dpr2.png`；Xcode 26.6 macOS arm64 Debug `BUILD SUCCEEDED`。外部 CI 和其他浏览器仍由 P0-08/P7 跟踪 |
| 2026-09-09 | 当前工作树 P4-05 | Chrome 152.0.7977.82 WebGL2 高风险能力审计 | 通过 | 3D C++ wrapper、Rust 3D ABI、Jolt 和 VideoNode 未进入 minimal 发布能力，禁止依赖门禁新增 3D node/model 与 VideoNode/Ogg-Theora 标记；SwiftShader renderer 上 MAX_TEXTURE_SIZE=8192、MAX_COLOR_ATTACHMENTS=8，RGBA8/D24S8/RGBA16F/RGBA32F framebuffer 均 complete 且 GL error=0，`EXT_color_buffer_float`/float linear 可用；压缩纹理支持 S3TC/S3TC-sRGB、ETC、ASTC，不支持 PVRTC，故只记录设备能力而不作通用格式承诺；报告为 `build/web-advanced-texture-capabilities.json`，外部 CI 与其他浏览器/真机仍由 P0-08/P7 跟踪 |
| 2026-09-09 | 当前工作树 P4-06 | Emscripten 3.1.74 + Chrome 152.0.7977.82 feature profile 契约 | 通过 | `dora-web-features.json` v1 随 Player 发布并精确声明 17 个 required 与 11 个 excluded 模块；Chrome 验证 `DoraWebPlatform.features`、`DoraWebFeatures`、`Module.doraWebFeatures` 内容一致且 active profile 为 minimal；`DORA_WEB_PROFILE=full` 在配置期以 P4-05 延后原因明确拒绝；20 次 reload 后 documents 1→1、nodes 17→17、listeners 37→37、JS heap 2,404,176→2,256,076 B，lifecycle warning 0、非预期 error 0；Player gzip 2,285,262 B、brotli 1,940,159 B；锁定工具链、静态门禁、actionlint/YAML 与变更 Rust 格式检查通过 |
| 2026-09-09 | 当前工作树 P4-07 | Emscripten 3.1.74 + Chrome 152.0.7977.82 启动与首包性能 | 通过 | macOS 26.6.2 arm64、锁定 Rust 1.85.1/Go 1.24.3/Node 22.14.0/CMake 3.30.5；清缓存冷启动可交互 2,808.2 ms，HTTP 缓存热启动 872.7 ms，runtime raw/gzip/brotli 为 6,550,807/2,285,357/1,940,231 B，完整首载分组为 6,567,796/2,290,824/1,945,380 B；热启动 JS/WASM/data 与 13 个游戏资产 transfer size 均为 0；`build/web-startup-performance.json` 提供 HTML/runtime/manifest/启动资产/storage/runtime 初始化/首帧/游戏 fixture 分段；20 次强制 reload 后 documents 1→1、nodes 17→17、listeners 37→37、JS heap 2,410,100→2,267,508 B，lifecycle warning 0、非预期 error 0。外部部署 P75 尚未测量 |
| 2026-09-09 | 当前工作树 P4-08 | Emscripten 3.1.74 + Chrome 152.0.7977.82 Lua/YueScript/Teal 示例兼容 | 通过 | macOS 26.6.2 arm64、锁定 Rust 1.85.1/Go 1.24.3/Node 22.14.0/CMake 3.30.5；YueScript 与 Teal 源码的生成 Lua 分别和仓库内 Yue 编译器/`tl.lua` 输出核对，manifest 发布 18 个文件并将五个示例文件保持为按需资产；Chrome 中 Lua Sprite、YueScript DrawNode、Teal Label 各输出唯一完成日志，截图分别命中 1,189/4,900/585 px；冷/热启动 2,900.8/974.5 ms，runtime gzip 2,285,357 B；20 次 reload 后 documents 1→1、nodes 17→17、listeners 37→37、JS heap 2,420,464→2,278,360 B，lifecycle warning 0、非预期 error 0；`build/web-browser-smoke-p4-examples-reload20.png`。运行期 YueScript/Teal 编译仍未提供 |
| 2026-09-09 | 当前工作树 P4-09 | Emscripten 3.1.74 + Chrome 152.0.7977.82 Player soak | 通过 | macOS 26.6.2 arm64、锁定 Rust 1.85.1/Go 1.24.3/Node 22.14.0/CMake 3.30.5；同一 Player 会话先通过 20 次 reload，再连续运行 1,800.015 秒并采集 31 个强制 GC 样本；frame 31→108,027，documents/nodes/listeners 始终 1/17/37，JS heap 2,276,520→3,381,040 B，线性斜率 37,660 B/min，低于 256 KiB/min；page errors 2→2（既有预期 418/touchcancel），warnings 3,592→3,592，lifecycle warning 0；最终全画面像素、RenderTarget readback、输入/音频/存储与 stop 清理通过；`build/web-soak-report.json`、`build/web-browser-smoke-p4-soak30.png` |
| 2026-09-09 | 当前工作树 P7-01 Chrome | Emscripten 3.1.74 + Chrome 152.0.7977.82 桌面矩阵 | 通过 | macOS 26.6.2 arm64、锁定 Node 22.14.0；完整像素、网络、存储、输入、音频、性能与 20 次 reload 通过；cold/warm 2,843.3/975.3 ms，documents/nodes/listeners 1/17/37→1/17/37，JS heap 2,420,524→2,276,800 B，非预期 error 0；`build/web-browser-smoke-chrome-reload20.png`、`build/web-startup-performance-chrome.json`、`build/web-advanced-texture-capabilities-chrome.json` |
| 2026-09-09 | 当前工作树 P7-01 Edge | Emscripten 3.1.74 + Edge 152.0.4191.66 桌面矩阵 | 通过 | macOS 26.6.2 arm64、锁定 Node 22.14.0；与 Chrome 同一 Player/测试入口完整通过，cold/warm 1,546.5/974.4 ms，documents/nodes/listeners 1/17/37→1/17/37，JS heap 2,422,952→2,280,860 B，非预期 error 0；`build/web-browser-smoke-edge-reload20.png`、`build/web-startup-performance-edge.json`、`build/web-advanced-texture-capabilities-edge.json` |
| 2026-09-09 | 当前工作树 P7-01 Safari 探测 | Safari 26.6.2 / safaridriver 21624.5.1.11.3 | 待验证 | macOS 26.6.2 arm64；WebDriver session 明确拒绝并提示需在 Safari 设置的 Developer 区开启“Allow remote automation”；未改变用户安全设置。Firefox 当前未安装，不产生伪造版本证据 |
| 2026-09-09 | 当前工作树 P7-06 | Chrome 152 报告 + Node 22.14.0 趋势门禁 | 通过 | runtime gzip/brotli 2,285,357/1,940,231 B、首载 2,291,376/1,945,919 B 与版本化基线相等；5% 增长阈值、5 s/2 s 时间预算均通过；篡改 gzip 基线的负向 fixture 被拒绝；`build/web-performance-trend-chrome.json`，workflow 经 actionlint 和 Ruby YAML 解析 |
| 2026-09-09 | 当前工作树 P7-04 | Node 22.14.0 + Emscripten 3.1.74 + Chrome 152 | 通过 | manifest startup 资源先完整校验并写 staging，再交换 `/game`；rename 失败注入恢复旧 startup/lazy 内容，旧请求延迟完成被 superseded generation 拒绝；真实 MEMFS Player 20 reload 后 documents/nodes/listeners 1/17/37→1/17/37，heap 2,426,380→2,280,408 B，非预期 error 0；runtime gzip 2,285,600 B，趋势 +0.01% 通过 |
| 2026-09-09 | 当前工作树 P4-10/P7-04 preview 工件 | Chrome 152.0.7977.82 本地版本入口 | 部分通过 | `worktree-20260909-p7d` 不可变目录含逐文件 SHA-256；两版本切换、拒绝覆盖、回滚、入口 loader/current no-cache、版本 immutable、WASM MIME 与英中文档自动测试通过；release CSP 只含精确 script/style SHA-256 和 `wasm-unsafe-eval`，无 `unsafe-inline`/`unsafe-eval`；Chrome 从部署根入口在实际 CSP 下完整通过，冷/热启动 2,882.8/978.7 ms 且无非预期 error；`result/dora-web-preview-local`、`build/web-browser-smoke-preview-final.png`。未公开部署，不能标记 P4-10 完成 |
| 2026-09-09 | 当前工作树 P5-01 | Node 22.14.0 capability gate | 通过 | `LoveRuntimeAdapters.inc` 的 graphics/image/font/sound/math/data/window/event/filesystem/keyboard/mouse/touch/joystick/timer/audio/video/system/thread/physics 共 19 个注册模块全部映射；thread 依据 `std::thread` 保持 unsupported，video/shader/physics 延后，其他仅为 candidate/limited；minimal Love 排除和 feature=false 门禁通过 |
| 2026-09-09 | 当前工作树 P5-02 | Emscripten 3.1.74 + Node 22.14.0 + Chrome 152.0.7977.82 Love runtime fixture | 通过 | macOS 26.6.2 arm64、Rust 1.85.1/Go 1.24.3/CMake 3.30.5；平台识别、Theora include 与 Love/Dora `physics/Body.h` 搜索顺序已收口；完整 `LoveRuntime.cpp`/`LoveVideoSources.cpp`、Love support 静态库和 vendored Box2D 与 Dora Web engine/link deps 组成 `dora-love-runtime-probe`；无 Dora API 的 fixture 验证 Runtime 生命周期、load/update/draw、键鼠触摸、2×2 ImageData 像素、TrueType Font rasterizer、math random 与 data SHA-256；Node 及 Chrome 首次运行和 20 次 reload 通过，页面异常 0；`build/web-love-runtime-report.json`。非发布探针不改变 minimal `loveNode=false` 或 full profile 可用性 |
| 2026-09-09 | 当前工作树 P5-03 | Emscripten 3.1.74 + Node 22.14.0 + Chrome 152.0.7977.83 Love 非阻塞启动 fixture | 通过 | macOS 26.6.2 arm64、Rust 1.85.1/Go 1.24.3/CMake 3.30.5；Web `LoveNode.cpp` 对象编译探针与运行时链接探针进入标准构建；纯 Lua 大循环由指令预算分片，显式 `love.bootYield()` 可恢复，异常保留 traceback，pending runtime 可安全关闭，原生同步 `start()` fixture 保持通过；Chrome 首次运行及 20 次 reload 共 21 次，最少 208 steps/269 heartbeats、最长 1,544.8 ms，页面异常 0；`build/web-love-runtime-report.json`；Xcode 26.6 arm64 Debug 原生全量构建 `BUILD SUCCEEDED`。非发布探针不改变 `available=false` 或发布 profile |
| 2026-09-09 | 当前工作树 P5-04 | Emscripten 3.1.74 + Node 22.14.0 + Chrome 152.0.7977.83 Love 图形 fixture | 通过 | macOS 26.6.2 arm64、Rust 1.85.1/Go 1.24.3/CMake 3.30.5；真实 `LoveNode`/Dora 场景/bgfx WebGL2 路径以 320×180 逻辑画布绘制 Canvas、Mesh、SpriteBatch、ParticleSystem；1280×720 截图精确命中蓝 3,072、绿 1,024、红 3,223、黄 832、青 144 像素及坐标边界，Canvas GPU→CPU 双区域回读通过；首次运行及 20 次 reload 共 21 次节点资源释放通过、页面异常 0；Xcode 26.6 arm64 Debug 原生目标在资源清理改动后 `BUILD SUCCEEDED`；`build/web-love-graphics-report.json`、`build/web-love-graphics.png`。仅使用默认 shader，发布能力仍关闭 |
| 2026-09-09 | 当前工作树 P5-05 | Emscripten 3.1.74 + Node 22.14.0 + Chrome 152.0.7977.83 Love shader fixture | 通过 | macOS 26.6.2 arm64、Rust 1.85.1/Go 1.24.3/CMake 3.30.5；实际定位 Mesa `glslopt_optimize` 在单线程浏览器 Wasm 中不返回，并发现未优化源码使旧 uniform parser 在辅助函数前停止；Dora Web 专用 shaderc 路径改为浏览器驱动最终校验、剥离重复 directive、独立提取 uniform 反射；GLSL3 custom varying、`vec2`/`vec4` uniform、额外 Image sampler、highp/mediump、`screen.x` 分支及 Love y-down 顶点偏移，GLSL1 number/Image uniform 均通过 192×64 Canvas 精确像素读回；首次运行及 20 次 reload 共 21 次渲染/释放、页面异常 0，P5-04 graphics 20 reload 回归仍通过；标准 Web 全量构建与 Xcode 26.6 macOS arm64 Debug 原生构建均 `BUILD SUCCEEDED`；`build/web-love-shader-report.json`、`build/web-love-shader.png`。失败策略与发布能力仍关闭 |
| 2026-09-09 | 当前工作树 P5-06 | Emscripten 3.1.74 + Node 22.14.0 + Chrome 152.0.7977.83 Love shader failure fixture | 通过 | macOS 26.6.2 arm64、Rust 1.85.1/Go 1.24.3/CMake 3.30.5；Web 由 LoveNode 在创建任何 bgfx shader 前解包 shaderc ESSL 并同步执行 WebGL2 vertex/pixel compile 与 program link；翻译错误、未定义函数编译错误、跨阶段 uniform array 链接错误及 `validateShader` 各在首次运行和 20 次 reload 中显式失败 21 次，编译错误映射到 Love pixel 源第 3 行，报告含 ESSL 字节数与底层日志；每轮负向检查后正常 GLSL1/GLSL3 像素、清理均通过，`BGFX FATAL` 与页面异常 0；P5-04 graphics 20 reload、标准 Web 全量构建/产物门禁、Xcode 26.6 arm64 Debug 原生全量构建均通过；`build/web-love-shader-report.json`、`build/web-love-shader.png`。可选 package fallback 未启用，发布能力仍关闭 |
| 2026-09-09 | 当前工作树 P5-07 | Emscripten 3.1.74 + Node 22.14.0 + Chrome 152.0.7977.83 Love audio lifecycle fixture | 通过 | macOS 26.6.2 arm64、Rust 1.85.1/Go 1.24.3/CMake 3.30.5；同一 runtime 的两个 `LoveNode` 覆盖 WAV static、OGG stream、SoundData、clone、用户手势解锁及播放控制；首次运行与 20 次 reload 共 21 次实例重建、21 次隔离清理、21 次最终 Source/AudioFile/SoLoud voice 归零；随后运行 1,800.000 秒并采集 31 次，frame 19→108,010，instances/sources/audioFiles 恒定 2/8/6，documents/nodes/listeners 恒定 1/17/30，heap 2,134,288→3,403,080 B、斜率 42,151 B/min（低于 256 KiB/min），页面错误 0；Love runtime/graphics/shader 各 20 reload、标准 Web 全量构建、发布门禁与 Xcode 26.6 arm64 Debug 原生全量构建均通过；`build/web-love-audio-report.json`。Headless 结果不替代移动设备听感/中断矩阵，发布能力仍关闭 |
| 2026-09-09 | 当前工作树 P5-08（用户更换输入） | Node 25.9.0 本地只读 `.dora` verifier | 通过 | `balatro_fixed.dora` 为 56,676,652 B 的完整 ZIP，305 个安全相对路径条目，archive SHA-256 `6814cfedd8743e125fc2f18b84478796bff9b724f130cdebf2a09be94f57765b`，版本 1.0.1o-FULL；根 `main.lua`/`conf.lua` 为 Love 运行入口，`init.lua` 是仅作边界核对的 Dora `LoveNode` wrapper；所选入口不调用 Dora 扩展。包只解压到未跟踪 build staging，未修改、未上传、未进入发布产物 |
| 2026-09-09 | 当前工作树 P5-09（阻塞） | Emscripten 3.1.74 + Node 22.14.0 + Chrome 152.0.7977.83 用户指定包启动/清理探针 | 未通过，已定位 | 锁定工具链完整重建成功；语义探针先确认 `love.system.getOS()` 错报 `Unknown`，修复 `Application` Web 宏优先级及 `LoveNode` 的 `Web` 映射后返回 `Web`，包内 sound thread 分支被正确关闭；启动继续至 `LOADING: savemanager`，再于 `game.lua:121` 因无条件启动 `engine/save_manager.lua` 报 `thread constructor failed: Resource temporarily unavailable`。当前能力矩阵明确 `thread=unsupported` 且 `USE_PTHREADS=0`。释放后 graphics/source/AudioFile/voice 归零、页面异常 0；`build/web-love-complex-package-boot-report.json`、`build/web-love-complex-package-boot.png`。旧目录取得的主菜单/输入/20 reload/30 分钟结果只保留为 adapter 诊断，不计作该包验收 |
| 2026-09-09 | 当前工作树 P5-09/P7-07（指定包） | Emscripten 3.1.74 pthread profile + Node 22.14.0 + Chrome 152.0.7977.83 | 部分通过 | `DORA_WEB_PTHREADS=1` 独立构建以 COOP/COEP 获得 cross-origin isolation 与 SharedArrayBuffer，Balatro 存档线程不再阻塞启动；指定 `balatro_fixed.dora` 通过启动、主菜单、鼠标开局、盲注及发牌，锁定 Node 22 复核报告为 `build/web-love-complex-pthread-play-node22-report.json`。固定完整局进一步定位 LuaJIT `math.log10` 缺口并在通用 Love 环境补齐；随后浏览器可选牌、出牌、弃牌并耗尽 4 手进入 `GAME_OVER`。清理归零、页面异常为 0；尚未达到 Shop，存档/20 reload/30 分钟/回归未验收 |
| 2026-09-09 | 当前工作树 P5-09/P7-07（指定包） | Emscripten 3.1.74 pthread profile + Node 22.14.0 + Chrome 152.0.7977.83 | 通过当前门禁 | macOS 26.6.2 arm64；测试入口为用户指定的本地 `balatro_fixed.dora`，只解压到忽略的 build staging。修正干净构建缺失 bgfx embedded shader、Love thread 数值整数语义及 worker 写入 IDBFS 合批，并恢复 shader 默认显式失败契约后，自动化流程从已有 RUN 存档完成选牌、出牌、回合结算、cash out 到 `SHOP`，调用游戏自身 `save_run()`/save-manager 写入 profile 与 run save；首次 reload 恢复真实存档，随后 20 次 reload 全部为 storage ready 且存档存在。末轮 documents/nodes/listeners 1/17/46→1/17/46，heap 3,065,512→2,628,176 B，释放后 graphics/source/AudioFile/voice 均归零，页面异常 0；`build/web-pthreads/balatro-full-game-reload20-strict.json`、`build/web-pthreads/balatro-full-game-reload20-strict.png`。未执行该包 30 分钟 soak，不能据此关闭 P5-09 |
| 2026-09-09 | `result/love-pthread-player` | Emscripten 3.1.74 pthread 构建、静态门禁与真实浏览器导入 | 通过 | macOS arm64、锁定 Rust 1.85.1/Node 22.14.0/CMake 3.30.5；正式产物由 `DORA_WEB_PTHREADS=1 build_web.sh` 生成，WASM、pthread glue、导入/停止/IDBFS/隔离契约通过静态检查，目录无 `.dora` 和 Balatro 标记。Headless Chrome 用运行时生成的无授权 Love `.dora` 完成导入、启动、停止、缺失项目错误清理和再次启动；COOP/COEP 本地页面选择用户指定 `balatro_fixed.dora` 后完成 ZIP 检查、稳定 ID 安装并显示 Balatro 启动画面，Stop 返回项目列表并确认存档同步。首次实现的隐藏 Canvas 0 framebuffer 与无用户手势音频 Promise 卡启动均已在通用宿主层修复；浏览器与服务器均已关闭 |

新增验证记录必须包含日期、commit/worktree、构建 profile、浏览器与版本、操作系统/设备、测试入口、结果和证据路径。未知字段写“未记录”，不能猜测。

## 14. 每周更新模板

```text
更新日期：YYYY-MM-DD
本周完成：P?-?? ...
当前进行：P?-?? ...
新增风险：R-?? ...
解除阻塞：...
验证证据：commit / CI URL / report / screenshot
下周目标：P?-?? ...
范围变化：无 / 说明设计章节与原因
```

## 15. 里程碑验收清单

### Player 开发预览（P0—P2）

- [ ] 干净 CI 生成 Web artifact。
- [x] Headless Chromium 显示最小 Lua 场景首帧。
- [x] manifest 启动资源和按需资源加载通过。
- [x] Fetch 成功、失败、超时与取消通过。
- [x] 设置或存档刷新后恢复。
- [x] `.dora` 导入完成全量安全检查。

### Player 首版（P0—P4）

- [ ] 桌面浏览器核心矩阵通过。
- [ ] Android/iOS 浏览器核心子集通过。
- [x] Sprite、Label、RenderTarget、常用资源和 2D 物理通过。
- [ ] 键鼠、触摸、手柄选定范围通过。
- [ ] AudioContext 解锁、播放、恢复和重启 soak 通过。
- [x] 首包、启动和内存预算达到或依据证据正式修订。
- [x] 30–60 分钟稳定性测试通过。
- [ ] 原生平台回归通过。
- [ ] 英中文档和公开限制同步。

### LoveNode Web（P5）

- [x] Love 基础模块 fixture 通过。
- [x] `love.load` 非阻塞契约通过。
- [x] Canvas、Mesh、SpriteBatch、ParticleSystem 和坐标视觉证据通过。
- [x] Love shader 翻译与坐标 fixture 通过。
- [x] 失败 shader 不发生未声明的静默视觉降级。
- [x] 音频、资源释放、reload 和多实例 soak 通过。
- [x] 复杂项目输入、修改和 Dora 扩展使用均可复现。
- [x] 指定 Balatro 包完成可见牌局、商店、真实存档恢复和 20 次 reload。
- [ ] 指定 Balatro 包完成 30 分钟长稳。

### Web Workspace（P6）

- [ ] 导入、启动、停止、重载和删除闭环通过。
- [ ] Yue/Teal 编译和源码错误定位通过。
- [ ] Wa Worker 可选加载且不冻结页面。
- [ ] 多项目生命周期和持久数据隔离通过。
- [ ] 浏览器差异和 fallback 已记录。

## 16. 更新约定

- 开始任务时将对应行改为“进行中”，填写负责人和当前分支/卡片。
- 实现完成但缺浏览器、设备或视觉证据时使用“待验证”。
- 任务完成后补验证记录，再更新阶段完成度。
- 新问题先加入“当前问题与风险”，再决定拆任务或调整阶段。
- 设计决策变化时同步修改 README、相关任务和变更记录，不能只改进度百分比。
- 如果后续使用 `akb` 创建实现卡，在任务行附卡片 ID；看板负责工作流状态，本文负责工程阶段和验证证据，不手工修改看板 frontmatter。

## 17. 变更记录

| 日期 | 变更 | 影响 |
| --- | --- | --- |
| 2026-09-08 | 建立 Web Player 优先的设计和进度跟踪 | D0 完成；所有实现阶段保持未开始 |
| 2026-09-08 | 登记 PR #122 架构审查和两次本地构建结果 | 原型不计入实现进度；P0/P5 风险与复现要求明确 |
| 2026-09-08 | 启动 P0 实现：共享 578 项 CMake source list、显式 tolua++ 生成、工具链锁、Rust WASM 构建、Web build probe、静态检查与 Ubuntu CI | P0 完成 2/9；其余项目按真实证据保持进行中或待验证，build probe 不计作 Player |
| 2026-09-08 | macOS 临时目录构建并通过浏览器加载 build probe | 页面显示 `Dora SSR Web build probe ready`，console 无 warning/error；完整 engine 编译的首个缺口定位为单线程 Web 下 `bx::Thread` 不可用，进入 WebApplication/WebTaskQueue 实现阶段 |
| 2026-09-08 | 完成 Web engine object compile gate | 共享 578 项清单中过滤 8 项平台/Love backend 后，570 个对象在 Emscripten 下 100% 编译；新增单线程主循环、延迟 WebTaskQueue、取消代次和无 semaphore 的 Web 读路径，尚未完成可执行链接 |
| 2026-09-08 | 将 WebTaskQueue 拆入平台层并增加真实异步探针 | build probe 在 `main()` 内断言任务未同步执行，浏览器事件循环执行后才报告 ready；Web gate 现为 570 个 engine 对象加 1 个平台对象；macOS arm64 Debug 原生构建通过，P0-09 完成，P0 总进度更新为 3/9 |
| 2026-09-09 | 建立固定截图、Headless Chrome 与 20 次 reload 内存门禁 | P1-06/P1-07/P1-08 完成，P1 达到 8/8；记录 Headless SwiftShader 的 bgfx/WebAudio 非致命 warning 为 R-11，不把能力探测噪声误判为生命周期泄漏 |
| 2026-09-09 | 实现 `.dora` 浏览器安全导入与真实 IDBFS 原子安装 | P2-09 完成，P2 达到 5/10；首版拒绝加密/ZIP64/symlink 和私密状态文件，导入只安装不执行，选择器与用户确认留在 P3-09/P6 |
| 2026-09-09 | 完成虚拟路径、缓存失效、Fetch 网络、入站能力声明和 IDBFS 合批 | P2 达到 10/10；锁定工具链真实 Player 与 Chrome 集成通过，P0 仍仅等待外部 Ubuntu/macOS Actions |
| 2026-09-09 | 启动输入、音频和页面生命周期适配 | minimal binding 新增 Keyboard/Mouse/Touch/Controller/Audio，宿主层完成失焦释放、音频解锁、真实 tab suspend/resume、文件选择回退和能力矩阵；SoLoud backend 增加每设备 generation/关闭保护；桌面 Chrome 完成 6/10，Gamepad 接口进入待验证，P3 保持 60%，移动端、真实手柄和系统中断继续跟踪 |
| 2026-09-09 | 完成 Web 引擎 suspend/resume 调度闭环 | P3-08 进入待验证：隐藏期冻结 logic/render、`bgfx::frame()` 与帧计时但继续泵送输入/停止任务，恢复时重置 delta 基线；Chrome 显式帧计数、真实 tab、音频状态和 20 次 reload 均通过，移动端/Safari 与系统中断仍保留人工验收 |
| 2026-09-09 | 建立 Web 首包与启动性能门禁 | P4-07 完成，P4 达到 70%；CI 上传冷/热启动分段与 raw/gzip/brotli 报告，本机锁定工具链通过 5 s/2 s/20 MiB 门禁和 20 次 reload，外部部署 P75 仍由发布验收跟踪 |
| 2026-09-09 | 建立 Lua/YueScript/Teal Web 示例兼容集 | P4-08 完成，P4 达到 80%；源码与预生成 Lua 一同发布，浏览器以日志、独立像素和 20 次 reload 验证三种语言的普通 minimal 项目路径，运行期编译边界保持不变 |
| 2026-09-09 | 建立 Web Player 长时稳定性门禁 | P4-09 完成，P4 达到 90%；手动 CI 可运行 30 分钟 soak 并上传逐分钟趋势，本机锁定工具链通过帧、heap、DOM、listener、错误、生命周期 warning、最终画面和 stop 清理验收 |
| 2026-09-09 | 启动桌面浏览器矩阵并建立版本化报告 | P7-01 进入进行中；Chrome/Edge 152 使用同一锁定 Player 完整通过 20 次 reload，报告记录真实产品版本并按浏览器分文件；Safari 等待用户开启远程自动化，Firefox 尚未安装 |
| 2026-09-09 | 建立性能与体积趋势门禁 | P7-06 完成，P7 达到 14%；CI 对 runtime/首载 gzip/brotli 执行相对基线门禁，对冷/热启动执行绝对预算，并上传趋势 JSON 与 step summary |
| 2026-09-09 | 建立 Web 版本目录原子升级与回滚 | P7-04 完成，P7 达到 29%；浏览器 manifest 使用 staging/backup 交换并隔离旧请求，CI 生成不可变 preview 版本目录、原子入口和回滚工具；P4-10 进入待验证，仍缺公共 URL 与托管端证据 |
| 2026-09-09 | 建立 LoveNode Web capability matrix | P5-01 完成，P5 达到 11%；19 个 Love 模块按 candidate/limited/deferred/unsupported 分级，minimal 仍明确排除 Love，后续 P5 fixture 不再从“原生可编译”外推 Web 支持 |
| 2026-09-09 | 启动 LoveNode Web 基础运行时适配 | P5-02 进入进行中；Emscripten 平台识别、完整 `LoveRuntime.cpp` 非发布编译探针和 engine CI 入口已完成，minimal 发布能力不变；下一步建立可链接测试 runtime 与无 Dora API 的浏览器 fixture |
| 2026-09-09 | 完成 LoveNode Web 基础运行时验收 | P5-02 完成，P5 达到 22%；Love support 静态库和可执行非发布探针接入标准构建/CI，无 Dora API 的 Lua fixture 在锁定 Node 与 Chrome 152 通过并完成 20 次 reload；minimal/full 发布能力仍保持关闭，后续进入非阻塞启动、复杂图形、音频与多实例验收 |
| 2026-09-09 | 完成 LoveNode Web 非阻塞启动契约 | P5-03 完成，P5 达到 33%；Web `LoveNode` 以指令预算逐帧恢复 `love.load`，提供显式 `love.bootYield()`，浏览器心跳、异常、关闭、20 次 reload 与原生同步构建回归通过；长时间原生 C 调用仍须异步化或拆分，发布能力保持关闭 |
| 2026-09-09 | 完成 LoveNode Web 基础图形视觉验收 | P5-04 完成，P5 达到 44%；真实 `LoveNode`/bgfx WebGL2 fixture 的 Canvas readback、Mesh、SpriteBatch、ParticleSystem、固定坐标与 21 次释放全部通过并接入 CI；自定义 shader 和发布能力仍保持关闭 |
| 2026-09-09 | 完成 LoveNode Web shader 成功路径验收 | P5-05 完成，P5 达到 56%；Web 专用 shaderc 反射路径避免 Mesa optimizer 卡死，GLSL1/GLSL3 的 varying、uniform、sampler、precision、屏幕与顶点坐标经 Canvas 像素和 20 次 reload 验证并接入 CI；P5-06 失败策略和发布能力仍保持关闭 |
| 2026-09-09 | 完成 LoveNode Web shader 失败策略验收 | P5-06 完成，P5 达到 67%；翻译、WebGL 编译、program 链接和 `validateShader` 错误在 bgfx 资源创建前显式返回，含阶段、可识别 Love 源行、翻译摘要与浏览器日志；20 次 reload 证明无 fatal、无静默降级且失败后仍可成功渲染/释放，可选 package fallback 与发布能力保持关闭 |
| 2026-09-09 | 完成 LoveNode Web 音频与资源生命周期长稳验收 | P5-07 完成，P5 达到 78%；WAV/OGG/SoundData、手势解锁、播放控制、双实例隔离、重建和最终资源归零经 21 轮验证，30 分钟内 heap 斜率低于门槛且 DOM/listener/错误稳定；Web/原生及既有 Love 回归通过，移动设备听感与复杂项目仍待后续矩阵 |
| 2026-09-09 | 固定 LoveNode Web 复杂项目验证输入 | P5-08 完成，P5 达到 89%；授权本地 Balatro 1.0.1o-FULL 的 commit、既有 patch、source/runtime tree、Love/Dora 入口、修改边界、无 Dora 扩展声明和 P5-09 流程均机器可读并可只读复核；无 remote 与不可分发限制被保留，尚不计作浏览器运行通过 |
| 2026-09-09 | 完成 Balatro 当前浏览器验收门禁 | P5 达到 95%；清除社区方案对未跟踪 bgfx embedded shader 的隐式依赖，修复 thread Channel 整数语义和 worker 写入后的 IDBFS 合批；用户指定包在 pthread/COOP/COEP profile 到达商店，真实存档首次恢复及 20 次 reload、资源释放和页面异常门禁通过；P5-09 仅保留该包 30 分钟长稳 |
| 2026-09-09 | 将复杂项目 probe 收敛为正式 `love-pthread-player` | 增加不内置游戏的独立 pthread 产物、Love `.dora` 安全导入、IDBFS 项目/存档持久化、最近项目与启动/停止 UI；指定 Balatro 经用户导入路径显示启动画面并完成 Stop 同步，旧 complex probe 仅保留自动化诊断；P5-09 的 30 分钟复杂项目长稳仍独立保留 |
| 2026-09-10 | 将 minimal Player 收敛为可裁剪 preset | 默认 profile 更名为 `dora-preset`，按开关组合 2D Physics、Entity、Platformer 和标准 Lua 资源；补齐常用 Lua 语法糖、默认字体与 eager 游戏打包，并修复 WebTaskQueue 异步回调缺少 autorelease pool 导致的音频流越界；三个 Dora-Demo 游戏在 Chrome 152 真实运行通过 |
| 2026-09-10 | 修复 minimal Player 的 2D 场景挂载 | minimal 运行时保留不依赖 View3D 的轻量 scene root，未挂载游戏节点不再进入 UI 树；Platformer 相机、场景触摸和全屏后处理恢复正常。Loli War 浏览器截图与原生布局一致，Zombie Escape、Dismantlism 持续运行 smoke 通过；旧 profile 名仅保留在负向测试中并会被 loader 拒绝 |
