/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

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
		public static extern void videonode_pause(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void videonode_resume(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t videonode_is_paused(int64_t self);
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
		/// Pauses the video playback.
		/// </summary>
		public void Pause()
		{
			Native.videonode_pause(Raw);
		}
		/// <summary>
		/// Resumes the video playback.
		/// </summary>
		public void Resume()
		{
			Native.videonode_resume(Raw);
		}
		/// <summary>
		/// Whether the video is currently paused.
		/// </summary>
		public bool IsPaused
		{
			get => Native.videonode_is_paused(Raw) != 0;
		}
		/// <summary>
		/// Creates a new VideoNode object for playing a video.
		/// </summary>
		/// <param name="filename">
		/// The path to an Ogg (`.ogv`) file containing a Theora video stream. VideoNode reads it through Dora Content, renders video only, supports Theora 4:2:0/4:2:2/4:4:4, and decodes in software; play audio separately.
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
