extern "C" {
	fn svg_type() -> i32;
	fn svgdef_get_width(slf: i64) -> f32;
	fn svgdef_get_height(slf: i64) -> f32;
	fn svgdef_render(slf: i64);
	fn svgdef_new(filename: i64) -> i64;
}
use crate::dora::IObject;
pub struct SVG { raw: i64 }
crate::dora_object!(SVG);
impl SVG {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { svg_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(SVG { raw: raw }))
			}
		})
	}
	pub fn get_width(&self) -> f32 {
		return unsafe { svgdef_get_width(self.raw()) };
	}
	pub fn get_height(&self) -> f32 {
		return unsafe { svgdef_get_height(self.raw()) };
	}
	pub fn render(&mut self) {
		unsafe { svgdef_render(self.raw()); }
	}
	pub fn new(filename: &str) -> Option<SVG> {
		unsafe { return SVG::from(svgdef_new(crate::dora::from_string(filename))); }
	}
}