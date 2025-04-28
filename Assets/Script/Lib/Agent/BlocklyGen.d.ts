declare namespace Gen {
	export class Blk {
		private constructor();
	}
	export const Bool: (v: boolean) => Blk;
	export const Text: (s?: string) => Blk;
	export const Print: (item: Blk) => Blk;
	export const Eq: (a: Blk, b: Blk) => Blk;
	export const Neq: (a: Blk, b: Blk) => Blk;
	export const Lt: (a: Blk, b: Blk) => Blk;
	export const Gt: (a: Blk, b: Blk) => Blk;
	export const Gte: (a: Blk, b: Blk) => Blk;
	export const Lte: (a: Blk, b: Blk) => Blk;
	export const And: (a: Blk, b: Blk) => Blk;
	export const Or: (a: Blk, b: Blk) => Blk;
	export const Not: (b: Blk) => Blk;
	export const Ternary: (cond: Blk, thenValue: Blk, elseValue: Blk) => Blk;
	export const List: (...items: Blk[]) => Blk;
	export const Declare: (name: string, value: Blk) => Blk;
	export const If: (cond: Blk, body: Blk) => {
		condition: Blk;
		elseBranch: boolean;
		body: Blk;
	};
	export const Else: (body: Blk) => {
		elseBranch: boolean;
		body: Blk;
	};
	export const IfElse: (...ifBranchesOrElse: (ReturnType<typeof If> | ReturnType<typeof Else>)[]) => Blk;
	export const Block: (...nodes: Blk[]) => Blk;
	export const Num: (n: number) => Blk;
	export const VarGet: (name: string) => Blk;
	export const Repeat: (times: Blk, body: Blk) => Blk;
	export const While: (cond: Blk, body: Blk) => Blk;
	export const Until: (cond: Blk, body: Blk) => Blk;
	export const For: (varName: string, from: Blk, to: Blk, by: Blk, body: Blk) => Blk;
	export const ForEach: (varName: string, list: Blk, body: Blk) => Blk;
	export const Break: () => Blk;
	export const Continue: () => Blk;
	export const PI: Blk;
	export const E: Blk;
	export const GOLDEN_RATIO: Blk;
	export const SQRT2: Blk;
	export const SQRT1_2: Blk;
	export const INFINITY: Blk;
	export const Add: (a: Blk, b: Blk) => Blk;
	export const Sub: (a: Blk, b: Blk) => Blk;
	export const Mul: (a: Blk, b: Blk) => Blk;
	export const Div: (a: Blk, b: Blk) => Blk;
	export const Pow: (a: Blk, b: Blk) => Blk;
	export const Root: (n: Blk) => Blk;
	export const Abs: (n: Blk) => Blk;
	export const Neg: (n: Blk) => Blk;
	export const Ln: (n: Blk) => Blk;
	export const Log10: (n: Blk) => Blk;
	export const Exp: (n: Blk) => Blk;
	export const Pow10: (n: Blk) => Blk;
	export const Sin: (deg: Blk) => Blk;
	export const Cos: (deg: Blk) => Blk;
	export const Tan: (deg: Blk) => Blk;
	export const Asin: (deg: Blk) => Blk;
	export const Acos: (deg: Blk) => Blk;
	export const Atan: (deg: Blk) => Blk;
	export const IsEven: (n: Blk) => Blk;
	export const IsOdd: (n: Blk) => Blk;
	export const IsPrime: (n: Blk) => Blk;
	export const IsWhole: (n: Blk) => Blk;
	export const IsPositive: (n: Blk) => Blk;
	export const IsNegtive: (n: Blk) => Blk;
	export const IsDivisibleBy: (n: Blk, divisor: Blk) => Blk;
	export const Round: (n: Blk) => Blk;
	export const RoundUp: (n: Blk) => Blk;
	export const RoundDown: (n: Blk) => Blk;
	export const Modulo: (dividend: Blk, divisor: Blk) => Blk;
	export const Sum: (listBlock: Blk) => Blk;
	export const Min: (listBlock: Blk) => Blk;
	export const Max: (listBlock: Blk) => Blk;
	export const Average: (listBlock: Blk) => Blk;
	export const Median: (listBlock: Blk) => Blk;
	export const Mode: (listBlock: Blk) => Blk;
	export const StdDev: (listBlock: Blk) => Blk;
	export const Random: (listBlock: Blk) => Blk;
	export const Constrain: (valueNum: Blk, lowNum: Blk, highNum: Blk) => Blk;
	export const RandomInt: (fromNum: Blk, toNum: Blk) => Blk;
	export const RandomFloat: () => Blk;
	export const Atan2: (x: Blk, y: Blk) => Blk;
	export const TextJoin: (...texts: Blk[]) => Blk;
	export const TextAppend: (varName: string, what: Blk) => Blk;
	export const TextLength: (text: Blk) => Blk;
	export const IsTextEmpty: (text: Blk) => Blk;
	export const TextReverse: (text: Blk) => Blk;
	export const TextFirstIndexOf: (text: Blk, firstFind: Blk) => Blk;
	export const TextLastIndexOf: (text: Blk, lastFind: Blk) => Blk;
	export const CharFromStart: (text: Blk, at: Blk) => Blk;
	export const CharFromEnd: (text: Blk, at: Blk) => Blk;
	export const FirstChar: (text: Blk) => Blk;
	export const LastChar: (text: Blk) => Blk;
	export const RandomChar: (text: Blk) => Blk;
	export const Substring: (at1: Blk, at2?: Blk) => Blk;
	export const UpperCase: (text: Blk) => Blk;
	export const LowerCase: (text: Blk) => Blk;
	export const TitleCase: (text: Blk) => Blk;
	export const TrimLeft: (text: Blk) => Blk;
	export const TrimRight: (text: Blk) => Blk;
	export const Trim: (text: Blk) => Blk;
	export const TextCount: (subText: Blk, text: Blk) => Blk;
	export const TextReplace: (text: Blk, fromText: Blk, toText: Blk) => Blk;
	export const RepeatList: (item: Blk, times: Blk) => Blk;
	export const ListLength: (list: Blk) => Blk;
	export const IsListEmpty: (list: Blk) => Blk;
	export const FirstIndexOf: (list: Blk, findItem: Blk) => Blk;
	export const LastIndexOf: (list: Blk, findItem: Blk) => Blk;
	export const ListGet: (list: Blk, at: Blk) => Blk;
	export const ListRemoveGet: (list: Blk, at: Blk) => Blk;
	export const ListRemove: (list: Blk, at: Blk) => Blk;
	export const ListRemoveLast: (list: Blk) => Blk;
	export const ListRemoveFirst: (list: Blk) => Blk;
	export const SubList: (list: Blk, at1: Blk, at2?: Blk) => Blk;
	export const ListSplit: (inputText: Blk, delimText: Blk) => Blk;
	export const ListStringConcat: (strList: Blk, delimText: Blk) => Blk;
	export const ListSort: (list: Blk, desc?: boolean) => Blk;
	export const ListReverse: (list: Blk) => Blk;
	export const ListSet: (list: Blk, at: Blk, item: Blk) => Blk;
	export const ListInsert: (list: Blk, at: Blk, item: Blk) => Blk;
	export const Dict: () => Blk;
	export const DictGet: (dict: Blk, key: Blk) => Blk;
	export const DictSet: (dict: Blk, key: Blk, val: Blk) => Blk;
	export const DictContain: (dict: Blk, key: Blk) => Blk;
	export const DictRemove: (dict: Blk, key: Blk) => Blk;
	export const VarSet: (name: string, value: Blk) => Blk;
	export const VarAdd: (name: string, deltaNum: Blk) => Blk;
	export const ProcReturn: (value?: Blk) => Blk;
	export const ProcIfReturn: (cond: Blk, value?: Blk) => Blk;
	export const DefProcReturn: (name: string, params: string[], body: Blk, returnExpr: Blk) => Blk;
	export const DefProc: (name: string, params: string[], body: Blk) => Blk;
	export const CallProc: (procName: string, ...args: Blk[]) => Blk;
	export const CallProcReturn: (procName: string, ...args: Blk[]) => Blk;
	export const Vec2Zero: () => Blk;
	export const Vec2: (x: Blk, y: Blk) => Blk;
	export const Vec2X: (varName: string) => Blk;
	export const Vec2Y: (varName: string) => Blk;
	export const Vec2Length: (varName: string) => Blk;
	export const Vec2Angle: (varName: string) => Blk;
	export const Vec2Normalize: (v: Blk) => Blk;
	export const Vec2Add: (a: Blk, b: Blk) => Blk;
	export const Vec2Sub: (a: Blk, b: Blk) => Blk;
	export const Vec2MulVec: (a: Blk, b: Blk) => Blk;
	export const Vec2DivVec: (a: Blk, b: Blk) => Blk;
	export const Vec2Distance: (a: Blk, b: Blk) => Blk;
	export const Vec2Dot: (a: Blk, b: Blk) => Blk;
	export const Vec2MulNum: (v: Blk, n: Blk) => Blk;
	export const Vec2DivNum: (v: Blk, n: Blk) => Blk;
	export const Vec2Clamp: (v: Blk, min: Blk, max: Blk) => Blk;
	export const CreateNode: () => Blk;
	export const CreateSprite: (file: Blk) => Blk;
	export const CreateLabel: (fontName: Blk, size: Blk) => Blk;
	export const LabelSetText: (varName: string, text: Blk) => Blk;
	export const NodeAddChild: (parentVar: string, childVar: string, order: Blk) => Blk;
	export const NodeSetX: (varName: string, n: Blk) => Blk;
	export const NodeSetY: (varName: string, n: Blk) => Blk;
	export const NodeSetWidth: (varName: string, n: Blk) => Blk;
	export const NodeSetHeight: (varName: string, n: Blk) => Blk;
	export const NodeSetAngle: (varName: string, n: Blk) => Blk;
	export const NodeSetScale: (varName: string, n: Blk) => Blk;
	export const NodeSetScaleX: (varName: string, n: Blk) => Blk;
	export const NodeSetScaleY: (varName: string, n: Blk) => Blk;
	export const NodeSetOpactity: (varName: string, n: Blk) => Blk;
	export const NodeGetX: (varName: string) => Blk;
	export const NodeGetY: (varName: string) => Blk;
	export const NodeGetWidth: (varName: string) => Blk;
	export const NodeGetHeight: (varName: string) => Blk;
	export const NodeGetAngle: (varName: string) => Blk;
	export const NodeGetScale: (varName: string) => Blk;
	export const NodeGetScaleX: (varName: string) => Blk;
	export const NodeGetScaleY: (varName: string) => Blk;
	export const NodeGetOpactity: (varName: string) => Blk;
	export const NodeSetVisible: (varName: string, bool: Blk) => Blk;
	export const NodeGetVisible: (varName: string) => Blk;
	export const NodeSetPosition: (varName: string, vec: Blk) => Blk;
	export const NodeSetAnchor: (varName: string, vec: Blk) => Blk;
	export const NodeGetPosition: (varName: string) => Blk;
	export const NodeGetAnchor: (varName: string) => Blk;
	export const BeginPaint: (nodeVar: string, paintBody: Blk) => Blk;
	export const BeginPath: () => Blk;
	export const MoveTo: (x: Blk, y: Blk) => Blk;
	export const BezierTo: (c1x: Blk, c1y: Blk, c2x: Blk, c2y: Blk, x: Blk, y: Blk) => Blk;
	export const LineTo: (x: Blk, y: Blk) => Blk;
	export const ClosePath: () => Blk;
	export const FillColor: (color: Blk, opacity: Blk) => Blk;
	export const Fill: () => Blk;
	export const StrokeColor: (color: Blk, opacity: Blk) => Blk;
	export const StrokeWidth: (w: Blk) => Blk;
	export const Stroke: () => Blk;
	export const Rect: (x: Blk, y: Blk, w: Blk, h: Blk) => Blk;
	export const RoundedRect: (x: Blk, y: Blk, w: Blk, h: Blk, r: Blk) => Blk;
	export const Ellipse: (cx: Blk, cy: Blk, rx: Blk, ry: Blk) => Blk;
	export const Circle: (cx: Blk, cy: Blk, radius: Blk) => Blk;
	export const Color: (hex: string) => Blk;
	export const OnUpdate: (nodeVar: string, dtVar: string, actionBody: Blk) => Blk;
	export type TapEvent = "TapBegan" | "TapMoved" | "TapEnded" | "Tapped";
	export const OnTapEvent: (nodeVar: string, event: TapEvent, touchVar: string, actionBody: Blk) => Blk;
	export type KeyName = 'Return' | 'Escape' | 'BackSpace' | 'Tab' | 'Space' | '!' | '"' | '#' | '%' | '$' | '&' | '\'' | '(' | ')' | '*' | '+' | ',' | '-' | '.' | '/' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' | '0' | ':' | ';' | '<' | '=' | '>' | '?' | '@' | '[' | '\\' | ']' | '^' | '_' | '`' | 'A' | 'B' | 'C' | 'D' | 'E' | 'F' | 'G' | 'H' | 'I' | 'J' | 'K' | 'L' | 'M' | 'N' | 'O' | 'P' | 'Q' | 'R' | 'S' | 'T' | 'U' | 'V' | 'W' | 'X' | 'Y' | 'Z' | 'Delete' | 'CapsLock' | 'F1' | 'F2' | 'F3' | 'F4' | 'F5' | 'F6' | 'F7' | 'F8' | 'F9' | 'F10' | 'F11' | 'F12' | 'PrintScreen' | 'ScrollLock' | 'Pause' | 'Insert' | 'Home' | 'PageUp' | 'End' | 'PageDown' | 'Right' | 'Left' | 'Down' | 'Up' | 'Application' | 'LCtrl' | 'LShift' | 'LAlt' | 'LGui' | 'RCtrl' | 'RShift' | 'RAlt' | 'RGui';
	export type KeyState = "KeyDown" | "KeyUp" | "KeyPressed";
	export const CheckKey: (key: KeyName, state: KeyState) => Blk;
	export const TouchGetId: (touchVar: string) => Blk;
	export const TouchGetLocation: (touchVar: string) => Blk;
	export const TouchGetWorldLocation: (touchVar: string) => Blk;
	export const toBlocklyJSON: (root: Blk, procs?: Blk[]) => string;
	export {};
}
export default Gen;

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
