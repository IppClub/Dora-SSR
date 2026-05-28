/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

export type ImageSpriteFacingDirection = "front" | "back" | "left" | "right";

export interface SpriteMotionTemplate {
	id: string;
	name: string;
	facing: ImageSpriteFacingDirection;
	frameCount: number;
	referenceImagePath: string;
	prompt: string;
}

export const spriteMotionTemplates: SpriteMotionTemplate[] = [{
	id: "idle_front",
	name: "Idle Front",
	facing: "front",
	frameCount: 4,
	referenceImagePath: "/pixel-templates/idle_front_4_mannequin.png",
	prompt: "FRONT view, facing the camera. The face, eyes, chest/front outfit details, and both arms are visible in every frame.",
}, {
	id: "idle_back",
	name: "Idle Back",
	facing: "back",
	frameCount: 4,
	referenceImagePath: "/pixel-templates/idle_back_4_mannequin.png",
	prompt: "BACK view, facing away from the camera. The face and eyes are not visible; show the back of the head, hair, shoulders, and back outfit details in every frame.",
}, {
	id: "idle_left",
	name: "Idle Left",
	facing: "left",
	frameCount: 4,
	referenceImagePath: "/pixel-templates/idle_left_4_mannequin.png",
	prompt: "LEFT side profile, facing screen-left. The nose, body, feet, and idle pose point left in every frame; do not rotate to front or right.",
}, {
	id: "idle_right",
	name: "Idle Right",
	facing: "right",
	frameCount: 4,
	referenceImagePath: "/pixel-templates/idle_right_4_mannequin.png",
	prompt: "RIGHT side profile, facing screen-right. The nose, body, feet, and idle pose point right in every frame; do not rotate to front or left.",
}];

export const defaultSpriteMotionTemplate = spriteMotionTemplates[0];

export const isImageSpriteFacingDirection = (value: unknown): value is ImageSpriteFacingDirection => {
	return value === "front" || value === "back" || value === "left" || value === "right";
};

export const getSpriteMotionTemplate = (id: string | undefined) => {
	return spriteMotionTemplates.find((template) => template.id === id);
};

export const inferFacingDirection = (id: string | undefined, name: string | undefined): ImageSpriteFacingDirection => {
	const text = `${id ?? ""} ${name ?? ""}`.toLowerCase();
	if (text.includes("back")) return "back";
	if (text.includes("left")) return "left";
	if (text.includes("right")) return "right";
	return "front";
};

export const getSpriteMotionTemplateForAction = (templateId: string | undefined, facing: ImageSpriteFacingDirection | undefined) => {
	const template = getSpriteMotionTemplate(templateId);
	if (template !== undefined) return template;
	return spriteMotionTemplates.find((item) => item.facing === facing) ?? defaultSpriteMotionTemplate;
};
