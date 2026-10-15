# ParticleEditor Web IDE 设计

## 目标

在 Dora SSR Web IDE 中实现一个内置粒子系统编辑器，使用户可以直接新建、打开、编辑、预览和保存引擎现有 `.par` 粒子资源。整体接入方式参考已经落地的 BodyEditor：浏览器端维护结构化 TypeScript 编辑模型，使用现有 Web IDE tab、读写、dirty/save、undo/redo 和资源路径机制；保存时写回引擎 `ParticleCache` 当前能直接加载的 XML `.par` 格式。

预览实现不调用引擎进程截图，也不通过临时运行工程绕一圈。编辑器内置一个 WebGL + canvas 粒子预览 runtime，把 `Source/Node/Particle.cpp` 里的 `ParticleNode` 发射、更新、quad 生成和混合逻辑用 TypeScript 一比一移植。这样编辑时参数变化可以即时反馈，也避免预览依赖当前游戏工程是否能运行。

## 参考来源

当前 Web IDE 和 BodyEditor 接入点：

- `Tools/dora-dora/src/App.tsx`
- `Tools/dora-dora/src/Service.ts`
- `Tools/dora-dora/src/BodyEditor/BodyEditor.tsx`
- `Tools/dora-dora/src/BodyEditor/BodyEditorCanvas.tsx`
- `Tools/dora-dora/src/BodyEditor/BodyDocument.ts`
- `Tools/dora-dora/src/BodyEditor/BodyLuaJsonFormat.ts`
- `Tools/dora-dora/src/BodyEditor/BodyRender.ts`
- `Tools/dora-dora/src/BodyEditor/BodyPhysicsRuntime.ts`
- `Assets/Script/Dev/WebServer.yue`

当前粒子运行时：

- `Source/Node/Particle.h`
- `Source/Node/Particle.cpp`
- `Source/Cache/ParticleCache.h`
- `Source/Cache/ParticleCache.cpp`
- `Source/Const/XmlTag.h`
- `Source/Common/Utils.cpp`
- `Source/Basic/Application.cpp`

旧 Dorothy 参考编辑器：

- `Docs/design/Dorothy/project/Resources/EffectEditor/Script/oEditor.lua`
- `Docs/design/Dorothy/project/Resources/EffectEditor/Script/oViewArea.lua`
- `Docs/design/Dorothy/project/Resources/EffectEditor/Script/oSettingPanel.lua`
- `Docs/design/Dorothy/project/Resources/EffectEditor/Script/oEditControl.lua`
- `Docs/design/Dorothy/project/Resources/EffectEditor/Script/oTemplateChooser.lua`
- `Docs/design/Dorothy/project/Resources/EffectEditor/Script/oSpriteChooser.lua`
- `Docs/design/Dorothy/project/Resources/EffectEditor/Script/oClipChooser.lua`

旧 EffectEditor 同时处理 `.par` 和 `.frame`，且旧 `.par` 写出的是 plist 风格字段。新版只做当前 Dora 引擎内置 `ParticleNode` 使用的 XML `.par`，不兼容旧 plist 作为首版目标。若后续需要导入旧文件，可做一次性 import，而不是把旧格式混入主保存路径。

## 现状结论

BodyEditor 的实际架构可以直接复用为 ParticleEditor 的骨架：

- React 宿主负责 tab 生命周期、尺寸、读写、诊断、undo/redo 和 `onChange()`。
- 编辑期数据存在前端 Document 里，UI 修改只操作 Document。
- 服务端只在必须执行受控脚本时参与；粒子 XML 不需要执行脚本，首版可以完全前端解析。
- 预览 runtime 是 Document 的派生缓存，不把运行时对象写回 Document。
- 保存走 Web IDE 现有 dirty/save 链路，编辑器不直接绕过 tab 写文件。

粒子运行时的关键语义集中在 `ParticleDef` 和 `ParticleNode`：

- `ParticleDef` 保存所有参数，`toXml()` 写出单字母 XML tag。
- `ParticleCache::Parser` 读取同一套 tag，所有数值在 `A` 属性里。
- 发射器有两种模式：`Gravity` 和 `Radius`。
- `ParticleNode::visit()` 负责按 `Scheduler` delta 发射、更新、删除死亡粒子并生成 `SpriteQuad`。
- `ParticleNode::render()` 把 quad 乘以 view-projection 后，用 `SpriteRenderer`、纹理和 `BlendFunc` 提交。
- 默认纹理是内置的 `__defaultParticleTexture.png`，当 `textureName` 为空、资源不存在或加载失败时使用。

## 文件格式

新版编辑器的持久格式就是引擎当前 XML：

```xml
<A>
  <B A="90"/>
  <C A="360"/>
  ...
</A>
```

tag 定义来自 `Xml::Particle`：

| tag | 字段 | 类型 |
| --- | --- | --- |
| `B` | `angle` | float |
| `C` | `angleVariance` | float |
| `D` | `blendFuncDestination` | uint32 |
| `E` | `blendFuncSource` | uint32 |
| `F` | `duration` | float |
| `G` | `emissionRate` | float |
| `H` | `finishColor` | vec4 |
| `I` | `finishColorVariance` | vec4 |
| `J` | `rotationStart` | float |
| `K` | `rotationStartVariance` | float |
| `L` | `rotationEnd` | float |
| `M` | `rotationEndVariance` | float |
| `N` | `finishParticleSize` | float |
| `O` | `finishParticleSizeVariance` | float |
| `P` | `maxParticles` | uint32 |
| `Q` | `particleLifespan` | float |
| `R` | `particleLifespanVariance` | float |
| `S` | `startPosition` | vec2 |
| `T` | `startPositionVariance` | vec2 |
| `U` | `startColor` | vec4 |
| `V` | `startColorVariance` | vec4 |
| `W` | `startParticleSize` | float |
| `X` | `startParticleSizeVariance` | float |
| `Y` | `textureName` | string |
| `Z` | `textureRect` | rect |
| `a` | `emitterMode` | enum, `0 = Gravity`, `1 = Radius` |
| `b` | `rotationIsDir` | bool, Gravity only |
| `c` | `gravity` | vec2, Gravity only |
| `d` | `speed` | float, Gravity only |
| `e` | `speedVariance` | float, Gravity only |
| `f` | `radialAcceleration` | float, Gravity only |
| `g` | `radialAccelVariance` | float, Gravity only |
| `h` | `tangentialAcceleration` | float, Gravity only |
| `i` | `tangentialAccelVariance` | float, Gravity only |
| `j` | `startRadius` | float, Radius only |
| `k` | `startRadiusVariance` | float, Radius only |
| `l` | `finishRadius` | float, Radius only |
| `m` | `finishRadiusVariance` | float, Radius only |
| `n` | `rotatePerSecond` | float, Radius only |
| `o` | `rotatePerSecondVariance` | float, Radius only |

序列化必须按 `ParticleDef::toXml()` 的顺序输出，便于 diff 稳定，也便于和 C++ 行为对照。解析时允许字段缺失，但需要补齐和 `ParticleDef::fire()` 一致的默认模板，不能把缺失字段保存成任意新默认值。

需要注意一个运行时细节：`ParticleCache::Parser` 当前对部分 gravity/radius float 字段使用 `std::atoi()`，会截断小数。设计上首版应忠实显示和保存用户输入的小数，但预览 runtime 要提供“引擎兼容模式”，按当前 parser 行为对这些字段取整后再模拟；否则编辑器预览会比引擎实际加载结果更精细，形成误导。后续若修正引擎 parser，再同步调整兼容层。

## 数据模型

建议新增 `Tools/dora-dora/src/ParticleEditor/ParticleDocument.ts`：

```ts
export type ParticleEmitterMode = "gravity" | "radius";

export type ParticleDocument = {
  version: 1;
  source: "par";
  fields: ParticleFields;
  dirty: boolean;
};

export type ParticleFields = {
  angle: number;
  angleVariance: number;
  blendFuncDestination: number;
  blendFuncSource: number;
  duration: number;
  emissionRate: number;
  finishColor: ParticleVec4;
  finishColorVariance: ParticleVec4;
  rotationStart: number;
  rotationStartVariance: number;
  rotationEnd: number;
  rotationEndVariance: number;
  finishParticleSize: number;
  finishParticleSizeVariance: number;
  maxParticles: number;
  particleLifespan: number;
  particleLifespanVariance: number;
  startPosition: ParticleVec2;
  startPositionVariance: ParticleVec2;
  startColor: ParticleVec4;
  startColorVariance: ParticleVec4;
  startParticleSize: number;
  startParticleSizeVariance: number;
  textureName: string;
  textureRect: ParticleRect;
  emitterMode: ParticleEmitterMode;
  gravity: ParticleGravityFields;
  radius: ParticleRadiusFields;
};
```

内部模型使用语义化字段名，保存时再映射到单字母 XML。这样属性面板、验证和 WebGL runtime 都不需要直接理解压缩 tag。

默认模板建议提供三类：

- `fire`：完全对齐 `ParticleDef::fire()`，作为新建 `.par` 的默认值。
- `blankGravity`：最小可见 gravity 粒子，用于测试和用户从零开始调参。
- `blankRadius`：最小可见 radius 粒子，便于切换模式时保留已有通用参数。

## Web IDE 接入

### 文件识别

在 `App.tsx` 中识别 `.par`：

- 默认打开 ParticleEditor。
- 提供“以文本打开”回退，行为参考 BodyEditor 的 `.b.lua` 文本回退。
- `.par` 不进入 Monaco XML，除非用户显式切换文本。
- `previewFileExts` 应包含 `.par`，当外部 `UpdateFile` 修改已打开 `.par` 时触发 `previewVersion`，编辑器按当前 tab 是否 dirty 决定重载或提示冲突。

### 新建入口

在 `NewFileDialog.tsx` 增加 Dora Particle 资源：

- 默认文件名后缀 `.par`。
- 新文件内容由 `ParticleDocument` 的 `fire` 模板写出。
- 创建后自动打开 ParticleEditor。

### 资源路径

纹理加载使用和 BodyEditor face 预览同类的规则：

- `textureName` 为空或资源不存在时使用浏览器端内置默认粒子纹理。
- 普通图片路径相对当前项目资源根解析。
- 如果 `textureName` 是 `.clip` 引用，沿用 `ActionEditor/ActionClip.ts` 解析 `.clip`，按 `SharedClipCache.loadTexture()` 的语义使用 atlas 纹理和 clip rect。
- `textureRect` 非零时裁剪普通纹理；如果 `.clip` 已提供 rect，优先使用 `.clip` rect，并在 UI 中显示当前实际 UV 来源。
- 所有 fetch URL 使用 Web IDE 现有 served-resource 转换和 cache-busting，避免外部更新图片后已打开预览不刷新。

## UI 设计

ParticleEditor 可以比 BodyEditor 更轻，但仍保持同一类工作流：

- 顶部工具栏：播放/暂停、重播、停止发射、单步、固定时间步、随机种子、缩放、回原点、纹理选择。
- 中央视图：WebGL 预览 canvas，显示坐标轴、发射器位置、发射范围、粒子数量、时间和 FPS。
- 右侧属性面板：按分组展示通用参数、颜色、尺寸、旋转、纹理、发射器模式参数。
- 底部可选曲线/时间面板：首版不做曲线资源，只显示生命周期内 size/color/rotation 线性变化预览。
- 诊断条：解析错误、资源缺失、参数被夹取、maxParticles 过高、兼容模式取整等信息。

属性分组：

- General：`duration`、`emissionRate`、`maxParticles`、`particleLifespan`、`particleLifespanVariance`。
- Emission：`angle`、`angleVariance`、`startPosition`、`startPositionVariance`。
- Color：`startColor`、`startColorVariance`、`finishColor`、`finishColorVariance`。
- Size：`startParticleSize`、`startParticleSizeVariance`、`finishParticleSize`、`finishParticleSizeVariance`。
- Rotation：`rotationStart`、`rotationStartVariance`、`rotationEnd`、`rotationEndVariance`、`rotationIsDir`。
- Texture：`textureName`、`textureRect`、`blendFuncSource`、`blendFuncDestination`、`depthWrite` 预览开关。
- Gravity Mode：`gravity`、`speed`、`speedVariance`、`radialAcceleration`、`radialAccelVariance`、`tangentialAcceleration`、`tangentialAccelVariance`。
- Radius Mode：`startRadius`、`startRadiusVariance`、`finishRadius`、`finishRadiusVariance`、`rotatePerSecond`、`rotatePerSecondVariance`。

交互控件：

- 数值字段使用 number input + slider/stepper，范围由字段语义约束。
- 颜色字段用 RGBA swatch + 数值输入，方差显示为 0 到 1。
- 布尔字段用 toggle。
- `emitterMode` 用 segmented control。
- `blendFunc` 用下拉菜单，显示常用值名，同时保留数字值。
- `startPosition` 可直接在预览画布拖拽发射器中心。
- `startPositionVariance` 在画布显示矩形范围，可拖拽边缘调整。
- Radius 模式在画布显示 start/end radius 圆，可拖拽调整半径。

## WebGL 预览 Runtime

新增 `ParticlePreviewRuntime.ts` 和 `ParticleWebGLRenderer.ts`。职责分开：

- `ParticlePreviewRuntime`：只做数据、随机、发射、更新、quad 生成。
- `ParticleWebGLRenderer`：只做纹理、shader、buffer、blend、viewport 和 draw。
- `ParticleEditorCanvas.tsx`：负责 requestAnimationFrame、输入、UI overlay 和状态同步。

### 发射逻辑对齐

按 `ParticleNode::start()`：

- `active = true`
- `emitting = true`
- `elapsed = 0`
- 清空现有粒子
- `emitCounter` 建议同步清零，虽然 C++ `start()` 当前只清 `_particles` 和 `_elapsed`，不清 `_emitCounter`；编辑器重播时保留 emitCounter 会让用户误以为首帧不稳定。这里应作为待确认点：若要严格复刻 C++，提供 strict 模式；默认编辑器模式以可重复预览为优先。

按 `ParticleNode::visit()`：

- `deltaTime = min(frameDelta, clamp)`，编辑器默认固定 `1 / 60` 可复现，实时模式用 RAF delta。
- 当 active 且 `emissionRate > 0` 时，`rate = 1 / emissionRate`。
- 粒子数量小于 `maxParticles` 时累加 `_emitCounter`。
- `while count < maxParticles && emitCounter > rate` 时调用 `addParticle()`，并减去 `rate`。
- `elapsed += deltaTime`。
- `duration >= 0 && duration < elapsed` 时停止发射。

### 随机数

引擎 `Math::rand1to1()` 来自 `Application` 的 `std::mt19937`，返回 `2 * ((getRand() - min) / max) - 1`。浏览器要实现一个兼容 MT19937：

- `ParticleRandom.ts` 实现 mt19937，默认 seed 从 UI 的随机种子字段来。
- preview 的每次 restart 用同一个 seed，保证调参时画面可复现。
- 提供“随机种子跟随时间”开关，用来观察真实随机变化。
- 如果后续引擎暴露 seed 给粒子资源，可再保存；首版 seed 是编辑器会话态，不写入 `.par`。

### 粒子初始化

按 `ParticleNode::addParticle()`：

- `timeToLive = lifespan + lifespanVariance * rand1to1()`，最小 `FLT_EPSILON`。
- `pos = worldPos + startPosition + startPositionVariance * [rand1to1(), rand1to1()]`。
- start/end color 每个通道加 variance 后 clamp 到 `[0, 1]`。
- `deltaColor = (end - start) / ttl`。
- start size 加 variance 后 clamp 到 `>= 0`。
- `finishParticleSize < 0` 时 `deltaSize = 0`，否则用 finish size variance 算 `(end - start) / ttl`。
- rotation start/end 同理线性插值。
- angle 使用 `toRad(angle + angleVariance * rand1to1())`。
- Gravity 模式：`dir = [cos(angle), sin(angle)] * speed`，并写入 radial/tangential accel；`rotationIsDir` 时 rotation 等于 `-toDeg(dir.angle())`。
- Radius 模式：初始化 radius、deltaRadius、angle 和 `degreesPerSecond = toRad(rotatePerSecond + variance * rand1to1())`。

### 粒子更新

Gravity 模式按 C++：

- `radial = p.pos`，非零时 normalize。
- `tangential = radial`。
- `radial *= radialAccel`。
- 切线向量做 `x = -y, y = oldX`，再乘 `tangentialAccel`。
- `tmp = radial + tangential + gravity`。
- `dir += tmp * deltaTime`。
- `pos += dir * deltaTime * scale`。

这里有一个必须标出的差异风险：C++ 使用的是粒子的世界坐标 `p.pos` 计算 radial，而不是相对发射器原点的局部坐标。WebGL runtime 必须照做，不要按常见粒子系统写成 `p.pos - sourcePosition`。

Radius 模式按 C++：

- `angle += degreesPerSecond * deltaTime`。
- `radius += deltaRadius * deltaTime * scale`。
- `pos.x = -cos(angle) * radius`。
- `pos.y = -sin(angle) * radius`。

通用更新：

- `color += deltaColor * deltaTime`。
- `size += deltaSize * deltaTime * scale`，最小 0。
- `rotation += deltaRotation * deltaTime`。
- ttl 到期时用最后一个粒子覆盖当前粒子再 `pop`，保持和 C++ 相同的删除顺序。
- 粒子清空时 `emitting = false`，触发 `Finished` 预览事件。

### Quad 和渲染

`addQuad()` 语义：

- 使用当前纹理 UV：`texLeft`、`texTop`、`texRight`、`texBottom`。
- quad 顶点顺序与 `SpriteQuad` 保持一致：rb、lb、lt、rt。
- color 转 ABGR 在 WebGL 中可直接传 RGBA float，但 shader 输出必须和引擎 alpha 混合结果一致。
- `halfSize = particle.size * 0.5 * scale`。
- rotation 非零时按 `-toRad(rotation)` 旋转四个顶点。
- `angleX/angleY` 的 3D 父级旋转首版可以不在 UI 暴露；runtime 保留实现入口，默认 0。

WebGL 渲染：

- 使用一个最小 textured quad shader。
- 每帧动态更新 interleaved buffer：position vec2/vec3、color vec4、uv vec2。
- draw mode 使用 triangles，每个粒子 6 indices；也可以在 CPU 展开 6 顶点，避免 index buffer 复杂度。
- canvas 坐标使用和 BodyEditor 一样的 editor viewport：世界 Y 向上，屏幕 Y 向下。
- 纹理采样使用 premultiply 策略要和浏览器上传保持一致。默认应设置 `UNPACK_PREMULTIPLY_ALPHA_WEBGL = false`，由 blend func 决定结果。
- 根据 `blendFuncSource` / `blendFuncDestination` 映射 WebGL blend factor。至少支持 `SrcAlpha`、`OneMinusSrcAlpha`、`One`、`Zero`、`DstColor`、`OneMinusDstColor`、`DstAlpha`、`OneMinusDstAlpha`。
- `DepthWrite` 只是 `ParticleNode` 运行时属性，不在 `.par` 内。编辑器可提供预览开关，但不保存。

### 验证策略

预览 runtime 需要可测试，不只靠肉眼：

- 纯函数测试：解析 `.par`、写回 `.par`、默认 `fire` 模板 round-trip。
- simulation fixture：固定 seed、固定 delta、固定 document，跑 N 帧后断言粒子数量、前几个粒子的 pos/color/size/rotation。
- C++ 对照：可以新增一个轻量 test 或 debug route，输出同一 seed 和参数下 N 帧 particle snapshot。首版若不做 C++ route，至少把从 `Particle.cpp` 手动翻译的关键公式用测试锁住。
- browser 验证：打开 Web IDE `.par` tab，Playwright 截图和 canvas pixel check 确认非空、纹理加载、重启后 deterministic。

## 模块划分

建议新增目录 `Tools/dora-dora/src/ParticleEditor/`：

- `ParticleDocument.ts`：类型、默认值、字段定义、字段约束。
- `ParticleXmlFormat.ts`：XML parse/write、tag 映射、诊断。
- `ParticleEditorState.ts`：clone、update field、undo/redo 纯函数。
- `ParticleResource.ts`：纹理路径、`.clip` 解析、默认粒子纹理、cache busting。
- `ParticleRandom.ts`：mt19937 和 `rand1to1()`。
- `ParticlePreviewRuntime.ts`：发射、更新、quad 生成。
- `ParticleWebGLRenderer.ts`：shader、buffer、texture、blend、draw。
- `ParticleRender.ts`：viewport、坐标轴、发射器 gizmo、范围 overlay、hit test。
- `ParticleEditor.tsx`：React 宿主，读写、诊断、资源加载、undo/redo。
- `ParticleEditorCanvas.tsx`：canvas、工具栏、属性面板、预览 controls。
- `index.ts`：对外导出。

是否复用 ImGui：

- 如果目标是和 ActionEditor 的全 canvas 风格完全一致，可以复用 `ActionImGuiRuntime` 抽出的通用 ImGui runtime。
- 如果目标是更快落地并贴近当前 BodyEditor，首版可以沿用 BodyEditor 的 React + MUI 属性面板、canvas 预览结构。
- 本设计建议首版按 BodyEditor 做，因为粒子属性很多且主要是表单/滑条，DOM 表单开发和可访问性成本更低；WebGL 预览仍在 canvas 内完成。

## 参数校验

校验结果分为 error 和 warning：

- error：XML 无法解析、根节点不是 `A`、数值不可解析、颜色/向量维度错误。
- warning：`maxParticles <= 0`、`emissionRate <= 0`、`particleLifespan <= 0`、`textureName` 找不到、`textureRect` 超出纹理、字段因引擎兼容模式被取整、blend factor 未知。
- 自动夹取：颜色通道显示 clamp 到 `[0, 1]` 的预览结果，但保留原始输入并提示。
- 性能保护：`maxParticles` UI 上限默认 5000；超过时允许保存，但预览用 capped count，并提示“预览已限制粒子数量”。

## 落地计划

| ID | 模块 | 任务 | 验收 |
| --- | --- | --- | --- |
| PE-01 | 数据格式 | 实现 `ParticleDocument`、默认模板、XML parse/write | `ParticleDef::fire()` 等价模板可 round-trip 成 `.par` |
| PE-02 | Web IDE 接入 | `.par` 默认打开 ParticleEditor，新建入口写默认模板 | 新建/打开/保存 `.par` 走现有 tab dirty/save |
| PE-03 | 属性面板 | 完成通用、颜色、尺寸、旋转、纹理、Gravity、Radius 字段编辑 | 修改字段即时写回 Document，可 undo/redo |
| PE-04 | 资源加载 | 支持图片、`.clip` atlas、默认纹理和 cache-busting | 纹理修改或 UpdateFile 后已打开预览刷新 |
| PE-05 | Runtime | 移植 `ParticleNode::addParticle()` 和 `visit()` | 固定 seed snapshot 测试稳定 |
| PE-06 | WebGL | 实现 textured quad shader、blend func、viewport | 预览 canvas 可播放 fire 模板，重启确定性 |
| PE-07 | 画布交互 | pan/zoom/origin、拖拽发射器、拖拽 variance/radius gizmo | 画布操作更新对应字段，可撤销 |
| PE-08 | 诊断和兼容 | parser 诊断、引擎兼容模式、性能限制提示 | 典型坏文件和资源缺失有明确用户反馈 |
| PE-09 | 验证 | 增加 XML、runtime、WebGL smoke 测试 | `pnpm lint` 和粒子 verifier 通过 |

## 风险和决策

- **预览一致性优先级**：粒子效果有随机性，不能追求每次和正在运行的引擎实例逐像素相同；应追求同一 seed、同一输入、同一时间步下公式一致。
- **parser 取整差异**：当前 C++ parser 对部分字段用 `atoi()`，设计必须暴露兼容提示。不要让编辑器 silently preview 小数而引擎实际加载整数。
- **旧 plist `.par`**：旧 Dorothy EffectEditor 的 plist 格式不作为主格式。导入能力可以后置。
- **CPU 模拟 vs GPU 模拟**：首版 CPU 模拟 + WebGL 绘制，最贴近当前 `ParticleNode`。不要引入 GPU particle 计算，否则很快偏离 C++ runtime。
- **默认纹理**：浏览器端需要一份等价默认粒子纹理。可以把 C++ 内置 PNG 提取为前端静态 base64 或生成同尺寸资源，但必须和引擎视觉接近。
- **保存字段顺序**：必须稳定按 `toXml()` 顺序输出，不根据 UI 分组排序。

## 首版范围

首版必须完成：

- `.par` 直接打开、编辑、保存。
- `fire` 默认模板新建。
- Gravity 和 Radius 两种模式完整参数。
- WebGL 预览，支持默认纹理、图片纹理、`.clip` 纹理。
- 固定 seed 和重播。
- 基础诊断和 undo/redo。

首版暂不做：

- 旧 plist `.par` 自动导入。
- 多发射器组合资源。
- 曲线/easing 粒子参数。
- GPU 计算粒子。
- 把编辑器 seed 写入 `.par`。
- 和 Effekseer 资源互转。

