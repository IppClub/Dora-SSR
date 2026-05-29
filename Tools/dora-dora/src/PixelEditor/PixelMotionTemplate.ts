/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

export type PixelMotionDirection = "side" | "front" | "topdown";
export type PixelMotionCategory = "idle" | "walk" | "run" | "attack" | "hurt" | "death";

export interface PixelMotionFrame {
	name: string;
	prompt: string;
	bodyOffsetX: number;
	bodyOffsetY: number;
	footAnchorX: number;
	footAnchorY: number;
}

export interface PixelMotionTemplate {
	id: string;
	name: string;
	category: PixelMotionCategory;
	direction: PixelMotionDirection;
	fps: number;
	frameCount: number;
	description: string;
	frames: PixelMotionFrame[];
}

export const defaultPixelMotionTemplateId = "idle_side_4";

export const pixelMotionTemplates: PixelMotionTemplate[] = [
	{
		id: "idle_side_4",
		name: "Side Idle 4 Frames",
		category: "idle",
		direction: "side",
		fps: 6,
		frameCount: 4,
		description: "Small breathing loop for a side-view character standing in place.",
		frames: [
			{
				name: "idle_neutral",
				prompt: "side view idle frame, relaxed standing pose, arms at rest, neutral body height",
				bodyOffsetX: 0,
				bodyOffsetY: 0,
				footAnchorX: 16,
				footAnchorY: 30,
			},
			{
				name: "idle_breathe_up",
				prompt: "side view idle frame, subtle breathing up pose, chest slightly raised, head slightly lifted",
				bodyOffsetX: 0,
				bodyOffsetY: -1,
				footAnchorX: 16,
				footAnchorY: 30,
			},
			{
				name: "idle_neutral_return",
				prompt: "side view idle frame, relaxed standing pose returning to neutral, arms at rest",
				bodyOffsetX: 0,
				bodyOffsetY: 0,
				footAnchorX: 16,
				footAnchorY: 30,
			},
			{
				name: "idle_breathe_down",
				prompt: "side view idle frame, subtle breathing down pose, shoulders slightly lower, stable feet",
				bodyOffsetX: 0,
				bodyOffsetY: 1,
				footAnchorX: 16,
				footAnchorY: 30,
			},
		],
	},
	{
		id: "walk_side_4",
		name: "Side Walk 4 Frames",
		category: "walk",
		direction: "side",
		fps: 8,
		frameCount: 4,
		description: "Classic four-frame walk cycle with opposing arm and leg swing.",
		frames: [
			{
				name: "contact_left",
				prompt: "side view walking frame, left foot forward, right foot back, right arm forward, left arm back",
				bodyOffsetX: 0,
				bodyOffsetY: 0,
				footAnchorX: 16,
				footAnchorY: 30,
			},
			{
				name: "passing_left",
				prompt: "side view walking passing pose, both feet near center, body slightly lifted, arms crossing center",
				bodyOffsetX: 0,
				bodyOffsetY: -1,
				footAnchorX: 16,
				footAnchorY: 29,
			},
			{
				name: "contact_right",
				prompt: "side view walking frame, right foot forward, left foot back, left arm forward, right arm back",
				bodyOffsetX: 0,
				bodyOffsetY: 0,
				footAnchorX: 16,
				footAnchorY: 30,
			},
			{
				name: "passing_right",
				prompt: "side view walking passing pose, both feet near center, body slightly lowered, arms crossing center",
				bodyOffsetX: 0,
				bodyOffsetY: 1,
				footAnchorX: 16,
				footAnchorY: 30,
			},
		],
	},
	{
		id: "run_side_6",
		name: "Side Run 6 Frames",
		category: "run",
		direction: "side",
		fps: 12,
		frameCount: 6,
		description: "Fast side-view run with airborne frames and stronger body lean.",
		frames: [
			{
				name: "run_push_left",
				prompt: "side view running frame, left foot pushing off behind, right knee forward, body leaning forward",
				bodyOffsetX: 1,
				bodyOffsetY: 0,
				footAnchorX: 16,
				footAnchorY: 30,
			},
			{
				name: "run_air_left",
				prompt: "side view running airborne frame, both feet off ground, right knee forward, arms pumping strongly",
				bodyOffsetX: 1,
				bodyOffsetY: -2,
				footAnchorX: 16,
				footAnchorY: 28,
			},
			{
				name: "run_land_right",
				prompt: "side view running landing frame, right foot contacting ground forward, left leg trailing behind",
				bodyOffsetX: 1,
				bodyOffsetY: 0,
				footAnchorX: 16,
				footAnchorY: 30,
			},
			{
				name: "run_push_right",
				prompt: "side view running frame, right foot pushing off behind, left knee forward, body leaning forward",
				bodyOffsetX: 1,
				bodyOffsetY: 0,
				footAnchorX: 16,
				footAnchorY: 30,
			},
			{
				name: "run_air_right",
				prompt: "side view running airborne frame, both feet off ground, left knee forward, arms pumping strongly",
				bodyOffsetX: 1,
				bodyOffsetY: -2,
				footAnchorX: 16,
				footAnchorY: 28,
			},
			{
				name: "run_land_left",
				prompt: "side view running landing frame, left foot contacting ground forward, right leg trailing behind",
				bodyOffsetX: 1,
				bodyOffsetY: 0,
				footAnchorX: 16,
				footAnchorY: 30,
			},
		],
	},
	{
		id: "attack_side_4",
		name: "Side Attack 4 Frames",
		category: "attack",
		direction: "side",
		fps: 10,
		frameCount: 4,
		description: "Anticipation, strike, impact, and recovery for a side-view melee attack.",
		frames: [
			{
				name: "attack_anticipation",
				prompt: "side view attack anticipation frame, body pulled back, weapon or arm raised, knees bent",
				bodyOffsetX: -1,
				bodyOffsetY: 0,
				footAnchorX: 15,
				footAnchorY: 30,
			},
			{
				name: "attack_swing",
				prompt: "side view attack swing frame, body lunging forward, weapon or arm sweeping forward, strong motion arc",
				bodyOffsetX: 2,
				bodyOffsetY: -1,
				footAnchorX: 16,
				footAnchorY: 29,
			},
			{
				name: "attack_impact",
				prompt: "side view attack impact frame, full extension forward, weapon or fist at farthest reach, dynamic pose",
				bodyOffsetX: 3,
				bodyOffsetY: 0,
				footAnchorX: 17,
				footAnchorY: 30,
			},
			{
				name: "attack_recovery",
				prompt: "side view attack recovery frame, body returning to balanced stance, weapon or arm lowering",
				bodyOffsetX: 1,
				bodyOffsetY: 0,
				footAnchorX: 16,
				footAnchorY: 30,
			},
		],
	},
	{
		id: "hurt_side_2",
		name: "Side Hurt 2 Frames",
		category: "hurt",
		direction: "side",
		fps: 8,
		frameCount: 2,
		description: "Short hit reaction with recoil and recovery pose.",
		frames: [
			{
				name: "hurt_recoil",
				prompt: "side view hurt frame, body knocked backward, head and shoulders recoiling, arms raised defensively",
				bodyOffsetX: -2,
				bodyOffsetY: -1,
				footAnchorX: 15,
				footAnchorY: 29,
			},
			{
				name: "hurt_recover",
				prompt: "side view hurt recovery frame, body returning forward, one knee bent, guarded stance",
				bodyOffsetX: -1,
				bodyOffsetY: 0,
				footAnchorX: 16,
				footAnchorY: 30,
			},
		],
	},
	{
		id: "death_side_6",
		name: "Side Death 6 Frames",
		category: "death",
		direction: "side",
		fps: 8,
		frameCount: 6,
		description: "Side-view defeat animation from stagger to grounded final pose.",
		frames: [
			{
				name: "death_stagger",
				prompt: "side view death animation frame, character staggered backward, balance lost",
				bodyOffsetX: -1,
				bodyOffsetY: -1,
				footAnchorX: 16,
				footAnchorY: 29,
			},
			{
				name: "death_fall_start",
				prompt: "side view death animation frame, knees buckling, upper body falling backward",
				bodyOffsetX: -2,
				bodyOffsetY: 1,
				footAnchorX: 16,
				footAnchorY: 30,
			},
			{
				name: "death_fall_mid",
				prompt: "side view death animation frame, body halfway to ground, legs folding, arms loose",
				bodyOffsetX: -2,
				bodyOffsetY: 4,
				footAnchorX: 16,
				footAnchorY: 31,
			},
			{
				name: "death_ground_hit",
				prompt: "side view death animation frame, body hitting ground, horizontal pose, small impact",
				bodyOffsetX: 0,
				bodyOffsetY: 8,
				footAnchorX: 16,
				footAnchorY: 31,
			},
			{
				name: "death_settle",
				prompt: "side view death animation frame, body settling on ground, no tension, final pose forming",
				bodyOffsetX: 0,
				bodyOffsetY: 9,
				footAnchorX: 16,
				footAnchorY: 31,
			},
			{
				name: "death_final",
				prompt: "side view death final frame, character lying still on ground, readable silhouette",
				bodyOffsetX: 0,
				bodyOffsetY: 9,
				footAnchorX: 16,
				footAnchorY: 31,
			},
		],
	},
];

export const getPixelMotionTemplate = (id: string) => {
	return pixelMotionTemplates.find((template) => template.id === id) ?? pixelMotionTemplates[0];
};

export const isPixelMotionTemplateId = (id: string) => {
	return pixelMotionTemplates.some((template) => template.id === id);
};
