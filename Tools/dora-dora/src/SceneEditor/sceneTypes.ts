/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

export type DoraSceneNodeType = "Node" | "Sprite" | "Label";

export interface DoraSceneNode {
	id: string;
	parentId: string | null;
	type: DoraSceneNodeType;
	name: string;
	x: number;
	y: number;
	scaleX: number;
	scaleY: number;
	rotation: number;
	visible: boolean;
	texture?: string;
	text?: string;
	fontSize?: number;
	script?: string;
}

export interface DoraScene {
	version: 1;
	name: string;
	rootId: string;
	viewport: {
		width: number;
		height: number;
	};
	nodes: DoraSceneNode[];
}
