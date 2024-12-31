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