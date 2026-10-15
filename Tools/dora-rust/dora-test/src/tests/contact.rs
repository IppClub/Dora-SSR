/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

use dora_ssr::*;

pub fn test() {
	let gravity = Vec2::new(0.0, -10.0);
	let mut world = PhysicsWorld::new();
	world.set_should_contact(0, 0, true);
	world.set_show_debug(true);
	let mut label = match Label::new("sarasa-mono-sc-regular", 30, false) {
		Some(label) => label,
		None => return,
	};
	label.add_to(&world);
	let mut terrain_def = BodyDef::new();
	let count = 50;
	let radius = 300.0;
	let mut vertices = vec![];
	for i in 0..=count {
		let angle = 2.0 * Math::PI * i as f32 / count as f32;
		vertices.push(Vec2::new(radius * Math::cos(angle), radius * Math::sin(angle)));
	}
	terrain_def.attach_chain(&vertices, 0.4, 0.0);
	terrain_def.attach_disk_with_center(&Vec2::new(0.0, -270.0), 30.0, 1.0, 0.0, 1.0);
	let mut terrain = Body::new(&terrain_def, &world, &Vec2::zero(), 0.0);
	terrain.add_to(&world);

	let mut platform_def = BodyDef::new();
	platform_def.attach_polygon_with_center(&Vec2::new(0.0, -80.0), 120.0, 30.0, 0.0, 1.0, 0.0, 1.0);
	let mut platform = Body::new(&platform_def, &world, &Vec2::zero(), 0.0);
	platform.on_contact_filter(Box::new(|other| {
		other.get_velocity_y() < 0.0
	}));
	platform.add_to(&world);

	let mut draw_node = Line::with_vec_color(&vec![
		Vec2::new(-20.0, 0.0),
		Vec2::new(20.0, 0.0),
		Vec2::zero(),
		Vec2::new(0.0, -20.0),
		Vec2::new(0.0, 20.0)
	], &App::get_theme_color());
	draw_node.add_to(&world);
	let mut disk_def = BodyDef::new();
	disk_def.set_type(BodyType::Dynamic);
	disk_def.set_linear_acceleration(&gravity);
	disk_def.attach_disk(20.0, 5.0, 0.8, 1.0);
	let mut disk = Body::new(&disk_def, &world, &Vec2::new(100.0, 200.0), 0.0);
	disk.add_to(&world);
	disk.set_angular_rate(-1800.0);
	let mut lb = label.clone();
	Slot::on_contact_start(&mut disk, move |_other, point, _normal, enabled| {
		if enabled {
			draw_node.set_position(&point);
			lb.set_text(&format!("Contact: [{:.0},{:.0}]", point.x, point.y));
		}
	});
	let windows_flags =
		ImGuiWindowFlag::NO_DECORATION |
		ImGuiWindowFlag::AlwaysAutoResize |
		ImGuiWindowFlag::NoSavedSettings |
		ImGuiWindowFlag::NoFocusOnAppearing |
		ImGuiWindowFlag::NO_NAV |
		ImGuiWindowFlag::NoMove;
	let mut receiving_contact = disk.is_receiving_contact();
	let mut imgui_node = Node::new();
	let mut lb = label.clone();
	imgui_node.schedule(Box::new(move |_| {
		let width = App::get_visual_size().width;
		ImGui::set_next_window_bg_alpha(0.35);
		ImGui::set_next_window_pos_opts(&Vec2::new(width - 10.0, 10.0), ImGuiCond::Always, &Vec2::new(1.0, 0.0));
		ImGui::set_next_window_size_opts(&Vec2::new(240.0, 0.0), ImGuiCond::FirstUseEver);
		ImGui::begin_opts("Contact", windows_flags, || {
			ImGui::text("Contact (Rust)");
			ImGui::separator();
			ImGui::text_wrapped("Receive events when physics bodies contact.");
			let (changed, receiving_contact_temp) = ImGui::checkbox_ret("Receiving Contact", receiving_contact);
			receiving_contact = receiving_contact_temp;
			if changed {
				disk.set_receiving_contact(receiving_contact);
				lb.set_text("");
			}
		});
		false
	}));
}