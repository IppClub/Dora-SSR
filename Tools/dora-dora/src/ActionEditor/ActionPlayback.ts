import type { ActionDocument, ActionFrameTrack, ActionKeyFrame, ActionKeyTrack, ActionNode, ActionTrack, ActionTransform } from "./ActionDocument";
import { cloneActionDocument, setActionNode } from "./ActionEditorState";

export type ActionFrameSpec = {
	clipFile: string;
	clipName: string;
	frameWidth: number;
	frameHeight: number;
	frameCount: number;
	duration: number;
};

export const parseActionFrameSpec = (value: string): ActionFrameSpec | null => {
	const [clipRef, frameRef] = value.split("::");
	if (!clipRef || !frameRef) return null;
	const separator = clipRef.indexOf("|");
	const clipFile = separator >= 0 ? clipRef.slice(0, separator) : "";
	const clipName = separator >= 0 ? clipRef.slice(separator + 1) : clipRef;
	const parts = frameRef.split(",").map((item) => Number(item.trim()));
	if (clipName === "" || parts.length < 4 || parts.some((item) => !Number.isFinite(item))) return null;
	const [frameWidth, frameHeight, frameCount, duration] = parts;
	if (frameWidth <= 0 || frameHeight <= 0 || frameCount <= 0 || duration <= 0) return null;
	return {
		clipFile,
		clipName,
		frameWidth,
		frameHeight,
		frameCount: Math.max(1, Math.round(frameCount)),
		duration,
	};
};

const trimSpecNumber = (value: number, precision: number) => {
	const fixed = value.toFixed(precision);
	return fixed.replace(/\.?0+$/, "");
};

export const formatActionFrameSpec = (spec: ActionFrameSpec) => {
	const clipRef = spec.clipFile ? `${spec.clipFile}|${spec.clipName}` : spec.clipName;
	return `${clipRef}::${trimSpecNumber(spec.frameWidth, 3)},${trimSpecNumber(spec.frameHeight, 3)},${Math.max(1, Math.round(spec.frameCount))},${trimSpecNumber(spec.duration, 3)}`;
};

export const createActionKeyFrameFromNode = (node: ActionNode, time: number): ActionKeyFrame => ({
	time: Math.max(0, time),
	transform: {
		position: { ...node.transform.position },
		scale: { ...node.transform.scale },
		skew: { ...node.transform.skew },
		rotation: node.transform.rotation,
		opacity: node.transform.opacity,
	},
	visible: true,
	ease: {
		position: 0,
		scale: 0,
		skew: 0,
		rotation: 0,
		opacity: 0,
	},
});

const cloneKeyFrame = (frame: ActionKeyFrame): ActionKeyFrame => ({
	time: frame.time,
	transform: {
		position: { ...frame.transform.position },
		scale: { ...frame.transform.scale },
		skew: { ...frame.transform.skew },
		rotation: frame.transform.rotation,
		opacity: frame.transform.opacity,
	},
	visible: frame.visible,
	ease: { ...frame.ease },
	event: frame.event,
});

const linearEase = () => ({
	position: 0,
	scale: 0,
	skew: 0,
	rotation: 0,
	opacity: 0,
});

const normalizeFirstKeyFrameEase = (keyframes: ActionKeyFrame[]) => {
	const sorted = keyframes.map(cloneKeyFrame).sort((a, b) => a.time - b.time);
	if (sorted.length > 0) {
		sorted[0] = {
			...sorted[0],
			ease: linearEase(),
		};
	}
	return sorted;
};

const keyTrackForNode = (node: ActionNode, animation: string): ActionKeyTrack => {
	const existing = node.tracks[animation];
	if (existing?.type === "key") {
		return {
			...existing,
			keyframes: normalizeFirstKeyFrameEase(existing.keyframes),
		};
	}
	return { type: "key", animation, keyframes: [] };
};

export const addActionAnimation = (document: ActionDocument) => {
	const next = cloneActionDocument(document);
	let index = next.animations.length + 1;
	let name = `Animation${index}`;
	while (next.animations.indexOf(name) >= 0) {
		index += 1;
		name = `Animation${index}`;
	}
	next.animations.push(name);
	return { document: next, animation: name };
};

export const removeActionAnimation = (document: ActionDocument, animation: string): ActionDocument => {
	const next = cloneActionDocument(document);
	next.animations = next.animations.filter((item) => item !== animation);
	const walk = (node: ActionNode) => {
		const tracks = { ...node.tracks };
		delete tracks[animation];
		node.tracks = tracks;
		node.children.forEach(walk);
	};
	walk(next.root);
	return next;
};

export const renameActionAnimation = (document: ActionDocument, from: string, to: string): ActionDocument => {
	const name = to.trim();
	if (name === "" || name === from || document.animations.indexOf(name) >= 0) return document;
	const next = cloneActionDocument(document);
	next.animations = next.animations.map((item) => item === from ? name : item);
	const walk = (node: ActionNode) => {
		const existing = node.tracks[from];
		if (existing) {
			const tracks = { ...node.tracks };
			delete tracks[from];
			tracks[name] = { ...existing, animation: name };
			node.tracks = tracks;
		}
		node.children.forEach(walk);
	};
	walk(next.root);
	return next;
};

export const upsertActionKeyFrame = (
	document: ActionDocument,
	nodeId: string,
	animation: string,
	time: number,
): ActionDocument => {
	const frameTime = Math.max(0, time);
	return setActionNode(document, nodeId, (node) => {
		const track = keyTrackForNode(node, animation);
		const index = track.keyframes.findIndex((frame) => Math.abs(frame.time - frameTime) < 1 / 120);
		const frame = createActionKeyFrameFromNode(node, frameTime);
		if (index >= 0) {
			track.keyframes[index] = { ...frame, event: track.keyframes[index].event };
		} else {
			track.keyframes.push(frame);
		}
		track.keyframes = normalizeFirstKeyFrameEase(track.keyframes);
		return { ...node, tracks: { ...node.tracks, [animation]: track } };
	});
};

export const deleteActionKeyFrame = (
	document: ActionDocument,
	nodeId: string,
	animation: string,
	time: number,
): ActionDocument => {
	return setActionNode(document, nodeId, (node) => {
		const existing = node.tracks[animation];
		if (existing?.type !== "key") return node;
		const keyframes = normalizeFirstKeyFrameEase(existing.keyframes.filter((frame) => Math.abs(frame.time - time) >= 1 / 120));
		const tracks: Record<string, ActionTrack> = {
			...node.tracks,
			[animation]: { ...existing, keyframes },
		};
		return { ...node, tracks };
	});
};

export const copyActionKeyFrame = (
	document: ActionDocument,
	nodeId: string,
	animation: string,
	time: number,
): ActionKeyFrame | null => {
	const find = (node: ActionNode): ActionKeyFrame | null => {
		if (node.id === nodeId) {
			const track = node.tracks[animation];
			if (track?.type !== "key") return null;
			const frame = track.keyframes.find((item) => Math.abs(item.time - time) < 1 / 120);
			return frame ? cloneKeyFrame(frame) : null;
		}
		for (const child of node.children) {
			const result = find(child);
			if (result) return result;
		}
		return null;
	};
	return find(document.root);
};

export const pasteActionKeyFrame = (
	document: ActionDocument,
	nodeId: string,
	animation: string,
	time: number,
	frame: ActionKeyFrame,
): ActionDocument => {
	const targetTime = Math.max(0, time);
	return setActionNode(document, nodeId, (node) => {
		const track = keyTrackForNode(node, animation);
		const pasted = cloneKeyFrame(frame);
		pasted.time = targetTime;
		const existing = track.keyframes.findIndex((item) => Math.abs(item.time - targetTime) < 1 / 120);
		if (existing >= 0) {
			track.keyframes[existing] = pasted;
		} else {
			track.keyframes.push(pasted);
		}
		track.keyframes = normalizeFirstKeyFrameEase(track.keyframes);
		return { ...node, tracks: { ...node.tracks, [animation]: track } };
	});
};

export const moveActionKeyFrame = (
	document: ActionDocument,
	nodeId: string,
	animation: string,
	fromTime: number,
	toTime: number,
): ActionDocument => {
	const targetTime = Math.max(0, toTime);
	return setActionNode(document, nodeId, (node) => {
		const existing = node.tracks[animation];
		if (existing?.type !== "key") return node;
		const keyframes = existing.keyframes.map((frame) => {
			if (Math.abs(frame.time - fromTime) >= 1 / 120) return frame;
			return { ...frame, time: targetTime };
		});
		return { ...node, tracks: { ...node.tracks, [animation]: { ...existing, keyframes: normalizeFirstKeyFrameEase(keyframes) } } };
	});
};

export const isFirstActionKeyFrame = (
	document: ActionDocument,
	nodeId: string,
	animation: string,
	time: number,
): boolean => {
	const find = (node: ActionNode): boolean | null => {
		if (node.id === nodeId) {
			const track = node.tracks[animation];
			if (track?.type !== "key" || track.keyframes.length === 0) return false;
			const sorted = [...track.keyframes].sort((a, b) => a.time - b.time);
			return Math.abs(sorted[0].time - time) < 1 / 120;
		}
		for (const child of node.children) {
			const result = find(child);
			if (result !== null) return result;
		}
		return null;
	};
	return find(document.root) ?? false;
};

export const normalizeActionKeyTrackFirstEase = (
	document: ActionDocument,
	nodeId: string,
	animation: string,
): ActionDocument => {
	return setActionNode(document, nodeId, (node) => {
		const existing = node.tracks[animation];
		if (existing?.type !== "key") return node;
		const keyframes = normalizeFirstKeyFrameEase(existing.keyframes);
		return { ...node, tracks: { ...node.tracks, [animation]: { ...existing, keyframes } } };
	});
};

export const setActionFrameTrack = (
	document: ActionDocument,
	nodeId: string,
	animation: string,
	track: Omit<ActionFrameTrack, "animation">,
): ActionDocument => setActionNode(document, nodeId, (node) => ({
	...node,
	tracks: {
		...node.tracks,
		[animation]: { ...track, animation },
	},
}));

export const setActionKeyFrameEvent = (
	document: ActionDocument,
	nodeId: string,
	animation: string,
	time: number,
	event: string,
): ActionDocument => {
	return setActionNode(document, nodeId, (node) => {
		const existing = node.tracks[animation];
		if (existing?.type !== "key") return node;
		const keyframes = normalizeFirstKeyFrameEase(existing.keyframes.map((frame) => {
			if (Math.abs(frame.time - time) >= 1 / 120) return frame;
			return { ...frame, event: event === "" ? undefined : event };
		}));
		return { ...node, tracks: { ...node.tracks, [animation]: { ...existing, keyframes } } };
	});
};

export const updateActionKeyFrame = (
	document: ActionDocument,
	nodeId: string,
	animation: string,
	time: number,
	updater: (frame: ActionKeyFrame) => ActionKeyFrame,
): ActionDocument => {
	return setActionNode(document, nodeId, (node) => {
		const existing = node.tracks[animation];
		if (existing?.type !== "key") return node;
		const keyframes = normalizeFirstKeyFrameEase(existing.keyframes.map((frame) => {
			if (Math.abs(frame.time - time) >= 1 / 120) return frame;
			return updater(cloneKeyFrame(frame));
		}));
		return { ...node, tracks: { ...node.tracks, [animation]: { ...existing, keyframes } } };
	});
};

const mix = (from: number, to: number, t: number) => from + (to - from) * t;

const easeInBounce = (t: number): number => 1 - easeOutBounce(1 - t);
const easeOutBounce = (t: number): number => {
	const n1 = 7.5625;
	const d1 = 2.75;
	if (t < 1 / d1) return n1 * t * t;
	if (t < 2 / d1) {
		const v = t - 1.5 / d1;
		return n1 * v * v + 0.75;
	}
	if (t < 2.5 / d1) {
		const v = t - 2.25 / d1;
		return n1 * v * v + 0.9375;
	}
	const v = t - 2.625 / d1;
	return n1 * v * v + 0.984375;
};

const easeInOut = (t: number, easeIn: (value: number) => number, easeOut: (value: number) => number) => (
	t < 0.5 ? easeIn(t * 2) * 0.5 : easeOut(t * 2 - 1) * 0.5 + 0.5
);

const easeOutIn = (t: number, easeOut: (value: number) => number, easeIn: (value: number) => number) => (
	t < 0.5 ? easeOut(t * 2) * 0.5 : easeIn(t * 2 - 1) * 0.5 + 0.5
);

const easeFuncs: Array<(t: number) => number> = [
	(t) => t,
	(t) => t * t,
	(t) => 1 - (1 - t) * (1 - t),
	(t) => easeInOut(t, easeFuncs[1], easeFuncs[2]),
	(t) => t * t * t,
	(t) => 1 - Math.pow(1 - t, 3),
	(t) => easeInOut(t, easeFuncs[4], easeFuncs[5]),
	(t) => t * t * t * t,
	(t) => 1 - Math.pow(1 - t, 4),
	(t) => easeInOut(t, easeFuncs[7], easeFuncs[8]),
	(t) => t * t * t * t * t,
	(t) => 1 - Math.pow(1 - t, 5),
	(t) => easeInOut(t, easeFuncs[10], easeFuncs[11]),
	(t) => 1 - Math.cos((t * Math.PI) / 2),
	(t) => Math.sin((t * Math.PI) / 2),
	(t) => -(Math.cos(Math.PI * t) - 1) / 2,
	(t) => t === 0 ? 0 : Math.pow(2, 10 * t - 10),
	(t) => t === 1 ? 1 : 1 - Math.pow(2, -10 * t),
	(t) => t === 0 || t === 1 ? t : (t < 0.5 ? Math.pow(2, 20 * t - 10) / 2 : (2 - Math.pow(2, -20 * t + 10)) / 2),
	(t) => 1 - Math.sqrt(1 - t * t),
	(t) => Math.sqrt(1 - Math.pow(t - 1, 2)),
	(t) => t < 0.5 ? (1 - Math.sqrt(1 - Math.pow(2 * t, 2))) / 2 : (Math.sqrt(1 - Math.pow(-2 * t + 2, 2)) + 1) / 2,
	(t) => t === 0 || t === 1 ? t : -Math.pow(2, 10 * t - 10) * Math.sin((t * 10 - 10.75) * ((2 * Math.PI) / 3)),
	(t) => t === 0 || t === 1 ? t : Math.pow(2, -10 * t) * Math.sin((t * 10 - 0.75) * ((2 * Math.PI) / 3)) + 1,
	(t) => t === 0 || t === 1 ? t : (t < 0.5
		? -(Math.pow(2, 20 * t - 10) * Math.sin((20 * t - 11.125) * ((2 * Math.PI) / 4.5))) / 2
		: (Math.pow(2, -20 * t + 10) * Math.sin((20 * t - 11.125) * ((2 * Math.PI) / 4.5))) / 2 + 1),
	(t) => 2.70158 * t * t * t - 1.70158 * t * t,
	(t) => 1 + 2.70158 * Math.pow(t - 1, 3) + 1.70158 * Math.pow(t - 1, 2),
	(t) => t < 0.5
		? (Math.pow(2 * t, 2) * (7.189819 * t - 2.5949095)) / 2
		: (Math.pow(2 * t - 2, 2) * (3.5949095 * (t * 2 - 2) + 2.5949095) + 2) / 2,
	easeInBounce,
	easeOutBounce,
	(t) => easeInOut(t, easeInBounce, easeOutBounce),
	(t) => easeOutIn(t, easeFuncs[2], easeFuncs[1]),
	(t) => easeOutIn(t, easeFuncs[5], easeFuncs[4]),
	(t) => easeOutIn(t, easeFuncs[8], easeFuncs[7]),
	(t) => easeOutIn(t, easeFuncs[11], easeFuncs[10]),
	(t) => easeOutIn(t, easeFuncs[14], easeFuncs[13]),
	(t) => easeOutIn(t, easeFuncs[17], easeFuncs[16]),
	(t) => easeOutIn(t, easeFuncs[20], easeFuncs[19]),
	(t) => easeOutIn(t, easeFuncs[23], easeFuncs[22]),
	(t) => easeOutIn(t, easeFuncs[26], easeFuncs[25]),
	(t) => easeOutIn(t, easeOutBounce, easeInBounce),
];

const ease = (type: number, t: number) => (easeFuncs[Math.max(0, Math.min(easeFuncs.length - 1, Math.round(type)))] ?? easeFuncs[0])(t);

export const sampleActionKeyTrack = (track: ActionKeyTrack, time: number): Omit<ActionTransform, "anchor"> & { visible: boolean } | null => {
	if (track.keyframes.length === 0) return null;
	const frames = [...track.keyframes].sort((a, b) => a.time - b.time);
	if (time <= frames[0].time) {
		const frame = frames[0];
		return { ...frame.transform, visible: frame.visible };
	}
	for (let index = 1; index < frames.length; index += 1) {
		const previous = frames[index - 1];
		const next = frames[index];
		if (time <= next.time) {
			const span = Math.max(0.0001, next.time - previous.time);
			const t = (time - previous.time) / span;
			const tPosition = ease(next.ease.position, t);
			const tScale = ease(next.ease.scale, t);
			const tSkew = ease(next.ease.skew, t);
			const tRotation = ease(next.ease.rotation, t);
			const tOpacity = ease(next.ease.opacity, t);
			return {
				position: {
					x: mix(previous.transform.position.x, next.transform.position.x, tPosition),
					y: mix(previous.transform.position.y, next.transform.position.y, tPosition),
				},
				scale: {
					x: mix(previous.transform.scale.x, next.transform.scale.x, tScale),
					y: mix(previous.transform.scale.y, next.transform.scale.y, tScale),
				},
				skew: {
					x: mix(previous.transform.skew.x, next.transform.skew.x, tSkew),
					y: mix(previous.transform.skew.y, next.transform.skew.y, tSkew),
				},
				rotation: mix(previous.transform.rotation, next.transform.rotation, tRotation),
				opacity: mix(previous.transform.opacity, next.transform.opacity, tOpacity),
				visible: time < next.time ? previous.visible : next.visible,
			};
		}
	}
	const frame = frames[frames.length - 1];
	return { ...frame.transform, visible: frame.visible };
};

export const getActionAnimationDuration = (document: ActionDocument, animation: string): number => {
	let duration = 0;
	const walk = (node: ActionNode) => {
		const track = node.tracks[animation];
		if (track?.type === "key") {
			for (const frame of track.keyframes) {
				duration = Math.max(duration, frame.time);
			}
		} else if (track?.type === "frame") {
			const spec = parseActionFrameSpec(track.file);
			if (spec) {
				duration = Math.max(duration, Math.max(0, track.delay) + spec.duration);
			}
		}
		node.children.forEach(walk);
	};
	walk(document.root);
	return duration;
};
