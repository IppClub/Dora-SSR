import type {ActionDocument, ActionNode, ActionTransform} from "./ActionDocument";

export type ActionViewport = {
	pan: {x: number; y: number};
	zoom: number;
};

export const defaultActionViewport = (): ActionViewport => ({
	pan: {x: 0, y: 0},
	zoom: 1,
});

const cloneTransform = (transform: ActionTransform): ActionTransform => ({
	position: {...transform.position},
	scale: {...transform.scale},
	skew: {...transform.skew},
	rotation: transform.rotation,
	opacity: transform.opacity,
	anchor: {...transform.anchor},
});

export const cloneActionNode = (node: ActionNode): ActionNode => ({
	...node,
	transform: cloneTransform(node.transform),
	hiddenInLooks: [...node.hiddenInLooks],
	tracks: {...node.tracks},
	children: node.children.map(cloneActionNode),
});

export const cloneActionDocument = (document: ActionDocument): ActionDocument => ({
	...document,
	size: {...document.size},
	root: cloneActionNode(document.root),
	animations: [...document.animations],
	looks: [...document.looks],
	keyPoints: document.keyPoints.map((point) => ({...point})),
	legacy: {...document.legacy},
});

export const countActionNodes = (node: ActionNode): number => {
	return 1 + node.children.reduce((sum, child) => sum + countActionNodes(child), 0);
};

export const findActionNode = (node: ActionNode, id: string): ActionNode | null => {
	if (node.id === id) return node;
	for (const child of node.children) {
		const found = findActionNode(child, id);
		if (found) return found;
	}
	return null;
};

export const findActionNodeParent = (node: ActionNode, id: string): ActionNode | null => {
	for (const child of node.children) {
		if (child.id === id) return node;
		const found = findActionNodeParent(child, id);
		if (found) return found;
	}
	return null;
};

export const updateActionNode = (node: ActionNode, id: string, updater: (node: ActionNode) => ActionNode): ActionNode => {
	if (node.id === id) return updater(node);
	return {
		...node,
		children: node.children.map((child) => updateActionNode(child, id, updater)),
	};
};

export const createActionNode = (id: string, name: string): ActionNode => ({
	id,
	name,
	clip: "",
	front: true,
	transform: {
		position: {x: 0, y: 0},
		scale: {x: 1, y: 1},
		skew: {x: 0, y: 0},
		rotation: 0,
		opacity: 1,
		anchor: {x: 0.5, y: 0.5},
	},
	hiddenInLooks: [],
	tracks: {},
	children: [],
});

export const addChildActionNode = (document: ActionDocument, parentId: string): ActionDocument => {
	const next = cloneActionDocument(document);
	const parent = findActionNode(next.root, parentId) ?? next.root;
	const id = `${parent.id}.${Date.now().toString(36)}.${parent.children.length}`;
	parent.children.push(createActionNode(id, `Node${countActionNodes(next.root)}`));
	return next;
};

export const removeActionNode = (document: ActionDocument, nodeId: string): ActionDocument => {
	if (nodeId === document.root.id) return document;
	const next = cloneActionDocument(document);
	const parent = findActionNodeParent(next.root, nodeId);
	if (!parent) return document;
	parent.children = parent.children.filter((child) => child.id !== nodeId);
	return next;
};

export const reorderActionNode = (document: ActionDocument, nodeId: string, direction: -1 | 1): ActionDocument => {
	if (nodeId === document.root.id) return document;
	const next = cloneActionDocument(document);
	const parent = findActionNodeParent(next.root, nodeId);
	if (!parent) return document;
	const index = parent.children.findIndex((child) => child.id === nodeId);
	const target = index + direction;
	if (index < 0 || target < 0 || target >= parent.children.length) return document;
	const moving = parent.children[index];
	parent.children[index] = parent.children[target];
	parent.children[target] = moving;
	return next;
};

export const moveActionNodeToParent = (document: ActionDocument, nodeId: string, parentId: string): ActionDocument => {
	if (nodeId === document.root.id || nodeId === parentId) return document;
	const next = cloneActionDocument(document);
	const sourceParent = findActionNodeParent(next.root, nodeId);
	const targetParent = findActionNode(next.root, parentId);
	const moving = findActionNode(next.root, nodeId);
	if (!sourceParent || !targetParent || !moving) return document;
	if (findActionNode(moving, parentId)) return document;
	sourceParent.children = sourceParent.children.filter((child) => child.id !== nodeId);
	targetParent.children.push(moving);
	return next;
};

export const setActionNode = (document: ActionDocument, nodeId: string, updater: (node: ActionNode) => ActionNode): ActionDocument => {
	const next = cloneActionDocument(document);
	next.root = updateActionNode(next.root, nodeId, updater);
	return next;
};

export const addActionLook = (document: ActionDocument): ActionDocument => {
	const next = cloneActionDocument(document);
	let index = next.looks.length + 1;
	let name = `Look${index}`;
	while (next.looks.indexOf(name) >= 0) {
		index += 1;
		name = `Look${index}`;
	}
	next.looks.push(name);
	return next;
};

export const removeActionLook = (document: ActionDocument, look: string): ActionDocument => {
	const next = cloneActionDocument(document);
	next.looks = next.looks.filter((item) => item !== look);
	const walk = (node: ActionNode) => {
		node.hiddenInLooks = node.hiddenInLooks.filter((item) => item !== look);
		node.children.forEach(walk);
	};
	walk(next.root);
	return next;
};

export const setActionNodeLookHidden = (document: ActionDocument, nodeId: string, look: string, hidden: boolean): ActionDocument => {
	return setActionNode(document, nodeId, (node) => {
		const hiddenInLooks = hidden
			? [...new Set([...node.hiddenInLooks, look])]
			: node.hiddenInLooks.filter((item) => item !== look);
		return {...node, hiddenInLooks};
	});
};

export const addActionKeyPoint = (document: ActionDocument): ActionDocument => {
	const next = cloneActionDocument(document);
	let index = next.keyPoints.length + 1;
	let name = `Point${index}`;
	while (next.keyPoints.some((point) => point.name === name)) {
		index += 1;
		name = `Point${index}`;
	}
	next.keyPoints.push({name, x: 0, y: 0});
	return next;
};

export const removeActionKeyPoint = (document: ActionDocument, index: number): ActionDocument => {
	const next = cloneActionDocument(document);
	if (index < 0 || index >= next.keyPoints.length) return document;
	next.keyPoints.splice(index, 1);
	return next;
};

export const updateActionKeyPoint = (
	document: ActionDocument,
	index: number,
	updater: (point: ActionDocument["keyPoints"][number]) => ActionDocument["keyPoints"][number],
): ActionDocument => {
	const next = cloneActionDocument(document);
	if (index < 0 || index >= next.keyPoints.length) return document;
	next.keyPoints[index] = updater(next.keyPoints[index]);
	return next;
};
