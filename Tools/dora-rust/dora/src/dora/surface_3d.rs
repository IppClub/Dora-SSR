/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn surface3d_type() -> i32;
	fn surface3d_set_content(slf: i64, val: i64);
	fn surface3d_get_content(slf: i64) -> i64;
	fn surface3d_set_size(slf: i64, val: i64);
	fn surface3d_get_size(slf: i64) -> i64;
	fn surface3d_set_pixel_size(slf: i64, val: i64);
	fn surface3d_get_pixel_size(slf: i64) -> i64;
	fn surface3d_set_billboard(slf: i64, val: i32);
	fn surface3d_get_billboard(slf: i64) -> i32;
	fn surface3d_is_using_texture(slf: i64) -> i32;
	fn surface3d_new(content: i64, size: i64, pixel_size: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode3D;
impl INode3D for Surface3D { }
/// A 2D node subtree displayed in a 3D scene.
pub struct Surface3D { raw: i64 }
crate::dora_object!(Surface3D);
impl Surface3D {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { surface3d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Surface3D { raw: raw }))
			}
		})
	}
	pub fn set_content(&mut self, val: &dyn crate::dora::INode) {
		unsafe { surface3d_set_content(self.raw(), val.raw()) };
	}
	pub fn get_content(&self) -> crate::dora::Node {
		return unsafe { crate::dora::Node::from(surface3d_get_content(self.raw())).unwrap() };
	}
	/// Sets Physical width and height in world units.
	pub fn set_size(&mut self, val: &crate::dora::Size) {
		unsafe { surface3d_set_size(self.raw(), val.into_i64()) };
	}
	/// Gets Physical width and height in world units.
	pub fn get_size(&self) -> crate::dora::Size {
		return unsafe { crate::dora::Size::from(surface3d_get_size(self.raw())) };
	}
	/// Sets Raster size used by the automatic render-target fallback.
	pub fn set_pixel_size(&mut self, val: &crate::dora::Size) {
		unsafe { surface3d_set_pixel_size(self.raw(), val.into_i64()) };
	}
	/// Gets Raster size used by the automatic render-target fallback.
	pub fn get_pixel_size(&self) -> crate::dora::Size {
		return unsafe { crate::dora::Size::from(surface3d_get_pixel_size(self.raw())) };
	}
	pub fn set_billboard(&mut self, val: crate::dora::Billboard) {
		unsafe { surface3d_set_billboard(self.raw(), val as i32) };
	}
	pub fn get_billboard(&self) -> crate::dora::Billboard {
		return unsafe { core::mem::transmute(surface3d_get_billboard(self.raw())) };
	}
	pub fn is_using_texture(&self) -> bool {
		return unsafe { surface3d_is_using_texture(self.raw()) != 0 };
	}
	pub fn new(content: &dyn crate::dora::INode, size: &crate::dora::Size, pixel_size: &crate::dora::Size) -> Surface3D {
		unsafe { return Surface3D { raw: surface3d_new(content.raw(), size.into_i64(), pixel_size.into_i64()) }; }
	}
}