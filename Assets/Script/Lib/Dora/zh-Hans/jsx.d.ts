import type * as dora from 'dora';

declare global {
namespace JSX {
interface Ref<T> {
	readonly current: T | null;
}

class Node {
	ref?: Ref<dora.Node.Type>;

	/** 节点在父节点的子节点数组中的顺序。 */
	order?: number;

	/** 节点的旋转角度，单位为度。 */
	angle?: number;

	/** 节点的X轴旋转角度，单位为度。 */
	angleX?: number;

	/** 节点的Y轴旋转角度，单位为度。 */
	angleY?: number;

	/** 节点的X轴缩放因子。 */
	scaleX?: number;

	/** 节点的Y轴缩放因子。 */
	scaleY?: number;

	/** 节点的X轴位置。 */
	x?: number;

	/** 节点的Y轴位置。 */
	y?: number;

	/** 节点的Z轴位置。 */
	z?: number;

	/** 节点的X轴倾斜角度，单位为度。 */
	skewX?: number;

	/** 节点的Y轴倾斜角度，单位为度。 */
	skewY?: number;

	/** 节点是否可见。 */
	visible?: boolean;

	/** 节点的锚点的X轴分量。 */
	anchorX?: number;

	/** 节点的锚点的Y轴分量。 */
	anchorY?: number;

	/** 节点的宽度。 */
	width?: number;

	/** 节点的高度。 */
	height?: number;

	/** 节点的标签，为字符串类型。 */
	tag?: string;

	/** 节点的透明度，应在0到1.0之间。 */
	opacity?: number;

	/** 节点的颜色，格式为0xffffff（RGB）。 */
	color3?: number;

	/** 是否将透明度值传递给子节点。 */
	passOpacity?: boolean;

	/** 是否将颜色值传递给子节点。 */
	passColor3?: boolean;

	/** 用于继承矩阵变换的目标节点。 */
	transformTarget?: Ref<Node>;

	/** 用于调度更新和动作回调的调度器。 */
	scheduler?: dora.Scheduler.Type;

	/** 节点上是否启用触摸事件。 */
	touchEnabled?: boolean;

	/** 节点是否独占触摸事件。 */
	swallowTouches?: boolean;

	/** 节点是否独占鼠标滚轮事件。 */
	swallowMouseWheel?: boolean;

	/** 节点上是否启用键盘事件。 */
	keyboardEnabled?: boolean;

	/** 节点上是否启用控制器事件。 */
	controllerEnabled?: boolean;

	/** 是否将节点的渲染与其所有递归子项分组。 */
	renderGroup?: boolean;

	/** 组渲染的渲染顺序号。渲染顺序较低的节点将更早渲染。 */
	renderOrder?: number;

	children?: any[] | any;

	/**
	 * 调用一个函数在每一帧运行，或是调度一个协程开始执行。
	 * @param funcOrJob 要运行的函数，返回true以停止。或是要运行的协程，用返回true或`coroutine.yield(true)`停止运行。
	 */
	onUpdate?(this: void, funcOrJob: ((this: void, deltaTime: number) => boolean) | dora.Job): void;

	/**
	 * ActionEnd事件会在节点执行完动作时触发。
	 * 在`node.runAction()`和`node.perform()`之后触发。
	 * @param action 执行完成的动作。
	 * @param target 执行完成动作的节点。
	 */
	onActionEnd?(this: void, action: dora.Action.Type, target: dora.Node.Type): void;

	/**
	 * TapFilter事件在TapBegan插槽之前触发，可用于过滤某些点击事件。
	 * 在设置`node.touchEnabled = true`之后才会触发。
	 * @param touch 点击事件的消息对象。
	*/
	onTapFilter?(this: void, touch: dora.Touch.Type): void;

	/**
	 * TapBegan事件在检测到点击时触发。
	 * 在设置`node.touchEnabled = true`之后才会触发。
	 * @param touch 点击事件的消息对象。
	*/
	onTapBegan?(this: void, touch: dora.Touch.Type): void;

	/**
	 * TapEnded事件在点击结束时触发。
	 * 在设置`node.touchEnabled = true`之后才会触发。
	 * @param touch 点击事件的消息对象。
	*/
	onTapEnded?(this: void, touch: dora.Touch.Type): void;

	/**
	 * Tapped事件在检测到并结束点击时触发。
	 * 在设置`node.touchEnabled = true`之后才会触发。
	 * @param touch 点击事件的消息对象。
	*/
	onTapped?(this: void, touch: dora.Touch.Type): void;

	/**
	 * TapMoved事件在点击移动时触发。
	 * 在设置`node.touchEnabled = true`之后才会触发。
	 * @param touch 点击事件的消息对象。
	*/
	onTapMoved?(this: void, touch: dora.Touch.Type): void;

	/**
	 * MouseWheel事件在滚动鼠标滚轮时触发。
	 * 在设置`node.touchEnabled = true`之后才会触发。
	 * @param delta 滚动的向量。
	*/
	onMouseWheel?(this: void, delta: dora.Vec2.Type): void;

	/**
	 * Gesture事件在识别到多点手势时触发。
	 * 在设置`node.touchEnabled = true`之后才会触发。
	 * @param center 手势的中心点。
	 * @param numFingers 手势涉及的触摸点数量。
	 * @param deltaDist 手势移动的距离。
	 * @param deltaAngle 手势的变动角度。
	*/
	onGesture?(this: void, center: dora.Vec2.Type, numFingers: number, deltaDist: number, deltaAngle: number): void;

	/**
	 * 当节点被添加到场景树中时，触发Enter事件。
	 * 当执行`node.addChild()`时触发。
	*/
	onEnter?(this: void): void;

	/**
	 * 当节点从场景树中移除时，触发Exit事件。
	 * 当执行`parent.removeChild()`时触发。
	*/
	onExit?(this: void): void;

	/**
	 * 当节点被清理时，触发Cleanup事件。
	 * 仅当执行`parent.removeChild(node, true)`时触发。
	*/
	onCleanup?(this: void): void;

	/**
	 * 当按下某个键盘按键时，触发KeyDown事件。
	 * 在设置`node.keyboardEnabled = true`后才会触发。
	 * @param keyName 被按下的键的名称。
	*/
	onKeyDown?(this: void, keyName: dora.KeyName): void;

	/**
	 * 当释放某个键盘按键时，触发KeyUp事件。
	 * 在设置`node.keyboardEnabled = true`后才会触发。
	 * @param keyName 被释放的键的名称。
	*/
	onKeyUp?(this: void, keyName: dora.KeyName): void;

	/**
	 * 当持续按下某个键时，触发KeyPressed事件。
	 * 在设置`node.keyboardEnabled = true`后才会触发。
	 * @param keyName 被持续按下的键的名称。
	*/
	onKeyPressed?(this: void, keyName: dora.KeyName): void;

	/**
	 * 当系统输入法（IME）开启到节点（调用`node: attachIME()`）时，会触发AttachIME事件。
	*/
	onAttachIME?(this: void): void;

	/**
	 * 当系统输入法（IME）关闭（调用`node: detachIME()`或手动关闭IME）时，会触发DetachIME事件。
	*/
	onDetachIME?(this: void): void;

	/**
	 * 当接收到系统输入法文本输入时，会触发TextInput事件。
	 * 在调用`node.attachIME()`之后触发。
	 * @param text 输入的文本。
	*/
	onTextInput?(this: void, text: string): void;

	/**
	 * 当系统输入法文本正在被编辑时，会触发TextEditing事件。
	 * 在调用`node:attachIME()`之后触发。
	 * @param text 正在编辑的文本。
	 * @param startPos 正在编辑的文本的起始位置。
	*/
	onTextEditing?(this: void, text: string, startPos: number): void;

	/**
	 * 当游戏控制器按钮被按下时触发ButtonDown事件。
	 * 在设置`node.controllerEnabled = true`之后触发。
	 * @param controllerId 控制器ID，当有多个控制器连接时从0开始递增。
	 * @param buttonName 被按下的按钮名称。
	*/
	onButtonDown?(this: void, controllerId: number, buttonName: dora.ButtonName): void;

	/**
	 * 当游戏控制器按钮被释放时触发ButtonUp事件。
	 * 在设置`node.controllerEnabled = true`之后触发。
	 * @param controllerId 控制器ID，当有多个控制器连接时从0开始递增。
	 * @param buttonName 被释放的按钮名称。
	*/
	onButtonUp?(this: void, controllerId: number, buttonName: dora.ButtonName): void;

	/**
	 * 当游戏控制器轴发生变化时触发Axis事件。
	 * 在设置`node.controllerEnabled = true`之后触发。
	 * @param controllerId 控制器ID，当有多个控制器连接时从0开始递增。
	 * @param axisValue 控制器轴的值，范围从 -1.0 到 1.0。
	*/
	onAxis?(this: void, controllerId: number, axisValue: number): void;
}

class ClipNode extends Node {
	ref?: Ref<dora.ClipNode.Type>;

	/**
	 * 定义剪切形状的蒙版节点。
	 */
	stencil: Node;

	/**
	 * 使像素可见的最小alpha阈值。值的范围从0到1。
	 */
	alphaThreshold?: number;

	/**
	 * 是否反转剪切区域。
	 */
	inverted?: boolean;
}

class Playable extends Node {
	ref?: Ref<dora.Playable.Type>;

	/**
	 * 动画的外观。
	 */
	look?: string;

	/**
	 * 动画的播放速度。
	 */
	speed?: number;

	/**
	 * 动画的恢复时间，以秒为单位。
	 * 用于从一个动画过渡到另一个动画。
	 */
	recovery?: number;

	/**
	 * 动画是否水平翻转。
	 */
	fliped?: boolean;

	/**
	 * 要加载的动画文件的文件名。
	 * 支持DragonBone，Spine2D和Dora Model文件。
	 * 应为以下格式之一：
	 *  "model:" + modelFile
	 *  "spine:" + spineStr
	 *  "bone:" + dragonBoneStr
	 */
	file: string;

	/**
	 * 要播放的动画的名称。
	 */
	play?: string;

	/**
	 * 是否要循环播放，默认为false。
	 */
	loop?: boolean;

	/**
	 * 当Playable动画模型播放结束动画后触发。
	 * @param animationName 播放结束的动画名称。
	 * @param target 播放该动画的动画模型实例。
	*/
	onAnimationEnd?(this: void, animationName: string, target: dora.Playable.Type): void;
}

class DragonBone extends Playable {
	ref?: Ref<dora.DragonBone.Type>;

	/**
	 * 用于创建新实例的`DragonBone`文件名字符串。
	 * `DragonBone`文件名字符串可以是不带扩展名的文件路径，例如 "DragonBone/item"，或包含所有相关扩展名的完整文件路径，例如："DragonBone/item_ske.json|DragonBone/item_tex.json"。
	 * 并且可以在分号后添加骨架名称。例如 "DragonBone/item;mainArmature" 或 "DragonBone/item_ske.json|DragonBone/item_tex.json;mainArmature"。
	 */
	file: string;

	/**
	 * 是否显示调试图形。
	 */
	showDebug?: boolean;

	/**
	 * 是否启用命中测试。
	 */
	hitTestEnabled?: boolean;
}

class Spine extends Playable {
	ref?: Ref<dora.Spine.Type>;

	/**
	 * 用于创建新实例的`Spine2D`文件名字符串。
	 * `Spine2D`文件名字符串可以是不带扩展名的文件路径，例如：“Spine/item”，也可以是带有所有相关文件的文件路径，例如 “Spine/item.skel|Spine/item.atlas” 或 “Spine/item.json|Spine/item.atlas”。
	 */
	file: string;

	/** 是否显示调试图形。 */
	showDebug?: boolean;

	/** 是否启用命中测试。 */
	hitTestEnabled?: boolean;
}

class Model extends Playable {
	ref?: Ref<dora.Model.Type>;

	/**
	 * 要加载的模型文件的文件名。
	 * 可以是带有或不带有扩展名的文件名，例如："Model/item" 或 "Model/item.model"。
	 */
	file: string;

	/**
	 * 是否将动画模型反向播放。
	 */
	reversed?: boolean;
}

class Dot {
	/**
	 * 点的X坐标位置。
	 */
	x: number;

	/**
	 * 点的Y坐标位置。
	 */
	y: number;

	/**
	 * 点的半径。
	 */
	radius: number;

	/**
	 * 点的颜色，格式为0xffffffff（ARGB），默认为白色。
	 */
	color?: number;
}

class Segment {
	/**
	 * 线段起点的X坐标。
	 */
	startX: number;

	/**
	 * 线段起点的Y坐标。
	 */
	startY: number;

	/**
	 * 线段终点的X坐标。
	 */
	stopX: number;

	/**
	 * 线段终点的Y坐标。
	 */
	stopY: number;

	/**
	 * 线段的半径。
	 */
	radius: number;

	/**
	 * 线段的颜色，格式为0xffffffff（ARGB），默认为白色。
	 */
	color?: number;
}

class Polygon {
	/*
	 * 多边形的顶点。
	 */
	verts: dora.Vec2.Type[];

	/*
	 * 多边形的填充颜色（默认为白色）。
	 */
	fillColor?: number;

	/**
	 * 边框的宽度（默认为0）。
	 */
	borderWidth?: number;

	/**
	 * 边框的颜色（默认为白色）。
	 */
	borderColor?: number;
}

class Verts {
	/*
	 * 包含要绘制的顶点及其颜色的列表，颜色格式为0xffffffff（ARGB）。
	 */
	verts: [vert: dora.Vec2.Type, color: number][];
}

class DrawNode extends Node {
	ref?: Ref<dora.DrawNode.Type>;

	/**
	 * 绘制时是否写入深度缓冲区（默认为false）。
	 */
	depthWrite?: boolean;

	/**
	 * 用于绘制形状的混合函数。
	 */
	blendFunc?: dora.BlendFunc.Type;
}

class Grid extends Node {
	ref?: Ref<dora.Grid.Type>;

	/**
	 * 用于网格的纹理文件名。
	 * 可以是用于网格的图片切片字符串 "Image/file.png" 或者 "Image/items.clip|itemA"。
	 */
	file: string;

	/** 网格中的列数。渲染时，水平方向上有 `gridX + 1` 个顶点。 */
	gridX: number;

	/** 网格中的行数。渲染时，垂直方向上有 `gridY + 1` 个顶点。 */
	gridY: number;

	/** 是否启用深度写入（默认为false）。 */
	depthWrite?: boolean;

	/** 用于网格的纹理内的矩形。 */
	textureRect?: dora.Rect.Type;

	/** 用于网格的混合函数。 */
	blendFunc?: dora.BlendFunc.Type;

	/** 应用于网格图元上的着色器特效。默认为 `SpriteEffect("builtin:vs_sprite", "builtin:fs_sprite")`。 */
	effect?: dora.SpriteEffect.Type;
}

class Sprite extends Node {
	ref?: Ref<dora.Sprite.Type>;

	/**
	 * 包含加载纹理文件格式的字符串。
	 * 可以是 "Image/file.png" 或者 "Image/items.clip|itemA"。支持的图片文件格式有：jpg、png、dds、pvr、ktx。
	 */
	file: string;

	/**
	 * 当渲染图元时，是否应该写入深度缓冲区（默认为false）。
	 */
	depthWrite?: boolean;

	/**
	 * 用于 alpha 测试的 alpha 参考值。小于或等于该值的像素将被丢弃。
	 * 仅在设置了 `sprite.effect = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritealphatest")` 时有效。
	 */
	alphaRef?: number;

	/**
	 * 图元的纹理矩形。
	 */
	textureRect?: dora.Rect.Type;

	/**
	 * 图元的混合函数。
	 */
	blendFunc?: dora.BlendFunc.Type;

	/**
	 * 图元的着色器特效。
	 */
	effect?: dora.SpriteEffect.Type;

	/**
	 * U（水平）轴的纹理包裹模式。
	 */
	uwrap?: dora.TextureWrap;

	/**
	 * V（垂直）轴的纹理包裹模式。
	 */
	vwrap?: dora.TextureWrap;

	/**
	 * 图元的纹理过滤模式。
	 */
	filter?: dora.TextureFilter;
}

class Label extends Node {
	ref?: Ref<dora.Label.Type>;

	/**
	 * 用于创建 Label 对象的字体名称。可以是带有或不带有文件扩展名的字体文件路径。
	 */
	fontName: string;

	/**
	 * 用于创建 Label 对象的字体大小。
	 */
	fontSize: number;

	/**
	 * 要渲染的文本。
	 */
	text?: string;

	/**
	 * Alpha 阈值。透明度低于此值的像素将不会被绘制。
	 * 仅在 `label.effect = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritealphatest")` 时有效。
	 */
	alphaRef?: number;

	/**
	 * 用于文本换行的文本宽度。
	 * 将其设置为 `Label.AutomaticWidth` 可禁用换行。
	 * 默认值为 `Label.AutomaticWidth`。
	 */
	textWidth?: number;

	/**
	 * 文本行之间的间距（以像素为单位）。
	 */
	lineGap?: number;

	/**
	 * 用于渲染文本的混合函数。
	 */
	blendFunc?: dora.BlendFunc.Type;

	/**
	 * 是否启用深度写入。（默认为 false）
	 */
	depthWrite?: boolean;

	/**
	 * 标签是否使用批量渲染。
	 * 使用批量渲染时，`label.getCharacter()` 函数将不再起作用，并获得更好的渲染性能。（默认为 true）
	 */
	batched?: boolean;

	/**
	 * 用于渲染文本的图元着色器特效。
	 */
	effect?: dora.SpriteEffect.Type;

	/**
	 * 文本对齐设置，默认为 TextAlign.Center。
	 */
	alignment?: dora.TextAlign;
}

class Line extends Node {
	ref?: Ref<dora.Line.Type>;

	/**
	 * 是否写入深度。（默认为 false）
	 */
	depthWrite?: boolean;

	/**
	 * 用于渲染线条的混合函数。
	 */
	blendFunc?: dora.BlendFunc.Type;

	/**
	 * 组成线条的顶点列表。
	 */
	verts: dora.Vec2.Type[];

	/**
	 * 线条的颜色，格式为0xffffffff（ARGB），默认为白色。
	 */
	lineColor?: number;
}

class Particle extends Node {
	ref?: Ref<dora.Particle.Type>;

	/**
	 * 加载粒子系统定义文件的文件路径。
	 */
	file: string;

	/**
	 * 是否在创建后开始发射粒子。默认为false。
	 */
	emit?: boolean;

	/**
	 * 当粒子系统节点在启动之后又停止发射粒子，并等待所有已发射的粒子结束它们的生命周期时触发。
	*/
	onFinished?(this: void): void;
}

class Menu extends Node {
	ref?: Ref<dora.Menu.Type>;

	/**
	 * 当前是否启用菜单节点。默认为 true。
	 */
	enabled?: boolean;
}

class Action {
	ref?: Ref<dora.ActionDef.Type>;
	children: any[] | any;
}

class AnchorX {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** 锚点的起始值。 */
	start: number;
	/** 锚点的结束值。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class AnchorY {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** 锚点的起始值。 */
	start: number;
	/** 锚点的结束值。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class Angle {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** 角度的起始值（以度为单位）。 */
	start: number;
	/** 角度的结束值（以度为单位）。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Linear。 */
	easing?: dora.EaseFunc;
}

class AngleX {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** X轴旋转角度的起始值（以度为单位）。 */
	start: number;
	/** X轴旋转角度的结束值（以度为单位）。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class AngleY {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** Y轴旋转角度的起始值（以度为单位）。 */
	start: number;
	/** Y轴旋转角度的结束值（以度为单位）。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class Delay {
	/** 延迟的持续时间（以秒为单位）。 */
	time: number;
}

class Event {
	/** 要触发的事件的名称。 */
	name: string;
	/** 传递给事件的参数。 (默认: "") */
	param?: string;
}

class Width {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** 节点的起始宽度值。 */
	start: number;
	/** 节点的结束宽度值。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class Height {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** 节点的起始高度值。 */
	start: number;
	/** 节点的结束高度值。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class Hide {}

class Show {}

class Move {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** 节点的起始X位置。 */
	startX: number;
	/** 节点的起始Y位置。 */
	startY: number;
	/** 节点的结束X位置。 */
	stopX: number;
	/** 节点的结束Y位置。 */
	stopY: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class Opacity {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** 节点的起始不透明度值（0-1.0）。 */
	start: number;
	/** 节点的结束不透明度值（0-1.0）。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class Roll {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** 节点的起始滚动值（以度为单位）。 */
	start: number;
	/** 节点的结束滚动值（以度为单位）。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class Scale {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** X轴和Y轴缩放的起始值。 */
	start: number;
	/** X轴和Y轴缩放的结束值。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class ScaleX {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** X轴缩放的起始值。 */
	start: number;
	/** X轴缩放的结束值。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class ScaleY {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** Y轴缩放的起始值。 */
	start: number;
	/** Y轴缩放的结束值。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class SkewX {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** 节点在x轴上的起始倾斜值（以度为单位）。 */
	start: number;
	/** 节点在x轴上的结束倾斜值（以度为单位）。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class SkewY {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** 节点在Y轴上的起始倾斜值（以度为单位）。 */
	start: number;
	/** 节点在Y轴上的结束倾斜值（以度为单位）。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class MoveX {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** 节点的起始X坐标位置。 */
	start: number;
	/** 节点的结束X坐标位置。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class MoveY {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** 节点的起始Y坐标位置。 */
	start: number;
	/** 节点的结束Y坐标位置。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class MoveZ {
	/** 动画的持续时间（以秒为单位）。 */
	time: number;
	/** 节点的起始Z坐标位置。 */
	start: number;
	/** 节点的结束Z坐标位置。 */
	stop: number;
	/** [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。 */
	easing?: dora.EaseFunc;
}

class Spawn {
	/** 要并行运行的一组动作定义对象。 */
	children: any[] | any;
}

class Sequence {
	/** 要按顺序执行的一组动作定义对象。 */
	children: any[] | any;
}

class PhysicsWorld extends Node {
	/**
	 * 是否应为物理世界显示调试图形。
	 */
	showDebug?: boolean;
}

class Contact {
	/**
	 * 物理体的分组A。
	 */
	groupA: number;

	/**
	 * 物理体的分组B。
	 */
	groupB: number;

	/**
	 * 是否允许碰撞。
	 */
	enabled: boolean;
}

class Body extends Node {
	/**
	 * 物理体的不同移动类型的枚举。
	 */
	type: dora.BodyMoveType;

	/**
	 * 在物理体上持续施加的线性加速度。
	 * 可以用来模拟重力、推力或是风力。
	 * @example
	 * bodyDef.linearAcceleration = Vec2(0, -9.8);
	 */
	linearAcceleration?: dora.Vec2.Type;

	/**
	 * 物理体的旋转是否被固定。
	 */
	fixedRotation?: boolean;

	/**
	 * 物理体是否为子弹。设置为true以进行额外的子弹移动检查。
	 */
	bullet?: boolean;

	/**
	 * 物理体的x轴速度。
	 */
	velocityX?: number;

	/**
	 * 物理体的y轴速度。
	 */
	velocityY?: number;

	/**
	 * 物理体的角速度。
	 */
	angularRate?: number;

	/**
	 * 物理体所属的碰撞组。
	 */
	group?: number;

	/**
	 * 物理体的线性阻尼。
	 */
	linearDamping?: number;

	/**
	 * 物理体的角阻尼。
	 */
	angularDamping?: number;

	/**
	 * 物理体的所有者的引用。
	 */
	owner?: dora.Object.Type;

	/**
	 * 物理体是否正在接收碰撞事件。默认为 false。
	 */
	receivingContact?: boolean;

	/**
	 * 当物理体对象与传感器对象碰撞时触发。
	 * 在设置`body.receivingContact = true`之后触发。
	 * @param other 当前发生碰撞的物理体对象。
	 * @param sensorTag 触发此碰撞事件的传感器的标签编号。
	*/
	onBodyEnter?(this: void, other: dora.Body.Type, sensorTag: number): void;

	/**
	 * 当物理体对象不再与传感器对象碰撞时触发。
	 * 在设置`body.receivingContact = true`之后触发。
	 * @param other 当前结束碰撞的物理体对象。
	 * @param sensorTag 触发此碰撞事件的传感器的标签。
	*/
	onBodyLeave?(this: void, other: dora.Body.Type, sensorTag: number): void;

	/**
	 * 当物理体对象开始与另物理体碰撞时触发。
	 * 在设置`body.receivingContact = true`之后触发。
	 * @param other 被碰撞的物理体对象。
	 * @param point 世界坐标系中的碰撞点。
	 * @param normal 世界坐标系中的接触表面法向量。
	*/
	onContactStart?(this: void, other: dora.Body.Type, point: dora.Vec2.Type, normal: dora.Vec2.Type): void;

	/**
	 * 当一个物理体对象停止与另一个物理体碰撞时触发。
	 * 在设置`body.receivingContact = true`之后触发。
	 * @param other 结束碰撞的物理体对象。
	 * @param point 世界坐标系中的碰撞点。
	 * @param normal 世界坐标系中的接触表面法向量。
	*/
	onContactEnd?(this: void, other: dora.Body.Type, point: dora.Vec2.Type, normal: dora.Vec2.Type): void;

	/**
	 * 注册一个函数，该函数在物理体与其他物理体发生碰撞时被调用。
	 * 当注册的函数返回false时，物理体将不会触发本次的碰撞事件。
	 * @param filter 碰撞过滤器函数。
	 */
	onContactFilter?(filter: (this: void, body: Body) => boolean): void;
}

class RectangleShape {
	/** 多边形的中心点。 */
	center?: dora.Vec2.Type;
	/** 多边形的宽度。 */
	width: number;
	/** 多边形的高度。 */
	height: number;
	/** 多边形的角度（默认为0.0）。 */
	angle?: number;
	/** 多边形的密度（默认为0.0）。 */
	density?: number;
	/** 多边形的摩擦系数（默认为0.4，应为0.0到1.0）。 */
	friction?: number;
	/** 多边形的弹性系数（默认为0.0，应为0.0到1.0）。 */
	restitution?: number;
	/** 感应器的整形数字标签。当感应器标签被设置时，该形状将创建为一个感应器区域。 */
	sensorTag?: number;
}

class PolygonShape {
	/** 多边形的顶点。 */
	verts: dora.Vec2.Type[];
	/** 多边形的密度（默认为0.0）（可选）。 */
	density?: number;
	/** 多边形的摩擦系数（默认为0.4，应为0.0到1.0）（可选）。 */
	friction?: number;
	/** 多边形的弹性系数（默认为0.0，应为0.0到1.0）（可选）。 */
	restitution?: number;
	/** 感应器的整形数字标签。当感应器标签被设置时，该形状将创建为一个感应器区域。 */
	sensorTag?: number;
}

class MultiShape {
	/** 表示组成凹形状的每个凸形状的顶点的Vec2数组。 */
	verts: dora.Vec2.Type[];
	/** 形状的密度（默认为0.0）。 */
	density?: number;
	/** 形状的摩擦系数（默认为0.4，应为0.0到1.0）。 */
	friction?: number;
	/** 形状的弹性系数（默认为0.0，应为0.0到1.0）。 */
	restitution?: number;
	/** 感应器的整形数字标签。当感应器标签被设置时，该形状将创建为一个感应器区域。 */
	sensorTag?: number;
}

class DiskShape {
	/** 圆盘的中心点。 */
	center?: dora.Vec2.Type;
	/** 圆盘的半径。 */
	radius: number;
	/** 圆盘的密度（默认为0.0）。 */
	density?: number;
	/** 圆盘的摩擦系数（默认为0.4，应为0.0到1.0）。 */
	friction?: number;
	/** 圆盘的弹性系数（默认为0.0，应为0.0到1.0）。 */
	restitution?: number;
	/** 感应器的整形数字标签。当感应器标签被设置时，该形状将创建为一个感应器区域。 */
	sensorTag?: number;
}

class ChainShape {
	/** 链的顶点。 */
	verts: dora.Vec2.Type[];
	/** 链的摩擦系数（默认为0.4）。 */
	friction?: number;
	/** 链的弹性系数（默认为0.0）。 */
	restitution?: number;
	/** 感应器的整形数字标签。当感应器标签被设置时，该形状将创建为一个感应器区域。 */
	sensorTag?: number;
}

class DistanceJoint {
	ref?: Ref<dora.Joint.Type>;
	/** 是否连接到关节的物理体会彼此碰撞。默认为 false。 */
	canCollide?: boolean;
	/** 要连接到关节的第一个物理体。 */
	bodyA: Ref<dora.Body.Type>;
	/** 要连接到关节的第二个物理体。 */
	bodyB: Ref<dora.Body.Type>;
	/** 关节在第一个物理体上的位置（默认值为 Vec2.zero）。 */
	anchorA?: dora.Vec2.Type;
	/** 关节在第二个物理体上的位置（默认值为 Vec2.zero）。 */
	anchorB?: dora.Vec2.Type;
	/** 关节的频率，单位为赫兹（默认值为 0.0）。 */
	frequency?: number;
	/** 关节的阻尼系数（默认值为 0.0）。 */
	damping?: number;
}

class FrictionJoint {
	ref?: Ref<dora.Joint.Type>;
	/** 是否连接到关节的物理体会彼此碰撞。默认为 false。 */
	canCollide?: boolean;
	/** 要连接到关节的第一个物理体。 */
	bodyA: Ref<dora.Body.Type>;
	/** 要连接到关节的第二个物理体。 */
	bodyB: Ref<dora.Body.Type>;
	/** 关节在物理世界中的位置。 */
	worldPos: dora.Vec2.Type;
	/** 可以施加到关节的最大力量。 */
	maxForce: number;
	/** 可以施加到关节的最大扭矩。 */
	maxTorque: number;
}

class GearJoint {
	ref?: Ref<dora.Joint.Type>;
	/** 是否连接到关节的物理体会彼此碰撞。默认为 false。 */
	canCollide?: boolean;
	/** 要连接到齿轮关节的第一个关节。 */
	jointA: Ref<dora.Joint.Type>;
	/** 要连接到齿轮关节的第二个关节。 */
	jointB: Ref<dora.Joint.Type>;
	/** 齿轮传动比率（默认值为 1.0）。 */
	ratio?: number;
}

class SpringJoint {
	ref?: Ref<dora.Joint.Type>;
	/** 是否连接到关节的物理体会彼此碰撞。默认为 false。 */
	canCollide?: boolean;
	/** 连接到关节的第一个物理体。 */
	bodyA: Ref<dora.Body.Type>;
	/** 连接到关节的第二个物理体。 */
	bodyB: Ref<dora.Body.Type>;
	/** 在物理体A坐标系下，物理体B的位置减去物理体A的位置。 */
	linearOffset: dora.Vec2.Type;
	/** 物理体B的角度减去物理体A的角度。 */
	angularOffset: number;
	/** 关节能够施加的最大力。 */
	maxForce: number;
	/** 关节能够施加的最大扭矩。 */
	maxTorque: number;
	/** 可选的纠正系数，默认为1.0。 */
	correctionFactor?: number;
}

class MoveJoint {
	ref?: Ref<dora.MoveJoint.Type>;
	/** 是否连接到关节的物理体会彼此碰撞。默认为 false。 */
	canCollide?: boolean;
	/** 关节连接的刚体。 */
	body: Ref<dora.Body.Type>;
	/** 刚体应该拖拽到的目标位置。 */
	targetPos: dora.Vec2.Type;
	/** 关节能够施加的最大力。 */
	maxForce: number;
	/** 可选的频率比率，默认为5.0。 */
	frequency?: number;
	/** 可选的阻尼比率，默认为0.7。 */
	damping?: number;
}

class PrismaticJoint {
	ref?: Ref<dora.MotorJoint.Type>;
	/** 是否连接到关节的物理体会彼此碰撞。默认为 false。 */
	canCollide?: boolean;
	/** 连接到关节的第一个刚体。 */
	bodyA: Ref<dora.Body.Type>;
	/** 连接到关节的第二个刚体。 */
	bodyB: Ref<dora.Body.Type>;
	/** 关节的世界坐标。 */
	worldPos: dora.Vec2.Type;
	/** 关节的轴角度。 */
	axisAngle: number;
	/** 可选的下限平移量，默认为0.0。 */
	lowerTranslation?: number;
	/** 可选的上限平移量，默认为0.0。 */
	upperTranslation?: number;
	/** 可选的最大电机力，默认为0.0。 */
	maxMotorForce?: number;
	/** 可选的电机速度，默认为0.0。 */
	motorSpeed?: number;
}

class PulleyJoint {
	ref?: Ref<dora.Joint.Type>;
	/** 是否连接到关节的物理体会彼此碰撞。默认为 false。 */
	canCollide?: boolean;
	/** 要连接的第一个物理体。 */
	bodyA: Ref<dora.Body.Type>;
	/** 要连接的第二个物理体。 */
	bodyB: Ref<dora.Body.Type>;
	/** 第一个物体上的锚点的位置（默认值为 Vec2.zero）。 */
	anchorA?: dora.Vec2.Type;
	/** 第二个物体上的锚点的位置（默认值为 Vec2.zero）。 */
	anchorB?: dora.Vec2.Type;
	/** 第一个物体上的地面锚点在世界坐标系中的位置。 */
	groundAnchorA: dora.Vec2.Type;
	/** 第二个物体上的地面锚点在世界坐标系中的位置。 */
	groundAnchorB: dora.Vec2.Type;
	/** [可选] 滑轮比率（默认值为1.0）。 */
	ratio?: number;
}

class RevoluteJoint {
	ref?: Ref<dora.MotorJoint.Type>;
	/** 是否连接到关节的物理体会彼此碰撞。默认为 false。 */
	canCollide?: boolean;
	/** 要连接的第一个物理体。 */
	bodyA: Ref<dora.Body.Type>;
	/** 要连接的第二个物理体。 */
	bodyB: Ref<dora.Body.Type>;
	/** 关节将被创建的世界坐标位置。 */
	worldPos: dora.Vec2.Type;
	/** [可选] 下限角度限制（弧度）（默认为0.0）。 */
	lowerAngle?: number;
	/** [可选] 上限角度限制（弧度）（默认为0.0）。 */
	upperAngle?: number;
	/** [可选] 关节施加的最大扭矩以达到目标速度（默认为0.0）。 */
	maxMotorTorque?: number;
	/** [可选] 关节的期望速度（默认为0.0）。 */
	motorSpeed?: number;
}

class RopeJoint {
	ref?: Ref<dora.Joint.Type>;
	/** 是否连接到关节的物理体会彼此碰撞。默认为 false。 */
	canCollide?: boolean;
	/** 要连接的第一个物理体。 */
	bodyA: Ref<dora.Body.Type>;
	/** 要连接的第二个物理体。 */
	bodyB: Ref<dora.Body.Type>;
	/** 第一个物体上的锚点的位置（默认值为 Vec2.zero）。 */
	anchorA?: dora.Vec2.Type;
	/** 第二个物体上的锚点的位置（默认值为 Vec2.zero）。 */
	anchorB?: dora.Vec2.Type;
	/** [可选] 锚点之间的最大距离（默认为0.0）。 */
	maxLength?: number;
}

class WeldJoint {
	ref?: Ref<dora.Joint.Type>;
	/** 是否连接到关节的物理体会彼此碰撞。默认为 false。 */
	canCollide?: boolean;
	/** 第一个将被连接的物体。 */
	bodyA: Ref<dora.Body.Type>;
	/** 第二个将被连接的物体。 */
	bodyB: Ref<dora.Body.Type>;
	/** 连接物体的世界位置。 */
	worldPos: dora.Vec2.Type;
	/** [可选] 关节的刚度频率，默认为 0.0。 */
	frequency?: number;
	/** [可选] 关节的阻尼比率，默认为 0.0。 */
	damping?: number;
}

class WheelJoint {
	ref?: Ref<dora.MotorJoint.Type>;
	/** 是否连接到关节的物理体会彼此碰撞。默认为 false。 */
	canCollide?: boolean;
	/** 第一个将被连接的物体。 */
	bodyA: Ref<dora.Body.Type>;
	/** 第二个将被连接的物体。 */
	bodyB: Ref<dora.Body.Type>;
	/** 连接物体的世界位置。 */
	worldPos: dora.Vec2.Type;
	/** 关节轴的角度，以弧度为单位。 */
	axisAngle: number;
	/** [可选] 关节电机可以施加的最大力矩，默认为 0.0。 */
	maxMotorTorque?: number;
	/** [可选] 关节电机的目标速度，默认为 0.0。 */
	motorSpeed?: number;
	/** [可选] 关节的刚度频率，默认为 2.0。 */
	frequency?: number;
	/** [可选] 关节的阻尼比率，默认为 0.7。 */
	damping?: number;
}

interface IntrinsicElements {
	/**
	 * 用于构建游戏对象的层级树结构的类。
	 */
	node: Node;
	/**
	 * 可以根据其蒙版的alpha值剪切其子节点渲染结果的节点。
	 */
	'clip-node': ClipNode;
	/**
	 * 动画模型系统类。
	 */
	playable: Playable;
	/**
	 * 使用DragonBones动画系统实现的'Playable'动画模型类。
	 */
	'dragon-bone': DragonBone;
	/**
	 * 使用Spine引擎实现的动画系统。
	 */
	spine: Spine;
	/**
	 * 'Playable'动画模型类的另一种实现。
	 */
	model: Model;
	/**
	 * 用于绘制简单形状（如点、线和多边形）的场景节点类。
	 */
	'draw-node': DrawNode;
	/**
	 * 在指定位置绘制指定半径和颜色的点。只能作为`<draw-node>`的子组件来使用。
	 */
	dot: Dot;
	/**
	 * 用指定的半径和颜色绘制两点之间的线段。只能作为`<draw-node>`的子组件来使用。
	 */
	segment: Segment;
	/**
	 * 绘制由顶点列表定义的多边形，具有指定的填充颜色和边框。只能作为`<draw-node>`的子组件来使用。
	 */
	polygon: Polygon;
	/**
	 * 把一组顶点绘制为多个三角形，每个顶点都有自己的颜色。只能作为`<draw-node>`的子组件来使用。
	 */
	verts: Verts;
	/**
	 * 用于将纹理渲染为图元网格的类，每个图元都可以定位、着色，并可以操作其UV坐标。
	 */
	grid: Grid;
	/**
	 * 用于在游戏场景树层次结构中渲染纹理的图元类。
	 */
	sprite: Sprite;
	/**
	 * 用于使用 TrueType 字体渲染文本的节点。
	 */
	label: Label;
	/**
	 * 使用一组顶点来绘制线条的类。
	 */
	line: Line;
	/**
	 * 用于发射和更新粒子动画的粒子系统节点。
	 */
	particle: Particle;
	/**
	 * 用于管理特定区域内子节点的触摸事件的接口。
	 * 菜单会拦截触摸事件并传递给子节点。
	 * 只有一个子节点可以接收第一个触摸事件；后续的多点触摸事件将被忽略。
	 */
	menu: Menu;
	/**
	 * 表示可以在节点上运行的动作对象的类。
	 */
	action: Action;
	/**
	 * 创建动作定义，该动作将持续改变节点的X锚点。
	 */
	'anchor-x': AnchorX;
	/**
	 * 创建动作定义，该动作将持续改变节点的Y锚点。
	 */
	'anchor-y': AnchorY;
	/**
	 * 创建动作定义，该动作将持续改变节点的角度。
	 */
	angle: Angle;
	/**
	 * 创建动作定义，该动作将持续改变节点的x轴旋转角度。
	 */
	'angle-x': AngleX;
	/**
	 * 创建动作定义，该动作将持续改变节点的y轴旋转角度。
	 */
	'angle-y': AngleY;
	/**
	 * 创建动作定义，该动作在动画时间线中产生延迟。
	 */
	delay: Delay;
	/**
	 * 创建动作定义，该动作将触发事件。
	 */
	event: Event;
	/**
	* 创建动作定义，该动作将持续改变节点的宽度。
	*/
	width: Width;
	/**
	 * 创建动作定义，该动作将持续改变节点的高度。
	 */
	height: Height;
	/**
	 * 创建动作定义，该动作将隐藏节点。
	 */
	hide: Hide;
	/**
	 * 创建动作定义，该动作将显示节点。
	 */
	show: Show;
	/**
	 * 创建动作定义，该动作将持续改变节点的位置。
	 */
	move: Move;
	/**
	 * 创建动作定义，该动作将持续改变节点的不透明度。
	 */
	opacity: Opacity;
	/**
	 * 创建动作定义，该动作将持续改变节点的旋转。
	 * 滚动动画将确保节点通过最小旋转角度旋转到目标角度。
	 */
	roll: Roll;
	/**
	 * 创建动作定义，该动作将持续改变节点的X轴和Y轴缩放。
	 */
	scale: Scale;
	/**
	 * 创建动作定义，该动作将持续改变节点的X轴缩放。
	 */
	'scale-x': ScaleX;
	/**
	 * 创建动作定义，该动作将持续改变节点的Y轴缩放。
	 */
	'scale-y': ScaleY;
	/**
	 * 创建动作定义，该动作将持续改变节点沿X轴的倾斜。
	 */
	'skew-x': SkewX;
	/**
	 * 创建动作定义，该动作将持续改变节点沿Y轴的倾斜。
	 */
	'skew-y': SkewY;
	/**
	 * 创建动作定义，该动作将持续改变节点的X坐标位置。
	 */
	'move-x': MoveX;
	/**
	 * 创建动作定义，该动作将持续改变节点的Y坐标位置。
	 */
	'move-y': MoveY;
	/**
	 * 创建动作定义，该动作将持续改变节点的z位置。
	 */
	'move-z': MoveZ;
	/**
	 * 创建动作定义，该动作会并行执行一组动作。
	 */
	spawn: Spawn;
	/**
	 * 创建动作定义，该动作会顺序执行一系列其它动作。
	 */
	sequence: Sequence;
	/**
	 * 在游戏中代表物理世界的类。
	 */
	'physics-world': PhysicsWorld;
	/**
	 * 设定物理体的分组之间的碰撞关系。
	 */
	contact: Contact;
	/**
	 * 在游戏中代表物理世界中的物理体的类。
	 */
	body: Body;
	/**
	 * 将矩形形状定义附加到物理体上。
	 */
	'rect-shape': RectangleShape;
	/**
	 * 使用顶点将多边形形状定义附加到物理体上。
	 */
	'polygon-shape': PolygonShape;
	/**
	 * 将由多个凸形状组成的凹形状定义附加到物理体上。
	 */
	'multi-shape': MultiShape;
	/**
	 * 将圆盘形状定义附加到物理体上。
	 */
	'disk-shape': DiskShape;
	/**
	 * 将链形状定义附加到物理体上。链形状是自由形式的线段序列，具有双面碰撞的特性。
	 */
	'chain-shape': ChainShape;
	/**
	 * 创建两个物理体之间的距离关节。
	 */
	'distance-joint': DistanceJoint;
	/**
	 * 创建两个物理体之间的摩擦关节。
	 */
	'friction-joint': FrictionJoint;
	/**
	 * 在两个其他关节之间创建齿轮关节。
	 */
	'gear-joint': GearJoint;
	/**
	 * 创建两个指定物理体之间的新弹簧关节。
	 */
	'spring-joint': SpringJoint;
	/**
	 * 为指定的刚体创建一个新的拖拽关节。
	 */
	'move-joint': MoveJoint;
	/**
	 * 创建两个指定刚体之间的新平移关节。
	 */
	'prismatic-joint': PrismaticJoint;
	/**
	 * 在两个物理体之间创建一个滑轮关节。
	 */
	'pulley-joint': PulleyJoint;
	/**
	 * 在两个物理体之间创建旋转关节。
	 */
	'revolute-joint': RevoluteJoint;
	/**
	 * 在两个物理体之间创建绳子关节。
	 */
	'rope-joint': RopeJoint;
	/**
	 * 创建两个物体之间的焊接关节。
	 */
	'weld-joint': WeldJoint;
	/**
	 * 创建两个物体之间的轮子关节。
	 */
	'wheel-joint': WheelJoint;
}

interface ElementChildrenAttribute {
	children: {};
}

} // namespace JSX
} // global

export {};
