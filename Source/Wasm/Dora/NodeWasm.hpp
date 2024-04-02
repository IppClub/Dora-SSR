/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int32_t node_type() {
	return DoraType<Node>();
}
static void node_set_order(int64_t self, int32_t var) {
	r_cast<Node*>(self)->setOrder(s_cast<int>(var));
}
static int32_t node_get_order(int64_t self) {
	return s_cast<int32_t>(r_cast<Node*>(self)->getOrder());
}
static void node_set_angle(int64_t self, float var) {
	r_cast<Node*>(self)->setAngle(var);
}
static float node_get_angle(int64_t self) {
	return r_cast<Node*>(self)->getAngle();
}
static void node_set_angle_x(int64_t self, float var) {
	r_cast<Node*>(self)->setAngleX(var);
}
static float node_get_angle_x(int64_t self) {
	return r_cast<Node*>(self)->getAngleX();
}
static void node_set_angle_y(int64_t self, float var) {
	r_cast<Node*>(self)->setAngleY(var);
}
static float node_get_angle_y(int64_t self) {
	return r_cast<Node*>(self)->getAngleY();
}
static void node_set_scale_x(int64_t self, float var) {
	r_cast<Node*>(self)->setScaleX(var);
}
static float node_get_scale_x(int64_t self) {
	return r_cast<Node*>(self)->getScaleX();
}
static void node_set_scale_y(int64_t self, float var) {
	r_cast<Node*>(self)->setScaleY(var);
}
static float node_get_scale_y(int64_t self) {
	return r_cast<Node*>(self)->getScaleY();
}
static void node_set_x(int64_t self, float var) {
	r_cast<Node*>(self)->setX(var);
}
static float node_get_x(int64_t self) {
	return r_cast<Node*>(self)->getX();
}
static void node_set_y(int64_t self, float var) {
	r_cast<Node*>(self)->setY(var);
}
static float node_get_y(int64_t self) {
	return r_cast<Node*>(self)->getY();
}
static void node_set_z(int64_t self, float var) {
	r_cast<Node*>(self)->setZ(var);
}
static float node_get_z(int64_t self) {
	return r_cast<Node*>(self)->getZ();
}
static void node_set_position(int64_t self, int64_t var) {
	r_cast<Node*>(self)->setPosition(vec2_from(var));
}
static int64_t node_get_position(int64_t self) {
	return vec2_retain(r_cast<Node*>(self)->getPosition());
}
static void node_set_skew_x(int64_t self, float var) {
	r_cast<Node*>(self)->setSkewX(var);
}
static float node_get_skew_x(int64_t self) {
	return r_cast<Node*>(self)->getSkewX();
}
static void node_set_skew_y(int64_t self, float var) {
	r_cast<Node*>(self)->setSkewY(var);
}
static float node_get_skew_y(int64_t self) {
	return r_cast<Node*>(self)->getSkewY();
}
static void node_set_visible(int64_t self, int32_t var) {
	r_cast<Node*>(self)->setVisible(var != 0);
}
static int32_t node_is_visible(int64_t self) {
	return r_cast<Node*>(self)->isVisible() ? 1 : 0;
}
static void node_set_anchor(int64_t self, int64_t var) {
	r_cast<Node*>(self)->setAnchor(vec2_from(var));
}
static int64_t node_get_anchor(int64_t self) {
	return vec2_retain(r_cast<Node*>(self)->getAnchor());
}
static void node_set_width(int64_t self, float var) {
	r_cast<Node*>(self)->setWidth(var);
}
static float node_get_width(int64_t self) {
	return r_cast<Node*>(self)->getWidth();
}
static void node_set_height(int64_t self, float var) {
	r_cast<Node*>(self)->setHeight(var);
}
static float node_get_height(int64_t self) {
	return r_cast<Node*>(self)->getHeight();
}
static void node_set_size(int64_t self, int64_t var) {
	r_cast<Node*>(self)->setSize(size_from(var));
}
static int64_t node_get_size(int64_t self) {
	return size_retain(r_cast<Node*>(self)->getSize());
}
static void node_set_tag(int64_t self, int64_t var) {
	r_cast<Node*>(self)->setTag(*str_from(var));
}
static int64_t node_get_tag(int64_t self) {
	return str_retain(r_cast<Node*>(self)->getTag());
}
static void node_set_opacity(int64_t self, float var) {
	r_cast<Node*>(self)->setOpacity(var);
}
static float node_get_opacity(int64_t self) {
	return r_cast<Node*>(self)->getOpacity();
}
static void node_set_color(int64_t self, int32_t var) {
	r_cast<Node*>(self)->setColor(Color(s_cast<uint32_t>(var)));
}
static int32_t node_get_color(int64_t self) {
	return r_cast<Node*>(self)->getColor().toARGB();
}
static void node_set_color3(int64_t self, int32_t var) {
	r_cast<Node*>(self)->setColor3(Color3(s_cast<uint32_t>(var)));
}
static int32_t node_get_color3(int64_t self) {
	return r_cast<Node*>(self)->getColor3().toRGB();
}
static void node_set_pass_opacity(int64_t self, int32_t var) {
	r_cast<Node*>(self)->setPassOpacity(var != 0);
}
static int32_t node_is_pass_opacity(int64_t self) {
	return r_cast<Node*>(self)->isPassOpacity() ? 1 : 0;
}
static void node_set_pass_color3(int64_t self, int32_t var) {
	r_cast<Node*>(self)->setPassColor3(var != 0);
}
static int32_t node_is_pass_color3(int64_t self) {
	return r_cast<Node*>(self)->isPassColor3() ? 1 : 0;
}
static void node_set_transform_target(int64_t self, int64_t var) {
	r_cast<Node*>(self)->setTransformTarget(r_cast<Node*>(var));
}
static int64_t node_get_transform_target(int64_t self) {
	return from_object(r_cast<Node*>(self)->getTransformTarget());
}
static void node_set_scheduler(int64_t self, int64_t var) {
	r_cast<Node*>(self)->setScheduler(r_cast<Scheduler*>(var));
}
static int64_t node_get_scheduler(int64_t self) {
	return from_object(r_cast<Node*>(self)->getScheduler());
}
static int64_t node_get_children(int64_t self) {
	return from_object(r_cast<Node*>(self)->getChildren());
}
static int64_t node_get_parent(int64_t self) {
	return from_object(r_cast<Node*>(self)->getParent());
}
static int64_t node_get_bounding_box(int64_t self) {
	return r_cast<int64_t>(new Rect{r_cast<Node*>(self)->getBoundingBox()});
}
static int32_t node_is_running(int64_t self) {
	return r_cast<Node*>(self)->isRunning() ? 1 : 0;
}
static int32_t node_is_scheduled(int64_t self) {
	return r_cast<Node*>(self)->isScheduled() ? 1 : 0;
}
static int32_t node_get_action_count(int64_t self) {
	return s_cast<int32_t>(r_cast<Node*>(self)->getActionCount());
}
static int64_t node_get_data(int64_t self) {
	return from_object(r_cast<Node*>(self)->getUserData());
}
static void node_set_touch_enabled(int64_t self, int32_t var) {
	r_cast<Node*>(self)->setTouchEnabled(var != 0);
}
static int32_t node_is_touch_enabled(int64_t self) {
	return r_cast<Node*>(self)->isTouchEnabled() ? 1 : 0;
}
static void node_set_swallow_touches(int64_t self, int32_t var) {
	r_cast<Node*>(self)->setSwallowTouches(var != 0);
}
static int32_t node_is_swallow_touches(int64_t self) {
	return r_cast<Node*>(self)->isSwallowTouches() ? 1 : 0;
}
static void node_set_swallow_mouse_wheel(int64_t self, int32_t var) {
	r_cast<Node*>(self)->setSwallowMouseWheel(var != 0);
}
static int32_t node_is_swallow_mouse_wheel(int64_t self) {
	return r_cast<Node*>(self)->isSwallowMouseWheel() ? 1 : 0;
}
static void node_set_keyboard_enabled(int64_t self, int32_t var) {
	r_cast<Node*>(self)->setKeyboardEnabled(var != 0);
}
static int32_t node_is_keyboard_enabled(int64_t self) {
	return r_cast<Node*>(self)->isKeyboardEnabled() ? 1 : 0;
}
static void node_set_controller_enabled(int64_t self, int32_t var) {
	r_cast<Node*>(self)->setControllerEnabled(var != 0);
}
static int32_t node_is_controller_enabled(int64_t self) {
	return r_cast<Node*>(self)->isControllerEnabled() ? 1 : 0;
}
static void node_set_render_group(int64_t self, int32_t var) {
	r_cast<Node*>(self)->setRenderGroup(var != 0);
}
static int32_t node_is_render_group(int64_t self) {
	return r_cast<Node*>(self)->isRenderGroup() ? 1 : 0;
}
static void node_set_render_order(int64_t self, int32_t var) {
	r_cast<Node*>(self)->setRenderOrder(s_cast<int>(var));
}
static int32_t node_get_render_order(int64_t self) {
	return s_cast<int32_t>(r_cast<Node*>(self)->getRenderOrder());
}
static void node_add_child_with_order_tag(int64_t self, int64_t child, int32_t order, int64_t tag) {
	r_cast<Node*>(self)->addChild(r_cast<Node*>(child), s_cast<int>(order), *str_from(tag));
}
static void node_add_child_with_order(int64_t self, int64_t child, int32_t order) {
	r_cast<Node*>(self)->addChild(r_cast<Node*>(child), s_cast<int>(order));
}
static void node_add_child(int64_t self, int64_t child) {
	r_cast<Node*>(self)->addChild(r_cast<Node*>(child));
}
static int64_t node_add_to_with_order_tag(int64_t self, int64_t parent, int32_t order, int64_t tag) {
	return from_object(r_cast<Node*>(self)->addTo(r_cast<Node*>(parent), s_cast<int>(order), *str_from(tag)));
}
static int64_t node_add_to_with_order(int64_t self, int64_t parent, int32_t order) {
	return from_object(r_cast<Node*>(self)->addTo(r_cast<Node*>(parent), s_cast<int>(order)));
}
static int64_t node_add_to(int64_t self, int64_t parent) {
	return from_object(r_cast<Node*>(self)->addTo(r_cast<Node*>(parent)));
}
static void node_remove_child(int64_t self, int64_t child, int32_t cleanup) {
	r_cast<Node*>(self)->removeChild(r_cast<Node*>(child), cleanup != 0);
}
static void node_remove_child_by_tag(int64_t self, int64_t tag, int32_t cleanup) {
	r_cast<Node*>(self)->removeChildByTag(*str_from(tag), cleanup != 0);
}
static void node_remove_all_children(int64_t self, int32_t cleanup) {
	r_cast<Node*>(self)->removeAllChildren(cleanup != 0);
}
static void node_remove_from_parent(int64_t self, int32_t cleanup) {
	r_cast<Node*>(self)->removeFromParent(cleanup != 0);
}
static void node_move_to_parent(int64_t self, int64_t parent) {
	r_cast<Node*>(self)->moveToParent(r_cast<Node*>(parent));
}
static void node_cleanup(int64_t self) {
	r_cast<Node*>(self)->cleanup();
}
static int64_t node_get_child_by_tag(int64_t self, int64_t tag) {
	return from_object(r_cast<Node*>(self)->getChildByTag(*str_from(tag)));
}
static void node_schedule(int64_t self, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	r_cast<Node*>(self)->schedule([func, args, deref](double deltaTime) {
		args->clear();
		args->push(deltaTime);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	});
}
static void node_unschedule(int64_t self) {
	r_cast<Node*>(self)->unschedule();
}
static int64_t node_convert_to_node_space(int64_t self, int64_t world_point) {
	return vec2_retain(r_cast<Node*>(self)->convertToNodeSpace(vec2_from(world_point)));
}
static int64_t node_convert_to_world_space(int64_t self, int64_t node_point) {
	return vec2_retain(r_cast<Node*>(self)->convertToWorldSpace(vec2_from(node_point)));
}
static void node_convert_to_window_space(int64_t self, int64_t node_point, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	r_cast<Node*>(self)->convertToWindowSpace(vec2_from(node_point), [func, args, deref](Vec2 result) {
		args->clear();
		args->push(result);
		SharedWasmRuntime.invoke(func);
	});
}
static int32_t node_each_child(int64_t self, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return r_cast<Node*>(self)->eachChild([func, args, deref](Node* child) {
		args->clear();
		args->push(child);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}) ? 1 : 0;
}
static int32_t node_traverse(int64_t self, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return r_cast<Node*>(self)->traverse([func, args, deref](Node* child) {
		args->clear();
		args->push(child);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}) ? 1 : 0;
}
static int32_t node_traverse_all(int64_t self, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return r_cast<Node*>(self)->traverseAll([func, args, deref](Node* child) {
		args->clear();
		args->push(child);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}) ? 1 : 0;
}
static int64_t node_run_action(int64_t self, int64_t def) {
	return from_object(node_run_action_def(r_cast<Node*>(self), std::move(*r_cast<ActionDef*>(def))));
}
static void node_stop_all_actions(int64_t self) {
	r_cast<Node*>(self)->stopAllActions();
}
static int64_t node_perform(int64_t self, int64_t action_def) {
	return from_object(node_perform_def(r_cast<Node*>(self), std::move(*r_cast<ActionDef*>(action_def))));
}
static void node_stop_action(int64_t self, int64_t action) {
	r_cast<Node*>(self)->stopAction(r_cast<Action*>(action));
}
static int64_t node_align_items_vertically(int64_t self, float padding) {
	return size_retain(r_cast<Node*>(self)->alignItemsVertically(padding));
}
static int64_t node_align_items_vertically_with_size(int64_t self, int64_t size, float padding) {
	return size_retain(r_cast<Node*>(self)->alignItemsVertically(size_from(size), padding));
}
static int64_t node_align_items_horizontally(int64_t self, float padding) {
	return size_retain(r_cast<Node*>(self)->alignItemsHorizontally(padding));
}
static int64_t node_align_items_horizontally_with_size(int64_t self, int64_t size, float padding) {
	return size_retain(r_cast<Node*>(self)->alignItemsHorizontally(size_from(size), padding));
}
static int64_t node_align_items(int64_t self, float padding) {
	return size_retain(r_cast<Node*>(self)->alignItems(padding));
}
static int64_t node_align_items_with_size(int64_t self, int64_t size, float padding) {
	return size_retain(r_cast<Node*>(self)->alignItems(size_from(size), padding));
}
static void node_move_and_cull_items(int64_t self, int64_t delta) {
	r_cast<Node*>(self)->moveAndCullItems(vec2_from(delta));
}
static void node_attach_ime(int64_t self) {
	r_cast<Node*>(self)->attachIME();
}
static void node_detach_ime(int64_t self) {
	r_cast<Node*>(self)->detachIME();
}
static int64_t node_grab(int64_t self) {
	return from_object(node_start_grabbing(r_cast<Node*>(self)));
}
static int64_t node_grab_with_size(int64_t self, int32_t grid_x, int32_t grid_y) {
	return from_object(r_cast<Node*>(self)->grab(s_cast<uint32_t>(grid_x), s_cast<uint32_t>(grid_y)));
}
static void node_stop_grab(int64_t self) {
	node_stop_grabbing(r_cast<Node*>(self));
}
static void node_set_transform_target_null(int64_t self) {
	node_set_transform_target_nullptr(r_cast<Node*>(self));
}
static void node_slot(int64_t self, int64_t event_name, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	r_cast<Node*>(self)->slot(*str_from(event_name), [func, args, deref](Event* e) {
		args->clear();
		e->pushArgsToWasm(args);
		SharedWasmRuntime.invoke(func);
	});
}
static void node_gslot(int64_t self, int64_t event_name, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	r_cast<Node*>(self)->gslot(*str_from(event_name), [func, args, deref](Event* e) {
		args->clear();
		e->pushArgsToWasm(args);
		SharedWasmRuntime.invoke(func);
	});
}
static int64_t node_new() {
	return from_object(Node::create());
}
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
	mod.link_optional("*", "node_get_bounding_box", node_get_bounding_box);
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
	mod.link_optional("*", "node_run_action", node_run_action);
	mod.link_optional("*", "node_stop_all_actions", node_stop_all_actions);
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
	mod.link_optional("*", "node_new", node_new);
}