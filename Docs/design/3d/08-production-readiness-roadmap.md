# Dora 轻量 3D 可用性路线图

## 1. 文档目标

当前 `3d` 分支已经完成从场景树到 glTF 渲染的端到端闭环。下一阶段的目标不是追求 3A 渲染功能，而是让 Dora 的 3D 能力具备轻量游戏项目所需的正确性、可诊断性、加载体验和稳定 API。

本路线图回答三个问题：

1. 哪些现有能力需要先固定为可回归的基线。
2. 哪些功能最能提高轻量游戏项目的实际可用性。
3. 哪些功能应明确延期，避免重新扩大首版范围。

当前实现事实与已知限制见 `PROGRESS.md`。`00` 至 `07` 文档继续作为架构设计与方案演进记录。

## 2. 总体优先级

历史基础阶段顺序保持为：

```text
P0 自动回归与诊断
  -> P1 最小实时灯光
  -> P2 glTF 动画正确性
  -> P3 异步加载与内存控制
  -> P4 渲染性能整理与基础交互
```

上述基础阶段完成后的当前执行顺序调整为：

```text
里程碑收口
  -> 动画稳态与 Node3D 语义冻结
  -> JOLT-A 基础接入
  -> JOLT-B 最小游戏 API
  -> Model3D 查询与最小 Material3D
  -> 单方向光阴影
  -> JOLT-C / LOD / Morph / cooked asset
```

这条顺序的核心依据是：

- 没有自动回归时，坐标系、材质、环境和动画修复很容易反复引入视觉回退。
- 没有实时灯光时，3D 内容过度依赖环境图，不适合普通游戏场景。
- 同步加载会直接造成案例切换和首次加载卡顿，属于用户可感知问题。
- 性能优化必须建立在统计数据上，不应凭局部代码形态提前重构。
- `Material3D`、shadow 和 physics 会扩大公开 API 与渲染架构，应在基础行为稳定后推进。

## 3. P0：自动回归与诊断基线

### 3.1 目标

把当前依赖人工观察的测试工程转化为可以重复执行和比较的回归体系。后续任何 shader、坐标、动画或资源生命周期变更都应先通过这一层。

### 3.2 工作范围

- 保留 `Dora-Example/Test/Model3D` 作为人工交互测试工程。
- 固定最小自动案例集：
  - Duck：基础 mesh、纹理和坐标系。
  - DamagedHelmet：core metallic-roughness PBR。
  - SpecularTest：材质参数和纹理通道。
  - Fox：单 skin 蒙皮动画。
  - Alpha Mask/Blend：深度写入和透明排序。
  - 双 `View3D`：环境与 view 状态隔离。
  - Frustum Culling：边界内外和开关行为。
- 截图能力放在 Renderer、Director 或 App 层，不放入 `View3D`/`Node3D`。
- 为 Metal、OpenGL、GLES/Vulkan 分别保存允许容差的参考图，不要求跨后端逐像素一致。
- 增加 3D frame statistics：
  - scene nodes
  - visible/culled visuals
  - opaque/transparent items
  - draw calls/submeshes
  - triangles
  - program/material/texture switches
- 增加 lifecycle stress：循环创建、切换、remove、cleanup、cache removeUnused，并记录 RSS 与资源 registry 数量。
- 将 glTF parser/material mapping、animation sampling、bounds 和 frustum 的纯逻辑拆成可单测代码。

### 3.3 验收标准

- 固定案例可通过单一命令运行并产生截图与统计结果。
- 连续切换全部案例至少 300 次不崩溃、不死锁。
- model instance registry 和 Node3D/visual 数量回到稳定基线。
- cache 保留导致的增长与 instance 泄漏能够通过统计明确区分。
- 核心 PBR、动画和透明案例的截图在允许容差内稳定。
- 纯 2D 测试不产生额外 3D draw call。

### 3.4 当前完成状态（2026-07-10）

- [x] `App.saveScreenshot()` 通用 backbuffer 截图接口，不放入 `View3D`/`Node3D`。
- [x] `View3D.stats` 帧统计和 3D registry 数量接口，并同步 Lua、TS、Teal、Wasm、Rust、Wa 和 C# 绑定。
- [x] 七组 TS 自动案例和机器可读的 `P0_RESULT` 输出。
- [x] Frustum Culling 开启/关闭、双 `View3D` 环境隔离和空 3D scene draw call 验证。
- [x] 七组完整场景轮换 300 次、Lua GC、C++ object、RSS 和 post-cache registry 验证。
- [x] macOS Metal PNG 基线和 normalized RMSE `0.05` 比较。
- [延期] 在具备真实 GPU self-hosted runner 或设备农场后，再为 OpenGL、OpenGLES 和 Vulkan 生成并审核各自基线。

P0 的接口、测试工程和 Metal 验证闭环已经完成，不再阻塞 P1 开发。普通 GitHub-hosted Action 只适合构建、纯逻辑测试和软件渲染 smoke test，不用于生成可信视觉基线；跨 backend 基线在具备对应硬件基础设施前不列为近期任务。

### 3.5 实施清单与验收命令

1. 生成绑定：

   ```sh
   Tools/tolua++/build.sh
   Tools/WasmGen/gen.yue
   Tools/dora-cs/CSharpGen/gen.yue
   ```

2. 运行逻辑、SDK 和 C# 验证：

   ```sh
   cd Source/Rust && cargo fmt --check && cargo test --lib dora_3d:: --no-default-features
   cd Tools/dora-rust/dora && cargo check
   cd Tools/dora-cs/DoraCS && dotnet build DoraCS.csproj
   ```

3. 构建 macOS 引擎：

   ```sh
   Tools/build-scripts/build_macos.sh
   ```

4. 关闭浏览器中所有 `localhost:8866`/`127.0.0.1:8866` Web IDE 标签页，清理旧进程、启动服务并运行 Metal 回归。必须同时处理 Codex 内置浏览器和外部浏览器，避免旧 Web IDE 连接影响测试：

   ```sh
   pkill -x Dora || true
   env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY \
     -u ALL_PROXY -u all_proxy -u NO_PROXY -u no_proxy \
     zsh -ic 'dora cli doctor --fix'
   cd ~/Workspace/Dora/Dora-Example
   ./Test/Model3D/run-p0-regression.zsh
   ```

成功标准是 `P0_SUMMARY status=PASS`、七个 `P0_COMPARE_PASS`、300 次 stress 后对象/instance 回到基线，并且 post-cache registry 只保留 `View3D.scene` root 与环境纹理缓存。

## 4. P1：最小实时灯光

### 4.1 目标

让没有环境图的普通游戏场景也能得到可控、可理解的光照，同时保持 forward renderer 的轻量边界。

### 4.2 建议设计

- 增加 `DirectionalLight3D : Node3D`：
  - direction 由 world rotation 推导
  - color
  - intensity
- 增加 `PointLight3D : Node3D`：
  - position 由 world transform 推导
  - color
  - intensity
  - range
- 首版使用一个主方向光；场景中的 `PointLight3D` 节点数量不设置四个的公开硬上限。
- 灯光挂在 `View3D.scene` 对应的 Node3D 树中，renderer 遍历当前 scene 时收集，因此多个 `View3D` 不会互相覆盖灯光状态。
- 环境图继续负责 diffuse/specular IBL；空环境使用中性低强度 ambient，实时灯光负责主要明暗关系。
- 灯光属性和选择结果由 Rust 持有，C++ 只保留 `Node3D` 风格的绑定外壳。

#### PointLight3D 数量与质量策略

首版采用“每对象 Top 4 完整 PBR + L1 SH 溢出光”的混合方案：

- renderer 先按当前 `View3D.scene` 收集可见点光源，并用 range 与 render item 的 world AABB 排除无影响灯光。
- 对每个 render item 计算候选灯光的影响分数：

  ```text
  score = luminance(linearColor) * intensity * attenuation(distanceToWorldAABB)
  ```

- 影响最大的四盏灯执行逐像素完整直接光 PBR，包括 diffuse、specular、clearcoat、sheen 和 anisotropy。
- 其余有效灯光在 CPU 上合成为一阶球谐光照 L1 SH，只提供逐像素 diffuse，不提供独立高光。
- L1 SH 使用 normal map 处理后的法线求值，避免退化为与表面方向无关的常量 ambient。
- 每个 draw 上传四盏直接光的两个 `vec4[4]` 数组，以及四个 RGB SH 系数；不增加纹理采样槽：

  ```glsl
  uniform vec4 u_pointLightPositionRange[4];
  uniform vec4 u_pointLightColorIntensity[4];
  uniform vec4 u_overflowLightSH[4];
  ```

- 空的直接光槽使用 `range = 0`。点光源使用带平滑 range cutoff 的 inverse-square attenuation。
- unlit material 在进入直接光和 SH 计算前返回，不受实时灯光与 IBL 影响。

四盏灯是每个 draw 的完整 PBR 预算，不是场景节点上限。以后提高预算或改为 Forward+ 时，不需要修改 `PointLight3D` 的公开 API。

#### 方案取舍

| 方案 | 多灯质量 | CPU/GPU 成本 | backend 要求 | P1 决策 |
| --- | --- | --- | --- | --- |
| 场景固定四盏点光 | 超出四盏后硬截断 | 最低 | 最低 | 不采用，公开语义限制过强 |
| 每对象 Top 4 | 邻近对象可选不同灯光，但溢出灯消失 | 低 | 最低 | 作为直接光基础 |
| Top 4 + L1 SH 溢出光 | 四盏完整高光，其余保留连续 diffuse | 低到中 | 最低 | P1 采用 |
| Forward+/Clustered Forward | 大量点光可保留逐像素高光 | 中到高 | 需要 light list、buffer/compute 与回退路径 | 延后 |
| Deferred | 多光源能力强，但透明、MSAA 和材质扩展成本高 | 高 | 需要完整 G-buffer 管线 | 不符合当前轻量目标 |

L1 SH 只是对溢出点光的低频 diffuse 近似，不代替 IBL，也不参与 specular、clearcoat、sheen 或 transmission。Top 4 与 SH 必须从同一候选集合拆分，避免同一盏灯被重复计入。

#### 选择稳定性与缓存

- 分数相同时使用 light handle 作为稳定排序键。
- 已选灯光保留滞回：新灯必须明显强于当前最低权重灯光后才替换，建议初始阈值为 10%。
- 必要时对替换权重做 0.1 至 0.2 秒过渡，避免移动对象经过灯光影响边界时产生闪烁。
- 仅在对象 world bounds、灯光 transform 或灯光属性变化时重建对象的候选灯光和 SH，不要求每帧无条件排序。
- 初版可以扫描当前 view 中的灯光；profile 证明 CPU 查询成为瓶颈后，再用按 range 覆盖的 3D spatial hash 查询候选灯光。

首版缓存以 render item/visual handle 为键；visual 销毁或 registry cleanup 时必须同步移除，不能让灯光选择缓存随模型切换持续增长。灯光节点只在 Rust registry 中保存属性，C++ wrapper 不复制选择结果或 SH 数据。

#### 后续升级条件

只有项目明确需要几十到上百个重叠动态灯光，并且溢出灯也必须保留逐像素高光时，才评估 Forward+/Clustered Forward。该升级需要单独处理 light-list buffer、compute/backend 能力和 GLES 回退，不进入当前 P1。

### 4.3 非目标

- shadow map
- light layer/mask
- clustered/forward+
- area light
- IES profile

### 4.4 验收标准

- `Env=None` 时 core PBR、unlit 和 skinned model 均能正确显示。
- 方向光随节点旋转稳定变化，不受模型旋转或坐标镜像影响。
- 点光源位置、range 和衰减行为可预测。
- 同一对象最多使用四盏完整 PBR 点光，其余灯光仍通过 L1 SH 连续影响 diffuse，不发生简单硬截断。
- 对象穿过两个灯光优先级边界时，Top 4 选择稳定且没有连续帧闪烁。
- 场景中存在超过四个 `PointLight3D` 时不会报错，也不会改变公开 API 语义。
- 两个 `View3D` 使用不同灯光时状态完全隔离。
- unlit material 不受实时灯光与 IBL 影响。

## 5. P2：glTF 动画正确性

截至 2026-07-11，multi-skin 绑定、普通 node TRS channel 与 `STEP`/`LINEAR`/`CUBICSPLINE` 已实现并通过自动截图。channel 保存 source node handle，instance 使用 source-to-clone map 采样；每个 visual 根据 glTF mesh node 的 `skin` 选择对应 skeleton。实例更新已直接借用 immutable clip/node map 并复用采样缓冲，剩余稳态工作是 renderer skeleton snapshot、规模化 profile 和后续 morph target。

### 5.1 目标

从“Fox 可以播放”提升为对 glTF core animation 的明确支持，先修正确性，再处理动画性能。

### 5.2 工作范围

- 按 glTF mesh node 的 `skin` 关系绑定 visual 与 skeleton，不再把全部 visual 绑定到第一个 skin。
- animation channel 直接关联目标 node，允许普通节点 TRS 动画，不要求目标必须是主要 skeleton joint。
- 保存并实现 sampler interpolation：
  - `STEP`
  - `LINEAR`
  - `CUBICSPLINE`
- 预构建 channel target 和采样索引，避免每帧搜索和重建映射。
- 消除每帧对 nodes、clip 和 skeleton 的完整 clone。
- joint matrix 和 animation result 使用可复用缓冲区。
- 为 skinned visual 提供保守动态 bounds：首版可使用加载期合并 bounds 或可配置 expansion，后续再评估逐帧精确更新。
- 增加多 skin、普通 node animation、STEP/CUBICSPLINE 和大姿态 bounds 案例。

### 5.3 Morph Target

Morph target weights 属于 glTF core animation。首版已经采用 per-instance CPU morph：导入 mesh/node 默认 weights 与 POSITION/NORMAL/TANGENT delta，支持 STEP/LINEAR/CUBICSPLINE animation channel，并通过 dynamic vertex buffer 同步当前姿态 bounds。该方案不限制 target 数量且保持实例隔离，但活跃 morph 实例需要逐帧更新完整顶点缓冲；高数量/高顶点模型的 GPU morph variant 继续作为独立性能里程碑。

### 5.4 验收标准

- Fox、CesiumMan 和新增的普通 node animation 案例结果稳定。
- 多 skin 模型的每个 mesh 使用正确 skeleton。
- STEP、LINEAR、CUBICSPLINE 与 glTF 参考结果一致。
- 动画模型在测试动作范围内不会被错误视锥剔除。
- 稳态动画更新不再每帧 clone clip、skeleton 或完整 node 列表。

## 6. P3：异步加载与内存控制

截至 2026-07-11，异步链路、统一 Content 读取和可分块 GPU 上传已经落地：主文件与外部依赖由 logic thread 通过 `Content` 同步读取或发起异步读取，Rust `PreparedModel` 在 worker 完成 glTF/GLB 解析、buffer/image 解码、标准纹理 RGBA/mip、特殊材质通道打包、场景拓扑展开、最终 vertex/index/tangent、skin 和 animation keyframe。logic/render thread 的 upload job 分别执行 texture、node、mesh、material、visual、skeleton、animation 和 finalize。`Model3DCache` 使用单一全局队列轮询，同时限制每帧约 `2ms` CPU 时间与 `512 KiB` 实际上传量；普通纹理按 mip/行/像素区段上传，异步 vertex/index buffer 按元素边界上传，环境 cubemap 按 face/mip/行上传，同路径并发请求继续合并。同步模型仍使用 static buffer，异步模型在分块填充完成后释放 CPU vertex/index 数组。

### 6.1 目标

消除 DamagedHelmet、MetalRoughSpheres 和环境图首次加载造成的长时间主线程阻塞，同时保留 Dora 现有同步 API 的兼容性。

### 6.2 建议流程

```text
logic thread
  Content 同步读取或发起 loadAsync -> callback 汇总主文件与依赖

worker
  glTF 解析 -> buffer/image 解码 -> CPU model data

logic/render thread
  texture upload -> vertex/index buffer 创建 -> cache 发布 -> callback
```

- 保留 `Model3D(path)` 同步创建语义。
- 为 `.gltf`/`.glb` 接入 Dora 现有 `Cache.loadAsync(path, callback)` 风格；预加载完成后 `Model3D(path)` 应只实例化缓存资源。
- 将 Rust loader 拆成不调用 bgfx 的 CPU parse 阶段和仅在渲染线程执行的 GPU upload 阶段。
- GPU 上传支持按帧预算分批执行，避免后台解析完成后在单帧集中创建大量资源。
- 环境图解码和卷积进入相同任务体系；生成的 irradiance/prefilter texture 继续按完整路径缓存。
- GPU upload 后释放不再需要的 CPU vertex、index 和 decoded image 数据，只保留 bounds、counts、animation 和必要 metadata。
- 对 cache 增加资源数量和估算内存统计。

### 6.3 当前完成状态（2026-07-11）

- [x] glTF 主文件和外部依赖统一经过 Dora `Content`，兼容搜索路径、ZIP package 与跨平台文件来源。
- [x] `Cache.loadAsync` 的读取从 logic thread 发起，callback 回到 logic thread；CPU parse 和预处理进入 worker。
- [x] 全局 upload queue 同时使用 `2ms` CPU 时间预算和 `512 KiB` 字节预算。
- [x] 普通 RGBA8/mip texture、异步 vertex/index buffer 与 environment cubemap 支持跨帧分块上传。
- [x] 同步模型保留 static buffer 路径；异步模型使用可增量填充的 dynamic buffer。
- [x] 取消和 cleanup 清理尚未完成的 GPU 对象。
- [x] 特殊材质异步案例每帧最大上传量为 `524288` bytes，两个案例最大帧均为 `16.7ms`。

### 6.4 动态上传预算方案（deferred）

动态预算具备实现条件，但当前明确不做。固定预算已经解决已知长帧，继续加入反馈控制会扩大实现和跨设备调参成本。

如以后出现“高性能设备加载吞吐不足”或“低端设备在 `512 KiB` 下仍有稳定长帧”的真实数据，可采用有硬边界的 AIMD 控制器：

- 桌面初始 `512 KiB`，移动/WASM 初始 `256 KiB`。
- 硬下限 `128 KiB`；桌面硬上限 `2 MiB`，移动硬上限 `1 MiB`。
- 使用上一完整帧的 `Application.cpuTime`、bgfx GPU time 和 `waitSubmit`，不以受垂直同步影响的 `deltaTime` 作为主要负载指标。
- 高负载时将预算乘 `0.5` 或 `0.75`；连续约 30 帧有充分余量时增加 `64 KiB`。
- 调整后设置 8 至 15 帧冷却期，并使用 EWMA/滞回避免预算振荡。
- 不累计未用完的预算，避免空闲后产生突发大上传；现有 `2ms` CPU 时间限制始终作为独立硬上限。
- 增加 `uploadBudgetBytes` 与 `uploadFrameBytes` 诊断，并在回归中断言实际上传不超过当帧预算。

启动条件：至少在两类性能差异明显的真实设备上证明固定预算存在相反问题，并能建立冷启动 P95/P99 帧时间与总加载时间基线。条件满足前保持 `deferred`，不进入近期实施列表。

### 6.5 验收标准

- 大模型首次解析时主循环仍可响应输入和渲染 UI。
- 单帧 GPU upload 时间受预算控制，不出现数秒无响应。
- 同一路径并发请求只执行一次 parse/upload，并安全合并 callback。
- 加载失败、取消和引擎 cleanup 不遗留半初始化 registry 对象。
- 同步 API 与已有脚本行为保持兼容。

## 7. P4：渲染性能整理

### 7.1 前置条件

只有 P0 statistics 能稳定输出后，才根据 profile 数据实施本阶段。不要仅因存在 `Mutex<HashMap>` 就提前重写整个 renderer。

### 7.2 候选优化

- 在一次 registry 锁定或 scene snapshot 中完成当前帧 visual 收集，减少逐 node/visual 的重复锁和 HashMap 查询。
- world matrix 与 world AABB 仅在 transform dirty 时更新。
- 透明排序距离使用 world bounds center，不使用 node origin。
- opaque sort key 明确编码 program、material、mesh 和 depth bucket。
- 增加提交状态缓存，避免重复绑定相同 program、material、texture 和 buffers。
- 复用 joint matrix、render item 和 traversal buffer。
- mesh 上传后保存 vertex/index count，不依赖 CPU `Vec` 长度。
- 明确超过 64 joints 时的诊断、拆分或回退规则。

### 7.3 性能场景

- 大量静态重复模型。
- 大量不同 material 的小 mesh。
- 透明对象重叠。
- 多个同时播放动画的 skinned model。
- 多 `View3D` 与 2D UI 混排。

性能验收应记录参考机器、分辨率、渲染后端和统计结果，不使用脱离环境的固定 FPS 结论。

## 8. P5：游戏查询、Material3D 与交互 API

### 8.1 Material3D

在内置 shader、灯光和资源生命周期稳定后，再设计公开 `Material3D`。首版只覆盖真实使用需求：

- `materialOverride`
- baseColor
- metallic/roughness
- emissive
- alpha mode/cutoff
- 常用 `Texture2D` 槽位替换
- per-instance 参数，不修改缓存中的共享 material

自定义 shader/program 替换应继续复用 Dora 的 `Effect`/shader cache 思路，但不应在首版把 Rust 内部所有 material 参数原样暴露。

截至 2026-07-11，最小 Material3D 已完成：

- [x] base color、emissive、metallic、roughness、alpha mode/cutoff。
- [x] base color、metallic-roughness、normal、emissive、occlusion `Texture2D` 替换。
- [x] 按 Model3D 实例和材质槽执行 copy-on-write，不修改缓存共享材质。
- [x] wrapper 生命周期由 Model3D instance 管理，cleanup 后不会单独持有 Rust material handle。
- [x] Lua、TS、Teal、Wasm、Rust、Wa 和 C# 绑定。

### 8.2 Model3D 查询能力

- animation name 列表
- 按名称查找导入节点
- local/world bounds
- material slot 查询和 override
- 明确的加载错误信息

当前完成状态：

- [x] `animationCount/getAnimationName()`。
- [x] `hasNode/attachToNode()`，不暴露内部 glTF Node3D wrapper。
- [x] 当前动画姿态对应的 local/world bounds min/max。
- [x] material slot 数量与逐实例 Material3D 查询。
- [x] loading/failed 的错误原因继续由 `Model3DCache` 查询；同步 `Model3D(path)` 构造失败返回空对象，不创建仅用于保存错误的半初始化实例。

### 8.3 Picking

物理系统之前需要的轻量 picking 已完成：

- [x] `Touch.viewLocation` 到 world ray
- [x] ray 与当前动态 world AABB
- [x] 按 scene tree 返回最近 `Model3D`
- [x] `View3D.showAABB` 调试线框
- [延期] mesh triangle 精确测试与 BVH

当前能力已经可服务编辑器选择、点击交互和调试。triangle-level picking 会重新引入 CPU geometry 或 cooked BVH 的内存成本，等待真实误选需求后再设计。

## 9. P6：延期能力

以下能力有价值，但不进入当前可用性主线：

- directional shadow map 与 point light shadow
- LOD、visibility range 和 occlusion culling
- morph target 的高数量/高性能实现
- decal、3D particle 和 post process
- cooked model format、meshopt/Draco/KTX2/BasisU
- JOLT-C 更高规模和原生 arm64 Release 优化（首轮 `100/250/500` body Debug 基线已完成）
- clustered lighting、deferred renderer 或多线程 command recording

开始这些工作前，应先确认 P0 至 P4 已达到稳定基线，并为新增系统单独定义资源和帧时间预算。

## 10. 近期实施建议

建议下一轮开发按以下顺序落地：

1. [x] 补 3D statistics 与通用截图接口。
2. [x] 固定七组自动渲染案例和 cleanup stress，并建立 macOS Metal 基线。
3. [x] 实现 `DirectionalLight3D`，让 `Env=None` 成为正式可用路径。
4. [x] 实现不限场景节点数的 `PointLight3D`，按 render item 执行 Top 4 完整 PBR，并将其余有效灯光聚合为 L1 SH diffuse。
5. [x] 修复 multi-skin、普通 node animation 与 interpolation。
6. [x] 拆分 glTF CPU parse/GPU upload，接入 `Cache.loadAsync`。
7. [x] 将特殊材质纹理重打包移入 worker，并补 anisotropy、sheen+volume 异步截图回归。

本轮完成的是上述七项核心正确性与加载体验目标，并补充了完整 PreparedScene、统一 Content 读取、命令级 upload job、全局时间/字节双预算、纹理/mesh/cubemap 分块上传和特殊材质 worker 预处理。

本组任务完成状态：

1. [x] **环境图异步 preparation**：worker 完成解码、卷积和 face 数据打包，主线程逐 cubemap face/mip 上传。Studio 与 Warm 首次切换均在 22 帧完成，最大帧 `16.7ms`。
2. [x] **模型 CPU 内存收口**：GPU buffer 创建后释放完整 vertex/index 数组，并公开 model/mesh/texture estimated resident bytes。
3. [x] **skinned bounds 正确性**：按 joint influence 保存小型 bounds，动画帧动态变换并与静态 AABB 合并；Fox、multi-skin 和 P0 截图通过。
4. [x] **基于 profile 的 renderer 整理**：upload 保留最近 256 条 phase/time/bytes 记录并公开累计统计；scene visual、skeleton binding/data 和 world matrix 改为批量 snapshot，移除 current-view draw lock，同 mesh submesh 不再重复绑定材质。

本轮实测数据：固定 `512 KiB` 预算下，anisotropy 与 thickness/sheen 特殊材质案例总加载时间分别约为 `0.968s` 和 `0.984s`，每帧实际上传不超过 `524288` bytes，最大帧均为 `16.7ms`；环境 Studio/Warm 异步切换约 22 至 23 帧完成，最大帧 `16.7ms`。49 draw 的 alpha/mask/blend 案例 collect/sort/submit 约为 `0.423/0.008/0.812ms`。

缓存预算、加载状态与取消、shared-material renderer profile、ray/AABB picking 和动态 bounds 极端姿态逻辑回归已经完成。下一组任务调整为：

1. **当前里程碑收口**：更新实现状态、测试说明与绑定文档；重跑 P0、cache lifecycle、renderer profile 和 picking 回归；修正 environment load-state 的声明与实际实现差异，并提交可回退基线。
2. [x] **动画稳态 profile 与复制清理**：`1/10/25/50` 个 Fox profile 已记录 frame、collect、sort 和 submit；clip/node-map clone、采样缓冲重分配和 skeleton topology 深拷贝已消除，renderer 的 traversal/visual/skeleton/world-matrix 主要临时容器改为 per-view workspace 复用。独立 animation update/dynamic bounds 计时仅在后续 profile 证明 collect 分解不足时再增加。
3. [x] **Node3D 语义冻结**：reparent 保留 local TRS 并重算 world，层级修改拒绝 cycle，rotation 在 core 归一化；Rust destroy 与 C++ cleanup 的双向断链规则已有单元/脚本回归。JOLT 复用主 Scheduler fixed accumulator，并采用 kinematic pre-step pull、dynamic post-step write-back 的单向 authority。
4. [x] **JOLT-A 基础接入**：Jolt 5.5.0 已直接编入引擎 C++ 目标，Rust 仅调用引擎导出的 C ABI；已建立 `PhysicsWorld3D` 生命周期、fixed timestep、box/sphere/capsule、静态/动态/运动学刚体，以及 `Body3D` 与 `Node3D` 的单向 authority 变换同步。
5. [x] **JOLT-B 最小游戏 API**：raycast/overlap、collision enter/stay/exit、layer/mask、sensor、force/impulse/velocity、physics debug draw 与 Lua、TS、Teal、Wasm、Rust、Wa、C# 绑定已经完成。集成测试统一在真实 Dora 引擎进程运行。
6. [x] **Model3D 查询与 Material3D**：已补 animation names、动态 local/world bounds、`hasNode/attachToNode` 挂点接口和 clone-on-write 的 per-instance Material3D；内部 glTF Node3D wrapper 未向脚本暴露。独立查询/COW 截图与合入后的 P0 七图、300 次 stress 均通过。
7. **单方向光阴影（已完成）**：单级 directional shadow map 已覆盖 static、skinned 和 alpha-mask；每个 View3D 按需创建独立 attachment，使用 3x3 PCF 和可调 bias。首版不做 CSM 或 point-light shadow。

方向评估：

| 方向 | 近期价值 | 实现风险 | 下一轮决策 |
| --- | --- | --- | --- |
| 动画稳态复制清理 | 已完成首轮：immutable clip/skeleton 使用共享快照，采样和 scene node 容器复用；50 Fox Debug/x86_64 frame P95 为 16.667ms | 低：剩余成本主要是 joint matrix、dynamic bounds 和 draw collect 的线性计算 | 暂停继续抽象，后续由 arm64 Release 或真实游戏 profile 驱动 |
| Node3D 语义冻结 | 高：物理同步和脚本 wrapper 都依赖稳定 transform/lifecycle authority | 中：错误语义会导致双向覆盖或悬空 wrapper | JOLT 开始前必须完成 |
| JOLT-A/B | 已完成游戏 API 闭环：world/body、fixed step、同步、事件、查询、debug draw 和多语言绑定通过真实场景回归 | 中：后续仍需其他 native 平台实机构建与规模化 profile | 保持 API 稳定，以引擎侧集成套件作为回归入口 |
| Model3D 查询与 Material3D | 已完成：动画名、动态 bounds、挂点和实例材质 COW 通过运行回归 | 低到中：后续主要是更多材质参数与错误诊断 | 保持最小 API，暂不暴露内部 node wrapper 或任意 shader uniform |
| 单方向光阴影 | 已完成：Duck static 与 Fox skinned 截图通过 | 已增加按需 render pass、skinned/alpha-mask caster 和固定 1024 attachment | 保持单级方向光边界，CSM/点光阴影延期 |
| 动态上传预算 | 当前不确定：固定 `512 KiB` 已满足现有案例 | 高：跨 backend 反馈延迟、振荡和调参成本 | `deferred`，等待跨设备证据 |

动态上传预算、triangle BVH、LOD、cooked model format 和 Forward+/clustered lighting 不进入本轮基础任务。动态预算等待跨设备固定预算失效的证据；triangle BVH 需要先决定 CPU geometry/BVH 的额外内存预算。JOLT-C 的 character controller、compound/mesh/convex hull shape、fixed/distance/hinge constraint、physics debug draw 和首轮规模化 profile 已完成，glTF morph target 也已完成 CPU 首版。

OpenGL、OpenGLES 和 Vulkan 的硬件视觉基线已延期，待具备真实 GPU self-hosted runner 或设备农场后再恢复，不占用近期开发顺序。

上述核心正确性、加载体验、基础交互、JOLT 最小游戏 API、JOLT-C 角色/复杂形状/最小约束、Model3D 查询、最小 Material3D、glTF morph target 和单方向光阴影已完成，Dora 3D 已从“模型查看器可用”进入“轻量游戏场景可用”。本轮 Jolt C ABI 收口、JOLT-C 规模化性能/诊断基线、动态 convex hull 和 glTF morph target 均已完成。动态上传预算、CSM、point-light shadow、高数量 GPU morph 和更复杂 renderer 能力继续保持独立里程碑。
