import { Vec2 } from "Dora";
import type * as Dora from "Dora";
import * as nvg from "nvg";

interface ClipInfo {
	width: number;
	height: number;
}

const clips = new LuaTable<Dora.Node.Type, ClipInfo>();

export function registerClip(this: void, node: Dora.Node.Type, width: number, height: number) {
	clips.set(node, {
		width: math.max(0, width),
		height: math.max(0, height),
	});
}

export function unregisterClip(this: void, node: Dora.Node.Type) {
	clips.delete(node);
}

function resolveClipRect(this: void, node: Dora.Node.Type, clipNode: Dora.Node.Type, clip: ClipInfo) {
	const worldA = clipNode.convertToWorldSpace(Vec2(0, 0));
	const worldB = clipNode.convertToWorldSpace(Vec2(clip.width, clip.height));
	const localA = node.convertToNodeSpace(worldA);
	const localB = node.convertToNodeSpace(worldB);
	return {
		x: math.min(localA.x, localB.x),
		y: math.min(localA.y, localB.y),
		width: math.abs(localB.x - localA.x),
		height: math.abs(localB.y - localA.y),
	};
}

export function applyAncestorClips(this: void, node: Dora.Node.Type) {
	let clipped = false;
	let parent = node.parent;
	while (parent !== undefined) {
		const clip = clips.get(parent);
		if (clip !== undefined && clip.width > 0 && clip.height > 0) {
			const rect = resolveClipRect(node, parent, clip);
			if (clipped) {
				nvg.IntersectScissor(rect.x, rect.y, rect.width, rect.height);
			} else {
				nvg.Scissor(rect.x, rect.y, rect.width, rect.height);
				clipped = true;
			}
		}
		parent = parent.parent;
	}
}
