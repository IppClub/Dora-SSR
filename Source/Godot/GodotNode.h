// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include "Node/Sprite.h"
#include "Godot/GodotBridge.h"
#include "Godot/GodotBridgeIME.h"

NS_DORA_BEGIN
class GodotSession;
class GodotNode : public Sprite {
public:
    virtual ~GodotNode() override;
    virtual bool init() override;
    virtual bool update(double deltaTime) override;
    virtual void cleanup() override;
    String getProjectPath() const noexcept { return _project; }
    String getSceneFile() const noexcept { return _scene; }
    String getLastError() const noexcept { return _lastError; }
    bool isRunning() const noexcept { return _running; }
    bool isPaused() const noexcept { return _paused; }
    void pause();
    void resume();
    bool restart(String sceneFile = Slice::Empty);
    // Asynchronous native texture resize. False rejects unsupported/busy/invalid
    // requests. getViewportSize changes only after the new texture is published.
    bool resizeViewport(int width,int height);
    Size getViewportSize() const noexcept { return {float(_pixelWidth),float(_pixelHeight)}; }
    // Coordinates are output-window pixels, top-left origin. Godot applies its
    // native content-scale transform to obtain logical scene coordinates.
    void sendPointer(double x, double y, int button, bool pressed);
    void sendPointerMove(double x, double y);
    void sendKey(String name, bool pressed);
    void sendText(String text);
    static void shutdownRuntime(); // Application render thread, after bgfx drain.
    // Once a session is accepted, process exit must drain the runtime even if
    // its node has already been removed. Thread-safe; does not load the library.
    static bool requiresRuntimeShutdown() noexcept;
    // GPU/backend capability only; does not load or validate the runtime library.
    static std::string getUnsupportedReason();
    static GodotNode *create(String projectPath, String sceneFile = Slice::Empty, int width = 640, int height = 360, int buffers = 3);
    friend class Object;
protected:
    GodotNode(String projectPath, String sceneFile, int width, int height, int buffers = 3);
private:
    void setupInput();
    std::string _project, _scene, _lastError;
    int _pixelWidth, _pixelHeight, _buffers;
    bool _running = false, _paused = false;
    std::shared_ptr<GodotSession> _session;
    friend class GodotSession;
    DORA_TYPE_OVERRIDE(GodotNode);
};

// Platform backends retain their state across queued callbacks; the node itself
// is weakly referenced so removing a node while booting cannot resurrect it.
class GodotSession {
public:
    explicit GodotSession(GodotNode *node) : _node(node) {}
    virtual ~GodotSession() = default;
    virtual bool start(const std::string &project, const std::string &scene, int width, int height, int buffers) = 0;
    virtual void step() = 0;
    virtual void close() = 0;
    virtual void pause(bool value) = 0;
    virtual bool restart(const std::string &scene) = 0;
    virtual bool resize(int,int) { return false; }
    virtual void input(DoraGodotInput event, std::string text = {}) = 0;
    // Called when another Dora node takes the singleton text-input service.
    void imeDetached() noexcept { _imeAttached=false; }
protected:
    GodotNode *node() const { return _node.get(); }
    void resized(int width,int height) {
        if (auto *target=node()) {
            target->_pixelWidth=width; target->_pixelHeight=height;
            target->setTextureRect({0,0,float(width),float(height)});
            target->setSize({float(width),float(height)});
        }
    }
    void running(bool value) { if (auto *target = node()) target->_running = value; }
    void error(const std::string &message) {
        if (auto *target = node()) { target->_lastError = message; target->_running = false; }
    }
    bool acceptIMEState(const DoraGodotIMEState &state) {
        if (!state.revision || state.revision==_imeRevision) return false;
        _imeRevision=state.revision;return true;
    }
    void applyIME(const DoraGodotIMEState &state);
    void releaseIME();
private:
    WRef<GodotNode> _node;
    uint64_t _imeRevision=0;
    bool _imeAttached=false;
};
NS_DORA_END
