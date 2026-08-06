/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

#pragma once

#include <cstdint>

namespace Dora::Love
{

struct PhysicsFilter
{
	std::uint16_t categoryBits = 0x0001;
	std::uint16_t maskBits = 0xffff;
	std::int16_t groupIndex = 0;
};

constexpr bool shouldPhysicsFiltersCollide(const PhysicsFilter &a,
	const PhysicsFilter &b) noexcept
{
	if (a.groupIndex != 0 && a.groupIndex == b.groupIndex)
		return a.groupIndex > 0;
	return (a.maskBits & b.categoryBits) != 0
		&& (b.maskBits & a.categoryBits) != 0;
}

} // namespace Dora::Love
