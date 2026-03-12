# ComputePass 最佳归属和调度设计分析报告

## 1. Dora 用户代码模式分析

### 1.1 用户代码执行入口

通过阅读 Dora 的代码，发现用户主要通过以下方式编写游戏逻辑：

#### 脚本语言支持
Dora 支持多种脚本语言：
- **Lua / YueScript / Teal** - 主要脚本语言
- **TypeScript / TSX** - 类型安全的脚本
- **Wa / Rust** - 编译为 WASM 运行
- **C#** - 通过动态库调用

#### 代码执行模式

**模式 A：脚本回调（最常见）**
```lua
-- 用户创建 Node 并注册回调
local sprite = Sprite("Image/logo.png")
sprite:schedule(function(dt)
    -- 每帧逻辑
    return false  -- 返回 true 结束调度
end)

sprite:onUpdate(function(dt)
    -- 更新逻辑
end)

sprite:onRender(function(dt)
    -- 渲染逻辑
end)

sprite:slot("Enter", function(event)
    -- 事件处理
end)
```

**模式 B：继承 Node（较少见，主要用于 C++）**
```lua
-- YueScript 中可以模拟继承
class MyNode extends Node
    update: (dt) =>
        -- 更新逻辑
    render: =>
        -- 渲染逻辑
```

**模式 C：全局调度**
```lua
-- 使用 Director 的调度器
Director.scheduler:schedule(function(dt)
    -- 全局逻辑
end)

-- 或使用协程
thread(function()
    while true do
        sleep(1)
        -- 每秒执行
    end
end)
```

### 1.2 Effect/SpriteEffect 的使用方式

用户使用 Effect 的方式是**组合而非继承**：

```lua
-- 创建 Effect
local effect = SpriteEffect()
effect:add(Pass("vs_shader", "fs_shader"))

-- 应用到 Sprite
sprite.effect = effect

-- 设置 uniform
effect:set("u_time", time)
```

**关键观察**：
- Effect 是独立对象，不绑定到特定 Node
- 用户通过属性赋值将 Effect 关联到 Sprite
- Effect 的调度由渲染管线自动管理
- 用户不需要关心 dispatch 时机

### 1.3 Dora 设计哲学

从代码分析可以看出 Dora 的设计哲学：

1. **简单易用** - 提供高层 API，隐藏底层细节
2. **组合优于继承** - 通过组合实现功能扩展
3. **自动化管理** - 引擎自动处理生命周期和调度
4. **多语言友好** - API 设计考虑了多种脚本语言

---

## 2. 不同 ComputePass 使用场景分析

| 场景 | 描述 | 典型归属 | 调度时机 | 依赖关系 |
|------|------|----------|----------|----------|
| **GPU 粒子系统** | 粒子位置/速度计算 | Node 持有 | Node::render() | 可能依赖 Node 的 transform |
| **程序化纹理生成** | 动态生成纹理数据 | Texture/Effect | 纹理创建时/每帧 | 独立或依赖参数 |
| **RT 后处理** | 对 RT 内容做滤波等 | RenderTarget | RT 渲染后 | 依赖 RT 的 color buffer |
| **全局物理模拟** | 独立于场景的物理 | Director | 每帧开始 | 独立 |
| **SSAO/SSR** | 全屏后处理 | View/Director | 场景渲染后 | 依赖 depth/normal buffer |
| **视频处理** | 对视频帧做处理 | Video/Texture | 视频帧更新时 | 依赖视频帧纹理 |
| **GPU 排序/搜索** | 通用计算任务 | 用户管理 | 用户决定 | 独立 |
| **深度图处理** | 阴影/遮挡计算 | Camera/RenderTarget | 渲染后 | 依赖 depth buffer |

### 关键观察

1. **归属关系多样** - 不同场景有不同的自然归属
2. **调度时机各异** - 有的需要每帧，有的按需触发
3. **依赖关系复杂** - 有的依赖渲染结果，有的独立

---

## 3. 方案评估

### 方案 A：纯 Node 组合

**设计**：
```cpp
class ComputeNode : public Node {
public:
    void add(ComputePass* pass);
    void render() override;  // 自动 dispatch
};
```

**优点**：
- 架构简单统一
- 符合 Dora 的 Node-centric 设计
- 自动继承 Node 的生命周期管理

**缺点**：
- 全局任务需要创建"假 Node"
- 不适合非场景相关的计算
- RenderTarget 的 compute 难以表达

**适用场景**：GPU 粒子系统、程序化纹理

---

### 方案 B：Director 全局回调

**设计**：
```cpp
class Director {
public:
    void onPreRender(const std::function<void()>& callback);
    void onPostRender(const std::function<void()>& callback);
};
```

**优点**：
- 灵活，不强制绑定 Node
- 适合全局任务
- 用户可以选择时机

**缺点**：
- 增加 Director 职责
- 回调管理复杂（需要取消注册）
- 不符合 Dora 的对象化设计

**适用场景**：全局物理模拟、SSAO/SSR

---

### 方案 C：独立 ComputeNode

**设计**：
```cpp
class ComputeNode : public Object {
public:
    void add(ComputePass* pass);
    void dispatch();
    void scheduleAuto();  // 注册到 Director
};
```

**优点**：
- 语义清晰
- 不参与渲染树
- 可以像 Node 一样管理

**缺点**：
- 本质还是类似 Node 的对象
- 需要额外的调度机制
- 与 Node 的关系模糊

**适用场景**：通用计算任务

---

### 方案 D：ComputePass 独立调度

**设计**：
```cpp
// ComputePass 完全独立
auto pass = ComputePass::create("shader");
pass->set("u_param", value);
pass->setImage(0, texture, ComputeAccess::Write);
pass->dispatch(viewId, x, y, z);  // 手动 dispatch
```

**优点**：
- 最大灵活性
- 类似 Unity/Unreal 的用法
- 适合高级用户

**缺点**：
- 用户需要理解 viewId 和调度时机
- 容易出错（顺序、同步）
- 不符合 Dora 的简单易用哲学

**适用场景**：高级用户、复杂计算图

---

### 方案 E：混合方案（当前实现）

**当前实现**：
```cpp
// Director 提供 PreScene/PrePost 调度点
Director::addPreSceneCompute(pass);
Director::addPrePostCompute(pass);

// RenderTarget 提供 Pre/Post Compute
rt->setPreCompute(pass);
rt->setPostCompute(pass);

// ComputePass 支持手动和自动 dispatch
pass->setDispatchSize(x, y, z);  // 配置自动 dispatch
pass->dispatch(viewId, x, y, z);  // 手动 dispatch
```

**优点**：
- 覆盖多种场景
- 灵活性高

**缺点**：
- API 复杂，学习曲线陡峭
- 用户需要理解多种调度方式
- 容易造成混乱（应该用哪种？）

---

## 4. 推荐方案：分层设计

基于 Dora 的设计哲学和使用模式，我推荐**分层设计**：

### 4.1 设计原则

1. **简单场景简单用** - 80% 的用例应该有简单的 API
2. **高级场景可能** - 剩下 20% 的复杂用例也能实现
3. **自动优先** - 默认自动管理，专家可手动控制
4. **组合而非继承** - 延续 Dora 的设计风格

### 4.2 分层 API 设计

#### 层级 1：Node 集成（最简单）

**适用场景**：GPU 粒子、程序化纹理、与 Node 关联的计算

**设计**：
```cpp
class Node {
public:
    // 新增：ComputePass 管理
    void setCompute(ComputePass* pass);
    ComputePass* getCompute() const;
    
    // 或更灵活的 ComputeEffect
    void setComputeEffect(ComputeEffect* effect);
    ComputeEffect* getComputeEffect() const;
};
```

**使用示例**：
```lua
-- Lua/YueScript 用户代码
local particleCompute = ComputePass("particle_compute")
particleCompute:setDispatchSize(100, 1, 1)
particleCompute:set("u_deltaTime", 0.016)

local emitter = Node()
emitter:setCompute(particleCompute)
emitter:schedule(function(dt)
    particleCompute:set("u_deltaTime", dt)
end)
```

**实现逻辑**：
- Node::render() 时自动检查是否有 ComputePass
- 如果有且配置了 autoDispatch，在渲染前自动 dispatch
- 计算结果可以用于后续渲染

#### 层级 2：RenderTarget 集成（保持现有设计）

**适用场景**：RT 后处理、纹理处理

**设计**（已实现）：
```cpp
class RenderTarget {
public:
    void setPreCompute(ComputePass* pass);   // 渲染前计算
    void setPostCompute(ComputePass* pass);  // 渲染后计算
};
```

**使用示例**：
```lua
-- Lua 用户代码
local blurPass = ComputePass("blur")
blurPass:setDispatchSize(rt.width / 16, rt.height / 16, 1)

local rt = RenderTarget(800, 600)
rt:setPostCompute(blurPass)

-- 渲染到 RT，自动执行 blur
rt:renderWithClear(sceneNode, Color(0xff000000))
```

#### 层级 3：Director 调度点（保持现有设计）

**适用场景**：全局物理、SSAO/SSR、全屏后处理

**设计**（已实现）：
```cpp
class Director {
public:
    void addPreSceneCompute(ComputePass* pass);  // 场景渲染前
    void removePreSceneCompute(ComputePass* pass);
    
    void addPrePostCompute(ComputePass* pass);   // 场景后、UI前
    void removePrePostCompute(ComputePass* pass);
};
```

**使用示例**：
```lua
-- Lua 用户代码
local physicsCompute = ComputePass("gpu_physics")
physicsCompute:setDispatchSize(100, 100, 1)
physicsCompute:setDispatchSize(100, 100, 1)

Director:addPreSceneCompute(physicsCompute)

-- 在 update 中更新参数
Director.postNode:schedule(function(dt)
    physicsCompute:set("u_deltaTime", dt)
end)
```

#### 层级 4：手动调度（高级用户）

**适用场景**：复杂计算图、自定义调度

**设计**（已实现）：
```cpp
class ComputePass {
public:
    void dispatch(bgfx::ViewId viewId, uint32_t x, uint32_t y, uint32_t z);
};
```

**使用示例**：
```lua
-- 高级用户代码
local pass1 = ComputePass("compute1")
local pass2 = ComputePass("compute2")

-- 自定义调度
Director.postNode:onRender(function()
    local viewId1 = SharedView.getId("CustomCompute1")
    pass1:dispatch(viewId1, 100, 1, 1)
    
    local viewId2 = SharedView.getId("CustomCompute2")
    pass2:dispatch(viewId2, 100, 1, 1)
end)
```

### 4.3 回答核心问题

**Q: 如果 dispatch 在 Node::render() 中调用，ComputePass 是否必须绑定到 Node？**

**A: 不一定。推荐分层设计：**

1. **Node 持有的 ComputePass** → 在 Node::render() 中自动 dispatch
2. **RenderTarget 持有的 ComputePass** → 在 RT 渲染流程中 dispatch
3. **Director 管理的 ComputePass** → 在帧循环的特定时机 dispatch
4. **用户手动管理的 ComputePass** → 用户决定 dispatch 时机

**ComputePass 可以属于不同的对象，取决于使用场景。**

---

## 5. 完整 API 设计

### 5.1 ComputePass（保持现有设计）

```cpp
class ComputePass : public Object {
public:
    // Uniform 设置
    void set(String name, float var);
    void set(String name, const Vec4& var);
    void set(String name, const Matrix& var);
    Value* get(String name) const;
    
    // Texture 绑定
    void setImage(uint8_t stage, Texture2D* texture, 
                  ComputeAccess access, 
                  bgfx::TextureFormat::Enum format = bgfx::TextureFormat::Count);
    
    // 自动 dispatch 配置
    void setDispatchSize(uint32_t x, uint32_t y, uint32_t z = 1);
    bool hasAutoDispatch() const;
    
    // 手动 dispatch（高级用户）
    void dispatch(bgfx::ViewId viewId, uint32_t x, uint32_t y, uint32_t z = 1);
    
    static bool isSupported();
    CREATE_FUNC_NULLABLE(ComputePass);
};
```

### 5.2 Node 扩展（新增）

```cpp
class Node {
public:
    // 新增：ComputePass 支持
    void setCompute(ComputePass* pass);
    ComputePass* getCompute() const;
    
    void setComputeEffect(ComputeEffect* effect);
    ComputeEffect* getComputeEffect() const;
    
protected:
    virtual void render() override {
        // 1. dispatch compute pass if configured
        if (_compute || _computeEffect) {
            dispatchComputePasses();
        }
        
        // 2. 原有渲染逻辑
        // ...
    }
    
private:
    void dispatchComputePasses() {
        SharedView.pushFront("NodeCompute"_slice, [&]() {
            bgfx::ViewId viewId = SharedView.getId();
            bgfx::setViewClear(viewId, BGFX_CLEAR_NONE);
            
            if (_compute && _compute->hasAutoDispatch()) {
                _compute->dispatchAuto(viewId);
            }
            if (_computeEffect) {
                for (auto pass : _computeEffect->getPasses()) {
                    if (pass->hasAutoDispatch()) {
                        pass->dispatchAuto(viewId);
                    }
                }
            }
        });
    }
    
    Ref<ComputePass> _compute;
    Ref<ComputeEffect> _computeEffect;
};
```

### 5.3 RenderTarget（保持现有设计）

```cpp
class RenderTarget {
public:
    void setPreCompute(ComputePass* pass);
    ComputePass* getPreCompute() const;
    
    void setPostCompute(ComputePass* pass);
    ComputePass* getPostCompute() const;
    
private:
    Ref<ComputePass> _preCompute;
    Ref<ComputePass> _postCompute;
};
```

### 5.4 Director（保持现有设计）

```cpp
class Director {
public:
    // Pre-scene compute passes
    void addPreSceneCompute(NotNull<ComputePass, 1> pass);
    void removePreSceneCompute(NotNull<ComputePass, 1> pass);
    void clearPreSceneCompute();
    
    // Pre-post compute passes (after scene, before UI)
    void addPrePostCompute(NotNull<ComputePass, 1> pass);
    void removePrePostCompute(NotNull<ComputePass, 1> pass);
    void clearPrePostCompute();
};
```

---

## 6. 使用示例

### 6.1 GPU 粒子系统（Node 集成）

```lua
-- Lua 用户代码
local ParticleEmitter = -> 
    emitter = Node()
    emitter.size = Size(100, 100)
    
    -- 创建 compute pass
    local compute = ComputePass("particle_update")
    compute:setDispatchSize(1000, 1, 1)  -- 1000 个粒子
    
    -- 创建粒子数据纹理
    local particleData = Texture2D(1000, 1, "RGBA32F")
    compute:setImage(0, particleData, ComputeAccess.ReadWrite)
    
    emitter.compute = compute
    
    -- 每帧更新参数
    emitter:schedule(function(dt)
        compute:set("u_deltaTime", dt)
        compute:set("u_time", App.runningTime)
    end)
    
    -- 渲染粒子（使用更新后的数据）
    emitter:onRender(function()
        -- 使用 particleData 渲染粒子
    end)
    
    emitter

-- 使用
local emitter = ParticleEmitter()
Director.entry:addChild(emitter)
```

### 6.2 RT 后处理（RenderTarget 集成）

```lua
-- Lua 用户代码
local rt = RenderTarget(800, 600)

-- 创建模糊 compute pass
local blurPass = ComputePass("blur")
blurPass:setDispatchSize(800 / 16, 600 / 16, 1)
blurPass:setImage(0, rt.texture, ComputeAccess.Read)
blurPass:set("u_texelSize", Vec4(1/800, 1/600, 0, 0))

-- 创建输出纹理
local outputTex = Texture2D(800, 600, "RGBA8", ComputeAccess.Write)
blurPass:setImage(1, outputTex, ComputeAccess.Write)

rt.postCompute = blurPass

-- 渲染场景到 RT，自动执行模糊
rt:renderWithClear(sceneNode, Color(0xff000000))

-- 使用 outputTex 显示结果
local sprite = Sprite(outputTex)
```

### 6.3 全局物理模拟（Director 调度）

```lua
-- Lua 用户代码
local physicsPass = ComputePass("gpu_physics")
physicsPass:setDispatchSize(100, 100, 1)

-- 创建物理数据纹理
local positionTex = Texture2D(100, 100, "RGBA32F")
local velocityTex = Texture2D(100, 100, "RGBA32F")

physicsPass:setImage(0, positionTex, ComputeAccess.ReadWrite)
physicsPass:setImage(1, velocityTex, ComputeAccess.ReadWrite)

-- 添加到 Director 的 pre-scene 阶段
Director:addPreSceneCompute(physicsPass)

-- 更新参数
Director.postNode:schedule(function(dt)
    physicsPass:set("u_deltaTime", dt)
    physicsPass:set("u_gravity", Vec4(0, -9.8, 0, 0))
end)

-- 使用物理结果渲染
local physicsSprite = Sprite(positionTex)
```

### 6.4 复杂计算图（手动调度）

```lua
-- 高级用户代码
local pass1 = ComputePass("pass1")
local pass2 = ComputePass("pass2")
local pass3 = ComputePass("pass3")

-- 配置依赖关系
local tempTex1 = Texture2D(512, 512, "RGBA32F")
local tempTex2 = Texture2D(512, 512, "RGBA32F")

pass1:setImage(0, inputTex, ComputeAccess.Read)
pass1:setImage(1, tempTex1, ComputeAccess.Write)

pass2:setImage(0, tempTex1, ComputeAccess.Read)
pass2:setImage(1, tempTex2, ComputeAccess.Write)

pass3:setImage(0, tempTex2, ComputeAccess.Read)
pass3:setImage(1, outputTex, ComputeAccess.Write)

-- 自定义调度
local computeNode = Node()
computeNode:onRender(function()
    -- 手动控制顺序
    local viewId1 = SharedView.getId("Compute1")
    pass1:dispatch(viewId1, 32, 32, 1)
    
    local viewId2 = SharedView.getId("Compute2")
    pass2:dispatch(viewId2, 32, 32, 1)
    
    local viewId3 = SharedView.getId("Compute3")
    pass3:dispatch(viewId3, 32, 32, 1)
end)
```

---

## 7. 实现建议

### 7.1 需要修改的代码

1. **Node.h / Node.cpp**
   - 添加 `_compute` 和 `_computeEffect` 成员
   - 添加 `setCompute()` / `getCompute()` 方法
   - 添加 `setComputeEffect()` / `getComputeEffect()` 方法
   - 在 `render()` 中添加 compute dispatch 逻辑

2. **ComputePass.h / ComputePass.cpp**
   - 保持现有实现
   - 确保 `hasAutoDispatch()` 和 `dispatchAuto()` 正确工作

3. **RenderTarget.h / RenderTarget.cpp**
   - 保持现有实现（已有 Pre/Post Compute）

4. **Director.h / Director.cpp**
   - 保持现有实现（已有 PreScene/PrePost Compute）

5. **Lua 绑定**
   - 添加 `Node:setCompute()` / `Node:getCompute()` 绑定
   - 添加 `Node:setComputeEffect()` / `Node:getComputeEffect()` 绑定
   - 确保 `ComputePass` 和 `ComputeEffect` 已正确绑定

### 7.2 需要删除/简化的代码

**当前实现已经很完善，主要需要添加 Node 集成。**

可以考虑删除或简化的部分：
- 如果 Director 的 PreScene/PrePost 调度点足够，可以考虑简化 RenderTarget 的 Pre/Post Compute（保留一个即可）

### 7.3 文档建议

需要提供以下文档：

1. **快速开始** - 展示最简单的用法（Node 集成）
2. **API 参考** - 详细列出所有 API
3. **使用场景指南** - 不同场景应该使用哪种方式
4. **高级用法** - 手动调度和复杂计算图
5. **最佳实践** - 性能优化建议

---

## 8. 总结

### 8.1 核心结论

1. **ComputePass 不必须绑定到 Node**，但可以绑定到 Node 以简化常见用例
2. **推荐分层设计**，提供从简单到高级的多种使用方式
3. **保持现有架构**，Director 和 RenderTarget 的集成已经很完善
4. **添加 Node 集成**，让 80% 的简单用例更容易实现

### 8.2 设计要点

| 层级 | 归属 | 调度时机 | 适用场景 | 难度 |
|------|------|----------|----------|------|
| 1 | Node | Node::render() | GPU 粒子、程序化纹理 | ⭐ |
| 2 | RenderTarget | RT 渲染前后 | RT 后处理、纹理处理 | ⭐⭐ |
| 3 | Director | 帧循环特定时机 | 全局物理、SSAO/SSR | ⭐⭐ |
| 4 | 用户管理 | 用户决定 | 复杂计算图 | ⭐⭐⭐ |

### 8.3 下一步

1. 实现 Node 的 ComputePass 集成
2. 完善 Lua/TypeScript 绑定
3. 编写文档和示例代码
4. 添加单元测试和性能测试

---

## 附录：参考引擎对比

| 引擎 | ComputeShader 归属 | 调度方式 | 学习曲线 |
|------|-------------------|----------|----------|
| **Unity** | 独立资源 | 用户手动 Dispatch | 中等 |
| **Unreal** | Render Dependency Graph | RDG 自动调度 | 较高 |
| **Godot** | RenderingDevice | 直接 dispatch | 较高 |
| **bgfx** | 无封装 | 直接 `bgfx::dispatch()` | 较高 |
| **Dora (推荐)** | 多种归属可选 | 自动 + 手动 | 低~中等 |

Dora 的设计在易用性和灵活性之间取得了平衡，延续了其"简单易用"的哲学。
