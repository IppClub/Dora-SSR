/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

/// <reference path="./Dora/en/jsx.d.ts"/>

import * as Dora from 'Dora';

function Warn(this: void, msg: string) {
	Dora.Log('Warn', `[Dora Warning] ${msg}`);
}

export namespace React {

export abstract class Component<T> {
	constructor(props: T) {
		this.props = props;
	}
	props!: T;
	abstract render(): React.Element;
	static isComponent = true;
}

export const Fragment = undefined;

function flattenChild(this: void, child: any): LuaMultiReturn<[any, boolean]> {
	if (type(child) !== "table") {
		return $multi(child, true);
	}
	if (child.type !== undefined) {
		return $multi(child, true);
	} else if (child.children) {
		child = child.children;
	}
	const list = child as [];
	const flatChildren = [];
	for (let i of $range(1, list.length)) {
		const [child, flat] = flattenChild(list[i - 1]);
		if (flat) {
			flatChildren.push(child);
		} else {
			const listChild = child as [];
			for (let i of $range(1, listChild.length)) {
				flatChildren.push(listChild[i - 1]);
			}
		}
	}
	return $multi(flatChildren, false);
}

export interface Element {
	type: string;
	props: any;
	children: Element[];
}

export function createElement(
	typeName: any,
	props: any,
	...children: any[]
): Element | Element[] {
	const items: any[] = [];
	for (let [, v] of pairs(children)) {
		items.push(v);
	}
	children = items;
	switch (type(typeName)) {
		case 'function': {
				props ??= {};
				if (props.children) {
					props.children = [...props.children, ...children];
				} else {
					props.children = children;
				}
				return typeName(props);
		}
		case 'table': {
			if (!typeName.isComponent) {
				Warn('unsupported class object in element creation');
				return [];
			}
			props ??= {};
			if (props.children) {
				props.children = [...props.children, ...children];
			} else {
				props.children = children;
			}
			const inst = new typeName(props) as React.Component<any>;
			return inst.render();
		}
		default: {
			if (props && props.children) {
				children = [...props.children, ...children];
				props.children = undefined;
			}
			const flatChildren = [];
			for (let i of $range(1, children.length)) {
				const [child, flat] = flattenChild(children[i - 1]);
				if (flat) {
					flatChildren.push(child);
				} else {
					for (let i of $range(1, (child as []).length)) {
						flatChildren.push((child as [])[i - 1]);
					}
				}
			}
			children = flatChildren;
		}
	}
	if (typeName === undefined) {
		return children;
	}
	return {
		type: typeName,
		props: props ?? {},
		children
	};
}

} // namespace React

type AttribHandler = (this: void, cnode: any, enode: React.Element, k: any, v: any) => boolean;

function getNode(this: void, enode: React.Element, cnode?: Dora.Node.Type, attribHandler?: AttribHandler) {
	cnode = cnode ?? Dora.Node();
	const jnode = enode.props as JSX.Node;
	let anchor: Dora.Vec2.Type | null = null;
	let color3: Dora.Color3.Type | null = null;
	for (let [k, v] of pairs(enode.props)) {
		switch (k as keyof JSX.Node) {
			case 'ref': v.current = cnode; break;
			case 'anchorX': anchor = Dora.Vec2(v, (anchor ?? cnode.anchor).y); break;
			case 'anchorY': anchor = Dora.Vec2((anchor ?? cnode.anchor).x, v); break;
			case 'color3': color3 = Dora.Color3(v); break;
			case 'transformTarget': cnode.transformTarget = v.current; break;
			case 'onUpdate': cnode.schedule(v); break;
			case 'onActionEnd': cnode.slot(Dora.Slot.ActionEnd, v); break;
			case 'onTapFilter': cnode.slot(Dora.Slot.TapFilter, v); break;
			case 'onTapBegan': cnode.slot(Dora.Slot.TapBegan, v); break;
			case 'onTapEnded': cnode.slot(Dora.Slot.TapEnded, v); break;
			case 'onTapped': cnode.slot(Dora.Slot.Tapped, v); break;
			case 'onTapMoved': cnode.slot(Dora.Slot.TapMoved, v); break;
			case 'onMouseWheel': cnode.slot(Dora.Slot.MouseWheel, v); break;
			case 'onGesture': cnode.slot(Dora.Slot.Gesture, v); break;
			case 'onEnter': cnode.slot(Dora.Slot.Enter, v); break;
			case 'onExit': cnode.slot(Dora.Slot.Exit, v); break;
			case 'onCleanup': cnode.slot(Dora.Slot.Cleanup, v); break;
			case 'onKeyDown': cnode.slot(Dora.Slot.KeyDown, v); break;
			case 'onKeyUp': cnode.slot(Dora.Slot.KeyUp, v); break;
			case 'onKeyPressed': cnode.slot(Dora.Slot.KeyPressed, v); break;
			case 'onAttachIME': cnode.slot(Dora.Slot.AttachIME, v); break;
			case 'onDetachIME': cnode.slot(Dora.Slot.DetachIME, v); break;
			case 'onTextInput': cnode.slot(Dora.Slot.TextInput, v); break;
			case 'onTextEditing': cnode.slot(Dora.Slot.TextEditing, v); break;
			case 'onButtonDown': cnode.slot(Dora.Slot.ButtonDown, v); break;
			case 'onButtonUp': cnode.slot(Dora.Slot.ButtonUp, v); break;
			case 'onAxis': cnode.slot(Dora.Slot.Axis, v); break;
			default: {
				if (attribHandler) {
					if (!attribHandler(cnode, enode, k, v)) {
						(cnode as any)[k] = v;
					}
				} else {
					(cnode as any)[k] = v;
				}
				break;
			}
		}
	}
	if (jnode.touchEnabled !== false && (
			jnode.onTapFilter ||
			jnode.onTapBegan ||
			jnode.onTapMoved ||
			jnode.onTapEnded ||
			jnode.onTapped ||
			jnode.onMouseWheel ||
			jnode.onGesture
		)) {
		cnode.touchEnabled = true;
	}
	if (jnode.keyboardEnabled !== false && (
			jnode.onKeyDown ||
			jnode.onKeyUp ||
			jnode.onKeyPressed
		)) {
		cnode.keyboardEnabled = true;
	}
	if (jnode.controllerEnabled !== false && (
			jnode.onButtonDown ||
			jnode.onButtonUp ||
			jnode.onAxis
		)) {
		cnode.controllerEnabled = true;
	}
	if (anchor !== null) cnode.anchor = anchor;
	if (color3 !== null) cnode.color3 = color3;
	if (jnode.onMount !== undefined) {
		jnode.onMount(cnode);
	}
	return cnode;
}

let getClipNode: (this: void, enode: React.Element) => Dora.ClipNode.Type;
{
	function handleClipNodeAttribute(
		this: void,
		cnode: Dora.ClipNode.Type,
		_enode: React.Element,
		k: any, v: any
	) {
		switch (k as keyof JSX.ClipNode) {
			case 'stencil': cnode.stencil = toNode(v); return true;
		}
		return false;
	}
	getClipNode = (enode) => {
		return getNode(enode, Dora.ClipNode(), handleClipNodeAttribute) as Dora.ClipNode.Type;
	};
}

let getPlayable: (this: void, enode: React.Element, cnode?: Dora.Node.Type, attribHandler?: AttribHandler) => Dora.Playable.Type | null;
let getDragonBone: (this: void, enode: React.Element) => Dora.DragonBone.Type | null;
let getSpine: (this: void, enode: React.Element) => Dora.Spine.Type | null;
let getModel: (this: void, enode: React.Element) => Dora.Model.Type | null;
{
	function handlePlayableAttribute(this: void, cnode: Dora.Playable.Type, enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Playable) {
			case 'file': return true;
			case 'play': cnode.play(v, enode.props.loop === true); return true;
			case 'loop': return true;
			case 'onAnimationEnd': cnode.slot(Dora.Slot.AnimationEnd, v); return true;
		}
		return false;
	}
	getPlayable = (enode, cnode?, attribHandler?) => {
		attribHandler ??= handlePlayableAttribute;
		cnode = cnode ?? Dora.Playable(enode.props.file) ?? undefined;
		if (cnode !== undefined) {
			return getNode(enode, cnode, attribHandler) as Dora.Playable.Type;
		}
		return null;
	};

	function handleDragonBoneAttribute(this: void, cnode: Dora.DragonBone.Type, enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.DragonBone) {
			case 'hitTestEnabled': cnode.hitTestEnabled = true; return true;
		}
		return handlePlayableAttribute(cnode, enode, k, v);
	}
	getDragonBone = (enode: React.Element) => {
		const node = Dora.DragonBone(enode.props.file);
		if (node !== null) {
			const cnode = getPlayable(enode, node, handleDragonBoneAttribute);
			return cnode as Dora.DragonBone.Type;
		}
		return null;
	};

	function handleSpineAttribute(this: void, cnode: Dora.Spine.Type, enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Spine) {
			case 'hitTestEnabled': cnode.hitTestEnabled = true; return true;
		}
		return handlePlayableAttribute(cnode, enode, k, v);
	}
	getSpine = (enode: React.Element) => {
		const node = Dora.Spine(enode.props.file);
		if (node !== null) {
			const cnode = getPlayable(enode, node, handleSpineAttribute);
			return cnode as Dora.Spine.Type;
		}
		return null;
	};

	function handleModelAttribute(this: void, cnode: Dora.Model.Type, enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Model) {
			case 'reversed': cnode.reversed = v; return true;
		}
		return handlePlayableAttribute(cnode, enode, k, v);
	}
	getModel = (enode: React.Element) => {
		const node = Dora.Model(enode.props.file);
		if (node !== null) {
			const cnode = getPlayable(enode, node, handleModelAttribute);
			return cnode as Dora.Model.Type;
		}
		return null;
	};
}

let getDrawNode: (this: void, enode: React.Element) => Dora.DrawNode.Type;
{
	function handleDrawNodeAttribute(this: void, cnode: Dora.DrawNode.Type, _enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.DrawNode) {
			case 'depthWrite': cnode.depthWrite = v; return true;
			case 'blendFunc': cnode.blendFunc = v; return true;
		}
		return false;
	}
	getDrawNode = (enode: React.Element) => {
		const node = Dora.DrawNode();
		const cnode = getNode(enode, node, handleDrawNodeAttribute);
		const {children} = enode;
		for (let i of $range(1, children.length)) {
			const child = children[i - 1];
			if (type(child) !== "table") {
				continue;
			}
			switch (child.type as keyof JSX.IntrinsicElements) {
				case 'dot-shape': {
					const dot = child.props as JSX.Dot;
					node.drawDot(
						Dora.Vec2(dot.x ?? 0, dot.y ?? 0),
						dot.radius,
						Dora.Color(dot.color ?? 0xffffffff)
					);
					break;
				}
				case 'segment-shape': {
					const segment = child.props as JSX.Segment;
					node.drawSegment(
						Dora.Vec2(segment.startX, segment.startY),
						Dora.Vec2(segment.stopX, segment.stopY),
						segment.radius,
						Dora.Color(segment.color ?? 0xffffffff)
					);
					break;
				}
				case 'rect-shape': {
					const rect = child.props as JSX.Rectangle;
					const centerX = rect.centerX ?? 0;
					const centerY = rect.centerY ?? 0;
					const hw = rect.width / 2.0;
					const hh = rect.height / 2.0;
					node.drawPolygon(
						[
							Dora.Vec2(centerX - hw, centerY + hh),
							Dora.Vec2(centerX + hw, centerY + hh),
							Dora.Vec2(centerX + hw, centerY - hh),
							Dora.Vec2(centerX - hw, centerY - hh),
						],
						Dora.Color(rect.fillColor ?? 0xffffffff),
						rect.borderWidth ?? 0,
						Dora.Color(rect.borderColor ?? 0xffffffff)
					);
					break;
				}
				case 'polygon-shape': {
					const poly = child.props as JSX.Polygon;
					node.drawPolygon(
						poly.verts,
						Dora.Color(poly.fillColor ?? 0xffffffff),
						poly.borderWidth ?? 0,
						Dora.Color(poly.borderColor ?? 0xffffffff)
					);
					break;
				}
				case 'verts-shape': {
					const verts = child.props as JSX.Verts;
					node.drawVertices(verts.verts.map(([vert, color]) => [vert, Dora.Color(color)]));
					break;
				}
			}
		}
		return cnode as Dora.DrawNode.Type;
	};
}

let getGrid: (this: void, enode: React.Element) => Dora.Grid.Type;
{
	function handleGridAttribute(this: void, cnode: Dora.Grid.Type, _enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Grid) {
			case 'file': case 'gridX': case 'gridY': return true;
			case 'textureRect': cnode.textureRect = v; return true;
			case 'depthWrite': cnode.depthWrite = v; return true;
			case 'blendFunc': cnode.blendFunc = v; return true;
			case 'effect': cnode.effect = v; return true;
		}
		return false;
	}
	getGrid = (enode: React.Element) => {
		const grid = enode.props as JSX.Grid;
		const node = Dora.Grid(grid.file, grid.gridX, grid.gridY);
		const cnode = getNode(enode, node, handleGridAttribute);
		return cnode as Dora.Grid.Type;
	};
}

let getSprite: (this: void, enode: React.Element) => Dora.Sprite.Type | null;
{
	function handleSpriteAttribute(this: void, cnode: Dora.Sprite.Type, _enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Sprite) {
			case 'file': return true;
			case 'textureRect': cnode.textureRect = v; return true;
			case 'depthWrite': cnode.depthWrite = v; return true;
			case 'blendFunc': cnode.blendFunc = v; return true;
			case 'effect': cnode.effect = v; return true;
			case 'alphaRef': cnode.alphaRef = v; return true;
			case 'uwrap': cnode.uwrap = v; return true;
			case 'vwrap': cnode.vwrap = v; return true;
			case 'filter': cnode.filter = v; return true;
		}
		return false;
	}
	getSprite = (enode: React.Element) => {
		const sp = enode.props as JSX.Sprite;
		if (sp.file) {
			const node = Dora.Sprite(sp.file);
			if (node !== null) {
				const cnode = getNode(enode, node, handleSpriteAttribute);
				return cnode as Dora.Sprite.Type;
			}
		} else {
			const node = Dora.Sprite();
			const cnode = getNode(enode, node, handleSpriteAttribute);
			return cnode as Dora.Sprite.Type;
		}
		return null;
	};
}

let getLabel: (this: void, enode: React.Element) => Dora.Label.Type | null;
{
	function handleLabelAttribute(this: void, cnode: Dora.Label.Type, _enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Label) {
			case 'fontName': case 'fontSize': case 'text': case 'smoothLower': case 'smoothUpper': return true;
			case 'alphaRef': cnode.alphaRef = v; return true;
			case 'textWidth': cnode.textWidth = v; return true;
			case 'lineGap': cnode.lineGap = v; return true;
			case 'spacing': cnode.spacing = v; return true;
			case 'outlineColor': cnode.outlineColor = Dora.Color(v); return true;
			case 'outlineWidth': cnode.outlineWidth = v; return true;
			case 'blendFunc': cnode.blendFunc = v; return true;
			case 'depthWrite': cnode.depthWrite = v; return true;
			case 'batched': cnode.batched = v; return true;
			case 'effect': cnode.effect = v; return true;
			case 'alignment': cnode.alignment = v; return true;
		}
		return false;
	}
	getLabel = (enode: React.Element) => {
		const label = enode.props as JSX.Label;
		const node = Dora.Label(label.fontName, label.fontSize, label.sdf);
		if (node !== null) {
			if (label.smoothLower !== undefined || label.smoothUpper != undefined) {
				const {x, y} = node.smooth;
				node.smooth = Dora.Vec2(label.smoothLower ?? x, label.smoothUpper ?? y);
			}
			const cnode = getNode(enode, node, handleLabelAttribute);
			const {children} = enode;
			let text = label.text ?? '';
			for (let i of $range(1, children.length)) {
				const child = children[i - 1];
				if (type(child) !== 'table') {
					text += tostring(child);
				}
			}
			node.text = text;
			return cnode as Dora.Label.Type;
		}
		return null;
	};
}

let getLine: (this: void, enode: React.Element) => Dora.Line.Type;
{
	function handleLineAttribute(this: void, cnode: Dora.Line.Type, enode: React.Element, k: any, v: any) {
		const line = enode.props as JSX.Line;
		switch (k as keyof JSX.Line) {
			case 'verts': cnode.set(v, Dora.Color(line.lineColor ?? 0xffffffff)); return true;
			case 'depthWrite': cnode.depthWrite = v; return true;
			case 'blendFunc': cnode.blendFunc = v; return true;
		}
		return false;
	}
	getLine = (enode: React.Element) => {
		const node = Dora.Line();
		const cnode = getNode(enode, node, handleLineAttribute);
		return cnode as Dora.Line.Type;
	};
}

let getParticle: (this: void, enode: React.Element) => Dora.Particle.Type | null;
{
	function handleParticleAttribute(this: void, cnode: Dora.Particle.Type, _enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Particle) {
			case 'file': return true;
			case 'emit': if (v) {cnode.start();} return true;
			case 'onFinished': cnode.slot(Dora.Slot.Finished, v); return true;
		}
		return false;
	}
	getParticle = (enode: React.Element) => {
		const particle = enode.props as JSX.Particle;
		const node = Dora.Particle(particle.file);
		if (node !== null) {
			const cnode = getNode(enode, node, handleParticleAttribute);
			return cnode as Dora.Particle.Type;
		}
		return null;
	};
}

let getMenu: (this: void, enode: React.Element) => Dora.Menu.Type;
{
	function handleMenuAttribute(this: void, cnode: Dora.Menu.Type, _enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Menu) {
			case 'enabled': cnode.enabled = v; return true;
		}
		return false;
	}
	getMenu = (enode: React.Element) => {
		const node = Dora.Menu();
		const cnode = getNode(enode, node, handleMenuAttribute);
		return cnode as Dora.Menu.Type;
	};
}

function getPhysicsWorld(this: void, enode: React.Element) {
	const node = Dora.PhysicsWorld();
	const cnode = getNode(enode, node);
	return cnode as Dora.PhysicsWorld.Type;
};

let getBody: (this: void, enode: React.Element, world: Dora.PhysicsWorld.Type) => Dora.Body.Type;
{
	function handleBodyAttribute(this: void, cnode: Dora.Body.Type, _enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Body) {
			case 'type':
			case 'linearAcceleration':
			case 'fixedRotation':
			case 'bullet':
			case 'world':
				return true;
			case 'velocityX': cnode.velocityX = v; return true;
			case 'velocityY': cnode.velocityY = v; return true;
			case 'angularRate': cnode.angularRate = v; return true;
			case 'group': cnode.group = v; return true;
			case 'linearDamping': cnode.linearDamping = v; return true;
			case 'angularDamping': cnode.angularDamping = v; return true;
			case 'owner': cnode.owner = v; return true;
			case 'receivingContact': cnode.receivingContact = v; return true;
			case 'onBodyEnter': cnode.slot(Dora.Slot.BodyEnter, v); return true;
			case 'onBodyLeave': cnode.slot(Dora.Slot.BodyLeave, v); return true;
			case 'onContactStart': cnode.slot(Dora.Slot.ContactStart, v); return true;
			case 'onContactEnd': cnode.slot(Dora.Slot.ContactEnd, v); return true;
			case 'onContactFilter': cnode.onContactFilter(v); return true;
		}
		return false;
	}
	getBody = (enode: React.Element, world: Dora.PhysicsWorld.Type) => {
		const def = enode.props as JSX.Body;
		const bodyDef = Dora.BodyDef();
		bodyDef.type = def.type;
		if (def.angle !== undefined) bodyDef.angle = def.angle;
		if (def.angularDamping !== undefined) bodyDef.angularDamping = def.angularDamping;
		if (def.bullet !== undefined) bodyDef.bullet = def.bullet;
		if (def.fixedRotation !== undefined) bodyDef.fixedRotation = def.fixedRotation;
		bodyDef.linearAcceleration = def.linearAcceleration ?? Dora.Vec2(0, -9.8);
		if (def.linearDamping !== undefined) bodyDef.linearDamping = def.linearDamping;
		bodyDef.position = Dora.Vec2(def.x ?? 0, def.y ?? 0);
		let extraSensors: [tag: number, def: Dora.FixtureDef.Type][] | null = null;
		for (let i of $range(1, enode.children.length)) {
			const child = enode.children[i - 1];
			if (type(child) !== 'table') {
				continue;
			}
			switch (child.type as keyof JSX.IntrinsicElements) {
				case 'rect-fixture': {
					const shape = child.props as JSX.RectangleShape;
					if (shape.sensorTag !== undefined) {
						bodyDef.attachPolygonSensor(
							shape.sensorTag,
							Dora.Vec2(shape.centerX ?? 0, shape.centerY ?? 0),
							shape.width, shape.height,
							shape.angle ?? 0
						);
					} else {
						bodyDef.attachPolygon(
							Dora.Vec2(shape.centerX ?? 0, shape.centerY ?? 0),
							shape.width, shape.height,
							shape.angle ?? 0,
							shape.density ?? 1.0,
							shape.friction ?? 0.4,
							shape.restitution ?? 0
						);
					}
					break;
				}
				case 'polygon-fixture': {
					const shape = child.props as JSX.PolygonShape;
					if (shape.sensorTag !== undefined) {
						bodyDef.attachPolygonSensor(
							shape.sensorTag,
							shape.verts
						);
					} else {
						bodyDef.attachPolygon(
							shape.verts,
							shape.density ?? 1.0,
							shape.friction ?? 0.4,
							shape.restitution ?? 0
						);
					}
					break;
				}
				case 'multi-fixture': {
					const shape = child.props as JSX.MultiShape;
					if (shape.sensorTag !== undefined) {
						extraSensors ??= [];
						extraSensors.push([shape.sensorTag, Dora.BodyDef.multi(shape.verts)]);
					} else {
						bodyDef.attachMulti(
							shape.verts,
							shape.density ?? 1.0,
							shape.friction ?? 0.4,
							shape.restitution ?? 0
						);
					}
					break;
				}
				case 'disk-fixture': {
					const shape = child.props as JSX.DiskShape;
					if (shape.sensorTag !== undefined) {
						bodyDef.attachDiskSensor(
							shape.sensorTag,
							Dora.Vec2(shape.centerX ?? 0, shape.centerY ?? 0),
							shape.radius
						);
					} else {
						bodyDef.attachDisk(
							Dora.Vec2(shape.centerX ?? 0, shape.centerY ?? 0),
							shape.radius,
							shape.density ?? 1.0,
							shape.friction ?? 0.4,
							shape.restitution ?? 0
						);
					}
					break;
				}
				case 'chain-fixture': {
					const shape = child.props as JSX.ChainShape;
					if (shape.sensorTag !== undefined) {
						extraSensors ??= [];
						extraSensors.push([shape.sensorTag, Dora.BodyDef.chain(shape.verts)]);
					} else {
						bodyDef.attachChain(
							shape.verts,
							shape.friction ?? 0.4,
							shape.restitution ?? 0
						);
					}
					break;
				}
			}
		}
		const body = Dora.Body(bodyDef, world);
		if (extraSensors !== null) {
			for (let i of $range(1, extraSensors.length)) {
				const [tag, def] = extraSensors[i - 1];
				body.attachSensor(tag, def);
			}
		}
		const cnode = getNode(enode, body, handleBodyAttribute);
		if (def.receivingContact !== false && (
			def.onContactStart ||
			def.onContactEnd
		)) {
			body.receivingContact = true;
		}
		return cnode as Dora.Body.Type;
	};
}

let getCustomNode: (this: void, enode: React.Element) => Dora.Node.Type | null;
{
	function handleCustomNode(this: void, _cnode: Dora.Node.Type, _enode: React.Element, k: any, _v: any) {
		switch (k as keyof JSX.CustomNode) {
			case 'onCreate': return true;
		}
		return false;
	}
	getCustomNode = (enode: React.Element) => {
		const custom = enode.props as JSX.CustomNode;
		const node = custom.onCreate();
		if (node) {
			const cnode = getNode(enode, node, handleCustomNode);
			return cnode;
		}
		return null;
	};
}

let getAlignNode: (this: void, enode: React.Element) => Dora.AlignNode.Type;
{
	function handleAlignNode(this: void, _cnode: Dora.AlignNode.Type, _enode: React.Element, k: any, _v: any) {
		switch (k as keyof JSX.AlignNode) {
			case 'windowRoot': return true;
			case 'style': return true;
			case 'onLayout': return true;
		}
		return false;
	}
	getAlignNode = (enode: React.Element) => {
		const alignNode = enode.props as JSX.AlignNode;
		const node = Dora.AlignNode(alignNode.windowRoot);
		if (alignNode.style) {
			const items: string[] = [];
			for (let [k, v] of pairs(alignNode.style)) {
				let [name] = string.gsub(k, "%u", "-%1");
				name = name.toLowerCase();
				switch (k) {
					case 'margin': case 'padding':
					case 'border': case 'gap': {
						if (type(v) === 'table') {
							const valueStr = table.concat((v as any[]).map(item => tostring(item)), ',')
							items.push(`${name}:${valueStr}`);
						} else {
							items.push(`${name}:${v}`);
						}
						break;
					}
					default:
						items.push(`${name}:${v}`);
						break;
				}
			}
			const styleStr = table.concat(items, ';');
			node.css(styleStr);
		}
		if (alignNode.onLayout) {
			node.slot(Dora.Slot.AlignLayout, alignNode.onLayout);
		}
		const cnode = getNode(enode, node, handleAlignNode);
		return cnode as Dora.AlignNode.Type;
	};
}

function getEffekNode(this: void, enode: React.Element): Dora.EffekNode.Type {
	return getNode(enode, Dora.EffekNode()) as Dora.EffekNode.Type;
}

let getTileNode: (this: void, enode: React.Element) => Dora.TileNode.Type | null;
{
	function handleTileNodeAttribute(this: void, cnode: Dora.TileNode.Type, _enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.TileNode) {
			case 'file': case 'layers': return true;
			case 'depthWrite': cnode.depthWrite = v; return true;
			case 'blendFunc': cnode.blendFunc = v; return true;
			case 'effect': cnode.effect = v; return true;
			case 'filter': cnode.filter = v; return true;
		}
		return false;
	}
	getTileNode = (enode: React.Element) => {
		const tn = enode.props as JSX.TileNode;
		const node = tn.layers ? Dora.TileNode(tn.file, tn.layers) : Dora.TileNode(tn.file);
		if (node !== null) {
			const cnode = getNode(enode, node, handleTileNodeAttribute);
			return cnode as Dora.TileNode.Type;
		}
		return null;
	};
}

function addChild(this: void, nodeStack: Dora.Node.Type[], cnode: Dora.Node.Type, enode: React.Element) {
	if (nodeStack.length > 0) {
		const last = nodeStack[nodeStack.length - 1];
		last.addChild(cnode);
	}
	nodeStack.push(cnode);
	const {children} = enode;
	for (let i of $range(1, children.length)) {
		visitNode(nodeStack, children[i - 1], enode);
	}
	if (nodeStack.length > 1) {
		nodeStack.pop();
	}
}

type ElementMap = {
	[name in keyof JSX.IntrinsicElements]: ((this: void, nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => void) | undefined;
};

function drawNodeCheck(this: void, _nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) {
	if (parent === undefined || parent.type !== 'draw-node') {
		Warn(`tag <${enode.type}> must be placed under a <draw-node> to take effect`);
	}
}

function visitAction(this: void, actionStack: Dora.ActionDef.Type[], enode: React.Element) {
	const createAction = actionMap[enode.type];
	if (createAction !== undefined) {
		actionStack.push(createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing));
		return;
	}
	switch (enode.type as keyof JSX.IntrinsicElements) {
		case 'delay': {
			const item = enode.props as JSX.Delay;
			actionStack.push(Dora.Delay(item.time));
			break;
		}
		case 'event': {
			const item = enode.props as JSX.Event;
			actionStack.push(Dora.Event(item.name, item.param));
			break;
		}
		case 'hide': {
			actionStack.push(Dora.Hide());
			break;
		}
		case 'show': {
			actionStack.push(Dora.Show());
			break;
		}
		case 'move': {
			const item = enode.props as JSX.Move;
			actionStack.push(Dora.Move(item.time, Dora.Vec2(item.startX, item.startY), Dora.Vec2(item.stopX, item.stopY), item.easing));
			break;
		}
		case 'frame': {
			const item = enode.props as JSX.Frame;
			actionStack.push(Dora.Frame(item.file, item.time, item.frames));
			break;
		}
		case 'spawn': {
			const spawnStack: Dora.ActionDef.Type[] = [];
			for (let i of $range(1, enode.children.length)) {
				visitAction(spawnStack, enode.children[i - 1]);
			}
			actionStack.push(Dora.Spawn(...table.unpack(spawnStack)));
			break;
		}
		case 'sequence': {
			const sequenceStack: Dora.ActionDef.Type[] = [];
			for (let i of $range(1, enode.children.length)) {
				visitAction(sequenceStack, enode.children[i - 1]);
			}
			actionStack.push(Dora.Sequence(...table.unpack(sequenceStack)));
			break;
		}
		default:
			Warn(`unsupported tag <${enode.type}> under action definition`);
			break;
	}
}

function actionCheck(this: void, nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) {
	let unsupported = false;
	if (parent === undefined) {
		unsupported = true;
	} else {
		switch (parent.type) {
			case 'action': case 'spawn': case 'sequence': break;
			default: unsupported = true; break;
		}
	}
	if (unsupported) {
		if (nodeStack.length > 0) {
			const node = nodeStack[nodeStack.length - 1];
			const actionStack: Dora.ActionDef.Type[] = [];
			visitAction(actionStack, enode);
			if (actionStack.length === 1) {
				node.runAction(actionStack[0]);
			}
		} else {
			Warn(`tag <${enode.type}> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect`);
		}
	}
}

function bodyCheck(this: void, _nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) {
	if (parent === undefined || parent.type !== 'body') {
		Warn(`tag <${enode.type}> must be placed under a <body> to take effect`);
	}
}

const actionMap: {
	[name: string]: (typeof Dora.AnchorX) | undefined;
} = {
	'anchor-x': Dora.AnchorX,
	'anchor-y': Dora.AnchorY,
	'angle': Dora.Angle,
	'angle-x': Dora.AngleX,
	'angle-y': Dora.AngleY,
	'width': Dora.Width,
	'height': Dora.Height,
	'opacity': Dora.Opacity,
	'roll': Dora.Roll,
	'scale': Dora.Scale,
	'scale-x': Dora.ScaleX,
	'scale-y': Dora.ScaleY,
	'skew-x': Dora.SkewX,
	'skew-y': Dora.SkewY,
	'move-x': Dora.X,
	'move-y': Dora.Y,
	'move-z': Dora.Z,
};

const elementMap: ElementMap = {
	node: (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		addChild(nodeStack, getNode(enode), enode);
	},
	'clip-node': (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		addChild(nodeStack, getClipNode(enode), enode);
	},
	playable: (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getPlayable(enode);
		if (cnode !== null) {
			addChild(nodeStack, cnode, enode);
		}
	},
	'dragon-bone': (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getDragonBone(enode);
		if (cnode !== null) {
			addChild(nodeStack, cnode, enode);
		}
	},
	spine: (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getSpine(enode);
		if (cnode !== null) {
			addChild(nodeStack, cnode, enode);
		}
	},
	model: (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getModel(enode);
		if (cnode !== null) {
			addChild(nodeStack, cnode, enode);
		}
	},
	'draw-node': (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		addChild(nodeStack, getDrawNode(enode), enode);
	},
	'dot-shape': drawNodeCheck,
	'segment-shape': drawNodeCheck,
	'rect-shape': drawNodeCheck,
	'polygon-shape': drawNodeCheck,
	'verts-shape': drawNodeCheck,
	grid: (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		addChild(nodeStack, getGrid(enode), enode);
	},
	sprite: (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getSprite(enode);
		if (cnode !== null) {
			addChild(nodeStack, cnode, enode);
		}
	},
	label: (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getLabel(enode);
		if (cnode !== null) {
			addChild(nodeStack, cnode, enode);
		}
	},
	line: (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		addChild(nodeStack, getLine(enode), enode);
	},
	particle: (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getParticle(enode);
		if (cnode !== null) {
			addChild(nodeStack, cnode, enode);
		}
	},
	menu: (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		addChild(nodeStack, getMenu(enode), enode);
	},
	action: (_nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		if (enode.children.length === 0) {
			Warn(`<action> tag has no children`);
			return;
		}
		const action = enode.props as JSX.Action;
		if (action.ref === undefined) {
			Warn(`<action> tag has no ref`);
			return;
		}
		const actionStack: Dora.ActionDef.Type[] = [];
		for (let i of $range(1, enode.children.length)) {
			visitAction(actionStack, enode.children[i - 1]);
		}
		if (actionStack.length === 1) {
			(action.ref as any).current = actionStack[0];
		} else if (actionStack.length > 1) {
			(action.ref as any).current = Dora.Sequence(...table.unpack(actionStack));
		}
	},
	'anchor-x': actionCheck,
	'anchor-y': actionCheck,
	angle: actionCheck,
	'angle-x': actionCheck,
	'angle-y': actionCheck,
	delay: actionCheck,
	event: actionCheck,
	width: actionCheck,
	height: actionCheck,
	hide: actionCheck,
	show: actionCheck,
	move: actionCheck,
	opacity: actionCheck,
	roll: actionCheck,
	scale: actionCheck,
	'scale-x': actionCheck,
	'scale-y': actionCheck,
	'skew-x': actionCheck,
	'skew-y': actionCheck,
	'move-x': actionCheck,
	'move-y': actionCheck,
	'move-z': actionCheck,
	frame: actionCheck,
	spawn: actionCheck,
	sequence: actionCheck,
	loop: (nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		if (nodeStack.length > 0) {
			const node = nodeStack[nodeStack.length - 1];
			const actionStack: Dora.ActionDef.Type[] = [];
			for (let i of $range(1, enode.children.length)) {
				visitAction(actionStack, enode.children[i - 1]);
			}
			if (actionStack.length === 1) {
				node.runAction(actionStack[0], true);
			} else {
				const loop = enode.props as JSX.Loop;
				if (loop.spawn) {
					node.runAction(Dora.Spawn(...actionStack), true);
				} else {
					node.runAction(Dora.Sequence(...actionStack), true);
				}
			}
		} else {
			Warn(`tag <loop> must be placed under a scene node to take effect`);
		}
	},
	'physics-world': (nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		addChild(nodeStack, getPhysicsWorld(enode), enode);
	},
	contact: (nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const world = Dora.tolua.cast(nodeStack[nodeStack.length - 1], Dora.TypeName.PhysicsWorld);
		if (world !== null) {
			const contact = enode.props as JSX.Contact;
			world.setShouldContact(contact.groupA, contact.groupB, contact.enabled);
		} else {
			Warn(`tag <${enode.type}> must be placed under <physics-world> or its derivatives to take effect`);
		}
	},
	body: (nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const def = enode.props as JSX.Body;
		if (def.world) {
			addChild(nodeStack, getBody(enode, def.world), enode);
			return;
		}
		const world = Dora.tolua.cast(nodeStack[nodeStack.length - 1], Dora.TypeName.PhysicsWorld);
		if (world !== null) {
			addChild(nodeStack, getBody(enode, world), enode);
		} else {
			Warn(`tag <${enode.type}> must be placed under <physics-world> or its derivatives to take effect`);
		}
	},
	'rect-fixture': bodyCheck,
	'polygon-fixture': bodyCheck,
	'multi-fixture': bodyCheck,
	'disk-fixture': bodyCheck,
	'chain-fixture': bodyCheck,
	'distance-joint': (_nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const joint = enode.props as JSX.DistanceJoint;
		if (joint.ref === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because it has no reference`);
			return;
		}
		if (joint.bodyA.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as any).current = Dora.Joint.distance(
			joint.canCollide ?? false,
			joint.bodyA.current,
			joint.bodyB.current,
			joint.anchorA ?? Dora.Vec2.zero,
			joint.anchorB ?? Dora.Vec2.zero,
			joint.frequency ?? 0,
			joint.damping ?? 0);
	},
	'friction-joint': (_nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const joint = enode.props as JSX.FrictionJoint;
		if (joint.ref === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because it has no reference`);
			return;
		}
		if (joint.bodyA.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as any).current = Dora.Joint.friction(
			joint.canCollide ?? false,
			joint.bodyA.current,
			joint.bodyB.current,
			joint.worldPos,
			joint.maxForce,
			joint.maxTorque
		);
	},
	'gear-joint': (_nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const joint = enode.props as JSX.GearJoint;
		if (joint.ref === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because it has no reference`);
			return;
		}
		if (joint.jointA.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because jointA is invalid`);
			return;
		}
		if (joint.jointB.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because jointB is invalid`);
			return;
		}
		(joint.ref as any).current = Dora.Joint.gear(
			joint.canCollide ?? false,
			joint.jointA.current,
			joint.jointB.current,
			joint.ratio ?? 1
		);
	},
	'spring-joint': (_nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const joint = enode.props as JSX.SpringJoint;
		if (joint.ref === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because it has no reference`);
			return;
		}
		if (joint.bodyA.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as any).current = Dora.Joint.spring(
			joint.canCollide ?? false,
			joint.bodyA.current,
			joint.bodyB.current,
			joint.linearOffset,
			joint.angularOffset,
			joint.maxForce,
			joint.maxTorque,
			joint.correctionFactor ?? 1
		);
	},
	'move-joint': (_nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const joint = enode.props as JSX.MoveJoint;
		if (joint.ref === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because it has no reference`);
			return;
		}
		if (joint.body.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because body is invalid`);
			return;
		}
		(joint.ref as any).current = Dora.Joint.move(
			joint.canCollide ?? false,
			joint.body.current,
			joint.targetPos,
			joint.maxForce,
			joint.frequency,
			joint.damping ?? 0.7
		);
	},
	'prismatic-joint': (_nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const joint = enode.props as JSX.PrismaticJoint;
		if (joint.ref === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because it has no reference`);
			return;
		}
		if (joint.bodyA.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as any).current = Dora.Joint.prismatic(
			joint.canCollide ?? false,
			joint.bodyA.current,
			joint.bodyB.current,
			joint.worldPos,
			joint.axisAngle,
			joint.lowerTranslation ?? 0,
			joint.upperTranslation ?? 0,
			joint.maxMotorForce ?? 0,
			joint.motorSpeed ?? 0
		);
	},
	'pulley-joint': (_nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const joint = enode.props as JSX.PulleyJoint;
		if (joint.ref === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because it has no reference`);
			return;
		}
		if (joint.bodyA.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as any).current = Dora.Joint.pulley(
			joint.canCollide ?? false,
			joint.bodyA.current,
			joint.bodyB.current,
			joint.anchorA ?? Dora.Vec2.zero,
			joint.anchorB ?? Dora.Vec2.zero,
			joint.groundAnchorA,
			joint.groundAnchorB,
			joint.ratio ?? 1
		);
	},
	'revolute-joint': (_nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const joint = enode.props as JSX.RevoluteJoint;
		if (joint.ref === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because it has no reference`);
			return;
		}
		if (joint.bodyA.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as any).current = Dora.Joint.revolute(
			joint.canCollide ?? false,
			joint.bodyA.current,
			joint.bodyB.current,
			joint.worldPos,
			joint.lowerAngle ?? 0,
			joint.upperAngle ?? 0,
			joint.maxMotorTorque ?? 0,
			joint.motorSpeed ?? 0
		)
	},
	'rope-joint': (_nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const joint = enode.props as JSX.RopeJoint;
		if (joint.ref === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because it has no reference`);
			return;
		}
		if (joint.bodyA.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as any).current = Dora.Joint.rope(
			joint.canCollide ?? false,
			joint.bodyA.current,
			joint.bodyB.current,
			joint.anchorA ?? Dora.Vec2.zero,
			joint.anchorB ?? Dora.Vec2.zero,
			joint.maxLength ?? 0
		);
	},
	'weld-joint': (_nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const joint = enode.props as JSX.WeldJoint;
		if (joint.ref === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because it has no reference`);
			return;
		}
		if (joint.bodyA.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as any).current = Dora.Joint.weld(
			joint.canCollide ?? false,
			joint.bodyA.current,
			joint.bodyB.current,
			joint.worldPos,
			joint.frequency ?? 0,
			joint.damping ?? 0
		);
	},
	'wheel-joint': (_nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const joint = enode.props as JSX.WheelJoint;
		if (joint.ref === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because it has no reference`);
			return;
		}
		if (joint.bodyA.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as any).current = Dora.Joint.wheel(
			joint.canCollide ?? false,
			joint.bodyA.current,
			joint.bodyB.current,
			joint.worldPos,
			joint.axisAngle,
			joint.maxMotorTorque ?? 0,
			joint.motorSpeed ?? 0,
			joint.frequency ?? 0,
			joint.damping ?? 0.7
		);
	},
	'custom-node': (nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const node = getCustomNode(enode);
		if (node !== null) {
			addChild(nodeStack, node, enode);
		}
	},
	'custom-element': () => {},
	'align-node': (nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		addChild(nodeStack, getAlignNode(enode), enode);
	},
	'effek-node': (nodeStack: Dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		addChild(nodeStack, getEffekNode(enode), enode);
	},
	'effek': (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		if (nodeStack.length > 0) {
			const node = Dora.tolua.cast(nodeStack[nodeStack.length - 1], Dora.TypeName.EffekNode);
			if (node) {
				const effek = enode.props as JSX.Effek;
				const handle = node.play(effek.file, Dora.Vec2(effek.x ?? 0, effek.y ?? 0), effek.z ?? 0);
				if (handle >= 0) {
					if (effek.ref) {
						(effek.ref as any).current = handle;
					}
					if (effek.onEnd) {
						const {onEnd} = effek;
						node.slot(Dora.Slot.EffekEnd, (h) => {
							if (handle == h) {
								onEnd();
							}
						});
					}
				}
			} else {
				Warn(`tag <${enode.type}> must be placed under a <effek-node> to take effect`);
			}
		}
	},
	'tile-node': (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getTileNode(enode);
		if (cnode !== null) {
			addChild(nodeStack, cnode, enode);
		}
	},
}
function visitNode(this: void, nodeStack: Dora.Node.Type[], node: React.Element | React.Element[], parent?: React.Element) {
	if (type(node) !== "table") {
		return;
	}
	const enode = node as React.Element;
	if (enode.type === undefined) {
		const list = node as React.Element[];
		if (list.length > 0) {
			for (let i of $range(1, list.length)) {
				const stack: Dora.Node.Type[] = [];
				visitNode(stack, list[i - 1], parent);
				for (let i of $range(1, stack.length)) {
					nodeStack.push(stack[i - 1]);
				}
			}
		}
	} else {
		const handler = elementMap[enode.type as keyof JSX.IntrinsicElements];
		if (handler !== undefined) {
			handler(nodeStack, enode, parent);
		} else {
			Warn(`unsupported tag <${enode.type}>`);
		}
	}
}

export function toNode(this: void, enode: React.Element | React.Element[]): Dora.Node.Type | null {
	const nodeStack: Dora.Node.Type[] = [];
	visitNode(nodeStack, enode);
	if (nodeStack.length === 1) {
		return nodeStack[0];
	} else if (nodeStack.length > 1) {
		const node = Dora.Node();
		for (let i of $range(1, nodeStack.length)) {
			node.addChild(nodeStack[i - 1]);
		}
		return node;
	}
	return null;
}

export function useRef<T>(this: void, item?: T): JSX.Ref<T> {
	return {current: item ?? null};
}

function getPreload(this: void, preloadList: string[], node: React.Element | React.Element[]) {
	if (type(node) !== "table") {
		return;
	}
	const enode = node as React.Element;
	if (enode.type === undefined) {
		const list = node as React.Element[];
		if (list.length > 0) {
			for (let i of $range(1, list.length)) {
				getPreload(preloadList, list[i - 1]);
			}
		}
	} else {
		switch (enode.type as keyof JSX.IntrinsicElements) {
			case 'sprite':
				const sprite = enode.props as JSX.Sprite;
				if (sprite.file) {
					preloadList.push(sprite.file);
				}
				break;
			case 'playable':
				const playable = enode.props as JSX.Playable;
				preloadList.push(playable.file);
				break;
			case 'frame':
				const frame = enode.props as JSX.Frame;
				preloadList.push(frame.file);
				break;
			case 'model':
				const model = enode.props as JSX.Model;
				preloadList.push(`model:${model.file}`);
				break;
			case 'spine':
				const spine = enode.props as JSX.Spine;
				preloadList.push(`spine:${spine.file}`);
				break;
			case 'dragon-bone':
				const dragonBone = enode.props as JSX.DragonBone;
				preloadList.push(`bone:${dragonBone.file}`);
				break;
			case 'label':
				const label = enode.props as JSX.Label;
				preloadList.push(`font:${label.fontName};${label.fontSize}`);
				break;
		}
	}
	getPreload(preloadList, enode.children);
}

export function preloadAsync(this: void, enode: React.Element | React.Element[], handler?: (this: void, progress: number) => void) {
	const preloadList: string[] = [];
	getPreload(preloadList, enode);
	Dora.Cache.loadAsync(preloadList, handler);
}

export function toAction(this: void, enode: React.Element): Dora.ActionDef.Type {
	const actionDef = useRef<Dora.ActionDef.Type>();
	toNode(React.createElement('action', {ref: actionDef}, enode));
	if (!actionDef.current) error('failed to create action');
	return actionDef.current;
}
