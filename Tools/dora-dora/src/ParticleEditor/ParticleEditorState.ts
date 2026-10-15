import { ParticleDocument, ParticleFields, ParticleRect, ParticleVec2, ParticleVec4 } from "./ParticleDocument";

export type ParticleFieldPath =
	| keyof ParticleFields
	| `startPosition.${keyof ParticleVec2}`
	| `startPositionVariance.${keyof ParticleVec2}`
	| `gravity.gravity.${keyof ParticleVec2}`
	| `startColor.${keyof ParticleVec4}`
	| `startColorVariance.${keyof ParticleVec4}`
	| `finishColor.${keyof ParticleVec4}`
	| `finishColorVariance.${keyof ParticleVec4}`
	| `textureRect.${keyof ParticleRect}`
	| `gravity.${Exclude<keyof ParticleFields["gravity"], "gravity">}`
	| `radius.${keyof ParticleFields["radius"]}`;

export const applyParticleFieldUpdate = (document: ParticleDocument, path: ParticleFieldPath, value: number | string | boolean): ParticleDocument => {
	const next = {
		...document,
		dirty: true,
		fields: {
			...document.fields,
			startPosition: { ...document.fields.startPosition },
			startPositionVariance: { ...document.fields.startPositionVariance },
			startColor: { ...document.fields.startColor },
			startColorVariance: { ...document.fields.startColorVariance },
			finishColor: { ...document.fields.finishColor },
			finishColorVariance: { ...document.fields.finishColorVariance },
			textureRect: { ...document.fields.textureRect },
			gravity: {
				...document.fields.gravity,
				gravity: { ...document.fields.gravity.gravity },
			},
			radius: { ...document.fields.radius },
		},
	};
	const keys = String(path).split(".");
	let target: any = next.fields;
	for (let i = 0; i < keys.length - 1; i++) target = target[keys[i]];
	target[keys[keys.length - 1]] = value;
	return next;
};

export const readParticleFieldPath = (fields: ParticleFields, path: ParticleFieldPath): any => {
	const keys = String(path).split(".");
	let target: any = fields;
	for (const key of keys) target = target[key];
	return target;
};
