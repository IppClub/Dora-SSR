/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


using System.Runtime.InteropServices;
using int64_t = long;
using int32_t = int;

namespace Dora
{
	internal static partial class Native
	{
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t videonode_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t videonode_new(int64_t filename, int32_t looped);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A class that represents a video node.
	/// </summary>
	public partial class VideoNode : Sprite
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.videonode_type(), From);
		}
		protected VideoNode(long raw) : base(raw) { }
		internal static new VideoNode From(long raw)
		{
			return new VideoNode(raw);
		}
		internal static new VideoNode? FromOpt(long raw)
		{
			return raw == 0 ? null : new VideoNode(raw);
		}
		/// <summary>
		/// Creates a new VideoNode object for playing a video.
		/// </summary>
		/// <param name="filename">
		/// The path to the video file. It should be a valid video file path with `.h264` suffix.
		/// <para>
		/// <b>H.264 format requirements:</b><br/>
		/// - Video codec: H.264 / AVC only (no H.265/HEVC, VP9, AV1, etc.).<br/>
		/// - Bitstream format: Annex-B byte stream is required (NAL units separated by 0x000001 / 0x00000001 start codes).<br/>
		///   MP4/FLV-style AVCC (length-prefixed NAL units) is NOT supported unless converted to Annex-B beforehand.<br/>
		/// - Stream type: video-only elementary stream is recommended. Audio tracks (if any) are ignored.<br/>
		/// - Profile/level constraints (recommended for maximum compatibility and performance):<br/>
		///   &nbsp;&nbsp;* Baseline / Constrained Baseline profile is recommended.<br/>
		///   &nbsp;&nbsp;* Progressive frames only (no interlaced/field-coded content).<br/>
		///   &nbsp;&nbsp;* No B-frames is recommended (e.g., baseline) to avoid output reordering costs.<br/>
		/// - Color format: YUV 4:2:0 (8-bit) is recommended; other chroma formats may be unsupported.<br/>
		/// - Frame rate: Constant frame rate (CFR) is recommended. Variable frame rate streams may play with unstable timing.<br/>
		/// - Resolution/performance notes:<br/>
		///   &nbsp;&nbsp;* 4K and high-bitrate streams may be CPU intensive for software decoding.<br/>
		///   &nbsp;&nbsp;* For smooth playback on mid-range devices, 720p/1080p and moderate bitrates are recommended.<br/>
		/// - It is recommended to use the `ffmpeg` tool to convert the video file to H.264 format before using it.<br/>
		/// </para>
		/// </param>
		/// <param name="looped">
		/// (Optional) Whether the video should loop. Default is false.
		/// </param>
		/// <returns>
		/// The created VideoNode instance.
		/// </returns>
		public VideoNode(string filename, bool looped = false) : this(Native.videonode_new(Bridge.FromString(filename), looped ? 1 : 0)) { }
		public static VideoNode? TryCreate(string filename, bool looped = false)
		{
			var raw = Native.videonode_new(Bridge.FromString(filename), looped ? 1 : 0);
			return raw == 0 ? null : new VideoNode(raw);
		}
	}
} // namespace Dora
