// Preserve the first project runtime error without retaining Godot objects.
#pragma once
#include "core/error/error_macros.h"
#include <mutex>
#include <string>

namespace DoraGodotDiagnostics {
inline std::mutex mutex;
inline std::string first_error;
inline bool installed = false;
// Metadata/service errors on the owner thread are not game runtime failures.
// Worker-thread game errors remain visible while a metadata query is running.
inline thread_local bool metadata_query = false;
struct ScopedMetadataQuery {
    bool previous;
    ScopedMetadataQuery() : previous(metadata_query) { metadata_query = true; }
    ~ScopedMetadataQuery() { metadata_query = previous; }
    ScopedMetadataQuery(const ScopedMetadataQuery &) = delete;
    ScopedMetadataQuery &operator=(const ScopedMetadataQuery &) = delete;
};
inline void capture(void *, const char *function, const char *file, int line,
        const char *error, const char *message, bool, ErrorHandlerType type) {
    if (metadata_query || type == ERR_HANDLER_WARNING) return;
    std::lock_guard<std::mutex> lock(mutex);
    if (!first_error.empty()) return;
    first_error = std::string(file ? file : "") + ":" + std::to_string(line) + ": "
        + (message && *message ? message : error ? error : "Godot runtime error");
    if (function && *function) first_error += std::string(" [") + function + "]";
    if (first_error.size() > 8192) first_error.resize(8192);
}
inline ErrorHandlerList handler{capture, nullptr, nullptr};
inline void end() {
    if (installed) { remove_error_handler(&handler); installed = false; }
}
inline void begin() {
    end();
    { std::lock_guard<std::mutex> lock(mutex); first_error.clear(); }
    add_error_handler(&handler); installed = true;
}
inline const char *get(const std::string &fallback = {}) {
    // Readers copy the returned text before the next owner-thread API call.
    thread_local std::string snapshot;
    std::lock_guard<std::mutex> lock(mutex);
    snapshot = first_error;
    if (!fallback.empty()) {
        if (!snapshot.empty()) snapshot += '\n';
        snapshot += fallback;
    }
    return snapshot.c_str();
}
}
