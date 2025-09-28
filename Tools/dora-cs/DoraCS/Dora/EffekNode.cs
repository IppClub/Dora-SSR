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
		public static extern int32_t effeknode_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t effeknode_play(int64_t self, int64_t filename, int64_t pos, float z);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void effeknode_stop(int64_t self, int32_t handle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t effeknode_new();
	}
} // namespace Dora

namespace Dora
{
	/// A struct for playing Effekseer effects.
	public partial class EffekNode : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.effeknode_type(), From);
		}
		protected EffekNode(long raw) : base(raw) { }
		internal static new EffekNode From(long raw)
		{
			return new EffekNode(raw);
		}
		internal static new EffekNode? FromOpt(long raw)
		{
			return raw == 0 ? null : new EffekNode(raw);
		}
		/// Plays an effect at the specified position.
		///
		/// # Arguments
		///
		/// * `filename` - The filename of the effect to play.
		/// * `pos` - The xy-position to play the effect at.
		/// * `z` - The z-position of the effect.
		///
		/// # Returns
		///
		/// * `int` - The handle of the effect.
		public int Play(string filename, Vec2 pos, float z)
		{
			return Native.effeknode_play(Raw, Bridge.FromString(filename), pos.Raw, z);
		}
		/// Stops an effect with the specified handle.
		///
		/// # Arguments
		///
		/// * `handle` - The handle of the effect to stop.
		public void Stop(int handle)
		{
			Native.effeknode_stop(Raw, handle);
		}
		/// Creates a new EffekNode object.
		///
		/// # Returns
		///
		/// * `EffekNode` - A new EffekNode object.
		public EffekNode() : this(Native.effeknode_new()) { }
	}
} // namespace Dora
