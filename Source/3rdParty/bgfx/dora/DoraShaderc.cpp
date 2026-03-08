/*
 * DoraShaderc - C API wrapper for bgfx shaderc
 * Implementation
 * 
 * Copyright 2026. License: BSD-2-Clause
 */

#include "DoraShaderc.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

/* bgfx shaderc headers */
#include "../tools/shaderc/shaderc.h"
#include "../src/vertexlayout.h"

#include <bx/bx.h>
#include <bx/file.h>
#include <bx/allocator.h>

/* ============================================================
 * Internal: File I/O wrapper
 * ============================================================ */

namespace {

/* Global file ops (for shaderc callbacks) */
static DoraShadercFileOps g_fileOps = {0};
static bool g_hasCustomFileOps = false;

/* Custom file reader that uses DoraShadercFileOps */
class DoraFileReader : public bx::FileReader {
public:
    DoraFileReader() : m_data(nullptr), m_size(0), m_pos(0) {}
    
    virtual ~DoraFileReader() {
        close();
    }
    
    bool open(const char* _filePath) {
        if (!g_hasCustomFileOps || !g_fileOps.readFile) {
            /* Fall back to standard file I/O */
            return bx::FileReader::open(_filePath);
        }
        
        /* Get file size first */
        long size = -1;
        if (g_fileOps.getFileSize) {
            size = g_fileOps.getFileSize(_filePath, g_fileOps.userData);
        } else {
            /* Read to get size */
            char temp[256];
            size = g_fileOps.readFile(_filePath, temp, sizeof(temp), g_fileOps.userData);
            if (size < 0) return false;
            /* We need to re-read, so this is inefficient without getFileSize */
        }
        
        if (size < 0) return false;
        
        /* Allocate buffer */
        m_data = (char*)malloc(size + 1);
        if (!m_data) return false;
        
        /* Read entire file */
        int bytesRead = g_fileOps.readFile(_filePath, m_data, (int)size, g_fileOps.userData);
        if (bytesRead != size) {
            free(m_data);
            m_data = nullptr;
            return false;
        }
        
        m_size = size;
        m_pos = 0;
        m_path = _filePath;
        return true;
    }
    
    virtual void close() {
        if (m_data) {
            free(m_data);
            m_data = nullptr;
        }
        m_size = 0;
        m_pos = 0;
    }
    
    virtual int64_t seek(int64_t _offset, bx::Whence::Enum _whence) {
        int64_t newPos = m_pos;
        switch (_whence) {
            case bx::Whence::Begin:   newPos = _offset; break;
            case bx::Whence::Current: newPos = m_pos + _offset; break;
            case bx::Whence::End:     newPos = m_size + _offset; break;
        }
        if (newPos < 0 || newPos > m_size) return -1;
        m_pos = (int64_t)newPos;
        return m_pos;
    }
    
    virtual int32_t read(void* _data, int32_t _size, bx::Error* _err) {
        if (!m_data) {
            if (m_file.isOpen()) {
                return bx::FileReader::read(_data, _size, _err);
            }
            return 0;
        }
        
        int32_t remaining = (int32_t)(m_size - m_pos);
        int32_t toRead = (_size > remaining) ? remaining : _size;
        memcpy(_data, m_data + m_pos, toRead);
        m_pos += toRead;
        return toRead;
    }
    
    virtual int64_t getSize() {
        if (m_data) return m_size;
        return bx::FileReader::getSize();
    }
    
private:
    char* m_data;
    int64_t m_size;
    int64_t m_pos;
    std::string m_path;
};

/* Memory writer for capturing compiled output */
class MemoryWriter : public bx::WriterI {
public:
    MemoryWriter() : m_data(nullptr), m_size(0), m_capacity(0) {}
    
    virtual ~MemoryWriter() {
        if (m_data) {
            free(m_data);
        }
    }
    
    virtual int32_t write(const void* _data, int32_t _size, bx::Error* _err) {
        BX_UNUSED(_err);
        
        /* Grow buffer if needed */
        if (m_size + _size > m_capacity) {
            int64_t newCapacity = m_capacity == 0 ? 4096 : m_capacity * 2;
            while (newCapacity < m_size + _size) {
                newCapacity *= 2;
            }
            
            void* newData = realloc(m_data, (size_t)newCapacity);
            if (!newData) return 0;
            
            m_data = (uint8_t*)newData;
            m_capacity = newCapacity;
        }
        
        memcpy(m_data + m_size, _data, _size);
        m_size += _size;
        return _size;
    }
    
    uint8_t* getData() { return m_data; }
    int64_t getSize() { return m_size; }
    
    /* Transfer ownership to caller */
    uint8_t* release() {
        uint8_t* data = m_data;
        m_data = nullptr;
        m_size = 0;
        m_capacity = 0;
        return data;
    }
    
private:
    uint8_t* m_data;
    int64_t m_size;
    int64_t m_capacity;
};

/* String writer for capturing error messages */
class StringWriter : public bx::WriterI {
public:
    virtual int32_t write(const void* _data, int32_t _size, bx::Error* _err) {
        BX_UNUSED(_err);
        m_str.append((const char*)_data, _size);
        return _size;
    }
    
    const std::string& get() const { return m_str; }
    bool empty() const { return m_str.empty(); }
    
private:
    std::string m_str;
};

} /* anonymous namespace */

/* ============================================================
 * Version API
 * ============================================================ */

void DoraShadercGetVersion(int* major, int* minor, int* patch) {
    if (major) *major = DORA_SHADERC_VERSION_MAJOR;
    if (minor) *minor = DORA_SHADERC_VERSION_MINOR;
    if (patch) *patch = DORA_SHADERC_VERSION_PATCH;
}

/* ============================================================
 * Platform Detection
 * ============================================================ */

DoraShadercRenderer DoraShadercGetDefaultRenderer(void) {
#if BX_PLATFORM_WINDOWS
    return DoraShadercRenderer_Direct3D11;
#elif BX_PLATFORM_OSX || BX_PLATFORM_IOS
    return DoraShadercRenderer_Metal;
#elif BX_PLATFORM_ANDROID
    return DoraShadercRenderer_OpenGLES;
#elif BX_PLATFORM_LINUX
    return DoraShadercRenderer_OpenGL;
#else
    return DoraShadercRenderer_OpenGL;
#endif
}

DoraShadercPlatform DoraShadercGetDefaultPlatform(void) {
#if BX_PLATFORM_WINDOWS
    return DoraShadercPlatform_Windows;
#elif BX_PLATFORM_OSX
    return DoraShadercPlatform_macOS;
#elif BX_PLATFORM_IOS
    return DoraShadercPlatform_iOS;
#elif BX_PLATFORM_ANDROID
    return DoraShadercPlatform_Android;
#elif BX_PLATFORM_LINUX
    return DoraShadercPlatform_Linux;
#else
    return DoraShadercPlatform_Auto;
#endif
}

int DoraShadercIsRendererSupported(DoraShadercRenderer renderer) {
    switch (renderer) {
#if BX_PLATFORM_WINDOWS
        case DoraShadercRenderer_Direct3D11:
        case DoraShadercRenderer_Direct3D12:
        case DoraShadercRenderer_OpenGL:
        case DoraShadercRenderer_Vulkan:
            return 1;
#elif BX_PLATFORM_OSX
        case DoraShadercRenderer_Metal:
        case DoraShadercRenderer_OpenGL:
        case DoraShadercRenderer_Vulkan:
            return 1;
#elif BX_PLATFORM_IOS
        case DoraShadercRenderer_Metal:
        case DoraShadercRenderer_OpenGLES:
            return 1;
#elif BX_PLATFORM_ANDROID
        case DoraShadercRenderer_OpenGLES:
        case DoraShadercRenderer_Vulkan:
            return 1;
#elif BX_PLATFORM_LINUX
        case DoraShadercRenderer_OpenGL:
        case DoraShadercRenderer_Vulkan:
            return 1;
#endif
        default:
            return 0;
    }
}

/* ============================================================
 * Utility API
 * ============================================================ */

void DoraShadercInitOptions(DoraShadercOptions* options) {
    if (!options) return;
    
    memset(options, 0, sizeof(DoraShadercOptions));
    options->renderer = DoraShadercGetDefaultRenderer();
    options->platform = DoraShadercGetDefaultPlatform();
    options->optimize = 1;
    options->debug = 0;
    options->metalUseMSL2 = 1;
    options->spirvUseSPIRV1_4 = 0;
}

const char* DoraShadercGetRendererName(DoraShadercRenderer renderer) {
    switch (renderer) {
        case DoraShadercRenderer_OpenGL: return "OpenGL";
        case DoraShadercRenderer_Metal: return "Metal";
        case DoraShadercRenderer_Direct3D11: return "Direct3D11";
        case DoraShadercRenderer_Direct3D12: return "Direct3D12";
        case DoraShadercRenderer_Vulkan: return "Vulkan";
        default: return "Unknown";
    }
}

const char* DoraShadercGetPlatformName(DoraShadercPlatform platform) {
    switch (platform) {
        case DoraShadercPlatform_Auto: return "Auto";
        case DoraShadercPlatform_Windows: return "Windows";
        case DoraShadercPlatform_macOS: return "macOS";
        case DoraShadercPlatform_iOS: return "iOS";
        case DoraShadercPlatform_Android: return "Android";
        case DoraShadercPlatform_Linux: return "Linux";
        case DoraShadercPlatform_Web: return "Web";
        default: return "Unknown";
    }
}

/* ============================================================
 * Core Compile API
 * ============================================================ */

DoraShadercResult DoraShadercCompile(
    const char* source,
    int sourceSize,
    const DoraShadercOptions* options
) {
    DoraShadercResult result;
    memset(&result, 0, sizeof(result));
    
    if (!source || !options) {
        result.success = 0;
        result.errorMessage = strdup("Invalid parameters: source and options must not be NULL");
        return result;
    }
    
    /* Get source length if not provided */
    if (sourceSize < 0) {
        sourceSize = (int)strlen(source);
    }
    
    /* Setup file ops */
    if (options->fileOps) {
        g_fileOps = *options->fileOps;
        g_hasCustomFileOps = true;
    } else {
        memset(&g_fileOps, 0, sizeof(g_fileOps));
        g_hasCustomFileOps = false;
    }
    
    /* Convert to bgfx shaderc options */
    bgfx::Options bgfxOpts;
    
    /* Shader type */
    switch (options->stage) {
        case DoraShadercStage_Vertex:
            bgfxOpts.shaderType = 'v';
            break;
        case DoraShadercStage_Fragment:
            bgfxOpts.shaderType = 'f';
            break;
        case DoraShadercStage_Compute:
            bgfxOpts.shaderType = 'c';
            break;
        default:
            bgfxOpts.shaderType = 'v';
            break;
    }
    
    /* Platform and profile */
    switch (options->renderer) {
        case DoraShadercRenderer_OpenGL:
        case DoraShadercRenderer_OpenGLES:
            bgfxOpts.platform = "glsl";
            bgfxOpts.profile = options->platform == DoraShadercPlatform_Android ? "100_es" : "430";
            break;
        case DoraShadercRenderer_Metal:
            bgfxOpts.platform = "metal";
            bgfxOpts.profile = options->metalUseMSL2 ? "metal-osx" : "metal";
            break;
        case DoraShadercRenderer_Direct3D11:
            bgfxOpts.platform = "hlsl";
            bgfxOpts.profile = "vs_5_0";  /* or ps_5_0 for fragment */
            break;
        case DoraShadercRenderer_Direct3D12:
            bgfxOpts.platform = "hlsl";
            bgfxOpts.profile = "vs_5_1";
            break;
        case DoraShadercRenderer_Vulkan:
            bgfxOpts.platform = "spirv";
            bgfxOpts.profile = options->spirvUseSPIRV1_4 ? "spirv14" : "spirv";
            break;
    }
    
    /* Include directories */
    if (options->includeDirs && options->includeDirCount > 0) {
        for (int i = 0; i < options->includeDirCount; i++) {
            if (options->includeDirs[i]) {
                bgfxOpts.includeDirs.push_back(options->includeDirs[i]);
            }
        }
    }
    
    /* Defines */
    if (options->defines && options->defineCount > 0) {
        for (int i = 0; i < options->defineCount; i++) {
            if (options->defines[i]) {
                bgfxOpts.defines.push_back(options->defines[i]);
            }
        }
    }
    
    /* Optimization */
    bgfxOpts.optimize = options->optimize != 0;
    bgfxOpts.debugInformation = options->debug != 0;
    
    /* Create output writers */
    MemoryWriter bytecodeWriter;
    StringWriter messageWriter;
    
    /* Copy source to string (shaderc expects std::string) */
    std::string sourceStr(source, sourceSize);
    
    /* Compile based on renderer type */
    bool success = false;
    uint32_t version = 1;  /* Shader version */
    
    switch (options->renderer) {
        case DoraShadercRenderer_OpenGL:
        case DoraShadercRenderer_OpenGLES:
            success = bgfx::compileGLSLShader(bgfxOpts, version, sourceStr, &bytecodeWriter, &messageWriter);
            break;
            
        case DoraShadercRenderer_Metal:
            success = bgfx::compileMetalShader(bgfxOpts, version, sourceStr, &bytecodeWriter, &messageWriter);
            break;
            
        case DoraShadercRenderer_Direct3D11:
        case DoraShadercRenderer_Direct3D12:
            success = bgfx::compileHLSLShader(bgfxOpts, version, sourceStr, &bytecodeWriter, &messageWriter);
            break;
            
        case DoraShadercRenderer_Vulkan:
            success = bgfx::compileSPIRVShader(bgfxOpts, version, sourceStr, &bytecodeWriter, &messageWriter);
            break;
    }
    
    /* Fill result */
    result.success = success ? 1 : 0;
    
    if (success) {
        /* Transfer bytecode ownership */
        result.bytecodeSize = (int)bytecodeWriter.getSize();
        result.bytecode = bytecodeWriter.release();
        
        /* Calculate hash from bytecode */
        if (result.bytecode && result.bytecodeSize > 0) {
            bx::HashMurmur2A hash;
            hash.begin();
            hash.add(result.bytecode, result.bytecodeSize);
            result.hash = (uint16_t)hash.end();
        }
    }
    
    /* Copy error/warning messages */
    if (!messageWriter.empty()) {
        result.errorMessage = strdup(messageWriter.get().c_str());
    }
    
    return result;
}

DoraShadercResult DoraShadercCompileFromFile(
    const char* sourceFile,
    const DoraShadercOptions* options
) {
    DoraShadercResult result;
    memset(&result, 0, sizeof(result));
    
    if (!sourceFile || !options) {
        result.success = 0;
        result.errorMessage = strdup("Invalid parameters: sourceFile and options must not be NULL");
        return result;
    }
    
    /* Setup file ops */
    if (options->fileOps) {
        g_fileOps = *options->fileOps;
        g_hasCustomFileOps = true;
    } else {
        memset(&g_fileOps, 0, sizeof(g_fileOps));
        g_hasCustomFileOps = false;
    }
    
    /* Read file */
    char* source = nullptr;
    int sourceSize = 0;
    
    if (g_hasCustomFileOps && g_fileOps.readFile) {
        /* Use custom file I/O */
        long size = -1;
        if (g_fileOps.getFileSize) {
            size = g_fileOps.getFileSize(sourceFile, g_fileOps.userData);
        }
        
        if (size < 0) {
            result.success = 0;
            result.errorMessage = strdup("Failed to get file size");
            return result;
        }
        
        source = (char*)malloc((size_t)size + 1);
        if (!source) {
            result.success = 0;
            result.errorMessage = strdup("Failed to allocate memory");
            return result;
        }
        
        int bytesRead = g_fileOps.readFile(sourceFile, source, (int)size, g_fileOps.userData);
        if (bytesRead != size) {
            free(source);
            result.success = 0;
            result.errorMessage = strdup("Failed to read file");
            return result;
        }
        source[size] = '\0';
        sourceSize = (int)size;
    } else {
        /* Use standard file I/O */
        FILE* f = fopen(sourceFile, "rb");
        if (!f) {
            result.success = 0;
            char buf[256];
            snprintf(buf, sizeof(buf), "Failed to open file: %s", sourceFile);
            result.errorMessage = strdup(buf);
            return result;
        }
        
        fseek(f, 0, SEEK_END);
        long size = ftell(f);
        fseek(f, 0, SEEK_SET);
        
        source = (char*)malloc((size_t)size + 1);
        if (!source) {
            fclose(f);
            result.success = 0;
            result.errorMessage = strdup("Failed to allocate memory");
            return result;
        }
        
        sourceSize = (int)fread(source, 1, (size_t)size, f);
        source[sourceSize] = '\0';
        fclose(f);
    }
    
    /* Compile */
    DoraShadercOptions opts = *options;
    opts.fileOps = nullptr;  /* Already read the file */
    
    result = DoraShadercCompile(source, sourceSize, &opts);
    
    free(source);
    return result;
}

void DoraShadercFreeResult(DoraShadercResult* result) {
    if (!result) return;
    
    if (result->bytecode) {
        free(result->bytecode);
        result->bytecode = nullptr;
    }
    
    if (result->errorMessage) {
        free(result->errorMessage);
        result->errorMessage = nullptr;
    }
    
    if (result->warningMessage) {
        free(result->warningMessage);
        result->warningMessage = nullptr;
    }
    
    result->bytecodeSize = 0;
    result->success = 0;
}

/* ============================================================
 * Quick Compile API
 * ============================================================ */

DoraShadercResult DoraShadercCompileVertexShader(
    const char* source,
    int sourceSize,
    DoraShadercRenderer renderer
) {
    DoraShadercOptions options;
    DoraShadercInitOptions(&options);
    options.stage = DoraShadercStage_Vertex;
    options.renderer = renderer;
    
    return DoraShadercCompile(source, sourceSize, &options);
}

DoraShadercResult DoraShadercCompileFragmentShader(
    const char* source,
    int sourceSize,
    DoraShadercRenderer renderer
) {
    DoraShadercOptions options;
    DoraShadercInitOptions(&options);
    options.stage = DoraShadercStage_Fragment;
    options.renderer = renderer;
    
    return DoraShadercCompile(source, sourceSize, &options);
}
