use std::{ffi::c_void, any::Any};
use dora::object_macro;

extern "C" {
	fn object_get_id(obj: i64) -> i32;
	fn object_get_type(obj: i64) -> i32;
	fn object_release(obj: i64);

	fn str_new(len: i32) -> i64;
	fn str_len(str: i64) -> i32;
	fn str_read(dest: *mut c_void, src: i64);
	fn str_write(dest: i64, src: *const c_void);
	fn str_release(str: i64);

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

	fn call_info_create() -> i64;
	fn call_info_release(info: i64);
	fn call_info_push_i32(info: i64, value: i32);
	fn call_info_push_i64(info: i64, value: i64);
	fn call_info_push_f32(info: i64, value: f32);
	fn call_info_push_f64(info: i64, value: f64);
	fn call_info_push_str(info: i64, value: i64);
	fn call_info_push_bool(info: i64, value: i32);
	fn call_info_push_object(info: i64, value: i64);
	fn call_info_push_vec2(info: i64, value: i64);
	fn call_info_push_size(info: i64, value: i64);
	fn call_info_pop_i32(info: i64) -> i32;
	fn call_info_pop_i64(info: i64) -> i64;
	fn call_info_pop_f32(info: i64) -> f32;
	fn call_info_pop_f64(info: i64) -> f64;
	fn call_info_pop_str(info: i64) -> i64;
	fn call_info_pop_bool(info: i64) -> i32;
	fn call_info_pop_object(info: i64) -> i64;
	fn call_info_pop_vec2(info: i64) -> i64;
	fn call_info_pop_size(info: i64) -> i64;
	fn call_info_front_i32(info: i64) -> i32;
	fn call_info_front_i64(info: i64) -> i32;
	fn call_info_front_f32(info: i64) -> i32;
	fn call_info_front_f64(info: i64) -> i32;
	fn call_info_front_str(info: i64) -> i32;
	fn call_info_front_bool(info: i64) -> i32;
	fn call_info_front_object(info: i64) -> i32;
	fn call_info_front_vec2(info: i64) -> i32;
	fn call_info_front_size(info: i64) -> i32;

	fn node_type() -> i32;
	fn node_create() -> i64;
	fn node_set_x(node: i64, var: f32);
	fn node_get_x(node: i64) -> f32;
	fn node_set_position(node: i64, var: i64);
	fn node_get_position(node: i64) -> i64;
	fn node_set_tag(node: i64, var: i64);
	fn node_get_tag(node: i64) -> i64;
	fn node_get_children(node: i64) -> i64;
	fn node_get_userdata(node: i64) -> i64;
	fn node_add_child(node: i64, child: i64);
	fn node_schedule(node: i64, func: i32, stack: i64);
	fn node_emit(node: i64, name: i64, stack: i64);
	fn node_slot(node: i64, name: i64, func: i32, stack: i64);

	fn array_type() -> i32;
	fn array_create() -> i64;
	fn array_set(array: i64, index: i32, v: i64) -> i32;
	fn array_get(array: i64, index: i32) -> i64;
	fn array_len(array: i64) -> i32;
	fn array_capacity(array: i64) -> i32;
	fn array_is_empty(array: i64) -> i32;
	fn array_add_range(array: i64, other: i64);
	fn array_remove_from(array: i64, other: i64);
	fn array_clear(array: i64);
	fn array_reverse(array: i64);
	fn array_shrink(array: i64);
	fn array_swap(array: i64, indexA: i32, indexB: i32);
	fn array_remove_at(array: i64, index: i32) -> i32;
	fn array_fast_remove_at(array: i64, index: i32) -> i32;
	fn array_first(array: i64) -> i64;
	fn array_last(array: i64) -> i64;
	fn array_random_object(array: i64) -> i64;
	fn array_add(array: i64, item: i64);
	fn array_insert(array: i64, index: i32, item: i64);
	fn array_contains(array: i64, item: i64) -> i32;
	fn array_index(array: i64, item: i64) -> i32;
	fn array_remove_last(array: i64) -> i64;
	fn array_fast_remove(array: i64, item: i64) -> i32;

	fn dictionary_type() -> i32;
	fn dictionary_create() -> i64;
	fn dictionary_set(dict: i64, key: i64, value: i64);
	fn dictionary_get(dict: i64, key: i64) -> i64;
	fn dictionary_len(dict: i64) -> i32;
	fn dictionary_get_keys(dict: i64) -> i64;
	fn dictionary_clear(dict: i64);

	fn director_get_entry() -> i64;
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct Vec2 {
	pub x: f32,
	pub y: f32
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct Size {
	pub width: f32,
	pub height: f32
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

static mut OBJECT_MAP: Vec<fn(i64) -> Option<Box<dyn Object>>> = Vec::new();
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

pub struct CallInfo { raw: i64 }

pub enum Value<'a> {
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
	fn val(self) -> Value<'a>;
	fn dora_val(self) -> DoraValue;
}

impl<'a> Value<'a> {
	pub fn new<A>(value: A) -> Value<'a>
		where A: IntoValue<'a> {
		value.val()
	}

	pub fn push(self, info: &mut CallInfo) {
		match self {
			Value::I32(x) => { info.push_i32(x); },
			Value::I64(x) => { info.push_i64(x); },
			Value::F32(x) => { info.push_f32(x); },
			Value::F64(x) => { info.push_f64(x); },
			Value::Bool(x) => { info.push_bool(x); },
			Value::Str(x) => { info.push_str(x); },
			Value::Object(x) => { info.push_object(x); },
			Value::Vec2(x) => { info.push_vec2(&x); },
			Value::Size(x) => { info.push_size(&x); },
		}
	}
}

impl<'a> IntoValue<'a> for i32 {
	fn val(self) -> Value<'a> { Value::I32(self) }
	fn dora_val(self) -> DoraValue {
		unsafe { DoraValue{ raw: value_create_i32(self) } }
	}
}

impl<'a> IntoValue<'a> for i64 {
	fn val(self) -> Value<'a> { Value::I64(self) }
	fn dora_val(self) -> DoraValue {
		unsafe { DoraValue{ raw: value_create_i64(self) } }
	}
}

impl<'a> IntoValue<'a> for f32 {
	fn val(self) -> Value<'a> { Value::F32(self) }
	fn dora_val(self) -> DoraValue {
		unsafe { DoraValue{ raw: value_create_f32(self) } }
	}
}

impl<'a> IntoValue<'a> for f64 {
	fn val(self) -> Value<'a> { Value::F64(self) }
	fn dora_val(self) -> DoraValue {
		unsafe { DoraValue{ raw: value_create_f64(self) } }
	}
}

impl<'a> IntoValue<'a> for bool {
	fn val(self) -> Value<'a> { Value::Bool(self) }
	fn dora_val(self) -> DoraValue {
		unsafe { DoraValue{ raw: value_create_bool(if self { 1 } else { 0 }) } }
	}
}

impl<'a> IntoValue<'a> for &'a str {
	fn val(self) -> Value<'a> { Value::Str(self) }
	fn dora_val(self) -> DoraValue {
		unsafe { DoraValue{ raw: value_create_str(from_string(self)) } }
	}
}

impl<'a> IntoValue<'a> for &'a dyn Object {
	fn val(self) -> Value<'a> { Value::Object(self) }
	fn dora_val(self) -> DoraValue {
		unsafe { DoraValue{ raw: value_create_object(self.raw()) } }
	}
}

impl<'a> IntoValue<'a> for Vec2 {
	fn val(self) -> Value<'a> { Value::Vec2(self) }
	fn dora_val(self) -> DoraValue {
		unsafe { DoraValue{ raw: value_create_vec2(LightValue{ vec2: self }.value) } }
	}
}

impl<'a> IntoValue<'a> for Size {
	fn val(self) -> Value<'a> { Value::Size(self) }
	fn dora_val(self) -> DoraValue {
		unsafe { DoraValue{ raw: value_create_size(LightValue{ size: self }.value) } }
	}
}

#[macro_export]
macro_rules! args {
	( $( $x:expr ),* ) => {
		{
			let mut stack = CallInfo::new();
			$(
				Value::new($x).push(&mut stack);
			)*
			stack
		}
	};
}

pub struct DoraValue { raw: i64 }

impl DoraValue {
	fn from(raw: i64) -> Option<DoraValue> {
		match raw {
			0 => { None },
			_ => { Some(DoraValue { raw: raw }) }
		}
	}
	pub fn raw(&self) -> i64 { self.raw }
	pub fn into_i32(&self) -> Option<i32> {
		unsafe {
			if value_is_i32(self.raw) > 0 {
				Some(value_into_i32(self.raw))
			} else { None }
		}
	}
	pub fn into_i64(&self) -> Option<i64> {
		unsafe {
			if value_is_i64(self.raw) > 0 {
				Some(value_into_i64(self.raw))
			} else { None }
		}
	}
	pub fn into_f32(&self) -> Option<f32> {
		unsafe {
			if value_is_f32(self.raw) > 0 {
				Some(value_into_f32(self.raw))
			} else { None }
		}
	}
	pub fn into_f64(&self) -> Option<f64> {
		unsafe {
			if value_is_f64(self.raw) > 0 {
				Some(value_into_f64(self.raw))
			} else { None }
		}
	}
	pub fn into_bool(&self) -> Option<bool> {
		unsafe {
			if value_is_bool(self.raw) > 0 {
				Some(value_into_bool(self.raw) > 0)
			} else { None }
		}
	}
	pub fn into_str(&self) -> Option<String> {
		unsafe {
			if value_is_str(self.raw) > 0 {
				Some(to_string(value_into_str(self.raw)))
			} else { None }
		}
	}
	pub fn into_object(&self) -> Option<Box<dyn Object>> {
		unsafe {
			if value_is_object(self.raw) > 0 {
				let raw = value_into_object(self.raw);
				OBJECT_MAP[object_get_type(raw) as usize](raw)
			} else { None }
		}
	}
	pub fn into_vec2(&self) -> Option<Vec2> {
		unsafe {
			if value_is_vec2(self.raw) > 0 {
				Some(LightValue{ value: value_into_vec2(self.raw) }.vec2)
			} else { None }
		}
	}
	pub fn into_size(&self) -> Option<Size> {
		unsafe {
			if value_is_size(self.raw) > 0 {
				Some(LightValue{ value: value_into_size(self.raw) }.size)
			} else { None }
		}
	}
}

impl Drop for DoraValue {
	fn drop(&mut self) { unsafe { value_release(self.raw); } }
}

impl CallInfo {
	fn raw(&self) -> i64 {
		self.raw
	}
	pub fn new() -> CallInfo {
		CallInfo { raw: unsafe { call_info_create() } }
	}
	pub fn push_i32(&mut self, value: i32) {
		unsafe { call_info_push_i32(self.raw, value); }
	}
	pub fn push_i64(&mut self, value: i64) {
		unsafe { call_info_push_i64(self.raw, value); }
	}
	pub fn push_f32(&mut self, value: f32) {
		unsafe { call_info_push_f32(self.raw, value); }
	}
	pub fn push_f64(&mut self, value: f64) {
		unsafe { call_info_push_f64(self.raw, value); }
	}
	pub fn push_str(&mut self, value: &str) {
		unsafe { call_info_push_str(self.raw, from_string(value)); }
	}
	pub fn push_bool(&mut self, value: bool) {
		unsafe { call_info_push_bool(self.raw, if value { 1 } else { 0 }); }
	}
	pub fn push_object(&mut self, value: &dyn Object) {
		unsafe { call_info_push_object(self.raw, value.raw()); }
	}
	pub fn push_vec2(&mut self, value: &Vec2) {
		unsafe { call_info_push_vec2(self.raw, LightValue{ vec2: *value }.value); }
	}
	pub fn push_size(&mut self, value: &Size) {
		unsafe { call_info_push_size(self.raw, LightValue{ size: *value }.value); }
	}
	pub fn pop_i32(&mut self) -> Option<i32> {
		unsafe {
			if call_info_front_i32(self.raw) > 0 {
				Some(call_info_pop_i32(self.raw))
			} else { None }
		}
	}
	pub fn pop_i64(&mut self) -> Option<i64> {
		unsafe {
			if call_info_front_i64(self.raw) > 0 {
				Some(call_info_pop_i64(self.raw))
			} else { None }
		}
	}
	pub fn pop_f32(&mut self) -> Option<f32> {
		unsafe {
			if call_info_front_f32(self.raw) > 0 {
				Some(call_info_pop_f32(self.raw))
			} else { None }
		}
	}
	pub fn pop_f64(&mut self) -> Option<f64> {
		unsafe {
			if call_info_front_f64(self.raw) > 0 {
				Some(call_info_pop_f64(self.raw))
			} else { None }
		}
	}
	pub fn pop_str(&mut self) -> Option<String> {
		unsafe {
			if call_info_front_str(self.raw) > 0 {
				Some(to_string(call_info_pop_str(self.raw)))
			} else { None }
		}
	}
	pub fn pop_bool(&mut self) -> Option<bool> {
		unsafe {
			if call_info_front_bool(self.raw) > 0 {
				Some(call_info_pop_bool(self.raw) > 0)
			} else { None }
		}
	}
	pub fn pop_object(&mut self) -> Option<Box<dyn Object>> {
		unsafe {
			if call_info_front_object(self.raw) > 0 {
				let raw = call_info_pop_object(self.raw);
				OBJECT_MAP[object_get_type(raw) as usize](raw)
			} else { None }
		}
	}
	pub fn pop_vec2(&mut self) -> Option<Vec2> {
		unsafe {
			if call_info_front_vec2(self.raw) > 0 {
				Some(LightValue{ value: call_info_pop_vec2(self.raw) }.vec2)
			} else { None }
		}
	}
	pub fn pop_size(&mut self) -> Option<Size> {
		unsafe {
			if call_info_front_size(self.raw) > 0 {
				Some(LightValue{ value: call_info_pop_size(self.raw) }.size)
			} else { None }
		}
	}
}

impl Drop for CallInfo {
	fn drop(&mut self) { unsafe { call_info_release(self.raw); } }
}

#[derive(object_macro)]
pub struct Array { raw: i64 }

impl Array {
	pub fn new() -> Array {
		Array { raw: unsafe { array_create() } }
	}
	pub fn set<'a, T>(&mut self, index: i32, v: T) where T: IntoValue<'a> {
		if unsafe { array_set(self.raw, index, v.dora_val().raw()) == 0 } {
			panic!("Out of bounds, expecting [0, {}), got {}", self.len(), index);
		}
	}
	pub fn get(&self, index: i32) -> Option<DoraValue> {
		DoraValue::from(unsafe { array_get(self.raw, index) })
	}
	pub fn first(&self) -> Option<DoraValue> {
		DoraValue::from(unsafe { array_first(self.raw) })
	}
	pub fn last(&self) -> Option<DoraValue> {
		DoraValue::from(unsafe { array_last(self.raw) })
	}
	pub fn random_object(&self) -> Option<DoraValue> {
		DoraValue::from(unsafe { array_random_object(self.raw) })
	}
	pub fn add<'a, T>(&mut self, v: T) where T: IntoValue<'a> {
		unsafe { array_add(self.raw, v.dora_val().raw()); }
	}
	pub fn insert<'a, T>(&mut self, index: i32, v: T) where T: IntoValue<'a> {
		unsafe { array_insert(self.raw, index, v.dora_val().raw()); }
	}
	pub fn contains<'a, T>(&self, v: T) -> bool where T: IntoValue<'a> {
		unsafe { array_contains(self.raw, v.dora_val().raw()) > 0 }
	}
	pub fn index<'a, T>(&self, v: T) -> i32 where T: IntoValue<'a> {
		unsafe { array_index(self.raw, v.dora_val().raw()) }
	}
	pub fn remove_last(&mut self) -> Option<DoraValue> {
		DoraValue::from(unsafe { array_remove_last(self.raw) })
	}
	pub fn fast_remove<'a, T>(&mut self, v: T) -> bool where T: IntoValue<'a> {
		unsafe { array_fast_remove(self.raw, v.dora_val().raw()) > 0 }
	}
	pub fn len(&self) -> i32 {
		unsafe { array_len(self.raw) }
	}
	pub fn capacity(&self) -> i32 {
		unsafe { array_capacity(self.raw) }
	}
	pub fn is_empty(&self) -> bool {
		unsafe { array_is_empty(self.raw) > 0 }
	}
	pub fn add_range(&mut self, other: &Array) {
		unsafe { array_add_range(self.raw, other.raw); }
	}
	pub fn remove_from(&mut self, other: &Array) {
		unsafe { array_remove_from(self.raw, other.raw); }
	}
	pub fn clear(&mut self) {
		unsafe { array_clear(self.raw); }
	}
	pub fn reverse(&mut self) {
		unsafe { array_reverse(self.raw); }
	}
	pub fn shrink(&mut self) {
		unsafe { array_shrink(self.raw); }
	}
	pub fn swap(&mut self, index_a: i32, index_b: i32) {
		unsafe { array_swap(self.raw, index_a, index_b); }
	}
	pub fn remove_at(&mut self, index: i32) -> bool {
		unsafe { array_remove_at(self.raw, index) > 0 }
	}
	pub fn fast_remove_at(&mut self, index: i32) -> bool {
		unsafe { array_fast_remove_at(self.raw, index) > 0 }
	}
}

#[derive(object_macro)]
pub struct Dictionary { raw: i64 }

impl Dictionary {
	pub fn new() -> Dictionary {
		Dictionary { raw: unsafe { dictionary_create() } }
	}
	pub fn set<'a, T>(&mut self, key: &str, v: T) where T: IntoValue<'a> {
		unsafe { dictionary_set(self.raw, from_string(key), v.dora_val().raw()); }
	}
	pub fn get(&self, key: &str) -> Option<DoraValue> {
		DoraValue::from(unsafe { dictionary_get(self.raw, from_string(key)) })
	}
	pub fn len(&self) -> i32 {
		unsafe { dictionary_len(self.raw) }
	}
	pub fn get_keys(&self) -> Array {
		Array::from(unsafe { dictionary_get_keys(self.raw) }).unwrap()
	}
	pub fn clear(&mut self) {
		unsafe { dictionary_clear(self.raw); }
	}
}

pub trait INode: Object {
	fn set_x(&mut self, var: f32) {
		unsafe { node_set_x(self.raw(), var); }
	}
	fn get_x(&self)-> f32 {
		unsafe { node_get_x(self.raw()) }
	}
	fn set_position(&mut self, var: &Vec2) {
		unsafe { node_set_position(self.raw(), LightValue{ vec2: *var }.value); }
	}
	fn get_position(&self)-> Vec2 {
		unsafe { LightValue{ value: node_get_position(self.raw()) }.vec2 }
	}
	fn set_tag(&mut self, var: &str) {
		unsafe { node_set_tag(self.raw(), from_string(var)); }
	}
	fn get_tag(&self)-> String {
		to_string(unsafe { node_get_tag(self.raw()) })
	}
	fn get_children(&self) -> Option<Array> {
		Array::from(unsafe { node_get_children(self.raw()) } )
	}
	fn get_userdata(&self) -> Dictionary {
		Dictionary::from(unsafe { node_get_userdata(self.raw()) } ).unwrap()
	}
	fn add_child(&mut self, child: &dyn INode) {
		unsafe { node_add_child(self.raw(), child.raw()); }
	}
	fn schedule(&mut self, mut func: Box<dyn FnMut(f64) -> bool>) {
		let mut stack = CallInfo::new();
		let stack_raw = stack.raw();
		let func_id = push_function(Box::new(move || {
			let delta_time = stack.pop_f64().unwrap();
			let result = func(delta_time);
			stack.push_bool(result);
		}));
		unsafe { node_schedule(self.raw(), func_id, stack_raw); }
	}
	fn emit(&mut self, name: &str, stack: &CallInfo) {
		unsafe { node_emit(self.raw(), from_string(name), stack.raw()); }
	}
	fn slot(&mut self, name: &str, mut func: Box<dyn FnMut(&mut CallInfo)>) {
		let mut stack = CallInfo::new();
		let stack_raw = stack.raw();
		let func_id = push_function(Box::new(move || { func(&mut stack); }));
		unsafe { node_slot(self.raw(), from_string(name), func_id, stack_raw); }
	}
}

#[derive(object_macro)]
pub struct Node { raw: i64 }

impl Node {
	pub fn new() -> Node {
		Node { raw: unsafe { node_create() } }
	}
}

impl INode for Node { }

pub struct Director { }

impl Director {
	pub fn get_entry() -> Node {
		Node::from(unsafe { director_get_entry() }).unwrap()
	}
}

fn none_type(_: i64) -> Option<Box<dyn Object>> { None }

pub fn init() {
	unsafe {
		let type_funcs = [
			(node_type(), |raw: i64| -> Option<Box<dyn Object>> {
				match raw { 0 => None, _ => Some(Box::new(Node { raw: raw })), }
			} as fn(i64) -> Option<Box<dyn Object>>),
			(array_type(), |raw: i64| -> Option<Box<dyn Object>> {
				match raw { 0 => None, _ => Some(Box::new(Array { raw: raw })), }
			}),
			(dictionary_type(), |raw: i64| -> Option<Box<dyn Object>> {
				match raw { 0 => None, _ => Some(Box::new(Dictionary { raw: raw })), }
			}),
		];
		for pair in type_funcs.iter() {
			let t = pair.0 as usize;
			if OBJECT_MAP.len() < t + 1 {
				OBJECT_MAP.resize(t + 1, none_type);
				OBJECT_MAP[t] = pair.1;
			}
		}
	}
}
