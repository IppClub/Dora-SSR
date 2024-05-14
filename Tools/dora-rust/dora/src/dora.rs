/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

use std::{ffi::c_void, any::Any};
use once_cell::sync::Lazy;
use core::ptr::addr_of_mut;

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
mod align_node;
pub use align_node::AlignNode;
mod effek_node;
pub use effek_node::EffekNode;
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
mod controller;
pub use controller::Controller;
mod svg;
pub use svg::SVG;
mod dbquery;
pub use dbquery::DBQuery;
mod dbparams;
pub use dbparams::DBParams;
mod dbrecord;
pub use dbrecord::DBRecord;
mod db;
pub use db::DB;
mod work_book;
pub use work_book::WorkBook;
mod work_sheet;
pub use work_sheet::WorkSheet;
mod c_45;
mod q_learner;
pub mod ml {
	pub use super::c_45::C45;
	pub use super::q_learner::QLearner;
}
mod http_client;
pub use http_client::HttpClient;
pub mod platformer;
mod buffer;
pub use buffer::Buffer;
mod im_gui;
pub use im_gui::ImGui;

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
		Action::type_info(),
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
		AlignNode::type_info(),
		EffekNode::type_info(),
		PhysicsWorld::type_info(),
		FixtureDef::type_info(),
		BodyDef::type_info(),
		Sensor::type_info(),
		Body::type_info(),
		JointDef::type_info(),
		Joint::type_info(),
		MotorJoint::type_info(),
		MoveJoint::type_info(),
		SVG::type_info(),
		ml::QLearner::type_info(),
		platformer::ActionUpdate::type_info(),
		platformer::Face::type_info(),
		platformer::BulletDef::type_info(),
		platformer::Bullet::type_info(),
		platformer::Visual::type_info(),
		platformer::behavior::Tree::type_info(),
		platformer::decision::Tree::type_info(),
		platformer::Unit::type_info(),
		platformer::PlatformCamera::type_info(),
		platformer::PlatformWorld::type_info(),
		Buffer::type_info(),
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

	fn dora_print(msg: i64);

	fn vec2_add(a: i64, b: i64) -> i64;
	fn vec2_sub(a: i64, b: i64) -> i64;
	fn vec2_mul(a: i64, b: i64) -> i64;
	fn vec2_mul_float(a: i64, b: f32) -> i64;
	fn vec2_div(a: i64, b: f32) -> i64;
	fn vec2_distance(a: i64, b: i64) -> f32;
	fn vec2_distance_squared(a: i64, b: i64) -> f32;
	fn vec2_length(a: i64) -> f32;
	fn vec2_angle(a: i64) -> f32;
	fn vec2_normalize(a: i64) -> i64;
	fn vec2_perp(a: i64) -> i64;
	fn vec2_dot(a: i64, b: i64) -> f32;
	fn vec2_clamp(a: i64, from: i64, to: i64) -> i64;

	fn dora_emit(name: i64, stack: i64);
}

pub fn print(msg: &str) {
	unsafe { dora_print(from_string(msg)); }
}

/// Emits a global event with the given name and arguments to all listeners registered by `node.gslot()` function.
///
/// # Arguments
///
/// * eventName - The name of the event to emit.
/// * stack - The data to pass to the global event listeners.
///
/// # Example
///
/// ```
/// let mut node = Node::new();
/// node.gslot("MyGlobalEvent", Box::new(|stack| {
/// 	let (arg1, arg2) = match (stack.pop_str(), stack.pop_i64()) {
/// 		(Some(arg1), Some(arg2)) => (arg1, arg2),
/// 		_ => return,
/// 	};
/// 	p!("Event triggered: {}, {}", arg1, arg2);
/// }));
///
/// emit("MyGlobalEvent", args!("Hello", 123));
/// ```
pub fn emit(name: &str, stack: CallStack) {
	unsafe { dora_emit(from_string(name), stack.raw()); }
}

#[macro_export]
macro_rules! p {
	() => {
		dora_ssr::print("\n")
	};
	($($arg:tt)*) => {{
		dora_ssr::print((format!($($arg)*) + "\n").as_str());
	}};
}

/// A record representing a 2D vector with an x and y component.
#[repr(C)]
#[derive(Clone, Copy)]
#[derive(PartialEq)]
pub struct Vec2 {
	pub x: f32,
	pub y: f32
}

impl Vec2 {
	pub(crate) fn from(value: i64) -> Vec2 {
		unsafe { LightValue { value: value }.vec2 }
	}
	pub(crate) fn into_i64(&self) -> i64 {
		unsafe { LightValue { vec2: *self }.value }
	}
	pub fn new(x: f32, y: f32) -> Vec2 {
		Vec2 { x: x, y: y }
	}
	pub fn zero() -> Vec2 {
		Vec2 { x: 0.0, y: 0.0 }
	}
	pub fn is_zero(&self) -> bool {
		self.x == 0.0 && self.y == 0.0
	}

	pub fn distance(&self, other: &Vec2) -> f32 {
		unsafe { vec2_distance(self.into_i64(), other.into_i64()) }
	}
	pub fn distance_squared(&self, other: &Vec2) -> f32 {
		unsafe { vec2_distance_squared(self.into_i64(), other.into_i64()) }
	}
	pub fn length(&self) -> f32 {
		unsafe { vec2_length(self.into_i64()) }
	}
	pub fn angle(&self) -> f32 {
		unsafe { vec2_angle(self.into_i64()) }
	}
	pub fn normalize(&self) -> Vec2 {
		Vec2::from(unsafe { vec2_normalize(self.into_i64()) })
	}
	pub fn perp(&self) -> Vec2 {
		Vec2::from(unsafe { vec2_perp(self.into_i64()) })
	}
	pub fn dot(&self, other: &Vec2) -> f32 {
		unsafe { vec2_dot(self.into_i64(), other.into_i64()) }
	}
	pub fn clamp(&self, from: &Vec2, to: &Vec2) -> Vec2 {
		Vec2::from(unsafe { vec2_clamp(self.into_i64(), from.into_i64(), to.into_i64()) })
	}
}

impl std::ops::Add for Vec2 {
	type Output = Vec2;
	fn add(self, other: Vec2) -> Vec2 {
		Vec2::from(unsafe { vec2_add(self.into_i64(), other.into_i64()) })
	}
}

impl std::ops::Sub for Vec2 {
	type Output = Vec2;
	fn sub(self, other: Vec2) -> Vec2 {
		Vec2::from(unsafe { vec2_sub(self.into_i64(), other.into_i64()) })
	}
}

impl std::ops::Mul for Vec2 {
	type Output = Vec2;
	fn mul(self, other: Vec2) -> Vec2 {
		Vec2::from(unsafe { vec2_mul(self.into_i64(), other.into_i64()) })
	}
}

impl std::ops::Mul<f32> for Vec2 {
	type Output = Vec2;
	fn mul(self, other: f32) -> Vec2 {
		Vec2::from(unsafe { vec2_mul_float(self.into_i64(), other) })
	}
}

impl std::ops::Div<f32> for Vec2 {
	type Output = Vec2;
	fn div(self, other: f32) -> Vec2 {
		Vec2::from(unsafe { vec2_div(self.into_i64(), other) })
	}
}

/// A size object with a given width and height.
#[repr(C)]
#[derive(Clone, Copy)]
#[derive(PartialEq)]
pub struct Size {
	pub width: f32,
	pub height: f32
}

impl Size {
	pub fn new(width: f32, height: f32) -> Size {
		Size { width: width, height: height }
	}
	pub fn zero() -> Size {
		Size { width: 0.0, height: 0.0 }
	}
	pub fn is_zero(&self) -> bool {
		self.width == 0.0 && self.height == 0.0
	}
	pub(crate) fn from(value: i64) -> Size {
		unsafe { LightValue { value: value }.size }
	}
	pub(crate) fn into_i64(&self) -> i64 {
		unsafe { LightValue { size: *self }.value }
	}
}

#[repr(C)]
union LightValue {
	vec2: Vec2,
	size: Size,
	value: i64,
}

/// A color with red, green, blue, and alpha channels.
#[repr(C)]
#[derive(Clone, Copy)]
pub struct Color {
	pub b: u8,
	pub g: u8,
	pub r: u8,
	pub a: u8
}

#[repr(C)]
union ColorValue {
	color: Color,
	value: i32,
}

impl Color {
	pub const WHITE: Color = Color { r: 255, g: 255, b: 255, a: 255 };
	pub const BLACK: Color = Color { r: 0, g: 0, b: 0, a: 255 };
	pub const TRANSPARENT: Color = Color { r: 0, g: 0, b: 0, a: 0 };
	pub fn new(argb: u32) -> Color {
		let a = argb >> 24;
		let r = (argb & 0x00ff0000) >> 16;
		let g = (argb & 0x0000ff00) >> 8;
		let b = argb & 0x000000ff;
		Color { r: r as u8, g: g as u8, b: b as u8, a: a as u8 }
	}
	pub fn from(argb: i32) -> Color {
		unsafe { ColorValue{ value: argb }.color }
	}
	pub fn to_argb(&self) -> u32 {
		(self.a as u32) << 24 | (self.r as u32) << 16 | (self.g as u32) << 8 | self.b as u32
	}
	pub fn to_color3(&self) -> Color3 {
		Color3 { r: self.r, g: self.g, b: self.b }
	}
}

/// A color with red, green and blue channels.
#[repr(C)]
#[derive(Clone, Copy)]
pub struct Color3 {
	pub b: u8,
	pub g: u8,
	pub r: u8
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
	pub const WHITE: Color3 = Color3 { r: 255, g: 255, b: 255 };
	pub const BLACK: Color3 = Color3 { r: 0, g: 0, b: 0 };
	pub fn new(rgb: u32) -> Color3 {
		let r = (rgb & 0x00ff0000) >> 16;
		let g = (rgb & 0x0000ff00) >> 8;
		let b = rgb & 0x000000ff;
		Color3 { r: r as u8, g: g as u8, b: b as u8 }
	}
	pub fn from(rgb: i32) -> Color3 {
		unsafe { Color3Value { value: rgb }.color3a.color3 }
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

pub(crate) trait IBuf {
	fn to_buf(&self) -> i64;
}

impl IBuf for Vec<i32> {
	fn to_buf(&self) -> i64 {
		unsafe {
			let len = self.len() as i32;
			let ptr = self.as_ptr();
			let new_vec = buf_new_i32(len);
			buf_write(new_vec, ptr as *const c_void);
			return new_vec;
		}
	}
}

impl IBuf for Vec<i64> {
	fn to_buf(&self) -> i64 {
		unsafe {
			let len = self.len() as i32;
			let ptr = self.as_ptr();
			let new_vec = buf_new_i64(len);
			buf_write(new_vec, ptr as *const c_void);
			return new_vec;
		}
	}
}

impl IBuf for Vec<f32> {
	fn to_buf(&self) -> i64 {
		unsafe {
			let len = self.len() as i32;
			let ptr = self.as_ptr();
			let new_vec = buf_new_f32(len);
			buf_write(new_vec, ptr as *const c_void);
			return new_vec;
		}
	}
}

impl IBuf for Vec<f64> {
	fn to_buf(&self) -> i64 {
		unsafe {
			let len = self.len() as i32;
			let ptr = self.as_ptr();
			let new_vec = buf_new_f64(len);
			buf_write(new_vec, ptr as *const c_void);
			return new_vec;
		}
	}
}

pub(crate) struct Vector;

impl Vector {
	pub fn to_num<T>(v: i64) -> Vec<T> where T: Clone + Default {
		unsafe {
			let len = buf_len(v) as usize;
			let mut vec: Vec<T> = Vec::with_capacity(len as usize);
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
	pub fn from_num<T: IBuf>(s: &T) -> i64 {
		return s.to_buf();
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

/// An argument stack for passing values to a function.
/// The stack is used to pass arguments to a function and to receive return values from a function.
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
			let mut stack = dora_ssr::CallStack::new();
			$(
				dora_ssr::Value::new($x).push(&mut stack);
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
	pub fn pop(&mut self) -> bool {
		if unsafe { call_stack_pop(self.raw) } == 0 {
			return false;
		}
		true
	}
}

impl Drop for CallStack {
	fn drop(&mut self) { unsafe { call_stack_release(self.raw); } }
}

/// An interface for providing Dora SSR built-in node event names.
pub struct Slot { }
impl Slot {
	/// The ActionEnd slot is triggered when an action is finished.
	/// Triggers after calling `node.run_action()`, `node.perform()`, `node.run_action_def()` and `node.perform_def()`.
	///
	/// # Callback Arguments
	///
	/// * action: Action - The finished action.
	/// * target: Node - The node that finished the action.
	///
	/// # Callback Example
	///
	/// ```
	/// node.perform_def(ActionDef::prop(1.0, 0.0, 100.0, Property::X, EaseType::Linear));
	/// node.slot(Slot::ACTION_END, Box::new(|stack| {
	/// 	let (
	/// 		action,
	/// 		target
	/// 	) = match (
	/// 		stack.pop_cast::<Action>,
	/// 		stack.pop_cast::<Node>()
	/// 	) {
	/// 		(Some(action), Some(target)) => (action, target),
	/// 		_ => return,
	/// 	};
	/// }));
	/// ```
	pub const ACTION_END: &'static str = "Action";
	/// The TapFilter slot is triggered before the TapBegan slot and can be used to filter out certain taps.
	/// Triggers after setting `node.set_touch_enabled(true)`.
	///
	/// # Callback Arguments
	///
	/// * touch: Touch - The touch that triggered the tap.
	///
	/// # Callback Example
	///
	/// ```
	/// node.set_touch_enabled(true);
	/// node.slot(Slot::TAP_FILTER, Box::new(|stack| {
	/// 	let touch = match stack.pop_cast::<Touch>() {
	/// 		Some(touch) => touch,
	/// 		None => return,
	/// 	};
	/// 	touch.set_enabled(false);
	/// }));
	/// ```
	pub const TAP_FILTER: &'static str = "TapFilter";
	/// The TapBegan slot is triggered when a tap is detected.
	/// Triggers after setting `node.set_touch_enabled(true)`.
	///
	/// # Callback Arguments
	///
	/// * touch: Touch - The touch that triggered the tap.
	///
	/// # Callback Example
	///
	/// ```
	/// node.set_touch_enabled(true);
	/// node.slot(Slot::TAP_BEGAN, Box::new(|stack| {
	/// 	let touch = match stack.pop_cast::<Touch>() {
	/// 		Some(touch) => touch,
	/// 		None => return,
	/// 	};
	/// }));
	/// ```
	pub const TAP_BEGAN: &'static str = "TapBegan";
	/// The TapEnded slot is triggered when a tap ends.
	/// Triggers after setting `node.set_touch_enabled(true)`.
	///
	/// # Callback Arguments
	///
	/// * touch: Touch - The touch that triggered the tap.
	///
	/// # Callback Example
	///
	/// ```
	/// node.set_touch_enabled(true);
	/// node.slot(Slot::TAP_ENDED, Box::new(|stack| {
	/// 	let touch = match stack.pop_cast::<Touch>() {
	/// 		Some(touch) => touch,
	/// 		None => return,
	/// 	};
	/// }));
	/// ```
	pub const TAP_ENDED: &'static str = "TapEnded";
	/// The Tapped slot is triggered when a tap is detected and has ended.
	/// Triggers after setting `node.set_touch_enabled(true)`.
	///
	/// # Callback Arguments
	///
	/// * touch: Touch - The touch that triggered the tap.
	///
	/// # Callback Example
	///
	/// ```
	/// node.set_touch_enabled(true);
	/// node.slot(Slot::TAPPED, Box::new(|stack| {
	/// 	let touch = match stack.pop_cast::<Touch>() {
	/// 		Some(touch) => touch,
	/// 		None => return,
	/// 	};
	/// }));
	/// ```
	pub const TAPPED: &'static str = "Tapped";
	/// The TapMoved slot is triggered when a tap moves.
	/// Triggers after setting `node.set_touch_enabled(true)`.
	///
	/// # Callback Arguments
	///
	/// * touch: Touch - The touch that triggered the tap.
	///
	/// # Callback Example
	///
	/// ```
	/// node.set_touch_enabled(true);
	/// node.slot(Slot::TAP_MOVED, Box::new(|stack| {
	/// 	let touch = match stack.pop_cast::<Touch>() {
	/// 		Some(touch) => touch,
	/// 		None => return,
	/// 	};
	/// }));
	/// ```
	pub const TAP_MOVED: &'static str = "TapMoved";
	/// The MouseWheel slot is triggered when the mouse wheel is scrolled.
	/// Triggers after setting `node.set_touch_enabled(true)`.
	///
	/// # Callback Arguments
	///
	/// * delta: Vec2 - The amount of scrolling that occurred.
	///
	/// # Callback Example
	///
	/// ```
	/// node.set_touch_enabled(true);
	/// node.slot(Slot::MOUSE_WHEEL, Box::new(|stack| {
	/// 	let delta = match stack.pop_vec2() {
	/// 		Some(delta) => delta,
	/// 		None => return,
	/// 	};
	/// }));
	/// ```
	pub const MOUSE_WHEEL: &'static str = "MouseWheel";
	/// The Gesture slot is triggered when a gesture is recognized.
	///
	/// # Callback Arguments
	///
	/// * center: Vec2 - The center of the gesture.
	/// * numFingers: i32 - The number of fingers involved in the gesture.
	/// * deltaDist: f32 - The distance the gesture has moved.
	/// * deltaAngle: f32 - The angle of the gesture.
	///
	/// # Callback Example
	///
	/// ```
	/// node.set_touch_enabled(true);
	/// node.slot(Slot::GESTURE, Box::new(|stack| {
	/// 	let (
	/// 		center,
	/// 		numFingers,
	/// 		deltaDist,
	/// 		deltaAngle
	/// 	) = match (
	/// 		stack.pop_vec2(),
	/// 		stack.pop_i32(),
	/// 		stack.pop_f32(),
	/// 		stack.pop_f32()
	/// 	) {
	/// 		(Some(center), Some(numFingers), Some(deltaDist), Some(deltaAngle)) => (center, numFingers, deltaDist, deltaAngle),
	/// 		_ => return,
	/// 	};
	/// }));
	/// ```
	pub const GESTURE: &'static str = "Gesture";
	/// The Enter slot is triggered when a node is added to the scene graph.
	/// Triggers when doing `node.add_child()`.
	pub const ENTER: &'static str = "Enter";
	/// The Exit slot is triggered when a node is removed from the scene graph.
	/// Triggers when doing `node.remove_child()`.
	pub const EXIT: &'static str = "Exit";
	/// The Cleanup slot is triggered when a node is cleaned up.
	/// Triggers only when doing `parent.remove_child(node, true)`.
	pub const CLEANUP: &'static str = "Cleanup";
	/// The KeyDown slot is triggered when a key is pressed down.
	/// Triggers after setting `node.set_keyboard_enabled(true)`.
	///
	/// # Callback Arguments
	///
	/// * keyName: String - The name of the key that was pressed.
	///
	/// # Callback Example
	///
	/// ```
	/// node.set_keyboard_enabled(true);
	/// node.slot(Slot::KEY_DOWN, Box::new(|stack| {
	/// 	let keyName = match stack.pop_str() {
	/// 		Some(keyName) => keyName,
	/// 		None => return,
	/// 	};
	/// 	if keyName == KeyName::Space.as_ref() {
	/// 		p!("Space key down!");
	/// 	}
	/// }));
	/// ```
	pub const KEY_DOWN: &'static str = "KeyDown";
	/// The KeyUp slot is triggered when a key is released.
	/// Triggers after setting `node.set_keyboard_enabled(true)`.
	///
	/// # Callback Arguments
	///
	/// * keyName: String - The name of the key that was released.
	///
	/// # Callback Example
	///
	/// ```
	/// node.set_keyboard_enabled(true);
	/// node.slot(Slot::KEY_UP, Box::new(|stack| {
	/// 	let keyName = match stack.pop_str() {
	/// 		Some(keyName) => keyName,
	/// 		None => return,
	/// 	};
	/// 	if keyName == KeyName::Space.as_ref() {
	/// 		p!("Space key up!");
	/// 	}
	/// }));
	/// ```
	pub const KEY_UP: &'static str = "KeyUp";
	/// The KeyPressed slot is triggered when a key is pressed.
	/// Triggers after setting `node.set_keyboard_enabled(true)`.
	///
	/// # Callback Arguments
	///
	/// * keyName: String - The name of the key that was pressed.
	///
	/// # Callback Example
	///
	/// ```
	/// node.set_keyboard_enabled(true);
	/// node.slot(Slot::KEY_PRESSED, Box::new(|stack| {
	/// 	let keyName = match stack.pop_str() {
	/// 		Some(keyName) => keyName,
	/// 		None => return,
	/// 	};
	/// 	if keyName == KeyName::Space.as_ref() {
	/// 		p!("Space key pressed!");
	/// 	}
	/// }));
	/// ```
	pub const KEY_PRESSED: &'static str = "KeyPressed";
	/// The AttachIME slot is triggered when the input method editor (IME) is attached (calling `node.attach_ime()`).
	pub const ATTACH_IME: &'static str = "AttachIME";
	/// The DetachIME slot is triggered when the input method editor (IME) is detached (calling `node.detach_ime()` or manually closing IME).
	pub const DETACH_IME: &'static str = "DetachIME";
	/// The TextInput slot is triggered when text input is received.
	/// Triggers after calling `node.attach_ime()`.
	///
	/// # Callback Arguments
	///
	/// * text: String - The text that was input.
	///
	/// # Callback Example
	///
	/// ```
	/// node.attach_ime();
	/// node.slot(Slot::TEXT_INPUT, Box::new(|stack| {
	/// 	let text = match stack.pop_str() {
	/// 		Some(text) => text,
	/// 		None => return,
	/// 	};
	/// 	p!(text);
	/// }));
	/// ```
	pub const TEXT_INPUT: &'static str = "TextInput";
	/// The TextEditing slot is triggered when text is being edited.
	/// Triggers after calling `node.attach_ime()`.
	///
	/// # Callback Arguments
	///
	/// * text: String - The text that is being edited.
	/// * startPos: i32 - The starting position of the text being edited.
	///
	/// # Callback Example
	///
	/// ```
	/// node.attach_ime();
	/// node.slot(Slot::TEXT_EDITING, Box::new(|stack| {
	/// 	let (
	/// 		text,
	/// 		startPos
	/// 	) = match (
	/// 		stack.pop_str(),
	/// 		stack.pop_i32()
	/// 	) {
	/// 		(Some(text), Some(startPos)) => (text, startPos),
	/// 		_ => return,
	/// 	};
	/// 	p!(text, startPos);
	/// }));
	/// ```
	pub const TEXT_EDITING: &'static str = "TextEditing";
	/// The ButtonDown slot is triggered when a game controller button is pressed down.
	/// Triggers after setting `node.set_controller_enabled(true)`.
	///
	/// # Callback Arguments
	///
	/// * controllerId: i32 - The controller id, incrementing from 0 when multiple controllers connected.
	/// * buttonName: String - The name of the button that was pressed.
	///
	/// # Callback Example
	///
	/// ```
	/// node.set_controller_enabled(true);
	/// node.slot(Slot::BUTTON_DOWN, Box::new(|stack| {
	/// 	let (
	/// 		controllerId,
	/// 		buttonName
	/// 	) = match (
	/// 		stack.pop_i32(),
	/// 		stack.pop_str()
	/// 	) {
	/// 		(Some(controllerId), Some(buttonName)) => (controllerId, buttonName),
	/// 		_ => return,
	/// 	};
	/// 	if controllerId == 0 && buttonName == ButtonName::DPUp.as_ref() {
	/// 		p!("DPad up button down!");
	/// 	}
	/// }));
	/// ```
	pub const BUTTON_DOWN: &'static str = "ButtonDown";
	/// The ButtonUp slot is triggered when a game controller button is released.
	/// Triggers after setting `node.set_controller_enabled(true)`.
	///
	/// # Callback Arguments
	///
	/// * controllerId: i32 - The controller id, incrementing from 0 when multiple controllers connected.
	/// * buttonName: String - The name of the button that was released.
	///
	/// # Callback Example
	///
	/// ```
	/// node.set_controller_enabled(true);
	/// node.slot(Slot::BUTTON_UP, Box::new(|stack| {
	/// 	let (
	/// 		controllerId,
	/// 		buttonName
	/// 	) = match (
	/// 		stack.pop_i32(),
	/// 		stack.pop_str()
	/// 	) {
	/// 		(Some(controllerId), Some(buttonName)) => (controllerId, buttonName),
	/// 		_ => return,
	/// 	};
	/// 	if controllerId == 0 && buttonName == ButtonName::DPUp.as_ref() {
	/// 		p!("DPad up button up!");
	/// 	}
	/// }));
	/// ```
	pub const BUTTON_UP: &'static str = "ButtonUp";
	/// The Axis slot is triggered when a game controller axis changed.
	/// Triggers after setting `node.set_controller_enabled(true)`.
	///
	/// # Callback Arguments
	///
	/// * controllerId: i32 - The controller id, incrementing from 0 when multiple controllers connected.
	/// * axisName: String - The name of the axis that changed.
	/// * axisValue: f32 - The controller axis value ranging from -1.0 to 1.0.
	///
	/// # Callback Example
	///
	/// ```
	/// node.set_controller_enabled(true);
	/// node.slot(Slot::AXIS, Box::new(|stack| {
	/// 	let (
	/// 		controllerId,
	/// 		axisName,
	/// 		axisValue
	/// 	) = match (
	/// 		stack.pop_i32(),
	/// 		stack.pop_str(),
	/// 		stack.pop_f32()
	/// 	) {
	/// 		(Some(controllerId), Some(axisName), Some(axisValue)) => (controllerId, axisName, axisValue),
	/// 		_ => return,
	/// 	};
	/// 	if controllerId == 0 && axisName == AxisName::LeftX.as_ref() {
	/// 		p!("Left stick x value {}", axisValue);
	/// 	}
	/// }));
	pub const AXIS: &'static str = "Axis";
	/// Triggers after an animation has ended on a Playable instance.
	///
	/// # Callback Arguments
	///
	/// * animationName: String - The name of the animation that ended.
	/// * target: Playable - The Playable instance that the animation was played on.
	///
	/// # Callback Example
	///
	/// ```
	/// playable.play("Walk", false);
	/// playable.slot(Slot::ANIMATION_END, Box::new(|stack| {
	/// 	let (
	/// 		animationName,
	/// 		target
	/// 	) = match (
	/// 		stack.pop_str(),
	/// 		stack.pop_cast::<Playable>()
	/// 	) {
	/// 		(Some(animationName), Some(target)) => (animationName, target),
	/// 		_ => return,
	/// 	};
	/// 	if animationName == "Walk" {
	/// 		target.play("Idle", true);
	/// 	}
	/// }));
	/// ```
	pub const ANIMATION_END: &'static str = "AnimationEnd";
	/// Triggers when a Body object collides with a sensor object.
	/// Triggers after setting `body.set_receiving_contact(true)`.
	///
	/// # Callback Arguments
	///
	/// * other: Body - The other Body object that the current Body is colliding with.
	/// * sensorTag: i32 - The tag of the sensor that triggered this collision.
	///
	/// # Callback Example
	///
	/// ```
	/// body.set_receiving_contact(true);
	/// body.slot(Slot::BODY_ENTER, Box::new(|stack| {
	/// 	let (
	/// 		other,
	/// 		sensorTag
	/// 	) = match (
	/// 		stack.pop_cast::<Body>(),
	/// 		stack.pop_i32()
	/// 	) {
	/// 		(Some(other), Some(sensorTag)) => (other, sensorTag),
	/// 		_ => return,
	/// 	};
	/// 	p!(sensorTag);
	/// }));
	/// ```
	pub const BODY_ENTER: &'static str = "BodyEnter";
	/// Triggers when a `Body` object is no longer colliding with a sensor object.
	/// Triggers after setting `body.set_receiving_contact(true)`.
	///
	/// # Callback Arguments
	///
	/// * other: Body - The other `Body` object that the current `Body` is no longer colliding with.
	/// * sensorTag: i32 - The tag of the sensor that triggered this collision.
	///
	/// # Callback Example
	///
	/// ```
	/// body.set_receiving_contact(true);
	/// body.slot(Slot::BODY_LEAVE, Box::new(|stack| {
	/// 	let (
	/// 		other,
	/// 		sensorTag
	/// 	) = match (
	/// 		stack.pop_cast::<Body>(),
	/// 		stack.pop_i32()
	/// 	) {
	/// 		(Some(other), Some(sensorTag)) => (other, sensorTag),
	/// 		_ => return,
	/// 	};
	/// 	p!(sensorTag);
	/// }));
	/// ```
	pub const BODY_LEAVE: &'static str = "BodyLeave";
	/// Triggers when a `Body` object starts to collide with another object.
	/// Triggers after setting `body.set_receiving_contact(true)`.
	///
	/// # Callback Arguments
	///
	/// * other: Body - The other `Body` object that the current `Body` is colliding with.
	/// * point: Vec2 - The point of collision in world coordinates.
	/// * normal: Vec2 - The normal vector of the contact surface in world coordinates.
	///
	/// # Callback Example
	///
	/// ```
	/// body.set_receiving_contact(true);
	/// body.slot(Slot::CONTACT_START, Box::new(|stack| {
	/// 	let (
	/// 		other,
	/// 		point,
	/// 		normal
	/// 	) = match (
	/// 		stack.pop_cast::<Body>(),
	/// 		stack.pop_vec2(),
	/// 		stack.pop_vec2()
	/// 	) {
	/// 		(Some(other), Some(point), Some(normal)) => (other, point, normal),
	/// 		_ => return,
	/// 	};
	/// }));
	/// ```
	pub const CONTACT_START: &'static str = "ContactStart";
	/// Triggers when a `Body` object stops colliding with another object.
	/// Triggers after setting `body.set_receiving_contact(true)`.
	///
	/// # Callback Arguments
	///
	/// * other: Body - The other `Body` object that the current `Body` is no longer colliding with.
	/// * point: Vec2 - The point of collision in world coordinates.
	/// * normal: Vec2 - The normal vector of the contact surface in world coordinates.
	///
	/// # Callback Example
	///
	/// ```
	/// body.set_receiving_contact(true);
	/// body.slot(Slot::CONTACT_START, Box::new(|stack| {
	/// 	let (
	/// 		other,
	/// 		point,
	/// 		normal
	/// 	) = match (
	/// 		stack.pop_cast::<Body>(),
	/// 		stack.pop_vec2(),
	/// 		stack.pop_vec2()
	/// 	) {
	/// 		(Some(other), Some(point), Some(normal)) => (other, point, normal),
	/// 		_ => return,
	/// 	};
	/// }));
	/// ```
	pub const CONTACT_END: &'static str = "ContactEnd";
	/// Triggered after a `Particle` node started a stop action and then all the active particles end their lives.
	pub const FINISHED: &'static str = "Finished";
	/// Triggers when the layout of the `AlignNode` is updated.
	///
	/// # Callback Arguments
	///
	/// * width: f32 - The width of the `AlignNode`.
	/// * height: f32 - The height of the `AlignNode`.
	///
	/// # Callback Example
	///
	/// ```
	/// align_node.slot(Slot::ALIGN_LAYOUT, Box::new(|stack| {
	/// 	let (
	/// 		width,
	/// 		height
	/// 	) = match (
	/// 		stack.pop_f32(),
	/// 		stack.pop_f32()
	/// 	) {
	/// 		(Some(width), Some(height)) => (width, height),
	/// 		_ => return,
	/// 	};
	/// 	p!("width: {}, height: {}", width, height);
	/// }));
	/// ```
	pub const ALIGN_LAYOUT: &'static str = "AlignLayout";
	/// Triggers when the `EffekseerNode` finishes playing an effect.
	///
	/// # Callback Arguments
	///
	/// * handle: i32 - The handle of the effect that finished playing.
	///
	/// # Callback Example
	///
	/// ```
	/// effekseer_node.slot(Slot::EFFEK_END, Box::new(|stack| {
	/// 	let handle = match stack.pop_i32() {
	/// 		Some(handle) => handle,
	/// 		None => return,
	/// 	};
	/// 	p!("Effect handle: {}", handle);
	/// }));
	/// ```
	pub const EFFEK_END: &'static str = "EffekEnd";
}

/// An interface for providing Dora SSR built-in global event names.
pub struct GSlot { }
impl GSlot {
	/// Triggers when the application is about to quit.
	pub const APP_QUIT: &'static str = "AppQuit";
	/// Triggers when the application receives a low memory warning.
	pub const APP_LOW_MEMORY: &'static str = "AppLowMemory";
	/// Triggers when the application is about to enter the background.
	pub const APP_WILL_ENTER_BACKGROUND: &'static str = "AppWillEnterBackground";
	/// Triggers when the application has entered the background.
	pub const APP_DID_ENTER_BACKGROUND: &'static str = "AppDidEnterBackground";
	/// Triggers when the application is about to enter the foreground.
	pub const APP_WILL_ENTER_FOREGROUND: &'static str = "AppWillEnterForeground";
	/// Triggers when the application has entered the foreground.
	pub const APP_DID_ENTER_FOREGROUND: &'static str = "AppDidEnterForeground";
	/// Triggers when the application window size changes.
	pub const APP_SIZE_CHANGED: &'static str = "AppSizeChanged";
	/// Triggers when the application window enters or exits full-screen mode.
	///
	/// # Callback Arguments
	///
	/// * fullScreen: bool - True if the application is in full-screen mode, false otherwise.
	///
	/// # Callback Example
	///
	/// ```
	/// node.gslot(GSlot::APP_FULL_SCREEN, Box::new(|stack| {
	/// 	let fullScreen = match stack.pop_bool() {
	/// 		Some(fullScreen) => fullScreen,
	/// 		None => return,
	/// 	};
	/// 	if fullScreen {
	/// 		p!("App is in full-screen mode!");
	/// 	} else {
	/// 		p!("App is not in full-screen mode!");
	/// 	}
	/// }));
	/// ```
	pub const APP_FULL_SCREEN: &'static str = "AppFullScreen";
	/// Triggers when the application window position changes.
	pub const APP_MOVED: &'static str = "AppMoved";
	/// Triggers when the application theme color changes.
	///
	/// # Callback Arguments
	///
	/// * themeColor: Color - The new theme color.
	///
	/// # Callback Example
	///
	/// ```
	/// node.gslot(GSlot::APP_THEME, Box::new(|stack| {
	/// 	let themeColor = match stack.pop_cast::<Color>() {
	/// 		Some(themeColor) => themeColor,
	/// 		None => return,
	/// 	};
	/// 	p!("themeColor [{}, {}, {}, {}]", themeColor.r(), themeColor.g(), themeColor.b(), themeColor.a());
	/// }));
	/// ```
	pub const APP_THEME: &'static str = "AppTheme";
	/// Triggers when a websocket connection is open.
	pub const APP_WS_OPEN: &'static str = "AppWSOpen";
	/// Triggers when a websocket connection is closed.
	pub const APP_WS_CLOSE: &'static str = "AppWSClose";
	/// Triggers when received text message from a websocket connection.
	///
	/// # Callback Arguments
	///
	/// * msg: string - The message received.
	///
	/// # Callback Example
	///
	/// ```
	/// node.gslot(GSlot::APP_WS_MESSAGE, Box::new(|stack| {
	/// 	let msg = match stack.pop_str() {
	/// 		Some(msg) => msg,
	/// 		None => return,
	/// 	};
	/// 	p!(msg);
	/// }));
	/// ```
	pub const APP_WS_MESSAGE: &'static str = "AppWSMessage";
	/// A gobal event used for broadcasting massage to all websocket connections.
	///
	/// # Usage
	///
	/// ```
	/// emit(GSlot::APP_WS_SEND, args!("A text message"));
	/// ```
	pub const APP_WS_SEND: &'static str = "AppWSSend";
}

// Content

extern "C" {
	fn content_load(filename: i64) -> i64;
}

impl Content {
	/// Loads the content of the file with the specified filename.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to load.
	///
	/// # Returns
	///
	/// * `String` - The content of the loaded file.
	pub fn load(filename: &str) -> Option<String> {
		let result = unsafe { content_load(from_string(filename)) };
		if result > 0 {
			Some(to_string(result))
		} else {
			None
		}
	}
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
	/// Sets the item at the given index.
	///
	/// # Arguments
	///
	/// * `index` - The index to set, should be 0 based.
	/// * `item` - The new item value.
	pub fn set<'a, T>(&mut self, index: i32, v: T) where T: IntoValue<'a> {
		if unsafe { array_set(self.raw(), index, v.val().raw()) == 0 } {
			panic!("Out of bounds, expecting [0, {}), got {}", self.get_count(), index);
		}
	}
	/// Gets the item at the given index.
	///
	/// # Arguments
	///
	/// * `index` - The index to get, should be 0 based.
	///
	/// # Returns
	///
	/// * `Option<Value>` - The item value.
	pub fn get(&self, index: i32) -> Option<Value> {
		Value::from(unsafe { array_get(self.raw(), index) })
	}
	/// The first item in the array.
	pub fn first(&self) -> Option<Value> {
		Value::from(unsafe { array_first(self.raw()) })
	}
	/// The last item in the array.
	pub fn last(&self) -> Option<Value> {
		Value::from(unsafe { array_last(self.raw()) })
	}
	/// A random item from the array.
	pub fn random_object(&self) -> Option<Value> {
		Value::from(unsafe { array_random_object(self.raw()) })
	}
	/// Adds an item to the end of the array.
	///
	/// # Arguments
	///
	/// * `item` - The item to add.
	pub fn add<'a, T>(&mut self, v: T) -> &mut Self where T: IntoValue<'a> {
		unsafe { array_add(self.raw(), v.val().raw()); }
		self
	}
	/// Inserts an item at the given index, shifting other items to the right.
	///
	/// # Arguments
	///
	/// * `index` - The index to insert at.
	/// * `item` - The item to insert.
	pub fn insert<'a, T>(&mut self, index: i32, v: T) where T: IntoValue<'a> {
		unsafe { array_insert(self.raw(), index, v.val().raw()); }
	}
	/// Checks whether the array contains a given item.
	///
	/// # Arguments
	///
	/// * `item` - The item to check.
	///
	/// # Returns
	///
	/// * `bool` - True if the item is found, false otherwise.
	pub fn contains<'a, T>(&self, v: T) -> bool where T: IntoValue<'a> {
		unsafe { array_contains(self.raw(), v.val().raw()) != 0 }
	}
	/// Gets the index of a given item.
	///
	/// # Arguments
	///
	/// * `item` - The item to search for.
	///
	/// # Returns
	///
	/// * `i32` - The index of the item, or -1 if it is not found.
	pub fn index<'a, T>(&self, v: T) -> i32 where T: IntoValue<'a> {
		unsafe { array_index(self.raw(), v.val().raw()) }
	}
	/// Removes and returns the last item in the array.
	///
	/// # Returns
	///
	/// * `Option<Value>` - The last item removed from the array.
	pub fn remove_last(&mut self) -> Option<Value> {
		Value::from(unsafe { array_remove_last(self.raw()) })
	}
	/// Removes the first occurrence of a given item from the array without preserving order.
	///
	/// # Arguments
	///
	/// * `item` - The item to remove.
	///
	/// # Returns
	///
	/// * `bool` - True if the item was found and removed, false otherwise.
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
	/// A method for setting items in the dictionary.
	///
	/// # Arguments
	///
	/// * `key` - The key of the item to set.
	/// * `item` - The Item to set for the given key, set to None to delete this key-value pair.
	pub fn set<'a, T>(&mut self, key: &str, v: T) where T: IntoValue<'a> {
		unsafe { dictionary_set(self.raw(), from_string(key), v.val().raw()); }
	}
	/// A method for accessing items in the dictionary.
	///
	/// # Arguments
	///
	/// * `key` - The key of the item to retrieve.
	///
	/// # Returns
	///
	/// * `Option<Item>` - The Item with the given key, or None if it does not exist.
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
	/// Sets a property of the entity to a given value.
	/// This function will trigger events for Observer objects.
	///
	/// # Arguments
	///
	/// * `key` - The name of the property to set.
	/// * `item` - The value to set the property to.
	pub fn set<'a, T>(&mut self, key: &str, value: T) where T: IntoValue<'a> {
		unsafe { entity_set(self.raw(), from_string(key), value.val().raw()); }
	}
	/// Retrieves the value of a property of the entity.
	///
	/// # Arguments
	///
	/// * `key` - The name of the property to retrieve the value of.
	///
	/// # Returns
	///
	/// * `Option<Value>` - The value of the specified property.
	pub fn get(&self, key: &str) -> Option<Value> {
		Value::from(unsafe { entity_get(self.raw(), from_string(key)) })
	}
	/// Retrieves the previous value of a property of the entity.
	/// The old values are values before the last change of the component values of the Entity.
	///
	/// # Arguments
	///
	/// * `key` - The name of the property to retrieve the previous value of.
	///
	/// # Returns
	///
	/// * `Option<Value>` - The previous value of the specified property.
	pub fn get_old(&self, key: &str) -> Option<Value> {
		Value::from(unsafe { entity_get_old(self.raw(), from_string(key)) })
	}
}

// EntityGroup

extern "C" {
	fn group_watch(group: i64, func: i32, stack: i64);
}

impl Group {
	/// Watches the group for changes to its entities, calling a function whenever an entity is added or changed.
	///
	/// # Arguments
	///
	/// * `func` - The function to call when an entity is added or changed. Returns true to stop watching.
	///
	/// # Returns
	///
	/// * `Group` - The same group, for method chaining.
	pub fn watch(&mut self, mut func: Box<dyn FnMut(&mut CallStack) -> bool>) -> &mut Group {
		let mut stack = CallStack::new();
		let stack_raw = stack.raw();
		let func_id = push_function(Box::new(move || {
			let result = func(&mut stack);
			stack.push_bool(result);
		}));
		unsafe { group_watch(self.raw(), func_id, stack_raw); }
		self
	}
	/// Calls a function for each entity in the group.
	///
	/// # Arguments
	///
	/// * `func` - The function to call for each entity. Returning true inside the function will stop iteration.
	///
	/// # Returns
	///
	/// * `bool` - Returns false if all entities were processed, true if the iteration was interrupted.
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
	/// Watches the components changes to entities that match the observer's component filter.
	///
	/// # Arguments
	///
	/// * `func` - The function to call when a change occurs. Returns true to stop watching.
	///
	/// # Returns
	///
	/// * `Observer` - The same observer, for method chaining.
	pub fn watch(&mut self, mut func: Box<dyn FnMut(&mut CallStack) -> bool>) -> &mut Observer {
		let mut stack = CallStack::new();
		let stack_raw = stack.raw();
		let func_id = push_function(Box::new(move || {
			let result = func(&mut stack);
			stack.push_bool(result);
		}));
		unsafe { observer_watch(self.raw(), func_id, stack_raw); }
		self
	}
}

// Node

extern "C" {
	fn node_emit(node: i64, name: i64, stack: i64);
}

impl Node {
	/// Emits an event to a node, triggering the event handler associated with the event name.
	///
	/// # Arguments
	///
	/// * `name` - The name of the event.
	/// * `stack` - The argument stack to be passed to the event handler.
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

// BodyDef

pub enum BodyType {
	Dynamic = 0,
	Static = 1,
	Kinematic = 2,
}

impl BodyDef {
	/// Sets the define for the type of the body.
	///
	/// # Arguments
	///
	/// * `body_type` - The type of the body.
	pub fn set_type(&mut self, body_type: BodyType) {
		self._set_type(body_type as i32);
	}
	/// Gets the define for the type of the body.
	///
	/// # Returns
	///
	/// * `BodyType` - The type of the body.
	pub fn get_type(&self) -> BodyType {
		match self._get_type() {
			0 => BodyType::Dynamic,
			1 => BodyType::Static,
			2 => BodyType::Kinematic,
			_ => panic!("Invalid body type.")
		}
	}
}

// Keyboard

pub enum KeyName {
	Return,
	Escape,
	BackSpace,
	Tab,
	Space,
	Exclamation,
	DoubleQuote,
	Hash,
	Percent,
	Dollar,
	Ampersand,
	SingleQuote,
	LeftParen,
	RightParen,
	Asterisk,
	Plus,
	Comma,
	Minus,
	Dot,
	Slash,
	Num1,
	Num2,
	Num3,
	Num4,
	Num5,
	Num6,
	Num7,
	Num8,
	Num9,
	Num0,
	Colon,
	Semicolon,
	LessThan,
	Equal,
	GreaterThan,
	Question,
	At,
	LeftBracket,
	Backslash,
	RightBracket,
	Caret,
	Underscore,
	Backtick,
	A,
	B,
	C,
	D,
	E,
	F,
	G,
	H,
	I,
	J,
	K,
	L,
	M,
	N,
	O,
	P,
	Q,
	R,
	S,
	T,
	U,
	V,
	W,
	X,
	Y,
	Z,
	Delete,
	CapsLock,
	F1,
	F2,
	F3,
	F4,
	F5,
	F6,
	F7,
	F8,
	F9,
	F10,
	F11,
	F12,
	PrintScreen,
	ScrollLock,
	Pause,
	Insert,
	Home,
	PageUp,
	End,
	PageDown,
	Right,
	Left,
	Down,
	Up,
	Application,
	LCtrl,
	LShift,
	LAlt,
	LGui,
	RCtrl,
	RShift,
	RAlt,
	RGui,
}

impl AsRef<str> for KeyName {
	fn as_ref(&self) -> &str {
		match self {
			KeyName::Return => "Return",
			KeyName::Escape => "Escape",
			KeyName::BackSpace => "BackSpace",
			KeyName::Tab => "Tab",
			KeyName::Space => "Space",
			KeyName::Exclamation => "!",
			KeyName::DoubleQuote => "\"",
			KeyName::Hash => "#",
			KeyName::Percent => "%",
			KeyName::Dollar => "$",
			KeyName::Ampersand => "&",
			KeyName::SingleQuote => "'",
			KeyName::LeftParen => "(",
			KeyName::RightParen => ")",
			KeyName::Asterisk => "*",
			KeyName::Plus => "+",
			KeyName::Comma => ",",
			KeyName::Minus => "-",
			KeyName::Dot => ".",
			KeyName::Slash => "/",
			KeyName::Num1 => "1",
			KeyName::Num2 => "2",
			KeyName::Num3 => "3",
			KeyName::Num4 => "4",
			KeyName::Num5 => "5",
			KeyName::Num6 => "6",
			KeyName::Num7 => "7",
			KeyName::Num8 => "8",
			KeyName::Num9 => "9",
			KeyName::Num0 => "0",
			KeyName::Colon => ":",
			KeyName::Semicolon => ";",
			KeyName::LessThan => "<",
			KeyName::Equal => "=",
			KeyName::GreaterThan => ">",
			KeyName::Question => "?",
			KeyName::At => "@",
			KeyName::LeftBracket => "[",
			KeyName::Backslash => "\\",
			KeyName::RightBracket => "]",
			KeyName::Caret => "^",
			KeyName::Underscore => "_",
			KeyName::Backtick => "`",
			KeyName::A => "A",
			KeyName::B => "B",
			KeyName::C => "C",
			KeyName::D => "D",
			KeyName::E => "E",
			KeyName::F => "F",
			KeyName::G => "G",
			KeyName::H => "H",
			KeyName::I => "I",
			KeyName::J => "J",
			KeyName::K => "K",
			KeyName::L => "L",
			KeyName::M => "M",
			KeyName::N => "N",
			KeyName::O => "O",
			KeyName::P => "P",
			KeyName::Q => "Q",
			KeyName::R => "R",
			KeyName::S => "S",
			KeyName::T => "T",
			KeyName::U => "U",
			KeyName::V => "V",
			KeyName::W => "W",
			KeyName::X => "X",
			KeyName::Y => "Y",
			KeyName::Z => "Z",
			KeyName::Delete => "Delete",
			KeyName::CapsLock => "CapsLock",
			KeyName::F1 => "F1",
			KeyName::F2 => "F2",
			KeyName::F3 => "F3",
			KeyName::F4 => "F4",
			KeyName::F5 => "F5",
			KeyName::F6 => "F6",
			KeyName::F7 => "F7",
			KeyName::F8 => "F8",
			KeyName::F9 => "F9",
			KeyName::F10 => "F10",
			KeyName::F11 => "F11",
			KeyName::F12 => "F12",
			KeyName::PrintScreen => "PrintScreen",
			KeyName::ScrollLock => "ScrollLock",
			KeyName::Pause => "Pause",
			KeyName::Insert => "Insert",
			KeyName::Home => "Home",
			KeyName::PageUp => "PageUp",
			KeyName::End => "End",
			KeyName::PageDown => "PageDown",
			KeyName::Right => "Right",
			KeyName::Left => "Left",
			KeyName::Down => "Down",
			KeyName::Up => "Up",
			KeyName::Application => "Application",
			KeyName::LCtrl => "LCtrl",
			KeyName::LShift => "LShift",
			KeyName::LAlt => "LAlt",
			KeyName::LGui => "LGui",
			KeyName::RCtrl => "RCtrl",
			KeyName::RShift => "RShift",
			KeyName::RAlt => "RAlt",
			KeyName::RGui => "RGui",
		 }
	}
}

impl Keyboard {
	/// Checks whether a key is pressed down in the current frame.
	///
	/// # Arguments
	///
	/// * `name` - The name of the key to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the key is pressed down, `false` otherwise.
	pub fn is_key_down(key: KeyName) -> bool {
		Keyboard::_is_key_down(key.as_ref())
	}
	/// Checks whether a key is released in the current frame.
	///
	/// # Arguments
	///
	/// * `name` - The name of the key to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the key is released, `false` otherwise.
	pub fn is_key_up(key: KeyName) -> bool {
		Keyboard::_is_key_up(key.as_ref())
	}
	/// Checks whether a key is in pressed state.
	///
	/// # Arguments
	///
	/// * `name` - The name of the key to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the key is in pressed state, `false` otherwise.
	pub fn is_key_pressed(key: KeyName) -> bool {
		Keyboard::_is_key_pressed(key.as_ref())
	}
}

// Controller

pub enum AxisName {
	LeftX,
	LeftY,
	RightX,
	RightY,
	LeftTrigger,
	RightTrigger,
}

impl AsRef<str> for AxisName {
	fn as_ref(&self) -> &str {
		match self {
			AxisName::LeftX => "leftx",
			AxisName::LeftY => "lefty",
			AxisName::RightX => "rightx",
			AxisName::RightY => "righty",
			AxisName::LeftTrigger => "lefttrigger",
			AxisName::RightTrigger => "righttrigger",
		}
	}
}

pub enum ButtonName {
	A,
	B,
	Back,
	DPDown,
	DPLeft,
	DPRight,
	DPUp,
	LeftShoulder,
	LeftStick,
	RightShoulder,
	RightStick,
	Start,
	X,
	Y,
}

impl AsRef<str> for ButtonName {
	fn as_ref(&self) -> &str {
		match self {
			ButtonName::A => "a",
			ButtonName::B => "b",
			ButtonName::Back => "back",
			ButtonName::DPDown => "dpdown",
			ButtonName::DPLeft => "dpleft",
			ButtonName::DPRight => "dpright",
			ButtonName::DPUp => "dpup",
			ButtonName::LeftShoulder => "leftshoulder",
			ButtonName::LeftStick => "leftstick",
			ButtonName::RightShoulder => "rightshoulder",
			ButtonName::RightStick => "rightstick",
			ButtonName::Start => "start",
			ButtonName::X => "x",
			ButtonName::Y => "y",
		}
	}
}

impl Controller {
	/// Checks whether a button is pressed down in the current frame.
	///
	/// # Arguments
	///
	/// * `controller_id` - The controller id, incrementing from 0 when multiple controllers are connected.
	/// * `name` - The name of the button to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the button is pressed down, `false` otherwise.
	pub fn is_button_down(controller_id: i32, button: ButtonName) -> bool {
		Controller::_is_button_down(controller_id, button.as_ref())
	}
	/// Checks whether a button is released in the current frame.
	///
	/// # Arguments
	///
	/// * `controller_id` - The controller id, incrementing from 0 when multiple controllers are connected.
	/// * `name` - The name of the button to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the button is released, `false` otherwise.
	pub fn is_button_up(controller_id: i32, button: ButtonName) -> bool {
		Controller::_is_button_up(controller_id, button.as_ref())
	}
	/// Checks whether a button is in pressed state.
	///
	/// # Arguments
	///
	/// * `controller_id` - The controller id, incrementing from 0 when multiple controllers are connected.
	/// * `name` - The name of the button to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the button is in pressed state, `false` otherwise.
	pub fn is_button_pressed(controller_id: i32, button: ButtonName) -> bool {
		Controller::_is_button_pressed(controller_id, button.as_ref())
	}
	/// Gets the axis value from a given controller.
	///
	/// # Arguments
	///
	/// * `controller_id` - The controller id, incrementing from 0 when multiple controllers are connected.
	/// * `name` - The name of the controller axis to check.
	///
	/// # Returns
	///
	/// * `f32` - The axis value ranging from -1.0 to 1.0.
	pub fn get_axis(controller_id: i32, axis: AxisName) -> f32 {
		Controller::_get_axis(controller_id, axis.as_ref())
	}
}

// platformer::ActionUpdate

impl platformer::ActionUpdate {
	pub fn from_update(mut update: Box<dyn FnMut(f64) -> bool>) -> platformer::ActionUpdate {
		platformer::ActionUpdate::new(Box::new(move |_, _, dt| {
			update(dt as f64)
		}))
	}
}

// Blackboard

extern "C" {
	fn blackboard_set(b: i64, k: i64, v: i64);
	fn blackboard_get(b: i64, k: i64) -> i64;
}

impl platformer::behavior::Blackboard {
	/// Sets a value in the blackboard.
	///
	/// # Arguments
	/// * `key` - The key associated with the value.
	/// * `value` - The value to be set.
	///
	/// # Example
	///
	/// ```
	/// blackboard.set("score", 100);
	/// ```
	pub fn set<'a, T>(&mut self, key: &str, value: T) where T: IntoValue<'a> {
		unsafe { blackboard_set(self.raw(), from_string(key), value.val().raw()); }
	}
	/// Retrieves a value from the blackboard.
	///
	/// # Arguments
	///
	/// * `key` - The key associated with the value.
	///
	/// # Returns
	///
	/// An `Option` containing the value associated with the key, or `None` if the key does not exist.
	///
	/// # Example
	///
	/// ```
	/// if let Some(score) = blackboard.get("score") {
	///     println!("Score: {}", score.into_i32().unwrap());
	/// } else {
	///     println!("Score not found.");
	/// }
	/// ```
	pub fn get(&self, key: &str) -> Option<Value> {
		Value::from(unsafe { blackboard_get(self.raw(), from_string(key)) })
	}
}

use enumflags2::{bitflags, make_bitflags};
pub use enumflags2::BitFlags;

#[bitflags]
#[repr(u8)]
#[derive(Copy, Clone, Debug, PartialEq)]
pub enum ImGuiSliderFlag {
	AlwaysClamp = 1 << 4,
	Logarithmic = 1 << 5,
	NoRoundToFormat = 1 << 6,
	NoInput = 1 << 7
}

#[bitflags]
#[repr(u32)]
#[derive(Copy, Clone, Debug, PartialEq)]
pub enum ImGuiWindowFlag {
	NoTitleBar = 1 << 0,
	NoResize = 1 << 1,
	NoMove = 1 << 2,
	NoScrollbar = 1 << 3,
	NoScrollWithMouse = 1 << 4,
	NoCollapse = 1 << 5,
	AlwaysAutoResize = 1 << 6,
	NoBackground = 1 << 7,
	NoSavedSettings = 1 << 8,
	NoMouseInputs = 1 << 9,
	MenuBar = 1 << 10,
	HorizontalScrollbar = 1 << 11,
	NoFocusOnAppearing = 1 << 12,
	NoBringToFrontOnFocus = 1 << 13,
	AlwaysVerticalScrollbar= 1 << 14,
	AlwaysHorizontalScrollbar= 1<< 15,
	NoNavInputs = 1 << 16,
	NoNavFocus = 1 << 17,
	UnsavedDocument = 1 << 18
}

impl ImGuiWindowFlag {
	pub const NO_NAV: BitFlags<Self> = make_bitflags!(Self::{NoNavInputs | NoNavFocus});
	pub const NO_DECORATION: BitFlags<Self> = make_bitflags!(Self::{NoTitleBar | NoResize | NoScrollbar | NoCollapse});
	pub const NO_INPUTS: BitFlags<Self> = make_bitflags!(Self::{NoMouseInputs | NoNavInputs | NoNavFocus});
}

#[bitflags]
#[repr(u8)]
#[derive(Copy, Clone, Debug, PartialEq)]
pub enum ImGuiChildFlag {
	Border = 1 << 0,
	AlwaysUseWindowPadding = 1 << 1,
	ResizeX = 1 << 2,
	ResizeY = 1 << 3,
	AutoResizeX = 1 << 4,
	AutoResizeY = 1 << 5,
	AlwaysAutoResize = 1 << 6,
	FrameStyle = 1 << 7
}

#[bitflags]
#[repr(u32)]
#[derive(Copy, Clone, Debug, PartialEq)]
pub enum ImGuiInputTextFlag {
	CharsDecimal = 1 << 0,
	CharsHexadecimal = 1 << 1,
	CharsUppercase = 1 << 2,
	CharsNoBlank = 1 << 3,
	AutoSelectAll = 1 << 4,
	EnterReturnsTrue = 1 << 5,
	CallbackCompletion = 1 << 6,
	CallbackHistory = 1 << 7,
	CallbackAlways = 1 << 8,
	CallbackCharFilter = 1 << 9,
	AllowTabInput = 1 << 10,
	CtrlEnterForNewLine = 1 << 11,
	NoHorizontalScroll = 1 << 12,
	AlwaysOverwrite = 1 << 13,
	ReadOnly = 1 << 14,
	Password = 1 << 15,
	NoUndoRedo = 1 << 16,
	CharsScientific = 1 << 17,
	CallbackResize = 1 << 18,
	CallbackEdit = 1 << 19,
	EscapeClearsAll = 1 << 20
}

#[bitflags]
#[repr(u32)]
#[derive(Copy, Clone, Debug, PartialEq)]
pub enum ImGuiTreeNodeFlag {
	Selected = 1 << 0,
	Framed = 1 << 1,
	AllowOverlap = 1 << 2,
	NoTreePushOnOpen = 1 << 3,
	NoAutoOpenOnLog = 1 << 4,
	DefaultOpen = 1 << 5,
	OpenOnDoubleClick = 1 << 6,
	OpenOnArrow = 1 << 7,
	Leaf = 1 << 8,
	Bullet = 1 << 9,
	FramePadding = 1 << 10,
	SpanAvailWidth = 1 << 11,
	SpanFullWidth = 1 << 12,
	SpanAllColumns = 1 << 13,
	NavLeftJumpsBackHere = 1 << 14
}

impl ImGuiTreeNodeFlag {
	pub const COLLAPSING_HEADER: BitFlags<Self> = make_bitflags!(Self::{Framed | NoTreePushOnOpen | NoAutoOpenOnLog});
}

#[bitflags]
#[repr(u8)]
#[derive(Copy, Clone, Debug, PartialEq)]
pub enum ImGuiSelectableFlag {
	DontClosePopups = 1 << 0,
	SpanAllColumns = 1 << 1,
	AllowDoubleClick = 1 << 2,
	Disabled = 1 << 3,
	AllowOverlap = 1 << 4
}

pub enum ImGuiCol {
	Text,
	TextDisabled,
	WindowBg,
	ChildBg,
	PopupBg,
	Border,
	BorderShadow,
	FrameBg,
	FrameBgHovered,
	FrameBgActive,
	TitleBg,
	TitleBgActive,
	TitleBgCollapsed,
	MenuBarBg,
	ScrollbarBg,
	ScrollbarGrab,
	ScrollbarGrabHovered,
	ScrollbarGrabActive,
	CheckMark,
	SliderGrab,
	SliderGrabActive,
	Button,
	ButtonHovered,
	ButtonActive,
	Header,
	HeaderHovered,
	HeaderActive,
	Separator,
	SeparatorHovered,
	SeparatorActive,
	ResizeGrip,
	ResizeGripHovered,
	ResizeGripActive,
	Tab,
	TabHovered,
	TabActive,
	TabUnfocused,
	TabUnfocusedActive,
	PlotLines,
	PlotLinesHovered,
	PlotHistogram,
	PlotHistogramHovered,
	TableHeaderBg,
	TableBorderStrong,
	TableBorderLight,
	TableRowBg,
	TableRowBgAlt,
	TextSelectedBg,
	DragDropTarget,
	NavHighlight,
	NavWindowingHighlight,
	NavWindowingDimBg,
	ModalWindowDimBg
}

#[bitflags]
#[repr(u32)]
#[derive(Copy, Clone, Debug, PartialEq)]
pub enum ImGuiColorEditFlag {
	NoAlpha = 1 << 1,
	NoPicker = 1 << 2,
	NoOptions = 1 << 3,
	NoSmallPreview = 1 << 4,
	NoInputs = 1 << 5,
	NoTooltip = 1 << 6,
	NoLabel = 1 << 7,
	NoSidePreview = 1 << 8,
	NoDragDrop = 1 << 9,
	NoBorder = 1 << 10,
	AlphaBar = 1 << 16,
	AlphaPreview = 1 << 17,
	AlphaPreviewHalf = 1 << 18,
	HDR = 1 << 19,
	DisplayRGB = 1 << 20,
	DisplayHSV = 1 << 21,
	DisplayHex = 1 << 22,
	Uint8 = 1 << 23,
	Float = 1 << 24,
	PickerHueBar = 1 << 25,
	PickerHueWheel = 1 << 26,
	InputRGB = 1 << 27,
	InputHSV = 1 << 28
}

impl ImGuiColorEditFlag {
	pub const DEFAULT_OPTIONS: BitFlags<Self> = make_bitflags!(Self::{Uint8 | DisplayRGB | InputRGB | PickerHueBar});
}

pub enum ImGuiCond {
	Always = 1 << 0,
	Once = 1 << 1,
	FirstUseEver = 1 << 2,
	Appearing = 1 << 3,
}

#[bitflags]
#[repr(u32)]
#[derive(Copy, Clone, Debug, PartialEq)]
pub enum ImGuiTableFlag {
	Resizable = 1 << 0,
	Reorderable = 1 << 1,
	Hideable = 1 << 2,
	Sortable = 1 << 3,
	NoSavedSettings = 1 << 4,
	ContextMenuInBody = 1 << 5,
	RowBg = 1 << 6,
	BordersInnerH = 1 << 7,
	BordersOuterH = 1 << 8,
	BordersInnerV = 1 << 9,
	BordersOuterV = 1 << 10,
	NoBordersInBody = 1 << 11,
	NoBordersInBodyUntilResize = 1 << 12,
	SizingFixedFit = 1 << 13,
	SizingFixedSame = 1 << 14,
	SizingStretchSame = 1 << 15,
	NoHostExtendX = 1 << 16,
	NoHostExtendY = 1 << 17,
	NoKeepColumnsVisible = 1 << 18,
	PreciseWidths = 1 << 19,
	NoClip = 1 << 20,
	PadOuterX = 1 << 21,
	NoPadOuterX = 1 << 22,
	NoPadInnerX = 1 << 23,
	ScrollX = 1 << 24,
	ScrollY = 1 << 25,
	SortMulti = 1 << 26,
	SortTristate = 1 << 27,
	HighlightHoveredColumn = 1 << 28
}

impl ImGuiTableFlag {
	pub const BORDERS_H: BitFlags<Self> = make_bitflags!(Self::{BordersInnerH | BordersOuterH});
	pub const BORDERS_V: BitFlags<Self> = make_bitflags!(Self::{BordersInnerV | BordersOuterV});
	pub const BORDERS_INNER: BitFlags<Self> = make_bitflags!(Self::{BordersInnerV | BordersInnerH});
	pub const BORDERS_OUTER: BitFlags<Self> = make_bitflags!(Self::{BordersOuterV | BordersOuterH});
	pub const BORDERS: BitFlags<Self> = make_bitflags!(Self::{BordersInnerV | BordersInnerH | BordersOuterV | BordersOuterH});
	pub const SIZING_STRETCH_PROP: BitFlags<Self> = make_bitflags!(Self::{SizingFixedFit | SizingFixedSame});
}

#[bitflags]
#[repr(u32)]
#[derive(Copy, Clone, Debug, PartialEq)]
pub enum ImGuiTableColumnFlag {
	Disabled = 1 << 0,
	DefaultHide = 1 << 1,
	DefaultSort = 1 << 2,
	WidthStretch = 1 << 3,
	WidthFixed = 1 << 4,
	NoResize = 1 << 5,
	NoReorder = 1 << 6,
	NoHide = 1 << 7,
	NoClip = 1 << 8,
	NoSort = 1 << 9,
	NoSortAscending = 1 << 10,
	NoSortDescending = 1 << 11,
	NoHeaderLabel = 1 << 12,
	NoHeaderWidth = 1 << 13,
	PreferSortAscending = 1 << 14,
	PreferSortDescending = 1 << 15,
	IndentEnable = 1 << 16,
	IndentDisable = 1 << 17,
	AngledHeader = 1 << 18,
	IsEnabled = 1 << 24,
	IsVisible = 1 << 25,
	IsSorted = 1 << 26,
	IsHovered = 1 << 27
}

pub enum ImGuiPopupButton {
	MouseButtonLeft = 0,
	MouseButtonRight = 1,
	MouseButtonMiddle = 2
}

#[bitflags]
#[repr(u32)]
#[derive(Copy, Clone, Debug, PartialEq)]
pub enum ImGuiPopupFlag {
	NoReopen = 1 << 5,
	NoOpenOverExistingPopup = 1 << 7,
	NoOpenOverItems = 1 << 8,
	AnyPopupId = 1 << 10,
	AnyPopupLevel = 1 << 11
}

impl ImGuiPopupFlag {
	pub const ANY_POPUP: BitFlags<Self> = make_bitflags!(Self::{AnyPopupId | AnyPopupLevel});
}

pub enum ImGuiStyleVar {
	Alpha = 0,
	DisabledAlpha = 1,
	WindowRounding = 3,
	WindowBorderSize = 4,
	ChildRounding = 7,
	ChildBorderSize = 8,
	PopupRounding = 9,
	PopupBorderSize = 10,
	FrameRounding = 12,
	FrameBorderSize = 13,
	IndentSpacing = 16,
	ScrollbarSize = 18,
	ScrollbarRounding = 19,
	GrabMinSize = 20,
	GrabRounding = 21,
	TabRounding = 22,
	TabBarBorderSize = 23,
	SeparatorTextBorderSize = 26,
}

pub enum ImGuiStyleVec2 {
	WindowPadding = 2,
	WindowMinSize = 5,
	WindowTitleAlign = 6,
	FramePadding = 11,
	ItemSpacing = 14,
	ItemInnerSpacing = 15,
	CellPadding = 17,
	ButtonTextAlign = 24,
	SelectableTextAlign = 25,
	SeparatorTextAlign = 27,
	SeparatorTextPadding = 28
}

#[bitflags]
#[repr(u8)]
#[derive(Copy, Clone, Debug, PartialEq)]
pub enum ImGuiTableRowFlag {
	Headers = 1 << 0
}

static mut IMGUI_STACK: Lazy<CallStack> = Lazy::new(|| { CallStack::new() });

impl ImGui {
	fn push_bool(v: bool) -> &'static mut CallStack {
		let stack = unsafe { addr_of_mut!(IMGUI_STACK).as_mut().unwrap() };
		stack.push_bool(v);
		stack
	}
	fn push_i32(v: i32) -> &'static mut CallStack {
		let stack = unsafe { addr_of_mut!(IMGUI_STACK).as_mut().unwrap() };
		stack.push_i32(v);
		stack
	}
	fn push_i32x2(v1: i32, v2: i32) -> &'static mut CallStack {
		let stack = unsafe { addr_of_mut!(IMGUI_STACK).as_mut().unwrap() };
		stack.push_i32(v1);
		stack.push_i32(v2);
		stack
	}
	fn push_f32(v: f32) -> &'static mut CallStack {
		let stack = unsafe { addr_of_mut!(IMGUI_STACK).as_mut().unwrap() };
		stack.push_f32(v);
		stack
	}
	fn push_f32x2(v1: f32, v2: f32) -> &'static mut CallStack {
		let stack = unsafe { addr_of_mut!(IMGUI_STACK).as_mut().unwrap() };
		stack.push_f32(v1);
		stack.push_f32(v2);
		stack
	}
	pub fn begin<C>(name: &str, inside: C) where C: FnOnce() {
		ImGui::begin_opts(name, BitFlags::default(), inside);
	}
	pub fn begin_opts<C>(name: &str, windows_flags: BitFlags<ImGuiWindowFlag>, inside: C) where C: FnOnce() {
		if ImGui::_begin_opts(name, windows_flags.bits() as i32) {
			inside();
		}
		ImGui::_end();
	}
	pub fn begin_ret<C>(name: &str, opened: bool, inside: C) -> (bool, bool) where C: FnOnce() {
		ImGui::begin_ret_opts(name, opened, BitFlags::default(), inside)
	}
	pub fn begin_ret_opts<C>(name: &str, opened: bool, windows_flags: BitFlags<ImGuiWindowFlag>, inside: C) -> (bool, bool) where C: FnOnce() {
		let stack = ImGui::push_bool(opened);
		let changed = ImGui::_begin_ret_opts(name, stack, windows_flags.bits() as i32);
		let opened = stack.pop_bool().unwrap();
		if opened {
			inside();
		}
		ImGui::_end();
		(changed, stack.pop_bool().unwrap())
	}
	pub fn begin_child<C>(str_id: &str, inside: C) where C: FnOnce() {
		ImGui::begin_child_opts(str_id, &Vec2::zero(), BitFlags::default(), BitFlags::default(), inside);
	}
	pub fn begin_child_opts<C>(str_id: &str, size: &crate::dora::Vec2, child_flags: BitFlags<ImGuiChildFlag>, window_flags: BitFlags<ImGuiWindowFlag>, inside: C) where C: FnOnce() {
		if ImGui::_begin_child_opts(str_id, size, child_flags.bits() as i32, window_flags.bits() as i32) {
			inside();
		}
		ImGui::_end_child();
	}
	pub fn begin_child_with_id<C>(id: i32, inside: C) where C: FnOnce() {
		ImGui::begin_child_with_id_opts(id, &Vec2::zero(), BitFlags::default(), BitFlags::default(), inside);
	}
	pub fn begin_child_with_id_opts<C>(id: i32, size: &crate::dora::Vec2, child_flags: BitFlags<ImGuiChildFlag>, window_flags: BitFlags<ImGuiWindowFlag>, inside: C) where C: FnOnce() {
		if ImGui::_begin_child_with_id_opts(id, size, child_flags.bits() as i32, window_flags.bits() as i32) {
			inside();
		}
		ImGui::_end_child();
	}
	pub fn collapsing_header_ret(label: &str, opened: bool) -> (bool, bool) {
		ImGui::collapsing_header_ret_opts(label, opened, BitFlags::default())
	}
	pub fn collapsing_header_ret_opts(label: &str, opened: bool, tree_node_flags: BitFlags<ImGuiTreeNodeFlag>) -> (bool, bool) {
		let stack = ImGui::push_bool(opened);
		let changed = ImGui::_collapsing_header_ret_opts(label, stack, tree_node_flags.bits() as i32);
		(changed, stack.pop_bool().unwrap())
	}
	pub fn selectable_ret(label: &str, selected: bool) -> (bool, bool) {
		ImGui::selectable_ret_opts(label, selected, &Vec2::zero(), BitFlags::default())
	}
	pub fn selectable_ret_opts(label: &str, selected: bool, size: &crate::dora::Vec2, selectable_flags: BitFlags<ImGuiSelectableFlag>) -> (bool, bool) {
		let stack = ImGui::push_bool(selected);
		let changed = ImGui::_selectable_ret_opts(label, stack, size, selectable_flags.bits() as i32);
		(changed, stack.pop_bool().unwrap())
	}
	pub fn combo_ret(label: &str, current_item: i32, items: &Vec<&str>) -> (bool, i32) {
		ImGui::combo_ret_opts(label, current_item, items, -1)
	}
	pub fn combo_ret_opts(label: &str, current_item: i32, items: &Vec<&str>, height_in_items: i32) -> (bool, i32) {
		let stack = ImGui::push_i32(current_item);
		let changed = ImGui::_combo_ret_opts(label, stack, items, height_in_items);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn drag_float_ret(label: &str, v: f32, v_speed: f32, v_min: f32, v_max: f32) -> (bool, f32) {
		ImGui::drag_float_ret_opts(label, v, v_speed, v_min, v_max, "%.3f", BitFlags::default())
	}
	pub fn drag_float_ret_opts(label: &str, v: f32, v_speed: f32, v_min: f32, v_max: f32, display_format: &str, slider_flags: BitFlags<ImGuiSliderFlag>) -> (bool, f32) {
		let stack = ImGui::push_f32(v);
		let changed = ImGui::_drag_float_ret_opts(label, stack, v_speed, v_min, v_max, display_format, slider_flags.bits() as i32);
		(changed, stack.pop_f32().unwrap())
	}
	pub fn drag_float2_ret(label: &str, v1: f32, v2: f32, v_speed: f32, v_min: f32, v_max: f32) -> (bool, f32, f32) {
		ImGui::drag_float2_ret_opts(label, v1, v2, v_speed, v_min, v_max, "%.3f", BitFlags::default())
	}
	pub fn drag_float2_ret_opts(label: &str, v1: f32, v2: f32, v_speed: f32, v_min: f32, v_max: f32, display_format: &str, slider_flags: BitFlags<ImGuiSliderFlag>) -> (bool, f32, f32) {
		let stack = ImGui::push_f32x2(v1, v2);
		let changed = ImGui::_drag_float2_ret_opts(label, stack, v_speed, v_min, v_max, display_format, slider_flags.bits() as i32);
		(changed, stack.pop_f32().unwrap(), stack.pop_f32().unwrap())
	}
	pub fn drag_int2_ret(label: &str, v1: i32, v2: i32, v_speed: f32, v_min: i32, v_max: i32) -> (bool, i32, i32) {
		ImGui::drag_int2_ret_opts(label, v1, v2, v_speed, v_min, v_max, "%d", BitFlags::default())
	}
	pub fn drag_int2_ret_opts(label: &str, v1: i32, v2: i32, v_speed: f32, v_min: i32, v_max: i32, display_format: &str, slider_flags: BitFlags<ImGuiSliderFlag>) -> (bool, i32, i32) {
		let stack = ImGui::push_i32x2(v1, v2);
		let changed = ImGui::_drag_int2_ret_opts(label, stack, v_speed, v_min, v_max, display_format, slider_flags.bits() as i32);
		(changed, stack.pop_i32().unwrap(), stack.pop_i32().unwrap())
	}
	pub fn input_float_ret(label: &str, v: f32) -> (bool, f32) {
		ImGui::input_float_ret_opts(label, v, 0.0, 0.0, "%.3f", BitFlags::default())
	}
	pub fn input_float_ret_opts(label: &str, v: f32, step: f32, step_fast: f32, display_format: &str, input_text_flags: BitFlags<ImGuiInputTextFlag>) -> (bool, f32) {
		let stack = ImGui::push_f32(v);
		let changed = ImGui::_input_float_ret_opts(label, stack, step, step_fast, display_format, input_text_flags.bits() as i32);
		(changed, stack.pop_f32().unwrap())
	}
	pub fn input_float2_ret(label: &str, v1: f32, v2: f32) -> (bool, f32, f32) {
		ImGui::input_float2_ret_opts(label, v1, v2, "%.3f", BitFlags::default())
	}
	pub fn input_float2_ret_opts(label: &str, v1: f32, v2: f32, display_format: &str, input_text_flags: BitFlags<ImGuiInputTextFlag>) -> (bool, f32, f32) {
		let stack = ImGui::push_f32x2(v1, v2);
		let changed = ImGui::_input_float2_ret_opts(label, stack, display_format, input_text_flags.bits() as i32);
		(changed, stack.pop_f32().unwrap(), stack.pop_f32().unwrap())
	}
	pub fn input_int_ret(label: &str, v: i32) -> (bool, i32) {
		ImGui::input_int_ret_opts(label, v, 1, 100, BitFlags::default())
	}
	pub fn input_int_ret_opts(label: &str, v: i32, step: i32, step_fast: i32, input_text_flags: BitFlags<ImGuiInputTextFlag>) -> (bool, i32) {
		let stack = ImGui::push_i32(v);
		let changed = ImGui::_input_int_ret_opts(label, stack, step, step_fast, input_text_flags.bits() as i32);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn input_int2_ret(label: &str, v1: i32, v2: i32) -> (bool, i32, i32) {
		ImGui::input_int2_ret_opts(label, v1, v2, BitFlags::default())
	}
	pub fn input_int2_ret_opts(label: &str, v1: i32, v2: i32, input_text_flags: BitFlags<ImGuiInputTextFlag>) -> (bool, i32, i32) {
		let stack = ImGui::push_i32x2(v1, v2);
		let changed = ImGui::_input_int2_ret_opts(label, stack, input_text_flags.bits() as i32);
		(changed, stack.pop_i32().unwrap(), stack.pop_i32().unwrap())
	}
	pub fn slider_float_ret(label: &str, v: f32, v_min: f32, v_max: f32) -> (bool, f32) {
		ImGui::slider_float_ret_opts(label, v, v_min, v_max, "%.3f", BitFlags::default())
	}
	pub fn slider_float_ret_opts(label: &str, v: f32, v_min: f32, v_max: f32, display_format: &str, slider_flags: BitFlags<ImGuiSliderFlag>) -> (bool, f32) {
		let stack = ImGui::push_f32(v);
		let changed = ImGui::_slider_float_ret_opts(label, stack, v_min, v_max, display_format, slider_flags.bits() as i32);
		(changed, stack.pop_f32().unwrap())
	}
	pub fn slider_float2_ret(label: &str, v1: f32, v2: f32, v_min: f32, v_max: f32) -> (bool, f32, f32) {
		ImGui::slider_float2_ret_opts(label, v1, v2, v_min, v_max, "%.3f", BitFlags::default())
	}
	pub fn slider_float2_ret_opts(label: &str, v1: f32, v2: f32, v_min: f32, v_max: f32, display_format: &str, slider_flags: BitFlags<ImGuiSliderFlag>) -> (bool, f32, f32) {
		let stack = ImGui::push_f32x2(v1, v2);
		let changed = ImGui::_slider_float2_ret_opts(label, stack, v_min, v_max, display_format, slider_flags.bits() as i32);
		(changed, stack.pop_f32().unwrap(), stack.pop_f32().unwrap())
	}
	pub fn drag_float_range2_ret(label: &str, v_current_min: f32, v_current_max: f32, v_speed: f32, v_min: f32, v_max: f32) -> (bool, f32, f32) {
		ImGui::drag_float_range2_ret_opts(label, v_current_min, v_current_max, v_speed, v_min, v_max, "%.3f", "%.3f", BitFlags::default())
	}
	pub fn drag_float_range2_ret_opts(label: &str, v_current_min: f32, v_current_max: f32, v_speed: f32, v_min: f32, v_max: f32, format: &str, format_max: &str, slider_flags: BitFlags<ImGuiSliderFlag>) -> (bool, f32, f32) {
		let stack = ImGui::push_f32x2(v_current_min, v_current_max);
		let changed = ImGui::_drag_float_range2_ret_opts(label, stack, v_speed, v_min, v_max, format, format_max, slider_flags.bits() as i32);
		(changed, stack.pop_f32().unwrap(), stack.pop_f32().unwrap())
	}
	pub fn drag_int_ret(label: &str, value: i32, v_speed: f32, v_min: i32, v_max: i32) -> (bool, i32) {
		ImGui::drag_int_ret_opts(label, value, v_speed, v_min, v_max, "%d", BitFlags::default())
	}
	pub fn drag_int_ret_opts(label: &str, value: i32, v_speed: f32, v_min: i32, v_max: i32, display_format: &str, slider_flags: BitFlags<ImGuiSliderFlag>) -> (bool, i32) {
		let stack = ImGui::push_i32(value);
		let changed = ImGui::_drag_int_ret_opts(label, stack, v_speed, v_min, v_max, display_format, slider_flags.bits() as i32);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn drag_int_range2_ret(label: &str, v_current_min: i32, v_current_max: i32, v_speed: f32, v_min: i32, v_max: i32) -> (bool, i32, i32) {
		ImGui::drag_int_range2_ret_opts(label, v_current_min, v_current_max, v_speed, v_min, v_max, "%d", "%d", BitFlags::default())
	}
	pub fn drag_int_range2_ret_opts(label: &str, v_current_min: i32, v_current_max: i32, v_speed: f32, v_min: i32, v_max: i32, format: &str, format_max: &str, slider_flags: BitFlags<ImGuiSliderFlag>) -> (bool, i32, i32) {
		let stack = ImGui::push_i32x2(v_current_min, v_current_max);
		let changed = ImGui::_drag_int_range2_ret_opts(label, stack, v_speed, v_min, v_max, format, format_max, slider_flags.bits() as i32);
		(changed, stack.pop_i32().unwrap(), stack.pop_i32().unwrap())
	}
	pub fn slider_int_ret(label: &str, value: i32, v_min: i32, v_max: i32) -> (bool, i32) {
		ImGui::slider_int_ret_opts(label, value, v_min, v_max, "%d", BitFlags::default())
	}
	pub fn slider_int_ret_opts(label: &str, value: i32, v_min: i32, v_max: i32, format: &str, slider_flags: BitFlags<ImGuiSliderFlag>) -> (bool, i32) {
		let stack = ImGui::push_i32(value);
		let changed = ImGui::_slider_int_ret_opts(label, stack, v_min, v_max, format, slider_flags.bits() as i32);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn slider_int2_ret(label: &str, v1: i32, v2: i32, v_min: i32, v_max: i32) -> (bool, i32, i32) {
		ImGui::slider_int2_ret_opts(label, v1, v2, v_min, v_max, "%d", BitFlags::default())
	}
	pub fn slider_int2_ret_opts(label: &str, v1: i32, v2: i32, v_min: i32, v_max: i32, display_format: &str, slider_flags: BitFlags<ImGuiSliderFlag>) -> (bool, i32, i32) {
		let stack = ImGui::push_i32x2(v1, v2);
		let changed = ImGui::_slider_int2_ret_opts(label, stack, v_min, v_max, display_format, slider_flags.bits() as i32);
		(changed, stack.pop_i32().unwrap(), stack.pop_i32().unwrap())
	}
	pub fn v_slider_float_ret(label: &str, size: &crate::dora::Vec2, v: f32, v_min: f32, v_max: f32) -> (bool, f32) {
		ImGui::v_slider_float_ret_opts(label, size, v, v_min, v_max, "%.3f", BitFlags::default())
	}
	pub fn v_slider_float_ret_opts(label: &str, size: &crate::dora::Vec2, v: f32, v_min: f32, v_max: f32, format: &str, slider_flags: BitFlags<ImGuiSliderFlag>) -> (bool, f32) {
		let stack = ImGui::push_f32(v);
		let changed = ImGui::_v_slider_float_ret_opts(label, size, stack, v_min, v_max, format, slider_flags.bits() as i32);
		(changed, stack.pop_f32().unwrap())
	}
	pub fn v_slider_int_ret(label: &str, size: &crate::dora::Vec2, v: i32, v_min: i32, v_max: i32) -> (bool, i32) {
		ImGui::v_slider_int_ret_opts(label, size, v, v_min, v_max, "%d", BitFlags::default())
	}
	pub fn v_slider_int_ret_opts(label: &str, size: &crate::dora::Vec2, v: i32, v_min: i32, v_max: i32, format: &str, slider_flags: BitFlags<ImGuiSliderFlag>) -> (bool, i32) {
		let stack = ImGui::push_i32(v);
		let changed = ImGui::_v_slider_int_ret_opts(label, size, stack, v_min, v_max, format, slider_flags.bits() as i32);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn color_edit3_ret(label: &str, color3: &Color3) -> (bool, Color3) {
		ImGui::color_edit3_ret_opts(label, color3, BitFlags::default())
	}
	pub fn color_edit3_ret_opts(label: &str, color3: &Color3, color_edit_flags: BitFlags<ImGuiColorEditFlag>) -> (bool, Color3) {
		let stack = ImGui::push_i32(color3.to_rgb() as i32);
		let changed = ImGui::_color_edit3_ret_opts(label, stack, color_edit_flags.bits() as i32);
		(changed, Color3::new(stack.pop_i32().unwrap() as u32))
	}
	pub fn color_edit4_ret(label: &str, color: &Color) -> (bool, Color) {
		ImGui::color_edit4_ret_opts(label, color, BitFlags::default())
	}
	pub fn color_edit4_ret_opts(label: &str, color: &Color, color_edit_flags: BitFlags<ImGuiColorEditFlag>) -> (bool, Color) {
		let stack = ImGui::push_i32(color.to_argb() as i32);
		let changed = ImGui::_color_edit4_ret_opts(label, stack, color_edit_flags.bits() as i32);
		(changed, Color::new(stack.pop_i32().unwrap() as u32))
	}
	pub fn checkbox_ret(label: &str, checked: bool) -> (bool, bool) {
		let stack = ImGui::push_bool(checked);
		let changed = ImGui::_checkbox_ret(label, stack);
		(changed, stack.pop_bool().unwrap())
	}
	pub fn radio_button_ret(label: &str, value: i32, v_button: i32) -> (bool, i32) {
		let stack = ImGui::push_i32(value);
		let changed = ImGui::_radio_button_ret(label, stack, v_button);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn list_box_ret(label: &str, current_item: i32, items: &Vec<&str>) -> (bool, i32) {
		ImGui::list_box_ret_opts(label, current_item, items, -1)
	}
	pub fn list_box_ret_opts(label: &str, current_item: i32, items: &Vec<&str>, height_in_items: i32) -> (bool, i32) {
		let stack = ImGui::push_i32(current_item);
		let changed = ImGui::_list_box_ret_opts(label, stack, items, height_in_items);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn set_next_window_pos_center() {
		ImGui::set_next_window_pos_center_opts(ImGuiCond::Always);
	}
	pub fn set_next_window_pos_center_opts(set_cond: ImGuiCond) {
		ImGui::_set_next_window_pos_center_opts(set_cond as i32);
	}
	pub fn set_next_window_size(size: &crate::dora::Vec2) {
		ImGui::set_next_window_size_opts(size, ImGuiCond::Always);
	}
	pub fn set_next_window_size_opts(size: &crate::dora::Vec2, set_cond: ImGuiCond) {
		ImGui::_set_next_window_size_opts(size, set_cond as i32);
	}
	pub fn set_next_window_collapsed(collapsed: bool) {
		ImGui::set_next_window_collapsed_opts(collapsed, ImGuiCond::Always);
	}
	pub fn set_next_window_collapsed_opts(collapsed: bool, set_cond: ImGuiCond) {
		ImGui::_set_next_window_collapsed_opts(collapsed, set_cond as i32);
	}
	pub fn set_window_pos(name: &str, pos: &crate::dora::Vec2) {
		ImGui::set_window_pos_opts(name, pos, ImGuiCond::Always);
	}
	pub fn set_window_pos_opts(name: &str, pos: &crate::dora::Vec2, set_cond: ImGuiCond) {
		ImGui::_set_window_pos_opts(name, pos, set_cond as i32);
	}
	pub fn set_window_size(name: &str, size: &crate::dora::Vec2) {
		ImGui::set_window_size_opts(name, size, ImGuiCond::Always);
	}
	pub fn set_window_size_opts(name: &str, size: &crate::dora::Vec2, set_cond: ImGuiCond) {
		ImGui::_set_window_size_opts(name, size, set_cond as i32);
	}
	pub fn set_window_collapsed(name: &str, collapsed: bool) {
		ImGui::set_window_collapsed_opts(name, collapsed, ImGuiCond::Always);
	}
	pub fn set_window_collapsed_opts(name: &str, collapsed: bool, set_cond: ImGuiCond) {
		ImGui::_set_window_collapsed_opts(name, collapsed, set_cond as i32);
	}
	pub fn set_color_edit_options(color_edit_flags: BitFlags<ImGuiColorEditFlag>) {
		ImGui::_set_color_edit_options(color_edit_flags.bits() as i32);
	}
	pub fn input_text(label: &str, buffer: &crate::dora::Buffer) -> bool {
		ImGui::input_text_opts(label, buffer, BitFlags::default())
	}
	pub fn input_text_opts(label: &str, buffer: &crate::dora::Buffer, input_text_flags: BitFlags<ImGuiInputTextFlag>) -> bool {
		ImGui::_input_text_opts(label, buffer, input_text_flags.bits() as i32)
	}
	pub fn input_text_multiline(label: &str, buffer: &crate::dora::Buffer, size: &crate::dora::Vec2) -> bool {
		ImGui::input_text_multiline_opts(label, buffer, size, BitFlags::default())
	}
	pub fn input_text_multiline_opts(label: &str, buffer: &crate::dora::Buffer, size: &crate::dora::Vec2, input_text_flags: BitFlags<ImGuiInputTextFlag>) -> bool {
		ImGui::_input_text_multiline_opts(label, buffer, size, input_text_flags.bits() as i32)
	}
	pub fn tree_push<C>(str_id: &str, inside: C) where C: FnOnce() {
		ImGui::_tree_push(str_id);
		inside();
		ImGui::_tree_pop();
	}
	pub fn tree_node<C>(str_id: &str, text: &str, inside: C) where C: FnOnce() {
		if ImGui::_tree_node(str_id, text) {
			inside();
			ImGui::_tree_pop();
		}
	}
	pub fn tree_node_ex<C>(label: &str, inside: C) where C: FnOnce() {
		ImGui::tree_node_ex_opts(label, BitFlags::default(), inside)
	}
	pub fn tree_node_ex_opts<C>(label: &str, tree_node_flags: BitFlags<ImGuiTreeNodeFlag>, inside: C) where C: FnOnce() {
		if ImGui::_tree_node_ex_opts(label, tree_node_flags.bits() as i32) {
			inside();
			ImGui::_tree_pop();
		}
	}
	pub fn tree_node_ex_with_id<C>(str_id: &str, text: &str, inside: C) where C: FnOnce() {
		ImGui::tree_node_ex_with_id_opts(str_id, text, BitFlags::default(), inside);
	}
	pub fn tree_node_ex_with_id_opts<C>(str_id: &str, text: &str, tree_node_flags: BitFlags<ImGuiTreeNodeFlag>, inside: C) where C: FnOnce() {
		if ImGui::_tree_node_ex_with_id_opts(str_id, text, tree_node_flags.bits() as i32) {
			inside();
			ImGui::_tree_pop();
		}
	}
	pub fn set_next_item_open(is_open: bool) {
		ImGui::set_next_item_open_opts(is_open, ImGuiCond::Always);
	}
	pub fn set_next_item_open_opts(is_open: bool, set_cond: ImGuiCond) {
		ImGui::_set_next_item_open_opts(is_open, set_cond as i32);
	}
	pub fn collapsing_header(label: &str) -> bool {
		ImGui::collapsing_header_opts(label, BitFlags::default())
	}
	pub fn collapsing_header_opts(label: &str, tree_node_flags: BitFlags<ImGuiTreeNodeFlag>) -> bool {
		ImGui::_collapsing_header_opts(label, tree_node_flags.bits() as i32)
	}
	pub fn selectable(label: &str) -> bool {
		ImGui::selectable_opts(label, BitFlags::default())
	}
	pub fn selectable_opts(label: &str, selectable_flags: BitFlags<ImGuiSelectableFlag>) -> bool {
		ImGui::_selectable_opts(label, selectable_flags.bits() as i32)
	}
	pub fn begin_popup<C>(str_id: &str, inside: C) where C: FnOnce() {
		if ImGui::_begin_popup(str_id) {
			inside();
			ImGui::_end_popup();
		}
	}
	pub fn begin_popup_modal<C>(name: &str, inside: C) where C: FnOnce() {
		ImGui::begin_popup_modal_opts(name, BitFlags::default(), inside);
	}
	pub fn begin_popup_modal_opts<C>(name: &str, windows_flags: BitFlags<ImGuiWindowFlag>, inside: C) where C: FnOnce() {
		if ImGui::_begin_popup_modal_opts(name, windows_flags.bits() as i32) {
			inside();
			ImGui::_end_popup();
		}
	}
	pub fn begin_popup_modal_ret(name: &str, opened: bool) -> (bool, bool) {
		ImGui::begin_popup_modal_ret_opts(name, opened, BitFlags::default())
	}
	pub fn begin_popup_modal_ret_opts(name: &str, opened: bool, windows_flags: BitFlags<ImGuiWindowFlag>) -> (bool, bool) {
		let stack = ImGui::push_bool(opened);
		let changed = ImGui::_begin_popup_modal_ret_opts(name, stack, windows_flags.bits() as i32);
		(changed, stack.pop_bool().unwrap())
	}
	pub fn begin_popup_context_item<C>(name: &str, inside: C) where C: FnOnce() {
		ImGui::begin_popup_context_item_opts(name, ImGuiPopupButton::MouseButtonRight, BitFlags::default(), inside);
	}
	pub fn begin_popup_context_item_opts<C>(name: &str, button: ImGuiPopupButton, popup_flags: BitFlags<ImGuiPopupFlag>, inside: C) where C: FnOnce() {
		if ImGui::_begin_popup_context_item_opts(name, (button as u32 | popup_flags.bits()) as i32) {
			inside();
			ImGui::_end_popup();
		}
	}
	pub fn begin_popup_context_window<C>(name: &str, inside: C) where C: FnOnce() {
		ImGui::begin_popup_context_window_opts(name, ImGuiPopupButton::MouseButtonRight, BitFlags::default(), inside);
	}
	pub fn begin_popup_context_window_opts<C>(name: &str, button: ImGuiPopupButton, popup_flags: BitFlags<ImGuiPopupFlag>, inside: C) where C: FnOnce() {
		if ImGui::_begin_popup_context_window_opts(name, (button as u32 | popup_flags.bits()) as i32) {
			inside();
			ImGui::_end_popup();
		}
	}
	pub fn begin_popup_context_void<C>(name: &str, inside: C) where C: FnOnce() {
		ImGui::begin_popup_context_void_opts(name, ImGuiPopupButton::MouseButtonRight, BitFlags::default(), inside);
	}
	pub fn begin_popup_context_void_opts<C>(name: &str, button: ImGuiPopupButton, popup_flags: BitFlags<ImGuiPopupFlag>, inside: C) where C: FnOnce() {
		if ImGui::_begin_popup_context_void_opts(name, (button as u32 | popup_flags.bits()) as i32) {
			inside();
			ImGui::_end_popup();
		}
	}
	pub fn begin_table<C>(str_id: &str, column: i32, inside: C) where C: FnOnce() {
		ImGui::begin_table_opts(str_id, column, &Vec2::zero(), -1.0, BitFlags::default(), inside);
	}
	pub fn begin_table_opts<C>(str_id: &str, column: i32, outer_size: &crate::dora::Vec2, inner_width: f32, table_flags: BitFlags<ImGuiTableFlag>, inside: C) where C: FnOnce() {
		if ImGui::_begin_table_opts(str_id, column, outer_size, inner_width, table_flags.bits() as i32) {
			inside();
			ImGui::_end_table();
		}
	}
	pub fn table_setup_column(label: &str, init_width_or_weight: f32) {
		ImGui::table_setup_column_opts(label, init_width_or_weight, 0, BitFlags::default())
	}
	pub fn table_setup_column_opts(label: &str, init_width_or_weight: f32, user_id: i32, table_column_flags: BitFlags<ImGuiTableColumnFlag>) {
		ImGui::_table_setup_column_opts(label, init_width_or_weight, user_id, table_column_flags.bits() as i32);
	}
	pub fn set_next_window_pos(pos: &crate::dora::Vec2) {
		ImGui::set_next_window_pos_opts(pos, ImGuiCond::Always, &Vec2::zero());
	}
	pub fn set_next_window_pos_opts(pos: &crate::dora::Vec2, set_cond: ImGuiCond, pivot: &crate::dora::Vec2) {
		ImGui::_set_next_window_pos_opts(pos, set_cond as i32, pivot);
	}
	pub fn push_style_color<C>(col: ImGuiCol, color: &crate::dora::Color, inside: C) where C: FnOnce() {
		ImGui::_push_style_color(col as i32, color);
		inside();
		ImGui::_pop_style_color(1);
	}
	pub fn push_style_float<C>(style: ImGuiStyleVar, val: f32, inside: C) where C: FnOnce() {
		ImGui::_push_style_float(style as i32, val);
		inside();
		ImGui::_pop_style_var(1);
	}
	pub fn push_style_vec2<C>(style: ImGuiStyleVec2, val: &crate::dora::Vec2, inside: C) where C: FnOnce() {
		ImGui::_push_style_vec2(style as i32, val);
		inside();
		ImGui::_pop_style_var(1);
	}
	pub fn color_button(desc_id: &str, col: &crate::dora::Color) -> bool {
		ImGui::color_button_opts(desc_id, col, BitFlags::default(), &Vec2::zero())
	}
	pub fn color_button_opts(desc_id: &str, col: &crate::dora::Color, color_edit_flags: BitFlags<ImGuiColorEditFlag>, size: &crate::dora::Vec2) -> bool {
		ImGui::_color_button_opts(desc_id, col, color_edit_flags.bits() as i32, size)
	}
	pub fn slider_angle_ret(label: &str, v: f32, v_degrees_min: f32, v_degrees_max: f32) -> (bool, f32) {
		let stack = ImGui::push_f32(v);
		let changed = ImGui::_slider_angle_ret(label, stack, v_degrees_min, v_degrees_max);
		(changed, stack.pop_f32().unwrap())
	}
	pub fn image(clip_str: &str, size: &crate::dora::Vec2) {
		ImGui::image_opts(clip_str, size, &Color::WHITE, &Color::TRANSPARENT);
	}
	pub fn image_button(str_id: &str, clip_str: &str, size: &crate::dora::Vec2) -> bool {
		ImGui::image_button_opts(str_id, clip_str, size, &Color::TRANSPARENT, &Color::WHITE)
	}
	pub fn table_next_row() {
		ImGui::table_next_row_opts(0.0, BitFlags::default());
	}
	pub fn table_next_row_opts(min_row_height: f32, table_row_flags: BitFlags<ImGuiTableRowFlag>) {
		ImGui::_table_next_row_opts(min_row_height, table_row_flags.bits() as i32);
	}
	pub fn begin_list_box<C>(label: &str, size: &crate::dora::Vec2, inside: C) where C: FnOnce() {
		if ImGui::_begin_list_box(label, size) {
			inside();
			ImGui::_end_list_box();
		}
	}
	pub fn begin_group<C>(inside: C) where C: FnOnce() {
		ImGui::_begin_group();
		inside();
		ImGui::_end_group();
	}
	pub fn begin_disabled<C>(inside: C) where C: FnOnce() {
		ImGui::_begin_disabled();
		inside();
		ImGui::_end_disabled();
	}
	pub fn begin_tooltip<C>(inside: C) where C: FnOnce() {
		if ImGui::_begin_tooltip() {
			inside();
			ImGui::_end_tooltip();
		}
	}
	pub fn begin_main_menu_bar<C>(inside: C) where C: FnOnce() {
		if ImGui::_begin_main_menu_bar() {
			inside();
			ImGui::_end_main_menu_bar();
		}
	}
	pub fn begin_menu_bar<C>(inside: C) where C: FnOnce() {
		if ImGui::_begin_menu_bar() {
			inside();
			ImGui::_end_menu_bar();
		}
	}
	pub fn begin_menu<C>(label: &str, enabled: bool, inside: C) where C: FnOnce() {
		if ImGui::_begin_menu(label, enabled) {
			inside();
			ImGui::_end_menu();
		}
	}
	pub fn push_item_width<C>(width: f32, inside: C) where C: FnOnce() {
		ImGui::_push_item_width(width);
		inside();
		ImGui::_pop_item_width();
	}
	pub fn push_text_wrap_pos<C>(wrap_pos_x: f32, inside: C) where C: FnOnce() {
		ImGui::_push_text_wrap_pos(wrap_pos_x);
		inside();
		ImGui::_pop_text_wrap_pos();
	}
	pub fn push_tab_stop<C>(v: bool, inside: C) where C: FnOnce() {
		ImGui::_push_tab_stop(v);
		inside();
		ImGui::_pop_tab_stop();
	}
	pub fn push_button_repeat<C>(repeat: bool, inside: C) where C: FnOnce() {
		ImGui::_push_button_repeat(repeat);
		inside();
		ImGui::_pop_button_repeat();
	}
	pub fn push_id<C>(str_id: &str, inside: C) where C: FnOnce() {
		ImGui::_push_id(str_id);
		inside();
		ImGui::_pop_id();
	}
	pub fn push_clip_rect<C>(clip_rect_min: &crate::dora::Vec2, clip_rect_max: &crate::dora::Vec2, intersect_with_current_clip_rect: bool, inside: C) where C: FnOnce() {
		ImGui::_push_clip_rect(clip_rect_min, clip_rect_max, intersect_with_current_clip_rect);
		inside();
		ImGui::_pop_clip_rect();
	}
}

use std::future::Future;
use std::pin::Pin;
use std::task::{Poll, Context};

enum State {
	Halted,
	Running,
}

pub struct Coroutine {
	state: State,
}

impl Coroutine {
	pub fn waiter<'a>(&'a mut self) -> Waiter<'a> {
		Waiter { co: self }
	}
}

pub struct Waiter<'a> {
	co: &'a mut Coroutine,
}

impl<'a> Future for Waiter<'a> {
	type Output = ();

	fn poll(mut self: Pin<&mut Self>, _cx: &mut Context) -> Poll<Self::Output> {
		 match self.co.state {
			State::Halted => {
				self.co.state = State::Running;
				Poll::Ready(())
			}
			State::Running => {
				self.co.state = State::Halted;
				Poll::Pending
			}
		 }
	}
}

use std::task::{RawWaker, RawWakerVTable, Waker};

fn create_waker() -> Waker {
	unsafe { Waker::from_raw(RAW_WAKER) }
}

const RAW_WAKER: RawWaker = RawWaker::new(std::ptr::null(), &VTABLE);
const VTABLE: RawWakerVTable = RawWakerVTable::new(clone, wake, wake_by_ref, drop);

unsafe fn clone(_: *const ()) -> RawWaker { RAW_WAKER }
unsafe fn wake(_: *const ()) { }
unsafe fn wake_by_ref(_: *const ()) { }
unsafe fn drop(_: *const ()) { }

struct Executor {
	co: Pin<Box<dyn Future<Output=()>>>,
}

impl Executor {
	fn new<C, F>(closure: C) -> Self where
		F: Future<Output=()> + 'static,
		C: FnOnce(Coroutine) -> F, {
		let co = Coroutine { state: State::Running };
		Executor {
			co: Box::pin(closure(co)),
		}
	}

	fn update(&mut self) -> bool {
		let waker = create_waker();
		let mut context = Context::from_waker(&waker);
		match self.co.as_mut().poll(&mut context) {
			Poll::Pending => {
				false
			},
			Poll::Ready(()) => {
				true
			},
		}
	}
}

pub fn once<C, F>(closure: C) -> Box<dyn FnMut(f64) -> bool> where
	F: Future<Output=()> + 'static,
	C: FnOnce(Coroutine) -> F, {
	let mut executor = Executor::new(closure);
	Box::new(move |_| {
		executor.update()
	})
}

pub fn thread<C, F>(closure: C) where
	F: Future<Output=()> + 'static,
	C: FnOnce(Coroutine) -> F, {
	let mut executor = Executor::new(closure);
	Director::get_scheduler().schedule(Box::new(move |_| {
		executor.update()
	}));
}

#[macro_export]
macro_rules! sleep {
	($co:expr, $time:expr) => {
		{
			let total = $time;
			let mut time: f32 = 0.0;
			while time <= total {
				time += dora_ssr::App::get_delta_time() as f32;
				$co.waiter().await;
			}
		}
	};
}

#[macro_export]
macro_rules! cycle {
	($co:expr, $time:expr, $closure:expr) => {
		{
			let total = $time;
			let mut time: f32 = 0.0;
			loop {
				$closure(f32::min(time / $time, 1.0));
				if time >= total {
					break;
				}
				$co.waiter().await;
				time += dora_ssr::App::get_delta_time() as f32;
			}
		}
	};
}

#[macro_export]
macro_rules! wait {
	($co:expr, $condition:expr) => {
		while !$condition {
			$co.waiter().await;
		}
	};
}
