/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

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

	function flattenChild(this: void, ch: unknown): LuaMultiReturn<[unknown, boolean]> {
		if (type(ch) !== "table") {
			return $multi(ch, true);
		}
		let child = ch as AnyTable;
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
		props: AnyTable;
		children: Element[];
	}

	export function createElement(
		typeName: unknown,
		props: AnyTable | undefined,
		...children: unknown[]
	): Element | Element[] {
		const items: unknown[] = [];
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
				return renderFunctionComponent(typeName as (this: void, props: AnyTable) => Element | Element[], props);
			}
			case 'table': {
				if (!(typeName as AnyTable).isComponent) {
					Warn('unsupported class object in element creation');
					return [];
				}
				props ??= {};
				if (props.children) {
					props.children = [...props.children, ...children];
				} else {
					props.children = children;
				}
				const inst = new (typeName as ObjectConstructor)(props) as React.Component<unknown>;
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
			return children as Element[];
		}
		return {
			type: typeName,
			props: props ?? {},
			children
		} as Element;
	}

} // namespace React

type FunctionComponentType = (this: void, props: AnyTable) => React.Element | React.Element[];

interface HookEntry<T = unknown> {
	value: T;
	deps?: unknown[];
}

interface HookFrame {
	type: unknown;
	key?: string | number;
	hooks: HookEntry[];
	hookIndex: number;
}

function renderFunctionComponent(this: void, component: FunctionComponentType, props: AnyTable): React.Element | React.Element[] {
	const frame = renderingHookRoot?.beginComponentHooks(component, props.key as string | number | undefined);
	if (frame === undefined) {
		return component(props);
	}
	const lastHookFrame = currentHookFrame;
	currentHookFrame = frame;
	try {
		return component(props);
	} finally {
		currentHookFrame = lastHookFrame;
	}
}

type AttribHandler = (this: void, cnode: unknown, enode: React.Element, k: unknown, v: unknown) => boolean;

function applyAutoEnableProps(this: void, node: Dora.Node.Type, props: AnyTable) {
	const jnode = props as JSX.Node;
	if (jnode.touchEnabled !== false && (
		jnode.onTapFilter ||
		jnode.onTapBegan ||
		jnode.onTapMoved ||
		jnode.onTapEnded ||
		jnode.onTapped ||
		jnode.onMouseWheel ||
		jnode.onGesture
	)) {
		node.touchEnabled = true;
	}
	if (jnode.keyboardEnabled !== false && (
		jnode.onKeyDown ||
		jnode.onKeyUp ||
		jnode.onKeyPressed
	)) {
		node.keyboardEnabled = true;
	}
	if (jnode.controllerEnabled !== false && (
		jnode.onButtonDown ||
		jnode.onButtonUp ||
		jnode.onAxis
	)) {
		node.controllerEnabled = true;
	}
	const body = Dora.tolua.cast(node, Dora.TypeName.Body);
	if (body !== undefined) {
		const bodyProps = props as JSX.Body;
		if (bodyProps.receivingContact !== false && (
			bodyProps.onContactStart ||
			bodyProps.onContactEnd
		)) {
			body.receivingContact = true;
		}
	}
}

function getNode(this: void, enode: React.Element, cnode?: Dora.Node.Type, attribHandler?: AttribHandler) {
	cnode = cnode ?? Dora.Node();
	const jnode = enode.props as JSX.Node;
	let anchor: Dora.Vec2.Type | undefined;
	let color3: Dora.Color3.Type | undefined;
	for (let [k, v] of pairs(enode.props as AnyTable)) {
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
			case 'onUnmount': break;
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
						(cnode as AnyTable)[k] = v;
					}
				} else {
					(cnode as AnyTable)[k] = v;
				}
				break;
			}
		}
	}
	applyAutoEnableProps(cnode, enode.props as AnyTable);
	if (anchor !== undefined) cnode.anchor = anchor;
	if (color3 !== undefined) cnode.color3 = color3;
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
		k: unknown, v: unknown
	) {
		switch (k as keyof JSX.ClipNode) {
			case 'stencil': cnode.stencil = toNode(v as React.Element); return true;
		}
		return false;
	}
	getClipNode = (enode) => {
		return getNode(enode, Dora.ClipNode(), handleClipNodeAttribute as AttribHandler) as Dora.ClipNode.Type;
	};
}

let getPlayable: (this: void, enode: React.Element, cnode?: Dora.Node.Type, attribHandler?: AttribHandler) => Dora.Playable.Type | undefined;
let getDragonBone: (this: void, enode: React.Element) => Dora.DragonBone.Type | undefined;
let getSpine: (this: void, enode: React.Element) => Dora.Spine.Type | undefined;
let getModel: (this: void, enode: React.Element) => Dora.Model.Type | undefined;
{
	function handlePlayableAttribute(this: void, cnode: Dora.Playable.Type, enode: React.Element, k: unknown, v: unknown) {
		switch (k as keyof JSX.Playable) {
			case 'file': return true;
			case 'play': cnode.play(v as string, enode.props.loop === true); return true;
			case 'loop': return true;
			case 'onAnimationEnd': cnode.slot(Dora.Slot.AnimationEnd, v as (this: void, animationName: string, target: Dora.Playable.Type) => void); return true;
		}
		return false;
	}
	getPlayable = (enode, cnode?, attribHandler?) => {
		attribHandler ??= handlePlayableAttribute as AttribHandler;
		cnode = cnode ?? Dora.Playable(enode.props.file) ?? undefined;
		if (cnode !== undefined) {
			return getNode(enode, cnode, attribHandler) as Dora.Playable.Type;
		}
		return undefined;
	};

	function handleDragonBoneAttribute(this: void, cnode: Dora.DragonBone.Type, enode: React.Element, k: unknown, v: unknown) {
		switch (k as keyof JSX.DragonBone) {
			case 'hitTestEnabled': cnode.hitTestEnabled = true; return true;
		}
		return handlePlayableAttribute(cnode, enode, k, v);
	}
	getDragonBone = (enode: React.Element) => {
		const node = Dora.DragonBone(enode.props.file);
		if (node !== undefined) {
			const cnode = getPlayable(enode, node, handleDragonBoneAttribute as AttribHandler);
			return cnode as Dora.DragonBone.Type;
		}
		return undefined;
	};

	function handleSpineAttribute(this: void, cnode: Dora.Spine.Type, enode: React.Element, k: unknown, v: unknown) {
		switch (k as keyof JSX.Spine) {
			case 'hitTestEnabled': cnode.hitTestEnabled = true; return true;
		}
		return handlePlayableAttribute(cnode, enode, k, v);
	}
	getSpine = (enode: React.Element) => {
		const node = Dora.Spine(enode.props.file);
		if (node !== undefined) {
			const cnode = getPlayable(enode, node, handleSpineAttribute as AttribHandler);
			return cnode as Dora.Spine.Type;
		}
		return undefined;
	};

	function handleModelAttribute(this: void, cnode: Dora.Model.Type, enode: React.Element, k: unknown, v: unknown) {
		switch (k as keyof JSX.Model) {
			case 'reversed': cnode.reversed = v as boolean; return true;
		}
		return handlePlayableAttribute(cnode, enode, k, v);
	}
	getModel = (enode: React.Element) => {
		const node = Dora.Model(enode.props.file);
		if (node !== undefined) {
			const cnode = getPlayable(enode, node, handleModelAttribute as AttribHandler);
			return cnode as Dora.Model.Type;
		}
		return undefined;
	};
}

let getDrawNode: (this: void, enode: React.Element) => Dora.DrawNode.Type;
{
	function handleDrawNodeAttribute(this: void, cnode: Dora.DrawNode.Type, _enode: React.Element, k: unknown, v: unknown) {
		switch (k as keyof JSX.DrawNode) {
			case 'depthWrite': cnode.depthWrite = v as boolean; return true;
			case 'blendFunc': cnode.blendFunc = v as Dora.BlendFunc.Type; return true;
		}
		return false;
	}
	getDrawNode = (enode: React.Element) => {
		const node = Dora.DrawNode();
		const cnode = getNode(enode, node, handleDrawNodeAttribute as AttribHandler);
		const { children } = enode;
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
	function handleGridAttribute(this: void, cnode: Dora.Grid.Type, _enode: React.Element, k: unknown, v: unknown) {
		switch (k as keyof JSX.Grid) {
			case 'file': case 'gridX': case 'gridY': return true;
			case 'textureRect': cnode.textureRect = v as Dora.Rect.Type; return true;
			case 'depthWrite': cnode.depthWrite = v as boolean; return true;
			case 'blendFunc': cnode.blendFunc = v as Dora.BlendFunc.Type; return true;
			case 'effect': cnode.effect = v as Dora.Effect.Type; return true;
		}
		return false;
	}
	getGrid = (enode: React.Element) => {
		const grid = enode.props as JSX.Grid;
		const node = Dora.Grid(grid.file, grid.gridX, grid.gridY);
		const cnode = getNode(enode, node, handleGridAttribute as AttribHandler);
		return cnode as Dora.Grid.Type;
	};
}

let getSprite: (this: void, enode: React.Element) => Dora.Sprite.Type | undefined;
let getVideoNode: (this: void, enode: React.Element) => Dora.VideoNode.Type | undefined;
let getTIC80Node: (this: void, enode: React.Element) => Dora.TIC80Node.Type | undefined;
{
	function handleSpriteAttribute(this: void, cnode: Dora.Sprite.Type, _enode: React.Element, k: unknown, v: unknown) {
		switch (k as keyof JSX.Sprite) {
			case 'file': return true;
			case 'textureRect': cnode.textureRect = v as Dora.Rect.Type; return true;
			case 'depthWrite': cnode.depthWrite = v as boolean; return true;
			case 'blendFunc': cnode.blendFunc = v as Dora.BlendFunc.Type; return true;
			case 'effect': cnode.effect = v as Dora.Effect.Type; return true;
			case 'alphaRef': cnode.alphaRef = v as number; return true;
			case 'uwrap': cnode.uwrap = v as Dora.TextureWrap; return true;
			case 'vwrap': cnode.vwrap = v as Dora.TextureWrap; return true;
			case 'filter': cnode.filter = v as Dora.TextureFilter; return true;
		}
		return false;
	}
	getSprite = (enode: React.Element) => {
		const sp = enode.props as JSX.Sprite;
		if (sp.file) {
			const node = Dora.Sprite(sp.file);
			if (node !== undefined) {
				const cnode = getNode(enode, node, handleSpriteAttribute as AttribHandler);
				return cnode as Dora.Sprite.Type;
			}
		} else {
			const node = Dora.Sprite();
			const cnode = getNode(enode, node, handleSpriteAttribute as AttribHandler);
			return cnode as Dora.Sprite.Type;
		}
		return undefined;
	};
	getVideoNode = (enode: React.Element) => {
		const vn = enode.props as JSX.VideoNode;
		const node = Dora.VideoNode(vn.file, vn.looped ?? false);
		if (node !== undefined) {
			const cnode = getNode(enode, node, handleSpriteAttribute as AttribHandler);
			return cnode as Dora.VideoNode.Type;
		}
		return undefined
	};
	getTIC80Node = (enode: React.Element) => {
		const tic = enode.props as JSX.TIC80Node;
		const node = Dora.TIC80Node(tic.file);
		if (node !== undefined) {
			const cnode = getNode(enode, node, handleSpriteAttribute as AttribHandler);
			return cnode as Dora.TIC80Node.Type;
		}
		return undefined
	};
}

let getAudioSource: (this: void, enode: React.Element) => Dora.AudioSource.Type | undefined;
{
	function handleAudioSourceAttribute(this: void, cnode: Dora.AudioSource.Type, enode: React.Element, k: unknown, v: unknown) {
		switch (k as keyof JSX.AudioSource) {
			case 'file': return true;
			case 'autoRemove': return true;
			case 'bus': return true;
			case 'volume': cnode.volume = v as number; return true;
			case 'pan': cnode.pan = v as number; return true;
			case 'looping': cnode.looping = v as boolean; return true;
			case 'playMode': {
				const aus = enode.props as JSX.AudioSource;
				switch (v as 'normal' | 'background' | '3D') {
					case 'normal': cnode.play(aus.delayTime ?? 0); break;
					case 'background': cnode.playBackground(); break;
					case '3D': cnode.play3D(aus.delayTime ?? 0); break;
				}
				return true;
			}
			case 'delayTime': return true;
			case 'protected': cnode.setProtected(v as boolean); return true;
			case 'loopPoint': cnode.setLoopPoint(v as number); return true;
			case 'velocity': {
				const [vx, vy, vz] = v as [number, number, number];
				cnode.setVelocity(vx, vy, vz);
				return true;
			}
			case 'minMaxDistance': {
				const [min, max] = v as [number, number];
				cnode.setMinMaxDistance(min, max);
				return true;
			}
			case 'attenuation': {
				const [model, factor] = v as [Dora.AttenuationModel, number];
				cnode.setAttenuation(model, factor);
				return true;
			}
			case 'dopplerFactor': cnode.setDopplerFactor(v as number); return true;
		}
		return false;
	}
	getAudioSource = (enode: React.Element) => {
		const aus = enode.props as JSX.AudioSource;
		const autoRemove = aus.autoRemove ?? true;
		const node = Dora.AudioSource(aus.file, autoRemove, aus.bus);
		if (node !== undefined) {
			const cnode = getNode(enode, node, handleAudioSourceAttribute as AttribHandler);
			return cnode as Dora.AudioSource.Type;
		}
		return undefined;
	};
}

let getLabel: (this: void, enode: React.Element) => Dora.Label.Type | undefined;
{
	function handleLabelAttribute(this: void, cnode: Dora.Label.Type, _enode: React.Element, k: unknown, v: unknown) {
		switch (k as keyof JSX.Label) {
			case 'fontName': case 'fontSize': case 'text': case 'smoothLower': case 'smoothUpper': return true;
			case 'alphaRef': cnode.alphaRef = v as number; return true;
			case 'textWidth': cnode.textWidth = v as number; return true;
			case 'lineGap': cnode.lineGap = v as number; return true;
			case 'spacing': cnode.spacing = v as number; return true;
			case 'outlineColor': cnode.outlineColor = Dora.Color(v as number); return true;
			case 'outlineWidth': cnode.outlineWidth = v as number; return true;
			case 'blendFunc': cnode.blendFunc = v as Dora.BlendFunc.Type; return true;
			case 'depthWrite': cnode.depthWrite = v as boolean; return true;
			case 'batched': cnode.batched = v as boolean; return true;
			case 'effect': cnode.effect = v as Dora.Effect.Type; return true;
			case 'alignment': cnode.alignment = v as Dora.TextAlign; return true;
		}
		return false;
	}
	getLabel = (enode: React.Element) => {
		const label = enode.props as JSX.Label;
		const node = Dora.Label(label.fontName, label.fontSize, label.sdf);
		if (node !== undefined) {
			if (label.smoothLower !== undefined || label.smoothUpper != undefined) {
				const { x, y } = node.smooth;
				node.smooth = Dora.Vec2(label.smoothLower ?? x, label.smoothUpper ?? y);
			}
			const cnode = getNode(enode, node, handleLabelAttribute as AttribHandler);
			const { children } = enode;
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
		return undefined;
	};
}

let getLine: (this: void, enode: React.Element) => Dora.Line.Type;
{
	function handleLineAttribute(this: void, cnode: Dora.Line.Type, enode: React.Element, k: unknown, v: unknown) {
		const line = enode.props as JSX.Line;
		switch (k as keyof JSX.Line) {
			case 'verts': cnode.set(v as Dora.Vec2.Type[], Dora.Color(line.lineColor ?? 0xffffffff)); return true;
			case 'depthWrite': cnode.depthWrite = v as boolean; return true;
			case 'blendFunc': cnode.blendFunc = v as Dora.BlendFunc.Type; return true;
		}
		return false;
	}
	getLine = (enode: React.Element) => {
		const node = Dora.Line();
		const cnode = getNode(enode, node, handleLineAttribute as AttribHandler);
		return cnode as Dora.Line.Type;
	};
}

let getParticle: (this: void, enode: React.Element) => Dora.Particle.Type | undefined;
{
	function handleParticleAttribute(this: void, cnode: Dora.Particle.Type, _enode: React.Element, k: unknown, v: unknown) {
		switch (k as keyof JSX.Particle) {
			case 'file': return true;
			case 'emit': if (v) { cnode.start(); } return true;
			case 'onFinished': cnode.slot(Dora.Slot.Finished, v as (this: void) => void); return true;
		}
		return false;
	}
	getParticle = (enode: React.Element) => {
		const particle = enode.props as JSX.Particle;
		const node = Dora.Particle(particle.file);
		if (node !== undefined) {
			const cnode = getNode(enode, node, handleParticleAttribute as AttribHandler);
			return cnode as Dora.Particle.Type;
		}
		return undefined;
	};
}

let getMenu: (this: void, enode: React.Element) => Dora.Menu.Type;
{
	function handleMenuAttribute(this: void, cnode: Dora.Menu.Type, _enode: React.Element, k: unknown, v: unknown) {
		switch (k as keyof JSX.Menu) {
			case 'enabled': cnode.enabled = v as boolean; return true;
		}
		return false;
	}
	getMenu = (enode: React.Element) => {
		const node = Dora.Menu();
		const cnode = getNode(enode, node, handleMenuAttribute as AttribHandler);
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
	function handleBodyAttribute(this: void, cnode: Dora.Body.Type, _enode: React.Element, k: unknown, v: unknown) {
		switch (k as keyof JSX.Body) {
			case 'type':
			case 'linearAcceleration':
			case 'fixedRotation':
			case 'bullet':
			case 'world':
				return true;
			case 'velocityX': cnode.velocityX = v as number; return true;
			case 'velocityY': cnode.velocityY = v as number; return true;
			case 'angularRate': cnode.angularRate = v as number; return true;
			case 'group': cnode.group = v as number; return true;
			case 'linearDamping': cnode.linearDamping = v as number; return true;
			case 'angularDamping': cnode.angularDamping = v as number; return true;
			case 'owner': cnode.owner = v as Dora.Object.Type; return true;
			case 'receivingContact': cnode.receivingContact = v as boolean; return true;
			case 'onBodyEnter': cnode.slot(Dora.Slot.BodyEnter, v as (this: void) => void); return true;
			case 'onBodyLeave': cnode.slot(Dora.Slot.BodyLeave, v as (this: void) => void); return true;
			case 'onContactStart': cnode.slot(Dora.Slot.ContactStart, v as (this: void) => void); return true;
			case 'onContactEnd': cnode.slot(Dora.Slot.ContactEnd, v as (this: void) => void); return true;
			case 'onContactFilter': cnode.onContactFilter(v as (this: void) => boolean); return true;
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
		let extraSensors: [tag: number, def: Dora.FixtureDef.Type][] | undefined;
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
		if (extraSensors !== undefined) {
			for (let i of $range(1, extraSensors.length)) {
				const [tag, def] = extraSensors[i - 1];
				body.attachSensor(tag, def);
			}
		}
		const cnode = getNode(enode, body, handleBodyAttribute as AttribHandler);
		return cnode as Dora.Body.Type;
	};
}

let getCustomNode: (this: void, enode: React.Element) => Dora.Node.Type | undefined;
{
	function handleCustomNode(this: void, _cnode: Dora.Node.Type, _enode: React.Element, k: unknown, _v: unknown) {
		switch (k as keyof JSX.CustomNode) {
			case 'onCreate': return true;
		}
		return false;
	}
	getCustomNode = (enode: React.Element) => {
		const custom = enode.props as JSX.CustomNode;
		const node = custom.onCreate();
		if (node) {
			const cnode = getNode(enode, node, handleCustomNode as AttribHandler);
			return cnode;
		}
		return undefined;
	};
}

let getAlignNode: (this: void, enode: React.Element) => Dora.AlignNode.Type;
{
	function handleAlignNode(this: void, _cnode: Dora.AlignNode.Type, _enode: React.Element, k: unknown, _v: unknown) {
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
			node.css(getAlignStyleText(alignNode.style as AnyTable));
		}
		if (alignNode.onLayout) {
			node.slot(Dora.Slot.AlignLayout, alignNode.onLayout);
		}
		const cnode = getNode(enode, node, handleAlignNode as AttribHandler);
		return cnode as Dora.AlignNode.Type;
	};
}

function getEffekNode(this: void, enode: React.Element): Dora.EffekNode.Type {
	return getNode(enode, Dora.EffekNode()) as Dora.EffekNode.Type;
}

let getTileNode: (this: void, enode: React.Element) => Dora.TileNode.Type | undefined;
{
	function handleTileNodeAttribute(this: void, cnode: Dora.TileNode.Type, _enode: React.Element, k: unknown, v: unknown) {
		switch (k as keyof JSX.TileNode) {
			case 'file': case 'layers': return true;
			case 'depthWrite': cnode.depthWrite = v as boolean; return true;
			case 'blendFunc': cnode.blendFunc = v as Dora.BlendFunc.Type; return true;
			case 'effect': cnode.effect = v as Dora.Effect.Type; return true;
			case 'filter': cnode.filter = v as Dora.TextureFilter; return true;
		}
		return false;
	}
	getTileNode = (enode: React.Element) => {
		const tn = enode.props as JSX.TileNode;
		const node = tn.layers ? Dora.TileNode(tn.file, tn.layers) : Dora.TileNode(tn.file);
		if (node !== undefined) {
			const cnode = getNode(enode, node, handleTileNodeAttribute as AttribHandler);
			return cnode as Dora.TileNode.Type;
		}
		return undefined;
	};
}

function addChild(this: void, nodeStack: Dora.Node.Type[], cnode: Dora.Node.Type, enode: React.Element) {
	if (nodeStack.length > 0) {
		const last = nodeStack[nodeStack.length - 1];
		last.addChild(cnode);
	}
	nodeStack.push(cnode);
	const { children } = enode;
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
		if (cnode !== undefined) {
			addChild(nodeStack, cnode, enode);
		}
	},
	'dragon-bone': (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getDragonBone(enode);
		if (cnode !== undefined) {
			addChild(nodeStack, cnode, enode);
		}
	},
	spine: (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getSpine(enode);
		if (cnode !== undefined) {
			addChild(nodeStack, cnode, enode);
		}
	},
	model: (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getModel(enode);
		if (cnode !== undefined) {
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
		if (cnode !== undefined) {
			addChild(nodeStack, cnode, enode);
		}
	},
	'audio-source': (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getAudioSource(enode);
		if (cnode !== undefined) {
			addChild(nodeStack, cnode, enode);
		}
	},
	'video-node': (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getVideoNode(enode);
		if (cnode !== undefined) {
			addChild(nodeStack, cnode, enode);
		}
	},
	'tic80-node': (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getTIC80Node(enode);
		if (cnode !== undefined) {
			addChild(nodeStack, cnode, enode);
		}
	},
	label: (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getLabel(enode);
		if (cnode !== undefined) {
			addChild(nodeStack, cnode, enode);
		}
	},
	line: (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		addChild(nodeStack, getLine(enode), enode);
	},
	particle: (nodeStack: Dora.Node.Type[], enode: React.Element, parent?: React.Element) => {
		const cnode = getParticle(enode);
		if (cnode !== undefined) {
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
			(action.ref as AnyTable).current = actionStack[0];
		} else if (actionStack.length > 1) {
			(action.ref as AnyTable).current = Dora.Sequence(...table.unpack(actionStack));
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
		if (world !== undefined) {
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
		if (world !== undefined) {
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
		if (joint.bodyA.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as AnyTable).current = Dora.Joint.distance(
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
		if (joint.bodyA.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as AnyTable).current = Dora.Joint.friction(
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
		if (joint.jointA.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because jointA is invalid`);
			return;
		}
		if (joint.jointB.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because jointB is invalid`);
			return;
		}
		(joint.ref as AnyTable).current = Dora.Joint.gear(
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
		if (joint.bodyA.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as AnyTable).current = Dora.Joint.spring(
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
		if (joint.body.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because body is invalid`);
			return;
		}
		(joint.ref as AnyTable).current = Dora.Joint.move(
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
		if (joint.bodyA.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as AnyTable).current = Dora.Joint.prismatic(
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
		if (joint.bodyA.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as AnyTable).current = Dora.Joint.pulley(
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
		if (joint.bodyA.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as AnyTable).current = Dora.Joint.revolute(
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
		if (joint.bodyA.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as AnyTable).current = Dora.Joint.rope(
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
		if (joint.bodyA.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as AnyTable).current = Dora.Joint.weld(
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
		if (joint.bodyA.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyA is invalid`);
			return;
		}
		if (joint.bodyB.current === undefined) {
			Warn(`not creating instance of tag <${enode.type}> because bodyB is invalid`);
			return;
		}
		(joint.ref as AnyTable).current = Dora.Joint.wheel(
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
		if (node !== undefined) {
			addChild(nodeStack, node, enode);
		}
	},
	'custom-element': () => { },
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
						(effek.ref as AnyTable).current = handle;
					}
					if (effek.onEnd) {
						const { onEnd } = effek;
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
		if (cnode !== undefined) {
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

export function toNode(this: void, enode: React.Element | React.Element[]): Dora.Node.Type | undefined {
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
	return undefined;
}

export type RenderInput = React.Element | React.Element[] | (() => React.Element | React.Element[]);

interface MountedElement {
	element: React.Element;
	node: Dora.Node.Type;
	children: MountedElement[];
}

const roots: Root[] = [];
let renderQueued = false;
let queuedRoots: Root[] = [];
let trackingRoot: Root | undefined;
let renderingHookRoot: Root | undefined;
let currentHookFrame: HookFrame | undefined;

function isElementList(this: void, node: React.Element | React.Element[]): boolean {
	return (node as React.Element).type === undefined;
}

function getElementKey(this: void, element: React.Element): string | number | undefined {
	const props = element.props as AnyTable | undefined;
	return props ? props.key as string | number | undefined : undefined;
}

function getRenderableElement(this: void, renderable: RenderInput): React.Element | React.Element[] {
	if (type(renderable) === "function") {
		return (renderable as () => React.Element | React.Element[])();
	}
	return renderable as React.Element | React.Element[];
}

function getPrimitiveLabelText(this: void, enode: React.Element): string {
	const label = enode.props as JSX.Label;
	let text = label.text ?? "";
	for (let i of $range(1, enode.children.length)) {
		const child = enode.children[i - 1];
		if (type(child) !== "table") {
			text += tostring(child);
		}
	}
	return text;
}

function isDrawShapeElement(this: void, element: React.Element): boolean {
	switch (element.type as keyof JSX.IntrinsicElements) {
		case "dot-shape":
		case "segment-shape":
		case "rect-shape":
		case "polygon-shape":
		case "verts-shape":
			return true;
	}
	return false;
}

function isBodyFixtureElement(this: void, element: React.Element): boolean {
	switch (element.type as keyof JSX.IntrinsicElements) {
		case "rect-fixture":
		case "polygon-fixture":
		case "multi-fixture":
		case "disk-fixture":
		case "chain-fixture":
			return true;
	}
	return false;
}

function isPhysicsWorldInputElement(this: void, element: React.Element): boolean {
	return element.type === "contact";
}

function isRunnableActionElement(this: void, element: React.Element): boolean {
	if (element.type === "loop") return true;
	return actionMap[element.type] !== undefined ||
		element.type === "delay" ||
		element.type === "event" ||
		element.type === "hide" ||
		element.type === "show" ||
		element.type === "move" ||
		element.type === "frame" ||
		element.type === "spawn" ||
		element.type === "sequence";
}

function shallowPropsEqual(this: void, oldProps: AnyTable, newProps: AnyTable): boolean {
	for (let [k, v] of pairs(oldProps)) {
		if (k !== "ref" && newProps[k] !== v) return false;
	}
	for (let [k, v] of pairs(newProps)) {
		if (k !== "ref" && oldProps[k] !== v) return false;
	}
	return true;
}

function collectRunnableActionElements(this: void, element: React.Element): React.Element[] {
	const actions: React.Element[] = [];
	for (let i of $range(1, element.children.length)) {
		const child = element.children[i - 1];
		if (type(child) === "table" && isRunnableActionElement(child as React.Element)) {
			actions.push(child as React.Element);
		}
	}
	return actions;
}

function collectContactElements(this: void, element: React.Element): React.Element[] {
	const contacts: React.Element[] = [];
	for (let i of $range(1, element.children.length)) {
		const child = element.children[i - 1];
		if (type(child) === "table" && isPhysicsWorldInputElement(child as React.Element)) {
			contacts.push(child as React.Element);
		}
	}
	return contacts;
}

function getContactKey(this: void, contact: JSX.Contact): string {
	return `${contact.groupA}:${contact.groupB}`;
}

function patchPhysicsWorldInputs(this: void, world: Dora.PhysicsWorld.Type, oldElement: React.Element, newElement: React.Element) {
	const oldContacts = collectContactElements(oldElement);
	const newContacts = collectContactElements(newElement);
	const oldByKey: LuaTable<string, JSX.Contact> = new LuaTable();
	const newByKey: LuaTable<string, JSX.Contact> = new LuaTable();
	for (let i of $range(1, oldContacts.length)) {
		const contact = oldContacts[i - 1].props as JSX.Contact;
		oldByKey.set(getContactKey(contact), contact);
	}
	for (let i of $range(1, newContacts.length)) {
		const contact = newContacts[i - 1].props as JSX.Contact;
		newByKey.set(getContactKey(contact), contact);
	}
	for (let i of $range(1, oldContacts.length)) {
		const oldContact = oldContacts[i - 1].props as JSX.Contact;
		const key = getContactKey(oldContact);
		const newContact = newByKey.get(key);
		if (newContact === undefined) {
			world.setShouldContact(oldContact.groupA, oldContact.groupB, true);
		} else if (oldContact.enabled !== newContact.enabled) {
			world.setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled);
		}
	}
	for (let i of $range(1, newContacts.length)) {
		const newContact = newContacts[i - 1].props as JSX.Contact;
		if (oldByKey.get(getContactKey(newContact)) === undefined) {
			world.setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled);
		}
	}
}

function actionElementEqual(this: void, oldElement: React.Element, newElement: React.Element): boolean {
	if (oldElement.type !== newElement.type) return false;
	if (!shallowPropsEqual(oldElement.props as AnyTable, newElement.props as AnyTable)) return false;
	if (oldElement.children.length !== newElement.children.length) return false;
	for (let i of $range(1, oldElement.children.length)) {
		const oldChild = oldElement.children[i - 1];
		const newChild = newElement.children[i - 1];
		if (type(oldChild) !== type(newChild)) return false;
		if (type(oldChild) === "table") {
			if (!actionElementEqual(oldChild as React.Element, newChild as React.Element)) return false;
		} else if (oldChild !== newChild) {
			return false;
		}
	}
	return true;
}

function actionChildrenEqual(this: void, oldElement: React.Element, newElement: React.Element): boolean {
	const oldActions = collectRunnableActionElements(oldElement);
	const newActions = collectRunnableActionElements(newElement);
	if (oldActions.length !== newActions.length) return false;
	for (let i of $range(1, oldActions.length)) {
		if (!actionElementEqual(oldActions[i - 1], newActions[i - 1])) return false;
	}
	return true;
}

function createActionDef(this: void, actionElement: React.Element): LuaMultiReturn<[Dora.ActionDef.Type | undefined, boolean]> {
	if (actionElement.type === "loop") {
		const actionStack: Dora.ActionDef.Type[] = [];
		for (let i of $range(1, actionElement.children.length)) {
			visitAction(actionStack, actionElement.children[i - 1]);
		}
		if (actionStack.length === 1) {
			return $multi(actionStack[0], true);
		} else if (actionStack.length > 1) {
			const loop = actionElement.props as JSX.Loop;
			return $multi(loop.spawn ? Dora.Spawn(...actionStack) : Dora.Sequence(...actionStack), true);
		}
		return $multi(undefined, true);
	}
	const actionStack: Dora.ActionDef.Type[] = [];
	visitAction(actionStack, actionElement);
	return $multi(actionStack.length === 1 ? actionStack[0] : undefined, false);
}

function structuralChildrenEqual(
	this: void,
	oldElement: React.Element,
	newElement: React.Element,
	check: (this: void, element: React.Element) => boolean
): boolean {
	const oldChildren: React.Element[] = [];
	const newChildren: React.Element[] = [];
	for (let i of $range(1, oldElement.children.length)) {
		const child = oldElement.children[i - 1];
		if (type(child) === "table" && check(child as React.Element)) {
			oldChildren.push(child as React.Element);
		}
	}
	for (let i of $range(1, newElement.children.length)) {
		const child = newElement.children[i - 1];
		if (type(child) === "table" && check(child as React.Element)) {
			newChildren.push(child as React.Element);
		}
	}
	if (oldChildren.length !== newChildren.length) return false;
	for (let i of $range(1, oldChildren.length)) {
		const oldChild = oldChildren[i - 1];
		const newChild = newChildren[i - 1];
		if (oldChild.type !== newChild.type) return false;
		if (!shallowPropsEqual(oldChild.props as AnyTable, newChild.props as AnyTable)) return false;
	}
	return true;
}

function runActionChildren(this: void, node: Dora.Node.Type, element: React.Element) {
	const actionChildren = collectRunnableActionElements(element);
	const exclusiveActions: Dora.ActionDef.Type[] = [];
	let exclusiveLoop: boolean | undefined;
	let warnedExclusiveConflict = false;
	for (let i of $range(1, actionChildren.length)) {
		const actionElement = actionChildren[i - 1];
		const [action, loop] = createActionDef(actionElement);
		if (action === undefined) continue;
		if ((actionElement.props as AnyTable).exclusive === true) {
			if (exclusiveLoop === undefined) {
				exclusiveLoop = loop;
			}
			if (exclusiveLoop === loop) {
				exclusiveActions.push(action);
			} else if (!warnedExclusiveConflict) {
				Warn(`exclusive action children on the same node can not mix <loop> and non-<loop>; ignoring conflicting exclusive actions`);
				warnedExclusiveConflict = true;
			}
		}
	}
	if (exclusiveActions.length === 1) {
		node.perform(exclusiveActions[0], exclusiveLoop === true);
	} else if (exclusiveActions.length > 1) {
		node.perform(Dora.Spawn(...exclusiveActions), exclusiveLoop === true);
	}
	for (let i of $range(1, actionChildren.length)) {
		const actionElement = actionChildren[i - 1];
		if ((actionElement.props as AnyTable).exclusive === true) continue;
		const [action, loop] = createActionDef(actionElement);
		if (action !== undefined) {
			node.runAction(action, loop);
		}
	}
}

function patchActionChildren(this: void, node: Dora.Node.Type, oldElement: React.Element, newElement: React.Element) {
	if (!actionChildrenEqual(oldElement, newElement)) {
		runActionChildren(node, newElement);
	}
}

function removeRoot(this: void, root: Root) {
	for (let i of $range(1, roots.length)) {
		if (roots[i - 1] === root) {
			table.remove(roots, i);
			break;
		}
	}
}

function toHostElement(this: void, enode: React.Element, parent?: Dora.Node.Type): React.Element {
	const hostChildren: unknown[] = [];
	const props: AnyTable = {};
	if (enode.props !== undefined) {
		for (let [k, v] of pairs(enode.props as AnyTable)) {
			props[k] = v;
		}
	}
	if (enode.type === "label") {
		for (let i of $range(1, enode.children.length)) {
			const child = enode.children[i - 1];
			if (type(child) !== "table") {
				hostChildren.push(child);
			}
		}
	} else if (enode.type === "draw-node") {
		for (let i of $range(1, enode.children.length)) {
			const child = enode.children[i - 1];
			if (type(child) === "table" && isDrawShapeElement(child as React.Element)) {
				hostChildren.push(child);
			}
		}
	} else if (enode.type === "body") {
		for (let i of $range(1, enode.children.length)) {
			const child = enode.children[i - 1];
			if (type(child) === "table" && isBodyFixtureElement(child as React.Element)) {
				hostChildren.push(child);
			}
		}
	} else if (enode.type === "physics-world") {
		for (let i of $range(1, enode.children.length)) {
			const child = enode.children[i - 1];
			if (type(child) === "table" && isPhysicsWorldInputElement(child as React.Element)) {
				hostChildren.push(child);
			}
		}
	}
	if (enode.type === "body" && (props as JSX.Body).world === undefined) {
		const world = Dora.tolua.cast(parent, Dora.TypeName.PhysicsWorld);
		if (world !== undefined) {
			(props as JSX.Body).world = world;
		}
	}
	return {
		type: enode.type,
		props,
		children: hostChildren as React.Element[],
	};
}

function createHostNode(this: void, enode: React.Element, parent?: Dora.Node.Type): Dora.Node.Type | undefined {
	const nodeStack: Dora.Node.Type[] = [];
	visitNode(nodeStack, toHostElement(enode, parent));
	if (nodeStack.length === 1) {
		return nodeStack[0];
	} else if (nodeStack.length > 1) {
		const node = Dora.Node();
		for (let i of $range(1, nodeStack.length)) {
			node.addChild(nodeStack[i - 1]);
		}
		return node;
	}
	return undefined;
}

function getElementChildren(this: void, enode: React.Element): React.Element[] {
	const children: React.Element[] = [];
	if (enode.type === "draw-node" || enode.type === "body") return children;
	for (let i of $range(1, enode.children.length)) {
		const child = enode.children[i - 1];
		if (type(child) === "table") {
			const childElement = child as React.Element;
			if (childElement.type !== undefined) {
				if (
					(enode.type !== "physics-world" || !isPhysicsWorldInputElement(childElement)) &&
					!isRunnableActionElement(childElement)
				) {
					children.push(childElement);
				}
			} else {
				const list = child as unknown as React.Element[];
				for (let j of $range(1, list.length)) {
					const item = list[j - 1];
					if (type(item) === "table" && item.type !== undefined) {
						if (
							(enode.type !== "physics-world" || !isPhysicsWorldInputElement(item)) &&
							!isRunnableActionElement(item)
						) {
							children.push(item);
						}
					}
				}
			}
		}
	}
	return children;
}

function shouldRecreate(this: void, oldElement: React.Element, newElement: React.Element): boolean {
	if (oldElement.type !== newElement.type) return true;
	if (getElementKey(oldElement) !== getElementKey(newElement)) return true;
	const oldProps = oldElement.props as AnyTable;
	const newProps = newElement.props as AnyTable;
	if (newElement.type === "draw-node") return true;
	for (let [k, v] of pairs(oldProps)) {
		if (k === "onMount" && newProps[k] !== v) {
			return true;
		}
		if (isEventProp(k) && !isPatchableEventProp(k) && newProps[k] !== v) {
			return true;
		}
	}
	for (let [k, v] of pairs(newProps)) {
		if (k === "onMount" && oldProps[k] !== v) {
			return true;
		}
		if (isEventProp(k) && !isPatchableEventProp(k) && oldProps[k] !== v) {
			return true;
		}
	}
	switch (newElement.type as keyof JSX.IntrinsicElements) {
		case "grid":
			return oldProps.file !== newProps.file || oldProps.gridX !== newProps.gridX || oldProps.gridY !== newProps.gridY;
		case "sprite":
		case "video-node":
		case "tic80-node":
		case "audio-source":
		case "particle":
		case "tile-node":
		case "playable":
		case "dragon-bone":
		case "spine":
		case "model":
			return oldProps.file !== newProps.file;
		case "label":
			return oldProps.fontName !== newProps.fontName || oldProps.fontSize !== newProps.fontSize || oldProps.sdf !== newProps.sdf;
		case "align-node":
			return oldProps.windowRoot !== newProps.windowRoot;
		case "custom-node":
			return oldProps.onCreate !== newProps.onCreate;
		case "body":
			return oldProps.type !== newProps.type ||
				oldProps.world !== newProps.world ||
				oldProps.fixedRotation !== newProps.fixedRotation ||
				oldProps.bullet !== newProps.bullet ||
				oldProps.linearAcceleration !== newProps.linearAcceleration ||
				!structuralChildrenEqual(oldElement, newElement, isBodyFixtureElement);
	}
	return false;
}

function isEventProp(this: void, key: unknown): boolean {
	return type(key) === "string" && key !== "onUnmount" && string.sub(key as string, 1, 2) === "on";
}

function getEventSlot(this: void, key: unknown): string | undefined {
	switch (key as string) {
		case "onActionEnd": return Dora.Slot.ActionEnd;
		case "onTapFilter": return Dora.Slot.TapFilter;
		case "onTapBegan": return Dora.Slot.TapBegan;
		case "onTapEnded": return Dora.Slot.TapEnded;
		case "onTapped": return Dora.Slot.Tapped;
		case "onTapMoved": return Dora.Slot.TapMoved;
		case "onMouseWheel": return Dora.Slot.MouseWheel;
		case "onGesture": return Dora.Slot.Gesture;
		case "onEnter": return Dora.Slot.Enter;
		case "onExit": return Dora.Slot.Exit;
		case "onCleanup": return Dora.Slot.Cleanup;
		case "onKeyDown": return Dora.Slot.KeyDown;
		case "onKeyUp": return Dora.Slot.KeyUp;
		case "onKeyPressed": return Dora.Slot.KeyPressed;
		case "onAttachIME": return Dora.Slot.AttachIME;
		case "onDetachIME": return Dora.Slot.DetachIME;
		case "onTextInput": return Dora.Slot.TextInput;
		case "onTextEditing": return Dora.Slot.TextEditing;
		case "onButtonDown": return Dora.Slot.ButtonDown;
		case "onButtonUp": return Dora.Slot.ButtonUp;
		case "onAxis": return Dora.Slot.Axis;
		case "onAnimationEnd": return Dora.Slot.AnimationEnd;
		case "onFinished": return Dora.Slot.Finished;
		case "onLayout": return Dora.Slot.AlignLayout;
		case "onBodyEnter": return Dora.Slot.BodyEnter;
		case "onBodyLeave": return Dora.Slot.BodyLeave;
		case "onContactStart": return Dora.Slot.ContactStart;
		case "onContactEnd": return Dora.Slot.ContactEnd;
	}
	return undefined;
}

function isPatchableEventProp(this: void, key: unknown): boolean {
	return getEventSlot(key) !== undefined || key === "onContactFilter" || key === "onUpdate";
}

function patchEventProp(this: void, node: Dora.Node.Type, key: unknown, value: unknown) {
	const slotName = getEventSlot(key);
	if (slotName === undefined) return;
	node.slot(slotName).clear();
	if (value !== undefined) {
		node.slot(slotName, value as (this: void, ...args: unknown[]) => void);
	}
}

function patchContactFilterProp(this: void, node: Dora.Node.Type, value: unknown) {
	const body = Dora.tolua.cast(node, Dora.TypeName.Body);
	if (body === undefined) return;
	if (value === undefined) {
		body.onContactFilter(() => true);
	} else {
		body.onContactFilter(value as (this: void, other: Dora.Body.Type) => boolean);
	}
}

function patchUpdateProp(this: void, node: Dora.Node.Type, value: unknown) {
	if (value === undefined) {
		node.unschedule();
	} else if (type(value) === "thread") {
		node.schedule(value as Dora.Job);
	} else {
		node.schedule(value as (this: void, deltaTime: number) => boolean);
	}
}

function clearRemovedProp(this: void, node: Dora.Node.Type, key: unknown): boolean {
	switch (key as string) {
		case "transformTarget":
		case "stencil":
			(node as AnyTable)[key as string] = undefined;
			return true;
	}
	return false;
}

function getAlignStyleText(this: void, style: AnyTable): string {
	const items: string[] = [];
	for (let [k, v] of pairs(style)) {
		let [name] = string.gsub(k as string, "%u", "-%1");
		name = name.toLowerCase();
		switch (k) {
			case 'margin': case 'padding':
			case 'border': case 'gap': {
				if (type(v) === 'table') {
					const valueStr = table.concat((v as unknown[]).map(item => tostring(item)), ',')
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
	return table.concat(items, ';');
}

function patchPlayableProps(this: void, node: Dora.Node.Type, oldProps: AnyTable, newProps: AnyTable) {
	if (newProps.play !== undefined && (oldProps.play !== newProps.play || oldProps.loop !== newProps.loop)) {
		(node as Dora.Playable.Type).play(newProps.play as string, newProps.loop === true);
	}
}

function patchAudioSourceProps(this: void, node: Dora.Node.Type, oldProps: AnyTable, newProps: AnyTable) {
	if (newProps.playMode !== undefined && (oldProps.playMode !== newProps.playMode || oldProps.delayTime !== newProps.delayTime)) {
		const audio = node as Dora.AudioSource.Type;
		switch (newProps.playMode as "normal" | "background" | "3D") {
			case "normal": audio.play(newProps.delayTime ?? 0); break;
			case "background": audio.playBackground(); break;
			case "3D": audio.play3D(newProps.delayTime ?? 0); break;
		}
	}
}

function patchParticleProps(this: void, node: Dora.Node.Type, oldProps: AnyTable, newProps: AnyTable) {
	if (newProps.emit !== undefined && oldProps.emit !== newProps.emit) {
		const particle = node as Dora.Particle.Type;
		if (newProps.emit) {
			particle.start();
		} else {
			particle.stop();
		}
	}
}

function patchAlignNodeProps(this: void, node: Dora.Node.Type, oldProps: AnyTable, newProps: AnyTable) {
	if (newProps.style !== undefined && oldProps.style !== newProps.style) {
		(node as Dora.AlignNode.Type).css(getAlignStyleText(newProps.style as AnyTable));
	}
}

function patchLineProps(this: void, node: Dora.Node.Type, oldProps: AnyTable, newProps: AnyTable) {
	if (newProps.verts !== undefined && (oldProps.verts !== newProps.verts || oldProps.lineColor !== newProps.lineColor)) {
		(node as Dora.Line.Type).set(newProps.verts as Dora.Vec2.Type[], Dora.Color(newProps.lineColor ?? 0xffffffff));
	}
}

function clearRef(this: void, props: AnyTable, node?: Dora.Node.Type) {
	const ref = props.ref as AnyTable | undefined;
	if (ref !== undefined && (node === undefined || ref.current === node)) {
		ref.current = undefined;
	}
}

function patchRef(this: void, node: Dora.Node.Type, oldProps: AnyTable, newProps: AnyTable) {
	if (oldProps.ref !== newProps.ref) {
		clearRef(oldProps, node);
		const ref = newProps.ref as AnyTable | undefined;
		if (ref !== undefined) {
			ref.current = node;
		}
	}
}

function applyProp(this: void, node: Dora.Node.Type, enode: React.Element, key: unknown, value: unknown) {
	const name = key as string;
	switch (name) {
		case "key":
		case "children":
		case "onMount":
		case "onUnmount":
			return;
		case "ref":
			(value as AnyTable).current = node;
			return;
		case "anchorX":
			node.anchor = Dora.Vec2(value as number, node.anchor.y);
			return;
		case "anchorY":
			node.anchor = Dora.Vec2(node.anchor.x, value as number);
			return;
		case "color3":
			node.color3 = Dora.Color3(value as number);
			return;
		case "transformTarget":
			node.transformTarget = (value as JSX.Ref<Dora.Node.Type>).current;
			return;
		case "outlineColor":
			(node as AnyTable)[name] = Dora.Color(value as number);
			return;
		case "smoothLower": {
			const smooth = (node as AnyTable).smooth;
			(node as AnyTable).smooth = Dora.Vec2(value as number, smooth.y);
			return;
		}
		case "smoothUpper": {
			const smooth = (node as AnyTable).smooth;
			(node as AnyTable).smooth = Dora.Vec2(smooth.x, value as number);
			return;
		}
	}
	if (isEventProp(key)) {
		if (key === "onUpdate") {
			patchUpdateProp(node, value);
		} else if (key === "onContactFilter") {
			patchContactFilterProp(node, value);
		} else if (isPatchableEventProp(key)) {
			patchEventProp(node, key, value);
		}
		return;
	}
	(node as AnyTable)[name] = value;
}

function patchProps(this: void, node: Dora.Node.Type, oldElement: React.Element, newElement: React.Element) {
	const oldProps = oldElement.props as AnyTable;
	const newProps = newElement.props as AnyTable;
	for (let [k] of pairs(oldProps)) {
		if (k === "onUpdate" && newProps[k] === undefined) {
			patchUpdateProp(node, undefined);
		} else if (k === "onContactFilter" && newProps[k] === undefined) {
			patchContactFilterProp(node, undefined);
		} else if (isPatchableEventProp(k) && newProps[k] === undefined) {
			patchEventProp(node, k, undefined);
		} else if (newProps[k] === undefined) {
			clearRemovedProp(node, k);
		}
	}
	patchRef(node, oldProps, newProps);
	for (let [k, v] of pairs(newProps)) {
		if (k !== "ref" && oldProps[k] !== v) {
			applyProp(node, newElement, k, v);
		}
	}
	if (newElement.type === "label") {
		(node as Dora.Label.Type).text = getPrimitiveLabelText(newElement);
	} else if (newElement.type === "physics-world") {
		const world = Dora.tolua.cast(node, Dora.TypeName.PhysicsWorld);
		if (world !== undefined) {
			patchPhysicsWorldInputs(world, oldElement, newElement);
		}
	} else if (
		newElement.type === "playable" ||
		newElement.type === "dragon-bone" ||
		newElement.type === "spine" ||
		newElement.type === "model"
	) {
		patchPlayableProps(node, oldProps, newProps);
	} else if (newElement.type === "audio-source") {
		patchAudioSourceProps(node, oldProps, newProps);
	} else if (newElement.type === "particle") {
		patchParticleProps(node, oldProps, newProps);
	} else if (newElement.type === "align-node") {
		patchAlignNodeProps(node, oldProps, newProps);
	} else if (newElement.type === "line") {
		patchLineProps(node, oldProps, newProps);
	}
	applyAutoEnableProps(node, newProps);
}

function addChildToParent(this: void, parent: Dora.Node.Type, node: Dora.Node.Type, props: JSX.Node) {
	if (props.tag !== undefined) {
		parent.addChild(node, props.order ?? 0, props.tag);
	} else if (props.order !== undefined) {
		parent.addChild(node, props.order);
	} else {
		parent.addChild(node);
	}
}

function mountElement(this: void, parent: Dora.Node.Type, enode: React.Element): MountedElement | undefined {
	const node = createHostNode(enode, parent);
	if (node === undefined) {
		return undefined;
	}
	if (
		enode.type === "dot-shape" ||
		enode.type === "segment-shape" ||
		enode.type === "rect-shape" ||
		enode.type === "polygon-shape" ||
		enode.type === "verts-shape"
	) {
		return undefined;
	}
	const props = enode.props as JSX.Node;
	addChildToParent(parent, node, props);
	const mounted: MountedElement = { element: enode, node, children: [] };
	runActionChildren(node, enode);
	mounted.children = reconcileChildren(node, [], getElementChildren(enode));
	return mounted;
}

function unmountElement(this: void, mounted: MountedElement) {
	for (let i of $range(1, mounted.children.length)) {
		unmountElement(mounted.children[i - 1]);
	}
	const props = mounted.element.props as JSX.Node;
	if (props.onUnmount !== undefined) {
		props.onUnmount(mounted.node);
	}
	clearRef(mounted.element.props as AnyTable, mounted.node);
	mounted.node.removeFromParent(true);
}

function reconcileElement(this: void, parent: Dora.Node.Type, oldMounted: MountedElement | undefined, newElement: React.Element): MountedElement | undefined {
	if (oldMounted === undefined) {
		return mountElement(parent, newElement);
	}
	if (shouldRecreate(oldMounted.element, newElement)) {
		const oldNode = oldMounted.node;
		const oldOrder = oldNode.order;
		const oldTag = oldNode.tag;
		unmountElement(oldMounted);
		const mounted = mountElement(parent, newElement);
		if (mounted !== undefined) {
			mounted.node.order = (newElement.props as JSX.Node).order ?? oldOrder;
			mounted.node.tag = (newElement.props as JSX.Node).tag ?? oldTag;
		}
		return mounted;
	}
	patchProps(oldMounted.node, oldMounted.element, newElement);
	patchActionChildren(oldMounted.node, oldMounted.element, newElement);
	oldMounted.children = reconcileChildren(oldMounted.node, oldMounted.children, getElementChildren(newElement));
	oldMounted.element = newElement;
	return oldMounted;
}

function reconcileChildren(this: void, parent: Dora.Node.Type, oldChildren: MountedElement[], newElements: React.Element[]): MountedElement[] {
	const oldByKey: LuaTable<string | number, MountedElement> = new LuaTable();
	const usedOld: LuaTable<MountedElement, boolean> = new LuaTable();
	for (let i of $range(1, oldChildren.length)) {
		const oldChild = oldChildren[i - 1];
		const key = getElementKey(oldChild.element);
		if (key !== undefined) {
			oldByKey.set(key, oldChild);
		}
	}
	const nextChildren: MountedElement[] = [];
	for (let i of $range(1, newElements.length)) {
		const newElement = newElements[i - 1];
		const key = getElementKey(newElement);
		let oldChild: MountedElement | undefined;
		if (key !== undefined) {
			oldChild = oldByKey.get(key);
		} else {
			oldChild = oldChildren[i - 1];
			if (oldChild !== undefined && getElementKey(oldChild.element) !== undefined) {
				oldChild = undefined;
			}
		}
		const mounted = reconcileElement(parent, oldChild, newElement);
		if (mounted !== undefined) {
			usedOld.set(mounted, true);
			nextChildren.push(mounted);
			const props = newElement.props as JSX.Node;
			mounted.node.order = props.order ?? i;
			if (props.tag !== undefined) mounted.node.tag = props.tag;
		}
	}
	for (let i of $range(1, oldChildren.length)) {
		const oldChild = oldChildren[i - 1];
		if (!usedOld.get(oldChild)) {
			unmountElement(oldChild);
		}
	}
	return nextChildren;
}

function toElementList(this: void, node: React.Element | React.Element[]): React.Element[] {
	if (isElementList(node)) {
		return node as React.Element[];
	}
	return [node as React.Element];
}

function scheduleRootRender(this: void, root: Root) {
	if (!root.active) return;
	for (let i of $range(1, queuedRoots.length)) {
		if (queuedRoots[i - 1] === root) return;
	}
	queuedRoots.push(root);
	if (renderQueued) return;
	renderQueued = true;
	Dora.Director.systemScheduler.schedule(Dora.once(() => {
		renderQueued = false;
		const updatingRoots = queuedRoots;
		queuedRoots = [];
		for (let i of $range(1, updatingRoots.length)) {
			updatingRoots[i - 1].update();
		}
	}));
}

export class Root {
	private mounted: MountedElement[] = [];
	private renderable?: RenderInput;
	private signals: Signal<unknown>[] = [];
	private hookFrames: HookFrame[] = [];
	private hookFrameIndex = 0;
	active = true;

	constructor(private parent: Dora.Node.Type) { }

	render(this: Root, enode: RenderInput): void {
		if (!this.active) {
			roots.push(this);
			this.active = true;
		}
		this.renderable = enode;
		this.update();
	}

	update(this: Root): void {
		if (!this.active || this.renderable === undefined) return;
		this.unsubscribeSignals();
		const lastTrackingRoot = trackingRoot;
		const lastRenderingHookRoot = renderingHookRoot;
		trackingRoot = this;
		renderingHookRoot = this;
		let elements: React.Element | React.Element[];
		try {
			this.beginHookRender();
			elements = getRenderableElement(this.renderable);
		} finally {
			this.finishHookRender();
			trackingRoot = lastTrackingRoot;
			renderingHookRoot = lastRenderingHookRoot;
		}
		this.mounted = reconcileChildren(this.parent, this.mounted, toElementList(elements));
	}

	unmount(this: Root): void {
		for (let i of $range(1, this.mounted.length)) {
			unmountElement(this.mounted[i - 1]);
		}
		this.mounted = [];
		this.renderable = undefined;
		this.hookFrames = [];
		this.hookFrameIndex = 0;
		this.unsubscribeSignals();
		if (this.active) {
			removeRoot(this);
			this.active = false;
		}
	}

	trackSignal(this: Root, signal: Signal<unknown>): void {
		for (let i of $range(1, this.signals.length)) {
			if (this.signals[i - 1] === signal) return;
		}
		this.signals.push(signal);
		signal.addRoot(this);
	}

	beginComponentHooks(this: Root, type: unknown, key?: string | number): HookFrame {
		const index = this.hookFrameIndex;
		this.hookFrameIndex += 1;
		let frame = this.hookFrames[index];
		if (frame === undefined || frame.type !== type || frame.key !== key) {
			frame = { type, key, hooks: [], hookIndex: 0 };
			this.hookFrames[index] = frame;
		}
		frame.hookIndex = 0;
		return frame;
	}

	private beginHookRender(this: Root): void {
		this.hookFrameIndex = 0;
	}

	private finishHookRender(this: Root): void {
		while (this.hookFrames.length > this.hookFrameIndex) {
			this.hookFrames.pop();
		}
	}

	private unsubscribeSignals(this: Root): void {
		for (let i of $range(1, this.signals.length)) {
			this.signals[i - 1].removeRoot(this);
		}
		this.signals = [];
	}
}

export function createRoot(this: void, parent: Dora.Node.Type): Root {
	const root = new Root(parent);
	roots.push(root);
	return root;
}

export class Signal<T> {
	private roots: Root[] = [];

	constructor(private item: T) { }

	get value(): T {
		if (trackingRoot !== undefined) {
			trackingRoot.trackSignal(this as unknown as Signal<unknown>);
		}
		return this.item;
	}

	set value(value: T) {
		if (this.item === value) return;
		this.item = value;
		for (let i of $range(1, this.roots.length)) {
			scheduleRootRender(this.roots[i - 1]);
		}
	}

	addRoot(this: Signal<T>, root: Root): void {
		for (let i of $range(1, this.roots.length)) {
			if (this.roots[i - 1] === root) return;
		}
		this.roots.push(root);
	}

	removeRoot(this: Signal<T>, root: Root): void {
		for (let i of $range(1, this.roots.length)) {
			if (this.roots[i - 1] === root) {
				table.remove(this.roots, i);
				break;
			}
		}
	}
}

export function signal<T>(this: void, value: T): Signal<T> {
	return new Signal(value);
}

export function reference<T>(this: void, item?: T): JSX.Ref<T> {
	return { current: item ?? undefined };
}

function hookDepsEqual(this: void, oldDeps: unknown[] | undefined, newDeps: unknown[] | undefined): boolean {
	if (oldDeps === undefined || newDeps === undefined) return false;
	if (oldDeps.length !== newDeps.length) return false;
	for (let i of $range(1, oldDeps.length)) {
		if (oldDeps[i - 1] !== newDeps[i - 1]) return false;
	}
	return true;
}

function copyDeps(this: void, deps: unknown[] | undefined): unknown[] | undefined {
	if (deps === undefined) return undefined;
	const copied: unknown[] = [];
	for (let i of $range(1, deps.length)) {
		copied.push(deps[i - 1]);
	}
	return copied;
}

export function useMemo<T>(this: void, factory: (this: void) => T, deps?: unknown[]): T {
	const frame = currentHookFrame;
	if (frame === undefined) {
		error("useMemo() can only be called inside a function component");
	}
	const index = frame.hookIndex;
	frame.hookIndex += 1;
	let hook = frame.hooks[index] as HookEntry<T> | undefined;
	if (hook === undefined || !hookDepsEqual(hook.deps, deps)) {
		hook = { value: factory(), deps: copyDeps(deps) };
		frame.hooks[index] = hook;
	}
	return hook.value;
}

export function useCallback<T extends Function>(this: void, callback: T, deps?: unknown[]): T {
	return useMemo(() => callback, deps);
}

export function useRef<T>(this: void, item?: T): JSX.Ref<T> {
	if (currentHookFrame === undefined) {
		error("useRef() can only be called inside a function component");
	}
	return useMemo(() => reference(item), []);
}

export function useSignal<T>(this: void, value: T): Signal<T> {
	if (currentHookFrame === undefined) {
		error("useSignal() can only be called inside a function component");
	}
	return useMemo(() => signal(value), []);
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
	const actionDef = reference<Dora.ActionDef.Type>();
	toNode(React.createElement('action', { ref: actionDef }, enode));
	if (!actionDef.current) error('failed to create action');
	return actionDef.current;
}
