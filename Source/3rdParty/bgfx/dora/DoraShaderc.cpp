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
#include <vector>

/* bgfx shaderc headers */
#include "../tools/shaderc/shaderc.h"
#include "../src/vertexlayout.h"

#include <bx/bx.h>
#include <bx/file.h>
#include <bx/allocator.h>

namespace bgfx {
bool compileShader(const char* _varying, const char* _comment, char* _shader, uint32_t _shaderLen, const Options& _options, bx::WriterI* _shaderWriter, bx::WriterI* _messageWriter);
}

/* ============================================================
 * Internal: File I/O wrapper
 * ============================================================ */

namespace {

static DoraShadercRenderer getBuiltInRenderer() {
#if SHADERC_CONFIG_HLSL
    return DoraShadercRenderer_Direct3D11;
#elif SHADERC_CONFIG_METAL
    return DoraShadercRenderer_Metal;
#elif SHADERC_CONFIG_GLSL
    return BX_PLATFORM_ANDROID ? DoraShadercRenderer_OpenGLES : DoraShadercRenderer_OpenGL;
#elif SHADERC_CONFIG_SPIRV
    return DoraShadercRenderer_Vulkan;
#else
    return DoraShadercRenderer_OpenGL;
#endif
}

static DoraShadercPlatform resolvePlatform(DoraShadercPlatform platform) {
    if (platform != DoraShadercPlatform_Auto) {
        return platform;
    }
    return DoraShadercGetDefaultPlatform();
}

static const char* getBgfxPlatformName(DoraShadercPlatform platform) {
    switch (platform) {
        case DoraShadercPlatform_Windows:
            return "windows";
        case DoraShadercPlatform_macOS:
            return "osx";
        case DoraShadercPlatform_iOS:
            return "ios";
        case DoraShadercPlatform_Android:
            return "android";
        case DoraShadercPlatform_Linux:
            return "linux";
        case DoraShadercPlatform_Web:
            return "asm.js";
        case DoraShadercPlatform_Auto:
        default:
            return "";
    }
}

static bool isRendererBuilt(DoraShadercRenderer renderer) {
    switch (renderer) {
        case DoraShadercRenderer_OpenGL:
#if SHADERC_CONFIG_GLSL
            return true;
#else
            return false;
#endif
        case DoraShadercRenderer_Metal:
#if SHADERC_CONFIG_METAL
            return true;
#else
            return false;
#endif
        case DoraShadercRenderer_Direct3D11:
#if SHADERC_CONFIG_HLSL
            return true;
#else
            return false;
#endif
        case DoraShadercRenderer_Direct3D12:
            return false;
        case DoraShadercRenderer_Vulkan:
#if SHADERC_CONFIG_SPIRV
            return true;
#else
            return false;
#endif
        default:
            return false;
    }
}

static const char* getShaderProfile(
    DoraShadercStage stage,
    DoraShadercRenderer renderer,
    DoraShadercPlatform platform,
    const DoraShadercOptions* options
) {
    switch (renderer) {
        case DoraShadercRenderer_OpenGL:
            if (platform == DoraShadercPlatform_Android) {
                return stage == DoraShadercStage_Compute ? "310_es" : "300_es";
            }
            return "430";
        case DoraShadercRenderer_Metal:
            return "metal";
        case DoraShadercRenderer_Direct3D11:
            return stage == DoraShadercStage_Compute ? "s_5_0" : "s_4_0";
        case DoraShadercRenderer_Direct3D12:
            return "s_5_0";
        case DoraShadercRenderer_Vulkan:
            return options->spirvUseSPIRV1_4 ? "spirv14-11" : "spirv";
        default:
            return nullptr;
    }
}

static std::string getDefaultVaryingDefPath(const char* sourcePath) {
    if (!sourcePath || *sourcePath == '\0') {
        return {};
    }
    bx::FilePath filePath(sourcePath);
    const bx::StringView dir = filePath.getPath();
    if (dir.isEmpty()) {
        return "varying.def.sc";
    }
    return std::string(dir.getPtr(), dir.getTerm()) + "varying.def.sc";
}

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

/* Helper: read file using custom file ops or standard I/O */
static char* readFile(
    const char* path,
    int* outSize,
    const DoraShadercFileOps* fileOps
) {
    char* data = nullptr;
    int size = 0;
    
    if (fileOps && fileOps->readFile) {
        /* Use custom file I/O */
        long fileSize = -1;
        if (fileOps->getFileSize) {
            fileSize = fileOps->getFileSize(path, fileOps->userData);
        }
        
        if (fileSize < 0) {
            return nullptr;
        }
        
        data = (char*)malloc((size_t)fileSize + 1);
        if (!data) {
            return nullptr;
        }
        
        int bytesRead = fileOps->readFile(path, data, (int)fileSize, fileOps->userData);
        if (bytesRead != fileSize) {
            free(data);
            return nullptr;
        }
        data[fileSize] = '\0';
        size = (int)fileSize;
    } else {
        /* Use standard file I/O */
        FILE* f = fopen(path, "rb");
        if (!f) {
            return nullptr;
        }
        
        fseek(f, 0, SEEK_END);
        long fileSize = ftell(f);
        fseek(f, 0, SEEK_SET);
        
        data = (char*)malloc((size_t)fileSize + 1);
        if (!data) {
            fclose(f);
            return nullptr;
        }
        
        size = (int)fread(data, 1, (size_t)fileSize, f);
        data[size] = '\0';
        fclose(f);
    }
    
    if (outSize) {
        *outSize = size;
    }
    return data;
}

static void trimUtf8Bom(char* data, int& size) {
    if (size >= 3
        && data[0] == '\xef'
        && data[1] == '\xbb'
        && data[2] == '\xbf') {
        memmove(data, data + 3, (size_t)(size - 3));
        size -= 3;
    }
}

static DoraShadercResult compileSourceInternal(
    const char* source,
    int sourceSize,
    const DoraShadercOptions* options,
    const char* sourcePath
) {
    DoraShadercResult result;
    memset(&result, 0, sizeof(result));

    if (!source || !options) {
        result.success = 0;
        result.errorMessage = strdup("Invalid parameters: source and options must not be NULL");
        return result;
    }

    if (sourceSize < 0) {
        sourceSize = (int)strlen(source);
    }

    if (!isRendererBuilt(options->renderer)) {
        std::string message = "Renderer target is not available in this DoraShaderc build: ";
        message += DoraShadercGetRendererName(options->renderer);
        result.errorMessage = strdup(message.c_str());
        return result;
    }

    const DoraShadercPlatform platform = resolvePlatform(options->platform);
    const char* profile = getShaderProfile(options->stage, options->renderer, platform, options);
    if (!profile) {
        result.errorMessage = strdup("Unable to resolve a shader profile for the requested renderer");
        return result;
    }

    bgfx::Options bgfxOpts;
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
            result.errorMessage = strdup("Unsupported shader stage");
            return result;
    }

    bgfxOpts.platform = getBgfxPlatformName(platform);
    bgfxOpts.profile = profile;
    bgfxOpts.inputFilePath = sourcePath ? sourcePath : "memory.sc";
    bgfxOpts.outputFilePath.clear();
    bgfxOpts.optimize = options->optimize != 0;
    bgfxOpts.debugInformation = options->debug != 0;

    if (options->includeDirs && options->includeDirCount > 0) {
        for (int i = 0; i < options->includeDirCount; i++) {
            if (options->includeDirs[i]) {
                bgfxOpts.includeDirs.push_back(options->includeDirs[i]);
            }
        }
    }

    if (options->defines && options->defineCount > 0) {
        for (int i = 0; i < options->defineCount; i++) {
            if (options->defines[i]) {
                bgfxOpts.defines.push_back(options->defines[i]);
            }
        }
    }

    std::vector<char> varyingStorage;
    const char* varying = nullptr;
    if (bgfxOpts.shaderType != 'c') {
        std::string varyingPath = options->varyingDefPath ? options->varyingDefPath : "";
        if (varyingPath.empty()) {
            varyingPath = getDefaultVaryingDefPath(sourcePath);
        }
        if (!varyingPath.empty()) {
            int varyingSize = 0;
            char* varyingData = readFile(varyingPath.c_str(), &varyingSize, options->fileOps);
            if (varyingData) {
                trimUtf8Bom(varyingData, varyingSize);
                varyingStorage.assign(varyingData, varyingData + varyingSize);
                varyingStorage.push_back('\0');
                varying = varyingStorage.data();
                bgfxOpts.dependencies.push_back(varyingPath);
                free(varyingData);
            }
        }
    }

    const int extraPadding = 16384;
    std::vector<char> shaderBuffer((size_t)sourceSize + extraPadding, 0);
    memcpy(shaderBuffer.data(), source, (size_t)sourceSize);
    int mutableSourceSize = sourceSize;
    trimUtf8Bom(shaderBuffer.data(), mutableSourceSize);
    shaderBuffer[(size_t)mutableSourceSize] = '\n';

    MemoryWriter bytecodeWriter;
    StringWriter messageWriter;
    const char* comment = "// compiled by DoraShaderc\n\n";

    const bool success = bgfx::compileShader(
        varying,
        comment,
        shaderBuffer.data(),
        (uint32_t)mutableSourceSize,
        bgfxOpts,
        &bytecodeWriter,
        &messageWriter);

    result.success = success ? 1 : 0;
    if (success) {
        result.bytecodeSize = (int)bytecodeWriter.getSize();
        result.bytecode = bytecodeWriter.release();
        if (result.bytecode && result.bytecodeSize > 0) {
            bx::HashMurmur2A hash;
            hash.begin();
            hash.add(result.bytecode, result.bytecodeSize);
            result.hash = (uint16_t)hash.end();
        }
    }

    if (!messageWriter.empty()) {
        if (success) {
            result.warningMessage = strdup(messageWriter.get().c_str());
        } else {
            result.errorMessage = strdup(messageWriter.get().c_str());
        }
    }

    return result;
}

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
    return getBuiltInRenderer();
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
    return isRendererBuilt(renderer) ? 1 : 0;
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
    return compileSourceInternal(source, sourceSize, options, nullptr);
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
    
    /* Read file */
    int sourceSize = 0;
    char* source = readFile(sourceFile, &sourceSize, options->fileOps);
    
    if (!source) {
        result.success = 0;
        char buf[256];
        snprintf(buf, sizeof(buf), "Failed to read file: %s", sourceFile);
        result.errorMessage = strdup(buf);
        return result;
    }
    
    DoraShadercOptions opts = *options;
    result = compileSourceInternal(source, sourceSize, &opts, sourceFile);
    
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
