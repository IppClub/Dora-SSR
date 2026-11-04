# Godot vendor / xmake 迁移计划

更新：2026-11-04。当前任务勾选以 [TRACKING.md](TRACKING.md) 为准；本页说明迁移顺序和交付门槛，不再追加实验流水。本次整理前的完整状态已移入 [历史快照](history/2026-11-03-vendor-xmake-plan-refresh-final/README.md)。

## 目标与约束

将固定版本 Godot 完整 vendor 到 `Source/3rdParty/Godot`，使用原生 xmake 管理源码、平台配置、生成器、编译、链接及封包，保留各自完整运行时及独立依赖。允许复用上游 Python 生成器；不以 xmake 包装 SCons 作为迁移完成。

保持 Godot 4.6-stable 来源、版本、许可证与 Dora 修改可追溯；生成物和对象文件放在独立构建目录，不写入 vendor 源码。受支持配置统一为原生 xmake 唯一构建入口；保留上游构建文件及封存对照，不保留 Dora 的 SCons 安装/调用/回退路径。动态验收缺口独立跟踪。

产品范围保持：Godot 不含 C#/Mono，Dora 原有 C# 保留；Dora Apple2 / Godot Apple4；Windows 本轮验收 x64 WGL，D3D12 适配保留但按用户决定跳过本轮动态验收；不做进程内 LibGodot 重初始化；按最新决定保留一个进程内LibGodot，实现项目级卸载与切换，macOS Metal、Linux EGL、Windows x64 WGL和Android EGL默认开放，其他平台和兼容性缺口见 [PROJECT_SWITCH.md](PROJECT_SWITCH.md)。

依赖部署固定为完整独立LibGodot：移除第三方库共享开关、宿主提供端、转发层及启动握手，各引擎保留自己的依赖实现。共享实验和撤销任务见[归档](history/2026-11-03-library-sharing-removed/README.md)。


## 阶段安排

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

## 剩余工作的最小执行计划

按用户要求采用增量验收，已有通过证据继续有效；不会因接入一个新后端而默认重跑其他平台、全部架构、浏览器或压力矩阵。

1. **复用当前 CI，结束 Linux 本轮工作**：先核对提交 `a7a379218` 的 CI 与实际产物配置；同一提交和配置已有通过项不再本地重跑。Linux ARM64 Debug 的项目切换已经通过；x64/Release 只补 CI 真正未覆盖的受影响项，不再重复八轮真实项目或完整图形矩阵。未验证的配置保持明确标注，不按已通过处理。
2. **Windows x64 WGL 已完成本轮最小验收，停止动态测试**：复用先前五次加载、失败恢复/取消/重复卸载通知证据；Parallels 的投影阴影采样适配后，只补原始 B的PCK(3缓冲) → A源码(4) → B的PCK(2)。9图、同实例/新场景树、动态画面/输入/PCM和GPU排空通过，阴影与4×MSAA保留。范围限VM内x64 Debug；物理GPU、Release及长期压力保持未覆盖。证据暂存 `build/godot-wgl-shadow-v1/`，不重跑其他平台或完整矩阵。
3. **Android EGL 已完成本轮功能验收，下一项 WebGL2**：arm64普通Release在API35／SwiftShader中完成一轮成功的五次官方源码/PCK切换、2/3/4缓冲与失败恢复/取消/卸载通知；15图、输入/PCM/GPU排空及重复清理计数通过。首次失败定位到Android APK资源根目录覆盖工程路径，修复后只复验受影响的组合，未重跑旧矩阵。保留既有shader binary回退告警，严格无告警/跨进程暖缓存任务继续单列；不关闭缓存，不将此功能验收写成缓存无告警通过。证据暂存 `build/godot-project-android-v1/`。
   WebGL2 后续沿用一轮组合；主浏览器跑完整组合，其余受影响浏览器只补A→B→A冒烟，不在VM中测浏览器。Android暖缓存修复仍仅补一次冷启动和一次保留缓存重启，不重跑全部功能。
4. **受限项保持待办**：iOS Apple4正向运行环境不足时，只复用已有编译/能力拒绝证据，不反复运行已知不能正向渲染的模拟器；D3D12继续按既定决定跳过。长期显存、额外并发压力、更多复杂工程及扩展兼容性保留后续，不自动扩成当前验收门槛，也不标为完成。

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

- [本次整理前的清单、计划及哈希](history/2026-11-03-vendor-xmake-plan-refresh-final/README.md)。
- [前次整理前的计划和进展原文](history/2026-11-03-vendor-xmake-plan-handoff/README.md)：保留完整快照与哈希，不追加后续进展。
- [前次清单快照](history/2026-11-03-migration-checklist-refresh/README.md)、[前次计划快照](history/2026-11-03-migration-plan-refresh/README.md)。
- [迁移前整合历史](history/2026-11-02-pre-vendor-xmake/README.md)、[早期迁移过程](history/2026-11-02-vendor-xmake-progress/README.md)、[前次完整证据索引](history/2026-11-02-vendor-xmake-status/README.md)。
- [构建及测试用法](README.md)：实际命令和参数；[维护指南](MAINTENANCE.md)：源码升级、包布局及排障。
