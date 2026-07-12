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
		public static extern int32_t view3d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t view3d_get_scene(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t view3d_get_stats(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view3d_set_show_a_a_b_b(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t view3d_is_show_a_a_b_b(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view3d_add_child_3d(int64_t self, int64_t child);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t view3d_get_ray_origin(int64_t self, int64_t viewPoint);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t view3d_get_ray_direction(int64_t self, int64_t viewPoint);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t view3d_pick(int64_t self, int64_t viewPoint);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t view3d_set_environment_map(int64_t self, int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view3d_set_environment_intensity(int64_t self, float diffuse, float specular, float exposure);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t view3d_new();
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A 2D scene node that owns a 3D scene tree.
	/// </summary>
	public partial class View3D : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.view3d_type(), From);
		}
		protected View3D(long raw) : base(raw) { }
		internal static new View3D From(long raw)
		{
			return new View3D(raw);
		}
		internal static new View3D? FromOpt(long raw)
		{
			return raw == 0 ? null : new View3D(raw);
		}
		/// <summary>
		/// The root 3D scene node.
		/// </summary>
		public Node3D Scene
		{
			get => Node3D.From(Native.view3d_get_scene(Raw));
		}
		/// <summary>
		/// Statistics from the most recent 3D render and current 3D registries.
		/// </summary>
		public RenderStats3D Stats
		{
			get => Dora.RenderStats3D.From(Native.view3d_get_stats(Raw));
		}
		/// <summary>
		/// Whether current world AABBs are drawn for debugging.
		/// </summary>
		public bool IsShowAABB
		{
			set => Native.view3d_set_show_a_a_b_b(Raw, value ? 1 : 0);
			get => Native.view3d_is_show_a_a_b_b(Raw) != 0;
		}
		/// <summary>
		/// Adds a 3D child node to the scene root.
		/// </summary>
		public void AddChild(Node3D child)
		{
			Native.view3d_add_child_3d(Raw, child.Raw);
		}
		/// <summary>Gets the world-space origin of the screen ray for a SharedView logical coordinate.</summary>
		public Vec3 GetRayOrigin(Vec2 viewPoint)
		{
			return Vec3.From(Native.view3d_get_ray_origin(Raw, viewPoint.Raw));
		}
		/// <summary>Gets the normalized world-space direction of the screen ray.</summary>
		public Vec3 GetRayDirection(Vec2 viewPoint)
		{
			return Vec3.From(Native.view3d_get_ray_direction(Raw, viewPoint.Raw));
		}
		/// <summary>Returns the nearest Model3D whose current world AABB intersects the screen ray.</summary>
		public Model3D? Pick(Vec2 viewPoint)
		{
			return Model3D.FromOpt(Native.view3d_pick(Raw, viewPoint.Raw));
		}
		/// <summary>
		/// Sets the environment map used by this 3D view.
		/// </summary>
		public bool SetEnvironmentMap(string path)
		{
			return Native.view3d_set_environment_map(Raw, Bridge.FromString(path)) != 0;
		}
		/// <summary>
		/// Sets the environment lighting intensity used by this 3D view.
		/// </summary>
		public void SetEnvironmentIntensity(float diffuse, float specular, float exposure = 1.0f)
		{
			Native.view3d_set_environment_intensity(Raw, diffuse, specular, exposure);
		}
		/// <summary>
		/// Creates a new 3D view node.
		/// </summary>
		public View3D() : this(Native.view3d_new()) { }
	}
} // namespace Dora
