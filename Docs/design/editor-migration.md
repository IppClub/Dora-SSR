# Dorothy Editors TypeScript 迁移方案

## 1. 项目概述

将 Dorothy 引擎的 ActionEditor 和 BodyEditor **1:1 复刻**到 Dora SSR 引擎中，使用 TypeScript 开发。UI 完全使用引擎自绘制方式（Node + DrawNode + Menu + Layer），与原始 Dorothy 编辑器的 UI 实现方式保持一致，不使用 ImGui。

### 原始编辑器规模

| 编辑器 | Lua 文件数 | 代码量 | 核心功能 |
|--------|-----------|--------|----------|
| ActionEditor | 17 | ~7,100 行 | Sprite 动作/动画编辑，关键帧，层级树，Look 管理 |
| BodyEditor | 21 | ~7,700 行 | 物理刚体编辑，碰撞形状，关节，物理模拟预览 |

### 原始共享 UI 组件（跨编辑器复用）

原始 Dorothy 编辑器中以下 UI 组件被两个编辑器共同使用，各自有独立拷贝：

| 组件 | 功能 | 实现方式 |
|------|------|----------|
| oBox | 对话框（带确认/取消按钮、可选输入框） | DrawNode + Menu + TextFieldTTF |
| oButton | 按钮（矩形/圆形，带缩放动画） | DrawNode + Line + MenuItem + LabelTTF |
| oTextField | 文本输入框（带光标闪烁） | TextFieldTTF + Line |
| oVertexControl | 顶点拖拽控制（可增删顶点） | DrawNode + Menu + MenuItem |
| oSelectionPanel | 通用滚动选择面板（带裁剪、惯性滑动） | ClipNode + Menu + Layer |
| oFileChooser | 文件浏览选择器 | 继承 oSelectionPanel |
| oSpriteChooser | Sprite 资源选择器 | 继承 oSelectionPanel |
| oSettingPanel | 属性编辑面板 | 继承 oSelectionPanel |

---

## 2. 技术方案

### 2.1 语言与编译

Dora SSR 通过内置编译器直接支持 `.ts` 文件的加载和运行。编辑器代码使用 TypeScript 编写，运行时编译为 Lua 执行。类型定义（`.d.ts`）在 `Assets/Script/Lib/Dora/en/` 目录下已完备。

### 2.2 开发工具链

使用引擎内置 CLI 模式进行代码编译检查和运行：

```bash
# 初始化 TS 项目
Dora cli init -p /Users/Jin/Workspace/Dora/Dora-Editor

# 编译检查（类型检查 + TSTL 编译）
Dora cli build --lang ts -p /Users/Jin/Workspace/Dora/Dora-Editor

# 编译单个文件（增量检查）
Dora cli build -p /Users/Jin/Workspace/Dora/Dora-Editor -f Editor/Common/Button.ts
```

开发流程中应频繁使用 `Dora cli build` 进行编译检查，及时发现和修正类型错误、API 调用问题。**不要使用 `Dora cli buildrun`**，因为代码 bug 可能导致辅助开发的引擎环境崩溃。

### 2.3 UI 框架 — 引擎自绘制

**完全使用引擎原生节点系统自绘制 UI**，与原始 Dorothy 编辑器 1:1 对应：

| 原始组件 | Dorothy API | Dora SSR API | 说明 |
|----------|-------------|--------------|------|
| 绘制基元 | CCDrawNode, oLine | DrawNode, Line | drawDot/drawSegment/drawPolygon 一致 |
| 触摸层 | CCLayer | Layer | touchEnabled + TouchBegan/Moved/Ended |
| 菜单系统 | CCMenu + CCMenuItem | Menu + MenuItem | 一致，支持 TapBegan/Tapped 事件 |
| 文本标签 | CCLabelTTF | Label | 一致，支持 getCharacter 获取单字 Sprite |
| 文本输入 | CCTextFieldTTF | 自建 TextInput 组件 | 旧引擎的 TextFieldTTF 不再存在，需用 Node + Label + IME 事件自建。参考 `Dora-Example/Example/TextInput.yue` 实现：Label 渲染文字 + attachIME/detachIME 管理输入 + onTextInput/onTextEditing/onKeyPressed 处理输入事件 + 光标闪烁动画 |
| 裁剪节点 | CCClipNode | ClipNode | oSelectionPanel 中用于面板裁剪 |
| 背景色 | CCLayerColor | LayerColor | 用于面板背景 |
| 动作系统 | CCSequence, CCSpawn, oScale, oOpacity | Sequence, Spawn, Scale, Opacity | 一致 |
| 调度 | CCScheduler, thread | Scheduler, Routine | 一致 |
| 渲染目标 | CCRenderTarget | RenderTarget | ActionEditor 中使用 |

### 2.4 引擎 API 对照

| 功能 | Dorothy API | Dora SSR API | 备注 |
|------|-------------|--------------|------|
| 导演 | CCDirector | Director | winSize 一致 |
| 场景 | CCScene | Scene | 一致 |
| 节点 | CCNode | Node | 一致 |
| 精灵 | CCSprite | Sprite | 一致 |
| 绘制 | CCDrawNode, oLine | DrawNode, Line | 一致 |
| 模型 | oModel, oCache.Model | Model, Cache | 一致 |
| 文件 | oContent | Content | load/save/exist/mkdir/copy 一致 |
| 数学 | oVec2, CCSize, CCRect | Vec2, Size, Rect | 一致 |
| 缓动 | oEase | Ease | 需确认函数列表完整 |
| 物理 | oWorld, oBody, oBodyDef | PhysicsWorld, Body, BodyDef | 一致 |
| 关节 | oJoint, oJointDef | Joint, JointDef | 新版更完整（10 种类型） |
| 动作 | oScale, oOpacity, oPos | Scale, Opacity, Pos | 一致 |
| 用户数据 | CCUserDefault | UserDefault | BodyEditor 中使用 |
| 字典 | CCDictionary | Record/object | 用 TS 对象替代 |
| 工具 | tolua | tolua | 部分底层操作 |

---

## 3. 架构设计

### 3.1 目录结构

项目路径: `/Users/Jin/Workspace/Dora/Dora-Editor/`

与原始 Dorothy 项目结构一一对应，共享组件统一到 Common 目录：

```
Assets/Script/Editor/
├── Common/                    # 共享 UI 组件库（对应原始各编辑器重复的 UI 代码）
│   ├── Box.ts                # 对话框（oBox）
│   ├── Button.ts             # 按钮（oButton）
│   ├── TextField.ts          # 文本输入（自建，基于 Label + IME，参考 Dora-Example TextInput.yue）
│   ├── SelectionPanel.ts     # 滚动选择面板（oSelectionPanel）
│   ├── FileChooser.ts        # 文件选择器（oFileChooser）
│   ├── SpriteChooser.ts      # Sprite 选择器（oSpriteChooser）
│   ├── SettingPanel.ts       # 属性编辑面板基类（oSettingPanel）
│   └── VertexControl.ts      # 顶点控制（oVertexControl）
│
├── ActionEditor/              # 动作编辑器
│   ├── main.ts               # 入口
│   ├── Editor.ts             # 编辑器主控（oEditor）
│   ├── ViewArea.ts           # 画布区域（oViewArea）
│   ├── ViewPanel.ts          # 层级树面板（oViewPanel）
│   ├── ControlBar.ts         # 时间线控制条（oControlBar）
│   ├── SettingPanel.ts       # 属性面板（继承 Common.SettingPanel）
│   ├── EditMenu.ts           # 菜单栏（oEditMenu）
│   ├── EditChooser.ts        # 编辑对象选择器（oEditChooser）
│   ├── LookChooser.ts        # Look 选择器（oLookChooser）
│   └── Packer.ts             # Sprite 打包（oPacker）
│
└── BodyEditor/                # 物理编辑器
    ├── main.ts               # 入口
    ├── Editor.ts             # 编辑器主控（oEditor）
    ├── ViewPanel.ts          # Body 列表面板（oViewPanel）
    ├── ViewItem.ts           # Body 列表项（oViewItem）
    ├── EditControl.ts        # 形状编辑控制（oEditControl）
    ├── SettingPanel.ts       # 属性面板（继承 Common.SettingPanel）
    ├── SettingItem.ts        # 属性项（oSettingItem）
    ├── EditMenu.ts           # 菜单栏（oEditMenu）
    ├── EditRuler.ts          # 标尺（oEditRuler）
    ├── JointChooser.ts       # 关节选择器（oJointChooser）
    ├── PlayButton.ts         # 播放按钮（oPlayButton）
    ├── PointControl.ts       # 点控制（oPointControl）
    └── LoaderGen.ts          # Lua Loader 生成
```

### 3.2 组件复用策略

原始 Dorothy 编辑器中 oBox/oButton/oTextField/oSelectionPanel/oVertexControl 在两个编辑器中各自有拷贝，实现基本相同。新方案统一到 `Common/` 目录：

- **完全共享**: Box, Button, TextField — 两个编辑器实现完全一致，直接复用
- **基类共享 + 继承扩展**: SelectionPanel, SettingPanel, FileChooser, SpriteChooser — 提供基类，各编辑器继承并定制内容和回调
- **编辑器独立**: ViewArea（画布交互逻辑差异大）、EditControl（BodyEditor 特有）、各种 Chooser

### 3.3 数据格式

#### ActionEditor Model 格式

保持与原始 Dorothy 格式兼容，便于导入旧数据：

```typescript
interface ModelData {
	anchorX: number;
	anchorY: number;
	clip?: string;
	name: string;
	opacity: number;
	angle: number;
	scaleX: number;
	scaleY: number;
	skewX: number;
	skewY: number;
	x: number;
	y: number;
	looks: string[];
	animationDefs: { [name: string]: AnimationDef };
	children: ModelData[];
	front?: boolean;
	isFaceRight?: boolean;
	isBatchUsed?: boolean;
	size?: [number, number];
	clipFile?: string;
	keys?: KeyDef;
	animationNames: string[];
	lookNames: string[];
}

interface AnimationDef {
	type: string;
	frameDefs: FrameDef[];
}

interface FrameDef {
	file: string;
	beginTime: number;
}

interface KeyDef {
	x: number;
	y: number;
	scaleX: number;
	scaleY: number;
	skewX: number;
	skewY: number;
	angle: number;
	opacity: number;
	visible: boolean;
	easeOpacity: number;
	easePos: number;
	easeAngle: number;
	easeScale: number;
	easeSkew: number;
	duration: number;
	event?: string;
}
```

#### BodyEditor Body 格式

```typescript
interface BodyFile {
	bodies: BodyData[];
	joints: JointData[];
}

interface BodyData {
	name: string;
	type: "Dynamic" | "Static" | "Kinematic";
	position: [number, number];
	angle: number;
	linearDamping: number;
	angularDamping: number;
	fixedRotation: boolean;
	isBullet: boolean;
	fixX: boolean;
	fixY: boolean;
	face?: string;
	facePos?: [number, number];
	fixtures: FixtureData[];
}

interface FixtureData {
	type: "polygon" | "disk" | "chain" | "multi";
	vertices: [number, number][];
	center?: [number, number];
	radius?: number;
	width?: number;
	height?: number;
	density: number;
	friction: number;
	restitution: number;
}

type JointType = "distance" | "friction" | "gear" | "prismatic" | "pulley" |
	"revolute" | "rope" | "weld" | "wheel" | "spring";

interface JointData {
	type: JointType;
	bodyA: string;
	bodyB: string;
	canCollide: boolean;
	// 各类型特有参数...
	[key: string]: unknown;
}
```

---

## 4. 开发计划

### Phase 0：基础设施（1-2 天）

- [ ] 创建目录结构
- [ ] 实现 Common UI 组件：Box, Button, TextField, SelectionPanel
- [ ] 验证引擎内置 CLI 编译检查流程（`Dora cli build`）
- [ ] 验证引擎自绘制 UI 在各平台的表现

### Phase 1：ActionEditor（预计 5-7 天）

#### P1.1 数据层
- [ ] Model 数据结构的序列化/反序列化
- [ ] 动画关键帧数据管理
- [ ] 旧格式兼容加载（解析 Dorothy .model 文件）

#### P1.2 共享组件
- [ ] FileChooser — 文件浏览选择器
- [ ] SpriteChooser — Sprite 资源选择器
- [ ] VertexControl — 节点位置/控制点拖拽

#### P1.3 画布与视图
- [ ] ViewArea — 核心画布（缩放、平移、网格、Sprite 渲染）
- [ ] ViewPanel — 层级树显示与管理

#### P1.4 编辑功能
- [ ] EditMenu — 四种模式切换（Start/Sprite/Animation/Look）
- [ ] SettingPanel — 属性编辑面板（位置/缩放/旋转/透明度）
- [ ] ControlBar — 时间线控制条（播放/暂停/帧光标）
- [ ] EditChooser — 编辑对象选择器
- [ ] LookChooser — Look 管理

#### P1.5 文件操作
- [ ] Packer — Sprite 打包导出
- [ ] Model 文件保存/加载

### Phase 2：BodyEditor（预计 5-7 天）

#### P2.1 数据层
- [ ] Body/Fixture 数据管理
- [ ] Joint 数据管理
- [ ] 旧格式兼容加载（解析 Dorothy .body 文件）
- [ ] LoaderGen — Lua 加载代码生成

#### P2.2 画布与编辑控制
- [ ] ViewArea — 物理编辑画布
- [ ] EditControl — 核心编辑控制（形状绘制/顶点编辑/拖拽/固定轴）
- [ ] EditRuler — 标尺
- [ ] PointControl — 点控制

#### P2.3 面板与管理
- [ ] EditMenu — 菜单栏（Body/Joint/文件/播放）
- [ ] SettingPanel + SettingItem — Body/Joint 属性编辑
- [ ] ViewPanel + ViewItem — Body 列表管理
- [ ] JointChooser — 关节类型选择
- [ ] PlayButton — 物理模拟播放/暂停

#### P2.4 文件操作
- [ ] Body 文件保存/加载

### Phase 3：集成与测试（2-3 天）

- [ ] 两个编辑器在 Dora SSR 中运行验证
- [ ] 旧数据文件导入测试
- [ ] 各平台（桌面/Web/移动端）UI 表现验证
- [ ] 性能优化
- [ ] 缺失引擎 API 补充（如需要）

---

## 5. 关键设计决策

### 5.1 引擎自绘制 UI（不使用 ImGui）

**完全使用引擎原生节点系统自绘制 UI**，与原始 Dorothy 编辑器保持 1:1 一致：

- **一致性** — 原始 Dorothy 编辑器的所有 UI（按钮、对话框、面板、选择器）均使用 CCNode/CCDrawNode/CCMenu/CCMenuItem 等引擎节点构建，新方案使用对应的 Node/DrawNode/Menu/MenuItem 等节点，API 映射直接
- **跨平台** — 引擎自绘制 UI 在所有 Dora SSR 支持的平台（桌面/Web/移动端）上表现一致，不需要处理 ImGui 的平台适配问题
- **触摸友好** — 引擎节点原生支持触摸事件，移动端无需额外适配
- **风格统一** — 保持 Dorothy 编辑器原有的视觉风格（半透明深色背景、青色文字、边框线条等）

### 5.2 数据格式兼容

优先兼容旧 Dorothy 的 `.model` 和 `.body` 文件格式，可直接导入旧项目数据。旧格式是自定义文本格式，新格式可考虑使用 JSON 以提高可读性和工具链兼容性。

### 5.3 共享组件统一

原始项目中 oBox/oButton/oTextField/oSelectionPanel/oVertexControl 在多个编辑器中各自拷贝了一份，代码几乎相同。新方案统一到 `Common/` 目录，避免重复代码，降低维护成本。

---

## 6. 风险与注意事项

1. **Model 渲染** — 新版 Model API 需验证是否完整支持旧格式的所有特性（front/isFaceRight/isBatchUsed 等）
2. **物理调试渲染** — PhysicsWorld.showDebug 的渲染效果需要确认
3. **文件写入权限** — Content.writablePath 在不同平台的行为需确认
4. **CCClipNode 对应** — 需确认 Dora SSR 中 ClipNode 的 stencil 渲染与原始 CCClipNode 行为一致
5. **CCRenderTarget** — ActionEditor 中使用了 RenderTarget，需确认 Dora SSR 的 RenderTarget API
6. **缺失 API** — 开发过程中通过引擎内置 CLI 编译检查及时发现缺失的引擎 API，在引擎侧补充实现
