/*
 * DoraShaderc - C API wrapper for bgfx shaderc
 * Provides runtime shader compilation for Dora game engine
 * 
 * Copyright 2026. License: BSD-2-Clause
 */

#ifndef DORA_SHADERC_H
#define DORA_SHADERC_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ============================================================
 * Version
 * ============================================================ */

#define DORA_SHADERC_VERSION_MAJOR 1
#define DORA_SHADERC_VERSION_MINOR 0
#define DORA_SHADERC_VERSION_PATCH 0

/* ============================================================
 * File Operations Callbacks
 * ============================================================ */

/**
 * File read callback
 * 
 * @param path File path
 * @param buffer Output buffer (allocated by caller)
 * @param bufferSize Buffer size in bytes
 * @param userData User data pointer
 * @return Bytes read, or -1 on error
 */
typedef int (*DoraShadercFileReadFunc)(
    const char* path,
    char* buffer,
    int bufferSize,
    void* userData
);

/**
 * File exists callback
 * 
 * @param path File path
 * @param userData User data pointer
 * @return 1 if exists, 0 otherwise
 */
typedef int (*DoraShadercFileExistsFunc)(
    const char* path,
    void* userData
);

/**
 * Get file size callback (optional)
 * 
 * @param path File path
 * @param userData User data pointer
 * @return File size in bytes, or -1 on error
 */
typedef long (*DoraShadercFileSizeFunc)(
    const char* path,
    void* userData
);

/**
 * File operations interface
 * Pass this to enable custom file I/O (e.g., Dora's cross-platform Content API)
 */
typedef struct {
    DoraShadercFileReadFunc readFile;
    DoraShadercFileExistsFunc fileExists;
    DoraShadercFileSizeFunc getFileSize;  /* Optional, can be NULL */
    void* userData;                        /* Passed to all callbacks */
} DoraShadercFileOps;

/* ============================================================
 * Enums
 * ============================================================ */

/**
 * Shader stage
 */
typedef enum {
    DoraShadercStage_Vertex = 0,
    DoraShadercStage_Fragment = 1,
    DoraShadercStage_Compute = 2,  /* Reserved for future use */
} DoraShadercStage;

/**
 * Renderer backend
 */
typedef enum {
    DoraShadercRenderer_OpenGL = 0,       /* OpenGL / OpenGL ES */
    DoraShadercRenderer_OpenGLES = 0,     /* Alias for OpenGL */
    DoraShadercRenderer_Metal = 1,        /* Apple Metal */
    DoraShadercRenderer_Direct3D11 = 2,   /* Windows D3D11 */
    DoraShadercRenderer_Direct3D12 = 3,   /* Windows D3D12 */
    DoraShadercRenderer_Vulkan = 4,       /* Vulkan */
} DoraShadercRenderer;

/**
 * Platform (auto-detected from renderer if not specified)
 */
typedef enum {
    DoraShadercPlatform_Auto = 0,         /* Auto-detect from renderer */
    DoraShadercPlatform_Windows = 1,
    DoraShadercPlatform_macOS = 2,
    DoraShadercPlatform_iOS = 3,
    DoraShadercPlatform_Android = 4,
    DoraShadercPlatform_Linux = 5,
    DoraShadercPlatform_Web = 6,
} DoraShadercPlatform;

/* ============================================================
 * Options
 * ============================================================ */

/**
 * Compile options
 */
typedef struct {
    /* Required */
    DoraShadercStage stage;
    DoraShadercRenderer renderer;
    
    /* Optional: platform (auto-detected from renderer if not specified) */
    DoraShadercPlatform platform;
    
    /* Optimization */
    int optimize;              /* 0 = no optimization, 1 = optimize (default: 1) */
    int debug;                 /* 0 = no debug info, 1 = include debug info (default: 0) */
    
    /* Preprocessor */
    const char** defines;      /* NULL-terminated array of defines (e.g., "FOO=1") */
    int defineCount;
    
    const char** includeDirs;  /* NULL-terminated array of include paths */
    int includeDirCount;
    
    /* GLSL-specific: varying definition file */
    const char* varyingDefPath;  /* Path to varying.def.sc (optional) */
    
    /* Metal-specific */
    int metalUseMSL2;          /* Use MSL 2.0 (default: 1) */
    
    /* SPIR-V / Vulkan specific */
    int spirvUseSPIRV1_4;      /* Use SPIR-V 1.4 (default: 0) */
    
    /* File operations (optional, uses standard file I/O if NULL) */
    const DoraShadercFileOps* fileOps;
} DoraShadercOptions;

/**
 * Compile result
 */
typedef struct {
    int success;               /* 1 = success, 0 = failure */
    
    /* Compiled bytecode (call DoraShadercFreeResult to free) */
    uint8_t* bytecode;
    int bytecodeSize;
    
    /* Hash of uniform table (for bgfx) */
    uint16_t hash;
    
    /* Error/warning messages (call DoraShadercFreeResult to free) */
    char* errorMessage;        /* NULL if no error */
    char* warningMessage;      /* NULL if no warning */
} DoraShadercResult;

/* ============================================================
 * Core API
 * ============================================================ */

/**
 * Get library version
 */
void DoraShadercGetVersion(int* major, int* minor, int* patch);

/**
 * Get default renderer for current platform
 * 
 * Returns:
 *   - OpenGL on Linux
 *   - Metal on macOS/iOS
 *   - Direct3D11 on Windows
 *   - OpenGLES on Android
 */
DoraShadercRenderer DoraShadercGetDefaultRenderer(void);

/**
 * Get default platform for current system
 */
DoraShadercPlatform DoraShadercGetDefaultPlatform(void);

/**
 * Check if a renderer is supported on current platform
 */
int DoraShadercIsRendererSupported(DoraShadercRenderer renderer);

/**
 * Compile shader from source code
 * 
 * @param source GLSL source code (with $input/$output annotations)
 * @param sourceSize Size of source code in bytes (-1 for null-terminated)
 * @param options Compile options
 * @return Compile result (call DoraShadercFreeResult when done)
 */
DoraShadercResult DoraShadercCompile(
    const char* source,
    int sourceSize,
    const DoraShadercOptions* options
);

/**
 * Compile shader from file
 * 
 * @param sourceFile Path to shader source file
 * @param options Compile options (fileOps can be used for custom file I/O)
 * @return Compile result (call DoraShadercFreeResult when done)
 */
DoraShadercResult DoraShadercCompileFromFile(
    const char* sourceFile,
    const DoraShadercOptions* options
);

/**
 * Free compile result
 * 
 * Must be called to free memory allocated by DoraShadercCompile or
 * DoraShadercCompileFromFile.
 */
void DoraShadercFreeResult(DoraShadercResult* result);

/**
 * Get renderer name as string
 */
const char* DoraShadercGetRendererName(DoraShadercRenderer renderer);

/**
 * Get platform name as string
 */
const char* DoraShadercGetPlatformName(DoraShadercPlatform platform);

/* ============================================================
 * Utility API
 * ============================================================ */

/**
 * Create default options
 * 
 * Fills the options struct with sensible defaults:
 *   - optimize = 1
 *   - debug = 0
 *   - renderer = auto-detected
 *   - platform = auto-detected
 */
void DoraShadercInitOptions(DoraShadercOptions* options);

/**
 * Quick compile vertex shader
 * 
 * Convenience function for simple vertex shader compilation.
 * Uses default options with specified renderer.
 */
DoraShadercResult DoraShadercCompileVertexShader(
    const char* source,
    int sourceSize,
    DoraShadercRenderer renderer
);

/**
 * Quick compile fragment shader
 * 
 * Convenience function for simple fragment shader compilation.
 * Uses default options with specified renderer.
 */
DoraShadercResult DoraShadercCompileFragmentShader(
    const char* source,
    int sourceSize,
    DoraShadercRenderer renderer
);

#ifdef __cplusplus
}
#endif

#endif /* DORA_SHADERC_H */
