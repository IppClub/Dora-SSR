# GodotNode：共享 GPU 纹理集成实验

将固定版本 Godot 4.6 的项目离屏输出作为 Dora Sprite 使用。Metal 后端已验证 Apple Silicon macOS、同一个 MTLDevice 和单个活动节点。Linux ARM64 EGL 和 Windows WGL 后端也已通过真实 GPU 节点测试。LibGodot、Godot 场景树与渲染器实际运行在 Dora 进程内。

当前平台状态、产品决策和待办任务统一维护在 [`TRACKING.md`](TRACKING.md)。`PLAN.md` 保留详细实验过程，不作为当前任务状态的唯一依据。

iOS 兼容策略：普通 Dora 保持 Apple2 GPU Family；可选 GodotNode 要求 Apple4 GPU Family，不满足时可查询原因并安全拒绝。模拟器兼容边界已验证，Apple4+ 真机共享渲染仍待验收，详见 TRACKING.md 的 D-001、IOS-01/02。

Web PCM 更新（2026-10-29）：宿主与 Godot 运行在同一 window 线程时，PCM 在宿主请求时按需混音；不启动 PCM 生产 pthread，不预填充 lookahead 队列。此路径用于避免 Firefox ScriptProcessor 突发回调耗尽异步队列，原生平台继续使用后台生产队列。包含 Web 排空记账修正的新运行库已通过 Chrome/Firefox/Playwright WebKit 的 2/3/4 缓冲矩阵；实际设备输出、长期复杂混音及端到端延迟仍待验收，详见 TRACKING.md 的 WEB-01/02。

## 构建和验证

Linux 自动回归入口：

```sh
python3 Tools/Godot/tests/ci_linux.py --jobs 2
```

系统依赖见 `.github/workflows/godot.yml`。入口依次构建运行库与 Dora 测试宿主，检查着色器构建失败后的立即退出/同进程恢复，再执行 EGL 2/3/4 缓冲矩阵和同进程 100 轮创建/销毁，最后构建普通宿主并执行项目拒绝/恢复、随包加载及缺库退化。测试宿主、普通宿主与运行库分别保存哈希，普通构建不能覆盖测试产物；全部阶段通过后才写聚合 verification.json，初始化失败/普通宿主报告索引分别位于 init_failure_reports、ordinary_reports。新增阶段的独立运行与新版聚合入口验收分开记录，详见 TRACKING.md。

优化普通 Linux Release 的自动回归另有入口，复用已构建且清单校验通过的 Godot 运行库，不重编 LibGodot：

```sh
python3 Tools/Godot/tests/ci_linux_release.py --jobs 2
```

该入口构建普通优化宿主、从编译命令检查优化标志和 NDEBUG，然后执行 2/3/4 缓冲活动退出、创建后立即退出、随包/缺库退化。报告位于 `build/godot-runtime/ci-linux-release/`；Godot 工作流在原 Debug/循环回归后执行本入口并上传两组结果。本地复现可显式指定 `--source-root`、`--library`、`--output`；`--prebuilt-receipt` 仅用于原产物与完整 source-audit.json 均存在、源码/二进制哈希未变的复现，报告会标明跳过构建。该模式不能证明本轮重新编译或远程 CI 已通过。Ubuntu ARM64 VM/llvmpipe 与 SDL dummy 音频的边界见 TRACKING。

日志、截图、产物哈希及严格报告保存到 `build/godot-runtime/ci-linux/`。需要 Weston 12+；软件渲染可设置 `LIBGL_ALWAYS_SOFTWARE=1`，验证范围为相应 EGL 驱动。仅复用明确已构建的本地产物时使用 `--skip-build --ordinary-binary /absolute/path/to/ordinary/Dora`，测试宿主/运行库仍由原环境选择器指定，报告会保留构建跳过标记。每次本地复验应选择新的 `--output` 目录。Linux 循环观察 bgfx 资源计数/估计字节，不包含 macOS 专用的 Metal 分配量查询。默认构建分支也可能使用编译缓存，不能据 build_skipped=false 推断再次全量编译。

原生初始化失败回归（要求 `DORA_BUILD_GODOT_NODE_TEST=1` 构建的测试宿主）：

```sh
python3 Tools/Godot/tests/run_init_failure.py --binary /absolute/path/to/test/Dora --library /absolute/path/to/libdora_godot.dylib --output /absolute/path/to/fresh-failure-results --mode exit
python3 Tools/Godot/tests/run_init_failure.py --binary /absolute/path/to/test/Dora --library /absolute/path/to/libdora_godot.dylib --output /absolute/path/to/fresh-recovery-results --mode recover
```

Linux 使用 `.so`，无显示会话时由 `tests/with_weston.py` 包裹。测试宿主向实际编译器传入缺少入口的无效源码，要求 Lua 构造拒绝。exit 用例在首帧前正常退出，并检查 SpriteRenderer 在 bgfx 设备之前释放；recover 在同一进程撤销故障注入后完成 1000 帧、15 截图和完整输入/控制器、resize/cancel、别名、音频及排空。原始日志完整保留；只对明确标记的预期故障区间作单独验证，恢复阶段继续使用原有严格校验器。注入入口仅编译进专用测试宿主，普通 Release 不包含该入口或注入标记。

真实 Safari 的 WebDriver 入口（要求 Safari 已启用“允许远程自动化”）：

```sh
python3 Tools/Godot/tests/web/run_safari.py --package /absolute/path/to/prepared-node-player --buffers 3 --output /absolute/path/to/fresh-results
```

输入包需由 `tests/web/prepare_node_game.py` 准备。脚本使用已安装的 `/usr/bin/safaridriver`，不修改 Safari 设置，复用严格像素/GPU/PCM 校验器；它只在所服务的测试页面加载公共采集脚本，不修改运行库文件。Playwright 与 Safari 共用 `acceptance_init.js`。原生Safari26.6.2的DPR2矩阵现已通过，当前范围见WEB-02。默认WebDriver端口0由系统选择空闲端口；显式端口不可bind时在启动前失败，不附着他人服务。

macOS 普通应用的项目边界回归：

```sh
python3 Tools/Godot/tests/run_project_boundary_macos.py --app /absolute/path/to/ordinary/Dora.app --library /absolute/path/to/libdora_godot.dylib --output /absolute/path/to/fresh-results
```

验证项目 A 动画、关闭、不同路径项目 B 明确拒绝、A 再次创建与动画，以及成功/失败客户端的 GPU 清理。此项不提供多项目切换或运行库卸载能力。

Linux 对应入口（需先构建不带 `DORA_BUILD_GODOT_NODE_TEST` 的普通宿主）：

```sh
python3 Tools/Godot/tests/with_weston.py --logs /absolute/path/to/weston-logs -- \
  python3 Tools/Godot/tests/run_project_boundary_linux.py --binary /absolute/path/to/ordinary/Dora --library /absolute/path/to/package/libdora_godot.so --output /absolute/path/to/fresh-results
```

入口复用公共图像/排空校验，记录 GL 实际渲染器；普通 Debug 宿主已在 Ubuntu ARM64 VM / Mesa llvmpipe 通过此用例，详细证据见 TRACKING.md 的 RUNTIME-01。普通宿主与原生测试宿主的结果分别记录。

Linux 普通宿主的随包加载和缺库退化回归：

```sh
python3 Tools/Godot/tests/with_weston.py --logs /absolute/path/to/weston-logs -- \
  python3 Tools/Godot/tests/run_ordinary_linux.py --binary /absolute/path/to/ordinary/Dora --library /absolute/path/to/package/libdora_godot.so --output /absolute/path/to/fresh-results
```

两项用例各有独立资产树，检查相对路径 GodotProject、默认资产目录中的运行库加载、Godot 动画、Dora 图形运动和退出；缺库项实际移除 `.so`，确认 Godot 未启动而 Dora 内容继续。Godot 许可复制到 `GodotNotices/`，保留 Dora 原有的 `LICENSES` 文件。Ubuntu VM / llvmpipe 两项已通过，正式安装/升级、Release 与物理硬件范围仍待验收。

运行库部署包校验：

```sh
python3 Tools/Godot/verify_package.py /absolute/path/to/runtime-package
python3 Tools/Godot/tests/package_integrity.py
```

macOS Release 运行库使用 `DORA_GODOT_TARGET=template_release Tools/Godot/build_runtime.sh`，开启 `optimize=speed`，输出至 `build/godot-runtime/release/package`，日志为 `build-release.log`；默认 Debug 包路径不变。`test_macos.sh` 同样接受该变量选择运行库。Release 运行库与 Release Dora 宿主需分别确认，不能仅凭运行库 target 推断宿主构建模式。

已构建的独立 macOS 测试宿主可直接指定运行库验收：

```sh
python3 Tools/Godot/tests/run_macos_node.py --app build/godot-runtime/release-host/Dora.app --library build/godot-runtime/release/package/libdora_godot.dylib --results build/godot-runtime/release-node-3 --host-mode release --buffers 3 --audio --controller --resize --aliases
```

该入口不会重建或修改宿主包，要求宿主已启用 `DORA_BUILD_GODOT_NODE_TEST=1`；报告记录双端 SHA-256。`--host-mode` 只记录声明，实际模式以对应 xmake 构建配置/日志为准。

当前打包工具生成 `dora-godot-runtime` v1 清单，包含声明的 Godot/bridge 版本、固定源码归档哈希，以及库、许可证和配套文件的逐文件 SHA-256。校验器不加载库；签名、实际二进制 ABI、GPU 运行和发布验收仍须分别执行。旧清单需用当前打包工具重新生成，不能通过手改版本字段升级。Android 在 JNI/STL 文件复制后重新封存完整清单，iOS 在 framework 签名后封存；正式应用重签名会改变哈希，应在最终产物阶段重新记录。

在仓库根目录运行：

```sh
Tools/Godot/test_macos.sh
Tools/LibGodotMetalProbe/test_matrix.sh
```

需要 Xcode、xmake、Python 3 和 Pillow。首次构建下载并校验固定源码；依赖、动态库和测试包全部位于 `build/`。第一个命令构建完整标准模块的 Godot 运行时和可选 Dora 测试入口，开启 Metal API Validation，检查动画、暂停/恢复、输入、场景重载和节点移除后重建。第二个命令对原始条码原型执行 2/3/4 缓冲的真实 GPU 回归，包含消费者积压。

报告分别位于：

- `build/godot-runtime/node-results/verification.json`
- `build/godot-metal-probe/current-matrix/verification.json`

三个桌面平台的测试入口还会在独立进程中检查真实动态库的启动前 C ABI 边界：
版本／结构体尺寸、输出缓冲区保护、无效参数／句柄及关闭后状态。该报告位于
结果目录的 `abi-preboot/verification.json`，明确不代表 GPU 通过。也可单独运行：

```sh
python3 Tools/Godot/tests/runtime_abi.py --library build/godot-runtime/package/libdora_godot.dylib --backend Metal --output build/godot-runtime/abi-native-macos
```

每次启动测试先删除该轮旧报告，失败不会保留旧的成功标记。截图用于检查最终 Dora 合成结果；共享传图不经过 CPU 像素读回或上传。

单独运行截图验证器也会先清除旧报告。可运行
`python3 Tools/Godot/tests/verifier_failures.py`，检查缺失日志和错误日志均不能残留
成功报告；这项检查不启动引擎，也不代表 GPU 验证通过。

## GPU 粒子动画验收

`tests/particle_project` 同时运行两种真实 `GPUParticles2D`：自定义 `DELTA`
着色器和标准 `ParticleProcessMaterial`，分别与独立 CPU 积分的红色标记比较。
测试包含时间倍率 1／0.25／2／0、SceneTree 暂停（Always 与 Pausable 两种语义）、
冻结时切换视口尺寸及恢复。每个平台执行 1,000 个控制帧，检查 13 张 Dora 合成截图，
并要求生产者和所有宿主 GPU 读取完成、无错误及资源泄漏日志。

先构建对应运行库与可选测试宿主，再运行：

```sh
DORA_BUILD_GODOT_NODE_TEST=1 xmake build -j2 Dora
python3 Tools/Godot/tests/run_particles.py --results build/godot-runtime/particles-local
# Linux 无显示会话时：
python3 Tools/Godot/tests/with_weston.py --logs build/godot-runtime/particles-weston -- python3 Tools/Godot/tests/run_particles.py --results build/godot-runtime/particles-local
```

可用 `--library` 指定运行库；Windows 必须在实际图形用户会话中运行。
时间条码使用高精度浮点转整数及位移，避免 GLES `exp2` 近似值破坏低位。
粒子场景将物理追帧上限设为 512，隔离首次 GPU 着色器编译停顿造成的追帧时间裁剪；
这项验收不覆盖追帧上限下的游戏时间策略。详细桌面结果索引为
`build/godot-runtime/particles-desktop.json`，平台范围仍限于 macOS Metal、
Ubuntu ARM64／virgl EGL 和 Windows 11 ARM64 虚拟机内的 x64 WGL。

此测试发现并修复两个实际问题：Godot 材质键按位域填充字节比较导致着色器缓存泄漏，
现在只打包逻辑字段参与哈希与比较；无表面 EGL 上粒子变换反馈所需的帧缓冲不完整，
现在使用私有 1×1 辅助 FBO，支持 pbuffer 时使用私有 pbuffer。共享图像仍使用原有
GPU 纹理与 fence 协议。`tests/particle_key.py` 单独检查材质键的填充字节不变性，
该 CPU 回归不等于 GPU 验收。

## 节点使用

普通 macOS / Linux / Windows Dora 构建包含节点适配层。各平台的 LibGodot 是运行时可选依赖。必须使用本目录脚本构建的 Dora bridge 运行库；上游原版 LibGodot 没有此 C ABI，不能直接替换。指定 `DORA_GODOT_LIBRARY` 为 `build/godot-runtime/package/libdora_godot.dylib` 的绝对路径，或将匹配动态库放到资源根目录的 `libdora_godot.dylib`。Linux 对应 `build/godot-linux/package/libdora_godot.so`。请以构建脚本实际输出的 package 路径为准。

Lua 示例：

```lua
local Dora = require("Dora")
local reason = Dora.GodotNode.getUnsupportedReason()
assert(reason == "", reason) -- GPU/backend only; runtime library is checked during startup.
local node = Dora.GodotNode("/absolute/path/to/godot-project", "", 640, 360, 3)
assert(node, "Godot node creation failed")
node:addTo(Dora.Director.ui)
-- 启动异步完成；检查 node.running 和 node.lastError。
-- node:pause() / node:resume() / node:restart()
```

项目路径支持包含 `project.godot` 的目录或导出的 `.pck` 文件。空场景路径使用项目主场景。项目保持自身 SceneTree 根路径、current_scene 和 autoload。显式 `sendPointer` 坐标以 Godot 输出窗口左上角为原点，单位为输出纹理像素；Godot 按自身内容拉伸变换转换为场景坐标。

创建前能力查询也提供给 Rust（`GodotNode::get_unsupported_reason()`）、Wa（`dora.GodotNodeGetUnsupportedReason()`）和 C#（`GodotNode.GetUnsupportedReason()`）。返回空字符串表示当前 GPU/后端支持，非空字符串解释拒绝原因；不会加载运行库，也不保证项目或可选库可用。这些语言的新增接口已编译，跨宿主运行验证状态见 TRACKING.md 的 BIND-01。

在异步启动完成前调用 `pause()` 也会生效。暂停使用 Godot SceneTree 原生语义，`PROCESS_MODE_ALWAYS` 节点仍持续处理；恢复不会重建项目。失焦会释放桥接层持有的按键、鼠标和标准手柄按钮／轴状态。

GodotNode 会订阅 Dora 的标准 `ButtonDown`／`ButtonUp`／`Axis` 事件，并映射为 Godot
`InputEventJoypadButton`／`InputEventJoypadMotion`。该扩展复用现有输入结构，不改变 ABI
版本：`button` 保存 Dora 控制器 ID，`text` 保存 SDL 标准按钮／轴名，`x` 保存归一化
轴值。macOS Metal、Windows WGL、Linux EGL、Android EGL 与 WebGL2 的当前源码运行库均已通过 `a` 与
`leftx` 转发以及持有状态失焦释放，同时完成 720 帧三缓冲、别名和宿主 PCM 回归，
GPU 错误与欠载均为 0。报告分别为
`build/godot-runtime/node-controller-focus-macos-2/verification.json`、
`build/godot-runtime/windows-controller-focus/verification.json`、
`build/godot-runtime/linux-controller-focus/verification.json` 和
`build/godot-runtime/android-controller-focus/verification.json`；Web 2／3／4 缓冲矩阵为
`build/godot-web/node-controller-teardown/verification.json`。Windows 使用的 x64 DLL
SHA-256 为 `c13761f608e82fcf08fc3c94bda4cac9b67fa074916dff20eb3c450ce5ce08f7`。
这些测试注入 Dora 标准事件，不是物理手柄、热插拔或震动的通过证据。

Godot 输出采用预乘透明度。默认节点着色器和混合模式同时处理该编码及 Dora 节点透明度；替换 `effect` 或 `blendFunc` 时需要保留此语义。导入纹理、半透明像素、节点透明度和加法光效已使用实际截图校验。

## 同步协议

每个槽位独立持有 RGBA8 Metal 纹理和两条递增的 SharedEvent 时间线。生产者在 Godot 队列上等待该槽位最后一次消费完成，再 blit Viewport 并发布 ready。每个实际 bgfx 帧保守地等待所有已发布槽位的 ready，在全部绘制结束后为所有槽位发布 consumed，覆盖其他 Sprite/effect 保留的纹理引用。逻辑线程只发布已预留的槽位，防止异步回调错配。

推进 Godot 前，先通过 bgfx 原有 flip 路径提交已编码的宿主帧；正常 flip 会识别该帧已经提交，避免重复呈现。呈现保留渲染器配置的交换间隔。上一份 Godot 拷贝尚未完成时，本轮延后生产，避免 Godot 内部同步 fence 等待与宿主提交形成等待环。新拷贝在 GPU 上等待目标槽位最后一次宿主读取完成。GL ABI 2 增加 `can_advance` / `advance_async` 实现此路径；ABI 1 的原有三函数前缀仍可查询，当前 Dora 节点要求 ABI 2。

传图每个生产帧有一次 GPU blit。稳定运行期间不逐帧用 CPU 等待 GPU 完成；节点关闭和最终退出才排空队列。bgfx 包装 retain 外部 Metal 纹理，保证排队绘制期间资源仍存活。启动导入安排在 bgfx 实际创建纹理之后，避免节点重建时复用句柄而绑定旧资源。

`node.texture` 引用某个环形槽位，后续会随该槽位复用而变化；它不是不可变截图。
其他 Sprite 可以保留该引用。macOS 已通过 2／3／4 缓冲的别名引用测试：各 720 帧、
9 张截图，包含动画、暂停和原节点移除；合计 81 组上下条码一致，1,992 个活动
GPU 帧全部完成，错误与音频源欠载为 0。汇总报告为
`build/godot-runtime/alias-matrix-macos.json`，其中链接每组的原始报告。
Linux ARM64 EGL 和 Windows WGL 的三缓冲别名检查也已通过各 720 帧、9 张截图、
27 组条码。Linux 报告 `build/godot-runtime/linux-gl2-alias-graphics-only/verification.json`
只证明图形部分；同一轮音频验收因欠载失败，不属于完整通过。Windows 图形报告为
`build/godot-windows/alias-gl2-results/verification.json`。

```sh
DORA_GODOT_TEST_AUDIO=1 DORA_GODOT_TEST_ALIASES=1 Tools/Godot/test_macos.sh
# 使用 DORA_GODOT_TEST_BUFFERS=2 或 4 选择其他缓冲数；默认 3。
```

Android 优化运行库使用独立输出，不覆盖默认 Debug 包：

```sh
python3 Tools/Godot/build_android_runtime.py --sdk "$ANDROID_HOME" --target template_release --arch arm64 --jobs 2
```

包位于 `build/godot-android/release/arm64/package`。Gradle 可通过
`-Pdora.godot.runtimePackage=<包的绝对路径>` 选择 JNI 运行库，通过
`-Pdora.godot.buildDir=<独立目录>` 隔离应用构建产物。测试驱动
`Tools/Godot/tests/android/run_node.py --runtime-package <同一包路径>`
先验证封存清单，再核对 APK 内运行库哈希；构建通过不表示模拟器或真机运行通过。
启用 `dora.godot.test=true` 时，专用 prototype 包的 Release 变体保留
debuggable 并使用开发调试签名，以便 run-as 导出原生报告；普通 Release 包不受影响。
此验收验证优化代码，不代表最终生产签名或分发包验收。

普通 macOS 应用验收入口为 `Tools/Godot/tests/run_ordinary_macos.py`，显式指定
`--app`、`--library`、全新 `--output`。它拒绝含原生测试入口的宿主，复制应用后
执行真实 Lua 启动和默认资源目录加载，再移除可选库检查退化。测试副本使用本地
ad-hoc 签名；这不替代最终分发签名、安装和升级验收。

同进程循环与资源验收使用新增模式的原生测试宿主：

```sh
python3 Tools/Godot/tests/run_cycles_macos.py --app /absolute/path/Dora.app \
  --library /absolute/path/libdora_godot.dylib --output /absolute/path/new-results \
  --cycles 100 --buffers 3 --warmup 5 --max-metal-growth-bytes 0
```

每轮检查真实场景动画、移除后画面、GPU/PCM 排空，并在空闲期读取 bgfx 资源计数
及同一 MTLDevice 的 currentAllocatedSize。资源阈值不自动放宽，失败保留采样和日志。
该指标不包含全部 CPU 堆或驱动分配，不能据此宣称所有项目均无内存泄漏。

## 普通 Release 宿主的活动节点退出回归

退出测试需保留正在运行的 GodotNode 和每个共享纹理槽的 Sprite 别名，再调用公开 App.shutdown。预先移除节点的正常退出用例不能覆盖这个路径。使用未编入 Godot 测试入口的 macOS Release 应用：

```sh
python3 Tools/Godot/tests/run_active_stop_macos.py --app /absolute/path/to/ordinary/Dora.app --library /absolute/path/to/libdora_godot.dylib --output /absolute/path/to/fresh-results --buffers 3
```

分别使用 2/3/4 缓冲和全新的输出目录。入口封存产物哈希、开启 Metal 验证、截取两张图像，并在节点和所有别名仍存活时请求停止。严格校验器要求动画条码推进、各别名槽内容不同、GPU 生产/消费排空且无错误、PCM 零欠载及 48kHz 双声道音调。execution.json 只证明子进程执行记录；仅当全部验收通过才生成 verification.json。异常时保留原日志，超时不自动重启仍活动的进程。

普通 Release 原先在 SDL_QUIT 中直接 std::_Exit，无法提供此路径的最终排空证据。当前工作区修复为：一旦 Godot 会话被接受，该进程退出时走正常引擎清理；即使节点先被移除也保留该要求。未使用 Godot 的普通 Dora 内容保留原有快速退出。修复的实际验收与提交范围见 TRACKING.md，不据源码修改宣称已通过。

Linux 的对应入口使用普通宿主可执行文件，并在隔离 Weston 中运行：

```sh
python3 Tools/Godot/tests/with_weston.py --logs /absolute/path/to/fresh-weston-logs -- python3 Tools/Godot/tests/run_active_stop_linux.py --binary /absolute/path/to/ordinary/Dora --library /absolute/path/to/libdora_godot.so --output /absolute/path/to/fresh-results --buffers 3
```

同样分别执行 2/3/4 缓冲。校验包含实际 Godot OpenGL 渲染器字符串、条码/别名、GPU 和 PCM 排空。虚拟机、软件 EGL 和 SDL dummy 音频仅证明对应接口路径，不能替代物理 GPU/音频输出验收。Linux Dora 宿主的 release 模式需启用 mode.release 规则；本地新增构建规则后，还需从实际编译命令确认优化标志及 NDEBUG，不能只依据输出目录名。

macOS 启动中退出另有入口，在创建节点后、节点尚未 running 时立刻调用 App.shutdown：

```sh
python3 Tools/Godot/tests/run_early_stop_macos.py --app /absolute/path/to/ordinary/Dora.app --library /absolute/path/to/libdora_godot.dylib --output /absolute/path/to/fresh-results
```

校验要求实际引擎清理日志。若 Godot 在退出事件处理前已启动，仍必须有完整 GPU/PCM 排空；若尚未启动，则不应产生客户端排空记录。此用例不代替持续动画或设备丢失测试。

## 宿主音频接入（验证进行中）

新增可选 `GodotBridgeAudio.h` 扩展表，提供 48 kHz 双声道 float32 PCM 拉取。
音频 ABI 2 使用无音频设备的 Dummy 驱动，由注册到 Godot 的专用线程生产 PCM，
通过有界 SPSC 队列交给 SoLoud 源，生产不依赖渲染帧。宿主混音回调通过 ABI
只读队列，短缺时补零并保持流存活，不调用 Godot 混音器或 VM、不分配内存。
节点关闭时先停止宿主源，再停止并等待 Godot 音频线程。需同步更新宿主与运行库。
旧运行库没有音频扩展时保留原有无声画面行为。

可用以下命令验证实际 Godot 测试音到宿主混音源回调的路径：

```sh
DORA_GODOT_TEST_AUDIO=1 Tools/Godot/test_macos.sh
# 注入两次 250 ms 渲染停顿，并追加 12,000 帧动画；每 300 帧采样检查冻结/撕裂。
DORA_GODOT_TEST_AUDIO=1 DORA_GODOT_TEST_AUDIO_STALL=1 DORA_GODOT_TEST_ALIASES=1 \
  DORA_GODOT_TEST_SOAK_FRAMES=12000 Tools/Godot/test_macos.sh
DORA_GODOT_TEST_AUDIO=1 Tools/Godot/test_linux.sh
python Tools/Godot/test_windows.py --audio
```

测试项目产生左声道 440 Hz、右声道 660 Hz 信号；验证器检查两个节点生命周期的
PCM 消费计数和完整一秒样本的频率。它不会把回调验证报告为扬声器可听性测试。
这些命令需要匹配的新运行库。macOS 已通过 720 帧音频/图形节点测试：两个节点
生命周期各取得完整一秒左右声道样本，440/660 Hz 匹配，宿主源欠载为 0，退出无
Godot 对象泄漏警告。Linux EGL 与 Windows WGL 的音频 ABI 2 实际运行回归也已通过，
具体环境和报告见文末；编译和 CPU 队列测试不能代替音频路径运行验证。

## 当前边界

这是实验集成。运行库为标准原生 Godot 构建，未启用 Godot Mono/C# 项目运行时；Dora 的 C# 节点绑定属于宿主接口。macOS Metal 有原生运行证据，Linux、Windows、Android 的现有运行证据限虚拟机/模拟器；Web 已通过 Chrome、Firefox、Playwright WebKit，macOS原生Safari26.6.2的2/3/4矩阵也已通过；移动浏览器、完整DOM/IME和真实后台策略仍需单独验收。iOS 保持 Dora Apple2 / Godot Apple4，模拟器仅验证普通 Dora 与 Godot 安全拒绝边界。各平台最新范围与报告统一见 [TRACKING.md](TRACKING.md)。

当前支持单运行时、单个活动 GodotNode、同一项目移除后重建；运行时驻留到进程退出。不同项目不能在该进程内切换；节点移除不卸载运行库，最终 shutdown 后不承诺再次初始化。GL 运行时还要求重建时缓冲数一致，内部目标模式需保持尺寸一致；外部目标尺寸协商另行处理。设备丢失恢复、多项目并行、完整 IME、物理控制器热插拔/震动及最终分发仍待完成。

`tests/protocol.sh` 的 macOS/Linux 结果证明共享的 C ABI、缓冲所有权 CPU 协议，以及内嵌着色器源码的有界长度。`tests/embedded_shader.py` 使用全新字节列表，覆盖带/不带末尾零与带/不带末尾逗号的四种组合，编译实际 string_view 封装头，检查长度和与上游源码的逐字节一致性，避免旧生成头掩盖干净构建缺陷。`tests/abi_targets.sh` 只证明目标头文件可编译，均不等于平台 GPU 测试。实验历史见 [PLAN.md](PLAN.md)，当前任务状态见 [TRACKING.md](TRACKING.md)。

## Linux EGL 验证

在 Linux 主机安装 C++20 编译器、EGL/GLES3 开发头文件和 Python 3/venv 后运行：

```sh
Tools/Godot/tests/gl/run.sh
Tools/Godot/build_linux_runtime.sh
Tools/Godot/test_linux.sh
```

第一条只验证独立共享 EGL 上下文、GPU 纹理 blit、GLsync 和生产背压，不启动 Godot 或 Dora。Linux ARM64 / Mesa virgl 的 2/3/4 缓冲实际测试已通过 3,600 个消费帧和 99 个抽样帧，报告为 `build/godot-runtime/gl-transport-linux-arm64.json`。

无桌面的测试环境可用 `python3 Tools/Godot/tests/with_weston.py -- Tools/Godot/test_linux.sh` 启动隔离的 GL Weston，测试后自动清理。该模式依赖 Weston 12+，实际驱动仍以报告为准。

Linux ARM64 已通过完整 GodotNode 720 帧测试及导入资源 PCK 测试。归档报告为 `build/godot-runtime/node-linux-arm64/verification.json` 和 `build/godot-runtime/node-imported-pck-linux-arm64/verification.json`。实际设备为 Mesa virgl (Apple M1 Pro Compat)。当前源码也已交叉构建 x86_64 LibGodot 与 Dora 宿主；在 ARM64 Ubuntu 虚拟机的 Rosetta 转译环境中，ANGLE／SwiftShader 独立消费者通过 360 帧共享 GPU 纹理、动画暂停／恢复及零 GPU 错误验证。完整 Dora 节点路径分别受 Rosetta 对 Mesa LLVM AOT 的限制和 ANGLE 启动期终止阻断，因此仍未验证 Linux x86_64 原生硬件上的完整节点输出。报告为 `build/godot-runtime/linux-x64-rosetta-report.json`；该结果不能替代原生 x86_64 GPU 验收。

完整 Linux 运行时使用原生 Compatibility 渲染器，保留标准 Godot 模块，并导出可选的 GL 同步扩展表。Dora 后端要求 bgfx OpenGL/OpenGLES 和 EGL，Vulkan 尚不支持。GL 上下文销毁前调用 Godot 退出钩子；两个上下文分别保留自己的 framebuffer/VAO 等状态，只共享纹理和 fence。

`build_linux_runtime.sh` 和 macOS 构建脚本会生成带上游 MIT 许可、第三方 notices 与二进制校验清单的 `package/` 目录。清单仅记录开发构建产物，不能替代平台运行验证。

## Web 启动失败与队列清理

Web最终停止（含启动失败）会先停止WebTaskQueue并释放排队捕获，再销毁自动释放池/GPU。已安排的回调随后为空操作，停止后不接受新任务；重新启动须创建新Module/重载页面。该路径不提供原地context恢复。

`tests/web/task_queue_stop.py --output <directory>`用实际C++队列与确定性调度器检查外部停止、任务内部停止、捕获释放及晚到回调；已接入protocol.sh，不代表GPU执行。

真实浏览器回归使用`tests/web/bootstrap_failure.lua`作为测试包init.lua：先排入日志任务再主动报错。复制普通Player到独立输出目录，使用`Projects/xmake/tools/web/package_web_game.mjs`打包该脚本，然后运行：

```sh
DORA_PLAYWRIGHT_MODULE=/absolute/path/to/node_modules/playwright node Tools/Godot/tests/web/run_bootstrap_failure.cjs /path/to/failure-player /path/to/fresh-results
```

依赖Playwright1.62.1（Node>=20）及浏览器；`DORA_BROWSER_ENGINE`可选chromium/firefox/webkit。脚本要求预期Lua错误、faulted状态、已释放输入/IME服务、无Wasm/JS异常或GL错误。Linux Web CI会安装Chromium并在真实Player上执行此项；只有该job实际通过才记为远程通过。该故障用例本身不证明Godot GPU输出，正常共享输出仍须另外运行node矩阵。

## Rust / Wa / C# 绑定

节点接口也通过 Dora 的生成绑定提供给 Rust、Wa 和 C#。Rust 使用
`GodotNode::new(project, scene, width, height, buffers)`；Wa 使用
`dora.NewGodotNode(project, scene, width, height, buffers)`；C# 推荐使用
`GodotNode.TryCreate(project)` 并检查返回值。它们使用同一个节点、异步状态与
GPU 传输协议，后端支持范围与 Lua 一致。

```sh
python3 Tools/Godot/tests/bindings/generate.py
python3 Tools/Godot/tests/bindings/build.py
DORA_BUILD_GODOT_NODE_TEST=1 xmake build -j2 Dora
python3 Tools/Godot/tests/bindings/run.py
```

第一步需要 Rust `wasm32-wasip1` 目标、Wa 和 .NET 8 SDK；只编译某些语言时
可用 `--languages Rust Wa`。macOS 需要先用 `build_runtime.sh` 构建运行库。
Linux 需要先用 `build_linux_runtime.sh` 构建运行库；无桌面时将最后一步放在
`tests/with_weston.py --` 后执行。修改项目路径时，构建和运行两步都应指定
相同的 `--project`，因为测试模块会嵌入该路径。

Rust / Wa 测试在真实 Wasm3 中创建节点，并通过生成的函数转发全部 Godot
控制操作，检查两次创建、运行状态、字符串字段、暂停恢复、指针、按键、文本和
场景重载，再校验最终 Dora 截图与 GPU 计数。结果位于
`build/godot-bindings/node-{rust,wa}/verification.json`。
视口尺寸回归可用以下命令执行（固定三缓冲）：

```sh
python3 Tools/Godot/tests/bindings/run.py --resize --cancel-resize --aliases --audio --audio-stall --reservation
```

该模式由语言模块实际调用 `viewportSize` / `resizeViewport` 对应接口，覆盖
800×450、暂停中的 320×180、恢复 640×360、忙时拒绝、非法尺寸、同尺寸空操作、
移除时取消请求；每种语言运行 1000 帧并校验 15 张 GPU 截图。
生成器在 `build/` 隔离目录运行，只回写 GodotNode 绑定及本轮 C# ABI 修复文件，保留其他生成文件。
`--verify-only` 复核已有截图与完整命令名计数，不启动 GPU；失败会删除 PASS 报告。

构造错误与恢复可在独立目录验证。Rust/Wa 使用真实Wasm3：

```sh
python3 Tools/Godot/tests/bindings/build.py --output build/godot-bindings-constructor-rejections --languages Rust Wa --constructor-rejections
python3 Tools/Godot/tests/bindings/run.py --output build/godot-bindings-constructor-rejections --languages Rust Wa --constructor-rejections --app /path/to/test/Dora.app --library /path/to/libdora_godot.dylib --resize --cancel-resize --aliases --audio --audio-stall --reservation
```

Windows C# 同组用例使用公开 `GodotNode.TryCreate`（返回null），运行前需构建匹配的原生C#测试宿主：

```sh
python Tools/Godot/tests/bindings/build.py --languages CSharp --constructor-rejections --output build/godot-bindings-constructor-rejections-csharp
python Tools/Godot/tests/bindings/run_csharp.py --output build/godot-bindings-constructor-rejections-csharp --native-library C:/path/to/Dora.dll --library C:/path/to/dora_godot.dll --dotnet C:/path/to/x64/dotnet.exe --constructor-rejections
```

每轮通过真实生成绑定检查零宽、零高、过大宽度、1/5缓冲及缺失项目返回None/nil/null，再创建正常节点。两轮共12次拒绝后，仍要求完整1000帧/15截图回归。原始run.log保留全部预期错误；单独recovered/run.log只移除精确匹配的10条尺寸/缓冲错误及2条缺失项目错误，其他错误继续由原严格校验器拒绝。共同的constructor_rejections.py要求全部错误诊断精确匹配预期消息与次数；非预期错误、critical或warning均拒绝。该模式不能替代运行库缺失、异步启动失败或其他错误面的验收。

C# 已通过 Parallels Windows11 ARM64 上的 x64 .NET / WGL 原生执行验证，
使用公开 `App.Run` 和生成的 P/Invoke 控制节点，固定三缓冲，1000 个控制帧、
15 张 GPU 截图。全部 1728 个 C# 导入符号已与实际 DLL 导出表核对；编译、
导出检查和 GPU 报告分别记录。原生 C# 宿主仍限 Windows，Godot 运行库未启用 Mono。

Windows 的 C# 原生 GPU 测试使用 xmake 生成的 64 位共享库，避免旧 Win32
工程与 64 位 Godot 运行库混用。以下为 PowerShell 命令：

```powershell
$env:DORA_BUILD_CSHARP_NATIVE="1"
$env:DORA_BUILD_GODOT_NODE_TEST="1"
xmake f -y -p windows -a x64
xmake build -j2 Dora
python Tools/Godot/tests/bindings/build.py --languages CSharp --output build/godot-bindings-csharp
python Tools/Godot/tests/bindings/run_csharp.py --library C:/path/to/dora_godot.dll
```

测试通过公开 `App.Run`、生成的 P/Invoke 绑定和原生反向回调创建节点，
复用 1000 帧/15 张截图的完整尺寸、动画、输入、纹理别名和音频验收。
编译需要 .NET 8 SDK；执行所用 .NET 主程序必须匹配 DLL 架构。在 ARM Windows
测试 x64 DLL 时，可用 `--dotnet` 指定 x64 .NET 8 的 `dotnet.exe`。
`--verify-only` 只复核已有结果；C# 的 GPU 报告与编译报告分别保存。
原生结果位于 `node-csharp/verification.json`，DLL/程序集哈希位于 `artifacts.json`，
静态导出核对位于 `exports.json`。本次实际结果保存在
`build/godot-bindings-csharp/windows-results/node-csharp/`；复制真实截图并删去一条
尺寸命令的负例会被拒绝，并删除旧的通过报告。

无效项目与 Wasm 初始化失败的退出回归可单独运行：

```sh
python3 Tools/Godot/tests/bindings/build.py --languages Rust --output build/godot-bindings/invalid --project /dora-godot-intentionally-missing-project
python3 Tools/Godot/tests/bindings/failure.py --module build/godot-bindings/invalid/rust/target/wasm32-wasip1/debug/godot-bindings.wasm --output build/godot-bindings/invalid-results
```

该测试故意触发 Wasm 初始化失败；通过条件是宿主返回测试失败码 2，同时没有崩溃、
GPU 句柄泄漏或延迟销毁的 C++ 对象。GodotNode 在构造 Sprite 前验证路径和缓冲参数，
避免失败启动创建随后无法正常排空的默认 GPU 效果资源。Linux 版本也需提供桌面或
使用 `with_weston.py` 包装运行命令。

## Windows WGL 构建与验证

Windows 使用独立 WGL 上下文、同一像素格式和 share group，与 bgfx 共享 OpenGL
纹理和 GLsync。Godot 仍在进程内使用原生 Compatibility 渲染器。它与 Linux EGL
共用纹理环、GPU blit 和 fence 逻辑；上下文创建与释放分别由平台实现。

Windows 独立 WGL 传输测试已通过 2／3／4 缓冲共 3,600 个消费帧，真实 LibGodot
动画、暂停恢复和中文项目路径测试也已通过 360 帧，GPU 错误均为 0。测试环境为
Parallels Windows 11 ARM64，x64 程序通过系统模拟运行，OpenGL 3.3 由 Parallels
Metal 驱动提供。Windows Dora 节点的源码项目与导入 PCK 两组测试均通过：
合计 1,440 个消费帧、16 张最终合成截图，包含动画、暂停恢复、输入、场景重载、
节点重建、导入纹理、预乘透明度和加法混合，GPU 错误为 0。实际报告位于
`build/godot-windows/node-source-after-readback/verification.json` 和
`build/godot-windows/node-pck-results/verification.json`。
普通 Windows 宿主仍按原有方式选择渲染器；使用 Godot WGL 时必须在进程启动前
设置 `DORA_GODOT_WINDOWS_GL=1`。新 xmake 构建同时包含 D3D11 和 OpenGL 3.3，
不能复用只包含 D3D11 的旧 bgfx 静态库。Windows shaderc 同时启用 HLSL 和 GLSL，
以编译节点的透明度处理着色器及其他自定义效果。GLSL 优化器的 C 源文件按 C11
编译，以保留与 C++ 调用方匹配的 C 符号。渲染器不匹配时，节点构造会直接失败。

在具备 Visual C++ / Python / xmake 环境的 Windows 主机上：

```powershell
python Tools/Godot/build_windows_runtime.py
python Tools/Godot/test_windows.py --skip-build
```

Windows ARM64 上应使用原生 ARM64 xmake，以便正确选择宿主 Rust/Go 工具链；
Dora 和 Godot 的目标架构仍为 x64。有完整工具包但不在 PATH 时，可使用
`--xmake C:\path\to\xmake.exe`。已经构建 DLL 时，可用
`--skip-runtime-build --library C:\path\to\dora_godot.dll` 只构建 Dora 并运行测试。

上面的 `--skip-build` 需要事先构建测试宿主；也可直接运行
`python Tools/Godot/test_windows.py`，由它构建运行库和测试宿主，并设置需要的
渲染器环境。验证导入 PCK 时使用 `--project 路径/project.pck --fixture 路径/fixture.json`。
测试结果只有在真实 Windows 进程、最终 Dora 截图和 GPU 计数检查
通过后才写入 `build/godot-runtime/node-windows-results/verification.json`。

自动 IME 宿主改动后，Windows 11 交互会话中的当前 Dora 源码重新用 MSVC 编译，
并配合先前已验证的 ABI-2 WGL DLL 完成 720 帧、三缓冲、别名和宿主 PCM 回归；GPU
错误与音频欠载均为 0。报告：
`build/godot-windows/node-auto-ime-host-results/verification.json`。由于 macOS 本机没有
MinGW，该次报告只证明新宿主兼容旧运行库。随后在隔离 Ubuntu ARM64 构建机安装
MinGW POSIX 工具链，从当前源码生成了完整 Godot 4.6 x86_64 DLL；PE 导出表包含
`dora_godot_get_ime_api` 等六个 Dora 接口，SHA-256 为
`b594469d73d48577cad433f99086b9748bfdb7a32e0192e76390cbf7771aff1d`，产物位于
`build/godot-windows/ime-package/dora_godot.dll`。随后以已登录 Windows 用户的交互式 GPU
会话加载这一精确 DLL，通过 228 项 ABI 预检以及 720 帧三缓冲 GodotNode 回归：两次
节点生命周期均完成，纹理别名、暂停／恢复、输入、场景重启和宿主 PCM 均通过，GPU
错误、待处理 reader 和 PCM 欠载均为 0。报告：
`build/godot-windows/node-new-ime-runtime-results/verification.json`。以 Parallels Tools 的
SYSTEM 会话直接启动图形程序会在加载 Godot DLL 前崩溃于 `prl_gldd.dll`，不能作为运行库
失败证据；WGL 验证必须在已登录的交互桌面会话运行。当前 DLL 的自动 IME ABI 已随实际
GodotNode 执行验证，但 Windows 原生候选词／组合编辑 UI 仍未验收。

`test_windows.py --ime` 进一步使用真实 Godot `LineEdit` 验证自动文本输入生命周期。
当前源码宿主与上述精确 DLL 在交互桌面通过 720 帧回归：首次场景自动绑定 IME，节点
移除后解绑，重建后再次绑定；Win32 `SendInput` 向前台 `SDL_app` 窗口提交 `WinIME中`，
经 `WM_CHAR`／SDL 文本事件进入 Godot。三缓冲 reader 均排空，GPU 错误和 PCM 欠载为
0。报告：`build/godot-windows/windows-ime-acceptance-results/verification.json`。该 Windows
ARM 虚拟机没有为窗口暴露传统 IMM32 context，因此这证明自动生命周期及操作系统来源的
已提交 Unicode 文本，不证明候选词窗口或组合编辑；报告中的
`composition_candidate_ui_tested=false` 必须保留。

Linux 上可用 MinGW 交叉编译运行库：

```sh
python3 Tools/Godot/build_windows_runtime.py --jobs 2
python3 Tools/Godot/tests/wgl/build.py --godot-source build/godot-windows/deps/godot-4.6-stable --dora-objects
```

第二步编译两个真实 Windows 测试程序，以及 Dora 的节点和 DLL 加载器对象。
它使用固定 Godot 源码中的 GLAD。将 `transport.exe`、`runtime.exe`、运行库包和
测试项目放到 Windows 后，运行 `python Tools/Godot/tests/wgl/run.py`，可分别验证
共享上下文传输和真正的 LibGodot 输出；两者均不能替代 Dora 节点的最终合成测试。
交叉编译报告的 `gpu_tested` 始终为 false。Windows 运行库保留标准模块，关闭
原生窗口辅助功能 AccessKit；宿主音频、动态 Viewport 尺寸等边界与其他后端一致。


### Windows Unicode 路径回归

运行库路径读取已改用 [GetEnvironmentVariableW](https://learn.microsoft.com/en-us/windows/win32/api/processenv/nf-processenv-getenvironmentvariablew)，测试宿主也把项目、Wasm 模块和截图目录转换为 UTF-8，再交给 Dora 接口。实际 Windows x64 进程已通过中文与 emoji 路径的 DLL、项目/截图、导入 PCK/截图三组测试：合计 2,160 帧、24 张截图，GPU 错误为 0。报告位于 `build/godot-windows/unicode-results/verification.json`；这些结果使用新 GL ABI 2 运行库，与前面的旧 DLL 基线分开保存。

准备好当前代码的测试宿主后，可运行：

```powershell
python Tools/Godot/tests/unicode_windows.py --library build/godot-windows/package/dora_godot.dll --fixture build/godot-runtime/imported-fixture/fixture.json
```

驱动创建包含中文和 `🚀` 的运行库、项目、截图及 PCK 目录，每种情况运行完整节点测试。提供 `--fixture` 时包含三组；不提供时只包含运行库和源码项目两组。只有实际 Windows 进程与图像／GPU 计数都通过，才生成 `build/godot-windows/unicode-results/verification.json`。CLI 帮助或语法检查不代表这些用例已通过。

### 音频线程解耦后的桌面回归（2026-10-28）

音频 ABI 2 的实际 macOS Metal、Linux ARM64 EGL、Windows x64 WGL 运行均通过
720 帧动态画面、暂停、重启、节点移除/重建和保留纹理引用检查；每轮注入两次
250 ms 渲染线程停顿，两个宿主音频源均零欠载，440/660 Hz 双声道采样通过。
Windows 是 ARM64 虚拟机中的 x64 进程，Linux 使用 Mesa virgl；不代表原生独显或移动平台。
物理扬声器可听性不在此次验收范围内。

原始报告分别位于 `build/godot-runtime/node-audio2-macos/verification.json`、
`build/godot-runtime/audio2-linux/node-audio/verification.json`、
`build/godot-windows/audio2-results/verification.json`。
macOS 另通过双缓冲与四缓冲各 720 帧检查，报告目录为
`node-audio2-two-macos` 与 `node-audio2-four-macos`。

正式 Dora 节点的 macOS 三缓冲持续测试也通过：附加 12,000 帧动画，共推进
12,720 帧、生产并完成 12,603 个 GPU 图像帧；40 张持续测试采样均保持动画，
共 147 组别名纹理上下条码一致。GPU 错误、未完成任务和音频源欠载均为 0。
报告：`build/godot-runtime/node-audio2-soak-macos/verification.json`。
桌面本轮结果索引：`build/godot-runtime/audio2-desktop.json`。

### 动态视口尺寸

C++／Lua（以及对应 Yue／Teal／TypeScript 接口）提供 `resizeViewport(width,height)`
和只读 `viewportSize`。返回值表示接受请求，尺寸字段在新纹理发布后更新。尺寸范围
为 1–8192，忙碌或未启动时拒绝；就绪节点同尺寸请求不重新分配。可选 viewport ABI 1
保持基础 ABI 不变，旧库仍可运行固定尺寸节点。GL 使用可选 GL targets ABI 1，
由 bgfx 拥有目标纹理、Godot 借用 GL 名称；没有对应扩展时调整尺寸返回 false。
Rust／Wa 和 Windows 原生 C# 的尺寸接口已完成实际运行验收，见语言绑定章节。

尺寸切换暂停新图像生产，等待已提交消费者／生产者 GPU 工作完成后，更换共享槽位。
场景、autoload、暂停和音频保持运行；宿主保留的旧纹理引用继续显示冻结画面。
只有切换边界会等待 GPU，正常帧继续使用原来的异步多缓冲路径。

```sh
DORA_GODOT_TEST_AUDIO=1 DORA_GODOT_TEST_ALIASES=1 DORA_GODOT_TEST_RESIZE=1 \
  DORA_GODOT_TEST_CANCEL_RESIZE=1 Tools/Godot/test_macos.sh
```

macOS 的 2／3／4 缓冲尺寸切换均已通过 Lua 实际运行测试，各 1,000 帧、15 张截图。
覆盖 800×450 → 320×180（暂停）→ 640×360、切换途中移除节点、重建和保留旧纹理引用。
合计 2,743 个 GPU 图像全部完成，135 组条码、90 个角标／边界采样通过，GPU 错误与
音频源欠载均为 0。三缓冲、四缓冲还各注入两次 250 ms 渲染停顿。
汇总报告：`build/godot-runtime/viewport-macos-matrix.json`。GL 后端的实际验证见下一节。

### 创建失败与单运行时占用

初始化失败的 GodotNode 会清理已创建的会话，并从 Dora 的未托管节点收养路径中移除，
不会在返回 nil／nullptr 后悄悄加入场景。只有成功取得运行时占用权的会话才能释放该占用。

三个桌面环境的回归在启动中、运行中及重建后各尝试竞争创建，并检查失败节点未加入
场景、原节点继续动画／输入／音频、移除后能重新创建。macOS 同时覆盖尺寸切换和
切换中取消。原始报告汇总：`build/godot-runtime/reservation-desktop.json`。

```sh
DORA_GODOT_TEST_RESERVATION=1 DORA_GODOT_TEST_AUDIO=1 DORA_GODOT_TEST_ALIASES=1 Tools/Godot/test_macos.sh
DORA_GODOT_TEST_RESERVATION=1 DORA_GODOT_TEST_AUDIO=1 DORA_GODOT_TEST_ALIASES=1 Tools/Godot/test_linux.sh
python Tools/Godot/test_windows.py --reservation --audio --aliases
# 对实际通过的日志副本注入错误，验证竞争创建与场景数量检查不能被跳过。
python Tools/Godot/tests/reservation_verifier_failures.py --results build/godot-runtime/node-reservation-fixed-macos
```

### Godot 项目主动改尺寸与内容拉伸

匹配的新运行库提供可选 `GodotBridgeOutput.h`／output ABI 1。项目修改根 Window
的 `size` 后，Dora 自动进行共享槽位重建；`viewportSize`、纹理矩形和节点尺寸在新画面
发布时一起更新。启动时 `_ready()` 修改尺寸也走该协商，不再由桥接层覆盖。
连续改尺寸会按最新请求重试；即使尺寸回到上一份已发布的值，也重建尚未发布的资源代。
旧运行库没有该扩展时，仍可运行原有固定尺寸节点。

内容拉伸由 Godot 自身的 Window／Viewport 变换计算，支持 Disabled、Canvas Items、
Viewport、Keep／Ignore／Expand 及整数缩放。需要外层缩放或留边时，运行库添加一个
Godot 离屏合成视口，保留预乘透明度，再走原有 GPU 纹理传输；边缘留空区域为透明。
无需外层合成的普通视口直接使用原输出。输入坐标是输出纹理左上角起算的像素，
Godot 再转换为逻辑场景坐标，Dora Sprite 的显示缩放和位置由 Dora 处理。

实际测试包含启动尺寸协商、八种配置及连续逐帧改尺寸，每轮 1,260 个控制帧、
16 张截图。测试从 SDL 事件进入 Dora Touch，再命中真实 Godot Button；根据平台的
Dora 输入来源使用鼠标事件或 SDL 鼠标转换对应的触摸事件，不直接调用按钮回调。
它检查最终尺寸、角标、透明边缘、半透明合成、动画、GUI 命中和 GPU 排空。
输入命中在各次尺寸切换完成后采样，不代表完整多点触摸、IME 或设备恢复验收。

```sh
DORA_BUILD_GODOT_NODE_TEST=1 xmake build -j2 Dora
python3 Tools/Godot/tests/run_output.py --startup --results build/godot-runtime/output-local
# 无显示会话的 Linux 使用 tests/with_weston.py 包装同一命令。
```

桌面证据索引为 `build/godot-runtime/output-desktop.json`。可用
`tests/output_verifier_failures.py --results <已通过的目录> --output <负例结果目录>`
检查缺失 GUI 命中、连续改尺寸记录、截图和错误日志都不能残留成功报告；此项仅检查
验收器，不会启动 GPU。

### GL 目标纹理与尺寸切换

EGL／WGL 新运行库可借用 Dora／bgfx 自己分配的 RGBA8 GL 纹理。每个生产帧仍只有
一次 GPU blit；新尺寸分配与排空仅发生在生命周期切换时。旧纹理由其 Texture2D／Sprite
引用持有，不会因 Godot 替换目标或关闭客户端而被释放，也不需要保存无限的旧分配列表。

`tests/gl/run_host_targets.sh` 已在真实 EGL／GLES 3.0 上验证 2／3／4 缓冲、三代尺寸、
54 个像素采样和错误参数拒绝，覆盖重绑、清空与销毁传输层后宿主纹理仍有效。旧接口
另通过 3,600 个消费者帧／99 次采样回归。两者属于传输层证据；完整 GodotNode 证据单独记录。

测试项目的条码会随实际视口尺寸重排，暂停时也响应尺寸变化。完整尺寸测试同时检查
新尺寸当前画面的上下条码，以及其他 Sprite 持有的旧纹理条码。四缓冲缩略图排布避开
放大视口的角标，颜色阈值未放宽。

Linux EGL 与 Windows WGL 的双／三／四缓冲完整尺寸矩阵均已通过，每组 1,000 帧、15 张截图。
加上 Metal 四缓冲回归，本轮共 7,000 个控制帧、105 张截图、330 组旧纹理条码与 42 组
当前新尺寸纹理条码，中心 3D 场景在恢复后确实变化。所有 GPU 工作完成，GPU 错误与
宿主混音源欠载均为 0；物理扬声器可听性未测试。三个桌面普通构建也通过。

完整报告：`build/godot-runtime/gl-targets-desktop.json`。Linux 使用 ARM64／Mesa virgl，
Windows 使用 Parallels Windows 11 ARM64 的 x64 进程；这些结果不代表其他 GPU、移动端或 Web。

### 材质时间与手动渲染

手动渲染消费 Godot `Main::iteration` 本轮实际计算的缩放后渲染步长，不再按每次绘制
固定增加 1/60 秒。Dora 显示后端禁用主循环的额外自动绘制，避免待处理 RD 资源造成
重复推进；尺寸重绘没有新的主循环步长时使用零步长。手动绘制也更新 Godot 已绘制帧计数。

这保留 Godot 的时间语义：`Engine.time_scale` 影响渲染时间，SceneTree 暂停本身不冻结
材质 `TIME`。主循环原生渲染步长在物理追赶上限裁剪之前计算，长停顿时不应强行改成
被裁剪后的场景 delta。时钟测试项目提高物理追赶上限，以隔离渲染时间接入的偏差。

专用测试在每次 Godot `_process` 中延迟 60 ms，GPU 分别绘制材质 `TIME` 与独立脚本
累积时钟的二进制条码。macOS Metal、Linux ARM64 EGL、Windows WGL 实际运行均通过
1／0.25／2／0 倍速、SceneTree 暂停、零倍速下尺寸重绘与恢复；39 张采样在 64 Hz 分辨率
下未见相对漂移。该结果验证材质时间，不代替粒子、设备恢复或移动端验证。
报告：`build/godot-runtime/timing-desktop.json`。

```sh
DORA_GODOT_TEST_TIMING=1 DORA_GODOT_TEST_PROJECT="$PWD/Tools/Godot/tests/timing_project" Tools/Godot/test_macos.sh
DORA_GODOT_TEST_TIMING=1 DORA_GODOT_TEST_PROJECT="$PWD/Tools/Godot/tests/timing_project" Tools/Godot/test_linux.sh
python Tools/Godot/test_windows.py --timing --project Tools/Godot/tests/timing_project
```

修复前的真实 GPU 采样保留在 `timing-before-fix-macos`：正常阶段材质时钟仅推进
29/64 秒，脚本时钟推进 136/64 秒，已绘制帧计数停在 1。当前验证器明确拒绝该数据，
并在失败时清除旧的通过报告。

### Android 实验构建

Android 使用上游 Java/JNI 平台服务和源码编译的标准 Godot 运行库；Dora 继续拥有
SDL/EGL、主循环和音频设备。Godot 不创建 Android 渲染视图，双方通过共享 EGL
纹理与 GPU fence 交接画面。Java 服务在 UI 线程构造，Godot Main 在 Dora 渲染线程运行。

需要 Android SDK 35、Build Tools 34、NDK 28.1.13356709，以及兼容 Gradle 8.2 的 JDK。
先按桌面构建说明准备 Godot 构建 venv，然后执行：

```sh
python3 Tools/Godot/prepare_android_aar.py
python3 Tools/Godot/prepare_android_test_assets.py
python3 Tools/Godot/build_android_runtime.py --sdk "$ANDROID_HOME" --jobs 2
Projects/Android/Dora/gradlew -p Projects/Android/Dora :app:assembleDebug \
  -Pdora.godot=true -Pdora.godot.test=true -Pdora.android.abis=arm64-v8a \
  -Pdora.android.jobs=2 --max-workers=2 --no-daemon
python3 Tools/Godot/tests/android/run_node.py --serial emulator-5554 \
  --sdk "$ANDROID_HOME" \
  --apk build/godot-android/gradle-app/outputs/apk/debug/app-debug.apk \
  --output build/godot-runtime/android-node-local --case lifecycle --buffers 3
```

测试 APK 使用独立包名 `org.ippclub.dorassr.godotprototype` 和独立测试资源，不替换普通
Dora 安装。驱动校验 APK 包名、隔离入口和运行库哈希；超时会保留原生进程与所有权记录，
供继续检查。可选择 `--buffers 2/3/4`、`--resize --cancel-resize --aliases`、
`--audio --audio-stall --reservation --ime --controller`，或 `--case timing/particles/output`。
这些选项表示可运行的验证入口，实际通过范围以 `PLAN.md` 和对应报告为准。

已通过 API35 ARM64 模拟器的 2／3／4 缓冲、共 3,000 帧／45 张截图，包含尺寸切换、
纹理别名、生命周期和宿主音频检查。报告：`build/godot-runtime/android-node.json`。尚不代表 Android
真机、后台恢复、完整触摸/输入法、音频可听性或移动端分发验收。

自动 Godot Control IME 桥接合入后，源码重新构建为 ARM64 运行库和独立 APK，并在同一
API35 模拟器重新执行 2／3／4 缓冲矩阵。三组各通过 720 帧、两次节点生命周期，保留
纹理别名数分别为 2／3／4；所有 GPU reader 均 `pending=0`、`gpu_errors=0`。三缓冲组
同时通过两段 48 kHz 双声道宿主 PCM，欠载为 0。报告目录为
`build/godot-runtime/android-auto-ime-node-buffers2`、
`build/godot-runtime/android-auto-ime-node` 和
`build/godot-runtime/android-auto-ime-node-buffers4`。这证明新 IME ABI 没有破坏 Android
编译、动态画面与 GPU 同步。专用 `--ime` 回归还让真实 Godot `LineEdit` 自动聚焦，
确认 Android `InputMethodManager` 已显示软键盘且服务对象为 SDL `DummyEdit`，并把系统
输入通道提交的 `IME42` 送入 LineEdit；同一运行通过 720 帧三缓冲 GPU 回归。报告为
`build/godot-runtime/android-auto-ime-soft-keyboard/verification.json`。这证明软键盘生命周期
和已提交拉丁文本路由，不代表中文候选词或组合编辑 UI 已验收。

控制器桥接更新后，当前 Godot ARM64 运行库与独立 APK 已重新构建，并在 Pixel 7 /
API35 ARM64 模拟器通过 `--controller --audio --aliases` 联合回归。`a` 按钮、`leftx`
轴及失焦自动释放均进入真实 Godot Input；同一进程完成 720 帧三缓冲、两次节点生命周期、
三份保留纹理别名及两段宿主 PCM，GPU 错误、待处理 reader 和音频欠载均为 0。运行库
SHA-256 为 `20af7feb71feee0c2c1f943cc71deec70f1017f5aa7fb214d64b69bc53d9f389`，
报告：`build/godot-runtime/android-controller-focus/verification.json`。这仍是模拟的 Dora
标准控制器事件，不代表 Android 物理手柄、热插拔或震动验收。

Android 原生编译可使用 `-Pdora.android.jobs=2` 限制 Ninja 编译与链接并发（1–32）。
Gradle `--max-workers` 只约束 Gradle 任务，不能约束每个 ABI 内部的 Ninja 并发。
执行 GPU 时钟等验证时需避免不受控的后台编译使单帧延迟超过测试物理追赶上限；
测试保留 Godot 原生时间语义，不通过放宽时钟像素误差掩盖异常。

Android 进一步通过材质时间、真实 GPU 粒子、八种场景主动尺寸／拉伸配置和实际
SDL 触摸事件到 Godot GUI 的测试，以及真实 Home／返回前台时同一进程中的表面销毁
重建。报告：`build/godot-runtime/android-advanced.json`。该批共 3,980 帧／50 张截图，
与 2／3／4 缓冲回归使用同一 APK 和运行库；强制上下文丢失与真机仍待验证。
`run_node.py --case lifecycle --background --audio` 可重复 Home／返回前台测试。

### iOS 实验构建

iOS 原型保留 Godot 的 `OS_IOS` 服务，由 Dora 拥有 UIKit 应用、Metal 呈现和音频设备。
运行库使用签名的 `DoraGodot.framework`，从应用 `Frameworks` 目录加载，只导出版本化
Dora ABI。标准 Godot 模块保持启用；当前包没有额外的 iOS 原生导出插件。

```sh
python3 Tools/Godot/build_ios_runtime.py --device simulator --jobs 2
python3 Tools/Godot/link_ios_runtime.py --device simulator
python3 Tools/Godot/build_ios_host.py --device simulator --jobs 2
# 从 xcrun simctl list 中选择已启动的专用测试模拟器 UDID。
python3 Tools/Godot/tests/ios/run_node.py --udid YOUR_TEST_SIMULATOR_UDID \
  --app build/godot-ios/host/simulator/arm64/debug/Dora.app \
  --framework build/godot-ios/simulator/package/DoraGodot.framework \
  --output build/godot-runtime/ios-node-local --case lifecycle --buffers 3
```

宿主构建使用独立包名 `org.ippclub.dorassr.godotprototype.ios`、资源入口、配置和产物目录。
构建器只刷新自己的包缓存，并校验资源入口及签名。测试驱动校验实际安装的 framework
哈希，记录原生 PID 和结束标记；未结束的原生运行必须先检查，不自动重启。

iOS 原生运行库启用 `disable_path_overrides=no`，支持宿主传入项目目录或 PCK。
模拟器 SDK 不提供 MetalFX 与定时 Metal 呈现 API：模拟器将可选 MetalFX 能力报告为
不可用，继续使用实际 Metal 渲染；真机分支保持上游能力。最低编译目标为 iOS 14。
`--device device` 可编译真机产物；本地 ad-hoc 签名不表示真机安装或分发通过。

当前编译、framework 链接和签名检查已通过。实际探针确认当前 iOS 模拟器最高仅提供
Apple2，立方体数组纹理被 Metal 拒绝；Godot Metal 驱动要求 Apple4，因而模拟器
尚未通过 Godot GPU 共享验收。能力诊断：`build/godot-runtime/ios-metal-capabilities`。
实际范围以 `PLAN.md` 与对应运行报告为准，不以编译成功代替 GPU 测试。

根据硬件能力分别检查，Dora iOS 最低要求保持 Apple2 GPU 家族，并拒绝 Metal
初始化失败后的 Noop 回退。模拟器保留 Dora 可支持的宿主测试，GodotNode 则在加载
运行库之前明确拒绝缺少 Apple4 能力的设备。Apple4 GPU 家族与 Metal 4 API 版本
是不同概念；Godot 的独立门槛不会影响普通 Dora 内容的硬件要求。

Apple 的模拟器能力说明：
[Developing Metal apps that run in Simulator](https://developer.apple.com/documentation/metal/developing-metal-apps-that-run-in-simulator)。
`tests/ios/run_node.py --expect-unsupported-gpu` 仅验证硬件拒绝与清理路径，写入
`unsupported-gpu.json`，不生成 GPU 渲染通过报告。

自动 Godot Control 输入法桥接更新后，模拟器运行库、framework 与宿主已重新编译并在
专用 iOS 26.5 模拟器复测。最新 framework SHA-256 为
`61911bd313a740ba2d641bd124f450d9f145b05392d60851939b86dc010ad31a`；Apple2 配置在
Godot 初始化前按预期拒绝，0 张截图，随后 bgfx 正常关闭。报告：
`build/godot-runtime/ios-user-request-simulator-apple4-rejection/unsupported-gpu.json`。这仍不是 iOS
共享 GPU 输出通过证据。


### Web 共享 WebGL2 传输探针

`tests/web/run_transport.py` 编译两个独立 Emscripten 模块，在一个真实 WebGL2 context
中传递同一 `WebGLTexture`，分别维护 WASM 内存和 GL 整数对象表。需要 Emscripten、
Node.js、Playwright 和已安装的 Chrome。Playwright 可通过 `DORA_PLAYWRIGHT_MODULE`
指定模块路径，默认使用 Node 的 `playwright` 包。

```sh
python3 Tools/Godot/tests/web/run_transport.py
```

测试使用临时本地 HTTP 端口，退出时关闭浏览器和服务；报告记录源文件、WASM 和 JS
的 SHA-256、编译命令、工具链与实际 GPU。失败前清除旧的通过报告。

当前 Chrome / ANGLE Metal / Apple M1 Pro 上，2／3／4 缓冲共 720 帧、1,815 个像素
采样通过；其中 357 帧不做像素读回，槽位复用通过异步 fence 检查并在未就绪时让出
浏览器事件循环。报告：`build/godot-web/transport-async/verification.json`。
像素读回仅用于测试判定，传输本身直接共享 GPU 纹理。

`web/shared_gl.js` 保存和恢复两个运行时的 GL 状态、共享纹理的各自整数名字，以及
Emscripten 挂在 context 上的 program / pixel-buffer 缓存。回归会故意在生产者中改绑
着色器与像素缓冲；消费者复用恢复后的着色器，避免重新绑定掩盖状态污染。
释放纹理前还会清除快照引用，防止恢复已删除纹理。活动 transform feedback 不允许跨边界。

这只证明传输方案可行，不是 LibGodot 或 Dora GodotNode 的 Web 验收。该组测试不覆盖真实 Dora Web 节点；实际节点与宿主 PCM 的后续验收见文末，DOM 输入和分发覆盖仍待完成。LibGodot Web 运行库的独立 GPU 测试见下节。首个运行时入口、异步 GPU 操作和资源生命周期仍需在实际 Dora /
Godot 双引擎上验收。该全量状态探针也未做性能验收。


### 真实 LibGodot Web 运行库

```sh
python3 Tools/Godot/build_web_runtime.py --jobs 2
python3 Tools/Godot/tests/web/run_runtime.py --buffers 2 --output build/godot-web/runtime-matrix-2
python3 Tools/Godot/tests/web/run_runtime.py --buffers 3 --output build/godot-web/runtime-matrix-3
python3 Tools/Godot/tests/web/run_runtime.py --buffers 4 --output build/godot-web/runtime-matrix-4
python3 Tools/Godot/tests/web/run_runtime.py --buffers 3 --pack --output build/godot-web/runtime-pck-3
```

需要前节的浏览器工具链、SCons（复用 `build/godot-runtime/venv/bin/scons`）；PCK 用例
还需要 Godot 编辑器，默认查找 `godot` 命令或 macOS 的 `/Applications/Godot.app`。
可用 `--godot-editor` 指定路径。当前测试工具链是 Emscripten5.0.5-git、Chrome156、
ANGLE Metal／Apple M1 Pro。PCKPacker 由本机 Godot4.4.1 执行，包由4.6运行库消费；
这是简单 GDScript/TSCN 资源包，不代表完整 Web 导出包或导入纹理覆盖。

运行库继续使用固定4.6源码与 Web 平台标准模块，启用上游的
`disable_path_overrides=no`，提供宿主驱动的 LibGodot 初始化／帧推进／关闭。Godot
保留自己的 Web OS、WASM 内存、对象表和线程；画布与主循环归宿主。此多线程原型
需要 COOP／COEP 响应头，测试 HTTP 服务已设置；普通 Dora Web 构建没有开启该功能。

`web/runtime_bridge.js` 在两个独立模块间映射纹理编号。纹理由宿主创建，Godot 借用
并 blit 离屏输出；关闭后测试检查宿主纹理仍存在。两者已经严格校验为同一 WebGL2
context，GPU 命令天然按同一队列排序，Web 路径不调用原生跨 context 的 waitSync，
不为稳态传图 CPU 等待 fence。完成状态仍由真实 GL fence／最终排空检查。

实际矩阵四轮共 1,440 帧、3,620 个像素采样，其中716帧不读回像素；每轮包含30帧
暂停图像检查、恢复与场景重启。纹理方向始终为 Godot 逻辑左上角对应纹理 y=0；
各轮 produced=completed=360，GPU 错误与 GL 校验警告为0。清理后宿主 GL 对象仍可
使用。索引：`build/godot-web/runtime-matrix.json`；最新原始双 WASM 传输探针另见
`build/godot-web/transport-current/verification.json`。

这是真实 Godot 运行库到独立 WASM GL 着色器的验证，**该组报告不代表 Dora GodotNode 输出验收**。
Emscripten 的主线程阻塞诊断原文保留在 `browser_errors` / `browser_diagnostics`；
图形判定只单独识别这条 SDK 诊断，其他 Godot 错误和 GL 校验错误仍导致失败。
主线程延迟、性能、宿主音频与完整输入／节点生命周期仍未验收。

构建产物位于 `build/godot-web/package`，包含 JS／WASM、桥接 JS 模块、上游许可证、
第三方声明和来源／编译参数／文件哈希清单。构建通过与浏览器 GPU 通过分别报告。


### 实际 Dora GodotNode Web 原型

```sh
python3 Tools/Godot/build_web_runtime.py --jobs 2
DORA_WEB_GODOT=1 DORA_WEB_GODOT_DIAGNOSTICS=1 \
DORA_WEB_BUILD_DIR="$PWD/build/godot-web/dora-build" \
DORA_WEB_PACKAGE_DIR="$PWD/build/godot-web/dora-probe" \
DORA_WEB_PLAYER_PACKAGE_DIR="$PWD/build/godot-web/dora-player" \
DORA_WEB_BUILD_LOVE_PROBE=0 xmake dora-web --mode=debug --profile=core --jobs=2
python3 Tools/Godot/tests/web/run_node_matrix.py
```

`DORA_WEB_GODOT` 默认关闭；开启后打包匹配的 Godot JS／WASM 和桥接模块，画布与
主循环仍归 Dora。`DORA_WEB_GODOT_DIAGNOSTICS` 只为节点与 PCM 的测试计数开启日志，
不是普通包的要求。主循环位于 Worker 的实验模式暂不支持此桥接。需要 COOP／COEP；
普通 Web 包不加载 Godot，也不因该功能而要求隔离响应头。

宿主和 Godot 使用独立堆／函数表。C ABI 的宿主 thunk 只传整数、复制字符串／资源／
PCM；纹理保持在同一个 WebGL2 context 中。原有 GodotNode GPU 环、全部别名读取
记录与 bgfx 回调继续使用，最终图片由真正的 Dora Sprite 合成。首个 context 创建时
捕获干净状态；Godot 的默认 VAO 也单独隔离，避免修改宿主默认 VAO 的属性。

启动时先通过 Dora 已验证的资源清单预加载 Godot 项目目录或 PCK，再复制到 Godot
虚拟文件系统；目录资源打包会包含对应 `.godot` 缓存。当前为项目资源启动快照，不是
两套文件系统的持续镜像。Godot `user://` 映射到独立 WASM 的 `/userfs` IDBFS；嵌入式
LibGodot 不经过官方 `web_main.cpp` 的同步循环，因此构建脚本为该挂载启用 Emscripten
写入自动持久化。

Chrome156／Apple M1 Pro 上已完成目录2／3／4缓冲和 PCK3缓冲：共2,480控制帧、
48张 Dora 合成截图、440个颜色采样及全部上下条码／别名一致性检查。覆盖预启动
暂停、恢复、C ABI 指针／按键、重启、640×360→480×270、保留别名、移除与重建。
各轮实际生产 fence 均排空，GPU错误0；PCM经宿主SoLoud读取，440／660 Hz两声道
与零欠载检查通过。索引：`build/godot-web/node-desktop-browser-matrix.json`。
普通 core Debug 的独立构建和浏览器启动／停止回归也通过，未加载 Godot。

控制器桥接源码更新后，当前 Web LibGodot 与 Dora Player 已增量重建，并重新完成
目录2／3／4缓冲矩阵：共1,860控制帧、36张 Dora 合成截图。每轮均验证 device 7 的
`a`、`leftx=0.75`、Input 状态和持有状态失焦释放；两次节点生命周期的 GPU reader
全部排空，GPU错误与PCM欠载均为0。报告：
`build/godot-web/node-controller-teardown/verification.json`。这是合成的 Dora 控制器事件，
不代表浏览器物理手柄、热插拔或震动验收。

同一矩阵还验证正常 `stopped` 状态会幂等销毁 Web 平台服务：DOM 监听器不再进入
已关闭的 WASM，IME 控件被移除，按键／指针状态归零，音频上下文关闭；停止后再次
触发 blur／visibilitychange 无错误。当前二进制又通过两个完整页面生命周期的
`user://` IndexedDB 计数 1→2 恢复，报告为
`build/godot-web/persistence-teardown-results/verification.json`。

运行中的三缓冲节点还通过显式宿主 suspend/resume：引擎帧在 70 保持不变，Web Audio
上下文由 running→suspended→running，恢复后继续完成 620 帧、12 张截图、两次节点
生命周期，GPU错误与PCM欠载为0；报告：
`build/godot-web/node-suspend-results/verification.json`。这验证宿主生命周期接口，
不等同于所有浏览器在真实后台标签页中的节流策略或后台持续播放保证。另有完全不含
Godot 文件的普通 core Player 通过相同停止清理，报告：
`build/godot-web/ordinary-teardown-results/execution.json`。

当前 LibGodot Web 构建还通过真实 `WEBGL_lose_context` 故障注入：运行中的共享
WebGL2 context 确认进入 lost 状态，页面显示明确的“重启运行时”错误，宿主音频、
输入监听与 IME 服务幂等关闭；Godot reader 以 `pending=0`、`gpuErrors=0` 排空。
共享状态边界在 context 丢失后不再恢复 `null` 状态或继续图形调用。2／3／4 缓冲
均在动态动画帧后通过真实丢失测试，reader 分别完成 72／74／72 帧且全部
`pending=0`、`gpuErrors=0`。修复后的同一 WASM 随后重新通过完整 2／3／4 缓冲
正常矩阵：共 1,860 帧、36 张截图、330 个像素检查，覆盖暂停／恢复、缩放、控制器、
移除／重建和零 PCM 欠载。索引报告为
`build/godot-web/context-loss-matrix.json`。三缓冲恢复用例还在完成故障清理后重新加载
同一页面，确认新的 Godot 运行时再次启动并完整完成 620 帧，最后正常停止并关闭平台
服务。当前策略是经页面重载恢复，并非原地恢复 WebGL 设备。

复现当前故障注入（第一个参数必须是已打包的节点验收 Player）：

```sh
node Tools/Godot/tests/web_context_loss.mjs \
  build/godot-web/node-controller-teardown/player-3 \
  build/godot-web/context-loss-reload-recovery \
  --reload-recovery
```

Web 默认 sample 音频捷径不经过 Godot mixer，因此本桥接选择 stream＋Dummy PCM。
宿主目前使用既有 ScriptProcessor 路径。实际截图负载曾产生欠载；失败报告保留在
`node-metrics-3`／`node-audio-diagnostic-3`，不算通过。当前 Web 在 window 线程按需
混音，不启用预填充或额外 lookahead；原生平台后台队列目标维持4,096帧。矩阵保持零欠载标准；
这项缓冲增加延迟，**不代表低延迟或主线程性能通过**。SDK主线程阻塞与现有
ScriptProcessor弃用诊断仍保留。真实中文输入法候选窗／组合 UI、完整浏览器覆盖、
导入资源／更广泛项目和发布包验收仍未完成。

PCK单独复现：复制已构建的 Player到独立目录，运行
`prepare_node_game.py --package <目录> --buffers 3 --pack`，再运行
`run_node.cjs <目录> <结果目录>` 与 `verify_node.py <结果目录> --buffers 3`。
浏览器驱动先写 execution.json；只有独立像素／GPU／PCM校验通过才写 verification.json。


### Web 真实 DOM 输入回归

在上述诊断版 Player 构建完成后，复制到独立目录并运行：

```sh
cp -R build/godot-web/dora-player build/godot-web/dom-player
python3 Tools/Godot/tests/web/prepare_dom_game.py
DORA_DOM_HEADED=1 node Tools/Godot/tests/web/run_dom_input.cjs \
  build/godot-web/dom-player build/godot-web/dom-input-acceptance
```

需要 Playwright 与已安装的 Chrome；可通过 `DORA_PLAYWRIGHT_MODULE` 或 `NODE_PATH`
指定模块。在 macOS 上可见窗口测试会激活它自己的 Chrome 进程，切换到 Finder 后再
返回，以产生真实 OS 失焦；Playwright 的人工焦点保持在导航完成后关闭。

`build/godot-web/dom-input-auto-ime-headless-2/verification.json` 的 19 项检查通过：真实鼠标
左右键、触摸、旋转／缩放／平移节点后的坐标、A 键状态、Shift／Ctrl、带 Shift 的
鼠标事件、ASCII 和 Unicode 提交文本，以及失焦时释放仍按住的键与鼠标。浏览器
受信任的 `input` 事件提交“中文”，Godot 收到码点 20013／25991。原始 DOM 的 `isTrusted`
事件与实际 Godot 日志共同验证；未直接调用 SDL 或 Godot 输入接口。报告保存五个
宿主／运行库／清单文件的哈希。Godot `LineEdit` 通过自定义 DisplayServer 的版本化
IME 状态扩展自动启用／释放 Dora 隐藏文本控件，并把光标位置投影到窗口坐标
`(404, 290)`；不再需要 Lua 侧显式 `attachIME`。Web 平台按 UTF-8 码点边界拆分提交
文本。该检查仍不代表真实中文输入法候选窗／组合更新 UI 已完成。

本轮修复 Dora 已归一化鼠标编号被重复交换、自动输入丢失修饰键和双侧修饰键聚合，
并防止页面在引擎 main 初始化前失焦时进入原生清理接口。焦点通知桥接本身正常。
测试期间的静音音频流在切换 OS 焦点时记录 12,288 帧欠载，因此该报告仅接受输入，
不接受后台音频连续性。更新后另跑三缓冲图形／PCM 回归：620 控制帧、12 PNG、
110 颜色采样与双声道频率检查通过，GPU 错误和欠载均为零；报告位于
`build/godot-web/node-auto-ime-regression/verification.json`。公共输入修改后的
macOS Metal 原生节点也重新执行了完整三缓冲回归：720 帧、9 张截图、27 组别名
条码、两个音频生命周期和 739 个完成的 GPU 生产帧全部通过，GPU 错误及音频欠载
均为零；报告位于 `build/godot-runtime/node-auto-ime-macos/verification.json`。
该轮未重跑所有原生平台的 GPU 测试。

初始化前失焦保护也在全新的普通 core Debug 构建中通过真实 Chrome 启动／停止；
该包的清单和文件树均不包含 Godot 运行库，浏览器错误为空。报告位于
`build/godot-web/ordinary-final-results/execution.json`。

Unicode 输入改动后的实际 Web 三缓冲节点回归也通过 620 帧、12 张截图、110 个颜色
采样、440／660 Hz 和零 GPU 错误／欠载；报告：
`build/godot-web/node-unicode-regression-3/verification.json`。同一结构改动在 macOS
Metal 完整节点回归中通过，报告：
`build/godot-runtime/node-ime-structure-macos/verification.json`。

`user://` 回归在同一真实 Chrome 源上运行两个完整页面、Dora 和 Godot WASM 生命周期：
首轮写入计数 1，第二轮从 IndexedDB 恢复后写入 2；两轮 GPU 队列均排空且音频欠载为
零。报告位于 `build/godot-web/persistence-autopersist-results/verification.json`。持久化
改动后的三缓冲节点回归仍通过 620 帧、12 张截图、110 个颜色采样、440／660 Hz 和
零欠载，报告位于 `build/godot-web/node-persistence-regression-3/verification.json`。
