extern "C" {
	fn entity_type() -> i32;
	fn entity_get_count() -> i32;
	fn entity_get_index(slf: i64) -> i32;
	fn entity_clear();
	fn entity_remove(slf: i64, key: i64);
	fn entity_destroy(slf: i64);
	fn entity_new() -> i64;
}
use crate::dora::IObject;
/// A struct representing an entity for an ECS game system.
pub struct Entity { raw: i64 }
crate::dora_object!(Entity);
impl Entity {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { entity_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Entity { raw: raw }))
			}
		})
	}
	/// Gets the number of all running entities.
	pub fn get_count() -> i32 {
		return unsafe { entity_get_count() };
	}
	/// Gets the index of the entity.
	pub fn get_index(&self) -> i32 {
		return unsafe { entity_get_index(self.raw()) };
	}
	/// Clears all entities.
	pub fn clear() {
		unsafe { entity_clear(); }
	}
	/// Removes a property of the entity.
	///
	/// This function will trigger events for Observer objects.
	///
	/// # Arguments
	///
	/// * `key` - The name of the property to remove.
	pub fn remove(&mut self, key: &str) {
		unsafe { entity_remove(self.raw(), crate::dora::from_string(key)); }
	}
	/// Destroys the entity.
	pub fn destroy(&mut self) {
		unsafe { entity_destroy(self.raw()); }
	}
	/// Creates a new entity.
	pub fn new() -> Entity {
		unsafe { return Entity { raw: entity_new() }; }
	}
}