use dora_ssr::*;

pub fn test() {
	let mut node = Node::new();
	node.slot("Enter", Box::new(|_| {
		p!("on enter event");
	}));
	node.slot("Exit", Box::new(|_| {
		p!("on exit event");
	}));
	node.slot("Cleanup", Box::new(|_| {
		p!("on node destoyed event");
	}));
	node.schedule(once(move |mut co| async move {
		for i in (1..=5).rev() {
			p!("{}", i);
			sleep!(co, 1.0);
		}
		p!("Hello World!");
	}));

	let mut imgui_node = Node::new();
	let windows_flags = vec!["NoDecoration", "AlwaysAutoResize", "NoSavedSettings", "NoFocusOnAppearing", "NoNav", "NoMove"];
	imgui_node.schedule(Box::new(move |_| {
		let width = App::get_visual_size().width;
		ImGui::set_next_window_bg_alpha(0.35);
		ImGui::set_next_window_pos(&Vec2::new(width - 10.0, 10.0), "Always", &Vec2::new(1.0, 0.0));
		ImGui::set_next_window_size_with_cond(&Vec2::new(240.0, 0.0), "FirstUseEver");
		if ImGui::begin_opts("Hello World", &windows_flags) {
			ImGui::text("Hello World");
			ImGui::separator();
			ImGui::text_wrapped("Basic Dora schedule and signal function usage. Written in Yuescript. View outputs in log window!");
			ImGui::end();
		}
		return false;
	}));
}