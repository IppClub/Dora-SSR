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
		public static extern int32_t vgnode_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t vgnode_get_surface(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void vgnode_render(int64_t self, int32_t func0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t vgnode_new(float width, float height, float scale, int32_t edge_aa);
	}
} // namespace Dora

namespace Dora
{
	/// A node for rendering vector graphics.
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
		/// The surface of the node for displaying frame buffer texture that contains vector graphics.
		/// You can get the texture of the surface by calling `vgNode.get_surface().get_texture()`.
		public Sprite Surface
		{
			get => Sprite.From(Native.vgnode_get_surface(Raw));
		}
		/// The function for rendering vector graphics.
		///
		/// # Arguments
		///
		/// * `renderFunc` - The closure function for rendering vector graphics. You can do the rendering operations inside this closure.
		///
		/// # Example
		///
		/// ```
		/// vgNode.render(|| {
		/// 	Nvg::begin_path();
		/// 	Nvg::move_to(100.0, 100.0);
		/// 	Nvg::line_to(200.0, 200.0);
		/// 	Nvg::close_path();
		/// 	Nvg::stroke();
		/// });
		/// ```
		public void Render(System.Action render_func)
		{
			var func_id0 = Bridge.PushFunction(() =>
			{
				render_func();
			});
			Native.vgnode_render(Raw, func_id0);
		}
		/// Creates a new VGNode object with the specified width and height.
		///
		/// # Arguments
		///
		/// * `width` - The width of the node's frame buffer texture.
		/// * `height` - The height of the node's frame buffer texture.
		/// * `scale` - The scale factor of the VGNode.
		/// * `edge_aa` - The edge anti-aliasing factor of the VGNode.
		///
		/// # Returns
		///
		/// * The newly created VGNode object.
		public VGNode(float width, float height, float scale, int edge_aa) : this(Native.vgnode_new(width, height, scale, edge_aa)) { }
	}
} // namespace Dora
