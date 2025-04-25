-- [ts]: BlocklyGen.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach -- 1
local Map = ____lualib.Map -- 1
local __TS__InstanceOf = ____lualib.__TS__InstanceOf -- 1
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
	local Blk = __TS__Class() -- 15
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
	Gen.Bool = function(v) return __TS__New(Blk, "logic_boolean", {fields = {BOOL = v and "TRUE" or "FALSE"}}) end -- 3
	Gen.Text = function(s) -- 3
		if s == nil then -- 3
			s = "" -- 54
		end -- 54
		return __TS__New(Blk, "text", {fields = {TEXT = s}}) -- 54
	end -- 54
	Gen.Print = function(item) return __TS__New(Blk, "print_block", {inputs = {ITEM = item}}) end -- 3
	local function compare(op, a, b) -- 57
		return __TS__New(Blk, "logic_compare", {fields = {OP = op}, inputs = {A = a, B = b}}) -- 58
	end -- 57
	Gen.Eq = function(a, b) return compare("EQ", a, b) end -- 3
	Gen.Neq = function(a, b) return compare("NEQ", a, b) end -- 3
	Gen.Lt = function(a, b) return compare("LT", a, b) end -- 3
	Gen.Gt = function(a, b) return compare("GT", a, b) end -- 3
	Gen.Gte = function(a, b) return compare("GTE", a, b) end -- 3
	Gen.Lte = function(a, b) return compare("LTE", a, b) end -- 3
	local function logicOp(op, a, b) -- 67
		return __TS__New(Blk, "logic_operation", {fields = {OP = op}, inputs = {A = a, B = b}}) -- 68
	end -- 67
	Gen.And = function(a, b) return logicOp("AND", a, b) end -- 3
	Gen.Or = function(a, b) return logicOp("OR", a, b) end -- 3
	Gen.Not = function(b) return __TS__New(Blk, "logic_negate", {inputs = {BOOL = b}}) end -- 3
	Gen.Ternary = function(cond, thenValue, elseValue) return __TS__New(Blk, "logic_ternary", {inputs = {IF = cond, THEN = thenValue, ELSE = elseValue}}) end -- 3
	Gen.List = function(...) -- 3
		local items = {...} -- 3
		local inputMap = {} -- 84
		__TS__ArrayForEach( -- 85
			items, -- 85
			function(____, b, i) -- 85
				inputMap["ADD" .. tostring(i)] = b -- 86
			end -- 85
		) -- 85
		return __TS__New(Blk, "lists_create_with", {extraState = {itemCount = #items}, inputs = inputMap}) -- 88
	end -- 83
	local varMap = __TS__New(Map) -- 95
	local function varAccess(name) -- 96
		varMap:set(name, {name = name, id = name}) -- 97
		return {id = name} -- 98
	end -- 96
	Gen.Declare = function(name, value) return __TS__New(Blk, "declare_variable", {fields = {VAR = {id = name, name = name}}, inputs = {VALUE = value}}) end -- 3
	Gen.If = function(cond, body) return {condition = cond, body = body} end -- 3
	Gen.Else = function(body) return body end -- 3
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
		return __TS__New(Blk, "controls_if", {extraState = {elseIfCount = #elseIfs, hasElse = not not otherwise}, inputs = inputs}) -- 124
	end -- 110
	Gen.IfElse = function(...) -- 3
		local ifBranchesOrElse = {...} -- 3
		local last = ifBranchesOrElse[#ifBranchesOrElse] -- 131
		local hasElse = __TS__InstanceOf(last, Blk) -- 132
		local main = ifBranchesOrElse[1] -- 133
		local elseIfs = hasElse and __TS__ArraySlice(ifBranchesOrElse, 1, -1) or __TS__ArraySlice(ifBranchesOrElse, 1) -- 134
		local elseBody = hasElse and last or nil -- 135
		return _ifElseCore(main, elseIfs, elseBody) -- 136
	end -- 130
	Gen.Block = function(...) -- 3
		local nodes = {...} -- 3
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
	Gen.Num = function(n) return __TS__New(Blk, "math_number", {fields = {NUM = n}}) end -- 3
	Gen.VarGet = function(name) return __TS__New(Blk, "variables_get", {fields = {VAR = {id = name, name = name}}}) end -- 3
	Gen.Repeat = function(times, body) return __TS__New(Blk, "controls_repeat_ext", {inputs = {TIMES = times, DO = body}}) end -- 3
	local function whileUntil(mode) -- 190
		return function(cond, body) return __TS__New(Blk, "controls_whileUntil", {fields = {MODE = mode}, inputs = {BOOL = cond, DO = body}}) end -- 192
	end -- 190
	Gen.While = whileUntil("WHILE") -- 3
	Gen.Until = whileUntil("UNTIL") -- 3
	Gen.For = function(varName, from, to, by, body) return __TS__New( -- 3
		Blk, -- 208
		"controls_for", -- 208
		{ -- 208
			fields = {VAR = varAccess(varName)}, -- 209
			inputs = {FROM = from, TO = to, BY = by, DO = body} -- 210
		} -- 210
	) end -- 210
	Gen.ForEach = function(varName, list, body) return __TS__New( -- 3
		Blk, -- 223
		"controls_forEach", -- 223
		{ -- 223
			fields = {VAR = varAccess(varName)}, -- 224
			inputs = {LIST = list, DO = body} -- 225
		} -- 225
	) end -- 225
	local function flowStmt(kind) -- 228
		return __TS__New(Blk, "controls_flow_statements", {fields = {FLOW = kind}}) -- 229
	end -- 228
	Gen.Break = function() return flowStmt("BREAK") end -- 3
	Gen.Continue = function() return flowStmt("CONTINUE") end -- 3
	local function constant(c) -- 236
		return __TS__New(Blk, "math_constant", {fields = {CONSTANT = c}}) -- 239
	end -- 236
	Gen.PI = constant("PI") -- 3
	Gen.E = constant("E") -- 3
	Gen.GOLDEN_RATIO = constant("GOLDEN_RATIO") -- 3
	Gen.SQRT2 = constant("SQRT2") -- 3
	Gen.SQRT1_2 = constant("SQRT1_2") -- 3
	Gen.INFINITY = constant("INFINITY") -- 3
	local function arithmetic(op, A, B) -- 248
		return __TS__New(Blk, "math_arithmetic", {fields = {OP = op}, inputs = {A = A, B = B}}) -- 252
	end -- 248
	Gen.Add = function(a, b) return arithmetic("ADD", a, b) end -- 3
	Gen.Sub = function(a, b) return arithmetic("MINUS", a, b) end -- 3
	Gen.Mul = function(a, b) return arithmetic("MULTIPLY", a, b) end -- 3
	Gen.Div = function(a, b) return arithmetic("DIVIDE", a, b) end -- 3
	Gen.Pow = function(a, b) return arithmetic("POWER", a, b) end -- 3
	local function mathSingle(op, n) -- 260
		return __TS__New(Blk, "math_single", {fields = {OP = op}, inputs = {NUM = n}}) -- 265
	end -- 260
	Gen.Root = function(n) return mathSingle("ROOT", n) end -- 3
	Gen.Abs = function(n) return mathSingle("ABS", n) end -- 3
	Gen.Neg = function(n) return mathSingle("NEG", n) end -- 3
	Gen.Ln = function(n) return mathSingle("LN", n) end -- 3
	Gen.Log10 = function(n) return mathSingle("LOG10", n) end -- 3
	Gen.Exp = function(n) return mathSingle("EXP", n) end -- 3
	Gen.Pow10 = function(n) return mathSingle("POW10", n) end -- 3
	local function trig(op, n) -- 275
		return __TS__New(Blk, "math_trig", {fields = {OP = op}, inputs = {NUM = n}}) -- 278
	end -- 275
	Gen.Sin = function(deg) return trig("SIN", deg) end -- 3
	Gen.Cos = function(deg) return trig("COS", deg) end -- 3
	Gen.Tan = function(deg) return trig("TAN", deg) end -- 3
	Gen.Asin = function(deg) return trig("ASIN", deg) end -- 3
	Gen.Acos = function(deg) return trig("ACOS", deg) end -- 3
	Gen.Atan = function(deg) return trig("ATAN", deg) end -- 3
	local function numProp(property, n) -- 287
		return __TS__New(Blk, "math_number_property", {fields = {PROPERTY = property}, extraState = "<mutation divisor_input=\"false\"></mutation>", inputs = {NUMBER_TO_CHECK = n}}) -- 293
	end -- 287
	Gen.IsEven = function(n) return numProp("EVEN", n) end -- 3
	Gen.IsOdd = function(n) return numProp("ODD", n) end -- 3
	Gen.IsPrime = function(n) return numProp("PRIME", n) end -- 3
	Gen.IsWhole = function(n) return numProp("WHOLE", n) end -- 3
	Gen.IsPositive = function(n) return numProp("POSITIVE", n) end -- 3
	Gen.IsNegtive = function(n) return numProp("NEGATIVE", n) end -- 3
	Gen.IsDivisibleBy = function(n, divisor) return __TS__New(Blk, "math_number_property", {fields = {PROPERTY = "DIVISIBLE_BY"}, extraState = "<mutation divisor_input=\"true\"></mutation>", inputs = {NUMBER_TO_CHECK = n, DIVISOR = divisor}}) end -- 3
	local function round(op, n) -- 311
		return __TS__New(Blk, "math_round", {fields = {OP = op}, inputs = {NUM = n}}) -- 314
	end -- 311
	Gen.Round = function(n) return round("ROUND", n) end -- 3
	Gen.RoundUp = function(n) return round("ROUNDUP", n) end -- 3
	Gen.RoundDown = function(n) return round("ROUNDDOWN", n) end -- 3
	Gen.Modulo = function(dividend, divisor) return __TS__New(Blk, "math_modulo", {inputs = {DIVIDEND = dividend, DIVISOR = divisor}}) end -- 3
	local function mathOnList(op, listBlock) -- 323
		return __TS__New(Blk, "math_on_list", {fields = {OP = op}, extraState = ("<mutation op=\"" .. op) .. "\"></mutation>", inputs = {LIST = listBlock}}) -- 329
	end -- 323
	Gen.Sum = function(listBlock) return mathOnList("SUM", listBlock) end -- 3
	Gen.Min = function(listBlock) return mathOnList("MIN", listBlock) end -- 3
	Gen.Max = function(listBlock) return mathOnList("MAX", listBlock) end -- 3
	Gen.Average = function(listBlock) return mathOnList("AVERAGE", listBlock) end -- 3
	Gen.Median = function(listBlock) return mathOnList("MEDIAN", listBlock) end -- 3
	Gen.Mode = function(listBlock) return mathOnList("MODE", listBlock) end -- 3
	Gen.StdDev = function(listBlock) return mathOnList("STD_DEV", listBlock) end -- 3
	Gen.Random = function(listBlock) return mathOnList("RANDOM", listBlock) end -- 3
	Gen.Constrain = function(valueNum, lowNum, highNum) return __TS__New(Blk, "math_constrain", {inputs = {VALUE = valueNum, LOW = lowNum, HIGH = highNum}}) end -- 3
	Gen.RandomInt = function(fromNum, toNum) return __TS__New(Blk, "math_random_int", {inputs = {FROM = fromNum, TO = toNum}}) end -- 3
	Gen.RandomFloat = function() return __TS__New(Blk, "math_random_float") end -- 3
	Gen.Atan2 = function(x, y) return __TS__New(Blk, "math_atan2", {inputs = {X = x, Y = y}}) end -- 3
	Gen.TextJoin = function(...) -- 3
		local texts = {...} -- 3
		local inputMap = {} -- 356
		__TS__ArrayForEach( -- 357
			texts, -- 357
			function(____, b, i) -- 357
				inputMap["ADD" .. tostring(i)] = b -- 358
			end -- 357
		) -- 357
		return __TS__New(Blk, "text_join", {extraState = {itemCount = #texts}, inputs = inputMap}) -- 360
	end -- 355
	Gen.TextAppend = function(varName, what) return __TS__New( -- 3
		Blk, -- 367
		"text_append", -- 367
		{ -- 367
			fields = {VAR = varAccess(varName)}, -- 368
			inputs = {TEXT = what} -- 369
		} -- 369
	) end -- 369
	Gen.TextLength = function(text) return __TS__New(Blk, "text_length", {inputs = {VALUE = text}}) end -- 3
	Gen.IsTextEmpty = function(text) return __TS__New(Blk, "text_isEmpty", {inputs = {VALUE = text}}) end -- 3
	Gen.TextReverse = function(text) return __TS__New(Blk, "text_reverse", {inputs = {TEXT = text}}) end -- 3
	local function textIndexOf(____end, textBlk, findBlk) -- 382
		return __TS__New(Blk, "text_indexOf", {fields = {END = ____end}, inputs = {VALUE = textBlk, FIND = findBlk}}) -- 387
	end -- 382
	Gen.TextFirstIndexOf = function(text, firstFind) return textIndexOf("FIRST", text, firstFind) end -- 3
	Gen.TextLastIndexOf = function(text, lastFind) return textIndexOf("LAST", text, lastFind) end -- 3
	local function charAt(where, textBlk, at) -- 396
		return __TS__New( -- 401
			Blk, -- 401
			"text_charAt", -- 401
			{ -- 401
				extraState = ("<mutation at=\"" .. tostring(where == "FROM_START" or where == "FROM_END")) .. "\"></mutation>", -- 402
				fields = {WHERE = where}, -- 403
				inputs = __TS__ObjectAssign({VALUE = textBlk}, at and ({AT = at}) or ({})) -- 404
			} -- 404
		) -- 404
	end -- 396
	Gen.CharFromStart = function(text, at) return charAt("FROM_START", text, at) end -- 3
	Gen.CharFromEnd = function(text, at) return charAt("FROM_END", text, at) end -- 3
	Gen.FirstChar = function(text) return charAt("FIRST", text) end -- 3
	Gen.LastChar = function(text) return charAt("LAST", text) end -- 3
	Gen.RandomChar = function(text) return charAt("RANDOM", text) end -- 3
	local function substring(where1, where2, textBlk, at1, at2) -- 418
		return __TS__New( -- 423
			Blk, -- 423
			"text_getSubstring", -- 423
			{ -- 423
				extraState = ((("<mutation at1=\"" .. tostring(where1 == "FROM_START" or where1 == "FROM_END")) .. "\" at2=\"") .. tostring(where2 == "FROM_START" or where2 == "FROM_END")) .. "\"></mutation>", -- 424
				fields = {WHERE1 = where1, WHERE2 = where2}, -- 425
				inputs = __TS__ObjectAssign({STRING = textBlk}, at1 and ({AT1 = at1}) or ({}), at2 and ({AT2 = at2}) or ({})) -- 426
			} -- 426
		) -- 426
	end -- 418
	Gen.Substring = function(at1, at2) return substring("FROM_START", at2 and "FROM_START" or "LAST", at1, at2) end -- 3
	local function changeCase(mode, str) -- 436
		return __TS__New(Blk, "text_changeCase", {fields = {CASE = mode}, inputs = {TEXT = str}}) -- 437
	end -- 436
	Gen.UpperCase = function(text) return changeCase("UPPERCASE", text) end -- 3
	Gen.LowerCase = function(text) return changeCase("LOWERCASE", text) end -- 3
	Gen.TitleCase = function(text) return changeCase("TITLECASE", text) end -- 3
	local function trim(mode, str) -- 447
		return __TS__New(Blk, "text_trim", {fields = {MODE = mode}, inputs = {TEXT = str}}) -- 448
	end -- 447
	Gen.TrimLeft = function(text) return trim("LEFT", text) end -- 3
	Gen.TrimRight = function(text) return trim("RIGHT", text) end -- 3
	Gen.Trim = function(text) return trim("BOTH", text) end -- 3
	Gen.TextCount = function(subText, text) return __TS__New(Blk, "text_count", {inputs = {SUB = subText, TEXT = text}}) end -- 3
	Gen.TextReplace = function(text, fromText, toText) return __TS__New(Blk, "text_replace", {inputs = {TEXT = text, FROM = fromText, TO = toText}}) end -- 3
	Gen.RepeatList = function(item, times) return __TS__New(Blk, "lists_repeat", {inputs = {ITEM = item, NUM = times}}) end -- 3
	Gen.ListLength = function(list) return __TS__New(Blk, "lists_length", {inputs = {VALUE = list}}) end -- 3
	Gen.IsListEmpty = function(list) return __TS__New(Blk, "lists_isEmpty", {inputs = {VALUE = list}}) end -- 3
	local function indexOf(list, findItem, which) -- 480
		return __TS__New(Blk, "lists_indexOf", {fields = {END = which}, inputs = {VALUE = list, FIND = findItem}}) -- 485
	end -- 480
	Gen.FirstIndexOf = function(list, findItem) return indexOf(list, findItem, "FIRST") end -- 3
	Gen.LastIndexOf = function(list, findItem) return indexOf(list, findItem, "FIRST") end -- 3
	local function listGetIndex(mode, where, listExpr, at) -- 501
		return __TS__New( -- 507
			Blk, -- 507
			"lists_getIndex", -- 507
			{ -- 507
				fields = {MODE = mode, WHERE = where}, -- 508
				inputs = __TS__ObjectAssign({VALUE = listExpr}, at and ({AT = at}) or ({})), -- 509
				extraState = {isStatement = mode == "REMOVE"} -- 513
			} -- 513
		) -- 513
	end -- 501
	Gen.ListGet = function(list, at) return listGetIndex("GET", "FROM_START", list, at) end -- 3
	Gen.ListRemoveGet = function(list, at) return listGetIndex("GET_REMOVE", "FROM_START", list, at) end -- 3
	Gen.ListRemove = function(list, at) return listGetIndex("REMOVE", "FROM_START", list, at) end -- 3
	Gen.ListRemoveLast = function(list) return listGetIndex("GET_REMOVE", "LAST", list) end -- 3
	Gen.ListRemoveFirst = function(list) return listGetIndex("GET_REMOVE", "FIRST", list) end -- 3
	local function subList(listExpr, where1, where2, at1, at2) -- 522
		return __TS__New(Blk, "lists_getSublist", {fields = {WHERE1 = where1, WHERE2 = where2}, inputs = at2 and ({LIST = listExpr, AT1 = at1, AT2 = at2}) or ({LIST = listExpr, AT1 = at1})}) -- 529
	end -- 522
	Gen.SubList = function(list, at1, at2) return subList( -- 3
		list, -- 535
		"FROM_START", -- 535
		at2 and "FROM_START" or "LAST", -- 535
		at1, -- 535
		at2 -- 535
	) end -- 535
	local function listSplit(input, delim, mode) -- 537
		return __TS__New(Blk, "lists_split", {fields = {MODE = mode}, inputs = {INPUT = input, DELIM = delim}}) -- 542
	end -- 537
	Gen.ListSplit = function(inputText, delimText) return listSplit(inputText, delimText, "SPLIT") end -- 3
	Gen.ListJoin = function(list, delimText) return listSplit(list, delimText, "JOIN") end -- 3
	local function listSort(listExpr, ____type, direction) -- 550
		return __TS__New(Blk, "lists_sort", {fields = {TYPE = ____type, DIRECTION = direction}, inputs = {LIST = listExpr}}) -- 555
	end -- 550
	Gen.ListSort = function(list, desc) return listSort(list, "NUMERIC", desc and "-1" or "1") end -- 3
	Gen.ListReverse = function(list) return __TS__New(Blk, "lists_reverse", {inputs = {LIST = list}}) end -- 3
	local function listSetIndex(mode, listExpr, at, to, where) -- 565
		return __TS__New(Blk, "lists_setIndex", {fields = {MODE = mode, WHERE = where}, inputs = {LIST = listExpr, AT = at, TO = to}}) -- 572
	end -- 565
	Gen.ListSet = function(list, at, item) return listSetIndex( -- 3
		"SET", -- 577
		list, -- 577
		at, -- 577
		item, -- 577
		"FROM_START" -- 577
	) end -- 577
	Gen.ListInsert = function(list, at, item) return listSetIndex( -- 3
		"INSERT", -- 578
		list, -- 578
		at, -- 578
		item, -- 578
		"FROM_START" -- 578
	) end -- 578
	Gen.Dict = function() return __TS__New(Blk, "dict_create") end -- 3
	Gen.DictGet = function(dict, key) return __TS__New(Blk, "dict_get", {inputs = {DICT = dict, KEY = key}}) end -- 3
	Gen.DictSet = function(dict, key, val) return __TS__New(Blk, "dict_set", {inputs = {DICT = dict, KEY = key, VALUE = val}}) end -- 3
	Gen.DictContain = function(dict, key) return __TS__New(Blk, "dict_has_key", {inputs = {DICT = dict, KEY = key}}) end -- 3
	Gen.DictRemove = function(dict, key) return __TS__New(Blk, "dict_remove_key", {inputs = {DICT = dict, KEY = key}}) end -- 3
	Gen.VarSet = function(name, value) return __TS__New( -- 3
		Blk, -- 595
		"variables_set", -- 595
		{ -- 595
			fields = {VAR = varAccess(name)}, -- 596
			inputs = {VALUE = value} -- 597
		} -- 597
	) end -- 597
	Gen.VarAdd = function(name, deltaNum) return __TS__New( -- 3
		Blk, -- 601
		"math_change", -- 601
		{ -- 601
			fields = {VAR = varAccess(name)}, -- 602
			inputs = {DELTA = deltaNum} -- 603
		} -- 603
	) end -- 603
	Gen.ProcIfReturn = function(cond, value) return __TS__New( -- 3
		Blk, -- 610
		"procedures_ifreturn", -- 610
		{ -- 610
			extraState = ("<mutation value=\"" .. tostring(value and 1 or 0)) .. "\"></mutation>", -- 611
			inputs = value and ({CONDITION = cond, VALUE = value}) or ({CONDITION = cond}) -- 612
		} -- 612
	) end -- 612
	local function buildParams(names) -- 617
		return __TS__ArrayMap( -- 618
			names, -- 618
			function(____, p) return { -- 618
				name = p, -- 618
				id = IdFactory:next("arg") -- 618
			} end -- 618
		) -- 618
	end -- 617
	Gen.DefProcReturn = function(name, params, body, returnExpr) return __TS__New( -- 3
		Blk, -- 626
		"procedures_defreturn", -- 626
		{ -- 626
			fields = {NAME = name}, -- 627
			inputs = {STACK = body, RETURN = returnExpr}, -- 628
			extraState = {params = buildParams(params)} -- 629
		} -- 629
	) end -- 629
	Gen.DefProc = function(name, params, body) return __TS__New( -- 3
		Blk, -- 637
		"procedures_defnoreturn", -- 637
		{ -- 637
			fields = {NAME = name}, -- 638
			inputs = {STACK = body}, -- 639
			extraState = {params = buildParams(params)} -- 640
		} -- 640
	) end -- 640
	Gen.CallProc = function(procName, ...) -- 3
		local args = {...} -- 3
		local inputMap = {} -- 644
		__TS__ArrayForEach( -- 645
			args, -- 645
			function(____, value, i) -- 645
				inputMap["ARG" .. tostring(i)] = value -- 646
			end -- 645
		) -- 645
		return __TS__New(Blk, "procedures_callnoreturn", {extraState = {name = procName, params = nil}, inputs = inputMap}) -- 648
	end -- 643
	Gen.CallProcReturn = function(procName, ...) -- 3
		local args = {...} -- 3
		local inputMap = {} -- 655
		__TS__ArrayForEach( -- 656
			args, -- 656
			function(____, value, i) -- 656
				inputMap["ARG" .. tostring(i)] = value -- 657
			end -- 656
		) -- 656
		return __TS__New(Blk, "procedures_callreturn", {extraState = {name = procName, params = nil}, inputs = inputMap}) -- 659
	end -- 654
	Gen.Vec2Zero = function() return __TS__New(Blk, "vec2_zero") end -- 3
	Gen.Vec2 = function(x, y) return __TS__New(Blk, "vec2_create", {inputs = {X = x, Y = y}}) end -- 3
	local function vec2Prop(vecVar, prop) -- 671
		return __TS__New( -- 672
			Blk, -- 672
			"vec2_get_property", -- 672
			{fields = { -- 672
				VEC2 = varAccess(vecVar), -- 673
				PROPERTY = prop -- 673
			}} -- 673
		) -- 673
	end -- 671
	Gen.Vec2X = function(varName) return vec2Prop(varName, "x") end -- 3
	Gen.Vec2Y = function(varName) return vec2Prop(varName, "y") end -- 3
	Gen.Vec2Length = function(varName) return vec2Prop(varName, "length") end -- 3
	Gen.Vec2Angle = function(varName) return vec2Prop(varName, "angle") end -- 3
	Gen.Vec2Normalize = function(v) return __TS__New(Blk, "vec2_get_normalized", {inputs = {VEC2 = v}}) end -- 3
	local function vec2VecOp(op, a, b) -- 684
		return __TS__New(Blk, "vec2_binary_operation", {fields = {OPERATION = op}, inputs = {VEC2_1 = a, VEC2_2 = b}}) -- 685
	end -- 684
	Gen.Vec2Add = function(a, b) return vec2VecOp("+", a, b) end -- 3
	Gen.Vec2Sub = function(a, b) return vec2VecOp("-", a, b) end -- 3
	Gen.Vec2MulVec = function(a, b) return vec2VecOp("*", a, b) end -- 3
	Gen.Vec2DivVec = function(a, b) return vec2VecOp("/", a, b) end -- 3
	Gen.Vec2Distance = function(a, b) return vec2Calc("distance", a, b) end -- 3
	Gen.Vec2Dot = function(a, b) return vec2Calc("dot", a, b) end -- 3
	local function vec2NumOp(op, v, n) -- 697
		return __TS__New(Blk, "vec2_binary_op_number", {fields = {OPERATION = op}, inputs = {VEC2 = v, NUMBER = n}}) -- 698
	end -- 697
	Gen.Vec2MulNum = function(v, n) return vec2NumOp("*", v, n) end -- 3
	Gen.Vec2DivNum = function(v, n) return vec2NumOp("/", v, n) end -- 3
	Gen.Vec2Clamp = function(v, min, max) return __TS__New(Blk, "vec2_clamp", {inputs = {VEC2 = v, MIN = min, MAX = max}}) end -- 3
	vec2Calc = function(what, a, b) return __TS__New(Blk, "vec2_calculate", {fields = {CALCULATE = what}, inputs = {VEC2_1 = a, VEC2_2 = b}}) end -- 715
	Gen.CreateNode = function() return __TS__New(Blk, "node_create") end -- 3
	Gen.CreateSprite = function(file) return __TS__New(Blk, "sprite_create", {inputs = {FILE = file}}) end -- 3
	Gen.CreateLabel = function(fontName, size) return __TS__New(Blk, "label_create", {inputs = {FONT = fontName, SIZE = size}}) end -- 3
	Gen.LabelSetText = function(varName, text) return __TS__New( -- 3
		Blk, -- 734
		"label_set_text", -- 734
		{ -- 734
			fields = {LABEL = varAccess(varName)}, -- 735
			inputs = {TEXT = text} -- 736
		} -- 736
	) end -- 736
	Gen.NodeAddChild = function(parentVar, childVar, order) return __TS__New( -- 3
		Blk, -- 740
		"node_add_child", -- 740
		{ -- 740
			fields = { -- 741
				PARENT = varAccess(parentVar), -- 741
				CHILD = varAccess(childVar) -- 741
			}, -- 741
			inputs = {ORDER = order} -- 742
		} -- 742
	) end -- 742
	local function nodeSetNumAttr(varName, attr, value) -- 746
		return __TS__New( -- 747
			Blk, -- 747
			"node_set_number_attribute", -- 747
			{ -- 747
				fields = { -- 748
					NODE = varAccess(varName), -- 748
					ATTRIBUTE = attr -- 748
				}, -- 748
				inputs = {VALUE = value} -- 749
			} -- 749
		) -- 749
	end -- 746
	Gen.NodeSetX = function(varName, n) return nodeSetNumAttr(varName, "x", n) end -- 3
	Gen.NodeSetY = function(varName, n) return nodeSetNumAttr(varName, "y", n) end -- 3
	Gen.NodeSetWidth = function(varName, n) return nodeSetNumAttr(varName, "width", n) end -- 3
	Gen.NodeSetHeight = function(varName, n) return nodeSetNumAttr(varName, "height", n) end -- 3
	Gen.NodeSetAngle = function(varName, n) return nodeSetNumAttr(varName, "angle", n) end -- 3
	Gen.NodeSetScale = function(varName, n) return nodeSetNumAttr(varName, "scale", n) end -- 3
	Gen.NodeSetScaleX = function(varName, n) return nodeSetNumAttr(varName, "scaleX", n) end -- 3
	Gen.NodeSetScaleY = function(varName, n) return nodeSetNumAttr(varName, "scaleY", n) end -- 3
	Gen.NodeSetOpactity = function(varName, n) return nodeSetNumAttr(varName, "opacity", n) end -- 3
	local function nodeGetNumAttr(varName, attr) -- 761
		return __TS__New( -- 762
			Blk, -- 762
			"node_get_number_attribute", -- 762
			{fields = { -- 762
				NODE = varAccess(varName), -- 763
				ATTRIBUTE = attr -- 763
			}} -- 763
		) -- 763
	end -- 761
	Gen.NodeGetX = function(varName) return nodeGetNumAttr(varName, "x") end -- 3
	Gen.NodeGetY = function(varName) return nodeGetNumAttr(varName, "y") end -- 3
	Gen.NodeGetWidth = function(varName) return nodeGetNumAttr(varName, "width") end -- 3
	Gen.NodeGetHeight = function(varName) return nodeGetNumAttr(varName, "height") end -- 3
	Gen.NodeGetAngle = function(varName) return nodeGetNumAttr(varName, "angle") end -- 3
	Gen.NodeGetScale = function(varName) return nodeGetNumAttr(varName, "scale") end -- 3
	Gen.NodeGetScaleX = function(varName) return nodeGetNumAttr(varName, "scaleX") end -- 3
	Gen.NodeGetScaleY = function(varName) return nodeGetNumAttr(varName, "scaleY") end -- 3
	Gen.NodeGetOpactity = function(varName) return nodeGetNumAttr(varName, "opacity") end -- 3
	local function nodeSetBoolAttr(nodeVar, attr, value) -- 777
		return __TS__New( -- 778
			Blk, -- 778
			"node_set_boolean_attribute", -- 778
			{ -- 778
				fields = { -- 779
					NODE = varAccess(nodeVar), -- 779
					ATTRIBUTE = attr -- 779
				}, -- 779
				inputs = {VALUE = value} -- 780
			} -- 780
		) -- 780
	end -- 777
	Gen.NodeSetVisible = function(varName, bool) return nodeSetBoolAttr(varName, "visible", bool) end -- 3
	local function nodeGetBoolAttr(varName, attr) -- 785
		return __TS__New( -- 786
			Blk, -- 786
			"node_get_boolean_attribute", -- 786
			{fields = { -- 786
				NODE = varAccess(varName), -- 787
				ATTRIBUTE = attr -- 787
			}} -- 787
		) -- 787
	end -- 785
	Gen.NodeGetVisible = function(varName) return nodeGetBoolAttr(varName, "visible") end -- 3
	local function nodeSetVec2Attr(varName, attr, vec) -- 793
		return __TS__New( -- 794
			Blk, -- 794
			"node_set_vec2_attribute", -- 794
			{ -- 794
				fields = { -- 795
					NODE = varAccess(varName), -- 795
					ATTRIBUTE = attr -- 795
				}, -- 795
				inputs = {VEC2 = vec} -- 796
			} -- 796
		) -- 796
	end -- 793
	Gen.NodeSetPosition = function(varName, vec) return nodeSetVec2Attr(varName, "position", vec) end -- 3
	Gen.NodeSetAnchor = function(varName, vec) return nodeSetVec2Attr(varName, "anchor", vec) end -- 3
	local function nodeGetVec2Attr(nodeVar, attr) -- 802
		return __TS__New( -- 803
			Blk, -- 803
			"node_get_vec2_attribute", -- 803
			{fields = { -- 803
				NODE = varAccess(nodeVar), -- 804
				ATTRIBUTE = attr -- 804
			}} -- 804
		) -- 804
	end -- 802
	Gen.NodeGetPosition = function(varName) return nodeGetVec2Attr(varName, "position") end -- 3
	Gen.NodeGetAnchor = function(varName) return nodeGetVec2Attr(varName, "anchor") end -- 3
	Gen.BeginPaint = function(nodeVar, paintBody) return __TS__New( -- 3
		Blk, -- 811
		"nvg_begin_painting", -- 811
		{ -- 811
			fields = {NODE = varAccess(nodeVar)}, -- 812
			inputs = {PAINT = paintBody} -- 813
		} -- 813
	) end -- 813
	Gen.BeginPath = function() return __TS__New(Blk, "nvg_begin_path") end -- 3
	Gen.MoveTo = function(x, y) return __TS__New(Blk, "nvg_move_to", {inputs = {X = x, Y = y}}) end -- 3
	Gen.BezierTo = function(c1x, c1y, c2x, c2y, x, y) return __TS__New(Blk, "nvg_bezier_to", {inputs = { -- 3
		C1X = c1x, -- 827
		C1Y = c1y, -- 827
		C2X = c2x, -- 827
		C2Y = c2y, -- 827
		X = x, -- 827
		Y = y -- 827
	}}) end -- 827
	Gen.LineTo = function(x, y) return __TS__New(Blk, "nvg_line_to", {inputs = {X = x, Y = y}}) end -- 3
	Gen.ClosePath = function() return __TS__New(Blk, "nvg_close_path") end -- 3
	Gen.FillColor = function(color, opacity) return __TS__New(Blk, "nvg_fill_color", {inputs = {COLOR = color, OPACITY = opacity}}) end -- 3
	Gen.Fill = function() return __TS__New(Blk, "nvg_fill") end -- 3
	Gen.StrokeColor = function(color, opacity) return __TS__New(Blk, "nvg_stroke_color", {inputs = {COLOR = color, OPACITY = opacity}}) end -- 3
	Gen.StrokeWidth = function(w) return __TS__New(Blk, "nvg_stroke_width", {inputs = {WIDTH = w}}) end -- 3
	Gen.Stroke = function() return __TS__New(Blk, "nvg_stroke") end -- 3
	Gen.Rect = function(x, y, w, h) return __TS__New(Blk, "nvg_rect", {inputs = {X = x, Y = y, WIDTH = w, HEIGHT = h}}) end -- 3
	Gen.RoundedRect = function(x, y, w, h, r) return __TS__New(Blk, "nvg_rounded_rect", {inputs = { -- 3
		X = x, -- 859
		Y = y, -- 859
		WIDTH = w, -- 859
		HEIGHT = h, -- 859
		RADIUS = r -- 859
	}}) end -- 859
	Gen.Ellipse = function(cx, cy, rx, ry) return __TS__New(Blk, "nvg_ellipse", {inputs = {CX = cx, CY = cy, RX = rx, RY = ry}}) end -- 3
	Gen.Circle = function(cx, cy, radius) return __TS__New(Blk, "nvg_circle", {inputs = {CX = cx, CY = cy, RADIUS = radius}}) end -- 3
	Gen.Color = function(hex) return __TS__New(Blk, "colour_hsv_sliders", {fields = {COLOUR = hex}}) end -- 3
	Gen.OnUpdate = function(nodeVar, dtVar, actionBody) return __TS__New( -- 3
		Blk, -- 882
		"on_update", -- 882
		{ -- 882
			fields = { -- 883
				NODE = varAccess(nodeVar), -- 883
				DELTA_TIME = varAccess(dtVar) -- 883
			}, -- 883
			inputs = {ACTION = actionBody} -- 884
		} -- 884
	) end -- 884
	Gen.OnTapEvent = function(nodeVar, event, touchVar, actionBody) return __TS__New( -- 3
		Blk, -- 894
		"on_tap_event", -- 894
		{ -- 894
			fields = { -- 895
				NODE = varAccess(nodeVar), -- 896
				EVENT = event, -- 897
				TOUCH = varAccess(touchVar) -- 898
			}, -- 898
			inputs = {ACTION = actionBody} -- 900
		} -- 900
	) end -- 900
	Gen.CheckKey = function(key, state) return __TS__New(Blk, "check_key", {fields = {KEY = key, KEY_STATE = state}}) end -- 3
	local function touchNumAttr(touchId, attr) -- 1014
		return __TS__New( -- 1015
			Blk, -- 1015
			"get_touch_number_attribute", -- 1015
			{fields = { -- 1015
				TOUCH = varAccess(touchId), -- 1016
				ATTRIBUTE = attr -- 1016
			}} -- 1016
		) -- 1016
	end -- 1014
	Gen.TouchGetId = function(touchVar) return touchNumAttr(touchVar, "id") end -- 3
	local function touchVec2Attr(touchId, attr) -- 1021
		return __TS__New( -- 1022
			Blk, -- 1022
			"get_touch_vec2_attribute", -- 1022
			{fields = { -- 1022
				TOUCH = varAccess(touchId), -- 1023
				ATTRIBUTE = attr -- 1023
			}} -- 1023
		) -- 1023
	end -- 1021
	Gen.TouchGetLocation = function(touchVar) return touchVec2Attr(touchVar, "location") end -- 3
	Gen.TouchGetWorldLocation = function(touchVar) return touchVec2Attr(touchVar, "worldLocation") end -- 3
	Gen.toBlocklyJSON = function(root, procs) -- 3
		local vars = __TS__ArrayMap( -- 1030
			__TS__ArrayFrom(collectVariables(root)), -- 1030
			function(____, n) return {name = n, id = n} end -- 1030
		) -- 1030
		for ____, ____value in __TS__Iterator(varMap:entries()) do -- 1031
			local _ = ____value[1] -- 1031
			local v = ____value[2] -- 1031
			vars[#vars + 1] = v -- 1032
		end -- 1032
		if procs then -- 1032
			fixProcParamNames(root, procs) -- 1035
			for ____, proc in ipairs(procs) do -- 1036
				fixProcParamNames(proc, procs) -- 1037
				local procVars = __TS__ArrayMap( -- 1038
					__TS__ArrayFrom(collectVariables(proc)), -- 1038
					function(____, n) return {name = n, id = n} end -- 1038
				) -- 1038
				vars = __TS__ArrayConcat(vars, procVars) -- 1039
			end -- 1039
		end -- 1039
		local finalVars = {} -- 1042
		local tmp = __TS__New(Set) -- 1043
		for ____, v in ipairs(vars) do -- 1044
			if not tmp:has(v.id) then -- 1044
				tmp:add(v.id) -- 1046
				finalVars[#finalVars + 1] = v -- 1047
			end -- 1047
		end -- 1047
		vars = finalVars -- 1050
		varMap = __TS__New(Map) -- 1051
		local ____opt_11 = procs -- 1051
		local procBlocks = ____opt_11 and __TS__ArrayMap( -- 1052
			procs, -- 1052
			function(____, proc, i) -- 1052
				local j = proc:toJSON() -- 1053
				j.x = (i + 1) * 500 -- 1054
				return j -- 1055
			end -- 1052
		) or ({}) -- 1052
		return { -- 1057
			blocks = { -- 1058
				languageVersion = 0, -- 1059
				blocks = { -- 1060
					root:toJSON(), -- 1060
					table.unpack(procBlocks) -- 1060
				} -- 1060
			}, -- 1060
			variables = vars -- 1062
		} -- 1062
	end -- 1029
	local root = Gen.Block( -- 1066
		Gen.IfElse( -- 1067
			Gen.If( -- 1068
				Gen.Bool(false), -- 1068
				Gen.Print(Gen.Text()) -- 1068
			), -- 1068
			Gen.If( -- 1069
				Gen.Bool(true), -- 1069
				Gen.Print(Gen.Text()) -- 1069
			), -- 1069
			Gen.Else(Gen.Block( -- 1070
				Gen.Print(Gen.Text("a")), -- 1071
				Gen.Print(Gen.Text("b")) -- 1072
			)) -- 1072
		), -- 1072
		Gen.Declare( -- 1075
			"temp", -- 1075
			Gen.List( -- 1075
				Gen.Eq( -- 1076
					Gen.Bool(true), -- 1076
					Gen.Bool(true) -- 1076
				), -- 1076
				Gen.Neq( -- 1077
					Gen.Bool(true), -- 1077
					Gen.Bool(false) -- 1077
				), -- 1077
				Gen.Lt( -- 1078
					Gen.Num(1), -- 1078
					Gen.Num(2) -- 1078
				), -- 1078
				Gen.Gt( -- 1079
					Gen.Num(2), -- 1079
					Gen.Num(1) -- 1079
				), -- 1079
				Gen.Gte( -- 1080
					Gen.Num(4), -- 1080
					Gen.Num(3) -- 1080
				), -- 1080
				Gen.Not(Gen.Bool(false)), -- 1081
				Gen.And( -- 1082
					Gen.Bool(true), -- 1082
					Gen.Bool(true) -- 1082
				), -- 1082
				Gen.Or( -- 1083
					Gen.Bool(true), -- 1083
					Gen.Bool(false) -- 1083
				) -- 1083
			) -- 1083
		), -- 1083
		Gen.VarSet( -- 1085
			"temp", -- 1085
			Gen.Ternary( -- 1085
				Gen.Bool(true), -- 1085
				Gen.Num(1), -- 1085
				Gen.Num(2) -- 1085
			) -- 1085
		), -- 1085
		Gen.Repeat( -- 1086
			Gen.Num(10), -- 1086
			Gen.Block( -- 1087
				Gen.Print(Gen.Num(123)), -- 1088
				Gen.Print(Gen.Text("abc")) -- 1089
			) -- 1089
		), -- 1089
		Gen.While( -- 1092
			Gen.Bool(true), -- 1092
			Gen.Print(Gen.Num(123)) -- 1093
		), -- 1093
		Gen.For( -- 1095
			"i", -- 1095
			Gen.Num(1), -- 1096
			Gen.Num(10), -- 1096
			Gen.Num(1), -- 1096
			Gen.Print(Gen.Num(123)) -- 1097
		), -- 1097
		Gen.ForEach( -- 1099
			"j", -- 1099
			Gen.VarGet("temp"), -- 1100
			Gen.Block( -- 1101
				Gen.Print(Gen.Num(123)), -- 1102
				Gen.Break() -- 1103
			) -- 1103
		), -- 1103
		Gen.Print(Gen.List( -- 1106
			Gen.Num(123), -- 1108
			Gen.Add( -- 1109
				Gen.Num(1), -- 1109
				Gen.Num(2) -- 1109
			), -- 1109
			Gen.Sub( -- 1110
				Gen.Num(5), -- 1110
				Gen.Num(3) -- 1110
			), -- 1110
			Gen.Mul( -- 1111
				Gen.Num(2), -- 1111
				Gen.Num(4) -- 1111
			), -- 1111
			Gen.Div( -- 1112
				Gen.Num(9), -- 1112
				Gen.Num(3) -- 1112
			), -- 1112
			Gen.Pow( -- 1113
				Gen.Num(2), -- 1113
				Gen.Num(10) -- 1113
			), -- 1113
			Gen.Root(Gen.Num(9)), -- 1114
			Gen.Cos(Gen.Num(45)), -- 1115
			Gen.PI, -- 3
			Gen.IsEven(Gen.Num(6)), -- 1117
			Gen.RoundUp(Gen.Num(3.14)), -- 1118
			Gen.Modulo( -- 1119
				Gen.Num(7), -- 1119
				Gen.Num(3) -- 1119
			), -- 1119
			Gen.Sum(Gen.List()), -- 1120
			Gen.Constrain( -- 1121
				Gen.Num(50), -- 1121
				Gen.Num(1), -- 1121
				Gen.Num(100) -- 1121
			), -- 1121
			Gen.RandomInt( -- 1122
				Gen.Num(1), -- 1122
				Gen.Num(10) -- 1122
			), -- 1122
			Gen.RandomFloat(), -- 1123
			Gen.Atan2( -- 1124
				Gen.Num(1), -- 1124
				Gen.Num(1) -- 1124
			), -- 1124
			Gen.IsDivisibleBy( -- 1125
				Gen.Num(10), -- 1125
				Gen.Num(3) -- 1125
			) -- 1125
		)), -- 1125
		Gen.Print(Gen.TextJoin( -- 1128
			Gen.Text("aa"), -- 1128
			Gen.Text("bb") -- 1128
		)), -- 1128
		Gen.Print(Gen.List( -- 1129
			Gen.TextLength(Gen.Text("xyz")), -- 1130
			Gen.IsTextEmpty(Gen.Text("")), -- 1131
			Gen.TextFirstIndexOf( -- 1132
				Gen.VarGet("temp"), -- 1132
				Gen.Text("a") -- 1132
			), -- 1132
			Gen.TextLastIndexOf( -- 1133
				Gen.VarGet("temp"), -- 1133
				Gen.Text("b") -- 1133
			), -- 1133
			Gen.CharFromStart( -- 1134
				Gen.VarGet("temp"), -- 1134
				Gen.Num(1) -- 1134
			), -- 1134
			Gen.CharFromEnd( -- 1135
				Gen.VarGet("temp"), -- 1135
				Gen.Num(123) -- 1135
			), -- 1135
			Gen.FirstChar(Gen.VarGet("temp")), -- 1136
			Gen.LastChar(Gen.VarGet("temp")), -- 1137
			Gen.RandomChar(Gen.VarGet("temp")) -- 1138
		)), -- 1138
		Gen.Print(Gen.List( -- 1140
			Gen.RepeatList( -- 1141
				Gen.VarGet("temp"), -- 1141
				Gen.Num(5) -- 1141
			), -- 1141
			Gen.ListLength(Gen.VarGet("temp")), -- 1142
			Gen.IsListEmpty(Gen.VarGet("temp")), -- 1143
			Gen.FirstIndexOf( -- 1144
				Gen.VarGet("temp"), -- 1144
				Gen.Num(123) -- 1144
			), -- 1144
			Gen.LastIndexOf( -- 1145
				Gen.VarGet("temp"), -- 1145
				Gen.Num(123) -- 1145
			), -- 1145
			Gen.ListGet( -- 1146
				Gen.VarGet("temp"), -- 1146
				Gen.Num(1) -- 1146
			), -- 1146
			Gen.ListRemoveGet( -- 1147
				Gen.VarGet("temp"), -- 1147
				Gen.Num(1) -- 1147
			), -- 1147
			Gen.SubList( -- 1148
				Gen.VarGet("temp"), -- 1148
				Gen.Num(1), -- 1148
				Gen.Num(4) -- 1148
			), -- 1148
			Gen.ListSplit( -- 1149
				Gen.Text("a,b,c,d"), -- 1149
				Gen.Text(",") -- 1149
			), -- 1149
			Gen.ListJoin( -- 1150
				Gen.List( -- 1150
					Gen.Text("a"), -- 1150
					Gen.Text("b"), -- 1150
					Gen.Text("c") -- 1150
				), -- 1150
				Gen.Text(",") -- 1150
			), -- 1150
			Gen.ListSort(Gen.VarGet("temp")), -- 1151
			Gen.ListSort( -- 1152
				Gen.VarGet("temp"), -- 1152
				true -- 1152
			), -- 1152
			Gen.ListReverse(Gen.VarGet("temp")) -- 1153
		)), -- 1153
		Gen.Print(Gen.List( -- 1155
			Gen.Dict(), -- 1156
			Gen.DictGet( -- 1157
				Gen.VarGet("temp"), -- 1157
				Gen.Text("key") -- 1157
			), -- 1157
			Gen.DictContain( -- 1158
				Gen.VarGet("temp"), -- 1158
				Gen.Text("key") -- 1158
			) -- 1158
		)), -- 1158
		Gen.DictSet( -- 1160
			Gen.VarGet("temp"), -- 1160
			Gen.Text("key"), -- 1160
			Gen.Text("value") -- 1160
		), -- 1160
		Gen.DictRemove( -- 1161
			Gen.VarGet("temp"), -- 1161
			Gen.Text("key") -- 1161
		), -- 1161
		Gen.VarSet( -- 1162
			"j", -- 1162
			Gen.CallProcReturn( -- 1162
				"func2", -- 1162
				Gen.Text("sub"), -- 1162
				Gen.Num(123), -- 1162
				Gen.Num(456) -- 1162
			) -- 1162
		), -- 1162
		Gen.VarAdd( -- 1163
			"j", -- 1163
			Gen.Num(1234) -- 1163
		), -- 1163
		Gen.CallProc( -- 1164
			"func1", -- 1164
			Gen.Num(100) -- 1164
		), -- 1164
		Gen.Print(Gen.List( -- 1165
			Gen.Vec2Zero(), -- 1166
			Gen.Vec2( -- 1167
				Gen.Num(123), -- 1167
				Gen.Num(456) -- 1167
			), -- 1167
			Gen.Vec2X("temp"), -- 1168
			Gen.Vec2Y("temp"), -- 1169
			Gen.Vec2Length("temp"), -- 1170
			Gen.Vec2Angle("temp"), -- 1171
			Gen.Vec2Normalize(Gen.VarGet("temp")) -- 1172
		)), -- 1172
		Gen.Print(Gen.List( -- 1174
			Gen.Vec2Add( -- 1175
				Gen.Vec2( -- 1175
					Gen.Num(123), -- 1175
					Gen.Num(123) -- 1175
				), -- 1175
				Gen.Vec2( -- 1175
					Gen.Num(123), -- 1175
					Gen.Num(123) -- 1175
				) -- 1175
			), -- 1175
			Gen.Vec2MulNum( -- 1176
				Gen.Vec2( -- 1176
					Gen.Num(123), -- 1176
					Gen.Num(123) -- 1176
				), -- 1176
				Gen.Num(2) -- 1176
			), -- 1176
			Gen.Vec2Clamp( -- 1177
				Gen.Vec2( -- 1177
					Gen.Num(123), -- 1177
					Gen.Num(123) -- 1177
				), -- 1177
				Gen.Vec2( -- 1177
					Gen.Num(1), -- 1177
					Gen.Num(1) -- 1177
				), -- 1177
				Gen.Vec2( -- 1177
					Gen.Num(20), -- 1177
					Gen.Num(20) -- 1177
				) -- 1177
			), -- 1177
			Gen.Vec2Distance( -- 1178
				Gen.Vec2( -- 1178
					Gen.Num(0), -- 1178
					Gen.Num(0) -- 1178
				), -- 1178
				Gen.Vec2( -- 1178
					Gen.Num(123), -- 1178
					Gen.Num(123) -- 1178
				) -- 1178
			), -- 1178
			Gen.Vec2Dot( -- 1179
				Gen.Vec2( -- 1179
					Gen.Num(123), -- 1179
					Gen.Num(123) -- 1179
				), -- 1179
				Gen.Vec2( -- 1179
					Gen.Num(123), -- 1179
					Gen.Num(123) -- 1179
				) -- 1179
			) -- 1179
		)), -- 1179
		Gen.Declare( -- 1181
			"sub", -- 1181
			Gen.CreateNode() -- 1181
		), -- 1181
		Gen.VarSet( -- 1182
			"temp", -- 1182
			Gen.CreateSprite(Gen.Text("Image/logo.png")) -- 1182
		), -- 1182
		Gen.Declare( -- 1183
			"temp1", -- 1183
			Gen.CreateLabel( -- 1183
				Gen.Text("sarasa-mono-sc-regular"), -- 1183
				Gen.Num(16) -- 1183
			) -- 1183
		), -- 1183
		Gen.LabelSetText( -- 1184
			"temp1", -- 1184
			Gen.Text("Hello World") -- 1184
		), -- 1184
		Gen.NodeAddChild( -- 1185
			"temp", -- 1185
			"sub", -- 1185
			Gen.Num(123) -- 1185
		), -- 1185
		Gen.NodeSetX( -- 1186
			"sub", -- 1186
			Gen.NodeGetX("temp1") -- 1186
		), -- 1186
		Gen.NodeSetPosition( -- 1187
			"temp1", -- 1187
			Gen.Vec2( -- 1187
				Gen.Num(0), -- 1187
				Gen.Num(0) -- 1187
			) -- 1187
		), -- 1187
		Gen.Declare( -- 1188
			"draw", -- 1188
			Gen.CreateNode() -- 1188
		), -- 1188
		Gen.BeginPaint( -- 1189
			"draw", -- 1189
			Gen.Block( -- 1189
				Gen.BeginPath(), -- 1190
				Gen.MoveTo( -- 1191
					Gen.Num(0), -- 1191
					Gen.Num(0) -- 1191
				), -- 1191
				Gen.BezierTo( -- 1192
					Gen.Num(0), -- 1193
					Gen.Num(0), -- 1193
					Gen.Num(0), -- 1194
					Gen.Num(100), -- 1194
					Gen.Num(100), -- 1195
					Gen.Num(100) -- 1195
				), -- 1195
				Gen.LineTo( -- 1197
					Gen.Num(100), -- 1197
					Gen.Num(100) -- 1197
				), -- 1197
				Gen.LineTo( -- 1198
					Gen.Num(100), -- 1198
					Gen.Num(-100) -- 1198
				), -- 1198
				Gen.ClosePath(), -- 1199
				Gen.FillColor( -- 1200
					Gen.Color("#3cbbfa"), -- 1200
					Gen.Num(1) -- 1200
				), -- 1200
				Gen.Fill(), -- 1201
				Gen.StrokeColor( -- 1202
					Gen.Color("#fac03d"), -- 1202
					Gen.Num(1) -- 1202
				), -- 1202
				Gen.StrokeWidth(Gen.Num(10)), -- 1203
				Gen.Stroke(), -- 1204
				Gen.BeginPath(), -- 1205
				Gen.Rect( -- 1206
					Gen.Num(150), -- 1206
					Gen.Num(150), -- 1206
					Gen.Num(100), -- 1206
					Gen.Num(100) -- 1206
				), -- 1206
				Gen.ClosePath(), -- 1207
				Gen.StrokeWidth(Gen.Num(0)), -- 1208
				Gen.Fill(), -- 1209
				Gen.BeginPath(), -- 1210
				Gen.RoundedRect( -- 1211
					Gen.Num(-150), -- 1211
					Gen.Num(-150), -- 1211
					Gen.Num(100), -- 1211
					Gen.Num(100), -- 1211
					Gen.Num(20) -- 1211
				), -- 1211
				Gen.ClosePath(), -- 1212
				Gen.Fill(), -- 1213
				Gen.BeginPath(), -- 1214
				Gen.Ellipse( -- 1215
					Gen.Num(250), -- 1215
					Gen.Num(0), -- 1215
					Gen.Num(120), -- 1215
					Gen.Num(100) -- 1215
				), -- 1215
				Gen.ClosePath(), -- 1216
				Gen.Fill(), -- 1217
				Gen.BeginPath(), -- 1218
				Gen.Circle( -- 1219
					Gen.Num(-250), -- 1219
					Gen.Num(0), -- 1219
					Gen.Num(100) -- 1219
				), -- 1219
				Gen.ClosePath(), -- 1220
				Gen.Fill() -- 1221
			) -- 1221
		), -- 1221
		Gen.VarSet( -- 1223
			"temp", -- 1223
			Gen.CreateNode() -- 1223
		), -- 1223
		Gen.OnUpdate( -- 1224
			"temp", -- 1224
			"dt", -- 1224
			Gen.IfElse(Gen.If( -- 1225
				Gen.CheckKey("Return", "KeyDown"), -- 1226
				Gen.Print(Gen.Text("Enter!")) -- 1226
			)) -- 1226
		), -- 1226
		Gen.OnTapEvent( -- 1229
			"temp", -- 1229
			"TapBegan", -- 1229
			"touch", -- 1229
			Gen.Block( -- 1229
				Gen.Print(Gen.Text("Touch began.")), -- 1230
				Gen.IfElse(Gen.If( -- 1231
					Gen.Eq( -- 1232
						Gen.TouchGetId("touch"), -- 1232
						Gen.Num(0) -- 1232
					), -- 1232
					Gen.Print(Gen.TouchGetWorldLocation("touch")) -- 1233
				)) -- 1233
			) -- 1233
		) -- 1233
	) -- 1233
	local funcs = { -- 1239
		Gen.DefProc( -- 1240
			"func1", -- 1240
			{"x"}, -- 1240
			Gen.Block( -- 1240
				Gen.ProcIfReturn(Gen.Lte( -- 1241
					Gen.VarGet("x"), -- 1241
					Gen.Num(0) -- 1241
				)), -- 1241
				Gen.Print(Gen.Text("x is greater than 0")) -- 1242
			) -- 1242
		), -- 1242
		Gen.DefProcReturn( -- 1244
			"func2", -- 1244
			{"op", "x", "y"}, -- 1244
			Gen.ProcIfReturn( -- 1245
				Gen.Eq( -- 1245
					Gen.VarGet("op"), -- 1245
					Gen.Text("add") -- 1245
				), -- 1245
				Gen.Add( -- 1245
					Gen.VarGet("x"), -- 1245
					Gen.VarGet("y") -- 1245
				) -- 1245
			), -- 1245
			Gen.Sub( -- 1246
				Gen.VarGet("x"), -- 1246
				Gen.VarGet("y") -- 1246
			) -- 1246
		) -- 1246
	} -- 1246
	local res = json.dump(Gen.toBlocklyJSON(root, funcs)) -- 1250
	print(res) -- 1251
end -- 1251
____exports.default = Gen -- 1255
return ____exports -- 1255