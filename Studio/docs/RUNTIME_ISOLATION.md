# Studio 试玩隔离验证

## 2026-09-15：普通 iframe 不能通过恢复门槛

本轮使用实际 Dora Web 引擎和自有 Lua 场景，不使用模拟 Canvas 游戏。结果不支持直接把当前 Player 嵌入工作室并宣称可安全停止不可信游戏。

| Chrome 桌面观测 | 同源 iframe | 跨站 iframe |
| --- | --- | --- |
| 正常场景首帧与停止 | 通过，绿色 DrawNode 截图已查看 | 通过，同一场景 |
| Lua 死循环期间子页面心跳 | 1 秒内 0 次 | 1 秒内 0 次 |
| 同期父页面心跳 | 0 次 | 20 次 |
| 父页面移除 iframe | 1.5 秒内未完成 | 完成 |
| 移除后在同一运行站点重建 | 无法进入重建操作 | 15 秒内未重新启动 |
| 满足响应与恢复门槛 | 否 | 否 |

跨站场景中，Chrome 的 CDP 明确列出了独立 iframe target；它保住父页面响应，但这次测试中移除 DOM 后仍无法在同一运行站点重建。不能把“能移除 iframe”视为已终止脚本或释放运行环境，也不能把本次 Chrome 进程分配外推为 Safari、Firefox 或移动浏览器保证。

## 复现与证据

在仓库根目录运行（Playwright、Chrome 与 runtime 目录按本机环境指定）：

```sh
STUDIO_PLAYWRIGHT_MODULE=/path/to/playwright \
STUDIO_CHROME_PATH=/path/to/chrome \
STUDIO_RUNTIME_DIR=/path/to/dora-web-build \
node Studio/tests/runtime-isolation.browser.mjs
```

默认 runtime 为 `build/web-demo-profile`。探针要求单线程 preset，并加载完整 HTML/JS/WASM/data、features、音频 mixer 和 worklet；不修改构建目录。每种拓扑使用独立自动化浏览器，临时本机服务只提供运行产物、测试 manifest 和 fixture。测试结束关闭这些浏览器和服务，不触碰用户的 8898 工作室。

Lua 先生成绿色 DrawNode，正常 fixture 通过引擎停止接口结束。故障 fixture 在独立一帧打印预告后进入 `while true do end`；预告与死循环分开，使日志有机会送出。父、子页面每 50 ms 向测试服务器发送心跳，观察由 Node 侧计时，不依赖已经卡死的页面去判断自身状态。恢复门槛失败作为实验结果写入报告，不伪装为产品测试通过；正常基线无法运行则探针报错。

最新完整报告与两张首帧截图位于忽略目录 `apps/web/artifacts/runtime-isolation/`，权威结果文件为 `report.json`；失败的早期探针日志不代替该报告。本轮 Chrome **152.0.7977.83**，使用 headless、SwiftShader 许可、localhost 域名映射和免用户手势音频测试设置；未强制启用 site-per-process。最终测试缺失资源为 0，页面/控制台 error 为 0。音频设置仅服务启动测试，不是音频听感或授权流程验收。

产物身份（报告时间 `2026-09-15T03:50:28.365Z`）：

- runtime WASM：9,811,003 字节；SHA-256 `5bf91722e13350e1e3f215b5a924c3412a94e1a9550df73497cb1d22cca939ff`。
- runtime JS：304,740 字节；SHA-256 `b694c55a5966e73b6bf594a9653fd63d8d16bd41adac1a32f7a2f8e3220ad604`。
- data：16,861,630 字节；SHA-256 `d1de8401f7d46f1200bef64287328c5e0359c2b5c0ae95524c5618a44768605d`。
- profile：dora-preset，threads=false。缓存 CMake 配置指向本机 Emscripten 5.0.5；本轮没有重建引擎，因此不能充当上游锁定工具链或可复现发布门禁的证据。

## 源码约束与下一步

### 主循环 Worker 实验（看板 #69 已归档，完整 P0 隔离仍进行中）

宿主清理后续验证：faulted 触发平台 dispose，但跳过 Wasm 重入和模拟输入事件。Chrome 152 在预先按住方向键的条件下，验证平台失活、输入记录归零、SDL 音频暂停、Worklet 上下文关闭；音频解锁/恢复请求无效，帧号 33/33，重建完整演示成功。单元测试另验证指针捕获释放、注销监听及不调用故障 Wasm。全量构建及 28 项测试通过；尚不代表内部控制器状态、重复销毁资源泄漏和所有音频后端验收。

2026-09-15 故障通知修复：Emscripten html5 WebGL 回调注册会同步代理到页面，不能观察 Worker OffscreenCanvas 的丢失事件。改为在实际运行画布注册一次监听，由所属逻辑线程在下一帧消费故障标记、暂停并报告 `faulted`；故障实例拒绝恢复。Chrome 152 重跑 GPU 探针通过，实际丢失事件、faulted 状态、恢复请求前后帧号 34/34、全新页面完整演示恢复均有断言，错误为 0。WASM SHA-256 `a6a2fae955e907b8e7da94a88c980efbcb130130405bb335ed1ddfe2c7659c96`。证据仍为 `apps/web/artifacts/runtime-worker-gpu/startup.json`。本轮仅验证此实验构建；音频/输入完整清理、默认单线程回归和其他浏览器尚未验证。以下 running 状态缺口为修复前记录，不是当前结果。

GPU 上下文故障探针：`STUDIO_TEST_CONTEXT_LOSS=1` 执行 `runtime-worker.browser.mjs`，在实际渲染 Worker 的 WebGL context 上调用 `WEBGL_lose_context` 并观察 `webglcontextlost`，不是只调用扩展就视为故障发生。Chrome 152 中事件已观察到；关闭运行页后创建新运行页，完整 manifest 演示再次完成且无错误，恢复截图已查看。独立证据目录 `apps/web/artifacts/runtime-worker-gpu/`。**发现缺口**：丢失事件后读取的宿主状态仍为 running，尚无自动故障通知/暂停。重建由测试执行，不是产品自动恢复。此测试不模拟真实显卡/驱动进程崩溃，也不证明同一 context 原地恢复或跨浏览器行为。

Edge 复测：Microsoft Edge 153.0.4234.32 使用同一实验产物和相同探针通过。正常 4 个 Worker 响应；死循环后 1 个超时、3 个响应；父/子页心跳均为 20，旧 Worker 全部退出并重启成功，错误/缺失资源为 0。以 `STUDIO_BROWSER_LABEL=edge` 指定独立证据目录 `apps/web/artifacts/runtime-worker-isolation-edge/`，原 Chrome 报告保留。此标签只隔离报告，不选择浏览器，仍须用 `STUDIO_CHROME_PATH` 指定实际 Edge 可执行文件。Chrome 与 Edge 都是 Chromium；本机尚未运行 Safari/Firefox 或移动设备验证。

**Lua 死循环恢复实验通过（Chrome 152，同源 iframe 承载主运行 pthread）。** 使用 `STUDIO_RUNTIME_THREADS=1` 和 `STUDIO_RUNTIME_DIR=../build/studio-main-worker` 从 Studio 运行已有隔离探针，另存 `apps/web/artifacts/runtime-worker-isolation/report.json`，不覆盖单线程基线。正常 4 个 Worker 全部可响应；真实 Lua 死循环后 1 个 Worker 的求值探针超时，其余 3 个响应，父页/子页在约 1 秒观察窗分别记录 21/20 次心跳。移除 iframe 后旧 Worker 数降至 0，重新挂载游戏成功，错误和缺失资源均为 0。探针先验证正常启动和停止，再测故障；等待 Worker 退出有 3 秒上限，重启有 15 秒上限。

这是一次实验环境证据，不是正式安全边界：本轮使用 COOP/COEP、同源测试来源、headless/SwiftShader 和免手势音频参数；未测跨浏览器、实际设备、GPU context loss、恶意来源隔离及全部音频/输入清理。接入正式 RuntimeHost 前仍必须补齐这些门槛。不能把同源测试布局原样当作不可信游戏的生产部署。

**最新启动结果：通过（Chrome 152.0.7977.83，诊断构建）。** 排查发现演示使用了旧式 `saveAsync(path, callback)`，但 WebInitialization 的公开 Lua 包装已等待完成并返回布尔值，演示自己的 readbackDone 因此永远不会置位。修正为检查返回值后，完整 manifest ready 标记与 Lua/Yue/Teal 示例均通过。探针另外读取实际 `/tmp/dora-web-render-target.png`：152 字节、PNG 魔数正确；没有页面/引擎错误或缺失 HTTP 资源。此项不等于 PNG 像素精度、音频听感或故障隔离验收。

诊断构建还发现并修复加载器依赖 FS/IDBFS 未显式导出的问题：开启 assertions 时原赋值被 Emscripten 的只读缺失导出保护拦截；Player 现显式导出这两个实际使用的模块。WASM SHA-256 `d38da7f46dfd9cf3657b8671d14f4091cfb73e7c35ef3c6a16d04878885e2883`，演示 init 内容哈希前缀 `02bf1cf8f707`。回读阶段日志未出现在此次 Release 输出中，结论来自公开包装源码、实际结束标记和生成文件，而非推测 GPU 已挂起。以下此前失败记录保留为排查历史。

回读定位开关：`DORA_WEB_DIAGNOSTICS=ON` 为 RenderTarget 源文件启用 `DORA_WEB_READBACK_TRACE`，记录提交帧号、GPU 完成、PNG 编码及文件保存阶段；默认构建不输出这些日志。该开关同时保留既有 Wasm 函数名和断言设置，诊断构建可能触发对象重编译。日志用于定位挂起，不改变回读完成条件，不作为修复本身。

资源代理实现后：`requestWebAsset` 在页面线程执行现有下载/校验，完成消息通过 Emscripten proxy queue 回到发起请求的逻辑线程后处理请求表和代次。实验完整链接及默认单线程 engine 对象构建通过；`check_web_loader.mjs` 的清单、延迟加载/去重/重试、IDBFS 测试通过。Chrome 152 现已实际请求 lazy.txt、图片、字体、WAV/OGG、Spine/DragonBones；没有页面或引擎错误，音频操作和 PlayRho 检查打印成功。截图已查看，显示 Sprite、文字、粒子、ImGui 与物理场景，不再空屏。新 WASM SHA-256 `20efdb2ad6c18e1dce53e251ff7bdfdcb883092cffa58ea7c680a73a08302a20`。

完整演示仍失败：20 秒内没有最终 ready 标记。源码在已打印 PlayRho 检查后等待 `RenderTarget:saveAsync` 完成，后续 Lua/Yue/Teal 示例请求均未发出；这将下一排查点缩小到异步回读/回调（尚未证明具体根因）。不把局部渲染、音频日志或无 error 当作完整启动通过。原生发布构建、Worklet 音频等价性和死循环恢复未完成。

资源断点复核：探针新增完整本机请求列表和页面/Worker 的只读状态快照。Chrome 实测页面 `Module.doraManifest=true`、`Module.FS=object`；4 个 Worker 都是 `doraManifest=false`、`Module.FS=undefined`，但加载器函数存在。服务器仅收到 init.lua 启动资源，没有收到 manifest 中的 lazy.txt 请求，缺失 HTTP 资源数为 0。因此目前证据支持“运行宿主状态未桥接”，不支持把问题归为网络 404 或坏资源内容。仍需检查 C++ 请求分支和回调线程，不能只把全部资源改为启动预加载来绕过延迟加载要求。报告含 `requests`、`workerState`、`pageState` 字段，仍以失败退出。

音频采样率修正后重建成功：Chrome 152 已进入 running，原 audioContext 异常消失；新 WASM SHA-256 `38a5ff67b80ff83fa0e7ff634c686498ce3742109fbb88d7c07e18e759b99842`。但演示 init.lua 第 79 行报告 `lazy Web asset content mismatch`，截图为空，不能宣称启动/渲染验收通过。探针现将 console.log 中的 `[error]` 也计为错误，避免只看 running 状态误报通过。下一步检查 Worker 的延迟资源加载/文件系统宿主桥接；完整音频听感及 Worklet 仍未验证。

已进一步定位首次崩溃：SDK SDL2 `src/audio/emscripten/SDL_emscriptenaudio.c` 第 273 行采样率读取使用 `EM_ASM_INT`，但创建 AudioContext 使用 `MAIN_THREAD_EM_ASM_INT`，因此读取发生在没有 SDL2 宿主对象的 Worker。实验 `MainWorkerAudio.cmake` 从显式指定的当前 SDK port 源码生成仅修正该调用的音频对象，并优先链接；不修改 SDK 全局缓存、不使用仓库另一版本的 SDL 内部头、不禁用音频。原始语句不存在时配置失败，要求重新审查。完整 Worklet 桥接与 SDL 回调线程语义仍须后续验证。

首次实际结果：独立完整引擎构建成功；Chrome 152.0.7977.83 创建 4 个 pthread Worker，但 20 秒内未进入 running。Worker 报 `Cannot read properties of undefined (reading 'audioContext')`。产物 WASM SHA-256 为 `a2157f7442b6ff1f265b63b4da422ac6e05de97977ec2aa68427b1e5fdac672a`。`Source/Web/WebAudio.h` 的现有 EM_JS 从本线程读取 `Module.doraAudio`，而 `web-audio.js` 只在页面安装宿主；SDK SDL2 音频后端也有直接 AudioContext 初始化路径。因此下一步须定位并适配音频跨线程初始化/调用，不能通过永久禁用音频满足验收。此处只有启动失败证据，尚未进行死循环恢复测试。

新增默认关闭的 `DORA_WEB_EXPERIMENTAL_MAIN_WORKER`，仅对 Player 链接启用 `PROXY_TO_PTHREAD`、`OFFSCREENCANVAS_SUPPORT` 和 `#canvas` 转移；必须同时启用 `DORA_WEB_PTHREADS`。关闭 pthread 的负向配置已确认报错。生命周期状态回调改为同步主线程代理，确保临时 UTF-8 字符串在页面读取前有效；SDK 定义在单线程模式下保留直接调用语义。

实验构建使用独立 `build/studio-main-worker` 目录、本机 Emscripten 5.0.5、Release、MODEL_3D=OFF、LOVE_PROBE=OFF，不引入外部游戏包。启动探针为 `Studio/tests/runtime-worker.browser.mjs`，从 Studio 目录执行，使用既有 `STUDIO_PLAYWRIGHT_MODULE`/`STUDIO_CHROME_PATH` 环境变量；测试服务提供 COOP/COEP，输出到 `apps/web/artifacts/runtime-worker/startup.json`。启动通过不等于隔离通过，音频跨线程调用、输入、终止及重建仍必须验证。

实验配置（仓库根目录；使用已安装 SDK 的 `emcmake`）：

```sh
emcmake cmake -S Projects/Web -B build/studio-main-worker \
  -DCMAKE_BUILD_TYPE=Release -DDORA_WEB_BUILD_ENGINE=ON \
  -DDORA_WEB_LINK_PLAYER=ON -DDORA_WEB_PTHREADS=ON \
  -DDORA_WEB_EXPERIMENTAL_MAIN_WORKER=ON \
  -DDORA_WEB_BUILTIN_FONT="$PWD/Assets/Font/sarasa-mono-sc-regular.ttf" \
  -DDORA_WEB_SDL2_PORT_SOURCE_DIR=/path/to/active-sdk/cache/ports/sdl2/SDL-release-2.32.10 \
  -DDORA_WEB_FEATURE_MODEL_3D=OFF -DDORA_WEB_BUILD_LOVE_PROBE=OFF
cmake --build build/studio-main-worker --target dora-web-player -j 6
```

Studio 试玩必须使用 `Assets/Font` 中的完整中文字库；Web preset 目录中的精简字体只覆盖基础字符，会使 Agent 生成游戏里的中文标签显示为方框。

当前源码也不能直接宣称支持主运行 Worker：

- 默认 pthread 配置只创建线程池；实验主运行选项已新增，但未通过完整运行验收。存在 pthread 不等于游戏主循环离开页面线程。
- `Source/Basic/Application.cpp` 的 Web 生命周期回调已改为主线程代理；其他页面桥接仍需逐项验证。
- `Projects/Web/web-loader.js` 的自动挂载依赖 document；独立 Worker 需要显式启动与快照挂载适配。
- `Projects/Web/web-platform.js` 的输入、文件选择、页面可见性与指针锁，以及 `web-audio.js` 的 AudioContext/Worklet 宿主，仍需要页面侧桥接。

下一实现方向是验证可终止的独立运行 Worker 与 OffscreenCanvas/适用 pthread 主循环，把 DOM 输入、生命周期和音频操作留在宿主侧桥接；必须继续实测 Lua 死循环、耗时原生调用、GPU context loss、销毁重建及浏览器矩阵。不能以跨站 iframe 或脚本指令预算替代整个故障恢复要求。

S-P0-07 保持进行中；正式工作室的试玩入口仍标注待接入。该结论阻止提前开放不可信运行，但不阻止继续实现正确的运行拓扑，也不是整个项目的外部阻塞。
