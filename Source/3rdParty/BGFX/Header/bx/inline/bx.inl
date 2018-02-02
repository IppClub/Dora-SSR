/*
 * Copyright 2010-2018 Branimir Karadzic. All rights reserved.
 * License: https://github.com/bkaradzic/bx#license-bsd-2-clause
 */

#ifndef BX_H_HEADER_GUARD
#	error "Must be included from bx/bx.h!"
#endif // BX_H_HEADER_GUARD

namespace bx
{
	template<bool>
	inline constexpr bool isEnabled()
	{
		return true;
	}

	template<>
	inline constexpr bool isEnabled<false>()
	{
		return false;
	}

	inline constexpr bool ignoreC4127(bool _x)
	{
		return _x;
	}

	template<typename Ty>
	inline void xchg(Ty& _a, Ty& _b)
	{
		Ty tmp = _a; _a = _b; _b = tmp;
	}

	template<typename Ty>
	inline constexpr Ty min(const Ty& _a, const Ty& _b)
	{
		return _a < _b ? _a : _b;
	}

	template<typename Ty>
	inline constexpr Ty max(const Ty& _a, const Ty& _b)
	{
		return _a > _b ? _a : _b;
	}

	template<typename Ty>
	inline constexpr Ty min(const Ty& _a, const Ty& _b, const Ty& _c)
	{
		return min(min(_a, _b), _c);
	}

	template<typename Ty>
	inline constexpr Ty max(const Ty& _a, const Ty& _b, const Ty& _c)
	{
		return max(max(_a, _b), _c);
	}

	template<typename Ty>
	inline constexpr Ty mid(const Ty& _a, const Ty& _b, const Ty& _c)
	{
		return max(min(_a, _b), min(max(_a, _b), _c) );
	}

	template<typename Ty>
	inline constexpr Ty clamp(const Ty& _a, const Ty& _min, const Ty& _max)
	{
		return max(min(_a, _max), _min);
	}

	template<typename Ty>
	inline constexpr bool isPowerOf2(Ty _a)
	{
		return _a && !(_a & (_a - 1) );
	}

} // namespace bx
