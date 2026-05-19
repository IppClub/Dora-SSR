import type { BodyStructDocument } from "./BodyDocument";

export type BodyNumberAxis = "X" | "Y";

export type BodyNumberConstraint = {
	min?: number;
	max?: number;
	step?: number;
	integer?: boolean;
};

const positiveSizeConstraint: BodyNumberConstraint = { min: 0.01, step: 1 };
const unitConstraint: BodyNumberConstraint = { min: 0, max: 1, step: 0.01 };
const nonNegativeConstraint: BodyNumberConstraint = { min: 0, step: 0.1 };
const nonNegativeIntegerConstraint: BodyNumberConstraint = { min: 0, step: 1, integer: true };
const correctionFactorConstraint: BodyNumberConstraint = { min: 0, max: 1, step: 0.01 };
const pulleyRatioConstraint: BodyNumberConstraint = { min: 0.01, step: 0.1 };
const faceScaleConstraint: BodyNumberConstraint = { step: 0.1 };

export const getBodyNumberConstraint = (
	item: BodyStructDocument,
	fieldName: string,
	_axis?: BodyNumberAxis,
): BodyNumberConstraint | undefined => {
	switch (fieldName) {
		case "size":
		case "radius":
			return positiveSizeConstraint;
		case "friction":
		case "restitution":
			return unitConstraint;
		case "density":
		case "linearDamping":
		case "angularDamping":
		case "frequency":
		case "damping":
		case "maxForce":
		case "maxTorque":
		case "maxMotorForce":
		case "maxMotorTorque":
		case "maxLength":
			return nonNegativeConstraint;
		case "sensorTag":
			return nonNegativeIntegerConstraint;
		case "correctionFactor":
			return correctionFactorConstraint;
		case "ratio":
			return item.structType === "Phyx.Pulley" ? pulleyRatioConstraint : undefined;
		case "faceScale":
			return faceScaleConstraint;
		default:
			return undefined;
	}
};

export const applyBodyNumberConstraint = (value: number, constraint?: BodyNumberConstraint) => {
	if (!Number.isFinite(value)) return 0;
	if (!constraint) return value;
	let next = value;
	if (constraint.integer) next = Math.round(next);
	if (constraint.min !== undefined && next < constraint.min) next = constraint.min;
	if (constraint.max !== undefined && next > constraint.max) next = constraint.max;
	return Object.is(next, -0) ? 0 : next;
};

export const validateBodyNumberValue = (
	value: number,
	constraint?: BodyNumberConstraint,
): string | null => {
	if (!Number.isFinite(value)) return "must be a finite number";
	if (!constraint) return null;
	if (constraint.integer && Math.round(value) !== value) return "must be an integer";
	if (constraint.min !== undefined && value < constraint.min) {
		return constraint.max !== undefined
			? `must be between ${constraint.min} and ${constraint.max}`
			: `must be greater than or equal to ${constraint.min}`;
	}
	if (constraint.max !== undefined && value > constraint.max) {
		return constraint.min !== undefined
			? `must be between ${constraint.min} and ${constraint.max}`
			: `must be less than or equal to ${constraint.max}`;
	}
	return null;
};
