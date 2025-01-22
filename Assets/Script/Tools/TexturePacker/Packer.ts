/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { Sprite } from 'Dora';

export interface Block {
	name: string;
	w: number;
	h: number;
	sp?: Sprite.Type;
	fit?: Node;
}

export interface Node {
	x: number;
	y: number;
	w: number;
	h: number;
	right?: Node;
	down?: Node;
	used?: boolean;
}

interface Packer {
	root?: Node;
	fit(blocks: Block[]): void;
	findNode(node: Node, w: number, h: number): Node | undefined;
	splitNode(node: Node, w: number, h: number): Node;
	growNode(w: number, h: number): Node | undefined;
	growRight(w: number, h: number): Node | undefined;
	growDown(w: number, h: number): Node | undefined;
}

function CreatePacker() {
	const packer: Packer = {
		fit(blocks: Block[]) {
			table.sort(blocks, (a, b) => {
				return math.max(a.w, a.h) > math.max(b.w, b.h);
			});
			const len = blocks.length;
			const w = len > 0 ? blocks[0].w : 0;
			const h = len > 0 ? blocks[0].h : 0;
			this.root = {x: 0, y: 0, w, h};
			for (let block of blocks) {
				const node = this.findNode(this.root, block.w, block.h);
				if (node) {
					block.fit = this.splitNode(node, block.w, block.h);
				} else {
					block.fit = this.growNode(block.w, block.h);
				}
			}
		},

		findNode(node: Node, w: number, h: number): Node | undefined {
			if (node.used) {
				return (node.right && this.findNode(node.right, w, h))
					|| (node.down && this.findNode(node.down, w, h));
			} else if (w <= node.w && h <= node.h) {
				return node;
			} else {
				return undefined;
			}
		},

		splitNode(node: Node, w: number, h: number): Node {
			node.used = true;
			node.down = {
				x: node.x,
				y: node.y + h,
				w: node.w,
				h: node.h - h
			};
			node.right = {
				x: node.x + w,
				y: node.y,
				w: node.w - w,
				h
			};
			return node;
		},

		growNode(w: number, h: number): Node | undefined {
			if (this.root === undefined) return undefined;
			const canGrowDown = w <= this.root.w;
			const canGrowRight = h <= this.root.h;
			const shouldGrowRight = canGrowRight && (this.root.h >= this.root.w + w);
			const shouldGrowDown = canGrowDown && (this.root.w >= this.root.h + h);
			if (shouldGrowRight) {
				return this.growRight(w, h);
			} else if (shouldGrowDown) {
				return this.growDown(w, h);
			} else if (canGrowRight) {
				return this.growRight(w, h);
			} else if (canGrowDown) {
				return this.growDown(w, h);
			} else {
				return undefined;
			}
		},

		growRight(w: number, h: number): Node | undefined {
			if (this.root === undefined) return undefined;
			this.root = {
				used: true,
				x: 0,
				y: 0,
				w: this.root.w + w,
				h: this.root.h,
				down: this.root,
				right: {
					x: this.root.w,
					y: 0,
					w,
					h: this.root.h
				}
			};
			const node = this.findNode(this.root, w, h);
			if (node) {
				return this.splitNode(node, w, h);
			} else {
				return undefined;
			}
		},

		growDown(w: number, h: number): Node | undefined {
			if (this.root === undefined) return undefined;
			this.root = {
				used: true,
				x: 0,
				y: 0,
				w: this.root.w,
				h: this.root.h + h,
				down: {
					x: 0,
					y: this.root.h,
					w: this.root.w,
					h
				},
				right: this.root
			};
			const node = this.findNode(this.root, w, h);
			if (node) {
				return this.splitNode(node, w, h);
			} else {
				return undefined;
			}
		}
	};
	return packer;
}

export default CreatePacker;
