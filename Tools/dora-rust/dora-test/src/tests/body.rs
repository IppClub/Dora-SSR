/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

use dora_ssr::*;

pub fn test() {
	let gravity = Vec2::new(0.0, -10.0);
	let group_zero = 0;
	let group_one = 1;
	let group_two = 2;

	let mut terrain_def = BodyDef::new();
	terrain_def.set_type(BodyType::Static);
	terrain_def.attach_polygon(800.0, 10.0, 1.0, 0.8, 0.2);

	let mut polygon_def = BodyDef::new();
	polygon_def.set_type(BodyType::Dynamic);
	polygon_def.set_linear_acceleration(&gravity);
	polygon_def.attach_polygon_with_vertices(&vec![
		Vec2::new(60.0, 0.0),
		Vec2::new(30.0, -30.0),
		Vec2::new(-30.0, -30.0),
		Vec2::new(-60.0, 0.0),
		Vec2::new(-30.0, 30.0),
		Vec2::new(30.0, 30.0)
	], 1.0, 0.4, 0.4);

	let mut disk_def = BodyDef::new();
	disk_def.set_type(BodyType::Dynamic);
	disk_def.set_linear_acceleration(&gravity);
	disk_def.attach_disk(60.0, 1.0, 0.4, 0.4);

	let mut world = PhysicsWorld::new();
	world.set_y(-200.0);
	world.set_should_contact(group_zero, group_one, false);
	world.set_should_contact(group_zero, group_two, true);
	world.set_should_contact(group_one, group_two, true);
	world.set_show_debug(true);

	let mut body = Body::new(&terrain_def, &world, &Vec2::zero(), 0.0);
	body.set_group(group_two);
	world.add_child(&body);

	let mut body_p = Body::new(&polygon_def, &world, &Vec2::new(0.0, 500.0), 15.0);
	body_p.set_group(group_one);
	world.add_child(&body_p);

	let mut body_d = Body::new(&disk_def, &world, &Vec2::new(50.0, 800.0), 0.0);
	body_d.set_group(group_zero);
	body_d.set_angular_rate(90.0);
	world.add_child(&body_d);

	let windows_flags =
		ImGuiWindowFlag::NO_DECORATION |
		ImGuiWindowFlag::AlwaysAutoResize |
		ImGuiWindowFlag::NoSavedSettings |
		ImGuiWindowFlag::NoFocusOnAppearing |
		ImGuiWindowFlag::NO_NAV |
		ImGuiWindowFlag::NoMove;
	let mut imgui_node = Node::new();
	imgui_node.schedule(Box::new(move |_| {
		let width = App::get_visual_size().width;
		ImGui::set_next_window_bg_alpha(0.35);
		ImGui::set_next_window_pos_opts(&Vec2::new(width - 10.0, 10.0), ImGuiCond::Always, &Vec2::new(1.0, 0.0));
		ImGui::set_next_window_size_opts(&Vec2::new(240.0, 0.0), ImGuiCond::FirstUseEver);
		ImGui::begin_opts("Body", windows_flags, || {
			ImGui::text("Body (Rust)");
			ImGui::separator();
			ImGui::text_wrapped("Basic usage to create physics bodies!");
		});
		false
	}));
}
