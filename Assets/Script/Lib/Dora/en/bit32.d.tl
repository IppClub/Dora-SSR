-- Lua 5.2-compatible unsigned 32-bit bitwise operations.
local record bit32
	-- Arithmetic right shift. Negative displacements shift left.
	arshift: function(value: number, displacement: integer): integer
	-- Bitwise AND of all arguments. With no arguments, returns 0xffffffff.
	band: function(...: number): integer
	-- Bitwise complement restricted to 32 bits.
	bnot: function(value: number): integer
	-- Bitwise OR of all arguments. With no arguments, returns 0.
	bor: function(...: number): integer
	-- Returns whether the bitwise AND of all arguments is nonzero.
	btest: function(...: number): boolean
	-- Bitwise exclusive OR of all arguments.
	bxor: function(...: number): integer
	-- Extracts width bits starting at zero-based bit field. Width defaults to 1.
	extract: function(value: number, field: integer, width?: integer): integer
	-- Rotates a value left inside its 32-bit representation.
	lrotate: function(value: number, displacement: integer): integer
	-- Logical left shift. Negative displacements shift right.
	lshift: function(value: number, displacement: integer): integer
	-- Replaces width bits starting at zero-based bit field. Width defaults to 1.
	replace: function(value: number, replacement: number, field: integer, width?: integer): integer
	-- Rotates a value right inside its 32-bit representation.
	rrotate: function(value: number, displacement: integer): integer
	-- Logical right shift. Negative displacements shift left.
	rshift: function(value: number, displacement: integer): integer
end

return bit32
