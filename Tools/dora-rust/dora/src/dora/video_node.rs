/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn videonode_type() -> i32;
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
	/// Creates a new VideoNode object for playing a video.
	///
	/// # Arguments
	///
	/// * `filename` - The path to the video file. It should be a valid video file path with `.h264` suffix.
	///     H.264 format requirements:
	///       - Video codec: H.264 / AVC only (no H.265/HEVC, VP9, AV1, etc.).
	///       - Bitstream format: Annex-B byte stream is required (NAL units separated by 0x000001 / 0x00000001 start codes).
	///         MP4/FLV-style AVCC (length-prefixed NAL units) is NOT supported unless converted to Annex-B beforehand.
	///       - Stream type: video-only elementary stream is recommended. Audio tracks (if any) are ignored.
	///       - Profile/level constraints (recommended for maximum compatibility and performance):
	///           * Baseline / Constrained Baseline profile is recommended.
	///           * Progressive frames only (no interlaced/field-coded content).
	///           * No B-frames is recommended (e.g., baseline) to avoid output reordering costs.
	///       - Color format: YUV 4:2:0 (8-bit) is recommended; other chroma formats may be unsupported.
	///       - Frame rate: Constant frame rate (CFR) is recommended. Variable frame rate streams may play with unstable timing.
	///       - Resolution/performance notes:
	///           * 4K and high-bitrate streams may be CPU intensive for software decoding.
	///           * For smooth playback on mid-range devices, 720p/1080p and moderate bitrates are recommended.
	///       - It is recommended to use the `ffmpeg` tool to convert the video file to H.264 format before using it.
	/// * `looped` - (optional) Whether the video should loop. Default is false.
	///
	/// # Returns
	///
	/// * `VideoNode` - The created VideoNode instance. Returns `nil` if creation fails.
	pub fn new(filename: &str, looped: bool) -> Option<VideoNode> {
		unsafe { return VideoNode::from(videonode_new(crate::dora::from_string(filename), if looped { 1 } else { 0 })); }
	}
}