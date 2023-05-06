extern "C" {
	fn spriteeffect_type() -> i32;
	fn spriteeffect_new(vert_shader: i64, frag_shader: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::IEffect;
impl IEffect for SpriteEffect { }
pub struct SpriteEffect { raw: i64 }
crate::dora_object!(SpriteEffect);
impl SpriteEffect {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { spriteeffect_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(SpriteEffect { raw: raw }))
			}
		})
	}
	pub fn new(vert_shader: &str, frag_shader: &str) -> SpriteEffect {
		unsafe { return SpriteEffect { raw: spriteeffect_new(crate::dora::from_string(vert_shader), crate::dora::from_string(frag_shader)) }; }
	}
}