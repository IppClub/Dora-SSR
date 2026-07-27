// Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>
// Licensed under the MIT License.

export interface AgentAutoScrollInput {
	followingOutput: boolean;
	previousScrollTop: number;
	previousScrollHeight: number;
	scrollTop: number;
	scrollHeight: number;
	distanceToBottom: number;
	bottomThreshold?: number;
}

export interface AgentAutoScrollState {
	followingOutput: boolean;
	atBottom: boolean;
}

export function resolveAgentAutoScrollState(input: AgentAutoScrollInput): AgentAutoScrollState {
	const threshold = input.bottomThreshold ?? 8;
	const atBottom = input.distanceToBottom <= threshold;
	const contentShrank = input.scrollHeight < input.previousScrollHeight - 1;
	const userMovedUp = !contentShrank && input.scrollTop < input.previousScrollTop - 1;
	return {
		atBottom,
		followingOutput: atBottom || (input.followingOutput && !userMovedUp),
	};
}
