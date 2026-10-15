//  MIT License
//
//  Copyright (c) 2023-2026 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_SETUP_H_
#define _KTM_SETUP_H_

#if defined(__clang__)
#    define KTM_COMPILER_CLANG
#elif defined(__GNUC__) || defined(__MINGW32__)
#    define KTM_COMPILER_GCC
#elif defined(_MSC_VER)
#    define KTM_COMPILER_MSVC
#else
#    error "ktm only support clang++, g++ and visual c++"
#endif

#if defined(KTM_COMPILER_MSVC)
#    define KTM_CPP_STANDARD _MSVC_LANG
#else
#    define KTM_CPP_STANDARD __cplusplus
#endif

#if KTM_CPP_STANDARD < 201703L
#    error "ktm only support cpp's version > c++17"
#endif

#if defined(KTM_COMPILER_CLANG)
#    define KTM_INLINE __inline__ __attribute__((always_inline))
#    define KTM_NOINLINE __attribute__((noinline))
#    define KTM_NOTHROW __attribute__((nothrow))
#    define KTM_ARTIFICIAL __attribute__((nodebug))
#elif defined(KTM_COMPILER_GCC)
#    define KTM_INLINE __inline__ __attribute__((__always_inline__))
#    define KTM_NOINLINE __attribute__((__noinline__))
#    define KTM_NOTHROW __attribute__((__nothrow__))
#    define KTM_ARTIFICIAL __attribute__((__artificial__))
#elif defined(KTM_COMPILER_MSVC)
#    define KTM_INLINE __forceinline
#    define KTM_NOINLINE __declspec(noinline)
#    define KTM_NOTHROW __declspec(nothrow)
#    define KTM_ARTIFICIAL __declspec(non_user_code)
#endif

#define KTM_CORE_FUNC KTM_INLINE KTM_NOTHROW
#define KTM_CORE_NI_FUNC KTM_NOINLINE KTM_NOTHROW

#endif