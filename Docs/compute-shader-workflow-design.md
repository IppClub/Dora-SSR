# Director Compute Shader Workflow Design

## 概述

本文档详细说明 Dora SSR 中 Director 的 compute shader 调度工作流设计和实现。

## 设计目标

1. **与现有架构一致**：遵循 Dora 现有的 View 系统和渲染管线
2. **易于使用**：提供简单清晰的 API 让用户注册和移除 compute pass
3. **执行顺序可控**：通过 View 系统保证 compute pass 在正确的渲染阶段执行
4. **资源安全**：防止悬空指针和资源生命周期问题

## 架构设计

### 1. Compute Pass 注册机制

Director 提供两个独立的 compute pass 列表：

- **PreSceneComputes**: 在场景渲染之前执行
  - 用途：粒子系统更新、物理模拟、程序化纹理生成
  - 执行时机：场景节点 visit 之前

- **PrePostComputes**: 在场景渲染之后、后处理之前执行
  - 用途：场景纹理后处理、图像滤波、延迟渲染光照计算
  - 执行时机：场景渲染完成后、UI 渲染前

### 2. 调度点设计

```
doRender() 渲染流程：
1. PreSceneCompute View
   └─> 运行所有注册的 PreSceneComputes
2. Main View (or RT + Main View)
   └─> 渲染场景树 (_root)
   └─> 渲染 PostNode
3. PrePostCompute View
   └─> 运行所有注册的 PrePostComputes
4. UI3D View
   └─> 渲染 3D UI
5. UI View
   └─> 渲染 2D UI
6. NanoVG View (如果需要)
7. ImGui View
```

### 3. View 系统集成

每个 compute pass 阶段创建独立的 View：

- View 名称：`"PreSceneCompute"`, `"PrePostCompute"`
- View 顺序：由 `SharedView.pushBack()` 自动管理
- View ID：由 View 系统分配，保证正确的渲染顺序

### 4. API 设计

#### 注册/移除 ComputePass

```cpp
// 添加 compute pass 到 PreScene 阶段
void Director::addPreSceneCompute(NotNull<ComputePass, 1> pass);

// 从 PreScene 阶段移除 compute pass
void Director::removePreSceneCompute(NotNull<ComputePass, 1> pass);

// 清空所有 PreScene compute passes
void Director::clearPreSceneCompute();

// PrePost 阶段的对应 API
void Director::addPrePostCompute(NotNull<ComputePass, 1> pass);
void Director::removePrePostCompute(NotNull<ComputePass, 1> pass);
void Director::clearPrePostCompute();
```

#### 用户使用示例

```cpp
// 创建 compute pass
auto computePass = ComputePass::create("shader/compute_blur.bin");

// 配置 compute pass
computePass->set("u_params", 1.0f, 0.0f, 0.0f, 0.0f);
computePass->setImage(0, inputTexture, ComputeAccess::Read);
computePass->setImage(1, outputTexture, ComputeAccess::Write);

// 注册到 Director
SharedDirector.addPrePostCompute(computePass);

// 在每帧中，用户需要手动 dispatch（可以在 update 或其他回调中）
void onUpdate() {
    // 更新 uniform
    computePass->set("u_time", time);
    
    // 获取当前 view ID 并 dispatch
    // 注意：用户需要自己管理 dispatch 的时机和参数
    computePass->dispatch(viewId, groupCountX, groupCountY);
}

// 不再需要时移除
SharedDirector.removePrePostCompute(computePass);
```

## 实现细节

### 1. ComputePass 改进

#### dispatch 方法
- **修复前**: `dispatch(uint32_t numX, uint32_t numY, uint32_t numZ = 1)`，硬编码 viewId = 0
- **修复后**: `dispatch(bgfx::ViewId viewId, uint32_t numX, uint32_t numY, uint32_t numZ = 1)`
- **原因**: 允许用户指定 viewId，与 View 系统正确集成，保证渲染顺序

#### setImage 方法
- **修复前**: 不持有 texture 引用，存在悬空指针风险
- **修复后**: 在 `_boundTextures` 中存储 texture 引用
- **format 参数**: 添加默认值 `bgfx::TextureFormat::Count`，表示自动从 texture 获取格式

### 2. Director Compute Pass 存储

```cpp
private:
    RefVector<ComputePass> _preSceneComputes;
    RefVector<ComputePass> _prePostComputes;
```

使用 `RefVector` 自动管理 compute pass 的生命周期。

### 3. 执行顺序保证

通过 View 系统的 `pushBack()` 方法保证执行顺序：

```cpp
void Director::runPreSceneCompute() {
    if (_preSceneComputes.empty()) return;
    
    SharedView.pushBack("PreSceneCompute"_slice, [&]() {
        bgfx::ViewId viewId = SharedView.getId();
        // 用户在此 frame 的更早时刻已经调用了 dispatch
    });
}
```

## 高级用法

### 1. 条件执行

用户可以通过标志位控制 compute pass 是否执行：

```cpp
bool shouldRunCompute = true;

if (shouldRunCompute) {
    SharedDirector.addPreSceneCompute(myComputePass);
} else {
    SharedDirector.removePreSceneCompute(myComputePass);
}
```

### 2. 多 Pass 链

支持多个 compute pass 串联：

```cpp
auto pass1 = ComputePass::create("pass1.bin");
auto pass2 = ComputePass::create("pass2.bin");

SharedDirector.addPrePostCompute(pass1);
SharedDirector.addPrePostCompute(pass2);

// pass1 和 pass2 会按照注册顺序执行
```

### 3. 动态 Dispatch 参数

用户可以在运行时动态调整 dispatch 参数：

```cpp
void update(float dt) {
    // 根据需要调整 dispatch 大小
    uint32_t groupsX = (textureWidth + 15) / 16;
    uint32_t groupsY = (textureHeight + 15) / 16;
    
    computePass->dispatch(viewId, groupsX, groupsY);
}
```

## 与现有系统的协调

### 1. 与 Grabber / PostEffect 的关系

- Compute pass 在 Grabber / PostEffect 之前或之后执行
- 可以用 compute pass 预处理纹理，然后交给 graphics pass
- 也可以用 compute pass 处理 graphics pass 的输出

示例混合流程：
```
Scene -> RT -> ComputePass (blur) -> SpriteEffect (color grading) -> Screen
```

### 2. 与 RenderTarget 的关系

RenderTarget 已经支持 `ComputeAccess` 标志：

```cpp
// 创建支持 compute 写入的 RenderTarget
auto rt = RenderTarget::create(1024, 768, bgfx::TextureFormat::RGBA8, ComputeAccess::Write);

// 绑定到 compute pass
computePass->setImage(0, rt->getTexture(), ComputeAccess::Write);
```

### 3. 纹理格式自动推断

```cpp
// format 参数使用默认值 Count，自动从 texture 获取
computePass->setImage(0, texture, ComputeAccess::Read);

// 或者显式指定格式
computePass->setImage(0, texture, ComputeAccess::Read, bgfx::TextureFormat::RGBA8);
```

## 性能考虑

### 1. 空 Pass 检查

```cpp
void Director::runPreSceneCompute() {
    if (_preSceneComputes.empty()) return;  // 快速返回，避免创建无用的 View
    // ...
}
```

### 2. 批量 Dispatch

多个 compute pass 共享同一个 View，减少状态切换开销。

### 3. View 顺序优化

Dora 的 View 系统在 `doRender()` 末尾统一 remap view order，compute view 自然纳入整体优化。

## 错误处理

### 1. Compute 不支持

`ComputePass::init()` 会检查 `BGFX_CAPS_COMPUTE`，如果不支持则返回 false。

### 2. 空纹理检查

`setImage()` 会检查 texture 是否为 nullptr，避免崩溃。

### 3. Format 检查

bgfx 会在运行时检查纹理格式是否支持指定的访问模式。

## 使用建议

### 1. 合适的使用场景

- ✅ 粒子系统状态更新
- ✅ 程序化纹理生成
- ✅ 图像后处理（模糊、边缘检测等）
- ✅ GPU 数据计算（物理、碰撞等）

### 2. 不推荐的用法

- ❌ 在 `Node::visit()` 或 `render()` 中动态注册/移除 compute pass
- ❌ 每帧创建新的 `ComputePass` 对象
- ❌ 在 compute pass 中访问未正确同步的资源

### 3. 生命周期管理

```cpp
class MyScene : public Node {
    Ref<ComputePass> _computePass;
    
    virtual bool init() override {
        if (!Node::init()) return false;
        
        // 创建时注册
        _computePass = ComputePass::create("my_compute.bin");
        if (_computePass) {
            SharedDirector.addPreSceneCompute(_computePass);
        }
        
        return true;
    }
    
    virtual void cleanup() override {
        // 清理时移除
        if (_computePass) {
            SharedDirector.removePreSceneCompute(_computePass);
        }
        Node::cleanup();
    }
};
```

## 未来扩展

### 1. ComputeBuffer 支持

可以类似地添加 `ComputeBuffer` 支持用于 GPGPU 计算：

```cpp
class ComputeBuffer : public Object {
    void update(const void* data, uint32_t size);
    // ...
};
```

### 2. 优先级系统

如果需要更精细的控制，可以添加优先级参数：

```cpp
void addPreSceneCompute(ComputePass* pass, int priority = 0);
```

### 3. 自动 Dispatch

可以为 `ComputePass` 添加自动 dispatch 配置：

```cpp
computePass->setAutoDispatch(groupsX, groupsY, groupsZ);
```

## 总结

Director 的 compute shader 工作流设计遵循以下原则：

1. **简单清晰**：通过 `add/remove` API 管理 compute pass
2. **与现有架构一致**：使用 View 系统保证正确的执行顺序
3. **资源安全**：通过 `RefVector` 和 texture 引用防止悬空指针
4. **灵活可控**：用户可以完全控制 dispatch 参数和时机

这个设计既保持了 Dora SSR 的简洁风格，又提供了强大的 compute shader 能力。
