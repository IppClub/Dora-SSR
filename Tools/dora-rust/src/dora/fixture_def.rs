extern "C" {
}
pub struct FixtureDef { raw: i64 }
impl FixtureDef {
	pub fn from(raw: i64) -> Option<FixtureDef> {
		match raw {
			0 => None,
			_ => Some(FixtureDef { raw: raw })
		}
	}
	pub fn raw(&self) -> i64 { self.raw }
}