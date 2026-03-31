-- [ts]: BlocklyGen.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach -- 1
local Map = ____lualib.Map -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayReduce = ____lualib.__TS__ArrayReduce -- 1
local Set = ____lualib.Set -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom -- 1
local __TS__Iterator = ____lualib.__TS__Iterator -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Log = ____Dora.Log -- 1
local ____Utils = require("Agent.Utils") -- 2
local safeJsonEncode = ____Utils.safeJsonEncode -- 2
local Gen = {} -- 2
do -- 2
	local vec2Calc -- 2
	local IdFactory = __TS__Class() -- 6
	IdFactory.name = "IdFactory" -- 6
	function IdFactory.prototype.____constructor(self) -- 6
	end -- 6
	function IdFactory.next(self, prefix) -- 8
		if prefix == nil then -- 8
			prefix = "block" -- 8
		end -- 8
		local ____prefix_3 = prefix -- 9
		local ____IdFactory_0, ____seq_1 = IdFactory, "seq" -- 9
		local ____IdFactory_seq_2 = ____IdFactory_0[____seq_1] + 1 -- 9
		____IdFactory_0[____seq_1] = ____IdFactory_seq_2 -- 9
		return (____prefix_3 .. "-") .. tostring(____IdFactory_seq_2) -- 9
	end -- 8
	IdFactory.seq = 0 -- 8
	Gen.Blk = __TS__Class() -- 4
	local Blk = Gen.Blk -- 4
	Blk.name = "Blk" -- 16
	function Blk.prototype.____constructor(self, ____type, opts) -- 24
		if opts == nil then -- 24
			opts = {} -- 26
		end -- 26
		self.id = IdFactory:next() -- 28
		self.type = ____type -- 29
		self.fields = opts.fields -- 30
		self.inputs = opts.inputs -- 31
		self.extraState = opts.extraState -- 32
	end -- 24
	function Blk.prototype.next(self, node) -- 35
		self._next = node -- 36
		return node -- 37
	end -- 35
	function Blk.prototype.toJSON(self) -- 40
		local j = {type = self.type, id = self.id} -- 41
		if self.fields then -- 41
			j.fields = self.fields -- 42
		end -- 42
		if self.inputs then -- 42
			j.inputs = {} -- 44
			for k, v in pairs(self.inputs) do -- 45
				j.inputs[k] = {block = v:toJSON()} -- 46
			end -- 46
		end -- 46
		if self.extraState then -- 46
			j.extraState = self.extraState -- 48
		end -- 48
		if self._next then -- 48
			j.next = {block = self._next:toJSON()} -- 49
		end -- 49
		return j -- 50
	end -- 40
	Gen.Bool = function(v) return __TS__New(Gen.Blk, "logic_boolean", {fields = {BOOL = v and "TRUE" or "FALSE"}}) end -- 4
	Gen.Text = function(s) -- 4
		if s == nil then -- 4
			s = "" -- 55
		end -- 55
		return __TS__New(Gen.Blk, "text", {fields = {TEXT = s}}) -- 55
	end -- 55
	Gen.Print = function(item) return __TS__New(Gen.Blk, "print_block", {inputs = {ITEM = item}}) end -- 4
	local function compare(op, a, b) -- 58
		return __TS__New(Gen.Blk, "logic_compare", {fields = {OP = op}, inputs = {A = a, B = b}}) -- 59
	end -- 58
	Gen.Eq = function(a, b) return compare("EQ", a, b) end -- 4
	Gen.Neq = function(a, b) return compare("NEQ", a, b) end -- 4
	Gen.Lt = function(a, b) return compare("LT", a, b) end -- 4
	Gen.Gt = function(a, b) return compare("GT", a, b) end -- 4
	Gen.Gte = function(a, b) return compare("GTE", a, b) end -- 4
	Gen.Lte = function(a, b) return compare("LTE", a, b) end -- 4
	local function logicOp(op, a, b) -- 68
		return __TS__New(Gen.Blk, "logic_operation", {fields = {OP = op}, inputs = {A = a, B = b}}) -- 69
	end -- 68
	Gen.And = function(a, b) return logicOp("AND", a, b) end -- 4
	Gen.Or = function(a, b) return logicOp("OR", a, b) end -- 4
	Gen.Not = function(b) return __TS__New(Gen.Blk, "logic_negate", {inputs = {BOOL = b}}) end -- 4
	Gen.Ternary = function(cond, thenValue, elseValue) return __TS__New(Gen.Blk, "logic_ternary", {inputs = {IF = cond, THEN = thenValue, ELSE = elseValue}}) end -- 4
	Gen.List = function(...) -- 4
		local items = {...} -- 4
		local inputMap = {} -- 85
		__TS__ArrayForEach( -- 86
			items, -- 86
			function(____, b, i) -- 86
				inputMap["ADD" .. tostring(i)] = b -- 87
			end -- 86
		) -- 86
		return __TS__New(Gen.Blk, "lists_create_with", {extraState = {itemCount = #items}, inputs = inputMap}) -- 89
	end -- 84
	local varMap = __TS__New(Map) -- 96
	local function varAccess(name) -- 97
		varMap:set(name, {name = name, id = name}) -- 98
		return {id = name} -- 99
	end -- 97
	Gen.Declare = function(name, value) return __TS__New(Gen.Blk, "declare_variable", {fields = {VAR = {id = name, name = name}}, inputs = {VALUE = value}}) end -- 4
	Gen.If = function(cond, body) return {condition = cond, elseBranch = false, body = body} end -- 4
	Gen.Else = function(body) return {elseBranch = true, body = body} end -- 4
	local function _ifElseCore(main, elseIfs, otherwise) -- 111
		local inputs = {IF0 = main.condition, DO0 = main.body} -- 116
		__TS__ArrayForEach( -- 120
			elseIfs, -- 120
			function(____, br, idx) -- 120
				inputs["IF" .. tostring(idx + 1)] = br.condition -- 121
				inputs["DO" .. tostring(idx + 1)] = br.body -- 122
			end -- 120
		) -- 120
		if otherwise then -- 120
			inputs.ELSE = otherwise -- 124
		end -- 124
		return __TS__New(Gen.Blk, "controls_if", {extraState = {elseIfCount = #elseIfs, hasElse = not not otherwise}, inputs = inputs}) -- 125
	end -- 111
	Gen.IfElse = function(...) -- 4
		local ifBranchesOrElse = {...} -- 4
		local last = ifBranchesOrElse[#ifBranchesOrElse] -- 132
		local main = ifBranchesOrElse[1] -- 133
		local elseIfs = last.elseBranch and __TS__ArraySlice(ifBranchesOrElse, 1, -1) or __TS__ArraySlice(ifBranchesOrElse, 1) -- 134
		local elseBody = last.elseBranch and last.body or nil -- 135
		return _ifElseCore(main, elseIfs, elseBody) -- 136
	end -- 131
	Gen.Block = function(...) -- 4
		local nodes = {...} -- 4
		__TS__ArrayReduce( -- 140
			nodes, -- 140
			function(____, prev, cur) -- 140
				prev:next(cur) -- 140
				return cur -- 140
			end -- 140
		) -- 140
		return nodes[1] -- 141
	end -- 139
	local collectVariables -- 144
	collectVariables = function(node, set) -- 144
		if set == nil then -- 144
			set = __TS__New(Set) -- 144
		end -- 144
		local ____temp_8 = node.type == "declare_variable" -- 145
		if ____temp_8 then -- 145
			local ____opt_6 = node.fields -- 145
			local ____opt_4 = ____opt_6 and ____opt_6.VAR -- 145
			if ____opt_4 ~= nil then -- 145
				____opt_4 = ____opt_4.id -- 145
			end -- 145
			____temp_8 = ____opt_4 -- 145
		end -- 145
		if ____temp_8 then -- 145
			set:add(node.fields.VAR.id) -- 146
		end -- 146
		if node.inputs then -- 146
			for ____, n in pairs(node.inputs) do -- 149
				collectVariables(n, set) -- 150
			end -- 150
		end -- 150
		if node._next then -- 150
			collectVariables(node._next, set) -- 153
		end -- 153
		return set -- 154
	end -- 144
	local fixProcParamNames -- 157
	fixProcParamNames = function(node, funcs) -- 157
		if node.type == "procedures_callnoreturn" or node.type == "procedures_callreturn" then -- 157
			local funcName = node.extraState.name -- 159
			for ____, func in ipairs(funcs) do -- 160
				local ____opt_9 = func.fields -- 160
				local name = ____opt_9 and ____opt_9.NAME -- 161
				if funcName == name then -- 161
					local params = func.extraState.params -- 163
					node.extraState.params = __TS__ArrayMap( -- 164
						params, -- 164
						function(____, param) return param.name end -- 164
					) -- 164
				end -- 164
			end -- 164
		end -- 164
		if node.inputs then -- 164
			for ____, n in pairs(node.inputs) do -- 169
				fixProcParamNames(n, funcs) -- 170
			end -- 170
		end -- 170
		if node._next then -- 170
			fixProcParamNames(node._next, funcs) -- 173
		end -- 173
	end -- 157
	Gen.Num = function(n) return __TS__New(Gen.Blk, "math_number", {fields = {NUM = n}}) end -- 4
	Gen.VarGet = function(name) return __TS__New(Gen.Blk, "variables_get", {fields = {VAR = {id = name, name = name}}}) end -- 4
	Gen.Repeat = function(times, body) return __TS__New(Gen.Blk, "controls_repeat_ext", {inputs = {TIMES = times, DO = body}}) end -- 4
	local function whileUntil(mode) -- 190
		return function(cond, body) return __TS__New(Gen.Blk, "controls_whileUntil", {fields = {MODE = mode}, inputs = {BOOL = cond, DO = body}}) end -- 192
	end -- 190
	Gen.While = whileUntil("WHILE") -- 4
	Gen.Until = whileUntil("UNTIL") -- 4
	Gen.For = function(varName, from, to, by, body) return __TS__New( -- 4
		Gen.Blk, -- 4
		"controls_for", -- 208
		{ -- 208
			fields = {VAR = varAccess(varName)}, -- 209
			inputs = {FROM = from, TO = to, BY = by, DO = body} -- 210
		} -- 210
	) end -- 210
	Gen.ForEach = function(varName, list, body) return __TS__New( -- 4
		Gen.Blk, -- 4
		"controls_forEach", -- 223
		{ -- 223
			fields = {VAR = varAccess(varName)}, -- 224
			inputs = {LIST = list, DO = body} -- 225
		} -- 225
	) end -- 225
	local function flowStmt(kind) -- 228
		return __TS__New(Gen.Blk, "controls_flow_statements", {fields = {FLOW = kind}}) -- 229
	end -- 228
	Gen.Break = function() return flowStmt("BREAK") end -- 4
	Gen.Continue = function() return flowStmt("CONTINUE") end -- 4
	local function constant(c) -- 236
		return __TS__New(Gen.Blk, "math_constant", {fields = {CONSTANT = c}}) -- 239
	end -- 236
	Gen.PI = constant("PI") -- 4
	Gen.E = constant("E") -- 4
	Gen.GOLDEN_RATIO = constant("GOLDEN_RATIO") -- 4
	Gen.SQRT2 = constant("SQRT2") -- 4
	Gen.SQRT1_2 = constant("SQRT1_2") -- 4
	Gen.INFINITY = constant("INFINITY") -- 4
	local function arithmetic(op, A, B) -- 248
		return __TS__New(Gen.Blk, "math_arithmetic", {fields = {OP = op}, inputs = {A = A, B = B}}) -- 252
	end -- 248
	Gen.Add = function(a, b) return arithmetic("ADD", a, b) end -- 4
	Gen.Sub = function(a, b) return arithmetic("MINUS", a, b) end -- 4
	Gen.Mul = function(a, b) return arithmetic("MULTIPLY", a, b) end -- 4
	Gen.Div = function(a, b) return arithmetic("DIVIDE", a, b) end -- 4
	Gen.Pow = function(a, b) return arithmetic("POWER", a, b) end -- 4
	local function mathSingle(op, n) -- 260
		return __TS__New(Gen.Blk, "math_single", {fields = {OP = op}, inputs = {NUM = n}}) -- 265
	end -- 260
	Gen.Root = function(n) return mathSingle("ROOT", n) end -- 4
	Gen.Abs = function(n) return mathSingle("ABS", n) end -- 4
	Gen.Neg = function(n) return mathSingle("NEG", n) end -- 4
	Gen.Ln = function(n) return mathSingle("LN", n) end -- 4
	Gen.Log10 = function(n) return mathSingle("LOG10", n) end -- 4
	Gen.Exp = function(n) return mathSingle("EXP", n) end -- 4
	Gen.Pow10 = function(n) return mathSingle("POW10", n) end -- 4
	local function trig(op, n) -- 275
		return __TS__New(Gen.Blk, "math_trig", {fields = {OP = op}, inputs = {NUM = n}}) -- 278
	end -- 275
	Gen.Sin = function(deg) return trig("SIN", deg) end -- 4
	Gen.Cos = function(deg) return trig("COS", deg) end -- 4
	Gen.Tan = function(deg) return trig("TAN", deg) end -- 4
	Gen.Asin = function(deg) return trig("ASIN", deg) end -- 4
	Gen.Acos = function(deg) return trig("ACOS", deg) end -- 4
	Gen.Atan = function(deg) return trig("ATAN", deg) end -- 4
	local function numProp(property, n) -- 287
		return __TS__New(Gen.Blk, "math_number_property", {fields = {PROPERTY = property}, extraState = "<mutation divisor_input=\"false\"></mutation>", inputs = {NUMBER_TO_CHECK = n}}) -- 293
	end -- 287
	Gen.IsEven = function(n) return numProp("EVEN", n) end -- 4
	Gen.IsOdd = function(n) return numProp("ODD", n) end -- 4
	Gen.IsPrime = function(n) return numProp("PRIME", n) end -- 4
	Gen.IsWhole = function(n) return numProp("WHOLE", n) end -- 4
	Gen.IsPositive = function(n) return numProp("POSITIVE", n) end -- 4
	Gen.IsNegtive = function(n) return numProp("NEGATIVE", n) end -- 4
	Gen.IsDivisibleBy = function(n, divisor) return __TS__New(Gen.Blk, "math_number_property", {fields = {PROPERTY = "DIVISIBLE_BY"}, extraState = "<mutation divisor_input=\"true\"></mutation>", inputs = {NUMBER_TO_CHECK = n, DIVISOR = divisor}}) end -- 4
	local function round(op, n) -- 311
		return __TS__New(Gen.Blk, "math_round", {fields = {OP = op}, inputs = {NUM = n}}) -- 314
	end -- 311
	Gen.Round = function(n) return round("ROUND", n) end -- 4
	Gen.RoundUp = function(n) return round("ROUNDUP", n) end -- 4
	Gen.RoundDown = function(n) return round("ROUNDDOWN", n) end -- 4
	Gen.Modulo = function(dividend, divisor) return __TS__New(Gen.Blk, "math_modulo", {inputs = {DIVIDEND = dividend, DIVISOR = divisor}}) end -- 4
	local function mathOnList(op, listBlock) -- 323
		return __TS__New(Gen.Blk, "math_on_list", {fields = {OP = op}, extraState = ("<mutation op=\"" .. op) .. "\"></mutation>", inputs = {LIST = listBlock}}) -- 329
	end -- 323
	Gen.Sum = function(listBlock) return mathOnList("SUM", listBlock) end -- 4
	Gen.Min = function(listBlock) return mathOnList("MIN", listBlock) end -- 4
	Gen.Max = function(listBlock) return mathOnList("MAX", listBlock) end -- 4
	Gen.Average = function(listBlock) return mathOnList("AVERAGE", listBlock) end -- 4
	Gen.Median = function(listBlock) return mathOnList("MEDIAN", listBlock) end -- 4
	Gen.Mode = function(listBlock) return mathOnList("MODE", listBlock) end -- 4
	Gen.StdDev = function(listBlock) return mathOnList("STD_DEV", listBlock) end -- 4
	Gen.Random = function(listBlock) return mathOnList("RANDOM", listBlock) end -- 4
	Gen.Constrain = function(valueNum, lowNum, highNum) return __TS__New(Gen.Blk, "math_constrain", {inputs = {VALUE = valueNum, LOW = lowNum, HIGH = highNum}}) end -- 4
	Gen.RandomInt = function(fromNum, toNum) return __TS__New(Gen.Blk, "math_random_int", {inputs = {FROM = fromNum, TO = toNum}}) end -- 4
	Gen.RandomFloat = function() return __TS__New(Gen.Blk, "math_random_float") end -- 4
	Gen.Atan2 = function(x, y) return __TS__New(Gen.Blk, "math_atan2", {inputs = {X = x, Y = y}}) end -- 4
	Gen.TextJoin = function(...) -- 4
		local texts = {...} -- 4
		local inputMap = {} -- 356
		__TS__ArrayForEach( -- 357
			texts, -- 357
			function(____, b, i) -- 357
				inputMap["ADD" .. tostring(i)] = b -- 358
			end -- 357
		) -- 357
		return __TS__New(Gen.Blk, "text_join", {extraState = {itemCount = #texts}, inputs = inputMap}) -- 360
	end -- 355
	Gen.TextAppend = function(varName, what) return __TS__New( -- 4
		Gen.Blk, -- 4
		"text_append", -- 367
		{ -- 367
			fields = {VAR = varAccess(varName)}, -- 368
			inputs = {TEXT = what} -- 369
		} -- 369
	) end -- 369
	Gen.TextLength = function(text) return __TS__New(Gen.Blk, "text_length", {inputs = {VALUE = text}}) end -- 4
	Gen.IsTextEmpty = function(text) return __TS__New(Gen.Blk, "text_isEmpty", {inputs = {VALUE = text}}) end -- 4
	Gen.TextReverse = function(text) return __TS__New(Gen.Blk, "text_reverse", {inputs = {TEXT = text}}) end -- 4
	local function textIndexOf(____end, textBlk, findBlk) -- 382
		return __TS__New(Gen.Blk, "text_indexOf", {fields = {END = ____end}, inputs = {VALUE = textBlk, FIND = findBlk}}) -- 387
	end -- 382
	Gen.TextFirstIndexOf = function(text, firstFind) return textIndexOf("FIRST", text, firstFind) end -- 4
	Gen.TextLastIndexOf = function(text, lastFind) return textIndexOf("LAST", text, lastFind) end -- 4
	local function charAt(where, textBlk, at) -- 396
		return __TS__New( -- 401
			Gen.Blk, -- 4
			"text_charAt", -- 401
			{ -- 401
				extraState = ("<mutation at=\"" .. tostring(where == "FROM_START" or where == "FROM_END")) .. "\"></mutation>", -- 402
				fields = {WHERE = where}, -- 403
				inputs = __TS__ObjectAssign({VALUE = textBlk}, at and ({AT = at}) or ({})) -- 404
			} -- 404
		) -- 404
	end -- 396
	Gen.CharFromStart = function(text, at) return charAt("FROM_START", text, at) end -- 4
	Gen.CharFromEnd = function(text, at) return charAt("FROM_END", text, at) end -- 4
	Gen.FirstChar = function(text) return charAt("FIRST", text) end -- 4
	Gen.LastChar = function(text) return charAt("LAST", text) end -- 4
	Gen.RandomChar = function(text) return charAt("RANDOM", text) end -- 4
	local function substring(where1, where2, textBlk, at1, at2) -- 418
		return __TS__New( -- 423
			Gen.Blk, -- 4
			"text_getSubstring", -- 423
			{ -- 423
				extraState = ((("<mutation at1=\"" .. tostring(where1 == "FROM_START" or where1 == "FROM_END")) .. "\" at2=\"") .. tostring(where2 == "FROM_START" or where2 == "FROM_END")) .. "\"></mutation>", -- 424
				fields = {WHERE1 = where1, WHERE2 = where2}, -- 425
				inputs = __TS__ObjectAssign({STRING = textBlk}, at1 and ({AT1 = at1}) or ({}), at2 and ({AT2 = at2}) or ({})) -- 426
			} -- 426
		) -- 426
	end -- 418
	Gen.Substring = function(at1, at2) return substring("FROM_START", at2 and "FROM_START" or "LAST", at1, at2) end -- 4
	local function changeCase(mode, str) -- 436
		return __TS__New(Gen.Blk, "text_changeCase", {fields = {CASE = mode}, inputs = {TEXT = str}}) -- 437
	end -- 436
	Gen.UpperCase = function(text) return changeCase("UPPERCASE", text) end -- 4
	Gen.LowerCase = function(text) return changeCase("LOWERCASE", text) end -- 4
	Gen.TitleCase = function(text) return changeCase("TITLECASE", text) end -- 4
	local function trim(mode, str) -- 447
		return __TS__New(Gen.Blk, "text_trim", {fields = {MODE = mode}, inputs = {TEXT = str}}) -- 448
	end -- 447
	Gen.TrimLeft = function(text) return trim("LEFT", text) end -- 4
	Gen.TrimRight = function(text) return trim("RIGHT", text) end -- 4
	Gen.Trim = function(text) return trim("BOTH", text) end -- 4
	Gen.TextCount = function(subText, text) return __TS__New(Gen.Blk, "text_count", {inputs = {SUB = subText, TEXT = text}}) end -- 4
	Gen.TextReplace = function(text, fromText, toText) return __TS__New(Gen.Blk, "text_replace", {inputs = {TEXT = text, FROM = fromText, TO = toText}}) end -- 4
	Gen.RepeatList = function(item, times) return __TS__New(Gen.Blk, "lists_repeat", {inputs = {ITEM = item, NUM = times}}) end -- 4
	Gen.ListLength = function(list) return __TS__New(Gen.Blk, "lists_length", {inputs = {VALUE = list}}) end -- 4
	Gen.IsListEmpty = function(list) return __TS__New(Gen.Blk, "lists_isEmpty", {inputs = {VALUE = list}}) end -- 4
	local function indexOf(list, findItem, which) -- 480
		return __TS__New(Gen.Blk, "lists_indexOf", {fields = {END = which}, inputs = {VALUE = list, FIND = findItem}}) -- 485
	end -- 480
	Gen.FirstIndexOf = function(list, findItem) return indexOf(list, findItem, "FIRST") end -- 4
	Gen.LastIndexOf = function(list, findItem) return indexOf(list, findItem, "FIRST") end -- 4
	local function listGetIndex(mode, where, listExpr, at) -- 501
		return __TS__New( -- 507
			Gen.Blk, -- 4
			"lists_getIndex", -- 507
			{ -- 507
				fields = {MODE = mode, WHERE = where}, -- 508
				inputs = __TS__ObjectAssign({VALUE = listExpr}, at and ({AT = at}) or ({})), -- 509
				extraState = {isStatement = mode == "REMOVE"} -- 513
			} -- 513
		) -- 513
	end -- 501
	Gen.ListGet = function(list, at) return listGetIndex("GET", "FROM_START", list, at) end -- 4
	Gen.ListRemoveGet = function(list, at) return listGetIndex("GET_REMOVE", "FROM_START", list, at) end -- 4
	Gen.ListRemove = function(list, at) return listGetIndex("REMOVE", "FROM_START", list, at) end -- 4
	Gen.ListRemoveLast = function(list) return listGetIndex("GET_REMOVE", "LAST", list) end -- 4
	Gen.ListRemoveFirst = function(list) return listGetIndex("GET_REMOVE", "FIRST", list) end -- 4
	local function subList(listExpr, where1, where2, at1, at2) -- 522
		return __TS__New(Gen.Blk, "lists_getSublist", {fields = {WHERE1 = where1, WHERE2 = where2}, inputs = at2 and ({LIST = listExpr, AT1 = at1, AT2 = at2}) or ({LIST = listExpr, AT1 = at1})}) -- 529
	end -- 522
	Gen.SubList = function(list, at1, at2) return subList( -- 4
		list, -- 535
		"FROM_START", -- 535
		at2 and "FROM_START" or "LAST", -- 535
		at1, -- 535
		at2 -- 535
	) end -- 535
	local function listSplit(input, delim, mode) -- 537
		return __TS__New(Gen.Blk, "lists_split", {fields = {MODE = mode}, inputs = {INPUT = input, DELIM = delim}}) -- 542
	end -- 537
	Gen.ListSplit = function(inputText, delimText) return listSplit(inputText, delimText, "SPLIT") end -- 4
	Gen.ListStringConcat = function(list, delimText) return listSplit(list, delimText, "JOIN") end -- 4
	local function listSort(listExpr, ____type, direction) -- 550
		return __TS__New(Gen.Blk, "lists_sort", {fields = {TYPE = ____type, DIRECTION = direction}, inputs = {LIST = listExpr}}) -- 555
	end -- 550
	Gen.ListSort = function(list, desc) return listSort(list, "NUMERIC", desc and "-1" or "1") end -- 4
	Gen.ListReverse = function(list) return __TS__New(Gen.Blk, "lists_reverse", {inputs = {LIST = list}}) end -- 4
	local function listSetIndex(mode, listExpr, at, to, where) -- 565
		return __TS__New(Gen.Blk, "lists_setIndex", {fields = {MODE = mode, WHERE = where}, inputs = {LIST = listExpr, AT = at, TO = to}}) -- 572
	end -- 565
	Gen.ListSet = function(list, at, item) return listSetIndex( -- 4
		"SET", -- 577
		list, -- 577
		at, -- 577
		item, -- 577
		"FROM_START" -- 577
	) end -- 577
	Gen.ListInsert = function(list, at, item) return listSetIndex( -- 4
		"INSERT", -- 578
		list, -- 578
		at, -- 578
		item, -- 578
		"FROM_START" -- 578
	) end -- 578
	Gen.Dict = function() return __TS__New(Gen.Blk, "dict_create") end -- 4
	Gen.DictGet = function(dict, key) return __TS__New(Gen.Blk, "dict_get", {inputs = {DICT = dict, KEY = key}}) end -- 4
	Gen.DictSet = function(dict, key, val) return __TS__New(Gen.Blk, "dict_set", {inputs = {DICT = dict, KEY = key, VALUE = val}}) end -- 4
	Gen.DictContain = function(dict, key) return __TS__New(Gen.Blk, "dict_has_key", {inputs = {DICT = dict, KEY = key}}) end -- 4
	Gen.DictRemove = function(dict, key) return __TS__New(Gen.Blk, "dict_remove_key", {inputs = {DICT = dict, KEY = key}}) end -- 4
	Gen.VarSet = function(name, value) return __TS__New( -- 4
		Gen.Blk, -- 4
		"variables_set", -- 595
		{ -- 595
			fields = {VAR = varAccess(name)}, -- 596
			inputs = {VALUE = value} -- 597
		} -- 597
	) end -- 597
	Gen.VarAdd = function(name, deltaNum) return __TS__New( -- 4
		Gen.Blk, -- 4
		"math_change", -- 601
		{ -- 601
			fields = {VAR = varAccess(name)}, -- 602
			inputs = {DELTA = deltaNum} -- 603
		} -- 603
	) end -- 603
	Gen.ProcReturn = function(value) return __TS__New(Gen.Blk, "return_block", {inputs = value and ({VALUE = value}) or ({})}) end -- 4
	Gen.ProcIfReturn = function(cond, value) return __TS__New( -- 4
		Gen.Blk, -- 4
		"procedures_ifreturn", -- 613
		{ -- 613
			extraState = ("<mutation value=\"" .. tostring(value and 1 or 0)) .. "\"></mutation>", -- 614
			inputs = value and ({CONDITION = cond, VALUE = value}) or ({CONDITION = cond}) -- 615
		} -- 615
	) end -- 615
	local function buildParams(names) -- 620
		return __TS__ArrayMap( -- 621
			names, -- 621
			function(____, p) return { -- 621
				name = p, -- 621
				id = IdFactory:next("arg") -- 621
			} end -- 621
		) -- 621
	end -- 620
	Gen.DefProcReturn = function(name, params, body, returnExpr) return __TS__New( -- 4
		Gen.Blk, -- 4
		"procedures_defreturn", -- 629
		{ -- 629
			fields = {NAME = name}, -- 630
			inputs = {STACK = body, RETURN = returnExpr}, -- 631
			extraState = {params = buildParams(params)} -- 632
		} -- 632
	) end -- 632
	Gen.DefProc = function(name, params, body) return __TS__New( -- 4
		Gen.Blk, -- 4
		"procedures_defnoreturn", -- 640
		{ -- 640
			fields = {NAME = name}, -- 641
			inputs = {STACK = body}, -- 642
			extraState = {params = buildParams(params)} -- 643
		} -- 643
	) end -- 643
	Gen.CallProc = function(procName, ...) -- 4
		local args = {...} -- 4
		local inputMap = {} -- 647
		__TS__ArrayForEach( -- 648
			args, -- 648
			function(____, value, i) -- 648
				inputMap["ARG" .. tostring(i)] = value -- 649
			end -- 648
		) -- 648
		return __TS__New(Gen.Blk, "procedures_callnoreturn", {extraState = {name = procName, params = nil}, inputs = inputMap}) -- 651
	end -- 646
	Gen.CallProcReturn = function(procName, ...) -- 4
		local args = {...} -- 4
		local inputMap = {} -- 658
		__TS__ArrayForEach( -- 659
			args, -- 659
			function(____, value, i) -- 659
				inputMap["ARG" .. tostring(i)] = value -- 660
			end -- 659
		) -- 659
		return __TS__New(Gen.Blk, "procedures_callreturn", {extraState = {name = procName, params = nil}, inputs = inputMap}) -- 662
	end -- 657
	Gen.Vec2Zero = function() return __TS__New(Gen.Blk, "vec2_zero") end -- 4
	Gen.Vec2 = function(x, y) return __TS__New(Gen.Blk, "vec2_create", {inputs = {X = x, Y = y}}) end -- 4
	local function vec2Prop(vecVar, prop) -- 674
		return __TS__New( -- 675
			Gen.Blk, -- 4
			"vec2_get_property", -- 675
			{fields = { -- 675
				VEC2 = varAccess(vecVar), -- 676
				PROPERTY = prop -- 676
			}} -- 676
		) -- 676
	end -- 674
	Gen.Vec2X = function(varName) return vec2Prop(varName, "x") end -- 4
	Gen.Vec2Y = function(varName) return vec2Prop(varName, "y") end -- 4
	Gen.Vec2Length = function(varName) return vec2Prop(varName, "length") end -- 4
	Gen.Vec2Angle = function(varName) return vec2Prop(varName, "angle") end -- 4
	Gen.Vec2Normalize = function(v) return __TS__New(Gen.Blk, "vec2_get_normalized", {inputs = {VEC2 = v}}) end -- 4
	local function vec2VecOp(op, a, b) -- 687
		return __TS__New(Gen.Blk, "vec2_binary_operation", {fields = {OPERATION = op}, inputs = {VEC2_1 = a, VEC2_2 = b}}) -- 688
	end -- 687
	Gen.Vec2Add = function(a, b) return vec2VecOp("+", a, b) end -- 4
	Gen.Vec2Sub = function(a, b) return vec2VecOp("-", a, b) end -- 4
	Gen.Vec2MulVec = function(a, b) return vec2VecOp("*", a, b) end -- 4
	Gen.Vec2DivVec = function(a, b) return vec2VecOp("/", a, b) end -- 4
	Gen.Vec2Distance = function(a, b) return vec2Calc("distance", a, b) end -- 4
	Gen.Vec2Dot = function(a, b) return vec2Calc("dot", a, b) end -- 4
	local function vec2NumOp(op, v, n) -- 700
		return __TS__New(Gen.Blk, "vec2_binary_op_number", {fields = {OPERATION = op}, inputs = {VEC2 = v, NUMBER = n}}) -- 701
	end -- 700
	Gen.Vec2MulNum = function(v, n) return vec2NumOp("*", v, n) end -- 4
	Gen.Vec2DivNum = function(v, n) return vec2NumOp("/", v, n) end -- 4
	Gen.Vec2Clamp = function(v, min, max) return __TS__New(Gen.Blk, "vec2_clamp", {inputs = {VEC2 = v, MIN = min, MAX = max}}) end -- 4
	vec2Calc = function(what, a, b) return __TS__New(Gen.Blk, "vec2_calculate", {fields = {CALCULATE = what}, inputs = {VEC2_1 = a, VEC2_2 = b}}) end -- 718
	Gen.CreateNode = function() return __TS__New(Gen.Blk, "node_create") end -- 4
	Gen.CreateSprite = function(file) return __TS__New(Gen.Blk, "sprite_create", {inputs = {FILE = file}}) end -- 4
	Gen.CreateLabel = function(fontName, size) return __TS__New(Gen.Blk, "label_create", {inputs = {FONT = fontName, SIZE = size}}) end -- 4
	Gen.LabelSetText = function(varName, text) return __TS__New( -- 4
		Gen.Blk, -- 4
		"label_set_text", -- 737
		{ -- 737
			fields = {LABEL = varAccess(varName)}, -- 738
			inputs = {TEXT = text} -- 739
		} -- 739
	) end -- 739
	Gen.NodeAddChild = function(parentVar, childVar, order) return __TS__New( -- 4
		Gen.Blk, -- 4
		"node_add_child", -- 743
		{ -- 743
			fields = { -- 744
				PARENT = varAccess(parentVar), -- 744
				CHILD = varAccess(childVar) -- 744
			}, -- 744
			inputs = {ORDER = order} -- 745
		} -- 745
	) end -- 745
	local function nodeSetNumAttr(varName, attr, value) -- 749
		return __TS__New( -- 750
			Gen.Blk, -- 4
			"node_set_number_attribute", -- 750
			{ -- 750
				fields = { -- 751
					NODE = varAccess(varName), -- 751
					ATTRIBUTE = attr -- 751
				}, -- 751
				inputs = {VALUE = value} -- 752
			} -- 752
		) -- 752
	end -- 749
	Gen.NodeSetX = function(varName, n) return nodeSetNumAttr(varName, "x", n) end -- 4
	Gen.NodeSetY = function(varName, n) return nodeSetNumAttr(varName, "y", n) end -- 4
	Gen.NodeSetWidth = function(varName, n) return nodeSetNumAttr(varName, "width", n) end -- 4
	Gen.NodeSetHeight = function(varName, n) return nodeSetNumAttr(varName, "height", n) end -- 4
	Gen.NodeSetAngle = function(varName, n) return nodeSetNumAttr(varName, "angle", n) end -- 4
	Gen.NodeSetScale = function(varName, n) return nodeSetNumAttr(varName, "scale", n) end -- 4
	Gen.NodeSetScaleX = function(varName, n) return nodeSetNumAttr(varName, "scaleX", n) end -- 4
	Gen.NodeSetScaleY = function(varName, n) return nodeSetNumAttr(varName, "scaleY", n) end -- 4
	Gen.NodeSetOpactity = function(varName, n) return nodeSetNumAttr(varName, "opacity", n) end -- 4
	local function nodeGetNumAttr(varName, attr) -- 764
		return __TS__New( -- 765
			Gen.Blk, -- 4
			"node_get_number_attribute", -- 765
			{fields = { -- 765
				NODE = varAccess(varName), -- 766
				ATTRIBUTE = attr -- 766
			}} -- 766
		) -- 766
	end -- 764
	Gen.NodeGetX = function(varName) return nodeGetNumAttr(varName, "x") end -- 4
	Gen.NodeGetY = function(varName) return nodeGetNumAttr(varName, "y") end -- 4
	Gen.NodeGetWidth = function(varName) return nodeGetNumAttr(varName, "width") end -- 4
	Gen.NodeGetHeight = function(varName) return nodeGetNumAttr(varName, "height") end -- 4
	Gen.NodeGetAngle = function(varName) return nodeGetNumAttr(varName, "angle") end -- 4
	Gen.NodeGetScale = function(varName) return nodeGetNumAttr(varName, "scale") end -- 4
	Gen.NodeGetScaleX = function(varName) return nodeGetNumAttr(varName, "scaleX") end -- 4
	Gen.NodeGetScaleY = function(varName) return nodeGetNumAttr(varName, "scaleY") end -- 4
	Gen.NodeGetOpactity = function(varName) return nodeGetNumAttr(varName, "opacity") end -- 4
	local function nodeSetBoolAttr(nodeVar, attr, value) -- 780
		return __TS__New( -- 781
			Gen.Blk, -- 4
			"node_set_boolean_attribute", -- 781
			{ -- 781
				fields = { -- 782
					NODE = varAccess(nodeVar), -- 782
					ATTRIBUTE = attr -- 782
				}, -- 782
				inputs = {VALUE = value} -- 783
			} -- 783
		) -- 783
	end -- 780
	Gen.NodeSetVisible = function(varName, bool) return nodeSetBoolAttr(varName, "visible", bool) end -- 4
	local function nodeGetBoolAttr(varName, attr) -- 788
		return __TS__New( -- 789
			Gen.Blk, -- 4
			"node_get_boolean_attribute", -- 789
			{fields = { -- 789
				NODE = varAccess(varName), -- 790
				ATTRIBUTE = attr -- 790
			}} -- 790
		) -- 790
	end -- 788
	Gen.NodeGetVisible = function(varName) return nodeGetBoolAttr(varName, "visible") end -- 4
	local function nodeSetVec2Attr(varName, attr, vec) -- 796
		return __TS__New( -- 797
			Gen.Blk, -- 4
			"node_set_vec2_attribute", -- 797
			{ -- 797
				fields = { -- 798
					NODE = varAccess(varName), -- 798
					ATTRIBUTE = attr -- 798
				}, -- 798
				inputs = {VEC2 = vec} -- 799
			} -- 799
		) -- 799
	end -- 796
	Gen.NodeSetPosition = function(varName, vec) return nodeSetVec2Attr(varName, "position", vec) end -- 4
	Gen.NodeSetAnchor = function(varName, vec) return nodeSetVec2Attr(varName, "anchor", vec) end -- 4
	local function nodeGetVec2Attr(nodeVar, attr) -- 805
		return __TS__New( -- 806
			Gen.Blk, -- 4
			"node_get_vec2_attribute", -- 806
			{fields = { -- 806
				NODE = varAccess(nodeVar), -- 807
				ATTRIBUTE = attr -- 807
			}} -- 807
		) -- 807
	end -- 805
	Gen.NodeGetPosition = function(varName) return nodeGetVec2Attr(varName, "position") end -- 4
	Gen.NodeGetAnchor = function(varName) return nodeGetVec2Attr(varName, "anchor") end -- 4
	Gen.BeginPaint = function(nodeVar, paintBody) return __TS__New( -- 4
		Gen.Blk, -- 4
		"nvg_begin_painting", -- 814
		{ -- 814
			fields = {NODE = varAccess(nodeVar)}, -- 815
			inputs = {PAINT = paintBody} -- 816
		} -- 816
	) end -- 816
	Gen.BeginPath = function() return __TS__New(Gen.Blk, "nvg_begin_path") end -- 4
	Gen.MoveTo = function(x, y) return __TS__New(Gen.Blk, "nvg_move_to", {inputs = {X = x, Y = y}}) end -- 4
	Gen.BezierTo = function(c1x, c1y, c2x, c2y, x, y) return __TS__New(Gen.Blk, "nvg_bezier_to", {inputs = { -- 4
		C1X = c1x, -- 830
		C1Y = c1y, -- 830
		C2X = c2x, -- 830
		C2Y = c2y, -- 830
		X = x, -- 830
		Y = y -- 830
	}}) end -- 830
	Gen.LineTo = function(x, y) return __TS__New(Gen.Blk, "nvg_line_to", {inputs = {X = x, Y = y}}) end -- 4
	Gen.ClosePath = function() return __TS__New(Gen.Blk, "nvg_close_path") end -- 4
	Gen.FillColor = function(color, opacity) return __TS__New(Gen.Blk, "nvg_fill_color", {inputs = {COLOR = color, OPACITY = opacity}}) end -- 4
	Gen.Fill = function() return __TS__New(Gen.Blk, "nvg_fill") end -- 4
	Gen.StrokeColor = function(color, opacity) return __TS__New(Gen.Blk, "nvg_stroke_color", {inputs = {COLOR = color, OPACITY = opacity}}) end -- 4
	Gen.StrokeWidth = function(w) return __TS__New(Gen.Blk, "nvg_stroke_width", {inputs = {WIDTH = w}}) end -- 4
	Gen.Stroke = function() return __TS__New(Gen.Blk, "nvg_stroke") end -- 4
	Gen.Rect = function(x, y, w, h) return __TS__New(Gen.Blk, "nvg_rect", {inputs = {X = x, Y = y, WIDTH = w, HEIGHT = h}}) end -- 4
	Gen.RoundedRect = function(x, y, w, h, r) return __TS__New(Gen.Blk, "nvg_rounded_rect", {inputs = { -- 4
		X = x, -- 862
		Y = y, -- 862
		WIDTH = w, -- 862
		HEIGHT = h, -- 862
		RADIUS = r -- 862
	}}) end -- 862
	Gen.Ellipse = function(cx, cy, rx, ry) return __TS__New(Gen.Blk, "nvg_ellipse", {inputs = {CX = cx, CY = cy, RX = rx, RY = ry}}) end -- 4
	Gen.Circle = function(cx, cy, radius) return __TS__New(Gen.Blk, "nvg_circle", {inputs = {CX = cx, CY = cy, RADIUS = radius}}) end -- 4
	Gen.Color = function(hex) return __TS__New(Gen.Blk, "colour_hsv_sliders", {fields = {COLOUR = hex}}) end -- 4
	Gen.OnUpdate = function(nodeVar, dtVar, actionBody) return __TS__New( -- 4
		Gen.Blk, -- 4
		"on_update", -- 885
		{ -- 885
			fields = { -- 886
				NODE = varAccess(nodeVar), -- 886
				DELTA_TIME = varAccess(dtVar) -- 886
			}, -- 886
			inputs = {ACTION = actionBody} -- 887
		} -- 887
	) end -- 887
	Gen.OnTapEvent = function(nodeVar, event, touchVar, actionBody) return __TS__New( -- 4
		Gen.Blk, -- 4
		"on_tap_event", -- 897
		{ -- 897
			fields = { -- 898
				NODE = varAccess(nodeVar), -- 899
				EVENT = event, -- 900
				TOUCH = varAccess(touchVar) -- 901
			}, -- 901
			inputs = {ACTION = actionBody} -- 903
		} -- 903
	) end -- 903
	Gen.CheckKey = function(key, state) return __TS__New(Gen.Blk, "check_key", {fields = {KEY = key, KEY_STATE = state}}) end -- 4
	local function touchNumAttr(touchId, attr) -- 1017
		return __TS__New( -- 1018
			Gen.Blk, -- 4
			"get_touch_number_attribute", -- 1018
			{fields = { -- 1018
				TOUCH = varAccess(touchId), -- 1019
				ATTRIBUTE = attr -- 1019
			}} -- 1019
		) -- 1019
	end -- 1017
	Gen.TouchGetId = function(touchVar) return touchNumAttr(touchVar, "id") end -- 4
	local function touchVec2Attr(touchId, attr) -- 1024
		return __TS__New( -- 1025
			Gen.Blk, -- 4
			"get_touch_vec2_attribute", -- 1025
			{fields = { -- 1025
				TOUCH = varAccess(touchId), -- 1026
				ATTRIBUTE = attr -- 1026
			}} -- 1026
		) -- 1026
	end -- 1024
	Gen.TouchGetLocation = function(touchVar) return touchVec2Attr(touchVar, "location") end -- 4
	Gen.TouchGetWorldLocation = function(touchVar) return touchVec2Attr(touchVar, "worldLocation") end -- 4
	Gen.toBlocklyJSON = function(root, procs) -- 4
		local vars = __TS__ArrayMap( -- 1033
			__TS__ArrayFrom(collectVariables(root)), -- 1033
			function(____, n) return {name = n, id = n} end -- 1033
		) -- 1033
		for ____, ____value in __TS__Iterator(varMap:entries()) do -- 1034
			local _ = ____value[1] -- 1034
			local v = ____value[2] -- 1034
			vars[#vars + 1] = v -- 1035
		end -- 1035
		if procs then -- 1035
			fixProcParamNames(root, procs) -- 1038
			for ____, proc in ipairs(procs) do -- 1039
				fixProcParamNames(proc, procs) -- 1040
				local procVars = __TS__ArrayMap( -- 1041
					__TS__ArrayFrom(collectVariables(proc)), -- 1041
					function(____, n) return {name = n, id = n} end -- 1041
				) -- 1041
				vars = __TS__ArrayConcat(vars, procVars) -- 1042
			end -- 1042
		end -- 1042
		local finalVars = {} -- 1045
		local tmp = __TS__New(Set) -- 1046
		for ____, v in ipairs(vars) do -- 1047
			if not tmp:has(v.id) then -- 1047
				tmp:add(v.id) -- 1049
				finalVars[#finalVars + 1] = v -- 1050
			end -- 1050
		end -- 1050
		vars = finalVars -- 1053
		varMap = __TS__New(Map) -- 1054
		local ____opt_11 = procs -- 1054
		local procBlocks = ____opt_11 and __TS__ArrayMap( -- 1055
			procs, -- 1055
			function(____, proc, i) -- 1055
				local j = proc:toJSON() -- 1056
				j.x = (i + 1) * 500 -- 1057
				return j -- 1058
			end -- 1055
		) or ({}) -- 1055
		local res, err = safeJsonEncode( -- 1060
			{ -- 1060
				blocks = { -- 1061
					languageVersion = 0, -- 1062
					blocks = { -- 1063
						root:toJSON(), -- 1063
						table.unpack(procBlocks) -- 1063
					} -- 1063
				}, -- 1063
				variables = vars -- 1065
			}, -- 1065
			false, -- 1066
			false, -- 1066
			false, -- 1066
			4096 -- 1066
		) -- 1066
		if err ~= nil then -- 1066
			Log("Error", err) -- 1068
		end -- 1068
		return res or "{}" -- 1070
	end -- 1032
end -- 1032
____exports.default = Gen -- 1262
return ____exports -- 1262