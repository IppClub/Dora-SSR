extern "C" {
	fn view_get_size() -> i64;
	fn view_get_standard_distance() -> f32;
	fn view_get_aspect_ratio() -> f32;
	fn view_set_near_plane_distance(var: f32);
	fn view_get_near_plane_distance() -> f32;
	fn view_set_far_plane_distance(var: f32);
	fn view_get_far_plane_distance() -> f32;
	fn view_set_field_of_view(var: f32);
	fn view_get_field_of_view() -> f32;
	fn view_set_scale(var: f32);
	fn view_get_scale() -> f32;
	fn view_set_post_effect(var: i64);
	fn view_get_post_effect() -> i64;
	fn view_set_vsync(var: i32);
	fn view_is_vsync() -> i32;
}
use crate::dora::Object;
pub struct View { }
impl View {
	pub fn get_size() -> crate::dora::Size {
		return unsafe { crate::dora::Size::from(view_get_size()) };
	}
	pub fn get_standard_distance() -> f32 {
		return unsafe { view_get_standard_distance() };
	}
	pub fn get_aspect_ratio() -> f32 {
		return unsafe { view_get_aspect_ratio() };
	}
	pub fn set_near_plane_distance(var: f32) {
		unsafe { view_set_near_plane_distance(var) };
	}
	pub fn get_near_plane_distance() -> f32 {
		return unsafe { view_get_near_plane_distance() };
	}
	pub fn set_far_plane_distance(var: f32) {
		unsafe { view_set_far_plane_distance(var) };
	}
	pub fn get_far_plane_distance() -> f32 {
		return unsafe { view_get_far_plane_distance() };
	}
	pub fn set_field_of_view(var: f32) {
		unsafe { view_set_field_of_view(var) };
	}
	pub fn get_field_of_view() -> f32 {
		return unsafe { view_get_field_of_view() };
	}
	pub fn set_scale(var: f32) {
		unsafe { view_set_scale(var) };
	}
	pub fn get_scale() -> f32 {
		return unsafe { view_get_scale() };
	}
	pub fn set_post_effect(var: &crate::dora::SpriteEffect) {
		unsafe { view_set_post_effect(var.raw()) };
	}
	pub fn get_post_effect() -> Option<crate::dora::SpriteEffect> {
		return unsafe { crate::dora::SpriteEffect::from(view_get_post_effect()) };
	}
	pub fn set_vsync(var: bool) {
		unsafe { view_set_vsync(if var { 1 } else { 0 }) };
	}
	pub fn is_vsync() -> bool {
		return unsafe { view_is_vsync() != 0 };
	}
}