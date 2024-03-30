extern "C" {
	fn ease_func(easing: i32, time: f32) -> f32;
}
/// A struct that defines a set of easing functions for use in animations.
pub struct Ease { }
impl Ease {
	/// Applies an easing function to a given value over a given amount of time.
	///
	/// # Arguments
	///
	/// * `easing` - The easing function to apply.
	/// * `time` - The amount of time to apply the easing function over, should be between 0 and 1.
	///
	/// # Returns
	///
	/// * `f32` - The result of applying the easing function to the value.
	pub fn func(easing: crate::dora::EaseType, time: f32) -> f32 {
		unsafe { return ease_func(easing as i32, time); }
	}
}