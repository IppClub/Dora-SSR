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
		public static extern int32_t movejoint_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void movejoint_set_position(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t movejoint_get_position(int64_t self);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A type of joint that allows a physics body to move to a specific position.
	/// </summary>
	public partial class MoveJoint : Joint
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.movejoint_type(), From);
		}
		protected MoveJoint(long raw) : base(raw) { }
		internal static new MoveJoint From(long raw)
		{
			return new MoveJoint(raw);
		}
		internal static new MoveJoint? FromOpt(long raw)
		{
			return raw == 0 ? null : new MoveJoint(raw);
		}
		/// <summary>
		/// The current position of the move joint in the game world.
		/// </summary>
		public Vec2 Position
		{
			set => Native.movejoint_set_position(Raw, value.Raw);
			get => Vec2.From(Native.movejoint_get_position(Raw));
		}
	}
} // namespace Dora
