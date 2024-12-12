/* Copyright (c) 2024 有个小小杜

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include <vector>

class SdfBuilder {
public:
	struct Point {
		int dx, dy;
		inline int DistSq() const { return dx * dx + dy * dy; }
	};

	static constexpr Point inside = {0, 0};
	static constexpr Point empty = {16384, 16384};

	SdfBuilder(unsigned char* bitmap, int width, int height)
		: mBitmap(bitmap)
		, mWidth(width)
		, mHeight(height)
		, mGridOut(std::vector<Point>(width * height, empty))
		, mGridIn(std::vector<Point>(width * height, inside)) { }

	std::vector<unsigned char> Build() {
		for (int y = 0; y < mHeight; ++y) {
			for (int x = 0; x < mWidth; ++x) {
				unsigned char val = mBitmap[y * mWidth + x];
				if (val > 128) {
					mGridOut[y * mWidth + x] = inside;
					mGridIn[y * mWidth + x] = empty;
				}
			}
		}
		GenerateSDF(mGridOut);
		GenerateSDF(mGridIn);
		std::vector<unsigned char> ret(mWidth * mHeight);
		for (int y = 0; y < mHeight; ++y) {
			for (int x = 0; x < mWidth; ++x) {
				// Calculate the actual distance from the dx/dy
				int dist1 = (int)(sqrt((double)Get(mGridOut, x, y).DistSq()));
				int dist2 = (int)(sqrt((double)Get(mGridIn, x, y).DistSq()));
				int dist = dist2 - dist1;

				// Clamp and scale it, just for display purposes.
				int c = dist * 5 + 180;
				if (c < 0) c = 0;
				if (c > 255) c = 255;
				ret[y * mWidth + x] = c;
			}
		}
		return ret;
	}

	inline Point Get(std::vector<Point>& g, int x, int y) {
		if (x >= 0 && y >= 0 && x < mWidth && y < mHeight)
			return g[y * mWidth + x];
		else
			return empty;
	}

	inline void Put(std::vector<Point>& g, int x, int y, const Point& p) {
		g[y * mWidth + x] = p;
	}

	inline void Compare(std::vector<Point>& g, Point& p, int x, int y, int offsetx, int offsety) {
		Point other = Get(g, x + offsetx, y + offsety);
		other.dx += offsetx;
		other.dy += offsety;

		if (other.DistSq() < p.DistSq())
			p = other;
	}

	void GenerateSDF(std::vector<Point>& g) {
		// Pass 0
		for (int y = 0; y < mHeight; ++y) {
			for (int x = 0; x < mWidth; ++x) {
				Point p = Get(g, x, y);
				Compare(g, p, x, y, -1, 0);
				Compare(g, p, x, y, 0, -1);
				Compare(g, p, x, y, -1, -1);
				Compare(g, p, x, y, 1, -1);
				Put(g, x, y, p);
			}

			for (int x = mWidth - 1; x >= 0; --x) {
				Point p = Get(g, x, y);
				Compare(g, p, x, y, 1, 0);
				Put(g, x, y, p);
			}
		}

		// Pass 1
		for (int y = mHeight - 1; y >= 0; --y) {
			for (int x = mWidth - 1; x >= 0; --x) {
				Point p = Get(g, x, y);
				Compare(g, p, x, y, 1, 0);
				Compare(g, p, x, y, 0, 1);
				Compare(g, p, x, y, -1, 1);
				Compare(g, p, x, y, 1, 1);
				Put(g, x, y, p);
			}

			for (int x = 0; x < mWidth; x++) {
				Point p = Get(g, x, y);
				Compare(g, p, x, y, -1, 0);
				Put(g, x, y, p);
			}
		}
	}

private:
	int mWidth, mHeight;
	unsigned char* mBitmap;
	std::vector<Point> mGridOut;
	std::vector<Point> mGridIn;
};
