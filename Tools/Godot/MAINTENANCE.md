# Godot vendor 与 xmake 维护指南

更新：2026-11-04。当前完成状态以 [TRACKING.md](TRACKING.md) 为准，实际测试命令见 [README.md](README.md)，1.0支持范围和候选包缺口见 [RELEASE_1_0.md](RELEASE_1_0.md)。本页规定源码更新、构建、默认组件包和排障流程，不代替运行验收报告。

## 源码与构建入口

Dora 1.10.0默认构建完整LibGodot组件，详见[默认正式组件](README.md#默认正式组件dora-1100)。`Tools/Godot/build_component.lua`负责模式/架构/后端匹配及部署，沿用下表的独立原生xmake构建器；不会静默取用Debug库满足Release。macOS默认arm64、Windows默认x64/WGL；iOS门槛和既有动态验收缺口保持不变。Godot的三方依赖仍独立维护，不新增共享库方案。

Godot 完整源码位于 `Source/3rdParty/Godot`，不是 submodule。固定版本与导入来源见 [UPSTREAM.json](../../Source/3rdParty/Godot/UPSTREAM.json)；该文件描述上游导入基线，不是当前带 Dora 修改的整棵源码树摘要。桥接实现位于其中的 `modules/dora_bridge`，宿主实现和协议位于 `Source/Godot`。

`prepare.lua`、`prepare_android.lua`、`prepare_ios.lua`、`prepare_web.lua` 目前是只读检查入口，不再下载或给源码打补丁。`vendor_source.lua` 检查固定来源、关键修改标记及双端协议头一致性；它不是完整源码完整性校验。需要证明构建不改源码时，应分别保存构建前后所有源码文件的清单和哈希。

完整来源与当前Dora差异另由 [源码审计工具](https://github.com/IppClub/Dora-Example/blob/master/Test/Godot/audit_vendor_provenance.py) 和 [登记清单](vendor/SOURCE_DELTA.json) 校验；[复查及更新流程](vendor/README.md)说明固定归档/上游Git树/首次导入提交、Git换行政策和零fuzz补丁重建。它是独立维护审计，不给普通构建新增下载或历史依赖。当前57个修改文件、55个新增文件均显式登记；后续源码修改需同步该清单并重验，不能仅靠标记检查。该范围包含登记及未忽略源码，忽略的SCons缓存和构建产物另行处理。

从仓库根目录构建。先准备 xmake 3.x 和平台工具链；自有工具通过 `xmake lua` 执行。Android 另需 SDK/NDK 29.0.14206865，Web 使用 Dora 管理的 Emscripten；Emscripten 等三方工具内部的 Python 保持不变。不要用 PATH 中另一个 SDK 的版本代替实际编译器证据。

代码生成器在 Lua 中展开上游静态文本模板，不执行上游 `.py`；Deflate 压缩使用 `gzip` 或 `7z`，ZIP 解包使用 xmake 的平台归档工具。可独立运行 `xmake lua Tools/Godot/generate_xmake_sources.lua --output=/path/to/generated`，也可在全新目录生成 `xmake lua Tools/Godot/generate_api_docs.lua --output=/path/to/docs`。重复生成保留未变化文件的时间戳。外部 Dora-Example 测试可继续使用 Python；测试中的旧 Python API 适配层仅传递 JSON 到 Lua，不实现构建逻辑。

| 配置 | 当前入口 | 默认构建器与范围 |
| --- | --- | --- |
| macOS arm64 Metal | `DORA_GODOT_TARGET=template_release Tools/Godot/build_runtime.sh` | Debug / Release 均为原生 xmake |
| Linux ARM64/x86_64 EGL | Linux 上运行 `DORA_GODOT_TARGET=template_release Tools/Godot/build_linux_runtime.sh` | 原生 xmake；`DORA_GODOT_LINUX_ARCH` 选架构，支持 Debug / Release |
| Windows x64/ARM64 WGL | `xmake lua Tools/Godot/build_windows_runtime.lua --target template_release --backend WGL --arch x86_64` | 原生 xmake / MinGW；ARM64 用 `--arch arm64` 及对应 SDK/prefix |
| Windows x64/ARM64 D3D12 | 同一脚本指定 `--backend D3D12 --target template_release --mesa-libs /path/to/sdk` | 原生 xmake；NIR SDK 须匹配架构及 GNU/LLVM 工具链；本轮不做动态 GPU 验收 |
| Android ARM64/ARM32/x86_64 EGL | `xmake lua Tools/Godot/build_android_runtime.lua --sdk /path/to/android-sdk --arch arm64 --target template_release` | 原生 xmake，API28；架构参数为 arm64 / arm32 / x86_64 |
| Web wasm32 | `xmake lua Tools/Godot/build_web_runtime.lua --target template_release` | 原生 xmake 与 Dora 管理的 Emscripten，支持 Debug / Release |
| iOS ARM64 Metal | `xmake lua Tools/Godot/build_ios_runtime.lua --device simulator --target template_release --build-dir /path/to/fresh-build` | 原生 xmake；随后以同一 device/build-dir 运行 `link_ios_runtime.lua`；设备构建选 device，支持 Debug / Release |

Python 构建入口可用 `--build-dir` 隔离报告/封包，是否支持其他参数以各脚本 `--help` 为准。Linux、Android、Windows、Web、iOS入口默认关闭编译缓存，避免共享目录中的大型预处理文件I/O；已完成对象仍可按依赖增量复用。独立报告目录不等于独立编译目录：部分入口共享仓库内固定对象路径，同平台同架构配置切换时不要并行写同一输出树。

原生目标定义、平台源码清单和 profile 位于 [Projects/xmake/godot](../../Projects/xmake/godot)。对象、生成代码和库位于 `build/godot-xmake` 的平台目录，Debug 有独立 `debug/` 子目录并启用 `DEBUG_ENABLED`、调试符号及关闭优化；Release 启用优化与 `NDEBUG`。默认 target 为 `template_debug`，生产构建须显式选 `template_release`。宿主 Dora 与 LibGodot 是两项独立构建。

六个平台运行库脚本只调用 xmake，不安装、导入或回退到 SCons；`--builder auto` 是 xmake 的兼容别名，`--builder scons` / `--scons` 已删除。上游 `SConstruct`、`SCsub`、`methods.py` 等完整保留供源码维护，但不属于 Dora 构建入口。旧实验启动器 `$DORA_TEST_REPO/Test/LibGodotMetalProbe/run.sh` 转发到受维护的 macOS 测试入口。

2026-11-04：上述13种架构/后端配置均已串行通过 Debug/Release 编译、链接与封包，共26项，另通过10项构建系统回归。构建通过不关闭动态验收缺口；本次详情暂存 `build/godot-xmake-only-v1/PROGRESS-DRAFT.md`，总验收为 `FINAL-VERIFICATION.json`。

脚本启用 `--dora_godot_standalone=y`，只载入 LibGodot 图，避免安装 Dora 的 Go/Rust 工具；完整 Dora 构建保留原有工具依赖。PCRE2 16/32、JPEG 8/12 用四个原生 object 目标对同一上游 C 文件分别设置宏，直接合并到 LibGodot，不生成 wrapper C 文件，也不增加独立动态库。Android ARM32 按上游限制关闭 raycast/Embree 模块，其他架构保持原标准模块。

Android Java/AAR 默认从 vendor 构建，`--builder maven` 仅为显式参考，与原生运行库 xmake 入口无关。构建通过不等于对应架构的 ABI、GPU 或真机验收，覆盖边界见跟踪清单与历史报告。

升级后导出全部十一个编译子目标（七个子系统及四个 codec object 目标）的编译数据库，用 [通用 include 审计](https://github.com/IppClub/Dora-Example/blob/master/Test/Godot/audit_compile_include_order.py) 核对源码数量和逐文件顺序。Android 使用 [Android 入口](https://github.com/IppClub/Dora-Example/blob/master/Test/Godot/audit_android_include_order.py)，Web 使用 [Web 入口](https://github.com/IppClub/Dora-Example/blob/master/Test/Godot/audit_web_include_order.py)：先以实际编译器证明特定 SDK include 的规范化不改变有效搜索，再执行通用严格检查，不手动放宽其他目录。审计参数见各脚本 `--help`；通过不代表完整编译选项、ABI 或动态渲染验收。

## 可选包与部署

先保存完整运行库包，再由平台打包流程消费；不要只复制一个库而遗漏许可和依赖。所有包都有 `manifest.json`，包身份为 `dora-godot-runtime` v1，记录 Godot 版本、bridge ABI、固定来源及文件摘要。不同平台的元数据字段并不完全相同。

| 平台 | 包的关键内容 | 宿主默认加载位置 |
| --- | --- | --- |
| macOS | `libdora_godot.dylib`、Godot 两份许可/通知、manifest | Dora 资产目录中的同名库 |
| Linux | `libdora_godot.so`、Godot 两份许可/通知、manifest | Dora 资产目录中的同名库 |
| Windows | `dora_godot.dll`、Godot 两份许可/通知、manifest；D3D12 另附 NIR 通知与 provenance | Dora 资产目录中的同名 DLL；桥接后端须匹配 |
| Android | `libgodot_android.so`、`jni/<ABI>/` 中的运行库和 `libc++_shared.so`、许可和 manifest；Java AAR 单独构建 | Android 本机库加载；Gradle 消费 JNI 包及 Java AAR |
| iOS | `DoraGodot.framework`（含库、Info.plist、Godot 许可与签名）及 manifest | 应用 `Frameworks/DoraGodot.framework/DoraGodot` |
| Web | `dora-godot.js`、`dora-godot.wasm`、`shared_gl.mjs`、`runtime_bridge.mjs`、LICENSE/COPYRIGHT/AUTHORS 及 manifest | Web 打包入口及 JS 初始化配置；不是桌面动态库加载 |

桌面/移动端原生加载器支持 `DORA_GODOT_LIBRARY` 覆盖路径，仅用于明确指定运行库；普通随包验收应取消该覆盖，验证默认查找。Android Gradle 通过 `dora.godot.runtimePackage` 和 `dora.godot.javaAar` 选包，默认启用Godot并构建vendor Java及匹配ABI原生库；只有显式`dora.godot=false`才裁剪Godot。

```sh
xmake lua Tools/Godot/verify_package.lua /absolute/path/to/package
```

校验器核对清单身份、文件和许可摘要；它不加载库，不证明 ABI、签名或 GPU 工作。平台封包完成后执行相应 ABI 与动态测试。桌面用 `tests/verify_desktop_package.py` 检查随包文件，并以普通宿主验证随包加载及缺库退化，命令见 README。Android 验证最终 APK，iOS 验证实际 framework 和应用，Web 验证实际部署响应头、MIME 和浏览器行为。

签名、更换 JNI/STL 或任何包内文件都会影响摘要，应在最终签名/依赖复制后用平台封包流程生成清单并复核。不能靠手改版本或删除摘要项让旧包通过。ad-hoc 签名、模拟器成功不等于正式签名、公证、安装升级或真实设备验收。

## 许可证与依赖共享

保留 Godot 的 `LICENSE.txt`、`COPYRIGHT.txt` 以及包声明的所有通知。Android Gradle 按 manifest 校验并复制通知到 `GodotRuntimeNotices`，不得覆盖 Dora 原有许可。D3D12 SDK 必须通过固定410文件校验；通知复现与剩余许可继承核对见 [NIR 材料](licenses/nir-25.3.1-1/README.md)。不要用 NIR 包装仓库的许可代替 Mesa 等组件许可。

[依赖说明](DEPENDENCIES.md)与[隔离规则](DEPENDENCY_ISOLATION.md)规定当前完整独立LibGodot模式。各引擎保留自己的依赖实现、来源登记及包内许可通知，不再开展跨引擎第三方库共享审计或试点。NIR剩余许可仅随D3D12恢复验收时处理，见NIR-LICENSE-01。

## 上游升级流程

1. 先封存当前源码状态、各平台工具链/flags、运行库包、摘要及运行报告；保留可复现的旧基线。上游导入与 Dora 修改分开提交，避免混淆来源。
2. 选择固定上游 commit/ref，从官方归档取得源码并核对摘要；更新 `UPSTREAM.json`。完整保留上游文件与许可证，核对 thirdparty 版本、补丁和通知差异。
3. 对照旧上游基线与当前 vendor 差异，重新应用桥接与平台修改，逐项记录冲突和处理；同步 `Source/Godot` 与 `modules/dora_bridge` 的协议头及导出表。
4. 同步 `vendor_source.lua`、`audit_vendor_provenance.py`、`vendor/SOURCE_DELTA.json`、`package_manifest.lua`、`package_runtime.lua`、平台构建脚本、profile 中的固定身份与哈希。只改 `UPSTREAM.json` 不足以完成升级；检查 tests/CI/许可证材料中的旧版本引用，不能绕过固定身份校验。
5. 使用封存的同配置编译数据库或在独立上游 checkout 建立参考。Dora 不提供 SCons 构建入口。用 `import_compile_db.lua`（macOS 可用专用 importer）更新源码清单及原生变体目标，核对架构、工具链实参、宏、SIMD、生成文件与逐文件 include 顺序。此过程会写维护文件，先检查输出路径和差异。
6. 更新生成 profile 与 `generate_xmake_sources.lua`，对比代码生成结果。运行相应 codegen、清单和 include 顺序检查；干净原生构建不得读取旧 SCons 输出或写 vendor。
7. 逐平台检查最终导出/依赖、封包/许可/ABI，并执行跟踪页规定的2/3/4缓冲、音频/输入、生命周期与未修改真实项目验收。软件渲染、VM、模拟器、物理 GPU 分开记录。
8. 所有支持配置保持 xmake 唯一入口；尚未通过动态验收的项目继续明确留待办，不添加 SCons 回退。更新跟踪清单，过程、失败和证据按约定另存；本次暂存 `build/godot-xmake-only-v1/PROGRESS-DRAFT.md`，不重建已移除的 history。签名/发布仍按实际授权执行。

不能直接对带补丁 vendor 运行上游更新脚本覆盖文件。SCons 对照会生成源码旁文件，必须使用独立 checkout；Dora 入口不原地生成；如手工上游参考构建产生残留，先保存源码清单与生成物，恢复干净输入后再做原生验收。不要直接清空整个 `build`，其中可能保存唯一证据、补丁或 VM 备份。

## CI轻量构建

仅运行Lua队列契约时，用独立配置加载 `dora_host_tools_only` 图，再构建 `dora-tolua`。该图只包含bundled Lua宿主及绑定生成器，不解析Dora引擎的Rust/Go包；不要在普通工程配置上仅指定target就认为依赖图已经隔离。CI步骤使用独立 `XMAKE_CONFIGDIR`，不改变常规引擎配置。

原生变体增量夹具需要两轮归档产物的时间戳位于不同的秒级tick：xmake 3.1.1可能把同秒内重编译的对象视为未改变，跳过重新归档。夹具等待时间戳边界，仍执行增量构建及16→160实际值检查；不使用强制重编译替代增量验证。失败时检查 `proof-*.log`、`build-*.log` 和保留的归档文件。

## 运行时与项目边界

当前是进程内 LibGodot、一次活动运行时。按最新用户决定，保留同一 LibGodot 实现项目级卸载和切换；不执行进程内 LibGodot 销毁/重初始化，也不继续 Worker 进程方案。macOS Metal、Linux EGL、Windows x64 WGL、Android EGL、WebGL2 默认采用项目卸载协议；其他后端仍按既有同工程协议执行。

macOS Metal、Linux EGL、Windows x64 WGL、Android EGL、WebGL2 已默认启用项目切换，清理场景树及项目状态并重新创建场景树；卸载通知及串行控制器已完成；树外状态、长期资源稳定性与其他平台仍有缺口。使用方式、验收和边界统一见 [PROJECT_SWITCH.md](PROJECT_SWITCH.md)，不能据节点销毁或有界测试通过声称任意工程已完整隔离。

Godot C#/Mono 关闭不影响 Dora 原有 C#；不要通过删掉 Dora 的 C# 绑定来缩小 Godot 包。Dora Apple2 / Godot Apple4 的能力门槛保留，不把 Apple2 模拟器安全拒绝写作 Apple4 渲染通过。

## 排障与证据

| 症状 | 下一步检查 |
| --- | --- |
| vendor 检查失败 | 固定来源、桥接头双端是否一致、关键补丁标记；检查实际工作区差异，不以重复 prepare 掩盖缺失补丁 |
| 源码旁有 `.gen.*`、`.sconsign*`、bin/obj | 停止混用原生/SCons 输入；先归档、核对，再将生成物移出源码树，保留未跟踪的真实源码 |
| 生成头缺失或选错平台 | profile、生成根目录、平台/架构、include 优先级；通过 `audit_compile_include_order.py` 与实际编译数据库对照 |
| 旧 SDK 或编译器被选中 | 检查 commands/toolchain/compilation 报告中的真实可执行路径和版本；Android 核对固定 NDK/API，Web 核对 Dora 管理的 Emscripten |
| 库缺失、ABI 或后端拒绝 | 先验证 manifest，再查默认路径/覆盖变量、目标架构、协议版本与宿主 WGL/D3D12/Metal/EGL 选择；用普通 Dora 验证安全退化 |
| Windows WGL 在服务账户失败 | 在登录用户的交互会话运行 GPU 测试；SYSTEM 会话失败不能直接归因为 Godot 渲染实现 |
| WARP 成功但硬件未验收 | 核对日志中的实际 adapter 和 CPU fence；保留软件边界，物理 GPU 与纯 GPU fence 另做 |
| iOS 只得到 Apple4 能力拒绝 | 记录实际设备 family；不降低 Godot 门槛或把拒绝算正向共享。设备/模拟器 archive 不能互换执行 |
| Web trap、无画面、无音频 | 检查 JS/WASM/bridge 是否同包、部署头/MIME、线程/heap/context、用户音频激活；诊断包与生产候选分开 |
| VM Tools 未就绪或控制命令超时 | 核实精确 VM UUID、宿主进程、截图与实际 I/O；观察超时不等于终止，避免重复重启活跃编译或快照 |

每项证据记录源码/宿主/运行库摘要、命令、工具链、环境、原始日志、截图和明确未覆盖范围。新实验写新目录；失败报告保留，修复后另建报告，不覆盖成成功。测试结束后关闭任务启动的服务、调度任务、模拟器/VM，保留产物与证据；大目录和虚拟机删除需按用户授权范围处理。

测试与独立审计程序由 Dora-Example 的 `Test/Godot` 维护；引擎 CI 先解析测试仓库的固定 revision。测试迁移或新增依赖须先发布 Dora-Example，再发布引擎的调用变更。正常运行库构建只依赖本仓库生产工具，包/SDK完整性校验不依赖测试仓库。

### Android 模拟器 binary 缓存边界

只把真正的`glProgramBinary`恢复成功计为暖缓存通过。按用户决定，不增加磁盘GLSL源码缓存，不关闭缓存、过滤告警或忽略失败的link状态。当前Emulator37.1.11／API35／SwiftShader的独立GLES探针能完整导出binary，但同/新context恢复均报告false，源码重编译像素正确；此问题保留为模拟器环境限制。

上游[gfxstream特性说明](https://android.googlesource.com/platform/hardware/google/gfxstream/+/refs/heads/emu-main-dev/host/features/include/gfxstream/host/features.h)解释了`GlProgramBinaryLinkStatus`：为了兼容旧guest的`samplerExternalOES`编码，host正确的binary链接状态更新默认受特性保护。本机`-feature GlProgramBinaryLinkStatus`被明确拒绝，不能把该gfxstream特性当作可用的普通模拟器CLI开关，也不能绕过失败继续查uniform。

`ShaderGLES3::_save_to_cache`现接收`glGetProgramBinary`实际返回长度，只持久化有效字节；容量与返回长度不同不再写入未返回的尾部。此修复通过生产方法CPU边界/负向控制测试，不宣称修复模拟器状态返回问题。最小冷/暖配对使用Dora-Example的`tests/android/run_warm_cache.py`，同一普通Release APK、三缓冲、严格告警检查、缓存哈希逐项一致；模拟器证据不替代物理驱动支持。
