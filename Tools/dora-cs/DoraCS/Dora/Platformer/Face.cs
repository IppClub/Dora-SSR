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
		public static extern int32_t platformer_face_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_face_add_child(int64_t self, int64_t face);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_face_to_node(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_face_new(int64_t faceStr, int64_t point, float scale, float angle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_face_with_func(int32_t func0, int64_t stack0, int64_t point, float scale, float angle);
	}
} // namespace Dora

namespace Dora.Platformer
{
	/// <summary>
	/// Represents a definition for a visual component of a game bullet or other visual item.
	/// </summary>
	public partial class Face : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.platformer_face_type(), From);
		}
		protected Face(long raw) : base(raw) { }
		internal static new Face From(long raw)
		{
			return new Face(raw);
		}
		internal static new Face? FromOpt(long raw)
		{
			return raw == 0 ? null : new Face(raw);
		}
		/// <summary>
		/// Adds a child `Face` definition to it.
		/// </summary>
		/// <param name="face">The child `Face` to add.</param>
		public void AddChild(Platformer.Face face)
		{
			Native.platformer_face_add_child(Raw, face.Raw);
		}
		/// <summary>
		/// Returns a node that can be added to a scene tree for rendering.
		/// </summary>
		/// <returns>The `Node` representing this `Face`.</returns>
		public Node ToNode()
		{
			return Node.From(Native.platformer_face_to_node(Raw));
		}
		/// <summary>
		/// Creates a new `Face` definition using the specified attributes.
		/// </summary>
		/// <param name="faceStr">A string for creating the `Face` component. Could be 'Image/file.png' and 'Image/items.clip|itemA'.</param>
		/// <param name="point">The position of the `Face` component.</param>
		/// <param name="scale">The scale of the `Face` component.</param>
		/// <param name="angle">The angle of the `Face` component.</param>
		/// <returns>The new `Face` component.</returns>
		public Face(string faceStr, Vec2 point, float scale = 1.0f, float angle = 0.0f) : this(Native.platformer_face_new(Bridge.FromString(faceStr), point.Raw, scale, angle)) { }
		private static long NewFace(Func<Node> createFunc, Vec2 point = new(), float scale = 1.0f, float angle = 0.0f)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = createFunc();
				stack0.Push(result);
			});
			return Native.platformer_face_with_func(func_id0, stack_raw0, point.Raw, scale, angle);
		}
		/// <summary>
		/// Creates a new `Face` definition using the specified attributes.
		/// </summary>
		/// <param name="createFunc">A function that returns a `Node` representing the `Face` component.</param>
		/// <param name="point">The position of the `Face` component.</param>
		/// <param name="scale">The scale of the `Face` component.</param>
		/// <param name="angle">The angle of the `Face` component.</param>
		/// <returns>The new `Face` component.</returns>
		public Face(Func<Node> createFunc, Vec2 point = new(), float scale = 1.0f, float angle = 0.0f) : this(NewFace(createFunc, point, scale, angle)) { }
	}
} // namespace Dora.Platformer
