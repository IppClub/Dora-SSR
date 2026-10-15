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
		public static extern int32_t playable_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void playable_set_look(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t playable_get_look(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void playable_set_speed(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float playable_get_speed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void playable_set_recovery(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float playable_get_recovery(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void playable_set_fliped(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t playable_is_fliped(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t playable_get_current(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t playable_get_last_completed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t playable_get_key(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float playable_play(int64_t self, int64_t name, int32_t looping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void playable_stop(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void playable_set_slot(int64_t self, int64_t name, int64_t item);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t playable_get_slot(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t playable_new(int64_t filename);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// An interface for an animation model system.
	/// </summary>
	public partial class Playable : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.playable_type(), From);
		}
		protected Playable(long raw) : base(raw) { }
		internal static new Playable From(long raw)
		{
			return new Playable(raw);
		}
		internal static new Playable? FromOpt(long raw)
		{
			return raw == 0 ? null : new Playable(raw);
		}
		/// <summary>
		/// The look of the animation.
		/// </summary>
		public string Look
		{
			set => Native.playable_set_look(Raw, Bridge.FromString(value));
			get => Bridge.ToString(Native.playable_get_look(Raw));
		}
		/// <summary>
		/// The play speed of the animation.
		/// </summary>
		public float Speed
		{
			set => Native.playable_set_speed(Raw, value);
			get => Native.playable_get_speed(Raw);
		}
		/// <summary>
		/// The recovery time of the animation, in seconds.
		/// Used for doing transitions from one animation to another animation.
		/// </summary>
		public float Recovery
		{
			set => Native.playable_set_recovery(Raw, value);
			get => Native.playable_get_recovery(Raw);
		}
		/// <summary>
		/// Whether the animation is flipped horizontally.
		/// </summary>
		public bool IsFliped
		{
			set => Native.playable_set_fliped(Raw, value ? 1 : 0);
			get => Native.playable_is_fliped(Raw) != 0;
		}
		/// <summary>
		/// The current playing animation name.
		/// </summary>
		public string Current
		{
			get => Bridge.ToString(Native.playable_get_current(Raw));
		}
		/// <summary>
		/// The last completed animation name.
		/// </summary>
		public string LastCompleted
		{
			get => Bridge.ToString(Native.playable_get_last_completed(Raw));
		}
		/// <summary>
		/// Gets a key point on the animation model by its name.
		/// </summary>
		/// <param name="name">The name of the key point to get.</param>
		public Vec2 GetKey(string name)
		{
			return Vec2.From(Native.playable_get_key(Raw, Bridge.FromString(name)));
		}
		/// <summary>
		/// Plays an animation from the model.
		/// </summary>
		/// <param name="name">The name of the animation to play.</param>
		/// <param name="looping">Whether to loop the animation or not.</param>
		public float Play(string name, bool looping = false)
		{
			return Native.playable_play(Raw, Bridge.FromString(name), looping ? 1 : 0);
		}
		/// <summary>
		/// Stops the currently playing animation.
		/// </summary>
		public void Stop()
		{
			Native.playable_stop(Raw);
		}
		/// <summary>
		/// Attaches a child node to a slot on the animation model.
		/// </summary>
		/// <param name="name">The name of the slot to set.</param>
		/// <param name="item">The node to set the slot to.</param>
		public void SetSlot(string name, Node item)
		{
			Native.playable_set_slot(Raw, Bridge.FromString(name), item.Raw);
		}
		/// <summary>
		/// Gets the child node attached to the animation model.
		/// </summary>
		/// <param name="name">The name of the slot to get.</param>
		public Node? GetSlot(string name)
		{
			return Node.FromOpt(Native.playable_get_slot(Raw, Bridge.FromString(name)));
		}
		/// <summary>
		/// Creates a new instance of 'Playable' from the specified animation file.
		/// </summary>
		/// <param name="filename">The filename of the animation file to load. Supports DragonBone, Spine2D and Dora Model files.</param>
		public Playable(string filename) : this(Native.playable_new(Bridge.FromString(filename))) { }
		public static Playable? TryCreate(string filename)
		{
			var raw = Native.playable_new(Bridge.FromString(filename));
			return raw == 0 ? null : new Playable(raw);
		}
	}
} // namespace Dora
