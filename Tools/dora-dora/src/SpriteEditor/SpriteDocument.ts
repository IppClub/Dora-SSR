/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { defaultSpriteMotionTemplate, inferFacingDirection, isImageSpriteFacingDirection, type ImageSpriteFacingDirection } from './SpriteMotionTemplate';

export interface ImageSpriteFrameRect {
	x: number;
	y: number;
	width: number;
	height: number;
}

export interface ImageSpriteFrame {
	id: string;
	name: string;
	rect: ImageSpriteFrameRect;
	duration: number;
	pivotX: number;
	pivotY: number;
}

export interface ImageSpriteAction {
	id: string;
	name: string;
	fps: number;
	direction: ImageSpriteFacingDirection;
	image?: string;
	imageWidth: number;
	imageHeight: number;
	frames: ImageSpriteFrame[];
}

export interface ImageSpriteDocument {
	type: "dora.imageSprite";
	version: 1;
	identityReferenceImage?: string;
	motionTemplate: string;
	selectedAction: number;
	selectedFrame: number;
	actions: ImageSpriteAction[];
}

const defaultActionId = defaultSpriteMotionTemplate.id;
const defaultFrameSize = 128;
const defaultFps = 8;
const defaultFrameDuration = 1000 / defaultFps;

const createFrameId = (index: number) => `frame-${index + 1}`;

export const createEmptyImageSpriteDocument = (): ImageSpriteDocument => ({
	type: "dora.imageSprite",
	version: 1,
	motionTemplate: defaultActionId,
	selectedAction: 0,
	selectedFrame: 0,
	actions: [{
		id: defaultActionId,
		name: defaultSpriteMotionTemplate.name,
		fps: defaultFps,
		direction: defaultSpriteMotionTemplate.facing,
		imageWidth: defaultFrameSize * 4,
		imageHeight: defaultFrameSize,
		frames: Array.from({ length: 4 }, (_unused, index) => ({
			id: createFrameId(index),
			name: `idle_${index + 1}`,
			rect: {
				x: index * defaultFrameSize,
				y: 0,
				width: defaultFrameSize,
				height: defaultFrameSize,
			},
			duration: defaultFrameDuration,
			pivotX: 0.5,
			pivotY: 1,
		})),
	}],
});

const isRecord = (value: unknown): value is Record<string, unknown> => {
	return typeof value === "object" && value !== null;
};

const readNumber = (value: unknown, fallback: number) => {
	return typeof value === "number" && Number.isFinite(value) ? value : fallback;
};

const readString = (value: unknown, fallback: string) => {
	return typeof value === "string" ? value : fallback;
};

const readOptionalString = (value: unknown) => {
	return typeof value === "string" && value !== "" ? value : undefined;
};

const readFrame = (value: unknown, index: number): ImageSpriteFrame => {
	const record = isRecord(value) ? value : {};
	const rectRecord = isRecord(record.rect) ? record.rect : {};
	return {
		id: readString(record.id, createFrameId(index)),
		name: readString(record.name, `frame_${index + 1}`),
		rect: {
			x: readNumber(rectRecord.x, index * defaultFrameSize),
			y: readNumber(rectRecord.y, 0),
			width: readNumber(rectRecord.width, defaultFrameSize),
			height: readNumber(rectRecord.height, defaultFrameSize),
		},
		duration: readNumber(record.duration, defaultFrameDuration),
		pivotX: readNumber(record.pivotX, 0.5),
		pivotY: readNumber(record.pivotY, 1),
	};
};

const readAction = (value: unknown, index: number): ImageSpriteAction => {
	const fallback = createEmptyImageSpriteDocument().actions[0];
	const fallbackAction = fallback === undefined ? {
		id: defaultActionId,
		name: defaultSpriteMotionTemplate.name,
		fps: defaultFps,
		direction: defaultSpriteMotionTemplate.facing,
		imageWidth: defaultFrameSize * 4,
		imageHeight: defaultFrameSize,
		frames: [],
	} : fallback;
	const record = isRecord(value) ? value : {};
	const fallbackName = index === 0 ? defaultSpriteMotionTemplate.name : `Action ${index + 1}`;
	const actionId = readString(record.id, index === 0 ? defaultActionId : `action_${index + 1}`);
	const actionName = readString(record.name, fallbackName);
	const direction = isImageSpriteFacingDirection(record.direction) ? record.direction : inferFacingDirection(actionId, actionName);
	const framesValue = Array.isArray(record.frames) ? record.frames : fallbackAction.frames;
	const frames = framesValue.map(readFrame);
	return {
		id: actionId,
		name: actionName,
		fps: readNumber(record.fps, defaultFps),
		direction,
		image: readOptionalString(record.image),
		imageWidth: readNumber(record.imageWidth, defaultFrameSize * Math.max(1, frames.length)),
		imageHeight: readNumber(record.imageHeight, defaultFrameSize),
		frames,
	};
};

export const readImageSpriteDocument = (content: string): ImageSpriteDocument => {
	try {
		const value: unknown = JSON.parse(content);
		if (!isRecord(value) || value.type !== "dora.imageSprite") {
			return createEmptyImageSpriteDocument();
		}
		const actionsValue = Array.isArray(value.actions) ? value.actions : createEmptyImageSpriteDocument().actions;
		const actions = actionsValue.map(readAction);
		return {
			type: "dora.imageSprite",
			version: 1,
			identityReferenceImage: readOptionalString(value.identityReferenceImage),
			motionTemplate: readString(value.motionTemplate, defaultActionId),
			selectedAction: Math.max(0, Math.min(actions.length - 1, Math.round(readNumber(value.selectedAction, 0)))),
			selectedFrame: Math.max(0, Math.round(readNumber(value.selectedFrame, 0))),
			actions: actions.length === 0 ? createEmptyImageSpriteDocument().actions : actions,
		};
	} catch {
		return createEmptyImageSpriteDocument();
	}
};

export const writeImageSpriteDocument = (document: ImageSpriteDocument) => {
	return `${JSON.stringify(document, undefined, "\t")}\n`;
};

export const cloneImageSpriteDocument = (document: ImageSpriteDocument): ImageSpriteDocument => {
	return readImageSpriteDocument(writeImageSpriteDocument(document));
};

export const isImageSpriteDocumentContent = (content: string) => {
	try {
		const value: unknown = JSON.parse(content);
		return isRecord(value) && value.type === "dora.imageSprite";
	} catch {
		return false;
	}
};

export const isImageSpriteDocumentFile = (fileName: string) => fileName.toLowerCase().endsWith(".sprite.json");
