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
		props?: any;
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
export function toNode(this: void, enode: React.Element | React.Element[]): Dora.Node.Type | null;

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