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
		public static extern int32_t dragonbone_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void dragonbone_set_hit_test_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t dragonbone_is_hit_test_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_contains_point(int64_t self, float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_intersects_segment(int64_t self, float x_1, float y_1, float x_2, float y_2);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_with_files(int64_t bone_file, int64_t atlas_file);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_new(int64_t bone_str);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_get_looks(int64_t bone_str);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_get_animations(int64_t bone_str);
	}
} // namespace Dora

namespace Dora
{
	/// An implementation of the 'Playable' record using the DragonBones animation system.
	public partial class DragonBone : Playable
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.dragonbone_type(), From);
		}
		protected DragonBone(long raw) : base(raw) { }
		internal static new DragonBone From(long raw)
		{
			return new DragonBone(raw);
		}
		internal static new DragonBone? FromOpt(long raw)
		{
			return raw == 0 ? null : new DragonBone(raw);
		}
		/// whether hit testing is enabled.
		public bool IsHitTestEnabled
		{
			set => Native.dragonbone_set_hit_test_enabled(Raw, value ? 1 : 0);
			get => Native.dragonbone_is_hit_test_enabled(Raw) != 0;
		}
		/// Checks if a point is inside the boundaries of the instance and returns the name of the bone or slot at that point, or `None` if no bone or slot is found.
		///
		/// # Arguments
		///
		/// * `x` - The x-coordinate of the point to check.
		/// * `y` - The y-coordinate of the point to check.
		///
		/// # Returns
		///
		/// * `String` - The name of the bone or slot at the point.
		public string ContainsPoint(float x, float y)
		{
			return Bridge.ToString(Native.dragonbone_contains_point(Raw, x, y));
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
		/// * `String` - The name of the bone or slot at the intersection point.
		public string IntersectsSegment(float x_1, float y_1, float x_2, float y_2)
		{
			return Bridge.ToString(Native.dragonbone_intersects_segment(Raw, x_1, y_1, x_2, y_2));
		}
		/// Creates a new instance of 'DragonBone' using the specified bone file and atlas file. This function only loads the first armature.
		///
		/// # Arguments
		///
		/// * `bone_file` - The filename of the bone file to load.
		/// * `atlas_file` - The filename of the atlas file to load.
		///
		/// # Returns
		///
		/// * A new instance of 'DragonBone' with the specified bone file and atlas file. Returns `None` if the bone file or atlas file is not found.
		public DragonBone(string bone_file, string atlas_file) : this(Native.dragonbone_with_files(Bridge.FromString(bone_file), Bridge.FromString(atlas_file))) { }
		public static DragonBone? TryCreate(string bone_file, string atlas_file)
		{
			var raw = Native.dragonbone_with_files(Bridge.FromString(bone_file), Bridge.FromString(atlas_file));
			return raw == 0 ? null : new DragonBone(raw);
		}
		/// Creates a new instance of 'DragonBone' using the specified bone string.
		///
		/// # Arguments
		///
		/// * `bone_str` - The DragonBone file string for the new instance. A DragonBone file string can be a file path with the target file extension like "DragonBone/item" or file paths with all the related files like "DragonBone/item_ske.json|DragonBone/item_tex.json". An armature name can be added following a separator of ';'. like "DragonBone/item;mainArmature" or "DragonBone/item_ske.json|DragonBone/item_tex.json;mainArmature".
		///
		/// # Returns
		///
		/// * A new instance of 'DragonBone'. Returns `None` if the bone file or atlas file is not found.
		public DragonBone(string bone_str) : this(Native.dragonbone_new(Bridge.FromString(bone_str))) { }
		public static new DragonBone? TryCreate(string bone_str)
		{
			var raw = Native.dragonbone_new(Bridge.FromString(bone_str));
			return raw == 0 ? null : new DragonBone(raw);
		}
		/// Returns a list of available looks for the specified DragonBone file string.
		///
		/// # Arguments
		///
		/// * `bone_str` - The DragonBone file string to get the looks for.
		///
		/// # Returns
		///
		/// * A `Vec<String>` representing the available looks.
		public static string[] GetLooks(string bone_str)
		{
			return Bridge.ToStringArray(Native.dragonbone_get_looks(Bridge.FromString(bone_str)));
		}
		/// Returns a list of available animations for the specified DragonBone file string.
		///
		/// # Arguments
		///
		/// * `bone_str` - The DragonBone file string to get the animations for.
		///
		/// # Returns
		///
		/// * A `Vec<String>` representing the available animations.
		public static string[] GetAnimations(string bone_str)
		{
			return Bridge.ToStringArray(Native.dragonbone_get_animations(Bridge.FromString(bone_str)));
		}
	}
} // namespace Dora
