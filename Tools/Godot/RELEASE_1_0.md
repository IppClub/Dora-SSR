# Godot 整合 1.0：支持范围与交付清单

更新：2026-11-05。本页汇总当前源码及跟踪清单已有证据，不代表本轮重新验收全部平台。当前处于候选收口：已实现能力、环境限制、最终候选包及公开发布分别记录；源码提交成功不等于最终包验收或发布完成。

## 固定范围

- Godot 4.6-stable 完整 vendor，原生 xmake 构建完整独立 LibGodot；保留上游构建文件，无 Dora SCons 入口或第三方库共享方案。
- Godot GDScript / 标准 SceneTree；Godot C#/Mono 不包含，Dora 原有 C# 保留。Dora Apple2 / Godot Apple4 的能力门槛不变。
- 单个 LibGodot 实例、单个活动 GodotNode。已接入后端默认提供项目卸载完成通知及 `GodotPlayer` 串行切换，使用源码目录或目标平台 PCK；不是 LibGodot 销毁后重新初始化。
- 在已验收配置中复用 Dora/bgfx 纹理，2/3/4 缓冲及零 blit；不把有界用例扩大为任意工程全局隔离或长期显存稳定性承诺。
- 沿用 Godot 原有 binary 缓存及失败后的源码重编译。只保留临时 GL program 回收、实际 binary 长度保存等必要修复，不新增磁盘 GLSL 源码缓存、不忽略链接失败或过滤验收告警。

## 平台与证据边界

| 平台 / 后端 | 已有功能记录 | 本轮 1.0 必须保留的边界 |
| --- | --- | --- |
| macOS Apple Silicon / Metal | 原生纹理共享、真实源码/PCK项目、默认卸载及反复切换 | 已有本机验收；最终候选应用、运行库和签名仍须逐包对应，不推广到 Intel Mac |
| Linux ARM64 / EGL | 普通 Debug 宿主、默认卸载及真实项目切换 | Ubuntu VM / Mesa virgl；不是物理 GPU 或 Release 项目切换验收 |
| Linux x86_64 / EGL | 运行、读回及普通宿主基线；CI 驱动含普通宿主 A→B→A | 当前 CI 的 Release 宿主复用默认 Debug LibGodot；不能称为完整 Release 组合，活动退出检查也不等于跨项目切换通过 |
| Windows x64 / WGL | 真实源码/PCK切换、2/3/4缓冲、输入/PCM/GPU排空 | Parallels Windows 11 ARM VM 内 x64 Debug；Release、物理 GPU 未覆盖；不新增 Windows ARM64 目标验收 |
| Android arm64 / EGL | 普通非 debuggable Release、模拟器真实项目切换、冷启动读回 | API35 / SwiftShader；暖缓存 binary 恢复严格失败，记为模拟器环境限制；不据源码回退宣称恢复通过 |
| Web wasm32 / WebGL2 | 默认 Release `dora-preset`；Chrome完整切换组合，Firefox/原生Safari/WebKit冒烟；42图 | 宿主桌面浏览器；context loss 采用安全停止/页面重载；移动浏览器和原地恢复未承诺 |
| iOS / Metal | xmake archive/framework、模拟器 ABI、普通 Dora 与 Apple4 安全拒绝 | 当前 Apple2 模拟器不能运行 Godot 正向共享；正向渲染、await及项目切换均未验收，不列入正向支持范围 |
| Windows / D3D12 | 保留适配、构建与部分 ABI/WARP 记录 | 按既定决定延期；真实项目动态验收、纯 GPU fence 与 NIR 许可缺口仍开放 |

详细能力和项目兼容性见 [PROJECT_SWITCH.md](PROJECT_SWITCH.md)，逐项状态见 [TRACKING.md](TRACKING.md)。部分旧 `build/` 证据已按用户整理清除；清单中的历史通过记录不证明当前磁盘上仍有可分发产物。

## 构建与交付内容

宿主 Dora、匹配的运行库包、游戏数据是三类产物，分别保存身份与摘要：

| 产物 | 必需内容 / 使用方式 |
| --- | --- |
| LibGodot 运行库包 | 平台库、`manifest.json`、声明的依赖和全部许可证；使用 `python3 Tools/Godot/verify_package.py /path/to/package` 校验 |
| Dora 应用 | 对应架构/后端宿主、运行库及通知；桌面可通过 `xmake dora-package --platform=macosx --arch=arm64 --mode=release --godot-runtime=/path/to/package` 显式选包；Linux/Windows按维护指南选择平台与架构；Android/Web/iOS 使用各自配置，见维护指南 |
| 游戏试玩数据 | 已由 Godot4.6 导入的工程目录，或目标平台 PCK / `.dora-game`；不重复携带 LibGodot；流程见 [PROJECTS.md](PROJECTS.md) |

首次运行和串行切换使用方式见 [README.md](README.md)、[PROJECT_SWITCH.md](PROJECT_SWITCH.md)；源码升级、平台包布局和参数见 [MAINTENANCE.md](MAINTENANCE.md)。仓库 clone 不代替资源导入；Git LFS、子模块和素材必须完整。工程代码并非沙箱，原生 GDExtension、未结束的脚本 Thread 及第三方全局副作用仍受既有约束。

## 已完成的本轮收口

- [x] 明确五个已接入后端的默认项目切换能力，逐项保留实际构建模式及设备边界。
- [x] 确定 Godot 最小源码修改策略；Android 模拟器暖缓存限制不通过新缓存方案或告警豁免绕过。
- [x] 复用本地 Web 成功报告、Android 冷/暖失败配对及源码登记审计；不再增加本地测试轮次。
- [x] 整理导入/导出、部署、许可证、已知限制及旧历史引用；不重建已删除的 history 目录。

## 最终交付仍缺少的证据

- [ ] **候选身份和 CI**：运行时代码候选及实际测试 revision 已核对，当前结果见下方清单；仍须补齐 Linux 完整 Release 组合，并保留 macOS runner 未分配的缺口，不据工作流定义或部分通过推断全部成功。
- [ ] **候选包对应关系**：将拟分发的宿主、LibGodot manifest、架构/后端和许可逐项对应到候选源码；`1.10.0`已将Godot改为默认正式组件，仍须独立核对各平台新包包含匹配LibGodot及许可。旧测试包和本地 QA 签名不充作最终发布包。
- [ ] **仅补缺失覆盖**：先查当前 CI 中普通宿主 A→B→A 的产物与报告；Linux x64/Release 只补确实缺少的项目切换证据。既有通过矩阵不重复。iOS/D3D12/物理设备/长期压力及扩展兼容性维持已注明的延期或未覆盖状态。

公开 Release、tag、发布签名、公证、上传及 Hub 工程浏览界面不在本轮执行动作内。后续发布单独确认交付清单；本页不声称已公开发布。

## 当前候选核对

以下为上一轮`1.9.4`候选审计，不能代替当前`1.10.0`默认组件产物的验收。上一轮运行时代码候选为`2bdad734a372499cfc606d0c4d493f722d0fe0b8`，原CI日志实际解析的Dora-Example版本为`aec520851ba747a9315997e2c5d9bf2b521902e5`。后续单项验收入口提交仅修改CI编排和测试驱动，不改变该候选运行时代码。

- [x] 原CI实际测试revision已从[Ubuntu协议任务](https://github.com/IppClub/Dora-SSR/actions/runs/41854885101/job/126660702194)日志确认。
- [x] 两架构AppImage已下载静态检查：均不包含LibGodot或GodotRuntimeNotices，不能当作Godot最终包。
- [x] [Godot Linux任务](https://github.com/IppClub/Dora-SSR/actions/runs/41854885101/job/126660702345)的构建、原有矩阵、普通Release宿主退出/回退、Wasm trap、3D工程及上传步骤均成功；产物`godot-linux-egl`（ID `13341903137`）已生成。该job已于2026-11-04 16:18:41 UTC正式成功；不能据此记为其他平台或当前1.10.0工作流通过。
- [ ] 原Linux任务已正式成功，后续单独消费其Release宿主；若运行库为Debug，只补建一次LibGodot Release，再运行一次A→B→A。入口为`godot-release-candidate.yml`，测试入口固定`2d1e2d15dd6d379ad29224187356baf7705550aa`；不重编译宿主或重跑旧矩阵，分别核对优化标志、runtime target、源码和测试fixture身份。此次单项动态验收尚未执行。
- [ ] macOS、iOS设备Debug/Release及模拟器Release、macOS Web：对应子任务未取得GitHub runner，未执行代码；Web子任务只重试一次后仍因容量被取消。iOS模拟器Debug子任务已通过，但普通Dora构建不证明Godot Apple4正向运行。保留其余基础设施缺口，不据此修改源码或记为通过。
- [x] 原Linux job总状态延迟已恢复并正式成功；其余runner缺口独立保留。

当前核对记录暂存`build/godot-1.0-candidate-v2/`。候选CI、单项验收与最终分发包仍须分别满足前述交付门槛。

## 1.10.0 默认组件

- [x] Godot进入普通构建/打包和Studio双Player默认链路，仍可显式裁剪；macOS默认arm64，Windows默认x64/WGL。
- [x] 版本及自更新文件名同步；1.10.0清单采用新架构名，保留旧版清单读取。旧客户端不自动跨CPU架构迁移，更新渠道发布数据另行审核发布。
- [ ] 当前改动提交后的跨平台CI与最终候选包核对；本地macOS/Studio动态验证不代替其他平台设备验收。
