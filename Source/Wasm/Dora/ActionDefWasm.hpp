/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT void actiondef_release(int64_t raw) {
	delete r_cast<ActionDef*>(raw);
}
DORA_EXPORT int64_t actiondef_prop(float duration, float start, float stop, int32_t prop, int32_t easing) {
	return r_cast<int64_t>(new ActionDef{ActionDef_Prop(duration, start, stop, s_cast<Property::Enum>(prop), s_cast<Ease::Enum>(easing))});
}
DORA_EXPORT int64_t actiondef_tint(float duration, int32_t start, int32_t stop, int32_t easing) {
	return r_cast<int64_t>(new ActionDef{ActionDef_Tint(duration, Color3(s_cast<uint32_t>(start)), Color3(s_cast<uint32_t>(stop)), s_cast<Ease::Enum>(easing))});
}
DORA_EXPORT int64_t actiondef_roll(float duration, float start, float stop, int32_t easing) {
	return r_cast<int64_t>(new ActionDef{ActionDef_Roll(duration, start, stop, s_cast<Ease::Enum>(easing))});
}
DORA_EXPORT int64_t actiondef_spawn(int64_t defs) {
	return r_cast<int64_t>(new ActionDef{ActionDef_Spawn(Vec_FromActionDef(defs))});
}
DORA_EXPORT int64_t actiondef_sequence(int64_t defs) {
	return r_cast<int64_t>(new ActionDef{ActionDef_Sequence(Vec_FromActionDef(defs))});
}
DORA_EXPORT int64_t actiondef_delay(float duration) {
	return r_cast<int64_t>(new ActionDef{ActionDef_Delay(duration)});
}
DORA_EXPORT int64_t actiondef_show() {
	return r_cast<int64_t>(new ActionDef{ActionDef_Show()});
}
DORA_EXPORT int64_t actiondef_hide() {
	return r_cast<int64_t>(new ActionDef{ActionDef_Hide()});
}
DORA_EXPORT int64_t actiondef_event(int64_t event_name, int64_t msg) {
	return r_cast<int64_t>(new ActionDef{ActionDef_Emit(*Str_From(event_name), *Str_From(msg))});
}
DORA_EXPORT int64_t actiondef_move_to(float duration, int64_t start, int64_t stop, int32_t easing) {
	return r_cast<int64_t>(new ActionDef{ActionDef_Move(duration, Vec2_From(start), Vec2_From(stop), s_cast<Ease::Enum>(easing))});
}
DORA_EXPORT int64_t actiondef_scale(float duration, float start, float stop, int32_t easing) {
	return r_cast<int64_t>(new ActionDef{ActionDef_Scale(duration, start, stop, s_cast<Ease::Enum>(easing))});
}
DORA_EXPORT int64_t actiondef_frame(int64_t clip_str, float duration) {
	return r_cast<int64_t>(new ActionDef{ActionDef_Frame(*Str_From(clip_str), duration)});
}
DORA_EXPORT int64_t actiondef_frame_with_frames(int64_t clip_str, float duration, int64_t frames) {
	return r_cast<int64_t>(new ActionDef{ActionDef_Frame(*Str_From(clip_str), duration, Vec_FromUint32(frames))});
}
} // extern "C"

static void linkActionDef(wasm3::module3& mod) {
	mod.link_optional("*", "actiondef_release", actiondef_release);
	mod.link_optional("*", "actiondef_prop", actiondef_prop);
	mod.link_optional("*", "actiondef_tint", actiondef_tint);
	mod.link_optional("*", "actiondef_roll", actiondef_roll);
	mod.link_optional("*", "actiondef_spawn", actiondef_spawn);
	mod.link_optional("*", "actiondef_sequence", actiondef_sequence);
	mod.link_optional("*", "actiondef_delay", actiondef_delay);
	mod.link_optional("*", "actiondef_show", actiondef_show);
	mod.link_optional("*", "actiondef_hide", actiondef_hide);
	mod.link_optional("*", "actiondef_event", actiondef_event);
	mod.link_optional("*", "actiondef_move_to", actiondef_move_to);
	mod.link_optional("*", "actiondef_scale", actiondef_scale);
	mod.link_optional("*", "actiondef_frame", actiondef_frame);
	mod.link_optional("*", "actiondef_frame_with_frames", actiondef_frame_with_frames);
}