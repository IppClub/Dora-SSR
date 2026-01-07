/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn model_type() -> i32;
	fn model_get_duration(slf: i64) -> f32;
	fn model_set_reversed(slf: i64, val: i32);
	fn model_is_reversed(slf: i64) -> i32;
	fn model_is_playing(slf: i64) -> i32;
	fn model_is_paused(slf: i64) -> i32;
	fn model_has_animation(slf: i64, name: i64) -> i32;
	fn model_pause(slf: i64);
	fn model_resume(slf: i64);
	fn model_resume_animation(slf: i64, name: i64, looping: i32);
	fn model_reset(slf: i64);
	fn model_update_to(slf: i64, elapsed: f32, reversed: i32);
	fn model_get_node_by_name(slf: i64, name: i64) -> i64;
	fn model_each_node(slf: i64, func0: i32, stack0: i64) -> i32;
	fn model_new(filename: i64) -> i64;
	fn model_dummy() -> i64;
	fn model_get_clip_file(filename: i64) -> i64;
	fn model_get_looks(filename: i64) -> i64;
	fn model_get_animations(filename: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::IPlayable;
impl IPlayable for Model { }
use crate::dora::INode;
impl INode for Model { }
/// Another implementation of the 'Playable' animation interface.
pub struct Model { raw: i64 }
crate::dora_object!(Model);
impl Model {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { model_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Model { raw: raw }))
			}
		})
	}
	/// Gets the duration of the current animation.
	pub fn get_duration(&self) -> f32 {
		return unsafe { model_get_duration(self.raw()) };
	}
	/// Sets whether the animation model will be played in reverse.
	pub fn set_reversed(&mut self, val: bool) {
		unsafe { model_set_reversed(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the animation model will be played in reverse.
	pub fn is_reversed(&self) -> bool {
		return unsafe { model_is_reversed(self.raw()) != 0 };
	}
	/// Gets whether the animation model is currently playing.
	pub fn is_playing(&self) -> bool {
		return unsafe { model_is_playing(self.raw()) != 0 };
	}
	/// Gets whether the animation model is currently paused.
	pub fn is_paused(&self) -> bool {
		return unsafe { model_is_paused(self.raw()) != 0 };
	}
	/// Checks if an animation exists in the model.
	///
	/// # Arguments
	///
	/// * `name` - The name of the animation to check.
	///
	/// # Returns
	///
	/// * `bool` - Whether the animation exists in the model or not.
	pub fn has_animation(&mut self, name: &str) -> bool {
		unsafe { return model_has_animation(self.raw(), crate::dora::from_string(name)) != 0; }
	}
	/// Pauses the currently playing animation.
	pub fn pause(&mut self) {
		unsafe { model_pause(self.raw()); }
	}
	/// Resumes the currently paused animation,
	pub fn resume(&mut self) {
		unsafe { model_resume(self.raw()); }
	}
	/// Resumes the currently paused animation, or plays a new animation if specified.
	///
	/// # Arguments
	///
	/// * `name` - The name of the animation to play.
	/// * `loop` - Whether to loop the animation or not.
	pub fn resume_animation(&mut self, name: &str, looping: bool) {
		unsafe { model_resume_animation(self.raw(), crate::dora::from_string(name), if looping { 1 } else { 0 }); }
	}
	/// Resets the current animation to its initial state.
	pub fn reset(&mut self) {
		unsafe { model_reset(self.raw()); }
	}
	/// Updates the animation to the specified time, and optionally in reverse.
	///
	/// # Arguments
	///
	/// * `elapsed` - The time to update to.
	/// * `reversed` - Whether to play the animation in reverse.
	pub fn update_to(&mut self, elapsed: f32, reversed: bool) {
		unsafe { model_update_to(self.raw(), elapsed, if reversed { 1 } else { 0 }); }
	}
	/// Gets the node with the specified name.
	///
	/// # Arguments
	///
	/// * `name` - The name of the node to get.
	///
	/// # Returns
	///
	/// * The node with the specified name.
	pub fn get_node_by_name(&mut self, name: &str) -> crate::dora::Node {
		unsafe { return crate::dora::Node::from(model_get_node_by_name(self.raw(), crate::dora::from_string(name))).unwrap(); }
	}
	/// Calls the specified function for each node in the model, and stops if the function returns `false`.
	///
	/// # Arguments
	///
	/// * `visitorFunc` - The function to call for each node.
	///
	/// # Returns
	///
	/// * `bool` - Whether the function was called for all nodes or not.
	pub fn each_node(&mut self, mut visitor_func: Box<dyn FnMut(&dyn crate::dora::INode) -> bool>) -> bool {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = visitor_func(&stack0.pop_cast::<crate::dora::Node>().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { return model_each_node(self.raw(), func_id0, stack_raw0) != 0; }
	}
	/// Creates a new instance of 'Model' from the specified model file.
	///
	/// # Arguments
	///
	/// * `filename` - The filename of the model file to load. Can be filename with or without extension like: "Model/item" or "Model/item.model".
	///
	/// # Returns
	///
	/// * A new instance of 'Model'.
	pub fn new(filename: &str) -> Option<Model> {
		unsafe { return Model::from(model_new(crate::dora::from_string(filename))); }
	}
	/// Returns a new dummy instance of 'Model' that can do nothing.
	///
	/// # Returns
	///
	/// * A new dummy instance of 'Model'.
	pub fn dummy() -> crate::dora::Model {
		unsafe { return crate::dora::Model::from(model_dummy()).unwrap(); }
	}
	/// Gets the clip file from the specified model file.
	///
	/// # Arguments
	///
	/// * `filename` - The filename of the model file to search.
	///
	/// # Returns
	///
	/// * A `String` representing the name of the clip file.
	pub fn get_clip_file(filename: &str) -> String {
		unsafe { return crate::dora::to_string(model_get_clip_file(crate::dora::from_string(filename))); }
	}
	/// Gets an array of look names from the specified model file.
	///
	/// # Arguments
	///
	/// * `filename` - The filename of the model file to search.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing an array of look names found in the model file.
	pub fn get_looks(filename: &str) -> Vec<String> {
		unsafe { return crate::dora::Vector::to_str(model_get_looks(crate::dora::from_string(filename))); }
	}
	/// Gets an array of animation names from the specified model file.
	///
	/// # Arguments
	///
	/// * `filename` - The filename of the model file to search.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing an array of animation names found in the model file.
	pub fn get_animations(filename: &str) -> Vec<String> {
		unsafe { return crate::dora::Vector::to_str(model_get_animations(crate::dora::from_string(filename))); }
	}
}