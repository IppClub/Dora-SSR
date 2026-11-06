# Godot vendor / xmake 迁移计划

更新：2026-11-06。1.0支持矩阵与最终交付缺口见 [RELEASE_1_0.md](RELEASE_1_0.md)。当前任务勾选以 [TRACKING.md](TRACKING.md) 为准；本页说明迁移顺序和交付门槛，不再追加实验流水。旧 history 目录已按用户整理移除，文中旧路径仅作历史标识；当前证据见对应 `build/` 目录，不恢复历史目录。

## 目标与约束

将固定版本 Godot 完整 vendor 到 `Source/3rdParty/Godot`，使用原生 xmake 管理源码、平台配置、生成器、编译、链接及封包，保留各自完整运行时及独立依赖。允许复用上游 Python 生成器；不以 xmake 包装 SCons 作为迁移完成。

保持固定上游版本（当前升级目标 4.7.2-stable）的来源、许可证与 Dora 修改可追溯；生成物和对象文件放在独立构建目录，不写入 vendor 源码。受支持配置统一为原生 xmake 唯一构建入口；保留上游构建文件及封存对照，不保留 Dora 的 SCons 安装/调用/回退路径。动态验收缺口独立跟踪。

产品范围保持：Godot 不含 C#/Mono，Dora 原有 C# 保留；Dora Apple2 / Godot Apple4；Windows 本轮验收 x64 WGL，D3D12 适配保留但按用户决定跳过本轮动态验收；不做进程内 LibGodot 重初始化；按最新决定保留一个进程内LibGodot，实现项目级卸载与切换，macOS Metal、Linux EGL、Windows x64 WGL、Android EGL和WebGL2默认开放，其他平台和兼容性缺口见 [PROJECT_SWITCH.md](PROJECT_SWITCH.md)。

依赖部署固定为完整独立LibGodot：移除第三方库共享开关、宿主提供端、转发层及启动握手，各引擎保留自己的依赖实现。共享实验和撤销任务见归档（`history/2026-11-03-library-sharing-removed/README.md`）。


## 既有 4.6 迁移阶段（历史基线）

| 阶段 | 工作与交付 | 当前状态 |
| --- | --- | --- |
| 1. 固定源码与构建基础 | 完整 vendor、来源与补丁审计、独立目标图、等价代码生成 | 已完成 VENDOR-01/02、XMAKE-01/02 |
| 2. 桌面生产迁移 | macOS Metal、Linux EGL、Windows x64 WGL；构建、封包、ABI、动态矩阵及真实项目 | macOS 已验收；Linux ARM64 VM 与当前x86_64新包均已验收；后者为QEMU/llvmpipe，并保留上游追赶计时契约与真实时间公开输入控制证据；Windows WGL 原迁移基线已验收，include/汇编修复后的新包已完成 WGL-REG-01/02 VM 回归；pending await 清理修复已在 WGL/macOS/Linux ARM64/x64/Android 验证，iOS清理回归、Web新包Safari/官方项目及GL直接目标CPU读回及公共RD改动的跨平台回归见开放清单 |
| 3. Android | arm64 EGL、JNI、Java/AAR 与 Release 封包，生命周期及 2/3/4 缓冲 | arm64 Release 已完成 XMAKE-06；最新GL读回修复库的2/3/4读回/resize、完整矩阵、普通宿主/缺库回退、官方项目及await冷安装回归已独立复核，限SwiftShader模拟器；暖缓存续验单列开放，三种架构的 Debug/Release 构建封包均已通过，见 XMAKE-ONLY-01 |
| 4. Web | WASM 静态库、Emscripten 与 JS glue，四类浏览器及 context loss | Release 已完成 XMAKE-07；Debug/Release 构建封包均已通过，见 XMAKE-ONLY-01 |
| 5. iOS | simulator/device、静态库及 framework、能力门槛与安全拒绝 | 当前登记源码 simulator/device 的 Debug/Release archive/framework 均已通过xmake重建，模拟器218项ABI/普通Dora/Apple4拒绝已重跑并独立复核；Apple4 正向渲染及运行态await仍未覆盖 |
| 6. D3D12（本轮跳过） | 保留单后端适配与构建对照，后续另行验收 | 原生 xmake 构建、ABI、WARP 矩阵及计时已有部分证据；官方项目仍崩溃，按用户决定不继续本轮验收，默认使用 xmake 构建，不标记动态验收完成 |
| 7. 独立依赖维护 | 保留上游依赖、来源登记与已有许可通知 | 共享综合审计已撤销；NIR-LICENSE-01随D3D12保留后续 |
| 8. 构建退场与文档 | 按已验收配置移除 SCons 生产路径，完善升级、复现、包布局与维护说明 | DOC-01、CLEANUP-01、XMAKE-ONLY-01 已完成：26项串行构建及10项构建系统回归通过；自有SCons入口/依赖移除，上游文件保留 |

## 当前升级的最小执行计划

2026-11-06：升级至固定 Godot **4.7.2-stable**，以 [TRACKING.md](TRACKING.md) 的 UPGRADE-47 清单为准。后面的 4.6 平台完成记录保留历史含义，不能当作新版的运行证据。

1. 固定官方归档、Git commit、完整许可证和 Dora 补丁差异；继续直接 xmake 构建，不恢复 SCons 依赖。
2. 先完成 macOS arm64 Metal：更新生成器、源清单和 metal-cpp 桥接，构建并验证新版运行包。
3. 唯一一组真实项目串行验收：Dodge 源码 → Squash PCK → Dodge 源码；分别使用 2/3/4 缓冲，检查动态画面、输入/PCM、零 blit、GPU 排空、卸载通知和同实例新场景树。失败只修复并复验受影响环节，通过即停止本平台。
macOS 上述 Release/真实项目最小验收已通过，证据见 `build/godot-4.7-macos/REPORT.md`；本平台不再加跑动态轮次。
Linux ARM64 EGL Release 同样已完成唯一一组 A→B→A（2/3/4 缓冲、9 图、484 共享生产帧、零 GPU 错误/未完成读取/blit），证据见 `build/godot-4.7-linux/REPORT.md`；Ubuntu ARM64 已关闭，本轮到此停止。后续 x64 EGL Release 交叉构建/封包/228 项 ABI 与相同最小组合也已通过（QEMU/llvmpipe，505 共享生产帧、9 图），见 `build/godot-4.7-linux-x64/REPORT.md`；仅增加慢翻译环境的看门狗，不降低活动 tick/帧数/像素等断言，VM 已关闭。两套 Linux 本轮到此停止，不推进其它平台；原生 x64 CPU/物理 GPU 与长期压力未覆盖。

4. macOS 通过后才推进其他平台，逐个平台构建和验收，不并行本地构建，不自动追加设备/浏览器/压力矩阵。iOS 缺少 Apple4 正向设备时明确保留边界。
5. 更新来源登记、维护文档和新版验收范围；本轮没有创建新 Dora tag 或公开 Release 的步骤。

## 增量验收与停止条件

- 先做便宜的包/导出/ABI检查，再启动唯一一轮动态组合用例；同一源码、工具链和配置可复用构建缓存及已导入的测试工程，记录本次实际执行产物摘要。
- 共用清理逻辑的隔离契约已在macOS/Linux验证；移植时检查后端资源释放、通知及新发生的差异，不每个平台重新复制所有已通过的契约场景。
- 沿用既有像素、GPU错误、未完成读取、音频及状态清理断言，不降低门槛；慢VM只增加必要的活动运行帧数，不增加卸载后的固定等待。
- 组合用例及相关检查通过即结束该后端。若失败，只修复并复验失败项和直接受影响项；仅在发现共用逻辑回归或证据不足时扩大范围，并说明原因。CI只重跑失败/受影响任务，不因局部修复手动重跑整套通过项。
- 每个新增后端目标为一次成功的动态组合验收，失败诊断不承诺固定次数；不以限制次数为由跳过真实失败。所有本地构建和动态用例串行，结束后清理本任务进程并关闭本次启动的VM/模拟器。
- 跟踪文档只更新已完成与待办；参数、摘要和过程暂存对应 `build/` 任务目录，不恢复已移除的history目录。

## 上游更新与验收

上游导入与 Dora 修改分开提交；更新来源、版本、哈希与许可差异，重新应用补丁并记录冲突。与 SCons 对照或最近封存的 xmake 基线比较，重新进行各平台实际运行验收。

每个平台须满足 [跟踪清单](TRACKING.md) 的干净构建、包/ABI、实际运行和环境清理门槛。编译通过不等于迁移完成；VM、模拟器、软件渲染与物理硬件分别记录。

## 历史与用法

- 本次整理前的清单、计划及哈希（`history/2026-11-03-vendor-xmake-plan-refresh-final/README.md`）。
- 前次整理前的计划和进展原文（`history/2026-11-03-vendor-xmake-plan-handoff/README.md`）：保留完整快照与哈希，不追加后续进展。
- 前次清单快照（`history/2026-11-03-migration-checklist-refresh/README.md`）、前次计划快照（`history/2026-11-03-migration-plan-refresh/README.md`）。
- 迁移前整合历史（`history/2026-11-02-pre-vendor-xmake/README.md`）、早期迁移过程（`history/2026-11-02-vendor-xmake-progress/README.md`）、前次完整证据索引（`history/2026-11-02-vendor-xmake-status/README.md`）。
- [构建及测试用法](README.md)：实际命令和参数；[维护指南](MAINTENANCE.md)：源码升级、包布局及排障。
