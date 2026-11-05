# Godot vendor / xmake 迁移清单

更新：2026-11-04。执行顺序见 [PLAN.md](PLAN.md)，命令见 [README.md](README.md)。本页只维护已完成项和待办。1.0平台支持矩阵与最终交付缺口见 [RELEASE_1_0.md](RELEASE_1_0.md)。旧 history 目录已按用户整理移除；本次新记录暂存 `build/godot-xmake-only-v1/PROGRESS-DRAFT.md`，不重建历史目录。

## 固定范围

- 完整 vendor Godot 4.6-stable 至 `Source/3rdParty/Godot`，不用 submodule；维护来源、版本、许可证与 Dora 补丁。
- 原生 xmake 管理生成、编译、链接与封包；允许复用上游 Python 生成器，生成物不写回源码。构建入口统一 xmake；保留上游构建文件与历史对照，不保留 SCons 安装/调用/回退。动态验收另行跟踪。
- Godot C#/Mono 关闭，Dora C# 保留；Dora Apple2 / Godot Apple4；Windows x64 WGL 为本轮验收后端；保留 D3D12 适配并跳过本轮 D3D12 验收，不新增 Windows ARM64 目标验收。
- 浏览器验收在宿主执行；不在虚拟机内增加浏览器测试，不自动扩展额外压力轮次。
- Godot保持完整独立LibGodot运行时，包含各平台原有第三方实现；Dora与Godot分别构建依赖，不复用第三方二进制或宿主codec函数表。共享库实验与相关待办已撤销，历史完整保留（`history/2026-11-03-library-sharing-removed/README.md`）。
- 不做进程内 LibGodot 重初始化；按最新决定保留同一 LibGodot，实现项目级卸载与切换，macOS Metal、Linux EGL、Windows x64 WGL、Android EGL和WebGL2默认开放，见 [PROJECT_SWITCH.md](PROJECT_SWITCH.md)。缺少真机时可用 VM/模拟器，明确证据边界。

## 已完成

- [x] **DEFAULT-CI-01｜默认组件冷构建入口修复**：修正Windows版本探针按系统代码页解码UTF-8的错误；Android Wa准备入口与Gradle共享NDK版本，默认28.1、显式裁剪仍为26.1，doctor同步。Windows旧错误负向控制/新探针及Android缺失AAR冷配置、NDK28依赖重建/Debug任务图通过；两平台完整构建仍待本次修复后的CI确认。证据`build/godot-ci-fix-v1/`。

- [x] **DEFAULT-COMPONENT-01｜1.10.0默认正式组件**：普通构建/封包、Android/Web、Studio Agent及游戏Player默认包含Godot，保留显式裁剪；Docs站作品Player显式关闭Godot；macOS默认arm64，Windows默认x64/WGL。版本及自更新架构文件名同步。macOS默认Release实际运行/缺库回退、Studio双Player及浏览器动态画面、Android arm64组件准备和Release任务图通过；macOS最终ZIP运行/缺库回退及资源/签名核对通过；Docs双语生产构建及11个Dora作品资源检查通过，Godot禁用和残留运行库由部署门禁拒绝。完整核对结果暂存`build/godot-production-v1/`。其余平台新候选CI和设备边界继续由RELEASE-DELIVERY-01跟踪，不视为全平台动态验收。

- [x] **RELEASE-SCOPE-01｜1.0范围与交付缺口整理**：汇总后端/模式/设备证据，固定Godot最小修改与原生binary失败回退策略；区分功能验收、模拟器限制、候选包及公开发布。更新默认切换平台、源码登记计数和失效历史引用，不重建history，不增加测试轮次。见 [收口清单](RELEASE_1_0.md)。

- [x] **GLES-CACHE-LENGTH-01｜binary有效长度保存与最小冷/暖配对**：接收并校验`glGetProgramBinary`实际返回长度，只写有效字节；生产保存方法7项边界及旧代码负向控制通过。arm64普通非debuggable Release在Emulator37.1.11／API35／SwiftShader仅跑三缓冲一次冷启动和一次保留缓存重启：冷启动通过，5文件／19条binary保存；暖启动前哈希逐项等于冷退出后，仍因binary链接告警严格失败，回退后的像素/时钟/resize/GPU排空/完整退出诊断通过，不算binary恢复通过。按用户决定保留模拟器环境限制，不加源码缓存、不忽略失败或过滤告警；测试APK与进程已清理，模拟器已关闭。源码登记审计通过；证据 `build/godot-android-warm-cache-v1/`，测试在Dora-Example。

- [x] **PROJECT-SWITCH-WEB-01｜WebGL2 同实例卸载与切换**：默认Release `dora-preset`保留同一LibGodot/WASM实例和共享WebGL2 context，接入卸载状态与2/3/4纹理环重建；回收JS侧工程副本，保留用户文件和进程缓存。修复重载工程设置后Web Sample默认值绕过PCM的问题。Chrome完成官方Dodge源码→Squash Web PCK→A→B→A及失败恢复/取消/重复通知/活动实例拒绝；Firefox、原生Safari和WebKit各补A→B→A，共42图，动态画面/公开输入/有效PCM、GPU排空、零blit及副本哈希/回收通过，重复清理对象稳定、资源1、节点0。Chrome卸载后context loss安全停止和拒绝再开通过；保留Firefox阴影过滤实现差异提示及既有Emscripten主线程等待提示，不声称无告警或任意工程隔离。浏览器、服务和驱动已清理；证据暂存 `build/godot-project-web-v1/`。

- [x] **GLES-CACHE-CLEANUP-01｜缓存失败的GL program回收**：缓存加载期间统一持有临时program，完整成功后才转交给Version；链接失败、跨变体部分成功后失败及读取截断均释放已创建program。实际生产加载/初始化/清理方法的C++故障注入覆盖13类路径及500次重复失败，成功路径和源码回退保持，旧代码负向控制复现泄漏。源码登记审计通过；未启动模拟器或扩展平台矩阵。测试在Dora-Example，证据暂存 `build/godot-shader-cache-cleanup-v1/`；不关闭shader binary兼容/暖缓存待办。

- [x] **PROJECT-SWITCH-ANDROID-01｜Android EGL 同实例卸载与切换**：默认接入生命周期协议和2/3/4纹理环重建，修复嵌入模式仍走APK资源根目录导致复用旧工程配置。arm64普通非debuggable Release在API35／SwiftShader模拟器完成官方Dodge源码→Squash Android PCK→A→B→A，同一LibGodot、五棵新树、15图、公开输入、有效PCM、失败恢复/取消/重复通知/活动实例拒绝通过；GPU错误/未完成读取/blit/音频欠载均0，重复清理对象稳定、资源1、节点0。按已有Android普通宿主功能标准验收；保留已知shader binary回退告警，不关闭严格无告警缓存任务。测试应用已清理，模拟器已关闭；证据暂存 `build/godot-project-android-v1/acceptance-v2/`。

- [x] **PROJECT-SWITCH-WGL-01｜Windows x64 WGL 卸载与切换**：保留同一LibGodot/WGL context及可重建的2/3/4纹理环。先前五次加载和失败/取消/通知/活动实例边界通过；本轮将Parallels阴影比较采样改为手动投影，原始阴影、滤波和4×MSAA保留，只补B→A→B，9图、动态像素/输入/PCM、零blit及GPU排空通过，重复清理对象稳定、资源1、节点0。限Windows 11 ARM VM内x64 Debug，物理GPU/Release未覆盖；VM已关闭。证据暂存 `build/godot-wgl-shadow-v1/` 和前轮 `build/godot-project-wgl-v1/`。

- [x] **PROJECT-SWITCH-LINUX-01｜Linux EGL 同实例卸载与切换**：默认接入项目生命周期接口与 GodotPlayer；保留 LibGodot、renderer 和 EGL context，在排空 GPU 后重建不同尺寸及 2/3/4 缓冲纹理环。Ubuntu ARM64／Mesa virgl 的 Debug 普通宿主通过七次隔离夹具、重复卸载通知、无效工程恢复、启动取消和旧库拒绝；官方 2D/3D 源码/PCK 交替八次、24 图、每轮149–169共享帧通过。输入、音频、零blit及GPU排空通过，重复访问后对象数稳定、资源1、场景节点0。普通资源目录查库的 A→B→A 回归及5图通过；修复 Linux 导出表并登记链接依赖；本次测试进程、临时挂载已清理，VM已关闭。证据暂存 `build/godot-project-linux-v1/acceptance-v3/`；范围见 [PROJECT_SWITCH.md](PROJECT_SWITCH.md)。

- [x] **CI-PRECHECK-01｜轻量测试构建与增量夹具修复**：Lua契约改用独立host-tools配置，避免触发Rust/Go依赖；解释器按宿主OS/架构选择。Linux快速构建复现xmake秒级mtime导致静态库未重打包，夹具跨时间戳tick后保留增量与运行断言；补实际值日志/CI产物。macOS及Linux VM本地验证通过，VM已关闭；远程CI另行核对。记录暂存 `build/godot-ci-fix-v1/`。

- [x] **PROJECT-DEFAULT-MAC-01｜macOS Metal默认卸载与切换**：移除实验环境开关，按运行库能力默认提供项目卸载；默认配置7次隔离/通知夹具、官方2D/3D源码/PCK交替8次24图、2/3/4缓冲与音频/GPU排空、启动取消、旧库拒绝及分发试玩通过。文档已同步；其余后端和长期兼容性留待办。证据暂存 `build/godot-project-default-v1/`。

- [x] **PROJECT-CONTROLLER-MAC-01｜卸载通知、串行控制与真实项目**：C++/Lua `GodotNode.unloadAsync` 在GPU/音频和项目清理后通知，重复/完成后订阅均支持；生产Lua `GodotPlayer` 以原生通知处理FIFO、失败、超时和关闭。官方2D/3D项目源码/PCK交替8次、24图、公开输入、音频、2/3/4缓冲与GPU排空通过，重复访问后对象/资源计数稳定且场景节点0；修复常驻Renderer相对shader缓存根切换。8项控制器契约、原生取消/未开启拒绝和通知夹具通过。后续已默认化；当前验收仍限macOS；用法见 [PROJECT_SWITCH.md](PROJECT_SWITCH.md)，详情暂存 `build/godot-project-controller-v1/`。

- [x] **PROJECT-SWITCH-MAC-01｜同实例项目切换原型**：macOS Metal 显式开关下，同一 LibGodot 完成七次源码/PCK加载，SceneTree逐次重建；静态/资源/Autoload/设置/输入/用户singleton与音频隔离、2/3/4缓冲像素和GPU排空、单活动实例拒绝及无主场景失败恢复通过。默认路径试玩和22项分发测试通过；后续卸载通知及默认化已完成，其他平台与兼容性缺口见待办。用法与边界见 [PROJECT_SWITCH.md](PROJECT_SWITCH.md)，细节暂存 `build/godot-project-switch-v1/`。

- [x] **PROJECT-DELIVERY-01｜工程与试玩包基础**：新增仓库/工程识别、Git clone、源码ZIP导入、独立副本Godot4.6资源导入、标准PCK导出、试玩清单与归档/校验安装、普通Dora试玩入口。macOS Metal 已验证 clone→原工程试玩→导出/安装→PCK试玩，导入PNG像素、动态帧、零blit与GPU排空通过；其他平台未验收，常驻实例切换仍见PROJECT-SWITCH-01。命令见[PROJECTS.md](PROJECTS.md)，详情暂存 `build/godot-project-delivery-v1/`。

- [x] **TEST-EXTERNAL-01｜测试外置**：287个 Godot 测试、夹具与独立审计/诊断文件迁入 Dora-Example `Test/Godot` 与 `Test/LibGodotMetalProbe`；xmake 测试宿主、统一套件、CI 和文档已同步。协议、17项包校验、构建回归、原生测试源码编译及可搬移封包夹具通过；生产构建和必需完整性校验保留引擎。新记录暂存 `build/godot-test-move-v1/`，未扩大 GPU/VM 验收。

- [x] **XMAKE-ONLY-01｜xmake 唯一构建入口**：六平台的13种架构/后端配置均通过 Debug、Release 串行编译、链接、封包与静态检查，共26项；10项构建系统回归通过，13,884个登记源码文件及24个最终构建输入摘要复核通过。自有 SCons 安装/调用/回退已移除，上游构建文件保留；四个原生 codec 变体目标替代新增 wrapper，无新增 codec 动态库。Linux ARM64 两模式各228项启动前ABI通过；其余动态缺口不随构建关闭。两台任务VM已关闭并恢复配置。新详情按用户要求暂存 `build/godot-xmake-only-v1/PROGRESS-DRAFT.md`，总验收为同目录 `FINAL-VERIFICATION.json`。

- [x] **DEPS-INDEPENDENT-01｜恢复完整独立LibGodot**：共享选项、codec提供/转发/握手及专用工具已移出活动树，实验与视频异常补丁归档；完整解码源恢复，macOS重建库与已验收独立基线整文件一致，普通宿主动画/缺库回退/GPU排空通过。其他既定整合修复保留；见撤销与验证记录（`history/2026-11-03-library-sharing-removed/README.md`）。
- [x] **ARCHIVE-01**：旧进展与计划完整归档，主清单保留阶段成果和开放任务。
- [x] **VENDOR-01/02、VENDOR-INTEGRITY-01**：完整固定版本 vendor，登记来源、许可证与 Dora 补丁，源码完整性核对通过。
- [x] **XMAKE-01/02**：独立目标、输出目录与等价代码生成。
- [x] **XMAKE-03/04**：macOS arm64 Metal、Linux Release 构建封包及既定运行验收；Linux x86_64 本轮基线补证见 LINUX-X64-REG-01。
- [x] **XMAKE-05、GL-REG-01**：Windows WGL 原迁移基线验收、GL 计时修复及 Linux ARM64 回归；新 WGL 包回归见 WGL-REG-01。
- [x] **XMAKE-06/07**：Android arm64 Release 模拟器、Web Release 四浏览器验收及入口切换。
- [x] **WIN-ABI-01**：修复后 WGL 与新 xmake D3D12 DLL 在 Windows x64 进程中分别通过 228 / 185 项启动前 ABI 检查；D3D12 图形动态验收仍开放。
- [x] **WGL-REG-01**：修复后新 DLL 的 Windows x64 ABI、2/3/4 缓冲、独立 soak/timing、普通宿主回退及官方项目回归通过；范围限 VM 虚拟 GPU。
- [x] **WGL-REG-02**：本轮新 WGL 包的 2/3/4 缓冲、soak/timing、普通宿主、缺库/后端回退及未修改官方项目通过；修复 pending await 退出泄漏并通过最小回归，哈希/截图审计和测试任务清理完成。范围限 VM 虚拟 GPU。
- [x] **WGL-GLES-REG-01**：读回修复前WGL库8df0a19e…完成 228项 ABI、2/3/4、soak/timing、普通宿主与缺库/后端回退、await 清理及原版官方项目验收；截图独立复核通过、零 blit，范围限 VM x64 进程。
- [x] **WIN-TOOLS-01**：D3D12 x64 双宿主构建、Rust 已安装工具链复用及中文 Windows UTF-8 封包检查通过；动态验收仍见 XMAKE-09。
- [x] **BASELINE-01**：D3D12 单后端 SCons Release 编译对照基线。
- [x] **VENDOR-MODE-01**：Ogg/Theora 构建模式修复及 macOS 宿主、视频和真实项目回归。
- [x] **DEPS-03、NIR-NOTICE-01**：依赖隔离方案与部分 NIR 历史许可补齐；完整许可审计仍开放。
- [x] **DEPS-LINUX-01、DEPS-ZLIB-01、DEPS-JOLT-01、DEPS-SDL-01**：Linux 最终 ELF 静态核对及 Dora zlib/Jolt/SDL2 来源、补丁审计。
- [x] **DEPS-MACOS-HOST-MAP-01**：已验收普通Dora Debug宿主的584对象顺序已恢复；控制/带map产物46段及签名前字节匹配（仅签名长度字段例外），Ogg归属和4项负向控制通过。Release收益仍未验收；见宿主map记录（`history/2026-11-03-macos-host-ogg-map.md`）。
- [x] **DEPS-MACOS-MAP-01**：当前Metal库已按实际链接收据重现，控制/带map产物均与已验收库整文件一致；旧52字节差异定位为framework顺序，负向重链复现通过。Ogg两成员贡献已核对，仍非共享收益或ABI验收；见精确map记录（`history/2026-11-03-macos-current-linkmap.md`）。
- [x] **DEPS-VORBIS-SOURCE-01**：Dora Vorbis的76个保留文件已从固定aoTuV/Lancer基线加完整差异精确重建，23个合并编译输入及9项负向控制通过。原源码/通知未改；仅确认等价基线，修改归属、完整ABI与共享仍开放；见来源记录（`history/2026-11-03-vorbis-source-provenance.md`）。
- [x] **DEPS-SHADER-SOURCE-01**：Dora glslang/SPIRV-Cross的131/36个保留文件及mode匹配固定bgfx树；Khronos基线加3/1文件补丁及glslang生成头精确重建，19项负向控制通过。原源码/通知未改，C++ ABI与共享仍开放；见来源记录（`history/2026-11-03-shader-source-provenance.md`）。
- [x] **DEPS-TINYEXR-SOURCE-01**：Dora保留的TinyEXR头及README与固定syoyo/bimg提交逐字节一致，Git blob及树关系核对、8项负向控制通过；来源已登记。仅覆盖两份保留文件，压缩后端、完整许可适用性及ABI/复用仍开放；见来源记录（`history/2026-11-03-tinyexr-source-provenance.md`）。
- [x] **DEPS-ASTC-SOURCE-01**：Dora astcenc的34个保留文件与固定bimg提交逐字节一致，Arm 4.8.0基线加两文件补丁精确重建；来源/补丁已登记，8项负向控制通过。Godot 5.3.0继续独立，ABI与复用仍待审计；见来源记录（`history/2026-11-03-astc-source-provenance.md`）。
- [x] **DEPS-WGL-IMAGE-01**：当前已验收WGL包与普通Dora宿主的最终PE导入/导出、包/验收收据身份已核对，6项负向控制通过；两侧静态符号已剥离，内部贡献与完整ABI/链接审计仍开放。见WGL镜像审计（`history/2026-11-03-wgl-dependency-images.md`）。
- [x] **DEPS-LINUX/WEB/IOS-LAYOUT-01、DEPS-MACOS/IOS/ANDROID-C-API-01**：指定编译单元布局及公开 C 接口核对；不等同完整 ABI 验收。
- [x] **DEPS-MACOS-CODEC-01、DEPS-MACOS-ZLIB-01**：macOS 现有对象跨库调用、所有权及错误清理实验；尚未进入生产复用。
- [x] **LINUX-X64-REG-01**：冻结新库 a5435ea9… 的 2/3/4、soak/timing、228项 ABI、普通宿主/缺库回退、官方项目及 await 清理全部通过，原始图像独立复核，VM已恢复关闭；范围为 QEMU/llvmpipe。后续 GLES 补丁的新产物复验另行跟踪。
- [x] **GDSCRIPT-MACOS-01**：修复后 macOS Metal 库重建封包、214项 ABI 与原生 pending await 清理回归通过；GPU 排空无错误、零 blit、退出无对象泄漏。
- [x] **GDSCRIPT-LINUX-ARM64-01**：当前源码重建库通过原生 ARM64 ABI、await 销毁与退出清理，以及 2/3/4、soak/timing、普通宿主回退、未修改官方项目；virgl GLES3.0/KHR_debug 分支及原始截图独立复核通过，零 blit。
- [x] **GDSCRIPT-ANDROID-01**：新 arm64 Release 库在专用模拟器通过 await 清理及正常 Activity/LibGodot 退出验证；修复 GLES 详细日志误启用不支持的调试功能，测试 APK/模拟器已清理关闭。
- [x] **GDSCRIPT-WEB-01**：当前源码 Web 库重建封包，Chrome/Firefox/WebKit/原生 Safari 的 await 节点销毁与正常退出回归全部通过；旧封包两个计时器泄漏的负向对照可复现，源码两侧 FS 哈希一致。
- [x] **WEB-CURRENT-EXTRAS-01**：当前源码 Web 包的 context loss/重载恢复、独立 heap、可信 DOM/中文输入及 WebAudio 输出/挂起恢复通过，报告与封包摘要独立复核完成。
- [x] **GL-TIMING-CAP-01**：原版 Godot 4.6、Dora Metal 与 Linux ARM64/x64 EGL 的强制追赶上限对照通过，Shader TIME 对独立墙钟误差≤2tick；原64步全部原图按上游语义复核通过，严格默认与运行时计时未改变。
- [x] **LINUX-X64-PROJECT-02、LINUX-CURRENT-REG-02**：GLES修复后的 x64 库 b89fbb2a… 的全部矩阵、原64步计时、普通宿主/缺库回退、原版官方项目及 await 已独立复核通过；公开输入按真实时间控制，455tick与全部像素门槛保留，范围限 QEMU/llvmpipe。
- [x] **GLES-DEBUG-REG-01**：Android 缺扩展、Linux ARM64 KHR_debug 正向分支及GLES阶段的 WGL/Linux x64 新包回归全部通过；Web/iOS 不编译此 EGL 调试分支，D3D12 本轮跳过。
- [x] **DIRECT-READBACK-01**：macOS Metal 的 Godot 根 ViewportTexture.get_image() 已跟随当前共享纹理；旧库负向对照、新库2/3/4读回/resize、宿主显示、完整Metal矩阵和原版官方项目通过，214项ABI与源码完整性复核完成。
- [x] **DIRECT-READBACK-EGL-01**：新Linux ARM64/x86_64库的Godot直接纹理读回2/3/4、640×360→800×450 resize及宿主显示通过，8组原图独立复核，GPU排空/零blit通过；范围为virgl及QEMU/llvmpipe，完整功能矩阵仍另验。
- [x] **READBACK-REG-EGL-01**：新ARM64/x86_64库a659e7bf…/e4865cfe…完成228项ABI、2/3/4、soak、原64步计时、普通宿主/缺库回退、官方项目及await共16组复核；首次欠载与计时模式拒绝保留，按相同门槛串行续验通过，范围限VM。
- [x] **DIRECT-READBACK-WEB-01、WEB-CURRENT-CORE-REG-01**：新Web包e72f952f…的三引擎2/3/4读回及完整显示矩阵、四浏览器await、context loss、DOM/音频回归通过；原图、实际shutdown与源/包摘要复核完成，原生Safari全矩阵另验。
- [x] **DIRECT-READBACK-GL-01、READBACK-REG-WGL-01**：新WGL库dd61a9ae…通过2/3/4读回/resize、宿主显示、228项ABI、完整矩阵/soak/timing、普通宿主/回退、await及原版Dodge；原图/输入独立复核，4个本轮任务已清理、VM正常关闭。GL读回各平台既定缺口已补齐；范围限Windows x64进程/VM虚拟GPU，见当前WGL验收（`history/2026-11-03-wgl-current-acceptance.md`）。
- [x] **WEB-CURRENT-REG-01、DIRECT-READBACK-SAFARI-01**：解锁后原生Safari26.6.2在同一新包e72f952f…通过2/3/4完整矩阵与Godot自身读回/resize；42张原图独立复核，可信画布点击/音频解锁及正常shutdown通过，旧失败保留。最新Web包四浏览器既定矩阵缺口补齐，见Safari当前包验收（`history/2026-11-03-safari-current-regression.md`）。
- [x] **IOS-CURRENT-BUILD-01**：当前登记源码的simulator/device Release archive及framework重建封包通过；新模拟器库218项ABI、普通Dora180帧与Apple4安全拒绝重跑通过，原图/42个宿主section及两套最终符号独立复核。未运行Godot正向渲染或await，相关父项仍开放；见iOS当前库历史（`history/2026-11-03-ios-current-regression.md`）。
- [x] **ANDROID-CACHE-DIAG-01**：保留缓存的2/3/4续验已核对5个文件跨进程摘要；源码回退后的像素、时钟、resize与真实退出通过诊断复核，独立GLES复现及验收器负向控制完成。告警仍使严格验收失败，兼容处理见ANDROID-SHADER-CACHE-01；不是暖缓存验收通过。见缓存诊断（`history/2026-11-03-android-shader-cache.md`）。
- [x] **DIRECT-READBACK-ANDROID-01、READBACK-REG-ANDROID-01**：新arm64 Release库b58bd299…在专用模拟器通过2/3/4读回/resize、完整显示矩阵、普通宿主/缺库回退、未修改官方Dodge及await清理；原图、密封包/宿主摘要和实际Activity/LibGodot退出独立复核通过。限冷安装SwiftShader，暖缓存另列待办，模拟器已关闭。见Android读回历史（`history/2026-11-03-android-readback.md`）。
- [x] **WEB-REAL-PROJECT-02**：同一新Web包在Chrome通过未修改官方Dodge的48源文件双heap摘要、625控制帧/12截图、输入动画、暂停恢复、移除重建及GPU/PCM排空。
- [x] **XMAKE-HOST-GEN-01**：修复 Linux 交叉配置中 Lua 生成器误用目标编译器；宿主 ARM64 ELF 与实际 Lua5.1/LFS 执行检查通过，配套 x64 测试宿主已构建并用于本轮矩阵验收。
- [x] **CLEANUP-01｜已验收配置旧构建退场**：macOS arm64、Linux ARM64/x64、WGL x64、Android arm64及Web的Release入口已使用原生xmake；17项分派核对与8次真实prepare只读检查通过，13,884个源码文件摘要不变。这是原Release入口收口阶段；后续Debug、其他架构、iOS/D3D12及SCons显式入口的全量退场见XMAKE-ONLY-01，不删除历史产物。见入口收口记录（`history/2026-11-03-build-entrypoint-cleanup.md`）。
- [x] **DOC-01**：[维护指南](MAINTENANCE.md)、构建、升级与封包说明。

## 待完成

- [ ] **DEFAULT-CI-02｜默认组件构建余项**：Linux Embree基线与iOS活动SDK修复已有CI通过证据；`a765d7265`的Linux、Docs、UI、入口检查已通过。Studio已补contracts、教程生成依赖和正式构建的xmake工具环境继承，本地完整生产构建通过；新提交的完整CI仍待确认，Windows、Android、Web等不推定通过。失败日志已留存，推送后取消旧commit未结束任务，仅跟踪最新commit。证据`build/godot-ci-fix-v2/`至`build/godot-ci-fix-v4/`。

- [ ] **RELEASE-DELIVERY-01｜候选CI与最终包对应**：上一轮1.9.4候选`2bdad734a`及实际测试`aec520851`已确认，两架构普通AppImage均未含LibGodot。Linux原有job已正式成功（2026-11-04 16:18:41 UTC）；macOS等runner容量缺口保留。本轮1.10.0默认组件产物另行核对，后续核对匹配的宿主/运行库清单/架构/后端/许可和产物摘要，仅补完整Release单项切换，不复跑既有矩阵，不把本地QA签名作为正式发布。见 [交付缺口](RELEASE_1_0.md#最终交付仍缺少的证据)。

- [ ] **PROJECT-SWITCH-01｜项目切换正式化**：macOS Metal、Linux ARM64 Debug EGL、Windows x64 Debug WGL、Android arm64 Release EGL、WebGL2默认Release功能验收已通过，本轮不重复验收。先复用当前CI，Linux x64/Release仅补未覆盖的受影响项；当前CI为Release宿主配Debug运行库，完整Release组合由单项产物复用入口补齐，不混记通过；WebGL2已按一轮组合及其余浏览器最小冒烟完成并停止，不重跑既有矩阵。iOS受限环境、D3D12、长期显存/额外压力及扩展兼容性保持待办，不自动扩测或标为通过。详见 [最小计划](PLAN.md#剩余工作的最小执行计划)。

执行规则：复用已有通过证据，先包/导出/ABI后动态；局部失败仅复验失败项和直接受影响项。已有渲染/读回/await完整矩阵不随项目切换移植反复重跑；本地任务串行，结束关闭本次启动的VM/模拟器。D3D12与第三方库共享等既定范围不变。

- [ ] **GDSCRIPT-REG-01｜其他平台 await 清理回归**：macOS、Linux ARM64/x86_64、Android、Web 已重建并通过最小清理回归；iOS两套当前库已重建，模拟器ABI/安全拒绝已复验，但Apple2模拟器不能进入Godot运行态；仍须在Apple4可用环境复用夹具检查节点销毁及退出泄漏。
- [ ] **READBACK-REG-01｜公共RD/GL改动的其他配置**：Linux ARM64/x86_64、WGL和Web新库已独立构建封包；Linux两架构、Android冷安装及Web核心回归已完成；首次失败与续验证据保留。WGL当前包动态回归、iOS重建/模拟器ABI及Web原生Safari矩阵均已补，剩余iOS正向动态回归；D3D12跳过。
- [ ] **ANDROID-SHADER-CACHE-01｜真实binary恢复（模拟器环境限制）**：独立GLES探针在Emulator37.1.11／API35／SwiftShader同/新context均复现binary链接状态false；上游gfxstream将正确状态更新放在`GlProgramBinaryLinkStatus`兼容特性后，本机普通CLI不支持该开关。按用户决定只接受真正binary恢复，不增加磁盘GLSL缓存、关闭缓存、过滤告警或忽略link失败；本环境不能据源码回退关闭该项，待可真正恢复binary的驱动/guest环境验证。GL program失败回收已完成；返回长度保存修复与本轮冷/暖配对结果见本轮完成项及 `build/godot-android-warm-cache-v1/`。
- [ ] **LINUX-X64-AUDIO-LOAD-01｜并发欠载诊断**：当前包并发浏览器测试时出现一次512帧音频欠载，串行同场景零欠载通过；本轮同宿主旧/新基线配对均通过；额外浏览器压力轮次按用户要求取消，部分样本不算完整配对，原因仍待确认，不将基线通过写成已修复并发问题。见范围收敛记录（`history/2026-11-03-linux-audio-scope.md`）。
- [ ] **XMAKE-08｜iOS Metal**：补 Apple4 正向共享、2/3/4 缓冲动态矩阵及真实项目；当前源码两套archive/framework、模拟器218项ABI与能力拒绝已重跑通过；模拟器仅Apple2，正向缺口不变，构建已改为xmake，最新配置验证见XMAKE-ONLY-01。


详细进展、失败诊断与证据见 Windows 回归历史（`history/2026-11-03-windows-runtime-reaccept.md`）、Linux x86_64 回归历史（`history/2026-11-03-linux-x64-runtime-reaccept.md`）、macOS 清理回归（`history/2026-11-03-macos-await-cleanup.md`）、Android 清理回归（`history/2026-11-03-android-await-cleanup.md`）、Web 清理回归（`history/2026-11-03-web-await-cleanup.md`）、计时契约对照（`history/2026-11-03-timing-cap-contract.md`）、Metal读回修复（`history/2026-11-03-metal-readback.md`）及归档索引（`history/2026-11-03-vendor-xmake-plan-refresh-final/README.md`），本页不追加过程记录。

## 本轮跳过，保留后续

- [ ] **NIR-LICENSE-01｜D3D12 SDK许可核对**：NIR仍有12项许可继承关系待确认，仅在恢复D3D12验收/封包时处理；当前WGL等其他后端不引入NIR通知材料，不作为本轮收口门槛。见[许可材料](licenses/nir-25.3.1-1/README.md)。
- [ ] **XMAKE-09｜Windows D3D12**：按用户决定跳过本轮动态验收，保留适配、构建与已有 WARP 证据；官方项目崩溃及物理 GPU/纯 GPU fence 仍未验收。不标记通过，构建入口仅使用 xmake，GPU 验收保持开放。

## 验收与维护规则

1. 干净 checkout 独立构建，不读取旧 SCons 输出、不修改 vendor；工具链、flags、平台与后端可追溯。
2. 通过封包哈希、许可证、导出、动态依赖、ABI 与协议检查。
3. 对新增/受影响路径覆盖相关缓冲、动画、生命周期、输入音频、resize、重建及退出排空；复用既有未受影响的回退和真实项目证据。按最小组合计划验收，不逐提交重跑完整矩阵；未覆盖项明确保留。
4. 编译、VM/模拟器、软件渲染和物理硬件分别记录。每完成任务更新勾选，过程与证据写入历史文档。
5. 测试结束关闭本任务启动的服务、模拟器和虚拟机，保留证据。
