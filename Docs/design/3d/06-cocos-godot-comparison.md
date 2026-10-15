# Dora 3D 方案外部参考分析：Cocos2d-x 与 Godot

## 1. 调研范围

本文基于 2026 年 3 月 13 日可访问的官方资料，重点观察三个方向：

- Cocos2d-x 在后续版本中是如何把 3D 功能接到原本偏 2D 的引擎架构里的
- Godot 是如何从一开始把 3D 作为一等能力组织在场景树、资源系统、渲染层和导入链路里的
- raylib 是如何以极简库式 API 提供 3D 能力，而不强加完整场景图架构的

本文不追求完整复述全部 API，而是关注对 Dora 后续 3D 设计最有价值的问题：

- 3D 场景节点如何分层
- Mesh / Material / 实例节点之间如何解耦
- 渲染层与场景层的边界如何划分
- 资源导入与运行时资源对象如何设计
- 哪些设计适合 Dora 借鉴，哪些不适合

## 2. 结论先行

### 2.1 一句话结论

如果只看 Dora 当前代码基础，最值得学的是：

- 从 Cocos2d-x 学“如何低成本把 3D 接进一个原本以 2D 节点树为中心的引擎”
- 从 Godot 学“如何把 3D 节点、3D 资源、渲染实例、导入流程分层清楚”
- 从 raylib 学“如何把 3D 的最小运行时对象和 API 边界压到足够简单”

### 2.2 对 Dora 最关键的判断

对 Dora 来说，最合理的路线不是完全照抄任何一方，而是：

- 架构层借 Godot
- 迁移成本控制借 Cocos2d-x

更具体地说：

1. 不要走 Cocos2d-x 那种把 3D 主渲染节点命名成 `Sprite3D` 的路线。
2. 要走 Godot 那种 `Node3D -> Visual3D/Geometry3D -> Mesh 实例节点` 的分层思路。
3. 但不要把 Godot 的 Server/RID 体系整个搬进 Dora 首版 3D，否则重构成本过高。
4. 不要走 raylib 那种“完全不给场景图约束”的路线，因为 Dora 已经是引擎，不只是图形库。
5. Dora 首版应先做“半步 Godot 化”：节点层、资源层、渲染提交流程分清，但不强制引入完整服务器架构。
6. 结合最新讨论，Dora 不应继续把 `Node3D` 建成 `Node` 的子类，也不必强行引入 `NodeBase`，而应直接建立独立 `Node3D` 场景树。

## 3. Cocos2d-x 的 3D 设计观察

## 3.1 设计出发点

Cocos2d-x 的 3D 很明显是“在 2D 引擎上增量加出来的”。

从官方文档看，它的核心思路是：

- 继续沿用 `Node`
- 把 `Camera` 也当作 `Node`
- 用 `Sprite3D` 作为主要 3D 可见对象
- 用 `Animation3D` / `Animate3D` 延续原有 Action 体系
- 用 `Material` / `ProgramState` 给节点换 shader 与参数

这条路线的优点是迁移成本低，原来会用 `Sprite` / `Node` / `Action` 的用户很容易上手；缺点是 3D 的概念层次和 2D 混在一起，命名和职责边界不够干净。

官方资料里能明显看出这种“2D 风格延续”：

- `Sprite3D` 被描述为“像普通 Sprite 一样工作，只是可以在 x/y/z 三轴定位”。
- `Camera` 继承 `Node`，因此继续支持多数 `Action`。
- `Animation3D` / `Animate3D` 被明确说成“3D 动画和 2D 是一样的概念”。

## 3.2 场景图层

### 观察

Cocos2d-x 没有在设计上把 3D 树和 2D 树彻底拆开，而是继续让 3D 节点挂在同一套 `Node` 树上。

优点：

- 兼容旧系统极强
- 生命周期、Action、事件、脚本绑定都可复用
- 对已有 2D 团队学习成本低

缺点：

- 3D 专用语义不够强
- 可见对象、几何对象、资源对象之间容易混在一起
- 节点 API 更像“带 3D 坐标的 2D Node”，而不是完整 3D 语义对象

### 对 Dora 的启发

这证明了一件事：Dora 完全可以复用现有节点树实现思路，而不必复制两套完全独立的 runtime。

但 Dora 不应该继续使用 Cocos 的命名和模型抽象，因为 Dora 已经在代码里具备了比 Cocos 当年更好的基础：

- `Node` 已有 4x4 world matrix
- 已有 `CameraBasic` / `CameraUI3D`
- 已有 `Pass` / `ShaderCache`

所以 Dora 现在有条件比 Cocos 当年的方案做得更干净：

- 保留 `Node` 作为默认 2D 树
- 通过独立 `Node3D` 分离 3D 语义

## 3.3 3D 可见节点：`Sprite3D`

### 观察

`Sprite3D` 的设计非常代表 Cocos2d-x 的路径：

- 它是主要 3D 显示节点
- 可以直接从 `.obj`、`.c3t`、`.c3b` 创建
- 节点上可访问 mesh
- 还能通过 attach node 在骨骼挂点上继续挂子节点

这套设计很实用，但问题也很明显：

- “Sprite” 这个名字对静态网格、骨骼角色、复杂模型都不准确
- 节点和资源的边界不够清楚
- `Sprite3D` 容易承担过多职责：加载、显示、材质、挂点、动画入口都放在一起

### 优点

- 用户视角简单
- API 迁移平滑
- 功能收口在一个主入口上

### 缺点

- 概念污染严重
- 难以自然扩展成多种 3D 可见对象层次
- 后续做 instancing、LOD、可见性控制时抽象容易别扭

### 对 Dora 的启发

不建议 Dora 采用 `Sprite3D` 路线。更合理的命名和分层是：

- `Node3D`
- `Visual3D` 或 `Geometry3D`
- `Model3D`
- `Mesh`
- `Material`

也就是说，Dora 应吸取 Cocos “低成本复用节点树”的优点，但避免“把 3D 模型抽象成 Sprite”的命名与职责混乱。

## 3.4 材质与 shader

### 观察

Cocos2d-x 在 3D 上并不是只靠固定管线。官方文档明确描述了：

- 渲染节点可直接换 `ProgramState`
- `ProgramState` 里包含 program 与 uniform state
- 更高层则提供 `Material`
- `Material` 文件支持 `material / technique / pass / renderState / shader`
- `Material` 还能继承父材质

这套设计的优点是：

- 对小型引擎很实用
- 允许手写 pass 和 render state
- 比完全固定材质模型灵活

但缺点是：

- 更像“渲染状态脚本”
- 资源层和实例层的区分仍不够彻底
- 节点如何覆盖局部材质、mesh 层材质、实例层材质，没有 Godot 那么清楚

### 对 Dora 的启发

Cocos 的 `material -> technique -> pass` 思路非常值得 Dora 借用，因为 Dora 当前 `Pass/Effect/ShaderCache` 已经和这个方向很接近。

可借鉴点：

- 材质资源定义支持多 pass
- render state 明确入材质体系
- 材质允许继承与覆写

不建议照搬点：

- 让节点直接深度耦合 `ProgramState`
- 让 mesh 自身同时承担太多材质状态

## 3.5 资源格式与导入

### 观察

Cocos2d-x 的 3D 文件策略是：

- 支持 `.obj`
- 支持自有 `.c3t` / `.c3b`
- 官方工具 `fbx-conv` 把 FBX 转成 Cocos 自有格式

官方文档还明确给出了这些限制：

- 模型材质至少要有一张纹理
- 只支持 skeletal animation
- 只支持一个 skeleton
- 每个 mesh 的顶点或索引上限为 32767

这体现出 Cocos 的 3D 资产链路是“引擎内聚、可控，但封闭且有历史包袱”的。

### 优点

- 运行时加载简单
- 引擎可控性高
- 转换后格式可针对自身优化

### 缺点

- 资产工作流不现代
- 自有格式增加工具链负担
- 对第三方 DCC 生态兼容不够自然

### 对 Dora 的启发

这一点 Dora 更应该站到今天的角度，直接学 Godot 而不是学 Cocos：

- 主格式使用 glTF / glb
- OBJ 只做 fallback
- 不优先发明新的 Dora 专有 3D 格式

只有在后期确有性能或打包需求时，再考虑在 glTF 之上增加 Dora 自己的 cooked/binary cache。

## 3.6 相机与渲染顺序

### 观察

Cocos2d-x 让 `Scene` 默认创建相机，并通过 camera flag / node mask 控制可见性。官方 API 还明确提到：

- 默认相机通常最后绘制
- 3D 对象通常建议放到单独相机
- 对每个相机，透明 3D 会在不透明 3D 和其他 2D 对象之后绘制

这说明 Cocos 的 3D/2D 混合主要靠：

- 多相机
- camera mask
- 每相机内的透明/不透明分段

### 对 Dora 的启发

Dora 已有 `Director`、多相机、`UI`、`UI3D`、`PostNode`，其实比 Cocos 当年的主路径更接近一个可显式组织的多 pass 系统。

所以 Dora 不必照搬 camera-mask-first 的组织，而可以采用更清晰的：

- `RenderPass3D`
- `Scene2D`
- `UI3D`
- `UI`
- `Post`

但 Cocos 的经验提醒 Dora：2D/3D 混排顺序必须在设计阶段就写死，否则后期会出现深度、透明和 UI 覆盖关系混乱。

## 3.7 Cocos2d-x 方案总评价

### 值得学习

- 增量接入 3D，尽量复用原有 `Node` / `Action` / `Camera`
- 用材质文件而不是硬编码 shader 组合
- 多相机和 culling 在同一体系内协作

### 不建议学习

- `Sprite3D` 这种命名与职责混合
- 专有 3D 资源格式优先
- 让 3D 动画过度依附 2D Action 语义
- 让节点本身承担过多 mesh/material/load 责任

## 4. Godot 的 3D 设计观察

## 4.1 设计出发点

Godot 的 3D 不是“后加的功能块”，而是从引擎架构上被当作一层完整系统组织的。

官方架构文档把系统分成：

- Scene layer
- Server layer
- Drivers / Platform layer

其中 Scene layer 管高层节点树，Server layer 管 rendering / physics / audio 等底层子系统。

这意味着 Godot 的关键思想不是“节点直接做一切”，而是：

- 节点负责用户语义
- 资源负责数据复用
- 服务器/实例层负责底层执行

## 4.2 `Node3D` 是真正的 3D 基类

### 观察

Godot 的 `Node3D` 是所有 3D 节点的基类，3D 相关节点大面积从它继承，包括：

- `Camera3D`
- `CollisionObject3D`
- `VisualInstance3D`
- `Skeleton3D`
- `RayCast3D`

这和 Cocos 把 3D 继续塞进通用 `Node` 的做法很不同。

### 优点

- 3D 语义明确
- 类型树清晰
- 2D 与 3D 能力边界自然

### 缺点

- 架构门槛更高
- 引擎内部抽象层更多
- 对已有 2D-only 引擎迁移成本更大

### 对 Dora 的启发

这一点对 Dora 很关键。Dora 应新增 `Node3D`，但不需要像 Godot 那样把所有内部系统一夜之间全部迁移到 `Node3D` 体系。

更适合 Dora 的做法是：

- API 层学 Godot：引入 `Node3D`
- 实现层保守：复用现有数学实现思路与运行时经验，但不强行复用 `Node` 类型层级

这正是“架构层借 Godot，成本控制借 Cocos”。

## 4.3 `VisualInstance3D`：节点与渲染实例的边界

### 观察

Godot 的一个非常重要的设计点是 `VisualInstance3D`。

官方文档对它的描述很关键：

- 它是所有视觉 3D 节点的父类
- 它是 `RenderingServer` instance 的节点表示
- 它能设置 base RID，也能拿到 instance RID

这意味着 Godot 在节点层和底层渲染对象之间，专门放了一层“视觉实例桥接层”。

这层的价值非常大：

- 节点树仍然友好
- 但渲染层对象可以独立组织
- 节点语义和底层提交句柄分离

### 对 Dora 的启发

这是 Dora 最值得借鉴的点之一。

我建议 Dora 在 `Node3D` 之上再抽一层，而不是直接 `Model3D : Node3D` 承担全部职责。两种可选命名：

- `Visual3D`
- `Geometry3D`

推荐结构：

- `Node3D`
  - 纯 3D 变换与场景语义
- `Visual3D`
  - 有渲染实例、有 bounds、有 layer mask、有 culling 入口
- `Model3D`
  - 持有 `Mesh` 和 `Material`

这能显著降低后续扩展灯光、体积、贴花、粒子、实例化网格时的混乱。

## 4.4 Mesh / Material / 实例节点的分层

### 观察

Godot 的 3D 分层是很清楚的：

- `Mesh` 是资源
- `MeshInstance3D` 是节点
- `GeometryInstance3D` 提供材质覆盖、可见性、LOD、culling 相关共性
- `Material` 也是资源

更重要的是，Godot 明确支持多层材质归属：

- 材质挂在 mesh 上
- 材质挂在节点上
- `material_override`
- `material_overlay`

这是一种非常成熟的实例层覆盖体系。

### 优点

- 资源复用自然
- 每层职责非常清晰
- 实例层覆写逻辑强
- 更适合大型项目和编辑器工作流

### 缺点

- 抽象层次更多
- 初学者不如 Cocos 直观

### 对 Dora 的启发

Dora 非常值得直接借这套分层，但可以做轻量化版本：

- `Mesh` 作为纯资源
- `Material` 作为纯资源或资源型实例
- `Model3D` 作为节点实例
- 节点上允许：
  - submesh material override
  - 整体 material override
  - 可选 overlay / next pass

这一点比 Cocos 的“节点直接 setMaterial”更适合 Dora 长期扩展。

## 4.5 `GeometryInstance3D`：可见性、AABB、LOD、实例参数

### 观察

Godot 把很多运行时 3D 共性都收在 `GeometryInstance3D` 上，例如：

- `custom_aabb`
- `extra_cull_margin`
- `material_override`
- `material_overlay`
- `transparency`
- visibility range
- per-instance shader parameter

这说明 Godot 对“几何对象的实例属性”和“材质资源本身”区分得很清楚。

### 对 Dora 的启发

Dora 未来很可能也会需要这些能力：

- 自定义 bounds
- cull margin
- visibility range / LOD hook
- per-instance uniform

所以 Dora 首版虽然不必全部实现，但架构上应该预留这些字段放在哪一层。最合理的位置不是 `Mesh`，也不是 `Material`，而是 `Visual3D/Geometry3D` 实例层。

## 4.6 材质系统

### 观察

Godot 的默认 3D 材质是：

- `StandardMaterial3D`
- `ORMMaterial3D`

它们明确是“给艺术家用的标准材质”，不用先写 shader，就能覆盖大多数 3D 项目需求；同时又能转成 shader code 做扩展。

这背后的设计思想是：

- 默认材质应足够强大
- 自定义 shader 是进阶路径，不应是首选入口

### 对 Dora 的启发

Dora 首版没必要一上来就把材质系统设计成“所有东西都靠自定义 shader 拼”。更合理的路径是：

- 先提供 2~3 个标准材质类型
  - `Unlit`
  - `LambertLit`
  - 后续 `PBR`
- 再允许材质底层绑定自定义 `Pass`

这会比直接暴露低层 shader/pipeline 对脚本用户更友好。

## 4.7 资源导入与工作流

### 观察

Godot 在 3D 上的导入设计很成熟，官方文档里能看到：

- `ResourceImporterScene` 可导入 glTF、FBX、Collada、Blender 场景
- 可在导入阶段生成 tangents、LOD、shadow mesh
- 可配置 root node 类型、root scale
- 可以把导入结果保留为场景，并用 scene inheritance 做本地修改

这套体系的核心不是“运行时直接解析原文件”，而是：

- 编辑器/导入器先把源资产转成更适合运行时的内部资源与场景
- 运行时使用的是已处理好的资产

### 对 Dora 的启发

Dora 当前没有 Godot 那么重的编辑器与 import pipeline，所以不能完全照搬。

但可以借鉴三点：

1. glTF 应作为主输入格式。
2. 导入结果最好区分“源文件”和“运行时缓存文件”。
3. 对 tangents、LOD、bounds、默认材质等预处理，应该放在导入阶段，而不是每次运行时现算。

短期方案：

- 运行时先直接支持 glTF / glb

中期方案：

- 增加 Dora 自己的 import/cook step，把 glTF 处理成更适合引擎缓存的格式

## 4.8 Server / RID 架构

### 观察

Godot 官方架构和相关文章都明确强调：

- scene system 是高层
- rendering/physics 等由 server 处理
- 节点和资源内部都持有对 server 对象的 RID/句柄

这个架构的价值在于：

- 高层语义与低层执行分离
- 更利于多线程、命令缓冲和统一资源管理

### 优点

- 结构长期可扩展
- 便于跨线程和后台处理
- 节点层不必直接承担渲染细节

### 缺点

- 实现复杂度显著上升
- 需要全引擎一致贯彻
- 对 Dora 这种当前以直接节点/渲染调用为主的架构来说，迁移成本极高

### 对 Dora 的启发

这是 Godot 最“不适合直接照搬”的部分。

对 Dora 来说，更现实的方案是部分吸收其思想，而不是照搬其机制：

- 学“节点语义层”和“渲染执行层”分开
- 不学“首版就上完整 Server/RID 中枢”

对应到 Dora 首版 3D：

- 有一个 `RenderPass3D` 作为提交边界
- `Visual3D` / `Model3D` 只向它提交 draw item
- 暂时不需要独立 `RenderingServer3D`

如果未来 Dora 要进一步做：

- 多线程渲染录制
- 大量实例化
- 编辑器级 3D 运行时

再考虑是否向 Godot 的 server 模式演进。

## 4.9 Godot 方案总评价

### 值得学习

- `Node3D` 作为 3D 语义基类
- `VisualInstance3D` 作为节点与渲染实例桥层
- `GeometryInstance3D` 收敛几何实例通用属性
- `Mesh` / `Material` / 实例节点严格分层
- 标准材质优先、自定义 shader 作为进阶路径
- glTF 导入链路与导入期预处理

### 不建议 Dora 首版照搬

- 完整 Server / RID 架构
- Godot 级别的导入器、编辑器和场景继承系统
- 过于完整的 3D 节点族一次性铺开

## 5. raylib 的 3D 设计观察

## 5.1 设计出发点

raylib 的核心定位不是“完整游戏引擎”，而是“简单、直接、易上手的多媒体/图形库”。它的官方首页明确强调简单易用，并把 3D 支持描述为：

- 基础 3D 形状
- 3D 模型
- billboard
- heightmap
- shader

这意味着 raylib 的 3D 设计哲学不是“先定义复杂场景图”，而是“先给你足够少的对象和足够直接的函数”。

从官方 cheatsheet 和 API 可以看出，raylib 的 3D 最核心对象就是：

- `Camera3D`
- `Mesh`
- `Material`
- `Model`
- `Matrix`

配套核心操作是：

- `BeginMode3D(camera)`
- `DrawModel(...)`
- `DrawMesh(mesh, material, transform)`
- `DrawMeshInstanced(...)`

换句话说，raylib 的 3D 重心在：

- 直接绘制
- 显式资源结构
- 显式相机
- 最小抽象

而不在：

- 场景节点语义
- 生命周期管理
- 资源导入流水线
- 编辑器级场景组织

## 5.2 场景图层

### 观察

raylib 基本没有强场景图概念。它更像是：

- 你自己维护游戏对象
- 每帧自己更新
- 每帧显式调用绘制函数

这点和 Godot、Cocos2d-x 都非常不一样。

优点：

- API 极其直接
- 没有被引擎结构强约束
- 对小型项目、教学、原型非常友好

缺点：

- 大项目缺少结构支撑
- 节点关系、可见性组织、生命周期、层级变换都要用户自己搭
- 资源与实例关系虽简单，但缺少更高层语义

### 对 Dora 的启发

raylib 的“弱结构”不适合直接照搬到 Dora，因为 Dora 已经不是单纯图形库，而是带脚本、节点和运行时的引擎。

但它提醒 Dora 一件重要的事：

- 3D 首版的运行时对象应该尽量少、尽量直接

也就是说 Dora 不应该在首版 3D 一开始就铺太多节点族和编辑器抽象。

## 5.3 资源对象分层

### 观察

raylib 的 3D 分层很“扁平”：

- `Mesh` 是几何数据
- `Material` 是 shader + texture maps + 参数
- `Model` 是 mesh/material 的聚合体，并带一个 `transform`

这是非常实用的运行时组织方式：

- 简单
- 清楚
- C 风格结构体友好

但缺点也明显：

- `Model` 更像运行时数据包，而不是场景语义节点
- 节点层实例覆盖、材质 override、可见性分层基本都需要用户自己搭

### 对 Dora 的启发

这点对 Dora 有正面借鉴价值：

- 首版 3D 的运行时核心资源对象可以保持简单
- `Mesh`、`Material`、`Model3D` 的边界要足够清楚

但 Dora 不应停在 raylib 这一层，因为 Dora 还需要：

- 场景树
- 生命周期
- 脚本绑定
- 2D/3D 桥接

## 5.4 相机设计

### 观察

raylib 使用 `Camera3D` 作为显式数据结构，再通过 `BeginMode3D(camera)` 启用 3D 绘制上下文。

这套模式的特点是：

- 相机不是重型场景节点
- 相机就是一个清晰的数据输入
- 切换 3D 视图上下文非常直接

### 对 Dora 的启发

虽然 Dora 已经有 `Director` 和 camera stack，不会照搬 `BeginMode3D` 模式，但 raylib 提醒 Dora：

- `Camera3D` 的用户接口应该尽可能简单
- 不要把相机 API 设计得过于重或过于编辑器导向

## 5.5 材质与 shader

### 观察

raylib 的 `Material` 设计非常实用：

- 材质里直接有 `Shader`
- 材质里有不同 `MaterialMap`
- 模型可按 mesh/material slot 对应绘制

这是一套典型的“够用优先”材质模型。

优点：

- 学习成本低
- 运行时访问简单
- 非常适合首版 3D 系统

缺点：

- 高级材质系统扩展有限
- shader variant、render pipeline、材质继承等高级组织不足

### 对 Dora 的启发

raylib 的材质思路可以用来约束 Dora 首版复杂度：

- 首版 `Material` 不要一开始就做成非常重的资源图谱系统
- 先把“shader + textures + uniform + render state”这条最短路径做好

## 5.6 模型导入与格式

### 观察

raylib 官方 API 和 cheatsheet 强调的是：

- `LoadModel`
- `LoadModelFromMesh`
- `LoadMesh`

也就是说，它站在运行时直接可用对象的角度看问题，而不是先强调完整 importer pipeline。

这很符合它“库”的定位。

### 对 Dora 的启发

这再次说明 Dora 首版 3D 不要先陷进大型导入器工程。更合理的顺序是：

1. 先有稳定的运行时对象
2. 再把 glTF 导入到这些对象上
3. 最后再考虑 import/cook pipeline

## 5.7 raylib 方案总评价

### 值得学习

- 运行时对象少而直接
- `Camera3D / Mesh / Material / Model` 的边界简单清楚
- 3D 绘制入口明确
- 很适合首版 3D 最小闭环

### 不建议 Dora 照搬

- 几乎无场景图约束
- 过多依赖用户手写组织逻辑
- 不提供足够的实例层语义
- 缺乏对引擎级脚本运行时的天然支撑

## 6. Cocos2d-x、Godot 与 raylib 的核心对比

| 维度 | Cocos2d-x | Godot | raylib | 对 Dora 的建议 |
|---|---|---|---|---|
| 3D 接入方式 | 在 2D 节点树上增量加入 | 3D 是一等系统 | 直接暴露 3D 绘制 API | 保留 `Node`，新增独立 `Node3D` |
| 3D 基类 | 继续主要依赖 `Node`，主渲染节点是 `Sprite3D` | `Node3D` 明确为 3D 基类 | 无强场景图基类 | 独立 `Node3D`，不继承 `Node` |
| 可见节点抽象 | `Sprite3D` 偏一体化 | `VisualInstance3D` / `GeometryInstance3D` 分层清楚 | `Model` 偏运行时数据包 | 新增 `Visual3D` |
| Mesh 与实例关系 | 节点与 mesh/material 边界较模糊 | `Mesh` 资源 + `MeshInstance3D` 节点 | `Mesh` + `Material` + `Model` 扁平结构 | 明确 `Mesh` 资源化 |
| 材质系统 | `Material / technique / pass`，很实用 | 标准材质 + override/overlay + shader | 简单直接，运行时够用 | 首版走简单材质，底层保留 pass 扩展 |
| 导入链路 | `.obj` + 自有 `.c3b/.c3t` | glTF 等标准格式 + importer | 更偏运行时直接加载 | 直接用 glTF，后续再考虑 cook |
| 动画理念 | 延续 2D Action 风格 | 资源、节点、骨骼系统分层 | 运行时 API 直接控制 | 首版先不把 3D 动画完全绑定到 Action |
| 渲染层架构 | 更贴节点驱动 | 节点层和 server 层分离 | 直接 `DrawModel/DrawMesh` | 先用 `RenderPass3D` 作为边界 |
| 复杂度 | 低，易接入 | 高，但长远更健康 | 很低，但约束少 | 首版吸收 raylib 的简洁、Godot 的分层 |

## 7. 对 Dora 的具体借鉴建议

## 6.1 应直接借鉴的设计点

### 来自 Godot

- `Node3D` 作为显式 3D 基类
- `Visual3D/Geometry3D` 作为 3D 可见实例层
- `Mesh`、`Material` 与节点实例解耦
- 实例层支持：
  - `material_override`
  - per-instance uniform
  - bounds / culling hook
- glTF 作为主格式

### 来自 Cocos2d-x

- 复用现有运行时思路和工具，不强求共用同一套节点类型
- 复用现有 action/scheduler/event/binding 能力
- 材质体系可采用 `material -> technique -> pass` 风格组织底层

### 来自 raylib

- 首版运行时对象尽量少而直接
- `Camera3D / Mesh / Material / Model` 的边界要简单清楚
- 不要一开始就堆太多高层抽象

## 7.2 应谨慎借鉴的设计点

### 来自 Cocos2d-x

- 多相机 + mask 方式可以保留，但不应成为 3D 管线的唯一组织手段
- 3D 动画可暂时借 action/scheduler，但不能长期只靠 action 抽象

### 来自 Godot

- visibility range、LOD、instance shader parameters 很好，但首版应只预留，不必一次性做完

### 来自 raylib

- 极简 API 很好，但不能因为追求简单而丢掉 Dora 作为引擎所需的场景语义

## 7.3 不建议借鉴的设计点

### 不建议学 Cocos2d-x 的

- `Sprite3D` 命名
- `.c3b/.c3t` 这种专有格式优先策略
- 让节点直接承担所有 3D 资源与渲染状态

### 不建议学 Godot 首版就做的

- 完整 Server/RID 体系
- 复杂导入器、场景继承、编辑器联动一次性做全

### 不建议学 raylib 的

- 完全不提供场景图约束
- 把太多组织责任留给用户手写
- 用库式 API 取代引擎级节点语义

## 8. 对 Dora 3D 架构的修正建议

结合本次调研，我建议把 Dora 之前那组 3D 设计文档中的实现结构再进一步收敛成下面这样：

### 8.1 推荐结构

- `Node3D`
  - 3D 语义基类
- `Visual3D`
  - 3D 可见实例基类
  - 有 bounds、visibility、layer、culling、instance parameters
- `Model3D : Visual3D`
  - 持有 `Mesh`
  - 持有 material slots
- `Camera3D`
  - 基于现有 `Camera`
- `Material`
  - 标准材质 + 底层 pass
- `Mesh`
  - 纯资源
- `RenderPass3D`
  - 统一收集与提交 3D draw item

### 8.2 对原方案的一个重要增强

原方案里 `Model3D` 直接继承 `Node3D` 是可行的，但从 Godot 的经验看，最好中间多一层 `Visual3D`。

原因：

- 后续灯光、贴花、粒子、可见性通知器、实例化网格都不应都直接继承 `Node3D`
- 有一层统一的可见对象基类，会让 render queue、culling、debug、layer mask 更整齐

## 9. 推荐实施路线

## 9.1 Dora Phase 1

借鉴 Cocos 的低成本路线，并吸收 raylib 的简洁运行时对象：

- 复用现有相机栈、渲染顺序系统和数学实现思路
- 保留 `Node`，新增独立 `Node3D`、`Visual3D`、`Model3D`
- 新增 `Mesh`、`Material`、`RenderPass3D`
- glTF 直载

## 9.2 Dora Phase 2

借鉴 Godot 的资源与实例分层：

- `material_override`
- per-instance shader parameters
- AABB / culling / visibility range
- LOD hook
- import/cook step

## 9.3 Dora Phase 3

在需要时再向更强的分层推进：

- 后台导入
- 多线程命令录制
- 更独立的 render scene / render instance 层

## 10. 最终建议

对 Dora 来说，最优解不是“选 Cocos”或“选 Godot”，而是分层借鉴：

### 战术层

学 Cocos2d-x：

- 先把 3D 低成本接进现有引擎
- 保住现有脚本和节点生态

同时学 raylib：

- 保持运行时对象少而直接
- 首版先把 3D 最小闭环跑通

### 战略层

学 Godot：

- 尽早把 3D 节点语义、资源对象、渲染实例、导入流程拆清楚
- 避免 3D 变成一堆“挂在 Node 上的特殊 case”

### 落到 Dora 的一句话架构建议

让 Dora 的 3D 首版“运行时对象像 raylib 一样直接，接入成本像 Cocos2d-x 一样可控，结构分层像 Godot 一样干净”。

## 11. 参考资料

以下为本文主要参考来源：

- Cocos2d-x `Sprite3D` 文档：
  - [https://docs.cocos2d-x.org/cocos2d-x/v4/en/3d/sprite3d.html](https://docs.cocos2d-x.org/cocos2d-x/v4/en/3d/sprite3d.html)
- Cocos2d-x `Camera` 文档：
  - [https://docs.cocos2d-x.org/cocos2d-x/v4/en/3d/camera.html](https://docs.cocos2d-x.org/cocos2d-x/v4/en/3d/camera.html)
- Cocos2d-x 3D 动画文档：
  - [https://docs.cocos2d-x.org/cocos2d-x/v4/en/3d/animation.html](https://docs.cocos2d-x.org/cocos2d-x/v4/en/3d/animation.html)
- Cocos2d-x shaders/materials 文档：
  - [https://docs.cocos2d-x.org/cocos2d-x/v4/en/advanced_topics/shaders.html](https://docs.cocos2d-x.org/cocos2d-x/v4/en/advanced_topics/shaders.html)
- Cocos2d-x 3D tools / file format 文档：
  - [https://docs.cocos2d-x.org/cocos2d-x/v3/en/3d/tools.html](https://docs.cocos2d-x.org/cocos2d-x/v3/en/3d/tools.html)
- Cocos2d-x `Mesh` API：
  - [https://docs.cocos2d-x.org/api-ref/cplusplus/v4x/d3/db9/classcocos2d_1_1_mesh.html](https://docs.cocos2d-x.org/api-ref/cplusplus/v4x/d3/db9/classcocos2d_1_1_mesh.html)
- Cocos2d-x `Sprite3DMaterial` API：
  - [https://docs.cocos2d-x.org/api-ref/cplusplus/v3x/df/d83/classcocos2d_1_1_sprite3_d_material.html](https://docs.cocos2d-x.org/api-ref/cplusplus/v3x/df/d83/classcocos2d_1_1_sprite3_d_material.html)
- Cocos2d-x `Frustum` API：
  - [https://docs.cocos2d-x.org/api-ref/cplusplus/V3.11/d5/d8a/classcocos2d_1_1_frustum.html](https://docs.cocos2d-x.org/api-ref/cplusplus/V3.11/d5/d8a/classcocos2d_1_1_frustum.html)
- Cocos2d-x `CameraFlag` 说明：
  - [https://docs.cocos2d-x.org/api-ref/cplusplus/v3x/d2/dc0/namespacecocos2d.html](https://docs.cocos2d-x.org/api-ref/cplusplus/v3x/d2/dc0/namespacecocos2d.html)

- raylib 官方首页：
  - [https://www.raylib.com/](https://www.raylib.com/)
- raylib cheatsheet：
  - [https://raylib.pages.dev/](https://raylib.pages.dev/)
  - [https://www.raylib.com/cheatsheet/raylib_cheatsheet_v5.0.pdf](https://www.raylib.com/cheatsheet/raylib_cheatsheet_v5.0.pdf)
- raylib architecture wiki：
  - [https://github-wiki-see.page/m/raysan5/raylib/wiki/raylib-architecture](https://github-wiki-see.page/m/raysan5/raylib/wiki/raylib-architecture)

- Godot `Node3D`：
  - [https://docs.godotengine.org/en/stable/classes/class_node3d.html](https://docs.godotengine.org/en/stable/classes/class_node3d.html)
- Godot `VisualInstance3D`：
  - [https://docs.godotengine.org/en/stable/classes/class_visualinstance3d.html](https://docs.godotengine.org/en/stable/classes/class_visualinstance3d.html)
- Godot `GeometryInstance3D`：
  - [https://docs.godotengine.org/en/stable/classes/class_geometryinstance3d.html](https://docs.godotengine.org/en/stable/classes/class_geometryinstance3d.html)
- Godot `StandardMaterial3D` / `ORMMaterial3D`：
  - [https://docs.godotengine.org/en/stable/tutorials/3d/standard_material_3d.html](https://docs.godotengine.org/en/stable/tutorials/3d/standard_material_3d.html)
- Godot `ResourceImporterScene`：
  - [https://docs.godotengine.org/en/stable/classes/class_resourceimporterscene.html](https://docs.godotengine.org/en/stable/classes/class_resourceimporterscene.html)
- Godot 架构总览：
  - [https://docs.godotengine.org/en/stable/engine_details/architecture/godot_architecture_diagram.html](https://docs.godotengine.org/en/stable/engine_details/architecture/godot_architecture_diagram.html)
- Godot servers / RIDs：
  - [https://docs.godotengine.org/en/stable/tutorials/performance/using_servers.html](https://docs.godotengine.org/en/stable/tutorials/performance/using_servers.html)
  - [https://godotengine.org/article/why-does-godot-use-servers-and-rids/](https://godotengine.org/article/why-does-godot-use-servers-and-rids/)
