// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#include "Const/Header.h"
#include "Godot/GodotNode.h"
#include "Basic/Content.h"
#include "Event/Event.h"
#include "Cache/ShaderCache.h"
#include "Shader/ShaderCompiler.h"
#include "Effect/Effect.h"
#include "Input/TouchDispather.h"
#include "Input/Keyboard.h"

NS_DORA_BEGIN
#if BX_PLATFORM_OSX || BX_PLATFORM_IOS
std::shared_ptr<GodotSession> createGodotMetalSession(GodotNode *node);
void shutdownGodotMetalRuntime();
std::string godotMetalUnsupportedReason();
#elif BX_PLATFORM_LINUX || BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID || (BX_PLATFORM_EMSCRIPTEN && !defined(DORA_WEB_NO_GODOT))
std::shared_ptr<GodotSession> createGodotGLSession(GodotNode *node);
void shutdownGodotGLRuntime();
#endif
namespace {
bool validateGodotProject(std::string &project, int width, int height, int buffers) {
    if (width < 1 || height < 1 || width > 8192 || height > 8192 || buffers < 2 || buffers > DORA_GODOT_MAX_BUFFERS) {
        Error("GodotNode: invalid viewport dimensions or buffer count"); return false;
    }
    project = SharedContent.getFullPath(project);
    const bool packaged=Path::getExt(project)=="pck"_slice && SharedContent.exist(project);
    if (project.empty() || (!SharedContent.isFolder(project) && !packaged)) {
        Error("GodotNode: project directory or .pck bundle was not found"); return false;
    }
    return true;
}
}
std::string GodotNode::getUnsupportedReason() {
#if BX_PLATFORM_OSX || BX_PLATFORM_IOS
    if (bgfx::getRendererType()!=bgfx::RendererType::Metal) return "Metal renderer required on Apple platforms";
    return godotMetalUnsupportedReason();
#elif BX_PLATFORM_WINDOWS
    if (bgfx::getRendererType()!=bgfx::RendererType::OpenGL) return "Windows WGL requires DORA_GODOT_WINDOWS_GL=1 before host startup";
#elif BX_PLATFORM_LINUX || BX_PLATFORM_ANDROID || (BX_PLATFORM_EMSCRIPTEN && !defined(DORA_WEB_NO_GODOT))
    if (bgfx::getRendererType()!=bgfx::RendererType::OpenGL && bgfx::getRendererType()!=bgfx::RendererType::OpenGLES) return "OpenGL/OpenGLES renderer required";
#else
    return "GPU backend is not implemented for this target";
#endif
    return {};
}
GodotNode *GodotNode::create(String projectPath, String sceneFile, int width, int height, int buffers) {
    const auto unsupported=getUnsupportedReason();
    if (!unsupported.empty()) { Error("GodotNode: {}",unsupported); return nullptr; }
    // Reject invalid requests before Sprite construction creates GPU effects.
    // A Wasm startup failure may exit before any Sprite is rendered, so those
    // effects must not introduce a renderer singleton during failed creation.
    std::string project=projectPath.toString();
    if (!validateGodotProject(project,width,height,buffers)) return nullptr;
#if BX_PLATFORM_OSX || BX_PLATFORM_IOS
    if (bgfx::getRendererType()!=bgfx::RendererType::Metal) {
        Error("GodotNode: Metal renderer required on Apple platforms"); return nullptr;
    }
#elif BX_PLATFORM_LINUX || BX_PLATFORM_ANDROID || (BX_PLATFORM_EMSCRIPTEN && !defined(DORA_WEB_NO_GODOT))
    if (bgfx::getRendererType()!=bgfx::RendererType::OpenGL && bgfx::getRendererType()!=bgfx::RendererType::OpenGLES) {
        Error("GodotNode: EGL OpenGL/OpenGLES renderer required on Linux/Android"); return nullptr;
    }
#elif BX_PLATFORM_WINDOWS
    if (bgfx::getRendererType()!=bgfx::RendererType::OpenGL) {
        Error("GodotNode: Windows WGL requires DORA_GODOT_WINDOWS_GL=1 before host startup"); return nullptr;
    }
#else
    Error("GodotNode: native GPU backend is not implemented for this target yet"); return nullptr;
#endif
    return Object::create<GodotNode>(project,sceneFile,width,height,buffers);
}
GodotNode::GodotNode(String project, String scene, int width, int height, int buffers)
    : _project(project.toString()), _scene(scene.toString()), _pixelWidth(width), _pixelHeight(height), _buffers(buffers) {}
GodotNode::~GodotNode() { if (_session) _session->close(); }
bool GodotNode::init() {
    bool initialized=false;
    DEFER(if (!initialized) {
        // Node construction registers an unmanaged reference with Director.
        // Failed nodes must not be adopted into the scene on the next frame.
        setAsManaged();
        cleanup();
    });
    if (!Sprite::init()) return false;
    if (!validateGodotProject(_project,_pixelWidth,_pixelHeight,_buffers)) return false;
#if BX_PLATFORM_OSX || BX_PLATFORM_IOS
    _session = createGodotMetalSession(this);
#elif BX_PLATFORM_LINUX || BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID || (BX_PLATFORM_EMSCRIPTEN && !defined(DORA_WEB_NO_GODOT))
    _session = createGodotGLSession(this);
#else
    Error("GodotNode: native GPU backend is not implemented for this target yet");
    return false;
#endif
    // Godot transparent viewports contain premultiplied RGBA, including
    // additive pixels whose RGB can exceed alpha. Preserve that encoding and
    // apply Sprite opacity to both RGB and alpha before premultiplied blending.
    // This stays in the consumer draw: no CPU transfer or extra texture copy.
    std::string shaderError;
    const char *alphaSource=R"SHADER($input v_color0, v_texcoord0
#include <bgfx_shader.sh>
SAMPLER2D(s_texColor, 0);
void main() {
    vec4 color=texture2D(s_texColor,v_texcoord0);
    gl_FragColor=vec4(color.rgb*v_color0.rgb*v_color0.a,color.a*v_color0.a);
}
)SHADER";
#if defined(DORA_GODOT_NODE_TEST)
    // Exercise the real compiler failure and node cleanup, only in test hosts.
    const char *shaderFailure=std::getenv("DORA_GODOT_TEST_SHADER_FAILURE");
    if (shaderFailure && std::strcmp(shaderFailure,"1")==0)
        alphaSource="DORA_GODOT_INJECTED_INVALID_SHADER\n";
#endif
    auto bytecode=SharedShaderCompiler.compile(alphaSource,ShaderStage::Fragment,false,shaderError,"/__dora_godot__/resolve.sc",nullptr,R"VARYING(
vec4 v_color0 : COLOR0 = vec4(1.0, 1.0, 1.0, 1.0);
vec2 v_texcoord0 : TEXCOORD0 = vec2(0.0, 0.0);
vec4 a_position : POSITION;
vec2 a_texcoord0 : TEXCOORD0;
vec4 a_color0 : COLOR0;
)VARYING");
    if (bytecode.empty()) { Error("GodotNode: alpha shader compilation failed: {}",shaderError); return false; }
    auto fragment=bgfx::createShader(bgfx::copy(bytecode.data(),uint32_t(bytecode.size())));
    if (!bgfx::isValid(fragment)) { Error("GodotNode: alpha shader creation failed"); return false; }
    auto *vertex=SharedShaderCache.load("builtin:vs_sprite"_slice);
    if (!vertex) { bgfx::destroy(fragment); return false; }
    auto *effect=SpriteEffect::create(vertex,Shader::create(fragment));
    if (effect->getPasses().empty()) return false;
    setEffect(effect);
    setBlendFunc(BlendFunc{BlendFunc::One,BlendFunc::InvSrcAlpha,BlendFunc::One,BlendFunc::InvSrcAlpha});
    if (!_session || !_session->start(_project, _scene, _pixelWidth, _pixelHeight, _buffers)) return false;
    setSize({static_cast<float>(_pixelWidth), static_cast<float>(_pixelHeight)});
    setupInput(); scheduleUpdate();
    initialized=true;
    return true;
}
bool GodotNode::update(double deltaTime) {
    if (_session) _session->step();
    return Sprite::update(deltaTime);
}
void GodotNode::cleanup() {
    if (_session) { _session->close(); _session.reset(); }
    _running = false;
    Sprite::cleanup();
}
void GodotNode::pause() { _paused = true; if (_session) _session->pause(true); }
void GodotNode::resume() { _paused = false; if (_session) _session->pause(false); }
bool GodotNode::restart(String scene) {
    if (!_session || !_session->restart(scene.toString())) return false;
    if (!scene.empty()) _scene=scene.toString();
    return true;
}
bool GodotNode::resizeViewport(int width,int height) {
    if (!_session || width<1 || height<1 || width>8192 || height>8192) return false;
    return _session->resize(width,height);
}
static void godotInputModifiers(DoraGodotInput &event) {
    event.shift=SharedKeyboard.isKeyPressed("LShift"_slice) || SharedKeyboard.isKeyPressed("RShift"_slice);
    event.ctrl=SharedKeyboard.isKeyPressed("LCtrl"_slice) || SharedKeyboard.isKeyPressed("RCtrl"_slice);
    event.alt=SharedKeyboard.isKeyPressed("LAlt"_slice) || SharedKeyboard.isKeyPressed("RAlt"_slice);
    event.meta=SharedKeyboard.isKeyPressed("LGui"_slice) || SharedKeyboard.isKeyPressed("RGui"_slice);
}
void GodotNode::sendPointer(double x, double y, int button, bool pressed) {
    if (!_session || button < 1 || button > 9) return;
    DoraGodotInput event{}; event.size = sizeof(event); event.kind = DORA_GODOT_POINTER_BUTTON;
    godotInputModifiers(event); event.x=x; event.y=y; event.button=button; event.pressed=pressed; _session->input(event);
}
void GodotNode::sendPointerMove(double x, double y) {
    if (!_session) return;
    DoraGodotInput event{}; event.size=sizeof(event); event.kind=DORA_GODOT_POINTER_MOVE;
    godotInputModifiers(event); event.x=x; event.y=y; _session->input(event);
}
void GodotNode::sendKey(String name, bool pressed) {
    if (!_session) return;
    DoraGodotInput event{}; event.size=sizeof(event); event.kind=DORA_GODOT_KEY; event.pressed=pressed;
    godotInputModifiers(event); _session->input(event, name.toString());
}
void GodotNode::sendText(String text) {
    if (!_session) return;
    DoraGodotInput event{}; event.size=sizeof(event); event.kind=DORA_GODOT_TEXT; _session->input(event, text.toString());
}
static int godotMouseButton(Touch *touch) {
    if (!touch->isFromMouse()) return 1;
    switch (touch->getMouseButton()) {
        case 1: return 1;
        case 2: return 2;
        case 3: return 3;
        case 4: return 8;
        case 5: return 9;
        default: return 0;
    }
}
void GodotNode::setupInput() {
    auto focused=std::make_shared<bool>(true);
    auto modifiers=std::make_shared<unsigned>(0);
    gslot("AppEvent"_slice, [this,focused,modifiers](Event *event) {
        std::string name; if (!event->get(name)) return;
        const bool lost=name=="WindowFocusLost" || name=="WindowHidden" || name=="WillEnterBackground";
        const bool gained=name=="WindowFocusGained" || name=="DidEnterForeground";
        if ((!lost && !gained) || *focused==gained) return;
        *focused=gained;
        if (lost) *modifiers=0;
        if (_session) {
            DoraGodotInput input{}; input.size=sizeof(input); input.kind=DORA_GODOT_FOCUS;
            input.pressed=gained; _session->input(input);
        }
    });
    setTouchEnabled(true);
    setControllerEnabled(true);
    slot("TapBegan"_slice, [this](Event *event) {
        Touch *touch = nullptr;
        if (event->get(touch) && touch) {
            setKeyboardEnabled(true);
            const auto location = touch->getLocation();
            sendPointer(location.x, _pixelHeight-location.y, godotMouseButton(touch), true);
        }
    });
    slot("TapEnded"_slice, [this](Event *event) {
        Touch *touch = nullptr;
        if (event->get(touch) && touch) { const auto p=touch->getLocation(); sendPointer(p.x,_pixelHeight-p.y,godotMouseButton(touch),false); }
    });
    auto move = [this](Event *event) { Touch *touch=nullptr; if (event->get(touch) && touch) { const auto p=touch->getLocation(); sendPointerMove(p.x,_pixelHeight-p.y); } };
    slot("TapMoved"_slice, move); slot("MouseMove"_slice, move);
    auto keyInput=[this,focused,modifiers](Event *event, bool pressed) {
        Slice key; if (!*focused || !event->get(key)) return;
        DoraGodotInput state{}; godotInputModifiers(state);
        unsigned bit=0; const char *name=nullptr; bool held=false;
        if (key=="LShift"_slice || key=="RShift"_slice) { bit=1; name="Shift"; held=state.shift; }
        else if (key=="LCtrl"_slice || key=="RCtrl"_slice) { bit=2; name="Ctrl"; held=state.ctrl; }
        else if (key=="LAlt"_slice || key=="RAlt"_slice) { bit=4; name="Alt"; held=state.alt; }
        else if (key=="LGui"_slice || key=="RGui"_slice) { bit=8; name="Meta"; held=state.meta; }
        if (!bit) { sendKey(key,pressed); return; }
        // Godot has one key per modifier; releasing one side must preserve the other.
        if (((*modifiers & bit)!=0)==held) return;
        if (held) *modifiers|=bit; else *modifiers&=~bit;
        sendKey(name,held);
    };
    slot("KeyDown"_slice, [keyInput](Event *event) { keyInput(event,true); });
    slot("KeyUp"_slice, [keyInput](Event *event) { keyInput(event,false); });
    slot("TextInput"_slice, [this,focused](Event *event) { Slice text; if (*focused && event->get(text)) sendText(text); });
    auto controllerButton=[this,focused](Event *event,bool pressed) {
        int id=0;Slice name;if (!*focused || !event->get(id,name) || id<0) return;
        DoraGodotInput input{};input.size=sizeof(input);input.kind=DORA_GODOT_CONTROLLER_BUTTON;
        input.button=uint32_t(id);input.pressed=pressed;_session->input(input,name.toString());
    };
    slot("ButtonDown"_slice,[controllerButton](Event *event) { controllerButton(event,true); });
    slot("ButtonUp"_slice,[controllerButton](Event *event) { controllerButton(event,false); });
    slot("Axis"_slice,[this,focused](Event *event) {
        int id=0;Slice name;float value=0;if (!*focused || !event->get(id,name,value) || id<0) return;
        DoraGodotInput input{};input.size=sizeof(input);input.kind=DORA_GODOT_CONTROLLER_AXIS;
        input.button=uint32_t(id);input.x=std::clamp(double(value),-1.0,1.0);_session->input(input,name.toString());
    });
    slot("DetachIME"_slice, [this](Event *) { if (_session) _session->imeDetached(); });
}
void GodotSession::applyIME(const DoraGodotIMEState &state) {
    auto *target=node();if (!target) return;
    if (!state.active) {
        if (_imeAttached) target->detachIME();
        _imeAttached=false;return;
    }
    if (!_imeAttached) { target->attachIME(true);_imeAttached=true; }
    const Vec2 position{float(state.x),float(target->_pixelHeight-state.y)};
    target->convertToWindowSpace(position,[](const Vec2 &windowPosition) { SharedKeyboard.updateIMEPosHint(windowPosition); });
}
void GodotSession::releaseIME() {
    if (_imeAttached) {
        if (auto *target=node()) target->detachIME();
    }
    _imeAttached=false;
}
void GodotNode::shutdownRuntime() {
#if BX_PLATFORM_OSX || BX_PLATFORM_IOS
    shutdownGodotMetalRuntime();
#elif BX_PLATFORM_LINUX || BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID || (BX_PLATFORM_EMSCRIPTEN && !defined(DORA_WEB_NO_GODOT))
    shutdownGodotGLRuntime();
#endif
}
NS_DORA_END
