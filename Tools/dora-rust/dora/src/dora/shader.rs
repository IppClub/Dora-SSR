/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn shadercompiler_compile(source_file: i64, target_file: i64, stage: i32) -> i64;
	fn shadercompiler_compile_async(source_file: i64, target_file: i64, stage: i32, func0: i32, stack0: i64);
}
/// A singleton interface for compiling shader source files into binary shader files.
pub struct Shader { }
impl Shader {
	/// Compiles a shader source file and writes the compiled bytecode to the target file.
	///
	/// # Arguments
	///
	/// * `source_file` - The shader source file path.
	/// * `target_file` - The output file path for the compiled shader bytecode.
	/// * `stage` - The shader stage.
	///
	/// # Returns
	///
	/// * `string` - An empty string on success, or an error message on failure.
	pub fn compile(source_file: &str, target_file: &str, stage: crate::dora::ShaderStage) -> String {
		unsafe { return crate::dora::to_string(shadercompiler_compile(crate::dora::from_string(source_file), crate::dora::from_string(target_file), stage as i32)); }
	}
	/// Compiles a shader source file asynchronously and writes the compiled bytecode to the target file.
	///
	/// # Arguments
	///
	/// * `source_file` - The shader source file path.
	/// * `target_file` - The output file path for the compiled shader bytecode.
	/// * `stage` - The shader stage.
	/// * `callback` - A callback function invoked when the compilation finishes. It receives an empty string on success, or an error message on failure.
	pub fn compile_async(source_file: &str, target_file: &str, stage: crate::dora::ShaderStage, mut callback: Box<dyn FnMut(&str)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			callback(stack0.pop_str().unwrap().as_str())
		}));
		unsafe { shadercompiler_compile_async(crate::dora::from_string(source_file), crate::dora::from_string(target_file), stage as i32, func_id0, stack_raw0); }
	}
}