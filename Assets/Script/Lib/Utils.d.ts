import { Vec2 } from "Dora";
type Vec2 = Vec2.Type;

declare module 'Utils' {

class StructType {
	private __struct_type__: "Struct";
}

type StructArray<T> = {
	set(index: number, item: T & StructType): void;
	get(index: number): T & StructType;
	insert(item: T & StructType): void;
	/** index is 1 based */
	insert(index: number, item: T & StructType): void;
	remove(item: T & StructType): (T & StructType) | undefined;
	/** index is 1 based */
	removeAt(index: number): boolean;
	clear(): void;
	each(handler: (this: void, item: T & StructType, index: number) => boolean): boolean;
	contains(item: T & StructType): boolean;
	count(): number;
	sort(comparer: (this: void, a: T, b: T) => boolean): void;
	__added(this: void, index: number, item: T & StructType): void;
	__removed(this: void, index: number, item: T & StructType): void;
	__changed(this: void, index: number, item: T & StructType): void;
	__updated(this: void): void;
} & StructType;

type Struct<T> = {
	eachAttr<K extends keyof T>(handler: (this: void, key: K, value: T[K]) => void): void;
	__modified<K extends keyof T>(this: void, key: K, value: T[K]): void;
	__updated(this: void): void;
} & T & StructType;

interface StructClass<T> {
	(this: void, values?: T): Struct<T>;
}

interface StructArrayClass<T> {
	(this: void, items?: (T & StructType)[]): StructArray<T>;
}

interface StructModule {
	[name: string]: StructModule;
	<T>(this: void, fieldName: keyof T, ...fieldNames: (keyof T)[]): StructClass<T>;
	<T>(this: void, fieldNames: (keyof T)[]): StructClass<T>;
	<T>(this: void): StructArrayClass<T>;
}

type StructHelper = {
	load<T>(input: string | {}, name?: string): Struct<T> | StructArray<T>;
	loadfile<T>(filename: string):  Struct<T> | StructArray<T>;
	clear(): void;
	has(name: string): boolean;
} & {
	[name: string]: StructModule
};

export const Struct: StructHelper;
export function Set(this: void, list: any[]): Record<any, boolean>;
export function CompareTable(this: void, oldTable: [any], newTable: [any]): [added: [any], deleted: [any]];
export function Round(this: void, val: number | Vec2): number | Vec2;
export function IsValidPath(this: void, path: string): boolean;
export function GSplit(this: void, text: string, pattern: string, plain: boolean): () => string;

} // module 'Utils'
