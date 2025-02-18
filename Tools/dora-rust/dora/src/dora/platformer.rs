mod target_allow;
pub use target_allow::TargetAllow;
mod face;
pub use face::Face;
mod bullet_def;
pub use bullet_def::BulletDef;
mod bullet;
pub use bullet::Bullet;
mod visual;
pub use visual::Visual;
mod action_update;
pub mod behavior;
pub mod decision;
pub use action_update::ActionUpdate;
mod unit_action;
pub use unit_action::UnitAction;
mod unit;
pub use unit::Unit;
mod platform_camera;
pub use platform_camera::PlatformCamera;
mod platform_world;
pub use platform_world::PlatformWorld;
mod data;
pub use data::Data;

#[repr(i32)]
pub enum Relation {
	Unknown = 0,
	Friend = 1 << 0,
	Neutral = 1 << 1,
	Enemy = 1 << 2,
	Any = (Relation::Friend as u32 | Relation::Neutral as u32 | Relation::Enemy as u32) as i32,
}
