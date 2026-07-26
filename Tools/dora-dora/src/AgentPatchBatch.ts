/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import type {
	AgentCheckpointItem,
	AgentSessionMessage,
	AgentSessionPatch,
	AgentSessionStep,
} from "./Service";

const updateMap = <T extends { id: number }>(items: T[]) => {
	return new Map(items.map((item) => [item.id, item]));
};

export interface AgentEntityCollection<T extends { id: number }> {
	byId: Map<number, T>;
	orderedIds: number[];
}

const createCollection = <T extends { id: number }>(
	items: T[],
	compare: (left: T, right: T) => number,
): AgentEntityCollection<T> => {
	const byId = updateMap(items);
	const orderedIds = [...byId.values()]
		.sort(compare)
		.map((item) => item.id);
	return { byId, orderedIds };
};

export const agentCollectionToArray = <T extends { id: number }>(
	collection: AgentEntityCollection<T>,
) => {
	return collection.orderedIds
		.map((id) => collection.byId.get(id))
		.filter((item): item is T => item !== undefined);
};

const messageCompare = (left: AgentSessionMessage, right: AgentSessionMessage) => {
	return left.id - right.id;
};

const stepCompare = (left: AgentSessionStep, right: AgentSessionStep) => {
	const taskDelta = (right.taskId ?? 0) - (left.taskId ?? 0);
	if (taskDelta !== 0) return taskDelta;
	return left.step - right.step;
};

const checkpointCompare = (left: AgentCheckpointItem, right: AgentCheckpointItem) => {
	const taskDelta = right.taskId - left.taskId;
	if (taskDelta !== 0) return taskDelta;
	return right.seq - left.seq;
};

const sameStructuredValue = (left: unknown, right: unknown) => {
	return left === right || JSON.stringify(left) === JSON.stringify(right);
};

export const createMessageCollection = (items: AgentSessionMessage[]) => {
	return createCollection(items, messageCompare);
};

export const createStepCollection = (items: AgentSessionStep[]) => {
	return createCollection(items, stepCompare);
};

export const createCheckpointCollection = (items: AgentCheckpointItem[]) => {
	return createCollection(items, checkpointCompare);
};

const reconcileCollection = <T extends { id: number }>(
	current: AgentEntityCollection<T>,
	items: T[],
	compare: (left: T, right: T) => number,
	isEqual: (left: T, right: T) => boolean,
): AgentEntityCollection<T> => {
	const next = createCollection(
		items.map((item) => {
			const previous = current.byId.get(item.id);
			return previous && isEqual(previous, item) ? previous : item;
		}),
		compare,
	);
	const sameOrder = next.orderedIds.length === current.orderedIds.length
		&& next.orderedIds.every((id, index) => id === current.orderedIds[index]);
	const sameEntities = sameOrder
		&& next.orderedIds.every((id) => next.byId.get(id) === current.byId.get(id));
	return sameEntities ? current : {
		byId: next.byId,
		orderedIds: sameOrder ? current.orderedIds : next.orderedIds,
	};
};

export const reconcileMessageCollection = (
	current: AgentEntityCollection<AgentSessionMessage>,
	items: AgentSessionMessage[],
) => {
	return reconcileCollection(current, items, messageCompare, (left, right) => {
		return left.sessionId === right.sessionId
			&& left.taskId === right.taskId
			&& left.role === right.role
			&& left.content === right.content
			&& left.displayContent === right.displayContent
			&& left.createdAt === right.createdAt
			&& left.updatedAt === right.updatedAt;
	});
};

export const reconcileStepCollection = (
	current: AgentEntityCollection<AgentSessionStep>,
	items: AgentSessionStep[],
) => {
	return reconcileCollection(current, items, stepCompare, (left, right) => {
		return left.sessionId === right.sessionId
			&& left.taskId === right.taskId
			&& left.step === right.step
			&& left.tool === right.tool
			&& left.status === right.status
			&& left.reason === right.reason
			&& left.reasoningContent === right.reasoningContent
			&& sameStructuredValue(left.params, right.params)
			&& sameStructuredValue(left.result, right.result)
			&& left.checkpointId === right.checkpointId
			&& left.checkpointSeq === right.checkpointSeq
			&& sameStructuredValue(left.files, right.files)
			&& left.createdAt === right.createdAt
			&& left.updatedAt === right.updatedAt;
	});
};

export const reconcileCheckpointCollection = (
	current: AgentEntityCollection<AgentCheckpointItem>,
	items: AgentCheckpointItem[],
) => {
	return reconcileCollection(current, items, checkpointCompare, (left, right) => {
		return left.taskId === right.taskId
			&& left.seq === right.seq
			&& left.status === right.status
			&& left.summary === right.summary
			&& left.toolName === right.toolName
			&& left.createdAt === right.createdAt;
	});
};

const applyCollectionPatches = <T extends { id: number }>(
	current: AgentEntityCollection<T>,
	updates: T[],
	removedIds: number[],
	compare: (left: T, right: T) => number,
): AgentEntityCollection<T> => {
	if (updates.length === 0 && removedIds.length === 0) return current;
	const byId = new Map(current.byId);
	let orderDirty = false;
	for (const id of removedIds) {
		if (byId.delete(id)) orderDirty = true;
	}
	for (const item of updates) {
		const previous = byId.get(item.id);
		byId.set(item.id, item);
		if (!previous || compare(previous, item) !== 0) orderDirty = true;
	}
	return {
		byId,
		orderedIds: orderDirty
			? [...byId.values()].sort(compare).map((item) => item.id)
			: current.orderedIds,
	};
};

export const applyMessageCollectionPatches = (
	current: AgentEntityCollection<AgentSessionMessage>,
	patches: AgentSessionPatch[],
) => {
	const updates: AgentSessionMessage[] = [];
	for (const patch of patches) {
		if (patch.message) updates.push(patch.message);
	}
	return applyCollectionPatches(current, updates, [], messageCompare);
};

export const applyStepCollectionPatches = (
	current: AgentEntityCollection<AgentSessionStep>,
	patches: AgentSessionPatch[],
) => {
	const updates: AgentSessionStep[] = [];
	const removedIds: number[] = [];
	for (const patch of patches) {
		if (patch.step) updates.push(patch.step);
		removedIds.push(...(patch.removedStepIds ?? []));
	}
	return applyCollectionPatches(current, updates, removedIds, stepCompare);
};

export const applyCheckpointCollectionPatches = (
	current: AgentEntityCollection<AgentCheckpointItem>,
	patches: AgentSessionPatch[],
) => {
	let collection = current;
	let updates: AgentCheckpointItem[] = [];
	for (const patch of patches) {
		if (patch.checkpoints) {
			collection = createCheckpointCollection(patch.checkpoints);
			updates = [];
		}
		if (patch.checkpoint) updates.push(patch.checkpoint);
	}
	return applyCollectionPatches(collection, updates, [], checkpointCompare);
};

export const applyMessagePatches = (
	current: AgentSessionMessage[],
	patches: AgentSessionPatch[],
) => {
	return agentCollectionToArray(
		applyMessageCollectionPatches(createMessageCollection(current), patches),
	);
};

export const applyStepPatches = (
	current: AgentSessionStep[],
	patches: AgentSessionPatch[],
) => {
	return agentCollectionToArray(
		applyStepCollectionPatches(createStepCollection(current), patches),
	);
};

export const applyCheckpointPatches = (
	current: AgentCheckpointItem[],
	patches: AgentSessionPatch[],
) => {
	return agentCollectionToArray(
		applyCheckpointCollectionPatches(createCheckpointCollection(current), patches),
	);
};

export const isImmediateAgentPatch = (patch: AgentSessionPatch) => {
	return patch.sessionDeleted === true
		|| "pendingQuestionnaire" in patch
		|| (patch.session !== undefined && patch.session.currentTaskStatus !== "RUNNING");
};
