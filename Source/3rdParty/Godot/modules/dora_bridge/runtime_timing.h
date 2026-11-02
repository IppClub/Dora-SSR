// Internal single-owner timing handoff from Main::iteration to manual drawing.
// No runtime API or GPU thread accesses this state. All quantities are the
// original scaled render step computed by Main, before physics catch-up caps.
#pragma once
namespace DoraGodotRenderTiming {
inline double pending_step=0.0;
inline void enqueue(double scaled_step) { pending_step+=scaled_step; }
inline double consume() { const double value=pending_step;pending_step=0.0;return value; }
inline void reset() { pending_step=0.0; }
}
