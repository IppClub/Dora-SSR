/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/DrawNode.h"

#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Cache/ShaderCache.h"
#include "Effect/Effect.h"
#include "Render/View.h"

NS_DORA_BEGIN

namespace {

constexpr float PolygonEpsilon = 1.0e-5f;

bool Finite(const Vec2& point) {
	return std::isfinite(point.x) && std::isfinite(point.y);
}

bool SamePoint(const Vec2& a, const Vec2& b) {
	return a.x == b.x && a.y == b.y;
}

Vec2 Direction(const Vec2& from, const Vec2& to) {
	const double x = double(to.x) - from.x, y = double(to.y) - from.y;
	const double length = std::hypot(x, y);
	return length > 0 ? Vec2{s_cast<float>(x / length), s_cast<float>(y / length)} : Vec2::zero;
}

Vec2 CirclePoint(double x, double y, float radius, double degrees) {
	const double angle = std::remainder(degrees, 360.0);
	const double radians = angle * std::acos(-1.0) / 180.0;
	// Exact quadrant endpoints prevent tiny duplicate edges at contour joins.
	const double cosine = angle == 0 ? 1 : std::abs(angle) == 180 ? -1 : std::abs(angle) == 90 ? 0 : std::cos(radians);
	const double sine = angle == 0 || std::abs(angle) == 180 ? 0 : angle == 90 ? 1 : angle == -90 ? -1 : std::sin(radians);
	return {s_cast<float>(x + cosine * radius), s_cast<float>(y + sine * radius)};
}

uint32_t ArcSegments(float radius, double sweep) {
	const double tolerance = std::min(0.25, double(radius) * 0.01);
	const double step = std::clamp(2.0 * std::acos(std::clamp(1.0 - tolerance / radius, -1.0, 1.0)), 1.0e-6, std::acos(-1.0) * 0.5);
	return std::clamp(s_cast<uint32_t>(std::min(512.0, std::ceil(std::abs(sweep) / step))),
		std::abs(sweep) >= 2.0 * std::acos(-1.0) ? 3u : 1u, 512u);
}

std::vector<Vec2> ArcPoints(const Vec2& center, float radius, double startDegrees, double sweepDegrees) {
	const double start = std::remainder(startDegrees, 360.0);
	const double sweep = sweepDegrees * std::acos(-1.0) / 180.0;
	const uint32_t segments = ArcSegments(radius, sweep);
	std::vector<Vec2> points;
	points.reserve(segments + 1);
	for (uint32_t i = 0; i <= segments; i++) {
		points.push_back(CirclePoint(center.x, center.y, radius, start + sweepDegrees * (double(i) / segments)));
	}
	return points;
}

double DistanceToSegmentSquared(const Vec2& point, const Vec2& from, const Vec2& to) {
	const double dx = double(to.x) - from.x, dy = double(to.y) - from.y;
	const double length = dx * dx + dy * dy;
	const double t = length > 0 ? std::clamp(((double(point.x) - from.x) * dx + (double(point.y) - from.y) * dy) / length, 0.0, 1.0) : 0;
	const double x = double(point.x) - from.x - t * dx, y = double(point.y) - from.y - t * dy;
	return x * x + y * y;
}

// The control hull bounds the curve. Segment distance, rather than infinite
// line distance, preserves collinear curves that overshoot their endpoints.
template <size_t Count>
void FlattenBezier(const std::array<Vec2, Count>& controls, std::vector<Vec2>& points, uint32_t depth = 0, double toleranceSquared = -1) {
	if (toleranceSquared < 0) {
		double left = controls[0].x, right = left, bottom = controls[0].y, top = bottom;
		for (const Vec2& point : controls) {
			left = std::min(left, double(point.x)); right = std::max(right, double(point.x));
			bottom = std::min(bottom, double(point.y)); top = std::max(top, double(point.y));
		}
		const double tolerance = std::min(0.25, std::hypot(right - left, top - bottom) * 0.01);
		toleranceSquared = tolerance * tolerance;
	}
	bool flat = true;
	for (size_t i = 1; i + 1 < Count; i++) {
		if (DistanceToSegmentSquared(controls[i], controls.front(), controls.back()) > toleranceSquared) flat = false;
	}
	if (flat || depth == 10) {
		if (points.empty() || !SamePoint(points.back(), controls.back())) points.push_back(controls.back());
		return;
	}
	std::array<Vec2, Count> left, right, work = controls;
	left.front() = controls.front();
	right.back() = controls.back();
	for (size_t level = 1; level < Count; level++) {
		for (size_t i = 0; i < Count - level; i++) work[i] = work[i] * 0.5f + work[i + 1] * 0.5f;
		left[level] = work[0];
		right[Count - level - 1] = work[Count - level - 1];
	}
	FlattenBezier(left, points, depth + 1, toleranceSquared);
	FlattenBezier(right, points, depth + 1, toleranceSquared);
}

// Strictly convex outlines with one revolution can skip the quadratic
// intersection check. The revolution check excludes star-shaped outlines.
bool IsConvex(const std::vector<Vec2>& polygon) {
	double rotation = 0.0;
	float sign = 0.0f;
	for (size_t i = 0; i < polygon.size(); i++) {
		const Vec2 a = polygon[i] - polygon[(i + polygon.size() - 1) % polygon.size()];
		const Vec2 b = polygon[(i + 1) % polygon.size()] - polygon[i];
		const double cross = double(a.x) * b.y - double(a.y) * b.x;
		if (std::abs(cross) <= PolygonEpsilon) return false;
		if (sign == 0.0f) sign = cross > 0.0 ? 1.0f : -1.0f;
		if (cross * sign <= 0.0) return false;
		rotation += std::atan2(cross, double(a.x) * b.x + double(a.y) * b.y);
	}
	return std::abs(std::abs(rotation) - 2.0 * std::acos(-1.0)) < 1.0e-4;
}

struct DrawingMesh {
	std::vector<DrawVertexInput> vertices;
	std::vector<uint16_t> indices;
	bool valid = true;

	uint16_t add(const Vec2& point, const Vec4& color, const Vec2& coord) {
		if (vertices.size() >= 65536 || !Finite(point)) {
			valid = false;
			return 0;
		}
		const auto index = s_cast<uint16_t>(vertices.size());
		vertices.push_back({{point.x, point.y, 0, 1}, color, coord});
		return index;
	}

	void triangle(uint16_t a, uint16_t b, uint16_t c) {
		if (a != b && b != c && c != a) indices.insert(indices.end(), {a, b, c});
	}
};

// A convex disk or an annulus between corresponding contour samples. The
// border has one coverage layer, including where inward offsets collapse.
void BuildContourBand(DrawingMesh& mesh, const std::vector<Vec2>& outer, const std::vector<Vec2>* inner, const Vec2& center, const Vec4& color, bool smooth) {
	const uint16_t base = s_cast<uint16_t>(mesh.vertices.size());
	const Vec2 outerCoord = smooth ? Vec2{1, 0} : Vec2::zero;
	if (!inner) {
		mesh.add(center, color, Vec2::zero);
		for (const Vec2& point : outer) mesh.add(point, color, outerCoord);
		if (!mesh.valid) return;
		for (size_t i = 0; i < outer.size(); i++) mesh.triangle(base, base + s_cast<uint16_t>(i + 1), base + s_cast<uint16_t>((i + 1) % outer.size() + 1));
	} else {
		const Vec2 innerCoord = smooth ? Vec2{-1, 0} : Vec2::zero;
		for (size_t i = 0; i < outer.size(); i++) {
			mesh.add(outer[i], color, outerCoord);
			mesh.add((*inner)[i], color, innerCoord);
		}
		if (!mesh.valid) return;
		for (size_t i = 0; i < outer.size(); i++) {
			const auto a = s_cast<uint16_t>(base + i * 2), b = s_cast<uint16_t>(base + ((i + 1) % outer.size()) * 2);
			mesh.triangle(a, b, a + 1);
			mesh.triangle(b, b + 1, a + 1);
		}
	}
}

std::vector<Vec2> RoundedContour(double left, double bottom, double right, double top, float radius, uint32_t segments) {
	const double centers[][2] = {{right - radius, bottom + radius}, {right - radius, top - radius},
		{left + radius, top - radius}, {left + radius, bottom + radius}};
	std::vector<Vec2> points;
	points.reserve(4 * (segments + 1));
	for (size_t i = 0; i < 4; i++) {
		for (uint32_t j = 0; j <= segments; j++) points.push_back(CirclePoint(centers[i][0], centers[i][1], radius, double(i) * 90 - 90 + double(j) * 90 / segments));
	}
	return points;
}

std::vector<Vec2> CircleContour(const Vec2& center, float radius, uint32_t segments) {
	std::vector<Vec2> points;
	points.reserve(segments);
	for (uint32_t i = 0; i < segments; i++) points.push_back(CirclePoint(center.x, center.y, radius, double(i) * 360 / segments));
	return points;
}

// One indexed strip, with shared joins and separate round end caps. Adjacent
// segments partition each join instead of blending overlapping capsules.
void BuildStroke(DrawingMesh& mesh, const Vec2* points, size_t count, float radius, const Vec4& color, bool closed) {
	struct Section { uint16_t left, right; };
	std::vector<Section> sections;
	auto section = [&](const Vec2& left, const Vec2& right) {
		sections.push_back({mesh.add(left, color, {1, 0}), mesh.add(right, color, {-1, 0})});
	};
	const size_t extraVertices = std::min(count * 2 + 8, size_t(65536) - mesh.vertices.size());
	mesh.vertices.reserve(mesh.vertices.size() + extraVertices);
	mesh.indices.reserve(mesh.indices.size() + std::min(count * 12 + 12, size_t(393216)));
	sections.reserve(std::min(count, size_t(65536)));
	for (size_t i = 0; i < count && mesh.valid; i++) {
		const Vec2& point = points[i];
		if (!closed && (i == 0 || i + 1 == count)) {
			const Vec2 normal = Vec2::perp(i == 0 ? Direction(point, points[1]) : Direction(points[i - 1], point));
			section(point + normal * radius, point - normal * radius);
			continue;
		}
		const Vec2& previous = points[(i + count - 1) % count];
		const Vec2& next = points[(i + 1) % count];
		const Vec2 incoming = Direction(previous, point), outgoing = Direction(point, next);
		const Vec2 n1 = Vec2::perp(incoming), n2 = Vec2::perp(outgoing);
		const float denominator = 1.0f + n1.dot(n2);
		const Vec2 offset = denominator > PolygonEpsilon ? (n1 + n2) / denominator : Vec2::zero;
		const float length = offset.length();
		// Bound the inner join by the adjoining segment lengths. Sharp outer
		// joins use a real bevel rather than a truncated miter spike.
		const double maxInner = std::min(std::hypot(double(point.x) - previous.x, double(point.y) - previous.y),
			std::hypot(double(next.x) - point.x, double(next.y) - point.y)) * 0.5;
		const float tangent = std::sqrt(std::max(0.0f, length * length - 1.0f));
		const float innerRadius = tangent > PolygonEpsilon ? s_cast<float>(std::min(double(radius), maxInner / tangent)) : radius;
		if (denominator > PolygonEpsilon && length <= 4.0f && innerRadius == radius) {
			section(point + offset * radius, point - offset * radius);
		} else {
			const float turn = incoming.x * outgoing.y - incoming.y * outgoing.x;
			const Vec2 inner = point + offset * innerRadius * (turn >= 0 ? 1.0f : -1.0f);
			if (turn >= 0) {
				section(inner, point - n1 * radius);
				section(inner, point - n2 * radius);
			} else {
				section(point + n1 * radius, inner);
				section(point + n2 * radius, inner);
			}
		}
	}
	if (!mesh.valid) return;
	for (size_t i = 0; i < sections.size() - (closed ? 0 : 1); i++) {
		const Section a = sections[i];
		const Section b = sections[(i + 1) % sections.size()];
		mesh.triangle(a.left, a.right, b.right);
		mesh.triangle(a.left, b.right, b.left);
	}
	if (!closed) {
		for (size_t i : {size_t(0), count - 1}) {
			const Vec2 direction = i == 0 ? Direction(points[1], points[0]) : Direction(points[i - 1], points[i]);
			const Vec2 normal = Vec2::perp(direction);
			const Vec2& point = points[i];
			const uint16_t a = mesh.add(point + normal * radius, color, normal);
			const uint16_t b = mesh.add(point - normal * radius, color, -normal);
			const uint16_t c = mesh.add(point + (normal + direction) * radius, color, normal + direction);
			const uint16_t d = mesh.add(point + (direction - normal) * radius, color, direction - normal);
			mesh.triangle(a, b, d);
			mesh.triangle(a, d, c);
		}
	}
}

void BuildStroke(DrawingMesh& mesh, const std::vector<Vec2>& points, float radius, const Vec4& color, bool closed) {
	BuildStroke(mesh, points.data(), points.size(), radius, color, closed);
}

// Remove overlap from a closed sector's stroke triangles. Each triangle is
// clipped against earlier triangles; texture coordinates are interpolated so
// the existing edge shader remains valid. Bounding boxes skip distant edges.
void MakeSingleCoverage(DrawingMesh& mesh) {
	struct Point { double x, y, u, v; };
	using Polygon = std::vector<Point>;
	struct Triangle { std::array<Point, 3> points; double left, bottom, right, top, sign; };
	auto cross = [](const Point& a, const Point& b, const Point& p) {
		return (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x);
	};
	auto clip = [&](Polygon polygon, const Point& a, const Point& b, double sign, bool inside) {
		Polygon output;
		if (polygon.empty()) return output;
		size_t retained = 0;
		for (const Point& point : polygon) {
			const double distance = cross(a, b, point) * sign;
			if (inside ? distance >= 0 : distance <= 0) retained++;
		}
		if (retained == polygon.size()) return polygon;
		if (retained == 0) return output;
		output.reserve(polygon.size() + 1);
		Point previous = polygon.back();
		double prevDistance = cross(a, b, previous) * sign;
		for (const Point& current : polygon) {
			const double distance = cross(a, b, current) * sign;
			const bool prevIn = inside ? prevDistance >= 0 : prevDistance <= 0;
			const bool currentIn = inside ? distance >= 0 : distance <= 0;
			if (prevIn != currentIn) {
				const double t = prevDistance / (prevDistance - distance);
				output.push_back({previous.x + (current.x - previous.x) * t, previous.y + (current.y - previous.y) * t,
					previous.u + (current.u - previous.u) * t, previous.v + (current.v - previous.v) * t});
			}
			if (currentIn) output.push_back(current);
			previous = current;
			prevDistance = distance;
		}
		return output;
	};
	auto area = [&](const Polygon& polygon) {
		double value = 0;
		for (size_t i = 1; i + 1 < polygon.size(); i++) value += cross(polygon[0], polygon[i], polygon[i + 1]);
		return std::abs(value);
	};
	std::vector<Triangle> triangles;
	triangles.reserve(mesh.indices.size() / 3);
	for (size_t i = 0; i < mesh.indices.size(); i += 3) {
		Triangle triangle;
		for (size_t j = 0; j < 3; j++) {
			const auto& vertex = mesh.vertices[mesh.indices[i + j]];
			triangle.points[j] = {vertex.position.x, vertex.position.y, vertex.texCoord.x, vertex.texCoord.y};
		}
		const auto& p = triangle.points;
		triangle.left = std::min({p[0].x, p[1].x, p[2].x}); triangle.right = std::max({p[0].x, p[1].x, p[2].x});
		triangle.bottom = std::min({p[0].y, p[1].y, p[2].y}); triangle.top = std::max({p[0].y, p[1].y, p[2].y});
		triangle.sign = cross(p[0], p[1], p[2]) >= 0 ? 1 : -1;
		triangles.push_back(triangle);
	}
	std::vector<size_t> order(triangles.size());
	std::iota(order.begin(), order.end(), size_t(0));
	std::sort(order.begin(), order.end(), [&](size_t a, size_t b) { return triangles[a].left < triangles[b].left; });
	std::vector<std::vector<size_t>> overlaps(triangles.size());
	bool anyOverlap = false;
	auto separated = [&](const Triangle& a, const Triangle& b) {
		for (size_t edge = 0; edge < 3; edge++) {
			bool outside = true;
			for (const Point& point : b.points) {
				if (cross(a.points[edge], a.points[(edge + 1) % 3], point) * a.sign > 0) outside = false;
			}
			if (outside) return true;
		}
		return false;
	};
	for (size_t i = 0; i < order.size(); i++) {
		const auto& a = triangles[order[i]];
		for (size_t j = i + 1; j < order.size(); j++) {
			const auto& b = triangles[order[j]];
			if (b.left >= a.right) break;
			if (a.top <= b.bottom || a.bottom >= b.top || separated(a, b) || separated(b, a)) continue;
			overlaps[std::max(order[i], order[j])].push_back(std::min(order[i], order[j]));
			anyOverlap = true;
		}
	}
	if (!anyOverlap) return;
	DrawingMesh output;
	output.vertices = mesh.vertices;
	output.indices.reserve(mesh.indices.size());
	for (size_t i = 0; i < triangles.size(); i++) {
		const auto& triangle = triangles[i];
		std::vector<Polygon> pieces = {Polygon(triangle.points.begin(), triangle.points.end())};
		bool changed = false;
		std::sort(overlaps[i].begin(), overlaps[i].end());
		for (size_t j : overlaps[i]) {
			if (pieces.empty()) break;
			const auto& other = triangles[j];
			std::vector<Polygon> remaining;
			for (Polygon& piece : pieces) {
				// Earlier subtractions shrink each piece. Most original triangle
				// overlaps no longer reach it; test the remaining piece before
				// allocating intersection and difference polygons.
				bool disjoint = false, contained = true;
				for (size_t edge = 0; edge < 3; edge++) {
					double minimum = std::numeric_limits<double>::max(), maximum = -minimum;
					for (const Point& point : piece) {
						const double distance = cross(other.points[edge], other.points[(edge + 1) % 3], point) * other.sign;
						minimum = std::min(minimum, distance); maximum = std::max(maximum, distance);
					}
					if (maximum <= 0) { disjoint = true; break; }
					if (minimum < 0) contained = false;
				}
				if (disjoint) {
					remaining.push_back(std::move(piece));
					continue;
				}
				if (contained && area(piece) > 0) {
					changed = true;
					continue;
				}
				Polygon intersection = piece;
				for (size_t edge = 0; edge < 3 && !intersection.empty(); edge++) intersection = clip(std::move(intersection), other.points[edge], other.points[(edge + 1) % 3], other.sign, true);
				// Relative threshold discards numerical slivers along shared joins.
				if (area(intersection) <= area(piece) * 1e-10) {
					remaining.push_back(std::move(piece));
					continue;
				}
				changed = true;
				Polygon inside = piece;
				for (size_t edge = 0; edge < 3 && !inside.empty(); edge++) {
					auto outside = clip(inside, other.points[edge], other.points[(edge + 1) % 3], other.sign, false);
					if (area(outside) > 0) remaining.push_back(std::move(outside));
					inside = clip(std::move(inside), other.points[edge], other.points[(edge + 1) % 3], other.sign, true);
				}
			}
			pieces = std::move(remaining);
		}
		if (!changed) output.indices.insert(output.indices.end(), mesh.indices.begin() + i * 3, mesh.indices.begin() + i * 3 + 3);
		else for (const Polygon& piece : pieces) {
			const auto base = s_cast<uint16_t>(output.vertices.size());
			for (const Point& point : piece) output.add({s_cast<float>(point.x), s_cast<float>(point.y)}, mesh.vertices[mesh.indices[i * 3]].color, {s_cast<float>(point.u), s_cast<float>(point.v)});
			if (!output.valid) { mesh.valid = false; return; }
			for (size_t k = 1; k + 1 < piece.size(); k++) output.triangle(base, base + s_cast<uint16_t>(k), base + s_cast<uint16_t>(k + 1));
		}
	}
	mesh = std::move(output);
}

float Cross(const Vec2& a, const Vec2& b, const Vec2& c) {
	return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
}

bool PointInTriangle(const Vec2& point, const Vec2& a, const Vec2& b, const Vec2& c) {
	return Cross(a, b, point) >= -PolygonEpsilon
		&& Cross(b, c, point) >= -PolygonEpsilon
		&& Cross(c, a, point) >= -PolygonEpsilon;
}

bool OnSegment(const Vec2& a, const Vec2& b, const Vec2& point) {
	return std::abs(Cross(a, b, point)) <= PolygonEpsilon
		&& point.x >= std::min(a.x, b.x) - PolygonEpsilon
		&& point.x <= std::max(a.x, b.x) + PolygonEpsilon
		&& point.y >= std::min(a.y, b.y) - PolygonEpsilon
		&& point.y <= std::max(a.y, b.y) + PolygonEpsilon;
}

bool SegmentsIntersect(const Vec2& a, const Vec2& b, const Vec2& c, const Vec2& d) {
	const float abC = Cross(a, b, c);
	const float abD = Cross(a, b, d);
	const float cdA = Cross(c, d, a);
	const float cdB = Cross(c, d, b);
	if (((abC > PolygonEpsilon && abD < -PolygonEpsilon) || (abC < -PolygonEpsilon && abD > PolygonEpsilon))
		&& ((cdA > PolygonEpsilon && cdB < -PolygonEpsilon) || (cdA < -PolygonEpsilon && cdB > PolygonEpsilon))) {
		return true;
	}
	return OnSegment(a, b, c) || OnSegment(a, b, d) || OnSegment(c, d, a) || OnSegment(c, d, b);
}

bool PreparePolygon(const Vec2* verts, uint32_t count, std::vector<Vec2>& polygon) {
	polygon.reserve(count);
	for (uint32_t i = 0; i < count; i++) {
		if (!Finite(verts[i])) return false;
		if (polygon.empty() || polygon.back().distanceSquared(verts[i]) > PolygonEpsilon * PolygonEpsilon) {
			polygon.push_back(verts[i]);
		}
	}
	if (polygon.size() > 1 && polygon.front().distanceSquared(polygon.back()) <= PolygonEpsilon * PolygonEpsilon) {
		polygon.pop_back();
	}
	bool removed = true;
	while (removed && polygon.size() > 3) {
		removed = false;
		for (size_t i = 0; i < polygon.size(); i++) {
			const Vec2& prev = polygon[(i + polygon.size() - 1) % polygon.size()];
			const Vec2& current = polygon[i];
			const Vec2& next = polygon[(i + 1) % polygon.size()];
			if (std::abs(Cross(prev, current, next)) <= PolygonEpsilon && OnSegment(prev, next, current)) {
				polygon.erase(polygon.begin() + i);
				removed = true;
				break;
			}
		}
	}
	if (polygon.size() < 3) return false;
	if (IsConvex(polygon)) return true;
	const size_t size = polygon.size();
	for (size_t i = 0; i < size; i++) {
		const size_t iNext = (i + 1) % size;
		for (size_t j = i + 1; j < size; j++) {
			const size_t jNext = (j + 1) % size;
			if (i == j || iNext == j || jNext == i) continue;
			if (SegmentsIntersect(polygon[i], polygon[iNext], polygon[j], polygon[jNext])) return false;
		}
	}
	return true;
}

bool TriangulatePolygon(const std::vector<Vec2>& polygon, std::vector<uint32_t>& triangles) {
	if (IsConvex(polygon)) {
		triangles.reserve((polygon.size() - 2) * 3);
		for (uint32_t i = 1; i + 1 < polygon.size(); i++) triangles.insert(triangles.end(), {0, i, i + 1});
		return true;
	}
	float area = 0.0f;
	for (size_t i = 0; i < polygon.size(); i++) {
		const Vec2& a = polygon[i];
		const Vec2& b = polygon[(i + 1) % polygon.size()];
		area += a.x * b.y - b.x * a.y;
	}
	if (std::abs(area) <= PolygonEpsilon) return false;
	std::vector<uint32_t> remaining(polygon.size());
	if (area > 0.0f) {
		std::iota(remaining.begin(), remaining.end(), 0u);
	} else {
		for (size_t i = 0; i < polygon.size(); i++) remaining[i] = s_cast<uint32_t>(polygon.size() - 1 - i);
	}
	triangles.reserve((polygon.size() - 2) * 3);
	while (remaining.size() > 3) {
		bool foundEar = false;
		for (size_t i = 0; i < remaining.size(); i++) {
			const uint32_t prev = remaining[(i + remaining.size() - 1) % remaining.size()];
			const uint32_t current = remaining[i];
			const uint32_t next = remaining[(i + 1) % remaining.size()];
			if (Cross(polygon[prev], polygon[current], polygon[next]) <= PolygonEpsilon) continue;
			bool containsPoint = false;
			for (uint32_t index : remaining) {
				if (index == prev || index == current || index == next) continue;
				if (PointInTriangle(polygon[index], polygon[prev], polygon[current], polygon[next])) {
					containsPoint = true;
					break;
				}
			}
			if (containsPoint) continue;
			triangles.insert(triangles.end(), {prev, current, next});
			remaining.erase(remaining.begin() + i);
			foundEar = true;
			break;
		}
		if (!foundEar) return false;
	}
	triangles.insert(triangles.end(), {remaining[0], remaining[1], remaining[2]});
	return true;
}

} // namespace

/* DrawNode */

bgfx::VertexLayout DrawVertex::ms_layout;
DrawVertex::Init DrawVertex::init;

DrawNode::DrawNode()
	: _renderState(BGFX_STATE_NONE)
	, _blendFunc(BlendFunc::Default) { }

void DrawNode::setBlendFunc(const BlendFunc& var) {
	_blendFunc = var;
}

const BlendFunc& DrawNode::getBlendFunc() const noexcept {
	return _blendFunc;
}

void DrawNode::setDepthWrite(bool var) {
	_flags.set(DrawNode::DepthWrite, var);
}

bool DrawNode::isDepthWrite() const noexcept {
	return _flags.isOn(DrawNode::DepthWrite);
}

uint64_t DrawNode::getRenderState() const noexcept {
	return _renderState;
}

const std::vector<DrawVertex>& DrawNode::getVertices() const noexcept {
	return _vertices;
}

const std::vector<uint16_t>& DrawNode::getIndices() const noexcept {
	return _indices;
}

void DrawNode::updateRealColor3() {
	Node::updateRealColor3();
	_flags.setOn(DrawNode::VertexColorDirty);
}

void DrawNode::updateRealOpacity() {
	Node::updateRealOpacity();
	_flags.setOn(DrawNode::VertexColorDirty);
}

const Matrix& DrawNode::getWorld() {
	if (_flags.isOn(Node::WorldDirty)) {
		_flags.setOn(DrawNode::VertexPosDirty);
	}
	return Node::getWorld();
}

bool DrawNode::ensureVertexCapacity(uint64_t additionalVertices) {
	constexpr uint64_t maxVertexCount = static_cast<uint64_t>(std::numeric_limits<uint16_t>::max()) + 1;
	const uint64_t currentVertexCount = _vertices.size();
	if (currentVertexCount <= maxVertexCount
		&& additionalVertices <= maxVertexCount - currentVertexCount) {
		return true;
	}
	if (_flags.isOff(DrawNode::VertexLimitWarned)) {
		_flags.setOn(DrawNode::VertexLimitWarned);
		Warn("DrawNode 16-bit vertex limit exceeded: current={}, requested={}, limit={}. "
			 "Call clear() or split geometry across multiple DrawNodes.",
			currentVertexCount, additionalVertices, maxVertexCount);
	}
	return false;
}

void DrawNode::render() {
	if (_vertices.empty()) {
		Node::render();
		return;
	}

	if (SharedView.isFrustumCulling()) {
		auto [minX, maxX] = std::minmax_element(_posColors.begin(), _posColors.end(), [](const auto& a, const auto& b) {
			return a.pos.x < b.pos.x;
		});
		auto [minY, maxY] = std::minmax_element(_posColors.begin(), _posColors.end(), [](const auto& a, const auto& b) {
			return a.pos.y < b.pos.y;
		});
		AABB aabb;
		Matrix::mulAABB(aabb, getWorld(), {
										  {minX->pos.x, minY->pos.y, 0},
										  {maxX->pos.x, maxY->pos.y, 0},
									  });
		if (!SharedDirector.isInFrustum(aabb)) {
			return;
		}
	}

	if (_flags.isOn(DrawNode::VertexColorDirty)) {
		_flags.setOff(DrawNode::VertexColorDirty);
		Vec4 ucolor = _realColor.toVec4();
		for (size_t i = 0; i < _posColors.size(); i++) {
			const Vec4& acolor = _posColors[i].color;
			Vec4 color{
				acolor.x * ucolor.x,
				acolor.y * ucolor.y,
				acolor.z * ucolor.z,
				acolor.w * ucolor.w};
			_vertices[i].abgr = Color(color).toABGR();
		}
	}

	if (_flags.isOn(DrawNode::VertexPosDirty)) {
		_flags.setOff(DrawNode::VertexPosDirty);
		Matrix transform;
		Matrix::mulMtx(transform, SharedDirector.getViewProjection(), getWorld());
		for (size_t i = 0; i < _vertices.size(); i++) {
			Matrix::mulVec4(&_vertices[i].x, transform, _posColors[i].pos);
		}
	}

	_renderState = BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | _blendFunc.toValue();
	if (_flags.isOn(DrawNode::DepthWrite)) {
		_renderState |= (BGFX_STATE_WRITE_Z | BGFX_STATE_DEPTH_TEST_LESS);
	}

	SharedRendererManager.setCurrent(SharedDrawRenderer.getTarget());
	SharedDrawRenderer.push(this);

	Node::render();
}

void DrawNode::pushVertex(const Vec2& pos, const Vec4& color, const Vec2& coord) {
	_posColors.push_back({{pos.x, pos.y, 0, 1}, color});
	_vertices.push_back({0, 0, 0, 0, 0, coord.x, coord.y});
}

void DrawNode::drawDot(const Vec2& pos, float radius, Color color) {
	drawEllipse(pos, radius, radius, color);
}

void DrawNode::drawCircle(const Vec2& center, float radius, Color color) {
	drawEllipse(center, radius, radius, color);
}

void DrawNode::drawRect(const Rect& rect, Color fillColor, float borderWidth, Color borderColor) {
	if (!std::isfinite(rect.size.width) || !std::isfinite(rect.size.height)
		|| rect.size.width <= 0.0f || rect.size.height <= 0.0f) return;
	const Vec2 verts[] = {
		{rect.getLeft(), rect.getBottom()},
		{rect.getRight(), rect.getBottom()},
		{rect.getRight(), rect.getTop()},
		{rect.getLeft(), rect.getTop()},
	};
	drawPolygon(verts, 4, fillColor, borderWidth, borderColor);
}

void DrawNode::drawRoundedRect(const Rect& rect, float cornerRadius, Color fillColor, float borderWidth, Color borderColor) {
	const bool fill = fillColor.a > 0, outline = borderWidth > 0 && borderColor.a > 0;
	if ((!fill && !outline) || !std::isfinite(cornerRadius) || cornerRadius < 0 || !std::isfinite(borderWidth)
		|| !std::isfinite(rect.size.width) || !std::isfinite(rect.size.height)
		|| rect.size.width <= 0 || rect.size.height <= 0 || !Finite({rect.getLeft(), rect.getBottom()})) return;
	const float radius = std::min(cornerRadius, std::min(rect.size.width, rect.size.height) * 0.5f);
	const double left = rect.getLeft(), bottom = rect.getBottom();
	const double right = left + rect.size.width, top = bottom + rect.size.height;
	const double width = outline ? borderWidth : 0;
	const double outerRadius = radius > 0 ? double(radius) + width : 0;
	const double limit = std::numeric_limits<float>::max();
	if (left - width < -limit || bottom - width < -limit || right + width > limit || top + width > limit || outerRadius > limit) return;
	if (radius == 0 && !outline) {
		if (!ensureVertexCapacity(4)) return;
		const Vec4 color = fillColor.toVec4();
		const std::vector<DrawVertexInput> vertices = {
			{{s_cast<float>(left), s_cast<float>(bottom), 0, 1}, color, Vec2::zero},
			{{s_cast<float>(right), s_cast<float>(bottom), 0, 1}, color, Vec2::zero},
			{{s_cast<float>(right), s_cast<float>(top), 0, 1}, color, Vec2::zero},
			{{s_cast<float>(left), s_cast<float>(top), 0, 1}, color, Vec2::zero},
		};
		drawIndexedVertices(vertices, {0, 1, 2, 0, 2, 3});
		return;
	}
	const uint32_t segments = radius > 0 ? ArcSegments(s_cast<float>(outerRadius), std::acos(-1.0) * 0.5) : 1;
	const size_t count = 4 * (segments + 1);
	const bool inset = outline && double(rect.size.width) > width * 2 && double(rect.size.height) > width * 2;
	const size_t vertexCount = (fill ? count + 1 : 0) + (outline ? (inset ? count * 2 : count + 1) : 0);
	if (!ensureVertexCapacity(vertexCount)) return;
	DrawingMesh mesh;
	mesh.vertices.reserve(vertexCount);
	mesh.indices.reserve(count * 9);
	const Vec2 center{s_cast<float>((left + right) * 0.5), s_cast<float>((bottom + top) * 0.5)};
	if (fill) {
		const auto contour = RoundedContour(left, bottom, right, top, radius, segments);
		BuildContourBand(mesh, contour, nullptr, center, fillColor.toVec4(), true);
	}
	if (outline && mesh.valid) {
		const auto outer = RoundedContour(left - width, bottom - width, right + width, top + width, s_cast<float>(outerRadius), segments);
		if (inset) {
			const auto inner = RoundedContour(left + width, bottom + width, right - width, top - width, std::max(0.0f, radius - borderWidth), segments);
			BuildContourBand(mesh, outer, &inner, center, borderColor.toVec4(), true);
		} else {
			BuildContourBand(mesh, outer, nullptr, center, borderColor.toVec4(), true);
		}
	}
	if (mesh.valid) drawIndexedVertices(mesh.vertices, mesh.indices);
}

void DrawNode::drawRing(const Vec2& center, float innerRadius, float outerRadius, Color fillColor, float borderWidth, Color borderColor) {
	if (!Finite(center) || !std::isfinite(innerRadius) || !std::isfinite(outerRadius)
		|| !std::isfinite(borderWidth) || innerRadius < 0 || outerRadius <= innerRadius) return;
	const bool fill = fillColor.a > 0, outline = borderWidth > 0 && borderColor.a > 0;
	if (!fill && !outline) return;
	const double extent = double(outerRadius) + (outline ? borderWidth : 0);
	const double limit = std::numeric_limits<float>::max();
	if (extent > limit || double(center.x) + extent > limit || double(center.x) - extent < -limit
		|| double(center.y) + extent > limit || double(center.y) - extent < -limit) return;
	std::array<std::pair<float, float>, 2> borders;
	size_t borderCount = 0;
	if (outline) {
		borders[borderCount++] = {std::max(0.0f, outerRadius - borderWidth), s_cast<float>(extent)};
		if (innerRadius > 0) {
			const float low = std::max(0.0f, innerRadius - borderWidth), high = innerRadius + borderWidth;
			if (high >= borders[0].first) borders[0].first = low;
			else borders[borderCount++] = {low, high};
		}
	}
	const uint32_t count = ArcSegments(s_cast<float>(extent), 2 * std::acos(-1.0));
	size_t vertexCount = fill ? (innerRadius > 0 ? count * 2 : count + 1) : 0;
	for (size_t i = 0; i < borderCount; i++) vertexCount += borders[i].first > 0 ? count * 2 : count + 1;
	if (!ensureVertexCapacity(vertexCount)) return;
	DrawingMesh mesh;
	mesh.vertices.reserve(vertexCount);
	mesh.indices.reserve(count * 18);
	auto band = [&](float low, float high, Color color) {
		const auto outer = CircleContour(center, high, count);
		if (low > 0) {
			const auto inner = CircleContour(center, low, count);
			BuildContourBand(mesh, outer, &inner, center, color.toVec4(), true);
		} else {
			BuildContourBand(mesh, outer, nullptr, center, color.toVec4(), true);
		}
	};
	if (fill) band(innerRadius, outerRadius, fillColor);
	for (size_t i = 0; i < borderCount && mesh.valid; i++) band(borders[i].first, borders[i].second, borderColor);
	if (mesh.valid) drawIndexedVertices(mesh.vertices, mesh.indices);
}

void DrawNode::drawSector(const Vec2& center, float radius, float startAngle, float endAngle, Color fillColor, float borderWidth, Color borderColor) {
	const bool fill = fillColor.a > 0, outline = borderWidth > 0 && borderColor.a > 0;
	if ((!fill && !outline) || !Finite(center) || !std::isfinite(radius) || radius <= 0 || !std::isfinite(startAngle)
		|| !std::isfinite(endAngle) || !std::isfinite(borderWidth) || startAngle == endAngle) return;
	const double sweep = std::clamp(double(endAngle) - startAngle, -360.0, 360.0);
	if (std::abs(sweep) == 360) {
		drawRing(center, 0, radius, fillColor, borderWidth, borderColor);
		return;
	}
	auto arc = ArcPoints(center, radius, startAngle, sweep);
	DrawingMesh mesh;
	mesh.vertices.reserve((fill ? arc.size() + 1 : 0) + (outline ? (arc.size() + 1) * 2 : 0));
	mesh.indices.reserve((fill ? (arc.size() - 1) * 3 : 0) + (outline ? (arc.size() + 1) * 6 : 0));
	if (fill) {
		const Vec4 color = fillColor.toVec4();
		mesh.add(center, color, Vec2::zero);
		for (const Vec2& point : arc) mesh.add(point, color, Vec2::zero);
		for (size_t i = 1; i < arc.size(); i++) mesh.triangle(0, s_cast<uint16_t>(i), s_cast<uint16_t>(i + 1));
	}
	if (outline && mesh.valid) {
		arc.push_back(center);
		DrawingMesh stroke;
		BuildStroke(stroke, arc, borderWidth, borderColor.toVec4(), true);
		if (!stroke.valid) return;
		MakeSingleCoverage(stroke);
		if (!stroke.valid || mesh.vertices.size() + stroke.vertices.size() > 65536) return;
		const auto base = s_cast<uint16_t>(mesh.vertices.size());
		mesh.vertices.insert(mesh.vertices.end(), stroke.vertices.begin(), stroke.vertices.end());
		for (uint16_t index : stroke.indices) mesh.indices.push_back(base + index);
	}
	if (mesh.valid) drawIndexedVertices(mesh.vertices, mesh.indices);
}

void DrawNode::drawEllipse(const Vec2& center, float radiusX, float radiusY, Color color) {
	if (!Finite(center) || !std::isfinite(radiusX) || !std::isfinite(radiusY)
		|| radiusX <= 0.0f || radiusY <= 0.0f || color.a == 0
		|| !Finite({center.x + radiusX, center.y + radiusY})
		|| !Finite({center.x - radiusX, center.y - radiusY})) return;
	const size_t vertexCount = 4;
	const size_t indexCount = 6;
	if (!ensureVertexCapacity(vertexCount)) return;

	_posColors.reserve(_posColors.size() + vertexCount);
	_vertices.reserve(_vertices.size() + vertexCount);
	_indices.reserve(_indices.size() + indexCount);

	Vec4 color4 = color.toVec4();
	uint16_t start = s_cast<uint16_t>(_vertices.size());
	pushVertex({center.x - radiusX, center.y - radiusY}, color4, {-1, -1});
	pushVertex({center.x - radiusX, center.y + radiusY}, color4, {-1, 1});
	pushVertex({center.x + radiusX, center.y + radiusY}, color4, {1, 1});
	pushVertex({center.x + radiusX, center.y - radiusY}, color4, {1, -1});

	const uint16_t indices[] = {0, 1, 2, 0, 2, 3};
	for (uint16_t index : indices) {
		_indices.push_back(start + index);
	}

	_flags.setOn(DrawNode::VertexColorDirty);
	_flags.setOn(DrawNode::VertexPosDirty);
}

void DrawNode::drawSegment(const Vec2& from, const Vec2& to, float radius, Color color) {
	if (!Finite(from) || !Finite(to) || !std::isfinite(radius) || radius <= 0.0f || color.a == 0) return;
	if (SamePoint(from, to)) {
		drawDot(from, radius, color);
		return;
	}
	const Vec2 n = Vec2::perp(Direction(from, to));
	const Vec2 t = Vec2::perp(n);
	const Vec2 nw = n * radius, tw = t * radius;
	const Vec2 positions[] = {
		to - nw - tw, to + nw - tw, to - nw, to + nw,
		from - nw, from + nw, from - nw + tw, from + nw + tw,
	};
	if (std::any_of(std::begin(positions), std::end(positions), [](const Vec2& p) { return !Finite(p); })) return;
	if (!ensureVertexCapacity(8)) return;
	const Vec2 coords[] = {-(n + t), n - t, -n, n, -n, n, t - n, n + t};
	const uint16_t indices[] = {0, 1, 2, 3, 1, 2, 3, 4, 2, 3, 4, 5, 6, 4, 5, 6, 7, 5};
	const uint16_t start = s_cast<uint16_t>(_vertices.size());
	const Vec4 color4 = color.toVec4();
	_posColors.reserve(_posColors.size() + 8);
	_vertices.reserve(_vertices.size() + 8);
	_indices.reserve(_indices.size() + 18);
	for (size_t i = 0; i < 8; i++) pushVertex(positions[i], color4, coords[i]);
	for (uint16_t index : indices) _indices.push_back(start + index);
	_flags.setOn(DrawNode::VertexColorDirty);
	_flags.setOn(DrawNode::VertexPosDirty);
}

void DrawNode::drawPolyline(const std::vector<Vec2>& verts, float radius, Color color, bool closed) {
	drawPolyline(verts.data(), s_cast<uint32_t>(verts.size()), radius, color, closed);
}

void DrawNode::drawPolyline(const Vec2* verts, uint32_t count, float radius, Color color, bool closed) {
	if (!verts || count < 2 || !std::isfinite(radius) || radius <= 0.0f || color.a == 0) return;
	bool duplicates = closed && SamePoint(verts[0], verts[count - 1]);
	for (uint32_t i = 0; i < count; i++) {
		if (!Finite(verts[i])) return;
		if (i > 0 && SamePoint(verts[i - 1], verts[i])) duplicates = true;
	}
	std::vector<Vec2> points;
	if (duplicates) {
		points.reserve(count);
		for (uint32_t i = 0; i < count; i++) {
			if (points.empty() || !SamePoint(points.back(), verts[i])) points.push_back(verts[i]);
		}
		if (closed && points.size() > 1 && SamePoint(points.front(), points.back())) points.pop_back();
		verts = points.data();
		count = s_cast<uint32_t>(points.size());
	}
	if (count == 1) {
		drawDot(verts[0], radius, color);
		return;
	}
	if (count < 2) return;
	if (count == 2) {
		drawSegment(verts[0], verts[1], radius, color);
		return;
	}
	DrawingMesh mesh;
	BuildStroke(mesh, verts, count, radius, color.toVec4(), closed);
	if (!mesh.valid) {
		Warn("DrawNode.drawPolyline geometry exceeds the vertex limit or contains non-finite positions.");
		return;
	}
	drawIndexedVertices(mesh.vertices, mesh.indices);
}

void DrawNode::drawArc(const Vec2& center, float radius, float startAngle, float endAngle, float lineRadius, Color color) {
	if (radius <= 0.0f || lineRadius <= 0.0f || color.a == 0 || startAngle == endAngle
		|| !Finite(center) || !std::isfinite(radius) || !std::isfinite(lineRadius)
		|| !std::isfinite(startAngle) || !std::isfinite(endAngle)) return;
	const double sweep = std::clamp(double(endAngle) - double(startAngle), -360.0, 360.0);
	const bool closed = std::abs(sweep) == 360.0;
	if (closed && lineRadius >= radius) {
		drawCircle(center, radius + lineRadius, color);
		return;
	}
	auto verts = ArcPoints(center, radius, startAngle, sweep);
	if (closed) verts.pop_back();
	drawPolyline(verts, lineRadius, color, closed);
}

void DrawNode::drawQuadraticBezier(const Vec2& from, const Vec2& control, const Vec2& to, float radius, Color color) {
	if (!Finite(from) || !Finite(control) || !Finite(to) || !std::isfinite(radius) || radius <= 0 || color.a == 0) return;
	std::vector<Vec2> points = {from};
	points.reserve(64);
	FlattenBezier(std::array<Vec2, 3>{from, control, to}, points);
	if (points.size() == 1) drawDot(from, radius, color);
	else drawPolyline(points, radius, color, SamePoint(from, to));
}

void DrawNode::drawCubicBezier(const Vec2& from, const Vec2& control1, const Vec2& control2, const Vec2& to, float radius, Color color) {
	if (!Finite(from) || !Finite(control1) || !Finite(control2) || !Finite(to) || !std::isfinite(radius) || radius <= 0 || color.a == 0) return;
	std::vector<Vec2> points = {from};
	points.reserve(64);
	FlattenBezier(std::array<Vec2, 4>{from, control1, control2, to}, points);
	if (points.size() == 1) drawDot(from, radius, color);
	else drawPolyline(points, radius, color, SamePoint(from, to));
}

void DrawNode::drawPolygon(const std::vector<Vec2>& verts, Color fillColor, float borderWidth, Color borderColor) {
	drawPolygon(verts.data(), s_cast<uint32_t>(verts.size()), fillColor, borderWidth, borderColor);
}

void DrawNode::drawPolygon(const Vec2* verts, uint32_t count, Color fillColor, float borderWidth, Color borderColor) {
	if (!verts || count < 3 || !std::isfinite(borderWidth)) return;
	const bool outline = borderColor.a > 0 && borderWidth > 0.0f;
	const bool fill = fillColor.a > 0;
	if (!outline && !fill) return;
	std::vector<Vec2> polygon;
	if (!PreparePolygon(verts, count, polygon)) {
		Warn("DrawNode.drawPolygon requires a finite, non-self-intersecting polygon with at least three distinct vertices.");
		return;
	}
	std::vector<uint32_t> triangles;
	if (!TriangulatePolygon(polygon, triangles)) {
		Warn("DrawNode.drawPolygon could not triangulate the polygon.");
		return;
	}
	DrawingMesh mesh;
	if (fill) {
		mesh.vertices.reserve(polygon.size());
		const Vec4 color = fillColor.toVec4();
		for (const Vec2& point : polygon) {
			mesh.add(point, color, Vec2::zero);
			if (!mesh.valid) break;
		}
		if (mesh.valid) {
			mesh.indices.reserve(triangles.size());
			for (uint32_t index : triangles) mesh.indices.push_back(s_cast<uint16_t>(index));
		}
	}
	if (outline && mesh.valid) BuildStroke(mesh, polygon, borderWidth, borderColor.toVec4(), true);
	if (!mesh.valid) {
		Warn("DrawNode.drawPolygon geometry exceeds the vertex limit or contains non-finite positions.");
		return;
	}
	// Submit the whole fill and border atomically, with shared fill vertices.
	drawIndexedVertices(mesh.vertices, mesh.indices);
}

void DrawNode::drawVertices(const std::vector<VertexColor>& verts) {
	uint32_t count = s_cast<uint32_t>(verts.size());
	if (count < 3) return;
	const uint64_t vertexCount = 3ull * (count - 2);
	if (!ensureVertexCapacity(vertexCount)) return;
	_posColors.reserve(_posColors.size() + s_cast<size_t>(vertexCount));
	_vertices.reserve(_vertices.size() + s_cast<size_t>(vertexCount));

	uint16_t start = s_cast<uint16_t>(_vertices.size());

	for (uint32_t i = 0; i < count - 2; i++) {
		pushVertex(verts[0].vertex, verts[0].color.toVec4(), Vec2::zero);
		pushVertex(verts[i + 1].vertex, verts[i + 1].color.toVec4(), Vec2::zero);
		pushVertex(verts[i + 2].vertex, verts[i + 2].color.toVec4(), Vec2::zero);
	}

	const size_t indexCount = _vertices.size() - start;
	_indices.reserve(indexCount);

	for (size_t i = 0; i < indexCount; i++) {
		_indices.push_back(s_cast<uint16_t>(start + i));
	}

	_flags.setOn(DrawNode::VertexColorDirty);
	_flags.setOn(DrawNode::VertexPosDirty);
}

void DrawNode::drawIndexedVertices(const std::vector<DrawVertexInput>& verts,
	const std::vector<uint16_t>& indices) {
	if (!ensureVertexCapacity(verts.size())) return;
	if (std::any_of(indices.begin(), indices.end(), [&verts](uint16_t index) { return index >= verts.size(); })) {
		Warn("DrawNode indexed vertex input contains an index outside the vertex array.");
		return;
	}
	const uint16_t start = s_cast<uint16_t>(_vertices.size());
	_posColors.reserve(_posColors.size() + verts.size());
	_vertices.reserve(_vertices.size() + verts.size());
	_indices.reserve(_indices.size() + indices.size());
	for (const auto& vertex : verts) {
		_posColors.push_back({vertex.position, vertex.color});
		_vertices.push_back({0, 0, 0, 0, 0, vertex.texCoord.x, vertex.texCoord.y});
	}
	for (const auto index : indices) {
		_indices.push_back(s_cast<uint16_t>(start + index));
	}
	_flags.setOn(DrawNode::VertexColorDirty);
	_flags.setOn(DrawNode::VertexPosDirty);
}

void DrawNode::clear() {
	_posColors.clear();
	_vertices.clear();
	_indices.clear();
}

/* DrawRenderer */

DrawRenderer::DrawRenderer()
	: _defaultPass(Pass::create("builtin:vs_draw"_slice, "builtin:fs_draw"_slice))
	, _lastState(BGFX_STATE_NONE) { }

Pass* DrawRenderer::getDefaultPass() const noexcept {
	return _defaultPass;
}

void DrawRenderer::push(DrawNode* node) {
	uint64_t state = SharedRendererManager.applyState(node->getRenderState());
	const auto& verts = node->getVertices();
	// Indices in DrawNode batches are 16-bit. Flush before rebasing another node
	// would wrap its indices, which also keeps each transient allocation bounded.
	constexpr size_t maxVertexCount = static_cast<size_t>(std::numeric_limits<uint16_t>::max()) + 1;
	if (state != _lastState
		|| (!_vertices.empty() && _vertices.size() + verts.size() > maxVertexCount)) {
		render();
	}
	_lastState = state;

	uint16_t start = s_cast<uint16_t>(_vertices.size());
	_vertices.reserve(_vertices.size() + verts.size());
	_vertices.insert(_vertices.end(), verts.begin(), verts.end());

	const auto& indices = node->getIndices();
	_indices.reserve(_indices.size() + indices.size());
	for (const auto& index : indices) {
		_indices.push_back(start + index);
	}
}

void DrawRenderer::render() {
	if (!_vertices.empty()) {
		bgfx::TransientVertexBuffer vertexBuffer;
		bgfx::TransientIndexBuffer indexBuffer;
		uint32_t vertexCount = s_cast<uint32_t>(_vertices.size());
		uint32_t indexCount = s_cast<uint32_t>(_indices.size());
		if (bgfx::allocTransientBuffers(
				&vertexBuffer, DrawVertex::ms_layout, vertexCount,
				&indexBuffer, indexCount)) {
			Renderer::render();
			std::memcpy(vertexBuffer.data, _vertices.data(), _vertices.size() * sizeof(_vertices[0]));
			std::memcpy(indexBuffer.data, _indices.data(), _indices.size() * sizeof(_indices[0]));
			bgfx::setVertexBuffer(0, &vertexBuffer);
			bgfx::setIndexBuffer(&indexBuffer);
			bgfx::setState(_lastState);
			bgfx::ViewId viewId = SharedView.getId();
			bgfx::submit(viewId, _defaultPass->apply());
		} else {
			Warn("not enough transient buffer for {} vertices, {} indices.", vertexCount, indexCount);
		}
		_vertices.clear();
		_indices.clear();
		_lastState = BGFX_STATE_NONE;
	}
}

/* Line */

bgfx::VertexLayout PosColorVertex::ms_layout;
PosColorVertex::Init PosColorVertex::init;

Line::Line()
	: _blendFunc{BlendFunc::One, BlendFunc::InvSrcAlpha}
	, _renderState(BGFX_STATE_NONE) { }

Line::Line(const std::vector<Vec2>& verts, Color color)
	: Line() {
	if (verts.empty()) return;
	_posColors.reserve(verts.size());
	_vertices.reserve(verts.size());
	Vec4 color4 = color.toVec4();
	for (const auto& vert : verts) {
		_posColors.push_back({{vert.x, vert.y, 0, 1}, color4});
	}
	_flags.setOn(Line::VertexColorDirty);
	_flags.setOn(Line::VertexPosDirty);
}

Line::Line(const Vec2* verts, uint32_t size, Color color)
	: Line() {
	if (size == 0) return;
	_posColors.reserve(size);
	_vertices.reserve(size);
	Vec4 color4 = color.toVec4();
	for (uint32_t i = 0; i < size; i++) {
		Vec2 vert = verts[i];
		_posColors.push_back({{vert.x, vert.y, 0, 1}, color4});
	}
	_flags.setOn(Line::VertexColorDirty);
	_flags.setOn(Line::VertexPosDirty);
}

void Line::setBlendFunc(BlendFunc var) {
	_blendFunc = var;
}

BlendFunc Line::getBlendFunc() const noexcept {
	return _blendFunc;
}

void Line::setDepthWrite(bool var) {
	_flags.set(Line::DepthWrite, var);
}

bool Line::isDepthWrite() const noexcept {
	return _flags.isOn(Line::DepthWrite);
}

uint64_t Line::getRenderState() const noexcept {
	return _renderState;
}

const std::vector<PosColorVertex>& Line::getVertices() const noexcept {
	return _vertices;
}

void Line::add(const std::vector<Vec2>& verts, Color color) {
	if (verts.empty()) return;
	if (!_posColors.empty()) {
		_posColors.push_back(_posColors.back());
		_posColors.back().color = {0, 0, 0, 0};
		Vec2 front = verts.front();
		_posColors.push_back({{front.x, front.y, 0, 1}, {0, 0, 0, 0}});
	}
	_posColors.reserve(_posColors.size() + verts.size());
	Vec4 color4 = color.toVec4();
	for (const auto& vert : verts) {
		_posColors.push_back({{vert.x, vert.y, 0, 1}, color4});
	}
	_flags.setOn(Line::VertexColorDirty);
	_flags.setOn(Line::VertexPosDirty);
}

void Line::add(const Vec2* verts, uint32_t size, Color color) {
	if (size == 0) return;
	if (!_posColors.empty()) {
		_posColors.push_back(_posColors.back());
		_posColors.back().color = {0, 0, 0, 0};
		Vec2 front = verts[0];
		_posColors.push_back({{front.x, front.y, 0, 1}, {0, 0, 0, 0}});
	}
	_posColors.reserve(_posColors.size() + size);
	Vec4 color4 = color.toVec4();
	for (uint32_t i = 0; i < size; i++) {
		Vec2 vert = verts[i];
		_posColors.push_back({{vert.x, vert.y, 0, 1}, color4});
	}
	_flags.setOn(Line::VertexColorDirty);
	_flags.setOn(Line::VertexPosDirty);
}

void Line::set(const std::vector<Vec2>& verts, Color color) {
	clear();
	add(verts, color);
}

void Line::set(const Vec2* verts, uint32_t size, Color color) {
	clear();
	add(verts, size, color);
}

void Line::clear() {
	_posColors.clear();
	_flags.setOn(Line::VertexColorDirty);
	_flags.setOn(Line::VertexPosDirty);
}

void Line::updateRealColor3() {
	Node::updateRealColor3();
	_flags.setOn(Line::VertexColorDirty);
}

void Line::updateRealOpacity() {
	Node::updateRealOpacity();
	_flags.setOn(Line::VertexColorDirty);
}

const Matrix& Line::getWorld() {
	if (_flags.isOn(Node::WorldDirty)) {
		_flags.setOn(Line::VertexPosDirty);
	}
	return Node::getWorld();
}

void Line::render() {
	if (_posColors.empty()) {
		Node::render();
		return;
	}

	if (SharedView.isFrustumCulling()) {
		auto [minX, maxX] = std::minmax_element(_posColors.begin(), _posColors.end(), [](const auto& a, const auto& b) {
			return a.pos.x < b.pos.x;
		});
		auto [minY, maxY] = std::minmax_element(_posColors.begin(), _posColors.end(), [](const auto& a, const auto& b) {
			return a.pos.y < b.pos.y;
		});
		AABB aabb;
		Matrix::mulAABB(aabb, getWorld(), {
										  {minX->pos.x, minY->pos.y, 0},
										  {maxX->pos.x, maxY->pos.y, 0},
									  });
		if (!SharedDirector.isInFrustum(aabb)) {
			return;
		}
	}

	if (_vertices.size() != _posColors.size()) {
		_vertices.resize(_posColors.size());
	}

	if (_flags.isOn(Line::VertexColorDirty)) {
		_flags.setOff(Line::VertexColorDirty);
		Vec4 ucolor = _realColor.toVec4();
		for (size_t i = 0; i < _posColors.size(); i++) {
			const Vec4& acolor = _posColors[i].color;
			Vec4 color{
				acolor.x * ucolor.x,
				acolor.y * ucolor.y,
				acolor.z * ucolor.z,
				acolor.w * ucolor.w};
			_vertices[i].abgr = Color(color).toABGR();
		}
	}

	if (_flags.isOn(Line::VertexPosDirty)) {
		_flags.setOff(Line::VertexPosDirty);
		Matrix transform;
		Matrix::mulMtx(transform, SharedDirector.getViewProjection(), getWorld());
		for (size_t i = 0; i < _vertices.size(); i++) {
			Matrix::mulVec4(&_vertices[i].x, transform, _posColors[i].pos);
		}
	}

	_renderState = BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | BGFX_STATE_PT_LINESTRIP | _blendFunc.toValue();
	if (_flags.isOn(Line::DepthWrite)) {
		_renderState |= (BGFX_STATE_WRITE_Z | BGFX_STATE_DEPTH_TEST_LESS);
	}

	SharedRendererManager.setCurrent(SharedLineRenderer.getTarget());
	SharedLineRenderer.push(this);

	Node::render();
}

/* LineRenderer */

LineRenderer::LineRenderer()
	: _defaultPass(Pass::create("builtin:vs_poscolor"_slice, "builtin:fs_poscolor"_slice))
	, _lastState(BGFX_STATE_NONE) { }

Pass* LineRenderer::getDefaultPass() const noexcept {
	return _defaultPass;
}

void LineRenderer::push(Line* line) {
	uint64_t state = line->getRenderState();
	if (state != _lastState) {
		render();
	}
	_lastState = state;
	const auto& verts = line->getVertices();
	_vertices.reserve(_vertices.size() + verts.size());
	if (!_vertices.empty()) {
		_vertices.push_back(_vertices.back());
		_vertices.back().abgr = 0;
		_vertices.push_back(verts.front());
		_vertices.back().abgr = 0;
	}
	_vertices.insert(_vertices.end(), verts.begin(), verts.end());
}

void LineRenderer::pushRect(PosColorVertex verts[4]) {
	uint64_t state = BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | BGFX_STATE_PT_LINESTRIP | BlendFunc::Default.toValue();
	if (state != _lastState) {
		render();
	}
	_lastState = state;
	if (!_vertices.empty()) {
		_vertices.reserve(_vertices.size() + 6);
		_vertices.push_back(_vertices.back());
		_vertices.back().abgr = 0;
		_vertices.push_back(verts[0]);
		_vertices.back().abgr = 0;
	} else {
		_vertices.reserve(_vertices.size() + 4);
	}
	_vertices.push_back(verts[0]);
	_vertices.push_back(verts[1]);
	_vertices.push_back(verts[2]);
	_vertices.push_back(verts[3]);
	_vertices.push_back(verts[0]);
}

void LineRenderer::pushSegment(PosColorVertex verts[2]) {
	uint64_t state = BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | BGFX_STATE_PT_LINESTRIP | BlendFunc::Default.toValue();
	if (state != _lastState) {
		render();
	}
	_lastState = state;
	if (!_vertices.empty()) {
		_vertices.reserve(_vertices.size() + 4);
		_vertices.push_back(_vertices.back());
		_vertices.back().abgr = 0;
		_vertices.push_back(verts[0]);
		_vertices.back().abgr = 0;
	} else {
		_vertices.reserve(_vertices.size() + 2);
	}
	_vertices.push_back(verts[0]);
	_vertices.push_back(verts[1]);
}

void LineRenderer::render() {
	if (!_vertices.empty()) {
		bgfx::TransientVertexBuffer vertexBuffer;
		uint32_t vertexCount = s_cast<uint32_t>(_vertices.size());
		if (bgfx::getAvailTransientVertexBuffer(vertexCount, PosColorVertex::ms_layout) >= vertexCount) {
			bgfx::allocTransientVertexBuffer(&vertexBuffer, vertexCount, PosColorVertex::ms_layout);
			Renderer::render();
			std::memcpy(vertexBuffer.data, _vertices.data(), _vertices.size() * sizeof(_vertices[0]));
			bgfx::setVertexBuffer(0, &vertexBuffer);
			bgfx::setState(_lastState);
			bgfx::ViewId viewId = SharedView.getId();
			bgfx::submit(viewId, _defaultPass->apply());
		} else {
			Warn("not enough transient buffer for {} vertices.", vertexCount);
		}
		_vertices.clear();
		_lastState = BGFX_STATE_NONE;
	}
}

NS_DORA_END
