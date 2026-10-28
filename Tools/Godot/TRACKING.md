# Godot / Dora 集成跟踪

最后更新：2026-10-29

用户确认：继续采用 **Dora Apple2 / Godot Apple4** 的能力边界；不再推进 Godot Metal 降级至 Apple2。本文件作为本地进展与待办的统一入口。

本文件维护当前结论、产品决策与待办；逐轮实验和失败记录见 [PLAN.md](PLAN.md)，构建与使用方法见 [README.md](README.md)。报告路径均相对于仓库根目录，build/ 中的本地证据不保证随源码分发。

## 当前远程审查与 CI

已建立并关联草稿PR [#159](https://github.com/IppClub/Dora-SSR/pull/159)，分支 `dev/godot-runtime-integration`，提交 `d60c48b4e547e79ac67de02e4da75df3c8849622`；已用git ls-remote核对远程提交。v5 tree `d9062744eead2c0065b5e430bcfdb773428f2e6c`，289文件，补丁1334858字节/SHA256 `e45ae128f7f4c59b9800b93ea0a2eed9972cc4775379e153124829fa312032e9`，Source与v4无差异。提交从独立临时树生成，主分支HEAD、工作区及真实索引保持原状，15个无关文件与5个共享接口中的无关片段未纳入。

已触发12个远程工作流，具体run句柄保存在 `build/godot-runtime/godot-remote-ci-snapshot.json`。Godot Integration [run 40772555311](https://github.com/IppClub/Dora-SSR/actions/runs/40772555311)：Ubuntu协议/包校验job123113307518已success；Linux EGL job123113307056正在安装构建依赖，编译/GPU阶段尚未通过；macOS协议job123113307423排队。最新已观察Engine Tests、Windows、Linux工作流success，Godot的macOS协议job也success；其他工作流尚未取得终态，不能计为通过。PR为draft、未合并；本轮仅观察现有run，不重新触发或合并。后续先取实际终态与失败日志，再修复或归档。工作流总状态与子job可能不同，以上逐job状态以first-jobs.json记录为准。

本节是当前状态入口；下文“未提交/未推送/远程未执行”属于候选与本地实验的历史检查点。进展文档后续更新先保留在本地，不为状态变化反复推送，以免取消并重启正在运行的CI。

### Web 清理修复的本地验收

实际复现：Lua先print排入异步日志、再主动error，旧普通host WASM `5881fded...`在faulted后继续执行WebTaskQueue::drainOneTask→PoolManager::push，访问已销毁池而越界；旧包报告bootstrap-fault-pending-red/verification.json为false并保留完整堆栈。仅error且无排队任务的对照旧包会通过，不能宣称所有Lua错误都会崩溃，也不是浏览器只读属性赋值错误的复现。

现增加最终stopTaskQueue：在启动失败的活动池/GPU仍存活时释放排队捕获，正常停止和主入口返回时也幂等停止，晚到回调不再访问引擎对象。最终普通host WASM `4f1dfd0d350537e856138af5c1234afaf816a55a0e3f53b028cabd348916a6de`的Chrome/Firefox/Playwright WebKit故障与普通启动/停止均通过；严格故障用例无JS/Wasm越界、无GL错误，输入/IME清理且音频context关闭。CPU真实队列测试与整套协议也通过，见protocol-web-task-stop/及build/godot-web/task-stop-evidence/verification.json。

含Godot的core Debug宿主也已重建，WASM `fda4fcc1c4144eb64122ac57cc912ec9e9677b46b2aa43ecc7eff9a5c29c4911`：三浏览器2/3/4矩阵5580帧/108截图/990像素检查通过，GPU错误/PCM欠载/pending=0、平台退出清理通过，报告build/godot-web/task-stop-godot-matrix-{chromium,firefox,webkit}/verification.json。复用封存LibGodot WASM，来自当前工作区，不称为纯PR源码/Release构建。第一轮仅因自编驱动给位置参数误加--results而停在verifier CLI（exit2），原始case-2实际执行通过；保留failure-before-cli-correction.json及旧驱动，修正后对原case-2图像离线严格校验，再实际执行3/4，没有重跑二缓冲或放宽校验。

新增CPU检查、可复用Lua故障fixture/浏览器driver，以及Web CI的Chromium真实失败清理步骤，actionlint/脚本语法通过。该修复的远程验收须依据包含此变更的提交及新CI。新CI与旧d60c48b提交结果分别记录，不能把旧轮通过当作新修复通过。

## 当前结论

Godot 4.6 运行时已嵌入 Dora 进程，持续动画可经共享 GPU 纹理、有界多缓冲和同步显示在 GodotNode 中。macOS 有原生 Metal 运行证据；Windows、Linux、Android 有虚拟机/模拟器范围的运行证据；Chrome、Firefox、Playwright WebKit 已通过 WebGL2 回归。

集成仍处于实验阶段，尚未达到正式发布条件。主要缺口：iOS Apple4+ 真机正向运行、其他真实硬件、设备丢失恢复、长时间稳定性和性能、最终应用打包与分发。

### 进展速览

- **方案固定：** Dora iOS 保持 Apple2；可选 GodotNode 独立要求 Apple4。这里指 Metal GPU Family，不是 Metal API 版本。
- **核心路径已打通：** LibGodot 在 Dora 进程内运行，离屏 GPU 纹理显示到节点；持续动画、2/3/4 缓冲和同步已有实际运行报告。
- **macOS 验证最完整：** 优化 Release 组合持续运行 38.36 分钟通过；同进程 100 轮创建/销毁通过，所测 Metal 分配量无增长。其他平台的证据范围见下表。
- **iOS 当前只通过兼容边界：** Apple2 模拟器中普通 Dora 动画正常，Godot 安全拒绝；Apple4+ 真机的正向共享渲染仍未验证。
- **下一步优先：** 跟进草稿PR #159的实际远程CI终态与失败日志；v4核心源码的macOS/Linux完整本地证据已归档复核；收口绑定错误面与公开 API 一致性，补真实浏览器、设备恢复和发布打包。需要真机的项目单独等待设备与签名，不以模拟器结果代替。

## 产品决策

### D-001：Dora Apple2，GodotNode Apple4（已确定）

- Dora iOS 基础运行保持 Apple2，不提高普通 Dora 内容的全局 GPU 要求。
- GodotNode 的 iOS Metal 路径要求 Apple4 或更新的 GPU Family。
- Apple2/Apple3 环境可以运行普通 Dora 内容；创建 GodotNode 时安全拒绝，并可查询不支持原因。
- 不维护 Apple2 专用 Godot Metal 分支，也不采用 Godot OpenGL ES → Dora Metal 跨 API 共享方案。

当前实现：Dora 入口在 [Application.mm](../../Source/Basic/Application.mm) 检查 Apple2；[GodotRuntimeMetal.mm](../../Source/Godot/GodotRuntimeMetal.mm) 在运行库加载前独立检查 Apple4。GodotNode.getUnsupportedReason() 返回 GPU/backend 不支持原因，空字符串表示能力检查通过，**不表示运行库已安装或可成功启动**；节点创建在 Sprite/着色器创建前执行同一检查。

已验收：Apple2 配置的 iOS 模拟器中，Lua 查询与原生原因一致，Godot 未启动且清理通过；普通 Dora DrawNode 实际运行 180 帧，两张截图的动画与像素检查通过。报告：

- `build/godot-runtime/ios-capability-query/unsupported-gpu.json`
- `build/godot-runtime/ios-ordinary-dora-apple2-capture/verification.json`

这证明模拟器内的兼容边界，不证明 Apple4+ 真机 GPU 共享或正式应用包通过。

## 平台状态

| 平台 | 当前证据 | 已验证范围 | 主要缺口 |
| --- | --- | --- | --- |
| macOS Metal | 原生运行通过，含优化 Release host + Release LibGodot | 2/3/4 缓冲、38.36 分钟持续动画、同进程 100 轮创建/销毁与 Metal 资源观察、生命周期、resize、输入/音频/控制器、GPU 粒子、源场景尺寸/合成 | 其他项目/长期资源增长、恢复、完整 IME、物理手柄、正式发布包 |
| Windows WGL | Parallels Windows 11 ARM64 中执行 x64，受限运行通过 | 共享纹理、动画、生命周期、IME 提交、音频、控制器、C#/Rust/Wa 绑定，含 C# 新能力查询 | 物理 x64 GPU、恢复、候选窗口与物理手柄；首轮音频欠载原因待追查 |
| Linux ARM64 EGL | Ubuntu ARM64 VM / Mesa virgl、llvmpipe，受限运行通过 | 2/3/4 缓冲、动画、生命周期、输入、音频、控制器、GPU 粒子；软件 EGL 的 100 轮循环、普通 Debug 宿主项目恢复与缺库退化 | 物理 GPU、Release/分发、恢复、完整 IME、手柄 |
| Linux x86_64 | Rosetta + ANGLE/SwiftShader 下独立共享测试通过 | LibGodot → EGL 消费者共享 360 帧，GPU 错误为 0 | 原生 x86_64 硬件上的完整 Dora GodotNode |
| Android EGL | API 35 ARM64 模拟器中实际 APK，含优化 Release 测试代码，受限运行通过 | Apple M1 Pro 硬件转换的 2/3/4 缓冲、resize/cancel、别名、IME 提交、音频/stall、Home/恢复、控制器与清理 | 手机/平板真机、强制 context loss、完整输入法、旋转/多点触控、软件渲染下既有欠载 |
| iOS Metal | simulator/device 产物构建；模拟器兼容边界通过 | Dora Apple2 普通内容；Godot Apple4 安全拒绝与查询 | Apple4+ 真机共享、动画、多缓冲、生命周期、触摸、音频 |
| WebGL2 | Chrome 156、Firefox 153、Playwright WebKit 26.5 运行通过 | 三浏览器 2/3/4 缓冲、动画/生命周期、输入/控制器、PCM；Chrome context loss 安全停止与重载恢复 | 实际 Safari/移动浏览器、原地恢复、完整 IME、真实后台页、长期音频及延迟 |

### 主要报告索引

- macOS Release：`build/godot-runtime/release-optimized-node-{2,3,4}/verification.json`，各 1,000 帧/15 张截图，GPU 错误和 PCM 欠载为 0，正常退出；粒子和源场景输出分别见 `release-optimized-particles/verification.json`、`release-optimized-output/verification.json`。
- Windows / Linux ARM64：`build/godot-runtime/windows-controller-focus/verification.json`、`build/godot-runtime/linux-controller-focus/verification.json`；Linux x86_64：`build/godot-runtime/linux-x64-rosetta-angle-independent/verification.json`。
- Linux 最新本地 CI 与普通宿主：`build/godot-linux-ci-local/{ci-linux-fixed-cycles,ordinary-linux-project-boundary,ordinary-linux-fallback-v2}/verification.json`；循环与资源细节见 CI-01、PERF-01。
- Android：`build/godot-runtime/android-advanced.json`、`build/godot-runtime/android-controller-focus/verification.json`。
- 按需 PCM 新运行库三浏览器矩阵：`build/godot-web/chrome-demand-matrix/verification.json`、`firefox-demand-pcm-3/verification.json`、`firefox-demand-matrix-24/verification.json`、`webkit-demand-matrix/verification.json`。合计 5,580 帧、108 张截图、990 项像素检查，GPU 错误/PCM 欠载为 0。
- 浏览器实际输出探针：`build/godot-web/{chrome,firefox,webkit}-rendered-output-3/audio-output.json`，各通过 24,064 个 48kHz 帧的短音调输出。半秒探针不能证明长期无掉音；浏览器 outputLatency 不是端到端实测延迟。
- Web 恢复边界：`build/godot-web/context-loss-matrix.json`、`build/godot-web/context-loss-reload-recovery/verification.json`。仅安全停止与页面重载恢复，不代表原地 context restore。
- 能力查询 Rust/Wa：`build/godot-bindings-capability/node-{rust,wa}/verification.json`，优化 macOS host/runtime 中实际 Wasm3 各 1,000 帧通过；C# 新查询已在 Windows VM 的实际 .NET/PInvoke 运行中通过，报告 `build/godot-bindings-capability-csharp-windows/node-csharp/verification.json`，1000 帧/15 截图；首轮欠载失败另存，未据后续通过称为修复。

### 最新验证与已知失败

macOS 优化组合 108,000 额外帧测试已通过：实际 1,179.85 秒（约 19.7 分钟）、108,720 总帧、360 个耐久采样、1,107 组别名条码检查，动画/暂停/生命周期及完整退出通过，GPU 错误/PCM 欠载为 0、pending=0。报告 `build/godot-runtime/release-optimized-soak-108000/verification.json`。实际时长不足 30 分钟，不能据目标帧数标记 CI-01 完成。

前轮资源观察已结束：同目录 resources.json 记录中途开始的 882.73 秒/88 次 RSS/CPU 采样，RSS 约 63.6～165.0 MiB；不含启动基线、不测显存、不自动判定泄漏。

严格续验已通过：`build/godot-runtime/release-optimized-soak-216000/verification.json` 的实际 runtime_seconds=2301.85（38.36 分钟），超过强制 1800 秒门槛；216720 总帧、720 个耐久采样、2187 组别名条码检查，双生命周期、动画/暂停/输入/控制器与退出排空全部通过，GPU 错误/PCM 欠载/pending=0。host/runtime 前后哈希一致，最后截图已人工抽查。资源采集从启动初期附加，同目录 resources.json 记录 2305.60 秒/230 个采样，RSS 约 64.8～247.3 MiB；观察到进程正常结束。RSS 不含完整 GPU 分配，也不等于内存/显存泄漏验收通过。

Windows 后续恢复并完成新能力查询：系统命令、当前用户 Jin 和共享源码访问已恢复，未再次重启。`build/godot-bindings-capability-csharp-windows/node-csharp/verification.json` 已通过真实 x64 .NET/PInvoke 1000 帧/15 截图，两个生命周期均执行 unsupported_reason_empty 查询；包含 resize/cancel、别名、竞争节点拒绝、输入、两个 250ms 渲染停顿和退出排空，GPU 错误/PCM 欠载/pending=0。此入口不注入控制器事件，控制器证据仍见既有 Windows 原生报告。原生 DLL SHA256 `7d1c6edc52779e075e50e5cb8f4e9902d9781eb5eb5cbf1e03ddf77049305cc7`，运行库 `c13761f608e82fcf08fc3c94bda4cac9b67fa074916dff20eb3c450ce5ce08f7`，fixture `511f8c5d6e0db9a07a3de696dd032bbf672f5f4fb6f1e71721d339424afebbb4`；执行前后哈希一致，三份产物均已导出或映射到宿主并复核，见 export-verification.json。Windows Debug DLL 重建 25.453 秒，使用 Python312/Pillow11.1，实际子进程退出 0。

Windows 本轮失败仍保留：旧格式包被 v1 校验拒绝的 staging 失败见 godot-bindings-capability-csharp-windows-stale-package-failure/。后续首轮确实执行了查询及15截图，但 Python314 缺图像库，且第二生命周期记录512帧欠载；宿主离线严格校验同样拒绝。证据见 godot-bindings-capability-csharp-windows-py314-underrun-failure/、`build/godot-runtime/windows-capability-offline-verifier.log`。该轮与 Mac 编译并发，后续单独复测通过；原因未确认，不计音频问题已修复。helper 已加入精确任务标记、显式 --package、图像库预检，以及导出时清除本轮不存在的旧结果标记。此前 Tools 更新/启动异常与脚本路径失败见 PLAN.md 历史。

Firefox 旧异步 PCM 欠载已由 Web 同线程按需混音修复，旧失败报告仍保留。WebKit 早期超时源于 fixture manifest 漂移，现已隔离测试包并校验入口；不能将旧超时解释为运行时不兼容。首轮 Release/Rust 退出超时记录仍保留，修正后的新报告通过，不覆盖旧失败。

前版候选 v3：`build/godot-runtime/godot-candidate-v3.patch`、godot-candidate-v3-manifest.json，287文件/1305534字节，tree `4efbad2551a90b73661421e63a97581c682dd227`，补丁SHA256 `39bd8a37eb8190718d0551c4af6d9ba80ab0f77e98e4860b0a2315212ba3f0a2`。新增初始化清理修复、测试注入/回归、CI与记录；相对v2的Source差异仅GodotNode.cpp和Sprite.cpp，与隔离macOS中实际使用的文件一致。临时索引应用/树检查通过，真实索引不变，仍排除15个无关文件及共享接口中的缓存诊断改动。Linux验证来自既有工作快照，未称为v3候选的全新独立构建；新版Linux本地整套CI已通过（见CI-01）；最新源码尚需刷新候选、审查与远程执行，未创建提交/分支或推送。

最新候选 v4 已生成：`build/godot-runtime/godot-candidate-v4.patch`、godot-candidate-v4-manifest.json，288文件/1314875字节，tree `dc1b8a5c9102d12eb85236d2a494f1aeb61b8305`，补丁SHA256 `9b8ed66b9ab7c1714c4cddcf6074ccc98565b6bb95bf068f4f02ea37bf6bc76f`。相对v3纳入有界着色器封装、四格式检查、Web默认入口及文档；Source差异仅BgfxEmbeddedShaders.hpp。临时索引应用后树一致，真实索引不变，保留原候选共享接口与3个仅行尾差异的C#文件，继续排除15个无关文件。从候选tree导出的CPU协议和四格式测试通过，见 candidate-v4-protocol-results/；40个候选Source路径与既有隔离macOS源码逐字节一致。以上不等于v4完整跨平台重建/GPU验收；macOS后续回归与Linux运行状态见下文，审查与远程CI待做。候选内文档是生成时快照，本文后续新增的v4/导出验收状态以工作区当前文档为准，无提交/分支/推送。

v4 macOS 续验已通过：隔离源码10728个Git原始blob在构建前后逐项匹配tree，报告 `build/godot-runtime/candidate-v4-macos-source-audit.json`。测试宿主缓存构建1.747秒（不是全新编译）；`candidate-v4-native-matrix.json` 的2/3/4组合共3000帧/45截图，包含resize/cancel、别名、竞争节点拒绝、音频停顿与控制器，GPU错误/PCM欠载/pending=0，退出0。宿主SHA仍为2aa0231e...，Release LibGodot仍为2e3f2ea6...，均未重新编译运行库。普通宿主缓存构建6.716秒，SHA256 `94e0afbcea2fedd04a26721f0bbd95d886422652b7a727c67b0432aec156e7d6`，无测试入口/着色器故障钩子；`candidate-v4-ordinary-macos/verification.json` 随包/缺库各2截图、11.153/6.380秒通过。一次从主cwd误启动的构建主动终止143并恢复主project缓存，保留candidate-v4-native-wrong-directory.log与wrong-directory.json，不计为验收。

v4 Linux 全流程现已通过：bootstrap PID72659、worker72666和宿主观察session89158均正常结束、退出0，报告为 `/tmp/dora-godot-ci-20261029/repo/build/godot-runtime/ci-linux-candidate-v4/verification.json`；必须查询进程/最终退出状态，不能按静态progress文件判定仍运行或成功。完整Git archive SHA256 `9a014676389ea8b279f65a1c0291e71bd3c37be39e6509f71c5d5670267385e0`，109477568字节。10728个归档项已逐项同步核对，包含两处Android符号链接；123项与原始Git blob的差异仅是.gitattributes指定的CRLF/LF，代码内容一致。证据candidate-v4-linux-{source-sync,transfer-audit}.json。首次同步helper拒绝符号链接，在CI启动前失败，记录transfer-staging-failure.json保留；已修正并核对完整归档后启动，不是重启超时CI。源传输服务已关闭。该CI冻结v4，不包含随后新增的三语言构造错误测试；尚无远程GitHub run ID。最终聚合捕获于 `build/godot-linux-ci-local/candidate-v4-aggregate.json`：769.98秒，build_skipped=false（复用编译缓存，不是全新全量构建）；测试宿主缓存构建53.309秒，普通宿主17.647秒。测试宿主SHA256 `51ff851eff3d8f487746736493b4e876b04863d04d5570a728bf86e8ee1d5d1b`，普通宿主 `541089e0a32bfdce494647ab37ab0f4122714d96e974844ef988c25a1b795110`，运行库仍为6997eb3c...。完整证据已导出 `build/godot-linux-ci-local/ci-candidate-v4-export/`：归档SHA256 `98294cc99868c28c45961660f70a8caf0ae6aaecea692778875731c1e55cfa87`，117606985字节，606文件逐项哈希通过、三个实际产物映射通过；369张独立原生截图，冻结严格verifier离线复验2/3/4矩阵、恢复阶段及100轮通过，见export-verification.json。资产树明确排除，恢复阶段副本不重复计数。导出服务PID76537已停止，无新增原生运行。

最新审查候选为v5：`build/godot-runtime/godot-candidate-v5.patch` 与 godot-candidate-v5-manifest.json；在v4基础上加入三语言构造拒绝/恢复测试、共同的严格错误过滤器及本轮文档，核心Source不变。候选树/补丁哈希和范围以manifest为准，继续排除无关Cache/3D改动并保持真实索引。现有本地报告仍按实际执行的宿主/fixture与平台记录；源代码候选不能替代物理硬件、远程CI或正式分发验收。远程推进后的状态将另行同步，历史条目的“未提交/未推送”仅描述当时状态。

## 已完成的集成能力

- 固定 Godot 4.6 源码、版本化 C ABI、原生符号隔离。
- 项目目录/PCK 加载，保留 SceneTree、主场景与 autoload 语义。
- Metal、EGL、WGL、WebGL2 GPU 纹理共享；2/3/4 缓冲、有界所有权、同步与完成记账。
- 动画、暂停/恢复、重启、移除后重建、异步 resize、保留纹理别名。
- 指针、键盘、文本、触摸和标准控制器事件基础桥接；宿主音频混合。
- Lua/Teal/TypeScript 与 C#/Rust/Wa 绑定及生成入口；各语言/平台验收范围见 BIND-01。
- 可选运行库包清单、来源/版本/文件/许可证哈希校验，macOS Release 构建和短回归。

## 待办任务

状态：TODO / 进行中 / 等待外部环境 / 完成。完成仅限明确列出的验收范围。

### P0：兼容边界与发布前闭环

- [x] **IOS-01｜完成（模拟器范围）：Dora Apple2 / Godot Apple4 解耦。** 入口、能力查询、安全拒绝、普通 Dora 180 帧/2 截图通过。真机与正式包分别归 IOS-02、DIST-01。
- [ ] **IOS-02｜等待外部环境：Apple4+ iOS 真机。** 准备已连接、开发者模式开启且可签名的 iPhone/iPad，执行共享纹理、2/3/4 缓冲、动画、resize、前后台、触摸、音频与清理。当前模拟器结果不替代本项。
- [ ] **PKG-01｜进行中：可选依赖与发布打包。** 统一 v1 清单与只读 verify_package.py 已接入，11 项正反例通过；macOS/Web/Linux/Windows/Android/iOS 现有实包完整性通过。macOS Release 已构建并运行；其他平台 Release、最终签名/安装、缺库退化、包体积、可复现构建和第三方许可完整性审计待做。哈希清单通过不等于 ABI、签名或运行通过。
- [ ] **WEB-01｜进行中：音频完整验收。** Firefox 已复现欠载修复，三浏览器 2/3/4 缓冲与短输出探针通过；待长时间/复杂混音压力、实际设备输出连续性与端到端延迟测量。
- [ ] **WEB-02｜进行中：真实浏览器覆盖。** Playwright WebKit 矩阵通过；待 macOS Safari、iOS Safari、Android Chrome 真机，以及真实后台页策略和发布环境验证。

WEB-02 当前推进：已确认本机 Safari 26.6.2（21624.5.1.11.3），原生 SafariDriver 创建会话时明确要求开启“允许远程自动化”；预检记录 `build/godot-web/safari-native-preflight/session.json`。尚未修改该设置，已请求所需权限确认，不能计为 Safari GPU 不兼容或运行通过。已新增 `tests/web/run_safari.py` 原生入口，公共 `acceptance_init.js` 已在 Chrome/Firefox/Playwright WebKit 三缓冲各完成 620 步、12 张截图/110 像素检查，GPU/PCM 排空通过；报告 `build/godot-web/{chrome,firefox,webkit}-shared-init-3/verification.json`。Safari 入口自身尚未端到端运行。

包校验证据：`build/godot-runtime/package-integrity.json`、`build/godot-runtime/release/package-integrity.json`、`build/godot-{web,linux,windows}/package-integrity.json`、`build/godot-android/package-integrity-notices.json`、`build/godot-ios/{simulator,device}/package-integrity.json`。Linux/Windows 等现有包重新封装不代表其运行库已重新编译；iOS 本地 ad-hoc 签名不等于真机分发签名。

PKG-01 Android 早期失败记录：template_release / optimize=speed 运行库与 -O2/-DNDEBUG 宿主、R8 测试 APK 均已构建，日志位于 `build/godot-android/release/arm64/`；库 SHA256 `eb53c136ba402d4f6bc54642520e32ee09bff14ecd77fe199a21ec90dac2d40c`，7 文件/134939768 字节包完整性通过。实际 API35 模拟器首轮因 R8 移除 JNI 查找的私有 Godot.restart() 而崩溃；已为可选 Godot Java 包添加定向 keep 规则，保留全局 R8。修正 APK 可启动并完成测试流程、Home/恢复和 IME 提交，但该轮严格音频校验出现 3072/512 帧欠载，未通过完整验收。首轮 APK/映射/日志保留于 `build/godot-runtime/android-release-controller-3/`，修正轮证据于 `android-release-controller-3-jni-keep/`；后续硬件转换后端矩阵已通过，见下文，软件负载欠载仍归 AUDIO-01 追查。

Android Release 宿主的生成编译命令已确认 -O2/-DNDEBUG，记录于同目录 host-configuration.json。为采集模拟器内报告，专用 godotprototype 测试 APK 的 Release 变体启用 debuggable 和开发调试签名；普通发布包不启用此分支。后续验收须注明“优化代码的可调试测试 APK”，不作为最终分发包/生产签名通过。

Android 续验结果：新增测试专用、预分配的 PCM 请求大小/间隔/欠载事件诊断；日志在回调停止后输出，未改变队列或放宽门槛。诊断版在 SwiftShader 环境完整通过一次（`build/godot-runtime/android-release-audio-diagnostics-3/verification.json`），未复现旧欠载，不能称为音频修复。查明现有 AVD 配置 hw.gpu.enabled=no；保留配置文件，以 `-gpu host -no-snapshot-load -no-snapshot-save` 重启任务模拟器后，实际后端确认为 Apple M1 Pro / Metal。

同一优化 APK 在硬件转换后端的 2/3/4 缓冲组合验收已通过：`build/godot-runtime/android-release-ime-window-matrix/verification.json`，3000 帧/45 截图，含双生命周期、resize/cancel、纹理别名、竞争节点拒绝、控制器、两个 250ms 渲染停顿、系统 IME 提交、同进程 Home/恢复和清理；GPU 错误/PCM 欠载/pending=0。此前四缓冲 IME 注入撞上用例主动失焦，留下 DoraE42；测试现增加稳定焦点窗口与外部成功确认，Godot 动画/音频持续，仍要求完整 DoraIME42。新矩阵 APK SHA256 `c9b54f7b68e802a02e4ad1807c1e06bc7be5e085397a36fd5840a9b491d8646b`。旧失败日志及完成后的原生产物均保留，不覆盖。上述是模拟器/开发签名证据，不代表真机或生产发布；软件负载下欠载原因仍未确认。

PKG-01 默认 Web 入口已修正：`Projects/Web/runtime-assets/init.lua` 改为读取并返回既有 Director.entry。当前源码重建的普通 core Player（不带 Godot）已在 Chrome 启动/停止通过：`build/godot-web/default-bootstrap-current-chrome/execution.json`；加入根节点身份断言的入口探针在 Chrome/Firefox/Playwright WebKit 均通过，见 `build/godot-web/default-bootstrap-probe-fixed-{chrome,firefox,webkit}/execution.json`。普通入口烟测无截图，不算 Godot GPU 矩阵或正式发布验收。旧赋值在原生 Debug 日志中确实报只读错误，但 Web 的 TOLUA_RELEASE 路径不安装只读报错 setter，旧脚本普通浏览器烟测也通过；旧探针失败的是新增的返回值断言，不能据此声称复现浏览器只读赋值崩溃。还需补独立执行标记与最终发布包验收。

### P1：稳定性与真实设备

CI 接入现状：已实现 `.github/workflows/godot.yml` 与 `Tools/Godot/tests/ci_linux.py`，工作流定义 Linux/macOS 协议和包校验，以及 Linux 的运行库/测试宿主构建、无效着色器的退出/恢复、EGL 2/3/4 矩阵、100 轮循环、普通宿主构建和普通应用用例。新版本地 Linux 全流程（含新增失败退出/恢复阶段）已通过；远程执行未完成。macOS 协议报告 `build/godot-runtime/ci-protocol-macos/verification.json`、11 项包校验及 actionlint 均通过；公共循环校验器的旧报告离线复核见 cycles-common-verifier-audit.json，不作为新增原生运行。

前版整合入口报告：`build/godot-linux-ci-local/ci-linux-ordinary-integrated/verification.json`，默认构建分支 build_skipped=false，699.63 秒，包含编译缓存复用，**不表示重新全量编译**。2/3/4 矩阵共 3000 帧/45 截图、100 轮/300 截图，以及 ordinary_reports 中普通项目恢复 5 截图、随包/缺库两项 4 截图全部通过，共 354 张原生截图（不含资产图片）。测试宿主/普通宿主/运行库三个 SHA 与前轮导出一致，普通构建未覆盖测试产物。测试宿主构建日志 19.96 秒，普通宿主另行构建；全流程正常退出 0。归档与映射见 ci-integrated-export-verification.json，临时导出服务已关闭。此报告来自 Ubuntu ARM64 VM / Mesa llvmpipe，本轮没有 GitHub run ID。

最新本地整合入口：`build/godot-linux-ci-local/ci-linux-lifetime-integrated/verification.json`，退出码 0、740.07 秒，build_skipped=false（复用编译缓存，不是全新全量构建）。包括无效着色器退出与同进程恢复、2/3/4 缓冲各1000帧、100轮循环、普通项目边界及随包/缺库用例。环境仍为 Ubuntu ARM64 VM / Mesa llvmpipe，GitHub run ID 为空。原始证据现已完整导出至 `build/godot-linux-ci-local/ci-lifetime-integrated-export/`，归档 SHA256 `70e86f3b201b123d4aadd53b351ba0a3dbdc678533e48d101bc65b5eeade91e3`，171951618字节；3134个归档文件逐项哈希通过，三个运行产物与聚合报告匹配。369张独立原生截图（不重复计恢复阶段副本）已核对；冻结的严格校验器离线重验2/3/4矩阵、恢复1000帧及100轮通过，见 export-verification.json。这是证据导出/离线复核，不是再次原生运行；普通宿主验收引用冻结的原生报告及文件完整性。归档实际保留普通用例的小写assets树，排除test-assets/Assets和重复宿主/运行库；上游导出元数据的excluded文字较实际过滤范围宽，已在复核报告明确纠正。聚合报告早先单独捕获的capture-scope.json保留其历史范围。两个传输服务均已停止。这轮使用 v3 阶段源码，未覆盖随后新增的有界 string_view 封装及四格式 CPU 检查。

最新源码兼容修正：Web 生成的字节列表末尾可带逗号，v3 的显式追加逗号/零方案在该格式下编译失败。现改为数组加有界 std::string_view，按实际长度去掉可选末尾零，避免依赖终止字符。`build/godot-runtime/embedded-length-view-four-formats/embedded-shader.json` 的带/不带末尾零 × 带/不带末尾逗号四项均通过；旧编译失败日志 embedded-trailing-comma-before.log 保留。macOS 隔离测试宿主重建后恢复回归通过（20.50秒、1000帧/15截图、GPU错误/PCM欠载/pending=0），见 embedded-view-native-recover/verification.json；宿主 SHA256 `2aa0231ec73f6beb77741204cc844b1f56a9e387d2ddac6f8efda599ca3f54a2`，Release LibGodot 未重编。当前普通 Web host 也已重建并通过上述启动烟测；最新改动已纳入v4候选，仍不称为该候选的完整跨平台回归。

远程 CI 候选准备：已只读盘点 66 个已跟踪改动文件及 232 个未跟踪文件，识别 5 个公共接口文件中的 Godot/缓存诊断独立片段；在临时 Git 索引生成可应用到 HEAD 的 `build/godot-runtime/godot-candidate.patch`（283 文件，排除 15 个缓存诊断/3D 文档文件），保留原工作区与真实索引。清单 godot-candidate-manifest.json 记录基线、候选 tree 和补丁 SHA；这只是候选，依赖改动仍需人工审查及完整原生构建。候选 C# 绑定/fixture 编译通过（candidate-csharp-compilation/compilation.json，runtime_tested=false），候选公共协议通过（candidate-protocol-v2/verification.json，GPU未测）。初次协议材料导出遗漏 module/runtime_timing.h，在启动编译时失败；补齐同一候选树的模块目录后通过，保留 staging-failure.log。尚未创建提交、发布分支或执行远程 CI。

候选原生构建：已从 tree `3c2323da4bb26bfe70e45e739d78368ce6e7b30b` 导出完整源码到 `build/godot-runtime/candidate-native-source/`，归档 SHA256 `bd6191fdc8aa028d4ba93c6f66209a37633f1e78b9c330ac74039b7bac57cf4c`，没有复制主工作区对象或生成绑定。8 个缓存/共享接口文件一致性检查通过（C# 按属性规范化 CRLF），见 candidate-source-scope-check.json。首次登录 Shell 误返回主仓库，确认 cwd 后主动终止，退出 143；candidate-native-wrong-directory.json 保留，不计候选验证。主仓库默认 xmake 配置被设为 macosx/arm64/release/ccache=false，专用 release-host-config 未改。改用非登录 Shell 和显式项目路径后，独立 Release 构建实际通过，用时 605.578 秒，候选自行生成的 Lua 绑定保留基线缓存 API 并包含 Godot 查询。

干净生成暴露的新失败已修复：首轮二缓冲启动因着色器源码混入相邻内存而构造失败，退出 SIGSEGV，记录 candidate-native-node-2/、candidate-native-matrix-failure.json。新生成的 bin2c 数组不带零终止，而旧工作区生成头恰好带零，掩盖了封装按 C 字符串读取的越界。已在 BgfxEmbeddedShaders.hpp 显式追加终止字符；精确数组复制到受保护分配后，ASan 复现越界，修复后检查通过，见 candidate-embedded-shader-{reproduction,fix}.json。当时新增 embedded_shader.py 用两种生成格式编译实际封装，检查有界终止与原源码完整一致，已接入 protocol.sh 和 CI 归档。原静态全局数组 ASan 探针未诊断，但读取长度超出数组；不将该探针说成 ASan 成功捕获。

修正后的隔离宿主重建 5.851 秒，已实际通过 2/3/4 缓冲矩阵：`build/godot-runtime/candidate-native-shader-fixed-matrix.json`，共 3000 帧/45 截图，动画、输入/控制器、resize、别名、两次生命周期与退出排空通过，GPU 错误/PCM 欠载/pending=0。宿主 SHA256 `2ee58dd5f3d2293e10283f6c493c09159488b0b0267632dee15863e8e2c7fb48`，复用的 Release LibGodot SHA256 `2e3f2ea69d9e7272b4aa8c5e0944b2fc0906a6f735ce0e0d52d1ec9422a1746d`，前后未变；运行库未重编。证据对应原候选树加显式着色器封装修复，尚需刷新候选补丁并审查；不是旧 tree 原样通过。新增 CPU 检查在主工作区及隔离源码均通过，报告 protocol-embedded-shader-fix/、candidate-protocol-shader-fixed/；actionlint 与脚本语法通过。构建与矩阵进程已终止，candidate-native-progress.json 已更新，不再等待旧句柄。

候选刷新已完成：`build/godot-runtime/godot-candidate-v2.patch` 与 godot-candidate-v2-manifest.json，285 文件/1281957 字节，补丁 SHA256 `95e2fc5c617b9bba2e802031e5b1e7e3eca0847b7321ce52600054839f6e768d`，tree `ebd6da88eba7b8298d3af0a7f0b9c73e5db51984`。在另一个临时索引应用到基线并 write-tree 一致，真实索引哈希不变，仍排除15个无关文件；相对原候选，Source/ 下唯一新增差异就是本次已通过 GPU 回归的封装修复，5个共享接口与原隔离候选逐字节一致。测试/文档/工作流另行刷新。Windows C# 执行来自主工作区同步的独立访客目录，未冒称该候选已完成 Windows 独立构建。下一步审查 v2、推进远程 CI；仍未创建提交/分支或发布远程。

Linux 初版 CI 入口本地完整构建与 2/3/4 矩阵已通过，报告已导出 `build/godot-linux-ci-local/ci-linux/verification.json`：build_skipped=false，整体耗时 1422.40 秒，3000 帧/45 截图，含输入/控制器、暂停/重启、resize/cancel、保留纹理别名、竞争节点拒绝、音频及两个 250ms 渲染停顿，GPU 错误/PCM 欠载/pending=0。实际渲染器为 Mesa llvmpipe / OpenGL ES 3.2，属于软件 EGL 接口执行，非物理 GPU 验收。独立访客目录 `/tmp/dora-godot-ci-20261029/repo`，原生构建快照 SHA256 `af40011281d4469fc84befb4d4860f6473b4f0c3a7b547f86a4003758a3042ec`；Godot 构建 12 分 30.33 秒，Dora 构建 552.30 秒。对应宿主已保存在 `build/godot-linux-ci-local/Dora-test-host`，SHA256 `913fcbcb58830a41199fb08fe4b2e25c003df41a81dffa71af71ec95e141fa1e`；运行库保存在该目录 package/，SHA256 `6997eb3c3a65c0178c7ab41bffce662764422ecd02292ed7c4774cfc76d82fa2`，包完整性检查通过。远程 GitHub CI 尚未执行。

100 轮扩展首轮未通过：第 3 轮移除后，GDB 实际定位主渲染线程等待 `bgfx::getStats()` 资源锁，逻辑/API 线程同时在持锁的 `bgfx::frame()` 等待渲染完成，属于测试采样线程错误。诊断后主动 SIGTERM 结束，退出码 143，不算正常退出或耐久通过。失败报告/截图/线程栈/修正前代码已导出到 `build/godot-linux-ci-local/{ci-linux-with-cycles,cycle3-backtrace.txt,GodotCycleTest-before-fix.inc}`。已将 bgfx 资源统计读取和标量复制移到逻辑/API 线程，渲染回调仅查询 Metal 分配量并发布采样；不修改图形共享协议或放宽校验。

修正后 macOS 100 轮已完整复验通过：`build/godot-runtime/cycles-api-thread-macos-100/verification.json`，新宿主构建 9.21 秒，运行 186.69 秒、300 截图、最小动画变化 3447 像素，100 次场景启动及 GPU/PCM 排空通过。bgfx 资源计数稳定，Metal 分配量仍为 149520384 字节、峰值增长 0（门槛 0）；这是新采样实现的实际运行证据，旧报告继续保留。

Linux 修正后的聚合入口也已完整通过并导出：`build/godot-linux-ci-local/ci-linux-fixed-cycles/verification.json`。宿主单独重编译 23.98 秒；聚合测试复用该产物（build_skipped=true），624.62 秒包含协议、包检查、2/3/4 矩阵及 100 轮循环。循环子报告 `cycles-100/verification.json`：100 次真实场景启动、300 截图、最小动画变化 20559 像素，每轮 GPU/PCM 排空，资源计数稳定（纹理 1、程序 13、着色器 16、帧缓冲 0，bgfx 估计纹理字节 49152）。未测 Metal 或完整驱动显存。新测试宿主已保存为 `build/godot-linux-ci-local/Dora-fixed-test-host`，SHA256 `09b997b88360d627b4e0034504da850bbdd86f5870b907d67577a35eb16e4390`，运行库 SHA 保持不变。完整构建与扩展测试两份报告共同说明本地验证范围，不能把复用产物的这一轮说成再次完整构建。

Linux 资源采样也已结束，按 /proc 可执行路径和启动计数核实目标身份：`build/godot-linux-ci-local/linux-cycle-resources/resources.json`，387.39 秒/193 次采样，观察到进程退出，RSS 约 457～573 MiB；从循环中途附加，不含启动基线、实际 GPU 显存或泄漏判定。导出后再次核对原生二进制与清单哈希、300 张循环图像和普通宿主边界图像，见 export-final-verification.json、post-export-audit.json；这是离线复核，不是额外原生运行。临时文件服务已关闭。远程 GitHub CI 仍未执行，其他平台循环/长期资源与其他项目仍待做，CI-01 整项未完成。

- [ ] **CI-01｜进行中：自动回归与耐久。** macOS 38.36 分钟、macOS/Linux 各 100 轮、本地 Linux CI 含普通宿主整合全流程通过；隔离候选 macOS 构建与修复后矩阵通过，v3补丁已刷新，新增失败退出/恢复已纳入本地整套流程并通过，最新封装修正尚需刷新候选与重验，证据与失败见上文。远程 CI 未执行。仍需候选审查、其他项目/更长期 CPU/GPU 内存观察、其余平台循环/长运行与远程报告归档，不能据此勾选整项完成。
- [ ] **HW-01｜等待外部环境：物理硬件矩阵。** Android 手机/平板、物理 Windows x64 GPU、原生 Linux x86_64 Intel/AMD/NVIDIA、真实手柄。
- [ ] **REC-01｜TODO：图形设备丢失恢复。** 桌面/Android 强制 device/context loss，评估 Web 原地恢复方案和失败降级。
- [ ] **INPUT-01｜TODO：完整输入与移动生命周期。** IME composition/候选窗口、移动原生文本、旋转、多点触控、锁屏/来电与真实前后台。
- [ ] **CTRL-01｜TODO：物理控制器。** 枚举、热插拔、震动、多手柄与失焦释放。注入事件不代表物理设备通过。
- [ ] **AUDIO-01｜进行中：音频平台矩阵。** Android 硬件转换后端 Release 2/3/4 矩阵严格零欠载通过；SwiftShader 首轮 3072/512 欠载仍需解释，新增诊断版未复现，不据此称为修复。Windows C# 本轮也记录一次512帧欠载，单独复测零欠载通过，原因未确认；保留失败并继续追查。继续移动真机、长时间/复杂负载及端到端延迟，评估 AudioWorklet 替换 Web ScriptProcessor。

### P2：覆盖面与维护

- [ ] **BIND-01｜进行中：绑定与 API 文档。** 新能力查询六类接口已有，Rust/Wa 实际运行通过，C# 新查询已在 Windows VM 通过实际 .NET/PInvoke 双生命周期、1000帧/15截图；见上文报告及哈希。整项仍需补其他平台、错误面与公开 API 一致性，不因单个子项通过而勾选完成。

BIND-01 新增构造拒绝与恢复：`build/godot-bindings-constructor-rejections/node-{rust,wa}/verification.json` 均通过真实Wasm3生成绑定，零宽、零高、宽8193、缓冲1/5、缺失项目在每次生命周期返回None/nil；每种语言共12次拒绝，随后仍完成双生命周期1000帧/15截图和完整resize/cancel、别名、音频/stall、竞争节点测试，GPU错误/PCM欠载/pending=0。使用上述隔离macOS测试宿主及既有Release运行库，原始run.log保留12条预期错误；recovered/仅排除精确匹配的10+2条错误，严格verifier未改。额外插入非预期错误的离线反向检查被正确拒绝，且无残留成功报告：godot-bindings-constructor-rejections-negative-control/negative-control.json。这轮原始报告只覆盖Rust/Wa；C#后续同组验收见下文。三语言尚未覆盖缺库/异步错误；新增测试尚未纳入v4候选。

- [ ] **PROJECT-01｜TODO：项目覆盖。** 大型导入资源、复杂 2D/3D、插件/GDExtension、更多 PCK/导出形式、长时间资源加载。
- [ ] **RUNTIME-01｜进行中：运行时与项目边界。** 当前单运行时/单活动节点，节点移除不卸载运行库；进程内不能切换到不同项目，最终 shutdown 后不承诺重新初始化。GL 重建还要求缓冲数一致，内部目标模式需尺寸一致。新增普通 macOS Release 宿主实际回归：A 动画 → 关闭 → B 明确拒绝 → A 重新创建并动画，GPU 工作全部排空。最终报告 `build/godot-runtime/project-boundary-macos-v2/verification.json`，验收耗时 13.77 秒/5 截图，两次动画变化 3142/3084 像素，只有两次真实场景启动，失败节点未产生 GPU 工作，包含截图与执行产物哈希；首轮报告仍保留于 project-boundary-macos。尚需 GL/移动/Web 对应错误恢复回归，并明确后续多项目隔离与卸载方案；不计为多项目支持。

RUNTIME-01 后续验证：公共校验器 `verify_project_boundary.py` 已在 macOS/Linux 实际入口通过。macOS `build/godot-runtime/project-boundary-common-macos/verification.json`：5 截图、动画变化 3200/3078 像素，两个有效客户端 produced/completed=100/100、101/101，失败客户端 readers=0，全部 pending/errors=0。Linux 在修正 CI 成功且产物哈希匹配后独立构建普通 Debug 宿主（23.02 秒），保留测试宿主字节不变；随后正常退出通过 `build/godot-linux-ci-local/ordinary-linux-project-boundary/verification.json`，12.28 秒/5 截图，动画变化 12920/12880 像素，两个有效客户端 produced/completed=64/64、125/125，读者各 107/107，pending/errors=0。默认按测试资产根目录加载随包库。GL 失败客户端不输出 readers 报告，公共校验器明确区分，不套用 Metal 的零值记录。仍需移动/Web 错误恢复及后续隔离/卸载方案。

RUNTIME-01 初始化失败路径已在 macOS/Linux 验证修复：独立注入无入口着色器，真实编译器拒绝后，原实现再次以 SIGSEGV 退出；正常节点在首帧前立即退出也复现。系统 crash.ips 指向 bgfx::Context::destroyUniform → 无效 Context 的 mutex，且日志显示 SpriteRenderer 晚于 BGFXDora 销毁。根因是 SpriteRenderer 构造创建 GPU effect，而其依赖的 RendererManager 直到首次绘制才实例化/注册生命周期。现于 SpriteRenderer 构造时显式建立该依赖，普通产物同样生效；故障注入仅在专用测试宿主编译，普通 Release 的静态检查已确认无测试入口和注入字符串。

新增 run_init_failure.py 覆盖 exit / recover 两种模式：前者在无有效节点绘制时正常退出，检查 SpriteRenderer 在 bgfx 之前释放、无泄漏；后者在同一进程撤销注入后执行完整 1000 帧/15截图、输入/控制器、resize/cancel、别名、竞争节点、两个250ms停顿、音频与清理。原始日志不改写，仅将明确标记的预期故障区间单独验证，恢复阶段沿用原严格校验器，GPU错误/PCM欠载/pending=0。macOS 最新报告 `build/godot-runtime/init-lifetime-final-macos-{exit,recover}/verification.json`（1.002/19.957秒，测试宿主SHA256 `44229adcbbbd6fbe6fd59b34a72f610e3334c4f9c944ad0fed7d7532e5fa15a7`）；此前复现与初次通过保留在 init-shader-{failure-before,invalid-before,fixed-exit,fixed-recover}/。LLDB诊断启动未在60秒内推进，遗留debugserver已关闭；结论依据真实系统崩溃报告和独立前后运行，不据调试器超时推断程序状态。

Linux 最终严格复验：`build/godot-linux-ci-local/init-lifetime-final/init-lifetime-final-linux-{exit,recover}/verification.json`，分别0.437/32.641秒，退出0，恢复1000帧/15截图，GPU错误/PCM欠载/pending=0，销毁顺序正确。宿主SHA256 `ace5380025101da0e0312ebfae7847918a3268afbffa8757b466fb2cc2d69fdd`（前轮重建40.661秒，含编译缓存，本轮复用），运行库 `6997eb3c3a65c0178c7ab41bffce662764422ecd02292ed7c4774cfc76d82fa2` 未重编。export-verification.json 核对原日志、实际产物、冻结的runner/verifier、资产清单哈希与0/15截图；归档SHA256 `12ee9a8f1c4aefe0e0e9e25f5b9ac8f5e4ca50e3d231d72f770210b7d323a076`。旧目录 init-lifetime/protocol-init-lifetime/ 的公共协议与生成边界检查也通过。服务与测试进程均已结束。

首轮 Linux 两项虽然通过GPU阶段，但严格诊断复核发现额外的 Director 只读属性赋值错误；旧目录 init-lifetime/ 下的整体验收报告已标记 passed=false，原报告备份为 verification-before-strict-audit.json，不再计为完整通过。新测试遗漏资产目录，使仓库根被当作资产树并递归加载 Projects/Web/runtime-assets/init.lua。最终入口改用独立复制的测试资产、显式 --asset 和中性 init.lua，原资产不改写；记录完整清单，并要求全日志只有预期的编译器/Lua两条错误，未放宽检查。两个平台的新报告使用同一runner SHA256 `40d7376de2d2dc517a308f58dc9a937614c09c92516a6a930612c65dfeef96b9`。Web生产入口后续修正与普通启动烟测见PKG-01；测试资产隔离本身不作为产品修复证据。

普通 macOS Release 也已复验：init-lifetime-ordinary-macos/verification.json 随包/缺库两项各2截图通过（12.857/6.481秒），普通宿主构建9.253秒，源产物SHA256 `6aabc32ac68f46a75fceacd65a6160d6953cd745ce60855fa93c6accd199d269`。init-lifetime-production-hook-check.json 确认无测试入口和故障注入字符串。新增失败两项已接入 ci_linux.py 的 init_failure_reports，GPU依赖修复也加入源码清单；新版Linux完整聚合CI后续已通过，见CI-01；Windows/移动/Web相同失败路径仍待执行，不将独立用例通过计为整套新CI完成。

BIND-01 C# 同组续验通过：`build/godot-bindings-constructor-rejections-csharp-windows/node-csharp/verification.json`，Windows11 ARM64 VM内实际x64 .NET/PInvoke/WGL执行，公开TryCreate的6类无效构造在两轮共返回null 12次；随后1000帧/15原生截图及resize/cancel、别名、竞争节点拒绝、音频/stall全部通过，GPU错误/PCM欠载/pending=0。流水线46.343秒（含编译、校验与运行，不是纯渲染时长）；仅重编C# fixture，复用宿主7d1c6edc...与LibGodot c13761f6...，不称为v4 Windows全源码构建。导出三个产物哈希映射、原始日志SHA、冻结校验器离线复核通过，见同目录export-verification.json；首次导出审计在校验已通过后枚举到__pycache__目录而失败，修正只枚举文件后生成报告，无原生重跑。

共享错误校验已收口到tests/bindings/constructor_rejections.py：Rust/Wa/C#均要求恰好10条参数错误和2条缺失项目错误，保留raw log，只生成单独的recovered输入；任何其他error/critical/warning拒绝。`build/godot-bindings-constructor-filter-audit/verification.json` 的8项离线检查通过（Rust/Wa既有原生截图正例，通用错误/Godot错误/warning反例各两种语言），不是新增GPU运行。此前三语言报告继续保留；异步错误、缺库、其他宿主和公开API一致性仍归BIND-01，未勾选整项完成。

- [ ] **PERF-01｜进行中：性能基线。** 已采集 macOS/Linux RSS/CPU、100 轮关闭后的 bgfx 资源计数/估计字节、macOS 同一 Metal device 当前分配量，以及 Android 回调请求/间隔；仍需生产者/消费者 GPU 时间、更完整内存/驱动观察、统一负载、分辨率/2/3/4 缓冲取舍及端到端音频延迟。当前资源稳定结果限本次场景与接口覆盖，不等于所有内存/显存泄漏验收。
- [ ] **DIST-01｜进行中：普通应用与分发。** macOS 普通 Release 宿主（无 Godot 测试入口）已通过随包运行库与缺库退化两项原生运行，共 4 截图：`build/godot-runtime/ordinary-macos-release-acceptance-v2/verification.json`。Linux 普通 Debug 宿主现也通过对应两项，共 4 截图：`build/godot-linux-ci-local/ordinary-linux-fallback-v2/verification.json`；按测试资产根目录默认加载 .so、相对路径 GodotProject 解析断言、Godot 动画/排空与 Dora 绿色图形运动通过，移除 .so 后明确报错、Godot 未启动，Dora 图形继续运动并正常退出。每项资产树附两份 Godot 许可到 GodotNotices/，原 Dora LICENSES 文件与源快照哈希一致。Linux 宿主 SHA256 `8f99f87db93ae14f6f6ed58d90490aef02ba6ac0a28871a42b035bab3d1bffa5`。首轮因误把 LICENSES 文件当目录在启动前失败，记录 ordinary-fallback-staging-failure.json 保留，不计运行失败或通过。上述分别为本地 ad-hoc macOS 副本与 Ubuntu VM / llvmpipe 测试资产，不代表正式分发；仍需其余平台普通宿主、Linux/其他平台 Release、安装/升级/卸载、最终签名和发布包验收。

## 下一步执行顺序

以下是后续工作的交接清单。既有通过报告保留；执行后将结果同步到相应任务编号，只有满足验收范围才勾选完成。

| 顺序 | 对应任务 | 下一项具体工作 | 完成判据 / 外部条件 |
| --- | --- | --- | --- |
| 1 | CI-01、RUNTIME-01 | 跟进PR #159远程CI，按失败日志修复并归档 | 前版Linux证据已导出复核；v4 macOS/Linux本地回归和导出复核均通过；三语言错误面已补，已有Godot远程run40772555311；待全部job终态和产物核验 |
| 2 | BIND-01 | 补绑定错误面、公开 API 一致性及其余平台覆盖 | Windows 新查询双生命周期已通过；继续核对各语言声明/生成结果与错误行为 |
| 3 | WEB-01/02、AUDIO-01 | 真实 Safari、复杂混音与长期音频；追查 Android 软件渲染欠载 | Safari 自动化设置等待已提出的权限确认；真实设备另需准备，旧欠载不能因未复现而关闭 |
| 4 | IOS-02、HW-01 | Apple4+ iOS 正向共享及其他物理硬件矩阵 | iOS 需开发者模式真机与有效签名；验证 2/3/4 缓冲、动画、前后台、触摸、音频及排空 |
| 5 | REC-01、INPUT-01、CTRL-01 | 设备丢失、完整输入法、移动生命周期和物理手柄 | 故障注入与实际设备报告；区分安全停止、重载恢复与原地恢复 |
| 6 | PKG-01、DIST-01、PROJECT-01、PERF-01 | 其余平台普通 Release 应用、安装分发、复杂项目及统一性能基线 | 随包/缺库退化、许可、签名及安装升级卸载通过；记录 CPU/GPU 时间和资源变化后评估发布条件 |

前次文档核对（本轮实现续验前）：已核实源码分别检查 Apple2 与 Apple4；macOS 38.36 分钟、修正采样后的 100 轮、Linux 整合入口和 iOS 普通 Dora 模拟器报告均存在且通过。该次只整理记录；本轮新增构建、修复及运行证据见上文，仍未执行远程 CI。

新增优先回归：浏览器输出探针现支持 `--audio-output-seconds`，fixture 支持 `--audio-hold-seconds`，让 Godot 动画持续运行而只延后控制器测试步骤。Chrome/Firefox/WebKit 的实际 60 秒输出窗口均通过（各 2880000 帧）；最长静音分别为 128/1/1 个采样，Chrome 的约 2.67ms 缺口并非“零静音”。Chrome 与 WebKit 的完整 620 步生命周期/110 像素检查通过，报告目录 `build/godot-web/chrome-audio-output-60s/`、`webkit-audio-output-60s-v2/`。Firefox `firefox-audio-output-60s-v2/` 仅输出窗口通过，完整 verifier 因末次 produced=2276/completed=2275 拒绝，不计整体通过。

Firefox 差异已修复：依据 [WebGL2 同步规范](https://registry.khronos.org/webgl/specs/latest/2.0/#3.7.14)，成功 glFinish 且无 GL 错误后记录队列完成，避免同任务内 fence 的缓存状态造成少记。仅 Web 分支变更，严格 verifier 未放宽。新版 WASM SHA256 `8098208471698e3b4e995fc7fd4e13853edbde57efc22a400985f46f8ac820e5` 已通过三浏览器 2/3/4 缓冲矩阵（5580 帧/108 截图/990 像素检查、GPU 错误/PCM 欠载 0、pending=0），报告 `build/godot-web/{chromium-drain-matrix-v2,firefox-drain-matrix,webkit-drain-matrix-v2}/verification.json`。Firefox 60 秒输出及完整生命周期回归也通过：`firefox-drain-audio-60s/verification.json` 和同目录 audio-output.json。新版 Chrome 三缓冲真实 context loss 安全停止及页面重载后 620 步恢复通过：`drain-context-loss-reload-3/verification.json`；仍非原地恢复。

并发矩阵首轮曾在浏览器启动前被 fixture 哈希检查拒绝，原因是相同缓冲数共用了准备目录；现按目标包路径隔离 staging，重跑通过。故障报告保留，不算运行时失败或通过。测试 CLI 同时改为拒绝未知选项，避免把普通回归误认为故障注入；错误的 `run_node.cjs --context-loss` 尝试已终止，实际恢复结果来自专用 web_context_loss.mjs。

## 当前不承诺的能力

Apple2 上运行 Godot Metal、GLES → Metal 跨 API 共享、Godot Mono/C# 项目运行时、Vulkan → bgfx Metal 直接共享、多个独立 Godot 运行时并行。Dora 的 C# GodotNode 绑定仅是宿主接口。

## 更新规则

- 构建、实际运行、真机和公开发布分别记录；虚拟机/模拟器/翻译层明确标注。
- 完成任务必须对应报告与源码/产物哈希；旧成功不能覆盖新失败。
- 报告仅在全部检查通过后生成；失败删除或标记旧成功报告。
- 每次工作结束更新本文件的当前状态、证据与下一步；逐轮过程追加到 PLAN.md，避免本文件变成重复日志。
