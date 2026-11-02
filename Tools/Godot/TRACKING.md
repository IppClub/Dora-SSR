# Godot / Dora vendor 与 xmake 迁移清单

更新：2026-11-02。当前目标：将固定版本的完整 Godot 源码纳入 Dora 仓库维护，把 LibGodot 构建逐平台迁移到 xmake，并为后续 Dora/Godot 第三方库复用建立可审计的构建基础。

使用方法见 [README.md](README.md)；截至 2026-11-01 的 1.0、多平台 direct-target、真实项目和 D3D12/WARP 进展已移入 [历史归档](history/2026-11-02-pre-vendor-xmake/TRACKING.md)。更早的原型记录见 [2026-10-29 归档](history/2026-10-29-pre-1.0/TRACKING.md)，详细实验和失败记录继续保留在 [PLAN.md](PLAN.md)。本页只维护当前决策、待办和验收门槛。

## 已确定的决策

- [x] 完整 vendor 固定的 Godot 4.6-stable 源码，不使用 submodule；目标目录为 `Source/3rdParty/Godot`。
- [x] Godot 上游版本、精确 commit、原始归档 SHA-256、导入日期、Dora 修改和许可证必须可追溯。
- [x] 当前 `prepare*.py` 对上游源码的修改将固化到 vendor 树；`modules/dora_bridge` 成为 vendor 源码的一部分，不再依赖构建时字符串改写。
- [x] 最终由 xmake 原生描述 Godot 的依赖图、源文件、编译选项和链接流程；Godot 必需的 Python 代码生成器可以继续由 xmake 调用。
- [x] SCons 在迁移期间只作为行为基线和对照构建，按平台通过等价验收后再移除，不能在首个阶段直接删除。
- [x] 不实现进程内 LibGodot 销毁后重新初始化。未来不同 Godot 工程的完整卸载与切换采用独立 Worker 进程边界。
- [x] 不恢复 Godot C# / Mono 支持；Dora 原有 C# 功能保持不变。
- [x] 第三方库共享必须逐库核对版本、补丁、编译宏、ABI、allocator、CRT、异常/RTTI、全局状态和许可证；vendor 与 xmake 统一本身不等于允许直接共用二进制。
- [x] 既有 1.0 能力和兼容回退不得因构建迁移而缩减；虚拟机、模拟器、软件渲染和物理设备证据继续分开标注。

## 当前已完成

- [x] 原 1.0 与后续 direct-target 进展完整归档，当前跟踪页与历史证据分离。
- [x] Godot 4.6-stable 源码规模已核对：13,842 个文件，其中 7,873 个 C/C++/Objective-C 源码及头文件；当前 Dora 公共准备脚本只直接修改少量上游文件并注入约 200 KB 的桥接模块。
- [x] Dora 主构建已统一使用 xmake 3.x，并已有 `Source/3rdParty` 内多库的源码级 xmake 构建模式，可作为 Godot 迁移的组织基础。

## 待完成：按顺序推进

- [x] **VENDOR-01｜导入上游源码。** 提交 `199c2c69c` 将 Godot 4.6-stable 完整源码导入 `Source/3rdParty/Godot`：上游 tag 对应 commit `89cea143987d564363e15d207438530651d943ac`，归档 SHA-256 为 `b451eaa1…57a0`。13,842 个上游路径逐项比较 Git mode/blob，缺失、额外和不一致均为 0；另加 `UPSTREAM.md/json` 两个来源文件，保留 MIT 许可证、完整第三方声明，并由既有 `Source/3rdParty/** linguist-vendored` 规则标记为 vendored。
- [x] **VENDOR-02｜固化 Dora 修改。** 提交 `58b79c23c`、`bef1e3912`、`be70d4912`、`34db79031`、`3233c3fc2`、`aafaa14cd` 分别固化通用 bridge/平台入口/渲染与音频输入、D3D12 WARP 兼容、嵌入稳定性修复、Android、iOS 和 Web 修改；`9f7c07ae1` 移除旧 `Tools/Godot/module` 副本并把构建及测试入口切到 vendor 树。四个 `prepare*.py` 兼容入口现为只读校验器，重复运行后 vendor 源码零变化；Web只读回归、17项包完整性测试和2/3/4缓冲CPU协议测试通过，未据此宣称平台编译或GPU验收。
- [ ] **BASELINE-01｜建立 SCons 对照基线。** 从未修改的 vendor 工作树构建现有 macOS、Linux、Windows、Android、Web、iOS 运行库，记录命令、工具链、编译宏、生成文件、导出符号、动态依赖、包体和现有运行回归结果。
- [ ] **XMAKE-01｜建立 Godot xmake 构建骨架。** 按 `core → drivers → servers → scene → modules → main/platform → dora_bridge` 组织 object/static targets；所有生成物写入构建目录，不污染 vendor 源码。
- [ ] **XMAKE-02｜迁移代码生成。** 由 xmake 驱动 Godot 版本、模块注册、ClassDB、扩展 API、Shader 和平台所需生成步骤；保留必要的上游 Python 生成器，并建立输入/输出依赖和增量重建测试。
- [ ] **XMAKE-03｜macOS Metal 首个平台。** 先完成 macOS arm64、`template_release`、Metal、无编辑器、无 Mono、无 Vulkan/OpenGL 的原生 xmake 构建；通过 ABI、导出符号、动态依赖、包清单以及现有 2/3/4 缓冲和真实项目回归后，才关闭该平台的 SCons 生产路径。
- [ ] **XMAKE-04｜Linux EGL/OpenGL。** 迁移 Linux x86_64/ARM64 构建，保持无 X11/Wayland 宿主窗口、direct-target、兼容 blit 回退、运行库打包和 AppImage 集成行为。
- [ ] **XMAKE-05｜Windows WGL/OpenGL。** 迁移 Windows x64 构建，保持符号隔离、WGL direct-target、输入/IME/音频和缺库安全回退；ARM64 Windows 不列入当前验收范围。
- [ ] **XMAKE-06｜Android EGL。** 迁移 Android arm64 JNI 运行库及 Java/AAR 配套生成，保持 nondebuggable/R8 Release、Activity 生命周期、触摸/IME、Home 恢复和 direct-target 行为。
- [ ] **XMAKE-07｜WebGL2/WASM。** 迁移 Web 静态运行库、Emscripten 链接和 JS glue，保持独立 Wasm heap、四浏览器矩阵、context loss 安全停止与页面重载恢复。
- [ ] **XMAKE-08｜iOS Metal。** 迁移 simulator/device 静态库与 framework 打包，保持 Dora Apple2 / Godot Apple4 能力门槛和安全拒绝；Apple4 正向 GPU 共享仍需相应设备证据。
- [ ] **XMAKE-09｜Windows D3D12。** 迁移保留的 D3D12 单后端构建；WARP CPU-fence 基线继续作为兼容性证据，物理 Windows GPU 和纯 GPU fence 仍单列验收。
- [ ] **DEPS-01｜第三方库清单与冲突审计。** 生成 Dora、Godot 双方第三方库的版本、补丁、特性、许可证、符号和链接形态矩阵，先识别重复项，不在审计前改变运行库归属。
- [ ] **DEPS-02｜低风险源码复用。** 优先评估纯 C、无跨边界对象所有权的库；每次只迁移一个库，分别验证静态复用、动态复用、包体、性能和跨进程代码页收益。
- [ ] **DEPS-03｜高风险依赖隔离。** Godot 修改过的 bundled 库、暴露 C++ ABI、依赖特定 allocator/CRT 或含全局状态的库默认保持独立，除非有完整的双宿主回归和回退方案。
- [ ] **CLEANUP-01｜移除旧准备与 SCons 生产路径。** 所有目标平台完成 xmake 等价验收后，删除下载归档、运行时源码改写和 SCons 生产入口；保留必要的上游同步工具、来源审计和历史复现说明。
- [ ] **DOC-01｜更新用户和维护者文档。** 更新构建命令、可选运行库布局、源码与许可证说明、上游升级流程、第三方共享政策、Worker 边界以及故障排查入口。

## 每个平台的完成门槛

- xmake 从干净 checkout 独立生成并构建，不读取旧 SCons 构建目录，也不修改 vendor 源码。
- 编译器、SDK、目标架构、Godot feature flags、Dora bridge ABI 和图形后端与对照基线一致。
- 导出符号、运行库动态依赖、许可证、manifest 和包内文件通过校验；二进制哈希不要求与 SCons 相同。
- 现有 ABI/协议测试，以及该平台 2/3/4 缓冲、动画、暂停/恢复、输入、音频、resize、节点重建、退出排空和缺库回退全部通过。
- 至少一个未经修改的真实 Godot 开源项目通过；测试设备和图形后端按实际证据标注。
- xmake 失败、可选运行库缺失或后端不匹配时，普通 Dora 功能保持安全可用。
- 本地验收完成后清理本任务启动的服务、模拟器和虚拟机，保留报告、截图、哈希及构建来源记录。

## 上游更新规则

1. 上游更新先以独立提交导入，不与 Dora 功能修改混合。
2. 更新来源清单、版本、commit、归档哈希、许可证和第三方声明差异。
3. 重新应用或合并 Dora 修改，明确记录冲突和已被上游吸收的修复。
4. SCons 尚未完全移除前先跑对照构建；之后以最近封存的 xmake 基线比较。
5. 全平台编译通过不等于迁移完成，仍须满足各平台实际运行与交付门槛。

## 当前不纳入本迁移的工作

- 进程内 LibGodot 重初始化。
- Godot C# / Mono 项目支持。
- 多个同时活动的 Godot Worker 或多个同时活动的 GodotNode。
- 未经审计的一次性全量第三方库合并。
- 以虚拟 GPU、软件渲染或模拟器结果替代物理设备兼容性声明。
