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
		public static extern int32_t bodydef3d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef3d_set_type(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t bodydef3d_get_type(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef3d_set_collision_layer(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t bodydef3d_get_collision_layer(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef3d_set_collision_mask(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t bodydef3d_get_collision_mask(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef3d_set_sensor(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t bodydef3d_is_sensor(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t bodydef3d_attach(int64_t self, int64_t fixture, int64_t position, int64_t angles);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef3d_new();
	}
} // namespace Dora

namespace Dora
{
	/// <summary>Reusable physical properties and fixtures used to create Body3D nodes.</summary>
	public partial class BodyDef3D : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.bodydef3d_type(), From);
		}
		protected BodyDef3D(long raw) : base(raw) { }
		internal static new BodyDef3D From(long raw)
		{
			return new BodyDef3D(raw);
		}
		internal static new BodyDef3D? FromOpt(long raw)
		{
			return raw == 0 ? null : new BodyDef3D(raw);
		}
		public int Type
		{
			set => Native.bodydef3d_set_type(Raw, value);
			get => Native.bodydef3d_get_type(Raw);
		}
		public int CollisionLayer
		{
			set => Native.bodydef3d_set_collision_layer(Raw, value);
			get => Native.bodydef3d_get_collision_layer(Raw);
		}
		public int CollisionMask
		{
			set => Native.bodydef3d_set_collision_mask(Raw, value);
			get => Native.bodydef3d_get_collision_mask(Raw);
		}
		public bool IsSensor
		{
			set => Native.bodydef3d_set_sensor(Raw, value ? 1 : 0);
			get => Native.bodydef3d_is_sensor(Raw) != 0;
		}
		public bool Attach(FixtureDef3D fixture, Vec3 position, Vec3 angles)
		{
			return Native.bodydef3d_attach(Raw, fixture.Raw, position.Raw, angles.Raw) != 0;
		}
		public BodyDef3D() : this(Native.bodydef3d_new()) { }
	}
} // namespace Dora
