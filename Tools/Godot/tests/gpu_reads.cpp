#include "Source/Godot/GodotGpuReads.h"
#include <cassert>
#include <cstdio>

int main() {
    for (uint32_t buffers=2;buffers<=4;++buffers) {
        Dora::GodotGpuReads reads;
        assert(!reads.configure(1)); assert(reads.configure(buffers));
        assert(!reads.produced(buffers,1)); assert(!reads.produced(0,0));
        assert(reads.produced(0,1));
        uint64_t sequence=1,waits=0;
        for (uint64_t frame=1;frame<=100000;++frame) {
            // Some host frames have only aliases, with no node update or new
            // production. They must still advance the last-reader protection.
            assert(reads.begin(frame)); assert(!reads.canProduce());
            assert(!reads.begin(frame+1)); assert(!reads.end(frame+1));
            assert(!reads.produced(0,sequence+1)); assert(!reads.replaceSlots());
            for (uint32_t slot=0;slot<buffers;++slot) if (reads.sequence(slot)) ++waits;
            assert(reads.end(frame)); assert(!reads.end(frame));
            assert(reads.canProduce() && reads.lastRead()==frame);
            assert(!reads.begin(frame));
            if (frame%3==0) {
                const auto slot=uint32_t(frame/3)%buffers;
                assert(reads.produced(slot,++sequence));
                assert(reads.lastSlot()==slot && reads.sequence(slot)==sequence);
                assert(!reads.produced(slot,sequence));
            }
        }
        assert(reads.replaceSlots());
        assert(reads.lastRead()==0);
        assert(!reads.begin(100000));
        for (uint32_t i=0;i<buffers;++i) assert(reads.sequence(i)==0);
        assert(!reads.produced(0,sequence));
        assert(reads.produced(0,++sequence));
        assert(!reads.pending() && reads.frames()==100000);
        assert(reads.signals()==100000*buffers && reads.waits()==waits);
    }
    puts("Godot GPU reader ledger: PASS (2/3/4 slots, 300000 alias-inclusive host frames; GPU not tested)");
}
