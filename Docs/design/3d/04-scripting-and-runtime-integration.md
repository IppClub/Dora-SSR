# Dora 3D 脚本绑定与运行时集成设计

## 1. 目标

本篇定义：

- Lua / Yue / TS 绑定策略
- 类型声明与文档生成
- 运行时接入点
- 示例、调试与测试方案

目标是让 3D API 的使用体验与 `Sprite`、`Label`、现有 `Model` 一致。
同时，对外脚本层应主要暴露 `Node` 和 `Node3D` 两套节点语义。

## 2. 脚本 API 原则

## 2.1 一致性

脚本暴露风格应与现有节点一致：

- 可直接构造
- 可挂载到树上
- 属性可读写
- 类型声明完整

### 示例

```ts
import { Director, Camera3D, Model3D, Vec3 } from "Dora";

const camera = Camera3D();
camera.position = Vec3(0, 2, -6);
camera.lookAt(Vec3(0, 1, 0));
Director.pushCamera(camera);

const model = Model3D("Model/helmet.glb");
model.position = Vec3(0, 0, 0);
model.addTo(Director.entry);
```

## 2.2 命名策略

建议脚本可见类型：

- `Node3D`
- `Visual3D`
- `Camera3D`
- `Mesh`
- `Material`
- `Model3D`
- `DirectionalLight`
- `PointLight`

避免与现有类型冲突：

- 保留 `Model` 代表现有 2D 模型

## 3. Lua / Yue / TS 绑定

## 3.1 绑定范围

首版必须暴露：

- 基础构造函数
- 常用属性
- 材质参数设置
- mesh/model 资源构造
- 相机切换

建议首版暂不暴露：

- 过于底层的 bgfx 句柄
- 内部 render item 结构

## 3.2 类型声明

需要同步更新：

- `Assets/Script/Lib/Dora/en/*.d.tl`
- `Assets/Script/Lib/Dora/zh-Hans/*.d.tl`
- `Assets/Script/Lib/Dora/en/Dora.d.ts`
- `Assets/Script/Lib/Dora/zh-Hans/Dora.d.ts`

新增声明建议：

- `Node3D.d.tl`
- `Visual3D.d.tl`
- `Camera3D.d.tl`
- `Mesh.d.tl`
- `Material.d.tl`
- `Model3D.d.tl`

## 3.3 手写绑定与生成链路

仓库当前 Lua 绑定体系依赖：

- `LuaBinding`
- `LuaManual`
- 类型声明产物

实施顺序建议：

1. `Node3D / Visual3D` 独立场景树先落地
2. Lua 绑定导出
3. Teal / TS 声明补齐
4. 样例脚本验证

## 4. 运行时接入点

## 4.1 `Director`

需要修改 `Director::doRender()`，让 3D pass 有固定插入点。

推荐顺序：

1. 主场景 3D
2. 主场景 2D
3. UI3D
4. UI
5. Post

是否把“主场景 2D”放在“主场景 3D”前面，取决于现有项目兼容性。首版建议：

- 主场景 3D 先于主场景 2D

原因：

- 更接近真实世界背景 + 2D 叠加
- 可避免大量 2D 元素误被 depth 覆盖

## 4.2 `RenderTarget` / `Grabber`

由于现有 `RenderTarget` 已支持绑定 `Camera`，3D 功能要保证：

- `RenderTarget` 渲染 3D 节点时可指定 `Camera3D`
- 后处理链拿到的是完整的 3D + 2D 合成结果

## 4.3 Cache 总入口

`Cache::load/unload` 建议扩展支持：

- `.glb`
- `.gltf`
- `.obj`
- `.mesh`，如果后续引入引擎内部二进制缓存格式

## 5. 示例与 Demo

首版应至少提供 3 个示例：

### 示例 1: 最小 3D 场景

- 创建 `Camera3D`
- 加载一个 `.glb`
- 绕 Y 轴旋转

### 示例 2: 材质替换

- 一个 mesh
- 两套 material
- 在脚本运行时切换

### 示例 3: UI3D 展示

- 模型挂在 `Director.ui3D`
- 与普通 UI 叠加显示

## 6. 调试工具

推荐增加：

- ImGui 面板显示 3D statistics
- 当前 camera 参数
- visible mesh 数
- opaque / transparent draw call 数
- shader / material 切换次数

## 7. 测试策略

## 7.1 单元测试

适合做：

- mesh parser
- material 参数映射
- bounds 计算
- frustum 判定

## 7.2 集成测试

适合做：

- 加载 glTF 后节点树结构正确
- camera 切换后 view-projection 正确
- 透明与不透明排序稳定

## 7.3 回归测试

必须覆盖：

- 纯 2D 项目运行不回退
- UI / UI3D 不受主场景 3D 影响
- 现有 `Model`、`Sprite`、`Label` 行为不变

## 8. 性能基线

首版就应加 profile 统计：

- visible models
- visible submeshes
- draw calls
- triangles
- culling ratio

否则后续性能问题很难定位。

## 9. 开发计划建议

### Sprint 1

- `Node3D`
- `Visual3D`
- `Camera3D`
- `Model3D` 空壳
- `RenderPass3D` 空壳

### Sprint 2

- primitive mesh
- unlit material
- 基本脚本绑定

### Sprint 3

- glTF
- Lambert 光照
- debug draw

### Sprint 4

- TS/Teal 文档与示例
- 性能与回归修正

## 10. 首版验收

- Lua / Yue / TS 三种脚本都能创建 `Camera3D` 与 `Model3D`。
- 类型声明无明显缺口。
- 提供最少 3 个可运行 demo。
- 纯 2D 示例在启用 3D 功能分支后通过回归验证。
