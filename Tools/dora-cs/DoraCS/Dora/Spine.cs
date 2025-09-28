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
		public static extern int32_t spine_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void spine_set_hit_test_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t spine_is_hit_test_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t spine_set_bone_rotation(int64_t self, int64_t name, float rotation);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_contains_point(int64_t self, float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_intersects_segment(int64_t self, float x_1, float y_1, float x_2, float y_2);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_with_files(int64_t skel_file, int64_t atlas_file);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_new(int64_t spine_str);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_get_looks(int64_t spine_str);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_get_animations(int64_t spine_str);
	}
} // namespace Dora

namespace Dora
{
	/// An implementation of an animation system using the Spine engine.
	public partial class Spine : Playable
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.spine_type(), From);
		}
		protected Spine(long raw) : base(raw) { }
		internal static new Spine From(long raw)
		{
			return new Spine(raw);
		}
		internal static new Spine? FromOpt(long raw)
		{
			return raw == 0 ? null : new Spine(raw);
		}
		/// whether hit testing is enabled.
		public bool IsHitTestEnabled
		{
			set => Native.spine_set_hit_test_enabled(Raw, value ? 1 : 0);
			get => Native.spine_is_hit_test_enabled(Raw) != 0;
		}
		/// Sets the rotation of a bone in the Spine skeleton.
		///
		/// # Arguments
		///
		/// * `name` - The name of the bone to rotate.
		/// * `rotation` - The amount to rotate the bone, in degrees.
		///
		/// # Returns
		///
		/// * `bool` - Whether the rotation was successfully set or not.
		public bool SetBoneRotation(string name, float rotation)
		{
			return Native.spine_set_bone_rotation(Raw, Bridge.FromString(name), rotation) != 0;
		}
		/// Checks if a point in space is inside the boundaries of the Spine skeleton.
		///
		/// # Arguments
		///
		/// * `x` - The x-coordinate of the point to check.
		/// * `y` - The y-coordinate of the point to check.
		///
		/// # Returns
		///
		/// * `Option<String>` - The name of the bone at the point, or `None` if there is no bone at the point.
		public string ContainsPoint(float x, float y)
		{
			return Bridge.ToString(Native.spine_contains_point(Raw, x, y));
		}
		/// Checks if a line segment intersects the boundaries of the instance and returns the name of the bone or slot at the intersection point, or `None` if no bone or slot is found.
		///
		/// # Arguments
		///
		/// * `x1` - The x-coordinate of the start point of the line segment.
		/// * `y1` - The y-coordinate of the start point of the line segment.
		/// * `x2` - The x-coordinate of the end point of the line segment.
		/// * `y2` - The y-coordinate of the end point of the line segment.
		///
		/// # Returns
		///
		/// * `Option<String>` - The name of the bone or slot at the intersection point, or `None` if no bone or slot is found.
		public string IntersectsSegment(float x_1, float y_1, float x_2, float y_2)
		{
			return Bridge.ToString(Native.spine_intersects_segment(Raw, x_1, y_1, x_2, y_2));
		}
		/// Creates a new instance of 'Spine' using the specified skeleton file and atlas file.
		///
		/// # Arguments
		///
		/// * `skel_file` - The filename of the skeleton file to load.
		/// * `atlas_file` - The filename of the atlas file to load.
		///
		/// # Returns
		///
		/// * A new instance of 'Spine' with the specified skeleton file and atlas file. Returns `None` if the skeleton file or atlas file could not be loaded.
		public Spine(string skel_file, string atlas_file) : this(Native.spine_with_files(Bridge.FromString(skel_file), Bridge.FromString(atlas_file))) { }
		public static Spine? TryCreate(string skel_file, string atlas_file)
		{
			var raw = Native.spine_with_files(Bridge.FromString(skel_file), Bridge.FromString(atlas_file));
			return raw == 0 ? null : new Spine(raw);
		}
		/// Creates a new instance of 'Spine' using the specified Spine string.
		///
		/// # Arguments
		///
		/// * `spine_str` - The Spine file string for the new instance. A Spine file string can be a file path with the target file extension like "Spine/item" or file paths with all the related files like "Spine/item.skel|Spine/item.atlas" or "Spine/item.json|Spine/item.atlas".
		///
		/// # Returns
		///
		/// * A new instance of 'Spine'. Returns `None` if the Spine file could not be loaded.
		public Spine(string spine_str) : this(Native.spine_new(Bridge.FromString(spine_str))) { }
		public static new Spine? TryCreate(string spine_str)
		{
			var raw = Native.spine_new(Bridge.FromString(spine_str));
			return raw == 0 ? null : new Spine(raw);
		}
		/// Returns a list of available looks for the specified Spine2D file string.
		///
		/// # Arguments
		///
		/// * `spine_str` - The Spine2D file string to get the looks for.
		///
		/// # Returns
		///
		/// * A `Vec<String>` representing the available looks.
		public static string[] GetLooks(string spine_str)
		{
			return Bridge.ToStringArray(Native.spine_get_looks(Bridge.FromString(spine_str)));
		}
		/// Returns a list of available animations for the specified Spine2D file string.
		///
		/// # Arguments
		///
		/// * `spine_str` - The Spine2D file string to get the animations for.
		///
		/// # Returns
		///
		/// * A `Vec<String>` representing the available animations.
		public static string[] GetAnimations(string spine_str)
		{
			return Bridge.ToStringArray(Native.spine_get_animations(Bridge.FromString(spine_str)));
		}
	}
} // namespace Dora
