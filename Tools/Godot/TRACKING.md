# Godot / Dora 整合 1.0 清单

更新：2026-10-30。当前目标：冻结已有能力，完成修复与交付闭环，不再扩展功能。
使用方法见 [README.md](README.md)；完整旧跟踪文档见 [历史归档](history/2026-10-29-pre-1.0/TRACKING.md)，详细实验和失败记录保留在 [PLAN.md](PLAN.md)。本页仅维护决策、已完成项和待完成项。

当前草稿 [PR #159](https://github.com/IppClub/Dora-SSR/pull/159) 的1.0候选head为`f3764dfe8`、tree为`6cb093d88`。该head的12个工作流全部success；Godot Integration产物离线复核通过。正式Linux双架构基包均不再携带旧`libstdc++`/`libgcc_s`，装入同候选运行库后的最终AppImage已完成包校验、随包动态验收和缺库安全回退。1.0范围内任务已收口；PR仍为草稿，合并、签名/公证和公开发布不包含在本清单内。

## 1.0 范围（已确定）

- 平台：macOS Apple Silicon、Windows x64、Linux x86_64/ARM64、Web、Android arm64；明确区分原生设备、虚拟机、模拟器与软件渲染的验证范围。普通Dora自身更宽的架构范围不因此缩减。
- iOS：保留 Dora Apple2 / Godot Apple4 能力查询和安全拒绝；Apple4+ 正向共享暂不列入 1.0 支持承诺。
- 项目：固定 Godot 4.6 与版本化桥接 ABI，GDScript 项目，目录及已验证的 PCK 加载形式。
- 运行边界：单运行时、单项目、单活动 GodotNode；可保留多个 Sprite 纹理别名。运行库驻留至进程退出，不承诺切换不同项目或最终 shutdown 后重新初始化。
- 功能：动态 GPU 画面共享，2/3/4 缓冲，暂停/恢复、场景重启、节点重建、异步 resize/cancel、基础输入、宿主 PCM 音频。
- 语言：Lua/Teal/TypeScript、Rust、Wa。**移除 GodotNode 的 C# 绑定与专用测试入口；保留 Dora 原有 C# 功能。** 不引入隔离的 C# 生命周期方案；Godot .NET/Mono 项目脚本也不支持。
- 恢复策略：Web context loss 已验证安全停止与页面重载恢复；原地设备恢复不在 1.0 承诺内。
- 硬件覆盖按实测标注；新增硬件矩阵不自动阻塞受限范围的 RC，未测环境不宣称通过。
- 本地验收结束后清理任务进程并关闭本任务启动的虚拟机/模拟器，保留报告和截图，不关闭无法确认归属的实例。

## 已完成

- [x] Godot 进程内嵌入、版本化 C ABI、符号隔离；Metal/EGL/WGL/WebGL2 纹理共享与多缓冲同步。
- [x] 动画、暂停/恢复、重启、节点移除重建、resize/cancel、纹理别名、竞争节点拒绝。
- [x] 目录与导入资源 PCK；主场景、SceneTree、autoload 语义。基础键鼠/文本/触摸、控制器事件和 PCM 音频已有测试。
- [x] macOS Apple Silicon 原生 Metal：优化 Release、多缓冲、38.36 分钟/216720 帧耐久、100 轮、普通应用随包/缺库及活动退出。
- [x] Linux：ARM64 VM virgl/llvmpipe 与原生 x86_64 CI；Debug/普通优化 Release、多缓冲、100 轮、故障恢复、项目边界、随包/缺库和退出。最终修复副本双架构均完成动态随包/缺库验收；x86_64为QEMU用户态+llvmpipe，非物理显卡验收。
- [x] Windows：ARM64 VM/x64 WGL；动态共享、输入/音频、普通 Release 多缓冲活动/启动中退出、随包/缺库。非物理 x64 显卡验收。
- [x] Android：已有测试APK 2/3/4共3000帧/45图、IME/Home恢复；新增普通nondebuggable/R8 Release本地验收，SwiftShader 2/3/4与缺库共23图，Wasm trap后继续运行、PCM/GPU排空及Activity.finish完整退出通过。仅开发签名/模拟器，非生产签名或真机验收。
- [x] Web：core与默认dora-preset双Release（原生诊断关闭）原四浏览器2/3/4完整矩阵通过；最终`b3cb54d5b`又从同候选Web输入重建Godot 4.6运行库、core和默认preset。最终core在Chromium/Firefox/WebKit/原生Safari完成12项，默认preset在Chromium完成3项，合计9300控制帧/180图/1650项像素检查，GPU/PCM排空和退出清理通过。
- [x] 小型3D glTF双通道动画/空间Shader：macOS、Windows、Linux普通宿主通过，共18图，固定三缓冲。
- [x] iOS Apple2 模拟器：普通 Dora 180帧/2图；Godot Apple4 能力查询和安全拒绝。simulator/device运行库构建与包清单已有验证。
- [x] Lua/Teal/TS 与 Rust/Wa 接口、生成入口；Rust/Wa GPU和异步错误反馈已有实测；Wa Emit及Sprite转换注册修复已进入 PR。
- [x] 可选运行库 v1 清单、来源/版本/文件/许可哈希校验与包校验正反例。
- [x] PR #159 的9cfae189自身12工作流全部success；Linux产物249源文件、24报告、385图及10项离线复核通过。新增本地改动需下一候选自身CI。
- [x] C# GodotNode 声明、托管类、类型注册和专用测试撤下；原始文件与实验记录归档。保留SDK和隔离重新生成的SDK均零警告/错误编译；Dora通用C#生成器修复和现有功能保留。
- [x] 本轮CPU协议回归通过：ABI、多缓冲所有权、音频队列、GPU读者记账、着色器边界和Web队列关闭；不增加GPU运行验收。

- [x] **FFI-01｜本地验收完成：失败模块对象所有权。** 按Wasm实例回收导出Object引用；旧宿主4对象泄漏与修复后0的对照、重复retain/部分release、真实Wa异常和独立Wasm trap通过。新运行库下Rust/Wa共2000帧/30图正常回归通过。Metal嵌入后端固定lazy着色器加载，避开实测的异步编译退出崩溃；跨平台新提交回归归CI-01。非Object类FFI堆分配不作全面无泄漏承诺。

- [x] **RC-01｜候选整理完成。** C# Godot支持撤下、通用空栈修复、失败模块Object引用回收、Metal加载策略、3D/故障测试及CI归入单一隔离候选；排除无关缓存/3D改动。最终候选的协议、Dora C#保留能力、跨平台CI和交付形态均已验收。

- [x] **DOC-01｜用户入口完成（本地）。** 提供可编辑2D/3D GDScript项目、共享Lua入口、桌面准备脚本与快速开始；说明运行库、语言/平台范围、异步错误和运行边界。普通macOS实际验收13图，动画/暂停/恢复、2D指针与退出通过；其他平台执行与最终包仍由对应交付任务验收。

- [x] **AUDIO-01｜本地排查与修复完成。** 复现Android生产调度延迟叠加消费突发的512帧欠载；线程音频优先级配合6144帧有界预混音后，SwiftShader加三CPU负载的2/3/4共3000帧/45图零欠载，公开源码重建SO字节一致。macOS共享代码1000帧/15图回归通过，保持4096帧。Android预混音增加42.7ms；真机、最终APK和端到端延迟另验。历史旧日志无生产计时，保留其证据边界。

## 1.0 收口任务（已完成）

- [x] **EVIDENCE-01｜RC证据归档。** macOS、Windows、Web、Android、iOS能力拒绝及Linux双架构证据均已归档；新增`f3764dfe8` CI终态、Godot Integration产物、最终AppImage动态报告和统一`final-verification.json`。C#原型只保留历史记录。
- [x] **CI-01｜RC自身回归。** `f3764dfe8`的12个工作流全部completed/success；Godot Integration run `40882737627`和Linux AppImage run `40882737733`通过。Linux EGL产物24份验证报告全部passed、444张PNG保留、JSON无失败标记。Linux CI使用llvmpipe，不替代物理GPU验收。
- [x] **PKG-01｜最终交付包。** macOS arm64、Windows x64、Web、Android arm64及Linux ARM64/x86_64交付形态完成。最终Linux AppImage分别为`20e65d1a...6724`与`396dd667...f367`；宿主、运行库、ABI、manifest、许可和架构匹配，包内无`libstdc++`/`libgcc_s`。ARM64原生VM与x86_64 QEMU用户态均通过随包动画/GPU同步和缺库回退。Windows/Linux虚拟环境不替代物理显卡；本地签名不等于分发签名/公证。
- [x] **WEB-01｜Web发布交付。** 最终候选的Godot 4.6 `template_release`、core和默认dora-preset均从隔离源码重建，Web相关输入与`b3cb54d5b`零差异；core完成四浏览器2/3/4，默认preset完成Chromium 2/3/4。部署响应头/MIME、输入、音频、失败、退出和重载沿用同一生产路径既有回归；报告见`build/godot-rc1-final-candidate-v6/web-verification.json`。不包含移动浏览器、物理音频回环或端到端延迟承诺。
- [x] **ANDROID-01｜Android发布交付。** 从最终`b3cb54d5b`精确源码完整重建arm64普通nondebuggable/R8 Release；2/3/4缓冲与缺库共4项、23图全部通过，GPU 576/576、错误与PCM欠载均为0，包清单/许可/JNI一致。模拟器验收后已卸载应用并关闭，报告见`build/godot-rc1-final-candidate-v6/android-release-verification.json`。本地开发证书不计生产签名，真机覆盖单列。
- [x] **RC-02｜冻结与验收。** 无已知范围内崩溃、死锁、同步或退出缺陷；核心、失败和生命周期回归通过，文档与证据对应同一RC。候选保持PR草稿；合并与公开发布另行执行。

## 后续版本：已完成的实验基础

- [x] **实验｜Windows 多张共享纹理直接渲染。** 新增仅由`DORA_GODOT_GL_DIRECT=1`启用的WGL原型：逐帧把Godot最终render target的颜色附件切换到Dora 2/3/4缓冲槽，直接发布GPU fence，不调用`glBlitFramebuffer`。Windows VM动态矩阵三项各1000帧，动画、暂停/恢复、输入、节点移除重建、三次resize、纹理别名和PCM通过；GPU错误/待处理/音频欠载均为0，日志确认`blits=0`。默认复制路径不变；该实验未进入1.0候选，也未验证物理Windows显卡或性能收益。

- [x] **Windows 图形后端构建边界。** Godot和Dora桥接均保留WGL/D3D12源码，但每个宿主只编入一种桥接，启动后固定该图形后端，不同时创建两套运行时或支持热切换。WGL单后端宿主已完成2/3/4缓冲各1000帧动态回归；D3D12单后端x64宿主也已独立编译链接，配套运行库通过185项ABI检查和后端不匹配安全拒绝。物理机测试ZIP已生成并通过哈希、CRC、全新Windows解包与ABI复验；动态GPU验收仍受下一项硬件范围限制。

## 1.0 之后：全平台 direct-target 优化路线

以下任务严格按 `DIRECT-01 → DIRECT-02 → DIRECT-03 → DIRECT-04 → DIRECT-05 → DIRECT-06` 推进。目标是让 Godot 直接渲染到 Dora 管理的 2/3/4 缓冲纹理，消除稳态逐帧 GPU blit；它们不属于已冻结的 1.0 RC。

- [x] **DIRECT-01｜通用 GL direct-target 与 Linux EGL。** WGL 的颜色附件替换、发布 fence 和统计已改为按 GL transport 能力启用的共用实现；Linux desktop EGL 可直接借用 bgfx 创建的 RGBA8 render-target，Android/Web 仍显式拒绝并留待后续任务。Ubuntu ARM64/Parallels virgl 下 2/3/4 缓冲各完成 1000 帧，动画、暂停/恢复、输入、节点重建、三次 resize、纹理别名、PCM 与退出排空通过；全部 direct 会话记录 `blits=0`，GPU pending/error 与 PCM 欠载为 0。报告见 `build/godot-direct01-linux/direct-matrix/verification.json`；这是虚拟 GPU 证据，不冒充物理 Linux 显卡。
- [ ] **DIRECT-02｜Android EGL 真机。** 在 DIRECT-01 共用实现上接入 Android EGL，不维护独立复制算法；使用 arm64 物理手机或平板完成普通 nondebuggable Release 的 2/3/4 缓冲矩阵，覆盖动画、触摸/文本、暂停恢复、节点重建、resize/Activity 生命周期、纹理别名、PCM 与完整退出。要求 `blits=0`、GPU/PCM 排空且无错误；模拟器结果只作回归，不作为本项完成依据。
- [ ] **DIRECT-03｜WebGL2 direct-target。** 将同一 WebGL2 context 中的宿主 `WebGLTexture` 直接绑定为 Godot 最终颜色目标，保留两个 Wasm 模块的对象名映射和完整 GL 状态隔离；稳态不得 readback、upload 或 blit。完成 Chromium、Firefox、Playwright WebKit 与 macOS 原生 Safari 的 2/3/4 缓冲矩阵，并复验 context loss 安全停止、资源释放和页面重载恢复。
- [ ] **DIRECT-04｜Metal host-owned render targets。** 由 Dora/bgfx 创建具备 RenderTarget 与 ShaderRead 用途的 RGBA8 `MTLTexture`，Godot 导入后直接设为最终 render target；继续使用 `MTLSharedEvent` 完成生产/消费同步，移除稳态 Metal blit。先在 macOS Apple Silicon 完成 2/3/4 缓冲、resize、生命周期、别名、音频和耐久回归，再在 Apple4+ iPhone/iPad 真机完成同等 GPU 路径及触摸、前后台和音频验收；模拟器与能力拒绝不计正向真机通过。
- [ ] **DIRECT-05｜Windows D3D12 物理机与纯 GPU fence。** 保留已经独立编译的 D3D12 单后端和共享资源原型；先在原生 x64 Windows、同一支持 Shader Model 6 的物理 GPU 上完成 CPU fence 双缓冲的资源导入与动态画面验收。通过后实现 2/3/4 缓冲的 Godot→bgfx 生产 fence 与 bgfx→Godot 回收 fence，稳态消除 CPU 等待，并覆盖动画、输入、resize、节点重建、纹理别名、PCM、退出排空和后端不匹配拒绝。
- [ ] **DIRECT-06｜旧 blit 路径收口。** 全部前置平台验收完成后，按后端和驱动能力决定删除旧 blit，或将其保留为显式、可诊断的兼容回退。直接路径与回退路径都必须有独立能力判定、计数/日志和回归测试；不得静默降级。记录各平台相同场景的 GPU 时间、显存、延迟与稳定性对照，确认收益后再改变默认策略。

## 其他未覆盖边界

- [ ] 物理Linux显卡、移动浏览器及物理控制器兼容性矩阵。
- [ ] 完整IME composition/候选窗口、旋转/多点触控、锁屏/来电/复杂前后台、真实浏览器后台策略。
- [ ] device/context loss原地恢复、控制器热插拔/震动/多手柄。
- [ ] 大型项目、复杂资源与插件/GDExtension、更多PCK/导出形式；长期复杂混音与端到端延迟、统一GPU/内存/性能基线。
- [ ] 多运行时、多活动节点、不同项目切换、运行库卸载和最终关闭后重初始化。

## 关键证据入口

路径相对于仓库；build/本地证据不保证随源码分发。历史证据完整索引见归档。

- `build/godot-runtime/release-optimized-soak-216000/verification.json`
- `build/godot-direct01-linux/direct-matrix/verification.json`
- `build/godot-runtime/godot-remote-ci-9297c4b-terminal.json`
- `build/godot-remote-ci/9297c4b/linux-egl/report/godot-runtime/{ci-linux,ci-linux-release}/verification.json`
- `build/godot-windows/release-stop-completed/{verification,export-verification}.json`
- `build/godot-runtime/android-release-ime-window-matrix/verification.json`
- `build/godot-web/safari-dpi-matrix/verification.json`
- `build/godot-project-3d-platforms-v2/verification.json`
- `build/godot-bindings-async-error-evidence/verification.json`
- `build/godot-bindings-wa-sprite-cast-red-clean/node-wa/reproduction.json`
- `build/godot-rc1-no-csharp/scope-verification.json`
- `build/godot-remote-ci/9297c4b/linux-egl/download-verification.json`
- `build/godot-remote-ci/9cfae189/linux-egl/download-verification.json`
- `build/godot-remote-ci/480b3739d/linux-egl/download-verification.json`
- `build/godot-runtime/rc1-scope-protocol/verification.json`
- `build/godot-ffi-owner-fix/verification.json`
- `build/godot-rc1-candidate-final/{verification,publication,remote-initial}.json`
- `build/godot-user-examples/verification.json`
- `build/godot-audio-rc1-investigation/verification.json`
- `build/godot-rc1-delivery/android-release-verification.json`
- `build/godot-rc1-web-delivery/release-verification.json`
- `build/godot-rc1-web-delivery/preset-release-verification.json`
- `build/godot-rc1-final-candidate-v2/macos-package-layout-verification.json`
- `build/godot-rc1-final-candidate-v2/macos-zip-runtime-verification/verification.json`
- `build/godot-rc1-final-candidate-v4/linux-arm64-evidence/{package-verification,runtime-verification}.json`
- `build/godot-rc1-final-candidate-v4/linux-x86_64-evidence/{static-verification,verification}.json`
- `build/godot-rc1-final-candidate-v4/windows-x64-evidence/{static-verification,verification,provenance}.json`
- `build/godot-rc1-final-candidate-v5/{candidate,publication}.json`
- `build/godot-rc1-final-candidate-v5/macos-arm64-evidence/{provenance,package-verification,fresh-package-verification}.json`
- `build/godot-rc1-final-candidate-v5/windows-x64-evidence/{provenance,static-verification,ordinary-evidence/verification}.json`
- `build/godot-rc1-final-candidate-v6/{candidate,publication,web-verification}.json`
- `build/godot-rc1-final-candidate-v6/web-{core,preset}-*-matrix/verification.json`
- `build/godot-rc1-final-candidate-v6/android-release-verification.json`
- `build/godot-rc1-final-candidate-v6/linux-appimage-artifacts/ci-appimage-audit.json`
- `build/godot-rc1-final-candidate-v6/linux-appimage-artifacts/f376-ci-appimage-audit.json`
- `build/godot-remote-ci/f3764dfe8/linux-egl/runtime-package-verification.json`
- `build/godot-rc1-final-candidate-v6/linux-appimage-artifacts/f376-final-godot/verification.json`
- `build/godot-rc1-final-candidate-v6/linux-appimage-artifacts/f376-final-godot/evidence/{aarch-verification,x86-verification}/verification.json`
- `build/godot-rc1-final-candidate-v6/final-verification.json`
- `build/godot-rc1-final-candidate-v6/linux-appimage-artifacts/godot-enabled/aarch64/verification.json`
- `build/godot-rc1-final-candidate-v6/linux-appimage-artifacts/godot-enabled/x86_64/verification.json`
- `build/godot-direct-shared-prototype/verification.json`
- `build/godot-wgl-current/verification.json`
- `build/godot-d3d12-physical/verification.json`
