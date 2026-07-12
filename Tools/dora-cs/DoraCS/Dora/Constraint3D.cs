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
		public static extern int32_t constraint3d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t constraint3d_get_world(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t constraint3d_get_first_body(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t constraint3d_get_second_body(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void constraint3d_destroy(int64_t self);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>A two-body constraint owned by a PhysicsWorld3D.</summary>
	public partial class Constraint3D : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.constraint3d_type(), From);
		}
		protected Constraint3D(long raw) : base(raw) { }
		internal static new Constraint3D From(long raw)
		{
			return new Constraint3D(raw);
		}
		internal static new Constraint3D? FromOpt(long raw)
		{
			return raw == 0 ? null : new Constraint3D(raw);
		}
		/// <summary>The physics world that owns this constraint.</summary>
		public PhysicsWorld3D? World
		{
			get => PhysicsWorld3D.FromOpt(Native.constraint3d_get_world(Raw));
		}
		/// <summary>The first constrained body.</summary>
		public Body3D? FirstBody
		{
			get => Body3D.FromOpt(Native.constraint3d_get_first_body(Raw));
		}
		/// <summary>The second constrained body.</summary>
		public Body3D? SecondBody
		{
			get => Body3D.FromOpt(Native.constraint3d_get_second_body(Raw));
		}
		/// <summary>Removes this constraint from its physics world.</summary>
		public void Destroy()
		{
			Native.constraint3d_destroy(Raw);
		}
	}
} // namespace Dora
