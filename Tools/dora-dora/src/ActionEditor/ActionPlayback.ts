import type {ActionDocument, ActionKeyFrame, ActionKeyTrack, ActionNode, ActionTrack, ActionTransform} from "./ActionDocument";
import {cloneActionDocument, setActionNode} from "./ActionEditorState";

export const createActionKeyFrameFromNode = (node: ActionNode, time: number): ActionKeyFrame => ({
	time: Math.max(0, time),
	transform: {
		position: {...node.transform.position},
		scale: {...node.transform.scale},
		skew: {...node.transform.skew},
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
		position: {...frame.transform.position},
		scale: {...frame.transform.scale},
		skew: {...frame.transform.skew},
		rotation: frame.transform.rotation,
		opacity: frame.transform.opacity,
	},
	visible: frame.visible,
	ease: {...frame.ease},
	event: frame.event,
});

const keyTrackForNode = (node: ActionNode, animation: string): ActionKeyTrack => {
	const existing = node.tracks[animation];
	if (existing?.type === "key") {
		return {
			...existing,
			keyframes: existing.keyframes.map(cloneKeyFrame),
		};
	}
	return {type: "key", animation, keyframes: []};
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
	return {document: next, animation: name};
};

export const removeActionAnimation = (document: ActionDocument, animation: string): ActionDocument => {
	const next = cloneActionDocument(document);
	next.animations = next.animations.filter((item) => item !== animation);
	const walk = (node: ActionNode) => {
		const tracks = {...node.tracks};
		delete tracks[animation];
		node.tracks = tracks;
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
			track.keyframes[index] = {...frame, event: track.keyframes[index].event};
		 } else {
			track.keyframes.push(frame);
		}
		track.keyframes.sort((a, b) => a.time - b.time);
		return {...node, tracks: {...node.tracks, [animation]: track}};
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
		const keyframes = existing.keyframes.filter((frame) => Math.abs(frame.time - time) >= 1 / 120);
		const tracks: Record<string, ActionTrack> = {
			...node.tracks,
			[animation]: {...existing, keyframes},
		};
		return {...node, tracks};
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
		track.keyframes.sort((a, b) => a.time - b.time);
		return {...node, tracks: {...node.tracks, [animation]: track}};
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
			return {...frame, time: targetTime};
		}).sort((a, b) => a.time - b.time);
		return {...node, tracks: {...node.tracks, [animation]: {...existing, keyframes}}};
	});
};

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
		const keyframes = existing.keyframes.map((frame) => {
			if (Math.abs(frame.time - time) >= 1 / 120) return frame;
			return {...frame, event: event === "" ? undefined : event};
		});
		return {...node, tracks: {...node.tracks, [animation]: {...existing, keyframes}}};
	});
};

const mix = (from: number, to: number, t: number) => from + (to - from) * t;

export const sampleActionKeyTrack = (track: ActionKeyTrack, time: number): Omit<ActionTransform, "anchor"> & {visible: boolean} | null => {
	if (track.keyframes.length === 0) return null;
	const frames = [...track.keyframes].sort((a, b) => a.time - b.time);
	if (time <= frames[0].time) {
		const frame = frames[0];
		return {...frame.transform, visible: frame.visible};
	}
	for (let index = 1; index < frames.length; index += 1) {
		const previous = frames[index - 1];
		const next = frames[index];
		if (time <= next.time) {
			const span = Math.max(0.0001, next.time - previous.time);
			const t = (time - previous.time) / span;
			return {
				position: {
					x: mix(previous.transform.position.x, next.transform.position.x, t),
					y: mix(previous.transform.position.y, next.transform.position.y, t),
				},
				scale: {
					x: mix(previous.transform.scale.x, next.transform.scale.x, t),
					y: mix(previous.transform.scale.y, next.transform.scale.y, t),
				},
				skew: {
					x: mix(previous.transform.skew.x, next.transform.skew.x, t),
					y: mix(previous.transform.skew.y, next.transform.skew.y, t),
				},
				rotation: mix(previous.transform.rotation, next.transform.rotation, t),
				opacity: mix(previous.transform.opacity, next.transform.opacity, t),
				visible: next.visible,
			};
		}
	}
	const frame = frames[frames.length - 1];
	return {...frame.transform, visible: frame.visible};
};

export const getActionAnimationDuration = (document: ActionDocument, animation: string): number => {
	let duration = 0;
	const walk = (node: ActionNode) => {
		const track = node.tracks[animation];
		if (track?.type === "key") {
			for (const frame of track.keyframes) {
				duration = Math.max(duration, frame.time);
			}
		}
		node.children.forEach(walk);
	};
	walk(document.root);
	return duration;
};
