#include "Source/Godot/GodotFrameRing.h"
#include <cassert>
#include <cstdio>
#include <type_traits>

int main() {
    static_assert(std::is_standard_layout_v<DoraGodotConfig>);
    static_assert(std::is_standard_layout_v<DoraGodotAPI>);
    static_assert(offsetof(DoraGodotAPI,abi_version)==4);
    static_assert(offsetof(DoraGodotConfig,backend)==4);
    for (unsigned count=2;count<=4;++count) {
        Dora::GodotFrameRing ring;
        assert(!ring.read(1)); assert(!ring.reserve());
        assert(!ring.configure(1)); assert(!ring.configure(5));
        assert(ring.configure(count)); assert(ring.seed(0,1)); assert(!ring.seed(0,2));
        uint64_t last[4]{}, sequence=1, random=0x1234567;
        unsigned current=0;
        for (uint64_t frame=1;frame<=100000;++frame) {
            auto read=ring.read(frame); assert(read && read->slot==current && read->sequence==sequence);
            last[current]=frame; assert(!ring.read(frame));
            auto reserved=ring.reserve(); assert(reserved && reserved->slot!=current && reserved->last_read==last[reserved->slot]);
            assert(!ring.reserve());
            // Additional consumer frames keep reading the displayed slot while
            // production is pending. The reserved slot's last reader stays fixed.
            random=random*1664525+1013904223;
            for (unsigned i=0;i<(random%4) && frame<100000;++i) {
                ++frame; auto duplicate=ring.read(frame);
                assert(duplicate && duplicate->slot==current && duplicate->sequence==sequence);
                last[current]=frame;
                assert(reserved->last_read==last[reserved->slot]);
            }
            auto stale=*reserved; ++stale.token;
            assert(!ring.publish(stale,sequence+1));
            assert(!ring.publish(*reserved,sequence));
            assert(ring.publish(*reserved,++sequence)); current=reserved->slot;
            assert(!ring.publish(*reserved,sequence+1));
        }
        auto postponed=ring.reserve(); assert(postponed);
        auto wrong=*postponed; ++wrong.token; assert(!ring.defer(wrong));
        assert(ring.defer(*postponed)); assert(!ring.publish(*postponed,sequence+1));
        auto pending=ring.reserve(); assert(pending); ring.close();
        assert(!ring.read(200001)); assert(!ring.publish(*pending,sequence+1));
        assert(ring.configure(count)); assert(ring.seed(0,1));
        auto fresh=ring.reserve(); assert(fresh && fresh->token!=pending->token);
        assert(!ring.publish(*pending,2)); assert(ring.publish(*fresh,2));
    }
    std::printf("Godot frame ownership protocol: PASS (2/3/4 buffers, 100000-frame schedules each)\n");
}
