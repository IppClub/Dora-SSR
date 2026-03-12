# Effect 支持.ComputePass 的可行性分析报告

## 1. Dora Effect 系统现状分析

### 1.1 当前架构

```
Effect (基类)
├── Pass (渲染 pass)
│   ├── Vertex Shader
│   ├── Fragment Shader
│   └── Uniforms
├── SpriteEffect (用于 Sprite)
│   └── sampler uniform (s_texColor)
└── [已存在] ComputePass (独立类)
    ├── Compute Shader
    ├── Uniforms
    └── dispatch(viewId, x, y, z)
```

### 1.2 Effect 的使用场景

**Sprite 渲染流程**（基于代码分析）：
```cpp
// 1. Sprite::render() - 收集渲染数据
void Sprite::render() {
    // 计算 transform、颜色等
    SharedSpriteRenderer.push(this);
    Node::render();  // 递归渲染子节点
}

// 2. SpriteRenderer::render() - 批量提交
void SpriteRenderer::render() {
    // 设置 vertex/index buffer
    bgfx::setVertexBuffer(0, &vertexBuffer);
    bgfx::setIndexBuffer(&indexBuffer);
    
    // 遍历 Effect 的所有 Pass
    for (Pass* pass : effect->getPasses()) {
        bgfx::submit(viewId, pass->apply(), ...);
    }
}
```

**关键观察**：
- Effect 在 **渲染阶段** 应用
- 与 Sprite 的顶点数据紧密耦合
- Pass 通过 `bgfx::submit()` 提交图形渲染命令

### 1.3 ComputePass 现状

```cpp
class ComputePass : public Object {
    // dispatch 需要显式的 viewId
    void dispatch(bgfx::ViewId viewId, uint32_t x, uint32_t y, uint32_t z);
    
    // image binding
    void setImage(uint8_t stage, Texture2D* texture, 
                  ComputeAccess access, bgfx::TextureFormat::Enum format);
};
```

**关键特点**：
- ComputePass 已经存在且独立于 Effect
- 需要显式的 `viewId` 参数来控制执行顺序
- 通过 `bgfx::dispatch()` 提交计算任务

---

## 2. 语义分析：Effect 与 ComputePass 的契合度

### 2.1 Effect 的语义本质

**Effect** = "应用于渲染对象的着色器效果"

- **目的**：改变对象的视觉表现
- **输入**：顶点数据、纹理、uniform 参数
- **输出**：到帧缓冲的图形输出
- **时机**：在对象渲染时同步执行

### 2.2 ComputePass 的语义本质

**ComputePass** = "通用 GPU 计算"

- **目的**：执行任意并行计算
- **输入/输出**：纹理、buffer、uniform 参数
- **特点**：无图形管线概念，没有固定功能阶段
- **时机**：可以独立于渲染存在

### 2.3 语义冲突点

| 维度 | Effect | ComputePass | 冲突程度 |
|------|--------|-------------|----------|
| **目的** | 渲染对象 | 通用计算 | 🔴 高 |
| **输出** | 帧缓冲 | 纹理/Buffer | 🟡 中 |
| **触发** | 对象渲染时 | 任意时机 | 🔴 高 |
| **数据流** | 顶点 → 像素 | 任意 | 🔴 高 |

**结论**：直接将 ComputePass 作为 Effect 的一部分存在 **语义冲突**。

---

## 3. 集成场景深度分析

### 场景 A：Effect 包含 ComputePass 作为预处理

```cpp
// 示例：高斯模糊效果
class BlurEffect : public Effect {
    ComputePass* _preCompute;  // 计算模糊权重/降采样
    Pass* _renderPass;         // 渲染 pass
};
```

**问题分析**：

1. **调度顺序**：
   ```cpp
   // 需要保证 compute 在 render 之前执行
   void BlurEffect::apply() {
       // ❌ 问题：Effect::apply() 在 SpriteRenderer::render() 中调用
       // 此时已经收集完顶点数据，准备提交
       _preCompute->dispatch(viewId, x, y, z);  // 何时执行？
       
       // render pass 的执行
       for (Pass* pass : getPasses()) {
           bgfx::submit(viewId, pass->apply());
       }
   }
   ```

2. **View ID 管理**：
   - bgfx 要求 compute 和 graphics pass 通过 viewId 排序
   - Effect 不知道自己的 viewId（由 SpriteRenderer 管理）

3. **资源依赖**：
   - ComputePass 可能需要读取 Sprite 的纹理
   - 但 Sprite 的纹理是在渲染时才绑定

**可行性评估**：🟡 **技术上可行，但需要重大架构调整**

### 场景 B：纯 ComputePass Effect

```cpp
// 示例：GPU 粒子系统
class ParticleComputeEffect : public Effect {
    ComputePass* _computePass;
    // 没有 Pass，只有 compute
};
```

**问题分析**：

1. **语义错误**：
   - 没有图形输出，不能称为 "Effect"
   - 更像是 "ComputeTask" 或 "ComputeNode"

2. **使用方式不匹配**：
   ```cpp
   sprite->setEffect(particleEffect);  // ❌ semantic wrong
   // particleEffect 不会改变 sprite 的外观
   ```

**可行性评估**：🔴 **不合理，违反 Effect 的语义**

### 场景 C：Effect 支持混合 Pass 类型

```cpp
class Effect : public Object {
    void addPass(Pass* pass);
    void addComputePass(ComputePass* pass);  // 新增
};
```

**问题分析**：

1. **执行顺序**：
   ```cpp
   void SpriteRenderer::render() {
       // 需要区分 compute 和 graphics pass
       for (auto& pass : effect->getAllPasses()) {
           if (pass->isCompute()) {
               bgfx::dispatch(viewId, ...);
           } else {
               bgfx::submit(viewId, ...);
           }
       }
   }
   ```

2. **批处理问题**：
   - 当前 SpriteRenderer 批量提交多个 Sprite
   - 如果每个 Effect 都有不同的 compute pass，批处理会失效

3. **资源生命周期**：
   - ComputePass 绑定的纹理需要独立管理
   - 不能复用 Sprite 的纹理绑定逻辑

**可行性评估**：🟡 **可行但复杂，影响性能和可维护性**

---

## 4. 替代方案设计

基于以上分析，我推荐以下方案：

### 方案 1：独立的 ComputeNode（推荐 ⭐⭐⭐⭐⭐）

**设计思路**：将 compute 作为独立节点，通过 view 系统控制执行顺序

```cpp
// 新增 ComputeNode 类
class ComputeNode : public Node {
public:
    void addComputePass(NotNull<ComputePass, 1> pass);
    
    virtual void render() override {
        // 在专用 view 中 dispatch
        for (auto& pass : _computePasses) {
            pass->dispatch(_viewId, _dispatchX, _dispatchY, _dispatchZ);
        }
        Node::render();
    }
    
    PROPERTY(uint32_t, DispatchX);
    PROPERTY(uint32_t, DispatchY);
    PROPERTY(uint32_t, DispatchZ);
    
private:
    bgfx::ViewId _viewId;
    std::vector<Ref<ComputePass>> _computePasses;
};

// 使用示例
class GaussianBlurNode : public Node {
    ComputeNode* _computeNode;
    Sprite* _displaySprite;
    Effect* _displayEffect;
    
public:
    void render() override {
        // 1. compute pass 在前置 view 执行
        _computeNode->visit();  // dispatch compute
        
        // 2. render pass 在主 view 执行
        _displaySprite->visit();  // 正常渲染
        
        Node::render();
    }
};
```

**优点**：
- ✅ 语义清晰：Compute 是 Node，不是 Effect
- ✅ 不修改现有 Effect 系统
- ✅ 灵活的执行顺序控制
- ✅ 符合 Unity/Unreal 的设计模式

**缺点**：
- ❌ 需要用户管理 compute 和 render 的协调

---

### 方案 2：ComputeEffect 作为独立类型（推荐 ⭐⭐⭐⭐）

**设计思路**：创建与 Effect 平行的新类型

```cpp
// 新增 ComputeEffect 基类
class ComputeEffect : public Object {
public:
    void add(NotNull<ComputePass, 1> pass);
    ComputePass* get(size_t index) const;
    void clear();
    
    // dispatch 所有 compute passes
    void dispatch(bgfx::ViewId viewId);
    
    CREATE_FUNC_NOT_NULL(ComputeEffect);

protected:
    ComputeEffect();

private:
    RefVector<ComputePass> _passes;
};

// 使用示例
class ParticleSystem : public Node {
    Ref<ComputeEffect> _computeEffect;  // 粒子更新
    Ref<Sprite> _particleSprite;         // 粒子渲染
    
    void update(float dt) override {
        // 更新 compute 参数
        _computeEffect->set("u_time", _time);
        _computeEffect->set("u_deltaTime", dt);
    }
    
    void render() override {
        // 1. dispatch compute
        SharedView.pushFront("particle_compute", [this]() {
            _computeEffect->dispatch(SharedView.getId(), ...);
        });
        
        // 2. render particles
        _particleSprite->visit();
        
        Node::render();
    }
};
```

**优点**：
- ✅ 类型安全：区分 Effect 和 ComputeEffect
- ✅ 符合现有代码风格
- ✅ 易于扩展（可以添加 ComputeSpriteEffect 等）

**缺点**：
- ❌ 需要新增类型层次

---

### 方案 3：组合模式（Effect + ComputePass）（推荐 ⭐⭐⭐）

**设计思路**：Node 同时持有 Effect 和 ComputePass

```cpp
class Node {
    // 现有
    virtual Effect* getEffect() const { return nullptr; }
    
    // 新增
    virtual ComputeEffect* getComputeEffect() const { return nullptr; }
    
    virtual void render() {
        // 1. 先执行 compute
        if (auto computeEffect = getComputeEffect()) {
            SharedView.pushFront("compute_pre", [computeEffect]() {
                computeEffect->dispatch(SharedView.getId());
            });
        }
        
        // 2. 再执行渲染
        // ... 现有渲染逻辑
    }
};

// 使用示例
class AdvancedSprite : public Sprite {
    Ref<ComputeEffect> _computeEffect;
    
public:
    ComputeEffect* getComputeEffect() const override {
        return _computeEffect;
    }
};
```

**优点**：
- ✅ 向后兼容
- ✅ 灵活组合
- ✅ 不破坏现有代码

**缺点**：
- ❌ Node 基类变复杂
- ❌ 需要修改所有 Node 子类

---

### 方案 4：混合 Effect（不推荐 ⭐⭐）

**设计思路**：在 Effect 中混合 Pass 和 ComputePass

```cpp
class Effect : public Object {
public:
    enum class PassType { Graphics, Compute };
    
    void addPass(Pass* pass);
    void addComputePass(ComputePass* pass, uint32_t x, uint32_t y, uint32_t z);
    
    // SpriteRenderer 需要修改
    void applyAll(bgfx::ViewId viewId);
    
private:
    struct PassEntry {
        PassType type;
        Ref<Object> pass;  // Pass or ComputePass
        uint32_t dispatchSize[3];  // for compute
    };
    std::vector<PassEntry> _passes;
};
```

**优点**：
- ✅ API 简单

**缺点**：
- ❌ 语义混乱
- ❌ 难以管理执行顺序
- ❌ 破坏现有批处理优化

---

## 5. 推荐方案详细设计

### 5.1 推荐：方案 2（ComputeEffect 独立类型）

**理由**：
1. 语义最清晰
2. 不破坏现有架构
3. 符合业界最佳实践
4. 易于使用和扩展

### 5.2 API 设计

```cpp
// Source/Effect/ComputeEffect.h
#pragma once

#include "Support/Common.h"
#include "Effect/ComputePass.h"

NS_DORA_BEGIN

class ComputeEffect : public Object {
public:
    PROPERTY_READONLY_CREF(RefVector<ComputePass>, Passes);
    
    void add(NotNull<ComputePass, 1> pass);
    ComputePass* get(size_t index) const;
    void clear();
    
    // 便捷方法：设置所有 pass 的 uniform
    void set(String name, float var);
    void set(String name, const Vec4& var);
    void set(String name, const Matrix& var);
    
    // dispatch 所有 compute passes
    void dispatch(bgfx::ViewId viewId, uint32_t x, uint32_t y, uint32_t z = 1);
    
    CREATE_FUNC_NOT_NULL(ComputeEffect);

protected:
    ComputeEffect();

private:
    RefVector<ComputePass> _passes;
    DORA_TYPE_OVERRIDE(ComputeEffect);
};

NS_DORA_END
```

```cpp
// Source/Effect/ComputeEffect.cpp
#include "Const/Header.h"
#include "Effect/ComputeEffect.h"

NS_DORA_BEGIN

ComputeEffect::ComputeEffect() { }

void ComputeEffect::add(NotNull<ComputePass, 1> pass) {
    _passes.push_back(pass);
}

ComputePass* ComputeEffect::get(size_t index) const {
    AssertUnless(index < _passes.size(), "compute effect pass index out of range");
    return _passes[index];
}

void ComputeEffect::clear() {
    _passes.clear();
}

const RefVector<ComputePass>& ComputeEffect::getPasses() const noexcept {
    return _passes;
}

void ComputeEffect::set(String name, float var) {
    for (auto& pass : _passes) {
        pass->set(name, var);
    }
}

void ComputeEffect::set(String name, const Vec4& var) {
    for (auto& pass : _passes) {
        pass->set(name, var);
    }
}

void ComputeEffect::set(String name, const Matrix& var) {
    for (auto& pass : _passes) {
        pass->set(name, var);
    }
}

void ComputeEffect::dispatch(bgfx::ViewId viewId, uint32_t x, uint32_t y, uint32_t z) {
    for (auto& pass : _passes) {
        pass->dispatch(viewId, x, y, z);
    }
}

NS_DORA_END
```

### 5.3 典型使用场景

#### 场景 1：GPU 粒子系统

```cpp
class ParticleSystem : public Node {
public:
    ParticleSystem() {
        // 创建 compute effect
        _computeEffect = ComputeEffect::create();
        auto updatePass = ComputePass::create("particle_update");
        _computeEffect->add(updatePass);
        
        // 创建粒子纹理
        _particleTexture = Texture2D::create(1024, 1024, 
            bgfx::TextureFormat::RGBA32F, BGFX_TEXTURE_COMPUTE_WRITE);
        
        // 创建显示 sprite
        _sprite = Sprite::create(_particleTexture);
        addChild(_sprite);
    }
    
    void update(float dt) override {
        // 更新参数
        _computeEffect->set("u_deltaTime", dt);
        _computeEffect->set("u_time", _time);
        _time += dt;
    }
    
    void render() override {
        // 1. dispatch compute (前置 view)
        SharedView.pushFront("particle_update", [this]() {
            // 绑定 particle buffer
            _computeEffect->get(0)->setImage(0, _particleBuffer, 
                                            ComputeAccess::ReadWrite);
            // dispatch
            _computeEffect->dispatch(SharedView.getId(), 
                                    _particleCount / 256, 1, 1);
        });
        
        // 2. render sprite (主 view)
        _sprite->visit();
        
        Node::render();
    }

private:
    Ref<ComputeEffect> _computeEffect;
    Ref<Texture2D> _particleTexture;
    Ref<Sprite> _sprite;
    float _time = 0.0f;
};
```

#### 场景 2：程序化纹理生成

```cpp
class ProceduralTexture : public Node {
public:
    ProceduralTexture() {
        _computeEffect = ComputeEffect::create();
        
        // Pass 1: 生成噪声
        auto noisePass = ComputePass::create("noise_gen");
        _computeEffect->add(noisePass);
        
        // Pass 2: 应用滤镜
        auto filterPass = ComputePass::create("filter");
        _computeEffect->add(filterPass);
        
        // 输出纹理
        _outputTexture = Texture2D::create(512, 512,
            bgfx::TextureFormat::RGBA8, BGFX_TEXTURE_COMPUTE_WRITE);
        
        _sprite = Sprite::create(_outputTexture);
        addChild(_sprite);
    }
    
    void render() override {
        SharedView.pushFront("procedural_gen", [this]() {
            // Pass 1: 生成噪声
            _computeEffect->get(0)->setImage(0, _outputTexture, 
                                            ComputeAccess::Write);
            _computeEffect->get(0)->dispatch(SharedView.getId(), 
                                            512/16, 512/16, 1);
            
            // Pass 2: 应用滤镜 (依赖 Pass 1 的输出)
            _computeEffect->get(1)->setImage(0, _outputTexture, 
                                            ComputeAccess::ReadWrite);
            _computeEffect->get(1)->dispatch(SharedView.getId(), 
                                            512/16, 512/16, 1);
        });
        
        _sprite->visit();
        Node::render();
    }
    
private:
    Ref<ComputeEffect> _computeEffect;
    Ref<Texture2D> _outputTexture;
    Ref<Sprite> _sprite;
};
```

#### 场景 3：动态变形效果

```cpp
class DeformableSprite : public Sprite {
public:
    DeformableSprite(Texture2D* texture) : Sprite(texture) {
        // 创建变形 compute
        _deformEffect = ComputeEffect::create();
        auto deformPass = ComputePass::create("vertex_deform");
        _deformEffect->add(deformPass);
        
        // 创建变形后的纹理
        _deformedTexture = Texture2D::create(
            texture->getInfo().width, texture->getInfo().height,
            bgfx::TextureFormat::RGBA8, BGFX_TEXTURE_COMPUTE_WRITE);
    }
    
    void render() override {
        // 1. compute deform
        SharedView.pushFront("deform", [this]() {
            // 原始纹理作为输入
            _deformEffect->get(0)->setImage(0, getTexture(), ComputeAccess::Read);
            // 变形纹理作为输出
            _deformEffect->get(0)->setImage(1, _deformedTexture, ComputeAccess::Write);
            
            _deformEffect->set("u_time", _time);
            _deformEffect->set("u_intensity", _intensity);
            _deformEffect->dispatch(SharedView.getId(), 
                                   _deformedTexture->getWidth()/16,
                                   _deformedTexture->getHeight()/16, 1);
        });
        
        // 2. 使用变形后的纹理渲染
        setTexture(_deformedTexture);
        Sprite::render();
    }
    
    void update(float dt) override {
        _time += dt;
    }
    
    PROPERTY(float, Intensity);

private:
    Ref<ComputeEffect> _deformEffect;
    Ref<Texture2D> _deformedTexture;
    float _time = 0.0f;
};
```

---

## 6. 实施建议

### 6.1 分阶段实施

**Phase 1：基础 ComputeEffect**
- 实现 `ComputeEffect` 类
- 添加 Lua/WASM 绑定
- 文档和示例

**Phase 2：高级功能**
- 多 pass 链式执行
- 资源管理辅助
- 调试工具

**Phase 3：优化**
- 自动 view ID 分配
- 批处理优化
- 性能分析工具

### 6.2 与现有系统的协调

1. **View 系统**：
   - ComputeEffect 通过 `SharedView.pushFront/pushBack` 控制顺序
   - 保持现有的 view 管理机制

2. **资源管理**：
   - ComputePass 已实现 texture 生命周期管理
   - ComputeEffect 继承此机制

3. **渲染流程**：
   - 不修改 `SpriteRenderer` 的批处理逻辑
   - compute 在独立 view 执行，不影响批处理

---

## 7. 结论

### 7.1 可行性评估

| 方案 | 语义 | 技术可行性 | 复杂度 | 推荐度 |
|------|------|-----------|--------|--------|
| Effect 直接集成 ComputePass | ❌ 冲突 | 🟡 可行 | 🔴 高 | ⭐⭐ |
| **独立 ComputeEffect** | ✅ 清晰 | ✅ 简单 | 🟢 低 | ⭐⭐⭐⭐⭐ |
| ComputeNode | ✅ 清晰 | ✅ 简单 | 🟢 低 | ⭐⭐⭐⭐ |
| 组合模式 | 🟡 可接受 | ✅ 简单 | 🟡 中 | ⭐⭐⭐ |

### 7.2 最终建议

**推荐实施：方案 2（独立 ComputeEffect）**

**理由**：
1. ✅ **语义清晰**：Effect 用于渲染，ComputeEffect 用于计算
2. ✅ **架构干净**：不修改现有 Effect 系统
3. ✅ **易于使用**：API 简单直观
4. ✅ **符合最佳实践**：类似 Unity/Unreal 的设计
5. ✅ **扩展性好**：可以独立演进

**不推荐**：
- ❌ 在 Effect 中直接集成 ComputePass（语义冲突，复杂度高）
- ❌ 创建 "混合 Effect"（破坏现有优化）

### 7.3 下一步行动

1. **实现 ComputeEffect 类**（预计 1-2 天）
2. **编写单元测试**（预计 1 天）
3. **添加 Lua/WASM 绑定**（预计 0.5 天）
4. **编写示例代码**（预计 1 天）
5. **撰写文档**（预计 0.5 天）

**总工作量估计**：4-5 天

---

## 8. 附录：其他引擎对比

### Unity
```csharp
// ComputeShader 独立于 Material
ComputeShader computeShader;
Material material;

// compute 独立执行
computeShader.Dispatch(kernelIndex, threadGroupsX, threadGroupsY, threadGroupsZ);

// material 用于渲染
material.SetTexture("_MainTex", computeOutput);
Graphics.DrawMesh(mesh, transform, material, 0);
```

### Unreal Engine
```cpp
// Compute shader 通过 RDG 管理
FRDGBuilder GraphBuilder(CommandList);

auto ComputePass = GraphBuilder.CreateComputePass(...);
ComputePass->Dispatch(...);

// Material 用于渲染
GraphBuilder.CreateRenderPass(...);
```

### Godot
```gdscript
# ComputeShader 是独立资源
var compute_shader = preload("res://compute.glsl")
var compute_list = RD.compute_list_begin()
RD.compute_list_bind_compute_pipeline(compute_list, pipeline)
RD.compute_list_dispatch(compute_list, x, y, z)
RD.compute_list_end()

# ShaderMaterial 用于渲染
var material = ShaderMaterial.new()
material.set_shader_parameter("texture", compute_output)
```

**共同点**：
- ✅ ComputeShader 都是独立资源
- ✅ 不直接集成在 Material/Shader 中
- ✅ 通过显式 dispatch 控制执行
- ✅ 输出可以连接到渲染管线

**Dora 应该遵循相同的模式。**

---

**报告完成日期**：2026-03-12
**作者**：AI Assistant
**审核状态**：待审核
