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
		public static extern int64_t spine_intersects_segment(int64_t self, float x1, float y1, float x2, float y2);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_with_files(int64_t skelFile, int64_t atlasFile);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_new(int64_t spineStr);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_get_looks(int64_t spineStr);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spine_get_animations(int64_t spineStr);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// An implementation of an animation system using the Spine engine.
	/// </summary>
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
		/// <summary>
		/// Whether hit testing is enabled.
		/// </summary>
		public bool IsHitTestEnabled
		{
			set => Native.spine_set_hit_test_enabled(Raw, value ? 1 : 0);
			get => Native.spine_is_hit_test_enabled(Raw) != 0;
		}
		/// <summary>
		/// Sets the rotation of a bone in the Spine skeleton.
		/// </summary>
		/// <param name="name">The name of the bone to rotate.</param>
		/// <param name="rotation">The amount to rotate the bone, in degrees.</param>
		/// <returns>Whether the rotation was successfully set or not.</returns>
		public bool SetBoneRotation(string name, float rotation)
		{
			return Native.spine_set_bone_rotation(Raw, Bridge.FromString(name), rotation) != 0;
		}
		/// <summary>
		/// Checks if a point in space is inside the boundaries of the Spine skeleton.
		/// </summary>
		/// <param name="x">The x-coordinate of the point to check.</param>
		/// <param name="y">The y-coordinate of the point to check.</param>
		/// <returns>The name of the bone at the point, or `None` if there is no bone at the point.</returns>
		public string ContainsPoint(float x, float y)
		{
			return Bridge.ToString(Native.spine_contains_point(Raw, x, y));
		}
		/// <summary>
		/// Checks if a line segment intersects the boundaries of the instance and returns the name of the bone or slot at the intersection point, or `None` if no bone or slot is found.
		/// </summary>
		/// <param name="x1">The x-coordinate of the start point of the line segment.</param>
		/// <param name="y1">The y-coordinate of the start point of the line segment.</param>
		/// <param name="x2">The x-coordinate of the end point of the line segment.</param>
		/// <param name="y2">The y-coordinate of the end point of the line segment.</param>
		/// <returns>The name of the bone or slot at the intersection point, or `None` if no bone or slot is found.</returns>
		public string IntersectsSegment(float x1, float y1, float x2, float y2)
		{
			return Bridge.ToString(Native.spine_intersects_segment(Raw, x1, y1, x2, y2));
		}
		/// <summary>
		/// Creates a new instance of 'Spine' using the specified skeleton file and atlas file.
		/// </summary>
		/// <param name="skelFile">The filename of the skeleton file to load.</param>
		/// <param name="atlasFile">The filename of the atlas file to load.</param>
		public Spine(string skelFile, string atlasFile) : this(Native.spine_with_files(Bridge.FromString(skelFile), Bridge.FromString(atlasFile))) { }
		public static Spine? TryCreate(string skelFile, string atlasFile)
		{
			var raw = Native.spine_with_files(Bridge.FromString(skelFile), Bridge.FromString(atlasFile));
			return raw == 0 ? null : new Spine(raw);
		}
		/// <summary>
		/// Creates a new instance of 'Spine' using the specified Spine string.
		/// </summary>
		/// <param name="spineStr">The Spine file string for the new instance. A Spine file string can be a file path with the target file extension like "Spine/item" or file paths with all the related files like "Spine/item.skel|Spine/item.atlas" or "Spine/item.json|Spine/item.atlas".</param>
		public Spine(string spineStr) : this(Native.spine_new(Bridge.FromString(spineStr))) { }
		public static new Spine? TryCreate(string spineStr)
		{
			var raw = Native.spine_new(Bridge.FromString(spineStr));
			return raw == 0 ? null : new Spine(raw);
		}
		/// <summary>
		/// Returns a list of available looks for the specified Spine2D file string.
		/// </summary>
		/// <param name="spineStr">The Spine2D file string to get the looks for.</param>
		public static string[] GetLooks(string spineStr)
		{
			return Bridge.ToStringArray(Native.spine_get_looks(Bridge.FromString(spineStr)));
		}
		/// <summary>
		/// Returns a list of available animations for the specified Spine2D file string.
		/// </summary>
		/// <param name="spineStr">The Spine2D file string to get the animations for.</param>
		public static string[] GetAnimations(string spineStr)
		{
			return Bridge.ToStringArray(Native.spine_get_animations(Bridge.FromString(spineStr)));
		}
	}
} // namespace Dora
