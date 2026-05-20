import {
	Body,
	Box,
	Chain,
	Circle,
	DistanceJoint,
	FrictionJoint,
	GearJoint,
	MotorJoint,
	Polygon,
	PrismaticJoint,
	PulleyJoint,
	RevoluteJoint,
	RopeJoint,
	Vec2,
	WeldJoint,
	WheelJoint,
	World,
	type BodyType as PlanckBodyType,
	type FixtureOpt,
	type Joint,
	type Shape,
} from "planck";
import { BodyDocument, BodyLuaValue, BodyStructDocument, BodyVector } from "./BodyDocument";
import { decomposeBodyPolygon } from "./BodyPolygon";
import { asArray, asNumber, asString, asVector, getItemName, isBodyItem } from "./BodyRender";

export const BODY_PIXELS_PER_METER = 100;
export const BODY_PHYSICS_TIME_STEP = 1 / 60;

export type BodyPhysicsDiagnostic = {
	id: string;
	message: string;
};

export type BodyPhysicsBodySnapshot = {
	id: string;
	name: string;
	structType: string;
	type: PlanckBodyType;
	position: BodyVector;
	angle: number;
};

export type BodyPhysicsJointSnapshot = {
	id: string;
	name: string;
	structType: string;
	anchorA: BodyVector;
	anchorB: BodyVector;
};

export type BodyPhysicsMotorControl = {
	id: string;
	name: string;
	structType: string;
	baseSpeed: number;
};

export type BodyPhysicsSnapshot = {
	bodies: BodyPhysicsBodySnapshot[];
	joints: BodyPhysicsJointSnapshot[];
	motorControls: BodyPhysicsMotorControl[];
	bodyCount: number;
	fixtureCount: number;
	jointCount: number;
	time: number;
};

type BodyRuntimeEntry = {
	item: BodyStructDocument;
	body: Body;
	fixtureCount: number;
};

type MotorRuntimeEntry = {
	control: BodyPhysicsMotorControl;
	setSpeed: (speed: number) => void;
};

const toMeters = (value: number) => value / BODY_PIXELS_PER_METER;
const toPixels = (value: number) => value * BODY_PIXELS_PER_METER;

export const vectorToMeters = (value: BodyVector) => Vec2(toMeters(value[0]), toMeters(value[1]));
export const vectorToPixels = (value: { x: number; y: number }): BodyVector => [toPixels(value.x), toPixels(value.y)];

const editorDegreesToPlanckRadians = (value: number) => -value * Math.PI / 180;
const planckRadiansToEditorDegrees = (value: number) => -value * 180 / Math.PI;
const editorAngleRangeToPlanckRadians = (lower: number, upper: number): [number, number] => {
	const a = editorDegreesToPlanckRadians(lower);
	const b = editorDegreesToPlanckRadians(upper);
	return [Math.min(a, b), Math.max(a, b)];
};

const planckBodyType = (value: BodyLuaValue | undefined): PlanckBodyType => {
	const type = asString(value, "Static");
	if (type === "Dynamic") return "dynamic";
	if (type === "Kinematic") return "kinematic";
	return "static";
};

const fixtureOptions = (shape: BodyStructDocument): FixtureOpt => ({
	density: Math.max(0, asNumber(shape.fields.density, 0)),
	friction: Math.max(0, asNumber(shape.fields.friction, 0.2)),
	restitution: Math.max(0, asNumber(shape.fields.restitution, 0)),
	isSensor: shape.fields.sensor === true,
	userData: {
		id: shape.id,
		structType: shape.structType,
		sensorTag: asNumber(shape.fields.sensorTag, 0),
	},
});

const validVertices = (value: BodyLuaValue | undefined): BodyVector[] => {
	const vertices = asArray(value).map((point) => asVector(point));
	return vertices.filter((point) => Number.isFinite(point[0]) && Number.isFinite(point[1]));
};

const makeShapes = (shape: BodyStructDocument, diagnostics: BodyPhysicsDiagnostic[]): Shape[] => {
	if (shape.structType === "Phyx.Rect" || shape.structType === "Phyx.SubRect") {
		const center = asVector(shape.fields.center);
		const size = asVector(shape.fields.size, [40, 40]);
		const halfWidth = Math.abs(toMeters(size[0])) / 2;
		const halfHeight = Math.abs(toMeters(size[1])) / 2;
		if (halfWidth <= 0 || halfHeight <= 0) {
			diagnostics.push({ id: shape.id, message: `${shape.structType} requires positive size` });
			return [];
		}
			const angle = shape.structType === "Phyx.SubRect" ? asNumber(shape.fields.angle) : 0;
			return [Box(halfWidth, halfHeight, vectorToMeters(center), editorDegreesToPlanckRadians(angle))];
	}
	if (shape.structType === "Phyx.Disk" || shape.structType === "Phyx.SubDisk") {
		const radius = Math.abs(toMeters(asNumber(shape.fields.radius, 20)));
		if (radius <= 0) {
			diagnostics.push({ id: shape.id, message: `${shape.structType} requires positive radius` });
			return [];
		}
		return [Circle(vectorToMeters(asVector(shape.fields.center)), radius)];
	}
	if (shape.structType === "Phyx.Poly" || shape.structType === "Phyx.SubPoly") {
		const result = decomposeBodyPolygon(validVertices(shape.fields.vertices));
		for (const message of result.diagnostics) diagnostics.push({ id: shape.id, message: `${shape.structType} ${message}` });
		return result.parts.map((part) => Polygon(part.map(vectorToMeters)));
	}
	if (shape.structType === "Phyx.Chain" || shape.structType === "Phyx.SubChain") {
		const vertices = validVertices(shape.fields.vertices);
		if (vertices.length < 2) {
			diagnostics.push({ id: shape.id, message: `${shape.structType} requires at least 2 vertices` });
			return [];
		}
		return [Chain(vertices.map(vectorToMeters), false)];
	}
	diagnostics.push({ id: shape.id, message: `Unsupported fixture shape ${shape.structType}` });
	return [];
};

const createFixture = (body: Body, shape: BodyStructDocument, diagnostics: BodyPhysicsDiagnostic[]) => {
	const shapes = makeShapes(shape, diagnostics);
	const options = fixtureOptions(shape);
	for (const planckShape of shapes) body.createFixture(planckShape, options);
	return shapes.length;
};

const getSubShapeItem = (value: BodyLuaValue, index: number, parentId: string): BodyStructDocument | null => {
	if (!Array.isArray(value) || typeof value[0] !== "string") return null;
	const structType = value[0];
	const fieldNames: Record<string, string[]> = {
		"Phyx.SubRect": ["center", "angle", "size", "density", "friction", "restitution", "sensor", "sensorTag"],
		"Phyx.SubDisk": ["center", "radius", "density", "friction", "restitution", "sensor", "sensorTag"],
		"Phyx.SubPoly": ["vertices", "density", "friction", "restitution", "sensor", "sensorTag"],
		"Phyx.SubChain": ["vertices", "friction", "restitution"],
	};
	const names = fieldNames[structType];
	if (!names) return null;
	const fields: Record<string, BodyLuaValue> = {};
	for (let i = 0; i < names.length; i++) fields[names[i]] = value[i + 1] ?? null;
	return {
		id: `${parentId}:sub:${index}`,
		structType: structType as BodyStructDocument["structType"],
		fields,
	};
};

export class BodyPhysicsRuntime {
	private world = new World({ gravity: Vec2(0, 0) });
	private readonly bodies = new Map<string, BodyRuntimeEntry>();
	private readonly joints = new Map<string, Joint>();
	private readonly jointItems = new Map<string, BodyStructDocument>();
	private readonly motors = new Map<string, MotorRuntimeEntry>();
	private diagnostics: BodyPhysicsDiagnostic[] = [];
	private time = 0;

	constructor(document?: BodyDocument) {
		if (document) this.reset(document);
	}

	getWorld() {
		return this.world;
	}

	getDiagnostics() {
		return [...this.diagnostics];
	}

	getBody(name: string) {
		return this.bodies.get(name)?.body ?? null;
	}

	setMotorDirection(id: string, direction: -1 | 0 | 1) {
		const motor = this.motors.get(id);
		if (!motor) return false;
		motor.setSpeed(motor.control.baseSpeed * direction);
		return true;
	}

	private applyLinearAcceleration() {
		for (const entry of this.bodies.values()) {
			if (!entry.body.isDynamic()) continue;
			const acceleration = asVector(entry.item.fields.linearAcceleration);
			if (acceleration[0] === 0 && acceleration[1] === 0) continue;
			const mass = entry.body.getMass();
			entry.body.applyForceToCenter(Vec2(mass * acceleration[0], mass * acceleration[1]), true);
		}
	}

	reset(document: BodyDocument) {
			this.world = new World({ gravity: Vec2(0, 0) });
			this.bodies.clear();
			this.joints.clear();
			this.jointItems.clear();
			this.motors.clear();
		this.diagnostics = [];
		this.time = 0;
		for (const item of document.items) {
			if (!isBodyItem(item)) continue;
			const body = this.world.createBody({
				type: planckBodyType(item.fields.type),
				position: vectorToMeters(asVector(item.fields.position)),
				angle: editorDegreesToPlanckRadians(asNumber(item.fields.angle)),
				linearDamping: Math.max(0, asNumber(item.fields.linearDamping, 0)),
				angularDamping: Math.max(0, asNumber(item.fields.angularDamping, 0)),
				fixedRotation: item.fields.fixedRotation === true,
				bullet: item.fields.bullet === true,
				userData: {
					id: item.id,
					name: getItemName(item),
					structType: item.structType,
				},
			});
			let fixtureCount = createFixture(body, item, this.diagnostics);
			for (const [index, subShapeValue] of asArray(item.fields.subShapes).entries()) {
				const subShape = getSubShapeItem(subShapeValue, index, item.id);
				if (subShape) fixtureCount += createFixture(body, subShape, this.diagnostics);
			}
			if (fixtureCount === 0) {
				this.diagnostics.push({ id: item.id, message: `${item.structType} created without fixtures` });
			}
			this.bodies.set(getItemName(item), { item, body, fixtureCount });
		}
		for (const item of document.items) {
			if (isBodyItem(item) || item.structType === "Phyx.Gear") continue;
			this.createJoint(item);
		}
		for (const item of document.items) {
			if (item.structType === "Phyx.Gear") this.createJoint(item);
		}
		return this.snapshot();
	}

	step(seconds = BODY_PHYSICS_TIME_STEP) {
		this.applyLinearAcceleration();
		this.world.step(seconds, 8, 3);
		this.time += seconds;
		return this.snapshot();
	}

		snapshot(): BodyPhysicsSnapshot {
			const bodies: BodyPhysicsBodySnapshot[] = [];
			const joints: BodyPhysicsJointSnapshot[] = [];
			let fixtureCount = 0;
		for (const entry of this.bodies.values()) {
			fixtureCount += entry.fixtureCount;
			const position = entry.body.getPosition();
			bodies.push({
				id: entry.item.id,
				name: getItemName(entry.item),
				structType: entry.item.structType,
				type: entry.body.getType(),
				position: vectorToPixels(position),
					angle: planckRadiansToEditorDegrees(entry.body.getAngle()),
				});
			}
			for (const [name, joint] of this.joints.entries()) {
				const item = this.jointItems.get(name);
				if (!item) continue;
				joints.push({
					id: item.id,
					name,
					structType: item.structType,
					anchorA: vectorToPixels(joint.getAnchorA()),
					anchorB: vectorToPixels(joint.getAnchorB()),
				});
			}
			return {
				bodies,
				joints,
				motorControls: [...this.motors.values()].map((entry) => entry.control),
			bodyCount: this.world.getBodyCount(),
			fixtureCount,
			jointCount: this.world.getJointCount(),
			time: this.time,
		};
	}

	private createJoint(item: BodyStructDocument) {
		try {
				const joint = this.makeJoint(item);
				if (!joint) return;
				const created = this.world.createJoint(joint);
				if (created) {
					const name = getItemName(item);
					this.joints.set(name, created);
					this.jointItems.set(name, item);
				}
		} catch (error) {
			this.diagnostics.push({
				id: item.id,
				message: `${item.structType} preview failed: ${error instanceof Error ? error.message : String(error)}`,
			});
		}
	}

	private bodyRef(item: BodyStructDocument, field: string) {
		const name = asString(item.fields[field]);
		const body = this.bodies.get(name)?.body ?? null;
		if (!body) this.diagnostics.push({ id: item.id, message: `${item.structType} missing body reference ${field}: ${name}` });
		return body;
	}

	private addMotorControl(item: BodyStructDocument, baseSpeed: number, setSpeed: (speed: number) => void) {
		if (baseSpeed === 0) return;
		this.motors.set(item.id, {
			control: {
				id: item.id,
				name: getItemName(item),
				structType: item.structType,
				baseSpeed,
			},
			setSpeed,
		});
	}

	private makeJoint(item: BodyStructDocument): Joint | null {
		if (item.structType === "Phyx.Gear") {
			const jointAName = asString(item.fields.jointA);
			const jointBName = asString(item.fields.jointB);
			const jointA = this.joints.get(jointAName);
			const jointB = this.joints.get(jointBName);
			if (!jointA || !jointB) {
				this.diagnostics.push({ id: item.id, message: `Phyx.Gear missing joint references: ${jointAName}, ${jointBName}` });
				return null;
			}
			return GearJoint(
				{ collideConnected: item.fields.collision === true },
				jointA.getBodyA(),
				jointB.getBodyB(),
				jointA as never,
				jointB as never,
				asNumber(item.fields.ratio, 1),
			);
		}
		const bodyA = this.bodyRef(item, "bodyA");
		const bodyB = this.bodyRef(item, "bodyB");
		if (!bodyA || !bodyB) return null;
		const opt = { collideConnected: item.fields.collision === true };
		if (item.structType === "Phyx.Distance") {
			const localAnchorA = vectorToMeters(asVector(item.fields.anchorA));
			const localAnchorB = vectorToMeters(asVector(item.fields.anchorB));
			return DistanceJoint({
				...opt,
				bodyA,
				bodyB,
				localAnchorA,
				localAnchorB,
				frequencyHz: Math.max(0, asNumber(item.fields.frequency)),
				dampingRatio: Math.max(0, asNumber(item.fields.damping)),
			});
		}
		if (item.structType === "Phyx.Friction") {
			return FrictionJoint({
				...opt,
				maxForce: Math.max(0, asNumber(item.fields.maxForce)),
				maxTorque: Math.max(0, asNumber(item.fields.maxTorque)),
			}, bodyA, bodyB, vectorToMeters(asVector(item.fields.worldPos)));
		}
		if (item.structType === "Phyx.Spring") {
			return MotorJoint({
				...opt,
				linearOffset: vectorToMeters(asVector(item.fields.linearOffset)),
					angularOffset: editorDegreesToPlanckRadians(asNumber(item.fields.angularOffset)),
				maxForce: Math.max(0, asNumber(item.fields.maxForce)),
				maxTorque: Math.max(0, asNumber(item.fields.maxTorque)),
				correctionFactor: Math.max(0, Math.min(1, asNumber(item.fields.correctionFactor, 0.3))),
			}, bodyA, bodyB);
		}
		if (item.structType === "Phyx.Prismatic") {
			const baseSpeed = toMeters(asNumber(item.fields.motorSpeed));
				const joint = PrismaticJoint({
				...opt,
				enableLimit: true,
				lowerTranslation: toMeters(asNumber(item.fields.lowerTranslation)),
				upperTranslation: toMeters(asNumber(item.fields.upperTranslation)),
				enableMotor: Math.max(0, asNumber(item.fields.maxMotorForce)) > 0,
				maxMotorForce: Math.max(0, asNumber(item.fields.maxMotorForce)),
				motorSpeed: baseSpeed,
			}, bodyA, bodyB, vectorToMeters(asVector(item.fields.worldPos)), Vec2(asVector(item.fields.axis, [1, 0])[0], asVector(item.fields.axis, [1, 0])[1]));
			this.addMotorControl(item, baseSpeed, (speed) => joint.setMotorSpeed(speed));
			return joint;
		}
		if (item.structType === "Phyx.Pulley") {
			const groundAnchorA = vectorToMeters(asVector(item.fields.groundAnchorA));
			const groundAnchorB = vectorToMeters(asVector(item.fields.groundAnchorB));
			const localAnchorA = vectorToMeters(asVector(item.fields.anchorA));
			const localAnchorB = vectorToMeters(asVector(item.fields.anchorB));
			return PulleyJoint({
				...opt,
				bodyA,
				bodyB,
				groundAnchorA,
				groundAnchorB,
				localAnchorA,
				localAnchorB,
				lengthA: Vec2.distance(bodyA.getWorldPoint(localAnchorA), groundAnchorA),
				lengthB: Vec2.distance(bodyB.getWorldPoint(localAnchorB), groundAnchorB),
				ratio: Math.max(0.01, asNumber(item.fields.ratio, 1)),
			});
		}
			if (item.structType === "Phyx.Revolute") {
				const [lowerAngle, upperAngle] = editorAngleRangeToPlanckRadians(asNumber(item.fields.lowerAngle), asNumber(item.fields.upperAngle));
				const baseSpeed = editorDegreesToPlanckRadians(asNumber(item.fields.motorSpeed));
				const joint = RevoluteJoint({
					...opt,
					enableLimit: true,
					lowerAngle,
					upperAngle,
					enableMotor: Math.max(0, asNumber(item.fields.maxMotorTorque)) > 0,
					maxMotorTorque: Math.max(0, asNumber(item.fields.maxMotorTorque)),
					motorSpeed: baseSpeed,
			}, bodyA, bodyB, vectorToMeters(asVector(item.fields.worldPos)));
			this.addMotorControl(item, baseSpeed, (speed) => joint.setMotorSpeed(speed));
			return joint;
		}
		if (item.structType === "Phyx.Rope") {
			return RopeJoint({
				...opt,
				bodyA,
				bodyB,
				localAnchorA: vectorToMeters(asVector(item.fields.anchorA)),
				localAnchorB: vectorToMeters(asVector(item.fields.anchorB)),
				maxLength: Math.max(0.01, toMeters(asNumber(item.fields.maxLength, 100))),
			});
		}
		if (item.structType === "Phyx.Weld") {
			return WeldJoint({
				...opt,
				frequencyHz: Math.max(0, asNumber(item.fields.frequency)),
				dampingRatio: Math.max(0, asNumber(item.fields.damping)),
			}, bodyA, bodyB, vectorToMeters(asVector(item.fields.worldPos)));
		}
			if (item.structType === "Phyx.Wheel") {
				const baseSpeed = editorDegreesToPlanckRadians(asNumber(item.fields.motorSpeed));
			const joint = WheelJoint({
				...opt,
				enableMotor: Math.max(0, asNumber(item.fields.maxMotorTorque)) > 0,
				maxMotorTorque: Math.max(0, asNumber(item.fields.maxMotorTorque)),
				motorSpeed: baseSpeed,
				frequencyHz: Math.max(0, asNumber(item.fields.frequency)),
				dampingRatio: Math.max(0, asNumber(item.fields.damping)),
			}, bodyA, bodyB, vectorToMeters(asVector(item.fields.worldPos)), Vec2(asVector(item.fields.axis, [0, 1])[0], asVector(item.fields.axis, [0, 1])[1]));
			this.addMotorControl(item, baseSpeed, (speed) => joint.setMotorSpeed(speed));
			return joint;
		}
		this.diagnostics.push({ id: item.id, message: `Unsupported joint preview ${item.structType}` });
		return null;
	}
}

export const createBodyPhysicsRuntime = (document: BodyDocument) => new BodyPhysicsRuntime(document);
