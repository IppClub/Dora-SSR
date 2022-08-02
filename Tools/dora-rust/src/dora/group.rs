extern "C" {
	fn group_type() -> i32;
	fn entity_group_get_count(slf: i64) -> i32;
	fn entity_group_new(components: i64) -> i64;
}
use crate::dora::Object;
pub struct Group { raw: i64 }
crate::dora_object!(Group);
impl Group {
	pub fn get_count(&self) -> i32 {
		return unsafe { entity_group_get_count(self.raw()) };
	}
	pub fn new(components: &Vec<&str>) -> Group {
		return Group { raw: unsafe { entity_group_new(crate::dora::Vector::from_str(components)) } };
	}
}