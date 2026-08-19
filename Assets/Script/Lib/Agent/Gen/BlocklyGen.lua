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
	local _ifElseCore, vec2Calc -- 2
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
	Gen.IfElse = function(...) -- 4
		local ifBranchesOrElse = {...} -- 4
		local last = ifBranchesOrElse[#ifBranchesOrElse] -- 109
		local main = ifBranchesOrElse[1] -- 110
		local elseIfs = last.elseBranch and __TS__ArraySlice(ifBranchesOrElse, 1, -1) or __TS__ArraySlice(ifBranchesOrElse, 1) -- 111
		local elseBody = last.elseBranch and last.body or nil -- 112
		return _ifElseCore(main, elseIfs, elseBody) -- 113
	end -- 108
	Gen.If = function(cond, body) return {condition = cond, elseBranch = false, body = body} end -- 4
	Gen.Else = function(body) return {elseBranch = true, body = body} end -- 4
	_ifElseCore = function(main, elseIfs, otherwise) -- 119
		local inputs = {IF0 = main.condition, DO0 = main.body} -- 124
		__TS__ArrayForEach( -- 128
			elseIfs, -- 128
			function(____, br, idx) -- 128
				inputs["IF" .. tostring(idx + 1)] = br.condition -- 129
				inputs["DO" .. tostring(idx + 1)] = br.body -- 130
			end -- 128
		) -- 128
		if otherwise then -- 128
			inputs.ELSE = otherwise -- 132
		end -- 132
		return __TS__New(Gen.Blk, "controls_if", {extraState = {elseIfCount = #elseIfs, hasElse = not not otherwise}, inputs = inputs}) -- 133
	end -- 119
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
		local ____opt_4 = node.fields -- 144
		local v = ____opt_4 and ____opt_4.VAR -- 145
		if node.type == "declare_variable" and (v and v.id) then -- 145
			set:add(v.id) -- 147
		end -- 147
		if node.inputs then -- 147
			for ____, n in pairs(node.inputs) do -- 150
				collectVariables(n, set) -- 151
			end -- 151
		end -- 151
		if node._next then -- 151
			collectVariables(node._next, set) -- 154
		end -- 154
		return set -- 155
	end -- 144
	local fixProcParamNames -- 158
	fixProcParamNames = function(node, funcs) -- 158
		if node.type == "procedures_callnoreturn" or node.type == "procedures_callreturn" then -- 158
			local funcName = node.extraState.name -- 160
			for ____, func in ipairs(funcs) do -- 161
				local ____opt_8 = func.fields -- 161
				local name = ____opt_8 and ____opt_8.NAME -- 162
				if funcName == name then -- 162
					local params = func.extraState.params -- 164
					node.extraState.params = __TS__ArrayMap( -- 165
						params, -- 165
						function(____, param) return param.name end -- 165
					) -- 165
				end -- 165
			end -- 165
		end -- 165
		if node.inputs then -- 165
			for ____, n in pairs(node.inputs) do -- 170
				fixProcParamNames(n, funcs) -- 171
			end -- 171
		end -- 171
		if node._next then -- 171
			fixProcParamNames(node._next, funcs) -- 174
		end -- 174
	end -- 158
	Gen.Num = function(n) return __TS__New(Gen.Blk, "math_number", {fields = {NUM = n}}) end -- 4
	Gen.VarGet = function(name) return __TS__New(Gen.Blk, "variables_get", {fields = {VAR = {id = name, name = name}}}) end -- 4
	Gen.Repeat = function(times, body) return __TS__New(Gen.Blk, "controls_repeat_ext", {inputs = {TIMES = times, DO = body}}) end -- 4
	local function whileUntil(mode) -- 191
		return function(cond, body) return __TS__New(Gen.Blk, "controls_whileUntil", {fields = {MODE = mode}, inputs = {BOOL = cond, DO = body}}) end -- 193
	end -- 191
	Gen.While = whileUntil("WHILE") -- 4
	Gen.Until = whileUntil("UNTIL") -- 4
	Gen.For = function(varName, from, to, by, body) return __TS__New( -- 4
		Gen.Blk, -- 4
		"controls_for", -- 209
		{ -- 209
			fields = {VAR = varAccess(varName)}, -- 210
			inputs = {FROM = from, TO = to, BY = by, DO = body} -- 211
		} -- 211
	) end -- 211
	Gen.ForEach = function(varName, list, body) return __TS__New( -- 4
		Gen.Blk, -- 4
		"controls_forEach", -- 224
		{ -- 224
			fields = {VAR = varAccess(varName)}, -- 225
			inputs = {LIST = list, DO = body} -- 226
		} -- 226
	) end -- 226
	local function flowStmt(kind) -- 229
		return __TS__New(Gen.Blk, "controls_flow_statements", {fields = {FLOW = kind}}) -- 230
	end -- 229
	Gen.Break = function() return flowStmt("BREAK") end -- 4
	Gen.Continue = function() return flowStmt("CONTINUE") end -- 4
	local function constant(c) -- 237
		return __TS__New(Gen.Blk, "math_constant", {fields = {CONSTANT = c}}) -- 240
	end -- 237
	Gen.PI = constant("PI") -- 4
	Gen.E = constant("E") -- 4
	Gen.GOLDEN_RATIO = constant("GOLDEN_RATIO") -- 4
	Gen.SQRT2 = constant("SQRT2") -- 4
	Gen.SQRT1_2 = constant("SQRT1_2") -- 4
	Gen.INFINITY = constant("INFINITY") -- 4
	local function arithmetic(op, A, B) -- 249
		return __TS__New(Gen.Blk, "math_arithmetic", {fields = {OP = op}, inputs = {A = A, B = B}}) -- 253
	end -- 249
	Gen.Add = function(a, b) return arithmetic("ADD", a, b) end -- 4
	Gen.Sub = function(a, b) return arithmetic("MINUS", a, b) end -- 4
	Gen.Mul = function(a, b) return arithmetic("MULTIPLY", a, b) end -- 4
	Gen.Div = function(a, b) return arithmetic("DIVIDE", a, b) end -- 4
	Gen.Pow = function(a, b) return arithmetic("POWER", a, b) end -- 4
	local function mathSingle(op, n) -- 261
		return __TS__New(Gen.Blk, "math_single", {fields = {OP = op}, inputs = {NUM = n}}) -- 266
	end -- 261
	Gen.Root = function(n) return mathSingle("ROOT", n) end -- 4
	Gen.Abs = function(n) return mathSingle("ABS", n) end -- 4
	Gen.Neg = function(n) return mathSingle("NEG", n) end -- 4
	Gen.Ln = function(n) return mathSingle("LN", n) end -- 4
	Gen.Log10 = function(n) return mathSingle("LOG10", n) end -- 4
	Gen.Exp = function(n) return mathSingle("EXP", n) end -- 4
	Gen.Pow10 = function(n) return mathSingle("POW10", n) end -- 4
	local function trig(op, n) -- 276
		return __TS__New(Gen.Blk, "math_trig", {fields = {OP = op}, inputs = {NUM = n}}) -- 279
	end -- 276
	Gen.Sin = function(deg) return trig("SIN", deg) end -- 4
	Gen.Cos = function(deg) return trig("COS", deg) end -- 4
	Gen.Tan = function(deg) return trig("TAN", deg) end -- 4
	Gen.Asin = function(deg) return trig("ASIN", deg) end -- 4
	Gen.Acos = function(deg) return trig("ACOS", deg) end -- 4
	Gen.Atan = function(deg) return trig("ATAN", deg) end -- 4
	local function numProp(property, n) -- 288
		return __TS__New(Gen.Blk, "math_number_property", {fields = {PROPERTY = property}, extraState = "<mutation divisor_input=\"false\"></mutation>", inputs = {NUMBER_TO_CHECK = n}}) -- 294
	end -- 288
	Gen.IsEven = function(n) return numProp("EVEN", n) end -- 4
	Gen.IsOdd = function(n) return numProp("ODD", n) end -- 4
	Gen.IsPrime = function(n) return numProp("PRIME", n) end -- 4
	Gen.IsWhole = function(n) return numProp("WHOLE", n) end -- 4
	Gen.IsPositive = function(n) return numProp("POSITIVE", n) end -- 4
	Gen.IsNegtive = function(n) return numProp("NEGATIVE", n) end -- 4
	Gen.IsDivisibleBy = function(n, divisor) return __TS__New(Gen.Blk, "math_number_property", {fields = {PROPERTY = "DIVISIBLE_BY"}, extraState = "<mutation divisor_input=\"true\"></mutation>", inputs = {NUMBER_TO_CHECK = n, DIVISOR = divisor}}) end -- 4
	local function round(op, n) -- 312
		return __TS__New(Gen.Blk, "math_round", {fields = {OP = op}, inputs = {NUM = n}}) -- 315
	end -- 312
	Gen.Round = function(n) return round("ROUND", n) end -- 4
	Gen.RoundUp = function(n) return round("ROUNDUP", n) end -- 4
	Gen.RoundDown = function(n) return round("ROUNDDOWN", n) end -- 4
	Gen.Modulo = function(dividend, divisor) return __TS__New(Gen.Blk, "math_modulo", {inputs = {DIVIDEND = dividend, DIVISOR = divisor}}) end -- 4
	local function mathOnList(op, listBlock) -- 324
		return __TS__New(Gen.Blk, "math_on_list", {fields = {OP = op}, extraState = ("<mutation op=\"" .. op) .. "\"></mutation>", inputs = {LIST = listBlock}}) -- 330
	end -- 324
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
		local inputMap = {} -- 357
		__TS__ArrayForEach( -- 358
			texts, -- 358
			function(____, b, i) -- 358
				inputMap["ADD" .. tostring(i)] = b -- 359
			end -- 358
		) -- 358
		return __TS__New(Gen.Blk, "text_join", {extraState = {itemCount = #texts}, inputs = inputMap}) -- 361
	end -- 356
	Gen.TextAppend = function(varName, what) return __TS__New( -- 4
		Gen.Blk, -- 4
		"text_append", -- 368
		{ -- 368
			fields = {VAR = varAccess(varName)}, -- 369
			inputs = {TEXT = what} -- 370
		} -- 370
	) end -- 370
	Gen.TextLength = function(text) return __TS__New(Gen.Blk, "text_length", {inputs = {VALUE = text}}) end -- 4
	Gen.IsTextEmpty = function(text) return __TS__New(Gen.Blk, "text_isEmpty", {inputs = {VALUE = text}}) end -- 4
	Gen.TextReverse = function(text) return __TS__New(Gen.Blk, "text_reverse", {inputs = {TEXT = text}}) end -- 4
	local function textIndexOf(____end, textBlk, findBlk) -- 383
		return __TS__New(Gen.Blk, "text_indexOf", {fields = {END = ____end}, inputs = {VALUE = textBlk, FIND = findBlk}}) -- 388
	end -- 383
	Gen.TextFirstIndexOf = function(text, firstFind) return textIndexOf("FIRST", text, firstFind) end -- 4
	Gen.TextLastIndexOf = function(text, lastFind) return textIndexOf("LAST", text, lastFind) end -- 4
	local function charAt(where, textBlk, at) -- 397
		return __TS__New( -- 402
			Gen.Blk, -- 4
			"text_charAt", -- 402
			{ -- 402
				extraState = ("<mutation at=\"" .. tostring(where == "FROM_START" or where == "FROM_END")) .. "\"></mutation>", -- 403
				fields = {WHERE = where}, -- 404
				inputs = __TS__ObjectAssign({VALUE = textBlk}, at and ({AT = at}) or ({})) -- 405
			} -- 405
		) -- 405
	end -- 397
	Gen.CharFromStart = function(text, at) return charAt("FROM_START", text, at) end -- 4
	Gen.CharFromEnd = function(text, at) return charAt("FROM_END", text, at) end -- 4
	Gen.FirstChar = function(text) return charAt("FIRST", text) end -- 4
	Gen.LastChar = function(text) return charAt("LAST", text) end -- 4
	Gen.RandomChar = function(text) return charAt("RANDOM", text) end -- 4
	local function substring(where1, where2, textBlk, at1, at2) -- 419
		return __TS__New( -- 424
			Gen.Blk, -- 4
			"text_getSubstring", -- 424
			{ -- 424
				extraState = ((("<mutation at1=\"" .. tostring(where1 == "FROM_START" or where1 == "FROM_END")) .. "\" at2=\"") .. tostring(where2 == "FROM_START" or where2 == "FROM_END")) .. "\"></mutation>", -- 425
				fields = {WHERE1 = where1, WHERE2 = where2}, -- 426
				inputs = __TS__ObjectAssign({STRING = textBlk}, at1 and ({AT1 = at1}) or ({}), at2 and ({AT2 = at2}) or ({})) -- 427
			} -- 427
		) -- 427
	end -- 419
	Gen.Substring = function(at1, at2) return substring("FROM_START", at2 and "FROM_START" or "LAST", at1, at2) end -- 4
	local function changeCase(mode, str) -- 437
		return __TS__New(Gen.Blk, "text_changeCase", {fields = {CASE = mode}, inputs = {TEXT = str}}) -- 438
	end -- 437
	Gen.UpperCase = function(text) return changeCase("UPPERCASE", text) end -- 4
	Gen.LowerCase = function(text) return changeCase("LOWERCASE", text) end -- 4
	Gen.TitleCase = function(text) return changeCase("TITLECASE", text) end -- 4
	local function trim(mode, str) -- 448
		return __TS__New(Gen.Blk, "text_trim", {fields = {MODE = mode}, inputs = {TEXT = str}}) -- 449
	end -- 448
	Gen.TrimLeft = function(text) return trim("LEFT", text) end -- 4
	Gen.TrimRight = function(text) return trim("RIGHT", text) end -- 4
	Gen.Trim = function(text) return trim("BOTH", text) end -- 4
	Gen.TextCount = function(subText, text) return __TS__New(Gen.Blk, "text_count", {inputs = {SUB = subText, TEXT = text}}) end -- 4
	Gen.TextReplace = function(text, fromText, toText) return __TS__New(Gen.Blk, "text_replace", {inputs = {TEXT = text, FROM = fromText, TO = toText}}) end -- 4
	Gen.RepeatList = function(item, times) return __TS__New(Gen.Blk, "lists_repeat", {inputs = {ITEM = item, NUM = times}}) end -- 4
	Gen.ListLength = function(list) return __TS__New(Gen.Blk, "lists_length", {inputs = {VALUE = list}}) end -- 4
	Gen.IsListEmpty = function(list) return __TS__New(Gen.Blk, "lists_isEmpty", {inputs = {VALUE = list}}) end -- 4
	local function indexOf(list, findItem, which) -- 481
		return __TS__New(Gen.Blk, "lists_indexOf", {fields = {END = which}, inputs = {VALUE = list, FIND = findItem}}) -- 486
	end -- 481
	Gen.FirstIndexOf = function(list, findItem) return indexOf(list, findItem, "FIRST") end -- 4
	Gen.LastIndexOf = function(list, findItem) return indexOf(list, findItem, "FIRST") end -- 4
	local function listGetIndex(mode, where, listExpr, at) -- 502
		return __TS__New( -- 508
			Gen.Blk, -- 4
			"lists_getIndex", -- 508
			{ -- 508
				fields = {MODE = mode, WHERE = where}, -- 509
				inputs = __TS__ObjectAssign({VALUE = listExpr}, at and ({AT = at}) or ({})), -- 510
				extraState = {isStatement = mode == "REMOVE"} -- 514
			} -- 514
		) -- 514
	end -- 502
	Gen.ListGet = function(list, at) return listGetIndex("GET", "FROM_START", list, at) end -- 4
	Gen.ListRemoveGet = function(list, at) return listGetIndex("GET_REMOVE", "FROM_START", list, at) end -- 4
	Gen.ListRemove = function(list, at) return listGetIndex("REMOVE", "FROM_START", list, at) end -- 4
	Gen.ListRemoveLast = function(list) return listGetIndex("GET_REMOVE", "LAST", list) end -- 4
	Gen.ListRemoveFirst = function(list) return listGetIndex("GET_REMOVE", "FIRST", list) end -- 4
	local function subList(listExpr, where1, where2, at1, at2) -- 523
		return __TS__New(Gen.Blk, "lists_getSublist", {fields = {WHERE1 = where1, WHERE2 = where2}, inputs = at2 and ({LIST = listExpr, AT1 = at1, AT2 = at2}) or ({LIST = listExpr, AT1 = at1})}) -- 530
	end -- 523
	Gen.SubList = function(list, at1, at2) return subList( -- 4
		list, -- 536
		"FROM_START", -- 536
		at2 and "FROM_START" or "LAST", -- 536
		at1, -- 536
		at2 -- 536
	) end -- 536
	local function listSplit(input, delim, mode) -- 538
		return __TS__New(Gen.Blk, "lists_split", {fields = {MODE = mode}, inputs = {INPUT = input, DELIM = delim}}) -- 543
	end -- 538
	Gen.ListSplit = function(inputText, delimText) return listSplit(inputText, delimText, "SPLIT") end -- 4
	Gen.ListStringConcat = function(list, delimText) return listSplit(list, delimText, "JOIN") end -- 4
	local function listSort(listExpr, ____type, direction) -- 551
		return __TS__New(Gen.Blk, "lists_sort", {fields = {TYPE = ____type, DIRECTION = direction}, inputs = {LIST = listExpr}}) -- 556
	end -- 551
	Gen.ListSort = function(list, desc) return listSort(list, "NUMERIC", desc and "-1" or "1") end -- 4
	Gen.ListReverse = function(list) return __TS__New(Gen.Blk, "lists_reverse", {inputs = {LIST = list}}) end -- 4
	local function listSetIndex(mode, listExpr, at, to, where) -- 566
		return __TS__New(Gen.Blk, "lists_setIndex", {fields = {MODE = mode, WHERE = where}, inputs = {LIST = listExpr, AT = at, TO = to}}) -- 573
	end -- 566
	Gen.ListSet = function(list, at, item) return listSetIndex( -- 4
		"SET", -- 578
		list, -- 578
		at, -- 578
		item, -- 578
		"FROM_START" -- 578
	) end -- 578
	Gen.ListInsert = function(list, at, item) return listSetIndex( -- 4
		"INSERT", -- 579
		list, -- 579
		at, -- 579
		item, -- 579
		"FROM_START" -- 579
	) end -- 579
	Gen.Dict = function() return __TS__New(Gen.Blk, "dict_create") end -- 4
	Gen.DictGet = function(dict, key) return __TS__New(Gen.Blk, "dict_get", {inputs = {DICT = dict, KEY = key}}) end -- 4
	Gen.DictSet = function(dict, key, val) return __TS__New(Gen.Blk, "dict_set", {inputs = {DICT = dict, KEY = key, VALUE = val}}) end -- 4
	Gen.DictContain = function(dict, key) return __TS__New(Gen.Blk, "dict_has_key", {inputs = {DICT = dict, KEY = key}}) end -- 4
	Gen.DictRemove = function(dict, key) return __TS__New(Gen.Blk, "dict_remove_key", {inputs = {DICT = dict, KEY = key}}) end -- 4
	Gen.VarSet = function(name, value) return __TS__New( -- 4
		Gen.Blk, -- 4
		"variables_set", -- 596
		{ -- 596
			fields = {VAR = varAccess(name)}, -- 597
			inputs = {VALUE = value} -- 598
		} -- 598
	) end -- 598
	Gen.VarAdd = function(name, deltaNum) return __TS__New( -- 4
		Gen.Blk, -- 4
		"math_change", -- 602
		{ -- 602
			fields = {VAR = varAccess(name)}, -- 603
			inputs = {DELTA = deltaNum} -- 604
		} -- 604
	) end -- 604
	Gen.ProcReturn = function(value) return __TS__New(Gen.Blk, "return_block", {inputs = value and ({VALUE = value}) or ({})}) end -- 4
	Gen.ProcIfReturn = function(cond, value) return __TS__New( -- 4
		Gen.Blk, -- 4
		"procedures_ifreturn", -- 614
		{ -- 614
			extraState = ("<mutation value=\"" .. tostring(value and 1 or 0)) .. "\"></mutation>", -- 615
			inputs = value and ({CONDITION = cond, VALUE = value}) or ({CONDITION = cond}) -- 616
		} -- 616
	) end -- 616
	local function buildParams(names) -- 621
		return __TS__ArrayMap( -- 622
			names, -- 622
			function(____, p) return { -- 622
				name = p, -- 622
				id = IdFactory:next("arg") -- 622
			} end -- 622
		) -- 622
	end -- 621
	Gen.DefProcReturn = function(name, params, body, returnExpr) return __TS__New( -- 4
		Gen.Blk, -- 4
		"procedures_defreturn", -- 630
		{ -- 630
			fields = {NAME = name}, -- 631
			inputs = {STACK = body, RETURN = returnExpr}, -- 632
			extraState = {params = buildParams(params)} -- 633
		} -- 633
	) end -- 633
	Gen.DefProc = function(name, params, body) return __TS__New( -- 4
		Gen.Blk, -- 4
		"procedures_defnoreturn", -- 641
		{ -- 641
			fields = {NAME = name}, -- 642
			inputs = {STACK = body}, -- 643
			extraState = {params = buildParams(params)} -- 644
		} -- 644
	) end -- 644
	Gen.CallProc = function(procName, ...) -- 4
		local args = {...} -- 4
		local inputMap = {} -- 648
		__TS__ArrayForEach( -- 649
			args, -- 649
			function(____, value, i) -- 649
				inputMap["ARG" .. tostring(i)] = value -- 650
			end -- 649
		) -- 649
		return __TS__New(Gen.Blk, "procedures_callnoreturn", {extraState = {name = procName, params = nil}, inputs = inputMap}) -- 652
	end -- 647
	Gen.CallProcReturn = function(procName, ...) -- 4
		local args = {...} -- 4
		local inputMap = {} -- 659
		__TS__ArrayForEach( -- 660
			args, -- 660
			function(____, value, i) -- 660
				inputMap["ARG" .. tostring(i)] = value -- 661
			end -- 660
		) -- 660
		return __TS__New(Gen.Blk, "procedures_callreturn", {extraState = {name = procName, params = nil}, inputs = inputMap}) -- 663
	end -- 658
	Gen.Vec2Zero = function() return __TS__New(Gen.Blk, "vec2_zero") end -- 4
	Gen.Vec2 = function(x, y) return __TS__New(Gen.Blk, "vec2_create", {inputs = {X = x, Y = y}}) end -- 4
	local function vec2Prop(vecVar, prop) -- 675
		return __TS__New( -- 676
			Gen.Blk, -- 4
			"vec2_get_property", -- 676
			{fields = { -- 676
				VEC2 = varAccess(vecVar), -- 677
				PROPERTY = prop -- 677
			}} -- 677
		) -- 677
	end -- 675
	Gen.Vec2X = function(varName) return vec2Prop(varName, "x") end -- 4
	Gen.Vec2Y = function(varName) return vec2Prop(varName, "y") end -- 4
	Gen.Vec2Length = function(varName) return vec2Prop(varName, "length") end -- 4
	Gen.Vec2Angle = function(varName) return vec2Prop(varName, "angle") end -- 4
	Gen.Vec2Normalize = function(v) return __TS__New(Gen.Blk, "vec2_get_normalized", {inputs = {VEC2 = v}}) end -- 4
	local function vec2VecOp(op, a, b) -- 688
		return __TS__New(Gen.Blk, "vec2_binary_operation", {fields = {OPERATION = op}, inputs = {VEC2_1 = a, VEC2_2 = b}}) -- 689
	end -- 688
	Gen.Vec2Add = function(a, b) return vec2VecOp("+", a, b) end -- 4
	Gen.Vec2Sub = function(a, b) return vec2VecOp("-", a, b) end -- 4
	Gen.Vec2MulVec = function(a, b) return vec2VecOp("*", a, b) end -- 4
	Gen.Vec2DivVec = function(a, b) return vec2VecOp("/", a, b) end -- 4
	Gen.Vec2Distance = function(a, b) return vec2Calc("distance", a, b) end -- 4
	Gen.Vec2Dot = function(a, b) return vec2Calc("dot", a, b) end -- 4
	local function vec2NumOp(op, v, n) -- 701
		return __TS__New(Gen.Blk, "vec2_binary_op_number", {fields = {OPERATION = op}, inputs = {VEC2 = v, NUMBER = n}}) -- 702
	end -- 701
	Gen.Vec2MulNum = function(v, n) return vec2NumOp("*", v, n) end -- 4
	Gen.Vec2DivNum = function(v, n) return vec2NumOp("/", v, n) end -- 4
	Gen.Vec2Clamp = function(v, min, max) return __TS__New(Gen.Blk, "vec2_clamp", {inputs = {VEC2 = v, MIN = min, MAX = max}}) end -- 4
	vec2Calc = function(what, a, b) return __TS__New(Gen.Blk, "vec2_calculate", {fields = {CALCULATE = what}, inputs = {VEC2_1 = a, VEC2_2 = b}}) end -- 719
	Gen.CreateNode = function() return __TS__New(Gen.Blk, "node_create") end -- 4
	Gen.CreateSprite = function(file) return __TS__New(Gen.Blk, "sprite_create", {inputs = {FILE = file}}) end -- 4
	Gen.CreateLabel = function(fontName, size) return __TS__New(Gen.Blk, "label_create", {inputs = {FONT = fontName, SIZE = size}}) end -- 4
	Gen.LabelSetText = function(varName, text) return __TS__New( -- 4
		Gen.Blk, -- 4
		"label_set_text", -- 738
		{ -- 738
			fields = {LABEL = varAccess(varName)}, -- 739
			inputs = {TEXT = text} -- 740
		} -- 740
	) end -- 740
	Gen.NodeAddChild = function(parentVar, childVar, order) return __TS__New( -- 4
		Gen.Blk, -- 4
		"node_add_child", -- 744
		{ -- 744
			fields = { -- 745
				PARENT = varAccess(parentVar), -- 745
				CHILD = varAccess(childVar) -- 745
			}, -- 745
			inputs = {ORDER = order} -- 746
		} -- 746
	) end -- 746
	local function nodeSetNumAttr(varName, attr, value) -- 750
		return __TS__New( -- 751
			Gen.Blk, -- 4
			"node_set_number_attribute", -- 751
			{ -- 751
				fields = { -- 752
					NODE = varAccess(varName), -- 752
					ATTRIBUTE = attr -- 752
				}, -- 752
				inputs = {VALUE = value} -- 753
			} -- 753
		) -- 753
	end -- 750
	Gen.NodeSetX = function(varName, n) return nodeSetNumAttr(varName, "x", n) end -- 4
	Gen.NodeSetY = function(varName, n) return nodeSetNumAttr(varName, "y", n) end -- 4
	Gen.NodeSetWidth = function(varName, n) return nodeSetNumAttr(varName, "width", n) end -- 4
	Gen.NodeSetHeight = function(varName, n) return nodeSetNumAttr(varName, "height", n) end -- 4
	Gen.NodeSetAngle = function(varName, n) return nodeSetNumAttr(varName, "angle", n) end -- 4
	Gen.NodeSetScale = function(varName, n) return nodeSetNumAttr(varName, "scale", n) end -- 4
	Gen.NodeSetScaleX = function(varName, n) return nodeSetNumAttr(varName, "scaleX", n) end -- 4
	Gen.NodeSetScaleY = function(varName, n) return nodeSetNumAttr(varName, "scaleY", n) end -- 4
	Gen.NodeSetOpactity = function(varName, n) return nodeSetNumAttr(varName, "opacity", n) end -- 4
	local function nodeGetNumAttr(varName, attr) -- 765
		return __TS__New( -- 766
			Gen.Blk, -- 4
			"node_get_number_attribute", -- 766
			{fields = { -- 766
				NODE = varAccess(varName), -- 767
				ATTRIBUTE = attr -- 767
			}} -- 767
		) -- 767
	end -- 765
	Gen.NodeGetX = function(varName) return nodeGetNumAttr(varName, "x") end -- 4
	Gen.NodeGetY = function(varName) return nodeGetNumAttr(varName, "y") end -- 4
	Gen.NodeGetWidth = function(varName) return nodeGetNumAttr(varName, "width") end -- 4
	Gen.NodeGetHeight = function(varName) return nodeGetNumAttr(varName, "height") end -- 4
	Gen.NodeGetAngle = function(varName) return nodeGetNumAttr(varName, "angle") end -- 4
	Gen.NodeGetScale = function(varName) return nodeGetNumAttr(varName, "scale") end -- 4
	Gen.NodeGetScaleX = function(varName) return nodeGetNumAttr(varName, "scaleX") end -- 4
	Gen.NodeGetScaleY = function(varName) return nodeGetNumAttr(varName, "scaleY") end -- 4
	Gen.NodeGetOpactity = function(varName) return nodeGetNumAttr(varName, "opacity") end -- 4
	local function nodeSetBoolAttr(nodeVar, attr, value) -- 781
		return __TS__New( -- 782
			Gen.Blk, -- 4
			"node_set_boolean_attribute", -- 782
			{ -- 782
				fields = { -- 783
					NODE = varAccess(nodeVar), -- 783
					ATTRIBUTE = attr -- 783
				}, -- 783
				inputs = {VALUE = value} -- 784
			} -- 784
		) -- 784
	end -- 781
	Gen.NodeSetVisible = function(varName, bool) return nodeSetBoolAttr(varName, "visible", bool) end -- 4
	local function nodeGetBoolAttr(varName, attr) -- 789
		return __TS__New( -- 790
			Gen.Blk, -- 4
			"node_get_boolean_attribute", -- 790
			{fields = { -- 790
				NODE = varAccess(varName), -- 791
				ATTRIBUTE = attr -- 791
			}} -- 791
		) -- 791
	end -- 789
	Gen.NodeGetVisible = function(varName) return nodeGetBoolAttr(varName, "visible") end -- 4
	local function nodeSetVec2Attr(varName, attr, vec) -- 797
		return __TS__New( -- 798
			Gen.Blk, -- 4
			"node_set_vec2_attribute", -- 798
			{ -- 798
				fields = { -- 799
					NODE = varAccess(varName), -- 799
					ATTRIBUTE = attr -- 799
				}, -- 799
				inputs = {VEC2 = vec} -- 800
			} -- 800
		) -- 800
	end -- 797
	Gen.NodeSetPosition = function(varName, vec) return nodeSetVec2Attr(varName, "position", vec) end -- 4
	Gen.NodeSetAnchor = function(varName, vec) return nodeSetVec2Attr(varName, "anchor", vec) end -- 4
	local function nodeGetVec2Attr(nodeVar, attr) -- 806
		return __TS__New( -- 807
			Gen.Blk, -- 4
			"node_get_vec2_attribute", -- 807
			{fields = { -- 807
				NODE = varAccess(nodeVar), -- 808
				ATTRIBUTE = attr -- 808
			}} -- 808
		) -- 808
	end -- 806
	Gen.NodeGetPosition = function(varName) return nodeGetVec2Attr(varName, "position") end -- 4
	Gen.NodeGetAnchor = function(varName) return nodeGetVec2Attr(varName, "anchor") end -- 4
	Gen.BeginPaint = function(nodeVar, paintBody) return __TS__New( -- 4
		Gen.Blk, -- 4
		"nvg_begin_painting", -- 815
		{ -- 815
			fields = {NODE = varAccess(nodeVar)}, -- 816
			inputs = {PAINT = paintBody} -- 817
		} -- 817
	) end -- 817
	Gen.BeginPath = function() return __TS__New(Gen.Blk, "nvg_begin_path") end -- 4
	Gen.MoveTo = function(x, y) return __TS__New(Gen.Blk, "nvg_move_to", {inputs = {X = x, Y = y}}) end -- 4
	Gen.BezierTo = function(c1x, c1y, c2x, c2y, x, y) return __TS__New(Gen.Blk, "nvg_bezier_to", {inputs = { -- 4
		C1X = c1x, -- 831
		C1Y = c1y, -- 831
		C2X = c2x, -- 831
		C2Y = c2y, -- 831
		X = x, -- 831
		Y = y -- 831
	}}) end -- 831
	Gen.LineTo = function(x, y) return __TS__New(Gen.Blk, "nvg_line_to", {inputs = {X = x, Y = y}}) end -- 4
	Gen.ClosePath = function() return __TS__New(Gen.Blk, "nvg_close_path") end -- 4
	Gen.FillColor = function(color, opacity) return __TS__New(Gen.Blk, "nvg_fill_color", {inputs = {COLOR = color, OPACITY = opacity}}) end -- 4
	Gen.Fill = function() return __TS__New(Gen.Blk, "nvg_fill") end -- 4
	Gen.StrokeColor = function(color, opacity) return __TS__New(Gen.Blk, "nvg_stroke_color", {inputs = {COLOR = color, OPACITY = opacity}}) end -- 4
	Gen.StrokeWidth = function(w) return __TS__New(Gen.Blk, "nvg_stroke_width", {inputs = {WIDTH = w}}) end -- 4
	Gen.Stroke = function() return __TS__New(Gen.Blk, "nvg_stroke") end -- 4
	Gen.Rect = function(x, y, w, h) return __TS__New(Gen.Blk, "nvg_rect", {inputs = {X = x, Y = y, WIDTH = w, HEIGHT = h}}) end -- 4
	Gen.RoundedRect = function(x, y, w, h, r) return __TS__New(Gen.Blk, "nvg_rounded_rect", {inputs = { -- 4
		X = x, -- 863
		Y = y, -- 863
		WIDTH = w, -- 863
		HEIGHT = h, -- 863
		RADIUS = r -- 863
	}}) end -- 863
	Gen.Ellipse = function(cx, cy, rx, ry) return __TS__New(Gen.Blk, "nvg_ellipse", {inputs = {CX = cx, CY = cy, RX = rx, RY = ry}}) end -- 4
	Gen.Circle = function(cx, cy, radius) return __TS__New(Gen.Blk, "nvg_circle", {inputs = {CX = cx, CY = cy, RADIUS = radius}}) end -- 4
	Gen.Color = function(hex) return __TS__New(Gen.Blk, "colour_hsv_sliders", {fields = {COLOUR = hex}}) end -- 4
	Gen.OnUpdate = function(nodeVar, dtVar, actionBody) return __TS__New( -- 4
		Gen.Blk, -- 4
		"on_update", -- 886
		{ -- 886
			fields = { -- 887
				NODE = varAccess(nodeVar), -- 887
				DELTA_TIME = varAccess(dtVar) -- 887
			}, -- 887
			inputs = {ACTION = actionBody} -- 888
		} -- 888
	) end -- 888
	Gen.OnTapEvent = function(nodeVar, event, touchVar, actionBody) return __TS__New( -- 4
		Gen.Blk, -- 4
		"on_tap_event", -- 898
		{ -- 898
			fields = { -- 899
				NODE = varAccess(nodeVar), -- 900
				EVENT = event, -- 901
				TOUCH = varAccess(touchVar) -- 902
			}, -- 902
			inputs = {ACTION = actionBody} -- 904
		} -- 904
	) end -- 904
	Gen.CheckKey = function(key, state) return __TS__New(Gen.Blk, "check_key", {fields = {KEY = key, KEY_STATE = state}}) end -- 4
	local function touchNumAttr(touchId, attr) -- 1018
		return __TS__New( -- 1019
			Gen.Blk, -- 4
			"get_touch_number_attribute", -- 1019
			{fields = { -- 1019
				TOUCH = varAccess(touchId), -- 1020
				ATTRIBUTE = attr -- 1020
			}} -- 1020
		) -- 1020
	end -- 1018
	Gen.TouchGetId = function(touchVar) return touchNumAttr(touchVar, "id") end -- 4
	local function touchVec2Attr(touchId, attr) -- 1025
		return __TS__New( -- 1026
			Gen.Blk, -- 4
			"get_touch_vec2_attribute", -- 1026
			{fields = { -- 1026
				TOUCH = varAccess(touchId), -- 1027
				ATTRIBUTE = attr -- 1027
			}} -- 1027
		) -- 1027
	end -- 1025
	Gen.TouchGetLocation = function(touchVar) return touchVec2Attr(touchVar, "location") end -- 4
	Gen.TouchGetWorldLocation = function(touchVar) return touchVec2Attr(touchVar, "worldLocation") end -- 4
	Gen.toBlocklyJSON = function(root, procs) -- 4
		local vars = __TS__ArrayMap( -- 1034
			__TS__ArrayFrom(collectVariables(root)), -- 1034
			function(____, n) return {name = n, id = n} end -- 1034
		) -- 1034
		for ____, ____value in __TS__Iterator(varMap:entries()) do -- 1035
			local _ = ____value[1] -- 1035
			local v = ____value[2] -- 1035
			vars[#vars + 1] = v -- 1036
		end -- 1036
		if procs then -- 1036
			fixProcParamNames(root, procs) -- 1039
			for ____, proc in ipairs(procs) do -- 1040
				fixProcParamNames(proc, procs) -- 1041
				local procVars = __TS__ArrayMap( -- 1042
					__TS__ArrayFrom(collectVariables(proc)), -- 1042
					function(____, n) return {name = n, id = n} end -- 1042
				) -- 1042
				vars = __TS__ArrayConcat(vars, procVars) -- 1043
			end -- 1043
		end -- 1043
		local finalVars = {} -- 1046
		local tmp = __TS__New(Set) -- 1047
		for ____, v in ipairs(vars) do -- 1048
			if not tmp:has(v.id) then -- 1048
				tmp:add(v.id) -- 1050
				finalVars[#finalVars + 1] = v -- 1051
			end -- 1051
		end -- 1051
		vars = finalVars -- 1054
		varMap = __TS__New(Map) -- 1055
		local ____opt_10 = procs -- 1055
		local procBlocks = ____opt_10 and __TS__ArrayMap( -- 1056
			procs, -- 1056
			function(____, proc, i) -- 1056
				local j = proc:toJSON() -- 1057
				j.x = (i + 1) * 500 -- 1058
				return j -- 1059
			end -- 1056
		) or ({}) -- 1056
		local res, err = safeJsonEncode( -- 1061
			{ -- 1061
				blocks = { -- 1062
					languageVersion = 0, -- 1063
					blocks = { -- 1064
						root:toJSON(), -- 1064
						table.unpack(procBlocks) -- 1064
					} -- 1064
				}, -- 1064
				variables = vars -- 1066
			}, -- 1066
			false, -- 1067
			false, -- 1067
			false, -- 1067
			4096 -- 1067
		) -- 1067
		if err ~= nil then -- 1067
			Log("Error", err) -- 1069
		end -- 1069
		return res or "{}" -- 1071
	end -- 1033
end -- 1033
____exports.default = Gen -- 1263
return ____exports -- 1263