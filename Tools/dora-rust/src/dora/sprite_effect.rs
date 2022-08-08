extern "C" {
	fn spriteeffect_type() -> i32;
	fn spriteeffect_new(vert_shader: i64, frag_shader: i64) -> i64;
}
use crate::dora::Object;
use crate::dora::IEffect;
impl IEffect for SpriteEffect { }
pub struct SpriteEffect { raw: i64 }
crate::dora_object!(SpriteEffect);
impl SpriteEffect {
	pub fn new(vert_shader: &str, frag_shader: &str) -> SpriteEffect {
		return SpriteEffect { raw: unsafe { spriteeffect_new(crate::dora::from_string(vert_shader), crate::dora::from_string(frag_shader)) } };
	}
}