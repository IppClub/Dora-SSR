# Compute Shader 调度策略分析报告

## 执行摘要

**推荐方案**: 混合方案 (方案 E) - 保留 Director 固定调度点 + 增强 Node/RT 级别调度 + 手动调度支持

---

## 1. Dora 渲染架构分析

### 1.1 当前渲染流程

```
Director::doRender()
├── pushViewProjection(defaultViewProj)
│   ├── [Post-process 模式]
│   │   ├── _root->grab() 创建 RT
│   │   ├── SharedView.pushBack("Main")
│   │   │   ├── _root->visit() (渲染到 RT)
│   │   │   ├── _postNode->visit()
│   │   │   ├── _ui3D->visit()
│   │   │   └── _ui->visit()
│   │   └── SharedView.pushBack("NanoVG")
│   │
│   └── [非 Post-process 模式]
│       ├── SharedView.pushBack("Main")
│       │   ├── _root->visit()
│       │   └── _postNode->visit()
│       ├── SharedView.pushBack("UI3D")
│       │   └── _ui3D->visit()
│       └── SharedView.pushBack("UI")
│           └── _ui->visit()
│
└── bgfx::setViewOrder() 重映射视图顺序
```

### 1.2 关键渲染机制

| 机制 | 描述 | 代码位置 |
|------|------|----------|
| **View 系统** | bgfx ViewId 管理渲染顺序 | `Source/Render/View.cpp` |
| **Node::visit()** | 场景树遍历，按 order 排序 | `Source/Node/Node.cpp:visitInner()` |
| **Node::render()** | 节点实际渲染，可重写 | `Source/Node/Node.cpp:render()` |
| **RenderTarget** | 离屏渲染，使用 pushFront | `Source/Render/RenderTarget.cpp` |
| **Grabber** | Node 抓取到 RT + Effect 链 | `Node::Grabber` |

### 1.3 当前 Compute 调度实现

```cpp
// Director.h - 固定调度点
RefVector<ComputePass> _preSceneComputes;
RefVector<ComputePass> _prePostComputes;

// ComputePass.h - dispatch 接口
void dispatch(bgfx::ViewId viewId, uint32_t numX, uint32_t numY, uint32_t numZ = 1);
```

**问题**: 
- `runPreSceneCompute()` 和 `runPrePostCompute()` 被定义但 **未在 doRender() 中调用**
- 用户无法在特定 Node 渲染前后插入 compute

---

## 2. 方案对比分析

### 2.1 对比表格

| 方案 | 灵活性 | 实现复杂度 | 用户易用性 | 适用场景 | 维护成本 |
|------|--------|------------|------------|----------|----------|
| **A: Director 固定调度** | ⭐⭐ | ⭐ | ⭐⭐⭐⭐ | 全局效果 | ⭐ |
| **B: Node 级别调度** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | 每对象特效 | ⭐⭐ |
| **C: RenderTarget 级别** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | RT 后处理 | ⭐⭐ |
| **D: 纯手动调度** | ⭐⭐⭐⭐⭐ | ⭐ | ⭐⭐ | 高级用户 | ⭐ |
| **E: 混合方案** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | 所有场景 | ⭐⭐ |

### 2.2 各方案详细分析

#### 方案 A: Director 固定调度点（当前方案）

```
┌─────────────────────────────────────────────────────────────┐
│                     Rendering Pipeline                       │
├─────────────────────────────────────────────────────────────┤
│  [PreSceneComputes]  ← 固定点 1                              │
│         ↓                                                    │
│  [Scene Tree]                                                │
│         ↓                                                    │
│  [PrePostComputes]  ← 固定点 2                               │
│         ↓                                                    │
│  [Post Effects]                                              │
│         ↓                                                    │
│  [UI]                                                        │
└─────────────────────────────────────────────────────────────┘
```

**优点**:
- 实现简单，易于理解
- 性能可控，便于优化
- 适合全局效果（全局光照、雾效）

**缺点**:
- ❌ 无法在特定 Node 渲染后执行
- ❌ 无法在 RT 渲染后立即处理
- ❌ 限制了复杂渲染管线的可能性

**适用**: 简单项目、全局后处理

---

#### 方案 B: Node 级别调度

```cpp
// API 设计示例
class Node {
    // Pre-render compute (在节点渲染前)
    void setPreCompute(ComputePass* pass);
    ComputePass* getPreCompute() const;
    
    // Post-render compute (在节点渲染后)
    void setPostCompute(ComputePass* pass);
    ComputePass* getPostCompute() const;
    
    // 或者更灵活的回调方式
    void setComputeCallback(const ComputeCallback& callback);
};

// 使用示例
auto sprite = Sprite::create("image.png");
auto blurPass = ComputePass::create("blur.cs");
sprite->setPostCompute(blurPass);
```

**渲染流程变化**:
```
Node::visit() {
    preCompute->dispatch();  // 新增
    children with order < 0
    render()
    children with order >= 0
    postCompute->dispatch(); // 新增
}
```

**优点**:
- ✅ 每个节点可独立控制
- ✅ 符合 Dora 的 Node-centric 设计哲学
- ✅ 适合粒子系统、角色特效

**缺点**:
- ⚠️ 大量节点时性能开销（View 切换）
- ⚠️ 需要 ViewId 管理策略
- ⚠️ 可能导致 Draw Call 碎片化

**适用**: 每对象特效、角色技能效果

---

#### 方案 C: RenderTarget 级别调度

```cpp
// API 设计示例
class RenderTarget {
    // RT 渲染前的 compute
    void setPreCompute(ComputePass* pass);
    
    // RT 渲染后的 compute
    void setPostCompute(ComputePass* pass);
    
    // 批量添加
    void addComputePass(ComputePass* pass, ComputeStage stage);
};

// 使用示例
auto rt = RenderTarget::create(512, 512);
rt->setPostCompute(ssaoPass);  // SSAO 在 RT 渲染后
rt->render(node);
```

**渲染流程**:
```
RenderTarget::render() {
    preComputes.dispatch();   // 新增
    renderToTexture();
    postComputes.dispatch();  // 新增
}
```

**优点**:
- ✅ RT 是自然的计算边界
- ✅ 不影响主渲染管线
- ✅ 适合延迟渲染、SSAO、SSR

**缺点**:
- ⚠️ 只对使用 RT 的场景有效
- ⚠️ 不适用于普通节点

**适用**: 延迟渲染 G-Buffer 处理、RT 后处理

---

#### 方案 D: 纯手动调度

```cpp
// 当前已支持！用户可以：
auto computePass = ComputePass::create("shader.cs");

// 方法 1: 在 update 中手动调度
node->schedule([computePass](double dt) {
    SharedView.pushBack("MyCompute"_slice, [&]() {
        computePass->dispatch(SharedView.getId(), 16, 16);
    });
    return false; // one-shot
});

// 方法 2: 在 render 回调中
node->onRender([computePass](double dt) {
    SharedView.pushBack("Compute"_slice, [&]() {
        computePass->dispatch(SharedView.getId(), 8, 8);
    });
    return false;
});

// 方法 3: 自定义 Node 子类
class MyEffectNode : public Node {
    void render() override {
        // 自定义渲染逻辑，完全控制 compute 时机
        SharedView.pushBack("PreCompute"_slice, [&]() {
            _computePass->dispatch(SharedView.getId(), ...);
        });
        Node::render();
        SharedView.pushBack("PostCompute"_slice, [&]() {
            _computePass->dispatch(SharedView.getId(), ...);
        });
    }
};
```

**优点**:
- ✅ 最大灵活性
- ✅ 无需修改引擎
- ✅ 高级用户可完全控制

**缺点**:
- ❌ 需要用户理解 ViewId 系统
- ❌ 代码复杂度高
- ❌ 易出错（View 顺序问题）

**适用**: 高级用户、复杂渲染管线

---

#### 方案 E: 混合方案（推荐）

```
┌─────────────────────────────────────────────────────────────┐
│                   Hybrid Scheduling System                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  [Level 1: Director 全局调度] - 保留现有 API                  │
│      PreSceneComputes → Scene → PrePostComputes → PostFX    │
│                                                              │
│  [Level 2: RenderTarget 调度] - 新增                         │
│      RT.preComputes → RT.render → RT.postComputes           │
│                                                              │
│  [Level 3: Node 调度] - 新增（可选）                          │
│      Node.preCompute → Node.render → Node.postCompute       │
│                                                              │
│  [Level 4: 手动调度] - 现有支持                               │
│      用户完全控制 ViewId 和 dispatch 时机                     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**优点**:
- ✅ 满足所有使用场景
- ✅ 向后兼容（保留 Director API）
- ✅ 渐进式学习曲线
- ✅ 用户可按需选择复杂度

**缺点**:
- ⚠️ 实现工作量较大
- ⚠️ API 表面增大

---

## 3. 推荐方案：混合方案 (E)

### 3.1 推荐理由

1. **与 Dora 设计哲学一致**: 
   - Dora 已有类似的多层次设计（Director 全局 + Node 局部 + 手动控制）
   - SpriteEffect 和 PostEffect 已体现了"按需绑定"的思想

2. **满足所有用户需求**:
   - 简单用户：Director 固定点
   - 中级用户：RenderTarget 调度
   - 高级用户：Node 级别或完全手动

3. **向后兼容**: 保留现有 `addPreSceneCompute()` API

4. **符合 bgfx 最佳实践**: View 系统天然支持灵活的调度顺序

### 3.2 优先级建议

**Phase 1（立即）**: 修复现有实现
- 在 `doRender()` 中调用 `runPreSceneCompute()` 和 `runPrePostCompute()`
- 添加 ViewId 分配策略

**Phase 2（短期）**: RenderTarget 集成
- 添加 RT 级别的 compute 支持
- 适合 SSAO、SSR 等效果

**Phase 3（中期）**: Node 集成（可选）
- 视用户反馈决定是否实现
- 考虑性能优化

---

## 4. API 设计示例

### 4.1 Director 全局调度（现有，需修复）

```cpp
// 现有 API - 保持不变
Director::addPreSceneCompute(pass);
Director::removePreSceneCompute(pass);
Director::clearPreSceneCompute();

Director::addPrePostCompute(pass);
Director::removePrePostCompute(pass);
Director::clearPrePostCompute();
```

### 4.2 RenderTarget 级别调度（新增）

```cpp
// RenderTarget.h
class RenderTarget : public Object {
public:
    enum class ComputePosition {
        BeforeRender,
        AfterRender
    };
    
    // 新增方法
    void addComputePass(ComputePass* pass, ComputePosition pos);
    void removeComputePass(ComputePass* pass);
    void clearComputePasses();
    
    // 便捷方法
    void setPreCompute(ComputePass* pass);
    void setPostCompute(ComputePass* pass);
    
private:
    struct ComputeEntry {
        Ref<ComputePass> pass;
        ComputePosition position;
    };
    std::vector<ComputeEntry> _computePasses;
};
```

### 4.3 Node 级别调度（可选，Phase 3）

```cpp
// Node.h
class Node : public Object {
public:
    // 新增属性
    PROPERTY(ComputePass*, PreCompute);
    PROPERTY(ComputePass*, PostCompute);
    
    // 或者使用回调方式（更灵活）
    using ComputeCallback = std::function<void(bgfx::ViewId)>;
    void setComputeBeforeRender(const ComputeCallback& callback);
    void setComputeAfterRender(const ComputeCallback& callback);
    
protected:
    virtual void render() override;
    
private:
    Ref<ComputePass> _preCompute;
    Ref<ComputePass> _postCompute;
};
```

### 4.4 手动调度（现有，增强文档）

```cpp
// 已支持，需要更好的文档和示例
auto pass = ComputePass::create("effect.cs");

// 在任何地方手动调度
SharedView.pushBack("Compute"_slice, [&]() {
    pass->setImage(0, inputTexture, ComputeAccess::Read);
    pass->setImage(1, outputTexture, ComputeAccess::Write);
    pass->dispatch(SharedView.getId(), width/16, height/16);
});
```

---

## 5. 实现建议

### 5.1 Phase 1: 修复 Director 调度（立即）

**修改文件**: `Source/Basic/Director.cpp`

```cpp
void Director::doRender() {
    if (_paused || _stoped) return;

    const auto& defaultViewProj = getCurrentViewProjection();

    pushViewProjection(defaultViewProj, [&]() {
        // === 新增：Pre-scene compute ===
        if (!_preSceneComputes.empty()) {
            SharedView.pushBack("PreSceneCompute"_slice, [&]() {
                bgfx::ViewId viewId = SharedView.getId();
                for (ComputePass* pass : _preSceneComputes) {
                    if (pass) {
                        // 用户需在 add 前配置好 dispatch 参数
                        // 或提供回调
                    }
                }
            });
        }
        
        // === 现有渲染逻辑 ===
        if (SharedView.isPostProcessNeeded()) {
            // ... RT 渲染 ...
        } else {
            // ... 直接渲染 ...
        }
        
        // === 新增：Pre-post compute ===
        if (!_prePostComputes.empty()) {
            SharedView.pushBack("PrePostCompute"_slice, [&]() {
                bgfx::ViewId viewId = SharedView.getId();
                for (ComputePass* pass : _prePostComputes) {
                    if (pass) {
                        // dispatch logic
                    }
                }
            });
        }
        
        // === NanoVG, ImGui ===
        // ...
    });
}
```

**ComputePass 增强接口**:

```cpp
// ComputePass.h - 新增
class ComputePass : public Object {
public:
    // 现有 dispatch
    void dispatch(bgfx::ViewId viewId, uint32_t numX, uint32_t numY, uint32_t numZ = 1);
    
    // 新增：自动 dispatch 配置
    void setDispatchSize(uint32_t numX, uint32_t numY, uint32_t numZ = 1);
    void autoDispatch(bgfx::ViewId viewId);  // 使用预设的 size
    
private:
    uint32_t _dispatchX = 1, _dispatchY = 1, _dispatchZ = 1;
};
```

### 5.2 Phase 2: RenderTarget 集成（短期）

**修改文件**: `Source/Render/RenderTarget.cpp`

```cpp
void RenderTarget::renderAfterClear(Node* target, bool clear, Color color, float depth, uint8_t stencil) {
    SharedRendererManager.flush();
    
    // === 新增：Pre-render compute passes ===
    for (const auto& entry : _computePasses) {
        if (entry.position == ComputePosition::BeforeRender) {
            SharedView.pushFront("RTCompute"_slice, [&]() {
                entry.pass->autoDispatch(SharedView.getId());
            });
        }
    }
    
    // === 现有渲染逻辑 ===
    SharedView.pushFront("RenderTarget"_slice, [&]() {
        // ... existing code ...
    });
    
    // === 新增：Post-render compute passes ===
    for (const auto& entry : _computePasses) {
        if (entry.position == ComputePosition::AfterRender) {
            SharedView.pushFront("RTCompute"_slice, [&]() {
                entry.pass->autoDispatch(SharedView.getId());
            });
        }
    }
}
```

### 5.3 Phase 3: Node 集成（可选，中期）

**修改文件**: `Source/Node/Node.cpp`

```cpp
void Node::visitInner() {
    if (_flags.isOff(Node::Visible)) return;

    getWorld();

    auto& rendererManager = SharedRendererManager;
    
    // === 新增：Pre-compute ===
    if (_preCompute) {
        SharedView.pushBack("NodeCompute"_slice, [&]() {
            _preCompute->autoDispatch(SharedView.getId());
        });
    }
    
    if (_children && !_children->isEmpty() && _flags.isOn(Node::ChildrenVisible)) {
        // ... existing child traversal ...
    } else if (_flags.isOn(Node::SelfVisible)) {
        // render self
    }
    
    // === 新增：Post-compute ===
    if (_postCompute) {
        SharedView.pushBack("NodeCompute"_slice, [&]() {
            _postCompute->autoDispatch(SharedView.getId());
        });
    }
}
```

**性能优化**:
- 对于大量相同 compute pass，考虑批量 dispatch
- 提供"延迟 dispatch"模式，减少 View 切换

---

## 6. 使用场景示例

### 6.1 全局光照计算（Director 级别）

```lua
-- Lua 示例
local lightingPass = ComputePass("lighting.cs")
lightingPass:setDispatchSize(16, 16)
lightingPass:setImage(0, depthBuffer, ComputeAccess.Read)
lightingPass:setImage(1, normalBuffer, ComputeAccess.Read)
lightingPass:setImage(2, lightingOutput, ComputeAccess.Write)

Director:addPrePostCompute(lightingPass)
-- 在场景渲染后、后处理前执行
```

### 6.2 RenderTarget 后处理（RT 级别）

```lua
local rt = RenderTarget(1024, 1024, nil, ComputeAccess.ReadWrite)

local ssao = ComputePass("ssao.cs")
ssao:setDispatchSize(64, 64)

rt:setPostCompute(ssao)
-- RT 渲染完成后自动执行 SSAO

rt:render(sceneNode)
```

### 6.3 节点特效（Node 级别）

```lua
local sprite = Sprite("character.png")
local outline = ComputePass("outline.cs")
outline:setDispatchSize(32, 32)

sprite:setPostCompute(outline)
-- 角色渲染后立即处理轮廓
```

### 6.4 复杂管线（手动调度）

```lua
local function complexPipeline()
    local gbuffer = RenderTarget(1920, 1080)
    local lighting = ComputePass("deferred_lighting.cs")
    local ssr = ComputePass("ssr.cs")
    local taa = ComputePass("taa.cs")
    
    -- 自定义渲染顺序
    gbuffer:render(scene)
    
    SharedView:pushBack("Lighting", function()
        lighting:setImage(0, gbuffer:getTexture(), ComputeAccess.Read)
        lighting:dispatch(SharedView:getId(), 120, 68)
    end)
    
    SharedView:pushBack("SSR", function()
        ssr:setImage(0, lightingOutput, ComputeAccess.Read)
        ssr:dispatch(SharedView:getId(), 120, 68)
    end)
    
    SharedView:pushBack("TAA", function()
        taa:dispatch(SharedView:getId(), 120, 68)
    end)
end
```

---

## 7. 迁移路径

### 7.1 现有用户

无需修改代码，现有 API 保持不变。

### 7.2 新用户

1. 从 Director 固定点开始
2. 需要 RT 处理时使用 RT 级别调度
3. 高级需求使用手动调度

---

## 8. 性能考虑

### 8.1 View 切换开销

- bgfx View 切换有少量开销
- 建议：批量相同类型的 compute

### 8.2 内存管理

- ComputePass 持有 Texture 引用
- 已实现 `_boundTextures` 防止悬空指针

### 8.3 多线程

- bgfx 支持多线程提交
- 当前实现兼容多线程

---

## 9. 总结

**推荐采用混合方案（方案 E）**，分阶段实施：

1. **Phase 1（立即）**: 修复 Director 调用，完善现有实现
2. **Phase 2（短期）**: 添加 RenderTarget 级别调度
3. **Phase 3（可选）**: 根据用户反馈决定 Node 级别实现

这种方案：
- ✅ 向后兼容
- ✅ 满足所有使用场景
- ✅ 渐进式复杂度
- ✅ 符合 Dora 架构设计
