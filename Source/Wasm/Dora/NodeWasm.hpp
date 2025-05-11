/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t node_type() {
	return DoraType<Node>();
}
void node_set_order(int64_t self, int32_t val) {
	r_cast<Node*>(self)->setOrder(s_cast<int>(val));
}
int32_t node_get_order(int64_t self) {
	return s_cast<int32_t>(r_cast<Node*>(self)->getOrder());
}
void node_set_angle(int64_t self, float val) {
	r_cast<Node*>(self)->setAngle(val);
}
float node_get_angle(int64_t self) {
	return r_cast<Node*>(self)->getAngle();
}
void node_set_angle_x(int64_t self, float val) {
	r_cast<Node*>(self)->setAngleX(val);
}
float node_get_angle_x(int64_t self) {
	return r_cast<Node*>(self)->getAngleX();
}
void node_set_angle_y(int64_t self, float val) {
	r_cast<Node*>(self)->setAngleY(val);
}
float node_get_angle_y(int64_t self) {
	return r_cast<Node*>(self)->getAngleY();
}
void node_set_scale_x(int64_t self, float val) {
	r_cast<Node*>(self)->setScaleX(val);
}
float node_get_scale_x(int64_t self) {
	return r_cast<Node*>(self)->getScaleX();
}
void node_set_scale_y(int64_t self, float val) {
	r_cast<Node*>(self)->setScaleY(val);
}
float node_get_scale_y(int64_t self) {
	return r_cast<Node*>(self)->getScaleY();
}
void node_set_x(int64_t self, float val) {
	r_cast<Node*>(self)->setX(val);
}
float node_get_x(int64_t self) {
	return r_cast<Node*>(self)->getX();
}
void node_set_y(int64_t self, float val) {
	r_cast<Node*>(self)->setY(val);
}
float node_get_y(int64_t self) {
	return r_cast<Node*>(self)->getY();
}
void node_set_z(int64_t self, float val) {
	r_cast<Node*>(self)->setZ(val);
}
float node_get_z(int64_t self) {
	return r_cast<Node*>(self)->getZ();
}
void node_set_position(int64_t self, int64_t val) {
	r_cast<Node*>(self)->setPosition(Vec2_From(val));
}
int64_t node_get_position(int64_t self) {
	return Vec2_Retain(r_cast<Node*>(self)->getPosition());
}
void node_set_skew_x(int64_t self, float val) {
	r_cast<Node*>(self)->setSkewX(val);
}
float node_get_skew_x(int64_t self) {
	return r_cast<Node*>(self)->getSkewX();
}
void node_set_skew_y(int64_t self, float val) {
	r_cast<Node*>(self)->setSkewY(val);
}
float node_get_skew_y(int64_t self) {
	return r_cast<Node*>(self)->getSkewY();
}
void node_set_visible(int64_t self, int32_t val) {
	r_cast<Node*>(self)->setVisible(val != 0);
}
int32_t node_is_visible(int64_t self) {
	return r_cast<Node*>(self)->isVisible() ? 1 : 0;
}
void node_set_anchor(int64_t self, int64_t val) {
	r_cast<Node*>(self)->setAnchor(Vec2_From(val));
}
int64_t node_get_anchor(int64_t self) {
	return Vec2_Retain(r_cast<Node*>(self)->getAnchor());
}
void node_set_width(int64_t self, float val) {
	r_cast<Node*>(self)->setWidth(val);
}
float node_get_width(int64_t self) {
	return r_cast<Node*>(self)->getWidth();
}
void node_set_height(int64_t self, float val) {
	r_cast<Node*>(self)->setHeight(val);
}
float node_get_height(int64_t self) {
	return r_cast<Node*>(self)->getHeight();
}
void node_set_size(int64_t self, int64_t val) {
	r_cast<Node*>(self)->setSize(Size_From(val));
}
int64_t node_get_size(int64_t self) {
	return Size_Retain(r_cast<Node*>(self)->getSize());
}
void node_set_tag(int64_t self, int64_t val) {
	r_cast<Node*>(self)->setTag(*Str_From(val));
}
int64_t node_get_tag(int64_t self) {
	return Str_Retain(r_cast<Node*>(self)->getTag());
}
void node_set_opacity(int64_t self, float val) {
	r_cast<Node*>(self)->setOpacity(val);
}
float node_get_opacity(int64_t self) {
	return r_cast<Node*>(self)->getOpacity();
}
void node_set_color(int64_t self, int32_t val) {
	r_cast<Node*>(self)->setColor(Color(s_cast<uint32_t>(val)));
}
int32_t node_get_color(int64_t self) {
	return r_cast<Node*>(self)->getColor().toARGB();
}
void node_set_color3(int64_t self, int32_t val) {
	r_cast<Node*>(self)->setColor3(Color3(s_cast<uint32_t>(val)));
}
int32_t node_get_color3(int64_t self) {
	return r_cast<Node*>(self)->getColor3().toRGB();
}
void node_set_pass_opacity(int64_t self, int32_t val) {
	r_cast<Node*>(self)->setPassOpacity(val != 0);
}
int32_t node_is_pass_opacity(int64_t self) {
	return r_cast<Node*>(self)->isPassOpacity() ? 1 : 0;
}
void node_set_pass_color3(int64_t self, int32_t val) {
	r_cast<Node*>(self)->setPassColor3(val != 0);
}
int32_t node_is_pass_color3(int64_t self) {
	return r_cast<Node*>(self)->isPassColor3() ? 1 : 0;
}
void node_set_transform_target(int64_t self, int64_t val) {
	r_cast<Node*>(self)->setTransformTarget(r_cast<Node*>(val));
}
int64_t node_get_transform_target(int64_t self) {
	return Object_From(r_cast<Node*>(self)->getTransformTarget());
}
void node_set_scheduler(int64_t self, int64_t val) {
	r_cast<Node*>(self)->setScheduler(r_cast<Scheduler*>(val));
}
int64_t node_get_scheduler(int64_t self) {
	return Object_From(r_cast<Node*>(self)->getScheduler());
}
int64_t node_get_children(int64_t self) {
	return Object_From(r_cast<Node*>(self)->getChildren());
}
int64_t node_get_parent(int64_t self) {
	return Object_From(r_cast<Node*>(self)->getParent());
}
int32_t node_is_running(int64_t self) {
	return r_cast<Node*>(self)->isRunning() ? 1 : 0;
}
int32_t node_is_scheduled(int64_t self) {
	return r_cast<Node*>(self)->isScheduled() ? 1 : 0;
}
int32_t node_get_action_count(int64_t self) {
	return s_cast<int32_t>(r_cast<Node*>(self)->getActionCount());
}
int64_t node_get_data(int64_t self) {
	return Object_From(r_cast<Node*>(self)->getUserData());
}
void node_set_touch_enabled(int64_t self, int32_t val) {
	r_cast<Node*>(self)->setTouchEnabled(val != 0);
}
int32_t node_is_touch_enabled(int64_t self) {
	return r_cast<Node*>(self)->isTouchEnabled() ? 1 : 0;
}
void node_set_swallow_touches(int64_t self, int32_t val) {
	r_cast<Node*>(self)->setSwallowTouches(val != 0);
}
int32_t node_is_swallow_touches(int64_t self) {
	return r_cast<Node*>(self)->isSwallowTouches() ? 1 : 0;
}
void node_set_swallow_mouse_wheel(int64_t self, int32_t val) {
	r_cast<Node*>(self)->setSwallowMouseWheel(val != 0);
}
int32_t node_is_swallow_mouse_wheel(int64_t self) {
	return r_cast<Node*>(self)->isSwallowMouseWheel() ? 1 : 0;
}
void node_set_keyboard_enabled(int64_t self, int32_t val) {
	r_cast<Node*>(self)->setKeyboardEnabled(val != 0);
}
int32_t node_is_keyboard_enabled(int64_t self) {
	return r_cast<Node*>(self)->isKeyboardEnabled() ? 1 : 0;
}
void node_set_controller_enabled(int64_t self, int32_t val) {
	r_cast<Node*>(self)->setControllerEnabled(val != 0);
}
int32_t node_is_controller_enabled(int64_t self) {
	return r_cast<Node*>(self)->isControllerEnabled() ? 1 : 0;
}
void node_set_render_group(int64_t self, int32_t val) {
	r_cast<Node*>(self)->setRenderGroup(val != 0);
}
int32_t node_is_render_group(int64_t self) {
	return r_cast<Node*>(self)->isRenderGroup() ? 1 : 0;
}
void node_set_show_debug(int64_t self, int32_t val) {
	r_cast<Node*>(self)->setShowDebug(val != 0);
}
int32_t node_is_show_debug(int64_t self) {
	return r_cast<Node*>(self)->isShowDebug() ? 1 : 0;
}
void node_set_render_order(int64_t self, int32_t val) {
	r_cast<Node*>(self)->setRenderOrder(s_cast<int>(val));
}
int32_t node_get_render_order(int64_t self) {
	return s_cast<int32_t>(r_cast<Node*>(self)->getRenderOrder());
}
void node_add_child_with_order_tag(int64_t self, int64_t child, int32_t order, int64_t tag) {
	r_cast<Node*>(self)->addChild(r_cast<Node*>(child), s_cast<int>(order), *Str_From(tag));
}
void node_add_child_with_order(int64_t self, int64_t child, int32_t order) {
	r_cast<Node*>(self)->addChild(r_cast<Node*>(child), s_cast<int>(order));
}
void node_add_child(int64_t self, int64_t child) {
	r_cast<Node*>(self)->addChild(r_cast<Node*>(child));
}
int64_t node_add_to_with_order_tag(int64_t self, int64_t parent, int32_t order, int64_t tag) {
	return Object_From(r_cast<Node*>(self)->addTo(r_cast<Node*>(parent), s_cast<int>(order), *Str_From(tag)));
}
int64_t node_add_to_with_order(int64_t self, int64_t parent, int32_t order) {
	return Object_From(r_cast<Node*>(self)->addTo(r_cast<Node*>(parent), s_cast<int>(order)));
}
int64_t node_add_to(int64_t self, int64_t parent) {
	return Object_From(r_cast<Node*>(self)->addTo(r_cast<Node*>(parent)));
}
void node_remove_child(int64_t self, int64_t child, int32_t cleanup) {
	r_cast<Node*>(self)->removeChild(r_cast<Node*>(child), cleanup != 0);
}
void node_remove_child_by_tag(int64_t self, int64_t tag, int32_t cleanup) {
	r_cast<Node*>(self)->removeChildByTag(*Str_From(tag), cleanup != 0);
}
void node_remove_all_children(int64_t self, int32_t cleanup) {
	r_cast<Node*>(self)->removeAllChildren(cleanup != 0);
}
void node_remove_from_parent(int64_t self, int32_t cleanup) {
	r_cast<Node*>(self)->removeFromParent(cleanup != 0);
}
void node_move_to_parent(int64_t self, int64_t parent) {
	r_cast<Node*>(self)->moveToParent(r_cast<Node*>(parent));
}
void node_cleanup(int64_t self) {
	r_cast<Node*>(self)->cleanup();
}
int64_t node_get_child_by_tag(int64_t self, int64_t tag) {
	return Object_From(r_cast<Node*>(self)->getChildByTag(*Str_From(tag)));
}
void node_schedule(int64_t self, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	r_cast<Node*>(self)->schedule([func0, args0, deref0](double deltaTime) {
		args0->clear();
		args0->push(deltaTime);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(true);
	});
}
void node_unschedule(int64_t self) {
	r_cast<Node*>(self)->unschedule();
}
int64_t node_convert_to_node_space(int64_t self, int64_t world_point) {
	return Vec2_Retain(r_cast<Node*>(self)->convertToNodeSpace(Vec2_From(world_point)));
}
int64_t node_convert_to_world_space(int64_t self, int64_t node_point) {
	return Vec2_Retain(r_cast<Node*>(self)->convertToWorldSpace(Vec2_From(node_point)));
}
void node_convert_to_window_space(int64_t self, int64_t node_point, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	r_cast<Node*>(self)->convertToWindowSpace(Vec2_From(node_point), [func0, args0, deref0](Vec2 result) {
		args0->clear();
		args0->push(result);
		SharedWasmRuntime.invoke(func0);
	});
}
int32_t node_each_child(int64_t self, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	return r_cast<Node*>(self)->eachChild([func0, args0, deref0](Node* child) {
		args0->clear();
		args0->push(child);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(true);
	}) ? 1 : 0;
}
int32_t node_traverse(int64_t self, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	return r_cast<Node*>(self)->traverse([func0, args0, deref0](Node* child) {
		args0->clear();
		args0->push(child);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(true);
	}) ? 1 : 0;
}
int32_t node_traverse_all(int64_t self, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	return r_cast<Node*>(self)->traverseAll([func0, args0, deref0](Node* child) {
		args0->clear();
		args0->push(child);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(true);
	}) ? 1 : 0;
}
float node_run_action_def(int64_t self, int64_t def, int32_t looped) {
	return Node_RunActionDefDuration(r_cast<Node*>(self), std::move(*r_cast<ActionDef*>(def)), looped != 0);
}
float node_run_action(int64_t self, int64_t action, int32_t looped) {
	return r_cast<Node*>(self)->runAction(r_cast<Action*>(action), looped != 0);
}
void node_stop_all_actions(int64_t self) {
	r_cast<Node*>(self)->stopAllActions();
}
float node_perform_def(int64_t self, int64_t action_def, int32_t looped) {
	return Node_PerformDefDuration(r_cast<Node*>(self), std::move(*r_cast<ActionDef*>(action_def)), looped != 0);
}
float node_perform(int64_t self, int64_t action, int32_t looped) {
	return r_cast<Node*>(self)->perform(r_cast<Action*>(action), looped != 0);
}
void node_stop_action(int64_t self, int64_t action) {
	r_cast<Node*>(self)->stopAction(r_cast<Action*>(action));
}
int64_t node_align_items_vertically(int64_t self, float padding) {
	return Size_Retain(r_cast<Node*>(self)->alignItemsVertically(padding));
}
int64_t node_align_items_vertically_with_size(int64_t self, int64_t size, float padding) {
	return Size_Retain(r_cast<Node*>(self)->alignItemsVertically(Size_From(size), padding));
}
int64_t node_align_items_horizontally(int64_t self, float padding) {
	return Size_Retain(r_cast<Node*>(self)->alignItemsHorizontally(padding));
}
int64_t node_align_items_horizontally_with_size(int64_t self, int64_t size, float padding) {
	return Size_Retain(r_cast<Node*>(self)->alignItemsHorizontally(Size_From(size), padding));
}
int64_t node_align_items(int64_t self, float padding) {
	return Size_Retain(r_cast<Node*>(self)->alignItems(padding));
}
int64_t node_align_items_with_size(int64_t self, int64_t size, float padding) {
	return Size_Retain(r_cast<Node*>(self)->alignItems(Size_From(size), padding));
}
void node_move_and_cull_items(int64_t self, int64_t delta) {
	r_cast<Node*>(self)->moveAndCullItems(Vec2_From(delta));
}
void node_attach_ime(int64_t self) {
	r_cast<Node*>(self)->attachIME();
}
void node_detach_ime(int64_t self) {
	r_cast<Node*>(self)->detachIME();
}
int64_t node_grab(int64_t self) {
	return Object_From(Node_StartGrabbing(r_cast<Node*>(self)));
}
int64_t node_grab_with_size(int64_t self, int32_t grid_x, int32_t grid_y) {
	return Object_From(r_cast<Node*>(self)->grab(s_cast<uint32_t>(grid_x), s_cast<uint32_t>(grid_y)));
}
void node_stop_grab(int64_t self) {
	Node_StopGrabbing(r_cast<Node*>(self));
}
void node_set_transform_target_null(int64_t self) {
	Node_SetTransformTargetNullptr(r_cast<Node*>(self));
}
void node_slot(int64_t self, int64_t event_name, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	r_cast<Node*>(self)->slot(*Str_From(event_name), [func0, args0, deref0](Event* e) {
		args0->clear();
		e->pushArgsToWasm(args0);
		SharedWasmRuntime.invoke(func0);
	});
}
void node_gslot(int64_t self, int64_t event_name, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	r_cast<Node*>(self)->gslot(*Str_From(event_name), [func0, args0, deref0](Event* e) {
		args0->clear();
		e->pushArgsToWasm(args0);
		SharedWasmRuntime.invoke(func0);
	});
}
void node_emit(int64_t self, int64_t name, int64_t stack) {
	Node_Emit(r_cast<Node*>(self), *Str_From(name), r_cast<CallStack*>(stack));
}
void node_on_update(int64_t self, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	r_cast<Node*>(self)->onUpdate([func0, args0, deref0](double deltaTime) {
		args0->clear();
		args0->push(deltaTime);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(true);
	});
}
void node_on_render(int64_t self, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	r_cast<Node*>(self)->onRender([func0, args0, deref0](double deltaTime) {
		args0->clear();
		args0->push(deltaTime);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(true);
	});
}
int64_t node_new() {
	return Object_From(Node::create());
}
} // extern "C"

static void linkNode(wasm3::module3& mod) {
	mod.link_optional("*", "node_type", node_type);
	mod.link_optional("*", "node_set_order", node_set_order);
	mod.link_optional("*", "node_get_order", node_get_order);
	mod.link_optional("*", "node_set_angle", node_set_angle);
	mod.link_optional("*", "node_get_angle", node_get_angle);
	mod.link_optional("*", "node_set_angle_x", node_set_angle_x);
	mod.link_optional("*", "node_get_angle_x", node_get_angle_x);
	mod.link_optional("*", "node_set_angle_y", node_set_angle_y);
	mod.link_optional("*", "node_get_angle_y", node_get_angle_y);
	mod.link_optional("*", "node_set_scale_x", node_set_scale_x);
	mod.link_optional("*", "node_get_scale_x", node_get_scale_x);
	mod.link_optional("*", "node_set_scale_y", node_set_scale_y);
	mod.link_optional("*", "node_get_scale_y", node_get_scale_y);
	mod.link_optional("*", "node_set_x", node_set_x);
	mod.link_optional("*", "node_get_x", node_get_x);
	mod.link_optional("*", "node_set_y", node_set_y);
	mod.link_optional("*", "node_get_y", node_get_y);
	mod.link_optional("*", "node_set_z", node_set_z);
	mod.link_optional("*", "node_get_z", node_get_z);
	mod.link_optional("*", "node_set_position", node_set_position);
	mod.link_optional("*", "node_get_position", node_get_position);
	mod.link_optional("*", "node_set_skew_x", node_set_skew_x);
	mod.link_optional("*", "node_get_skew_x", node_get_skew_x);
	mod.link_optional("*", "node_set_skew_y", node_set_skew_y);
	mod.link_optional("*", "node_get_skew_y", node_get_skew_y);
	mod.link_optional("*", "node_set_visible", node_set_visible);
	mod.link_optional("*", "node_is_visible", node_is_visible);
	mod.link_optional("*", "node_set_anchor", node_set_anchor);
	mod.link_optional("*", "node_get_anchor", node_get_anchor);
	mod.link_optional("*", "node_set_width", node_set_width);
	mod.link_optional("*", "node_get_width", node_get_width);
	mod.link_optional("*", "node_set_height", node_set_height);
	mod.link_optional("*", "node_get_height", node_get_height);
	mod.link_optional("*", "node_set_size", node_set_size);
	mod.link_optional("*", "node_get_size", node_get_size);
	mod.link_optional("*", "node_set_tag", node_set_tag);
	mod.link_optional("*", "node_get_tag", node_get_tag);
	mod.link_optional("*", "node_set_opacity", node_set_opacity);
	mod.link_optional("*", "node_get_opacity", node_get_opacity);
	mod.link_optional("*", "node_set_color", node_set_color);
	mod.link_optional("*", "node_get_color", node_get_color);
	mod.link_optional("*", "node_set_color3", node_set_color3);
	mod.link_optional("*", "node_get_color3", node_get_color3);
	mod.link_optional("*", "node_set_pass_opacity", node_set_pass_opacity);
	mod.link_optional("*", "node_is_pass_opacity", node_is_pass_opacity);
	mod.link_optional("*", "node_set_pass_color3", node_set_pass_color3);
	mod.link_optional("*", "node_is_pass_color3", node_is_pass_color3);
	mod.link_optional("*", "node_set_transform_target", node_set_transform_target);
	mod.link_optional("*", "node_get_transform_target", node_get_transform_target);
	mod.link_optional("*", "node_set_scheduler", node_set_scheduler);
	mod.link_optional("*", "node_get_scheduler", node_get_scheduler);
	mod.link_optional("*", "node_get_children", node_get_children);
	mod.link_optional("*", "node_get_parent", node_get_parent);
	mod.link_optional("*", "node_is_running", node_is_running);
	mod.link_optional("*", "node_is_scheduled", node_is_scheduled);
	mod.link_optional("*", "node_get_action_count", node_get_action_count);
	mod.link_optional("*", "node_get_data", node_get_data);
	mod.link_optional("*", "node_set_touch_enabled", node_set_touch_enabled);
	mod.link_optional("*", "node_is_touch_enabled", node_is_touch_enabled);
	mod.link_optional("*", "node_set_swallow_touches", node_set_swallow_touches);
	mod.link_optional("*", "node_is_swallow_touches", node_is_swallow_touches);
	mod.link_optional("*", "node_set_swallow_mouse_wheel", node_set_swallow_mouse_wheel);
	mod.link_optional("*", "node_is_swallow_mouse_wheel", node_is_swallow_mouse_wheel);
	mod.link_optional("*", "node_set_keyboard_enabled", node_set_keyboard_enabled);
	mod.link_optional("*", "node_is_keyboard_enabled", node_is_keyboard_enabled);
	mod.link_optional("*", "node_set_controller_enabled", node_set_controller_enabled);
	mod.link_optional("*", "node_is_controller_enabled", node_is_controller_enabled);
	mod.link_optional("*", "node_set_render_group", node_set_render_group);
	mod.link_optional("*", "node_is_render_group", node_is_render_group);
	mod.link_optional("*", "node_set_show_debug", node_set_show_debug);
	mod.link_optional("*", "node_is_show_debug", node_is_show_debug);
	mod.link_optional("*", "node_set_render_order", node_set_render_order);
	mod.link_optional("*", "node_get_render_order", node_get_render_order);
	mod.link_optional("*", "node_add_child_with_order_tag", node_add_child_with_order_tag);
	mod.link_optional("*", "node_add_child_with_order", node_add_child_with_order);
	mod.link_optional("*", "node_add_child", node_add_child);
	mod.link_optional("*", "node_add_to_with_order_tag", node_add_to_with_order_tag);
	mod.link_optional("*", "node_add_to_with_order", node_add_to_with_order);
	mod.link_optional("*", "node_add_to", node_add_to);
	mod.link_optional("*", "node_remove_child", node_remove_child);
	mod.link_optional("*", "node_remove_child_by_tag", node_remove_child_by_tag);
	mod.link_optional("*", "node_remove_all_children", node_remove_all_children);
	mod.link_optional("*", "node_remove_from_parent", node_remove_from_parent);
	mod.link_optional("*", "node_move_to_parent", node_move_to_parent);
	mod.link_optional("*", "node_cleanup", node_cleanup);
	mod.link_optional("*", "node_get_child_by_tag", node_get_child_by_tag);
	mod.link_optional("*", "node_schedule", node_schedule);
	mod.link_optional("*", "node_unschedule", node_unschedule);
	mod.link_optional("*", "node_convert_to_node_space", node_convert_to_node_space);
	mod.link_optional("*", "node_convert_to_world_space", node_convert_to_world_space);
	mod.link_optional("*", "node_convert_to_window_space", node_convert_to_window_space);
	mod.link_optional("*", "node_each_child", node_each_child);
	mod.link_optional("*", "node_traverse", node_traverse);
	mod.link_optional("*", "node_traverse_all", node_traverse_all);
	mod.link_optional("*", "node_run_action_def", node_run_action_def);
	mod.link_optional("*", "node_run_action", node_run_action);
	mod.link_optional("*", "node_stop_all_actions", node_stop_all_actions);
	mod.link_optional("*", "node_perform_def", node_perform_def);
	mod.link_optional("*", "node_perform", node_perform);
	mod.link_optional("*", "node_stop_action", node_stop_action);
	mod.link_optional("*", "node_align_items_vertically", node_align_items_vertically);
	mod.link_optional("*", "node_align_items_vertically_with_size", node_align_items_vertically_with_size);
	mod.link_optional("*", "node_align_items_horizontally", node_align_items_horizontally);
	mod.link_optional("*", "node_align_items_horizontally_with_size", node_align_items_horizontally_with_size);
	mod.link_optional("*", "node_align_items", node_align_items);
	mod.link_optional("*", "node_align_items_with_size", node_align_items_with_size);
	mod.link_optional("*", "node_move_and_cull_items", node_move_and_cull_items);
	mod.link_optional("*", "node_attach_ime", node_attach_ime);
	mod.link_optional("*", "node_detach_ime", node_detach_ime);
	mod.link_optional("*", "node_grab", node_grab);
	mod.link_optional("*", "node_grab_with_size", node_grab_with_size);
	mod.link_optional("*", "node_stop_grab", node_stop_grab);
	mod.link_optional("*", "node_set_transform_target_null", node_set_transform_target_null);
	mod.link_optional("*", "node_slot", node_slot);
	mod.link_optional("*", "node_gslot", node_gslot);
	mod.link_optional("*", "node_emit", node_emit);
	mod.link_optional("*", "node_on_update", node_on_update);
	mod.link_optional("*", "node_on_render", node_on_render);
	mod.link_optional("*", "node_new", node_new);
}