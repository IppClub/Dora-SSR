type NonIterableObject = Partial<Record<string, unknown>> & {
	[Symbol.iterator]?: never;
};
type Action = string;
declare class BaseNode<S = unknown, P extends NonIterableObject = NonIterableObject> {
	protected _params: P;
	protected _successors: Map<Action, BaseNode>;
	protected _exec(prepRes: unknown): Promise<unknown>;
	prep(shared: S): Promise<unknown>;
	exec(prepRes: unknown): Promise<unknown>;
	post(shared: S, prepRes: unknown, execRes: unknown): Promise<Action | undefined>;
	_run(shared: S): Promise<Action | undefined>;
	run(shared: S): Promise<Action | undefined>;
	setParams(params: P): this;
	next<T extends BaseNode>(node: T): T;
	on(action: Action, node: BaseNode): this;
	getNextNode(action?: Action): BaseNode | undefined;
	clone(): this;
}
declare class Node<S = unknown, P extends NonIterableObject = NonIterableObject> extends BaseNode<S, P> {
	maxRetries: number;
	wait: number;
	currentRetry: number;
	constructor(maxRetries?: number, wait?: number);
	execFallback(prepRes: unknown, error: Error): void;
	_exec(prepRes: unknown): Promise<unknown>;
}
declare class BatchNode<S = unknown, P extends NonIterableObject = NonIterableObject> extends Node<S, P> {
	_exec(items: unknown[]): Promise<unknown[]>;
}
declare class ParallelBatchNode<S = unknown, P extends NonIterableObject = NonIterableObject> extends Node<S, P> {
	_exec(items: unknown[]): Promise<unknown[]>;
}
declare class Flow<S = unknown, P extends NonIterableObject = NonIterableObject> extends BaseNode<S, P> {
	start: BaseNode;
	constructor(start: BaseNode);
	protected _orchestrate(shared: S, params?: P): Promise<void>;
	_run(shared: S): Promise<Action | undefined>;
	exec(prepRes: unknown): Promise<unknown>;
}
declare class BatchFlow<S = unknown, P extends NonIterableObject = NonIterableObject, NP extends NonIterableObject[] = NonIterableObject[]> extends Flow<S, P> {
	_run(shared: S): Promise<Action | undefined>;
	prep(shared: S): Promise<NP>;
}
declare class ParallelBatchFlow<S = unknown, P extends NonIterableObject = NonIterableObject, NP extends NonIterableObject[] = NonIterableObject[]> extends BatchFlow<S, P, NP> {
	_run(shared: S): Promise<Action | undefined>;
}
export { BaseNode, Node, BatchNode, ParallelBatchNode, Flow, BatchFlow, ParallelBatchFlow };
