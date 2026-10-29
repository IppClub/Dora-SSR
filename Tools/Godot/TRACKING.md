# Godot / Dora 整合 1.0 清单

更新：2026-10-29。当前目标：冻结已有能力，完成修复与交付闭环，不再扩展功能。
使用方法见 [README.md](README.md)；完整旧跟踪文档见 [历史归档](history/2026-10-29-pre-1.0/TRACKING.md)，详细实验和失败记录保留在 [PLAN.md](PLAN.md)。本页仅维护决策、已完成项和待完成项。

## 1.0 范围（已确定）

- 平台：macOS、Windows、Linux、Web、Android；明确区分原生设备、虚拟机、模拟器与软件渲染的验证范围。
- iOS：保留 Dora Apple2 / Godot Apple4 能力查询和安全拒绝；Apple4+ 正向共享暂不列入 1.0 支持承诺。
- 项目：固定 Godot 4.6 与版本化桥接 ABI，GDScript 项目，目录及已验证的 PCK 加载形式。
- 运行边界：单运行时、单项目、单活动 GodotNode；可保留多个 Sprite 纹理别名。运行库驻留至进程退出，不承诺切换不同项目或最终 shutdown 后重新初始化。
- 功能：动态 GPU 画面共享，2/3/4 缓冲，暂停/恢复、场景重启、节点重建、异步 resize/cancel、基础输入、宿主 PCM 音频。
- 语言：Lua/Teal/TypeScript、Rust、Wa。**移除 GodotNode 的 C# 绑定与专用测试入口；保留 Dora 原有 C# 功能。** 不引入隔离的 C# 生命周期方案；Godot .NET/Mono 项目脚本也不支持。
- 恢复策略：Web context loss 已验证安全停止与页面重载恢复；原地设备恢复不在 1.0 承诺内。
- 硬件覆盖按实测标注；新增硬件矩阵不自动阻塞受限范围的 RC，未测环境不宣称通过。

## 已完成

- [x] Godot 进程内嵌入、版本化 C ABI、符号隔离；Metal/EGL/WGL/WebGL2 纹理共享与多缓冲同步。
- [x] 动画、暂停/恢复、重启、节点移除重建、resize/cancel、纹理别名、竞争节点拒绝。
- [x] 目录与导入资源 PCK；主场景、SceneTree、autoload 语义。基础键鼠/文本/触摸、控制器事件和 PCM 音频已有测试。
- [x] macOS 原生 Metal：优化 Release、多缓冲、38.36 分钟/216720 帧耐久、100 轮、普通应用随包/缺库及活动退出。
- [x] Linux：ARM64 VM virgl/llvmpipe 与原生 x86_64 CI；Debug/普通优化 Release、多缓冲、100 轮、故障恢复、项目边界、随包/缺库和退出。非物理显卡验收。
- [x] Windows：ARM64 VM/x64 WGL；动态共享、输入/音频、普通 Release 多缓冲活动/启动中退出、随包/缺库。非物理 x64 显卡验收。
- [x] Android：API35 ARM64 模拟器硬件转换后端，优化代码的开发签名/可调试测试 APK；2/3/4 共3000帧/45图、IME提交、Home/恢复及清理。非正式发布包或真机验收。
- [x] Web：Chromium/Firefox/Playwright WebKit 多缓冲与 PCM；真实桌面 Safari 2/3/4 共1860控制步/36图；context loss 停止和重载恢复。
- [x] 小型3D glTF双通道动画/空间Shader：macOS、Windows、Linux普通宿主通过，共18图，固定三缓冲。
- [x] iOS Apple2 模拟器：普通 Dora 180帧/2图；Godot Apple4 能力查询和安全拒绝。simulator/device运行库构建与包清单已有验证。
- [x] Lua/Teal/TS 与 Rust/Wa 接口、生成入口；Rust/Wa GPU和异步错误反馈已有实测；Wa Emit及Sprite转换注册修复已进入 PR。
- [x] 可选运行库 v1 清单、来源/版本/文件/许可哈希校验与包校验正反例。
- [x] PR #159 的9297c4b本地保存终态：12工作流全部success；不能替代后续修改的自身CI。
- [x] C# GodotNode 声明、托管类、类型注册和专用测试撤下；原始文件与实验记录归档。保留SDK和隔离重新生成的SDK均零警告/错误编译；Dora通用C#生成器修复和现有功能保留。
- [x] 9297c4b Linux产物审计：22报告、230源文件、3宿主/4运行库副本与379验收图核对，8项离线复核通过。
- [x] 本轮CPU协议回归通过：ABI、多缓冲所有权、音频队列、GPU读者记账、着色器边界和Web队列关闭；不增加GPU运行验收。

- [x] **FFI-01｜本地验收完成：失败模块对象所有权。** 按Wasm实例回收导出Object引用；旧宿主4对象泄漏与修复后0的对照、重复retain/部分release、真实Wa异常和独立Wasm trap通过。新运行库下Rust/Wa共2000帧/30图正常回归通过。Metal嵌入后端固定lazy着色器加载，避开实测的异步编译退出崩溃；跨平台新提交回归归CI-01。非Object类FFI堆分配不作全面无泄漏承诺。

- [x] **RC-01｜本地候选整理完成。** C# Godot支持撤下、通用空栈修复、失败模块Object引用回收、Metal加载策略、3D/故障测试及CI归入单一隔离索引候选；排除无关缓存/3D改动。冻结候选CPU协议、保留C# SDK编译与隔离生成检查通过；自身跨平台CI与最终包仍待验收。

## 1.0 待完成（按执行顺序）

- [ ] **AUDIO-01｜历史欠载排查。** Android SwiftShader既有3072/512帧欠载仍未解释。旧C#宿主512帧欠载保留历史，相关宿主已退出Godot范围；若复现于保留平台路径仍需修复。后续零欠载不算原因已解决。
- [ ] **EVIDENCE-01｜RC证据归档。** 9297c4b Linux来源/二进制审计已完成；剩余是最终RC新增改动的源码、宿主、运行库与校验器对应归档。C#原型仅作历史，不继续扩展其验收。
- [ ] **CI-01｜RC自身回归。** 新候选自身CI与针对改动的运行测试通过；复用已验证功能，不重复从零验证平台可行性。新增3D及Wasm所有权故障CI步骤待新提交执行。
- [ ] **PKG-01｜最终交付包。** 对齐RC源码/宿主/运行库/ABI/许可证；验收macOS、Windows、Linux的实际安装加载和退出。现有随包/缺库测试不等于最终安装包验收。
- [ ] **WEB-01｜Web发布交付。** 验收最终Release配置、部署资源/响应头、启动/输入/音频/退出及重载策略；既有含Godot矩阵主要使用core Debug宿主，不计最终Release交付。
- [ ] **ANDROID-01｜Android发布交付。** 验收普通非debuggable发布变体、R8/JNI保留规则、资源/库打包和安装运行；现有测试APK不计生产签名通过。真机覆盖依赖设备，单独标注。
- [ ] **DOC-01｜用户入口。** 将已有项目整理为可直接使用的2D/3D示例和操作步骤，说明运行库准备、语言/平台范围、错误处理、运行边界及已知限制。
- [ ] **RC-02｜冻结与验收。** 无已知范围内崩溃/死锁/同步或退出缺陷；最终包的核心、失败与生命周期回归通过，文档和证据对应同一RC。合并与公开发布另行执行。

## 后续版本 / 未覆盖边界

- [ ] Apple4+ iOS真机共享、多缓冲、生命周期、触摸和音频；当前无可用真机签名证据。
- [ ] 物理Windows/Linux显卡、Android手机/平板、移动浏览器及物理控制器兼容性矩阵。
- [ ] 完整IME composition/候选窗口、旋转/多点触控、锁屏/来电/复杂前后台、真实浏览器后台策略。
- [ ] device/context loss原地恢复、控制器热插拔/震动/多手柄。
- [ ] 大型项目、复杂资源与插件/GDExtension、更多PCK/导出形式；长期复杂混音与端到端延迟、统一GPU/内存/性能基线。
- [ ] 多运行时、多活动节点、不同项目切换、运行库卸载和最终关闭后重初始化。

## 关键证据入口

路径相对于仓库；build/本地证据不保证随源码分发。历史证据完整索引见归档。

- `build/godot-runtime/release-optimized-soak-216000/verification.json`
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
- `build/godot-runtime/rc1-scope-protocol/verification.json`
- `build/godot-ffi-owner-fix/verification.json`
