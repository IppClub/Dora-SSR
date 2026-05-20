export type BodyVector = [number, number];
export type BodySize = [number, number];
export type BodyType = "Static" | "Dynamic" | "Kinematic";

export type BodyFieldKind =
	| "string"
	| "bodyType"
	| "number"
	| "boolean"
	| "vector"
	| "size"
	| "vertices"
	| "subShapes"
	| "bodyRef"
	| "jointRef";

export type BodyStructField = {
	name: string;
	kind: BodyFieldKind;
};

export type BodyStructDefinition = {
	type: BodyStructType;
	fields: readonly BodyStructField[];
};

export type BodyLuaPrimitive = string | number | boolean | null;
export type BodyLuaValue = BodyLuaPrimitive | BodyLuaValue[];

export type BodyStructDocument = {
	id: string;
	structType: BodyStructType;
	fields: Record<string, BodyLuaValue>;
};

export type BodyShapeType = "Phyx.Rect" | "Phyx.Disk" | "Phyx.Poly" | "Phyx.Chain";
export type BodySubShapeType = "Phyx.SubRect" | "Phyx.SubDisk" | "Phyx.SubPoly" | "Phyx.SubChain";
export type BodyJointType =
	| "Phyx.Distance"
	| "Phyx.Friction"
	| "Phyx.Gear"
	| "Phyx.Spring"
	| "Phyx.Prismatic"
	| "Phyx.Pulley"
	| "Phyx.Revolute"
	| "Phyx.Rope"
	| "Phyx.Weld"
	| "Phyx.Wheel";
export type BodyStructType = BodyShapeType | BodySubShapeType | BodyJointType;

export type BodyShapeDocument = {
	id: string;
	structType: BodyShapeType;
	name: string;
	type: BodyType;
	position: BodyVector;
	angle: number;
	linearDamping: number;
	angularDamping: number;
	fixedRotation: boolean;
	linearAcceleration: BodyVector;
	bullet: boolean;
	subShapes: BodySubShapeDocument[];
	face: string;
	facePos: BodyVector;
	faceScale: number;
};

export type BodySubShapeDocument = {
	id: string;
	structType: BodySubShapeType;
};

export type BodyJointDocument = {
	id: string;
	structType: BodyJointType;
	name: string;
	collision: boolean;
};

export type BodyDocument = {
	version: 1;
	source: "b.lua";
	items: BodyStructDocument[];
	dirty: boolean;
};

const field = (name: string, kind: BodyFieldKind): BodyStructField => ({ name, kind });

export const BODY_SHAPE_STRUCTS = [
	{
		type: "Phyx.Rect",
		fields: [
			field("name", "string"),
			field("type", "bodyType"),
			field("position", "vector"),
			field("angle", "number"),
			field("center", "vector"),
			field("size", "size"),
			field("density", "number"),
			field("friction", "number"),
			field("restitution", "number"),
			field("linearDamping", "number"),
			field("angularDamping", "number"),
			field("fixedRotation", "boolean"),
			field("linearAcceleration", "vector"),
			field("bullet", "boolean"),
			field("sensor", "boolean"),
			field("sensorTag", "number"),
			field("subShapes", "subShapes"),
			field("face", "string"),
			field("facePos", "vector"),
			field("faceScale", "number"),
		],
	},
	{
		type: "Phyx.Disk",
		fields: [
			field("name", "string"),
			field("type", "bodyType"),
			field("position", "vector"),
			field("angle", "number"),
			field("center", "vector"),
			field("radius", "number"),
			field("density", "number"),
			field("friction", "number"),
			field("restitution", "number"),
			field("linearDamping", "number"),
			field("angularDamping", "number"),
			field("fixedRotation", "boolean"),
			field("linearAcceleration", "vector"),
			field("bullet", "boolean"),
			field("sensor", "boolean"),
			field("sensorTag", "number"),
			field("subShapes", "subShapes"),
			field("face", "string"),
			field("facePos", "vector"),
			field("faceScale", "number"),
		],
	},
	{
		type: "Phyx.Poly",
		fields: [
			field("name", "string"),
			field("type", "bodyType"),
			field("position", "vector"),
			field("angle", "number"),
			field("vertices", "vertices"),
			field("density", "number"),
			field("friction", "number"),
			field("restitution", "number"),
			field("linearDamping", "number"),
			field("angularDamping", "number"),
			field("fixedRotation", "boolean"),
			field("linearAcceleration", "vector"),
			field("bullet", "boolean"),
			field("sensor", "boolean"),
			field("sensorTag", "number"),
			field("subShapes", "subShapes"),
			field("face", "string"),
			field("facePos", "vector"),
			field("faceScale", "number"),
		],
	},
	{
		type: "Phyx.Chain",
		fields: [
			field("name", "string"),
			field("type", "bodyType"),
			field("position", "vector"),
			field("angle", "number"),
			field("vertices", "vertices"),
			field("friction", "number"),
			field("restitution", "number"),
			field("linearDamping", "number"),
			field("angularDamping", "number"),
			field("fixedRotation", "boolean"),
			field("linearAcceleration", "vector"),
			field("bullet", "boolean"),
			field("subShapes", "subShapes"),
			field("face", "string"),
			field("facePos", "vector"),
			field("faceScale", "number"),
		],
	},
] as const satisfies readonly BodyStructDefinition[];

export const BODY_SUB_SHAPE_STRUCTS = [
	{
		type: "Phyx.SubRect",
		fields: [
			field("center", "vector"),
			field("angle", "number"),
			field("size", "size"),
			field("density", "number"),
			field("friction", "number"),
			field("restitution", "number"),
			field("sensor", "boolean"),
			field("sensorTag", "number"),
		],
	},
	{
		type: "Phyx.SubDisk",
		fields: [
			field("center", "vector"),
			field("radius", "number"),
			field("density", "number"),
			field("friction", "number"),
			field("restitution", "number"),
			field("sensor", "boolean"),
			field("sensorTag", "number"),
		],
	},
	{
		type: "Phyx.SubPoly",
		fields: [
			field("vertices", "vertices"),
			field("density", "number"),
			field("friction", "number"),
			field("restitution", "number"),
			field("sensor", "boolean"),
			field("sensorTag", "number"),
		],
	},
	{
		type: "Phyx.SubChain",
		fields: [
			field("vertices", "vertices"),
			field("friction", "number"),
			field("restitution", "number"),
		],
	},
] as const satisfies readonly BodyStructDefinition[];

export const BODY_JOINT_STRUCTS = [
	{
		type: "Phyx.Distance",
		fields: [
			field("name", "string"),
			field("collision", "boolean"),
			field("bodyA", "bodyRef"),
			field("bodyB", "bodyRef"),
			field("anchorA", "vector"),
			field("anchorB", "vector"),
			field("frequency", "number"),
			field("damping", "number"),
		],
	},
	{
		type: "Phyx.Friction",
		fields: [
			field("name", "string"),
			field("collision", "boolean"),
			field("bodyA", "bodyRef"),
			field("bodyB", "bodyRef"),
			field("worldPos", "vector"),
			field("maxForce", "number"),
			field("maxTorque", "number"),
		],
	},
	{
		type: "Phyx.Gear",
		fields: [
			field("name", "string"),
			field("collision", "boolean"),
			field("jointA", "jointRef"),
			field("jointB", "jointRef"),
			field("ratio", "number"),
		],
	},
	{
		type: "Phyx.Spring",
		fields: [
			field("name", "string"),
			field("collision", "boolean"),
			field("bodyA", "bodyRef"),
			field("bodyB", "bodyRef"),
			field("linearOffset", "vector"),
			field("angularOffset", "number"),
			field("maxForce", "number"),
			field("maxTorque", "number"),
			field("correctionFactor", "number"),
		],
	},
	{
		type: "Phyx.Prismatic",
		fields: [
			field("name", "string"),
			field("collision", "boolean"),
			field("bodyA", "bodyRef"),
			field("bodyB", "bodyRef"),
			field("worldPos", "vector"),
			field("axis", "vector"),
			field("lowerTranslation", "number"),
			field("upperTranslation", "number"),
			field("maxMotorForce", "number"),
			field("motorSpeed", "number"),
		],
	},
	{
		type: "Phyx.Pulley",
		fields: [
			field("name", "string"),
			field("collision", "boolean"),
			field("bodyA", "bodyRef"),
			field("bodyB", "bodyRef"),
			field("anchorA", "vector"),
			field("anchorB", "vector"),
			field("groundAnchorA", "vector"),
			field("groundAnchorB", "vector"),
			field("ratio", "number"),
		],
	},
	{
		type: "Phyx.Revolute",
		fields: [
			field("name", "string"),
			field("collision", "boolean"),
			field("bodyA", "bodyRef"),
			field("bodyB", "bodyRef"),
			field("worldPos", "vector"),
			field("lowerAngle", "number"),
			field("upperAngle", "number"),
			field("maxMotorTorque", "number"),
			field("motorSpeed", "number"),
		],
	},
	{
		type: "Phyx.Rope",
		fields: [
			field("name", "string"),
			field("collision", "boolean"),
			field("bodyA", "bodyRef"),
			field("bodyB", "bodyRef"),
			field("anchorA", "vector"),
			field("anchorB", "vector"),
			field("maxLength", "number"),
		],
	},
	{
		type: "Phyx.Weld",
		fields: [
			field("name", "string"),
			field("collision", "boolean"),
			field("bodyA", "bodyRef"),
			field("bodyB", "bodyRef"),
			field("worldPos", "vector"),
			field("frequency", "number"),
			field("damping", "number"),
		],
	},
	{
		type: "Phyx.Wheel",
		fields: [
			field("name", "string"),
			field("collision", "boolean"),
			field("bodyA", "bodyRef"),
			field("bodyB", "bodyRef"),
			field("worldPos", "vector"),
			field("axis", "vector"),
			field("maxMotorTorque", "number"),
			field("motorSpeed", "number"),
			field("frequency", "number"),
			field("damping", "number"),
		],
	},
] as const satisfies readonly BodyStructDefinition[];

export const BODY_STRUCTS = [
	...BODY_SHAPE_STRUCTS,
	...BODY_SUB_SHAPE_STRUCTS,
	...BODY_JOINT_STRUCTS,
] as const satisfies readonly BodyStructDefinition[];

export const BODY_STRUCTS_BY_TYPE: Readonly<Record<BodyStructType, BodyStructDefinition>> = Object.freeze(
	Object.fromEntries(BODY_STRUCTS.map((definition) => [definition.type, definition])) as unknown as Record<
		BodyStructType,
		BodyStructDefinition
	>,
);

export const BODY_EDITOR_SAMPLE_BODY_LUA = `return {
	"Array",
	{"Phyx.Rect","rectHero","Dynamic",{0,120},0,{0,0},{160,80},1,0.4,0.1,0.05,0.02,false,{0,-10},false,false,0,{
		{"Phyx.SubRect",{0,-54},0,{120,20},0.8,0.4,0.1,false,0},
		{"Phyx.SubDisk",{88,0},24,0.8,0.3,0.2,true,7},
		{"Phyx.SubPoly",{{-60,48},{-20,92},{20,48}},0.7,0.35,0.15,false,0},
		{"Phyx.SubChain",{{-80,-60},{-30,-90},{40,-72},{90,-100}},0.45,0.05}
	},"Images/hero.png",{0,8}},
	{"Phyx.Disk","diskSensor","Dynamic",{260,130},0,{0,0},48,0.9,0.2,0.4,0.04,0.01,false,{12,-10},false,true,2,{},"Atlas/actors.clip|idle",{6,4}},
	{"Phyx.Poly","polyGround","Static",{0,-80},0,{{-180,0},{180,0},{120,-40},{-140,-60}},1,0.7,0,0,0,true,{0,0},false,false,0,{},"",{0,0}},
	{"Phyx.Chain","chainGuide","Kinematic",{-220,40},0,{{-60,0},{-20,28},{24,10},{70,42}},0.5,0.05,0,0,false,{0,0},false,{},"",{0,0}},
	{"Phyx.Revolute","revHeroGround",false,"rectHero","polyGround",{0,80},-45,45,200,0},
	{"Phyx.Prismatic","slideHero",false,"rectHero","polyGround",{0,120},{1,0},-80,80,150,0},
	{"Phyx.Distance","distanceDisk",false,"rectHero","diskSensor",{0,0},{0,0},4,0.7},
	{"Phyx.Friction","frictionDisk",true,"diskSensor","polyGround",{260,80},20,10},
	{"Phyx.Spring","springGuide",false,"diskSensor","chainGuide",{30,10},0,120,45,0.3},
	{"Phyx.Pulley","pulleyPair",false,"rectHero","diskSensor",{0,0},{0,0},{-120,240},{240,260},1},
	{"Phyx.Rope","ropeLimit",false,"rectHero","diskSensor",{0,0},{0,0},280},
	{"Phyx.Weld","weldGuide",true,"chainGuide","polyGround",{-180,20},3,0.5},
	{"Phyx.Wheel","wheelDisk",false,"diskSensor","polyGround",{260,92},{0,1},300,0,4,0.8},
	{"Phyx.Gear","gearMotors",false,"revHeroGround","slideHero",1.5}
}`;
