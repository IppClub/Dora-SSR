# Dora 3D 场景图与相机设计

## 1. 目标

本篇定义 3D 场景层的核心对象：

- `Node3D`
- `Visual3D`
- `Camera3D`
- 场景树中的 2D/3D 混合规则

目标是让 3D 在 Dora 现有 runtime 之上增量成立，但不再直接复用现有 `Node` 作为 3D 语义节点，而是建立一套独立的 `Node3D` 场景树。

## 2. 场景树分层

## 2.1 推荐结构

```cpp
class Node { ... };        // 现有 2D 场景树
class Node3D { ... };      // 新增 3D 场景树
class Visual3D : public Node3D { ... };
```

这意味着：

- `Node` 和 `Node3D` 是两套独立语义树
- 二者不共享父子树结构
- 2D/3D 混合通过桥接节点，而不是任意父子混挂

## 2.2 为什么不做 `NodeBase`

最新判断是：

- `Node` 里真正值得抽出的公共能力不多
- 为了抽公共基类而重构，会带来较大的迁移成本
- 相比之下，直接做独立 `Node3D` 更务实

因此 `Node3D` 应自己完整实现：

- child tree
- enter / exit / cleanup
- schedule / update / fixedUpdate / render
- 事件与 signal
- 3D transform

## 3. `Node3D` 设计

## 3.1 定位

`Node3D` 是 Dora 的 3D 场景节点基类，职责是：

- 提供纯 3D 场景语义
- 提供 3D 友好的属性命名
- 支撑 3D 子树生命周期
- 为 `Visual3D` / `RenderPass3D` 提供基础

## 3.2 建议接口

```cpp
class Node3D : public Object {
public:
	PROPERTY_CREF(Vec3, Position);
	PROPERTY_CREF(Vec3, Scale);
	PROPERTY_CREF(Quat, Rotation);
	PROPERTY_CREF(Vec3, Angles);
	PROPERTY_READONLY_CREF(Matrix, WorldMatrix);

	void addChild(Node3D* child, int order = 0, String tag = String::empty());
	void removeChild(Node3D* child, bool cleanup = true);
	void removeFromParent(bool cleanup = true);

	Vec3 convertToWorldSpace(const Vec3& localPoint);
	Vec3 convertToNodeSpace(const Vec3& worldPoint);
};
```

首版不要为了兼容 2D API 再暴露：

- `x/y`
- `anchor`
- `size`
- `color`

否则语义会重新混乱。

## 3.3 与现有数学实现的关系

虽然 `Node3D` 不再继承现有 `Node`，但可以继续复用现有数学实现思路：

- 维护 local matrix
- 级联 parent world matrix
- dirty propagation

建议直接复用或迁移现有 `Node::getLocalWorld()` 的数学实现思路，而不是重新发明一套不同的变换模型。

## 3.4 缓存设计

建议新增以下 dirty flag：

- `Transform3DDirty`
- `BoundsDirty`
- `NormalMatrixDirty`

缓存项：

- `worldMatrix`
- `worldBounds`
- `normalMatrix`

## 4. `Visual3D`

建议在 `Node3D` 与 `Model3D` 之间增加一层：

```cpp
class Visual3D : public Node3D {
public:
	PROPERTY_BOOL(FrustumCulling);
	PROPERTY_READONLY_CREF(AABB, LocalBounds);
	PROPERTY_READONLY_CREF(AABB, WorldBounds);
	PROPERTY_READONLY_CREF(Matrix, NormalMatrix);
};
```

这样后续灯光、贴花、粒子、实例化对象就不会都直接堆在 `Node3D` 上。

## 5. 遍历与渲染责任

`Node3D` 自身不直接做 bgfx 提交。职责应为：

- 参与 3D 场景树遍历
- 提供 world matrix 与空间语义

`Visual3D` 负责：

- 持有 bounds
- 参与 culling
- 在 `render()` 中把自身注册给 `RenderPass3D`

## 6. `Camera3D` 设计

## 6.1 定位

`Camera3D` 应继承 `Camera`，并兼容 `Director.pushCamera(...)`。

建议接口：

```cpp
class Camera3D : public Camera {
public:
	PROPERTY_CREF(Vec3, Position);
	PROPERTY_CREF(Vec3, Forward);
	PROPERTY_CREF(Vec3, Up);
	PROPERTY_CREF(Vec3, Right);
	PROPERTY_CREF(Vec3, Target);
	PROPERTY(float, FieldOfView);
	PROPERTY(float, NearClip);
	PROPERTY(float, FarClip);
	PROPERTY(float, AspectRatio);
	PROPERTY_BOOL(AutoAspect);
	PROPERTY_BOOL(Orthographic);
	PROPERTY(float, OrthoHeight);
};
```

## 6.2 为什么不直接复用 `CameraBasic`

`CameraBasic` 已接近 3D 相机，但它的问题是：

- 没有明确暴露 projection 参数
- 脚本语义不够清晰

因此推荐：

- `CameraBasic` 保留
- 新增面向外部 API 的 `Camera3D`

## 6.3 投影矩阵策略

`Camera3D::hasProjection()` 应返回 `true`，让 `Director` 把 `camera->getView()` 视为完整 view-projection。

内部缓存拆分：

- `_view`
- `_projection`
- `_viewProjection`

## 6.4 相机控制辅助

首版建议提供：

- `lookAt`
- `screenPointToRay`
- `worldToScreenPoint`

## 7. 2D/3D 混合规则

建议沿用当前 `Director` 的四层结构：

- 主场景 `entry`
- `ui3D`
- `ui`
- `postNode`

但 `Node` 子树与 `Node3D` 子树不应任意互为父子。混合必须通过桥接节点。

### 7.1 场景 3D

3D 节点挂在 `Director.entry` 下，但内部仍是独立的 `Node3D` 子树，由 `RenderPass3D` 负责遍历和提交。

### 7.2 UI 3D

3D UI 内容挂在 `Director.ui3D` 下，使用 `CameraUI3D` 或专用 `Camera3D`。

### 7.3 `Scene2DIn3D`

`Scene2DIn3D : Node3D` 是唯一合法的“3D 中承载 2D”方式：

- 内部持有一棵 `Node` 子树
- 渲染到离屏纹理
- 再以 3D 面片或曲面形式显示

## 8. 可见性与裁剪

## 8.1 首版做 frustum culling，先不做 occlusion culling

实现顺序：

1. `Camera3D` 提供 frustum
2. `Visual3D` / `Model3D` 暴露 `worldBounds`
3. `RenderPass3D` 收集阶段做 frustum 测试

## 8.2 与 `Director::isInFrustum` 的关系

当前 `Director` 已有 frustum culling 能力。建议扩展其适配 3D AABB，而不是另起完全独立实现。

## 9. 调试能力

首版建议支持：

- 绘制 world bounds
- 绘制 local axis
- 绘制 camera frustum
- 显示 draw call / visible object 数量

## 10. 代码落点建议

新增文件：

- `Source/Node/Node3D.h`
- `Source/Node/Node3D.cpp`
- `Source/Node/Visual3D.h`
- `Source/Node/Visual3D.cpp`
- `Source/Render/Camera3D.h`
- `Source/Render/Camera3D.cpp`

修改文件：

- `Source/Basic/Director.h/.cpp`
  - camera stack 与 3D frustum 兼容
- `Source/Lua/LuaBinding.cpp`
  - 导出新类型

## 11. 首版验收

- `Node3D` 支持 parent-child 级联变换。
- `Visual3D` 统一提供 bounds 与 culling 入口。
- `Camera3D` 可通过 `Director.pushCamera()` 切换生效。
- `Model3D` 在旋转、缩放、嵌套场景下 world matrix 正确。
- `Scene2DIn3D` 能稳定显示一棵 2D 子树。
