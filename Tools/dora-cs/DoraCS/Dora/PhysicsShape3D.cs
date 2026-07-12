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
		public static extern int32_t physicsshape3d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t physicsshape3d_is_built(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t physicsshape3d_add_child(int64_t self, int64_t shape, int64_t position, int64_t eulerAngles);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t physicsshape3d_build(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsshape3d_with_box(int64_t halfExtent);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsshape3d_with_sphere(float radius);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsshape3d_with_capsule(float halfHeight, float radius);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsshape3d_with_compound();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void physicsshape3d_load_mesh_async(int64_t filename, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void physicsshape3d_load_convex_hull_async(int64_t filename, int32_t func0, int64_t stack0);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>A reusable immutable Jolt collision shape or a compound shape builder.</summary>
	public partial class PhysicsShape3D : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.physicsshape3d_type(), From);
		}
		protected PhysicsShape3D(long raw) : base(raw) { }
		internal static new PhysicsShape3D From(long raw)
		{
			return new PhysicsShape3D(raw);
		}
		internal static new PhysicsShape3D? FromOpt(long raw)
		{
			return raw == 0 ? null : new PhysicsShape3D(raw);
		}
		/// <summary>Whether this shape can be used to create bodies.</summary>
		public bool IsBuilt
		{
			get => Native.physicsshape3d_is_built(Raw) != 0;
		}
		/// <summary>Adds a child to an unbuilt compound shape using local position and XYZ Euler angles in degrees.</summary>
		public bool AddChild(PhysicsShape3D shape, Vec3 position, Vec3 eulerAngles)
		{
			return Native.physicsshape3d_add_child(Raw, shape.Raw, position.Raw, eulerAngles.Raw) != 0;
		}
		/// <summary>Freezes a compound shape. A built shape cannot be modified.</summary>
		public bool Build()
		{
			return Native.physicsshape3d_build(Raw) != 0;
		}
		/// <summary>Creates a box shape using half extents.</summary>
		public PhysicsShape3D(Vec3 halfExtent) : this(Native.physicsshape3d_with_box(halfExtent.Raw)) { }
		/// <summary>Creates a sphere shape.</summary>
		public PhysicsShape3D(float radius) : this(Native.physicsshape3d_with_sphere(radius)) { }
		/// <summary>Creates a capsule shape.</summary>
		public PhysicsShape3D(float halfHeight, float radius) : this(Native.physicsshape3d_with_capsule(halfHeight, radius)) { }
		/// <summary>Creates an empty compound shape builder.</summary>
		public PhysicsShape3D() : this(Native.physicsshape3d_with_compound()) { }
		/// <summary>Loads and cooks a static triangle mesh shape through Content asynchronously.</summary>
		public static void LoadMeshAsync(string filename, System.Action<PhysicsShape3D> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				handler((PhysicsShape3D)stack0.PopObject());
			});
			Native.physicsshape3d_load_mesh_async(Bridge.FromString(filename), func_id0, stack_raw0);
		}
		/// <summary>Loads model vertices through Content asynchronously and cooks a convex hull suitable for dynamic bodies.</summary>
		public static void LoadConvexHullAsync(string filename, System.Action<PhysicsShape3D> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				handler((PhysicsShape3D)stack0.PopObject());
			});
			Native.physicsshape3d_load_convex_hull_async(Bridge.FromString(filename), func_id0, stack_raw0);
		}
	}
} // namespace Dora
