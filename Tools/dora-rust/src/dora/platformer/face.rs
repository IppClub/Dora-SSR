extern "C" {
	fn platformer_face_type() -> i32;
	fn platformer_face_add_child(slf: i64, face: i64);
	fn platformer_face_to_node(slf: i64) -> i64;
	fn platformer_face_new(face_str: i64, point: i64, scale: f32, angle: f32) -> i64;
	fn platformer_face_with_func(func: i32, stack: i64, point: i64, scale: f32, angle: f32) -> i64;
}
use crate::dora::IObject;
pub struct Face { raw: i64 }
crate::dora_object!(Face);
impl Face {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_face_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Face { raw: raw }))
			}
		})
	}
	pub fn add_child(&mut self, face: &crate::dora::platformer::Face) {
		unsafe { platformer_face_add_child(self.raw(), face.raw()); }
	}
	pub fn to_node(&mut self) -> crate::dora::Node {
		unsafe { return crate::dora::Node::from(platformer_face_to_node(self.raw())).unwrap(); }
	}
	pub fn new(face_str: &str, point: &crate::dora::Vec2, scale: f32, angle: f32) -> Face {
		unsafe { return Face { raw: platformer_face_new(crate::dora::from_string(face_str), point.into_i64(), scale, angle) }; }
	}
	pub fn with_func(mut create_func: Box<dyn FnMut() -> crate::dora::Node>, point: &crate::dora::Vec2, scale: f32, angle: f32) -> Face {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = create_func();
			stack.push_object(&result);
		}));
		unsafe { return Face { raw: platformer_face_with_func(func_id, stack_raw, point.into_i64(), scale, angle) }; }
	}
}