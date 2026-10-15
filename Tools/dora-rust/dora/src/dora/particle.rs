/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn particle_type() -> i32;
	fn particlenode_is_active(slf: i64) -> i32;
	fn particlenode_start(slf: i64);
	fn particlenode_stop(slf: i64);
	fn particlenode_new(filename: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for Particle { }
/// Represents a particle system node that emits and animates particles.
pub struct Particle { raw: i64 }
crate::dora_object!(Particle);
impl Particle {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { particle_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Particle { raw: raw }))
			}
		})
	}
	/// Gets whether the particle system is active.
	pub fn is_active(&self) -> bool {
		return unsafe { particlenode_is_active(self.raw()) != 0 };
	}
	/// Starts emitting particles.
	pub fn start(&mut self) {
		unsafe { particlenode_start(self.raw()); }
	}
	/// Stops emitting particles and wait for all active particles to end their lives.
	pub fn stop(&mut self) {
		unsafe { particlenode_stop(self.raw()); }
	}
	/// Creates a new Particle object from a particle system file.
	///
	/// # Arguments
	///
	/// * `filename` - The file path of the particle system file.
	///
	/// # Returns
	///
	/// * A new `Particle` object.
	pub fn new(filename: &str) -> Option<Particle> {
		unsafe { return Particle::from(particlenode_new(crate::dora::from_string(filename))); }
	}
}