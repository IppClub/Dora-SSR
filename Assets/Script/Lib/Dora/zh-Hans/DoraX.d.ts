/// <reference path="jsx.d.ts" />

declare module "DoraX" {

import type * as Dora from 'Dora';

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

	export abstract class Component<T> {
		constructor(props: T);
		props: T;
		abstract render(): React.Element;
	}

	export function Fragment(): void;

	/**
	 * 创建一个 React 元素。
	 * @param type 元素类型。
	 * @param props 元素属性。
	 * @param children 子元素。
	 * @returns 创建的 React 元素。
	 */
	export function createElement(type: any, props: any, ...children: any[]): Element | Element[];
}

/**
 * 将 React 元素转换为 Dora 节点。
 * @param enode 要转换的 React 元素。
 * @returns 转换后的 Dora 节点。
 */
export function toNode(this: void, enode: React.Element | React.Element[]): Dora.Node.Type | null;

/**
 * 将 React 元素转换为 Dora 动作定义。
 * @param enode 要转换的 React 元素。
 * @returns 转换后的 Dora 动作定义。
 */
export function toAction(this: void, enode: React.Element): Dora.ActionDef.Type;

/**
 * 创建一个用于引用的 Ref 对象。
 * @param item 初始值。
 * @returns 创建的 Ref 对象。
 */
export function useRef<T>(this: void, item?: T): JSX.Ref<T>;

/**
 * 异步地预加载指定的节点使用的资源文件。
 * @param enode 要预加载的节点。
 * @param handler 用于通知进度变化的回调函数。
 */
export function preloadAsync(this: void, enode: React.Element | React.Element[], handler?: (this: void, progress: number) => void): void;

} // module "DoraX"