import { Vec2Type as Vec2 } from "dora";

declare module 'Utils' {

interface Struct {
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
	__notify(event: RecordEvent, key: string, value: any): void;
	__notify(event: ArrayEvent, index: number, value: any): void;
	[key: string | number]: any;
}

export const enum RecordEvent {
	Modified = "Modified",
	Updated = "Updated"
}

export const enum ArrayEvent {
	Added = "Added",
	Removed = "Removed",
	Changed = "Changed",
	Updated = "Updated"
}

interface StructClass {
	(this: void, values?: Record<string, any>): Struct;
}

interface StructModule {
	[name: string]: StructModule;
	(this: void, name: string, ...args: Array<string | string[]>): StructClass;
}

type StructHelper = {
	load(input: string | Record<string, any>, name?: string): Struct;
	loadfile(filename: string): Struct;
	clear(): void;
	has(name: string): boolean;
} & {
	[name: string]: StructClass
};

export const Struct: StructHelper;
export function Set(this: void, list: any[]): Record<any, boolean>;
export function CompareTable(this: void, oldTable: [any], newTable: [any]): [added: [any], deleted: [any]];
export function Round(this: void, val: number | Vec2): number | Vec2;
export function IsValidPath(this: void, path: string): boolean;
export function GSplit(this: void, text: string, pattern: string, plain: boolean): () => string;

} // module 'Utils'