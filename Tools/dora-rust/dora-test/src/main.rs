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
			ImGui::set_next_window_pos_opts(&Vec2::new(size.width / 2.0, size.height / 2.0), ImGuiCond::FirstUseEver, &Vec2::new(0.5, 0.5));
			ImGui::begin_opts("Rust Tests", ImGuiWindowFlag::NoSavedSettings.into(), || {
				let button_size = Vec2::new(200.0, 0.0);
				if ImGui::button("Hello World", &button_size) {
					all_clear();
					tests::hello_world::test();
				}
				if ImGui::button("Quick Start", &button_size) {
					all_clear();
					tests::quick_start::test();
				}
				if ImGui::button("Body", &button_size) {
					all_clear();
					tests::body::test();
				}
				if ImGui::button("Entity Move", &button_size) {
					all_clear();
					tests::entity_move::test();
				}
				if ImGui::button("SQLite", &button_size) {
					all_clear();
					tests::sqlite::test();
				}
				if ImGui::button("Contact", &button_size) {
					all_clear();
					tests::contact::test();
				}
				if ImGui::button("Sprite", &button_size) {
					all_clear();
					tests::sprite::test();
				}
				if ImGui::button("Model", &button_size) {
					all_clear();
					tests::model::test();
				}
				if ImGui::button("Render Target", &button_size) {
					all_clear();
					tests::rander_target::test();
				}
				if ImGui::button("Excel Test", &button_size) {
					all_clear();
					tests::excel_test::test();
				}
				if ImGui::button("Layout", &button_size) {
					all_clear();
					tests::layout::test();
				}
				if ImGui::button("VG Button", &button_size) {
					all_clear();
					tests::vg_button::test();
				}
			});
			co.waiter().await;
		}
	});
}
