extern "C" {
	fn observer_type() -> i32;
	fn entityobserver_new(event: i32, components: i64) -> i64;
}
use crate::dora::Object;
pub struct Observer { raw: i64 }
crate::dora_object!(Observer);
impl Observer {
	pub fn new(event: crate::dora::EntityEvent, components: &Vec<&str>) -> Observer {
		return Observer { raw: unsafe { entityobserver_new(event as i32, crate::dora::Vector::from_str(components)) } };
	}
}