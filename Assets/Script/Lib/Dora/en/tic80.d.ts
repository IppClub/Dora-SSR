/////////////////////////////
/// TIC-80 API
/////////////////////////////

declare module "tic80" {
	/**
	 * Button IDs for all players.
	 * P1: 0-7, P2: 8-15, P3: 16-23, P4: 24-31
	 */
	export const enum Button {
		// Player 1
		P1_Up = 0,
		P1_Down = 1,
		P1_Left = 2,
		P1_Right = 3,
		P1_A = 4, // Z key
		P1_B = 5, // X key
		P1_X = 6, // A key
		P1_Y = 7, // S key

		// Player 2
		P2_Up = 8,
		P2_Down = 9,
		P2_Left = 10,
		P2_Right = 11,
		P2_A = 12,
		P2_B = 13,
		P2_X = 14,
		P2_Y = 15,

		// Player 3
		P3_Up = 16,
		P3_Down = 17,
		P3_Left = 18,
		P3_Right = 19,
		P3_A = 20,
		P3_B = 21,
		P3_X = 22,
		P3_Y = 23,

		// Player 4
		P4_Up = 24,
		P4_Down = 25,
		P4_Left = 26,
		P4_Right = 27,
		P4_A = 28,
		P4_B = 29,
		P4_X = 30,
		P4_Y = 31,
	}

	/**
	 * Keyboard key codes.
	 * Letters A-Z: 0-25, Numbers 0-9: 27-36, Special keys: 37-65
	 */
	export const enum Key {
		// Letters A-Z
		A = 0,
		B = 1,
		C = 2,
		D = 3,
		E = 4,
		F = 5,
		G = 6,
		H = 7,
		I = 8,
		J = 9,
		K = 10,
		L = 11,
		M = 12,
		N = 13,
		O = 14,
		P = 15,
		Q = 16,
		R = 17,
		S = 18,
		T = 19,
		U = 20,
		V = 21,
		W = 22,
		X = 23,
		Y = 24,
		Z = 25,

		// Numbers 0-9
		Num0 = 27,
		Num1 = 28,
		Num2 = 29,
		Num3 = 30,
		Num4 = 31,
		Num5 = 32,
		Num6 = 33,
		Num7 = 34,
		Num8 = 35,
		Num9 = 36,

		// Special keys
		Minus = 37,
		Equals = 38,
		LeftBracket = 39,
		RightBracket = 40,
		Backslash = 41,
		Semicolon = 42,
		Apostrophe = 43,
		Grave = 44,
		Comma = 45,
		Period = 46,
		Slash = 47,
		Space = 48,
		Tab = 49,
		Return = 50,
		Backspace = 51,
		Delete = 52,
		Insert = 53,
		PageUp = 54,
		PageDown = 55,
		Home = 56,
		End = 57,
		Up = 58,
		Down = 59,
		Left = 60,
		Right = 61,
		CapsLock = 62,
		Ctrl = 63,
		Shift = 64,
		Alt = 65,
	}

	/**
	 * Sync mask bit flags for the sync() function.
	 */
	export const enum SyncMask {
		Tiles = 1 << 0, // 1
		Sprites = 1 << 1, // 2
		Map = 1 << 2, // 4
		Sfx = 1 << 3, // 8
		Music = 1 << 4, // 16
		Palette = 1 << 5, // 32
		Flags = 1 << 6, // 64
		Screen = 1 << 7, // 128
	}

	/**
	 * Remap callback function type for map() function.
	 * @param tile The tile ID at position (x, y)
	 * @param x The X coordinate of the tile
	 * @param y The Y coordinate of the tile
	 * @returns A tuple containing [tile, flip?, rotate?]
	 */
	export type MapRemapCallback = (
		tile: number,
		x: number,
		y: number
	) => LuaMultiReturn<[number, number?, number?]>;

	/////////////////////////////
	/// Input Functions
	/////////////////////////////

	/**
	 * Checks if a button is currently pressed.
	 * @param id Optional button ID (0-31). If omitted, checks all buttons.
	 * @returns true if the button is pressed, false otherwise.
	 */
	export function btn(id?: Button): boolean;

	/**
	 * Checks if a button was just pressed (on this frame).
	 * @param id Optional button ID (0-31). If omitted, checks all buttons.
	 * @param hold Optional hold time in frames.
	 * @param period Optional period in frames for repeating.
	 * @returns true if the button was just pressed, false otherwise.
	 */
	export function btnp(id?: Button, hold?: number, period?: number): boolean;

	/**
	 * Checks if a keyboard key is currently pressed.
	 * @param code Optional key code. If omitted, checks all keys.
	 * @returns true if the key is pressed, false otherwise.
	 */
	export function key(code?: Key): boolean;

	/**
	 * Checks if a keyboard key was just pressed (on this frame).
	 * @param code Optional key code. If omitted, checks all keys.
	 * @param hold Optional hold time in frames.
	 * @param period Optional period in frames for repeating.
	 * @returns true if the key was just pressed, false otherwise.
	 */
	export function keyp(code?: Key, hold?: number, period?: number): boolean;

	/**
	 * Gets the current mouse state.
	 * @returns A tuple containing [x, y, left, middle, right, scrollx, scrolly]
	 */
	export function mouse(): LuaMultiReturn<
		[number, number, number, number, number, number, number]
	>;

	/////////////////////////////
	/// Graphics Functions
	/////////////////////////////

	/**
	 * Sets the drawing clip region.
	 * @param x The X coordinate of the clip region.
	 * @param y The Y coordinate of the clip region.
	 * @param w The width of the clip region.
	 * @param h The height of the clip region.
	 */
	export function clip(x: number, y: number, w: number, h: number): void;

	/**
	 * Clears the screen with a color.
	 * @param color Optional color index (default: 0).
	 */
	export function cls(color?: number): void;

	/**
	 * Draws a filled circle.
	 * @param x The X coordinate of the center.
	 * @param y The Y coordinate of the center.
	 * @param radius The radius of the circle.
	 * @param color The color index.
	 */
	export function circ(x: number, y: number, radius: number, color: number): void;

	/**
	 * Draws a circle outline.
	 * @param x The X coordinate of the center.
	 * @param y The Y coordinate of the center.
	 * @param radius The radius of the circle.
	 * @param color The color index.
	 */
	export function circb(
		x: number,
		y: number,
		radius: number,
		color: number
	): void;

	/**
	 * Draws a filled ellipse.
	 * @param x The X coordinate of the center.
	 * @param y The Y coordinate of the center.
	 * @param a The horizontal radius.
	 * @param b The vertical radius.
	 * @param color The color index.
	 */
	export function elli(
		x: number,
		y: number,
		a: number,
		b: number,
		color: number
	): void;

	/**
	 * Draws an ellipse outline.
	 * @param x The X coordinate of the center.
	 * @param y The Y coordinate of the center.
	 * @param a The horizontal radius.
	 * @param b The vertical radius.
	 * @param color The color index.
	 */
	export function ellib(
		x: number,
		y: number,
		a: number,
		b: number,
		color: number
	): void;

	/**
	 * Draws a line.
	 * @param x0 The X coordinate of the start point.
	 * @param y0 The Y coordinate of the start point.
	 * @param x1 The X coordinate of the end point.
	 * @param y1 The Y coordinate of the end point.
	 * @param color The color index.
	 */
	export function line(
		x0: number,
		y0: number,
		x1: number,
		y1: number,
		color: number
	): void;

	/**
	 * Gets or sets a pixel color.
	 * @param x The X coordinate.
	 * @param y The Y coordinate.
	 * @param color Optional color index. If provided, sets the pixel color.
	 * @returns The color index at the specified position.
	 */
	export function pix(x: number, y: number, color?: number): number;

	/**
	 * Prints text on the screen.
	 * @param text The text to print.
	 * @param x Optional X coordinate (default: 0).
	 * @param y Optional Y coordinate (default: 0).
	 * @param color Optional color index (default: 12).
	 * @param fixed Optional fixed-width font flag (default: false).
	 * @param scale Optional scale factor (default: 1).
	 * @param smallfont Optional small font flag (default: false).
	 * @returns The width of the printed text.
	 */
	export function print(
		text: string,
		x?: number,
		y?: number,
		color?: number,
		fixed?: boolean,
		scale?: number,
		smallfont?: boolean
	): number;

	/**
	 * Draws a filled rectangle.
	 * @param x The X coordinate of the top-left corner.
	 * @param y The Y coordinate of the top-left corner.
	 * @param w The width of the rectangle.
	 * @param h The height of the rectangle.
	 * @param color The color index.
	 */
	export function rect(
		x: number,
		y: number,
		w: number,
		h: number,
		color: number
	): void;

	/**
	 * Draws a rectangle outline.
	 * @param x The X coordinate of the top-left corner.
	 * @param y The Y coordinate of the top-left corner.
	 * @param w The width of the rectangle.
	 * @param h The height of the rectangle.
	 * @param color The color index.
	 */
	export function rectb(
		x: number,
		y: number,
		w: number,
		h: number,
		color: number
	): void;

	/**
	 * Draws a sprite.
	 * @param id The sprite ID.
	 * @param x The X coordinate.
	 * @param y The Y coordinate.
	 * @param transparent Optional transparent color index (default: -1, no transparency).
	 * @param scale Optional scale factor (default: 1).
	 * @param flip Optional flip flag: 1=horizontal, 2=vertical, 3=both (default: 0).
	 * @param rotate Optional rotation: 1=90°, 2=180°, 3=270° clockwise (default: 0).
	 * @param w Optional sprite width in tiles (default: 1).
	 * @param h Optional sprite height in tiles (default: 1).
	 */
	export function spr(
		id: number,
		x: number,
		y: number,
		transparent?: number,
		scale?: number,
		flip?: number,
		rotate?: number,
		w?: number,
		h?: number
	): void;

	/**
	 * Draws a filled triangle.
	 * @param x1 The X coordinate of the first vertex.
	 * @param y1 The Y coordinate of the first vertex.
	 * @param x2 The X coordinate of the second vertex.
	 * @param y2 The Y coordinate of the second vertex.
	 * @param x3 The X coordinate of the third vertex.
	 * @param y3 The Y coordinate of the third vertex.
	 * @param color The color index.
	 */
	export function tri(
		x1: number,
		y1: number,
		x2: number,
		y2: number,
		x3: number,
		y3: number,
		color: number
	): void;

	/**
	 * Draws a triangle outline.
	 * @param x1 The X coordinate of the first vertex.
	 * @param y1 The Y coordinate of the first vertex.
	 * @param x2 The X coordinate of the second vertex.
	 * @param y2 The Y coordinate of the second vertex.
	 * @param x3 The X coordinate of the third vertex.
	 * @param y3 The Y coordinate of the third vertex.
	 * @param color The color index.
	 */
	export function trib(
		x1: number,
		y1: number,
		x2: number,
		y2: number,
		x3: number,
		y3: number,
		color: number
	): void;

	/**
	 * Draws a textured triangle.
	 * @param x1 The X coordinate of the first vertex.
	 * @param y1 The Y coordinate of the first vertex.
	 * @param x2 The X coordinate of the second vertex.
	 * @param y2 The Y coordinate of the second vertex.
	 * @param x3 The X coordinate of the third vertex.
	 * @param y3 The Y coordinate of the third vertex.
	 * @param u1 The U texture coordinate of the first vertex.
	 * @param v1 The V texture coordinate of the first vertex.
	 * @param u2 The U texture coordinate of the second vertex.
	 * @param v2 The V texture coordinate of the second vertex.
	 * @param u3 The U texture coordinate of the third vertex.
	 * @param v3 The V texture coordinate of the third vertex.
	 * @param texsrc Optional texture source (default: 0).
	 * @param chromakey Optional chroma key color index (default: -1).
	 * @param z1 Optional Z coordinate of the first vertex (default: 0).
	 * @param z2 Optional Z coordinate of the second vertex (default: 0).
	 * @param z3 Optional Z coordinate of the third vertex (default: 0).
	 */
	export function ttri(
		x1: number,
		y1: number,
		x2: number,
		y2: number,
		x3: number,
		y3: number,
		u1: number,
		v1: number,
		u2: number,
		v2: number,
		u3: number,
		v3: number,
		texsrc?: number,
		chromakey?: number,
		z1?: number,
		z2?: number,
		z3?: number
	): void;

	/**
	 * Draws text using a custom font.
	 * @param text The text to draw.
	 * @param x The X coordinate.
	 * @param y The Y coordinate.
	 * @param transparent Optional transparent color index.
	 * @param charWidth Optional character width.
	 * @param charHeight Optional character height.
	 * @param fixed Optional fixed-width font flag (default: false).
	 * @param scale Optional scale factor (default: 1).
	 * @returns The width of the drawn text.
	 */
	export function font(
		text: string,
		x: number,
		y: number,
		transparent?: number,
		charWidth?: number,
		charHeight?: number,
		fixed?: boolean,
		scale?: number
	): number;

	/////////////////////////////
	/// Map Functions
	/////////////////////////////

	/**
	 * Draws a map tile layer.
	 * @param x Optional X coordinate of the map (default: 0).
	 * @param y Optional Y coordinate of the map (default: 0).
	 * @param w Optional width in tiles (default: 30).
	 * @param h Optional height in tiles (default: 17).
	 * @param sx Optional sprite X offset (default: 0).
	 * @param sy Optional sprite Y offset (default: 0).
	 * @param colorkey Optional color key for transparency (default: -1).
	 * @param scale Optional scale factor (default: 1).
	 * @param remap Optional remap callback function.
	 */
	export function map(
		x?: number,
		y?: number,
		w?: number,
		h?: number,
		sx?: number,
		sy?: number,
		colorkey?: number,
		scale?: number,
		remap?: MapRemapCallback
	): void;

	/**
	 * Gets the tile ID at a map position.
	 * @param x The X coordinate in tiles.
	 * @param y The Y coordinate in tiles.
	 * @returns The tile ID.
	 */
	export function mget(x: number, y: number): number;

	/**
	 * Sets the tile ID at a map position.
	 * @param x The X coordinate in tiles.
	 * @param y The Y coordinate in tiles.
	 * @param id The tile ID to set.
	 */
	export function mset(x: number, y: number, id: number): void;

	/////////////////////////////
	/// Sprite Functions
	/////////////////////////////

	/**
	 * Gets a sprite flag.
	 * @param sprite_id The sprite ID.
	 * @param flag The flag index (0-7).
	 * @returns true if the flag is set, false otherwise.
	 */
	export function fget(sprite_id: number, flag: number): boolean;

	/**
	 * Sets a sprite flag.
	 * @param sprite_id The sprite ID.
	 * @param flag The flag index (0-7).
	 * @param bool The flag value to set.
	 */
	export function fset(sprite_id: number, flag: number, bool: boolean): void;

	/////////////////////////////
	/// Audio Functions
	/////////////////////////////

	/**
	 * Plays a sound effect.
	 * @param id The sound effect ID.
	 * @param note Optional note number (0-95, default: uses SFX note).
	 * @param duration Optional duration in frames (default: -1, full duration).
	 * @param channel Optional channel number (0-3, default: 0).
	 * @param volume Optional volume (0-15, default: 15).
	 * @param speed Optional speed (0-15, default: 0).
	 */
	export function sfx(
		id: number,
		note?: number,
		duration?: number,
		channel?: number,
		volume?: number,
		speed?: number
	): void;

	/**
	 * Plays music.
	 * @param track Optional track number (default: -1, stops music).
	 * @param frame Optional frame number (default: -1).
	 * @param row Optional row number (default: -1).
	 * @param loop Optional loop flag (default: true).
	 */
	export function music(
		track?: number,
		frame?: number,
		row?: number,
		loop?: boolean
	): void;

	/////////////////////////////
	/// Memory Functions
	/////////////////////////////

	/**
	 * Reads a value from memory.
	 * @param addr The memory address.
	 * @param bits Optional bit width: 8, 16, or 32 (default: 8).
	 * @returns The value read from memory.
	 */
	export function peek(addr: number, bits?: number): number;

	/**
	 * Reads a single bit from memory.
	 * @param bitaddr The bit address.
	 * @returns The bit value (0 or 1).
	 */
	export function peek1(bitaddr: number): number;

	/**
	 * Reads a 2-byte value from memory.
	 * @param addr2 The memory address (must be 2-byte aligned).
	 * @returns The 16-bit value read from memory.
	 */
	export function peek2(addr2: number): number;

	/**
	 * Reads a 4-byte value from memory.
	 * @param addr4 The memory address (must be 4-byte aligned).
	 * @returns The 32-bit value read from memory.
	 */
	export function peek4(addr4: number): number;

	/**
	 * Writes a value to memory.
	 * @param addr The memory address.
	 * @param val The value to write.
	 */
	export function poke(addr: number, val: number): void;

	/**
	 * Writes a single bit to memory.
	 * @param bitaddr The bit address.
	 * @param bitval The bit value (0 or 1).
	 */
	export function poke1(bitaddr: number, bitval: number): void;

	/**
	 * Writes a 2-byte value to memory.
	 * @param addr2 The memory address (must be 2-byte aligned).
	 * @param val2 The 16-bit value to write.
	 */
	export function poke2(addr2: number, val2: number): void;

	/**
	 * Writes a 4-byte value to memory.
	 * @param addr4 The memory address (must be 4-byte aligned).
	 * @param val4 The 32-bit value to write.
	 */
	export function poke4(addr4: number, val4: number): void;

	/**
	 * Gets or sets a persistent memory value.
	 * @param index The persistent memory index (0-255).
	 * @param val Optional value to set. If omitted, returns the current value.
	 * @returns The persistent memory value.
	 */
	export function pmem(index: number, val?: number): number;

	/**
	 * Copies memory from one location to another.
	 * @param toaddr The destination address.
	 * @param fromaddr The source address.
	 * @param len The number of bytes to copy.
	 */
	export function memcpy(toaddr: number, fromaddr: number, len: number): void;

	/**
	 * Sets a block of memory to a value.
	 * @param addr The starting address.
	 * @param val The value to set.
	 * @param len The number of bytes to set.
	 */
	export function memset(addr: number, val: number, len: number): void;

	/////////////////////////////
	/// System Functions
	/////////////////////////////

	/**
	 * Exits the game.
	 */
	export function exit(): void;

	/**
	 * Resets the game.
	 */
	export function reset(): void;

	/**
	 * Synchronizes cart data.
	 * @param mask Optional sync mask (default: 0, syncs all).
	 * @param bank Optional bank number (default: 0).
	 * @param tocart Optional flag to save to cart (default: false).
	 */
	export function sync(mask?: SyncMask, bank?: number, tocart?: boolean): void;

	/**
	 * Gets the current time in milliseconds.
	 * @returns The current time in milliseconds.
	 */
	export function time(): number;

	/**
	 * Gets a timestamp.
	 * @returns A timestamp value.
	 */
	export function tstamp(): number;

	/**
	 * Outputs a trace message.
	 * @param msg The message to output.
	 * @param color Optional color index.
	 */
	export function trace(msg: string, color?: number): void;

	/**
	 * Switches the video bank.
	 * @param bank The bank number (0 or 1).
	 */
	export function vbank(bank: number): void;

	/////////////////////////////
	/// Callback Functions
	/////////////////////////////


	export const _G: {
		/**
		 * The BDR (Between Display Rows) callback allows you to execute code between the rendering of each scan line.
		 * The primary reason to do this is to manipulate the palette. Doing so makes it possible to use a different
		 * palette for each scan line, and therefore more than 16 colors at a time.
		 * @param scanline The scan line about to be drawn (0-143).
		 *                 0-3: TOP BORDER
		 *                 4-139: ROW 0-135 (equiv SCN(0-135))
		 *                 140-143: BOTTOM BORDER
		 */
		BDR(this: void, scanline: number): void;

		/**
		 * The TIC function is the main update/draw callback and must be present in every program.
		 * It takes no parameters and is called sixty times per second (60fps).
		 * Put your update and draw code here.
		 */
		TIC(this: void): void;

		/**
		 * The BOOT function is called a single time when your cartridge is booted.
		 * It should be used for startup/initialization code. For scripting languages that allow
		 * code in the global scope (Lua, etc.) using BOOT is preferred rather than including
		 * source code in the global scope.
		 */
		BOOT(this: void): void;
	};
}
