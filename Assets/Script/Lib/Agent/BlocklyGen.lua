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
local json = ____Dora.json -- 1
local Gen = {} -- 1
do -- 1
	local vec2Calc -- 1
	local IdFactory = __TS__Class() -- 5
	IdFactory.name = "IdFactory" -- 5
	function IdFactory.prototype.____constructor(self) -- 5
	end -- 5
	function IdFactory.next(self, prefix) -- 7
		if prefix == nil then -- 7
			prefix = "block" -- 7
		end -- 7
		local ____prefix_3 = prefix -- 8
		local ____IdFactory_0, ____seq_1 = IdFactory, "seq" -- 8
		local ____IdFactory_seq_2 = ____IdFactory_0[____seq_1] + 1 -- 8
		____IdFactory_0[____seq_1] = ____IdFactory_seq_2 -- 8
		return (____prefix_3 .. "-") .. tostring(____IdFactory_seq_2) -- 8
	end -- 7
	IdFactory.seq = 0 -- 7
	Gen.Blk = __TS__Class() -- 3
	local Blk = Gen.Blk -- 3
	Blk.name = "Blk" -- 15
	function Blk.prototype.____constructor(self, ____type, opts) -- 23
		if opts == nil then -- 23
			opts = {} -- 25
		end -- 25
		self.id = IdFactory:next() -- 27
		self.type = ____type -- 28
		self.fields = opts.fields -- 29
		self.inputs = opts.inputs -- 30
		self.extraState = opts.extraState -- 31
	end -- 23
	function Blk.prototype.next(self, node) -- 34
		self._next = node -- 35
		return node -- 36
	end -- 34
	function Blk.prototype.toJSON(self) -- 39
		local j = {type = self.type, id = self.id} -- 40
		if self.fields then -- 40
			j.fields = self.fields -- 41
		end -- 41
		if self.inputs then -- 41
			j.inputs = {} -- 43
			for k, v in pairs(self.inputs) do -- 44
				j.inputs[k] = {block = v:toJSON()} -- 45
			end -- 45
		end -- 45
		if self.extraState then -- 45
			j.extraState = self.extraState -- 47
		end -- 47
		if self._next then -- 47
			j.next = {block = self._next:toJSON()} -- 48
		end -- 48
		return j -- 49
	end -- 39
	Gen.Bool = function(v) return __TS__New(Gen.Blk, "logic_boolean", {fields = {BOOL = v and "TRUE" or "FALSE"}}) end -- 3
	Gen.Text = function(s) -- 3
		if s == nil then -- 3
			s = "" -- 54
		end -- 54
		return __TS__New(Gen.Blk, "text", {fields = {TEXT = s}}) -- 54
	end -- 54
	Gen.Print = function(item) return __TS__New(Gen.Blk, "print_block", {inputs = {ITEM = item}}) end -- 3
	local function compare(op, a, b) -- 57
		return __TS__New(Gen.Blk, "logic_compare", {fields = {OP = op}, inputs = {A = a, B = b}}) -- 58
	end -- 57
	Gen.Eq = function(a, b) return compare("EQ", a, b) end -- 3
	Gen.Neq = function(a, b) return compare("NEQ", a, b) end -- 3
	Gen.Lt = function(a, b) return compare("LT", a, b) end -- 3
	Gen.Gt = function(a, b) return compare("GT", a, b) end -- 3
	Gen.Gte = function(a, b) return compare("GTE", a, b) end -- 3
	Gen.Lte = function(a, b) return compare("LTE", a, b) end -- 3
	local function logicOp(op, a, b) -- 67
		return __TS__New(Gen.Blk, "logic_operation", {fields = {OP = op}, inputs = {A = a, B = b}}) -- 68
	end -- 67
	Gen.And = function(a, b) return logicOp("AND", a, b) end -- 3
	Gen.Or = function(a, b) return logicOp("OR", a, b) end -- 3
	Gen.Not = function(b) return __TS__New(Gen.Blk, "logic_negate", {inputs = {BOOL = b}}) end -- 3
	Gen.Ternary = function(cond, thenValue, elseValue) return __TS__New(Gen.Blk, "logic_ternary", {inputs = {IF = cond, THEN = thenValue, ELSE = elseValue}}) end -- 3
	Gen.List = function(...) -- 3
		local items = {...} -- 3
		local inputMap = {} -- 84
		__TS__ArrayForEach( -- 85
			items, -- 85
			function(____, b, i) -- 85
				inputMap["ADD" .. tostring(i)] = b -- 86
			end -- 85
		) -- 85
		return __TS__New(Gen.Blk, "lists_create_with", {extraState = {itemCount = #items}, inputs = inputMap}) -- 88
	end -- 83
	local varMap = __TS__New(Map) -- 95
	local function varAccess(name) -- 96
		varMap:set(name, {name = name, id = name}) -- 97
		return {id = name} -- 98
	end -- 96
	Gen.Declare = function(name, value) return __TS__New(Gen.Blk, "declare_variable", {fields = {VAR = {id = name, name = name}}, inputs = {VALUE = value}}) end -- 3
	Gen.If = function(cond, body) return {condition = cond, elseBranch = false, body = body} end -- 3
	Gen.Else = function(body) return {elseBranch = true, body = body} end -- 3
	local function _ifElseCore(main, elseIfs, otherwise) -- 110
		local inputs = {IF0 = main.condition, DO0 = main.body} -- 115
		__TS__ArrayForEach( -- 119
			elseIfs, -- 119
			function(____, br, idx) -- 119
				inputs["IF" .. tostring(idx + 1)] = br.condition -- 120
				inputs["DO" .. tostring(idx + 1)] = br.body -- 121
			end -- 119
		) -- 119
		if otherwise then -- 119
			inputs.ELSE = otherwise -- 123
		end -- 123
		return __TS__New(Gen.Blk, "controls_if", {extraState = {elseIfCount = #elseIfs, hasElse = not not otherwise}, inputs = inputs}) -- 124
	end -- 110
	Gen.IfElse = function(...) -- 3
		local ifBranchesOrElse = {...} -- 3
		local last = ifBranchesOrElse[#ifBranchesOrElse] -- 131
		local main = ifBranchesOrElse[1] -- 132
		local elseIfs = last.elseBranch and __TS__ArraySlice(ifBranchesOrElse, 1, -1) or __TS__ArraySlice(ifBranchesOrElse, 1) -- 133
		local elseBody = last.elseBranch and last.body or nil -- 134
		return _ifElseCore(main, elseIfs, elseBody) -- 135
	end -- 130
	Gen.Block = function(...) -- 3
		local nodes = {...} -- 3
		__TS__ArrayReduce( -- 139
			nodes, -- 139
			function(____, prev, cur) -- 139
				prev:next(cur) -- 139
				return cur -- 139
			end -- 139
		) -- 139
		return nodes[1] -- 140
	end -- 138
	local collectVariables -- 143
	collectVariables = function(node, set) -- 143
		if set == nil then -- 143
			set = __TS__New(Set) -- 143
		end -- 143
		local ____temp_8 = node.type == "declare_variable" -- 144
		if ____temp_8 then -- 144
			local ____opt_6 = node.fields -- 144
			local ____opt_4 = ____opt_6 and ____opt_6.VAR -- 144
			if ____opt_4 ~= nil then -- 144
				____opt_4 = ____opt_4.id -- 144
			end -- 144
			____temp_8 = ____opt_4 -- 144
		end -- 144
		if ____temp_8 then -- 144
			set:add(node.fields.VAR.id) -- 145
		end -- 145
		if node.inputs then -- 145
			for ____, n in pairs(node.inputs) do -- 148
				collectVariables(n, set) -- 149
			end -- 149
		end -- 149
		if node._next then -- 149
			collectVariables(node._next, set) -- 152
		end -- 152
		return set -- 153
	end -- 143
	local fixProcParamNames -- 156
	fixProcParamNames = function(node, funcs) -- 156
		if node.type == "procedures_callnoreturn" or node.type == "procedures_callreturn" then -- 156
			local funcName = node.extraState.name -- 158
			for ____, func in ipairs(funcs) do -- 159
				local ____opt_9 = func.fields -- 159
				local name = ____opt_9 and ____opt_9.NAME -- 160
				if funcName == name then -- 160
					local params = func.extraState.params -- 162
					node.extraState.params = __TS__ArrayMap( -- 163
						params, -- 163
						function(____, param) return param.name end -- 163
					) -- 163
				end -- 163
			end -- 163
		end -- 163
		if node.inputs then -- 163
			for ____, n in pairs(node.inputs) do -- 168
				fixProcParamNames(n, funcs) -- 169
			end -- 169
		end -- 169
		if node._next then -- 169
			fixProcParamNames(node._next, funcs) -- 172
		end -- 172
	end -- 156
	Gen.Num = function(n) return __TS__New(Gen.Blk, "math_number", {fields = {NUM = n}}) end -- 3
	Gen.VarGet = function(name) return __TS__New(Gen.Blk, "variables_get", {fields = {VAR = {id = name, name = name}}}) end -- 3
	Gen.Repeat = function(times, body) return __TS__New(Gen.Blk, "controls_repeat_ext", {inputs = {TIMES = times, DO = body}}) end -- 3
	local function whileUntil(mode) -- 189
		return function(cond, body) return __TS__New(Gen.Blk, "controls_whileUntil", {fields = {MODE = mode}, inputs = {BOOL = cond, DO = body}}) end -- 191
	end -- 189
	Gen.While = whileUntil("WHILE") -- 3
	Gen.Until = whileUntil("UNTIL") -- 3
	Gen.For = function(varName, from, to, by, body) return __TS__New( -- 3
		Gen.Blk, -- 3
		"controls_for", -- 207
		{ -- 207
			fields = {VAR = varAccess(varName)}, -- 208
			inputs = {FROM = from, TO = to, BY = by, DO = body} -- 209
		} -- 209
	) end -- 209
	Gen.ForEach = function(varName, list, body) return __TS__New( -- 3
		Gen.Blk, -- 3
		"controls_forEach", -- 222
		{ -- 222
			fields = {VAR = varAccess(varName)}, -- 223
			inputs = {LIST = list, DO = body} -- 224
		} -- 224
	) end -- 224
	local function flowStmt(kind) -- 227
		return __TS__New(Gen.Blk, "controls_flow_statements", {fields = {FLOW = kind}}) -- 228
	end -- 227
	Gen.Break = function() return flowStmt("BREAK") end -- 3
	Gen.Continue = function() return flowStmt("CONTINUE") end -- 3
	local function constant(c) -- 235
		return __TS__New(Gen.Blk, "math_constant", {fields = {CONSTANT = c}}) -- 238
	end -- 235
	Gen.PI = constant("PI") -- 3
	Gen.E = constant("E") -- 3
	Gen.GOLDEN_RATIO = constant("GOLDEN_RATIO") -- 3
	Gen.SQRT2 = constant("SQRT2") -- 3
	Gen.SQRT1_2 = constant("SQRT1_2") -- 3
	Gen.INFINITY = constant("INFINITY") -- 3
	local function arithmetic(op, A, B) -- 247
		return __TS__New(Gen.Blk, "math_arithmetic", {fields = {OP = op}, inputs = {A = A, B = B}}) -- 251
	end -- 247
	Gen.Add = function(a, b) return arithmetic("ADD", a, b) end -- 3
	Gen.Sub = function(a, b) return arithmetic("MINUS", a, b) end -- 3
	Gen.Mul = function(a, b) return arithmetic("MULTIPLY", a, b) end -- 3
	Gen.Div = function(a, b) return arithmetic("DIVIDE", a, b) end -- 3
	Gen.Pow = function(a, b) return arithmetic("POWER", a, b) end -- 3
	local function mathSingle(op, n) -- 259
		return __TS__New(Gen.Blk, "math_single", {fields = {OP = op}, inputs = {NUM = n}}) -- 264
	end -- 259
	Gen.Root = function(n) return mathSingle("ROOT", n) end -- 3
	Gen.Abs = function(n) return mathSingle("ABS", n) end -- 3
	Gen.Neg = function(n) return mathSingle("NEG", n) end -- 3
	Gen.Ln = function(n) return mathSingle("LN", n) end -- 3
	Gen.Log10 = function(n) return mathSingle("LOG10", n) end -- 3
	Gen.Exp = function(n) return mathSingle("EXP", n) end -- 3
	Gen.Pow10 = function(n) return mathSingle("POW10", n) end -- 3
	local function trig(op, n) -- 274
		return __TS__New(Gen.Blk, "math_trig", {fields = {OP = op}, inputs = {NUM = n}}) -- 277
	end -- 274
	Gen.Sin = function(deg) return trig("SIN", deg) end -- 3
	Gen.Cos = function(deg) return trig("COS", deg) end -- 3
	Gen.Tan = function(deg) return trig("TAN", deg) end -- 3
	Gen.Asin = function(deg) return trig("ASIN", deg) end -- 3
	Gen.Acos = function(deg) return trig("ACOS", deg) end -- 3
	Gen.Atan = function(deg) return trig("ATAN", deg) end -- 3
	local function numProp(property, n) -- 286
		return __TS__New(Gen.Blk, "math_number_property", {fields = {PROPERTY = property}, extraState = "<mutation divisor_input=\"false\"></mutation>", inputs = {NUMBER_TO_CHECK = n}}) -- 292
	end -- 286
	Gen.IsEven = function(n) return numProp("EVEN", n) end -- 3
	Gen.IsOdd = function(n) return numProp("ODD", n) end -- 3
	Gen.IsPrime = function(n) return numProp("PRIME", n) end -- 3
	Gen.IsWhole = function(n) return numProp("WHOLE", n) end -- 3
	Gen.IsPositive = function(n) return numProp("POSITIVE", n) end -- 3
	Gen.IsNegtive = function(n) return numProp("NEGATIVE", n) end -- 3
	Gen.IsDivisibleBy = function(n, divisor) return __TS__New(Gen.Blk, "math_number_property", {fields = {PROPERTY = "DIVISIBLE_BY"}, extraState = "<mutation divisor_input=\"true\"></mutation>", inputs = {NUMBER_TO_CHECK = n, DIVISOR = divisor}}) end -- 3
	local function round(op, n) -- 310
		return __TS__New(Gen.Blk, "math_round", {fields = {OP = op}, inputs = {NUM = n}}) -- 313
	end -- 310
	Gen.Round = function(n) return round("ROUND", n) end -- 3
	Gen.RoundUp = function(n) return round("ROUNDUP", n) end -- 3
	Gen.RoundDown = function(n) return round("ROUNDDOWN", n) end -- 3
	Gen.Modulo = function(dividend, divisor) return __TS__New(Gen.Blk, "math_modulo", {inputs = {DIVIDEND = dividend, DIVISOR = divisor}}) end -- 3
	local function mathOnList(op, listBlock) -- 322
		return __TS__New(Gen.Blk, "math_on_list", {fields = {OP = op}, extraState = ("<mutation op=\"" .. op) .. "\"></mutation>", inputs = {LIST = listBlock}}) -- 328
	end -- 322
	Gen.Sum = function(listBlock) return mathOnList("SUM", listBlock) end -- 3
	Gen.Min = function(listBlock) return mathOnList("MIN", listBlock) end -- 3
	Gen.Max = function(listBlock) return mathOnList("MAX", listBlock) end -- 3
	Gen.Average = function(listBlock) return mathOnList("AVERAGE", listBlock) end -- 3
	Gen.Median = function(listBlock) return mathOnList("MEDIAN", listBlock) end -- 3
	Gen.Mode = function(listBlock) return mathOnList("MODE", listBlock) end -- 3
	Gen.StdDev = function(listBlock) return mathOnList("STD_DEV", listBlock) end -- 3
	Gen.Random = function(listBlock) return mathOnList("RANDOM", listBlock) end -- 3
	Gen.Constrain = function(valueNum, lowNum, highNum) return __TS__New(Gen.Blk, "math_constrain", {inputs = {VALUE = valueNum, LOW = lowNum, HIGH = highNum}}) end -- 3
	Gen.RandomInt = function(fromNum, toNum) return __TS__New(Gen.Blk, "math_random_int", {inputs = {FROM = fromNum, TO = toNum}}) end -- 3
	Gen.RandomFloat = function() return __TS__New(Gen.Blk, "math_random_float") end -- 3
	Gen.Atan2 = function(x, y) return __TS__New(Gen.Blk, "math_atan2", {inputs = {X = x, Y = y}}) end -- 3
	Gen.TextJoin = function(...) -- 3
		local texts = {...} -- 3
		local inputMap = {} -- 355
		__TS__ArrayForEach( -- 356
			texts, -- 356
			function(____, b, i) -- 356
				inputMap["ADD" .. tostring(i)] = b -- 357
			end -- 356
		) -- 356
		return __TS__New(Gen.Blk, "text_join", {extraState = {itemCount = #texts}, inputs = inputMap}) -- 359
	end -- 354
	Gen.TextAppend = function(varName, what) return __TS__New( -- 3
		Gen.Blk, -- 3
		"text_append", -- 366
		{ -- 366
			fields = {VAR = varAccess(varName)}, -- 367
			inputs = {TEXT = what} -- 368
		} -- 368
	) end -- 368
	Gen.TextLength = function(text) return __TS__New(Gen.Blk, "text_length", {inputs = {VALUE = text}}) end -- 3
	Gen.IsTextEmpty = function(text) return __TS__New(Gen.Blk, "text_isEmpty", {inputs = {VALUE = text}}) end -- 3
	Gen.TextReverse = function(text) return __TS__New(Gen.Blk, "text_reverse", {inputs = {TEXT = text}}) end -- 3
	local function textIndexOf(____end, textBlk, findBlk) -- 381
		return __TS__New(Gen.Blk, "text_indexOf", {fields = {END = ____end}, inputs = {VALUE = textBlk, FIND = findBlk}}) -- 386
	end -- 381
	Gen.TextFirstIndexOf = function(text, firstFind) return textIndexOf("FIRST", text, firstFind) end -- 3
	Gen.TextLastIndexOf = function(text, lastFind) return textIndexOf("LAST", text, lastFind) end -- 3
	local function charAt(where, textBlk, at) -- 395
		return __TS__New( -- 400
			Gen.Blk, -- 3
			"text_charAt", -- 400
			{ -- 400
				extraState = ("<mutation at=\"" .. tostring(where == "FROM_START" or where == "FROM_END")) .. "\"></mutation>", -- 401
				fields = {WHERE = where}, -- 402
				inputs = __TS__ObjectAssign({VALUE = textBlk}, at and ({AT = at}) or ({})) -- 403
			} -- 403
		) -- 403
	end -- 395
	Gen.CharFromStart = function(text, at) return charAt("FROM_START", text, at) end -- 3
	Gen.CharFromEnd = function(text, at) return charAt("FROM_END", text, at) end -- 3
	Gen.FirstChar = function(text) return charAt("FIRST", text) end -- 3
	Gen.LastChar = function(text) return charAt("LAST", text) end -- 3
	Gen.RandomChar = function(text) return charAt("RANDOM", text) end -- 3
	local function substring(where1, where2, textBlk, at1, at2) -- 417
		return __TS__New( -- 422
			Gen.Blk, -- 3
			"text_getSubstring", -- 422
			{ -- 422
				extraState = ((("<mutation at1=\"" .. tostring(where1 == "FROM_START" or where1 == "FROM_END")) .. "\" at2=\"") .. tostring(where2 == "FROM_START" or where2 == "FROM_END")) .. "\"></mutation>", -- 423
				fields = {WHERE1 = where1, WHERE2 = where2}, -- 424
				inputs = __TS__ObjectAssign({STRING = textBlk}, at1 and ({AT1 = at1}) or ({}), at2 and ({AT2 = at2}) or ({})) -- 425
			} -- 425
		) -- 425
	end -- 417
	Gen.Substring = function(at1, at2) return substring("FROM_START", at2 and "FROM_START" or "LAST", at1, at2) end -- 3
	local function changeCase(mode, str) -- 435
		return __TS__New(Gen.Blk, "text_changeCase", {fields = {CASE = mode}, inputs = {TEXT = str}}) -- 436
	end -- 435
	Gen.UpperCase = function(text) return changeCase("UPPERCASE", text) end -- 3
	Gen.LowerCase = function(text) return changeCase("LOWERCASE", text) end -- 3
	Gen.TitleCase = function(text) return changeCase("TITLECASE", text) end -- 3
	local function trim(mode, str) -- 446
		return __TS__New(Gen.Blk, "text_trim", {fields = {MODE = mode}, inputs = {TEXT = str}}) -- 447
	end -- 446
	Gen.TrimLeft = function(text) return trim("LEFT", text) end -- 3
	Gen.TrimRight = function(text) return trim("RIGHT", text) end -- 3
	Gen.Trim = function(text) return trim("BOTH", text) end -- 3
	Gen.TextCount = function(subText, text) return __TS__New(Gen.Blk, "text_count", {inputs = {SUB = subText, TEXT = text}}) end -- 3
	Gen.TextReplace = function(text, fromText, toText) return __TS__New(Gen.Blk, "text_replace", {inputs = {TEXT = text, FROM = fromText, TO = toText}}) end -- 3
	Gen.RepeatList = function(item, times) return __TS__New(Gen.Blk, "lists_repeat", {inputs = {ITEM = item, NUM = times}}) end -- 3
	Gen.ListLength = function(list) return __TS__New(Gen.Blk, "lists_length", {inputs = {VALUE = list}}) end -- 3
	Gen.IsListEmpty = function(list) return __TS__New(Gen.Blk, "lists_isEmpty", {inputs = {VALUE = list}}) end -- 3
	local function indexOf(list, findItem, which) -- 479
		return __TS__New(Gen.Blk, "lists_indexOf", {fields = {END = which}, inputs = {VALUE = list, FIND = findItem}}) -- 484
	end -- 479
	Gen.FirstIndexOf = function(list, findItem) return indexOf(list, findItem, "FIRST") end -- 3
	Gen.LastIndexOf = function(list, findItem) return indexOf(list, findItem, "FIRST") end -- 3
	local function listGetIndex(mode, where, listExpr, at) -- 500
		return __TS__New( -- 506
			Gen.Blk, -- 3
			"lists_getIndex", -- 506
			{ -- 506
				fields = {MODE = mode, WHERE = where}, -- 507
				inputs = __TS__ObjectAssign({VALUE = listExpr}, at and ({AT = at}) or ({})), -- 508
				extraState = {isStatement = mode == "REMOVE"} -- 512
			} -- 512
		) -- 512
	end -- 500
	Gen.ListGet = function(list, at) return listGetIndex("GET", "FROM_START", list, at) end -- 3
	Gen.ListRemoveGet = function(list, at) return listGetIndex("GET_REMOVE", "FROM_START", list, at) end -- 3
	Gen.ListRemove = function(list, at) return listGetIndex("REMOVE", "FROM_START", list, at) end -- 3
	Gen.ListRemoveLast = function(list) return listGetIndex("GET_REMOVE", "LAST", list) end -- 3
	Gen.ListRemoveFirst = function(list) return listGetIndex("GET_REMOVE", "FIRST", list) end -- 3
	local function subList(listExpr, where1, where2, at1, at2) -- 521
		return __TS__New(Gen.Blk, "lists_getSublist", {fields = {WHERE1 = where1, WHERE2 = where2}, inputs = at2 and ({LIST = listExpr, AT1 = at1, AT2 = at2}) or ({LIST = listExpr, AT1 = at1})}) -- 528
	end -- 521
	Gen.SubList = function(list, at1, at2) return subList( -- 3
		list, -- 534
		"FROM_START", -- 534
		at2 and "FROM_START" or "LAST", -- 534
		at1, -- 534
		at2 -- 534
	) end -- 534
	local function listSplit(input, delim, mode) -- 536
		return __TS__New(Gen.Blk, "lists_split", {fields = {MODE = mode}, inputs = {INPUT = input, DELIM = delim}}) -- 541
	end -- 536
	Gen.ListSplit = function(inputText, delimText) return listSplit(inputText, delimText, "SPLIT") end -- 3
	Gen.ListStringConcat = function(list, delimText) return listSplit(list, delimText, "JOIN") end -- 3
	local function listSort(listExpr, ____type, direction) -- 549
		return __TS__New(Gen.Blk, "lists_sort", {fields = {TYPE = ____type, DIRECTION = direction}, inputs = {LIST = listExpr}}) -- 554
	end -- 549
	Gen.ListSort = function(list, desc) return listSort(list, "NUMERIC", desc and "-1" or "1") end -- 3
	Gen.ListReverse = function(list) return __TS__New(Gen.Blk, "lists_reverse", {inputs = {LIST = list}}) end -- 3
	local function listSetIndex(mode, listExpr, at, to, where) -- 564
		return __TS__New(Gen.Blk, "lists_setIndex", {fields = {MODE = mode, WHERE = where}, inputs = {LIST = listExpr, AT = at, TO = to}}) -- 571
	end -- 564
	Gen.ListSet = function(list, at, item) return listSetIndex( -- 3
		"SET", -- 576
		list, -- 576
		at, -- 576
		item, -- 576
		"FROM_START" -- 576
	) end -- 576
	Gen.ListInsert = function(list, at, item) return listSetIndex( -- 3
		"INSERT", -- 577
		list, -- 577
		at, -- 577
		item, -- 577
		"FROM_START" -- 577
	) end -- 577
	Gen.Dict = function() return __TS__New(Gen.Blk, "dict_create") end -- 3
	Gen.DictGet = function(dict, key) return __TS__New(Gen.Blk, "dict_get", {inputs = {DICT = dict, KEY = key}}) end -- 3
	Gen.DictSet = function(dict, key, val) return __TS__New(Gen.Blk, "dict_set", {inputs = {DICT = dict, KEY = key, VALUE = val}}) end -- 3
	Gen.DictContain = function(dict, key) return __TS__New(Gen.Blk, "dict_has_key", {inputs = {DICT = dict, KEY = key}}) end -- 3
	Gen.DictRemove = function(dict, key) return __TS__New(Gen.Blk, "dict_remove_key", {inputs = {DICT = dict, KEY = key}}) end -- 3
	Gen.VarSet = function(name, value) return __TS__New( -- 3
		Gen.Blk, -- 3
		"variables_set", -- 594
		{ -- 594
			fields = {VAR = varAccess(name)}, -- 595
			inputs = {VALUE = value} -- 596
		} -- 596
	) end -- 596
	Gen.VarAdd = function(name, deltaNum) return __TS__New( -- 3
		Gen.Blk, -- 3
		"math_change", -- 600
		{ -- 600
			fields = {VAR = varAccess(name)}, -- 601
			inputs = {DELTA = deltaNum} -- 602
		} -- 602
	) end -- 602
	Gen.ProcReturn = function(value) return __TS__New(Gen.Blk, "return_block", {inputs = value and ({VALUE = value}) or ({})}) end -- 3
	Gen.ProcIfReturn = function(cond, value) return __TS__New( -- 3
		Gen.Blk, -- 3
		"procedures_ifreturn", -- 612
		{ -- 612
			extraState = ("<mutation value=\"" .. tostring(value and 1 or 0)) .. "\"></mutation>", -- 613
			inputs = value and ({CONDITION = cond, VALUE = value}) or ({CONDITION = cond}) -- 614
		} -- 614
	) end -- 614
	local function buildParams(names) -- 619
		return __TS__ArrayMap( -- 620
			names, -- 620
			function(____, p) return { -- 620
				name = p, -- 620
				id = IdFactory:next("arg") -- 620
			} end -- 620
		) -- 620
	end -- 619
	Gen.DefProcReturn = function(name, params, body, returnExpr) return __TS__New( -- 3
		Gen.Blk, -- 3
		"procedures_defreturn", -- 628
		{ -- 628
			fields = {NAME = name}, -- 629
			inputs = {STACK = body, RETURN = returnExpr}, -- 630
			extraState = {params = buildParams(params)} -- 631
		} -- 631
	) end -- 631
	Gen.DefProc = function(name, params, body) return __TS__New( -- 3
		Gen.Blk, -- 3
		"procedures_defnoreturn", -- 639
		{ -- 639
			fields = {NAME = name}, -- 640
			inputs = {STACK = body}, -- 641
			extraState = {params = buildParams(params)} -- 642
		} -- 642
	) end -- 642
	Gen.CallProc = function(procName, ...) -- 3
		local args = {...} -- 3
		local inputMap = {} -- 646
		__TS__ArrayForEach( -- 647
			args, -- 647
			function(____, value, i) -- 647
				inputMap["ARG" .. tostring(i)] = value -- 648
			end -- 647
		) -- 647
		return __TS__New(Gen.Blk, "procedures_callnoreturn", {extraState = {name = procName, params = nil}, inputs = inputMap}) -- 650
	end -- 645
	Gen.CallProcReturn = function(procName, ...) -- 3
		local args = {...} -- 3
		local inputMap = {} -- 657
		__TS__ArrayForEach( -- 658
			args, -- 658
			function(____, value, i) -- 658
				inputMap["ARG" .. tostring(i)] = value -- 659
			end -- 658
		) -- 658
		return __TS__New(Gen.Blk, "procedures_callreturn", {extraState = {name = procName, params = nil}, inputs = inputMap}) -- 661
	end -- 656
	Gen.Vec2Zero = function() return __TS__New(Gen.Blk, "vec2_zero") end -- 3
	Gen.Vec2 = function(x, y) return __TS__New(Gen.Blk, "vec2_create", {inputs = {X = x, Y = y}}) end -- 3
	local function vec2Prop(vecVar, prop) -- 673
		return __TS__New( -- 674
			Gen.Blk, -- 3
			"vec2_get_property", -- 674
			{fields = { -- 674
				VEC2 = varAccess(vecVar), -- 675
				PROPERTY = prop -- 675
			}} -- 675
		) -- 675
	end -- 673
	Gen.Vec2X = function(varName) return vec2Prop(varName, "x") end -- 3
	Gen.Vec2Y = function(varName) return vec2Prop(varName, "y") end -- 3
	Gen.Vec2Length = function(varName) return vec2Prop(varName, "length") end -- 3
	Gen.Vec2Angle = function(varName) return vec2Prop(varName, "angle") end -- 3
	Gen.Vec2Normalize = function(v) return __TS__New(Gen.Blk, "vec2_get_normalized", {inputs = {VEC2 = v}}) end -- 3
	local function vec2VecOp(op, a, b) -- 686
		return __TS__New(Gen.Blk, "vec2_binary_operation", {fields = {OPERATION = op}, inputs = {VEC2_1 = a, VEC2_2 = b}}) -- 687
	end -- 686
	Gen.Vec2Add = function(a, b) return vec2VecOp("+", a, b) end -- 3
	Gen.Vec2Sub = function(a, b) return vec2VecOp("-", a, b) end -- 3
	Gen.Vec2MulVec = function(a, b) return vec2VecOp("*", a, b) end -- 3
	Gen.Vec2DivVec = function(a, b) return vec2VecOp("/", a, b) end -- 3
	Gen.Vec2Distance = function(a, b) return vec2Calc("distance", a, b) end -- 3
	Gen.Vec2Dot = function(a, b) return vec2Calc("dot", a, b) end -- 3
	local function vec2NumOp(op, v, n) -- 699
		return __TS__New(Gen.Blk, "vec2_binary_op_number", {fields = {OPERATION = op}, inputs = {VEC2 = v, NUMBER = n}}) -- 700
	end -- 699
	Gen.Vec2MulNum = function(v, n) return vec2NumOp("*", v, n) end -- 3
	Gen.Vec2DivNum = function(v, n) return vec2NumOp("/", v, n) end -- 3
	Gen.Vec2Clamp = function(v, min, max) return __TS__New(Gen.Blk, "vec2_clamp", {inputs = {VEC2 = v, MIN = min, MAX = max}}) end -- 3
	vec2Calc = function(what, a, b) return __TS__New(Gen.Blk, "vec2_calculate", {fields = {CALCULATE = what}, inputs = {VEC2_1 = a, VEC2_2 = b}}) end -- 717
	Gen.CreateNode = function() return __TS__New(Gen.Blk, "node_create") end -- 3
	Gen.CreateSprite = function(file) return __TS__New(Gen.Blk, "sprite_create", {inputs = {FILE = file}}) end -- 3
	Gen.CreateLabel = function(fontName, size) return __TS__New(Gen.Blk, "label_create", {inputs = {FONT = fontName, SIZE = size}}) end -- 3
	Gen.LabelSetText = function(varName, text) return __TS__New( -- 3
		Gen.Blk, -- 3
		"label_set_text", -- 736
		{ -- 736
			fields = {LABEL = varAccess(varName)}, -- 737
			inputs = {TEXT = text} -- 738
		} -- 738
	) end -- 738
	Gen.NodeAddChild = function(parentVar, childVar, order) return __TS__New( -- 3
		Gen.Blk, -- 3
		"node_add_child", -- 742
		{ -- 742
			fields = { -- 743
				PARENT = varAccess(parentVar), -- 743
				CHILD = varAccess(childVar) -- 743
			}, -- 743
			inputs = {ORDER = order} -- 744
		} -- 744
	) end -- 744
	local function nodeSetNumAttr(varName, attr, value) -- 748
		return __TS__New( -- 749
			Gen.Blk, -- 3
			"node_set_number_attribute", -- 749
			{ -- 749
				fields = { -- 750
					NODE = varAccess(varName), -- 750
					ATTRIBUTE = attr -- 750
				}, -- 750
				inputs = {VALUE = value} -- 751
			} -- 751
		) -- 751
	end -- 748
	Gen.NodeSetX = function(varName, n) return nodeSetNumAttr(varName, "x", n) end -- 3
	Gen.NodeSetY = function(varName, n) return nodeSetNumAttr(varName, "y", n) end -- 3
	Gen.NodeSetWidth = function(varName, n) return nodeSetNumAttr(varName, "width", n) end -- 3
	Gen.NodeSetHeight = function(varName, n) return nodeSetNumAttr(varName, "height", n) end -- 3
	Gen.NodeSetAngle = function(varName, n) return nodeSetNumAttr(varName, "angle", n) end -- 3
	Gen.NodeSetScale = function(varName, n) return nodeSetNumAttr(varName, "scale", n) end -- 3
	Gen.NodeSetScaleX = function(varName, n) return nodeSetNumAttr(varName, "scaleX", n) end -- 3
	Gen.NodeSetScaleY = function(varName, n) return nodeSetNumAttr(varName, "scaleY", n) end -- 3
	Gen.NodeSetOpactity = function(varName, n) return nodeSetNumAttr(varName, "opacity", n) end -- 3
	local function nodeGetNumAttr(varName, attr) -- 763
		return __TS__New( -- 764
			Gen.Blk, -- 3
			"node_get_number_attribute", -- 764
			{fields = { -- 764
				NODE = varAccess(varName), -- 765
				ATTRIBUTE = attr -- 765
			}} -- 765
		) -- 765
	end -- 763
	Gen.NodeGetX = function(varName) return nodeGetNumAttr(varName, "x") end -- 3
	Gen.NodeGetY = function(varName) return nodeGetNumAttr(varName, "y") end -- 3
	Gen.NodeGetWidth = function(varName) return nodeGetNumAttr(varName, "width") end -- 3
	Gen.NodeGetHeight = function(varName) return nodeGetNumAttr(varName, "height") end -- 3
	Gen.NodeGetAngle = function(varName) return nodeGetNumAttr(varName, "angle") end -- 3
	Gen.NodeGetScale = function(varName) return nodeGetNumAttr(varName, "scale") end -- 3
	Gen.NodeGetScaleX = function(varName) return nodeGetNumAttr(varName, "scaleX") end -- 3
	Gen.NodeGetScaleY = function(varName) return nodeGetNumAttr(varName, "scaleY") end -- 3
	Gen.NodeGetOpactity = function(varName) return nodeGetNumAttr(varName, "opacity") end -- 3
	local function nodeSetBoolAttr(nodeVar, attr, value) -- 779
		return __TS__New( -- 780
			Gen.Blk, -- 3
			"node_set_boolean_attribute", -- 780
			{ -- 780
				fields = { -- 781
					NODE = varAccess(nodeVar), -- 781
					ATTRIBUTE = attr -- 781
				}, -- 781
				inputs = {VALUE = value} -- 782
			} -- 782
		) -- 782
	end -- 779
	Gen.NodeSetVisible = function(varName, bool) return nodeSetBoolAttr(varName, "visible", bool) end -- 3
	local function nodeGetBoolAttr(varName, attr) -- 787
		return __TS__New( -- 788
			Gen.Blk, -- 3
			"node_get_boolean_attribute", -- 788
			{fields = { -- 788
				NODE = varAccess(varName), -- 789
				ATTRIBUTE = attr -- 789
			}} -- 789
		) -- 789
	end -- 787
	Gen.NodeGetVisible = function(varName) return nodeGetBoolAttr(varName, "visible") end -- 3
	local function nodeSetVec2Attr(varName, attr, vec) -- 795
		return __TS__New( -- 796
			Gen.Blk, -- 3
			"node_set_vec2_attribute", -- 796
			{ -- 796
				fields = { -- 797
					NODE = varAccess(varName), -- 797
					ATTRIBUTE = attr -- 797
				}, -- 797
				inputs = {VEC2 = vec} -- 798
			} -- 798
		) -- 798
	end -- 795
	Gen.NodeSetPosition = function(varName, vec) return nodeSetVec2Attr(varName, "position", vec) end -- 3
	Gen.NodeSetAnchor = function(varName, vec) return nodeSetVec2Attr(varName, "anchor", vec) end -- 3
	local function nodeGetVec2Attr(nodeVar, attr) -- 804
		return __TS__New( -- 805
			Gen.Blk, -- 3
			"node_get_vec2_attribute", -- 805
			{fields = { -- 805
				NODE = varAccess(nodeVar), -- 806
				ATTRIBUTE = attr -- 806
			}} -- 806
		) -- 806
	end -- 804
	Gen.NodeGetPosition = function(varName) return nodeGetVec2Attr(varName, "position") end -- 3
	Gen.NodeGetAnchor = function(varName) return nodeGetVec2Attr(varName, "anchor") end -- 3
	Gen.BeginPaint = function(nodeVar, paintBody) return __TS__New( -- 3
		Gen.Blk, -- 3
		"nvg_begin_painting", -- 813
		{ -- 813
			fields = {NODE = varAccess(nodeVar)}, -- 814
			inputs = {PAINT = paintBody} -- 815
		} -- 815
	) end -- 815
	Gen.BeginPath = function() return __TS__New(Gen.Blk, "nvg_begin_path") end -- 3
	Gen.MoveTo = function(x, y) return __TS__New(Gen.Blk, "nvg_move_to", {inputs = {X = x, Y = y}}) end -- 3
	Gen.BezierTo = function(c1x, c1y, c2x, c2y, x, y) return __TS__New(Gen.Blk, "nvg_bezier_to", {inputs = { -- 3
		C1X = c1x, -- 829
		C1Y = c1y, -- 829
		C2X = c2x, -- 829
		C2Y = c2y, -- 829
		X = x, -- 829
		Y = y -- 829
	}}) end -- 829
	Gen.LineTo = function(x, y) return __TS__New(Gen.Blk, "nvg_line_to", {inputs = {X = x, Y = y}}) end -- 3
	Gen.ClosePath = function() return __TS__New(Gen.Blk, "nvg_close_path") end -- 3
	Gen.FillColor = function(color, opacity) return __TS__New(Gen.Blk, "nvg_fill_color", {inputs = {COLOR = color, OPACITY = opacity}}) end -- 3
	Gen.Fill = function() return __TS__New(Gen.Blk, "nvg_fill") end -- 3
	Gen.StrokeColor = function(color, opacity) return __TS__New(Gen.Blk, "nvg_stroke_color", {inputs = {COLOR = color, OPACITY = opacity}}) end -- 3
	Gen.StrokeWidth = function(w) return __TS__New(Gen.Blk, "nvg_stroke_width", {inputs = {WIDTH = w}}) end -- 3
	Gen.Stroke = function() return __TS__New(Gen.Blk, "nvg_stroke") end -- 3
	Gen.Rect = function(x, y, w, h) return __TS__New(Gen.Blk, "nvg_rect", {inputs = {X = x, Y = y, WIDTH = w, HEIGHT = h}}) end -- 3
	Gen.RoundedRect = function(x, y, w, h, r) return __TS__New(Gen.Blk, "nvg_rounded_rect", {inputs = { -- 3
		X = x, -- 861
		Y = y, -- 861
		WIDTH = w, -- 861
		HEIGHT = h, -- 861
		RADIUS = r -- 861
	}}) end -- 861
	Gen.Ellipse = function(cx, cy, rx, ry) return __TS__New(Gen.Blk, "nvg_ellipse", {inputs = {CX = cx, CY = cy, RX = rx, RY = ry}}) end -- 3
	Gen.Circle = function(cx, cy, radius) return __TS__New(Gen.Blk, "nvg_circle", {inputs = {CX = cx, CY = cy, RADIUS = radius}}) end -- 3
	Gen.Color = function(hex) return __TS__New(Gen.Blk, "colour_hsv_sliders", {fields = {COLOUR = hex}}) end -- 3
	Gen.OnUpdate = function(nodeVar, dtVar, actionBody) return __TS__New( -- 3
		Gen.Blk, -- 3
		"on_update", -- 884
		{ -- 884
			fields = { -- 885
				NODE = varAccess(nodeVar), -- 885
				DELTA_TIME = varAccess(dtVar) -- 885
			}, -- 885
			inputs = {ACTION = actionBody} -- 886
		} -- 886
	) end -- 886
	Gen.OnTapEvent = function(nodeVar, event, touchVar, actionBody) return __TS__New( -- 3
		Gen.Blk, -- 3
		"on_tap_event", -- 896
		{ -- 896
			fields = { -- 897
				NODE = varAccess(nodeVar), -- 898
				EVENT = event, -- 899
				TOUCH = varAccess(touchVar) -- 900
			}, -- 900
			inputs = {ACTION = actionBody} -- 902
		} -- 902
	) end -- 902
	Gen.CheckKey = function(key, state) return __TS__New(Gen.Blk, "check_key", {fields = {KEY = key, KEY_STATE = state}}) end -- 3
	local function touchNumAttr(touchId, attr) -- 1016
		return __TS__New( -- 1017
			Gen.Blk, -- 3
			"get_touch_number_attribute", -- 1017
			{fields = { -- 1017
				TOUCH = varAccess(touchId), -- 1018
				ATTRIBUTE = attr -- 1018
			}} -- 1018
		) -- 1018
	end -- 1016
	Gen.TouchGetId = function(touchVar) return touchNumAttr(touchVar, "id") end -- 3
	local function touchVec2Attr(touchId, attr) -- 1023
		return __TS__New( -- 1024
			Gen.Blk, -- 3
			"get_touch_vec2_attribute", -- 1024
			{fields = { -- 1024
				TOUCH = varAccess(touchId), -- 1025
				ATTRIBUTE = attr -- 1025
			}} -- 1025
		) -- 1025
	end -- 1023
	Gen.TouchGetLocation = function(touchVar) return touchVec2Attr(touchVar, "location") end -- 3
	Gen.TouchGetWorldLocation = function(touchVar) return touchVec2Attr(touchVar, "worldLocation") end -- 3
	Gen.toBlocklyJSON = function(root, procs) -- 3
		local vars = __TS__ArrayMap( -- 1032
			__TS__ArrayFrom(collectVariables(root)), -- 1032
			function(____, n) return {name = n, id = n} end -- 1032
		) -- 1032
		for ____, ____value in __TS__Iterator(varMap:entries()) do -- 1033
			local _ = ____value[1] -- 1033
			local v = ____value[2] -- 1033
			vars[#vars + 1] = v -- 1034
		end -- 1034
		if procs then -- 1034
			fixProcParamNames(root, procs) -- 1037
			for ____, proc in ipairs(procs) do -- 1038
				fixProcParamNames(proc, procs) -- 1039
				local procVars = __TS__ArrayMap( -- 1040
					__TS__ArrayFrom(collectVariables(proc)), -- 1040
					function(____, n) return {name = n, id = n} end -- 1040
				) -- 1040
				vars = __TS__ArrayConcat(vars, procVars) -- 1041
			end -- 1041
		end -- 1041
		local finalVars = {} -- 1044
		local tmp = __TS__New(Set) -- 1045
		for ____, v in ipairs(vars) do -- 1046
			if not tmp:has(v.id) then -- 1046
				tmp:add(v.id) -- 1048
				finalVars[#finalVars + 1] = v -- 1049
			end -- 1049
		end -- 1049
		vars = finalVars -- 1052
		varMap = __TS__New(Map) -- 1053
		local ____opt_11 = procs -- 1053
		local procBlocks = ____opt_11 and __TS__ArrayMap( -- 1054
			procs, -- 1054
			function(____, proc, i) -- 1054
				local j = proc:toJSON() -- 1055
				j.x = (i + 1) * 500 -- 1056
				return j -- 1057
			end -- 1054
		) or ({}) -- 1054
		local res = json.dump({ -- 1059
			blocks = { -- 1060
				languageVersion = 0, -- 1061
				blocks = { -- 1062
					root:toJSON(), -- 1062
					table.unpack(procBlocks) -- 1062
				} -- 1062
			}, -- 1062
			variables = vars -- 1064
		}) -- 1064
		return res or "{}" -- 1066
	end -- 1031
end -- 1031
____exports.default = Gen -- 1258
return ____exports -- 1258