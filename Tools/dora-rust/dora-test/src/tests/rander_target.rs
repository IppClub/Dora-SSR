/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

use dora_ssr::*;

pub fn test() {
	let root = Node::new();
	let mut node = Node::new();
	node.set_order(1);
	node.add_to(&root);
	let mut spine = match Spine::new("Spine/moling") {
		Some(spine) => spine,
		None => return,
	};
	spine.add_to(&node);
	spine.set_y(-200.0);
	spine.set_scale_x(1.2);
	spine.set_scale_y(1.2);
	spine.set_fliped(false);
	spine.play("fmove", true);
	spine.run_action_def(
		ActionDef::sequence(&vec![
			ActionDef::prop(2.0, -150.0, 250.0, Property::X, EaseType::Linear),
			ActionDef::event("Turn", ""),
			ActionDef::prop(2.0, 250.0, -150.0, Property::X, EaseType::Linear),
			ActionDef::event("Turn", "")
		]), true);
	let mut spine_clone = spine.clone();
	spine.slot("Turn", Box::new(move |_| {
		spine_clone.set_fliped(!spine_clone.is_fliped());
	}));
	let mut render_target = RenderTarget::new(300, 400);
	render_target.render_clear(&Color::new(0xff8a8a8a), 1.0, 0);
	let mut surface = Sprite::with_texture(&render_target.get_texture()).add_to(&root);
	surface.set_z(300.0);
	surface.set_angle_y(25.0);
	surface.add_child(&Line::with_vec_color(&vec![
		Vec2::zero(),
		Vec2::new(300.0, 0.0),
		Vec2::new(300.0, 400.0),
		Vec2::new(0.0, 400.0),
		Vec2::zero()
	], &App::get_theme_color()));
	let mut node_clone = node.clone();
	surface.schedule(Box::new(move |_| {
		node_clone.set_y(200.0);
		render_target.render_clear_with_target(&node_clone, &Color::new(0xff8a8a8a), 1.0, 0);
		node_clone.set_y(0.0);
		false
	}));
	let window_flags =
		ImGuiWindowFlag::NO_DECORATION |
		ImGuiWindowFlag::AlwaysAutoResize |
		ImGuiWindowFlag::NoSavedSettings |
		ImGuiWindowFlag::NoFocusOnAppearing |
		ImGuiWindowFlag::NO_NAV |
		ImGuiWindowFlag::NoMove;
	let mut imgui_node = Node::new();
	imgui_node.schedule(Box::new(move |_| {
		let size = App::get_visual_size();
		ImGui::set_next_window_bg_alpha(0.35);
		ImGui::set_next_window_pos_opts(&Vec2::new(size.width - 10.0, 10.0), ImGuiCond::Always, &Vec2::new(1.0, 0.0));
		ImGui::set_next_window_size_opts(&Vec2::new(240.0, 0.0), ImGuiCond::FirstUseEver);
		ImGui::begin_opts("Render Target", window_flags, || {
			ImGui::text("Render Target (Rust)");
			ImGui::separator();
			ImGui::text_wrapped("Use render target node as a mirror!");
		});
		false
	}));
}