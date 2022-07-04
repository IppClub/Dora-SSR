use std::{ffi::c_void, any::Any};
use once_cell::sync::Lazy;
mod node;
pub use node::{INode, Node};
mod array;
pub use array::Array;
mod dictionary;
pub use dictionary::Dictionary;
mod director;
pub use director::Director;

extern "C" {
	fn object_get_id(obj: i64) -> i32;
	fn object_get_type(obj: i64) -> i32;
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

	fn value_create_i32(value: i32) -> i64;
	fn value_create_i64(value: i64) -> i64;
	fn value_create_f32(value: f32) -> i64;
	fn value_create_f64(value: f64) -> i64;
	fn value_create_str(value: i64) -> i64;
	fn value_create_bool(value: i32) -> i64;
	fn value_create_object(value: i64) -> i64;
	fn value_create_vec2(value: i64) -> i64;
	fn value_create_size(value: i64) -> i64;
	fn value_release(value: i64);
	fn value_into_i32(value: i64) -> i32;
	fn value_into_i64(value: i64) -> i64;
	fn value_into_f32(value: i64) -> f32;
	fn value_into_f64(value: i64) -> f64;
	fn value_into_str(value: i64) -> i64;
	fn value_into_bool(value: i64) -> i32;
	fn value_into_object(value: i64) -> i64;
	fn value_into_vec2(value: i64) -> i64;
	fn value_into_size(value: i64) -> i64;
	fn value_is_i32(value: i64) -> i32;
	fn value_is_i64(value: i64) -> i32;
	fn value_is_f32(value: i64) -> i32;
	fn value_is_f64(value: i64) -> i32;
	fn value_is_str(value: i64) -> i32;
	fn value_is_bool(value: i64) -> i32;
	fn value_is_object(value: i64) -> i32;
	fn value_is_vec2(value: i64) -> i32;
	fn value_is_size(value: i64) -> i32;

	fn call_stack_create() -> i64;
	fn call_stack_release(info: i64);
	fn call_stack_push_i32(info: i64, value: i32);
	fn call_stack_push_i64(info: i64, value: i64);
	fn call_stack_push_f32(info: i64, value: f32);
	fn call_stack_push_f64(info: i64, value: f64);
	fn call_stack_push_str(info: i64, value: i64);
	fn call_stack_push_bool(info: i64, value: i32);
	fn call_stack_push_object(info: i64, value: i64);
	fn call_stack_push_vec2(info: i64, value: i64);
	fn call_stack_push_size(info: i64, value: i64);
	fn call_stack_pop_i32(info: i64) -> i32;
	fn call_stack_pop_i64(info: i64) -> i64;
	fn call_stack_pop_f32(info: i64) -> f32;
	fn call_stack_pop_f64(info: i64) -> f64;
	fn call_stack_pop_str(info: i64) -> i64;
	fn call_stack_pop_bool(info: i64) -> i32;
	fn call_stack_pop_object(info: i64) -> i64;
	fn call_stack_pop_vec2(info: i64) -> i64;
	fn call_stack_pop_size(info: i64) -> i64;
	fn call_stack_front_i32(info: i64) -> i32;
	fn call_stack_front_i64(info: i64) -> i32;
	fn call_stack_front_f32(info: i64) -> i32;
	fn call_stack_front_f64(info: i64) -> i32;
	fn call_stack_front_str(info: i64) -> i32;
	fn call_stack_front_bool(info: i64) -> i32;
	fn call_stack_front_object(info: i64) -> i32;
	fn call_stack_front_vec2(info: i64) -> i32;
	fn call_stack_front_size(info: i64) -> i32;
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct Vec2 {
	pub x: f32,
	pub y: f32
}

impl Vec2 {
	pub fn from(value: i64) -> Vec2 {
		unsafe { LightValue { value: value }.vec2 }
	}
	pub fn into_i64(&self) -> i64 {
		unsafe { LightValue { vec2: *self }.value }
	}
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct Size {
	pub width: f32,
	pub height: f32
}

impl Size {
	pub fn from(value: i64) -> Size {
		unsafe { LightValue { value: value }.size }
	}
	pub fn into_i64(&self) -> i64 {
		unsafe { LightValue { size: *self }.value }
	}
}

#[repr(C)]
union LightValue {
	vec2: Vec2,
	size: Size,
	value: i64,
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
	pub fn from_bool(s: &Vec<bool>) -> i64 {
		unsafe {
			let len = s.len() as i32;
			let mut bools: Vec<i32> = Vec::with_capacity(s.len());
			for i in 0..s.len() {
				bools.push(if s[i] { 1 } else { 0 });
			}
			let ptr = bools.as_ptr();
			let new_vec = buf_new_i32(len);
			buf_write(new_vec, ptr as *const c_void);
			return new_vec;
		}
	}
}

fn none_type(_: i64) -> Option<Box<dyn Object>> { None }

static mut OBJECT_MAP: Lazy<Vec<fn(i64) -> Option<Box<dyn Object>>>> = Lazy::new(|| {
	let mut map: Vec<fn(i64) -> Option<Box<dyn Object>>> = Vec::new();
	let type_funcs = [
		Node::type_info(),
		Array::type_info(),
		Dictionary::type_info(),
	];
	for pair in type_funcs.iter() {
		let t = pair.0 as usize;
		if map.len() < t + 1 {
			map.resize(t + 1, none_type);
			map[t] = pair.1;
		}
	}
	map
});
static mut FUNC_MAP: Vec<Box<dyn FnMut()>> = Vec::new();
static mut FUNC_AVAILABLE: Vec<i32> = Vec::new();

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

pub trait Object {
	fn raw(&self) -> i64;
	fn obj(&self) -> &dyn Object;
	fn get_id(&self) -> i32 { unsafe { object_get_id(self.raw()) } }
	fn as_any(&self) -> &dyn Any;
	fn as_any_mut(&mut self) -> &mut dyn Any;
}

pub struct CallStack { raw: i64 }

pub enum DoraValue<'a> {
	I32(i32),
	I64(i64),
	F32(f32),
	F64(f64),
	Bool(bool),
	Str(&'a str),
	Object(&'a dyn Object),
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
		unsafe { Value{ raw: value_create_i32(self) } }
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
		unsafe { Value{ raw: value_create_f32(self) } }
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

impl<'a> IntoValue<'a> for &'a dyn Object {
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
			let mut stack = CallStack::new();
			$(
				Value::new($x).push(&mut stack);
			)*
			stack
		}
	};
}

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
			if value_is_i32(self.raw) != 0 {
				Some(value_into_i32(self.raw))
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
			if value_is_f32(self.raw) != 0 {
				Some(value_into_f32(self.raw))
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
	pub fn into_object(&self) -> Option<Box<dyn Object>> {
		unsafe {
			if value_is_object(self.raw) != 0 {
				let raw = value_into_object(self.raw);
				OBJECT_MAP[object_get_type(raw) as usize](raw)
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
}

impl Drop for Value {
	fn drop(&mut self) { unsafe { value_release(self.raw); } }
}

impl CallStack {
	fn raw(&self) -> i64 {
		self.raw
	}
	pub fn new() -> CallStack {
		CallStack { raw: unsafe { call_stack_create() } }
	}
	pub fn push_i32(&mut self, value: i32) {
		unsafe { call_stack_push_i32(self.raw, value); }
	}
	pub fn push_i64(&mut self, value: i64) {
		unsafe { call_stack_push_i64(self.raw, value); }
	}
	pub fn push_f32(&mut self, value: f32) {
		unsafe { call_stack_push_f32(self.raw, value); }
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
	pub fn push_object(&mut self, value: &dyn Object) {
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
			if call_stack_front_i32(self.raw) != 0 {
				Some(call_stack_pop_i32(self.raw))
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
			if call_stack_front_f32(self.raw) != 0 {
				Some(call_stack_pop_f32(self.raw))
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
	pub fn pop_object(&mut self) -> Option<Box<dyn Object>> {
		unsafe {
			if call_stack_front_object(self.raw) != 0 {
				let raw = call_stack_pop_object(self.raw);
				OBJECT_MAP[object_get_type(raw) as usize](raw)
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
}

impl Drop for CallStack {
	fn drop(&mut self) { unsafe { call_stack_release(self.raw); } }
}
