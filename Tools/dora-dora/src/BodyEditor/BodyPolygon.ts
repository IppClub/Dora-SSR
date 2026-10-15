import { BodyVector } from "./BodyDocument";

const EPSILON = 0.000001;

const clonePoint = (point: BodyVector): BodyVector => [point[0], point[1]];

const samePoint = (a: BodyVector, b: BodyVector) => (
	Math.abs(a[0] - b[0]) <= EPSILON && Math.abs(a[1] - b[1]) <= EPSILON
);

const cross = (a: BodyVector, b: BodyVector, c: BodyVector) => (
	(b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
);

export const normalizeBodyPolygon = (vertices: BodyVector[]) => {
	const result: BodyVector[] = [];
	for (const vertex of vertices) {
		if (!Number.isFinite(vertex[0]) || !Number.isFinite(vertex[1])) continue;
		const point = clonePoint(vertex);
		if (result.length > 0 && samePoint(result[result.length - 1], point)) continue;
		result.push(point);
	}
	if (result.length > 1 && samePoint(result[0], result[result.length - 1])) result.pop();
	return result;
};

export const bodyPolygonSignedArea = (vertices: BodyVector[]) => {
	let area = 0;
	for (let i = 0; i < vertices.length; i++) {
		const a = vertices[i];
		const b = vertices[(i + 1) % vertices.length];
		area += a[0] * b[1] - b[0] * a[1];
	}
	return area * 0.5;
};

const pointInTriangle = (point: BodyVector, a: BodyVector, b: BodyVector, c: BodyVector) => {
	const ab = cross(a, b, point);
	const bc = cross(b, c, point);
	const ca = cross(c, a, point);
	const hasNegative = ab < -EPSILON || bc < -EPSILON || ca < -EPSILON;
	const hasPositive = ab > EPSILON || bc > EPSILON || ca > EPSILON;
	return !(hasNegative && hasPositive);
};

const orientation = (a: BodyVector, b: BodyVector, c: BodyVector) => {
	const value = cross(a, b, c);
	if (Math.abs(value) <= EPSILON) return 0;
	return value > 0 ? 1 : -1;
};

const onSegment = (point: BodyVector, a: BodyVector, b: BodyVector) => (
	Math.min(a[0], b[0]) - EPSILON <= point[0]
	&& point[0] <= Math.max(a[0], b[0]) + EPSILON
	&& Math.min(a[1], b[1]) - EPSILON <= point[1]
	&& point[1] <= Math.max(a[1], b[1]) + EPSILON
	&& Math.abs(cross(a, b, point)) <= EPSILON
);

const segmentsIntersect = (a: BodyVector, b: BodyVector, c: BodyVector, d: BodyVector) => {
	const o1 = orientation(a, b, c);
	const o2 = orientation(a, b, d);
	const o3 = orientation(c, d, a);
	const o4 = orientation(c, d, b);
	if (o1 !== o2 && o3 !== o4) return true;
	if (o1 === 0 && onSegment(c, a, b)) return true;
	if (o2 === 0 && onSegment(d, a, b)) return true;
	if (o3 === 0 && onSegment(a, c, d)) return true;
	if (o4 === 0 && onSegment(b, c, d)) return true;
	return false;
};

const isSelfIntersecting = (vertices: BodyVector[]) => {
	for (let i = 0; i < vertices.length; i++) {
		const a = vertices[i];
		const b = vertices[(i + 1) % vertices.length];
		for (let j = i + 1; j < vertices.length; j++) {
			if (Math.abs(i - j) <= 1) continue;
			if (i === 0 && j === vertices.length - 1) continue;
			const c = vertices[j];
			const d = vertices[(j + 1) % vertices.length];
			if (segmentsIntersect(a, b, c, d)) return true;
		}
	}
	return false;
};

const isConvexPolygon = (vertices: BodyVector[]) => {
	if (vertices.length <= 3) return true;
	const winding = bodyPolygonSignedArea(vertices) >= 0 ? 1 : -1;
	for (let i = 0; i < vertices.length; i++) {
		const a = vertices[(i + vertices.length - 1) % vertices.length];
		const b = vertices[i];
		const c = vertices[(i + 1) % vertices.length];
		if (cross(a, b, c) * winding <= EPSILON) return false;
	}
	return true;
};

const uniquePoints = (vertices: BodyVector[]) => {
	const result: BodyVector[] = [];
	for (const vertex of vertices) {
		if (!result.some((point) => samePoint(point, vertex))) result.push(clonePoint(vertex));
	}
	return result;
};

const convexHull = (vertices: BodyVector[]) => {
	const points = uniquePoints(vertices)
		.sort((a, b) => a[0] === b[0] ? a[1] - b[1] : a[0] - b[0]);
	if (points.length <= 1) return points;
	const lower: BodyVector[] = [];
	for (const point of points) {
		while (lower.length >= 2 && cross(lower[lower.length - 2], lower[lower.length - 1], point) <= EPSILON) lower.pop();
		lower.push(point);
	}
	const upper: BodyVector[] = [];
	for (let i = points.length - 1; i >= 0; i--) {
		const point = points[i];
		while (upper.length >= 2 && cross(upper[upper.length - 2], upper[upper.length - 1], point) <= EPSILON) upper.pop();
		upper.push(point);
	}
	lower.pop();
	upper.pop();
	return [...lower, ...upper];
};

const countSharedPoints = (a: BodyVector[], b: BodyVector[]) => {
	let count = 0;
	for (const point of a) {
		if (b.some((candidate) => samePoint(candidate, point))) count++;
	}
	return count;
};

const polygonAbsArea = (vertices: BodyVector[]) => Math.abs(bodyPolygonSignedArea(vertices));

const tryMergeConvexParts = (a: BodyVector[], b: BodyVector[], maxConvexVertices: number) => {
	if (countSharedPoints(a, b) < 2) return null;
	const hull = convexHull([...a, ...b]);
	if (hull.length < 3 || hull.length > maxConvexVertices) return null;
	if (!isConvexPolygon(hull)) return null;
	const expectedArea = polygonAbsArea(a) + polygonAbsArea(b);
	if (Math.abs(polygonAbsArea(hull) - expectedArea) > Math.max(EPSILON, expectedArea * EPSILON)) return null;
	return hull;
};

const mergeConvexParts = (parts: BodyVector[][], maxConvexVertices: number) => {
	const result = parts.map((part) => part.map(clonePoint));
	let changed = true;
	while (changed) {
		changed = false;
		for (let i = 0; i < result.length && !changed; i++) {
			for (let j = i + 1; j < result.length; j++) {
				const merged = tryMergeConvexParts(result[i], result[j], maxConvexVertices);
				if (!merged) continue;
				result[i] = merged;
				result.splice(j, 1);
				changed = true;
				break;
			}
		}
	}
	return result;
};

export type BodyPolygonDecomposeResult = {
	parts: BodyVector[][];
	diagnostics: string[];
};

export const decomposeBodyPolygon = (vertices: BodyVector[], maxConvexVertices = 12): BodyPolygonDecomposeResult => {
	const polygon = normalizeBodyPolygon(vertices);
	const diagnostics: string[] = [];
	if (polygon.length < 3) {
		return { parts: [], diagnostics: ["requires at least 3 vertices"] };
	}
	if (Math.abs(bodyPolygonSignedArea(polygon)) <= EPSILON) {
		return { parts: [], diagnostics: ["has zero area"] };
	}
	if (isSelfIntersecting(polygon)) {
		return { parts: [], diagnostics: ["self intersecting polygons are not supported"] };
	}
	if (polygon.length <= maxConvexVertices && isConvexPolygon(polygon)) {
		return { parts: [polygon], diagnostics };
	}
	const winding = bodyPolygonSignedArea(polygon) >= 0 ? 1 : -1;
	const indices = polygon.map((_, index) => index);
	const parts: BodyVector[][] = [];
	let guard = polygon.length * polygon.length;
	while (indices.length > 3 && guard > 0) {
		guard--;
		let earIndex = -1;
		for (let i = 0; i < indices.length; i++) {
			const prevIndex = indices[(i + indices.length - 1) % indices.length];
			const currIndex = indices[i];
			const nextIndex = indices[(i + 1) % indices.length];
			const prev = polygon[prevIndex];
			const curr = polygon[currIndex];
			const next = polygon[nextIndex];
			if (cross(prev, curr, next) * winding <= EPSILON) continue;
			let containsPoint = false;
			for (const candidateIndex of indices) {
				if (candidateIndex === prevIndex || candidateIndex === currIndex || candidateIndex === nextIndex) continue;
				if (pointInTriangle(polygon[candidateIndex], prev, curr, next)) {
					containsPoint = true;
					break;
				}
			}
			if (!containsPoint) {
				parts.push([clonePoint(prev), clonePoint(curr), clonePoint(next)]);
				earIndex = i;
				break;
			}
		}
		if (earIndex < 0) break;
		indices.splice(earIndex, 1);
	}
	if (indices.length === 3) {
		parts.push(indices.map((index) => clonePoint(polygon[index])));
	}
	if (parts.length === 0 || indices.length > 3) {
		return { parts: [], diagnostics: ["failed to decompose polygon"] };
	}
	return { parts: mergeConvexParts(parts, maxConvexVertices), diagnostics };
};
