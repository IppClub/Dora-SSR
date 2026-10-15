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
		public static extern int32_t dragonbone_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void dragonbone_set_hit_test_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t dragonbone_is_hit_test_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_contains_point(int64_t self, float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_intersects_segment(int64_t self, float x1, float y1, float x2, float y2);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_with_files(int64_t boneFile, int64_t atlasFile);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_new(int64_t boneStr);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_get_looks(int64_t boneStr);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dragonbone_get_animations(int64_t boneStr);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// An implementation of the 'Playable' record using the DragonBones animation system.
	/// </summary>
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
		/// <summary>
		/// Whether hit testing is enabled.
		/// </summary>
		public bool IsHitTestEnabled
		{
			set => Native.dragonbone_set_hit_test_enabled(Raw, value ? 1 : 0);
			get => Native.dragonbone_is_hit_test_enabled(Raw) != 0;
		}
		/// <summary>
		/// Checks if a point is inside the boundaries of the instance and returns the name of the bone or slot at that point, or `None` if no bone or slot is found.
		/// </summary>
		/// <param name="x">The x-coordinate of the point to check.</param>
		/// <param name="y">The y-coordinate of the point to check.</param>
		/// <returns>The name of the bone or slot at the point.</returns>
		public string ContainsPoint(float x, float y)
		{
			return Bridge.ToString(Native.dragonbone_contains_point(Raw, x, y));
		}
		/// <summary>
		/// Checks if a line segment intersects the boundaries of the instance and returns the name of the bone or slot at the intersection point, or `None` if no bone or slot is found.
		/// </summary>
		/// <param name="x1">The x-coordinate of the start point of the line segment.</param>
		/// <param name="y1">The y-coordinate of the start point of the line segment.</param>
		/// <param name="x2">The x-coordinate of the end point of the line segment.</param>
		/// <param name="y2">The y-coordinate of the end point of the line segment.</param>
		/// <returns>The name of the bone or slot at the intersection point.</returns>
		public string IntersectsSegment(float x1, float y1, float x2, float y2)
		{
			return Bridge.ToString(Native.dragonbone_intersects_segment(Raw, x1, y1, x2, y2));
		}
		/// <summary>
		/// Creates a new instance of 'DragonBone' using the specified bone file and atlas file. This function only loads the first armature.
		/// </summary>
		/// <param name="boneFile">The filename of the bone file to load.</param>
		/// <param name="atlasFile">The filename of the atlas file to load.</param>
		public DragonBone(string boneFile, string atlasFile) : this(Native.dragonbone_with_files(Bridge.FromString(boneFile), Bridge.FromString(atlasFile))) { }
		public static DragonBone? TryCreate(string boneFile, string atlasFile)
		{
			var raw = Native.dragonbone_with_files(Bridge.FromString(boneFile), Bridge.FromString(atlasFile));
			return raw == 0 ? null : new DragonBone(raw);
		}
		/// <summary>
		/// Creates a new instance of 'DragonBone' using the specified bone string.
		/// </summary>
		/// <param name="boneStr">The DragonBone file string for the new instance. A DragonBone file string can be a file path with the target file extension like "DragonBone/item" or file paths with all the related files like "DragonBone/item_ske.json|DragonBone/item_tex.json". An armature name can be added following a separator of ';'. like "DragonBone/item;mainArmature" or "DragonBone/item_ske.json|DragonBone/item_tex.json;mainArmature".</param>
		public DragonBone(string boneStr) : this(Native.dragonbone_new(Bridge.FromString(boneStr))) { }
		public static new DragonBone? TryCreate(string boneStr)
		{
			var raw = Native.dragonbone_new(Bridge.FromString(boneStr));
			return raw == 0 ? null : new DragonBone(raw);
		}
		/// <summary>
		/// Returns a list of available looks for the specified DragonBone file string.
		/// </summary>
		/// <param name="boneStr">The DragonBone file string to get the looks for.</param>
		public static string[] GetLooks(string boneStr)
		{
			return Bridge.ToStringArray(Native.dragonbone_get_looks(Bridge.FromString(boneStr)));
		}
		/// <summary>
		/// Returns a list of available animations for the specified DragonBone file string.
		/// </summary>
		/// <param name="boneStr">The DragonBone file string to get the animations for.</param>
		public static string[] GetAnimations(string boneStr)
		{
			return Bridge.ToStringArray(Native.dragonbone_get_animations(Bridge.FromString(boneStr)));
		}
	}
} // namespace Dora
