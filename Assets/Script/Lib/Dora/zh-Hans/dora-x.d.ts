/// <reference path="jsx.d.ts" />
import type * as dora from 'dora';

/**
 * 命名空间 React 包含了与 React 相关的类型和函数。
 */
export namespace React {
	/**
	 * 表示一个 React 元素。
	 */
	export interface Element {
		type: string;
		props?: any;
		children: Element[];
	}

	/**
	 * 创建一个 React 元素。
	 * @param type 元素类型。
	 * @param props 元素属性。
	 * @param children 子元素。
	 * @returns 创建的 React 元素。
	 */
	export function createElement(type: any, props?: any, ...children: any[]): Element | Element[];
}

/**
 * 将 React 元素转换为 dora 节点。
 * @param enode 要转换的 React 元素。
 * @returns 转换后的 dora 节点。
 */
export function toNode(this: void, enode: React.Element | React.Element[]): dora.Node.Type | null;

/**
 * 创建一个用于引用的 Ref 对象。
 * @param item 初始值。
 * @returns 创建的 Ref 对象。
 */
export function useRef<T>(this: void, item?: T): JSX.Ref<T>;
