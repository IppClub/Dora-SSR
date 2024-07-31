//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_ARCH_DEF_H_
#define _KTM_ARCH_DEF_H_

#include "../setup.h"

#define KTM_SIMD_NEON 0x00000001
#define KTM_SIMD_NEON64 0x00000002
#define KTM_SIMD_SSE 0x00000004
#define KTM_SIMD_SSE2 0x00000008
#define KTM_SIMD_SSE3 0x00000010
#define KTM_SIMD_SSSE3 0x00000020
#define KTM_SIMD_SSE4_1 0x00000040
#define KTM_SIMD_SSE4_2 0x00000080
#define KTM_SIMD_WASM 0x00000100
#define KTM_SIMD_ENABLE(flags) (KTM_SIMD_SUPPORT & (flags))

#if defined(KTM_COMPILER_MSVC)
	#if defined(__AVX__)
		#ifndef __SSE4_2__
			#define __SSE4_2__
		#endif
	#elif defined(_M_AMD64) || defined(_M_X64) || _M_IX86_FP == 2
		#ifndef __SSE2__
			#define __SSE2__
		#endif
	#elif _M_IX86_FP == 1
			#ifndef __SSE__
				#define __SSE__
			#endif
	#endif
#endif

#if defined(__SSE4_2__)
	#define KTM_SIMD_SUPPORT (KTM_SIMD_SSE4_2 | KTM_SIMD_SSE4_1 | KTM_SIMD_SSSE3 | KTM_SIMD_SSE3 | KTM_SIMD_SSE2 | KTM_SIMD_SSE)
	#include <nmmintrin.h>
#elif defined(__SSE4_1__)
	#define KTM_SIMD_SUPPORT (KTM_SIMD_SSE4_1 | KTM_SIMD_SSSE3 | KTM_SIMD_SSE3 | KTM_SIMD_SSE2 | KTM_SIMD_SSE)
	#include <smmintrin.h>	
#elif defined(__SSSE3__)
	#define KTM_SIMD_SUPPORT (KTM_SIMD_SSSE3 | KTM_SIMD_SSE3 | KTM_SIMD_SSE2 | KTM_SIMD_SSE)
	#include <tmmintrin.h>
#elif defined(__SSE3__)
	#define KTM_SIMD_SUPPORT (KTM_SIMD_SSE3 | KTM_SIMD_SSE2 | KTM_SIMD_SSE)
	#include <pmmintrin.h>
#elif defined(__SSE2__)
	#define KTM_SIMD_SUPPORT (KTM_SIMD_SSE2 | KTM_SIMD_SSE)
	#include <emmintrin.h>
#elif defined(__SSE__)
	#define KTM_SIMD_SUPPORT KTM_SIMD_SSE
	#include <xmmintrin.h>
#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_SSE)
	#if defined(KTM_COMPILER_MSVC)
		#if defined(_M_IX86_FP)
			#define KTM_SIMD_SSE_X86 0xffffffff
		#endif
	#else
		#if defined(__i386__) || defined(__x86_64__)
			#define KTM_SIMD_SSE_X86 0xffffffff	
		#endif
	#endif
#endif

#if defined(KTM_COMPILER_MSVC)
	#if defined(_M_ARM64) || defined(_M_HYBRID_X86_ARM64) || defined(_M_ARM64EC)
		#define KTM_SIMD_SUPPORT (KTM_SIMD_NEON | KTM_SIMD_NEON64)
		#include <arm64_neon.h>
	#elif defined(_M_ARM)
		#define KTM_SIMD_SUPPORT KTM_SIMD_NEON
		#include <arm_neon.h>
	#endif
#else
	#if defined(__ARM_FP)
		#if defined(__ARM_NEON) || defined(__ARM_NEON__)
			#if defined(__aarch64__)
				#define KTM_SIMD_SUPPORT (KTM_SIMD_NEON | KTM_SIMD_NEON64)
			#else
				#define KTM_SIMD_SUPPORT KTM_SIMD_NEON
			#endif
			#include <arm_neon.h>
		#endif
	#endif
#endif

#if defined(__wasm__) && defined (__wasm_simd128__)
	#define KTM_SIMD_SUPPORT KTM_SIMD_WASM
	#include <wasm_simd128.h>
#endif

#endif