import { ParticleDocument, ParticleFields, ParticleVec4, cloneParticleDocument } from "./ParticleDocument";
import { ParticleRandom } from "./ParticleRandom";

export type ParticleQuadVertex = {
	x: number;
	y: number;
	u: number;
	v: number;
	color: ParticleVec4;
};

export type ParticleQuad = {
	rb: ParticleQuadVertex;
	lb: ParticleQuadVertex;
	lt: ParticleQuadVertex;
	rt: ParticleQuadVertex;
};

type RuntimeParticle = {
	pos: { x: number; y: number; z: number };
	color: ParticleVec4;
	deltaColor: ParticleVec4;
	size: number;
	deltaSize: number;
	rotation: number;
	deltaRotation: number;
	timeToLive: number;
	gravity: {
		dir: { x: number; y: number };
		radialAccel: number;
		tangentialAccel: number;
	};
	radius: {
		angle: number;
		degreesPerSecond: number;
		radius: number;
		deltaRadius: number;
	};
};

const createRuntimeParticle = (): RuntimeParticle => ({
	pos: { x: 0, y: 0, z: 0 },
	color: { x: 0, y: 0, z: 0, w: 0 },
	deltaColor: { x: 0, y: 0, z: 0, w: 0 },
	size: 0,
	deltaSize: 0,
	rotation: 0,
	deltaRotation: 0,
	timeToLive: 0,
	gravity: { dir: { x: 0, y: 0 }, radialAccel: 0, tangentialAccel: 0 },
	radius: { angle: 0, degreesPerSecond: 0, radius: 0, deltaRadius: 0 },
});

const createQuadVertex = (): ParticleQuadVertex => ({
	x: 0,
	y: 0,
	u: 0,
	v: 0,
	color: { x: 0, y: 0, z: 0, w: 0 },
});

const createQuad = (): ParticleQuad => ({
	rb: createQuadVertex(),
	lb: createQuadVertex(),
	lt: createQuadVertex(),
	rt: createQuadVertex(),
});

export type ParticleRuntimeSnapshot = {
	active: boolean;
	emitting: boolean;
	elapsed: number;
	particleCount: number;
	quads: ParticleQuad[];
};

const epsilon = 1.1920928955078125e-7;
const toRad = (degree: number) => degree * Math.PI / 180;
const toDeg = (rad: number) => rad * 180 / Math.PI;
const clamp = (value: number, min: number, max: number) => Math.max(min, Math.min(max, value));
const length = (x: number, y: number) => Math.sqrt(x * x + y * y);
const randomSeed = () => Math.floor(Math.random() * 0x100000000) >>> 0;

const engineCompatibleFields = (fields: ParticleFields): ParticleFields => {
	const next = cloneParticleDocument({ version: 1, source: "par", dirty: false, fields }).fields;
	if (next.emitterMode === "gravity") {
		next.gravity.speed = Math.trunc(next.gravity.speed);
		next.gravity.speedVariance = Math.trunc(next.gravity.speedVariance);
		next.gravity.radialAcceleration = Math.trunc(next.gravity.radialAcceleration);
		next.gravity.radialAccelVariance = Math.trunc(next.gravity.radialAccelVariance);
		next.gravity.tangentialAcceleration = Math.trunc(next.gravity.tangentialAcceleration);
		next.gravity.tangentialAccelVariance = Math.trunc(next.gravity.tangentialAccelVariance);
	} else {
		next.radius.startRadius = Math.trunc(next.radius.startRadius);
		next.radius.startRadiusVariance = Math.trunc(next.radius.startRadiusVariance);
		next.radius.finishRadius = Math.trunc(next.radius.finishRadius);
		next.radius.finishRadiusVariance = Math.trunc(next.radius.finishRadiusVariance);
		next.radius.rotatePerSecond = Math.trunc(next.radius.rotatePerSecond);
		next.radius.rotatePerSecondVariance = Math.trunc(next.radius.rotatePerSecondVariance);
	}
	return next;
};

export class ParticlePreviewRuntime {
	private document: ParticleDocument;
	private random: ParticleRandom;
	private particles: RuntimeParticle[] = [];
	private particlePool: RuntimeParticle[] = [];
	private quads: ParticleQuad[] = [];
	private quadPool: ParticleQuad[] = [];
	private active = false;
	private emitting = false;
	private elapsed = 0;
	private emitCounter = 0;
	private seed: number;
	private compatibleMode: boolean;
	private previewCap: number;
	private cachedFields: ParticleFields | null = null;
	private previewEmitterPosition: { x: number; y: number } = { x: 0, y: 0 };

	constructor(document: ParticleDocument, seed = randomSeed(), compatibleMode = true, previewCap = 5000) {
		this.document = cloneParticleDocument(document);
		this.seed = seed >>> 0;
		this.random = new ParticleRandom(this.seed);
		this.compatibleMode = compatibleMode;
		this.previewCap = previewCap;
		this.start(this.seed);
	}

	setDocument(document: ParticleDocument) {
		this.document = cloneParticleDocument(document);
		this.cachedFields = null;
		this.start();
	}

	setSeed(seed: number) {
		this.seed = seed >>> 0;
		this.start(this.seed);
	}

	setCompatibleMode(enabled: boolean) {
		this.compatibleMode = enabled;
		this.cachedFields = null;
		this.start();
	}

	setPreviewEmitterPosition(position: { x: number; y: number }) {
		this.previewEmitterPosition = { ...position };
	}

	start(seed = randomSeed()) {
		this.seed = seed >>> 0;
		this.random.seed(this.seed);
		this.active = true;
		this.emitting = true;
		this.elapsed = 0;
		this.emitCounter = 0;
		this.recycleParticles();
		this.recycleQuads();
	}

	stop() {
		this.active = false;
		this.elapsed = this.fields().duration;
		this.emitCounter = 0;
	}

	step(deltaTime: number, scale = 1) {
		const fields = this.fields();
		if (!this.emitting) return this.snapshot();
		if (this.active && fields.emissionRate > 0) {
			const rate = 1 / fields.emissionRate;
			if (this.particles.length < Math.min(fields.maxParticles, this.previewCap)) {
				this.emitCounter += deltaTime;
			}
			while (this.particles.length < Math.min(fields.maxParticles, this.previewCap) && this.emitCounter > rate) {
				this.addParticle(fields);
				this.emitCounter -= rate;
			}
			this.elapsed += deltaTime;
			if (fields.duration >= 0 && fields.duration < this.elapsed) {
				this.stop();
			}
		}
		const particleScale = scale;
		this.recycleQuads();
		let index = 0;
		while (index < this.particles.length) {
			const p = this.particles[index];
			p.timeToLive -= deltaTime;
			if (p.timeToLive > 0) {
				if (fields.emitterMode === "gravity") {
					let radialX = 0;
					let radialY = 0;
					if (p.pos.x || p.pos.y) {
						const len = length(p.pos.x, p.pos.y);
						radialX = p.pos.x / len;
						radialY = p.pos.y / len;
					}
					const tangentialX = -radialY * p.gravity.tangentialAccel;
					const tangentialY = radialX * p.gravity.tangentialAccel;
					const tmpX = (radialX * p.gravity.radialAccel + tangentialX + fields.gravity.gravity.x) * deltaTime;
					const tmpY = (radialY * p.gravity.radialAccel + tangentialY + fields.gravity.gravity.y) * deltaTime;
					p.gravity.dir.x += tmpX;
					p.gravity.dir.y += tmpY;
					p.pos.x += p.gravity.dir.x * deltaTime * particleScale;
					p.pos.y += p.gravity.dir.y * deltaTime * particleScale;
				} else {
					p.radius.angle += p.radius.degreesPerSecond * deltaTime;
					p.radius.radius += p.radius.deltaRadius * deltaTime * particleScale;
					p.pos.x = -Math.cos(p.radius.angle) * p.radius.radius;
					p.pos.y = -Math.sin(p.radius.angle) * p.radius.radius;
				}
				p.color.x += p.deltaColor.x * deltaTime;
				p.color.y += p.deltaColor.y * deltaTime;
				p.color.z += p.deltaColor.z * deltaTime;
				p.color.w += p.deltaColor.w * deltaTime;
				p.size = Math.max(0, p.size + p.deltaSize * deltaTime * particleScale);
				p.rotation += p.deltaRotation * deltaTime;
				this.addQuad(p, particleScale);
				index++;
			} else {
				const dead = this.particles[index];
				const replacement = this.particles.pop();
				if (replacement && replacement !== dead && index < this.particles.length) {
					this.particles[index] = replacement;
				}
				this.recycleParticle(dead);
				if (this.particles.length === 0) {
					this.emitting = false;
				}
			}
		}
		return this.snapshot();
	}

	snapshot(): ParticleRuntimeSnapshot {
		return {
			active: this.active,
			emitting: this.emitting,
			elapsed: this.elapsed,
			particleCount: this.particles.length,
			quads: this.quads,
		};
	}

	private fields() {
		if (!this.cachedFields) {
			this.cachedFields = this.compatibleMode ? engineCompatibleFields(this.document.fields) : cloneParticleDocument(this.document).fields;
		}
		return this.cachedFields;
	}

	private recycleParticles() {
		while (this.particles.length > 0) {
			const particle = this.particles.pop();
			if (particle) this.recycleParticle(particle);
		}
	}

	private recycleQuads() {
		while (this.quads.length > 0) {
			const quad = this.quads.pop();
			if (quad && this.quadPool.length < this.previewCap) {
				this.quadPool.push(quad);
			}
		}
	}

	private recycleParticle(particle: RuntimeParticle) {
		if (this.particlePool.length < this.previewCap) {
			this.particlePool.push(particle);
		}
	}

	private acquireParticle() {
		return this.particlePool.pop() ?? createRuntimeParticle();
	}

	private acquireQuad() {
		return this.quadPool.pop() ?? createQuad();
	}

	private addParticle(fields: ParticleFields) {
		const ttl = Math.max(epsilon, fields.particleLifespan + fields.particleLifespanVariance * this.random.rand1to1());
		const particle = this.acquireParticle();
		particle.pos.x = this.previewEmitterPosition.x + fields.startPosition.x + fields.startPositionVariance.x * this.random.rand1to1();
		particle.pos.y = this.previewEmitterPosition.y + fields.startPosition.y + fields.startPositionVariance.y * this.random.rand1to1();
		particle.pos.z = 0;
		const startX = clamp(fields.startColor.x + fields.startColorVariance.x * this.random.rand1to1(), 0, 1);
		const startY = clamp(fields.startColor.y + fields.startColorVariance.y * this.random.rand1to1(), 0, 1);
		const startZ = clamp(fields.startColor.z + fields.startColorVariance.z * this.random.rand1to1(), 0, 1);
		const startW = clamp(fields.startColor.w + fields.startColorVariance.w * this.random.rand1to1(), 0, 1);
		const endX = clamp(fields.finishColor.x + fields.finishColorVariance.x * this.random.rand1to1(), 0, 1);
		const endY = clamp(fields.finishColor.y + fields.finishColorVariance.y * this.random.rand1to1(), 0, 1);
		const endZ = clamp(fields.finishColor.z + fields.finishColorVariance.z * this.random.rand1to1(), 0, 1);
		const endW = clamp(fields.finishColor.w + fields.finishColorVariance.w * this.random.rand1to1(), 0, 1);
		const startSize = Math.max(0, fields.startParticleSize + fields.startParticleSizeVariance * this.random.rand1to1());
		const finishSize = fields.finishParticleSize < 0 ? startSize : Math.max(0, fields.finishParticleSize + fields.finishParticleSizeVariance * this.random.rand1to1());
		const startAngle = fields.rotationStart + fields.rotationStartVariance * this.random.rand1to1();
		const endAngle = fields.rotationEnd + fields.rotationEndVariance * this.random.rand1to1();
		const angle = toRad(fields.angle + fields.angleVariance * this.random.rand1to1());
		particle.color.x = startX;
		particle.color.y = startY;
		particle.color.z = startZ;
		particle.color.w = startW;
		particle.deltaColor.x = (endX - startX) / ttl;
		particle.deltaColor.y = (endY - startY) / ttl;
		particle.deltaColor.z = (endZ - startZ) / ttl;
		particle.deltaColor.w = (endW - startW) / ttl;
		particle.size = startSize;
		particle.deltaSize = fields.finishParticleSize < 0 ? 0 : (finishSize - startSize) / ttl;
		particle.rotation = startAngle;
		particle.deltaRotation = (endAngle - startAngle) / ttl;
		particle.timeToLive = ttl;
		particle.gravity.dir.x = 0;
		particle.gravity.dir.y = 0;
		particle.gravity.radialAccel = 0;
		particle.gravity.tangentialAccel = 0;
		particle.radius.angle = angle;
		particle.radius.degreesPerSecond = 0;
		particle.radius.radius = 0;
		particle.radius.deltaRadius = 0;
		if (fields.emitterMode === "gravity") {
			const speed = fields.gravity.speed + fields.gravity.speedVariance * this.random.rand1to1();
			particle.gravity.dir = { x: Math.cos(angle) * speed, y: Math.sin(angle) * speed };
			particle.gravity.radialAccel = fields.gravity.radialAcceleration + fields.gravity.radialAccelVariance * this.random.rand1to1();
			particle.gravity.tangentialAccel = fields.gravity.tangentialAcceleration + fields.gravity.tangentialAccelVariance * this.random.rand1to1();
			if (fields.gravity.rotationIsDir) {
				particle.rotation = -toDeg(Math.atan2(particle.gravity.dir.y, particle.gravity.dir.x));
			}
		} else {
			const startRadius = fields.radius.startRadius + fields.radius.startRadiusVariance * this.random.rand1to1();
			particle.radius.radius = startRadius;
			if (fields.radius.finishRadius < 0) {
				particle.radius.deltaRadius = 0;
			} else {
				const endRadius = fields.radius.finishRadius + fields.radius.finishRadiusVariance * this.random.rand1to1();
				particle.radius.deltaRadius = (endRadius - startRadius) / ttl;
			}
			particle.radius.degreesPerSecond = toRad(fields.radius.rotatePerSecond + fields.radius.rotatePerSecondVariance * this.random.rand1to1());
		}
		this.particles.push(particle);
	}

	private addQuad(particle: RuntimeParticle, scale: number) {
		const halfSize = particle.size * 0.5 * scale;
		const quad = this.acquireQuad();
		const setVertex = (vertex: ParticleQuadVertex, x: number, y: number, u: number, v: number) => {
			vertex.x = particle.pos.x + x;
			vertex.y = particle.pos.y + y;
			vertex.u = u;
			vertex.v = v;
			vertex.color.x = particle.color.x;
			vertex.color.y = particle.color.y;
			vertex.color.z = particle.color.z;
			vertex.color.w = particle.color.w;
		};
		if (particle.rotation) {
			const r = -toRad(particle.rotation);
			const cr = Math.cos(r);
			const sr = Math.sin(r);
			const ax = -halfSize * cr - -halfSize * sr;
			const ay = -halfSize * sr + -halfSize * cr;
			const bx = halfSize * cr - -halfSize * sr;
			const by = halfSize * sr + -halfSize * cr;
			const cx = halfSize * cr - halfSize * sr;
			const cy = halfSize * sr + halfSize * cr;
			const dx = -halfSize * cr - halfSize * sr;
			const dy = -halfSize * sr + halfSize * cr;
			setVertex(quad.rb, bx, by, 1, 1);
			setVertex(quad.lb, ax, ay, 0, 1);
			setVertex(quad.lt, dx, dy, 0, 0);
			setVertex(quad.rt, cx, cy, 1, 0);
		} else {
			setVertex(quad.rb, halfSize, -halfSize, 1, 1);
			setVertex(quad.lb, -halfSize, -halfSize, 0, 1);
			setVertex(quad.lt, -halfSize, halfSize, 0, 0);
			setVertex(quad.rt, halfSize, halfSize, 1, 0);
		}
		this.quads.push(quad);
	}
}
