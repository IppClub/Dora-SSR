/** @noSelfInFile */

/////////////////////////////
/// Lua 5.4 Library
/////////////////////////////

type AnyTable = Record<any, any>;
// eslint-disable-next-line @typescript-eslint/ban-types, @typescript-eslint/consistent-type-definitions
type AnyNotNil = {};

/**
 * Indicates a type is a language extension provided by TypescriptToLua when used as a value or function call.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TBrand A string used to uniquely identify the language extension type
 */
declare interface LuaExtension<TBrand extends string> {
    readonly __tstlExtension: TBrand;
}

/**
 * Indicates a type is a language extension provided by TypescriptToLua when used in a for-of loop.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TBrand A string used to uniquely identify the language extension type
 */
declare interface LuaIterationExtension<TBrand extends string> {
    readonly __tstlIterable: TBrand;
}

/**
 * Returns multiple values from a function, by wrapping them in a LuaMultiReturn tuple.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param T A tuple type with each element type representing a return value's type.
 * @param values Return values.
 */
declare const $multi: (<T extends any[]>(...values: T) => LuaMultiReturn<T>) & LuaExtension<"MultiFunction">;

/**
 * Represents multiple return values as a tuple.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param T A tuple type with each element type representing a return value's type.
 */
declare type LuaMultiReturn<T extends any[]> = T & {
    readonly __tstlMultiReturn: any;
};

/**
 * Creates a Lua-style numeric for loop (for i=start,limit,step) when used in for...of. Not valid in any other context.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param start The first number in the sequence to iterate over.
 * @param limit The last number in the sequence to iterate over.
 * @param step The amount to increment each iteration.
 */
declare const $range: ((start: number, limit: number, step?: number) => Iterable<number>) &
    LuaExtension<"RangeFunction">;

/**
 * Transpiles to the global vararg (`...`)
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 */
declare const $vararg: string[] & LuaExtension<"VarargConstant">;

/**
 * Represents a Lua-style iterator which is returned from a LuaIterable.
 * For simple iterators (with no state), this is just a function.
 * For complex iterators that use a state, this is a LuaMultiReturn tuple containing a function, the state, and the initial value to pass to the function.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param state The state object returned from the LuaIterable.
 * @param lastValue The last value returned from this function. If iterating LuaMultiReturn values, this is the first value of the tuple.
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
 * Represents a Lua-style iteratable which iterates single values in a `for...in` loop (ex. `for x in iter() do`).
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TValue The type of value returned each iteration. If this is LuaMultiReturn, multiple values will be returned each iteration.
 * @param TState The type of the state value passed back to the iterator function each iteration.
 */
declare type LuaIterable<TValue, TState = undefined> = Iterable<TValue> &
    LuaIterator<TValue, TState> &
    LuaIterationExtension<"Iterable">;

/**
 * Represents an object that can be iterated with pairs()
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey The type of the key returned each iteration.
 * @param TValue The type of the value returned each iteration.
 */
declare type LuaPairsIterable<TKey extends AnyNotNil, TValue> = Iterable<[TKey, TValue]> &
    LuaIterationExtension<"Pairs">;

/**
 * Represents an object that can be iterated with pairs(), where only the key value is used.
 *
 * @param TKey The type of the key returned each iteration.
 */
declare type LuaPairsKeyIterable<TKey extends AnyNotNil> = Iterable<TKey> & LuaIterationExtension<"PairsKey">;

/**
 * Calls to functions with this type are translated to `left + right`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft The type of the left-hand-side of the operation.
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaAddition<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) & LuaExtension<"Addition">;

/**
 * Calls to methods with this type are translated to `left + right`, where `left` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaAdditionMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"AdditionMethod">;

/**
 * Calls to functions with this type are translated to `left - right`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft The type of the left-hand-side of the operation.
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaSubtraction<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
    LuaExtension<"Subtraction">;

/**
 * Calls to methods with this type are translated to `left - right`, where `left` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaSubtractionMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"SubtractionMethod">;

/**
 * Calls to functions with this type are translated to `left * right`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft The type of the left-hand-side of the operation.
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaMultiplication<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
    LuaExtension<"Multiplication">;

/**
 * Calls to methods with this type are translated to `left * right`, where `left` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaMultiplicationMethod<TRight, TReturn> = ((right: TRight) => TReturn) &
    LuaExtension<"MultiplicationMethod">;

/**
 * Calls to functions with this type are translated to `left / right`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft The type of the left-hand-side of the operation.
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaDivision<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) & LuaExtension<"Division">;

/**
 * Calls to methods with this type are translated to `left / right`, where `left` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaDivisionMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"DivisionMethod">;

/**
 * Calls to functions with this type are translated to `left % right`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft The type of the left-hand-side of the operation.
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaModulo<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) & LuaExtension<"Modulo">;

/**
 * Calls to methods with this type are translated to `left % right`, where `left` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaModuloMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"ModuloMethod">;

/**
 * Calls to functions with this type are translated to `left ^ right`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft The type of the left-hand-side of the operation.
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaPower<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) & LuaExtension<"Power">;

/**
 * Calls to methods with this type are translated to `left ^ right`, where `left` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaPowerMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"PowerMethod">;

/**
 * Calls to functions with this type are translated to `left // right`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft The type of the left-hand-side of the operation.
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaFloorDivision<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
    LuaExtension<"FloorDivision">;

/**
 * Calls to methods with this type are translated to `left // right`, where `left` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaFloorDivisionMethod<TRight, TReturn> = ((right: TRight) => TReturn) &
    LuaExtension<"FloorDivisionMethod">;

/**
 * Calls to functions with this type are translated to `left & right`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft The type of the left-hand-side of the operation.
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaBitwiseAnd<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
    LuaExtension<"BitwiseAnd">;

/**
 * Calls to methods with this type are translated to `left & right`, where `left` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaBitwiseAndMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"BitwiseAndMethod">;

/**
 * Calls to functions with this type are translated to `left | right`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft The type of the left-hand-side of the operation.
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaBitwiseOr<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
    LuaExtension<"BitwiseOr">;

/**
 * Calls to methods with this type are translated to `left | right`, where `left` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaBitwiseOrMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"BitwiseOrMethod">;

/**
 * Calls to functions with this type are translated to `left ~ right`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft The type of the left-hand-side of the operation.
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaBitwiseExclusiveOr<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
    LuaExtension<"BitwiseExclusiveOr">;

/**
 * Calls to methods with this type are translated to `left ~ right`, where `left` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaBitwiseExclusiveOrMethod<TRight, TReturn> = ((right: TRight) => TReturn) &
    LuaExtension<"BitwiseExclusiveOrMethod">;

/**
 * Calls to functions with this type are translated to `left << right`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft The type of the left-hand-side of the operation.
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaBitwiseLeftShift<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
    LuaExtension<"BitwiseLeftShift">;

/**
 * Calls to methods with this type are translated to `left << right`, where `left` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaBitwiseLeftShiftMethod<TRight, TReturn> = ((right: TRight) => TReturn) &
    LuaExtension<"BitwiseLeftShiftMethod">;

/**
 * Calls to functions with this type are translated to `left >> right`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft The type of the left-hand-side of the operation.
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaBitwiseRightShift<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
    LuaExtension<"BitwiseRightShift">;

/**
 * Calls to methods with this type are translated to `left >> right`, where `left` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaBitwiseRightShiftMethod<TRight, TReturn> = ((right: TRight) => TReturn) &
    LuaExtension<"BitwiseRightShiftMethod">;

/**
 * Calls to functions with this type are translated to `left .. right`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft The type of the left-hand-side of the operation.
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaConcat<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) & LuaExtension<"Concat">;

/**
 * Calls to methods with this type are translated to `left .. right`, where `left` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaConcatMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"ConcatMethod">;

/**
 * Calls to functions with this type are translated to `left < right`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft The type of the left-hand-side of the operation.
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaLessThan<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) & LuaExtension<"LessThan">;

/**
 * Calls to methods with this type are translated to `left < right`, where `left` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaLessThanMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"LessThanMethod">;

/**
 * Calls to functions with this type are translated to `left > right`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TLeft The type of the left-hand-side of the operation.
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaGreaterThan<TLeft, TRight, TReturn> = ((left: TLeft, right: TRight) => TReturn) &
    LuaExtension<"GreaterThan">;

/**
 * Calls to methods with this type are translated to `left > right`, where `left` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TRight The type of the right-hand-side of the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaGreaterThanMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"GreaterThanMethod">;

/**
 * Calls to functions with this type are translated to `-operand`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TOperand The type of the value in the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaNegation<TOperand, TReturn> = ((operand: TOperand) => TReturn) & LuaExtension<"Negation">;

/**
 * Calls to method with this type are translated to `-operand`, where `operand` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaNegationMethod<TReturn> = (() => TReturn) & LuaExtension<"NegationMethod">;

/**
 * Calls to functions with this type are translated to `~operand`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TOperand The type of the value in the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaBitwiseNot<TOperand, TReturn> = ((operand: TOperand) => TReturn) & LuaExtension<"BitwiseNot">;

/**
 * Calls to method with this type are translated to `~operand`, where `operand` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaBitwiseNotMethod<TReturn> = (() => TReturn) & LuaExtension<"BitwiseNotMethod">;

/**
 * Calls to functions with this type are translated to `#operand`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TOperand The type of the value in the operation.
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaLength<TOperand, TReturn> = ((operand: TOperand) => TReturn) & LuaExtension<"Length">;

/**
 * Calls to method with this type are translated to `#operand`, where `operand` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TReturn The resulting (return) type of the operation.
 */
declare type LuaLengthMethod<TReturn> = (() => TReturn) & LuaExtension<"LengthMethod">;

/**
 * Calls to functions with this type are translated to `table[key]`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TTable The type to access as a Lua table.
 * @param TKey The type of the key to use to access the table.
 * @param TValue The type of the value stored in the table.
 */
declare type LuaTableGet<TTable extends AnyTable, TKey extends AnyNotNil, TValue> = ((
    table: TTable,
    key: TKey
) => TValue) &
    LuaExtension<"TableGet">;

/**
 * Calls to methods with this type are translated to `table[key]`, where `table` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey The type of the key to use to access the table.
 * @param TValue The type of the value stored in the table.
 */
declare type LuaTableGetMethod<TKey extends AnyNotNil, TValue> = ((key: TKey) => TValue) &
    LuaExtension<"TableGetMethod">;

/**
 * Calls to functions with this type are translated to `table[key] = value`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TTable The type to access as a Lua table.
 * @param TKey The type of the key to use to access the table.
 * @param TValue The type of the value to assign to the table.
 */
declare type LuaTableSet<TTable extends AnyTable, TKey extends AnyNotNil, TValue> = ((
    table: TTable,
    key: TKey,
    value: TValue
) => void) &
    LuaExtension<"TableSet">;

/**
 * Calls to methods with this type are translated to `table[key] = value`, where `table` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey The type of the key to use to access the table.
 * @param TValue The type of the value to assign to the table.
 */
declare type LuaTableSetMethod<TKey extends AnyNotNil, TValue> = ((key: TKey, value: TValue) => void) &
    LuaExtension<"TableSetMethod">;

/**
 * Calls to functions with this type are translated to `table[key] = true`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TTable The type to access as a Lua table.
 * @param TKey The type of the key to use to access the table.
 */
declare type LuaTableAddKey<TTable extends AnyTable, TKey extends AnyNotNil> = ((table: TTable, key: TKey) => void) &
    LuaExtension<"TableAddKey">;

/**
 * Calls to methods with this type are translated to `table[key] = true`, where `table` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 * @param TKey The type of the key to use to access the table.
 */
declare type LuaTableAddKeyMethod<TKey extends AnyNotNil> = ((key: TKey) => void) & LuaExtension<"TableAddKeyMethod">;

/**
 * Calls to functions with this type are translated to `table[key] ~= nil`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TTable The type to access as a Lua table.
 * @param TKey The type of the key to use to access the table.
 */
declare type LuaTableHas<TTable extends AnyTable, TKey extends AnyNotNil> = ((table: TTable, key: TKey) => boolean) &
    LuaExtension<"TableHas">;

/**
 * Calls to methods with this type are translated to `table[key] ~= nil`, where `table` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey The type of the key to use to access the table.
 */
declare type LuaTableHasMethod<TKey extends AnyNotNil> = ((key: TKey) => boolean) & LuaExtension<"TableHasMethod">;

/**
 * Calls to functions with this type are translated to `table[key] = nil`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TTable The type to access as a Lua table.
 * @param TKey The type of the key to use to access the table.
 */
declare type LuaTableDelete<TTable extends AnyTable, TKey extends AnyNotNil> = ((table: TTable, key: TKey) => boolean) &
    LuaExtension<"TableDelete">;

/**
 * Calls to methods with this type are translated to `table[key] = nil`, where `table` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey The type of the key to use to access the table.
 */
declare type LuaTableDeleteMethod<TKey extends AnyNotNil> = ((key: TKey) => boolean) &
    LuaExtension<"TableDeleteMethod">;

/**
 * Calls to functions with this type are translated to `next(myTable) == nil`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TTable The type to access as a Lua table.
 */
declare type LuaTableIsEmpty<TTable extends AnyTable> = ((table: TTable) => boolean) & LuaExtension<"TableIsEmpty">;

/**
 * Calls to methods with this type are translated to `next(myTable) == nil`, where `table` is the object with the method.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 */
declare type LuaTableIsEmptyMethod = (() => boolean) & LuaExtension<"TableIsEmptyMethod">;

/**
 * A convenience type for working directly with a Lua table.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey The type of the keys used to access the table.
 * @param TValue The type of the values stored in the table.
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
 * A convenience type for working directly with a Lua table.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey The type of the keys used to access the table.
 * @param TValue The type of the values stored in the table.
 */
declare type LuaTableConstructor = (new <TKey extends AnyNotNil = AnyNotNil, TValue = any>() => LuaTable<
    TKey,
    TValue
>) &
    LuaExtension<"TableNew">;

/**
 * A convenience type for working directly with a Lua table.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 *
 * @param TKey The type of the keys used to access the table.
 * @param TValue The type of the values stored in the table.
 */
declare const LuaTable: LuaTableConstructor;

/**
 * A convenience type for working directly with a Lua table, used as a map.
 *
 * This differs from LuaTable in that the `get` method may return `nil`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 * @param K The type of the keys used to access the table.
 * @param V The type of the values stored in the table.
 */
declare interface LuaMap<K extends AnyNotNil = AnyNotNil, V = any> extends LuaPairsIterable<K, V> {
    get: LuaTableGetMethod<K, V | undefined>;
    set: LuaTableSetMethod<K, V>;
    has: LuaTableHasMethod<K>;
    delete: LuaTableDeleteMethod<K>;
    isEmpty: LuaTableIsEmptyMethod;
}

/**
 * A convenience type for working directly with a Lua table, used as a map.
 *
 * This differs from LuaTable in that the `get` method may return `nil`.
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 * @param K The type of the keys used to access the table.
 * @param V The type of the values stored in the table.
 */
declare const LuaMap: (new <K extends AnyNotNil = AnyNotNil, V = any>() => LuaMap<K, V>) & LuaExtension<"TableNew">;

/**
 * Readonly version of {@link LuaMap}.
 *
 * @param K The type of the keys used to access the table.
 * @param V The type of the values stored in the table.
 */
declare interface ReadonlyLuaMap<K extends AnyNotNil = AnyNotNil, V = any> extends LuaPairsIterable<K, V> {
    get: LuaTableGetMethod<K, V | undefined>;
    has: LuaTableHasMethod<K>;
    isEmpty: LuaTableIsEmptyMethod;
}

/**
 * A convenience type for working directly with a Lua table, used as a set.
 *
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 * @param T The type of the keys used to access the table.
 */
declare interface LuaSet<T extends AnyNotNil = AnyNotNil> extends LuaPairsKeyIterable<T> {
    add: LuaTableAddKeyMethod<T>;
    has: LuaTableHasMethod<T>;
    delete: LuaTableDeleteMethod<T>;
    isEmpty: LuaTableIsEmptyMethod;
}

/**
 * A convenience type for working directly with a Lua table, used as a set.
 *
 * For more information see: https://typescripttolua.github.io/docs/advanced/language-extensions
 * @param T The type of the keys used to access the table.
 */
declare const LuaSet: (new <T extends AnyNotNil = AnyNotNil>() => LuaSet<T>) & LuaExtension<"TableNew">;

/**
 * Readonly version of {@link LuaSet}.
 *
 * @param T The type of the keys used to access the table.
 */
declare interface ReadonlyLuaSet<T extends AnyNotNil = AnyNotNil> extends LuaPairsKeyIterable<T> {
    has: LuaTableHasMethod<T>;
    isEmpty: LuaTableIsEmptyMethod;
}

interface ObjectConstructor {
    /** Returns an array of keys of an object, when iterated with `pairs`. */
    keys<K extends AnyNotNil>(o: LuaPairsIterable<K, any> | LuaPairsKeyIterable<K>): K[];

    /** Returns an array of values of an object, when iterated with `pairs`. */
    values<V>(o: LuaPairsIterable<any, V>): V[];

    /** Returns an array of key/values of an object, when iterated with `pairs`. */
    entries<K extends AnyNotNil, V>(o: LuaPairsIterable<K, V>): Array<[K, V]>;
}

// Based on https://www.lua.org/manual/5.3/manual.html#2.4

interface LuaMetatable<
    T,
    TIndex extends object | ((this: T, key: any) => any) | undefined =
        | object
        | ((this: T, key: any) => any)
        | undefined
> {
    /**
     * the addition (+) operation. If any operand for an addition is not a number
     * (nor a string coercible to a number), Lua will try to call a metamethod.
     * First, Lua will check the first operand (even if it is valid). If that
     * operand does not define a metamethod for __add, then Lua will check the
     * second operand. If Lua can find a metamethod, it calls the metamethod with
     * the two operands as arguments, and the result of the call (adjusted to one
     * value) is the result of the operation. Otherwise, it raises an error.
     */
    __add?(this: T, operand: any): any;

    /**
     * the subtraction (-) operation. Behavior similar to the addition operation.
     */
    __sub?(this: T, operand: any): any;

    /**
     * the multiplication (*) operation. Behavior similar to the addition
     * operation.
     */
    __mul?(this: T, operand: any): any;

    /**
     * the division (/) operation. Behavior similar to the addition operation.
     */
    __div?(this: T, operand: any): any;

    /**
     * the modulo (%) operation. Behavior similar to the addition operation.
     */
    __mod?(this: T, operand: any): any;

    /**
     * the exponentiation (^) operation. Behavior similar to the addition
     * operation.
     */
    __pow?(this: T, operand: any): any;

    /**
     * the negation (unary -) operation. Behavior similar to the addition
     * operation.
     */
    __unm?(this: T, operand: any): any;

    /**
     * the concatenation (..) operation. Behavior similar to the addition
     * operation, except that Lua will try a metamethod if any operand is neither
     * a string nor a number (which is always coercible to a string).
     */
    __concat?(this: T, operand: any): any;

    /**
     * the length (#) operation. If the object is not a string, Lua will try its
     * metamethod. If there is a metamethod, Lua calls it with the object as
     * argument, and the result of the call (always adjusted to one value) is the
     * result of the operation. If there is no metamethod but the object is a
     * table, then Lua uses the table length operation (see §3.4.7). Otherwise,
     * Lua raises an error.
     */
    __len?(this: T): any;

    /**
     * the equal (==) operation. Behavior similar to the addition operation,
     * except that Lua will try a metamethod only when the values being compared
     * are either both tables or both full userdata and they are not primitively
     * equal. The result of the call is always converted to a boolean.
     */
    __eq?(this: T, operand: any): boolean;

    /**
     * the less than (<) operation. Behavior similar to the addition operation,
     * except that Lua will try a metamethod only when the values being compared
     * are neither both numbers nor both strings. The result of the call is always
     * converted to a boolean.
     */
    __lt?(this: T, operand: any): boolean;

    /**
     * the less equal (<=) operation. Unlike other operations, the less-equal
     * operation can use two different events. First, Lua looks for the __le
     * metamethod in both operands, like in the less than operation. If it cannot
     * find such a metamethod, then it will try the __lt metamethod, assuming that
     * a <= b is equivalent to not (b < a). As with the other comparison
     * operators, the result is always a boolean. (This use of the __lt event can
     * be removed in future versions; it is also slower than a real __le
     * metamethod.)
     */
    __le?(this: T, operand: any): boolean;

    /**
     * The indexing access table[key]. This event happens when table is not a
     * table or when key is not present in table. The metamethod is looked up in
     * table.
     *
     * Despite the name, the metamethod for this event can be either a function or
     * a table. If it is a function, it is called with table and key as arguments,
     * and the result of the call (adjusted to one value) is the result of the
     * operation. If it is a table, the final result is the result of indexing
     * this table with key. (This indexing is regular, not raw, and therefore can
     * trigger another metamethod.)
     */
    __index?: TIndex;

    /**
     * The indexing assignment table[key] = value. Like the index event, this
     * event happens when table is not a table or when key is not present in
     * table. The metamethod is looked up in table.
     *
     * Like with indexing, the metamethod for this event can be either a function
     * or a table. If it is a function, it is called with table, key, and value as
     * arguments. If it is a table, Lua does an indexing assignment to this table
     * with the same key and value. (This assignment is regular, not raw, and
     * therefore can trigger another metamethod.)
     *
     * Whenever there is a __newindex metamethod, Lua does not perform the
     * primitive assignment. (If necessary, the metamethod itself can call rawset
     * to do the assignment.)
     */
    __newindex?: object | ((this: T, key: any, value: any) => void);

    /**
     * The call operation func(args). This event happens when Lua tries to call a
     * non-function value (that is, func is not a function). The metamethod is
     * looked up in func. If present, the metamethod is called with func as its
     * first argument, followed by the arguments of the original call (args). All
     * results of the call are the result of the operation. (This is the only
     * metamethod that allows multiple results.)
     */
    __call?(this: T, ...args: any[]): any;

    /**
     * If the metatable of v has a __tostring field, then tostring calls the
     * corresponding value with v as argument, and uses the result of the call as
     * its result.
     */
    __tostring?(this: T): string;

    /**
     * If this field is a string containing the character 'k', the keys in the
     * table are weak. If it contains 'v', the values in the table are weak.
     */
    __mode?: 'k' | 'v' | 'kv';

    /**
     * If the object's metatable has this field, `getmetatable` returns the
     * associated value.
     */
    __metatable?: any;

    /**
     * Userdata finalizer code. When userdata is set to be garbage collected, if
     * the metatable has a __gc field pointing to a function, that function is
     * first invoked, passing the userdata to it. The __gc metamethod is not
     * called for tables.
     */
    __gc?(this: T): void;
}

// Based on https://www.lua.org/manual/5.3/manual.html#6.1

type LuaThread = { readonly __internal__: unique symbol };
type LuaUserdata = { readonly __internal__: unique symbol };

/**
 * A global variable (not a function) that holds a string containing the running
 * Lua version.
 */
declare const _VERSION:
    | ('Lua 5.0' | 'Lua 5.0.1' | 'Lua 5.0.2' | 'Lua 5.0.3')
    | 'Lua 5.1'
    | 'Lua 5.2'
    | 'Lua 5.3'
    | 'Lua 5.4';

/**
 * A global variable (not a function) that holds the global environment (see
 * §2.2). Lua itself does not use this variable; changing its value does not
 * affect any environment, nor vice versa.
 */
declare const _G: typeof globalThis;

/**
 * Calls error if the value of its argument `v` is false (i.e., nil or false);
 * otherwise, returns all its arguments. In case of error, `message` is the
 * error object; when absent, it defaults to "assertion failed!"
 */
declare function assert<V>(v: V): Exclude<V, undefined | null | false>;
declare function assert<V, A extends any[]>(
    v: V,
    ...args: A
): LuaMultiReturn<[Exclude<V, undefined | null | false>, ...A]>;

/**
 * This function is a generic interface to the garbage collector. It performs
 * different functions according to its first argument, opt.
 *
 * Performs a full garbage-collection cycle. This is the default option.
 */
declare function collectgarbage(opt?: 'collect'): void;

/**
 * This function is a generic interface to the garbage collector. It performs
 * different functions according to its first argument, opt.
 *
 * Stops automatic execution of the garbage collector. The collector will run
 * only when explicitly invoked, until a call to restart it.
 */
declare function collectgarbage(opt: 'stop'): void;

/**
 * This function is a generic interface to the garbage collector. It performs
 * different functions according to its first argument, opt.
 *
 * Restarts automatic execution of the garbage collector.
 */
declare function collectgarbage(opt: 'restart'): void;

/**
 * This function is a generic interface to the garbage collector. It performs
 * different functions according to its first argument, opt.
 *
 * Sets arg as the new value for the pause of the collector (see §2.5). Returns
 * the previous value for pause.
 */
declare function collectgarbage(opt: 'setpause', arg: number): number;

/**
 * This function is a generic interface to the garbage collector. It performs
 * different functions according to its first argument, opt.
 *
 * Sets arg as the new value for the step multiplier of the collector (see
 * §2.5). Returns the previous value for step.
 */
declare function collectgarbage(opt: 'setstepmul', arg: number): number;

/**
 * This function is a generic interface to the garbage collector. It performs
 * different functions according to its first argument, opt.
 *
 * Performs a garbage-collection step. The step "size" is controlled by arg.
 * With a zero value, the collector will perform one basic (indivisible) step.
 * For non-zero values, the collector will perform as if that amount of memory
 * (in KBytes) had been allocated by Lua. Returns true if the step finished a
 * collection cycle.
 */
declare function collectgarbage(opt: 'step', arg: number): boolean;

/**
 * Opens the named file and executes its contents as a Lua chunk. When called
 * without arguments, dofile executes the contents of the standard input
 * (stdin). Returns all values returned by the chunk. In case of errors, dofile
 * propagates the error to its caller (that is, dofile does not run in protected
 * mode).
 */
declare function dofile(filename?: string): any;

/**
 * Terminates the last protected function called and returns message as the
 * error object. Function error never returns.
 *
 * Usually, error adds some information about the error position at the
 * beginning of the message, if the message is a string. The level argument
 * specifies how to get the error position. With level 1 (the default), the
 * error position is where the error function was called. Level 2 points the
 * error to where the function that called error was called; and so on. Passing
 * a level 0 avoids the addition of error position information to the message.
 */
declare function error(message: string, level?: number): never;

/**
 * If object does not have a metatable, returns nil. Otherwise, if the object's
 * metatable has a __metatable field, returns the associated value. Otherwise,
 * returns the metatable of the given object.
 */
declare function getmetatable<T>(object: T): LuaMetatable<T> | undefined;

/**
 * Returns three values (an iterator function, the table t, and 0) so that the
 * construction
 *
 * `for i,v in ipairs(t) do body end`
 *
 * will iterate over the key–value pairs (1,t[1]), (2,t[2]), ..., up to the
 * first nil value.
 */
declare function ipairs<T>(
    t: Record<number, T>
): LuaIterable<LuaMultiReturn<[number, NonNullable<T>]>>;

/**
 * Allows a program to traverse all fields of a table. Its first argument is a
 * table and its second argument is an index in this table. next returns the
 * next index of the table and its associated value. When called with nil as its
 * second argument, next returns an initial index and its associated value. When
 * called with the last index, or with nil in an empty table, next returns nil.
 * If the second argument is absent, then it is interpreted as nil. In
 * particular, you can use next(t) to check whether a table is empty.
 *
 * The order in which the indices are enumerated is not specified, even for
 * numeric indices. (To traverse a table in numerical order, use a numerical
 * for.)
 *
 * The behavior of next is undefined if, during the traversal, you assign any
 * value to a non-existent field in the table. You may however modify existing
 * fields. In particular, you may clear existing fields.
 */
declare function next(table: object, index?: any): LuaMultiReturn<[any, any] | []>;

/**
 * If t has a metamethod __pairs, calls it with t as argument and returns the
 * first three results from the call. Otherwise, returns three values: the next
 * function, the table t, and nil, so that the construction
 *
 * `for k,v in pairs(t) do body end`
 *
 * will iterate over all key–value pairs of table t.
 *
 * See function next for the caveats of modifying the table during its
 * traversal.
 */
declare function pairs<TKey extends AnyNotNil, TValue>(
    t: LuaTable<TKey, TValue>
): LuaIterable<LuaMultiReturn<[TKey, NonNullable<TValue>]>>;
declare function pairs<T>(t: T): LuaIterable<LuaMultiReturn<[keyof T, NonNullable<T[keyof T]>]>>;

/**
 * Calls function f with the given arguments in protected mode. This means that
 * any error inside f is not propagated; instead, pcall catches the error and
 * returns a status code. Its first result is the status code (a boolean), which
 * is true if the call succeeds without errors. In such case, pcall also returns
 * all results from the call, after this first result. In case of any error,
 * pcall returns false plus the error message.
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
 * Receives any number of arguments and prints their values to stdout, using the
 * tostring function to convert each argument to a string. print is not intended
 * for formatted output, but only as a quick way to show a value, for instance
 * for debugging. For complete control over the output, use string.format and
 * io.write.
 */
declare function print(...args: any[]): void;

/**
 * Checks whether v1 is equal to v2, without invoking the __eq metamethod.
 * Returns a boolean.
 */
declare function rawequal<T>(v1: T, v2: T): boolean;

/**
 * Gets the real value of table[index], without invoking the __index metamethod.
 * table must be a table; index may be any value.
 */
declare function rawget<T extends object, K extends keyof T>(table: T, index: K): T[K];

/**
 * Returns the length of the object v, which must be a table or a string,
 * without invoking the __len metamethod. Returns an integer.
 */
declare function rawlen(v: object | string): number;

/**
 * Sets the real value of table[index] to value, without invoking the __newindex
 * metamethod. table must be a table, index any value different from nil and
 * NaN, and value any Lua value.
 *
 * This function returns table.
 */
declare function rawset<T extends object, K extends keyof T>(table: T, index: K, value: T[K]): T;

/**
 * If index is a number, returns all arguments after argument number index; a
 * negative number indexes from the end (-1 is the last argument). Otherwise,
 * index must be the string "#", and select returns the total number of extra
 * arguments it received.
 */
declare function select<T>(index: number, ...args: T[]): LuaMultiReturn<T[]>;

/**
 * If index is a number, returns all arguments after argument number index; a
 * negative number indexes from the end (-1 is the last argument). Otherwise,
 * index must be the string "#", and select returns the total number of extra
 * arguments it received.
 */
declare function select<T>(index: '#', ...args: T[]): number;

/**
 * Sets the metatable for the given table. (To change the metatable of other
 * types from Lua code, you must use the debug library (§6.10).) If metatable is
 * nil, removes the metatable of the given table. If the original metatable has
 * a __metatable field, raises an error.
 *
 * This function returns table.
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
 * When called with no base, tonumber tries to convert its argument to a number.
 * If the argument is already a number or a string convertible to a number, then
 * tonumber returns this number; otherwise, it returns nil.
 *
 * The conversion of strings can result in integers or floats, according to the
 * lexical conventions of Lua (see §3.1). (The string may have leading and
 * trailing spaces and a sign.)
 *
 * When called with base, then e must be a string to be interpreted as an
 * integer numeral in that base. The base may be any integer between 2 and 36,
 * inclusive. In bases above 10, the letter 'A' (in either upper or lower case)
 * represents 10, 'B' represents 11, and so forth, with 'Z' representing 35. If
 * the string e is not a valid numeral in the given base, the function returns
 * nil.
 */
declare function tonumber(e: any, base?: number): number | undefined;

/**
 * Receives a value of any type and converts it to a string in a human-readable
 * format. (For complete control of how numbers are converted, use
 * string.format.)
 *
 * If the metatable of v has a __tostring field, then tostring calls the
 * corresponding value with v as argument, and uses the result of the call as
 * its result.
 */
declare function tostring(v: any): string;

/**
 * Returns the type of its only argument, coded as a string.
 */
declare function type(
    v: any
): 'nil' | 'number' | 'string' | 'boolean' | 'table' | 'function' | 'thread' | 'userdata';

// Based on https://www.lua.org/manual/5.3/manual.html#6.2

/**
 * This library comprises the operations to manipulate coroutines, which come
 * inside the table coroutine.
 */
declare namespace coroutine {
	/**
	 * Creates a new coroutine, with body f. f must be a function. Returns this
	 * new coroutine, an object with type "thread".
	 */
	function create(f: (...args: any[]) => any): LuaThread;

	/**
	 * Starts or continues the execution of coroutine co. The first time you
	 * resume a coroutine, it starts running its body. The values val1, ... are
	 * passed as the arguments to the body function. If the coroutine has yielded,
	 * resume restarts it; the values val1, ... are passed as the results from the
	 * yield.
	 *
	 * If the coroutine runs without any errors, resume returns true plus any
	 * values passed to yield (when the coroutine yields) or any values returned
	 * by the body function (when the coroutine terminates). If there is any
	 * error, resume returns false plus the error message.
	 */
	function resume(
		 co: LuaThread,
		 ...val: any[]
	): LuaMultiReturn<[true, ...any[]] | [false, string]>;

	/**
	 * Returns the status of coroutine co, as a string: "running", if the
	 * coroutine is running (that is, it called status); "suspended", if the
	 * coroutine is suspended in a call to yield, or if it has not started running
	 * yet; "normal" if the coroutine is active but not running (that is, it has
	 * resumed another coroutine); and "dead" if the coroutine has finished its
	 * body function, or if it has stopped with an error.
	 */
	function status(co: LuaThread): 'running' | 'suspended' | 'normal' | 'dead';

	/**
	 * Creates a new coroutine, with body f. f must be a function. Returns a
	 * function that resumes the coroutine each time it is called. Any arguments
	 * passed to the function behave as the extra arguments to resume. Returns the
	 * same values returned by resume, except the first boolean. In case of error,
	 * propagates the error.
	 */
	function wrap(f: (...args: any[]) => any): (...args: any[]) => LuaMultiReturn<any[]>;

	/**
	 * Suspends the execution of the calling coroutine. Any arguments to yield are
	 * passed as extra results to resume.
	 */
	function yield(...args: any[]): LuaMultiReturn<any[]>;
}

// Based on https://www.lua.org/manual/5.3/manual.html#6.10

/**
 * This library provides the functionality of the debug interface (§4.9) to Lua
 * programs. You should exert care when using this library. Several of its
 * functions violate basic assumptions about Lua code (e.g., that variables
 * local to a function cannot be accessed from outside; that userdata metatables
 * cannot be changed by Lua code; that Lua programs do not crash) and therefore
 * can compromise otherwise secure code. Moreover, some functions in this
 * library may be slow.
 *
 * All functions in this library are provided inside the debug table. All
 * functions that operate over a thread have an optional first argument which is
 * the thread to operate over. The default is always the current thread.
 */
declare namespace debug {
	/**
	 * Enters an interactive mode with the user, running each string that the user
	 * enters. Using simple commands and other debug facilities, the user can
	 * inspect global and local variables, change their values, evaluate
	 * expressions, and so on. A line containing only the word cont finishes this
	 * function, so that the caller continues its execution.
	 *
	 * Note that commands for debug.debug are not lexically nested within any
	 * function and so have no direct access to local variables.
	 */
	function debug(): void;

	/**
	 * Returns the current hook settings of the thread, as three values: the
	 * current hook function, the current hook mask, and the current hook count
	 * (as set by the debug.sethook function).
	 */
	function gethook(
		 thread?: LuaThread
	): LuaMultiReturn<[undefined, 0] | [Function, number, string?]>;

	interface FunctionInfo<T extends Function = Function> {
		 /**
		  * The function itself.
		  */
		 func: T;

		 /**
		  * A reasonable name for the function.
		  */
		 name?: string;
		 /**
		  * What the `name` field means. The empty string means that Lua did not find
		  * a name for the function.
		  */
		 namewhat: 'global' | 'local' | 'method' | 'field' | '';

		 source: string;
		 /**
		  * A short version of source (up to 60 characters), useful for error
		  * messages.
		  */
		 short_src: string;
		 linedefined: number;
		 lastlinedefined: number;
		 /**
		  * What this function is.
		  */
		 what: 'Lua' | 'C' | 'main';

		 currentline: number;

		 /**
		  * Number of upvalues of that function.
		  */
		 nups: number;
	}

	/**
	 * Returns a table with information about a function. You can give the
	 * function directly or you can give a number as the value of f, which means
	 * the function running at level f of the call stack of the given thread:
	 * level 0 is the current function (getinfo itself); level 1 is the function
	 * that called getinfo (except for tail calls, which do not count on the
	 * stack); and so on. If f is a number larger than the number of active
	 * functions, then getinfo returns nil.
	 *
	 * The returned table can contain all the fields returned by lua_getinfo, with
	 * the string what describing which fields to fill in. The default for what is
	 * to get all information available, except the table of valid lines. If
	 * present, the option 'f' adds a field named func with the function itself.
	 * If present, the option 'L' adds a field named activelines with the table of
	 * valid lines.
	 *
	 * For instance, the expression debug.getinfo(1,"n").name returns a name for
	 * the current function, if a reasonable name can be found, and the expression
	 * debug.getinfo(print) returns a table with all available information about
	 * the print function.
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
	 * Returns the metatable of the given value or nil if it does not have a
	 * metatable.
	 */
	function getmetatable<T extends any>(value: T): LuaMetatable<T> | undefined;

	/**
	 * Returns the registry table (see §4.5).
	 */
	function getregistry(): Record<string, any>;

	/**
	 * This function returns the name and the value of the upvalue with index up
	 * of the function f. The function returns nil if there is no upvalue with the
	 * given index.
	 *
	 * Variable names starting with '(' (open parenthesis) represent variables
	 * with no known names (variables from chunks saved without debug
	 * information).
	 */
	function getupvalue(f: Function, up: number): LuaMultiReturn<[string, any] | []>;

	/**
	 * Returns the Lua value associated to u. If u is not a full userdata, returns
	 * nil.
	 */
	function getuservalue(u: LuaUserdata): any;

	/**
	 * Sets the given function as a hook. The string mask and the number count
	 * describe when the hook will be called. The string mask may have any
	 * combination of the following characters, with the given meaning:
	 *
	 * * 'c': the hook is called every time Lua calls a function;
	 * * 'r': the hook is called every time Lua returns from a function;
	 * * 'l': the hook is called every time Lua enters a new line of code.
	 *
	 * Moreover, with a count different from zero, the hook is called also after
	 * every count instructions.
	 *
	 * When called without arguments, debug.sethook turns off the hook.
	 *
	 * When the hook is called, its first parameter is a string describing the
	 * event that has triggered its call: "call" (or "tail call"), "return",
	 * "line", and "count". For line events, the hook also gets the new line
	 * number as its second parameter. Inside a hook, you can call getinfo with
	 * level 2 to get more information about the running function (level 0 is the
	 * getinfo function, and level 1 is the hook function).
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
	 * This function assigns the value value to the local variable with index
	 * local of the function at level level of the stack. The function returns nil
	 * if there is no local variable with the given index, and raises an error
	 * when called with a level out of range. (You can call getinfo to check
	 * whether the level is valid.) Otherwise, it returns the name of the local
	 * variable.
	 *
	 * See debug.getlocal for more information about variable indices and names.
	 */
	function setlocal(level: number, local: number, value: any): string | undefined;
	function setlocal(
		 thread: LuaThread,
		 level: number,
		 local: number,
		 value: any
	): string | undefined;

	/**
	 * Sets the metatable for the given value to the given table (which can be
	 * nil). Returns value.
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
	 * This function assigns the value value to the upvalue with index up of the
	 * function f. The function returns nil if there is no upvalue with the given
	 * index. Otherwise, it returns the name of the upvalue.
	 */
	function setupvalue(f: Function, up: number, value: any): string | undefined;

	/**
	 * Sets the given value as the Lua value associated to the given udata. udata
	 * must be a full userdata.
	 *
	 * Returns udata.
	 */
	function setuservalue(udata: LuaUserdata, value: any): LuaUserdata;

	/**
	 * If message is present but is neither a string nor nil, this function
	 * returns message without further processing. Otherwise, it returns a string
	 * with a traceback of the call stack. The optional message string is appended
	 * at the beginning of the traceback. An optional level number tells at which
	 * level to start the traceback (default is 1, the function calling
	 * traceback).
	 */
	function traceback(message?: string | null, level?: number | null): string;
	function traceback(thread?: LuaThread, message?: string | null, level?: number | null): string;
	function traceback<T>(message: T): T;
	function traceback<T>(thread: LuaThread, message: T): T;
}

// Based on https://www.lua.org/manual/5.3/manual.html#6.7

/**
 * This library provides basic mathematical functions. It provides all its
 * functions and constants inside the table math. Functions with the annotation
 * "integer/float" give integer results for integer arguments and float results
 * for float (or mixed) arguments. Rounding functions (math.ceil, math.floor,
 * and math.modf) return an integer when the result fits in the range of an
 * integer, or a float otherwise.
 */
declare namespace math {
	/**
	 * Returns the absolute value of x. (integer/float)
	 */
	function abs(x: number): number;

	/**
	 * Returns the arc cosine of x (in radians).
	 */
	function acos(x: number): number;

	/**
	 * Returns the arc sine of x (in radians).
	 */
	function asin(x: number): number;

	/**
	 * Returns the smallest integral value larger than or equal to x.
	 */
	function ceil(x: number): number;

	/**
	 * Returns the cosine of x (assumed to be in radians).
	 */
	function cos(x: number): number;

	/**
	 * Converts the angle x from radians to degrees.
	 */
	function deg(x: number): number;

	/**
	 * Returns the value ex (where e is the base of natural logarithms).
	 */
	function exp(x: number): number;

	/**
	 * Returns the largest integral value smaller than or equal to x.
	 */
	function floor(x: number): number;

	/**
	 * Returns the remainder of the division of x by y that rounds the quotient
	 * towards zero. (integer/float)
	 */
	function fmod(x: number, y: number): number;

	/**
	 * The float value HUGE_VAL, a value larger than any other numeric value.
	 */
	const huge: number;

	/**
	 * Returns the argument with the maximum value, according to the Lua operator
	 * <. (integer/float)
	 */
	function max(x: number, ...numbers: number[]): number;

	/**
	 * Returns the argument with the minimum value, according to the Lua operator
	 * <. (integer/float)
	 */
	function min(x: number, ...numbers: number[]): number;

	/**
	 * Returns the integral part of x and the fractional part of x. Its second
	 * result is always a float.
	 */
	function modf(x: number): LuaMultiReturn<[number, number]>;

	/**
	 * The value of π.
	 */
	const pi: number;

	/**
	 * Converts the angle x from degrees to radians.
	 */
	function rad(x: number): number;

	/**
	 * Returns the sine of x (assumed to be in radians).
	 */
	function sin(x: number): number;

	/**
	 * Returns the square root of x. (You can also use the expression x^0.5 to
	 * compute this value.)
	 */
	function sqrt(x: number): number;

	/**
	 * Returns the tangent of x (assumed to be in radians).
	 */
	function tan(x: number): number;

    /**
     * When called without arguments, returns a pseudo-random float with uniform
     * distribution in the range [0,1). When called with two integers m and n,
     * math.random returns a pseudo-random integer with uniform distribution in
     * the range [m, n]. The call math.random(n), for a positive n, is equivalent
     * to math.random(1,n). The call math.random(0) produces an integer with all
     * bits (pseudo)random.
     *
     * Lua initializes its pseudo-random generator with a weak attempt for
     * "randomness", so that math.random should generate different sequences of
     * results each time the program runs. To ensure a required level of
     * randomness to the initial state (or contrarily, to have a deterministic
     * sequence, for instance when debugging a program), you should call
     * math.randomseed explicitly.
     *
     * The results from this function have good statistical qualities, but they
     * are not cryptographically secure. (For instance, there are no garanties
     * that it is hard to predict future results based on the observation of some
     * number of previous results.)
     */
    function random(m?: number, n?: number): number;

    /**
     * Sets x and y as the "seed" for the pseudo-random generator: equal seeds
     * produce equal sequences of numbers. The default for y is zero.
     */
    function randomseed(x: number, y?: number): number;
}

// Based on https://www.lua.org/manual/5.3/manual.html#6.3

/**
 * Loads the given module. The function starts by looking into the
 * package.loaded table to determine whether modname is already loaded. If it
 * is, then require returns the value stored at package.loaded[modname].
 * Otherwise, it tries to find a loader for the module.
 *
 * To find a loader, require is guided by the package.searchers sequence. By
 * changing this sequence, we can change how require looks for a module. The
 * following explanation is based on the default configuration for
 * package.searchers.
 *
 * First require queries package.preload[modname]. If it has a value, this value
 * (which must be a function) is the loader. Otherwise require searches for a
 * Lua loader using the path stored in package.path. If that also fails, it
 * searches for a C loader using the path stored in package.cpath. If that also
 * fails, it tries an all-in-one loader (see package.searchers).
 *
 * Once a loader is found, require calls the loader with two arguments: modname
 * and an extra value dependent on how it got the loader. (If the loader came
 * from a file, this extra value is the file name.) If the loader returns any
 * non-nil value, require assigns the returned value to package.loaded[modname].
 * If the loader does not return a non-nil value and has not assigned any value
 * to package.loaded[modname], then require assigns true to this entry. In any
 * case, require returns the final value of package.loaded[modname].
 *
 * If there is any error loading or running the module, or if it cannot find any
 * loader for the module, then require raises an error.
 */
declare function require(modname: string): any;

/**
 * The package library provides basic facilities for loading modules in Lua. It
 * exports one function directly in the global environment: require. Everything
 * else is exported in a table package.
 */
declare namespace package {
    /**
     * A string describing some compile-time configurations for packages. This
     * string is a sequence of lines:
     * * The first line is the directory separator string. Default is '\' for
     *   Windows and '/' for all other systems.
     * * The second line is the character that separates templates in a path.
     *   Default is ';'.
     * * The third line is the string that marks the substitution points in a
     *   template. Default is '?'.
     * * The fourth line is a string that, in a path in Windows, is replaced by
     *   the executable's directory. Default is '!'.
     * * The fifth line is a mark to ignore all text after it when building the
     *   luaopen_ function name. Default is '-'.
     */
    var config: string;

    /**
     * The path used by require to search for a C loader.
     *
     * Lua initializes the C path package.cpath in the same way it initializes the
     * Lua path package.path, using the environment variable LUA_CPATH_5_3, or the
     * environment variable LUA_CPATH, or a default path defined in luaconf.h.
     */
    var cpath: string;

    /**
     * A table used by require to control which modules are already loaded. When
     * you require a module modname and package.loaded[modname] is not false,
     * require simply returns the value stored there.
     *
     * This variable is only a reference to the real table; assignments to this
     * variable do not change the table used by require.
     */
    const loaded: Record<string, any>;

    /**
     * Dynamically links the host program with the C library libname.
     *
     * If funcname is "*", then it only links with the library, making the symbols
     * exported by the library available to other dynamically linked libraries.
     * Otherwise, it looks for a function funcname inside the library and returns
     * this function as a C function. So, funcname must follow the lua_CFunction
     * prototype (see lua_CFunction).
     *
     * This is a low-level function. It completely bypasses the package and module
     * system. Unlike require, it does not perform any path searching and does not
     * automatically adds extensions. libname must be the complete file name of
     * the C library, including if necessary a path and an extension. funcname
     * must be the exact name exported by the C library (which may depend on the C
     * compiler and linker used).
     *
     * This function is not supported by Standard C. As such, it is only available
     * on some platforms (Windows, Linux, Mac OS X, Solaris, BSD, plus other Unix
     * systems that support the dlfcn standard).
     */
    function loadlib(
        libname: string,
        funcname: string
    ): [Function] | [undefined, string, 'open' | 'init'];

    /**
     * The path used by require to search for a Lua loader.
     *
     * At start-up, Lua initializes this variable with the value of the
     * environment variable LUA_PATH_5_3 or the environment variable LUA_PATH or
     * with a default path defined in luaconf.h, if those environment variables
     * are not defined. Any ";;" in the value of the environment variable is
     * replaced by the default path.
     */
    var path: string;

    /**
     * A table to store loaders for specific modules (see require).
     *
     * This variable is only a reference to the real table; assignments to this
     * variable do not change the table used by require.
     */
    const preload: Record<string, (modname: string, fileName?: string) => any>;

    /**
     * Searches for the given name in the given path.
     *
     * A path is a string containing a sequence of templates separated by
     * semicolons. For each template, the function replaces each interrogation
     * mark (if any) in the template with a copy of name wherein all occurrences
     * of sep (a dot, by default) were replaced by rep (the system's directory
     * separator, by default), and then tries to open the resulting file name.
     *
     * For instance, if the path is the string
     *
     * `./?.lua;./?.lc;/usr/local/?/init.lua`
     *
     * the search for the name foo.a will try to open the files ./foo/a.lua,
     * ./foo/a.lc, and /usr/local/foo/a/init.lua, in that order.
     *
     * Returns the resulting name of the first file that it can open in read mode
     * (after closing the file), or nil plus an error message if none succeeds.
     * (This error message lists all file names it tried to open.)
     */
    function searchpath(name: string, path: string, sep?: string, rep?: string): string;
}

// Based on https://www.lua.org/manual/5.3/manual.html#6.4

/**
 * This library provides generic functions for string manipulation, such as
 * finding and extracting substrings, and pattern matching. When indexing a
 * string in Lua, the first character is at position 1 (not at 0, as in C).
 * Indices are allowed to be negative and are interpreted as indexing backwards,
 * from the end of the string. Thus, the last character is at position -1, and
 * so on.
 *
 * The string library provides all its functions inside the table string. It
 * also sets a metatable for strings where the __index field points to the
 * string table. Therefore, you can use the string functions in object-oriented
 * style. For instance, string.byte(s,i) can be written as s:byte(i).
 *
 * The string library assumes one-byte character encodings.
 */
declare namespace string {
	/**
	 * Returns the internal numeric codes of the characters s[i], s[i+1], ...,
	 * s[j]. The default value for i is 1; the default value for j is i. These
	 * indices are corrected following the same rules of function string.sub.
	 *
	 * Numeric codes are not necessarily portable across platforms.
	 */
	function byte(s: string, i?: number): number;
	function byte(s: string, i?: number, j?: number): LuaMultiReturn<number[]>;

	/**
	 * Receives zero or more integers. Returns a string with length equal to the
	 * number of arguments, in which each character has the internal numeric code
	 * equal to its corresponding argument.
	 *
	 * Numeric codes are not necessarily portable across platforms.
	 */
	function char(...args: number[]): string;

	/**
	 * Returns a string containing a binary representation of the given function,
	 * so that a later load on this string returns a copy of the function (but
	 * with new upvalues).
	 */
	function dump(func: Function): string;

	/**
	 * Looks for the first match of pattern (see §6.4.1) in the string s. If it
	 * finds a match, then find returns the indices of s where this occurrence
	 * starts and ends; otherwise, it returns nil. A third, optional numeric
	 * argument init specifies where to start the search; its default value is 1
	 * and can be negative. A value of true as a fourth, optional argument plain
	 * turns off the pattern matching facilities, so the function does a plain
	 * "find substring" operation, with no characters in pattern being considered
	 * magic. Note that if plain is given, then init must be given as well.
	 *
	 * If the pattern has captures, then in a successful match the captured values
	 * are also returned, after the two indices.
	 */
	function find(
		 s: string,
		 pattern: string,
		 init?: number,
		 plain?: boolean
	): LuaMultiReturn<[number, number, ...string[]] | []>;

	/**
	 * Returns a formatted version of its variable number of arguments following
	 * the description given in its first argument (which must be a string). The
	 * format string follows the same rules as the ISO C function sprintf. The
	 * only differences are that the options/modifiers *, h, L, l, n, and p are
	 * not supported and that there is an extra option, q.
	 *
	 * The q option formats a string between double quotes, using escape sequences
	 * when necessary to ensure that it can safely be read back by the Lua
	 * interpreter. For instance, the call
	 *
	 * `string.format('%q', 'a string with "quotes" and \n new line')`
	 *
	 * may produce the string:
	 *
	 * `"a string with \"quotes\" and \
	 *  new line"` Options A, a, E, e, f, G, and g all expect a number as
	 * argument. Options c, d, i, o, u, X, and x expect an integer. When Lua is
	 * compiled with a C89 compiler, options A and a (hexadecimal floats) do not
	 * support any modifier (flags, width, length).
	 *
	 * Option s expects a string; if its argument is not a string, it is converted
	 * to one following the same rules of tostring. If the option has any modifier
	 * (flags, width, length), the string argument should not contain embedded
	 * zeros.
	 */
	function format(formatstring: string, ...args: any[]): string;

	/**
	 * Returns an iterator function that, each time it is called, returns the next
	 * captures from pattern (see §6.4.1) over the string s. If pattern specifies
	 * no captures, then the whole match is produced in each call.
	 *
	 * As an example, the following loop will iterate over all the words from
	 * string s, printing one per line:
	 *
	 * ```
	 * s = "hello world from Lua"
	 * for w in string.gmatch(s, "%a+") do
	 *   print(w)
	 * end
	 * ```
	 *
	 * The next example collects all pairs key=value from the given string into a
	 * table:
	 *
	 * ```
	 * t = {}
	 * s = "from=world, to=Lua"
	 * for k, v in string.gmatch(s, "(%w+)=(%w+)") do
	 *   t[k] = v
	 * end
	 * ```
	 *
	 * For this function, a caret '^' at the start of a pattern does not work as
	 * an anchor, as this would prevent the iteration.
	 */
	function gmatch(s: string, pattern: string): LuaIterable<LuaMultiReturn<string[]>>;

	/**
	 * Returns a copy of s in which all (or the first n, if given) occurrences of
	 * the pattern (see §6.4.1) have been replaced by a replacement string
	 * specified by repl, which can be a string, a table, or a function. gsub also
	 * returns, as its second value, the total number of matches that occurred.
	 * The name gsub comes from Global SUBstitution.
	 *
	 * If repl is a string, then its value is used for replacement. The character
	 * % works as an escape character: any sequence in repl of the form %d, with d
	 * between 1 and 9, stands for the value of the d-th captured substring. The
	 * sequence %0 stands for the whole match. The sequence %% stands for a single
	 * %.
	 *
	 * If repl is a table, then the table is queried for every match, using the
	 * first capture as the key.
	 *
	 * If repl is a function, then this function is called every time a match
	 * occurs, with all captured substrings passed as arguments, in order.
	 *
	 * In any case, if the pattern specifies no captures, then it behaves as if
	 * the whole pattern was inside a capture.
	 *
	 * If the value returned by the table query or by the function call is a
	 * string or a number, then it is used as the replacement string; otherwise,
	 * if it is false or nil, then there is no replacement (that is, the original
	 * match is kept in the string).
	 */
	function gsub(
		 s: string,
		 pattern: string,
		 repl: string | Record<string, string> | ((...matches: string[]) => string),
		 n?: number
	): LuaMultiReturn<[string, number]>;

	/**
	 * Receives a string and returns its length. The empty string "" has length 0.
	 * Embedded zeros are counted, so "a\000bc\000" has length 5.
	 */
	function len(s: string): number;

	/**
	 * Receives a string and returns a copy of this string with all uppercase
	 * letters changed to lowercase. All other characters are left unchanged. The
	 * definition of what an uppercase letter is depends on the current locale.
	 */
	function lower(s: string): string;

	/**
	 * Looks for the first match of pattern (see §6.4.1) in the string s. If it
	 * finds one, then match returns the captures from the pattern; otherwise it
	 * returns nil. If pattern specifies no captures, then the whole match is
	 * returned. A third, optional numeric argument init specifies where to start
	 * the search; its default value is 1 and can be negative.
	 */
	function match(s: string, pattern: string, init?: number): LuaMultiReturn<string[]>;

	/**
	 * Returns a string that is the concatenation of `n` copies of the string `s`.
	 */
	function rep(s: string, n: number): string;

	/**
	 * Returns a string that is the string s reversed.
	 */
	function reverse(s: string): string;

	/**
	 * Returns the substring of s that starts at i and continues until j; i and j
	 * can be negative. If j is absent, then it is assumed to be equal to -1
	 * (which is the same as the string length). In particular, the call
	 * string.sub(s,1,j) returns a prefix of s with length j, and string.sub(s,
	 * -i) (for a positive i) returns a suffix of s with length i.
	 *
	 * If, after the translation of negative indices, i is less than 1, it is
	 * corrected to 1. If j is greater than the string length, it is corrected to
	 * that length. If, after these corrections, i is greater than j, the function
	 * returns the empty string.
	 */
	function sub(s: string, i: number, j?: number): string;

	/**
	 * Receives a string and returns a copy of this string with all lowercase
	 * letters changed to uppercase. All other characters are left unchanged. The
	 * definition of what a lowercase letter is depends on the current locale.
	 */
	function upper(s: string): string;
}

// Based on https://www.lua.org/manual/5.3/manual.html#6.6

/**
 * This library provides generic functions for table manipulation. It provides
 * all its functions inside the table table.
 *
 * Remember that, whenever an operation needs the length of a table, all caveats
 * about the length operator apply (see §3.4.7). All functions ignore
 * non-numeric keys in the tables given as arguments.
 */
declare namespace table {
	/**
	 * Given a list where all elements are strings or numbers, returns the string
	 * list[i]..sep..list[i+1] ··· sep..list[j]. The default value for sep is the
	 * empty string, the default for i is 1, and the default for j is #list. If i
	 * is greater than j, returns the empty string.
	 */
	function concat(list: (string | number)[], sep?: string, i?: number, j?: number): string;

	/**
	 * Inserts element value at position pos in list, shifting up the elements
	 * list[pos], list[pos+1], ···, list[#list]. The default value for pos is
	 * #list+1, so that a call table.insert(t,x) inserts x at the end of list t.
	 */
	function insert<T>(list: T[], value: T): void;
	function insert<T>(list: T[], pos: number, value: T): void;

	/**
	 * Removes from list the element at position pos, returning the value of the
	 * removed element. When pos is an integer between 1 and #list, it shifts down
	 * the elements list[pos+1], list[pos+2], ···, list[#list] and erases element
	 * list[#list]; The index pos can also be 0 when #list is 0, or #list + 1; in
	 * those cases, the function erases the element list[pos].
	 *
	 * The default value for pos is #list, so that a call table.remove(l) removes
	 * the last element of list l.
	 */
	function remove<T>(list: T[], pos?: number): T | undefined;

	/**
	 * Sorts list elements in a given order, in-place, from list[1] to
	 * list[#list]. If comp is given, then it must be a function that receives two
	 * list elements and returns true when the first element must come before the
	 * second in the final order (so that, after the sort, i < j implies not
	 * comp(list[j],list[i])). If comp is not given, then the standard Lua
	 * operator < is used instead.
	 *
	 * Note that the comp function must define a strict partial order over the
	 * elements in the list; that is, it must be asymmetric and transitive.
	 * Otherwise, no valid sort may be possible.
	 *
	 * The sort algorithm is not stable: elements considered equal by the given
	 * order may have their relative positions changed by the sort.
	 */
	function sort<T>(list: T[], comp?: (a: T, b: T) => boolean): void;
}
