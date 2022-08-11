use std::{ffi::c_void, any::Any};
use once_cell::sync::Lazy;

mod rect;
pub use rect::Rect;
mod array;
pub use array::Array;
mod dictionary;
pub use dictionary::Dictionary;
mod director;
pub use director::Director;
mod app;
pub use app::App;
mod entity;
pub use entity::Entity;
mod group;
pub use group::Group;
mod observer;
pub use observer::Observer;
mod path;
pub use path::Path;
mod content;
pub use content::Content;
mod scheduler;
pub use scheduler::Scheduler;
mod camera;
pub use camera::{ICamera, Camera};
mod camera_2d;
pub use camera_2d::Camera2D;
mod camera_otho;
pub use camera_otho::CameraOtho;
mod pass;
pub use pass::Pass;
mod effect;
pub use effect::{IEffect, Effect};
mod sprite_effect;
pub use sprite_effect::SpriteEffect;
mod view;
pub use view::View;
mod action_def;
pub use action_def::ActionDef;
mod action;
pub use action::Action;
mod grabber;
pub use grabber::Grabber;
mod node;
pub use node::{INode, Node};
mod texture_2d;
pub use texture_2d::Texture2D;
mod sprite;
pub use sprite::Sprite;
mod grid;
pub use grid::Grid;
mod touch;
pub use touch::Touch;
mod ease;
pub use ease::Ease;
mod label;
pub use label::Label;
mod render_target;
pub use render_target::RenderTarget;
mod clip_node;
pub use clip_node::ClipNode;
mod draw_node;
pub use draw_node::DrawNode;
mod vertex_color;
pub use vertex_color::VertexColor;
mod line;
pub use line::Line;
mod particle;
pub use particle::Particle;
mod playable;
pub use playable::{IPlayable, Playable};
mod model;
pub use model::Model;
mod spine;
pub use spine::Spine;
mod dragon_bone;
pub use dragon_bone::DragonBone;
mod physics_world;
pub use physics_world::{IPhysicsWorld, PhysicsWorld};
mod fixture_def;
pub use fixture_def::FixtureDef;
mod body_def;
pub use body_def::BodyDef;
mod sensor;
pub use sensor::Sensor;
mod body;
pub use body::{IBody, Body};
mod joint_def;
pub use joint_def::JointDef;
mod joint;
pub use joint::{IJoint, Joint};
mod motor_joint;
pub use motor_joint::MotorJoint;
mod move_joint;
pub use move_joint::MoveJoint;
mod cache;
pub use cache::Cache;
mod audio;
pub use audio::Audio;
mod keyboard;
pub use keyboard::Keyboard;
mod svg;
pub use svg::SVG;
mod dbquery;
pub use dbquery::DBQuery;
mod dbrecord;
pub use dbrecord::DBRecord;
mod db;
pub use db::DB;
mod c_45;
mod q_learner;
pub mod ml {
	pub use super::c_45::C45;
	pub use super::q_learner::QLearner;
}
pub mod platformer;

fn none_type(_: i64) -> Option<Box<dyn IObject>> {
	panic!("'none_type' should not be called!");
}

static OBJECT_MAP: Lazy<Vec<fn(i64) -> Option<Box<dyn IObject>>>> = Lazy::new(|| {
	let mut map: Vec<fn(i64) -> Option<Box<dyn IObject>>> = Vec::new();
	let type_funcs = [
		Array::type_info(),
		Dictionary::type_info(),
		Entity::type_info(),
		Group::type_info(),
		Observer::type_info(),
		Scheduler::type_info(),
		Camera::type_info(),
		Camera2D::type_info(),
		CameraOtho::type_info(),
		Pass::type_info(),
		Effect::type_info(),
		SpriteEffect::type_info(),
		Grabber::type_info(),
		Node::type_info(),
		Texture2D::type_info(),
		Sprite::type_info(),
		Grid::type_info(),
		Touch::type_info(),
		Label::type_info(),
		RenderTarget::type_info(),
		ClipNode::type_info(),
		DrawNode::type_info(),
		Line::type_info(),
		Particle::type_info(),
		Playable::type_info(),
		Model::type_info(),
		Spine::type_info(),
		DragonBone::type_info(),
		PhysicsWorld::type_info(),
		BodyDef::type_info(),
		Sensor::type_info(),
		Body::type_info(),
		JointDef::type_info(),
		Joint::type_info(),
		MotorJoint::type_info(),
		MoveJoint::type_info(),
		SVG::type_info(),
		ml::QLearner::type_info(),
		platformer::BulletDef::type_info(),
		platformer::Bullet::type_info(),
		platformer::Visual::type_info(),
		platformer::behavior::Tree::type_info(),
		platformer::decision::Tree::type_info(),
	];
	for pair in type_funcs.iter() {
		let t = pair.0 as usize;
		if map.len() < t + 1 {
			map.resize(t + 1, none_type);
		}
		if map[t] != none_type {
			panic!("cpp object type id {} duplicated!", t);
		}
		map[t] = pair.1;
	}
	map
});
static mut FUNC_MAP: Vec<Box<dyn FnMut()>> = Vec::new();
static mut FUNC_AVAILABLE: Vec<i32> = Vec::new();

extern "C" {
	fn object_get_id(obj: i64) -> i32;
	fn object_get_type(obj: i64) -> i32;
	fn object_retain(obj: i64);
	fn object_release(obj: i64);

	fn str_new(len: i32) -> i64;
	fn str_len(str: i64) -> i32;
	fn str_read(dest: *mut c_void, src: i64);
	fn str_write(dest: i64, src: *const c_void);
	fn str_release(str: i64);

	fn buf_new_i32(len: i32) -> i64;
	fn buf_new_i64(len: i32) -> i64;
	fn buf_new_f32(len: i32) -> i64;
	fn buf_new_f64(len: i32) -> i64;
	fn buf_len(v: i64) -> i32;
	fn buf_read(dest: *mut c_void, src: i64);
	fn buf_write(dest: i64, src: *const c_void);
	fn buf_release(v: i64);

	fn value_create_i64(value: i64) -> i64;
	fn value_create_f64(value: f64) -> i64;
	fn value_create_str(value: i64) -> i64;
	fn value_create_bool(value: i32) -> i64;
	fn value_create_object(value: i64) -> i64;
	fn value_create_vec2(value: i64) -> i64;
	fn value_create_size(value: i64) -> i64;
	fn value_release(value: i64);
	fn value_into_i64(value: i64) -> i64;
	fn value_into_f64(value: i64) -> f64;
	fn value_into_str(value: i64) -> i64;
	fn value_into_bool(value: i64) -> i32;
	fn value_into_object(value: i64) -> i64;
	fn value_into_vec2(value: i64) -> i64;
	fn value_into_size(value: i64) -> i64;
	fn value_is_i64(value: i64) -> i32;
	fn value_is_f64(value: i64) -> i32;
	fn value_is_str(value: i64) -> i32;
	fn value_is_bool(value: i64) -> i32;
	fn value_is_object(value: i64) -> i32;
	fn value_is_vec2(value: i64) -> i32;
	fn value_is_size(value: i64) -> i32;

	fn call_stack_create() -> i64;
	fn call_stack_release(info: i64);
	fn call_stack_push_i64(info: i64, value: i64);
	fn call_stack_push_f64(info: i64, value: f64);
	fn call_stack_push_str(info: i64, value: i64);
	fn call_stack_push_bool(info: i64, value: i32);
	fn call_stack_push_object(info: i64, value: i64);
	fn call_stack_push_vec2(info: i64, value: i64);
	fn call_stack_push_size(info: i64, value: i64);
	fn call_stack_pop_i64(info: i64) -> i64;
	fn call_stack_pop_f64(info: i64) -> f64;
	fn call_stack_pop_str(info: i64) -> i64;
	fn call_stack_pop_bool(info: i64) -> i32;
	fn call_stack_pop_object(info: i64) -> i64;
	fn call_stack_pop_vec2(info: i64) -> i64;
	fn call_stack_pop_size(info: i64) -> i64;
	fn call_stack_pop(info: i64) -> i32;
	fn call_stack_front_i64(info: i64) -> i32;
	fn call_stack_front_f64(info: i64) -> i32;
	fn call_stack_front_str(info: i64) -> i32;
	fn call_stack_front_bool(info: i64) -> i32;
	fn call_stack_front_object(info: i64) -> i32;
	fn call_stack_front_vec2(info: i64) -> i32;
	fn call_stack_front_size(info: i64) -> i32;
}

#[repr(C)]
#[derive(Clone, Copy)]
#[derive(PartialEq)]
pub struct Vec2 {
	pub x: f32,
	pub y: f32
}

impl Vec2 {
	pub fn from(value: i64) -> Vec2 {
		unsafe { LightValue { value: value }.vec2 }
	}
	pub fn zero() -> Vec2 {
		Vec2 { x: 0.0, y: 0.0 }
	}
	pub fn into_i64(&self) -> i64 {
		unsafe { LightValue { vec2: *self }.value }
	}
	pub fn is_zero(&self) -> bool {
		self.x == 0.0 && self.y == 0.0
	}
}

#[repr(C)]
#[derive(Clone, Copy)]
#[derive(PartialEq)]
pub struct Size {
	pub width: f32,
	pub height: f32
}

impl Size {
	pub fn from(value: i64) -> Size {
		unsafe { LightValue { value: value }.size }
	}
	pub fn zero() -> Size {
		Size { width: 0.0, height: 0.0 }
	}
	pub fn into_i64(&self) -> i64 {
		unsafe { LightValue { size: *self }.value }
	}
	pub fn is_zero(&self) -> bool {
		self.width == 0.0 && self.height == 0.0
	}
}

#[repr(C)]
union LightValue {
	vec2: Vec2,
	size: Size,
	value: i64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct Color {
	pub r: u8,
	pub g: u8,
	pub b: u8,
	pub a: u8
}

#[repr(C)]
union ColorValue {
	color: Color,
	value: i32,
}

impl Color {
	pub fn new(argb: u32) -> Color {
		let a = argb >> 24;
		let r = (argb & 0x00ff0000) >> 16;
		let g = (argb & 0x0000ff00) >> 8;
		let b = argb & 0x000000ff;
		Color { r: r as u8, g: g as u8, b: b as u8, a: a as u8 }
	}
	pub fn from(agbr: i32) -> Color {
		unsafe { ColorValue{ value: agbr }.color }
	}
	pub fn to_argb(&self) -> u32 {
		(self.a as u32) << 24 | (self.r as u32) << 16 | (self.g as u32) << 8 | self.b as u32
	}
	pub fn to_color3(&self) -> Color3 {
		Color3 { r: self.r, g: self.g, b: self.b }
	}
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct Color3 {
	pub r: u8,
	pub g: u8,
	pub b: u8
}

#[repr(C)]
#[derive(Clone, Copy)]
struct Color3a {
	color3: Color3,
	a: u8
}

#[repr(C)]
union Color3Value {
	color3a: Color3a,
	value: i32,
}

impl Color3 {
	pub fn new(rgb: u32) -> Color3 {
		let r = (rgb & 0x00ff0000) >> 16;
		let g = (rgb & 0x0000ff00) >> 8;
		let b = rgb & 0x000000ff;
		Color3 { r: r as u8, g: g as u8, b: b as u8 }
	}
	pub fn from(gbr: i32) -> Color3 {
		unsafe { Color3Value { value: gbr }.color3a.color3 }
	}
	pub fn to_rgb(&self) -> u32 {
		(self.r as u32) << 16 | (self.g as u32) << 8 | self.b as u32
	}
}

fn to_string(str: i64) -> String {
	unsafe {
		let len = str_len(str) as usize;
		let mut vec = Vec::with_capacity(len as usize);
		vec.resize(len, 0);
		let data = vec.as_mut_ptr() as *mut c_void;
		str_read(data, str);
		str_release(str);
		return String::from_utf8(vec).unwrap();
	}
}

fn from_string(s: &str) -> i64 {
	unsafe {
		let len = s.len() as i32;
		let ptr = s.as_ptr();
		let new_str = str_new(len);
		str_write(new_str, ptr as *const c_void);
		return new_str;
	}
}

pub struct Vector;

impl Vector {
	pub fn to_i32(v: i64) -> Vec<i32> {
		unsafe {
			let len = buf_len(v) as usize;
			let mut vec: Vec<i32> = Vec::with_capacity(len as usize);
			vec.resize(len, Default::default());
			let data = vec.as_mut_ptr() as *mut c_void;
			buf_read(data, v);
			buf_release(v);
			return vec;
		}
	}
	pub fn to_i64(v: i64) -> Vec<i64> {
		unsafe {
			let len = buf_len(v) as usize;
			let mut vec: Vec<i64> = Vec::with_capacity(len as usize);
			vec.resize(len, Default::default());
			let data = vec.as_mut_ptr() as *mut c_void;
			buf_read(data, v);
			buf_release(v);
			return vec;
		}
	}
	pub fn to_f32(v: i64) -> Vec<f32> {
		unsafe {
			let len = buf_len(v) as usize;
			let mut vec: Vec<f32> = Vec::with_capacity(len as usize);
			vec.resize(len, Default::default());
			let data = vec.as_mut_ptr() as *mut c_void;
			buf_read(data, v);
			buf_release(v);
			return vec;
		}
	}
	pub fn to_f64(v: i64) -> Vec<f64> {
		unsafe {
			let len = buf_len(v) as usize;
			let mut vec: Vec<f64> = Vec::with_capacity(len as usize);
			vec.resize(len, Default::default());
			let data = vec.as_mut_ptr() as *mut c_void;
			buf_read(data, v);
			buf_release(v);
			return vec;
		}
	}
	pub fn to_str(v: i64) -> Vec<String> {
		unsafe {
			let len = buf_len(v) as usize;
			let mut vec: Vec<i64> = Vec::with_capacity(len as usize);
			vec.resize(len, Default::default());
			let data = vec.as_mut_ptr() as *mut c_void;
			buf_read(data, v);
			let mut strs = Vec::with_capacity(vec.len());
			for i in 0..vec.len() {
				strs.push(to_string(vec[i]));
			}
			buf_release(v);
			strs
		}
	}
	pub fn from_i32(s: &Vec<i32>) -> i64 {
		unsafe {
			let len = s.len() as i32;
			let ptr = s.as_ptr();
			let new_vec = buf_new_i32(len);
			buf_write(new_vec, ptr as *const c_void);
			return new_vec;
		}
	}
	pub fn from_i64(s: &Vec<i64>) -> i64 {
		unsafe {
			let len = s.len() as i32;
			let ptr = s.as_ptr();
			let new_vec = buf_new_i64(len);
			buf_write(new_vec, ptr as *const c_void);
			return new_vec;
		}
	}
	pub fn from_f32(s: &Vec<f32>) -> i64 {
		unsafe {
			let len = s.len() as i32;
			let ptr = s.as_ptr();
			let new_vec = buf_new_f32(len);
			buf_write(new_vec, ptr as *const c_void);
			return new_vec;
		}
	}
	pub fn from_f64(s: &Vec<f64>) -> i64 {
		unsafe {
			let len = s.len() as i32;
			let ptr = s.as_ptr();
			let new_vec = buf_new_f64(len);
			buf_write(new_vec, ptr as *const c_void);
			return new_vec;
		}
	}
	pub fn from_str(s: &Vec<&str>) -> i64 {
		unsafe {
			let len = s.len() as i32;
			let mut strs: Vec<i64> = Vec::with_capacity(s.len());
			for i in 0..s.len() {
				strs.push(from_string(s[i]));
			}
			let ptr = strs.as_ptr();
			let new_vec = buf_new_i64(len);
			buf_write(new_vec, ptr as *const c_void);
			return new_vec;
		}
	}
	pub fn from_vec2(s: &Vec<Vec2>) -> i64 {
		unsafe {
			let len = s.len() as i32;
			let mut vs: Vec<i64> = Vec::with_capacity(s.len());
			for i in 0..s.len() {
				vs.push(LightValue { vec2: s[i] }.value);
			}
			let ptr = vs.as_ptr();
			let new_vec = buf_new_i64(len);
			buf_write(new_vec, ptr as *const c_void);
			return new_vec;
		}
	}
	pub fn from_vertex_color(s: &Vec<VertexColor>) -> i64 {
		unsafe {
			let len = s.len() as i32;
			let mut vs: Vec<i64> = Vec::with_capacity(s.len());
			for i in 0..s.len() {
				vs.push(s[i].raw());
			}
			let ptr = vs.as_ptr();
			let new_vec = buf_new_i64(len);
			buf_write(new_vec, ptr as *const c_void);
			return new_vec;
		}
	}
	pub fn from_action_def(s: &Vec<ActionDef>) -> i64 {
		unsafe {
			let len = s.len() as i32;
			let mut vs: Vec<i64> = Vec::with_capacity(s.len());
			for i in 0..s.len() {
				vs.push(s[i].raw());
			}
			let ptr = vs.as_ptr();
			let new_vec = buf_new_i64(len);
			buf_write(new_vec, ptr as *const c_void);
			return new_vec;
		}
	}
	pub fn from_btree(s: &Vec<platformer::behavior::Tree>) -> i64 {
		unsafe {
			let len = s.len() as i32;
			let mut vs: Vec<i64> = Vec::with_capacity(s.len());
			for i in 0..s.len() {
				vs.push(s[i].raw());
			}
			let ptr = vs.as_ptr();
			let new_vec = buf_new_i64(len);
			buf_write(new_vec, ptr as *const c_void);
			return new_vec;
		}
	}
	pub fn from_dtree(s: &Vec<platformer::decision::Tree>) -> i64 {
		unsafe {
			let len = s.len() as i32;
			let mut vs: Vec<i64> = Vec::with_capacity(s.len());
			for i in 0..s.len() {
				vs.push(s[i].raw());
			}
			let ptr = vs.as_ptr();
			let new_vec = buf_new_i64(len);
			buf_write(new_vec, ptr as *const c_void);
			return new_vec;
		}
	}
}

fn get_object(raw: i64) -> Option<Box<dyn IObject>> {
	unsafe { OBJECT_MAP[object_get_type(raw) as usize](raw) }
}

fn push_function(func: Box<dyn FnMut()>) -> i32 {
	unsafe {
		if let Some(func_id) = FUNC_AVAILABLE.pop() {
			FUNC_MAP[func_id as usize] = func;
			func_id
		} else {
			FUNC_MAP.push(func);
			(FUNC_MAP.len() - 1) as i32
		}
	}
}

#[no_mangle]
pub extern fn call_function(func_id: i32) {
	unsafe { FUNC_MAP[func_id as usize](); }
}

fn dummy_func() {
	panic!("the dummy function should not be called.");
}

#[no_mangle]
pub extern fn deref_function(func_id: i32) {
	unsafe {
		FUNC_MAP[func_id as usize] = Box::new(dummy_func);
		FUNC_AVAILABLE.push(func_id);
	}
}

pub trait IObject {
	fn raw(&self) -> i64;
	fn obj(&self) -> &dyn IObject;
	fn get_id(&self) -> i32 { unsafe { object_get_id(self.raw()) } }
	fn as_any(&self) -> &dyn Any;
}

pub struct Object { raw: i64 }
impl IObject for Object {
	fn raw(&self) -> i64 { self.raw }
	fn obj(&self) -> &dyn IObject { self }
	fn as_any(&self) -> &dyn std::any::Any { self }
}
impl Drop for Object {
	fn drop(&mut self) { unsafe { crate::dora::object_release(self.raw); } }
}
impl Clone for Object {
	fn clone(&self) -> Object {
		unsafe { crate::dora::object_retain(self.raw); }
		Object { raw: self.raw }
	}
}
impl Object {
	pub fn from(raw: i64) -> Option<Object> {
		match raw {
			0 => None,
			_ => Some(Object { raw: raw })
		}
	}
}

pub fn cast<T: Clone + 'static>(obj: &dyn IObject) -> Option<T> {
	Some(obj.as_any().downcast_ref::<T>()?.clone())
}

pub struct CallStack { raw: i64 }

pub enum DoraValue<'a> {
	I32(i32),
	I64(i64),
	F32(f32),
	F64(f64),
	Bool(bool),
	Str(&'a str),
	Object(&'a dyn IObject),
	Vec2(Vec2),
	Size(Size),
}

pub trait IntoValue<'a> {
	fn dora_val(self) -> DoraValue<'a>;
	fn val(self) -> Value;
}

impl<'a> DoraValue<'a> {
	pub fn push(self, info: &mut CallStack) {
		match self {
			DoraValue::I32(x) => { info.push_i32(x); },
			DoraValue::I64(x) => { info.push_i64(x); },
			DoraValue::F32(x) => { info.push_f32(x); },
			DoraValue::F64(x) => { info.push_f64(x); },
			DoraValue::Bool(x) => { info.push_bool(x); },
			DoraValue::Str(x) => { info.push_str(x); },
			DoraValue::Object(x) => { info.push_object(x); },
			DoraValue::Vec2(x) => { info.push_vec2(&x); },
			DoraValue::Size(x) => { info.push_size(&x); },
		}
	}
}

impl<'a> IntoValue<'a> for i32 {
	fn dora_val(self) -> DoraValue<'a> { DoraValue::I32(self) }
	fn val(self) -> Value {
		unsafe { Value{ raw: value_create_i64(self as i64) } }
	}
}

impl<'a> IntoValue<'a> for i64 {
	fn dora_val(self) -> DoraValue<'a> { DoraValue::I64(self) }
	fn val(self) -> Value {
		unsafe { Value{ raw: value_create_i64(self) } }
	}
}

impl<'a> IntoValue<'a> for f32 {
	fn dora_val(self) -> DoraValue<'a> { DoraValue::F32(self) }
	fn val(self) -> Value {
		unsafe { Value{ raw: value_create_f64(self as f64) } }
	}
}

impl<'a> IntoValue<'a> for f64 {
	fn dora_val(self) -> DoraValue<'a> { DoraValue::F64(self) }
	fn val(self) -> Value {
		unsafe { Value{ raw: value_create_f64(self) } }
	}
}

impl<'a> IntoValue<'a> for bool {
	fn dora_val(self) -> DoraValue<'a> { DoraValue::Bool(self) }
	fn val(self) -> Value {
		unsafe { Value{ raw: value_create_bool(if self { 1 } else { 0 }) } }
	}
}

impl<'a> IntoValue<'a> for &'a str {
	fn dora_val(self) -> DoraValue<'a> { DoraValue::Str(self) }
	fn val(self) -> Value {
		unsafe { Value{ raw: value_create_str(from_string(self)) } }
	}
}

impl<'a> IntoValue<'a> for &'a dyn IObject {
	fn dora_val(self) -> DoraValue<'a> { DoraValue::Object(self) }
	fn val(self) -> Value {
		unsafe { Value{ raw: value_create_object(self.raw()) } }
	}
}

impl<'a> IntoValue<'a> for Vec2 {
	fn dora_val(self) -> DoraValue<'a> { DoraValue::Vec2(self) }
	fn val(self) -> Value {
		unsafe { Value{ raw: value_create_vec2(self.into_i64()) } }
	}
}

impl<'a> IntoValue<'a> for Size {
	fn dora_val(self) -> DoraValue<'a> { DoraValue::Size(self) }
	fn val(self) -> Value {
		unsafe { Value{ raw: value_create_size(self.into_i64()) } }
	}
}

#[macro_export]
macro_rules! args {
	( $( $x:expr ),* ) => {
		{
			let mut stack = crate::dora::CallStack::new();
			$(
				crate::dora::Value::new($x).push(&mut stack);
			)*
			stack
		}
	};
}

#[macro_export]
macro_rules! dora_object {
	($name: ident) => {
		paste::paste! {
			 impl IObject for $name {
				fn raw(&self) -> i64 { self.raw }
				fn obj(&self) -> &dyn IObject { self }
				fn as_any(&self) -> &dyn std::any::Any { self }
			}
			impl Drop for $name {
				fn drop(&mut self) { unsafe { crate::dora::object_release(self.raw); } }
			}
			impl Clone for $name {
				fn clone(&self) -> $name {
					unsafe { crate::dora::object_retain(self.raw); }
					$name { raw: self.raw }
				}
			}
			impl $name {
				pub fn from(raw: i64) -> Option<$name> {
					match raw {
						0 => None,
						_ => Some($name { raw: raw })
					}
				}
			}
		}
	};
}

// Value

pub struct Value { raw: i64 }

impl Value {
	pub fn new<'a, A>(value: A) -> DoraValue<'a>
		where A: IntoValue<'a> {
		value.dora_val()
	}
	fn from(raw: i64) -> Option<Value> {
		match raw {
			0 => { None },
			_ => { Some(Value { raw: raw }) }
		}
	}
	pub fn raw(&self) -> i64 { self.raw }
	pub fn into_i32(&self) -> Option<i32> {
		unsafe {
			if value_is_i64(self.raw) != 0 {
				Some(value_into_i64(self.raw) as i32)
			} else { None }
		}
	}
	pub fn into_i64(&self) -> Option<i64> {
		unsafe {
			if value_is_i64(self.raw) != 0 {
				Some(value_into_i64(self.raw))
			} else { None }
		}
	}
	pub fn into_f32(&self) -> Option<f32> {
		unsafe {
			if value_is_f64(self.raw) != 0 {
				Some(value_into_f64(self.raw) as f32)
			} else { None }
		}
	}
	pub fn into_f64(&self) -> Option<f64> {
		unsafe {
			if value_is_f64(self.raw) != 0 {
				Some(value_into_f64(self.raw))
			} else { None }
		}
	}
	pub fn into_bool(&self) -> Option<bool> {
		unsafe {
			if value_is_bool(self.raw) != 0 {
				Some(value_into_bool(self.raw) != 0)
			} else { None }
		}
	}
	pub fn into_str(&self) -> Option<String> {
		unsafe {
			if value_is_str(self.raw) != 0 {
				Some(to_string(value_into_str(self.raw)))
			} else { None }
		}
	}
	pub fn into_object(&self) -> Option<Box<dyn IObject>> {
		unsafe {
			if value_is_object(self.raw) != 0 {
				get_object(value_into_object(self.raw))
			} else { None }
		}
	}
	pub fn into_vec2(&self) -> Option<Vec2> {
		unsafe {
			if value_is_vec2(self.raw) != 0 {
				Some(Vec2::from(value_into_vec2(self.raw)))
			} else { None }
		}
	}
	pub fn into_size(&self) -> Option<Size> {
		unsafe {
			if value_is_size(self.raw) != 0 {
				Some(Size::from(value_into_size(self.raw)))
			} else { None }
		}
	}
	pub fn cast<T: Clone + 'static>(&self) -> Option<T> {
		cast::<T>(self.into_object()?.as_ref())
	}
}

impl Drop for Value {
	fn drop(&mut self) { unsafe { value_release(self.raw); } }
}

// CallStack

impl CallStack {
	fn raw(&self) -> i64 {
		self.raw
	}
	pub fn new() -> CallStack {
		CallStack { raw: unsafe { call_stack_create() } }
	}
	pub fn push_i32(&mut self, value: i32) {
		unsafe { call_stack_push_i64(self.raw, value as i64); }
	}
	pub fn push_i64(&mut self, value: i64) {
		unsafe { call_stack_push_i64(self.raw, value); }
	}
	pub fn push_f32(&mut self, value: f32) {
		unsafe { call_stack_push_f64(self.raw, value as f64); }
	}
	pub fn push_f64(&mut self, value: f64) {
		unsafe { call_stack_push_f64(self.raw, value); }
	}
	pub fn push_str(&mut self, value: &str) {
		unsafe { call_stack_push_str(self.raw, from_string(value)); }
	}
	pub fn push_bool(&mut self, value: bool) {
		unsafe { call_stack_push_bool(self.raw, if value { 1 } else { 0 }); }
	}
	pub fn push_object(&mut self, value: &dyn IObject) {
		unsafe { call_stack_push_object(self.raw, value.raw()); }
	}
	pub fn push_vec2(&mut self, value: &Vec2) {
		unsafe { call_stack_push_vec2(self.raw, value.into_i64()); }
	}
	pub fn push_size(&mut self, value: &Size) {
		unsafe { call_stack_push_size(self.raw, value.into_i64()); }
	}
	pub fn pop_i32(&mut self) -> Option<i32> {
		unsafe {
			if call_stack_front_i64(self.raw) != 0 {
				Some(call_stack_pop_i64(self.raw) as i32)
			} else { None }
		}
	}
	pub fn pop_i64(&mut self) -> Option<i64> {
		unsafe {
			if call_stack_front_i64(self.raw) != 0 {
				Some(call_stack_pop_i64(self.raw))
			} else { None }
		}
	}
	pub fn pop_f32(&mut self) -> Option<f32> {
		unsafe {
			if call_stack_front_f64(self.raw) != 0 {
				Some(call_stack_pop_f64(self.raw) as f32)
			} else { None }
		}
	}
	pub fn pop_f64(&mut self) -> Option<f64> {
		unsafe {
			if call_stack_front_f64(self.raw) != 0 {
				Some(call_stack_pop_f64(self.raw))
			} else { None }
		}
	}
	pub fn pop_str(&mut self) -> Option<String> {
		unsafe {
			if call_stack_front_str(self.raw) != 0 {
				Some(to_string(call_stack_pop_str(self.raw)))
			} else { None }
		}
	}
	pub fn pop_bool(&mut self) -> Option<bool> {
		unsafe {
			if call_stack_front_bool(self.raw) != 0 {
				Some(call_stack_pop_bool(self.raw) != 0)
			} else { None }
		}
	}
	pub fn pop_object(&mut self) -> Option<Box<dyn IObject>> {
		unsafe {
			if call_stack_front_object(self.raw) != 0 {
				let raw = call_stack_pop_object(self.raw);
				get_object(raw)
			} else { None }
		}
	}
	pub fn pop_cast<T: Clone + 'static>(&mut self) -> Option<T> {
		unsafe {
			if call_stack_front_object(self.raw) != 0 {
				let raw = call_stack_pop_object(self.raw);
				cast::<T>(get_object(raw)?.as_ref())
			} else { None }
		}
	}
	pub fn pop_vec2(&mut self) -> Option<Vec2> {
		unsafe {
			if call_stack_front_vec2(self.raw) != 0 {
				Some(Vec2::from(call_stack_pop_vec2(self.raw)))
			} else { None }
		}
	}
	pub fn pop_size(&mut self) -> Option<Size> {
		unsafe {
			if call_stack_front_size(self.raw) != 0 {
				Some(Size::from(call_stack_pop_size(self.raw)))
			} else { None }
		}
	}
	pub fn pop(&mut self) {
		if unsafe { call_stack_pop(self.raw) } == 0 {
			panic!("pop from empty call stack!");
		}
	}
}

impl Drop for CallStack {
	fn drop(&mut self) { unsafe { call_stack_release(self.raw); } }
}

// Array

extern "C" {
	fn array_set(array: i64, index: i32, item: i64) -> i32;
	fn array_get(array: i64, index: i32) -> i64;
	fn array_first(array: i64) -> i64;
	fn array_last(array: i64) -> i64;
	fn array_random_object(array: i64) -> i64;
	fn array_add(array: i64, item: i64);
	fn array_insert(array: i64, index: i32, item: i64);
	fn array_contains(array: i64, item: i64) -> i32;
	fn array_index(array: i64, item: i64) -> i32;
	fn array_remove_last(array: i64) -> i64;
	fn array_fast_remove(array: i64, item: i64) -> i32;
}

impl Array {
	pub fn set<'a, T>(&mut self, index: i32, v: T) where T: IntoValue<'a> {
		if unsafe { array_set(self.raw(), index, v.val().raw()) == 0 } {
			panic!("Out of bounds, expecting [0, {}), got {}", self.get_count(), index);
		}
	}
	pub fn get(&self, index: i32) -> Option<Value> {
		Value::from(unsafe { array_get(self.raw(), index) })
	}
	pub fn first(&self) -> Option<Value> {
		Value::from(unsafe { array_first(self.raw()) })
	}
	pub fn last(&self) -> Option<Value> {
		Value::from(unsafe { array_last(self.raw()) })
	}
	pub fn random_object(&self) -> Option<Value> {
		Value::from(unsafe { array_random_object(self.raw()) })
	}
	pub fn add<'a, T>(&mut self, v: T) where T: IntoValue<'a> {
		unsafe { array_add(self.raw(), v.val().raw()); }
	}
	pub fn insert<'a, T>(&mut self, index: i32, v: T) where T: IntoValue<'a> {
		unsafe { array_insert(self.raw(), index, v.val().raw()); }
	}
	pub fn contains<'a, T>(&self, v: T) -> bool where T: IntoValue<'a> {
		unsafe { array_contains(self.raw(), v.val().raw()) != 0 }
	}
	pub fn index<'a, T>(&self, v: T) -> i32 where T: IntoValue<'a> {
		unsafe { array_index(self.raw(), v.val().raw()) }
	}
	pub fn remove_last(&mut self) -> Option<Value> {
		Value::from(unsafe { array_remove_last(self.raw()) })
	}
	pub fn fast_remove<'a, T>(&mut self, v: T) -> bool where T: IntoValue<'a> {
		unsafe { array_fast_remove(self.raw(), v.val().raw()) != 0 }
	}
}

// Dictionary

extern "C" {
	fn dictionary_set(dict: i64, key: i64, value: i64);
	fn dictionary_get(dict: i64, key: i64) -> i64;
}

impl Dictionary {
	pub fn set<'a, T>(&mut self, key: &str, v: T) where T: IntoValue<'a> {
		unsafe { dictionary_set(self.raw(), from_string(key), v.val().raw()); }
	}
	pub fn get(&self, key: &str) -> Option<Value> {
		Value::from(unsafe { dictionary_get(self.raw(), from_string(key)) })
	}
}

// Entity

extern "C" {
	fn entity_set(e: i64, k: i64, v: i64);
	fn entity_get(e: i64, k: i64) -> i64;
	fn entity_get_old(e: i64, k: i64) -> i64;
}

impl Entity {
	pub fn set<'a, T>(&mut self, key: &str, value: T) where T: IntoValue<'a> {
		unsafe { entity_set(self.raw(), from_string(key), value.val().raw()); }
	}
	pub fn get(&self, key: &str) -> Option<Value> {
		Value::from(unsafe { entity_get(self.raw(), from_string(key)) })
	}
	pub fn get_old(&self, key: &str) -> Option<Value> {
		Value::from(unsafe { entity_get_old(self.raw(), from_string(key)) })
	}
}

// EntityGroup

extern "C" {
	fn group_watch(group: i64, func: i32, stack: i64);
}

impl Group {
	pub fn watch(&mut self, mut func: Box<dyn FnMut(&mut CallStack)>) {
		let mut stack = CallStack::new();
		let stack_raw = stack.raw();
		let func_id = push_function(Box::new(move || { func(&mut stack); }));
		unsafe { group_watch(self.raw(), func_id, stack_raw); }
	}
	pub fn each(&self, func: Box<dyn FnMut(&Entity) -> bool>) -> bool {
		match self.find(func) {
			Some(_) => true,
			None => false
		}
	}
}

// Observer

extern "C" {
	fn observer_watch(observer: i64, func: i32, stack: i64);
}

#[repr(i32)]
pub enum EntityEvent {
	Add = 1,
	Change = 2,
	AddOrChange = 3,
	Remove = 4
}

impl Observer {
	pub fn watch(&mut self, mut func: Box<dyn FnMut(&mut CallStack)>) {
		let mut stack = CallStack::new();
		let stack_raw = stack.raw();
		let func_id = push_function(Box::new(move || { func(&mut stack); }));
		unsafe { observer_watch(self.raw(), func_id, stack_raw); }
	}
}

// Node

extern "C" {
	fn node_emit(node: i64, name: i64, stack: i64);
}

impl Node {
	pub fn emit(&mut self, name: &str, stack: CallStack) {
		unsafe { node_emit(self.raw(), from_string(name), stack.raw()); }
	}
}

// Sprite
#[repr(i32)]
pub enum TextureWrap {
	None = 0,
	Mirror = 1,
	Clamp = 2,
	Border = 3,
}

#[repr(i32)]
pub enum TextureFilter {
	None = 0,
	Point = 1,
	Anisotropic = 2,
}

// Ease

#[repr(i32)]
pub enum EaseType {
	Linear = 0,
	InQuad = 1,
	OutQuad = 2,
	InOutQuad = 3,
	InCubic = 4,
	OutCubic = 5,
	InOutCubic = 6,
	InQuart = 7,
	OutQuart = 8,
	InOutQuart = 9,
	InQuint = 10,
	OutQuint = 11,
	InOutQuint = 12,
	InSine = 13,
	OutSine = 14,
	InOutSine = 15,
	InExpo = 16,
	OutExpo = 17,
	InOutExpo = 18,
	InCirc = 19,
	OutCirc = 20,
	InOutCirc = 21,
	InElastic = 22,
	OutElastic = 23,
	InOutElastic = 24,
	InBack = 25,
	OutBack = 26,
	InOutBack = 27,
	InBounce = 28,
	OutBounce = 29,
	InOutBounce = 30,
	OutInQuad = 31,
	OutInCubic = 32,
	OutInQuart = 33,
	OutInQuint = 34,
	OutInSine = 35,
	OutInExpo = 36,
	OutInCirc = 37,
	OutInElastic = 38,
	OutInBack = 39,
	OutInBounce = 40,
}

#[repr(i32)]
pub enum Property {
	X = 0,
	Y = 1,
	Z = 2,
	Angle = 3,
	AngleX = 4,
	AngleY = 5,
	ScaleX = 6,
	ScaleY = 7,
	SkewX = 8,
	SkewY = 9,
	Width = 10,
	Height = 11,
	AnchorX = 12,
	AnchorY = 13,
	Opacity = 14,
}

// Label

#[repr(i32)]
pub enum TextAlign {
	Left = 0,
	Center = 1,
	Right = 2,
}
