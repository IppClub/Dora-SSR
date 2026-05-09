export type ActionVec2 = {
	x: number;
	y: number;
};

export type ActionSize = {
	width: number;
	height: number;
};

export type ActionTransform = {
	position: ActionVec2;
	scale: ActionVec2;
	skew: ActionVec2;
	rotation: number;
	opacity: number;
	anchor: ActionVec2;
};

export type ActionKeyPoint = ActionVec2 & {
	name: string;
};

export type ActionKeyFrame = {
	time: number;
	transform: Omit<ActionTransform, "anchor">;
	visible: boolean;
	ease: {
		position: number;
		scale: number;
		skew: number;
		rotation: number;
		opacity: number;
	};
	event?: string;
};

export type ActionKeyTrack = {
	type: "key";
	animation: string;
	keyframes: ActionKeyFrame[];
};

export type ActionFrameTrack = {
	type: "frame";
	animation: string;
	file: string;
	delay: number;
};

export type ActionTrack = ActionKeyTrack | ActionFrameTrack;

export type ActionNode = {
	id: string;
	name: string;
	clip: string;
	front: boolean;
	transform: ActionTransform;
	hiddenInLooks: string[];
	tracks: Record<string, ActionTrack>;
	children: ActionNode[];
	legacy?: {
		hiddenLookIndices?: number[];
	};
};

export type ActionDocument = {
	version: 1;
	source: "model";
	modelPath?: string;
	clipFile: string;
	size: ActionSize;
	root: ActionNode;
	animations: string[];
	looks: string[];
	keyPoints: ActionKeyPoint[];
	legacy: {
		animationIndexes?: Record<string, number>;
		lookIndexes?: Record<string, number>;
		animationOrder?: string[];
		lookOrder?: string[];
	};
};

export type ActionDiagnosticSeverity = "error" | "warning" | "info";

export type ActionDiagnostic = {
	severity: ActionDiagnosticSeverity;
	message: string;
	path?: string;
	nodeId?: string;
};

export type ActionLoadResult = {
	document: ActionDocument;
	diagnostics: ActionDiagnostic[];
	dirty: boolean;
};

export const createEmptyActionNode = (id = "root"): ActionNode => ({
	id,
	name: "",
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

export const createEmptyActionDocument = (modelPath?: string, clipFile = ""): ActionDocument => ({
	version: 1,
	source: "model",
	modelPath,
	clipFile,
	size: {width: 0, height: 0},
	root: createEmptyActionNode(),
	animations: [],
	looks: [],
	keyPoints: [],
	legacy: {},
});
