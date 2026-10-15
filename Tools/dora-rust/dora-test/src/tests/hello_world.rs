/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

use dora_ssr::*;

pub fn test() {
	let mut node = Node::new();
	Slot::on_enter(&mut node, || {
		p!("on enter event");
	});
	Slot::on_exit(&mut node, || {
		p!("on exit event");
	});
	Slot::on_cleanup(&mut node, || {
		p!("on node destoyed event");
	});
	node.schedule(once(move |mut co| async move {
		for i in (1..=5).rev() {
			p!("{}", i);
			sleep!(co, 1.0);
		}
		p!("Hello World!");
	}));

	let mut imgui_node = Node::new();
	let windows_flags =
		ImGuiWindowFlag::NO_DECORATION |
		ImGuiWindowFlag::AlwaysAutoResize |
		ImGuiWindowFlag::NoSavedSettings |
		ImGuiWindowFlag::NoFocusOnAppearing |
		ImGuiWindowFlag::NO_NAV |
		ImGuiWindowFlag::NoMove;
	imgui_node.schedule(Box::new(move |_| {
		let width = App::get_visual_size().width;
		ImGui::set_next_window_bg_alpha(0.35);
		ImGui::set_next_window_pos_opts(&Vec2::new(width - 10.0, 10.0), ImGuiCond::Always, &Vec2::new(1.0, 0.0));
		ImGui::set_next_window_size_opts(&Vec2::new(240.0, 0.0), ImGuiCond::FirstUseEver);
		ImGui::begin_opts("Hello World", windows_flags, || {
			ImGui::text("Hello World (Rust)");
			ImGui::separator();
			ImGui::text_wrapped("Basic Dora schedule and signal function usage. View outputs in log window!");
		});
		false
	}));
}