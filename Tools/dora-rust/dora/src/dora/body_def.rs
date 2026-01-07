/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn bodydef_type() -> i32;
	fn bodydef_set_type(slf: i64, body_type: i32);
	fn bodydef_get_type(slf: i64) -> i32;
	fn bodydef_set_position(slf: i64, val: i64);
	fn bodydef_get_position(slf: i64) -> i64;
	fn bodydef_set_angle(slf: i64, val: f32);
	fn bodydef_get_angle(slf: i64) -> f32;
	fn bodydef_set_face(slf: i64, val: i64);
	fn bodydef_get_face(slf: i64) -> i64;
	fn bodydef_set_face_pos(slf: i64, val: i64);
	fn bodydef_get_face_pos(slf: i64) -> i64;
	fn bodydef_set_linear_damping(slf: i64, val: f32);
	fn bodydef_get_linear_damping(slf: i64) -> f32;
	fn bodydef_set_angular_damping(slf: i64, val: f32);
	fn bodydef_get_angular_damping(slf: i64) -> f32;
	fn bodydef_set_linear_acceleration(slf: i64, val: i64);
	fn bodydef_get_linear_acceleration(slf: i64) -> i64;
	fn bodydef_set_fixed_rotation(slf: i64, val: i32);
	fn bodydef_is_fixed_rotation(slf: i64) -> i32;
	fn bodydef_set_bullet(slf: i64, val: i32);
	fn bodydef_is_bullet(slf: i64) -> i32;
	fn bodydef_polygon_with_center(center: i64, width: f32, height: f32, angle: f32, density: f32, friction: f32, restitution: f32) -> i64;
	fn bodydef_polygon(width: f32, height: f32, density: f32, friction: f32, restitution: f32) -> i64;
	fn bodydef_polygon_with_vertices(vertices: i64, density: f32, friction: f32, restitution: f32) -> i64;
	fn bodydef_attach_polygon_with_center(slf: i64, center: i64, width: f32, height: f32, angle: f32, density: f32, friction: f32, restitution: f32);
	fn bodydef_attach_polygon(slf: i64, width: f32, height: f32, density: f32, friction: f32, restitution: f32);
	fn bodydef_attach_polygon_with_vertices(slf: i64, vertices: i64, density: f32, friction: f32, restitution: f32);
	fn bodydef_multi(vertices: i64, density: f32, friction: f32, restitution: f32) -> i64;
	fn bodydef_attach_multi(slf: i64, vertices: i64, density: f32, friction: f32, restitution: f32);
	fn bodydef_disk_with_center(center: i64, radius: f32, density: f32, friction: f32, restitution: f32) -> i64;
	fn bodydef_disk(radius: f32, density: f32, friction: f32, restitution: f32) -> i64;
	fn bodydef_attach_disk_with_center(slf: i64, center: i64, radius: f32, density: f32, friction: f32, restitution: f32);
	fn bodydef_attach_disk(slf: i64, radius: f32, density: f32, friction: f32, restitution: f32);
	fn bodydef_chain(vertices: i64, friction: f32, restitution: f32) -> i64;
	fn bodydef_attach_chain(slf: i64, vertices: i64, friction: f32, restitution: f32);
	fn bodydef_attach_polygon_sensor(slf: i64, tag: i32, width: f32, height: f32);
	fn bodydef_attach_polygon_sensor_with_center(slf: i64, tag: i32, center: i64, width: f32, height: f32, angle: f32);
	fn bodydef_attach_polygon_sensor_with_vertices(slf: i64, tag: i32, vertices: i64);
	fn bodydef_attach_disk_sensor_with_center(slf: i64, tag: i32, center: i64, radius: f32);
	fn bodydef_attach_disk_sensor(slf: i64, tag: i32, radius: f32);
	fn bodydef_new() -> i64;
}
use crate::dora::IObject;
/// A struct to describe the properties of a physics body.
pub struct BodyDef { raw: i64 }
crate::dora_object!(BodyDef);
impl BodyDef {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { bodydef_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(BodyDef { raw: raw }))
			}
		})
	}
	/// Sets the define for the type of the body.
	///
	/// # Arguments
	///
	/// * `body_type` - The type of the body.
	pub fn set_type(&mut self, body_type: crate::dora::BodyType) {
		unsafe { bodydef_set_type(self.raw(), body_type as i32); }
	}
	/// Gets the define for the type of the body.
	///
	/// # Returns
	///
	/// * `BodyType` - The type of the body.
	pub fn get_type(&self) -> crate::dora::BodyType {
		unsafe { return core::mem::transmute(bodydef_get_type(self.raw())); }
	}
	/// Sets define for the position of the body.
	pub fn set_position(&mut self, val: &crate::dora::Vec2) {
		unsafe { bodydef_set_position(self.raw(), val.into_i64()) };
	}
	/// Gets define for the position of the body.
	pub fn get_position(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(bodydef_get_position(self.raw())) };
	}
	/// Sets define for the angle of the body.
	pub fn set_angle(&mut self, val: f32) {
		unsafe { bodydef_set_angle(self.raw(), val) };
	}
	/// Gets define for the angle of the body.
	pub fn get_angle(&self) -> f32 {
		return unsafe { bodydef_get_angle(self.raw()) };
	}
	/// Sets define for the face image or other items accepted by creating `Face` for the body.
	pub fn set_face(&mut self, val: &str) {
		unsafe { bodydef_set_face(self.raw(), crate::dora::from_string(val)) };
	}
	/// Gets define for the face image or other items accepted by creating `Face` for the body.
	pub fn get_face(&self) -> String {
		return unsafe { crate::dora::to_string(bodydef_get_face(self.raw())) };
	}
	/// Sets define for the face position of the body.
	pub fn set_face_pos(&mut self, val: &crate::dora::Vec2) {
		unsafe { bodydef_set_face_pos(self.raw(), val.into_i64()) };
	}
	/// Gets define for the face position of the body.
	pub fn get_face_pos(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(bodydef_get_face_pos(self.raw())) };
	}
	/// Sets define for linear damping of the body.
	pub fn set_linear_damping(&mut self, val: f32) {
		unsafe { bodydef_set_linear_damping(self.raw(), val) };
	}
	/// Gets define for linear damping of the body.
	pub fn get_linear_damping(&self) -> f32 {
		return unsafe { bodydef_get_linear_damping(self.raw()) };
	}
	/// Sets define for angular damping of the body.
	pub fn set_angular_damping(&mut self, val: f32) {
		unsafe { bodydef_set_angular_damping(self.raw(), val) };
	}
	/// Gets define for angular damping of the body.
	pub fn get_angular_damping(&self) -> f32 {
		return unsafe { bodydef_get_angular_damping(self.raw()) };
	}
	/// Sets define for initial linear acceleration of the body.
	pub fn set_linear_acceleration(&mut self, val: &crate::dora::Vec2) {
		unsafe { bodydef_set_linear_acceleration(self.raw(), val.into_i64()) };
	}
	/// Gets define for initial linear acceleration of the body.
	pub fn get_linear_acceleration(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(bodydef_get_linear_acceleration(self.raw())) };
	}
	/// Sets whether the body's rotation is fixed or not.
	pub fn set_fixed_rotation(&mut self, val: bool) {
		unsafe { bodydef_set_fixed_rotation(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the body's rotation is fixed or not.
	pub fn is_fixed_rotation(&self) -> bool {
		return unsafe { bodydef_is_fixed_rotation(self.raw()) != 0 };
	}
	/// Sets whether the body is a bullet or not.
	/// Set to true to add extra bullet movement check for the body.
	pub fn set_bullet(&mut self, val: bool) {
		unsafe { bodydef_set_bullet(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the body is a bullet or not.
	/// Set to true to add extra bullet movement check for the body.
	pub fn is_bullet(&self) -> bool {
		return unsafe { bodydef_is_bullet(self.raw()) != 0 };
	}
	/// Creates a polygon fixture definition with the specified dimensions and center position.
	///
	/// # Arguments
	///
	/// * `center` - The center point of the polygon.
	/// * `width` - The width of the polygon.
	/// * `height` - The height of the polygon.
	/// * `angle` - The angle of the polygon.
	/// * `density` - The density of the polygon.
	/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
	/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.
	pub fn polygon_with_center(center: &crate::dora::Vec2, width: f32, height: f32, angle: f32, density: f32, friction: f32, restitution: f32) -> crate::dora::FixtureDef {
		unsafe { return crate::dora::FixtureDef::from(bodydef_polygon_with_center(center.into_i64(), width, height, angle, density, friction, restitution)).unwrap(); }
	}
	/// Creates a polygon fixture definition with the specified dimensions.
	///
	/// # Arguments
	///
	/// * `width` - The width of the polygon.
	/// * `height` - The height of the polygon.
	/// * `density` - The density of the polygon.
	/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
	/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.
	pub fn polygon(width: f32, height: f32, density: f32, friction: f32, restitution: f32) -> crate::dora::FixtureDef {
		unsafe { return crate::dora::FixtureDef::from(bodydef_polygon(width, height, density, friction, restitution)).unwrap(); }
	}
	/// Creates a polygon fixture definition with the specified vertices.
	///
	/// # Arguments
	///
	/// * `vertices` - The vertices of the polygon.
	/// * `density` - The density of the polygon.
	/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
	/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.0.
	pub fn polygon_with_vertices(vertices: &Vec<crate::dora::Vec2>, density: f32, friction: f32, restitution: f32) -> crate::dora::FixtureDef {
		unsafe { return crate::dora::FixtureDef::from(bodydef_polygon_with_vertices(crate::dora::Vector::from_vec2(vertices), density, friction, restitution)).unwrap(); }
	}
	/// Attaches a polygon fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `center` - The center point of the polygon.
	/// * `width` - The width of the polygon.
	/// * `height` - The height of the polygon.
	/// * `angle` - The angle of the polygon.
	/// * `density` - The density of the polygon.
	/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
	/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.0.
	pub fn attach_polygon_with_center(&mut self, center: &crate::dora::Vec2, width: f32, height: f32, angle: f32, density: f32, friction: f32, restitution: f32) {
		unsafe { bodydef_attach_polygon_with_center(self.raw(), center.into_i64(), width, height, angle, density, friction, restitution); }
	}
	/// Attaches a polygon fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `width` - The width of the polygon.
	/// * `height` - The height of the polygon.
	/// * `density` - The density of the polygon.
	/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
	/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.0.
	pub fn attach_polygon(&mut self, width: f32, height: f32, density: f32, friction: f32, restitution: f32) {
		unsafe { bodydef_attach_polygon(self.raw(), width, height, density, friction, restitution); }
	}
	/// Attaches a polygon fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `vertices` - The vertices of the polygon.
	/// * `density` - The density of the polygon.
	/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
	/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.0.
	pub fn attach_polygon_with_vertices(&mut self, vertices: &Vec<crate::dora::Vec2>, density: f32, friction: f32, restitution: f32) {
		unsafe { bodydef_attach_polygon_with_vertices(self.raw(), crate::dora::Vector::from_vec2(vertices), density, friction, restitution); }
	}
	/// Creates a concave shape definition made of multiple convex shapes.
	///
	/// # Arguments
	///
	/// * `vertices` - A vector containing the vertices of each convex shape that makes up the concave shape. Each convex shape in the vertices vector should end with a `Vec2(0.0, 0.0)` as separator.
	/// * `density` - The density of the shape.
	/// * `friction` - The friction coefficient of the shape. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution (elasticity) of the shape. Should be between 0.0 and 1.0.
	///
	/// # Returns
	///
	/// * `FixtureDef` - The resulting fixture definition.
	pub fn multi(vertices: &Vec<crate::dora::Vec2>, density: f32, friction: f32, restitution: f32) -> crate::dora::FixtureDef {
		unsafe { return crate::dora::FixtureDef::from(bodydef_multi(crate::dora::Vector::from_vec2(vertices), density, friction, restitution)).unwrap(); }
	}
	/// Attaches a concave shape definition made of multiple convex shapes to the body.
	///
	/// # Arguments
	///
	/// * `vertices` - A vector containing the vertices of each convex shape that makes up the concave shape. Each convex shape in the vertices vector should end with a `Vec2(0.0, 0.0)` as separator.
	/// * `density` - The density of the concave shape.
	/// * `friction` - The friction of the concave shape. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution of the concave shape. Should be between 0.0 and 1.0.
	pub fn attach_multi(&mut self, vertices: &Vec<crate::dora::Vec2>, density: f32, friction: f32, restitution: f32) {
		unsafe { bodydef_attach_multi(self.raw(), crate::dora::Vector::from_vec2(vertices), density, friction, restitution); }
	}
	/// Creates a Disk-shape fixture definition.
	///
	/// # Arguments
	///
	/// * `center` - The center of the circle.
	/// * `radius` - The radius of the circle.
	/// * `density` - The density of the circle.
	/// * `friction` - The friction coefficient of the circle. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution (elasticity) of the circle. Should be between 0.0 and 1.0.
	///
	/// # Returns
	///
	/// * `FixtureDef` - The resulting fixture definition.
	pub fn disk_with_center(center: &crate::dora::Vec2, radius: f32, density: f32, friction: f32, restitution: f32) -> crate::dora::FixtureDef {
		unsafe { return crate::dora::FixtureDef::from(bodydef_disk_with_center(center.into_i64(), radius, density, friction, restitution)).unwrap(); }
	}
	/// Creates a Disk-shape fixture definition.
	///
	/// # Arguments
	///
	/// * `radius` - The radius of the circle.
	/// * `density` - The density of the circle.
	/// * `friction` - The friction coefficient of the circle. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution (elasticity) of the circle. Should be between 0.0 and 1.0.
	///
	/// # Returns
	///
	/// * `FixtureDef` - The resulting fixture definition.
	pub fn disk(radius: f32, density: f32, friction: f32, restitution: f32) -> crate::dora::FixtureDef {
		unsafe { return crate::dora::FixtureDef::from(bodydef_disk(radius, density, friction, restitution)).unwrap(); }
	}
	/// Attaches a disk fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `center` - The center point of the disk.
	/// * `radius` - The radius of the disk.
	/// * `density` - The density of the disk.
	/// * `friction` - The friction of the disk. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution of the disk. Should be between 0.0 and 1.0.
	pub fn attach_disk_with_center(&mut self, center: &crate::dora::Vec2, radius: f32, density: f32, friction: f32, restitution: f32) {
		unsafe { bodydef_attach_disk_with_center(self.raw(), center.into_i64(), radius, density, friction, restitution); }
	}
	/// Attaches a disk fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `radius` - The radius of the disk.
	/// * `density` - The density of the disk.
	/// * `friction` - The friction of the disk. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution of the disk. Should be between 0.0 and 1.0.
	pub fn attach_disk(&mut self, radius: f32, density: f32, friction: f32, restitution: f32) {
		unsafe { bodydef_attach_disk(self.raw(), radius, density, friction, restitution); }
	}
	/// Creates a Chain-shape fixture definition. This fixture is a free form sequence of line segments that has two-sided collision.
	///
	/// # Arguments
	///
	/// * `vertices` - The vertices of the chain.
	/// * `friction` - The friction coefficient of the chain. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution (elasticity) of the chain. Should be between 0.0 and 1.0.
	///
	/// # Returns
	///
	/// * `FixtureDef` - The resulting fixture definition.
	pub fn chain(vertices: &Vec<crate::dora::Vec2>, friction: f32, restitution: f32) -> crate::dora::FixtureDef {
		unsafe { return crate::dora::FixtureDef::from(bodydef_chain(crate::dora::Vector::from_vec2(vertices), friction, restitution)).unwrap(); }
	}
	/// Attaches a chain fixture definition to the body. The Chain fixture is a free form sequence of line segments that has two-sided collision.
	///
	/// # Arguments
	///
	/// * `vertices` - The vertices of the chain.
	/// * `friction` - The friction of the chain. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution of the chain. Should be between 0.0 and 1.0.
	pub fn attach_chain(&mut self, vertices: &Vec<crate::dora::Vec2>, friction: f32, restitution: f32) {
		unsafe { bodydef_attach_chain(self.raw(), crate::dora::Vector::from_vec2(vertices), friction, restitution); }
	}
	/// Attaches a polygon sensor fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `tag` - An integer tag for the sensor.
	/// * `width` - The width of the polygon.
	/// * `height` - The height of the polygon.
	pub fn attach_polygon_sensor(&mut self, tag: i32, width: f32, height: f32) {
		unsafe { bodydef_attach_polygon_sensor(self.raw(), tag, width, height); }
	}
	/// Attaches a polygon sensor fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `tag` - An integer tag for the sensor.
	/// * `center` - The center point of the polygon.
	/// * `width` - The width of the polygon.
	/// * `height` - The height of the polygon.
	/// * `angle` - Optional. The angle of the polygon.
	pub fn attach_polygon_sensor_with_center(&mut self, tag: i32, center: &crate::dora::Vec2, width: f32, height: f32, angle: f32) {
		unsafe { bodydef_attach_polygon_sensor_with_center(self.raw(), tag, center.into_i64(), width, height, angle); }
	}
	/// Attaches a polygon sensor fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `tag` - An integer tag for the sensor.
	/// * `vertices` - A vector containing the vertices of the polygon.
	pub fn attach_polygon_sensor_with_vertices(&mut self, tag: i32, vertices: &Vec<crate::dora::Vec2>) {
		unsafe { bodydef_attach_polygon_sensor_with_vertices(self.raw(), tag, crate::dora::Vector::from_vec2(vertices)); }
	}
	/// Attaches a disk sensor fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `tag` - An integer tag for the sensor.
	/// * `center` - The center of the disk.
	/// * `radius` - The radius of the disk.
	pub fn attach_disk_sensor_with_center(&mut self, tag: i32, center: &crate::dora::Vec2, radius: f32) {
		unsafe { bodydef_attach_disk_sensor_with_center(self.raw(), tag, center.into_i64(), radius); }
	}
	/// Attaches a disk sensor fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `tag` - An integer tag for the sensor.
	/// * `radius` - The radius of the disk.
	pub fn attach_disk_sensor(&mut self, tag: i32, radius: f32) {
		unsafe { bodydef_attach_disk_sensor(self.raw(), tag, radius); }
	}
	/// Creates a new instance of `BodyDef` class.
	///
	/// # Returns
	///
	/// * A new `BodyDef` object.
	pub fn new() -> BodyDef {
		unsafe { return BodyDef { raw: bodydef_new() }; }
	}
}