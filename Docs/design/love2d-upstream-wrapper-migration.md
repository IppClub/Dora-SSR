# Dora Love2D 上游 Wrapper 复用与迁移计划

本文记录 Dora Love2D 兼容层从“Dora 自写 Lua binding + Dora backend”逐步收敛为“Love 11.5 上游 Lua wrapper + 按 Lua State 隔离的模块上下文 + Dora backend”的设计方案、实施边界和分阶段验收计划。

本文是 [Dora Love2D 整合设计](./love2d-integration.md) 的增量设计，不改变以下既有决策：全引擎只链接 Lua 5.5、每个 `LoveNode` 拥有独立 `lua_State`、Dora 是唯一应用主循环所有者、文件读取经过 `Content`、音频进入 SoLoud、渲染进入 Dora/bgfx、Love 状态不公开 Dora API。

最后更新：2026-08-26

## 背景与问题

迁移前的实现只直接编译 Love 11.5 的 `Object`、`Type`、`Reference`、`Module`、Proxy 和 common runtime。公开 userdata 的引用计数、弱 registry、`release()`、`type()` 和 `typeOf()` 已复用上游机制，但绝大部分模块函数、方法注册、参数解析、默认值和错误处理由 `LoveRuntime.cpp` 重新实现。下文“当前调用链”保留为迁移基线记录；实际完成情况以后续 W0–W7 跟踪表为准。

迁移前调用链为：

```text
Love Lua 5.5 state
→ Dora LoveRuntime Lua binding
→ Dora GraphicsBackend / AudioBackend / FilesystemBackend / ...
→ LoveNode
→ bgfx / SoLoud / Content / SDL host / Dora physics
```

这套基线实现已经具备多实例和跨平台运行能力，但存在以下长期问题：

- 上游新增或已有的重载容易在 Dora binding 中遗漏，例如 `love.graphics.draw(..., Transform)`。
- 参数默认值、类型错误、返回值数量和弃用别名需要人工逐项复制。
- 上游 wrapper、Dora runtime 和英中 TypeScript/Teal 定义之间存在重复事实源。
- `LoveRuntime.cpp` 同时承担 Lua 状态、对象模型、模块注册、API 语义和 backend 调度，修改影响面过大。
- 当前保留的 `wrap_*.cpp` 主要用于 API 对账，并未进入实际构建，无法直接提供运行时兼容收益。

现有实现不是错误的临时桩，不能通过一次整体替换废弃。迁移必须保持已验证的游戏兼容性和 Dora backend，并允许按模块回退。

## 目标

- 尽量直接编译 Love 11.5 原版 Lua wrapper 和平台无关上层实现。
- 让参数解析、标准重载、默认值、枚举和对象类型检查以 Love 上游代码为主要事实源。
- 将 Love 原版进程级 `Module` singleton 改造成按 `lua_State` 隔离的模块上下文。
- 保留 LoveNode 已有的渲染、音频、文件、输入、窗口、线程和物理 backend。
- 最终让 `LoveNode` 只承担宿主节点、平台设施和渲染目标，不再复制 `love.*` Lua API 语义。
- 每个迁移阶段都能独立编译、测试、比较和回退，不要求一次完成全部模块。

## 非目标

- 不恢复 Love 自带的 LuaJIT、Lua 5.1 ABI 或原生 Lua 模块加载。
- 不恢复 Love 可执行程序主循环、SDL window、swapchain 或 `present` 所有权。
- 不把 Love 原版 OpenGL renderer 与 Dora bgfx renderer 同时运行。
- 不恢复 OpenAL 等第二套音频设备或混音系统。
- 不允许 Love filesystem 绕过 Dora `Content` 和实例写目录策略。
- 不为了减少 patch 数量而放弃多个 LoveNode 同时运行。
- 不在迁移期间承诺未通过自动化和人工验证的兼容性提升。

## 为什么不能直接编译现有 `wrap_*.cpp`

Love 11.5 wrapper 不是独立的 Lua 参数解析程序库，它直接依赖上游模块实例和对象类型。例如原版 `w_draw` 会取得 `Drawable`、`Texture` 和 `Quad`，再调用全局 `Graphics` 模块实例。原版 `luaopen_love_graphics` 在没有实例时还会直接创建 OpenGL Graphics。

直接接入存在四类阻断：

1. `Module::instances[]` 和模块名称 registry 是进程级全局状态，不能隔离同一线程中的多个 Love Lua State。
2. wrapper 使用 Love 原版 `Image`、`Canvas`、`Mesh`、`Source` 等具体 C++ 类型；当前 Dora userdata 使用 `DoraHandleObject` 和 backend handle。
3. Graphics、Audio、Filesystem、Window 等原版模块会创建或控制自己的平台设施，与 Dora 的 bgfx、SoLoud、Content 和宿主窗口冲突。
4. 当前 vendored tree 是固定清单的裁剪子集，许多 wrapper 依赖的上游类型与实现尚未恢复。

因此目标不是“把 wrapper 文件加入 xmake”这一项构建修改，而是恢复其依赖的上层对象模型，并为模块查找和平台调用建立可隔离的 Dora 接入点。

## 结论：原版 Wrapper 是 API 层，Dora Adapter 是平台层

最终方案不是继续在 `LoveNode` 中重写一套 Love API，也不是把 Love 的整套平台实现原样嵌入 Dora，而是明确拆成三层：

```text
Love 11.5 原版 wrapper
  负责 Lua 函数名、重载、默认值、枚举、类型检查、返回值和对象方法
        ↓
state-local Love module / upstream object
  负责每个 lua_State 的模块状态、Love Object 生命周期和平台无关语义
        ↓
Dora backend adapter
  负责 Content、bgfx、SoLoud、宿主窗口、输入、线程和物理设施
```

这也解释了当前部分接口为什么曾在 `LoveRuntime.cpp` 中重新实现：最初的裁剪版本没有带回 wrapper 所依赖的完整 Love 类型和模块对象，而且原版模块依赖进程级 singleton、OpenGL、OpenAL、PhysFS 和 SDL window 等设施。为了先建立多 LoveNode、Lua 5.5 和 Dora backend 的可运行闭环，只能先用 Dora binding 复刻公开 API。现在 state-local 模块上下文和上游对象基础已经具备，继续手写同一层 API 的收益已经小于兼容性与维护成本，因此应逐模块删除。

各层的代码归属按以下规则固定：

| 内容 | 最终归属 | 是否允许 Dora 重写 |
| --- | --- | --- |
| Lua 参数解析、重载、默认值、错误入口 | Love 原版 `wrap_*.cpp` | 原则上不允许；Lua 5.5 差异以最小 patch 记录 |
| `type`、`typeOf`、Proxy、retain/release、GC | Love `Object`/runtime | 不允许建立第二套生命周期 |
| 平台无关对象状态和算法 | Love 原版对象实现 | 优先原样复用；只修明确缺陷或建立抽象 backend 边界 |
| 模块实例查找 | 当前 `lua_State` 的 registry | 必须修改为 state-local，禁止进程级 singleton |
| 文件和资源访问 | Dora `Content` adapter | 必须由 Dora 实现，禁止 stdio/PhysFS 旁路 |
| GPU、音频设备、窗口和事件 | Dora backend | 必须由 Dora 实现，Love 不取得平台设施所有权 |
| 旧 LoveRuntime 公开方法表 | 仅迁移期存在 | 上游 wrapper 验收后必须删除 |

判断一个接口是否应该留在 `LoveRuntime.cpp` 的标准不是“Dora 能不能实现”，而是它是否属于宿主边界。`graphics.draw` 的重载解析、`newImageData` 的参数组合和 `Quad` 方法属于 Love API 语义，应来自上游 wrapper；把 ImageData 上传为 bgfx texture、用 Content 取得文件、将 Source 接到 SoLoud 属于 Dora backend，应由 adapter 实现。这样才能既复用 Love 的兼容行为，又不引入第二套渲染、音频和操作系统运行时。

## 目标架构

```text
LoveNode A                         LoveNode B
├── Lua State A                    ├── Lua State B
├── LoveModuleContext A            ├── LoveModuleContext B
│   ├── Graphics module A          │   ├── Graphics module B
│   ├── Filesystem module A        │   ├── Filesystem module B
│   └── Audio module A             │   └── Audio module B
├── Upstream wrap_*.cpp            ├── Upstream wrap_*.cpp
├── Upstream Love object types     ├── Upstream Love object types
└── Dora backend adapters          └── Dora backend adapters
             │                                  │
             └──────── shared Dora facilities ─┘
                       bgfx / SoLoud / Content
```

目标调用链为：

```text
Lua call
→ Love 原版 wrapper
→ 当前 lua_State 对应的 Love module/object
→ Dora adapter
→ 现有 LoveNode backend
→ Dora 原生设施
```

### 按 Lua State 隔离模块实例

将 Love 已有的 `REGISTRY_MODULES` 表作为 `LoveModuleContext` 的实际存储，由一个
`lua_State` 独占；不再增加一份与 registry 重复的 C++ 容器。模块同时按公开名称和
`ModuleType` 存入该表，查找不得再以 `Module::instances[ModuleType]` 作为运行时事实源。

建议接口轮廓：

```cpp
template <class T>
T* luax_getmodule(lua_State* state, Module::ModuleType type);
```

wrapper 中的模块获取必须显式使用当前 `lua_State`。不能用 `thread_local` 替代，因为多个 LoveNode 会在 Dora 主线程交替运行；也不能在回调前临时覆盖全局 singleton，因为对象方法、协程、错误路径和后台任务会使恢复逻辑脆弱。

兼容迁移期可以保留原版全局 registry 供未迁移代码使用，但已迁移 wrapper 的测试必须证明不会访问它。最终应删除或编译期禁止 LoveNode 路径使用全局模块实例。

### 上游源码与 Vendor 边界

- `Source/3rdParty/Love/` 保存固定到 Love 11.5 tag/commit 的上游文件。
- 能通过 Dora adapter 解决的问题不得修改上游文件。
- 必须修改上游 wrapper/common runtime 时，直接修改 vendored tree，并以独立、可审阅的 Git 提交记录原因和兼容影响。
- `DORA_SOURCE.md` 记录固定上游版本、恢复的文件边界和刷新命令，不再维护重复 patch 快照。
- `UpstreamSourceSubsetAudit.mjs` 更新为验证“所选完整模块子树”，而不是继续假设只保留 wrapper 文件。
- 不把生成产物、测试结果或平台二进制提交进上游源码目录。

### 对象和资源生命周期

上游 wrapper 复用必须继续使用 Love `Object`、Proxy、`StrongRef` 和弱 registry。不得恢复 Dora 侧手写 `__gc` 或第二套 released-object 表。

迁移后的 GPU、音频和物理对象有两种可选实现：

1. 上游具体类型持有 Dora backend handle，并在析构时调用唯一的 Runtime release 入口。
2. 上游抽象类型由 Dora 子类实现，子类持有 backend handle。

每类对象在进入实施前必须选定一种方式，不允许同一类型同时保留上游资源和 Dora handle 两套所有权。跨 LoveRuntime 传入对象必须继续报错。

### Dora Backend 保留范围

| 能力 | 保留的 Dora 实现 | 上游复用目标 |
| --- | --- | --- |
| Lua 状态和 boot | `LoveRuntime` / `LoveNode` | callback 名称和 root Lua 逻辑 |
| Graphics | bgfx command、RenderTarget、Shader 转译 | wrapper、上层 Graphics 状态和 Drawable 类型 |
| Audio | SoLoud、应用级混音空间 | Source/Queueable 状态和 wrapper |
| Filesystem | `Content`、mount、实例写目录 | File/FileData 接口和 wrapper |
| Image/Font/Sound data | Dora 现有 decoder 或已选三方库 | Data 类型、参数语义和 wrapper |
| Window/Event/Input | Dora/SDL 宿主事件和虚拟窗口 | Love 枚举、事件名和 wrapper |
| Physics | Dora 当前物理 backend | Love 对象层、回调和参数语义 |
| Thread | Dora 线程设施、独立 Lua 5.5 worker | Channel/Thread wrapper 和对象语义 |

## 迁移原则

1. **行为先对账**：迁移前先固定当前通过的 API、错误、像素、音频和生命周期证据。
2. **一次一个模块族**：一个提交不同时迁移 Graphics 和 Audio 等两个高风险模块族。
3. **双路径只用于短期比较**：允许测试构建选择 old/new binding，但发布构建不能长期携带两套公开 API。
4. **backend 不随 wrapper 重写**：除非验收证明 backend 契约不足，否则 wrapper 迁移不得顺便替换已验证的 Dora 渲染或音频实现。
5. **失败可回退**：删除旧 binding 之前，必须有模块级开关或独立提交可恢复。
6. **不以编译代替兼容验收**：每阶段至少包含 Lua 调用、对象生命周期和真实 LoveNode 运行验证。

## 分阶段实施计划

状态使用“未开始、进行中、已完成、阻塞、不适用”。完成状态必须同时具备代码、自动化测试和要求的平台证据。

### W0：建立迁移基线

| ID | 状态 | 任务 | 验收标准 |
| --- | --- | --- | --- |
| W0-01 | 已完成 | 固定当前自写 binding API 与行为快照 | Runtime、API parity、声明和固定 Love 游戏语料结果归档 |
| W0-02 | 已完成 | 统计每个模块当前自写函数、userdata 和 backend 方法 | API parity 直接从上游 method table 抽取方法面，并对已迁移模块断言原版 wrapper 唯一注册、旧 parser 不得回流 |
| W0-03 | 已完成 | 标记上游 wrapper 依赖的源码闭包 | 当前目标模块闭包已进入固定源码清单、xmake 源列表、上游 hash 与五平台构建审计 |
| W0-04 | 不适用 | 建立 old/new binding 测试构建开关 | 实施以独立 Git 提交回退取代长期双路径，发布构建始终只有一套注册 |

阶段门槛：没有基线回归、文件闭包和模块级可回退提交时，不开始替换运行路径。

### W1：按 Lua State 隔离 Module Context

| ID | 状态 | 任务 | 验收标准 |
| --- | --- | --- | --- |
| W1-01 | 已完成 | 以 Lua registry 实现 state-local 模块上下文 | 一个 state 只能取得自己的模块实例 |
| W1-02 | 已完成 | 为上游 wrapper 提供 state-local `luax_getmodule` | helper 不读取 `Module::instances[]`，与固定 Love 11.5 来源差异可由 Git 审阅 |
| W1-03 | 已完成 | 调整模块注册、关闭和异常回滚 | registry 延迟发布；构造后 type 注册失败不会留下模块或 Proxy 引用 |
| W1-04 | 已完成 | 双 LoveNode 交叉隔离和重启压力测试 | 关闭一个 state 后另一个继续调用，关闭 state 可重新打开 |
| W1-05 | 已完成 | Thread worker 模块上下文验证 | worker state 独立取得并释放模块且不污染全局 singleton |

阶段门槛：双实例、重启和 worker 隔离全部通过，TSan/ASan 不出现共享实例问题。

### W2：恢复上游源码与构建单元

| ID | 状态 | 任务 | 验收标准 |
| --- | --- | --- | --- |
| W2-01 | 已完成 | 按模块恢复 Love 11.5 上游源码 | math/data、Filesystem/File/FileData、Sound/Decoder/SoundData、Image/ImageData/CompressedImageData、Font/Rasterizer/GlyphData、Graphics、Audio Source、Video、Thread/Channel、平台输入，以及 Physics 的 backend-neutral 基类和全部对象 wrapper 已恢复；当前 328 文件、117 个未修改文件 SHA-256 和 58 个未修改 wrapper 通过审计 |
| W2-02 | 已完成 | 更新 xmake 独立构建单元 | macOS arm64、iOS arm64/模拟器双架构、Android 三 ABI、Linux x86_64 Zig、Windows x86_64 Zig/MinGW 均由当前 xmake 源码构建通过；standalone CMake、Windows 完整交叉测试目标和 Dora Xcode Debug 亦通过 |
| W2-03 | 已完成 | 更新源码子集和许可证审计 | 当前全部目标模块闭包、许可证、五平台构建清单与 Box2D/原生平台实现排除规则均已纳入自动审计 |
| W2-04 | 已完成 | 建立 vendor 刷新流程 | `DORA_SOURCE.md` 固定 Love 11.5 来源和 curated subset 边界；源码审计锁定保留文件及未修改文件哈希，Dora 差异直接通过 Git 提交审阅，不维护重复 patch 快照 |

阶段门槛：恢复源码不改变默认运行路径，五平台至少完成编译清单审计。

### W3：迁移平台无关模块

首批顺序：`love.math` → `love.data` → ByteData/DataView/CompressedData → Transform/BezierCurve/RandomGenerator → ImageData/GlyphData/SoundData 的纯数据部分。

| ID | 状态 | 任务 | 验收标准 |
| --- | --- | --- | --- |
| W3-01 | 已完成 | 编译原版 math/data wrapper 和对象实现 | 完整 math/data 模块、对象、Lua helper、codec、hash 和算法均由 xmake 编译 |
| W3-02 | 已完成 | 将对应模块注册切换为上游 wrapper | `love.math` 与 `love.data` 分别由 `luaopen_love_math/data` 整体注册 |
| W3-03 | 已完成 | 迁移 Data 对象生命周期 | clone/view/parent release/GC、自定义 Data 子类输入和双 state 隔离全部通过 |
| W3-04 | 已完成 | 删除已替代的 LoveRuntime binding | math/data 重复方法、对象、codec 和聚合编译单元均已删除 |

阶段门槛：算法向量、对象生命周期、双实例确定性和现有游戏语料无回归。

### W4：迁移资源与文件模块

顺序：Filesystem/File/FileData → Image decoder 接口 → Font/Rasterizer/GlyphData → Sound/Decoder。

| ID | 状态 | 任务 | 验收标准 |
| --- | --- | --- | --- |
| W4-01 | 已完成 | 让原版 filesystem wrapper 调用 Dora adapter | `luaopen_love_filesystem` 创建 state-local `DoraLoveFilesystem`；所有读取经过 Content，写入限制在实例写目录 |
| W4-02 | 已完成 | 迁移 File/FileData 和 archive mount 对象 | `.love`/`.zip`、FileData mount、非 UTF-8 文件名、双实例、restart 和 mount 生命周期由现有 Runtime 回归覆盖 |
| W4-03 | 已完成 | 迁移 Image/Font/Sound 数据 wrapper | ImageData/CompressedImageData、Font/TrueTypeRasterizer/GlyphData/Rasterizer 与 Sound/Decoder/SoundData 均由 Love 11.5 原版 wrapper 注册，Dora 子类只实现 Content、stb/BMFont、图像解析和 SoLoud backend |
| W4-04 | 已完成 | 删除对应自写 binding | Filesystem/File/FileData、Image/ImageData/CompressedImageData、Font、Sound/Decoder/SoundData、GlyphData 和 Rasterizer 的重复公开方法与模块表均已删除；原版 wrapper、state-local factory、patch 重放、源码/平台审计及完整测试通过 |

阶段门槛：路径安全、包加载、资源释放和跨平台 decoder 构建全部通过。

### W5：迁移 Graphics 上层类型和 Wrapper

这是风险最高的阶段，必须拆分提交：基础状态 → Image/Canvas/Quad → Mesh/SpriteBatch/ParticleSystem → Text/Font → Shader → Video drawable。

| ID | 状态 | 任务 | 验收标准 |
| --- | --- | --- | --- |
| W5-01 | 已完成 | 定义 `DoraGraphics` 与上游 Graphics 的适配边界 | `DoraLoveGraphics` 是每个 Lua State 独占的 `M_GRAPHICS` 模块，只指向所属 LoveRuntime/GraphicsBackend；不创建 OpenGL context，不拥有宿主 window、swapchain 或 present |
| W5-02 | 已完成 | 迁移 Drawable/Texture/Quad、标准 transform parser 和 draw dispatch | Quad、Drawable、Texture、Graphics Image/Canvas 对象层、标准 transform parser 及原版 `w_draw/w_drawLayer` 已迁移；Image/Canvas 绘制直接消费 wrapper 解析出的 Texture/Quad/Matrix4，剩余 Drawable backend 命令体按 W5-04/W5-05 分批收敛 |
| W5-03 | 已完成 | 迁移 Canvas、Graphics 状态栈和 pass 顺序 | Canvas C++/Type/Lua wrapper、`setCanvas/getCanvas/clear/discard/reset/flushBatch/present`、12 个 transform-stack 入口及颜色/背景色/线/点/ColorMask/wireframe/scissor/default filter/blend/depth/cull/winding/stencil-test/stencil callback 34 个 DisplayState 入口均由原版 wrapper 分派；Dora 保持唯一 pass/window/present 所有权 |
| W5-04 | 已完成 | 迁移 Mesh/SpriteBatch/ParticleSystem | 三类对象的原版 Type/对象契约、构造、对象方法 wrapper 和 draw command Matrix4 直通均已迁移；CPU/GPU storage、ParticleSystem 实例随机/模拟状态仍由 Dora backend 持有 |
| W5-05 | 已完成 | 迁移 Text/Font 和 Shader wrapper | Graphics Font/Text 已切到原版 Type、对象/构造 wrapper 和 Matrix4 draw command；Shader 已切到原版 Type、uniform contract 与方法 wrapper。Dora 保留 Content/BMFont、layout、shader 转译/诊断及 renderer backend |
| W5-06 | 已完成 | 删除 LoveRuntime 中旧 Graphics API 注册 | surface/status、capability/stats、primitives、Canvas/Quad/Shader/Font/print/Image 构造与 `captureScreenshot` 均由 state-local wrapper 分派；LoveRuntime 只保留 Graphics backend、异步截图请求和宿主合成逻辑 |

阶段门槛：macOS 像素基准通过；Windows、Linux、Android、iOS 完成构建和运行矩阵；固定开源游戏 Graphics 语料不低于迁移前通过数。

### W6：迁移平台和高风险模块

| ID | 状态 | 任务 | 验收标准 |
| --- | --- | --- | --- |
| W6-01 | 已完成 | Audio/Source/Queueable wrapper 迁移 | Source 使用原版 Type/对象契约和 wrapper；SoLoud 仍是唯一输出设备，queue/effects/filter/voice budget 回归与多平台 SoLoud 生命周期 workflow 通过；物理设备可听输出归人工验收 |
| W6-02 | 已完成 | Event/Window/Input/System/Timer wrapper 迁移 | System、Timer、Event、Window、Keyboard、Mouse/Cursor、Touch、Joystick 已切换为原版 wrapper 与 state-local Dora backend。虚拟窗口和 Dora 事件路由不被上游 SDL module 接管；macOS、Windows、Linux、Android AVD 与 iOS Simulator 运行 workflow 已通过，物理输入/触觉/麦克风体验归人工验收 |
| W6-03 | 已完成 | Thread/Channel wrapper 迁移 | 原版 Thread/Channel Type、对象契约和 wrapper 已接管公开 API；Dora 保留 Lua 5.5 worker、Content 请求泵、runtime-scoped Channel、取消和 join。普通/sanitizer Runtime 与 macOS、Windows、Linux、Android AVD、iOS Simulator 两代 Thread restart/isolation workflow 已通过 |
| W6-04 | 已完成 | Physics wrapper 和对象层迁移 | backend-neutral Type 以及 Body、World、Fixture、Contact、Shape、Joint wrapper 已由 Dora PlayRho 对象实现；Dora filter、contact callback、ghost/one-sided edge、全部 Joint 子类型、完整 sanitizer、五平台当前源码运行 workflow 和源码审计已通过 |
| W6-05 | 已完成 | Video wrapper 迁移 | Video/VideoStream 使用原版 Type、对象与 wrapper；Theora、Video drawable、音视频同步和 VideoNode 共用依赖通过，五平台 Ogg/Theora Content/RenderTarget 解码 workflow 已通过 |

阶段门槛：所有模块保持 Dora 平台设施唯一所有权，多 LoveNode 和应用级共享状态符合既有设计。

### Thread/Channel 与截图的收敛设计

`love.thread` 不能直接恢复 Love 的原生线程平台层。Dora 现有实现已经解决 Lua 5.5 worker state、`Content` 主线程请求、restart 取消、`threaderror` 投递和多 LoveNode 隔离，这些属于 Dora backend，不随 wrapper 迁移替换。

目标分层为：

```text
wrap_ThreadModule / wrap_LuaThread / wrap_Channel
  负责 newThread/newChannel/getChannel、重载、返回值和对象方法
        ↓
state-local DoraLoveThreadModule + DoraLoveLuaThread + DoraLoveChannel
  负责 Love Object/Type、对象强弱引用和当前 Lua State 归属
        ↓
现有 ThreadContext / ThreadWorker / ThreadChannel backend
  负责 std::thread、Lua 5.5 worker、Content 代理、取消、join 和队列同步
```

实施顺序固定为：

1. 恢复 Love 11.5 `Channel` / `LuaThread` / `ThreadModule` 的公开对象契约和原版 wrapper，不引入 Love 原生平台线程实现。
2. 用 Dora 具体子类包装现有 `ThreadWorker` / `ThreadChannel`，确保只有一份队列、worker 和关闭状态。
3. `luaopen_love_thread` 通过 `luax_getmodule(state, M_THREAD)` 只取得当前 state 的 `DoraLoveThreadModule`，删除 `ThreadUserdata` / `ChannelUserdata` 和手写方法表。
4. 对账 `push/supply/pop/demand/peek/getCount/hasRead/clear/performAtomic`、Thread 重复 start、wait、error 与 running 语义，并重跑两代 LoveNode restart/close 压力。
5. Thread/Channel 对象收敛后，再启用原版 `captureScreenshot(function|string|Channel)` wrapper。截图的帧末读回、weak/generation token、`Content` 保存和 backend request 仍由 Dora 实现。

因此 `captureScreenshot(Channel)` 不单独复制一个临时 Channel 识别分支；它是 W6-03 的直接下游验收项。这个顺序可以保证截图 wrapper 与 `love.thread` 使用同一个上游 `Channel` Type，不在 Graphics 和 Thread 之间形成新的平行 userdata。

### W7：收尾、发布和维护流程

| ID | 状态 | 任务 | 验收标准 |
| --- | --- | --- | --- |
| W7-01 | 已完成 | 删除 old binding 测试开关和失效实现 | 发布构建没有 old/new binding 开关；API parity 持续断言原版 wrapper 唯一注册且旧 parser 不得回流 |
| W7-02 | 已完成 | 拆分或缩减 `LoveRuntime.cpp` | `LoveRuntime.cpp` 由 17,924 行缩减为约 1,172 行，只呈现 state、boot、调度、错误和模块装配；adapter 与 backend-neutral 对象实现移入 `LoveRuntimeAdapters.inc`，保持单一编译单元和内部类型可见性 |
| W7-03 | 已完成 | 更新 TS/Teal 文档生成和 API 对账 | API parity 直接读取 Love 11.5 wrapper method table，并对英中 TypeScript/Teal 四份声明执行 4,324 项方法对账 |
| W7-04 | 已完成 | 五平台 CI、Sanitizer 和游戏语料验收 | 五平台当前源码构建及核心运行 workflow、macOS 普通/ASan+UBSan CTest 与集成 workflow、官方兼容快照 238 pass/0 fail/53 skip 已通过；Android `32886811734`、iOS `32886815756`、Linux `32886819237`、macOS `32886823057` 及修复 MSVC 类名歧义后的 Windows `32888321145` 五套既有 CI 全部成功。物理设备输入、麦克风和可听输出按约定留给人工验收，不由模拟器/注入事件替代 |
| W7-05 | 已完成 | 更新公开教程和兼容说明 | LoveNode 英中教程以 API 数量比和兼容专项展示实际边界；已迁移 API 不再统称为 Dora 手写近似 binding，仅 SoLoud 等 backend 语义差异保留明确说明 |

阶段门槛：移除双路径，源码、构建、文档和发布包均无旧 binding 残留。

## 单个模块的标准实施模板

每个模块都按同一顺序迁移，避免“wrapper 已编译”被误认为“迁移已完成”：

1. **依赖闭包盘点**：列出 wrapper、对象类型、模块基类、Lua helper、平台依赖和三方库；明确哪些恢复、哪些裁剪。
2. **基线固定**：为当前 Dora binding 建立 API parity、错误路径、生命周期和真实 LoveNode 回归；未验证行为不能在迁移后被声称兼容。
3. **恢复上游对象层**：优先原样复制 Love 11.5 文件并固定 SHA-256；需要修改的文件退出未修改 hash 清单，并以独立 Git 提交记录。
4. **建立 state-local factory**：`luaopen_love_*` 只创建或获取当前 `lua_State` 的模块；模块对象保存所属 `LoveRuntime`/backend，不读取进程级 singleton。
5. **实现 Dora adapter**：只实现抽象 factory、资源上传、I/O 或设备调用，不复制公开 Lua 参数解析。
6. **切换运行注册**：由 `luaopen_love_*` 注册模块和对象，旧表仅在短期测试分支用于对照。
7. **删除重复实现**：删除旧函数、userdata、metatable、枚举转换和生命周期包装；检查 `LoveRuntime.cpp` 不再保留同名 API。
8. **四层验收**：依次通过 Binding、对象生命周期、LoveNode workflow、平台/游戏语料验证。
9. **更新审计和文档**：同步源码清单、固定 hash、五平台构建清单、TS/Teal API 对账和本进度表。

一个任务只有在第 1～9 项全部完成后才能标记“已完成”。仅通过编译应标记“实现中”，通过 Runtime 单测但未完成 sanitizer/平台构建应标记“待完整验收”。

## 当前收敛状态与下一步

| 范围 | 当前状态 | 下一门槛 |
| --- | --- | --- |
| Module context | 已完成 | 持续以双 LoveNode、restart 和 worker 隔离测试守护 |
| Math / Data | 已完成 | 保持原版 wrapper，并由源码 hash 与 Git 历史审计 Lua 5.5 差异 |
| Filesystem / File / FileData | 已完成 | 保持 Content-only、路径安全和 archive 回归 |
| Sound / Decoder / SoundData | 已完成 | 已由 Audio/Source 原版对象层直接复用 |
| Font / Rasterizer / GlyphData | 已完成 | 后续 Graphics Text/Font 迁移不得重建平行 userdata |
| ImageData / CompressedImageData | 已完成 | 后续 Texture/Image 只消费上游 Data 对象 |
| Image module | 已完成 | 由原版 wrapper 注册，state-local `DoraLoveImage` 只提供 Content/image backend factory |
| Graphics Quad | 已完成 | 与 Drawable/Texture 及标准 transform parser 合并进入 W5-02 验收 |
| Graphics Drawable | 已完成 | 七类现有 Dora drawable 具备真实上游 C++ 基类 |
| Graphics Texture / Image | 已完成 | Dora Image 是上游 `graphics::Image` 具体子类，原版 Texture/Image wrapper 负责全部公开对象 API |
| Graphics 其余对象和模块 | 已完成 | Canvas/状态栈、Mesh、SpriteBatch、ParticleSystem、Graphics Font/Text/Shader/Video、主要构造入口与 `captureScreenshot` 已收敛，旧公开 parser 已删除 |
| Audio Source | 已完成 | 原版 Source Type/对象与 wrapper 负责 API 语义，Dora/SoLoud backend 保持唯一设备与资源所有权 |
| Video | 已完成 | 原版 Video/VideoStream Type、对象方法及 `newVideo` Lua constructor 负责 API 语义；Dora 保持 Content/Theora/纹理上传/SoLoud backend，五平台运行 workflow 通过 |
| Thread / Channel | 已完成 | 上游对象契约与 wrapper 已接管公开 API，Dora Lua 5.5 worker/backend 保持唯一所有权；`captureScreenshot(Channel)` 使用同一上游 Channel Type，五平台 restart/isolation workflow 通过 |
| 平台模块 | 已完成 | System、Timer、Event、Window、Keyboard、Mouse/Cursor、Touch、Joystick 均已迁移；完整 sanitizer 与五平台当前源码运行矩阵通过，物理 I/O 归人工验收 |
| Physics | 已完成 | Body、World、Fixture、Contact、Shape、Joint 已使用原版或按原版 method table 适配的 wrapper；PlayRho 继续作为唯一 backend，并保留 Dora filter、contact callback、ghost/one-sided edge 规则；standalone、sanitizer、五平台运行 workflow 与源码审计通过 |

实施结果：Graphics、Audio Source、Video、Thread/Channel、截图、System、Timer、Event、Window、Input 与 Physics 全对象族已完成原版 wrapper 收敛；源码审计、sanitizer、五平台当前源码构建和核心运行矩阵已通过。`draw(texture, transform)`、`draw(texture, quad, transform)` 以及已迁移高层 Drawable 的 Transform 重载均由原版 parser 和 state-local command adapter 统一处理，不再在 Dora binding 中逐个补重载。发布前剩余门槛是当前变更提交后的 CI；物理设备 I/O 依照约定由人工验收。

## 测试与验收矩阵

每个模块迁移至少执行以下四层验证：

| 层级 | 验证内容 |
| --- | --- |
| Binding 单测 | 参数数量、类型错误、默认值、重载、返回值和弃用别名 |
| 对象单测 | Proxy 复用、StrongRef、显式 release、GC、跨 state 拒绝和 backend handle 释放 |
| LoveNode workflow | 真实隔离 state 中加载模块、运行 callback、停止、重启和错误行号改写 |
| 平台/语料 | macOS 基准，加 Windows/Linux/Android/iOS 构建运行及固定开源游戏比较 |

Graphics 还必须包含像素读回、Canvas pass 顺序、Shader、Stencil、Blend、Transform 和高 DPI；Audio 必须包含 PCM/状态回归与人工听感边界；Input、Recording 和设备能力继续区分自动化与物理设备人工验证。

## 实施进度记录

以下条目按实施当时的验证方式保留历史记录，其中出现的编号 patch 或“重放”仅表示当时的迁移切片证据，不再对应仓库中的维护文件。当前维护以 vendored 源码、固定上游信息、源码审计和 Git 历史为准。

### 2026-08-25：state-local 基础与完整 `love.math` 上游 wrapper

- `luax_register_module` 不再写入 `Module::instances[]`，并在函数/type 注册全部成功后，才将同一 Proxy 以模块名和 `ModuleType` 事务式发布到当前 Lua State 的 registry。
- 新增按类型和名称查询的 `luax_getmodule(lua_State*, ...)`，双 state、关闭一个后继续调用、重新打开及 worker state 生命周期测试通过。
- `MathModule`、`RandomGenerator`、`Transform`、`BezierCurve`、所需 common math 类型、Noise、wrapper 和 Lua helper 从固定 Love 11.5 commit 恢复；子集审计固定 20 个未修改文件的 SHA-256，修改文件通过独立 patch 对账。
- `LoveRuntime` 删除自写 math 模块方法表、随机算法、颜色/gamma/noise/三角剖分实现，以及三个对象的 userdata 和方法注册，改由一次 `luaopen_love_math` 注册完整上游模块。
- Graphics draw/apply/replace 路径直接读取上游 `Transform::getMatrix()`；模块初始化前会先发布同一个 `love` table，确保上游 wrapper 创建的 state-local module registry 不会在初始化末尾失联。
- 上游 math wrapper 直接依赖尚未迁移的 data wrapper，因此当前 patch 暂时移除其两个 deprecated codec 函数；`LoveRuntime` 在模块打开后以现有 Dora data 实现补回 `compress/decompress`，待 data 模块迁移后删除该例外。
- BezierCurve 不再保留 Dora 自写 binding 的 `render(accuracy > 20)` 限制；Love 11.5 上游未定义该限制，因此测试改为对账上游行为。
- 上游 wrapper 的 gamma 返回值按 float 精度处理，且 Love 11.5 不额外拒绝传入 Noise/凸性算法的无限值；测试已移除 Dora 自写实现独有的限制，改为验证上游语义。
- UBSan 发现 Love 11.5 `Transform:setMatrix` 非法 layout 报错路径读取未初始化 enum；最小 patch 初始化为 row-major，仅用于生成同一枚举错误，不改变合法输入行为。
- 自动验证：standalone CMake Runtime 与五项审计 6/6 通过；ASan/UBSan Runtime 1/1 通过（macOS 禁用不支持的 LeakSanitizer）；当时 API parity 为 294 Graphics + 418 core、声明 4168；许可证、源码子集、进度一致性和平台构建清单审计通过；macOS xmake `love` target 通过。
- 当时待办：TSan、五平台 CI、固定游戏人工回归；`love.data` 已在下一记录完成。

### 2026-08-25：完整 `love.data` 上游 wrapper

- 恢复并编译 Data base、DataModule、ByteData、DataView、CompressedData、Compressor、Hash、Base64、LZ4 及全部对象 wrapper；未修改文件纳入固定 SHA-256 清单。
- `LoveDataObject` 改为真正继承上游 `love::Data`，因此 Dora 的 ImageData、CompressedImageData、SoundData、GlyphData 和 FileData 可以直接作为上游 `love.data` wrapper 输入，不再维护并行的 Data 类型系统。
- `LoveRuntime` 删除自写 ByteData/DataView/CompressedData、codec、hash、pack/unpack 和注册表；`love.data` 改由 `luaopen_love_data` 整体注册，`love.math.compress/decompress` 恢复 Love 11.5 原版参数顺序和返回语义。
- 删除 `LoveDataAlgorithms.cpp`、`LoveLZ4.c`、`LoveLZ4HC.c` 三个 Dora 聚合编译单元，并从五个平台工程清单移除；实现现在只由 xmake 的 `liblove` 构建一次。
- Data wrapper 不再包含 Love 的 Lua 5.3 `lstrlib`：最小 patch 在当前 Lua 5.5 state 调用标准 `string.pack/unpack/packsize`，没有引入第二套 Lua runtime。
- Runtime 覆盖上游对象 clone、DataView 对父对象的强引用、自定义 Dora Data 子类、三种压缩、LZ4 header、六种 hash、pack/unpack、显式 release、双 state、关闭其中一个后继续调用及 reopen。
- 当前 API parity 为 294 Graphics + 421 core，声明 4168；源码子集在下一记录扩展前为 144 文件、47 个固定 upstream hash；macOS xmake `love` target 与 Dora Xcode Debug arm64 全量构建均已通过。
- 普通 Runtime 与五项审计 6/6、ASan+UBSan Runtime 1/1 已通过；Sanitizer 同时发现并修复非法枚举诊断和 LZ4 legacy fast decoder 的未定义行为。
- 待办：五平台 CI 与固定游戏人工回归。

### Filesystem / File / FileData 原版 wrapper 与 Dora Content adapter

- 恢复并直接编译 Love 11.5 的 `Filesystem`、`File`、`FileData` 及三套 wrapper；未修改文件保持上游字节一致，源码子集扩展为 149 文件、57 个固定 upstream hash，xmake `love` target 为 40 个上游源文件。
- `FileUserdata` 不再建立平行 Love 类型，而是实现上游 `love::filesystem::File` 抽象；读取、写入、flush、seek 和 size 查询继续调用实例的 Dora `FilesystemBackend`，因此没有引入 stdio、PhysFS 或宿主绝对路径回退。
- FileData 改用上游 `love::filesystem::FileData`，图片、字体、shader、sound、thread 与 mount 等既有消费者统一从 `love::Data` 内存读取；自写 Filesystem/File/FileData 公开 Lua 方法和类型注册已删除，由 `luaopen_love_filesystem` 连同对象 wrapper 整体注册。
- `DoraLoveFilesystem` 实现上游抽象并持有所属 LoveRuntime；source/save/mount/require path 均保持 state-local。PhysFS、DroppedFile、SDL native loader、host `stat` 和平台 executable fallback 未被带回，`getExecutablePath` 只从 Dora backend 查询。
- Dora 只覆盖原版模块表中的三个宿主边界：identity 安全校验、require path 安全校验、以及 `filesystem.load` 的 Lua 5.5 字节码诊断与 TS/Teal/Yue 行号改写；它们不是第二套公开 API 实现。
- standalone 完整 CTest 12/12、ASan+UBSan Runtime 1/1、macOS xmake `love` target 与 Dora Xcode Debug arm64 全量构建通过；双 identity、save/source 优先级、FileData、zip/FileData mount/unmount、restart、路径逃逸和 staging 清理均由 Runtime 回归覆盖。W4-01/W4-02 完成，W4-04 随 Image/Font/Sound 继续推进。

### SoundData 原版对象与 wrapper

- 恢复 Love 11.5 的 `Decoder` base、`SoundData` 和 `wrap_SoundData`；当前总源码子集为 171 文件、82 个固定 upstream hash，xmake `love` target 为 51 个上游源文件。`SoundData.cpp` 的独立 patch 在分配前使用整数除法检查尺寸，并保留 256 MiB 解码数据上限。
- `sound.newSoundData` 仍使用 Dora 现有 Content/SoLoud decoder 产生 PCM，但构造的对象已是上游 `love::sound::SoundData`；clone、sample、metadata 和 Data 方法由 `luaopen_love_sound` 所带的原版 wrapper 注册。
- `LoveRuntime` 的平行 SoundData userdata、13 个公开方法和类型注册已删除；Audio Source、Queueable Source、Shader Data 与 Mesh Data 路径均改为从上游 Data 指针和 metadata 读取。
- Runtime SoundData/Decoder 专项与完整 CTest 12/12、ASan+UBSan Runtime 1/1、macOS xmake `love` 和 Xcode Debug arm64 已通过；精确 duration 断言改为容差比较，以对齐 Love 11.5 上游返回的 float 精度。

### GlyphData 原版对象与 wrapper

- 恢复 Love 11.5 未修改的 pixel format 表、utf8cpp、`GlyphData` 和 wrapper；当前源码子集为 164 文件、74 个固定 upstream hash，xmake `love` target 为 46 个上游源文件。
- Dora Image/TrueType/BMFont rasterizer 仍负责产生 RGBA8/LA8 像素与 metrics，但现在直接填充上游 `love::font::GlyphData` 分配；clone、UTF-8 glyph string、bearing/bounds、format 和 Data 方法由 `luaopen_glyphdata` 注册。
- `LoveRuntime` 的平行 GlyphData userdata、14 个公开方法和类型注册已删除。Runtime 字形/字体回归与完整 CTest 12/12、ASan+UBSan Runtime 1/1、macOS xmake `love` 和 Xcode Debug arm64 已通过。

### Rasterizer 原版对象层与 wrapper

- 恢复 Love 11.5 未修改的 `Rasterizer` base 和 wrapper；当前源码子集为 167 文件、78 个固定 upstream hash，xmake `love` target 为 48 个上游源文件。
- Dora Image/TrueType/BMFont rasterizer 现在是 `love::font::Rasterizer` 具体子类，直接实现 metrics、glyph count、hasGlyph、data type 和 `getGlyphData`；最后一项返回上游 GlyphData，但 Content、stb 和 BMFont page 像素生成保持 Dora backend。
- `LoveRuntime` 的八个 Rasterizer 公开 Lua 方法和手写类型注册已删除，改由 `luaopen_rasterizer` 调用子类虚函数。完整 CTest 12/12、ASan+UBSan Runtime 1/1、macOS xmake `love` 和 Xcode Debug arm64 已通过。

### Sound/Decoder 原版模块与 wrapper

- 恢复 Love 11.5 未修改的 `Sound` 实现/头文件和 Decoder wrapper 头；编译原版 `wrap_Sound.cpp`、`wrap_Decoder.cpp`，并由 `luaopen_love_sound` 一次注册 Sound、Decoder 与 SoundData。
- `DoraLoveSound` 是每个 Lua state 独占的上游 Sound 具体子类。`newDecoder(FileData, bufferSize)` 直接读取 FileData 内存并调用所属 LoveRuntime 的 SoLoud decoder；filename 重载先由原版 filesystem wrapper 经 Dora Content 转为 FileData，因此没有新增原生文件旁路。
- Dora Decoder 现在继承上游 `love::sound::Decoder`，仅保存 SoLoud 一次解码得到的 PCM16 snapshot 和独立 cursor；clone/decode/seek/metadata 由原版 wrapper 调用虚函数，`newSoundData(decoder)` 使用上游 Sound/SoundData 实现。
- `LoveRuntime` 原有 Sound 模块表、Decoder 类型注册和八个公开 Decoder Lua 方法已删除。Lua 5.5 patch 只补 Love 11.5/LuaJIT 的有限数值截断语义、state-local 模块查找和非有限 seek 防护；双 state 使用各自 SoLoud backend、关闭其中一个后另一个继续解码的回归已通过。
- 本阶段完整 CTest 12/12、ASan+UBSan Runtime 1/1、macOS arm64 xmake `love` 静态库和 Dora Xcode Debug 主目标均已通过；源码子集、API parity、五平台构建清单及九个 patch 顺序应用审计同步通过。

### ImageData 原版对象与 wrapper

- 恢复 Love 11.5 的 `ImageDataBase`、`ImageData`、`FormatHandler`、`CompressedSlice`、`Color`、`wrap_ImageData.cpp` 与原版 `mapPixel` Lua helper；源码子集现为 182 文件，其中 91 个未修改文件由固定 SHA-256 对账，xmake `love` target 为 56 个上游源文件。
- `DoraImageData` 是上游 `love::image::ImageData` 的具体子类。clone、17 种原生 PixelFormat、Data 方法、pixel/mapPixel/paste、参数解析和对象注册直接使用 Love 11.5；仅 decode factory、PNG/TGA encode 与 Content 写入继续调用所属 LoveRuntime 的 Dora backend。
- `LoveRuntime` 已删除平行 ImageData userdata 的公开 Lua 方法和手写类型注册，Rasterizer、BMFont、Cursor、Graphics、Thread 与 Shader Data 消费路径统一读取上游 ImageData。跨 state 输入仍由 Dora 子类保存的 owner 校验拒绝。
- 最小 `0010` patch 让 encode 可由 Dora 子类覆盖并禁用进程级 Image/Filesystem codec 查找；同时补 Lua 5.5 到 C++ `int` 的范围检查、整数像素 NaN 安全转换、重叠 self-paste 的 `memmove`、非法 encode format 的诊断枚举初始化，以及上游 `setPixel(table)` 对单通道格式使用错误栈索引的问题。
- 原版 `ImageData:paste(self, ...)` 暴露 Dora Love thread adapter 与 SDL mutex 的语义差异；Dora adapter 已改用递归 mutex 与 `condition_variable_any`，自粘贴不再死锁。路径逃逸在调用 encoder 前拒绝，保持失败调用无 backend 副作用。
- 本阶段完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、macOS arm64 xmake `love` 静态库与 Dora Xcode Debug 主目标均已通过；API parity、182 文件源码子集、五平台构建清单及十个 patch 顺序应用审计同步通过。

### Font 原版模块与 wrapper

- 恢复 Love 11.5 的 `Font` 接口、`wrap_Font.cpp`、wrapper 头与未修改的 stb `TrueTypeRasterizer`；源码子集扩展为 186 文件，其中 94 个未修改文件由固定 SHA-256 对账，xmake `love` target 为 58 个上游源文件。
- `DoraLoveFont` 是每个 Lua state 独占的上游 Font 具体子类。原版 wrapper 负责所有 overload、对象转换、Lua 类型注册和错误入口；Dora 子类只负责默认字体、Content/FileData、ImageData atlas、stb TrueType 和文本 BMFont page 的构造。
- Image、TrueType、BMFont Rasterizer 继续使用已迁移的上游 Rasterizer/GlyphData 对象。BMFont 自动及显式 page 均走 Dora Content/图像 backend；`graphics.newFont("*.fnt")` 也先通过 state-local filesystem/Font 模块生成原版 Rasterizer userdata，不再调用旧 Font binding。
- `0011` patch 移除进程级 FreeType、内嵌 Vera 与 native Image/BMFont factory，保留 Dora backend 的纯虚构造边界；同时补 Lua 5.5 有限数值截断、C++ `int`/Unicode 范围校验，并修复上游 `newBMFontRasterizer` page table 转换固定读取参数一的问题。
- `LoveRuntime` 的五个 `fontNew*` 方法、手写 `love.font` 模块表和独立 GlyphData/Rasterizer 注册已删除，改由 `luaopen_love_font` 一次创建 state-local Font 模块并注册关联对象。双 state、默认/Data TrueType、Image/BMFont、page filename/FileData table、fractional size 与越界输入均纳入 Runtime 回归。
- 本阶段完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、macOS arm64 xmake `love` 静态库与 Dora Xcode Debug 主目标均已通过；API parity 保持 294 Graphics + 421 core、英中 TypeScript/Teal 4168 method checks，186 文件源码子集、五平台构建清单和十一个 patch 顺序重放审计同步通过。迁移后遗留的三个未使用 Font/Rasterizer helper 已删除，Xcode 主目标无该阶段新增编译告警。

### Graphics Quad 原版对象与 wrapper

- 恢复 Love 11.5 未修改的 `Quad` 对象、头文件和 wrapper 头，并把原已保留用于 API 审计的 `wrap_Quad.cpp` 加入实际构建；源码子集扩展为 189 文件，其中 98 个未修改文件由固定 SHA-256 对账，xmake `love` target 为 60 个上游源文件。
- `LoveRuntime` 的平行 `QuadUserdata`、独立 Type、五个公开方法和自定义 metatable 已删除。viewport、texture dimensions、zero-based native layer、vertex/UV 刷新、Object/Proxy 生命周期和 Lua-visible 1-based layer 全部来自上游实现。
- 当前 Graphics 模块尚未整体迁移，因此 `graphics.newQuad` 暂时仍是 Dora adapter：纯数字重载直接构造上游 Quad，Image/Canvas 重载只从所属 Runtime 的 Dora handle 读取纹理尺寸，并补齐原先遗漏的 `newQuad(x,y,w,h,layer,texture)` 重载。draw、drawLayer、SpriteBatch 与 ParticleSystem 消费路径统一读取上游 Quad getters。
- Runtime 覆盖数字/Image/Canvas、layer+ArrayImage、viewport 刷新、draw/drawLayer、SpriteBatch、ParticleSystem、release 后强引用和类型层级；完整 CTest 12/12、ASan+UBSan Runtime 1/1、macOS arm64 xmake 静态库与 Dora Xcode Debug 主目标通过，API parity、源码子集和五平台构建清单同步通过。本切片未修改上游文件，因此无需新增 patch。

### CompressedImageData 原版对象与 wrapper

- 恢复 Love 11.5 的 `CompressedImageData` 对象/头和 wrapper 头，并把原已保留用于 API 审计的 `wrap_CompressedImageData.cpp` 加入实际构建；源码子集扩展为 192 文件，其中 100 个未修改文件固定 SHA-256，xmake `love` target 为 62 个上游源文件。
- `DoraCompressedImageData` 继承上游对象，把 Dora Content→bimg parser 返回的格式、mip 尺寸与 bytes 一次性填入 `CompressedMemory` 和 `CompressedSlice`。公开 clone、mip queries、format、Data string/size/pointer、Object/Proxy 生命周期全部由原版对象和 wrapper 实现；Graphics/Mesh 仍通过子类保留的 parser metadata 进入现有 bgfx 上传路径。
- `LoveRuntime` 的平行 Data 对象、十个手写方法和类型注册表已删除，改由 `luaopen_compressedimagedata` 注册。最小 `0012` patch 只增加 protected backend construction path，不导入 Love native DDS/KTX/PVR handlers 或文件访问。
- Runtime 既有 DDS/KTX/PVR、clone、mip、Data 互操作、Graphics 2D/Array/Cube/Volume 上传和失败边界回归通过；完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、macOS arm64 xmake 静态库与 Dora Xcode Debug 主目标通过，API parity、192 文件源码子集、五平台构建清单和十二个 patch 顺序重放同步通过。

### Image 原版模块与 state-local Dora backend

- 恢复 Love 11.5 的 `Image` 模块、头文件、wrapper 头并编译原版 `wrap_Image.cpp`；源码子集扩展为 195 文件，其中 101 个未修改文件固定 SHA-256，xmake `love` target 为 64 个上游源文件。
- `DoraLoveImage` 是每个 Lua state 独占的上游 Image 具体子类。原版 wrapper 负责 `newImageData`、`newCompressedData`、`isCompressed` 的 filename/Data overload、默认值、错误入口和关联对象注册；Dora 子类只把解码、空白/raw ImageData 和压缩容器解析交给所属 LoveRuntime 的 image backend。
- 上游 `newCubeFaces`/`newVolumeLayers` 平台无关算法保留在对象层，native magpie PNG/STB/EXR/DDS/KTX/PVR handlers 和进程级模块 singleton 没有带回；filename 输入先经 state-local Filesystem wrapper 和 Dora Content 转成 FileData。Mouse Cursor 的图片解码消费者也改为取得当前 state 的 Image 模块，不再调用已删除的手写方法。
- `LoveRuntime` 的手写 Image 模块表、三个公开函数及迁移后遗留的 `pushCompressedImageData` helper 已删除。`0013` patch 对 Love 11.5 干净 checkout 顺序重放成功，三个修改文件与 vendored tree 精确一致。
- API parity 保持 294 Graphics、421 core 和英中 TypeScript/Teal 4168 method checks；完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、macOS arm64 xmake 静态库及 Dora Xcode Debug 主目标全部通过，Xcode 无本阶段 LoveRuntime/Image 新增警告。W4 至此关闭。

### Graphics Drawable 原版 C++ 基类

- 恢复并原样编译 Love 11.5 `Drawable.cpp/.h`，删除 Dora 平行的 `LoveDrawableType`。源码子集扩展为 197 文件、103 个固定上游 SHA-256，xmake `love` target 为 65 个上游源文件；本切片没有修改上游文件，因此不新增 patch。
- 通用 `DoraHandleObject` 改为默认仍继承 Love `Object`、但允许 GPU drawable 指定真实上游基类。Image、Canvas、Mesh、SpriteBatch、ParticleSystem、Text 和 Video 的 C++ 对象现在全部实际派生自 `love::graphics::Drawable`，而不是仅让 Lua Type 表声称继承关系。
- 在 `DoraGraphics` 尚未建立前，Drawable 的虚拟 `draw` 入口明确拒绝绕过 state-local graphics adapter；当前公开 `love.graphics.draw` 仍走已验证的 Dora binding。后续切换原版 Graphics wrapper 时，可以安全取得真实 `Drawable*`，不会把仅继承 Object 的对象错误转换为 Drawable 造成未定义行为。
- 源码审计增加编译期 `is_base_of` 门禁并禁止平行 Drawable Type 回归。完整 CTest 12/12、ASan+UBSan Runtime 1/1、macOS xmake 与 Dora Xcode Debug arm64 通过，API parity 保持 294 Graphics、421 core、4168 声明检查，Xcode 无本切片新增警告。

### Graphics Texture/Image 原版对象与 wrapper

- 恢复 Love 11.5 的 `Resource`、depth/stencil、`Texture`、Graphics `Image` 对象和 Texture/Image wrapper 头，并实际编译原版 `wrap_Texture.cpp`、`wrap_Image.cpp`。源码子集扩展为 207 文件，其中 109 个未修改文件固定 SHA-256，xmake `love` target 为 70 个上游源文件。
- Dora `ImageUserdata` 现在是上游 `love::graphics::Image` 的具体子类，同时继续由统一 `DoraHandleObject` 对 Image handle 执行 retain/release。尺寸、层数、mipmap、格式、filter、wrap、DPI、depth compare 和 `replacePixels` 的 Lua 参数解析全部来自 Love 11.5 wrapper；Dora 子类只实现 handle 校验、metadata 同步和像素上传。
- `LoveRuntime` 已删除 24 个平行 Image/Texture 公开方法及手写类型注册。当前只调用原版 `luaopen_image`；Canvas 在完成 Texture 对象迁移前仍保留现有独立注册，因此暂不注册会与 Canvas 临时 Texture Type 冲突的 standalone Texture metatable。
- `0014` patch 去除 Texture/Image 对 Love 进程级 Graphics singleton、原生 stream renderer 和全局 flush 的依赖，把尺寸验证、上传和绘制留给 Dora adapter；显式 DPI 字段避免奇数像素 `@2x` 资源经逻辑尺寸取整后丢失 scale。`0015` 另补齐既有 Lua 5.5 多 uservalue Proxy 修改的可重放记录；15 个 patch 已从干净 Love 11.5 checkout 顺序应用并与 vendored 修改文件精确一致。
- 本切片完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、macOS arm64 xmake `love` 静态库和 Dora Xcode Debug 主目标全部通过；API parity、207 文件/109 个未修改文件 SHA-256、70 个上游构建源及 15 个 patch 干净顺序重放审计同步通过，Xcode 无本切片新增警告。Texture/Image 子任务已关闭；W5-02 仍保持进行中，下一门槛是原版 Graphics `draw`/transform parser 与 Dora command backend 对接。

### Graphics 标准 transform parser

- Love 11.5 的标准绘制变换重载解析原本定义在 `wrap_SpriteBatch.h`，同时被 Graphics 与 SpriteBatch wrapper 使用；该头会继续拉入 Mesh、Buffer 和原生 renderer 闭包。`0016` 将同一段 parser 原样复制到依赖较小的 `wrap_GraphicsTransform.h`，作为后续两个原版 wrapper 的共享入口；恢复 `wrap_SpriteBatch.h` 时再用同一 patch 移除旧定义，避免最终保留两份实现。
- Dora 当前 `graphics.draw` dispatch 已删除平行的九个数字参数解析，统一调用 `luax_checkstandardtransform` 取得 `Transform` 或 `x/y/r/sx/sy/ox/oy/kx/ky` 矩阵。Dora backend 只在解析后保留有限值和 affine 2D 能力校验，不改变 Love 的重载选择与默认值。
- 这一步只关闭标准 transform parser 的重复实现；公开 `w_draw/w_drawLayer` 还需经 W5-01 的 state-local Graphics command adapter 从进程级 `Graphics::instance()` 切换到 Dora backend。完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、macOS xmake `love` target 和 Dora Xcode Debug arm64 主目标通过；API parity、208 文件/109 hash 源码子集、70 源平台清单及 16 patch 干净顺序重放同步通过。P5-47 已关闭，W5-02 继续跟踪公开 wrapper dispatch 与 Canvas Texture。

### State-local Graphics 模块边界

- 新增 Dora-owned `LoveGraphicsAdapter.h`，其中 `DoraLoveGraphics` 是实际继承 Love `Module` 的 `M_GRAPHICS` 模块。模块 Proxy 由 `luax_register_module` 放入当前 Lua State 的 `REGISTRY_MODULES`，不再用一张未注册的普通 Lua table 冒充 Graphics 模块。
- 每个 `DoraLoveGraphics` 只保存所属 `LoveRuntime` 指针，具体 GPU 命令继续进入已注入的 `GraphicsBackend`；该类型没有 window、OpenGL context、swapchain、present loop 或 native stream renderer 所有权。后续原版 Graphics wrapper 只能通过当前 `lua_State` 查到该 adapter，禁止写入或临时替换 `Module::instances[M_GRAPHICS]`。
- Runtime 新增双 LoveRuntime 断言：两 state 的 Graphics module 对象和 Runtime 指针均不同；关闭第一个 state 后第二个 module 仍可查找；进程级 singleton 始终为空；两个 state 关闭后 Lua allocation 归零。API audit 同时固定继承关系、`luax_register_module` 注册和禁止 `Module::registerInstance` 回归。
- 完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、macOS xmake `love` target 与 Dora Xcode Debug arm64 主目标通过。该切片只增加 Dora adapter，不修改上游 Love 文件，因此 patch 数仍为 16。

### Graphics Canvas 原版对象层

- 恢复 Love 11.5 `Canvas.h/.cpp` 与 `wrap_Canvas.h`，并把 `CanvasUserdata` 从临时 Drawable/Texture Type 改为上游 `love::graphics::Canvas` 的具体子类。Lua `type/typeOf` 现在来自真实的 `Canvas -> Texture -> Drawable -> Object` C++ 与 Type 继承链，不再维护平行 `LoveTextureType`。
- Canvas 构造继续使用原版 settings 校验、PixelFormat、DPI、mipmap、readable 与 Texture metadata；Dora 子类只持有所属 LoveRuntime 的 RenderTarget handle，并实现 filter/wrap/depth compare、mipmap generation 与 metadata 同步。既有 Content/readback、活动 target 检查和 pass 提交仍由 state-local GraphicsBackend 负责。
- `0017` 只移除原版 Canvas 对进程级 native Graphics singleton 的 capability/active-target 查询及构造期虚函数调用；驱动能力在 Dora 创建 RenderTarget 前后校验。原版 `wrap_Canvas.cpp` 仍保留但暂未编译，避免其 `renderTo` 回到 `Module::getInstance<Graphics>`；下一切片将其改为 state-local adapter 后再删除手写 Canvas Lua 方法。
- Runtime 增加 Canvas 原版 Type 链断言；完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、macOS universal Debug `liblove.a` 与 Dora Xcode Debug arm64 主目标通过。源码子集为 211 文件、111 个未修改文件 SHA-256、71 个 xmake 源和 17 个 patch；干净重放覆盖 27 个修改文件且 mismatch=0。P5-49 已关闭，W5-03 继续跟踪 Canvas Lua wrapper 与状态栈。

### Graphics draw/drawLayer 原版 wrapper 分派

- 从 Love 11.5 `wrap_Graphics.cpp` 拆出保持原逻辑的 `wrap_GraphicsDraw.cpp/.h`：`w_draw/w_drawLayer` 继续负责 Drawable/Texture/Quad 重载选择、nil Quad 错误和标准 Matrix4 解析，只把最终 native Graphics 调用替换为当前 Lua State 的 `GraphicsDrawCommand`。`0018` 完整记录这一依赖裁剪与 state-local 接入修改。
- `love.graphics.draw` 和 `drawLayer` 的注册已切到原版 wrapper；平行 `LoveRuntime::graphicsDrawLayer` 已删除并由 API audit 禁止回归。Image/Canvas 的 command adapter 直接消费 wrapper 传入的对象与 Matrix4，覆盖 `draw(texture, Transform)`、`draw(texture, Quad, Transform)`、ArrayImage/array Canvas 的 `drawLayer` 及错误边界，不再重新解析 Lua 参数。
- Mesh、SpriteBatch、ParticleSystem、Text 和 Video 已经过原版公开 `w_draw` 选择 Drawable，但其 Dora backend 命令体仍暂时消费现有 Lua stack；这些实现分别归 W5-04/W5-05/W6-05 删除，不能据此宣称整个 Graphics binding 已完成迁移。
- 本切片完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、macOS universal Debug `liblove.a`、xmake `love` target 与 Dora Xcode Debug arm64 主目标通过。源码审计为 213 文件/111 hash/72 个 xmake 源；迁移差异与 vendored tree 核对一致。P5-50 与 W5-02 已关闭，下一门槛是 W5-03 Canvas wrapper 和 Graphics 状态栈。

### Graphics Canvas 原版 Lua wrapper

- `luaopen_canvas` 现直接注册 Love 11.5 Canvas 自有方法和继承的 Texture 方法，LoveRuntime 中 25 个平行 Canvas getter/setter/readback/mipmap 方法体及手写方法表已删除。`newImageData` 仍由原版 wrapper 解析 slice、mipmap 和 Rect，再调用 Dora Canvas 子类完成 RenderTarget readback并返回 state-local ImageData。
- `0019` 只把上游 `Canvas:renderTo` 的进程级 `Module::getInstance<Graphics>` 与 native RenderTargets 操作替换为当前 state 的 `GraphicsCanvasCommand`；callback 参数数量、错误传播和方法注册保持上游入口。Dora command 保存并恢复当前 Canvas/depth-stencil 引用和 backend target，回调失败后同样恢复。
- Runtime 新增 callback 参数、活动 Canvas、异常恢复和资源释放回归；完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、macOS universal Debug、xmake `love` 与 Dora Xcode Debug arm64 主目标通过。当前源码审计为 213 文件/110 hash/19 patch/73 个 xmake 源；干净顺序重放覆盖 32 个文件且 mismatch=0。P5-51 已关闭；W5-03 继续跟踪 Graphics 模块状态函数与 pass 顺序，不把 Canvas wrapper 完成等同于整个 Graphics 模块完成。

### Graphics transform/state stack 原版 wrapper

- `0020` 将 Love 11.5 的 `getStackDepth/push/pop/origin/translate/rotate/scale/shear/applyTransform/replaceTransform/transformPoint/inverseTransformPoint` wrapper 主体拆入 renderer-independent 单元。Lua 数字默认值、stack type 枚举、Transform 类型检查、`push(type, Transform)` 二参数重载与返回值均留在 wrapper；最终调用通过当前 State 的 `GraphicsStateCommand` 到 Dora 状态。
- LoveRuntime 中对应的 12 个平行 Lua binding 已删除；只保留没有 Lua 参数语义的状态栈保存/恢复 helper。Dora adapter 维护 affine transform 与 pixel scale，并保留奇异 inverse 的受控 Lua 错误边界，避免 C++ 异常越过 Lua C API。
- Runtime 新增 `push("transform", Transform)` 定向回归，并继续覆盖 transform/all 栈、DisplayState 选择性恢复、Canvas/Shader/Font 强引用、点变换与奇异逆变换。完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、macOS universal Debug、xmake `love` 与 Dora Xcode Debug arm64 主目标通过。当前源码审计为 215 文件/110 hash/20 patch/74 个 xmake 源；干净顺序重放覆盖 34 个文件且 mismatch=0。P5-52 已关闭，W5-03 下一切片迁移 DisplayState wrapper。

### Graphics 基础 DisplayState 原版 wrapper

- `0021` 把 `set/getColor`、`set/getBackgroundColor`、线宽/样式/连接方式和点大小共 12 个入口拆入 renderer-independent wrapper 单元；颜色 table/数值重载、alpha 默认值、枚举诊断与点大小约束留在 wrapper，Dora adapter 只保存所属 LoveRuntime 的状态。
- LoveRuntime 删除对应 12 个平行 Lua binding，注册表直接使用 `love::graphics::w_*`；状态继续进入既有 draw、primitive、push/pop 与 reset 路径，因此没有新建第二套 DisplayState。
- 既有 Runtime 用例覆盖颜色到 depth/cull/winding/stencil callback 及 `push("all")` 恢复；API parity 禁止旧 binding 回流。`0027` 迁移 stencil compare/value，修正旧手写实现禁用后返回 nil 的偏差，恢复 Love 11.5 的 `always, 0`；`0028` 迁移六种 stencil action、clear 重载和 callback，并在 callback 报错时先结束 backend stencil write 再重抛 Lua 错误。完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、xmake `love`、macOS universal `liblove.a` 与 Xcode Debug arm64 主目标通过；源码审计为 217 文件/110 hash/28 patch/75 个 xmake 源，干净顺序重放覆盖 36 个文件且 mismatch=0。P5-53～P5-60 已关闭，W5-03 继续迁移 Canvas 切换、clear 与 pass 顺序。

### Graphics Canvas target 原版 wrapper

- `0029` 把 Love 11.5 的 `setCanvas/getCanvas` 参数与返回值逻辑迁入已编译的 Canvas wrapper 单元，保留多 Canvas、table-of-targets、Array/Cube/Volume slice、mipmap、独立 depth-stencil Canvas 和临时 depth/stencil flags；Dora adapter 只校验所属 Runtime、handle、尺寸、mipmap/slice 与格式并提交 backend。
- LoveRuntime 的两套平行公开 binding 已删除；Canvas Lua Proxy 由 Love `StrongRef` 与 registry reference 继续保活，切换目标仍会终止进行中的 stencil write。原版 `getCanvas` 对仅 depth-stencil、无 color target 的状态返回 nil，旧 Dora 扩展返回 table 的偏差已移除并更新回归。
- Runtime Canvas/MRT/depth-stencil 与 API parity 通过；完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、xmake `love`、macOS universal `liblove.a` 与 Xcode Debug arm64 主目标均通过。源码审计为 217 文件/110 hash/29 patch/75 个 xmake 源，干净顺序重放覆盖 36 个文件且 mismatch=0。P5-61 已关闭，W5-03 下一切片迁移 clear/discard 与 pass 顺序。

### Graphics clear/discard 原版 wrapper

- `0030` 将 Love 11.5 的 broadcast color、逐 attachment color table、nil/空表跳过、布尔 clear 开关、stencil 整数和 depth 数值解析迁入 state-local Canvas command wrapper；Dora adapter 只构造 `GraphicsBackend::ClearRequest` 并提交。`discard` 的 table/boolean 默认值同样由原版入口解析，Dora 保留规范允许的 framebuffer invalidation no-op。
- LoveRuntime 的两套平行 binding 和仅服务旧 clear parser 的 clamp helper 已删除，注册直接指向 `w_clear/w_discard`。完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、xmake `love`、macOS universal `liblove.a` 与 Xcode Debug arm64 主目标通过；源码审计为 217 文件/110 hash/30 patch/75 个 xmake 源，干净顺序重放覆盖 36 个文件且 mismatch=0。P5-62 已关闭，W5-03 下一切片迁移 reset/flush 与 pass 顺序。

### Graphics reset/flush/present 原版 wrapper

- `0031` 将 Love 11.5 的 `reset/present/flushBatch` wrapper 入口迁入 state-local `GraphicsStateCommand`；Lua 注册直接使用 `w_reset/w_present/w_flushBatch`，LoveRuntime 中三套平行公开 binding 已删除。`reset` 继续复位同一套 Dora Graphics 状态和 backend，未建立第二份状态存储。
- `flushBatch` 保持可证明的同步点 no-op：LoveNode 每次 draw 已记录捕获完整状态的有序 Dora command，不存在 Love native stream batch。`present` 仍只允许在 Dora 驱动的 `love.draw` 帧内调用，作为兼容屏障且不结束/重开 pass、不交换窗口；真实 `beginFrame/endFrame` 仍由 `LoveRuntime::draw` 各执行一次。
- Runtime 覆盖帧内连续两次 `present`、帧外错误、reset 全状态恢复和 flush 顺序；API parity 固定原版 wrapper 注册并禁止旧 binding 回流。完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、xmake `love`、macOS universal `liblove.a` 与 Xcode Debug arm64 主目标通过；源码审计为 217 文件/110 hash/31 patch/75 个 xmake 源，31 个 patch 干净顺序重放覆盖 36 个文件且 mismatch=0。P5-63 与 W5-03 已关闭，下一阶段进入 W5-04 Drawable 高层类型迁移。

### Graphics Mesh 原版对象契约与 Lua wrapper

- 恢复 Love 11.5 的 `vertex.h/.cpp`、`Mesh` Type 和完整 `wrap_Mesh.cpp/.h`。`0032` 只把 Mesh native `Graphics/Buffer/Shader` 实现替换为可由嵌入 backend 实现的对象契约；`MeshUserdata` 真实继承 `love::graphics::Mesh`，CPU bytes/decoded attributes、attached Mesh 强引用、Texture 强引用、vertex map、draw range 和 Dora `MeshBuffer` cache 均属于该对象，不再维护平行 `MeshLoveType`。
- `luaopen_mesh` 现注册原版 20 个公开方法；table/Data vertex 写入、byte/unorm16/float 编解码、attribute step、vertex-map Data/table/vararg 重载、Texture 类型返回、draw mode/range 和异常边界均由上游 wrapper 解析。LoveRuntime 中原 20 个 Mesh Lua binding 及只服务它们的参数 helper 已删除；构造与 draw command 在 P5-65/P5-66 继续完成，整个 W5-04 仍须等待 SpriteBatch/ParticleSystem。
- UBSan 在原版无效 vertex-map/draw-mode 枚举诊断发现未初始化 enum 按值传递，`0033` 只为诊断路径设置合法初值，不改变合法输入。Runtime Mesh/Data/attachment/texture/GC/draw/instancing 回归、完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、xmake `love`、macOS universal `liblove.a` 与 Xcode Debug arm64 主目标通过。源码审计为 222 文件/112 hash/33 patch/78 个 xmake 源，33 个 patch 顺序重放覆盖 39 个文件且 mismatch=0。P5-64 已关闭，W5-04 下一切片迁移 Mesh draw command。

### Graphics Mesh draw command Matrix4 直通

- 原版 `w_draw` 负责选择 Drawable/Texture/Quad 重载并生成 `Matrix4`；`DoraLoveGraphics::draw` 识别真实 `love::graphics::Mesh` 后，直接将该 Matrix4 与当前 Graphics transform 合成，再调用 Dora Mesh backend 命令。普通 Mesh draw 不再从 Lua 参数栈重复辨认 Transform 或重解析数值参数。
- `drawInstanced` 暂无 Love 原版公开 wrapper，仍使用同一 Dora Mesh backend 命令，但只在该兼容入口解析 instance count 与标准 transform；普通 draw 与 instanced draw 共用几何展开、attribute attachment、shader instancing、缓存和提交逻辑，避免形成两套 renderer 行为。
- Runtime 新增 `graphics.draw(mesh, love.math.newTransform(...))` 回归，并保留数字 transform、Data Mesh、attachment、shader 与 instancing 覆盖；API parity 固定 Matrix4 直通，不允许退回 Lua stack 解析。Runtime/API parity、ASan+UBSan Runtime 1/1、xmake `love` 与 Xcode Debug arm64 主目标通过。P5-65 已关闭；W5-04 继续迁移 Mesh 构造 wrapper 和 SpriteBatch/ParticleSystem。

### Graphics Mesh 原版构造 wrapper

- `0034` 将 Love 11.5 `newStandardMesh/newCustomMesh/w_newMesh` 的重载判定、standard vertex 默认值与颜色量化、custom vertex format、table/Data、draw mode 和 usage 解析原样提取到已编译的 Mesh wrapper；它通过当前 Lua State 的 `GraphicsMeshCommand` 创建对象，不再访问 Love native Graphics singleton。
- `DoraLoveGraphics` 只实现四种原版构造签名，将已解析的 `Vertex`、`AttribFormat` 或 Data bytes 转成同一 `MeshUserdata` CPU storage；Lua 对象 push/release、custom table 的逐 attribute 写入和 flush 仍由原版 wrapper 管理。旧 `LoveRuntime::graphicsNewMesh` 及其平行 Lua 参数解析已删除。
- Runtime 既有 standard/custom/Data/count、非法 format/mode/usage、GC、draw 与 instancing 覆盖继续通过；API parity 固定 `w_newMesh` 注册并禁止旧构造 binding 回流。完整 standalone CTest 12/12、ASan+UBSan Runtime 1/1、xmake `love`、macOS universal `liblove.a` 与 Xcode Debug arm64 主目标通过；源码审计保持 222 文件/112 hash/78 个 xmake 源，patch 数增至 34，顺序重放覆盖 40 个文件且 mismatch=0。P5-66 已关闭；W5-04 下一步迁移 SpriteBatch/ParticleSystem。

### Graphics SpriteBatch 原版对象与方法 wrapper

- 恢复 Love 11.5 的 SpriteBatch Type、Drawable 对象契约及 15 个公开方法 wrapper；`SpriteBatchUserdata` 真实继承 `love::graphics::SpriteBatch`，Dora 继续持有 sprite CPU storage、Texture/attribute Mesh 强引用和渲染缓存，不再维护平行 Type 或手写 Lua 方法表。
- `add/set/addLayer/setLayer` 的 Quad/Transform/数值重载、1-based sprite index、0-based texture layer、颜色默认值与 8-bit 量化、draw range、buffer size、flush 和错误入口均由原版 wrapper 负责；adapter 只消费已解析的 Quad 与 Matrix4 并更新 Dora storage。`0035` 记录对象 backend 边界和共享 transform parser 调整。
- Runtime 与 API parity 定向覆盖 Transform add、颜色量化、对象注册和旧 binding 删除；源码审计为 225 文件/112 hash/58 个 wrapper/80 个 xmake 源。P5-67 已完成实现并通过 Runtime/API/源码/平台清单定向测试；完整平台验收与构造/draw 一并记入 P5-68。

### Graphics SpriteBatch 原版构造与 draw command

- `0036` 保留 Love 11.5 `newSpriteBatch(texture, size, usage)` 的 Texture、整数与 usage 枚举解析，只把最终创建路由到当前 Lua State 的 `GraphicsSpriteBatchCommand`。旧 `LoveRuntime::graphicsNewSpriteBatch` 及其平行参数解析已删除。
- 原版 `w_draw` 生成的 Matrix4 与当前 Graphics transform 在 `DoraLoveGraphics::draw` 中合成后直接送入 SpriteBatch backend；普通 draw 不再回读 Lua stack。方法与构造 wrapper、真实对象 Type 以及 draw command 因而形成一条完整路径。
- Runtime/API parity 与 standalone 全量 CTest 12/12、ASan+UBSan Runtime 1/1、xmake `love`、macOS universal `liblove.a` 和 Xcode Debug arm64 主目标均通过；36 个 patch 在干净 Love 11.5 tree 顺序重放覆盖 44 个修改文件，和 vendored tree 比较 mismatch=0。P5-68 已关闭；W5-04 下一步迁移 ParticleSystem。

### Graphics ParticleSystem 原版对象、方法与构造 wrapper

- 恢复 Love 11.5 的 ParticleSystem Type、Drawable/public 对象契约、完整方法 wrapper 与构造入口；`ParticleSystemUserdata` 真实继承上游对象接口。约 60 个平行 Lua binding、手写方法表、平行 Type 和旧构造函数已删除，`luaopen_particlesystem` 成为唯一对象注册入口。
- `0037` 把依赖 native Graphics/Buffer 与进程级随机状态的对象实现裁成 backend 契约。Dora 对象继续持有每实例模拟状态、Texture/Quad 强引用和 MeshBuffer cache；原版 wrapper 负责枚举、默认值、table/vararg、颜色/Quad、clone、生命周期和 Lua 错误边界。既有 `isEmpty/isFull` 扩展作为两个小 wrapper 保留，避免已有 Dora Love 项目回归。
- `newParticleSystem(texture, size)` 由原版入口解析后通过当前 Lua State 的 `GraphicsParticleSystemCommand` 创建；普通 draw 直接消费 `w_draw` 生成的 Matrix4 并与当前 Graphics transform 合成，不再回读 Lua 参数栈。该阶段 API parity 为 296 Graphics + 421 core，声明检查为 4168；后续 Shader wrapper 兼容别名使当前值增至 297 Graphics。
- standalone 全量 CTest 12/12、ASan+UBSan Runtime 1/1、xmake 双架构、macOS universal `liblove.a` 与 Xcode Debug arm64 主目标无新增告警通过；源码审计为 228 文件/112 hash/58 wrapper/82 个 xmake 源，37 个 patch 顺序重放覆盖 48 文件且 mismatch=0。P5-69/P5-70 与 W5-04 已关闭；下一阶段进入 W5-05 Text/Shader。

### Graphics Font 与 Text 原版对象/wrapper

- 恢复 Graphics `Font`/`Text` 的原版 Type、公开对象契约及 `wrap_Font.cpp`、`wrap_Text.cpp`。`FontUserdata` 现在真实继承 `love::graphics::Font`，14 个 Font 方法由原版 wrapper 解析；Dora 子类只提供 state-local handle 的 metrics、wrap、fallback、line-height、filter 与 DPI backend。
- `TextUserdata` 现在真实继承 `love::graphics::Text`。ColoredText、alignment、数字/Transform 矩阵、set/add/setf/addf、Font 引用和尺寸查询均进入原版 wrapper；旧十个 Text binding、十四个 Font binding、平行 Type 和 `graphicsNewText` 构造已删除。
- `w_newText` 只把最终构造路由给当前 Lua State 的 `GraphicsTextCommand`。原版 `w_draw` 产生的 Matrix4 直接进入 Text backend command，与当前 Graphics transform 合成后绘制 Dora layout runs，不再从 Lua stack 二次解析。
- `0038`、`0039` 可从干净 Love 11.5 顺序重放；该切片源码审计为 234 文件/112 hash/58 wrapper/86 个 xmake 源，39 个 patch 覆盖 56 个修改文件。standalone CTest 12/12、ASan+UBSan Runtime 1/1、xmake macOS 双架构/universal 与 Xcode Debug arm64 主目标无新增告警通过。

### Graphics Shader 原版对象与方法 wrapper

- 恢复 Love 11.5 `Shader` 的 Type、uniform metadata contract 与 `wrap_Shader.h`，并实际编译原版 `wrap_Shader.cpp`。`ShaderUserdata` 真实继承上游 Shader 接口；`getWarnings/send/sendColor/hasUniform` 与旧版兼容别名 `getExternVariable` 由同一 wrapper 注册，旧五个 Runtime 对象 binding 已删除。
- Dora concrete Shader 将 backend reflection 转换为上游 `UniformInfo`，原版 wrapper 负责 float/matrix/int/uint/bool/Data/Texture 参数解析；更新和 sampler 强引用再由对象送入所属 LoveRuntime 的 GraphicsBackend。编译、Love shader 转译、跨 renderer 诊断、uniform reflection 与实际 GPU submission 保持 Dora 唯一实现，不引入 Love OpenGL `ShaderStage`、进程级 current/default Shader 或第二套 renderer。
- `0040` 记录这一裁剪，并保留 Lua 5.5 的 int/uint 32 位范围校验、非 gamma-correct `sendColor` 标记和 Dora 异常转 Lua 错误。当前 API parity 为 297 Graphics + 421 core，声明检查 4168；源码审计为 237 文件/112 hash/58 wrapper/88 个 xmake 源。
- 从干净 Love 11.5 commit 顺序重放 40 个 patch，覆盖 60 个文件且 vendored 比较 mismatch=0。standalone CTest 12/12、ASan+UBSan Runtime 1/1、macOS arm64/x86_64 xmake、universal `liblove.a` 及 Dora Xcode Debug arm64 主目标无新增告警通过。W5-05 已关闭。

### Audio Source 原版对象与方法 wrapper

- 恢复 Love 11.5 的 `Filter.cpp`、`Source.cpp`、`wrap_Source.h`，实际编译原版 `wrap_Source.cpp`；`AudioSourceUserdata` 真实继承 `love::audio::Source`，`luaopen_source` 成为唯一 Source 方法注册入口，LoveRuntime 中 43 个重复 Source Lua 方法和手写方法表已删除。
- 原版 wrapper 继续负责 clone/play/pause/stop、时间单位、空间音频、queue、filter/effect 与 deprecated `getChannels` 的 Lua 语义；Dora concrete Source 只把这些对象操作送入所属 LoveRuntime 的 `AudioBackend`。SoLoud、AudioBus、应用级 listener、voice budget 与 Content 解码仍由 Dora 唯一持有，不引入 Love 的 OpenAL/SDL 音频设备。
- `0041` 增加 clone proxy 弱索引 hook，并保留 Dora 已验证的有限值、范围、Lua 5.5 `size_t` 队列边界和 `isStopped/isPaused` 兼容入口。当前 API parity 为 297 Graphics + 423 core，声明检查 4168；源码审计为 240 文件/112 hash/58 wrapper/91 个 xmake 源。
- standalone 全量 CTest 12/12、ASan+UBSan Runtime 1/1、macOS arm64/x86_64 xmake、universal `liblove.a` 与 Xcode Debug arm64 主目标无新增告警通过；`0041` 已在前 40 个 patch 后顺序应用，全部 patch 涉及的 vendored 文件比较 mismatch=0。W6-01 的代码实现已完成，Windows/Linux/Android/iOS 当前源码构建仍作为该项完整关闭及 W7-04/P6 的平台门禁。

### Video 与 VideoStream 原版对象/wrapper

- 恢复并编译 Love 11.5 的 `graphics::Video`、`wrap_Video.h/cpp/lua` 和 `video::wrap_VideoStream.h/cpp`。`VideoUserdata` 与 `VideoStreamUserdata` 分别真实继承原版对象契约，`luaopen_video/luaopen_videostream` 成为唯一对象方法注册入口；旧 Video/VideoStream 方法表、平行 Type、Lua Source 引用和手写 `graphicsNewVideo` 已删除。
- 原版 Video Lua helper 继续提供 `setSource/play/pause/seek/rewind/tell/isPlaying`，原版 `newVideo(file, settings)` constructor 继续处理 `audio`、无音轨错误和 `dpiscale`。底层构造仅经当前 Lua State 的 `GraphicsVideoCommand` 创建 Dora 视频纹理；Content-backed Ogg/Theora 解码、RGBA 上传、SoLoud Source 与 VideoNode 共享依赖仍由 Dora 唯一实现。
- `0042` 记录去除 native GL Video 资源和进程级 Graphics factory 的裁剪，并保留有限非负 seek、正有限 `dpiscale`、异常转 Lua 错误及跨 Runtime 对象拒绝。Runtime 新增 VideoStream/Source Proxy 身份、VideoStream 构造复用和逻辑/像素 DPI 尺寸验证。
- 当前 API parity 为 303 Graphics + 423 core，英中 TypeScript/Teal 声明检查 4192；源码审计为 245 文件/112 hash/58 wrapper/94 个 xmake 源。standalone CTest 12/12、ASan+UBSan Runtime 1/1、macOS arm64/x86_64 xmake、universal `liblove.a` 与 Xcode Debug arm64 主目标通过；`0042` 已在前 41 个 patch 后顺序应用且五个修改文件 mismatch=0。W6-05 的代码实现完成，Windows/Linux/Android/iOS 当前源码构建仍为完整关闭门禁。

### Graphics surface/status 查询 wrapper

- `0043` 从 Love 11.5 `wrap_Graphics.cpp` 提取 `getWidth/getHeight/getDimensions`、三项 pixel 查询、`getDPIScale`、`isActive/isCreated/isGammaCorrect` 十个无参数入口，保留原始返回语义，仅将 native Graphics singleton 替换为当前 Lua State 的 `GraphicsInfoCommand`。
- `DoraLoveGraphics` 从所属 Runtime/GraphicsBackend 提供虚拟 surface 尺寸和 active/created 状态；嵌入 surface 的逻辑单位与 RenderTarget 像素保持 1:1，DPI 为 1，gamma-correct 为 false。LoveRuntime 中对应十个 Lua closure、声明和 window 尺寸别名均已切除或改由 wrapper 注册。
- 当前源码审计为 247 文件/112 hash/58 wrapper/95 个 xmake 源；`0043` 已在前 42 个 patch 后顺序应用且两文件 mismatch=0。该切片 Runtime/API/source/platform manifest 通过，W5-06 继续迁移 capability/stats 与剩余构造/绘制入口。

### Graphics capabilities/stats 查询 wrapper

- `0044` 将 `getSupported/getTextureTypes/getImageFormats/getRendererInfo/getSystemLimits/getStats` 六个入口迁移到 state-local `GraphicsCapabilitiesCommand`；上游 wrapper 继续负责可选输出 table 的复用、字段写入和多返回值语义。
- `DoraLoveGraphics` 只提供 backend feature/format 查询、renderer 标识、系统限制和统计数据。LoveRuntime 中六个重复 Lua closure 及声明已删除，模块注册改为 wrapper 入口，不引入 Love 原生 OpenGL Graphics singleton。
- 当前源码审计为 249 文件/112 hash/58 wrapper/96 个 xmake 源；`0044` 已在前 43 个 patch 后顺序应用且两文件 mismatch=0。Runtime/API/source/platform manifest 定向验证通过；W5-06 下一切片为 primitives 与剩余构造/绘制入口。

### Graphics primitives wrapper

- `0045` 将 `points/line/rectangle/circle/ellipse/arc/polygon` 七个入口的 vararg、平面 table、彩色点 table、draw/arc mode、默认值及参数错误解析迁移到 state-local `GraphicsPrimitivesCommand`。
- `DoraLoveGraphics` 将解析后的顶点与形状请求送入既有 GraphicsBackend，并继续应用当前 transform、颜色、线型、点大小和 shader draw validation；LoveRuntime 中七个重复 Lua parser、声明和注册已删除。
- 当前源码审计为 251 文件/112 hash/58 wrapper/97 个 xmake 源；`0045` 已在前 44 个 patch 后顺序应用且两文件 mismatch=0。Runtime 新增 table/vararg、彩色点、mode 与错误路径回归，API/source/platform manifest 定向验证通过；W5-06 下一切片为 Image/Canvas/Quad/Shader/Font/print 构造入口。

### Graphics drawInstanced 与 Video Matrix 直通

- `0046` 在已拆分的原版 draw wrapper 中恢复 `drawInstanced(mesh, count, transform...)`，由 wrapper 完成 Mesh、count 和标准 Transform 重载解析；Dora adapter 直接接收 Matrix4 与实例数。
- Video 也与 Mesh/SpriteBatch/ParticleSystem/Text 一样直接消费 `w_draw` 解析出的 Matrix4，不再回读 Lua stack。最后一个 `LoveRuntime::graphicsDraw` 公共 parser 和 drawInstanced 特制 closure 已删除。
- 既有正数、零数、负数、per-instance attribute、hardware/fallback instancing 与 Video Transform 回归通过；`0046` 在前 45 个 patch 后重放且两文件 mismatch=0。源码审计仍为 251 文件/112 hash/58 wrapper/97 个 xmake 源。

### Graphics Quad 构造 wrapper

- `0047` 从原版 Graphics wrapper 提取 `newQuad`，保留 `Texture`、`layer + Texture`、`width/height`、`layer + width/height` 四类重载及 1-based layer 转换；Quad 继续直接使用上游对象和对象方法 wrapper。
- wrapper 通过当前 State 的 `GraphicsInfoCommand` 验证 Graphics 已创建，并从上游 Texture 接口读取 Image/Canvas 尺寸；LoveRuntime 的平行 Texture 类型判断、backend handle 查询和构造 parser 已删除。
- 当前源码审计为 253 文件/112 hash/58 wrapper/98 个 xmake 源；`0047` 在前 46 个 patch 后顺序应用且两文件 mismatch=0，Runtime/API/source/platform manifest 定向验证通过。

### Graphics Canvas format 查询 wrapper

- `0048` 将 `getCanvasFormats([readable], [result])` 并入 state-local capabilities wrapper，保留 boolean 首参、可选输出 table 复用和完整字段写入语义；Dora adapter 只返回 readable/non-readable backend 支持结果。
- LoveRuntime 的参数解析、table 构造和格式遍历已删除；`0048` 在前 47 个 patch 后重放且两文件 mismatch=0。源码审计仍为 253 文件/112 hash/58 wrapper/98 个 xmake 源，Runtime/API 定向回归通过。

### Graphics Canvas 构造 wrapper

- `0049` 提取 Love 11.5 的 `newCanvas` parser，保留默认 surface 尺寸、layer 数字重载、settings 字段白名单、dpiscale/MSAA/format/type/readable/mipmaps 枚举与错误语义；LuaJIT 数值转整数行为在 Lua 5.5 下显式保留。
- `GraphicsCanvasCommand::newCanvas` 接收上游 `Canvas::Settings`，Dora adapter 只负责像素尺寸换算、平台 format capability、RenderTarget 创建和 Dora handle 包装。Canvas 的 DPI 语义恢复为上游规则：构造宽高是逻辑尺寸，pixel dimensions 为逻辑尺寸乘 dpiscale。
- 当前源码审计为 255 文件/112 hash/58 wrapper/99 个 xmake 源；`0049` 在前 48 个 patch 后重放且三文件 mismatch=0。Runtime 已覆盖 2D/array/cube/volume、DPI、MSAA、mipmap、readable/depth 与失败路径。

### Graphics Shader 当前状态 wrapper

- `0050` 将 `setShader/getShader` 的 nil/Shader 参数与 Proxy 返回迁移到 state-local `GraphicsShaderStateCommand`。Dora adapter 只校验 Runtime/handle、切换 backend shader 并保存上游对象强引用。
- 旧 LoveRuntime closure 与 `_graphicsShaderReference` Lua registry 所有权已删除；push/pop/reset 仅使用 Love `StrongRef` 保存和恢复 Shader，避免同一对象同时由两套生命周期机制持有。
- 当前源码审计为 257 文件/112 hash/58 wrapper/100 个 xmake 源；`0050` 在前 49 个 patch 后重放且两文件 mismatch=0，既有 shader selection、push/pop、GC 与绘制回归通过。

### Graphics Font 当前状态 wrapper

- `0051` 将 `setFont/getFont` 迁移到 state-local `GraphicsFontStateCommand`，由原版 wrapper 完成 Font Type 检查与 Proxy 返回。Dora adapter 只校验对象归属、保存 handle/StrongRef，并在 get 时按需创建默认字体。
- LoveRuntime 的两个公开 closure 已删除；push/pop/reset 继续通过同一 StrongRef 保存恢复 Font，不增加 Lua registry 引用。
- 当前源码审计为 259 文件/112 hash/58 wrapper/101 个 xmake 源；`0051` 在前 50 个 patch 后重放且两文件 mismatch=0，Font selection、默认 Font、push/pop、GC 与 Text/print 现有回归通过。

### Graphics print/printf wrapper

- `0052` 将 `print/printf` 的 ColoredText、可选 Font、数字/Transform 变换、wrap 与 alignment 参数解析迁移到 state-local `GraphicsPrintCommand`；LoveRuntime 不再维护对应的公开 Lua parser。
- Dora adapter 只校验 Font 归属、合成当前 Graphics transform，并通过现有 LoveTextLayout 将已解析文本分段提交 backend。负数 wrap 按 Love 11.5 先钳制为 0：宽于限制的非空格字形会被逐个跳过，空格仍保留。
- 当前源码审计为 261 文件/112 hash/58 wrapper/102 个 xmake 源；`0052` 在前 51 个 patch 后顺序应用且两文件 mismatch=0。Runtime 覆盖 ColoredText、Font、数字/Transform、换行、alignment 与负数 wrap；API/source/platform manifest 定向验证通过。

### Graphics Shader 构造与校验 wrapper

- `0053` 将 `newShader/validateShader` 的 boolean、单/双源码、FileData、Content 文件路径、顶点/像素入口识别及 validation 返回值迁移到 state-local `GraphicsShaderConstructorCommand`。文件访问通过当前 Lua State 的 Filesystem 模块，不回退到宿主 stdio。
- Dora adapter 只调用既有 shader 转译/编译/反射 backend，创建上游 Shader 对象或返回编译诊断。`gles` 参数保留 Love API 契约；实际 renderer 方言仍由 Dora/bgfx 跨平台编译链决定。缺失的短文件名按 Love 原版参数解析阶段直接抛错，而不是伪装成一次编译失败。
- 当前源码审计为 263 文件/112 hash/58 wrapper/103 个 xmake 源；`0053` 在前 52 个 patch 后顺序应用且两文件 mismatch=0。Runtime 覆盖字符串、FileData、Content 文件、单/双 stage、编译失败、缺失文件与对象生命周期；API/source/platform manifest 纳入新 wrapper。

### Graphics Font 构造 wrapper

- `0054` 将 `newFont/newImageFont/setNewFont` 的 Rasterizer 判断、`love.font` 转换和当前 Font 设置迁移到 state-local `GraphicsFontConstructorCommand`。TrueType、ImageFont 与 BMFont 都只把已解析 Rasterizer 交给 Dora adapter。
- Graphics backend 新增内存字体字节、逻辑字号和 DPI 接口；LoveNode 通过 FontManager/TrueTypeFile 创建资源，不落地临时文件。无参数或单个数字的默认 Font 在 wrapper 内走 FontCache 快路径，避免每次 `newFont(size)` 重复解析完整默认 CJK 字体；Lua 5.5 数字仍显式保留 LuaJIT 截断语义。
- 当前源码审计为 265 文件/112 hash/58 wrapper/104 个 xmake 源；`0054` 在前 53 个 patch 后顺序应用且两文件 mismatch=0。Runtime 覆盖默认/文件/Rasterizer、BMFont、ImageFont、setNewFont、DPI、GC 和 50 轮资源 soak，耗时保持约 7 秒而非未优化路径的 104 秒。

### Graphics Image 构造 wrapper

- `0055` 将 `newImage/newArrayImage/newCubeImage/newVolumeImage` 的 ImageData、CompressedImageData、FileData/Content、settings、DPI、mipmap、array/cube/volume 形式解析迁移到 state-local `GraphicsImageConstructorCommand`。wrapper 从当前 Lua State 获取 `love.image` 与 `love.graphics`，不使用进程级 Module singleton。
- Dora adapter 只接收已验证的上游 `Image::Slices` 与 `Image::Settings`，完成 RGBA8 或压缩 mip/slice 上传、Dora handle 创建和上游 Image 元数据同步。旧 filename 快捷创建、重复 cube/volume 拆分、DPI 与 layered parser 已从 LoveRuntime 删除；字符串路径必须先通过 Dora Content 和 `love.image` 解码。
- 当前源码审计为 267 文件/112 hash/58 wrapper/105 个 xmake 源；`0055` 的反向应用校验与两文件逐内容匹配通过。Runtime 覆盖完整 3-level DXT1 链、truthy boolean flag、Content 路径、DPI、显式/自动 mip、array/cube/volume、资源释放和 500 轮 state lifecycle；standalone CTest 12/12、macOS arm64 xmake、universal `liblove.a` 与 Xcode Debug arm64 主目标通过，API/source/platform manifest 定向验证通过。

### Thread/Channel 与截图 wrapper

- `0056` 恢复 Variant、Threadable、Channel、LuaThread、ThreadModule 和三个原版 wrapper。`DoraLoveThreadModule`、`DoraLoveLuaThread`、`DoraLoveChannel` 只适配既有 ThreadWorker/ThreadChannel；公开方法表、Type/Threadable 继承、命名 Channel identity、`performAtomic` 与 `threaderror` 对象身份由 Love 对象层负责。
- 跨 state 参数只复制 nil/boolean/number/string/Data/ImageData/table/Channel 快照，拒绝 Transform 等其它对象，避免把父 state 资源指针插入 worker。worker 仍通过 Dora Content 请求泵读文件，close 仍负责取消、唤醒和 join。
- `0057` 把 `captureScreenshot(function|string|Channel)` 与 PNG/TGA 后缀解析移到 state-local wrapper。Dora 继续持有帧末 readback、weak/generation token；完成时构造上游 ImageData，再回调、推入同一 Channel 对象或经 ImageData encoder/Content 保存。
- 当前源码审计为 279 文件/117 hash/58 wrapper/112 个 xmake 源；两个 patch 反向应用校验通过。macOS standalone Runtime 覆盖嵌套 table、Data/ImageData/Channel、非法跨 state 对象、错误映射、restart/close、截图 callback/PNG/TGA/Channel/拒绝路径；API/source/platform manifest、xmake arm64 与 ASan/UBSan 已通过。五平台当前源码运行矩阵仍归阶段门槛，不以历史 Thread 功能证据替代。

### System、Timer 与 Event wrapper

- `0058` 恢复 System/Timer 原版模块 wrapper。`DoraLoveSystem` 只转接现有 SystemBackend；`DoraLoveTimer` 只读取所属 Runtime 的 steady clock、delta、FPS 与 frame average，旧模块方法表和 Lua parser 已删除。
- `0059` 恢复 Message/Event 对象层、原版 C wrapper 与 `wrap_Event.lua` 的公开 `poll` 迭代器。`DoraLoveEvent` 把 Message 转换到既有实例 FIFO，宿主自动派发、restart/close、userdata 保活和非阻塞嵌入式 wait 仍由 LoveRuntime 控制，不导入 SDL Event backend。
- 当前源码审计为 288 文件/117 hash/58 wrapper/117 个 xmake 源；`0058`、`0059` 反向应用校验通过。API parity 为 303 Graphics + 424 core，四份声明 4192 项；Runtime 与 source/platform manifest 定向验证通过。W6-02 尚未关闭，下一切片为 Window/Input，完整 sanitizer 与五平台当前源码矩阵仍按阶段门槛执行。

### Window wrapper

- `0060` 恢复 Window 常量、WindowSettings 和完整原版 wrapper；`DoraLoveWindow` 只实现虚拟 surface 的尺寸、状态、位置、图标引用与宿主能力边界。Dora 仍唯一拥有宿主窗口、RenderTarget、swapchain 和 present，未引入 SDL Window backend。
- 旧 30 个 Window Lua parser/closure 已删除，`getWidth/getHeight/getDimensions` 仅作为 Love 11.5 兼容别名追加到原版模块表。`close/minimize/maximize/restore/setPosition/showMessageBox/requestAttention` 保留原版 API 入口，不再作为声明缺口；前五项只维护虚拟表面状态，`showMessageBox` 不显示对话框并返回明确占位结果，`requestAttention` 为无操作占位，均不得记作宿主能力已实现。
- 原版 settings 使用 Lua truthy boolean 规则，定向回归已替换旧手写 binding 的强 boolean 限制。当前源码审计为 291 文件/117 hash/58 wrapper/119 个 xmake 源，60 个 patch；API parity 为 303 Graphics + 427 core，四份声明 4220 项，Runtime/source/platform manifest 已通过。W6-02 下一切片为 Input。

### Keyboard wrapper

- `0061` 将原版 Keyboard wrapper、Key/Scancode 常量表作为独立构建源接入；`DoraLoveKeyboard` 只读取所属 Runtime 的按键集合，并调用 Dora KeyboardBackend 完成布局映射、IME 矩形和屏幕键盘查询。
- 旧九个手写 Keyboard parser/closure 已删除。`setKeyRepeat` 恢复 Love 11.5 的严格 boolean 参数，不再保留旧兼容层的数字 truthy 扩展；文本矩形的有限值与非负尺寸仍在 backend 边界校验。
- 当前源码审计为 292 文件/117 hash/58 wrapper/121 个 xmake 源，61 个 patch；Runtime/API/source/platform manifest 已通过。W6-02 下一切片为 Mouse/Cursor。

### Mouse/Cursor wrapper

- `0062` 恢复原版 Cursor Type/Object wrapper 与完整 Mouse 模块 wrapper；`DoraLoveMouse` 只提供所属 Runtime 的位置、按钮、可见性、grab/relative 状态及 Dora 宿主 cursor backend，不引入 SDL Mouse singleton。
- 自定义 Cursor 继续从上游 ImageData 参数和 hotspot parser 进入，backend 边界统一转换 RGBA8；系统 Cursor 按 Runtime 缓存，当前 Cursor 与缓存都用 Love `StrongRef` 保持对象身份和生命周期，不再维护平行 Lua registry 引用。
- 旧 Mouse/Cursor 手写 parser、方法表和 Type 注册已删除。当前源码审计为 297 文件/117 hash/58 wrapper/124 个 xmake 源，62 个 patch；Runtime/API/source/platform manifest 与 `0062` 干净正向重放已通过。W6-02 下一切片为 Touch。

### Touch wrapper

- `0063` 恢复 Touch 抽象模块与原版三方法 wrapper；`DoraLoveTouch` 只把所属 Runtime 的活动触点快照映射为上游 `TouchInfo`，lightuserdata ID、参数错误和返回表仍由原版 wrapper 负责。
- 旧三个 Touch parser/closure 已删除，Dora 事件路由、节点坐标和触点来源保持不变，不引入 SDL 全局 Touch 列表。当前源码审计为 299 文件/117 hash/58 wrapper/125 个 xmake 源，63 个 patch；Runtime/API/source/platform manifest 与 `0063` 干净正向重放已通过。W6-02 下一切片为 Joystick。

### Joystick wrapper

- `0064` 恢复 Joystick Type/Object、常量表与模块/对象原版 wrapper；`DoraLoveJoystick` 和 `DoraLoveJoystickModule` 只适配所属 Runtime 的控制器状态、mapping 与振动 backend，不引入 SDL Joystick singleton。
- 旧模块六方法、对象二十方法、手写 Type/`__eq` 和 parser 已删除。对象由 Runtime 连接表持有，原版 Proxy 保证重复查询、事件参数和断连对象 identity；mapping 文件输入继续经 state-local Filesystem/Content。
- 当前源码审计为 304 文件/117 hash/58 wrapper/128 个 xmake 源，64 个 patch；Runtime/API/source/platform manifest 与 `0064` 干净正向重放已通过。W6-02 实现切片完成，下一步进入 W6-04 Physics。

### Physics backend-neutral 基类

- `0065` 先恢复 Love 11.5 原版 Body/Shape/Joint Type、枚举与常量表，现有 Dora handle 对象直接继承这三个上游基类，删除对应平行 Type；PlayRho backend、handle 和对象父子 StrongRef 均保持不变。
- 只接入 `modules/physics` 顶层六个 backend-neutral 文件，源码/构建审计继续显式拒绝 `modules/physics/box2d` 与 Box2D 依赖。当前源码审计为 310 文件/117 hash/58 wrapper/131 个 xmake 源，65 个 patch；Runtime/source/platform manifest 与干净 patch 重放已通过。W6-04 下一切片为 World/Body wrapper contract。

### Physics Body wrapper

- `0066` 恢复 Love 11.5 原版 `wrap_Body`，并把 Body/World 扩展为不依赖 Box2D 的虚接口；`PhysicsBodyUserdata` 只负责把调用转交给所属 Runtime 的 PlayRho backend。
- 旧 Body 手写 Lua 方法表和 57 个 parser/closure 已删除。原版 wrapper 现统一提供变换、力学状态、`getWorld/getFixtures/getJoints/getContacts/isTouching`、user data 与 deprecated 别名；World、Fixture、Joint、Contact 后续仍按独立切片迁移。
- Joint 对象表补齐 Runtime 强引用和失效清理，Body 级联销毁不会留下可枚举的无效 Joint。Runtime 定向覆盖对象关系、接触、user data、deprecated 别名和原版 destroyed 语义。
- 当前源码审计为 314 文件/117 hash/58 wrapper/132 个 xmake 源，66 个 patch；API parity 为 303 Graphics + 427 core，四份声明 4296 项。standalone CTest 12/12、`0066` 反向/正向与 Love 11.5 干净源码五文件重放通过。

### Physics World wrapper

- `0067` 恢复原版 World method table 和 parser，补齐 `translateOrigin/isLocked`、Body/Joint/Contact 计数与枚举、deprecated list 别名；World/Body/Joint/Contact 对象关系均由所属 Runtime 的 Love Proxy 表维持。
- `setContactFilter/getContactFilter` 继续按既定设计从公开表排除：它依赖旧 Box2D 回调模型，Dora 仍使用 Fixture filter、16 位 groupIndex、contact callback 与 PlayRho ghost/单面 Edge 规则。
- Runtime 定向覆盖更新期间 locked 状态、origin 平移、计数/列表、接触生命周期和第二次 destroy 的原版错误语义。当前源码审计为 324 文件/117 hash/58 个未修改 wrapper/137 个 xmake 源，68 个 patch；API 303+427、声明 4296。W6-04 下一切片为 Shape 与 Joint 家族。

### Physics Fixture / Contact wrapper

- `0068` 恢复 Love 11.5 Fixture、Contact 的原版方法表；Fixture 的过滤规则继续由 Dora PlayRho backend 实现，`groupIndex` 保持有符号 16 位。
- Contact 从早期 Dora 自定义 `isValid` 收敛到 Love 正式 `isDestroyed`；四份 TypeScript/Teal 定义和运行时测试同步更新。
- Fixture userdata 直接继承 backend-neutral `Fixture`，Contact 直接继承 `Contact`。Runtime 在 `lua_close` 前释放物理对象强引用，保证其 `love::Reference` 在有效 State 上析构。
- 当前 standalone CTest 12/12、ASan 双 State 500 次生命周期循环、macOS arm64 xmake 构建均通过；`0068` 反向校验、干净基线正向应用及逐文件对比通过。

### Physics Shape wrapper

- `0069` 恢复 Love 11.5 Shape 基础与 Circle/Polygon/Edge/Chain 的原版方法表语义，并把几何查询、ray cast、AABB、mass、圆形变更和 ghost vertex 操作转交给 state-local PlayRho backend。
- 现有单一 `PhysicsShapeUserdata` 继续保存 Dora handle，但直接继承 backend-neutral `Shape`；原版 wrapper 负责 Lua 参数、1-based child/vertex 索引和返回值，旧 `LoveRuntime::physicsShape*` parser 已删除。
- `ChainShape:getChildEdge` 保留 loop 与外部 previous/next ghost topology，失败路径释放新建 Edge 的 Love/Dora 引用；Shape 新增接口同步进入英中 TypeScript/Teal 声明。
- 当前源码审计为 326 文件/117 hash/58 个未修改 wrapper/138 个 xmake 源，69 个 patch；API parity 303+427、声明 4324。standalone Runtime、源码/API/平台清单、macOS arm64 xmake 与 Dora Xcode Debug 主目标通过；`0069` 反向校验、干净基线正向应用及逐文件对比通过。

### Physics Joint wrapper

- `0070` 恢复 Joint 公共接口以及 Distance、Revolute、Prismatic、Weld、Friction、Rope、Pulley、Wheel、Mouse、Motor、Gear 十一个子类型的方法表与参数解析；Dora 的单一 Joint userdata 继承 backend-neutral `Joint`，具体约束操作仍转交 state-local PlayRho backend。
- wrapper 保留 Love 的 subtype `type/typeOf`、deprecated alias、关系对象和任意 Lua user data 语义；销毁统一进入 `destroyPhysicsJointObject`，释放 Dora handle、对象索引和关联引用，重复销毁按 Love 语义报错。
- 旧 `LoveRuntime::physics*Joint*` parser 和手写方法表已删除；当前源码审计为 328 文件/117 hash/58 个未修改 wrapper/139 个 xmake 源，API parity 303+427、声明 4324。standalone CTest 12/12、ASan CTest 12/12、源码/API/平台清单、macOS arm64 xmake 与 Dora Xcode Debug 均通过；Android NDK 21 `<cmath>` 依赖已补齐，五平台 Physics 运行 workflow 后续已完成。

### 五平台当前源码构建

- macOS arm64 xmake 静态库和 Dora Xcode Debug 主目标通过。
- iOS arm64 真机、arm64/x86_64 Simulator xmake 静态库通过。
- Android NDK 21 的 arm64-v8a、armeabi-v7a、x86_64 xmake 静态库通过；构建暴露的 `ImageData.cpp` `<cmath>` 直接依赖由 `0071` 修复。
- Linux x86_64 使用 Zig toolchain 交叉编译通过。
- Windows x86_64 使用 Zig/MinGW xmake 静态库通过；同时完整 CMake 交叉构建产出 Runtime、PlayRho ghost topology、SoLoud filter/voice budget 四个测试可执行文件。LuaSocket 与 Love xmake 已把 `mingw` 归入 Windows 源码分支，不再误编译 `usocket.c`。
- 以上是编译证据；除 macOS standalone/workflow 外，不替代 Windows/Linux/Android/iOS 的实际运行、物理设备和人工游戏验收。

### 非 macOS 当前源码运行验收

- Windows 11 VM 以 MSVC 19.51/SDK 10.0.26100 原生运行四项 CTest，并在登录用户交互桌面明确使用 Direct3D 11/12，通过两代 Thread restart、CompressedImage、Ogg/Theora VideoNode、十三场景高级 Graphics、非二维 sampler、十一 Joint Physics、双 LoveNode 隔离与 System workflow。
- Ubuntu 26.04 ARM64 VM 以 Xvfb/Mesa llvmpipe OpenGL ES 3.0 从标准 `Script.Dev.Entry` 启动当前 ELF，通过 Thread/Video、Mouse/Cursor、Canvas readback、PlayRho Physics 与十三场景 Graphics workflow。Xvfb 与 dummy audio 不计作真实 GPU、物理输入或可听音频证据。
- Android 14 / API 34 arm64 AVD 从 APK assets 冷启动，通过双实例、十三场景 OpenGL ES Graphics、完整 Physics、两代 Thread、Ogg/Theora VideoNode、系统单触/双触点、键盘与 IME workflow；真机手势、物理键盘/手柄、触觉、麦克风和可听输出仍属人工验收。
- iPhone 17 / iOS 26.5 Simulator 以 arm64/x86_64 universal 产物安装运行，通过双实例、十三场景 Metal Graphics、完整 Physics、两代 Thread、Ogg/Theora VideoNode、Canvas/readback、MSAA、CompressedImage、SoLoud 和 AVAudioSession workflow；真机物理 I/O 仍属人工验收。
- 固定官方兼容快照现为 238 pass/0 fail/53 skip。上述非 macOS 证据是虚拟机/模拟器运行证据，不将注入输入、dummy audio 或软件渲染扩大为真实设备体验。

### macOS 完整运行验收与关闭期物理生命周期

- 最终 Debug arm64 Dora 进程在 Metal、单 Web IDE compiler 和 `DORA_VIRTUAL_CONTROLLER=1` 下完成 `MacOSIntegrationWorkflowSuiteTests.mjs` 36/36；覆盖声明/语言服务、TS/Teal/Yue 源映射、热重载、Dora 2D/3D/TIC-80/NVG/ImGui 回归、VideoNode、SoLoud、Thread、Content、Canvas/Stencil/像素读回、Image/Font、输入、PlayRho、Shader、SpriteBatch、Window 与 Wireframe。
- 视觉证据用例统一在新建 Canvas 完成一个 host frame 后取证，Canvas、Stencil、Mesh/Depth 三张 Metal 截图均通过；这避免把首帧 GPU 资源提交时序误判为 stencil 计算失败，Canvas 直接像素读回仍独立验证模板结果。
- 原版 wrapper 兼容回归同步修正两项旧自写 parser 假设：2D `Canvas:newImageData` 忽略 slice 参数，以及 `Image` 的 `mipmaps` setting 使用 Lua truthy boolean；非法 mipmap 等真实错误路径仍保留拒绝测试。
- Physics workflow 首次完整退出暴露关闭期 EndContact 回调访问正在清空的 Fixture 对象表。Runtime 现在在对象 teardown 前解除每个 World 的 callback，并在 query/raycast/contact 路径同时检查 registry reference 与 concrete object；修复后 Physics workflow 通过且 Dora 进程继续运行。
- 分别以新进程运行 Physics workflow 和 Dora 既有功能回归后发送 `SIGINT`，两者均干净退出。重建 Dora 后再次连续运行全部 36 项 workflow 并退出，同样无 `Object` 引用计数告警；此前单次不可复现的长序列告警由该复测关闭。
- 最终 standalone 普通 CTest 12/12、ASan+UBSan CTest 12/12、xmake `love`、Xcode Debug arm64、规范总补丁从固定 Love 11.5 commit 重放并逐一比对 324 个文件全部通过。

### 选定 Love 12 API 的前向兼容切片

- `0072` 在固定 Love 11.5 子集上增加 `perlinNoise/simplexNoise`、`openFile`、`getTextureFormats` 和高层 stencil mode wrapper；Simplex 1D～4D 与双精度实现固定取自 Love main commit `48b5e130…`。这不是整体切换到未发布 Love 12，也不导入其 SDL、renderer、filesystem 或 Lua 环境。
- `newTextBatch` 直接注册到已经迁移的上游 `w_newText`，继续返回现有 Text 对象；`getDistance` 则纠正此前分类，它是 Love 11.5 既有 API，Lua parser 进入 state-local PlayRho Fixture backend 并返回距离及两个 witness point。
- Dora-owned adapter 继续负责 Content I/O、bgfx texture capability、stencil render state 和 PlayRho 距离计算。`openFile` 不开放宿主文件旁路；compute-write/shader-atomic 格式在 Dora 无对应能力时明确为 false；stencil mode 纳入 `push("all")/pop/reset`。
- 当前 parity 为 303 Graphics + 430 core，英中 TypeScript/Teal 为 4356 method checks；官方固定子集新增七个用例组后为 238 pass/0 fail/53 skip。源码审计为 328 文件、116 个未修改上游 hash 和 58 个 wrapper；修改后的 vendored 文件由 Git 历史维护，不再同步生成 patch 快照。

## 回退策略

- 每个模块族使用独立提交，先新增上游路径和测试，再切换默认，最后删除旧 binding。
- 切换提交出现兼容下降时，回退该模块，不回退已完成的 Module Context 或其它模块。
- old/new 开关只能存在于测试构建，并在对应模块删除旧实现后移除。
- 不允许用 Lua 层 monkey patch 长期掩盖 wrapper/backend 契约错误。
- 上游 patch 引起平台构建问题时，优先回退 patch 并恢复 Dora adapter，不直接修改未记录的 vendored 文件。

## 风险与控制

| 风险 | 控制措施 |
| --- | --- |
| 上游 Module singleton 污染多实例 | W1 先完成 state-local context，设源码审计门禁 |
| 恢复完整源码导致体积和构建时间上涨 | 按模块恢复依赖闭包，保持独立 xmake target 和 dead-strip |
| 上游类型与 Dora handle 双重所有权 | 每类对象先写所有权图和唯一 release 入口测试 |
| wrapper 正确但 backend 语义不足 | 保留模块级像素/状态/音频对比，不把 API parity 当运行验收 |
| 大规模一次替换导致无法定位回归 | 严格按 W3～W6 模块族和子阶段提交 |
| Lua 5.1/LuaJIT 假设重新进入 | 编译审计和 Lua 5.5 compatibility patch 清单持续门禁 |
| 平台实现被上游模块重新接管 | 禁止 OpenGL context、OpenAL device、SDL window/main 和 stdio fallback 进入发布构建 |

## 完成定义

迁移只有同时满足以下条件才算完成：

- 运行时公开 `love.*` API 主要由 Love 11.5 上游 wrapper 注册。
- 多个 LoveNode 的模块实例、对象和 Lua 状态完全隔离。
- Dora 仍唯一拥有主循环、窗口、bgfx、SoLoud、Content 和平台事件。
- `LoveRuntime.cpp` 不再维护已迁移模块的重复参数解析和方法表。
- 英中 TypeScript/Teal 定义、API parity 和实际 wrapper 同步。
- 五平台构建、运行工作流、Sanitizer 和固定游戏语料不低于迁移前基线。
- 所有上游修改均有可重复应用的最小 patch 和来源记录。
