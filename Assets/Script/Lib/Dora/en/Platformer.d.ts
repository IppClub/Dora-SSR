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

/** A class that represents an action that can be performed by a "Unit". */
class UnitAction {
	private constructor();

	/**
	 * The length of the reaction time for the "UnitAction", in seconds.
	 * The reaction time will affect the AI check cycling time.
	 */
	reaction: number;

	/**
	 * The length of the recovery time for the "UnitAction", in seconds.
	 * The recovery time will mainly affect how long the `Playable` animation model will do transitions between animations played by different actions.
	 */
	recovery: number;

	/** The name of the "UnitAction". */
	readonly name: string;

	/** Whether the "Unit" is currently performing the "UnitAction" or not. */
	readonly doing: boolean;

	/** The elapsed time since the "UnitAction" was started, in seconds. */
	readonly elapsedTime: number;

	/** The "Unit" that owns this "UnitAction". */
	readonly owner: Unit;
}

export namespace UnitAction {
	export type Type = UnitAction;
}

/** An interface that defines the parameters for a "UnitAction". */
export interface UnitActionParam {
	/** The priority level for the "UnitAction". Higher priority (larger number) replaces lower priority "UnitActions". */
	priority: number;

	/** The length of the reaction time for the "UnitAction", in seconds. */
	reaction: number;

	/** The length of the recovery time for the "UnitAction", in seconds. */
	recovery: number;

	/** Whether the "UnitAction" is currently queued or not. The queued "UnitAction" won't replace the running "UnitAction" with a same priority. */
	queued?: boolean;

	/**
	 * A function that determines whether the "UnitAction" is currently available for the specified "Unit".
	 * @param owner The "Unit" that owns the "UnitAction".
	 * @param action The "UnitAction" to check availability for.
	 * @returns True if the "UnitAction" is available for the "Unit", false otherwise.
	 */
	available?(this: void, owner: Unit, action: UnitAction): boolean;

	/**
	 * A function that creates a new function or "Routine.Job" that represents the processing of the "UnitAction".
	 * @param owner The "Unit" that will own the "UnitAction".
	 * @param action The "UnitAction" to create the processing function or "Routine.Job" for.
	 * @param deltaTime The time elapsed since the last frame.
	 * @returns A function or a "Routine.Job" that returns or yields true if the "UnitAction" is complete.
	 */
	create(this: void, owner: Unit, action: UnitAction, deltaTime: number): ((this: void, owner: Unit, action: UnitAction, deltaTime: number) => boolean) | Job;

	/**
	 * A function that gets invoked when the specified "Unit" stops performing the "UnitAction".
	 * @param owner The "Unit" that is stopping the "UnitAction".
	 */
	stop?(this: void, owner: Unit): void;
}

/**
 * An interface that defines and stores the behavior and properties of the "UnitAction" class.
 * It is a singleton object that manages all "UnitAction" objects.
 */
interface UnitActionClass {
	/**
	 * Adds a new "UnitAction" to the "UnitActionClass" with the specified name and parameters.
	 * @param name The name of the new "UnitAction".
	 * @param param The parameters for the new "UnitAction".
	 */
	add(name: string, param: UnitActionParam): void;

	/**
	 * Removes all "UnitAction" objects from the "UnitActionClass".
	 */
	clear(): void;
}

const unitActionClass: UnitActionClass;
export {unitActionClass as UnitAction};

/**
 * A class represents a character or other interactive item in a game scene.
 */
class Unit extends Body {
	private constructor();

	/**
	 * A property that references a "Playable" object for managing the animation state and playback of the "Unit".
	 */
	playable: Playable;

	/**
	 * A property that specifies the maximum distance at which the "Unit" can detect other "Unit" or objects.
	 */
	detectDistance: number;

	/**
	 * A property that specifies the size of the attack range for the "Unit".
	 */
	attackRange: Size;

	/**
	 * A boolean property that specifies whether the "Unit" is facing right or not.
	 */
	faceRight: boolean;

	/**
	 * A boolean property that specifies whether the "Unit" is receiving a trace of the decision tree for debugging purposes.
	 */
	receivingDecisionTrace: boolean;

	/**
	 * A string property that specifies the decision tree to use for the "Unit's" AI behavior.
	 * The decision tree object will be searched in The singleton instance Data.store.
	 */
	decisionTree: string;

	/**
	 * Whether the "Unit" is currently on a surface or not.
	 */
	readonly onSurface: boolean;

	/**
	 * A "Sensor" object for detecting ground surfaces.
	 */
	readonly groundSensor: Sensor;

	/**
	 * A "Sensor" object for detecting other "Unit" objects or physics bodies in the game world.
	 */
	readonly detectSensor: Sensor;

	/**
	 * A "Sensor" object for detecting other "Unit" objects within the attack sensor area.
	 */
	readonly attackSensor: Sensor;

	/**
	 * A "Dictionary" object for defining the properties and behavior of the "Unit".
	 */
	readonly unitDef: Dictionary;

	/**
	 * A property that specifies the current action being performed by the "Unit".
	 */
	readonly currentAction: UnitAction;

	/**
	 * The width of the "Unit".
	 */
	readonly width: number;

	/**
	 * The height of the "Unit".
	 */
	readonly height: number;

	/**
	 * An "Entity" object for representing the "Unit" in the ECS system.
	 */
	readonly entity: Entity;

	/**
	 * Adds a new "UnitAction" to the "Unit" with the specified name, and returns the new "UnitAction".
	 * @param name The name of the new "UnitAction".
	 * @returns The newly created "UnitAction".
	 */
	attachAction(name: string): UnitAction;

	/**
	 * Removes the "UnitAction" with the specified name from the "Unit".
	 * @param name The name of the "UnitAction" to remove.
	 */
	removeAction(name: string): void;

	/**
	 * Removes all "UnitAction" objects from the "Unit".
	 */
	removeAllActions(): void;

	/**
	 * Returns the "UnitAction" with the specified name, or null if the "UnitAction" does not exist.
	 * @param name The name of the "UnitAction" to retrieve.
	 * @returns The "UnitAction" with the specified name, or null.
	 */
	getAction(name: string): UnitAction | null;

	/**
	 * Calls the specified function for each "UnitAction" attached to the "Unit".
	 * @param func A function to call for each "UnitAction".
	 */
	eachAction(func: (this: void, action: UnitAction) => void): void;

	/**
	 * Starts the "UnitAction" with the specified name, and returns true if the "UnitAction" was started successfully.
	 * @param name The name of the "UnitAction" to start.
	 * @returns True if the "UnitAction" was started successfully, false otherwise.
	 */
	start(name: string): boolean;

	/**
	 * Stops the currently running "UnitAction".
	 */
	stop(): void;

	/**
	 * Returns true if the "Unit" is currently performing the specified "UnitAction", false otherwise.
	 * @param name The name of the "UnitAction" to check.
	 * @returns True if the "Unit" is currently performing the specified "UnitAction", false otherwise.
	 */
	isDoing(name: string): boolean;
}

export namespace Unit {
	export type Type = Unit;
}

/**
 * A class for creating instances of Unit.
 */
interface UnitClass {
	/**
	 * The tag for the "GroundSensor" attached to each "Unit".
	 */
	readonly GroundSensorTag: number;

	/**
	 * The tag for the "DetectSensor" attached to each "Unit".
	 */
	readonly DetectSensorTag: number;

	/**
	 * The tag for the "AttackSensor" attached to each "Unit".
	 */
	readonly AttackSensorTag: number;

	/**
	 * A metamethod that creates a new "Unit" object.
	 * @param unitDef A "Dictionary" object that defines the properties and behavior of the "Unit".
	 * @param physicsWorld A "PhysicsWorld" object that represents the physics simulation world.
	 * @param entity An "Entity" object that represents the "Unit" in the ECS system.
	 * @param pos A "Vec2" object that specifies the initial position of the "Unit".
	 * @param rot An optional number that specifies the initial rotation of the "Unit" (default is 0.0).
	 * @returns The newly created "Unit" object.
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
	 * A metamethod that creates a new "Unit" object.
	 * @param unitDefName The name of the "Dictionary" object that defines the properties and behavior of the "Unit" to retrieve from the "Data.store".
	 * @param physicsWorldName The name of the "PhysicsWorld" object that represents the physics simulation world to retrieve from the "Data.store".
	 * @param entity An "Entity" object that represents the "Unit" in the ECS system.
	 * @param pos A "Vec2" object that specifies the initial position of the "Unit".
	 * @param rot An optional number that specifies the initial rotation of the "Unit" (default is 0.0).
	 * @returns The newly created "Unit" object.
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
 * An enum representing the possible relations between two groups.
 */
export const enum Relation {
	Enemy = "Enemy",
	Friend = "Friend",
	Neutral = "Neutral",
	Unknown = "Unknown",
	Any = "Any"
}

/**
 * A singleton object that provides a centralized location for storing and accessing game-related data.
 */
interface Data {
	/**
	 * A group key representing the first index for a player group.
	 */
	readonly groupFirstPlayer: number;

	/**
	 * A group key representing the last index for a player group.
	 */
	readonly groupLastPlayer: number;

	/**
	 * A group key that won't have any contact with other groups by default.
	 */
	readonly groupHide: number;

	/**
	 * A group key that will have contacts with player groups by default.
	 */
	readonly groupDetectPlayer: number;

	/**
	 * A group key representing terrain that will have contacts with other groups by default.
	 */
	readonly groupTerrain: number;

	/**
	 * A group key that will have contacts with other groups by default.
	 */
	readonly groupDetection: number;

	/**
	 * A dictionary that can be used to store arbitrary data associated with string keys and various values globally.
	 */
	readonly store: Dictionary;

	/**
	 * A function that can be used to set a boolean value indicating whether two groups should be in contact or not.
	 * @param groupA An integer representing the first group.
	 * @param groupB An integer representing the second group.
	 * @param contact A boolean indicating whether the two groups should be in contact.
	 */
	setShouldContact(groupA: number, groupB: number, contact: boolean): void;

	/**
	 * A function that can be used to get a boolean value indicating whether two groups should be in contact or not.
	 * @param groupA An integer representing the first group.
	 * @param groupB An integer representing the second group.
	 * @returns Whether the two groups should be in contact.
	 */
	getShouldContact(groupA: number, groupB: number): boolean;

	/**
	 * A function that can be used to set the relation between two groups.
	 * @param groupA An integer representing the first group.
	 * @param groupB An integer representing the second group.
	 * @param relation The relation between the two groups.
	 */
	setRelation(groupA: number, groupB: number, relation: Relation): void;

	/**
	 * A function that can be used to get the relation between two groups.
	 * @param groupA An integer representing the first group.
	 * @param groupB An integer representing the second group.
	 * @returns The relation between the two groups.
	 */
	getRelation(groupA: number, groupB: number): Relation;

	/**
	 * A function that can be used to get the relation between two bodies.
	 * @param bodyA The first body.
	 * @param bodyB The second body.
	 * @returns The relation between the two bodies.
	 */
	getBodyRelation(bodyA: Body, bodyB: Body): Relation;

	/**
	 * A function that returns whether two groups have an "Enemy" relation.
	 * @param groupA An integer representing the first group.
	 * @param groupB An integer representing the second group.
	 * @returns Whether the two groups have an "Enemy" relation.
	 */
	isEnemy(groupA: number, groupB: number): boolean;

	/**
	 * A function that returns whether two bodies have an "Enemy" relation.
	 * @param bodyA The first body.
	 * @param bodyB The second body.
	 * @returns Whether the two bodies have an "Enemy" relation.
	 */
	isBodyEnemy(bodyA: Body, bodyB: Body): boolean;

	/**
	 * A function that returns whether two groups have a "Friend" relation.
	 * @param groupA An integer representing the first group.
	 * @param groupB An integer representing the second group.
	 * @returns Whether the two groups have a "Friend" relation.
	 */
	isFriend(groupA: number, groupB: number): boolean;

	/**
	 * A function that returns whether two bodies have a "Friend" relation.
	 * @param bodyA The first body.
	 * @param bodyB The second body.
	 * @returns Whether the two bodies have a "Friend" relation.
	 */
	isBodyFriend(bodyA: Body, bodyB: Body): boolean;

	/**
	 * A function that returns whether two groups have a "Neutral" relation.
	 * @param groupA An integer representing the first group.
	 * @param groupB An integer representing the second group.
	 * @returns Whether the two groups have a "Neutral" relation.
	 */
	isNeutral(groupA: number, groupB: number): boolean;

	/**
	 * A function that returns whether two bodies have a "Neutral" relation.
	 * @param bodyA The first body.
	 * @param bodyB The second body.
	 * @returns Whether the two bodies have a "Neutral" relation.
	 */
	isBodyNeutral(bodyA: Body, bodyB: Body): boolean;

	/**
	 * A function that sets the bonus factor for a particular type of damage against a particular type of defense.
	 * @param damageType An integer representing the type of damage.
	 * @param defenseType An integer representing the type of defense.
	 * @param bonus A number representing the bonus.
	 */
	setDamageFactor(damageType: number, defenseType: number, bonus: number): void;

	/**
	 * A function that gets the bonus factor for a particular type of damage against a particular type of defense.
	 * @param damageType An integer representing the type of damage.
	 * @param defenseType An integer representing the type of defense.
	 * @returns A number representing the bonus factor.
	 */
	getDamageFactor(damageType: number, defenseType: number): number;

	/**
	 * A function that returns whether a body is a player or not.
	 * @param body The body to check.
	 * @returns Whether the body is a player.
	 */
	isPlayer(body: Body): boolean;

	/**
	 * A function that returns whether a body is terrain or not.
	 * @param body The body to check.
	 * @returns Whether the body is terrain.
	 */
	isTerrain(body: Body): boolean;

	/**
	 * A function that clears all data stored in the "Data" object, including user data in Data.store field.
	 * And reset some data to default values.
	 */
	clear(): void;
}

const data: Data;
export {data as Data};

/**
 * A class that specifies how a bullet object should interact with other game objects or units based on their relationship.
 */
class TargetAllow {
	/**
	 * Whether the bullet object can collide with terrain.
	 */
	terrainAllowed: boolean;

	/**
	 * A function that allows or disallows the bullet object to interact with a game object or unit, based on their relationship.
	 * @param relation The relationship between the bullet object and the other game object or unit.
	 * @param allow Whether the bullet object should be allowed to interact.
	 */
	allow(relation: Relation, allow: boolean): void;

	/**
	 * A function that determines whether the bullet object is allowed to interact with a game object or unit, based on their relationship.
	 * @param relation The relationship between the bullet object and the other game object or unit.
	 * @returns Whether the bullet object is allowed to interact.
	 */
	isAllow(relation: Relation): boolean;

	/**
	 * A function that converts the "TargetAllow" object to a number value.
	 * @returns The number value representing the "TargetAllow" object.
	 */
	toValue(): number;
}

export namespace TargetAllow {
	export type Type = TargetAllow;
}

/**
 * A class that specifies how a bullet object should interact with other game objects or units based on their relationship.
 * @usage
 * const targetAllow = new TargetAllow();
 * targetAllow.terrainAllowed = true;
 * targetAllow.allow("Enemy", true);
 */
interface TargetAllowClass {
	/**
	 * Call this function to create an instance of TargetAllow.
	 * @returns An instance of TargetAllow.
	 */
	(this: void): TargetAllow;
}

const targetAllowClass: TargetAllowClass;
export {targetAllowClass as TargetAllow};

/**
 * A platform camera for 2D platformer games that can track a game unit's movement and keep it within the camera's view.
 */
class PlatformCamera extends Camera {
	private constructor();

	/**
	 * The camera's position.
	 */
	position: Vec2;

	/**
	 * The camera's rotation in degrees.
	 */
	rotation: number;

	/**
	 * The camera's zoom factor, 1.0 means the normal size, 2.0 mean zoom to doubled size.
	 */
	zoom: number;

	/**
	 * The rectangular area within which the camera is allowed to view.
	 */
	boundary: Rect;

	/**
	 * The ratio at which the camera should move to keep up with the target's position.
	 * For example, set to `Vec2(1.0, 1.0)`, then the camera will keep up to the target's position right away.
	 * Set to Vec2(0.5, 0.5) or smaller value, then the camera will move halfway to the target's position each frame, resulting in a smooth and gradual movement.
	 */
	followRatio: Vec2;

	/**
	 * The game unit that the camera should track.
	 */
	followTarget: Node;
}

export namespace PlatformCamera {
	export type Type = PlatformCamera;
}

/**
 * A class that defines how to create instances of PlatformCamera.
 */
interface PlatformCameraClass {
	/**
	 * Creates a new instance of PlatformCamera.
	 * @param name [optional] The name of the new instance, default is an empty string.
	 * @returns The new PlatformCamera instance.
	 */
	(this: void, name?: string): PlatformCamera;
}

const platformCameraClass: PlatformCameraClass;
export {platformCameraClass as PlatformCamera};

/**
 * A class representing a 2D platformer game world with physics simulations.
 */
class PlatformWorld extends PhysicsWorld {
	private constructor();

	/**
	 * The camera used to control the view of the game world.
	 */
	readonly camera: PlatformCamera;

	/**
	 * Moves a child node to a new order for a different layer.
	 * @param child The child node to be moved.
	 * @param newOrder The new order of the child node.
	 */
	moveChild(child: Node, newOrder: number): void;

	/**
	 * Gets the layer node at a given order.
	 * @param order The order of the layer node to get.
	 * @returns The layer node at the given order.
	 */
	getLayer(order: number): Node;

	/**
	 * Sets the parallax moving ratio for a given layer to simulate 3D projection effect.
	 * @param order The order of the layer to set the ratio for.
	 * @param ratio The new parallax ratio for the layer.
	 */
	setLayerRatio(order: number, ratio: Vec2): void;

	/**
	 * Gets the parallax moving ratio for a given layer.
	 * @param order The order of the layer to get the ratio for.
	 * @returns The parallax ratio for the layer.
	 */
	getLayerRatio(order: number): Vec2;

	/**
	 * Sets the position offset for a given layer.
	 * @param order The order of the layer to set the offset for.
	 * @param offset The new position offset for the layer.
	 */
	setLayerOffset(order: number, offset: Vec2): void;

	/**
	 * Gets the position offset for a given layer.
	 * @param order The order of the layer to get the offset for.
	 * @returns The position offset for the layer.
	 */
	getLayerOffset(order: number): Vec2;

	/**
	 * Swaps the positions of two layers.
	 * @param orderA The order of the first layer to swap.
	 * @param orderB The order of the second layer to swap.
	 */
	swapLayer(orderA: number, orderB: number): void;

	/**
	 * Removes a layer from the game world.
	 * @param order The order of the layer to remove.
	 */
	removeLayer(order: number): void;

	/**
	 * Removes all layers from the game world.
	 */
	removeAllLayers(): void;
}

export namespace PlatformWorld {
	export type Type = PlatformWorld;
}

/**
 * A class for instantiating instances of PlatformWorld.
 * @example
 * ```
 * const world = PlatformWorldClass();
 * world.addTo(entry);
 * ```
 */
interface PlatformWorldClass {
	/**
	 * The metamethod to create a new instance of PlatformWorld.
	 * @returns A new instance of PlatformWorld.
	 */
	(this: void): PlatformWorld;
}

const platformWorldClass: PlatformWorldClass;
export {platformWorldClass as PlatformWorld};

/**
 * Represents a definition for a visual component of a game bullet or other visual item.
 */
class Face extends Node {
	/**
	 * Adds a child `Face` definition to it.
	 * @param face The child `Face` to add.
	 */
	addChild(face: Face): void;

	/**
	 * Returns a node that can be added to a scene tree for rendering.
	 * @returns The `Node` representing this `Face`.
	 */
	toNode(): Node;
}

export namespace Face {
	export type Type = Face;
}

/**
 * An interface provides functions for creating instances of the `Face` component with different configurations.
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
	 * Creates a new `Face` definition using the specified attributes.
	 * @param faceStr A string for creating the `Face` component.
	 * Could be 'Image/file.png' and 'Image/items.clip|itemA'.
	 * @param point The position of the `Face` component, default is `Vec2.zero`.
	 * @param scale The scale of the `Face` component, default is 1.0.
	 * @param angle The angle of the `Face` component, default is 0.0.
	 * @returns The new `Face` component.
	 */
	(
		this: void,
		faceStr: string,
		point?: Vec2,
		scale?: number,
		angle?: number
	): Face;

	/**
	 * Creates a new `Face` definition using the specified attributes.
	 * @param createFunc A function that returns a `Node` representing the `Face` component.
	 * @param point The position of the `Face` component, default is `Vec2.zero`.
	 * @param scale The scale of the `Face` component, default is 1.0.
	 * @param angle The angle of the `Face` component, default is 0.0.
	 * @returns The new `Face` component.
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
 * A class to represent a visual effect object like Particle, Frame Animation, or just a Sprite.
 */
class Visual extends Node {
	private constructor();

	/**
	 * Whether the visual effect is currently playing or not.
	 */
	playing: boolean;

	/**
	 * Starts playing the visual effect.
	 */
	start(): void;

	/**
	 * Stops playing the visual effect.
	 */
	stop(): void;

	/**
	 * Automatically removes the visual effect from the game world when it finishes playing.
	 * @returns The same "Visual" object that was passed in as a parameter.
	 */
	autoRemove(): Visual;
}

export namespace Visual {
	export type Type = Visual;
}

/**
* A class for creating "Visual" objects.
*/
interface VisualClass {
	/**
	 * Creates a new "Visual" object with the specified name.
	 * @param name The name of the new "Visual" object.
	 * Could be a particle file, a frame animation file, or an image file.
	 * @returns The new "Visual" object.
	 */
	(this: void, name: string): Visual;
}

const visualClass: VisualClass;
export {visualClass as Visual};

/** A behavior tree framework for creating game AI structures. */
export namespace Behavior {
/**
 * A blackboard object that can be used to store data for behavior tree nodes.
 */
class Blackboard {
	private constructor();

	/**
	 * The time since the last frame update in seconds.
	 */
	deltaTime: number;

	/**
	 * The unit that the AI agent belongs to.
	 */
	owner: Unit;

	/**
	 * A method to index the blackboard properties.
	 * @param key The key to index.
	 * @returns The value associated with the key.
	 */
	[key: string]: Item;
}

/**
 * A leaf node in a behavior tree.
 */
class Leaf extends Object {
	private constructor();
}

/**
 * Creates a new sequence node that executes an array of child nodes in order.
 * @param nodes An array of child nodes.
 * @returns A new sequence node.
 */
export function Seq(this: void, nodes: Leaf[]): Leaf;

/**
 * Creates a new selector node that selects and executes one of its child nodes that will succeed.
 * @param nodes An array of child nodes.
 * @returns A new selector node.
 */
export function Sel(this: void, nodes: Leaf[]): Leaf;

/**
 * Creates a new condition node that executes a check handler function when executed.
 * @param name The name of the condition.
 * @param check A function that takes a blackboard object and returns a boolean value.
 * @returns A new condition node.
 */
export function Con(this: void, name: string, check: (this: void, board: Blackboard) => boolean): Leaf;

/**
 * Creates a new action node that executes an action when executed.
 * This node will block the execution until the action finishes.
 * @param actionName The name of the action to execute.
 * @returns A new action node.
 */
export function Act(this: void, actionName: string): Leaf;

/**
 * Creates a new command node that executes a command when executed.
 * This node will return right after the action starts.
 * @param actionName The name of the command to execute.
 * @returns A new command node.
 */
export function Command(this: void, actionName: string): Leaf;

/**
 * Creates a new wait node that waits for a specified duration when executed.
 * @param duration The duration to wait in seconds.
 * @returns A new wait node.
 */
export function Wait(this: void, duration: number): Leaf;

/**
 * Creates a new countdown node that executes a child node continuously until a timer runs out.
 * @param time The time limit in seconds.
 * @param node The child node to execute.
 * @returns A new countdown node.
 */
export function Countdown(this: void, time: number, node: Leaf): Leaf;

/**
 * Creates a new timeout node that executes a child node until a timer runs out.
 * @param time The time limit in seconds.
 * @param node The child node to execute.
 * @returns A new timeout node.
 */
export function Timeout(this: void, time: number, node: Leaf): Leaf;

/**
 * Creates a new repeat node that executes a child node a specified number of times.
 * @param times The number of times to execute the child node.
 * @param node The child node to execute.
 * @returns A new repeat node.
 */
export function Repeat(this: void, times: number, node: Leaf): Leaf;

/**
 * Creates a new repeat node that executes a child node repeatedly.
 * @param node The child node to execute.
 * @returns A new repeat node.
 */
export function Repeat(this: void, node: Leaf): Leaf;

/**
 * Creates a new retry node that executes a child node repeatedly until it succeeds or a maximum number of retries is reached.
 * @param times The maximum number of retries.
 * @param node The child node to execute.
 * @returns A new retry node.
 */
export function Retry(this: void, times: number, node: Leaf): Leaf;

/**
 * Creates a new retry node that executes a child node repeatedly until it succeeds.
 * @param node The child node to execute.
 * @returns A new retry node.
 */
export function Retry(this: void, node: Leaf): Leaf;

} // namespace Behavior

/**
 * The singleton interface to retrieve information when executing the decision tree.
 */
interface AI {
	/**
	 * Gets an array of units in detection range that have the specified relation to current AI agent.
	 * @param relation The relation to filter the units by.
	 * @returns An array of units with the specified relation.
	 */
	getUnitsByRelation(relation: Relation): Unit[];

	/**
	 * Gets an array of units that the AI has detected.
	 * @returns An array of detected units.
	 */
	getDetectedUnits(): Unit[];

	/**
	 * Gets an array of bodies that the AI has detected.
	 * @returns An array of detected bodies.
	 */
	getDetectedBodies(): Body[];

	/**
	 * Gets the nearest unit that has the specified relation to the AI.
	 * @param relation The relation to filter the units by.
	 * @returns The nearest unit with the specified relation.
	 */
	getNearestUnit(relation: Relation): Unit;

	/**
	 * Gets the distance to the nearest unit that has the specified relation to the AI agent.
	 * @param relation The relation to filter the units by.
	 * @returns The distance to the nearest unit with the specified relation.
	 */
	getNearestUnitDistance(relation: Relation): number;

	/**
	 * Gets an array of units that are within attack range.
	 * @returns An array of units in attack range.
	 */
	getUnitsInAttackRange(): Unit[];

	/**
	 * Gets an array of bodies that are within attack range.
	 * @returns An array of bodies in attack range.
	 */
	getBodiesInAttackRange(): Body[];
}

/**
 * A decision tree framework for creating game AI structures.
 */
export namespace Decision {
/**
 * A leaf node in a decision tree.
 */
class Leaf extends Object {
	private constructor();
}

/**
 * Creates a selector node with the specified child nodes.
 * A selector node will go through the child nodes until one succeeds.
 * @param nodes An array of `Leaf` nodes.
 * @returns A `Leaf` node that represents a selector.
 */
export function Sel(this: void, nodes: Leaf[]): Leaf;

/**
 * Creates a sequence node with the specified child nodes.
 * A sequence node will go through the child nodes until all nodes succeed.
 * @param nodes An array of `Leaf` nodes.
 * @returns A `Leaf` node that represents a sequence.
 */
export function Seq(this: void, nodes: Leaf[]): Leaf;

/**
 * Creates a condition node with the specified name and handler function.
 * @param name The name of the condition.
 * @param check The check function that takes a `Unit` parameter and returns a boolean result.
 * @returns A `Leaf` node that represents a condition check.
 */
export function Con(this: void, name: string, check: (this: void, self: Unit) => boolean): Leaf;

/**
 * Creates an action node with the specified action name.
 * @param actionName The name of the action to perform.
 * @returns A `Leaf` node that represents an action.
 */
export function Act(this: void, actionName: string): Leaf;

/**
 * Creates an action node with the specified handler function.
 * @param handler The handler function that takes a `Unit` parameter which is the running AI agent and returns an action.
 * @returns A `Leaf` node that represents an action.
 */
export function Act(this: void, handler: (this: void, self: Unit) => string): Leaf;

/**
 * Creates a leaf node that represents accepting the current behavior tree.
 * Always get a success result from this node.
 * @returns A `Leaf` node.
 */
export function Accept(this: void): Leaf;

/**
 * Creates a leaf node that represents rejecting the current behavior tree.
 * Always get a failure result from this node.
 * @returns A `Leaf` node.
 */
export function Reject(this: void): Leaf;

/**
 * Creates a leaf node with the specified behavior tree as its root.
 * It is possible to include a Behavior Tree as a node in a Decision Tree by using the Behave() function.
 * This allows the AI to use a combination of decision-making and behavior execution to achieve its goals.
 * @param name The name of the behavior tree.
 * @param root The root node of the behavior tree.
 * @returns A `Leaf` node.
 */
export function Behave(this: void, name: string, root: Behavior.Leaf): Leaf;

/**
 * The singleton instance to retrieve information while executing the decision tree. */
export const AI: AI;

} // namespace Decision

/**
 * A class type that specifies the properties and behaviors of a bullet object in the game.
 */
class BulletDef extends Object {
	private constructor();

	/**
	 * The tag for the bullet object.
	 */
	tag: string;

	/**
	 * The effect that occurs when the bullet object ends its life.
	 */
	endEffect: string;

	/**
	 * The amount of time in seconds that the bullet object remains active.
	 */
	lifeTime: number;

	/**
	 * The radius of the bullet object's damage area.
	 */
	damageRadius: number;

	/**
	 * Whether the bullet object should be fixed for high speeds.
	 */
	highSpeedFix: boolean;

	/**
	 * The gravity vector that applies to the bullet object.
	 */
	gravity: Vec2;

	/**
	 * The visual item of the bullet object.
	 */
	face: Face;

	/**
	 * The physics body definition for the bullet object.
	 */
	bodyDef: BodyDef;

	/**
	 * The velocity vector of the bullet object.
	 */
	velocity: Vec2;

	/**
	 * Sets the bullet object's physics body as a circle.
	 * @param radius The radius of the circle.
	 */
	setAsCircle(radius: number): void;

	/**
	 * Sets the velocity of the bullet object.
	 * @param angle The angle of the velocity in degrees.
	 * @param speed The speed of the velocity.
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
 * A class type that defines the properties and behavior of a bullet object instance in the game.
 */
class Bullet extends Body {
	private constructor();

	/**
	 * The value from a `Platformer.TargetAllow` object for the bullet object.
	 */
	targetAllow: number;

	/**
	 * Whether the bullet object is facing right.
	 */
	readonly faceRight: boolean;

	/**
	 * Whether the bullet object should stop on impact.
	 */
	hitStop: boolean;

	/**
	 * The `Unit` object that fired the bullet.
	 */
	readonly emitter: Unit;

	/**
	 * The `BulletDef` object that defines the bullet's properties and behavior.
	 */
	readonly bulletDef: BulletDef;

	/**
	 * The `Node` object that appears as the bullet's visual item.
	 */
	face: Node;

	/**
	 * Destroys the bullet object instance.
	 */
	destroy(): void;
}

export namespace Bullet {
	export type Type = Bullet;
}

/**
* An interface type that creates new `Bullet` object instances.
*/
interface BulletClass {
	/**
	 * A metamethod that creates a new `Bullet` object instance with the specified `BulletDef` and `Unit` objects.
	 * @param def The `BulletDef` object that defines the bullet's properties and behavior.
	 * @param owner The `Unit` object that fired the bullet.
	 * @returns The new `Bullet` object instance.
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
