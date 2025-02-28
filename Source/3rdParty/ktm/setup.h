//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_SETUP_H_
#define _KTM_SETUP_H_

// c++ compiler config
#if defined(__clang__) && defined(__GNUC__)
#    define KTM_COMPILER_CLANG
#elif defined(__GNUC__) || defined(__MINGW32__)
#    define KTM_COMPILER_GCC
#elif defined(_MSC_VER)
#    define KTM_COMPILER_MSVC
#else
#    error "ktm only support clang++, g++ and visual c++"
#endif

#if defined(KTM_COMPILER_CLANG) || defined(KTM_COMPILER_GCC)
#    define KTM_CPP_STANDARD __cplusplus
#elif defined(KTM_COMPILER_MSVC)
#    define KTM_CPP_STANDARD _MSVC_LANG
#endif

#if KTM_CPP_STANDARD < 201703L
#    error "ktm only support cpp's version > c++17"
#endif

// function config
#if defined(KTM_COMPILER_CLANG)
#    define KTM_INLINE __inline__ __attribute__((always_inline))
#    define KTM_NOINLINE __attribute__((noinline))
#    define KTM_FUNC __inline__ __attribute__((always_inline, nothrow, nodebug))
#elif defined(KTM_COMPILER_GCC)
#    define KTM_INLINE __inline__ __attribute__((__always_inline__))
#    define KTM_NOINLINE __attribute__((__noinline__))
#    define KTM_FUNC __inline__ __attribute__((__always_inline__, __nothrow__, __artificial__))
#elif defined(KTM_COMPILER_MSVC)
#    define KTM_INLINE __forceinline
#    define KTM_NOINLINE __declspec(noinline)
#    define KTM_FUNC __forceinline __declspec(nothrow)
#endif

#endif