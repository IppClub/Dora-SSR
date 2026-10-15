/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn videonode_type() -> i32;
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
	/// Pauses the video playback.
	pub fn pause(&mut self) {
		unsafe { videonode_pause(self.raw()); }
	}
	/// Resumes the video playback.
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
	/// * `filename` - The path to an Ogg (`.ogv`) file containing a Theora video stream. VideoNode reads it through Dora Content, renders video only, supports Theora 4:2:0/4:2:2/4:4:4, and decodes in software; play audio separately.
	/// * `looped` - (optional) Whether the video should loop. Default is false.
	///
	/// # Returns
	///
	/// * `VideoNode` - The created VideoNode instance. Returns `nil` if creation fails.
	pub fn new(filename: &str, looped: bool) -> Option<VideoNode> {
		unsafe { return VideoNode::from(videonode_new(crate::dora::from_string(filename), if looped { 1 } else { 0 })); }
	}
}