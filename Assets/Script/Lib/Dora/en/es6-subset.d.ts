/// <reference no-default-lib="true"/>

/////////////////////////////
/// ECMAScript APIs es5
/////////////////////////////

declare var NaN: number;
declare var Infinity: number;

/**
 * Converts a string to an integer.
 * @param string A string to convert into a number.
 * @param radix A value between 2 and 36 that specifies the base of the number in `string`.
 * If this argument is not supplied, strings with a prefix of '0x' are considered hexadecimal.
 * All other strings are considered decimal.
 */
declare function parseInt(string: string, radix?: number): number;

/**
 * Converts a string to a floating-point number.
 * @param string A string that contains a floating-point number.
 */
declare function parseFloat(string: string): number;

/**
 * Returns a Boolean value that indicates whether a value is the reserved value NaN (not a number).
 * @param number A numeric value.
 */
declare function isNaN(number: number): boolean;

/**
 * Determines whether a supplied number is finite.
 * @param number Any numeric value.
 */
declare function isFinite(number: number): boolean;

interface Symbol {
	/** Returns a string representation of an object. */
	toString(): string;

	/** Returns the primitive value of the specified object. */
	valueOf(): symbol;
}

declare type PropertyKey = string | number | symbol;

interface PropertyDescriptor {
	configurable?: boolean;
	enumerable?: boolean;
	value?: any;
	writable?: boolean;
	get?(): any;
	set?(v: any): void;
}

interface PropertyDescriptorMap {
	[key: PropertyKey]: PropertyDescriptor;
}

interface Object {
	/** The initial value of Object.prototype.constructor is the standard built-in Object constructor. */
	constructor: Function;

	/** Returns a string representation of an object. */
	toString(): string;

	/**
	 * Determines whether an object has a property with the specified name.
	 * @param v A property name.
	 */
	hasOwnProperty(v: PropertyKey): boolean;
}

interface ObjectConstructor {
	new (value?: any): Object;
	(): any;
	(value: any): any;

	/**
	 * Gets the own property descriptor of the specified object.
	 * An own property descriptor is one that is defined directly on the object and is not inherited from the object's prototype.
	 * @param o Object that contains the property.
	 * @param p Name of the property.
	 */
	getOwnPropertyDescriptor(o: any, p: PropertyKey): PropertyDescriptor | undefined;

	/**
	 * Adds a property to an object, or modifies attributes of an existing property.
	 * @param o Object on which to add or modify the property. This can be a native JavaScript object (that is, a user-defined object or a built in object) or a DOM object.
	 * @param p The property name.
	 * @param attributes Descriptor for the property. It can be for a data property or an accessor property.
	 */
	defineProperty<T>(o: T, p: PropertyKey, attributes: PropertyDescriptor & ThisType<any>): T;

	/**
	 * Returns the names of the enumerable string properties and methods of an object.
	 * @param o Object that contains the properties and methods. This can be an object that you created or an existing Document Object Model (DOM) object.
	 */
	keys(o: object): string[];

	/**
	 * Groups members of an iterable according to the return value of the passed callback.
	 * @param items An iterable.
	 * @param keySelector A callback which will be invoked for each item in items.
	 */
	groupBy<K extends PropertyKey, T>(
		items: Iterable<T>,
		keySelector: (item: T, index: number) => K,
	): Partial<Record<K, T[]>>;
}

/**
 * Provides functionality common to all JavaScript objects.
 */
declare var Object: ObjectConstructor;

/**
 * Creates a new function.
 */
interface Function {
	/**
	 * Calls the function, substituting the specified object for the this value of the function, and the specified array for the arguments of the function.
	 * @param thisArg The object to be used as the this object.
	 * @param argArray A set of arguments to be passed to the function.
	 */
	apply(this: Function, thisArg: any, argArray?: any): any;

	/**
	 * Calls a method of an object, substituting another object for the current object.
	 * @param thisArg The object to be used as the current object.
	 * @param argArray A list of arguments to be passed to the method.
	 */
	call(this: Function, thisArg: any, ...argArray: any[]): any;

	/**
	 * For a given function, creates a bound function that has the same body as the original function.
	 * The this object of the bound function is associated with the specified object, and has the specified initial parameters.
	 * @param thisArg An object to which the this keyword can refer inside the new function.
	 * @param argArray A list of arguments to be passed to the new function.
	 */
	bind(this: Function, thisArg: any, ...argArray: any[]): any;

	/** Returns a string representation of a function. */
	toString(): string;

	readonly length: number;
}

/**
 * Extracts the type of the 'this' parameter of a function type, or 'unknown' if the function type has no 'this' parameter.
 */
type ThisParameterType<T> = T extends (this: infer U, ...args: never) => any ? U : unknown;

/**
 * Removes the 'this' parameter from a function type.
 */
type OmitThisParameter<T> = unknown extends ThisParameterType<T> ? T : T extends (...args: infer A) => infer R ? (...args: A) => R : T;

interface CallableFunction extends Function {
	/**
	 * Calls the function with the specified object as the this value and the elements of specified array as the arguments.
	 * @param thisArg The object to be used as the this object.
	 */
	apply<T, R>(this: (this: T) => R, thisArg: T): R;

	/**
	 * Calls the function with the specified object as the this value and the elements of specified array as the arguments.
	 * @param thisArg The object to be used as the this object.
	 * @param args An array of argument values to be passed to the function.
	 */
	apply<T, A extends any[], R>(this: (this: T, ...args: A) => R, thisArg: T, args: A): R;

	/**
	 * Calls the function with the specified object as the this value and the specified rest arguments as the arguments.
	 * @param thisArg The object to be used as the this object.
	 * @param args Argument values to be passed to the function.
	 */
	call<T, A extends any[], R>(this: (this: T, ...args: A) => R, thisArg: T, ...args: A): R;

	/**
	 * For a given function, creates a bound function that has the same body as the original function.
	 * The this object of the bound function is associated with the specified object, and has the specified initial parameters.
	 * @param thisArg The object to be used as the this object.
	 */
	bind<T>(this: T, thisArg: ThisParameterType<T>): OmitThisParameter<T>;

	/**
	 * For a given function, creates a bound function that has the same body as the original function.
	 * The this object of the bound function is associated with the specified object, and has the specified initial parameters.
	 * @param thisArg The object to be used as the this object.
	 * @param args Arguments to bind to the parameters of the function.
	 */
	bind<T, A extends any[], B extends any[], R>(this: (this: T, ...args: [...A, ...B]) => R, thisArg: T, ...args: A): (...args: B) => R;
}

interface NewableFunction extends Function {
	/**
	 * Calls the function with the specified object as the this value and the elements of specified array as the arguments.
	 * @param thisArg The object to be used as the this object.
	 */
	apply<T>(this: new () => T, thisArg: T): void;
	/**
	 * Calls the function with the specified object as the this value and the elements of specified array as the arguments.
	 * @param thisArg The object to be used as the this object.
	 * @param args An array of argument values to be passed to the function.
	 */
	apply<T, A extends any[]>(this: new (...args: A) => T, thisArg: T, args: A): void;

	/**
	 * Calls the function with the specified object as the this value and the specified rest arguments as the arguments.
	 * @param thisArg The object to be used as the this object.
	 * @param args Argument values to be passed to the function.
	 */
	call<T, A extends any[]>(this: new (...args: A) => T, thisArg: T, ...args: A): void;

	/**
	 * For a given function, creates a bound function that has the same body as the original function.
	 * The this object of the bound function is associated with the specified object, and has the specified initial parameters.
	 * @param thisArg The object to be used as the this object.
	 */
	bind<T>(this: T, thisArg: any): T;

	/**
	 * For a given function, creates a bound function that has the same body as the original function.
	 * The this object of the bound function is associated with the specified object, and has the specified initial parameters.
	 * @param thisArg The object to be used as the this object.
	 * @param args Arguments to bind to the parameters of the function.
	 */
	bind<A extends any[], B extends any[], R>(this: new (...args: [...A, ...B]) => R, thisArg: any, ...args: A): new (...args: B) => R;
}

interface IArguments {
	[index: number]: any;
	length: number;
	callee: Function;
}

interface String {
	/** Returns a string representation of a string. */
	toString(): string;

	/**
	 * Returns the character at the specified index.
	 * @param pos The zero-based index of the desired character.
	 */
	charAt(pos: number): string;

	/**
	 * Returns the Unicode value of the character at the specified location.
	 * @param index The zero-based index of the desired character. If there is no character at the specified index, NaN is returned.
	 */
	charCodeAt(index: number): number;

	/**
	 * Returns a string that contains the concatenation of two or more strings.
	 * @param strings The strings to append to the end of the string.
	 */
	concat(...strings: string[]): string;

	/**
	 * Returns the position of the first occurrence of a substring.
	 * @param searchString The substring to search for in the string
	 * @param position The index at which to begin searching the String object. If omitted, search starts at the beginning of the string.
	 */
	indexOf(searchString: string, position?: number): number;

	/**
	 * Replaces text in a string, using a regular expression or search string.
	 * @param searchValue A string to search for.
	 * @param replaceValue A string containing the text to replace.
	 */
	replace(searchValue: string, replaceValue: string): string;

	/**
	 * Replaces text in a string, using a regular expression or search string.
	 * @param searchValue A string to search for.
	 * @param replacer A function that returns the replacement text.
	 */
	replace(searchValue: string, replacer: (substring: string, ...args: any[]) => string): string;

	/**
	 * Returns a section of a string.
	 * @param start The index to the beginning of the specified portion of stringObj.
	 * @param end The index to the end of the specified portion of stringObj. The substring includes the characters up to, but not including, the character indicated by end.
	 * If this value is not specified, the substring continues to the end of stringObj.
	 */
	slice(start?: number, end?: number): string;

	/**
	 * Split a string into substrings using the specified separator and return them as an array.
	 * @param separator A string that identifies character or characters to use in separating the string. If omitted, a single-element array containing the entire string is returned.
	 * @param limit A value used to limit the number of elements returned in the array.
	 */
	split(separator: string, limit?: number): string[];

	/**
	 * Returns the substring at the specified location within a String object.
	 * @param start The zero-based index number indicating the beginning of the substring.
	 * @param end Zero-based index number indicating the end of the substring. The substring includes the characters up to, but not including, the character indicated by end.
	 * If end is omitted, the characters from start through the end of the original string are returned.
	 */
	substring(start: number, end?: number): string;

	/** Converts all the alphabetic characters in a string to lowercase. */
	toLowerCase(): string;

	/** Converts all the alphabetic characters in a string to uppercase. */
	toUpperCase(): string;

	/** Removes the leading and trailing white space and line terminator characters from a string. */
	trim(): string;

	/** Returns the length of a String object. */
	readonly length: number;

	// IE extensions
	/**
	 * Gets a substring beginning at the specified location and having the specified length.
	 * @deprecated A legacy feature for browser compatibility
	 * @param from The starting position of the desired substring. The index of the first character in the string is zero.
	 * @param length The number of characters to include in the returned substring.
	 */
	substr(from: number, length?: number): string;

	readonly [index: number]: string;
}

interface StringConstructor {
	fromCharCode(...codes: number[]): string;
}

/**
 * Allows manipulation and formatting of text strings and determination and location of substrings within strings.
 */
declare var String: StringConstructor;

interface Boolean {
}

interface BooleanConstructor {
}

declare var Boolean: BooleanConstructor;

interface Number {
	/**
	 * Returns a string representation of an object.
	 * @param radix Specifies a radix for converting numeric values to strings. This value is only used for numbers.
	 */
	toString(radix?: number): string;

	/**
	 * Returns a string representing a number in fixed-point notation.
	 * @param fractionDigits Number of digits after the decimal point. Must be in the range 0 - 20, inclusive.
	 */
	toFixed(fractionDigits?: number): string;
}

interface NumberConstructor {
	(value?: any): number;

	/** The largest number that can be represented in JavaScript. Equal to approximately 1.79E+308. */
	readonly MAX_VALUE: number;

	/** The closest number to zero that can be represented in JavaScript. Equal to approximately 5.00E-324. */
	readonly MIN_VALUE: number;

	/**
	 * A value that is not a number.
	 * In equality comparisons, NaN does not equal any value, including itself. To test whether a value is equivalent to NaN, use the isNaN function.
	 */
	readonly NaN: number;

	/**
	 * A value that is less than the largest negative number that can be represented in JavaScript.
	 * JavaScript displays NEGATIVE_INFINITY values as -infinity.
	 */
	readonly NEGATIVE_INFINITY: number;

	/**
	 * A value greater than the largest number that can be represented in JavaScript.
	 * JavaScript displays POSITIVE_INFINITY values as infinity.
	 */
	readonly POSITIVE_INFINITY: number;
}

/** An object that represents a number of any kind. All JavaScript numbers are 64-bit floating-point numbers. */
declare var Number: NumberConstructor;

interface TemplateStringsArray extends ReadonlyArray<string> {
	readonly raw: readonly string[];
}

/**
 * The type of `import.meta`.
 *
 * If you need to declare that a given property exists on `import.meta`,
 * this type may be augmented via interface merging.
 */
interface ImportMeta {
}

/**
 * The type for the optional second argument to `import()`.
 *
 * If your host environment supports additional options, this type may be
 * augmented via interface merging.
 */
interface ImportCallOptions {
	/** @deprecated*/ assert?: ImportAssertions;
	with?: ImportAttributes;
}

/**
 * The type for the `assert` property of the optional second argument to `import()`.
 */
interface ImportAssertions {
	[key: string]: string;
}

/**
 * The type for the `with` property of the optional second argument to `import()`.
 */
interface ImportAttributes {
	[key: string]: string;
}

interface Math {
	/** The mathematical constant e. This is Euler's number, the base of natural logarithms. */
	readonly E: number;
	/** The natural logarithm of 10. */
	readonly LN10: number;
	/** The natural logarithm of 2. */
	readonly LN2: number;
	/** The base-2 logarithm of e. */
	readonly LOG2E: number;
	/** The base-10 logarithm of e. */
	readonly LOG10E: number;
	/** Pi. This is the ratio of the circumference of a circle to its diameter. */
	readonly PI: number;
	/** The square root of 0.5, or, equivalently, one divided by the square root of 2. */
	readonly SQRT1_2: number;
	/** The square root of 2. */
	readonly SQRT2: number;
	/**
	 * Returns the absolute value of a number (the value without regard to whether it is positive or negative).
	 * For example, the absolute value of -5 is the same as the absolute value of 5.
	 * @param x A numeric expression for which the absolute value is needed.
	 */
	abs(x: number): number;
	/**
	 * Returns the arc cosine (or inverse cosine) of a number.
	 * @param x A numeric expression.
	 */
	acos(x: number): number;
	/**
	 * Returns the arcsine of a number.
	 * @param x A numeric expression.
	 */
	asin(x: number): number;
	/**
	 * Returns the arctangent of a number.
	 * @param x A numeric expression for which the arctangent is needed.
	 */
	atan(x: number): number;
	/**
	 * Returns the angle (in radians) from the X axis to a point.
	 * @param y A numeric expression representing the cartesian y-coordinate.
	 * @param x A numeric expression representing the cartesian x-coordinate.
	 */
	atan2(y: number, x: number): number;
	/**
	 * Returns the smallest integer greater than or equal to its numeric argument.
	 * @param x A numeric expression.
	 */
	ceil(x: number): number;
	/**
	 * Returns the cosine of a number.
	 * @param x A numeric expression that contains an angle measured in radians.
	 */
	cos(x: number): number;
	/**
	 * Returns e (the base of natural logarithms) raised to a power.
	 * @param x A numeric expression representing the power of e.
	 */
	exp(x: number): number;
	/**
	 * Returns the greatest integer less than or equal to its numeric argument.
	 * @param x A numeric expression.
	 */
	floor(x: number): number;
	/**
	 * Returns the natural logarithm (base e) of a number.
	 * @param x A numeric expression.
	 */
	log(x: number): number;
	/**
	 * Returns the larger of a set of supplied numeric expressions.
	 * @param values Numeric expressions to be evaluated.
	 */
	max(...values: number[]): number;
	/**
	 * Returns the smaller of a set of supplied numeric expressions.
	 * @param values Numeric expressions to be evaluated.
	 */
	min(...values: number[]): number;
	/**
	 * Returns the value of a base expression taken to a specified power.
	 * @param x The base value of the expression.
	 * @param y The exponent value of the expression.
	 */
	pow(x: number, y: number): number;
	/** Returns a pseudorandom number between 0 and 1. */
	random(): number;
	/**
	 * Returns a supplied numeric expression rounded to the nearest integer.
	 * @param x The value to be rounded to the nearest integer.
	 */
	round(x: number): number;
	/**
	 * Returns the sine of a number.
	 * @param x A numeric expression that contains an angle measured in radians.
	 */
	sin(x: number): number;
	/**
	 * Returns the square root of a number.
	 * @param x A numeric expression.
	 */
	sqrt(x: number): number;
	/**
	 * Returns the tangent of a number.
	 * @param x A numeric expression that contains an angle measured in radians.
	 */
	tan(x: number): number;
}
/** An intrinsic object that provides basic mathematics functionality and constants. */
declare var Math: Math;

interface RegExp {
}

interface RegExpConstructor {
}

declare var RegExp: RegExpConstructor;

interface Error {
	name: string;
	message: string;
	stack?: string;
}

interface ErrorConstructor {
	new (message?: string): Error;
	(message?: string): Error;
	readonly prototype: Error;
}

declare var Error: ErrorConstructor;

interface RangeError extends Error {
}

interface RangeErrorConstructor extends ErrorConstructor {
	new (message?: string): RangeError;
	(message?: string): RangeError;
	readonly prototype: RangeError;
}

declare var RangeError: RangeErrorConstructor;

interface ReferenceError extends Error {
}

interface ReferenceErrorConstructor extends ErrorConstructor {
	new (message?: string): ReferenceError;
	(message?: string): ReferenceError;
	readonly prototype: ReferenceError;
}

declare var ReferenceError: ReferenceErrorConstructor;

interface SyntaxError extends Error {
}

interface SyntaxErrorConstructor extends ErrorConstructor {
	new (message?: string): SyntaxError;
	(message?: string): SyntaxError;
	readonly prototype: SyntaxError;
}

declare var SyntaxError: SyntaxErrorConstructor;

interface TypeError extends Error {
}

interface TypeErrorConstructor extends ErrorConstructor {
	new (message?: string): TypeError;
	(message?: string): TypeError;
	readonly prototype: TypeError;
}

declare var TypeError: TypeErrorConstructor;

interface URIError extends Error {
}

interface URIErrorConstructor extends ErrorConstructor {
	new (message?: string): URIError;
	(message?: string): URIError;
	readonly prototype: URIError;
}

declare var URIError: URIErrorConstructor;

/////////////////////////////
/// ECMAScript Array API (specially handled by compiler)
/////////////////////////////

interface ReadonlyArray<T> {
	/**
	 * Gets the length of the array. This is a number one higher than the highest element defined in an array.
	 */
	readonly length: number;
	/**
	 * Combines two or more arrays.
	 * @param items Additional items to add to the end of array1.
	 */
	concat(...items: ConcatArray<T>[]): T[];
	/**
	 * Combines two or more arrays.
	 * @param items Additional items to add to the end of array1.
	 */
	concat(...items: (T | ConcatArray<T>)[]): T[];
	/**
	 * Adds all the elements of an array separated by the specified separator string.
	 * @param separator A string used to separate one element of an array from the next in the resulting String. If omitted, the array elements are separated with a comma.
	 */
	join(separator?: string): string;
	/**
	 * Returns a section of an array.
	 * @param start The beginning of the specified portion of the array.
	 * @param end The end of the specified portion of the array. This is exclusive of the element at the index 'end'.
	 */
	slice(start?: number, end?: number): T[];
	/**
	 * Returns the index of the first occurrence of a value in an array.
	 * @param searchElement The value to locate in the array.
	 * @param fromIndex The array index at which to begin the search. If fromIndex is omitted, the search starts at index 0.
	 */
	indexOf(searchElement: T, fromIndex?: number): number;
	/**
	 * Determines whether all the members of an array satisfy the specified test.
	 * @param predicate A function that accepts up to three arguments. The every method calls
	 * the predicate function for each element in the array until the predicate returns a value
	 * which is coercible to the Boolean value false, or until the end of the array.
	 * @param thisArg An object to which the this keyword can refer in the predicate function.
	 * If thisArg is omitted, undefined is used as the this value.
	 */
	every<S extends T>(predicate: (value: T, index: number, array: readonly T[]) => value is S, thisArg?: any): this is readonly S[];
	/**
	 * Determines whether all the members of an array satisfy the specified test.
	 * @param predicate A function that accepts up to three arguments. The every method calls
	 * the predicate function for each element in the array until the predicate returns a value
	 * which is coercible to the Boolean value false, or until the end of the array.
	 * @param thisArg An object to which the this keyword can refer in the predicate function.
	 * If thisArg is omitted, undefined is used as the this value.
	 */
	every(predicate: (value: T, index: number, array: readonly T[]) => unknown, thisArg?: any): boolean;
	/**
	 * Determines whether the specified callback function returns true for any element of an array.
	 * @param predicate A function that accepts up to three arguments. The some method calls
	 * the predicate function for each element in the array until the predicate returns a value
	 * which is coercible to the Boolean value true, or until the end of the array.
	 * @param thisArg An object to which the this keyword can refer in the predicate function.
	 * If thisArg is omitted, undefined is used as the this value.
	 */
	some(predicate: (value: T, index: number, array: readonly T[]) => unknown, thisArg?: any): boolean;
	/**
	 * Performs the specified action for each element in an array.
	 * @param callbackfn  A function that accepts up to three arguments. forEach calls the callbackfn function one time for each element in the array.
	 * @param thisArg  An object to which the this keyword can refer in the callbackfn function. If thisArg is omitted, undefined is used as the this value.
	 */
	forEach(callbackfn: (value: T, index: number, array: readonly T[]) => void, thisArg?: any): void;
	/**
	 * Calls a defined callback function on each element of an array, and returns an array that contains the results.
	 * @param callbackfn A function that accepts up to three arguments. The map method calls the callbackfn function one time for each element in the array.
	 * @param thisArg An object to which the this keyword can refer in the callbackfn function. If thisArg is omitted, undefined is used as the this value.
	 */
	map<U>(callbackfn: (value: T, index: number, array: readonly T[]) => U, thisArg?: any): U[];
	/**
	 * Returns the elements of an array that meet the condition specified in a callback function.
	 * @param predicate A function that accepts up to three arguments. The filter method calls the predicate function one time for each element in the array.
	 * @param thisArg An object to which the this keyword can refer in the predicate function. If thisArg is omitted, undefined is used as the this value.
	 */
	filter<S extends T>(predicate: (value: T, index: number, array: readonly T[]) => value is S, thisArg?: any): S[];
	/**
	 * Returns the elements of an array that meet the condition specified in a callback function.
	 * @param predicate A function that accepts up to three arguments. The filter method calls the predicate function one time for each element in the array.
	 * @param thisArg An object to which the this keyword can refer in the predicate function. If thisArg is omitted, undefined is used as the this value.
	 */
	filter(predicate: (value: T, index: number, array: readonly T[]) => unknown, thisArg?: any): T[];
	/**
	 * Calls the specified callback function for all the elements in an array. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.
	 * @param callbackfn A function that accepts up to four arguments. The reduce method calls the callbackfn function one time for each element in the array.
	 * @param initialValue If initialValue is specified, it is used as the initial value to start the accumulation. The first call to the callbackfn function provides this value as an argument instead of an array value.
	 */
	reduce(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: readonly T[]) => T): T;
	reduce(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: readonly T[]) => T, initialValue: T): T;
	/**
	 * Calls the specified callback function for all the elements in an array. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.
	 * @param callbackfn A function that accepts up to four arguments. The reduce method calls the callbackfn function one time for each element in the array.
	 * @param initialValue If initialValue is specified, it is used as the initial value to start the accumulation. The first call to the callbackfn function provides this value as an argument instead of an array value.
	 */
	reduce<U>(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: readonly T[]) => U, initialValue: U): U;
	/**
	 * Calls the specified callback function for all the elements in an array, in descending order. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.
	 * @param callbackfn A function that accepts up to four arguments. The reduceRight method calls the callbackfn function one time for each element in the array.
	 * @param initialValue If initialValue is specified, it is used as the initial value to start the accumulation. The first call to the callbackfn function provides this value as an argument instead of an array value.
	 */
	reduceRight(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: readonly T[]) => T): T;
	reduceRight(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: readonly T[]) => T, initialValue: T): T;
	/**
	 * Calls the specified callback function for all the elements in an array, in descending order. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.
	 * @param callbackfn A function that accepts up to four arguments. The reduceRight method calls the callbackfn function one time for each element in the array.
	 * @param initialValue If initialValue is specified, it is used as the initial value to start the accumulation. The first call to the callbackfn function provides this value as an argument instead of an array value.
	 */
	reduceRight<U>(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: readonly T[]) => U, initialValue: U): U;

	readonly [n: number]: T;
}

interface ConcatArray<T> {
	readonly length: number;
	readonly [n: number]: T;
	join(separator?: string): string;
	slice(start?: number, end?: number): T[];
}

interface Array<T> {
	/**
	 * Gets or sets the length of the array. This is a number one higher than the highest index in the array.
	 */
	length: number;
	/**
	 * Removes the last element from an array and returns it.
	 * If the array is empty, undefined is returned and the array is not modified.
	 */
	pop(): T | undefined;
	/**
	 * Appends new elements to the end of an array, and returns the new length of the array.
	 * @param items New elements to add to the array.
	 */
	push(...items: T[]): number;
	/**
	 * Combines two or more arrays.
	 * This method returns a new array without modifying any existing arrays.
	 * @param items Additional arrays and/or items to add to the end of the array.
	 */
	concat(...items: ConcatArray<T>[]): T[];
	/**
	 * Combines two or more arrays.
	 * This method returns a new array without modifying any existing arrays.
	 * @param items Additional arrays and/or items to add to the end of the array.
	 */
	concat(...items: (T | ConcatArray<T>)[]): T[];
	/**
	 * Adds all the elements of an array into a string, separated by the specified separator string.
	 * @param separator A string used to separate one element of the array from the next in the resulting string. If omitted, the array elements are separated with a comma.
	 */
	join(separator?: string): string;
	/**
	 * Reverses the elements in an array in place.
	 * This method mutates the array and returns a reference to the same array.
	 */
	reverse(): T[];
	/**
	 * Removes the first element from an array and returns it.
	 * If the array is empty, undefined is returned and the array is not modified.
	 */
	shift(): T | undefined;
	/**
	 * Returns a copy of a section of an array.
	 * For both start and end, a negative index can be used to indicate an offset from the end of the array.
	 * For example, -2 refers to the second to last element of the array.
	 * @param start The beginning index of the specified portion of the array.
	 * If start is undefined, then the slice begins at index 0.
	 * @param end The end index of the specified portion of the array. This is exclusive of the element at the index 'end'.
	 * If end is undefined, then the slice extends to the end of the array.
	 */
	slice(start?: number, end?: number): T[];
	/**
	 * Sorts an array in place.
	 * This method mutates the array and returns a reference to the same array.
	 * @param compareFn Function used to determine the order of the elements. It is expected to return
	 * a negative value if the first argument is less than the second argument, zero if they're equal, and a positive
	 * value otherwise. If omitted, the elements are sorted in ascending, ASCII character order.
	 * ```ts
	 * [11,2,22,1].sort((a, b) => a - b)
	 * ```
	 */
	sort(compareFn?: (a: T, b: T) => number): this;
	/**
	 * Removes elements from an array and, if necessary, inserts new elements in their place, returning the deleted elements.
	 * @param start The zero-based location in the array from which to start removing elements.
	 * @param deleteCount The number of elements to remove.
	 * @returns An array containing the elements that were deleted.
	 */
	splice(start: number, deleteCount?: number): T[];
	/**
	 * Removes elements from an array and, if necessary, inserts new elements in their place, returning the deleted elements.
	 * @param start The zero-based location in the array from which to start removing elements.
	 * @param deleteCount The number of elements to remove.
	 * @param items Elements to insert into the array in place of the deleted elements.
	 * @returns An array containing the elements that were deleted.
	 */
	splice(start: number, deleteCount: number, ...items: T[]): T[];
	/**
	 * Inserts new elements at the start of an array, and returns the new length of the array.
	 * @param items Elements to insert at the start of the array.
	 */
	unshift(...items: T[]): number;
	/**
	 * Returns the index of the first occurrence of a value in an array, or -1 if it is not present.
	 * @param searchElement The value to locate in the array.
	 * @param fromIndex The array index at which to begin the search. If fromIndex is omitted, the search starts at index 0.
	 */
	indexOf(searchElement: T, fromIndex?: number): number;
	/**
	 * Determines whether all the members of an array satisfy the specified test.
	 * @param predicate A function that accepts up to three arguments. The every method calls
	 * the predicate function for each element in the array until the predicate returns a value
	 * which is coercible to the Boolean value false, or until the end of the array.
	 * @param thisArg An object to which the this keyword can refer in the predicate function.
	 * If thisArg is omitted, undefined is used as the this value.
	 */
	every<S extends T>(predicate: (value: T, index: number, array: T[]) => value is S, thisArg?: any): this is S[];
	/**
	 * Determines whether all the members of an array satisfy the specified test.
	 * @param predicate A function that accepts up to three arguments. The every method calls
	 * the predicate function for each element in the array until the predicate returns a value
	 * which is coercible to the Boolean value false, or until the end of the array.
	 * @param thisArg An object to which the this keyword can refer in the predicate function.
	 * If thisArg is omitted, undefined is used as the this value.
	 */
	every(predicate: (value: T, index: number, array: T[]) => unknown, thisArg?: any): boolean;
	/**
	 * Determines whether the specified callback function returns true for any element of an array.
	 * @param predicate A function that accepts up to three arguments. The some method calls
	 * the predicate function for each element in the array until the predicate returns a value
	 * which is coercible to the Boolean value true, or until the end of the array.
	 * @param thisArg An object to which the this keyword can refer in the predicate function.
	 * If thisArg is omitted, undefined is used as the this value.
	 */
	some(predicate: (value: T, index: number, array: T[]) => unknown, thisArg?: any): boolean;
	/**
	 * Performs the specified action for each element in an array.
	 * @param callbackfn  A function that accepts up to three arguments. forEach calls the callbackfn function one time for each element in the array.
	 * @param thisArg  An object to which the this keyword can refer in the callbackfn function. If thisArg is omitted, undefined is used as the this value.
	 */
	forEach(callbackfn: (value: T, index: number, array: T[]) => void, thisArg?: any): void;
	/**
	 * Calls a defined callback function on each element of an array, and returns an array that contains the results.
	 * @param callbackfn A function that accepts up to three arguments. The map method calls the callbackfn function one time for each element in the array.
	 * @param thisArg An object to which the this keyword can refer in the callbackfn function. If thisArg is omitted, undefined is used as the this value.
	 */
	map<U>(callbackfn: (value: T, index: number, array: T[]) => U, thisArg?: any): U[];
	/**
	 * Returns the elements of an array that meet the condition specified in a callback function.
	 * @param predicate A function that accepts up to three arguments. The filter method calls the predicate function one time for each element in the array.
	 * @param thisArg An object to which the this keyword can refer in the predicate function. If thisArg is omitted, undefined is used as the this value.
	 */
	filter<S extends T>(predicate: (value: T, index: number, array: T[]) => value is S, thisArg?: any): S[];
	/**
	 * Returns the elements of an array that meet the condition specified in a callback function.
	 * @param predicate A function that accepts up to three arguments. The filter method calls the predicate function one time for each element in the array.
	 * @param thisArg An object to which the this keyword can refer in the predicate function. If thisArg is omitted, undefined is used as the this value.
	 */
	filter(predicate: (value: T, index: number, array: T[]) => unknown, thisArg?: any): T[];
	/**
	 * Calls the specified callback function for all the elements in an array. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.
	 * @param callbackfn A function that accepts up to four arguments. The reduce method calls the callbackfn function one time for each element in the array.
	 * @param initialValue If initialValue is specified, it is used as the initial value to start the accumulation. The first call to the callbackfn function provides this value as an argument instead of an array value.
	 */
	reduce(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) => T): T;
	reduce(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) => T, initialValue: T): T;
	/**
	 * Calls the specified callback function for all the elements in an array. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.
	 * @param callbackfn A function that accepts up to four arguments. The reduce method calls the callbackfn function one time for each element in the array.
	 * @param initialValue If initialValue is specified, it is used as the initial value to start the accumulation. The first call to the callbackfn function provides this value as an argument instead of an array value.
	 */
	reduce<U>(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: T[]) => U, initialValue: U): U;
	/**
	 * Calls the specified callback function for all the elements in an array, in descending order. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.
	 * @param callbackfn A function that accepts up to four arguments. The reduceRight method calls the callbackfn function one time for each element in the array.
	 * @param initialValue If initialValue is specified, it is used as the initial value to start the accumulation. The first call to the callbackfn function provides this value as an argument instead of an array value.
	 */
	reduceRight(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) => T): T;
	reduceRight(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) => T, initialValue: T): T;
	/**
	 * Calls the specified callback function for all the elements in an array, in descending order. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.
	 * @param callbackfn A function that accepts up to four arguments. The reduceRight method calls the callbackfn function one time for each element in the array.
	 * @param initialValue If initialValue is specified, it is used as the initial value to start the accumulation. The first call to the callbackfn function provides this value as an argument instead of an array value.
	 */
	reduceRight<U>(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: T[]) => U, initialValue: U): U;

	[n: number]: T;
}

interface ArrayConstructor {
	new (): any[];
	new <T>(): T[];
	new <T>(...items: T[]): T[];
	isArray(arg: any): arg is any[];
}

declare var Array: ArrayConstructor;

interface TypedPropertyDescriptor<T> {
	enumerable?: boolean;
	configurable?: boolean;
	writable?: boolean;
	value?: T;
	get?: () => T;
	set?: (value: T) => void;
}

declare type PromiseConstructorLike = new <T>(executor: (resolve: (value: T | PromiseLike<T>) => void, reject: (reason?: any) => void) => void) => PromiseLike<T>;

interface PromiseLike<T> {
	/**
	 * Attaches callbacks for the resolution and/or rejection of the Promise.
	 * @param onfulfilled The callback to execute when the Promise is resolved.
	 * @param onrejected The callback to execute when the Promise is rejected.
	 * @returns A Promise for the completion of which ever callback is executed.
	 */
	then<TResult1 = T, TResult2 = never>(onfulfilled?: ((value: T) => TResult1 | PromiseLike<TResult1>) | undefined | null, onrejected?: ((reason: any) => TResult2 | PromiseLike<TResult2>) | undefined | null): PromiseLike<TResult1 | TResult2>;
}

/**
 * Represents the completion of an asynchronous operation
 */
interface Promise<T> {
	/**
	 * Attaches callbacks for the resolution and/or rejection of the Promise.
	 * @param onfulfilled The callback to execute when the Promise is resolved.
	 * @param onrejected The callback to execute when the Promise is rejected.
	 * @returns A Promise for the completion of which ever callback is executed.
	 */
	then<TResult1 = T, TResult2 = never>(onfulfilled?: ((value: T) => TResult1 | PromiseLike<TResult1>) | undefined | null, onrejected?: ((reason: any) => TResult2 | PromiseLike<TResult2>) | undefined | null): Promise<TResult1 | TResult2>;

	/**
	 * Attaches a callback for only the rejection of the Promise.
	 * @param onrejected The callback to execute when the Promise is rejected.
	 * @returns A Promise for the completion of the callback.
	 */
	catch<TResult = never>(onrejected?: ((reason: any) => TResult | PromiseLike<TResult>) | undefined | null): Promise<T | TResult>;
}

/**
 * Recursively unwraps the "awaited type" of a type. Non-promise "thenables" should resolve to `never`. This emulates the behavior of `await`.
 */
type Awaited<T> = T extends null | undefined ? T : // special case for `null | undefined` when not in `--strictNullChecks` mode
	T extends object & { then(onfulfilled: infer F, ...args: infer _): any; } ? // `await` only unwraps object types with a callable `then`. Non-object types are not unwrapped
		F extends ((value: infer V, ...args: infer _) => any) ? // if the argument to `then` is callable, extracts the first argument
			Awaited<V> : // recursively unwrap the value
		never : // the argument to `then` was not callable
	T; // non-object or non-thenable

interface ArrayLike<T> {
	readonly length: number;
	readonly [n: number]: T;
}

/**
 * Make all properties in T optional
 */
type Partial<T> = {
	[P in keyof T]?: T[P];
};

/**
 * Make all properties in T required
 */
type Required<T> = {
	[P in keyof T]-?: T[P];
};

/**
 * Make all properties in T readonly
 */
type Readonly<T> = {
	readonly [P in keyof T]: T[P];
};

/**
 * From T, pick a set of properties whose keys are in the union K
 */
type Pick<T, K extends keyof T> = {
	[P in K]: T[P];
};

/**
 * Construct a type with a set of properties K of type T
 */
type Record<K extends keyof any, T> = {
	[P in K]: T;
};

/**
 * Exclude from T those types that are assignable to U
 */
type Exclude<T, U> = T extends U ? never : T;

/**
 * Extract from T those types that are assignable to U
 */
type Extract<T, U> = T extends U ? T : never;

/**
 * Construct a type with the properties of T except for those in type K.
 */
type Omit<T, K extends keyof any> = Pick<T, Exclude<keyof T, K>>;

/**
 * Exclude null and undefined from T
 */
type NonNullable<T> = T & {};

/**
 * Obtain the parameters of a function type in a tuple
 */
type Parameters<T extends (...args: any) => any> = T extends (...args: infer P) => any ? P : never;

/**
 * Obtain the parameters of a constructor function type in a tuple
 */
type ConstructorParameters<T extends abstract new (...args: any) => any> = T extends abstract new (...args: infer P) => any ? P : never;

/**
 * Obtain the return type of a function type
 */
type ReturnType<T extends (...args: any) => any> = T extends (...args: any) => infer R ? R : any;

/**
 * Obtain the return type of a constructor function type
 */
type InstanceType<T extends abstract new (...args: any) => any> = T extends abstract new (...args: any) => infer R ? R : any;

/**
 * Convert string literal type to uppercase
 */
type Uppercase<S extends string> = intrinsic;

/**
 * Convert string literal type to lowercase
 */
type Lowercase<S extends string> = intrinsic;

/**
 * Convert first character of string literal type to uppercase
 */
type Capitalize<S extends string> = intrinsic;

/**
 * Convert first character of string literal type to lowercase
 */
type Uncapitalize<S extends string> = intrinsic;

/**
 * Marker for contextual 'this' type
 */
interface ThisType<T> {}

/**
 * Stores types to be used with WeakSet, WeakMap, WeakRef, and FinalizationRegistry
 */
interface WeakKeyTypes {
	object: object;
}

type WeakKey = WeakKeyTypes[keyof WeakKeyTypes];

/////////////////////////////
/// es2015.core
/////////////////////////////

interface Array<T> {
	/**
	 * Returns the value of the first element in the array where predicate is true, and undefined
	 * otherwise.
	 * @param predicate find calls predicate once for each element of the array, in ascending
	 * order, until it finds one where predicate returns true. If such an element is found, find
	 * immediately returns that element value. Otherwise, find returns undefined.
	 * @param thisArg If provided, it will be used as the this value for each invocation of
	 * predicate. If it is not provided, undefined is used instead.
	 */
	find<S extends T>(predicate: (value: T, index: number, obj: T[]) => value is S, thisArg?: any): S | undefined;
	find(predicate: (value: T, index: number, obj: T[]) => unknown, thisArg?: any): T | undefined;

	/**
	 * Returns the index of the first element in the array where predicate is true, and -1
	 * otherwise.
	 * @param predicate find calls predicate once for each element of the array, in ascending
	 * order, until it finds one where predicate returns true. If such an element is found,
	 * findIndex immediately returns that element index. Otherwise, findIndex returns -1.
	 * @param thisArg If provided, it will be used as the this value for each invocation of
	 * predicate. If it is not provided, undefined is used instead.
	 */
	findIndex(predicate: (value: T, index: number, obj: T[]) => unknown, thisArg?: any): number;

	/**
	 * Changes all array elements from `start` to `end` index to a static `value` and returns the modified array
	 * @param value value to fill array section with
	 * @param start index to start filling the array at. If start is negative, it is treated as
	 * length+start where length is the length of the array.
	 * @param end index to stop filling the array at. If end is negative, it is treated as
	 * length+end.
	 */
	fill(value: T, start?: number, end?: number): this;
}

interface ArrayConstructor {
	/**
	 * Creates an array from an array-like object.
	 * @param arrayLike An array-like object to convert to an array.
	 */
	from<T>(arrayLike: ArrayLike<T>): T[];

	/**
	 * Creates an array from an iterable object.
	 * @param arrayLike An array-like object to convert to an array.
	 * @param mapfn A mapping function to call on every element of the array.
	 * @param thisArg Value of 'this' used to invoke the mapfn.
	 */
	from<T, U>(arrayLike: ArrayLike<T>, mapfn: (v: T, k: number) => U, thisArg?: any): U[];

	/**
	 * Returns a new array from a set of elements.
	 * @param items A set of elements to include in the new array object.
	 */
	of<T>(...items: T[]): T[];
}

interface Math {
	/**
	 * Returns the sign of the x, indicating whether x is positive, negative or zero.
	 * @param x The numeric expression to test
	 */
	sign(x: number): number;

	/**
	 * Returns the base 10 logarithm of a number.
	 * @param x A numeric expression.
	 */
	log10(x: number): number;

	/**
	 * Returns the base 2 logarithm of a number.
	 * @param x A numeric expression.
	 */
	log2(x: number): number;

	/**
	 * Returns the natural logarithm of 1 + x.
	 * @param x A numeric expression.
	 */
	log1p(x: number): number;

	/**
	 * Returns the integral part of the a numeric expression, x, removing any fractional digits.
	 * If x is already an integer, the result is x.
	 * @param x A numeric expression.
	 */
	trunc(x: number): number;
}

interface NumberConstructor {
	/**
	 * The value of Number.EPSILON is the difference between 1 and the smallest value greater than 1
	 * that is representable as a Number value, which is approximately:
	 * 2.2204460492503130808472633361816 x 10‍−‍16.
	 */
	readonly EPSILON: number;

	/**
	 * Returns true if passed value is finite.
	 * Unlike the global isFinite, Number.isFinite doesn't forcibly convert the parameter to a
	 * number. Only finite values of the type number, result in true.
	 * @param number A numeric value.
	 */
	isFinite(number: unknown): boolean;

	/**
	 * Returns true if the value passed is an integer, false otherwise.
	 * @param number A numeric value.
	 */
	isInteger(number: unknown): boolean;

	/**
	 * Returns a Boolean value that indicates whether a value is the reserved value NaN (not a
	 * number). Unlike the global isNaN(), Number.isNaN() doesn't forcefully convert the parameter
	 * to a number. Only values of the type number, that are also NaN, result in true.
	 * @param number A numeric value.
	 */
	isNaN(number: unknown): boolean;

	/**
	 * The value of the largest integer n such that n and n + 1 are both exactly representable as
	 * a Number value.
	 * The value of Number.MAX_SAFE_INTEGER is 9007199254740991 2^53 − 1.
	 */
	readonly MAX_SAFE_INTEGER: number;

	/**
	 * The value of the smallest integer n such that n and n − 1 are both exactly representable as
	 * a Number value.
	 * The value of Number.MIN_SAFE_INTEGER is −9007199254740991 (−(2^53 − 1)).
	 */
	readonly MIN_SAFE_INTEGER: number;

	/**
	 * Converts a string to a floating-point number.
	 * @param string A string that contains a floating-point number.
	 */
	parseFloat(string: string): number;

	/**
	 * Converts A string to an integer.
	 * @param string A string to convert into a number.
	 * @param radix A value between 2 and 36 that specifies the base of the number in `string`.
	 * If this argument is not supplied, strings with a prefix of '0x' are considered hexadecimal.
	 * All other strings are considered decimal.
	 */
	parseInt(string: string, radix?: number): number;
}

interface ObjectConstructor {
	/**
	 * Copy the values of all of the enumerable own properties from one or more source objects to a
	 * target object. Returns the target object.
	 * @param target The target object to copy to.
	 * @param source The source object from which to copy properties.
	 */
	assign<T extends {}, U>(target: T, source: U): T & U;

	/**
	 * Copy the values of all of the enumerable own properties from one or more source objects to a
	 * target object. Returns the target object.
	 * @param target The target object to copy to.
	 * @param source1 The first source object from which to copy properties.
	 * @param source2 The second source object from which to copy properties.
	 */
	assign<T extends {}, U, V>(target: T, source1: U, source2: V): T & U & V;

	/**
	 * Copy the values of all of the enumerable own properties from one or more source objects to a
	 * target object. Returns the target object.
	 * @param target The target object to copy to.
	 * @param source1 The first source object from which to copy properties.
	 * @param source2 The second source object from which to copy properties.
	 * @param source3 The third source object from which to copy properties.
	 */
	assign<T extends {}, U, V, W>(target: T, source1: U, source2: V, source3: W): T & U & V & W;

	/**
	 * Copy the values of all of the enumerable own properties from one or more source objects to a
	 * target object. Returns the target object.
	 * @param target The target object to copy to.
	 * @param sources One or more source objects from which to copy properties
	 */
	assign(target: object, ...sources: any[]): any;

	/**
	 * Returns the names of the enumerable string properties and methods of an object.
	 * @param o Object that contains the properties and methods. This can be an object that you created or an existing Document Object Model (DOM) object.
	 */
	keys(o: {}): string[];
}

interface ReadonlyArray<T> {
	/**
	 * Returns the value of the first element in the array where predicate is true, and undefined
	 * otherwise.
	 * @param predicate find calls predicate once for each element of the array, in ascending
	 * order, until it finds one where predicate returns true. If such an element is found, find
	 * immediately returns that element value. Otherwise, find returns undefined.
	 * @param thisArg If provided, it will be used as the this value for each invocation of
	 * predicate. If it is not provided, undefined is used instead.
	 */
	find<S extends T>(predicate: (value: T, index: number, obj: readonly T[]) => value is S, thisArg?: any): S | undefined;
	find(predicate: (value: T, index: number, obj: readonly T[]) => unknown, thisArg?: any): T | undefined;

	/**
	 * Returns the index of the first element in the array where predicate is true, and -1
	 * otherwise.
	 * @param predicate find calls predicate once for each element of the array, in ascending
	 * order, until it finds one where predicate returns true. If such an element is found,
	 * findIndex immediately returns that element index. Otherwise, findIndex returns -1.
	 * @param thisArg If provided, it will be used as the this value for each invocation of
	 * predicate. If it is not provided, undefined is used instead.
	 */
	findIndex(predicate: (value: T, index: number, obj: readonly T[]) => unknown, thisArg?: any): number;
}

interface String {
	/**
	 * Returns true if searchString appears as a substring of the result of converting this
	 * object to a String, at one or more positions that are
	 * greater than or equal to position; otherwise, returns false.
	 * @param searchString search string
	 * @param position If position is undefined, 0 is assumed, so as to search all of the String.
	 */
	includes(searchString: string, position?: number): boolean;

	/**
	 * Returns true if the sequence of elements of searchString converted to a String is the
	 * same as the corresponding elements of this object (converted to a String) starting at
	 * endPosition – length(this). Otherwise returns false.
	 */
	endsWith(searchString: string, endPosition?: number): boolean;

	/**
	 * Returns a String value that is made from count copies appended together. If count is 0,
	 * the empty string is returned.
	 * @param count number of copies to append
	 */
	repeat(count: number): string;

	/**
	 * Returns true if the sequence of elements of searchString converted to a String is the
	 * same as the corresponding elements of this object (converted to a String) starting at
	 * position. Otherwise returns false.
	 */
	startsWith(searchString: string, position?: number): boolean;
}

/////////////////////////////
/// es2015.collection
/////////////////////////////

interface Map<K, V> {
	clear(): void;
	/**
	 * @returns true if an element in the Map existed and has been removed, or false if the element does not exist.
	 */
	delete(key: K): boolean;
	/**
	 * Executes a provided function once per each key/value pair in the Map, in insertion order.
	 */
	forEach(callbackfn: (value: V, key: K, map: Map<K, V>) => void, thisArg?: any): void;
	/**
	 * Returns a specified element from the Map object. If the value that is associated to the provided key is an object, then you will get a reference to that object and any change made to that object will effectively modify it inside the Map.
	 * @returns Returns the element associated with the specified key. If no element is associated with the specified key, undefined is returned.
	 */
	get(key: K): V | undefined;
	/**
	 * @returns boolean indicating whether an element with the specified key exists or not.
	 */
	has(key: K): boolean;
	/**
	 * Adds a new element with a specified key and value to the Map. If an element with the same key already exists, the element will be updated.
	 */
	set(key: K, value: V): this;
	/**
	 * @returns the number of elements in the Map.
	 */
	readonly size: number;
}

interface MapConstructor {
	new (): Map<any, any>;
	new <K, V>(entries?: readonly (readonly [K, V])[] | null): Map<K, V>;

	/**
	 * Groups members of an iterable according to the return value of the passed callback.
	 * @param items An iterable.
	 * @param keySelector A callback which will be invoked for each item in items.
	 */
	groupBy<K, T>(
		items: Iterable<T>,
		keySelector: (item: T, index: number) => K,
	): Map<K, T[]>;
}
declare var Map: MapConstructor;

interface ReadonlyMap<K, V> {
	forEach(callbackfn: (value: V, key: K, map: ReadonlyMap<K, V>) => void, thisArg?: any): void;
	get(key: K): V | undefined;
	has(key: K): boolean;
	readonly size: number;
}

interface WeakMap<K extends WeakKey, V> {
	/**
	 * Removes the specified element from the WeakMap.
	 * @returns true if the element was successfully removed, or false if it was not present.
	 */
	delete(key: K): boolean;
	/**
	 * @returns a specified element.
	 */
	get(key: K): V | undefined;
	/**
	 * @returns a boolean indicating whether an element with the specified key exists or not.
	 */
	has(key: K): boolean;
	/**
	 * Adds a new element with a specified key and value.
	 * @param key Must be an object or symbol.
	 */
	set(key: K, value: V): this;
}

interface WeakMapConstructor {
	new <K extends WeakKey = WeakKey, V = any>(entries?: readonly (readonly [K, V])[] | null): WeakMap<K, V>;
}
declare var WeakMap: WeakMapConstructor;

interface Set<T> {
	/**
	 * Appends a new element with a specified value to the end of the Set.
	 */
	add(value: T): this;

	clear(): void;
	/**
	 * Removes a specified value from the Set.
	 * @returns Returns true if an element in the Set existed and has been removed, or false if the element does not exist.
	 */
	delete(value: T): boolean;
	/**
	 * Executes a provided function once per each value in the Set object, in insertion order.
	 */
	forEach(callbackfn: (value: T, value2: T, set: Set<T>) => void, thisArg?: any): void;
	/**
	 * @returns a boolean indicating whether an element with the specified value exists in the Set or not.
	 */
	has(value: T): boolean;
	/**
	 * @returns the number of (unique) elements in Set.
	 */
	readonly size: number;
}

interface SetConstructor {
	new <T = any>(values?: readonly T[] | null): Set<T>;
}
declare var Set: SetConstructor;

interface ReadonlySet<T> {
	forEach(callbackfn: (value: T, value2: T, set: ReadonlySet<T>) => void, thisArg?: any): void;
	has(value: T): boolean;
	readonly size: number;
}

interface WeakSet<T extends WeakKey> {
	/**
	 * Appends a new value to the end of the WeakSet.
	 */
	add(value: T): this;
	/**
	 * Removes the specified element from the WeakSet.
	 * @returns Returns true if the element existed and has been removed, or false if the element does not exist.
	 */
	delete(value: T): boolean;
	/**
	 * @returns a boolean indicating whether a value exists in the WeakSet or not.
	 */
	has(value: T): boolean;
}

interface WeakSetConstructor {
	new <T extends WeakKey = WeakKey>(values?: readonly T[] | null): WeakSet<T>;
	readonly prototype: WeakSet<WeakKey>;
}
declare var WeakSet: WeakSetConstructor;

/////////////////////////////
/// es2015.iterable
/////////////////////////////

interface SymbolConstructor {
	/**
	 * Returns a new unique Symbol value.
	 * @param  description Description of the new Symbol object.
	 */
	(description?: string | number): symbol;

	/**
	 * Returns a Symbol object from the global symbol registry matching the given key if found.
	 * Otherwise, returns a new symbol with this key.
	 * @param key key to search for.
	 */
	for(key: string): symbol;

	/**
	 * Returns a key from the global symbol registry matching the given Symbol if found.
	 * Otherwise, returns a undefined.
	 * @param sym Symbol to find the key for.
	 */
	keyFor(sym: symbol): string | undefined;
}

declare var Symbol: SymbolConstructor;

interface SymbolConstructor {
	/**
	 * A method that returns the default iterator for an object. Called by the semantics of the
	 * for-of statement.
	 */
	readonly iterator: unique symbol;
}

interface IteratorYieldResult<TYield> {
	done?: false;
	value: TYield;
}

interface IteratorReturnResult<TReturn> {
	done: true;
	value: TReturn;
}

type IteratorResult<T, TReturn = any> = IteratorYieldResult<T> | IteratorReturnResult<TReturn>;

interface Iterator<T, TReturn = any, TNext = undefined> {
	// NOTE: 'next' is defined using a tuple to ensure we report the correct assignability errors in all places.
	next(...args: [] | [TNext]): IteratorResult<T, TReturn>;
	return?(value?: TReturn): IteratorResult<T, TReturn>;
	throw?(e?: any): IteratorResult<T, TReturn>;
}

interface Iterable<T> {
	[Symbol.iterator](): Iterator<T>;
}

interface IterableIterator<T> extends Iterator<T> {
	[Symbol.iterator](): IterableIterator<T>;
}

interface Array<T> {
	/** Iterator */
	[Symbol.iterator](): IterableIterator<T>;

	/**
	 * Returns an iterable of key, value pairs for every entry in the array
	 */
	entries(): IterableIterator<[number, T]>;
}

interface ArrayConstructor {
	/**
	 * Creates an array from an iterable object.
	 * @param iterable An iterable object to convert to an array.
	 */
	from<T>(iterable: Iterable<T> | ArrayLike<T>): T[];

	/**
	 * Creates an array from an iterable object.
	 * @param iterable An iterable object to convert to an array.
	 * @param mapfn A mapping function to call on every element of the array.
	 * @param thisArg Value of 'this' used to invoke the mapfn.
	 */
	from<T, U>(iterable: Iterable<T> | ArrayLike<T>, mapfn: (v: T, k: number) => U, thisArg?: any): U[];
}

interface IArguments {
	/** Iterator */
	[Symbol.iterator](): IterableIterator<any>;
}

interface ReadonlyArray<T> {
	/** Iterator of values in the array. */
	[Symbol.iterator](): IterableIterator<T>;

	/**
	 * Returns an iterable of key, value pairs for every entry in the array
	 */
	entries(): IterableIterator<[number, T]>;
}

interface Map<K, V> {
	/** Returns an iterable of entries in the map. */
	[Symbol.iterator](): IterableIterator<[K, V]>;

	/**
	 * Returns an iterable of key, value pairs for every entry in the map.
	 */
	entries(): IterableIterator<[K, V]>;

	/**
	 * Returns an iterable of keys in the map
	 */
	keys(): IterableIterator<K>;

	/**
	 * Returns an iterable of values in the map
	 */
	values(): IterableIterator<V>;
}

interface ReadonlyMap<K, V> {
	/** Returns an iterable of entries in the map. */
	[Symbol.iterator](): IterableIterator<[K, V]>;

	/**
	 * Returns an iterable of key, value pairs for every entry in the map.
	 */
	entries(): IterableIterator<[K, V]>;

	/**
	 * Returns an iterable of keys in the map
	 */
	keys(): IterableIterator<K>;

	/**
	 * Returns an iterable of values in the map
	 */
	values(): IterableIterator<V>;
}

interface MapConstructor {
	new (): Map<any, any>;
	new <K, V>(iterable?: Iterable<readonly [K, V]> | null): Map<K, V>;
}

interface WeakMap<K extends WeakKey, V> {}

interface WeakMapConstructor {
	new <K extends WeakKey, V>(iterable: Iterable<readonly [K, V]>): WeakMap<K, V>;
}

interface Set<T> {
	/** Iterates over values in the set. */
	[Symbol.iterator](): IterableIterator<T>;
	/**
	 * Returns an iterable of [v,v] pairs for every value `v` in the set.
	 */
	entries(): IterableIterator<[T, T]>;
	/**
	 * Despite its name, returns an iterable of the values in the set.
	 */
	keys(): IterableIterator<T>;

	/**
	 * Returns an iterable of values in the set.
	 */
	values(): IterableIterator<T>;
}

interface ReadonlySet<T> {
	/** Iterates over values in the set. */
	[Symbol.iterator](): IterableIterator<T>;

	/**
	 * Returns an iterable of [v,v] pairs for every value `v` in the set.
	 */
	entries(): IterableIterator<[T, T]>;

	/**
	 * Despite its name, returns an iterable of the values in the set.
	 */
	keys(): IterableIterator<T>;

	/**
	 * Returns an iterable of values in the set.
	 */
	values(): IterableIterator<T>;
}

interface SetConstructor {
	new <T>(iterable?: Iterable<T> | null): Set<T>;
}

interface WeakSet<T extends WeakKey> {}

interface WeakSetConstructor {
	new <T extends WeakKey = WeakKey>(iterable: Iterable<T>): WeakSet<T>;
}

interface Promise<T> {}

interface PromiseConstructor {
	/**
	 * Creates a Promise that is resolved with an array of results when all of the provided Promises
	 * resolve, or rejected when any Promise is rejected.
	 * @param values An iterable of Promises.
	 * @returns A new Promise.
	 */
	all<T>(values: Iterable<T | PromiseLike<T>>): Promise<Awaited<T>[]>;

	/**
	 * Creates a Promise that is resolved or rejected when any of the provided Promises are resolved
	 * or rejected.
	 * @param values An iterable of Promises.
	 * @returns A new Promise.
	 */
	race<T>(values: Iterable<T | PromiseLike<T>>): Promise<Awaited<T>>;
}

interface String {
	/** Iterator */
	[Symbol.iterator](): IterableIterator<string>;
}

/////////////////////////////
/// es2015.promise
/////////////////////////////

interface PromiseConstructor {
	/**
	 * Creates a new Promise.
	 * @param executor A callback used to initialize the promise. This callback is passed two arguments:
	 * a resolve callback used to resolve the promise with a value or the result of another promise,
	 * and a reject callback used to reject the promise with a provided reason or error.
	 */
	new <T>(executor: (resolve: (value: T | PromiseLike<T>) => void, reject: (reason?: any) => void) => void): Promise<T>;

	/**
	 * Creates a Promise that is resolved with an array of results when all of the provided Promises
	 * resolve, or rejected when any Promise is rejected.
	 * @param values An array of Promises.
	 * @returns A new Promise.
	 */
	all<T extends readonly unknown[] | []>(values: T): Promise<{ -readonly [P in keyof T]: Awaited<T[P]>; }>;

	// see: lib.es2015.iterable.d.ts
	// all<T>(values: Iterable<T | PromiseLike<T>>): Promise<Awaited<T>[]>;

	/**
	 * Creates a Promise that is resolved or rejected when any of the provided Promises are resolved
	 * or rejected.
	 * @param values An array of Promises.
	 * @returns A new Promise.
	 */
	race<T extends readonly unknown[] | []>(values: T): Promise<Awaited<T[number]>>;

	// see: lib.es2015.iterable.d.ts
	// race<T>(values: Iterable<T | PromiseLike<T>>): Promise<Awaited<T>>;

	/**
	 * Creates a new rejected promise for the provided reason.
	 * @param reason The reason the promise was rejected.
	 * @returns A new rejected Promise.
	 */
	reject<T = never>(reason?: any): Promise<T>;

	/**
	 * Creates a new resolved promise.
	 * @returns A resolved promise.
	 */
	resolve(): Promise<void>;
	/**
	 * Creates a new resolved promise for the provided value.
	 * @param value A promise.
	 * @returns A promise whose internal state matches the provided promise.
	 */
	resolve<T>(value: T): Promise<Awaited<T>>;
	/**
	 * Creates a new resolved promise for the provided value.
	 * @param value A promise.
	 * @returns A promise whose internal state matches the provided promise.
	 */
	resolve<T>(value: T | PromiseLike<T>): Promise<Awaited<T>>;
}

declare var Promise: PromiseConstructor;

/////////////////////////////
/// es2015.symbol.wellknown
/////////////////////////////

interface SymbolConstructor {
	/**
	 * A method that determines if a constructor object recognizes an object as one of the
	 * constructor’s instances. Called by the semantics of the instanceof operator.
	 */
	readonly hasInstance: unique symbol;

	/**
	 * A function valued property that is the constructor function that is used to create
	 * derived objects.
	 */
	readonly species: unique symbol;

	/**
	 * A String value that is used in the creation of the default string description of an object.
	 * Called by the built-in method Object.prototype.toString.
	 */
	readonly toStringTag: unique symbol;
}

interface Map<K, V> {
	readonly [Symbol.toStringTag]: string;
}

interface WeakMap<K extends WeakKey, V> {
	readonly [Symbol.toStringTag]: string;
}

interface Set<T> {
	readonly [Symbol.toStringTag]: string;
}

interface WeakSet<T extends WeakKey> {
	readonly [Symbol.toStringTag]: string;
}

interface MapConstructor {
	readonly [Symbol.species]: MapConstructor;
}
interface SetConstructor {
	readonly [Symbol.species]: SetConstructor;
}
interface WeakMapConstructor {
	readonly [Symbol.species]: WeakMapConstructor;
}
interface WeakSetConstructor {
	readonly [Symbol.species]: WeakSetConstructor;
}

/////////////////////////////
/// esnext.collection
/////////////////////////////

interface Set<T> {
	/**
	 * @returns a new Set containing all the elements in this Set and also all the elements in the argument.
	 */
	union<U>(other: ReadonlySet<U>): Set<T | U>;
	/**
	 * @returns a new Set containing all the elements which are both in this Set and in the argument.
	 */
	intersection<U>(other: ReadonlySet<U>): Set<T & U>;
	/**
	 * @returns a new Set containing all the elements in this Set which are not also in the argument.
	 */
	difference<U>(other: ReadonlySet<U>): Set<T>;
	/**
	 * @returns a new Set containing all the elements which are in either this Set or in the argument, but not in both.
	 */
	symmetricDifference<U>(other: ReadonlySet<U>): Set<T | U>;
	/**
	 * @returns a boolean indicating whether all the elements in this Set are also in the argument.
	 */
	isSubsetOf(other: ReadonlySet<unknown>): boolean;
	/**
	 * @returns a boolean indicating whether all the elements in the argument are also in this Set.
	 */
	isSupersetOf(other: ReadonlySet<unknown>): boolean;
	/**
	 * @returns a boolean indicating whether this Set has no elements in common with the argument.
	 */
	isDisjointFrom(other: ReadonlySet<unknown>): boolean;
}
