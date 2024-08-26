-- 载入模式的枚举类型。
local enum LoadMode

	-- 二进制模式
	"b"

	-- 文本模式
	"t"

	-- 二进制和文本模式
	"bt"
end

-- 选择长度标志的枚举类型。
local enum SelectLengthFlag
	"#"
end

-- 垃圾回收器操作的枚举类型。
local enum CollectorOperationA

	-- 执行完整的垃圾回收周期。这是默认选项。
	"collect"

	-- 停止垃圾回收器的自动执行。垃圾回收器只会在显式调用时运行，直到调用重启。
	"stop"

	-- 重启垃圾回收器的自动执行。
	"restart"

	-- 返回 Lua 使用的总内存（以 KB 为单位）。该值有小数部分，因此乘以 1024 可以得到 Lua 实际使用的字节数。
	"count"
end

-- 垃圾回收器操作的枚举类型。
local enum GarbageCollectorOperationB

	-- 执行一个垃圾回收步骤。步骤的“大小”由 arg 控制。若值为零，则回收器执行一个基本的（不可分割的）步骤。非零值表示回收器将执行与分配了该数量内存（以 KB 为单位）的 Lua 相当的操作。如果步骤完成了一个回收周期，则返回 true。
	"step"
end

-- 垃圾回收器操作的枚举类型。
local enum GarbageCollectorOperationC

	-- 返回一个布尔值，表示垃圾回收器是否正在运行（即未停止）。
	"isrunning"
end

-- 垃圾回收器操作的枚举类型。
local enum GarbageCollectorOperationD

	-- 获取或设置垃圾回收器参数。无参数时，返回当前参数的值。有参数时，设置参数的值并返回当前值。
	"param"
end

-- 垃圾回收器参数的枚举类型。
local enum GarbageCollectorParameter

	-- 垃圾回收器暂停参数控制回收器在启动新回收周期之前等待的时间。
	-- 当对象数量达到上一个回收周期后的总数的 `pause` 倍时，回收器将启动新周期。
	-- 较大的值会使回收器更不积极。
	-- 小于或等于 100 的值表示回收器不等待时间来启动新周期。
	-- 值为 200 表示回收器在总对象数量翻倍之前等待启动新周期。
	-- 默认值为 200。
	"pause"

	-- 垃圾回收器步进乘数参数控制每个 GC 步骤的大小。
	-- `stepmul` 的值表示解释器在每个步骤中会标记或清除 `stepmul` 个对象。
	-- 较大的值会使回收器更积极。
	-- 注意，值太小可能使回收器太慢而无法完成一个周期。
	-- 默认值为 200。
	-- 作为特例，零值表示无限工作，实际上产生一个非增量的、会停止世界的回收器。
	"stepmul"

	-- 垃圾回收器步长参数控制每个增量步骤的大小，具体是在执行步骤之前解释器创建多少个对象：
	-- `stepsize` 的值表示解释器在步骤之间大约创建 `stepsize` 个对象。
	-- 默认值为 250。
	"stepsize"

	-- 小型回收器乘数参数控制小型回收的频率。
	-- 对于小型乘数 `minormul`，当对象数量比上一个大型回收后使用的数量增加 `minormul` 倍时，将执行新的小型回收。
	-- 例如，对于乘数为 20，当对象数量比上一个大型回收后的总数增加 20% 时，回收器将执行小型回收。
	-- 默认值为 25。
	"minormul"

	-- 小型-大型乘数参数控制切换到大型回收的时机。
	-- 对于乘数 `minormajor`，当旧对象数量比上一个大型回收后的总数增加 `minormajor` 时，回收器将切换到大型回收。
	-- 例如，对于乘数为 100，当旧对象数量比上一个大型回收后的总数的两倍还多时，回收器将执行大型回收。
	-- 默认值为 100。
	"minormajor"

	-- 大型-小型乘数参数控制切换回小型回收的时机。
	-- 对于乘数 `majorminor`，在大型回收收集到上一个周期分配的对象的至少 `majorminor` 倍之后，回收器将切换回小型回收。
	-- 特别地，对于乘数为 0，回收器在执行一次大型回收周期后立即切换回小型回收。
	-- 默认值为 50。
	"majorminor"
end

-- 垃圾回收模式的枚举类型。
local enum GarbageCollectionMode

	-- 将回收器模式更改为增量模式。
	"incremental"

	-- 将回收器模式更改为分代模式。
	"generational"
end

-- Lua 标准库。
local record lua
	-- 载入指定模块。
	-- @param modname (string) 要载入的模块名称。
	-- @return (any) 如果模块已经载入，则返回 package.loaded[modname] 中的值。
	-- 否则，尝试查找一个加载器，并返回 package.loaded[modname] 的最终值以及作为第二个结果的加载器数据。
	require: function(modname: string)

	-- 如果参数 v 的值为 false（nil 或 false），则抛出错误；否则，返回所有参数。
	-- 在出错的情况下，message 是错误对象；如果缺失，默认为“断言失败！”。
	-- @param v (any) 要测试的值。
	-- @param message (string) [可选] 错误消息。
	-- @return (...) 如果 v 不为 false，则返回所有参数。
	assert: function(v: any, message?: string): any...

	-- 打开文件并执行其内容作为 Lua 块。
	-- 返回块返回的所有值。将错误传播给调用者。
	-- @param filename (string) 要执行的文件名。
	-- @return (...) 块返回的值。
	dofile: function(filename: string): any...

	-- 使用 message 作为错误对象抛出错误。此函数永不返回。
	-- 如果 message 是字符串，则向消息中添加错误位置信息。
	-- @param message (any) 错误对象，可以是字符串消息。
	-- @param level (number) [可选] 指定获取错误位置的方式。
	error: function(message: any, level?: number)

	-- 一个全局变量，保存全局环境。更改其值不会影响任何环境。
	_G: table

	-- 返回给定对象的元表。
	-- 如果对象的元表具有 __metatable 字段，则返回其值。否则，返回元表。
	-- @param object (any) 要从中获取元表的对象。
	-- @return (metatable<T> | nil) 元表或 nil（如果没有）。
	getmetatable: function<T>(object: any): metatable<T> | nil

	-- 返回用于迭代类似数组的表的迭代器函数。
	-- @param t (table) 要迭代的表。
	-- @return (function) 迭代器函数，表 t 和 0。
	ipairs: function<A>(t: {A}): function(): (integer, A), {A}, integer

	-- 加载一个块。如果 chunk 是字符串，则它是块。如果是函数，则调用它以获取块片段。
	-- @param chunk (string | function) 块或提供块的函数。
	-- @param chunkname (string) [可选] 块的名称，用于错误消息。
	-- @param mode (LoadMode) [可选] 控制块可以是文本还是二进制。
	-- @param env (table) [可选] 块的环境。
	-- @return (function | nil, nil | string) 编译后的块作为函数，或 nil 和错误消息。
	load: function(chunk: (string | function(): string), chunkname?: string, mode?: LoadMode, env?: table): function, string

	-- 类似于 load，但从文件或标准输入中获取块（如果没有提供文件名）。
	-- @param filename (string) [可选] 从中加载块的文件名。
	-- @param mode (LoadMode) [可选] 块的模式。
	-- @param env (table) [可选] 块的环境。
	-- @return (function | nil, nil | string) 加载的块作为函数，或 nil 和错误消息。
	loadfile: function(filename?: string, mode?: LoadMode, env?: table): function, string

	-- 允许遍历表的所有字段。返回下一个索引及其值。
	-- @param table (table) 要遍历的表。
	-- @param index (any) [可选] 表中当前的索引。
	-- @return (any, any) 下一个索引及其关联值，或 nil（如果在末尾）。
	next: function<A, B>(table: {A: B}, index?: A): A, B

	-- 允许遍历表的所有字段。返回下一个索引及其值。
	-- @param table (table) 要遍历的表。
	-- @param index (any) [可选] 表中当前的索引。
	-- @return (any, any) 下一个索引及其关联值，或 nil（如果在末尾）。
	next: function<A>(table: {A}, index?: A): integer, A

	-- 遍历表中的所有键值对。
	-- 如果 t 有一个 __pairs 元方法，调用它并返回从调用中得到的前三个结果。
	-- 否则，返回三个值：next 函数，表 t 和 nil。
	-- @param t (table) 要遍历的表。
	-- @return (function, table, any) 迭代器函数，遍历的表，当前的表键。
	pairs: function<A, B>(t: {A: B}): function<A, B>(table: {A: B}, index?: A): (A, B), {A: B}, any

	-- 以保护模式调用函数。
	-- 捕获任何错误并返回状态码及结果或错误对象。
	-- @param f (function) 要调用的函数。
	-- @param ... (any) 传递给函数的参数。
	-- @return (boolean, ...) 状态码及函数结果或错误对象。
	pcall: function(f: function, ...: any): boolean, any...

	-- 将值打印到标准输出。
	-- 将每个参数转换为字符串并打印。
	-- @param ... (any) 要打印的值。
	print: function(...: any)

	-- 检查两个值是否原始相等。
	-- 比较时不调用__eq元方法。
	-- @param v1 (any) 要比较的值。
	-- @param v2 (any) 要比较的值。
	-- @return (boolean) 如果v1等于v2则为真，否则为假。
	rawequal: function(v1: any, v2: any): boolean

	-- 获取给定索引处表的真实值。
	-- 不使用__index元方法。
	-- @param table (table) 要索引的表。
	-- @param index (any) 要检索的索引。
	-- @return (any) 给定索引处的值。
	rawget: function(table: table, index: any): any

	-- 返回对象的长度，不调用__len元方法。
	-- @param v (table | string) 要获取长度的对象。
	-- @return (integer) 对象的长度。
	rawlen: function(v: table | string): integer

	-- 在给定索引处设置表的真实值。
	-- 不使用__newindex元方法。
	-- @param table (table) 要修改的表。
	-- @param index (any) 要设置的索引。
	-- @param value (any) 要设置的值。
	-- @return (table) 修改后的表。
	rawset: function<A, B>(table: {A : B}, index: A, value: B): {A}

	-- 设置表格中指定索引的真实值。
	-- 不使用 __newindex 元方法。
	-- @param table (table) 需要修改的表格。
	-- @param index (number) 要设置的索引。
	-- @param value (any) 要设置的值。
	-- @return (table) 被修改后的表格。
	rawset: function<A>(table: {A}, index: number, value: A): {A}

	-- 根据索引选择参数。
	-- 返回参数索引处的参数。负数索引表示从末尾开始（-1是最后一个参数）。
	-- @param index (integer) 开始的索引，或'#'表示总数。
	-- @param ... (any) 要选择的参数。
	-- @return (...) 选择的参数。
	select: function<A>(number, ...: A): A

	-- 根据索引选择参数。
	-- 返回指定索引位置的参数。负数索引表示从末尾开始计数（-1 表示最后一个参数）。
	-- @param index (integer) 起始索引，或用 '#' 表示参数总数。
	-- @param ... (any) 用于选择的参数。
	-- @return (...) 选中的参数。
	select: function(number, ...: any): any

	-- 选择参数总数。
	-- @param flag (SelectLengthFlag) 总数的'#'标记。
	-- @param ... (any) 要选择的参数。
	-- @return (integer) 参数总数。
	select: function(flag: SelectLengthFlag, ...: any): integer

	-- 设置或移除表的元表。
	-- @param table (table) 要修改的表。
	-- @param metatable (table | nil) 要设置的元表，或nil以移除。
	-- @return (table) 修改后的表。
	setmetatable: function<A>(table: A, metatable: metatable<A> | nil): A

	-- 将参数转换为数字。
	-- 尝试将字符串转换为数字。
	-- @param e (string) 要转换的值。
	-- @return (number | nil) 转换后的数字或失败时为nil。
	tonumber: function(e: string): number | nil

	-- Converts an argument to a number.
	-- Tries to convert a string or number to a number, with an optional base.
	-- @param e (string | number) The value to convert.
	-- @param base (number) [optional] The base for conversion.
	-- @return (integer | nil) The converted number or nil on failure.
	tonumber: function(e: string | number, base: number): integer | nil

	-- 将值转换为字符串。
	-- 如果可用，使用__tostring元方法。
	-- @param v (any) 要转换的值。
	-- @return (string) 字符串表示形式。
	tostring: function(v: any): string

	-- 返回值的类型（字符串形式）。
	-- @param v (any) 要获取类型的值。
	-- @return (string) 值的类型。
	type: function(v: any): string

	-- 一个全局变量，包含运行中的Lua版本。
	_VERSION: string

	-- 发出带有连接消息的警告。
	-- 通常，以'@'开头的单个消息意味着控制消息，即发给警告系统本身的消息。特别是，Lua的标准警告函数识别控制消息"@off"（停止发出警告）和"@on"（重新开始发出警告）；它忽略未知的控制消息。
	-- @param ... (string) 要连接的消息部分。
	warn: function(...: string)

	-- 使用自定义消息处理器调用函数。
	-- 类似于pcall，但有消息处理器。
	-- @param f (function) 要调用的函数。
	-- @param msgh (function) 消息处理器。
	-- @param ... (any) 传递给函数的参数。
	-- @return (boolean, ...) 状态码及函数结果或错误对象。
	xpcall: function(f: function, msgh: (function(err: string): string), ...: any): boolean, any...

	-- 垃圾收集器的通用接口。根据第一个参数opt执行不同的功能。
	-- @param opt (CollectorOperationA) 要执行的垃圾收集器操作。
	-- @return (number) 取决于opt参数。
	collectgarbage: function(opt: CollectorOperationA): number

	-- 垃圾收集器的通用接口。根据首个参数 opt 决定执行的不同功能。
	-- @param opt ("step") 要执行的垃圾收集操作。
	-- @param arg (number) 操作的步幅大小。
	-- @return (boolean) 返回值依据 opt 参数而定。
	collectgarbage: function(opt: GarbageCollectorOperationB, arg: number): boolean

	-- 垃圾收集器的通用接口。根据首个参数 opt 决定执行的不同功能。
	-- @param opt ("isrunning") 要执行的垃圾收集相关操作。
	-- @return (bool) 收集器是否正在运行。
	collectgarbage: function(opt: GarbageCollectorOperationC): boolean

	-- 垃圾收集器的通用接口。根据第一个参数opt执行不同的功能。
	-- @param opt ("param") 垃圾收集器操作。
	-- @param param (GarbageCollectorParameter) 要获取或设置的参数。
	-- @param value (number) [可选] 参数的新值。
	-- @return (number) 参数的当前值。
	collectgarbage: function(opt: GarbageCollectorOperationD, param: GarbageCollectorParameter, value?: number): number

	-- 垃圾收集器的通用接口。根据第一个参数opt执行不同的功能。
	-- @param opt ("generational" | "incremental" ) 垃圾收集器操作。
	collectgarbage: function(opt: GarbageCollectionMode)

	-- 提供基本数学函数的库。
	record math

		-- 返回浮点数x的绝对值。
		-- @param x (number) 输入的数字。
		-- @return (number) x的绝对值。
		abs: function(x: number): number

		-- Returns the absolute value of integer x.
		-- @param x (integer) The input number.
		-- @return (integer) The absolute value of x.
		abs: function(x: integer): integer

		-- 返回x的反余弦值（以弧度为单位）。
		-- @param x (number) 输入的数字。
		-- @return (number) x的反余弦值。
		acos: function(x: number): number

		-- Returns the arc sine of x (in radians).
		-- @param x (number) The input number.
		-- @return (number) The arc sine of x.
		asin: function(x: number): number

		-- Returns the arc tangent of y/x (in radians), considering the quadrant.
		-- @param y (number) The y value.
		-- @param x (number) [optional] The x value, defaults to 1.
		-- @return (number) The arc tangent of y/x.
		atan: function(y: number, x?: number): number

		-- 返回大于或等于x的最小整数。
		-- @param x (number) 输入的数字。
		-- @return (integer) 大于或等于x的最小整数。
		ceil: function(x: number): integer

		-- 返回x的余弦值（以弧度为单位）。
		-- @param x (number) 输入的数字。
		-- @return (number) x的余弦值。
		cos: function(x: number): number

		-- 将角度x从弧度转换为度。
		-- @param x (number) 输入的数字。
		-- @return (number) 角度（度）。
		deg: function(x: number): number

		-- 返回e^x的值。
		-- @param x (number) 输入的数字。
		-- @return (number) e^x的值。
		exp: function(x: number): number

		-- 返回小于或等于x的最大整数。
		-- @param x (number) 输入的数字。
		-- @return (integer) 小于或等于x的最大整数。
		floor: function(x: number): integer

		-- 返回x除以浮点数y后的余数。
		-- @param x (number) 被除数。
		-- @param y (number) 除数。
		-- @return (number) x除以y的余数。
		fmod: function(x: number, y: number): number

		-- 返回整数x除以整数y后的余数。
		-- @param x (integer) 被除数。
		-- @param y (integer) 除数。
		-- @return (integer) x除以y的余数。
		fmod: function(x: integer, y: integer): integer

		-- 代表无穷大的浮点数值。
		huge: number

		-- 返回x的以指定底数（默认为e）的对数。
		-- @param x (number) 输入数字。
		-- @param base (number) [可选] 对数的底数。
		-- @return (number) x以给定底数的对数。
		log: function(x: number, base?: number): number

		-- 返回其参数中的最大值。
		-- @param ... (integer) 输入整数。
		-- @return (integer) 参数中的最大值。
		max: function(...: integer): integer

		-- 返回其参数中的最大值。
		-- @param ... (number) 输入数字。
		-- @return (number) 参数中的最大值。
		max: function(...: number): number

		-- 返回其参数中的最大值。
		-- @param ... (number | integer) 输入数字。
		-- @return (number | integer) 参数中的最大值。
		max: function(...: number | integer): number | integer

		-- 返回其参数中的最大值。
		-- @param ... (any) 输入可比较的值。
		-- @return (any) 参数中的最大值。
		max: function(...: any): any

		-- 具有最大值的整数。
		maxinteger: number

		-- 返回其参数中的最小值。
		-- @param ... (integer) 输入整数。
		-- @return (integer) 参数中的最小值。
		min: function(...: integer): integer

		-- 返回其参数中的最小值。
		-- @param ... (number) 输入数字。
		-- @return (number) 参数中的最小值。
		min: function(...: number): number

		-- 返回其参数中的最小值。
		-- @param ... (number | integer) 输入数字。
		-- @return (number | integer) 参数中的最小值。
		min: function(...: number | integer): number | integer

		-- 返回其参数中的最小值。
		-- @param ... (any) 输入可比较的值。
		-- @return (any) 参数中的最小值。
		min: function(...: any): any

		-- 具有最小值的整数。
		mininteger: number

		-- 返回x的整数部分和小数部分。
		-- @param x (number) 输入数字。
		-- @return (integer, number) x的整数部分和小数部分。
		modf: function(x: number): integer, number

		-- 返回数字π的值。
		pi: number

		-- 将角度x从度转换为弧度。
		-- @param x (number) 输入的数字。
		-- @return (number) 角度（弧度）。
		rad: function(x: number): number

		-- 返回一个伪随机64位整数。
		-- @param m (number) 下限范围。
		-- @param n (number) [可选] 上限范围。
		-- @return (integer) 一个伪随机整数。
		random: function(m: number, n?: number): integer

		-- 返回在区间[0,1)内均匀分布的伪随机浮点数。
		-- @return (number) 一个伪随机数。
		random: function(): number

		-- 对伪随机数生成器进行种子设定。
		-- @param x (number) [可选] 第一个种子成分。
		-- @param y (number) [可选] 第二个种子成分。
		-- @return (integer, integer) 使用的种子成分。
		randomseed: function(x?: number, y?: number): integer, integer

		-- 返回x的正弦值（以弧度为单位）。
		-- @param x (number) 输入的数字。
		-- @return (number) x的正弦值。
		sin: function(x: number): number

		-- 返回x的平方根。
		-- @param x (number) 输入的数字。
		-- @return (number) x的平方根。
		sqrt: function(x: number): number

		-- 返回x的正切值（以弧度为单位）。
		-- @param x (number) 输入的数字。
		-- @return (number) x的正切值。
		tan: function(x: number): number

		-- 将x转换为整数，如果不可能则失败。
		-- @param x (number) 输入数字。
		-- @return (number | nil) x的整数值，或者在转换不可能时失败。
		tointeger: function(x: number): number | nil

		enum NumberType
			"integer"
			"float"
		end

		-- 根据x的类型返回"integer"或"float"，如果不是数字则失败。
		-- @param x (number | integer) 输入数字。
		-- @return (NumberType | nil) x的类型。
		type: function(x: number | integer): NumberType | nil

		-- 如果无符号整数m低于n，则返回true。
		-- @param m (number) 第一个整数。
		-- @param n (number) 第二个整数。
		-- @return (boolean) 如果无符号整数m低于n，则为true。
		ult: function(m: number, n: number): boolean
	end

	-- 提供基本的UTF-8编码支持的库。
	record utf8

		-- 接收零个或多个整数，将每个整数转换为对应的UTF-8字节序列，并返回这些序列的字符串连接。
		-- @param ... (integer) 要转换的零个或多个整数。
		-- @return (string) 连接的UTF-8字节序列。
		char: function(...: integer): string

		-- 用于精确匹配一个UTF-8字节序列的模式，假设主题是有效的UTF-8字符串。
		charpattern: string

		-- 遍历字符串中的所有UTF-8字符，包括每个字符的字节位置和代码点。
		-- @param s (string) 输入字符串。
		-- @param lax (boolean) [可选] 如果为true，则放宽验证检查。
		-- @return (function) UTF-8字符的迭代器函数。
		codes: function(s: string, lax?: boolean): function(string, ? number): number, integer

		-- 返回从给定字节位置开始的字符串中所有字符的代码点。
		-- @param s (string) 输入字符串。
		-- @param i (integer) [可选] 开始字节位置。默认为1。
		-- @param j (integer) [可选] 结束字节位置。默认为起始位置。
		-- @param lax (boolean) [可选] 如果为true，则放宽验证检查。
		-- @return (integer...) 字符的代码点。
		codepoint: function(s: string, i?: integer, j?: integer, lax?: boolean): integer...

		-- 返回从指定位置开始的字符串中UTF-8字符的数量。
		-- @param s (string) 输入字符串。
		-- @param i (integer) [可选] 开始位置。默认为1。
		-- @param j (integer) [可选] 结束位置。默认为-1。
		-- @param lax (boolean) [可选] 如果为true，则放宽验证检查。
		-- @return (integer) UTF-8字符的数量。
		len: function(s: string, i?: integer, j?: integer, lax?: boolean): integer

		-- 返回指定字符开始编码的字节位置。
		-- @param s (string) 输入字符串。
		-- @param n (integer) 字符索引。
		-- @param i (integer) [可选] 开始计数的位置。
		-- @return (integer) 字符的字节位置。
		offset: function(s: string, n: integer, i?: integer): integer
	end

	-- 提供表格操作的通用函数的库。
	record table

		-- 将表格元素连接成一个字符串。
		-- @param list ({string | number}) 所有元素都是字符串或数字的列表。
		-- @param sep (string) [可选] 分隔符字符串。默认为空字符串。
		-- @param i (number) [可选] 起始索引。默认为1。
		-- @param j (number) [可选] 结束索引。默认为#list。
		-- @return (string) 连接后的字符串。
		concat: function(list: {string | number}, sep?: string, i?: number, j?: number): string

		-- 创建一个新的空表格，并预分配内存。
		-- 当您事先知道表格将有多少元素时，这种预分配可以提高性能并能节省内存，
		-- @param nseq (integer) 表格将有的序列元素数量的提示。
		-- @param nrec (integer) [可选] 表格将有的非序列元素数量的提示。默认为0。
		-- @return (table) 新的空表格。
		create: function(nseq: integer, nrec?: integer): table

		-- 将元素插入表格。
		-- @param list (table) 目标列表。
		-- @param pos (number) 插入位置。
		-- @param value (any) 要插入的值。
		insert: function<A>(list: {A}, pos: number, value: A)

		-- 将元素插入表格。
		-- @param list (table) 目标列表。
		-- @param value (any) 要插入到索引#list + 1的值。
		insert: function<A>(list: {A}, value: A)

		-- 在表格内或不同表格间移动元素。
		-- @param a1 (table) 源表格。
		-- @param f (number) 源表格的起始索引。
		-- @param e (number) 源表格的结束索引。
		-- @param t (number) 目标表格的起始索引。
		-- @param a2 (table) [可选] 目标表格。默认为a1。
		-- @return (table) 目标表格。
		move: function<A>(a1: {A}, f: number, e: number, t: number, a2?: {A}): {A}

		-- 将参数打包成表格。
		-- @param ... (any) 要打包的参数。
		-- @return (table) 带参数的表格和字段"n"表示参数总数。
		pack: function(...: any): table

		-- 从表格中移除一个元素。
		-- @param list (table) 目标列表。
		-- @param pos (number) [可选] 要移除的位置。默认为#list。
		-- @return (any) 被移除元素的值。
		remove: function<A>(list: {A}, pos?: number): A

		-- 排序表格。
		-- @param list (table) 要排序的列表。
		-- @param comp (function) [可选] 比较函数。默认为Lua的<运算符。
		sort: function<A>(list: {A}, comp?: function<A>(A, A): boolean)

		-- 将表格解包成多个返回值。
		-- @param list (table) 要解包的列表。
		-- @param i (number) [可选] 起始索引。默认为1。
		-- @param j (number) [可选] 结束索引。默认为#list。
		-- @return (any...) 从表格中的多个返回值。
		unpack: function<A>(list: {A}, i?: number, j?: number): A...
	end

	-- 提供字符串操作的通用函数的库。
	record string

		-- 返回字符串中字符的内部数字代码。
		-- @param s (string) 输入字符串。
		-- @param i (number) [可选] 字符位置（默认为1）。
		-- @return (integer) 数字代码。
		byte: function(s: string, i?: number): integer

		-- 返回字符串中字符的内部数字代码。
		-- @param s (string) 输入字符串。
		-- @param i (number) [可选] 起始位置（默认为1）。
		-- @param j (number) [可选] 结束位置（默认为i）。
		-- @return (integer...) 数字代码。
		byte: function(s: string, i?: number, j?: number): integer...

		-- 接收整数并返回每个字符的内部数字代码相等的字符串。
		-- @param ... (number) 代表字符代码的整数。
		-- @return (string) 结果字符串。
		char: function(...: number): string

		-- 返回给定函数的二进制表示字符串。
		-- @param func (function) 输入函数。
		-- @param strip (boolean) [可选] 是否去除调试信息。
		-- @return (string) 函数的二进制表示。
		dump: function(func: function, strip?: boolean): string

		-- 在字符串中查找模式的首次匹配。
		-- @param s (string) 输入字符串。
		-- @param pattern (string) 要搜索的模式。
		-- @param init (number) [可选] 搜索的起始位置。
		-- @param plain (boolean) [可选] 若为真，关闭模式匹配功能。
		-- @return (integer, integer, string...) 匹配的起始和结束索引，后续为捕获的值（如果有）。
		find: function(s: string, pattern: string, init?: number, plain?: boolean): integer, integer, string...

		-- 返回其变量数量参数的格式化版本。
		-- @param formatstring (string) 格式字符串。
		-- @param ... (any) 要格式化的可变数量参数。
		-- @return (string) 格式化的字符串。
		format: function(formatstring: string, ...: any): string

		-- 为字符串上的模式匹配返回一个迭代器函数。
		-- @param s (string) 输入字符串。
		-- @param pattern (string) 要匹配的模式。
		-- @param init (number) [可选] 搜索的起始位置。
		-- @return (function) 迭代器函数。
		gmatch: function(s: string, pattern: string, init?: number): function(): string...

		-- 返回一个字符串的副本，其中模式出现的地方被替换。
		-- @param s (string) 输入字符串。
		-- @param pattern (string) 要搜索的模式。
		-- @param repl (string | table | function) 替换字符串、表或函数。
		-- @param n (number) [可选] 要进行的替换次数。
		-- @return (string, integer) 修改后的字符串和替换次数。
		gsub: function(s: string, pattern: string, repl: (string | table | function(...: string): string | number | boolean), n?: number): string, integer

		-- 返回字符串的长度。
		-- @param s (string) 输入字符串。
		-- @return (integer) 字符串长度。
		len: function(s: string): integer

		-- 将字符串中的所有大写字母转换为小写。
		-- @param s (string) 输入字符串。
		-- @return (string) 修改后的字符串。
		lower: function(s: string): string

		-- 在字符串中查找模式的首次匹配。
		-- @param s (string) 输入字符串。
		-- @param pattern (string) 要搜索的模式。
		-- @param init (number) [可选] 搜索的起始位置。
		-- @return (string...) 捕获的值或nil。
		match: function(s: string, pattern?: string, init?: number): string...

		-- 根据格式字符串返回一个二进制字符串。
		-- @param fmt (string) 格式字符串。
		-- @param ... (any) 要序列化的值。
		-- @return (string) 二进制字符串。
		pack: function(fmt: string, ...: any): string

		-- 返回根据给定格式生成的字符串.pack的字符串大小。
		-- @param fmt (string) 格式字符串。
		-- @return (number) 结果字符串的大小。
		packsize: function(fmt: string): number

		-- 返回一个字符串，是另一个字符串的多个副本的连接。
		-- @param s (string) 输入字符串。
		-- @param n (number) 重复次数。
		-- @param sep (string) [可选] 分隔字符串。
		-- @return (string) 连接后的字符串。
		rep: function(s: string, n: number, sep?: string): string

		-- 返回输入字符串的反转版本。
		-- @param s (string) 输入字符串。
		-- @return (string) 反转后的字符串。
		reverse: function(s: string): string

		-- 返回字符串从指定位置开始和结束的子字符串。
		-- @param s (string) 输入字符串。
		-- @param i (number) 起始位置。
		-- @param j (number) [可选] 结束位置。
		-- @return (string) 子字符串。
		sub: function(s: string, i: number, j?: number): string

		-- 根据格式字符串解包一个字符串。
		-- @param fmt (string) 格式字符串。
		-- @param s (string) 要解包的字符串。
		-- @param pos (number) [可选] 字符串中的起始位置。
		-- @return (...) 解包后的值。
		unpack: function(fmt: string, s: string, pos?: number): any...

		-- 将字符串中的所有小写字母转换为大写。
		-- @param s (string) 输入字符串。
		-- @return (string) 修改后的字符串。
		upper: function(s: string): string
	end

	-- 该库提供了在Lua中加载模块的基本设施。
	record package

		-- 一个描述包的一些编译时配置的字符串。
		-- 此字符串是基于系统的特定默认值的一系列行。
		config: string

		-- 一个用于搜索C加载器的路径字符串。
		-- 使用环境变量或默认路径初始化。
		cpath: string

		-- 一个表，由require用来控制哪些模块已加载。
		-- 对此变量的赋值不会改变require所使用的表。
		loaded: {string: any}

		-- 动态链接主程序与C库libname。
		-- @param libname (string) C库的完整文件名。
		-- @param funcname (string) 要链接的函数名。使用"*"仅链接库。
		-- @return (function) 若funcname非"*"，则为C函数。
		loadlib: function(libname: string, funcname: string): function

		-- 一个用于搜索Lua加载器的路径字符串。
		-- 使用环境变量或默认路径初始化。
		path: string

		-- 一个用来存储特定模块加载器的表。
		-- 对此变量的赋值不会改变require所使用的表。
		preload: {string: function(string): any, any}

		-- 一个表，由require用来查找模块。
		-- 每个条目是一个搜索器函数，返回一个模块加载器及其数据。
		searchers: {function(string): any, any}

		-- 在给定路径中搜索给定名称。
		-- @param name (string) 要搜索的名称。
		-- @param path (string) 包含一系列模板的路径。
		-- @param sep (string) [可选] 分隔名称段的字符，默认为点。
		-- @param rep (string) [可选] 系统的目录分隔符，默认为系统特定值。
		-- @return (string, string) 能以读模式打开的首个文件名，或nil及错误信息。
		searchpath: function(name: string, path: string, sep?: string, rep?: string): string | nil, nil | string
	end

	-- 该库包含操作协程的功能。
	record coroutine

		-- 关闭协程并将其置于死亡状态。
		-- @param co (thread) 要关闭的协程。
		-- @return (boolean, string) 如果成功则返回true，否则返回false和错误字符串。
		close: function(co: thread): boolean, string

		-- 使用指定函数作为主体创建一个新的协程。
		-- @param f (function) 作为协程主体的函数。
		-- @return (thread) 新创建的协程。
		create: function(f: function): thread

		-- 检查协程是否可以挂起。
		-- @param co (thread?) [可选] 要检查的协程，默认为当前运行协程。
		-- @return (boolean) 如果协程可以挂起，则返回true。
		isyieldable: function(co?: thread): boolean

		-- 开始或继续执行协程。
		-- @param co (thread) 要恢复的协程。
		-- @param ... (any) 作为参数传递给主体函数或从yield返回的值。
		-- @return (boolean, any...) 如果成功，返回true和yield或主体函数的值；如果出错，返回false和错误信息。
		resume: function(co: thread, ...: any): boolean, any...

		-- 返回当前正在运行的协程，以及它是否为主协程。
		-- @return (thread, boolean) 正在运行的协程和一个指示它是否为主协程的布尔值。
		running: function(): thread, boolean

		-- 协程状态的枚举。
		enum CoroutineStatus
			"running"
			"suspended"
			"normal"
			"dead"
		end

		-- 获取协程的状态。
		-- @param co (thread) 要检查的协程。
		-- @return (string) 协程的状态："running", "suspended", "normal"或"dead"。
		status: function(co: thread): CoroutineStatus

		-- 创建一个新的协程，并返回一个恢复它的函数。
		-- @param f (function) 作为协程主体的函数。
		-- @return (function) 一个恢复协程的函数，返回值与resume相同，除了第一个布尔值。
		wrap: function(f: function): function

		-- 挂起调用协程的执行。
		-- @param ... (any) 作为额外结果传递给resume的参数。
		-- @return (any...) 返回传递给yield的任何参数。
		yield: function(...: any): any...
	end

	-- 提供Lua程序调试接口的功能。
	-- 使用此库时应十分小心，因为一些函数可能会破坏安全代码。
	record debug

		-- 调试钩子事件的枚举。
		enum DebugHookEvent
			"call"
			"tail call"
			"return"
			"line"
			"count"
		end

		-- 调试钩子掩码的枚举。
		enum DebugHookMask

			-- 每次Lua调用函数时都会调用钩子。
			'c'

			-- 每次Lua从函数返回时都会调用钩子。
			'r'

			-- 每次Lua进入新的代码行时都会调用钩子。
			'l'
		end

		-- 返回线程的当前钩子设置。
		-- @param thread (thread) [可选] 要操作的线程。
		-- @return (function, DebugHookMask, number) 当前钩子函数，钩子掩码和钩子计数。
		gethook: function(thread?: thread): function(DebugHookEvent, integer), DebugHookMask, integer

		-- 调试信息的函数信息记录。
		record DebugGetInfoTable
			name: string
			namewhat: string
			source: string
			short_src: string
			linedefined: integer
			lastlinedefined: integer
			what: string
			currentline: integer
			istailcall: boolean
			nups: integer
			nparams: integer
			isvararg: boolean
			func: any
			activelines: {integer: boolean}
		end

		-- 返回有关函数的信息表。
		-- @param func (function) [可选] 要操作的函数。
		-- @param f (number) 堆栈层级。
		-- @param what (string) [可选] 要检索的信息。
		-- @return (DebugGetInfoTable) 包含函数信息的表。
		getinfo: function(func: function, f: number, what?: string): DebugGetInfoTable

		-- 返回当前函数的信息表。
		-- @param f (number) 堆栈层级。
		-- @param what (string) [可选] 要检索的信息。
		-- @return (DebugGetInfoTable) 包含函数信息的表。
		getinfo: function(f: number, what?: string): DebugGetInfoTable

		-- 返回局部变量的名称和值。
		-- @param thread (thread) [可选] 要操作的线程。
		-- @param f (function) 要检查的函数。
		-- @param index (integer) 局部变量索引。
		-- @return (string, any) 局部变量的名称和值。
		getlocal: function(thread: thread, f: function, index: integer): string, any

		-- 返回局部变量的名称和值。
		-- @param thread (thread) [可选] 要操作的线程。
		-- @param f (integer) 正在检查的函数堆栈层级。
		-- @param index (integer) 局部变量的索引。
		-- @return (string, any) 局部变量的名称和值。
		getlocal: function(thread: thread, f: integer, index: integer): string, any

		-- 返回当前线程的局部变量名称和值。
		-- @param f (function) 要检查的函数。
		-- @param index (integer) 局部变量索引。
		-- @return (string, any) 局部变量的名称和值。
		getlocal: function(f: function, index: integer): string, any

		-- 获取当前线程中局部变量的名称和值。
		-- @param f (integer) 正在检查的函数堆栈级别。
		-- @param index (integer) 局部变量的索引。
		-- @return (string, any) 局部变量的名称和值。
		getlocal: function(f: integer, index: integer): string, any

		-- 返回给定值的元表。
		-- @param value (any) 要获取元表的值。
		-- @return (table | nil) 元表或nil。
		getmetatable: function<A>(value: A): metatable<A> | nil

		-- 返回注册表。
		-- @return (table) 注册表。
		getregistry: function(): table

		-- 返回upvalue的名称和值。
		-- @param f (function) 函数。
		-- @param up (number) upvalue索引。
		-- @return (string, any) upvalue的名称和值。
		getupvalue: function(f: function, up: number): string, any

		record Userdata
			userdata
		end

		-- 返回与userdata关联的用户值。
		-- @param u (Userdata) userdata。
		-- @param n (number) 用户值的索引。
		-- @return (any, boolean) 用户值和一个布尔状态。
		getuservalue: function(u: Userdata, n: number): any, boolean

		-- 设置调试钩子函数。
		-- @param thread (thread) [可选] 要操作的线程。
		-- @param hook (function) 钩子函数。
		-- @param mask (string) 钩子掩码。
		-- @param count (number) [可选] 钩子计数。
		sethook: function(thread?: thread, hook: function(DebugHookEvent, integer), mask: DebugHookMask, count?: number)

		-- 设置当前线程的调试钩子函数。
		-- @param hook (function) 钩子函数。
		-- @param mask (string) 钩子掩码。
		-- @param count (number) [可选] 钩子计数。
		sethook: function(hook: function(DebugHookEvent, integer), mask: DebugHookMask, count?: number)

		-- 为局部变量分配一个值。
		-- @param thread (thread) [可选] 要操作的线程。
		-- @param level (number) 堆栈层级。
		-- @param index (number) 局部变量索引。
		-- @param value (any) 要分配的值。
		-- @return (string) 局部变量的名称。
		setlocal: function(thread: thread, level: number, index: number, value: any): string

		-- 为当前线程的局部变量赋值。
		-- @param level (number) 栈层级。
		-- @param index (number) 局部变量索引。
		-- @param value (any) 要赋予的值。
		-- @return (string) 局部变量的名称。
		setlocal: function(level: number, index: number, value: any): string

		-- 为某个值设置元表。
		-- @param value (any) 需要设置元表的值。
		-- @param table (table) 元表。
		-- @return (any) 原始值。
		setmetatable: function<A>(value: A, table: metatable<A>): A

		-- 为上值赋值。
		-- @param f (function) 函数。
		-- @param up (number) 上值索引。
		-- @param value (any) 要赋予的值。
		-- @return (string) 上值的名称。
		setupvalue: function(f: function, up: number, value: any): string

		-- 为用户数据设置用户值。
		-- @param udata (Userdata) 用户数据。
		-- @param value (any) 要设置的值。
		-- @param n (number) 用户值的索引。
		-- @return (userdata) 用户数据或nil（如果无效）。
		setuservalue: function(udata: Userdata, value: any, n: number): Userdata

		-- 返回调用栈的回溯。
		-- @param thread (thread) [optional] 要操作的线程。
		-- @param message (string) [optional] 预置的消息。
		-- @param level (number) [optional] 起始的栈层级。
		-- @return (string) 回溯字符串。
		traceback: function(thread: thread, message?: string, level?: number): string

		-- 为当前线程返回调用栈的回溯。
		-- @param message (string) [optional] 预置的消息。
		-- @param level (number) [optional] 起始的栈层级。
		-- @return (string) 回溯字符串。
		traceback: function(message?: string, level?: number): string

		-- 返回上值的唯一标识符。
		-- @param f (function) 函数。
		-- @param n (number) 上值索引。
		-- @return (Userdata) 唯一标识符。
		upvalueid: function(f: function, n: number): Userdata

		-- 使Lua闭包f1的第n1个闭包上值（up value）指向Lua闭包f2的第n2个闭包上值（up value）。
		-- @param f1 (function) 第一个函数。
		-- @param n1 (number) 第一个上值索引。
		-- @param f2 (function) 第二个函数。
		-- @param n2 (number) 第二个上值索引。
		upvaluejoin: function(f1: function, n1: number, f2: function, n2: number)
	end

	-- 提供操作系统功能的库。
	record os

		-- 区域设置类别的枚举。
		enum LocaleCategory
			"all"
			"collate"
			"ctype"
			"monetary"
			"numeric"
			"time"
		end

		-- 设置程序的当前区域设置。
		-- @param locale (string) [可选] 要设置的区域设置。
		-- 如果 locale 是空字符串，则当前区域设置被设置为实现定义的本地区域设置。如果 locale 是字符串 "C"，则当前区域设置被设置为标准 C 区域设置。当 locale 参数为 nil 时，此函数仅返回给定类别的当前区域设置的名称。
		-- @param category (LocaleCategory) [可选] 要更改的类别。默认是 "all"。
		-- @return (string | nil) 新区域设置的名称，如果请求无法满足则返回 nil。
		setlocale: function(locale?: string, category?: LocaleCategory): string | nil

		-- 输出的日期和时间记录。
		record OutputDate
			year: number
			month: number --[[1-12]]
			day: number --[[1-31]]
			hour: number --[[0-23]]
			min: number --[[0-59]]
			sec: number --[[0-61，60和61是闰秒]]
			wday: number --[[1-7，星期天是 1]]
			yday: number --[[1-366]]
			isdst: boolean --[[夏令时标志]]
		end

		-- 返回一个包含日期和时间的字符串或表，格式根据给定的字符串格式化。
		-- @param format (string) [可选] 格式字符串。默认是 "%c"，表示人类可读的日期和时间表示。如果格式以 '!' 开头，则日期格式化为协调世界时。如果格式是字符串 "*t"，则 date 返回一个包含字段 year, month, day, hour, min, sec, wday, yday 和 isdst 的表。如果格式不是 "*t"，则 date 返回一个字符串，格式化规则与 ISO C 函数 strftime 相同，例如 "%Y-%m-%d %H:%M:%S"。
		-- @param time (number) [可选] 要格式化的时间。默认是当前时间。
		-- @return (string | OutputDate) 格式化的日期和时间。
		date: function(format?: string, time?: number): string | OutputDate

		-- 输入的日期和时间记录。
		record InputDate
			year: number
			month: number
			day: number
			hour: number --[[默认是 12]]
			min: number --[[默认是 0]]
			sec: number --[[默认是 0]]
			isdst: boolean --[[默认是 nil]]
		end

		-- 当没有参数时，返回当前时间，或者返回由给定表指定的本地日期和时间。这个表必须包含字段 year, month 和 day，并且可以包含字段 hour（默认是 12）, min（默认是 0）, sec（默认是 0）和 isdst（默认是 nil）。其他字段将被忽略。os.time 还会规范化 os.date 函数中记录的所有字段，以便它们表示与调用前相同的时间，但值在其有效范围内。
		-- @param date (InputDate) [可选] 表示本地日期和时间的表。
		-- 当调用该函数时，这些字段中的值不需要在其有效范围内。例如，如果 sec 是 -10，则表示在其他字段指定的时间之前的 10 秒；如果 hour 是 1000，则表示在其他字段指定的时间之后的 1000 小时。
		-- @return (number) 当前时间或表中指定的时间。返回值是一个数字，其含义取决于您的系统。在 POSIX、Windows 和其他一些系统中，这个数字表示自某个给定起始时间（“纪元”）以来的秒数。在其他系统中，这个含义没有指定，time 返回的数字只能作为 os.date 和 os.difftime 的参数使用。
		time: function(date?: InputDate): number

		-- 返回从时间 t1 到时间 t2 的差值（以秒为单位）（其中时间是 os.time 返回的值）。在 POSIX、Windows 和其他一些系统中，这个值正好是 t2-t1。
		-- @param t2 (number) 结束时间。
		-- @param t1 (number) 开始时间。
		-- @return (number) 时间差，以秒为单位。
		difftime: function(t2: number, t1: number): number

		-- 返回进程环境变量 varname 的值，如果变量未定义则返回 nil。
		-- @param varname (string) 环境变量的名称。
		-- @return (string | nil) 环境变量的值，如果变量未定义则返回 nil。
		getenv: function(varname: string): string | nil
	end
end

return lua