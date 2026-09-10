# Dora Web 运行时适配设计

本文定义 Dora SSR 适配浏览器 WebAssembly 运行环境的产品边界、平台架构、构建方式和验收要求。目标是先交付可发布、可复现、可长期维护的 Web Player，再在同一平台层上扩展 Web Workspace 与 LoveNode 兼容能力。

分阶段任务、状态和验收证据记录在 [Dora Web 运行时开发进度](./PROGRESS.md)。

PR [#122](https://github.com/IppClub/Dora-SSR/pull/122) 是本设计的重要可行性参考：它验证了 Emscripten、WebGL2、IDBFS、项目导入以及 LoveNode/Balatro 兼容方向，同时也暴露了构建不可复现、同步化异步任务、全量资源预加载、bgfx 改动过深和诊断代码未收敛等问题。本设计不要求原样合并该 PR。

## 1. 最终决策

| 项目 | 决策 |
| --- | --- |
| 首个产品 | Web Player：通过静态站点直接运行单个 Dora 游戏 |
| 后续产品 | Web Workspace：导入 `.dora` 或目录，在浏览器内预览、编译和运行 |
| 首个运行基线 | 普通 Dora Lua 项目；LoveNode 与 Balatro 不作为平台首版前置条件 |
| 引擎形态 | Emscripten 编译的单页 WASM 运行时，浏览器主线程拥有事件和 WebGL 上下文 |
| 主循环 | `requestAnimationFrame` / Emscripten main loop 驱动单线程逻辑与渲染 |
| 异步模型 | 浏览器 Promise 与 Worker 完成后投递到 Dora 主线程任务队列；禁止把全部 Async 直接同步内联 |
| 渲染 | 优先复用 bgfx 上游 WebGL2 后端，Dora 平台差异放在 Web adapter 中 |
| 资源 | manifest 驱动的按需 Fetch；不把完整 `Assets/` 预加载进通用 `.data` |
| 持久化 | IDBFS 只保存设置、存档和用户导入项目；网络资源使用浏览器缓存策略 |
| 项目包 | `.dora` 保持 ZIP 容器，使用版本化 `dora-package.json` 描述入口和兼容要求 |
| 网络 | 浏览器中不启动入站 HTTP/WebSocket Server；客户端请求使用 Fetch/WebSocket |
| 音频 | 首版复用稳定的 SDL/WebAudio 通路，用户手势解锁；长期评估 AudioWorklet |
| 语言 | Lua 为必选；Yue/Teal 按 profile 选择；Wa 编译器作为独立 Worker/WASM 可选模块 |
| Love2D | 作为独立兼容层分阶段接入，不修改 Web 平台核心语义 |
| 验收原则 | 构建、启动、画面、输入、音频、持久化和长时间稳定性分别提供证据 |

## 2. 目标

- 在 Chrome、Edge、Firefox 和 Safari 的当前稳定版本中运行导出的 Dora 游戏。
- 保持 Dora 场景树、Lua 脚本、2D 渲染、基础物理、输入和音频的核心行为。
- 通过静态文件服务器或 CDN 部署，不要求本地原生 Dora 服务常驻。
- 允许游戏按需加载资源，并提供明确的加载、错误和兼容性状态。
- 支持刷新页面后恢复设置和游戏存档。
- 为 `.dora` 导入、Web Workspace、LoveNode 和离线运行保留扩展边界。
- Web 适配代码不破坏 Windows、macOS、Linux、Android 和 iOS 的现有行为。
- 所有发布能力都能从干净 checkout 在 CI 中重建并由真实浏览器验证。

## 3. 非目标

首版不以以下能力为目标：

- 在浏览器中启动 Dora 的 HTTP Server、Web IDE 后端或本地监听端口。
- 完整移植 Git、Agent、资源市场和原生进程管理能力。
- 将整个 `Assets/`、所有编译器、Love2D 和全部第三方模块放入一个首包。
- 支持 POSIX socket、`fork`、`exec`、`dlopen` 或任意原生动态模块。
- 承诺所有浏览器支持目录选择、持久文件句柄或相同的自动播放行为。
- 在首版承诺 Love 11.5 完整兼容、LuaJIT 兼容或未修改 Balatro 的完整运行。
- 把 WASM 页面当作不可信代码的安全沙箱；导入项目仍是在当前页面权限内执行代码。

## 4. 产品与构建 Profile

### 4.1 Web Player

Web Player 是首个交付目标。一个发布目录包含引擎启动文件、游戏 manifest 和游戏资源：

```text
dist/web-game/
├── index.html
├── dora-player.js
├── dora-player.wasm
├── dora-player.data          # 仅最小内置资源，可为空
├── dora-web-manifest.json
└── assets/
    ├── init.<hash>.lua
    ├── player.<hash>.png
    └── ...
```

页面加载后自动运行 manifest 指定的入口。Player 不包含项目选择器、编译器 UI、Git 或 Dora HTTP Server。

### 4.2 Web Workspace

Web Workspace 复用 Player 引擎，增加：

- `.dora` 和目录导入。
- IDBFS 项目管理。
- Yue/Teal 编译。
- 可选的 Wa Worker。
- 启动、停止、重载和错误展示。

Workspace 是独立构建产物，不能通过给 Player 无条件加入全部工具来实现。

### 4.3 建议的构建 Profile

| Profile | 必选内容 | 可选内容 | 用途 |
| --- | --- | --- | --- |
| `core` | Lua、2D 渲染、输入、基础音频、Content | 由裁剪开关增加模块 | 最小基线和定制起点 |
| `dora-preset`（默认） | core + 2D 物理、Entity、Platformer、标准 Lua 库与默认字体 | 继续通过裁剪开关调整 | Dora 2D 游戏发布；覆盖 Loli War、Zombie Escape、Dismantlism |
| `custom` | core + 显式启用的裁剪模块 | 2D 物理、Entity、Platformer、标准 Lua 库 | 产品定制运行时 |
| `web-player-full` | minimal + 常用 Dora 子系统 | 3D、视频、LoveNode | 功能完整的游戏导出 |
| `web-workspace` | full + 项目导入和编译工具 | Wa、Love 开发工具 | 浏览器内开发和预览 |
| `love-pthread-player` | Love 11.5 adapter、pthread、`.dora` 导入、IDBFS | 项目最近列表 | 运行需要 `love.thread` 的 Love 项目 |

模块通过 CMake cache 和统一 feature manifest 管理。`DORA_WEB_PROFILE` 可选 `core`、`dora-preset`、`custom`，默认值为 `dora-preset`；`DORA_WEB_FEATURE_PHYSICS_2D`、`DORA_WEB_FEATURE_ENTITY`、`DORA_WEB_FEATURE_PLATFORMER`、`DORA_WEB_FEATURE_BUILTIN_LIBS` 均接受 `AUTO`、`ON`、`OFF`。`AUTO` 跟随所选 profile，显式值用于进一步裁剪；Platformer 配置必须同时启用 Entity 和 2D Physics。构建产物通过 `dora-web-features.json` v2 记录实际能力，浏览器宿主从 `DoraWebPlatform.features` 查询同一对象。

当前 minimal Player 使用共享 Dora API binding 加编译期 guard：裁剪掉的模块不会注册，避免手工维护一套不断漂移的缩减 API。默认 `dora-preset` 包含 Lua 基础库、常用 2D 渲染与动画、输入、音频、Particle、Spine、DragonBones、NanoVG、ImGui、PlayRho 2D、Entity、Platformer、标准 Lua 库及默认字体；仍排除 Yue/Teal 运行期编译器、Wa/Wasm runtime、LoveNode、ML、3D 物理、3D 节点、视频、Workspace 和 Rust Dora bridge。Dora-Demo 的三个目标游戏使用预生成 Lua，并以 eager manifest 安装资源，均已在本地 Chrome 真实启动并持续运行。

## 5. 总体架构

```text
Hosting Server / CDN
├── Dora runtime artifacts
├── dora-web-manifest.json
└── hashed game assets
          │
          ▼
Browser Bootstrap
├── loading/error UI
├── feature and browser checks
├── audio unlock/fullscreen/file picker
├── Fetch/Cache Storage
└── Promise and Worker bridge
          │
          ▼
Dora WASM Runtime
├── WebApplication: main loop and lifecycle
├── WebTaskQueue: async completion and cancellation
├── WebContent: virtual paths and lazy resource loading
├── WebHttpClient: Fetch/WebSocket adapter
├── SDL input + bgfx WebGL2
├── Lua and selected language runtimes
└── IDBFS: saves/settings/imported projects
          │
          ├── optional compiler Worker
          └── optional LoveNode compatibility layer
```

平台相关实现集中在：

```text
Projects/Web/
Source/Web/
├── WebAssetLoader.cpp
├── WebTaskQueue.cpp
├── WebHttp.cpp
├── WebLuaManual.cpp
└── WebXrtNetwork.cpp
```

跨平台实现优先保留在已有通用源码中，通过宏隔离差异，与 Dora 现有组织方式一致。`Source/Web/` 仅承载 Web 专用的资源加载、任务队列和宿主桥接，不建立统一的按平台拆分源码目录层级。

## 6. 构建系统

### 6.1 可复现构建

Web 构建必须从干净 checkout 完成以下步骤：

1. 固定 Emscripten、Rust、Go、Node 和 CMake 版本。
2. 运行 `Tools/tolua++/build.sh` 或等价的跨平台绑定生成 target。
3. 构建 `wasm32-unknown-emscripten` Rust static library。
4. 按 profile 构建 Dora engine target。
5. 构建可选的 Wa Worker/WASM。
6. 生成带内容哈希的资源 manifest。
7. 检查产物大小、导出符号和禁止依赖。
8. 启动静态服务器并运行浏览器测试。

Web CMake 不解析 Linux CMake 文件文本来获得源文件。推荐把跨平台源文件定义为共享的 CMake target/source list，再由 Linux 和 Web 平台分别链接。

当前 P0 构建入口会同时生成工具链探针和真实 Dora Web Player：

```bash
Tools/build-scripts/build_web.sh
node Tools/build-scripts/check_web_output.mjs result/dora-web-build-probe
node Tools/build-scripts/check_web_loader.mjs
node Tools/build-scripts/check_web_package.mjs
node Tools/build-scripts/check_web_player_output.mjs result/dora-web-player
node Tools/build-scripts/check_web_forbidden_deps.mjs result/dora-web-player
node Tools/build-scripts/check_web_browser.mjs result/dora-web-player
```

需要 Love thread 的项目使用独立的正式 player，不改变默认单线程 Dora Player：

```bash
DORA_WEB_PTHREADS=1 Tools/build-scripts/build_web.sh
node Tools/build-scripts/check_web_love_player_output.mjs result/love-pthread-player
```

产物位于 `result/love-pthread-player`。页面要求托管端返回
`Cross-Origin-Opener-Policy: same-origin` 和
`Cross-Origin-Embedder-Policy: require-corp`；满足 cross-origin isolation 后，用户可选择或拖入含根 `main.lua` 的 `.dora` Love 包。浏览器会在完整 ZIP 路径、大小、CRC、加密、ZIP64、symlink 与私密文件检查后原子安装到 `/user/projects`，项目与 Love 存档通过 IDBFS 持久化。相同内容使用稳定 SHA-256 项目 ID，不会重复解包。正式产物不预载测试游戏，也不包含 Balatro；`DORA_WEB_LOVE_COMPLEX_PACKAGE` 只保留给诊断 probe。

版本锁位于 `Projects/Web/toolchain.env`。本地诊断其他工具链版本时可临时设置 `DORA_WEB_ALLOW_TOOLCHAIN_DRIFT=1`；该开关不得用于 CI 或发布验收。`dora-web-build-probe` 隔离验证工具链和异步队列，`dora-web-player` 则链接真实引擎并运行最小 Lua/DrawNode 场景。当前 Player 仍是功能裁剪中的开发工件，不代表资源、输入、音频和浏览器矩阵已经验收。

示例游戏通过 `package_web_game.mjs` 生成内容哈希资产和 v1 manifest。Player 在执行 Dora `main` 前校验 manifest 与启动文件，并挂载到 `/game`；通用 `.data` 只保留 `/builtin` bootstrap，不包含完整 `Assets/` 或游戏内容。构建会先清理受控的打包目录，静态门禁要求 `assets/` 与 manifest 精确一致，防止旧内容哈希文件混入发布包。

普通脚本项目按“源码随包、Lua 执行”的方式发布：Lua 文件直接执行；YueScript 与 Teal 在构建前生成 Lua，源文件和生成文件都进入 manifest，浏览器只加载生成 Lua，因此 minimal profile 不需要携带两个编译器。当前兼容集包含 Lua Sprite、YueScript DrawNode 和 Teal Label 三个独立示例；浏览器测试会检查源码/生成来源、唯一完成日志和各自的像素区域。运行期编辑与编译仍属于后续 Web Workspace，不在 Player minimal 能力内。

`check_web_forbidden_deps.mjs` 检查 shared memory/pthread、动态链接段、原生库工件、本机构建路径、凭据样式内容和全局 Asyncify。当前 Web player 已移除全局 Asyncify，标准门禁不使用例外参数；`--allow-asyncify` 仅保留给诊断历史产物，不能用于 CI 或发布验收。`check_web_package.mjs` 生成 Store/Deflate ZIP fixture 和恶意变体，覆盖检查与原子安装/回滚；Headless Chrome 再使用真实 IDBFS 验证导入后 reload 恢复。

### 6.2 Emscripten 基线

首版基线：

- WebGL2 / GLES 3。
- `ALLOW_MEMORY_GROWTH=1`，但必须设置可观测的最大内存。
- C++ exceptions 只在实际依赖要求时启用并记录体积成本。
- 默认不启用 pthreads，避免首版强制 COOP/COEP。
- 默认不全局启用 Asyncify；需要时限定到明确调用路径。
- 只导出稳定的 JS bridge API，不导出整个 runtime method 集合。
- Release 产物关闭 Assertions 和诊断 probe；Debug profile 单独保留。

### 6.3 产物检查

静态检查至少包括：

- `.wasm`、`.js`、HTML、manifest 都存在且非空。
- JS 语法可解析，WASM 可实例化。
- manifest 中所有文件均可下载并通过大小与哈希检查。
- 不包含本机绝对路径、凭据、私有配置或开发缓存。
- 不存在未允许的 pthread、动态链接或同步网络依赖。
- Release 产物不包含 probe、逐帧像素回读或高频诊断日志。

静态检查不能替代浏览器运行测试。`check_web_browser.mjs` 启动一次性静态服务器和 Chromium 浏览器，在固定 1280×720 viewport 等待 Lua ready 标记，拒绝控制台错误和 WebGL context 丢失/耗尽等生命周期 warning，并保存最终合成截图和 RenderTarget readback PNG；像素门禁分别验证 DrawNode、Sprite、Label、blend、scissor、stencil、Particle、Spine、DragonBones、NanoVG、PlayRho debug draw 与 ImGui 窗口/字体/裁剪按钮的颜色和边界。测试会在同一会话切换 DPR 1→2→1，核对画布缓冲和物理像素缩放，并确认 ImGui 点击不泄漏到 Dora 场景输入。设置 `DORA_WEB_RELOADS=20` 后还会逐次验证唯一 ready，并在强制 GC 前后比较 document、DOM node、listener 和 JS heap；bgfx 能力探测及旧 WebAudio 后端产生的普通 warning 会计数报告，由后续任务单独消除。可用 `DORA_WEB_CHROME` 指定 Chrome/Edge/Chromium 可执行文件；报告通过 `Browser.getVersion` 写入实际产品和版本，设置 `DORA_WEB_REPORT_SUFFIX=chrome|edge` 可保留互不覆盖的矩阵 JSON，默认文件名继续兼容 CI。

`Projects/Web/performance-baseline.json` 保存可审查的 runtime/首载 gzip 与 brotli 基线，以及 5 秒冷启动、2 秒热启动预算。`check_web_performance.mjs` 对确定性体积指标允许最多 5% 增长，超过即失败；启动时间只和绝对预算比较，避免把开发机硬件差异固化为相对基线。CI 将当前值、基线、上限和结果写入 step summary，并上传 `web-performance-trend.json`。确有必要的体积增长必须在同一变更中更新基线，不能只放宽检查器。

长时稳定性通过 `DORA_WEB_SOAK_SECONDS` 启用，`DORA_WEB_SOAK_SAMPLE_SECONDS` 控制采样间隔。每个样本在强制 GC 后记录引擎 frame heartbeat、JS heap、documents、DOM nodes、listeners、page errors 和 warnings；测试拒绝帧停滞、结构累积、新增错误、context lost/OOM、超过 8 MiB 的 heap 增量，以及五分钟以上超过 256 KiB/min 的线性趋势，并写出 `web-soak-report.json`。GitHub Actions 的普通 push/PR 不增加 30 分钟成本；手动 `workflow_dispatch` 默认运行 1,800 秒并上传报告。锁定工具链的本机 Chrome 152 已完成 1,800.015 秒、31 样本验收：frame 31→108,027，documents/nodes/listeners 始终 1/17/37，JS heap 2,276,520→3,381,040 B，线性斜率 37,660 B/min，无新增 error 或 lifecycle warning。

## 7. 应用生命周期与主循环

浏览器主线程拥有 Canvas、SDL 事件和 WebGL context。每帧执行：

```text
poll browser/SDL events
→ deliver completed async tasks
→ update fixed-step accumulator
→ run Dora logic
→ submit Dora render commands
→ bgfx::frame()
→ schedule next animation frame
```

生命周期状态统一为：

```text
Booting → Ready → Running → Suspended → Stopping → Stopped
                     └──────────────→ Faulted
```

要求：

- 当前 Player 页面隐藏时冻结 Dora logic/render、`bgfx::frame()` 和帧计时，同时继续泵送 SDL、逻辑与渲染任务队列，使输入释放和 stop 仍可完成；恢复时重置时间基线，避免把后台时长计为一个超大 delta。后续 profile 可把该策略扩展为游戏可配置降频。
- WebGL context lost 时停止提交，恢复后重建 GPU 资源或明确报告不可恢复。
- `shutdown()` 只停止游戏和引擎任务，不尝试终止浏览器页面。
- 每次启动、停止和重载都有 generation token；旧异步回调不能进入新实例。
- Runtime fatal error 必须进入 Faulted 并显示用户可理解的错误，不保留半初始化状态。

## 8. 异步与 Worker 模型

Web 平台禁止将所有 `Async::run()` 简化为立即执行。统一规则：

- Fetch、文件选择、IDBFS sync 等浏览器异步操作通过 JS Promise 完成。
- 完成结果只进入线程安全/单线程安全的 `WebTaskQueue`，在下一帧逻辑阶段调用 C++/Lua callback。
- 不允许 Promise completion 直接重入正在执行的 Lua 或场景逻辑。
- 每个任务持有 owner、generation、cancel token 和完成状态。
- stop/reload 时先取消 owner 的任务，再销毁 Lua handler 和引擎对象。
- 图片处理、解压、编译等 CPU 重任务优先放独立 Worker；Worker 只交换字节和结构化消息，不持有 Dora 原生对象指针。
- 必须运行在主线程的长任务拆成可预算的分片，并通过 coroutine/task scheduler 逐帧让出。
- 禁止同步 XHR、主线程 busy wait 和依赖浏览器恰好异步回调的未定义顺序。

## 9. Content、资源和持久化

### 9.1 虚拟路径

运行时定义稳定的虚拟根：

| 路径 | 用途 | 后端 |
| --- | --- | --- |
| `/builtin` | 最小字体、shader、启动脚本 | WASM preload 或只读内存 |
| `/game` | 当前发布游戏 | manifest + Fetch/cache |
| `/user/saves` | 存档 | IDBFS |
| `/user/settings` | 设置 | IDBFS |
| `/user/projects` | Workspace 导入项目 | IDBFS |
| `/tmp` | 解包和中间结果 | MEMFS |

普通脚本继续通过 Dora `Content` 访问路径，不直接依赖浏览器 URL。

当前 minimal profile 将 Lua bootstrap 编译进 `LuaCodeWeb.cpp`，因此 `/builtin` 只预载只读说明文件；后续 profile 的字体和 shader 仍放在该稳定根。`/game` 只通过 manifest loader 写入，minimal Lua binding 不暴露保存 API；持久写入限定到 `/user`，导入 staging 也放在 `/user/projects` 的同一 IDBFS mount 内；`/tmp` 保持会话级 MEMFS。

IDBFS 在 `preRun` 阶段先 populate，再允许引擎进入 ready。显式 `doraSyncUserStorage()` 会合并并发 flush；普通写路径使用 `doraQueueUserStorageSync()` 的 250 ms debounce，同一批共享 Promise。若写入发生在进行中的 flush 内，会在当前 flush 后再执行一次；配额不足映射为明确错误，失败会清理同步状态以允许重试。

### 9.2 发布 manifest

`dora-web-manifest.json` 是静态部署清单，不等同于 `.dora` 内的 `dora-package.json`：

```json
{
  "format": "dora-web-game",
  "version": 1,
  "engineVersion": "1.9.2",
  "profile": "dora-preset",
  "entry": "init.lua",
  "files": [
    {
      "path": "init.lua",
      "url": "assets/init.01234567.lua",
      "size": 2048,
      "sha256": "...",
      "startup": true
    }
  ]
}
```

manifest 解析必须校验格式版本、路径、URL origin 策略、大小上限和哈希。启动资源可并行预取，其他资源首次访问时加载。

当前 Player 将非启动资源接入 Web 下的 `Content.loadAsync*()`：同步 `Content.load*()` 只读取已挂载文件，不隐式阻塞浏览器主线程；异步加载在 `/game` 缺失时通过 JS Promise Fetch，完成大小与 SHA-256 校验后原子写入 MEMFS。同一路径共享一个进行中的 Promise，失败会清除该状态以允许后续重试。JS/C++ 回调经 `WebTaskQueue` 延后投递，并用 generation 在 Content 销毁后丢弃旧完成事件。

manifest 请求固定使用 `no-cache`，内容哈希 URL 使用 `force-cache`。新 manifest 成功挂载时，loader 会移除上一代受控文件和临时文件，再只接受新清单内的路径；即使旧内容仍残留在 MEMFS，也不能绕过当前 manifest 复用。

### 9.3 `.dora` 导入

`.dora` 保持 ZIP 格式。Workspace 导入流程：

```text
选择文件
→ 检查压缩包大小
→ 在 /tmp 解包并验证全部 entry
→ 校验 dora-package.json 和 init.*
→ 原子移动到 /user/projects/<id>
→ syncfs
→ 用户确认后启动
```

必须限制文件数、单文件大小和总展开大小，拒绝绝对路径、盘符、反斜杠、空路径、`.`、`..`、重复规范化路径和符号链接。检查包内容时不得执行代码。

当前 `DoraWebPackage.inspectPackage()` 在 JS 内存中先完成 ZIP EOCD、central/local header、压缩方式、范围重叠、CRC-32、UTF-8/NFC 路径和全部配额检查；首版明确拒绝加密、多磁盘、ZIP64、symlink、隐藏状态、`node_modules`、凭据/数据库和日志文件，只接受 Store/Deflate。随后要求版本化 `dora-package.json`、可运行 `init.*`，并拒绝高于当前 Dora 的引擎版本。`installPackage()` 只接受已检查的内存结果，在 `/user/projects/.dora-import-*` staging 完整写入后于同一 IDBFS mount 内 rename；sync 失败会删除目标并再次 flush 回滚。这样没有依赖 MEMFS→IDBFS 跨挂载 rename 的原子性假设。导入 API 不自动执行项目，文件选择和用户确认入口仍属于 P3-09/P6。

## 10. 网络

- 浏览器中 C++ `HttpServer.start()`、`startWS()` 明确返回 false，不伪装启动成功；host script 可通过 `DoraWebNetwork.capabilities` 或 `Module.doraWebCapabilities` 查询 HTTP/WS server 为 unsupported，并获得原因。
- C++ `HttpClient` 使用 Emscripten Fetch，各 client 独立持有和取消请求，response/download 硬上限分别为 64/512 MiB。Player 的 `DoraWebNetwork` Promise 契约保留状态码、header、超时、取消、流式进度和 64 MiB 响应硬上限。
- WebSocket 只提供客户端连接；连接状态和消息回调经主线程任务队列投递。
- host script 默认只允许同源 HTTP(S)；显式 allowlist 的跨域请求仍受浏览器 CORS 约束。错误分类为 URL/origin、network/CORS、timeout、cancel 和 size；非 2xx 响应保留状态与 body，不与网络失败混淆。
- 默认只允许 manifest 同源资源；跨源资源必须由发布配置显式允许。
- 浏览器不支持的 Git、socket 和服务端 API 在能力表中标记，不注册半可用接口。

## 11. 渲染

### 11.1 Dora 渲染基线

接入顺序：

1. Canvas resize、DPR 和 viewport。
2. 清屏、Sprite、Label 和基础 blend。
3. RenderTarget、scissor、stencil 和截图。
4. 粒子、Spine、DragonBones 和 NanoVG。
5. 2D 物理调试绘制。
6. 3D、阴影和高级纹理格式。

每一层都要有固定 fixture 和像素/截图证据。不得从“shader 编译成功”推断最终画面正确。

P4-01 已采用 `ScissorNode` 对普通 Dora 节点子树施加 framebuffer-space 矩形裁剪，并与 `ClipNode` stencil 分开验收。RenderTarget 异步 readback 只在测试入口执行并保存证据，不进入逐帧发布路径。

P4-02 使用仓库内最小 Particle、Spine 与 DragonBones 文本资源，并在构建时用纯 Node 确定性生成两张 RGBA 纹理；NanoVG 通过 `VGNode` 同时验证填充和矩形裁剪。四类资产继续走 manifest 按需 Fetch，不进入 runtime bootstrap；浏览器测试以互不重叠的坐标和颜色区域分别断言画面，并通过 20 次 reload 与显式 stop 覆盖资源释放。

P4-03 将 Dora 的 BodyDef、Body、Sensor、PhysicsWorld 和 DebugDraw 2D wrapper 加回 minimal profile；PlayRho 求解器沿用共享 source manifest。由于 `PhysicsWorld.cpp` 同时包含 3D bridge，Web 目标定义 `DORA_NO_3D_PHYSICS` 只编译 2D 部分，产物门禁同时拒绝 Jolt/3D bridge 标记。fixture 使用静态地面与动态矩形验证重力、质量、碰撞、raycast 和休眠后的 debug draw，Joint 与复杂 contact/sensor API 留给示例兼容集按需开放。

P4-04 只向 minimal profile 开放固定窗口、文字、按钮、样式、裁剪和 item bounds 所需的 ImGui API，并暴露 system scheduler 以在字体 atlas 未锁定时替换自定义字体。fixture 固定验证窗口、22px 字体和 72px 裁剪按钮；浏览器测试点击可见区域并确认事件不落入 Dora 场景触摸层，同时用 DPR 1/2 截图和画布指标证明 framebuffer 物理像素正确倍增。完整 ImGui binding 继续留给 full profile 评估。

P4-05 的高风险能力结论如下。这里的“延后”表示不会进入首版 Player 的能力声明；源码可编译或浏览器暴露某个扩展，都不能替代模块级 fixture 与跨浏览器验收。

| 能力 | 首版结论 | 当前证据 | 重新评估条件 |
| --- | --- | --- | --- |
| 3D 渲染 | 延后到 `web-player-full` 实验 | minimal 显式排除 Model3D cache、Node3D/Surface3D/Light3D/Model3D/Visual3D/View3D 和 Camera3D；3D C++ wrapper 依赖未链接到 Player 的 Rust C ABI；当前发布产物无 `dora_3d_node_`/`dora_3d_model_` runtime 标记 | Rust runtime 与 3D wrapper 进入独立 full target，并完成 glTF、光照、阴影、context restore、体积与桌面/移动浏览器 fixture |
| Jolt 3D 物理 | 延后，不进入 minimal | Web 目标从共享 `/Physics/` 源中只加回 PlayRho 2D 文件，并定义 `DORA_NO_3D_PHYSICS`；禁止依赖门禁拒绝 `dora_3d_physics_` 与 `JoltPhysics`；Jolt 的大型源集合和 bridge 尚未做 Web 链接/运行验收 | 先建立单线程确定性模拟与体积基线，再决定是否提供可选模块；若需要并行版，必须另行满足 COOP/COEP 与 pthread 部署契约 |
| 视频 | 延后；首版不声明 `VideoNode` | Ogg/Theora 的 `VideoNode.cpp` 可被 Emscripten 编译，但 minimal binding 未暴露，LTO 后发布产物无 `VideoNode:`/`Ogg/Theora` 标记；无 pthread 时现有 `Async` worker 在主线程 Web task queue 解码，可能造成长任务 | 建立浏览器媒体适配层，以 `HTMLVideoElement` 为兼容基线、WebCodecs 为可选加速，补用户手势、解码格式、纹理上传、暂停/后台和音画同步矩阵；不得直接启用主线程 CPU 解码 |
| RGBA8 与 D24S8 | 支持 | P4-01 真实 RenderTarget/readback 通过；Chrome WebGL2 framebuffer probe 均 complete 且无 GL error | 保持现有像素、readback 与 browser matrix 门禁 |
| RGBA16F/RGBA32F 渲染目标 | 条件支持候选，不进入首版稳定声明 | Chrome 152 SwiftShader 的 `EXT_color_buffer_float` 可用，RGBA16F/RGBA32F framebuffer 均 complete；float linear 也可用 | full profile 运行时能力查询必须与 bgfx format caps 一致，并在无扩展设备回退或明确拒绝；完成 Firefox/Safari/移动端像素 fixture |
| BC/S3TC、ETC、ASTC、PVRTC | 按设备可选，当前延后资产承诺 | Chrome 152 SwiftShader 探测到 S3TC/S3TC-sRGB、ETC、ASTC，未探测到 PVRTC，证明单一压缩格式不可作为通用发布输入 | manifest 增加格式变体/回退选择或接入统一转码格式，并在桌面与移动真机验证上传、采样、mipmap、sRGB 和 context restore |

Headless 测试会把本次 WebGL2 renderer、尺寸上限、颜色附件数、浮点附件和压缩纹理扩展写入 `build/web-advanced-texture-capabilities.json`；该报告描述当前浏览器/GPU，不是跨设备支持清单。CI 同时上传 DPR 2 截图与该 JSON，供能力漂移审查。

### 11.2 bgfx 边界

- 优先使用可追溯的 bgfx WebGL2 能力，不在 fork 中保留游戏专用逻辑。
- 必须修改 bgfx 时，补最小复现、上游差异说明和独立回归。
- Release 禁止逐帧 `glReadPixels`、全 pipeline dump 和无界 trace。
- Dora shader 的 Web 变体尽量离线生成；运行时只处理用户动态 shader。

### 11.3 Love shader

Love shader 翻译器属于 LoveNode adapter：

- 维护 Love GLSL → 目标 ESSL 的独立输入输出 fixture。
- 校验 varying、uniform、sampler、precision、Canvas 和坐标约定。
- 编译或链接失败时返回原 shader、翻译结果摘要和 WebGL 日志。
- 默认不得静默换成普通 Sprite；如产品允许降级，必须由 package capability 显式声明并向用户显示。

P5-05 的成功路径在真实浏览器中暴露了两个不能由静态编译发现的问题：Mesa `glsl-optimizer` 在单线程 Wasm 中进入不返回的优化调用；跳过优化后，bgfx 旧反射解析又会在源码辅助函数前停止，导致第一个 program 链接时尚不存在 `u_loveTransform`。当前仅由 Dora Web link target 定义 `DORA_SHADERC_WEB_RUNTIME`：shaderc 保留已预处理的 ESSL，移除 renderer 会重复注入的 directive，并从完整源码独立收集 uniform 声明写入 shader binary；原生目标仍走原优化器，renderer 通用层未增加 Web 分支。LoveNode 的纹理绘制命令同时与动态 Mesh 统一为 Love y-down 顶点输入，通过 `u_loveTransform` 完成 y 翻转和投影，因此自定义 `position()` 中的像素偏移保持 Love 语义。GLSL1/GLSL3 fixture 以 Canvas readback 和截图验证 varying、数值 uniform、额外 Image sampler、highp/mediump 与 `gl_FragCoord` 屏幕坐标。

P5-06 把错误路径前移到任何 bgfx 资源创建之前。Web 目标从 shaderc bytecode 读取最终 ESSL，在当前 WebGL2 context 中同步编译 vertex/pixel 并链接 program；失败通过 `[love-shader/translation]`、`[love-shader/compiler/<stage>]`、`[love-shader/driver/<stage>]` 或 `[love-shader/driver/link]` 返回 Lua，包含可识别的 Love 源行、翻译后字节数和浏览器日志，避免 renderer 延迟创建时的 fatal。负向 fixture 分别触发翻译签名错误、未定义 GLSL 函数、跨阶段 uniform 数组长度冲突，并同时验证 `newShader` 的 `pcall` 和 `validateShader` 返回；四次失败后同一节点仍完成成功 shader 出图和释放，20 次 reload 中没有 `BGFX FATAL` 或默认 Sprite 静默降级。机器可读 capability 将默认动作固定为 `explicit-error`、`silentFallback=false`；可选 package 降级仍为 `available=false`，未来若启用必须声明 `features.love.shaderFallback` 并暴露 capability 状态和日志。

## 12. 输入与窗口能力

- Canvas 获得焦点后接收键盘、鼠标、触摸和手柄事件。
- Pointer 坐标统一从 CSS pixel 转换到 drawable pixel，再转换为 Dora visual coordinate。
- DPR、浏览器缩放、横竖屏和全屏变化必须触发一次原子尺寸更新。
- Player 以 Canvas 双击作为首版用户手势全屏入口；浏览器 `fullscreenchange` 产生的 SDL resize 更新 `Application.visualSize`、`bufferSize`、`devicePixelRatio` 和 `fullScreen`，退出全屏时同样恢复，拒绝全屏只发送非致命 `dora-fullscreenerror` 事件。
- 触摸 ID 在按下到释放期间稳定；丢失焦点时合成释放事件，防止按键或摇杆卡住。
- 文件选择同时支持 File System Access API 和 `<input type=file>` 回退。
- 虚拟键盘、IME、剪贴板和鼠标锁作为独立能力跟踪，不用桌面行为推断浏览器行为。

当前 Player 由 `web-platform.js` 暴露 `DoraWebPlatform` 宿主契约和能力矩阵。它记录宿主按键与触点，在 `blur` 时向 Canvas 合成 `keyup`/`pointercancel`、释放 pointer capture，并调用 Web runtime 的输入释放入口把 Dora Controller 按键和轴归零；Lua minimal binding 暴露 Keyboard、Mouse、Touch、Controller 和 Audio，脚本可通过 SDL/Dora 状态和 `Node.slot` 接收键盘、鼠标、滚轮、触摸与标准手柄事件。文件选择优先调用 `showOpenFilePicker()`，不可用时创建一次性隐藏 `<input type=file>`；两条路径都只返回 `File`，不会自动安装或运行内容。桌面 Chrome 自动化已经验证多点触控/取消，并在浏览器 Gamepad API 边界模拟连接、按键、轴、失焦释放、恢复和断连；原生选择 API 的适配契约及真实 `<input>` chooser 也已通过。真实 Gamepad、File System Access OS chooser、IME 和移动浏览器仍保留在 P3/P7 矩阵中。

## 13. 音频

首版范围：WAV/OGG、播放/停止/暂停、循环、音量和基础混音。

要求：

- 首次用户交互时恢复 AudioContext，并向游戏报告解锁状态。
- 设备初始化和销毁有 generation token；旧回调不得访问已释放的 WASM 对象。
- 页面隐藏、系统中断和 AudioContext suspend/resume 后状态可恢复。
- 音频 callback 不分配大块内存、不持锁等待主线程，也不调用 Lua。
- 连续播放、快速重启、反复开关声音和多声源压力必须验证。
- AudioWorklet 迁移在兼容性与延迟测量后决定，不能只根据 API 新旧替换。

当前实现复用 Emscripten SDL2 创建的 WebAudio `AudioContext`：首次 `keydown`/`pointerdown` 或显式 `unlockAudio()` 时执行 `resume()`；`visibilitychange` 和 Player stop 分别调用 suspend/resume 与最终关闭，状态通过 `dora-visibilitychange` 事件可观测。固定 22,050 Hz WAV 与 Vorbis OGG fixture 已通过 Dora `Audio` 的播放、循环、暂停、全局音量和停止测试，OGG 字节内嵌在生成脚本中，因此 CI 不依赖宿主音频编码器。SoLoud SDL2 static backend 已从进程级全局设备改为每设备状态；关闭时先持有 SDL device lock，将 generation 和 SoLoud 指针失效，再关闭并释放 backend data。Web stop 更早把 ScriptProcessor callback 替换为空函数并断连，随后浏览器断言 SDL audio device 与 AudioContext 都不可达。桌面 Chrome 的真实 tab 前后台切换和 20 次 reload 已验证；移动端/系统音频中断与 AudioWorklet 仍由 P3/P7 继续跟踪。

生命周期调度与音频使用同一 visibility 状态：隐藏期冻结 Dora logic/render、`bgfx::frame()` 和帧计时，但继续泵送 SDL 与任务队列；恢复时重置 delta 基线。`dora-visibilitychange` 同时携带引擎帧号，桌面 Chrome 已显式验证冻结期帧号不增长、恢复后继续增长；移动端和系统音频中断仍需设备验收。

## 14. 语言运行时

| 能力 | Player minimal | Player full | Workspace |
| --- | --- | --- | --- |
| Lua 执行 | 必选 | 必选 | 必选 |
| Yue/Teal 已生成 Lua | 支持 | 支持 | 支持 |
| 浏览器内 Yue/Teal 编译 | 不包含 | 可选 | 必选 |
| Dora WASM 脚本 | 按需 | 按需 | 按需 |
| Wa 浏览器内构建/格式化 | 不包含 | 不包含 | 可选 Worker |
| Git 能力 | 不包含 | 不包含 | 首版不包含 |

编译器不应延迟 Player 首屏。Workspace 的 Wa 模块独立下载、独立实例化，并通过消息 API 返回结果；编译失败不能使 Dora 引擎 runtime abort。

## 15. LoveNode Web 兼容

LoveNode Web 适配建立在稳定的 Dora Web Player 之上：

1. 验证普通 Love 回调、Image、Font、输入和基础音频。
2. 接入 Canvas、Mesh、SpriteBatch 和 ParticleSystem。
3. 接入 shader 翻译、坐标转换和多 RenderTarget。
4. 建立资源释放、reload 和长时间运行门禁。
5. 最后使用复杂项目验证兼容覆盖。

`Projects/Web/love-capabilities.json` 是 P5 的机器可读能力基线。它覆盖 `LoveRuntime` 实际注册的 19 个模块，但顶层保持 `available: false`：原生 Dora adapter 存在只证明候选实现，不等于已经进入 Web full profile。CI 同时检查模块完整性、milestone/reason、minimal CMake 排除规则和 `loveNode=false` feature 声明。

P5-02 已建立独立的非发布运行边界。`DoraLoveSources.cmake` 将 Love runtime/support 与 vendored Box2D 收入可复用静态库，`dora-web-love-compile-probe` 编译完整 `LoveRuntime.cpp` 和视频输入适配，`dora-web-love-link-probe` 再与 Dora engine/Web 链接依赖组成可执行 Wasm；Love module include 使用 target-local `BEFORE` 顺序消除大小写不敏感文件系统上的 `physics/Body.h` 冲突。Love 的平台配置在 `__EMSCRIPTEN__` 下复用 POSIX/Linux 路径并额外定义 `LOVE_EMSCRIPTEN`。标准 Lua fixture 不调用 Dora API，实际验证 Runtime open/configure/start/update/draw/stop/close、load/update/draw 与键鼠触摸回调、2×2 ImageData 像素、TrueType 默认字体 rasterizer、math random generator 和 data SHA-256；Node 与 Chrome 152 均通过，Chrome 连续 20 次 reload 无页面异常。该探针仍不链接进 minimal Player，`loveNode=false` 和顶层 `available=false` 保持不变；filesystem、完整输入矩阵和其余发布门槛继续由后续 P5 项验收。

P5-03 将 Web 启动改为明确的增量契约。Emscripten 下的 `LoveNode` 只在创建时调用 `beginStart()`，随后由场景更新循环以每帧 50,000 条 Lua 指令的预算恢复 `love.load` coroutine；原生平台仍走同步 `start()`。纯 Lua 计算达到预算时由 count hook 自动让出，项目也可在确定的批量加载边界调用 Dora 扩展 `love.bootYield()`。每个加载切片保持 graphics begin/end frame 成对，完成后才进入 update/draw；异常保留 Lua traceback，关闭待完成实例会释放 coroutine。不可让出的长时间原生 C 调用不在自动抢占范围内，仍须使用异步 API 或拆分工作。非发布浏览器 fixture 同时覆盖自动预算、显式让出、错误和 pending-close，并以计时器心跳证明事件循环在加载期间继续前进；Chrome 152 首次运行及 20 次 reload 共 21 次通过，最少 208 个加载切片、269 次心跳，最长约 1.545 秒。`available=false` 与发布 profile 排除保持不变。

P5-04 以真实 `LoveNode`、Dora 场景循环和 bgfx WebGL2 后端建立非发布图形 fixture，不使用 mock renderer。固定 320×180 Love 逻辑画布分别绘制可读 Canvas、静态 Mesh、两实例 SpriteBatch 和暂停的 ParticleSystem；Chrome 152 的 1280×720 截图对五个不重叠颜色区域执行像素数量与边界坐标断言，Canvas 另以 `newImageData()` 校验蓝色背景和绿色中心区的 GPU→CPU 回读。探针释放时验证 RenderTarget、动态 Mesh buffer、Image/Canvas、render pass 和 pending mipmap 均不残留；首次运行及 20 次 reload 共 21 次渲染和 21 次释放通过、页面异常为零。默认 shader 仅用于验证这四类对象的基础绘制，自定义 shader 翻译仍由 P5-05/P5-06 单独验收；`loveNode=false` 与顶层 `available=false` 继续保持。

P5-05 建立独立的非发布 `dora-web-love-shader-probe`。固定 fixture 同时编译 GLSL3 vertex/pixel shader 和 GLSL1 pixel shader，在 192×64 可读 Canvas 上用两色 mask、custom varying、`vec2`/`vec4`/number uniform、额外 sampler、highp/mediump 与 `screen.x` 分支产生四个确定颜色区域；GPU→CPU 像素断言和 1280×720 截图均通过。Chrome 152 首次运行及 20 次 reload 共 21 次创建、渲染和释放通过，P5-04 graphics fixture 的 20 次 reload 回归同步通过。该结果只把 `graphicsGroups.shaderTranslation` 的成功路径标为 passed；P5-06 的编译/链接失败诊断与可选降级、其余 P5 门槛、`loveNode=false` 和顶层 `available=false` 均保持不变。

P5-06 扩展同一 probe 为成功/失败组合门禁。每次运行先断言翻译、WebGL 编译、WebGL program 链接和 `validateShader` 四条失败路径均显式返回且不创建 bgfx shader，再执行 P5-05 的确定性画面；报告保存四类计数和诊断样本。Chrome 152 首次运行与 20 次 reload 共观察到每类失败 21 次、21 次后续成功渲染和 21 次清理，P5-04 graphics 20 次 reload、标准 Web 全量构建、发布产物门禁及 macOS arm64 Debug 原生构建同步通过。可选降级未启用，Love 发布能力继续关闭。

P5-07 增加独立的非发布 `dora-web-love-audio-probe`。同一 Dora runtime 内并存两个 `LoveNode`，各自创建 WAV static Source、OGG streaming Source、内存 SoundData Source 和 clone，覆盖 play/pause/resume/seek/stop/loop/volume/pitch；浏览器手势在资源建立后恢复当前 SDL2 AudioContext。每轮测试会重建第一个实例、单独销毁它并确认第二个实例仍播放，最后延迟两个 scheduler frame 断言 Love Source、`AudioFile` 与 SoLoud voice 全部回到基线。Chrome 152 首次运行及 20 次 reload 共完成 21 次重建、21 次隔离清理和 21 次最终清理；随后持续运行 1,800.000 秒、采样 31 次，frame 19→108,010，documents/nodes/listeners 恒定为 1/17/30，JS heap 2,134,288→3,403,080 B、线性斜率 42,151 B/min，低于 256 KiB/min，页面错误为零。标准 Web 全量构建、P5-02/P5-04/P5-06 浏览器回归、发布产物门禁和 macOS arm64 Debug 原生全量构建同步通过。Headless 自动化证明 API、AudioContext 和资源生命周期，不替代移动设备/系统中断的真实听感矩阵；`available=false` 与发布 profile 排除保持不变。

P5-08 的最终复杂输入按用户指定改为本地 `balatro_fixed.dora`。它是 56,676,652 B、305 个条目的标准 ZIP，archive SHA-256 为 `6814cfedd8743e125fc2f18b84478796bff9b724f130cdebf2a09be94f57765b`，版本记录为 `1.0.1o-FULL`。`check_web_love_complex_input.mjs` 只读核对 ZIP 完整性、绝对路径/路径穿越、精确哈希、条目数、版本和入口契约，任一漂移都会拒绝；staging 只解压到未跟踪构建目录。P5-09 直接启动包根 `main.lua`，不执行含 Dora `LoveNode("main.lua")` wrapper 的 `init.lua`，因此所选运行路径不调用 Dora 扩展。包的来源基线未记录且已包含兼容改动，不能宣称未修改 Balatro 兼容，也不得把包内容提交、上传或收入 Dora-SSR 发布产物。

P5-09 的 opt-in probe 只有在显式设置 `DORA_WEB_LOVE_COMPLEX_PACKAGE` 且包校验通过时才预载入 `/love-complex`，普通 CI/发布产物仍不含授权内容。此前目录输入曾暴露并修复 shader 精度限定、单文件 vertex/pixel 符号冲突、触摸到模拟鼠标事件、非有限 Text transform 和增量 `love.load` coroutine 栈保留等通用 adapter 缺口；这些结果继续作为独立兼容诊断，但用户更换输入后不再计作最终 Balatro 验收。指定包在锁定 Emscripten 3.1.74 pthread profile 下已通过启动、主菜单、固定游戏流、商店、真实存档恢复、20 次 reload 与最终资源释放；仍缺该复杂项目自身的 30 分钟长稳。

上述诊断路径已收敛为独立的 `love-pthread-player` 产品产物。它复用经过验证的 Love adapter，但把 Balatro 专用状态探针、自动点击和编译期 package staging 留在测试侧；正式页面从用户手势导入任意通过检查且根目录含 `main.lua` 的 `.dora` Love 包，挂载 IDBFS 后按项目启动、停止并同步存档。首轮浏览器验收使用用户指定的 `balatro_fixed.dora`，完成导入、启动画面和 Stop 后同步返回启动器；包本身未进入构建或发布目录。

| 能力组 | 当前 Web 状态 | 进入支持前的门槛 |
| --- | --- | --- |
| callbacks、data、math、event、timer | 候选 | Lua 兼容、事件顺序、suspend/delta fixture |
| Image、Font、基础 Graphics | 候选 | 解码/像素格式、字体布局、截图和释放 fixture |
| keyboard、mouse、touch、joystick | 候选 | 复用 Web 输入桥并完成 DPR、取消、Pointer Lock、Gamepad 矩阵 |
| filesystem | 候选 | 接 WebContent/IDBFS，并定义异步启动让出；不能直接依赖同步 `std::filesystem` 路径 |
| sound/audio | P5-07 桌面 Chrome 已通过 | WAV/OGG/SoundData、gesture、重建、双实例隔离、20 次 reload 与 30 分钟 soak 已通过；移动设备听感、后台恢复和系统中断仍由 P3/P7 矩阵验收 |
| Canvas、Mesh、SpriteBatch、ParticleSystem | P5-04 已通过 | 真实 LoveNode/bgfx fixture 的像素、坐标、Canvas readback、21 次资源释放门禁已通过；发布仍受其余 P5 项约束 |
| shader translation | P5-05/P5-06 成功与失败路径已通过 | GLSL1/GLSL3 的 varying、uniform、sampler、precision、Canvas readback、截图、21 次释放及翻译/编译/链接负向门禁已通过；默认显式失败且无静默降级，可选 package 降级尚未启用 |
| window、system | 有限候选 | 只提供虚拟窗口/宿主桥；无原生 window handle/message box，电量与振动按设备能力 |
| thread | 默认 Dora Player 不支持；`love-pthread-player` 可用 | 默认发布保持 `USE_PTHREADS=0`；独立 player 使用 4 worker pool，并要求 COOP/COEP、cross-origin isolation 和 SharedArrayBuffer；iframe/PWA 与移动浏览器仍待验收 |
| video、physics | 首轮延后 | 分别需要浏览器媒体 adapter，以及独立 Box2D Web source/fixture 边界 |

`love.load()` 的浏览器启动采用真实的让出机制，而不是只把函数放进 coroutine：

- 普通 Lua 工作由指令 count hook 按帧预算自动 yield。
- 文件、网络和解码 API 应保持异步，并在等待资源时 yield；长时间原生 C 调用不能由 Lua 指令 hook 抢占。
- 大型项目可调用 Dora 扩展 `love.bootYield()` 主动划分加载阶段，并须在项目兼容性记录中声明该非标准扩展。

任何 Balatro 验收都必须记录游戏版本、是否修改源码、是否调用 Dora 扩展、测试流程和持续运行时间。当前 P5-08 输入是用户指定的本地 `.dora` 包，来源基线未记录且内容不得随 Dora-SSR 分发；只有设置 `DORA_WEB_LOVE_COMPLEX_PACKAGE` 并通过 `node Tools/build-scripts/check_web_love_complex_input.mjs` 后，才可把后续结果计入 P5-09。

## 16. 安全边界

- `.dora` 与远程 manifest 均视为不可信输入，写文件前完成全量路径和大小检查。
- 禁止将凭据、token、用户主目录、构建机绝对路径打入产物。
- 默认 CSP 禁止任意远程脚本；如 Emscripten glue 需要 `unsafe-eval`，必须记录原因并争取消除。
- 用户导入项目与发布游戏建议使用独立 origin，避免访问 Web IDE 的敏感同源数据。
- IDBFS 数据按应用/项目 namespace 隔离，删除项目时清理对应存档要由用户确认。
- Future pthread profile 需要 COOP/COEP，必须单独评估嵌入 iframe、第三方资源和部署限制。

Preview 打包器会从实际 release HTML 提取 inline script/style 的精确 SHA-256，生成不含 `unsafe-inline`/`unsafe-eval` 的 CSP；WebAssembly 仅使用 `wasm-unsafe-eval`，外部脚本、Fetch、字体和媒体按最小同源能力开放。根入口使用单独的无 inline CSP。`check_web_preview.mjs` 拒绝放宽策略，`check_web_browser.mjs` 在本地 preview 根目录按生成的 header 实际运行完整 Player，因此静态字符串存在不能替代浏览器无 violation 的证据。托管端仍必须在公共 URL 返回相同 header。

## 17. 初始性能预算

以下是首轮工程预算，不是已经达到的结果；完成 P1/P2 测量后允许按证据修订：

| 指标 | 初始目标 |
| --- | --- |
| `dora-preset` JS + WASM gzip | 不超过 20 MiB |
| 通用内置 preload gzip | 不超过 5 MiB |
| 最小示例首次可交互 | 桌面宽带 P75 不超过 5 秒 |
| 最小示例二次启动 | P75 不超过 2 秒 |
| 空场景稳定内存 | 连续 30 分钟无单调增长 |
| 典型 2D 示例 | 60 FPS 目标设备中 P95 帧时间不超过 20 ms |
| 页面隐藏 | CPU 与渲染显著降频，音频行为符合配置 |

产物大小按 raw、gzip 和 brotli 分别记录；启动时间拆分 HTML、JS、WASM、资源下载、实例化、脚本启动和首帧，不用总时间掩盖瓶颈。

P4-07 已把预算落实为自动化门禁。`check_web_browser.mjs` 在清空浏览器缓存后记录冷启动，再以真实 HTTP 缓存记录热启动；报告包含 Navigation/Resource Timing、shell/manifest/启动资产/IDBFS/runtime/首帧 marks，以及 runtime、发布辅助文件和启动资产的 raw/gzip/brotli 分组。锁定 Emscripten 3.1.74 的 Chrome 152 本机基线为：冷启动可交互 2,808.2 ms、热启动 872.7 ms、runtime gzip 2,285,357 B，均低于 5 s、2 s 和 20 MiB 门禁；热启动 JS/WASM/data 与游戏资产 transfer size 均为 0。该结果是本机确定性回归证据，不代替部署网络上的桌面宽带 P75。

## 18. 浏览器与部署矩阵

| 环境 | 首版要求 | 特殊关注 |
| --- | --- | --- |
| Chrome/Edge 桌面 | 必须通过 | File System Access、WebGL2、手柄 |
| Firefox 桌面 | 必须通过 | 文件选择回退、shader 差异 |
| Safari macOS | 必须通过 | WebAudio 解锁、IDBFS、内存 |
| Chrome Android | 必须通过核心子集 | 触控、横竖屏、后台恢复、内存 |
| Safari iOS | 必须通过核心子集 | 音频、虚拟键盘、页面生命周期 |
| iframe 嵌入 | P1 延后 | fullscreen、存储、跨源隔离 |
| 离线 PWA | P1 延后 | cache version、升级和空间回收 |

“核心子集”至少包括启动、Sprite、触摸、音频、资源加载、存档和恢复。高级 3D、视频、Love shader 按能力矩阵独立标记。

### 18.1 版本目录、缓存与回滚

Web preview 不覆盖已发布文件。`package_web_preview.mjs <player-dir> <deployment-dir> <release-id>` 将完整 Player 复制到不可变的 `releases/<release-id>/`，为每个文件记录大小和 SHA-256，然后才用原子 rename 更新根目录的 `dora-web-current.json`。稳定的 `index.html`/`dora-web-entry.js` 每次以 `no-store` 读取该指针并跳转到版本目录，因此版本切换只依赖一个原子文件。上传顺序必须同样遵循“版本目录全部成功 → current pointer 最后切换”，不得先让入口指向尚未完整上传的目录。

根目录的 `dora-web-deployment.json` 是托管契约：入口 loader 和 current pointer 使用 `no-cache`，版本目录使用一年 `immutable`，WASM 必须返回 `application/wasm`，根入口和每个 release 使用各自记录的 CSP。工件自带 `README.md` 与 `README.zh-CN.md`，说明上传顺序、回滚、安全边界和 minimal profile 限制。`check_web_preview.mjs` 会创建两个版本、验证所有哈希、拒绝覆盖既有版本、检查 HTTP 缓存/MIME/CSP 行为并执行一次回滚。`rollback_web_preview.mjs <deployment-dir>` 只原子交换 current/previous 指针，不修改任一不可变版本目录。部署平台必须把该契约转换为自己的 header 配置并在公共 URL 再验证；本地通过不等同于 P4-10 已公开发布。

## 19. CI 与验收

### 19.1 CI 层级

| 层级 | 内容 |
| --- | --- |
| 静态 | 格式、manifest、禁止依赖、符号和产物大小 |
| 构建 | 干净 Ubuntu 构建；macOS 开发者构建冒烟 |
| 浏览器单元 | JS bridge、路径、manifest、任务取消和错误映射 |
| 浏览器集成 | 启动、截图、输入、音频、IDBFS、Fetch |
| 兼容矩阵 | Chrome、Firefox、Safari 及移动端 |
| 长稳 | reload、音频重建、资源释放、30–60 分钟 soak |
| 原生回归 | Windows、macOS、Linux、Android、iOS 原有构建和关键测试 |

### 19.2 完成定义

一个 Web 能力只有同时满足以下条件才能标记“已完成”：

- 实现已提交，Release profile 可以从干净 checkout 构建。
- 自动测试验证成功和失败路径。
- 真实浏览器运行证据明确记录浏览器、版本、设备和代码版本。
- 涉及画面、坐标或 shader 时附截图或像素证据。
- 涉及输入或音频时附真实交互/播放证据。
- 涉及持久化时验证刷新和浏览器重新打开后的恢复。
- 文档记录支持范围、限制和错误行为。
- 未使现有原生平台回归。

## 20. 实施顺序

```text
D0 设计与基线审计
→ P0 可复现 Web 构建
→ P1 最小 Player 与主循环
→ P2 manifest、Content、Fetch 与存档
→ P3 输入、音频和页面生命周期
→ P4 Dora 子系统覆盖与发布 profile
→ P5 LoveNode Web 兼容与复杂项目验证
→ P6 Web Workspace
→ P7 发布、兼容矩阵和长期维护
```

P0—P2 完成后即可发布普通 Dora Web 游戏的开发预览；P3—P4 构成首个正式 Player 版本；P5 和 P6 不阻塞 Player 首版。

## 21. PR 拆分建议

| PR | 主要内容 | 明确排除 |
| --- | --- | --- |
| 1 | 共享 CMake source target、绑定生成、最小 Emscripten 构建 | IDBFS、Love、Workspace |
| 2 | WebApplication、主循环、Canvas、Sprite 冒烟 | 网络、音频、高级渲染 |
| 3 | manifest、WebContent、Fetch、Cache、存档 | 项目编辑器、Git |
| 4 | 输入、音频、页面生命周期 | Love shader |
| 5 | 子系统与构建 profile、发布工具 | Workspace |
| 6 | LoveNode 基础兼容 | Balatro 专用补丁 |
| 7 | Love shader/Canvas 与复杂项目验证 | Web 平台核心重构 |
| 8 | Web Workspace 和编译 Worker | 原生 Dora Server 移植 |

每个 PR 保持独立可构建、可运行、可回退；不得把平台基线与单个游戏的兼容补丁绑定为同一个合并条件。
