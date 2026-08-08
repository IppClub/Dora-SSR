-- 与 Lua 5.2 兼容的无符号 32 位运算库。
local record bit32
	-- 算术右移；负位移量表示左移。
	arshift: function(value: number, displacement: integer): integer
	-- 对全部参数执行按位与；无参数时返回 0xffffffff。
	band: function(...: number): integer
	-- 在 32 位范围内执行按位取反。
	bnot: function(value: number): integer
	-- 对全部参数执行按位或；无参数时返回 0。
	bor: function(...: number): integer
	-- 判断全部参数按位与的结果是否非零。
	btest: function(...: number): boolean
	-- 对全部参数执行按位异或。
	bxor: function(...: number): integer
	-- 从编号为 field 的位开始提取 width 位；width 默认为 1。
	extract: function(value: number, field: integer, width?: integer): integer
	-- 在 32 位表示范围内向左循环移位。
	lrotate: function(value: number, displacement: integer): integer
	-- 逻辑左移；负位移量表示右移。
	lshift: function(value: number, displacement: integer): integer
	-- 从编号为 field 的位开始替换 width 位；width 默认为 1。
	replace: function(value: number, replacement: number, field: integer, width?: integer): integer
	-- 在 32 位表示范围内向右循环移位。
	rrotate: function(value: number, displacement: integer): integer
	-- 逻辑右移；负位移量表示左移。
	rshift: function(value: number, displacement: integer): integer
end

return bit32
