use std::ffi::c_void;

extern "C" {
	fn object_get_id(obj: i64) -> i32;
	fn object_get_type(obj: i64) -> i32;
	fn object_release(obj: i64);

	fn node_type() -> i32;
	fn node_create()-> i64;
	fn node_set_x(node: i64, var: f32);
	fn node_get_x(node: i64)-> f32;
	fn node_set_tag(node: i64, var: i64);
	fn node_get_tag(node: i64)-> i64;
	fn node_add_child(node: i64, child: i64);
	fn node_schedule(node: i64, func: i32, stack: i64);
	fn node_emit(node: i64, name: i64, stack: i64);
	fn node_slot(node: i64, name: i64, func: i32, stack: i64);

	fn str_new(len: i32)-> i64;
	fn str_len(str: i64)-> i32;
	fn str_read(dest: *mut c_void, src: i64);
	fn str_write(dest: i64, src: *const c_void);
	fn str_release(str: i64);

	fn call_info_create() -> i64;
	fn call_info_release(info: i64);
	fn call_info_push_i32(info: i64, value: i32);
	fn call_info_push_i64(info: i64, value: i64);
	fn call_info_push_f32(info: i64, value: f32);
	fn call_info_push_f64(info: i64, value: f64);
	fn call_info_push_str(info: i64, value: i64);
	fn call_info_push_bool(info: i64, value: i32);
	fn call_info_push_object(info: i64, value: i64);
	fn call_info_pop_i32(info: i64) -> i32;
	fn call_info_pop_i64(info: i64) -> i64;
	fn call_info_pop_f32(info: i64) -> f32;
	fn call_info_pop_f64(info: i64) -> f64;
	fn call_info_pop_str(info: i64) -> i64;
	fn call_info_pop_bool(info: i64) -> i32;
	fn call_info_pop_object(info: i64) -> i64;
	fn call_info_front_i32(info: i64) -> i32;
	fn call_info_front_i64(info: i64) -> i32;
	fn call_info_front_f32(info: i64) -> i32;
	fn call_info_front_f64(info: i64) -> i32;
	fn call_info_front_str(info: i64) -> i32;
	fn call_info_front_bool(info: i64) -> i32;
	fn call_info_front_object(info: i64) -> i32;

	fn director_get_entry() -> i64;
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

	fn get_id(&self) -> i32 {
		unsafe { object_get_id(self.raw()) }
	}
}

pub struct CallInfo {
	raw: i64,
}

pub enum Value<'a> {
	I32(i32),
	I64(i64),
	F32(f32),
	F64(f64),
	Bool(bool),
	Str(&'a str),
	Object(&'a dyn Object),
}

pub trait IntoValue<'a> {
	fn val(self) -> Value<'a>;
}

impl<'a> Value<'a> {
	pub fn new<A>(value: A) -> Value<'a>
		where A: IntoValue<'a>
	{
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
		}
	}
}

impl<'a> IntoValue<'a> for i32 {
	fn val(self) -> Value<'a> {
		Value::I32(self)
	}
}

impl<'a> IntoValue<'a> for i64 {
	fn val(self) -> Value<'a> {
		Value::I64(self)
	}
}

impl<'a> IntoValue<'a> for f32 {
	fn val(self) -> Value<'a> {
		Value::F32(self)
	}
}

impl<'a> IntoValue<'a> for f64 {
	fn val(self) -> Value<'a> {
		Value::F64(self)
	}
}

impl<'a> IntoValue<'a> for bool {
	fn val(self) -> Value<'a> {
		Value::Bool(self)
	}
}

impl<'a> IntoValue<'a> for &'a str {
	fn val(self) -> Value<'a> {
		Value::Str(self)
	}
}

impl<'a> IntoValue<'a> for &'a dyn Object {
	fn val(self) -> Value<'a> {
		Value::Object(self)
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
}

impl Drop for CallInfo {
	fn drop(&mut self) {
		unsafe { call_info_release(self.raw); }
	}
}

pub trait INode {
	fn raw(&self) -> i64;

	fn set_x(&mut self, var: f32) {
		unsafe { node_set_x(self.raw(), var); }
	}

	fn get_x(&self)-> f32 {
		unsafe { node_get_x(self.raw()) }
	}

	fn set_tag(&mut self, var: &str) {
		unsafe { node_set_tag(self.raw(), from_string(var)); }
	}

	fn get_tag(&self)-> String {
		unsafe { to_string(node_get_tag(self.raw())) }
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

pub struct Node {
	raw: i64
}

impl Object for Node {
	fn raw(&self) -> i64 { self.raw }
}

impl Node {
	pub fn new() -> Node {
		Node { raw: unsafe { node_create() } }
	}

	pub fn from(raw: i64) -> Option<Node> {
		match raw {
			0 => None,
			_ => Some(Node { raw: raw })
		}
	}
}

impl INode for Node {
	fn raw(&self) -> i64 { self.raw }
}

impl Drop for Node {
	fn drop(&mut self) {
		unsafe { object_release(self.raw); }
	}
}

pub struct Director {}

impl Director {
	pub fn get_entry() -> Node {
		Node::from(unsafe { director_get_entry() }).unwrap()
	}
}

fn none_type(_: i64) -> Option<Box<dyn Object>> { None }

pub fn init() {
	unsafe {
		let type_funcs = [
			(node_type, |raw: i64| -> Option<Box<dyn Object>> {
				match raw { 0 => None, _ => Some(Box::new(Node { raw: raw })), }
			}),
		];
		for pair in type_funcs.iter() {
			let t = pair.0() as usize;
			if OBJECT_MAP.len() < t + 1 {
				OBJECT_MAP.resize(t + 1, none_type);
				OBJECT_MAP[t] = pair.1;
			}
		}
	}
}
