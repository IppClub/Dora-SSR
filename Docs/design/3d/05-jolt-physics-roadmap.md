# Dora 3D 与 JOLT 物理接入路线图

## 1. 现状判断

当前仓库已并行保留基于 `playrho` 的 2D `PhysicsWorld`，并将 Jolt Physics 5.5.0 作为 3D 物理后端直接编入引擎 C++ 目标。两套系统不共享 world、body 或 shape 类型。

Jolt 的编译与 native instance 生命周期属于 C++ 引擎边界，`Source/Physics/JoltBridge.cpp` 只导出 C ABI；Rust crate 通过 `extern "C"` 调用该 ABI，自身不运行 C++ 编译器。C++ wrapper 调用 Rust core 时继续使用 Rust 导出的 C ABI。任一方向都不跨边界传递 STL、Rust 容器或 Jolt C++ 类型。

截至 2026-07-11：

- JOLT-A 已完成 world/body 生命周期、box/sphere/capsule、static/dynamic/kinematic authority 和主 Scheduler fixed step 接入。
- JOLT-B 已完成碰撞 Enter/Stay/Exit、layer/mask、sensor、raycast/overlap、velocity、force/impulse 及 Lua、TS、Teal、Wasm、Rust、Wa、C# 绑定。
- `Physics3D.ts` 真实运行回归通过，动态刚体稳定落地，事件与查询均产生预期结果。
- physics debug draw 已接入 3D renderer：box、sphere、capsule 使用对应 primitive 线框，compound/mesh 等复杂形状使用 world AABB 回退。

这意味着：

- JOLT 不是“渲染 3D 首版”的附属小改动
- JOLT 是新的运行时子系统
- 必须拆成独立里程碑

因此本设计明确建议：

- 3D 渲染首版不依赖 JOLT
- 在场景、资源、动画、缓存和基础 picking 闭环完成后启动 JOLT
- JOLT 提前到 Material3D 与 shadow 之前，作为 Dora 3D 从展示进入游戏玩法的下一阶段

## 2. 为什么不能把 JOLT 混进首版 3D

如果把以下内容同时做：

- `Node3D`
- `Camera3D`
- `MeshCache`
- `Material`
- `RenderPass3D`
- glTF
- JOLT 刚体 / 碰撞体 / world / debug draw / binding

项目复杂度会呈指数增长，风险包括：

- 首版周期不可控
- 错误来源难定位
- 2D runtime 回归面过大

更合理的策略是：

- 先让 3D “看得见”
- 再让 3D “动得对”

## 3. JOLT 子系统目标

JOLT 接入的中期目标：

- 3D 刚体世界
- 静态碰撞体
- 动态刚体
- 射线检测
- 碰撞事件
- 调试绘制
- 与 `Node3D` 的双向同步

## 4. 架构边界

建议新增并行体系：

- `PhysicsWorld3D`
- `BodyDef3D`
- `Body3D`
- `Shape3D`
- `Joint3D`
- `PhysicsDebugDraw3D`

而不是在现有 `PhysicsWorld` 上硬扩 3D。

原因：

- 现有 `PhysicsWorld` API 与数据结构明显 2D 化
- 强行共用会让接口长期扭曲

## 5. 与 `Node3D` 的关系

推荐组件关系：

- `Body3D` 不是 `Node3D` 子类
- `Body3D` 挂接到 `Node3D` 或由 `Node3D` 持有引用

同步模式建议：

### 动态刚体

- physics 驱动 transform
- 每 fixed step 后把刚体 world transform 写回 `Node3D`
- 写回只更新 position/rotation，保留节点原有 scale；碰撞形状尺寸由 `Shape3D` 明确定义
- 首版要求目标 `Node3D` 为 root，或其 parent chain 仅包含无缩放的刚性变换；不支持把动态刚体挂在 non-uniform scale/shear 层级下

### 静态/运动学对象

- `Node3D` 驱动 physics
- 每个 fixed step 开始前读取最新 world transform 并同步到刚体

### 已冻结的同步顺序

`Director::doLogic()` 的主 `Scheduler` 已在 action 和普通 update 前执行 fixed update list，并由 `fixedFPS` 与 `_leftTime` 维护 accumulator。因此 JOLT-A 不再实现第二套 accumulator，而是把每个 `PhysicsWorld3D` 注册为一个 fixed scheduled item：

1. 从 Node3D world transform 推送 static/kinematic body 的脏变换。
2. 使用 Scheduler 提供的 fixed delta 执行一次 JOLT step。
3. 将 active dynamic body 的 world position/rotation 转回 Node3D local TRS。
4. 普通 update、动画和 render collect 在 fixed step 后继续执行。

同一 body 每个 fixed tick 只能有一个 authority。dynamic 由 physics 写回；static/kinematic 由 Node3D 推入，禁止同帧双向覆盖。

## 6. 推荐 API 草案

```cpp
class PhysicsWorld3D : public Node {
public:
	bool raycast(
		const Vec3& origin,
		const Vec3& direction,
		float distance,
		const std::function<bool(Body3D*, const Vec3&, const Vec3&)>& callback);
};

class Body3D : public Object {
public:
	PROPERTY(Node3D*, Node);
	PROPERTY(BodyType3D, Type);
	PROPERTY(float, Mass);
	PROPERTY_BOOL(UseGravity);

	void applyForce(const Vec3& force);
	void applyImpulse(const Vec3& impulse);
};
```

## 7. 形状系统

首版优先支持：

- box
- sphere
- capsule
- mesh collider，静态 only

不要首版就做：

- convex decomposition 自动化
- 复杂角色控制器
- 车辆系统

## 8. 脚本绑定策略

只有当 `PhysicsWorld3D` 最小闭环稳定后，再向脚本暴露：

- `PhysicsWorld3D`
- `BodyDef3D`
- `Body3D`
- `Shape3D`

避免出现脚本层 API 已冻结，但底层实现还在大改。

## 9. 启动条件与开发阶段

JOLT-A 开始前需要满足：

- 当前 3D 大版本变更已经提交并通过 P0、cache、profile 和 picking 回归。
- `Node3D` world transform、parent/child、cleanup 和 wrapper 生命周期语义冻结。
- 明确 fixed timestep accumulator 的调度位置。
- 明确动态刚体、静态/运动学刚体各自的 transform authority，禁止同一帧双向覆盖。

JOLT 不需要等待 Material3D、shadow、triangle picking、morph target 或 LOD。

### JOLT-A: 基础接入

- 第三方库引入
- world lifecycle
- 接入主 `Scheduler` fixed update，不新增第二套 accumulator
- box/sphere/capsule
- static/dynamic/kinematic body
- static/kinematic step 前拉取 Node3D world transform
- dynamic step 后写回 Node3D local position/rotation
- 创建、销毁和场景轮换压力测试

### JOLT-B: 最小游戏 API

- raycast / overlap
- collision enter/stay/exit
- layer/mask 与 sensor
- force、impulse 和 velocity
- debug draw（诊断补项，不阻塞游戏 API）
- Lua、TS、Wasm、Rust、Wa 与 C# 最小绑定

### JOLT-C: 生产化

- [x] 基于 `CharacterVirtual` 的胶囊 character controller
  - Node3D 世界坐标表示脚底位置
  - 与 PhysicsWorld3D 共用固定时间步
  - 支持期望水平速度、重力、落地状态、跳跃、最大坡度和步阶高度
  - 支持 layer/mask，并忽略 sensor 作为角色支撑面
  - world、character 或关联 Node3D 任一路径销毁都会释放 native instance
  - Lua、TS、Wasm、Rust、Wa 和 C# 绑定已生成
- [x] reusable primitive shape 与 immutable compound shape
  - Rust 持有引擎 C ABI 返回的 opaque shape handle，native Jolt shape instance 由 C++ bridge 管理；C++ `PhysicsShape3D` wrapper 只持 Rust runtime handle
  - compound 先 `addChild`，再以 `build()` 一次性冻结，冻结后拒绝修改
  - shape wrapper 可在 body 创建后释放，body 继续通过 Jolt 引用计数持有 native shape
  - Lua、TS、Wasm、Rust、Wa 和 C# 绑定已生成
- [x] mesh collider cooking
  - 模型与外部 buffer 均通过 Dora `Content.loadAsyncData` 在主线程发起读取
  - Rust worker 解析 glTF scene transform 与 triangle primitive，并在后台构建 Jolt `MeshShape`
  - 独立 shape cache 复用完成的 cook 结果；static/kinematic 可用，dynamic concave 明确拒绝
- [x] constraint 最小集合
  - `Constraint3D` 覆盖 fixed、distance 和带角度限制的 hinge
  - anchor/axis 使用世界空间，hinge limit 对外使用角度
  - world 持有 constraint wrapper；约束显式销毁、关联 body 销毁或 world cleanup 都会先释放 Jolt constraint
  - Lua、TS、Teal、Wasm、Rust、Wa 和 C# 绑定已生成
- [x] 首轮规模化性能与诊断基线
  - `JoltScaleProfile.ts` 覆盖 `100/250/500` 个动态 box/sphere/capsule，并分别采样 physics debug draw 关闭和开启状态
  - 记录 frame P50/P95、Jolt collect/submit P95、RSS 区间以及阶段清理后的 3D registry
  - 首轮结果用于识别增长趋势和调试绘制成本，不替代原生 arm64 Release profile
- [x] 动态 convex hull shape
  - `PhysicsShape3D.loadConvexHullAsync()` 复用 Content 异步读取和 glTF buffer dependency 链路
  - Rust worker 应用 scene node transform，仅保留 triangle indices 实际引用的唯一 POSITION
  - Jolt `ConvexHullShapeSettings` 在引擎 C++ 边界创建 native shape，可直接用于 dynamic body
  - mesh/hull cache 使用类型化 key，同路径重复 hull 请求复用、不同 shape kind 不串缓存
  - Lua、TS、Teal、Wasm、Rust、Wa 和 C# 绑定已补齐

复杂形状采用独立的 Rust-owned `PhysicsShape3D` 公开句柄层，native Jolt shape instance 由引擎 C++ bridge 创建和释放；脚本/C++ wrapper 不持有 Jolt 类型，也不让 `PhysicsWorld3D` 增加按形状类型扩张的创建接口。基础 box/sphere/capsule shape 可组合为 immutable compound，并由多个 body 共享。现有 convenience body API 保留并在内部创建临时基础 shape。

mesh collider 不直接读取渲染 `MeshData`。当前渲染 mesh 上传后只保留 GPU buffer、AABB 和 joint bounds，CPU 顶点/索引会释放；为 physics 永久保留一份会无条件增加模型内存。正确路径是通过 Dora `Content` 从模型源按需异步重新读取静态 primitive，后台 cook 为 Jolt `MeshShape`，最终产物进入独立 shape cache。首版只允许 static/kinematic mesh collider；dynamic concave mesh 明确拒绝，动态复杂物体使用 compound convex shape。

## 10. 与渲染系统的耦合边界

JOLT 不应直接依赖：

- `Material`
- `Mesh`
- `RenderPass3D`

唯一合理耦合点：

- debug draw
- optional mesh collider generation

## 11. 决策建议

结论非常明确：

- 把 JOLT 纳入 3D 总路线图
- 但不要纳入 3D 首版交付范围

更具体地说：

1. 收口当前 3D 变更并清理动画每帧 clone。
2. 冻结 `Node3D` transform/lifecycle authority 后立即开启 JOLT-A。
3. JOLT-A/B 完成物理最小闭环后，再继续 Model3D 查询、Material3D 和单方向光阴影。
4. JOLT-C 的 character controller、mesh collider cooking 和复杂约束继续作为独立生产化里程碑。

## 12. JOLT 阶段验收

- [x] 可创建、清理并重复销毁 `PhysicsWorld3D`。
- [x] `Node3D` 与动态刚体变换同步正确，static/kinematic 在 step 前推入，dynamic 在 step 后写回。
- [x] `raycast` 与 sphere overlap 可返回 `Body3D` 和碰撞信息。
- [x] Enter/Stay/Exit、layer/mask 与 sensor 行为通过 Rust 和真实场景回归。
- [x] force、impulse、linear/angular velocity 已进入全部目标语言绑定。
- [x] CharacterVirtual 胶囊控制器的落地、移动、跳跃和生命周期通过 Rust 与 TS 截图回归。
- [x] primitive/compound shape 的冻结、共享和 body 独立持有通过 Rust 测试与 TS 截图回归。
- [x] glTF mesh collider 的异步 Content 读取、scene transform 提取、cache 复用和 static body 运行回归通过。
- [x] fixed/distance/hinge 的约束保持、平面自由度和 C++ wrapper 生命周期通过 Rust 与 TS 截图回归。
- [x] physics debug draw 可视化支持 box/sphere/capsule，复杂形状使用 AABB 回退。
- [x] 现有 2D `PhysicsWorld` 类型与实现保持独立。

Jolt 的自动集成验证统一由 `Dora-Example/Test/Model3D/run-jolt-integration.zsh` 在真实引擎进程内执行，不在 Rust unit-test binary 中直接链接 Jolt。总入口覆盖 Physics3D、CharacterController3D、CompoundShape3D、MeshCollider3D 与 Constraint3D；Rust 单测只保留不依赖 native engine 的纯逻辑验证。

2026-07-11 macOS Metal Debug 运行记录：`Physics3D.ts` 在 3 秒稳定态得到 `enter=6, stay=155, exit=6, sensor=3, rayDistance=5.75, overlap=5`，三个动态刚体均稳定在 `y=0.63`。Jolt fixed temp allocator 使用 4 MiB 预分配并在容量不足时回退到 allocator，避免 world 最大容量导致 `TempAllocatorImpl::Allocate` 触发断言崩溃。

2026-07-11 compound 运行记录：`CompoundShape3D.ts` 创建偏置 box+sphere 复合动态刚体，冻结后修改被拒绝，落地后两条射线均命中同一 body；`COMPOUND3D_SUMMARY status=PASS built=true frozen=true left=true right=true y=0.530`。同时补齐 tolua++ Object 注册列表，避免新加的 `Material3D`、`Body3D`、`CharacterController3D`、`PhysicsShape3D` 和 `PhysicsWorld3D` 在 Lua 仍持有 userdata 时被 autorelease 清空。

2026-07-11 mesh collider 运行记录：`MeshCollider3D.ts` 通过异步 Content 路径 cook Duck glTF triangle mesh，第二次请求命中 shape cache，静态 body 射线命中；`MESH_COLLIDER3D_SUMMARY status=PASS built=true cache=true ray=true y=0.480 load=0.862`。

2026-07-12 边界收口后运行记录：`cargo test --lib` 的 30 项纯 Rust 测试通过；`run-jolt-integration.zsh` 的 Physics3D、CharacterController3D、CompoundShape3D、MeshCollider3D 与 Constraint3D 五项引擎集成回归通过。constraint 结果为 `fixed=1.400, distance=2.000, hingeMove=1.377 refs=true`，macOS 原生构建通过。

2026-07-12 首轮规模化基线：`JoltScaleProfile.ts` 六个阶段全部通过。关闭 physics debug draw 时，`100/250/500` body 的 frame P95 均为 `16.667ms`，Jolt collect P95 为 `0.480/1.140/2.329ms`；500 body 开启 debug draw 后 frame P50/P95 为 `24.072/26.186ms`，collect P95 为 `2.404ms`。Jolt submit P95 保持 `0-1us`，说明当前可见额外成本主要来自调试几何生成/渲染，而非 native step 后的提交同步。进程 RSS 为 `165220 -> 199784 KB`、峰值 `212996 KB`。

2026-07-12 dynamic convex hull 运行记录：Duck glTF 通过 Content 异步读取并在 worker 侧提取点集，Jolt cook 后创建 dynamic body。重复 hull 加载命中同一 cache object，同路径 triangle mesh 返回独立 shape；刚体完成下落、旋转和 raycast，`CONVEX_HULL3D_SUMMARY status=PASS built=true cache=true isolated=true dynamic=true rotated=true ray=true y=0.690`。
