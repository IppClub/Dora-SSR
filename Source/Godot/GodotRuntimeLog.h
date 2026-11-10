#pragma once
#include "GodotBridgeLog.h"
#include "Common/Debug.h"
#include <deque>
#include <string>

namespace Dora {
// Owner/render-thread bridge shared by Metal, GL, D3D12 and the Web thunks.
class GodotRuntimeLog {
    DoraGodotLogAPI _api{};
    std::deque<std::string> _errors;
public:
    template <class Resolve> void connect(Resolve resolve) {
        auto getter = reinterpret_cast<DoraGodotGetLogAPI>(resolve("dora_godot_get_log_api"));
        DoraGodotLogAPI api{}; api.size = sizeof(api);
        if (getter && getter(DORA_GODOT_LOG_ABI_VERSION, &api) && api.size >= sizeof(api)
            && api.abi_version == DORA_GODOT_LOG_ABI_VERSION && api.set_enabled && api.pop) connect(api);
    }
    void connect(DoraGodotLogAPI api) { _api = api; _api.set_enabled(1); }
    void beginProject() { pump(); _errors.clear(); }
    void pump() {
        if (!_api.pop) return; // Older libraries retain lastError behavior.
        for (int i = 0; i < 129; ++i) {
            uint32_t level = 0;
            const char *text = _api.pop(&level);
            if (!text) break;
            if (level == DORA_GODOT_LOG_WARNING) Warn("[Godot] {}", text);
            else {
                Error("[Godot] {}", text);
                if (_errors.size() == 128) _errors.pop_front();
                _errors.emplace_back(text);
            }
        }
    }
    // Return only unreported failure lines. Keep lastError itself unchanged.
    std::string failureText(const std::string &message) {
        pump();
        std::string remaining = message;
        for (const auto &text : _errors) {
            if (remaining == text) return {};
            if (remaining.size() > text.size() && remaining.compare(0, text.size(), text) == 0
                && remaining[text.size()] == '\n') remaining.erase(0, text.size() + 1);
        }
        return remaining;
    }
    void disconnect() { pump(); if (_api.set_enabled) _api.set_enabled(0); _api = {}; _errors.clear(); }
};
}
