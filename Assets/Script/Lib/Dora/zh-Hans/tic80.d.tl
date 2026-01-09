-- TIC-80 API

-- map() 函数的重映射回调函数类型。
-- @param tile (number) 位置 (x, y) 处的图块 ID
-- @param x (number) 图块的 X 坐标
-- @param y (number) 图块的 Y 坐标
-- @return (number, number | nil, number | nil) 包含 [tile, flip, rotate] 的元组
local type MapRemapCallback = function(tile: number, x: number, y: number): number, number | nil, number | nil

--[[ 输入函数 ]]

-- 检查按钮是否当前被按下。
-- @param id (number) [可选] 按钮 ID (0-31)。如果省略，检查任意按钮是否有按下。
-- 所有玩家的按钮 ID。
-- 玩家 1: 上 0、下 1、左 2、右 3、A 4、B 5、X 6、Y 7
-- 玩家 2: 上 8、下 9、左 10、右 11、A 12、B 13、X 14、Y 15
-- 玩家 3: 上 16、下 17、左 18、右 19、A 20、B 21、X 22、Y 23
-- 玩家 4: 上 24、下 25、左 26、右 27、A 28、B 29、X 30、Y 31
-- @return (boolean) 如果按钮被按下则返回 true，否则返回 false。
global btn: function(id?: number): boolean

-- 检查按钮是否刚刚被按下（在本帧）。
-- @param id (number) [可选] 按钮 ID (0-31)。如果省略，检查所有按钮。
-- @param hold (number) [可选] 按住时间（以帧为单位）。
-- @param period (number) [可选] 重复周期（以帧为单位）。
-- @return (boolean) 如果按钮刚刚被按下则返回 true，否则返回 false。
global btnp: function(id?: number, hold?: number, period?: number): boolean

-- 检查键盘按键是否当前被按下。
-- @param code (number) [可选] 按键代码。如果省略，检查所有按键。
-- 字母 A-Z: 0-25
-- 数字 0-9: 27-36
-- 特殊键: 37-65
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
-- @return (boolean) 如果按键被按下则返回 true，否则返回 false。
global key: function(code?: number): boolean

-- 检查键盘按键是否刚刚被按下（在本帧）。
-- @param code (number) [可选] 按键代码。如果省略，检查所有按键。
-- @param hold (number) [可选] 按住时间（以帧为单位）。
-- @param period (number) [可选] 重复周期（以帧为单位）。
-- @return (boolean) 如果按键刚刚被按下则返回 true，否则返回 false。
global keyp: function(code?: number, hold?: number, period?: number): boolean

-- 获取当前鼠标状态。
-- @return (number, number, number, number, number, number, number) 包含 [x, y, left, middle, right, scrollx, scrolly] 的多返回值
global mouse: function(): number, number, number, number, number, number, number

--[[ 图形函数 ]]

-- 设置绘制裁剪区域。
-- @param x (number) 裁剪区域的 X 坐标。
-- @param y (number) 裁剪区域的 Y 坐标。
-- @param w (number) 裁剪区域的宽度。
-- @param h (number) 裁剪区域的高度。
global clip: function(x: number, y: number, w: number, h: number)

-- 用颜色清空屏幕。
-- @param color (number) [可选] 颜色索引（默认: 0）。
global cls: function(color?: number)

-- 绘制填充圆形。
-- @param x (number) 圆心的 X 坐标。
-- @param y (number) 圆心的 Y 坐标。
-- @param radius (number) 圆的半径。
-- @param color (number) 颜色索引。
global circ: function(x: number, y: number, radius: number, color: number)

-- 绘制圆形轮廓。
-- @param x (number) 圆心的 X 坐标。
-- @param y (number) 圆心的 Y 坐标。
-- @param radius (number) 圆的半径。
-- @param color (number) 颜色索引。
global circb: function(x: number, y: number, radius: number, color: number)

-- 绘制填充椭圆。
-- @param x (number) 椭圆中心的 X 坐标。
-- @param y (number) 椭圆中心的 Y 坐标。
-- @param a (number) 水平半径。
-- @param b (number) 垂直半径。
-- @param color (number) 颜色索引。
global elli: function(x: number, y: number, a: number, b: number, color: number)

-- 绘制椭圆轮廓。
-- @param x (number) 椭圆中心的 X 坐标。
-- @param y (number) 椭圆中心的 Y 坐标。
-- @param a (number) 水平半径。
-- @param b (number) 垂直半径。
-- @param color (number) 颜色索引。
global ellib: function(x: number, y: number, a: number, b: number, color: number)

-- 绘制直线。
-- @param x0 (number) 起点的 X 坐标。
-- @param y0 (number) 起点的 Y 坐标。
-- @param x1 (number) 终点的 X 坐标。
-- @param y1 (number) 终点的 Y 坐标。
-- @param color (number) 颜色索引。
global line: function(x0: number, y0: number, x1: number, y1: number, color: number)

-- 获取或设置像素颜色。
-- @param x (number) X 坐标。
-- @param y (number) Y 坐标。
-- @param color (number?) 可选的颜色索引。如果提供，则设置像素颜色。
-- @return (number) 指定位置的颜色索引。
global pix: function(x: number, y: number, color?: number): number

-- 在屏幕上打印文本。
-- @param text (string) 要打印的文本。
-- @param x (number) [可选] X 坐标（默认: 0）。
-- @param y (number) [可选] Y 坐标（默认: 0）。
-- @param color (number) [可选] 颜色索引（默认: 12）。
-- @param fixed (boolean) [可选] 等宽字体标志（默认: false）。
-- @param scale (number) [可选] 缩放因子（默认: 1）。
-- @param smallfont (boolean) [可选] 小字体标志（默认: false）。
-- @return (number) 打印文本的宽度。
global print: function(text: string, x?: number, y?: number, color?: number, fixed?: boolean, scale?: number, smallfont?: boolean): number

-- 绘制填充矩形。
-- @param x (number) 左上角的 X 坐标。
-- @param y (number) 左上角的 Y 坐标。
-- @param w (number) 矩形的宽度。
-- @param h (number) 矩形的高度。
-- @param color (number) 颜色索引。
global rect: function(x: number, y: number, w: number, h: number, color: number)

-- 绘制矩形轮廓。
-- @param x (number) 左上角的 X 坐标。
-- @param y (number) 左上角的 Y 坐标。
-- @param w (number) 矩形的宽度。
-- @param h (number) 矩形的高度。
-- @param color (number) 颜色索引。
global rectb: function(x: number, y: number, w: number, h: number, color: number)

-- 绘制精灵。
-- @param id (number) 精灵 ID。
-- @param x (number) X 坐标。
-- @param y (number) Y 坐标。
-- @param transparent (number) [可选] 透明颜色索引（默认: -1，无透明）。
-- @param scale (number) [可选] 缩放因子（默认: 1）。
-- @param flip (number) [可选] 翻转标志：1=水平，2=垂直，3=两者（默认: 0）。
-- @param rotate (number) [可选] 旋转：1=90°，2=180°，3=270° 顺时针（默认: 0）。
-- @param w (number) [可选] 精灵宽度（以图块为单位，默认: 1）。
-- @param h (number) [可选] 精灵高度（以图块为单位，默认: 1）。
global spr: function(id: number, x: number, y: number, transparent?: number, scale?: number, flip?: number, rotate?: number, w?: number, h?: number)

-- 绘制填充三角形。
-- @param x1 (number) 第一个顶点的 X 坐标。
-- @param y1 (number) 第一个顶点的 Y 坐标。
-- @param x2 (number) 第二个顶点的 X 坐标。
-- @param y2 (number) 第二个顶点的 Y 坐标。
-- @param x3 (number) 第三个顶点的 X 坐标。
-- @param y3 (number) 第三个顶点的 Y 坐标。
-- @param color (number) 颜色索引。
global tri: function(x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, color: number)

-- 绘制三角形轮廓。
-- @param x1 (number) 第一个顶点的 X 坐标。
-- @param y1 (number) 第一个顶点的 Y 坐标。
-- @param x2 (number) 第二个顶点的 X 坐标。
-- @param y2 (number) 第二个顶点的 Y 坐标。
-- @param x3 (number) 第三个顶点的 X 坐标。
-- @param y3 (number) 第三个顶点的 Y 坐标。
-- @param color (number) 颜色索引。
global trib: function(x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, color: number)

-- 绘制纹理三角形。
-- @param x1 (number) 第一个顶点的 X 坐标。
-- @param y1 (number) 第一个顶点的 Y 坐标。
-- @param x2 (number) 第二个顶点的 X 坐标。
-- @param y2 (number) 第二个顶点的 Y 坐标。
-- @param x3 (number) 第三个顶点的 X 坐标。
-- @param y3 (number) 第三个顶点的 Y 坐标。
-- @param u1 (number) 第一个顶点的 U 纹理坐标。
-- @param v1 (number) 第一个顶点的 V 纹理坐标。
-- @param u2 (number) 第二个顶点的 U 纹理坐标。
-- @param v2 (number) 第二个顶点的 V 纹理坐标。
-- @param u3 (number) 第三个顶点的 U 纹理坐标。
-- @param v3 (number) 第三个顶点的 V 纹理坐标。
-- @param texsrc (number) [可选] 纹理源（默认: 0）。
-- @param chromakey (number) [可选] 色度键颜色索引（默认: -1）。
-- @param z1 (number) [可选] 第一个顶点的 Z 坐标（默认: 0）。
-- @param z2 (number) [可选] 第二个顶点的 Z 坐标（默认: 0）。
-- @param z3 (number) [可选] 第三个顶点的 Z 坐标（默认: 0）。
global ttri: function(x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, u1: number, v1: number, u2: number, v2: number, u3: number, v3: number, texsrc?: number, chromakey?: number, z1?: number, z2?: number, z3?: number)

-- 使用自定义字体绘制文本。
-- @param text (string) 要绘制的文本。
-- @param x (number) X 坐标。
-- @param y (number) Y 坐标。
-- @param transparent (number) [可选] 透明颜色索引。
-- @param charWidth (number) [可选] 字符宽度。
-- @param charHeight (number) [可选] 字符高度。
-- @param fixed (boolean) [可选] 等宽字体标志（默认: false）。
-- @param scale (number) [可选] 缩放因子（默认: 1）。
-- @return (number) 绘制文本的宽度。
global font: function(text: string, x: number, y: number, transparent?: number, charWidth?: number, charHeight?: number, fixed?: boolean, scale?: number): number

--[[ 地图函数 ]]

-- 绘制地图图块层。
-- @param x (number) [可选] 地图 X 坐标（默认: 0）。
-- @param y (number) [可选] 地图 Y 坐标（默认: 0）。
-- @param w (number) [可选] 宽度（以图块为单位，默认: 30）。
-- @param h (number) [可选] 高度（以图块为单位，默认: 17）。
-- @param sx (number) [可选] 精灵 X 偏移（默认: 0）。
-- @param sy (number) [可选] 精灵 Y 偏移（默认: 0）。
-- @param colorkey (number) [可选] 透明颜色键（默认: -1）。
-- @param scale (number) [可选] 缩放因子（默认: 1）。
-- @param remap (MapRemapCallback) [可选] 重映射回调函数。
global map: function(x?: number, y?: number, w?: number, h?: number, sx?: number, sy?: number, colorkey?: number, scale?: number, remap?: MapRemapCallback)

-- 获取地图位置的图块 ID。
-- @param x (number) 图块的 X 坐标。
-- @param y (number) 图块的 Y 坐标。
-- @return (number) 图块 ID。
global mget: function(x: number, y: number): number

-- 设置地图位置的图块 ID。
-- @param x (number) 图块的 X 坐标。
-- @param y (number) 图块的 Y 坐标。
-- @param id (number) 要设置的图块 ID。
global mset: function(x: number, y: number, id: number)

--[[ 精灵函数 ]]

-- 获取精灵标志。
-- @param sprite_id (number) 精灵 ID。
-- @param flag (number) 标志索引 (0-7)。
-- @return (boolean) 如果标志已设置则返回 true，否则返回 false。
global fget: function(sprite_id: number, flag: number): boolean

-- 设置精灵标志。
-- @param sprite_id (number) 精灵 ID。
-- @param flag (number) 标志索引 (0-7)。
-- @param bool (boolean) 要设置的标志值。
global fset: function(sprite_id: number, flag: number, bool: boolean)

--[[ 音频函数 ]]

-- 播放音效。
-- @param id (number) 音效 ID。
-- @param note (number) [可选] 音符编号 (0-95，默认: 使用 SFX 音符)。
-- @param duration (number) [可选] 持续时间（以帧为单位，默认: -1，完整持续时间）。
-- @param channel (number) [可选] 通道编号 (0-3，默认: 0)。
-- @param volume (number) [可选] 音量 (0-15，默认: 15)。
-- @param speed (number) [可选] 速度 (0-15，默认: 0)。
global sfx: function(id: number, note?: number, duration?: number, channel?: number, volume?: number, speed?: number)

-- 播放音乐。
-- @param track (number) [可选] 音轨编号（默认: -1，停止音乐）。
-- @param frame (number) [可选] 帧编号（默认: -1）。
-- @param row (number) [可选] 行编号（默认: -1）。
-- @param loop (boolean) [可选] 循环标志（默认: true）。
global music: function(track?: number, frame?: number, row?: number, loop?: boolean)

--[[ 内存函数 ]]

-- 从内存读取值。
-- @param addr (number) 内存地址。
-- @param bits (number) [可选] 位宽：8、16 或 32（默认: 8）。
-- @return (number) 从内存读取的值。
global peek: function(addr: number, bits?: number): number

-- 从内存读取单个位。
-- @param bitaddr (number) 位地址。
-- @return (number) 位值 (0 或 1)。
global peek1: function(bitaddr: number): number

-- 从内存读取 2 字节值。
-- @param addr2 (number) 内存地址（必须 2 字节对齐）。
-- @return (number) 从内存读取的 16 位值。
global peek2: function(addr2: number): number

-- 从内存读取 4 字节值。
-- @param addr4 (number) 内存地址（必须 4 字节对齐）。
-- @return (number) 从内存读取的 32 位值。
global peek4: function(addr4: number): number

-- 将值写入内存。
-- @param addr (number) 内存地址。
-- @param val (number) 要写入的值。
global poke: function(addr: number, val: number)

-- 将单个位写入内存。
-- @param bitaddr (number) 位地址。
-- @param bitval (number) 位值 (0 或 1)。
global poke1: function(bitaddr: number, bitval: number)

-- 将 2 字节值写入内存。
-- @param addr2 (number) 内存地址（必须 2 字节对齐）。
-- @param val2 (number) 要写入的 16 位值。
global poke2: function(addr2: number, val2: number)

-- 将 4 字节值写入内存。
-- @param addr4 (number) 内存地址（必须 4 字节对齐）。
-- @param val4 (number) 要写入的 32 位值。
global poke4: function(addr4: number, val4: number)

-- 获取或设置持久内存值。
-- @param index (number) 持久内存索引 (0-255)。
-- @param val (number) [可选] 要设置的值。如果省略，返回当前值。
-- @return (number) 持久内存值。
global pmem: function(index: number, val?: number): number

-- 将内存从一个位置复制到另一个位置。
-- @param toaddr (number) 目标地址。
-- @param fromaddr (number) 源地址。
-- @param len (number) 要复制的字节数。
global memcpy: function(toaddr: number, fromaddr: number, len: number)

-- 将内存块设置为值。
-- @param addr (number) 起始地址。
-- @param val (number) 要设置的值。
-- @param len (number) 要设置的字节数。
global memset: function(addr: number, val: number, len: number)

--[[ 回调函数 ]]

-- BDR（Between Display Rows，显示行之间）回调允许你在每行扫描线渲染之间执行代码。
-- 主要用于操作调色板。这样做可以为每行扫描线使用不同的调色板，因此一次可以使用超过 16 种颜色。
-- @param scanline (number) 即将绘制的扫描行 (0-143)。
--                 0-3: 顶部边框
--                 4-139: 第 0-135 行 (等价于 SCN(0-135))
--                 140-143: 底部边框
global BDR: function(scanline: number)

-- TIC 函数是主更新/绘制回调，必须在每个程序中存在。
-- 它不接受参数，每秒被调用 60 次（60fps）。
-- 在此处放置你的更新和绘制代码。
global TIC: function()

-- BOOT 函数在卡带启动时被调用一次。
-- 它应用于启动/初始化代码。对于允许在全局作用域中编写代码的脚本语言（Lua 等），
-- 使用 BOOT 比在全局作用域中包含源代码更可取。
global BOOT: function()

--[[ 系统函数 ]]

-- 退出游戏。
global exit: function()

-- 重置游戏。
global reset: function()

-- 同步卡带数据。
-- @param mask (number) [可选] 同步掩码（默认: 0，同步所有）。
-- Tiles = 1 << 0
-- Sprites = 1 << 1
-- Map = 1 << 2
-- Sfx = 1 << 3
-- Music = 1 << 4
-- Palette = 1 << 5
-- Flags = 1 << 6
-- Screen = 1 << 7
-- @param bank (number) [可选] 库编号（默认: 0）。
-- @param tocart (boolean) [可选] 保存到卡带标志（默认: false）。
global sync: function(mask?: number, bank?: number, tocart?: boolean)

-- 获取当前时间（以毫秒为单位）。
-- @return (number) 当前时间（以毫秒为单位）。
global time: function(): number

-- 获取时间戳。
-- @return (number) 时间戳值。
global tstamp: function(): number

-- 输出跟踪消息。
-- @param msg (string) 要输出的消息。
-- @param color (number) [可选] 颜色索引。
global trace: function(msg: string, color?: number)

-- 切换视频库。
-- @param bank (number) 库编号 (0 或 1)。
global vbank: function(bank: number)
