// Coverage-aware Euclidean distance transform for antialiased glyph bitmaps.
// Uses the lower envelope of squared-distance parabolas (Felzenszwalb/Huttenlocher).
#pragma once

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <vector>

namespace bgfx {

inline std::vector<uint8_t> buildCoverageSDF(const uint8_t* coverage, int width, int height) {
	if (!coverage || width <= 0 || height <= 0) return {};
	// Finite infinity keeps all-empty rows well defined in the envelope pass.
	constexpr double infinity = 1e20;
	const int count = width * height;
	std::vector<double> outside(count), inside(count);
	for (int i = 0; i < count; ++i) {
		const double alpha = coverage[i] / 255.0;
		const double offset = 0.5 - alpha;
		outside[i] = alpha == 0 ? infinity : std::max(0.0, offset) * std::max(0.0, offset);
		inside[i] = alpha == 1 ? infinity : std::min(0.0, offset) * std::min(0.0, offset);
	}
	const int extent = std::max(width, height);
	std::vector<double> source(extent), boundaries(extent + 1);
	std::vector<int> sites(extent);
	auto transformLine = [&](std::vector<double>& grid, int start, int stride, int length) {
		for (int i = 0; i < length; ++i) source[i] = grid[start + i * stride];
		int last = 0;
		sites[0] = 0;
		boundaries[0] = -infinity;
		boundaries[1] = infinity;
		for (int q = 1; q < length; ++q) {
			double crossing;
			for (;;) {
				const int p = sites[last];
				crossing = ((source[q] - source[p]) + double(q * q - p * p)) / (2.0 * (q - p));
				if (last == 0 || crossing > boundaries[last]) break;
				--last;
			}
			sites[++last] = q;
			boundaries[last] = crossing;
			boundaries[last + 1] = infinity;
		}
		int segment = 0;
		for (int q = 0; q < length; ++q) {
			while (segment < last && boundaries[segment + 1] < q) ++segment;
			const int p = sites[segment];
			grid[start + q * stride] = source[p] + double((q - p) * (q - p));
		}
	};
	for (auto* grid : {&outside, &inside}) {
		for (int x = 0; x < width; ++x) transformLine(*grid, x, width, height);
		for (int y = 0; y < height; ++y) transformLine(*grid, y * width, 1, width);
	}
	std::vector<uint8_t> result(count);
	for (int i = 0; i < count; ++i) {
		const double distance = std::sqrt(inside[i]) - std::sqrt(outside[i]);
		// Match the existing 0.69 contour and five encoded levels per atlas pixel.
		// Quantize only here, not the distances or input coverage.
		result[i] = static_cast<uint8_t>(std::clamp(std::round(0.69 * 255.0 + distance * 5.0), 0.0, 255.0));
	}
	return result;
}

} // namespace bgfx
