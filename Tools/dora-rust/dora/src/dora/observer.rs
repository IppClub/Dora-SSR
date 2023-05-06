extern "C" {
	fn observer_type() -> i32;
	fn entityobserver_new(event: i32, components: i64) -> i64;
}
use crate::dora::IObject;
pub struct Observer { raw: i64 }
crate::dora_object!(Observer);
impl Observer {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { observer_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Observer { raw: raw }))
			}
		})
	}
	pub fn new(event: crate::dora::EntityEvent, components: &Vec<&str>) -> Observer {
		unsafe { return Observer { raw: entityobserver_new(event as i32, crate::dora::Vector::from_str(components)) }; }
	}
}