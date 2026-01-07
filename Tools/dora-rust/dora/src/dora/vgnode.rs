/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn vgnode_type() -> i32;
	fn vgnode_get_surface(slf: i64) -> i64;
	fn vgnode_render(slf: i64, func0: i32);
	fn vgnode_new(width: f32, height: f32, scale: f32, edge_aa: i32) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for VGNode { }
/// A node for rendering vector graphics.
pub struct VGNode { raw: i64 }
crate::dora_object!(VGNode);
impl VGNode {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { vgnode_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(VGNode { raw: raw }))
			}
		})
	}
	/// Gets The surface of the node for displaying frame buffer texture that contains vector graphics.
	/// You can get the texture of the surface by calling `vgNode.get_surface().get_texture()`.
	pub fn get_surface(&self) -> crate::dora::Sprite {
		return unsafe { crate::dora::Sprite::from(vgnode_get_surface(self.raw())).unwrap() };
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
	pub fn render(&mut self, mut render_func: Box<dyn FnMut()>) {
		let func_id0 = crate::dora::push_function(Box::new(move || {
			render_func()
		}));
		unsafe { vgnode_render(self.raw(), func_id0); }
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
	pub fn new(width: f32, height: f32, scale: f32, edge_aa: i32) -> VGNode {
		unsafe { return VGNode { raw: vgnode_new(width, height, scale, edge_aa) }; }
	}
}