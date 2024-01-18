import type * as dora from 'dora';

declare global {
namespace JSX {
interface Ref<T> {
	readonly current: T | null;
}

class Node {
	ref?: Ref<dora.Node.Type>;

	/** The order of the node in the parent's children array. */
	order?: number;

	/** The rotation angle of the node in degrees. */
	angle?: number;

	/** The X-axis rotation angle of the node in degrees. */
	angleX?: number;

	/** The Y-axis rotation angle of the node in degrees. */
	angleY?: number;

	/** The X-axis scale factor of the node. */
	scaleX?: number;

	/** The Y-axis scale factor of the node. */
	scaleY?: number;

	/** The X-axis position of the node. */
	x?: number;

	/** The Y-axis position of the node. */
	y?: number;

	/** The Z-axis position of the node. */
	z?: number;

	/** The X-axis skew angle of the node in degrees. */
	skewX?: number;

	/** The Y-axis skew angle of the node in degrees. */
	skewY?: number;

	/** Whether the node is visible. */
	visible?: boolean;

	/** The X-axis anchor value. */
	anchorX?: number;

	/** The Y-axis anchor value. */
	anchorY?: number;

	/** The width of the node. */
	width?: number;

	/** The height of the node. */
	height?: number;

	/** The tag of the node as a string. */
	tag?: string;

	/** The opacity of the node, should be 0 to 1.0. */
	opacity?: number;

	/** The color of the node in format 0xffffff (RGB). */
	color3?: number;

	/** Whether to pass the opacity value to child nodes. */
	passOpacity?: boolean;

	/** Whether to pass the color value to child nodes. */
	passColor3?: boolean;

	/** Whether touch events are enabled on the node. */
	touchEnabled?: boolean;

	/** Whether the node should swallow touch events. */
	swallowTouches?: boolean;

	/** Whether the node should swallow mouse wheel events. */
	swallowMouseWheel?: boolean;

	/** Whether keyboard events are enabled on the node. */
	keyboardEnabled?: boolean;

	/** Whether controller events are enabled on the node. */
	controllerEnabled?: boolean;

	/** Whether to group the node's rendering with all its recursive children. */
	renderGroup?: boolean;

	/** The rendering order number for group rendering. Nodes with lower rendering orders are rendered earlier. */
	renderOrder?: number;

	children?: any[] | any

	/**
	 * The ActionEnd slot is triggered when an action is finished.
	 * Triggers after `node.runAction()` and `node.perform()`.
	 * @param action The finished action.
	 * @param target The node that finished the action.
	 */
	onActionEnd?(this: void, action: dora.Action.Type, target: dora.Node.Type): void;

	/**
	 * The TapFilter slot is triggered before the TapBegan slot and can be used to filter out certain taps.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param touch The touch that triggered the tap.
	*/
	onTapFilter?(this: void, touch: dora.Touch.Type): void;

	/**
	 * The TapBegan slot is triggered when a tap is detected.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param touch The touch that triggered the tap.
	*/
	onTapBegan?(this: void, touch: dora.Touch.Type): void;

	/**
	 * The TapEnded slot is triggered when a tap ends.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param touch The touch that triggered the tap.
	*/
	onTapEnded?(this: void, touch: dora.Touch.Type): void;

	/**
	 * The Tapped slot is triggered when a tap is detected and has ended.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param touch The touch that triggered the tap.
	*/
	onTapped?(this: void, touch: dora.Touch.Type): void;

	/**
	 * The TapMoved slot is triggered when a tap moves.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param touch The touch that triggered the tap.
	*/
	onTapMoved?(this: void, touch: dora.Touch.Type): void;

	/**
	 * The MouseWheel slot is triggered when the mouse wheel is scrolled.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param delta The amount of scrolling that occurred.
	*/
	onMouseWheel?(this: void, delta: dora.Vec2.Type): void;

	/**
	 * The Gesture slot is triggered when a gesture is recognized.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param center The center of the gesture.
	 * @param numFingers The number of fingers involved in the gesture.
	 * @param deltaDist The distance the gesture has moved.
	 * @param deltaAngle The angle of the gesture.
	*/
	onGesture?(this: void, center: dora.Vec2.Type, numFingers: number, deltaDist: number, deltaAngle: number): void;

	/**
	 * The Enter slot is triggered when a node is added to the scene graph.
	 * Triggers when doing `node.addChild()`.
	*/
	onEnter?(this: void): void;

	/**
	 * The Exit slot is triggered when a node is removed from the scene graph.
	 * Triggers when doing `node.removeChild()`.
	*/
	onExit?(this: void): void;

	/**
	 * The Cleanup slot is triggered when a node is cleaned up.
	 * Triggers only when doing `parent.removeChild(node, true)`.
	*/
	onCleanup?(this: void): void;

	/**
	 * The KeyDown slot is triggered when a key is pressed down.
	 * Triggers after setting `node.keyboardEnabled = true`.
	 * @param keyName The name of the key that was pressed.
	*/
	onKeyDown?(this: void, keyName: dora.KeyName): void;

	/**
	 * The KeyUp slot is triggered when a key is released.
	 * Triggers after setting `node.keyboardEnabled = true`.
	 * @param keyName The name of the key that was released.
	*/
	onKeyUp?(this: void, keyName: dora.KeyName): void;

	/**
	 * The KeyPressed slot is triggered when a key is pressed.
	 * Triggers after setting `node.keyboardEnabled = true`.
	 * @param keyName The name of the key that was pressed.
	*/
	onKeyPressed?(this: void, keyName: dora.KeyName): void;

	/**
	 * The AttachIME slot is triggered when the input method editor (IME) is attached (calling `node.attachIME()`).
	*/
	onAttachIME?(this: void): void;

	/**
	 * The DetachIME slot is triggered when the input method editor (IME) is detached (calling `node.detachIME()` or manually closing IME).
	*/
	onDetachIME?(this: void): void;

	/**
	 * The TextInput slot is triggered when text input is received.
	 * Triggers after calling `node.attachIME()`.
	 * @param text The text that was input.
	*/
	onTextInput?(this: void, text: string): void;

	/**
	 * The TextEditing slot is triggered when text is being edited.
	 * Triggers after calling `node.attachIME()`.
	 * @param text The text that is being edited.
	 * @param startPos The starting position of the text being edited.
	*/
	onTextEditing?(this: void, text: string, startPos: number): void;

	/**
	 * The ButtonDown slot is triggered when a game controller button is pressed down.
	 * Triggers after setting `node.controllerEnabled = true`.
	 * @param controllerId The controller id, incrementing from 0 when multiple controllers connected.
	 * @param buttonName The name of the button that was pressed.
	*/
	onButtonDown?(this: void, controllerId: number, buttonName: dora.ButtonName): void;

	/**
	 * The ButtonUp slot is triggered when a game controller button is released.
	 * Triggers after setting `node.controllerEnabled = true`.
	 * @param controllerId The controller id, incrementing from 0 when multiple controllers connected.
	 * @param buttonName The name of the button that was released.
	*/
	onButtonUp?(this: void, controllerId: number, buttonName: dora.ButtonName): void;

	/**
	 * The Axis slot is triggered when a game controller axis changed.
	 * Triggers after setting `node.controllerEnabled = true`.
	 * @param controllerId The controller id, incrementing from 0 when multiple controllers connected.
	 * @param axisValue The controller axis value ranging from -1.0 to 1.0.
	*/
	onAxis?(this: void, controllerId: number, axisValue: number): void;
}

class ClipNode extends Node {
	ref?: Ref<dora.ClipNode.Type>;

	/**
	 * The stencil Node that defines the clipping shape.
	 */
	stencil: Node;

	/**
	 * The minimum alpha threshold for a pixel to be visible. Value ranges from 0 to 1.
	 */
	alphaThreshold?: number;

	/**
	 * Whether to invert the clipping area.
	 */
	inverted?: boolean;
}

class Playable extends Node {
	ref?: Ref<dora.Playable.Type>;

	/**
	 * The look of the animation.
	 */
	look?: string;

	/**
	 * The play speed of the animation.
	 */
	speed?: number;

	/**
	 * The recovery time of the animation, in seconds.
	 * Used for doing transitions from one animation to another animation.
	 */
	recovery?: number;

	/**
	 * Whether the animation is flipped horizontally.
	 */
	fliped?: boolean;

	/**
	 * The filename of the animation file to load.
	 * Supports DragonBone, Spine2D, and Dora Model files.
	 * Should be one of the formats below:
	 *  "model:" + modelFile
	 *  "spine:" + spineStr
	 *  "bone:" + dragonBoneStr
	 */
	file: string;

	/**
	 * The name of the animation to play.
	 */
	play?: string;

	/**
	 * Whether to loop the animation or not (default is false).
	 */
	loop?: boolean;

	/**
	 * Triggers after an animation has ended on a Playable instance.
	 * @param animationName The name of the animation that ended.
	 * @param target The Playable instance that the animation was played on.
	*/
	onAnimationEnd?(this: void, animationName: string, target: dora.Playable.Type): void;
}

class DragonBone extends Playable {
	ref?: Ref<dora.DragonBone.Type>;

	/**
	 * The DragonBone file string for the new instance.
	 * A DragonBone file string can be a file path with the target file extention like "DragonBone/item" or file paths with all the related files like "DragonBone/item_ske.json|DragonBone/item_tex.json".
	 * And the an armature name can be added following a seperator of ';'. like "DragonBone/item;mainArmature" or "DragonBone/item_ske.json|DragonBone/item_tex.json;mainArmature".
	 */
	file: string;

	/**
	 * Whether to show debug graphics.
	 */
	showDebug?: boolean;

	/**
	 * Whether hit testing is enabled.
	 */
	hitTestEnabled?: boolean;
}

class Spine extends Playable {
	ref?: Ref<dora.Spine.Type>;

	/**
	 * The Spine file string for the new instance.
	 * A Spine file string can be a file path with the target file extention like "Spine/item" or file paths with all the related files like "Spine/item.skel|Spine/item.atlas" or "Spine/item.json|Spine/item.atlas".
	 */
	file: string;

	/** Whether to show debug graphics. */
	showDebug?: boolean;

	/** Whether hit testing is enabled. */
	hitTestEnabled?: boolean;
}

class Model extends Playable {
	ref?: Ref<dora.Model.Type>;

	/**
	 * The filename of the model file to load.
	 * Can be filename with or without extension like: "Model/item" or "Model/item.model".
	 */
	file: string;

	/**
	 * Whether the animation model will be played in reverse.
	 */
	reversed?: boolean;
}

class Dot {
	/**
	 * The X position of the dot.
	 */
	x: number;

	/**
	 * The Y position of the dot.
	 */
	y: number;

	/**
	 * The radius of the dot.
	 */
	radius: number;

	/**
	 * The color of the dot (default is white).
	 */
	color?: number;
}

class Segment {
	/**
	 * The starting X position of the line.
	 */
	startX: number;

	/**
	 * The starting Y position of the line.
	 */
	startY: number;

	/**
	 * The ending X position of the line.
	 */
	stopX: number;

	/**
	 * The ending Y position of the line.
	 */
	stopY: number;

	/**
	 * The radius of the line.
	 */
	radius: number;

	/**
	 * The color of the line in format 0xffffffff (ARGB, default is white).
	 */
	color?: number;
}

class Polygon {
	/*
	 * The vertices of the polygon.
	 */
	verts: dora.Vec2.Type[];

	/* 
	 * The fill color of the polygon in format 0xffffffff (ARGB, default is white).
	 */
	fillColor?: number;

	/**
	 * The width of the border (default is 0).
	 */
	borderWidth?: number;

	/**
	 * The color of the border in format 0xffffffff (ARGB, default is white).
	 */
	borderColor?: number;
}

class Verts {
	/*
	 * The list of vertices and their colors in format 0xffffffff (ARGB).
	 */
	verts: [vert: dora.Vec2.Type, color: number][];
}

class DrawNode extends Node {
	ref?: Ref<dora.DrawNode.Type>;

	/**
	 * Whether to write to the depth buffer when drawing (default is false).
	 */
	depthWrite?: boolean;

	/**
	 * The blend function used to draw the shape.
	 */
	blendFunc?: dora.BlendFunc.Type;
}

class Grid extends Node {
	ref?: Ref<dora.Grid.Type>;

	/**
	 * The filename of texture used for the grid.
	 * Can be a clip string of "Image/file.png" or "Image/items.clip|itemA".
	 */
	file: string;

	/** The number of columns in the grid. There are `gridX + 1` vertices horizontally for rendering. */
	gridX: number;

	/** The number of rows in the grid. There are `gridY + 1` vertices vertically for rendering. */
	gridY: number;

	/** Whether depth writes are enabled (default is false). */
	depthWrite?: boolean;

	/** The rectangle within the texture that is used for the grid. */
	textureRect?: dora.Rect.Type;

	/** The blending function used for the grid. */
	blendFunc?: dora.BlendFunc.Type;

	/** The sprite effect applied to the grid. Default is `SpriteEffect("builtin:vs_sprite", "builtin:fs_sprite")`. */
	effect?: dora.SpriteEffect.Type;
}

class Sprite extends Node {
	ref?: Ref<dora.Sprite.Type>;

	/**
	 * The string containing format for loading a texture file.
	 * Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.
	 */
	file: string;

	/**
	 * Whether the depth buffer should be written to when rendering the sprite (default is false).
	 */
	depthWrite?: boolean;

	/**
	 * The alpha reference value for alpha testing. Pixels with alpha values less than or equal to this value will be discarded.
	 * Only works with `sprite.effect = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritealphatest")`.
	 */
	alphaRef?: number;

	/**
	 * The texture rectangle for the sprite.
	 */
	textureRect?: dora.Rect.Type;

	/**
	 * The blend function for the sprite.
	 */
	blendFunc?: dora.BlendFunc.Type;

	/**
	 * The sprite shader effect.
	 */
	effect?: dora.SpriteEffect.Type;

	/**
	 * The texture wrapping mode for the U (horizontal) axis.
	 */
	uwrap?: dora.TextureWrap;

	/**
	 * The texture wrapping mode for the V (vertical) axis.
	 */
	vwrap?: dora.TextureWrap;

	/**
	 * The texture filtering mode for the sprite.
	 */
	filter?: dora.TextureFilter;
}

class Label extends Node {
	ref?: Ref<dora.Label.Type>;

	/**
	 * The name of the font to use for the label. Can be a font file path with or without a file extension.
	 */
	fontName: string;

	/**
	 * The size of the font to use for the label.
	 */
	fontSize: number;

	/**
	 * The alpha threshold value. Pixels with alpha values below this value will not be drawn.
	 * Only works with `label.effect = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritealphatest")`.
	 */
	alphaRef?: number;

	/**
	 * The width of the text used for text wrapping.
	 * Set to `Label.AutomaticWidth` to disable wrapping.
	 * Default is `Label.AutomaticWidth`.
	 */
	textWidth?: number;

	/**
	 * The gap in pixels between lines of text.
	 */
	lineGap?: number;

	/**
	 * The text to be rendered.
	 */
	text?: string;

	/**
	 * The blend function used to render the text.
	 */
	blendFunc?: dora.BlendFunc.Type;

	/**
	 * Whether depth writing is enabled. (Default is false)
	 */
	depthWrite?: boolean;

	/**
	 * Whether the label is using batched rendering.
	 * When using batched rendering, the `label.getCharacter()` function will no longer work, and getting better rendering performance. (Default is true)
	 */
	batched?: boolean;

	/**
	 * The sprite effect used to render the text.
	 */
	effect?: dora.SpriteEffect.Type;

	/**
	 * The text alignment setting. (Default is `TextAlign.Center`)
	 */
	alignment?: dora.TextAlign;
}

class Line extends Node {
	ref?: Ref<dora.Line.Type>;

	/**
	 * Whether the depth should be written. (Default is false)
	 */
	depthWrite?: boolean;

	/**
	 * Blend function used for rendering the line.
	 */
	blendFunc?: dora.BlendFunc.Type;

	/**
	 * List of vertices to set to the line.
	 */
	verts: dora.Vec2.Type[];

	/**
	 * Color of the line in format 0xffffffff (ARGB, default is opaque white).
	 */
	lineColor?: number;
}

class Particle extends Node {
	ref?: Ref<dora.Particle.Type>;

	/**
	 * The file path of the particle system definition file.
	 */
	file: string;

	/**
	 * Whether to start emitting particles after creating (Default is false).
	 */
	emit?: boolean;

	/**
	 * Triggered after a Particle node started a stop action and then all the active particles end their lives.
	*/
	onFinished?(this: void): void;
}

class Menu extends Node {
	ref?: Ref<dora.Menu.Type>;

	/**
	 * Whether the menu is currently enabled or disabled.
	 */
	enabled?: boolean;
}

class Action {
	ref?: Ref<dora.ActionDef.Type>;
	children: any[] | any;
}

class AnchorX {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the anchor point. */
	start: number;
	/** The ending value of the anchor point. */
	stop: number;
	easing?: dora.EaseFunc;
}

class AnchorY {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the anchor point. */
	start: number;
	/** The ending value of the anchor point. */
	stop: number;
	easing?: dora.EaseFunc;
}

class Angle {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the angle in degrees. */
	start: number;
	/** The ending value of the angle in degrees. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Linear if not specified. */
	easing?: dora.EaseFunc;
}

class AngleX {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the x-axis rotation angle in degrees. */
	start: number;
	/** The ending value of the x-axis rotation angle in degrees. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: dora.EaseFunc;
}

class AngleY {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the y-axis rotation angle in degrees. */
	start: number;
	/** The ending value of the y-axis rotation angle in degrees. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: dora.EaseFunc;
}

class Delay {
	/** The duration of the delay in seconds. */
	time: number;
}

class Event {
	/** The name of the event to be triggered. */
	name: string;
	/** The parameter to pass to the event. (default: "") */
	param?: string;
}

class Width {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting width value of the Node. */
	start: number;
	/** The ending width value of the Node. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: dora.EaseFunc;
}

class Height {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting height value of the Node. */
	start: number;
	/** The ending height value of the Node. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: dora.EaseFunc;
}

class Hide {}

class Show {}

class Move {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting x position of the Node. */
	startX: number;
	/** The starting y position of the Node. */
	startY: number;
	/** The ending x position of the Node. */
	stopX: number;
	/** The ending y position of the Node. */
	stopY: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: dora.EaseFunc;
}

class Opacity {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting opacity value of the Node (0 - 1.0). */
	start: number;
	/** The ending opacity value of the Node (0 - 1.0). */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: dora.EaseFunc;
}

class Roll {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting roll value of the Node (in degrees). */
	start: number;
	/** The ending roll value of the Node (in degrees). */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: dora.EaseFunc;
}

class Scale {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the x-axis and y-axis scale. */
	start: number;
	/** The ending value of the x-axis and y-axis scale. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: dora.EaseFunc;
}

class ScaleX {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the x-axis scale. */
	start: number;
	/** The ending value of the x-axis scale. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: dora.EaseFunc;
}

class ScaleY {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the y-axis scale. */
	start: number;
	/** The ending value of the y-axis scale. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: dora.EaseFunc;
}

class SkewX {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting skew value of the Node on the x-axis (in degrees). */
	start: number;
	/** The ending skew value of the Node on the x-axis (in degrees). */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: dora.EaseFunc;
}

class SkewY {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting skew value of the Node on the y-axis (in degrees). */
	start: number;
	/** The ending skew value of the Node on the y-axis (in degrees). */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: dora.EaseFunc;
}

class MoveX {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting x-position of the Node. */
	start: number;
	/** The ending x-position of the Node. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: dora.EaseFunc;
}

class MoveY {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting y-position of the Node. */
	start: number;
	/** The ending y-position of the Node. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: dora.EaseFunc;
}

class MoveZ {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting z-position of the Node. */
	start: number;
	/** The ending z-position of the Node. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: dora.EaseFunc;
}

class Spawn {
	/** The action definitions to run in parallel. */
	children: any[] | any;
}

class Sequence {
	/** The action definitions to run in sequence. */
	children: any[] | any;
}

class PhysicsWorld extends Node {
	/**
	 * Whether debug graphic should be displayed for the physics world.
	 */
	showDebug?: boolean;
}

class Body extends Node {
	/**
	 * An enumeration for the different moving types of bodies.
	 */
	type: dora.BodyMoveType;

	/**
	 * A constant linear acceleration applied to the body.
	 * Can be used for simulating gravity, wind, or other constant forces.
	 * @example
	 * bodyDef.linearAcceleration = Vec2(0, -9.8);
	 */
	linearAcceleration?: dora.Vec2.Type;

	/**
	 * Whether the body's rotation is fixed.
	 */
	fixedRotation?: boolean;

	/**
	 * Whether the body is a bullet. Set to true for extra bullet movement check.
	 */
	bullet?: boolean;

	/**
	 * The x-axis velocity of the body.
	 */
	velocityX?: number;

	/**
	 * The y-axis velocity of the body.
	 */
	velocityY?: number;

	/**
	 * The angular rate of the body.
	 */
	angularRate?: number;

	/**
	 * The collision group that the body belongs to.
	 */
	group?: number;

	/**
	 * The linear damping of the body.
	 */
	linearDamping?: number;

	/**
	 * The angular damping of the body.
	 */
	angularDamping?: number;

	/**
	 * The reference for an owner of the body.
	 */
	owner?: dora.Object.Type;

	/**
	 * Whether the body is currently receiving contact events or not.
	 */
	receivingContact?: boolean;

	/**
	 * Triggers when a Body object collides with a sensor object.
	 * Triggers after setting `body.receivingContact = true`.
	 * @param other The other Body object that the current Body is colliding with.
	 * @param sensorTag The tag of the sensor that triggered this collision.
	*/
	onBodyEnter?(this: void, other: dora.Body.Type, sensorTag: number): void;

	/**
	 * Triggers when a `Body` object is no longer colliding with a sensor object.
	 * Triggers after setting `body.receivingContact = true`.
	 * @param other The other `Body` object that the current `Body` is no longer colliding with.
	 * @param sensorTag The tag of the sensor that triggered this collision.
	*/
	onBodyLeave?(this: void, other: dora.Body.Type, sensorTag: number): void;

	/**
	 * Triggers when a `Body` object starts to collide with another object.
	 * Triggers after setting `body.receivingContact = true`.
	 * @param other The other `Body` object that the current `Body` is colliding with.
	 * @param point The point of collision in world coordinates.
	 * @param normal The normal vector of the contact surface in world coordinates.
	*/
	onContactStart?(this: void, other: dora.Body.Type, point: dora.Vec2.Type, normal: dora.Vec2.Type): void;

	/**
	 * Triggers when a `Body` object stops colliding with another object.
	 * Triggers after setting `body.receivingContact = true`.
	 * @param other The other `Body` object that the current `Body` is no longer colliding with.
	 * @param point The point of collision in world coordinates.
	 * @param normal The normal vector of the contact surface in world coordinates.
	*/
	onContactEnd?(this: void, other: dora.Body.Type, point: dora.Vec2.Type, normal: dora.Vec2.Type): void;
}

class RectangleShape {
	/** center The center point of the polygon. */
	center?: dora.Vec2.Type;
	/** The width of the polygon. */
	width: number;
	/** The height of the polygon. */
	height: number;
	/** The angle of the polygon (default is 0.0). */
	angle?: number;
	/** The density of the polygon (default is 0.0). */
	density?: number;
	/** The friction of the polygon (default is 0.4, should be 0 to 1.0). */
	friction?: number;
	/** The restitution of the polygon (default is 0.0, should be 0 to 1.0). */
	restitution?: number;
	/** An integer tag indicating it's a sensor area instead of actual body. */
	sensorTag?: number;
}

class PolygonShape {
	/** The vertices of the polygon. */
	verts: dora.Vec2.Type[];
	/** The density of the polygon (default is 0.0). */
	density?: number;
	/** The friction of the polygon (default is 0.4, should be 0 to 1.0). */
	friction?: number;
	/** The restitution of the polygon (default is 0.0, should be 0 to 1.0). */
	restitution?: number;
	/** An integer tag indicating it's a sensor area instead of actual body. */
	sensorTag?: number;
}

class MultiShape {
	/** A table containing the vertices of each convex shape that makes up the concave shape. */
	verts: dora.Vec2.Type[];
	/** The density of the concave shape (default is 0.0). */
	density?: number;
	/** The friction of the concave shape (default is 0.4, should be 0 to 1.0). */
	friction?: number;
	/** The restitution of the concave shape (default is 0.0, should be 0 to 1.0). */
	restitution?: number;
	/** An integer tag indicating it's a sensor area instead of actual body. */
	sensorTag?: number;
}

class DiskShape {
	/** The center point of the disk. */
	center?: dora.Vec2.Type;
	/** The radius of the disk. */
	radius: number;
	/** The density of the disk (default is 0.0). */
	density?: number;
	/** The friction of the disk (default is 0.4, should be 0 to 1.0). */
	friction?: number;
	/** The restitution of the disk (default is 0.0, should be 0 to 1.0) */
	restitution?: number;
	/** An integer tag indicating it's a sensor area instead of actual body. */
	sensorTag?: number;
}

class ChainShape {
	/** The vertices of the chain. */
	verts: dora.Vec2.Type[];
	/** The friction of the chain (default is 0.4). */
	friction?: number;
	/** The restitution of the chain (default is 0.0). */
	restitution?: number;
	/** An integer tag indicating it's a sensor area instead of actual body. */
	sensorTag?: number;
}

class DistanceJoint {
	ref?: Ref<dora.Joint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first physical body to be connected to the joint. */
	bodyA: Ref<dora.Body.Type>;
	/** The second physical body to be connected to the joint. */
	bodyB: Ref<dora.Body.Type>;
	/** The position of the joint on the first physical body (default value is Vec2.zero). */
	anchorA?: dora.Vec2.Type;
	/** The position of the joint on the second physical body (default value is Vec2.zero). */
	anchorB?: dora.Vec2.Type;
	/** The frequency of the joint in Hertz (default value is 0.0). */
	frequency?: number;
	/** The damping coefficient of the joint (default value is 0.0). */
	damping?: number;
}

class FrictionJoint {
	ref?: Ref<dora.Joint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first physical body to be connected to the joint. */
	bodyA: Ref<dora.Body.Type>;
	/** The second physical body to be connected to the joint. */
	bodyB: Ref<dora.Body.Type>;
	/** The position of the joint in the physical world. */
	worldPos: dora.Vec2.Type;
	/** The maximum force that can be applied to the joint. */
	maxForce: number;
	/** The maximum torque that can be applied to the joint. */
	maxTorque: number;
}

class GearJoint {
	ref?: Ref<dora.Joint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first joint to be connected to the gear joint. */
	jointA: Ref<dora.Joint.Type>;
	/** The second joint to be connected to the gear joint. */
	jointB: Ref<dora.Joint.Type>;
	/** The gear transmission ratio (default value is 1.0). */
	ratio?: number;
}

class SpringJoint {
	ref?: Ref<dora.Joint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first physical body connected to the joint. */
	bodyA: Ref<dora.Body.Type>;
	/** The second physical body connected to the joint. */
	bodyB: Ref<dora.Body.Type>;
	/** In the coordinate system of body A, the position of body B minus the position of body A. */
	linearOffset: dora.Vec2.Type;
	/** The angle of body B minus the angle of body A. */
	angularOffset: number;
	/** The maximum force the joint can apply. */
	maxForce: number;
	/** The maximum torque the joint can apply. */
	maxTorque: number;
	/** Optional correction factor, default is 1.0. */
	correctionFactor?: number;
}

class MoveJoint {
	ref?: Ref<dora.MoveJoint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The rigid body connected to the joint. */
	body: Ref<dora.Body.Type>;
	/** The target position to which the rigid body should be dragged. */
	targetPos: dora.Vec2.Type;
	/** The maximum force the joint can apply. */
	maxForce: number;
	/** Optional frequency ratio, default is 5.0. */
	frequency?: number;
	/** Optional damping ratio, default is 0.7. */
	damping?: number;
}

class PrismaticJoint {
	ref?: Ref<dora.MotorJoint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first rigid body connected to the joint. */
	bodyA: Ref<dora.Body.Type>;
	/** The second rigid body connected to the joint. */
	bodyB: Ref<dora.Body.Type>;
	/** The world coordinates of the joint. */
	worldPos: dora.Vec2.Type;
	/** The axial angle of the joint. */
	axisAngle: number;
	/** Optional lower translation limit, default is 0.0. */
	lowerTranslation?: number;
	/** Optional upper translation limit, default is 0.0. */
	upperTranslation?: number;
	/** Optional maximum motor force, default is 0.0. */
	maxMotorForce?: number;
	/** Optional motor speed, default is 0.0. */
	motorSpeed?: number;
}

class PulleyJoint {
	ref?: Ref<dora.Joint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first physical body to be connected. */
	bodyA: Ref<dora.Body.Type>;
	/** The second physical body to be connected. */
	bodyB: Ref<dora.Body.Type>;
	/** The position of the anchor point on the first body (default value is Vec2.zero). */
	anchorA?: dora.Vec2.Type;
	/** The position of the anchor point on the second body (default value is Vec2.zero). */
	anchorB?: dora.Vec2.Type;
	/** The position of the ground anchor on the first body in world coordinates. */
	groundAnchorA: dora.Vec2.Type;
	/** The position of the ground anchor on the second body in world coordinates. */
	groundAnchorB: dora.Vec2.Type;
	/** [Optional] The pulley ratio (default value is 1.0). */
	ratio?: number;
}

class RevoluteJoint {
	ref?: Ref<dora.MotorJoint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first physical body to be connected. */
	bodyA: Ref<dora.Body.Type>;
	/** The second physical body to be connected. */
	bodyB: Ref<dora.Body.Type>;
	/** The world coordinate position where the joint will be created. */
	worldPos: dora.Vec2.Type;
	/** [Optional] Lower angle limit (in radians) (default is 0.0). */
	lowerAngle?: number;
	/** [Optional] Upper angle limit (in radians) (default is 0.0). */
	upperAngle?: number;
	/** [Optional] The maximum torque the joint can exert to achieve the target speed (default is 0.0). */
	maxMotorTorque?: number;
	/** [Optional] The desired speed of the joint (default is 0.0). */
	motorSpeed?: number;
}

class RopeJoint {
	ref?: Ref<dora.Joint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first physical body to be connected. */
	bodyA: Ref<dora.Body.Type>;
	/** The second physical body to be connected. */
	bodyB: Ref<dora.Body.Type>;
	/** The position of the anchor point on the first body (default value is Vec2.zero). */
	anchorA?: dora.Vec2.Type;
	/** The position of the anchor point on the second body (default value is Vec2.zero). */
	anchorB?: dora.Vec2.Type;
	/** [Optional] The maximum distance between anchor points (default is 0.0). */
	maxLength?: number;
}

class WeldJoint {
	ref?: Ref<dora.Joint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first body to be connected. */
	bodyA: Ref<dora.Body.Type>;
	/** The second body to be connected. */
	bodyB: Ref<dora.Body.Type>;
	/** The world position where the bodies are connected. */
	worldPos: dora.Vec2.Type;
	/** [Optional] The stiffness frequency of the joint, default is 0.0. */
	frequency?: number;
	/** [Optional] The damping ratio of the joint, default is 0.0. */
	damping?: number;
}

class WheelJoint {
	ref?: Ref<dora.MotorJoint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first body to be connected. */
	bodyA: Ref<dora.Body.Type>;
	/** The second body to be connected. */
	bodyB: Ref<dora.Body.Type>;
	/** The world position where the bodies are connected. */
	worldPos: dora.Vec2.Type;
	/** The angle of the joint axis, in radians. */
	axisAngle: number;
	/** [Optional] The maximum torque the joint motor can apply, default is 0.0. */
	maxMotorTorque?: number;
	/** [Optional] The target speed of the joint motor, default is 0.0. */
	motorSpeed?: number;
	/** [Optional] The stiffness frequency of the joint, default is 2.0. */
	frequency?: number;
	/** [Optional] The damping ratio of the joint, default is 0.7. */
	damping?: number;
}

interface IntrinsicElements {
	/**
	 * Class used for building a hierarchical tree structure of game objects.
	 */
	node: Node;
	/**
	 * A Node that can clip its children based on the alpha values of its stencil.
	 */
	'clip-node': ClipNode;
	/**
	 * Class for animation model system.
	 */
	playable: Playable;
	/**
	 * An implementation of the 'Playable' class using the DragonBones animation system.
	 */
	'dragon-bone': DragonBone;
	/**
	 * An implementation of an animation system using the Spine engine.
	 */
	spine: Spine;
	/**
	 * Another implementation of the 'Playable' class.
	 */
	model: Model;
	/**
	 * A class for scene node that draws simple shapes such as dots, lines, and polygons.
	 */
	'draw-node': DrawNode;
	/**
	 * Draws a dot at a specified position with a specified radius and color.
	 * Can only be used as a child element of `<draw-node>`.
	 */
	dot: Dot;
	/**
	 * Draws a line segment between two points with a specified radius and color.
	 * Can only be used as a child element of `<draw-node>`.
	 */
	segment: Segment;
	/**
	 * Draws a polygon defined by a list of vertices with a specified fill color and border.
	 * Can only be used as a child element of `<draw-node>`.
	 */
	polygon: Polygon;
	/**
	 * Draws a set of vertices as triangles, each vertex with its own color.
	 * Can only be used as a child element of `<draw-node>`.
	 */
	verts: Verts;
	/**
	 * A class used to render a texture as a grid of sprites, where each sprite can be positioned,
	 * colored, and have its UV coordinates manipulated.
	 */
	grid: Grid;
	/**
	 * The Sprite class to render texture in game scene tree hierarchy.
	 */
	sprite: Sprite;
	/**
	 * A node for rendering text using a TrueType font.
	 */
	label: Label;
	/**
	 * A class provides functionality for drawing lines using vertices.
	 */
	line: Line;
	/**
	 * A particle system node that emits and animates particles.
	 */
	particle: Particle;
	/**
	 * This interface is used for managing touch events for children nodes in a given area.
	 * The menu will swallow touches that hit children nodes.
	 * Only one child node can receive the first touch event; multi-touches that come later for other children nodes will be ignored.
	 */
	menu: Menu;
	/**
	 * Represents an action that can be run on a node.
	 */
	action: Action;
	/**
	 * Creates a definition for an action that animates the x anchor point of a Node from one value to another.
	 */
	'anchor-x': AnchorX;
	/**
	 * Creates a definition for an action that animates the y anchor point of a Node from one value to another.
	 */
	'anchor-y': AnchorY;
	/**
	 * Creates a definition for an action that animates the angle of a Node from one value to another.
	 */
	angle: Angle;
	/**
	 * Creates a definition for an action that animates the x-axis rotation angle of a Node from one value to another.
	 */
	'angle-x': AngleX;
	/**
	 * Creates a definition for an action that animates the y-axis rotation angle of a Node from one value to another.
	 */
	'angle-y': AngleY;
	/**
	 * Creates a definition for an action that makes a delay in the animation timeline.
	 */
	delay: Delay;
	/**
	 * Creates a definition for an action that emits an event.
	 */
	event: Event;
	/**
	 * Creates a definition for an action that animates the width of a Node.
	 */
	width: Width;
	/**
	 * Creates a definition for an action that animates the height of a Node.
	 */
	height: Height;
	/**
	 * Creates a definition for an action that hides a Node.
	 */
	hide: Hide;
	/**
	 * Creates a definition for an action that shows a Node.
	 */
	show: Show;
	/**
	 * Creates a definition for an action that animates the position of a Node.
	 */
	move: Move;
	/**
	 * Creates a definition for an action that animates the opacity of a Node from one value to another.
	 */
	opacity: Opacity;
	/**
	 * Creates a definition for an action that animates the rotation of a Node from one value to another.
	 * The roll animation will make sure the node is rotated to the target angle by the minimum rotation angle.
	 */
	roll: Roll;
	/**
	 * Creates a definition for an action that animates the x-axis and y-axis scale of a Node from one value to another.
	 */
	scale: Scale;
	/**
	 * Creates a definition for an action that animates the x-axis scale of a Node from one value to another.
	 */
	'scale-x': ScaleX;
	/**
	 * Creates a definition for an action that animates the y-axis scale of a Node from one value to another.
	 */
	'scale-y': ScaleY;
	/**
	 * Creates a definition for an action that animates the skew of a Node along the x-axis.
	 */
	'skew-x': SkewX;
	/**
	 * Creates a definition for an action that animates the skew of a Node along the y-axis.
	 */
	'skew-y': SkewY;
	/**
	 * Creates a definition for an action that animates the x-position of a Node.
	 */
	'move-x': MoveX;
	/**
	 * Creates a definition for an action that animates the y-position of a Node.
	 */
	'move-y': MoveY;
	/**
	 * Creates a definition for an action that animates the z-position of a Node.
	 */
	'move-z': MoveZ;
	/**
	 * Creates a definition for an action that runs a group of actions in parallel.
	 */
	spawn: Spawn;
	/**
	 * Creates a definition for an action that runs a sequence of actions.
	 */
	sequence: Sequence;
	/**
	 * A class representing a physics world in the game.
	 */
	'physics-world': PhysicsWorld;
	/**
	 * A class represents a physics body in the world.
	 */
	body: Body;
	/**
	 * Attaches a rectangle fixture definition to the body.
	 */
	'rect-shape': RectangleShape;
	/**
	 * Attaches a polygon fixture definition to the body using vertices.
	 */
	'polygon-shape': PolygonShape;
	/**
	 * Attaches a concave shape definition made of multiple convex shapes to the body.
	 */
	'multi-shape': MultiShape;
	/**
	 * Attaches a disk fixture definition to the body.
	 */
	'disk-shape': DiskShape;
	/**
	 * Attaches a chain fixture definition to the body. The Chain fixture is a free form sequence of line segments that has two-sided collision.
	 */
	'chain-shape': ChainShape;
	/**
	 * Creates a distance joint between two bodies.
	 */
	'distance-joint': DistanceJoint;
	/**
	 * Creates a friction joint between two bodies.
	 */
	'friction-joint': FrictionJoint;
	/**
	 * Creates a gear joint between two other joints.
	 */
	'gear-joint': GearJoint;
	/**
	 * Creates a new spring joint between two specified bodies.
	 */
	'spring-joint': SpringJoint;
	/**
	 * Creates a new move joint for the specified rigid body.
	 */
	'move-joint': MoveJoint;
	/**
	 * Creates a new prismatic joint between two specified rigid bodies.
	 */
	'prismatic-joint': PrismaticJoint;
	/**
	 * Creates a pulley joint between two bodies.
	 */
	'pulley-joint': PulleyJoint;
	/**
	 * Creates a revolute joint between two bodies.
	 */
	'revolute-joint': RevoluteJoint;
	/**
	 * Creates a rope joint between two bodies.
	 */
	'rope-joint': RopeJoint;
	/**
	 * Creates a weld joint between two objects.
	 */
	'weld-joint': WeldJoint;
	/**
	 * Creates a wheel joint between two objects.
	 */
	'wheel-joint': WheelJoint;
}

interface ElementChildrenAttribute {
	children: {};
}

} // namespace JSX
} // global

export {};
