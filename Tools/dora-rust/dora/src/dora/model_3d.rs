/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn model3d_type() -> i32;
	fn model3d_set_speed(slf: i64, val: f32);
	fn model3d_get_speed(slf: i64) -> f32;
	fn model3d_get_duration(slf: i64) -> f32;
	fn model3d_get_elapsed(slf: i64) -> f32;
	fn model3d_is_playing(slf: i64) -> i32;
	fn model3d_is_paused(slf: i64) -> i32;
	fn model3d_play(slf: i64, name: i64, looped: i32) -> f32;
	fn model3d_stop(slf: i64);
	fn model3d_pause(slf: i64);
	fn model3d_resume(slf: i64);
	fn model3d_new(path: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode3D;
impl INode3D for Model3D { }
/// A 3D model node loaded from a glTF/GLB file.
pub struct Model3D { raw: i64 }
crate::dora_object!(Model3D);
impl Model3D {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { model3d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Model3D { raw: raw }))
			}
		})
	}
	/// Sets the animation playback speed.
	pub fn set_speed(&mut self, val: f32) {
		unsafe { model3d_set_speed(self.raw(), val) };
	}
	/// Gets the animation playback speed.
	pub fn get_speed(&self) -> f32 {
		return unsafe { model3d_get_speed(self.raw()) };
	}
	/// Gets the current animation duration.
	pub fn get_duration(&self) -> f32 {
		return unsafe { model3d_get_duration(self.raw()) };
	}
	/// Gets the elapsed playback time.
	pub fn get_elapsed(&self) -> f32 {
		return unsafe { model3d_get_elapsed(self.raw()) };
	}
	/// Gets whether an animation is playing.
	pub fn is_playing(&self) -> bool {
		return unsafe { model3d_is_playing(self.raw()) != 0 };
	}
	/// Gets whether animation playback is paused.
	pub fn is_paused(&self) -> bool {
		return unsafe { model3d_is_paused(self.raw()) != 0 };
	}
	/// Plays an animation by name.
	pub fn play(&mut self, name: &str, looped: bool) -> f32 {
		unsafe { return model3d_play(self.raw(), crate::dora::from_string(name), if looped { 1 } else { 0 }); }
	}
	/// Stops animation playback.
	pub fn stop(&mut self) {
		unsafe { model3d_stop(self.raw()); }
	}
	/// Pauses animation playback.
	pub fn pause(&mut self) {
		unsafe { model3d_pause(self.raw()); }
	}
	/// Resumes animation playback.
	pub fn resume(&mut self) {
		unsafe { model3d_resume(self.raw()); }
	}
	/// Creates a model from a glTF/GLB file.
	pub fn new(path: &str) -> Option<Model3D> {
		unsafe { return Model3D::from(model3d_new(crate::dora::from_string(path))); }
	}
}