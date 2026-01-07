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
		public static extern int32_t platformer_visual_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_visual_is_playing(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_visual_start(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_visual_stop(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_visual_auto_remove(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_visual_new(int64_t name);
	}
} // namespace Dora

namespace Dora.Platformer
{
	/// <summary>
	/// A struct represents a visual effect object like Particle, Frame Animation or just a Sprite.
	/// </summary>
	public partial class Visual : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.platformer_visual_type(), From);
		}
		protected Visual(long raw) : base(raw) { }
		internal static new Visual From(long raw)
		{
			return new Visual(raw);
		}
		internal static new Visual? FromOpt(long raw)
		{
			return raw == 0 ? null : new Visual(raw);
		}
		/// <summary>
		/// Whether the visual effect is currently playing or not.
		/// </summary>
		public bool IsPlaying
		{
			get => Native.platformer_visual_is_playing(Raw) != 0;
		}
		/// <summary>
		/// Starts playing the visual effect.
		/// </summary>
		public void Start()
		{
			Native.platformer_visual_start(Raw);
		}
		/// <summary>
		/// Stops playing the visual effect.
		/// </summary>
		public void Stop()
		{
			Native.platformer_visual_stop(Raw);
		}
		/// <summary>
		/// Automatically removes the visual effect from the game world when it finishes playing.
		/// </summary>
		/// <returns>The same `Visual` object that was passed in as a parameter.</returns>
		public Platformer.Visual AutoRemove()
		{
			return Platformer.Visual.From(Native.platformer_visual_auto_remove(Raw));
		}
		/// <summary>
		/// Creates a new `Visual` object with the specified name.
		/// </summary>
		/// <param name="name">The name of the new `Visual` object. Could be a particle file, a frame animation file or an image file.</param>
		/// <returns>The new `Visual` object.</returns>
		public Visual(string name) : this(Native.platformer_visual_new(Bridge.FromString(name))) { }
	}
} // namespace Dora.Platformer
