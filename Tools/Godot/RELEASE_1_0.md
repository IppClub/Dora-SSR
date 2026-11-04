# Godot 整合 1.0：支持范围与交付清单

更新：2026-11-04。本页汇总当前源码及跟踪清单已有证据，不代表本轮重新验收全部平台。当前处于候选收口：已实现能力、环境限制、最终候选包及公开发布分别记录；源码提交成功不等于最终包验收或发布完成。

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
| Linux x86_64 / EGL | 运行、读回及普通宿主基线；CI 驱动含普通宿主 A→B→A | QEMU/llvmpipe 历史基线与当前 CI 分开；Release 的活动退出检查不等于跨项目切换通过 |
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

- [ ] **候选身份和 CI**：记录引擎与 Dora-Example 的最终提交、实际解析的测试 revision、对应 CI 结果及产物摘要。本轮未查询最新远程 CI，不据工作流定义推断运行成功。
- [ ] **候选包对应关系**：将拟分发的宿主、LibGodot manifest、架构/后端和许可逐项对应到候选源码；通用 `dora-package` 的 Godot 包参数是可选的，常规 Dora 构建成功不能证明含有匹配 LibGodot。旧测试包和本地 QA 签名不充作最终发布包。
- [ ] **仅补缺失覆盖**：先查当前 CI 中普通宿主 A→B→A 的产物与报告；Linux x64/Release 只补确实缺少的项目切换证据。既有通过矩阵不重复。iOS/D3D12/物理设备/长期压力及扩展兼容性维持已注明的延期或未覆盖状态。

公开 Release、tag、发布签名、公证、上传及 Hub 工程浏览界面不在本轮执行动作内。后续发布单独确认交付清单；本页不声称已公开发布。
