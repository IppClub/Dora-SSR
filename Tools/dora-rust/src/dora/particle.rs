extern "C" {
	fn particle_type() -> i32;
	fn particlenode_is_active(slf: i64) -> i32;
	fn particlenode_start(slf: i64);
	fn particlenode_stop(slf: i64);
	fn particlenode_new(filename: i64) -> i64;
}
use crate::dora::Object;
use crate::dora::INode;
impl INode for Particle { }
pub struct Particle { raw: i64 }
crate::dora_object!(Particle);
impl Particle {
	pub fn is_active(&self) -> bool {
		return unsafe { particlenode_is_active(self.raw()) != 0 };
	}
	pub fn start(&mut self) {
		unsafe { particlenode_start(self.raw()) };
	}
	pub fn stop(&mut self) {
		unsafe { particlenode_stop(self.raw()) };
	}
	pub fn new(filename: &str) -> Option<Particle> {
		return Particle::from(unsafe { particlenode_new(crate::dora::from_string(filename)) });
	}
}