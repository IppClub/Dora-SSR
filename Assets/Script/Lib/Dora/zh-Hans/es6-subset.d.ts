/// <reference no-default-lib="true"/>

/////////////////////////////
/// ECMAScript APIs es5
/////////////////////////////

declare var NaN: number;
declare var Infinity: number;

/**
 * 将字符串转换为整数。
 * @param string 需要转换为数字的字符串。
 * @param radix 指定`string`中数字的基数，取值范围为2到36。
 * 如果不提供此参数，以'0x'开头的字符串被视为十六进制，其它所有字符串被视为十进制。
 */
declare function parseInt(string: string, radix?: number): number;

/**
 * 将字符串转换为浮点数。
 * @param string 包含浮点数的字符串。
 */
declare function parseFloat(string: string): number;

/**
 * 返回一个布尔值，表示值是否为保留值NaN（非数字）。
 * @param number 数字值。
 */
declare function isNaN(number: number): boolean;

/**
 * 判断提供的数字是否有限。
 * @param number 任意数字值。
 */
declare function isFinite(number: number): boolean;

interface Symbol {
	/** 返回对象的字符串表示形式。 */
	toString(): string;

	/** 返回指定对象的原始值。 */
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
	/** Object.prototype.constructor的初始值是标准内置的Object构造函数。 */
	constructor: Function;

	/** 返回对象的字符串表示形式。 */
	toString(): string;

	/**
	 * 确定对象是否具有指定名称的属性。
	 * @param v 属性名称。
	 */
	hasOwnProperty(v: PropertyKey): boolean;
}

interface ObjectConstructor {
	new (value?: any): Object;
	(): any;
	(value: any): any;

	/**
	 * 获取指定对象的自有属性描述符。
	 * 自有属性描述符是直接在对象上定义的，而不是从对象的原型继承的。
	 * @param o 包含属性的对象。
	 * @param p 属性的名称。
	 */
	getOwnPropertyDescriptor(o: any, p: PropertyKey): PropertyDescriptor | undefined;

	/**
	 * 向对象添加属性，或修改现有属性的属性。
	 * @param o 要添加或修改属性的对象。这可以是原生JavaScript对象（即用户定义的对象或内置对象）或DOM对象。
	 * @param p 属性名称。
	 * @param attributes 属性的描述符。它可以是数据属性或访问器属性。
	 */
	defineProperty<T>(o: T, p: PropertyKey, attributes: PropertyDescriptor & ThisType<any>): T;

	/**
	 * 返回对象的可枚举字符串属性和方法的名称。
	 * @param o 包含属性和方法的对象。这可以是您创建的对象或现有的文档对象模型（DOM）对象。
	 */
	keys(o: object): string[];

	/**
	 * 根据传递的回调函数的返回值对可迭代对象的成员进行分组。
	 * @param items 可迭代对象。
	 * @param keySelector 会对items中的每个项目调用的回调。
	 */
	groupBy<K extends PropertyKey, T>(
		items: Iterable<T>,
		keySelector: (item: T, index: number) => K,
	): Partial<Record<K, T[]>>;
}

/**
 * 提供所有JavaScript对象通用的功能。
 */
declare var Object: ObjectConstructor;

/**
 * 创建新的函数。
 */
interface Function {
	/**
	 * 调用函数，将指定对象替换为函数的this值，将指定数组替换为函数的参数。
	 * @param thisArg 用作this对象的对象。
	 * @param argArray 传递给函数的一组参数。
	 */
	apply(this: Function, thisArg: any, argArray?: any): any;

	/**
	 * 调用对象的方法，将另一对象替换为当前对象。
	 * @param thisArg 用作当前对象的对象。
	 * @param argArray 传递给方法的参数列表。
	 */
	call(this: Function, thisArg: any, ...argArray: any[]): any;

	/**
	 * 对于给定的函数，创建绑定函数，该函数具有与原函数相同的主体。
	 * 绑定函数的this对象与指定对象关联，并具有指定的初始参数。
	 * @param thisArg 新函数中this关键字可以引用的对象。
	 * @param argArray 传递给新函数的参数列表。
	 */
	bind(this: Function, thisArg: any, ...argArray: any[]): any;

	/** 返回函数的字符串表示形式。 */
	toString(): string;

	readonly length: number;
}

/**
 * 提取函数类型的 'this' 参数的类型，如果函数类型没有 'this' 参数，则为 'unknown'。
 */
type ThisParameterType<T> = T extends (this: infer U, ...args: never) => any ? U : unknown;

/**
 * 从函数类型中移除 'this' 参数。
 */
type OmitThisParameter<T> = unknown extends ThisParameterType<T> ? T : T extends (...args: infer A) => infer R ? (...args: A) => R : T;

interface CallableFunction extends Function {
	/**
	 * 以指定对象作为 this 值，指定数组的元素作为参数，调用函数。
	 * @param thisArg 用作 this 对象的对象。
	 */
	apply<T, R>(this: (this: T) => R, thisArg: T): R;

	/**
	 * 以指定对象作为 this 值，指定数组的元素作为参数，调用函数。
	 * @param thisArg 用作 this 对象的对象。
	 * @param args 要传递给函数的参数值数组。
	 */
	apply<T, A extends any[], R>(this: (this: T, ...args: A) => R, thisArg: T, args: A): R;

	/**
	 * 以指定对象作为 this 值，指定的剩余参数作为参数，调用函数。
	 * @param thisArg 用作 this 对象的对象。
	 * @param args 要传递给函数的参数值。
	 */
	call<T, A extends any[], R>(this: (this: T, ...args: A) => R, thisArg: T, ...args: A): R;

	/**
	 * 对于给定的函数，创建具有与原函数相同主体的绑定函数。
	 * 绑定函数的 this 对象与指定对象关联，并具有指定的初始参数。
	 * @param thisArg 用作 this 对象的对象。
	 */
	bind<T>(this: T, thisArg: ThisParameterType<T>): OmitThisParameter<T>;

	/**
	 * 对于给定的函数，创建具有与原函数相同主体的绑定函数。
	 * 绑定函数的 this 对象与指定对象关联，并具有指定的初始参数。
	 * @param thisArg 用作 this 对象的对象。
	 * @param args 要绑定到函数参数的参数。
	 */
	bind<T, A extends any[], B extends any[], R>(this: (this: T, ...args: [...A, ...B]) => R, thisArg: T, ...args: A): (...args: B) => R;
}

interface NewableFunction extends Function {
	/**
	 * 以指定对象作为 this 值，指定数组的元素作为参数，调用函数。
	 * @param thisArg 用作 this 对象的对象。
	 */
	apply<T>(this: new () => T, thisArg: T): void;
	/**
	 * 以指定对象作为 this 值，指定数组的元素作为参数，调用函数。
	 * @param thisArg 用作 this 对象的对象。
	 * @param args 要传递给函数的参数值数组。
	 */
	apply<T, A extends any[]>(this: new (...args: A) => T, thisArg: T, args: A): void;

	/**
	 * 以指定对象作为 this 值，指定的剩余参数作为参数，调用函数。
	 * @param thisArg 用作 this 对象的对象。
	 * @param args 要传递给函数的参数值。
	 */
	call<T, A extends any[]>(this: new (...args: A) => T, thisArg: T, ...args: A): void;

	/**
	 * 对于给定的函数，创建具有与原函数相同主体的绑定函数。
	 * 绑定函数的 this 对象与指定对象关联，并具有指定的初始参数。
	 * @param thisArg 用作 this 对象的对象。
	 */
	bind<T>(this: T, thisArg: any): T;

	/**
	 * 对于给定的函数，创建具有与原函数相同主体的绑定函数。
	 * 绑定函数的 this 对象与指定对象关联，并具有指定的初始参数。
	 * @param thisArg 用作 this 对象的对象。
	 * @param args 要绑定到函数参数的参数。
	 */
	bind<A extends any[], B extends any[], R>(this: new (...args: [...A, ...B]) => R, thisArg: any, ...args: A): new (...args: B) => R;
}

interface IArguments {
	[index: number]: any;
	length: number;
	callee: Function;
}

interface String {
	/** 返回字符串的字符串表示形式。 */
	toString(): string;

	/**
	 * 返回指定索引处的字符。
	 * @param pos 需要获取字符的索引（从0开始）。
	 */
	charAt(pos: number): string;

	/**
	 * 返回指定位置的字符的Unicode值。
	 * @param index 需要获取字符Unicode值的索引（从0开始）。如果指定索引处没有字符，返回NaN。
	 */
	charCodeAt(index: number): number;

	/**
	 * 返回包含两个或多个字符串连接的字符串。
	 * @param strings 需要添加到字符串末尾的字符串。
	 */
	concat(...strings: string[]): string;

	/**
	 * 返回子字符串首次出现的位置。
	 * @param searchString 需要在字符串中查找的子字符串
	 * @param position 开始在String对象中进行搜索的索引。如果省略，搜索从字符串的开始处开始。
	 */
	indexOf(searchString: string, position?: number): number;

	/**
	 * 使用正则表达式或搜索字符串替换字符串中的文本。
	 * @param searchValue 需要搜索的字符串。
	 * @param replaceValue 包含替换文本的字符串。
	 */
	replace(searchValue: string, replaceValue: string): string;

	/**
	 * 使用正则表达式或搜索字符串替换字符串中的文本。
	 * @param searchValue 需要搜索的字符串。
	 * @param replacer 返回替换文本的函数。
	 */
	replace(searchValue: string, replacer: (substring: string, ...args: any[]) => string): string;

	/**
	 * 返回字符串的部分内容。
	 * @param start 指定部分字符串开始的索引。
	 * @param end 指定部分字符串结束的索引。子字符串包括开始到结束（但不包括结束）的字符。
	 * 如果未指定此值，则子字符串会继续到字符串的末尾。
	 */
	slice(start?: number, end?: number): string;

	/**
	 * 使用指定的分隔符将字符串分割成子字符串，并将它们作为数组返回。
	 * @param separator 用于分隔字符串的字符或字符组。如果省略，返回包含整个字符串的单元素数组。
	 * @param limit 用于限制返回数组中的元素数量的值。
	 */
	split(separator: string, limit?: number): string[];

	/**
	 * 返回String对象中指定位置的子字符串。
	 * @param start 指定子字符串开始的索引（从0开始）。
	 * @param end 指定子字符串结束的索引。子字符串包括开始到结束（但不包括结束）的字符。
	 * 如果省略结束，从开始到原始字符串的结束的字符都会被返回。
	 */
	substring(start: number, end?: number): string;

	/** 将字符串中的所有字母字符转换为小写。 */
	toLowerCase(): string;

	/** 将字符串中的所有字母字符转换为大写。 */
	toUpperCase(): string;

	/** 从字符串中移除前导和尾随的空格和行终止符。 */
	trim(): string;

	/** 返回String对象的长度。 */
	readonly length: number;

	// IE扩展
	/**
	 * 获取从指定位置开始且具有指定长度的子字符串。
	 * @deprecated 为了浏览器兼容性而保留的旧特性
	 * @param from 需要获取子字符串的开始位置。字符串中第一个字符的索引为零。
	 * @param length 返回的子字符串中应包含的字符数量。
	 */
	substr(from: number, length?: number): string;

	readonly [index: number]: string;
}

interface StringConstructor {
	fromCharCode(...codes: number[]): string;
}

/**
 * 允许操作和格式化文本字符串，并确定和定位字符串内的子字符串。
 */
declare var String: StringConstructor;

interface Boolean {
}

interface BooleanConstructor {
}

declare var Boolean: BooleanConstructor;

interface Number {
	/**
	 * 返回对象的字符串表示形式。
	 * @param radix 用于将数字值转换为字符串的基数。此值仅用于数字。
	 */
	toString(radix?: number): string;

	/**
	 * 返回以定点表示法表示的数字的字符串。
	 * @param fractionDigits 小数点后的位数。必须在0 - 20范围内，包含两端。
	 */
	toFixed(fractionDigits?: number): string;
}

interface NumberConstructor {
	(value?: any): number;

	/** JavaScript中可以表示的最大数字。等于大约1.79E+308。 */
	readonly MAX_VALUE: number;

	/** JavaScript中可以表示的最接近零的数字。等于大约5.00E-324。 */
	readonly MIN_VALUE: number;

	/**
	 * 不是数字的值。
	 * 在等式比较中，NaN不等于任何值，包括其自身。要测试一个值是否等于NaN，使用isNaN函数。
	 */
	readonly NaN: number;

	/**
	 * 小于JavaScript中可以表示的最大负数的值。
	 * JavaScript将NEGATIVE_INFINITY值显示为-infinity。
	 */
	readonly NEGATIVE_INFINITY: number;

	/**
	 * 大于JavaScript中可以表示的最大数字的值。
	 * JavaScript将POSITIVE_INFINITY值显示为infinity。
	 */
	readonly POSITIVE_INFINITY: number;
}

/** 表示任何类型数字的对象。所有JavaScript数字都是64位浮点数。 */
declare var Number: NumberConstructor;

interface TemplateStringsArray extends ReadonlyArray<string> {
	readonly raw: readonly string[];
}

/**
 * `import.meta`的类型。
 *
 * 如果需要声明给定属性存在于`import.meta`上，
 * 可以通过接口合并来增强此类型。
 */
interface ImportMeta {
}

/**
 * `import()`的可选第二个参数的类型。
 *
 * 如果您的主机环境支持额外的选项，此类型可能会
 * 通过接口合并进行增强。
 */
interface ImportCallOptions {
	/** @deprecated*/ assert?: ImportAssertions;
	with?: ImportAttributes;
}

/**
 * `import()`的可选第二个参数的`assert`属性的类型。
 */
interface ImportAssertions {
	[key: string]: string;
}

/**
 * `import()`的可选第二个参数的`with`属性的类型。
 */
interface ImportAttributes {
	[key: string]: string;
}

interface Math {
	/** 数学常数e。这是欧拉数，自然对数的底数。 */
	readonly E: number;
	/** 10的自然对数。 */
	readonly LN10: number;
	/** 2的自然对数。 */
	readonly LN2: number;
	/** e的以2为底的对数。 */
	readonly LOG2E: number;
	/** e的以10为底的对数。 */
	readonly LOG10E: number;
	/** 圆周率。这是圆的周长与直径的比值。 */
	readonly PI: number;
	/** 0.5的平方根，或等效地，1除以2的平方根。 */
	readonly SQRT1_2: number;
	/** 2的平方根。 */
	readonly SQRT2: number;
	/**
	 * 返回数字的绝对值（不考虑正负）。
	 * 例如，-5的绝对值与5的绝对值相同。
	 * @param x 需要求绝对值的数字表达式。
	 */
	abs(x: number): number;
	/**
	 * 返回数字的反余弦值。
	 * @param x 数字表达式。
	 */
	acos(x: number): number;
	/**
	 * 返回数字的反正弦值。
	 * @param x 数字表达式。
	 */
	asin(x: number): number;
	/**
	 * 返回数字的反正切值。
	 * @param x 需要求反正切的数字表达式。
	 */
	atan(x: number): number;
	/**
	 * 返回从X轴到点的角度（以弧度为单位）。
	 * @param y 表示笛卡尔y坐标的数字表达式。
	 * @param x 表示笛卡尔x坐标的数字表达式。
	 */
	atan2(y: number, x: number): number;
	/**
	 * 返回大于或等于其数字参数的最小整数。
	 * @param x 数字表达式。
	 */
	ceil(x: number): number;
	/**
	 * 返回数字的余弦值。
	 * @param x 包含以弧度测量的角度的数字表达式。
	 */
	cos(x: number): number;
	/**
	 * 返回e（自然对数的底数）的幂。
	 * @param x 表示e的幂的数字表达式。
	 */
	exp(x: number): number;
	/**
	 * 返回小于或等于其数字参数的最大整数。
	 * @param x 数字表达式。
	 */
	floor(x: number): number;
	/**
	 * 返回数字的自然对数（底数为e）。
	 * @param x 数字表达式。
	 */
	log(x: number): number;
	/**
	 * 返回一组提供的数字表达式中的最大值。
	 * @param values 待评估的数字表达式。
	 */
	max(...values: number[]): number;
	/**
	 * 返回一组提供的数字表达式中的最小值。
	 * @param values 待评估的数字表达式。
	 */
	min(...values: number[]): number;
	/**
	 * 返回基数表达式的指定幂的值。
	 * @param x 表达式的基数值。
	 * @param y 表达式的指数值。
	 */
	pow(x: number, y: number): number;
	/** 返回0和1之间的伪随机数。 */
	random(): number;
	/**
	 * 返回四舍五入到最接近的整数的提供的数字表达式。
	 * @param x 需要四舍五入到最接近的整数的值。
	 */
	round(x: number): number;
	/**
	 * 返回数字的正弦值。
	 * @param x 包含以弧度测量的角度的数字表达式。
	 */
	sin(x: number): number;
	/**
	 * 返回数字的平方根。
	 * @param x 数字表达式。
	 */
	sqrt(x: number): number;
	/**
	 * 返回数字的正切值。
	 * @param x 包含以弧度测量的角度的数字表达式。
	 */
	tan(x: number): number;
}
/** 提供基本数学功能和常数的内置对象。 */
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
	 * 获取数组的长度。这是数组中定义的最高元素的索引加一的数字。
	 */
	readonly length: number;
	/**
	 * 合并两个或更多的数组。
	 * @param items 需要添加到数组1末尾的额外项。
	 */
	concat(...items: ConcatArray<T>[]): T[];
	/**
	 * 合并两个或更多的数组。
	 * @param items 需要添加到数组1末尾的额外项。
	 */
	concat(...items: (T | ConcatArray<T>)[]): T[];
	/**
	 * 将数组的所有元素添加到由指定分隔符字符串分隔的字符串中。
	 * @param separator 用于在结果字符串中将一个数组元素与下一个元素分隔的字符串。如果省略，数组元素用逗号分隔。
	 */
	join(separator?: string): string;
	/**
	 * 返回数组的一个部分。
	 * @param start 指定数组部分的开始。
	 * @param end 指定数组部分的结束。这是索引 'end' 处的元素的排他性。
	 */
	slice(start?: number, end?: number): T[];
	/**
	 * 返回数组中值首次出现的索引。
	 * @param searchElement 需要在数组中定位的值。
	 * @param fromIndex 开始搜索的数组索引。如果省略 fromIndex，搜索从索引 0 开始。
	 */
	indexOf(searchElement: T, fromIndex?: number): number;
	/**
	 * 确定数组的所有成员是否满足指定的测试。
	 * @param predicate 接受最多三个参数的函数。every 方法为数组中的每个元素调用
	 * predicate 函数，直到 predicate 返回一个可以强制转换为布尔值 false 的值，
	 * 或直到数组的结束。
	 * @param thisArg 在 predicate 函数中可以引用的 this 关键字的对象。
	 * 如果省略 thisArg，undefined 用作 this 值。
	 */
	every<S extends T>(predicate: (value: T, index: number, array: readonly T[]) => value is S, thisArg?: any): this is readonly S[];
	/**
	 * 确定数组的所有成员是否满足指定的测试。
	 * @param predicate 接受最多三个参数的函数。every 方法为数组中的每个元素调用
	 * predicate 函数，直到 predicate 返回一个可以强制转换为布尔值 false 的值，
	 * 或直到数组的结束。
	 * @param thisArg 在 predicate 函数中可以引用的 this 关键字的对象。
	 * 如果省略 thisArg，undefined 用作 this 值。
	 */
	every(predicate: (value: T, index: number, array: readonly T[]) => unknown, thisArg?: any): boolean;
	/**
	 * 确定指定的回调函数是否对数组的任何元素返回 true。
	 * @param predicate 接受最多三个参数的函数。some 方法为数组中的每个元素调用
	 * predicate 函数，直到 predicate 返回一个可以强制转换为布尔值 true 的值，
	 * 或直到数组的结束。
	 * @param thisArg 在 predicate 函数中可以引用的 this 关键字的对象。
	 * 如果省略 thisArg，undefined 用作 this 值。
	 */
	some(predicate: (value: T, index: number, array: readonly T[]) => unknown, thisArg?: any): boolean;
	/**
	 * 对数组的每个元素执行指定的操作。
	 * @param callbackfn 接受最多三个参数的函数。forEach 为数组中的每个元素调用一次 callbackfn 函数。
	 * @param thisArg 在 callbackfn 函数中可以引用的 this 关键字的对象。如果省略 thisArg，undefined 用作 this 值。
	 */
	forEach(callbackfn: (value: T, index: number, array: readonly T[]) => void, thisArg?: any): void;
	/**
	 * 调用定义的回调函数处理数组的每个元素，并返回包含结果的数组。
	 * @param callbackfn 接受最多三个参数的函数。map 方法为数组中的每个元素调用一次 callbackfn 函数。
	 * @param thisArg 在 callbackfn 函数中可以引用的 this 关键字的对象。如果省略 thisArg，undefined 用作 this 值。
	 */
	map<U>(callbackfn: (value: T, index: number, array: readonly T[]) => U, thisArg?: any): U[];
	/**
	 * 返回数组中满足指定回调函数条件的元素。
	 * @param predicate 接受最多三个参数的函数。filter方法为数组中的每个元素调用一次predicate函数。
	 * @param thisArg 在predicate函数中可以引用的this关键字的对象。如果省略thisArg，undefined用作this值。
	 */
	filter<S extends T>(predicate: (value: T, index: number, array: readonly T[]) => value is S, thisArg?: any): S[];
	/**
	 * 返回数组中满足指定回调函数条件的元素。
	 * @param predicate 接受最多三个参数的函数。filter方法为数组中的每个元素调用一次predicate函数。
	 * @param thisArg 在predicate函数中可以引用的this关键字的对象。如果省略thisArg，undefined用作this值。
	 */
	filter(predicate: (value: T, index: number, array: readonly T[]) => unknown, thisArg?: any): T[];
	/**
	 * 为数组中的所有元素调用指定的回调函数。回调函数的返回值是累积结果，并在下一次调用回调函数时作为参数提供。
	 * @param callbackfn 接受最多四个参数的函数。reduce方法为数组中的每个元素调用一次callbackfn函数。
	 * @param initialValue 如果指定了initialValue，它将用作开始累积的初始值。第一次调用callbackfn函数时，将此值而不是数组值作为参数提供。
	 */
	reduce(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: readonly T[]) => T): T;
	reduce(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: readonly T[]) => T, initialValue: T): T;
	/**
	 * 为数组中的所有元素调用指定的回调函数。回调函数的返回值是累积结果，并在下一次调用回调函数时作为参数提供。
	 * @param callbackfn 接受最多四个参数的函数。reduce方法为数组中的每个元素调用一次callbackfn函数。
	 * @param initialValue 如果指定了initialValue，它将用作开始累积的初始值。第一次调用callbackfn函数时，将此值而不是数组值作为参数提供。
	 */
	reduce<U>(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: readonly T[]) => U, initialValue: U): U;
	/**
	 * 以降序为数组中的所有元素调用指定的回调函数。回调函数的返回值是累积结果，并在下一次调用回调函数时作为参数提供。
	 * @param callbackfn 接受最多四个参数的函数。reduceRight方法为数组中的每个元素调用一次callbackfn函数。
	 * @param initialValue 如果指定了initialValue，它将用作开始累积的初始值。第一次调用callbackfn函数时，将此值而不是数组值作为参数提供。
	 */
	reduceRight(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: readonly T[]) => T): T;
	reduceRight(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: readonly T[]) => T, initialValue: T): T;
	/**
	 * 以降序为数组中的所有元素调用指定的回调函数。回调函数的返回值是累积结果，并在下一次调用回调函数时作为参数提供。
	 * @param callbackfn 接受最多四个参数的函数。reduceRight方法为数组中的每个元素调用一次callbackfn函数。
	 * @param initialValue 如果指定了initialValue，它将用作开始累积的初始值。第一次调用callbackfn函数时，将此值而不是数组值作为参数提供。
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
	 * 获取或设置数组的长度。这是数组中最高索引加一的数字。
	 */
	length: number;
	/**
	 * 从数组中移除最后元素并返回它。
	 * 如果数组为空，返回undefined且数组不会被修改。
	 */
	pop(): T | undefined;
	/**
	 * 将新元素添加到数组的末尾，并返回新的数组长度。
	 * @param items 要添加到数组的新元素。
	 */
	push(...items: T[]): number;
	/**
	 * 合并两个或更多的数组。
	 * 此方法返回新数组，不会修改任何现有数组。
	 * @param items 额外的数组和/或要添加到数组末尾的元素。
	 */
	concat(...items: ConcatArray<T>[]): T[];
	/**
	 * 合并两个或更多的数组。
	 * 此方法返回新数组，不会修改任何现有数组。
	 * @param items 额外的数组和/或要添加到数组末尾的元素。
	 */
	concat(...items: (T | ConcatArray<T>)[]): T[];
	/**
	 * 将数组的所有元素添加到由指定分隔符字符串分隔的字符串中。
	 * @param separator 用于在结果字符串中将数组的元素与下一个元素分隔的字符串。如果省略，数组元素用逗号分隔。
	 */
	join(separator?: string): string;
	/**
	 * 就地反转数组中的元素。
	 * 此方法会改变数组并返回相同的数组引用。
	 */
	reverse(): T[];
	/**
	 * 从数组中移除第一元素并返回它。
	 * 如果数组为空，返回undefined且数组不会被修改。
	 */
	shift(): T | undefined;
	/**
	 * 返回数组的部分副本。
	 * 对于start和end，可以使用负索引表示从数组末尾的偏移。
	 * 例如，-2表示数组的倒数第二元素。
	 * @param start 指定数组部分的开始索引。
	 * 如果start未定义，则切片从索引0开始。
	 * @param end 指定数组部分的结束索引。这是索引 'end' 处的元素的排他性。
	 * 如果end未定义，则切片扩展到数组的末尾。
	 */
	slice(start?: number, end?: number): T[];
	/**
	 * 就地对数组进行排序。
	 * 此方法会改变数组并返回相同的数组引用。
	 * @param compareFn 用于确定元素顺序的函数。预期返回
	 * 如果第一参数小于第二参数，则返回负值，如果它们相等，则返回零，否则返回正值。
	 * 如果省略，元素按升序，ASCII字符顺序排序。
	 * ```ts
	 * [11,2,22,1].sort((a, b) => a - b)
	 * ```
	 */
	sort(compareFn?: (a: T, b: T) => number): this;
	/**
	 * 从数组中移除元素，并在必要时插入新元素，返回被删除的元素。
	 * @param start 从数组中开始移除元素的零基位置。
	 * @param deleteCount 要移除的元素数量。
	 * @returns 包含被删除元素的数组。
	 */
	splice(start: number, deleteCount?: number): T[];
	/**
	 * 从数组中移除元素，并在必要时插入新元素，返回被删除的元素。
	 * @param start 从数组中开始移除元素的零基位置。
	 * @param deleteCount 要移除的元素数量。
	 * @param items 要插入到被删除元素位置的元素。
	 * @returns 包含被删除元素的数组。
	 */
	splice(start: number, deleteCount: number, ...items: T[]): T[];
	/**
	 * 在数组的开始处插入新元素，并返回新的数组长度。
	 * @param items 要在数组开始处插入的元素。
	 */
	unshift(...items: T[]): number;
	/**
	 * 返回数组中值首次出现的索引，如果未找到则返回-1。
	 * @param searchElement 要在数组中定位的值。
	 * @param fromIndex 开始搜索的数组索引。如果省略fromIndex，搜索从索引0开始。
	 */
	indexOf(searchElement: T, fromIndex?: number): number;
	/**
	 * 判断数组的所有成员是否满足指定的测试。
	 * @param predicate 接受最多三个参数的函数。every方法对数组中的每个元素调用
	 * predicate函数，直到predicate返回可以强制转换为布尔值false的值，
	 * 或直到数组的结束。
	 * @param thisArg 在predicate函数中可以引用的this关键字的对象。
	 * 如果省略thisArg，undefined用作this值。
	 */
	every<S extends T>(predicate: (value: T, index: number, array: T[]) => value is S, thisArg?: any): this is S[];
	/**
	 * 判断数组的所有成员是否满足指定的测试。
	 * @param predicate 接受最多三个参数的函数。every方法对数组中的每个元素调用
	 * predicate函数，直到predicate返回可以强制转换为布尔值false的值，
	 * 或直到数组的结束。
	 * @param thisArg 在predicate函数中可以引用的this关键字的对象。
	 * 如果省略thisArg，undefined用作this值。
	 */
	every(predicate: (value: T, index: number, array: T[]) => unknown, thisArg?: any): boolean;
	/**
	 * 判断指定的回调函数是否对数组的任何元素返回true。
	 * @param predicate 接受最多三个参数的函数。some方法对数组中的每个元素调用
	 * predicate函数，直到predicate返回可以强制转换为布尔值true的值，
	 * 或直到数组的结束。
	 * @param thisArg 在predicate函数中可以引用的this关键字的对象。
	 * 如果省略thisArg，undefined用作this值。
	 */
	some(predicate: (value: T, index: number, array: T[]) => unknown, thisArg?: any): boolean;
	/**
	 * 对数组的每个元素执行指定的操作。
	 * @param callbackfn 接受最多三个参数的函数。forEach为数组中的每个元素调用一次callbackfn函数。
	 * @param thisArg 在callbackfn函数中可以引用的this关键字的对象。如果省略thisArg，undefined用作this值。
	 */
	forEach(callbackfn: (value: T, index: number, array: T[]) => void, thisArg?: any): void;
	/**
	 * 调用定义的回调函数处理数组的每个元素，并返回包含结果的数组。
	 * @param callbackfn 接受最多三个参数的函数。map方法为数组中的每个元素调用一次callbackfn函数。
	 * @param thisArg 在callbackfn函数中可以引用的this关键字的对象。如果省略thisArg，undefined用作this值。
	 */
	map<U>(callbackfn: (value: T, index: number, array: T[]) => U, thisArg?: any): U[];
	/**
	 * 返回数组中满足指定回调函数条件的元素。
	 * @param predicate 接受最多三个参数的函数。filter方法为数组中的每个元素调用一次predicate函数。
	 * @param thisArg 在predicate函数中可以引用的this关键字的对象。如果省略thisArg，undefined用作this值。
	 */
	filter<S extends T>(predicate: (value: T, index: number, array: T[]) => value is S, thisArg?: any): S[];
	/**
	 * 返回数组中满足指定回调函数条件的元素。
	 * @param predicate 接受最多三个参数的函数。filter方法为数组中的每个元素调用一次predicate函数。
	 * @param thisArg 在predicate函数中可以引用的this关键字的对象。如果省略thisArg，undefined用作this值。
	 */
	filter(predicate: (value: T, index: number, array: T[]) => unknown, thisArg?: any): T[];
	/**
	 * 调用指定的回调函数处理数组的所有元素。回调函数的返回值是累积结果，并在下一次调用回调函数时作为参数提供。
	 * @param callbackfn 接受最多四个参数的函数。reduce方法为数组中的每个元素调用一次callbackfn函数。
	 * @param initialValue 如果指定了initialValue，它将用作开始累积的初始值。第一次调用callbackfn函数时，将此值而不是数组值作为参数提供。
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
	 * 为数组中的所有元素调用指定的回调函数，顺序为降序。回调函数的返回值是累积结果，并在下一次调用回调函数时作为参数提供。
	 * @param callbackfn 接受最多四个参数的函数。reduceRight方法为数组中的每个元素调用一次callbackfn函数。
	 * @param initialValue 如果指定了initialValue，它将用作开始累积的初始值。第一次调用callbackfn函数时，将此值而不是数组值作为参数提供。
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
	 * 为 Promise 的解决和/或拒绝附加回调函数。
	 * @param onfulfilled 当 Promise 解决时执行的回调函数。
	 * @param onrejected 当 Promise 被拒绝时执行的回调函数。
	 * @returns 一个 Promise，用于完成执行的任何回调函数。
	 */
	then<TResult1 = T, TResult2 = never>(onfulfilled?: ((value: T) => TResult1 | PromiseLike<TResult1>) | undefined | null, onrejected?: ((reason: any) => TResult2 | PromiseLike<TResult2>) | undefined | null): PromiseLike<TResult1 | TResult2>;
}

/**
 * 表示异步操作的完成
 */
interface Promise<T> {
	/**
	 * 为 Promise 的解决和/或拒绝附加回调函数。
	 * @param onfulfilled 当 Promise 解决时执行的回调函数。
	 * @param onrejected 当 Promise 被拒绝时执行的回调函数。
	 * @returns 一个 Promise，用于完成执行的任何回调函数。
	 */
	then<TResult1 = T, TResult2 = never>(onfulfilled?: ((value: T) => TResult1 | PromiseLike<TResult1>) | undefined | null, onrejected?: ((reason: any) => TResult2 | PromiseLike<TResult2>) | undefined | null): Promise<TResult1 | TResult2>;

	/**
	 * 仅为 Promise 的拒绝附加回调函数。
	 * @param onrejected 当 Promise 被拒绝时执行的回调函数。
	 * @returns 一个 Promise，用于完成回调函数。
	 */
	catch<TResult = never>(onrejected?: ((reason: any) => TResult | PromiseLike<TResult>) | undefined | null): Promise<T | TResult>;
}

/**
 * 递归地解包类型的 "等待类型"。非 promise 的 "thenable" 应解析为 `never`。这模拟了 `await` 的行为。
 */
type Awaited<T> = T extends null | undefined ? T : // 对于 `null | undefined` 的特殊情况，当不在 `--strictNullChecks` 模式时
	T extends object & { then(onfulfilled: infer F, ...args: infer _): any; } ? // `await` 只解包具有可调用 `then` 的对象类型。非对象类型不会被解包
		F extends ((value: infer V, ...args: infer _) => any) ? // 如果 `then` 的参数是可调用的，提取第一个参数
			Awaited<V> : // 递归地解包值
		never : // `then` 的参数不可调用
	T; // 非对象或非 thenable

interface ArrayLike<T> {
	readonly length: number;
	readonly [n: number]: T;
}

/**
 * 使 T 中的所有属性变为可选
 */
type Partial<T> = {
	[P in keyof T]?: T[P];
};

/**
 * 使 T 中的所有属性都为必需
 */
type Required<T> = {
	[P in keyof T]-?: T[P];
};

/**
 * 使 T 中的所有属性都为只读
 */
type Readonly<T> = {
	readonly [P in keyof T]: T[P];
};

/**
 * 从 T 中挑选一组属性，其键在联合 K 中
 */
type Pick<T, K extends keyof T> = {
	[P in K]: T[P];
};

/**
 * 构造一个类型，该类型具有一组属性 K，类型为 T
 */
type Record<K extends keyof any, T> = {
	[P in K]: T;
};

/**
 * 从 T 中排除那些可以分配给 U 的类型
 */
type Exclude<T, U> = T extends U ? never : T;

/**
 * 从 T 中提取那些可以分配给 U 的类型
 */
type Extract<T, U> = T extends U ? T : never;

/**
 * 构造一个类型，该类型具有 T 的属性，除了类型 K 中的属性。
 */
type Omit<T, K extends keyof any> = Pick<T, Exclude<keyof T, K>>;

/**
 * 从 T 中排除 null 和 undefined
 */
type NonNullable<T> = T & {};

/**
 * 获取函数类型的参数，以元组形式
 */
type Parameters<T extends (...args: any) => any> = T extends (...args: infer P) => any ? P : never;

/**
 * 获取构造函数类型的参数，以元组形式
 */
type ConstructorParameters<T extends abstract new (...args: any) => any> = T extends abstract new (...args: infer P) => any ? P : never;

/**
 * 获取函数类型的返回类型
 */
type ReturnType<T extends (...args: any) => any> = T extends (...args: any) => infer R ? R : any;

/**
 * 获取构造函数类型的返回类型
 */
type InstanceType<T extends abstract new (...args: any) => any> = T extends abstract new (...args: any) => infer R ? R : any;

/**
 * 将字符串字面量类型转换为大写
 */
type Uppercase<S extends string> = intrinsic;

/**
 * 将字符串字面量类型转换为小写
 */
type Lowercase<S extends string> = intrinsic;

/**
 * 将字符串字面量类型的首字母转换为大写
 */
type Capitalize<S extends string> = intrinsic;

/**
 * 将字符串字面量类型的首字母转换为小写
 */
type Uncapitalize<S extends string> = intrinsic;

/**
 * 标记上下文中的 'this' 类型
 */
interface ThisType<T> {}

/**
 * 存储用于 WeakSet，WeakMap，WeakRef 和 FinalizationRegistry 的类型
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
	 * 返回数组中第一个满足条件的元素的值，否则返回 undefined。
	 * @param predicate find 函数会为数组中的每个元素调用一次 predicate 函数，按升序，
	 * 直到找到一个 predicate 返回 true 的元素。如果找到这样的元素，find
	 * 立即返回该元素的值。否则，find 返回 undefined。
	 * @param thisArg 如果提供，它将被用作每次调用 predicate 的 this 值。
	 * 如果未提供，将使用 undefined 代替。
	 */
	find<S extends T>(predicate: (value: T, index: number, obj: T[]) => value is S, thisArg?: any): S | undefined;
	find(predicate: (value: T, index: number, obj: T[]) => unknown, thisArg?: any): T | undefined;

	/**
	 * 返回数组中第一个满足条件的元素的索引，否则返回 -1。
	 * @param predicate find 函数会为数组中的每个元素调用一次 predicate 函数，按升序，
	 * 直到找到一个 predicate 返回 true 的元素。如果找到这样的元素，
	 * findIndex 立即返回该元素的索引。否则，findIndex 返回 -1。
	 * @param thisArg 如果提供，它将被用作每次调用 predicate 的 this 值。
	 * 如果未提供，将使用 undefined 代替。
	 */
	findIndex(predicate: (value: T, index: number, obj: T[]) => unknown, thisArg?: any): number;

	/**
	 * 将数组中从 `start` 到 `end` 索引的所有元素更改为静态 `value`，并返回修改后的数组
	 * @param value 用于填充数组部分的值
	 * @param start 开始填充数组的索引。如果 start 为负数，则将其视为
	 * 长度+start，其中长度为数组的长度。
	 * @param end 停止填充数组的索引。如果 end 为负数，将其视为
	 * 长度+end。
	 */
	fill(value: T, start?: number, end?: number): this;
}

interface ArrayConstructor {
	/**
	 * 从类数组对象创建数组。
	 * @param arrayLike 要转换为数组的类数组对象。
	 */
	from<T>(arrayLike: ArrayLike<T>): T[];

	/**
	 * 从可迭代对象创建数组。
	 * @param arrayLike 要转换为数组的类数组对象。
	 * @param mapfn 在数组的每个元素上调用的映射函数。
	 * @param thisArg 用于调用 mapfn 的 'this' 值。
	 */
	from<T, U>(arrayLike: ArrayLike<T>, mapfn: (v: T, k: number) => U, thisArg?: any): U[];

	/**
	 * 从一组元素返回新数组。
	 * @param items 要包含在新数组对象中的一组元素。
	 */
	of<T>(...items: T[]): T[];
}

interface Math {
	/**
	 * 返回 x 的符号，指示 x 是正数、负数还是零。
	 * @param x 要测试的数值表达式
	 */
	sign(x: number): number;

	/**
	 * 返回数字的以 10 为底的对数。
	 * @param x 数值表达式。
	 */
	log10(x: number): number;

	/**
	 * 返回数字的以 2 为底的对数。
	 * @param x 数值表达式。
	 */
	log2(x: number): number;

	/**
	 * 返回 1 + x 的自然对数。
	 * @param x 数值表达式。
	 */
	log1p(x: number): number;

	/**
	 * 返回数值表达式 x 的整数部分，去除任何小数位。
	 * 如果 x 已经是一个整数，则结果为 x。
	 * @param x 数值表达式。
	 */
	trunc(x: number): number;
}

interface NumberConstructor {
	/**
	 * Number.EPSILON 的值是 1 和大于 1 的最小可表示为 Number 值的差，
	 * 大约为：2.2204460492503130808472633361816 x 10‍−‍16。
	 */
	readonly EPSILON: number;

	/**
	 * 如果传入的值是有限的，则返回 true。
	 * 与全局 isFinite 不同，Number.isFinite 不强制将参数转换为
	 * 数字。只有类型为 number 的有限值，结果为 true。
	 * @param number 数值。
	 */
	isFinite(number: unknown): boolean;

	/**
	 * 如果传入的值是整数，则返回 true，否则返回 false。
	 * @param number 数值。
	 */
	isInteger(number: unknown): boolean;

	/**
	 * 返回一个布尔值，该值指示值是否为保留值 NaN（非数字）。
	 * 与全局 isNaN() 不同，Number.isNaN() 不强制将参数
	 * 转换为数字。只有类型为 number，且也是 NaN 的值，结果为 true。
	 * @param number 数值。
	 */
	isNaN(number: unknown): boolean;

	/**
	 * 最大整数 n 的值，使得 n 和 n + 1 都可以精确表示为
	 * Number 值。
	 * Number.MAX_SAFE_INTEGER 的值为 9007199254740991 2^53 - 1。
	 */
	readonly MAX_SAFE_INTEGER: number;

	/**
	 * 最小整数 n 的值，使得 n 和 n - 1 都可以精确表示为
	 * Number 值。
	 * Number.MIN_SAFE_INTEGER 的值为 -9007199254740991 (-2^53 + 1)。
	 */
	readonly MIN_SAFE_INTEGER: number;

	/**
	 * 将字符串转换为浮点数。
	 * @param string 包含浮点数的字符串。
	 */
	parseFloat(string: string): number;

	/**
	 * 将字符串转换为整数。
	 * @param string 要转换为数字的字符串。
	 * @param radix 一个介于 2 和 36 之间的值，指定 `string` 中数字的基数。
	 * 如果未提供此参数，带有 '0x' 前缀的字符串被视为十六进制。
	 * 所有其他字符串被视为十进制。
	 */
	parseInt(string: string, radix?: number): number;
}

interface ObjectConstructor {
	/**
	 * 将一个或多个源对象的所有可枚举自有属性的值复制到目标对象。返回目标对象。
	 * @param target 要复制到的目标对象。
	 * @param source 要复制属性的源对象。
	 */
	assign<T extends {}, U>(target: T, source: U): T & U;

	/**
	 * 将一个或多个源对象的所有可枚举自有属性的值复制到目标对象。返回目标对象。
	 * @param target 要复制到的目标对象。
	 * @param source1 要复制属性的第一源对象。
	 * @param source2 要复制属性的第二源对象。
	 */
	assign<T extends {}, U, V>(target: T, source1: U, source2: V): T & U & V;

	/**
	 * 将一个或多个源对象的所有可枚举自有属性的值复制到目标对象。返回目标对象。
	 * @param target 要复制到的目标对象。
	 * @param source1 要复制属性的第一源对象。
	 * @param source2 要复制属性的第二源对象。
	 * @param source3 要复制属性的第三源对象。
	 */
	assign<T extends {}, U, V, W>(target: T, source1: U, source2: V, source3: W): T & U & V & W;

	/**
	 * 将一个或多个源对象的所有可枚举自有属性的值复制到目标对象。返回目标对象。
	 * @param target 要复制到的目标对象。
	 * @param sources 要复制属性的一个或多个源对象
	 */
	assign(target: object, ...sources: any[]): any;

	/**
	 * 返回对象的可枚举字符串属性和方法的名称。
	 * @param o 包含属性和方法的对象。这可以是您创建的对象或现有的 Document Object Model (DOM) 对象。
	 */
	keys(o: {}): string[];
}

interface ReadonlyArray<T> {
	/**
	 * 返回数组中第一满足条件的元素的值，否则返回 undefined。
	 * @param predicate find 函数会为数组中的每个元素调用一次 predicate 函数，按升序，
	 * 直到找到一个 predicate 返回 true 的元素。如果找到这样的元素，find
	 * 立即返回该元素值。否则，find 返回 undefined。
	 * @param thisArg 如果提供，它将被用作每次调用 predicate 的 this 值。
	 * 如果未提供，将使用 undefined 代替。
	 */
	find<S extends T>(predicate: (value: T, index: number, obj: readonly T[]) => value is S, thisArg?: any): S | undefined;
	find(predicate: (value: T, index: number, obj: readonly T[]) => unknown, thisArg?: any): T | undefined;

	/**
	 * 返回数组中第一满足条件的元素的索引，否则返回 -1。
	 * @param predicate find 函数会为数组中的每个元素调用一次 predicate 函数，按升序，
	 * 直到找到一个 predicate 返回 true 的元素。如果找到这样的元素，
	 * findIndex 立即返回该元素索引。否则，findIndex 返回 -1。
	 * @param thisArg 如果提供，它将被用作每次调用 predicate 的 this 值。
	 * 如果未提供，将使用 undefined 代替。
	 */
	findIndex(predicate: (value: T, index: number, obj: readonly T[]) => unknown, thisArg?: any): number;
}

interface String {
	/**
	 * 如果 searchString 作为此对象转换为 String 的结果的子字符串出现在一个或多个位置上，
	 * 并且这些位置大于或等于 position，则返回 true；否则，返回 false。
	 * @param searchString 搜索字符串
	 * @param position 如果 position 未定义，则假定为 0，以便搜索整个 String。
	 */
	includes(searchString: string, position?: number): boolean;

	/**
	 * 如果 searchString 转换为 String 的元素序列与此对象（转换为 String）的相应元素序列相同，
	 * 并且起始位置为 endPosition - length(this)，则返回 true。否则返回 false。
	 */
	endsWith(searchString: string, endPosition?: number): boolean;

	/**
	 * 返回由 count 个副本连接在一起的 String 值。如果 count 为 0，
	 * 则返回空字符串。
	 * @param count 要附加的副本数
	 */
	repeat(count: number): string;

	/**
	 * 如果 searchString 转换为 String 的元素序列与此对象（转换为 String）的相应元素序列相同，
	 * 并且起始位置为 position，则返回 true。否则返回 false。
	 */
	startsWith(searchString: string, position?: number): boolean;
}

/////////////////////////////
/// es2015.collection
/////////////////////////////

interface Map<K, V> {
	clear(): void;
	/**
	 * @returns 如果 Map 中存在元素并已被删除，则返回 true，否则返回 false。
	 */
	delete(key: K): boolean;
	/**
	 * 对 Map 中的每个键/值对执行一次提供的函数，按插入顺序。
	 */
	forEach(callbackfn: (value: V, key: K, map: Map<K, V>) => void, thisArg?: any): void;
	/**
	 * 从 Map 对象返回指定的元素。如果与提供的键关联的值是对象，则将获取该对象的引用，并且对该对象所做的任何更改都将有效地在 Map 中修改它。
	 * @returns 返回与指定键关联的元素。如果没有与指定键关联的元素，则返回 undefined。
	 */
	get(key: K): V | undefined;
	/**
	 * @returns 指示是否存在具有指定键的元素的布尔值。
	 */
	has(key: K): boolean;
	/**
	 * 向 Map 添加具有指定键和值的新元素。如果已存在具有相同键的元素，则将更新该元素。
	 */
	set(key: K, value: V): this;
	/**
	 * @returns Map 中的元素数量。
	 */
	readonly size: number;
}

interface MapConstructor {
	new (): Map<any, any>;
	new <K, V>(entries?: readonly (readonly [K, V])[] | null): Map<K, V>;

	/**
	 * 根据传递的回调函数的返回值对可迭代对象的成员进行分组。
	 * @param items 可迭代对象。
	 * @param keySelector 会为 items 中的每个项目调用的回调。
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
	 * 从 WeakMap 中删除指定的元素。
	 * @returns 如果元素已成功删除，则返回 true，否则返回 false。
	 */
	delete(key: K): boolean;
	/**
	 * @returns 指定的元素。
	 */
	get(key: K): V | undefined;
	/**
	 * @returns 指示是否存在具有指定键的元素的布尔值。
	 */
	has(key: K): boolean;
	/**
	 * 添加具有指定键和值的新元素。
	 * @param key 必须是对象或符号。
	 */
	set(key: K, value: V): this;
}

interface WeakMapConstructor {
	new <K extends WeakKey = WeakKey, V = any>(entries?: readonly (readonly [K, V])[] | null): WeakMap<K, V>;
}
declare var WeakMap: WeakMapConstructor;

interface Set<T> {
	/**
	 * 将具有指定值的新元素追加到 Set 的末尾。
	 */
	add(value: T): this;

	clear(): void;
	/**
	 * 从 Set 中删除指定的值。
	 * @returns 如果 Set 中存在元素并已被删除，则返回 true，否则返回 false。
	 */
	delete(value: T): boolean;
	/**
	 * 对 Set 对象中的每个值执行一次提供的函数，按插入顺序。
	 */
	forEach(callbackfn: (value: T, value2: T, set: Set<T>) => void, thisArg?: any): void;
	/**
	 * @returns 指示是否存在具有指定值的元素的布尔值。
	 */
	has(value: T): boolean;
	/**
	 * @returns Set 中的（唯一）元素数量。
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
	 * 在 WeakSet 的末尾添加新值。
	 */
	add(value: T): this;
	/**
	 * 从 WeakSet 中删除指定的元素。
	 * @returns 如果元素存在并已被删除，则返回 true，否则返回 false。
	 */
	delete(value: T): boolean;
	/**
	 * @returns 指示 WeakSet 中是否存在值的布尔值。
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
	 * 返回新的唯一 Symbol 值。
	 * @param  description 新 Symbol 对象的描述。
	 */
	(description?: string | number): symbol;

	/**
	 * 如果找到，从全局 symbol 注册表中返回与给定键匹配的 Symbol 对象。
	 * 否则，返回带有此键的新 symbol。
	 * @param key 要搜索的键。
	 */
	for(key: string): symbol;

	/**
	 * 如果找到，返回与给定 Symbol 匹配的全局 symbol 注册表中的键。
	 * 否则，返回 undefined。
	 * @param sym 要找到键的 Symbol。
	 */
	keyFor(sym: symbol): string | undefined;
}

declare var Symbol: SymbolConstructor;

interface SymbolConstructor {
	/**
	 * 返回对象的默认迭代器的方法。由 for-of 语句的语义调用。
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
	// 注意：'next' 是使用元组定义的，以确保我们在所有地方报告正确的可分配性错误。
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
	/** 迭代器 */
	[Symbol.iterator](): IterableIterator<T>;

	/**
	 * 返回数组中每个条目的键值对的可迭代对象
	 */
	entries(): IterableIterator<[number, T]>;
}

interface ArrayConstructor {
	/**
	 * 从可迭代对象创建数组。
	 * @param iterable 要转换为数组的可迭代对象。
	 */
	from<T>(iterable: Iterable<T> | ArrayLike<T>): T[];

	/**
	 * 从可迭代对象创建数组。
	 * @param iterable 要转换为数组的可迭代对象。
	 * @param mapfn 在数组的每个元素上调用的映射函数。
	 * @param thisArg 用于调用 mapfn 的 'this' 值。
	 */
	from<T, U>(iterable: Iterable<T> | ArrayLike<T>, mapfn: (v: T, k: number) => U, thisArg?: any): U[];
}

interface IArguments {
	/** Iterator */
	[Symbol.iterator](): IterableIterator<any>;
}

interface ReadonlyArray<T> {
	/** 数组中值的迭代器。 */
	[Symbol.iterator](): IterableIterator<T>;

	/**
	 * 返回数组中每个条目的键值对的可迭代对象。
	 */
	entries(): IterableIterator<[number, T]>;
}

interface Map<K, V> {
	/** 返回映射中条目的迭代器。 */
	[Symbol.iterator](): IterableIterator<[K, V]>;

	/**
	 * 返回映射中每个条目的键值对的可迭代对象。
	 */
	entries(): IterableIterator<[K, V]>;

	/**
	 * 返回映射中键的可迭代对象。
	 */
	keys(): IterableIterator<K>;

	/**
	 * 返回映射中值的可迭代对象。
	 */
	values(): IterableIterator<V>;
}

interface ReadonlyMap<K, V> {
	/** 返回映射中条目的迭代器。 */
	[Symbol.iterator](): IterableIterator<[K, V]>;

	/**
	 * 返回映射中每个条目的键值对的可迭代对象。
	 */
	entries(): IterableIterator<[K, V]>;

	/**
	 * 返回映射中键的可迭代对象。
	 */
	keys(): IterableIterator<K>;

	/**
	 * 返回映射中值的可迭代对象。
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
	/** 遍历集合中的值。 */
	[Symbol.iterator](): IterableIterator<T>;
	/**
	 * 返回集合中每个值 `v` 的 [v,v] 对的可迭代对象。
	 */
	entries(): IterableIterator<[T, T]>;
	/**
	 * 尽管名字如此，但返回集合中值的可迭代对象。
	 */
	keys(): IterableIterator<T>;

	/**
	 * 返回集合中值的可迭代对象。
	 */
	values(): IterableIterator<T>;
}

interface ReadonlySet<T> {
	/** 遍历集合中的值。 */
	[Symbol.iterator](): IterableIterator<T>;

	/**
	 * 返回集合中每个值 `v` 的 [v,v] 对的可迭代对象。
	 */
	entries(): IterableIterator<[T, T]>;

	/**
	 * 尽管名字如此，但返回集合中值的可迭代对象。
	 */
	keys(): IterableIterator<T>;

	/**
	 * 返回集合中值的可迭代对象。
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
	 * 创建一个 Promise，当所有提供的 Promise 都解析时，该 Promise 会以结果数组的形式解析，当任何一个 Promise 被拒绝时，它会被拒绝。
	 * @param values 一个 Promise 的可迭代对象。
	 * @returns 新的 Promise。
	 */
	all<T>(values: Iterable<T | PromiseLike<T>>): Promise<Awaited<T>[]>;

	/**
	 * 创建一个 Promise，当任何一个提供的 Promise 被解析或拒绝时，该 Promise 会被解析或拒绝。
	 * @param values 一个 Promise 的可迭代对象。
	 * @returns 新的 Promise。
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
	 * 创建新的 Promise。
	 * @param executor 用于初始化 promise 的回调。此回调传递两个参数：
	 * 用于以值或另一 promise 的结果解析 promise 的 resolve 回调，
	 * 以及用于以提供的原因或错误拒绝 promise 的 reject 回调。
	 */
	new <T>(executor: (resolve: (value: T | PromiseLike<T>) => void, reject: (reason?: any) => void) => void): Promise<T>;

	/**
	 * 创建一个 Promise，当所有提供的 Promise 都解析时，该 Promise 会以结果数组的形式解析，当任何 Promise 被拒绝时，它会被拒绝。
	 * @param values 一个 Promise 数组。
	 * @returns 新的 Promise。
	 */
	all<T extends readonly unknown[] | []>(values: T): Promise<{ -readonly [P in keyof T]: Awaited<T[P]>; }>;

	/**
	 * 创建一个 Promise，当任何一个提供的 Promise 被解析或拒绝时，该 Promise 会被解析或拒绝。
	 * @param values 一个 Promise 数组。
	 * @returns 新的 Promise。
	 */
	race<T extends readonly unknown[] | []>(values: T): Promise<Awaited<T[number]>>;

	/**
	 * 为提供的原因创建新的拒绝 promise。
	 * @param reason 拒绝 promise 的原因。
	 * @returns 新的拒绝 Promise。
	 */
	reject<T = never>(reason?: any): Promise<T>;

	/**
	 * 创建新的已解析 promise。
	 * @returns 已解析的 promise。
	 */
	resolve(): Promise<void>;
	/**
	 * 为提供的值创建新的已解析 promise。
	 * @param value promise。
	 * @returns 其内部状态与提供的 promise 匹配的 promise。
	 */
	resolve<T>(value: T): Promise<Awaited<T>>;
	/**
	 * 为提供的值创建新的已解析 promise。
	 * @param value promise。
	 * @returns 其内部状态与提供的 promise 匹配的 promise。
	 */
	resolve<T>(value: T | PromiseLike<T>): Promise<Awaited<T>>;
}

declare var Promise: PromiseConstructor;

/////////////////////////////
/// es2015.symbol.wellknown
/////////////////////////////

interface SymbolConstructor {
	/**
	 * 一种方法，用于确定构造函数对象是否将对象识别为构造函数的实例之一。由 instanceof 操作符的语义调用。
	 */
	readonly hasInstance: unique symbol;

	/**
	 * 一个函数值属性，该属性是用于创建派生对象的构造函数。
	 */
	readonly species: unique symbol;

	/**
	 * 一个字符串值，用于创建对象默认字符串描述。由内置方法 Object.prototype.toString 调用。
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
	 * @returns 返回一个新的 Set，包含此 Set 中所有的元素以及参数中所有的元素。
	 */
	union<U>(other: ReadonlySet<U>): Set<T | U>;
	/**
	 * @returns 返回一个新的 Set，包含同时存在于此 Set 和参数中的所有元素。
	 */
	intersection<U>(other: ReadonlySet<U>): Set<T & U>;
	/**
	 * @returns 返回一个新的 Set，包含此 Set 中所有不在参数中的元素。
	 */
	difference<U>(other: ReadonlySet<U>): Set<T>;
	/**
	 * @returns 返回一个新的 Set，包含存在于此 Set 或参数中的所有元素，但不包含同时存在于两者中的元素。
	 */
	symmetricDifference<U>(other: ReadonlySet<U>): Set<T | U>;
	/**
	 * @returns 返回一个布尔值，指示此 Set 中的所有元素是否也都在参数中。
	 */
	isSubsetOf(other: ReadonlySet<unknown>): boolean;
	/**
	 * @returns 返回一个布尔值，指示参数中的所有元素是否也都在此 Set 中。
	 */
	isSupersetOf(other: ReadonlySet<unknown>): boolean;
	/**
	 * @returns 返回一个布尔值，指示此 Set 是否与参数没有共同的元素。
	 */
	isDisjointFrom(other: ReadonlySet<unknown>): boolean;
}
