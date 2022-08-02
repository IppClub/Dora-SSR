extern "C" {
	fn observer_type() -> i32;
}
use crate::dora::Object;
pub struct Observer { raw: i64 }
crate::dora_object!(Observer);
impl Observer {
}