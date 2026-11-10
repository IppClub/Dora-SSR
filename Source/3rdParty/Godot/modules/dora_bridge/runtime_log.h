// Queue only from Godot callbacks: never call the host under Godot's print lock.
#pragma once
#include "GodotBridgeLog.h"
#include "runtime_diagnostics.h"
#include "core/string/print_string.h"
#include <deque>
#include <utility>

namespace DoraGodotLog {
inline std::mutex mutex;
inline std::deque<std::pair<uint32_t, std::string>> records;
inline uint64_t dropped = 0;
inline bool enabled = false;
inline void append(uint32_t level, std::string text) {
    if (DoraGodotDiagnostics::metadata_query) return;
    if (text.size() > 8192) {
        size_t end = 8192;
        while (end && (static_cast<unsigned char>(text[end]) & 0xc0) == 0x80) --end;
        text.resize(end);
    }
    std::lock_guard<std::mutex> lock(mutex);
    if (!enabled) return;
    if (records.size() == 128) { ++dropped; return; }
    records.emplace_back(level, std::move(text));
}
inline void error(void *, const char *function, const char *file, int line,
        const char *error, const char *message, bool, ErrorHandlerType type) {
    std::string text = std::string(file ? file : "") + ":" + std::to_string(line) + ": "
        + (message && *message ? message : error ? error : "Godot runtime error");
    if (function && *function) text += std::string(" [") + function + "]";
    append(type == ERR_HANDLER_WARNING ? DORA_GODOT_LOG_WARNING : DORA_GODOT_LOG_ERROR, std::move(text));
}
inline void print(void *, const String &text, bool error, bool) {
    if (error) append(DORA_GODOT_LOG_ERROR, text.utf8().get_data());
}
inline ErrorHandlerList error_handler{error, nullptr, nullptr};
inline PrintHandlerList print_handler{print, nullptr, nullptr};
inline void set_enabled(int value) {
    // Registration is serialized by Godot's own global handler lock. Do not
    // hold the queue lock while adding/removing a handler (workers may print).
    if (enabled) {
        remove_error_handler(&error_handler);
        remove_print_handler(&print_handler);
    }
    {
        std::lock_guard<std::mutex> lock(mutex);
        enabled = value != 0;
        records.clear(); dropped = 0;
    }
    if (value) { add_error_handler(&error_handler); add_print_handler(&print_handler); }
}
inline const char *pop(uint32_t *level) {
    if (!level) return nullptr;
    thread_local std::string snapshot;
    std::lock_guard<std::mutex> lock(mutex);
    if (!records.empty()) {
        *level = records.front().first;
        snapshot = std::move(records.front().second);
        records.pop_front();
    } else if (dropped) {
        *level = DORA_GODOT_LOG_WARNING;
        snapshot = "Godot log queue overflow: dropped " + std::to_string(dropped) + " records";
        dropped = 0;
    } else return nullptr;
    return snapshot.c_str();
}
}
extern "C" DORA_GODOT_EXPORT int dora_godot_get_log_api(uint32_t abi, DoraGodotLogAPI *api) {
    if (abi != DORA_GODOT_LOG_ABI_VERSION || !api || api->size < sizeof(*api)) return 0;
    *api = {sizeof(*api), DORA_GODOT_LOG_ABI_VERSION, DoraGodotLog::set_enabled, DoraGodotLog::pop};
    return 1;
}
