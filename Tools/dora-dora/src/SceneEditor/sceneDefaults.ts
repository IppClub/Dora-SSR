/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { DoraScene, DoraSceneNode, DoraSceneNodeType } from './sceneTypes';

const defaultViewport = {width: 960, height: 540};

const parseViewportSize = (value: unknown, fallback: number) => (
	typeof value === "number" && Number.isFinite(value) && value >= 64 ? Math.round(value) : fallback
);

export const createSceneNode = (type: DoraSceneNodeType, index: number, parentId = "root"): DoraSceneNode => {
	const id = `${type.toLowerCase()}-${Date.now().toString(36)}-${index}`;
	const baseNode: DoraSceneNode = {
		id,
		parentId,
		type,
		name: `${type}${index}`,
		x: 0,
		y: 0,
		scaleX: 1,
		scaleY: 1,
		rotation: 0,
		visible: true,
	};
	switch (type) {
		case "Sprite":
			return {...baseNode, texture: ""};
		case "Label":
			return {...baseNode, text: "Hello Dora", fontSize: 32};
		default:
			return baseNode;
	}
};

export const createDefaultScene = (name = "MainScene"): DoraScene => ({
	version: 1,
	name,
	rootId: "root",
	viewport: {...defaultViewport},
	nodes: [
		{
			id: "root",
			parentId: null,
			type: "Node",
			name,
			x: 0,
			y: 0,
			scaleX: 1,
			scaleY: 1,
			rotation: 0,
			visible: true,
		},
		{
			id: "sprite-hero",
			parentId: "root",
			type: "Sprite",
			name: "HeroSprite",
			x: -120,
			y: 40,
			scaleX: 1,
			scaleY: 1,
			rotation: 0,
			visible: true,
			texture: "",
		},
		{
			id: "label-title",
			parentId: "root",
			type: "Label",
			name: "TitleLabel",
			x: 0,
			y: 130,
			scaleX: 1,
			scaleY: 1,
			rotation: 0,
			visible: true,
			text: "Dora Scene",
			fontSize: 36,
		},
	],
});

export const parseSceneContent = (content: string, fallbackName: string): DoraScene => {
	if (content.trim().length === 0) {
		return createDefaultScene(fallbackName);
	}
	try {
		const parsed = JSON.parse(content) as Partial<DoraScene>;
		if (parsed.version === 1 && typeof parsed.rootId === "string" && Array.isArray(parsed.nodes)) {
			const parsedViewport = typeof parsed.viewport === "object" && parsed.viewport !== null ? parsed.viewport as Partial<DoraScene["viewport"]> : {};
			return {
				version: 1,
				name: typeof parsed.name === "string" && parsed.name.length > 0 ? parsed.name : fallbackName,
				rootId: parsed.rootId,
				viewport: {
					width: parseViewportSize(parsedViewport.width, defaultViewport.width),
					height: parseViewportSize(parsedViewport.height, defaultViewport.height),
				},
				nodes: parsed.nodes.map((node, index) => ({
					id: typeof node.id === "string" ? node.id : `node-${index}`,
					parentId: typeof node.parentId === "string" ? node.parentId : null,
					type: node.type === "Sprite" || node.type === "Label" ? node.type : "Node",
					name: typeof node.name === "string" ? node.name : `Node${index}`,
					x: typeof node.x === "number" ? node.x : 0,
					y: typeof node.y === "number" ? node.y : 0,
					scaleX: typeof node.scaleX === "number" ? node.scaleX : 1,
					scaleY: typeof node.scaleY === "number" ? node.scaleY : 1,
					rotation: typeof node.rotation === "number" ? node.rotation : 0,
					visible: typeof node.visible === "boolean" ? node.visible : true,
					texture: typeof node.texture === "string" ? node.texture : undefined,
					text: typeof node.text === "string" ? node.text : undefined,
					fontSize: typeof node.fontSize === "number" ? node.fontSize : undefined,
					script: typeof node.script === "string" ? node.script : undefined,
				})),
			};
		}
	} catch {
		// Keep the editor usable even if the file is not valid scene JSON yet.
	}
	return createDefaultScene(fallbackName);
};

export const stringifySceneContent = (scene: DoraScene) => `${JSON.stringify(scene, null, "\t")}\n`;
