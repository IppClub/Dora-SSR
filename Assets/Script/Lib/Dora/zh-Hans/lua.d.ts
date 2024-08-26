/** @noSelfInFile */

/////////////////////////////
/// Lua 5.4 Library
/////////////////////////////

type AnyTable = Record<any, any>;
// eslint-disable-next-line @typescript-eslint/ban-types, @typescript-eslint/consistent-type-definitions
type AnyNotNil = {};

/**
 * 该类型是TypescriptToLua提供的语言扩展，当作为值或函数调用时使用。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TBrand 用于唯一标识语言扩展类型的字符串
 */
declare interface LuaExtension<TBrand extends string> {
	readonly __tstlExtension: TBrand;
}

/**
 * 该类型是TypescriptToLua提供的语言扩展，在for-of循环中使用。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TBrand 用于唯一标识语言扩展类型的字符串
 */
declare interface LuaIterationExtension<TBrand extends string> {
	readonly __tstlIterable: TBrand;
}

/**
 * 通过使用LuaMultiReturn元组，可以从函数中返回多个值。
 * 你可以在这个链接中找到更多相关信息：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param T 元组类型，其中每个元素的类型代表一个返回值的类型。
 * @param values 函数返回的值。
 */
declare const $multi: (<T extends any[]>(...values: T) => LuaMultiReturn<T>) & LuaExtension<"MultiFunction">;

/**
 * 将多个返回值表示为元组。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param T 每个元素类型代表返回值类型的元组类型。
 */
declare type LuaMultiReturn<T extends any[]> = T & {
	readonly __tstlMultiReturn: any;
};

/**
 * 在for...of中使用时创建Lua风格的数字for循环（for i=start,limit,step）。在任何其他上下文中都无效。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param start 要遍历的序列中的第一个数字。
 * @param limit 要遍历的序列中的最后一个数字。
 * @param step 每次迭代的增量。
 */
declare const $range: ((start: number, limit: number, step?: number) => Iterable<number>) &
	LuaExtension<"RangeFunction">;

/**
 * 转译为全局变量参数（`...`）
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 */
declare const $vararg: string[] & LuaExtension<"VarargConstant">;

/**
 * 从LuaIterable返回的Lua风格迭代器。
 * 对于简单的迭代器（无状态），这只是一个函数。
 * 对于使用状态的复杂迭代器，这是一个LuaMultiReturn元组，包含一个函数、状态对象和传递给函数的初始值。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param state 从LuaIterable返回的状态对象。
 * @param lastValue 从此函数返回的最后一个值。如果迭代LuaMultiReturn值，这是元组的第一个值。
 */
declare type LuaIterator<TValue, TState> = TState extends undefined
	? (this: void) => TValue
	: LuaMultiReturn<
		  [
			  (
				  this: void,
				  state: TState,
				  lastValue: TValue extends LuaMultiReturn<infer TTuple> ? TTuple[0] : TValue
			  ) => TValue,
			  TState,
			  TValue extends LuaMultiReturn<infer TTuple> ? TTuple[0] : TValue
		  ]
	  >;

/**
 * Lua风格的可迭代对象，它在`for...in`循环中迭代单个值（例如`for x in iter() do`）。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TValue 每次迭代返回的值的类型。如果这是LuaMultiReturn，每次迭代将返回多个值。
 * @param TState 每次迭代传回迭代器函数的状态值的类型。
 */
declare type LuaIterable<TValue, TState = undefined> = Iterable<TValue> &
	LuaIterator<TValue, TState> &
	LuaIterationExtension<"Iterable">;

/**
 * 可以使用pairs()进行迭代的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey 每次迭代返回的键的类型。
 * @param TValue 每次迭代返回的值的类型。
 */
declare type LuaPairsIterable<TKey extends AnyNotNil, TValue> = Iterable<[TKey, TValue]> &
	LuaIterationExtension<"Pairs">;

/**
 * 可以使用pairs()进行迭代的对象，其中只使用键值。
 *
 * @param TKey 每次迭代返回的键的类型。
 */
declare type LuaPairsKeyIterable<TKey extends AnyNotNil> = Iterable<TKey> & LuaIterationExtension<"PairsKey">;

/**
 * 对此类型的函数的调用将转译为`left + right`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft 操作的左侧的类型。
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaAddition<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) & LuaExtension<"Addition">;

/**
 * 对此类型的方法的调用将转译为`left + right`，其中`left`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaAdditionMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"AdditionMethod">;

/**
 * 对此类型的函数的调用将转译为`left - right`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft 操作的左侧的类型。
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaSubtraction<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
	LuaExtension<"Subtraction">;

/**
 * 对此类型的方法的调用将转译为`left - right`，其中`left`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaSubtractionMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"SubtractionMethod">;

/**
 * 对此类型的函数的调用将转译为`left * right`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft 操作的左侧的类型。
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaMultiplication<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
	LuaExtension<"Multiplication">;

/**
 * 对此类型的方法的调用将转译为`left * right`，其中`left`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaMultiplicationMethod<TRight, TReturn> = ((right: TRight) => TReturn) &
	LuaExtension<"MultiplicationMethod">;

/**
 * 对此类型的函数的调用将转译为`left / right`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft 操作的左侧的类型。
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaDivision<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) & LuaExtension<"Division">;

/**
 * 对此类型的方法的调用将转译为`left / right`，其中`left`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaDivisionMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"DivisionMethod">;

/**
 * 对此类型的函数的调用将转译为`left % right`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft 操作的左侧的类型。
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaModulo<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) & LuaExtension<"Modulo">;

/**
 * 对此类型的方法的调用将转译为`left % right`，其中`left`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaModuloMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"ModuloMethod">;

/**
 * 对此类型的函数的调用将转译为`left ^ right`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft 操作的左侧的类型。
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaPower<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) & LuaExtension<"Power">;

/**
 * 对此类型的方法的调用将转译为`left ^ right`，其中`left`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaPowerMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"PowerMethod">;

/**
 * 对此类型的函数的调用将转译为`left // right`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft 操作的左侧的类型。
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaFloorDivision<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
	LuaExtension<"FloorDivision">;

/**
 * 对此类型的方法的调用将转译为`left // right`，其中`left`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaFloorDivisionMethod<TRight, TReturn> = ((right: TRight) => TReturn) &
	LuaExtension<"FloorDivisionMethod">;

/**
 * 对此类型的函数的调用将转译为`left & right`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft 操作的左侧的类型。
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaBitwiseAnd<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
	LuaExtension<"BitwiseAnd">;

/**
 * 对此类型的方法的调用将转译为`left & right`，其中`left`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaBitwiseAndMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"BitwiseAndMethod">;

/**
 * 对此类型的函数的调用将转译为`left | right`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft 操作的左侧的类型。
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaBitwiseOr<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
	LuaExtension<"BitwiseOr">;

/**
 * 对此类型的方法的调用将转译为`left | right`，其中`left`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaBitwiseOrMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"BitwiseOrMethod">;

/**
 * 对此类型的函数的调用将转译为`left ~ right`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft 操作的左侧的类型。
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaBitwiseExclusiveOr<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
	LuaExtension<"BitwiseExclusiveOr">;

/**
 * 对此类型的方法的调用将转译为`left ~ right`，其中`left`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaBitwiseExclusiveOrMethod<TRight, TReturn> = ((right: TRight) => TReturn) &
	LuaExtension<"BitwiseExclusiveOrMethod">;

/**
 * 对此类型的函数的调用将转译为`left << right`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft 操作的左侧的类型。
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaBitwiseLeftShift<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
	LuaExtension<"BitwiseLeftShift">;

/**
 * 对此类型的方法的调用将转译为`left << right`，其中`left`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaBitwiseLeftShiftMethod<TRight, TReturn> = ((right: TRight) => TReturn) &
	LuaExtension<"BitwiseLeftShiftMethod">;

/**
 * 对此类型的函数的调用将转译为`left >> right`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft 操作的左侧的类型。
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaBitwiseRightShift<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
	LuaExtension<"BitwiseRightShift">;

/**
 * 对此类型的方法的调用将转译为`left >> right`，其中`left`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaBitwiseRightShiftMethod<TRight, TReturn> = ((right: TRight) => TReturn) &
	LuaExtension<"BitwiseRightShiftMethod">;

/**
 * 对此类型的函数的调用将转译为`left .. right`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft 操作的左侧的类型。
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaConcat<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) & LuaExtension<"Concat">;

/**
 * 对此类型的方法的调用将转译为`left .. right`，其中`left`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaConcatMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"ConcatMethod">;

/**
 * 对此类型的函数的调用将转译为`left < right`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft 操作的左侧的类型。
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaLessThan<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) & LuaExtension<"LessThan">;

/**
 * 对此类型的方法的调用将转译为`left < right`，其中`left`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaLessThanMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"LessThanMethod">;

/**
 * 对此类型的函数的调用将转译为`left > right`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft 操作的左侧的类型。
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaGreaterThan<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
	LuaExtension<"GreaterThan">;

/**
 * 对此类型的方法的调用将转译为`left > right`，其中`left`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight 操作的右侧的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaGreaterThanMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"GreaterThanMethod">;

/**
 * 对此类型的函数的调用将转译为`-operand`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TOperand 操作数的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaNegation<TOperand, TReturn> = ((operand: TOperand) => TReturn) & LuaExtension<"Negation">;

/**
 * 对此类型的方法的调用将转译为`-operand`，其中`operand`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaNegationMethod<TReturn> = (() => TReturn) & LuaExtension<"NegationMethod">;

/**
 * 对此类型的函数的调用将转译为`~operand`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TOperand 操作数的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaBitwiseNot<TOperand, TReturn> = ((operand: TOperand) => TReturn) & LuaExtension<"BitwiseNot">;

/**
 * 对此类型的方法的调用将转译为`~operand`，其中`operand`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaBitwiseNotMethod<TReturn> = (() => TReturn) & LuaExtension<"BitwiseNotMethod">;

/**
 * 对此类型的函数的调用将转译为`#operand`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TOperand 操作数的类型。
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaLength<TOperand, TReturn> = ((operand: TOperand) => TReturn) & LuaExtension<"Length">;

/**
 * 对此类型的方法的调用将转译为`#operand`，其中`operand`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TReturn 操作的结果（返回）类型。
 */
declare type LuaLengthMethod<TReturn> = (() => TReturn) & LuaExtension<"LengthMethod">;

/**
 * 对此类型的函数的调用将转译为`table[key]`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TTable 作为Lua表访问的类型。
 * @param TKey 用于访问表的键的类型。
 * @param TValue 存储在表中的值的类型。
 */
declare type LuaTableGet<TTable extends AnyTable, TKey extends AnyNotNil, TValue> = ((
	table: TTable,
	key: TKey
) => TValue) &
	LuaExtension<"TableGet">;

/**
 * 对此类型的方法的调用将转译为`table[key]`，其中`table`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey 用于访问表的键的类型。
 * @param TValue 存储在表中的值的类型。
 */
declare type LuaTableGetMethod<TKey extends AnyNotNil, TValue> = ((key: TKey) => TValue) &
	LuaExtension<"TableGetMethod">;

/**
 * 对此类型的函数的调用将转译为`table[key] = value`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TTable 作为Lua表访问的类型。
 * @param TKey 用于访问表的键的类型。
 * @param TValue 要分配给表的值的类型。
 */
declare type LuaTableSet<TTable extends AnyTable, TKey extends AnyNotNil, TValue> = ((
	table: TTable,
	key: TKey,
	value: TValue
) => void) &
	LuaExtension<"TableSet">;

/**
 * 对此类型的方法的调用将转译为`table[key] = value`，其中`table`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey 用于访问表的键的类型。
 * @param TValue 要分配给表的值的类型。
 */
declare type LuaTableSetMethod<TKey extends AnyNotNil, TValue> = ((key: TKey, value: TValue) => void) &
	LuaExtension<"TableSetMethod">;

/**
 * 对此类型的函数的调用将转译为`table[key] = true`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TTable 作为Lua表访问的类型。
 * @param TKey 用于访问表的键的类型。
 */
declare type LuaTableAddKey<TTable extends AnyTable, TKey extends AnyNotNil> = ((table: TTable, key: TKey) => void) &
	LuaExtension<"TableAddKey">;

/**
 * 对此类型的方法的调用将转译为`table[key] = true`，其中`table`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 * @param TKey 用于访问表的键的类型。
 */
declare type LuaTableAddKeyMethod<TKey extends AnyNotNil> = ((key: TKey) => void) & LuaExtension<"TableAddKeyMethod">;

/**
 * 对此类型的函数的调用将转译为`table[key] ~= nil`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TTable 作为Lua表访问的类型。
 * @param TKey 用于访问表的键的类型。
 */
declare type LuaTableHas<TTable extends AnyTable, TKey extends AnyNotNil> = ((table: TTable, key: TKey) => boolean) &
	LuaExtension<"TableHas">;

/**
 * 对此类型的方法的调用将转译为`table[key] ~= nil`，其中`table`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey 用于访问表的键的类型。
 */
declare type LuaTableHasMethod<TKey extends AnyNotNil> = ((key: TKey) => boolean) & LuaExtension<"TableHasMethod">;

/**
 * 对此类型的函数的调用将转译为`table[key] = nil`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TTable 作为Lua表访问的类型。
 * @param TKey 用于访问表的键的类型。
 */
declare type LuaTableDelete<TTable extends AnyTable, TKey extends AnyNotNil> = ((table: TTable, key: TKey) => boolean) &
	LuaExtension<"TableDelete">;

/**
 * 对此类型的方法的调用将转译为`table[key] = nil`，其中`table`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey 用于访问表的键的类型。
 */
declare type LuaTableDeleteMethod<TKey extends AnyNotNil> = ((key: TKey) => boolean) &
	LuaExtension<"TableDeleteMethod">;

/**
 * 对此类型的函数的调用将转译为`next(myTable) == nil`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TTable 作为Lua表访问的类型。
 */
declare type LuaTableIsEmpty<TTable extends AnyTable> = ((table: TTable) => boolean) & LuaExtension<"TableIsEmpty">;

/**
 * 对此类型的方法的调用将转译为`next(myTable) == nil`，其中`table`是具有该方法的对象。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 */
declare type LuaTableIsEmptyMethod = (() => boolean) & LuaExtension<"TableIsEmptyMethod">;

/**
 * 方便直接操作Lua表的类型。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey 用于访问表的键的类型。
 * @param TValue 存储在表中的值的类型。
 */
declare interface LuaTable<TKey extends AnyNotNil = AnyNotNil, TValue = any> extends LuaPairsIterable<TKey, TValue> {
	length: LuaLengthMethod<number>;
	get: LuaTableGetMethod<TKey, TValue>;
	set: LuaTableSetMethod<TKey, TValue>;
	has: LuaTableHasMethod<TKey>;
	delete: LuaTableDeleteMethod<TKey>;
	isEmpty: LuaTableIsEmptyMethod;
}

/**
 * 方便直接操作Lua表的类型。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey 用于访问表的键的类型。
 * @param TValue 存储在表中的值的类型。
 */
declare type LuaTableConstructor = (new <TKey extends AnyNotNil = AnyNotNil, TValue = any>() => LuaTable<
	TKey,
	TValue
>) &
	LuaExtension<"TableNew">;

/**
 * 方便直接操作Lua表的类型。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey 用于访问表的键的类型。
 * @param TValue 存储在表中的值的类型。
 */
declare const LuaTable: LuaTableConstructor;

/**
 * 方便直接操作Lua表的类型，用作映射。
 *
 * 这与LuaTable不同，`get`方法可能返回`nil`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 * @param K 用于访问表的键的类型。
 * @param V 存储在表中的值的类型。
 */
declare interface LuaMap<K extends AnyNotNil = AnyNotNil, V = any> extends LuaPairsIterable<K, V> {
	get: LuaTableGetMethod<K, V | undefined>;
	set: LuaTableSetMethod<K, V>;
	has: LuaTableHasMethod<K>;
	delete: LuaTableDeleteMethod<K>;
	isEmpty: LuaTableIsEmptyMethod;
}

/**
 * 方便直接操作Lua表的类型，用作映射。
 *
 * 这与LuaTable不同，`get`方法可能返回`nil`。
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 * @param K 用于访问表的键的类型。
 * @param V 存储在表中的值的类型。
 */
declare const LuaMap: (new <K extends AnyNotNil = AnyNotNil, V = any>() => LuaMap<K, V>) & LuaExtension<"TableNew">;

/**
 * {@link LuaMap}的只读版本。
 *
 * @param K 用于访问表的键的类型。
 * @param V 存储在表中的值的类型。
 */
declare interface ReadonlyLuaMap<K extends AnyNotNil = AnyNotNil, V = any> extends LuaPairsIterable<K, V> {
	get: LuaTableGetMethod<K, V | undefined>;
	has: LuaTableHasMethod<K>;
	isEmpty: LuaTableIsEmptyMethod;
}

/**
 * 方便直接操作Lua表的类型，用作集合。
 *
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 * @param T 用于访问表的键的类型。
 */
declare interface LuaSet<T extends AnyNotNil = AnyNotNil> extends LuaPairsKeyIterable<T> {
	add: LuaTableAddKeyMethod<T>;
	has: LuaTableHasMethod<T>;
	delete: LuaTableDeleteMethod<T>;
	isEmpty: LuaTableIsEmptyMethod;
}

/**
 * 方便直接操作Lua表的类型，用作集合。
 *
 * 更多信息请参见：https://typescripttolua.github.io/docs/advanced/language-extensions
 * @param T 用于访问表的键的类型。
 */
declare const LuaSet: (new <T extends AnyNotNil = AnyNotNil>() => LuaSet<T>) & LuaExtension<"TableNew">;

/**
 * {@link LuaSet}的只读版本。
 *
 * @param T 用于访问表的键的类型。
 */
declare interface ReadonlyLuaSet<T extends AnyNotNil = AnyNotNil> extends LuaPairsKeyIterable<T> {
	has: LuaTableHasMethod<T>;
	isEmpty: LuaTableIsEmptyMethod;
}

interface ObjectConstructor {
	/** 返回对象的键数组，当使用`pairs`迭代时。 */
	keys<K extends AnyNotNil>(o: LuaPairsIterable<K, any> | LuaPairsKeyIterable<K>): K[];

	/** 返回对象的值数组，当使用`pairs`迭代时。 */
	values<V>(o: LuaPairsIterable<any, V>): V[];

	/** 返回对象的键/值数组，当使用`pairs`迭代时。 */
	entries<K extends AnyNotNil, V>(o: LuaPairsIterable<K, V>): Array<[K, V]>;
}

// 基于 https://www.lua.org/manual/5.3/manual.html#2.4

interface LuaMetatable<
	T,
	TIndex extends object | ((this: T, key: any) => any) | undefined =
		| object
		| ((this: T, key: any) => any)
		| undefined
> {
	/**
	 * 加法 (+) 操作。如果加法的任何操作数不是数字
	 * （也不是可以强制转换为数字的字符串），Lua将尝试调用元方法。
	 * 首先，Lua会检查第一个操作数（即使它是有效的）。如果该
	 * 操作数没有为 __add 定义元方法，那么 Lua 将检查
	 * 第二个操作数。如果 Lua 可以找到元方法，它会用两个操作数作为参数调用元方法，
	 * 调用的结果（调整为一个值）就是操作的结果。否则，它会引发错误。
	 */
	__add?(this: T, operand: any): any;

	/**
	 * 减法 (-) 操作。其调用行为类似于加法操作。
	 */
	__sub?(this: T, operand: any): any;

	/**
	 * 乘法 (*) 操作。其调用行为类似于加法操作。
	 */
	__mul?(this: T, operand: any): any;

	/**
	 * 除法 (/) 操作。其调用行为类似于加法操作。
	 */
	__div?(this: T, operand: any): any;

	/**
	 * 取模 (%) 操作。其调用行为类似于加法操作。
	 */
	__mod?(this: T, operand: any): any;

	/**
	 * 幂运算 (^) 操作。其调用行为类似于加法操作。
	 */
	__pow?(this: T, operand: any): any;

	/**
	 * 取反（一元 -）操作。其调用行为类似于加法操作。
	 */
	__unm?(this: T, operand: any): any;

	/**
	 * 连接 (..) 操作。其调用行为类似于加法操作，除了当任何操作数既不是字符串也不是数字时（总是可以强制转换为字符串），Lua 将尝试该元方法。
	 */
	__concat?(this: T, operand: any): any;

	/**
	 * 长度 (#) 操作。如果对象不是字符串，Lua 将尝试该元方法。
	 * 如果有元方法，Lua 会用对象作为参数调用它，调用的结果（总是调整为一个值）就是操作的结果。
	 * 如果没有元方法但对象是表，则 Lua 使用表长度操作（参见 §3.4.7）。否则，Lua 引发错误。
	 */
	__len?(this: T): any;

	/**
	 * 等于 (==) 操作。其调用行为类似于加法操作，除了当被比较的值要么都是表，要么都是完全的用户数据，并且它们在原始上不相等时，Lua 才会尝试元方法。调用的结果总是转换为布尔值。
	 */
	__eq?(this: T, operand: any): boolean;

	/**
	 * 小于 (<) 操作。其调用行为类似于加法操作，除了当被比较的值既不都是数字也不都是字符串时，Lua 才会尝试元方法。调用的结果总是转换为布尔值。
	 */
	__lt?(this: T, operand: any): boolean;

	/**
	 * 小于等于 (<=) 操作。与其他操作不同，小于等于操作可以使用两个不同的事件。首先，Lua 在两个操作数中查找 __le 元方法，就像在小于操作中一样。如果找不到这样的元方法，那么它将尝试 __lt 元方法，假设 a <= b 等价于 not (b < a)。与其他比较运算符一样，结果总是布尔值。 （这种使用 __lt 事件的方式可能会在未来的版本中被移除；它也比真正的 __le 元方法慢。）
	 */
	__le?(this: T, operand: any): boolean;

	/**
	 * 索引访问 table[key]。当 table 不是表或 key 不在 table 中时，会触发此事件。通过调用该元方法做查找访问。
	 *
	 * 尽管名字如此，此事件的元方法可以是函数或表。如果它是函数，它会被调用，参数是 table 和 key，调用的结果（调整为一个值）就是操作的结果。如果它是表，最终结果是用 key 对此表进行索引的结果。（这种索引是常规的，不是原始的，因此可以触发另一个元方法。）
	 */
	__index?: TIndex;

	/**
	 * 索引赋值操作 table[key] = value。类似于索引事件，当 table 不是表或 key 不在 table 中时，会发生此事件。元方法在 table 中查找。
	 *
	 * 与索引一样，此事件的元方法可以是函数或表。如果是函数，它会被调用，参数是 table、key 和 value。如果是表，Lua 会对此表进行索引赋值，键和值与原来的相同。（这种赋值是常规的，不是原始的，因此可以触发另一个元方法。）
	 *
	 * 只要有 __newindex 元方法，Lua 就不会执行原始赋值。（如果需要，元方法本身可以调用 rawset 来执行赋值。）
	 */
	__newindex?: object | ((this: T, key: any, value: any) => void);

	/**
	 * 调用操作 func(args)。当 Lua 尝试调用非函数值时（即，func 不是函数），会发生此事件。元方法在 func 中查找。如果存在，元方法会被调用，func 作为其第一个参数，后面跟着原始调用的参数（args）。调用的所有结果都是操作的结果。（这是唯一允许多个结果的元方法。）
	 */
	__call?(this: T, ...args: any[]): any;

	/**
	 * 如果 v 的元表有一个 __tostring 字段，那么 tostring 会调用相应的值，参数为 v，并使用调用的结果作为其结果。
	 */
	__tostring?(this: T): string;

	/**
	 * 如果此字段是一个包含字符 'k' 的字符串，那么表中的键是弱引用的。如果包含 'v'，表中的值是弱引用的。
	 */
	__mode?: 'k' | 'v' | 'kv';

	/**
	 * 如果对象的元表有此字段，`getmetatable` 返回关联的值。
	 */
	__metatable?: any;

	/**
	 * 用户数据的终结器代码。当用户数据被设置为垃圾收集时，如果元表有一个指向函数的 __gc 字段，那么首先会调用该函数，将用户数据传递给它。__gc 元方法不会被调用表。
	 */
	__gc?(this: T): void;
}

// 基于 https://www.lua.org/manual/5.3/manual.html#6.1

type LuaThread = { readonly __internal__: unique symbol };
type LuaUserdata = { readonly __internal__: unique symbol };

/**
 * 全局变量（非函数），包含运行中的 Lua 版本的字符串。
 */
declare const _VERSION:
	| ('Lua 5.0' | 'Lua 5.0.1' | 'Lua 5.0.2' | 'Lua 5.0.3')
	| 'Lua 5.1'
	| 'Lua 5.2'
	| 'Lua 5.3'
	| 'Lua 5.4';

/**
 * 全局变量（非函数），持有全局环境（参见 §2.2）。Lua 本身不使用此变量；改变其值不会影响任何环境，反之亦然。
 */
declare const _G: typeof globalThis;

/**
 * 如果其参数 `v` 的值为假（即，nil 或 false）则调用 error；否则，返回所有参数。出错时，`message` 是错误对象；如果缺失，它默认为 "assertion failed!"。
 */
declare function assert<V>(v: V): Exclude<V, undefined | null | false>;
declare function assert<V, A extends any[]>(
	v: V,
	...args: A
): LuaMultiReturn<[Exclude<V, undefined | null | false>, ...A]>;

/**
 * 此函数是垃圾收集器的通用接口。根据其第一个参数，opt，执行不同的功能。
 *
 * 执行完整的垃圾收集周期。这是默认选项。
 */
declare function collectgarbage(opt?: 'collect'): void;

/**
 * 此函数是垃圾收集器的通用接口。根据其第一个参数，opt，执行不同的功能。
 *
 * 停止垃圾收集器的自动执行。收集器只会在明确调用时运行，直到重新启动它的调用。
 */
declare function collectgarbage(opt: 'stop'): void;

/**
 * 此函数是垃圾收集器的通用接口。根据其第一个参数，opt，执行不同的功能。
 *
 * 重新启动垃圾收集器的自动执行。
 */
declare function collectgarbage(opt: 'restart'): void;

/**
 * 此函数是垃圾收集器的通用接口。根据其第一个参数，opt，执行不同的功能。
 *
 * 改变垃圾收集器的工作模式。
 */
declare function collectgarbage(opt: 'incremental' | 'generational'): void;

/**
 * 此函数是垃圾收集器的通用接口。根据其第一个参数，opt，执行不同的功能。
 *
 * 获取或设置垃圾收集器参数。如果没有参数，则返回参数的当前值。如果有参数，则设置参数的值并返回当前值。
 */
declare function collectgarbage(opt: 'param', param: 'minormul' | 'majorminor' | 'minormajor' | 'pause' | 'stepmul' | 'stepsize', arg?: number): number;

/**
 * 此函数是垃圾收集器的通用接口。根据其第一个参数，opt，执行不同的功能。
 *
 * 执行垃圾收集步骤。步骤的 "大小" 由 arg 控制。
 * 对于零值，收集器将执行一个基本（不可分割）步骤。
 * 对于非零值，收集器将执行，就像 Lua 分配了该数量的内存（以 KBytes 为单位）。
 * 如果步骤完成了收集周期，则返回 true。
 */
declare function collectgarbage(opt: 'step', arg?: number): boolean;

/**
 * 打开指定的文件并执行其内容作为 Lua 块。当没有参数调用时，dofile 执行标准输入（stdin）的内容。
 * 返回块返回的所有值。如果有错误，dofile 将错误传播给其调用者（即，dofile 不在保护模式下运行）。
 */
declare function dofile(filename?: string): any;

/**
 * 终止最后调用的保护函数并返回 message 作为错误对象。函数 error 永不返回。
 *
 * 通常，error 在消息的开始处添加一些关于错误位置的信息，如果消息是字符串。level 参数指定如何获取错误位置。
 * 使用 level 1（默认），错误位置是调用 error 函数的地方。Level 2 指向调用 error 的函数被调用的地方；依此类推。
 * 传递 level 0 避免在消息中添加错误位置信息。
 */
declare function error(message: string, level?: number): never;

/**
 * 如果对象没有元表，返回 undefined。否则，如果对象的元表有一个 __metatable 字段，返回关联的值。否则，返回给定对象的元表。
 */
declare function getmetatable<T>(object: T): LuaMetatable<T> | undefined;

/**
 * 返回三个值（迭代器函数，表 t 和 0），以便构造
 *
 * `for i,v in ipairs(t) do body end`
 *
 * 将遍历键值对 (1,t[1])，(2,t[2])，...，直到第一个 nil 值。
 */
declare function ipairs<T>(
	t: Record<number, T>
): LuaIterable<LuaMultiReturn<[number, NonNullable<T>]>>;

/**
 * 允许程序遍历表的所有字段。它的第一个参数是表，第二个参数是这个表中的索引。next 返回表的下一个索引及其关联的值。当用 nil 作为第二个参数调用时，next 返回一个初始索引及其关联的值。当在空表中用 nil 调用，或者在最后一个索引上调用时，next 返回 nil。
 * 如果第二个参数缺失，则将其解释为 nil。特别地，你可以使用 next(t) 来检查表是否为空。
 *
 * 索引的枚举顺序并未指定，即使对于数字索引。（要按数字顺序遍历表，使用数字 for。）
 *
 * 如果在遍历过程中，你给表中不存在的字段赋值，next 的行为是未定义的。然而，你可以修改现有的字段。特别地，你可以清除现有的字段。
 */
declare function next(table: object, index?: any): LuaMultiReturn<[any, any] | []>;

/**
 * 如果 t 有一个 __pairs 的元方法，调用它，参数为 t，并返回调用的前三个结果。否则，返回三个值：next 函数，表 t 和 nil，以便构造
 *
 * `for k,v in pairs(t) do body end`
 *
 * 将遍历表 t 的所有键值对。
 *
 * 查看 next 函数以了解在遍历过程中修改表的注意事项。
 */
declare function pairs<TKey extends AnyNotNil, TValue>(
	t: LuaTable<TKey, TValue>
): LuaIterable<LuaMultiReturn<[TKey, NonNullable<TValue>]>>;
declare function pairs<T>(t: T): LuaIterable<LuaMultiReturn<[keyof T, NonNullable<T[keyof T]>]>>;

/**
 * 以保护模式调用函数 f，带有给定的参数。这意味着 f 内的任何错误都不会传播；相反，pcall 捕获错误并返回一个状态码。它的第一个结果是状态码（一个布尔值），如果调用成功并且没有错误，那么就是 true。在这种情况下，pcall 还返回调用的所有结果，这些结果在第一个结果之后。如果有任何错误，pcall 返回 false 加上错误消息。
 */
declare function pcall<This, Args extends any[], R>(
	f: (this: This, ...args: Args) => R,
	context: This,
	...args: Args
): LuaMultiReturn<[true, R] | [false, string]>;

declare function pcall<A extends any[], R>(
	f: (this: void, ...args: A) => R,
	...args: A
): LuaMultiReturn<[true, R] | [false, string]>;

/**
 * 接收任意数量的参数，并将它们的值打印到 stdout，使用 tostring 函数将每个参数转换为字符串。print 不是用于格式化输出，而只是作为快速显示值的方式，例如用于调试。要完全控制输出，请使用 string.format 和 io.write。
 */
declare function print(...args: any[]): void;

/**
 * 检查 v1 是否等于 v2，不调用 __eq 元方法。返回一个布尔值。
 */
declare function rawequal<T>(v1: T, v2: T): boolean;

/**
 * 获取 table[index] 的实际值，不调用 __index 元方法。table 必须是一个表；index 可以是任何值。
 */
declare function rawget<T extends object, K extends keyof T>(table: T, index: K): T[K];

/**
 * 返回对象 v 的长度，该对象必须是表或字符串，不调用 __len 元方法。返回一个整数。
 */
declare function rawlen(v: object | string): number;

/**
 * 将 table[index] 的实际值设置为 value，不调用 __newindex 元方法。table 必须是一个表，index 是除 nil 和 NaN 以外的任何值，value 是任何 Lua 值。
 *
 * 此函数返回 table。
 */
declare function rawset<T extends object, K extends keyof T>(table: T, index: K, value: T[K]): T;

/**
 * 如果索引是数字，返回参数列表中索引之后的所有参数；负数索引表示从末尾开始（-1 是最后一个参数）。否则，索引必须是字符串 "#"，并且 select 返回它接收到的额外参数的总数。
 */
declare function select<T>(index: number, ...args: T[]): LuaMultiReturn<T[]>;

/**
 * 如果索引是数字，返回参数列表中索引之后的所有参数；负数索引表示从末尾开始（-1 是最后一个参数）。否则，索引必须是字符串 "#"，并且 select 返回它接收到的额外参数的总数。
 */
declare function select<T>(index: '#', ...args: T[]): number;

/**
 * 为给定的表设置元表。（要从 Lua 代码更改其他类型的元表，必须使用 debug 库（§6.10））。如果元表是 nil，则移除给定表的元表。如果原始元表有一个 __metatable 字段，会引发错误。
 *
 * 此函数返回表。
 */
declare function setmetatable<
	T extends object,
	TIndex extends object | ((this: T, key: any) => any) | undefined = undefined
>(
	table: T,
	metatable?: LuaMetatable<T, TIndex> | null
): TIndex extends (this: T, key: infer TKey) => infer TValue
	? T & { [K in TKey & string]: TValue }
	: TIndex extends object
	? T & TIndex
	: T;

/**
 * 当没有基数时，tonumber 尝试将其参数转换为数字。如果参数已经是数字或可转换为数字的字符串，则 tonumber 返回此数字；否则，返回 nil。
 *
 * 字符串的转换可能导致整数或浮点数，根据 Lua 的词法约定（参见 §3.1）。（字符串可能有前导和尾随空格以及符号。）
 *
 * 当有基数时，e 必须是一个字符串，将被解释为该基数中的整数数值。基数可以是 2 到 36 之间的任何整数，包括。在大于 10 的基数中，字母 'A'（无论大小写）代表 10，'B' 代表 11，依此类推，'Z' 代表 35。如果字符串 e 不是给定基数中的有效数值，函数返回 nil。
 */
declare function tonumber(e: any, base?: number): number | undefined;

/**
 * 接收任意类型的值，并将其转换为人类可读的格式的字符串。（要完全控制数字的转换方式，使用 string.format。）
 *
 * 如果 v 的元表有一个 __tostring 字段，那么 tostring 调用相应的值，参数为 v，并使用调用的结果作为其结果。
 */
declare function tostring(v: any): string;

/**
 * 返回其唯一参数的类型，编码为字符串。
 */
declare function type(
	v: any
): 'nil' | 'number' | 'string' | 'boolean' | 'table' | 'function' | 'thread' | 'userdata';

// 基于 https://www.lua.org/manual/5.3/manual.html#6.2

/**
 * 此库包括操作协程的操作，这些操作位于表 coroutine 中。
 */
declare namespace coroutine {
	/**
	 * 创建新的协程，其主体为 f。f 必须是函数。返回这个新的协程，一个类型为 "thread" 的对象。
	 */
	function create(f: (...args: any[]) => any): LuaThread;

	/**
	 * 启动或继续执行协程 co。你第一次恢复协程时，它开始运行其主体。值 val1, ... 作为主体函数的参数传递。如果协程已经挂起，resume 会重启它；值 val1, ... 作为 yield 的结果传递。
	 *
	 * 如果协程无错误运行，resume 返回 true 加上任何传递给 yield 的值（当协程挂起时）或主体函数返回的任何值（当协程终止时）。如果有任何错误，resume 返回 false 加上错误消息。
	 */
	function resume(
		 co: LuaThread,
		 ...val: any[]
	): LuaMultiReturn<[true, ...any[]] | [false, string]>;

	/**
	 * 返回协程 co 的状态，作为字符串："running"，如果协程正在运行（即，它调用了 status）；"suspended"，如果协程在调用 yield 中挂起，或者如果它还没有开始运行；"normal" 如果协程是活动的但不在运行（即，它已经恢复了另一个协程）；和 "dead" 如果协程已经完成了其主体函数，或者如果它因错误而停止。
	 */
	function status(co: LuaThread): 'running' | 'suspended' | 'normal' | 'dead';

	/**
	 * 创建新的协程，主体为函数f。f必须是函数。返回的函数每次被调用时都会恢复协程的执行。传递给函数的任何参数都会作为resume的额外参数。返回由resume返回的相同值，除了第一个布尔值。在出现错误的情况下，会传播错误。
	 */
	function wrap(f: (...args: any[]) => any): (...args: any[]) => LuaMultiReturn<any[]>;

	/**
	 * 暂停调用协程的执行。传递给yield的任何参数都会作为resume的额外结果。
	 */
	function yield(...args: any[]): LuaMultiReturn<any[]>;
}

// 基于 https://www.lua.org/manual/5.3/manual.html#6.10

/**
 * 此库为Lua程序提供了调试接口（§4.9）的功能。使用此库时应谨慎。其多个函数违反了Lua代码的基本假设（例如，函数的局部变量不能从外部访问；用户数据元表不能由Lua代码更改；Lua程序不会崩溃），因此可能会破坏原本安全的代码。此外，此库中的一些函数可能会较慢。
 *
 * 此库中的所有函数都在debug表中提供。所有操作线程的函数都有一个可选的第一个参数，该参数是要操作的线程。默认值始终是当前线程。
 */
declare namespace debug {
	/**
	 * 与用户进入交互模式，每次用户输入字符串时都会执行。通过简单的命令和其他调试工具，用户可以查看全局和局部变量，更改它们的值，评估表达式等。只包含单词cont的行会结束此函数，使调用者继续执行。
	 *
	 * 注意，debug.debug的命令不在任何函数中词法嵌套，因此无法直接访问局部变量。
	 */
	function debug(): void;

	/**
	 * 返回线程的当前钩子设置，作为三个值：当前钩子函数，当前钩子掩码，和当前钩子计数（由debug.sethook函数设置）。
	 */
	function gethook(
		thread?: LuaThread
	): LuaMultiReturn<[undefined, 0] | [Function, number, string?]>;

	interface FunctionInfo<T extends Function = Function> {
		/**
		 * 函数本身。
		 */
		func: T;

		/**
		 * 函数的合理名称。
		 */
		name?: string;
		/**
		 * `name`字段的含义。空字符串表示Lua没有为函数找到名称。
		 */
		namewhat: 'global' | 'local' | 'method' | 'field' | '';

		source: string;
		/**
		 * source的简短版本（最多60个字符），用于错误消息。
		 */
		short_src: string;
		linedefined: number;
		lastlinedefined: number;
		/**
		 * 此函数的类型。
		 */
		what: 'Lua' | 'C' | 'main';

		currentline: number;

		/**
		 * 该函数的upvalue数量。
		 */
		nups: number;
	}

	/**
	 * 返回关于函数的信息的表。你可以直接给出函数，或者你可以给出一个数字作为f的值，该数字表示给定线程的调用堆栈中级别f处运行的函数：级别0是当前函数（getinfo本身）；级别1是调用getinfo的函数（除了尾调用，它们在堆栈上不计数）；依此类推。如果f是大于活动函数数量的数字，那么getinfo返回nil。
	 *
	 * 返回的表可以包含lua_getinfo返回的所有字段，字符串what描述要填充哪些字段。what的默认值是获取所有可用的信息，除了有效行的表。如果存在，选项'f'会添加一个名为func的字段，其中包含函数本身。如果存在，选项'L'会添加一个名为activelines的字段，其中包含有效行的表。
	 *
	 * 例如，表达式debug.getinfo(1,"n").name返回当前函数的名称（如果可以找到合理的名称），表达式debug.getinfo(print)返回包含关于print函数的所有可用信息的表。
	 */
	function getinfo<T extends Function>(f: T): FunctionInfo<T>;
	function getinfo<T extends Function>(f: T, what: string): Partial<FunctionInfo<T>>;
	function getinfo<T extends Function>(thread: LuaThread, f: T): FunctionInfo<T>;
	function getinfo<T extends Function>(
		 thread: LuaThread,
		 f: T,
		 what: string
	): Partial<FunctionInfo<T>>;
	function getinfo(f: number): FunctionInfo | undefined;
	function getinfo(f: number, what: string): Partial<FunctionInfo> | undefined;
	function getinfo(thread: LuaThread, f: number): FunctionInfo | undefined;
	function getinfo(thread: LuaThread, f: number, what: string): Partial<FunctionInfo> | undefined;

	/**
	 * 返回给定值的元表，如果它没有元表，则返回 nil。
	 */
	function getmetatable<T extends any>(value: T): LuaMetatable<T> | undefined;

	/**
	 * 返回注册表（参见 §4.5）。
	 */
	function getregistry(): Record<string, any>;

	/**
	 * 此函数返回函数f的索引为up的上值的名称和值。如果没有给定索引的上值，函数返回 nil。
	 *
	 * 以'('（开括号）开头的变量名代表没有已知名称的变量（来自未保存调试信息的块的变量）。
	 */
	function getupvalue(f: Function, up: number): LuaMultiReturn<[string, any] | []>;

	/**
	 * 返回与u关联的Lua值。如果u不是完整的用户数据，返回 nil。
	 */
	function getuservalue(u: LuaUserdata): any;

	/**
	 * 将给定函数设置为钩子。字符串mask和数字count描述何时调用钩子。字符串mask可以包含以下字符的任何组合，含义如下：
	 *
	 * * 'c': 每次Lua调用函数时，都会调用钩子；
	 * * 'r': 每次Lua从函数返回时，都会调用钩子；
	 * * 'l': 每次Lua进入新的代码行时，都会调用钩子。
	 *
	 * 此外，如果count不为零，每执行count条指令后，也会调用钩子。
	 *
	 * 当不带参数调用时，debug.sethook关闭钩子。
	 *
	 * 当钩子被调用时，其第一个参数是一个字符串，描述触发其调用的事件："call"（或"tail call"），"return"，"line"，和"count"。对于行事件，钩子还获取新行号作为其第二个参数。在钩子内部，你可以调用getinfo，级别为2，以获取有关正在运行的函数的更多信息（级别0是getinfo函数，级别1是钩子函数）。
	 */
	function sethook(): void;
	function sethook(
		hook: (event: 'call' | 'return' | 'line' | 'count', line?: number) => any,
		mask: string,
		count?: number
	): void;
	function sethook(
		thread: LuaThread,
		hook: (event: 'call' | 'return' | 'line' | 'count', line?: number) => any,
		mask: string,
		count?: number
	): void;

	/**
	 * 此函数将值value分配给堆栈级别level的函数的索引为local的局部变量。如果没有给定索引的局部变量，函数返回 nil，并在级别超出范围时引发错误。（你可以调用getinfo检查级别是否有效。）否则，它返回局部变量的名称。
	 *
	 * 有关变量索引和名称的更多信息，请参见debug.getlocal。
	 */
	function setlocal(level: number, local: number, value: any): string | undefined;
	function setlocal(
		thread: LuaThread,
		level: number,
		local: number,
		value: any
	): string | undefined;

	/**
	 * 为给定值设置元表，元表为给定表（可以为 nil）。返回值。
	 */
	function setmetatable<
		T extends object,
		TIndex extends object | ((this: T, key: any) => any) | undefined = undefined
	>(
		value: T,
		table?: LuaMetatable<T, TIndex> | null
	): TIndex extends (this: T, key: infer TKey) => infer TValue
		? T & { [K in TKey & string]: TValue }
		: TIndex extends object
		? T & TIndex
		: T;

	/**
	 * 此函数将值value分配给函数f的索引为up的上值。如果没有给定索引的上值，函数返回 nil。否则，它返回上值的名称。
	 */
	function setupvalue(f: Function, up: number, value: any): string | undefined;

	/**
	 * 将指定的值设置为与给定的udata关联的Lua值。udata
	 * 必须是完整的用户数据。
	 *
	 * 返回udata。
	 */
	function setuservalue(udata: LuaUserdata, value: any): LuaUserdata;

	/**
	 * 如果message存在，但不是字符串也不是null，此函数
	 * 不进行进一步处理，直接返回message。否则，返回
	 * 包含调用堆栈跟踪的字符串。可选的message字符串会被添加到
	 * 跟踪的开始处。可选的level数字表示从哪个级别开始跟踪
	 * （默认为1，即调用traceback的函数）。
	 */
	function traceback(message?: string | null, level?: number | null): string;
	function traceback(thread?: LuaThread, message?: string | null, level?: number | null): string;
	function traceback<T>(message: T): T;
	function traceback<T>(thread: LuaThread, message: T): T;
}

// 基于 https://www.lua.org/manual/5.3/manual.html#6.9

interface LuaDateInfo {
	year: number;
	month: number;
	day: number;
	hour?: number;
	min?: number;
	sec?: number;
	isdst?: boolean;
}

interface LuaDateInfoResult {
	year: number;
	month: number;
	day: number;
	hour: number;
	min: number;
	sec: number;
	isdst: boolean;
	yday: number;
	wday: number;
}

/**
 * 操作系统功能
 */
declare namespace os {
	/**
	 * 设置程序的当前区域设置。locale 是一个系统相关的字符串，指定一个区域设置；category 是一个可选字符串，描述要更改的类别："all", "collate", "ctype", "monetary", "numeric", 或 "time"；默认类别是 "all"。该函数返回新区域设置的名称，如果请求无法满足则返回 nil。
	 *
	 * 如果 locale 是空字符串，则当前区域设置被设置为实现定义的本地区域设置。如果 locale 是字符串 "C"，则当前区域设置被设置为标准 C 区域设置。
	 *
	 * 当第一个参数为 nil 时，此函数仅返回给定类别的当前区域设置的名称。
	 *
	 * 由于依赖于 C 函数 setlocale，此函数可能不是线程安全的。
	 */
	function setlocale(
		locale?: string,
		category?: 'all' | 'collate' | 'ctype' | 'monetary' | 'numeric' | 'time'
	): string | undefined;

	/**
	 * 返回一个包含日期和时间的字符串或表，格式根据给定的字符串格式化。
	 *
	 * 如果提供了 time 参数，则这是要格式化的时间（参见 os.time 函数以了解此值的描述）。否则，date 格式化当前时间。
	 *
	 * 如果格式以 '!' 开头，则日期格式化为协调世界时。在此可选字符之后，如果格式是字符串 "*t"，则 date 返回一个包含以下字段的表：year, month (1–12), day (1–31), hour (0–23), min (0–59), sec (0–61), wday (星期几, 1–7, 星期天是 1), yday (一年中的第几天, 1–366), 和 isdst (夏令时标志，一个布尔值)。如果信息不可用，则最后一个字段可能不存在。
	 *
	 * 如果格式不是 "*t"，则 date 返回一个字符串，格式化规则与 ISO C 函数 strftime 相同。
	 *
	 * 当不带参数调用时，date 返回一个合理的日期和时间表示，具体取决于主机系统和当前区域设置。（更具体地说，os.date() 等效于 os.date("%c")。）
	 *
	 * 在非 POSIX 系统上，由于依赖于 C 函数 gmtime 和 C 函数 localtime，此函数可能不是线程安全的。
	 */
	function date(format?: string, time?: number): string;

	/**
	 * 返回一个包含日期和时间的字符串或表，格式根据给定的字符串格式化。
	 *
	 * 如果提供了 time 参数，则这是要格式化的时间（参见 os.time 函数以了解此值的描述）。否则，date 格式化当前时间。
	 *
	 * 如果格式以 '!' 开头，则日期格式化为协调世界时。在此可选字符之后，如果格式是字符串 "*t"，则 date 返回一个包含以下字段的表：year, month (1–12), day (1–31), hour (0–23), min (0–59), sec (0–61), wday (星期几, 1–7, 星期天是 1), yday (一年中的第几天, 1–366), 和 isdst (夏令时标志，一个布尔值)。如果信息不可用，则最后一个字段可能不存在。
	 *
	 * 如果格式不是 "*t"，则 date 返回一个字符串，格式化规则与 ISO C 函数 strftime 相同，示例： "%Y-%m-%d %H:%M:%S"。
	 *
	 * 当不带参数调用时，date 返回一个合理的日期和时间表示，具体取决于主机系统和当前区域设置。（更具体地说，os.date() 等效于 os.date("%c")。）
	 *
	 * 在非 POSIX 系统上，由于依赖于 C 函数 gmtime 和 C 函数 localtime，此函数可能不是线程安全的。
	 */
	function date(format: '*t', time?: number): LuaDateInfoResult;

	/**
	 * 当不带参数调用时，返回当前时间，或者返回由给定表指定的本地日期和时间。这个表必须包含字段 year, month 和 day，并且可以包含字段 hour（默认是 12）, min（默认是 0）, sec（默认是 0）和 isdst（默认是 nil）。其他字段将被忽略。有关这些字段的描述，请参见 os.date 函数。
	 *
	 * 这些字段中的值不需要在其有效范围内。例如，如果 sec 是 -10，则表示在其他字段指定的时间之前的 10 秒；如果 hour 是 1000，则表示在其他字段指定的时间之后的 1000 小时。
	 *
	 * 返回值是一个数字，其含义取决于您的系统。在 POSIX、Windows 和其他一些系统中，这个数字表示自某个给定起始时间（“纪元”）以来的秒数。在其他系统中，这个含义没有指定，time 返回的数字只能作为 os.date 和 os.difftime 的参数使用。
	 */
	function time(): number;

	/**
	 * 当不带参数调用时，返回当前时间，或者返回由给定表指定的本地日期和时间。这个表必须包含字段 year, month 和 day，并且可以包含字段 hour（默认是 12）, min（默认是 0）, sec（默认是 0）和 isdst（默认是 nil）。其他字段将被忽略。有关这些字段的描述，请参见 os.date 函数。
	 *
	 * 这些字段中的值不需要在其有效范围内。例如，如果 sec 是 -10，则表示在其他字段指定的时间之前的 10 秒；如果 hour 是 1000，则表示在其他字段指定的时间之后的 1000 小时。
	 *
	 * 返回值是一个数字，其含义取决于您的系统。在 POSIX、Windows 和其他一些系统中，这个数字表示自某个给定起始时间（“纪元”）以来的秒数。在其他系统中，这个含义没有指定，time 返回的数字只能作为 os.date 和 os.difftime 的参数使用。
	 */
	function time(table: LuaDateInfo): number;

	/**
	 * 返回从时间 t1 到时间 t2 的差值（以秒为单位）（其中时间是 os.time 返回的值）。在 POSIX、Windows 和其他一些系统中，这个值正好是 t2-t1。
	 */
	function difftime(t1: number, t2: number): number;

	/**
	 * 返回进程环境变量 varname 的值，如果变量未定义则返回 nil。
	 */
	function getenv(varname: string): string | undefined;
}

// 基于 https://www.lua.org/manual/5.3/manual.html#6.7

/**
 * 此库提供基本的数学函数。所有函数和常量都在 math 表中提供。带有 "整数/浮点数" 注释的函数对整数参数返回整数结果，对浮点数（或混合）参数返回浮点数结果。取整函数（math.ceil，math.floor 和 math.modf）在结果适合整数范围时返回整数，否则返回浮点数。
 */
declare namespace math {
	/**
	 * 返回 x 的绝对值。（整数/浮点数）
	 */
	function abs(x: number): number;

	/**
	 * 返回 x 的反余弦值（以弧度为单位）。
	 */
	function acos(x: number): number;

	/**
	 * 返回 x 的反正弦值（以弧度为单位）。
	 */
	function asin(x: number): number;

	/**
	 * 返回大于或等于 x 的最小整数值。
	 */
	function ceil(x: number): number;

	/**
	 * 返回 x 的余弦值（假定以弧度为单位）。
	 */
	function cos(x: number): number;

	/**
	 * 将角度 x 从弧度转换为度。
	 */
	function deg(x: number): number;

	/**
	 * 返回值为 e^x（其中 e 是自然对数的底数）。
	 */
	function exp(x: number): number;

	/**
	 * 返回小于或等于 x 的最大整数值。
	 */
	function floor(x: number): number;

	/**
	 * 返回 x 除以 y 的余数，该余数将商向零舍入。（整数/浮点数）
	 */
	function fmod(x: number, y: number): number;

	/**
	 * 浮点值 HUGE_VAL，比任何其他数值都大。
	 */
	const huge: number;

	/**
	 * 根据 Lua 操作符 < 返回具有最大值的参数。（整数/浮点数）
	 */
	function max(x: number, ...numbers: number[]): number;

	/**
	 * 根据 Lua 操作符 < 返回具有最小值的参数。（整数/浮点数）
	 */
	function min(x: number, ...numbers: number[]): number;

	/**
	 * 返回 x 的整数部分和小数部分。其第二个结果始终为浮点数。
	 */
	function modf(x: number): LuaMultiReturn<[number, number]>;

	/**
	 * π 的值。
	 */
	const pi: number;

	/**
	 * 将角度 x 从度转换为弧度。
	 */
	function rad(x: number): number;

	/**
	 * 返回 x 的正弦值（假定以弧度为单位）。
	 */
	function sin(x: number): number;

	/**
	 * 返回 x 的平方根。（也可以使用表达式 x^0.5 来计算此值。）
	 */
	function sqrt(x: number): number;

	/**
	 * 返回 x 的正切值（假定以弧度为单位）。
	 */
	function tan(x: number): number;
}

// 基于 https://www.lua.org/manual/5.3/manual.html#6.3

/**
 * 加载指定模块。此函数首先查看 package.loaded 表以确定 modname 是否已经加载。如果已加载，
 * 则 require 返回存储在 package.loaded[modname] 的值。否则，它会尝试找到模块的加载器。
 *
 * 在寻找加载器时，require 由 package.searchers 序列指导。通过更改此序列，我们可以改变 require 查找模块的方式。
 * 下面的解释基于 package.searchers 的默认配置。
 *
 * 首先，require 查询 package.preload[modname]。如果有值（必须是函数），则此值就是加载器。
 * 否则，require 使用存储在 package.path 中的路径搜索 Lua 加载器。如果还是失败，它会使用存储在 package.cpath 中的路径搜索 C 加载器。
 * 如果还是失败，它会尝试全能加载器（参见 package.searchers）。
 *
 * 一旦找到加载器，require 就会用两个参数调用加载器：modname 和取决于如何获取加载器的额外值。（如果加载器来自文件，此额外值就是文件名。）
 * 如果加载器返回任何非 nil 值，require 就会将返回的值分配给 package.loaded[modname]。
 * 如果加载器没有返回非 nil 值，并且没有给 package.loaded[modname] 分配任何值，那么 require 就会给此项分配 true。
 * 无论如何，require 都会返回 package.loaded[modname] 的最终值。
 *
 * 如果加载或运行模块出现任何错误，或者找不到模块的加载器，那么 require 就会引发错误。
 */
declare function require(modname: string): any;

/**
 * package 库为在 Lua 中加载模块提供了基本设施。它在全局环境中直接导出了一个函数：require。其他所有内容都在 package 表中导出。
 */
declare namespace package {
	/**
	 * 描述一些包的编译时配置的字符串。此字符串是行的序列：
	 * * 第一行是目录分隔符字符串。默认为 '\'（Windows）和 '/'（其他所有系统）。
	 * * 第二行是路径中模板分隔符的字符。默认为 ';'。
	 * * 第三行是模板中替换点标记的字符串。默认为 '?'。
	 * * 第四行是在 Windows 路径中被替换为可执行文件目录的字符串。默认为 '!'。
	 * * 第五行是在构建 luaopen_ 函数名时忽略其后所有文本的标记。默认为 '-'。
	 */
	var config: string;

	/**
	 * require 用于搜索 C 加载器的路径。
	 *
	 * Lua 以与初始化 Lua 路径 package.path 相同的方式初始化 C 路径 package.cpath，使用环境变量 LUA_CPATH_5_3，或环境变量 LUA_CPATH，或在 luaconf.h 中定义的默认路径。
	 */
	var cpath: string;

	/**
	 * require 用于控制哪些模块已经加载的表。当你需要模块 modname 且 package.loaded[modname] 不为 false 时，require 简单地返回存储在那里的值。
	 *
	 * 此变量只是实际表的引用；对此变量的赋值不会改变 require 使用的表。
	 */
	const loaded: Record<string, any>;

	/**
	 * 将主程序与 C 库 libname 动态链接。
	 *
	 * 如果 funcname 是 "*"，那么它只链接库，使库导出的符号对其他动态链接的库可用。否则，它在库内查找函数 funcname 并将此函数作为 C 函数返回。因此，funcname 必须遵循 lua_CFunction 原型（参见 lua_CFunction）。
	 *
	 * 这是低级函数。它完全绕过了包和模块系统。与 require 不同，它不执行任何路径搜索，也不自动添加扩展。libname 必须是 C 库的完整文件名，包括必要的路径和扩展。funcname 必须是 C 库导出的确切名称（可能取决于使用的 C 编译器和链接器）。
	 *
	 * 此函数不受标准 C 支持。因此，它只在某些平台上可用（Windows，Linux，Mac OS X，Solaris，BSD，以及支持 dlfcn 标准的其他 Unix 系统）。
	 */
	function loadlib(
		libname: string,
		funcname: string
	): [Function] | [undefined, string, 'open' | 'init'];

	/**
	 * require 用于搜索 Lua 加载器的路径。
	 *
	 * 在启动时，Lua 使用环境变量 LUA_PATH_5_3 或环境变量 LUA_PATH 的值，或者如果这些环境变量未定义，则使用 luaconf.h 中定义的默认路径初始化此变量。环境变量的值中的任何 ";;" 都被替换为默认路径。
	 */
	var path: string;

	/**
	 * 存储特定模块加载器的表（参见 require）。
	 *
	 * 此变量只是实际表的引用；对此变量的赋值不会改变 require 使用的表。
	 */
	const preload: Record<string, (modname: string, fileName?: string) => any>;

	/**
	 * 在给定路径中搜索给定名称。
	 *
	 * 路径是包含由分号分隔的模板序列的字符串。对于每个模板，函数将模板中的每个问号（如果有）替换为名称的副本，其中所有 sep 出现（默认为点）都被 rep 替换（默认为系统的目录分隔符），然后尝试打开结果文件名。
	 *
	 * 例如，如果路径是字符串
	 *
	 * `./?.lua;./?.lc;/usr/local/?/init.lua`
	 *
	 * 那么搜索名称 foo.a 将尝试按顺序打开文件 ./foo/a.lua，./foo/a.lc 和 /usr/local/foo/a/init.lua。
	 *
	 * 返回可以在读模式下打开的第一个文件的结果名称（关闭文件后），或者如果没有成功，则返回 nil 加上错误消息。（此错误消息列出了尝试打开的所有文件名。）
	 */
	function searchpath(name: string, path: string, sep?: string, rep?: string): string;
}

// 基于 https://www.lua.org/manual/5.3/manual.html#6.4

/**
 * 此库提供了通用的字符串操作函数，如查找和提取子字符串，以及模式匹配。在 Lua 中索引字符串时，第一个字符位于位置 1（而不是像在 C 中那样位于 0）。允许使用负索引，解释为从字符串的末尾向后索引。因此，最后一个字符位于位置 -1，依此类推。
 *
 * 字符串库将所有函数都提供在 string 表中。它还为字符串设置了元表，其中 __index 字段指向 string 表。因此，你可以以面向对象的风格使用字符串函数。例如，string.byte(s,i) 可以写成 s:byte(i)。
 *
 * 字符串库假定一字节字符编码。
 */
declare namespace string {
	/**
	 * 返回字符 s[i]，s[i+1]，...，s[j] 的内部数字代码。i 的默认值为 1；j 的默认值为 i。这些索引根据 string.sub 函数的规则进行修正。
	 *
	 * 数字代码在不同平台上可能不可移植。
	 */
	function byte(s: string, i?: number): number;
	function byte(s: string, i?: number, j?: number): LuaMultiReturn<number[]>;

	/**
	 * 接收零个或多个整数。返回长度等于参数数量的字符串，其中每个字符的内部数字代码等于其对应的参数。
	 *
	 * 数字代码在不同平台上可能不可移植。
	 */
	function char(...args: number[]): string;

	/**
	 * 返回包含给定函数的二进制表示的字符串，以便稍后在此字符串上加载返回函数的副本（但具有新的上值）。
	 */
	function dump(func: Function): string;

	/**
	 * 在字符串 s 中查找模式（参见 §6.4.1）的第一次匹配。如果找到匹配，find 就返回此次出现在 s 中的开始和结束的索引；否则，返回 nil。第三个可选的数字参数 init 指定开始搜索的位置；其默认值为 1，可以为负。第四个可选参数 plain 为 true 时关闭模式匹配功能，因此函数执行纯“查找子字符串”操作，模式中的字符都不被视为魔术字符。注意，如果给出了 plain，那么也必须给出 init。
	 *
	 * 如果模式有捕获，那么在成功匹配时，也会返回捕获的值，放在两个索引之后。
	 */
	function find(
		s: string,
		pattern: string,
		init?: number,
		plain?: boolean
	): LuaMultiReturn<[number, number, ...string[]] | []>;

	/**
	 * 返回其可变数量的参数的格式化版本，该版本遵循其第一个参数（必须为字符串）中给出的描述。格式字符串遵循 ISO C 函数 sprintf 的相同规则。唯一的区别是选项/修饰符 *, h, L, l, n, 和 p 不受支持，并且有一个额外的选项，q。
	 *
	 * q 选项将字符串格式化为双引号之间，必要时使用转义序列，以确保可以通过 Lua 解释器安全地读回。例如，调用
	 *
	 * `string.format('%q', 'a string with "quotes" and \n new line')`
	 *
	 * 可能会产生字符串：
	 *
	 * `"a string with \"quotes\" and \
	 *  new line"` 选项 A, a, E, e, f, G, 和 g 都期望数字作为参数。选项 c, d, i, o, u, X, 和 x 期望整数。当 Lua 使用 C89 编译器编译时，选项 A 和 a（十六进制浮点数）不支持任何修饰符（标志，宽度，长度）。
	 *
	 * 选项 s 期望字符串；如果其参数不是字符串，那么将其转换为字符串，遵循 tostring 的相同规则。如果选项有任何修饰符（标志，宽度，长度），字符串参数不应包含嵌入的零。
	 */
	function format(formatstring: string, ...args: any[]): string;

	/**
	 * 返回一个迭代器函数，每次调用它时，都会返回字符串 s 上的模式（参见 §6.4.1）的下一次捕获。如果模式未指定捕获，那么在每次调用中都会产生整个匹配。
	 *
	 * 作为示例，以下循环将遍历字符串 s 中的所有单词，每行打印一个：
	 *
	 * ```
	 * s = "hello world from Lua"
	 * for w in string.gmatch(s, "%a+") do
	 *   print(w)
	 * end
	 * ```
	 *
	 * 下一个示例将给定字符串中的所有键值对收集到表中：
	 *
	 * ```
	 * t = {}
	 * s = "from=world, to=Lua"
	 * for k, v in string.gmatch(s, "(%w+)=(%w+)") do
	 *   t[k] = v
	 * end
	 * ```
	 *
	 * 对于此函数，模式的开头的插入符号 '^' 不作为锚点，因为这会阻止迭代。
	 */
	function gmatch(s: string, pattern: string): LuaIterable<LuaMultiReturn<string[]>>;

	/**
	 * 返回字符串 s 的副本，其中所有（或前 n 个，如果给定）出现的模式（参见 §6.4.1）都被 repl 指定的替换字符串替换，该替换字符串可以是字符串，表或函数。gsub 还返回其第二个值，即发生的匹配总数。gsub 的名称来自全局替换。
	 *
	 * 如果 repl 是字符串，那么其值用于替换。字符 % 作为转义字符：repl 中的任何形式为 %d 的序列，其中 d 介于 1 和 9 之间，代表第 d 个捕获子字符串的值。序列 %0 代表整个匹配。序列 %% 代表单个 %。
	 *
	 * 如果 repl 是表，那么每次匹配时都会查询该表，使用第一次捕获作为键。
	 *
	 * 如果 repl 是函数，那么每次匹配时都会调用此函数，所有捕获的子字符串按顺序作为参数传递。
	 *
	 * 无论如何，如果模式未指定捕获，那么它的行为就好像整个模式都在捕获内部。
	 *
	 * 如果表查询或函数调用返回的值是字符串或数字，那么它将用作替换字符串；否则，如果它是 false 或 nil，那么没有替换（也就是说，原始匹配保留在字符串中）。
	 */
	function gsub(
		s: string,
		pattern: string,
		repl: string | Record<string, string> | ((...matches: string[]) => string),
		n?: number
	): LuaMultiReturn<[string, number]>;

	/**
	 * 接收字符串并返回其长度。空字符串 "" 的长度为 0。计数嵌入的零，因此 "a\000bc\000" 的长度为 5。
	 */
	function len(s: string): number;

	/**
	 * 接收字符串并返回此字符串的副本，其中所有大写字母都变为小写。所有其他字符保持不变。大写字母的定义取决于当前的区域设置。
	 */
	function lower(s: string): string;

	/**
	 * 在字符串 s 中查找模式（参见 §6.4.1）的第一次匹配。如果找到匹配，match 就返回模式的捕获；否则返回 nil。如果模式未指定捕获，那么返回整个匹配。第三个可选的数字参数 init 指定开始搜索的位置；其默认值为 1，可以为负。
	 */
	function match(s: string, pattern: string, init?: number): LuaMultiReturn<string[]>;

	/**
	 * 返回字符串 s 的 n 个副本的串联。
	 */
	function rep(s: string, n: number): string;

	/**
	 * 返回字符串 s 的反转副本。
	 */
	function reverse(s: string): string;

	/**
	 * 返回从 i 开始并继续到 j 的 s 的子字符串；i 和 j 可以为负。如果 j 不存在，则假定等于 -1（与字符串长度相同）。特别地，调用 string.sub(s,1,j) 返回长度为 j 的 s 的前缀，string.sub(s, -i)（对于正数 i）返回长度为 i 的 s 的后缀。
	 *
	 * 如果在负索引的转换后，i 小于 1，它将被修正为 1。如果 j 大于字符串长度，它将被修正为该长度。如果在这些修正后，i 大于 j，函数返回空字符串。
	 */
	function sub(s: string, i: number, j?: number): string;

	/**
	 * 接收字符串并返回此字符串的副本，其中所有小写字母都变为大写。所有其他字符保持不变。小写字母的定义取决于当前的区域设置。
	 */
	function upper(s: string): string;
}

// 基于 https://www.lua.org/manual/5.3/manual.html#6.6

/**
 * 此库提供了通用的表操作函数。所有函数都在 table 表中提供。
 *
 * 请记住，每当操作需要表的长度时，都适用有关长度运算符的所有注意事项（参见 §3.4.7）。所有函数都忽略给定表中的非数字键。
 */
declare namespace table {
	/**
	 * 给定一个所有元素都是字符串或数字的列表，返回字符串 list[i]..sep..list[i+1] ··· sep..list[j]。sep 的默认值为空字符串，i 的默认值为 1，j 的默认值为 #list。如果 i 大于 j，则返回空字符串。
	 */
	function concat(list: (string | number)[], sep?: string, i?: number, j?: number): string;

	/**
	 * 创建一个新的空表格，并预分配内存。
	 * 当您事先知道表格将有多少元素时，这种预分配可以提高性能并能节省内存，
	 * @param nseq 表格将有的序列元素数量的提示。
	 * @param nrec 表格将有的非序列元素数量的提示。默认为0。
	 * @returns 新的空表格。
	 */
	function create<T extends any[]>(nseq: number, nrec?: number): T

	/**
	 * 在列表的位置 pos 插入元素 value，将元素 list[pos]，list[pos+1]，···，list[#list] 向上移动。pos 的默认值为 #list+1，因此调用 table.insert(t,x) 将 x 插入到列表 t 的末尾。
	 */
	function insert<T>(list: T[], value: T): void;
	function insert<T>(list: T[], pos: number, value: T): void;

	/**
	 * 从列表中移除位置 pos 的元素，返回被移除元素的值。当 pos 是 1 和 #list 之间的整数时，它将元素 list[pos+1]，list[pos+2]，···，list[#list] 向下移动并删除元素 list[#list]；索引 pos 也可以在 #list 为 0 时为 0，或为 #list + 1；在这些情况下，函数删除元素 list[pos]。
	 *
	 * pos 的默认值为 #list，因此调用 table.remove(l) 会移除列表 l 的最后一个元素。
	 */
	function remove<T>(list: T[], pos?: number): T | undefined;

	/**
	 * 按给定顺序对列表元素进行排序，从 list[1] 到 list[#list]。如果给出了 comp，则它必须是接收两个列表元素并在第一个元素在最终顺序中应位于第二个元素之前时返回 true 的函数（因此，在排序后，i < j 意味着不 comp(list[j],list[i])）。如果未给出 comp，则使用标准 Lua 运算符 <。
	 *
	 * 请注意，comp 函数必须在列表中的元素上定义严格的偏序；也就是说，它必须是不对称且可传递的。否则，可能无法进行有效的排序。
	 *
	 * 排序算法不稳定：被给定顺序认为相等的元素可能会因排序而改变其相对位置。
	 */
	function sort<T>(list: T[], comp?: (a: T, b: T) => boolean): void;
}

// Lua 5.2 plus

declare let _ENV: Record<string, any>;

/**
 * 此函数是对垃圾收集器的通用接口。根据其第一个参数 opt，它执行不同的功能。
 *
 * 返回一个布尔值，表示收集器是否正在运行（即，未停止）。
 */
declare function collectgarbage(opt: 'isrunning'): boolean;

/**
 * 创建模块。如果在 package.loaded[name] 中有表，此表就是模块。否则，如果有全局表 t 与给定名称相同，此表就是模块。否则创建新表 t，并将其设置为全局名称的值和 package.loaded[name] 的值。此函数还用给定名称初始化 t._NAME，用模块（t 本身）初始化 t._M，并用包名（完整模块名减去最后组件；参见下文）初始化 t._PACKAGE。最后，module 将 t 设置为当前函数的新环境和 package.loaded[name] 的新值，因此 require 返回 t。
 *
 * 如果 name 是复合名称（即，由点分隔的组件），module 为每个组件创建（或重用，如果它们已经存在）表。例如，如果 name 是 a.b.c，那么 module 在全局 a 的字段 b 的字段 c 中存储模块表。
 *
 * 此函数可以在模块名称后接收可选选项，其中每个选项都是要应用于模块的函数。
 */
declare function module(name: string, ...options: Function[]): void;

declare namespace package {
	/**
	 * 由 require 使用的表，用于控制如何加载模块。
	 *
	 * 此表中的每个条目都是搜索器函数。在寻找模块时，require 按升序调用这些搜索器，其唯一参数为模块名称（给 require 的参数）。函数可以返回另一个函数（模块加载器）以及将传递给该加载器的额外值，或者一个字符串，解释为什么找不到该模块（或者如果它无话可说，则为 nil）。
	 *
	 * Lua 使用四个搜索器函数初始化此表。
	 *
	 * 第一个搜索器只是在 package.preload 表中寻找加载器。
	 *
	 * 第二个搜索器以 Lua 库的形式寻找加载器，使用存储在 package.path 中的路径。搜索按照函数 package.searchpath 中的描述进行。
	 *
	 * 第三个搜索器以 C 库的形式寻找加载器，使用变量 package.cpath 给出的路径。同样，搜索按照函数 package.searchpath 中的描述进行。例如，如果 C 路径是字符串
	 *
	 * `./?.so;./?.dll;/usr/local/?/init.so`
	 *
	 * 那么搜索模块 foo 的搜索器将尝试按顺序打开文件 ./foo.so，./foo.dll 和 /usr/local/foo/init.so。一旦找到 C 库，此搜索器首先使用动态链接设施将应用程序与库链接。然后，它尝试在库内找到一个 C 函数，用作加载器。此 C 函数的名称是字符串 "luaopen_" 与模块名称的副本连接，其中每个点都被下划线替换。此外，如果模块名称有连字符，其后（包括）第一个连字符后的后缀将被删除。例如，如果模块名称是 a.b.c-v2.1，函数名称将是 luaopen_a_b_c。
	 *
	 * 第四个搜索器尝试全能加载器。它在 C 路径中搜索给定模块的根名称的库。例如，当需要 a.b.c 时，它将搜索 a 的 C 库。如果找到，它会在其中寻找子模块的打开函数；在我们的示例中，那将是 luaopen_a_b_c。有了这个设施，包可以将几个 C 子模块打包到单个库中，每个子模块保持其原始打开函数。
	 *
	 * 除第一个（预加载）之外的所有搜索器都返回作为额外值的模块找到的文件名，由 package.searchpath 返回。第一个搜索器不返回额外值。
	 */
	var searchers: (
		| ((modname: string) => LuaMultiReturn<[(modname: string) => void]>)
		| (<T>(modname: string) => LuaMultiReturn<[(modname: string, extra: T) => T, T]>)
		| string
	)[];
}

declare namespace table {
	/**
	 * 返回给定列表中的元素。此函数等同于
	 *
	 * `return list[i], list[i+1], ···, list[j]`
	 *
	 * 默认情况下，i 是 1，j 是 #list。
	 */
	function unpack<T extends any[]>(list: T): LuaMultiReturn<T>;
	function unpack<T>(list: T[], i: number, j?: number): LuaMultiReturn<T[]>;

	/**
	 * 返回新表，所有参数存储在键 1, 2, 等等，并带有字段 "n" 表示参数的总数。注意，结果表可能不是序列。
	 */
	function pack<T extends any[]>(...args: T): T & { n: number };
}

declare namespace debug {
	interface FunctionInfo<T extends Function> {
		istailcall: boolean;
	}
}

interface LuaMetatable<T> {
	/**
	 * 当调用 `for k,v in pairs(tbl) do ... end` 时，处理通过表对进行迭代。
	 */
	__pairs?<T>(t: T): [(t: T, index?: any) => [any, any], T];

	/**
	 * 当调用 `for k,v in ipairs(tbl) do ... end` 时，处理通过表对进行迭代。
	 */
	__ipairs?<T extends object>(t: T): [(t: T, index?: number) => [number, any], T, 0];
}

declare namespace coroutine {
	/**
	 * 返回正在运行的协程以及布尔值，当正在运行的协程是主协程时为 true。
	 */
	function running(): LuaMultiReturn<[LuaThread, boolean]>;
}

// Lua 5.2 plus or jit

/**
 * 加载代码块。
 *
 * 如果 chunk 是字符串，那么代码块就是此字符串。如果 chunk 是函数，load
 * 会反复调用它以获取代码块片段。每次对 chunk 的调用都必须返回
 * 与前面结果连接的字符串。返回空字符串、nil 或无值表示代码块的结束。
 *
 * 如果没有语法错误，返回编译后的代码块作为函数；
 * 否则，返回 nil 加上错误消息。
 *
 * 如果结果函数有上值，第一个上值设置为 env 的值（如果给出了该参数），
 * 或设置为全局环境的值。其他上值用 nil 初始化。 （当你加载主代码块时，
 * 结果函数将始终有一个上值，即 _ENV 变量（参见 §2.2）。然而，当你加载由函数
 * 创建的二进制代码块（参见 string.dump）时，结果函数可以有任意数量的上值。）
 * 所有上值都是新的，也就是说，它们不与任何其他函数共享。
 *
 * chunkname 用作错误消息和调试信息的代码块名称（参见 §4.9）。如果缺席，
 * 则默认为 chunk（如果 chunk 是字符串），否则为 "=(load)"。
 *
 * 字符串 mode 控制代码块可以是文本还是二进制（即，预编译的代码块）。
 * 它可能是字符串 "b"（仅二进制代码块），"t"（仅文本代码块），
 * 或 "bt"（二进制和文本）。默认为 "bt"。
 *
 * Lua 不检查二进制代码块的一致性。恶意制作的二进制代码块可能会使解释器崩溃。
 */
declare function load(
	chunk: string | (() => string | null | undefined),
	chunkname?: string,
	mode?: 'b' | 't' | 'bt',
	env?: object
): LuaMultiReturn<[() => any] | [undefined, string]>;

/**
* 类似于 load，但是从文件 filename 获取代码块，或者从标准输入获取，
* 如果没有给出文件名。
*/
declare function loadfile(
	filename?: string,
	mode?: 'b' | 't' | 'bt',
	env?: object
): LuaMultiReturn<[() => any] | [undefined, string]>;

/**
* 此函数类似于 pcall，只是它设置了新的消息处理程序 msgh。
*/
declare function xpcall<This, Args extends any[], R, E>(
	f: (this: This, ...args: Args) => R,
	msgh: (this: void, err: any) => E,
	context: This,
	...args: Args
): LuaMultiReturn<[true, R] | [false, E]>;

declare function xpcall<Args extends any[], R, E>(
	f: (this: void, ...args: Args) => R,
	msgh: (err: any) => E,
	...args: Args
): LuaMultiReturn<[true, R] | [false, E]>;

declare namespace debug {
	interface FunctionInfo<T extends Function = Function> {
		nparams: number;
		isvararg: boolean;
	}

	/**
	 * 此函数返回堆栈中级别 f 的函数的索引为 local 的局部变量的名称和值。此函数不仅访问显式局部变量，还访问参数，临时变量等。
	 *
	 * 第一个参数或局部变量的索引为 1，以此类推，按照它们在代码中声明的顺序，只计算函数当前作用域中的活动变量。负索引指的是 vararg 参数；-1 是第一个 vararg 参数。如果没有给定索引的变量，函数返回 nil，并在级别超出范围时引发错误。（你可以调用 debug.getinfo 检查级别是否有效。）
	 *
	 * 以 '('（开括号）开头的变量名代表没有已知名称的变量（例如循环控制变量，以及没有调试信息的块保存的变量）。
	 *
	 * 参数 f 也可以是函数。在这种情况下，getlocal 只返回函数参数的名称。
	 */
	function getlocal(f: Function | number, local: number): LuaMultiReturn<[string, any]>;
	function getlocal(
		thread: LuaThread,
		f: Function | number,
		local: number
	): LuaMultiReturn<[string, any]>;

	/**
	 * 返回给定函数的编号为 n 的上值的唯一标识符（作为轻量级用户数据）。
	 *
	 * 这些唯一标识符允许程序检查不同的闭包是否共享上值。共享上值的 Lua 闭包（即，访问相同的外部局部变量）将为这些上值索引返回相同的 id。
	 */
	function upvalueid(f: Function, n: number): LuaUserdata;

	/**
	 * 使 Lua 闭包 f1 的第 n1 个上值引用 Lua 闭包 f2 的第 n2 个上值。
	 */
	function upvaluejoin(f1: Function, n1: number, f2: Function, n2: number): void;
}

declare namespace math {
	/**
	 * 返回 x 在给定基数中的对数。基数的默认值为 e（因此该函数返回 x 的自然对数）。
	 */
	function log(x: number, base?: number): number;
}

declare namespace string {
	/**
	 * 返回字符串，该字符串是由字符串 s 的 n 份副本组成，这些副本由字符串 sep 分隔。sep 的默认值为空字符串（即，没有分隔符）。如果 n 不是正数，则返回空字符串。
	 *
	 * （请注意，单次调用此函数就可以很容易地耗尽机器的内存。）
	 */
	function rep(s: string, n: number, sep?: string): string;
}

// Lua 5.3 plus

/**
 * 此函数是对垃圾收集器的通用接口。根据其第一个参数 opt，它执行不同的功能。
 *
 * 返回 Lua 使用的总内存（以 Kbytes 为单位）。该值有小数部分，因此乘以 1024 可以得到 Lua 实际使用的字节数（除非溢出）。
 */
declare function collectgarbage(opt: 'count'): number;

declare namespace math {
	/**
	 * 返回 y/x 的反正切值（以弧度为单位），但使用两个参数的符号来确定结果的象限。（当 x 为零时，也能正确处理。）
	 *
	 * x 的默认值为 1，因此调用 math.atan(y) 返回 y 的反正切值。
	 */
	function atan(y: number, x?: number): number;

	/**
	 * 具有整数最小值的整数。
	 */
	const mininteger: number;

	/**
	 * 具有整数最大值的整数。
	 */
	const maxinteger: number;

	/**
	 * 如果值 x 可转换为整数，则返回该整数。否则，返回 nil。
	 */
	function tointeger(x: number): number;

	/**
	 * 如果 x 是整数，则返回 "integer"，如果是浮点数，则返回 "float"，如果 x 不是数字，则返回 nil。
	 */
	function type(x: number): 'integer' | 'float' | undefined;

	/**
	 * 返回布尔值，当且仅当整数 m 在作为无符号整数比较时低于整数 n。
	 */
	function ult(m: number, n: number): boolean;
}

declare namespace table {
	/**
	 * 将元素从表 a1 移动到表 a2，执行等效于以下多重赋值：a2[t],··· = a1[f],···,a1[e]。a2 的默认值为 a1。目标范围可以与源范围重叠。要移动的元素数量必须适合 Lua 整数。
	 *
	 * 返回目标表 a2。
	 */
	function move<T1, T2 = T1>(a1: T1[], f: number, e: number, t: number, a2?: T2[]): (T2 | T1)[];
}

declare namespace string {
	/**
	 * 返回包含给定函数的二进制表示（二进制块）的字符串，以便稍后在此字符串上加载返回函数的副本（但具有新的上值）。如果 strip 是真值，二进制表示可能不包含有关函数的所有调试信息，以节省空间。
	 *
	 * 具有上值的函数只保存其上值的数量。重新加载时，这些上值接收包含 nil 的新实例。（你可以使用调试库以适合你的需求的方式序列化和重新加载函数的上值。）
	 */
	function dump(func: Function, strip?: boolean): string;

	/**
	 * 返回包含值 v1，v2 等的二进制字符串，这些值根据格式字符串 fmt 打包（即，以二进制形式序列化）。
	 */
	function pack(fmt: string, ...values: any[]): string;

	/**
	 * 根据格式字符串 fmt 返回在字符串 s 中打包的值（参见 string.pack）。可选的 pos 标记在 s 中开始读取的位置（默认为 1）。在读取的值之后，此函数还返回 s 中第一个未读字节的索引。
	 */
	function unpack(fmt: string, s: string, pos?: number): LuaMultiReturn<any[]>;

	/**
	 * 返回由 string.pack 生成的字符串的大小。格式字符串不能有可变长度的选项 's' 或 'z'（参见 §6.4.2）。
	 */
	function packsize(fmt: string): number;
}

declare namespace coroutine {
	/**
	 * 当运行的协程可以挂起时返回 true。
	 *
	 * 如果运行的协程不是主线程并且不在不可挂起的 C 函数内，则该协程是可挂起的。
	 */
	function isyieldable(): boolean;
}

// https://www.lua.org/manual/5.3/manual.html#6.5

/**
 * 此库提供对 UTF-8 编码的基本支持。它在 utf8 表中提供所有的函数。
 * 除了处理编码外，此库不提供对 Unicode 的任何其他支持。任何需要字符含义的操作，
 * 如字符分类，都超出了其范围。
 *
 * 除非另有说明，所有期望字节位置作为参数的函数都假定给定位置是字节序列的开头，
 * 或者是主题字符串的长度加一。与字符串库一样，负索引从字符串的末尾开始计数。
 */
declare namespace utf8 {
	/**
	 * 接收零个或多个整数，将每个整数转换为其对应的 UTF-8 字节序列，
	 * 并返回所有这些序列的连接字符串
	 */
	function char(...args: number[]): string;

	/**
	 * 模式（字符串，而不是函数）"[\0-\x7F\xC2-\xF4][\x80-\xBF]*"（参见 §6.4.1），
	 * 它精确匹配一个 UTF-8 字节序列，假设主题是有效的 UTF-8 字符串。
	 */
	var charpattern: string;

	/**
	 * 返回值，使得构造
	 *
	 * `for p, c in utf8.codes(s) do body end`
	 *
	 * 将遍历字符串 s 中的所有字符，其中 p 是位置（以字节为单位），
	 * c 是每个字符的代码点。如果遇到任何无效的字节序列，它会引发错误。
	 */
	function codes<S extends string>(
		s: S
	): [(s: S, index?: number) => LuaMultiReturn<[number, number]>, S, 0];

	/**
	 * 返回从字符串 s 中开始在字节位置 i 和 j（都包括在内）的所有字符的代码点（作为整数）。
	 * i 的默认值为 1，j 的默认值为 i。如果遇到任何无效的字节序列，它会引发错误。
	 */
	function codepoint(s: string, i?: number, j?: number): LuaMultiReturn<number[]>;

	/**
	 * 返回字符串 s 中开始在位置 i 和 j（都包括在内）的 UTF-8 字符的数量。
	 * i 的默认值为 1，j 的默认值为 -1。如果找到任何无效的字节序列，返回一个 false 值加上第一个无效字节的位置。
	 */
	function len(s: string, i?: number, j?: number): number;

	/**
	 * 返回 s 中第 n 个字符的编码开始的位置（以字节为单位）。
	 * 负数 n 获取位置 i 之前的字符。当 n 为非负数时，i 的默认值为 1，否则为 #s + 1，
	 * 因此 utf8.offset(s, -n) 获取字符串末尾第 n 个字符的偏移量。如果指定的字符既不在主题中，
	 * 也不在其结束后，函数返回 nil。
	 *
	 * 作为特殊情况，当 n 为 0 时，函数返回包含 s 的第 i 个字节的字符的编码的开始。
	 *
	 * 此函数假定 s 是有效的 UTF-8 字符串。
	 */
	function offset(s: string, n?: number, i?: number): number;
}

interface LuaMetatable<T> {
	/**
	 * 地板除法（//）操作。其调用行为类似于加法操作。
	 */
	__idiv?(this: T, operand: any): any;

	/**
	 * 按位与（&）操作。其调用行为类似于加法操作，除了当任何操作数既不是整数也不是可强制转换为整数的值时，Lua 将尝试元方法（参见 §3.4.3）。
	 */
	__band?(this: T, operand: any): any;

	/**
	 * 按位或（|）操作。其调用行为类似于按位与操作。
	 */
	__bor?(this: T, operand: any): any;

	/**
	 * 按位异或（二进制 ~）操作。其调用行为类似于按位与操作。
	 */
	__bxor?(this: T, operand: any): any;

	/**
	 * 按位非（一元 ~）操作。其调用行为类似于按位与操作。
	 */
	__bnot?(this: T, operand: any): any;

	/**
	 * 按位左移（<<）操作。其调用行为类似于按位与操作。
	 */
	__shl?(this: T, operand: any): any;

	/**
	 * 按位右移（>>）操作。其调用行为类似于按位与操作。
	 */
	__shr?(this: T, operand: any): any;
}

// Lua 5.4 only

declare namespace math {
	/**
	 * 当没有参数调用时，返回在范围 [0,1) 内具有均匀分布的伪随机浮点数。当使用两个整数 m 和 n 调用时，
	 * math.random 返回在范围 [m, n] 内具有均匀分布的伪随机整数。调用 math.random(n)，对于正整数 n，
	 * 等同于 math.random(1,n)。调用 math.random(0) 会产生所有位都是（伪）随机的整数。
	 *
	 * Lua 用对 "随机性" 的弱尝试初始化其伪随机生成器，因此 math.random 应在每次运行程序时生成不同的结果序列。
	 * 为了确保初始状态的所需随机性级别（或相反，为了有确定的序列，例如在调试程序时），你应该显式地调用 math.randomseed。
	 *
	 * 此函数的结果具有良好的统计特性，但它们不具有密码学安全性。（例如，没有保证基于观察一些数量的先前结果就很难预测未来的结果。）
	 */
	function random(m?: number, n?: number): number;

	/**
	 * 将 x 和 y 设置为伪随机生成器的 "种子"：相等的种子产生相等的数字序列。y 的默认值为零。
	 */
	function randomseed(x: number, y?: number): number;
}
