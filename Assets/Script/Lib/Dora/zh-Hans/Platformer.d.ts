/// <reference path="Dora.d.ts" />

declare module "Platformer" {
import {
	BodyType as Body,
	PhysicsWorldType as PhysicsWorld,
	NodeType as Node,
	CameraType as Camera,
	Playable,
	Size,
	Sensor,
	Dictionary,
	Entity,
	Vec2,
	Rect,
	BodyDef,
	Job,
	Item
} from 'Dora';

type Playable = Playable.Type;
type Size = Size.Type;
type Sensor = Sensor.Type;
type Dictionary = Dictionary.Type;
type Entity = Entity.Type;
type Vec2 = Vec2.Type;
type Rect = Rect.Type;
type BodyDef = BodyDef.Type;

/** 代表游戏单位可以执行的动作的类。 */
class UnitAction {
	private constructor();

	/**
	 * 游戏单位动作的反应时间间隔，单位为秒。
	 * 反应时间会影响AI循环检查的频率。
	 */
	reaction: number;

	/**
	 * 游戏单位动作的恢复时间长度，单位为秒。
	 * 恢复时间主要影响`Playable`动画模型在不同动作之间切换动画的时间。
	 */
	recovery: number;

	/** 游戏单位动作的名称。 */
	readonly name: string;

	/** 游戏单位是否正在执行游戏单位动作。 */
	readonly doing: boolean;

	/** 自游戏单位动作开始执行以来的经过时间，单位为秒。 */
	readonly elapsedTime: number;

	/** 执行此单位动作的游戏单位。 */
	readonly owner: Unit;
}

export namespace UnitAction {
	export type Type = UnitAction;
}

/** 定义游戏单位动作参数的接口。 */
export interface UnitActionParam {
	/** 单位动作的优先级。优先级更高（数值更大）的单位动作会替换优先级较低的单位动作。 */
	priority: number;

	/** 单位动作的反应时间长度，单位为秒。 */
	reaction: number;

	/** 单位动作的恢复时间长度，单位为秒。 */
	recovery: number;

	/** 表示单位动作是否在队列中。在队列中的单位动作不会替换具有相同优先级的正在运行的单位动作。 */
	queued?: boolean;

	/**
	 * 用于判断指定游戏单位当前是否可以执行单位动作的函数。
	 * @param owner 执行该单位动作的游戏单位。
	 * @param action 需要检查可用性的单位动作。
	 * @returns 如果单位动作对游戏单位可用，则返回true，否则返回false。
	 */
	available?(this: void, owner: Unit, action: UnitAction): boolean;

	/**
	 * 创建新函数或协程作业以代表单位动作的处理过程的函数。
	 * @param owner 将拥有单位动作的游戏单位。
	 * @param action 需要创建处理函数或协程作业的单位动作。
	 * @param deltaTime 自上一帧以来的经过时间。
	 * @returns 返回或产生true如果单位动作已完成的函数或协程作业。
	 */
	create(this: void, owner: Unit, action: UnitAction, deltaTime: number): ((this: void, owner: Unit, action: UnitAction, deltaTime: number) => boolean) | Job;

	/**
	 * 当指定的游戏单位停止执行单位动作时调用的函数。
	 * @param owner 正在停止单位动作的游戏单位。
	 */
	stop?(this: void, owner: Unit): void;
}

/**
 * 定义并存储游戏单位动作类的行为和属性的接口。
 * 这是管理所有游戏单位动作对象的单例对象。
 */
interface UnitActionClass {
	/**
	 * 添加具有指定名称和参数的新单位动作定义。
	 * @param name 新单位动作的名称。
	 * @param param 新单位动作的参数。
	 */
	add(name: string, param: UnitActionParam): void;

	/**
	 * 移除所有单位动作定义对象。
	 */
	clear(): void;
}

const unitActionClass: UnitActionClass;
export {unitActionClass as UnitAction};

/**
 * 代表游戏场景中的角色或其他交互项目的类。
 */
class Unit extends Body {
	private constructor();

	/**
	 * 引用动画模型对象的属性，用于管理游戏对象的动画状态和播放。
	 */
	playable: Playable;

	/**
	 * 指定游戏对象能够检测到其他游戏对象或物理体的最大距离的属性。
	 */
	detectDistance: number;

	/**
	 * 指定游戏对象攻击范围大小的属性。
	 */
	attackRange: Size;

	/**
	 * 布尔属性，指定游戏对象是否面向右侧。
	 */
	faceRight: boolean;

	/**
	 * 布尔属性，指定游戏对象是否正在接收决策树的追踪信息，用于调试目的。
	 */
	receivingDecisionTrace: boolean;

	/**
	 * 字符串属性，指定用于游戏对象的AI行为的决策树。
	 * 决策树对象将在单例实例`Data.store`中搜索。
	 */
	decisionTree: string;

	/**
	 * 游戏对象当前是否在表面上。
	 */
	readonly onSurface: boolean;

	/**
	 * 用于检测地面表面的物理感应器对象。
	 */
	readonly groundSensor: Sensor;

	/**
	 * 用于检测游戏世界中的其他游戏对象或物理体的感应器对象。
	 */
	readonly detectSensor: Sensor;

	/**
	 * 用于检测攻击区域内的其他游戏对象的感应器对象。
	 */
	readonly attackSensor: Sensor;

	/**
	 * 字典对象，用于定义游戏单位的属性和行为。
	 */
	readonly unitDef: Dictionary;

	/**
	 * 指定游戏单位当前正在执行的单位动作的属性。
	 */
	readonly currentAction: UnitAction;

	/**
	 * 游戏单位的宽度。
	 */
	readonly width: number;

	/**
	 * 游戏单位的高度。
	 */
	readonly height: number;

	/**
	 * 用于在ECS系统中表示游戏单位的数据实体对象。
	 */
	readonly entity: Entity;

	/**
	 * 向游戏单位添加具有指定名称的新单位动作，并返回新的单位动作。
	 * @param name 新单位动作的名称。
	 * @returns 新创建的单位动作。
	 */
	attachAction(name: string): UnitAction;

	/**
	 * 从游戏单位中移除具有指定名称的单位动作。
	 * @param name 需要移除的单位动作的名称。
	 */
	removeAction(name: string): void;

	/**
	 * 从游戏单位中移除所有单位动作对象。
	 */
	removeAllActions(): void;

	/**
	 * 返回具有指定名称的单位动作，如果单位动作不存在，则返回null。
	 * @param name 需要检索的单位动作的名称。
	 * @returns 具有指定名称的单位动作，或null。
	 */
	getAction(name: string): UnitAction | null;

	/**
	 * 对附加到游戏单位的每个单位动作调用指定的函数。
	 * @param func 需要为每个单位动作调用的函数。
	 */
	eachAction(func: (this: void, action: UnitAction) => void): void;

	/**
	 * 开始具有指定名称的单位动作，并返回是否成功开始单位动作。
	 * @param name 需要开始的单位动作的名称。
	 * @returns 如果单位动作成功开始，则返回true，否则返回false。
	 */
	start(name: string): boolean;

	/**
	 * 停止当前正在运行的单位动作。
	 */
	stop(): void;

	/**
	 * 如果游戏单位当前正在执行指定的单位动作，则返回true，否则返回false。
	 * @param name 需要检查的单位动作的名称。
	 * @returns 如果游戏单位当前正在执行指定的单位动作，则返回true，否则返回false。
	 */
	isDoing(name: string): boolean;
}

export namespace Unit {
	export type Type = Unit;
}

/**
 * 用于创建游戏单位实例的类。
 */
interface UnitClass {
	/**
	 * 附加到游戏单位的"GroundSensor"的标签。
	 */
	readonly GroundSensorTag: number;

	/**
	 * 附加到游戏单位的"DetectSensor"的标签。
	 */
	readonly DetectSensorTag: number;

	/**
	 * 附加到游戏单位的"AttackSensor"的标签。
	 */
	readonly AttackSensorTag: number;

	/**
	 * 创建新的游戏单位对象的元方法。
	 * @param unitDef 定义游戏单位属性和行为的字典对象。
	 * @param physicsWorld 表示物理模拟世界的物理世界对象。
	 * @param entity 在ECS系统中代表游戏单位的数据实体对象。
	 * @param pos 指定游戏单位初始位置的"Vec2"对象。
	 * @param rot 可选的数字，指定游戏单位的初始旋转（默认为0.0）。
	 * @returns 新创建的游戏单位对象。
	 */
	(
		this: void,
		unitDef: Dictionary,
		physicsWorld: PhysicsWorld,
		entity: Entity,
		pos: Vec2,
		rot?: number
	): Unit;

	/**
	 * 创建新的游戏单位对象的元方法。
	 * @param unitDefName 定义游戏单位属性和行为的字典对象的名称，将用于在`Data.store`中搜索对象。
	 * @param physicsWorldName 表示物理模拟世界的物理世界对象的名称，将用于在`Data.store`中搜索对象。
	 * @param entity 在ECS系统中代表游戏单位的数据实体对象。
	 * @param pos 指定游戏单位初始位置的"Vec2"对象。
	 * @param rot 可选的数字，指定游戏单位的初始旋转（默认为0.0）。
	 * @returns 新创建的游戏单位对象。
	 */
	(
		this: void,
		unitDefName: string,
		physicsWorldName: string,
		entity: Entity,
		pos: Vec2,
		rot?: number
	): Unit;
}

const unitClass: UnitClass;
export {unitClass as Unit};

/**
 * 表示两个游戏单位分组之间可能的关系的枚举。
 */
export const enum Relation {
	Enemy = "Enemy",
	Friend = "Friend",
	Neutral = "Neutral",
	Unknown = "Unknown",
	Any = "Any"
}

/**
 * 提供集中存储和访问游戏相关数据的单例对象。
 */
interface Data {
	/**
	 * 表示游戏单位分组的第一个编号。
	 */
	readonly groupFirstPlayer: number;

	/**
	 * 表示游戏单位分组的最后一个编号。
	 */
	readonly groupLastPlayer: number;

	/**
	 * 默认不会与其他游戏单位分组有任何接触的组编号。
	 */
	readonly groupHide: number;

	/**
	 * 默认会与游戏单位分组有接触的组编号。
	 */
	readonly groupDetectPlayer: number;

	/**
	 * 表示默认会与其他游戏单位分组有接触的地形的组编号。
	 */
	readonly groupTerrain: number;

	/**
	 * 默认会与其他游戏单位分组有接触的组编号。
	 */
	readonly groupDetection: number;

	/**
	 * 可用于全局存储任意共享数据的字典。
	 */
	readonly store: Dictionary;

	/**
	 * 可用于设置两个游戏单位分组是否应有接触的布尔值的函数。
	 * @param groupA 表示第一组的整数。
	 * @param groupB 表示第二组的整数。
	 * @param contact 表示两个游戏单位分组是否应有接触的布尔值。
	 */
	setShouldContact(groupA: number, groupB: number, contact: boolean): void;

	/**
	 * 可用于获取两个游戏单位分组是否应有接触的布尔值的函数。
	 * @param groupA 表示第一组的整数。
	 * @param groupB 表示第二组的整数。
	 * @returns 两个游戏单位分组是否应有接触。
	 */
	getShouldContact(groupA: number, groupB: number): boolean;

	/**
	 * 可用于设置两个游戏单位分组之间关系的函数。
	 * @param groupA 表示第一组的整数。
	 * @param groupB 表示第二组的整数。
	 * @param relation 两个分组之间的关系。
	 */
	setRelation(groupA: number, groupB: number, relation: Relation): void;

	/**
	 * 可用于获取两个游戏单位分组之间关系的函数。
	 * @param groupA 表示第一组的整数。
	 * @param groupB 表示第二组的整数。
	 * @returns 两个分组之间的关系。
	 */
	getRelation(groupA: number, groupB: number): Relation;

	/**
	 * 可用于获取两个物体之间关系的函数。
	 * @param bodyA 第一个物体。
	 * @param bodyB 第二个物体。
	 * @returns 两个物体之间的关系。
	 */
	getBodyRelation(bodyA: Body, bodyB: Body): Relation;

	/**
	 * 返回两个游戏单位分组是否具有"Enemy"关系的函数。
	 * @param groupA 表示第一组的整数。
	 * @param groupB 表示第二组的整数。
	 * @returns 两个分组是否具有"Enemy"关系。
	 */
	isEnemy(groupA: number, groupB: number): boolean;

	/**
	 * 返回两个物体是否具有"Enemy"关系的函数。
	 * @param bodyA 第一个物体。
	 * @param bodyB 第二个物体。
	 * @returns 两个物体是否具有"Enemy"关系。
	 */
	isBodyEnemy(bodyA: Body, bodyB: Body): boolean;

	/**
	 * 返回两个游戏单位分组是否具有"Friend"关系的函数。
	 * @param groupA 表示第一组的整数。
	 * @param groupB 表示第二组的整数。
	 * @returns 两个分组是否具有"Friend"关系。
	 */
	isFriend(groupA: number, groupB: number): boolean;

	/**
	 * 函数返回两个物体是否具有"Friend"关系。
	 * @param bodyA 第一个物体。
	 * @param bodyB 第二个物体。
	 * @returns 两个物体是否具有"Friend"关系。
	 */
	isBodyFriend(bodyA: Body, bodyB: Body): boolean;

	/**
	 * 函数返回两个游戏单位分组是否具有"Neutral"关系。
	 * @param groupA 表示第一组的整数。
	 * @param groupB 表示第二组的整数。
	 * @returns 两个分组是否具有"Neutral"关系。
	 */
	isNeutral(groupA: number, groupB: number): boolean;

	/**
	 * 函数返回两个物体是否具有"Neutral"关系。
	 * @param bodyA 第一个物体。
	 * @param bodyB 第二个物体。
	 * @returns 两个物体是否具有"Neutral"关系。
	 */
	isBodyNeutral(bodyA: Body, bodyB: Body): boolean;

	/**
	 * 函数设置特定类型的伤害对特定类型的防御的奖励因子。
	 * @param damageType 表示伤害类型的整数。
	 * @param defenseType 表示防御类型的整数。
	 * @param bonus 表示奖励因子的数字。
	 */
	setDamageFactor(damageType: number, defenseType: number, bonus: number): void;

	/**
	 * 函数获取特定类型的伤害对特定类型的防御的奖励因子。
	 * @param damageType 表示伤害类型的整数。
	 * @param defenseType 表示防御类型的整数。
	 * @returns 表示奖励因子的数字。
	 */
	getDamageFactor(damageType: number, defenseType: number): number;

	/**
	 * 函数返回一个物体是否为玩家分组。
	 * @param body 需要检查的物体。
	 * @returns 物体是否为玩家分组。
	 */
	isPlayer(body: Body): boolean;

	/**
	 * 函数返回一个物体是否为地形。
	 * @param body 需要检查的物体。
	 * @returns 物体是否为地形。
	 */
	isTerrain(body: Body): boolean;

	/**
	 * 函数清除存储在"Data"对象中的所有数据，包括`Data.store`字段中的用户数据。
	 * 并将一些数据重置为默认值。
	 */
	clear(): void;
}

const data: Data;
export {data as Data};

/**
 * 定义子弹对象如何根据其与其他游戏对象或游戏单位的根据不同关系进行交互的类。
 */
class TargetAllow {
	/**
	 * 子弹对象是否可以与地形碰撞。
	 */
	terrainAllowed: boolean;

	/**
	 * 根据子弹对象与游戏对象或游戏单位的关系，允许或禁止子弹对象进行交互。
	 * @param relation 子弹对象与其他游戏对象或游戏单位的关系。
	 * @param allow 是否应允许子弹对象进行交互。
	 */
	allow(relation: Relation, allow: boolean): void;

	/**
	 * 根据子弹对象与游戏对象或游戏单位的关系，确定是否允许子弹对象进行交互。
	 * @param relation 子弹对象与其他游戏对象或游戏单位的关系。
	 * @returns 子弹对象是否被允许进行交互。
	 */
	isAllow(relation: Relation): boolean;

	/**
	 * 将子弹对象的允许交互关系转换为整数。
	 * @returns 子弹对象的允许交互关系的整数值。
	 */
	toValue(): number;
}

export namespace TargetAllow {
	export type Type = TargetAllow;
}

/**
 * 定义子弹对象如何根据其与其他游戏对象或游戏单位的关系进行交互的类。
 * @example
 * const targetAllow = TargetAllow();
 * targetAllow.terrainAllowed = true;
 * targetAllow.allow("Enemy", true);
 */
interface TargetAllowClass {
	/**
	 * 调用此函数以创建TargetAllow的实例。
	 * @returns TargetAllow的实例。
	 */
	(this: void): TargetAllow;
}

const targetAllowClass: TargetAllowClass;
export {targetAllowClass as TargetAllow};

/**
 * 2D平台游戏的相机，可以跟踪游戏单位的移动并将其保持在相机的视野内。
 */
class PlatformCamera extends Camera {
	private constructor();

	/**
	 * 相机的位置。
	 */
	position: Vec2;

	/**
	 * 相机的旋转角度。
	 */
	rotation: number;

	/**
	 * 相机的缩放因子，1.0表示正常大小，2.0表示放大到双倍大小。
	 */
	zoom: number;

	/**
	 * 相机允许查看的矩形区域。
	 */
	boundary: Rect;

	/**
	 * 相机应以何种比率跟随目标的位置移动。
	 * 例如，设置为`Vec2(1.0, 1.0)`，则相机将立即跟随到目标的位置。
	 * 设置为Vec2(0.5, 0.5)或更小的值，那么相机每帧将移动到目标位置的一半，从而产生平滑且逐渐的移动。
	 */
	followRatio: Vec2;

	/**
	 * 相机应跟踪的游戏单位。
	 */
	followTarget: Node;
}

export namespace PlatformCamera {
	export type Type = PlatformCamera;
}

/**
 * 定义如何创建2D平台游戏的相机实例的类。
 */
interface PlatformCameraClass {
	/**
	 * 创建一个新的2D平台游戏的相机实例。
	 * @param name [可选] 新实例的名称，默认为空字符串。
	 * @returns 新的2D平台游戏的相机实例。
	 */
	(this: void, name?: string): PlatformCamera;
}

const platformCameraClass: PlatformCameraClass;
export {platformCameraClass as PlatformCamera};

/**
 * 代表一个具有物理模拟的2D平台游戏世界的类。
 */
class PlatformWorld extends PhysicsWorld {
	private constructor();

	/**
	 * 用于控制游戏世界可视区域的相机。
	 */
	readonly camera: PlatformCamera;

	/**
	 * 将子节点移动到不同层级的新顺序。
	 * @param child 需要移动的子节点。
	 * @param newOrder 子节点的新层级顺序。
	 */
	moveChild(child: Node, newOrder: number): void;

	/**
	 * 获取给定顺序的层级节点。
	 * @param order 需要获取的层级节点的顺序。
	 * @returns 给定顺序的层级节点。
	 */
	getLayer(order: number): Node;

	/**
	 * 为给定层级设置视差移动比例，以模拟3D投影效果。
	 * @param order 需要设置移动比例的层级的顺序。
	 * @param ratio 层级的新视差比例。
	 */
	setLayerRatio(order: number, ratio: Vec2): void;

	/**
	 * 获取给定层级的视差移动比例。
	 * @param order 需要获取比例的层级的顺序。
	 * @returns 层级的视差比例。
	 */
	getLayerRatio(order: number): Vec2;

	/**
	 * 为给定层级设置位置偏移。
	 * @param order 需要设置偏移的层级的顺序。
	 * @param offset 层级的新位置偏移。
	 */
	setLayerOffset(order: number, offset: Vec2): void;

	/**
	 * 获取给定层级的位置偏移。
	 * @param order 需要获取偏移的层级的顺序。
	 * @returns 层级的位置偏移。
	 */
	getLayerOffset(order: number): Vec2;

	/**
	 * 交换两个层级的位置。
	 * @param orderA 需要交换的第一个层级的顺序。
	 * @param orderB 需要交换的第二个层级的顺序。
	 */
	swapLayer(orderA: number, orderB: number): void;

	/**
	 * 从游戏世界中移除一个层级。
	 * @param order 需要移除的层级的顺序。
	 */
	removeLayer(order: number): void;

	/**
	 * 从游戏世界中移除所有层级。
	 */
	removeAllLayers(): void;
}

export namespace PlatformWorld {
	export type Type = PlatformWorld;
}

/**
 * 用于实例化PlatformWorld实例的类。
 * @example
 * ```
 * const world = PlatformWorld();
 * world.addTo(entry);
 * ```
 */
interface PlatformWorldClass {
	/**
	 * 创建PlatformWorld新实例的元方法。
	 * @returns PlatformWorld的新实例。
	 */
	(this: void): PlatformWorld;
}

const platformWorldClass: PlatformWorldClass;
export {platformWorldClass as PlatformWorld};

/**
 * 代表游戏子弹或其他视觉项目的可视组件的定义。
 */
class Face extends Node {
	/**
	 * 添加子可视组件定义。
	 * @param face 要添加的子可视组件。
	 */
	addChild(face: Face): void;

	/**
	 * 返回可以添加到场景树进行渲染的节点。
	 * @returns 通过此可视组件创建的节点对象。
	 */
	toNode(): Node;
}

export namespace Face {
	export type Type = Face;
}

/**
 * 提供创建具有不同配置的可视组件实例的函数的接口。
 * @example
 * ```
 * import { Face } from "Platformer";
 * const faceA = Face("Image/file.png");
 * const faceB = Face(() => {
 * 	return Sprite("Image/file.png");
 * });
 * faceA.toNode().addTo(entry);
 * faceB.toNode().addTo(entry);
 * ```
 */
interface FaceClass {
	/**
	 * 使用指定的属性创建新的可视组件定义。
	 * @param faceStr 用于创建可视组件的字符串。
	 * 可以是'Image/file.png'和'Image/items.clip|itemA'。
	 * @param point 可视组件的位置，默认为`Vec2.zero`。
	 * @param scale 可视组件的缩放，默认为1.0。
	 * @param angle 可视组件的角度，默认为0.0。
	 * @returns 新的可视组件。
	 */
	(
		this: void,
		faceStr: string,
		point?: Vec2,
		scale?: number,
		angle?: number
	): Face;

	/**
	 * 使用指定的属性创建新的可视组件定义。
	 * @param createFunc 返回表示可视组件的`Node`对象的函数。
	 * @param point 可视组件的位置，默认为`Vec2.zero`。
	 * @param scale 可视组件的缩放，默认为1.0。
	 * @param angle 可视组件的角度，默认为0.0。
	 * @returns 新的可视组件。
	 */
	(
		this: void,
		createFunc: (this: void) => Node,
		point?: Vec2,
		scale?: number,
		angle?: number
	): Face;
}

const faceClass: FaceClass;
export {faceClass as Face};

/**
 * 用于表示粒子、帧动画或仅仅是精灵的视觉效果对象的类。
 */
class Visual extends Node {
	private constructor();

	/**
	 * 视觉效果是否正在播放。
	 */
	playing: boolean;

	/**
	 * 开始播放视觉效果。
	 */
	start(): void;

	/**
	 * 停止播放视觉效果。
	 */
	stop(): void;

	/**
	 * 当视觉效果播放完毕时，自动从游戏世界中移除。
	 * @returns 作为参数传入的同一个视觉效果对象。
	 */
	autoRemove(): Visual;
}

export namespace Visual {
	export type Type = Visual;
}

/**
* 用于创建视觉效果对象的类。
*/
interface VisualClass {
	/**
	 * 使用指定的名称创建新的视觉效果对象。
	 * @param name 新视觉效果对象的名称。
	 * 可以是粒子文件、帧动画文件或图像文件。
	 * @returns 新的视觉效果对象。
	 */
	(this: void, name: string): Visual;
}

const visualClass: VisualClass;
export {visualClass as Visual};

/** 用于创建游戏AI结构的行为树框架。 */
export namespace Behavior {
/**
 * 可用于存储行为树节点数据的黑板对象。
 */
class Blackboard {
	private constructor();

	/**
	 * 自上次帧更新以来的时间（以秒为单位）。
	 */
	deltaTime: number;

	/**
	 * 当前执行AI所属的游戏单位。
	 */
	owner: Unit;

	/**
	 * 用于索引黑板属性的方法。
	 * @param key 要索引的键。
	 * @returns 与键关联的值。
	 */
	[key: string]: Item;
}

/**
 * 行为树中的叶节点。
 */
class Leaf extends Object {
	private constructor();
}

/**
 * 创建一个新的序列节点，按顺序执行一组子节点。
 * @param nodes 子节点数组。
 * @returns 新的序列节点。
 */
export function Seq(this: void, nodes: Leaf[]): Leaf;

/**
 * 创建一个新的选择器节点，选择并执行将成功的子节点之一。
 * @param nodes 子节点数组。
 * @returns 新的选择器节点。
 */
export function Sel(this: void, nodes: Leaf[]): Leaf;

/**
 * 创建一个新的条件节点，当执行时执行检查处理函数。
 * @param name 条件的名称。
 * @param check 接收一个黑板对象并返回布尔值的函数。
 * @returns 新的条件节点。
 */
export function Con(this: void, name: string, check: (this: void, board: Blackboard) => boolean): Leaf;

/**
 * 创建一个新的动作节点，当执行时执行一个动作。
 * 此节点将阻止执行，直到动作完成。
 * @param actionName 要执行的动作的名称。
 * @returns 新的动作节点。
 */
export function Act(this: void, actionName: string): Leaf;

/**
 * 创建一个新的命令节点，当执行时执行一个命令。
 * 此节点将在动作开始后立即返回。
 * @param actionName 要执行的命令的名称。
 * @returns 新的命令节点。
 */
export function Command(this: void, actionName: string): Leaf;

/**
 * 创建一个新的等待节点，当执行时等待指定的持续时间。
 * @param duration 以秒为单位的等待时间。
 * @returns 新的等待节点。
 */
export function Wait(this: void, duration: number): Leaf;

/**
 * 创建一个新的倒计时节点，执行子节点直到计时器用完。
 * @param time 以秒为单位的时间限制。
 * @param node 要执行的子节点。
 * @returns 新的倒计时节点。
 */
export function Countdown(this: void, time: number, node: Leaf): Leaf;

/**
 * 创建一个新的超时节点，执行子节点直到计时器用完。
 * @param time 以秒为单位的时间限制。
 * @param node 要执行的子节点。
 * @returns 新的超时节点。
 */
export function Timeout(this: void, time: number, node: Leaf): Leaf;

/**
 * 创建一个新的重复节点，执行子节点指定的次数。
 * @param times 执行子节点的次数。
 * @param node 要执行的子节点。
 * @returns 新的重复节点。
 */
export function Repeat(this: void, times: number, node: Leaf): Leaf;

/**
 * 创建一个新的重复节点，反复执行子节点。
 * @param node 要执行的子节点。
 * @returns 新的重复节点。
 */
export function Repeat(this: void, node: Leaf): Leaf;

/**
 * 创建一个新的重试节点，反复执行子节点，直到它成功或达到最大重试次数。
 * @param times 最大重试次数。
 * @param node 要执行的子节点。
 * @returns 新的重试节点。
 */
export function Retry(this: void, times: number, node: Leaf): Leaf;

/**
 * 创建一个新的重试节点，反复执行子节点，直到它成功。
 * @param node 要执行的子节点。
 * @returns 新的重试节点。
 */
export function Retry(this: void, node: Leaf): Leaf;

} // namespace Behavior

/**
 * 单例接口，用于在执行决策树时获取信息。
 */
interface AI {
	/**
	 * 获取在检测范围内与当前执行AI具有指定关系的游戏单位数组。
	 * @param relation 用于过滤游戏单位的关系。
	 * @returns 具有指定关系的游戏单位数组。
	 */
	getUnitsByRelation(relation: Relation): Unit[];

	/**
	 * 获取AI检测到的游戏单位数组。
	 * @returns 检测到的游戏单位数组。
	 */
	getDetectedUnits(): Unit[];

	/**
	 * 获取AI检测到的物体数组。
	 * @returns 检测到的物体数组。
	 */
	getDetectedBodies(): Body[];

	/**
	 * 获取与AI具有指定关系的最近的游戏单位。
	 * @param relation 用于过滤游戏单位的关系。
	 * @returns 具有指定关系的最近的游戏单位。
	 */
	getNearestUnit(relation: Relation): Unit;

	/**
	 * 获取到与AI代理具有指定关系的最近游戏单位的距离。
	 * @param relation 用于过滤游戏单位的关系。
	 * @returns 到具有指定关系的最近游戏单位的距离。
	 */
	getNearestUnitDistance(relation: Relation): number;

	/**
	 * 获取在攻击范围内的游戏单位数组。
	 * @returns 在攻击范围内的游戏单位数组。
	 */
	getUnitsInAttackRange(): Unit[];

	/**
	 * 获取在攻击范围内的物体数组。
	 * @returns 在攻击范围内的物体数组。
	 */
	getBodiesInAttackRange(): Body[];
}

/**
 * 用于创建游戏AI结构的决策树框架。
 */
export namespace Decision {
/**
 * 决策树中的叶节点。
 */
class Leaf extends Object {
	private constructor();
}

/**
 * 创建一个带有指定子节点的选择器节点。
 * 选择器节点将遍历子节点，直到其中一个成功。
 * @param nodes 一个AI节点的数组。
 * @returns 代表选择器的AI节点。
 */
export function Sel(this: void, nodes: Leaf[]): Leaf;

/**
 * 创建一个带有指定子节点的序列节点。
 * 序列节点将遍历子节点，直到所有节点成功。
 * @param nodes 一个AI节点的数组。
 * @returns 代表序列的AI节点。
 */
export function Seq(this: void, nodes: Leaf[]): Leaf;

/**
 * 创建一个带有指定名称和处理函数的条件节点。
 * @param name 条件的名称。
 * @param check 接收一个`游戏单位`参数并返回布尔结果的检查函数。
 * @returns 代表条件检查的AI节点。
 */
export function Con(this: void, name: string, check: (this: void, self: Unit) => boolean): Leaf;

/**
 * 创建一个带有指定动作名称的动作节点。
 * @param actionName 要执行的动作的名称。
 * @returns 代表动作的AI节点。
 */
export function Act(this: void, actionName: string): Leaf;

/**
 * 创建一个带有指定处理函数的动作节点。
 * @param handler 接收一个`游戏单位`参数（即正在运行AI的对象）并返回动作的处理函数。
 * @returns 代表动作的AI节点。
 */
export function Act(this: void, handler: (this: void, self: Unit) => string): Leaf;

/**
 * 创建一个代表接受当前行为树的叶节点。
 * 该节点总是返回成功结果。
 * @returns 一个AI节点。
 */
export function Accept(this: void): Leaf;

/**
 * 创建一个代表拒绝当前行为树的叶节点。
 * 该节点总是返回失败结果。
 * @returns 一个AI节点。
 */
export function Reject(this: void): Leaf;

/**
 * 创建一个带有指定行为树作为其根的叶节点。
 * 通过使用Behave()函数，可以将行为树作为决策树中的一个节点。
 * 这允许AI使用决策和行为执行的组合来实现其目标。
 * @param name 行为树的名称。
 * @param root 行为树的根节点。
 * @returns 一个AI节点。
 */
export function Behave(this: void, name: string, root: Behavior.Leaf): Leaf;

/**
 * 单例实例，用于在执行决策树时获取信息。
 */
export const AI: AI;

} // namespace Decision

/**
 * 该类定义了游戏中子弹对象的属性和行为。
 */
class BulletDef extends Object {
	private constructor();

	/**
	 * 子弹对象的标签。
	 */
	tag: string;

	/**
	 * 子弹对象生命周期结束时发生的效果。
	 */
	endEffect: string;

	/**
	 * 子弹对象保持存活状态的时间（以秒为单位）。
	 */
	lifeTime: number;

	/**
	 * 子弹对象的伤害区域半径。
	 */
	damageRadius: number;

	/**
	 * 是否应为做高速运动检测的子弹对象。
	 */
	highSpeedFix: boolean;

	/**
	 * 应用于子弹对象的重力向量。
	 */
	gravity: Vec2;

	/**
	 * 子弹对象的可视组件。
	 */
	face: Face;

	/**
	 * 子弹对象的物理体定义。
	 */
	bodyDef: BodyDef;

	/**
	 * 子弹对象的速度向量。
	 */
	velocity: Vec2;

	/**
	 * 将子弹对象的物理体设为圆形。
	 * @param radius 圆的半径。
	 */
	setAsCircle(radius: number): void;

	/**
	 * 设置子弹对象的速度。
	 * @param angle 速度的角度（以度为单位）。
	 * @param speed 速度的速度。
	 */
	setVelocity(angle: number, speed: number): void;
}

/**
 * @example
 * ```
 * import { BulletDef } from "Platformer";
 * const bulletDef = BulletDef();
 * ```
 */
interface BulletDefClass {
	(this: void): BulletDef;
}

const bulletDefClass: BulletDefClass;
export {bulletDefClass as BulletDef};

/**
 * 该类定义了游戏中子弹对象实例的属性和行为。
 */
class Bullet extends Body {
	private constructor();

	/**
	 * 子弹的允许碰撞对象的定义信息。通过`Platformer.TargetAllow`对象获取。
	 */
	targetAllow: number;

	/**
	 * 子弹对象是否朝右。
	 */
	readonly faceRight: boolean;

	/**
	 * 子弹对象是否应在碰撞时停止。
	 */
	hitStop: boolean;

	/**
	 * 发射子弹的游戏单位对象。
	 */
	readonly emitter: Unit;

	/**
	 * 定义子弹属性和行为的对象。
	 */
	readonly bulletDef: BulletDef;

	/**
	 * 作为子弹可视组件的`Node`对象。
	 */
	face: Node;

	/**
	 * 销毁子弹对象实例。
	 */
	destroy(): void;
}

export namespace Bullet {
	export type Type = Bullet;
}

/**
* 创建新的子弹对象实例的接口类型。
*/
interface BulletClass {
	/**
	 * 创建一个新的子弹对象实例，具有指定的子弹定义和所属游戏单位对象。
	 * @param def 定义子弹的属性和行为的对象。
	 * @param owner 发射子弹的游戏单位对象。
	 * @returns 新的子弹对象实例。
	 */
	(this: void, def: BulletDef, owner: Unit): Bullet;
}

const bulletClass: BulletClass;
export {bulletClass as Bullet};

} // module "Platformer"

declare module "Dora" {
import {
	Behavior,
	Bullet,
	Decision,
	Face,
	PlatformWorld,
	TargetAllow,
	Unit,
	UnitAction,
	Visual,
} from 'Platformer';

type Bullet = Bullet.Type;
type Face = Face.Type;
type PlatformWorld = PlatformWorld.Type;
type TargetAllow = TargetAllow.Type;
type Unit = Unit.Type;
type UnitAction = UnitAction.Type;
type Visual = Visual.Type;

export const enum TypeName {
	Bullet = "Platformer::Bullet",
	Face = "Platformer::Face",
	PlatformWorld = "Platformer::PlatformWorld",
	TargetAllow = "Platformer::TargetAllow",
	Unit = "Platformer::Unit",
	UnitAction = "Platformer::UnitAction",
	Visual = "Platformer::Visual",
	BehaviorBlackboard = "Platformer::Behavior::Blackboard",
	BehaviorLeaf = "Platformer::Behavior::Leaf",
	DecisionLeaf = "Platformer::Decision::Leaf",
}

export interface TypeMap {
	[TypeName.Bullet]: Bullet;
	[TypeName.Face]: Face;
	[TypeName.PlatformWorld]: PlatformWorld;
	[TypeName.TargetAllow]: TargetAllow;
	[TypeName.Unit]: Unit;
	[TypeName.UnitAction]: UnitAction;
	[TypeName.Visual]: Visual;
	[TypeName.BehaviorBlackboard]: Behavior.Blackboard;
	[TypeName.BehaviorLeaf]: Behavior.Leaf;
	[TypeName.DecisionLeaf]: Decision.Leaf;
}

} // module "Dora"
