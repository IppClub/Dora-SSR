#pragma once
#include <cstdint>
#include <functional>
#include <utility>
#include <vector>
namespace Dora {
// Render-thread queue. A job may import native textures only after bgfx has
// executed the resource commands belonging to the allocation's API frame.
class GodotRenderBootQueue {
public:
    void schedule(uint32_t frame,std::function<void()> job) { _jobs.emplace_back(frame,std::move(job)); }
    void drain(uint32_t frame) {
        std::vector<std::function<void()>> ready;
        for (auto it=_jobs.begin();it!=_jobs.end();) {
            if (int32_t(frame-it->first)>=0) { ready.push_back(std::move(it->second)); it=_jobs.erase(it); }
            else ++it;
        }
        // Jobs can enqueue other jobs without invalidating the traversal.
        for (auto &job:ready) job();
    }
    void clear() { _jobs.clear(); }
private:
    std::vector<std::pair<uint32_t,std::function<void()>>> _jobs;
};
}
