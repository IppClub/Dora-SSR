extern "C" {
	fn ease_func(easing: i32, time: f32) -> f32;
}
pub struct Ease { }
impl Ease {
	pub fn func(easing: crate::dora::EaseType, time: f32) -> f32 {
		return unsafe { ease_func(easing as i32, time) };
	}
}