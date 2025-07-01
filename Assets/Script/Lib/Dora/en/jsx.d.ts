import type * as Dora from 'Dora';

declare global {
namespace JSX {
interface Ref<T> {
	readonly current: T | null;
}

class Node {
	ref?: Ref<Dora.Node.Type>;

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

	/** The Z-axis scale factor of the node. */
	scaleZ?: number;

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

	/** Whether debug graphic should be displayed for the node. */
	showDebug?: boolean;

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

	/** The target node acts as a parent node for transforming this node. */
	transformTarget?: Ref<Node>;

	/** The scheduler used for scheduling update and action callbacks. */
	scheduler?: Dora.Scheduler.Type;

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
	 * Schedules a function to run every frame, or schedules a coroutine to start running. Return true to stop the running function or using 'coroutine.yield(true)' to stop the coroutine.
	 */
	onUpdate?: ((this: void, deltaTime: number) => boolean) | Dora.Job;

	/**
	 * The ActionEnd slot is triggered when an action is finished.
	 * Triggers after `node.runAction()` and `node.perform()`.
	 * @param action The finished action.
	 * @param target The node that finished the action.
	 */
	onActionEnd?(this: void, action: Dora.Action.Type, target: Dora.Node.Type): void;

	/**
	 * The TapFilter slot is triggered before the TapBegan slot and can be used to filter out certain taps.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param touch The touch that triggered the tap.
	*/
	onTapFilter?(this: void, touch: Dora.Touch.Type): void;

	/**
	 * The TapBegan slot is triggered when a tap is detected.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param touch The touch that triggered the tap.
	*/
	onTapBegan?(this: void, touch: Dora.Touch.Type): void;

	/**
	 * The TapEnded slot is triggered when a tap ends.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param touch The touch that triggered the tap.
	*/
	onTapEnded?(this: void, touch: Dora.Touch.Type): void;

	/**
	 * The Tapped slot is triggered when a tap is detected and has ended.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param touch The touch that triggered the tap.
	*/
	onTapped?(this: void, touch: Dora.Touch.Type): void;

	/**
	 * The TapMoved slot is triggered when a tap moves.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param touch The touch that triggered the tap.
	*/
	onTapMoved?(this: void, touch: Dora.Touch.Type): void;

	/**
	 * The MouseWheel slot is triggered when the mouse wheel is scrolled.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param delta The amount of scrolling that occurred.
	*/
	onMouseWheel?(this: void, delta: Dora.Vec2.Type): void;

	/**
	 * The Gesture slot is triggered when a gesture is recognized.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param center The center of the gesture.
	 * @param numFingers The number of fingers involved in the gesture.
	 * @param deltaDist The distance the gesture has moved.
	 * @param deltaAngle The angle of the gesture.
	*/
	onGesture?(this: void, center: Dora.Vec2.Type, numFingers: number, deltaDist: number, deltaAngle: number): void;

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
	onKeyDown?(this: void, keyName: Dora.KeyName): void;

	/**
	 * The KeyUp slot is triggered when a key is released.
	 * Triggers after setting `node.keyboardEnabled = true`.
	 * @param keyName The name of the key that was released.
	*/
	onKeyUp?(this: void, keyName: Dora.KeyName): void;

	/**
	 * The KeyPressed slot is triggered when a key is pressed.
	 * Triggers after setting `node.keyboardEnabled = true`.
	 * @param keyName The name of the key that was pressed.
	*/
	onKeyPressed?(this: void, keyName: Dora.KeyName): void;

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
	onButtonDown?(this: void, controllerId: number, buttonName: Dora.ButtonName): void;

	/**
	 * The ButtonUp slot is triggered when a game controller button is released.
	 * Triggers after setting `node.controllerEnabled = true`.
	 * @param controllerId The controller id, incrementing from 0 when multiple controllers connected.
	 * @param buttonName The name of the button that was released.
	*/
	onButtonUp?(this: void, controllerId: number, buttonName: Dora.ButtonName): void;

	/**
	 * The Axis slot is triggered when a game controller axis changed.
	 * Triggers after setting `node.controllerEnabled = true`.
	 * @param controllerId The controller id, incrementing from 0 when multiple controllers connected.
	 * @param axisValue The controller axis value ranging from -1.0 to 1.0.
	*/
	onAxis?(this: void, controllerId: number, axisValue: number): void;

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.Node.Type): void;
}

class ClipNode extends Node {
	ref?: Ref<Dora.ClipNode.Type>;

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

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.ClipNode.Type): void;
}

class Playable extends Node {
	ref?: Ref<Dora.Playable.Type>;

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
	onAnimationEnd?(this: void, animationName: string, target: Dora.Playable.Type): void;

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.Playable.Type): void;
}

class DragonBone extends Playable {
	ref?: Ref<Dora.DragonBone.Type>;

	/**
	 * The DragonBone file string for the new instance.
	 * A DragonBone file string can be a file path with the target file extention like "DragonBone/item" or file paths with all the related files like "DragonBone/item_ske.json|DragonBone/item_tex.json".
	 * And the an armature name can be added following a seperator of ';'. like "DragonBone/item;mainArmature" or "DragonBone/item_ske.json|DragonBone/item_tex.json;mainArmature".
	 */
	file: string;

	/**
	 * Whether hit testing is enabled.
	 */
	hitTestEnabled?: boolean;

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.DragonBone.Type): void;
}

class Spine extends Playable {
	ref?: Ref<Dora.Spine.Type>;

	/**
	 * The Spine file string for the new instance.
	 * A Spine file string can be a file path with the target file extention like "Spine/item" or file paths with all the related files like "Spine/item.skel|Spine/item.atlas" or "Spine/item.json|Spine/item.atlas".
	 */
	file: string;

	/** Whether hit testing is enabled. */
	hitTestEnabled?: boolean;

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.Spine.Type): void;
}

class Model extends Playable {
	ref?: Ref<Dora.Model.Type>;

	/**
	 * The filename of the model file to load.
	 * Can be filename with or without extension like: "Model/item" or "Model/item.model".
	 */
	file: string;

	/**
	 * Whether the animation model will be played in reverse.
	 */
	reversed?: boolean;

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.Model.Type): void;
}

class Dot {
	/**
	 * The X position of the dot.
	 */
	x?: number;

	/**
	 * The Y position of the dot.
	 */
	y?: number;

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
	/**
	 * The vertices of the polygon.
	 */
	verts: Dora.Vec2.Type[];

	/**
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

class Rectangle {
	/**
	 * The width of the rectangle.
	 */
	width: number;

	/**
	 * The height of the rectangle.
	 */
	height: number;

	/**
	 * The center X position of the rectangle.
	 */
	centerX?: number;

	/**
	 * The center Y position of the rectangle.
	 */
	centerY?: number;

	/**
	 * The fill color of the rectangle in format 0xffffffff (ARGB, default is white).
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
	/**
	 * The list of vertices and their colors in format 0xffffffff (ARGB).
	 */
	verts: [vert: Dora.Vec2.Type, color: number][];
}

class DrawNode extends Node {
	ref?: Ref<Dora.DrawNode.Type>;

	/**
	 * Whether to write to the depth buffer when drawing (default is false).
	 */
	depthWrite?: boolean;

	/**
	 * The blend function used to draw the shape.
	 */
	blendFunc?: Dora.BlendFunc.Type;

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.DrawNode.Type): void;
}

class Grid extends Node {
	ref?: Ref<Dora.Grid.Type>;

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
	textureRect?: Dora.Rect.Type;

	/** The blending function used for the grid. */
	blendFunc?: Dora.BlendFunc.Type;

	/** The sprite effect applied to the grid. Default is `SpriteEffect("builtin:vs_sprite", "builtin:fs_sprite")`. */
	effect?: Dora.SpriteEffect.Type;

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.Grid.Type): void;
}

class Sprite extends Node {
	ref?: Ref<Dora.Sprite.Type>;

	/**
	 * The string containing format for loading a texture file.
	 * Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.
	 */
	file?: string;

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
	textureRect?: Dora.Rect.Type;

	/**
	 * The blend function for the sprite.
	 */
	blendFunc?: Dora.BlendFunc.Type;

	/**
	 * The sprite shader effect.
	 */
	effect?: Dora.SpriteEffect.Type;

	/**
	 * The texture wrapping mode for the U (horizontal) axis.
	 */
	uwrap?: Dora.TextureWrap;

	/**
	 * The texture wrapping mode for the V (vertical) axis.
	 */
	vwrap?: Dora.TextureWrap;

	/**
	 * The texture filtering mode for the sprite.
	 */
	filter?: Dora.TextureFilter;

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.Sprite.Type): void;
}

class Label extends Node {
	ref?: Ref<Dora.Label.Type>;

	/**
	 * The name of the font to use for the label. Can be a font file path with or without a file extension.
	 */
	fontName: string;

	/**
	 * The size of the font to use for the label.
	 */
	fontSize: number;

	/**
	 * Whether to use SDF rendering or not. With SDF rendering, the outline feature will be enabled.
	 */
	sdf?: boolean;

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
	 * The gap in pixels between characters.
	 */
	spacing?: number;

	/**
	 * The color of the outline, only works with SDF label.
	 */
	outlineColor?: number;

	/**
	 * The width of the outline, only works with SDF label.
	 */
	outlineWidth?: number;

	/**
	 * The smooth lower value of the text, only works with SDF label, default is 0.7.
	 */
	smoothLower?: number;

	/**
	 * The smooth upper value of the text, only works with SDF label, default is 0.7.
	 */
	smoothUpper?: number;

	/**
	 * The text to be rendered.
	 */
	text?: string;

	/**
	 * The blend function used to render the text.
	 */
	blendFunc?: Dora.BlendFunc.Type;

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
	effect?: Dora.SpriteEffect.Type;

	/**
	 * The text alignment setting. (Default is `TextAlign.Center`)
	 */
	alignment?: Dora.TextAlign;

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.Label.Type): void;
}

class Line extends Node {
	ref?: Ref<Dora.Line.Type>;

	/**
	 * Whether the depth should be written. (Default is false)
	 */
	depthWrite?: boolean;

	/**
	 * Blend function used for rendering the line.
	 */
	blendFunc?: Dora.BlendFunc.Type;

	/**
	 * List of vertices to set to the line.
	 */
	verts: Dora.Vec2.Type[];

	/**
	 * Color of the line in format 0xffffffff (ARGB, default is opaque white).
	 */
	lineColor?: number;

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.Line.Type): void;
}

class Particle extends Node {
	ref?: Ref<Dora.Particle.Type>;

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

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.Particle.Type): void;
}

class Menu extends Node {
	ref?: Ref<Dora.Menu.Type>;

	/**
	 * Whether the menu is currently enabled or disabled.
	 */
	enabled?: boolean;

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.Menu.Type): void;
}

type StyleDirection = 'ltr' | 'rtl' | 'inherit';
type StyleAlign = 'flex-start' | 'center' | 'flex-end' | 'stretch' | 'auto';
type StyleFlexDirection = 'row' | 'column' | 'row-reverse' | 'column-reverse';
type StyleJustifyContent = 'flex-start' | 'center' | 'flex-end' | 'space-between' | 'space-around' | 'space-evenly';
type StylePositionType = 'relative' | 'absolute' | 'static';
type StyleWrap = 'nowrap' | 'wrap' | 'wrap-reverse';
type StyleOverflow = 'visible' | 'hidden' | 'scroll';
type StyleDisplay = 'flex' | 'none';
type StylePercentage = `${number}%`;
type StyleValuePercent = number | StylePercentage;
type StyleValuePercentAuto = number | StylePercentage | "auto";

interface AlignStyle {
	direction?: StyleDirection;
	alignContent?: StyleAlign;
	alignItems?: StyleAlign;
	alignSelf?: StyleAlign;
	flexDirection?: StyleFlexDirection;
	justifyContent?: StyleJustifyContent;
	flexWrap?: StyleWrap;
	flex?: number;
	flexBasis?: StyleValuePercentAuto;
	flexGrow?: number;
	flexShrink?: number;
	left?: StyleValuePercent;
	right?: StyleValuePercent;
	top?: StyleValuePercent;
	bottom?: StyleValuePercent;
	start?: StyleValuePercent;
	end?: StyleValuePercent;
	horizontal?: StyleValuePercent;
	vetical?: StyleValuePercent;
	position?: StylePositionType;
	overflow?: StyleOverflow;
	display?: StyleDisplay;
	width?: StyleValuePercentAuto;
	height?: StyleValuePercentAuto;
	minWidth?: StyleValuePercent;
	minHeight?: StyleValuePercent;
	maxWidth?: StyleValuePercent;
	maxHeight?: StyleValuePercent;
	marginTop?: StyleValuePercentAuto;
	marginRight?: StyleValuePercentAuto;
	marginBottom?: StyleValuePercentAuto;
	marginLeft?: StyleValuePercentAuto;
	marginInlineStart?: StyleValuePercentAuto;
	marginInlineEnd?: StyleValuePercentAuto;
	marginInline?: StyleValuePercentAuto;
	margin?: [StyleValuePercentAuto, StyleValuePercentAuto?, StyleValuePercentAuto?, StyleValuePercentAuto?] | StyleValuePercentAuto;
	paddingTop?: StyleValuePercent;
	paddingRight?: StyleValuePercent;
	paddingBottom?: StyleValuePercent;
	paddingLeft?: StyleValuePercent;
	padding?: [StyleValuePercent, StyleValuePercent?, StyleValuePercent?, StyleValuePercent?] | StyleValuePercent;
	border?: [number, number?, number?, number?] | number;
	gap?: [StyleValuePercent, StyleValuePercent?] | StyleValuePercent;
	aspectRatio?: number;
}

class AlignNode extends Node {
	ref?: Ref<Dora.AlignNode.Type>;

	/**
	 * Whether the node is a window root node.
	 * A window root node will automatically listen for window size change events and update the layout accordingly.
	 */
	windowRoot?: boolean;

	/** The layout style of the node */
	style?: AlignStyle;

	/**
	 * Triggers when the layout of the node is updated.
	 * @param width The width of the node.
	 * @param height The height of the node.
	 */
	onLayout?(this: void, width: number, height: number): void;

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.AlignNode.Type): void;
}

class EffekNode extends Node {
	ref?: Ref<Dora.EffekNode.Type>;

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.EffekNode.Type): void;
}

class Effek {
	ref?: Ref<number>;

	/**
	 * The filename of the Effekseer effect file to load.
	 */
	file: string;

	/**
	 * The x position of the effect.
	 */
	x?: number;

	/**
	 * The y position of the effect.
	 */
	y?: number;

	/**
	 * The z position of the effect.
	 */
	z?: number;

	/**
	 * Triggers when the effect is finished playing.
	 */
	onEnd?(): void;
}

class TileNode extends Node {
	ref?: Ref<Dora.TileNode.Type>;

	/**
	 * The TMX file for the tilemap.
	 * Can be files created with Tiled Map Editor (http://www.mapeditor.org).
	 * And the TMX file should be in the format of XML.
	 */
	file: string;

	/**
	 * The names of the layers to load from the tilemap file.
	 * Will load all the tile layers when the layer names are not offered.
	 */
	layers?: string[];

	/**
	 * Whether the depth buffer should be written to when rendering the tilemap (default is false).
	 */
	depthWrite?: boolean;

	/**
	 * The blend function for the tilemap.
	 */
	blendFunc?: Dora.BlendFunc.Type;

	/**
	 * The sprite shader effect.
	 */
	effect?: Dora.SpriteEffect.Type;

	/**
	 * The texture filtering mode for the tilemap.
	 */
	filter?: Dora.TextureFilter;

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.TileNode.Type): void;
}

class Action {
	ref?: Ref<Dora.ActionDef.Type>;
	children: any[] | any;
}

class AnchorX {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the anchor point. */
	start: number;
	/** The ending value of the anchor point. */
	stop: number;
	easing?: Dora.EaseFunc;
}

class AnchorY {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the anchor point. */
	start: number;
	/** The ending value of the anchor point. */
	stop: number;
	easing?: Dora.EaseFunc;
}

class Angle {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the angle in degrees. */
	start: number;
	/** The ending value of the angle in degrees. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Linear if not specified. */
	easing?: Dora.EaseFunc;
}

class AngleX {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the x-axis rotation angle in degrees. */
	start: number;
	/** The ending value of the x-axis rotation angle in degrees. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: Dora.EaseFunc;
}

class AngleY {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the y-axis rotation angle in degrees. */
	start: number;
	/** The ending value of the y-axis rotation angle in degrees. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: Dora.EaseFunc;
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
	easing?: Dora.EaseFunc;
}

class Height {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting height value of the Node. */
	start: number;
	/** The ending height value of the Node. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: Dora.EaseFunc;
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
	easing?: Dora.EaseFunc;
}

class Opacity {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting opacity value of the Node (0 - 1.0). */
	start: number;
	/** The ending opacity value of the Node (0 - 1.0). */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: Dora.EaseFunc;
}

class Roll {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting roll value of the Node (in degrees). */
	start: number;
	/** The ending roll value of the Node (in degrees). */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: Dora.EaseFunc;
}

class Scale {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the x-axis and y-axis scale. */
	start: number;
	/** The ending value of the x-axis and y-axis scale. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: Dora.EaseFunc;
}

class ScaleX {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the x-axis scale. */
	start: number;
	/** The ending value of the x-axis scale. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: Dora.EaseFunc;
}

class ScaleY {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting value of the y-axis scale. */
	start: number;
	/** The ending value of the y-axis scale. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: Dora.EaseFunc;
}

class SkewX {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting skew value of the Node on the x-axis (in degrees). */
	start: number;
	/** The ending skew value of the Node on the x-axis (in degrees). */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: Dora.EaseFunc;
}

class SkewY {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting skew value of the Node on the y-axis (in degrees). */
	start: number;
	/** The ending skew value of the Node on the y-axis (in degrees). */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: Dora.EaseFunc;
}

class MoveX {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting x-position of the Node. */
	start: number;
	/** The ending x-position of the Node. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: Dora.EaseFunc;
}

class MoveY {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting y-position of the Node. */
	start: number;
	/** The ending y-position of the Node. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: Dora.EaseFunc;
}

class MoveZ {
	/** The duration of the animation in seconds. */
	time: number;
	/** The starting z-position of the Node. */
	start: number;
	/** The ending z-position of the Node. */
	stop: number;
	/** [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. */
	easing?: Dora.EaseFunc;
}

class Frame {
	/** The duration of the animation in seconds. */
	time: number;
	/** The number of frames for each frame. The number of frames should match the number of frames in the clip. */
	file: string;
	/** The number of frames for each frame. The number of frames should match the number of frames in the clip. */
	frames?: number[];
}

class Loop {
	/** Whether the action definitions should run in parallel. */
	spawn?: boolean;

	/** The action definitions to run. Default to run in sequence. */
	children: any[] | any;
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
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.PhysicsWorld.Type): void;
}

class Contact {
	/**
	 * The first body group.
	 */
	groupA: number;

	/**
	 * The second body group.
	 */
	groupB: number;

	/**
	 * Whether the two groups should collide.
	 */
	enabled: boolean;
}

class Body extends Node {
	/**
	 * An enumeration for the different moving types of bodies.
	 */
	type: Dora.BodyMoveType;

	/**
	 * The `PhysicsWorld` instance for creating body node.
	 */
	world?: Dora.PhysicsWorldType;

	/**
	 * A constant linear acceleration applied to the body.
	 * Can be used for simulating gravity, wind, or other constant forces.
	 * @example
	 * bodyDef.linearAcceleration = Vec2(0, -9.8);
	 */
	linearAcceleration?: Dora.Vec2.Type;

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
	owner?: Dora.Object.Type;

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
	onBodyEnter?(this: void, other: Dora.Body.Type, sensorTag: number): void;

	/**
	 * Triggers when a `Body` object is no longer colliding with a sensor object.
	 * Triggers after setting `body.receivingContact = true`.
	 * @param other The other `Body` object that the current `Body` is no longer colliding with.
	 * @param sensorTag The tag of the sensor that triggered this collision.
	*/
	onBodyLeave?(this: void, other: Dora.Body.Type, sensorTag: number): void;

	/**
	 * Triggers when a `Body` object starts to collide with another object.
	 * Triggers after setting `body.receivingContact = true`.
	 * @param other The other `Body` object that the current `Body` is colliding with.
	 * @param point The point of collision in world coordinates.
	 * @param normal The normal vector of the contact surface in world coordinates.
	 * @param enabled Whether the contact is enabled or not. Collisions that are filtered out will still trigger this event, but the enabled state will be false.
	*/
	onContactStart?(this: void, other: Dora.Body.Type, point: Dora.Vec2.Type, normal: Dora.Vec2.Type, enabled: boolean): void;

	/**
	 * Triggers when a `Body` object stops colliding with another object.
	 * Triggers after setting `body.receivingContact = true`.
	 * @param other The other `Body` object that the current `Body` is no longer colliding with.
	 * @param point The point of collision in world coordinates.
	 * @param normal The normal vector of the contact surface in world coordinates.
	*/
	onContactEnd?(this: void, other: Dora.Body.Type, point: Dora.Vec2.Type, normal: Dora.Vec2.Type): void;

	/**
	 * Register a function to be called when the body begins to receive contact events. Return false from this function to prevent colliding.
	 * @param other The other `Body` object that the current `Body` is colliding with.
	 * @returns Whether to allow the collision to happen.
	 */
	onContactFilter?(this: void, other: Dora.Body.Type): boolean;

	/**
	 * Triggers when this node element is instantialized.
	 * @param self The node element that was instantialized.
	 */
	onMount?(this: void, self: Dora.Body.Type): void;
}

class RectangleShape {
	/** The center X position of the polygon. */
	centerX?: number;
	/** The center Y position of the polygon. */
	centerY?: number;
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
	verts: Dora.Vec2.Type[];
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
	verts: Dora.Vec2.Type[];
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
	/** The center X position of the disk. */
	centerX?: number;
	/** The center Y position of the disk. */
	centerY?: number;
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
	verts: Dora.Vec2.Type[];
	/** The friction of the chain (default is 0.4). */
	friction?: number;
	/** The restitution of the chain (default is 0.0). */
	restitution?: number;
	/** An integer tag indicating it's a sensor area instead of actual body. */
	sensorTag?: number;
}

class DistanceJoint {
	ref?: Ref<Dora.Joint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first physical body to be connected to the joint. */
	bodyA: Ref<Dora.Body.Type>;
	/** The second physical body to be connected to the joint. */
	bodyB: Ref<Dora.Body.Type>;
	/** The position of the joint on the first physical body (default value is Vec2.zero). */
	anchorA?: Dora.Vec2.Type;
	/** The position of the joint on the second physical body (default value is Vec2.zero). */
	anchorB?: Dora.Vec2.Type;
	/** The frequency of the joint in Hertz (default value is 0.0). */
	frequency?: number;
	/** The damping coefficient of the joint (default value is 0.0). */
	damping?: number;
}

class FrictionJoint {
	ref?: Ref<Dora.Joint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first physical body to be connected to the joint. */
	bodyA: Ref<Dora.Body.Type>;
	/** The second physical body to be connected to the joint. */
	bodyB: Ref<Dora.Body.Type>;
	/** The position of the joint in the physical world. */
	worldPos: Dora.Vec2.Type;
	/** The maximum force that can be applied to the joint. */
	maxForce: number;
	/** The maximum torque that can be applied to the joint. */
	maxTorque: number;
}

class GearJoint {
	ref?: Ref<Dora.Joint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first joint to be connected to the gear joint. */
	jointA: Ref<Dora.Joint.Type>;
	/** The second joint to be connected to the gear joint. */
	jointB: Ref<Dora.Joint.Type>;
	/** The gear transmission ratio (default value is 1.0). */
	ratio?: number;
}

class SpringJoint {
	ref?: Ref<Dora.Joint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first physical body connected to the joint. */
	bodyA: Ref<Dora.Body.Type>;
	/** The second physical body connected to the joint. */
	bodyB: Ref<Dora.Body.Type>;
	/** In the coordinate system of body A, the position of body B minus the position of body A. */
	linearOffset: Dora.Vec2.Type;
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
	ref?: Ref<Dora.MoveJoint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The rigid body connected to the joint. */
	body: Ref<Dora.Body.Type>;
	/** The target position to which the rigid body should be dragged. */
	targetPos: Dora.Vec2.Type;
	/** The maximum force the joint can apply. */
	maxForce: number;
	/** Optional frequency ratio, default is 5.0. */
	frequency?: number;
	/** Optional damping ratio, default is 0.7. */
	damping?: number;
}

class PrismaticJoint {
	ref?: Ref<Dora.MotorJoint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first rigid body connected to the joint. */
	bodyA: Ref<Dora.Body.Type>;
	/** The second rigid body connected to the joint. */
	bodyB: Ref<Dora.Body.Type>;
	/** The world coordinates of the joint. */
	worldPos: Dora.Vec2.Type;
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
	ref?: Ref<Dora.Joint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first physical body to be connected. */
	bodyA: Ref<Dora.Body.Type>;
	/** The second physical body to be connected. */
	bodyB: Ref<Dora.Body.Type>;
	/** The position of the anchor point on the first body (default value is Vec2.zero). */
	anchorA?: Dora.Vec2.Type;
	/** The position of the anchor point on the second body (default value is Vec2.zero). */
	anchorB?: Dora.Vec2.Type;
	/** The position of the ground anchor on the first body in world coordinates. */
	groundAnchorA: Dora.Vec2.Type;
	/** The position of the ground anchor on the second body in world coordinates. */
	groundAnchorB: Dora.Vec2.Type;
	/** [Optional] The pulley ratio (default value is 1.0). */
	ratio?: number;
}

class RevoluteJoint {
	ref?: Ref<Dora.MotorJoint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first physical body to be connected. */
	bodyA: Ref<Dora.Body.Type>;
	/** The second physical body to be connected. */
	bodyB: Ref<Dora.Body.Type>;
	/** The world coordinate position where the joint will be created. */
	worldPos: Dora.Vec2.Type;
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
	ref?: Ref<Dora.Joint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first physical body to be connected. */
	bodyA: Ref<Dora.Body.Type>;
	/** The second physical body to be connected. */
	bodyB: Ref<Dora.Body.Type>;
	/** The position of the anchor point on the first body (default value is Vec2.zero). */
	anchorA?: Dora.Vec2.Type;
	/** The position of the anchor point on the second body (default value is Vec2.zero). */
	anchorB?: Dora.Vec2.Type;
	/** [Optional] The maximum distance between anchor points (default is 0.0). */
	maxLength?: number;
}

class WeldJoint {
	ref?: Ref<Dora.Joint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first body to be connected. */
	bodyA: Ref<Dora.Body.Type>;
	/** The second body to be connected. */
	bodyB: Ref<Dora.Body.Type>;
	/** The world position where the bodies are connected. */
	worldPos: Dora.Vec2.Type;
	/** [Optional] The stiffness frequency of the joint, default is 0.0. */
	frequency?: number;
	/** [Optional] The damping ratio of the joint, default is 0.0. */
	damping?: number;
}

class WheelJoint {
	ref?: Ref<Dora.MotorJoint.Type>;
	/** Whether the physical bodies connected to the joint can collide with each other. Default is false. */
	canCollide?: boolean;
	/** The first body to be connected. */
	bodyA: Ref<Dora.Body.Type>;
	/** The second body to be connected. */
	bodyB: Ref<Dora.Body.Type>;
	/** The world position where the bodies are connected. */
	worldPos: Dora.Vec2.Type;
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

class CustomNode extends Node {
	/**
	 * Function to create a custom node.
	 * @returns The custom node element.
	 */
	onCreate(this: void): Dora.Node.Type | null;
}

class CustomElement {
	name: string;
	data: any;
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
	'dot-shape': Dot;
	/**
	 * Draws a line segment between two points with a specified radius and color.
	 * Can only be used as a child element of `<draw-node>`.
	 */
	'segment-shape': Segment;
	/**
	 * Draws a rectangle defined by width and height with a specified fill color and border.
	 * Can only be used as a child element of `<draw-node>`.
	 */
	'rect-shape': Rectangle;
	/**
	 * Draws a polygon defined by a list of vertices with a specified fill color and border.
	 * Can only be used as a child element of `<draw-node>`.
	 */
	'polygon-shape': Polygon;
	/**
	 * Draws a set of vertices as triangles, each vertex with its own color.
	 * Can only be used as a child element of `<draw-node>`.
	 */
	'verts-shape': Verts;
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
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	'anchor-x': AnchorX;
	/**
	 * Creates a definition for an action that animates the y anchor point of a Node from one value to another.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	'anchor-y': AnchorY;
	/**
	 * Creates a definition for an action that animates the angle of a Node from one value to another.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	angle: Angle;
	/**
	 * Creates a definition for an action that animates the x-axis rotation angle of a Node from one value to another.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	'angle-x': AngleX;
	/**
	 * Creates a definition for an action that animates the y-axis rotation angle of a Node from one value to another.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	'angle-y': AngleY;
	/**
	 * Creates a definition for an action that makes a delay in the animation timeline.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	delay: Delay;
	/**
	 * Creates a definition for an action that emits an event.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	event: Event;
	/**
	 * Creates a definition for an action that animates the width of a Node.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	width: Width;
	/**
	 * Creates a definition for an action that animates the height of a Node.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	height: Height;
	/**
	 * Creates a definition for an action that hides a Node.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	hide: Hide;
	/**
	 * Creates a definition for an action that shows a Node.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	show: Show;
	/**
	 * Creates a definition for an action that animates the position of a Node.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	move: Move;
	/**
	 * Creates a definition for an action that animates the opacity of a Node from one value to another.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	opacity: Opacity;
	/**
	 * Creates a definition for an action that animates the rotation of a Node from one value to another.
	 * The roll animation will make sure the node is rotated to the target angle by the minimum rotation angle.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	roll: Roll;
	/**
	 * Creates a definition for an action that animates the x-axis and y-axis scale of a Node from one value to another.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	scale: Scale;
	/**
	 * Creates a definition for an action that animates the x-axis scale of a Node from one value to another.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	'scale-x': ScaleX;
	/**
	 * Creates a definition for an action that animates the y-axis scale of a Node from one value to another.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	'scale-y': ScaleY;
	/**
	 * Creates a definition for an action that animates the skew of a Node along the x-axis.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	'skew-x': SkewX;
	/**
	 * Creates a definition for an action that animates the skew of a Node along the y-axis.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	'skew-y': SkewY;
	/**
	 * Creates a definition for an action that animates the x-position of a Node.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	'move-x': MoveX;
	/**
	 * Creates a definition for an action that animates the y-position of a Node.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	'move-y': MoveY;
	/**
	 * Creates a definition for an action that animates the z-position of a Node.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	'move-z': MoveZ;
	/**
	 * Creates a definition for a frame animation with frames count for each frame. Can only be applied to <sprite> element.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	frame: Frame;
	/**
	 * Creates a definition for an action that runs repeatedly.
	 * Must be placed under scene node to take effect.
	 */
	loop: Loop;
	/**
	 * Creates a definition for an action that runs a group of actions in parallel.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	spawn: Spawn;
	/**
	 * Creates a definition for an action that runs a sequence of actions.
	 * Must be placed under <action>, <spawn>, <sequence>, <loop> or scene node to take effect.
	 */
	sequence: Sequence;
	/**
	 * A class representing a physics world in the game.
	 */
	'physics-world': PhysicsWorld;
	/**
	 * The setting for whether two groups of bodies should collide.
	 * Must be placed under <physics-world> or its derivatives to take effect.
	 */
	contact: Contact;
	/**
	 * A class represents a physics body in the world.
	 * Must be placed under <physics-world> or its derivatives to take effect.
	 * Or providing a `world` attribute for creating physics body instance.
	 */
	body: Body;
	/**
	 * Attaches a rectangle fixture definition to the body.
	 * Must be placed under <body> or its derivatives to take effect.
	 */
	'rect-fixture': RectangleShape;
	/**
	 * Attaches a polygon fixture definition to the body using vertices.
	 * Must be placed under <body> or its derivatives to take effect.
	 */
	'polygon-fixture': PolygonShape;
	/**
	 * Attaches a concave fixture definition made of multiple convex fixtures to the body.
	 * Must be placed under <body> or its derivatives to take effect.
	 */
	'multi-fixture': MultiShape;
	/**
	 * Attaches a disk fixture definition to the body.
	 * Must be placed under <body> or its derivatives to take effect.
	 */
	'disk-fixture': DiskShape;
	/**
	 * Attaches a chain fixture definition to the body. The Chain fixture is a free form sequence of line segments that has two-sided collision.
	 * Must be placed under <body> or its derivatives to take effect.
	 */
	'chain-fixture': ChainShape;
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
	/**
	 * A class for creating a custom node element.
	 */
	'custom-node': CustomNode;
	/**
	 * A class for creating a custom element.
	 */
	'custom-element': CustomElement;
	/**
	 * A class for aligning child nodes within a parent node.
	 */
	'align-node': AlignNode;
	/**
	 * A class for creating a Effekseer node.
	 */
	'effek-node': EffekNode;
	/**
	 * A class for creating a tilemap node.
	 */
	'tile-node': TileNode;
	/**
	 * A class for playing a Effekseer effect. Must be placed under <effek-node> to take effect.
	 */
	'effek': Effek;
}

interface ElementChildrenAttribute {
	children: {};
}

interface ElementAttributesProperty {
	props: any;
}

} // namespace JSX
} // global

export {};
