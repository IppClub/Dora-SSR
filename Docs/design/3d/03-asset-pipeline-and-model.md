# Dora 3D 资源管线与 Model 设计

## 1. 目标

本篇定义：

- `Mesh` 资源结构
- `MeshCache`
- glTF / OBJ 导入策略
- `Model3D` 节点
- 资源目录与缓存策略

## 2. 格式选择

## 2.1 glTF 作为主格式

推荐将 glTF (`.gltf` / `.glb`) 设为首选格式。

原因：

- 现代 3D 资产交换标准
- 原生支持 mesh、material、node hierarchy、texture
- 与 PBR 天然兼容
- 生态好，DCC 工具导出成熟

## 2.2 OBJ 作为回退格式

OBJ 仅建议作为简单静态模型 fallback：

- 几何简单
- 导入成本低
- 方便测试

但不应作为主格式，因为：

- 材质能力弱
- 无标准化层级
- 不适合未来动画扩展

## 3. `Mesh` 设计

## 3.1 职责

`Mesh` 只表示几何资源，不关心节点树与播放逻辑。

应包含：

- vertex buffer
- index buffer
- submesh 列表
- 顶点布局
- local bounds
- 可选 skinning 预留字段

## 3.2 数据结构建议

```cpp
struct SubMesh {
	uint32_t indexOffset;
	uint32_t indexCount;
	uint32_t vertexOffset;
	uint32_t vertexCount;
	uint32_t materialSlot;
	AABB bounds;
};

class Mesh : public Object {
public:
	PROPERTY_READONLY(uint32_t, VertexCount);
	PROPERTY_READONLY(uint32_t, IndexCount);
	PROPERTY_READONLY_CREF(AABB, Bounds);
	PROPERTY_READONLY_CREF(std::vector<SubMesh>, SubMeshes);
	PROPERTY_READONLY(bgfx::VertexBufferHandle, VertexBuffer);
	PROPERTY_READONLY(bgfx::IndexBufferHandle, IndexBuffer);
};
```

## 3.3 顶点格式

首版建议统一静态网格布局：

- position: `float3`
- normal: `float3`
- tangent: `float4`，首版可选
- uv0: `float2`
- color: `uint32`，可选

首版最低要求：

- position
- normal
- uv0

不建议一开始允许过于自由的顶点布局，否则 shader 组合会迅速膨胀。

## 4. `MeshCache` 设计

## 4.1 风格

应与 `TextureCache`、`ModelCache`、`ShaderCache` 保持一致：

- 同步加载
- 异步加载
- unload / removeUnused
- 内容路径解析走 `SharedContent`

建议接口：

```cpp
class MeshCache : public NonCopyable {
public:
	Mesh* load(String filename);
	void loadAsync(String filename, const std::function<void(Mesh*)>& handler);
	bool unload(String filename);
	bool unload(Mesh* mesh);
	void removeUnused();
};
```

## 4.2 Cache key

建议以 full path 为 key，避免同名冲突。

## 5. `Model3D` 设计

## 5.1 定位

`Model3D` 是渲染节点，不是资源本身。

职责：

- 继承 `Visual3D`
- 引用 `Mesh`
- 引用一个或多个 `Material`
- 在每帧向 `RenderPass3D` 提交 draw item

## 5.2 与现有 `Model` 的关系

仓库内已有 `Node/Model`，它本质是 2D 骨骼/片段动画容器，对应 `ModelDef` XML 流程。为了避免概念混淆，建议：

- 保留现有 `Model` 名字不变
- 新 3D 节点命名为 `Model3D`

这样脚本层也更清晰：

- `Model(...)` = 现有 2D 模型
- `Model3D(...)` = 新 3D 模型

## 5.3 接口建议

```cpp
class Model3D : public Visual3D {
public:
	PROPERTY(Mesh*, Mesh);
	PROPERTY_READONLY(uint32_t, MaterialCount);

	void setMaterial(uint32_t index, Material* material);
	Material* getMaterial(uint32_t index) const;

	static Model3D* create(String filename);
};
```

## 5.4 多 submesh / 多材质

首版就应支持：

- 一个 mesh 多个 submesh
- 一个 submesh 一个 material slot

原因：

- glTF 常见
- 如果首版只支持单材质，后续改动会波及 render queue 与资源导入

## 6. glTF 导入策略

## 6.1 首版支持范围

建议首版支持：

- `.glb`
- `.gltf`
- static mesh
- node hierarchy
- material 基本参数
- texture 引用

可先不支持：

- skin
- 高数量 GPU morph target（core morph target 已由 per-instance CPU morph 支持）
- animation
- camera / light 导入

## 6.2 导入结果

推荐分为两层：

### `Mesh`

纯几何缓存

### `ModelPrefab3D` 或导入结果对象

如果 glTF 包含层级和多 mesh，建议导入中间数据：

- 节点树
- 每节点 mesh 引用
- 每节点默认 material 引用
- 本地变换

然后 `Model3D::create("file.glb")` 可以有两种实现策略：

#### 方案 A

`Model3D` 仅代表单 mesh 节点。

缺点：

- 无法原生还原 glTF 层级

#### 方案 B

`Model3D::create("file.glb")` 返回根节点，内部自动生成多个 `Model3D` 子节点。

更推荐方案 B，因为：

- 更符合用户预期
- 更适合未来动画和 prefab

## 6.3 导入库建议

如果允许引入第三方，优先考虑轻量成熟的 glTF 解析器。设计层面只要求：

- 导入逻辑与 `MeshCache` 解耦
- glTF parser 不直接依赖节点树

可抽象为：

```cpp
class MeshLoader {
public:
	virtual Mesh* load(String filename) = 0;
};
```

## 7. OBJ 导入策略

OBJ 仅支持：

- 单静态 mesh
- 单层或简单 material

主要用于：

- 调试
- 历史资源兼容
- 简单示例

不建议围绕 OBJ 设计高级功能。

## 8. 材质资源与文件组织

首版建议支持两种材质来源：

### 8.1 glTF 内嵌材质

导入时自动创建默认 `Material`

### 8.2 脚本动态材质

由脚本创建并替换：

```ts
const model = Model3D("Model/robot.glb");
model.setMaterial(0, Material.lit());
```

后续再考虑外部 `.material` 文件格式。

## 9. 资源热重载

建议在 Phase 2 提供：

- mesh reload
- material reload
- shader reload

首版只要求 cache unload/reload 正常工作。

## 10. 代码落点建议

新增文件：

- `Source/Render/Mesh.h`
- `Source/Render/Mesh.cpp`
- `Source/Cache/MeshCache.h`
- `Source/Cache/MeshCache.cpp`
- `Source/Node/Model3D.h`
- `Source/Node/Model3D.cpp`
- `Source/Asset/gltf/*`
- `Source/Asset/obj/*`

修改文件：

- `Source/Cache/Cache.cpp`
  - 扩展 `Cache::load/unload` 对 mesh/material 的识别
- 工程文件与打包脚本

## 11. 首版验收

- 能加载 `.glb` 并正确显示多个 submesh。
- 一个 glTF 的层级结构可映射到 `Node3D` 子树。
- 替换材质后可即时生效。
- 卸载 mesh cache 后资源能正确释放。
