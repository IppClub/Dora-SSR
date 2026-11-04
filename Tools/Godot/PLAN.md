# Godot vendor / xmake 迁移计划

更新：2026-11-04。当前任务勾选以 [TRACKING.md](TRACKING.md) 为准；本页说明迁移顺序和交付门槛，不再追加实验流水。本次整理前的完整状态已移入 [历史快照](history/2026-11-03-vendor-xmake-plan-refresh-final/README.md)。

## 目标与约束

将固定版本 Godot 完整 vendor 到 `Source/3rdParty/Godot`，使用原生 xmake 管理源码、平台配置、生成器、编译、链接及封包，保留各自完整运行时及独立依赖。允许复用上游 Python 生成器；不以 xmake 包装 SCons 作为迁移完成。

保持 Godot 4.6-stable 来源、版本、许可证与 Dora 修改可追溯；生成物和对象文件放在独立构建目录，不写入 vendor 源码。受支持配置统一为原生 xmake 唯一构建入口；保留上游构建文件及封存对照，不保留 Dora 的 SCons 安装/调用/回退路径。动态验收缺口独立跟踪。

产品范围保持：Godot 不含 C#/Mono，Dora 原有 C# 保留；Dora Apple2 / Godot Apple4；Windows 本轮验收 x64 WGL，D3D12 适配保留但按用户决定跳过本轮动态验收；不做进程内 LibGodot 重初始化；按最新决定保留一个进程内LibGodot，实现项目级卸载与切换，macOS Metal和Linux EGL默认开放，其他平台和兼容性缺口见 [PROJECT_SWITCH.md](PROJECT_SWITCH.md)。

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

## 剩余工作的执行顺序

1. **补齐平台迁移与回归缺口**：最新WGL读回修复包已完成负向对照、2/3/4读回/resize、宿主显示、完整回归、await、回退及官方项目，并独立复核和关闭VM；当前各平台GL读回既定缺口已补齐。WGL-REG-02 与后续 GLES 新包的 WGL-GLES-REG-01 完整 VM 验收已通过；Linux x86_64 冻结新包的动态矩阵与真实项目也已通过；当前GLES新包回归已完成；接下来补iOS Apple4正向共享及await、Web新包剩余回归（原生Safari矩阵/读回及Chrome官方项目已补），并完成GL直接目标的Godot根viewport读回契约及公共RD改动的其他平台回归；macOS Metal读回已经修复验收。D3D12 的 XMAKE-09 按用户决定跳过本轮，保留适配、证据与未解决缺口，不作为当前 WGL 验收门槛。既有编译与静态检查不替代动态验收。

环境不足时可推进其他已授权任务，原缺口保持未完成。物理 GPU、纯 GPU fence 及其他架构的动态验收不由编译或 Release 验收替代。平台进展和故障分析只写入对应历史文档。

每完成一项更新 [跟踪清单](TRACKING.md)；本次参数、哈希、日志和失败过程按用户要求暂存 `build/godot-xmake-only-v1/PROGRESS-DRAFT.md`，不恢复已移除的 history 目录。构建与动态验收分别记录，构建脚本只保留 xmake。

## 每项任务的交付

- **平台迁移与回归**：独立构建与封包、ABI/导出检查、2/3/4 缓冲及真实项目报告；明确 VM/模拟器、软件渲染与物理 GPU 的覆盖边界。
- **旧路径退场**：补齐支持配置的 xmake 构建并移除自有 SCons 入口/依赖；保留完整上游文件与历史对照，不删除旧证据。

## 上游更新与验收

上游导入与 Dora 修改分开提交；更新来源、版本、哈希与许可差异，重新应用补丁并记录冲突。与 SCons 对照或最近封存的 xmake 基线比较，重新进行各平台实际运行验收。

每个平台须满足 [跟踪清单](TRACKING.md) 的干净构建、包/ABI、实际运行和环境清理门槛。编译通过不等于迁移完成；VM、模拟器、软件渲染与物理硬件分别记录。

## 历史与用法

- [本次整理前的清单、计划及哈希](history/2026-11-03-vendor-xmake-plan-refresh-final/README.md)。
- [前次整理前的计划和进展原文](history/2026-11-03-vendor-xmake-plan-handoff/README.md)：保留完整快照与哈希，不追加后续进展。
- [前次清单快照](history/2026-11-03-migration-checklist-refresh/README.md)、[前次计划快照](history/2026-11-03-migration-plan-refresh/README.md)。
- [迁移前整合历史](history/2026-11-02-pre-vendor-xmake/README.md)、[早期迁移过程](history/2026-11-02-vendor-xmake-progress/README.md)、[前次完整证据索引](history/2026-11-02-vendor-xmake-status/README.md)。
- [构建及测试用法](README.md)：实际命令和参数；[维护指南](MAINTENANCE.md)：源码升级、包布局及排障。
