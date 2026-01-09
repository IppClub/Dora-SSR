-- TIC-80 API

-- Remap callback function type for map() function.
-- @param tile (number) The tile ID at position (x, y)
-- @param x (number) The X coordinate of the tile
-- @param y (number) The Y coordinate of the tile
-- @return (number, number | nil, number | nil) A tuple containing [tile, flip, rotate]
local type MapRemapCallback = function(tile: number, x: number, y: number): number, number | nil, number | nil

--[[ Input Functions ]]

-- Checks if a button is currently pressed.
-- @param id (number) [optional] Button ID (0-31). If omitted, checks if any button is pressed.
-- Button IDs for all players:
-- Player 1: Up 0, Down 1, Left 2, Right 3, A 4, B 5, X 6, Y 7
-- Player 2: Up 8, Down 9, Left 10, Right 11, A 12, B 13, X 14, Y 15
-- Player 3: Up 16, Down 17, Left 18, Right 19, A 20, B 21, X 22, Y 23
-- Player 4: Up 24, Down 25, Left 26, Right 27, A 28, B 29, X 30, Y 31
-- @return (boolean) True if the button is pressed, false otherwise.
global btn: function(id?: number): boolean

-- Checks if a button was just pressed (on this frame).
-- @param id (number) [optional] Button ID (0-31). If omitted, checks all buttons.
-- @param hold (number) [optional] Hold time in frames.
-- @param period (number) [optional] Repeat period in frames.
-- @return (boolean) True if the button was just pressed, false otherwise.
global btnp: function(id?: number, hold?: number, period?: number): boolean

-- Checks if a keyboard key is currently pressed.
-- @param code (number) [optional] Key code. If omitted, checks all keys.
-- Letters A-Z: 0-25
-- Numbers 0-9: 27-36
-- Special keys: 37-65
-- Minus = 37
-- Equals = 38
-- LeftBracket = 39
-- RightBracket = 40
-- Backslash = 41
-- Semicolon = 42
-- Apostrophe = 43
-- Grave = 44
-- Comma = 45
-- Period = 46
-- Slash = 47
-- Space = 48
-- Tab = 49
-- Return = 50
-- Backspace = 51
-- Delete = 52
-- Insert = 53
-- PageUp = 54
-- PageDown = 55
-- Home = 56
-- End = 57
-- Up = 58
-- Down = 59
-- Left = 60
-- Right = 61
-- CapsLock = 62
-- Ctrl = 63
-- Shift = 64
-- Alt = 65
-- @return (boolean) True if the key is pressed, false otherwise.
global key: function(code?: number): boolean

-- Checks if a keyboard key was just pressed (on this frame).
-- @param code (number) [optional] Key code. If omitted, checks all keys.
-- @param hold (number) [optional] Hold time in frames.
-- @param period (number) [optional] Repeat period in frames.
-- @return (boolean) True if the key was just pressed, false otherwise.
global keyp: function(code?: number, hold?: number, period?: number): boolean

-- Gets the current mouse state.
-- @return (number, number, number, number, number, number, number) Multiple return values containing [x, y, left, middle, right, scrollx, scrolly]
global mouse: function(): number, number, number, number, number, number, number

--[[ Graphics Functions ]]

-- Sets the drawing clip region.
-- @param x (number) The X coordinate of the clip region.
-- @param y (number) The Y coordinate of the clip region.
-- @param w (number) The width of the clip region.
-- @param h (number) The height of the clip region.
global clip: function(x: number, y: number, w: number, h: number)

-- Clears the screen with a color.
-- @param color (number) [optional] Color index (default: 0).
global cls: function(color?: number)

-- Draws a filled circle.
-- @param x (number) The X coordinate of the center.
-- @param y (number) The Y coordinate of the center.
-- @param radius (number) The radius of the circle.
-- @param color (number) The color index.
global circ: function(x: number, y: number, radius: number, color: number)

-- Draws a circle outline.
-- @param x (number) The X coordinate of the center.
-- @param y (number) The Y coordinate of the center.
-- @param radius (number) The radius of the circle.
-- @param color (number) The color index.
global circb: function(x: number, y: number, radius: number, color: number)

-- Draws a filled ellipse.
-- @param x (number) The X coordinate of the center.
-- @param y (number) The Y coordinate of the center.
-- @param a (number) The horizontal radius.
-- @param b (number) The vertical radius.
-- @param color (number) The color index.
global elli: function(x: number, y: number, a: number, b: number, color: number)

-- Draws an ellipse outline.
-- @param x (number) The X coordinate of the center.
-- @param y (number) The Y coordinate of the center.
-- @param a (number) The horizontal radius.
-- @param b (number) The vertical radius.
-- @param color (number) The color index.
global ellib: function(x: number, y: number, a: number, b: number, color: number)

-- Draws a line.
-- @param x0 (number) The X coordinate of the start point.
-- @param y0 (number) The Y coordinate of the start point.
-- @param x1 (number) The X coordinate of the end point.
-- @param y1 (number) The Y coordinate of the end point.
-- @param color (number) The color index.
global line: function(x0: number, y0: number, x1: number, y1: number, color: number)

-- Gets or sets a pixel color.
-- @param x (number) The X coordinate.
-- @param y (number) The Y coordinate.
-- @param color (number?) Optional color index. If provided, sets the pixel color.
-- @return (number) The color index at the specified position.
global pix: function(x: number, y: number, color?: number): number

-- Prints text on the screen.
-- @param text (string) The text to print.
-- @param x (number) [optional] X coordinate (default: 0).
-- @param y (number) [optional] Y coordinate (default: 0).
-- @param color (number) [optional] Color index (default: 12).
-- @param fixed (boolean) [optional] Fixed-width font flag (default: false).
-- @param scale (number) [optional] Scale factor (default: 1).
-- @param smallfont (boolean) [optional] Small font flag (default: false).
-- @return (number) The width of the printed text.
global print: function(text: string, x?: number, y?: number, color?: number, fixed?: boolean, scale?: number, smallfont?: boolean): number

-- Draws a filled rectangle.
-- @param x (number) The X coordinate of the top-left corner.
-- @param y (number) The Y coordinate of the top-left corner.
-- @param w (number) The width of the rectangle.
-- @param h (number) The height of the rectangle.
-- @param color (number) The color index.
global rect: function(x: number, y: number, w: number, h: number, color: number)

-- Draws a rectangle outline.
-- @param x (number) The X coordinate of the top-left corner.
-- @param y (number) The Y coordinate of the top-left corner.
-- @param w (number) The width of the rectangle.
-- @param h (number) The height of the rectangle.
-- @param color (number) The color index.
global rectb: function(x: number, y: number, w: number, h: number, color: number)

-- Draws a sprite.
-- @param id (number) The sprite ID.
-- @param x (number) The X coordinate.
-- @param y (number) The Y coordinate.
-- @param transparent (number) [optional] Transparent color index (default: -1, no transparency).
-- @param scale (number) [optional] Scale factor (default: 1).
-- @param flip (number) [optional] Flip flag: 1=horizontal, 2=vertical, 3=both (default: 0).
-- @param rotate (number) [optional] Rotation: 1=90°, 2=180°, 3=270° clockwise (default: 0).
-- @param w (number) [optional] Sprite width in tiles (default: 1).
-- @param h (number) [optional] Sprite height in tiles (default: 1).
global spr: function(id: number, x: number, y: number, transparent?: number, scale?: number, flip?: number, rotate?: number, w?: number, h?: number)

-- Draws a filled triangle.
-- @param x1 (number) The X coordinate of the first vertex.
-- @param y1 (number) The Y coordinate of the first vertex.
-- @param x2 (number) The X coordinate of the second vertex.
-- @param y2 (number) The Y coordinate of the second vertex.
-- @param x3 (number) The X coordinate of the third vertex.
-- @param y3 (number) The Y coordinate of the third vertex.
-- @param color (number) The color index.
global tri: function(x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, color: number)

-- Draws a triangle outline.
-- @param x1 (number) The X coordinate of the first vertex.
-- @param y1 (number) The Y coordinate of the first vertex.
-- @param x2 (number) The X coordinate of the second vertex.
-- @param y2 (number) The Y coordinate of the second vertex.
-- @param x3 (number) The X coordinate of the third vertex.
-- @param y3 (number) The Y coordinate of the third vertex.
-- @param color (number) The color index.
global trib: function(x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, color: number)

-- Draws a textured triangle.
-- @param x1 (number) The X coordinate of the first vertex.
-- @param y1 (number) The Y coordinate of the first vertex.
-- @param x2 (number) The X coordinate of the second vertex.
-- @param y2 (number) The Y coordinate of the second vertex.
-- @param x3 (number) The X coordinate of the third vertex.
-- @param y3 (number) The Y coordinate of the third vertex.
-- @param u1 (number) The U texture coordinate of the first vertex.
-- @param v1 (number) The V texture coordinate of the first vertex.
-- @param u2 (number) The U texture coordinate of the second vertex.
-- @param v2 (number) The V texture coordinate of the second vertex.
-- @param u3 (number) The U texture coordinate of the third vertex.
-- @param v3 (number) The V texture coordinate of the third vertex.
-- @param texsrc (number) [optional] Texture source (default: 0).
-- @param chromakey (number) [optional] Chroma key color index (default: -1).
-- @param z1 (number) [optional] Z coordinate of the first vertex (default: 0).
-- @param z2 (number) [optional] Z coordinate of the second vertex (default: 0).
-- @param z3 (number) [optional] Z coordinate of the third vertex (default: 0).
global ttri: function(x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, u1: number, v1: number, u2: number, v2: number, u3: number, v3: number, texsrc?: number, chromakey?: number, z1?: number, z2?: number, z3?: number)

-- Draws text using a custom font.
-- @param text (string) The text to draw.
-- @param x (number) The X coordinate.
-- @param y (number) The Y coordinate.
-- @param transparent (number) [optional] Transparent color index.
-- @param charWidth (number) [optional] Character width.
-- @param charHeight (number) [optional] Character height.
-- @param fixed (boolean) [optional] Fixed-width font flag (default: false).
-- @param scale (number) [optional] Scale factor (default: 1).
-- @return (number) The width of the drawn text.
global font: function(text: string, x: number, y: number, transparent?: number, charWidth?: number, charHeight?: number, fixed?: boolean, scale?: number): number

--[[ Map Functions ]]

-- Draws a map tile layer.
-- @param x (number) [optional] Map X coordinate (default: 0).
-- @param y (number) [optional] Map Y coordinate (default: 0).
-- @param w (number) [optional] Width in tiles (default: 30).
-- @param h (number) [optional] Height in tiles (default: 17).
-- @param sx (number) [optional] Sprite X offset (default: 0).
-- @param sy (number) [optional] Sprite Y offset (default: 0).
-- @param colorkey (number) [optional] Color key for transparency (default: -1).
-- @param scale (number) [optional] Scale factor (default: 1).
-- @param remap (MapRemapCallback) [optional] Remap callback function.
global map: function(x?: number, y?: number, w?: number, h?: number, sx?: number, sy?: number, colorkey?: number, scale?: number, remap?: MapRemapCallback)

-- Gets the tile ID at a map position.
-- @param x (number) The X coordinate in tiles.
-- @param y (number) The Y coordinate in tiles.
-- @return (number) The tile ID.
global mget: function(x: number, y: number): number

-- Sets the tile ID at a map position.
-- @param x (number) The X coordinate in tiles.
-- @param y (number) The Y coordinate in tiles.
-- @param id (number) The tile ID to set.
global mset: function(x: number, y: number, id: number)

--[[ Sprite Functions ]]

-- Gets a sprite flag.
-- @param sprite_id (number) The sprite ID.
-- @param flag (number) The flag index (0-7).
-- @return (boolean) True if the flag is set, false otherwise.
global fget: function(sprite_id: number, flag: number): boolean

-- Sets a sprite flag.
-- @param sprite_id (number) The sprite ID.
-- @param flag (number) The flag index (0-7).
-- @param bool (boolean) The flag value to set.
global fset: function(sprite_id: number, flag: number, bool: boolean)

--[[ Audio Functions ]]

-- Plays a sound effect.
-- @param id (number) The sound effect ID.
-- @param note (number) [optional] Note number (0-95, default: uses SFX note).
-- @param duration (number) [optional] Duration in frames (default: -1, full duration).
-- @param channel (number) [optional] Channel number (0-3, default: 0).
-- @param volume (number) [optional] Volume (0-15, default: 15).
-- @param speed (number) [optional] Speed (0-15, default: 0).
global sfx: function(id: number, note?: number, duration?: number, channel?: number, volume?: number, speed?: number)

-- Plays music.
-- @param track (number) [optional] Track number (default: -1, stops music).
-- @param frame (number) [optional] Frame number (default: -1).
-- @param row (number) [optional] Row number (default: -1).
-- @param loop (boolean) [optional] Loop flag (default: true).
global music: function(track?: number, frame?: number, row?: number, loop?: boolean)

--[[ Memory Functions ]]

-- Reads a value from memory.
-- @param addr (number) The memory address.
-- @param bits (number) [optional] Bit width: 8, 16, or 32 (default: 8).
-- @return (number) The value read from memory.
global peek: function(addr: number, bits?: number): number

-- Reads a single bit from memory.
-- @param bitaddr (number) The bit address.
-- @return (number) The bit value (0 or 1).
global peek1: function(bitaddr: number): number

-- Reads a 2-byte value from memory.
-- @param addr2 (number) The memory address (must be 2-byte aligned).
-- @return (number) The 16-bit value read from memory.
global peek2: function(addr2: number): number

-- Reads a 4-byte value from memory.
-- @param addr4 (number) The memory address (must be 4-byte aligned).
-- @return (number) The 32-bit value read from memory.
global peek4: function(addr4: number): number

-- Writes a value to memory.
-- @param addr (number) The memory address.
-- @param val (number) The value to write.
global poke: function(addr: number, val: number)

-- Writes a single bit to memory.
-- @param bitaddr (number) The bit address.
-- @param bitval (number) The bit value (0 or 1).
global poke1: function(bitaddr: number, bitval: number)

-- Writes a 2-byte value to memory.
-- @param addr2 (number) The memory address (must be 2-byte aligned).
-- @param val2 (number) The 16-bit value to write.
global poke2: function(addr2: number, val2: number)

-- Writes a 4-byte value to memory.
-- @param addr4 (number) The memory address (must be 4-byte aligned).
-- @param val4 (number) The 32-bit value to write.
global poke4: function(addr4: number, val4: number)

-- Gets or sets a persistent memory value.
-- @param index (number) The persistent memory index (0-255).
-- @param val (number) [optional] Value to set. If omitted, returns the current value.
-- @return (number) The persistent memory value.
global pmem: function(index: number, val?: number): number

-- Copies memory from one location to another.
-- @param toaddr (number) The destination address.
-- @param fromaddr (number) The source address.
-- @param len (number) The number of bytes to copy.
global memcpy: function(toaddr: number, fromaddr: number, len: number)

-- Sets a block of memory to a value.
-- @param addr (number) The starting address.
-- @param val (number) The value to set.
-- @param len (number) The number of bytes to set.
global memset: function(addr: number, val: number, len: number)

--[[ Callback Functions ]]

-- The BDR (Between Display Rows) callback allows you to execute code between the rendering of each scan line.
-- The primary reason to do this is to manipulate the palette. Doing so makes it possible to use a different
-- palette for each scan line, and therefore more than 16 colors at a time.
-- @param scanline (number) The scan line about to be drawn (0-143).
--                 0-3: TOP BORDER
--                 4-139: ROW 0-135 (equiv SCN(0-135))
--                 140-143: BOTTOM BORDER
global BDR: function(scanline: number)

-- The TIC function is the main update/draw callback and must be present in every program.
-- It takes no parameters and is called sixty times per second (60fps).
-- Put your update and draw code here.
global TIC: function()

-- The BOOT function is called a single time when your cartridge is booted.
-- It should be used for startup/initialization code. For scripting languages that allow
-- code in the global scope (Lua, etc.) using BOOT is preferred rather than including
-- source code in the global scope.
global BOOT: function()

--[[ System Functions ]]

-- Exits the game.
global exit: function()

-- Resets the game.
global reset: function()

-- Synchronizes cart data.
-- @param mask (number) [optional] Sync mask (default: 0, syncs all).
-- Tiles = 1 << 0
-- Sprites = 1 << 1
-- Map = 1 << 2
-- Sfx = 1 << 3
-- Music = 1 << 4
-- Palette = 1 << 5
-- Flags = 1 << 6
-- Screen = 1 << 7
-- @param bank (number) [optional] Bank number (default: 0).
-- @param tocart (boolean) [optional] Flag to save to cart (default: false).
global sync: function(mask?: number, bank?: number, tocart?: boolean)

-- Gets the current time in milliseconds.
-- @return (number) The current time in milliseconds.
global time: function(): number

-- Gets a timestamp.
-- @return (number) A timestamp value.
global tstamp: function(): number

-- Outputs a trace message.
-- @param msg (string) The message to output.
-- @param color (number) [optional] Color index.
global trace: function(msg: string, color?: number)

-- Switches the video bank.
-- @param bank (number) The bank number (0 or 1).
global vbank: function(bank: number)
