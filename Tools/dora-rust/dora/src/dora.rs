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
}

pub fn print(msg: &str) {
	unsafe { dora_print(from_string(msg)); }
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

#[repr(C)]
#[derive(Clone, Copy)]
#[derive(PartialEq)]
pub struct Vec2 {
	pub x: f32,
	pub y: f32
}

impl Vec2 {
	pub fn new(x: f32, y: f32) -> Vec2 {
		Vec2 { x: x, y: y }
	}
	pub fn zero() -> Vec2 {
		Vec2 { x: 0.0, y: 0.0 }
	}
	pub fn is_zero(&self) -> bool {
		self.x == 0.0 && self.y == 0.0
	}
	pub(crate) fn from(value: i64) -> Vec2 {
		unsafe { LightValue { value: value }.vec2 }
	}
	pub(crate) fn into_i64(&self) -> i64 {
		unsafe { LightValue { vec2: *self }.value }
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
	pub fn add<'a, T>(&mut self, v: T) where T: IntoValue<'a> {
		unsafe { array_add(self.raw(), v.val().raw()); }
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
	fn observer_watch(observer: i64, func: i32, stack: i64) -> i64;
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
	pub fn begin_ret(name: &str, opened: bool) -> (bool, bool) {
		let stack = ImGui::push_bool(opened);
		let changed = ImGui::_begin(name, stack);
		(changed, stack.pop_bool().unwrap())
	}
	pub fn begin_ret_opts(name: &str, opened: bool, windows_flags: &Vec<&str>) -> (bool, bool) {
		let stack = ImGui::push_bool(opened);
		let changed = ImGui::_begin_opts(name, stack, windows_flags);
		(changed, stack.pop_bool().unwrap())
	}
	pub fn collapsing_header_ret(label: &str, opened: bool) -> (bool, bool) {
		let stack = ImGui::push_bool(opened);
		let changed = ImGui::_collapsing_header(label, stack);
		(changed, stack.pop_bool().unwrap())
	}
	pub fn collapsing_header_ret_opts(label: &str, opened: bool, tree_node_flags: &Vec<&str>) -> (bool, bool) {
		let stack = ImGui::push_bool(opened);
		let changed = ImGui::_collapsing_header_opts(label, stack, tree_node_flags);
		(changed, stack.pop_bool().unwrap())
	}
	pub fn selectable_ret(label: &str, selected: bool) -> (bool, bool) {
		let stack = ImGui::push_bool(selected);
		let changed = ImGui::_selectable(label, stack);
		(changed, stack.pop_bool().unwrap())
	}
	pub fn selectable_ret_opts(label: &str, selected: bool, size: &crate::dora::Vec2, selectable_flags: &Vec<&str>) -> (bool, bool) {
		let stack = ImGui::push_bool(selected);
		let changed = ImGui::_selectable_opts(label, stack, size, selectable_flags);
		(changed, stack.pop_bool().unwrap())
	}
	pub fn begin_popup_modal_ret(name: &str, opened: bool) -> (bool, bool) {
		let stack = ImGui::push_bool(opened);
		let changed = ImGui::_begin_popup_modal(name, stack);
		(changed, stack.pop_bool().unwrap())
	}
	pub fn begin_popup_modal_ret_opts(name: &str, opened: bool, windows_flags: &Vec<&str>) -> (bool, bool) {
		let stack = ImGui::push_bool(opened);
		let changed = ImGui::_begin_popup_modal_opts(name, stack, windows_flags);
		(changed, stack.pop_bool().unwrap())
	}
	pub fn combo_ret(label: &str, current_item: i32, items: &Vec<&str>) -> (bool, i32) {
		let stack = ImGui::push_i32(current_item);
		let changed = ImGui::_combo(label, stack, items);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn combo_ret_opts(label: &str, current_item: i32, items: &Vec<&str>, height_in_items: i32) -> (bool, i32) {
		let stack = ImGui::push_i32(current_item);
		let changed = ImGui::_combo_opts(label, stack, items, height_in_items);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn drag_float_ret(label: &str, v: f32, v_speed: f32, v_min: f32, v_max: f32) -> (bool, f32) {
		let stack = ImGui::push_f32(v);
		let changed = ImGui::_drag_float(label, stack, v_speed, v_min, v_max);
		(changed, stack.pop_f32().unwrap())
	}
	pub fn drag_float_ret_opts(label: &str, v: f32, v_speed: f32, v_min: f32, v_max: f32, display_format: &str, slider_flags: &Vec<&str>) -> (bool, f32) {
		let stack = ImGui::push_f32(v);
		let changed = ImGui::_drag_float_opts(label, stack, v_speed, v_min, v_max, display_format, slider_flags);
		(changed, stack.pop_f32().unwrap())
	}
	pub fn drag_float2_ret(label: &str, v1: f32, v2: f32, v_speed: f32, v_min: f32, v_max: f32) -> (bool, f32, f32) {
		let stack = ImGui::push_f32x2(v1, v2);
		let changed = ImGui::_drag_float2(label, stack, v_speed, v_min, v_max);
		(changed, stack.pop_f32().unwrap(), stack.pop_f32().unwrap())
	}
	pub fn drag_float2_ret_opts(label: &str, v1: f32, v2: f32, v_speed: f32, v_min: f32, v_max: f32, display_format: &str, slider_flags: &Vec<&str>) -> (bool, f32, f32) {
		let stack = ImGui::push_f32x2(v1, v2);
		let changed = ImGui::_drag_float2_opts(label, stack, v_speed, v_min, v_max, display_format, slider_flags);
		(changed, stack.pop_f32().unwrap(), stack.pop_f32().unwrap())
	}
	pub fn drag_int2_ret(label: &str, v1: i32, v2: i32, v_speed: f32, v_min: i32, v_max: i32) -> (bool, i32, i32) {
		let stack = ImGui::push_i32x2(v1, v2);
		let changed = ImGui::_drag_int2(label, stack, v_speed, v_min, v_max);
		(changed, stack.pop_i32().unwrap(), stack.pop_i32().unwrap())
	}
	pub fn drag_int2_opts(label: &str, v1: i32, v2: i32, v_speed: f32, v_min: i32, v_max: i32, display_format: &str, slider_flags: &Vec<&str>) -> (bool, i32, i32) {
		let stack = ImGui::push_i32x2(v1, v2);
		let changed = ImGui::_drag_int2_opts(label, stack, v_speed, v_min, v_max, display_format, slider_flags);
		(changed, stack.pop_i32().unwrap(), stack.pop_i32().unwrap())
	}
	pub fn input_float_ret(label: &str, v: f32) -> (bool, f32) {
		let stack = ImGui::push_f32(v);
		let changed = ImGui::_input_float(label, stack);
		(changed, stack.pop_f32().unwrap())
	}
	pub fn input_float_ret_opts(label: &str, v: f32, step: f32, step_fast: f32, display_format: &str, input_text_flags: &Vec<&str>) -> (bool, f32) {
		let stack = ImGui::push_f32(v);
		let changed = ImGui::_input_float_opts(label, stack, step, step_fast, display_format, input_text_flags);
		(changed, stack.pop_f32().unwrap())
	}
	pub fn input_float2_ret(label: &str, v1: f32, v2: f32) -> (bool, f32, f32) {
		let stack = ImGui::push_f32x2(v1, v2);
		let changed = ImGui::_input_float2(label, stack);
		(changed, stack.pop_f32().unwrap(), stack.pop_f32().unwrap())
	}
	pub fn input_float2_ret_opts(label: &str, v1: f32, v2: f32, display_format: &str, input_text_flags: &Vec<&str>) -> (bool, f32, f32) {
		let stack = ImGui::push_f32x2(v1, v2);
		let changed = ImGui::_input_float2_opts(label, stack, display_format, input_text_flags);
		(changed, stack.pop_f32().unwrap(), stack.pop_f32().unwrap())
	}
	pub fn input_int_ret(label: &str, v: i32) -> (bool, i32) {
		let stack = ImGui::push_i32(v);
		let changed = ImGui::_input_int(label, stack);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn input_int_ret_opts(label: &str, v: i32, step: i32, step_fast: i32, input_text_flags: &Vec<&str>) -> (bool, i32) {
		let stack = ImGui::push_i32(v);
		let changed = ImGui::_input_int_opts(label, stack, step, step_fast, input_text_flags);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn input_int2_ret(label: &str, v1: i32, v2: i32) -> (bool, i32, i32) {
		let stack = ImGui::push_i32x2(v1, v2);
		let changed = ImGui::_input_int2(label, stack);
		(changed, stack.pop_i32().unwrap(), stack.pop_i32().unwrap())
	}
	pub fn input_int2_ret_opts(label: &str, v1: i32, v2: i32, input_text_flags: &Vec<&str>) -> (bool, i32, i32) {
		let stack = ImGui::push_i32x2(v1, v2);
		let changed = ImGui::_input_int2_opts(label, stack, input_text_flags);
		(changed, stack.pop_i32().unwrap(), stack.pop_i32().unwrap())
	}
	pub fn slider_float_ret(label: &str, v: f32, v_min: f32, v_max: f32) -> (bool, f32) {
		let stack = ImGui::push_f32(v);
		let changed = ImGui::_slider_float(label, stack, v_min, v_max);
		(changed, stack.pop_f32().unwrap())
	}
	pub fn slider_float_ret_opts(label: &str, v: f32, v_min: f32, v_max: f32, display_format: &str, slider_flags: &Vec<&str>) -> (bool, f32) {
		let stack = ImGui::push_f32(v);
		let changed = ImGui::_slider_float_opts(label, stack, v_min, v_max, display_format, slider_flags);
		(changed, stack.pop_f32().unwrap())
	}
	pub fn slider_float2_ret(label: &str, v1: f32, v2: f32, v_min: f32, v_max: f32) -> (bool, f32, f32) {
		let stack = ImGui::push_f32x2(v1, v2);
		let changed = ImGui::_slider_float2(label, stack, v_min, v_max);
		(changed, stack.pop_f32().unwrap(), stack.pop_f32().unwrap())
	}
	pub fn slider_float2_ret_opts(label: &str, v1: f32, v2: f32, v_min: f32, v_max: f32, display_format: &str, slider_flags: &Vec<&str>) -> (bool, f32, f32) {
		let stack = ImGui::push_f32x2(v1, v2);
		let changed = ImGui::_slider_float2_opts(label, stack, v_min, v_max, display_format, slider_flags);
		(changed, stack.pop_f32().unwrap(), stack.pop_f32().unwrap())
	}
	pub fn drag_float_range2_ret(label: &str, v_current_min: f32, v_current_max: f32, v_speed: f32, v_min: f32, v_max: f32) -> (bool, f32, f32) {
		let stack = ImGui::push_f32x2(v_current_min, v_current_max);
		let changed = ImGui::_drag_float_range2(label, stack, v_speed, v_min, v_max);
		(changed, stack.pop_f32().unwrap(), stack.pop_f32().unwrap())
	}
	pub fn drag_float_range2_ret_opts(label: &str, v_current_min: f32, v_current_max: f32, v_speed: f32, v_min: f32, v_max: f32, format: &str, format_max: &str, slider_flags: &Vec<&str>) -> (bool, f32, f32) {
		let stack = ImGui::push_f32x2(v_current_min, v_current_max);
		let changed = ImGui::_drag_float_range2_opts(label, stack, v_speed, v_min, v_max, format, format_max, slider_flags);
		(changed, stack.pop_f32().unwrap(), stack.pop_f32().unwrap())
	}
	pub fn drag_int(label: &str, value: i32, v_speed: f32, v_min: i32, v_max: i32) -> (bool, i32) {
		let stack = ImGui::push_i32(value);
		let changed = ImGui::_drag_int(label, stack, v_speed, v_min, v_max);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn drag_int_opts(label: &str, value: i32, v_speed: f32, v_min: i32, v_max: i32, display_format: &str, slider_flags: &Vec<&str>) -> (bool, i32) {
		let stack = ImGui::push_i32(value);
		let changed = ImGui::_drag_int_opts(label, stack, v_speed, v_min, v_max, display_format, slider_flags);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn drag_int_range2_ret(label: &str, v_current_min: i32, v_current_max: i32, v_speed: f32, v_min: i32, v_max: i32) -> (bool, i32, i32) {
		let stack = ImGui::push_i32x2(v_current_min, v_current_max);
		let changed = ImGui::_drag_int_range2(label, stack, v_speed, v_min, v_max);
		(changed, stack.pop_i32().unwrap(), stack.pop_i32().unwrap())
	}
	pub fn drag_int_range2_ret_opts(label: &str, v_current_min: i32, v_current_max: i32, v_speed: f32, v_min: i32, v_max: i32, format: &str, format_max: &str, slider_flags: &Vec<&str>) -> (bool, i32, i32) {
		let stack = ImGui::push_i32x2(v_current_min, v_current_max);
		let changed = ImGui::_drag_int_range2_opts(label, stack, v_speed, v_min, v_max, format, format_max, slider_flags);
		(changed, stack.pop_i32().unwrap(), stack.pop_i32().unwrap())
	}
	pub fn slider_int(label: &str, value: i32, v_min: i32, v_max: i32) -> (bool, i32) {
		let stack = ImGui::push_i32(value);
		let changed = ImGui::_slider_int(label, stack, v_min, v_max);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn slider_int_opts(label: &str, value: i32, v_min: i32, v_max: i32, format: &str, slider_flags: &Vec<&str>) -> (bool, i32) {
		let stack = ImGui::push_i32(value);
		let changed = ImGui::_slider_int_opts(label, stack, v_min, v_max, format, slider_flags);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn slider_int2(label: &str, v1: i32, v2: i32, v_min: i32, v_max: i32) -> (bool, i32, i32) {
		let stack = ImGui::push_i32x2(v1, v2);
		let changed = ImGui::_slider_int2(label, stack, v_min, v_max);
		(changed, stack.pop_i32().unwrap(), stack.pop_i32().unwrap())
	}
	pub fn slider_int2_opts(label: &str, v1: i32, v2: i32, v_min: i32, v_max: i32, display_format: &str, slider_flags: &Vec<&str>) -> (bool, i32, i32) {
		let stack = ImGui::push_i32x2(v1, v2);
		let changed = ImGui::_slider_int2_opts(label, stack, v_min, v_max, display_format, slider_flags);
		(changed, stack.pop_i32().unwrap(), stack.pop_i32().unwrap())
	}
	pub fn v_slider_float_ret(label: &str, size: &crate::dora::Vec2, v: f32, v_min: f32, v_max: f32) -> (bool, f32) {
		let stack = ImGui::push_f32(v);
		let changed = ImGui::_v_slider_float(label, size, stack, v_min, v_max);
		(changed, stack.pop_f32().unwrap())
	}
	pub fn v_slider_float_ret_opts(label: &str, size: &crate::dora::Vec2, v: f32, v_min: f32, v_max: f32, format: &str, slider_flags: &Vec<&str>) -> (bool, f32) {
		let stack = ImGui::push_f32(v);
		let changed = ImGui::_v_slider_float_opts(label, size, stack, v_min, v_max, format, slider_flags);
		(changed, stack.pop_f32().unwrap())
	}
	pub fn v_slider_int_ret(label: &str, size: &crate::dora::Vec2, v: i32, v_min: i32, v_max: i32) -> (bool, i32) {
		let stack = ImGui::push_i32(v);
		let changed = ImGui::_v_slider_int(label, size, stack, v_min, v_max);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn v_slider_int_ret_opts(label: &str, size: &crate::dora::Vec2, v: i32, v_min: i32, v_max: i32, format: &str, slider_flags: &Vec<&str>) -> (bool, i32) {
		let stack = ImGui::push_i32(v);
		let changed = ImGui::_v_slider_int_opts(label, size, stack, v_min, v_max, format, slider_flags);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn color_edit3(label: &str, color3: &Color3) -> (bool, Color3) {
		let stack = ImGui::push_i32(color3.to_rgb() as i32);
		let changed = ImGui::_color_edit3(label, stack);
		(changed, Color3::new(stack.pop_i32().unwrap() as u32))
	}
	pub fn color_edit4(label: &str, color: &Color, show_alpha: bool) -> (bool, Color) {
		let stack = ImGui::push_i32(color.to_argb() as i32);
		let changed = ImGui::_color_edit4(label, stack, show_alpha);
		(changed, Color::new(stack.pop_i32().unwrap() as u32))
	}
	pub fn checkbox(label: &str, checked: bool) -> (bool, bool) {
		let stack = ImGui::push_bool(checked);
		let changed = ImGui::_checkbox(label, stack);
		(changed, stack.pop_bool().unwrap())
	}
	pub fn radio_button(label: &str, value: i32, v_button: i32) -> (bool, i32) {
		let stack = ImGui::push_i32(value);
		let changed = ImGui::_radio_button(label, stack, v_button);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn list_box(label: &str, current_item: i32, items: &Vec<&str>) -> (bool, i32) {
		let stack = ImGui::push_i32(current_item);
		let changed = ImGui::_list_box(label, stack, items);
		(changed, stack.pop_i32().unwrap())
	}
	pub fn list_box_with_height(label: &str, current_item: i32, items: &Vec<&str>, height_in_items: i32) -> (bool, i32) {
		let stack = ImGui::push_i32(current_item);
		let changed = ImGui::_list_box_with_height(label, stack, items, height_in_items);
		(changed, stack.pop_i32().unwrap())
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
			let mut time = 0.0;
			while time <= $time {
				time += dora_ssr::App::get_delta_time();
				$co.waiter().await;
			}
		}
	};
}

#[macro_export]
macro_rules! cycle {
	($co:expr, $time:expr, $closure:expr) => {
		{
			let mut time = 0.0;
			loop {
				$closure(f64::min(time / $time, 1.0));
				if time >= $time {
					break;
				}
				$co.waiter().await;
				time += dora_ssr::App::get_delta_time();
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
