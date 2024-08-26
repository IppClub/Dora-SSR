-- Enumeration for load function.
local enum LoadMode

	-- Binary mode.
	"b"

	-- Textual mode.
	"t"

	-- Both binary and textual mode.
	"bt"
end

local enum SelectLengthFlag
	"#"
end

-- Enumeration for The garbage collector operation.
local enum CollectorOperationA

	-- Performs a full garbage-collection cycle. This is the default option.
	"collect"

	-- Stops automatic execution of the garbage collector. The collector will run only when explicitly invoked, until a call to restart it.
	"stop"

	-- Restarts automatic execution of the garbage collector.
	"restart"

	-- Returns the total memory in use by Lua in Kbytes. The value has a fractional part, so that it multiplied by 1024 gives the exact number of bytes in use by Lua.
	"count"
end

-- Enumeration for The garbage collector operation.
local enum GarbageCollectorOperationB

	-- Performs a garbage-collection step. The step "size" is controlled by arg. With a zero value, the collector will perform one basic (indivisible) step. For non-zero values, the collector will perform as if that amount of memory (in Kbytes) had been allocated by Lua. Returns true if the step finished a collection cycle.
	"step"
end

-- Enumeration for The garbage collector operation.
local enum GarbageCollectorOperationC

	-- Returns a boolean that tells whether the collector is running (i.e., not stopped).
	"isrunning"
end

-- Enumeration for The garbage collector operation.
local enum GarbageCollectorOperationD

	-- Gets or sets the garbage-collector parameter. With no argument, returns the current value for the parameter. With argument, sets the value of the parameter and returns the current value.
	"param"
end

-- Enumeration for The garbage collector parameter.
local enum GarbageCollectorParameter

	-- The garbage-collector pause controls how long the collector waits before starting a new cycle.
	-- The collector starts a new cycle when the number of objects hits `pause` of the total after the previous collection.
	-- Larger values make the collector less aggressive.
	-- Values equal to or less than 100 mean the collector will not wait to start a new cycle.
	-- A value of 200 means that the collector waits for the total number of objects to double before starting a new cycle.
	-- The default value is 200.
	"pause"

	-- The garbage-collector step multiplier controls the size of each GC step.
	-- A value of `stepmul` means the interpreter will mark or sweep, in each step, `stepmul` objects for each created object.
	-- Larger values make the collector more aggressive.
	-- Beware that values too small can make the collector too slow to ever finish a cycle.
	-- The default value is 200.
	-- As a special case, a zero value means unlimited work, effectively producing a non-incremental, stop-the-world collector.
	"stepmul"

	-- The garbage-collector step size controls the size of each incremental step, specifically how many objects the interpreter creates before performing a step:
	-- A value of `stepsize` means the interpreter will create approximately `stepsize` objects between steps.
	-- The default value is 250.
	"stepsize"

	-- The minor multiplier controls the frequency of minor collections.
	-- For a minor multiplier `minormul`, a new minor collection will be done when the number of objects grows `minormul` larger than the number in use just after the last major collection.
	-- For instance, for a multiplier of 20, the collector will do a minor collection when the number of objects gets 20% larger than the total after the last major collection.
	-- The default value is 25.
	"minormul"

	-- The minor-major multiplier controls the shift to major collections.
	-- For a multiplier `minormajor`, the collector will shift to a major collection when the number of old objects grows `minormajor` larger than the total after the previous major collection.
	-- For instance, for a multiplier of 100, the collector will do a major collection when the number of old objects gets larger than twice the total after the previous major collection.
	-- The default value is 100.
	"minormajor"

	-- The major-minor multiplier controls the shift back to minor collections.
	-- For a multiplier `majorminor`, the collector will shift back to minor collections after a major collection collects at least `majorminor` of the objects allocated during the last cycle.
	-- In particular, for a multiplier of 0, the collector will immediately shift back to minor collections after doing one cycle of major collections.
	-- The default value is 50.
	"majorminor"
end

-- Enumeration for The garbage collection mode.
local enum GarbageCollectionMode

	-- Change the collector mode to incremental.
	"incremental"

	-- Change the collector mode to generational.
	"generational"
end

-- The Lua standard lib.
local record lua

	-- Loads a given module.
	-- @param modname (string) The name of the module to load.
	-- @return (any) The value stored at package.loaded[modname] if the module is already loaded.
	-- Otherwise, tries to find a loader and returns the final value of package.loaded[modname] and a loader data as a second result.
	require: function(modname: string)

	-- Raises an error if the value of its argument v is false (nil or false); otherwise, returns all its arguments.
	-- In case of error, message is the error object; defaults to "assertion failed!" if absent.
	-- @param v (any) The value to be tested.
	-- @param message (string) [optional] The error message.
	-- @return (...) Returns all arguments if v is not false.
	assert: function(v: any, message?: string): any...

	-- Opens a file and executes its contents as a Lua chunk.
	-- Returns all values returned by the chunk. Propagates errors to its caller.
	-- @param filename (string) The file name to execute.
	-- @return (...) The values returned by the chunk.
	dofile: function(filename: string): any...

	-- Raises an error with message as the error object. This function never returns.
	-- Adds error position information to the message if it's a string.
	-- @param message (any) The error object, could be string message.
	-- @param level (number) [optional] Specifies how to get the error position.
	error: function(message: any, level?: number)

	-- A global variable holding the global environment. Changing its value does not affect any environment.
	_G: table

	-- Returns the metatable of the given object.
	-- If object's metatable has a __metatable field, returns its value. Otherwise, returns the metatable.
	-- @param object (any) The object to get the metatable from.
	-- @return (metatable<T> | nil) The metatable or nil if none.
	getmetatable: function<T>(object: any): metatable<T> | nil

	-- Returns an iterator function for iterating over array-like tables.
	-- @param t (table) The table to iterate over.
	-- @return (function) Iterator function, the table t, and 0.
	ipairs: function<A>(t: {A}): function(): (integer, A), {A}, integer

	-- Loads a chunk. If chunk is a string, it is the chunk. If a function, it's called to get chunk pieces.
	-- @param chunk (string | function) The chunk or function providing the chunk.
	-- @param chunkname (string) [optional] The name of the chunk for error messages.
	-- @param mode (LoadMode) [optional] Controls whether the chunk can be text or binary.
	-- @param env (table) [optional] The environment for the chunk.
	-- @return (function | nil, nil | string) The compiled chunk as a function, or nil and error message.
	load: function(chunk: (string | function(): string), chunkname?: string, mode?: LoadMode, env?: table): function, string

	-- Similar to load, but gets the chunk from a file or standard input if no filename is provided.
	-- @param filename (string) [optional] The file name to load the chunk from.
	-- @param mode (LoadMode) [optional] The mode for the chunk.
	-- @param env (table) [optional] The environment for the chunk.
	-- @return (function | nil, nil | string) The loaded chunk as a function, or nil and error message.
	loadfile: function(filename?: string, mode?: LoadMode, env?: table): function, string

	-- Allows traversal of all fields of a table. Returns the next index and its value.
	-- @param table (table) The table to traverse.
	-- @param index (any) [optional] The current index in the table.
	-- @return (any, any) The next index and its associated value, or nil if at the end.
	next: function<A, B>(table: {A: B}, index?: A): A, B

	-- Allows traversal of all fields of a table. Returns the next index and its value.
	-- @param table (table) The table to traverse.
	-- @param index (any) [optional] The current index in the table.
	-- @return (any, any) The next index and its associated value, or nil if at the end.
	next: function<A>(table: {A}, index?: A): integer, A

	-- Iterates over all key-value pairs of a table.
	-- If t has a metamethod __pairs, calls it with t as argument and returns the first three results from the call.
	-- Otherwise, returns three values: the next function, the table t, and nil.
	-- @param t (table) The table to iterate over.
	-- @return (function) The iterator function.
	pairs: function<A, B>(t: {A: B}): function<A, B>(table: {A: B}, index?: A): (A, B), {A: B}, any

	-- Calls a function in protected mode.
	-- Catches any errors and returns a status code and results or error object.
	-- @param f (function) The function to call.
	-- @param ... (any) Arguments to pass to the function.
	-- @return (boolean, ...) Status code and function results or error object.
	pcall: function(f: function, ...: any): boolean, any...

	-- Prints values to stdout.
	-- Converts each argument to a string and prints them.
	-- @param ... (any) The values to print.
	print: function(...: any)

	-- Checks whether two values are raw-equal.
	-- Compares without invoking the __eq metamethod.
	-- @param v1 (any) The values to compare.
	-- @param v2 (any) The values to compare.
	-- @return (boolean) True if v1 is equal to v2, false otherwise.
	rawequal: function(v1: any, v2: any): boolean

	-- Gets the real value of a table at a given index.
	-- Does not use the __index metamethod.
	-- @param table (table) The table to index.
	-- @param index (any) The index to retrieve.
	-- @return (any) The value at the given index.
	rawget: function(table: table, index: any): any

	-- Returns the length of an object without invoking the __len metamethod.
	-- @param v (table | string) The object to get the length of.
	-- @return (integer) The length of the object.
	rawlen: function(v: table | string): integer

	-- Sets the real value of a table at a given index.
	-- Does not use the __newindex metamethod.
	-- @param table (table) The table to modify.
	-- @param index (any) The index to set.
	-- @param value (any) The value to set.
	-- @return (table) The modified table.
	rawset: function<A, B>(table: {A : B}, index: A, value: B): {A}

	-- Sets the real value of a table at a given index.
	-- Does not use the __newindex metamethod.
	-- @param table (table) The table to modify.
	-- @param index (number) The index to set.
	-- @param value (any) The value to set.
	-- @return (table) The modified table.
	rawset: function<A>(table: {A}, index: number, value: A): {A}

	-- Selects argument based on index.
	-- Returns argument at argument index. A negative number indexes from the end (-1 is the last argument).
	-- @param index (integer) The index to start from, or '#' for total count.
	-- @param ... (any) The arguments to select from.
	-- @return (...) Selected argument.
	select: function<A>(number, ...: A): A

	-- Selects argument based on index.
	-- Returns argument at argument index. A negative number indexes from the end (-1 is the last argument).
	-- @param index (integer) The index to start from, or '#' for total count.
	-- @param ... (any) The arguments to select from.
	-- @return (...) Selected argument.
	select: function(number, ...: any): any

	-- Selects the total number of arguments.
	-- @param flag (SelectLengthFlag) The '#' for total count.
	-- @param ... (any) The arguments to select from.
	-- @return (integer) The total number of arguments
	select: function(flag: SelectLengthFlag, ...: any): integer

	-- Sets or removes the metatable of a table.
	-- @param table (table) The table to modify.
	-- @param metatable (table | nil) The metatable to set, or nil to remove.
	-- @return (table) The modified table.
	setmetatable: function<A>(table: A, metatable: metatable<A> | nil): A

	-- Converts an argument to a number.
	-- Tries to convert a string to a number.
	-- @param e (string) The value to convert.
	-- @return (number | nil) The converted number or nil on failure.
	tonumber: function(e: string): number | nil

	-- Converts an argument to a number.
	-- Tries to convert a string or number to a number, with an optional base.
	-- @param e (string | number) The value to convert.
	-- @param base (number) [optional] The base for conversion.
	-- @return (integer | nil) The converted number or nil on failure.
	tonumber: function(e: string | number, base: number): integer | nil

	-- Converts a value to a string.
	-- Uses the __tostring metamethod if available.
	-- @param v (any) The value to convert.
	-- @return (string) The string representation.
	tostring: function(v: any): string

	-- Returns the type of a value as a string.
	-- @param v (any) The value to get the type of.
	-- @return (string) The type of the value.
	type: function(v: any): string

	-- A global variable holding the running Lua version.
	_VERSION: string

	-- Emits a warning with a concatenated message.
	-- By convention, a one-piece message starting with '@' is intended to be a control message, which is a message to the warning system itself. In particular, the standard warning function in Lua recognizes the control messages "@off", to stop the emission of warnings, and "@on", to (re)start the emission; it ignores unknown control messages.
	-- @param ... (string) The message parts to concatenate.
	warn: function(...: string)

	-- Calls a function with a custom message handler.
	-- Similar to pcall but with a message handler.
	-- @param f (function) The function to call.
	-- @param msgh (function) The message handler.
	-- @param ... (any) Arguments to pass to the function.
	-- @return (boolean, ...) Status code and function results or error object.
	xpcall: function(f: function, msgh: (function(err: string): string), ...: any): boolean, any...

	-- Generic interface to the garbage collector. Performs different functions based on the first argument, opt.
	-- @param opt (CollectorOperationA) The garbage collector operation.
	-- @return (number) Depends on the opt parameter.
	collectgarbage: function(opt: CollectorOperationA): number

	-- Generic interface to the garbage collector. Performs different functions based on the first argument, opt.
	-- @param opt ("step") The garbage collector operation.
	-- @param arg (number) [optional] The step "size".
	-- @return (boolean) Depends on the opt parameter.
	collectgarbage: function(opt: GarbageCollectorOperationB, arg?: number): boolean

	-- Generic interface to the garbage collector. Performs different functions based on the first argument, opt.
	-- @param opt ("isrunning") The garbage collector operation.
	-- @return (bool) whether the collector is running.
	collectgarbage: function(opt: GarbageCollectorOperationC): boolean

	-- Generic interface to the garbage collector. Performs different functions based on the first argument, opt.
	-- @param opt ("param") The garbage collector operation.
	-- @param param (GarbageCollectorParameter) The parameter to get or set.
	-- @param value (number) [optional] The new value for the parameter.
	-- @return (number) The current value of the parameter.
	collectgarbage: function(opt: GarbageCollectorOperationD, param: GarbageCollectorParameter, value?: number): number

	-- Generic interface to the garbage collector. Performs different functions based on the first argument, opt.
	-- @param opt ("generational" | "incremental" ) The garbage collector operation.
	collectgarbage: function(opt: GarbageCollectionMode)

	-- Library provides basic mathematical functions.
	record math

		-- Returns the absolute value of float x.
		-- @param x (number) The input number.
		-- @return (number) The absolute value of x.
		abs: function(x: number): number

		-- Returns the absolute value of integer x.
		-- @param x (integer) The input number.
		-- @return (integer) The absolute value of x.
		abs: function(x: integer): integer

		-- Returns the arc cosine of x (in radians).
		-- @param x (number) The input number.
		-- @return (number) The arc cosine of x.
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

		-- Returns the smallest integer greater than or equal to x.
		-- @param x (number) The input number.
		-- @return (integer) The smallest integer greater than or equal to x.
		ceil: function(x: number): integer

		-- Returns the cosine of x (in radians).
		-- @param x (number) The input number.
		-- @return (number) The cosine of x.
		cos: function(x: number): number

		-- Converts angle x from radians to degrees.
		-- @param x (number) The input number.
		-- @return (number) The angle in degrees.
		deg: function(x: number): number

		-- Returns the value e^x.
		-- @param x (number) The input number.
		-- @return (number) The value of e^x.
		exp: function(x: number): number

		-- Returns the largest integer less than or equal to x.
		-- @param x (number) The input number.
		-- @return (integer) The largest integer less than or equal to x.
		floor: function(x: number): integer

		-- Returns the remainder of x divided by float y.
		-- @param x (number) The dividend.
		-- @param y (number) The divisor.
		-- @return (number) The remainder of x divided by y.
		fmod: function(x: number, y: number): number

		-- Returns the remainder of integer x divided by integer y.
		-- @param x (integer) The dividend.
		-- @param y (integer) The divisor.
		-- @return (integer) The remainder of x divided by y.
		fmod: function(x: integer, y: integer): integer

		-- The float value representing infinity.
		huge: number

		-- Returns the logarithm of x in the given base (default is e).
		-- @param x (number) The input number.
		-- @param base (number) [optional] The logarithm base.
		-- @return (number) The logarithm of x in the given base.
		log: function(x: number, base?: number): number

		-- Returns the maximum value among its arguments.
		-- @param ... (integer) The input integers.
		-- @return (integer) The maximum value among the arguments.
		max: function(...: integer): integer

		-- Returns the maximum value among its arguments.
		-- @param ... (number) The input numbers.
		-- @return (number) The maximum value among the arguments.
		max: function(...: number): number

		-- Returns the maximum value among its arguments.
		-- @param ... (number | integer) The input numbers.
		-- @return (number | integer) The maximum value among the arguments.
		max: function(...: number | integer): number | integer

		-- Returns the maximum value among its arguments.
		-- @param ... (any) The input comparables.
		-- @return (any) The maximum value among the arguments.
		max: function(...: any): any

		-- An integer with the maximum value.
		maxinteger: number

		-- Returns the minimum value among its arguments.
		-- @param ... (integer) The input integers.
		-- @return (integer) The minimum value among the arguments.
		min: function(...: integer): integer

		-- Returns the minimum value among its arguments.
		-- @param ... (number) The input numbers.
		-- @return (number) The minimum value among the arguments.
		min: function(...: number): number

		-- Returns the minimum value among its arguments.
		-- @param ... (number | integer) The input numbers.
		-- @return (number | integer) The minimum value among the arguments.
		min: function(...: number | integer): number | integer

		-- Returns the minimum value among its arguments.
		-- @param ... (any) The input comparables.
		-- @return (any) The minimum value among the arguments.
		min: function(...: any): any

		-- An integer with the minimum value.
		mininteger: number

		-- Returns the integral and fractional parts of x.
		-- @param x (number) The input number.
		-- @return (integer, number) The integral and fractional parts of x.
		modf: function(x: number): integer, number

		-- The value of π.
		pi: number

		-- Converts angle x from degrees to radians.
		-- @param x (number) The input number.
		-- @return (number) The angle in radians.
		rad: function(x: number): number

		-- Returns a pseudo-random 64-bit integers.
		-- @param m (number) The lower range limit.
		-- @param n (number) [optional] The upper range limit.
		-- @return (integer) A pseudo-random integer.
		random: function(m: number, n?: number): integer

		-- Returns pseudo-random float with uniform distribution in the range [0,1).
		-- @return (number) A pseudo-random number.
		random: function(): number

		-- Seeds the pseudo-random number generator.
		-- @param x (number) [optional] The first seed component.
		-- @param y (number) [optional] The second seed component.
		-- @return (integer, integer) The seed components used.
		randomseed: function(x?: number, y?: number): integer, integer

		-- Returns the sine of x (in radians).
		-- @param x (number) The input number.
		-- @return (number) The sine of x.
		sin: function(x: number): number

		-- Returns the square root of x.
		-- @param x (number) The input number.
		-- @return (number) The square root of x.
		sqrt: function(x: number): number

		-- Returns the tangent of x (in radians).
		-- @param x (number) The input number.
		-- @return (number) The tangent of x.
		tan: function(x: number): number

		-- Converts x to an integer, or fails if not possible.
		-- @param x (number) The input number.
		-- @return (number | nil) The integer value of x or fail if conversion is not possible.
		tointeger: function(x: number): number | nil

		enum NumberType
			"integer"
			"float"
		end

		-- Returns "integer" or "float" based on the type of x, or fails if not a number.
		-- @param x (number | integer) The input number.
		-- @return (NumberType | nil) The type of x.
		type: function(x: number | integer): NumberType | nil

		-- Returns true if integer m is below n as unsigned integers.
		-- @param m (number) The first integer.
		-- @param n (number) The second integer.
		-- @return (boolean) True if m is below n as unsigned integers.
		ult: function(m: number, n: number): boolean
	end

	-- Library provides basic support for UTF-8 encoding.
	record utf8

		-- Receives zero or more integers, converts each to corresponding UTF-8 byte sequence and returns a string with the concatenation of these sequences.
		-- @param ... (integer) Zero or more integers to convert.
		-- @return (string) Concatenated UTF-8 byte sequences.
		char: function(...: integer): string

		-- The pattern matching exactly one UTF-8 byte sequence, assuming the subject is a valid UTF-8 string.
		charpattern: string

		-- Iterates over all UTF-8 characters in a string, with byte position and code point of each character.
		-- @param s (string) The input string.
		-- @param lax (boolean) [optional] If true, relaxes validation checks.
		-- @return (function) Iterator function for UTF-8 characters.
		codes: function(s: string, lax?: boolean): function(string, ? number): number, integer

		-- Returns the code points from all characters in a string that start between given byte positions.
		-- @param s (string) The input string.
		-- @param i (integer) [optional] The start byte position. Default is 1.
		-- @param j (integer) [optional] The end byte position. Default is the start position.
		-- @param lax (boolean) [optional] If true, relaxes validation checks.
		-- @return (integer...) Code points of characters.
		codepoint: function(s: string, i?: integer, j?: integer, lax?: boolean): integer...

		-- Returns the number of UTF-8 characters in a string that start between specified positions.
		-- @param s (string) The input string.
		-- @param i (integer) [optional] The start position. Default is 1.
		-- @param j (integer) [optional] The end position. Default is -1.
		-- @param lax (boolean) [optional] If true, relaxes validation checks.
		-- @return (integer) Number of UTF-8 characters.
		len: function(s: string, i?: integer, j?: integer, lax?: boolean): integer

		-- Returns the byte position where the encoding of a specified character starts.
		-- @param s (string) The input string.
		-- @param n (integer) The character index.
		-- @param i (integer) [optional] The start position for counting.
		-- @return (integer) Byte position of the character.
		offset: function(s: string, n: integer, i?: integer): integer
	end

	-- Library provides generic functions for table manipulation.
	record table

		-- Concatenates table elements into a string.
		-- @param list ({string | number}) A list where all elements are strings or numbers.
		-- @param sep (string) [optional] Separator string. Default is the empty string.
		-- @param i (number) [optional] Starting index. Default is 1.
		-- @param j (number) [optional] Ending index. Default is #list.
		-- @return (string) The concatenated string.
		concat: function(list: {string | number}, sep?: string, i?: number, j?: number): string

		-- Creates a new empty table, preallocating memory.
		-- This preallocation may help performance and save memory
		-- when you know in advance how many elements the table will have.
		-- @param nseq (integer) A hint for how many elements the table will have as a sequence.
		-- @param nrec (integer) [optional] A hint for how many other elements the table will have; its default is zero.
		-- @return (table) The new empty table.
		create: function(nseq: integer, nrec?: integer): table

		-- Inserts an element into a table.
		-- @param list (table) The target list.
		-- @param pos (number) Position to insert.
		-- @param value (any) The value to insert.
		insert: function<A>(list: {A}, pos: number, value: A)

		-- Inserts an element into a table.
		-- @param list (table) The target list.
		-- @param value (any) The value to insert to index #list + 1.
		insert: function<A>(list: {A}, value: A)

		-- Moves elements within or between tables.
		-- @param a1 (table) The source table.
		-- @param f (number) The starting index in the source table.
		-- @param e (number) The ending index in the source table.
		-- @param t (number) The starting index in the destination table.
		-- @param a2 (table) [optional] The destination table. Default is a1.
		-- @return (table) The destination table.
		move: function<A>(a1: {A}, f: number, e: number, t: number, a2?: {A}): {A}

		-- Packs arguments into a table.
		-- @param ... (any) The arguments to pack.
		-- @return (table) The table with arguments and a field "n" for the total number of arguments.
		pack: function(...: any): table

		-- Removes an element from a table.
		-- @param list (table) The target list.
		-- @param pos (number) [optional] The position to remove from. Default is #list.
		-- @return (any) The value of the removed element.
		remove: function<A>(list: {A}, pos?: number): A

		-- Sorts a table.
		-- @param list (table) The list to sort.
		-- @param comp (function) [optional] Comparison function. Default is Lua's < operator.
		sort: function<A>(list: {A}, comp?: function<A>(A, A): boolean)

		-- Unpacks a table into multiple return values.
		-- @param list (table) The list to unpack.
		-- @param i (number) [optional] The starting index. Default is 1.
		-- @param j (number) [optional] The ending index. Default is #list.
		-- @return (any...) Multiple return values from the table.
		unpack: function<A>(list: {A}, i?: number, j?: number): A...
	end

	-- Library provides generic functions for string manipulation.
	record string

		-- Returns the internal numeric code of the character in a string.
		-- @param s (string) The input string.
		-- @param i (number) [optional] The character position (default 1).
		-- @return (integer) Numeric code.
		byte: function(s: string, i?: number): integer

		-- Returns the internal numeric codes of the characters in a string.
		-- @param s (string) The input string.
		-- @param i (number) [optional] The starting position (default 1).
		-- @param j (number) [optional] The ending position (default i).
		-- @return (integer...) Numeric codes.
		byte: function(s: string, i?: number, j?: number): integer...

		-- Receives integers and returns a string where each character has the internal numeric code equal to the corresponding argument.
		-- @param ... (number) The integers representing character codes.
		-- @return (string) The resulting string.
		char: function(...: number): string

		-- Returns a string containing a binary representation of a given function.
		-- @param func (function) The input function.
		-- @param strip (boolean) [optional] Whether to strip debug information.
		-- @return (string) Binary representation of the function.
		dump: function(func: function, strip?: boolean): string

		-- Looks for the first match of a pattern in a string.
		-- @param s (string) The input string.
		-- @param pattern (string) The pattern to search for.
		-- @param init (number) [optional] The starting position for search.
		-- @param plain (boolean) [optional] If true, turns off pattern matching.
		-- @return (integer, integer, string...) The start and end indices of the match, followed by captured values if any.
		find: function(s: string, pattern: string, init?: number, plain?: boolean): integer, integer, string...

		-- Returns a formatted version of its variable number of arguments.
		-- @param formatstring (string) The format string.
		-- @param ... (any) Variable number of arguments to format.
		-- @return (string) The formatted string.
		format: function(formatstring: string, ...: any): string

		-- Returns an iterator function for pattern matching over a string.
		-- @param s (string) The input string.
		-- @param pattern (string) The pattern to match.
		-- @param init (number) [optional] The starting position for search.
		-- @return (function) The iterator function.
		gmatch: function(s: string, pattern: string, init?: number): function(): string...

		-- Returns a copy of a string with occurrences of a pattern replaced by a replacement.
		-- @param s (string) The input string.
		-- @param pattern (string) The pattern to search for.
		-- @param repl (string | table | function) The replacement string, table, or function.
		-- @param n (number) [optional] The number of replacements to make.
		-- @return (string, integer) The modified string and the number of replacements made.
		gsub: function(s: string, pattern: string, repl: (string | table | function(...: string): string | number | boolean), n?: number): string, integer

		-- Returns the length of a string.
		-- @param s (string) The input string.
		-- @return (integer) The length of the string.
		len: function(s: string): integer

		-- Converts all uppercase letters in a string to lowercase.
		-- @param s (string) The input string.
		-- @return (string) The modified string.
		lower: function(s: string): string

		-- Looks for the first match of a pattern in a string.
		-- @param s (string) The input string.
		-- @param pattern (string) The pattern to search for.
		-- @param init (number) [optional] The starting position for search.
		-- @return (string...) The captured values or nil.
		match: function(s: string, pattern?: string, init?: number): string...

		-- Returns a binary string according to the format string.
		-- @param fmt (string) The format string.
		-- @param ... (any) Values to be serialized.
		-- @return (string) The binary string.
		pack: function(fmt: string, ...: any): string

		-- Returns the size of a string resulting from string.pack with a given format.
		-- @param fmt (string) The format string.
		-- @return (number) The size of the resulting string.
		packsize: function(fmt: string): number

		-- Returns a string that is the concatenation of copies of another string.
		-- @param s (string) The input string.
		-- @param n (number) The number of times to repeat.
		-- @param sep (string) [optional] The separator string.
		-- @return (string) The concatenated string.
		rep: function(s: string, n: number, sep?: string): string

		-- Returns a string that is the reverse of the input string.
		-- @param s (string) The input string.
		-- @return (string) The reversed string.
		reverse: function(s: string): string

		-- Returns the substring of a string that starts and ends at specified positions.
		-- @param s (string) The input string.
		-- @param i (number) The starting position.
		-- @param j (number) [optional] The ending position.
		-- @return (string) The substring.
		sub: function(s: string, i: number, j?: number): string

		-- Unpacks a string according to a format string.
		-- @param fmt (string) The format string.
		-- @param s (string) The string to unpack.
		-- @param pos (number) [optional] The starting position in the string.
		-- @return (...) Unpacked values.
		unpack: function(fmt: string, s: string, pos?: number): any...

		-- Converts all lowercase letters in a string to uppercase.
		-- @param s (string) The input string.
		-- @return (string) The modified string.
		upper: function(s: string): string
	end

	-- Library provides basic facilities for loading modules in Lua.
	record package

		-- A string describing some compile-time configurations for packages.
		-- This string is a sequence of lines with specific default values based on the system.
		config: string

		-- A string with the path used by require to search for a C loader.
		-- Initialized using environment variables or a default path.
		cpath: string

		-- A table used by require to control which modules are already loaded.
		-- Assignments to this variable do not change the table used by require.
		loaded: {string: any}

		-- Dynamically links the host program with the C library libname.
		-- @param libname (string) The complete file name of the C library.
		-- @param funcname (string) The function name to be linked. Use "*" to link only the library.
		-- @return (function) The function as a C function if funcname is not "*".
		loadlib: function(libname: string, funcname: string): function

		-- A string with the path used by require to search for a Lua loader.
		-- Initialized using environment variables or a default path.
		path: string

		-- A table to store loaders for specific modules.
		-- Assignments to this variable do not change the table used by require.
		preload: {string: function(string): any, any}

		-- A table used by require to find modules.
		-- Each entry is a searcher function that returns a module loader and loader data.
		searchers: {function(string): any, any}

		-- Searches for the given name in the given path.
		-- @param name (string) The name to search for.
		-- @param path (string) The path containing a sequence of templates.
		-- @param sep (string) [optional] The character that separates name segments, defaults to a dot.
		-- @param rep (string) [optional] The system's directory separator, defaults to system-specific value.
		-- @return (string, string) The first file name that can be opened in read mode, or nil with an error message.
		searchpath: function(name: string, path: string, sep?: string, rep?: string): string | nil, nil | string
	end

	-- Library comprises the operations to manipulate coroutines.
	record coroutine

		-- Closes a coroutine and puts it in a dead state.
		-- @param co (thread) The coroutine to close.
		-- @return (boolean, string) Returns true if successful, false and the error string otherwise.
		close: function(co: thread): boolean, string

		-- Creates a new coroutine with a specified function as its body.
		-- @param f (function) The function to be the body of the coroutine.
		-- @return (thread) The new coroutine.
		create: function(f: function): thread

		-- Checks if a coroutine can yield.
		-- @param co (thread?) [optional] The coroutine to check. Defaults to the running coroutine.
		-- @return (boolean) Returns true if the coroutine can yield.
		isyieldable: function(co?: thread): boolean

		-- Starts or continues the execution of a coroutine.
		-- @param co (thread) The coroutine to resume.
		-- @param ... (any) Values passed as arguments to the body function or as results from yield.
		-- @return (boolean, any...) Returns true and any values from yield or the body function, or false and the error message on error.
		resume: function(co: thread, ...: any): boolean, any...

		-- Returns the currently running coroutine and if it is the main one.
		-- @return (thread, boolean) The running coroutine and a boolean indicating if it is the main coroutine.
		running: function(): thread, boolean

		-- Enumeration for status of coroutine.
		enum CoroutineStatus
			"running"
			"suspended"
			"normal"
			"dead"
		end

		-- Gets the status of a coroutine.
		-- @param co (thread) The coroutine to check.
		-- @return (string) The status of the coroutine: "running", "suspended", "normal", or "dead".
		status: function(co: thread): CoroutineStatus

		-- Creates a new coroutine and returns a function to resume it.
		-- @param f (function) The function to be the body of the coroutine.
		-- @return (function) A function that resumes the coroutine, returning the same values as resume except the first boolean.
		wrap: function(f: function): function

		-- Suspends the execution of the calling coroutine.
		-- @param ... (any) Arguments passed as extra results to resume.
		-- @return (any...) Returns any arguments passed to yield.
		yield: function(...: any): any...
	end

	-- Library provides the functionality of the debug interface to Lua programs.
	-- Care should be taken when using this library, as several functions can compromise secure code.
	record debug

		-- Enumeration for debug hook event.
		enum DebugHookEvent
			"call"
			"tail call"
			"return"
			"line"
			"count"
		end

		-- Enumeration for debug hook mask.
		enum DebugHookMask

			-- The hook is called every time Lua calls a function.
			'c'

			-- The hook is called every time Lua returns from a function.
			'r'

			-- The hook is called every time Lua enters a new line of code.
			'l'
		end

		-- Returns the current hook settings of the thread.
		-- @param thread (thread) [optional] The thread to operate over.
		-- @return (function, DebugHookMask, number) Current hook function, hook mask, and hook count.
		gethook: function(thread?: thread): function(DebugHookEvent, integer), DebugHookMask, integer

		-- Function information for debugging.
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

		-- Returns a table with information about a function.
		-- @param func (function) [optional] The function to operate over.
		-- @param f (number) stack level.
		-- @param what (string) [optional] Info to retrieve.
		-- @return (DebugGetInfoTable) Table with function information.
		getinfo: function(func: function, f: number, what?: string): DebugGetInfoTable

		-- Returns a table with information about current function.
		-- @param f (number) The stack level.
		-- @param what (string) [optional] Info to retrieve.
		-- @return (DebugGetInfoTable) Table with function information.
		getinfo: function(f: number, what?: string): DebugGetInfoTable

		-- Returns the name and value of a local variable.
		-- @param thread (thread) [optional] The thread to operate over.
		-- @param f (function) The function to inspect.
		-- @param index (integer) The local variable index.
		-- @return (string, any) Name and value of the local variable.
		getlocal: function(thread: thread, f: function, index: integer): string, any

		-- Returns the name and value of a local variable.
		-- @param thread (thread) [optional] The thread to operate over.
		-- @param f (integer) The inspecting function stack level.
		-- @param index (integer) The local variable index.
		-- @return (string, any) Name and value of the local variable.
		getlocal: function(thread: thread, f: integer, index: integer): string, any

		-- Returns the name and value of a local variable at current thread.
		-- @param f (function) The function to inspect.
		-- @param index (integer) The local variable index.
		-- @return (string, any) Name and value of the local variable.
		getlocal: function(f: function, index: integer): string, any

		-- Returns the name and value of a local variable at current thread.
		-- @param f (integer) The inspecting function stack level.
		-- @param index (integer) The local variable index.
		-- @return (string, any) Name and value of the local variable.
		getlocal: function(f: integer, index: integer): string, any

		-- Returns the metatable of the given value.
		-- @param value (any) The value to get the metatable from.
		-- @return (table | nil) The metatable or nil.
		getmetatable: function<A>(value: A): metatable<A> | nil

		-- Returns the registry table.
		-- @return (table) The registry table.
		getregistry: function(): table

		-- Returns the name and value of an upvalue.
		-- @param f (function) The function.
		-- @param up (number) The upvalue index.
		-- @return (string, any) Name and value of the upvalue.
		getupvalue: function(f: function, up: number): string, any

		record Userdata
			userdata
		end

		-- Returns the user value associated with the userdata.
		-- @param u (Userdata) The userdata.
		-- @param n (number) The index of the user value.
		-- @return (any, boolean) The user value and a boolean status.
		getuservalue: function(u: Userdata, n: number): any, boolean

		-- Sets a debug hook function.
		-- @param thread (thread) [optional] The thread to operate over.
		-- @param hook (function) The hook function.
		-- @param mask (string) The hook mask.
		-- @param count (number) [optional] The hook count.
		sethook: function(thread?: thread, hook: function(DebugHookEvent, integer), mask: DebugHookMask, count?: number)

		-- Sets a debug hook function for current thread.
		-- @param hook (function) The hook function.
		-- @param mask (string) The hook mask.
		-- @param count (number) [optional] The hook count.
		sethook: function(hook: function(DebugHookEvent, integer), mask: DebugHookMask, count?: number)

		-- Assigns a value to a local variable.
		-- @param thread (thread) [optional] The thread to operate over.
		-- @param level (number) The stack level.
		-- @param index (number) The local variable index.
		-- @param value (any) The value to assign.
		-- @return (string) Name of the local variable.
		setlocal: function(thread: thread, level: number, index: number, value: any): string

		-- Assigns a value to a local variable for current thread.
		-- @param level (number) The stack level.
		-- @param index (number) The local variable index.
		-- @param value (any) The value to assign.
		-- @return (string) Name of the local variable.
		setlocal: function(level: number, index: number, value: any): string

		-- Sets the metatable for a value.
		-- @param value (any) The value to set the metatable for.
		-- @param table (table) The metatable.
		-- @return (any) The original value.
		setmetatable: function<A>(value: A, table: metatable<A>): A

		-- Assigns a value to an upvalue.
		-- @param f (function) The function.
		-- @param up (number) The upvalue index.
		-- @param value (any) The value to assign.
		-- @return (string) Name of the upvalue.
		setupvalue: function(f: function, up: number, value: any): string

		-- Sets a user value for userdata.
		-- @param udata (Userdata) The userdata.
		-- @param value (any) The value to set.
		-- @param n (number) The index of the user value.
		-- @return (userdata) The userdata or nil if invalid.
		setuservalue: function(udata: Userdata, value: any, n: number): Userdata

		-- Returns a traceback of the call stack.
		-- @param thread (thread) [optional] The thread to operate over.
		-- @param message (string) [optional] The message to prepend.
		-- @param level (number) [optional] The stack level to start at.
		-- @return (string) The traceback string.
		traceback: function(thread: thread, message?: string, level?: number): string

		-- Returns a traceback of the call stack for current thread.
		-- @param message (string) [optional] The message to prepend.
		-- @param level (number) [optional] The stack level to start at.
		-- @return (string) The traceback string.
		traceback: function(message?: string, level?: number): string

		-- Returns a unique identifier for an upvalue.
		-- @param f (function) The function.
		-- @param n (number) The upvalue index.
		-- @return (Userdata) The unique identifier.
		upvalueid: function(f: function, n: number): Userdata

		-- Make the n1-th upvalue of the Lua closure f1 refer to the n2-th upvalue of the Lua closure f2.
		-- @param f1 (function) The first function.
		-- @param n1 (number) The first upvalue index.
		-- @param f2 (function) The second function.
		-- @param n2 (number) The second upvalue index.
		upvaluejoin: function(f1: function, n1: number, f2: function, n2: number)
	end

	-- Library provides the functionality of the operating system facilities.
	record os

		-- Enumeration for locale category.
		enum LocaleCategory
			"all"
			"collate"
			"ctype"
			"monetary"
			"numeric"
			"time"
		end

		-- Sets the current locale of the program.
		-- @param locale (string) [optional] The locale to set.
		-- If locale is the empty string, the current locale is set to an implementation-defined native locale. If locale is the string "C", the current locale is set to the standard C locale. When called with nil as the locale argument, this function only returns the name of the current locale for the given category.
		-- @param category (LocaleCategory) [optional] The category to change. Default is "all".
		-- @return (string | nil) The name of the new locale or nil if the request cannot be honored.
		setlocale: function(locale?: string, category?: LocaleCategory): string | nil

		-- The date and time record for output.
		record OutputDate
			year: number
			month: number --[[1-12]]
			day: number --[[1-31]]
			hour: number --[[0-23]]
			min: number --[[0-59]]
			sec: number --[[0-61, due to leap seconds]]
			wday: number --[[1-7, Sunday is 1]]
			yday: number --[[1-366]]
			isdst: boolean --[[daylight saving flag]]
		end

		-- Returns a string or a table containing date and time, formatted according to the given string format.
		-- @param format (string) [optional] The format string. Default is "%c" for a human-readable date and time representation. If format starts with '!', the date is formatted in Coordinated Universal Time. If format is the string "*t", then date returns a table with fields year, month, day, hour, min, sec, wday, yday, and isdst. If format is not "*t", then date returns the date as a string, formatted according to the same rules as the ISO C function strftime, for example, "%Y-%m-%d %H:%M:%S".
		-- @param time (number) [optional] The time to be formatted. Default is the current time.
		-- @return (string | OutputDate) The formatted date and time.
		date: function(format?: string, time?: number): string | OutputDate

		-- The date and time record for input.
		record InputDate
			year: number
			month: number
			day: number
			hour: number --[[default is 12]]
			min: number --[[default is 0]]
			sec: number --[[default is 0]]
			isdst: boolean --[[default is nil]]
		end

		-- Returns the current time when called without arguments, or a time representing the local date and time specified by the given table. This table must have fields year, month, and day, and may have fields hour (default is 12), min (default is 0), sec (default is 0), and isdst (default is nil). Other fields are ignored. os.time also normalizes all the fields recorded by the os.date function so that they represent the same time as before the call, but with values inside their valid ranges.
		-- @param date (InputDate) [optional] The table representing the local date and time.
		-- When the function is called, the values in these fields do not need to be inside their valid ranges. For instance, if sec is -10, it means 10 seconds before the time specified by the other fields; if hour is 1000, it means 1000 hours after the time specified by the other fields.
		-- @return (number) The current time or the time specified by the table. The return value is a number, whose meaning depends on your system. In POSIX, Windows, and some other systems, this number represents the number of seconds since some given start time (the "epoch"). In other systems, the meaning is not specified, and the number returned by time can only be used as an argument to os.date and os.difftime.
		time: function(date?: InputDate): number

		-- Returns the difference, in seconds, from time t1 to time t2 (where the times are values returned by os.time). In POSIX, Windows, and some other systems, this value is exactly t2-t1.
		-- @param t2 (number) The end time.
		-- @param t1 (number) The start time.
		-- @return (number) The difference in seconds.
		difftime: function(t2: number, t1: number): number

		-- Returns the value of the process environment variable varname or fail if the variable is not defined.
		-- @param varname (string) The name of the environment variable.
		-- @return (string | nil) The value of the environment variable, or nil if the variable is not defined.
		getenv: function(varname: string): string | nil
	end
end

return lua