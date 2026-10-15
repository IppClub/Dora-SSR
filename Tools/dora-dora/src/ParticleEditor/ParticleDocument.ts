export type ParticleEmitterMode = "gravity" | "radius";

export type ParticleVec2 = {
	x: number;
	y: number;
};

export type ParticleVec4 = {
	x: number;
	y: number;
	z: number;
	w: number;
};

export type ParticleRect = {
	x: number;
	y: number;
	width: number;
	height: number;
};

export type ParticleGravityFields = {
	rotationIsDir: boolean;
	gravity: ParticleVec2;
	speed: number;
	speedVariance: number;
	radialAcceleration: number;
	radialAccelVariance: number;
	tangentialAcceleration: number;
	tangentialAccelVariance: number;
};

export type ParticleRadiusFields = {
	startRadius: number;
	startRadiusVariance: number;
	finishRadius: number;
	finishRadiusVariance: number;
	rotatePerSecond: number;
	rotatePerSecondVariance: number;
};

export type ParticleFields = {
	angle: number;
	angleVariance: number;
	blendFuncDestination: number;
	blendFuncSource: number;
	duration: number;
	emissionRate: number;
	finishColor: ParticleVec4;
	finishColorVariance: ParticleVec4;
	rotationStart: number;
	rotationStartVariance: number;
	rotationEnd: number;
	rotationEndVariance: number;
	finishParticleSize: number;
	finishParticleSizeVariance: number;
	maxParticles: number;
	particleLifespan: number;
	particleLifespanVariance: number;
	startPosition: ParticleVec2;
	startPositionVariance: ParticleVec2;
	startColor: ParticleVec4;
	startColorVariance: ParticleVec4;
	startParticleSize: number;
	startParticleSizeVariance: number;
	textureName: string;
	textureRect: ParticleRect;
	emitterMode: ParticleEmitterMode;
	gravity: ParticleGravityFields;
	radius: ParticleRadiusFields;
};

export type ParticleDocument = {
	version: 1;
	source: "par";
	fields: ParticleFields;
	dirty: boolean;
};

export type ParticleDiagnosticSeverity = "error" | "warning" | "info";

export type ParticleDiagnostic = {
	severity: ParticleDiagnosticSeverity;
	message: string;
	path: string;
};

const knownBlendFactors = new Set([
	0x1000,
	0x2000,
	0x3000,
	0x4000,
	0x5000,
	0x6000,
	0x7000,
	0x8000,
	0x9000,
	0xa000,
]);

export const cloneParticleDocument = (document: ParticleDocument): ParticleDocument => ({
	version: 1,
	source: "par",
	dirty: document.dirty,
	fields: {
		...document.fields,
		finishColor: { ...document.fields.finishColor },
		finishColorVariance: { ...document.fields.finishColorVariance },
		startPosition: { ...document.fields.startPosition },
		startPositionVariance: { ...document.fields.startPositionVariance },
		startColor: { ...document.fields.startColor },
		startColorVariance: { ...document.fields.startColorVariance },
		textureRect: { ...document.fields.textureRect },
		gravity: {
			...document.fields.gravity,
			gravity: { ...document.fields.gravity.gravity },
		},
		radius: { ...document.fields.radius },
	},
});

export const createFireParticleFields = (): ParticleFields => ({
	angle: 90,
	angleVariance: 360,
	blendFuncDestination: 0x2000,
	blendFuncSource: 0x5000,
	duration: -1,
	emissionRate: 350,
	finishColor: { x: 0, y: 0, z: 0, w: 1 },
	finishColorVariance: { x: 0, y: 0, z: 0, w: 0 },
	rotationStart: 0,
	rotationStartVariance: 0,
	rotationEnd: 0,
	rotationEndVariance: 0,
	finishParticleSize: -1,
	finishParticleSizeVariance: 0,
	maxParticles: 100,
	particleLifespan: 1,
	particleLifespanVariance: 0.5,
	startPosition: { x: 0, y: 0 },
	startPositionVariance: { x: 0, y: 0 },
	startColor: { x: 0.76, y: 0.25, z: 0.12, w: 1 },
	startColorVariance: { x: 0, y: 0, z: 0, w: 0 },
	startParticleSize: 30,
	startParticleSizeVariance: 10,
	textureName: "",
	textureRect: { x: 0, y: 0, width: 0, height: 0 },
	emitterMode: "gravity",
	gravity: {
		rotationIsDir: false,
		gravity: { x: 0, y: 0 },
		speed: 20,
		speedVariance: 5,
		radialAcceleration: 0,
		radialAccelVariance: 0,
		tangentialAcceleration: 0,
		tangentialAccelVariance: 0,
	},
	radius: {
		startRadius: 60,
		startRadiusVariance: 0,
		finishRadius: 0,
		finishRadiusVariance: 0,
		rotatePerSecond: 90,
		rotatePerSecondVariance: 0,
	},
});

export const createBlankGravityParticleFields = (): ParticleFields => ({
	...createFireParticleFields(),
	angleVariance: 0,
	emissionRate: 30,
	particleLifespanVariance: 0,
	startColor: { x: 1, y: 1, z: 1, w: 1 },
	finishColor: { x: 1, y: 0.35, z: 0.1, w: 0 },
	startParticleSize: 18,
	startParticleSizeVariance: 0,
	gravity: {
		rotationIsDir: false,
		gravity: { x: 0, y: -40 },
		speed: 90,
		speedVariance: 0,
		radialAcceleration: 0,
		radialAccelVariance: 0,
		tangentialAcceleration: 0,
		tangentialAccelVariance: 0,
	},
});

export const createBlankRadiusParticleFields = (): ParticleFields => ({
	...createBlankGravityParticleFields(),
	emitterMode: "radius",
	radius: {
		startRadius: 90,
		startRadiusVariance: 0,
		finishRadius: 10,
		finishRadiusVariance: 0,
		rotatePerSecond: 120,
		rotatePerSecondVariance: 0,
	},
});

export const createParticleDocument = (template: "fire" | "blankGravity" | "blankRadius" = "fire"): ParticleDocument => {
	const fields =
		template === "blankGravity" ? createBlankGravityParticleFields() :
			template === "blankRadius" ? createBlankRadiusParticleFields() :
				createFireParticleFields();
	return {
		version: 1,
		source: "par",
		fields,
		dirty: false,
	};
};

export const validateParticleDocument = (document: ParticleDocument, previewParticleCap = 5000): ParticleDiagnostic[] => {
	const diagnostics: ParticleDiagnostic[] = [];
	const { fields } = document;
	if (fields.maxParticles <= 0) diagnostics.push({ severity: "warning", path: "maxParticles", message: "maxParticles should be greater than 0." });
	if (fields.maxParticles > previewParticleCap) diagnostics.push({ severity: "warning", path: "maxParticles", message: `Preview is capped to ${previewParticleCap} particles.` });
	if (fields.emissionRate <= 0) diagnostics.push({ severity: "warning", path: "emissionRate", message: "emissionRate should be greater than 0 to emit particles." });
	if (fields.particleLifespan <= 0) diagnostics.push({ severity: "warning", path: "particleLifespan", message: "particleLifespan should be greater than 0." });
	if (!knownBlendFactors.has(fields.blendFuncSource)) diagnostics.push({ severity: "warning", path: "blendFuncSource", message: `Unknown source blend factor ${fields.blendFuncSource}; preview falls back to One.` });
	if (!knownBlendFactors.has(fields.blendFuncDestination)) diagnostics.push({ severity: "warning", path: "blendFuncDestination", message: `Unknown destination blend factor ${fields.blendFuncDestination}; preview falls back to One.` });
	for (const [name, color] of [
		["startColor", fields.startColor],
		["finishColor", fields.finishColor],
		["startColorVariance", fields.startColorVariance],
		["finishColorVariance", fields.finishColorVariance],
	] as const) {
		for (const channel of ["x", "y", "z", "w"] as const) {
			if (color[channel] < 0 || color[channel] > 1) {
				diagnostics.push({ severity: "warning", path: `${name}.${channel}`, message: `${name}.${channel} is clamped to [0, 1] in preview.` });
			}
		}
	}
	const compatibilityIntegerFields = fields.emitterMode === "gravity"
		? [
			["speed", fields.gravity.speed],
			["speedVariance", fields.gravity.speedVariance],
			["radialAcceleration", fields.gravity.radialAcceleration],
			["radialAccelVariance", fields.gravity.radialAccelVariance],
			["tangentialAcceleration", fields.gravity.tangentialAcceleration],
			["tangentialAccelVariance", fields.gravity.tangentialAccelVariance],
		]
		: [
			["startRadius", fields.radius.startRadius],
			["startRadiusVariance", fields.radius.startRadiusVariance],
			["finishRadius", fields.radius.finishRadius],
			["finishRadiusVariance", fields.radius.finishRadiusVariance],
			["rotatePerSecond", fields.radius.rotatePerSecond],
			["rotatePerSecondVariance", fields.radius.rotatePerSecondVariance],
		];
	for (const [name, value] of compatibilityIntegerFields) {
		if (!Number.isInteger(value)) {
			diagnostics.push({ severity: "info", path: String(name), message: `${name} is rounded in engine-compatible preview because the current C++ parser uses integer parsing.` });
		}
	}
	return diagnostics;
};
