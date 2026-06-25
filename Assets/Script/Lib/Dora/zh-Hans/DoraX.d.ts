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
export function toNode(this: void, enode: React.Element | React.Element[]): Dora.Node.Type | undefined;

export type RenderInput = React.Element | React.Element[] | (() => React.Element | React.Element[]);

/**
 * 已挂载的动态 TSX 根节点，通过 diff 新的元素树来更新 Dora 节点。
 */
export class Root {
	constructor(parent: Dora.Node.Type);
	render(enode: RenderInput): void;
	update(): void;
	unmount(): void;
}

/**
 * 在指定 Dora 节点下创建动态 TSX 根节点。
 * @param parent 持有渲染子节点的 Dora 节点。
 * @returns 创建的动态根节点。
 */
export function createRoot(this: void, parent: Dora.Node.Type): Root;

/**
 * 一个小型响应式值。给 `value` 赋值会调度读取过该 signal 的动态根节点更新。
 */
export class Signal<T> {
	constructor(value: T);
	value: T;
}

/**
 * 创建用于动态 TSX 渲染的响应式值。
 * @param value 初始值。
 * @returns 创建的 signal。
 */
export function signal<T>(this: void, value: T): Signal<T>;

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
export function reference<T>(this: void, item?: T): JSX.Ref<T>;

/**
 * 创建组件本地 Ref 对象。只能在函数组件内调用。
 * @param item 初始值。
 * @returns 创建的 Ref 对象。
 */
export function useRef<T>(this: void, item?: T): JSX.Ref<T>;

/**
 * 创建组件本地 signal。只能在函数组件内调用。
 * @param value signal 初始值。
 * @returns 创建或复用的 signal。
 */
export function useSignal<T>(this: void, value: T): Signal<T>;

/**
 * 为当前函数组件记忆一个值，直到依赖列表发生变化。只能在函数组件内调用。
 * @param factory 用于创建记忆值的函数。
 * @param deps 按引用比较的依赖列表。
 * @returns 记忆后的值。
 */
export function useMemo<T>(this: void, factory: (this: void) => T, deps?: unknown[]): T;

/**
 * 为当前函数组件记忆一个回调，直到依赖列表发生变化。只能在函数组件内调用。
 * @param callback 要记忆的回调。
 * @param deps 按引用比较的依赖列表。
 * @returns 记忆后的回调。
 */
export function useCallback<T>(this: void, callback: T, deps?: unknown[]): T;

/**
 * 异步地预加载指定的节点使用的资源文件。
 * @param enode 要预加载的节点。
 * @param handler 用于通知进度变化的回调函数。
 */
export function preloadAsync(this: void, enode: React.Element | React.Element[], handler?: (this: void, progress: number) => void): void;

} // module "DoraX"
