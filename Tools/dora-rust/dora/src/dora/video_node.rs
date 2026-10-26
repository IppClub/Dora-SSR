/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn videonode_type() -> i32;
	fn videonode_play(slf: i64);
	fn videonode_seek(slf: i64, seconds: f64);
	fn videonode_rewind(slf: i64);
	fn videonode_get_current_time(slf: i64) -> f64;
	fn videonode_get_duration(slf: i64) -> f64;
	fn videonode_is_playing(slf: i64) -> i32;
	fn videonode_pause(slf: i64);
	fn videonode_resume(slf: i64);
	fn videonode_is_paused(slf: i64) -> i32;
	fn videonode_new(filename: i64, looped: i32) -> i64;
}
use crate::dora::IObject;
use crate::dora::ISprite;
impl ISprite for VideoNode { }
use crate::dora::INode;
impl INode for VideoNode { }
pub struct VideoNode { raw: i64 }
crate::dora_object!(VideoNode);
impl VideoNode {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { videonode_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(VideoNode { raw: raw }))
			}
		})
	}
	/// Starts or resumes playback; restarts from zero after the end.
	pub fn play(&mut self) {
		unsafe { videonode_play(self.raw()); }
	}
	/// Seeks both tracks in seconds, clamped to the duration. Preserves pause; non-finite values are ignored.
	pub fn seek(&mut self, seconds: f64) {
		unsafe { videonode_seek(self.raw(), seconds); }
	}
	/// Seeks to zero while preserving the paused state.
	pub fn rewind(&mut self) {
		unsafe { videonode_rewind(self.raw()); }
	}
	/// Gets Current playback position in seconds, including while paused or ended.
	pub fn get_current_time(&self) -> f64 {
		return unsafe { videonode_get_current_time(self.raw()) };
	}
	/// Gets Total playback duration in seconds, the longer of the video and audio tracks.
	pub fn get_duration(&self) -> f64 {
		return unsafe { videonode_get_duration(self.raw()) };
	}
	/// Gets Whether playback is requested in the running scene and has not paused or ended. Includes buffering.
	pub fn is_playing(&self) -> bool {
		return unsafe { videonode_is_playing(self.raw()) != 0 };
	}
	/// Pauses the video and embedded audio playback.
	pub fn pause(&mut self) {
		unsafe { videonode_pause(self.raw()); }
	}
	/// Resumes both tracks; restarts from zero after the end.
	pub fn resume(&mut self) {
		unsafe { videonode_resume(self.raw()); }
	}
	/// Gets Whether the video is currently paused.
	pub fn is_paused(&self) -> bool {
		return unsafe { videonode_is_paused(self.raw()) != 0 };
	}
	/// Creates a new VideoNode object for playing a video.
	///
	/// # Arguments
	///
	/// * `filename` - The path to an Ogg (`.ogv`) file containing a Theora video stream. VideoNode reads it through Dora Content, decodes Theora 4:2:0/4:2:2/4:4:4 in software, and automatically plays an embedded Vorbis track with synchronized pause, resume, and looping.
	/// * `looped` - (optional) Whether the video should loop. Default is false.
	///
	/// # Returns
	///
	/// * `VideoNode` - The created VideoNode instance. Returns `nil` if creation fails.
	pub fn new(filename: &str, looped: bool) -> Option<VideoNode> {
		unsafe { return VideoNode::from(videonode_new(crate::dora::from_string(filename), if looped { 1 } else { 0 })); }
	}
}