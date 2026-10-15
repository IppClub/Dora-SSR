# Dora Love2D 整合设计

本文定义 Dora 引擎整合 Love2D 核心源码和 `love.*` API 的最终架构边界。实现目标不是在 Dora 中再嵌入一套 LuaJIT，也不是用 Lua 脚本近似模拟少量 Love2D API，而是复用 Love2D 上层模块与行为，在 Dora 的 Lua 5.5、渲染、音频、输入和文件系统之上提供可多实例运行的纯 Love 环境。

分阶段任务、状态和验收证据记录在 [Dora Love2D 整合开发进度](./love2d-integration-progress.md)。
上游 Lua wrapper 复用、按 Lua State 隔离模块实例及现有 Dora binding 迁移方案记录在 [Dora Love2D 上游 Wrapper 复用与迁移计划](./love2d-upstream-wrapper-migration.md)。
面向使用者的运行说明、逐模块兼容边界与 Lua 版本限制记录在[公开 Love2D 指南](../docs/tutorial/50.Using%20Nodes/13.using-love2d.mdx)，公开页必须和本设计及进度表同步更新。

## 最终决策

| 项目 | 决策 |
| --- | --- |
| Lua 实现 | 全引擎只链接 Dora 现有 Lua 5.5 |
| Lua 状态 | 每个 `LoveNode` 创建并拥有独立 `lua_State` |
| Love API | Love 状态只公开标准 Lua 库和 `love.*` |
| Dora API | 不向 Love 状态注册 `Dora`、`DoraHost`、`nvg` 或 `ImGui` |
| 多实例 | 每个 `LoveNode` 的 `_G`、`package.loaded`、回调、资源和 GC 完全隔离 |
| 生命周期 | Dora 驱动 Love 的加载、更新、绘制、输入与销毁，不允许 Love 接管宿主主循环 |
| 渲染 | Love 使用 Dora/bgfx 后端绘制到实例自己的渲染目标，再作为 Dora 节点合成 |
| 语言工作流 | TS、Yue、Teal 继续由 Dora 工具链转译为 Lua 5.5，再加载到目标 Love 状态 |
| 兼容定位 | 目标是基于 Lua 5.5 的 Love2D API/源码兼容，不承诺 LuaJIT 二进制兼容 |
| 首个基线 | 固定 Love 11.5 作为首个移植和测试基线，不直接跟随上游开发分支 |

这个设计沿用 `TIC80Node` 的嵌入模式：宿主节点拥有独立运行时，Dora 负责帧调度、输入、音频和最终画面合成。与 TIC-80 不同，Love 图形后端应直接提交 Dora/bgfx 渲染命令，不采用每帧从 CPU framebuffer 上传完整纹理的路径。

## 目标

- 在 Dora 场景中通过 `LoveNode` 加载和运行 Love 项目。
- 同时创建多个 Love 实例，实例之间不共享 Lua 全局变量或模块状态。
- Love 项目保持标准 `love.load()`、`love.update()`、`love.draw()` 等写法。
- Love 项目不知道 Dora 宿主的存在，不要求调用 Dora 专属桥接 API。
- 尽量保留 Love 上层对象、Lua binding、回调和模块语义。
- 用 Dora 的跨平台后端替换 Love 对窗口、渲染、音频、输入和操作系统的直接控制。
- 保留 Dora Web IDE、TypeScript、YueScript、Teal、诊断和源码映射能力。
- 支持可靠的启动失败、运行时错误、销毁和完整重启。

## 非目标

首版不以以下能力为目标：

- LuaJIT `ffi`、`jit` 和 LuaJIT 专有行为。
- 加载 Lua 5.1、LuaJIT 或其他版本生成的预编译字节码。
- 加载面向 Lua 5.1 ABI 编译的第三方原生 Lua 模块。
- 从 Love 脚本直接访问 Dora 场景树或其他 Dora Lua API。
- 让 Love 控制 Dora 的应用主循环或直接拥有操作系统 swapchain。
- 在不同原生线程中并发执行多个 LoveNode 的主 Lua 回调。
- 一次性承诺 `love.thread`、Video 的所有平台边缘行为完全等同上游；主体 API 接入后仍按平台矩阵逐项验收。

独立 `lua_State` 是运行环境隔离手段，不是进程级安全沙箱。Love 代码仍与 Dora 运行在同一进程，所有原生绑定都必须验证参数、资源归属和生命周期。

## 总体架构

```text
Dora Application
├── Dora LuaEngine
│   └── Dora 主 lua_State
├── Director / Scheduler / Input / Audio / Content
├── LoveNode A
│   ├── LoveRuntime A
│   │   ├── 独立 Lua 5.5 state
│   │   ├── loveA.* bindings
│   │   ├── 独立 _G / package.loaded
│   │   ├── Love event queue
│   │   └── Love filesystem context
│   ├── LoveGraphics A
│   └── RenderTarget A
└── LoveNode B
    ├── LoveRuntime B
    ├── LoveGraphics B
    └── RenderTarget B
```

共享的是引擎原生设施和 Lua 5.5 程序库，不共享任何 Love Lua 状态：

- bgfx 设备与 Dora 渲染器共享。
- SoLoud 设备与 Dora 音频系统共享。
- SDL/平台事件由 Dora 接收后路由。
- Content、线程池和文件读取能力由 Dora 提供底层实现。
- 每个 LoveNode 自己创建、使用和关闭 `lua_State`。
- 任意 Love Lua table、function、userdata 或栈索引不得跨状态传递。

## `LoveNode` 宿主接口

首版脚本接口保持最小：

```lua
local LoveNode = require("LoveNode")

local gameA = LoveNode("Games/A/boot.lua")
local gameB = LoveNode("Games/B/boot.lua")

gameA.position = Vec2(-300, 0)
gameB.position = Vec2(300, 0)
```

构造参数是 boot 代码文件路径。路径必须通过 Dora `Content` 解析；其所在目录成为该实例默认的 Love source root。boot 文件负责完成 Love 启动流程，例如读取配置、加载 `main.lua` 并建立标准回调。

建议的原生轮廓：

```cpp
class LoveNode : public Sprite {
public:
	bool init() override;
	bool update(double deltaTime) override;
	void cleanup() override;

	CREATE_FUNC_NULLABLE(LoveNode);

protected:
	explicit LoveNode(String bootFile);

private:
	std::string _bootFile;
	Own<LoveRuntime> _runtime;
	Ref<Scheduler> _scheduler;
};
```

`LoveNode` 继承 `Sprite`，表面纹理来自该实例的主渲染目标。这样它天然支持 Dora 节点的 transform、opacity、visibility、父子关系和场景排序。

首版不增加用于操纵 Love 内部脚本状态的公开 Dora API。暂停、可见性、缩放和销毁优先使用现有 Node/Scheduler 语义；确有需求时再增加与 Love API 无关的宿主节点属性。

## Lua 状态

### 创建

每个 `LoveRuntime` 使用 Dora 已链接的 Lua 5.5 创建独立状态：

```cpp
_lua = luaL_newstate();
```

初始化过程中只打开 Love 所需的标准库，并注册 Love 模块。不得调用 Dora 主状态的 `tolua_LuaBinding_open()`，也不得安装 Dora 的 `.xml`、`.tl`、`.wasm` 等运行时 loader。

需要注册的内容包括：

- Love 根模块及启用的子模块。
- Love 对象 userdata 和 metatable。
- Love filesystem package searcher。
- Love boot 所需的兼容函数。
- 统一的 traceback 和错误上报入口。

### 隔离

每个状态天然拥有独立的：

- `_G`
- `package.loaded`
- `package.preload`
- `package.searchers`
- registry
- coroutine
- garbage collector
- `love` table 与回调
- 游戏模块和游戏全局变量

因此两个 LoveNode 即使加载同一份 boot 文件，也会得到两套完整的游戏状态。

### 销毁

LoveRuntime 必须先停止所有可能回调 Lua 的原生对象，再调用 `lua_close()`：

```text
停止节点更新和输入投递
→ 调用 love.quit（如果存在）
→ 停止该实例音频
→ 取消异步回调和资源完成通知
→ 释放 Canvas、Shader、Texture 等 Love 资源
→ 清空事件队列
→ lua_close
```

任何后台任务都不得在 `lua_close()` 后持有该状态的 handler、registry reference 或 userdata 指针。

### 公共 Object 生命周期

所有公开 Love userdata 统一具有 `type()`、`typeOf(name)` 与 `release()`。类型层级由对象注册时声明；共用 metatable 的 Shape 与 Joint 根据实际子类型返回 `CircleShape`、`DistanceJoint` 等精确名称，同时继续匹配 `Shape`/`Joint` 与 `Object`。`release()` 对当前 Lua proxy 幂等：首次调用返回 true，重复调用返回 false；释放后 `type/typeOf` 仍可查询，其他方法（包括释放前捕获的方法闭包和把对象再次传给模块函数）必须由同一个上游类型检查定向失败，不能继续访问 backing resource。

公共实现直接编译 Love 11.5 原有的 `Object`、`Type`、`StrongRef`、Lua `Proxy`、弱对象 registry、`Reference`、`Module` 与 common runtime，不在 Dora 侧复制一套释放状态表。每个隔离 Lua state 在注册对象前建立 Love pinned thread；Lua proxy 持有一个原生 intrusive reference，`release()` 与 `__gc` 都进入上游 `Object::release()`，同一原生对象重复 push 时由 state-local 弱 registry 复用 proxy。

全部公开 userdata 已完成该模型。CPU Data 家族的 `DataView` 以 `StrongRef<Data>` 持有父对象；对接 Dora 渲染、音频和输入资源的 Image/Canvas/Font/Shader/Source/Cursor/Video/RecordingDevice 使用 `DoraHandleObject`，由唯一 Runtime release 入口管理 backend handle。由 Dora binding 创建的对象通过 `pushNewDoraHandleObject` 交接初始引用；由原版 wrapper 创建的对象保留 `luax_pushtype + release` 的上游所有权交接。Physics 是明确例外：World/Body/Shape/Fixture/Joint/Contact 直接使用 Love 11.5 Box2D 具体对象、`StrongRef`/`Reference` 与 Proxy，不持有 Dora handle；`destroy()` 的拓扑释放和 GC 继续由上游 Physics 代码负责。File、Thread、Channel、Joystick、Rasterizer、Decoder、Math 对象及所有 Drawable 也都通过 `luax_register_type/luax_pushtype` 注册和创建。Dora 自定义 released-object 表、placement userdata、逐类型 `*GC` 回调、手动 userdata 析构和手写公开 metatable 路径已经移除；common runtime 仍把 Proxy uservalue 容量设为 5，但对象身份、类型检查、弱 registry 与 refcount 语义复用 Love 实现。

## Love 启动和主循环

### Boot

LoveNode 加载传入的 boot 文件，但不直接把 Love 原版可执行程序主循环搬入 Dora。boot 层负责：

1. 初始化 `love` 根表和启用模块。
2. 建立 Love 默认配置。
3. 加载同目录的 `conf.lua`（如果存在）。
4. 应用允许由虚拟窗口支持的配置。
5. 加载 `main.lua` 或 boot 指定的入口。
6. 调用 `love.load()`。

加载错误应使 `LoveNode` 构造失败或进入明确的错误状态，不能留下半初始化的 Lua state、音频句柄或 RenderTarget。

### 帧驱动

Dora 是唯一主循环所有者。每帧按以下逻辑驱动各 LoveNode：

```text
Dora 采集平台事件
→ 路由到对应 LoveNode
→ LoveNode 更新事件队列
→ 调用 love.update(dt)
→ 开始实例渲染 pass
→ 调用 love.draw()
→ 结束实例渲染 pass
→ Dora 把 LoveNode 表面合成到场景
```

`love.run` 可以保留 API 兼容入口，但默认实现必须适配 Dora 驱动模型，不能进入自己的无限循环或调用平台 present。

### 固定帧率

默认使用 Dora 传入的实际 `deltaTime`。如果后续支持实例级固定帧率，应为 LoveNode 配置独立 `Scheduler`，行为参考 `TIC80Node`；不能通过阻塞或 sleep 控制 Dora 主线程。

## Love 模块边界

### 尽量保留

优先保留 Love 的上层类型、Lua binding 和可独立于平台后端的逻辑：

- `love.data`
- `love.math`
- `love.image` 的数据模型和解码语义
- `love.sound` 的数据模型和解码语义
- `love.font` 的上层接口
- `love.physics` 的 Box2D 行为
- Graphics 中的 Quad、Mesh、SpriteBatch、ParticleSystem 等上层对象语义
- Love callback、event name、枚举和错误行为

### 替换或适配

以下部分必须由 Dora 后端接管：

| Love 模块 | Dora 接入方向 |
| --- | --- |
| `love.graphics` | Dora/bgfx graphics backend 与实例 RenderTarget |
| `love.window` | LoveNode 虚拟窗口，不直接拥有宿主窗口 |
| `love.event` | 实例事件队列，由 Dora 平台事件转发 |
| `love.keyboard` | Dora Keyboard/平台事件映射 |
| `love.mouse` | Dora 鼠标与节点本地坐标映射 |
| `love.touch` | Dora Touch 事件与触点 ID 映射 |
| `love.joystick` | Dora Controller 映射 |
| `love.audio` | Dora Audio/SoLoud backend |
| `love.filesystem` | Dora Content 读取能力和实例写目录策略 |
| `love.timer` | Dora 时间源和每实例帧统计 |
| `love.system` | Dora Application/平台信息的受限映射 |

### `love.math` 的实例状态

`love.math` 不依赖平台后端，但它不是无状态工具集合。模块级随机数生成器必须由每个 Love Lua state 独立持有，不能使用 Dora 主状态、C 标准库全局随机数或进程级单例。`love.math.newRandomGenerator` 另外创建互不影响的生成器对象；seed、state 字符串和 normal 分布缓存均属于对应对象，并保持 Love 11.5 的确定性算法与状态序列化语义。这样两个使用相同 seed 的 LoveNode 会得到相同序列，而不会因帧间交错互相消耗随机数。

### `love.font` 的独立对象层

`love.graphics.Font` 只表示可绘制字体，不能代替 Love 11.5 的 `Rasterizer` 与 `GlyphData`。这两个对象必须属于各自 Love Lua state：`GlyphData` 同时实现 `Data`，保存确定的 RGBA8 字形像素、码点和度量；`Rasterizer` 提供字形查询和生成接口，不泄漏 Dora FontCache 对象。

Image 后端采用 `love.font.newImageRasterizer(ImageData, glyphs, extraSpacing, dpiScale)`。它按首行左上角 spacer color 分割 glyph，保留源 ImageData 的 userdata 引用，并在每次生成 GlyphData 时读取当前像素；等于 spacer color 的像素转为透明。这保持 Love 的可变 ImageData 和生命周期语义，也不引入文件 I/O。

TrueType 后端复用 Dora 已有的 `stb_truetype`，由 Content 路径或任意 Love Data 载入 TTF/OTF/TTC 内存；默认构造器的 Sarasa 字体也由 LoveNode 经 Content 注入。每个 Rasterizer 自持字体字节和 stb fontinfo，生成 Love 兼容的 LA8 GlyphData，不依赖全局 FontCache。`normal/light/none` 接受为 stb 的抗锯齿路径，`mono` 对覆盖率做二值化；这不是 FreeType hinting 的逐像素等价，应在兼容矩阵中保留差异说明。

BMFont 后端实现 Love 11.5 使用的文本 descriptor：描述文件只从 Dora Content 路径或 FileData 读取；page 可显式传入 ImageData、Content 路径、FileData 或按页号排列的数组，未显式提供的 page 按 descriptor 所在目录经 Content 相对加载。Rasterizer 强引用各页 ImageData，并在每次生成 RGBA8 GlyphData 时读取当前矩形，因此源页的修改和生命周期语义与 ImageRasterizer 一致；多页、Unicode、metrics、越界和缺页均须验证。AngelCode 二进制 BMFont 不在此兼容承诺内，也不得把 `love.graphics.newFont` 包装后冒充 Rasterizer。

实现保留 `RandomGenerator`、模块随机数接口、颜色 byte/float 与 gamma 转换、`isConvex`、`triangulate`、1D～4D Noise、完整 4×4 `Transform` 和 `BezierCurve` 对象语义。这些逻辑直接运行在目标 Lua 5.5 state 中，不需要 Dora backend，也不会访问文件系统；Noise 直接编译 vendored Love 11.5 使用的 public-domain simplex/Perlin 实现，避免换算法导致相同项目生成不同地图。Transform 与 BezierCurve userdata 只属于创建它们的 state，随 LoveNode stop/restart 一起释放。已弃用的 `love.math.compress/decompress` 仅作为后续 `love.data` 压缩实现的兼容别名处理，不在 Math 对象层重复实现 codec。

### `love.data` 的对象与 codec 边界

`ByteData`、`DataView` 和 `CompressedData` 都是所属 Love Lua state 的私有 Object，不得把裸指针或对象引用跨 LoveNode 传递。`DataView` 不复制字节，而是以 Love 原生 `StrongRef<Data>` 强引用父 Data；即使脚本显式 release 父 proxy、释放原变量并触发 GC，view 和它的 clone 仍必须保持父 backing 存活。`ByteData:clone` 与 `CompressedData:clone` 则复制自己的字节快照。Lua 5.5 没有 LuaJIT FFI，因此 `getFFIPointer` 明确返回 nil；`getPointer` 只作为当前 state 生命周期内的不透明标识，不形成 DoraHost 或跨状态接口。单对象及解压结果统一受 256 MiB 上限保护。

Data 对象本身只处理内存，不产生文件访问。FileData、ImageData、CompressedImageData 和 SoundData 可作为 Data 输入，但它们若源于文件，仍必须先经各模块已定义的 Dora Content-only 路径取得内存；encode/decode、pack/unpack 和压缩不得再次解析路径或回退到 stdio。首批编码支持 hex/base64，并对齐 Love 11.5 的 Base64 line-length 与边界末尾换行行为；pack/unpack/getPackedSize 复用同一 Lua 5.5 state 的标准 `string.pack/unpack/packsize`。

zlib、gzip 和 raw deflate 复用 Dora 已 vendored 的 zlib，实现 string/Data 输入以及 string/CompressedData 或 ByteData 输出。LZ4 直接编译 Love 11.5 vendored 的 `lz4/lz4hc`，保持其 4-byte little-endian 原始长度头和 level 大于 8 时使用 HC 的格式语义，并始终使用 safe decompressor 检查截断、损坏和超限输入。MD5、SHA-1、SHA-224、SHA-256、SHA-384 和 SHA-512 同样直接编译 Love 11.5 的 backend-independent `HashFunction`，返回原始二进制摘要字符串；六种算法均以官方 `abc` 向量验证。已弃用的 `love.math.compress/decompress` 直接注册为相同函数的兼容别名，不维护第二套 codec。这些算法只消费 state 内已有内存，不增加文件 I/O，也不共享跨实例可变状态。

### `love.system` 的受限宿主映射

`love.system` 仍注册在每个隔离 Love state 中，但查询和操作通过 LoveNode 的 System backend 进入 Dora 宿主，不注册上游进程级 Module singleton。`getOS` 把 Dora 平台名转换为 Love 11.5 可观察值（macOS 返回 `OS X`），CPU 数、供电状态、剩余电量/时间和文本剪贴板使用已经初始化的 SDL 宿主能力；剪贴板是操作系统共享资源而不是 state-local 数据，接口不缓存副本，嵌入 NUL 或 SDL 错误会形成明确 Lua 错误。`getPowerInfo` 保持 `state, percent|nil, seconds|nil` 的三返回值约定，并将百分比限制到 0～100。

`openURL` 经 Dora `Application.openURL` 调度，嵌入宿主只允许 `http`、`https` 和 `mailto` scheme，拒绝空值、控制字符、超长地址、相对路径以及 `file:` 等本地 handler，返回 boolean 而不是把平台失败伪装成成功。`vibrate` 保持 Love 默认 0.5 秒和参数检查；桌面按 Love 11.5 行为 no-op，iOS 使用系统 vibration sound（与上游一致，忽略秒数），Android 使用应用 `Vibrator` 并按秒数计时、在 Activity pause/destroy 时取消，不能拿 controller rumble 冒充。`hasBackgroundMusic` 是 Dora 应用级查询而非 LoveNode 私有状态：iOS 读取 `AVAudioSession.secondaryAudioShouldBeSilencedHint`，Android 与 Love 上游相同读取 `AudioManager.isMusicActive()`，桌面返回 false。macOS 与 Windows 桌面验收必须保存原剪贴板、写入并读回测试值、再恢复原值，不能把测试数据留在用户环境；Windows 另在交互桌面实跑 PowerInfo 与 `file:` URL 拒绝。移动端自动化只证明宿主调用、返回类型和生命周期安全，物理震动、其他应用音频竞争仍需真机人工验收。

## 渲染架构

Love 是立即模式渲染系统，不能把每次 `love.graphics.draw()` 都转换成临时 Dora Node。正确边界是实现 Love Graphics 的 Dora/bgfx 后端。

```text
love.draw()
→ Love Graphics 状态机
→ Love draw command / vertex data
→ Dora bgfx backend
→ LoveNode RenderTarget
→ LoveNode Sprite surface
```

### 主表面

每个 LoveNode 拥有独立主渲染目标：

- 尺寸由 Love 虚拟窗口配置决定。
- `love.graphics.clear()` 只影响该实例表面。
- Dora 场景只看到表面纹理，不受 Love 内部坐标系影响。
- Love 默认左上角原点和 Y 向下坐标由 backend 统一处理。
- 节点缩放不应改变 Love 内部逻辑分辨率，除非显式调整虚拟窗口。

### Canvas

`love.graphics.newCanvas()` 应创建 Love 实例拥有的离屏目标。Canvas 可以共享 Dora/bgfx 设备，但必须记录 owner runtime；跨 LoveNode 使用另一个实例创建的 Canvas、Shader 或 GPU Buffer 必须报错。

每个 Love Canvas 在所属 `LoveNode` 内组合一个 Dora `RenderTarget`，其颜色附件同时作为可绘制纹理暴露给 LoveRuntime。当前 graphics frame 不再假设只有主表面，而是记录按调用顺序产生的 pass：切换 Canvas、回到主表面或在已有绘制后 `clear` 都建立新的有序 pass。由于 Dora `RenderTarget::render()` 通过 `SharedView.pushFront` 提交，LoveNode 在帧末反向提交 pass，才能保持 Love 脚本中的依赖顺序；所有临时 pass root 必须标记为 managed，避免既被 RenderTarget 渲染又泄漏到宿主场景树。

首版 Canvas 支持一个或多个二维颜色目标：`newCanvas`、`setCanvas` 的单值/变参/数组形式、`getCanvas` 的多返回值、`draw(Canvas)`、Canvas 版 `newQuad`、尺寸/DPI/format/MSAA/readable 查询，以及 userdata 私有的 filter/wrap。`push("all")/pop()` 必须保存并恢复全部当前 Canvas 的 Lua registry 强引用；正在作为任一颜色目标的 Canvas 不能绘制到自身。无参数 `setCanvas()` 回到 LoveNode 主表面。Canvas 默认保留上次内容，只有脚本显式 `clear` 才清除；同一回调中的多次目标切换和 clear 必须保持先后关系。Love 的 `graphics.getDimensions/getPixelDimensions` 始终查询虚拟窗口而非当前 Canvas，无参 `newCanvas()` 同样采用虚拟窗口像素尺寸；backend 仅在把 Love 左上坐标转换到 Dora RenderTarget 时使用首个当前目标的高度。

多颜色目标由 `LoveNode` 按有序 Canvas handle 组合并缓存一个非拥有型 Dora `RenderTarget` framebuffer：各颜色 Canvas 继续独立拥有颜色纹理和自身 D24S8 texture；没有显式 depth/stencil Canvas 时组合 framebuffer 复用首个颜色 Canvas 的 D24S8，显式提供时则组合对应的独立 depth/stencil texture。组合目标强引用全部附件但不取得纹理所有权，缓存键同时包含有序颜色附件和显式 depth/stencil handle。Runtime 在切换前拒绝重复 handle、同一 Canvas 兼任颜色与 depth/stencil、格式角色不符、不同尺寸、已关闭或跨实例对象；backend 再校验一致的 MSAA 与 bgfx `maxFBAttachments`。失败必须保持原有活动目标和 Lua registry 引用不变。普通 Dora/Love shader 只写颜色附件 0，view clear 写入全部颜色附件；自定义 `void effect()` 可通过 `love_Canvases[constant]` 写入多个附件，具体转换和 draw-time 数量校验见 Shader 小节。任一附件释放时必须清除所有包含该 handle 的组合 framebuffer 缓存，避免悬空附件。

Canvas 的 Love 11.5 公开对象方法和资源模型均已接入，包括继承的 Texture 查询/设置、`renderTo/generateMipmaps/getMipmapMode`，以及 2D、Array、Cube、Volume、`dpiscale`、manual/auto mip chain、按 layer/face/volume slice 与 mipmap 绑定和读回。Volume depth 随 mipmap 逐级减半。自动模式只在渲染基础 mip 时请求 bgfx resolve；手动模式由 `generateMipmaps()` 排入带 `BGFX_RESOLVE_AUTO_GEN_MIPS` 的有序空 pass，`RenderTarget` 显式 touch view 以保证 resolve 提交。layered/mipmap Canvas 与 MSAA、layered depth/stencil 的组合在当前 bgfx backend 明确拒绝，不静默降级。颜色格式直接映射为 Dora/bgfx texture：`r8/rg8/rgba8/srgba8`、`r16/rg16/rgba16`、`r16f/rg16f/rgba16f`、`r32f/rg32f/rgba32f`、`rgba4/rgb5a1/rgb565/rgb10a2/rg11b10f`；`normal` 归一为 `rgba8`，`hdr` 归一为 `rgba16f`。独立 depth/stencil Canvas 支持 `stencil8/depth16/depth24/depth32f/depth24stencil8`；`depth32fstencil8` 和 `la8` 保留枚举但当前能力为 false。`love.graphics.getCanvasFormats(readable[, table])` 必须结合活动 renderer 的 framebuffer 能力动态返回。

`setCanvas` table 支持 `depth=true`、`stencil=true`、`depthstencil=true` 的临时附件语义和 `depthstencil=<Canvas>` 显式附件；颜色目标可通过 `{Canvas, layer=..., face=..., mipmap=...}` 选择 Array、Cube、Volume 或 2D mip 子资源，直接重载同样接受 slice/mipmap。自定义附件必须在所选 mip 上尺寸与 MSAA 一致。`getCanvas()` 对非基础子资源返回可无损恢复的 target table；`push("all")/pop()` 保存并恢复 handle、slice/mipmap、标志及原生 `StrongRef`。作为活动颜色或 depth/stencil 目标的 Canvas 都不能同时被采样。depth/stencil Canvas 不能伪装为颜色 ImageData；Love 11.5 也不定义“压缩 Canvas”。

Canvas 接受 `msaa=0/2/4/8/16` 请求，颜色和 D24S8 depth attachment 使用相同 sample count，并由 bgfx 自动 resolve 为可采样颜色纹理；同一 MRT 的全部颜色目标必须具有相同 MSAA。创建入口必须拒绝 renderer 无法可靠表达的级别，不能让 bgfx 静默降级后仍由 `Canvas:getMSAA()` 返回请求值。当前 Metal backend 因 bgfx 不公开设备实际降级结果，明确只暴露到 4×，8×/16× 返回创建错误；4× 已通过真实 resolve 后的 framebuffer 像素读回。其他 renderer 的精确级别继续由各平台发布门槛验证。

`readable=false` 映射为 `BGFX_TEXTURE_RT_WRITE_ONLY`：它仍可被 `setCanvas` 绑定、clear 和绘制，但不得作为 `draw` 的纹理来源，也不得进入 readback。`readable=true` 才允许采样；depth/stencil Canvas 即使 readable，也仍不能通过 `newImageData` 转成颜色数据。能力查询和实际创建必须一致；Metal 上 `rgba4/rgb5a1/rgb565` 虽被当前 bgfx 标为 framebuffer-capable，却需要 Metal 禁止用于 render target 的 texture swizzle，因此 backend 在排队 GPU 创建前同时从查询和创建入口排除，避免系统 descriptor assertion。超出格式、类型、MSAA 与 depth/stencil 组合矩阵的 settings 必须明确报错，不能静默降级。

### 状态

后端必须覆盖 Love 的有状态绘制语义：

- transform stack
- color 与 background color
- blend mode
- scissor
- stencil/depth
- Canvas 切换
- Shader 与 uniform
- Font
- line/point style
- color mask
- winding 和 mesh attributes

LoveNode 开始绘制前建立默认状态，结束后恢复 Dora 渲染状态，不能把 Love 的 blend、scissor、view 或 RenderTarget 泄漏到后续 Dora pass。

基础后端把 alpha、add、multiply、replace、screen 映射为 Dora `BlendFunc`；multiply 保持 Love 11.5 的 premultiplied alpha 限制。`subtract` 通过 bgfx `BGFX_STATE_BLEND_EQUATION_REVSUB` 表达，并继续使用 Love 对应 alpha mode 的源/目标因子；运行时状态恢复和 macOS Metal 逐像素结果均已验证。`lighten/darken` 受 Love 的 `getSupported().lighten` 能力位约束，当前报告 false 并明确拒绝是合法行为，不计为缺失。Scissor 在实例 RenderTarget 内切分有序 command segment，并通过 Renderer 的局部 bgfx scissor scope 同时裁剪图元与纹理；它不再占用 ClipNode 的 stencil bit，因此可与 Love 的完整 8-bit stencil buffer 组合，scope 结束后也不会污染宿主绘制状态。

`love.graphics.stencil(callback, action, value, keepvalues)` 和 `setStencilTest/getStencilTest` 使用当前目标的 D24S8 attachment。主表面默认可用 stencil；Canvas 必须显式通过 `setCanvas({canvas, stencil=true})` 开启，普通 `setCanvas(canvas)` 下调用要明确失败。`replace/increment/decrement/incrementwrap/decrementwrap/invert` 分别映射 bgfx 的 replace、饱和加减、环绕加减和 invert；stencil 写入阶段关闭颜色通道，callback 结束或抛错后都必须恢复。Love 的比较关系以“reference 与 stencil value”定义，映射到 GPU compare 时要反转 less/greater 方向。`keepvalues=false/nil` 先按 0 clear，`true` 保留，数值则以该整数 clear；clear 通过同一 RenderTarget 的有序 stencil-only pass 完成，不能同时抹除颜色。`push("all")/pop()` 保存 Canvas stencil 开关及 compare/value；嵌套 stencil callback 当前明确拒绝，避免写状态重入。

`setColorMask/getColorMask` 同样属于实例 graphics state 并随 `push("all")/pop()` 保存。Renderer state scope 直接映射 bgfx 独立的 `WRITE_R/G/B/A`，因此支持任意四通道组合；Stencil 写入在其外层临时关闭全部颜色通道，结束后恢复原 mask。view clear 不服从 draw-state color mask 和局部 scissor，所以 `love.graphics.clear` 在 partial mask、scissor 或逐 MRT 附件颜色模式下改用保持命令顺序的专用 replace draw：单目标覆盖当前 framebuffer，MRT table overload 则逐附件提交并允许空表跳过对应附件；scissor 同时约束颜色、depth 与 stencil clear。该 draw 自带 color-write/depth/stencil state，不受当前 transform、blend、depth compare、cull 或 stencil test 影响，随后恢复活动组合目标和普通 command segment。无参 clear、数值 RGBA 广播、boolean color 开关、逐附件颜色表、stencil 数值/开关与 depth 数值/开关均按 Love 11.5 解析；主 surface 在无 scissor 时仍可按 mask 合并延迟 clear color。

`setDepthMode/getDepthMode`、`setMeshCullMode/getMeshCullMode` 和 `setFrontFaceWinding/getFrontFaceWinding` 也是实例 graphics state，并纳入 `push("all")/pop()`。八种 depth compare 与 depth write 分别映射到 Renderer 的局部 bgfx state；cull 只在当前 Love command segment 内生效。Love 顶点采用左上原点、Y 向下，而 Dora 合成前会转换为 Y 向上坐标，因此 backend 必须在 cull 映射处补偿这次镜像，不能直接照搬 `cw/ccw`。默认 `ccw`、front/back cull 及 float3 Z 的 `less + write` 已由真实 Metal 深度附件逐像素验证，scope 退出后不得污染后续 Dora pass。

Background color 与无参 `clear()` 的透明黑不是同一状态：`set/getBackgroundColor` 只维护 Love DisplayState，宿主是否用它清理窗口仍由嵌入循环策略决定。`set/getDefaultFilter` 同样属于每个 LoveRuntime 的 DisplayState，并且必须写入之后创建的 Image、ArrayImage、CubeImage、VolumeImage 与 Canvas userdata；已有纹理保持自己的 filter。Dora sampler 只有一组 min/mag 模式，所以当前要求两者相同，anisotropy 至少为 1；不同 min/mag 必须明确报错。background/default filter、Font 与其余已实现状态都进入 `push("all")/pop()`；普通 transform push 仍只保存矩阵。

`applyTransform`、`replaceTransform`、`shear`、`transformPoint` 与 `inverseTransformPoint` 操作实例当前的二维仿射矩阵，并与 translate/rotate/scale 使用同一右乘顺序。传入含 3D 分量的 Transform 要明确拒绝，奇异当前矩阵的 inverse point 要报错。`intersectScissor` 在未启用时等价于建立传入矩形，已启用时取屏幕空间交集并允许得到零宽或零高区域。`getStackDepth` 返回当前 transform/state stack 深度；`reset` 恢复 Love 11.5 默认 DisplayState、主 Canvas、默认 Shader/Font 和单位 transform，但不清空 stack。`isActive` 只报告该实例是否已连接 Dora graphics backend，不能等价为 LoveNode 可见性；当前非 gamma-correct pipeline 由 `isGammaCorrect=false` 如实报告。

`set/getLineStyle` 与 `set/getLineJoin` 属于每个 LoveRuntime 的 DisplayState，默认分别为 `smooth` 和 `miter`，进入 `push("all")/pop()` 并由 `reset()` 复位。LoveNode 不用 DrawNode 的固定描边冒充这些状态，而是参考 Love 11.5 `Polyline` 算法生成 miter、bevel 或彼此独立的 segment quad；smooth 在核心线套外增加约一个 screen pixel 的透明 alpha fringe，rough 只提交核心几何。标准与自定义 Shader 都消费同一份细分网格，`love_VertexID` 使用动态顶点属性路径。当前二维仿射矩阵和 Love 式 `pixelScale` 随 line/polygon backend 契约下沉：scale 按两轴绝对值平均数累乘，apply/replace transform 按结果矩阵的两个近似轴向 scale 重算，rotate/translate/shear 保持该值；LoveNode 先在局部坐标生成核心与 join，再整体变换到实例 surface，从而保持上游“先细分再变换”的顺序，并让非均匀 scale/shear 同样改变线宽和连接几何。

`setWireframe/isWireframe` 同样是实例 DisplayState，默认关闭，并进入 `push("all")/pop()` 与 `reset()`。开启后，Love 专用的填充图元、Image/Canvas、ImageFont/Text mesh、Mesh、SpriteBatch、ParticleSystem 和自定义 Shader 提交把每组三角形索引展开为三条 bgfx line-list 边；points 保持原有点大小和填充，不被线框状态改变。TrueType 系统 Font 仍复用 Dora Label，其 glyph 提交通过局部 topology override 进入调试线框路径。该模式对齐 Love 把 wireframe 定义为调试工具而非普通 line 的边界；Dora 的显式 line-list 不具备三角形 rasterizer 的 face primitive，因此 wireframe 与 front/back cull 组合不声明逐像素等价，作为可审计的 renderer 差异保留。

`getSupported(target?)`、`getTextureTypes(target?)`、Love 11.5 的 `getImageFormats(target?)` 与 `getRendererInfo()` 必须从当前 LoveNode 所在的 bgfx renderer 动态生成，而不是写死桌面能力。features 精确返回八个 Love 11.5 键：mixed-format MRT、clamp-zero、NPOT、pixel highp、shader derivatives、GLSL3 和 instancing 按真实 backend/现有转换链报告；Dora 尚未暴露 min/max blend equation，因此 `lighten=false`。texture type 通过 RGBA8 的 bgfx texture-valid 检查区分 2D、array、cube、volume。Image formats 只枚举上游 `ImageData::validPixelFormat` 的 17 种格式和全部压缩 PixelFormat 名称：17 种普通格式确实由 runtime 解码后转 RGBA8 上传，所以报告可用；压缩格式则要求存在 Love→bgfx 映射，且 `isTextureValid` 确认 renderer 能通过原生采样或 bgfx 明确报告的 `TEXTURE_2D_EMULATED` 转换路径创建；signed BC/EAC 等未映射格式明确为 false。查询与 `newCompressedImage/createTexture2D` 必须使用同一 capability 判定，不能出现查询 false 而创建成功。Canvas alias、sRGBA 和 depth/stencil 格式不能混入该表。

`getRendererInfo` 返回 bgfx renderer 名称、bgfx API 版本和当前 PCI vendor/device 标识。前向兼容的 `getTextureFormats(settings, target?)` 复用同一能力查询：`canvas` 为必填项，决定查询 render-target 或普通纹理；`readable` 继续使用真实 Canvas 可读性能力，Dora 当前没有 compute texture write 和 shader atomic 纹理路径，因此相应要求保守返回 false。它不创建资源，也不绕过 bgfx capability。`getStats(target?)` 只统计当前 LoveNode：每帧的 `drawcalls/drawcallsbatched/canvasswitches/shaderswitches` 在 `beginFrame` 清零并在 `present/endFrame` 后归零，持久的 `images/canvases/fonts` 来自本实例 handle map，`texturememory` 汇总该实例拥有的 Image、ArrayImage 逐层副本、Canvas 与 ImageFont atlas 实际 GPU allocation。它不读取 Dora 全局 renderer 计数，也不包含宿主 Node、其它 LoveNode 或共享 Dora 系统字体 atlas；因此多实例不会互相污染。这里的 draw/batch 是 Love compatibility command submission 口径，不虚构为 bgfx 驱动级 draw-call profiler。

本轮按七个兼容功能组补充接口：Math 的 `perlinNoise/simplexNoise`、Filesystem 的 `openFile`、Physics 的 `getDistance`、Graphics 的 `newTextBatch`、`getTextureFormats` 和 `setStencilMode/getStencilMode`。其中 `getDistance` 是此前遗漏的 Love 11.5 API；其余是选定的 Love 12 前向名称。`newTextBatch` 复用已经迁移的 Text 对象和原版 `newText` parser，不另建文字系统；高层模板模式映射到 Dora 现有 stencil state，并纳入 `push("all")/pop/reset`；`openFile` 只组合当前 state 的 File 构造与打开，所以文件读写仍严格经过 Content。这里把成对的 stencil setter/getter 作为一个功能组统计，但两个 Lua 函数和两份查询/设置语义都实际注册。

`discard` 与 `flushBatch` 是可证明的等价 no-op，而不是空壳 API。Love 11.5 的 `discard(colorbuffers?, depthstencil?)` 只是允许 renderer 失效 framebuffer 内容的性能提示，调用后读取被丢弃附件的结果本就未定义；LoveNode 保留内容不影响任何已定义行为，并按上游 `luax_optboolean` 规则接受单 boolean、逐附件 boolean table 和 depth/stencil 参数。`flushBatch()` 用于提交 Love 自动 stream batch；LoveNode 每个 draw 已按顺序形成独立 Dora render command，并在创建时捕获 graphics state，因此没有待提交的 Love stream batch，调用前后的可见顺序天然成立。

`newImageFont` 不复用 Dora 系统 `Label`：每个 Font handle 持有独立 RGBA8 atlas、separator 解析后的 glyph rectangle/advance、额外 spacing、DPI scale 与创建时的默认 filter。输入可为 ImageData、FileData、Dora Content 路径，或同 state 的 ImageRasterizer；路径和编码数据仍统一经 Content/Image backend，禁止原生文件 I/O。separator 色在上传副本中转为透明，源 ImageData 不被修改；绘制时同一 atlas 的连续 glyph 合并为 textured mesh，切换 fallback atlas 时按保持原字符顺序的纹理 run 拆批，保留 variable width、换行/对齐、line height、仿射 transform、graphics color、blend 及普通或 `love_VertexID` Shader。ImageFont 的 ascent/baseline/descent 与 kerning 均为 0，尺寸、advance 和 glyph 高度按实际提供 glyph 的 ImageFont DPI scale 换算。

BMFont 使用相同的位图字体绘制通道，但保留 AngelCode 文本描述中的 page、x/y 矩形、xoffset/yoffset、xadvance、lineHeight 和 base，不把多页图集错误压成单行 ImageFont。`love.graphics.newFont("font.fnt")` 自动经 Content 读取描述文件及相对 page 图像；`love.graphics.newFont(love.font.newBMFontRasterizer(...))` 则可使用调用方显式提供的 ImageData、FileData 或 Content page。每个 page 生成独立 atlas，按原字符顺序、资源和 page 拆分纹理 run；测量、换行、fallback、普通和 `love_VertexID` Shader 绘制均使用同一套 glyph metrics。BMFont 不支持 AngelCode 二进制描述格式。

`Font:setFallbacks` 对齐 Love 11.5 的 rasterizer data type 限制：ImageFont 只能使用 ImageFont fallback，TrueType/系统 Font 只能使用同类 Font；交叉类型在提交前失败且保留旧列表。查询与排版均按主字体优先、fallback 参数顺序选择第一个拥有 glyph 的 Font；ImageFont fallback 因此同时进入 `hasGlyphs/getWidth/getWrap/print/printf/Text` 路径，不把缺失 glyph 静默交给 Dora 系统字体。更一般的 Rasterizer subtype 仍必须先取得等价 atlas 语义后才能接入。

ArrayImage 除保留供 Shader uniform 使用的原生 bgfx texture array 外，还在创建时为每层保留一份同源 RGBA8 2D 纹理视图副本。`drawLayer(array, layer, quad?, transform...)` 和普通 `draw(array, quad?, ...)` 的默认 Shader 路径使用逐层副本：前者采用显式一基 layer，后者采用 Quad layer、无 Quad 时默认为第一层；显式 layer 不受 Quad 自身 layer 字段影响。活动 Shader 显式声明 `extern ArrayImage MainTex` 时则改走原生 texture array，不提取或冒充二维层：UV 保持在 `v_texcoord0.xy`，每次 draw 的零基层通过独立 `a_texcoord1 → v_texcoord1.x` 输入组成 Love 的 `VaryingTexCoord.xyz`，因此同一帧多个 layer 不共享可变 uniform。主纹理声明、`send("MainTex", array)` 和实际 drawable 类型必须一致；2D Image、Font/Text atlas、无纹理图元或错误 texture 类型在提交前定向失败。所有越界、非 ArrayImage 和 closed/cross-state 输入同样在提交前失败。逐层副本随 Image handle 一起释放；额外显存只服务默认 renderer 的精确选层与既有 filter/wrap/blend/transform/Canvas 顺序复用。

### Mesh

`love.graphics.newMesh` 当前支持 Love 11.5 的标准顶点格式和显式 vertex format。标准格式为 `VertexPosition(float2)`、`VertexTexCoord(float2)`、`VertexColor(byte4)`；自定义格式支持 `float`、`byte`、`unorm16` 的 1～4 分量，并将内置属性规整为 Dora 的 position/texcoord/color 输入。Mesh userdata 保存 CPU 顶点、可选 vertex map、draw range、draw mode、usage 及 Image/Canvas 纹理强引用；对象和纹理都必须属于同一 LoveRuntime。

`love.graphics.newSpriteBatch` 复用相同的 Dora/bgfx Mesh 提交边界。SpriteBatch userdata 按 Love 语义在 `add/set/addLayer/setLayer` 时固化 Quad、标准变换、当前批次颜色和 ArrayImage layer；`add` 在 ArrayImage 批次上读取 Quad layer、无 Quad 时默认第一层，`addLayer/setLayer` 的显式一基 layer 覆盖 Quad 自身 layer，并且只允许 ArrayImage。`add` 超过容量时倍增缓冲，`set/setLayer` 只覆盖指定槽位而不改变 count，`clear` 只把 count 归零，`flush` 作为当前 CPU-backed 实现的兼容同步点。批次通过 uservalue 强引用一个同 state、类型固定的 Image/ArrayImage/可读 Canvas；`setTexture` 只能替换为相同 texture type，`getTexture`、draw range 和外层 `graphics.draw` 变换均保持 Love 行为。二维批次继续使用普通 texture Mesh；ArrayImage 批次把每顶点零基层送入独立 layer semantic，默认状态按需复用实例内部 `ArrayImage MainTex` effect，活动自定义 Shader 则必须同样声明 ArrayImage 主纹理。两条路径都把选中的 N 个 sprite 合并为 `4N` 顶点、`6N` 索引的一次 `drawMesh`，不按 layer 拆 draw，也不为每个 sprite 创建 Dora Node。

`SpriteBatch:attachAttribute(name, mesh)` 按 Love 11.5 只绑定源 Mesh 中同名的直接 vertex attribute，并由 SpriteBatch uservalue 对每个绑定 Mesh 保持强引用。绑定时及每次 draw 时都要求源 Mesh 至少具有 `batch.count × 4` 个顶点；因此绑定后继续增长 batch 可以成功写入，但在源 attribute 扩容前会于提交前定向失败。draw range 只选择提交的 sprite，attribute 取值仍按绝对 sprite 顶点索引截取，不放宽上述完整 count 校验。`VertexPosition`、`VertexTexCoord`、`VertexColor` 覆盖批次内建流，其中 ArrayImage 批次会把 attached `VertexTexCoord.z` 作为替换后的 layer 值继续送入独立主纹理 semantic；其余同名 attribute 进入活动 Shader 的动态 attribute semantic。至此固定 Love 11.5 目标中的 SpriteBatch 方法面已完整接入。

`love.graphics.newParticleSystem` 同样使用实例内 CPU 状态和 Dora Mesh 提交，不为每个粒子创建 Dora Node。ParticleSystem userdata 保存活动粒子、发射器位置与前一位置、寿命、速度、线性/径向/切向加速度、damping、尺寸/颜色/Quad 时间序列、旋转/spin 和 insert mode；`update(dt)` 只由 Love 代码显式推进，保持 Love 主循环可重放语义。Image/Canvas texture 与 Quad userdata 分别放入 uservalue 强引用，clone 复制配置而清空活动粒子，setBufferSize/reset/stop/pause 的状态转换遵循 Love 11.5。绘制时把 N 个存活粒子展开为 `4N` 顶点、`6N` 索引并在一次 `drawMesh` 中提交，外层标准 transform、当前 graphics color、texture filter/wrap、Shader 及全局 blend state 继续复用现有 graphics scope；活动 Canvas 自采样仍在提交前拒绝。Love 专用动态 Mesh 已能按提交规模选择 16/32-bit index buffer，因此不再存在 16383 粒子的固定索引上限；实际单次容量仍受 ParticleSystem 的 `setBufferSize` 上限、内存和活动 renderer transient buffer 可用量约束，分配不足必须明确失败，不能静默截断。

`fan`、`strip`、`triangles` 会在提交前转换为 Dora 可消费的索引三角形。普通无纹理、无用户 Shader 且索引可由 16 位表达时继续使用既有 DrawNode 路径；纹理 Mesh、小型默认 sprite Mesh 与点图元尽量保留现有批次。顶点数或任一索引超过 65535 时，Love 专用 Mesh node 刷新共享批次并改用 32-bit transient index buffer；活动 renderer 不具备 `BGFX_CAPS_INDEX32` 时在提交前给出定向错误。带 Image/Canvas 纹理或活动用户 Shader 的点仍在最终变换坐标处展开为屏幕像素大小的四顶点 quad，保留每点 UV、RGBA、Z/W，并明确屏蔽 cull，避免三角形剔除状态错误影响 Love 的 point primitive。transform、全局 color、顶点 RGBA、UV、Z/W、vertex map 与 draw range 继续在 backend 边界合成；Canvas 纹理仍遵守 readable、不能采样当前目标和实例所有权限制。32 位索引消除了旧的 65535 顶点/16383 展开点固定上限，但不承诺任意接近 `uint32` 极限的网格都能一次取得 transient buffer；资源不足仍按现有 renderer 失败路径处理。

Data 形式的 vertices 和 vertex map 已接入现有 Data 对象（FileData、ImageData、CompressedImageData、SoundData）的内存快照。vertex Data 按 Love 的原生布局解释：`float` 为本机 float，`byte`/`unorm16` 归一化到 0～1，各 attribute 的字节尺寸必须为 4 的倍数；Mesh 同时保留原始字节和解码值，使 `setVertices(Data, start, count)` 的局部/部分字节覆盖、表输入量化后的查询和后续绘制保持一致。index Data 支持零基的 `uint16/uint32` 及可选 count，对外 `getVertexMap` 仍返回一基 Lua 索引。原始 Data 不经过文件路径或平台 I/O；从文件取得 Data 时仍只能先走 Love filesystem/Dora Content。

`setAttributeEnabled/isAttributeEnabled` 与 `attachAttribute/detachAttribute` 已实现。外部 Mesh 通过 userdata uservalue 表被目标 Mesh 强引用，GC 后不会留下悬空 attribute；跨 LoveRuntime、缺失 attribute、超过 16 个 attribute 和会形成 Mesh attachment 引用环的组合明确拒绝。`pervertex` 按目标 vertex index 取源 attribute，普通非 instanced draw 下 `perinstance` 使用源 Mesh 第一行；`drawInstanced(mesh, count, transform...)` 则按 instance index 推进每个 `perinstance` attachment，内置 Position/Color/TexCoord 与活动 Shader custom attribute 使用同一解析规则。替换 Position/Color/TexCoord、custom attribute 和 shear transform 均已进入 canonical vertex 生成及真实 Metal 场景。

活动 vertex Shader 实际使用的非内置 `attribute float/vec2/vec3/vec4` 会按声明顺序映射到 bgfx 剩余的 15 个 attribute semantic；未在代码中使用的声明不占 semantic，也不要求 Mesh 提供数据。Runtime 在每次 draw 时按名称合并 Mesh 自有与 attachment attribute，把 `float/byte/unorm16` 都转换为 Shader 可见的归一化 float 值；缺失、被禁用、分量数不符或值数量异常会在提交前明确失败。LoveNode 为这些 draw 建立动态 `VertexLayout` 和 transient buffer；普通三角保留 Love 左上原点坐标，在 Shader 的 `position` 运算完成后才通过内部矩阵转换到 Dora/RenderTarget，point quad 则把每个 custom attribute 同值复制到四个展开顶点。这样自定义位移仍使用 Love 像素坐标，不会因过早进入 clip space 而改变语义。

`drawInstanced` 采用硬件优先、语义保底的混合路径。活动 Shader 能生成实例化变体、renderer 支持 instancing 且逐实例 stream 不超过 5 个时，Runtime 只提交一份基础 vertex/index geometry；LoveNode 把每个 stream 打包成 bgfx `InstanceDataBuffer` 的一个 vec4 slot，由隐藏 selector uniform 让同一 Shader 声明在 `pervertex` 与 `perinstance` 间选择，并以一个带 instance count 的 draw 提交。GLSL3 `love_InstanceID` 在普通 draw 中显式为 0，在实例化变体中映射 bgfx `gl_InstanceID`，以 0 起始值参与 vertex `position`；若该 Shader 无法走硬件路径则明确报错，不能用恒定 0 的 CPU 回退伪造结果。当前实例化变体为避免与 5 个 instance semantic 冲突，最多承载 10 个实际使用的 custom vertex attributes；不使用 `love_InstanceID` 时，若变体无法生成、没有活动 Shader、renderer 不支持或 stream 超限，Runtime 自动回退到原有 CPU 展开的一次 backend 提交，不影响普通 Shader 创建和绘制。回退时 fan/strip 会逐实例三角化以隔离拓扑，0/负 count 均不提交。硬件路径只提交一次基础 Mesh；CPU 路径展开后的 geometry 和基础 Mesh 都能使用 32-bit 索引，并已验证两个 65538 顶点实例展开为 131076 顶点且高位索引不截断。P5-06 已由 Metal、OpenGL ES 与 Direct3D 的当前支持矩阵闭合；其它未来 renderer 只需复跑同一 capability/像素门禁。

GLSL3 `love_VertexID` 不直接映射 bgfx 的 `gl_VertexID`：transient vertex buffer 的底层 ID 包含分配基址，不等价于 Love 每次 draw 从 0 开始的局部编号。转换器改为为实际使用 VertexID 的 Shader 预留一个隐藏 vertex semantic；Runtime/LoveNode 对 Mesh、Image/Canvas quad 和 Shader graphics primitives 生成从 0 开始的本地 ID stream，point/line 等展开几何沿最终提交顶点重新编号。CPU 展开的多实例 Mesh 为每个实例重复基础 Mesh 的局部编号，硬件实例化只提交一份基础编号。隐藏 stream 只在当前 Shader 确实使用 VertexID 时创建，不改变普通 Shader 的 attribute 列表；其代价是该 Shader 的普通变体最多容纳 14 个用户 custom vertex attributes，实例化变体最多 9 个。

### Shader

`love.graphics.newShader` 的首个可用子集以 Love 11.5 标准 `vec4 effect(...)`、multiple-output 自定义 `void effect()` 和 `vec4 position(...)` 为输入，并在所属 LoveNode 内转换为 Dora/bgfx shader source。单参数或双参数可为内联源码、FileData 或文件名；文件名仍先走 Love source/save 解析，再且只能通过注入的 Dora Content filesystem backend 读取。缺失 stage 由 backend 生成与 Dora CPU clip-space Sprite vertex 兼容的默认 stage，不能回退到 Love 的平台文件或 OpenGL runtime compiler。

转换层提供 `number`、`Image`、`Texel`、`VertexPosition`、`VertexTexCoord`、`VertexColor`、`VaryingColor` 与 `VaryingTexCoord` 等当前子集别名，把活动的 `extern/uniform number|float|vec2|vec3|vec4|mat2|mat3|mat4|int|ivec2|ivec3|ivec4|uint|uvec2|uvec3|uvec4|bool|bvec2|bvec3|bvec4` 重写为 bgfx uniform。标量、向量和 mat2 存入 vec4 uniform；mat3 按三个 vec4 column 打包并由生成的 helper 重建；mat4 使用 bgfx Mat4 uniform。bgfx 没有整数 uniform 类型，后端以 32-bit 位模式存入 float 通道，生成的 shader 再通过 `floatBitsToInt/floatBitsToUint` 还原，因此不能改成普通数值转换。像 `texture` 这样会与目标 HLSL/Metal 关键字冲突的 Love 合法标识符必须在词法边界内重命名。生成层给 `position` 显式追加内置顶点和 custom attribute 参数，并用内部 `u_loveTransform` 区分已经 CPU 投影的固定 Sprite layout 与仍处在 Love 像素坐标的动态 Mesh layout；标准 `transform * vertex` 会转成 bgfx 跨后端安全的 `mul(transform, vertex)`。只传 vertex stage 时自动生成的默认 pixel stage 同样必须避开 HLSL 保留字 `texture`。

转换结果由 Dora `ShaderCompiler` 针对当前活动 renderer 编译，再链接为实例持有的 `SpriteEffect`。`setShader/getShader` 是 LoveRuntime graphics state，并随 `push("all")/pop()` 通过 Lua registry 强引用保存恢复；Shader userdata GC、runtime close 和 LoveNode restart 必须解除当前绑定并释放 effect/stage。跨 state、已关闭或不存在的 Shader 必须报错，`validateShader` 只验证并立即释放临时资源，不改变当前 Shader。

转换器删除 Love pragma、varying、attribute 与 uniform 声明时只空白字符而保留换行，并记录转换后每条非空用户源码到 Love 原始行号的映射。DoraShaderc 若报告生成源码片段，`newShader/validateShader` 会在该片段唯一匹配用户源码时把错误前缀回映为 `Love vertex/pixel Shader source line N`，同时保留完整 backend 原始诊断；重复源码行无法唯一定位时不得伪造行号。`Shader:getWarnings()` 汇总 DoraShaderc 的成功编译 warning 与转换器可确定的 warning，例如已声明但未使用、因而被省略的 uniform/attribute。这样 Metal 即使只返回中间 HLSL 行号，用户仍能获得 Love 源文件定位，而 Linux/Windows 后端原始文本也不会丢失。

ShaderCompiler 使用的 `Assets/Shader/Love/varying.def.sc` 是运行时必需资源，不只是开发仓库中的测试文件。macOS、iOS、Android 及后续 Linux/Windows 发布 target 必须把 `Assets/Shader` 以原目录层级放入 Dora Content 根；发布验收既要检查 bundle/APK 中的实际文件，也要从发布 app 调用 `newShader/validateShader`，不能用仓库 `--asset Assets` 的运行结果替代打包验证。资源审计应固定检查 target manifest，避免默认预编译 Shader 可运行却让 Love 自定义 Shader 在用户设备上失败。

当前 `Shader:getWarnings/hasUniform/send/sendColor` 已接入。`send` 支持有限 float/number、32-bit signed int、32-bit unsigned uint、严格 Lua boolean、vec/ivec/uvec/bvec、mat2/mat3/mat4，以及单个 Image/Canvas；类型、范围和分量数必须与声明一致。矩阵默认把 Lua 扁平表或 table-of-tables 解释为 row-major，也接受首个值参数为 `"row"|"column"`；Runtime 按 Love 上游转为 column-major 逻辑值，LoveNode 再在 renderer 边界适配：Metal 对 Dora Mat4 的逻辑索引做转置，OpenGL ES 保持 Love/GLSL 的 column-major 数据。该差异必须用非对称矩阵逐元素验证，不能直接 memcpy 后用单位矩阵测试冒充正确。固定长度数值数组支持 1～1024 个元素：标量数组按多个标量参数发送，向量和矩阵数组按多个 table 参数发送；少于声明长度时更新前缀并保留其余已存值，超出声明长度的值按 Love 行为忽略。`sendColor` 只接受 float vec3/vec4 并把分量限制到 0～1，不能用于整数、boolean 或矩阵 uniform。活动的 `extern Image` 从 slot 1 起分配（slot 0 保留给 draw 对象自身纹理），并按当前 renderer 的 sampler 上限校验；发送时把对应 Love userdata 的 filter/wrap 作为该 uniform 独立 sampler flags 写入 Dora `Pass`，不修改共享 Texture。Shader userdata 的 uservalue 表按 uniform 名强引用已发送的 Image/Canvas，确保局部变量 GC 后资源仍有效，重新发送则替换引用。

`Shader:send/sendColor` 同时接受当前 Love state 的 FileData、ImageData、CompressedImageData 和 SoundData 原始内存。offset 与 size 均以 byte 为单位；offset 必须位于 Data 内，显式 size 必须为正、在边界内、是单个 uniform 元素 stride 的整数倍，并且不能超过声明数组总大小；省略 size 时从 offset 起截取尽可能多的完整元素并限制到声明 count。float/matrix 按原生 32-bit float、int/uint/bool 按原生 32-bit word 解释；sampler 明确拒绝 Data。矩阵 Data 同样支持 `layout, data` 和兼容上游旧顺序 `data, layout`，默认 row-major。Data 只读取 userdata 已有的内存快照，不产生文件访问；FileData 若来自文件，仍必须先经过 Love filesystem 与 Dora Content。

Canvas sampler 必须 `readable=true`，且不得同时作为任何活动 render target。该反馈环在三个状态边界都做事务式拒绝：向 Shader 发送当前活动 Canvas、启用一个采样当前 Canvas 的 Shader、以及在活动 Shader 下把其采样 Canvas 切为 render target；失败不改变原活动 Shader/Canvas。Image/ArrayImage/CubeImage/VolumeImage sampler array 会展开为连续的 bgfx sampler slot，并把动态索引调用转换成引用各元素 sampler 的选择 helper；二维坐标为 `vec2`，Array/Cube/Volume 均为 `vec3`，分别调用 `texture2D/texture2DArray/textureCube/texture3D`。数组总数与其它活动 sampler 合计不能超过当前 renderer 上限。`send` 按 Love 的前缀更新规则接受 1～声明 count 个同类型 Image，二维数组也可使用 readable Canvas；整批资源、类型、readable 和 feedback 检查成功后才统一替换对应 slot，每个元素独立保存 filter/wrap、Canvas 所有权和原生 `StrongRef`。当前转换子集要求 sampler array 只以 `Texel(array[index], coordinates)` 或等价纹理函数调用消费，其它把纹理对象当一等值传递的写法明确报错。

自定义 `void effect()` 支持 `love_PixelColor` 单输出或 `love_Canvases[n]` 多输出。当前跨 renderer 可控子集要求 `n` 是非负编译期常量；转换器计算最高索引所需的颜色附件数，并为 Dora framebuffer 的 depth attachment 保留一个 bgfx 槽位，因此当前编译上限是 7 个颜色输出。bgfx 把 `gl_FragData[n]` 跨编译成 `main` 的 `SV_TARGETn`/等价输出，独立 Love `effect()` 不能直接访问这些 main 参数；生成层将各颜色值改写为 `effect` 的 `inout vec4` 参数，再由 wrapper main 提交到对应 attachment。绑定 Shader 本身不要求立刻切换 Canvas，但每次 Image/Canvas/Mesh 或 graphics primitive 提交前必须验证当前主表面/Canvas 数量，输出不足时失败且不提交半个 draw；多余的已绑定目标允许存在。

自定义 `varying` 当前支持可选 `lowp/mediump/highp` 修饰的 `float/vec2/vec3/vec4/mat2/mat3/mat4`，GLSL3 还支持 `int/ivec2/ivec3/ivec4`、`uint/uvec2/uvec3/uvec4`、`bool/bvec2/bvec3/bvec4`，以及这些类型的固定长度数组。创建 Shader 时先联合解析 vertex/pixel 两段源码，pixel 输入必须在 vertex 有同名、同类型且同数组长度的输出；实际跨阶段消费的 varying 按 vertex 声明顺序映射到 `TEXCOORD1..7`、`COLOR1..3` 共 10 个 vec4 semantic。浮点标量/向量和 boolean 每个数组元素占一个 slot，矩阵每个元素再按 GLSL column 分别占 2/3/4 个连续 slot；32-bit signed/unsigned integer 的每个分量拆成高低两个 16-bit 数值分量，每个元素占 `ceil(componentCount * 2 / 4)` 个 slot。不能把任意 integer 直接 bitcast 为 float varying：例如 `-7` 会形成 NaN 位型，而 GLES 可在跨 stage 通道中规范化 NaN，无法保证逐位往返。16-bit 数值分量在高精度 shader float 中精确可表示，pixel wrapper 再用 shift/or 重组完整 32-bit 值，不依赖 NaN/Inf payload。由于 bgfx shaderc 会把 varying 收进目标 `main` 的输入/输出结构，生成层不能让 Love 的 `position/effect` helper 直接访问全局 varying，而是把变量改写为 helper 参数；数组在 wrapper 中保留原类型与长度，vertex 端逐元素、逐列或逐整数 stream 写回，pixel 端重建局部数组，因此用户 helper 内的动态索引仍有效。只在 vertex 声明但 pixel 不消费的 varying 降为 helper 局部临时值，不占 semantic，也不会触发 bgfx 严格链接失败。缺失来源、类型、数组形态/长度或插值限定符不一致、重复、内置名重声明、attribute/uniform 同名和按实际 stream 数计算的容量超限必须在 runtime compile 前返回定向错误。

`#pragma language glsl1|glsl3` 必须和 Love 11.5 一样出现在源码首个非空白行；双 stage 显式目标必须一致，缺失 stage 继承另一段源码的目标。GLSL3 继续兼容 Love 的 `attribute/varying` 别名，同时接受 vertex `in`/`out` 与 pixel `in` 的浮点、矩阵、signed/unsigned integer 和 boolean 标量/向量 interface 声明及固定长度数组；同类型 direct varying 可在一条语句声明多个名称，每个名称可独立声明固定数组。GLSL1 direct varying 保持浮点子集。现代 `texture(Image, uv)` 在转换边界按 Image/ArrayImage/CubeImage/VolumeImage uniform 类型归一为 bgfx 对应采样调用。命名或匿名的 vertex `out` / pixel `in` interface block 可包含上述叶类型及成员数组、引用预先声明的固定命名 `struct`，或直接声明可递归嵌套的 `struct { ... } member[N]` 匿名类型；命名 struct、匿名 struct 与 block 的同类型字段都支持逗号分隔的多声明符，每个字段独立保留数组形状。struct 字段可继续引用固定命名 struct，并可在每层声明固定长度数组。带实例名的 block 还可声明固定长度实例数组。转译器先在注释屏蔽后的源码上用平衡花括号定位完整 interface block，再从最内层开始把内联匿名 struct 提升为仅供分析的稳定内部类型；内部 identity 由去空白后的 member body 产生，但跨 stage shape 记录使用 `<anonymous>` 标记和完整叶路径，因此 `vec2 a,b;` 与 `vec2 a; vec2 b;` 这类结构等价声明可以链接，内部类型名不会进入最终 Shader。随后按 block 名和完整成员路径建立跨 stage identity，把各 stage 可不同的实例名递归展开为现有独立 varying；block、struct 字段及叶成员的多层数组索引按各维长度线性化，仍保留动态整数表达式。GLSL3 integer/boolean 跨 stage 声明必须显式使用 `flat`，省略或使用其它 interpolation 会在 backend 前得到 `requires flat interpolation`；这条规则也适用于从 interface block/struct 递归展开的叶。匿名 block 实例数组、递归命名 struct、运行时数组、错误方向、重复成员，以及跨 stage 的类型、命名 struct 名、各层数组形状或限定符不一致在 shaderc 前返回定向错误。

跨 stage 声明可带一个 `flat`、`smooth` 或 `noperspective` 插值限定符以及可选的 `centroid`；`centroid` 也可单独使用，省略插值限定符对浮点类型等价于 `smooth`，两段必须匹配。组合按 GLSL 顺序写成 `smooth centroid` 或 `noperspective centroid`，integer/boolean 则只允许 `flat`。LoveNode 通过 Dora Content 读取基础 `Shader/Love/varying.def.sc`，为每个 Shader 在内存中生成带相应限定符的独立 varying 定义并交给 ShaderCompiler，不修改共享资源，也不把限定符只在源码转换层吞掉；bgfx shaderc 的 varying parser 已扩展为保留该合法组合，并在 HLSL 路径映射为 `linear centroid` 或 `noperspective centroid`。冲突的双插值限定符、顺序错误的 `centroid smooth`、重复 `centroid`、无有效插值意义的 `flat centroid` 以及未标记 `flat` 的 integer/boolean 会在 shaderc 前得到定向错误。`love_VertexID` 使用每次提交从 0 起始的隐藏本地 attribute，`love_InstanceID` 在普通变体为 0、硬件实例化变体映射 renderer instance ID；GLSL1 使用二者会得到要求 glsl3 的定向错误。非法目标、错位 pragma、pixel-only input 以及跨 stage 语言/类型、数组形状、struct 类型或限定符不一致同样在 shaderc 前返回定向错误。GLSL3 vertex attribute 还接受 GLSL 330 与 ESSL 300 共同支持的 `layout(location=N) in`，其中跨平台安全位置固定为 4～15：0～3 保留给 Love 的 VertexPosition、VertexTexCoord、VertexColor 与 ConstantColor，活动 custom attribute 的显式位置不得重复。该数字只约束 Love 源码的链接语义，实际 Mesh 数据仍按属性名接入 Dora 动态 VertexLayout；未使用属性与 Love 一样可被优化移除。varying location、uniform binding、fragment output 等不属于固定两种目标语言的共同用户语法，继续给出定向错误。当前这是 Love entry-point 的可运行 GLSL3 兼容子集，不宣称接受任意桌面 GLSL；其它 `layout` 和运行时数组等复杂形态仍由后续扩展处理。

首批真实绘制覆盖 Image/Canvas Sprite，带 Image/Canvas、无纹理、custom attributes/varyings 和 points 模式的 Mesh，以及 rectangle/circle/ellipse/polygon/line/points graphics primitives。Love 与 OpenGL backend 一样要求无纹理 Shader draw 的基础 `Image texture` 表现为白色；LoveNode 因此按需创建一个实例拥有的 1×1 RGBA8 白纹理，通过既有 SpriteEffect 路径绑定 slot 0，并在实例 stop/cleanup 时释放。这样标准 `Texel(texture, uv) * color` 在无纹理 Mesh 与 graphics primitives 上保持顶点色，而不需要维护另一套无 sampler Shader。Shader/纹理 point Mesh 和 graphics points 会先扩为固定像素尺寸的 quad；填充图元转为 triangle fan，描边/折线转为线段 quad。所有 graphics primitives 在内部 renderer scope 屏蔽 mesh cull，坐标先采用 Love transform 结果，point size 和 line width 保持 RenderTarget 像素尺度。数值 array、bool/int/uint、mat2/mat3/mat4、Data-backed send、2D/Array/Cube/Volume sampler array、ArrayImage/CubeImage/VolumeImage、常量索引 `love_Canvases[]`、动态 Mesh custom attributes/varyings、GLSL3 基础 interface/texture 语法、direct/interface block/固定命名 struct 的同类型多声明符、包含浮点/矩阵/integer/boolean、固定数组、固定命名及内联匿名嵌套 struct 与固定实例数组的 interface block、动态多层索引、单个及 `smooth centroid`/`noperspective centroid` 组合 interpolation、integer/boolean `flat`、vertex attribute `layout(location=4..15)`、`love_VertexID/love_InstanceID`、硬件 instancing、无纹理/纹理 Mesh points 与 graphics primitives 已通过 macOS/iOS Metal、Android OpenGL ES、Linux ARM64 Mesa OpenGL ES 和 Windows Direct3D 真实像素矩阵；Windows 还连续通过十三场景高级图形与 Array/Cube/Volume 单值、数组及动态索引的非二维 sampler workflow，并明确排除 Noop renderer。HLSL 路径将 Love/GLSL 单参数 vector 构造改写为显式 splat/copy/truncate helper，矩阵零值与标量构造改为显式列，MRT/ConstantColor/boolean 比较零值使用 bgfx portable constructor；Direct3D 的 mat4 读取在生成 Shader 内转置，避免把数组 upload 的主机布局规则扩散到 Runtime。Linux 验收还固定了 OpenGL ES 独立 shader profile 与 GLES readable Canvas capability；Love 原始源码行号回映与 compiler/translator warning 汇总已在 Metal 与 Direct3D 编译路径通过。P5 图形实现以当前 Dora 可选的 Metal、OpenGL ES 与 Direct3D 闭合；其它 layout 是条件兼容扩展，Linux 真实 GPU和逐设备压缩格式归 P6。Dora Linux 当前在 SDL context 存在时固定选择 OpenGLES，Vulkan 待宿主平台层先提供可选择 surface/backend，不能作为 Love 层接口缺失。

`love.graphics.setPointSize/getPointSize` 属于每个 LoveRuntime 的 graphics state，默认值为 1，并随 `push("all")/pop()` 保存恢复。point 的坐标先经过 Love transform，但 point size 保持 RenderTarget 像素直径，不随 scale/rotate 改变；Dora DrawNode 绘制前在最终坐标增加半像素中心偏移，避免整数坐标的 size-1 point 落在像素边界而完全不可见。非有限值和小于等于 0 的尺寸必须报 Lua 参数错误。


基础 Font/Text 后端把每个 Love Font handle 映射到 Dora `Font`，把逐帧 `print/printf` 命令映射为实例 RenderTarget 内的 `Label`。默认字体使用 Dora 内置字体名；文件字体先由 Love source/save 路径策略解析，再交给 `SharedFontCache`，其资源加载继续走 Dora `SharedContent`，不允许 Love backend 直接打开字体文件。首版覆盖 TrueType `.ttf`、CFF OpenType `.otf` 与取第一 face 的 TrueType Collection `.ttc`；损坏输入先经过 SFNT/TTC 结构和 table 边界检查再进入 stb_truetype。

Font userdata 支持 width/height/baseline/ascent/descent/wrap、Unicode `hasGlyphs`、kerning、line-height 和 `setFallbacks`。Fallback 顺序保持主字体优先，再按传入顺序选择首个包含目标 codepoint 的 Dora Font；测量按选中字形字体分 run，绘制在同一 Love transform 容器内组合多个 Label，fallback 状态只属于当前 Love Font handle，不能修改 Dora 全局字体缓存或其它 Love state。当前 `print/printf` 支持 left/center/right/justify、颜色、旋转、缩放、origin 和 scissor；固定采用 1 logical unit = 1 RenderTarget pixel，宿主高 DPI 只影响节点最终合成。

`love.graphics.newText(font, text?)` 创建所属 Love state 私有的 retained Text userdata。Text 保存原始字符串或 ColoredText 片段、创建/追加时的标准变换或 `Transform` 矩阵、`addf/setf` 的 wrap 与 left/center/right/justify 对齐，以及对 Font userdata 的强引用；`set/add/setf/addf/clear/setFont/getFont/getWidth/getHeight/getDimensions` 在修改后重新形成可测量的排版 run。彩色片段的颜色在 draw 时再与当前 graphics color 相乘，数字值按 Love 文本规则转换；`graphics.draw(Text, ...)` 仍叠加调用处的外层标准变换。

Text 缓存的是 Love 侧排版与 run，不缓存 Dora Label 的 glyph UV 或 atlas 页。每次 draw 为各个字体、颜色和 fallback run 创建新的 Label 提交，因此 `setFont` 后会完整重排，运行中新增 Unicode 字形或 Font atlas 更新也不会留下失效 UV；多字体和多 atlas 仍由 Dora Font/Label 路径管理。justify 只扩展非末行的 ASCII 空格，保持 colored run 边界，不能把多个 Label 提交误记为单个 GPU draw call。通用文字 shear 仍需单独核验；复杂 Unicode shaping/bidi 和把多 run 合并成专用 GPU text batch 不属于 Love 11.5 的兼容验收要求，前者可作为超出目标版本的排版质量增强，后者只是性能优化。

Image 的 filter/wrap 是 Love userdata 的实例状态，不能写回 Dora 全局 TextureCache。当前后端把 `nearest`、`linear` 和启用 anisotropy 的 `linear` 分别映射到 Dora `Point`、`None` 和 `Anisotropic`，把 `repeat`、`mirroredrepeat`、`clamp`、`clampzero` 分别映射到 Dora `None`、`Mirror`、`Clamp`、`Border`。Dora Sprite 目前只有一组采样过滤状态，因此首版要求 min/mag 相同；不同值必须返回明确的不支持错误，不能悄悄选择其中一个。每次 Image draw 把 userdata 当前采样状态送入 backend，不同 Love state 不共享这部分可变状态。

Love Image 必须支持 `replacePixels`，因此不能复用以初始内存创建、随后不可更新的共享 TextureCache 纹理。2D、array、cube、volume Image 都由 LoveNode 以空初始内存创建动态 bgfx texture，再用 `updateTexture2D/3D/Cube` 上传初始或替换区域；ArrayImage 为默认二维逐层绘制持有的 layer 副本必须同步更新。filename 输入仍先通过 Love filesystem 和 Dora Content 取得内存，再经 bimg 解码进入相同动态创建路径，不允许回退为原生文件访问。Runtime 按 Love 11.5 校验同 state ImageData、压缩 Image 拒绝、一基 slice/mipmap 与零基 x/y 区域；当前 2D/Array 已有 Metal 保留区和替换区像素证据，Cube/Volume 已有 Mock dispatch 与平台编译证据。

Image 的 mip 链不能只作为 userdata 元数据保存，必须进入 GraphicsBackend 的资源创建契约。非压缩级别以 `width/height/slices/RGBA8` 表达：2D 使用 `{mip1, ...}`，Array/Cube 使用 `{slice = {mip1, ...}}` 并在各级保持固定 slice/face 数，Volume 使用 `{mip = {slice1, ...}}` 且 depth 与宽高一起逐级减半；除单独 base level 外，显式链必须提供到 1×1（及 Volume depth 1），符合上游 `Image::Slices::validate`。`mipmaps=true` 且只给 base level 时，由 Runtime 生成完整 RGBA8 链：2D/Array/Cube 对每个 slice 做 2×2 box filter，Volume 同时沿 z 做 2×2×2 降采样，再交给 LoveNode 创建实际 `hasMips=true` 的 bgfx 资源。文件输入仍只经 Dora Content 解析、读取并从内存解码。

Cube 单个非压缩输入遵循 Love 11.5 的 3×4、4×3、1×6、6×1 atlas 布局并按 `+X,-X,+Y,-Y,+Z,-Z` 拆分；Volume 单图接受横向或纵向等宽方形层条带。Array 的单图输入按上游语义只形成一个 layer。table 元素可以是同 state ImageData，也可以是 FileData/Data；后两者只从 Dora Content 已读取的内存经注入 image backend 解码，并以首个 `@Nx` 文件名推断 DPI。Runtime 同时让 `getWidth/getHeight/getPixelDimensions/getDepth(mipmap)` 与实际资源维度一致，并把 `linear/dpiscale` settings 应用于所有纹理类型。

压缩 Image 的 GraphicsBackend 契约同样按每级 `width/height/slices/bytes` 传递，支持由多个 `CompressedImageData` 组合 Array/Cube/Volume，且不会把压缩资源解压成 RGBA8。bgfx Array/Cube 上传按 slice/face-major 重排完整 mip chain；Array 的逐层绘制副本也使用同一完整链。能力判断必须以真实 renderer 验收为准：macOS Metal 上 bgfx 的 layered BC1 创建会停止 render thread，即使通用 `isTextureValid` 返回成功，因此 LoveNode 在提交前明确拒绝 layered compressed Image；2D BC1 完整链继续支持。该限制不是 Lua/Object 生命周期降级，也不得以“先创建后等待超时”的方式探测。

`love.image.newImageData` 的文件输入继续先走 Love source/save 解析和 Dora Content 读取，再把内存数据交给 LoveNode 注入的 bimg decoder；禁止 bimg 或 Love 使用路径自行打开文件。每个 Love state 持有私有 CPU 像素缓冲，支持 Love 11.5 的 17 种 ImageData 格式：`r8/rg8/rgba8`、`r16/rg16/rgba16`、`r16f/rg16f/rgba16f`、`r32f/rg32f/rgba32f`、`rgba4/rgb5a1/rgb565/rgb10a2/rg11b10f`。raw bytes、`getString/getSize/getPointer` 均保持对应原生字节布局；clone、0-based `getPixel/setPixel`、区域 `mapPixel`、同格式 raw paste 和 RGBA 家族跨格式 paste 使用 Love 11.5 的 half/packed-float 与 UNORM 转换语义。文件解码当前由 bimg 产生 RGBA8；上传到现有 Dora 2D Image 后端以及 PNG/TGA 编码时才在边界转换为 RGBA8，而不改变源 ImageData 的格式与字节。越界、非法区域、非法尺寸、非有限分量、raw 长度不符、文件缺失与解码失败都必须成为可诊断 Lua 错误。

`love.image.newCompressedData` 与 `isCompressed` 复用相同的 Content/Data 输入边界，但经独立 `ImageBackend::decodeCompressedImage` 解析，不把压缩纹理伪装成 RGBA8 ImageData。LoveNode 使用 Dora 已链接的 bimg 读取内存 container，只接受 Love/bimg 都能表达的二维、单 layer、非 cube 压缩格式；解析结果按 mip 复制到所属 state 的 CompressedImageData，提供 Data、clone、format、mipmap count 和一基 mip dimensions。bimg 的通用 parser 会把压缩尺寸扩大到最小 block storage 并把任意 mip 输入扩成完整链，桥接层已修正为保留 container 的逻辑宽高、精确 mip 数与实际 payload 大小；PVRTC1 的 `TextureInfo` 也必须以逻辑尺寸计算 GPU mip 数，block 最小值只参与每级 storage size，不能把合法 8×8 2bpp 输入伪装成 16×8/5 mip。

`love.graphics.newImage(compressedData, settings?)` 将压缩 block 原样交给 bgfx，不经过 RGBA 解码：默认只上传 base mip，`mipmaps=true` 才上传 CompressedImageData 的完整 mip chain；后端用 `calcTextureSize` 核对尺寸、层数和总字节数，并用活动 renderer 的共同 capability helper 拒绝不支持的格式。该 helper 以 `isTextureValid` 为基础，同时验证仿真路径确有 bimg decoder；当前 bimg 没有 ETC2A1 decoder，因此只有原生支持 ETC2A1 的 renderer 才能公开并创建 `ETC2rgba1`，纯 `TEXTURE_2D_EMULATED` 不得返回成功后产生黑纹理。macOS Metal 还会虚报 PVRTC1 2bpp：Xcode 合法 payload 可创建却稳定采样为黑，且 bimg 没有 2bpp decoder fallback，因此 macOS 的 `PVR1rgb2/PVR1rgba2` 在查询和创建时一致拒绝；4bpp 不受影响。部分 mip chain、非 boolean 设置和格式/能力不匹配都返回明确 Lua 错误。

当前 macOS Metal 真实验收共解析 43 种输入：原有 14 种 DDS/KTX/PVR3 的 DXT、ASTC4x4、ETC1/ETC2，KTX 与 PVR3 各四种 PVRTC1 RGB/RGBA 2bpp/4bpp，KTX 中 Love 11.5 其余 13 种 ASTC footprint，以及 KTX/PVR3 各四种 EAC R11/RG11 的 unsigned/signed 组合。ASTC 使用 footprint-independent 的 opaque-red void-extent block，并按各 footprint 的逻辑宽高提供到 1×1 的完整三或四级链；14 种 ASTC 均逐像素通过 Metal。EAC 作为 bimg/bgfx 的一等压缩格式追加在既有公开枚举尾部，保留 `Unknown=34`、`RGBA8=67`、`D0S8=95` 的 ABI；KTX 识别四个 EAC internal format，PVR3 以 channel type 精确优先、ANY 兜底区分 signed/unsigned，GL/GLES、Vulkan 和 Apple-family Metal 提供原生映射，D3D 明确不报告支持。bimg 的 PVR3 映射表也按 Love 11.5/标准编号补上 ETC2 的 22/23/24 三项。两个容器中的 ETC2rgba1 与四条 PVRTC1 2bpp 路径按上述安全边界一致拒绝；其余 37 种逐一完成原始 block 上传并在 framebuffer 读取实际像素。原生 ETC2A1、PVRTC1 2bpp 的非 macOS renderer，以及 ASTC/EAC 等已支持格式在其它 renderer 的交集仍须逐格式补证。

`love.graphics.captureScreenshot` 按 Love 11 的帧末异步语义实现：调用只登记请求，LoveNode 在当前 `love.draw` 的所有 pass 提交后读回该实例主 RenderTarget。文件名形式只接受 PNG，并在登记请求时完成 save 路径校验；GPU 返回 RGBA8 后由 Dora 图片后端编码，再且只能由 Content filesystem backend 写入 `Content.writablePath/Love/<identity>`。回调形式在所属隔离 state 中构造私有 ImageData，不把 RenderTarget 或 Dora Texture 暴露给脚本。Channel overload 把复制的 RGBA8 ImageData 投递到所属 LoveRuntime 的 state-independent Channel，由接收 state 重建私有 userdata。每项读回持有 LoveNode 弱引用和 runtime generation；实例 quit、restart 或销毁后，旧请求只能释放 staging texture，不能再进入旧 `lua_State`。

`Canvas:newImageData(slice, mipmap, x, y, width, height)` 保持同步 API，并拒绝不可读、仍为活动目标、无效 slice/mipmap 或越界区域。2D、Array、Cube 与 Volume 按 `(slice,mipmap)` 建立并缓存子资源 RenderTarget；mipmapped 或 layered texture 先把指定 layer/face/z-slice 和 mip blit 到同格式 2D staging texture，再读取该级精确字节数。安全子集只允许在 `love.draw` 外且 `SharedView` 没有待提交 view 时调用，典型位置是后续帧的 `love.update`；`love.draw` 内调用必须明确报错。

Canvas 读回保持目标自身的原生 PixelFormat 与字节布局，只有上游规定的 `srgba8` 返回 `rgba8`。真实 Metal 已覆盖 `rgba8` 4× MSAA resolve/裁剪、`r8/rg16/rgba16f/rgba32f` 的格式、字节数与像素转换，以及 2D manual、Array auto、Cube manual、Volume manual 的生成后 mip 像素和指定子资源读回。Dora 的 `LoveNode::render` 运行在 Director 正在构建的全局 `Main/UI` view 栈内，而 bgfx 同步 `readTexture` 必须推进全局 `bgfx::frame()`；此时中断会提前提交尚未完成且尚未设置最终 view order 的宿主整帧，并破坏其他 Dora 节点共用的 `SharedView`。因此 draw callback 内同步读回确定为嵌入式不支持边界，保持受控 Lua 错误，不再规划用 Love pass 暂停/恢复伪装等价支持。P5-03 在非 Metal renderer 验证完成前保持“进行中”；`captureScreenshot(Channel)` 已由 P5-16 完成，不属于 `Canvas:newImageData` overload。

`ImageData:encode` 支持 Love 11.5 声明的全部两种 encoded image format：PNG 与 TGA。LoveRuntime 在编码边界把任意已支持 ImageData 格式转换为 RGBA8；PNG 交给注入的 lodepng backend，TGA 按上游 STBHandler 语义生成无压缩、左上原点的 32-bit BGRA 字节。两者始终返回 `FileData`，默认文件名分别为 `Image.png`/`Image.tga`；只有传入 filename 时才按实例 identity 解析 save 路径，并调用 Dora Content 保存。编码器不得直接使用 stdio 或平台文件 API，写入失败必须作为 Lua 错误返回。EXR 不属于 Love 11.5 `ImageData:encode` 的格式枚举，不能作为本目标的待补项；CompressedImageData 的读取边界由上一段单独定义。

### Present

Love backend 的 `present()` 不交换操作系统窗口缓冲。由于嵌入式 Love state 不运行上游 `callbacks.lua` 的独立窗口循环，Dora 在 LoveNode render phase 中建立一次 graphics frame，调用 `love.draw`，再在回调返回时结束实例 RenderTarget pass。脚本在 `love.draw` 内显式调用 `present()` 时，它作为兼容屏障被接受；同帧多次调用不会重复提交或清空表面，真正的 `endFrame()` 仍严格执行一次。帧外调用会返回可诊断 Lua 错误，避免脚本误以为能够交换宿主窗口。

Love RenderTarget 使用 `SharedView.pushFront` 建立独立 view/framebuffer；VGNode 的 NanoVG framebuffer 同样使用自己的 `pushFront` entry，宿主 NanoVG 和 ImGui 则分别在 Director 的 NanoVG/ImGui view 中提交。各路径必须显式设置自己的 framebuffer、view rect、projection、blend/scissor，不能依赖前一个 pass 的隐含状态。专项验收需在 Love 启用 alpha/add/multiply/scissor 的同一帧同时绘制 VGNode NanoVG scissor 和 ImGui window，并验证三者可见及 cleanup 后资源释放。

### 虚拟 Window settings

LoveNode 的 `love.window` 只描述实例 RenderTarget，不映射为 SDL/系统窗口。`love.conf(t)`、`love.window.setMode` 与 Love 11.5 的 `love.window.updateMode` 支持 width、height 和 resizable；默认 resizable 为 false。运行期 setMode/updateMode 必须先验证全部 settings，再创建新的 RenderTarget，只有 backend resize 成功后才同时提交尺寸与 resizable 状态，失败时旧表面和旧 settings 保持不变。`setMode(width, height, settings)` 从默认配置应用传入 settings；`updateMode(settings)` 保持当前 width/height 并只合并传入字段，`updateMode(width, height, settings)` 则改变尺寸但继续保留未指定的当前 settings。

fullscreen、highdpi 和非 1 的 display 会影响宿主窗口或物理显示器，嵌入模式明确不支持：`conf.lua` 中请求这些模式会让实例启动失败并指出要求，运行期 setMode 则返回 false。getMode 始终报告 fullscreen=false、highdpi=false、display=1 以及当前实例 resizable。实例固定采用 1 Love logical unit = 1 RenderTarget pixel，因此 `love.graphics.getDimensions/getPixelDimensions` 返回同一尺寸，graphics/window 的 `getDPIScale()`、window `getNativeDPIScale()` 均返回 1，`toPixels/fromPixels` 是保留单值或二元重载的恒等逆变换。宿主 Retina/backbuffer scale 只在 Dora 合成 LoveNode 纹理时生效，不得反向改变实例逻辑或像素尺寸。

其余查询按“虚拟表面”而不是宿主 OS 窗口解释。每个 LoveNode 看见一个名为 `Dora LoveNode` 的虚拟 display；desktop/safe-area 尺寸等于当前 RenderTarget，orientation 由宽高推导，位置固定为 `(0, 0, 1)`，没有 icon 或 fullscreen mode。`isOpen` 反映 Runtime 与 graphics backend 是否存活，`isVisible` 反映节点 visibility，`hasFocus/hasMouseFocus` 只反映 Dora 当前输入焦点；焦点在 `love.load` 返回后才由宿主授予，因此 load 阶段可为 false，后续 update 为 true。`isMaximized/isMinimized` 固定为 false。

`t.title` 是 Love 11.5 的标准配置位置；TypeScript 的 `WindowConfig.title` 只保留为既有社区声明兼容别名，不改变 Runtime 读取规则。`setTitle/getTitle`、`setVSync/getVSync` 和 `setDisplaySleepEnabled/isDisplaySleepEnabled` 是 LoveRuntime 实例局部的请求状态，不修改 Dora 应用窗口、交换链或系统睡眠策略；默认值分别为 `Untitled`、`1` 和 `false`。为保持原版 method table，宿主动作入口仍会注册，但语义必须明确：`close` 只关闭虚拟 Love 窗口；`maximize/minimize/restore` 只维护实例状态；`setIcon` 只保存可由 `getIcon` 取回的 ImageData；`setPosition` 只保存单虚拟 display 的位置元数据；`showMessageBox` 是兼容占位，简单形式返回 `false`，按钮形式返回 escape/末尾按钮索引且不会显示对话框；`requestAttention` 是无操作占位。进入 fullscreen 明确返回 `false`，不能把这些行为描述为已经操作 Dora 宿主窗口。

## 输入与事件

输入首先由 Dora 接收，再根据节点状态路由到 LoveNode：

- Touch 和 Mouse 坐标转换为 LoveNode 本地、左上角原点坐标；`dx/dy` 必须由本地 current/previous location 相减得到，不能直接复用 Dora Touch 的世界坐标增量。
- 不可见、已 cleanup 或输入未启用的节点不接收事件。
- 多 LoveNode 重叠时遵循 Dora 的节点命中、吞噬和排序规则。
- 键盘和手柄事件需要明确的焦点归属；首版同一时刻只把这类事件发送给一个 LoveNode。
- 第一个进入场景并启用输入的 LoveNode 默认取得焦点；指针在另一 LoveNode 上开始时把焦点切换给该节点。切换时只调整宿主路由，不在 Love state 之间共享任何输入状态。
- 指针事件按命中节点分别转换为该 LoveNode 的本地坐标；键盘和手柄事件只投递给当前焦点实例。焦点实例销毁后不把事件发送给悬空对象，剩余实例可在下一次指针开始时取得焦点。
- 当前键盘焦点 LoveNode 同时独占 Dora IME：取得焦点时 attach，切换、停止或 cleanup 时 detach；切换时把宿主仍按下的键向旧实例排入 release，避免其 `isDown` 卡住。
- `love.joystick` 的对象和连接/按键/轴状态全部保存在各自 LoveRuntime。LoveNode 从 Dora Controller 快照建立本实例的稳定 Joystick userdata；连接和移除事件同步到所有存活实例，button/axis 只进入当前焦点实例。切换焦点时向旧实例合成仍按下按钮的 release 和活动轴的零值，避免 `isGamepadDown` 与 `getGamepadAxis` 保留失焦前状态。Lua 可见的 Joystick ID、connected index、axis/button index 均保持 Love 的 1-based 语义；GUID、VID/PID/version、原始 axis/button/hat 查询和 rumble 由 SDL GameController/Joystick backend 提供。震动状态按 LoveRuntime 对象记录，但最终设备能力和输出属于 Dora Controller；实例关闭时停止其仍在请求的震动，不把物理设备或 SDL handle 暴露给 Love state。Gamepad mapping 与上游 SDL backend 一样按 GUID 作用于应用级 Controller 映射表，因此多个 LoveRuntime 和 Dora 输入共享修改结果；`loadGamepadMappings` 把现有 Love 虚拟路径优先解析为文件，`saveGamepadMappings(filename)` 只写实例 identity save root，两者的文件数据必须经 Dora Content，Runtime 不直接访问宿主文件系统。
- SDL 的首次按下和自动重复分别进入 Dora `KeyDown`、`KeyRepeat`；LoveNode 将后者映射为 `love.keypressed(key, scancode, true)`。Dora `TextInput` 的 UTF-8 文本进入同一实例 FIFO 并调用 `love.textinput`；`SDL_TEXTEDITING` 的 composition text、start 和 selection length 完整进入 `love.textedited`。
- `love.keyboard` 接入 Love 11.5 的完整九方法面：`setKeyRepeat/hasKeyRepeat`、`isDown/isScancodeDown`、`getScancodeFromKey/getKeyFromScancode`、`setTextInput/hasTextInput/hasScreenKeyboard`。key/scancode 输入由仓库固定 Love 11.5 常量表校验，状态分别保存在各 LoveRuntime；`isDown` 和 `isScancodeDown` 同时支持 vararg 与 table overload。repeat 默认关闭，关闭时宿主 repeat 事件在进入实例队列前丢弃；布局相关双向转换和屏幕键盘能力通过 LoveNode 的 SDL backend 查询当前宿主，不创建上游进程级 Keyboard Module。macOS 确定性场景覆盖字母、控制键、功能键、方向键、左右 modifier、keypad 和 numlock 映射；其他键盘布局及物理 repeat 仍属于平台矩阵。
- `love.keyboard.setTextInput(enable, x, y, w, h)` 的矩形由 Love 左上原点转换为 LoveNode 本地坐标，再通过节点世界变换投影到 Dora 窗口坐标并更新 SDL IME hint；只有当前焦点实例可实际 attach/detach IME。系统候选窗位置仍需在各平台真实输入法下视觉复验。文件拖放和窗口焦点事件按后续支持程度映射。
- `love.mouse` 的 position、visibility、grab、relative-mode 和 active Cursor 请求保存在各 LoveRuntime；只有当前输入焦点 LoveNode 才可把请求提交给 SDL 宿主窗口。`setPosition` 把 Love 左上原点节点坐标经节点世界变换映射到窗口坐标；未聚焦实例只更新自己的逻辑 position，不在随后取得焦点时执行陈旧的指针跳转。取得焦点时重新应用该实例的 visible/grab/relative/Cursor 请求，失焦、停止、重启失败或 cleanup 时统一恢复宿主 `visible=true`、`grab=false`、`relative=false` 和默认 cursor，避免一个 LoveNode 污染 Dora 或另一实例。
- Cursor 是隔离 state 中的真实上游 Love Object，而不是 Dora 全局 Cursor 的状态回显。自定义 Cursor 由原版 wrapper 接收 ImageData 或经 Dora Content 解码的 filename/FileData，再在 backend 边界复制 RGBA8 像素与 hotspot；十二种 system cursor 按 Runtime 缓存，重复查询保持 Proxy identity。`setCursor/getCursor` 与系统缓存通过 Love `StrongRef` 保持对象，不再维护平行 registry 引用；替换、默认恢复、GC、restart 和 state close 都按 Love Object 与 Dora handle 的单一所有权路径释放。宿主不支持 cursor 时 `isCursorSupported` 返回 false，创建失败保留定向 backend 错误。

事件进入实例自己的队列，再由 Love boot 按 Love 规定的 callback 名称调用，例如：

- `love.keypressed`
- `love.keyreleased`
- `love.textinput`
- `love.textedited`
- `love.mousepressed`
- `love.mousereleased`
- `love.mousemoved`
- `love.touchpressed`
- `love.touchreleased`
- `love.touchmoved`
- `love.joystickadded`
- `love.joystickremoved`
- `love.gamepadpressed`
- `love.gamepadreleased`
- `love.gamepadaxis`
- `love.resize`
- `love.focus`
- `love.quit`

`love.event` 直接操作这一个实例私有队列，不另建第二套事件源。`pump()` 是安全 no-op：SDL/平台事件已经由 Dora 主循环采集并路由，Love state 不得再次驱动操作系统 event pump。`poll()` 返回迭代器并按 FIFO 消费；`push(name, ...)` 把自定义事件放入同一队列，自动派发时调用 `love[name](...)`；`clear()` 清空尚未消费的事件。自定义参数支持 boolean、number、string、userdata 和 lightuserdata，遇到第一个 nil 截断；userdata 通过所属 Lua state 的 registry table 保活，消费、clear、quit、错误或 state 关闭时必须解除引用。

标准 LÖVE 主循环中的 `wait()` 可以阻塞等待 SDL 事件，但 LoveNode 的 Lua callback 运行在 Dora 应用线程；在这里阻塞会使负责投递事件的宿主主循环死锁。因此嵌入模式的 `wait()` 只消费当前队首，空队列立即返回零个值。宿主驱动的自动派发仍发生在 `love.update(dt)` 之前；脚本若用 `poll()` 或 `wait()` 手动消费，事件状态也在返回 tuple 前更新，之后不会再重复自动派发。

Mouse 与 Touch 必须在 Dora 输入分发层保留真实来源，不能把触屏事件伪装成 mouse button 1。SDL/Dora 的鼠标按钮按 Love 规则映射为 left=1、right=2、middle=3，并保留 clicks；拖动时只由 `MouseMove` 产生一次 `love.mousemoved`，不得再由 `TapMoved` 重复投递。`love.mouse.isDown` 与 Love 11.5 一致同时接受 button vararg 和 table overload。Touch ID 在隔离 Love state 中以 lightuserdata 暴露，活动触点状态由各自 LoveRuntime 持有；当前 Dora Touch 没有 pressure 字段时使用 1，后续平台提供可信 pressure 后再透传。

`love.event.quit()` 默认请求关闭当前 Love 实例，不直接退出整个 Dora 应用。请求进入当前实例队列；`love.quit()` 返回真值时取消本次退出，未定义 callback、无返回值或返回假值时均接受退出。随后 LoveNode 停止调度和输入，关闭 Lua state，并释放实例 RenderTarget 与资源。

`love.event.quit("restart")` 使用同一 FIFO 和取消语义；`love.event.push("quit", "restart")` 与它等价。接受后 Runtime 只标记 `RestartRequested`，等待当前 callback 栈完全退回 LoveNode 的帧边界，再对发起请求的节点执行完整 `restart()` 生命周期：关闭旧 state，停止并移除 AudioSource、清空 graphics/physics/mount/input 等实例资源，从原 boot 路径经 Content 重新加载 conf/boot/main，最后恢复该节点的输入和调度。它不重启 Dora 应用，也不触碰其他 LoveNode；`love.quit()` 返回真值仍可取消。字符串参数除 `"restart"` 外均明确拒绝。宿主在仅运行一个顶层 LoveNode 的独占模式下，可以选择把普通退出请求提升为应用退出，但这属于宿主策略，不改变 Love 脚本 API。

## 虚拟窗口

LoveNode 将 Love 的窗口概念虚拟化：

- `love.window.getMode()` 返回实例逻辑尺寸和配置。
- `love.window.setMode()` 重建或调整该实例主 RenderTarget。
- `love.window.updateMode(settings)` 或 `updateMode(width, height, settings)` 保留未指定的当前设置，并经同一事务式 resize backend 提交。
- display、desktop、orientation、safe area、position、visibility、focus、open、icon、fullscreen/maximize/minimize 状态查询返回可验证的实例虚拟表面语义。
- title、vsync 与 display-sleep 只保存实例局部请求值，不修改宿主；close、maximize、minimize、restore、setIcon、setPosition 仅提供虚拟表面状态。showMessageBox 和 requestAttention 仅为兼容占位，分别返回明确的占位结果或不执行操作，不声称触发宿主行为。
- 嵌入式表面固定为 1 logical unit = 1 RenderTarget pixel；Dora device pixel ratio 只属于宿主最终合成，不能隐式改变 Love 实例尺寸。
- Fullscreen 不得让任意嵌入 LoveNode 抢占宿主窗口。

后续若增加“Love 独占应用模式”，仍应复用同一个 LoveRuntime，只由宿主策略把部分虚拟窗口操作映射到 Dora Application。

## 文件系统和模块加载

每个 LoveRuntime 拥有独立 filesystem context：

- source root 默认为 boot 文件所在目录。
- save identity 对应独立可写目录。
- 读取优先级保持 Love 语义：save directory 优先于 source。
- 所有项目路径以 Love source root 为相对根。
- 写操作不得逃逸实例可写目录。
- `require()` 使用 Love filesystem searcher，不使用 Dora 主 Lua 状态的模块缓存；Lua 模块模式由 `love.filesystem.getRequirePath/setRequirePath` 按实例配置。

文件系统后端必须遵守以下硬边界：

- boot、conf、main、source 和 save 的文件内容读写、存在性检查、目录创建/删除及枚举，一律通过 Dora `Content` / `SharedContent` 完成。
- LoveRuntime 只计算和校验 Love 虚拟路径、save/source 优先级与 identity，不得使用 `fstream`、stdio 或平台文件 API 直接读写文件。
- LoveNode 在建立 source root 前注入 Content filesystem backend；未注入后端时启动必须明确失败，不能退回进程文件系统。
- 路径 canonicalize 只用于限制绝对路径、`..`、反斜杠和符号链接逃逸，不构成另一条文件读取通道。

当前 Lua API 与 File/FileData 对象方法由 Love 11.5 原版 `wrap_Filesystem`/`wrap_File`/`wrap_FileData` 注册，而不再由 `LoveRuntime` 重写一套方法表。每个 Lua State 创建独立的 `DoraLoveFilesystem` 模块实例，上游 wrapper 通过 state-local module registry 取得它，再由 adapter 调用当前 LoveRuntime 注入的 Content backend。Dora 仅在原版模块表上替换 identity 和 require path 的宿主安全校验，以及 `load` 的 Lua 5.5 字节码诊断与 TS/Teal/Yue 行号映射；这三个边界不构成第二套公开 API。

当前基础子集包括 `setIdentity/getIdentity/getSource/getSaveDirectory`、`getWorkingDirectory/getUserDirectory/getAppdataDirectory/getSourceBaseDirectory/getExecutablePath/getRealDirectory`、`getRequirePath/setRequirePath`、`read/write/append/load/lines/getInfo/createDirectory/remove/getDirectoryItems`、`mount/unmount/isFused`，以及 `newFile/newFileData`。Love 11.5 仍导出的 deprecated `exists/isDirectory/isFile/isSymlink/getSize/getLastModified` 也保留：前五项复用同一 Content 虚拟路径解析，归档/source/save 都不会绕过实例边界；Dora Content 不提供修改时间，因此 `getLastModified` 对存在项按 Love 的“无法确定日期”约定返回 `nil, error`，而不是伪造时间戳。File 支持 `r/w/a`、read/write/flush/seek/tell/lines、EOF、buffer 状态和文件名查询；FileData 支持 clone、文件名/扩展名及 Data 的 string/size/pointer 查询。写入只进入 `Content.writablePath/Love/<identity>`；读取、脚本 `load`、行迭代、File 内存快照和 `require()` 均按 save、运行时 mount、source 的顺序解析。File 的打开和刷新分别调用 Content load/save，不能持有或创建平台文件句柄。`load` 只能从 Content 取得源码后在当前隔离 Love state 中建立文本 chunk，`lines` 迭代 Content 返回的内存字符串；两者均不得调用 `loadfile`、`io.lines` 或平台文件 API。

Lua require path 默认与 Love 11.5 一致为 `?.lua;?/init.lua`。`setRequirePath` 接受分号分隔模式并把每个 `?` 替换为点号模块名对应的相对路径；空字符串可关闭文件模块搜索。模式只改变该 LoveRuntime 的 confined searcher，解析结果仍按 save→mount→source 经 Content 查询；绝对路径、反斜杠、盘符和 `.`/`..` 逃逸被拒绝，并限制总长度与模式数量。`package.path`、`package.cpath` 继续保持为空，native C loader、LuaJIT FFI 和宿主进程路径均不会因这个接口重新开放；C require path 暂不支持。

独立 LoveNode 不拥有宿主进程 cwd，因此 `getWorkingDirectory` 映射为该实例的 source root；`getUserDirectory` 映射为 Dora Love save base 的父级可写边界，`getAppdataDirectory` 映射为 identity 的 save base，`getSourceBaseDirectory` 返回 source root 的父目录。`getExecutablePath` 按 Love 11.5 返回实际 Dora 宿主进程的可执行文件路径：Apple 使用 main bundle executable，Windows 使用当前 module，Linux/Android 使用当前进程 executable；它是只读身份查询，不进入 Love 的 save→mount→source resolution，也不授权脚本用绝对路径绕过 Content 读取宿主文件。其余路径查询是嵌入宿主的稳定 Content 路径语义，不伪装成可由 Love 绕过 Content 访问的操作系统目录。`getRealDirectory` 复用同一 save→mount→source resolution：返回实际命中项所属 root，缺失或不安全路径返回 nil/error；mount 命中会返回该实例 staging root，unmount 后立即失效。`setSymlinksEnabled/areSymlinksEnabled` 继续不注册：Dora Content 当前没有可强制执行的全局 symlink policy，虚构一个可写布尔状态会错误承诺安全效果；source、save、mount 和 `.love` staging 仍分别依靠 canonical confinement 与拒绝归档 symlink 保持边界。

目录形式和标准根目录含 `main.lua` 的 `.love` zip 包均可作为 LoveNode boot 输入。`.love` 本体必须先由 `SharedContent.load` 读入内存，再交给 Dora 自带 Zip reader；不得让 Zip/PhysFS 自行按平台路径打开归档。为继续复用 TextureCache、FontCache、SoLoud 和 ShaderCompiler 的 Content 路径，安全条目只通过 `SharedContent.createFolder/save` 写入 `Content.writablePath/LovePackages/<instance-generation>` 的独立 staging source root，不能把归档加入全局 Content search path。每次 restart 使用新 root，stop、失败或 cleanup 后删除所属 root，不影响同时运行的其他 LoveNode。

归档入口必须限制为最多 4096 个文件、单文件最多 256 MiB、总展开数据最多 512 MiB，并拒绝绝对路径、反斜杠、盘符、空组件、`.`/`..` 和缺失根 `main.lua`；只提取普通文件，因此不得创建归档声明的 symlink。

运行时 `mount` 接受 Love 虚拟路径中的 zip 文件或 FileData。归档先经当前实例的 filesystem resolution 与 Content backend 取得内存，再使用相同条目安全/容量限制，经 Content staging 到 `Content.writablePath/LoveMounts/<instance-generation>`；挂载点只进入该 LoveRuntime 的有序 mount 表，不加入 Dora 全局 search path。`appendToPath=false` 在当前实例挂载表前插，true 后插；save 继续优先于 mount，source 位于 mount 之后。`read/load/lines/getInfo/getDirectoryItems/require` 都消费同一挂载视图，FileData 由 Lua registry 保活直至 unmount/close。显式 unmount、实例 stop/restart、失败和 cleanup 必须删除 staging。嵌入 LoveNode 永不与宿主可执行文件 fused，因此 `isFused()` 恒为 false；可变 fused 模式及其路径 API 不在当前宿主模型内。

Love 状态不直接安装 Dora 源码 loader，因此不会在运行时自动编译 `.ts`、`.tsx`、`.yue` 或 `.tl`。开发和构建阶段由 Dora 工具链生成 Lua 5.5 产物，Love loader 只负责加载最终 Lua 模块。

## 音频

`love.audio` 使用 Dora 的 `AudioBus`、`AudioSource` 节点和同一套 SoLoud 设备。每个 `LoveNode` 内部固定组合一个实例父 AudioBus；每个 Love `Source` 再拥有一个子 AudioBus 和一一对应的 Dora `AudioSource` 子节点，路由为 `AudioSource -> Source effects Bus -> LoveNode Bus -> SoLoud root`。不能把多个可并发且需要独立 pause/seek/loop/pitch/filter/effect 的 Love Source 压缩到单个普通 AudioSource。一个 LoveNode 可持有多个 Source，但 bus、节点、userdata 和 voice 均不得跨实例共享。

内部路由容量与 active Source 数必须分开。SoLoud resampler table 配置为 255，仅用于容纳 LoveNode 父 Bus、每 Source 子 Bus 和候选 voice，并受其 8-bit resampler-owner 索引上限约束；它不是“255 个声音同时可辨识”的承诺。`mVoice` 保留仍存活的全部 voice，SoLoud 现有的单一 `mActiveVoice` 只是当前获得重采样缓冲并进入混音的工作集；mandatory ticking Bus 不占 Source 预算，Dora 应用最多选择 32 个 leaf Source。候选超过预算时按 Source 自身/3D `overallVolume` 继续乘以 Source effects Bus 和 LoveNode 父 Bus 的路由音量，保留最终增益最高的 32 个；未选中的 Source 仍保留有效 handle 和 playing 状态，不设置 `PAUSED` 标志，之后在音量、3D 状态或 voice 生命周期使 active 集合变脏并重排时仍可重新入选。因此适配层不再抽象“激活列表 + 可听列表”，也不另建虚拟 voice 状态机。

预算落选采用暂停式播放位置语义，但不伪装成显式 `Source:pause()`：`mStreamTime` 仍为全部未显式暂停 voice 推进，用于 fader 和 schedule；`mStreamPosition` 只为当前 `mActiveVoice` 推进，Love `tell` 读取后者。active owner 被替换时，SoLoud 在该 voice 上保存两块 decoder read-ahead/resampler 数据，重新入选时恢复，因此 static、stream 和 queueable Source 均不会因共享 resampler 槽被复用而跳过已解码但尚未播放的样本；virtualized seek 会废弃旧快照并从新位置建立状态。快照不是第二份 voice 列表；存储在 voice 初始化时预分配，active 切换的音频线程只做内存复制，避免实时路径分配。每个 voice 的大小为 `2 × 512 × channels × sizeof(float)`（mono 4 KiB、stereo 8 KiB、最多 32 KiB），随 voice 析构释放。有限长度 Source 在预算外不推进位置或自然结束，重新入选并实际消费完数据后才结束。这样既保留纯 Love API，不增加 `DoraHost` 或非标准 priority 方法，也避免大量环境声掩盖重点音效。Bus 数超过 255 的异常负载必须安全降级，不得再次出现未映射 resample buffer 的音频线程崩溃。

Love 11.5 Effects 明确采用 SoLoud 近似适配，不引入 OpenAL Soft。`Source:setFilter` 占用子 Bus 的 filter slot 0；`Source:setEffect` 按名字绑定当前 Runtime 的效果定义，并使用 slot 1～3，因此 `getMaxSourceEffects()` 固定为 3，`getMaxSceneEffects()` 固定为 64。命名效果、direct filter 和 Source effect 绑定属于各自 LoveRuntime；clone 得到独立子 Bus 并复制设置，删除命名效果会解除该 Runtime 内所有 Source 的同名绑定。所有 LoveNode 与普通 Dora 音频共同进入应用级 SoLoud 的同一个 `mActiveVoice` 工作集，由全应用统一执行 32 个 leaf Source 的预算选择；不得为 LoveRuntime、LoveNode 或“可听状态”再维护第二份 voice 激活列表。listener、Doppler 和 distance model 同样是应用级共享状态。

近似映射为：direct low/high/band-pass → `BiquadResonant`，reverb → `FreeVerb`，chorus/flanger → `Flanger`，echo → `Echo`，ringmodulator → `Robotize`，equalizer → `Eq`，distortion/compressor → `WaveShaper`。Love 参数表与查询 API 保持，但部分参数只能参与启发式映射。SoLoud 的四槽串联链不等价于 OpenAL 的并行 auxiliary send：不承诺逐采样一致、共享 effect tail、发送滤镜频响或所有参数听感等价；这些差异必须保留在支持矩阵和发行说明中。

`Source:clone()` 复用原 Source 已经通过 Content 创建并由 SoLoud 解码的不可变 AudioFile，但必须为 clone 新建独立 Dora AudioSource 子节点和 Love handle。clone 复制 source type、volume、pitch 与 looping 配置，以停止状态和位置 0 开始；之后任一对象的播放、pause、stop、seek 和属性修改不得影响另一个。`getDuration` 以及 `seek/tell` 支持 Love 的 `seconds`/`samples` 双单位；duration 的 samples 直接使用 SoLoud 解码所得原始 sample count，不由浮点秒数反算。

`love.audio.newQueueableSource(sampleRate, bitDepth, channels, buffers)` 使用 Dora 内部的 `PCMQueueFile`/SoLoud 动态 AudioSource，不写临时文件，也不绕过 Content 边界。格式严格限制为 Love 11.5/OpenAL 路径支持的正采样率、8/16-bit、mono/stereo；`buffers < 1` 使用默认 8，最大 64。`Source:queue(soundData[, length] | soundData, offset, length)` 的 offset/length 均为 byte，必须匹配 Source 格式并按完整 sample frame 对齐；零长度成功但不占槽，队列满返回 false。Mixer 消费完整 buffer 后 `getFreeBufferCount()` 立即归还槽位，允许播放中继续补入 PCM；`stop` 同时停止 voice 并清空队列。queue Source 的 type 为 `queue`、不得 looping，clone 复制 Source 属性和队列格式/容量，但按 Love 语义从空队列、停止状态开始。mono queue Source 继续使用单声道空间 API，stereo queue Source 走普通二维播放。

模块级 `love.audio.play/pause/stop` 同时接受 Source vararg 和 Love 11.5 的 Source table 形式。无参数 `pause()` 只暂停调用时仍处于 playing 的 Source，并返回这些对象原有 userdata 组成的数组；已经 paused/stopped 的对象不会重复出现在结果中。Runtime 以 handle 到 userdata 的弱值 registry 完成回查，不能为了返回列表创建第二个包装对象，也不能因此延长 Source、AudioSource 子节点或 SoLoud voice 的生命周期。

`love.audio.getActiveSourceCount()` 遍历当前 LoveRuntime 自己持有的 Source handle，并以 backend 的 playing 或 paused 状态计数；尚未播放、已经 stop、自然播放结束或已释放的 Source 不计入。paused Source 仍占用 Love 的 active source pool，因此必须继续计数。该查询不得使用 Dora/SoLoud 的进程级总 voice 数，否则多个 LoveNode 和宿主音频会相互污染。

`love.sound.newSoundData` 与 Source 共用 Content-only 输入边界，但对象本身是所属 Love state 内的 CPU PCM 数据，不创建 AudioSource 子节点或 SoLoud voice。文件名先按 save/mount/source 规则解析，再由 `SharedContent` 读为内存，由 LoveNode 注入的 SoLoud decoder 解码；decoder 的 float 输出转为 Love SoundData 的 interleaved 16-bit PCM。数值构造支持 Love 的 8/16-bit、采样率、声道和帧数参数；逐样本 API 保持 0-based frame index、可选 1-based channel 语义，无 channel 时按底层交错 sample index。基础实现对参数、非有限样本、索引、声道和解码 metadata 做检查，并把单个 SoundData 限制在 256 MiB，防止脚本参数触发无界分配。`love.audio.newSource(soundData)` 把 PCM 封装为内存 WAV 并创建所属 LoveNode 的 static AudioSource 子节点，不写临时文件；之后 Source 仍由 Dora SoLoud voice 管理。WAV、Vorbis OGG、MP3 与 FLAC 已通过真实 Content→SoLoud 格式矩阵。

`love.sound.newDecoder(filename|FileData, bufferSize)` 复用同一 Content→SoLoud 解码入口。当前 Dora backend 没有向上暴露可逐块推进的 codec handle，因此 Decoder 在创建时保存一次完整的 16-bit interleaved PCM 快照，在所属 Love state 内维护独立 byte cursor；`decode` 按 bufferSize 返回整帧 SoundData，`seek`、`clone`、duration/sample-rate/bit-depth/channel 查询及 `newSoundData(decoder)` 的“从当前位置读到 EOF”语义均在这层完成。默认 bufferSize 为 16384 bytes，单个解码结果和显式 bufferSize 都受 256 MiB 上限保护。Decoder 不创建、组合或持有 Dora AudioSource 子节点，也不产生 SoLoud voice；只有把结果交给 `love.audio.newSource` 后，才进入 `LoveNode 1 -> 1 AudioBus + 0..N AudioSource` 的节点和播放生命周期。

- 音频文件先由 Love filesystem 解析 source/save 路径，再且只能通过 `SharedContent.load` 取得数据；不得使用 Love/SoLoud 自带文件 API 或 stdio 回退。
- `static` 数据构造 Dora `WavFile`，`stream` 数据构造 Dora `WavStream`，随后把已解码 `AudioFile` 注入 `AudioSource`，避免 `AudioSource` 再次按路径读取。
- `queue` 数据由 `PCMQueueFile` 把每次 SoundData byte range 转为 SoLoud planar float buffer；队列的 slots、PCM 和 voice 仍属于创建它的 LoveNode，不能跨 state 共享。
- Source 的 play、pause、stop、seek、loop、volume 和 pitch 保持 Love 行为。
- Source clone 共享 AudioFile 而不重复读取 Content，独立组合 AudioSource 节点与 voice；clone 失败不得登记半成品 handle 或节点。
- `love.audio.setVolume/getVolume` 控制并查询当前 LoveRuntime 的实例音量；backend 把它写到所属 AudioBus，因此不会改变 Dora 全局音量或其他 LoveNode。尚未创建 Source 时设置也必须对之后路由进 Bus 的 Source 生效。
- `love.audio.setMixWithSystem` 按固定 Love 11.5 行为只在 iOS 修改应用级 `AVAudioSession`：`true` 选择可与其他应用混音的 Ambient category，`false` 选择 SoloAmbient，并返回平台调用的真实成功值；其他平台返回 false。`love.conf(t)` 提供默认 `t.audio.mixwithsystem=true` 并在配置阶段走同一入口。音频会话不是 LoveNode 私有资源，多个实例遵循最后一次写入生效；该设置不创建 Source、Bus、voice 或第二份 mixer 状态。
- 单声道 Source 支持 `set/getPosition`、`set/getVelocity`、`set/getDirection`、`set/getCone`、`set/getAirAbsorption`、`setRelative/isRelative`、`set/getAttenuationDistances` 与 `set/getRolloff`。这些属性属于各 Source，并在 clone 时复制到新建的独立 AudioSource；播放前和播放中设置都必须进入对应 SoLoud voice。Love 坐标使用 AudioSource 的显式 3D 位置，不跟随 LoveNode 在 Dora 场景树中的视觉变换。多声道 Source 调用这些空间 API 时按 Love 语义明确报错。cone angle 采用 Love 11.5 的弧度接口并按其 OpenAL backend 量化为整数角度；SoLoud mixer 按 source direction 与 source→listener 夹角，在 inner/outer cone 之间分别插值基础 outer volume 与 `outerHighGain`。空气吸收在超过 reference distance 后按 `(distance-reference) × rolloff × factor` 计算，并使用 OpenAL Soft 默认每米高频增益 `0.99426`。cone HF 与空气吸收相乘后进入以 5 kHz 为 reference 的 high-shelf，公式采用 RBJ Audio EQ Cookbook；gain 最低按 OpenAL 路径限制为 `0.001`。
- `Source:set/getVolumeLimits` 对单声道和多声道 Source 均可用。Love 创建 Source 时显式启用默认 `[0, 1]` 限制，最终 voice gain 使用 `min(minVolume,maxVolume)` 与 `max(minVolume,maxVolume)` 钳制，允许 setter 保留 `minVolume > maxVolume` 的 Love 状态。普通 Dora AudioSource 默认不启用该钳制，避免 Love 兼容语义反向改变宿主音频。
- Source GC 时停止并移除对应 `AudioSource` 子节点；实例销毁和重启时停止并清理该实例创建的所有 AudioSource/voice。
- LoveNode 销毁或重启时先让 Runtime 逐个停止并移除 Source，再释放实例 AudioBus；音频设备不可用时不创建 Bus，但仍保持 Content 解码、Source 节点安全操作和退出释放路径。
- Dora 场景树是 AudioSource 的强所有者，Love userdata 只保存所属 runtime 和不透明 handle；不得向 Love state 暴露 Dora 节点或允许脚本把它改挂到其他父节点。
- 不允许持有已销毁 LoveRuntime 的回调或音频 userdata。
- 音频设备不可用时返回可诊断的失败，不得空指针解引用。
- Dora 构建默认以 `DORA_AUDIO_BACKEND=0` 选择 SoLoud `AUTO` backend；平台验收可覆盖为无效 backend，直接触发真实 `SharedAudio.init()` 失败。失败后 `Audio`、`AudioBus` 和 LoveNode 组合的 `AudioSource` 所有入口必须安全返回；Source 节点仍由所属 LoveNode 持有，GC/退出时正常移除。
- 录音不进入 SoLoud 输出混音链。`love.audio.getRecordingDevices()` 通过 Dora 已有 SDL2 backend 枚举 capture device；每个 LoveRuntime 缓存稳定的实例私有 `RecordingDevice` userdata，`start(samples, rate, bits, channels)` 打开独立 SDL capture handle，回调只向以 `samples` 为上限的 8/16-bit mono/stereo PCM buffer 写入完整 frame。`getData()` 原子取走当前 buffer 并构造所属 Lua state 的 `SoundData`，`stop()` 先返回剩余数据再关闭设备；restart、GC、LoveNode cleanup 都必须关闭 handle。录音字节只存在内存，不走 Content，也不送入 SoLoud；macOS/iOS 包含麦克风用途说明，Android 声明 `RECORD_AUDIO` 并沿用 SDL 的运行时权限请求。设备拒绝、被拔出或独占失败按 Love 语义使 `start()` 返回 false。自动化使用可审计 capture mock 验证格式、边界、消费和释放；真实物理输入与权限对话框必须在平台设备矩阵中单独验收。
- 空间音频以 Dora 应用为一个共同声场，不在多个 LoveNode 之间隔离：`love.audio.setPosition/getPosition`、`setOrientation/getOrientation`、`setVelocity/getVelocity`、`setDopplerScale/getDopplerScale` 与 `setDistanceModel/getDistanceModel` 直接读写同一套 Dora/SoLoud 声场状态，多个写入者遵循最后写入生效。Doppler scale 与各 Source 的 doppler factor 相乘，0 禁用 Doppler；负数沿用 Love/OpenAL 行为而忽略。distance model 默认 `inverseclamped`，完整支持 `none/inverse/inverseclamped/linear/linearclamped/exponent/exponentclamped`；公式按 OpenAL 的 reference/max distance 与 rolloff 规则实现，unclamped 模型不借用 SoLoud 原有始终 clamp 的公式。Love Source 使用应用模型入口，因此任一 LoveNode 改变模型都会影响所有 LoveNode 的 3D Source；普通 Dora AudioSource 显式选择的逐 Source 衰减模型继续保持，不被 Love 兼容层覆盖。任一 Love listener setter 被显式调用时，Dora 的自动 Node listener 跟随会被解除，避免下一帧覆盖脚本设置；如项目需要 Node 跟随，应由宿主重新设置 Dora `Audio.listener`。这些共享规则不改变 LoveRuntime 的 Source 所有权、direction/cone/air absorption/volume limits、active source 计数和实例 AudioBus 音量隔离。高频滤波只对 Love Source 使用的 `ApplicationDistance` voice 生效，普通 Dora AudioSource 不被自动套用 Love 的 shelf。

这里的“应用级共享声场”只指唯一 listener 及其传播参数，不等于共享整个 `love.audio` 模块状态。`love.audio.setEffect` 创建的命名效果定义、每个 Source 的 direct filter、效果绑定和 active-effect 列表属于发起它们的 LoveRuntime/LoveNode；同名效果可以在两个隔离 Love state 中使用不同参数，不得互相覆盖。实际 DSP 统一由同一个 Dora/SoLoud mixer 计算，路由保持 `LoveNode parent Bus -> Source child Bus -> AudioSource` 的实例所有权边界。

当前基础 Image、ImageData、SoundData、Font 和 Source 创建均为同步操作：Content 读取、解码、缓存查找和实例句柄登记在构造函数返回前完成；不得为了表面异步而转用 Dora Cache 的 `loadAsync`。当前唯一已接入的异步资源完成路径是截图读回，它持有 LoveNode 弱引用和 runtime generation，完成时先验证实例仍存活且 generation 一致，不捕获裸 `LoveRuntime*` 或 `lua_State*`。未来 Love Thread、Video 或其他异步 API 必须复用同一生命周期规则。

Texture 和 Font 可以命中 Dora 全局不可变缓存，但 Love Image/Font userdata、backend handle 和当前字体状态必须保存在各自 LoveRuntime。一个实例关闭只删除自己的句柄和引用，不得卸载仍被其他 LoveNode 使用的缓存对象。Audio Source 不进入全局 AudioCache：每个 Source 都持有自己已解码的 AudioFile 和所属 LoveNode 子节点。

资源 soak 判断必须使用 live object/resource 计数而不是只看进程 RSS。LoveNode 退出或 restart 时要立即清空自己的 Texture/Font/Audio handle、AudioSource 子节点、RenderTarget 引用和 Lua allocator；Dora RenderTarget/Object 随后可能在全局自动释放池中暂存到周期回收点，系统 allocator 也可能保留 RSS high-water。验收应证明多个回收周期后 Object/Texture 回到同一基线、Font/AudioFile 不累计，并同时检查实例 stopped 时 texture 与 children 已归零。

## 物理

### 当前实现：Love 原版 Box2D 封装

`love.physics` 直接编译 Love 11.5 随附并修改过的 Box2D 2.3.2，以及 `modules/physics/box2d` 下的原版对象实现和 Lua wrapper。World、Body、Fixture、Shape、Contact 与十一类 Joint 的创建、过滤、回调、显式销毁、拓扑所有权和 Lua Proxy 生命周期都沿用 Love 原版代码；`World:update` 直接且只调用一次 Box2D `Step`，不创建 Dora `PhysicsWorld`、Dora `Node` 或 PlayRho handle 中间层。

Dora 原生 `Body`/`PhysicsWorld` API 仍使用 PlayRho。两套物理引擎在产品边界上彼此独立：Dora 项目继续获得现有 PlayRho 行为，Love 项目获得与 Love 11.5 相同的 Box2D 行为，任何一边的过滤、单位或求解规则都不再改写另一边。

为适配 Dora 的多 LoveNode 独立 Lua state，只保留两项宿主化修改：Physics Module 按 `lua_State` 从 Love registry 查找，而不是使用进程级 singleton；meter 的存储也归属各 Physics Module，进入任一物理 wrapper 时激活该 state 的 meter。Box2D 算法、对象关系、公开 wrapper 和参数规则不改写。双 LoveNode 交错测试已验证 `meter=30` 与 `meter=60` 分别得到 30 与 60 的位移，状态不串扰。

### 已废弃的 PlayRho 适配方案（历史记录）

以下内容记录此前的 Dora/PlayRho 适配实现及其验证依据，已被上面的原版 Box2D 接入取代，不代表当前源码架构。

vendored Love 11.5 physics 基于旧版 Box2D，并把 meter 和 Module 生命周期放在进程静态状态；Dora 2D physics 则基于 PlayRho，固定采用 `PhysicsWorld::scaleFactor = 100`。直接把上游 Lua binding 注册进多个独立 Love state 会让 `setMeter` 和对象所有权跨 LoveNode 泄漏，因此首批不直接复用上游 Module singleton。

不以“新版 Love 已切换 Box2D 3”为理由替换 Dora 的 PlayRho backend。仓库固定的 Love 11.5 明确携带 Box2D 2.3.2；截至 2026-08-04 核对的 Love 上游 `main` 也仍使用 `b2World`/`b2Fixture`、`SetContactFilter` 和 `Step(dt, velocityIterations, positionIterations)` 的 Box2D 2.x 对象模型。Box2D 3 是 C17 handle/event-based 的完整重写，contact begin/end 主要改为 step 后事件数组，Joint 集合和求解行为也不等同于 Love 11.5；把 Dora 内置物理整体替换过去会同时破坏 Dora 的 Body/Fixture/Joint ABI、0～31 group matrix、同步 Lua 回调和现有项目行为，不能作为 Love 兼容层的实现步骤。

`contactFilter` 也不是 Box2D 3 中应删除的概念。Box2D 3 仍提供 category/mask/group filter 与 `b2World_SetCustomFilterCallback`，但 custom callback 要求线程安全且不得读写 World；Dora 的 `Body:onContactFilter`、`PhysicsWorld:setShouldContact` 和 Love `World:setContactFilter` 属于不同的公开语义，必须分别保留并在 backend 边界适配。若未来独立评估 Box2D 3 backend，应先建立并行实验 backend、API 行为对照和迁移层，不能从主线直接删除这些接口。

Box2D 3 的单面 segment/chain 同样不能反向改变 Love 11.5 双面 Edge/Chain 语义。Dora 若需要单面 Edge，应作为显式的新 shape/configuration 能力加入 PlayRho，并单独验证正面碰撞、背面穿越、凹凸连接、raycast、sensor、CCD/TOI 和 debug draw；Love 11.5 backend 继续走当前 connected-edge 双面 normal-cone 路径。只有未来目标版本的 Love API 本身采用单面 Chain 时，才在版本化的 Love adapter 中选择该模式。

当前采用 state-local Love 对象层与 LoveNode physics backend：每个 LoveRuntime 持有自己的 meter（默认 30）和 World/Body/Shape/Fixture/Joint userdata，每个 LoveNode 为这些 handle 组合独立的 Dora `PhysicsWorld`、`Body`、`FixtureDef`/PlayRho shape 与 `Joint`。userdata 只持不透明 handle并通过 uservalue 建立 Body→World、Fixture→Body+Shape、Joint→两 Body 的强引用；对象不能跨 Love state 使用，stop/restart 时按 Joint→Fixture→Body→Shape→World 顺序释放。

Love World 不加入 Dora 场景树的自动物理调度，只由 `World:update(dt, velocityIterations, positionIterations)` 显式推进，避免宿主帧与 Love 调用双重 step。Love meter 只参与当前实例的像素/米换算，转换到 Dora 固定 100 px/m 后调用 PlayRho，绝不修改 Dora 全局 scale factor。Love 的左上原点坐标、弧度角度、速度、重力与 impulse 均在 backend 边界显式转换。

当前已接入 `set/getMeter`、World 创建/更新/重力与全局 sleepingAllowed，static/dynamic/kinematic Body 的位置/角度、完整 transform、局部/世界 point/vector/points 转换、指定点线速度、线速度/角速度、线性/角阻尼、质量数据的读写/重算、gravity scale、局部/世界质心、fixed rotation、awake/sleepingAllowed/active/bullet、运行时 type 切换、线性/角冲量、force/torque，Circle/Rectangle/Polygon/Edge/Chain Shape、Fixture 完整对象 API，以及 Love 11.5 的全部十一类 Joint：Distance、Revolute、Prismatic、Weld、Friction、Rope、Pulley、Wheel、Mouse、Motor 与 Gear；同时支持 World/Body/Fixture/Joint 的 `destroy/isDestroyed` 及 `World:queryBoundingBox`/`World:rayCast`。Fixture 已包含 type/density/friction/restitution/sensor、原 Body/Shape 身份、testPoint、单 Fixture rayCast、filter/category/mask/group、state-local userdata、child AABB 与 mass data。Joint 通用层已包含 anchors、reaction force/torque、collide-connected 与 state-local user data；DistanceJoint 支持 length、frequency、damping ratio 的查询和运行时调整；RevoluteJoint 支持共享或独立世界锚点、显式 reference angle、joint angle/speed、motor enable/speed/max/current torque，以及 angular limits 的完整查询和调整；PrismaticJoint 同样支持两种锚点重载及显式 reference angle，并完整提供 world axis、linear translation/speed、motor enable/speed/max/current force 和 linear limits；WeldJoint 支持共享/独立锚点、显式 reference angle，以及 frequency/damping ratio 的查询和运行时调整；FrictionJoint 支持共享/独立世界锚点及 max force/torque；RopeJoint 支持独立世界锚点、collide-connected 及 max length 的查询和运行时调整；PulleyJoint 支持双 ground anchor、双 Body anchor、当前 segment length 和 ratio 查询；WheelJoint 支持 suspension translation/axis、spring frequency/damping 和旋转 motor 完整查询与调整；MouseJoint 支持 target、max force、frequency 与 damping ratio；MotorJoint 支持 linear/angular offset、max force/torque 与 correction factor；GearJoint 支持 ratio 读写及两个源 Joint 身份查询。World 的 sleepingAllowed 会立即作用于已有 Body，并成为后续新 Body 的初值。Body 的 active 直接映射 PlayRho enabled，bullet 映射 impenetrable/连续碰撞检测；type 切换交给 World 级 `SetType` 重建对应质量状态。Body 的线性量和 local center 按 meter 缩放一次，惯量、torque 与 angular impulse 按 meter² 缩放；Love 物理接口的角度和角速度保持弧度及弧度每秒，RevoluteJoint 不经过 Dora 高层 Joint 工厂的角度制和符号转换。

PrismaticJoint 也绕过 Dora 高层 Joint 工厂，直接用 PlayRho `PrismaticJointConf` 表达 Love 的独立双锚点、归一化世界轴与显式弧度 reference angle。Love/Box2D 构造后的默认线性 limits 为 enabled 且 `[0, 100 m]`，因此 getter 必须按当前 state-local meter 返回 `[0, 100 * meter]` 像素，不能改成更直观的 disabled。PlayRho 内部把 prismatic motor speed 以带角速度量纲的字段保存，并在求解器中乘 `Meter/Radian` 还原线速度；backend 边界因而显式以 `pixel/s ↔ (pixel/meter)·radian/s` 映射，max/current motor force 则只按 meter 缩放一次。

WeldJoint 同样直接构造 PlayRho `WeldJointConf`，因为 Dora 高层 weld 工厂只表达单一世界锚点，不能无损保留 Love 的独立双锚点和显式弧度 reference angle。frequency 与 damping ratio 通过原 Joint config 更新真实约束，不只缓存 Lua 属性；设置后保持原 Joint userdata、两端 Body 强引用和 World/Body 级联销毁关系。

FrictionJoint 直接构造 PlayRho `FrictionJointConf` 以保留 Love 两种锚点重载。max force 在 Love pixel 与 PlayRho meter 边界缩放一次，max torque 缩放 meter²；默认值均为零，运行时 setter 修改真实约束。真实零重力场景的首 step reaction 精确达到配置的 `64 px-force` 与 `256 px²-torque` 上限，随后把动态刚体的线速度和角速度衰减到零。

RopeJoint 直接构造 PlayRho `RopeJointConf`。Love 构造参数中的两个锚点是世界坐标，backend 在创建时转换为各 Body 的局部锚点；max length 在 Love pixel 与 PlayRho meter 间只缩放一次，`setMaxLength` 原位修改真实约束。它是只限制最大距离的单侧约束：真实零重力场景把初始相距 128 px 的 Body 拉回 64 px 上限，放到 32 px 时保持松弛，把上限改为 96 px 后再向外加速则止于 96 px；首 step 反力为 `-353.429 px-force`。

PulleyJoint 使用 PlayRho `GetPulleyJointConf` 从 Love 的两个世界 ground anchors 和两个世界 Body anchors 同时生成局部锚点及初始参考绳长，ratio 必须为有限正数，默认 `1`，`collideConnected` 按 Love 11.5 特例默认为 `true`。`getLengthA/B` 不能返回 config 中的初始参考长度，而要用当前 Body 世界锚点到固定 ground anchor 的距离实时计算。真实零重力场景以 ratio 2 推动 A 端向下，最终 `148.000076 + 2 × 75.999954 = 299.999985`，A/B 速度分别为 `+95.999985/-47.999992 px/s`，证明原生约束保持 `lengthA + ratio × lengthB ≤ initial constant`。

WheelJoint 直接构造 PlayRho `WheelJointConf`，支持 Love 的共享锚点和独立双锚点重载；世界 axis 先归一化再转换为 Body A 局部轴，独立的 Body B 世界锚点单独转换，不能退化为 PlayRho 的单锚点 helper。translation 按 meter 缩放，motor speed 保持 rad/s，max/current motor torque 按 meter² 缩放，spring frequency/damping 原位更新真实 config。Love 11.5 的 `getJointSpeed` 实现会对 Box2D 相对角速度调用 `scaleUp`，因此兼容层也保留这一历史行为：meter 64、真实相对角速度 2 rad/s 时返回 128。真实场景同时验证 32 px 悬挂位移收敛到近零、motor 达到 2 rad/s 和首步 torque `188.49556`。

MouseJoint 直接映射 PlayRho `TargetJointConf`。PlayRho 内部会把被拖动 Body 放在约束的第二端，但 Love 对外的 `Joint:getBodies()` 必须固定返回被拖动 Body 和 `nil`；因此 backend 资源显式把该 Body 记录为 Love 侧 bodyA，同时仍以真实 TargetJoint config 计算 anchors、reaction 与级联销毁。构造拒绝 kinematic Body，默认 max force 为 `1000 × Body mass` 的 Love 线性 force 单位，默认 frequency/damping 为 `5 Hz/0.7`；target 与 max force 按 meter 缩放一次，frequency/damping 原位更新真实约束。真实零重力场景把动态圆从 `(0,0)` 拖到 `(96,32)`，并验证销毁 Body 会级联销毁 MouseJoint。

MotorJoint 直接映射 PlayRho `MotorJointConf`。默认 linear/angular offset 取构造时 Body B 相对 Body A 的位置与角度，默认 max force/torque 为零、correction factor 为 `0.3`；显式 correction factor 限制在 `[0,1]`。linear offset 和 max force 按 meter 缩放一次，max torque 按 meter² 缩放，angular offset 保持弧度；所有 setter 都原位更新真实约束。真实零重力场景把 Body B 从构造时相对位置 `(60,30)` 驱动到目标 offset `(20,-10)`、角度 `0.25 rad`，并验证 reaction、Body 身份、anchors 和销毁级联。

GearJoint 使用 PlayRho `GetGearJointConf` 从两个已有 RevoluteJoint/PrismaticJoint 的真实 JointID 构造，默认 ratio 为 `1`、collide-connected 为 `false`，ratio 只要求有限并允许零值或负值。Gear userdata 额外强引用两个源 Joint，backend 资源也记录两条依赖；销毁任一源 Joint 时先级联销毁依赖 Gear，再销毁源约束，避免 PlayRho Gear 配置持有失效 JointID。`getJoints()` 返回原 Lua userdata，`getBodies()` 则依 Love/Box2D 返回两个源 Joint 的 Body B。真实 Revolute + Prismatic 场景在 meter 64、ratio 2 下得到 `ω=0.444444 rad/s`、`v=-14.222222 px/s`，满足 `ω + ratio × v/meter = 0`，并产生 `-5361.652` 的反作用力矩。

Fixture category/mask 保持 Love 11.5 的 16 类位语义；`setMask/getMask` 对外仍表示“排除的类别”，backend 边界才取反为 maskBits。PlayRho `Filter::groupIndex` 只把存储宽度迁移为有符号 16 位，`ShouldCollide`、Dora `PhysicsWorld` 的 0～31 group matrix、`setShouldContact`、Body `onContactFilter` 和 Sensor 分组均保持原行为。Box2D 的 override group 规则只在 LoveNode 内实现：group 为零时直接使用原 category/mask；非零 group 的 native category/mask 增加 Love 私有候选位，PlayRho 只负责产生候选 Contact，LoveNode 的 Begin/PreSolve listener 再执行“相同非零 group 时正值强制碰撞、负值强制不碰撞，否则检查公开 16 位 category/mask”。Love Fixture 因而完整接受 `-32768..32767`，且不会改变 Dora 原生物理的全局过滤语义。真实场景分别验证 Love `+300/-300` 的覆盖语义和 Dora group 5 的禁用后重新启用。

PlayRho 没有独立的 gravity-scale 字段，因此该值保存在每个 Love Body backend resource 中，并只替换当前 acceleration 里的重力分量：`Body:setGravityScale` 和 `World:setGravity` 都保留尚未 step 的 force/torque 累积；每次 step 后再按 `worldGravity * bodyGravityScale` 恢复 acceleration，保证一次 `applyForce/applyTorque` 不意外变成永久力。`get/setMassData` 使用 Love/Box2D 的局部质心与“相对刚体局部原点”的惯量语义，`setMass`/`setInertia` 保留其余质量数据，`resetMassData` 从现有 Fixture 重新计算；不满足有限值、正质量及惯量平行轴约束的输入在进入 PlayRho assertion 前转为 Lua 错误。

显式销毁与 GC 走同一条幂等释放路径。销毁 World 会级联其 Joint、Fixture 和 Body，销毁 Body 会级联连接 Joint 与所属 Fixture；重复 `destroy` 安全，任何已销毁对象的方法都会明确报错。若在 begin/end/pre/post contact callback 的 PlayRho 世界锁定期间请求销毁，backend 将精确 handle 放入所属 LoveNode 的延迟队列，请求对象立即对 Lua 调用方失效，真实 Joint→Fixture→Body→World 释放则在当前 `World:update` 的原生 step 返回后、Lua update 返回前完成，禁止在锁内修改 PlayRho 容器或把悬空 handle 留到下一帧。

Body 坐标查询和转换必须直接读取 PlayRho transformation，不以 Dora `Node::position/angle` 缓存作为物理真值。PlayRho sweep 保存的是世界质心，而 Love/Box2D 的 transform 位置表示刚体局部原点；设置 transform 时先把 local center 经目标 transform 转成世界质心，再写入 sweep。否则偏心 Fixture 会在每次 `setX/setY/setTransform` 时产生一个 local-center 偏移。真实偏心圆夹具已验证旋转时刚体原点保持 `(100,100)`、局部质心 `(5,0)` 到达世界 `(100,105)`，并验证局部点 `(10,0)` 的 world point/vector、批量往返及角速度贡献的 point velocity。

Polygon 接受数值变参或坐标表、限制为 Love 11.5 的 3–8 个顶点，并从最终 PlayRho convex hull 反读规范化 `getPoints()`，不能回显可能已被重排或剔除的输入；Edge 拒绝重合端点；Chain 同样接受表或变参，loop 通过重复首点建立闭环，并按 Box2D/Love 行为在 `getPoints/getVertexCount/getPoint` 中暴露该闭合点。AABB query 与 Love 11.5/Box2D 一样查询 broad-phase fixture proxy，不额外收窄为精确 shape overlap；回调的 boolean 提前终止、射线 `-1/0/fraction` 控制、命中点/法线/fraction 和原 Fixture userdata 身份均在 Runtime 与真实 PlayRho 场景验证。

`World:setCallbacks(begin, end, pre, post)` 直接安装到该 LoveNode 私有 PhysicsWorld 的 PlayRho contact listener，不经会丢失 ShapeID 的 Dora Body 事件层。listener 把 ShapeID 还原为原 Fixture userdata，并在 begin 到 end 期间为同一 native contact 保持一个由 Lua registry 强引用的 Contact userdata；end callback 返回后立即从 registry 和 backend 映射中移除，之后 `isDestroyed()` 为 true，其余方法报明确的 destroyed Contact 错误。当前 Contact 子集包含 fixtures、转换为 Lua 1-based 的 shape child indices、positions、normal、friction/restitution 的 get/set/reset、enabled、touching 和 tangent speed；preSolve 的修改直接作用于当前 PlayRho contact，postSolve 依 Love 参数顺序传递法向/切向 impulse 对。

PlayRho step 期间的 Lua callback 使用受保护调用；错误先保存到所属 World，待 step 返回后由 `World:update` 抛回 Lua，严禁 Lua longjmp 穿过物理引擎 C++ 栈。由于该 PhysicsWorld 仅服务单个隔离 Love state，安装 Love listener 会取代其 Dora Body listener，这是私有 World 的明确所有权规则，不影响宿主或其它 LoveNode。

`ChainShape:getChildEdge(index)` 从链拓扑创建所属 state 的独立 EdgeShape，并为开链中间段与闭环首尾段恢复 Love 查询可见的 previous/next vertex；越界使用 Lua 1-based 规则报错。为补齐 PlayRho 原本缺少的 Box2D 外部 ghost topology，`EdgeShapeConf`、`ChainShapeConf` 与其 child `DistanceProxy` 现在保存并传播可选的前后连接顶点；闭环 Chain 自动用倒数第二点和第二点建立首尾连接，平移、缩放、旋转时 ghost vertex 与实际顶点一同变换。

连接边碰撞不再使用形状质心越过端点后的全局提前过滤。PlayRho 现在只在 `2` 顶点 edge 携带 previous/next topology 且另一形状为 circle 或 convex polygon 时进入专用窄相：edge-circle 按重心坐标把端点 Voronoi 区域交给相邻 edge；edge-polygon 依据 Love 11.5 Box2D `b2EPCollider` 的已验证行为，分类前后连接处的凹凸性和接触正反面，建立 adjacent-edge lower/upper normal limits，再在 SAT 选轴与 clipping 中排除内部 ghost normal。普通无 topology Edge、Polygon/Polygon 和其它 PlayRho 碰撞仍走原路径。

Love 的 `EdgeShape/ChainShape:setPreviousVertex` 与 `setNextVertex` 因而会复制并替换真实 PlayRho shape 配置，不是只保存 Lua 查询属性；`getChildEdge` 也把内邻接、闭环或显式外部拓扑继续传给新 EdgeShape。开发阶段曾直接编译 Love 11.5 Box2D 参考碰撞器，以六种 previous/next 凹凸组合、17×11 个位置、五个 polygon 角度、非单位 edge transform 和正反 shape 顺序，核对 6732 组 circle/polygon 配置的 manifold 点数、类型、local point、local normal、各 contact local point 与完整 feature ID；完整通过结果现以稳定量化 hash `0x95a865bab1a1aa84` 固化。持续回归只编译 PlayRho 并核对该矩阵 hash、翻转 manifold 不变量与真实 bullet TOI，从而不再为测试保留整套 Box2D 源码。真实 World 的连续碰撞场景另以带前后 ghost vertex 的三点 Chain 接收 `setBullet(true)` 的动态圆：圆从 `y=-80` 以 `12000 px/s` 向连接点运动，一个 `1/60 s` step 后停在 `y=-6.3175`、速度归零，并在相邻 child 上产生两个 begin contact，证明 topology-aware manifold 也进入 PlayRho TOI 求解且没有高速穿透。这证明的是目标 Love 11.5 的双面连接边算法；新版 Box2D 3 的单边 Chain 规则属于不同版本语义，不作为本阶段兼容目标。Love 11.5 的十一类 Joint、`love.physics.getDistance` 与 16 位 group index 已接入；`getDistance` 对两个同 World Fixture 使用 PlayRho distance proxy 的第 0 个 child，包含 shape radius 并返回像素单位距离和两侧最近点。PlayRho backend 已在 macOS、Windows Direct3D、Linux ARM64、iOS Simulator 与 Android AVD 的完整真实 LoveNode PhysicsScene 中运行。`love.physics` 的“部分支持”只来自固定官方快照中六个未编写的对象占位，不再表示平台 backend 或已知 Love 11.5 API 缺失。

## Lua 5.5 兼容边界

Love 项目运行在 Lua 5.5，不运行在 LuaJIT/Lua 5.1。boot 可以内部提供常见源码兼容项，但这些兼容项仍属于 Love 环境，不暴露 Dora 扩展。例如：

- `unpack` 映射到 `table.unpack`。
- `loadstring` 映射到 `load`。
- `package.loaders` 映射到 `package.searchers`。
- `bit` 可以用 Lua 5.5 位运算提供兼容实现。
- `getfenv/setfenv` 对 Lua 函数和正数调用栈层级提供有限兼容：通过 Lua 5.5 的 `_ENV` upvalue 查询环境；替换时先把目标函数连接到私有 upvalue cell，不能连带改变原本共享 `_ENV` 的兄弟闭包。没有 `_ENV` 的纯局部 Lua 函数以 runtime 私有弱键表保留可查询环境，不延长函数或环境生命周期。`getfenv(0)` 返回当前隔离 state 的 `_G`；Lua 5.5 没有 Lua 5.1 可替换的 thread environment，因此 `setfenv(0, env)` 明确报错。C 函数查询返回 `_G`，替换明确报错。

明确不支持：

- `require("ffi")`
- `require("jit")` 的真实 JIT 能力
- LuaJIT FFI C declaration
- LuaJIT bytecode
- Lua 5.1 ABI native module
- 依赖 LuaJIT GC、number representation 或内部实现的库

遇到这些能力时应返回带有 Dora Love runtime 和 Lua 5.5 信息的明确错误，不能只报告模糊的 module not found。所有 chunk 入口先识别 `\x1bLJ` 和标准 Lua `\x1bLua + version` header：LuaJIT 或非 5.5 版本在 `execute/boot`、全局 `load/loadstring`、Content `require` 与 `filesystem.load` 都提示提供源码或用 Lua 5.5 重编译；当前 Lua 5.5 `string.dump` chunk 允许通过后三条标准脚本入口执行。这样既不把 Lua 5.1/LuaJIT 字节码交给 5.5 parser 产生模糊错误，也不把“禁用异版本字节码”错误扩大成“禁用当前运行时字节码”。

## Dora 语言工作流

独立 `lua_State` 不影响转译器工作，因为编译器与目标运行状态无需相同。工作流为：

```text
TS / Yue / Teal source
→ Dora Web IDE / build service
→ Lua 5.5 source + source map
→ LoveNode load/reload request
→ 目标 Love lua_State
```

### 通过 Love 模块触发定义

Love2D 支持不新增项目类型、源码注释或额外编译模式。Love 与 Dora 源码可以混合放在同一项目中；程序文件只有在正常导入 Love 模块后，定义检查才加载 Love API：

```lua
local love = require("love")
```

```ts
import "love";
```

规则如下：

- Lua、Teal 和 YueScript 通过静态可识别的 `require("love")` 触发 `love.d.tl`；TypeScript 通过静态 `import "love"` 触发 `love.d.ts`。
- 只识别字符串字面量模块名。动态 `require(name)` 不触发定义，以保持模块分析确定性。
- 没有 import/require 的文件完全保持现有 Dora 行为；Dora 默认 API 和默认 TypeScript declarations 绝不注入 `love` 全局变量。
- 触发只影响包含该 import/require 的编译单元。同一目录可以同时存在导入 Love 的 `.ts`/`.tsx`、普通 Dora `.ts`/`.tsx` 和中立共享模块。
- `.tsx` 不做任何 Love 特殊处理，继续走标准 Dora TypeScript/TSX 检查、DoraX 转换和模块生成。导入 Love 只影响模块定义可见性。
- 编译器不根据 Love import 决定产物由 Dora 主状态还是 LoveNode 执行；运行入口和对应 API 的可用性由上层代码与 LoveNode boot 配置负责。
- LoveNode 仍由宿主传入 boot Lua 文件路径；LoveRuntime 根据 boot 确定 source root、资源和 require 规则，不参与语言判定。

### TIC-80 特殊处理及复用方式

TIC-80 已经采用了相近的文件级机制：

- Lua、Teal 和 YueScript 通过第一行 `-- tic80` 识别。
- 检查、补全、悬停和签名阶段临时改写为 `require("tic80")`，让 `tic80.d.tl` 参与 Teal 推断；生成后再还原标记。
- YueScript globals lint 额外允许 `btn`、`cls`、`spr`、`TIC` 等 TIC-80 globals。
- TypeScript 目前通过 `import ... from "tic80"` 触发 TSTL 的 `isTIC80` 路径，把模块引用改成 `_G`，并 inline Lua helpers。
- Teal/Yue 生成产物必须继续把 `-- tic80` 放在第一行；通用 `-- [tl]/[yue]: source` 标识放在第二行。Yue 编译器不会保留源注释，因此生成服务负责恢复该标记；Teal 已保留时不得重复。
- TIC-80 的 inline helper 构建仍由标准 browser compiler 完成。WebServer 的只读虚拟文件快照除 `lualib_bundle.lua` 外还包含 `lualib/*.lua`，让 TSTL 能按需内联单体 helper；普通 TS/Love TS 仍使用 bundle 策略。

Love2D 只复用 TIC-80 的声明文件和模块解析经验，不复用其首行标记、全局白名单或 TSTL 输出特判。`require("love")` 由普通模块转换路径生成，并在目标 Love state 中返回该实例已经注入的 `love` 表。

因此不需要把 `CheckTIC80Code` 扩展成 Love 模式识别器；TIC-80 特殊行为保持原样，Love 的入口集中在通用 import/require module resolution。

### Love API 声明

声明按 Love 11.5 固定版本维护：

```text
Assets/Script/Lib/Dora/en/love.d.ts
Assets/Script/Lib/Dora/en/love.d.tl
Assets/Script/Lib/Dora/zh-Hans/love.d.ts
Assets/Script/Lib/Dora/zh-Hans/love.d.tl
```

- `love.d.ts` 描述 Love root、子模块、对象和 callbacks，由 TypeScript module resolver 在遇到 `import "love"` 时纳入当前 program。
- `love.d.tl` 返回 `love` record，由 Teal module resolver 在遇到 `require("love")` 时加载，供 Lua、Teal 和 YueScript 的检查、补全、悬停和签名共同使用。
- 支持矩阵中部分支持或未支持的 API 必须在声明注释中标明，不能让类型系统承诺运行时尚未实现的能力。
- 中英文声明的类型结构由同一数据或生成器产生；`LoveNode` 宿主声明仍属于 Dora API，不与 `love.*` 声明互相导入。

TypeScript 声明应采用外部模块加 global augmentation 的结构，而不是把 value declaration 放进 Dora 默认库：

```ts
declare namespace Love {
	interface Root {
		load?: () => void;
		update?: (dt: number) => void;
		draw?: () => void;
		// 其余 Love 11.5 API
	}
}

declare global {
	const love: Love.Root;
}

export {};
```

该声明文件只有被 `import "love"` 解析进当前 program 后，global augmentation 才参与该 program 的类型检查；它不能作为无条件 root extra lib 安装到所有 Monaco TypeScript 模型。

### TypeScript 定义与生成

- 推荐入口写法是副作用导入 `import "love"`，随后使用 `love.load = ...`、`love.update = ...`。这样现有 TSTL 自然生成 `require("love")`，不需要 Love 专属 AST 转换。
- `love.d.ts` 作为外部模块声明，在被 import 后为当前 TypeScript program 提供 ambient `love` 类型；没有 import 的 Dora program 看不到该 value declaration。
- compiler host 只需让模块名 `love` 解析到声明文件，不改变现有 `Lua55`、strict、module resolution、source map 或 helper 生成规则。
- 如果现有 TypeScript language worker 无法做到声明按 import 生效，应为活动 program 做按需 module resolution，不能退回全局注入 `love`。
- TSTL 生成的 `require("love")` 在每个 Love state 中返回当前实例的 Love 表。现有 `lualib_bundle` 策略保持不变，但 LoveRuntime 必须能在隔离 state 中解析该 helper module。
- `.tsx` 与 `.ts` 使用相同的 Love module resolution；其余 JSX、DoraX 和生成行为完全沿用标准 Dora 编译流程，不增加判断分支。
- `love.graphics`、`love.event` 等模块表的声明接口使用 TSTL 标准 `@noSelf`，确保模块函数生成点调用；Image、Font、Source 等对象接口不加该标记，继续生成冒号方法调用。可选 alpha 的 Color 使用三元组/四元组 union，不能在 Lua array 元素类型中引入 `undefined`。

#### 已确认的 Web IDE 转译边界

- 原生 `/ts/build` 等待浏览器 WebSocket 回包时，compiler host 不得再调用同步 `/read-sync`；WebServer 在进入等待前统一通过 Dora `Content` 收集项目 `.ts/.tsx`、当前 locale 声明、内建 `lualib_bundle.lua` 和 `lualib/*.lua`，以只读虚拟文件快照随请求发送。单体 helper 只供 TIC-80 既有 inline 模式按需读取，不改变 Love 和普通 Dora TS 的 bundle 输出。
- TypeScript browser build 必须保留顶层 `ts` 标识符并显式写入 `globalThis.ts`。带内容 hash 的 compiler script 在 Web IDE `index.html` 中先于主 module 加载，不能在已建立编译 WebSocket 后才按需请求。
- TSTL、output collector 与 source-map `mappings.wasm` 必须在编译 WebSocket 建立前完成加载；WASM 以 ArrayBuffer 初始化，正式转译阶段不得产生嵌套静态请求。
- 编译协议只使用 `TranspileTSProbe / TranspileTS`：probe 请求与应答共用前者，转译请求与结果共用后者，并以严格匹配的请求 `id` 关联。服务端先以 5 秒 probe 确认至少一个完成预热的客户端，再进入 30 秒转译等待；协议不保留版本化并行接口。
- `lualib_bundle` 不是 Love 专属 inline 规则。LoveNode 用 Dora `Content` 读取现有 `Script/Lib/lualib_bundle.lua`，再把 loader 注册到当前隔离 state 的 `package.preload`；注册表随 runtime restart 恢复，各实例的 `package.loaded` 仍完全隔离。

### Lua、Teal 与 YueScript 定义和生成

- Lua 和 Teal 使用 `local love = require("love")`。现有 Teal module resolver 找到 `love.d.tl` 后即可提供类型，不需要临时前导或生成后还原。
- YueScript 可使用其正常的 require/import 语法加载 `love`；Yue → Lua 后的 `require("love")` 继续交给 Teal language service 解析。
- Love API 通过局部 `love` 变量使用，因此 `LintYueGlobals` 不需要 Love 白名单；现有禁止意外全局变量的规则保持不变。
- 补全、悬停和签名只在模块已经导入的上下文中出现，不额外追加 `Dora.` 或 Love globals。
- 保存编译和 CLI build 不增加 Love 分支，正常保留用户源码生成出的 `require("love")`。

### 生成与运行加载

Love2D 源码完全使用现有单文件生成链路：

```text
main.ts / main.tl / main.yue
  + import/require("love")
        ↓ unchanged check/build service
同目录 main.lua + source map/line map
        ↓ LoveNode boot path
目标 Love lua_State
```

- 继续沿用 Dora 将 `.ts`、`.tl`、`.yue` 生成到对应 `.lua` 的规则，不增加 Love 项目 staging 或专用编译规则。
- 生成使用临时文件后原子替换；失败不得覆盖上一次成功的 Lua。
- 输出使用 Dora 通用的生成源码标识和 line map 协议，traceback 映射回 `.ts`、`.tsx`、`.tl` 或 `.yue`；该协议不检查源码是否导入 Love，也不改变普通 Dora 项目的编译规则。
- LoveNode 只加载传入的 boot Lua 及其模块，不负责运行 TypeScript、Teal 或 YueScript 编译器。

#### 已确认的生成源码行映射协议

编译服务在 Lua 首行写入与运行目标无关的源文件标识：

```lua
-- [ts]: project/source/main.ts
-- [tsx]: project/source/view.tsx
-- [tl]: project/source/main.tl
-- [yue]: project/source/main.yue
```

- TypeScript/TSX 与 YueScript 生成行继续使用编译器已有的行尾 `-- <source-line>` 标记；Teal 生成结果保持源码行布局，只在输出前增加一行源文件标识，因此生成行 `n + 1` 对应 Teal 源行 `n`。
- TIC-80 是通用源标识位置的既有例外：Teal/Yue 产物第一行固定为 `-- tic80`，第二行才是 `-- [tl]/[yue]: source`，避免破坏运行时首行识别；这不是 Love 编译规则。
- 路径由通用编译服务按当前 project root 决定，可为完整 Content 路径或项目内路径。协议不要求 Love 项目 profile、首行源码注释或 Love 专属 build 分支。
- LoveRuntime 在每个隔离 state 内加载 chunk 时解析该标识，并把生成 Lua 行建立为实例局部映射；普通 Lua 没有该标识时完全沿用原 chunk name 和 traceback。
- 映射同时应用于 boot 主文件、`require` 经 Dora Content source searcher 加载的模块、`love.filesystem.load` 返回的 chunk，以及 `love.thread.newThread` 在独立子 state 中加载的入口 chunk；语法错误、callback traceback 和 thread error 都回写为原扩展名、完整源路径和原行号。
- Lua 的长 chunk name 会受 `LUA_IDSIZE` 截断。LoveRuntime 只在 traceback 生成后匹配该 state 已登记的截断名并恢复完整路径，不修改 Lua 5.5 全局行为；restart/close 会清空映射，避免跨 LoveNode 或跨代串扰。

### 现有代码接入位置

| 位置 | Love2D 改造 |
| --- | --- |
| `Tools/dora-dora/src/Editor.tsx` | 继续复用 providers；模块已解析为 Love declarations 时展示对应补全、悬停和签名 |
| `Tools/dora-dora/src/App.tsx` | 不全局安装 Love value declaration；TypeScript 活动 program 通过 module resolution 按需取得定义 |
| `Tools/dora-dora/src/TranspileTS.ts` | 让模块名 `love` 解析到 `love.d.ts`；`.ts`/`.tsx` 生成均走现有普通 import/require 和标准转换 |
| `Assets/Script/Dev/WebServer.yue` | 让 Teal search path 能解析 `require("love")`；complete/infer/signature/check/build 复用通用路径，签名包装必须保留编译器原始函数类型，声明注释只作可选文档增强 |
| `Assets/Script/Dev/Entry.yue` | 无 Love 专属编译路径，只验证现有生成结果保留 require |
| `Tools/dora-dora/src/3rdParty/tstl/...` | 不增加 Love import transform；保留现有普通 module 转换和 TIC-80 特判 |

`WebServer.yue`、`Entry.yue` 和 `Utils.yue` 是作者源码，对应 `.lua` 是生成产物；实现时必须修改 `.yue` 并验证生成 Lua 同步。

### 语言工作流验收组合

| 用例 | 编辑器验收 | 构建验收 | 运行验收 |
| --- | --- | --- | --- |
| `require("love")` 的 `main.lua` | Love 补全、悬停和错误行列正确 | Lua 检查通过 | LoveNode 显示画面并收到 update |
| `require("love")` 的 `main.tl` | record、枚举、多返回值正确 | 生成正常 require 的 `main.lua` | 独立 Love state 加载 |
| 导入 Love 的 `main.yue` | Love 补全且无隐式全局依赖 | 生成 Lua 5.5 和行映射 | traceback 回到 Yue 源码 |
| `import "love"` 的 `main.ts` | import 后 `love` 有类型；移除 import 后不可见 | 普通 TSTL Lua 5.5 与 source map 成功 | require、Love global 和 helpers 可用 |
| 导入 Love 的 `.tsx` | Love 定义与标准 Dora TSX 定义均按模块可见 | 走现有 Dora TSX/TSTL 转换 | 由宿主选择产物运行入口 |
| 同目录 Dora 与 Love 文件 | 定义由各自 import 决定 | 使用相同通用编译机制 | Dora 宿主与 LoveNode 均正常 |
| TIC-80 回归 | 原标记/import 补全不变 | 原 Teal/Yue/TS 变换不变 | TIC80Node 行为不变 |

第一版热重载采用关闭旧 LoveRuntime 并创建新状态的方式，优先保证清理正确。`LoveNode.restart()` 先停止调度并关闭旧 state，再统一清空该实例的 RenderTarget/pass/texture/shader/canvas/font、AudioBus/AudioSource、physics world/body/fixture/joint、mount/package staging 和宿主 graphics 状态，然后从同一 boot 路径加载 Content 重新生成的 Lua。失败时再次清理部分创建资源、停用触摸与控制器并保留可查询错误；成功时恢复输入、焦点与调度。其他 LoveNode、Dora 主 Lua state 和宿主项目文件均不参与重启。增量替换单个模块会保留旧闭包、userdata 和 `package.loaded` 状态，只有在完整重启稳定后再考虑。

Love 状态不包含 Dora bindings，但语言工具链不通过文件扩展名或 Love import 强制判断运行目标。Dora 与 Love 源码可以在同一宿主项目中混合存放，定义由显式 import/require 决定，编译机制保持统一；上层代码负责把生成产物交给正确的 Lua state。

## 多实例规则

多实例是首版架构约束，不应作为后期补丁：

- 每个 LoveNode 必须创建新 Lua state。
- Love native userdata 必须携带或能够验证 owner runtime。
- 所有异步完成回调必须通过弱生命周期 token 检查实例是否仍存活。
- 所有 Love module singleton 必须是 runtime singleton，不能是进程 singleton。
- 可共享的缓存只能是不可变资源数据或明确支持引用计数的原生资源。
- Graphics、filesystem、event、timer、audio 的可变状态不得跨实例共享。
- 每个节点可以加载相同模块名和相同全局变量而互不影响。
- LoveNode Lua 回调在 Dora 主线程顺序执行，不并发进入同一或不同状态。

允许共享的候选包括：

- 解码后的不可变图片数据。
- 字体文件数据。
- 只读 shader 编译缓存。
- 音频解码数据。

即便共享底层资源，Love userdata 和资源生命周期仍属于各自 runtime。

## Thread 与 Video 可行性边界

`love.thread` 已按上游隔离模型接入，不能把 Dora 的协程或通用异步任务直接包装成 Love Thread，也不能让 native worker 进入 LoveNode 的主 `lua_State*`。Love 11.5 的公开对象包括模块级 `newThread/newChannel/getChannel`，Thread 的 `start/wait/getError/isRunning`，以及 Channel 的 `push/supply/pop/demand/peek/getCount/hasRead/clear/performAtomic`；Dora 与上游 `LuaThread` 一样在线程函数内新建 Lua state：

- 每个 Thread 创建独立 Lua 5.5 state，worker 只进入自己的 state；父 LoveNode state 继续只由 Dora 主线程进入。
- 每个 LoveRuntime 拥有独立 ThreadHub；命名 Channel 以 runtime 为作用域，不使用进程级全局表，避免两个 LoveNode 的同名 Channel 串扰。
- Channel 使用 state-independent Variant 复制 boolean、number、string、最多 32 层的 table、Channel 与明确支持的 Data/ImageData；不得传递父 state 的任意函数、thread、任意 userdata 或 registry 引用。
- Thread 源码接受 Content 路径、File、FileData/Data 或源码字符串。worker 内 filesystem 请求进入 runtime-owned 队列，由父 LoveRuntime 在 Dora 逻辑线程调用 Content backend；`Thread:wait` 与阻塞 Channel 操作也会泵该队列，不开放原生模块或宿主文件 API。
- LoveNode restart/close 先取消或请求停止 worker，再 join 全部线程，最后释放 Channel 和 state；threaderror 通过 generation/weak token 投递回实例事件队列，不捕获裸 `lua_State*`。
- 不具备 native thread 的平台必须明确拒绝 `newThread`，不能静默退化为会阻塞主循环的同步调用。

P5-16 已从可行性结论进入实现：固定官方 Thread 5 项为 5 pass/0 fail/0 skip，普通与 ASan/UBSan Runtime 覆盖阻塞/超时、错误、Data、Content、关闭取消和多实例隔离；macOS、Windows、Linux ARM64、iOS Simulator 与 Android API 34 AVD 的真实 LoveNode 均已覆盖 Content worker、`threaderror` 与两代 restart。Windows 在登录用户交互桌面运行当前 MSVC x86 Dora，worker 文件经 Dora Content 暂存，未使用宿主文件 API。不具备 native thread 的未来平台必须明确拒绝 `newThread`，不能同步退化。

`love.video` 复用 Love 11.5 上游的 `OggDemuxer`、`TheoraVideoStream` 与 `VideoStream` 时钟、seek、同步和双缓冲状态机。Dora 适配层只提供 Content-backed 内存 `File`、后台解码调度、YCbCr→RGBA 转换、主线程 bgfx 纹理上传，以及由 AudioBackend/SoLoud 驱动的 `setSync(Source)`。公开对象包含 `newVideoStream`、`play/pause/seek/rewind/tell/isPlaying/getFilename/setSync` 和可绘制 `Video` 的尺寸、filter、stream/source 查询。

Dora `VideoNode` 是独立实现，但底层格式统一为 Ogg/Theora：文件必须经 `SharedContent.load` 进入内存，后台线程只解码和排队，主线程上传纹理；它不依赖 Love Lua state，也不承载 Love Audio Source 对象模型。原 h264bsd/H.264 Annex-B 路径被破坏性删除，不提供兼容回退。libogg 的头文件、源码、许可证与唯一聚合编译单元统一位于 `Source/3rdParty/ogg`，供音频与视频共同链接，避免重复符号；portable theoradec 位于同层的 `Source/3rdParty/theora`。两者的独立构建均使用 xmake，并进入五个平台构建清单与许可证矩阵。

固定 VideoNode workflow 已在 macOS、Windows、Linux ARM64、iOS Simulator 与 Android API 34 AVD 运行：`.ogv` 和 boot 文件均经 Dora Content 暂存，断言 496×502 解码纹理、暂停前后 RenderTarget PNG 像素完全一致、跨 EOF loop 后像素发生变化，并完成资源清理。Android 使用 GLES texture readback emulation；首帧门禁允许慢速 AVD 最多等待 15 秒，但不会放宽像素或循环断言。Windows 使用登录用户交互桌面的 Direct3D renderer，并明确拒绝 Noop 会话作为图形证据。

## 错误处理

所有进入 Love Lua 的调用都必须使用统一 protected call 和 traceback：

- boot/config/main 加载错误。
- `love.load()` 错误。
- update/draw callback 错误。
- 输入和事件 callback 错误。
- 异步资源完成 callback 错误。

错误信息至少包含：

- LoveNode boot 路径。
- callback 或模块名。
- Love Lua stack traceback。
- 转译源码映射后的路径和行号（可用时）。

Image、Font、Audio 等资源创建错误还必须包含 Love 侧请求路径、资源类型、解析或创建失败阶段，以及可用的格式信息；Font 应带字号，Audio Source 应带 `static`/`stream` 类型。LoveRuntime 负责保留用户传入的虚拟路径和调用阶段，LoveNode backend 负责追加 Dora Content/Cache/SoLoud 失败位置与实例 boot 标识，不能只返回底层的笼统“load failed”。

不可信或损坏的字体数据不得直接交给 stb_truetype。Dora FontManager 应先验证 SFNT/TTC 头、目录边界、各 table 的 offset/length 和必要表，再调用 stb；FontCache 必须拒绝无效 font handle。该检查是崩溃边界保护，不代替后续自定义字体格式兼容矩阵或完整的恶意字体沙箱。

发生 update/draw 错误后，应停止该实例继续执行脚本并显示可诊断状态，不能让同一错误每帧重复刷屏。其他 LoveNode 和 Dora 主运行时应继续工作。

## 推荐源码组织

```text
Source/
  Node/
    LoveNode.h
    LoveNode.cpp
  Love/
    LoveRuntime.h
    LoveRuntime.cpp
    LoveContext.h
    LoveGraphics.*
    LoveAudio.*
    LoveFilesystem.*
    LoveInput.*
    LoveWindow.*
  3rdParty/
    love/

Assets/Script/Lib/
  Dora/en/LoveNode.d.tl
  Dora/zh-Hans/LoveNode.d.tl
  Love/
    en/
    zh-Hans/
```

实际 vendoring 结构应尽量减少对上游 Love 文件的直接修改：

- 上游源码固定版本保存。
- Dora backend 放在独立目录。
- 模块选择和 backend factory 通过少量适配文件完成。
- 必须修改的上游文件形成可审计 patch。
- 保留 Love zlib license 和所有第三方依赖许可证。

## 分阶段实现

### 阶段 0：构建与状态原型

- 固定 Love 11.5 源码和许可证。
- 建立独立构建 target。
- 用 Dora Lua 5.5 编译 Love binding。
- 创建两个 LoveRuntime state，并分别加载最小脚本。
- 验证创建、执行、报错、关闭和重复创建。

验收标准：同一进程中的 Dora 主状态和两个 Love 状态可独立运行、GC 和销毁，无符号或生命周期冲突。

### 阶段 1：LoveNode 与 Boot

- 新增 `LoveNode(bootFile)`。
- 注册最小 `love`、timer 和 event。
- Dora 驱动 `love.load/update/draw`。
- 实现错误上报和完整重启。

验收标准：两个 LoveNode 加载相同 boot 文件时，全局计数和 callback 状态互不影响。

### 阶段 2：最小图形后端

- 主 RenderTarget。
- clear、color、transform。
- rectangle、circle、line。
- Image、Quad、Font/Text。
- 基本 blend 和 scissor。

验收标准：LoveNode 在 Dora 场景中可缩放、移动和遮挡；两个实例同时绘制不同内容且状态不串扰。

### 阶段 3：输入、窗口和文件系统

- Keyboard、Mouse、Touch、Controller。
- 节点坐标转换和焦点。
- 虚拟 window mode。
- source/save filesystem 和 require loader。

验收标准：两个实例使用相同相对文件名、模块名和输入代码时，资源根、模块缓存和事件队列保持独立。

### 阶段 4：音频与资源

- SoundData/Source。
- 图片和字体完整加载路径。
- 实例销毁时资源和播放句柄清理。
- 资源加载失败诊断。

### 阶段 5：高级图形与物理

- Canvas、多 RenderTarget。
- Mesh、SpriteBatch、ParticleSystem。
- Stencil、depth、readback。
- Shader 和 uniform。
- `love.physics`。

### 阶段 6：工具链与兼容测试

- Love TS/Teal 类型声明。
- Web IDE 项目识别、构建和运行。
- source map 错误回传。
- 完整重启式热重载。
- TIC-80 首行识别、语言服务、TypeScript import 改写和 helper inline 回归。
- `mount/unmount`、fused 查询和更多平台行为。

Windows 在原生发布验收之外增加一个可从 macOS/Linux 重现的 x86 编译链接门禁：执行配套 Dora-Example 仓库中的 `Test/Love/build-windows-cross.sh`，通过 Zig 的 `x86-windows-gnu` target 完整构建独立 Love Runtime、PlayRho ghost topology、SoLoud filter response 与 voice budget 四个 PE32 测试程序。该门禁用于尽早发现 Windows ABI、头文件、模板实例化和链接符号回退；它不能替代 Visual C++、Dora 完整 Windows target、Direct3D renderer 或可执行文件运行证据。原生 Windows CI 必须另外检出 Dora-Example，并以 Win32 generator 分别构建 Debug/Release、执行同一组 CTest。

## 验证策略

### 单元测试

- Love enum 和 Dora backend 状态映射。
- 坐标、颜色、blend、scissor 转换。
- 文件系统路径、优先级和逃逸阻止。
- Lua 5.1 常见兼容函数。
- userdata owner runtime 检查。
- 错误状态与 cleanup 幂等性。

### 集成测试

- 同时创建、更新、绘制和销毁两个 LoveNode。
- 两个实例加载同名模块但得到独立 module state。
- 一个实例脚本报错时另一个实例继续运行。
- 一个实例销毁后异步任务不再回调其 Lua state。
- `love.window.setMode()` 只影响目标实例。
- `love.event.quit()` 不误退出 Dora 或关闭其他 LoveNode。
- 音频不可用时安全失败。

Windows 采用三层递进验收：项目清单审计保证发布 target 没有漏接源码；Zig x86 交叉构建保证独立 Runtime/物理/音频测试能够生成合法 PE32；原生 MSVC CI 和 Windows 设备运行分别证明工具链兼容与实际行为。前两层通过不得将后一层标记为完成。

### Love 兼容测试

- Love 11.5 tag 本身不含 `testing/`；官方仓库后续测试树明确以开发中的 Love 12 为目标。接入时固定官方测试 commit，以 Love 11.5 为基础兼容面；只有经过明确设计、上游源码固定、四份定义和运行测试共同覆盖的前向 API 才能转为通过，其余 Love 12-only API 继续以版本原因跳过，不能仅凭同名函数计为兼容。
- 固定 `love2d/love@357b005e5332d7fca847a40eac5b1d263e6e7398` 的 Data、Math、Event、Timer、System、Filesystem、Image、Sound、Audio、Font、Physics、Window、Graphics、Thread 与 Video 全部 15 个测试文件，保留官方方法名、摘要等固定向量和每用例独立隔离；模块报告必须同时给出 pass/fail/skip 及具体原因。Filesystem 使用独立临时 save base 和 Content 测试 backend；Image/Sound 使用确定性注入解码器；Audio 使用可审计 handle 的 Dora AudioSource/capture mock；Physics 使用可审计的 backend handle map 验证构造器、meter 变化和销毁，state 关闭后两类 handle 均要求归零。Window 只验证实例虚拟 surface，不伪造 LoveNode 对 Dora 宿主 display/focus/title/fullscreen/vsync 的所有权。Graphics 的确定性状态、构造器和 Shader 验证可进入 Mock 子集，依赖像素或 presentation 的断言必须由真实 Metal framebuffer 套件证明，不能降级成“调用成功”；关闭 state 后 Image/Canvas/Font/Shader handle 创建与释放计数必须相等。Thread 已进入独立 state/Channel 专项；Video 的 API 面与构建先由 runtime、manifest 和语言声明测试覆盖，解码、seek、loop 与音画同步必须再用固定授权 `.ogv` 样本验收。该快照没有 Keyboard、Mouse、Touch、Joystick 测试文件，因此输入兼容只能引用 Dora 自有注入和平台场景，不能制造官方通过率。禁止为通过测试开放宿主文件 API、压缩纹理或尚未实现的能力，也不能让 `love.graphics.Font` 冒充独立的 `love.font` Rasterizer/GlyphData。
- 官方测试源码与 Dora 适配断言的来源、选择边界记录在 `Dora-Example/Test/Love/Official/README.md`；不能把选定子集的通过率表述成整个 Love 官方套件兼容率。
- API 方法面审计必须直接读取 vendored Love 11.5 wrapper，而不只比较 Runtime 与编辑器声明：Graphics 模块及对象、其余模块及对象分别固定对账，内部 helper 与 Content/嵌入宿主明确拒绝项使用精确白名单。这样 Runtime 和 TS/Teal 同时漏掉方法时也会失败，白名单增减同样要求显式更新设计决定。
- 建立一组不依赖 LuaJIT FFI 的真实开源 Love 项目样本。运行样本固定完整 commit、保留仓库许可证与未修改上游源码，通过 Content source root 在隔离 LoveRuntime 中 boot；测试 harness 可以驱动 frame 和检查 backend，但不得重写项目的 Love API 调用来制造通过。首个基线固定 MIT 项目 `Samuel-de-Oliveira/Love2D-Examples@2b13922a5705895e00e0f52c9a3f1e5d39fce55d` 的 `Game_Timer`，覆盖多文件 require、Timer、Keyboard、Font/Text 与 load/update/draw，后续运行样本继续覆盖图片、音频、物理和交互。
- TS/Teal/Yue 开源样本按语言工具链边界验收：固定上游 commit、许可证和原始源码快照，Dora port 的每一处改动必须显式且可比较；只要求通过 Content-backed 标准 `/check`、`/build`、`/ts/build` 路径，并由普通 `import "love"` 或 `require("love")` 触发定义。该类样本用于证明程序文件的检查和生成，不把未复制资源或未完整移植的上游应用声明为 LoveRuntime 运行通过。
- 每个失败记录为“缺失 API”“Lua 版本差异”“行为差异”或“后端 bug”。
- 不以 API 名称存在或构建成功代替行为兼容验证。

### 视觉和交互验证

渲染完成必须进行运行时视觉检查，至少覆盖：

- 坐标方向和 transform stack。
- Alpha、blend 和颜色空间。
- Text baseline、字体测量和 DPI。
- Canvas、scissor、stencil。
- Dora 节点缩放和 Love 内部分辨率关系。
- Mouse/Touch 本地坐标。
- 两个 LoveNode 重叠时的绘制顺序和输入焦点。

构建通过只证明代码可编译，不代表 Love 游戏的视觉或交互行为通过。

## 风险与控制

| 风险 | 控制方式 |
| --- | --- |
| Love 11.5 binding 依赖 Lua 5.1 行为 | 先完成 Lua 5.5 编译原型，集中维护兼容层 |
| Love Graphics 接口面较大 | 先实现最小可测 backend，再按官方测试扩展 |
| bgfx 状态污染 Dora pass | 每个 Love draw 建立和恢复完整 pass 状态 |
| bgfx 公开枚举扩展造成预编译库/语言绑定 ABI 不一致 | 新格式只追加、不改既有数值；C++ 固定数值断言、Rust FFI 对账与各平台 bgfx 主目标重建必须同时通过 |
| 多实例资源串用 | userdata owner runtime 校验和实例生命周期 token |
| 热重载遗留旧对象 | 首版始终关闭并重建整个 LoveRuntime |
| Love filesystem 与 Dora Content 语义不同 | 保留 Love 路径和 save/source 优先级，只替换底层 I/O |
| LuaJIT 项目无法运行 | 明确 Lua 5.5 兼容定位并提供针对性错误 |
| 上游升级成本 | 固定版本、隔离 backend、保存可审计 patch 和测试基线 |

## 完成定义

Love 整合只有同时满足以下条件才可称为完成：

- Dora 只链接一套 Lua 5.5。
- 每个 LoveNode 拥有独立、可完整销毁的 Lua state。
- Love 状态中不存在 Dora 专属公开模块。
- 至少两个 LoveNode 可同时运行且 Lua、资源、输入和渲染状态不串扰。
- 基础 Love lifecycle、graphics、input、audio 和 filesystem 通过对应测试。
- Web IDE 转译产物能够加载到指定 LoveNode，并正确映射错误位置。
- 支持的平台构建通过。
- 完成视觉与交互运行验证，并记录尚未支持的 Love API 和 LuaJIT 边界。
