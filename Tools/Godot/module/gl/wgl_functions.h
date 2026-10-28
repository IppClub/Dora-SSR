#pragma once
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#include <glad/gl.h>
#include <cstring>
#include <cstdint>

// Godot's private GLAD table is separate from bgfx's GL dispatch. A standalone
// transport test links the pinned upstream GLAD source with the same header.
namespace DoraWGL {
using CreateContextAttribs=HGLRC (WINAPI *)(HDC,HGLRC,const int *);
constexpr int ContextMajor=0x2091,ContextMinor=0x2092,ContextProfileMask=0x9126,CoreProfile=0x00000001;
inline PROC resolve(const char *name) {
    PROC address=wglGetProcAddress(name);
    const auto value=reinterpret_cast<intptr_t>(address);
    if (!address || value==1 || value==2 || value==3 || value==-1) {
        static HMODULE library=GetModuleHandleW(L"opengl32.dll");
        address=library?GetProcAddress(library,name):nullptr;
    }
    return address;
}
template<class T> inline bool load(T &target,const char *name) {
    auto address=resolve(name);
    static_assert(sizeof(target)==sizeof(address));
    std::memcpy(&target,&address,sizeof(target));
    return target!=nullptr;
}
inline bool load() { return gladLoaderLoadGL()!=0 && GLAD_GL_VERSION_3_3; }
}
