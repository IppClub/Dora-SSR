import {
	ActionDocument,
	ActionFrameTrack,
	ActionKeyFrame,
	ActionKeyTrack,
	ActionNode,
	ActionTrack,
	createEmptyActionDocument,
} from "./ActionDocument";
import {ActionXmlElement, escapeXml, parseActionXml} from "./ActionXml";

type TempTrack = {
	index: number;
	track: Omit<ActionKeyTrack, "animation"> | Omit<ActionFrameTrack, "animation">;
};

type TempNode = Omit<ActionNode, "hiddenInLooks" | "tracks" | "children"> & {
	hiddenLookIndices: number[];
	tracksByIndex: TempTrack[];
	children: TempNode[];
};

const num = (value: string | undefined, fallback: number) => {
	if (value === undefined || value === "") return fallback;
	const parsed = Number(value);
	return Number.isFinite(parsed) ? parsed : fallback;
};

const vec2 = (value: string | undefined, fallback = {x: 0, y: 0}) => {
	if (!value) return {...fallback};
	const [xRaw, yRaw] = value.split(",");
	return {x: num(xRaw, fallback.x), y: num(yRaw, fallback.y)};
};

const size = (value: string | undefined) => {
	const parsed = vec2(value);
	return {width: parsed.x, height: parsed.y};
};

const splitIndices = (value: string | undefined) => {
	if (!value) return [];
	return value.split(",").map((item) => Number(item)).filter((item) => Number.isFinite(item));
};

const attrIndexMapToNames = (items: ActionXmlElement[], tag: "I" | "J") => {
	const mapped: Array<{index: number; name: string}> = [];
	for (const item of items) {
		if (item.name !== tag) continue;
		const index = num(item.attrs.C, 0);
		const name = item.attrs.H ?? "";
		mapped.push({index, name});
	}
	mapped.sort((a, b) => a.index - b.index);
	return mapped.map((item) => item.name);
};

const defaultFrame = (): ActionKeyFrame => ({
	time: 0,
	transform: {
		position: {x: 0, y: 0},
		scale: {x: 1, y: 1},
		skew: {x: 0, y: 0},
		rotation: 0,
		opacity: 1,
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

const cloneFrame = (frame: ActionKeyFrame): ActionKeyFrame => ({
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

const parseKeyAnimation = (element: ActionXmlElement): Omit<ActionKeyTrack, "animation"> => {
	const keyframes: ActionKeyFrame[] = [];
	let lastFrame = defaultFrame();
	let time = 0;
	let lastDuration = 0;
	for (const child of element.children) {
		if (child.name !== "D") continue;
		const frame = cloneFrame(lastFrame);
		const duration = child.attrs.A === undefined ? lastDuration : num(child.attrs.A, 0) / 60;
		time = keyframes.length === 0 ? 0 : time + duration;
		lastDuration = duration;
		frame.time = time;
		if (child.attrs.B !== undefined) frame.visible = num(child.attrs.B, 1) !== 0;
		if (child.attrs.C !== undefined) frame.transform.opacity = Math.max(0, Math.min(1, num(child.attrs.C, 1)));
		if (child.attrs.D !== undefined) frame.transform.position = vec2(child.attrs.D);
		if (child.attrs.E !== undefined) frame.transform.scale = vec2(child.attrs.E, {x: 1, y: 1});
		if (child.attrs.F !== undefined) frame.transform.rotation = num(child.attrs.F, 0);
		if (child.attrs.G !== undefined) frame.transform.skew = vec2(child.attrs.G);
		if (child.attrs.H !== undefined) frame.ease.opacity = num(child.attrs.H, 0);
		if (child.attrs.I !== undefined) frame.ease.position = num(child.attrs.I, 0);
		if (child.attrs.J !== undefined) frame.ease.scale = num(child.attrs.J, 0);
		if (child.attrs.K !== undefined) frame.ease.rotation = num(child.attrs.K, 0);
		if (child.attrs.L !== undefined) frame.ease.skew = num(child.attrs.L, 0);
		if (child.attrs.M !== undefined) frame.event = child.attrs.M;
		keyframes.push(frame);
		lastFrame = frame;
	}
	return {type: "key", keyframes};
};

const parseFrameAnimation = (element: ActionXmlElement): Omit<ActionFrameTrack, "animation"> => ({
	type: "frame",
	file: element.attrs.A ?? "",
	delay: num(element.attrs.B, 0),
});

const parseNode = (element: ActionXmlElement, id: string): TempNode => {
	const node: TempNode = {
		id,
		name: element.attrs.H ?? "",
		clip: element.attrs.I ?? "",
		front: element.attrs.J === undefined ? true : num(element.attrs.J, 1) !== 0,
		transform: {
			position: vec2(element.attrs.D),
			scale: vec2(element.attrs.E, {x: 1, y: 1}),
			skew: vec2(element.attrs.G),
			rotation: num(element.attrs.F, 0),
			opacity: num(element.attrs.C, 1),
			anchor: vec2(element.attrs.A, {x: 0.5, y: 0.5}),
		},
		hiddenLookIndices: [],
		tracksByIndex: [],
		children: [],
	};
	let trackIndex = 0;
	let childIndex = 0;
	for (const child of element.children) {
		if (child.name === "C") {
			node.tracksByIndex.push({index: trackIndex, track: parseKeyAnimation(child)});
			trackIndex += 1;
		} else if (child.name === "E") {
			node.tracksByIndex.push({index: trackIndex, track: parseFrameAnimation(child)});
			trackIndex += 1;
		} else if (child.name === "F") {
			node.hiddenLookIndices.push(...splitIndices(child.attrs.H));
		} else if (child.name === "B") {
			node.children.push(parseNode(child, `${id}.${childIndex}`));
			childIndex += 1;
		}
	}
	return node;
};

const resolveNode = (node: TempNode, animations: string[], looks: string[]): ActionNode => {
	const tracks: Record<string, ActionTrack> = {};
	for (const item of node.tracksByIndex) {
		const animation = animations[item.index] ?? `animation${item.index}`;
		tracks[animation] = {...item.track, animation} as ActionTrack;
	}
	return {
		id: node.id,
		name: node.name,
		clip: node.clip,
		front: node.front,
		transform: node.transform,
		hiddenInLooks: node.hiddenLookIndices.map((index) => looks[index]).filter((name) => name !== undefined),
		tracks,
		children: node.children.map((child) => resolveNode(child, animations, looks)),
	};
};

export const parseLegacyModel = (xml: string, modelPath?: string): ActionDocument => {
	const root = parseActionXml(xml);
	if (root.name !== "A") throw new Error("Expected .model root <A>");
	const rootNodeElement = root.children.find((child) => child.name === "B");
	if (!rootNodeElement) throw new Error("Expected .model sprite root <B>");
	const animations = attrIndexMapToNames(root.children, "J");
	const looks = attrIndexMapToNames(root.children, "I");
	const tempRoot = parseNode(rootNodeElement, "root");
	const document: ActionDocument = {
		version: 1,
		source: "model",
		modelPath,
		clipFile: root.attrs.A ?? "",
		size: size(root.attrs.D),
		root: resolveNode(tempRoot, animations, looks),
		animations,
		looks,
		keyPoints: root.children
			.filter((child) => child.name === "K")
			.map((child) => ({name: child.attrs.A ?? "", ...vec2(child.attrs.B)})),
		legacy: {
			useBatch: root.attrs.B === undefined ? undefined : num(root.attrs.B, 0) !== 0,
		},
	};
	return document;
};

const trimNumber = (value: number, precision: number) => {
	const fixed = value.toFixed(precision);
	return fixed.replace(/\.?0+$/, "");
};

const pair = (x: number, y: number, precision = 2) => `${trimNumber(x, precision)},${trimNumber(y, precision)}`;

const attr = (name: string, value: string | number | undefined) => value === undefined || value === "" ? "" : ` ${name}="${escapeXml(String(value))}"`;

const nodeToXml = (node: ActionNode, animations: string[], looks: string[]) => {
	const t = node.transform;
	let out = `<B`;
	if (t.position.x !== 0 || t.position.y !== 0) out += attr("D", pair(t.position.x, t.position.y));
	if (t.rotation !== 0) out += attr("F", trimNumber(t.rotation, 2));
	if (t.anchor.x !== 0.5 || t.anchor.y !== 0.5) out += attr("A", pair(t.anchor.x, t.anchor.y, 4));
	if (t.scale.x !== 1 || t.scale.y !== 1) out += attr("E", pair(t.scale.x, t.scale.y, 3));
	if (t.skew.x !== 0 || t.skew.y !== 0) out += attr("G", pair(t.skew.x, t.skew.y, 3));
	if (t.opacity !== 1) out += attr("C", trimNumber(t.opacity, 2));
	out += attr("H", node.name);
	out += attr("I", node.clip);
	if (!node.front) out += attr("J", 0);
	out += ">";
	for (const animation of animations) {
		const track = node.tracks[animation];
		if (!track) {
			out += "<C/>";
		} else if (track.type === "frame") {
			out += `<E${attr("A", track.file)}${attr("B", track.delay === 0 ? undefined : trimNumber(track.delay, 2))}/>`;
		} else {
			out += keyTrackToXml(track);
		}
	}
	const hiddenLookIndices = node.hiddenInLooks
		.map((name) => looks.indexOf(name))
		.filter((index) => index >= 0);
	if (hiddenLookIndices.length > 0) {
		out += `<F H="${hiddenLookIndices.join(",")}"/>`;
	}
	for (const child of node.children) {
		out += nodeToXml(child, animations, looks);
	}
	out += "</B>";
	return out;
};

const keyTrackToXml = (track: ActionKeyTrack) => {
	if (track.keyframes.length === 0) return "<C/>";
	const sorted = [...track.keyframes].sort((a, b) => a.time - b.time);
	let out = "<C>";
	let previousTime = 0;
	for (const frame of sorted) {
		const f = frame.transform;
		const duration = Math.max(0, Math.round((frame.time - previousTime) * 60));
		out += `<D`;
		if (duration !== 0) out += attr("A", duration);
		if (!frame.visible) out += attr("B", 0);
		if (f.opacity !== 1) out += attr("C", trimNumber(f.opacity, 2));
		if (f.position.x !== 0 || f.position.y !== 0) out += attr("D", pair(f.position.x, f.position.y));
		if (f.scale.x !== 1 || f.scale.y !== 1) out += attr("E", pair(f.scale.x, f.scale.y));
		if (f.rotation !== 0) out += attr("F", trimNumber(f.rotation, 2));
		if (f.skew.x !== 0 || f.skew.y !== 0) out += attr("G", pair(f.skew.x, f.skew.y));
		if (frame.ease.opacity !== 0) out += attr("H", frame.ease.opacity);
		if (frame.ease.position !== 0) out += attr("I", frame.ease.position);
		if (frame.ease.scale !== 0) out += attr("J", frame.ease.scale);
		if (frame.ease.rotation !== 0) out += attr("K", frame.ease.rotation);
		if (frame.ease.skew !== 0) out += attr("L", frame.ease.skew);
		if (frame.event) out += attr("M", frame.event);
		out += "/>";
		previousTime = frame.time;
	}
	out += "</C>";
	return out;
};

export const writeLegacyModel = (document: ActionDocument) => {
	let out = `<A${attr("A", document.clipFile)}`;
	if (document.size.width !== 0 || document.size.height !== 0) {
		out += attr("D", `${Math.round(document.size.width)},${Math.round(document.size.height)}`);
	}
	out += ">";
	out += nodeToXml(document.root, document.animations, document.looks);
	document.animations.forEach((name, index) => {
		out += `<J C="${index}" H="${escapeXml(name)}"/>`;
	});
	document.looks.forEach((name, index) => {
		out += `<I C="${index}" H="${escapeXml(name)}"/>`;
	});
	for (const point of document.keyPoints) {
		out += `<K A="${escapeXml(point.name)}" B="${pair(point.x, point.y)}"/>`;
	}
	out += "</A>";
	return out;
};

const defaultClipFileForModel = (modelPath?: string) => {
	if (!modelPath) return "";
	const file = modelPath.split("/").pop() ?? "";
	return file.replace(/\.model$/i, ".clip");
};

export const loadActionDocumentFromModelContent = (content: string, modelPath?: string) => {
	try {
		return {
			document: parseLegacyModel(content, modelPath),
			diagnostics: [],
			dirty: false,
		};
	} catch (error) {
		return {
			document: createEmptyActionDocument(modelPath, defaultClipFileForModel(modelPath)),
			diagnostics: [{
				severity: "error" as const,
				message: error instanceof Error ? `Failed to load .model: ${error.message}` : "Failed to load .model",
				path: modelPath,
			}],
			dirty: true,
		};
	}
};
