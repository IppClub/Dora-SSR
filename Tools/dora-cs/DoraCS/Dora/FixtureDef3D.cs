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
		public static extern int32_t fixturedef3d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t fixturedef3d_is_built(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t fixturedef3d_add_child(int64_t self, int64_t fixture, int64_t position, int64_t angles);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t fixturedef3d_build(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t fixturedef3d_with_box(int64_t halfExtent);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t fixturedef3d_with_sphere(float radius);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t fixturedef3d_with_capsule(float halfHeight, float radius);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t fixturedef3d_with_compound();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void fixturedef3d_load_mesh_async(int64_t filename, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void fixturedef3d_load_convex_hull_async(int64_t filename, int32_t func0, int64_t stack0);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>A reusable Jolt collision fixture definition or compound fixture builder.</summary>
	public partial class FixtureDef3D : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.fixturedef3d_type(), From);
		}
		protected FixtureDef3D(long raw) : base(raw) { }
		internal static new FixtureDef3D From(long raw)
		{
			return new FixtureDef3D(raw);
		}
		internal static new FixtureDef3D? FromOpt(long raw)
		{
			return raw == 0 ? null : new FixtureDef3D(raw);
		}
		public bool IsBuilt
		{
			get => Native.fixturedef3d_is_built(Raw) != 0;
		}
		public bool AddChild(FixtureDef3D fixture, Vec3 position, Vec3 angles)
		{
			return Native.fixturedef3d_add_child(Raw, fixture.Raw, position.Raw, angles.Raw) != 0;
		}
		public bool Build()
		{
			return Native.fixturedef3d_build(Raw) != 0;
		}
		public FixtureDef3D(Vec3 halfExtent) : this(Native.fixturedef3d_with_box(halfExtent.Raw)) { }
		public FixtureDef3D(float radius) : this(Native.fixturedef3d_with_sphere(radius)) { }
		public FixtureDef3D(float halfHeight, float radius) : this(Native.fixturedef3d_with_capsule(halfHeight, radius)) { }
		public FixtureDef3D() : this(Native.fixturedef3d_with_compound()) { }
		public static void LoadMeshAsync(string filename, System.Action<FixtureDef3D> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				handler((FixtureDef3D)stack0.PopObject());
			});
			Native.fixturedef3d_load_mesh_async(Bridge.FromString(filename), func_id0, stack_raw0);
		}
		public static void LoadConvexHullAsync(string filename, System.Action<FixtureDef3D> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				handler((FixtureDef3D)stack0.PopObject());
			});
			Native.fixturedef3d_load_convex_hull_async(Bridge.FromString(filename), func_id0, stack_raw0);
		}
	}
} // namespace Dora
