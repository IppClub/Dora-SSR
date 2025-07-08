/// <reference path="es6-subset.d.ts" />
/// <reference path="lua.d.ts" />

declare module "Dora" {

interface BasicTyping<TypeName> {
	__basic__: TypeName;
}

type BasicType<TypeName, T = {}> = T & BasicTyping<TypeName>;

/** A base class for items that can be stored in Array and Dictionary. */
class ContainerItem {
	protected constructor();
}

/**
 * A size object with a given width and height.
 */
class Size extends ContainerItem {
	private constructor();

	/**
	 * The width of the size.
	 */
	width: number;

	/**
	 * The height of the size.
	 */
	height: number;

	/**
	 * Set the width and height of the size.
	 * @param width The new width of the size.
	 * @param height The new height of the size.
	 */
	set(width: number, height: number): void;

	/**
	 * Check if two sizes are equal.
	 * @param other The other size to compare to.
	 * @returns Whether or not the two sizes are equal.
	 */
	equals(other: Size): boolean;

	/**
	 * Multiply the size by a vector.
	 * @param vec The vector to multiply by.
	 * @returns The result of multiplying the size by the vector.
	 * @example
	 * ```
	 * const halfSize = size.mul(Vec2(0.5, 0.5));
	 * ```
	 */
	mul(vec: Vec2): Size;
}

export namespace Size {
	export type Type = Size;
}

/**
 * A class for creating Size objects.
 */
interface SizeClass {
	/**
	 * Create a new Size object with the given width and height.
	 *
	 * @param width The width of the new size (default 0).
	 * @param height The height of the new size (default 0).
	 * @returns The new Size object.
	 * @example
	 * ```
	 * let size = Size(10, 20);
	 * ```
	 */
	(this: void, width?: number, height?: number): Size;

	/**
	 * Create a new Size object from an existing Size object.
	 *
	 * @param other The existing Size object to create the new object from.
	 * @returns The new Size object.
	 * @example
	 * ```
	 * let newSize = Size(existingSize);
	 * ```
	 */
	(this: void, other: Size): Size;

	/**
	 * Create a new Size object from a Vec2 object.
	 *
	 * @param vec The vector to create the new size from, represented by a Vec2 object.
	 * @returns The new Size object.
	 * @example
	 * ```
	 * let size = Size(Vec2(10, 20));
	 * ```
	 */
	(this: void, vec: Vec2): Size;

	/**
	 * Gets zero-size object.
	 */
	readonly zero: Size;
}

const sizeClass: SizeClass;
export {sizeClass as Size};

/**
 * A class representing a 2D vector with an x and y component.
 */
class Vec2 extends ContainerItem {
	private constructor();

	/** The x-component of the vector. */
	readonly x: number;

	/** The y-component of the vector. */
	readonly y: number;

	/** The length of the vector. */
	readonly length: number;

	/** The squared length of the vector. */
	readonly lengthSquared: number;

	/** The angle between the vector and the x-axis. */
	readonly angle: number;

	/**
	 * Calculates the distance between two vectors.
	 * @param vec The other vector to calculate the distance to.
	 * @returns The distance between the two vectors.
	 */
	distance(vec: Vec2): number;

	/**
	 * Calculates the squared distance between two vectors.
	 * @param vec The other vector to calculate the squared distance to.
	 * @returns The squared distance between the two vectors.
	 */
	distanceSquared(vec: Vec2): number;

	/**
	 * Normalizes the vector to have a length of 1.
	 * @returns The normalized vector.
	 */
	normalize(): Vec2;

	/**
	 * Gets the perpendicular vector of this vector.
	 * @returns The perpendicular vector.
	 */
	perp(): Vec2;

	/**
	 * Clamps the vector to a range between two other vectors.
	 * @param from The lower bound of the range.
	 * @param to The upper bound of the range.
	 * @returns The clamped vector.
	 */
	clamp(from: Vec2, to: Vec2): Vec2;

	/**
	 * Calculates the dot product of two vectors.
	 * @param other The other vector to calculate the dot product with.
	 * @returns The dot product of the two vectors.
	 */
	dot(other: Vec2): number;

	/**
	 * Adds two vectors together.
	 * @param other The other vector to add.
	 * @returns The sum of the two vectors.
	 */
	add(other: Vec2): Vec2;

	/**
	 * Subtracts one vector from another.
	 * @param other The vector to subtract.
	 * @returns The difference between the two vectors.
	 */
	sub(other: Vec2): Vec2;

	/**
	 * Multiplies two vectors component-wise.
	 * @param other The other vector to multiply by.
	 * @returns The result of multiplying the two vectors component-wise.
	 */
	mul(other: Vec2): Vec2;

	/**
	 * Multiplies a vector by a scalar.
	 * @param other The scalar to multiply by.
	 * @returns The result of multiplying the vector by the scalar.
	 */
	mul(other: number): Vec2;

	/**
	 * Multiplies a vector by a Size object.
	 * @param other The Size object to multiply by.
	 * @returns The result of multiplying the vector by the Size object.
	 */
	mul(other: Size): Vec2;

	/**
	 * Divide a vector by a scalar.
	 * @param other The scalar to divide by.
	 * @returns The result of dividing the vector by the scalar.
	 */
	div(other: number): Vec2;

	/**
	 * Compare two vectors for equality.
	 * @param other The other vector to compare to.
	 * @returns Whether or not the two vectors are equal.
	 */
	equals(other: Vec2): boolean;
}

export namespace Vec2 {
	export type Type = Vec2;
}

/**
 * A class for creating Vec2 objects.
 */
interface Vec2Class {
	/**
	 * Creates a new Vec2 object from an existing Vec2 object.
	 *
	 * @param other The existing Vec2 object to create the new object from.
	 * @returns The new Vec2 object.
	 * @example
	 * ```
	 * const newVec = Vec2(existingVec);
	 * ```
	 */
	(this: void, other: Vec2): Vec2;

	/**
	 * Creates a new Vec2 object with the given x and y components.
	 *
	 * @param x The x-component of the new vector.
	 * @param y The y-component of the new vector.
	 * @returns The new Vec2 object.
	 * @example
	 * ```
	 * const newVec = Vec2(10, 20);
	 * ```
	 */
	(this: void, x: number, y: number): Vec2;

	/**
	 * Creates a new Vec2 object from a Size object.
	 *
	 * @param size The Size object to create the new vector from.
	 * @returns The new Vec2 object.
	 * @example
	 * ```
	 * const newVec = Vec2(Size(10, 20));
	 * ```
	 */
	(this: void, size: Size): Vec2;

	/**
	 * Gets zero-vector object.
	 */
	readonly zero: Vec2;
}

const vec2: Vec2Class;
export {vec2 as Vec2};

/**
 * A rectangle object with a left-bottom origin position and a size.
 * Inherits from `ContainerItem`.
 */
class Rect extends ContainerItem {
	private constructor();

	// The position of the origin of the rectangle.
	origin: Vec2;

	// The dimensions of the rectangle.
	size: Size;

	// The x-coordinate of the origin of the rectangle.
	x: number;

	// The y-coordinate of the origin of the rectangle.
	y: number;

	// The width of the rectangle.
	width: number;

	// The height of the rectangle.
	height: number;

	// The top edge in y-axis of the rectangle.
	top: number;

	// The bottom edge in y-axis of the rectangle.
	bottom: number;

	// The left edge in x-axis of the rectangle.
	left: number;

	// The right edge in x-axis of the rectangle.
	right: number;

	// The x-coordinate of the center of the rectangle.
	centerX: number;

	// The y-coordinate of the center of the rectangle.
	centerY: number;

	// The lower bound (left-bottom) of the rectangle.
	lowerBound: Vec2;

	// The upper bound (right-top) of the rectangle.
	upperBound: Vec2;

	/**
	 * Set the properties of the rectangle.
	 * @param x The x-coordinate of the origin of the rectangle.
	 * @param y The y-coordinate of the origin of the rectangle.
	 * @param width The width of the rectangle.
	 * @param height The height of the rectangle.
	 */
	set(x: number, y: number, width: number, height: number): void;

	/**
	 * Check if a point is inside the rectangle.
	 * @param point The point to check, represented by a Vec2 object.
	 * @returns Whether or not the point is inside the rectangle.
	 */
	containsPoint(point: Vec2): boolean;

	/**
	 * Check if the rectangle intersects with another rectangle.
	 * @param rect The other rectangle to check for intersection with, represented by a Rect object.
	 * @returns Whether or not the rectangles intersect.
	 */
	intersectsRect(rect: Rect): boolean;

	/**
	 * Check if two rectangles are equal.
	 * @param other The other rectangle to compare to, represented by a Rect object.
	 * @returns Whether or not the two rectangles are equal.
	 */
	equals(other: Rect): boolean;
}

export namespace Rect {
	export type Type = Rect;
}

/**
 * A class for creating rectangle objects.
 */
interface RectClass {
	/**
	 * A rectangle object with all properties set to 0.
	 */
	readonly zero: Rect;

	/**
	 * Create a new rectangle object using another rectangle object.
	 * @param other The other rectangle object to create a new rectangle object from.
	 * @returns A new rectangle object.
	 */
	(this: void, other: Rect): Rect;

	/**
	 * Create a new rectangle object using individual properties.
	 * @param x The x-coordinate of the origin of the rectangle.
	 * @param y The y-coordinate of the origin of the rectangle.
	 * @param width The width of the rectangle.
	 * @param height The height of the rectangle.
	 * @returns A new rectangle object.
	 */
	(this: void, x: number, y: number, width: number, height: number): Rect;

	/**
	 * Create a new rectangle object using a Vec2 object for the origin and a Size object for the size.
	 * @param origin The origin of the rectangle, represented by a Vec2 object.
	 * @param size The size of the rectangle, represented by a Size object.
	 * @returns A new rectangle object.
	 */
	(this: void, origin: Vec2, size: Size): Rect;

	/**
	 * Create a new rectangle object with all properties set to 0.
	 * @returns A new rectangle object.
	 */
	(this: void): Rect;
}

const rectClass: RectClass;
export {rectClass as Rect};

/** A color with red, green, and blue channels. */
class Color3 {
	private constructor();

	/** The red channel of the color, should be 0 to 255. */
	r: number;

	/** The green channel of the color, should be 0 to 255. */
	g: number;

	/** The blue channel of the color, should be 0 to 255. */
	b: number;

	/**
	 * Converts the color to an RGB integer value.
	 * @returns Converted RGB integer.
	 */
	toRGB(): number;
}

export namespace Color3 {
	export type Type = Color3;
}

/** A class for creating Color3 objects. */
interface Color3Class {
	/**
	 * Creates a color with all channels set to 0.
	 * @returns A new `Color3` object.
	 */
	(this: void): Color3;

	/**
	 * Creates a new `Color3` object from an RGB integer value.
	 * @param rgb The RGB integer value to create the color from.
	 * For example 0xffffff (white), 0xff0000 (red).
	 * @returns A new `Color3` object.
	 */
	(this: void, rgb: number): Color3;

	/**
	 * Creates a new `Color3` object from RGB color channel values.
	 * @param r The red channel value (0-255).
	 * @param g The green channel value (0-255).
	 * @param b The blue channel value (0-255).
	 * @returns A new `Color3` object.
	 */
	(this: void, r: number, g: number, b: number): Color3;
}

const color3Class: Color3Class;
export {color3Class as Color3};

/**
 * Represents a color with red, green, blue, and alpha channels.
 */
class Color {
	private constructor();

	// The red channel of the color, should be 0 to 255.
	r: number;

	// The green channel of the color, should be 0 to 255.
	g: number;

	// The blue channel of the color, should be 0 to 255.
	b: number;

	// The alpha channel of the color, should be 0 to 255.
	a: number;

	/**
	 * Another representation for alpha channel.
	 * The opacity of the color, ranging from 0 to 1.
	 */
	opacity: number;

	/**
	 * Converts the color to a Color3 value without alpha channel.
	 * @returns Converted Color3 value.
	 */
	toColor3(): Color3;

	/**
	 * Converts the color to an ARGB integer value.
	 * @returns Converted ARGB integer.
	 */
	toARGB(): number;
}

export namespace Color {
	export type Type = Color;
}

/**
 * Provides methods for creating Color objects.
 */
interface ColorClass {
	/**
	 * Creates a color with all channels set to 0.
	 * @returns A new Color object.
	 */
	(this: void): Color;

	/**
	 * Creates a new Color object with a Color3 object and alpha value.
	 * @param color The color as a Color3 object.
	 * @param a [optional] The alpha value of the color ranging from 0 to 255.
	 * @returns A new Color object.
	 */
	(this: void, color: Color3, a?: number): Color;

	/**
	 * Creates a new `Color` object from an ARGB integer value.
	 * @param argb The ARGB integer value to create the color from.
	 * For example 0xffffffff (opaque white), 0x88ff0000 (half transparent red)
	 * @returns A new `Color` object.
	 */
	(this: void, argb: number): Color;

	/**
	 * Creates a new `Color` object from RGBA color channel values.
	 * @param r The red channel value (0-255).
	 * @param g The green channel value (0-255).
	 * @param b The blue channel value (0-255).
	 * @param a The alpha channel value (0-255).
	 * @returns A new `Color` object.
	 */
	(this: void, r: number, g: number, b: number, a: number): Color;
}

const colorClass: ColorClass;
export {colorClass as Color};

/** An enumerated type representing the platform the game engine is running on. */
export const enum PlatformType {
	Windows = "Windows",
	Android = "Android",
	macOS = "macOS",
	iOS = "iOS",
	Linux = "Linux",
	Unknown = "Unknown"
}

/**
 * An interface representing an application singleton instance.
 */
interface App {
	/** The current passed frame number. */
	readonly frame: number;

	/** The size of the main frame buffer texture used for rendering. */
	readonly bufferSize: Size;

	/**
	 * The logical visual size of the screen.
	 * The visual size only changes when application window size changes.
	 * And it won't be affected by the view buffer scaling factor.
	 */
	readonly visualSize: Size;

	/**
	 * The ratio of the pixel density displayed by the device.
	 * Can be calculated as the size of the rendering buffer divided by the size of the application window.
	 */
	readonly devicePixelRatio: number;

	/** An enumerated type representing the platform the game engine is running on. */
	readonly platform: PlatformType;

	/** The version string of the game engine. Should be in format of "v0.0.0.0". */
	readonly version: string;

	/** The time in seconds since the last frame update. */
	readonly deltaTime: number;

	/** The elapsed time since current frame was started, in seconds. */
	readonly elapsedTime: number;

	/**
	 * The total time the game engine has been running until last frame ended, in seconds.
	 * Should be a constant number when invoked in the same frame for multiple times.
	 */
	readonly totalTime: number;

	/**
	 * The total time the game engine has been running until this field being accessed, in seconds.
	 * Should be an increasing number when invoked in the same frame for multiple times.
	 */
	readonly runningTime: number;

	/**
	 * A random number generated by a random number engine based on Mersenne Twister algorithm.
	 * So that the random number generated by the same seed should be consistent on every platform.
	 */
	readonly rand: number;

	/**
	 * The maximum valid frames per second the game engine is allowed to run at.
	 * The max FPS is being inferred by the device screen max refresh rate.
	 */
	readonly maxFPS: number;

	/** Whether the game engine is running in debug mode. */
	readonly debugging: boolean;

	/** An array of test names of engine included C++ tests. */
	readonly testNames: string[];

	/** The system locale string, in format like: `zh-Hans`, `en`. */
	locale: string;

	/** A theme color for Dora SSR. */
	themeColor: Color;

	/** A random number seed. */
	seed: number;

	/**
	 * The target frames per second the game engine is supposed to run at.
	 * Only works when `fpsLimited` is set to true.
	 */
	targetFPS: number;

	/**
	 * Whether the game engine is limiting the frames per second.
	 * Set `fpsLimited` to true, will make engine run in a busy loop to track the precise frame time to switch to the next frame.
	 * This behavior can lead to 100% CPU usage. This is usually common practice on Windows PCs for better CPU usage occupation.
	 * But it also results in extra heat and power consumption.
	 */
	fpsLimited: boolean;

	/**
	 * Whether the game engine is currently idled.
	 * Set `idled` to true, will make game logic thread use a sleep time and going idled for next frame to come.
	 * This idled state may cause game engine over slept for a few frames to lost.
	 * `idled` state can reduce some CPU usage.
	 */
	idled: boolean;

	/**
	 * Whether the game engine is running in full screen mode.
	 * It is not available to set this property on platform Android and iOS.
	 */
	fullScreen: boolean;

	/**
	 * Whether the game engine window is always on top.
	 * It is not available to set this property on platform Android and iOS.
	 */
	alwayOnTop: boolean;

	/**
	 * The application window size.
	 * May differ from visual size due to the different DPIs of display devices.
	 * It is not available to set this property on platform Android and iOS.
	 */
	winSize: Size;

	/**
	 * The application window position.
	 * It is not available to set this property on platform Android and iOS.
	 */
	winPosition: Vec2;

	/**
	 * A function that runs a specific C++ test included in the engine.
	 * @param name The name of the test to run.
	 * @returns Whether the test ran successfully.
	 */
	runTest(name: string): boolean;

	/**
	 * A function that opens a URL in the system default browser.
	 * @param url The URL to open.
	 */
	openURL(url: string): void;

	/**
	 * A function used for self updating the game engine.
	 * @param path The path to the new engine file.
	 */
	install(path: string): void;

	/**
	 * A function that saves the log file to the specified path.
	 * @param path The path to save the log file to.
	 * @returns Whether the log was saved successfully.
	 */
	saveLog(path: string): boolean;

	/**
	 * A function that opens a file dialog. Only works on Windows, macOS and Linux.
	 * @param folderOnly Whether the file dialog is only for selecting folders.
	 * @param callback The callback function to be called when the file dialog is closed. The callback function should accept a string parameter which is the path of the selected file or folder. Get empty string if the user canceled the dialog.
	 */
	openFileDialog(folderOnly: boolean, callback: (path: string) => void): void;

	/**
	 * A function that shuts down the game engine.
	 * It is not working and acts as a dummy function for platform Android and iOS to follow the specification of how mobile platform applications should operate.
	 */
	shutdown(): void;
}

const app: App;
export {app as App};

/** A class that is a base class for many C++ objects managed by Lua VM. */
class Object extends ContainerItem {
	protected constructor();

	/** The ID of the C++ object. */
	readonly id: number;

	/** The Lua reference ID for this C++ object. */
	readonly ref: number;
}

export namespace Object {
	export type Type = Object;
}

/** The static class for accessing object class attributes. */
interface ObjectClass {
	/** The number of total existing C++ objects. */
	readonly count: number;

	/** The maximum number of C++ objects that were ever created. */
	readonly maxCount: number;

	/** The number of total existing Lua references to C++ objects. */
	readonly luaRefCount: number;

	/** The maximum number of Lua references that were ever created. */
	readonly maxLuaRefCount: number;

	/** The number of C++ function call objects referenced by Lua. */
	readonly callRefCount: number;

	/** The maximum number of C++ function call references that were ever created. */
	readonly maxCallRefCount: number;
}

const objectClass: ObjectClass;
export {objectClass as Object};

/** An empty interface as action definition instance. */
type ActionDef = BasicType<'ActionDef'>;

export namespace ActionDef {
	export type Type = ActionDef;
}

/** Represents an action that can be run on a node. */
interface Action extends Object {
	/** The duration of the action. */
	readonly duration: number;

	/** Whether the action is currently running. */
	readonly running: boolean;

	/** Whether the action is currently paused. */
	readonly paused: boolean;

	/** Whether the action should be run in reverse. */
	reversed: boolean;

	/**
	 * The speed at which the action should be run.
	 * Set to 1.0 to get normal speed, Set to 2.0 to get two times faster.
	 */
	speed: number;

	/** Pauses the action. */
	pause(): void;

	/** Resumes the action. */
	resume(): void;

	/**
	 * Updates the state of the Action.
	 * @param elapsed The amount of time in seconds that has elapsed to update action to.
	 * @param reversed Whether or not to update the Action in reverse (default is false).
	 */
	updateTo(elapsed: number, reversed?: boolean): void;
}

export namespace Action {
	export type Type = Action;
}

/** A class for creating an action that can be run on a Node */
interface ActionClass {
	/**
	 * Creates a new Action from the given definition
	 * @param actionDef The definition of the Action
	 * @returns The new Action object
	 */
	(this: void, actionDef: ActionDef): Action;
}

export const actionClass: ActionClass;
export {actionClass as Action};

/** Type for each easing function. */
export type EaseFunc = BasicType<'EaseFunc', number>;

/** Interface for the Ease object containing easing functions. */
interface EaseClass {
	/** An easing function that applies a linear rate of change. */
	Linear: EaseFunc;

	/** An easing function that starts slow and accelerates quickly. */
	InQuad: EaseFunc;

	/** An easing function that starts fast and decelerates quickly. */
	OutQuad: EaseFunc;

	/** An easing function that starts slow, accelerates, then decelerates. */
	InOutQuad: EaseFunc;

	/** An easing function that starts fast, decelerates, then accelerates. */
	OutInQuad: EaseFunc;

	/** An easing function that starts slow and accelerates gradually. */
	InCubic: EaseFunc;

	/** An easing function that starts fast and decelerates gradually. */
	OutCubic: EaseFunc;

	/** An easing function that starts slow, accelerates, then decelerates. */
	InOutCubic: EaseFunc;

	/** An easing function that starts fast, decelerates, then accelerates. */
	OutInCubic: EaseFunc;

	/** An easing function that starts slow and accelerates sharply. */
	InQuart: EaseFunc;

	/** An easing function that starts fast and decelerates sharply. */
	OutQuart: EaseFunc;

	/** An easing function that starts slow, accelerates sharply, then decelerates sharply. */
	InOutQuart: EaseFunc;

	/** An easing function that starts fast, decelerates sharply, then accelerates sharply. */
	OutInQuart: EaseFunc;

	/** An easing function that starts slow and accelerates extremely quickly. */
	InQuint: EaseFunc;

	/** An easing function that starts fast and decelerates extremely quickly. */
	OutQuint: EaseFunc;

	/** An easing function that starts slow, accelerates extremely quickly, then decelerates extremely quickly. */
	InOutQuint: EaseFunc;

	/** An easing function that starts fast, decelerates extremely quickly, then accelerates extremely quickly. */
	OutInQuint: EaseFunc;

	/** An easing function that starts slow and accelerates gradually, then slows down again. */
	InSine: EaseFunc;

	/** An easing function that starts fast and decelerates gradually, then slows down again. */
	OutSine: EaseFunc;

	/** An easing function that starts slow, accelerates gradually, then decelerates gradually. */
	InOutSine: EaseFunc;

	/** An easing function that starts fast, decelerates gradually, then accelerates gradually. */
	OutInSine: EaseFunc;

	/** An easing function that starts extremely slow and accelerates exponentially. */
	InExpo: EaseFunc;

	/** An easing function that starts extremely fast and decelerates exponentially. */
	OutExpo: EaseFunc;

	/** An easing function that starts extremely slow, accelerates exponentially, then decelerates exponentially. */
	InOutExpo: EaseFunc;

	/** An easing function that starts extremely fast, decelerates exponentially, then accelerates exponentially. */
	OutInExpo: EaseFunc;

	/** An easing function that starts slow and accelerates gradually in a circular fashion. */
	InCirc: EaseFunc;

	/** An easing function that starts fast and decelerates gradually in a circular fashion. */
	OutCirc: EaseFunc;

	/** An easing function that starts slow, accelerates gradually in a circular fashion, then decelerates gradually in a circular fashion. */
	InOutCirc: EaseFunc;

	/** An easing function that starts fast, decelerates gradually in a circular fashion, then accelerates gradually in a circular fashion. */
	OutInCirc: EaseFunc;

	/** An easing function that starts slow and accelerates exponentially, overshooting the target and then returning to it. */
	InElastic: EaseFunc;

	/** An easing function that starts fast and decelerates exponentially, overshooting the target and then returning to it. */
	OutElastic: EaseFunc;

	/** An easing function that starts slow, accelerates exponentially, overshooting the target and then returning to it, then decelerates exponentially, overshooting the target and then returning to it again. */
	InOutElastic: EaseFunc;

	/** An easing function that starts fast, decelerates exponentially, overshooting the target and then returning to it, then accelerates exponentially, overshooting the target and then returning to it again. */
	OutInElastic: EaseFunc;

	/** An easing function that starts slow and accelerates sharply backward before returning to the target. */
	InBack: EaseFunc;

	/** An easing function that starts fast and decelerates sharply backward before returning to the target. */
	OutBack: EaseFunc;

	/** An easing function that starts slow, accelerates sharply backward, then decelerates sharply forward before returning to the target. */
	InOutBack: EaseFunc;

	/** An easing function that starts fast, decelerates sharply backward, then accelerates sharply forward before returning to the target. */
	OutInBack: EaseFunc;

	/** An easing function that starts slow and accelerates in a bouncing motion before settling on the target. */
	InBounce: EaseFunc;

	/** An easing function that starts fast and decelerates in a bouncing motion before settling on the target. */
	OutBounce: EaseFunc;

	/** An easing function that starts slow, accelerates in a bouncing motion, then decelerates in a bouncing motion before settling on the target. */
	InOutBounce: EaseFunc;

	/** An easing function that starts fast, decelerates in a bouncing motion, then accelerates in a bouncing motion before settling on the target. */
	OutInBounce: EaseFunc;

	/**
	 * Applies an easing function to a given value over a given amount of time.
	 * @param easing The easing function to apply.
	 * @param time The amount of time to apply the easing function over, should be between 0 and 1.
	 * @returns The result of applying the easing function to the value.
	 */
	func(easing: EaseFunc, time: number): number;
}

export const Ease: EaseClass;

/**
 * Creates a definition for an action that animates the x anchor point of a Node from one value to another.
 * @param duration The duration of the animation in seconds.
 * @param from The starting value of the anchor point.
 * @param to The ending value of the anchor point.
 * @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
 * @returns An ActionDef object that can be used to run the animation on a Node.
 */
export function AnchorX(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // Default to Ease.Linear
): ActionDef;

/**
 * Creates a definition for an action that animates the y anchor point of a Node from one value to another.
 * @param duration The duration of the animation in seconds.
 * @param from The starting value of the anchor point.
 * @param to The ending value of the anchor point.
 * @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
 * @returns An ActionDef object that can be used to run the animation on a Node.
 */
export function AnchorY(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // Default to Ease.Linear
): ActionDef;

/**
 * Creates a definition for an action that animates the angle of a Node from one value to another.
 * @param duration The duration of the animation in seconds.
 * @param from The starting value of the angle in degrees.
 * @param to The ending value of the angle in degrees.
 * @param easing [optional] The easing function to use for the animation. Defaults to Linear if not specified.
 * @returns An ActionDef object that can be used to run the animation on a Node.
 */
export function Angle(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // Defaults to Linear
): ActionDef;

/**
 * Creates a definition for an action that animates the x-axis rotation angle of a Node from one value to another.
 * @param duration The duration of the animation in seconds.
 * @param from The starting value of the x-axis rotation angle in degrees.
 * @param to The ending value of the x-axis rotation angle in degrees.
 * @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
 * @returns An ActionDef object that can be used to run the animation on a Node.
 */
export function AngleX(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // Ease.Linear
): ActionDef;

/**
 * Creates a definition for an action that animates the y-axis rotation angle of a Node from one value to another.
 * @param duration The duration of the animation in seconds.
 * @param from The starting value of the y-axis rotation angle in degrees.
 * @param to The ending value of the y-axis rotation angle in degrees.
 * @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
 * @returns An ActionDef object that can be used to run the animation on a Node.
 */
export function AngleY(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // Ease.Linear
): ActionDef;

/**
 * Creates a definition for an action that makes a delay in the animation timeline.
 * @param duration The duration of the delay in seconds.
 * @returns An ActionDef object that represents a delay in the animation timeline.
 */
export function Delay(this: void, duration: number): ActionDef;

/**
 * Creates a definition for an action that emits an event.
 * @param name The name of the event to be triggered.
 * @param param The parameter to pass to the event. (default: "")
 * @returns The created `ActionDef`.
 * @example
 * Get this event by register event from the action performing node.
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
* Creates a definition for an action that animates the width of a Node.
* @param duration The duration of the animation in seconds.
* @param from The starting width value of the Node.
* @param to The ending width value of the Node.
* @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
* @returns An ActionDef object that can be used to run the animation on a Node.
*/
export function Width(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc
): ActionDef;

/**
 * Creates a definition for an action that animates the height of a Node.
 * @param duration The duration of the animation in seconds.
 * @param from The starting height value of the Node.
 * @param to The ending height value of the Node.
 * @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
 * @returns An ActionDef object that can be used to run the animation on a Node.
 */
export function Height(this: void, duration: number, from: number, to: number, easing?: EaseFunc): ActionDef;

/**
 * Creates a definition for an action that hides a Node.
 * @returns An ActionDef object that can be used to hide a Node.
 */
export function Hide(this: void): ActionDef;

/**
* Creates a definition for an action that shows a Node.
* @returns An ActionDef object that can be used to show a Node.
*/
export function Show(this: void): ActionDef;

/**
 * Creates a definition for an action that animates the position of a Node from one Vec2 value to another.
 * @param duration The duration of the animation in seconds.
 * @param from The starting position of the Node.
 * @param to The ending position of the Node.
 * @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
 * @returns An ActionDef object that can be used to run the animation on a Node.
 */
export function Move(this: void, duration: number, from: Vec2, to: Vec2, easing?: EaseFunc): ActionDef;

/**
 * Creates a definition for an action that animates the opacity of a Node from one value to another.
 * @param duration The duration of the animation in seconds.
 * @param from The starting opacity value of the Node (0-1.0).
 * @param to The ending opacity value of the Node (0-1.0).
 * @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
 * @returns An ActionDef object that can be used to run the animation on a Node.
 */
export function Opacity(this: void, duration: number, from: number, to: number, easing?: EaseFunc): ActionDef;

/**
 * Creates a definition for an action that animates the rotation of a Node from one value to another.
 * The roll animation will make sure the node is rotated to the target angle by the minimum rotation angle.
 * @param duration The duration of the animation in seconds.
 * @param from The starting roll value of the Node (in degrees).
 * @param to The ending roll value of the Node (in degrees).
 * @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
 * @returns An ActionDef object that can be used to run the animation on a Node.
 */
export function Roll(this: void, duration: number, from: number, to: number, easing?: EaseFunc): ActionDef;

/**
 * Creates a definition for an action that animates the x-axis and y-axis scale of a Node from one value to another.
 * @param duration The duration of the animation in seconds.
 * @param from The starting value of the x-axis and y-axis scale.
 * @param to The ending value of the x-axis and y-axis scale.
 * @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
 * @returns An ActionDef object that can be used to run the animation on a Node.
 */
export function Scale(this: void, duration: number, from: number, to: number, easing?: EaseFunc): ActionDef;

/**
 * Creates a definition for an action that animates the x-axis scale of a Node from one value to another.
 * @param duration The duration of the animation in seconds.
 * @param from The starting value of the x-axis scale.
 * @param to The ending value of the x-axis scale.
 * @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
 * @returns An ActionDef object that can be used to run the animation on a Node.
 */
export function ScaleX(this: void, duration: number, from: number, to: number, easing?: EaseFunc): ActionDef;

/**
 * Creates a definition for an action that animates the y-axis scale of a Node from one value to another.
 * @param duration The duration of the animation in seconds.
 * @param from The starting value of the y-axis scale.
 * @param to The ending value of the y-axis scale.
 * @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
 * @returns An ActionDef object that can be used to run the animation on a Node.
 */
export function ScaleY(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc
): ActionDef;

/**
* Creates a definition for an action that animates the skew of a Node along the x-axis.
* @param duration The duration of the animation in seconds.
* @param from The starting skew value of the Node on the x-axis (in degrees).
* @param to The ending skew value of the Node on the x-axis (in degrees).
* @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
* @returns An ActionDef object that can be used to run the animation on a Node.
*/
export function SkewX(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc
): ActionDef;

/**
* Creates a definition for an action that animates the skew of a Node along the y-axis.
* @param duration The duration of the animation in seconds.
* @param from The starting skew value of the Node on the y-axis (in degrees).
* @param to The ending skew value of the Node on the y-axis (in degrees).
* @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
* @returns An ActionDef object that can be used to run the animation on a Node.
*/
export function SkewY(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc
): ActionDef;

/**
 * Creates a definition for an action that animates the x-position of a Node.
 * @param duration The duration of the animation in seconds.
 * @param from The starting x-position of the Node.
 * @param to The ending x-position of the Node.
 * @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
 * @returns An ActionDef object that can be used to run the animation on a Node.
 */
export function X(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // Default: Ease.Linear
): ActionDef;

/**
 * Creates a definition for an action that animates the y-position of a Node.
 * @param duration The duration of the animation in seconds.
 * @param from The starting y-position of the Node.
 * @param to The ending y-position of the Node.
 * @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
 * @returns An ActionDef object that can be used to run the animation on a Node.
 */
export function Y(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // Default: Ease.Linear
): ActionDef;

/**
 * Creates a definition for an action that animates the z-position of a Node.
 * @param duration The duration of the animation in seconds.
 * @param from The starting z-position of the Node.
 * @param to The ending z-position of the Node.
 * @param easing [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
 * @returns An ActionDef object that can be used to run the animation on a Node.
 */
export function Z(
	this: void,
	duration: number,
	from: number,
	to: number,
	easing?: EaseFunc // Default: Ease.Linear
): ActionDef;

/**
* Creates a definition for an action that runs a group of actions in parallel.
* @param actions The ActionDef objects to run in parallel.
* @returns An ActionDef object that can be used to run the group of actions on a Node.
*/
export function Spawn(this: void, ...actions: ActionDef[]): ActionDef;

/**
 * Creates a definition for an action that runs a sequence of actions.
 * @param actions The ActionDef objects to run in sequence.
 * @returns An ActionDef object that can be used to run the sequence of actions on a Node.
 */
export function Sequence(this: void, ...actions: ActionDef[]): ActionDef;

/**
 * Create a frame animation with frames count for each frame. Can only be performed on a Sprite node.
 * @param clipStr The string containing format for loading a texture file.
 * Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.
 * @param duration The total duration of the animation.
 * @param frames [optional] The number of frames for each frame. The number of frames should match the number of frames in the clip.
 * @returns Returns a new action definition.
 */
export function Frame(this: void, clipStr: string, duration: number, frames?: number[]): ActionDef;

/**
 * The supported array data types.
 * This can be an integer, number, boolean, string, thread, ContainerItem.
 */
export type Item = number | boolean | string | LuaThread | ContainerItem;

/**
 * An array data structure that supports various operations.
 * The Array class is designed to be 1-based indexing, which means that the first item in the array has an index of 1.
 * This is the same behavior of Lua table used as an array.
 */
class Array extends Object {
	private constructor();

	/** The number of items in the array. */
	readonly count: number;

	/** Whether the array is empty or not. */
	readonly empty: boolean;

	/**
	 * Adds all items from another array to the end of this array.
	 * @param other Another array object.
	 */
	addRange(other: Array): void;

	/**
	 * Removes all items from this array that are also in another array.
	 * @param other Another array object.
	 */
	removeFrom(other: Array): void;

	/** Removes all items from the array. */
	clear(): void;

	/** Reverses the order of the items in the array. */
	reverse(): void;

	/** Removes any empty slots from the end of the array. Used for releasing the unused memory this array holds. */
	shrink(): void;

	/**
	 * Swaps the items at two given indices.
	 * @param indexA The first index.
	 * @param indexB The second index.
	 */
	swap(indexA: number, indexB: number): void;

	/**
	 * Removes the item at the given index.
	 * @param index The index to remove.
	 * @returns True if an item was removed, false otherwise.
	 */
	removeAt(index: number): boolean;

	/**
	 * Removes the item at the given index without preserving the order of the array.
	 * @param index The index to remove.
	 * @returns True if an item was removed, false otherwise.
	 */
	fastRemoveAt(index: number): boolean;

	/**
	 * Calls a given function for each item in the array. The items in the array can not be added or removed during the iteration.
	 * Should return false to continue iteration, true to stop.
	 * @param func The function to call for each item.
	 * @returns False if the iteration completed, true if it was interrupted by the function.
	 */
	each(func: (this: void, item: Item) => boolean): boolean;

	/** The first item in the array. */
	readonly first: Item;

	/** The last item in the array. */
	readonly last: Item;

	/** A random item from the array. */
	readonly randomObject: Item;

	/**
	 * Sets the item at the given index.
	 * @param index The index to set, should be 1 based.
	 * @param item The new item value.
	 */
	set(index: number, item: Item): void;

	/**
	 * Gets the item at the given index.
	 * @param index The index to get, should be 1 based.
	 * @returns The item value.
	 */
	get(index: number): Item;

	/**
	 * Adds an item to the end of the array.
	 * @param item The item to add.
	 */
	add(item: Item): void;

	/**
	 * Inserts an item at the given index, shifting other items to the right.
	 * @param index The index to insert at.
	 * @param item The item to insert.
	 */
	insert(index: number, item: Item): void;

	/**
	 * Checks whether the array contains a given item.
	 * @param item The item to check.
	 * @returns True if the item is found, false otherwise.
	 */
	contains(item: Item): boolean;

	/**
	 * Gets the index of a given item.
	 * @param item The item to search for.
	 * @returns The index of the item, or 0 if it is not found.
	 */
	index(item: Item): number;

	/**
	 * Removes and returns the last item in the array.
	 * @returns The last item in the array.
	 */
	removeLast(): Item;

	/**
	 * Removes the first occurrence of a given item from the array without preserving order.
	 * @param item The item to remove.
	 * @returns True if the item was found and removed, false otherwise.
	 */
	fastRemove(item: Item): boolean;

	/**
	 * Access the item at the given index using the [] operator.
	 * @param index The index to get, should be 1 based.
	 * @returns The item value.
	 */
	[index: number]: Item | undefined;
}

export namespace Array {
	export type Type = Array;
}

/**
 * A class that creates Array objects.
 */
interface ArrayClass {
	/**
	 * Create a new, empty array object.
	 * @returns A new Array object.
	*/
	(this: void): Array;

	/**
	 * Create a new array object initialized with a list of items.
	 * @param items Items to initialize the array with.
	 * @returns A new Array object.
	*/
	(this: void, items: Item[]): Array;
}

const arrayClass: ArrayClass;
export {arrayClass as Array};

/**
 * Represents an audio player singleton object.
 */
class Audio {
	private constructor();

	/** The speed of the sound. */
	soundSpeed: number;

	/** The global volume. */
	globalVolume: number;

	/** The listener node of the 3D sound source. */
	listener?: Node;

	/**
	 * Plays a sound effect and returns a handler for the audio.
	 *
	 * @param filename The path to the sound effect file (must be a WAV file).
	 * @param loop Whether to loop the sound effect. Default is false.
	 * @returns A handler for the audio that can be used to stop the sound effect.
	 */
	play(filename: string, loop?: boolean): number;

	/**
	 * Stops a sound effect that is currently playing.
	 *
	 * @param handler The handler for the audio that is returned by the `play` function.
	 */
	stop(handler: number): void;

	/**
	 * Plays a streaming audio file.
	 *
	 * @param filename The path to the streaming audio file (can be OGG, WAV, MP3, or FLAC).
	 * @param loop Whether to loop the streaming audio. Default is false.
	 * @param crossFadeTime The time (in seconds) to crossfade between the previous and new streaming audio. Default is 0.0.
	 */
	playStream(filename: string, loop?: boolean, crossFadeTime?: number): void;

	/**
	 * Stops a streaming audio file that is currently playing.
	 *
	 * @param fadeTime The time (in seconds) to fade out the streaming audio. Default is 0.0.
	 */
	stopStream(fadeTime?: number): void;

	/**
	 * Pauses all currently playing audio.
	 *
	 * @param pause The pause state.
	 */
	setPauseAllCurrent(pause: boolean): void;

	/**
	 * Sets the position of the listener.
	 *
	 * @param atX The x-axis position.
	 * @param atY The y-axis position.
	 * @param atZ The z-axis position.
	 */
	setListenerAt(atX: number, atY: number, atZ: number): void;

	/**
	 * Sets the up direction of the listener.
	 *
	 * @param upX The x-axis up direction.
	 * @param upY The y-axis up direction.
	 * @param upZ The z-axis up direction.
	 */
	setListenerUp(upX: number, upY: number, upZ: number): void;

	/**
	 * Sets the velocity of the listener.
	 *
	 * @param velocityX The x-axis velocity.
	 * @param velocityY The y-axis velocity.
	 * @param velocityZ The z-axis velocity.
	 */
	setListenerVelocity(velocityX: number, velocityY: number, velocityZ: number): void;
}

const audio: Audio;
export {audio as Audio};

/**
 * A blend function object used for rendering.
 */
type BlendFunc = BasicType<'BlendFunc'>;

/**
 * An enum defining blend functions.
 */
export const enum BlendOp {
	/**
	 * The source color is multiplied by 1 and added to the destination color
	 * (essentially, the source color is drawn on top of the destination color).
	 */
	One = "One",

	/**
	 * The source color is multiplied by 0 and added to the destination color
	 * (essentially, the source color has no effect on the destination color).
	 */
	Zero = "Zero",

	/**
	 * The source color is multiplied by the source alpha, and added to the
	 * destination color multiplied by the inverse of the source alpha.
	 */
	SrcColor = "SrcColor",

	/**
	 * The source alpha is multiplied by the source color, and added to the
	 * destination alpha multiplied by the inverse of the source alpha.
	 */
	SrcAlpha = "SrcAlpha",

	/**
	 * The destination color is multiplied by the destination alpha, and added to
	 * the source color multiplied by the inverse of the destination alpha.
	 */
	DstColor = "DstColor",

	/**
	 * The destination alpha is multiplied by the source alpha, and added to the
	 * source alpha multiplied by the inverse of the destination alpha.
	 */
	DstAlpha = "DstAlpha",

	/**
	 * Same as "SrcColor", but with the source and destination colors swapped.
	 */
	InvSrcColor = "InvSrcColor",

	/**
	 * Same as "SrcAlpha", but with the source and destination alphas swapped.
	 */
	InvSrcAlpha = "InvSrcAlpha",

	/**
	 * Same as "DstColor", but with the source and destination colors swapped.
	 */
	InvDstColor = "InvDstColor",

	/**
	 * Same as "DstAlpha", but with the source and destination alphas swapped.
	 */
	InvDstAlpha = "InvDstAlpha"
}

export namespace BlendFunc {
	export type Type = BlendFunc;
}

/**
 * A class for creating BlendFunc objects.
 */
interface BlendFuncClass {
	/**
	 * Gets the integer value of a blend function.
	 * @param func The blend function to get the value of.
	 * @returns The integer value of the specified blend function.
	 */
	get(func: BlendOp): number;

	/**
	 * Creates a new BlendFunc instance with the specified source and destination factors.
	 * @param src The source blend factor.
	 * @param dst The destination blend factor.
	 * @returns The new BlendFunc instance.
	 */
	(this: void, src: BlendOp, dst: BlendOp): BlendFunc;

	/**
	 * Creates a new BlendFunc instance with the specified source and destination factors for color and alpha channels.
	 * @param srcColor The source blend factor for the color channel.
	 * @param dstColor The destination blend factor for the color channel.
	 * @param srcAlpha The source blend factor for the alpha channel.
	 * @param dstAlpha The destination blend factor for the alpha channel.
	 * @returns The new BlendFunc instance.
	 */
	(this: void, srcColor: BlendOp, dstColor: BlendOp, srcAlpha: BlendOp, dstAlpha: BlendOp): BlendFunc;

	/**
	 * The default blend function.
	 * Equals to `BlendFunc(BlendOp.SrcAlpha, BlendOp.InvSrcAlpha, BlendOp.One, BlendOp.InvSrcAlpha)`.
	 */
	readonly default: BlendFunc;
}

const blendFuncClass: BlendFuncClass;
export {blendFuncClass as BlendFunc};

/**
* The Job type, representing a coroutine thread.
*/
export type Job = BasicType<"Job", LuaThread>;

/**
 * A singleton interface for managing coroutines.
 */
interface Routine {
	/**
	 * Remove a coroutine job from the set and close it if it is still running.
	 * @param job The Job instance to remove.
	 * @returns True if the job was removed, false otherwise.
	 */
	remove(job: Job): boolean;

	/**
	 * Remove all coroutine jobs and close them if they are still running.
	 */
	clear(): void;

	/**
	 * Add a new Job to the Routine.
	 * @param job The Job instance to add.
	 * @returns The Job instance that was added.
	 */
	(this: void, job: Job): Job;
}

const routine: Routine;
export {routine as Routine};

/**
 * Creates a new coroutine from a function and executes it.
 * @param routine A function to execute as a coroutine.
 * @returns A handle to the coroutine that was created.
 */
export function thread(this: void, routine: (this: void) => void): Job;

/**
 * Create a new coroutine from a function that runs repeatedly.
 * @param routine A function to execute repeatedly as a coroutine. The function should return false to continue running, or true to stop.
 * @returns A handle to the coroutine that was created.
 */
export function threadLoop(this: void, routine: (this: void) => boolean): Job;

/**
 * A function that keeps another function to run repeatedly for a duration of time.
 * @param duration The duration of the cycle, in seconds.
 * @param work A function to execute repeatedly during the cycle, receiving a time value from 0 to 1 to indicate the execution progress.
 */
export function cycle(this: void, duration: number, work: (this: void, time: number) => void): void;

/**
 * Create a coroutine job that runs once.
 * @param routine A routine function to execute once when the coroutine is resumed.
 * Yield true or just return inside the routine function to stop the job execution half way.
 * @returns A coroutine that runs the given routine function once.
 */
export function once(this: void, routine: (this: void) => void): Job;

/**
 * Create a coroutine job that runs repeatedly until a condition is met.
 * @param routine A routine function to execute repeatedly until it returns non-nil or non-false.
 * Yield or return true inside the routine function to stop the job execution.
 * @returns A coroutine that runs the given routine function repeatedly.
 */
export function loop(this: void, routine: (this: void) => boolean): Job;

/**
 * Wait until a condition is true in a coroutine.
 * @param condition A function that returns true when the condition is met.
 */
export function wait(this: void, condition: (this: void) => boolean): void;

/**
 * Yield the coroutine for a specified duration.
 * @param duration The duration to yield for, in seconds. If undefined, the coroutine will be yielded for one frame.
 */
export function sleep(this: void, duration?: number): void;

/**
 * A scheduler that manages the execution of scheduled tasks.
 * Inherits from `Object`.
 */
class Scheduler extends Object {
	private constructor();

	/**
	 * The time scale factor for the scheduler.
	 * This factor is applied to deltaTime that the scheduled functions will receive.
	 */
	timeScale: number;

	/**
	 * The target frame rate (in frames per second) for a fixed update mode.
	 * The fixed update will ensure a constant frame rate, and the operation handled in a fixed update can use a constant delta time value.
	 * It is used for preventing weird behavior of a physics engine or synchronizing some states via network communications.
	 */
	fixedFPS: number;

	/**
	 * Schedules a main function to run every frame. Call this function again to replace the previous scheduled main function or coroutine.
	 * @param handler The main function to be called every frame. It should take a single argument of type number, which represents the delta time since the last frame, returns true to stop.
	 * If the function returns true, it will not be called again.
	 */
	schedule(handler: (this: void, deltaTime: number) => boolean): void;

	/**
	 * Schedules a main coroutine to run. Call this function again to replace the previous scheduled main function or coroutine.
	 * @param job The coroutine job to be resumed.
	 */
	schedule(job: Job): void;

	/**
	 * Manually updates the scheduler if it is created by the user.
	 * @param deltaTime The time interval between the last update and the current update.
	 * @returns False if the scheduler is still running, true otherwise.
	 */
	update(deltaTime: number): boolean;
}

export namespace Scheduler {
	export type Type = Scheduler;
}

/**
* A class for creating Scheduler objects.
*/
interface SchedulerClass {
	/**
	 * Creates a new Scheduler object.
	 * @returns The newly created Scheduler object.
	 */
	(this: void): Scheduler;
}

const scheduler: SchedulerClass;
export {scheduler as Scheduler};

/**
 * A class type for storing pairs of string keys and various values.
 * Inherits from `Object`.
 */
class Dictionary extends Object {
	private constructor();

	/**
	 * The number of items in the dictionary.
	 */
	readonly count: number;

	/**
	 * The keys of the items in the dictionary.
	 */
	readonly keys: string[];

	/**
	 * A method for accessing items in the dictionary.
	 * @param key The key of the item to retrieve.
	 * @returns The Item with the given key, or undefined if it does not exist.
	 */
	get(key: string): Item | undefined;

	/**
	 * A method for setting items in the dictionary.
	 * @param key The key of the item to set.
	 * @param item The Item to set for the given key, set to undefined or null to delete this key-value pair.
	 */
	set(key: string, item: Item | null | undefined): void;

	/**
	 * A function that iterates over each item in the dictionary and calls a given function with the item and its key. The items in the dictionary can not be added or removed during the iteration.
	 * This function should take an Item and a string as arguments and return a boolean. Returns true to stop iteration, false to continue.
	 * @param func The function to call for each item in the dictionary.
	 * @returns Returns false if the iteration completed successfully, true otherwise.
	 */
	each(func: (this: void, item: Item, key: string) => boolean): boolean;

	/**
	 * A function that removes all the items from the dictionary.
	 */
	clear(): void;

	/**
	 * Allows accessing items in the dictionary using the index notation, e.g. "dict['key']" or "dict.key".
	 * @param key The key of the item to retrieve.
	 * @returns The Item with the given key, or undefined if it does not exist.
	 */
	[key: string]: Item | undefined | null;
}

export namespace Dictionary {
	export type Type = Dictionary;
}

/**
 * A class for creating Dictionary
 * @example
 * ```
 * import { Dictionary } from "Dora";
 * const dict = Dictionary();
 * ```
 */
interface DictionaryClass {
	/**
	 * A method that allows creating instances of the "Dictionary" type.
	 * @returns A new instance of the Dictionary type.
	 */
	(this: void): Dictionary;
}

const dictionaryClass: DictionaryClass;
export {dictionaryClass as Dictionary};

/**
 * A Slot object that represents a single event slot with handlers.
 */
class Slot extends Object {
	private constructor();

	/**
	 * Adds a new handler function to this slot.
	 * @param handler The handler function to add.
	 */
	add(handler: (this: void, ...args: any[]) => void): void;

	/**
	 * Sets a new handler function for this slot, replacing any existing handlers.
	 * @param handler The handler function to set.
	 */
	set(handler: (this: void, ...args: any[]) => void): void;

	/**
	 * Removes a previously added handler function from this slot.
	 * @param handler The handler function to remove.
	 */
	remove(handler: (this: void, ...args: any[]) => void): void;

	/**
	 * Clears all handler functions from this slot.
	 */
	clear(): void;
}

/**
 * A global signal slot object that can be used to handle global events
 */
class GSlot extends Object {
	private constructor();

	/** The name of the GSlot */
	readonly name: string;

	/** Whether the GSlot is currently enabled or disabled */
	enabled: boolean;
}

/**
 * Represents a touch input or mouse click event.
 */
class Touch extends Object {
	private constructor();

	/**
	 * Whether touch input is enabled or not.
	 */
	enabled: boolean;

	/**
	 * Whether this is the first touch event when multi-touches exist.
	 */
	readonly first: boolean;

	/**
	 * The unique identifier assigned to this touch event.
	 */
	readonly id: number;

	/**
	 * The amount and direction of movement since the last touch event.
	 */
	readonly delta: Vec2;

	/**
	 * The location of the touch event in the node's local coordinate system.
	 */
	readonly location: Vec2;

	/**
	 * The location of the touch event in the world coordinate system.
	 */
	readonly worldLocation: Vec2;
}

export namespace Touch {
	export type Type = Touch;
}

/**
 * A class for the Camera object in the game engine.
 */
class Camera extends Object {
	protected constructor();

	/**
	 * The name of the Camera.
	 */
	readonly name: string;
}

export {Camera as CameraType};
export namespace Camera {
	export type Type = Camera;
}

/**
 * A class for 2D camera object in the game engine.
 */
class Camera2D extends Camera {
	private constructor();

	/**
	 * The rotation angle of the camera in degrees.
	 */
	rotation: number;

	/**
	 * The factor by which to zoom the camera. If set to 1.0, the view is normal sized. If set to 2.0, items will appear double in size.
	 */
	zoom: number;

	/**
	 * The position of the camera in the game world.
	 */
	position: Vec2;
}

export namespace Camera2D {
	export type Type = Camera2D;
}

/**
* A class for creating Camera2D objects.
*/
interface Camera2DClass {
	/**
	 * Creates a new Camera2D object with the given name.
	 * @param name The name of the Camera2D object. Defaults to an empty string.
	 * @returns A new instance of the Camera2D object.
	 */
	(this: void, name?: string): Camera2D;
}

const camera2DClass: Camera2DClass;
export {camera2DClass as Camera2D};

/**
 * A class of an orthographic camera object in the game engine.
 */
class CameraOtho extends Camera {
	private constructor();

	/**
	 * The position of the camera in the game world.
	 */
	position: Vec2;
}

export namespace CameraOtho {
	export type Type = CameraOtho;
}

/**
* A class for creating CameraOtho objects.
*/
interface CameraOthoClass {
	/**
	 * Creates a new CameraOtho object with the given name.
	 * @param name The name of the CameraOtho object. Defaults to an empty string.
	 * @returns A new instance of the CameraOtho object.
	 */
	(this: void, name?: string): CameraOtho;
}

const cameraOthoClass: CameraOthoClass;
export {cameraOthoClass as CameraOtho};

/**
 * A class representing a shader pass.
 */
class Pass extends Object {
	private constructor();

	/**
	 * Whether this Pass should be a grab pass.
	 * A grab pass will render a portion of the game scene into a texture frame buffer.
	 * Then use this texture frame buffer as an input for the next render pass.
	 */
	grabPass: boolean;

	/**
	 * A function that sets the values of shader parameters.
	 *
	 * @param name The name of the parameter to set.
	 * @param var1 The first numeric value to set.
	 * @param var2 An optional second numeric value to set (default is 0).
	 * @param var3 An optional third numeric value to set (default is 0).
	 * @param var4 An optional fourth numeric value to set (default is 0).
	 */
	set(name: string, var1: number, var2?: number, var3?: number, var4?: number): void;

	/**
	 * Another function that sets the values of shader parameters.
	 * Works the same as: pass.set("varName", color.r / 255.0, color.g / 255.0, color.b / 255.0, color.opacity)
	 *
	 * @param name The name of the parameter to set.
	 * @param cvar The Color object to set.
	 */
	set(name: string, cvar: Color): void;
}

export namespace Pass {
	export type Type = Pass;
}

/**
* A class for creating Pass objects.
*/
interface PassClass {
	/**
	 * A method that allows you to create a new Pass object.
	 *
	 * @param vertShader The vertex shader in binary form file string.
	 * @param fragShader The fragment shader file string.
	 * A shader file string must be one of the formats:
	 * 	"builtin:" + theBuiltinShaderName
	 * 	"Shader/compiled_shader_file.bin"
	 * @returns A new Pass object.
	 */
	(this: void, vertShader: string, fragShader: string): Pass;
}

const passClass: PassClass;
export {passClass as Pass};

/**
 * A class for managing multiple render pass objects.
 * Effect objects allow you to combine multiple passes to create more complex shader effects.
 */
class Effect extends Object {
	protected constructor();

	/**
	 * A function that adds a Pass object to this Effect.
	 * @param pass The Pass object to add.
	 */
	add(pass: Pass): void;

	/**
	 * A function that retrieves a Pass object from this Effect by index.
	 * @param index The index of the Pass object to retrieve. Starts from 1.
	 * @returns The Pass object at the given index.
	 */
	get(index: number): Pass;

	/**
	 * A function that removes all Pass objects from this Effect.
	 */
	clear(): void;
}

export namespace Effect {
	export type Type = Effect;
}

/**
* A class for creating Effect objects.
*/
interface EffectClass {
	/**
	 * A method that allows you to create a new Effect object.
	 * @param vertShader The vertex shader file string.
	 * @param fragShader The fragment shader file string.
	 * A shader file string must be one of the formats:
	 * 	"builtin:" + theBuiltinShaderName
	 * 	"Shader/compiled_shader_file.bin"
	 * @returns A new Effect object.
	 */
	(this: void, vertShader: string, fragShader: string): Effect;

	/**
	 * Another method that allows you to create a new empty Effect object.
	 * @returns A new empty Effect object.
	 */
	(this: void): Effect;
}

const effectClass: EffectClass;
export {effectClass as Effect};

/**
 * A classe that is a specialization of Effect for rendering 2D sprites.
 */
class SpriteEffect extends Effect {}

export namespace SpriteEffect {
	export type Type = SpriteEffect;
}

/**
 * A class for creating SpriteEffect objects.
 */
interface SpriteEffectClass {
	/**
	 * A method that allows you to create a new SpriteEffect object.
	 * @param vertShader The vertex shader file string. A shader file string must be one of the formats:
	 * "builtin:" + theBuiltinShaderName
	 * "Shader/compiled_shader_file.bin"
	 * @param fragShader The fragment shader file string.
	 * @returns A new SpriteEffect object.
	 */
	(this: void, vertShader: string, fragShader: string): SpriteEffect;

	/**
	 * A method for creating a new empty SpriteEffect object.
	 * @returns A new SpriteEffect object.
	 */
	(this: void): SpriteEffect;
}

const spriteEffectClass: SpriteEffectClass;
export {spriteEffectClass as SpriteEffect};

/**
 * Enumeration for defining the keys.
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
 * An interface for handling keyboard inputs.
 */
interface Keyboard {
	/**
	 * Check whether a key is pressed down in the current frame.
	 * @param name The name of the key to check.
	 * @returns Whether the key is pressed down.
	 */
	isKeyDown(name: KeyName): boolean;

	/**
	 * Check whether a key is released in the current frame.
	 * @param name The name of the key to check.
	 * @returns Whether the key is released.
	 */
	isKeyUp(name: KeyName): boolean;

	/**
	 * Check whether a key is in pressed state.
	 * @param name The name of the key to check.
	 * @returns Whether the key is in pressed state.
	 */
	isKeyPressed(name: KeyName): boolean;

	/**
	 * Update the input method editor (IME) position hint.
	 * @param winPos The position of the keyboard window.
	 */
	updateIMEPosHint(winPos: Vec2): void;
}

const keyboard: Keyboard;
export {keyboard as Keyboard};

/**
 * An interface for handling mouse inputs.
 */
interface Mouse {
	/**
	 * The position of the mouse in the visible window.
	 * You can use `Mouse.position.mul(App.devicePixelRatio)` to get the coordinate in the game world.
	 * Then use `node.convertToNodeSpace()` to convert the world coordinate to the local coordinate of the node.
	 * @example
	 * ```
	 * const worldPos = Mouse.position.mul(App.devicePixelRatio);
	 * const nodePos = node.convertToNodeSpace(worldPos);
	 * ```
	 */
	readonly position: Vec2
	/**
	 * Whether the left mouse button is being pressed down.
	 */
	readonly leftButtonPressed: boolean
	/**
	 * Whether the right mouse button is being pressed down.
	 */
	readonly rightButtonPressed: boolean
	/**
	 * Whether the middle mouse button is being pressed down.
	 */
	readonly middleButtonPressed: boolean
	/**
	 * Gets the mouse wheel value.
	 */
	readonly wheel: Vec2
}

const mouse: Mouse;
export {mouse as Mouse};

/**
 * Enumeration for defining the controller axis names.
 */
export const enum AxisName {
	LeftX = "leftx",
	LeftY = "lefty",
	RightX = "rightx",
	RightY = "righty",
	LeftTrigger = "lefttrigger",
	RightTrigger = "righttrigger"
}

/**
* Enumeration for defining the controller button names.
*/
export const enum ButtonName {
	A = "a",
	B = "b",
	Back = "back",
	Down = "dpdown",
	Left = "dpleft",
	Right = "dpright",
	Up = "dpup",
	LeftShoulder = "leftshoulder",
	LeftStick = "leftstick",
	RightShoulder = "rightshoulder",
	RightStick = "rightstick",
	Start = "start",
	X = "x",
	Y = "y"
}

/**
 * An interface for handling game controller inputs.
 */
interface Controller {
	/**
	 * Check whether a button is pressed down in current frame.
	 * @param controllerId The controller id, incrementing from 0 when multiple controllers are connected.
	 * @param name The name of the button to check.
	 * @returns Whether the button is pressed down.
	 */
	isButtonDown(controllerId: number, name: ButtonName): boolean;

	/**
	 * Check whether a button is released in current frame.
	 * @param controllerId The controller id, incrementing from 0 when multiple controllers are connected.
	 * @param name The name of the button to check.
	 * @returns Whether the button is released.
	 */
	isButtonUp(controllerId: number, name: ButtonName): boolean;

	/**
	 * Check whether a button is in pressed state.
	 * @param controllerId The controller id, incrementing from 0 when multiple controllers are connected.
	 * @param name The name of the button to check.
	 * @returns Whether the button is in pressed state.
	 */
	isButtonPressed(controllerId: number, name: ButtonName): boolean;

	/**
	 * Get the axis value from a given controller.
	 * @param controllerId The controller id, incrementing from 0 when multiple controllers are connected.
	 * @param name The name of the controller axis to check.
	 * @returns The axis value ranging from -1.0 to 1.0.
	 */
	getAxis(controllerId: number, name: AxisName): number;
}

const controller: Controller;
export {controller as Controller};

/**
 * A grabber which is used to render a part of the scene to a texture by a grid of vertices.
 * @example
 * const node = Node();
 * node.size = Size(500, 500);
 * const grabber = node.grab();
 * grabber.moveUV(0, 0, Vec2(0, 0.1));
 */
class Grabber extends Object {
	private constructor();

	/**
	* The camera used to render the texture.
	*/
	camera: Camera;

	/**
	* The sprite effect applied to the texture.
	*/
	effect: SpriteEffect;

	/**
	* The blend function applied to the texture.
	*/
	blendFunc: BlendFunc;

	/**
	* The clear color used to clear the texture.
	*/
	clearColor: Color;

	/**
	* Sets the position of a vertex in the grabber grid.
	* @param x The x-index of the vertex in the grabber grid.
	* @param y The y-index of the vertex in the grabber grid.
	* @param pos The new position of the vertex.
	* @param z [optional] The new z-coordinate of the vertex (default: 0.0).
	*/
	setPos(x: number, y: number, pos: Vec2, z?: number): void;

	/**
	* Gets the position of a vertex in the grabber grid.
	* @param x The x-index of the vertex in the grabber grid.
	* @param y The y-index of the vertex in the grabber grid.
	* @returns The position of the vertex.
	*/
	getPos(x: number, y: number): Vec2;

	/**
	* Gets the color of a vertex in the grabber grid.
	* @param x The x-index of the vertex in the grabber grid.
	* @param y The y-index of the vertex in the grabber grid.
	* @returns The color of the vertex.
	*/
	getColor(x: number, y: number): Color;

	/**
	* Sets the color of a vertex in the grabber grid.
	* @param x The x-index of the vertex in the grabber grid.
	* @param y The y-index of the vertex in the grabber grid.
	* @param color The new color of the vertex.
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
	ButtonPressed = "ButtonPressed",
	Axis = "Axis",
	AnimationEnd = "AnimationEnd",
	BodyEnter = "BodyEnter",
	BodyLeave = "BodyLeave",
	ContactStart = "ContactStart",
	ContactEnd = "ContactEnd",
	Finished = "Finished",
	AlignLayout = "AlignLayout",
	EffekEnd = "EffekEnd",
}

export {NodeEvent as Slot};

interface NodeEventHandlerMap {
	/**
	 * The ActionEnd slot is triggered when an action is finished.
	 * Triggers after `node.runAction()` and `node.perform()`.
	 * @param action The finished action.
	 * @param target The node that finished the action.
	 */
	ActionEnd(this: void, action: Action, target: Node): void;

	/**
	 * The TapFilter slot is triggered before the TapBegan slot and can be used to filter out certain taps.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param touch The touch that triggered the tap.
	*/
	TapFilter(this: void, touch: Touch): void;

	/**
	 * The TapBegan slot is triggered when a tap is detected.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param touch The touch that triggered the tap.
	*/
	TapBegan(this: void, touch: Touch): void;

	/**
	 * The TapEnded slot is triggered when a tap ends.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param touch The touch that triggered the tap.
	*/
	TapEnded(this: void, touch: Touch): void;

	/**
	 * The Tapped slot is triggered when a tap is detected and has ended.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param touch The touch that triggered the tap.
	*/
	Tapped(this: void, touch: Touch): void;

	/**
	 * The TapMoved slot is triggered when a tap moves.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param touch The touch that triggered the tap.
	*/
	TapMoved(this: void, touch: Touch): void;

	/**
	 * The MouseWheel slot is triggered when the mouse wheel is scrolled.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param delta The amount of scrolling that occurred.
	*/
	MouseWheel(this: void, delta: Vec2): void;

	/**
	 * The Gesture slot is triggered when a gesture is recognized.
	 * Triggers after setting `node.touchEnabled = true`.
	 * @param center The center of the gesture.
	 * @param numFingers The number of fingers involved in the gesture.
	 * @param deltaDist The distance the gesture has moved.
	 * @param deltaAngle The angle of the gesture.
	*/
	Gesture(this: void, center: Vec2, numFingers: number, deltaDist: number, deltaAngle: number): void;

	/**
	 * The Enter slot is triggered when a node is added to the scene graph.
	 * Triggers when doing `node.addChild()`.
	*/
	Enter(this: void): void;

	/**
	 * The Exit slot is triggered when a node is removed from the scene graph.
	 * Triggers when doing `node.removeChild()`.
	*/
	Exit(this: void): void;

	/**
	 * The Cleanup slot is triggered when a node is cleaned up.
	 * Triggers only when doing `parent.removeChild(node, true)`.
	*/
	Cleanup(this: void): void;

	/**
	 * The KeyDown slot is triggered when a key is pressed down.
	 * Triggers after setting `node.keyboardEnabled = true`.
	 * @param keyName The name of the key that was pressed.
	*/
	KeyDown(this: void, keyName: KeyName): void;

	/**
	 * The KeyUp slot is triggered when a key is released.
	 * Triggers after setting `node.keyboardEnabled = true`.
	 * @param keyName The name of the key that was released.
	*/
	KeyUp(this: void, keyName: KeyName): void;

	/**
	 * The KeyPressed slot is triggered when a key is pressed.
	 * Triggers after setting `node.keyboardEnabled = true`.
	 * @param keyName The name of the key that was pressed.
	*/
	KeyPressed(this: void, keyName: KeyName): void;

	/**
	 * The AttachIME slot is triggered when the input method editor (IME) is attached (calling `node.attachIME()`).
	*/
	AttachIME(this: void): void;

	/**
	 * The DetachIME slot is triggered when the input method editor (IME) is detached (calling `node.detachIME()` or manually closing IME).
	*/
	DetachIME(this: void): void;

	/**
	 * The TextInput slot is triggered when text input is received.
	 * Triggers after calling `node.attachIME()`.
	 * @param text The text that was input.
	*/
	TextInput(this: void, text: string): void;

	/**
	 * The TextEditing slot is triggered when text is being edited.
	 * Triggers after calling `node.attachIME()`.
	 * @param text The text that is being edited.
	 * @param startPos The starting position of the text being edited.
	*/
	TextEditing(this: void, text: string, startPos: number): void;

	/**
	 * The ButtonDown slot is triggered when a game controller button is pressed down.
	 * Triggers after setting `node.controllerEnabled = true`.
	 * @param controllerId The controller id, incrementing from 0 when multiple controllers connected.
	 * @param buttonName The name of the button that was pressed.
	*/
	ButtonDown(this: void, controllerId: number, buttonName: ButtonName): void;

	/**
	 * The ButtonUp slot is triggered when a game controller button is released.
	 * Triggers after setting `node.controllerEnabled = true`.
	 * @param controllerId The controller id, incrementing from 0 when multiple controllers connected.
	 * @param buttonName The name of the button that was released.
	*/
	ButtonUp(this: void, controllerId: number, buttonName: ButtonName): void;

	/**
	 * The ButtonPressed slot is triggered when a game controller button is being pressed.
	 * Triggers after setting `node.controllerEnabled = true`.
	 * @param controllerId The controller id, incrementing from 0 when multiple controllers connected.
	 * @param buttonName The name of the button that was pressed.
	*/
	ButtonPressed(this: void, controllerId: number, buttonName: ButtonName): void;

	/**
	 * The Axis slot is triggered when a game controller axis changed.
	 * Triggers after setting `node.controllerEnabled = true`.
	 * @param controllerId The controller id, incrementing from 0 when multiple controllers connected.
	 * @param axisName The name of the controller axis that changed.
	 * @param axisValue The controller axis value ranging from -1.0 to 1.0.
	*/
	Axis(this: void, controllerId: number, axisName: AxisName, axisValue: number): void;

	/**
	 * Triggers after an animation has ended on a Playable instance.
	 * @param animationName The name of the animation that ended.
	 * @param target The Playable instance that the animation was played on.
	*/
	AnimationEnd(this: void, animationName: string, target: Playable): void;

	/**
	 * Triggers when a Body object collides with a sensor object.
	 * This event triggers only when the Body attached with any fixture as sensor.
	 * @param other The other Body object that the current Body is colliding with.
	 * @param sensorTag The tag of the sensor that triggered this collision.
	*/
	BodyEnter(this: void, other: Body, sensorTag: number): void;

	/**
	 * Triggers when a `Body` object is no longer colliding with a sensor object.
	 * This event triggers only when the Body attached with any fixture as sensor.
	 * @param other The other `Body` object that the current `Body` is no longer colliding with.
	 * @param sensorTag The tag of the sensor that triggered this collision.
	*/
	BodyLeave(this: void, other: Body, sensorTag: number): void;

	/**
	 * Triggers when a `Body` object starts to collide with another object.
	 * Triggers after setting `body.receivingContact = true`.
	 * @param other The other `Body` object that the current `Body` is colliding with.
	 * @param point The point of collision in world coordinates.
	 * @param normal The normal vector of the contact surface in world coordinates.
	 * @param enabled Whether the collision is enabled. Collisions that are filtered out will still trigger this event, but with enabled set to false.
	*/
	ContactStart(this: void, other: Body, point: Vec2, normal: Vec2, enabled: boolean): void;

	/**
	 * Triggers when a `Body` object stops colliding with another object.
	 * Triggers after setting `body.receivingContact = true`.
	 * @param other The other `Body` object that the current `Body` is no longer colliding with.
	 * @param point The point of collision in world coordinates.
	 * @param normal The normal vector of the contact surface in world coordinates.
	*/
	ContactEnd(this: void, other: Body, point: Vec2, normal: Vec2): void;

	/**
	 * Triggered after a Particle node started a stop action and then all the active particles end their lives.
	*/
	Finished(this: void): void;

	/**
	 * Triggers when the layout of the `AlignNode` is updated.
	 * @param width The width of the node.
	 * @param height The height of the node.
	 */
	AlignLayout(this: void, width: number, height: number): void;

	/**
	 * Triggers when an Effekseer effect has ended.
	 * @param handle The handle of the effect that has ended.
	 */
	EffekEnd(this: void, handle: number): void;
}

const enum GlobalEvent {
	AppEvent = "AppEvent",
	AppChange = "AppChange",
	AppWS = "AppWS",
}

export {GlobalEvent as GSlot};

type AppEventType = "Quit" | "LowMemory" | "WillEnterBackground" | "DidEnterBackground" | "WillEnterForeground" | "DidEnterForeground";
type AppSettingName = "Locale" | "Theme" | "FullScreen" | "Position" | "Size";
type AppWSEventType = "Open" | "Close" | "Send" | "Receive";

type GlobalEventHandlerMap = {
	/** Triggers when the application receives an event. */
	AppEvent(this: void, eventType: AppEventType): void;

	/** Triggers when the application window changes a specific setting. */
	AppChange(this: void, settingName: AppSettingName): void;

	/** Triggers when a websocket connection gets an event. */
	AppWS(this: void, eventType: AppWSEventType, msg: string): void;
};

/**
 * Class used for building a hierarchical tree structure of game objects.
 */
class Node extends Object {
	protected constructor();

	/** The order of the node in the parent's children array. */
	order: number;

	/** The rotation angle of the node in degrees. */
	angle: number;

	/** The X-axis rotation angle of the node in degrees. */
	angleX: number;

	/** The Y-axis rotation angle of the node in degrees. */
	angleY: number;

	/** The X-axis scale factor of the node. */
	scaleX: number;

	/** The Y-axis scale factor of the node. */
	scaleY: number;

	/** The Z-axis scale factor of the node. */
	scaleZ: number;

	/** The X-axis position of the node. */
	x: number;

	/** The Y-axis position of the node. */
	y: number;

	/** The Z-axis position of the node. */
	z: number;

	/** The position of the node as a Vec2 object. */
	position: Vec2;

	/** The X-axis skew angle of the node in degrees. */
	skewX: number;

	/** The Y-axis skew angle of the node in degrees. */
	skewY: number;

	/** Whether the node is visible. */
	visible: boolean;

	/** The anchor point of the node as a Vec2 object. */
	anchor: Vec2;

	/** The width of the node. */
	width: number;

	/** The height of the node. */
	height: number;

	/** The size of the node as a Size object. */
	size: Size;

	/** The tag of the node as a string. */
	tag: string;

	/** The opacity of the node, should be 0 to 1.0. */
	opacity: number;

	/** The color of the node as a Color object. */
	color: Color;

	/** The color of the node as a Color3 object. */
	color3: Color3;

	/** Whether to pass the opacity value to child nodes. */
	passOpacity: boolean;

	/** Whether to pass the color value to child nodes. */
	passColor3: boolean;

	/** The target node acts as a parent node for transforming this node. */
	transformTarget?: Node;

	/** The scheduler used for scheduling update and action callbacks. */
	scheduler: Scheduler;

	/** Whether the node has children. */
	readonly hasChildren: boolean;

	/** The children of the node as an Array object, could be undefined. */
	readonly children?: Array;

	/** The parent node of the node, could be undefined. */
	readonly parent?: Node;

	/** Whether the node is currently running in a scene tree. */
	readonly running: boolean;

	/** Whether the node is currently scheduling a function or a coroutine for updates. */
	readonly scheduled: boolean;

	/** The number of actions currently running on the node. */
	readonly actionCount: number;

	/** Additional data stored on the node as a Dictionary object. */
	readonly data: Dictionary;

	/** Whether touch events are enabled on the node. */
	touchEnabled: boolean;

	/** Whether the node should swallow touch events. */
	swallowTouches: boolean;

	/** Whether the node should swallow mouse wheel events. */
	swallowMouseWheel: boolean;

	/** Whether keyboard events are enabled on the node. */
	keyboardEnabled: boolean;

	/** Whether controller events are enabled on the node. */
	controllerEnabled: boolean;

	/** Whether to group the node's rendering with all its recursive children. */
	renderGroup: boolean;

	/** Whether to show debug information for the node. */
	showDebug: boolean;

	/** The rendering order number for group rendering. Nodes with lower rendering orders are rendered earlier. */
	renderOrder: number;

	/**
	 * Adds a child node to the current node.
	 * @param child The child node to add.
	 * @param order [optional] The drawing order of the child node. Default is 0.
	 * @param tag [optional] The tag of the child node. Default is an empty string.
	 */
	addChild(child: Node, order?: number, tag?: string): void;

	/**
	 * Adds the current node to a parent node.
	 * @param parent The parent node to add the current node to.
	 * @param order [optional] The drawing order of the current node. Default is 0.
	 * @param tag [optional] The tag of the current node. Default is an empty string.
	 * @returns The current node.
	 */
	addTo<T>(this: T, parent: Node, order?: number, tag?: string): T;

	/**
	 * Removes a child node from the current node.
	 * @param child The child node to remove.
	 * @param cleanup [optional] Whether to cleanup the child node. Default is true.
	 */
	removeChild(child: Node, cleanup?: boolean): void;

	/**
	 * Removes a child node from the current node by tag.
	 * @param tag The tag of the child node to remove.
	 * @param cleanup [optional] Whether to cleanup the child node. Default is true.
	 */
	removeChildByTag(tag: string, cleanup?: boolean): void;

	/**
	 * Removes all child nodes from the current node.
	 * @param cleanup [optional] Whether to cleanup the child nodes. Default is true.
	 */
	removeAllChildren(cleanup?: boolean): void;

	/**
	 * Removes the current node from its parent node.
	 * @param cleanup [optional] Whether to cleanup the current node. Default is true.
	 */
	removeFromParent(cleanup?: boolean): void;

	/**
	 * Moves the current node to a new parent node without triggering node events.
	 * @param parent The new parent node to move the current node to.
	 */
	moveToParent(parent: Node): void;

	/**
	 * Cleans up the current node.
	 */
	cleanup(): void;

	/**
	 * Gets a child node by tag.
	 * @param tag The tag of the child node to get.
	 * @returns The child node, or nil if not found.
	 */
	getChildByTag(tag: string): Node | null;

	/**
	 * Schedules a main function to run every frame. Call this function again to replace the previous scheduled main function or coroutine.
	 * @param func The main function to be called every frame. It should take a single argument of type number, which represents the delta time since the last frame, returns true to stop.
	 */
	schedule(func: (this: void, deltaTime: number) => boolean): void;

	/**
	 * Schedules a main coroutine to run. Call this function again to replace the previous scheduled main function or coroutine.
	 * @param job The main coroutine to run, return or yield true to stop.
	 */
	schedule(job: Job): void;

	/**
	 * Unschedules the current node's scheduled main function or coroutine.
	 */
	unschedule(): void;

	/**
	 * Schedules a function that runs in a coroutine once. Call this function to replace the previous scheduled main function or coroutine.
	 * @param func The function to run once.
	 */
	once(func: (this: void) => void): void;

	/**
	 * Schedules a function that runs in a coroutine in a loop. Call this function to replace the previous scheduled main function or coroutine.
	 * @param func The function to run in a loop, returns true to stop.
	 */
	loop(func: (this: void) => boolean): void;

	/**
	 * Converts a point in world space to node space.
	 * @param worldPoint The point to convert.
	 * @returns The converted point.
	 */
	convertToNodeSpace(worldPoint: Vec2): Vec2;

	/**
	 * Converts a point in world space to node space.
	 * @param worldPoint The point to convert.
	 * @param z The z-coordinate of the point.
	 * @returns The converted point and z-coordinate.
	 */
	convertToNodeSpace(worldPoint: Vec2, z: number): LuaMultiReturn<[Vec2, number]>;

	/**
	 * Converts a point from node space to world space.
	 * @param nodePoint The point in node space.
	 * @returns The converted point in world space.
	 */
	convertToWorldSpace(nodePoint: Vec2): Vec2;

	/**
	 * Converts a point from node space to world space.
	 * @param nodePoint The point in node space.
	 * @param z The z coordinate in node space.
	 * @returns The converted point and z coordinate in world space.
	 */
	convertToWorldSpace(nodePoint: Vec2, z: number): LuaMultiReturn<[Vec2, number]>;

	/**
	 * Converts a point from node space to window space.
	 * @param nodePoint The point in node space.
	 * @param callback The callback function to receive the converted point in window space.
	 */
	convertToWindowSpace(nodePoint: Vec2, callback: (this: void, windowPoint: Vec2) => void): void;

	/**
	 * Calls the given function for each child node of this node. The child nodes can not be added or removed during the iteration.
	 * @param func The function to call for each child node. The function should return a boolean value indicating whether to continue the iteration. Return true to stop iteration.
	 * @returns False if all children have been visited, true if the iteration was interrupted by the function.
	 */
	eachChild(func: (this: void, child: Node) => boolean): boolean;

	/**
	 * Traverses the node hierarchy starting from this node and calls the given function for each visited node. The nodes without `TraverseEnabled` flag are not visited. The nodes can not be added or removed during the iteration.
	 * @param func The function to call for each visited node. The function should return a boolean value indicating whether to continue the traversal. Return true to stop iteration.
	 * @returns False if all nodes have been visited, true if the traversal was interrupted by the function.
	 */
	traverse(func: (this: void, node: Node) => boolean): boolean;

	/**
	 * Traverses the entire node hierarchy starting from this node and calls the given function for each visited node. The nodes without `TraverseEnabled` flag are also visited. The nodes can not be added or removed during the iteration.
	 * @param func The function to call for each visited node. The function should return a boolean value indicating whether to continue the traversal.
	 * @returns True if all nodes have been visited, false if the traversal was interrupted by the function.
	 */
	traverseAll(func: (this: void, node: Node) => boolean): boolean;

	/**
	 * Runs the given action on this node.
	 * @param action The action to run.
	 * @param loop [optional] Whether to loop the action. Defaults to false.
	 * @returns The duration of the newly running action in seconds.
	 */
	runAction(action: Action, loop?: boolean): number;

	/**
	 * Runs an action defined by the given action definition on this node.
	 * @param actionDef The action definition to run.
	 * @param loop [optional] Whether to loop the action. Defaults to false.
	 * @returns The duration of the newly running action in seconds.
	 */
	runAction(actionDef: ActionDef, loop?: boolean): number;

	/**
	 * Stops all actions running on this node.
	 */
	stopAllActions(): void;

	/**
	 * Runs the given action immediately without adding it to the action queue.
	 * @param action The action to run.
	 * @param loop [optional] Whether to loop the action. Defaults to false.
	 * @returns The duration of the newly running action.
	 */
	perform(action: Action, loop?: boolean): number;

	/**
	 * Runs an action defined by the given action definition right after clearing all the previous running actions.
	 * @param actionDef The action definition to run.
	 * @param loop [optional] Whether to loop the action. Defaults to false.
	 * @returns The duration of the newly running action.
	 */
	perform(actionDef: ActionDef, loop?: boolean): number;

	/**
	 * Stops the given action running on this node.
	 * @param action The action to stop.
	 */
	stopAction(action: Action): void;

	/**
	 * Vertically aligns all child nodes of this node.
	 * @param padding [optional] The padding between child nodes. Defaults to 10.
	 * @returns The size of the aligned child nodes.
	 */
	alignItemsVertically(padding?: number): Size;

	/**
	 * Vertically aligns all child nodes within the node using the given size and padding.
	 * @param size The size to use for alignment.
	 * @param padding [optional] The amount of padding to use between each child node (default is 10).
	 * @returns The size of the node after alignment.
	 */
	alignItemsVertically(size: Size, padding?: number): Size;

	/**
	 * Horizontally aligns all child nodes within the node using the given padding.
	 * @param padding [optional] The amount of padding to use between each child node (default is 10).
	 * @returns The size of the node after alignment.
	 */
	alignItemsHorizontally(padding?: number): Size;

	/**
	 * Horizontally aligns all child nodes within the node using the given size and padding.
	 * @param size The size to hint for alignment.
	 * @param padding [optional] The amount of padding to use between each child node (default is 10).
	 * @returns The size of the node after alignment.
	 */
	alignItemsHorizontally(size: Size, padding?: number): Size;

	/**
	 * Aligns all child nodes within the node using the given size and padding.
	 * @param padding [optional] The amount of padding to use between each child node (default is 10).
	 * @returns The size of the node after alignment.
	 */
	alignItems(padding?: number): Size;

	/**
	 * Aligns all child nodes within the node using the given size and padding.
	 * @param size The size to use for alignment.
	 * @param padding [optional] The amount of padding to use between each child node (default is 10).
	 * @returns The size of the node after alignment.
	 */
	alignItems(size: Size, padding?: number): Size;

	/**
	 * Moves and changes child nodes' visibility based on their position in parent's area.
	 * @param delta The distance to move its children.
	 */
	moveAndCullItems(delta: Vec2): void;

	/**
	 * Attaches the input method editor (IME) to the node.
	 * Makes node receiving Slot.AttachIME，Slot.DetachIME，Slot.TextInput，Slot.TextEditing events.
	 */
	attachIME(): void;

	/**
	 * Detaches the input method editor (IME) from the node.
	 */
	detachIME(): void;

	/**
	 * Gets the global event listener associated with the given event name in this node.
	 * @param eventName The name of the global event.
	 * @returns All the global event listeners associated with the event.
	 */
	gslot(eventName: string): GSlot[];

	/**
	 * Associates the given event handler function with a global event.
	 * @param eventName The name of the global event.
	 * @param handler The handler function to associate with the event.
	 * @returns The global event listener associated with the event in this node.
	 * @example
	 * Register for builtin global events:
	 * ```
	 * const node = Node()
	 * node.gslot(GSlot.AppEvent, (eventType) => {
	 * 	print("Application event: " + eventType);
	 * });
	 * ```
	 */
	gslot<K extends keyof GlobalEventHandlerMap>(eventName: K, handler: GlobalEventHandlerMap[K]): void;

	/**
	 * Associates the given event handler function with a global event.
	 * @param eventName The name of the global event.
	 * @param handler The handler function to associate with the event.
	 * @returns The global event listener associated with the event in this node.
	 */
	gslot(eventName: string, handler: (this: void, ...args: any[]) => void): GSlot;

	/**
	 * Gets the node event listener associated with the given node event name.
	 * @param eventName The name of the node event.
	 * @returns The node event listener associated with the node event.
	 */
	slot(eventName: string): Slot;

	/**
	 * Associates the given handler function with the node event.
	 * @param eventName The name of the node event.
	 * @param handler The handler function to associate with the node event.
	 * Register for builtin node events:
	 * ```
	 * const node = Node()
	 * node.slot(Slot.Cleanup, () => {
	 * 	print("Node is cleaning up!");
	 * });
	 * ```
	 */
	slot<K extends keyof NodeEventHandlerMap>(eventName: K, handler: NodeEventHandlerMap[K]): void;

	/**
	 * Associates the given handler function with the node event.
	 * @param eventName The name of the node event.
	 * @param handler The handler function to associate with the node event.
	 */
	slot(eventName: string, handler: (this: void, ...args: any[]) => void): void;

	/**
	 * Emits a node event with a given event name and arguments.
	 * @param eventName The name of the node event.
	 * @param args The arguments to pass to the node event handler functions.
	 */
	emit(eventName: string, ...args: any[]): void;

	/**
	 * Creates a texture grabber for the specified node.
	 * @returns A Grabber object with gridX == 1 and gridY == 1.
	 */
	grab(): Grabber;

	/**
	 * Creates a texture grabber for the specified node.
	 * @param enabled Passes true to enable the grabber.
	 * @returns A Grabber object with gridX == 1 and gridY == 1 when enabled.
	 */
	grab(enabled: true): Grabber;

	/**
	 * Removes a texture grabber for the specified node.
	 * @param enabled Passes false to disable it.
	 */
	grab(enabled: false): void;

	/**
	 * Creates a texture grabber for the specified node with a specified grid size.
	 * @param gridX The number of horizontal grid cells to divide the grabber into.
	 * @param gridY The number of vertical grid cells to divide the grabber into.
	 * @returns A Grabber object.
	 */
	grab(gridX: number, gridY: number): Grabber;

	/**
	 * Schedules a function to run every frame. Call this function again to schedule multiple functions.
	 * @param func The function to run every frame, returns true to stop.
	 */
	onUpdate(func: (this: void, deltaTime: number) => boolean): void;

	/**
	 * Schedules a coroutine to run every frame. Call this function again to schedule multiple coroutines.
	 * @param job The coroutine to run every frame.
	 */
	onUpdate(job: Job): void;

	/**
	 * Registers a callback for event triggered when the node is entering the rendering phase. The callback is called every frame, and ensures that its call order is consistent with the rendering order of the scene tree, such as rendering child nodes after their parent nodes. Recommended for calling vector drawing functions.
	 * @param func The function to call when the node is entering the rendering phase, returns true to stop.
	 */
	onRender(func: (this: void, deltaTime: number) => boolean): void;

	/**
	 * Registers a callback for the event triggered when an action is finished.
	 * @param callback The callback function to register.
	 */
	onActionEnd(callback: (this: void, action: Action, target: Node) => void): void;

	/**
	 * Registers a callback for the event triggered before the TapBegan slot and can be used to filter out certain taps.
	 * This function also sets `node.touchEnabled = true`.
	 * @param callback The callback function to register.
	 */
	onTapFilter(callback: (this: void, touch: Touch) => void): void;

	/**
	 * Registers a callback for the event triggered when a tap is detected.
	 * This function also sets `node.touchEnabled = true`.
	 * @param callback The callback function to register.
	 */
	onTapBegan(callback: (this: void, touch: Touch) => void): void;

	/**
	 * Registers a callback for the event triggered when a tap ends.
	 * This function also sets `node.touchEnabled = true`.
	 * @param callback The callback function to register.
	 */
	onTapEnded(callback: (this: void, touch: Touch) => void): void;

	/**
	 * Registers a callback for the event triggered when a tap is detected and has ended.
	 * This function also sets `node.touchEnabled = true`.
	 * @param callback The callback function to register.
	 */
	onTapped(callback: (this: void, touch: Touch) => void): void;

	/**
	 * Registers a callback for the event triggered when a tap moves.
	 * This function also sets `node.touchEnabled = true`.
	 * @param callback The callback function to register.
	 */
	onTapMoved(callback: (this: void, touch: Touch) => void): void;

	/**
	 * Registers a callback for the event triggered when the mouse wheel is scrolled.
	 * This function also sets `node.touchEnabled = true`.
	 * @param callback The callback function to register.
	 */
	onMouseWheel(callback: (this: void, delta: Vec2) => void): void;

	/**
	 * Registers a callback for the event triggered when a gesture is recognized.
	 * This function also sets `node.touchEnabled = true`.
	 * @param callback The callback function to register.
	 */
	onGesture(callback: (this: void, center: Vec2, numFingers: number, deltaDist: number, deltaAngle: number) => void): void;

	/**
	 * Registers a callback for the event triggered when a node is added to the scene graph.
	 * @param callback The callback function to register.
	 */
	onEnter(callback: (this: void) => void): void;

	/**
	 * Registers a callback for the event triggered when a node is removed from the scene graph.
	 * @param callback The callback function to register.
	 */
	onExit(callback: (this: void) => void): void;

	/**
	 * Registers a callback for the event triggered when a node is cleaned up.
	 * @param callback The callback function to register.
	 */
	onCleanup(callback: (this: void) => void): void;

	/**
	 * Registers a callback for the event triggered when a key is pressed down.
	 * This function also sets `node.keyboardEnabled = true`.
	 * @param callback The callback function to register.
	 */
	onKeyDown(callback: (this: void, keyName: KeyName) => void): void;

	/**
	 * Registers a callback for the event triggered when a key is released.
	 * This function also sets `node.keyboardEnabled = true`.
	 * @param callback The callback function to register.
	 */
	onKeyUp(callback: (this: void, keyName: KeyName) => void): void;

	/**
	 * Registers a callback for the event triggered when a key is being pressed.
	 * This function also sets `node.keyboardEnabled = true`.
	 * @param callback The callback function to register.
	 */
	onKeyPressed(callback: (this: void, keyName: KeyName) => void): void;

	/**
	 * Registers a callback for the event triggered when the input method editor (IME) is attached.
	 * @param callback The callback function to register.
	 */
	onAttachIME(callback: (this: void) => void): void;

	/**
	 * Registers a callback for the event triggered when the input method editor (IME) is detached.
	 * @param callback The callback function to register.
	 */
	onDetachIME(callback: (this: void) => void): void;

	/**
	 * Registers a callback for the event triggered when text input is received.
	 * @param callback The callback function to register.
	 */
	onTextInput(callback: (this: void, text: string) => void): void;

	/**
	 * Registers a callback for the event triggered when text is being edited.
	 * @param callback The callback function to register.
	 */
	onTextEditing(callback: (this: void, text: string, startPos: number) => void): void;

	/**
	 * Registers a callback for the event triggered when a button is pressed down on a controller.
	 * This function also sets `node.controllerEnabled = true`.
	 * @param callback The callback function to register.
	 */
	onButtonDown(callback: (this: void, controllerId: number, buttonName: ButtonName) => void): void;

	/**
	 * Registers a callback for the event triggered when a button is released on a controller.
	 * This function also sets `node.controllerEnabled = true`.
	 * @param callback The callback function to register.
	 */
	onButtonUp(callback: (this: void, controllerId: number, buttonName: ButtonName) => void): void;

	/**
	 * Registers a callback for the event triggered when a button is pressed on a controller.
	 * This function also sets `node.controllerEnabled = true`.
	 * @param callback The callback function to register.
	 */
	onButtonPressed(callback: (this: void, controllerId: number, buttonName: ButtonName) => void): void;

	/**
	 * Registers a callback for the event triggered when an axis is moved on a controller.
	 * This function also sets `node.controllerEnabled = true`.
	 * @param callback The callback function to register.
	 */
	onAxis(callback: (this: void, controllerId: number, axisName: AxisName, value: number) => void): void;

	/**
	 * Registers a callback for the application event.
	 * @param callback The callback function to register.
	 */
	onAppEvent(callback: (this: void, eventType: AppEventType) => void): void;

	/**
	 * Registers a callback for the application setting change event.
	 * @param callback The callback function to register.
	 */
	onAppChange(callback: (this: void, settingName: AppSettingName) => void): void;

	/**
	 * Registers a callback for the application websocket event.
	 * @param callback The callback function to register.
	 */
	onAppWS(callback: (this: void, eventType: AppWSEventType, msg: string) => void): void;
}

export {Node as NodeType};
export namespace Node {
	export type Type = Node;
}

/**
 * A class object for the `Node` class.
 */
interface NodeClass {
	/**
	 * Creates a new instance of the `Node` class.
	 *
	 * @example
	 * ```
	 * import {Node} from 'Dora';
	 * const node = Node();
	 * ```
	 * @returns A new instance of the `Node` class.
	 */
	(this: void): Node;
}

const nodeClass: NodeClass;
export {nodeClass as Node};

/**
 * A buffer of string for the use of ImGui widget.
 */
class Buffer extends Object {
	private constructor();

	/** The size of the buffer. */
	readonly size: number;

	/** Getting or setting the text stored in the buffer. */
	text: string;

	/**
	 * Changing the size of the buffer.
	 * @param size The new size of the buffer.
	 */
	resize(size: number): void;

	/** Setting all bytes in the buffer to zero. */
	zeroMemory(): void;
}

export namespace Buffer {
	export type Type = Buffer;
}

/**
* A class for creating Buffer objects.
*/
interface BufferClass {
	/**
	 * Creates a new buffer instance.
	 * @param size The size of the buffer to create.
	 * @returns A new instance of the "Buffer" type with the given size.
	 */
	(this: void, size: number): Buffer;
}

const bufferClass: BufferClass;
export {bufferClass as Buffer};

/**
 * A Node that can clip its children based on the alpha values of its stencil.
 */
class ClipNode extends Node {
	private constructor();

	/**
	 * The stencil Node that defines the clipping shape.
	 */
	stencil: Node | null;

	/**
	 * The minimum alpha threshold for a pixel to be visible. Value ranges from 0 to 1.
	 */
	alphaThreshold: number;

	/**
	 * Whether to invert the clipping area.
	 */
	inverted: boolean;
}

export namespace ClipNode {
	export type Type = ClipNode;
}

/**
* A class for creating ClipNode objects.
*/
interface ClipNodeClass {
	/**
	 * Creates a new ClipNode object.
	 * @param stencil The stencil Node that defines the clipping shape. Defaults to undefined.
	 * @returns A new ClipNode object.
	 */
	(this: void, stencil?: Node): ClipNode;
}

const clipNodeClass: ClipNodeClass;
export {clipNodeClass as ClipNode};

/**
 * The `Content` object manages file searching, loading, and other operations related to resources.
 *
 * @example
 * ```
 * import {Content} from "Dora";
 * const text = Content.load("filename.txt");
 * ```
 */
class Content {
	private constructor();

	/** An array of directories to search for resource files. */
	searchPaths: string[];

	/** The path to the directory containing read-only resources. Can only be altered by the user on platform Windows, MacOS and Linux. */
	assetPath: string;

	/** The path to the directory where files can be written. Can only be altered by the user on platform Windows, MacOS and Linux. Default is the same as the `appPath`. */
	writablePath: string;

	/** The path to the directory for the application storage. */
	appPath: string;

	/**
	 * Loads the content of the file with the specified filename.
	 * @param filename The name of the file to load.
	 * @returns The content of the loaded file.
	 */
	load(filename: string): string;

	/**
	 * Loads the content of an Excel file with the specified filename and optional sheet names.
	 * @param filename The name of the Excel file to load.
	 * @param sheetNames An array of strings representing the names of the sheets to load. If not provided, all sheets will be loaded.
	 * @returns A table containing the data in the Excel file. The keys are the sheet names and the values are tables containing the rows and columns of the sheet.
	 */
	loadExcel(filename: string, sheetNames?: string[]): {
		[sheetName: string]: (/* column */ string | number)[][] | undefined
	} | null;

	/**
	 * Saves the specified content to a file with the specified filename.
	 * @param filename The name of the file to save.
	 * @param content The content to save to the file.
	 * @returns `true` if the content saves to file successfully, `false` otherwise.
	 */
	save(filename: string, content: string): boolean;

	/**
	 * Checks if a file with the specified filename exists.
	 * @param filename The name of the file to check.
	 * @returns `true` if the file exists, `false` otherwise.
	 */
	exist(filename: string): boolean;

	/**
	 * Creates a new directory with the specified path.
	 * @param path The path of the directory to create.
	 * @returns `true` if the directory was created, `false` otherwise.
	 */
	mkdir(path: string): boolean;

	/**
	 * Checks if the specified path is a directory.
	 * @param path The path to check.
	 * @returns `true` if the path is a directory, `false` otherwise.
	 */
	isdir(path: string): boolean;

	/**
	 * Removes the file or directory with the specified path.
	 * @param path The path of the file or directory to remove.
	 * @returns `true` if the file or directory was removed, `false` otherwise.
	 */
	remove(path: string): boolean;

	/**
	 * Copies the file or directory in the specified path to target path.
	 * @param srcPath The path of the file or directory to copy.
	 * @param dstPath The path to copy files to.
	 * @returns `true` if the file or directory was copied to target path, `false` otherwise.
	 */
	copy(srcPath: string, dstPath: string): boolean;

	/**
	 * Moves the file or directory in the specified path to target path.
	 * @param srcPath The path of the file or directory to move.
	 * @param dstPath The path to move files to.
	 * @returns `true` if the file or directory was moved to target path, `false` otherwise.
	 */
	move(srcPath: string, dstPath: string): boolean;

	/**
	 * Checks if the specified path is an absolute path.
	 * @param path The path to check.
	 * @returns `true` if the path is an absolute path, `false` otherwise.
	 */
	isAbsolutePath(path: string): boolean;

	/**
	 * Gets the full path of a file with the specified filename.
	 * @param filename The name of the file to get the full path of.
	 * @returns The full path of the file.
	 */
	getFullPath(filename: string): string;

	/**
	 * Inserts a search path at the specified index.
	 * @param index The index at which to insert the search path.
	 * @param path The search path to insert.
	 */
	insertSearchPath(index: number, path: string): void;

	/**
	 * Adds a new search path to the end of the list.
	 * @param path The search path to add.
	 */
	addSearchPath(path: string): void;

	/**
	 * Removes the specified search path from the list.
	 * @param path The search path to remove.
	 */
	removeSearchPath(path: string): void;

	/**
	 * Asynchronously loads the content of the file with the specified filename.
	 * @param filename The name of the file to load.
	 * @returns The content of the loaded file.
	 */
	loadAsync(filename: string): string;

	/**
	 * Asynchronously loads the content of an Excel file with the specified filename and optional sheet names.
	 * @param filename The name of the Excel file to load.
	 * @param sheetNames An array of strings representing the names of the sheets to load. If not provided, all sheets will be loaded.
	 * @returns A table containing the data in the Excel file. The keys are the sheet names and the values are tables containing the rows and columns of the sheet.
	 */
	loadExcelAsync(filename: string, sheetNames?: string[]): {
		[sheetName: string]: (/* column */ string | number)[][]
	} | null;

	/**
	 * Asynchronously saves the specified content to a file with the specified filename.
	 * @param filename The name of the file to save.
	 * @param content The content to save to the file.
	 * @returns `true` if the content was saved successfully, `false` otherwise.
	 */
	saveAsync(filename: string, content: string): boolean;

	/**
	 * Asynchronously copies a file or a folder from the source path to the destination path.
	 * @param src The path of the file or folder to copy.
	 * @param dst The destination path of the copied files.
	 * @returns `true` if the file or folder was copied successfully, `false` otherwise.
	 */
	copyAsync(src: string, dst: string): boolean;

	/**
	 * Asynchronously compresses the specified folder to a ZIP archive with the specified filename.
	 * @param folderPath The path of the folder to compress, should be under the asset writable path.
	 * @param zipFile The name of the ZIP archive to create.
	 * @param filter A function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.
	 * @returns `true` if the folder was compressed successfully, `false` otherwise.
	 */
	zipAsync(folderPath: string, zipFile: string, filter?: (this: void, filename: string) => boolean): boolean;

	/**
	 * Asynchronously decompresses a ZIP archive to the specified folder.
	 * @param zipFile The name of the ZIP archive to decompress, should be a file under the asset writable path.
	 * @param folderPath The path of the folder to decompress to, should be under the asset writable path.
	 * @param filter A function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.
	 * @returns `true` if the folder was decompressed successfully, `false` otherwise.
	 */
	unzipAsync(zipFile: string, folderPath: string, filter?: (this: void, filename: string) => boolean): boolean;

	/**
	 * Gets the names of all subdirectories in the specified directory.
	 * @param path The path of the directory to search.
	 * @returns An array of the names of all subdirectories in the specified directory.
	 */
	getDirs(path: string): string[];

	/**
	 * Gets the names of all files in the specified directory.
	 * @param path The path of the directory to search.
	 * @returns An array of the names of all files in the specified directory.
	 */
	getFiles(path: string): string[];

	/**
	 * Gets the names of all files in the specified directory and its subdirectories.
	 * @param path The path of the directory to search.
	 * @returns An array of the names of all files in the specified directory and its subdirectories.
	 */
	getAllFiles(path: string): string[];

	/**
	 * Clears the search path cache of the map of relative paths to full paths.
	 */
	clearPathCache(): void;
}

const content: Content;
export {content as Content};

/**
 * Logs a message to the console.
 * @param level The message logging level.
 * @param msg The message to be logged.
 */
export function Log(this: void, level: "Info" | "Warn" | "Error", msg: string): void;

/**
 * Type definition for a database column.
 * The boolean type is only used for representing the database NULL value with the boolean false value.
 */
type DBColumn = number | string | boolean;

/**
 * Type definition for a database row.
 */
type DBRow = DBColumn[];

/**
 * Type definition for an SQL query.
 * Can be SQL string or a pair of SQL string and an array of parameters.
 */
export type SQL = string | [string, DBRow[]];

/**
 * An interface that represents a database.
 */
interface DB {
	/**
	 * Checks whether an attached database exists.
	 * @param dbName The name of the table to check.
	 * @returns Whether the attached database exists or not.
	 */
	existDB(dbName: string): boolean;

	/**
	 * Checks whether a table exists in the database.
	 * @param tableName The name of the table to check.
	 * @param schema [optional] The name of the schema to check in.
	 * @returns Whether the table exists or not.
	 */
	exist(tableName: string, schema?: string): boolean;

	/**
	 * Executes a list of SQL statements as a single transaction.
	 * @param sqls A list of SQL statements to execute.
	 * @returns Whether the transaction was successful or not.
	 */
	transaction(sqls: SQL[]): boolean;

	/**
	 * Executes a list of SQL statements as a single transaction asynchronously.
	 * @param sqls A list of SQL statements to execute.
	 * @returns Whether the transaction was successful or not.
	 */
	transactionAsync(sqls: SQL[]): boolean;

	/**
	 * Executes an SQL query and returns the results as a list of rows.
	 * @param sql The SQL statement to execute.
	 * @param args [optional] A list of values to substitute into the SQL statement.
	 * @param withColumn [optional] Whether to include column names in the result (default false).
	 * @returns A list of rows returned by the query, or null if the query failed.
	 */
	query(sql: string, args?: DBRow, withColumn?: boolean): DBRow[] | null;

	/**
	 * Executes an SQL query and returns the results as a list of rows.
	 * @param sql The SQL statement to execute.
	 * @param withColumn [optional] Whether to include column names in the result (default false).
	 * @returns A list of rows returned by the query, or null if the query failed.
	 */
	query(sql: string, withColumn?: boolean): DBRow[] | null;

	/**
	 * Inserts a row of data into a table within a transaction.
	 * @param tableName The name of the table to insert into.
	 * @param values The values to insert into the table.
	 * @returns Whether the insertion was successful or not.
	 */
	insert(tableName: string, values: DBRow[]): boolean;

	/**
	 * Executes an SQL statement and returns the number of rows affected.
	 * @param sql The SQL statement to execute.
	 * @returns The number of rows affected by the statement, or -1 if the statement failed.
	 */
	exec(sql: string): number;

	/**
	 * Executes an SQL statement and returns the number of rows affected.
	 * @param sql The SQL statement to execute.
	 * @param values A list of values to substitute into the SQL statement.
	 * @returns The number of rows affected by the statement, or -1 if the statement failed.
	 */
	exec(sql: string, values: DBRow): number;

	/**
	 * Executes an SQL statement with list of values and returns the number of rows affected within a transaction.
	 * @param sql The SQL statement to execute.
	 * @param values A list of lists of values to substitute into the SQL statement.
	 * @returns The number of rows affected by the statement, or -1 if the statement failed.
	 */
	exec(sql: string, values: DBRow[]): number;

	/**
	 * Inserts a row of data into a table within a transaction asynchronously.
	 * @param tableName The name of the table to insert into.
	 * @param values The values to insert into the table.
	 * @returns Whether the insert was successful or not.
	 */
	insertAsync(tableName: string, values: DBRow[]): boolean;

	/**
	 * Inserts data from an Excel file into a table within a transaction asynchronously.
	 * @param tableSheets The names of the tables to insert into.
	 * @param excelFile The path to the Excel file containing the data.
	 * @param startRow The row number to start inserting data from. The row number starts with 1.
	 * @returns Whether the insert was successful or not.
	 */
	insertAsync(tableSheets: string[], excelFile: string, startRow: number): boolean;

	/**
	 * Inserts data from an Excel file into a table within a transaction asynchronously.
	 * @param tableSheets A list of table names and corresponding sheet names to insert into.
	 * @param excelFile The path to the Excel file containing the data.
	 * @param startRow The row number to start inserting data from. The row number starts with 1.
	 * @returns Whether the insert was successful or not.
	 */
	insertAsync(tableSheets: [string, string][], excelFile: string, startRow: number): boolean;

	/**
	 * Executes an SQL query asynchronously and returns the results as a list of rows.
	 * @param sql The SQL statement to execute.
	 * @param args [optional] A list of values to substitute into the SQL statement.
	 * @param withColumn [optional] Whether to include column names in the result (default false).
	 * @returns A list of rows returned by the query, or null if the query failed.
	 */
	queryAsync(sql: string, args?: DBRow, withColumn?: boolean): DBRow[] | null;

	/**
	 * Executes an SQL query asynchronously and returns the results as a list of rows.
	 * @param sql The SQL statement to execute.
	 * @param withColumn [optional] Whether to include column names in the result (default false).
	 * @returns A list of rows returned by the query, or null if the query failed.
	 */
	queryAsync(sql: string, withColumn?: boolean): DBRow[] | null;

	/**
	 * Executes an SQL statement with a list of values within a transaction asynchronously and returns the number of rows affected.
	 * @param sql The SQL statement to execute.
	 * @param values A list of values to substitute into the SQL statement.
	 * @returns The number of rows affected by the statement, or -1 if the statement failed.
	 */
	execAsync(sql: string, values: DBRow[]): number;

	/**
	 * Executes an SQL statement asynchronously and returns the number of rows affected.
	 * @param sql The SQL statement to execute.
	 * @returns The number of rows affected by the statement, or -1 if the statement failed.
	 */
	execAsync(sql: string): number;
}

const db: DB;
export {db as DB};

/**
 * A singleton class that manages the game scene trees and provides access to root scene nodes for different game uses.
 *
 * @example
 * ```
 * import {Director} from "Dora";
 * Director.entry.addChild(node);
 * ```
 */
class Director {
	private constructor();

	/**
	 * The background color for the game world.
	 */
	clearColor: Color;

	/**
	 * Provides access to the game scheduler, which is used for scheduling tasks like animations and gameplay events.
	 */
	scheduler: Scheduler;

	/**
	 * The root node for 2D user interface elements like buttons and labels.
	 */
	readonly ui: Node;

	/**
	 * The root node for 3D user interface elements with 3D projection effect.
	 */
	readonly ui3D: Node;

	/**
	 * The root node for the starting point of a game.
	 */
	readonly entry: Node;

	/**
	 * The root node for post-rendering scene tree.
	 */
	readonly postNode: Node;

	/**
	 * Provides access to the system scheduler, which is used for low-level system tasks. Should not put any game logic in it.
	 */
	readonly systemScheduler: Scheduler;

	/**
	 * Provides access to the scheduler used for processing post game logic.
	 */
	readonly postScheduler: Scheduler;

	/**
	 * The current active camera in Director's camera stack.
	 */
	readonly currentCamera: Camera;

	/**
	 * Whether to enable frustum culling.
	 */
	frustumCulling: boolean;

	/**
	 * The flag to enable or disable sending collected statistics via built-in Web Socket server. For Web IDE use only.
	 */
	profilerSending: boolean;

	/**
	 * Adds a new camera to Director's camera stack and sets it to the current camera.
	 * @param camera The camera to add.
	 */
	pushCamera(camera: Camera): void;

	/**
	 * Removes the current camera from Director's camera stack.
	 */
	popCamera(): void;

	/**
	 * Removes a specified camera from Director's camera stack.
	 * @param camera The camera to remove.
	 * @returns True if the camera was removed, false otherwise.
	 */
	removeCamera(camera: Camera): boolean;

	/**
	 * Removes all cameras from Director's camera stack.
	 */
	clearCamera(): void;

	/**
	 * Cleans up all resources managed by the Director, including scene trees and cameras.
	 */
	cleanup(): void;
}

const director: Director;
export {director as Director};

/**
 * A base class for an animation model system.
 */
class Playable extends Node {
	protected constructor();

	/**
	 * The look of the animation.
	 */
	look: string;

	/**
	 * The play speed of the animation.
	 */
	speed: number;

	/**
	 * The recovery time of the animation, in seconds.
	 * Used for doing transitions from one animation to another animation.
	 */
	recovery: number;

	/**
	 * Whether the animation is flipped horizontally.
	 */
	fliped: boolean;

	/**
	 * The current playing animation name.
	 */
	readonly current: string;

	/**
	 * The last completed animation name.
	 */
	readonly lastCompleted: string;

	/**
	 * Get a key point on the animation model by its name.
	 * In the Model animation system, key points are specific points set on the model. In DragonBone, key points are the positions of the armature. In Spine2D, key points are the positions of the point attachments.
	 * @param name The name of the key point to get.
	 * @returns The key point value as a Vec2.
	 */
	getKey(name: string): Vec2;

	/**
	 * Plays an animation from the model.
	 * @param name The name of the animation to play.
	 * @param loop Whether to loop the animation or not (default is false).
	 * @returns The duration of the animation in seconds.
	 */
	play(name: string, loop?: boolean): number;

	/**
	 * Stops the currently playing animation.
	 */
	stop(): void;

	/**
	 * Attaches a child node to a slot on the animation model.
	 * @param name The name of the slot to set.
	 * @param item The node to set the slot to.
	 */
	setSlot(name: string, item: Node | null): void;

	/**
	 * Gets the child node attached to the animation model.
	 * @param name The name of the slot to get.
	 * @returns The node in the slot, or null if there is no node in the slot.
	 */
	getSlot(name: string): Node | null;

	/**
	 * Registers a callback for the event triggered when an animation is finished.
	 * @param callback The callback function to register.
	 */
	onAnimationEnd(callback: (this: void, name: string, playable: Playable) => void): void;
}

export namespace Playable {
	export type Type = Playable;
}

/**
* A class for creating instances of the 'Playable' object.
*/
interface PlayableClass {
	/**
	 * Creates a new instance of 'Playable' from the specified animation file.
	 * @param filename The filename of the animation file to load.
	 * Supports DragonBone, Spine2D, and Dora Model files.
	 * Should be one of the formats below:
	 *  "model:" + modelFile
	 *  "spine:" + spineStr
	 *  "bone:" + dragonBoneStr
	 * @returns a new instance of 'Playable'.
	 */
	(this: void, filename: string): Playable;
}

const playableClass: PlayableClass;
export {playableClass as Playable};

/**
 * An implementation of the 'Playable' class using the DragonBones animation system.
 */
class DragonBone extends Playable {
	private constructor();

	/**
	 * Whether to show debug graphics.
	 */
	showDebug: boolean;

	/**
	 * Whether hit testing is enabled.
	 */
	hitTestEnabled: boolean;

	/**
	 * Checks if a point is inside the boundaries of the instance and returns the name of the bone or slot at that point, or undefined if no bone or slot is found.
	 * @param x The x-coordinate of the point to check.
	 * @param y The y-coordinate of the point to check.
	 * @returns The name of the bone or slot at the point, or undefined if no bone or slot is found.
	 */
	containsPoint(x: number, y: number): string | undefined;

	/**
	 * Checks if a line segment intersects the boundaries of the instance and returns the name of the bone or slot at the intersection point, or undefined if no bone or slot is found.
	 * @param x1 The x-coordinate of the start point of the line segment.
	 * @param y1 The y-coordinate of the start point of the line segment.
	 * @param x2 The x-coordinate of the end point of the line segment.
	 * @param y2 The y-coordinate of the end point of the line segment.
	 * @returns The name of the bone or slot at the intersection point, or undefined if no bone or slot is found.
	 */
	intersectsSegment(x1: number, y1: number, x2: number, y2: number): string | undefined;
}

export namespace DragonBone {
	export type Type = DragonBone;
}

/**
* A class for creating instances of the 'DragonBone' object.
*/
interface DragonBoneClass {
	/**
	 * Returns a list of available looks for the specified DragonBone file string.
	 * @param boneStr The DragonBone file string to get the looks for.
	 * @returns A list of strings representing the available looks.
	 */
	getLooks(boneStr: string): string[];

	/**
	 * Returns a list of available animations for the specified DragonBone file string.
	 * @param boneStr The DragonBone file string to get the animations for.
	 * @returns A list of strings representing the available animations.
	 */
	getAnimations(boneStr: string): string[];

	/**
	 * Creates a new instance of 'DragonBone' using the specified bone string.
	 * @param boneStr The DragonBone file string for the new instance.
	 * A DragonBone file string can be a file path with the target file extention like "DragonBone/item" or file paths with all the related files like "DragonBone/item_ske.json|DragonBone/item_tex.json".
	 * And the an armature name can be added following a seperator of ';'. like "DragonBone/item;mainArmature" or "DragonBone/item_ske.json|DragonBone/item_tex.json;mainArmature".
	 * @returns A new instance of 'DragonBone'.
	 */
	(this: void, boneStr: string): DragonBone | null;

	/**
	 * Creates a new instance of 'DragonBone' using the specified bone file and atlas file. This function only loads the first armature.
	 * @param boneFile The filename of the bone file to load.
	 * @param atlasFile The filename of the atlas file to load.
	 * @returns A new instance of 'DragonBone' with the specified bone file and atlas file.
	 */
	(this: void, boneFile: string, atlasFile: string): DragonBone | null;
}

const dragonBoneClass: DragonBoneClass;
export {dragonBoneClass as DragonBone};

/**
 * An implementation of an animation system using the Spine engine.
 */
class Spine extends Playable {
	private constructor();

	/** Whether to show debug graphics. */
	showDebug: boolean;

	/** Whether hit testing is enabled. */
	hitTestEnabled: boolean;

	/**
	 * Sets the rotation of a bone in the Spine skeleton.
	 * @param name The name of the bone to rotate.
	 * @param rotation The amount to rotate the bone, in degrees.
	 * @returns Whether the rotation was successfully set or not.
	 */
	setBoneRotation(name: string, rotation: number): boolean;

	/**
	 * Checks if a point in space is inside the boundaries of the Spine skeleton.
	 * @param x The x-coordinate of the point to check.
	 * @param y The y-coordinate of the point to check.
	 * @returns The name of the bone at the point, or null if there is no bone at the point.
	 */
	containsPoint(x: number, y: number): string | null;

	/**
	 * Checks if a line segment intersects the boundaries of the instance and returns the name of the bone or slot at the intersection point, or null if no bone or slot is found.
	 * @param x1 The x-coordinate of the start point of the line segment.
	 * @param y1 The y-coordinate of the start point of the line segment.
	 * @param x2 The x-coordinate of the end point of the line segment.
	 * @param y2 The y-coordinate of the end point of the line segment.
	 * @returns The name of the bone or slot at the intersection point, or null if no bone or slot is found.
	 */
	intersectsSegment(x1: number, y1: number, x2: number, y2: number): string | null;
}

export namespace Spine {
	export type Type = Spine;
}

/**
* A class for creating instances of the 'Spine' object.
*/
interface SpineClass {
	/**
	 * Returns a list of available looks for the specified Spine2D file string.
	 * @param spineStr The Spine2D file string to get the looks for.
	 * @returns A list of strings representing the available looks.
	 */
	getLooks(spineStr: string): string[];

	/**
	 * Returns a list of available animations for the specified Spine2D file string.
	 * @param spineStr The Spine2D file string to get the animations for.
	 * @returns A list of strings representing the available animations.
	 */
	getAnimations(spineStr: string): string[];

	/**
	 * Creates a new instance of 'Spine' using the specified Spine string.
	 * @param spineStr The Spine file string for the new instance.
	 * A Spine file string can be a file path with the target file extention like "Spine/item" or file paths with all the related files like "Spine/item.skel|Spine/item.atlas" or "Spine/item.json|Spine/item.atlas".
	 * @returns A new instance of 'Spine'.
	 */
	(this: void, spineStr: string): Spine | null;

	/**
	 * Creates a new instance of 'Spine' using the specified skeleton file and atlas file.
	 * @param skelFile The filename of the skeleton file to load.
	 * @param atlasFile The filename of the atlas file to load.
	 * @returns A new instance of 'Spine' with the specified skeleton file and atlas file.
	 */
	(this: void, skelFile: string, atlasFile: string): Spine | null;
}

const spineClass: SpineClass;
export {spineClass as Spine};

/**
 * Another implementation of the 'Playable' class.
 */
class Model extends Playable {
	protected constructor();

	/**
	 * Whether the animation model will be played in reverse.
	 */
	reversed: boolean;

	/**
	 * The duration of the current animation.
	 */
	readonly duration: number;

	/**
	 * Whether the animation model is currently playing.
	 */
	readonly playing: boolean;

	/**
	 * Whether the animation model is currently paused.
	 */
	readonly paused: boolean;

	/**
	 * Check if an animation exists in the model.
	 * @param name The name of the animation to check.
	 * @returns Whether the animation exists in the model or not.
	 */
	hasAnimation(name: string): boolean;

	/**
	 * Pauses the currently playing animation.
	 */
	pause(): void;

	/**
	 * Resumes the currently paused animation, or plays a new animation if specified.
	 * @param name [optional] The name of the animation to play.
	 * @param loop [optional] Whether to loop the animation or not (default is false).
	 */
	resume(name?: string, loop?: boolean): void;

	/**
	 * Resets the current animation to its initial state.
	 */
	reset(): void;

	/**
	 * Updates the animation to the specified time, and optionally in reverse.
	 * @param elapsed The time to update to.
	 * @param reversed [optional] Whether to play the animation in reverse (default is false).
	 */
	updateTo(elapsed: number, reversed?: boolean): void;

	/**
	 * Gets the node with the specified name.
	 * @param name The name of the node to get.
	 * @returns The node with the specified name.
	 */
	getNodeByName(name: string): Node;

	/**
	 * Calls the specified function for each node in the model, and stops if the function returns false. The nodes can not be added or removed during the iteration.
	 * @param func The function to call for each node.
	 * @returns Whether the function was called for all nodes or not.
	 */
	eachNode(func: (this: void, node: Node) => boolean): boolean;
}

export namespace Model {
	export type Type = Model;
}

/**
 * A class for creating instances of the 'Model' object.
 */
interface ModelClass {
	/**
	 * A method that returns a new dummy instance of 'Model' that can do nothing.
	 * @returns A new dummy instance of 'Model'.
	 */
	dummy(): Model;

	/**
	 * Gets the clip file from the specified model file.
	 * @param filename The filename of the model file to search.
	 * @returns The name of the clip file.
	 */
	getClipFile(filename: string): string;

	/**
	 * Gets an array of look names from the specified model file.
	 * @param filename The filename of the model file to search.
	 * @returns An array of look names found in the model file.
	 */
	getLooks(filename: string): string[];

	/**
	 * Gets an array of animation names from the specified model file.
	 * @param filename The filename of the model file to search.
	 * @returns An array of animation names found in the model file.
	 */
	getAnimations(filename: string): string[];

	/**
	 * Creates a new instance of 'Model' from the specified model file.
	 * @param filename The filename of the model file to load.
	 * Can be filename with or without extension like: "Model/item" or "Model/item.model".
	 * @returns A new instance of 'Model'.
	 */
	(this: void, filename: string): Model | null;
}

const modelClass: ModelClass;
export {modelClass as Model};

/**
 * A class for scene node that draws simple shapes such as dots, lines, and polygons.
 */
class DrawNode extends Node {
	private constructor();

	/**
	 * Whether to write to the depth buffer when drawing (default is false).
	 */
	depthWrite: boolean;

	/**
	 * The blend function used to draw the shape.
	 */
	blendFunc: BlendFunc;

	/**
	 * Draws a dot at a specified position with a specified radius and color.
	 * @param pos The position of the dot.
	 * @param radius The radius of the dot.
	 * @param color The color of the dot (default is white).
	 */
	drawDot(pos: Vec2, radius: number, color?: Color): void;

	/**
	 * Draws a line segment between two points with a specified radius and color.
	 * @param from The starting point of the line.
	 * @param to The ending point of the line.
	 * @param radius The radius of the line.
	 * @param color The color of the line (default is white).
	 */
	drawSegment(from: Vec2, to: Vec2, radius: number, color?: Color): void;

	/**
	 * Draws a polygon defined by a list of vertices with a specified fill color and border.
	 * @param verts The vertices of the polygon.
	 * @param fillColor The fill color of the polygon (default is white).
	 * @param borderWidth The width of the border (default is 0).
	 * @param borderColor The color of the border (default is white).
	 */
	drawPolygon(verts: Vec2[], fillColor?: Color, borderWidth?: number, borderColor?: Color): void;

	/**
	 * Draws a set of vertices as triangles, each vertex with its own color.
	 * @param verts The list of vertices and their colors.
	 */
	drawVertices(verts: [Vec2, Color][]): void;

	/**
	 * Clears all previously drawn shapes from the node.
	 */
	clear(): void;
}

export namespace DrawNode {
	export type Type = DrawNode;
}

/**
 * A class for creating DrawNode objects.
 */
interface DrawNodeClass {
	/**
	 * Creates a new DrawNode object.
	 * @returns The new DrawNode object.
	 */
	(this: void): DrawNode;
}

const drawNodeClass: DrawNodeClass;
export {drawNodeClass as DrawNode};

/** A node used for aligning layout elements. */
class AlignNode extends Node {
	private constructor();

	/**
	 * Sets the layout style of the node.
	 *
	 * @param style The layout style.
	 *
	 * The following properties can be set through a CSS style string:
	 *
	 * ## Layout direction and alignment
	 * * direction: Sets the direction (ltr, rtl, inherit).
	 * * align-items, align-self, align-content: Sets the alignment of different items (flex-start, center, stretch, flex-end, auto).
	 * * flex-direction: Sets the layout direction (column, row, column-reverse, row-reverse).
	 * * justify-content: Sets the arrangement of child items (flex-start, center, flex-end, space-between, space-around, space-evenly).
	 *
	 * ## Flex properties
	 * * flex: Sets the overall size of the flex container.
	 * * flex-grow: Sets the flex growth value.
	 * * flex-shrink: Sets the flex shrink value.
	 * * flex-wrap: Sets whether to wrap (nowrap, wrap, wrap-reverse).
	 * * flex-basis: Sets the flex basis value or percentage.
	 *
	 * ## Margins and dimensions
	 * * margin: Can be set by a single value or multiple values separated by commas, percentages or auto for each side.
	 * * margin-top, margin-right, margin-bottom, margin-left, margin-inline-start, margin-inline-end, margin-inline: Sets the margin values, percentages or auto.
	 * * padding: Can be set by a single value or multiple values separated by commas or percentages for each side.
	 * * padding-top, padding-right, padding-bottom, padding-left: Sets the padding values or percentages.
	 * * border: Can be set by a single value or multiple values separated by commas for each side.
	 * * width, height, min-width, min-height, max-width, max-height: Sets the dimension values or percentage properties.
	 *
	 * ## Positioning
	 * * top, right, bottom, left, start, end, horizontal, vertical: Sets the positioning property values or percentages.
	 *
	 * ## Other properties
	 * * position: Sets the positioning type (absolute, relative, static).
	 * * overflow: Sets the overflow property (visible, hidden, scroll).
	 * * display: Controls whether to display (flex, none, contents).
	 * * box-sizing: Sets the box sizing type (border-box, content-box).
	 */
	css(style: string): void;

	/**
	 * Registers a callback function for when the layout is updated.
	 * @param callback The callback function for when the layout is updated.
	 */
	onAlignLayout(callback: (this: void, width: number, height: number) => void): void;
}

interface AlignNodeClass {
	/**
	 * Creates a new AlignNode object.
	 * @param isWindowRoot Whether the node is a window root node. A window root node will automatically listen for window size change events and update the layout accordingly.
	 * @returns The new AlignNode object.
	 */
	(this: void, isWindowRoot?: boolean): AlignNode;
}

export namespace AlignNode {
	export type Type = AlignNode;
}

const alignNodeClass: AlignNodeClass;
export {alignNodeClass as AlignNode};

/**
 * A class for playing Effekseer effects.
 */
class EffekNode extends Node {
	private constructor();

	/**
	 * Plays an Effekseer effect.
	 *
	 * @param filename The filename of the effect.
	 * @param pos The XY position to play the effect at.
	 * @param z The Z position to play the effect at.
	 * @returns The handle of the effect.
	 */
	play(filename: string, pos?: Vec2, z?: number): number;

	/**
	 * Stops an Effekseer effect.
	 *
	 * @param handle The handle of the effect.
	 */
	stop(handle: number): void;

	/**
	 * Registers a callback for when an Effekseer effect has ended.
	 * @param callback The callback function for when the effect has ended.
	 */
	onEffekEnd(callback: (this: void, handle: number) => void): void;
}

/**
 * A class for creating EffekNode objects.
 */
interface EffekNodeClass {
	/**
	 * Creates a new EffekNode object.
	 *
	 * @returns The new EffekNode object.
	 */
	(this: void): EffekNode
}

export namespace EffekNode {
	export type Type = EffekNode;
}

const effekNodeClass: EffekNodeClass;
export {effekNodeClass as EffekNode};

/** The TileNode class to render Tilemaps from TMX file in game scene tree hierarchy. */
class TileNode extends Node {
	private constructor();

	/**
	 * Whether the depth buffer should be written to when rendering the tilemap (default is false).
	 */
	depthWrite: boolean;

	/**
	 * The blend function for the tilemap.
	 */
	blendFunc: BlendFunc;

	/**
	 * The tilemap shader effect.
	 */
	effect: SpriteEffect;

	/**
	 * The texture filtering mode for the tilemap.
	 */
	filter: TextureFilter;

	/**
	 * Get the layer data by name from the tilemap.
	 * @param layerName The name of the layer to get.
	 * @returns The layer data as a dictionary.
	 */
	getLayer(layerName: string): Dictionary | null;
}

export namespace TileNode {
	export type Type = TileNode;
}

/**
 * A class used for creating `TileNode` object.
 */
interface TileNodeClass {
	/**
	 * Creates a TileNode object that will render all the tile layers.
	 * @param tmxFile The TMX file for the tilemap. Can be files created with Tiled Map Editor (http://www.mapeditor.org). The TMX file should be in XML format.
	 * @returns A new instance of the TileNode class. If the tilemap file is not found, it will return null.
	 */
	(this: void, tmxFile: string): TileNode | null;

	/**
	 * Creates a TileNode object that will render the specific tile layer.
	 * @param tmxFile The TMX file for the tilemap.
	 * @param layerName The name of the layer in the TMX file. Can be files created with Tiled Map Editor (http://www.mapeditor.org). The TMX file should be in XML format.
	 * @returns A new instance of the TileNode class. If the tilemap file is not found, it will return null.
	 */
	(this: void, tmxFile: string, layerName: string): TileNode | null;

	/**
	 * Creates a TileNode object that will render the specific tile layers.
	 * @param tmxFile The TMX file for the tilemap.
	 * @param layerNames The names of the layers in the TMX file. Can be files created with Tiled Map Editor (http://www.mapeditor.org). The TMX file should be in XML format.
	 * @returns A new instance of the TileNode class. If the tilemap file is not found, it will return null.
	 */
	(this: void, tmxFile: string, layerNames: string[]): TileNode | null;
}

const tileNodeClass: TileNodeClass;
export {tileNodeClass as TileNode};

/**
 * Emits a global event with the given name and arguments to all listeners registered by `node.gslot()` function.
 * @param eventName The name of the event to emit.
 * @param args The data to pass to the global event listeners.
 */
export function emit(this: void, eventName: string, ...args: any[]): void;

export type Component = number | boolean | string | ContainerItem;

/**
 * A class type representing an entity for an ECS game system.
 */
class Entity extends Object {
	private constructor();

	/** The index of the entity. */
	readonly index: number;

	/**
	 * A syntax shortcut for accessing the old values of the entity's properties.
	 * The old values are values before last change of the component values of the Entity.
	 * Don't keep a reference to it for it is not an actual table.
	 */
	readonly oldValues: Record<string, Component | undefined>;

	/**
	 * A function that destroys the entity.
	 */
	destroy(): void;

	/**
	 * A function that sets a property of the entity to a given value.
	 * This function will trigger events for Observer objects.
	 * @param key The name of the property to set.
	 * @param item The value to set the property to.
	 */
	set(key: string, item: Component | undefined | null): void;

	/**
	 * A function that retrieves the value of a property of the entity
	 * @param key The name of the property to retrieve the value of.
	 * @returns The value of the specified property.
	 */
	get(key: string): Component | undefined;

	/**
	 * A function that retrieves the previous value of a property of the entity
	 * The old values are values before last change of the component values of the Entity.
	 * @param key The name of the property to retrieve the previous value of.
	 * @returns The previous value of the specified property
	 */
	getOld(key: string): Component | undefined;

	/**
	 * A method that retrieves the value of a property of the entity.
	 * @param key The name of the property to retrieve the value of.
	 * @returns The value of the specified property.
	 */
	[key: string]: Component | undefined;
}

export namespace Entity {
	export type Type = Entity;
}

/**
 * A class for creating and managing entities in the ECS game systems.
 */
interface EntityClass {
	/** The number of all running entities. */
	readonly count: number;

	/**
	 * A function that clears all entities.
	 */
	clear(): void;

	/**
	 * A method that creates a new entity with the specified components.
	 * And you can then get the newly created Entity object from groups and observers.
	 * @param components A table mapping component names (strings) to component values (Items).
	 * @example
	 * Entity({ a: 1, b: "abc", c: Node() });
	 */
	(this: void, components: Record<string, Component>): Entity;

	/**
	 * A method that creates a new entity with the specified components.
	 * And you can then get the newly created Entity object from groups and observers.
	 * @param components A table mapping component names (strings) to component values (Items).
	 * @example
	 * Entity<Item>({ a: 1, b: "abc", c: Node() });
	 */
	<T>(this: void, components: T): Entity;
}

const entityClass: EntityClass;
export {entityClass as Entity};

/**
 * A class representing an observer of entity changes in the game systems.
 */
class Observer {
	private constructor();

	/**
	 * Watches the components changes to entities that match the observer's component filter.
	 * @param func The function to call when a change occurs. Returning true inside the function to stop watching.
	 * @returns The same observer, for method chaining.
	 */
	watch(func: (this: void, entity: Entity, ...components: any[]) => boolean): Observer;
}

/**
 * The types of entity events that an observer can watch for.
 */
export const enum EntityEvent {
	/** The addition of a new entity. */
	Add = "Add",

	/** The modification of an existing entity. */
	Change = "Change",

	/** The addition or modification of an entity. */
	AddOrChange = "AddOrChange",

	/** The removal of an existing entity. */
	Remove = "Remove"
}

/**
* A class for creating Observer objects.
*/
interface ObserverClass {
	/**
	 * A method that creates a new observer with the specified component filter and action to watch for.
	 * @param event The type of entity event to watch for.
	 * @param components A list of the names of the components to filter entities by.
	 * @returns The new observer.
	 */
	(this: void, event: EntityEvent, components: string[]): Observer;
}

const observerClass: ObserverClass;
export {observerClass as Observer};

/**
 * A class representing a group of entities in the ECS game systems.
 */
class Group extends Object {
	private constructor();

	/** The number of entities in the group. */
	readonly count: number;

	/** The first entity in the group, or undefined if the group is empty. */
	readonly first?: Entity;

	/**
	 * Calls a function for each entity in the group.
	 * @param func The function to call for each entity. Returning true inside the function to stop iteration.
	 * @returns False if all entities were processed, True if the iteration was interrupted.
	 */
	each(func: (this: void, entity: Entity) => boolean): boolean;

	/**
	 * Finds the first entity in the group that satisfies a predicate function.
	 * @param func The predicate function to test each entity with.
	 * @returns The first entity that satisfies the predicate, or undefined if no entity does.
	 */
	find(func: (this: void, entity: Entity) => boolean): Entity | undefined;

	/**
	 * Watches the group for changes to its entities, calling a function whenever an entity is added or changed.
	 * @param func The function to call when an entity is added or changed. Returning true inside the function to stop watching.
	 * @returns The same group, for method chaining.
	 */
	watch(func: (this: void, entity: Entity, ...components: any[]) => boolean): Group;
}

export namespace Group {
	export type Type = Group;
}

/**
* A class for creating Group objects.
*/
interface GroupClass {
	/**
	 * A method that creates a new group with the specified component names.
	 * @param components A list of the names of the components to include in the group.
	 * @returns The new group.
	 */
	(this: void, components: string[]): Group;
}

const groupClass: GroupClass;
export {groupClass as Group};

/**
 * Represents a 2D texture.
 * Inherits from `Object`.
 */
class Texture2D extends Object {
	private constructor();

	/** The width of the texture, in pixels. */
	readonly width: number;

	/** The height of the texture, in pixels. */
	readonly height: number;
}

export namespace Texture2D {
	export type Type = Texture2D;
}

interface Texture2DClass {
	/**
	 * Creates a new texture from the specified image file.
	 * @param filename The filename of the image file to load.
	 * @returns The new texture.
	 */
	(this: void, filename: string): Texture2D | null;
}

const texture2DClass: Texture2DClass;
export {texture2DClass as Texture2D};

/**
 * A class used to render a texture as a grid of sprites, where each sprite can be positioned,
 * colored, and have its UV coordinates manipulated.
 */
class Grid extends Node {
	private constructor();

	/** The number of columns in the grid. There are `gridX + 1` vertices horizontally for rendering. */
	readonly gridX: number;

	/** The number of rows in the grid. There are `gridY + 1` vertices vertically for rendering. */
	readonly gridY: number;

	/** Whether depth writes are enabled (default is false). */
	depthWrite: boolean;

	/** The texture used for the grid. */
	texture: Texture2D;

	/** The rectangle within the texture that is used for the grid. */
	textureRect: Rect;

	/** The blending function used for the grid. */
	blendFunc: BlendFunc;

	/** The sprite effect applied to the grid. Default is `SpriteEffect("builtin:vs_sprite", "builtin:fs_sprite")`. */
	effect: SpriteEffect;

	/**
	 * Sets the position of a vertex in the grid.
	 * @param x The x-coordinate of the vertex in the grid.
	 * @param y The y-coordinate of the vertex in the grid.
	 * @param pos The new position of the vertex.
	 * @param z [optional] The new z-coordinate of the vertex in the grid (default is 0).
	 */
	setPos(x: number, y: number, pos: Vec2, z?: number): void;

	/**
	 * Gets the position of a vertex in the grid.
	 * @param x The x-coordinate of the vertex in the grid.
	 * @param y The y-coordinate of the vertex in the grid.
	 * @returns The current position of the vertex.
	 */
	getPos(x: number, y: number): Vec2;

	/**
	 * Gets the color of a vertex in the grid.
	 * @param x The x-coordinate of the vertex in the grid.
	 * @param y The y-coordinate of the vertex in the grid.
	 * @returns The current color of the vertex.
	 */
	getColor(x: number, y: number): Color;

	/**
	 * Sets the color of a vertex in the grid.
	 * @param x The x-coordinate of the vertex in the grid.
	 * @param y The y-coordinate of the vertex in the grid.
	 * @param color The new color of the vertex.
	 */
	setColor(x: number, y: number, color: Color): void;

	/**
	 * Moves the UV coordinates of a vertex in the grid.
	 * @param x The x-coordinate of the vertex in the grid.
	 * @param y The y-coordinate of the vertex in the grid.
	 * @param offset The offset by which to move the UV coordinates.
	 */
	moveUV(x: number, y: number, offset: Vec2): void;
}

export namespace Grid {
	export type Type = Grid;
}

/**
* A class for creating Grid objects.
*/
interface GridClass {
	/**
	 * Creates a new Grid with the specified texture rectangle and grid size.
	 * @param width The width of the texture.
	 * @param height The height of the texture.
	 * @param gridX The number of columns in the grid.
	 * @param gridY The number of rows in the grid.
	 * @returns The new Grid instance.
	 */
	(this: void, width: number, height: number, gridX: number, gridY: number): Grid;

	/**
	 * Creates a new Grid with the specified texture, texture rectangle, and grid size.
	 * @param texture The texture to use for the grid.
	 * @param textureRect The rectangle within the texture to use for the grid.
	 * @param gridX The number of columns in the grid.
	 * @param gridY The number of rows in the grid.
	 * @returns The new Grid instance.
	 */
	(this: void, texture: Texture2D, textureRect: Rect, gridX: number, gridY: number): Grid;

	/**
	 * Creates a new Grid with the specified texture and grid size.
	 * @param texture The texture to use for the grid.
	 * @param gridX The number of columns in the grid.
	 * @param gridY The number of rows in the grid.
	 * @returns The new Grid instance.
	 */
	(this: void, texture: Texture2D, gridX: number, gridY: number): Grid;

	/**
	 * Creates a new Grid with the specified clip string and grid size.
	 * @param clipStr The clip string to use for the grid. Can be "Image/file.png" and "Image/items.clip|itemA".
	 * @param gridX The number of columns in the grid.
	 * @param gridY The number of rows in the grid.
	 * @returns The new Grid instance.
	 */
	(this: void, clipStr: string, gridX: number, gridY: number): Grid;
}

const gridClass: GridClass;
export {gridClass as Grid};

/**
 * An enum that defines the various types of resources that can be loaded into the cache.
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
	TMX = "TMX",
}

/**
 * An enum that defines the various types of resources that can be safely unloaded from the cache.
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
	TMX = "TMX",
}

/**
 * A singleton cache instance for various game resources.
 */
class Cache {
	private constructor();

	/**
	 * Loads a file into the cache with a blocking operation.
	 * @param filename The name of the file to load.
	 * @returns True if the file was loaded successfully, false otherwise.
	 */
	load(filename: string): boolean;

	/**
	 * Loads a file into the cache asynchronously.
	 * @param filename The name of the file(s) to load.
	 * @param handler A function to call when a resource is loaded. The progress parameter is a number between 0 and 1.
	 * @returns True if the file was loaded successfully, false otherwise.
	 * @example
	 * thread(() => {
	 * 	const success = Cache.loadAsync("file.png");
	 * 	if (success) {
	 * 		print("Game resource is loaded into memory");
	 * 	}
	 * });
	 */
	loadAsync(filename: string | string[], handler?: (this: void, progress: number) => void): boolean;

	/**
	 * Updates the content of a file loaded in the cache.
	 * If the item of filename does not exist in the cache, a new file content will be added into the cache.
	 * @param filename The name of the file to update.
	 * @param content The new content for the file.
	 */
	update(filename: string, content: string): void;

	/**
	 * Updates the texture object of the specific filename loaded in the cache.
	 * If the texture object of filename does not exist in the cache, it will be added into the cache.
	 * @param filename The name of the texture to update.
	 * @param texture The new texture object for the file.
	 */
	update(filename: string, texture: Texture2D): void;

	/**
	 * Unloads a resource from the cache.
	 * @param type The type of resource to unload.
	 * @returns True if the resource was unloaded successfully, false otherwise.
	 */
	unload(type: CacheResourceTypeSafeUnload): boolean;

	/**
	 * Unloads a resource from the cache.
	 * @param filename The name of the file to unload.
	 * @returns True if the resource was unloaded successfully, false otherwise.
	 */
	unload(filename: string): boolean;

	/**
	 * Unloads all resources from the cache.
	 */
	unload(): void;

	/**
	 * Removes all unused resources (not being referenced) of the given type from the cache.
	 * @param type The type of resource to remove.
	 */
	removeUnused(type: CacheResourceType): void;

	/**
	 * Removes all unused resources (not being referenced) from the cache.
	 */
	removeUnused(): void;
}

const cache: Cache;
export {cache as Cache};

/** A definition object for fixtures added to physics bodies. */
class FixtureDef extends Object {
	private constructor();
}

export namespace FixtureDef {
	export type Type = FixtureDef;
}

/**
 * A class to represent a physics sensor object in the game world.
 */
class Sensor extends Object {
	private constructor();

	/**
	 * Whether the sensor is currently enabled or not.
	 */
	enabled: boolean;

	/**
	 * The tag for the sensor.
	 */
	readonly tag: number;

	/**
	 * The "Body" object that owns the sensor.
	 */
	readonly owner: Body;

	/**
	 * Whether the sensor is currently sensing any other "Body" objects in the game world.
	 */
	readonly sensed: boolean;

	/**
	 * An array of "Body" objects that are currently being sensed by the sensor.
	 */
	readonly sensedBodies: Array;

	/**
	 * Determines whether the specified "Body" object is currently being sensed by the sensor.
	 * @param body The "Body" object to check if it is being sensed.
	 * @returns True if the "Body" object is being sensed by the sensor, false otherwise.
	 */
	contains(body: Body): boolean;
}

export namespace Sensor {
	export type Type = Sensor;
}

export const enum BodyMoveType {
	/** A body that does not move. */
	Static = "Static",

	/** A body that can move and be affected by forces. */
	Dynamic = "Dynamic",

	/** A body that can move but is not affected by forces. */
	Kinematic = "Kinematic",
}

/**
 * A class called "BodyDef" to describe the properties of a physics body.
 * Inherits from `Object`.
 */
class BodyDef extends Object {
	private constructor();

	/**
	 * An enumeration for the different moving types of bodies.
	 */
	type: BodyMoveType;

	/** Position of the body. */
	position: Vec2;

	/** Angle of the body. */
	angle: number;

	/** Face image or other items for the body. */
	face: string;

	/** Position of the face on the body. */
	facePos: Vec2;

	/** Linear damping of the body. */
	linearDamping: number;

	/** Angular damping of the body. */
	angularDamping: number;

	/**
	 * A constant linear acceleration applied to the body.
	 * Can be used for simulating gravity, wind, or other constant forces.
	 * @example
	 * bodyDef.linearAcceleration = Vec2(0, -9.8);
	 */
	linearAcceleration: Vec2;

	/** Whether the body's rotation is fixed. */
	fixedRotation: boolean;

	/**
	 * Whether the body is a bullet. Set to true for extra bullet movement check.
	 */
	bullet: boolean;

	/**
	 * Attaches a polygon fixture definition to the body.
	 * @param center The center point of the polygon.
	 * @param width The width of the polygon.
	 * @param height The height of the polygon.
	 * @param angle The angle of the polygon (default is 0.0) (optional).
	 * @param density The density of the polygon (default is 0.0) (optional).
	 * @param friction The friction of the polygon (default is 0.4, should be 0 to 1.0) (optional).
	 * @param restitution The restitution of the polygon (default is 0.0, should be 0 to 1.0) (optional).
	 */
	attachPolygon(center: Vec2, width: number, height: number, angle?: number, density?: number, friction?: number, restitution?: number): void;

	/**
	 * Attaches a polygon fixture definition to the body using only width and height.
	 * @param width The width of the polygon.
	 * @param height The height of the polygon.
	 * @param density The density of the polygon (default is 0.0) (optional).
	 * @param friction The friction of the polygon (default is 0.4, should be 0 to 1.0) (optional).
	 * @param restitution The restitution of the polygon (default is 0.0, should be 0 to 1.0) (optional).
	 */
	attachPolygon(width: number, height: number, density?: number, friction?: number, restitution?: number): void;

	/**
	 * Attaches a polygon fixture definition to the body using vertices.
	 * @param vertices The vertices of the polygon.
	 * @param density The density of the polygon (default is 0.0) (optional).
	 * @param friction The friction of the polygon (default is 0.4, should be 0 to 1.0) (optional).
	 * @param restitution The restitution of the polygon (default is 0.0, should be 0 to 1.0) (optional).
	 */
	attachPolygon(vertices: Vec2[], density?: number, friction?: number, restitution?: number): void;

	/**
	 * Attaches a concave shape definition made of multiple convex shapes to the body.
	 * @param vertices A table containing the vertices of each convex shape that makes up the concave shape.
	 * @param density The density of the concave shape (default is 0.0) (optional).
	 * @param friction The friction of the concave shape (default is 0.4, should be 0 to 1.0) (optional).
	 * @param restitution The restitution of the concave shape (default is 0.0, should be 0 to 1.0) (optional).
	 */
	attachMulti(vertices: Vec2[], density?: number, friction?: number, restitution?: number): void;

	/**
	 * Attaches a disk fixture definition to the body.
	 * @param center The center point of the disk.
	 * @param radius The radius of the disk.
	 * @param density The density of the disk (default is 0.0) (optional).
	 * @param friction The friction of the disk (default is 0.4, should be 0 to 1.0) (optional).
	 * @param restitution The restitution of the disk (default is 0.0, should be 0 to 1.0) (optional).
	 */
	attachDisk(center: Vec2, radius: number, density?: number, friction?: number, restitution?: number): void;

	/**
	 * Attaches a disk fixture to the body using only radius.
	 * @param radius The radius of the disk.
	 * @param density The density of the disk (default is 0.0) (optional).
	 * @param friction The friction of the disk (default is 0.4) (optional).
	 * @param restitution The restitution of the disk (default is 0.0) (optional).
	 */
	attachDisk(radius: number, density?: number, friction?: number, restitution?: number): void;

	/**
	 * Attaches a chain fixture definition to the body. The Chain fixture is a free form sequence of line segments that has two-sided collision.
	 * @param vertices The vertices of the chain.
	 * @param friction The friction of the chain (default is 0.4) (optional).
	 * @param restitution The restitution of the chain (default is 0.0) (optional).
	 */
	attachChain(vertices: Vec2[], friction?: number, restitution?: number): void;

	/**
	 * Attaches a polygon sensor fixture definition to the body.
	 * @param tag An integer tag for the sensor.
	 * @param width The width of the polygon.
	 * @param height The height of the polygon.
	 * @param angle The angle of the polygon (default is 0.0) (optional).
	 */
	attachPolygonSensor(tag: number, width: number, height: number, angle?: number): void;

	/**
	 * Attaches a polygon sensor fixture definition to the body.
	 * @param tag An integer tag for the sensor.
	 * @param center The center point of the polygon.
	 * @param width The width of the polygon.
	 * @param height The height of the polygon.
	 * @param angle The angle of the polygon (default is 0.0) (optional).
	 */
	attachPolygonSensor(tag: number, center: Vec2, width: number, height: number, angle?: number): void;

	/**
	 * Attaches a polygon sensor fixture definition to the body using vertices.
	 * @param tag An integer tag for the sensor.
	 * @param vertices A table containing the vertices of the polygon.
	 */
	attachPolygonSensor(tag: number, vertices: Vec2[]): void;

	/**
	 * Attaches a disk sensor fixture definition to the body.
	 * @param tag An integer tag for the sensor.
	 * @param center The center of the disk.
	 * @param radius The radius of the disk.
	 */
	attachDiskSensor(tag: number, center: Vec2, radius: number): void;

	/**
	 * Attaches a disk sensor fixture to the body using only radius.
	 * @param tag An integer tag for the sensor.
	 * @param radius The radius of the disk.
	 */
	attachDiskSensor(tag: number, radius: number): void;
}

export namespace BodyDef {
	export type Type = BodyDef;
}

/**
 * A class for creating BodyDef and FixtureDef.
 */
interface BodyDefClass {
	/**
	 * Creates a polygon fixture definition with the specified dimensions.
	 * @param width The width of the polygon.
	 * @param height The height of the polygon.
	 * @param density The density of the polygon (default is 0.0) (optional).
	 * @param friction The friction of the polygon (default is 0.4, should be 0.0 to 1.0) (optional).
	 * @param restitution The restitution of the polygon (default is 0.0, should be  0.0 to 1.0) (optional).
	 * @returns A FixtureDef object for the created polygon fixture.
	 */
	polygon(width: number, height: number, density?: number, friction?: number, restitution?: number): FixtureDef;

	/**
	 * Creates a polygon fixture definition with the specified dimensions and center position.
	 * @param center The center position of the polygon.
	 * @param width The width of the polygon.
	 * @param height The height of the polygon.
	 * @param angle The angle of the polygon in radians (default is 0.0) (optional).
	 * @param density The density of the polygon (default is 0.0) (optional).
	 * @param friction The friction of the polygon (default is 0.4, should be 0.0 to 1.0) (optional).
	 * @param restitution The restitution of the polygon (default is 0.0, should be 0.0 to 1.0) (optional).
	 * @returns A FixtureDef object for the created polygon fixture.
	 */
	polygon(center: Vec2, width: number, height: number, angle?: number, density?: number, friction?: number, restitution?: number): FixtureDef;

	/**
	 * Creates a polygon fixture definition with the specified vertices.
	 * @param vertices The vertices of the polygon.
	 * @param density The density of the polygon (default is 0.0) (optional).
	 * @param friction The friction of the polygon (default is 0.4, should be 0.0 to 1.0) (optional).
	 * @param restitution The restitution of the polygon (default is 0.0, should be 0.0 to 1.0) (optional).
	 * @returns A FixtureDef object for the created polygon fixture.
	 */
	polygon(vertices: Vec2[], density?: number, friction?: number, restitution?: number): FixtureDef;

	/**
     * Create a concave shape definition made of multiple convex shapes.
     * @param vertices Array of Vec2 representing vertices of each convex shape that makes up the concave shape. Each convex shape in the vertices array should end with a Vec2(0.0, 0.0) as a separator.
     * @param density The density of the shape (optional, default 0.0).
     * @param friction The friction coefficient of the shape (optional, default 0.4, should be 0.0 to 1.0).
     * @param restitution The restitution (elasticity) of the shape (optional, default 0.0, should be 0.0 to 1.0).
     * @returns The resulting fixture definition.
     */
	multi(vertices: Vec2[], density?: number, friction?: number, restitution?: number): FixtureDef;

	/**
	 * Create a Disk-shape fixture definition.
	 * @param center The center of the circle as Vec2.
	 * @param radius The radius of the circle.
	 * @param density The density of the circle (optional, default 0.0).
	 * @param friction The friction coefficient of the circle (optional, default 0.4, should be 0.0 to 1.0).
	 * @param restitution The restitution (elasticity) of the circle (optional, default 0.0, should be 0.0 to 1.0).
	 * @returns The resulting fixture definition.
	 */
	disk(center: Vec2, radius: number, density?: number, friction?: number, restitution?: number): FixtureDef;

	/**
	 * Create a Disk-shape fixture definition with center at origin.
	 * @param radius The radius of the circle.
	 * @param density The density of the circle (optional, default 0.0).
	 * @param friction The friction coefficient of the circle (optional, default 0.4, should be 0.0 to 1.0).
	 * @param restitution The restitution (elasticity) of the circle (optional, default 0.0, should be 0.0 to 1.0).
	 * @returns The resulting fixture definition.
	 */
	disk(radius: number, density?: number, friction?: number, restitution?: number): FixtureDef;

	/**
	 * Create a Chain-shape fixture definition. This fixture is a free form sequence of line segments that has two-sided collision.
	 * @param vertices The vertices of the chain as an array of Vec2.
	 * @param friction The friction coefficient of the chain (optional, default 0.4, should be 0.0 to 1.0).
	 * @param restitution The restitution (elasticity) of the chain (optional, default 0.0, should be 0.0 to 1.0).
	 * @returns The resulting fixture definition.
	 */
	chain(vertices: Vec2[], friction?: number, restitution?: number): FixtureDef;

	/**
	 * Create a new instance of BodyDef class.
	 * @returns a new BodyDef object.
	 */
	(this: void): BodyDef;
}

const bodyDefClass: BodyDefClass;
export {bodyDefClass as BodyDef};

/**
 * A class represents a physics body in the world.
 */
class Body extends Node {
	protected constructor();

	/**
	 * The physics world that the body belongs to.
	 */
	readonly world: PhysicsWorld;

	/**
	 * The definition of the body.
	 */
	readonly bodyDef: BodyDef;

	/**
	 * The mass of the body.
	 */
	readonly mass: number;

	/**
	 * Whether the body is used as a sensor or not.
	 */
	readonly sensor: boolean;

	/**
	 * The x-axis velocity of the body.
	 */
	velocityX: number;

	/**
	 * The y-axis velocity of the body.
	 */
	velocityY: number;

	/**
	 * The velocity of the body as a `Vec2`.
	 */
	velocity: Vec2;

	/**
	 * The angular rate of the body.
	 */
	angularRate: number;

	/**
	 * The collision group that the body belongs to.
	 */
	group: number;

	/**
	 * The linear damping of the body.
	 */
	linearDamping: number;

	/**
	 * The angular damping of the body.
	 */
	angularDamping: number;

	/**
	 * The reference for an owner of the body.
	 */
	owner?: Object;

	/**
	 * Whether the body is currently receiving contact events or not.
	 */
	receivingContact: boolean;

	/**
	 * Applies a linear impulse to the body at a specified position.
	 * @param impulse The linear impulse to apply.
	 * @param pos The position at which to apply the impulse.
	 */
	applyLinearImpulse(impulse: Vec2, pos: Vec2): void;

	/**
	 * Applies an angular impulse to the body.
	 * @param impulse The angular impulse to apply.
	 */
	applyAngularImpulse(impulse: number): void;

	/**
	 * Removes the sensor with the specified tag from the body.
	 * @param tag The tag of the sensor to remove.
	 * @returns Whether a sensor with the specified tag was found and removed.
	 */
	removeSensorByTag(tag: number): boolean;

	/**
	 * Attaches a fixture to the body.
	 * @param fixtureDef The fixture definition for the fixture to attach.
	 */
	attach(fixtureDef: FixtureDef): void;

	/**
	 * Returns the sensor with the given tag.
	 * @param tag The tag of the sensor to get.
	 * @returns The sensor with the given tag.
	 */
	getSensorByTag(tag: number): Sensor;

	/**
	 * Removes the given sensor from the body's sensor list.
	 * @param sensor The sensor to remove.
	 * @returns True if the sensor was successfully removed, false otherwise.
	 */
	removeSensor(sensor: Sensor): boolean;

	/**
	 * Attaches a new sensor with the given tag and fixture definition to the body.
	 * @param tag The tag of the sensor to attach.
	 * @param fixtureDef The fixture definition of the sensor.
	 * @returns The newly attached sensor.
	 */
	attachSensor(tag: number, fixtureDef: FixtureDef): Sensor;

	/**
	 * Register a function to be called when the body begins to receive contact events. Return false from this function to prevent colliding.
	 * @param filter The filter function to set.
	 */
	onContactFilter(filter: (this: void, other: Body) => boolean): void;

	/**
	 * Registers a callback function for when the body enters a sensor.
	 * @param callback The callback function for when the body enters a sensor.
	 */
	onBodyEnter(callback: (this: void, other: Body, sensorTag: number) => void): void;

	/**
	 * Registers a callback function for when the body leaves a sensor.
	 * @param callback The callback function for when the body leaves a sensor.
	 */
	onBodyLeave(callback: (this: void, other: Body, sensorTag: number) => void): void;

	/**
	 * Registers a callback function for when the body starts to collide with another object.
	 * This function sets the `receivingContact` property to true.
	 * @param callback The callback function for when the body starts to collide with another object.
	 */
	onContactStart(callback: (this: void, other: Body, point: Vec2, normal: Vec2, enabled: boolean) => void): void;

	/**
	 * Registers a callback function for when the body stops colliding with another object.
	 * This function sets the `receivingContact` property to true.
	 * @param callback The callback function for when the body stops colliding with another object.
	 */
	onContactEnd(callback: (this: void, other: Body, point: Vec2, normal: Vec2) => void): void;
}

export {Body as BodyType};
export namespace Body {
	export type Type = Body;
}

/**
 * A class for creating Body objects.
 */
interface BodyClass {
	/**
	 * Creates a new instance of `Body`.
	 * @param def The definition for the body to be created.
	 * @param world The physics world where the body belongs.
	 * @param pos [optional] The initial position of the body. Defaults to zero vector.
	 * @param rot [optional] The initial rotation angle of the body in degrees. Defaults to 0.
	 * @returns The newly created `Body` instance.
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
 * A class representing a physics world in the game.
 */
class PhysicsWorld extends Node {
	protected constructor();

	/**
	 * Whether debug graphic should be displayed for the physics world.
	 */
	showDebug: boolean;

	/**
	 * Queries the physics world for all bodies that intersect with the specified rectangle.
	 *
	 * @param rect The rectangle to query for bodies.
	 * @param handler A function that is called for each body found in the query.
	 * @returns Whether the query was interrupted, true means interrupted, false otherwise.
	 */
	query(rect: Rect, handler: (this: void, body: Body) => boolean): boolean;

	/**
	 * Casts a ray through the physics world and finds the first body that intersects with the ray.
	 *
	 * @param start The starting point of the ray.
	 * @param stop The ending point of the ray.
	 * @param closest Whether to stop ray casting upon the closest body that intersects with the ray. Set closest to true to get a faster ray casting search.
	 * @param handler A function that is called for each body found in the raycast.
	 * @returns Whether the raycast was interrupted, true means interrupted, false otherwise.
	 */
	raycast(start: Vec2, stop: Vec2, closest: boolean, handler: (this: void, body: Body, point: Vec2, normal: Vec2) => boolean): boolean;

	/**
	 * Sets the number of velocity and position iterations to perform in the physics world.
	 *
	 * @param velocityIter The number of velocity iterations to perform.
	 * @param positionIter The number of position iterations to perform.
	 */
	setIterations(velocityIter: number, positionIter: number): void;

	/**
	 * Sets whether two physics groups should make contact with each other or not.
	 *
	 * @param groupA The first physics group.
	 * @param groupB The second physics group.
	 * @param contact Whether the two groups should make contact with each other.
	 */
	setShouldContact(groupA: number, groupB: number, contact: boolean): void;

	/**
	 * Gets whether two physics groups should make contact with each other or not.
	 *
	 * @param groupA The first physics group.
	 * @param groupB The second physics group.
	 * @returns Whether the two groups should make contact with each other.
	 */
	getShouldContact(groupA: number, groupB: number): boolean;
}

export {PhysicsWorld as PhysicsWorldType};
export namespace PhysicsWorld {
	export type Type = PhysicsWorld;
}

/**
 * A class for creating PhysicsWorld objects.
 */
interface PhysicsWorldClass {
	/**
	 * A factor used for converting physics engine meters value to pixel value.
	 * Default 100.0 is a good value since the physics engine can well simulate real life objects
	 * between 0.1 to 10 meters. Use value 100.0 we can simulate game objects
	 * between 10 to 1000 pixels that suite most games.
	 * You can change this value before any physics body creation.
	 */
	scaleFactor: number;

	/**
	 * Creates a new "PhysicsWorld" object.
	 * @returns The new "PhysicsWorld" object.
	 */
	(this: void): PhysicsWorld;
}

const physicsWorldClass: PhysicsWorldClass;
export {physicsWorldClass as PhysicsWorld};

/**
 * A class that can be used to connect physics bodies together.
 */
class Joint extends Object {
	protected constructor();

	/**
	 * The physics world that the joint belongs to.
	 */
	readonly world: PhysicsWorld;

	/**
	 * Destroys the joint and removes it from the physics simulation.
	 */
	destroy(): void;
}

export namespace Joint {
	export type Type = Joint;
}

/**
 * A joint that applies a rotational or linear force to a physics body.
 */
class MotorJoint extends Joint {
	private constructor();

	/**
	 * Whether or not the motor joint is enabled.
	 */
	enabled: boolean;

	/**
	 * The force applied to the motor joint.
	 */
	force: number;

	/**
	 * The speed of the motor joint.
	 */
	speed: number;
}

export namespace MotorJoint {
	export type Type = MotorJoint;
}

/**
* A type of joint that allows a physics body to move to a specific position.
*/
class MoveJoint extends Joint {
	private constructor();

	/**
	 * The current position of the move joint in the game world.
	 */
	position: Vec2;
}

export namespace MoveJoint {
	export type Type = MoveJoint;
}

/**
 * A class that defines the properties of a joint to be created.
 */
class JointDef extends Object {
	private constructor();

	/** The center point of the joint, in local coordinates. */
	center: Vec2;

	/** The position of the joint, in world coordinates. */
	position: Vec2;

	/** The angle of the joint, in degrees. */
	angle: number;
}

/**
 * An interface for creating JointDef objects.
 */
interface JointDefClass {
	/**
	 * Creates a distance joint definition.
	 * @param canCollide Whether the physics body connected to joint will collide with each other.
	 * @param bodyA The name of first physics body to connect with the joint.
	 * @param bodyB The name of second physics body to connect with the joint.
	 * @param anchorA The position of the joint on the first physics body.
	 * @param anchorB The position of the joint on the second physics body.
	 * @param frequency The frequency of the joint, in Hertz (default is 0.0).
	 * @param damping The damping ratio of the joint (default is 0.0).
	 * @returns The new joint definition.
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
	 * Creates a friction joint definition.
	 * @param canCollide Whether or not the physics body connected to the joint will collide with each other.
	 * @param bodyA The name of the first physics body to connect with the joint.
	 * @param bodyB The name of the second physics body to connect with the joint.
	 * @param worldPos The position of the joint in the game world.
	 * @param maxForce The maximum force that can be applied to the joint.
	 * @param maxTorque The maximum torque that can be applied to the joint.
	 * @returns The new friction joint definition.
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
	 * Creates a gear joint definition.
	 * @param canCollide Whether or not the physics bodies connected to the joint can collide with each other.
	 * @param jointA The name of the first joint to connect with the gear joint.
	 * @param jointB The name of the second joint to connect with the gear joint.
	 * @param ratio The gear ratio (default is 1.0).
	 * @returns The new gear joint definition.
	 */
	gear(
		canCollide: boolean,
		jointA: string,
		jointB: string,
		ratio?: number
	): JointDef;

	/**
	 * Creates a new spring joint definition.
	 * @param canCollide Whether the connected bodies should collide with each other.
	 * @param bodyA The name of the first body connected to the joint.
	 * @param bodyB The name of the second body connected to the joint.
	 * @param linearOffset Position of body-B minus the position of body-A, in body-A's frame.
	 * @param angularOffset Angle of body-B minus angle of body-A.
	 * @param maxForce The maximum force the joint can exert.
	 * @param maxTorque The maximum torque the joint can exert.
	 * @param correctionFactor Optional correction factor, defaults to 1.0.
	 * @returns The created joint definition.
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
	 * Creates a new prismatic joint definition.
	 * @param canCollide Whether the connected bodies should collide with each other.
	 * @param bodyA The name of the first body connected to the joint.
	 * @param bodyB The name of the second body connected to the joint.
	 * @param worldPos The world position of the joint.
	 * @param axisAngle The axis angle of the joint.
	 * @param lowerTranslation Optional lower translation limit, defaults to 0.0.
	 * @param upperTranslation Optional upper translation limit, defaults to 0.0.
	 * @param maxMotorForce Optional maximum motor force, defaults to 0.0.
	 * @param motorSpeed Optional motor speed, defaults to 0.0.
	 * @returns The created prismatic joint definition.
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
	 * Create a pulley joint definition.
	 * @param canCollide Whether or not the connected bodies will collide with each other.
	 * @param bodyA The name of the first physics body to connect.
	 * @param bodyB The name of the second physics body to connect.
	 * @param anchorA The position of the anchor point on the first body.
	 * @param anchorB The position of the anchor point on the second body.
	 * @param groundAnchorA The position of the ground anchor point on the first body in world coordinates.
	 * @param groundAnchorB The position of the ground anchor point on the second body in world coordinates.
	 * @param ratio Optional The pulley ratio (default 1.0).
	 * @returns The pulley joint definition.
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
	 * Create a revolute joint definition.
	 * @param canCollide Whether or not the connected bodies will collide with each other.
	 * @param bodyA The name of the first physics body to connect.
	 * @param bodyB The name of the second physics body to connect.
	 * @param worldPos The position in world coordinates where the joint will be created.
	 * @param lowerAngle Optional The lower angle limit (radians) (default 0.0).
	 * @param upperAngle Optional The upper angle limit (radians) (default 0.0).
	 * @param maxMotorTorque Optional The maximum torque that can be applied to the joint to achieve the target speed (default 0.0).
	 * @param motorSpeed Optional The desired speed of the joint (default 0.0).
	 * @returns The revolute joint definition.
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
	 * Create a rope joint definition.
	 * @param canCollide Whether or not the connected bodies will collide with each other.
	 * @param bodyA The name of the first physics body to connect.
	 * @param bodyB The name of the second physics body to connect.
	 * @param anchorA The position of the anchor point on the first body.
	 * @param anchorB The position of the anchor point on the second body.
	 * @param maxLength Optional The maximum distance between the anchor points (default 0.0).
	 * @returns The rope joint definition.
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
	 * Creates a weld joint definition.
	 * @param canCollide Whether or not the bodies connected to the joint can collide with each other.
	 * @param bodyA The name of the first body to be connected by the joint.
	 * @param bodyB The name of the second body to be connected by the joint.
	 * @param worldPos The position in the world to connect the bodies together.
	 * @param frequency Optional The frequency at which the joint should be stiff, defaults to 0.0.
	 * @param damping Optional The damping rate of the joint, defaults to 0.0.
	 * @returns The newly created weld joint definition.
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
	 * Creates a wheel joint definition.
	 * @param canCollide Whether or not the bodies connected to the joint can collide with each other.
	 * @param bodyA The name of the first body to be connected by the joint.
	 * @param bodyB The name of the second body to be connected by the joint.
	 * @param worldPos The position in the world to connect the bodies together.
	 * @param axisAngle The angle of the joint axis in radians.
	 * @param maxMotorTorque Optional The maximum torque the joint motor can exert, defaults to 0.0.
	 * @param motorSpeed Optional The target speed of the joint motor, defaults to 0.0.
	 * @param frequency Optional The frequency at which the joint should be stiff, defaults to 2.0.
	 * @param damping Optional The damping rate of the joint, defaults to 0.7.
	 * @returns The newly created wheel joint definition.
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
 * A factory class to create different types of joints that can be used to connect physics bodies together.
 */
interface JointClass {
	/**
	 * Creates a distance joint between two physics bodies.
	 * @param canCollide Whether or not the physics body connected to joint will collide with each other.
	 * @param bodyA The first physics body to connect with the joint.
	 * @param bodyB The second physics body to connect with the joint.
	 * @param anchorA The position of the joint on the first physics body.
	 * @param anchorB The position of the joint on the second physics body.
	 * @param frequency The frequency of the joint, in Hertz (default is 0.0).
	 * @param damping The damping ratio of the joint (default is 0.0).
	 * @returns The new distance joint.
	 */
	distance(
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		anchorA: Vec2,
		anchorB: Vec2,
		frequency?: number,
		damping?: number
	): Joint;

	/**
	 * Creates a friction joint between two physics bodies.
	 * @param canCollide Whether or not the physics body connected to joint will collide with each other.
	 * @param bodyA The first physics body to connect with the joint.
	 * @param bodyB The second physics body to connect with the joint.
	 * @param worldPos The position of the joint in the game world.
	 * @param maxForce The maximum force that can be applied to the joint.
	 * @param maxTorque The maximum torque that can be applied to the joint.
	 * @returns The new friction joint.
	 */
	friction(
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		maxForce: number,
		maxTorque: number
	): Joint;

	/**
	 * Creates a gear joint between two other joints.
	 * @param canCollide Whether or not the physics bodies connected to the joint can collide with each other.
	 * @param jointA The first joint to connect with the gear joint.
	 * @param jointB The second joint to connect with the gear joint.
	 * @param ratio The gear ratio (default is 1.0).
	 * @returns The new gear joint.
	 */
	gear(
		canCollide: boolean,
		jointA: Joint,
		jointB: Joint,
		ratio?: number
	): Joint;

	/**
	 * Creates a new spring joint between the two specified bodies.
	 * @param canCollide Whether the connected bodies should collide with each other.
	 * @param bodyA The first body connected to the joint.
	 * @param bodyB The second body connected to the joint.
	 * @param linearOffset Position of body-B minus the position of body-A, in body-A's frame.
	 * @param angularOffset Angle of body-B minus angle of body-A.
	 * @param maxForce The maximum force the joint can exert.
	 * @param maxTorque The maximum torque the joint can exert.
	 * @param correctionFactor Optional correction factor, defaults to 1.0.
	 * @returns The created joint.
	 */
	spring(
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		linearOffset: Vec2,
		angularOffset: number,
		maxForce: number,
		maxTorque: number,
		correctionFactor?: number
	): Joint;

	/**
	 * Creates a new move joint for the specified body.
	 * @param canCollide Whether the body can collide with other bodies.
	 * @param body The body that the joint is attached to.
	 * @param targetPos The target position that the body should move towards.
	 * @param maxForce The maximum force the joint can exert.
	 * @param frequency Optional frequency ratio, defaults to 5.0.
	 * @param damping Optional damping ratio, defaults to 0.7.
	 * @returns The created move joint.
	 */
	move(
		canCollide: boolean,
		body: Body,
		targetPos: Vec2,
		maxForce: number,
		frequency?: number,
		damping?: number
	): MoveJoint;

	/**
	 * Creates a new prismatic joint between the two specified bodies.
	 * @param canCollide Whether the connected bodies should collide with each other.
	 * @param bodyA The first body connected to the joint.
	 * @param bodyB The second body connected to the joint.
	 * @param worldPos The world position of the joint.
	 * @param axisAngle The axis angle of the joint.
	 * @param lowerTranslation Optional lower translation limit, defaults to 0.0.
	 * @param upperTranslation Optional upper translation limit, defaults to 0.0.
	 * @param maxMotorForce Optional maximum motor force, defaults to 0.0.
	 * @param motorSpeed Optional motor speed, defaults to 0.0.
	 * @returns The created prismatic joint.
	 */
	prismatic(
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		axisAngle: number,
		lowerTranslation?: number,
		upperTranslation?: number,
		maxMotorForce?: number,
		motorSpeed?: number
	): MotorJoint;

	/**
	 * Create a pulley joint between two physics bodies.
	 * @param canCollide Whether or not the connected bodies will collide with each other.
	 * @param bodyA The first physics body to connect.
	 * @param bodyB The second physics body to connect.
	 * @param anchorA The position of the anchor point on the first body.
	 * @param anchorB The position of the anchor point on the second body.
	 * @param groundAnchorA The position of the ground anchor point on the first body in world coordinates.
	 * @param groundAnchorB The position of the ground anchor point on the second body in world coordinates.
	 * @param ratio Optional The pulley ratio, defaults to 1.0.
	 * @returns The created pulley joint.
	 */
	pulley(
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		anchorA: Vec2,
		anchorB: Vec2,
		groundAnchorA: Vec2,
		groundAnchorB: Vec2,
		ratio?: number
	): Joint;

	/**
	 * Create a revolute joint between two physics bodies.
	 * @param canCollide Whether or not the connected bodies will collide with each other.
	 * @param bodyA The first physics body to connect.
	 * @param bodyB The second physics body to connect.
	 * @param worldPos The position in world coordinates where the joint will be created.
	 * @param lowerAngle Optional The lower angle limit (radians), defaults to 0.0.
	 * @param upperAngle Optional The upper angle limit (radians), defaults to 0.0.
	 * @param maxMotorTorque Optional The maximum torque that can be applied to the joint to achieve the target speed, defaults to 0.0.
	 * @param motorSpeed Optional The desired speed of the joint, defaults to 0.0.
	 * @returns The created revolute joint.
	 */
	revolute(
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		lowerAngle?: number,
		upperAngle?: number,
		maxMotorTorque?: number,
		motorSpeed?: number
	): MotorJoint;

	/**
	 * Create a rope joint between two physics bodies.
	 * @param canCollide Whether or not the connected bodies will collide with each other.
	 * @param bodyA The first physics body to connect.
	 * @param bodyB The second physics body to connect.
	 * @param anchorA The position of the anchor point on the first body.
	 * @param anchorB The position of the anchor point on the second body.
	 * @param maxLength Optional The maximum distance between the anchor points, defaults to 0.0.
	 * @returns The created rope joint.
	 */
	rope(
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		anchorA: Vec2,
		anchorB: Vec2,
		maxLength?: number
	): Joint;

	/**
	 * Creates a weld joint between two bodies.
	 * @param canCollide Whether or not the bodies connected to the joint can collide with each other.
	 * @param bodyA The first body to be connected by the joint.
	 * @param bodyB The second body to be connected by the joint.
	 * @param worldPos The position in the world to connect the bodies together.
	 * @param frequency [optional] The frequency at which the joint should be stiff, defaults to 0.0.
	 * @param damping [optional] The damping rate of the joint, defaults to 0.0.
	 * @returns The newly created weld joint.
	 */
	weld(
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		frequency?: number,
		damping?: number
	): Joint;

	/**
	 * Creates a wheel joint between two bodies.
	 * @param canCollide Whether or not the bodies connected to the joint can collide with each other.
	 * @param bodyA The first body to be connected by the joint.
	 * @param bodyB The second body to be connected by the joint.
	 * @param worldPos The position in the world to connect the bodies together.
	 * @param axisAngle The angle of the joint axis in radians.
	 * @param maxMotorTorque [optional] The maximum torque the joint motor can exert, defaults to 0.0.
	 * @param motorSpeed [optional] The target speed of the joint motor, defaults to 0.0.
	 * @param frequency [optional] The frequency at which the joint should be stiff, defaults to 2.0.
	 * @param damping [optional] The damping rate of the joint, defaults to 0.7.
	 * @returns The newly created wheel joint.
	 */
	wheel(
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		axisAngle: number,
		maxMotorTorque?: number,
		motorSpeed?: number,
		frequency?: number,
		damping?: number
	): MotorJoint;

	/**
	 * Creates a joint instance based on the given joint definition and item dictionary containing physics bodies to be connected by the joint.
	 * @param def The joint definition.
	 * @param itemDict The dictionary containing all the bodies and other required items.
	 * @returns The newly created joint.
	 */
	(this: void, def: JointDef, itemDict: Dictionary): Joint;
}

const jointClass: JointClass;
export {jointClass as Joint};

/**
 * An enumeration for texture wrapping modes.
 */
export const enum TextureWrap {
	None = "None",
	Mirror = "Mirror",
	Clamp = "Clamp",
	Border = "Border",
}

/**
 * An enumeration for texture filtering modes.
 */
export const enum TextureFilter {
	None = "None",
	Point = "Point",
	Anisotropic = "Anisotropic",
}

/** The Sprite class to render texture in game scene tree hierarchy. */
class Sprite extends Node {
	private constructor();

	/**
	 * Whether the depth buffer should be written to when rendering the sprite (default is false).
	 */
	depthWrite: boolean;

	/**
	 * The alpha reference value for alpha testing. Pixels with alpha values less than or equal to this value will be discarded.
	 * Only works with `sprite.effect = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritealphatest")`.
	 */
	alphaRef: number;

	/**
	 * The texture rectangle for the sprite.
	 */
	textureRect: Rect;

	/**
	 * The blend function for the sprite.
	 */
	blendFunc: BlendFunc;

	/**
	 * The sprite shader effect.
	 */
	effect: SpriteEffect;

	/**
	 * The texture for the sprite.
	 */
	texture: Texture2D;

	/**
	 * The texture wrapping mode for the U (horizontal) axis.
	 */
	uwrap: TextureWrap;

	/**
	 * The texture wrapping mode for the V (vertical) axis.
	 */
	vwrap: TextureWrap;

	/**
	 * The texture filtering mode for the sprite.
	 */
	filter: TextureFilter;
}

export namespace Sprite {
	export type Type = Sprite;
}

/**
 * A class used for creating `Sprite` object.
 */
interface SpriteClass {
	/**
	 * Gets the clip names and rectangles from the clip file.
	 * @param clipFile The clip file name to load, should end with ".clip".
	 * @returns A table containing the clip names and rectangles.
	 */
	getClips(clipFile: string): LuaTable<string, Rect> | null;

	/**
	 * A method for creating Sprite object.
	 * @param clipStr The string containing format for loading a texture file.
	 * Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.
	 * @returns A new instance of the Sprite class.
	 */
	(this: void, clipStr: string): Sprite | null;

	/**
	 * A method for creating Sprite object.
	 * @returns A new instance of the Sprite class.
	 */
	(this: void): Sprite;

	/**
	 * A method for creating Sprite object.
	 * @param texture The texture to be used for the sprite.
	 * @param textureRect [optional] The rectangle defining the portion of the texture to use for the sprite, if not provided, the whole texture will be used for rendering.
	 * @returns A new instance of the Sprite class.
	 */
	(this: void, texture: Texture2D, textureRect?: Rect): Sprite;
}

const spriteClass: SpriteClass;
export {spriteClass as Sprite};

/**
 * Enumeration for text alignment setting.
 */
export const enum TextAlign {
	/**
	 * Text alignment to the left.
	 */
	Left = "Left",

	/**
	 * Text alignment to the center.
	 */
	Center = "Center",

	/**
	 * Text alignment to the right.
	 */
	Right = "Right",
}

/**
 * A node for rendering text using a TrueType font.
 */
class Label extends Node {
	private constructor();

	/**
	 * The alpha threshold value. Pixels with alpha values below this value will not be drawn.
	 * Only works with `label.effect = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritealphatest")`.
	 */
	alphaRef: number;

	/**
	 * The width of the text used for text wrapping.
	 * Set to `Label.AutomaticWidth` to disable wrapping.
	 * Default is `Label.AutomaticWidth`.
	 */
	textWidth: number;

	/**
	 * The gap in pixels between lines of text.
	 */
	lineGap: number;

	/**
	 * The gap in pixels between characters.
	 */
	spacing: number;

	/**
	 * The color of the outline, only works with SDF label.
	 */
	outlineColor: Color;

	/**
	 * The width of the outline, only works with SDF label.
	 */
	outlineWidth: number;

	/**
	 * The smooth value of the text, only works with SDF label, default is (0.7, 0.7).
	 */
	smooth: Vec2;

	/**
	 * The text to be rendered.
	 */
	text: string;

	/**
	 * The blend function used to render the text.
	 */
	blendFunc: BlendFunc;

	/**
	 * Whether depth writing is enabled. (Default is false)
	 */
	depthWrite: boolean;

	/**
	 * Whether the label is using batched rendering.
	 * When using batched rendering, the `label.getCharacter()` function will no longer work, and getting better rendering performance. (Default is true)
	 */
	batched: boolean;

	/**
	 * The sprite effect used to render the text.
	 */
	effect: SpriteEffect;

	/**
	 * The text alignment setting. (Default is `TextAlign.Center`)
	 */
	alignment: TextAlign;

	/**
	 * The number of characters in the label.
	 */
	readonly characterCount: number;

	/**
	 * Returns the sprite for the character at the specified index.
	 * @param index The index of the character sprite to retrieve.
	 * @returns The sprite for the character, or `null` if the index is out of range.
	 */
	getCharacter(index: number): Sprite | null;
}

export namespace Label {
	export type Type = Label;
}

/**
* A class for creating Label object.
*/
interface LabelClass {
	/**
	 * The value to use for automatic width calculation.
	 */
	readonly AutomaticWidth: number;

	/**
	 * Creates a new Label object with the specified font string.
	 * @param fontStr The font string to use for the label. Should be in the format "fontName;fontSize;sdf", where `sdf` should be "true" or "false" and can be omitted as default is false.
	 * @returns The new Label object. Returns `null` if the font could not be loaded.
	 */
	(this: void, fontStr: string): Label | null;

	/**
	 * Creates a new Label object with the specified font name and font size.
	 * @param fontName The name of the font to use for the label. Can be a font file path with or without a file extension.
	 * @param fontSize The size of the font to use for the label.
	 * @param sdf [optional] Whether to use SDF rendering or not. With SDF rendering, the outline feature will be enabled. (Default is false)
	 * @returns The new Label object. Returns `null` if the font could not be loaded.
	 */
	(this: void, fontName: string, fontSize: number, sdf?: boolean): Label | null;
}

const labelClass: LabelClass;
export {labelClass as Label};

/**
 * A class provides functionality for drawing lines using vertices.
 */
class Line extends Node {
	private constructor();

	/**
	 * Whether the depth should be written. (Default is false)
	 */
	depthWrite: boolean;

	/**
	 * Blend function used for rendering the line.
	 */
	blendFunc: BlendFunc;

	/**
	 * Adds vertices to the line.
	 * @param verts List of vertices to add to the line.
	 * @param color Color of the line (default is opaque white).
	 */
	add(verts: Vec2[], color?: Color): void;

	/**
	 * Sets vertices of the line.
	 * @param verts List of vertices to set to the line.
	 * @param color Color of the line (default is opaque white).
	 */
	set(verts: Vec2[], color?: Color): void;

	/**
	 * Clears all the vertices of the line.
	 */
	clear(): void;
}

export namespace Line {
	export type Type = Line;
}

/**
 * A class for creating Line objects.
 */
interface LineClass {
	/**
	 * Creates and returns a new Line object.
	 * @param verts Table of vertices to add to the line.
	 * @param color Color of the line (default is opaque white).
	 * @returns Line object.
	 */
	(this: void, verts: Vec2[], color?: Color): Line;

	/**
	 * Creates and returns a new empty Line object.
	 * @returns Line object.
	 */
	(this: void): Line;
}

const lineClass: LineClass;
export {lineClass as Line}

/**
 * This interface is used for managing touch events for children nodes in a given area.
 * The menu will swallow touches that hit children nodes.
 * Only one child node can receive the first touch event; multi-touches that come later for other children nodes will be ignored.
 */
class Menu extends Node {
	private constructor();

	/**
	 * Whether the menu is currently enabled or disabled.
	 */
	enabled: boolean;
}

export namespace Menu {
	export type Type = Menu;
}

/**
* A class for creating Menu objects.
*/
interface MenuClass {
	/**
	 * Creates a new instance of `Menu` with the specified width and height.
	 * @param width The width of the Menu node.
	 * @param height The height of the Menu node.
	 * @returns A new Menu node object.
	 */
	(this: void, width: number, height: number): Menu;

	/**
	 * Creates a new instance of `Menu` with 0 width and 0 height.
	 * A menu with zero size will handle full screen touches for children nodes.
	 * @returns A new Menu node object.
	 */
	(this: void): Menu;
}

const menuClass: MenuClass;
export {menuClass as Menu};

/**
 * A simple reinforcement learning framework that can be used to learn optimal policies for Markov decision processes using Q-learning.
 * Q-learning is a model-free reinforcement learning algorithm that learns an optimal action-value function from experience by repeatedly updating estimates of the Q-value of state-action pairs.
 */
class QLearner extends Object {
	private constructor();

	/**
	 * The matrix that stores state, action, and Q-value.
	 */
	matrix: [state: number, action: number, QValue: number][];

	/**
	 * Update Q-value for a state-action pair based on received reward.
	 * @param state Representing the state.
	 * @param action Representing the action. Must be greater than 0.
	 * @param reward Representing the reward received for the action in the state.
	 */
	update(state: number, action: number, reward: number): void;

	/**
	 * Returns the best action for a given state based on the current Q-values.
	 * @param state The current state.
	 * @returns The action with the highest Q-value for the given state. Returns 0 if no action is available.
	 */
	getBestAction(state: number): number;

	/**
	 * Load Q-values from a matrix of state-action pairs.
	 * @param values The matrix of state-action pairs to load.
	 */
	load(values: [state: number, action: number, QValue: number][]): void;
}

export namespace QLearner {
	export type Type = QLearner;
}

/**
 * A class for creating QLearner objects.
 */
interface QLearnerClass {
	/**
	 * Construct a state from given hints and condition values.
	 * @param hints Representing the max number of possible hints. For example, if there are two conditions, and each condition has 3 possible values (0, 1, 2), then the hints array is {3, 3}.
	 * @param values The condition values as discrete values.
	 * @returns The packed state value.
	 */
	pack(hints: number[], values: number[]): number;

	/**
	 * Deconstruct a state from given hints to get condition values.
	 * @param hints Representing the max number of possible hints. For example, if there are two conditions, and each condition has 3 possible values (0, 1, 2), then the hints array is {3, 3}.
	 * @param state The state integer to unpack.
	 * @returns The condition values as discrete values.
	 */
	unpack(hints: number[], state: number): number[];

	/**
	 * Create a new QLearner object with optional parameters for gamma, alpha, and maxQ.
	 * @param gamma The discount factor for future rewards. Defaults to 0.5.
	 * @param alpha The learning rate for updating Q-values. Defaults to 0.5.
	 * @param maxQ The maximum Q-value. Defaults to 100.0.
	 * @returns The newly created QLearner object.
	 */
	(
		this: void,
		gamma?: number,
		alpha?: number,
		maxQ?: number
	): QLearner;
}

/**
 * Enumeration for comparison operators.
 */
type MLOperator = "return" | "<=" | ">" | "==";

/**
 * A class for machine learning algorithms.
 */
class ML {
	/**
	 * A function that takes CSV data as input and applies the C4.5 machine learning algorithm to build a decision tree model asynchronously.
	 * C4.5 is a decision tree algorithm that uses information gain to select the best attribute to split the data at each node of the tree. The resulting decision tree can be used to make predictions on new data.
	 * @param csvData The CSV training data for building the decision tree using delimiter `,`.
	 * @param maxDepth The maximum depth of the generated decision tree. Set to 0 to prevent limiting the generated tree depth.
	 * @param handler The callback function to be called for each node of the generated decision tree.
	 * @returns The accuracy of the decision tree on the training data. And an error message if an error occurred during building of the decision tree.
	 */
	BuildDecisionTreeAsync(
		this: void,
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
	 * A field for accessing QLearner class.
	 */
	QLearner: QLearnerClass;
}

const ml: ML;
export {ml as ML};

/**
 * Represents a particle system node that emits and animates particles.
 */
class Particle extends Node {
	private constructor();

	/** Whether the particle system is active. */
	readonly active: boolean;

	/** Starts emitting particles. */
	start(): void;

	/**
	 * Stops emitting particles and waits for all active particles to end their lives.
	 */
	stop(): void;

	/**
	 * Registers a callback function for when the particle system ends.
	 * Triggered after a Particle node started a stop action and then all the active particles end their lives.
	 * @param callback The callback function for when the particle system ends.
	 */
	onFinished(callback: (this: void) => void): void;
}

export namespace Particle {
	export type Type = Particle;
}

/**
 * A class that can create new Particle objects.
 */
interface ParticleClass {
	/**
	 * Creates a new Particle object from a particle system definition file.
	 * @param filename The file path of the particle system definition file.
	 * @returns A new Particle object. Returns `null` if the particle system file could not be loaded.
	 */
	(this: void, filename: string): Particle | null;
}

const particleClass: ParticleClass;
export {particleClass as Particle};

/** Helper class for file path operations. */
interface Path {
	/**
	 * Gets script running path from a module name.
	 * @param moduleName The input module name.
	 * @returns The module path for script searching.
	 */
	getScriptPath(moduleName: string): string;

	/**
	 * Input: /a/b/c.TXT output: txt
	 * @param path The input file path.
	 * @returns The input file's extension.
	 */
	getExt(path: string): string;

	/**
	 * Input: /a/b/c.TXT output: /a/b
	 * @param path The input file path.
	 * @returns The input file's parent path.
	 */
	getPath(path: string): string;

	/**
	 * Input: /a/b/c.TXT output: c
	 * @param path The input file path.
	 * @returns The input file's name without extension.
	 */
	getName(path: string): string;

	/**
	 * Input: /a/b/c.TXT output: c.TXT
	 * @param path The input file path.
	 * @returns The input file's name.
	 */
	getFilename(path: string): string;

	/**
	 * Input: /a/b/c.TXT, base: /a output: b/c.TXT
	 * @param path The input file path.
	 * @param base The target file path.
	 * @returns The relative from input file to target file.
	 */
	getRelative(path: string, base: string): string;

	/** Input: /a/b/c.TXT, lua output: /a/b/c.lua
	 * @param path The input file path.
	 * @param newExt The new file extension to add to file path.
	 * @returns The new file path.
	 */
	replaceExt(path: string, newExt: string): string;

	/** Input: /a/b/c.TXT, d output: /a/b/d.TXT
	 * @param path The input file path.
	 * @param newFile The new filename to replace.
	 * @returns The new file path.
	 */
	replaceFilename(path: string, newFile: string): string;

	/** Input: a, b, c.TXT output: a/b/c.TXT
	 * @param segments The segments to be joined as a new file path.
	 * @returns The new file path.
	 */
	(this: void, ...segments: string[]): string;
}

const path: Path;
export {path as Path};

/**
 * A class for profiling functions.
 */
interface ProfilerClass {
	/**
	 * The name of the profiling event.
	 */
	EventName: string;

	/**
	 * The current level of profiling.
	 */
	level: number;

	/**
	 * Calls a function and returns the amount of time it took to execute.
	 * @param funcForProfiling The function to profile.
	 * @returns The amount of time it took to execute the function.
	 * @example
	 * const time = profiler(funcForProfiling);
	 */
	(this: void, funcForProfiling: (this: void) => number): number;
}

const profiler: ProfilerClass;
export {profiler as Profiler};

/**
 * A RenderTarget is a node with a buffer that allows you to render a Node into a texture.
 */
class RenderTarget {
	private constructor();

	/**
	 * The width of the rendering target.
	 */
	readonly width: number;

	/**
	 * The height of the rendering target.
	 */
	readonly height: number;

	/**
	 * The texture generated by the rendering target.
	 */
	readonly texture: Texture2D;

	/**
	 * The camera used for rendering the scene.
	 */
	camera: Camera;

	/**
	 * Renders a node to the target without replacing its previous contents.
	 * @param target The node to be rendered onto the render target.
	 */
	render(target: Node): void;

	/**
	 * Clears the previous color, depth, and stencil values on the render target.
	 * @param color The clear color used to clear the render target.
	 * @param depth (optional) The value used to clear the depth buffer of the render target. Default is 1.
	 * @param stencil (optional) The value used to clear the stencil buffer of the render target. Default is 0.
	 */
	renderWithClear(color: Color, depth?: number, stencil?: number): void;

	/**
	 * Renders a node to the target after clearing the previous color, depth, and stencil values on it.
	 * @param target The node to be rendered onto the render target.
	 * @param color The clear color used to clear the render target.
	 * @param depth (optional) The value used to clear the depth buffer of the render target. Default is 1.
	 * @param stencil (optional) The value used to clear the stencil buffer of the render target. Default is 0.
	 */
	renderWithClear(target: Node, color: Color, depth?: number, stencil?: number): void;

	/**
	 * Saves the contents of the render target to a PNG file asynchronously.
	 * @param filename The name of the file to save the contents to.
	 */
	saveAsync(filename: string): void;
}

/**
 * A class for creating RenderTarget objects.
 */
interface RenderTargetClass {
	/**
	 * Creates a new RenderTarget object with the given width and height.
	 * @param width The width of the render target.
	 * @param height The height of the render target.
	 * @returns The created render target.
	 */
	(this: void, width: number, height: number): RenderTarget;
}

const renderTargetClass: RenderTargetClass;
export {renderTargetClass as RenderTarget};

/**
 * A class used for Scalable Vector Graphics rendering.
 */
class SVG extends Object {
	private constructor();

	/**
	 * The width of the SVG object.
	 */
	readonly width: number;

	/**
	 * The height of the SVG object.
	 */
	readonly height: number;

	/**
	 * Renders the SVG object, should be called every frame for the render result to appear.
	 */
	render(): void;
}

export namespace SVG {
	export type Type = SVG;
}

/**
 * A class for creating SVG objects.
 */
interface SVGClass {
	/**
	 * Creates a new SVG object from the specified SVG file.
	 * @param filename The path to the SVG format file.
	 * @returns The created SVG object.
	 */
	(this: void, filename: string): SVG;
}

const svgClass: SVGClass;
export {svgClass as SVG};

/**
 * A node for rendering vector graphics.
 */
class VGNode extends Node {
	private constructor();

	/**
	 * The surface of the node for displaying frame buffer texture that contains vector graphics.
	 * You can get the texture of the surface by calling `vgNode.surface.texture`.
	 */
	surface: Sprite;

	/**
	 * The function for rendering vector graphics.
	 * @param func The closure function for rendering vector graphics.
	 * You can do the rendering operations inside this closure.
	 * @example
	 * ```
	 * vgNode.render(() => {
	 * 	nvg.BeginPath();
	 * 	nvg.Rect(0, 0, 100, 100);
	 * 	nvg.ClosePath();
	 * 	nvg.FillColor(Color(255, 0, 0, 255));
	 * 	nvg.Fill();
	 * });
	 * ```
	 */
	render(func: (this: void) => void): void;
}

export namespace VGNode {
	export type Type = VGNode;
}

/**
 * A class for creating VGNode objects.
 */
interface VGNodeClass {
	/**
	 * Creates a new VGNode object with the specified width and height.
	 * @param width The width of the node's frame buffer texture.
	 * @param height The height of the node's frame buffer texture.
	 * @param scale The scale factor of the VGNode.
	 * @param edgeAA The edge anti-aliasing factor of the VGNode.
	 * @returns The created VGNode object.
	 */
	(this: void, width: number, height: number, scale?: number, edgeAA?: number): VGNode;
}

const vgNodeClass: VGNodeClass;
export {vgNodeClass as VGNode};

/**
 * An interface that provides access to the 3D graphic view.
 */
class View {
	private constructor();

	/** The size of the view in pixels. */
	size: Size;

	/** The standard distance of the view from the origin. */
	standardDistance: number;

	/** The aspect ratio of the view. */
	aspectRatio: number;

	/** The distance to the near clipping plane. */
	nearPlaneDistance: number;

	/** The distance to the far clipping plane. */
	farPlaneDistance: number;

	/** The field of view of the view in degrees. */
	fieldOfView: number;

	/** The scale factor of the view. */
	scale: number;

	/** The post effect applied to the view. */
	postEffect: SpriteEffect;

	/** Whether or not vertical sync is enabled. */
	vsync: boolean;
}

const view: View;
export {view as View};

type VGPaintType = BasicType<"VGPaint">;

export namespace VGPaint {
	export type Type = VGPaintType;
}

/**
 * The filter types that can be applied to the audio bus.
 */
export const enum AudioFilter {
	None = "",
	/**
	 * The bass boost filter.
	 * param0: WET, float, min: 0, max: 1
	 * param1: BOOST, float, min: 0, max: 10
	 */
	BassBoost = "BassBoost",
	/**
	 * The biquad resonant filter.
	 * param0: WET, float, min: 0, max: 1
	 * param1: TYPE, int, values: 0 - LOWPASS, 1 - HIGHPASS, 2 - BANDPASS
	 * param2: FREQUENCY, float, min: 10, max: 8000
	 * param3: RESONANCE, float, min: 0.1, max: 20
	 */
	BiquadResonant = "BiquadResonant",
	/**
	 * The DC removal filter.
	 * param0: WET, float, min: 0, max: 1
	 */
	DCRemoval = "DCRemoval",
	/**
	 * The echo filter.
	 * param0: WET, float, min: 0, max: 1
	 * param1: DELAY, float, min: 0, max: 1
	 * param2: DECAY, float, min: 0, max: 1
	 * param3: FILTER, float, min: 0, max: 1
	 */
	Echo = "Echo",
	/**
	 * The equalizer filter.
	 * param0: WET, float, min: 0, max: 1
	 * param1: BAND0, float, min: 0, max: 4
	 * param2: BAND1, float, min: 0, max: 4
	 * param3: BAND2, float, min: 0, max: 4
	 * param4: BAND3, float, min: 0, max: 4
	 * param5: BAND4, float, min: 0, max: 4
	 * param6: BAND5, float, min: 0, max: 4
	 * param7: BAND6, float, min: 0, max: 4
	 * param8: BAND7, float, min: 0, max: 4
	 */
	Eq = "Eq",
	/**
	 * The FFT filter.
	 * param0: WET, float, min: 0, max: 1
	 */
	FFT = "FFT",
	/**
	 * The flanger filter.
	 * param0: WET, float, min: 0, max: 1
	 * param1: DELAY, float, min: 0.001, max: 0.1
	 * param2: FREQ, float, min: 0.001, max: 100
	 */
	Flanger = "Flanger",
	/**
	 * The freeverb filter.
	 * param0: WET, float, min: 0, max: 1
	 * param1: FREEZE, float, min: 0, max: 1
	 * param2: ROOMSIZE, float, min: 0, max: 1
	 * param3: DAMP, float, min: 0, max: 1
	 * param4: WIDTH, float, min: 0, max: 1
	 */
	FreeVerb = "FreeVerb",
	/**
	 * The lofi filter.
	 * param0: WET, float, min: 0, max: 1
	 * param1: SAMPLE_RATE, float, min: 100, max: 22000
	 * param2: BITDEPTH, float, min: 0.5, max: 16
	 */
	Lofi = "Lofi",
	/**
	 * The robotize filter.
	 * param0: WET, float, min: 0, max: 1
	 * param1: FREQ, float, min: 0.1, max: 100
	 * param2: WAVE, float, min: 0, max: 6
	 */
	Robotize = "Robotize",
	/**
	 * The wave shaper filter.
	 * param0: WET, float, min: 0, max: 1
	 * param1: AMOUNT, float, min: -1, max: 1
	 */
	WaveShaper = "WaveShaper",
}

/**
 * A class that represents an audio bus.
 */
class AudioBus extends Object {

	private constructor();

	/** The volume of the audio bus. The value is between 0.0 and 1.0. */
	volume: number;

	/** The pan of the audio bus. The value is between -1.0 and 1.0. */
	pan: number;

	/** The play speed of the audio bus. The value is 1.0 for normal speed, 0.5 for half speed, and 2.0 for double speed. */
	playSpeed: number;

	/**
	 * Fades the volume of the audio bus to the specified value.
	 * @param time The time to fade the volume (in seconds).
	 * @param toVolume The value to fade the volume to.
	 */
	fadeVolume(time: number, toVolume: number): void;

	/**
	 * Fades the pan of the audio bus to the specified value.
	 * @param time The time to fade the pan (in seconds).
	 * @param toPan The value to fade the pan to.
	 */
	fadePan(time: number, toPan: number): void;

	/**
	 * Fades the play speed of the audio bus to the specified value.
	 * @param time The time to fade the play speed (in seconds).
	 * @param toPlaySpeed The value to fade the play speed to.
	 */
	fadePlaySpeed(time: number, toPlaySpeed: number): void;

	/**
	 * Sets the filter of the audio bus.
	 * @param index The index of the filter.
	 * @param name The type of the filter.
	 */
	setFilter(index: number, name: AudioFilter): void;

	/**
	 * Sets the filter parameter of the audio bus.
	 * @param index The index of the filter.
	 * @param attrId The attribute ID of the filter parameter.
	 * @param value The value of the filter parameter.
	 */
	setFilterParameter(index: number, attrId: number, value: number): void;

	/**
	 * Gets the filter parameter of the audio bus.
	 * @param index The index of the filter.
	 * @param attrId The attribute ID of the filter parameter.
	 * @returns The value of the filter parameter.
	 */
	getFilterParameter(index: number, attrId: number): number;

	/**
	 * Fades the filter parameter of the audio bus to the specified value.
	 * @param index The index of the filter.
	 * @param attrId The attribute ID of the filter parameter.
	 * @param to The value to fade the filter parameter to.
	 * @param time The time to fade the filter parameter (in seconds).
	 */
	fadeFilterParameter(index: number, attrId: number, to: number, time: number): void;
}

export namespace AudioBus {
	export type Type = AudioBus;
}

/**
 * A class for creating AudioBus objects.
 */
interface AudioBusClass {
	/**
	 * Creates a new AudioBus object.
	 * @returns The created AudioBus object.
	 */
	(this: void): AudioBus;
}

const audioBusClass: AudioBusClass;
export {audioBusClass as AudioBus};

/**
 * The attenuation model of the 3D audio source.
 */
export const enum AttenuationModel {
	NoAttenuation = "NoAttenuation",
	InverseDistance = "InverseDistance",
	LinearDistance = "LinearDistance",
	ExponentialDistance = "ExponentialDistance",
}

/**
 * A node that represents an audio source.
 */
class AudioSource extends Node {

	/**
	 * The volume of the audio source. The value is between 0.0 and 1.0.
	 */
	volume: number;

	/**
	 * The pan of the audio source. The value is between -1.0 and 1.0.
	 */
	pan: number;

	/**
	 * Whether the audio source is looping.
	 */
	looping: boolean;

	/**
	 * Whether the audio source is playing.
	 */
	playing: boolean;

	/**
	 * Seeks to the specified time of the audio source.
	 * @param startTime The time to seek to.
	 */
	seek(startTime: number): void;

	/**
	 * Schedules the stop of the audio source.
	 * @param timeToStop The time to stop.
	 */
	scheduleStop(timeToStop: number): void;

	/**
	 * Stops the audio source.
	 * @param fadeTime The time to fade out. Default is 0 seconds.
	 */
	stop(fadeTime?: number): void;

	/**
	 * Plays the audio source.
	 * @param delayTime The delay time before playing. Default is 0 seconds.
	 * @returns Whether the audio source is playing.
	 */
	play(delayTime?: number): boolean;

	/**
	 * Plays the audio source as background audio.
	 * @returns Whether the audio source is playing.
	 */
	playBackground(): boolean;

	/**
	 * Plays the audio source as 3D audio.
	 * @param delayTime The delay time before playing. Default is 0 seconds.
	 * @returns Whether the audio source is playing.
	 */
	play3D(delayTime?: number): boolean;

	/**
	 * Sets the protected state of the audio source. If the audio source is protected, it will not be stopped when there is not enough voice.
	 * @param protected The state to set.
	 */
	setProtected(protected: boolean): void;

	/**
	 * Sets the loop point of the audio source. The audio source will loop play from the specified time.
	 * @param loopStartTime The time to loop play.
	 */
	setLoopPoint(loopStartTime: number): void;

	/**
	 * Sets the speed of the 3D audio source.
	 * @param vx The x-axis speed.
	 * @param vy The y-axis speed.
	 * @param vz The z-axis speed.
	 */
	setVelocity(vx: number, vy: number, vz: number): void;

	/**
	 * Sets the minimum and maximum distance of the 3D audio source.
	 * @param min The minimum distance.
	 * @param max The maximum distance.
	 */
	setMinMaxDistance(min: number, max: number): void;

	/**
	 * Sets the attenuation model of the 3D audio source.
	 * @param model The attenuation model.
	 * @param factor The attenuation factor.
	 */
	setAttenuation(model: AttenuationModel, factor: number): void;

	/**
	 * Sets the Doppler effect factor of the 3D audio source.
	 * @param factor The Doppler effect factor.
	 */
	setDopplerFactor(factor: number): void;
}

export namespace AudioSource {
	export type Type = AudioSource;
}

/**
 * A class for creating AudioSource objects.
 */
interface AudioSourceClass {
	/**
	 * Creates a new AudioSource object.
	 * @param filename The path to the audio file.
	 * @param autoRemove [optional] Whether to remove the audio source when it stops. Defaults to `true`.
	 * @param bus [optional] The bus to play the audio source. Defaults to `nil`.
	 * @returns Created AudioSource node. If the audio file is not loaded, it will return null.
	 */
	(this: void, filename: string, autoRemove?: boolean, bus?: AudioBus): AudioSource | null;
}

const audioSourceClass: AudioSourceClass;
export {audioSourceClass as AudioSource};

export const enum TypeName {
	Size = "Size",
	Vec2 = "Vec2",
	Rect = "Rect",
	Color3 = "Color3",
	Color = "Color",
	Object = "Object",
	Action = "Action",
	Array = "Array",
	BlendFunc = "BlendFunc",
	Scheduler = "Scheduler",
	Dictionary = "Dictionary",
	Camera = "Camera",
	Camera2D = "Camera2D",
	CameraOtho = "CameraOtho",
	Pass = "Pass",
	Effect = "Effect",
	SpriteEffect = "SpriteEffect",
	Node = "Node",
	RenderTarget = "RenderTarget",
	Buffer = "Buffer",
	ClipNode = "ClipNode",
	Playable = "Playable",
	DragonBone = "DragonBone",
	Spine = "Spine",
	Model = "Model",
	DrawNode = "DrawNode",
	Entity = "Entity",
	Group = "Group",
	Texture2D = "Texture2D",
	Grid = "Grid",
	Sensor = "Sensor",
	BodyDef = "BodyDef",
	Body = "Body",
	PhysicsWorld = "PhysicsWorld",
	Joint = "Joint",
	MotorJoint = "MotorJoint",
	MoveJoint = "MoveJoint",
	Sprite = "Sprite",
	Label = "Label",
	Line = "Line",
	Menu = "Menu",
	QLearner = "QLearner",
	Particle = "Particle",
	SVG = "SVG",
	VGNode = "VGNode",
	AlignNode = "AlignNode",
	EffekNode = "EffekNode",
	TileNode = "TileNode",
	AudioBus = "AudioBus",
	AudioSource = "AudioSource",
}

export interface TypeMap {
	[TypeName.Size]: Size;
	[TypeName.Vec2]: Vec2;
	[TypeName.Rect]: Rect;
	[TypeName.Color3]: Color3;
	[TypeName.Color]: Color;
	[TypeName.Object]: Object;
	[TypeName.Action]: Action;
	[TypeName.Array]: Array;
	[TypeName.BlendFunc]: BlendFunc;
	[TypeName.Scheduler]: Scheduler;
	[TypeName.Dictionary]: Dictionary;
	[TypeName.Camera]: Camera;
	[TypeName.Camera2D]: Camera2D;
	[TypeName.CameraOtho]: CameraOtho;
	[TypeName.Pass]: Pass;
	[TypeName.Effect]: Effect;
	[TypeName.SpriteEffect]: SpriteEffect;
	[TypeName.Node]: Node;
	[TypeName.RenderTarget]: RenderTarget;
	[TypeName.Buffer]: Buffer;
	[TypeName.ClipNode]: ClipNode;
	[TypeName.Playable]: Playable;
	[TypeName.DragonBone]: DragonBone;
	[TypeName.Spine]: Spine;
	[TypeName.Model]: Model;
	[TypeName.DrawNode]: DrawNode;
	[TypeName.Entity]: Entity;
	[TypeName.Group]: Group;
	[TypeName.Texture2D]: Texture2D;
	[TypeName.Grid]: Grid;
	[TypeName.Sensor]: Sensor;
	[TypeName.BodyDef]: BodyDef;
	[TypeName.Body]: Body;
	[TypeName.PhysicsWorld]: PhysicsWorld;
	[TypeName.Joint]: Joint;
	[TypeName.MotorJoint]: MotorJoint;
	[TypeName.MoveJoint]: MoveJoint;
	[TypeName.Sprite]: Sprite;
	[TypeName.Label]: Label;
	[TypeName.Line]: Line;
	[TypeName.Menu]: Menu;
	[TypeName.QLearner]: QLearner;
	[TypeName.Particle]: Particle;
	[TypeName.SVG]: SVG;
	[TypeName.VGNode]: VGNode;
	[TypeName.AlignNode]: AlignNode;
	[TypeName.EffekNode]: EffekNode;
	[TypeName.TileNode]: TileNode;
	[TypeName.AudioBus]: AudioBus;
	[TypeName.AudioSource]: AudioSource;
}

/**
 * The `tolua` object provides utilities for interfacing between C++ and Lua.
 */
export interface tolua {
	/**
	 * Returns the C++ object type of a Lua object.
	 * @param item The Lua object to get the type of.
	 * @returns The C++ object type.
	 */
	type(this: void, item: any): string;

	/**
	 * Attempts to cast a Lua object to a C++ type object.
	 * @param item The Lua object to cast.
	 * @param name The C++ object type name .
	 * @returns The target object, or `null` if the cast fails.
	 */
	cast<k extends TypeName>(this: void, item: any, name: k): TypeMap[typeof name] | null;

	/**
	 * Gets the class object for a given class name.
	 * @param className The name of the class to get the table for.
	 * @returns The class table, or `null` if the class does not exist.
	 */
	class(this: void, className: string): { [key: string | number]: any } | null;

	/**
	 * Sets the peer table for an object. A peer table is a table referenced by a Lua userdata providing custom fields for this userdata object.
	 * @param obj The object to set the peer table for.
	 * @param data The table to use as the peer table.
	 */
	setpeer(this: void, obj: Object, data: { [key: string | number]: any }): void;

	/**
	 * Gets the peer table for an object. A peer table is a table referenced by a Lua userdata providing custom fields for this userdata object.
	 * @param obj The object to get the peer table for.
	 * @returns The peer table, or `null` if the object has no peer table.
	 */
	getpeer(this: void, obj: Object): { [key: string | number]: any } | null;
}

export const tolua: tolua;

/**
 * The HTTP request object.
 */
interface Request {
	/** A table containing the request headers. */
	headers: {string: string}
	/** The body of the request. */
	body: LuaTable | string
}

/**
 * Represents an HTTP server that can handle requests and serve files.
 */
interface HttpServer {
	/**
	 * The local IP address of the server.
	 */
	readonly localIP: string;
	/**
	 * The number of active WebSocket connections.
	 */
	readonly wsConnectionCount: number;
	/**
	 * The path to the server's root static files directory.
	 */
	wwwPath: string
	/**
	 * Starts the HTTP server on the specified port.
	 * @param port The port number to start the server on.
	 * @returns A boolean value indicating whether the server was started successfully.
	 */
	start(port: number): boolean;
	/**
	 * Starts the WebSocket server on the specified port.
	 * @param port The port number to start the server on.
	 * @returns A boolean value indicating whether the server was started successfully.
	 */
	startWS(port: number): boolean;
	/**
	 * Registers a handler function for POST requests.
	 * @param pattern The URL pattern to match.
	 * @param handler The handler function to call when the pattern is matched. The function should return a LuaTable containing the response data which can be serialized to JSON.
	 */
	post(
		pattern: string,
		handler: (this: void, req: Request) => LuaTable
	): void;
	/**
	 * Registers a handler function in a coroutine for POST requests.
	 * @param pattern The URL pattern to match.
	 * @param handler The handler function to call when the pattern is matched. The function should return a LuaTable containing the response data which can be serialized to JSON. And the function will be run in a coroutine.
	 */
	postSchedule(
		pattern: string,
		handler: (this: void, req: Request) => LuaTable
	): void;
	/**
	 * Registers a handler function for multipart POST requests as file uploads.
	 * @param pattern The URL pattern to match.
	 * @param acceptHandler The handler function to call when a file is being uploaded. The function should return the filename to save the file as, or `null` to reject the file.
	 * @param doneHandler The handler function to call when the file upload is complete. The function should return `true` to accept the file, or `false` to reject it.
	 */
	upload(
		pattern: string,
		acceptHandler: (this: void, req: Request, filename: string) => string | null,
		doneHandler: (this: void, req: Request, filename: string) => boolean
	): void;
	/**
	 * Stops the servers, including HTTP and WebSocket servers.
	 */
	stop(): void;
}

const httpServer: HttpServer;
export {httpServer as HttpServer};

/**
 * Represents an HTTP client.
 */
interface HttpClient {
	/**
	 * Sends a POST request to the specified URL and returns the response body.
	 * @param url The URL to send the request to.
	 * @param json The JSON data to send in the request body.
	 * @param timeout [optional] The timeout in seconds for the request. Defaults to 5.
	 * @returns The response body text, or `null` if the request failed.
	 */
	postAsync(url: string, json: string, timeout?: number): string | null;
	/**
	 * Sends a POST request to the specified URL with custom headers and returns the response body.
	 * @param url The URL to send the request to.
	 * @param headers The headers to send with the request. Each header should be a string in the format "name: value".
	 * @param json The JSON data to send in the request body.
	 * @param timeout [optional] The timeout in seconds for the request. Defaults to 5.
	 * @param partCallback [optional] A callback function that is called periodically to get part of the response content. Returns `true` to stop the request.
	 * @returns The response body text, or `null` if the request failed.
	 */
	postAsync(url: string, headers: string[], json: string, timeout?: number, partCallback?: (this: void, data: string) => boolean): string | null;
	/**
	 * Sends a GET request to the specified URL and returns the response body.
	 * @param url The URL to send the request to.
	 * @param timeout [optional] The timeout in seconds for the request. Defaults to 5.
	 * @returns The response body text, or `null` if the request failed.
	 */
	getAsync(url: string, timeout?: number): string | null;
	/**
	 * Downloads a file asynchronously from the specified URL and saves it to the specified path. Should be run in a coroutine.
	 * @param url The URL of the file to download.
	 * @param fullPath The full path where the downloaded file should be saved.
	 * @param timeout [optional] The timeout in seconds for the download. Defaults to 30.
	 * @param progress [optional] A callback function that is called periodically to report the download progress.
	 * The function receives two parameters: current (the number of bytes downloaded so far)
	 * and total (the total number of bytes to be downloaded).
	 * If the function returns true, the download will be canceled.
	 * @returns A boolean value indicating whether the download was done successfully.
	 */
	downloadAsync(url: string, fullPath: string, timeout?: number, progress?: (this: void, current: number, total: number) => boolean): boolean;
}

const httpClient: HttpClient;
export {httpClient as HttpClient};

/**
 * Dora's JSON library.
 */
interface json {
	/**
	 * Parses the specified JSON text and returns the corresponding object.
	 * @param json The JSON text to parse.
	 * @param maxDepth The maximum depth to parse (default is 128).
	 * @returns The object representing the JSON data, or null with an error message if the JSON text is invalid.
	 */
	load(this: void, json: string, maxDepth?: number): LuaMultiReturn<[any, null]> | LuaMultiReturn<[null, string]>;
	/**
	 * Converts the specified object to JSON text.
	 * @param obj The object to convert.
	 * @returns The JSON text representing the object, or null with an error message if the object cannot be converted.
	 */
	dump(this: void, obj: object): LuaMultiReturn<[string, null]> | LuaMultiReturn<[null, string]>;
	/**
	 * Represents the JSON null value.
	 */
	["null"]: BasicType<"JsonNull">;
}

const jsn: json;
export {jsn as json};

/**
 * An interface that provides WASM related functions.
 */
interface Wasm {
	/**
	 * Executes the main WASM file (e.g. init.wasm).
	 * @param filename The name of the main WASM file.
	 */
	executeMainFile(filename: string): void;
	/**
	 * Executes the main WASM file (e.g. init.wasm) asynchronously.
	 * @param filename The name of the main WASM file.
	 * @returns Whether the main WASM file was executed successfully.
	 */
	executeMainFileAsync(filename: string): boolean;
	/**
	 * Builds the WASM file (e.g. init.wasm) from a Wa-lang project asynchronously.
	 * @param fullPath The full path of the Wa-lang project.
	 * @returns The WASM file building result.
	 * @example
	 * ```
	 * thread(() => {
	 * 	const result = Wasm.buildWaAsync("/path/to/wa-lang/project/");
	 * 	if (result === "") {
	 * 		print("Built successfully!")
	 * 	} else {
	 * 		print("Failed to build, due to " + result)
	 * 	}
	 * });
	 * ```
	 */
	buildWaAsync(fullPath: string): boolean;
	/**
	 * Formats a Wa-lang code file asynchronously.
	 * @param fullPath The full path of the Wa-lang code file.
	 * @returns The Wa-lang code file formatting result.
	 * @example
	 * ```
	 * thread(() => {
	 * 	const result = Wasm.formatWaAsync("/path/to/wa-lang/code/file.wa");
	 * 	if (result === "") {
	 * 		print("Failed to format")
	 * 	} else {
	 * 		print("Formated code:" + result)
	 * 	}
	 * });
	 * ```
	 */
	formatWaAsync(fullPath: string): boolean;
	/**
	 * Clears the running WASM module and stops the runtime.
	 */
	clear(): void;
}

const wasm: Wasm;
export {wasm as Wasm};

} // module "Dora"

/**
 * Inspect and print the internal information of the input parameter value in a formatted way.
 * @param args The values to inspect.
 */
declare function p(this: void, ...args: any[]): void;
