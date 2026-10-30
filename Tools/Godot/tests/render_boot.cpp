#include "Source/Godot/GodotRenderBootQueue.h"
#include <cassert>
#include <memory>
#include <vector>
int main() {
    Dora::GodotRenderBootQueue queue;
    std::vector<int> order;
    queue.schedule(12,[&]{order.push_back(1);queue.schedule(13,[&]{order.push_back(3);});});
    queue.schedule(12,[&]{order.push_back(2);});
    queue.drain(11);assert(order.empty());
    queue.drain(12);assert((order==std::vector<int>{1,2}));
    queue.drain(12);assert(order.size()==2);
    queue.drain(13);assert((order==std::vector<int>{1,2,3}));
    auto retained=std::make_shared<int>(4);std::weak_ptr<int> weak=retained;
    queue.schedule(100,[retained]{assert(*retained==4);});retained.reset();
    assert(!weak.expired());queue.clear();assert(weak.expired());queue.drain(100);
    queue.schedule(0,[&]{order.push_back(4);});queue.drain(UINT32_MAX);assert(order.size()==3);
    queue.drain(0);assert(order.back()==4);
}
