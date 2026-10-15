/********************************************************************
 *                                                                  *
 * THIS FILE IS PART OF THE OggVorbis SOFTWARE CODEC SOURCE CODE.   *
 * USE, DISTRIBUTION AND REPRODUCTION OF THIS LIBRARY SOURCE IS     *
 * GOVERNED BY A BSD-STYLE SOURCE LICENSE INCLUDED WITH THIS SOURCE *
 * IN 'COPYING'. PLEASE READ THESE TERMS BEFORE DISTRIBUTING.       *
 *                                                                  *
 * THE OggVorbis SOURCE CODE IS (C) COPYRIGHT 1994-2003             *
 * by the XIPHOPHORUS Company http://www.xiph.org/                  *
 *                                                                  *
 ********************************************************************

 function: Header of SSE Function Library

 ********************************************************************/

#ifndef _XMMLIB_H_INCLUDED
#define _XMMLIB_H_INCLUDED

#if !defined(__INTEL_COMPILER) && !defined(__GNUC__) && !defined(_WIN32)
#error "Not supported STIN(=static inline)."
#endif

#if !defined(STIN)
#  ifdef __GNUC__
#    define STIN static __inline__
#  elif _WIN32
#    define STIN static __inline
#  else
#    define STIN static
#  endif
#endif

#if defined(__SSE__)
#if defined(__INTEL_COMPILER)
#include <ia32intrin.h>
#else
#include <xmmintrin.h>
#if defined(__SSE3__)
#include <pmmintrin.h>
#endif
#endif

#define PM64(x)		(*(__m64*)(x))
#define PM128(x)	(*(__m128*)(x))
#ifdef	__SSE2__
#define PM128I(x)	(*(__m128i*)(x))
#define PM128D(x)	(*(__m128d*)(x))
#endif

#ifndef _MM_ALIGN16
#define _MM_ALIGN16 __attribute__ ((aligned (16)))
#endif

#ifdef __GNUC__
#define _INTRIN_TYPE
#else
#define _INTRIN_TYPE __declspec(intrin_type)
#endif

typedef union {
	unsigned char	si8[8];
	unsigned short	si16[4];
	uint32_t	si32[2];
	char			ssi8[8];
	short			ssi16[4];
	int32_t			ssi32[2];
	__m64			pi64;
} __m64x;

typedef union _INTRIN_TYPE _MM_ALIGN16 __m128x{
	uint32_t	si32[4];
	float			sf[4];
	__m64			pi64[2];
	__m128			ps;
#ifdef	__SSE2__
	__m128i			pi;
	__m128d			pd;
#endif
} __m128x;

#if defined(__SSE3__)
#define	_mm_lddqu_ps(x)	_mm_castsi128_ps(_mm_lddqu_si128((__m128i*)(x)))
#else
#define	_mm_lddqu_ps(x)	_mm_loadu_ps(x)
#endif

extern _MM_ALIGN16 const uint32_t PCS_NNRN[4];
extern _MM_ALIGN16 const uint32_t PCS_NNRR[4];
extern _MM_ALIGN16 const uint32_t PCS_NRNN[4];
extern _MM_ALIGN16 const uint32_t PCS_NRNR[4];
extern _MM_ALIGN16 const uint32_t PCS_NRRN[4];
extern _MM_ALIGN16 const uint32_t PCS_NRRR[4];
extern _MM_ALIGN16 const uint32_t PCS_RNNN[4];
extern _MM_ALIGN16 const uint32_t PCS_RNRN[4];
extern _MM_ALIGN16 const uint32_t PCS_RNRR[4];
extern _MM_ALIGN16 const uint32_t PCS_RRNN[4];
extern _MM_ALIGN16 const uint32_t PCS_RNNR[4];
extern _MM_ALIGN16 const uint32_t PCS_RRRR[4];
extern _MM_ALIGN16 const uint32_t PCS_NNNR[4];
extern _MM_ALIGN16 const uint32_t PABSMASK[4];
extern _MM_ALIGN16 const uint32_t PSTARTEDGEM1[4];
extern _MM_ALIGN16 const uint32_t PSTARTEDGEM2[4];
extern _MM_ALIGN16 const uint32_t PSTARTEDGEM3[4];
extern _MM_ALIGN16 const uint32_t PENDEDGEM1[4];
extern _MM_ALIGN16 const uint32_t PENDEDGEM2[4];
extern _MM_ALIGN16 const uint32_t PENDEDGEM3[4];
extern _MM_ALIGN16 const uint32_t PMASKTABLE[16*4];

extern _MM_ALIGN16 const float PFV_0[4];
extern _MM_ALIGN16 const float PFV_1[4];
extern _MM_ALIGN16 const float PFV_2[4];
extern _MM_ALIGN16 const float PFV_4[4];
extern _MM_ALIGN16 const float PFV_8[4];
extern _MM_ALIGN16 const float PFV_INIT[4];
extern _MM_ALIGN16 const float PFV_0P5[4];
extern _MM_ALIGN16 const float PFV_M0P5[4];

extern const int bitCountTable[16];

extern void* xmm_malloc(size_t);
extern void* xmm_calloc(size_t, size_t);
extern void xmm_free(void*);
extern void* xmm_realloc(void*, size_t);
extern void* xmm_align(void*);

STIN __m128 _mm_todB_ps(__m128 x)
{
	static _MM_ALIGN16 float mparm[4] = {
		7.17711438e-7f, 7.17711438e-7f, 7.17711438e-7f, 7.17711438e-7f
	};
	static _MM_ALIGN16 float aparm[4] = {
		-764.6161886f, -764.6161886f, -764.6161886f, -764.6161886f
	};
#ifdef	__SSE2__
	__m128x	U;
	U.ps	 = _mm_and_ps(x, PM128(PABSMASK));
	U.ps	 = _mm_cvtepi32_ps(U.pi);
	U.ps	 = _mm_mul_ps(U.ps, PM128(mparm));
	U.ps	 = 	_mm_add_ps(U.ps, PM128(aparm));
	return	U.ps;
#else
#pragma warning(disable : 592)
	__m128	RESULT;
	__m128x	U;
	U.ps	 = _mm_and_ps(x, PM128(PABSMASK));
	RESULT	 = _mm_cvtpi32_ps(RESULT, U.pi64[1]);
#pragma warning(default : 592)
	RESULT	 = _mm_movelh_ps(RESULT, RESULT);
	RESULT	 = _mm_cvtpi32_ps(RESULT, U.pi64[0]);
	RESULT	 = _mm_mul_ps(RESULT, PM128(mparm));
	RESULT	 = _mm_add_ps(RESULT, PM128(aparm));
	return	RESULT;
#endif
}

STIN __m128 _mm_untnorm_ps(__m128 x)
{
	static _MM_ALIGN16 const uint32_t PIV0[4] = {
		0x3f800000, 0x3f800000, 0x3f800000, 0x3f800000
	};
	register __m128 r;
	r	 = _mm_and_ps(x, PM128(PCS_RRRR));
	r	 = _mm_or_ps(x, PM128(PIV0));
	return	r;
}

STIN float _mm_add_horz(__m128 x)
{
#if	defined(__SSE3__)
	x	 = _mm_hadd_ps(x, x);
	x	 = _mm_hadd_ps(x, x);
#else
#pragma warning(disable : 592)
	__m128	y;
	y	 = _mm_movehl_ps(y, x);
#pragma warning(default : 592)
	x	 = _mm_add_ps(x, y);
	y	 = x;
	y	 = _mm_shuffle_ps(y, y, _MM_SHUFFLE(1,1,1,1));
	x	 = _mm_add_ss(x, y);
#endif
	return _mm_cvtss_f32(x);
}

STIN __m128 _mm_add_horz_ss(__m128 x)
{
#if	defined(__SSE3__)
	x	 = _mm_hadd_ps(x, x);
	x	 = _mm_hadd_ps(x, x);
#else
#pragma warning(disable : 592)
	__m128	y;
	y	 = _mm_movehl_ps(y, x);
#pragma warning(default : 592)
	x	 = _mm_add_ps(x, y);
	y	 = x;
	y	 = _mm_shuffle_ps(y, y, _MM_SHUFFLE(1,1,1,1));
	x	 = _mm_add_ss(x, y);
#endif
	return x;
}

STIN float _mm_max_horz(__m128 x)
{
#pragma warning(disable : 592)
	__m128	y;
	y	 = _mm_movehl_ps(y, x);
#pragma warning(default : 592)
	x	 = _mm_max_ps(x, y);
	y	 = x;
	y	 = _mm_shuffle_ps(y, y, _MM_SHUFFLE(1,1,1,1));
	x	 = _mm_max_ss(x, y);
	return _mm_cvtss_f32(x);
}

STIN float _mm_min_horz(__m128 x)
{
#pragma warning(disable : 592)
	__m128	y;
	y	 = _mm_movehl_ps(y, x);
#pragma warning(default : 592)
	x	 = _mm_min_ps(x, y);
	y	 = x;
	y	 = _mm_shuffle_ps(y, y, _MM_SHUFFLE(1,1,1,1));
	x	 = _mm_min_ss(x, y);
	return _mm_cvtss_f32(x);
}

#endif /* defined(__SSE__) */

#if	0
/*---------------------------------------------------------------------------
// for calcurate performance
//-------------------------------------------------------------------------*/
extern unsigned __int64* _perf_start(void);
extern void _perf_end(unsigned __int64 *stime, int index);
extern void _perf_result(int index);
#endif

#endif /* _XMMLIB_H_INCLUDED */
