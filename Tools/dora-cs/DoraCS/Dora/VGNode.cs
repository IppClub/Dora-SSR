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
		public static extern int32_t vgnode_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t vgnode_get_surface(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void vgnode_render(int64_t self, int32_t func0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t vgnode_new(float width, float height, float scale, int32_t edgeAA);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A node for rendering vector graphics.
	/// </summary>
	public partial class VGNode : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.vgnode_type(), From);
		}
		protected VGNode(long raw) : base(raw) { }
		internal static new VGNode From(long raw)
		{
			return new VGNode(raw);
		}
		internal static new VGNode? FromOpt(long raw)
		{
			return raw == 0 ? null : new VGNode(raw);
		}
		/// <summary>
		/// The surface of the node for displaying frame buffer texture that contains vector graphics.
		/// You can get the texture of the surface by calling `vgNode.Surface.Texture`.
		/// </summary>
		public Sprite Surface
		{
			get => Sprite.From(Native.vgnode_get_surface(Raw));
		}
		/// <summary>
		/// The function for rendering vector graphics.
		/// </summary>
		/// <param name="renderFunc">The closure function for rendering vector graphics. You can do the rendering operations inside this closure.</param>
		public void Render(System.Action renderFunc)
		{
			var func_id0 = Bridge.PushFunction(() =>
			{
				renderFunc();
			});
			Native.vgnode_render(Raw, func_id0);
		}
		/// <summary>
		/// Creates a new VGNode object with the specified width and height.
		/// </summary>
		/// <param name="width">The width of the node's frame buffer texture.</param>
		/// <param name="height">The height of the node's frame buffer texture.</param>
		/// <param name="scale">The scale factor of the VGNode.</param>
		/// <param name="edgeAA">The edge anti-aliasing factor of the VGNode.</param>
		public VGNode(float width, float height, float scale, int edgeAA) : this(Native.vgnode_new(width, height, scale, edgeAA)) { }
	}
} // namespace Dora
