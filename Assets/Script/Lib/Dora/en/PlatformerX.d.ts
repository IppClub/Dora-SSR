declare module 'PlatformerX' {

import { React } from 'DoraX';
import * as P from 'Platformer';

export namespace BehaviorTree {
	export class Leaf implements React.Element {
		private constructor();
		type: string;
		props: any;
		children: React.Element[];
	}

	export interface NodeProps {
		children?: Leaf | Leaf[];
	}

	export function Selector(props: NodeProps): Leaf;

	export function Sequence(props: NodeProps): Leaf;

	export interface ConditionProps {
		desc: string;
		onCheck(this: void, blackboard: P.Behavior.Blackboard): boolean;
	}

	export function Condition(props: ConditionProps): Leaf;

	export interface MatchProps {
		desc: string;
		onCheck(this: void, unit: P.Unit.Type): boolean;
		children?: Leaf | Leaf[];
	}

	export function Match(props: MatchProps): Leaf;

	export interface ActionProps {
		name: string;
	}

	export function Action(props: ActionProps): Leaf;

	export function Command(props: ActionProps): Leaf;

	export interface WaitProps {
		time: number;
	}

	export function Wait(props: WaitProps): Leaf;

	export interface TimerProps {
		time: number;
		children: BehaviorTree.Leaf;
	}

	export function Countdown(props: TimerProps): Leaf;

	export function Timeout(props: TimerProps): Leaf;

	export interface CountProps {
		times?: number;
		children: BehaviorTree.Leaf;
	}

	export function Repeat(props: CountProps): Leaf;

	export function Retry(props: CountProps): Leaf;
}

export namespace DecisionTree {
	export class Leaf implements React.Element {
		private constructor();
		type: string;
		props: any;
		children: React.Element[];
	}

	export interface NodeProps {
		children?: Leaf | Leaf[];
	}

	export function Selector(props: NodeProps): Leaf;

	export function Sequence(props: NodeProps): Leaf;

	export interface ConditionProps {
		desc: string;
		onCheck(this: void, unit: P.Unit.Type): boolean;
	}

	export function Condition(props: ConditionProps): Leaf;

	export interface MatchProps {
		desc: string;
		onCheck(this: void, unit: P.Unit.Type): boolean;
		children?: Leaf | Leaf[];
	}

	export function Match(props: MatchProps): Leaf;

	export interface ActionProps {
		name: string | ((this: void, self: P.Unit.Type) => string);
	}

	export function Action(props: ActionProps): Leaf;

	export function Accept(): Leaf;

	export function Reject(): Leaf;

	export interface BehaviorProps {
		name: string;
		children: BehaviorTree.Leaf;
	}

	export function Behavior(props: BehaviorProps): Leaf;
}

export function toAI(this: void, node: DecisionTree.Leaf): P.Decision.Leaf | null;

} // module 'PlatformerX'
