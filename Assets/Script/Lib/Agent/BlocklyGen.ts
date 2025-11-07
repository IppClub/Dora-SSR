import { json } from 'Dora';

namespace Gen {

class IdFactory {
	private static seq = 0;
	static next(prefix = "block"): string {
		return `${prefix}-${++IdFactory.seq}`;
	}
}

type InputMap	= Record<string, Blk>;
type FieldMap	= Record<string, any>;

export class Blk {
	readonly id: string;
	readonly type: string;
	readonly fields?: FieldMap;
	readonly inputs?: InputMap;
	readonly extraState?: unknown;
	private _next?: Blk;

	constructor(
		type: string,
		opts: { fields?: FieldMap; inputs?: InputMap; extraState?: unknown } = {}
	) {
		this.id = IdFactory.next();
		this.type = type;
		this.fields = opts.fields;
		this.inputs = opts.inputs;
		this.extraState = opts.extraState;
	}

	next(node: Blk): Blk {
		this._next = node;
		return node;
	}

	toJSON(): any {
		const j: any = { type: this.type, id: this.id };
		if (this.fields) j.fields = this.fields;
		if (this.inputs) {
			j.inputs = {};
			for (const [k, v] of pairs(this.inputs))
				j.inputs[k] = { block: v.toJSON() };
		}
		if (this.extraState) j.extraState = this.extraState;
		if (this._next) j.next = { block: this._next.toJSON() };
		return j;
	}
}

export const Bool	= (v: boolean) => new Blk("logic_boolean", { fields:{ BOOL: v ? "TRUE" : "FALSE" }});
export const Text	= (s = "") => new Blk("text", { fields:{ TEXT: s }});
export const Print = (item: Blk) => new Blk("print_block", { inputs:{ ITEM: item }});

const compare = (op: string, a: Blk, b: Blk) =>
	new Blk("logic_compare", { fields:{ OP: op }, inputs:{ A: a, B: b }});

export const Eq = (a: Blk, b: Blk) => compare("EQ", a, b);
export const Neq = (a: Blk, b: Blk) => compare("NEQ", a, b);
export const Lt = (a: Blk, b: Blk) => compare("LT", a, b);
export const Gt = (a: Blk, b: Blk) => compare("GT", a, b);
export const Gte = (a: Blk, b: Blk) => compare("GTE", a, b);
export const Lte = (a: Blk, b: Blk) => compare("LTE", a, b);

const logicOp = (op: "AND" | "OR", a: Blk, b: Blk) =>
	new Blk("logic_operation", { fields:{ OP: op }, inputs:{ A: a, B: b }});

export const And = (a: Blk, b: Blk) => logicOp("AND", a, b);
export const Or = (a: Blk, b: Blk) => logicOp("OR" , a, b);
export const Not = (b: Blk) => new Blk("logic_negate", { inputs:{ BOOL: b }});

export const Ternary = (
	cond: Blk,
	thenValue: Blk,
	elseValue: Blk
) =>
	new Blk("logic_ternary", {
		inputs: { IF: cond, THEN: thenValue, ELSE: elseValue },
	});

export const List = (...items: Blk[]) => {
	const inputMap: InputMap = {};
	items.forEach((b,i)=> {
		inputMap[`ADD${i}`] = b;
	});
	return new Blk("lists_create_with", {
		extraState: { itemCount: items.length },
		inputs: inputMap,
	});
};

type VarType = {id: string, name: string};
let varMap = new Map<string, VarType>;
const varAccess = (name: string) => {
	varMap.set(name, {name, id: name});
	return {id: name};
};

export const Declare = (name: string, value: Blk) =>
	new Blk("declare_variable", {
		fields:{ VAR: { id: name, name } },
		inputs:{ VALUE: value },
	});

export const If = (cond: Blk, body: Blk) => ({ condition: cond, elseBranch: false, body });
export const Else = (body: Blk) => ({ elseBranch: true, body });

const _ifElseCore = (
	main: ReturnType<typeof If>,
	elseIfs: ReturnType<typeof If>[],
	otherwise?: Blk
) => {
	const inputs: InputMap = {
		IF0: main.condition,
		DO0: main.body,
	};
	elseIfs.forEach((br, idx) => {
		inputs[`IF${idx+1}`] = br.condition;
		inputs[`DO${idx+1}`] = br.body;
	});
	if (otherwise) inputs["ELSE"] = otherwise;
	return new Blk("controls_if", {
		extraState:{ elseIfCount: elseIfs.length, hasElse: !!otherwise },
		inputs,
	});
};

export const IfElse = (...ifBranchesOrElse: (ReturnType<typeof If> | ReturnType<typeof Else>)[]) => {
	const last = ifBranchesOrElse[ifBranchesOrElse.length-1];
	const main = ifBranchesOrElse[0] as ReturnType<typeof If>;
	const elseIfs	= (last.elseBranch ? ifBranchesOrElse.slice(1, -1) : ifBranchesOrElse.slice(1)) as ReturnType<typeof If>[];
	const elseBody = last.elseBranch ? last.body : undefined;
	return _ifElseCore(main, elseIfs, elseBody);
};

export const Block = (...nodes: Blk[]): Blk => {
	nodes.reduce((prev, cur) => (prev.next(cur), cur));
	return nodes[0];
};

const collectVariables = (node: Blk, set = new Set<string>()) => {
	if (node.type === "declare_variable" && node.fields?.VAR?.id) {
		set.add(node.fields.VAR.id);
	}
	if (node.inputs) {
		for (let [, n] of pairs(node.inputs)) {
			collectVariables(n, set);
		}
	}
	if ((node as any)._next) collectVariables((node as any)._next, set);
	return set;
};

const fixProcParamNames = (node: Blk, funcs: Blk[]) => {
	if (node.type === "procedures_callnoreturn" || node.type === "procedures_callreturn") {
		const funcName = (node.extraState as any).name as string;
		for (let func of funcs) {
			const name = func.fields?.NAME as string;
			if (funcName === name) {
				const params = (func.extraState as any).params as ProcParam[];
				(node.extraState as any).params = params.map(param => param.name);
			}
		}
	}
	if (node.inputs) {
		for (let [, n] of pairs(node.inputs)) {
			fixProcParamNames(n, funcs);
		}
	}
	if ((node as any)._next) fixProcParamNames((node as any)._next, funcs);
};

export const Num = (n: number) =>
	new Blk("math_number", { fields: { NUM: n } });

export const VarGet = (name: string) =>
	new Blk("variables_get", { fields: { VAR: { id: name, name } } });

export const Repeat = (times: Blk, body: Blk) =>
	new Blk("controls_repeat_ext", {
		inputs: {
			TIMES: times,
			DO: body,
		},
	});

const whileUntil =
	(mode: "WHILE" | "UNTIL") =>
	(cond: Blk, body: Blk) =>
		new Blk("controls_whileUntil", {
			fields: { MODE: mode },
			inputs: { BOOL: cond, DO: body },
		});

export const While = whileUntil("WHILE");
export const Until = whileUntil("UNTIL");

export const For = (
	varName: string,
	from: Blk,
	to: Blk,
	by: Blk,
	body: Blk
) =>
	new Blk("controls_for", {
		fields: { VAR: varAccess(varName) },
		inputs: {
			FROM: from,
			TO: to,
			BY: by,
			DO: body,
		},
	});

export const ForEach = (
	varName: string,
	list: Blk,
	body: Blk
) =>
	new Blk("controls_forEach", {
		fields: { VAR: varAccess(varName) },
		inputs: { LIST: list, DO: body },
	});

const flowStmt = (kind: "BREAK" | "CONTINUE") =>
	new Blk("controls_flow_statements", {
		fields: { FLOW: kind },
	});

export const Break = () => flowStmt("BREAK");
export const Continue = () => flowStmt("CONTINUE");

const constant = (c:
	| "PI" | "E" | "GOLDEN_RATIO" | "SQRT2"
	| "SQRT1_2" | "INFINITY"
) => new Blk("math_constant", { fields: { CONSTANT: c } });

export const PI = constant("PI");
export const E = constant("E");
export const GOLDEN_RATIO = constant("GOLDEN_RATIO");
export const SQRT2 = constant("SQRT2");
export const SQRT1_2 = constant("SQRT1_2");
export const INFINITY = constant("INFINITY");

const arithmetic = (
	op: "ADD" | "MINUS" | "MULTIPLY" | "DIVIDE" | "POWER",
	A: Blk,
	B: Blk
) => new Blk("math_arithmetic", { fields: { OP: op }, inputs: { A, B } });

export const Add = (a: Blk, b: Blk) => arithmetic("ADD" , a, b);
export const Sub = (a: Blk, b: Blk) => arithmetic("MINUS", a, b);
export const Mul = (a: Blk, b: Blk) => arithmetic("MULTIPLY", a, b);
export const Div = (a: Blk, b: Blk) => arithmetic("DIVIDE", a, b);
export const Pow = (a: Blk, b: Blk) => arithmetic("POWER", a, b);

const mathSingle = (
	op:
		| "ROOT" | "ABS" | "NEG" | "LN"
		| "LOG10" | "EXP" | "POW10",
	n: Blk
) => new Blk("math_single", { fields: { OP: op }, inputs: { NUM: n } });

export const Root = (n: Blk) => mathSingle("ROOT", n);
export const Abs = (n: Blk) => mathSingle("ABS", n);
export const Neg = (n: Blk) => mathSingle("NEG", n);
export const Ln = (n: Blk) => mathSingle("LN", n);
export const Log10 = (n: Blk) => mathSingle("LOG10", n);
export const Exp = (n: Blk) => mathSingle("EXP", n);
export const Pow10 = (n: Blk) => mathSingle("POW10", n);

const trig = (
	op: "SIN" | "COS" | "TAN" | "ASIN" | "ACOS" | "ATAN",
	n: Blk
) => new Blk("math_trig", { fields: { OP: op }, inputs: { NUM: n } });

export const Sin = (deg: Blk) => trig("SIN", deg);
export const Cos = (deg: Blk) => trig("COS", deg);
export const Tan = (deg: Blk) => trig("TAN", deg);
export const Asin = (deg: Blk) => trig("ASIN", deg);
export const Acos = (deg: Blk) => trig("ACOS", deg);
export const Atan = (deg: Blk) => trig("ATAN", deg);

const numProp = (
	property:
		| "EVEN" | "ODD" | "PRIME" | "WHOLE"
		| "POSITIVE" | "NEGATIVE",
	n: Blk
) =>
	new Blk("math_number_property", {
		fields: { PROPERTY: property },
		extraState: '<mutation divisor_input="false"></mutation>',
		inputs: { NUMBER_TO_CHECK: n },
	});

export const IsEven = (n: Blk) => numProp("EVEN", n);
export const IsOdd = (n: Blk) => numProp("ODD", n);
export const IsPrime = (n: Blk) => numProp("PRIME", n);
export const IsWhole = (n: Blk) => numProp("WHOLE", n);
export const IsPositive = (n: Blk) => numProp("POSITIVE", n);
export const IsNegtive = (n: Blk) => numProp("NEGATIVE", n);
export const IsDivisibleBy = (n: Blk, divisor: Blk) => new Blk("math_number_property", {
		fields: { PROPERTY: 'DIVISIBLE_BY' },
		extraState: '<mutation divisor_input="true"></mutation>',
		inputs: { NUMBER_TO_CHECK: n, DIVISOR: divisor },
	});

const round = (
	op: "ROUND" | "ROUNDUP" | "ROUNDDOWN",
	n: Blk
) => new Blk("math_round", { fields: { OP: op }, inputs: { NUM: n } });

export const Round = (n: Blk) => round("ROUND", n);
export const RoundUp = (n: Blk) => round("ROUNDUP", n);
export const RoundDown = (n: Blk) => round("ROUNDDOWN", n);

export const Modulo = (dividend: Blk, divisor: Blk) =>
	new Blk("math_modulo", { inputs: { DIVIDEND: dividend, DIVISOR: divisor } });

const mathOnList = (
	op:
		| "SUM" | "MIN" | "MAX" | "AVERAGE"
		| "MEDIAN" | "MODE" | "STD_DEV" | "RANDOM",
	listBlock: Blk
) =>
	new Blk("math_on_list", {
		fields: { OP: op },
		extraState: `<mutation op="${op}"></mutation>`,
		inputs: { LIST: listBlock },
	});

export const Sum = (listBlock: Blk) => mathOnList("SUM", listBlock);
export const Min = (listBlock: Blk) => mathOnList("MIN", listBlock);
export const Max = (listBlock: Blk) => mathOnList("MAX", listBlock);
export const Average = (listBlock: Blk) => mathOnList("AVERAGE", listBlock);
export const Median = (listBlock: Blk) => mathOnList("MEDIAN", listBlock);
export const Mode = (listBlock: Blk) => mathOnList("MODE", listBlock);
export const StdDev = (listBlock: Blk) => mathOnList("STD_DEV", listBlock);
export const Random = (listBlock: Blk) => mathOnList("RANDOM", listBlock);

export const Constrain = (valueNum: Blk, lowNum: Blk, highNum: Blk) =>
	new Blk("math_constrain", { inputs: { VALUE: valueNum, LOW: lowNum, HIGH: highNum } });

export const RandomInt = (fromNum: Blk, toNum: Blk) =>
	new Blk("math_random_int", { inputs: { FROM: fromNum, TO: toNum } });

export const RandomFloat = () => new Blk("math_random_float");

export const Atan2 = (x: Blk, y: Blk) =>
	new Blk("math_atan2", { inputs: { X: x, Y: y } });

export const TextJoin = (...texts: Blk[]) => {
	const inputMap: InputMap = {};
	texts.forEach((b, i) => {
		inputMap[`ADD${i}`] = b;
	});
	return new Blk("text_join", {
		extraState: { itemCount: texts.length },
		inputs: inputMap,
	});
};

export const TextAppend = (varName: string, what: Blk) =>
	new Blk("text_append", {
		fields: { VAR: varAccess(varName) },
		inputs: { TEXT: what },
	});

export const TextLength	= (text: Blk) =>
	new Blk("text_length", { inputs: { VALUE: text } });

export const IsTextEmpty = (text: Blk) =>
	new Blk("text_isEmpty", { inputs: { VALUE: text } });

export const TextReverse = (text: Blk) =>
	new Blk("text_reverse", { inputs: { TEXT: text } });

type IndexEnd = "FIRST" | "LAST";
const textIndexOf = (
	end: IndexEnd,
	textBlk: Blk,
	findBlk: Blk
) =>
	new Blk("text_indexOf", {
		fields: { END: end },
		inputs: { VALUE: textBlk, FIND: findBlk },
	});

export const TextFirstIndexOf = (text: Blk, firstFind: Blk) => textIndexOf("FIRST", text, firstFind);
export const TextLastIndexOf = (text: Blk, lastFind: Blk) => textIndexOf("LAST", text, lastFind);

type CharWhere = "FROM_START" | "FROM_END" | "FIRST" | "LAST" | "RANDOM";
const charAt = (
	where: CharWhere,
	textBlk: Blk,
	at?: Blk
) =>
	new Blk("text_charAt", {
		extraState: `<mutation at="${where === "FROM_START" || where === "FROM_END"}"></mutation>`,
		fields: { WHERE: where },
		inputs: {
			VALUE: textBlk,
			...(at ? { AT: at } : {}),
		},
	});

export const CharFromStart = (text: Blk, at: Blk) => charAt("FROM_START", text, at);
export const CharFromEnd = (text: Blk, at: Blk) => charAt("FROM_END", text, at);
export const FirstChar = (text: Blk) => charAt("FIRST", text);
export const LastChar = (text: Blk) => charAt("LAST", text);
export const RandomChar = (text: Blk) => charAt("RANDOM", text);

type SubWhere1 = "FROM_START" | "FROM_END" | "FIRST";
type SubWhere2 = "FROM_START" | "FROM_END" | "LAST";
const substring = (
	where1: SubWhere1, where2: SubWhere2,
	textBlk: Blk,
	at1?: Blk, at2?: Blk
) =>
	new Blk("text_getSubstring", {
		extraState: `<mutation at1="${where1 === "FROM_START" || where1 === "FROM_END"}" at2="${where2 === "FROM_START" || where2 === "FROM_END"}"></mutation>`,
		fields: { WHERE1: where1, WHERE2: where2 },
		inputs: {
			STRING: textBlk,
			...(at1 ? { AT1: at1 } : {}),
			...(at2 ? { AT2: at2 } : {}),
		},
	});
export const Substring = (at1: Blk, at2?: Blk) =>
	substring("FROM_START", at2 ? "FROM_START" : "LAST", at1, at2);

type CaseMode = "UPPERCASE" | "LOWERCASE" | "TITLECASE";
const changeCase = (mode: CaseMode, str: Blk) =>
	new Blk("text_changeCase", {
		fields: { CASE: mode },
		inputs: { TEXT: str },
	});

export const UpperCase = (text: Blk) => changeCase("UPPERCASE", text);
export const LowerCase = (text: Blk) => changeCase("LOWERCASE", text);
export const TitleCase = (text: Blk) => changeCase("TITLECASE", text);

type TrimMode = "LEFT" | "RIGHT" | "BOTH";
const trim = (mode: TrimMode, str: Blk) =>
	new Blk("text_trim", {
		fields: { MODE: mode },
		inputs: { TEXT: str },
	});

export const TrimLeft = (text: Blk) => trim("LEFT", text);
export const TrimRight = (text: Blk) => trim("RIGHT", text);
export const Trim = (text: Blk) => trim("BOTH", text);

export const TextCount = (subText: Blk, text: Blk) =>
	new Blk("text_count", {
		inputs: { SUB: subText, TEXT: text },
	});

export const TextReplace = (
	text: Blk,
	fromText: Blk,
	toText: Blk
) =>
	new Blk("text_replace", {
		inputs: { TEXT: text, FROM: fromText, TO: toText },
	});

export const RepeatList = (item: Blk, times: Blk) =>
	new Blk("lists_repeat", { inputs: { ITEM: item, NUM: times } });

export const ListLength = (list: Blk) =>
	new Blk("lists_length", { inputs: { VALUE: list } });

export const IsListEmpty = (list: Blk) =>
	new Blk("lists_isEmpty", { inputs: { VALUE: list } });

const indexOf = (
	list: Blk,
	findItem: Blk,
	which: "FIRST" | "LAST"
) =>
	new Blk("lists_indexOf", {
		fields: { END: which },
		inputs: { VALUE: list, FIND: findItem },
	});

export const FirstIndexOf = (list: Blk, findItem: Blk) => indexOf(list, findItem, "FIRST");
export const LastIndexOf = (list: Blk, findItem: Blk) => indexOf(list, findItem, "FIRST");

type Mode = "GET" | "GET_REMOVE" | "REMOVE";
type Where =
	| "FROM_START"
	| "FROM_END"
	| "FIRST"
	| "LAST"
	| "RANDOM";

const listGetIndex = (
	mode: Mode,
	where: Where,
	listExpr: Blk,
	at?: Blk
) =>
	new Blk("lists_getIndex", {
		fields: { MODE: mode, WHERE: where },
		inputs: {
			VALUE: listExpr,
			...(at ? { AT: at } : {}),
		},
		extraState: { isStatement: mode === "REMOVE" },
	});

export const ListGet = (list: Blk, at: Blk) => listGetIndex("GET", "FROM_START", list, at);
export const ListRemoveGet = (list: Blk, at: Blk) => listGetIndex("GET_REMOVE", "FROM_START", list, at);
export const ListRemove = (list: Blk, at: Blk) => listGetIndex("REMOVE", "FROM_START", list, at);
export const ListRemoveLast = (list: Blk) => listGetIndex("GET_REMOVE", "LAST", list);
export const ListRemoveFirst = (list: Blk) => listGetIndex("GET_REMOVE", "FIRST", list);

const subList = (
	listExpr: Blk,
	where1: Where,
	where2: Where,
	at1: Blk,
	at2?: Blk
) =>
	new Blk("lists_getSublist", {
		fields: { WHERE1: where1, WHERE2: where2 },
		inputs: at2 ? { LIST: listExpr, AT1: at1, AT2: at2 } : { LIST: listExpr, AT1: at1 },
	});

export const SubList = (list: Blk, at1: Blk, at2?: Blk) =>
	subList(list, "FROM_START", at2 ? "FROM_START" : "LAST", at1, at2);

const listSplit = (
	input: Blk,
	delim: Blk,
	mode: "SPLIT" | "JOIN"
) =>
	new Blk("lists_split", {
		fields: { MODE: mode },
		inputs: { INPUT: input, DELIM: delim },
	});

export const ListSplit = (inputText: Blk, delimText: Blk) => listSplit(inputText, delimText, "SPLIT");
export const ListStringConcat = (list: Blk, delimText: Blk) => listSplit(list, delimText, "JOIN");

const listSort = (
	listExpr: Blk,
	type: "NUMERIC" | "TEXT" | "IGNORE_CASE",
	direction: "1" | "-1"
) =>
	new Blk("lists_sort", {
		fields: { TYPE: type, DIRECTION: direction },
		inputs: { LIST: listExpr },
	});

export const ListSort = (list: Blk, desc?: boolean) => listSort(list, "NUMERIC", desc ? "-1" : "1");

export const ListReverse = (list: Blk) =>
	new Blk("lists_reverse", { inputs: { LIST: list } });

const listSetIndex = (
	mode: "SET" | "INSERT",
	listExpr: Blk,
	at: Blk,
	to: Blk,
	where: Where
) =>
	new Blk("lists_setIndex", {
		fields: { MODE: mode, WHERE: where },
		inputs: { LIST: listExpr, AT: at, TO: to },
	});

export const ListSet = (list: Blk, at: Blk, item: Blk) => listSetIndex("SET", list, at, item, "FROM_START");
export const ListInsert = (list: Blk, at: Blk, item: Blk) => listSetIndex("INSERT", list, at, item, "FROM_START");

export const Dict = () => new Blk("dict_create");

export const DictGet = (dict: Blk, key: Blk) =>
	new Blk("dict_get", { inputs: { DICT: dict, KEY: key } });

export const DictSet = (dict: Blk, key: Blk, val: Blk) =>
	new Blk("dict_set", { inputs: { DICT: dict, KEY: key, VALUE: val } });

export const DictContain = (dict: Blk, key: Blk) =>
	new Blk("dict_has_key", { inputs: { DICT: dict, KEY: key } });

export const DictRemove = (dict: Blk, key: Blk) =>
	new Blk("dict_remove_key", { inputs: { DICT: dict, KEY: key } });

export const VarSet = (name: string, value: Blk) =>
	new Blk("variables_set", {
		fields: { VAR: varAccess(name) },
		inputs: { VALUE: value },
	});

export const VarAdd = (name: string, deltaNum: Blk) =>
	new Blk("math_change", {
		fields: { VAR: varAccess(name) },
		inputs: { DELTA: deltaNum },
	});

export const ProcReturn = (value?: Blk) =>
	new Blk("return_block", { inputs: value ? { VALUE: value } : {} });

export const ProcIfReturn = (
	cond: Blk,
	value?: Blk
) =>
	new Blk("procedures_ifreturn", {
		extraState: `<mutation value="${value ? 1 : 0}"></mutation>`,
		inputs: value ? { CONDITION: cond, VALUE: value } : { CONDITION: cond },
	});

interface ProcParam { name: string; id: string }

const buildParams = (names: string[]): ProcParam[] =>
	names.map(p => ({ name: p, id: IdFactory.next("arg") }));

export const DefProcReturn = (
	name: string,
	params: string[],
	body: Blk,
	returnExpr: Blk
) =>
	new Blk("procedures_defreturn", {
		fields: { NAME: name },
		inputs: { STACK: body, RETURN: returnExpr },
		extraState: { params: buildParams(params) }
	});

export const DefProc = (
	name: string,
	params: string[],
	body: Blk
) =>
	new Blk("procedures_defnoreturn", {
		fields: { NAME: name },
		inputs: { STACK: body },
		extraState: { params: buildParams(params) },
	});

export const CallProc = (procName: string, ...args: Blk[]) => {
	const inputMap: InputMap = {};
	args.forEach((value, i) => {
		inputMap[`ARG${i}`] = value;
	});
	return new Blk("procedures_callnoreturn", {
		extraState: { name: procName, params: undefined },
		inputs: inputMap,
	});
};

export const CallProcReturn = (procName: string, ...args: Blk[]) => {
	const inputMap: InputMap = {};
	args.forEach((value, i) => {
		inputMap[`ARG${i}`] = value;
	});
	return new Blk("procedures_callreturn", {
		extraState: { name: procName, params: undefined },
		inputs: inputMap,
	});
};

export const Vec2Zero = () => new Blk("vec2_zero");

export const Vec2 = (x: Blk, y: Blk) =>
	new Blk("vec2_create", { inputs: { X: x, Y: y } });

type Vec2Prop = "x" | "y" | "length" | "angle";
const vec2Prop = (vecVar: string, prop: Vec2Prop) =>
	new Blk("vec2_get_property", {
		fields: { VEC2: varAccess(vecVar), PROPERTY: prop },
	});

export const Vec2X = (varName: string) => vec2Prop(varName, "x");
export const Vec2Y = (varName: string) => vec2Prop(varName, "y");
export const Vec2Length = (varName: string) => vec2Prop(varName, "length");
export const Vec2Angle = (varName: string) => vec2Prop(varName, "angle");

export const Vec2Normalize = (v: Blk) =>
	new Blk("vec2_get_normalized", { inputs: { VEC2: v } });

const vec2VecOp = (op: "+" | "-" | "*" | "/", a: Blk, b: Blk) =>
	new Blk("vec2_binary_operation", {
		fields: { OPERATION: op },
		inputs: { VEC2_1: a, VEC2_2: b },
	});

export const Vec2Add = (a: Blk, b: Blk) => vec2VecOp("+", a, b);
export const Vec2Sub = (a: Blk, b: Blk) => vec2VecOp("-", a, b);
export const Vec2MulVec = (a: Blk, b: Blk) => vec2VecOp("*", a, b);
export const Vec2DivVec = (a: Blk, b: Blk) => vec2VecOp("/", a, b);
export const Vec2Distance = (a: Blk, b: Blk) => vec2Calc("distance", a, b);
export const Vec2Dot = (a: Blk, b: Blk) => vec2Calc("dot", a, b);

const vec2NumOp = (op: "*" | "/", v: Blk, n: Blk) =>
	new Blk("vec2_binary_op_number", {
		fields: { OPERATION: op },
		inputs: { VEC2: v, NUMBER: n },
	});

export const Vec2MulNum = (v: Blk, n: Blk) => vec2NumOp("*", v, n);
export const Vec2DivNum = (v: Blk, n: Blk) => vec2NumOp("/", v, n);

export const Vec2Clamp = (
	v: Blk,
	min: Blk,
	max: Blk
) =>
	new Blk("vec2_clamp", {
		inputs: { VEC2: v, MIN: min, MAX: max },
	});

const vec2Calc = (what: "distance" | "dot", a: Blk, b: Blk) =>
	new Blk("vec2_calculate", {
		fields: { CALCULATE: what },
		inputs: { VEC2_1: a, VEC2_2: b },
	});

export const CreateNode = () => new Blk("node_create");
export const CreateSprite = (file: Blk) =>
	new Blk("sprite_create", { inputs: { FILE: file } });

export const CreateLabel = (fontName: Blk, size: Blk) =>
	new Blk("label_create", {
		inputs: {
			FONT: fontName,
			SIZE: size,
		},
	});

export const LabelSetText = (varName: string, text: Blk) =>
	new Blk("label_set_text", {
		fields: { LABEL: varAccess(varName) },
		inputs: { TEXT: text },
	});

export const NodeAddChild = (parentVar: string, childVar: string, order: Blk) =>
	new Blk("node_add_child", {
		fields: { PARENT: varAccess(parentVar), CHILD: varAccess(childVar) },
		inputs: { ORDER: order },
	});

type NumAttr = "x" | "y" | "width" | "height" | "angle" | "scale" | "scaleX" | "scaleY" | "opacity";
const nodeSetNumAttr = (varName: string, attr: NumAttr, value: Blk) =>
	new Blk("node_set_number_attribute", {
		fields: { NODE: varAccess(varName), ATTRIBUTE: attr },
		inputs: { VALUE: value },
	});
export const NodeSetX = (varName: string, n: Blk) => nodeSetNumAttr(varName, "x", n);
export const NodeSetY = (varName: string, n: Blk) => nodeSetNumAttr(varName, "y", n);
export const NodeSetWidth = (varName: string, n: Blk) => nodeSetNumAttr(varName, "width", n);
export const NodeSetHeight = (varName: string, n: Blk) => nodeSetNumAttr(varName, "height", n);
export const NodeSetAngle = (varName: string, n: Blk) => nodeSetNumAttr(varName, "angle", n);
export const NodeSetScale = (varName: string, n: Blk) => nodeSetNumAttr(varName, "scale", n);
export const NodeSetScaleX = (varName: string, n: Blk) => nodeSetNumAttr(varName, "scaleX", n);
export const NodeSetScaleY = (varName: string, n: Blk) => nodeSetNumAttr(varName, "scaleY", n);
export const NodeSetOpactity = (varName: string, n: Blk) => nodeSetNumAttr(varName, "opacity", n);

const nodeGetNumAttr = (varName: string, attr: NumAttr) =>
	new Blk("node_get_number_attribute", {
		fields: { NODE: varAccess(varName), ATTRIBUTE: attr },
	});

export const NodeGetX = (varName: string) => nodeGetNumAttr(varName, "x");
export const NodeGetY = (varName: string) => nodeGetNumAttr(varName, "y");
export const NodeGetWidth = (varName: string) => nodeGetNumAttr(varName, "width");
export const NodeGetHeight = (varName: string) => nodeGetNumAttr(varName, "height");
export const NodeGetAngle = (varName: string) => nodeGetNumAttr(varName, "angle");
export const NodeGetScale = (varName: string) => nodeGetNumAttr(varName, "scale");
export const NodeGetScaleX = (varName: string) => nodeGetNumAttr(varName, "scaleX");
export const NodeGetScaleY = (varName: string) => nodeGetNumAttr(varName, "scaleY");
export const NodeGetOpactity = (varName: string) => nodeGetNumAttr(varName, "opacity");

type BoolAttr = "visible" | "showDebug";
const nodeSetBoolAttr = (nodeVar: string, attr: BoolAttr, value: Blk) =>
	new Blk("node_set_boolean_attribute", {
		fields: { NODE: varAccess(nodeVar), ATTRIBUTE: attr },
		inputs: { VALUE: value },
	});

export const NodeSetVisible = (varName: string, bool: Blk) => nodeSetBoolAttr(varName, "visible", bool);

const nodeGetBoolAttr = (varName: string, attr: BoolAttr) =>
	new Blk("node_get_boolean_attribute", {
		fields: { NODE: varAccess(varName), ATTRIBUTE: attr },
	});

export const NodeGetVisible = (varName: string) => nodeGetBoolAttr(varName, "visible");

type Vec2Attr = "position" | "scale" | "size" | "anchor";
const nodeSetVec2Attr = (varName: string, attr: Vec2Attr, vec: Blk) =>
	new Blk("node_set_vec2_attribute", {
		fields: { NODE: varAccess(varName), ATTRIBUTE: attr },
		inputs: { VEC2: vec },
	});

export const NodeSetPosition = (varName: string, vec: Blk) => nodeSetVec2Attr(varName, "position", vec);
export const NodeSetAnchor = (varName: string, vec: Blk) => nodeSetVec2Attr(varName, "anchor", vec);

const nodeGetVec2Attr = (nodeVar: string, attr: Vec2Attr) =>
	new Blk("node_get_vec2_attribute", {
		fields: { NODE: varAccess(nodeVar), ATTRIBUTE: attr },
	});

export const NodeGetPosition = (varName: string) => nodeGetVec2Attr(varName, "position");
export const NodeGetAnchor = (varName: string) => nodeGetVec2Attr(varName, "anchor");

export const BeginPaint = (nodeVar: string, paintBody: Blk) =>
	new Blk("nvg_begin_painting", {
		fields: { NODE: varAccess(nodeVar) },
		inputs: { PAINT: paintBody },
	});

export const BeginPath = () =>
	new Blk("nvg_begin_path");

export const MoveTo = (x: Blk, y: Blk) =>
	new Blk("nvg_move_to", { inputs: { X: x, Y: y } });

export const BezierTo = (
	c1x: Blk, c1y: Blk,
	c2x: Blk, c2y: Blk,
	x: Blk,	y: Blk,
) => new Blk("nvg_bezier_to", {
	inputs: { C1X: c1x, C1Y: c1y, C2X: c2x, C2Y: c2y, X: x, Y: y },
});

export const LineTo = (x: Blk, y: Blk) =>
	new Blk("nvg_line_to", { inputs: { X: x, Y: y } });

export const ClosePath = () =>
	new Blk("nvg_close_path");

export const FillColor = (color: Blk, opacity: Blk) =>
	new Blk("nvg_fill_color", { inputs: { COLOR: color, OPACITY: opacity } });

export const Fill = () =>
	new Blk("nvg_fill");

export const StrokeColor = (color: Blk, opacity: Blk) =>
	new Blk("nvg_stroke_color", { inputs: { COLOR: color, OPACITY: opacity } });

export const StrokeWidth = (w: Blk) =>
	new Blk("nvg_stroke_width", { inputs: { WIDTH: w } });

export const Stroke = () =>
	new Blk("nvg_stroke");

export const Rect = (x: Blk, y: Blk, w: Blk, h: Blk) =>
	new Blk("nvg_rect", {
		inputs: { X: x, Y: y, WIDTH: w, HEIGHT: h },
	});

export const RoundedRect = (
	x: Blk, y: Blk, w: Blk, h: Blk, r: Blk,
) => new Blk("nvg_rounded_rect", {
	inputs: { X: x, Y: y, WIDTH: w, HEIGHT: h, RADIUS: r },
});

export const Ellipse = (
	cx: Blk, cy: Blk, rx: Blk, ry: Blk,
) => new Blk("nvg_ellipse", {
	inputs: { CX: cx, CY: cy, RX: rx, RY: ry },
});

export const Circle = (
	cx: Blk, cy: Blk, radius: Blk,
) => new Blk("nvg_circle", {
	inputs: { CX: cx, CY: cy, RADIUS: radius },
});

export const Color = (hex: string) =>
	new Blk("colour_hsv_sliders", { fields: { COLOUR: hex } });

export const OnUpdate = (
	nodeVar: string,
	dtVar: string,
	actionBody: Blk
) =>
	new Blk("on_update", {
		fields: { NODE: varAccess(nodeVar), DELTA_TIME: varAccess(dtVar) },
		inputs: { ACTION: actionBody },
	});

export type TapEvent = "TapBegan" | "TapMoved" | "TapEnded" | "Tapped";
export const OnTapEvent = (
	nodeVar: string,
	event: TapEvent,
	touchVar: string,
	actionBody: Blk
) =>
	new Blk("on_tap_event", {
		fields: {
			NODE: varAccess(nodeVar),
			EVENT: event,
			TOUCH: varAccess(touchVar),
		},
		inputs: { ACTION: actionBody },
	});

export type KeyName = 'Return'|
	'Escape'|
	'BackSpace'|
	'Tab'|
	'Space'|
	'!'|
	'"'|
	'#'|
	'%'|
	'$'|
	'&'|
	'\''|
	'('|
	')'|
	'*'|
	'+'|
	','|
	'-'|
	'.'|
	'/'|
	'1'|
	'2'|
	'3'|
	'4'|
	'5'|
	'6'|
	'7'|
	'8'|
	'9'|
	'0'|
	':'|
	';'|
	'<'|
	'='|
	'>'|
	'?'|
	'@'|
	'['|
	'\\'|
	']'|
	'^'|
	'_'|
	'`'|
	'A'|
	'B'|
	'C'|
	'D'|
	'E'|
	'F'|
	'G'|
	'H'|
	'I'|
	'J'|
	'K'|
	'L'|
	'M'|
	'N'|
	'O'|
	'P'|
	'Q'|
	'R'|
	'S'|
	'T'|
	'U'|
	'V'|
	'W'|
	'X'|
	'Y'|
	'Z'|
	'Delete'|
	'CapsLock'|
	'F1'|
	'F2'|
	'F3'|
	'F4'|
	'F5'|
	'F6'|
	'F7'|
	'F8'|
	'F9'|
	'F10'|
	'F11'|
	'F12'|
	'PrintScreen'|
	'ScrollLock'|
	'Pause'|
	'Insert'|
	'Home'|
	'PageUp'|
	'End'|
	'PageDown'|
	'Right'|
	'Left'|
	'Down'|
	'Up'|
	'Application'|
	'LCtrl'|
	'LShift'|
	'LAlt'|
	'LGui'|
	'RCtrl'|
	'RShift'|
	'RAlt'|
	'RGui';
export type KeyState = "KeyDown" | "KeyUp" | "KeyPressed";
export const CheckKey = (key: KeyName, state: KeyState) =>
	new Blk("check_key", { fields: { KEY: key, KEY_STATE: state } });

type TouchNumAttr = "id" | "x" | "y" | "worldX" | "worldY";
type TouchVec2Attr = "worldLocation" | "location";

const touchNumAttr = (touchId: string, attr: TouchNumAttr) =>
	new Blk("get_touch_number_attribute", {
		fields: { TOUCH: varAccess(touchId), ATTRIBUTE: attr },
	});

export const TouchGetId = (touchVar: string) => touchNumAttr(touchVar, "id");

const touchVec2Attr = (touchId: string, attr: TouchVec2Attr) =>
	new Blk("get_touch_vec2_attribute", {
		fields: { TOUCH: varAccess(touchId), ATTRIBUTE: attr },
	});

export const TouchGetLocation = (touchVar: string) => touchVec2Attr(touchVar, "location");
export const TouchGetWorldLocation = (touchVar: string) => touchVec2Attr(touchVar, "worldLocation");

export const toBlocklyJSON = (root: Blk, procs?: Blk[]): string => {
	let vars = Array.from(collectVariables(root)).map(n => ({ name: n, id: n }));
	for (let [_, v] of varMap.entries()) {
		vars.push(v);
	}
	if (procs) {
		fixProcParamNames(root, procs);
		for (let proc of procs) {
			fixProcParamNames(proc, procs);
			const procVars = Array.from(collectVariables(proc)).map(n => ({ name: n, id: n }));
			vars = vars.concat(procVars);
		}
	}
	const finalVars: VarType[] = [];
	const tmp = new Set<string>;
	for (let v of vars) {
		if (!tmp.has(v.id)) {
			tmp.add(v.id);
			finalVars.push(v);
		}
	}
	vars = finalVars;
	varMap = new Map<string, VarType>;
	const procBlocks = procs?.map((proc, i) => {
		const j = proc.toJSON();
		j.x = (i + 1) * 500;
		return j;
	}) ?? [];
	const [res] = json.encode({
		blocks: {
			languageVersion: 0,
			blocks: [root.toJSON(), ...procBlocks],
		},
		variables: vars,
	});
	return res ?? "{}";
};

/* Usages:
const root = Block(
	IfElse(
		If(Bool(false), Print(Text())),
		If(Bool(true), Print(Text())),
		Else(Block(
			Print(Text("a")),
			Print(Text("b")),
		)),
	),
	Declare("temp", List(
		Eq(Bool(true), Bool(true)),
		Neq(Bool(true), Bool(false)),
		Lt(Num(1), Num(2)),
		Gt(Num(2), Num(1)),
		Gte(Num(4), Num(3)),
		Not(Bool(false)),
		And(Bool(true), Bool(true)),
		Or(Bool(true), Bool(false)),
	)),
	VarSet("temp", Ternary(Bool(true), Num(1), Num(2))),
	Repeat(Num(10),
		Block(
			Print(Num(123)),
			Print(Text("abc"))
		)
	),
	While(Bool(true),
		Print(Num(123))
	),
	For("i",
		Num(1), Num(10), Num(1),
		Print(Num(123))
	),
	ForEach("j",
		VarGet("temp"),
		Block(
			Print(Num(123)),
			Break()
		)
	),
	Print(
		List(
			Num(123),
			Add(Num(1), Num(2)),
			Sub(Num(5), Num(3)),
			Mul(Num(2), Num(4)),
			Div(Num(9), Num(3)),
			Pow(Num(2), Num(10)),
			Root(Num(9)),
			Cos(Num(45)),
			PI,
			IsEven(Num(6)),
			RoundUp(Num(3.14)),
			Modulo(Num(7), Num(3)),
			Sum(List()),
			Constrain(Num(50), Num(1), Num(100)),
			RandomInt(Num(1), Num(10)),
			RandomFloat(),
			Atan2(Num(1), Num(1)),
			IsDivisibleBy(Num(10), Num(3))
		)
	),
	Print(TextJoin(Text("aa"), Text("bb"))),
	Print(List(
		TextLength(Text("xyz")),
		IsTextEmpty(Text("")),
		TextFirstIndexOf(VarGet("temp"), Text("a")),
		TextLastIndexOf(VarGet("temp"), Text("b")),
		CharFromStart(VarGet("temp"), Num(1)),
		CharFromEnd(VarGet("temp"), Num(123)),
		FirstChar(VarGet("temp")),
		LastChar(VarGet("temp")),
		RandomChar(VarGet("temp")),
	)),
	Print(List(
		RepeatList(VarGet("temp"), Num(5)),
		ListLength(VarGet("temp")),
		IsListEmpty(VarGet("temp")),
		FirstIndexOf(VarGet("temp"), Num(123)),
		LastIndexOf(VarGet("temp"), Num(123)),
		ListGet(VarGet("temp"), Num(1)),
		ListRemoveGet(VarGet("temp"), Num(1)),
		SubList(VarGet("temp"), Num(1), Num(4)),
		ListSplit(Text("a,b,c,d"), Text(",")),
		ListStringConcat(List(Text("a"), Text("b"), Text("c")), Text(",")),
		ListSort(VarGet("temp")),
		ListSort(VarGet("temp"), true),
		ListReverse(VarGet("temp")),
	)),
	Print(List(
		Dict(),
		DictGet(VarGet("temp"), Text("key")),
		DictContain(VarGet("temp"), Text("key")),
	)),
	DictSet(VarGet("temp"), Text("key"), Text("value")),
	DictRemove(VarGet("temp"), Text("key")),
	VarSet("j", CallProcReturn("func2", Text("sub"), Num(123), Num(456))),
	VarAdd("j", Num(1234)),
	CallProc("func1", Num(100)),
	Print(List(
		Vec2Zero(),
		Vec2(Num(123), Num(456)),
		Vec2X("temp"),
		Vec2Y("temp"),
		Vec2Length("temp"),
		Vec2Angle("temp"),
		Vec2Normalize(VarGet("temp")),
	)),
	Print(List(
		Vec2Add(Vec2(Num(123), Num(123)), Vec2(Num(123), Num(123))),
		Vec2MulNum(Vec2(Num(123), Num(123)), Num(2)),
		Vec2Clamp(Vec2(Num(123), Num(123)), Vec2(Num(1), Num(1)), Vec2(Num(20), Num(20))),
		Vec2Distance(Vec2(Num(0), Num(0)), Vec2(Num(123), Num(123))),
		Vec2Dot(Vec2(Num(123), Num(123)), Vec2(Num(123), Num(123))),
	)),
	Declare("sub", CreateNode()),
	VarSet("temp", CreateSprite(Text("Image/logo.png"))),
	Declare("temp1", CreateLabel(Text("sarasa-mono-sc-regular"), Num(16))),
	LabelSetText("temp1", Text("Hello World")),
	NodeAddChild("temp", "sub", Num(123)),
	NodeSetX("sub", NodeGetX("temp1")),
	NodeSetPosition("temp1", Vec2(Num(0), Num(0))),
	Declare("draw", CreateNode()),
	BeginPaint("draw", Block(
		BeginPath(),
		MoveTo(Num(0), Num(0)),
		BezierTo(
			Num(0), Num(0),
			Num(0), Num(100),
			Num(100), Num(100)
		),
		LineTo(Num(100), Num(100)),
		LineTo(Num(100), Num(-100)),
		ClosePath(),
		FillColor(Color("#3cbbfa"), Num(1)),
		Fill(),
		StrokeColor(Color("#fac03d"), Num(1)),
		StrokeWidth(Num(10)),
		Stroke(),
		BeginPath(),
		Rect(Num(150), Num(150), Num(100), Num(100)),
		ClosePath(),
		StrokeWidth(Num(0)),
		Fill(),
		BeginPath(),
		RoundedRect(Num(-150), Num(-150), Num(100), Num(100), Num(20)),
		ClosePath(),
		Fill(),
		BeginPath(),
		Ellipse(Num(250), Num(0), Num(120), Num(100)),
		ClosePath(),
		Fill(),
		BeginPath(),
		Circle(Num(-250), Num(0), Num(100)),
		ClosePath(),
		Fill()
	)),
	VarSet("temp", CreateNode()),
	OnUpdate("temp", "dt",
		IfElse(
			If(CheckKey("Return", "KeyDown"), Print(Text("Enter!")))
		)
	),
	OnTapEvent("temp", "TapBegan", "touch", Block(
		Print(Text("Touch began.")),
		IfElse(
			If(Eq(TouchGetId("touch"), Num(0)),
				Print(TouchGetWorldLocation("touch"))
			)
		)
	))
);
const funcs = [
	DefProc("func1", ["x"], Block(
		ProcIfReturn(Lte(VarGet("x"), Num(0))),
		Print(Text("x is greater than 0"))
	)),
	DefProcReturn("func2", ["op", "x", "y"],
		ProcIfReturn(Eq(VarGet("op"), Text("add")), Add(VarGet("x"), VarGet("y"))),
		Sub(VarGet("x"), VarGet("y"))
	)
];
const jsonCode = toBlocklyJSON(root, funcs);
print(jsonCode);
*/

} // namespace Gen

export default Gen;
