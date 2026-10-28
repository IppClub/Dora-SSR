#include "Tools/Godot/module/runtime_timing.h"
#include <cassert>
#include <cmath>
int main() {
    using namespace DoraGodotRenderTiming;
    assert(consume()==0.0);
    enqueue(0.06); assert(consume()==0.06);
    assert(consume()==0.0); // Redraw without a Main iteration cannot add time.
    enqueue(0.015); enqueue(0.12);
    assert(std::abs(consume()-0.135)<1e-12);
    enqueue(0.0); assert(consume()==0.0); // Frozen effective time scale.
    enqueue(0.06);reset();assert(consume()==0.0);
}
