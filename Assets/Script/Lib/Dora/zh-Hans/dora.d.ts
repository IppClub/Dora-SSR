/// <reference path="es6-subset.d.ts" />
/// <reference path="lua.d.ts" />

declare module "dora" {

interface BasicTyping<TypeName> {
	__basic__: TypeName;
}

type BasicType<TypeName, T = {}> = T & BasicTyping<TypeName>;

/** 可以存储在Array和Dictionary中的元素对象的基类。 */
class ContainerItem {
	protected constructor();
}

/**
 * 具有给定宽度和高度的尺寸对象。
 */
class Size extends ContainerItem {
	private constructor();

	/**
	 * 尺寸的宽度。
	 */
	width: number;

	/**
	 * 尺寸的高度。
	 */
	height: number;

	/**
	 * 设置尺寸的宽度和高度。
	 * @param width 尺寸的新宽度。
	 * @param height 尺寸的新高度。
	 */
	set(width: number, height: number): void;

	/**
	 * 检查两个尺寸是否相等。
	 * @param other 要比较的另尺寸。
	 * @returns 两个尺寸是否相等。
	 */
	equals(other: Size): boolean;

	/**
	 * 将尺寸乘以向量。
	 * @param vec 要乘以的向量。
	 * @returns 将尺寸乘以向量的结果。
	 * @example
	 * ```
	 * const halfSize = size.mul(Vec2(0.5, 0.5));
	 * ```
	 */
	mul(vec: Vec2): Size;
}

export type {Size as SizeType};

/**
 * 用于创建Size对象的类。
 */
interface SizeClass {
	/**
	 * 创建新的Size对象，给定宽度和高度。
	 *
	 * @param width 新尺寸的宽度（默认为0）。
	 * @param height 新尺寸的高度（默认为0）。
	 * @returns 新的Size对象。
	 * @example
	 * ```
	 * let size = Size(10, 20);
	 * ```
	 */
	(this: void, width?: number, height?: number): Size;

	/**
	 * 从现有的Size对象创建新的Size对象。
	 *
	 * @param other 用于创建新对象的现有Size对象。
	 * @returns 新的Size对象。
	 * @example
	 * ```
	 * let newSize = Size(existingSize);
	 * ```
	 */
	(this: void, other: Size): Size;

	/**
	 * 从Vec2对象创建新的Size对象。
	 *
	 * @param vec 用于创建新尺寸的向量，由Vec2对象表示。
	 * @returns 新的Size对象。
	 * @example
	 * ```
	 * let size = Size(Vec2(10, 20));
	 * ```
	 */
	(this: void, vec: Vec2): Size;

	/**
	 * 获取零尺寸对象。
	 */
	readonly zero: Size;
}

const sizeClass: SizeClass;
export {sizeClass as Size};

/**
 * 表示具有x和y分量的2D向量的类。
 */
class Vec2 extends ContainerItem {
	private constructor();

	/** 向量的x分量。 */
	readonly x: number;

	/** 向量的y分量。 */
	readonly y: number;

	/** 向量的长度。 */
	readonly length: number;

	/** 向量的平方长度。 */
	readonly lengthSquared: number;

	/** 向量与x轴之间的角度。 */
	readonly angle: number;

	/**
	 * 计算两个向量之间的距离。
	 * @param vec 要计算距离的另向量。
	 * @returns 两个向量之间的距离。
	 */
	distance(vec: Vec2): number;

	/**
	 * 计算两个向量之间的平方距离。
	 * @param vec 要计算平方距离的另向量。
	 * @returns 两个向量之间的平方距离。
	 */
	distanceSquared(vec: Vec2): number;

	/**
	 * 将向量标准化为长度为1。
	 * @returns 标准化的向量。
	 */
	normalize(): Vec2;

	/**
	 * 获取此向量的垂直向量。
	 * @returns 垂直向量。
	 */
	perp(): Vec2;

	/**
	 * 将向量限制在两个其他向量之间的范围内。
	 * @param from 范围的下限。
	 * @param to 范围的上限。
	 * @returns 限制后的向量。
	 */
	clamp(from: Vec2, to: Vec2): Vec2;

	/**
	 * 将两个向量相加。
	 * @param other 要添加的另向量。
	 * @returns 两个向量的和。
	 */
	add(other: Vec2): Vec2;

	/**
	 * 从向量中减去另向量。
	 * @param other 要减去的向量。
	 * @returns 两个向量的差。
	 */
	sub(other: Vec2): Vec2;

	/**
	 * 逐元素地将两个向量相乘。
	 * @param other 要乘以的另向量。
	 * @returns 两个向量逐元素相乘的结果。
	 */
	mul(other: Vec2): Vec2;

	/**
	 * 将向量乘以标量。
	 * @param other 要乘以的标量。
	 * @returns 将向量乘以标量的结果。
	 */
	mul(other: number): Vec2;

	/**
	 * 将向量乘以Size对象。
	 * @param other 要乘以的Size对象。
	 * @returns 将向量乘以Size对象的结果。
	 */
	mul(other: Size): Vec2;

	/**
	 * 将向量除以标量。
	 * @param other 要除以的标量。
	 * @returns 将向量除以标量的结果。
	 */
	div(other: number): Vec2;

	/**
	 * 比较两个向量是否相等。
	 * @param other 要比较的另向量。
	 * @returns 两个向量是否相等。
	 */
	equals(other: Vec2): boolean;
}

export type {Vec2 as Vec2Type};

/**
 * 用于创建Vec2对象的类。
 */
interface Vec2Class {
	/**
	 * 从现有的Vec2对象创建新的Vec2对象。
	 *
	 * @param other 用于创建新对象的现有Vec2对象。
	 * @returns 新的Vec2对象。
	 * @example
	 * ```
	 * const newVec = Vec2(existingVec);
	 * ```
	 */
	(this: void, other: Vec2): Vec2;

	/**
	 * 使用给定的x和y分量创建新的Vec2对象。
	 *
	 * @param x 新向量的x分量。
	 * @param y 新向量的y分量。
	 * @returns 新的Vec2对象。
	 * @example
	 * ```
	 * const newVec = Vec2(10, 20);
	 * ```
	 */
	(this: void, x: number, y: number): Vec2;

	/**
	 * 从Size对象创建新的Vec2对象。
	 *
	 * @param size 用于创建新向量的Size对象。
	 * @returns 新的Vec2对象。
	 * @example
	 * ```
	 * const newVec = Vec2(Size(10, 20));
	 * ```
	 */
	(this: void, size: Size): Vec2;

	/**
	 * 获取零向量对象。
	 */
	readonly zero: Vec2;
}

const vec2: Vec2Class;
export {vec2 as Vec2};

/**
 * 矩形对象，具有左下角原点位置和大小。
 * 继承自 `ContainerItem`。
 */
class Rect extends ContainerItem {
	private constructor();

	// 矩形的原点位置。
	origin: Vec2;

	// 矩形的尺寸。
	size: Size;

	// 矩形原点的x坐标。
	x: number;

	// 矩形原点的y坐标。
	y: number;

	// 矩形的宽度。
	width: number;

	// 矩形的高度。
	height: number;

	// 矩形的上边缘的y轴坐标值。
	top: number;

	// 矩形的下边缘的y轴坐标值。
	bottom: number;

	// 矩形的左边缘的x轴坐标值。
	left: number;

	// 矩形的右边缘的x轴坐标值。
	right: number;

	// 矩形中心的x坐标。
	centerX: number;

	// 矩形中心的y坐标。
	centerY: number;

	// 矩形的下界（左下角坐标）。
	lowerBound: Vec2;

	// 矩形的上界（右上角坐标）。
	upperBound: Vec2;

	/**
	 * 设置矩形的属性。
	 * @param x 矩形原点的x坐标。
	 * @param y 矩形原点的y坐标。
	 * @param width 矩形的宽度。
	 * @param height 矩形的高度。
	 */
	set(x: number, y: number, width: number, height: number): void;

	/**
	 * 检查点是否在矩形内。
	 * @param point 要检查的点，由Vec2对象表示。
	 * @returns 点是否在矩形内。
	 */
	containsPoint(point: Vec2): boolean;

	/**
	 * 检查矩形是否与另矩形相交。
	 * @param rect 要检查相交的另矩形，由Rect对象表示。
	 * @returns 矩形是否相交。
	 */
	intersectsRect(rect: Rect): boolean;

	/**
	 * 检查两个矩形是否相等。
	 * @param other 要比较的另矩形，由Rect对象表示。
	 * @returns 两个矩形是否相等。
	 */
	equals(other: Rect): boolean;
}

export type {Rect as RectType};

/**
 * 用于创建矩形对象的类。
 */
interface RectClass {
	/**
	 * 所有属性都设置为0的矩形对象。
	 */
	readonly zero: Rect;

	/**
	 * 使用另矩形对象创建新的矩形对象。
	 * @param other 用于创建新矩形对象的另矩形对象。
	 * @returns 新的矩形对象。
	 */
	(this: void, other: Rect): Rect;

	/**
	 * 使用单独的属性创建新的矩形对象。
	 * @param x 矩形原点的x坐标。
	 * @param y 矩形原点的y坐标。
	 * @param width 矩形的宽度。
	 * @param height 矩形的高度。
	 * @returns 新的矩形对象。
	 */
	(this: void, x: number, y: number, width: number, height: number): Rect;

	/**
	 * 使用Vec2对象作为原点和Size对象作为大小创建新的矩形对象。
	 * @param origin 矩形的原点，由Vec2对象表示。
	 * @param size 矩形的大小，由Size对象表示。
	 * @returns 新的矩形对象。
	 */
	(this: void, origin: Vec2, size: Size): Rect;

	/**
	 * 创建所有属性都设置为0的新矩形对象。
	 * @returns 新的矩形对象。
	 */
	(this: void): Rect;
}

const rectClass: RectClass;
export {rectClass as Rect};

/** 具有红色、绿色和蓝色通道的颜色。 */
class Color3 {
	private constructor();

	/** 颜色的红色通道，应为0到255。 */
	r: number;

	/** 颜色的绿色通道，应为0到255。 */
	g: number;

	/** 颜色的蓝色通道，应为0到255。 */
	b: number;

	/**
	 * 将颜色转换为RGB整数值。
	 * @returns 转换后的RGB整数。
	 */
	toRGB(): number;
}

export type {Color3 as Color3Type};

/** 用于创建Color3对象的类。 */
interface Color3Class {
	/**
	 * 创建所有通道都设置为0的颜色。
	 * @returns 新的`Color3`对象。
	 */
	(this: void): Color3;

	/**
	 * 从RGB整数值创建新的`Color3`对象。
	 * @param rgb 用于创建颜色的RGB整数值。
	 * 例如 0xffffff（白色），0xff0000（红色）。
	 * @returns 新的`Color3`对象。
	 */
	(this: void, rgb: number): Color3;

	/**
	 * 从RGB颜色通道值创建新的`Color3`对象。
	 * @param r 红色通道值（0-255）。
	 * @param g 绿色通道值（0-255）。
	 * @param b 蓝色通道值（0-255）。
	 * @returns 新的`Color3`对象。
	 */
	(this: void, r: number, g: number, b: number): Color3;
}

const color3Class: Color3Class;
export {color3Class as Color3};

/**
 * 表示具有红色、绿色、蓝色和alpha通道的颜色。
 */
class Color {
	private constructor();

	// 颜色的红色通道，应为0到255。
	r: number;

	// 颜色的绿色通道，应为0到255。
	g: number;

	// 颜色的蓝色通道，应为0到255。
	b: number;

	// 颜色的alpha通道，应为0到255。
	a: number;

	/**
	 * alpha通道的另一种表示方式。
	 * 颜色的不透明度，范围从0到1。
	 */
	opacity: number;

	/**
	 * 将颜色转换为没有alpha通道的Color3值。
	 * @returns 转换后的Color3值。
	 */
	toColor3(): Color3;

	/**
	 * 将颜色转换为ARGB整数值。
	 * @returns 转换后的ARGB整数。
	 */
	toARGB(): number;
}

export type {Color as ColorType};

/**
 * 提供创建Color对象的方法。
 */
interface ColorClass {
	/**
	 * 创建所有通道都设置为0的颜色。
	 * @returns 新的Color对象。
	 */
	(this: void): Color;

	/**
	 * 使用Color3对象和alpha值创建新的Color对象。
	 * @param color 作为Color3对象的颜色。
	 * @param a [可选] 颜色的alpha值，范围从0到255。
	 * @returns 新的Color对象。
	 */
	(this: void, color: Color3, a?: number): Color;

	/**
	 * 从ARGB整数值创建新的`Color`对象。
	 * @param argb 用于创建颜色的ARGB整数值。
	 * 例如 0xffffffff（不透明的白色），0x88ff0000（半透明的红色）
	 * @returns 新的`Color`对象。
	 */
	(this: void, argb: number): Color;

	/**
	 * 从RGBA颜色通道值创建新的`Color`对象。
	 * @param r 红色通道值（0-255）。
	 * @param g 绿色通道值（0-255）。
	 * @param b 蓝色通道值（0-255）。
	 * @param a alpha通道值（0-255）。
	 * @returns 新的`Color`对象。
	 */
	(this: void, r: number, g: number, b: number, a: number): Color;
}

const colorClass: ColorClass;
export {colorClass as Color};

/** 游戏引擎运行的平台类型。 */
export const enum PlatformType {
	Windows = "Windows",
	Android = "Android",
	macOS = "macOS",
	iOS = "iOS",
	Linux = "Linux",
	Unknown = "Unknown"
}

/**
 * 管理应用程序信息的单例类。
 */
interface App {
	/** 引擎运行到当前时间经过的帧数。 */
	readonly frame: number;

	/** 渲染主帧的缓冲纹理的大小。 */
	readonly bufferSize: Size;

	/**
	 * 屏幕的逻辑视觉大小。
	 * 视觉大小仅在应用程序窗口大小更改时更改。
	 */
	readonly visualSize: Size;

	/**
	 * 设备显示的像素密度比。
	 * 等于渲染缓冲纹理的像素大小除以应用程序窗口的大小。
	 */
	readonly devicePixelRatio: number;

	/** 游戏引擎当前运行的平台。 */
	readonly platform: PlatformType;

	/**
	 * 游戏引擎的版本字符串。
	 * 格式为“v0.0.0”。
	*/
	readonly version: string;

	/**
	 * 自从上一帧游戏更新以来间隔的时间（以秒为单位）。
	 * 在同游戏帧中多次调用时得到的是常数。
	*/
	readonly deltaTime: number;

	/** 从当前游戏帧开始到本次API调用经过的时间（以秒为单位）。 */
	readonly elapsedTime: number;

	/**
	 * 游戏引擎直到上一帧结束为止，已经运行的总时间（以秒为单位）。
	 * 在同游戏帧中多次调用时得到的是常数。
	 */
	readonly totalTime: number;

	/**
	 * 直到调用该API为止，游戏引擎已经运行的总时间（以秒为单位）。
	 * 在同游戏帧中多次调用时得到递增的数字。
	 */
	readonly runningTime: number;

	/**
	 * 基于Mersenne Twister算法生成的随机数。
	 * 由同一种子生成的随机数在每个平台上会保持一致。
	 */
	readonly rand: number;

	/**
	 * 游戏引擎可以运行的最大有效帧率。
	 * 最大有效帧率是通过设备屏幕的最大刷新率推断出来的。
	 */
	readonly maxFPS: number;

	/** 游戏引擎是否运行在调试模式下。 */
	readonly debugging: boolean;

	/** 引擎内置的C++测试的测试名称（用于辅助引擎本身开发）。 */
	readonly testNames: string[];

	/** 当前系统的语言环境字符串，格式例如：`zh-Hans`，`en`. */
	locale: string;

	/** Dora SSR的主题颜色。 */
	themeColor: Color;

	/** 随机数种子。 */
	seed: number;

	/**
	 * 游戏引擎应该运行的目标帧率。
	 * 仅在`fpsLimited`设置为true时有效。
	 */
	targetFPS: number;

	/**
	 * 游戏引擎是否自动限制帧率。
	 * 将`fpsLimited`设置为true，会使引擎通过执行忙等待的死循环以获取更加精准的机器时间，并计算切换到下一帧的时间点。
	 * 这是在PC机Windows系统上的通常做法，以提升CPU占用率来提升游戏的性能。但这也会导致额外的芯片热量产生和电力消耗。
	 */
	fpsLimited: boolean;

	/**
	 * 游戏引擎当前是否处于闲置状态。
	 * 将`idled`设置为true，将使游戏逻辑线程使用`sleep`系统调用来等待进入下一个游戏帧的时间点。
	 * 由于操作系统定时器存在一定程度的误差，可能导致游戏引擎睡眠过头而错过几个游戏帧。
	 * 闲置状态可以减少额外的CPU占用。
	 */
	idled: boolean;

	/**
	 * 应用程序窗口大小。
	 * 由于显示设备的DPI不同，可能会与实际的可视大小有差异。
	 * 将`winSize`设置为`Size.zero`，可以将应用程序窗口切换到全屏模式。
	 * 在Android和iOS平台上无法设置此属性。
	 */
	winSize: Size;

	/**
	 * 应用程序窗口的位置。
	 * 在Android和iOS平台上无法设置此属性。
	 */
	winPosition: Vec2;

	/**
	 * 运行特定的包含在引擎中的C++测试函数。
	 * @param name 要运行的测试的名称。
	 * @return 测试是否成功运行。
	 */
	runTest(name: string): boolean;

	/**
	 * 关闭游戏引擎。
	 * 该函数在Android和iOS平台不会生效，以遵循移动平台上应用程序规范。
	 */
	shutdown(): void;
}

const app: App;
export {app as App};

/** 被Lua虚拟机管理的C++对象的基类。 */
class Object extends ContainerItem {
	protected constructor();

	/** C++对象的ID。 */
	readonly id: number;

	/** C++对象的Lua引用ID。 */
	readonly ref: number;
}

export type {Object as ObjectType};

/** 用于访问C++对象管理相关信息的静态类。 */
interface ObjectClass {
	/** 现存的C++对象的总数。 */
	readonly count: number;

	/** 曾经创建的C++对象的最大数量。 */
	readonly maxCount: number;

	/** 现存的对C++对象的Lua引用的总数。 */
	readonly luaRefCount: number;

	/** 曾经创建的Lua引用的最大数量。 */
	readonly maxLuaRefCount: number;

	/** Lua引用的C++函数调用对象的数量。 */
	readonly callRefCount: number;

	/** 曾经创建的C++函数调用引用的最大数量。 */
	readonly maxCallRefCount: number;
}

const objectClass: ObjectClass;
export {objectClass as Object};

/** 动作定义对象的类型。 */
type ActionDef = BasicType<'ActionDef'>;

export type {ActionDef as ActionDefType};

/** 表示可以在节点上运行的动作对象的类 */
interface Action extends Object {
	/** 动作的持续时间 */
	readonly duration: number;

	/** 动作是否正在运行 */
	readonly running: boolean;

	/** 动作是否当前已暂停 */
	readonly paused: boolean;

	/** 动作是否应该反向运行 */
	reversed: boolean;

	/**
	 * 动作应该以何种速度运行
	 * 设置为1.0以获得正常速度，设置为2.0以获得两倍的速度
	 */
	speed: number;

	/** 暂停动作 */
	pause(): void;

	/** 恢复动作 */
	resume(): void;

	/**
	 * 更新动作的状态
	 * @param elapsed 更新动作所需的已过去的时间（以秒为单位）
	 * @param reversed 是否应该反向更新动作（默认为false）
	 */
	updateTo(elapsed: number, reversed?: boolean): void;
}

export type {Action as ActionType};

/** 用于创建可以在节点上运行的动作的类 */
interface ActionClass {
	/**
	 * 根据给定的定义创建新的动作
	 * @param actionDef 动作的定义
	 * @returns 新的动作对象
	 */
	(this: void, actionDef: ActionDef): Action;
}

export const actionClass: ActionClass;
export {actionClass as Action};

/** 缓动函数对象的类型。 */
type EaseFunc = BasicType<'EaseFunc', number>;

/** 获取缓动函数对象的接口。 */
interface EaseClass {
	/** 应用线性变化率的缓动函数。 */
	Linear: EaseFunc;

	/** 开始慢，然后快速加速的缓动函数。 */
	InQuad: EaseFunc;

	/** 缓动函数，开始快，然后快速减速。 */
	OutQuad: EaseFunc;

	/** 缓动函数，开始慢，然后加速，然后减速。 */
	InOutQuad: EaseFunc;

	/** 缓动函数，开始快，然后减速，然后加速。 */
	OutInQuad: EaseFunc;

	/** 缓动函数，开始慢，然后逐渐加速。 */
	InCubic: EaseFunc;

	/** 缓动函数，开始快，然后逐渐减速。 */
	OutCubic: EaseFunc;

	/** 缓动函数，开始慢，然后加速，然后减速。 */
	InOutCubic: EaseFunc;

	/** 缓动函数，开始快，然后减速，然后加速。 */
	OutInCubic: EaseFunc;

	/** 缓动函数，开始慢，然后急剧加速。 */
	InQuart: EaseFunc;

	/** 缓动函数，开始快，然后急剧减速。 */
	OutQuart: EaseFunc;

	/** 缓动函数，开始慢，然后急剧加速，然后急剧减速。 */
	InOutQuart: EaseFunc;

	/** 缓动函数，开始快，然后急剧减速，然后急剧加速。 */
	OutInQuart: EaseFunc;

	/** 缓动函数，开始慢，然后极快地加速。 */
	InQuint: EaseFunc;

	/** 缓动函数，开始快，然后极快地减速。 */
	OutQuint: EaseFunc;

	/** 缓动函数，开始慢，然后极快地加速，然后极快地减速。 */
	InOutQuint: EaseFunc;

	/** 缓动函数，开始快，然后极快地减速，然后极快地加速。 */
	OutInQuint: EaseFunc;

	/** 缓动函数，开始慢，然后逐渐加速，然后再次减速。 */
	InSine: EaseFunc;

	/** 缓动函数，开始快，然后逐渐减速，然后再次减速。 */
	OutSine: EaseFunc;

	/** 缓动函数，开始慢，然后逐渐加速，然后逐渐减速。 */
	InOutSine: EaseFunc;

	/** 缓动函数，开始快，逐渐减速，然后逐渐加速。 */
	OutInSine: EaseFunc;

	/** 缓动函数，开始极慢，然后以指数方式加速。 */
	InExpo: EaseFunc;

	/** 缓动函数，开始极快，然后以指数方式减速。 */
	OutExpo: EaseFunc;

	/** 缓动函数，开始极慢，以指数方式加速，然后以指数方式减速。 */
	InOutExpo: EaseFunc;

	/** 缓动函数，开始极快，以指数方式减速，然后以指数方式加速。 */
	OutInExpo: EaseFunc;

	/** 缓动函数，开始慢，以圆形方式逐渐加速。 */
	InCirc: EaseFunc;

	/** 缓动函数，开始快，以圆形方式逐渐减速。 */
	OutCirc: EaseFunc;

	/** 缓动函数，开始慢，以圆形方式逐渐加速，然后以圆形方式逐渐减速。 */
	InOutCirc: EaseFunc;

	/** 缓动函数，开始快，以圆形方式逐渐减速，然后以圆形方式逐渐加速。 */
	OutInCirc: EaseFunc;

	/** 缓动函数，开始慢，以指数方式加速，超过目标然后返回。 */
	InElastic: EaseFunc;

	/** 缓动函数，开始快，以指数方式减速，超过目标然后返回。 */
	OutElastic: EaseFunc;

	/** 缓动函数，开始慢，以指数方式加速，超过目标然后返回，然后以指数方式减速，再次超过目标然后返回。 */
	InOutElastic: EaseFunc;

	/** 缓动函数，开始快速，指数级地减速，超过目标然后返回，然后指数级地加速，再次超过目标然后返回。 */
	OutInElastic: EaseFunc;

	/** 缓动函数，开始慢，然后急剧向后加速，最后返回到目标。 */
	InBack: EaseFunc;

	/** 缓动函数，开始快，然后急剧向后减速，最后返回到目标。 */
	OutBack: EaseFunc;

	/** 缓动函数，开始慢，急剧向后加速，然后急剧向前减速，最后返回到目标。 */
	InOutBack: EaseFunc;

	/** 缓动函数，开始快，急剧向后减速，然后急剧向前加速，最后返回到目标。 */
	OutInBack: EaseFunc;

	/** 缓动函数，开始慢，然后在弹跳的动作中加速，最后在目标上稳定下来。 */
	InBounce: EaseFunc;

	/** 缓动函数，开始快，然后在弹跳的动作中减速，最后在目标上稳定下来。 */
	OutBounce: EaseFunc;

	/** 缓动函数，开始慢，在弹跳的动作中加速，然后在弹跳的动作中减速，最后在目标上稳定下来。 */
	InOutBounce: EaseFunc;

	/** 缓动函数，开始快，在弹跳的动作中减速，然后在弹跳的动作中加速，最后在目标上稳定下来。 */
	OutInBounce: EaseFunc;

	/**
	 * 在给定的时间内对给定的值应用缓动函数。
	 * @param easing 要应用的缓动函数。
	 * @param time 要应用缓动函数的时间，应在0和1之间。
	 * @returns 将缓动函数应用于值的结果。
	 */
	func(easing: EaseFunc, time: number): number;
}

export const Ease: EaseClass;

/**
 * 创建动作定义，该动作将持续改变节点的x锚点从值到另值。
 * @param duration 动画的持续时间（以秒为单位）。
 * @param from 锚点的起始值。
 * @param to 锚点的结束值。
 * @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
 * @returns 可用于在节点上运行动画的动作定义对象。
 */
export function AnchorX(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // 默认为Ease.Linear
): ActionDef;

/**
 * 创建动作定义，该动作将持续改变节点的y锚点从值到另值。
 * @param duration 动画的持续时间（以秒为单位）。
 * @param from 锚点的起始值。
 * @param to 锚点的结束值。
 * @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
 * @returns 可用于在节点上运行动画的动作定义对象。
 */
export function AnchorY(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // 默认为Ease.Linear
): ActionDef;

/**
 * 创建动作定义，该动作将持续改变节点的角度从值到另值。
 * @param duration 动画的持续时间（以秒为单位）。
 * @param from 角度的起始值（以度为单位）。
 * @param to 角度的结束值（以度为单位）。
 * @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Linear。
 * @returns 可用于在节点上运行动画的动作定义对象。
 */
export function Angle(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // 默认为Linear
): ActionDef;

/**
 * 创建动作定义，该动作将持续改变节点的x轴旋转角度从值到另值。
 * @param duration 动画的持续时间（以秒为单位）。
 * @param from x轴旋转角度的起始值（以度为单位）。
 * @param to x轴旋转角度的结束值（以度为单位）。
 * @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
 * @returns 可用于在节点上运行动画的动作定义对象。
 */
export function AngleX(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // Ease.Linear
): ActionDef;

/**
 * 创建动作定义，该动作将持续改变节点的y轴旋转角度从值到另值。
 * @param duration 动画的持续时间（以秒为单位）。
 * @param from y轴旋转角度的起始值（以度为单位）。
 * @param to y轴旋转角度的结束值（以度为单位）。
 * @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
 * @returns 可用于在节点上运行动画的动作定义对象。
 */
export function AngleY(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // Ease.Linear
): ActionDef;

/**
 * 创建动作定义，该动作在动画时间线中产生延迟。
 * @param duration 延迟的持续时间（以秒为单位）。
 * @returns 代表动画时间线中延迟的动作定义对象。
 */
export function Delay(this: void, duration: number): ActionDef;

/**
 * 创建动作定义，该动作将触发事件。
 * @param name 要触发的事件的名称。
 * @param param 传递给事件的参数。 (默认: "")
 * @returns 创建的 `ActionDef`。
 * @example
 * 通过从执行动作的节点注册事件来获取此事件。
 * ```
 * node.slot("EventName", function(param: string) {
 * 	print("EventName triggered with param", param);
 * });
 * node.perform(Sequence(
 * 	Delay(3),
 * 	Event("EventName", "Hello")
 * ));
 * ```
 */
export function Event(this: void, name: string, param?: string): ActionDef;

/**
* 创建动作定义，该动作将持续改变节点的宽度。
* @param duration 动画的持续时间（以秒为单位）。
* @param from 节点的起始宽度值。
* @param to 节点的结束宽度值。
* @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
* @returns 可用于在节点上运行动画的动作定义对象。
*/
export function Width(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc
): ActionDef;

/**
 * 创建动作定义，该动作将持续改变节点的高度。
 * @param duration 动画的持续时间（以秒为单位）。
 * @param from 节点的起始高度值。
 * @param to 节点的结束高度值。
 * @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
 * @returns 可用于在节点上运行动画的动作定义对象。
 */
export function Height(this: void, duration: number, from: number, to: number, easing?: EaseFunc): ActionDef;

/**
 * 创建动作定义，该动作将隐藏节点。
 * @returns 可用于隐藏节点的动作定义对象。
 */
export function Hide(this: void): ActionDef;

/**
* 创建动作定义，该动作将显示节点。
* @returns 可用于显示节点的动作定义对象。
*/
export function Show(this: void): ActionDef;

/**
 * 创建动作定义，该动作将持续改变节点的位置从Vec2值到另值。
 * @param duration 动画的持续时间（以秒为单位）。
 * @param from 节点的起始位置。
 * @param to 节点的结束位置。
 * @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
 * @returns 可用于在节点上运行动画的动作定义对象。
 */
export function Move(this: void, duration: number, from: Vec2, to: Vec2, easing?: EaseFunc): ActionDef;

/**
 * 创建动作定义，该动作将持续改变节点的不透明度从值到另值。
 * @param duration 动画的持续时间（以秒为单位）。
 * @param from 节点的起始不透明度值（0-1.0）。
 * @param to 节点的结束不透明度值（0-1.0）。
 * @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
 * @returns 可用于在节点上运行动画的动作定义对象。
 */
export function Opacity(this: void, duration: number, from: number, to: number, easing?: EaseFunc): ActionDef;

/**
 * 创建动作定义，该动作将持续改变节点的旋转从值到另值。
 * 滚动动画将确保节点通过最小旋转角度旋转到目标角度。
 * @param duration 动画的持续时间（以秒为单位）。
 * @param from 节点的起始滚动值（以度为单位）。
 * @param to 节点的结束滚动值（以度为单位）。
 * @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
 * @returns 可用于在节点上运行动画的动作定义对象。
 */
export function Roll(this: void, duration: number, from: number, to: number, easing?: EaseFunc): ActionDef;

/**
 * 创建动作定义，该动作将持续改变节点的x轴和y轴缩放从值到另值。
 * @param duration 动画的持续时间（以秒为单位）。
 * @param from x轴和y轴缩放的起始值。
 * @param to x轴和y轴缩放的结束值。
 * @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
 * @returns 可用于在节点上运行动画的动作定义对象。
 */
export function Scale(this: void, duration: number, from: number, to: number, easing?: EaseFunc): ActionDef;

/**
 * 创建动作定义，该动作将持续改变节点的x轴缩放从值到另值。
 * @param duration 动画的持续时间（以秒为单位）。
 * @param from x轴缩放的起始值。
 * @param to x轴缩放的结束值。
 * @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
 * @returns 可用于在节点上运行动画的动作定义对象。
 */
export function ScaleX(this: void, duration: number, from: number, to: number, easing?: EaseFunc): ActionDef;

/**
 * 创建动作定义，该动作将持续改变节点的y轴缩放从值到另值。
 * @param duration 动画的持续时间（以秒为单位）。
 * @param from y轴缩放的起始值。
 * @param to y轴缩放的结束值。
 * @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
 * @returns 可用于在节点上运行动画的动作定义对象。
 */
export function ScaleY(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc
): ActionDef;

/**
* 创建动作定义，该动作将持续改变节点沿x轴的倾斜。
* @param duration 动画的持续时间（以秒为单位）。
* @param from 节点在x轴上的起始倾斜值（以度为单位）。
* @param to 节点在x轴上的结束倾斜值（以度为单位）。
* @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
* @returns 可用于在节点上运行动画的动作定义对象。
*/
export function SkewX(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc
): ActionDef;

/**
* 创建动作定义，该动作将持续改变节点沿y轴的倾斜。
* @param duration 动画的持续时间（以秒为单位）。
* @param from 节点在y轴上的起始倾斜值（以度为单位）。
* @param to 节点在y轴上的结束倾斜值（以度为单位）。
* @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
* @returns 可用于在节点上运行动画的动作定义对象。
*/
export function SkewY(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc
): ActionDef;

/**
 * 创建动作定义，该动作将持续改变节点的x位置。
 * @param duration 动画的持续时间（以秒为单位）。
 * @param from 节点的起始x位置。
 * @param to 节点的结束x位置。
 * @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
 * @returns 可用于在节点上运行动画的动作定义对象。
 */
export function X(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // 默认值: Ease.Linear
): ActionDef;

/**
 * 创建动作定义，该动作将持续改变节点的y位置。
 * @param duration 动画的持续时间（以秒为单位）。
 * @param from 节点的起始y位置。
 * @param to 节点的结束y位置。
 * @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
 * @returns 可用于在节点上运行动画的动作定义对象。
 */
export function Y(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // 默认值: Ease.Linear
): ActionDef;

/**
 * 创建动作定义，该动作将持续改变节点的z位置。
 * @param duration 动画的持续时间（以秒为单位）。
 * @param from 节点的起始z位置。
 * @param to 节点的结束z位置。
 * @param easing [可选] 用于动画的缓动函数。如果未指定，默认为Ease.Linear。
 * @returns 可用于在节点上运行动画的动作定义对象。
 */
export function Z(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // 默认值: Ease.Linear
): ActionDef;

/**
* 创建动作定义，该动作并行运行一组ActionDefs。
* @param actions 要并行运行的一组ActionDef对象。
* @returns 可用于在节点上运行动作组的动作定义对象。
*/
export function Spawn(this: void, ...actions: ActionDef[]): ActionDef;

/**
 * 创建动作定义，该动作播放一系列其他ActionDefs。
 * @param actions 要按顺序播放的一组ActionDef对象。
 * @returns 可用于在节点上运行动作序列的动作定义对象。
 */
export function Sequence(this: void, ...actions: ActionDef[]): ActionDef;

/**
 * 支持在数组对象存储数据类型。
 * 可以是整数，数字，布尔值，字符串，线程，继承自`ContainerItem`的对象。
 */
export type Item = number | boolean | string | LuaThread | ContainerItem;

/**
 * 支持各种操作的数组数据结构。
 * 数组类设计为基于1的索引，这意味着数组中的第一个项目的索引为1。
 * 这与作为数组使用的Lua表容器的行为相同。
 */
class Array extends Object {
	private constructor();

	/** 数组中的元素数量。 */
	readonly count: number;

	/** 数组是否为空。 */
	readonly empty: boolean;

	/**
	 * 将另数组中的所有元素添加到此数组的末尾。
	 * @param other 另数组对象。
	 */
	addRange(other: Array): void;

	/**
	 * 从此数组中移除所有也在另数组中的元素。
	 * @param other 另数组对象。
	 */
	removeFrom(other: Array): void;

	/** 从数组中移除所有元素。 */
	clear(): void;

	/** 反转数组中元素的顺序。 */
	reverse(): void;

	/** 从数组末尾移除预留内存空间。用于释放此数组持有的未使用的内存。 */
	shrink(): void;

	/**
	 * 交换两个给定索引处的元素。
	 * @param indexA 第一个索引。
	 * @param indexB 第二个索引。
	 */
	swap(indexA: number, indexB: number): void;

	/**
	 * 移除给定索引处的元素。
	 * @param index 要移除的索引。
	 * @returns 如果移除了元素，则返回true，否则返回false。
	 */
	removeAt(index: number): boolean;

	/**
	 * 移除给定索引处的元素，可能会改变剩余元素的顺序。
	 * @param index 要移除的索引。
	 * @returns 如果移除了元素，则返回true，否则返回false。
	 */
	fastRemoveAt(index: number): boolean;

	/**
	 * 对数组中的每个元素调用给定的函数。
	 * 应返回false以继续迭代，返回true以停止。
	 * @param func 要为每个元素调用的函数。
	 * @returns 如果迭代完成，则返回false，如果被函数中断，则返回true。
	 */
	each(func: (this: void, item: Item) => boolean): boolean;

	/** 数组中的第一个元素。 */
	readonly first: Item;

	/** 数组中的最后一个元素。 */
	readonly last: Item;

	/** 数组中的随机元素。 */
	readonly randomObject: Item;

	/**
	 * 设置给定索引处的元素。
	 * @param index 要设置的索引，从1开始。
	 * @param item 新的元素值。
	 */
	set(index: number, item: Item): void;

	/**
	 * 获取给定索引处的元素。
	 * @param index 要获取的索引，从1开始。
	 * @returns 元素的值。
	 */
	get(index: number): Item;

	/**
	 * 将元素添加到数组的末尾。
	 * @param item 要添加的元素。
	 */
	add(item: Item): void;

	/**
	 * 在给定索引处插入元素，将其他元素向右移动。
	 * @param index 要插入的索引。
	 * @param item 要插入的元素。
	 */
	insert(index: number, item: Item): void;

	/**
	 * 检查数组是否包含给定的元素。
	 * @param item 要检查的元素。
	 * @returns 如果找到元素，则返回true，否则返回false。
	 */
	contains(item: Item): boolean;

	/**
	 * 获取给定元素的索引。
	 * @param item 要搜索的元素。
	 * @returns 元素的索引，如果未找到，则为0。
	 */
	index(item: Item): number;

	/**
	 * 移除并返回数组中的最后一个元素。
	 * @returns 数组中的最后一个元素。
	 */
	removeLast(): Item;

	/**
	 * 从数组中移除第一次出现的特定元素，会改变剩余元素的顺序。
	 * @param item 要移除的元素。
	 * @returns 如果找到并移除了元素，则返回true，否则返回false。
	 */
	fastRemove(item: Item): boolean;

	/**
	 * 使用[]运算符获取给定索引处的元素。
	 * @param index 要访问的索引，从0开始。
	 * @returns 元素的值。
	 */
	[index: number]: Item | undefined;
}

export type {Array as ArrayType};

/**
 * 用于创建数组对象的类。
 */
interface ArrayClass {
	/**
	 * 创建新的空数组对象。
	 * @returns 新的数组对象。
	*/
	(this: void): Array;

	/**
	 * 以Lua数组表初始化创建新的数组对象。
	 * @param items 用于初始化数组对象的数组表。
	 * @returns 新的数组对象。
	*/
	(this: void, items: Item[]): Array;
}

const arrayClass: ArrayClass;
export {arrayClass as Array};

/**
 * 表示音频播放器单例对象。
 */
class Audio {
	private constructor();

	/**
	 * 播放音效并返回音频的处理器。
	 *
	 * @param filename 音效文件的路径（必须是WAV文件）。
	 * @param loop 是否循环播放音效。默认为false。
	 * @returns 音频的处理器，可以用来停止音效。
	 */
	play(filename: string, loop?: boolean): number;

	/**
	 * 停止当前正在播放的音效。
	 *
	 * @param handler 由 `play` 函数返回的音频处理器。
	 */
	stop(handler: number): void;

	/**
	 * 播放流式音频文件。
	 *
	 * @param filename 流式音频文件的路径（可以是OGG、WAV、MP3或FLAC）。
	 * @param loop 是否循环播放流式音频。默认为false。
	 * @param crossFadeTime 在前和新的流式音频之间交叉淡入淡出的时间（以秒为单位）。默认为0.0。
	 */
	playStream(filename: string, loop?: boolean, crossFadeTime?: number): void;

	/**
	 * 停止当前正在播放的流式音频文件。
	 *
	 * @param fadeTime 淡出流式音频的时间（以秒为单位）。默认为0.0。
	 */
	stopStream(fadeTime?: number): void;
}

const audio: Audio;
export {audio as Audio};

/**
 * 用于渲染的混合函数对象。
 */
type BlendFunc = BasicType<'BlendFunc'>;

/**
 * 定义混合函数的枚举。
 */
export const enum BlendOp {
	/**
	 * 源颜色乘以 1 并加到目标颜色上（源颜色绘制在目标颜色之上）。
	 */
	One = "One",

	/**
	 * 源颜色乘以 0 并加到目标颜色上（源颜色对目标颜色没有影响）。
	 */
	Zero = "Zero",

	/**
	 * 源颜色乘以源 alpha 值，加到目标颜色乘以（1 - 源 alpha 值）上。
	 */
	SrcColor = "SrcColor",

	/**
	 * 源 alpha 值乘以源颜色，加到目标 alpha 值乘以（1 - 源 alpha 值）上。
	 */
	SrcAlpha = "SrcAlpha",

	/**
	 * 目标颜色乘以目标 alpha 值，加到源颜色乘以（1 - 目标 alpha 值）上。
	 */
	DstColor = "DstColor",

	/**
	 * 目标 alpha 值乘以源 alpha 值，加到源 alpha 值乘以（1 - 目标 alpha 值）上。
	 */
	DstAlpha = "DstAlpha",

	/**
	 * 类似于 "SrcColor"，但是交换源颜色和目标颜色做计算。
	 */
	InvSrcColor = "InvSrcColor",

	/**
	 * 类似于 "SrcAlpha"，但是交换源 alpha 值和目标 alpha 值做计算。
	 */
	InvSrcAlpha = "InvSrcAlpha",

	/**
	 * 类似于 "DstColor"，但是交换源颜色和目标颜色做计算。
	 */
	InvDstColor = "InvDstColor",

	/**
	 * 类似于 "DstAlpha"，但是交换源 alpha 值和目标 alpha 值做计算。
	 */
	InvDstAlpha = "InvDstAlpha"
}

export type {BlendFunc as BlendFuncType};

/**
 * 用于创建混合函数对象的类。
 */
interface BlendFuncClass {
	/**
	 * 获取混合函数的参数值。
	 * @param func 要获取参数值的混合函数。
	 * @returns 混合函数的参数值。
	 */
	get(func: BlendOp): number;

	/**
	 * 创建新的混合函数对象。
	 * @param src 源混合函数。
	 * @param dst 目标混合函数。
	 * @returns 新的混合函数对象。
	 */
	(this: void, src: BlendOp, dst: BlendOp): BlendFunc;

	/**
	 * 创建新的混合函数对象。
	 * @param srcColor 颜色通道的源混合因子。
	 * @param dstColor 颜色通道的目标混合因子。
	 * @param srcAlpha alpha通道的源混合因子。
	 * @param dstAlpha alpha通道的目标混合因子。
	 * @returns 新的混合函数对象。
	 */
	(this: void, srcColor: BlendOp, dstColor: BlendOp, srcAlpha: BlendOp, dstAlpha: BlendOp): BlendFunc;

	/**
	 * 默认的混合函数。
	 * 等于 `BlendFunc(BlendOp.SrcAlpha, BlendOp.InvSrcAlpha, BlendOp.One, BlendOp.InvSrcAlpha)`。
	 */
	readonly default: BlendFunc;
}

const blendFuncClass: BlendFuncClass;
export {blendFuncClass as BlendFunc};

/**
* 表示协程作业类型。
*/
export type Job = BasicType<"Job", LuaThread>;

/**
 * 用于管理协程作业的单例接口。
 */
interface Routine {
	/**
	 * 从集合中移除协程作业，并关闭仍在运行状态的作业。
	 * @param job 要移除的Job实例。
	 * @returns 如果作业被移除，则返回true，否则返回false。
	 */
	remove(job: Job): boolean;

	/**
	 * 移除所有协程作业，并关闭仍在运行状态的作业。
	 */
	clear(): void;

	/**
	 * 用于添加新的协程作业。
	 * @param job 要添加的协程作业实例。
	 * @returns 被添加的协程作业实例。
	 */
	(this: void, job: Job): Job;
}

const routine: Routine;
export {routine as Routine};

/**
 * 从函数创建新的协程并执行它。
 * @param routine 作为协程执行的函数。
 * @returns 创建的协程作业对象。
 */
export function thread(this: void, routine: (this: void) => boolean): Job;

/**
 * 从函数创建新的协程，该函数会反复运行。
 * @param routine 作为协程反复执行的函数。
 * @returns 创建的协程作业对象。
 */
export function threadLoop(this: void, routine: (this: void) => boolean): Job;

/**
 * 使另一个函数在一段时间内每帧重复执行。
 * @param duration 周期的持续时间，以秒为单位。
 * @param work 在周期内每帧反复执行的函数，接收从0到1的时间值，表示执行进度。
 */
export function cycle(this: void, duration: number, work: (this: void, time: number) => void): void;

/**
 * 创建只运行一次的协程作业。
 * @param routine 当协程恢复时执行一次的例程函数。
 * 在例程函数内部产生或返回true以在半途停止作业执行。
 * @returns 运行给定例程函数一次的协程。
 */
export function once(this: void, routine: (this: void) => void): Job;

/**
 * 创建协程作业，该作业将重复运行，直到满足某个条件为止。
 * @param routine 作业处理函数，将重复执行，直到它返回true以停止作业执行。
 * @returns 重复运行给定例程函数的协程。
 */
export function loop(this: void, routine: (this: void) => boolean): Job;

/**
 * 在协程中等待，直到条件为真。
 * @param condition 当条件满足时返回true的函数。
 */
export function wait(this: void, condition: (this: void) => boolean): void;

/**
 * 使协程暂停指定的持续时间。
 * @param duration 要暂停的持续时间，以秒为单位。如果未提供，协程将暂停到下一帧。
 */
export function sleep(this: void, duration?: number): void;

/**
 * 用于管理调度任务执行的调度器类。
 * 继承自 `Object`。
 */
class Scheduler extends Object {
	private constructor();

	/**
	 * 调度器的时间缩放因子。
	 * 此因子应用于调度函数将接收的deltaTime。
	 */
	timeScale: number;

	/**
	 * 固定更新模式的目标帧率（以每秒帧数表示）。
	 * 固定更新将确保恒定的帧率，处理在固定更新中的操作可以使用恒定的delta时间值。
	 * 它用于防止物理引擎产生奇怪的行为或者通过网络通信来同步一些状态。
	 */
	fixedFPS: number;

	/**
	 * 安排函数在每一帧被调用。
	 * @param handler 要调用的函数。它应该接受数值的参数，表示自上一帧以来的时间间隔。
	 * 如果函数返回true，它将不再被调度。
	 */
	schedule(handler: (this: void, deltaTime: number) => boolean): void;

	/**
	 * 安排协程作业在每一帧被调度。
	 * @param job 要调度的协程作业。
	 */
	schedule(job: Job): void;
}

export type {Scheduler as SchedulerType};

/**
* 用于创建调度器对象的类。
*/
interface SchedulerClass {
	/**
	 * 创建新的调度器对象。
	 * @returns 新创建的调度器对象。
	 */
	(this: void): Scheduler;
}

const scheduler: SchedulerClass;
export {scheduler as Scheduler};

/**
 * 用字符串键和对应值存储数据的字典类。
 */
class Dictionary extends Object {
	private constructor();

	/**
	 * 字典储存的键值对总数。
	 */
	readonly count: number;

	/**
	 * 字典中所有键的列表。
	 */
	readonly keys: string[];

	/**
	 * 访问字典数据的方法。
	 * @param key 要检索的字典的键。
	 * @returns 字典里存储的值，如果不存在则为undefined。
	 */
	get(key: string): Item | undefined;

	/**
	 * 设置字典里的值的方法。
	 * @param key 要设置的字典的键。
	 * @param item 要在字典里存储的值，设置为undefined以删除此键值对。
	 */
	set(key: string, item: Item): void;

	/**
	 * 遍历字典中每个键值对并调用处理函数。
	 * @param func 对字典中每个键值对调用的函数。
	-- 此函数会接收值对象Item和字符串的键作为参数，并需要返回布尔值。返回true停止遍历，false继续。
	-- @returns 如果遍历成功完成，则返回false，否则返回true。
	 */
	each(func: (this: void, item: Item, key: string) => boolean): boolean;

	/**
	 * 从字典中删除所有键值对。
	 */
	clear(): void;

	/**
	 * 允许使用索引表示法访问字典中的项目，例如 "dict['key']" 或 "dict.key"。
	 * @param key 要检索的字典的键。
	 * @returns 字典里存储的值，如果不存在则为undefined。
	 */
	[key: string]: Item | undefined;
}

export type {Dictionary as DictionaryType};

/**
 * 用于创建Dictionary的类
 * @example
 * ```
 * import { Dictionary } from "dora";
 * const dict = Dictionary();
 * ```
 */
interface DictionaryClass {
	/**
	 * 创建"Dictionary"类型的实例。
	 * @returns Dictionary类型的新实例。
	 */
	(this: void): Dictionary;
}

const dictionaryClass: DictionaryClass;
export {dictionaryClass as Dictionary};

/**
 * 用于监听处理节点事件的信号槽对象类。
 */
class Slot extends Object {
	private constructor();

	/**
	 * 向此信号槽添加新的处理函数。
	 * @param handler 要添加的处理函数。
	 */
	add(handler: (this: void, ...args: any[]) => void): void;

	/**
	 * 为此信号槽设置新的处理函数，替换任何现有的处理程序。
	 * @param handler 要设置的处理函数。
	 */
	set(handler: (this: void, ...args: any[]) => void): void;

	/**
	 * 从此信号槽中移除先前添加的处理函数。
	 * @param handler 要移除的处理函数。
	 */
	remove(handler: (this: void, ...args: any[]) => void): void;

	/**
	 * 清除此信号槽中的所有处理函数。
	 */
	clear(): void;
}

/**
 * 用于监听处理全局事件信号槽对象
 */
class GSlot extends Object {
	private constructor();

	/** 全局事件信号槽的名称 */
	readonly name: string;

	/** 全局事件信号槽当前是否启用或禁用 */
	enabled: boolean;
}

/**
 * 代表触摸输入或鼠标点击事件的类。
 */
class Touch extends Object {
	private constructor();

	/**
	 * 是否启用该触摸输入。
	 */
	enabled: boolean;

	/**
	 * 触摸事件是否源自鼠标点击。
	 */
	readonly fromMouse: boolean;

	/**
	 * 当存在多个触摸时，此触摸事件是否为第一个。
	 */
	readonly first: boolean;

	/**
	 * 分配给此触摸事件的唯一标识符。
	 */
	readonly id: number;

	/**
	 * 自上次触摸事件以来的移动量和方向。
	 */
	readonly delta: Vec2;

	/**
	 * 触摸事件在节点的本地坐标系统中的位置。
	 */
	readonly location: Vec2;

	/**
	 * 触摸事件在世界坐标系统中的位置。
	 */
	readonly worldLocation: Vec2;
}

/**
 * 游戏引擎中的摄像机对象的类。
 */
class Camera extends Object {
	protected constructor();

	/**
	 * 摄像机的名称。
	 */
	readonly name: string;
}

export type {Camera as CameraType};

/**
 * 游戏引擎中的2D摄像机对象的类。
 */
class Camera2D extends Camera {
	private constructor();

	/**
	 * 摄像机的旋转角度，单位为度。
	 */
	rotation: number;

	/**
	 * 缩放摄像机的因子。如果设置为1.0，视图大小为正常。如果设置为2.0，物品将以双倍大小显示。
	 */
	zoom: number;

	/**
	 * 摄像机在游戏世界中的位置。
	 */
	position: Vec2;
}

export type {Camera2D as Camera2DType};

/**
* 用于创建2D摄像机对象的类。
*/
interface Camera2DClass {
	/**
	 * 使用给定的名称创建新的2D摄像机对象。
	 * @param name 2D摄像机对象的名称。默认为空字符串。
	 * @returns 2D摄像机对象的新实例。
	 */
	(this: void, name?: string): Camera2D;
}

const camera2DClass: Camera2DClass;
export {camera2DClass as Camera2D};

/**
 * 游戏引擎中的正交摄像机对象的类。
 */
class CameraOtho extends Camera {
	private constructor();

	/**
	 * 摄像机在游戏世界中的位置。
	 */
	position: Vec2;
}

export type {CameraOtho as CameraOthoType};

/**
* 用于创建正交摄像机对象的类。
*/
interface CameraOthoClass {
	/**
	 * 使用给定的名称创建新的正交摄像机对象。
	 * @param name 正交摄像机对象的名称。默认为空字符串。
	 * @returns 正交摄像机对象的新实例。
	 */
	(this: void, name?: string): CameraOtho;
}

const cameraOthoClass: CameraOthoClass;
export {cameraOthoClass as CameraOtho};

/**
 * 代表着色器渲染流程的类。
 */
class Pass extends Object {
	private constructor();

	/**
	 * 是否应该是采样流程。
	 * 采样流程将会把游戏场景渲染到纹理缓存中。
	 * 然后将该纹理帧缓存用作下一次渲染流程的输入。
	 */
	grabPass: boolean;

	/**
	 * 用于设置着色器参数值的函数。
	 *
	 * @param name 要设置的参数的名称。
	 * @param var1 要设置的第一个数值。
	 * @param var2 可选的要设置的第二个数值（默认为0）。
	 * @param var3 可选的要设置的第三个数值（默认为0）。
	 * @param var4 可选的要设置的第四个数值（默认为0）。
	 */
	set(name: string, var1: number, var2?: number, var3?: number, var4?: number): void;

	/**
	 * 另一个设置着色器参数值的函数。
	 * 等同于 `pass.set("varName", color.r / 255.0, color.g / 255.0, color.b / 255.0, color.opacity)`
	 *
	 * @param name 要设置的参数的名称。
	 * @param cvar 要设置的Color对象。
	 */
	set(name: string, cvar: Color): void;
}

export type {Pass as PassType};

/**
* 用于创建着色器渲染流程对象的类。
*/
interface PassClass {
	/**
	 * 用于创建新的渲染流程对象的方法。
	 *
	 * @param vertShader 顶点着色器的二进制形式文件字符串。
	 * @param fragShader 片段着色器文件字符串。
	 * 着色器文件字符串必须是以下格式之一：
	 * 	"builtin:" + 内置着色器名称
	 * 	"Shader/compiled_shader_file.bin"
	 * @returns 新的着色器渲染流程对象。
	 */
	(this: void, vertShader: string, fragShader: string): Pass;
}

const passClass: PassClass;
export {passClass as Pass};

/**
 * 用于管理多个渲染通道对象的类。
 * Effect对象允许你组合多个通道以创建更复杂的着色器效果。
 */
class Effect extends Object {
	protected constructor();

	/**
	 * 函数，将Pass对象添加到此Effect。
	 * @param pass 要添加的Pass对象。
	 */
	add(pass: Pass): void;

	/**
	 * 函数，通过索引从此Effect中检索Pass对象。
	 * @param index 要检索的Pass对象的索引。
	 * @returns 给定索引处的Pass对象。
	 */
	get(index: number): Pass;

	/**
	 * 函数，从此Effect中移除所有Pass对象。
	 */
	clear(): void;
}

export type {Effect as EffectType};

/**
* 用于创建Effect对象的类。
*/
interface EffectClass {
	/**
	 * 创建新的Effect对象。
	 * @param vertShader 顶点着色器文件字符串。
	 * @param fragShader 片段着色器文件字符串。
	 * 着色器文件字符串必须是以下格式之一：
	 * 	"builtin:" + 内置着色器名称
	 * 	"Shader/compiled_shader_file.bin"
	 * @returns 新的Effect对象。
	 */
	(this: void, vertShader: string, fragShader: string): Effect;

	/**
	 * 创建新的空Effect对象。
	 * @returns 新的空Effect对象。
	 */
	(this: void): Effect;
}

const effectClass: EffectClass;
export {effectClass as Effect};

/**
 * 专门用于渲染2D图元的着色器特效类。
 */
class SpriteEffect extends Effect {}

export type {SpriteEffect as SpriteEffectType};

/**
 * 用于创建新的2D图元着色器特效的类。
 */
interface SpriteEffectClass {
	/**
	 * 创建新的2D图元着色器特效对象。
	 * @param vertShader 顶点着色器文件字符串。
	 * 着色器文件名字符串必须是以下格式之一：
	 * 	"builtin:" + theBuiltinShaderName
	 * 	"Shader/compiled_shader_file.bin"
	 * @param fragShader 片段着色器文件字符串。
	 * @returns 新的2D图元着色器特效对象。
	 */
	(this: void, vertShader: string, fragShader: string): SpriteEffect;

	/**
	 * 创建空的2D图元着色器特效对象。
	 * @returns 新的2D图元着色器特效对象。
	 */
	(this: void): SpriteEffect;
}

const spriteEffectClass: SpriteEffectClass;
export {spriteEffectClass as SpriteEffect};

/**
 * 定义键盘按键的枚举。
 */
export const enum KeyName {
	Return = "Return",
	Escape = "Escape",
	BackSpace = "BackSpace",
	Tab = "Tab",
	Space = "Space",
	Exclamation = "!",
	DoubleQuote = "\"",
	Hash = "#",
	Percent = "%",
	Dollar = "$",
	Ampersand = "&",
	SingleQuote = "'",
	LeftParenthesis = "(",
	RightParenthesis = ")",
	Asterisk = "*",
	Plus = "+",
	Comma = ",",
	Minus = "-",
	Dot = ".",
	Slash = "/",
	Num1 = "1",
	Num2 = "2",
	Num3 = "3",
	Num4 = "4",
	Num5 = "5",
	Num6 = "6",
	Num7 = "7",
	Num8 = "8",
	Num9 = "9",
	Num0 = "0",
	Colon = ":",
	Semicolon = ";",
	LessThan = "<",
	Equal = "=",
	GreaterThan = ">",
	Question = "?",
	At = "@",
	LeftBracket = "[",
	Backslash = "\\",
	RightBracket = "]",
	Caret = "^",
	Underscore = "_",
	Backquote = "`",
	A = "A",
	B = "B",
	C = "C",
	D = "D",
	E = "E",
	F = "F",
	G = "G",
	H = "H",
	I = "I",
	J = "J",
	K = "K",
	L = "L",
	M = "M",
	N = "N",
	O = "O",
	P = "P",
	Q = "Q",
	R = "R",
	S = "S",
	T = "T",
	U = "U",
	V = "V",
	W = "W",
	X = "X",
	Y = "Y",
	Z = "Z",
	Delete = "Delete",
	CapsLock = "CapsLock",
	F1 = "F1",
	F2 = "F2",
	F3 = "F3",
	F4 = "F4",
	F5 = "F5",
	F6 = "F6",
	F7 = "F7",
	F8 = "F8",
	F9 = "F9",
	F10 = "F10",
	F11 = "F11",
	F12 = "F12",
	PrintScreen = "PrintScreen",
	ScrollLock = "ScrollLock",
	Pause = "Pause",
	Insert = "Insert",
	Home = "Home",
	PageUp = "PageUp",
	End = "End",
	PageDown = "PageDown",
	Right = "Right",
	Left = "Left",
	Down = "Down",
	Up = "Up",
	Application = "Application",
	LCtrl = "LCtrl",
	LShift = "LShift",
	LAlt = "LAlt",
	LGui = "LGui",
	RCtrl = "RCtrl",
	RShift = "RShift",
	RAlt = "RAlt",
	RGui = "RGui"
}

/**
 * 用于处理键盘输入的单例类接口。
 */
interface Keyboard {
	/**
	 * 检查在当前帧中是否按下了键。
	 * @param name 要检查的键的名称。
	 * @returns 键是否被按下。
	 */
	isKeyDown(name: KeyName): boolean;

	/**
	 * 检查在当前帧中是否释放了键。
	 * @param name 要检查的键的名称。
	 * @returns 键是否被释放。
	 */
	isKeyUp(name: KeyName): boolean;

	/**
	 * 检查键是否处于按下状态。
	 * @param name 要检查的键的名称。
	 * @returns 键是否处于按下状态。
	 */
	isKeyPressed(name: KeyName): boolean;

	/**
	 * 更新输入法编辑器（IME）位置提示。
	 * @param winPos 键盘窗口的位置。
	 */
	updateIMEPosHint(winPos: Vec2): void;
}

const keyboard: Keyboard;
export {keyboard as Keyboard};

/**
 * 用于定义控制器轴名称的枚举。
 */
export const enum AxisName {
	leftx = "leftx",
	lefty = "lefty",
	rightx = "rightx",
	righty = "righty",
	lefttrigger = "lefttrigger",
	righttrigger = "righttrigger"
}

/**
* 用于定义控制器按钮名称的枚举。
*/
export const enum ButtonName {
	a = "a",
	b = "b",
	back = "back",
	dpdown = "dpdown",
	dpleft = "dpleft",
	dpright = "dpright",
	dpup = "dpup",
	leftshoulder = "leftshoulder",
	leftstick = "leftstick",
	rightshoulder = "rightshoulder",
	rightstick = "rightstick",
	start = "start",
	x = "x",
	y = "y"
}

/**
 * 用于处理游戏控制器输入的单例类接口。
 */
interface Controller {
	/**
	 * 检查在当前帧中是否按下了按钮。
	 * @param controllerId 控制器id，当连接多个控制器时从0开始递增。
	 * @param name 要检查的按钮的名称。
	 * @returns 按钮是否被按下。
	 */
	isButtonDown(controllerId: number, name: ButtonName): boolean;

	/**
	 * 检查在当前帧中是否释放了按钮。
	 * @param controllerId 控制器id，当连接多个控制器时从0开始递增。
	 * @param name 要检查的按钮的名称。
	 * @returns 按钮是否被释放。
	 */
	isButtonUp(controllerId: number, name: ButtonName): boolean;

	/**
	 * 检查按钮是否处于按下状态。
	 * @param controllerId 控制器id，当连接多个控制器时从0开始递增。
	 * @param name 要检查的按钮的名称。
	 * @returns 按钮是否处于按下状态。
	 */
	isButtonPressed(controllerId: number, name: ButtonName): boolean;

	/**
	 * 从给定的控制器获取轴值。
	 * @param controllerId 控制器id，当连接多个控制器时从0开始递增。
	 * @param name 要检查的控制器轴的名称。
	 * @returns 轴值的范围从-1.0到1.0。
	 */
	getAxis(controllerId: number, name: AxisName): number;
}

const controller: Controller;
export {controller as Controller};

/**
 * 将场景的一部分节点渲染到一张绑定到网格的纹理上的抓取器类。
 */
class Grabber extends Object {
	private constructor();

	/**
	* 用于渲染网格的相机。
	*/
	camera: Camera;

	/**
	* 应用于网格的图元着色器特效。
	*/
	effect: SpriteEffect;

	/**
	* 应用于网格的混合函数。
	*/
	blendFunc: BlendFunc;

	/**
	* 用于清空纹理的清除颜色。
	*/
	clearColor: Color;

	/**
	* 设置抓取器网格中顶点的位置。
	* @param x 抓取器网格中顶点的x索引。
	* @param y 抓取器网格中顶点的y索引。
	* @param pos 顶点的新位置。
	* @param z [可选] 顶点的新z坐标（默认：0.0）。
	*/
	setPos(x: number, y: number, pos: Vec2, z?: number): void;

	/**
	* 获取抓取器网格中顶点的位置。
	* @param x 抓取器网格中顶点的x索引。
	* @param y 抓取器网格中顶点的y索引。
	* @returns 顶点的位置。
	*/
	getPos(x: number, y: number): Vec2;

	/**
	* 获取抓取器网格中顶点的颜色。
	* @param x 抓取器网格中顶点的x索引。
	* @param y 抓取器网格中顶点的y索引。
	* @returns 顶点的颜色。
	*/
	getColor(x: number, y: number): Color;

	/**
	* 设置抓取器网格中顶点的颜色。
	* @param x 抓取器网格中顶点的x索引。
	* @param y 抓取器网格中顶点的y索引。
	* @param color 顶点的新颜色。
	*/
	setColor(x: number, y: number, color: Color): void;
}

const enum NodeEvent {
	ActionEnd = "ActionEnd",
	TapFilter = "TapFilter",
	TapBegan = "TapBegan",
	TapEnded = "TapEnded",
	Tapped = "Tapped",
	TapMoved = "TapMoved",
	MouseWheel = "MouseWheel",
	Gesture = "Gesture",
	Enter = "Enter",
	Exit = "Exit",
	Cleanup = "Cleanup",
	KeyDown = "KeyDown",
	KeyUp = "KeyUp",
	KeyPressed = "KeyPressed",
	AttachIME = "AttachIME",
	DetachIME = "DetachIME",
	TextInput = "TextInput",
	TextEditing = "TextEditing",
	ButtonDown = "ButtonDown",
	ButtonUp = "ButtonUp",
	Axis = "Axis",
	AnimationEnd = "AnimationEnd",
	BodyEnter = "BodyEnter",
	BodyLeave = "BodyLeave",
	ContactStart = "ContactStart",
	ContactEnd = "ContactEnd",
	Finished = "Finished",
}

export {NodeEvent as Slot};

interface NodeEventHandlerMap {
	/**
	 * ActionEnd事件会在节点执行完动作时触发。
	 * 在`node.runAction()`和`node.perform()`之后触发。
	 * @param action 执行完成的动作。
	 * @param target 执行完成动作的节点。
	 */
	ActionEnd(this: void, action: Action, target: Node): void;

	/**
	 * TapFilter事件在TapBegan插槽之前触发，可用于过滤某些点击事件。
	 * 在设置`node.touchEnabled = true`之后才会触发。
	 * @param touch 点击事件的消息对象。
	*/
	TapFilter(this: void, touch: Touch): void;

	/**
	 * TapBegan事件在检测到点击时触发。
	 * 在设置`node.touchEnabled = true`之后才会触发。
	 * @param touch 点击事件的消息对象。
	*/
	TapBegan(this: void, touch: Touch): void;

	/**
	 * TapEnded事件在点击结束时触发。
	 * 在设置`node.touchEnabled = true`之后才会触发。
	 * @param touch 点击事件的消息对象。
	*/
	TapEnded(this: void, touch: Touch): void;

	/**
	 * Tapped事件在检测到并结束点击时触发。
	 * 在设置`node.touchEnabled = true`之后才会触发。
	 * @param touch 点击事件的消息对象。
	*/
	Tapped(this: void, touch: Touch): void;

	/**
	 * TapMoved事件在点击移动时触发。
	 * 在设置`node.touchEnabled = true`之后才会触发。
	 * @param touch 点击事件的消息对象。
	*/
	TapMoved(this: void, touch: Touch): void;

	/**
	 * MouseWheel事件在滚动鼠标滚轮时触发。
	 * 在设置`node.touchEnabled = true`之后才会触发。
	 * @param delta 滚动的向量。
	*/
	MouseWheel(this: void, delta: Vec2): void;

	/**
	 * Gesture事件在识别到多点手势时触发。
	 * 在设置`node.touchEnabled = true`之后才会触发。
	 * @param center 手势的中心点。
	 * @param numFingers 手势涉及的触摸点数量。
	 * @param deltaDist 手势移动的距离。
	 * @param deltaAngle 手势的变动角度。
	*/
	Gesture(this: void, center: Vec2, numFingers: number, deltaDist: number, deltaAngle: number): void;

	/**
	 * 当节点被添加到场景树中时，触发Enter事件。
	 * 当执行`node.addChild()`时触发。
	*/
	Enter(this: void): void;

	/**
	 * 当节点从场景树中移除时，触发Exit事件。
	 * 当执行`parent.removeChild()`时触发。
	*/
	Exit(this: void): void;

	/**
	 * 当节点被清理时，触发Cleanup事件。
	 * 仅当执行`parent.removeChild(node, true)`时触发。
	*/
	Cleanup(this: void): void;

	/**
	 * 当按下某个键盘按键时，触发KeyDown事件。
	 * 在设置`node.keyboardEnabled = true`后才会触发。
	 * @param keyName 被按下的键的名称。
	*/
	KeyDown(this: void, keyName: KeyName): void;

	/**
	 * 当释放某个键盘按键时，触发KeyUp事件。
	 * 在设置`node.keyboardEnabled = true`后才会触发。
	 * @param keyName 被释放的键的名称。
	*/
	KeyUp(this: void, keyName: KeyName): void;

	/**
	 * 当持续按下某个键时，触发KeyPressed事件。
	 * 在设置`node.keyboardEnabled = true`后才会触发。
	 * @param keyName 被持续按下的键的名称。
	*/
	KeyPressed(this: void, keyName: KeyName): void;

	/**
	 * 当系统输入法（IME）开启到节点（调用`node: attachIME()`）时，会触发AttachIME事件。
	*/
	AttachIME(this: void): void;

	/**
	 * 当系统输入法（IME）关闭（调用`node: detachIME()`或手动关闭IME）时，会触发DetachIME事件。
	*/
	DetachIME(this: void): void;

	/**
	 * 当接收到系统输入法文本输入时，会触发TextInput事件。
	 * 在调用`node.attachIME()`之后触发。
	 * @param text 输入的文本。
	*/
	TextInput(this: void, text: string): void;

	/**
	 * 当系统输入法文本正在被编辑时，会触发TextEditing事件。
	 * 在调用`node:attachIME()`之后触发。
	 * @param text 正在编辑的文本。
	 * @param startPos 正在编辑的文本的起始位置。
	*/
	TextEditing(this: void, text: string, startPos: number): void;

	/**
	 * 当游戏控制器按钮被按下时触发ButtonDown事件。
	 * 在设置`node.controllerEnabled = true`之后触发。
	 * @param controllerId 控制器ID，当有多个控制器连接时从0开始递增。
	 * @param buttonName 被按下的按钮名称。
	*/
	ButtonDown(this: void, controllerId: number, buttonName: ButtonName): void;

	/**
	 * 当游戏控制器按钮被释放时触发ButtonUp事件。
	 * 在设置`node.controllerEnabled = true`之后触发。
	 * @param controllerId 控制器ID，当有多个控制器连接时从0开始递增。
	 * @param buttonName 被释放的按钮名称。
	*/
	ButtonUp(this: void, controllerId: number, buttonName: ButtonName): void;

	/**
	 * 当游戏控制器轴发生变化时触发Axis事件。
	 * 在设置`node.controllerEnabled = true`之后触发。
	 * @param controllerId 控制器ID，当有多个控制器连接时从0开始递增。
	 * @param axisValue 控制器轴的值，范围从 -1.0 到 1.0。
	*/
	Axis(this: void, controllerId: number, axisValue: number): void;

	/**
	 * 当Playable动画模型播放结束动画后触发。
	 * @param animationName 播放结束的动画名称。
	 * @param target 播放该动画的动画模型实例。
	*/
	AnimationEnd(this: void, animationName: string, target: Playable): void;

	/**
	 * 当物理体对象与传感器对象碰撞时触发。
	 * 在设置`body.receivingContact = true`之后触发。
	 * @param other 当前发生碰撞的物理体对象。
	 * @param sensorTag 触发此碰撞事件的传感器的标签编号。
	*/
	BodyEnter(this: void, other: Body, sensorTag: number): void;

	/**
	 * 当物理体对象不再与传感器对象碰撞时触发。
	 * 在设置`body.receivingContact = true`之后触发。
	 * @param other 当前结束碰撞的物理体对象。
	 * @param sensorTag 触发此碰撞事件的传感器的标签。
	*/
	BodyLeave(this: void, other: Body, sensorTag: number): void;

	/**
	 * 当物理体对象开始与另物理体碰撞时触发。
	 * 在设置`body.receivingContact = true`之后触发。
	 * @param other 被碰撞的物理体对象。
	 * @param point 世界坐标系中的碰撞点。
	 * @param normal 世界坐标系中的接触表面法向量。
	*/
	ContactStart(this: void, other: Body, point: Vec2, normal: Vec2): void;

	/**
	 * 当一个物理体对象停止与另一个物理体碰撞时触发。
	 * 在设置`body.receivingContact = true`之后触发。
	 * @param other 结束碰撞的物理体对象。
	 * @param point 世界坐标系中的碰撞点。
	 * @param normal 世界坐标系中的接触表面法向量。
	*/
	ContactEnd(this: void, other: Body, point: Vec2, normal: Vec2): void;

	/**
	 * 当粒子系统节点在启动之后又停止发射粒子，并等待所有已发射的粒子结束它们的生命周期时触发。
	*/
	Finished(this: void): void;
}

const enum GlobalEvent {
	AppQuit = "AppQuit",
	AppLowMemory = "AppLowMemory",
	AppWillEnterBackground = "AppWillEnterBackground",
	AppDidEnterBackground = "AppDidEnterBackground",
	AppWillEnterForeground = "AppWillEnterForeground",
	AppDidEnterForeground = "AppDidEnterForeground",
	AppSizeChanged = "AppSizeChanged",
	AppFullScreen = "AppFullScreen",
	AppMoved = "AppMoved",
	AppTheme = "AppTheme",
	AppWSOpen = "AppWSOpen",
	AppWSClose = "AppWSClose",
	AppWSMessage = "AppWSMessage",
	AppWSSend = "AppWSSend"
}

export {GlobalEvent as GSlot};

type GlobalEventHandlerMap = {
	/** 应用即将退出时触发。 */
	AppQuit(this: void): void;

	/** 应用接收到低内存警告时触发。 */
	AppLowMemory(this: void): void;

	/** 应用即将进入后台时触发。 */
	AppWillEnterBackground(this: void): void;

	/** 应用已经进入后台时触发。 */
	AppDidEnterBackground(this: void): void;

	/** 应用即将进入前台时触发。 */
	AppWillEnterForeground(this: void): void;

	/** 应用已经进入前台时触发。 */
	AppDidEnterForeground(this: void): void;

	/** 应用窗口大小发生变化时触发。 */
	AppSizeChanged(this: void): void;

	/** 应用进入或退出全屏窗口模式时触发。 */
	AppFullScreen(this: void, fullScreen: boolean): void;

	/** 应用窗口位置发生变化时触发。 */
	AppMoved(this: void): void;

	/** 应用改变主题颜色时触发。 */
	AppTheme(this: void, themeColor: Color): void;

	/** 当一个客户端和应用建立 Websocket 连接时触发。 */
	AppWSOpen(this: void): void;

	/** 当一个客户端和应用断开 Websocket 连接时触发。 */
	AppWSClose(this: void): void;

	/** 当一个客户端向应用发送 Websocket 文本消息时触发。 */
	AppWSMessage(this: void, msg: string): void;

	/**
	 * 用于向所有已建立 Websocket 连接的客户端广播发送文本消息的事件。
	 * @example
	 * ```
	 * emit("AppWSSend", "A message");
	 * ```
	 */
	AppWSSend(this: void, msg: string): void;
};

/**
 * 用于构建游戏对象的层级树结构的类。
 */
class Node extends Object {
	protected constructor();

	/** 节点在父节点的子节点数组中的顺序。 */
	order: number;

	/** 节点的旋转角度，单位为度。 */
	angle: number;

	/** 节点的X轴旋转角度，单位为度。 */
	angleX: number;

	/** 节点的Y轴旋转角度，单位为度。 */
	angleY: number;

	/** 节点的X轴缩放因子。 */
	scaleX: number;

	/** 节点的Y轴缩放因子。 */
	scaleY: number;

	/** 节点的X轴位置。 */
	x: number;

	/** 节点的Y轴位置。 */
	y: number;

	/** 节点的Z轴位置。 */
	z: number;

	/** 节点的位置，为Vec2对象。 */
	position: Vec2;

	/** 节点的X轴倾斜角度，单位为度。 */
	skewX: number;

	/** 节点的Y轴倾斜角度，单位为度。 */
	skewY: number;

	/** 节点是否可见。 */
	visible: boolean;

	/** 节点的锚点，为Vec2对象。 */
	anchor: Vec2;

	/** 节点的宽度。 */
	width: number;

	/** 节点的高度。 */
	height: number;

	/** 节点的大小，为Size对象。 */
	size: Size;

	/** 节点的标签，为字符串类型。 */
	tag: string;

	/** 节点的透明度，应在0到1.0之间。 */
	opacity: number;

	/** 节点的颜色，为Color对象。 */
	color: Color;

	/** 节点的颜色，为Color3对象。 */
	color3: Color3;

	/** 是否将透明度值传递给子节点。 */
	passOpacity: boolean;

	/** 是否将颜色值传递给子节点。 */
	passColor3: boolean;

	/** 用于继承矩阵变换的目标节点。 */
	transformTarget: Node;

	/** 用于调度更新和动作回调的调度器。 */
	scheduler: Scheduler;

	/** 节点是否有子节点。 */
	readonly hasChildren: boolean;

	/** 节点的子节点，为Array对象，可能为nil。 */
	readonly children: Array;

	/** 节点的父节点。 */
	readonly parent: Node;

	/** 节点的边界框，为Rect对象。 */
	readonly boundingBox: Rect;

	/** 节点当前是否在场景树中运行。 */
	readonly running: boolean;

	/** 节点当前是否正在调度函数或协程进行更新。 */
	readonly scheduled: boolean;

	/** 当前在节点上运行的动作的数量。 */
	readonly actionCount: number;

	/** 以Dictionary对象形式存储在节点上的附加数据。 */
	readonly data: Dictionary;

	/** 节点上是否启用触摸事件。 */
	touchEnabled: boolean;

	/** 节点是否独占触摸事件。 */
	swallowTouches: boolean;

	/** 节点是否独占鼠标滚轮事件。 */
	swallowMouseWheel: boolean;

	/** 节点上是否启用键盘事件。 */
	keyboardEnabled: boolean;

	/** 节点上是否启用控制器事件。 */
	controllerEnabled: boolean;

	/** 是否将节点的渲染与其所有递归子项分组。 */
	renderGroup: boolean;

	/** 组渲染的渲染顺序号。渲染顺序较低的节点将更早渲染。 */
	renderOrder: number;

	/**
	 * 向当前节点添加子节点。
	 * @param child 要添加的子节点。
	 * @param order [可选] 子节点的绘制顺序。默认为0。
	 * @param tag [可选] 子节点的标签。默认为空字符串。
	 */
	addChild(child: Node, order?: number, tag?: string): void;

	/**
	 * 将当前节点添加到父节点。
	 * @param parent 要添加当前节点的父节点。
	 * @param order [可选] 当前节点的绘制顺序。默认为0。
	 * @param tag [可选] 当前节点的标签。默认为空字符串。
	 * @returns 当前节点。
	 */
	addTo<T>(this: T, parent: Node, order?: number, tag?: string): T;

	/**
	 * 从当前节点中移除子节点。
	 * @param child 要移除的子节点。
	 * @param cleanup [可选] 是否清理子节点。默认为true。
	 */
	removeChild(child: Node, cleanup?: boolean): void;

	/**
	 * 通过标签从当前节点中移除子节点。
	 * @param tag 要移除的子节点的标签。
	 * @param cleanup [可选] 是否清理子节点。默认为true。
	 */
	removeChildByTag(tag: string, cleanup?: boolean): void;

	/**
	 * 从当前节点中移除所有子节点。
	 * @param cleanup [可选] 是否清理子节点。默认为true。
	 */
	removeAllChildren(cleanup?: boolean): void;

	/**
	 * 从其父节点中移除当前节点。
	 * @param cleanup [可选] 是否清理当前节点。默认为true。
	 */
	removeFromParent(cleanup?: boolean): void;

	/**
	 * 将当前节点移动到新的父节点，而不触发节点事件。
	 * @param parent 要移动当前节点的新父节点。
	 */
	moveToParent(parent: Node): void;

	/**
	 * 清理当前节点。
	 */
	cleanup(): void;

	/**
	 * 通过标签获取子节点。
	 * @param tag 要获取的子节点的标签。
	 * @returns 子节点，如果未找到则为null。
	 */
	getChildByTag(tag: string): Node | null;

	/**
	 * 安排函数在每一帧运行。
	 * @param func 要运行的函数，返回true以停止。
	 */
	schedule(func: (this: void, deltaTime: number) => boolean): void;

	/**
	 * 安排协程开始运行。
	 * @param job 要运行的协程，返回或产出true以停止。
	 */
	schedule(job: Job): void;

	/**
	 * 取消当前节点在调度的函数或协程。
	 */
	unschedule(): void;

	/**
	 * 将世界空间中的坐标点转换为节点空间的坐标。
	 * @param worldPoint 要转换的点。
	 * @returns 转换后的点。
	 */
	convertToNodeSpace(worldPoint: Vec2): Vec2;

	/**
	 * 将世界空间中的坐标点转换为节点空间的坐标。
	 * @param worldPoint 要转换的点。
	 * @param z 点的z坐标。
	 * @returns 转换后的点和z坐标。
	 */
	convertToNodeSpace(worldPoint: Vec2, z: number): LuaMultiReturn<[Vec2, number]>;

	/**
	 * 将节点空间中的坐标点转换为世界空间的坐标。
	 * @param nodePoint 节点空间中的点。
	 * @returns 转换后的世界空间中的点。
	 */
	convertToWorldSpace(nodePoint: Vec2): Vec2;

	/**
	 * 将坐标点从节点空间转换到世界空间。
	 * @param nodePoint 节点空间中的点。
	 * @param z 节点空间中的z坐标。
	 * @returns 转换后的点和世界空间中的z坐标。
	 */
	convertToWorldSpace(nodePoint: Vec2, z: number): LuaMultiReturn<[Vec2, number]>;

	/**
	 * 将坐标点从节点空间转换到窗口空间。
	 * @param nodePoint 节点空间中的点。
	 * @param callback 接收窗口空间中转换后的点的回调函数。
	 */
	convertToWindowSpace(nodePoint: Vec2, callback: (this: void, windowPoint: Vec2) => void): void;

	/**
	 * 为此节点的每个子节点调用给定的函数。
	 * @param func 为每个子节点调用的函数。该函数应返回布尔值，表示是否继续迭代。返回true以停止迭代。
	 * @returns 如果所有子节点都已访问，则为False，如果函数中断了迭代，则为true。
	 */
	eachChild(func: (this: void, child: Node) => boolean): boolean;

	/**
	 * 从此节点开始遍历节点层次结构，并为每个访问的节点调用给定的函数。没有`TraverseEnabled`标志的节点不会被访问。
	 * @param func 为每个访问的节点调用的函数。该函数应返回布尔值，表示是否继续遍历。返回true以停止迭代。
	 * @returns 如果所有节点都已访问，则为False，如果函数中断了遍历，则为true。
	 */
	traverse(func: (this: void, node: Node) => boolean): boolean;

	/**
	 * 遍历从此节点开始的整个节点层次结构，并为每个访问的节点调用给定的函数。
	 * @param func 为每个访问的节点调用的函数。该函数应返回布尔值，表示是否继续遍历。
	 * @returns 如果所有节点都已访问，则为True，如果函数中断了遍历，则为false。
	 */
	traverseAll(func: (this: void, node: Node) => boolean): boolean;

	/**
	 * 在此节点上执行给定的动作。
	 * @param action 要执行的动作。
	 * @returns 新执行的动作的持续时间（以秒为单位）。
	 */
	runAction(action: Action): number;

	/**
	 * 在此节点上执行由给定动作定义的动作。
	 * @param actionDef 要执行的动作定义。
	 * @returns 新执行的动作的持续时间（以秒为单位）。
	 */
	runAction(actionDef: ActionDef): number;

	/**
	 * 停止在此节点上执行的所有动作。
	 */
	stopAllActions(): void;

	/**
	 * 立即执行给定的动作，而不将其添加到动作队列中。
	 * @param action 要执行的动作。
	 * @returns 新执行的动作的持续时间。
	 */
	perform(action: Action): number;

	/**
	 * 在清除所有之前执行的动作后，立即执行由给定动作定义的动作。
	 * @param actionDef 要执行的动作定义。
	 * @returns 新执行的动作的持续时间。
	 */
	perform(actionDef: ActionDef): number;

	/**
	 * 停止在此节点上执行的特定动作。
	 * @param action 要停止的动作。
	 */
	stopAction(action: Action): void;

	/**
	 * 使用特定的填充间隔垂直对齐排布此节点的所有子节点。
	 * @param padding [可选] 子节点之间的填充间隔。默认为10。
	 * @returns 排布后的区域大小。
	 */
	alignItemsVertically(padding?: number): Size;

	/**
	 * 使用特定的区域大小填充和垂直对齐排布节点内的所有子节点。
	 * @param size 填充区域的大小。
	 * @param padding [可选] 每个子节点之间使用的填充间隔（默认为10）。
	 * @returns 排布后的区域大小。
	 */
	alignItemsVertically(size: Size, padding?: number): Size;

	/**
	 * 使用特定的填充间隔横向对齐节点内的所有子节点。
	 * @param padding [可选] 每个子节点之间使用的填充间隔（默认为10）。
	 * @returns 排布后的区域大小。
	 */
	alignItemsHorizontally(padding?: number): Size;

	/**
	 * 使用特定的区域大小来填充并水平对齐排布节点内的所有子节点。
	 * @param size 填充区域的大小。
	 * @param padding [可选] 每个子节点之间使用的填充间隔（默认为10）。
	 * @returns 排布后的区域大小。
	 */
	alignItemsHorizontally(size: Size, padding?: number): Size;

	/**
	 * 使用特定的间隔来对齐排布节点内的所有子节点。
	 * @param padding [可选] 每个子节点之间使用的填充间隔（默认为10）。
	 * @returns 排布后的区域大小。
	 */
	alignItems(padding?: number): Size;

	/**
	 * 使用特定的区域大小来对齐和填充排布节点内的所有子节点。
	 * @param size 填充区域的大小。
	 * @param padding [可选] 每个子节点之间使用的填充间隔（默认为10）。
	 * @returns 排布后的区域大小。
	 */
	alignItems(size: Size, padding?: number): Size;

	/**
	 * 移动子节点，并根据它们是否超出父节点区域更改可见性。
	 * @param delta 移动其子节点的距离。
	 */
	moveAndCullItems(delta: Vec2): void;

	/**
	 * 将输入法编辑器（IME）附加到节点。
	 * 使节点接收 Slot.AttachIME，Slot.DetachIME，Slot.TextInput，Slot.TextEditing 事件。
	 */
	attachIME(): void;

	/**
	 * 从节点分离输入法编辑器（IME）。
	 */
	detachIME(): void;

	/**
	 * 获取与此节点中特定事件名称关联的全局事件监听器。
	 * @param eventName 全局事件的名称。
	 * @returns 与事件关联的所有全局事件监听器。
	 */
	gslot(eventName: string): GSlot[];

	/**
	 * 将特定的事件处理函数与全局事件关联。
	 * @param eventName 全局事件的名称。
	 * @param handler 要与事件关联的处理函数。
	 * @returns 与此节点中的事件关联的全局事件监听器。
	 * @example
	 * 注册内置全局事件：
	 * ```
	 * const node = Node()
	 * node.gslot(GSlot.AppQuit, () => {
	 * 	print("Application is shuting down!");
	 * });
	 * ```
	 */
	gslot<K extends keyof GlobalEventHandlerMap>(eventName: K, handler: GlobalEventHandlerMap[K]): void;

	/**
	 * 将特定的事件处理函数与全局事件关联。
	 * @param eventName 全局事件的名称。
	 * @param handler 要与事件关联的处理函数。
	 * @returns 与此节点中的事件关联的全局事件监听器。
	 */
	gslot(eventName: string, handler: (this: void, ...args: any[]) => void): GSlot;

	/**
	 * 获取与特定节点事件名称关联的节点事件监听器。
	 * @param eventName 节点事件的名称。
	 * @returns 与节点事件关联的节点事件监听器。
	 */
	slot(eventName: string): Slot;

	/**
	 * 将特定的处理函数与节点事件关联。
	 * @param eventName 节点事件的名称。
	 * @param handler 要与节点事件关联的处理函数。
	 * @example
	 * 注册内置节点事件：
	 * ```
	 * const node = Node()
	 * node.slot(Slot.Cleanup, () => {
	 * 	print("Node is cleaning up!");
	 * });
	 * ```
	 */
	slot<K extends keyof NodeEventHandlerMap>(eventName: K, handler: NodeEventHandlerMap[K]): void;

	/**
	 * 将特定的处理函数与节点事件关联。
	 * @param eventName 节点事件的名称。
	 * @param handler 要与节点事件关联的处理函数。
	 */
	slot(eventName: string, handler: (this: void, ...args: any[]) => void): void;

	/**
	 * 发出具有特定事件名称和参数的节点事件。
	 * @param eventName 节点事件的名称。
	 * @param args 要传递给节点事件处理函数的参数。
	 */
	emit(eventName: string, ...args: any[]): void;

	/**
	 * 为指定节点创建或删除纹理抓取器。
	 * @param enabled [可选] 是否启用或禁用抓取器。默认为true。
	 * @returns 启用时的Grabber对象。
	 */
	grab(enabled?: boolean): Grabber;

	/**
	 * 为指定节点创建具有指定网格大小的纹理抓取器。
	 * @param gridX 将抓取器划分为的水平网格单元数。
	 * @param gridY 将抓取器划分为的垂直网格单元数。
	 * @returns Grabber对象。
	 */
	grab(gridX: number, gridY: number): Grabber;
}

export type {Node as NodeType};

/**
 * 用于创建`Node`类的类对象。
 */
interface NodeClass {
	/**
	 * 创建`Node`类的新实例。
	 *
	 * @example
	 * ```
	 * import {Node} from 'dora';
	 * const node = Node();
	 * ```
	 * @returns `Node`类的新实例。
	 */
	(this: void): Node;
}

const nodeClass: NodeClass;
export {nodeClass as Node};

/**
 * ImGui控件使用的字符串缓冲区类。
 */
class Buffer extends Object {
	private constructor();

	/** 缓冲区的大小。 */
	readonly size: number;

	/**
	 * 更改缓冲区的大小。
	 * @param size 缓冲区的新大小。
	 */
	resize(size: number): void;

	/** 将缓冲区中的所有字节设置为零。 */
	zeroMemory(): void;

	/**
	 * 将缓冲区转换为字符串。
	 * @returns 缓冲区内容作为字符串。
	 */
	toString(): string;

	/**
	 * 使用字符串设置缓冲区的内容。
	 * @param str 缓冲区的新内容。
	 */
	setString(str: string): void;
}

export type {Buffer as BufferType};

/**
* 用于创建Buffer对象的类。
*/
interface BufferClass {
	/**
	 * 创建新的缓冲区实例。
	 * @param size 要创建的缓冲区的大小。
	 * @returns 具有特定大小的新的"Buffer"类型的实例。
	 */
	(this: void, size: number): Buffer;
}

const bufferClass: BufferClass;
export {bufferClass as Buffer};

/**
 * 可以根据其蒙版的alpha值剪切其子节点渲染结果的节点。
 */
class ClipNode extends Node {
	private constructor();

	/**
	 * 定义剪切形状的蒙版节点。
	 */
	stencil: Node;

	/**
	 * 使像素可见的最小alpha阈值。值的范围从0到1。
	 */
	alphaThreshold: number;

	/**
	 * 是否反转剪切区域。
	 */
	inverted: boolean;
}

export type {ClipNode as ClipNodeType};

/**
* 用于创建ClipNode对象的类。
*/
interface ClipNodeClass {
	/**
	 * 创建新的ClipNode对象。
	 * @param stencil 剪切形状的蒙版节点。
	 * @returns 新的ClipNode对象。
	 */
	(this: void, stencil?: Node): ClipNode;
}

const clipNodeClass: ClipNodeClass;
export {clipNodeClass as ClipNode};

/**
 * 用于管理文件搜索、加载和其他与资源相关的操作的单例对象。
 *
 * @example
 * ```
 * import {Content} from "dora";
 * const text = Content.load("filename.txt");
 * ```
 */
class Content {
	private constructor();

	/** 用于搜索资源文件的目录数组。 */
	searchPaths: string[];

	/** 包含只读资源的目录的路径。 */
	readonly assetPath: string;

	/** 可以写入文件的目录的路径。 */
	readonly writablePath: string;

	/**
	 * 加载具有指定文件名的文件的内容。
	 * @param filename 要加载的文件的名称。
	 * @returns 加载的文件的内容。
	 */
	load(filename: string): string;

	/**
	 * 加载具有指定文件名和可选表名的Excel文件的内容。
	 * @param filename 要加载的Excel文件的名称。
	 * @param sheetNames 表示要加载的表的名称的字符串数组。如果未提供，将加载所有表。
	 * @returns 包含Excel文件中数据的表。键是表名，值是包含表的行和列的表。
	 */
	loadExcel(filename: string, sheetNames?: string[]): {
		[sheetName: string]: [column: string | number][]
	} | null;

	/**
	 * 将指定的内容保存到具有指定文件名的文件中。
	 * @param filename 要保存的文件的名称。
	 * @param content 要保存到文件的内容。
	 * @returns 如果内容成功保存到文件，则为`true`，否则为`false`。
	 */
	save(filename: string, content: string): boolean;

	/**
	 * 检查是否存在具有指定文件名的文件。
	 * @param filename 要检查的文件的名称。
	 * @returns 如果文件存在，则为`true`，否则为`false`。
	 */
	exist(filename: string): boolean;

	/**
	 * 创建具有指定路径的新目录。
	 * @param path 要创建的目录的路径。
	 * @returns 如果目录已创建，则为`true`，否则为`false`。
	 */
	mkdir(path: string): boolean;

	/**
	 * 检查指定的路径是否为目录。
	 * @param path 要检查的路径。
	 * @returns 如果路径是目录，则为`true`，否则为`false`。
	 */
	isdir(path: string): boolean;

	/**
	 * 删除具有指定路径的文件或目录。
	 * @param path 要删除的文件或目录的路径。
	 * @returns 如果文件或目录已删除，则为`true`，否则为`false`。
	 */
	remove(path: string): boolean;

	/**
	 * 将指定路径中的文件或目录复制到目标路径。
	 * @param srcPath 要复制的文件或目录的路径。
	 * @param dstPath 要复制文件的路径。
	 * @returns 如果文件或目录已复制到目标路径，则为`true`，否则为`false`。
	 */
	copy(srcPath: string, dstPath: string): boolean;

	/**
	 * 将指定路径中的文件或目录移动到目标路径。
	 * @param srcPath 要移动的文件或目录的路径。
	 * @param dstPath 要移动文件的路径。
	 * @returns 如果文件或目录已移动到目标路径，则为`true`，否则为`false`。
	 */
	move(srcPath: string, dstPath: string): boolean;

	/**
	 * 获取具有指定文件名的文件的完整路径。
	 * @param filename 要获取其完整路径的文件的名称。
	 * @returns 文件的完整路径。
	 */
	getFullPath(filename: string): string;

	/**
	 * 在指定索引处插入搜索路径。
	 * @param index 要插入搜索路径的索引。
	 * @param path 要插入的搜索路径。
	 */
	insertSearchPath(index: number, path: string): void;

	/**
	 * 在列表的末尾添加新的搜索路径。
	 * @param path 要添加的搜索路径。
	 */
	addSearchPath(path: string): void;

	/**
	 * 从列表中删除指定的搜索路径。
	 * @param path 要删除的搜索路径。
	 */
	removeSearchPath(path: string): void;

	/**
	 * 异步加载具有指定文件名的文件的内容。
	 * @param filename 要加载的文件的名称。
	 * @returns 加载的文件的内容。
	 */
	loadAsync(filename: string): string;

	/**
	 * 异步加载具有指定文件名和可选表名的Excel文件的内容。
	 * @param filename 要加载的Excel文件的名称。
	 * @param sheetNames 表示要加载的表的名称的字符串数组。如果未提供，将加载所有表。
	 * @returns 包含Excel文件中数据的表。键是表名，值是包含表的行和列的表。
	 */
	loadExcelAsync(filename: string, sheetNames?: string[]): {
		[sheetName: string]: [column: string | number][]
	} | null;

	/**
	 * 异步将指定的内容保存到具有指定文件名的文件中。
	 * @param filename 要保存的文件的名称。
	 * @param content 要保存到文件的内容。
	 * @returns 如果内容成功保存到文件，则为`true`，否则为`false`。
	 */
	saveAsync(filename: string, content: string): boolean;

	/**
	 * 异步地将源路径的文件或文件夹复制到目标路径。
	 * @param src 要复制的文件或文件夹的路径。
	 * @param dst 复制文件的目标路径。
	 * @returns 如果文件或文件夹成功复制，则返回`true`，否则返回`false`。
	 */
	copyAsync(src: string, dst: string): boolean;

	/**
	 * 异步地将指定的文件夹压缩为具有指定文件名的ZIP存档。
	 * @param folderPath 要压缩的文件夹的路径，应在资产可写路径下。
	 * @param zipFile 要创建的ZIP存档的名称。
	 * @param filter 过滤器函数，用于过滤包含在存档中的文件。该函数接受文件名作为输入，并返回布尔值，表示是否包含该文件。如果未提供，将包含所有文件。
	 * @returns 如果文件夹成功压缩，则返回`true`，否则返回`false`。
	 */
	zipAsync(folderPath: string, zipFile: string, filter?: (this: void, filename: string) => boolean): boolean;

	/**
	 * 异步地将ZIP存档解压缩到指定的文件夹。
	 * @param zipFile 要解压缩的ZIP存档的名称，应该是资产可写路径下的文件。
	 * @param folderPath 要解压缩到的文件夹的路径，应在资产可写路径下。
	 * @param filter 过滤器函数，用于过滤包含在存档中的文件。该函数接受文件名作为输入，并返回布尔值，表示是否包含该文件。如果未提供，将包含所有文件。
	 * @returns 如果文件夹成功解压缩，则返回`true`，否则返回`false`。
	 */
	unzipAsync(folderPath: string, zipFile: string, filter?: (this: void, filename: string) => boolean): boolean;

	/**
	 * 获取指定目录中所有子目录的名称。
	 * @param path 要搜索的目录的路径。
	 * @returns 指定目录中所有子目录的名称的数组。
	 */
	getDirs(path: string): string[];

	/**
	 * 获取指定目录中所有文件的名称。
	 * @param path 要搜索的目录的路径。
	 * @returns 指定目录中所有文件的名称的数组。
	 */
	getFiles(path: string): string[];

	/**
	 * 获取指定目录及其子目录中所有文件的名称。
	 * @param path 要搜索的目录的路径。
	 * @returns 指定目录及其子目录中所有文件的名称的数组。
	 */
	getAllFiles(path: string): string[];

	/**
	 * 清除相对路径到完整路径的映射的搜索路径缓存。
	 */
	clearPathCache(): void;
}

const content: Content;
export {content as Content};

/**
 * 将日志消息打印到控制台。
 * @param msg 要打印的日志消息。
 */
export function Log(this: void, msg: string): void;

/**
 * 数据库列的类型定义。
 * 布尔类型仅使用布尔值false表示数据库NULL值。
 */
type DBColumn = number | string | boolean;

/**
 * 数据库行的类型定义。
 */
type DBRow = DBColumn[];

/**
 * SQL查询的类型定义。
 * 可以是SQL命令或SQL命令和对应的参数数组。
 */
export type SQL = string | [string, DBRow[]];

/**
 * 代表数据库的接口。
 */
interface DB {
	/**
	 * 检查数据库中是否存在表。
	 * @param tableName 要检查的表的名称。
	 * @param schema [可选] 要检查的模式的名称。
	 * @returns 表是否存在。
	 */
	exist(tableName: string, schema?: string): boolean;

	/**
	 * 执行一系列SQL语句作为一个单独的事务。
	 * @param sqls 要执行的SQL语句列表。
	 * @returns 事务是否成功。
	 */
	transaction(sqls: SQL[]): boolean;

	/**
	 * 异步地执行一系列SQL语句作为一个单独的事务。
	 * @param sqls 要执行的SQL语句列表。
	 * @returns 事务是否成功。
	 */
	transactionAsync(sqls: SQL[]): boolean;

	/**
	 * 执行SQL查询并将结果返回为行列表。
	 * @param sql 要执行的SQL语句。
	 * @param args [可选] 要替换到SQL语句中的值列表。
	 * @param withColumn [可选] 是否在结果中包含列名（默认为false）。
	 * @returns 查询返回的行列表。
	 */
	query(sql: string, args?: DBRow, withColumn?: boolean): DBRow[];

	/**
	 * 执行SQL查询并将结果返回为行列表。
	 * @param sql 要执行的SQL语句。
	 * @param withColumn [可选] 是否在结果中包含列名（默认为false）。
	 * @returns 查询返回的行列表。
	 */
	query(sql: string, withColumn?: boolean): DBRow[];

	/**
	 * 在一个事务中将数据行插入到表中。
	 * @param tableName 要插入的表的名称。
	 * @param values 要插入到表中的值。
	 * @returns 插入是否成功。
	 */
	insert(tableName: string, values: DBRow[]): boolean;

	/**
	 * 执行SQL语句并返回受影响的行数。
	 * @param sql 要执行的SQL语句。
	 * @returns 语句影响的行数。
	 */
	exec(sql: string): number;

	/**
	 * 执行SQL语句并返回受影响的行数。
	 * @param sql 要执行的SQL语句。
	 * @param values 要替换到SQL语句中的值列表。
	 * @returns 语句影响的行数。
	 */
	exec(sql: string, values: DBRow): number;

	/**
	 * 在一个事务中执行SQL语句并返回受影响的行数。
	 * @param sql 要执行的SQL语句。
	 * @param values 要替换到SQL语句中的值列表。
	 * @returns 语句影响的行数。
	 */
	exec(sql: string, values: DBRow[]): number;

	/**
	 * 异步地在一个事务中将数据行插入到表中。
	 * @param tableName 要插入的表的名称。
	 * @param values 要插入到表中的值。
	 * @returns 插入是否成功。
	 */
	insertAsync(tableName: string, values: DBRow[]): boolean;

	/**
	 * 异步地在一个事务中将Excel文件中的数据插入到表中。
	 * @param tableSheets 要插入的表的名称。
	 * @param excelFile 包含数据的Excel文件的路径。
	 * @param startRow 开始插入数据的行号。行号从1开始。
	 * @returns 插入是否成功。
	 */
	insertAsync(tableSheets: string[], excelFile: string, startRow: number): boolean;

	/**
	 * 异步地在一个事务中将Excel文件中的数据插入到表中。
	 * @param tableSheets 要插入的表名和相应的表名列表。
	 * @param excelFile 包含数据的Excel文件的路径。
	 * @param startRow 开始插入数据的行号。行号从1开始。
	 * @returns 插入是否成功。
	 */
	insertAsync(tableSheets: [string, string][], excelFile: string, startRow: number): boolean;

	/**
	 * 异步地执行SQL查询并将结果返回为行列表。
	 * @param sql 要执行的SQL语句。
	 * @param args [可选] 要替换到SQL语句中的值列表。
	 * @param withColumn [可选] 是否在结果中包含列名（默认为false）。
	 * @returns 查询返回的行列表。
	 */
	queryAsync(sql: string, args?: DBRow, withColumn?: boolean): DBRow[];

	/**
	 * 异步地执行SQL查询并将结果返回为行列表。
	 * @param sql 要执行的SQL语句。
	 * @param withColumn [可选] 是否在结果中包含列名（默认为false）。
	 * @returns 查询返回的行列表。
	 */
	queryAsync(sql: string, withColumn?: boolean): DBRow[];

	/**
	 * 异步地在一个事务中执行SQL语句并返回受影响的行数。
	 * @param sql 要执行的SQL语句。
	 * @param values 要替换到SQL语句中的值列表。
	 * @returns 语句影响的行数。
	 */
	execAsync(sql: string, values: DBRow[]): number;

	/**
	 * 异步地执行SQL语句并返回受影响的行数。
	 * @param sql 要执行的SQL语句。
	 * @returns 语句影响的行数。
	 */
	execAsync(sql: string): number;
}

const db: DB;
export {db as DB};

/**
 * 单例类，管理游戏场景树并提供不同游戏用途的多种场景根节点。
 *
 * @example
 * ```
 * import {Director} from "dora";
 * Director.entry.addChild(node);
 * ```
 */
class Director {
	private constructor();

	/**
	 * 游戏世界的背景颜色。
	 */
	clearColor: Color;

	/**
	 * 提供对游戏调度器的访问，用于调度任务，如动画和游戏事件。
	 */
	scheduler: Scheduler;

	/**
	 * 2D用户界面元素（如按钮和标签）的根节点。
	 */
	readonly ui: Node;

	/**
	 * 具有3D投影效果的3D用户界面元素的根节点。
	 */
	readonly ui3D: Node;

	/**
	 * 游戏起点的根节点。
	 */
	readonly entry: Node;

	/**
	 * 后渲染场景树的根节点。
	 */
	readonly postNode: Node;

	/**
	 * 提供对系统调度器的访问，用于低级系统任务。不应在其中放置任何游戏逻辑。
	 */
	readonly systemScheduler: Scheduler;

	/**
	 * 提供对用于处理后游戏逻辑的调度器的访问。
	 */
	readonly postScheduler: Scheduler;

	/**
	 * Director的摄像机堆栈中当前活动的摄像机。
	 */
	readonly currentCamera: Camera;

	/**
	 * 向Director的摄像机堆栈添加新摄像机，并将其设置为当前摄像机。
	 * @param camera 要添加的摄像机。
	 */
	pushCamera(camera: Camera): void;

	/**
	 * 从Director的摄像机堆栈中移除当前摄像机。
	 */
	popCamera(): void;

	/**
	 * 从Director的摄像机堆栈中移除指定的摄像机。
	 * @param camera 要移除的摄像机。
	 * @returns 如果摄像机被移除，则返回True，否则返回False。
	 */
	removeCamera(camera: Camera): boolean;

	/**
	 * 从Director的摄像机堆栈中移除所有摄像机。
	 */
	clearCamera(): void;

	/**
	 * 清理Director管理的所有资源，包括场景树和摄像机。
	 */
	cleanup(): void;
}

const director: Director;
export {director as Director};

/**
 * 动画模型系统的基类。
 */
class Playable extends Node {
	protected constructor();

	/**
	 * 动画的外观。
	 */
	look: string;

	/**
	 * 动画的播放速度。
	 */
	speed: number;

	/**
	 * 动画的恢复时间，以秒为单位。
	 * 用于从一个动画过渡到另一个动画。
	 */
	recovery: number;

	/**
	 * 动画是否水平翻转。
	 */
	fliped: boolean;

	/**
	 * 当前播放的动画名称。
	 */
	readonly current: string;

	/**
	 * 最后完成的动画名称。
	 */
	readonly lastCompleted: string;

	/**
	 * 通过其名称获取动画模型上的关键点。
	 * @param name 要获取的关键点的名称。
	 * @returns 关键点值作为Vec2。
	 */
	getKey(name: string): Vec2;

	/**
	 * 播放模型中的动画。
	 * @param name 要播放的动画的名称。
	 * @param loop 是否循环播放动画（默认为false）。
	 * @returns 动画的持续时间，以秒为单位。
	 */
	play(name: string, loop?: boolean): number;

	/**
	 * 停止当前播放的动画。
	 */
	stop(): void;

	/**
	 * 将子节点附加到动画模型上的插槽。
	 * @param name 要设置的插槽的名称。
	 * @param item 要设置插槽的节点。
	 */
	setSlot(name: string, item: Node): void;

	/**
	 * 获取附加到动画模型的子节点。
	 * @param name 要获取的插槽的名称。
	 * @returns 插槽中的节点，如果插槽中没有节点，则返回null。
	 */
	getSlot(name: string): Node | null;
}

export type {Playable as PlayableType};

/**
* 用于创建'Playable'对象实例的类。
*/
interface PlayableClass {
	/**
	 * 从指定的动画文件创建新的'Playable'实例。
	 * @param filename 要加载的动画文件的文件名。
	 * 支持DragonBone，Spine2D和Dora Model文件。
	 * 应为以下格式之一：
	 *  "model:" + modelFile
	 *  "spine:" + spineStr
	 *  "bone:" + dragonBoneStr
	 * @returns 新的'Playable'实例。
	 */
	(this: void, filename: string): Playable;
}

const playableClass: PlayableClass;
export {playableClass as Playable};

/**
 * 使用DragonBones动画系统实现的'Playable'动画模型类。
 */
class DragonBone extends Playable {
	private constructor();

	/**
	 * 是否显示调试图形。
	 */
	showDebug: boolean;

	/**
	 * 是否启用命中测试。
	 */
	hitTestEnabled: boolean;

	/**
	 * 检查点是否在实例的边界内，并返回该点处的骨骼或插槽的名称，如果没有找到骨骼或插槽，则返回undefined。
	 * @param x 要检查的点的x坐标。
	 * @param y 要检查的点的y坐标。
	 * @returns 该点处的骨骼或插槽的名称，如果没有找到骨骼或插槽，则返回undefined。
	 */
	containsPoint(x: number, y: number): string | undefined;

	/**
	 * 检查一条线段是否与实例的边界相交，并返回交点处的骨骼或插槽的名称，如果没有找到骨骼或插槽，则返回undefined。
	 * @param x1 线段起点的x坐标。
	 * @param y1 线段起点的y坐标。
	 * @param x2 线段终点的x坐标。
	 * @param y2 线段终点的y坐标。
	 * @returns 交点处的骨骼或插槽的名称，如果没有找到骨骼或插槽，则返回undefined。
	 */
	intersectsSegment(x1: number, y1: number, x2: number, y2: number): string | undefined;
}

export type {DragonBone as DragonBoneType};

/**
* 用于创建'DragonBone'对象实例的类。
*/
interface DragonBoneClass {
	/**
	 * 返回指定DragonBone文件字符串的可用外观列表。
	 * @param boneStr 要获取外观的DragonBone文件字符串。
	 * @returns 代表可用外观的字符串列表。
	 */
	getLooks(boneStr: string): string[];

	/**
	 * 返回指定DragonBone文件字符串的可用动画列表。
	 * @param boneStr 要获取动画的DragonBone文件字符串。
	 * @returns 代表可用动画的字符串列表。
	 */
	getAnimations(boneStr: string): string[];

	/**
	 * 使用指定的骨骼字符串创建新的'DragonBone'实例。
	 * @param boneStr 新实例的DragonBone文件字符串。
	 * @returns 新的'DragonBone'实例。
	 */
	(this: void, boneStr: string): DragonBone;

	/**
	 * 使用指定的骨骼文件和图集文件创建新的'DragonBone'实例。此函数只加载一个骨架。
	 * @param boneFile 要加载的骨骼文件的文件名。
	 * @param atlasFile 要加载的图集文件的文件名。
	 * @returns 具有指定骨骼文件和图集文件的新的'DragonBone'实例。
	 */
	(this: void, boneFile: string, atlasFile: string): DragonBone;
}

const dragonBoneClass: DragonBoneClass;
export {dragonBoneClass as DragonBone};

/**
 * 使用Spine引擎实现的动画系统。
 */
class Spine extends Playable {
	private constructor();

	/** 是否显示调试图形。 */
	showDebug: boolean;

	/** 是否启用命中测试。 */
	hitTestEnabled: boolean;

	/**
	 * 设置Spine骨架中骨骼的旋转。
	 * @param name 要旋转的骨骼的名称。
	 * @param rotation 旋转骨骼的量，以度为单位。
	 * @returns 旋转是否成功设置。
	 */
	setBoneRotation(name: string, rotation: number): boolean;

	/**
	 * 检查空间中的点是否在Spine骨架的边界内。
	 * @param x 要检查的点的x坐标。
	 * @param y 要检查的点的y坐标。
	 * @returns 点处的骨骼的名称，如果点处没有骨骼，则返回null。
	 */
	containsPoint(x: number, y: number): string | null;

	/**
	 * 检查一条线段是否与实例的边界相交，并返回交点处的骨骼或插槽的名称，如果没有找到骨骼或插槽，则返回null。
	 * @param x1 线段起点的x坐标。
	 * @param y1 线段起点的y坐标。
	 * @param x2 线段终点的x坐标。
	 * @param y2 线段终点的y坐标。
	 * @returns 交点处的骨骼或插槽的名称，如果没有找到骨骼或插槽，则返回null。
	 */
	intersectsSegment(x1: number, y1: number, x2: number, y2: number): string | null;
}

export type {Spine as SpineType};

/**
* 用于创建'Spine'动画模型对象实例的类。
*/
interface SpineClass {
	/**
	 * 返回指定Spine2D文件字符串的可用外观列表。
	 * @param spineStr 要获取外观的Spine2D文件字符串。
	 * @returns 代表可用外观的字符串列表。
	 */
	getLooks(spineStr: string): string[];

	/**
	 * 返回指定Spine2D文件字符串的可用动画列表。
	 * @param spineStr 要获取动画的Spine2D文件字符串。
	 * @returns 代表可用动画的字符串列表。
	 */
	getAnimations(spineStr: string): string[];

	/**
	 * 使用指定的Spine字符串创建新的'Spine'实例。
	 * @param spineStr 新实例的Spine文件字符串。
	 * @returns 新的'Spine'实例。
	 */
	(this: void, spineStr: string): Spine;

	/**
	 * 使用指定的骨架文件和图集文件创建新的'Spine'实例。
	 * @param skelFile 要加载的骨架文件的文件名。
	 * @param atlasFile 要加载的图集文件的文件名。
	 * @returns 具有指定骨架文件和图集文件的新的'Spine'实例。
	 */
	(this: void, skelFile: string, atlasFile: string): Spine;
}

const spineClass: SpineClass;
export {spineClass as Spine};

/**
 * 'Playable'动画模型类的另一种实现。
 */
class Model extends Playable {
	protected constructor();

	/**
	 * 当前动画的持续时间。
	 */
	duration: number;

	/**
	 * 是否将动画模型反向播放。
	 */
	reversed: boolean;

	/**
	 * 动画模型当前是否正在播放。
	 */
	playing: boolean;

	/**
	 * 动画模型当前是否已暂停。
	 */
	paused: boolean;

	/**
	 * 检查模型中是否存在动画。
	 * @param name 要检查的动画的名称。
	 * @returns 动画是否存在于模型中。
	 */
	hasAnimation(name: string): boolean;

	/**
	 * 暂停当前正在播放的动画。
	 */
	pause(): void;

	/**
	 * 恢复当前已暂停的动画，或者如果指定，则播放新动画。
	 * @param name [可选] 要播放的动画的名称。
	 * @param loop [可选] 是否循环播放动画（默认为false）。
	 */
	resume(name?: string, loop?: boolean): void;

	/**
	 * 将当前动画重置为其初始状态。
	 */
	reset(): void;

	/**
	 * 将动画更新到指定的时间，并可选择反向播放。
	 * @param elapsed 要更新到的时间。
	 * @param reversed [可选] 是否反向播放动画（默认为false）。
	 */
	updateTo(elapsed: number, reversed?: boolean): void;

	/**
	 * 获取具有指定名称的节点。
	 * @param name 要获取的节点的名称。
	 * @returns 具有指定名称的节点。
	 */
	getNodeByName(name: string): Node;

	/**
	 * 对模型中的每个节点调用指定的函数，并在函数返回false时停止。
	 * @param func 要对每个节点调用的函数。
	 * @returns 函数是否被调用了所有节点。
	 */
	eachNode(func: (this: void, node: Node) => boolean): boolean;
}

export type {Model as ModelType}

/**
 * 用于创建'Model'对象实例的类。
 */
interface ModelClass {
	/**
	 * 返回占位使用的'Model'实例，该实例无法执行任何操作。
	 * @returns 占位用的'Model'实例。
	 */
	dummy(): Model;

	/**
	 * 从指定的模型文件中获取切片文件。
	 * @param filename 要搜索的模型文件的文件名。
	 * @returns 切片文件的名称。
	 */
	getClipFile(filename: string): string;

	/**
	 * 从指定的模型文件中获取一组外观名称。
	 * @param filename 要搜索的模型文件的文件名。
	 * @returns 在模型文件中找到的外观名称数组。
	 */
	getLooks(filename: string): string[];

	/**
	 * 从指定的模型文件中获取一组动画名称。
	 * @param filename 要搜索的模型文件的文件名。
	 * @returns 在模型文件中找到的动画名称数组。
	 */
	getAnimations(filename: string): string[];

	/**
	 * 从指定的模型文件创建新的'Model'实例。
	 * @param filename 要加载的模型文件的文件名。
	 * 可以是带有或不带有扩展名的文件名，例如："Model/item" 或 "Model/item.model"。
	 * @returns 新的'Model'实例。
	 */
	(this: void, filename: string): Model;
}

const modelClass: ModelClass;
export {modelClass as Model};

/**
 * 用于绘制简单形状（如点、线和多边形）的场景节点类。
 */
class DrawNode extends Node {
	private constructor();

	/**
	 * 绘制时是否写入深度缓冲区（默认为false）。
	 */
	depthWrite: boolean;

	/**
	 * 用于绘制形状的混合函数。
	 */
	blendFunc: BlendFunc;

	/**
	 * 在指定位置绘制指定半径和颜色的点。
	 * @param pos 点的位置。
	 * @param radius 点的半径。
	 * @param color 点的颜色（默认为白色）。
	 */
	drawDot(this: DrawNode, pos: Vec2, radius: number, color?: Color): void;

	/**
	 * 用指定的半径和颜色绘制两点之间的线段。
	 * @param from 线的起点。
	 * @param to 线的终点。
	 * @param radius 线的半径。
	 * @param color 线的颜色（默认为白色）。
	 */
	drawSegment(this: DrawNode, from: Vec2, to: Vec2, radius: number, color?: Color): void;

	/**
	 * 绘制由顶点列表定义的多边形，具有指定的填充颜色和边框。
	 * @param verts 多边形的顶点。
	 * @param fillColor 多边形的填充颜色（默认为白色）。
	 * @param borderWidth 边框的宽度（默认为0）。
	 * @param borderColor 边框的颜色（默认为白色）。
	 */
	drawPolygon(this: DrawNode, verts: Vec2[], fillColor?: Color, borderWidth?: number, borderColor?: Color): void;

	/**
	 * 绘制一组顶点作为三角形，每个顶点都有自己的颜色。
	 * @param verts 顶点及其颜色的列表。
	 */
	drawVertices(this: DrawNode, verts: [Vec2, Color][]): void;

	/**
	 * 清除节点上所有之前绘制的形状。
	 */
	clear(this: DrawNode): void;
}

export type {DrawNode as DrawNodeType};

/**
* 用于创建DrawNode对象的类。
*/
interface DrawNodeClass {
	/**
	 * 创建新的DrawNode对象。
	 * @returns 新的DrawNode对象。
	 */
	(this: void): DrawNode;
}

const drawNodeClass: DrawNodeClass;
export {drawNodeClass as DrawNode};

/**
 * 发送具有特定名称和参数的全局事件，传递给所有由`node.gslot()`函数注册的事件监听器。
 * @param eventName 要发出的事件的名称。
 * @param args 要传递给全局事件监听器的数据。
 */
export function emit(this: void, eventName: string, ...args: any[]): void;

export type Component = number | boolean | string | ContainerItem;

/**
 * 代表ECS游戏系统中的实体的类。
 */
class Entity extends Object {
	private constructor();

	/** 实体的索引。 */
	readonly index: number;

	/**
	 * 访问实体属性旧值的快捷语法变量。
	 * 旧值是指Entity的组件值上次更改之前的值。
	 * 不要对这个对象做引用，引用它会导致未定义的行为。
	 */
	readonly oldValues: Record<string, Component | undefined>;

	/**
	 * 用于销毁实体的函数。
	 */
	destroy(): void;

	/**
	 * 将实体的属性设置为特定值的函数。
	 * 此函数将触发Observer对象的监听事件。
	 * @param key 要设置的属性的名称。
	 * @param item 要设置的属性值。
	 */
	set(key: string, item: Component | undefined): void;

	/**
	 * 获取实体的属性值的函数。
	 * @param key 要检索值的属性的名称。
	 * @returns 指定属性的值。
	 */
	get(key: string): Component | undefined;

	/**
	 * 获取实体属性的前一个值。
	 * 为Entity的组件值上次更改之前的值。
	 * @param key 要检索前一个值的属性的名称。
	 * @returns 指定属性的前一个值。
	 */
	getOld(key: string): Component | undefined;

	/**
	 * 检索实体的属性值的便捷方法。
	 * @param key 要检索值的属性的名称。
	 * @returns 指定属性的值。
	 */
	[key: string]: Component | undefined;
}

export type {Entity as EntityType};

/**
 * 用于在ECS游戏系统中创建和管理实体的类。
 */
interface EntityClass {
	/** 所有正在运行的实体的数量。 */
	readonly count: number;

	/**
	 * 用于清除所有实体对象的函数。
	 */
	clear(): void;

	/**
	 * 用于创建具有指定组件的新实体。
	 * 在新实体创建以后，可以从实体组和观察者中访问新创建的Entity对象。
	 * @param components 将组件名称（字符串）映射到组件值的数值字典。
	 * @example
	 * Entity({ a: 1, b: "abc", c: Node() });
	 */
	(this: void, components: Record<string, Component>): Entity;
}

const entity: EntityClass;
export {entity as Entity};

/**
 * 代表游戏系统中监听实体变化的观察者的类。
 */
class Observer {
	private constructor();

	/**
	 * 监听目标的实体对象的特定组件变化。
	 * @param func 当实体发生变化时调用的函数。
	 * @returns 用于链式调用方法的同一个观察者。
	 */
	watch(func: (this: void, entity: Entity, ...components: any[]) => void): Observer;
}

/**
 * 观察者可以监听的事件类型。
 */
export const enum ObserverEvent {
	/** 新实体的添加。 */
	Add = "Add",

	/** 现有实体的修改。 */
	Change = "Change",

	/** 实体的添加或修改。 */
	AddOrChange = "AddOrChange",

	/** 现有实体的移除。 */
	Remove = "Remove"
}

/**
* 用于创建Observer对象的类。
*/
interface ObserverClass {
	/**
	 * 创建具有指定组件过滤器和要监听的动作的新观察者。
	 * @param action 要监听的动作类型。
	 * @param components 用于过滤实体的组件的名称列表。
	 * @returns 新的观察者。
	 */
	(this: void, action: ObserverEvent, components: string[]): Observer;
}

const observerClass: ObserverClass;
export {observerClass as Observer};

/**
 * 代表ECS游戏系统中的实体组的类。
 */
class Group extends Object {
	private constructor();

	/** 实体组中的实体数量。 */
	readonly count: number;

	/**
	 * 对组中的每个实体调用函数。
	 * @param func 对每个实体调用的函数。在函数内部返回true以停止迭代。
	 * @returns 如果所有实体都被处理，返回False；如果迭代被中断，返回True。
	 */
	each(func: (this: void, entity: Entity) => boolean): boolean;

	/**
	 * 查找满足检查函数的实体组中的第一个实体。
	 * @param func 用于检查每个实体的函数。
	 * @returns 满足检查函数的第一个实体，如果没有实体满足，则返回undefined。
	 */
	find(func: (this: void, entity: Entity) => boolean): Entity | undefined;

	/**
	 * 监听实体组的实体变化，每当实体被添加或更改时，触发回调函数。
	 * @param func 当实体被添加或更改时调用的函数。
	 * @returns 用于链式调用方法的同一个实体组。
	 */
	watch(func: (this: void, entity: Entity, ...components: any[]) => void): Group;
}

export type {Group as GroupType};

/**
* 用于创建实体组对象的类。
*/
interface GroupClass {
	/**
	 * 创建包含指定组件名称的新实体组。
	 * @param components 要包含在实体组中的组件的名称列表。
	 * @returns 新的实体组。
	 */
	(this: void, components: string[]): Group;
}

const groupClass: GroupClass;
export {groupClass as Group};

/**
 * 表示2D纹理。
 * 继承自 `Object`。
 */
class Texture2D extends Object {
	private constructor();

	/** 纹理的宽度，以像素为单位。 */
	readonly width: number;

	/** 纹理的高度，以像素为单位。 */
	readonly height: number;
}

export type {Texture2D as Texture2DType};

/**
 * 用于将纹理渲染为图元网格的类，每个图元都可以定位、着色，并可以操作其UV坐标。
 */
class Grid extends Node {
	private constructor();

	/** 网格中的列数。渲染时，水平方向上有 `gridX + 1` 个顶点。 */
	readonly gridX: number;

	/** 网格中的行数。渲染时，垂直方向上有 `gridY + 1` 个顶点。 */
	readonly gridY: number;

	/** 是否启用深度写入（默认为false）。 */
	depthWrite: boolean;

	/** 用于网格的纹理。 */
	texture: Texture2D;

	/** 用于网格的纹理内的矩形。 */
	textureRect: Rect;

	/** 用于网格的混合函数。 */
	blendFunc: BlendFunc;

	/** 应用于网格图元上的着色器特效。默认为 `SpriteEffect("builtin:vs_sprite", "builtin:fs_sprite")`。 */
	effect: SpriteEffect;

	/**
	 * 设置网格中顶点的位置。
	 * @param x 顶点在网格中的x坐标。
	 * @param y 顶点在网格中的y坐标。
	 * @param pos 顶点的新位置。
	 */
	setPos(x: number, y: number, pos: Vec2): void;

	/**
	 * 获取网格中顶点的位置。
	 * @param x 顶点在网格中的x坐标。
	 * @param y 顶点在网格中的y坐标。
	 * @returns 顶点的当前位置。
	 */
	getPos(x: number, y: number): Vec2;

	/**
	 * 获取网格中顶点的颜色。
	 * @param x 顶点在网格中的x坐标。
	 * @param y 顶点在网格中的y坐标。
	 * @returns 顶点的当前颜色。
	 */
	getColor(x: number, y: number): Color;

	/**
	 * 设置网格中顶点的颜色。
	 * @param x 顶点在网格中的x坐标。
	 * @param y 顶点在网格中的y坐标。
	 * @param color 顶点的新颜色。
	 */
	setColor(x: number, y: number, color: Color): void;

	/**
	 * 移动网格中顶点的UV坐标。
	 * @param x 顶点在网格中的x坐标。
	 * @param y 顶点在网格中的y坐标。
	 * @param offset 移动UV坐标的偏移量。
	 */
	moveUV(x: number, y: number, offset: Vec2): void;
}

export type {Grid as GridType};

/**
* 用于创建Grid对象的类。
*/
interface GridClass {
	/**
	 * 使用指定的纹理矩形和网格大小创建新的Grid。
	 * @param textureRect 用于网格的纹理内的矩形。
	 * @param gridX 网格中的列数。
	 * @param gridY 网格中的行数。
	 * @returns 新的Grid实例。
	 */
	(this: void, textureRect: Rect, gridX: number, gridY: number): Grid;

	/**
	 * 使用指定的纹理，纹理矩形和网格大小创建新的Grid。
	 * @param texture 用于网格的纹理。
	 * @param textureRect 用于网格的纹理内的矩形。
	 * @param gridX 网格中的列数。
	 * @param gridY 网格中的行数。
	 * @returns 新的Grid实例。
	 */
	(this: void, texture: Texture2D, textureRect: Rect, gridX: number, gridY: number): Grid;

	/**
	 * 使用指定的纹理和网格大小创建新的Grid。
	 * @param texture 用于网格的纹理。
	 * @param gridX 网格中的列数。
	 * @param gridY 网格中的行数。
	 * @returns 新的Grid实例。
	 */
	(this: void, texture: Texture2D, gridX: number, gridY: number): Grid;

	/**
	 * 使用指定的剪辑字符串和网格大小创建新的Grid。
	 * @param clipStr 用于网格的剪辑字符串。可以是 "Image/file.png" 和 "Image/items.clip|itemA"。
	 * @param gridX 网格中的列数。
	 * @param gridY 网格中的行数。
	 * @returns 新的Grid实例。
	 */
	(this: void, clipStr: string, gridX: number, gridY: number): Grid;
}

const gridClass: GridClass;
export {gridClass as Grid};

/**
 * 定义了可以加载到缓存中的各种类型的资源的枚举。
 */
export const enum CacheResourceType {
	Bone = "Bone",
	Spine = "Spine",
	Texture = "Texture",
	SVG = "SVG",
	Clip = "Clip",
	Frame = "Frame",
	Model = "Model",
	Particle = "Particle",
	Shader = "Shader",
	Font = "Font",
	Sound = "Sound",
}

/**
 * 定义了可以从缓存中安全卸载的各种类型的资源的枚举。
 */
export const enum CacheResourceTypeSafeUnload {
	Texture = "Texture",
	SVG = "SVG",
	Clip = "Clip",
	Frame = "Frame",
	Model = "Model",
	Particle = "Particle",
	Shader = "Shader",
	Font = "Font",
	Sound = "Sound",
	Spine = "Spine",
}

/**
 * 用于管理各种游戏资源缓存的单例实例。
 */
class Cache {
	private constructor();

	/**
	 * 通过阻塞操作将文件加载到缓存中。
	 * @param filename 要加载的文件的名称。
	 * @returns 如果文件成功加载，则返回true，否则返回false。
	 */
	load(filename: string): boolean;

	/**
	 * 异步将文件加载到缓存中。
	 * @param filename 要加载的文件的名称。
	 * @returns 如果文件成功加载，则返回true，否则返回false。
	 */
	loadAsync(filename: string): boolean;

	/**
	 * 更新缓存中已加载文件的内容。
	 * 如果文件名的项在缓存中不存在，将会添加新的文件内容到缓存中。
	 * @param filename 要更新的文件的名称。
	 * @param content 文件的新内容。
	 */
	update(filename: string, content: string): void;

	/**
	 * 更新缓存中已加载的特定文件名的纹理对象。
	 * 如果文件名的纹理对象在缓存中不存在，它将被添加到缓存中。
	 * @param filename 要更新的纹理的名称。
	 * @param texture 文件的新纹理对象。
	 */
	update(filename: string, texture: Texture2D): void;

	/**
	 * 从缓存中卸载资源。
	 * @param type 要卸载的资源类型。
	 * @returns 如果资源成功卸载，则返回true，否则返回false。
	 */
	unload(type: CacheResourceTypeSafeUnload): boolean;

	/**
	 * 从缓存中卸载资源。
	 * @param filename 要卸载的文件的名称。
	 * @returns 如果资源成功卸载，则返回true，否则返回false。
	 */
	unload(filename: string): boolean;

	/**
	 * 从缓存中移除特定类型的所有未使用的资源（未被引用）。
	 * @param type 要移除的资源类型。
	 */
	removeUnused(type: CacheResourceType): void;

	/**
	 * 从缓存中移除所有未使用的资源（未被引用）。
	 */
	removeUnused(): void;
}

const cache: Cache;
export {cache as Cache};

/** 用于添加到物理体的形状定义类。 */
class FixtureDef extends Object {
	private constructor();
}

/**
 * 用于表示游戏世界中的物理感应器的类。
 */
class Sensor extends Object {
	private constructor();

	/**
	 * 感应器当前是否启用。
	 */
	enabled: boolean;

	/**
	 * 感应器的标签。
	 */
	readonly tag: number;

	/**
	 * 拥有感应器的物理体对象。
	 */
	readonly owner: Body;

	/**
	 * 感应器当前是否正在感知游戏世界中的其他物理体对象。
	 */
	readonly sensed: boolean;

	/**
	 * 当前被感应器感知的物理体对象的数组。
	 */
	readonly sensedBodies: Array;

	/**
	 * 确定感应器是否当前正在感知指定的物理体对象。
	 * @param body 要检查是否被感知的物理体对象。
	 * @returns 如果物理体对象被感应器感知，则返回true，否则返回false。
	 */
	contains(body: Body): boolean;
}

export type {Sensor as SensorType};

export const enum BodyMoveType {
	/** 不会移动的物理体。 */
	Static = "Static",

	/** 可以移动并受力影响的物理体。 */
	Dynamic = "Dynamic",

	/** 可以移动但不受力影响的物理体。 */
	Kinematic = "Kinematic",
}

/**
 * 名为 "BodyDef" 的类，用于描述物理体的属性。
 * 继承自 `Object`。
 */
class BodyDef extends Object {
	private constructor();

	/**
	 * 物理体的不同移动类型的枚举。
	 */
	type: BodyMoveType;

	/** 物理体的位置。 */
	position: Vec2;

	/** 物理体的角度。 */
	angle: number;

	/** 物理体的图形显示组件。 */
	face: string;

	/** 显示组件在物理体上的位置。 */
	facePos: Vec2;

	/** 物理体的线性阻尼。 */
	linearDamping: number;

	/** 物理体的角阻尼。 */
	angularDamping: number;

	/** 物理体的初始线性加速度。 */
	linearAcceleration: Vec2;

	/** 物理体的旋转是否固定。 */
	fixedRotation: boolean;

	/**
	 * 物理体是否为子弹。设置为true以进行额外的子弹移动检查。
	 */
	bullet: boolean;

	/**
	 * 将多边形形状定义附加到物理体上。
	 * @param center 多边形的中心点。
	 * @param width 多边形的宽度。
	 * @param height 多边形的高度。
	 * @param angle 多边形的角度（默认为0.0）（可选）。
	 * @param density 多边形的密度（默认为0.0）（可选）。
	 * @param friction 多边形的摩擦系数（默认为0.4，应为0.0到1.0）（可选）。
	 * @param restitution 多边形的弹性系数（默认为0.0，应为0.0到1.0）（可选）。
	 */
	attachPolygon(center: Vec2, width: number, height: number, angle?: number, density?: number, friction?: number, restitution?: number): void;

	/**
	 * 仅使用宽度和高度将多边形形状定义附加到物理体上。
	 * @param width 多边形的宽度。
	 * @param height 多边形的高度。
	 * @param density 多边形的密度（默认为0.0）（可选）。
	 * @param friction 多边形的摩擦系数（默认为0.4，应为0.0到1.0）（可选）。
	 * @param restitution 多边形的弹性系数（默认为0.0，应为0.0到1.0）（可选）。
	 */
	attachPolygon(width: number, height: number, density?: number, friction?: number, restitution?: number): void;

	/**
	 * 使用顶点将多边形形状定义附加到物理体上。
	 * @param vertices 多边形的顶点。
	 * @param density 多边形的密度（默认为0.0）（可选）。
	 * @param friction 多边形的摩擦系数（默认为0.4，应为0.0到1.0）（可选）。
	 * @param restitution 多边形的弹性系数（默认为0.0，应为0.0到1.0）（可选）。
	 */
	attachPolygon(vertices: Vec2[], density?: number, friction?: number, restitution?: number): void;

	/**
	 * 将由多个凸形状组成的凹形状定义附加到物理体上。
	 * @param vertices 表示组成凹形状的每个凸形状的顶点的Vec2数组。
	 * @param density 形状的密度（默认为0.0）（可选）。
	 * @param friction 形状的摩擦系数（默认为0.4，应为0.0到1.0）（可选）。
	 * @param restitution 形状的弹性系数（默认为0.0，应为0.0到1.0）（可选）。
	 */
	attachMulti(vertices: Vec2[], density?: number, friction?: number, restitution?: number): void;

	/**
	 * 将圆盘形状定义附加到物理体上。
	 * @param center 圆盘的中心点。
	 * @param radius 圆盘的半径。
	 * @param density 圆盘的密度（默认为0.0）（可选）。
	 * @param friction 圆盘的摩擦系数（默认为0.4，应为0.0到1.0）（可选）。
	 * @param restitution 圆盘的弹性系数（默认为0.0，应为0.0到1.0）（可选）。
	 */
	attachDisk(center: Vec2, radius: number, density?: number, friction?: number, restitution?: number): void;

	/**
	 * 仅使用半径将圆盘形状附加到物理体上。
	 * @param radius 圆盘的半径。
	 * @param density 圆盘的密度（默认为0.0）（可选）。
	 * @param friction 圆盘的摩擦系数（默认为0.4）（可选）。
	 * @param restitution 圆盘的弹性系数（默认为0.0）（可选）。
	 */
	attachDisk(radius: number, density?: number, friction?: number, restitution?: number): void;

	/**
	 * 将链形状定义附加到物理体上。链形状是自由形式的线段序列，具有双面碰撞。
	 * @param vertices 链的顶点。
	 * @param friction 链的摩擦系数（默认为0.4）（可选）。
	 * @param restitution 链的弹性系数（默认为0.0）（可选）。
	 */
	attachChain(vertices: Vec2[], friction?: number, restitution?: number): void;

	/**
	 * 将多边形感应器形状定义附加到物理体上。
	 * @param tag 感应器的整数标签。
	 * @param width 多边形的宽度（可选）。
	 * @param height 多边形的高度（可选）。
	 * @param center 多边形的中心点（可选）。
	 * @param angle 多边形的角度（默认为0.0）（可选）。
	 */
	attachPolygonSensor(tag: number, width?: number, height?: number, center?: Vec2, angle?: number): void;

	/**
	 * 使用顶点将多边形感应器形状定义附加到物理体上。
	 * @param tag 感应器的整数标签。
	 * @param vertices 包含多边形顶点的表。
	 */
	attachPolygonSensor(tag: number, vertices: Vec2[]): void;

	/**
	 * 将圆盘感应器形状定义附加到物理体上。
	 * @param tag 感应器的整数标签。
	 * @param center 圆盘的中心。
	 * @param radius 圆盘的半径。
	 */
	attachDiskSensor(tag: number, center: Vec2, radius: number): void;

	/**
	 * 仅使用半径将圆盘感应器形状附加到物理体上。
	 * @param tag 感应器的整数标签。
	 * @param radius 圆盘的半径。
	 */
	attachDiskSensor(tag: number, radius: number): void;
}

export type {BodyDef as BodyDefType};

/**
 * 用于创建BodyDef和FixtureDef的类。
 */
interface BodyDefClass {
	/**
	 * 使用指定的尺寸创建多边形定义。
	 * @param width 多边形的宽度。
	 * @param height 多边形的高度。
	 * @param density 多边形的密度（默认为0.0）（可选）。
	 * @param friction 多边形的摩擦系数（默认为0.4，应为0.0到1.0）（可选）。
	 * @param restitution 多边形的弹性系数（默认为0.0，应为0.0到1.0）（可选）。
	 * @returns 为创建的多边形创建的FixtureDef对象。
	 */
	polygon(width: number, height: number, density?: number, friction?: number, restitution?: number): FixtureDef;

	/**
	 * 使用指定的尺寸和中心位置创建多边形定义。
	 * @param center 多边形的中心位置。
	 * @param width 多边形的宽度。
	 * @param height 多边形的高度。
	 * @param angle 多边形的角度，以弧度为单位（默认为0.0）（可选）。
	 * @param density 多边形的密度（默认为0.0）（可选）。
	 * @param friction 多边形的摩擦系数（默认为0.4，应为0.0到1.0）（可选）。
	 * @param restitution 多边形的弹性系数（默认为0.0，应为0.0到1.0）（可选）。
	 * @returns 为创建的多边形创建的FixtureDef对象。
	 */
	polygon(center: Vec2, width: number, height: number, angle?: number, density?: number, friction?: number, restitution?: number): FixtureDef;

	/**
	 * 使用指定的顶点创建多边形定义。
	 * @param vertices 多边形的顶点。
	 * @param density 多边形的密度（默认为0.0）（可选）。
	 * @param friction 多边形的摩擦系数（默认为0.4，应为0.0到1.0）（可选）。
	 * @param restitution 多边形的弹性系数（默认为0.0，应为0.0到1.0）（可选）。
	 * @returns 为创建的多边形创建的FixtureDef对象。
	 */
	polygon(vertices: Vec2[], density?: number, friction?: number, restitution?: number): FixtureDef;

	/**
	 * 创建由多个凸形状组成的凹形状定义。
	 * @param vertices 表示组成凹形状的每个凸形状的顶点的Vec2数组。顶点数组中的每个凸形状应以Vec2(0.0, 0.0)作为分隔符结束。
	 * @param density 形状的密度（可选，默认0.0）。
	 * @param friction 形状的摩擦系数（可选，默认0.4，应为0.0到1.0）。
	 * @param restitution 形状的弹性系数（可选，默认0.0，应为0.0到1.0）。
	 * @returns 多边形定义对象。
	 */
	multi(vertices: Vec2[], density?: number, friction?: number, restitution?: number): FixtureDef;

	/**
	 * 创建圆盘形状的定义。
	 * @param center 圆的中心，为Vec2。
	 * @param radius 圆的半径。
	 * @param density 圆的密度（可选，默认0.0）。
	 * @param friction 圆的摩擦系数（可选，默认0.4，应为0.0到1.0）。
	 * @param restitution 圆的弹性系数（可选，默认0.0，应为0.0到1.0）。
	 * @returns 圆盘形状定义对象。
	 */
	disk(center: Vec2, radius: number, density?: number, friction?: number, restitution?: number): FixtureDef;

	/**
	 * 创建以原点为中心的圆盘形状的定义。
	 * @param radius 圆的半径。
	 * @param density 圆的密度（可选，默认0.0）。
	 * @param friction 圆的摩擦系数（可选，默认0.4，应为0.0到1.0）。
	 * @param restitution 圆的弹性系数（可选，默认0.0，应为0.0到1.0）。
	 * @returns 圆盘形状定义对象。
	 */
	disk(radius: number, density?: number, friction?: number, restitution?: number): FixtureDef;

	/**
	 * 创建链形状的定义。这个形状是自由形式的线段序列，具有双面碰撞。
	 * @param vertices 链的顶点，为Vec2数组。
	 * @param friction 链的摩擦系数（可选，默认0.4，应为0.0到1.0）。
	 * @param restitution 链的弹性系数（可选，默认0.0，应为0.0到1.0）。
	 * @returns 链形状的定义对象。
	 */
	chain(vertices: Vec2[], friction?: number, restitution?: number): FixtureDef;

	/**
	 * 创建新的BodyDef类的实例。
	 * @returns 新的BodyDef对象。
	 */
	(this: void): BodyDef;
}

const bodyDefClass: BodyDefClass;
export {bodyDefClass as BodyDef};

/**
 * 代表物理世界中的物理体的类。
 */
class Body extends Node {
	protected constructor();

	/**
	 * 该物理体所属的物理世界。
	 */
	readonly world: PhysicsWorld;

	/**
	 * 物理体的定义。
	 */
	readonly bodyDef: BodyDef;

	/**
	 * 物理体的质量。
	 */
	readonly mass: number;

	/**
	 * 物理体是否被用作感应器。
	 */
	readonly sensor: boolean;

	/**
	 * 物理体的x轴速度。
	 */
	velocityX: number;

	/**
	 * 物理体的y轴速度。
	 */
	velocityY: number;

	/**
	 * 物理体的速度，作为`Vec2`。
	 */
	velocity: Vec2;

	/**
	 * 物理体的角速度。
	 */
	angularRate: number;

	/**
	 * 物理体所属的碰撞组。
	 */
	group: number;

	/**
	 * 物理体的线性阻尼。
	 */
	linearDamping: number;

	/**
	 * 物理体的角阻尼。
	 */
	angularDamping: number;

	/**
	 * 物理体的所有者的引用。
	 */
	owner: Object;

	/**
	 * 物理体是否正在接收接触事件。
	 */
	receivingContact: boolean;

	/**
	 * 在指定位置对物理体施加线性冲量。
	 * @param impulse 要施加的线性冲量。
	 * @param pos 施加冲量的位置。
	 */
	applyLinearImpulse(impulse: Vec2, pos: Vec2): void;

	/**
	 * 对物理体施加角冲量。
	 * @param impulse 要施加的角冲量。
	 */
	applyAngularImpulse(impulse: number): void;

	/**
	 * 从物理体中移除指定标签的感应器。
	 * @param tag 要移除的感应器的标签。
	 * @returns 是否找到并移除了指定标签的感应器。
	 */
	removeSensorByTag(tag: number): boolean;

	/**
	 * 将形状附加到物理体上。
	 * @param fixtureDef 要附加的形状的定义。
	 */
	attach(fixtureDef: FixtureDef): void;

	/**
	 * 返回具有特定标签的感应器。
	 * @param tag 要获取的感应器的标签。
	 * @returns 具有特定标签的感应器。
	 */
	getSensorByTag(tag: number): Sensor;

	/**
	 * 从物理体的感应器列表中移除特定的感应器。
	 * @param sensor 要移除的感应器。
	 * @returns 如果感应器成功被移除，则返回true，否则返回false。
	 */
	removeSensor(sensor: Sensor): boolean;

	/**
	 * 将具有特定标签和形状定义的新感应器附加到物理体上。
	 * @param tag 要附加的感应器的标签。
	 * @param fixtureDef 感应器的形状定义。
	 * @returns 新附加的感应器。
	 */
	attachSensor(tag: number, fixtureDef: FixtureDef): Sensor;
}

export type {Body as BodyType};

/**
 * 用于创建Body对象的类。
 */
interface BodyClass {
	/**
	 * 创建新的`Body`实例。
	 * @param def 要创建的物理体的定义。
	 * @param world 物理体所属的物理世界。
	 * @param pos [可选] 物理体的初始位置。默认为零向量。
	 * @param rot [可选] 物理体的初始旋转角度，以度为单位。默认为0。
	 * @returns 新创建的`Body`实例。
	 */
	(
		this: void,
		def: BodyDef,
		world: PhysicsWorld,
		pos?: Vec2, // Vec2.zero
		rot?: number // 0
	): Body;
}

const bodyClass: BodyClass;
export {bodyClass as Body};

/**
 * 在游戏中代表物理世界。
 */
class PhysicsWorld extends Node {
	protected constructor();

	/**
	 * 是否应为物理世界显示调试图形。
	 */
	showDebug: boolean;

	/**
	 * 查询与指定矩形相交的物理世界中的所有物体。
	 *
	 * @param rect 要查询物体的矩形。
	 * @param handler 函数，对在查询中找到的每个物体调用。
	 * @returns 查询是否被中断，true表示中断，否则为false。
	 */
	query(rect: Rect, handler: (this: void, body: Body) => boolean): boolean;

	/**
	 * 通过物理世界投射一条射线，并找到与射线相交的第一个物体。
	 *
	 * @param start 射线的起点。
	 * @param stop 射线的终点。
	 * @param closest 是否在找到与射线相交的最近的物体时停止射线投射。将closest设置为true可以更快地进行射线投射搜索。
	 * @param handler 函数，对在射线投射中找到的每个物体调用。
	 * @returns 射线投射是否被中断，true表示中断，否则为false。
	 */
	raycast(start: Vec2, stop: Vec2, closest: boolean, handler: (this: void, body: Body, point: Vec2, normal: Vec2) => boolean): boolean;

	/**
	 * 设置在物理世界中执行的速度和位置迭代的次数。
	 *
	 * @param velocityIter 要执行的速度迭代次数。
	 * @param positionIter 要执行的位置迭代次数。
	 */
	setIterations(velocityIter: number, positionIter: number): void;

	/**
	 * 设置两个物理组是否应该相互接触。
	 *
	 * @param groupA 第一个物理组。
	 * @param groupB 第二个物理组。
	 * @param contact 两个组是否应该相互接触。
	 */
	setShouldContact(groupA: number, groupB: number, contact: boolean): void;

	/**
	 * 获取两个物理组是否应该相互接触。
	 *
	 * @param groupA 第一个物理组。
	 * @param groupB 第二个物理组。
	 * @returns 两个组是否应该相互接触。
	 */
	getShouldContact(groupA: number, groupB: number): boolean;
}

export type {PhysicsWorld as PhysicsWorldType};

/**
 * 用于创建PhysicsWorld对象的类。
 */
interface PhysicsWorldClass {
	/**
	 * 用于将物理引擎的米值转换为像素值的因子。
	 * 默认值100.0是一个好的值，因为物理引擎可以很好地模拟0.1到10米的真实物体。
	 * 使用值100.0，我们可以模拟10到1000像素的游戏对象，这适合大多数游戏。
	 * 你可以在创建任何物理体之前更改此值。
	 */
	scaleFactor: number;

	/**
	 * 创建新的"PhysicsWorld"对象。
	 * @returns 新的"PhysicsWorld"对象。
	 */
	(this: void): PhysicsWorld;
}

const physicsWorldClass: PhysicsWorldClass;
export {physicsWorldClass as PhysicsWorld};

/**
 * 可用于将物理体连接在一起的类。
 */
class Joint extends Object {
	protected constructor();

	/**
	 * 关节所属的物理世界。
	 */
	readonly world: PhysicsWorld;

	/**
	 * 销毁关节并将其从物理模拟中移除。
	 */
	destroy(): void;
}

export type {Joint as JointType};

/**
 * A joint that applies a rotational or linear force to a physics body.
 */
class MotorJoint extends Joint {
	private constructor();

	/**
	 * 是否启用电机关节。
	 */
	enabled: boolean;

	/**
	 * 施加在电机关节上的力。
	 */
	force: number;

	/**
	 * 电机关节的速度。
	 */
	speed: number;
}

export type {MotorJoint as MotorJointType};

/**
 * 允许物理体移动到特定位置的关节类型。
 */
class MoveJoint extends Joint {
	private constructor();

	/**
	 * 移动关节在游戏世界中的当前位置。
	 */
	position: Vec2;
}

export type {MoveJoint as MoveJointType};

/**
 * 定义创建关节的属性的类。
 */
class JointDef extends Object {
	private constructor();

	/** 关节的中心点，以本地坐标表示。 */
	center: Vec2;

	/** 关节的位置，以世界坐标表示。 */
	position: Vec2;

	/** 关节的角度，以度为单位。 */
	angle: number;
}

/**
 * 用于创建 JointDef 对象的接口。
 */
interface JointDefClass {
	/**
	 * 创建距离关节定义。
	 * @param canCollide 连接的物体是否应该相互碰撞。
	 * @param bodyA 连接到关节的第一个物体的名称。
	 * @param bodyB 连接到关节的第二个物体的名称。
	 * @param anchorA 关节在第一个物体上的位置。
	 * @param anchorB 关节在第二个物体上的位置。
	 * @param frequency 关节的频率，以赫兹为单位（默认为0.0）。
	 * @param damping 关节的阻尼比（默认为0.0）。
	 * @returns 新的关节定义。
	 */
	distance(
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		anchorA: Vec2,
		anchorB: Vec2,
		frequency?: number,
		damping?: number
	): JointDef;

	/**
	 * 创建摩擦关节定义。
	 * @param canCollide 连接的物体是否应该相互碰撞。
	 * @param bodyA 连接到关节的第一个物体的名称。
	 * @param bodyB 连接到关节的第二个物体的名称。
	 * @param worldPos 关节在游戏世界中的位置。
	 * @param maxForce 可以施加到关节上的最大力。
	 * @param maxTorque 可以施加到关节上的最大扭矩。
	 * @returns 新的摩擦关节定义。
	 */
	friction(
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		maxForce: number,
		maxTorque: number
	): JointDef;

	/**
	 * 创建齿轮关节定义。
	 * @param canCollide 是否允许连接的物体相互碰撞。
	 * @param jointA 要连接到齿轮关节的第一个关节的名称。
	 * @param jointB 要连接到齿轮关节的第二个关节的名称。
	 * @param ratio 齿轮比率（默认为1.0）。
	 * @returns 齿轮关节定义。
	 */
	gear(
		canCollide: boolean,
		jointA: string,
		jointB: string,
		ratio?: number
	): JointDef;

	/**
	 * 创建新的弹簧关节定义。
	 * @param canCollide 连接的物体是否应该相互碰撞。
	 * @param bodyA 连接到关节的第一个物体的名称。
	 * @param bodyB 连接到关节的第二个物体的名称。
	 * @param linearOffset 在物理体A的坐标系中，物理体B减去物理体A的位置。
	 * @param angularOffset 物理体B的角度减去物理体A的角度。
	 * @param maxForce 关节可以施加的最大力。
	 * @param maxTorque 关节可以施加的最大扭矩。
	 * @param correctionFactor 可选的校正因子，默认为1.0。
	 * @returns 创建的关节定义。
	 */
	spring(
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		linearOffset: Vec2,
		angularOffset: number,
		maxForce: number,
		maxTorque: number,
		correctionFactor?: number
	): JointDef;

	/**
	 * 创建新的平移关节定义。
	 * @param canCollide 连接的物体是否应该相互碰撞。
	 * @param bodyA 连接到关节的第一个物体的名称。
	 * @param bodyB 连接到关节的第二个物体的名称。
	 * @param worldPos 关节的世界位置。
	 * @param axisAngle 关节的轴角度。
	 * @param lowerTranslation 可选的较小平移限制，默认为0.0。
	 * @param upperTranslation 可选的较大平移限制，默认为0.0。
	 * @param maxMotorForce 可选的最大电机力，默认为0.0。
	 * @param motorSpeed 可选的电机速度，默认为0.0。
	 * @returns 创建的平移关节定义。
	 */
	prismatic(
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		axisAngle: number,
		lowerTranslation?: number,
		upperTranslation?: number,
		maxMotorForce?: number,
		motorSpeed?: number
	): JointDef;

	/**
	 * 创建滑轮关节定义。
	 * @param canCollide 连接的物体是否应该相互碰撞。
	 * @param bodyA 要连接的第一个物理体的名称。
	 * @param bodyB 要连接的第二个物理体的名称。
	 * @param anchorA 第一个物体上的锚点位置，以世界坐标表示。
	 * @param anchorB 第二个物体上的锚点位置，以世界坐标表示。
	 * @param groundAnchorA 第一个物体上的地面锚点位置，以世界坐标表示。
	 * @param groundAnchorB 第二个物体上的地面锚点位置，以世界坐标表示。
	 * @param ratio 可选的滑轮比率（默认为1.0）。
	 * @returns 滑轮关节定义。
	 */
	pulley(
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		anchorA: Vec2,
		anchorB: Vec2,
		groundAnchorA: Vec2,
		groundAnchorB: Vec2,
		ratio?: number
	): JointDef;

	/**
	 * 创建旋转关节定义。
	 * @param canCollide 是否允许连接的物体相互碰撞。
	 * @param bodyA 第一个要连接的物体的名称。
	 * @param bodyB 第二个要连接的物体的名称。
	 * @param worldPos 关节将被创建的世界坐标位置。
	 * @param lowerAngle 可选，较小的角度限制（弧度）（默认为0.0）。
	 * @param upperAngle 可选，较大的角度限制（弧度）（默认为0.0）。
	 * @param maxMotorTorque 可选，可以施加到关节上以达到目标速度的最大扭矩（默认为0.0）。
	 * @param motorSpeed 可选，关节的期望速度（默认为0.0）。
	 * @returns 旋转关节定义。
	 */
	revolute(
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		lowerAngle?: number,
		upperAngle?: number,
		maxMotorTorque?: number,
		motorSpeed?: number
	): JointDef;

	/**
	 * 创建绳子关节定义。
	 * @param canCollide 是否允许连接的物体相互碰撞。
	 * @param bodyA 第一个要连接的物体的名称。
	 * @param bodyB 第二个要连接的物体的名称。
	 * @param anchorA 第一个物体上锚点的位置（世界坐标）。
	 * @param anchorB 第二个物体上锚点的位置（世界坐标）。
	 * @param maxLength 可选，锚点之间的最大距离（默认为0.0）。
	 * @returns 绳子关节定义。
	 */
	rope(
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		anchorA: Vec2,
		anchorB: Vec2,
		maxLength: number
	): JointDef;

	/**
	 * 创建焊接关节定义。
	 * @param canCollide 连接的物体是否可以相互碰撞。
	 * @param bodyA 要连接的第一个物体的名称。
	 * @param bodyB 要连接的第二个物体的名称。
	 * @param worldPos 在世界中连接物体的位置。
	 * @param frequency 可选，关节的频率，默认为0.0。
	 * @param damping 可选，关节的阻尼率，默认为0.0。
	 * @returns 新创建的焊接关节定义。
	 */
	weld(
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		frequency?: number,
		damping?: number
	): JointDef;

	/**
	 * 创建轮子关节定义。
	 * @param canCollide 是否允许连接的物体相互碰撞。
	 * @param bodyA 第一个要连接的物体的名称。
	 * @param bodyB 第二个要连接的物体的名称。
	 * @param worldPos 连接物体的世界坐标位置。
	 * @param axisAngle 关节轴的角度（弧度）。
	 * @param maxMotorTorque 可选，关节马达可以施加的最大扭矩，默认为0.0。
	 * @param motorSpeed 可选，关节马达的目标速度，默认为0.0。
	 * @param frequency 可选，关节的频率，默认为2.0。
	 * @param damping 可选，关节的阻尼率，默认为0.7。
	 * @returns 新创建的轮子关节定义。
	 */
	wheel(
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		axisAngle: number,
		maxMotorTorque?: number,
		motorSpeed?: number,
		frequency?: number,
		damping?: number
	): JointDef;
}

const jointDefClass: JointDefClass;
export {jointDefClass as JointDef};

/**
 * 纹理包裹模式的枚举。
 */
export const enum TextureWrap {
	None = "None",
	Mirror = "Mirror",
	Clamp = "Clamp",
	Border = "Border",
}

/**
 * 纹理过滤模式的枚举。
 */
export const enum TextureFilter {
	None = "None",
	Point = "Point",
	Anisotropic = "Anisotropic",
}

/**
 * 用于在游戏场景树层次结构中渲染纹理的Sprite类。
 */
class Sprite extends Node {
	private constructor();

	/**
	 * 当渲染图元时，是否应该写入深度缓冲区（默认为false）。
	 */
	depthWrite: boolean;

	/**
	 * 用于 alpha 测试的 alpha 参考值。小于或等于该值的像素将被丢弃。
	 * 仅在 `sprite.effect = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritealphatest")` 时有效。
	 */
	alphaRef: number;

	/**
	 * 图元的纹理矩形。
	 */
	textureRect: Rect;

	/**
	 * 图元的混合函数。
	 */
	blendFunc: BlendFunc;

	/**
	 * 图元的着色器特效。
	 */
	effect: SpriteEffect;

	/**
	 * 图元的纹理。
	 */
	texture: Texture2D;

	/**
	 * U（水平）轴的纹理包裹模式。
	 */
	uwrap: TextureWrap;

	/**
	 * V（垂直）轴的纹理包裹模式。
	 */
	vwrap: TextureWrap;

	/**
	 * 图元的纹理过滤模式。
	 */
	filter: TextureFilter;
}

export type {Sprite as SpriteType};

/**
 * 用于创建 `Sprite` 对象的类。
 */
interface SpriteClass {
	/**
	 * 创建 Sprite 对象的构造函数。
	 * @param clipStr 包含加载纹理文件格式的字符串。
	 * 可以是 "Image/file.png" 和 "Image/items.clip|itemA"。支持的图片文件格式有：jpg、png、dds、pvr、ktx。
	 * @returns Sprite 类的新实例。
	 */
	(this: void, clipStr: string): Sprite;

	/**
	 * 创建 Sprite 对象的构造函数。
	 * @returns Sprite 类的新实例。
	 */
	(this: void): Sprite;

	/**
	 * 创建 Sprite 对象的构造函数。
	 * @param texture 用于 Sprite 的纹理。
	 * @param textureRect [可选] 定义用于 Sprite 的纹理部分的矩形区域，如果未提供，则整个纹理将用于渲染。
	 * @returns Sprite 类的新实例。
	 */
	(this: void, texture: Texture2D, textureRect?: Rect): Sprite;
}

const spriteClass: SpriteClass;
export {spriteClass as Sprite};

/**
 * 用于文本对齐设置的枚举。
 */
export const enum TextAlign {
	/**
	 * 文本左对齐。
	 */
	Left = "Left",

	/**
	 * 文本居中对齐。
	 */
	Center = "Center",

	/**
	 * 文本右对齐。
	 */
	Right = "Right",
}

/**
 * 用于使用 TrueType 字体渲染文本的节点。
 */
class Label extends Node {
	private constructor();

	/**
	 * Alpha 阈值。透明度低于此值的像素将不会被绘制。
	 * 仅在 `label.effect = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritealphatest")` 时有效。
	 */
	alphaRef: number;

	/**
	 * 用于文本换行的文本宽度。
	 * 将其设置为 `Label.AutomaticWidth` 可禁用换行。
	 * 默认值为 `Label.AutomaticWidth`。
	 */
	textWidth: number;

	/**
	 * 文本行之间的间距（以像素为单位）。
	 */
	lineGap: number;

	/**
	 * 要渲染的文本。
	 */
	text: string;

	/**
	 * 用于渲染文本的混合函数。
	 */
	blendFunc: BlendFunc;

	/**
	 * 是否启用深度写入。（默认为 false）
	 */
	depthWrite: boolean;

	/**
	 * 标签是否使用批量渲染。
	 * 使用批量渲染时，`label.getCharacter()` 函数将不再起作用，并获得更好的渲染性能。（默认为 true）
	 */
	batched: boolean;

	/**
	 * 用于渲染文本的图元着色器特效。
	 */
	effect: SpriteEffect;

	/**
	 * 文本对齐设置。
	 */
	alignment: TextAlign;

	/**
	 * 标签中的字符数。
	 */
	readonly characterCount: number;

	/**
	 * 返回指定索引处字符的图元。
	 * @param index 要检索的字符图元的索引。
	 * @returns 字符的图元，如果索引超出范围则返回 `null`。
	 */
	getCharacter(index: number): Sprite | null;
}

export type {Label as LabelType};

/**
 * 用于创建 Label 对象的类。
 */
interface LabelClass {
	/**
	 * 用于自动计算宽度的值。
	 */
	readonly AutomaticWidth: number;

	/**
	 * 使用指定的字体名称和字体大小创建新的 Label 对象。
	 * @param fontName 用于 Label 的字体名称。可以是带有或不带有文件扩展名的字体文件路径。
	 * @param fontSize 用于 Label 的字体大小。
	 * @returns 新的 Label 对象。
	 */
	(this: void, fontName: string, fontSize: number): Label;
}

const labelClass: LabelClass;
export {labelClass as Label};

/**
 * 用于使用顶点绘制线条的类。
 */
class Line extends Node {
	private constructor();

	/**
	 * 是否写入深度。（默认为 false）
	 */
	depthWrite: boolean;

	/**
	 * 用于渲染线条的混合函数。
	 */
	blendFunc: BlendFunc;

	/**
	 * 添加顶点到线条中。
	 * @param verts 要添加到线条的顶点表。
	 * @param color 线条的颜色（默认为不透明白色）。
	 */
	add(verts: Vec2[], color?: Color): void;

	/**
	 * 设置线条的顶点。
	 * @param verts 要设置的顶点表。
	 * @param color 线条的颜色（默认为不透明白色）。
	 */
	set(verts: Vec2[], color?: Color): void;

	/**
	 * 清除线条的所有顶点。
	 */
	clear(): void;
}

export type {Line as LineType};

/** 用于创建 Line 对象的类。 */
interface LineClass {
	/**
	 * 创建并返回新的 Line 对象。
	 * @param verts 要添加到线条的顶点表。
	 * @param color 线条的颜色（默认为不透明白色）。
	 * @returns Line 对象。
	 */
	(this: void, verts: Vec2[], color?: Color): Line;

	/**
	 * 创建并返回新的空 Line 对象。
	 * @returns Line 对象。
	 */
	(this: void): Line;
}

const lineClass: LineClass;
export {lineClass as Line}

/**
 * 用于管理特定区域内子节点的触摸事件的接口。
 * 菜单会拦截触摸事件并传递给子节点。
 * 只有一个子节点可以接收第一个触摸事件；后续的多点触摸事件将被忽略。
 */
class Menu extends Node {
	private constructor();

	/**
	 * 菜单当前是否启用。
	 */
	enabled: boolean;
}

export type {Menu as MenuType};

/**
 * 用于创建菜单对象的类。
 */
interface MenuClass {
	/**
	 * 使用指定的宽度和高度创建新的 `Menu` 实例。
	 * @param width 菜单节点的宽度。
	 * @param height 菜单节点的高度。
	 * @returns 一个新的菜单节点对象。
	 */
	(this: void, width: number, height: number): Menu;

	/**
	 * 使用0宽度和0高度创建新的 `Menu` 实例。
	 * 尺寸为0的菜单将在全屏范围处理子节点的触摸事件。
	 * @returns 新的菜单节点对象。
	 */
	(this: void): Menu;
}

const menuClass: MenuClass;
export {menuClass as Menu};

/**
 * 用于学习马尔可夫决策过程的最优策略的简单强化学习框架。
 * Q-learning 是一种无模型的强化学习算法，通过反复更新状态-动作对的 Q 值估计来学习最优的动作值函数。
 */
class QLearner extends Object {
	private constructor();

	/**
	 * 存储状态、动作和 Q 值的矩阵。
	 */
	matrix: [state: number, action: number, QValue: number][];

	/**
	 * 根据接收到的奖励更新状态-动作对的 Q 值。
	 * @param state 表示状态的值。
	 * @param action 表示动作的值。
	 * @param reward 表示在状态中执行动作所获得的奖励。
	 */
	update(state: number, action: number, reward: number): void;

	/**
	 * 根据当前的 Q 值返回特定状态的最佳动作。
	 * @param state 当前状态。
	 * @returns 特定状态下具有最高 Q 值的动作。
	 */
	getBestAction(state: number): number;

	/**
	 * 从状态-动作对的矩阵中加载 Q 值。
	 * @param values 要加载的状态-动作对矩阵。
	 */
	load(values: [state: number, action: number, QValue: number][]): void;
}

export type {QLearner as QLearnerType};

/**
 * 用于创建 QLearner 对象的类。
 */
interface QLearnerClass {
	/**
	 * 根据特定的提示和条件值构造状态。
	 * @param hints 提供的值的字节长度。
	 * @param values 离散值的条件值。
	 * @returns 打包后的状态值。
	 */
	pack(hints: number[], values: number[]): number;

	/**
	 * 解包函数，将状态整数解包为离散值。
	 * @param hints 提供的值的字节长度。
	 * @param state 要解包的状态整数。
	 * @returns 离散值的条件值。
	 */
	unpack(hints: number[], state: number): number[];

	/**
	 * 使用可选参数 gamma、alpha 和 maxQ 创建新的 QLearner 对象。
	 * @param gamma 未来奖励的折扣因子。默认为 0.5。
	 * @param alpha 更新 Q 值的学习率。默认为 0.5。
	 * @param maxQ 最大 Q 值。默认为 100.0。
	 * @returns 新创建的 QLearner 对象。
	 */
	(
		this: void,
		gamma?: number,
		alpha?: number,
		maxQ?: number
	): QLearner;
}

/**
 * 比较运算符的枚举。
 */
type MLOperator = "return" | "<=" | ">" | "==";

/**
 * 机器学习算法的类。
 */
class ML {
	/**
	 * 将 CSV 数据作为输入，并异步应用 C4.5 机器学习算法构建决策树模型。
	 * C4.5 是一种决策树算法，它使用信息增益来选择最佳属性在树的每个节点上拆分数据。生成的决策树可以用于对新数据进行预测。
	 * @param csvData 用于构建决策树的 CSV 训练数据，使用逗号 `,` 作为分隔符。
	 * @param maxDepth 生成的决策树的最大深度。设置为 0 以防止限制生成的树的深度。
	 * @param handler 生成的决策树的每个节点调用的回调函数。
	 * @returns 决策树在训练数据上的准确度。如果在构建决策树过程中发生错误，则返回错误消息。
	 */
	BuildDecisionTreeAsync(
		csvData: string,
		maxDepth: number,
		handler: (
			this: void,
			depth: number,
			name: string,
			op: MLOperator,
			value: string
		) => void
	): LuaMultiReturn<[number, null]> | LuaMultiReturn<[null, string]>;

	/**
	 * 用于访问 QLearner 类的字段。
	 */
	QLearner: QLearnerClass;
}

const ml: ML;
export {ml as ML};

/**
 * 表示发射和动画粒子的粒子系统节点。
 */
class Particle extends Node {
	private constructor();

	/** 粒子系统是否处于活动状态。 */
	readonly active: boolean;

	/** 开始发射粒子。 */
	start(): void;

	/**
	 * 停止发射粒子，并等待所有活动粒子结束生命周期。
	 */
	stop(): void;
}

export type {Particle as ParticleType};

/**
 * 可以创建新的 Particle 对象的类。
 */
interface ParticleClass {
	/**
	 * 从粒子系统文件创建新的 Particle 对象。
	 * @param filename 粒子系统文件的文件路径。
	 * @returns 新的 Particle 对象。
	 */
	(this: void, filename: string): Particle;
}

const particleClass: ParticleClass;
export {particleClass as Particle};

/** 文件路径操作的辅助类。 */
interface Path {
	/**
	 * 从模块名称获取脚本运行路径。
	 * @param moduleName 输入的模块名称。
	 * @returns 用于脚本搜索的模块路径。
	 */
	getScriptPath(moduleName: string): string;

	/**
	 * 输入: /a/b/c.TXT 输出: txt
	 * @param path 输入的文件路径。
	 * @returns 输入文件的扩展名。
	 */
	getExt(path: string): string;

	/**
	 * 输入: /a/b/c.TXT 输出: /a/b
	 * @param path 输入的文件路径。
	 * @returns 输入文件的父路径。
	 */
	getPath(path: string): string;

	/**
	 * 输入: /a/b/c.TXT 输出: c
	 * @param path 输入的文件路径。
	 * @returns 不带扩展名的输入文件名。
	 */
	getName(path: string): string;

	/**
	 * 输入: /a/b/c.TXT 输出: c.TXT
	 * @param path 输入的文件路径。
	 * @returns 输入文件的名称。
	 */
	getFilename(path: string): string;

	/**
	 * 输入: /a/b/c.TXT, base: /a 输出: b/c.TXT
	 * @param path 输入的文件路径。
	 * @param base 目标文件路径。
	 * @returns 从输入文件到目标文件的相对路径。
	 */
	getRelative(path: string, base: string): string;

	/** 输入: /a/b/c.TXT, lua 输出: /a/b/c.lua
	 * @param path 输入的文件路径。
	 * @param newExt 要添加到文件路径的新文件扩展名。
	 * @returns 新的文件路径。
	 */
	replaceExt(path: string, newExt: string): string;

	/** 输入: /a/b/c.TXT, d 输出: /a/b/d.TXT
	 * @param path 输入的文件路径。
	 * @param newFile 要替换的新文件名。
	 * @returns 新的文件路径。
	 */
	replaceFilename(path: string, newFile: string): string;

	/** 输入: a, b, c.TXT 输出: a/b/c.TXT
	 * @param segments 要连接为新文件路径的段。
	 * @returns 新的文件路径。
	 */
	(this: void, ...segments: string[]): string;
}

const path: Path;
export {path as Path};

/**
 * 用于函数性能分析的类。
 */
interface ProfilerClass {
	/**
	 * 分析事件的名称。
	 */
	EventName: string;

	/**
	 * 分析的当前级别。
	 */
	level: number;

	/**
	 * 调用函数并返回执行所需的时间。
	 * @param funcForProfiling 要分析的函数。
	 * @returns 执行函数所需的时间。
	 * @example
	 * const time = profiler(funcForProfiling);
	 */
	(this: void, funcForProfiling: (this: void) => number): number;
}

const profiler: ProfilerClass;
export {profiler as Profiler};

/**
 * RenderTarget 是带有缓冲区的节点，允许将 Node 渲染到纹理中。
 */
class RenderTarget {
	private constructor();

	/**
	 * 渲染目标的宽度。
	 */
	readonly width: number;

	/**
	 * 渲染目标的高度。
	 */
	readonly height: number;

	/**
	 * 渲染目标生成的纹理。
	 */
	readonly texture: Texture2D;

	/**
	 * 用于渲染场景的相机。
	 */
	camera: Camera;

	/**
	 * 渲染节点到目标，而不替换其先前的内容。
	 * @param target 要渲染到渲染目标的节点。
	 */
	render(target: Node): void;

	/**
	 * 清除渲染目标上先前的颜色、深度和模板值。
	 * @param color 用于清除渲染目标的清除颜色。
	 * @param depth （可选）用于清除渲染目标的深度缓冲区的值。默认为 1。
	 * @param stencil （可选）用于清除渲染目标的模板缓冲区的值。默认为 0。
	 */
	renderWithClear(color: Color, depth?: number, stencil?: number): void;

	/**
	 * 渲染节点到目标之前清除渲染目标上先前的颜色、深度和模板值。
	 * @param target 要渲染到渲染目标的节点。
	 * @param color 用于清除渲染目标的清除颜色。
	 * @param depth （可选）用于清除渲染目标的深度缓冲区的值。默认为 1。
	 * @param stencil （可选）用于清除渲染目标的模板缓冲区的值。默认为 0。
	 */
	renderWithClear(target: Node, color: Color, depth?: number, stencil?: number): void;

	/**
	 * 异步将渲染目标的内容保存为 PNG 文件。
	 * @param filename 要保存内容的文件名。
	 */
	saveAsync(filename: string): void;
}

/**
 * 用于创建 RenderTarget 对象的类。
 */
interface RenderTargetClass {
	/**
	 * 使用特定的宽度和高度创建新的 RenderTarget 对象。
	 * @param width 渲染目标的宽度。
	 * @param height 渲染目标的高度。
	 * @returns 创建的渲染目标。
	 */
	(this: void, width: number, height: number): RenderTarget;
}

const renderTargetClass: RenderTargetClass;
export { renderTargetClass as RenderTarget };

/**
 * 用于可缩放矢量图形渲染的类。
 */
class SVG extends Object {
	private constructor();

	/**
	 * SVG 对象的宽度。
	 */
	readonly width: number;

	/**
	 * SVG 对象的高度。
	 */
	readonly height: number;

	/**
	 * 渲染 SVG 对象，应该在每帧调用以显示渲染结果。
	 */
	render(): void;
}

export type {SVG as SVGType};

/**
 * 用于创建 SVG 对象的类。
 */
interface SVGClass {
	/**
	 * 从指定的 SVG 文件创建新的 SVG 对象。
	 * @param filename SVG 格式文件的路径。
	 * @returns 创建的 SVG 对象。
	 */
	(this: void, filename: string): SVG;
}

const svgClass: SVGClass;
export {svgClass as SVG};

class VGNode extends Node {
	private constructor();
	surface: Sprite;
	render(func: (this: void) => void): void;
}

export type {VGNode as VGNodeType};

interface VGNodeClass {
	(this: void, width: number, height: number, scale?: number, edgeAA?: number): VGNode;
}

const vgNodeClass: VGNodeClass;
export {vgNodeClass as VGNode};

class View {
	private constructor();

	/** 视图的像素大小。 */
	size: Size;

	/** 视图与原点的标准距离。 */
	standardDistance: number;

	/** 视图的宽高比。 */
	aspectRatio: number;

	/** 近裁剪平面的距离。 */
	nearPlaneDistance: number;

	/** 远裁剪平面的距离。 */
	farPlaneDistance: number;

	/** 视图的视野角度（以度为单位）。 */
	fieldOfView: number;

	/** 视图的缩放因子。 */
	scale: number;

	/** 应用于视图的后期着色器特效。 */
	postEffect: SpriteEffect;

	/** 是否启用垂直同步。 */
	vsync: boolean;
}

const view: View;
export {view as View};

export type VGPaintType = BasicType<"VGPaint">;

/**
 * `tolua` 对象提供了在 C++ 和 Lua 之间进行接口交互的实用工具。
 */
export interface tolua {
	/**
	 * 返回 Lua 对象的 C++ 对象类型。
	 * @param item 要获取类型的 Lua 对象。
	 * @returns C++ 对象类型。
	 */
	type(this: void, item: any): string;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Size"。
	 * @returns 转换后的 Size 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Size"): Size | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Vec2"。
	 * @returns 转换后的 Vec2 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Vec2"): Vec2 | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Rect"。
	 * @returns 转换后的 Rect 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Rect"): Rect | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Color3"。
	 * @returns 转换后的 Color3 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Color3"): Color3 | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Color"。
	 * @returns 转换后的 Color 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Color"): Color | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Object"。
	 * @returns 转换后的 Object 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Object"): Object | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Action"。
	 * @returns 转换后的 Action 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Action"): Action | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Array"。
	 * @returns 转换后的 Array 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Array"): Array | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "BlendFunc"。
	 * @returns 转换后的 BlendFunc 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "BlendFunc"): BlendFunc | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Scheduler"。
	 * @returns 转换后的 Scheduler 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Scheduler"): Scheduler | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Dictionary"。
	 * @returns 转换后的 Dictionary 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Dictionary"): Dictionary | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Camera"。
	 * @returns 转换后的 Camera 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Camera"): Camera | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Camera2D"。
	 * @returns 转换后的 Camera2D 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Camera2D"): Camera2D | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "CameraOtho"。
	 * @returns 转换后的 CameraOtho 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "CameraOtho"): CameraOtho | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Pass"。
	 * @returns 转换后的 Pass 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Pass"): Pass | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Effect"。
	 * @returns 转换后的 Effect 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Effect"): Effect | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "SpriteEffect"。
	 * @returns 转换后的 SpriteEffect 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "SpriteEffect"): SpriteEffect | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Node"。
	 * @returns 转换后的 Node 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Node"): Node | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Buffer"。
	 * @returns 转换后的 Buffer 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Buffer"): Buffer | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "ClipNode"。
	 * @returns 转换后的 ClipNode 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "ClipNode"): ClipNode | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Playable"。
	 * @returns 转换后的 Playable 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Playable"): Playable | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "DragonBone"。
	 * @returns 转换后的 DragonBone 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "DragonBone"): DragonBone | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Spine"。
	 * @returns 转换后的 Spine 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Spine"): Spine | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Model"。
	 * @returns 转换后的 Model 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Model"): Model | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "DrawNode"。
	 * @returns 转换后的 DrawNode 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "DrawNode"): DrawNode | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Entity"。
	 * @returns 转换后的 Entity 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Entity"): Entity | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Group"。
	 * @returns 转换后的 Group 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Group"): Group | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Texture2D"。
	 * @returns 转换后的 Texture2D 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Texture2D"): Texture2D | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Grid"。
	 * @returns 转换后的 Grid 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Grid"): Grid | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Sensor"。
	 * @returns 转换后的 Sensor 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Sensor"): Sensor | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "BodyDef"。
	 * @returns 转换后的 BodyDef 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "BodyDef"): BodyDef | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Body"。
	 * @returns 转换后的 Body 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Body"): Body | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "PhysicsWorld"。
	 * @returns 转换后的 PhysicsWorld 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "PhysicsWorld"): PhysicsWorld | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Joint"。
	 * @returns 转换后的 Joint 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Joint"): Joint | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "MotorJoint"。
	 * @returns 转换后的 MotorJoint 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "MotorJoint"): MotorJoint | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "MoveJoint"。
	 * @returns 转换后的 MoveJoint 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "MoveJoint"): MoveJoint | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Sprite"。
	 * @returns 转换后的 Sprite 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Sprite"): Sprite | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Label"。
	 * @returns 转换后的 Label 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Label"): Label | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Line"。
	 * @returns 转换后的 Line 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Line"): Line | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Menu"。
	 * @returns 转换后的 Menu 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Menu"): Menu | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "QLearner"。
	 * @returns 转换后的 QLearner 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "QLearner"): QLearner | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "Particle"。
	 * @returns 转换后的 Particle 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "Particle"): Particle | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "SVG"。
	 * @returns 转换后的 SVG 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "SVG"): SVG | null;

	/**
	 * 尝试将 Lua 对象转换为 C++ 类型对象。
	 * @param item 要转换的 Lua 对象。
	 * @param name "VGNode"。
	 * @returns 转换后的 VGNode 对象，如果转换失败则返回 `null`。
	 */
	cast(this: void, item: any, name: "VGNode"): VGNode | null;

	/**
	 * 获取特定类名的类对象。
	 * @param className 要获取表格的类名。
	 * @returns 类表格，如果类不存在则返回 `null`。
	 */
	class(this: void, className: string): { [key: string | number]: any } | null;

	/**
	 * 为对象设置对等表。对等表是由 Lua userdata 引用的表，为该 userdata 对象提供自定义字段。
	 * @param obj 要设置对等表的对象。
	 * @param data 要用作对等表的表。
	 */
	setpeer(this: void, obj: Object, data: { [key: string | number]: any }): void;

	/**
	 * 获取对象的对等表。对等表是由 Lua userdata 引用的表，为该 userdata 对象提供自定义字段。
	 * @param obj 要获取对等表的对象。
	 * @returns 对等表，如果对象没有对等表则返回 `null`。
	 */
	getpeer(this: void, obj: Object): { [key: string | number]: any } | null;
}

export const tolua: tolua;

} // module "dora"

declare function p(this: void, ...args: any[]): void;
