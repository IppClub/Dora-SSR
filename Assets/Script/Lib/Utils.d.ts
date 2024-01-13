import { Vec2 } from "dora";
type Vec2 = Vec2.Type;

declare module 'Utils' {

type Struct<T = {}> = {
	set(index: number, item: any): void;
	get(index: number): any;
	insert(item: any): void;
	/** index is 1 based */
	insert(index: number, item: any): void;
	remove(item: any): any;
	/** index is 1 based */
	removeAt(index: number): boolean;
	clear(): void;
	each(handler: (value: any, index: number) => boolean): boolean;
	eachAttr(handler: (key: string, value: any) => void): void;
	contains(item: any): boolean;
	count(): number;
	sort(comparer: (a: any, b: any) => boolean): void;
	__notify(event: RecordEvent | ArrayEvent | StructEvent, key?: string | number, value?: any): void;
} & T;

export const enum StructEvent {
	Updated = "Updated"
}

export const enum RecordEvent {
	Modified = "Modified",
}

export const enum ArrayEvent {
	Added = "Added",
	Removed = "Removed",
	Changed = "Changed",
	Updated = "Updated"
}

interface StructClass<T> {
	(this: void, values?: T): Struct<T>;
	(this: void, ...items: any[]): Struct<T>;
}

interface StructModule {
	[name: string]: StructModule;
	<T = {}>(this: void, ...fieldNames: string[]): StructClass<T>;
	<T = {}>(this: void, fieldNames: string[]): StructClass<T>;
}

type StructHelper = {
	load<T = {}>(input: string | Record<string, any>, name?: string): Struct<T>;
	loadfile<T = {}>(filename: string): Struct<T>;
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