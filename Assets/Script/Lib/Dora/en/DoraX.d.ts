/// <reference path="jsx.d.ts" />

declare module "DoraX" {

import type * as Dora from 'Dora';

/**
 * Represents the React namespace.
 */
export namespace React {
	/**
	 * Represents a React element.
	 */
	export interface Element {
		type: string;
		props?: AnyTable;
		children: Element[];
	}

	export abstract class Component<T> {
		constructor(props: T);
		props: T;
		abstract render(): React.Element;
	}

	export function Fragment(): void;

	/**
	 * Creates a React element.
	 * @param type The type of the element.
	 * @param props The properties of the element.
	 * @param children The child elements of the element.
	 * @returns The created React element.
	 */
	export function createElement(type: any, props: any, ...children: any[]): Element | Element[];
}

/**
 * Converts a React element or an array of React elements to a Dora node.
 * @param enode The React element or array of React elements to convert.
 * @returns The converted Dora node.
 */
export function toNode(this: void, enode: React.Element | React.Element[]): Dora.Node.Type | undefined;

export type RenderInput = React.Element | React.Element[] | (() => React.Element | React.Element[]);

/**
 * A mounted dynamic TSX root that updates Dora nodes by diffing new element trees.
 */
export class Root {
	constructor(parent: Dora.Node.Type);
	render(enode: RenderInput): void;
	update(): void;
	unmount(): void;
}

/**
 * Creates a dynamic TSX root under the specified Dora node.
 * @param parent The Dora node that owns rendered children.
 * @returns The created dynamic root.
 */
export function createRoot(this: void, parent: Dora.Node.Type): Root;

/**
 * A small reactive value. Assigning `value` schedules all mounted dynamic roots to update.
 */
export class Signal<T> {
	constructor(value: T);
	value: T;
}

/**
 * Creates a reactive value for dynamic TSX rendering.
 * @param value The initial value.
 * @returns The created signal.
 */
export function signal<T>(this: void, value: T): Signal<T>;

/**
 * Converts a React element to a Dora action definition.
 * @param enode The React element to convert.
 * @returns The converted Dora action definition.
 */
export function toAction(this: void, enode: React.Element): Dora.ActionDef.Type;

/**
 * Creates a ref object that can be used to reference a value.
 * @param item The initial value of the ref.
 * @returns The created ref object.
 */
export function useRef<T>(this: void, item?: T): JSX.Ref<T>;

/**
 * Asynchronously preloads the resource files used by the specified node.
 * @param enode The node to preload.
 * @param handler The callback function used to notify the progress change.
 */
export function preloadAsync(this: void, enode: React.Element | React.Element[], handler?: (this: void, progress: number) => void): void;

} // module "DoraX"
