#include "Dora.h"
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <chrono>
#include <thread>
#include <unordered_set>
#include <fstream>
#include <SDL.h>
#include "Input/Controller.h"
#if BX_PLATFORM_OSX || BX_PLATFORM_IOS
// Keep only acceptance entrypoints inspectable when Release hides symbols.
#define DORA_GODOT_TEST_EXPORT __attribute__((visibility("default")))
#else
#define DORA_GODOT_TEST_EXPORT DORA_EXPORT
#endif
#if BX_PLATFORM_ANDROID
#include "Godot/GodotAndroidPlatform.h"
#include <android/log.h>
#include <cstdarg>
static int androidGodotTestPrint(FILE *,const char *format,...) {
    char buffer[8192];va_list args;va_start(args,format);
    const int count=std::vsnprintf(buffer,sizeof(buffer),format,args);va_end(args);
    __android_log_write(ANDROID_LOG_INFO,"DoraGodotTest",buffer);return count;
}
#define fprintf androidGodotTestPrint
#endif
#if BX_PLATFORM_WINDOWS
#include "Other/utf8.h"
#include <windows.h>
#endif

namespace {
Dora::GodotNode *godot=nullptr;
std::string output, project, bindingPath;
int result=0, captures=0;
bool second=false;
bool capturePending=false;
bool testAliases=false;
bool testResize=false;
bool testIME=false;
bool testController=false;
int testBuffers=3;
std::vector<Dora::Sprite*> aliases;
const char *bindingWasm=nullptr;
void stopGodotTest() {
    // The opt-in acceptance entry owns the SDL loop. Application.shutdown()
    // deliberately only notifies development-mode apps and does not close
    // mobile apps, so it is not a reliable test termination mechanism.
    SDL_Event quit{};quit.type=SDL_QUIT;
    if (SDL_PushEvent(&quit)!=1) result=2;
}
using NativeBindingCreate = int (*)();
NativeBindingCreate nativeBindingCreate=nullptr;
std::string environmentUtf8(const char *name) {
#if BX_PLATFORM_WINDOWS
    const auto utf16=CodeCvt::utf8to16(name);
    const std::wstring nativeName(utf16.begin(),utf16.end());
    const DWORD length=GetEnvironmentVariableW(nativeName.c_str(),nullptr,0);
    if (!length) return {};
    std::wstring value(length,L'\0');
    const DWORD copied=GetEnvironmentVariableW(nativeName.c_str(),value.data(),length);
    if (!copied || copied>=length) return {};
    return CodeCvt::utf16to8(std::u16string(value.begin(),value.begin()+copied));
#elif BX_PLATFORM_ANDROID
    const auto value=Dora::godotAndroidIntentOption(name);
    if (!value.empty()) return value;
    const auto *fallback=std::getenv(name);
    return fallback?fallback:"";
#else
    const auto *value=std::getenv(name);
    return value?value:"";
#endif
}
bool bindingCommand(const std::string &command) {
    if (!bindingWasm && !nativeBindingCreate) return false;
    Dora::Event::send("GodotBindingTest"_slice,command);
    return true;
}
void capture(const std::string &name) {
    capturePending=true;
    if (!SharedDirector.captureGameAsync(output+"/"+name, [name](bool ok,double,Dora::Size) {
        capturePending=false;
        fprintf(stderr,"GODOT_NODE_CAPTURE %s success=%d\n",name.c_str(),ok);
        if (ok) ++captures; else result=2;
    })) {
        capturePending=false; result=2;
        fprintf(stderr,"GODOT_NODE_CAPTURE %s rejected=1\n",name.c_str());
    }
}
bool createNode() {
    if (nativeBindingCreate) {
        if (!nativeBindingCreate()) return false;
        godot=dynamic_cast<Dora::GodotNode*>(SharedDirector.getUI()->getChildByTag("GodotBindingNode"_slice));
        return godot!=nullptr;
    }
    if (bindingWasm) {
        if (!SharedWasmRuntime.executeMainFile(bindingWasm)) return false;
        godot=dynamic_cast<Dora::GodotNode*>(SharedDirector.getUI()->getChildByTag("GodotBindingNode"_slice));
        return godot!=nullptr;
    }
    lua_State *state=SharedLuaEngine.getState();
    lua_pushglobaltable(state); lua_pushliteral(state,"__DORA_GODOT_PROJECT");
    lua_pushlstring(state,project.data(),project.size()); lua_rawset(state,-3); lua_pop(state,1);
    lua_pushglobaltable(state); lua_pushliteral(state,"__DORA_GODOT_TEST_BUFFERS");
    lua_pushinteger(state,testBuffers); lua_rawset(state,-3); lua_pop(state,1);
    if (luaL_loadstring(state,R"(
        local node = Dora.GodotNode(__DORA_GODOT_PROJECT, "res://main.tscn", 640, 360, __DORA_GODOT_TEST_BUFFERS)
        assert(node, "GodotNode Lua constructor failed")
        node:pause()
        node.scaleX, node.scaleY = 1.25, 1.25
        Dora.Director.ui:addChild(node)
        rawset(_G, "__DORA_GODOT_TEST_NODE", node)
    )") != LUA_OK || !Dora::LuaEngine::call(state,0,0)) return false;
    lua_getglobal(state,"__DORA_GODOT_TEST_NODE");
    godot=static_cast<Dora::GodotNode*>(Dora::tolua_tousertype(state,-1,nullptr));
    lua_pop(state,1);
    if (!godot) return false;
    return true;
}
void reservationProbe(int stage) {
    auto *extra=Dora::GodotNode::create(project,"res://main.tscn",640,360,testBuffers);
    const bool rejected=extra==nullptr;
    fprintf(stderr,"GODOT_NODE_RESERVATION stage=%d rejected=%d\n",stage,rejected);
    if (!rejected) {
        extra->cleanup(); result=2;
    }
}
void addAlias() {
    if (!testAliases || !godot || !godot->isRunning() || aliases.size()>=size_t(testBuffers)) return;
    auto *texture=godot->getTexture();
    if (!texture) return;
    for (auto *alias:aliases) if (alias->getTexture()==texture) return;
    auto *alias=Dora::Sprite::create(texture);
    alias->setEffect(godot->getEffect()); alias->setBlendFunc(godot->getBlendFunc());
    // Leave room for the large viewport's corner markers even in a 1280px
    // window with four aliases; no overlay may cover a barcode sample.
    const float scale=testResize && testBuffers==4 ? 0.20f : 0.25f;
    const float margin=testResize && testBuffers==4 ? 70.0f : 120.0f;
    alias->setScaleX(scale); alias->setScaleY(scale);
    const auto host=SharedApplication.getBufferSize();
    const bool portrait=host.height>host.width;
    // Portrait output has ample space above the main viewport; a side column
    // would overlap the large resized viewport and obscure alias barcodes.
    const float x=portrait?(float(aliases.size())-(testBuffers-1)*0.5f)*180.0f:-host.width*0.5f+margin;
    const float y=portrait?host.height*0.5f-150.0f:(float(aliases.size())-(testBuffers-1)*0.5f)*160.0f;
    alias->setPosition({x,y}); SharedDirector.getUI()->addChild(alias);
    fprintf(stderr,"GODOT_NODE_ALIAS index=%d x=%.0f y=%.0f scale=%.2f handle=%u\n",int(aliases.size()),x,y,scale,texture->getHandle().idx);
    aliases.push_back(alias);
}
#include "GodotTimingTest.inc"
#include "GodotOutputTest.inc"
#include "GodotCycleTest.inc"
}
// Test-only reverse P/Invoke factory; no runtime ABI change.
extern "C" DORA_GODOT_TEST_EXPORT void dora_godot_binding_set_create(NativeBindingCreate create) {
    nativeBindingCreate=create;
}
extern "C" DORA_GODOT_TEST_EXPORT int dora_godot_node_test_main() {
#if BX_PLATFORM_ANDROID
    // Mirror the opt-in test intent into libc so the host controller and the
    // real project's OS.get_environment() observe the same test configuration.
    const char *options[]={"DORA_GODOT_TEST_PROJECT","DORA_GODOT_TEST_OUTPUT","DORA_GODOT_TEST_AUDIO",
        "DORA_GODOT_TEST_RESIZE","DORA_GODOT_TEST_ALIASES","DORA_GODOT_TEST_AUDIO_STALL",
        "DORA_GODOT_TEST_RESERVATION","DORA_GODOT_TEST_CANCEL_RESIZE","DORA_GODOT_TEST_TIMING",
        "DORA_GODOT_TEST_OUTPUT_CHANGE","DORA_GODOT_TEST_OUTPUT_STARTUP","DORA_GODOT_TEST_BUFFERS",
        "DORA_GODOT_TEST_IME","DORA_GODOT_TEST_CONTROLLER"};
    for (const char *name:options) {
        const auto value=Dora::godotAndroidIntentOption(name);
        if (!value.empty()) setenv(name,value.c_str(),1);
    }
#endif
    project=environmentUtf8("DORA_GODOT_TEST_PROJECT");
    output=environmentUtf8("DORA_GODOT_TEST_OUTPUT");
    if (project.empty() || output.empty()) { result=2; stopGodotTest(); return 1; }
    if (environmentUtf8("DORA_GODOT_TEST_DORA_ONLY")=="1") {
        SharedDirector.beginGameCapture();
        auto *draw=Dora::DrawNode::create();
        draw->drawDot({0,0},50,Dora::Color(0xff00ff00));
        SharedDirector.getUI()->addChild(draw);
        draw->schedule([draw,tick=0](double) mutable {
            if (capturePending) return false;
            ++tick;
            draw->setPosition({tick<90?-120.0f:120.0f,0});
            if (tick==60) capture("dora-left.png");
            if (tick==150) capture("dora-right.png");
            if (tick>=180 && !capturePending) {
                if (captures!=2) result=2;
                fprintf(stderr,"DORA_ONLY_TEST frames=%d captures=%d result=%d\n",tick,captures,result);
                stopGodotTest(); return true;
            }
            return false;
        });
        return 1;
    }
    {
        auto *state=SharedLuaEngine.getState();
        if (luaL_loadstring(state,"return Dora.GodotNode.getUnsupportedReason()")!=LUA_OK || !Dora::LuaEngine::call(state,0,1)) {
            result=2; stopGodotTest(); return 1;
        }
        const char *reason=lua_tostring(state,-1);
        const bool matches=reason && Dora::GodotNode::getUnsupportedReason()==reason;
        fprintf(stderr,"GODOT_CAPABILITY_QUERY matches=%d reason=%s\n",int(matches),reason?reason:"<invalid>");
        lua_pop(state,1);
        if (!matches) { result=2; stopGodotTest(); return 1; }
    }
    bindingPath=environmentUtf8("DORA_GODOT_BINDING_WASM");
    bindingWasm=bindingPath.empty()?nullptr:bindingPath.c_str();
    if (environmentUtf8("DORA_GODOT_TEST_TIMING")=="1") return startTimingTest();
    if (environmentUtf8("DORA_GODOT_TEST_OUTPUT_CHANGE")=="1") return startOutputTest();
    testResize=environmentUtf8("DORA_GODOT_TEST_RESIZE")=="1";
    testAliases=environmentUtf8("DORA_GODOT_TEST_ALIASES")=="1";
    testIME=environmentUtf8("DORA_GODOT_TEST_IME")=="1";
    testController=environmentUtf8("DORA_GODOT_TEST_CONTROLLER")=="1";
    const auto buffers=environmentUtf8("DORA_GODOT_TEST_BUFFERS");
    if (!buffers.empty()) {
        if (buffers!="2" && buffers!="3" && buffers!="4") { result=2; stopGodotTest(); return 1; }
        testBuffers=buffers[0]-'0';
    }
    if ((bindingWasm || nativeBindingCreate) && testBuffers!=3) { result=2; stopGodotTest(); return 1; }
    const auto cycles=environmentUtf8("DORA_GODOT_TEST_CYCLES");
    if (!cycles.empty()) {
        int count=0;
        try {count=std::stoi(cycles);} catch (...) {result=2;stopGodotTest();return 1;}
        if (count<2 || count>1000 || bindingWasm || nativeBindingCreate) {result=2;stopGodotTest();return 1;}
        return startCycleTest(count);
    }
    int soakFrames=0;
    const auto soak=environmentUtf8("DORA_GODOT_TEST_SOAK_FRAMES");
    if (!soak.empty()) {
        try { soakFrames=std::stoi(soak); } catch (...) { result=2; stopGodotTest(); return 1; }
        if (soakFrames<0 || soakFrames>216000 || soakFrames%300) { result=2; stopGodotTest(); return 1; }
    }
    if (testResize && soakFrames) { result=2; stopGodotTest(); return 1; }
    const auto buffer=SharedApplication.getBufferSize();
    fprintf(stderr,"GODOT_NODE_VIEW buffer=%dx%d scale=1.25\n",int(buffer.width),int(buffer.height));
    std::filesystem::create_directories(std::filesystem::u8path(output));
    SharedDirector.setClearColor(Dora::Color(0xff192331));
    SharedDirector.beginGameCapture();
    const auto initFailureMode=environmentUtf8("DORA_GODOT_TEST_INIT_FAILURE_MODE");
    if (!initFailureMode.empty()) {
        fprintf(stderr,"GODOT_INIT_FAILURE begin=1\n");
        const bool rejected=!createNode();
        fprintf(stderr,"GODOT_INIT_FAILURE rejected=%d\n",int(rejected));
        if (!rejected || (initFailureMode!="exit" && initFailureMode!="recover")) {
            result=2; stopGodotTest(); return 1;
        }
        if (initFailureMode=="exit") { stopGodotTest(); return 1; }
#if BX_PLATFORM_WINDOWS
        _putenv_s("DORA_GODOT_TEST_SHADER_FAILURE","");
#else
        unsetenv("DORA_GODOT_TEST_SHADER_FAILURE");
#endif
        // Queue this behind the expected asynchronous compiler/Lua errors so
        // the recovery verifier can keep its normal strict error checks.
        Dora::LogInfoThreaded("GODOT_INIT_FAILURE recovery_begin=1");
    }
    if (!createNode()) { result=2; stopGodotTest(); return 1; }
    if (environmentUtf8("DORA_GODOT_TEST_RESERVATION")=="1") reservationProbe(0);
    auto controller=Dora::Node::create(); SharedDirector.getUI()->addChild(controller);
    auto tick=std::make_shared<int>(0);
    auto elapsed=std::make_shared<int>(0);
    controller->schedule([tick,elapsed,soakFrames](double) {
        // Keep the current scene/pause/size state until its GPU readback and
        // PNG callback finish. Slow hosts must not skip or mislabel captures.
        if (capturePending) return false;
#if BX_PLATFORM_ANDROID
        // Keep the Godot scene/render/audio running while the external IME
        // probe types. Advancing into the focus-loss/restart cases mid-command
        // would intentionally discard part of adb's injected text.
        if (testIME && *tick==295) {
            static auto started=std::chrono::steady_clock::now();
            std::error_code error;
            if (!std::filesystem::exists(std::filesystem::path(output)/"ime-accepted",error)) {
                if (error || std::chrono::steady_clock::now()-started>std::chrono::seconds(30)) {
                    fprintf(stderr,"GODOT_NODE_IME_ACK timeout=1\n");result=2;stopGodotTest();return true;
                }
                return false;
            }
        }
#endif
        ++*tick; ++*elapsed;
        if ((*tick==115 || *tick==575) && environmentUtf8("DORA_GODOT_TEST_RESERVATION")=="1") {
            std::unordered_set<Dora::GodotNode*> nodes;
            Dora::Node *roots[]={SharedDirector.getEntry(),SharedDirector.getUI()};
            for (auto *root:roots) root->traverseAll([&](Dora::Node *node) {
                if (auto *embedded=dynamic_cast<Dora::GodotNode*>(node)) nodes.insert(embedded);
                return false;
            });
            if (nodes.size()!=1) result=2;
            fprintf(stderr,"GODOT_NODE_RESERVATION_TREE stage=%d nodes=%zu\n",*tick,nodes.size());
        }
        if ((*tick==100 || *tick==110 || *tick==560 || *tick==570) && environmentUtf8("DORA_GODOT_TEST_RESERVATION")=="1") reservationProbe(*tick);
        if ((*tick==320 || *tick==610) && environmentUtf8("DORA_GODOT_TEST_AUDIO_STALL")=="1") {
            SharedApplication.invokeInRender([] {
                Info("GodotAudio test render stall: 250 ms");
                std::this_thread::sleep_for(std::chrono::milliseconds(250));
            });
        }
        if (*tick>=90 && *tick<120) addAlias();
        if (godot && !godot->getLastError().empty()) { fprintf(stderr,"GODOT_NODE_TEST FAIL %s\n",godot->getLastError().toString().c_str()); result=2; stopGodotTest(); return true; }
        if (*tick==650 && *elapsed<650+soakFrames) {
            --*tick;
            if (*elapsed%300==0) capture("soak-"+std::to_string(*elapsed)+".png");
            return false;
        }
        if ((*tick==30 || *tick==530) && godot) {
            if (!bindingCommand("probe")) { godot->sendKey("F9",true); godot->sendKey("F9",false); }
        }
        if ((*tick==60 || *tick==540) && godot && !bindingCommand("resume")) godot->resume();
        if (testIME && (*tick==75 || *tick==470 || *tick==550)) {
            const bool attached=SharedKeyboard.isIMEAttached();
            const bool expected=*tick!=470;
            const char *stage=*tick==75?"first":*tick==470?"removed":"second";
            fprintf(stderr,"GODOT_NODE_HOST_IME stage=%s active=%d\n",stage,attached);
            if (attached!=expected) result=2;
        }
        if ((*tick==90 || *tick==570) && godot) bindingCommand("verify");
        if (*tick==120) capture("animated-a.png");
        if (*tick==150) capture("animated-b.png");
        if (*tick==180 && godot && !bindingCommand("pause")) godot->pause();
        if (*tick==210) capture("paused-a.png");
        if (*tick==240) capture("paused-b.png");
        if (*tick==270 && godot && !bindingCommand("input")) {
            godot->resume();
            godot->sendPointer(240,310,1,true); godot->sendPointer(240,310,1,false);
            godot->sendText("Dora"); godot->sendKey("Space",true); godot->sendKey("Space",false);
        }
        if (*tick==275 && testController) {
            Dora::EventArgs<int,Slice> down("ButtonDown"_slice,7,"a"_slice);SharedController.handler(&down);
            Dora::EventArgs<int,Slice,float> axis("Axis"_slice,7,"leftx"_slice,0.75f);SharedController.handler(&axis);
            Dora::EventArgs<int,Slice,float> neutral("Axis"_slice,7,"leftx"_slice,0.0f);SharedController.handler(&neutral);
            Dora::EventArgs<int,Slice> up("ButtonUp"_slice,7,"a"_slice);SharedController.handler(&up);
        }
        if (*tick==285 && godot) {
            Dora::Event::send("AppEvent"_slice,std::string("WindowFocusGained"));
            if (!bindingCommand("held")) { godot->sendKey("F8",true); godot->sendPointer(20,20,1,true); }
            if (testController) {
                Dora::EventArgs<int,Slice> down("ButtonDown"_slice,7,"a"_slice);SharedController.handler(&down);
                Dora::EventArgs<int,Slice,float> axis("Axis"_slice,7,"leftx"_slice,0.5f);SharedController.handler(&axis);
            }
            Dora::Event::send("AppEvent"_slice,std::string("WindowFocusLost"));
        }
        if (*tick==290) Dora::Event::send("AppEvent"_slice,std::string("WindowFocusGained"));
#if BX_PLATFORM_ANDROID
        if (*tick==295 && testIME && godot) {
            godot->sendPointer(240,310,1,true);godot->sendPointer(240,310,1,false);
            fprintf(stderr,"GODOT_NODE_IME_READY stage=stable-window\n");
        }
#endif
        if (*tick==300) capture("input.png");
        if (*tick==330 && godot && !bindingCommand("restart")) { if (!godot->restart()) result=2; }
        if (*tick==390) capture("restarted.png");
        if (*tick==450 && godot) {
            if (testResize && environmentUtf8("DORA_GODOT_TEST_CANCEL_RESIZE")=="1") {
                const bool accepted=bindingCommand("resize_cancel") || godot->resizeViewport(1024,576);
                if (!accepted) result=2;
                fprintf(stderr,"GODOT_NODE_RESIZE_CANCEL accepted=%d\n",accepted);
            }
            if (auto *control=SharedDirector.getUI()->getChildByTag("GodotBindingControl"_slice)) control->removeFromParent();
            godot->removeFromParent(); godot=nullptr;
        }
        if (*tick==510) { second=createNode(); if (!second) result=2; }
        if (*tick==480 && testAliases) capture("aliases-after-remove.png");
        if (*tick==600) capture("recreated.png");
        if (*tick==620 && godot) godot->setOpacity(0.5f);
        if (*tick==630) capture("opacity.png");
        if (*tick==640 && godot) godot->setOpacity(1.0f);
        if (testResize && godot) {
            auto callResize=[&](int width,int height) {
                auto *state=SharedLuaEngine.getState();
                const auto code="return __DORA_GODOT_TEST_NODE:resizeViewport("+std::to_string(width)+","+std::to_string(height)+")";
                if (luaL_loadstring(state,code.c_str())!=LUA_OK || !Dora::LuaEngine::call(state,0,1)) { result=2; return false; }
                const bool accepted=lua_toboolean(state,-1); lua_pop(state,1); return accepted;
            };
            auto request=[&](const char *command,int width,int height) {
                if (bindingCommand(command)) return;
                if (!callResize(width,height)) result=2;
                // A second request must not overwrite an in-flight generation.
                if (callResize(width+1,height)) result=2;
            };
            auto verify=[&](const char *command,int width,int height) {
                const auto size=godot->getViewportSize();
                if (size.width!=width || size.height!=height || !godot->getTexture()
                    || godot->getTexture()->getWidth()!=width || godot->getTexture()->getHeight()!=height) result=2;
                if (!bindingCommand(command)) {
                    if (!callResize(width,height)) result=2; // Same-size no-op.
                    auto *state=SharedLuaEngine.getState();
                    const auto code="local s=__DORA_GODOT_TEST_NODE.viewportSize; assert(s.width=="+std::to_string(width)+" and s.height=="+std::to_string(height)+")";
                    if (luaL_loadstring(state,code.c_str())!=LUA_OK || !Dora::LuaEngine::call(state,0,0)) result=2;
                }
                godot->sendKey("F10",true); godot->sendKey("F10",false);
                fprintf(stderr,"GODOT_NODE_RESIZE width=%d height=%d result=%d\n",width,height,result);
            };
            if (*tick==650) request("resize_large",800,450);
            if (*tick==680) verify("verify_large",800,450);
            if (*tick==690) capture("resized-large-a.png");
            if (*tick==710) capture("resized-large-b.png");
            if (*tick==720) { if (!bindingCommand("resize_pause")) godot->pause(); request("resize_small",320,180); }
            if (*tick==750) { verify("verify_small",320,180); capture("resized-small-a.png"); }
            if (*tick==780) capture("resized-small-b.png");
            if (*tick==790 && !bindingCommand("resize_resume")) godot->resume();
            if (*tick==820) capture("resized-small-motion.png");
            if (*tick==830) request("resize_restore",640,360);
            if (*tick==860) verify("verify_restore",640,360);
            if (*tick==880) capture("resized-restored.png");
            if (*tick==920 && !bindingCommand("resize_invalid")) {
                if (callResize(0,180) || callResize(-1,360)
                    || callResize(640,8193) || !godot->isRunning()) result=2;
            }
        }
        if (*tick==(testResize?1000:720)) {
            if (!second || !godot || !godot->isRunning() || captures!=(testAliases?9:8)+soakFrames/300+(testResize?6:0) || (testAliases && aliases.size()!=size_t(testBuffers))) result=2;
            fprintf(stderr,"GODOT_NODE_TEST frames=%d captures=%d recreated=%d result=%d\n",*elapsed,captures,second,result);
            if (soakFrames) fprintf(stderr,"GODOT_NODE_SOAK frames=%d samples=%d\n",soakFrames,soakFrames/300);
            stopGodotTest(); return true;
        }
        return false;
    });
    return 1;
}
extern "C" DORA_GODOT_TEST_EXPORT int dora_godot_node_test_finish() {
#if BX_PLATFORM_ANDROID || BX_PLATFORM_IOS
    if (!output.empty()) {
        const auto temporary=output+"/native-finish.json.tmp";
        { std::ofstream finish(temporary);finish<<"{\"result\":"<<result<<",\"captures\":"<<captures<<"}\n"; }
        std::filesystem::rename(temporary,output+"/native-finish.json");
    }
#endif
    return result;
}
