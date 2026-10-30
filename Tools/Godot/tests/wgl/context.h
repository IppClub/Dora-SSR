#pragma once
#include "Tools/Godot/module/gl/wgl_functions.h"
#include <cstdio>
struct WGLTestContext {
    HWND window=nullptr;
    HDC dc=nullptr;
    HGLRC context=nullptr;
    bool create() {
        window=CreateWindowExW(0,L"STATIC",L"Dora WGL transport test",WS_POPUP|WS_DISABLED,0,0,64,64,
            nullptr,nullptr,GetModuleHandleW(nullptr),nullptr);
        if (!window || !(dc=GetDC(window))) return false;
        PIXELFORMATDESCRIPTOR format{};format.nSize=sizeof(format);format.nVersion=1;
        format.dwFlags=PFD_DRAW_TO_WINDOW|PFD_SUPPORT_OPENGL|PFD_DOUBLEBUFFER;
        format.iPixelType=PFD_TYPE_RGBA;format.cColorBits=32;format.cAlphaBits=8;
        format.cDepthBits=24;format.cStencilBits=8;
        int index=ChoosePixelFormat(dc,&format);
        if (!index || !SetPixelFormat(dc,index,&format)) return false;
        HGLRC bootstrap=wglCreateContext(dc);
        if (!bootstrap) return false;
        if (!wglMakeCurrent(dc,bootstrap)) { wglDeleteContext(bootstrap);return false; }
        DoraWGL::CreateContextAttribs create=nullptr;
        if (DoraWGL::load(create,"wglCreateContextAttribsARB")) {
            const int attrs[]={DoraWGL::ContextMajor,3,DoraWGL::ContextMinor,3,
                DoraWGL::ContextProfileMask,DoraWGL::CoreProfile,0};
            context=create(dc,nullptr,attrs);
        }
        wglMakeCurrent(nullptr,nullptr);wglDeleteContext(bootstrap);
        return context && wglMakeCurrent(dc,context) && DoraWGL::load();
    }
    ~WGLTestContext() {
        if (context) { wglMakeCurrent(dc,context);if (glFinish) glFinish();wglMakeCurrent(nullptr,nullptr);wglDeleteContext(context); }
        if (dc) ReleaseDC(window,dc);
        if (window) DestroyWindow(window);
    }
};
