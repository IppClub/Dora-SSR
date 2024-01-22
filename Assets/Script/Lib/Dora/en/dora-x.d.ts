/// <reference path="jsx.d.ts" />

/**
 * Represents the React namespace.
 */
import type * as dora from 'dora';

export namespace React {
	/**
	 * Represents a React element.
	 */
	export interface Element {
		type: string;
		props?: any;
		children: Element[];
	}

	/**
	 * Creates a React element.
	 * @param type - The type of the element.
	 * @param props - The properties of the element.
	 * @param children - The child elements of the element.
	 * @returns The created React element.
	 */
	export function createElement(type: any, props?: any, ...children: any[]): Element | Element[];
}

/**
 * Converts a React element or an array of React elements to a Dora node.
 * @param enode - The React element or array of React elements to convert.
 * @returns The converted Dora node.
 */
export function toNode(this: void, enode: React.Element | React.Element[]): dora.Node.Type | null;

/**
 * Creates a ref object that can be used to reference a value.
 * @param item - The initial value of the ref.
 * @returns The created ref object.
 */
export function useRef<T>(this: void, item?: T): JSX.Ref<T>;
