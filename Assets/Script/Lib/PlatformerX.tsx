/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { React } from 'DoraX';
import * as P from 'Platformer';

export namespace BehaviorTree {
	export const enum NodeType {
		Selector = 'BTSelector',
		Sequence = 'BTSequence',
		Condition = 'BTCondition',
		Match = 'BTMatch',
		Action = 'BTAction',
		Command = 'BTCommand',
		Wait = 'BTWait',
		Countdown = 'BTCountdown',
		Timeout = 'BTTimeout',
		Repeat = 'BTRepeat',
		Retry = 'BTRetry',
	}

	export class Leaf implements React.Element {
		private constructor() {}
		type!: string;
		props: any;
		children!: React.Element[];
	}

	export interface NodeProps {
		children?: Leaf | Leaf[];
	}

	export function Selector(props: NodeProps): Leaf {
		return <custom-element name={NodeType.Selector} data={props}/>;
	}

	export function Sequence(props: NodeProps): Leaf {
		return <custom-element name={NodeType.Sequence} data={props}/>;
	}

	export interface ConditionProps {
		desc: string;
		onCheck(this: void, blackboard: P.Behavior.Blackboard): boolean;
	}

	export function Condition(props: ConditionProps): Leaf {
		return <custom-element name={NodeType.Condition} data={props}/>;
	}

	export interface MatchProps {
		desc: string;
		onCheck(this: void, blackboard: P.Behavior.Blackboard): boolean;
		children?: Leaf | Leaf[];
	}

	export function Match(props: MatchProps): Leaf {
		return <custom-element name={NodeType.Match} data={props}/>;
	}

	export interface ActionProps {
		name: string;
	}

	export function Action(props: ActionProps): Leaf {
		return <custom-element name={NodeType.Action} data={props}/>;
	}

	export function Command(props: ActionProps): Leaf {
		return <custom-element name={NodeType.Command} data={props}/>;
	}

	export interface WaitProps {
		time: number;
	}

	export function Wait(props: WaitProps): Leaf {
		return <custom-element name={NodeType.Wait} data={props}/>;
	}

	export interface TimerProps {
		time: number;
		children: Leaf;
	}

	export function Countdown(props: TimerProps): Leaf {
		return <custom-element name={NodeType.Countdown} data={props}/>;
	}

	export function Timeout(props: TimerProps): Leaf {
		return <custom-element name={NodeType.Timeout} data={props}/>;
	}

	export interface CountProps {
		times?: number;
		children: Leaf;
	}

	export function Repeat(props: CountProps): Leaf {
		return <custom-element name={NodeType.Repeat} data={props}/>;
	}

	export function Retry(props: CountProps): Leaf {
		return <custom-element name={NodeType.Retry} data={props}/>;
	}
}

export namespace DecisionTree {
	export const enum NodeType {
		Selector = 'DTSelector',
		Sequence = 'DTSequence',
		Condition = 'DTCondition',
		Match = 'DTMatch',
		Action = 'DTAction',
		Accept = 'DTAccept',
		Reject = 'DTReject',
		Behavior = 'DTBehavior',
	}

	export class Leaf implements React.Element {
		private constructor() {}
		type!: string;
		props: any;
		children!: React.Element[];
	}

	export interface NodeProps {
		children?: Leaf | Leaf[];
	}

	export function Selector(props: NodeProps): Leaf {
		return <custom-element name={NodeType.Selector} data={props}/>;
	}

	export function Sequence(props: NodeProps): Leaf {
		return <custom-element name={NodeType.Sequence} data={props}/>;
	}

	export interface ConditionProps {
		desc: string;
		onCheck(this: void, unit: P.Unit.Type): boolean;
	}

	export function Condition(props: ConditionProps): Leaf {
		return <custom-element name={NodeType.Condition} data={props}/>;
	}

	export interface MatchProps {
		desc: string;
		onCheck(this: void, unit: P.Unit.Type): boolean;
		children?: Leaf | Leaf[];
	}

	export function Match(props: MatchProps): Leaf {
		return <custom-element name={NodeType.Match} data={props}/>;
	}

	export interface ActionProps {
		name: string | ((this: void, self: P.Unit.Type) => string);
	}

	export function Action(props: ActionProps): Leaf {
		return <custom-element name={NodeType.Action} data={props}/>;
	}

	export function Accept(): Leaf {
		return <custom-element name={NodeType.Accept} data={undefined}/>;
	}

	export function Reject(): Leaf {
		return <custom-element name={NodeType.Reject} data={undefined}/>;
	}

	export interface BehaviorProps extends BehaviorTree.NodeProps {
		name: string;
	}

	export function Behavior(props: BehaviorProps): Leaf {
		return <custom-element name={NodeType.Behavior} data={props}/>;
	}
}

function Warn(this: void, msg: string) {
	print(`[Dora Warning] ${msg}`);
}

function visitDTree(this: void, treeStack: P.Decision.Leaf[], node: JSX.CustomElement): boolean {
	if (type(node) !== 'table') {
		return false;
	}
	switch (node.name as DecisionTree.NodeType) {
		case DecisionTree.NodeType.Selector: {
			const props = node.data as DecisionTree.NodeProps;
			const children = props.children as DecisionTree.Leaf[] | undefined;
			if (children && children.length > 0) {
				const stack: P.Decision.Leaf[] = [];
				for (let i = 0; i < children.length; i++) {
					if (!visitDTree(stack, children[i].props)) {
						Warn(`unsupported DecisionTree node with name ${children[i].props.name}`);
					}
				}
				if (stack.length > 0) {
					treeStack.push(P.Decision.Sel(stack));
				}
			}
			break;
		}
		case DecisionTree.NodeType.Sequence: {
			const props = node.data as DecisionTree.NodeProps;
			const children = props.children as DecisionTree.Leaf[] | undefined;
			if (children && children.length > 0) {
				const stack: P.Decision.Leaf[] = [];
				for (let i = 0; i < children.length; i++) {
					if (!visitDTree(stack, children[i].props)) {
						Warn(`unsupported DecisionTree node with name ${children[i].props.name}`);
					}
				}
				if (stack.length > 0) {
					treeStack.push(P.Decision.Seq(stack));
				}
			}
			break;
		}
		case DecisionTree.NodeType.Condition: {
			const props = node.data as DecisionTree.ConditionProps;
			treeStack.push(P.Decision.Con(props.desc, props.onCheck));
			break;
		}
		case DecisionTree.NodeType.Match: {
			const props = node.data as DecisionTree.MatchProps;
			const children = props.children as DecisionTree.Leaf[] | undefined;
			if (children && children.length > 0) {
				const stack: P.Decision.Leaf[] = [];
				for (let i = 0; i < children.length; i++) {
					if (!visitDTree(stack, children[i].props)) {
						Warn(`unsupported DecisionTree node with name ${children[i].props.name}`);
					}
				}
				if (stack.length > 0) {
					treeStack.push(
						P.Decision.Seq(
							[P.Decision.Con(props.desc, props.onCheck), ...stack]
						)
					);
					break;
				}
			}
			treeStack.push(P.Decision.Con(props.desc, props.onCheck));
			break;
		}
		case DecisionTree.NodeType.Action: {
			const props = node.data as DecisionTree.ActionProps;
			if (typeof props.name === 'string') {
				treeStack.push(P.Decision.Act(props.name));
			} else {
				treeStack.push(P.Decision.Act(props.name));
			}
			break;
		}
		case DecisionTree.NodeType.Accept: {
			treeStack.push(P.Decision.Accept());
			break;
		}
		case DecisionTree.NodeType.Reject: {
			treeStack.push(P.Decision.Reject());
			break;
		}
		case DecisionTree.NodeType.Behavior: {
			const props = node.data as DecisionTree.BehaviorProps;
			const children = props.children as BehaviorTree.Leaf[] | undefined;
			if (children && children.length >= 1) {
				const stack: P.Behavior.Leaf[] = [];
				if (visitBTree(stack, children[0].props)) {
					treeStack.push(P.Decision.Behave(props.name, stack[0]));
				} else {
					Warn("expects only one BehaviorTree child for DecisionTree.Behavior");
				}
			} else {
				Warn("expects only one BehaviorTree child for DecisionTree.Behavior");
			}
			break;
		}
		default:
			return false;
	}
	return true;
}

function visitBTree(this: void, treeStack: P.Behavior.Leaf[], node: JSX.CustomElement): boolean {
	if (type(node) !== 'table') {
		return false;
	}
	switch (node.name as BehaviorTree.NodeType) {
		case BehaviorTree.NodeType.Selector: {
			const props = node.data as BehaviorTree.NodeProps;
			const children = props.children as BehaviorTree.Leaf[] | undefined;
			if (children && children.length > 0) {
				const stack: P.Behavior.Leaf[] = [];
				for (let i = 0; i < children.length; i++) {
					if (!visitBTree(stack, children[i].props)) {
						Warn(`unsupported BehaviorTree node with name ${children[i].props.name}`);
					}
				}
				if (stack.length > 0) {
					treeStack.push(P.Behavior.Sel(stack));
				}
			}
			break;
		}
		case BehaviorTree.NodeType.Sequence: {
			const props = node.data as BehaviorTree.NodeProps;
			const children = props.children as BehaviorTree.Leaf[] | undefined;
			if (children && children.length > 0) {
				const stack: P.Behavior.Leaf[] = [];
				for (let i = 0; i < children.length; i++) {
					if (!visitBTree(stack, children[i].props)) {
						Warn(`unsupported BehaviorTree node with name ${children[i].props.name}`);
					}
				}
				if (stack.length > 0) {
					treeStack.push(P.Behavior.Seq(stack));
				}
			}
			break;
		}
		case BehaviorTree.NodeType.Condition: {
			const props = node.data as BehaviorTree.ConditionProps;
			treeStack.push(P.Behavior.Con(props.desc, props.onCheck));
			break;
		}
		case BehaviorTree.NodeType.Match: {
			const props = node.data as BehaviorTree.MatchProps;
			const children = props.children as BehaviorTree.Leaf[] | undefined;
			if (children && children.length > 0) {
				const stack: P.Behavior.Leaf[] = [];
				for (let i = 0; i < children.length; i++) {
					if (!visitBTree(stack, children[i].props)) {
						Warn(`unsupported BehaviorTree node with name ${children[i].props.name}`);
					}
				}
				if (stack.length > 0) {
					treeStack.push(
						P.Behavior.Seq(
							[P.Behavior.Con(props.desc, props.onCheck), ...stack]
						)
					);
					break;
				}
			}
			treeStack.push(P.Behavior.Con(props.desc, props.onCheck));
			break;
		}
		case BehaviorTree.NodeType.Action: {
			const props = node.data as BehaviorTree.ActionProps;
			treeStack.push(P.Behavior.Act(props.name));
			break;
		}
		case BehaviorTree.NodeType.Command: {
			const props = node.data as BehaviorTree.ActionProps;
			treeStack.push(P.Behavior.Command(props.name));
			break;
		}
		case BehaviorTree.NodeType.Wait: {
			const props = node.data as BehaviorTree.WaitProps;
			treeStack.push(P.Behavior.Wait(props.time));
			break;
		}
		case BehaviorTree.NodeType.Countdown: {
			const props = node.data as BehaviorTree.TimerProps;
			const children = props.children as unknown as BehaviorTree.Leaf[] | undefined;
			if (children && children.length >= 1) {
				const stack: JSX.CustomElement[] = [];
				if (visitBTree(stack, children[0].props)) {
					treeStack.push(P.Behavior.Countdown(props.time, stack[0]));
				} else {
					Warn("expects only one BehaviorTree child for BehaviorTree.Countdown");
				}
			} else {
				Warn("expects only one BehaviorTree child for BehaviorTree.Countdown");
			}
			break;
		}
		case BehaviorTree.NodeType.Timeout: {
			const props = node.data as BehaviorTree.TimerProps;
			const children = props.children as unknown as BehaviorTree.Leaf[] | undefined;
			if (children && children.length >= 1) {
				const stack: JSX.CustomElement[] = [];
				if (visitBTree(stack, children[0].props)) {
					treeStack.push(P.Behavior.Timeout(props.time, stack[0]));
				} else {
					Warn("expects only one BehaviorTree child for BehaviorTree.Timeout");
				}
			} else {
				Warn("expects only one BehaviorTree child for BehaviorTree.Timeout");
			}
			break;
		}
		case BehaviorTree.NodeType.Repeat: {
			const props = node.data as BehaviorTree.CountProps;
			const children = props.children as unknown as BehaviorTree.Leaf[] | undefined;
			if (children && children.length >= 1) {
				const stack: JSX.CustomElement[] = [];
				if (visitBTree(stack, children[0].props)) {
					if (props.times !== undefined) {
						treeStack.push(P.Behavior.Repeat(props.times, stack[0]));
					} else {
						treeStack.push(P.Behavior.Repeat(stack[0]));
					}
				} else {
					Warn("expects only one BehaviorTree child for BehaviorTree.Repeat");
				}
			} else {
				Warn("expects only one BehaviorTree child for BehaviorTree.Repeat");
			}
			break;
		}
		case BehaviorTree.NodeType.Retry: {
			const props = node.data as BehaviorTree.CountProps;
			const children = props.children as unknown as BehaviorTree.Leaf[] | undefined;
			if (children && children.length >= 1) {
				const stack: JSX.CustomElement[] = [];
				if (visitBTree(stack, children[0].props)) {
					if (props.times !== undefined) {
						treeStack.push(P.Behavior.Retry(props.times, stack[0]));
					} else {
						treeStack.push(P.Behavior.Retry(stack[0]));
					}
				} else {
					Warn("expects only one BehaviorTree child for BehaviorTree.Retry");
				}
			} else {
				Warn("expects only one BehaviorTree child for BehaviorTree.Retry");
			}
			break;
		}
		default:
			return false;
	}
	return true;
}

export function toAI(this: void, node: DecisionTree.Leaf): P.Decision.Leaf | null {
	if (type(node) !== 'table') {
		return null;
	}
	const treeStack: P.Decision.Leaf[] = [];
	if (visitDTree(treeStack, node.props) && treeStack.length > 0) {
		return treeStack[0];
	}
	return null;
}
