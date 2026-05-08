# ActionEditor Web IDE 复刻设计

## 目标

在当前 Dora SSR Web IDE 中复刻 Dorothy 历史项目的 ActionEditor，用浏览器端 Canvas + WebGL + ImGui 绘制编辑体验，直接打开和保存 Dora 引擎现有 `.model` 资源文件。编辑器内部可以把 `.model` 解析成语义化对象模型作为工作态，但不把 `.action.json` 作为用户可见或持久化的资源格式。

本设计只针对 ActionEditor。BodyEditor 和 PrefabEditor 可以复用这里的编辑器宿主、资源读写、对象模型转换和 Canvas 输入框架，但不共享动画数据模型。

## 参考来源

旧实现位于：

- `Docs/design/Dorothy/project/Resources/ActionEditor/Script/main.lua`
- `Docs/design/Dorothy/project/Resources/ActionEditor/Script/oEditor.lua`
- `Docs/design/Dorothy/project/Resources/ActionEditor/Script/oEditMenu.lua`
- `Docs/design/Dorothy/project/Resources/ActionEditor/Script/oViewArea.lua`
- `Docs/design/Dorothy/project/Resources/ActionEditor/Script/oViewPanel.lua`
- `Docs/design/Dorothy/project/Resources/ActionEditor/Script/oControlBar.lua`
- `Docs/design/Dorothy/project/Resources/ActionEditor/Script/oSettingPanel.lua`
- `Docs/design/Dorothy/project/Resources/ActionEditor/Script/oFileChooser.lua`
- `Docs/design/Dorothy/project/Resources/ActionEditor/Script/oEditChooser.lua`
- `Docs/design/Dorothy/project/Resources/ActionEditor/Script/oLookChooser.lua`
- `Docs/design/Dorothy/project/Resources/ActionEditor/Script/oSpriteChooser.lua`
- `Docs/design/Dorothy/project/Resources/ActionEditor/Model/Output/*.clip`
- `Docs/design/Dorothy/project/Resources/ActionEditor/Model/Output/*.model`

当前 Web IDE 相关接入点：

- `Tools/dora-dora/src/App.tsx`
- `Tools/dora-dora/src/Editor.tsx`
- `Tools/dora-dora/src/Service.ts`
- `Assets/Script/Dev/WebServer.yue`

当前引擎运行时相关能力：

- `Model(filename)` 可加载 `.model`
- `Model.getClipFile(filename)` / `Model.getLooks(filename)` / `Model.getAnimations(filename)`
- `Sprite.getClips(clipFile)` 可读取 `.clip`
- `Service.read()` / `Service.write()` 可读写 Web IDE 工作区文件
- WebSocket `UpdateFile` 可把外部写入同步到资源树和已打开文件

## 技术栈

新版 ActionEditor 的编辑器界面使用一个浏览器 canvas 作为主绘制入口，整个编辑器 UI 和预览都在这个 canvas 内完成：

- React 只负责 Web IDE tab 宿主、生命周期、尺寸变化、Service 调用和键盘事件分发。
- Canvas 是 ActionEditor 的唯一编辑器绘制面，不使用 Monaco、HTML 表单或 DOM 面板来拼编辑器界面。
- WebGL 负责 sprite 预览、texture 上传、quad 渲染、selection outline、gizmo 辅助图形和 ImGui draw data 绘制。
- ImGui 使用 `imgui-ts`，即 [zhobo63/imgui-ts](https://github.com/zhobo63/imgui-ts)，作为 Dear ImGui 的 TypeScript/WebGL 绑定。
- ImGui 字体使用 `sarasa-mono-sc-regular`，用于保证中文、英文、数字和代码风格字段在编辑器内一致显示。
- ImGui 配色和 style 必须和 `Source/GUI/ImGuiDora.cpp` 中 `DoraSetupTheme()` 与 `ImGuiDora::init()` 的设置保持一致。
- ActionEditor 的菜单、工具栏、节点树、属性面板、时间轴、弹窗和 `.clips` 目录选择 UI 都用 ImGui 绘制。
- ImGui 的输入焦点需要和 Web IDE 快捷键系统隔离；当 ImGui 捕获键盘或鼠标时，不把对应事件继续传给全局编辑器快捷键。
- 图片、`.clip`、`.model` 和 `.clips` 目录仍通过 Web IDE 现有 Service/WebServer 读写，不让 imgui-ts 直接承担资源 IO。

推荐依赖接入方式：

- 在 `Tools/dora-dora` 前端依赖中引入 `@zhobo63/imgui-ts`。
- 封装 `ActionImGuiRuntime`，集中处理 `ImGui.default()`、`ImGui.CreateContext()`、字体、style、`ImGui_Impl.Init(canvas)`、frame begin/end 和 dispose。
- 在 `ActionImGuiRuntime` 中加载 `sarasa-mono-sc-regular` 字体文件，并按 `ImGuiDora::setDefaultFont()` 的行为配置 font atlas：清空默认字体、设置默认字体、启用 pixel snap，并保持横向/纵向 oversample 为 1。
- 在 `ActionImGuiRuntime` 中实现 `applyDoraImGuiStyle(themeColor)`，从 `ImGuiDora.cpp` 迁移 style 数值和 `DoraSetupTheme()` 的颜色公式。
- ActionEditor 业务代码只调用本地封装，不在各个面板模块里直接初始化 ImGui context。
- 如果后续确认 `imgui-ts` 和当前前端打包链路不兼容，必须先评估兼容 shim 或局部打包配置；不能把 UI 方案退回 DOM/HTML 面板。

需要对齐的 `ImGuiDora::init()` style 值包括：

- `Alpha = 0.9`
- `WindowPadding = (10, 10)`
- `WindowMinSize = (100, 32)`
- `WindowRounding = 6`
- `WindowBorderSize = 0`
- `WindowTitleAlign = (0.5, 0.5)`
- `ChildRounding = 6`
- `ChildBorderSize = 0`
- `FramePadding = (5, 5)`
- `FrameRounding = 6`
- `FrameBorderSize = 0`
- `ItemSpacing = (10, 10)`
- `ItemInnerSpacing = (5, 5)`
- `TouchExtraPadding = (5, 5)`
- `IndentSpacing = 10`
- `ColumnsMinSpacing = 5`
- `ScrollbarSize = 25`
- `ScrollbarRounding = 6`
- `GrabMinSize = 20`
- `GrabRounding = 6`
- `TabRounding = 6`
- `TabBorderSize = 0`
- `PopupRounding = 6`
- `PopupBorderSize = 0`
- `ButtonTextAlign = (0.5, 0.5)`
- `DisplayWindowPadding = (50, 50)`
- `DisplaySafeAreaPadding = (5, 5)`
- `AntiAliasedLines = true`
- `AntiAliasedFill = true`
- `CurveTessellationTol = 1`

`DoraSetupTheme()` 的颜色策略也要迁移，而不是只近似使用深色主题。主题色来自 Web IDE 当前 Dora theme color，按同样的 `HI`、`MED`、`LOW`、`BG`、`TEXT`、`BUTTON`、`TRANSPARENT` 公式写入 ImGui colors。这样 ActionEditor 和引擎内置 ImGui 面板在视觉上保持一致。

字体资源约束：

- 优先复用项目已有的 `sarasa-mono-sc-regular` 资源；如果 Web IDE 前端 bundle 不能直接访问，需要通过静态资源路径或 WebServer 字体读取接口暴露给浏览器。
- 如果字体加载失败，必须显示可见诊断；不能静默退回浏览器默认字体后继续验收通过。

## 旧 ActionEditor 功能拆解

### 总体结构

旧 `main.lua` 只负责创建 `oEditor`，设置能否退出，并交给 Director 运行。

`oEditor.lua` 是全局状态中心：

- 维护当前 model、look、animation、sprite、spriteData、keyIndex、dirty、needSave、loop、isPlaying。
- 定义压缩表索引 `oSd`、`oAd`、`oKd`、`oFd`。
- `edit(modelFile, clipFile)` 加载或创建模型数据，重建预览模型，清空时间轴和属性面板，刷新层级树，进入 Sprite 编辑模式。
- 异步加载 `oViewArea`、`oEditMenu`、`oViewPanel`、`oControlBar`、`oSettingPanel`、`oVertexControl`。

旧实现把模型数据、运行时节点和 UI 状态混在同一个 Lua 场景中。新版要拆开：`.model` 是外部持久文件，内部 `ActionDocument` 是编辑期工作态，渲染状态是派生缓存，UI 选择态是会话状态。

### 文件选择和图集生成

`oFileChooser.lua` 支持三类入口：

- 选择已有 `.model`。
- 选择已有 `.clip` 并创建对应 `.model`。
- 从 `Model/Input/<group>/*.png` 打包生成 `Model/Output/<group>.png` 和 `<group>.clip`。

图集打包使用 `oPacker.lua` 的 growable bin packing。它按最大边降序排序图片块，逐个放入二叉空间树，必要时向右或向下扩展根节点。

新版策略：

- 不再兼容旧 `Model/Input` 和 `Model/Output` 目录约定。
- 以当前 `.model` 所在目录作为资源根。
- 在 `.model` 同目录查找以 `.clips` 结尾的目录作为图集输入目录，例如 `Hero.clips/`。
- 默认优先使用与 `.model` 同 basename 的输入目录：`Hero.model` 对应 `Hero.clips/`。
- 如果同目录存在多个 `.clips` 目录，提供选择 UI；默认选中同 basename 的目录。
- 将所选输入目录中的图片打包输出到同目录下的 `.png` 和 `.clip`，例如 `Hero.clips/` 输出 `Hero.png` 和 `Hero.clip`。
- `.model` 内引用同目录输出的 `.clip` 文件，例如 `A="Hero.clip"`。
- 图集打包逻辑可以复用旧 `oPacker` 的 growable bin packing，或复用当前 TexturePacker 的实现，但 UI 和路径规则必须归属于 ActionEditor 当前 `.model` 目录。

### 编辑模式

旧 `oEditMenu.lua` 有四个主要模式：

- `EDIT_START`：初始文件选择态，画布、层级树、属性面板禁用。
- `EDIT_SPRITE`：编辑节点树和默认姿态。
- `EDIT_ANIMATION`：编辑某个 animation 的关键帧。
- `EDIT_LOOK`：编辑某个 look 下哪些节点隐藏。

每个模式会显示不同按钮组合：

- Sprite：Fix、Face、Add、Remove、Up、Down、Change、Move、Origin、Zoom。
- Animation：Del、Fix、New、Delete、Copy/Paste、Clear、Play、Loop、Look。
- Look：Del、Visible。

新版不需要复刻旧按钮布局，但必须保留模式语义和命令集合。推荐 UI：

- 左侧：资源/节点树。
- 中间：Canvas 预览和交互。
- 右侧：属性面板。
- 底部：时间轴，仅 Animation 模式显示。
- 顶部：模式切换、保存、撤销/重做。

### 节点树编辑

旧 Sprite 模式支持：

- 添加节点或 Sprite。
- 删除非根节点。
- 上移/下移调整兄弟顺序。
- 替换 Sprite clip。
- Move 两段式移动，把一个节点改挂到另一个节点下，且禁止移动到自己的子孙。
- 修改 Face Right。
- 修改 root size。
- 修改默认变换：position、scale、rotation、skew、opacity、anchor、front。
- 编辑关键点 `keys`，用于游戏逻辑挂点。

`oViewPanel.lua` 负责显示树。它从 `modelData` 和运行时 `model.children[1]` 建立映射，并把运行时 sprite 节点缓存回 `sp[oSd.sprite]`。这也是旧实现容易出错的地方：每次重建模型后，树节点、选中项和运行时 node 都必须重新对齐。

新版设计：

- 内部对象模型中每个节点有稳定 `id`，不要依赖对象引用或数组索引做选择态。
- 层级树操作只修改内部对象树。
- 渲染层根据内部对象树生成 `RenderNode` 映射 `nodeId -> renderNode`。
- 选中态只保存 `selectedNodeId`。
- 任何重建预览后通过 `selectedNodeId` 恢复选择，不保存运行时节点引用到数据对象里。

### Animation 编辑

旧 Animation 模式通过 `animationNames` 把动画名映射到数字 index；每个 sprite 的 `animationDefs[index + 1]` 保存该 sprite 在该动画中的定义。

旧关键帧动画格式：

- `animationDef[1] = 1` 表示 key animation。
- 从 `animationDef[2]` 开始是 frame list。
- 每个 frame 保存 x、y、scaleX、scaleY、skewX、skewY、angle、opacity、visible、各属性 ease、duration、event。
- duration 是到当前帧的段时长，旧 UI 按 60fps 展示，`ControlBar` 的位置是 frame index，实际秒数为 `pos / 60`。

旧编辑能力：

- 在当前时间插入新关键帧。
- 删除当前关键帧。
- Copy/Paste 当前关键帧到另一个时间点。
- Clear 清空当前 sprite 在当前 animation 上的关键帧。
- 修改当前关键帧的 position、scale、rotation、skew、opacity、visible、event、各 ease。
- 播放、暂停、循环。
- 时间轴拖拽和点击跳转。
- 时间轴显示关键帧光标。

旧实现插入关键帧时会调整后一帧 duration，删除时会把当前 duration 合并到后一帧。这一规则必须保留，否则播放时长会漂移。

新版设计：

- 内部对象模型中不要用 duration-only 链式结构作为主编辑模型。主模型使用绝对时间 `time`，单位秒。
- 保存 `.model` 时再转换成旧引擎需要的 duration 序列。
- UI 仍以 60fps 网格显示，`frame = round(time * 60)`。
- 对内编辑时保留 `time`，插入、移动和删除关键帧更稳定，也更容易做 undo/redo；对外保存时写回 `.model` 的 duration 序列。

### Look 编辑

旧 Look 模式：

- `lookNames` 把 look 名映射到 index。
- 每个 sprite 的 `looks` 保存“在这些 look 下隐藏”的 index 列表。
- `Visible` 按钮实际是在当前 selected sprite 上添加或删除当前 look index。
- 选择 `None` 会清空当前 model look。

新版设计：

- 内部对象模型中 look 使用稳定 name，不使用 index 作为编辑期标识。
- 节点上保存 `hiddenInLooks: string[]`。
- 保存 `.model` 时生成旧 index 映射。

### 属性编辑

旧 `oSettingPanel.lua` 根据模式和选中对象动态显示属性：

- Sprite/root 属性：name、anchorX/Y、width/height、posX/Y、scaleX/Y、angle、opacity、skewX/Y、front、key points。
- Animation key 属性：posX/Y、scaleX/Y、angle、opacity、skewX/Y、visible、easePos、easeScale、easeSkew、easeAngle、easeOpacity、event。
- Look 模式不显示属性面板。

旧 `oViewArea.lua` 支持点击属性项后在画布上拖拽修改对应值。`Fix` 开启时对数值进行取整或步进吸附。

新版设计：

- 右侧属性面板使用 ImGui 表单直接编辑数值。
- Canvas gizmo 提供常用变换拖拽：move、rotate、scale、anchor、size。
- 精细属性通过 ImGui 输入框完成。
- `Fixed` 作为 snapping 设置，作用于 gizmo 和数值 steppers。

### 画布交互

旧 `oViewArea.lua` 覆盖：

- 平移、惯性滚动、缩放循环、回原点。
- 选中 sprite 的旋转、位置、缩放、透明度、skew、anchor、root size 编辑。
- 切换 front、visible、ease。
- 修改后调用 `view:getModel()` 重建运行时模型，并通知 `viewPanel:updateSprite()` 对齐运行时节点。

新版设计：

- Canvas 坐标系统保持模型空间和屏幕空间分离。
- 渲染循环：
  1. 读取内部 `ActionDocument`。
  2. 计算当前 pose，包括默认 pose、look 可见性、当前 animation 插值。
  3. 用 WebGL 渲染 sprite quad。
  4. 用 ImGui 绘制 toolbar、panels、timeline。
  5. 用 Canvas overlay 或 ImGui draw list 绘制 gizmo、selection outline、anchor、root bounds。
- 不在数据对象中保存临时渲染节点。

### 保存和撤销

旧 `oEditMenu`：

- `markEditButton(true)` 把 Menu 改成 Save，显示 Undo。
- Save 前调用 `viewArea:getModel()` 让运行时模型由当前数据重建，再 `oCache.Model:save()` 写 `.model`。
- Undo 会卸载模型缓存并重新 `edit(modelFile)`。

历史 TS 移植中暴露过一个核心风险：保存、撤销、模型重建、层级树选择四者很容易漂移。新版必须把 `.model` 文件读写、内部对象变更和派生渲染状态分离。

新版设计：

- 内部对象模型修改即进入 dirty。
- Undo/redo 使用 command stack 或对象 patch，至少覆盖节点树、关键帧、look、属性改动。
- Save 直接把当前内部对象模型序列化回当前 `.model` 文件。
- 不单独输出 `.action.json`。
- Preview 可以使用浏览器渲染，不依赖引擎；Run Preview 可先保存或生成临时 `.model`，再调用引擎加载验证。

## 旧数据格式解读

### `.clip`

示例：

```xml
<A A="role.png"><B A="body" B="2,2,54,119"/></A>
```

含义：

- 根 `A` 的 `A` 属性是 texture 文件。
- 子 `B` 的 `A` 属性是 clip name。
- 子 `B` 的 `B` 属性是 rect：`x,y,width,height`。

新版直接解析 `.clip` 作为图集切片来源，不把它内嵌到 `.model`。内部对象模型只引用 `clipFile` 和 `clip` name。

### `.model`

`.model` 是字母压缩的 XML 风格格式。旧 C++ `toXml()` 显示主要含义：

- 根 `A`：model，属性 `A` 是 clip file，`B` 是 faceRight，`C` 是历史 useBatch 标记，`D` 是 root size。
- 节点 `B`：sprite/node。
- 节点 `C`：key animation。
- 节点 `D`：key frame。
- 节点 `I`：look name 映射。
- 节点 `J`：animation name 映射。
- 节点 `F`：look hide list。
- 关键点节点使用 key + position 属性。

旧 Lua 中压缩表索引如下：

```ts
type LegacySpriteDef = [
  anchorX, anchorY, clip, name, opacity, angle, scaleX, scaleY,
  skewX, skewY, x, y, looks, animationDefs, children, front,
  isFaceRight, isBatchUsed, size, clipFile, keys, animationNames, lookNames
];
```

新版内部对象模型应使用语义字段，不延续数字索引表。数字索引表只存在于 `.model` 解析/序列化边界。`isBatchUsed` 只作为旧格式兼容字段读取；新的 Dora 引擎已经自动做 sprite 渲染 batch，编辑器 UI 不再暴露 Batch Used，也不让用户维护这个开关。

## 内部对象模型

内部对象模型建议命名为 `ActionDocument`。它是 Web IDE 会话中的工作态，不作为默认持久文件保存。打开 `.model` 时解析得到它，保存时由它序列化回 `.model`。

```ts
interface ActionDocument {
  version: 1;
  type: "Dora.Action";
  clipFile: string;
  textureFile?: string;
  model: ActionModel;
  animations: Record<string, ActionAnimation>;
  looks: Record<string, ActionLook>;
  metadata?: {
    sourceModelFile?: string;
    generatedModelFile?: string;
    generatedLuaFile?: string;
  };
}

interface ActionModel {
  id: string;
  name: string;
  faceRight: boolean;
  size: { width: number; height: number };
  keys: Record<string, Vec2>;
  root: ActionNode;
}

interface ActionNode {
  id: string;
  name: string;
  clip: string;
  transform: NodeTransform;
  front: boolean;
  hiddenInLooks: string[];
  children: ActionNode[];
}

interface NodeTransform {
  anchor: Vec2;
  position: Vec2;
  scale: Vec2;
  skew: Vec2;
  rotation: number;
  opacity: number;
}

interface ActionAnimation {
  name: string;
  tracks: Record<string, NodeTrack>;
}

interface NodeTrack {
  nodeId: string;
  keys: KeyFrame[];
}

interface KeyFrame {
  time: number;
  transform: Partial<NodeTransform>;
  visible?: boolean;
  easing?: {
    position?: EaseName;
    scale?: EaseName;
    skew?: EaseName;
    rotation?: EaseName;
    opacity?: EaseName;
  };
  event?: string;
}

interface ActionLook {
  name: string;
}

interface Vec2 {
  x: number;
  y: number;
}
```

字段原则：

- `id` 稳定，不随重命名、移动、排序变化。
- 内部对象模型保存绝对时间，保存 `.model` 时转 duration。
- look 和 animation 以 name 为编辑期 key。
- 默认 transform 和 animation key frame transform 分离。
- `clip` 为空字符串表示纯 Node。

## 文件读写和产物

### 主文件：`.model`

为了和当前引擎流程整合，ActionEditor 的主文件就是 Dora 当前 `Model(filename)` 能加载的 `.model` 文件。新版编辑器应支持直接打开、编辑、保存 `.model`。

推荐命名：

- 源文件/保存文件：`Assets/Role/Hero.model`
- 图集输入目录：`Assets/Role/Hero.clips/`
- 图集输出文件：`Assets/Role/Hero.clip` + `Assets/Role/Hero.png`

读写器职责：

1. 读取 `.model` XML 字符串。
2. 解析为内部 `ActionDocument`。
3. 以 `.model` 所在目录解析 `clipFile`，并解析 `.clip`。
4. 验证所有 node clip 名称存在。
5. 如用户触发图集更新，在 `.model` 同目录查找 `.clips` 输入目录；多个目录时由用户选择，并输出所选 basename 的 `.clip`/`.png`。
6. 编辑过程中维护内部对象模型、undo/redo 和浏览器预览。
7. 保存时生成 animation index 和 look index。
8. 把每个 node track 的绝对时间 key 转为 duration key。
9. 输出旧 `.model` XML 字符串。
10. 通过 `Service.write()` 写回当前 `.model`。
11. 依赖 WebSocket `UpdateFile` 或本地 state 更新，让资源树和已打开 `.model`、`.clip`、`.png` 同步。

## Web IDE 集成设计

### 文件创建

Web IDE 的文件资源创建入口需要新增 Dora 动画文件类型，例如 `Dora Animation Model` / `Dora 动画文件`。

创建规则：

- 在当前选中的目录中创建 `.model` 文件；如果当前选中的是文件，则默认创建到该文件所在目录。
- 文件名由用户输入，未带扩展名时自动补 `.model`。
- 新文件内容使用 ActionEditor writer 生成的空模型 XML，不创建 `.action.json`。
- 创建成功后打开该 `.model` tab，并默认进入 ActionEditor 可视化界面。
- 新建时不自动创建 `.clips` 目录、`.clip` 或 `.png`；用户后续在 ActionEditor 中选择同目录 `.clips` 目录并触发图集打包。
- 如果同目录已经存在同 basename 的 `.clips` 目录，ActionEditor 打开后可默认选中它作为图集输入候选。

这个入口应接入现有 `NewFileDialog` / `Service.newFile()` 流程，避免为 ActionEditor 单独实现文件创建协议。

### 文件打开

在 `Tools/dora-dora/src/App.tsx` 的文件类型分发中新增：

- `.model` 识别为 ActionEditor。
- 打开时渲染 `ActionEditor` React 组件，而不是 Monaco。
- 不开发源码文本切换；`.model` 在 ActionEditor 中以可视化方式编辑。

### 资源读写

ActionEditor 组件需要以下 props：

```ts
interface ActionEditorProps {
  file: string;
  content: string;
  width: number;
  height: number;
  readOnly: boolean;
  onChange(modelContent: string): void;
  onSave(): void;
  onKeydown(event: KeyboardEvent): void;
  addAlert(message: string, type: AlertColor): void;
}
```

`content` 是当前 `.model` 文件内容。组件加载后立即解析成内部 `ActionDocument`；编辑后 `onChange()` 传回新的 `.model` XML 内容，让现有 tab dirty/save 流程处理真实写入。这样保存语义和普通文本文件一致。

如果初次解析失败，组件应提示加载失败，创建一个空的 `ActionDocument`，立即生成对应的空 `.model` XML 并调用 `onChange()`，让当前 tab 进入待保存状态。用户保存后会用空模型覆盖原 `.model`；需要保留原内容时可以直接关闭未保存 tab。

### 保存时机

建议分三档：

- 编辑中：只更新浏览器预览，不写文件。
- 修改内部对象模型：同步生成新的 `.model` XML，标记当前 tab dirty。
- Save / Save All：通过现有 `Service.write()` 写回当前 `.model`。

如果后续需要 Lua factory，可以提供单独的 Export Lua 命令，但不作为 ActionEditor 保存路径的一部分。

### WebServer 接口

短期可以完全用现有 `/read` 和 `/write`：

- 读 `.model`、同目录 `.clip`、同目录 `.clips` 输入目录、图片 URL。
- 写 `.model`，以及图集更新时写同目录 `.clip` 和 `.png`。

中期可以新增专用校验接口：

- `POST /action/validate`
- 输入：`{ path: string, content?: string }`
- 输出：`{ success, diagnostics }`

好处：

- `.model` 解析和校验逻辑可以复用到 CLI、Agent、批量检查。
- 错误信息由服务端统一格式化。

### 与 Agent 和外部修改同步

现有 WebSocket `UpdateFile` 已能同步任意文件：

- 外部工具或 Agent 修改当前 `.model` 后，ActionEditor 应监听对应 model 内容变化并重新解析。
- Agent 生成或修改 `.model` 不应自动打开 tab，只更新树和已打开文件。这和现有 UpdateFile 约定一致。

## 编辑器内部架构

推荐目录：

```text
Tools/dora-dora/src/ActionEditor/
  ActionEditor.tsx
  ActionEditorCanvas.ts
  ActionEditorImGui.ts
  ActionImGuiRuntime.ts
  ActionEditorState.ts
  ActionDocument.ts
  ActionLegacyModel.ts
  ActionClip.ts
  ActionPlayback.ts
  ActionCommands.ts
  ActionSelection.ts
  ActionGizmo.ts
```

职责：

- `ActionDocument.ts`：类型、默认值、迁移、clone。
- `ActionClip.ts`：解析 `.clip`，加载 texture 和 rect。
- `ActionLegacyModel.ts`：`.model` 解析/生成，负责 `.model` 和内部 `ActionDocument` 的双向转换。
- `ActionEditorState.ts`：当前 mode、selectedNodeId、selectedAnimation、selectedLook、time、dirty、viewport。
- `ActionCommands.ts`：undo/redo command。
- `ActionPlayback.ts`：pose sampling、ease、loop、play/pause。
- `ActionEditorCanvas.ts`：WebGL 初始化、资源上传、sprite 渲染。
- `ActionImGuiRuntime.ts`：`imgui-ts` 初始化、frame lifecycle、`sarasa-mono-sc-regular` 字体、Dora ImGui style/theme、输入捕获和资源释放。
- `ActionGizmo.ts`：hit test、transform handles。
- `ActionEditorImGui.ts`：菜单、面板、时间轴、属性。
- `ActionEditor.tsx`：React 生命周期、Service 集成、尺寸、键盘事件。

## 渲染和预览

### 浏览器预览

ActionEditor 的主预览应在浏览器端完成：

- 加载 `.png` texture。
- 解析 `.clip` rect。
- 根据内部对象树绘制 sprite。
- 应用 transform、anchor、opacity、visibility、front/order。
- 根据当前 animation 和 time 做插值。
- 根据 look 隐藏节点。

这能保证编辑体验不依赖引擎运行状态，也不会因为脚本崩溃影响 Web IDE。

### 工程运行

ActionEditor 不提供“运行当前动画 model”的命令。`.model` 是资源文件，不是可直接执行的脚本入口。

运行语义沿用 Web IDE：

- 用户在编辑 `.model` 时点击工程运行命令，触发的是当前游戏工程运行。
- 用户在编辑 `.model` 时执行 Run Current File，应提示“无法运行当前文件”。
- ActionEditor 的浏览器预览只用于编辑反馈，不替代游戏工程运行。

## `.model` 加载

ActionEditor 必须直接支持打开 `.model`：

1. 用户打开 `.model` 时默认进入 ActionEditor 可视化界面。
2. 编辑器解析 `.model` XML 压缩格式。
3. 生成内部 `ActionDocument` 工作态。
4. 用户保存时直接覆盖原 `.model`。
5. 如解析失败，提示加载失败，创建空 `ActionDocument`，并把编辑 tab 标记为待保存状态。

解析策略：

- 根 `A` 的 clipFile、faceRight、size 转到 `model`；历史 useBatch 标记仅在解析层保留兼容，不进入可编辑属性。
- 递归 `B` 节点生成 `ActionNode`。
- `I` look name 映射转 `looks`。
- `J` animation name 映射转 `animations`。
- 每个节点下的 `C` key animation 转对应 animation track。
- 每个节点下的 `F` hidden look index 转 `hiddenInLooks`。
- 关键点转 `model.keys`。

注意旧 `.model` 的 key frame 是增量属性输出：某一帧 XML 只写和上一帧不同的字段。解析时要做还原，补齐每帧完整 transform 后再进入内部对象模型。保存时可以重新按旧规则压缩输出。

## 关键行为规则

必须保留：

- Animation 时间轴以 60fps 为编辑网格。
- 插入关键帧不改变后续关键帧的绝对时间。
- 删除关键帧不改变后续关键帧的绝对时间。
- Copy/Paste 复制 transform、visible、ease、event，但 paste 后 time 使用目标时间。
- Look 表示“当前 look 下隐藏该节点”，不是“只显示这些节点”。
- Move 节点时禁止移动到自身或自身子孙。
- 纯 Node 允许 `clip = ""`。
- root 节点不可删除。
- root name 不可编辑，旧实现也禁止 root name 编辑。
- `front` 控制子节点相对父节点的前后层级语义，不能丢。
- `faceRight`、`size` 是 model 级字段。

可以调整：

- 旧按钮位置和动画可以不 1:1。
- 旧的半透明 DrawNode 风格可以改成 Web IDE 内一致的工具界面。
- FileChooser 不再提供旧 Input/Output 模式，只围绕当前 `.model` 同目录资源工作。
- 内置图集打包可以延后，但一旦实现必须使用同目录 `.clips` -> `.clip`/`.png` 规则。

## MVP 范围

第一阶段建议只做一个完整闭环：

1. 打开 `.model`。
2. 读取 `.clip` 和 `.png`。
3. 渲染节点树和默认 pose。
4. 支持节点选择、移动、旋转、缩放、anchor、opacity。
5. 支持添加、删除、重排、替换 clip。
6. 支持创建 animation，添加/删除/移动关键帧。
7. 支持时间轴 scrub 和浏览器播放。
8. 支持创建 look，切换节点隐藏状态。
9. 保存回同一个 `.model`。
10. 用 `Model("...")` 在引擎里加载保存后的 `.model` 验证。

MVP 暂不做：

- frame animation type 2。
- 复杂多选。
- 曲线编辑器。
- 自动 IK 或骨骼约束。

## 实施步骤

### Phase 1：数据和读写

- 定义 `ActionDocument` schema。
- 实现 `.clip` parser。
- 实现 `.model` 同目录资源路径解析。
- 实现 `.clips` -> `.clip`/`.png` 图集打包。
- 实现旧 `.model` parser。
- 实现旧 `.model` writer。
- 实现 `.model` -> `ActionDocument` -> `.model` 双向转换。
- 用历史 `role.model`、`flandre.model` 做 round-trip 对比。

验收：

- 历史 `.model` 能解析为内部对象模型。
- 保存后的 `.model` 能被 `Model(filename)` 加载。
- `Model.getAnimations()` 和 `Model.getLooks()` 返回预期名称。
- 旧样例 round-trip 后不丢节点、look、animation 名称。

### Phase 2：Web IDE 宿主

- 在 `App.tsx` 中识别 `.model`。
- 在 Web IDE 文件资源创建入口新增 Dora 动画文件类型，创建空 `.model` 并打开 ActionEditor。
- 新增 `ActionEditor` React 组件。
- 接入 `@zhobo63/imgui-ts` 依赖，并封装 `ActionImGuiRuntime`。
- `ActionImGuiRuntime` 加载 `sarasa-mono-sc-regular`，并迁移 `Source/GUI/ImGuiDora.cpp` 的 style 与 theme 设置。
- 接入 `Service.read()` 读取同目录 `.clip`。
- 接入当前 tab 的 dirty/save 流程写 `.model`。
- 不提供源码文本切换。

验收：

- ActionEditor tab 内只有 canvas 编辑器，ImGui UI 可正常渲染并接收输入。
- ImGui 中文文本使用 `sarasa-mono-sc-regular` 渲染，style 和配色与 `Source/GUI/ImGuiDora.cpp` 保持一致。
- Web IDE 中可新建 `.model`，创建后自动打开 ActionEditor。
- 打开 `.model` 默认显示可视化编辑器。
- 保存后资源树和已打开文件同步。

### Phase 3：Canvas/WebGL 预览

- 初始化 WebGL renderer。
- 加载 texture。
- 根据 `.clip` rect 绘制 sprite quad。
- 实现 viewport pan/zoom。
- 实现 selection outline、anchor、root bounds。

验收：

- 历史角色图集能在浏览器正确显示。
- pan/zoom 不影响模型坐标。
- 节点层级顺序和 front 语义正确。

### Phase 4：ImGui UI 和命令

- 顶部 toolbar。
- 左侧节点树。
- 右侧属性面板。
- 底部时间轴。
- undo/redo command stack。

验收：

- Sprite、Animation、Look 三种模式可切换。
- 属性变更进入 dirty 和 undo stack。
- 保存和工程运行不改变当前选择。

### Phase 5：动画编辑

- 实现 pose sampler。
- 实现 keyframe add/delete/copy/paste。
- 实现 easing。
- 实现 play/pause/loop/scrub。
- 实现 event 字段编辑。

验收：

- 插入/删除关键帧后后续帧绝对时间不漂移。
- 浏览器播放和引擎 `Model()` 播放时长一致。
- 关键帧光标与属性面板同步。

### Phase 6：兼容性增强

- 扩展 `.model` parser 对历史边界格式的兼容性。
- 增加错误定位；解析失败时走空模型待保存流程。
- 批量验证历史 `.model` 样例；验证时不保留旧 Input/Output 目录规则，只验证解析能力。

验收：

- 能打开 `role.model` 并进入可视化编辑。
- 保存后的 `.model` 可被引擎加载。
- 至少对节点数、动画名、look 名、clip 引用、关键点做自动校验。

## 测试清单

数据：

- 空模型创建。
- 只有纯 Node 的模型。
- 多层嵌套 sprite。
- clip 为空、clip 缺失、clip 名不存在。
- 重名 node。
- look 删除后节点 hiddenInLooks 清理。
- animation 删除后 tracks 清理。

时间轴：

- 0 秒插入第一帧。
- 非 0 秒插入第一帧，需要生成初始帧。
- 两帧之间插入。
- 删除中间帧。
- 删除第一帧。
- copy 后 paste 到已有帧和空白时间。
- loop 播放。

集成：

- Web IDE 文件资源创建入口可创建空 `.model`，并自动打开 ActionEditor。
- `.model` 保存。
- 图集更新从同目录 `.clips` 目录读取图片。
- 图集更新输出同目录 `.clip` 和 `.png`。
- `.model` 内的 `clipFile` 指向同目录 `.clip`，不依赖旧 Input/Output 目录。
- 不提供源码文本切换。
- 外部修改 `.model` 后当前编辑器刷新或提示冲突。
- Agent 修改 `.model` 只更新树和已打开文件，不自动打开新 tab。
- readOnly 文件不允许写入。

性能：

- 200 个节点可编辑。
- 20 个 animation，每个 100 key 可 scrub。
- 大图集加载后不会阻塞 UI。

## 风险和决策

### 风险：内部对象模型与 `.model` 语义不一致

缓解：

- `.model` parser/writer 集中维护映射。
- 用历史样例做 parse/save/run 验证。
- 不在 UI 组件里直接拼 `.model`。

### 风险：浏览器预览和引擎 Model 行为不一致

缓解：

- 浏览器预览用于编辑反馈。
- 工程运行用于验证游戏侧集成，不提供单独的 model 运行入口。
- 对 easing、front、look、opacity、anchor 建立专门测试样例。

### 风险：ImGui 输入和 Web IDE 快捷键冲突

缓解：

- ActionEditor 捕获 canvas focus 内的快捷键。
- Ctrl/Cmd+S、W、R 等转发给 Web IDE 统一处理。
- 文本输入聚焦时阻止全局快捷键。

### 风险：旧 `.model` 解析复杂

缓解：

- 第一阶段先覆盖当前样例 `.model` 的核心 XML 子集。
- 解析失败时提示加载失败，创建空模型对象，并通过 `onChange()` 标记当前 tab 为待保存。
- 解析时完整展开增量 key frame，再进入内部对象模型。

### 决策：外部持久文件仍是 `.model`，内部使用对象模型

这是当前引擎流程下最稳的折中：用户继续直接维护 Dora 已有 `.model` 资源，游戏运行时继续使用 `Model()` 加载；编辑器内部获得语义化对象模型带来的稳定选择态、undo/redo 和动画时间编辑能力，但不引入额外 JSON 源文件。
