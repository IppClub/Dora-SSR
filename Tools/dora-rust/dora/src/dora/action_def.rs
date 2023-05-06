extern "C" {
	fn actiondef_release(raw: i64);
}
pub struct ActionDef { raw: i64 }
impl Drop for ActionDef {
	fn drop(&mut self) { unsafe { actiondef_release(self.raw); } }
}
impl ActionDef {
	pub fn raw(&self) -> i64 {
		self.raw
	}
	pub fn from(raw: i64) -> ActionDef {
		ActionDef { raw: raw }
	}
}