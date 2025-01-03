/* Copyright (c) 2025 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
double platformer_behavior_blackboard_get_delta_time(int64_t self) {
	return r_cast<Platformer::Behavior::Blackboard*>(self)->getDeltaTime();
}
int64_t platformer_behavior_blackboard_get_owner(int64_t self) {
	return Object_From(r_cast<Platformer::Behavior::Blackboard*>(self)->getOwner());
}
} // extern "C"

static void linkPlatformerBehaviorBlackboard(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_behavior_blackboard_get_delta_time", platformer_behavior_blackboard_get_delta_time);
	mod.link_optional("*", "platformer_behavior_blackboard_get_owner", platformer_behavior_blackboard_get_owner);
}