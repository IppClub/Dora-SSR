extern "C" {
	fn fixturedef_type() -> i32;
}
use crate::dora::IObject;
pub struct FixtureDef { raw: i64 }
crate::dora_object!(FixtureDef);
impl FixtureDef {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { fixturedef_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(FixtureDef { raw: raw }))
			}
		})
	}
}