# Dora 3D 当前实现状态

本文记录 `3d` 分支当前已经落地的能力、验证状态和已知限制。历史设计依据保留在 `00` 至 `07` 文档中；后续开发优先级与验收计划见 `08-production-readiness-roadmap.md`。

## 1. 当前架构

### 1.1 场景树与 2D/3D 集成

- `Node` 与 `Node3D` 保持两套独立父子树语义。
- `Node3D` 的变换、父子关系和 world matrix 核心状态由 Rust 持有，C++ 对象作为引擎对象与绑定外壳。
- `View3D : Node` 是 2D 场景树与 3D 场景树之间的桥接节点，内部按需创建 `Node3D` scene root。
- `Director.entry` 的实际类型为 `View3D`，既可继续挂载普通 2D `Node`，也可通过 `View3D` 的 3D 接口挂载 `Node3D`。
- `View3D` 先按 `Node::render()` 规则渲染 2D 子树，再提交其 3D scene；`Director.entry` 在没有 2D 子节点时复用当前 main view，避免额外空 view。
- 多个 `View3D` 使用各自的 bgfx view id 和环境状态，不共享当前场景的环境参数。

### 1.2 相机与投影

- `Camera3D` 继承现有 `Camera`，通过 `Director.pushCamera()` 参与统一相机栈。
- 3D 渲染直接使用 `Director` 已计算的 view-projection，不再由 `View3D` 维护第二套 camera/projection。
- `View` 管理 projection 和 `frustumCulling` 开关；2D 与 3D 共用当前 view-projection 规则。

### 1.3 资源与实例

- `Model3DCache` 按 Dora 现有 Cache 风格缓存 glTF 模型定义。
- `Model3D` 是 `Node3D` 实例，资源定义与场景实例分离；多个实例共享 mesh、material、texture 和 animation clip 资源。
- `Model3D::cleanup()` 会销毁 Rust instance 并释放实例级节点、visual 和 skeleton；缓存资源由 `Model3DCache` 管理。
- 模型路径通过 `Content::getFullPath()` 解析，遵循引擎文件搜索机制。

## 2. 已实现能力

### 2.1 glTF 与渲染

- 支持 `.gltf` 与 `.glb`。
- 支持 glTF scene/node 层级、TRS、mesh primitive、submesh 和索引数据。
- 顶点数据包含 position、normal、tangent、UV0、UV1、color、joints 和 weights。
- 支持 32 位 index buffer。
- 内置 Model3D shader 通过 `Builtin.cpp` 的 embedded shader 接口创建，Rust 不直接依赖生成的 C++ shader binary 细节。
- 默认使用 forward rendering、深度测试和深度写入。
- 不透明对象按 sort key 排序；透明对象关闭深度写入并按相机距离从后向前排序。

### 2.2 材质与环境光

- 支持 glTF core metallic-roughness、base color、normal、emissive、occlusion、alpha mode 和 double-sided。
- 已接入 specular、clearcoat、transmission、volume、sheen、anisotropy、emissive strength、IOR 与 texture transform 等扩展数据。
- 支持 equirectangular 环境图到 irradiance/prefilter cubemap 的运行时预计算和缓存。
- 环境图、diffuse intensity、specular intensity 与 exposure 按 `View3D` 生效。
- 空环境路径使用内置中性环境纹理，不会使 PBR 模型因缺少 IBL 直接全黑。
- `Model3D` 公开逐实例 `Material3D` 槽位；第一次写入时 Rust 克隆共享材质并只替换当前实例相关 visual，其他实例继续使用缓存材质。
- 最小 `Material3D` 支持 base color、emissive、metallic、roughness、alpha mode/cutoff，以及 base color、metallic-roughness、normal、emissive、occlusion 五个 `Texture2D` 替换入口。
- `DirectionalLight3D` 支持单级 shadow map；每个 `View3D` 按需维护独立 1024x1024 RGBA8 depth-packed attachment，仅在当前场景选中的方向光开启 `castShadow` 时动态插入 Shadow3D pass。
- shadow caster 覆盖 static、skinned 与 alpha-mask，Blend 材质不写入硬阴影；接收端使用 3x3 PCF，并提供 constant bias 与 slope-dependent normal bias。
- PBR 环境 BRDF 改为解析近似，释放 sampler 10 给 shadow map，使 GLES 仍保持最多 16 个 sampler 且不牺牲 sheen/clearcoat 等现有材质槽。

### 2.3 动画

- 支持 glTF skin、joint、inverse bind matrix、JOINTS_0 和 WEIGHTS_0。
- 支持按名称播放、循环、停止、暂停、恢复、速度、时长和当前时间。
- `Model3D` 仅在播放动画时使用 scheduler 更新。
- skinning joint matrix 在 Rust 中计算并通过统一 Model3D shader 提交。

### 2.4 剔除与生命周期

- mesh 在导入时生成 local AABB。
- visual 按 world matrix 转换 AABB，并使用当前 view-projection 构造的 frustum 进行剔除。
- 全局开关使用 `View.frustumCulling`；visual 内部仍保留独立剔除开关。
- `Node3D`、model instance、mesh、material、texture、animation 和 environment 均有对应清理路径。
- `View3D.scene` 按需创建，空 3D scene 不提交 draw call。

### 2.5 脚本绑定

- Lua/tolua++ 已导出 `Vec3`、`Camera3D`、`Node3D`、`View3D` 和 `Model3D`。
- TypeScript、Teal、Wasm、Rust SDK、Wa 与 C# 已生成或补充对应声明。
- `Node3D` 的 position、scale、eulerAngles 和坐标转换统一使用 `Vec3`。
- 绑定层对 `Node.addChild(Node)` 与 `View3D.addChild(Node3D)` 的同名问题采用目标语言适合的重命名或覆盖策略。

### 2.6 Jolt 3D 物理

- Jolt Physics 5.5.0 以 C++17 源码直接编入各平台引擎目标，和现有 playrho 2D 物理保持独立；Rust crate 不调用 C++ 编译器，也不链接独立 Jolt 静态库。
- `Source/Physics/JoltBridge.cpp` 是引擎侧 Jolt C ABI 实现，Rust 只通过 `extern "C"` 声明访问；反向的 3D runtime 能力继续通过 Rust 导出的 C ABI 供 C++ wrapper 调用，Jolt C++ 类型不会跨越边界。
- `PhysicsWorld3D : Node` 复用主 Scheduler fixed accumulator；static/kinematic 在 step 前读取 `Node3D` world transform，dynamic 在 step 后写回 local position/rotation并保留 scale。
- `Body3D : Object` 由 world 持有，提供 box/sphere/capsule、linear/angular velocity、force/impulse、layer/mask 与 sensor。
- contact listener 在 Jolt step 内只收集 POD 事件，C++ 在 step 返回后快照 `Body3D` 引用并分发 Enter/Stay/Exit，允许回调中安全销毁 body。
- raycast 返回最近命中及 point/normal/distance；sphere overlap 返回当前重叠 body。
- Jolt world 使用 4 MiB 预分配临时 allocator，并在容量不足时回退分配，避免大 world capacity 在约束缓冲准备阶段触发断言。

## 3. 当前验证

- macOS 引擎通过 `Tools/build-scripts/build_macos.sh` 构建。
- Rust 3D 单元测试覆盖 frustum/AABB、opaque/transparent 排序、统计 ABI 字段顺序、invisible subtree、灯光选择、动画插值和特殊材质通道打包。
- `cargo test --lib` 当前通过 32 个纯 Rust 测试；覆盖 ray/AABB 相交、极端蒙皮姿态 bounds 合并、TRS/morph 动画采样、skeleton snapshot 共享存储、Node3D 层级/生命周期不变量、材质通道打包和上传预算。Jolt 集成不再由 Rust 测试进程直接链接 C++，统一改由真实 Dora 引擎进程回归。
- `Dora-Example/Test/Model3D` 提供 TS 编写的 ImGui 测试程序，覆盖 core PBR、多个材质扩展、环境切换、Fox 动画、视锥剔除和 cleanup 压力案例。
- `App.saveScreenshot()` 提供与场景节点解耦的 backbuffer 截图能力；相对路径写入 writable path，接口返回最终 `.tga` 路径。
- `View3D.stats` 提供 scene/visible/cull/item/draw/triangle/switch 统计以及全局 3D registry 数量。
- `Dora-Example/Test/Model3D/P0Regression.ts` 固定 Duck、DamagedHelmet、SpecularTest、Fox、Alpha Mask/Blend、双 `View3D` 和 Frustum Culling 七组案例。
- `run-p0-regression.zsh` 使用 `/tmp/dora-3d-test` 运行测试，生成截图、统计、RSS 采样，并对 Metal PNG 基线执行 normalized RMSE 比较，当前阈值为 `0.05`。
- 2026-07-10 的 macOS Metal 验证中，七组案例、剔除开关、空场景 draw call 和 300 次资源轮换均通过；Fox 动画截图 RMSE 为 `0.0169`，其余静态图为 `0`。
- 七组场景轮换 300 次前后 C++ object count 为 `145 -> 145`，model instance 为 `0 -> 0`；`Cache.removeUnused()` 后 registry 为 `nodes=1, visuals=0, models=0, meshes=0, materials=0, animations=0, instances=0`。
- 同轮整体 RSS 采样为 `first=155716 KB, max=535052 KB, last=401772 KB`；单独截取七组场景轮换 300 次的区间后为 `first=531820 KB, max=532116 KB, last=532116 KB, delta=296 KB`，没有呈现随循环持续增长的趋势。
- `Model3DCache` 已提供 loading/ready/failed/cancelled 状态、错误原因、取消、软预算和 resident bytes 统计；取消、失败重试与超预算淘汰有独立回归。
- renderer 规模化探针已比较同步 static 与异步 dynamic mesh 在 `100/250/500` 个 shared-material Duck 实例下的稳态成本；500 实例在当前 x86_64/Rosetta Debug 环境约为 `40ms` 帧时间，1000 实例出现高内存 abort，仍需在原生 arm64 Release 环境复测容量边界。
- `Touch.viewLocation`、`View3D.getRayOrigin/getRayDirection/pick` 已形成 screen ray 到最近 `Model3D` world AABB 的交互闭环，并提供 `View3D.showAABB` 调试线框。
- `Dora-Example/Test/Model3D/Physics3D.ts` 提供 JOLT-B 交互案例和 backbuffer 自动截图；2026-07-11 稳定态得到 `enter=6, stay=155, exit=6, sensor=3, ray=5.75, overlap=5`，三个动态刚体均稳定在 `y=0.63`，验证状态为 `PASS`。
- `Dora-Example/Test/Model3D/run-jolt-integration.zsh` 是 Jolt 引擎集成总入口，依次覆盖刚体/事件/查询、角色控制器、compound shape、mesh collider、dynamic convex hull 和 fixed/distance/hinge constraint；2026-07-12 六项均为 `PASS`。
- `JoltScaleProfile.ts` 建立 `100/250/500` 个动态 primitive body 的 physics-only 基线，同时采样正常模式与 physics debug draw；2026-07-12 macOS Metal Debug 下，关闭调试绘制的 500 body frame P95 保持 `16.667ms`，开启后为 `26.186ms`，Jolt collect P95 从 100 body 的 `0.480ms` 近似线性增长到 500 body 的 `2.329ms`。
- `ModelQuery3D.ts` 验证 Fox 动画名称 `Survey/Walk/Run`、`b_Head_05` 挂点、动画挂点世界位置变化和动态 local/world bounds，backbuffer 状态为 `PASS`。
- `Material3D.ts` 验证同资源双 Duck 实例的 copy-on-write：左侧实例修改为 metallic `1.00` / roughness `0.15`，右侧保持 `0.00/1.00` 和原始 tint，状态为 `PASS`。
- Material3D 合入后的 P0 完整回归仍为七图全通过；300 次 stress 区间 RSS `528552 KB -> 528560 KB`，对象数保持 `147`，post-cache registry 回到 `nodes=1, visuals=0, models=0, meshes=0, materials=0, animations=0, instances=0`。
- `DirectionalShadow3D.ts` 对同一场景分别截图 shadow disabled/enabled，验证 Duck static caster、Fox skinned caster、方向光旋转、3x3 PCF 和 bias；2026-07-11 macOS Metal 结果为 `SHADOW_SUMMARY status=PASS`，截图位于 `/tmp/dora-3d-shadow`。

当前自动参考图仅覆盖 macOS Metal。OpenGL、OpenGLES 和 Vulkan 基线暂不进入近期开发计划；以后具备真实 GPU self-hosted runner 或设备农场时，再在实际运行对应 backend 的平台生成并人工审核，不能复用 Metal 图片冒充跨后端验证。

## 4. 已知限制

### 4.1 测试与诊断

- 自动截图和 RSS/registry 回归当前只在 macOS Metal 建立基线，其他 backend 尚未接入平台 CI。
- `program/material/texture/mesh switches` 是 renderer 提交顺序中的逻辑状态切换次数，不等同于 bgfx backend 内部最终产生的全部 API 调用。
- `RenderStats3D` 已提供 model/mesh/texture estimated resident bytes、collect/sort/submit 微秒统计和 upload command 累计统计；这些仍是引擎侧估算，不等同于驱动实际分配。正式机器分级预算尚未制定。
- 截图比较使用整帧 normalized RMSE；后续可增加遮罩、像素差异图和每案例独立阈值，减少窗口尺寸或平台抗锯齿差异造成的误报。

### 4.2 光照

- 已公开 `DirectionalLight3D` 与 `PointLight3D`；灯光按当前 `View3D.scene` 收集，不同 view 互相隔离。
- 每个 render item 选择四盏点光执行完整 PBR，其余有效点光聚合为 L1 SH diffuse；场景节点数量没有四盏硬上限。
- `Env=None` 可由实时方向光/点光照亮，unlit material 仍绕过实时灯光和 IBL。
- `DirectionalLight3D` 已公开 `castShadow`、`shadowBias` 和 `shadowNormalBias`；首版只支持当前场景最亮的一盏方向光、固定 1024 shadow map 和单级正交拟合，不支持 CSM、point-light shadow、light layer/mask 或独立 caster/receiver mask。
- transmission/volume 等扩展属于当前 forward shader 的近似实现，不应视为完整 glTF 渲染器一致性保证。

### 4.3 资源加载

- glTF 主文件与外部 buffer/image 依赖统一通过 Dora `Content` 接口读取，不直接使用 Rust 文件系统 API；同步读取在 logic thread 执行，异步读取由 logic thread 发起并在 logic thread callback 后进入 worker parse。
- glTF 文件解析、图片解码、标准纹理 RGBA/mip 生成、特殊材质通道打包、场景拓扑展开、最终 vertex/index/tangent、skin 和 animation keyframe 已拆到 worker `PreparedModel` 阶段；Dora/bgfx 资源仍只在 logic/render thread finalize。
- `.gltf`/`.glb` 已接入 `Cache.load` 与 `Cache.loadAsync`，同路径并发请求会合并。
- Rust upload job 已拆成 texture、node、mesh、material、visual、skeleton、animation 和 finalize 命令；`Model3DCache` 用单一全局队列轮询，当前同时限制每帧约 `2ms` CPU 时间和 `512 KiB` 实际上传量，多个并发模型共享同一份预算。
- 普通 glTF 纹理先创建空 texture，再按 mip、完整行或行内像素区段调用 `bgfx_update_texture_2d`；任意单步都不会突破当帧剩余字节预算。
- 异步 mesh 使用 dynamic vertex/index buffer，按完整 `Vertex` 和 `u32 index` 边界跨帧填充；同步 `Model3D(path)` 继续创建 static buffer，不承担 dynamic buffer 的常驻渲染成本。
- 环境 cubemap 在原有 face/mip 拆分基础上进一步支持行块上传，未来提高 cubemap 分辨率时也不会因单个 face 超过预算而停滞。
- 上传任务取消或引擎 cleanup 会销毁尚未完成的 texture 和 dynamic mesh，不发布半初始化资源。
- DamagedHelmet 的 macOS Metal Debug 探针最大加载帧由 `2841.7ms` 经首轮优化的 `24.2ms` 进一步降至重复运行的 `16.7-18.2ms`。
- thickness/sheen 与 metallic-roughness/anisotropy 的通道重打包已经移到 worker，并以稳定组合 key 进入统一 PreparedTexture/upload job；在 `512 KiB` 字节预算下，两组特殊材质异步案例总加载时间分别约为 `0.968s` 和 `0.984s`，最大加载帧均为 `16.7ms`，实测每帧上传量不超过 `524288` bytes。
- 环境图 equirect 解码、irradiance convolution、prefilter 生成和 RGBA16F/RGBA8 打包已进入 worker；cubemap 创建与逐 face/mip/行上传复用全局时间/字节双预算 upload queue，同路径请求合并，完成前不发布半初始化环境。
- `MeshData` 只保留 vertex/index count、submesh、bounds、joint bounds 和 GPU handle；同步 buffer 创建或异步分块填充完成后，完整 CPU 数组立即释放。
- cache 会保留已加载模型，切换多个不同案例后的 RSS 增长不等同于 instance 泄漏。P0 stress 的稳定阶段 RSS 增量为约 `236KB`；当前已基于 resident bytes 提供 Model3D 软预算与 LRU 候选淘汰。
- 上传预算当前有意保持固定。基于 CPU/GPU frame time 的 AIMD 自适应预算方案已经记录在路线图中，但在缺少跨设备证据前不实现，避免引入反馈振荡、后端时序差异和额外调参成本。

### 4.4 动画正确性

- visual 已按 glTF mesh node 的 `skin` 绑定对应 skeleton，支持单模型多 skin。
- animation channel 直接指向 source node，instance 通过 source-to-clone map 驱动普通 node 与 joint TRS。
- 动画实例更新已直接借用 immutable clip 和 source-to-clone node map，不再每帧 clone 完整 clip 与 node map；采样结果复用 instance buffer，并有连续采样不重分配的单元测试。
- animation/skeleton registry 使用 `Arc` 保存 immutable 数据；renderer 每帧 skeleton snapshot 只复制共享引用。traversal stack、scene nodes、visual/skeleton snapshots 和 world-matrix map 保存在 per-view workspace 中清空复用，不再深拷贝 topology、完整 node list 或反复创建主要收集容器。
- 已实现 `STEP`、`LINEAR` 和 `CUBICSPLINE`，非循环末帧与 STEP 精确关键帧边界已修正。
- glTF morph target 已支持 mesh/node 默认 weights、动画 weights channel、POSITION/NORMAL/TANGENT delta 和动态 bounds；首版使用每实例 CPU morph 与 dynamic vertex buffer，高数量 GPU morph 仍未实现。
- 蒙皮 visual 在加载期按 joint influence 生成紧凑 bounds，渲染时用 joint matrix 更新并与静态 mesh AABB 取并集，避免 bind-pose AABB 对大姿态动画的误剔除。

### 4.5 Node3D 语义

- reparent 保留 local position/rotation/scale，并根据新 parent 重新计算 world transform；removeFromParent 后 world transform 回到 local transform。
- Rust core 与 C++ wrapper 均拒绝形成 parent cycle 的 addChild；检查只发生在层级修改时，不增加 render traversal 成本。
- rotation 在 Rust core 入口统一归一化，非法或零长度 quaternion 回退为 identity。
- Rust destroy 双向移除 parent/child link，但不会递归销毁 child；C++ cleanup 先从 parent 摘除自身，再递归 cleanup children 并销毁 Rust handle，使 cleanup 后对象成为不可继续使用的空壳。
- Lua/TS 使用只读 `hasChildren`，Wasm/Rust/Wa/C# 使用 `hasChildren()`/目标语言对应命名；虚假的 `children:any` 声明已移除。
- JOLT fixed step 复用主 Scheduler 的 fixed accumulator，在 action/普通 update/render collect 前执行；kinematic 在 step 前从 Node3D 推入，dynamic 在 step 后写回 local position/rotation。

### 4.6 渲染扩展

- `Material3D` 已公开最小逐实例参数与常用纹理替换，并采用 model instance 所有的 copy-on-write；高级扩展参数、自定义 Effect/program 和任意 shader uniform 仍未公开。
- ray/AABB picking、JOLT-A/B 游戏 API、JOLT-C 角色控制器、reusable/compound/mesh/convex hull shape、fixed/distance/hinge constraint、physics debug draw、首轮规模化物理基线、glTF morph target 和单方向光阴影已完成；尚无 triangle-level picking/BVH、CSM、point-light shadow、LOD、高数量 GPU morph、decal 或 cooked model format。
- renderer 已将 scene visual、visual-skeleton、skeleton data 和 world matrix 改为每帧批量 snapshot，移除每 draw 的 current-view mutex，并避免同一 mesh 多 submesh 重复提交整套材质。P0 49 draw 场景 collect/submit 分别约 `0.423/0.812ms`，更大实例规模仍需单独采样。
- `AnimationScaleProfile.ts` 覆盖 `1/10/25/50` 个同时播放的 Fox；2026-07-11 两轮 Debug/x86_64 基线中 collect P95 为约 `0.219-0.254/1.923-1.967/4.940-4.987/9.676-10.099ms`，submit P95 为约 `0.033-0.045/0.168-0.179/0.395-0.398/0.742-0.747ms`，50 实例 frame P95 保持 `16.667ms`。workspace 复用的收益是消除稳态分配，耗时差异处于测量抖动范围；该结果不作为 arm64 Release 性能承诺。

## 5. 状态结论

当前实现已经完成 3D 场景树、glTF、PBR/IBL、动画、剔除、缓存和多语言绑定的端到端闭环。它适合继续作为轻量 3D 功能基础，但还不应通过继续增加高级材质扩展来扩大范围。

P0 自动回归、实时灯光、glTF 动画、异步资源链路、缓存预算、首轮规模化 renderer/animation profile、动态 skinned bounds 和 ray/AABB picking 均已完成。动画稳态已移除每帧 clip/node-map/skeleton topology/scene-node 深拷贝，Node3D transform/lifecycle/fixed-step authority 也已冻结；剩余优化应由 profile 数据驱动。

JOLT-A/B、Model3D 查询、最小 Material3D、glTF morph target 和单方向光阴影已形成端到端闭环：Rust core、C++ wrapper、全部目标语言绑定、macOS 完整构建、P0 回归和独立真实场景均已通过。JOLT-C 的 `CharacterVirtual` 胶囊角色控制器、immutable compound shape、异步 glTF mesh/convex hull cooking、fixed/distance/hinge constraint、基础 physics debug draw 和首轮规模化性能/诊断基线也已完成。复杂 shape 的公开 ownership 保持在 Rust handle 层，Jolt native instance 由引擎 C++ C ABI 实现管理；mesh 数据通过 Content 异步读取并后台 preparation。当前通过 32 项纯 Rust 测试和六项真实引擎 Jolt 集成回归。动态上传预算、CSM、point-light shadow 和高数量 GPU morph 继续延期。详细计划见 `08-production-readiness-roadmap.md`。

2026-07-12 Jolt 边界收口回归：`cargo test --lib` 为 30/30，`Tools/build-scripts/build_macos.sh` 成功；引擎侧 Physics3D、CharacterController3D、CompoundShape3D、MeshCollider3D 和 Constraint3D 五项均为 `PASS`。其中 physics 稳定态为 `enter=6, stay=155, exit=6, sensor=3, ray=5.75, overlap=5`，constraint 为 `fixed=1.400, distance=2.000, hingeMove=1.377`。

2026-07-12 Jolt-C 性能基线：`JoltScaleProfile.ts` 的 `100/250/500` body、debug off/on 六个阶段均为 `PASS`。关闭调试绘制时 frame P95 均为 `16.667ms`，collect P95 分别为 `0.480/1.140/2.329ms`；500 body 开启调试绘制时 frame P50/P95 为 `24.072/26.186ms`，collect P95 为 `2.404ms`。RSS 采样为 `165220 -> 199784 KB`、峰值 `212996 KB`；该 Debug/x86_64 数据用于后续回归和增长趋势判断，不作为 arm64 Release 性能承诺。

2026-07-12 动态 Convex Hull：`PhysicsShape3D.loadConvexHullAsync()` 复用 Content 主线程异步读取与 worker preparation，只提取场景变换后、被 triangle indices 实际引用的唯一 POSITION；C++ Jolt bridge 通过 `ConvexHullShapeSettings` 创建可用于 dynamic body 的 native shape。cache key 区分 triangle mesh 与 convex hull。`ConvexHull3D.ts` 验证 cook、同类型 cache 命中、跨类型 cache 隔离、动态下落/旋转和 raycast，结果为 `CONVEX_HULL3D_SUMMARY status=PASS`。

2026-07-12 glTF Morph Target：首版在 worker 导入所有 target delta 和默认 weights，每个模型实例为 morph primitive 创建独立 dynamic mesh；动画支持 STEP/LINEAR/CUBICSPLINE weights，稳态复用采样与顶点缓冲，更新后同步 mesh/joint bounds。CPU morph 数据计入 model resident bytes。Khronos `SimpleMorph` 回归为 `MORPH_TARGET3D_SUMMARY status=PASS animations=1 duration=4.000 width=1.000..1.498 height=0.502..2.498`。

同轮最终验证：`cargo test --lib` 为 32/32，macOS universal Debug 构建成功，六项 Jolt 总回归、P0 七图/RMSE 与 300 次 cleanup stress 均为 `PASS`。同时修复 physics debug 队列为空时仍创建 debug material 的问题，post-cache registry 恢复为 `nodes=1, visuals=0, models=0, meshes=0, materials=0, animations=0, instances=0`。
