/////////////////////////////
/// TIC-80 API
/////////////////////////////

declare module "tic80" {
	/**
	 * 所有玩家的按钮 ID。
	 * P1: 0-7, P2: 8-15, P3: 16-23, P4: 24-31
	 */
	export const enum Button {
		// Player 1
		P1_Up = 0,
		P1_Down = 1,
		P1_Left = 2,
		P1_Right = 3,
		P1_A = 4, // Z 键
		P1_B = 5, // X 键
		P1_X = 6, // A 键
		P1_Y = 7, // S 键

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
	 * 键盘按键代码。
	 * 字母 A-Z: 0-25, 数字 0-9: 27-36, 特殊键: 37-65
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
	 * sync() 函数的同步掩码位标志。
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
	 * map() 函数的重映射回调函数类型。
	 * @param tile 位置 (x, y) 处的图块 ID
	 * @param x 图块的 X 坐标
	 * @param y 图块的 Y 坐标
	 * @returns 包含 [tile, flip?, rotate?] 的元组
	 */
	export type MapRemapCallback = (
		tile: number,
		x: number,
		y: number
	) => LuaMultiReturn<[number, number?, number?]>;

	/////////////////////////////
	/// 输入函数
	/////////////////////////////

	/**
	 * 检查按钮是否当前被按下。
	 * @param id 可选的按钮 ID (0-31)。如果省略，检查所有按钮。
	 * @returns 如果按钮被按下则返回 true，否则返回 false。
	 */
	export function btn(id?: Button): boolean;

	/**
	 * 检查按钮是否刚刚被按下（在本帧）。
	 * @param id 可选的按钮 ID (0-31)。如果省略，检查所有按钮。
	 * @param hold 可选的按住时间（以帧为单位）。
	 * @param period 可选的重复周期（以帧为单位）。
	 * @returns 如果按钮刚刚被按下则返回 true，否则返回 false。
	 */
	export function btnp(id?: Button, hold?: number, period?: number): boolean;

	/**
	 * 检查键盘按键是否当前被按下。
	 * @param code 可选的按键代码。如果省略，检查所有按键。
	 * @returns 如果按键被按下则返回 true，否则返回 false。
	 */
	export function key(code?: Key): boolean;

	/**
	 * 检查键盘按键是否刚刚被按下（在本帧）。
	 * @param code 可选的按键代码。如果省略，检查所有按键。
	 * @param hold 可选的按住时间（以帧为单位）。
	 * @param period 可选的重复周期（以帧为单位）。
	 * @returns 如果按键刚刚被按下则返回 true，否则返回 false。
	 */
	export function keyp(code?: Key, hold?: number, period?: number): boolean;

	/**
	 * 获取当前鼠标状态。
	 * @returns 包含 [x, y, left, middle, right, scrollx, scrolly] 的元组
	 */
	export function mouse(): LuaMultiReturn<
		[number, number, number, number, number, number, number]
	>;

	/////////////////////////////
	/// 图形函数
	/////////////////////////////

	/**
	 * 设置绘制裁剪区域。
	 * @param x 裁剪区域的 X 坐标。
	 * @param y 裁剪区域的 Y 坐标。
	 * @param w 裁剪区域的宽度。
	 * @param h 裁剪区域的高度。
	 */
	export function clip(x: number, y: number, w: number, h: number): void;

	/**
	 * 用颜色清空屏幕。
	 * @param color 可选的颜色索引（默认: 0）。
	 */
	export function cls(color?: number): void;

	/**
	 * 绘制填充圆形。
	 * @param x 圆心的 X 坐标。
	 * @param y 圆心的 Y 坐标。
	 * @param radius 圆的半径。
	 * @param color 颜色索引。
	 */
	export function circ(x: number, y: number, radius: number, color: number): void;

	/**
	 * 绘制圆形轮廓。
	 * @param x 圆心的 X 坐标。
	 * @param y 圆心的 Y 坐标。
	 * @param radius 圆的半径。
	 * @param color 颜色索引。
	 */
	export function circb(
		x: number,
		y: number,
		radius: number,
		color: number
	): void;

	/**
	 * 绘制填充椭圆。
	 * @param x 椭圆中心的 X 坐标。
	 * @param y 椭圆中心的 Y 坐标。
	 * @param a 水平半径。
	 * @param b 垂直半径。
	 * @param color 颜色索引。
	 */
	export function elli(
		x: number,
		y: number,
		a: number,
		b: number,
		color: number
	): void;

	/**
	 * 绘制椭圆轮廓。
	 * @param x 椭圆中心的 X 坐标。
	 * @param y 椭圆中心的 Y 坐标。
	 * @param a 水平半径。
	 * @param b 垂直半径。
	 * @param color 颜色索引。
	 */
	export function ellib(
		x: number,
		y: number,
		a: number,
		b: number,
		color: number
	): void;

	/**
	 * 绘制直线。
	 * @param x0 起点的 X 坐标。
	 * @param y0 起点的 Y 坐标。
	 * @param x1 终点的 X 坐标。
	 * @param y1 终点的 Y 坐标。
	 * @param color 颜色索引。
	 */
	export function line(
		x0: number,
		y0: number,
		x1: number,
		y1: number,
		color: number
	): void;

	/**
	 * 获取或设置像素颜色。
	 * @param x X 坐标。
	 * @param y Y 坐标。
	 * @param color 可选的颜色索引。如果提供，则设置像素颜色。
	 * @returns 指定位置的颜色索引。
	 */
	export function pix(x: number, y: number, color?: number): number;

	/**
	 * 在屏幕上打印文本。
	 * @param text 要打印的文本。
	 * @param x 可选的 X 坐标（默认: 0）。
	 * @param y 可选的 Y 坐标（默认: 0）。
	 * @param color 可选的颜色索引（默认: 12）。
	 * @param fixed 可选的等宽字体标志（默认: false）。
	 * @param scale 可选的缩放因子（默认: 1）。
	 * @param smallfont 可选的小字体标志（默认: false）。
	 * @returns 打印文本的宽度。
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
	 * 绘制填充矩形。
	 * @param x 左上角的 X 坐标。
	 * @param y 左上角的 Y 坐标。
	 * @param w 矩形的宽度。
	 * @param h 矩形的高度。
	 * @param color 颜色索引。
	 */
	export function rect(
		x: number,
		y: number,
		w: number,
		h: number,
		color: number
	): void;

	/**
	 * 绘制矩形轮廓。
	 * @param x 左上角的 X 坐标。
	 * @param y 左上角的 Y 坐标。
	 * @param w 矩形的宽度。
	 * @param h 矩形的高度。
	 * @param color 颜色索引。
	 */
	export function rectb(
		x: number,
		y: number,
		w: number,
		h: number,
		color: number
	): void;

	/**
	 * 绘制精灵。
	 * @param id 精灵 ID。
	 * @param x X 坐标。
	 * @param y Y 坐标。
	 * @param transparent 可选的透明颜色索引（默认: -1，无透明）。
	 * @param scale 可选的缩放因子（默认: 1）。
	 * @param flip 可选的翻转标志：1=水平，2=垂直，3=两者（默认: 0）。
	 * @param rotate 可选的旋转：1=90°，2=180°，3=270° 顺时针（默认: 0）。
	 * @param w 可选的精灵宽度（以图块为单位，默认: 1）。
	 * @param h 可选的精灵高度（以图块为单位，默认: 1）。
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
	 * 绘制填充三角形。
	 * @param x1 第一个顶点的 X 坐标。
	 * @param y1 第一个顶点的 Y 坐标。
	 * @param x2 第二个顶点的 X 坐标。
	 * @param y2 第二个顶点的 Y 坐标。
	 * @param x3 第三个顶点的 X 坐标。
	 * @param y3 第三个顶点的 Y 坐标。
	 * @param color 颜色索引。
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
	 * 绘制三角形轮廓。
	 * @param x1 第一个顶点的 X 坐标。
	 * @param y1 第一个顶点的 Y 坐标。
	 * @param x2 第二个顶点的 X 坐标。
	 * @param y2 第二个顶点的 Y 坐标。
	 * @param x3 第三个顶点的 X 坐标。
	 * @param y3 第三个顶点的 Y 坐标。
	 * @param color 颜色索引。
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
	 * 绘制纹理三角形。
	 * @param x1 第一个顶点的 X 坐标。
	 * @param y1 第一个顶点的 Y 坐标。
	 * @param x2 第二个顶点的 X 坐标。
	 * @param y2 第二个顶点的 Y 坐标。
	 * @param x3 第三个顶点的 X 坐标。
	 * @param y3 第三个顶点的 Y 坐标。
	 * @param u1 第一个顶点的 U 纹理坐标。
	 * @param v1 第一个顶点的 V 纹理坐标。
	 * @param u2 第二个顶点的 U 纹理坐标。
	 * @param v2 第二个顶点的 V 纹理坐标。
	 * @param u3 第三个顶点的 U 纹理坐标。
	 * @param v3 第三个顶点的 V 纹理坐标。
	 * @param texsrc 可选的纹理源（默认: 0）。
	 * @param chromakey 可选的色度键颜色索引（默认: -1）。
	 * @param z1 可选的第一个顶点的 Z 坐标（默认: 0）。
	 * @param z2 可选的第二个顶点的 Z 坐标（默认: 0）。
	 * @param z3 可选的第三个顶点的 Z 坐标（默认: 0）。
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
	 * 使用自定义字体绘制文本。
	 * @param text 要绘制的文本。
	 * @param x X 坐标。
	 * @param y Y 坐标。
	 * @param transparent 可选的透明颜色索引。
	 * @param charWidth 可选的字符宽度。
	 * @param charHeight 可选的字符高度。
	 * @param fixed 可选的等宽字体标志（默认: false）。
	 * @param scale 可选的缩放因子（默认: 1）。
	 * @returns 绘制文本的宽度。
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
	/// 地图函数
	/////////////////////////////

	/**
	 * 绘制地图图块层。
	 * @param x 可选的地图 X 坐标（默认: 0）。
	 * @param y 可选的地图 Y 坐标（默认: 0）。
	 * @param w 可选的宽度（以图块为单位，默认: 30）。
	 * @param h 可选的高度（以图块为单位，默认: 17）。
	 * @param sx 可选的精灵 X 偏移（默认: 0）。
	 * @param sy 可选的精灵 Y 偏移（默认: 0）。
	 * @param colorkey 可选的透明颜色键（默认: -1）。
	 * @param scale 可选的缩放因子（默认: 1）。
	 * @param remap 可选的重映射回调函数。
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
	 * 获取地图位置的图块 ID。
	 * @param x 图块的 X 坐标。
	 * @param y 图块的 Y 坐标。
	 * @returns 图块 ID。
	 */
	export function mget(x: number, y: number): number;

	/**
	 * 设置地图位置的图块 ID。
	 * @param x 图块的 X 坐标。
	 * @param y 图块的 Y 坐标。
	 * @param id 要设置的图块 ID。
	 */
	export function mset(x: number, y: number, id: number): void;

	/////////////////////////////
	/// 精灵函数
	/////////////////////////////

	/**
	 * 获取精灵标志。
	 * @param sprite_id 精灵 ID。
	 * @param flag 标志索引 (0-7)。
	 * @returns 如果标志已设置则返回 true，否则返回 false。
	 */
	export function fget(sprite_id: number, flag: number): boolean;

	/**
	 * 设置精灵标志。
	 * @param sprite_id 精灵 ID。
	 * @param flag 标志索引 (0-7)。
	 * @param bool 要设置的标志值。
	 */
	export function fset(sprite_id: number, flag: number, bool: boolean): void;

	/////////////////////////////
	/// 音频函数
	/////////////////////////////

	/**
	 * 播放音效。
	 * @param id 音效 ID。
	 * @param note 可选的音符编号 (0-95，默认: 使用 SFX 音符)。
	 * @param duration 可选的持续时间（以帧为单位，默认: -1，完整持续时间）。
	 * @param channel 可选的通道编号 (0-3，默认: 0)。
	 * @param volume 可选的音量 (0-15，默认: 15)。
	 * @param speed 可选的速度 (0-15，默认: 0)。
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
	 * 播放音乐。
	 * @param track 可选的音轨编号（默认: -1，停止音乐）。
	 * @param frame 可选的帧编号（默认: -1）。
	 * @param row 可选的行编号（默认: -1）。
	 * @param loop 可选的循环标志（默认: true）。
	 */
	export function music(
		track?: number,
		frame?: number,
		row?: number,
		loop?: boolean
	): void;

	/////////////////////////////
	/// 内存函数
	/////////////////////////////

	/**
	 * 从内存读取值。
	 * @param addr 内存地址。
	 * @param bits 可选的位宽：8、16 或 32（默认: 8）。
	 * @returns 从内存读取的值。
	 */
	export function peek(addr: number, bits?: number): number;

	/**
	 * 从内存读取单个位。
	 * @param bitaddr 位地址。
	 * @returns 位值 (0 或 1)。
	 */
	export function peek1(bitaddr: number): number;

	/**
	 * 从内存读取 2 字节值。
	 * @param addr2 内存地址（必须 2 字节对齐）。
	 * @returns 从内存读取的 16 位值。
	 */
	export function peek2(addr2: number): number;

	/**
	 * 从内存读取 4 字节值。
	 * @param addr4 内存地址（必须 4 字节对齐）。
	 * @returns 从内存读取的 32 位值。
	 */
	export function peek4(addr4: number): number;

	/**
	 * 将值写入内存。
	 * @param addr 内存地址。
	 * @param val 要写入的值。
	 */
	export function poke(addr: number, val: number): void;

	/**
	 * 将单个位写入内存。
	 * @param bitaddr 位地址。
	 * @param bitval 位值 (0 或 1)。
	 */
	export function poke1(bitaddr: number, bitval: number): void;

	/**
	 * 将 2 字节值写入内存。
	 * @param addr2 内存地址（必须 2 字节对齐）。
	 * @param val2 要写入的 16 位值。
	 */
	export function poke2(addr2: number, val2: number): void;

	/**
	 * 将 4 字节值写入内存。
	 * @param addr4 内存地址（必须 4 字节对齐）。
	 * @param val4 要写入的 32 位值。
	 */
	export function poke4(addr4: number, val4: number): void;

	/**
	 * 获取或设置持久内存值。
	 * @param index 持久内存索引 (0-255)。
	 * @param val 可选的要设置的值。如果省略，返回当前值。
	 * @returns 持久内存值。
	 */
	export function pmem(index: number, val?: number): number;

	/**
	 * 将内存从一个位置复制到另一个位置。
	 * @param toaddr 目标地址。
	 * @param fromaddr 源地址。
	 * @param len 要复制的字节数。
	 */
	export function memcpy(toaddr: number, fromaddr: number, len: number): void;

	/**
	 * 将内存块设置为值。
	 * @param addr 起始地址。
	 * @param val 要设置的值。
	 * @param len 要设置的字节数。
	 */
	export function memset(addr: number, val: number, len: number): void;

	/////////////////////////////
	/// 系统函数
	/////////////////////////////

	/**
	 * 退出游戏。
	 */
	export function exit(): void;

	/**
	 * 重置游戏。
	 */
	export function reset(): void;

	/**
	 * 同步卡带数据。
	 * @param mask 可选的同步掩码（默认: 0，同步所有）。
	 * @param bank 可选的库编号（默认: 0）。
	 * @param tocart 可选的保存到卡带标志（默认: false）。
	 */
	export function sync(mask?: SyncMask, bank?: number, tocart?: boolean): void;

	/**
	 * 获取当前时间（以毫秒为单位）。
	 * @returns 当前时间（以毫秒为单位）。
	 */
	export function time(): number;

	/**
	 * 获取时间戳。
	 * @returns 时间戳值。
	 */
	export function tstamp(): number;

	/**
	 * 输出跟踪消息。
	 * @param msg 要输出的消息。
	 * @param color 可选的颜色索引。
	 */
	export function trace(msg: string, color?: number): void;

	/**
	 * 切换视频库。
	 * @param bank 库编号 (0 或 1)。
	 */
	export function vbank(bank: number): void;

	/////////////////////////////
	/// 回调函数
	/////////////////////////////

	export const _G: {
		/**
		 * BDR（Between Display Rows，显示行之间）回调允许你在每行扫描线渲染之间执行代码。
		 * 主要用于操作调色板。这样做可以为每行扫描线使用不同的调色板，因此一次可以使用超过 16 种颜色。
		 * @param scanline 即将绘制的扫描行 (0-143)。
		 *                 0-3: 顶部边框
		 *                 4-139: 第 0-135 行 (等价于 SCN(0-135))
		 *                 140-143: 底部边框
		 */
		BDR(this: void, scanline: number): void;

		/**
		 * TIC 函数是主更新/绘制回调，必须在每个程序中存在。
		 * 它不接受参数，每秒被调用 60 次（60fps）。
		 * 在此处放置你的更新和绘制代码。
		 */
		TIC(this: void): void;

		/**
		 * BOOT 函数在卡带启动时被调用一次。
		 * 它应用于启动/初始化代码。对于允许在全局作用域中编写代码的脚本语言（Lua 等），
		 * 使用 BOOT 比在全局作用域中包含源代码更可取。
		 */
		BOOT(this: void): void;
	};
}
