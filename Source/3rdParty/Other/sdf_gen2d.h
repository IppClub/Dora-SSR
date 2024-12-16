/* Copyright (c) 2024 有个小小杜
 ref: http://www.codersnotes.com/notes/signed-distance-fields

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "ktm/ktm.h"
#include <cstdint>
#include <memory>
#include <vector>

namespace sdf {

class sdf_fgen2d {
public:
	static constexpr float suggested_edge_x = 0.735f;
	static constexpr float suggested_edge_y = 0.735f;

	using sdf_point2d = ktm::svec2;
	static inline constexpr sdf_point2d empty = {16384, 16384};
	static inline constexpr sdf_point2d inside = {};

	sdf_fgen2d() = default;

	std::vector<unsigned char> build(unsigned char* bitmap, uint32_t width, uint32_t height, float dist_scale = 20.0f) {
		m_width = width;
		m_height = height;
		auto m_grid_out = std::make_unique<sdf_point2d[]>(m_width * m_height);
		auto m_grid_in = std::make_unique<sdf_point2d[]>(m_width * m_height);

		for (int i = 0; i < m_height * m_width; ++i) {
			m_grid_out[i] = empty;
			m_grid_in[i] = inside;
		}

		for (int y = 1; y < m_height - 1; ++y) {
			for (int x = 1; x < m_width - 1; ++x) {
				unsigned char val = bitmap[y * m_width + x];
				if (val > 128) {
					m_grid_out[y * m_width + x] = inside;
					m_grid_out[(y - 1) * m_width + x] = inside;
					m_grid_out[(y)*m_width + x - 1] = inside;
					m_grid_out[(y + 1) * m_width + x] = inside;
					m_grid_out[(y)*m_width + x + 1] = inside;
					m_grid_out[(y - 1) * m_width + x - 1] = inside;
					m_grid_out[(y - 1) * m_width + x + 1] = inside;
					m_grid_out[(y + 1) * m_width + x - 1] = inside;
					m_grid_out[(y + 1) * m_width + x + 1] = inside;
					m_grid_in[y * m_width + x] = empty;
				}
			}
		}

		generate_sdf(m_grid_out.get());
		generate_sdf(m_grid_in.get());

		std::vector<unsigned char> ret(m_width * m_height);
		int remain = m_height * m_width % 4;

		for (int i = 0; i < m_height * m_width - remain; i += 4) {
			ktm::fvec4 outx = ktm::fvec4(m_grid_out[i].x, m_grid_out[i + 1].x, m_grid_out[i + 2].x, m_grid_out[i + 3].x);
			ktm::fvec4 outy = ktm::fvec4(m_grid_out[i].y, m_grid_out[i + 1].y, m_grid_out[i + 2].y, m_grid_out[i + 3].y);
			ktm::fvec4 dist1 = ktm::sqrt(outx * outx + outy * outy);
			ktm::fvec4 inx = ktm::fvec4(m_grid_in[i].x, m_grid_in[i + 1].x, m_grid_in[i + 2].x, m_grid_in[i + 3].x);
			ktm::fvec4 iny = ktm::fvec4(m_grid_in[i].y, m_grid_in[i + 1].y, m_grid_in[i + 2].y, m_grid_in[i + 3].y);
			ktm::fvec4 dist2 = ktm::sqrt(inx * inx + iny * iny);
			ktm::fvec4 dist = dist2 - dist1;
			ktm::svec4 group_c = ktm::svec4(dist * dist_scale + 180.f);
			group_c = ktm::clamp(group_c, {}, {255, 255, 255, 255});
			ret[i] = group_c[0];
			ret[i + 1] = group_c[1];
			ret[i + 2] = group_c[2];
			ret[i + 3] = group_c[3];
		}

		for (int i = 0; i < remain; ++i) {
			float dist1 = sqrtf(static_cast<float>(dist_square(m_grid_out[i])));
			float dist2 = sqrtf(static_cast<float>(dist_square(m_grid_in[i])));
			float dist = dist2 - dist1;

			int c = round(dist * dist_scale) + 180.f;
			if (c < 0) c = 0;
			if (c > 255) c = 255;
			ret[i] = c;
		}

		return ret;
	}

private:
	inline int dist_square(const sdf_point2d& p) {
		return p.x * p.x + p.y * p.y;
	}

	inline sdf_point2d get(sdf_point2d* g, int x, int y) {
		if (x >= 0 && y >= 0 && x < m_width && y < m_height)
			return g[y * m_width + x];
		else
			return empty;
	}

	inline void put(sdf_point2d* g, int x, int y, const sdf_point2d& p) {
		g[y * m_width + x] = p;
	}

	inline void compare(sdf_point2d* g, sdf_point2d& p, int x, int y, int offsetx, int offsety) {
		sdf_point2d other = get(g, x + offsetx, y + offsety);
		other.x += offsetx;
		other.y += offsety;

		if (dist_square(other) < dist_square(p))
			p = other;
	}

	inline void group_compare(sdf_point2d* g, sdf_point2d& p, int x, int y, const ktm::svec4& offsetx, const ktm::svec4& offsety) {
		sdf_point2d other0 = get(g, x + offsetx[0], y + offsety[0]);
		sdf_point2d other1 = get(g, x + offsetx[1], y + offsety[1]);
		sdf_point2d other2 = get(g, x + offsetx[2], y + offsety[2]);
		sdf_point2d other3 = get(g, x + offsetx[3], y + offsety[3]);

		ktm::svec4 other_dx = {other0.x, other1.x, other2.x, other3.x};
		ktm::svec4 other_dy = {other0.y, other1.y, other2.y, other3.y};
		other_dx = other_dx + offsetx;
		other_dy = other_dy + offsety;
		ktm::svec4 other_dist_square = other_dx * other_dx + other_dy * other_dy;
		int dist_square_p = dist_square(p);

		int index = other_dist_square[0] < other_dist_square[1] ? 0 : 1;
		index = other_dist_square[index] < other_dist_square[2] ? index : 2;
		index = other_dist_square[index] < other_dist_square[3] ? index : 3;

		if (other_dist_square[index] < dist_square_p) {
			p.x = other_dx[index];
			p.y = other_dy[index];
		}
	}

	void generate_sdf(sdf_point2d* g) {
		for (int y = 0; y < m_height; ++y) {
			for (int x = 0; x < m_width; ++x) {
				sdf_point2d p = get(g, x, y);
				group_compare(g, p, x, y, {-1, 0, -1, 1}, {0, -1, -1, -1});
				put(g, x, y, p);
			}

			for (int x = m_width - 1; x >= 0; --x) {
				sdf_point2d p = get(g, x, y);
				compare(g, p, x, y, 1, 0);
				put(g, x, y, p);
			}
		}

		for (int y = m_height - 1; y >= 0; --y) {
			for (int x = m_width - 1; x >= 0; --x) {
				sdf_point2d p = get(g, x, y);
				group_compare(g, p, x, y, {1, 0, -1, 1}, {0, 1, 1, 1});
				put(g, x, y, p);
			}

			for (int x = 0; x < m_width; x++) {
				sdf_point2d p = get(g, x, y);
				compare(g, p, x, y, -1, 0);
				put(g, x, y, p);
			}
		}
	}

	uint32_t m_width, m_height;
};

class sdf_igen2d {
public:
	static constexpr float suggested_edge_x = 0.702f;
	static constexpr float suggested_edge_y = 0.702f;

	struct sdf_point2d {
		int dx, dy;
		inline int DistSq() const { return dx * dx + dy * dy; }
	};

	static constexpr sdf_point2d inside = {0, 0};
	static constexpr sdf_point2d empty = {16384, 16384};

	sdf_igen2d() = default;

	std::vector<unsigned char> build(unsigned char* bitmap, int width, int height) {
		m_width = width;
		m_height = height;
		auto m_grid_out = std::make_unique<sdf_point2d[]>(m_width * m_height);
		auto m_grid_in = std::make_unique<sdf_point2d[]>(m_width * m_height);

		for (int i = 0; i < m_height * m_width; ++i) {
			m_grid_out[i] = empty;
			m_grid_in[i] = inside;
		}

		for (int y = 0; y < height; ++y) {
			for (int x = 0; x < width; ++x) {
				unsigned char val = bitmap[y * width + x];
				if (val > 128) {
					m_grid_out[y * width + x] = inside;
					m_grid_in[y * width + x] = empty;
				}
			}
		}
		GenerateSDF(m_grid_out.get());
		GenerateSDF(m_grid_in.get());
		std::vector<unsigned char> ret(width * height);
		for (int y = 0; y < height; ++y) {
			for (int x = 0; x < width; ++x) {
				// Calculate the actual distance from the dx/dy
				int dist1 = (int)(sqrt((double)Get(m_grid_out.get(), x, y).DistSq()));
				int dist2 = (int)(sqrt((double)Get(m_grid_in.get(), x, y).DistSq()));
				int dist = dist2 - dist1;

				// Clamp and scale it, just for display purposes.
				int c = dist * 5 + 180;
				if (c < 0) c = 0;
				if (c > 255) c = 255;
				ret[y * width + x] = c;
			}
		}
		return ret;
	}

	inline sdf_point2d Get(sdf_point2d* g, int x, int y) {
		if (x >= 0 && y >= 0 && x < m_width && y < m_height)
			return g[y * m_width + x];
		else
			return empty;
	}

	inline void Put(sdf_point2d* g, int x, int y, const sdf_point2d& p) {
		g[y * m_width + x] = p;
	}

	inline void Compare(sdf_point2d* g, sdf_point2d& p, int x, int y, int offsetx, int offsety) {
		sdf_point2d other = Get(g, x + offsetx, y + offsety);
		other.dx += offsetx;
		other.dy += offsety;

		if (other.DistSq() < p.DistSq())
			p = other;
	}

	void GenerateSDF(sdf_point2d* g) {
		// Pass 0
		for (int y = 0; y < m_height; ++y) {
			for (int x = 0; x < m_width; ++x) {
				sdf_point2d p = Get(g, x, y);
				Compare(g, p, x, y, -1, 0);
				Compare(g, p, x, y, 0, -1);
				Compare(g, p, x, y, -1, -1);
				Compare(g, p, x, y, 1, -1);
				Put(g, x, y, p);
			}

			for (int x = m_width - 1; x >= 0; --x) {
				sdf_point2d p = Get(g, x, y);
				Compare(g, p, x, y, 1, 0);
				Put(g, x, y, p);
			}
		}

		// Pass 1
		for (int y = m_height - 1; y >= 0; --y) {
			for (int x = m_width - 1; x >= 0; --x) {
				sdf_point2d p = Get(g, x, y);
				Compare(g, p, x, y, 1, 0);
				Compare(g, p, x, y, 0, 1);
				Compare(g, p, x, y, -1, 1);
				Compare(g, p, x, y, 1, 1);
				Put(g, x, y, p);
			}

			for (int x = 0; x < m_width; x++) {
				sdf_point2d p = Get(g, x, y);
				Compare(g, p, x, y, -1, 0);
				Put(g, x, y, p);
			}
		}
	}

private:
	uint32_t m_width, m_height;
};

using sdf_gen2d = sdf_igen2d;

} // namespace sdf
