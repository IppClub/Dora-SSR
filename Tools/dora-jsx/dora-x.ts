/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

/// <reference path="./jsx.d.ts"/>
import * as dora from 'dora';

function Warn(this: void, msg: string) {
	print(`[Dora Warning] ${msg}`);
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
			const inst = new typeName(props);
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

function getNode(this: void, enode: React.Element, cnode?: dora.Node.Type, attribHandler?: AttribHandler) {
	cnode = cnode ?? dora.Node();
	const jnode = enode.props as JSX.Node;
	let anchor: dora.Vec2.Type | null = null;
	let color3: dora.Color3.Type | null = null;
	for (let [k, v] of pairs(enode.props)) {
		switch (k as keyof JSX.Node) {
			case 'ref': v.current = cnode; break;
			case 'anchorX': anchor = dora.Vec2(v, (anchor ?? cnode.anchor).y); break;
			case 'anchorY': anchor = dora.Vec2((anchor ?? cnode.anchor).x, v); break;
			case 'color3': color3 = dora.Color3(v); break;
			case 'transformTarget': cnode.transformTarget = v.current; break;
			case 'onUpdate': cnode.schedule(v); break;
			case 'onActionEnd': cnode.slot(dora.Slot.ActionEnd, v); break;
			case 'onTapFilter': cnode.slot(dora.Slot.TapFilter, v); break;
			case 'onTapBegan': cnode.slot(dora.Slot.TapBegan, v); break;
			case 'onTapEnded': cnode.slot(dora.Slot.TapEnded, v); break;
			case 'onTapped': cnode.slot(dora.Slot.Tapped, v); break;
			case 'onTapMoved': cnode.slot(dora.Slot.TapMoved, v); break;
			case 'onMouseWheel': cnode.slot(dora.Slot.MouseWheel, v); break;
			case 'onGesture': cnode.slot(dora.Slot.Gesture, v); break;
			case 'onEnter': cnode.slot(dora.Slot.Enter, v); break;
			case 'onExit': cnode.slot(dora.Slot.Exit, v); break;
			case 'onCleanup': cnode.slot(dora.Slot.Cleanup, v); break;
			case 'onKeyDown': cnode.slot(dora.Slot.KeyDown, v); break;
			case 'onKeyUp': cnode.slot(dora.Slot.KeyUp, v); break;
			case 'onKeyPressed': cnode.slot(dora.Slot.KeyPressed, v); break;
			case 'onAttachIME': cnode.slot(dora.Slot.AttachIME, v); break;
			case 'onDetachIME': cnode.slot(dora.Slot.DetachIME, v); break;
			case 'onTextInput': cnode.slot(dora.Slot.TextInput, v); break;
			case 'onTextEditing': cnode.slot(dora.Slot.TextEditing, v); break;
			case 'onButtonDown': cnode.slot(dora.Slot.ButtonDown, v); break;
			case 'onButtonUp': cnode.slot(dora.Slot.ButtonUp, v); break;
			case 'onAxis': cnode.slot(dora.Slot.Axis, v); break;
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

let getClipNode: (this: void, enode: React.Element) => dora.ClipNode.Type;
{
	function handleClipNodeAttribute(
		this: void,
		cnode: dora.ClipNode.Type,
		_enode: React.Element,
		k: any, v: any
	) {
		switch (k as keyof JSX.ClipNode) {
			case 'stencil': cnode.stencil = toNode(v); return true;
		}
		return false;
	}
	getClipNode = (enode) => {
		return getNode(enode, dora.ClipNode(), handleClipNodeAttribute) as dora.ClipNode.Type;
	};
}

let getPlayable: (this: void, enode: React.Element, cnode?: dora.Node.Type, attribHandler?: AttribHandler) => dora.Playable.Type | null;
let getDragonBone: (this: void, enode: React.Element) => dora.DragonBone.Type | null;
let getSpine: (this: void, enode: React.Element) => dora.Spine.Type | null;
let getModel: (this: void, enode: React.Element) => dora.Model.Type | null;
{
	function handlePlayableAttribute(this: void, cnode: dora.Playable.Type, enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Playable) {
			case 'file': return true;
			case 'play': cnode.play(v, enode.props.loop === true); return true;
			case 'loop': return true;
			case 'onAnimationEnd': cnode.slot(dora.Slot.AnimationEnd, v); return true;
		}
		return false;
	}
	getPlayable = (enode, cnode?, attribHandler?) => {
		attribHandler ??= handlePlayableAttribute;
		cnode = cnode ?? dora.Playable(enode.props.file) ?? undefined;
		if (cnode !== undefined) {
			return getNode(enode, cnode, attribHandler) as dora.Playable.Type;
		}
		return null;
	};

	function handleDragonBoneAttribute(this: void, cnode: dora.DragonBone.Type, enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.DragonBone) {
			case 'showDebug': cnode.showDebug = v; return true;
			case 'hitTestEnabled': cnode.hitTestEnabled = true; return true;
		}
		return handlePlayableAttribute(cnode, enode, k, v);
	}
	getDragonBone = (enode: React.Element) => {
		const node = dora.DragonBone(enode.props.file);
		if (node !== null) {
			const cnode = getPlayable(enode, node, handleDragonBoneAttribute);
			return cnode as dora.DragonBone.Type;
		}
		return null;
	};

	function handleSpineAttribute(this: void, cnode: dora.Spine.Type, enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Spine) {
			case 'showDebug': cnode.showDebug = v; return true;
			case 'hitTestEnabled': cnode.hitTestEnabled = true; return true;
		}
		return handlePlayableAttribute(cnode, enode, k, v);
	}
	getSpine = (enode: React.Element) => {
		const node = dora.Spine(enode.props.file);
		if (node !== null) {
			const cnode = getPlayable(enode, node, handleSpineAttribute);
			return cnode as dora.Spine.Type;
		}
		return null;
	};

	function handleModelAttribute(this: void, cnode: dora.Model.Type, enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Model) {
			case 'reversed': cnode.reversed = v; return true;
		}
		return handlePlayableAttribute(cnode, enode, k, v);
	}
	getModel = (enode: React.Element) => {
		const node = dora.Model(enode.props.file);
		if (node !== null) {
			const cnode = getPlayable(enode, node, handleModelAttribute);
			return cnode as dora.Model.Type;
		}
		return null;
	};
}

let getDrawNode: (this: void, enode: React.Element) => dora.DrawNode.Type;
{
	function handleDrawNodeAttribute(this: void, cnode: dora.DrawNode.Type, _enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.DrawNode) {
			case 'depthWrite': cnode.depthWrite = v; return true;
			case 'blendFunc': cnode.blendFunc = v; return true;
		}
		return false;
	}
	getDrawNode = (enode: React.Element) => {
		const node = dora.DrawNode();
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
						dora.Vec2(dot.x, dot.y),
						dot.radius,
						dora.Color(dot.color ?? 0xffffffff)
					);
					break;
				}
				case 'segment-shape': {
					const segment = child.props as JSX.Segment;
					node.drawSegment(
						dora.Vec2(segment.startX, segment.startY),
						dora.Vec2(segment.stopX, segment.stopY),
						segment.radius,
						dora.Color(segment.color ?? 0xffffffff)
					);
					break;
				}
				case 'polygon-shape': {
					const poly = child.props as JSX.Polygon;
					node.drawPolygon(
						poly.verts,
						dora.Color(poly.fillColor ?? 0xffffffff),
						poly.borderWidth ?? 0,
						dora.Color(poly.borderColor ?? 0xffffffff)
					);
					break;
				}
				case 'verts-shape': {
					const verts = child.props as JSX.Verts;
					node.drawVertices(verts.verts.map(([vert, color]) => [vert, dora.Color(color)]));
					break;
				}
			}
		}
		return cnode as dora.DrawNode.Type;
	};
}

let getGrid: (this: void, enode: React.Element) => dora.Grid.Type;
{
	function handleGridAttribute(this: void, cnode: dora.Grid.Type, _enode: React.Element, k: any, v: any) {
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
		const node = dora.Grid(grid.file, grid.gridX, grid.gridY);
		const cnode = getNode(enode, node, handleGridAttribute);
		return cnode as dora.Grid.Type;
	};
}

let getSprite: (this: void, enode: React.Element) => dora.Sprite.Type | null;
{
	function handleSpriteAttribute(this: void, cnode: dora.Sprite.Type, _enode: React.Element, k: any, v: any) {
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
		const node = dora.Sprite(sp.file);
		if (node !== null) {
			const cnode = getNode(enode, node, handleSpriteAttribute);
			return cnode as dora.Sprite.Type;
		}
		return null;
	};
}

let getLabel: (this: void, enode: React.Element) => dora.Label.Type | null;
{
	function handleLabelAttribute(this: void, cnode: dora.Label.Type, _enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Label) {
			case 'fontName': case 'fontSize': case 'text': return true;
			case 'alphaRef': cnode.alphaRef = v; return true;
			case 'textWidth': cnode.textWidth = v; return true;
			case 'lineGap': cnode.lineGap = v; return true;
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
		const node = dora.Label(label.fontName, label.fontSize);
		if (node !== null) {
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
			return cnode as dora.Label.Type;
		}
		return null;
	};
}

let getLine: (this: void, enode: React.Element) => dora.Line.Type;
{
	function handleLineAttribute(this: void, cnode: dora.Line.Type, enode: React.Element, k: any, v: any) {
		const line = enode.props as JSX.Line;
		switch (k as keyof JSX.Line) {
			case 'verts': cnode.set(v, dora.Color(line.lineColor ?? 0xffffffff)); return true;
			case 'depthWrite': cnode.depthWrite = v; return true;
			case 'blendFunc': cnode.blendFunc = v; return true;
		}
		return false;
	}
	getLine = (enode: React.Element) => {
		const node = dora.Line();
		const cnode = getNode(enode, node, handleLineAttribute);
		return cnode as dora.Line.Type;
	};
}

let getParticle: (this: void, enode: React.Element) => dora.Particle.Type | null;
{
	function handleParticleAttribute(this: void, cnode: dora.Particle.Type, _enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Particle) {
			case 'file': return true;
			case 'emit': if (v) {cnode.start();} return true;
			case 'onFinished': cnode.slot(dora.Slot.Finished, v); return true;
		}
		return false;
	}
	getParticle = (enode: React.Element) => {
		const particle = enode.props as JSX.Particle;
		const node = dora.Particle(particle.file);
		if (node !== null) {
			const cnode = getNode(enode, node, handleParticleAttribute);
			return cnode as dora.Particle.Type;
		}
		return null;
	};
}

let getMenu: (this: void, enode: React.Element) => dora.Menu.Type;
{
	function handleMenuAttribute(this: void, cnode: dora.Menu.Type, _enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Menu) {
			case 'enabled': cnode.enabled = v; return true;
		}
		return false;
	}
	getMenu = (enode: React.Element) => {
		const node = dora.Menu();
		const cnode = getNode(enode, node, handleMenuAttribute);
		return cnode as dora.Menu.Type;
	};
}

let getPhysicsWorld: (this: void, enode: React.Element) => dora.PhysicsWorld.Type;
{
	function handlePhysicsWorldAttribute(this: void, cnode: dora.PhysicsWorld.Type, _enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.PhysicsWorld) {
			case 'showDebug': cnode.showDebug = v; return true;
		}
		return false;
	}
	getPhysicsWorld = (enode: React.Element) => {
		const node = dora.PhysicsWorld();
		const cnode = getNode(enode, node, handlePhysicsWorldAttribute);
		return cnode as dora.PhysicsWorld.Type;
	};
}

let getBody: (this: void, enode: React.Element, world: dora.PhysicsWorld.Type) => dora.Body.Type;
{
	function handleBodyAttribute(this: void, cnode: dora.Body.Type, _enode: React.Element, k: any, v: any) {
		switch (k as keyof JSX.Body) {
			case 'type':
			case 'linearAcceleration':
			case 'fixedRotation':
			case 'bullet':
				return true;
			case 'velocityX': cnode.velocityX = v; return true;
			case 'velocityY': cnode.velocityY = v; return true;
			case 'angularRate': cnode.angularRate = v; return true;
			case 'group': cnode.group = v; return true;
			case 'linearDamping': cnode.linearDamping = v; return true;
			case 'angularDamping': cnode.angularDamping = v; return true;
			case 'owner': cnode.owner = v; return true;
			case 'receivingContact': cnode.receivingContact = v; return true;
			case 'onBodyEnter': cnode.slot(dora.Slot.BodyEnter, v); return true;
			case 'onBodyLeave': cnode.slot(dora.Slot.BodyLeave, v); return true;
			case 'onContactStart': cnode.slot(dora.Slot.ContactStart, v); return true;
			case 'onContactEnd': cnode.slot(dora.Slot.ContactEnd, v); return true;
			case 'onContactFilter': cnode.onContactFilter(v); return true;
		}
		return false;
	}
	getBody = (enode: React.Element, world: dora.PhysicsWorld.Type) => {
		const def = enode.props as JSX.Body;
		const bodyDef = dora.BodyDef();
		bodyDef.type = def.type;
		if (def.angle !== undefined) bodyDef.angle = def.angle;
		if (def.angularDamping !== undefined) bodyDef.angularDamping = def.angularDamping;
		if (def.bullet !== undefined) bodyDef.bullet = def.bullet;
		if (def.fixedRotation !== undefined) bodyDef.fixedRotation = def.fixedRotation;
		if (def.linearAcceleration !== undefined) bodyDef.linearAcceleration = def.linearAcceleration;
		if (def.linearDamping !== undefined) bodyDef.linearDamping = def.linearDamping;
		bodyDef.position = dora.Vec2(def.x ?? 0, def.y ?? 0);
		let extraSensors: [tag: number, def: dora.FixtureDef.Type][] | null = null;
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
							shape.width, shape.height,
							dora.Vec2(shape.centerX ?? 0, shape.centerY ?? 0),
							shape.angle ?? 0
						);
					} else {
						bodyDef.attachPolygon(
							dora.Vec2(shape.centerX ?? 0, shape.centerY ?? 0),
							shape.width, shape.height,
							shape.angle ?? 0,
							shape.density ?? 0,
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
							shape.density ?? 0,
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
						extraSensors.push([shape.sensorTag, dora.BodyDef.multi(shape.verts)]);
					} else {
						bodyDef.attachMulti(
							shape.verts,
							shape.density ?? 0,
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
							dora.Vec2(shape.centerX ?? 0, shape.centerY ?? 0),
							shape.radius
						);
					} else {
						bodyDef.attachDisk(
							dora.Vec2(shape.centerX ?? 0, shape.centerY ?? 0),
							shape.radius,
							shape.density ?? 0,
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
						extraSensors.push([shape.sensorTag, dora.BodyDef.chain(shape.verts)]);
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
		const body = dora.Body(bodyDef, world);
		if (extraSensors !== null) {
			for (let i of $range(1, extraSensors.length)) {
				const [tag, def] = extraSensors[i - 1];
				body.attachSensor(tag, def);
			}
		}
		const cnode = getNode(enode, body, handleBodyAttribute);
		if (def.receivingContact !== false && (
			def.onBodyEnter ||
			def.onBodyLeave ||
			def.onContactStart ||
			def.onContactEnd
		)) {
			body.receivingContact = true;
		}
		return cnode as dora.Body.Type;
	};
}

function addChild(this: void, nodeStack: dora.Node.Type[], cnode: dora.Node.Type, enode: React.Element) {
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
	[name in keyof JSX.IntrinsicElements]: ((this: void, nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) => void) | undefined;
};

function drawNodeCheck(this: void, _nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) {
	if (parent === undefined || parent.type !== 'draw-node') {
		Warn(`label <${enode.type}> must be placed under a <draw-node> to take effect`);
	}
}

function actionCheck(this: void, _nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) {
	let unsupported = false;
	if (parent === undefined) {
		unsupported = true;
	} else {
		switch (enode.type) {
			case 'action': case 'spawn': case 'sequence': break;
			default: unsupported = true; break;
		}
	}
	if (unsupported) {
		Warn(`tag <${enode.type}> must be placed under <action>, <spawn> or <sequence> to take effect`);
	}
}

function bodyCheck(this: void, _nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) {
	if (parent === undefined || parent.type !== 'body') {
		Warn(`label <${enode.type}> must be placed under a <body> to take effect`);
	}
}

const actionMap: {
	[name: string]: (typeof dora.AnchorX) | undefined;
} = {
	'anchor-x': dora.AnchorX,
	'anchor-y': dora.AnchorY,
	'angle': dora.Angle,
	'angle-x': dora.AngleX,
	'angle-y': dora.AngleY,
	'width': dora.Width,
	'height': dora.Height,
	'opacity': dora.Opacity,
	'roll': dora.Roll,
	'scale': dora.Scale,
	'scale-x': dora.ScaleX,
	'scale-y': dora.ScaleY,
	'skew-x': dora.SkewX,
	'skew-y': dora.SkewY,
	'move-x': dora.X,
	'move-y': dora.Y,
	'move-z': dora.Z,
};

const elementMap: ElementMap = {
	node: (nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		addChild(nodeStack, getNode(enode), enode);
	},
	'clip-node': (nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		addChild(nodeStack, getClipNode(enode), enode);
	},
	playable: (nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getPlayable(enode);
		if (cnode !== null) {
			addChild(nodeStack, cnode, enode);
		}
	},
	'dragon-bone': (nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getDragonBone(enode);
		if (cnode !== null) {
			addChild(nodeStack, cnode, enode);
		}
	},
	spine: (nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getSpine(enode);
		if (cnode !== null) {
			addChild(nodeStack, cnode, enode);
		}
	},
	model: (nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getModel(enode);
		if (cnode !== null) {
			addChild(nodeStack, cnode, enode);
		}
	},
	'draw-node': (nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		addChild(nodeStack, getDrawNode(enode), enode);
	},
	'dot-shape': drawNodeCheck,
	'segment-shape': drawNodeCheck,
	'polygon-shape': drawNodeCheck,
	'verts-shape': drawNodeCheck,
	grid: (nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		addChild(nodeStack, getGrid(enode), enode);
	},
	sprite: (nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getSprite(enode);
		if (cnode !== null) {
			addChild(nodeStack, cnode, enode);
		}
	},
	label: (nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getLabel(enode);
		if (cnode !== null) {
			addChild(nodeStack, cnode, enode);
		}
	},
	line: (nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		addChild(nodeStack, getLine(enode), enode);
	},
	particle: (nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getParticle(enode);
		if (cnode !== null) {
			addChild(nodeStack, cnode, enode);
		}
	},
	menu: (nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		addChild(nodeStack, getMenu(enode), enode);
	},
	action: (_nodeStack: dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		if (enode.children.length === 0) return;
		const action = enode.props as JSX.Action;
		if (action.ref === undefined) return;
		function visitAction(this: void, actionStack: dora.ActionDef.Type[], enode: React.Element) {
			const createAction = actionMap[enode.type];
			if (createAction !== undefined) {
				actionStack.push(createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing));
				return;
			}
			switch (enode.type as keyof JSX.IntrinsicElements) {
				case 'delay': {
					const item = enode.props as JSX.Delay;
					actionStack.push(dora.Delay(item.time));
					return;
				}
				case 'event': {
					const item = enode.props as JSX.Event;
					actionStack.push(dora.Event(item.name, item.param));
					return;
				}
				case 'hide': {
					actionStack.push(dora.Hide());
					return;
				}
				case 'show': {
					actionStack.push(dora.Show());
					return;
				}
				case 'move': {
					const item = enode.props as JSX.Move;
					actionStack.push(dora.Move(item.time, dora.Vec2(item.startX, item.startY), dora.Vec2(item.stopX, item.stopY), item.easing));
					return;
				}
				case 'spawn': {
					const spawnStack: dora.ActionDef.Type[] = [];
					for (let i of $range(1, enode.children.length)) {
						visitAction(spawnStack, enode.children[i - 1]);
					}
					actionStack.push(dora.Spawn(...table.unpack(spawnStack)));
				}
				case 'sequence': {
					const sequenceStack: dora.ActionDef.Type[] = [];
					for (let i of $range(1, enode.children.length)) {
						visitAction(sequenceStack, enode.children[i - 1]);
					}
					actionStack.push(dora.Sequence(...table.unpack(sequenceStack)));
				}
				default:
					Warn(`unsupported tag <${enode.type}> under action definition`);
					break;
			}
		}
		const actionStack: dora.ActionDef.Type[] = [];
		for (let i of $range(1, enode.children.length)) {
			visitAction(actionStack, enode.children[i - 1]);
		}
		if (actionStack.length === 1) {
			(action.ref as any).current = actionStack[0];
		} else if (actionStack.length > 1) {
			(action.ref as any).current = dora.Sequence(...table.unpack(actionStack));
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
	spawn: actionCheck,
	sequence: actionCheck,
	'physics-world': (nodeStack: dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		addChild(nodeStack, getPhysicsWorld(enode), enode);
	},
	contact: (nodeStack: dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const world = dora.tolua.cast(nodeStack[nodeStack.length - 1], dora.TypeName.PhysicsWorld);
		if (world !== null) {
			const contact = enode.props as JSX.Contact;
			world.setShouldContact(contact.groupA, contact.groupB, contact.enabled);
		} else {
			Warn(`tag <${enode.type}> must be placed under <physics-world> or its derivatives to take effect`);
		}
	},
	body: (nodeStack: dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const world = dora.tolua.cast(nodeStack[nodeStack.length - 1], dora.TypeName.PhysicsWorld);
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
	'distance-joint': (_nodeStack: dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
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
		(joint.ref as any).current = dora.Joint.distance(
			joint.canCollide ?? false,
			joint.bodyA.current,
			joint.bodyB.current,
			joint.anchorA ?? dora.Vec2.zero,
			joint.anchorB ?? dora.Vec2.zero,
			joint.frequency ?? 0,
			joint.damping ?? 0);
	},
	'friction-joint': (_nodeStack: dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
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
		(joint.ref as any).current = dora.Joint.friction(
			joint.canCollide ?? false,
			joint.bodyA.current,
			joint.bodyB.current,
			joint.worldPos,
			joint.maxForce,
			joint.maxTorque
		);
	},
	'gear-joint': (_nodeStack: dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
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
		(joint.ref as any).current = dora.Joint.gear(
			joint.canCollide ?? false,
			joint.jointA.current,
			joint.jointB.current,
			joint.ratio ?? 1
		);
	},
	'spring-joint': (_nodeStack: dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
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
		(joint.ref as any).current = dora.Joint.spring(
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
	'move-joint': (_nodeStack: dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
		const joint = enode.props as JSX.MoveJoint;
		if (joint.ref === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because it has no reference`);
			return;
		}
		if (joint.body.current === null) {
			Warn(`not creating instance of tag <${enode.type}> because body is invalid`);
			return;
		}
		(joint.ref as any).current = dora.Joint.move(
			joint.canCollide ?? false,
			joint.body.current,
			joint.targetPos,
			joint.maxForce,
			joint.frequency,
			joint.damping ?? 0.7
		);
	},
	'prismatic-joint': (_nodeStack: dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
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
		(joint.ref as any).current = dora.Joint.prismatic(
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
	'pulley-joint': (_nodeStack: dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
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
		(joint.ref as any).current = dora.Joint.pulley(
			joint.canCollide ?? false,
			joint.bodyA.current,
			joint.bodyB.current,
			joint.anchorA ?? dora.Vec2.zero,
			joint.anchorB ?? dora.Vec2.zero,
			joint.groundAnchorA,
			joint.groundAnchorB,
			joint.ratio ?? 1
		);
	},
	'revolute-joint': (_nodeStack: dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
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
		(joint.ref as any).current = dora.Joint.revolute(
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
	'rope-joint': (_nodeStack: dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
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
		(joint.ref as any).current = dora.Joint.rope(
			joint.canCollide ?? false,
			joint.bodyA.current,
			joint.bodyB.current,
			joint.anchorA ?? dora.Vec2.zero,
			joint.anchorB ?? dora.Vec2.zero,
			joint.maxLength ?? 0
		);
	},
	'weld-joint': (_nodeStack: dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
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
		(joint.ref as any).current = dora.Joint.weld(
			joint.canCollide ?? false,
			joint.bodyA.current,
			joint.bodyB.current,
			joint.worldPos,
			joint.frequency ?? 0,
			joint.damping ?? 0
		);
	},
	'wheel-joint': (_nodeStack: dora.Node.Type[], enode: React.Element, _parent?: React.Element) => {
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
		(joint.ref as any).current = dora.Joint.wheel(
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
}
function visitNode(this: void, nodeStack: dora.Node.Type[], node: React.Element | React.Element[], parent?: React.Element) {
	if (type(node) !== "table") {
		return;
	}
	const enode = node as React.Element;
	if (enode.type === undefined) {
		const list = node as React.Element[];
		if (list.length > 0) {
			for (let i of $range(1, list.length)) {
				const stack: dora.Node.Type[] = [];
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

export function toNode(this: void, enode: React.Element | React.Element[]): dora.Node.Type | null {
	const nodeStack: dora.Node.Type[] = [];
	visitNode(nodeStack, enode);
	if (nodeStack.length === 1) {
		return nodeStack[0];
	} else if (nodeStack.length > 1) {
		const node = dora.Node();
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
				preloadList.push(sprite.file);
				break;
			case 'playable':
				const playable = enode.props as JSX.Playable;
				preloadList.push(playable.file);
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
	dora.Cache.loadAsync(preloadList, handler);
}
