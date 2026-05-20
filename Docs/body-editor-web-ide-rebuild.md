# BodyEditor Web IDE 迁移设计

## 目标

把 Dorothy 历史项目中的 BodyEditor 迁移到新版 Dora SSR Web IDE，使 Web IDE 可以直接打开、编辑、预览和保存 Dora 物理体编辑资源 `.b.lua`。迁移方式参考现有 ActionEditor 的 Web IDE 重建路径：浏览器端提供完整编辑体验，内部使用语义化 TypeScript 数据模型，保存时写回新版 Dora 运行时 `BodyEx` 可加载的 Lua 文件格式。

本设计只针对 BodyEditor。ActionEditor 已经提供了可复用的 Web IDE 编辑器宿主、Canvas/ImGui 运行时、文件读写、外部更新同步、undo/redo 和资源路径处理经验，但 BodyEditor 不共享 ActionEditor 的动画数据模型。

## 参考来源

旧 BodyEditor 资源位于：

- `Docs/design/Dorothy/project/Resources/BodyEditor/Script/main.lua`
- `Docs/design/Dorothy/project/Resources/BodyEditor/Script/oEditor.lua`
- `Docs/design/Dorothy/project/Resources/BodyEditor/Script/oViewArea.lua`
- `Docs/design/Dorothy/project/Resources/BodyEditor/Script/oEditMenu.lua`
- `Docs/design/Dorothy/project/Resources/BodyEditor/Script/oEditControl.lua`
- `Docs/design/Dorothy/project/Resources/BodyEditor/Script/oViewPanel.lua`
- `Docs/design/Dorothy/project/Resources/BodyEditor/Script/oSettingPanel.lua`
- `Docs/design/Dorothy/project/Resources/BodyEditor/Script/oJointChooser.lua`
- `Docs/design/Dorothy/project/Resources/BodyEditor/Script/oPointControl.lua`
- `Docs/design/Dorothy/project/Resources/BodyEditor/Script/oVertexControl.lua`
- `Docs/design/Dorothy/project/Resources/BodyEditor/Script/generateLoader.lua`
- `Docs/design/Dorothy/project/Resources/BodyEditor/Body/Output/*.body`

新版引擎加载库：

- `Assets/Script/Lib/BodyEx.yue`
- `Assets/Script/Lib/BodyEx.lua`
- `Assets/Script/Lib/Utils.yue` 中的 `Struct` 定义

当前 Web IDE/ActionEditor 相关接入点：

- `Tools/dora-dora/src/App.tsx`
- `Tools/dora-dora/src/Editor.tsx`
- `Tools/dora-dora/src/Service.ts`
- `Tools/dora-dora/src/ActionEditor/ActionEditor.tsx`
- `Tools/dora-dora/src/ActionEditor/ActionEditorCanvas.tsx`
- `Tools/dora-dora/src/ActionEditor/ActionImGuiRuntime.ts`
- `Tools/dora-dora/src/ActionEditor/ActionEditorState.ts`
- `Assets/Script/Dev/WebServer.yue`

## 旧 BodyEditor 功能拆解

### 总体结构

旧 `main.lua` 只负责创建 `oEditor` 并把编辑器场景交给 Director 运行。核心状态集中在 `oEditor.lua`：

- 当前编辑文件 `currentFile`、当前选择 `currentData`、dirty/play 状态、视图原点和缩放。
- `bodyData` 是完整资源数据数组，`names` 维护唯一名称，`items` 维护名称到运行时 `oBody`/`oJoint` 的映射。
- `defaultShapeData` 定义所有 Body、SubShape 和 Joint 的压缩字段顺序、默认值、创建函数和 rename/reset 监听。
- `dumpData()` 把 `bodyData` 保存成 `local v,s,t,f = ... return {...}` 形式的旧 Lua 文件。
- `loadData()` 通过 `dofile()` 读取旧 `.body`，把数字 item type 转回名字，恢复 set/get/has/create 函数，并重建运行时物理对象。

旧实现把持久数据、运行时物理对象、UI 选择态和事件监听混在一个 Lua 场景里。新版要拆开：

- `.b.lua` 是新版编辑器唯一支持的用户可见持久资源格式；旧 `.body` 代码只作为交互和工作流参考，不再作为 Web IDE 的读取、导入或保存目标。
- `BodyDocument` 是编辑期工作态。
- Box2D world 和 Canvas 渲染对象是从 `BodyDocument` 派生出的预览缓存。
- UI 会话态只保存 selected id、工具模式、viewport、play state、clipboard 和 undo/redo。

### 数据类型

旧 BodyEditor 支持 20 种 item type：

- Body：`Rectangle`、`Circle`、`Polygon`、`Chain`、`Loop`
- SubShape：`SubRectangle`、`SubCircle`、`SubPolygon`、`SubChain`、`SubLoop`
- Joint：`Distance`、`Friction`、`Gear`、`Spring`、`Prismatic`、`Pulley`、`Revolute`、`Rope`、`Weld`、`Wheel`

Body 具备名称、运动类型、位置、角度、几何、材料、阻尼、重力缩放、子形状、可视化 face 等字段。SubShape 没有独立名称，挂在某个 Body 的 `SubShapes` 下。Joint 通过 Body 或 Joint 的名称引用依赖项，Gear 特别依赖两个已有 Joint。

旧保存格式使用数字表示 item type，例如 `1` 表示 `Rectangle`、`17` 表示 `Revolute`。新版 `BodyEx` 改为 Dora `Struct` 风格：根节点是 `{"Array", ...}`，每个 item 的首项是字符串类型名，例如 `"Phyx.Rect"`、`"Phyx.Revolute"`。字段仍然靠数组位置表达，不能随意调换顺序。为了让 Web IDE 可以直接走引擎侧空 `_ENV` 受控执行并 `json.encode(data, false, true)`，新版 `.b.lua` 不再写 `Vec2`/`Size` 对象构造，而是把向量和尺寸保存为普通 Lua 二元数组，例如 `{0,0}`、`{2970,10}`。Web IDE 可以使用更清晰的对象模型，但写出时必须完整保持 `BodyEx.yue` 注册的字段顺序。

### 编辑界面

截图中的旧界面由几块组成：

- 左侧工具栏：Menu/保存、矩形、圆形、多边形、链、闭合 loop、删除、Joint 选择入口。
- 中央视图：深色画布、世界坐标轴、水平/垂直标尺、平移和缩放、shape/joint 调试绘制。
- 顶部工具：固定 X/Y、Origin、缩放倍率、播放按钮。
- 右上列表：按 `bodyData` 顺序展示 Body、SubShape 和 Joint，选中项高亮。
- 右下属性面板：按选中 item type 展示字段，支持文本、数值、布尔、Body/Joint 选择、坐标点、轴向、顶点、Face 资源等编辑。
- 播放预览：切换 world scheduler 的 timeScale，编辑期间暂停物理，播放时运行物理模拟。

新版不需要逐像素复刻旧布局，但必须保留这些工作流。推荐延续 ActionEditor 的 Canvas + ImGui 方式，让 BodyEditor 在一个 Web IDE tab 内自成完整编辑器，而不是用 Monaco 或普通 DOM 表单拼凑局部面板。

## 旧版交互工作流

旧 BodyEditor 的界面行为可以从 Lua 事件链还原。核心事件流是：`oEditMenu.lua` 发起工具命令，`oViewArea.lua` 负责画布创建/拾取/视图变换，`oViewPanel.lua` 同步右侧列表和选择态，`oSettingPanel.lua` 展示字段，`oEditControl.lua` 根据字段名打开具体编辑控件，`oEditor.lua` 统一修改数据、重建 runtime item、保存和加载。

### 文件流程

- 入口：`oFileChooser.lua` 扫描旧 `Body/Output/**/*.body`，显示已有文件、`<NEW>`、`<DEL>`、Cancel/Quit。
- 打开：点击已有文件调用 `oEditor:edit(file)`，内部执行 `resetEditor()`、`loadData(file)`、`resetItems()`，然后通过 `Body.editor.bodyData` 刷新右侧列表。
- 新建：`<NEW>` 弹出名称输入，校验空名和非法字符后调用 `oEditor:new(file)`，立即 dump 一个空数据文件并发出 `Edited`。
- 保存：左上 `Menu` 按钮在 dirty 后变成 `Save`。点击时调用 `dumpData(currentFile)`，隐藏 Undo，发出 `Edited`。
- 撤销：旧版 Undo 不是多步历史，而是放弃当前 dirty 改动并重新 `edit(currentFile)`。Web IDE 版应提供真正的 undo/redo，但也要保留“恢复到上次保存”语义。

### 创建流程

- 左侧 Rectangle/Circle/Polygon/Chain/Loop 按钮是互斥工具。选中后发出 `Body.viewArea.create(shapeName)`，清空当前属性和选择。
- 画布下一次点击时，`oViewArea.lua` 根据 `shapeToCreate` 创建数据：
  - 若当前选中的是普通 Body 且不是 Joint，则创建 `Sub*` 子形状，点位转换到父 Body local space 后写入 `Center` 或 `Vertices`。
  - 否则创建顶层 Body，点位转换到 world space 后写入 `Position`。
- 创建完成后调用 `oEditor:addData()` 或 `addSubData()`，然后发出 `Body.viewPanel.choose(data)`、`Body.editMenu.created`、`Body.editor.change`。
- `addData()` 保持旧排序：Body 插到 Joint 之前，普通 Joint 插到 Gear 之前，Gear 保持在依赖 Joint 之后。

### 选择和定位

- 画布点击未拖动时，`oViewArea.lua` 对 world 做 1x1 query，命中 body 后发出 `Body.viewPanel.choose(data)`。
- 右侧列表点击时，`oViewPanel.lua` 发出 `Body.settingPanel.toState(itemType)`，并调用 `moveViewToData(data)` 把视图平移到选中对象附近。
- 对 Body/SubShape，定位优先使用 `Position`、`Center` 或父 Body transform；对 Joint，定位到 `BodyA` 或 `BodyB` 并短暂显示十字标记。
- 选择态只应保存数据 id。旧版把 runtime item、view item 和 dataItem 相互引用，Web IDE 版不要复用这种引用结构。

### 视图操作

- 单指/鼠标拖动画布平移，发出 `Body.viewArea.move(delta)`；松手后有惯性滚动。
- 双指缩放或滚轮缩放更新 view scale，并发出 `Body.viewArea.scale(scale)`。
- `Origin` 发出 `Body.viewArea.toPos(oEditor.origin)`，回到默认原点。
- `Zoom` 在 200%、50%、100% 间循环；收到 `Body.viewArea.scale` 时同步按钮文字。
- 水平/垂直标尺跟随 view pan/scale 更新。Web IDE 版可以保留标尺，但应把它作为 Canvas overlay，而不是独立 DOM 控件。

### 属性面板和编辑控件

`oSettingPanel.lua` 按 item type 决定字段列表；`oEditControl.lua` 根据字段名打开具体编辑器：

- `Name`：文本输入结束时校验唯一名，调用 `oEditor:rename(oldName,newName)`，并通过 `Body.editor.rename` 更新 Joint 引用和列表文字。
- `Type`：Dynamic/Static/Kinematic 选择器，变更后重建 Body。
- `Position`：世界坐标拖拽箭头，支持 Fix X/Y 和整数吸附；实时更新 runtime body position。
- `Angle`：圆形旋转控件；对 SubShape 使用父 Body position 和 local center。
- `Center`、`FacePos`：点位拖拽控件；`Center` 会重建 fixture，`FacePos` 只移动视觉子节点。
- `Size`、`Radius`：尺寸/半径拖拽控件，带最小值限制。
- `Vertices`：顶点编辑器，支持选择顶点、拖拽顶点、`+` 添加顶点、`-` 删除顶点、Fix X/Y 和整数吸附。
- `Density`、`Friction`、`Restitution`、`LinearDamping`、`AngularDamping`、Joint 数值字段：用 ruler 数值编辑；关闭当前编辑项时重建 item。
- `FixedRotation`、`Bullet`、`Sensor`、`Collision`：True/False 开关，变更后重建 item。
- `BodyA`/`BodyB`：进入 Body chooser，画布上显示可选 Body 十字，点击 body 后写入引用并重建 Joint。
- `JointA`/`JointB`：进入 Joint chooser，右侧列表临时变成 joint 选择模式；Gear 只允许选择 Revolute 或 Prismatic。
- `WorldPos`、`GroundA`、`GroundB`、`AnchorA`、`AnchorB`、`Offset`：点控制器；Anchor/Offset 可绑定到对应 Body local space。
- `Axis`：复用旋转控件，把旋转角换算成单位向量。
- `Face`：打开 Sprite/Model/Empty 资源选择器；旧版会列出 png、clip 内的 clip name、model。Web IDE 版按本文 Face 资源方案处理。
- `G`：旧版全局重力快捷项，写入 `CCUserDefault.G` 和 world gravity。新版不再作为持久字段，只保留可选的批量设置便利功能。

### Joint 创建流程

- 左侧 Joint 按钮打开 `oJointChooser.lua`，展示 10 种 Joint：Distance、Friction、Gear、Spring、Prismatic、Pulley、Revolute、Rope、Weld、Wheel。
- 选择类型后调用 `oEditor:new<Type>()` 创建默认数据，再 `addData()`、选择新 Joint、标记 dirty。
- Joint 创建后通常还需要在属性面板里选择 BodyA/BodyB 或 JointA/JointB，并编辑 anchor/worldPos/axis 等字段。
- 删除 Body 后，旧版依赖 `Body.editor.rename/reset` 监听更新或重建相关 Joint。Web IDE 版应显式维护依赖图，删除被引用对象时给出确认或诊断。

### 播放和测试

- Play 按钮发出 `Body.editor.isPlaying(isPlaying)`。
- 播放时 `worldScheduler.timeScale = 1`，属性面板禁用，编辑控件隐藏。
- 暂停时 `timeScale = 0` 并调用 `resetItems()`，回到编辑数据的初始状态。
- 播放时旧版会为 motor joint 生成临时按钮，用于启用/禁用 motor。Web IDE 版也应在动态预览首版实现这个能力：播放态扫描可启用/禁用的 motor joint，生成临时控制按钮，暂停或 reset 时移除。

### 显示和隐藏编辑器

- `Body.hideEditor` 会把左侧菜单、右侧列表和属性面板滑出/滑入，用于嵌入其他编辑器时临时隐藏 BodyEditor UI。
- Web IDE tab 不需要复刻滑出动画，但需要保留同等状态：切换 tab、只读模式、播放模式时禁用或隐藏对应交互控件。

## Web IDE 架构

### 模块划分

建议新增 `Tools/dora-dora/src/BodyEditor/`：

- `BodyDocument.ts`：编辑期数据结构、默认值、字段定义、类型守卫。
- `BodyLuaJsonFormat.ts`：新版 `.b.lua` JSON-like Lua 数据和 `BodyDocument` 的转换、序列化。
- `BodyEditorState.ts`：clone、rename、add/remove/reorder、selection、undo/redo 相关纯函数。
- `BodyPhysicsRuntime.ts`：Box2D Web world 构建、step、reset、hit test 辅助。
- `BodyRender.ts`：Canvas/ImGui 绘制需要的 shape/joint 几何、坐标转换、拾取。
- `BodyEditor.tsx`：React 宿主，负责 Service 读写、sourceContent 同步、错误上报。
- `BodyEditorCanvas.tsx`：Canvas/ImGui UI、工具栏、属性面板、视图和交互。
- `BodyResource.ts`：Face 图片/model 资源路径解析、WebServer served URL 转换。
- `index.ts`：对外导出。

复用现有 ActionEditor 的原则：

- 复用 `ActionImGuiRuntime` 或抽成更通用的 `ImGuiRuntime`，避免 BodyEditor 重新初始化 imgui-ts。
- 复用 Web IDE tab 接入模式：文件名命中 `.b.lua` 时渲染专用编辑器，同时保留 source content 的 onChange 写回路径。
- 复用自写入防抖/回避逻辑，避免保存后触发的外部 sourceContent 更新把本地状态重置。
- 复用 `UpdateFile` 刷新已打开预览的思路，Face 资源变化时重新加载纹理或模型缩略。

### 数据流

推荐数据流：

1. `Editor.tsx` 识别 `.b.lua`，传入 `filePath`、`resourceBasePath`、`sourceContent`、`onChange`。
2. `BodyEditor.tsx` 调用 WebServer/Service 的专用转换接口，请引擎侧执行受控的 `json.encode(loadstring("_ENV = {}\n" .. code)(), false, true)`，返回 JSON 数据数组，其中 `empty_as_array=true` 保证空 Lua 表按 JSON 数组返回。
3. 前端把 JSON 数组映射为 `BodyDocument`；失败时显示诊断，并提供只读 source fallback 或恢复为空文档的显式操作。
4. UI 修改只操作 `BodyDocument`，同时 push undo stack。
5. 每次文档变化把 `BodyDocument` 序列化成 JSON-like `.b.lua` 内容，通过 `onChange()` 交给 Web IDE 既有保存链路。
6. Box2D runtime 从 `BodyDocument` 派生，不把 runtime object 写回 document。

这样可以避免旧实现中 `data.create()`、`item.dataItem`、`oEditor.items[name]` 互相引用导致的重建同步风险。

## 数据模型

### 编辑期模型

建议内部模型使用稳定 id：

```ts
export type BodyDocument = {
	version: 1;
	source: "body";
	bodyLuaPath?: string;
	items: BodyItem[];
};

export type BodyItem = BodyShape | BodyJoint;

export type BodyShape = {
	id: string;
	kind: "Rect" | "Disk" | "Poly" | "Chain";
	name: string;
	bodyType: "Dynamic" | "Static" | "Kinematic";
	position: BodyVec2;
	angle: number;
	fixtures: BodyFixture[];
	linearDamping: number;
	angularDamping: number;
	fixedRotation: boolean;
	linearAcceleration: BodyVec2;
	bullet: boolean;
	face: string;
	facePosition: BodyVec2;
};

export type BodyFixture =
	| BodyRectFixture
	| BodyDiskFixture
	| BodyPolyFixture
	| BodyChainFixture;

export type BodyJoint = {
	id: string;
	kind: "Distance" | "Friction" | "Gear" | "Spring" | "Prismatic" | "Pulley" | "Revolute" | "Rope" | "Weld" | "Wheel";
	name: string;
	collision: boolean;
	// kind-specific fields follow
};
```

Body 主形状和 SubShape 可以统一为 `fixtures`，但序列化时必须恢复新版 `BodyEx` 格式：主 shape 字段写在 `Phyx.Rect/Disk/Poly/Chain` item 上，额外 fixture 写入 `subShapes` 数组。UI 层仍要能把主 shape 和 SubShape 分开展示，因为旧编辑器允许选中和删除子形状。第一版设计应尽可能完整保留 SubShape 的新增、删除、选择和属性编辑能力。

新版 `BodyEx` 没有独立 `Loop`/`SubLoop` struct，只有 `Phyx.Chain`/`Phyx.SubChain`。Web IDE 不再提供 Loop 工具，旧版截图中的闭合 loop 图标不进入新版工具栏；只保留 Chain，并按 `Phyx.Chain`/`Phyx.SubChain` 保存。

### 名称和引用

旧资源中 Joint 使用名字引用 Body/Joint。新版内部应同时维护 id 和 name：

- UI selection 使用 id。
- Joint 编辑面板选择 Body/Joint 时优先存 id。
- 保存时写出 name。
- 读取旧文件时为每个 item 分配 id，再把 joint 的 name 引用解析成 id。
- 重命名 Body/Joint 时更新所有依赖项；若引用丢失，保留原始 name 并显示诊断。

Gear 的依赖是 JointA/JointB，不是 BodyA/BodyB。排序也要保留旧规则：Body 在前，普通 Joint 在 Body 后，Gear 在其他 Joint 后，确保加载时依赖项已存在。

### `.b.lua` 加载和序列化

新版 `.b.lua` 示例形态：

```lua
return {"Array",{"Phyx.Rect","rect","Static",{0,-540},0,{0,0},{2970,10},1,0.4,0.4,0,0,false,{0,-10},false,false,0,false,"",{0,0}}}
```

新版 BodyEditor 产出的文件应尽量保持 JSON-like：

- `return { ... }`
- 数字、字符串、布尔字面量 `true/false`
- 向量和尺寸都用二元数组，例如 `{x,y}`、`{width,height}`
- 嵌套数组，主要用于 root `Array`、vertices 和 subShapes

Web IDE 不再手写 Lua tokenizer/parser。加载时由 WebServer 提供一个受控转换接口，在引擎侧执行 `json.encode(loadstring("_ENV = {}\n" .. code)(), false, true)`，把 `.b.lua` 转成 JSON 字符串返回给前端。第三个参数 `empty_as_array=true` 用于兜底把手写或旧中间版本里的空 Lua 表 `{}` 转成 JSON 数组 `[]`，避免 `subShapes` 这类空数组字段被编码成对象。转换接口只用于 `.b.lua`，并且必须校验根结构是 `{"Array", ...}`。前端只需要处理 JSON 数组到 `BodyDocument` 的映射。保存时从 `BodyDocument` 直接生成 JSON-like Lua table 字符串，并保持 `BodyEx.yue` 中 `Struct.Phyx.*` 的字段顺序和数值精度策略；`subShapes` 为空时保存为 `false`，表示没有额外 fixture，同时保留父数组字段位置，避免 Lua 数组 hole 和额外空数组对象。

这个方案要求 `BodyEx` 加载逻辑同步适配普通数组：

- 不再依赖 `Struct.load()` 递归处理完整数据，因为 `{0,0}` 这类二元数组不是 struct。
- `BodyEx` 内部需要在读取字段时把 `{x,y}` 转为 `Vec2(x,y)`，把 `{width,height}` 转为 `Size(width,height)` 或直接解构为 width/height。
- vertices 需要从 `{{x,y},{x,y}}` 转为 `Vec2` 数组后再传给 `BodyDef:attachPolygon`、`attachChain` 等 API。
- `subShapes` 仍按 `{"Phyx.SubRect", ...}` 这样的 struct-like item 递归加载。
- 不建议修改全局 `Struct.load()` 的语义，以免影响其他资源；数组 normalize 应放在 `BodyEx` 专用加载路径中。

保存策略：

- 坐标和尺寸默认保留最多两位小数，整数不带 `.00`，对齐旧 `dumpData()` 的输出习惯。
- 字符串做 Lua 转义。
- 未知或暂不支持字段不得丢失；第一阶段如果遇到不支持结构，应阻止保存并显示诊断。
- 读取后如果只是格式化差异，不应自动改写文件；只有用户编辑后才写回。

### 新版 `.b.lua` 格式

Web IDE 只按新版 `BodyEx` 标准格式读写：

- 文件后缀固定为 `.b.lua`，因为资源本质是 Lua 文件。
- 文件不需要 helper require，直接 `return` JSON-like Lua table。
- 根结构必须是 `{"Array", item1, item2, ...}`，由 `BodyEx` 专用加载逻辑识别。
- 类型编码使用字符串 struct name，例如 `"Phyx.Rect"`、`"Phyx.Disk"`、`"Phyx.Poly"`、`"Phyx.Chain"`。
- Body 类型保存 `"Static"`、`"Dynamic"`、`"Kinematic"` 字符串，`BodyEx.toDef()` 直接写入 `BodyDef.type`。
- 向量/尺寸统一保存为二元数组 `{x,y}`/`{w,h}`，便于引擎侧用空 `_ENV` 受控执行后 `json.encode(data, false, true)` 给 Web IDE 使用；`subShapes` 空值保存为 `false`，非空时保存为普通 struct-like 子数组。
- 重力相关不再提供全局 `G` 或每个 body 的 `GravityScale` 字段；新版直接编辑并保存每个 body 的 `linearAcceleration`，新建 body 默认 `{0,-10}`。这个值使用 Dora 运行时的真实重力加速度单位。
- Shape API：新版 `BodyEx` 使用 `attachDisk/attachDiskSensor` 表示圆形，使用 `attachChain` 表示链；没有单独 `attachLoop` 加载分支。
- Face 加载：新版 `BodyEx` 中 face 字符串包含 `:` 时使用 `Playable(faceStr)`，否则使用 `Sprite(faceStr)`。

字段顺序必须以 `Assets/Script/Lib/BodyEx.yue` 中的 `Struct.Phyx.*(...)` 为准。当前主要 struct 字段如下：

- `Phyx.Rect(name,type,position,angle,center,size,density,friction,restitution,linearDamping,angularDamping,fixedRotation,linearAcceleration,bullet,sensor,sensorTag,subShapes,face,facePos)`
- `Phyx.Disk(name,type,position,angle,center,radius,density,friction,restitution,linearDamping,angularDamping,fixedRotation,linearAcceleration,bullet,sensor,sensorTag,subShapes,face,facePos)`
- `Phyx.Poly(name,type,position,angle,vertices,density,friction,restitution,linearDamping,angularDamping,fixedRotation,linearAcceleration,bullet,sensor,sensorTag,subShapes,face,facePos)`
- `Phyx.Chain(name,type,position,angle,vertices,friction,restitution,linearDamping,angularDamping,fixedRotation,linearAcceleration,bullet,subShapes,face,facePos)`
- `Phyx.SubRect(center,angle,size,density,friction,restitution,sensor,sensorTag)`
- `Phyx.SubDisk(center,radius,density,friction,restitution,sensor,sensorTag)`
- `Phyx.SubPoly(vertices,density,friction,restitution,sensor,sensorTag)`
- `Phyx.SubChain(vertices,friction,restitution)`

Joint struct 字段也以 `BodyEx` 为准，命名从旧 UI 的简写字段变为更完整的字段名：`linearOffset`、`lowerTranslation`、`upperTranslation`、`groundAnchorA`、`groundAnchorB` 等。编辑器 UI 可以继续显示旧名称附近的短标签，但保存层不能写回旧字段名或旧数组位置。

## Box2D Web 预览方案

### 依赖选择

Web IDE 上的物理预览建议优先使用 Planck.js。它是 JavaScript/TypeScript 侧实现的 Box2D 风格库，避免第一版被 WASM 异步加载和打包问题拖住，同时覆盖当前 BodyEditor 需要的大部分 body、fixture 和 joint 预览。最终接入前仍要验证：

- Vite/当前前端构建链路是否能稳定打包 Planck.js。
- 坐标系、角度单位和 fixture API 是否覆盖旧 Dora BodyEditor 的 shape/joint。
- 能否稳定创建、销毁和重建 world，避免热更新或切 tab 后泄漏。
- license 与项目发布方式兼容。

如果未来改用 WASM Box2D 绑定，`BodyEditor.tsx` 应显示明确 loading/failed 状态；不能让空白 Canvas 当作成功加载。

### 预览职责边界

Box2D 只负责浏览器内预览和简单测试：

- 构建 world。
- 创建 bodies、fixtures、joints。
- step/pause/reset。
- 提供 debug draw 所需的 runtime transform。
- 提供点击拾取或 query 辅助。

Box2D 不负责资源保存格式，不成为 `.b.lua` 的语义来源。Dora 运行时仍以保存出的 `.b.lua` Lua 数据和 `Assets/Script/Lib/BodyEx.yue`/`BodyEx.lua` loader 为准。

### 坐标、单位和显示

旧编辑器直接使用 Dora 世界坐标作为像素级编辑单位，截图中标尺也是这个单位。Box2D 通常需要 meter scale。建议：

- `BodyDocument` 使用 Dora 单位。
- `BodyPhysicsRuntime` 内部配置 `pixelsPerMeter = 100`，即物理世界 `1 meter` 对应显示层 `100 pixel`。
- 写入 Planck/Box2D 时 `meters = doraUnits / 100`。
- 从 Planck/Box2D 读取 transform 时 `doraUnits = meters * 100`，再把 sprite、clip face、占位图标和 debug draw 挂到显示坐标上。
- 角度编辑沿用旧 UI 的 degree，写入 Box2D 时转换成 radians。

Chain/Polygon 的顶点方向和凸性需要在构建前验证。Box2D 对 polygon fixture 有凸多边形限制；旧 Dora 运行时是否允许更宽松输入要单独确认。Web 预览不能因为 Box2D 限制而偷偷改写用户数据，只能显示诊断。

### 加速度预览

Web IDE 预览不使用 Box2D/Planck 的全局重力表达新版 body 数据：

- 创建 world 时 gravity 固定为 `{0,0}`。
- 每个 dynamic body 保留 `.b.lua` 中的 `linearAcceleration`。
- 每个 fixed timestep 开始前，对 body 施加 `force = mass * linearAcceleration`，再执行 world step；实际实现需要按 `1 meter = 100 pixel` 把 Dora 加速度单位转换为 Planck/Box2D 内部单位。
- Static body 不施加力；Kinematic body 是否使用 `linearAcceleration` 由 Dora 运行时语义确认，第一版可显示诊断并跳过。

这样预览层可以支持任意方向的 per-body acceleration，不需要把 x 分量拆成额外逻辑，也不需要在 Web IDE UI 中保留旧 `G`/`GravityScale`。保存出的 `.b.lua` 始终以 `linearAcceleration` 为准。

### Joint 映射

基础映射：

- `Distance` -> distance joint，anchorA/anchorB、frequency/damping。
- `Friction` -> friction joint，world position、max force/torque。
- `Prismatic` -> prismatic joint，world position、axis、lower/upper、motor force/speed。
- `Pulley` -> pulley joint，anchors、ground anchors、ratio。
- `Revolute` -> revolute joint，world position、angle limits、motor torque/speed。
- `Rope` -> rope joint 或 fallback debug constraint，取决于所选 Box2D 绑定是否支持 rope joint。
- `Weld` -> weld joint，world position、frequency/damping。
- `Wheel` -> wheel joint，world position、axis、motor、spring frequency/damping；`motorSpeed` 按引擎规则使用度/秒，预览时转换为底层角速度。
- `Gear` -> gear joint，依赖两个已创建 joint。
- `Spring` -> 接受近似预览，可用 Planck 的 `MotorJoint` 或 spring-like 约束模拟，界面标记“预览近似”，保存数据仍保持 `BodyEx` 原字段。

对于 Box2D 不支持或语义不完全一致的 Joint，设计上要区分：

- 保存语义：仍完整保存 `BodyEx` 支持的新版字段，预览层不能因为 Box2D 限制改写 `.b.lua` 数据。
- 静态绘制：仍画出 joint 连接和锚点。
- 动态预览：显示 warning，必要时跳过 runtime joint。

## UI 和交互设计

### 布局

推荐布局：

- 顶部工具条：保存状态、Undo/Redo、播放/暂停、Reset Simulation、Origin、Zoom、Snap、Fix X/Y。
- 左侧工具条：Rectangle、Circle、Polygon、Chain、Joint、Delete。
- 中央 Canvas：世界网格、标尺、坐标轴、shape/joint debug draw、face 贴图、选中框、顶点/点位控制器。
- 右上对象列表：Body、SubShape、Joint 顺序列表，支持选择、重命名、删除和依赖状态提示。
- 右下属性面板：按选中类型展示字段。
- 弹窗：新建/打开、Joint 类型选择、Body/Joint chooser、Face 资源选择。

视觉上可以继承 ActionEditor 的 ImGui Dora theme，不必复刻旧截图中的像素字体和青/粉线框，但交互密度和编辑器属性面板要保持工具属性，而不是做成营销式页面。旧版 BodyEditor 已经形成了一套很直观的小图标语言，新版应从旧 Lua 绘制逻辑和截图中提炼矢量图标设计作为识别线索：矩形、圆形、三角/多边形、折线 chain、delete、joint 两端锚点连线、播放按钮，以及列表中各类 shape/joint 的缩略图标。实现上可以用 Canvas/ImGui 代码重绘这些简化线框图标，颜色和线宽可适配新版 theme，但轮廓语义应保持一致。

### 图标规范

图标不直接复用旧截图位图，避免分辨率和版权/清晰度问题；应把旧 Lua UI 中的 shape/joint glyph 作为矢量设计参考，在 Web IDE 中用统一函数绘制：

- Shape 工具和列表图标：Rect 用空心矩形，Disk 用空心圆，Poly 用三角形或当前多边形轮廓，Chain 用开口折线。新版不提供 Loop 工具和 Loop 图标。
- SubShape 图标沿用对应 shape 图标，但可以用更小尺寸、虚线或角标区分它挂在 Body 下。
- Joint 图标统一表达“两个锚点 + 连线”，再用细节区分类型：Distance/Rope 用直线，Revolute/Wheel 加圆形轴心，Prismatic 加滑轨方向，Pulley 加两个 ground anchor，Gear 加双 joint/齿轮提示，Friction/Spring/Weld 用旧版 chooser 中接近的简化符号。
- 播放、Origin、Zoom、Fix X/Y、Delete 等工具按钮保留旧版视觉语义，按钮外观服从新版 ImGui theme。
- 所有图标都要同时用于左侧工具条、右侧对象列表和 chooser 弹窗，避免同一对象类型在不同面板使用不同符号。

### 创建和选择

创建流程：

1. 点击左侧 shape 工具进入创建模式。
2. 在画布点击生成 Body；如果当前选中的是可挂子形状的 Body，则创建 SubShape。
3. Polygon/Chain 支持连续点选顶点，Enter/双击完成，Esc 取消。
4. 创建后自动选中新 item，右侧属性面板进入对应状态，文档 dirty。

选择流程：

- 点击 shape body 或 fixture 选中 item。
- 点击 joint line/anchor 选中 joint。
- 列表选择和画布选择使用同一 `selectedItemId`。
- 重建 Box2D world 后通过 id 恢复选择，不保存 runtime object 引用。

### 编辑控制器

旧 `oEditControl.lua` 提供多种编辑器：位置箭头、点控制、顶点控制、数值 ruler、类型选择、布尔开关、Body/Joint chooser。新版可以用 ImGui 表单加 Canvas gizmo 实现：

- Position/Center/WorldPos/Anchor/Ground/Offset/FacePos：Canvas 点位拖拽 + 数值输入。
- Axis：单位向量控制器，支持拖拽方向和数值输入。
- Size/Radius/Angle/Length/Motor 参数：属性面板数值输入，必要时配 slider。
- Vertices：Canvas 顶点控制器，支持新增、删除、拖拽、闭合提示。
- Type：Dynamic/Static/Kinematic combo。
- Boolean：checkbox。
- BodyA/BodyB/JointA/JointB：对象 chooser，过滤非法目标。

Fix X/Y 和 snap 应作为编辑辅助状态，不写入 `.b.lua`。

### 属性面板

字段集合以旧 `oSettingPanel.lua` 为基础，但按新版 `.b.lua` 数据模型调整：

- Rect/Disk/Poly：Name、Type、几何、Angle、Position、Density、Friction、Restitution、LinearDamping、AngularDamping、FixedRotation、LinearAcceleration、Bullet、Sensor、SensorTag、Face、FacePos。
- Chain 工具：Name、Type、Position、Angle、Vertices、Friction、Restitution、LinearDamping、AngularDamping、FixedRotation、LinearAcceleration、Bullet、Face、FacePos；保存层写成 `Phyx.Chain`。
- SubRect/SubDisk/SubPoly：几何、Density、Friction、Restitution、Sensor、SensorTag。
- SubChain 工具：Vertices、Friction、Restitution；保存层写成 `Phyx.SubChain`。
- Distance/Friction/Gear/Spring/Prismatic/Pulley/Revolute/Rope/Weld/Wheel：保留旧 panel 对应字段。

新版 Web IDE 完全不提供旧 `G`/`GravityScale` 字段。打开和保存都以 `linearAcceleration` 为唯一加速度来源，不再做旧字段推导或反推。

### 播放和测试

播放模式：

- 编辑模式：world 暂停，只显示 document 几何和当前 Box2D 初始状态。
- 播放模式：从 document 重建 world，按固定 timestep step，禁用会改变 document 的编辑控件。
- Reset Simulation：回到 document 初始状态。
- 单步：可选，用于调试 joint。

播放时产生的 body transform 不能写回 document，除非未来明确增加“烘焙模拟结果”功能。

## 文件接入

### Web IDE 打开规则

- `.b.lua` 在 tab 中默认打开 BodyEditor。
- 提供“Open as Text”或错误 fallback，方便诊断 `.b.lua` 解析失败。
- 新建文件对话框可以增加 `.b.lua` 类型；初始内容为新版 `return {"Array"}` 空数组。
- 资源树可为 `.b.lua` 增加预览/编辑图标，但不应影响普通文本编辑路径。

### Face 资源

旧 BodyEditor 的 `Face` 可以引用图片、model/playable 或 clip-string。新版 `BodyEx` 的运行时分支保持现有规则：包含 `:` 的 face 用 `Playable(faceStr)`，否则用 `Sprite(faceStr)`。不含 `:` 的字符串可直接交给 `Sprite(faceStr)` 创建精灵，支持普通图片路径，也支持 `xxx.clip|clipName` 这样的 clip 引用。Web IDE 前端只做图片和 `.clip` 图集裁剪预览，不做 playable/model 的真实运行时预览。

编辑器内部不要只把 `face` 当成裸字符串到处传。建议解析成结构化引用：

```ts
type BodyFaceRef =
	| { type: "none" }
	| { type: "image"; path: string }
	| { type: "clip"; clipPath: string; clipName: string; texturePath?: string }
	| { type: "playable"; path: string };
```

保存时再落回 `BodyEx` 的 `face` 字符串：

- image：保存为相对 `.b.lua` 所在目录的 `.png/.jpg/.jpeg` 路径。
- clip：保存为 `xxx.clip|clipName`，保持不含 `:`，运行时走 `Sprite(faceStr)`。
- playable/model：原样保存为引擎可识别的 playable 字符串，但 Web IDE 前端只绘制占位图标和资源名，不尝试实例化、播放或复用 ActionEditor 的 model 渲染能力。

资源选择和路径规则：

- 以 `.b.lua` 所在目录作为默认相对目录，保存时优先写相对路径，不写绝对路径。
- 资源选择器展示同目录和子目录内的 `.png/.jpg/.jpeg/.clip/.model` 等候选资源。
- `Face` 属性不应只是文本框，应提供资源选择、清空按钮和 `facePos` 的二维数值/画布拖拽编辑。
- 选择 `.clip` 时要展开 clip names，让用户选具体 clip，而不是只选 `.clip` 文件。

Web 预览加载：

- 图片资源直接用 `toServedResourceUrl(filePath, resourceBasePath)` 转成 Web URL 后加载并绘制。
- `.clip` 复用 ActionEditor 的 `parseLegacyClip()` 解析 XML，按 sibling path 找 atlas 图片，再按 clip rect 裁剪绘制。
- playable/model 始终显示占位图标、边框和资源名；加载失败也显示占位和 diagnostics，不阻止编辑保存。

Face 与物理形状的关系：

- `face` 只是挂在刚体上的视觉子节点，不改变 fixture、joint 或碰撞形状。
- `facePos` 使用 body local space；编辑暂停时跟随文档里的 body `position/angle`，Box2D 播放时跟随 runtime body transform。
- fixture 的 `center/vertices/size/radius` 只影响物理 debug draw 和 Box2D shape，不反向影响 face 尺寸。

资源刷新：

- 复用 ActionEditor 已有的资源 URL 和 `.clip` 解析逻辑。
- 当 `.png/.jpg/.jpeg/.clip` 被外部更新时，已打开的 BodyEditor 应刷新 face resource cache；第一版可以粗粒度刷新所有打开的 `.b.lua` tab，后续再做反向依赖索引。

Face 加载失败不阻止编辑和保存，但要在 diagnostics panel 中显示。

## 实施阶段

### 阶段 1：只读解析和静态预览

- 接入 `.b.lua` tab。
- 实现 WebServer/Service 的 `.b.lua` 到 JSON 转换接口，内部使用受控 `json.encode(loadstring("_ENV = {}\n" .. code)(), false, true)`，并校验根结构为 `{"Array", ...}`。
- 实现 `BodyLuaJsonFormat.ts`，负责 JSON 数组和 `BodyDocument` 之间的映射，以及 JSON-like Lua table 序列化。
- 同步调整 `BodyEx`，让运行时 loader 能把普通二元数组 normalize 为 `Vec2`/`Size`。
- 建立 `BodyDocument` 和诊断系统。
- Canvas 绘制 Body/SubShape/Joint 静态几何、坐标轴、标尺、pan/zoom。
- 补充新版 `.b.lua` fixture 做只读打开验证。

验收：新版 `.b.lua` 资源能打开，列表和画布结构与文档数据一致，解析失败有明确错误。

### 阶段 2：编辑和保存

- 实现 add/remove/rename/reorder、属性编辑、顶点编辑、undo/redo。
- 第一版尽可能完整支持 SubShape 的新增、删除、选择和属性编辑，覆盖旧版 BodyEditor 的组合刚体工作流。
- 实现 serializer，保存回新版 `.b.lua` JSON-like Lua table 格式。
- 确保 rename 更新 Joint 引用，删除 Body/Joint 时给出依赖确认。
- 实现复用旧版 BodyEditor 视觉语义的 shape/joint/tool 图标，并接入工具条、对象列表和 chooser。
- 新建 `.b.lua` 文件和 dirty 状态接入 Web IDE。

验收：打开 `.b.lua`、修改、保存、重新打开后数据一致；未编辑文件不被无意义重写；工具条、对象列表和 chooser 中的 shape/joint 图标语义一致，能对应旧版编辑器中的小图标设计。

### 阶段 3：Box2D 动态预览

- 引入 Box2D Web 依赖并封装异步 runtime。
- 从 `BodyDocument` 构建 world。
- 实现 play/pause/reset/fixed timestep。
- 映射主流 shape 和 joint，unsupported joint 显示 warning。
- 播放时禁用会修改 document 的编辑控件。
- 播放态为可启用/禁用的 motor joint 生成临时按钮，允许测试时切换 motor enabled 状态；暂停或 reset 后清理临时按钮。

验收：示例文件能播放，常见 joint 有可见效果；motor joint 临时按钮可切换 enabled 状态；不支持项不丢数据。

### 阶段 4：Face、资源体验和质量补齐

- png/clip face 资源加载；playable/model 只显示占位图标，不做真实预览。
- Face 资源变化时刷新已打开 tab。
- 对象 chooser、资源 chooser、错误定位、快捷键、复制粘贴。
- 移动端/窄屏最低可用布局。
- 补充 parser/serializer 单元测试和关键交互截图验证。

## 风险和决策点

- Box2D 与 Dora 物理语义不是完全等价，尤其是 Spring/Rope/Gear 和 polygon 限制。必须把“保存语义”和“预览近似”分开。
- `.b.lua` 是 Lua 代码形态。Web IDE 不在浏览器执行它，只通过引擎侧受控接口转换为 JSON；转换接口必须限制用途、返回明确错误，并避免把任意执行能力暴露成通用前端 API。
- 新版 Struct 格式仍靠数组位置表达，字段顺序是兼容性核心。字段模型、parser、serializer 必须集中在一个定义表里，避免多处手写索引。
- `BodyEx` 不能继续无条件 `Struct.load()` 整棵数据，否则 `{0,0}` 会被当成 struct 递归处理而失败；需要专用 normalize 路径。
- Joint 依赖顺序影响运行时加载。新增、删除、重排时要保证 Body -> Joint -> Gear 的保存顺序。
- ActionEditor 已使用 Canvas/ImGui 方式，BodyEditor 应复用这条路线；如果改成 DOM 表单，会造成编辑体验和输入焦点管理分裂。

## 推荐第一批文件

第一批实现建议控制在这些文件：

- `Tools/dora-dora/src/BodyEditor/BodyDocument.ts`
- `Tools/dora-dora/src/BodyEditor/BodyLuaJsonFormat.ts`
- `Tools/dora-dora/src/BodyEditor/BodyEditorState.ts`
- `Tools/dora-dora/src/BodyEditor/BodyRender.ts`
- `Tools/dora-dora/src/BodyEditor/BodyEditor.tsx`
- `Tools/dora-dora/src/BodyEditor/BodyEditorCanvas.tsx`
- `Tools/dora-dora/src/BodyEditor/index.ts`
- `Tools/dora-dora/src/Service.ts`
- `Tools/dora-dora/src/Editor.tsx`
- `Tools/dora-dora/src/App.tsx`
- `Tools/dora-dora/src/i18n.ts`
- `Assets/Script/Dev/WebServer.yue`
- `Assets/Script/Lib/BodyEx.yue`
- `Assets/Script/Lib/BodyEx.lua`

Box2D runtime 可以在阶段 3 再加入，避免 parser/editor 基础还不稳定时被 WASM 打包和物理语义问题拖住。

## `/goal` 开发任务拆解

下面的任务表用于让 Codex 通过 `/goal` 模式逐轮接任务。每轮建议只领取一个任务，完成后更新状态、实际改动文件、验证结果和遗留问题。状态取值：

- `TODO`：未开始。
- `DOING`：当前轮正在做。
- `DONE`：已完成并通过验收。
- `BLOCKED`：被外部决策、依赖或运行环境阻塞。
- `DEFERRED`：确认延后，不影响当前阶段继续。

### 进度跟踪表

| ID | 状态 | 任务 | 主要文件 | 验收标准 | 验证方式 |
| --- | --- | --- | --- | --- | --- |
| BE-00 | DONE | 准备新版 `.b.lua` 示例 fixture 和字段定义清单 | `Docs/body-editor-web-ide-rebuild.md`, `Tools/dora-dora/src/BodyEditor/BodyDocument.ts` | 覆盖 Rect/Disk/Poly/Chain、SubShape、10 类 Joint、face、linearAcceleration；字段顺序和 `BodyEx.yue` 一致 | `pnpm lint`；人工对照 `Assets/Script/Lib/BodyEx.yue` |
| BE-01 | DONE | 调整 `BodyEx` 加载普通二元数组 | `Assets/Script/Lib/BodyEx.yue`, `Assets/Script/Lib/BodyEx.lua` | `.b.lua` 中 `{x,y}`/`{w,h}` 能 normalize 为运行时 `Vec2`/`Size`；`subShapes` struct-like 数组仍能加载 | 用引擎加载最小 `.b.lua` fixture；必要时补 Lua 侧 smoke 测试 |
| BE-02 | DONE | 增加 WebServer/Service `.b.lua` 到 JSON 转换接口 | `Assets/Script/Dev/WebServer.yue`, `Tools/dora-dora/src/Service.ts` | 接口执行 `json.encode(loadstring("_ENV = {}\n" .. code)(), false, true)`；只接受 `.b.lua` 用途；校验根结构 `{"Array", ...}`；错误返回可展示诊断；空 Lua 表按 JSON 数组返回 | 构造合法/非法 `.b.lua` 请求；`pnpm lint` |
| BE-03 | DONE | 接入 `.b.lua` tab 和空编辑器宿主 | `Tools/dora-dora/src/Editor.tsx`, `Tools/dora-dora/src/App.tsx`, `Tools/dora-dora/src/BodyEditor/BodyEditor.tsx`, `Tools/dora-dora/src/BodyEditor/index.ts` | 打开 `.b.lua` 默认进入 BodyEditor；支持 Open as Text fallback；未影响普通 `.lua` 打开逻辑 | Web IDE 手动打开 `.b.lua`；`pnpm lint` |
| BE-04 | DONE | 实现 `BodyDocument` 和新版格式 parser/serializer | `Tools/dora-dora/src/BodyEditor/BodyDocument.ts`, `Tools/dora-dora/src/BodyEditor/BodyLuaJsonFormat.ts` | JSON 数组可映射到内部模型；保存可输出 JSON-like Lua table；未知结构阻止保存并显示诊断；未编辑不重写 | 单元测试或最小 fixture round-trip；`pnpm lint` |
| BE-05 | DONE | 实现只读静态 Canvas/ImGui 预览 | `Tools/dora-dora/src/BodyEditor/BodyEditorCanvas.tsx`, `Tools/dora-dora/src/BodyEditor/BodyRender.ts` | 可绘制 Body/SubShape/Joint、坐标轴、标尺；pan/zoom 正常；列表选择能定位画布对象 | Web IDE 视觉检查；必要时截图比对 |
| BE-06 | DONE | 实现旧版语义的矢量图标系统 | `Tools/dora-dora/src/BodyEditor/BodyIcons.ts`, `Tools/dora-dora/src/BodyEditor/BodyEditorCanvas.tsx` | Rect/Disk/Poly/Chain/Joint/Delete/Play/Origin/Zoom/Fix X/Y 等图标从旧 Lua 和截图提炼；工具条、列表、chooser 复用同一套绘制函数 | Web IDE 视觉检查；图标在不同面板语义一致 |
| BE-07 | DONE | 实现选择、列表、增删和排序基础编辑 | `Tools/dora-dora/src/BodyEditor/BodyEditorState.ts`, `Tools/dora-dora/src/BodyEditor/BodyEditorCanvas.tsx` | Body 在 Joint 前、Gear 在其他 Joint 后；选择态用 id；删除依赖对象有确认或诊断；dirty 状态正确 | 手动编辑 fixture；保存前后检查顺序 |
| BE-08 | DONE | 实现属性面板和基础字段编辑 | `Tools/dora-dora/src/BodyEditor/BodyEditorCanvas.tsx`, `Tools/dora-dora/src/BodyEditor/BodyEditorState.ts` | Name/Type/Position/Angle/几何/材料/阻尼/fixedRotation/linearAcceleration/bullet/sensor/sensorTag 均可编辑；rename 更新 Joint 引用 | round-trip 保存重开；`pnpm lint` |
| BE-09 | DONE | 完整支持 SubShape 工作流 | `Tools/dora-dora/src/BodyEditor/BodyEditorState.ts`, `Tools/dora-dora/src/BodyEditor/BodyEditorCanvas.tsx`, `Tools/dora-dora/src/BodyEditor/BodyLuaJsonFormat.ts` | 可新增、选择、编辑、删除 SubRect/SubDisk/SubPoly/SubChain；序列化回 `subShapes`；组合刚体工作流可用 | 手动创建组合 body 后保存重开 |
| BE-10 | DONE | 实现顶点、点位、轴向 Canvas gizmo | `Tools/dora-dora/src/BodyEditor/BodyEditorCanvas.tsx`, `Tools/dora-dora/src/BodyEditor/BodyRender.ts` | Position/Center/FacePos/Anchor/Ground/Offset/Axis/Vertices 可拖拽编辑；支持 Fix X/Y 和 snap；不会写入辅助状态 | 手动交互验证；截图检查控件不遮挡 |
| BE-11 | DONE | 实现 Joint 创建和引用 chooser | `Tools/dora-dora/src/BodyEditor/BodyEditorState.ts`, `Tools/dora-dora/src/BodyEditor/BodyEditorCanvas.tsx` | 10 类 Joint 可创建；BodyA/BodyB、JointA/JointB chooser 有过滤；Gear 只允许 Revolute/Prismatic 依赖 | 创建每类 Joint 并保存重开 |
| BE-12 | DONE | 接入保存、undo/redo、新建 `.b.lua` 和 dirty 状态 | `Tools/dora-dora/src/BodyEditor/BodyEditor.tsx`, `Tools/dora-dora/src/App.tsx`, `Tools/dora-dora/src/i18n.ts` | 修改会 dirty；保存回 `.b.lua`；undo/redo 可恢复；新建初始内容为 `return {"Array"}` | Web IDE 手动保存重开；`pnpm lint` |
| BE-13 | DONE | Face 资源选择和预览 | `Tools/dora-dora/src/BodyEditor/BodyResource.ts`, `Tools/dora-dora/src/BodyEditor/BodyEditorCanvas.tsx` | 图片路径走 `Sprite`；`.clip` 保存 `xxx.clip|clipName`；playable/model 只显示占位；facePos 可编辑；加载失败只报诊断不阻止保存 | 用 png/clip/playable 占位 fixture 手动验证 |
| BE-14 | DONE | 资源更新刷新已打开 BodyEditor | `Tools/dora-dora/src/App.tsx`, `Tools/dora-dora/src/BodyEditor/BodyResource.ts` | 外部更新 `.png/.jpg/.jpeg/.clip` 后已打开 BodyEditor 刷新 face cache；不自动改写 `.b.lua` | 触发 `UpdateFile` 后观察预览刷新 |
| BE-15 | DONE | 引入 Planck.js 并封装物理 runtime | `Tools/dora-dora/package.json`, `Tools/dora-dora/src/BodyEditor/BodyPhysicsRuntime.ts` | world gravity `{0,0}`；`1 meter = 100 pixel`；能从 `BodyDocument` 构建 body/fixture；step/reset 无泄漏 | `pnpm install` 后 `pnpm lint`；Web IDE 播放 smoke test |
| BE-16 | DONE | 实现 `linearAcceleration` 施力和动态预览 | `Tools/dora-dora/src/BodyEditor/BodyPhysicsRuntime.ts`, `Tools/dora-dora/src/BodyEditor/BodyEditorCanvas.tsx` | 每个 dynamic body 在 step 前施加 `mass * linearAcceleration`；sprite/clip/debug draw 按 `meters * 100` 显示；播放不写回文档 | 播放含 `{0,-10}` 和横向 acceleration 的 fixture |
| BE-17 | DONE | 映射 Joint 动态预览和 motor 临时按钮 | `Tools/dora-dora/src/BodyEditor/BodyPhysicsRuntime.ts`, `Tools/dora-dora/src/BodyEditor/BodyEditorCanvas.tsx` | 常见 Joint 有动态效果；Spring 可近似预览并提示；motor joint 播放态生成临时按钮，暂停/reset 清理 | 创建含 motor 的 Joint fixture 手动验证 |
| BE-18 | DONE | 补齐诊断、快捷键、复制粘贴和窄屏最低体验 | `Tools/dora-dora/src/BodyEditor/*` | 解析/资源/预览不支持项有可定位诊断；常用快捷键可用；窄屏不出现明显遮挡 | 手动测试；截图检查 |
| BE-19 | DONE | 测试补齐和最终验收 | `Tools/dora-dora/src/BodyEditor/*.test.ts`, fixture 文件 | parser/serializer round-trip、字段顺序、错误输入、关键状态函数有覆盖；Web IDE 端完整手动验收记录更新到本文档 | `pnpm lint`；相关单元测试；手动验收记录 |

### 每轮 `/goal` 工作约定

每轮开发开始前：

1. 把对应任务状态改为 `DOING`。
2. 只修改该任务必要文件，除非发现阻塞性依赖。
3. 若任务需要改动 `BodyEx.yue`，同步确认是否需要更新生成后的 `BodyEx.lua`。

每轮开发结束前：

1. 在任务表中把状态改为 `DONE`、`BLOCKED` 或 `DEFERRED`。
2. 在下方“进度日志”追加一条记录，写明实际改动、验证结果和遗留问题。
3. 优先运行 `pnpm lint`；涉及运行时加载时补充最小 `.b.lua` fixture 手动验证；涉及 UI 时用 Web IDE 手动打开检查。

### 进度日志

| 日期 | 任务 | 状态变更 | 实际改动 | 验证 | 遗留问题 |
| --- | --- | --- | --- | --- | --- |
| 2026-05-15 | 文档准备 | TODO | 建立任务拆解和跟踪表 | 未运行代码验证 | 等待进入首轮 `/goal` 开发 |
| 2026-05-15 | BE-00 | TODO -> DOING -> DONE | 新增 `Tools/dora-dora/src/BodyEditor/BodyDocument.ts`，集中定义 Body/ SubShape/Joint 的 BodyEx 字段顺序、字段类型提示、基础文档类型和覆盖 Rect/Disk/Poly/Chain、4 类 SubShape、10 类 Joint、face、linearAcceleration 的新版 `.b.lua` fixture；未修改 `BodyEx.yue`/`BodyEx.lua` | `pnpm lint` 通过；脚本人工对照 `Assets/Script/Lib/BodyEx.yue`，18 个 `Struct.Phyx.*` 字段顺序全部一致 | 后续 BE-04 仍需实现 parser/serializer round-trip；BE-01 仍需让运行时 BodyEx normalize 普通二元数组 |
| 2026-05-15 | BE-01 | TODO -> DOING -> DONE | 更新 `Assets/Script/Lib/BodyEx.yue` 及生成后的 `BodyEx.lua`，在 BodyEx 专用加载路径中按 `Struct.Phyx.*` 字段表 normalize 新版 JSON-like Lua table；普通 `{x,y}` 转为 `Vec2`，`{w,h}` 直接解构，vertices 和 subShapes 同时支持普通数组与 `Array` 包装 | `yue -r -c Assets/Script/Lib/BodyEx.yue` 通过；Lua stub smoke 通过，覆盖 `{x,y}`、`{w,h}`、SubRect、SubChain 和 Distance joint；`pnpm lint` 通过 | BE-02 仍需提供 WebServer/Service `.b.lua` 到 JSON 转换接口；当前 smoke 使用本地 stub，不等同完整引擎场景验收 |
| 2026-05-15 | BE-02 | TODO -> DOING -> DONE | 新增 `Assets/Script/Dev/WebServer.yue` 的 `/body/parse` 专用接口并同步生成 `WebServer.lua`；新增 `Tools/dora-dora/src/Service.ts` 的 `parseBodyFile()` 类型化 Service 调用；接口只接受 `.b.lua`，用空 `_ENV` 执行 Lua table，校验根 `{\"Array\", ...}` 后返回 JSON 字符串 | `yue --path "Assets/Script/Lib/?.yue;Assets/Script/?.yue;Assets/Script/?/init.yue" -r -c Assets/Script/Dev/WebServer.yue` 通过；合法/非法 `.b.lua` 转换逻辑 smoke 通过；`pnpm lint` 通过 | 后续 BE-04 需要消费该接口并把 JSON 数组映射到 `BodyDocument`；当前未启动 WebServer 做真实 HTTP 请求 |
| 2026-05-15 | BE-03 | TODO -> DOING -> DONE | 新增 `BodyEditor.tsx` 空宿主和 `BodyEditor/index.ts`；`App.tsx` 对完整 `.b.lua` 文件名默认打开 BodyEditor，普通 `.lua` 保持 Monaco；新增 `bodyTextEditing` 状态并持久化到 editingInfo，BodyEditor 提供 Open as Text 切回 Lua 文本编辑 | `pnpm lint` 通过；代码检查确认 `.b.lua` 路由、Open as Text fallback 和普通 `.lua` 分支分离；Vite dev server 曾启动成功但浏览器插件缺少执行工具，未完成真实 UI 点击验收；完整 `pnpm build` 被中断且未继续 | BE-04 仍需接入 parser/serializer；BE-05 后才会有实际 Canvas/ImGui 预览内容 |
| 2026-05-15 | BE-04 | TODO -> DOING -> DONE | 扩展 `BodyDocument.ts` 为保留完整字段值的 `BodyStructDocument` 模型；新增 `BodyLuaJsonFormat.ts`，支持 `{\"Array\", ...}` JSON 数组映射、未知 struct/字段数诊断、保存门禁、最多两位小数的 JSON-like Lua table serializer；`BodyEditor/index.ts` 导出格式层 | `pnpm lint` 通过；`pnpm exec esbuild ... --outdir=/tmp/body-editor-format-test` 通过；Node round-trip smoke 通过，覆盖 Rect、SubRect、Distance、`linearAcceleration`、数值格式化和未知 struct 阻止保存 | 当前 `BodyEditor.tsx` 尚未消费 parser/serializer；BE-12 保存接入前仍不会写回 `.b.lua` |
| 2026-05-15 | BE-05 | TODO -> DOING -> DONE | 新增 `BodyRender.ts` 和 `BodyEditorCanvas.tsx`；`BodyEditor.tsx` 通过 `/body/parse` 加载文档并显示诊断；Canvas 绘制坐标网格、轴线、Body 主形状、SubShape、Joint 连线和右侧列表，支持拖拽平移、滚轮缩放、列表选择后定位 | `pnpm lint` 通过；`pnpm exec esbuild src/BodyEditor/BodyRender.ts src/BodyEditor/BodyEditorCanvas.tsx --bundle --platform=browser --format=esm --external:react --outdir=/tmp/body-editor-render-test` 通过 | 浏览器插件缺少执行工具，未完成真实 Web IDE 截图验收；预览仍为静态 debug draw，动态物理留到 BE-15 之后 |
| 2026-05-15 | BE-06 | TODO -> DOING -> DONE | 新增 `BodyIcons.ts`，集中绘制 Menu/Rect/Disk/Poly/Chain/Joint/Delete/Play/Origin/Zoom/Fix X/Fix Y 矢量图标；`BodyEditorCanvas.tsx` 接入左侧工具条并复用同一绘制函数，Origin/Zoom 已有基础视图动作 | `pnpm lint` 通过；`pnpm exec esbuild src/BodyEditor/BodyIcons.ts src/BodyEditor/BodyEditorCanvas.tsx --bundle --platform=browser --format=esm --external:react --outdir=/tmp/body-editor-icons-test` 通过 | 工具条创建/删除/播放动作仍待 BE-07/BE-11/BE-15 接入；未做真实截图验收 |
| 2026-05-15 | BE-07 | TODO -> DOING -> DONE | 新增 `BodyEditorState.ts`，实现 Body 创建、Body 在 Joint 前且 Gear 在普通 Joint 后的排序、按 id 选择、删除依赖诊断和 dirty 标记；`BodyEditorCanvas.tsx` 将 Rect/Disk/Poly/Chain/Delete 工具接入状态层；`BodyEditor.tsx` 编辑后序列化并触发 tab modified | `pnpm lint` 通过；`pnpm exec esbuild src/BodyEditor/BodyEditorState.ts --bundle --platform=node --format=cjs --outfile=/tmp/body-editor-state-test.cjs` 通过；Node smoke 覆盖新增排序、dirty 和依赖删除保护 | Joint 创建仍待 BE-11；删除确认目前以诊断阻止实现，尚未加交互式确认弹窗 |
| 2026-05-15 | BE-08 | TODO -> DOING -> DONE | `BodyEditorCanvas.tsx` 增加属性面板，按 `BODY_STRUCTS_BY_TYPE` 展示字段并提供文本、数字、布尔、Body Type、向量/顶点 JSON 输入；`BodyEditorState.ts` 增加字段更新和 rename 引用同步；`BodyEditor.tsx` 将字段编辑序列化回 `.b.lua` 并标记 tab modified | `pnpm lint` 通过；`pnpm exec esbuild src/BodyEditor/BodyEditor.tsx src/BodyEditor/BodyEditorCanvas.tsx src/BodyEditor/BodyEditorState.ts --bundle --platform=browser --format=esm --external:react '--external:@mui/*' --external:../Service --outdir=/tmp/body-editor-properties-test` 通过；Node smoke 覆盖 rename 更新 Joint 引用和重复名诊断 | 复杂字段暂用 JSON 文本输入，BE-10 会补 Canvas gizmo；round-trip 保存重开仍待 BE-12/BE-19 完整验收 |
| 2026-05-15 | BE-09 | TODO -> DOING -> DONE | `BodyRender.ts` 增加 SubShape 选择 id 和子形状解析导出；`BodyEditorCanvas.tsx` 在 body 列表下展示 SubShape 子项，并在属性面板提供 SubRect/SubDisk/SubPoly/SubChain 新增按钮；`BodyEditorState.ts` 支持新增、选择、字段编辑和删除子形状，保存仍落回父 body 的 `subShapes` 数组 | `pnpm lint` 通过；`pnpm exec esbuild src/BodyEditor/BodyEditorState.ts src/BodyEditor/BodyEditorCanvas.tsx --bundle --platform=browser --format=esm --external:react --outdir=/tmp/body-editor-subshape-test` 通过；Node smoke 覆盖新增 SubDisk、编辑 radius、删除并序列化回 `subShapes` | 子形状的拖拽 gizmo 仍待 BE-10；未做真实 Web IDE 保存重开手动验收 |
| 2026-05-15 | BE-10 | TODO -> DOING -> DONE | `BodyEditorCanvas.tsx` 增加选中项拖拽 gizmo：默认拖动选中 Body/SubShape/Joint 的相关点位，按 Shift 平移视图，Fix X/Y 工具约束轴向；`BodyEditorState.ts` 增加 `translateBodySelection()`，对 Position、Center、FacePos、Anchor/Ground/Offset、Vertices 等向量字段做数据内平移，不写入辅助状态 | `pnpm lint` 通过；`pnpm exec esbuild src/BodyEditor/BodyEditorState.ts src/BodyEditor/BodyEditorCanvas.tsx --bundle --platform=browser --format=esm --external:react --outdir=/tmp/body-editor-gizmo-test` 通过；Node smoke 覆盖 Body position、SubShape vertices 和 Joint anchors 平移 | Axis 目前仍主要通过属性面板编辑，未做专用旋转手柄；未做截图遮挡检查 |
| 2026-05-15 | BE-11 | TODO -> DOING -> DONE | `BodyEditorState.ts` 新增 10 类 Joint 默认创建逻辑，普通 Joint 默认绑定前两个 Body，Gear 只从 Revolute/Prismatic 候选中取依赖；`BodyEditorCanvas.tsx` 属性面板增加 Joint 创建按钮，工具栏 Joint 快捷创建 Distance；创建后继续走排序和 dirty 序列化 | `pnpm lint` 通过；`pnpm exec esbuild src/BodyEditor/BodyEditorState.ts src/BodyEditor/BodyEditorCanvas.tsx --bundle --platform=browser --format=esm --external:react --outdir=/tmp/body-editor-joint-test` 通过；Node smoke 覆盖 9 类普通 Joint 和 Gear 依赖过滤 | BodyA/BodyB、JointA/JointB 目前通过属性面板字段调整，不是专门的画布 chooser；保存重开验收仍待 BE-12/BE-19 |
| 2026-05-15 | BE-12 | TODO -> DOING -> DONE | `BodyEditor.tsx` 增加 undo/redo 栈和按钮，所有编辑操作通过 `writeBodyDocumentToLua()` 回写并触发 tab modified；`App.tsx` 新增 Dora Body 新建模板，`.b.lua` 初始内容为 `return {\"Array\"}`；`NewFileDialog.tsx` 增加 Dora Body 类型；`i18n.ts` 增加 BodyEditor 和新建类型文案 | `pnpm lint` 通过；`pnpm exec esbuild src/BodyEditor/BodyEditor.tsx --bundle --platform=browser --format=esm --external:react '--external:@mui/*' --external:../Service --outdir=/tmp/body-editor-save-test` 通过 | 未做真实 Web IDE 保存重开手动验收；完整 `pnpm build` 此前被中断，未继续运行 |
| 2026-05-15 | BE-13 | TODO -> DOING -> DONE | 新增 `BodyResource.ts` 解析 Sprite 图片、`.clip|clipName` 和 playable/model face 字符串；`BodyRender.ts` 在 `facePos` 绘制 face 占位标签；属性面板展示 face 类型/clip 信息，facePos 继续通过属性和 BE-10 gizmo 编辑；解析失败不阻止保存 | `pnpm lint` 通过；`pnpm exec esbuild src/BodyEditor/BodyResource.ts src/BodyEditor/BodyRender.ts src/BodyEditor/BodyEditorCanvas.tsx --bundle --platform=browser --format=esm --external:react --outdir=/tmp/body-editor-face-test` 通过；Node smoke 覆盖 png、clip、playable face 解析 | 尚未加载真实图片像素或 clip 图集裁剪，只显示占位；资源更新刷新在 BE-14 |
| 2026-05-15 | BE-14 | TODO -> DOING -> DONE | `App.tsx` 在 `.png/.jpg/.jpeg/.clip` UpdateFile 时同步递增已打开 `.b.lua` tab 的 `previewVersion`；`BodyEditor.tsx` 接收 `refreshKey` 并重新加载 `.b.lua` JSON，不自动改写文件内容 | `pnpm lint` 通过；`pnpm exec esbuild src/BodyEditor/BodyEditor.tsx --bundle --platform=browser --format=esm --external:react '--external:@mui/*' --external:../Service --outdir=/tmp/body-editor-refresh-test` 通过 | 未通过真实 WebSocket `UpdateFile` 做浏览器端手动观察；真实图片缓存待后续替换占位预览时继续复用 `refreshKey` |
| 2026-05-15 | BE-15 | TODO -> DOING -> DONE | `pnpm add planck` 更新 `Tools/dora-dora/package.json` 和 lockfile；新增 `BodyPhysicsRuntime.ts` 并从 `index.ts` 导出，封装零重力 Planck world、`1m = 100px` 边界转换、Body/Fixture 构建、SubShape fixture 构建、reset/step/snapshot 和可定位 runtime 诊断 | `pnpm lint` 通过；`pnpm exec esbuild src/BodyEditor/BodyPhysicsRuntime.ts --bundle --platform=node --format=cjs --outfile=/tmp/body-physics-runtime-test.cjs` 通过；Node smoke 覆盖 2 个 body、3 个 fixture、零重力、step 后无漂移和空诊断 | 已引入 Planck 依赖；动态播放 UI、`linearAcceleration` 施力和 Joint runtime 映射留到 BE-16/BE-17 |
| 2026-05-15 | BE-16 | TODO -> DOING -> DONE | `BodyPhysicsRuntime.step()` 在每帧 step 前对 dynamic body 施加 `mass * linearAcceleration`；`BodyEditorCanvas.tsx` 的 Play 按钮创建 runtime、requestAnimationFrame 驱动 step，并用 runtime snapshot 叠加渲染 body/debug draw，播放时不写回文档且禁用拖拽编辑；`BodyRender.ts` 支持按物理 snapshot 覆盖 body 位姿和 Joint 连线端点 | `pnpm lint` 通过；`pnpm exec esbuild src/BodyEditor/BodyPhysicsRuntime.ts src/BodyEditor/BodyEditorCanvas.tsx --bundle --platform=browser --format=esm --external:react --outdir=/tmp/body-editor-physics-play-test` 通过；Node smoke 覆盖 `{0,-10}` 下落、横向 acceleration 移动和源文档 position 不变 | 未做真实浏览器播放截图；Joint 动态约束和 motor 临时按钮留到 BE-17 |
| 2026-05-15 | BE-17 | TODO -> DOING -> DONE | `BodyPhysicsRuntime.ts` 映射 Distance/Friction/Spring(Planck MotorJoint 近似并诊断提示)/Prismatic/Pulley/Revolute/Rope/Weld/Wheel/Gear 到 Planck joint，并收集 motor 控制项；`BodyEditorCanvas.tsx` 播放态显示临时 motor `- / 0 / +` 按钮，暂停或 reset 后随 runtime 清理 | `pnpm lint` 通过；`pnpm exec esbuild src/BodyEditor/BodyPhysicsRuntime.ts src/BodyEditor/BodyEditorCanvas.tsx --bundle --platform=browser --format=esm --external:react --outdir=/tmp/body-editor-joint-runtime-test` 通过；Node smoke 覆盖 Distance/Revolute/Prismatic/Gear 构建、2 个 motor 控制和方向切换 | Spring 为近似预览；未做真实浏览器 motor 点击手动验收 |
| 2026-05-15 | BE-18 | TODO -> DOING -> DONE | `BodyEditorState.ts` 增加 item/SubShape 深拷贝复制；`BodyEditor.tsx` 接入 duplicate 回写；`BodyEditorCanvas.tsx` 增加 Delete/Backspace、Space 播放、Cmd/Ctrl+C/V、1/2/3/4 创建 Body、J 创建 Distance 的快捷键，播放态展示 runtime 诊断，窄屏隐藏右侧属性列表保证 Canvas/工具条不遮挡 | `pnpm lint` 通过；`pnpm exec esbuild src/BodyEditor/BodyEditor.tsx src/BodyEditor/BodyEditorCanvas.tsx src/BodyEditor/BodyEditorState.ts --bundle --platform=browser --format=esm --external:react '--external:@mui/*' --external:../Service --outdir=/tmp/body-editor-ergonomics-test` 通过；Node smoke 覆盖 Body/SubShape 复制和删除 | 未做真实浏览器窄屏截图；快捷键未接全局 undo/redo，仍使用顶部按钮 |
| 2026-05-15 | BE-19 | TODO -> DOING -> DONE | 新增 `BodyEditorSmoke.test.ts` 覆盖 parser/serializer round-trip、字段顺序、错误输入、状态函数和 physics runtime；新增 `fixtures/sample.b.lua` 与 `fixtures/invalid.b.lua` 作为手动/后续自动化验收样例；本文档记录 BE-00 到 BE-19 全部验收状态 | `pnpm lint` 通过；`pnpm exec esbuild src/BodyEditor/BodyEditorSmoke.test.ts --bundle --platform=node --format=cjs --outfile=/tmp/body-editor-smoke-test.cjs` 通过；`node -e require('/tmp/body-editor-smoke-test.cjs').runBodyEditorSmokeTests()` 等价 smoke 通过 | 浏览器插件缺少执行工具，真实 Web IDE 端截图/点击验收未能在本轮完成；完整 `pnpm build` 此前因写出 YarnEditor version 文件需要越权且用户中断，未继续运行 |
