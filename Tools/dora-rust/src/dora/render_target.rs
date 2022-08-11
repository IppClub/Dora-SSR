extern "C" {
	fn rendertarget_type() -> i32;
	fn rendertarget_get_width(slf: i64) -> i32;
	fn rendertarget_get_height(slf: i64) -> i32;
	fn rendertarget_set_camera(slf: i64, var: i64);
	fn rendertarget_get_camera(slf: i64) -> i64;
	fn rendertarget_get_texture(slf: i64) -> i64;
	fn rendertarget_render(slf: i64, target: i64);
	fn rendertarget_render_clear(slf: i64, color: i32, depth: f32, stencil: i32);
	fn rendertarget_render_clear_with_target(slf: i64, target: i64, color: i32, depth: f32, stencil: i32);
	fn rendertarget_save_async(slf: i64, filename: i64, func: i32);
	fn rendertarget_new(width: i32, height: i32) -> i64;
}
use crate::dora::IObject;
pub struct RenderTarget { raw: i64 }
crate::dora_object!(RenderTarget);
impl RenderTarget {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { rendertarget_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(RenderTarget { raw: raw }))
			}
		})
	}
	pub fn get_width(&self) -> i32 {
		return unsafe { rendertarget_get_width(self.raw()) };
	}
	pub fn get_height(&self) -> i32 {
		return unsafe { rendertarget_get_height(self.raw()) };
	}
	pub fn set_camera(&mut self, var: &dyn crate::dora::ICamera) {
		unsafe { rendertarget_set_camera(self.raw(), var.raw()) };
	}
	pub fn get_camera(&self) -> Option<crate::dora::Camera> {
		return unsafe { crate::dora::Camera::from(rendertarget_get_camera(self.raw())) };
	}
	pub fn get_texture(&self) -> crate::dora::Texture2D {
		return unsafe { crate::dora::Texture2D::from(rendertarget_get_texture(self.raw())).unwrap() };
	}
	pub fn render(&mut self, target: &dyn crate::dora::INode) {
		unsafe { rendertarget_render(self.raw(), target.raw()); }
	}
	pub fn render_clear(&mut self, color: &crate::dora::Color, depth: f32, stencil: i32) {
		unsafe { rendertarget_render_clear(self.raw(), color.to_argb() as i32, depth, stencil); }
	}
	pub fn render_clear_with_target(&mut self, target: &dyn crate::dora::INode, color: &crate::dora::Color, depth: f32, stencil: i32) {
		unsafe { rendertarget_render_clear_with_target(self.raw(), target.raw(), color.to_argb() as i32, depth, stencil); }
	}
	pub fn save_async(&mut self, filename: &str, mut handler: Box<dyn FnMut()>) {
		let func_id = crate::dora::push_function(Box::new(move || {
			handler()
		}));
		unsafe { rendertarget_save_async(self.raw(), crate::dora::from_string(filename), func_id); }
	}
	pub fn new(width: i32, height: i32) -> RenderTarget {
		unsafe { return RenderTarget { raw: rendertarget_new(width, height) }; }
	}
}