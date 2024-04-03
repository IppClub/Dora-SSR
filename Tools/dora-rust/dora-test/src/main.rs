use dora_ssr::*;

mod tests;

fn all_clear() {
	Director::cleanup();
	Cache::unload();
	Entity::clear();
	platformer::Data::clear();
	platformer::UnitAction::clear();
}

fn main() {
	thread(move |mut co| async move {
		loop {
			let size = App::get_visual_size();
			ImGui::set_next_window_pos(&Vec2::new(size.width / 2.0, size.height / 2.0), "FirstUseEver", &Vec2::new(0.5, 0.5));
			if ImGui::begin_opts("Rust Tests", &vec!["AlwaysAutoResize"]) {
				if ImGui::button("Hello World", &Vec2::zero()) {
					all_clear();
					tests::hello_world::test();
				}
				ImGui::end();
			}
			co.waiter().await;
		}
	});
}
