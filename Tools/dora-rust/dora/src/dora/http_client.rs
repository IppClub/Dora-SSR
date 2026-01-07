/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn httpclient_post_async(url: i64, json: i64, timeout: f32, func0: i32, stack0: i64);
	fn httpclient_post_with_headers_async(url: i64, headers: i64, json: i64, timeout: f32, func0: i32, stack0: i64);
	fn httpclient_post_with_headers_part_async(url: i64, headers: i64, json: i64, timeout: f32, func0: i32, stack0: i64, func1: i32, stack1: i64);
	fn httpclient_get_async(url: i64, timeout: f32, func0: i32, stack0: i64);
	fn httpclient_download_async(url: i64, full_path: i64, timeout: f32, func0: i32, stack0: i64);
}
/// An HTTP client interface.
pub struct HttpClient { }
impl HttpClient {
	/// Sends a POST request to the specified URL and returns the response body.
	///
	/// # Arguments
	///
	/// * `url` - The URL to send the request to.
	/// * `json` - The JSON data to send in the request body.
	/// * `timeout` - The timeout in seconds for the request.
	/// * `callback` - A callback function that is called when the request is complete. The function receives the response body as a parameter.
	pub fn post_async(url: &str, json: &str, timeout: f32, mut callback: Box<dyn FnMut(Option<String>)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			callback(stack0.pop_str())
		}));
		unsafe { httpclient_post_async(crate::dora::from_string(url), crate::dora::from_string(json), timeout, func_id0, stack_raw0); }
	}
	/// Sends a POST request to the specified URL with custom headers and returns the response body.
	///
	/// # Arguments
	///
	/// * `url` - The URL to send the request to.
	/// * `headers` - A vector of headers to include in the request. Each header should be in the format `key: value`.
	/// * `json` - The JSON data to send in the request body.
	/// * `timeout` - The timeout in seconds for the request.
	/// * `callback` - A callback function that is called when the request is complete. The function receives the response body as a parameter.
	pub fn post_with_headers_async(url: &str, headers: &Vec<&str>, json: &str, timeout: f32, mut callback: Box<dyn FnMut(Option<String>)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			callback(stack0.pop_str())
		}));
		unsafe { httpclient_post_with_headers_async(crate::dora::from_string(url), crate::dora::Vector::from_str(headers), crate::dora::from_string(json), timeout, func_id0, stack_raw0); }
	}
	/// Sends a POST request to the specified URL with custom headers and returns the response body.
	///
	/// # Arguments
	///
	/// * `url` - The URL to send the request to.
	/// * `headers` - A vector of headers to include in the request. Each header should be in the format `key: value`.
	/// * `json` - The JSON data to send in the request body.
	/// * `timeout` - The timeout in seconds for the request.
	/// * `part_callback` - A callback function that is called periodically to get part of the response content. Returns `true` to stop the request.
	/// * `callback` - A callback function that is called when the request is complete. The function receives the response body as a parameter.
	pub fn post_with_headers_part_async(url: &str, headers: &Vec<&str>, json: &str, timeout: f32, mut part_callback: Box<dyn FnMut(&str) -> bool>, mut callback: Box<dyn FnMut(Option<String>)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = part_callback(stack0.pop_str().unwrap().as_str());
			stack0.push_bool(result);
		}));
		let mut stack1 = crate::dora::CallStack::new();
		let stack_raw1 = stack1.raw();
		let func_id1 = crate::dora::push_function(Box::new(move || {
			callback(stack1.pop_str())
		}));
		unsafe { httpclient_post_with_headers_part_async(crate::dora::from_string(url), crate::dora::Vector::from_str(headers), crate::dora::from_string(json), timeout, func_id0, stack_raw0, func_id1, stack_raw1); }
	}
	/// Sends a GET request to the specified URL and returns the response body.
	///
	/// # Arguments
	///
	/// * `url` - The URL to send the request to.
	/// * `timeout` - The timeout in seconds for the request.
	/// * `callback` - A callback function that is called when the request is complete. The function receives the response body as a parameter.
	pub fn get_async(url: &str, timeout: f32, mut callback: Box<dyn FnMut(Option<String>)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			callback(stack0.pop_str())
		}));
		unsafe { httpclient_get_async(crate::dora::from_string(url), timeout, func_id0, stack_raw0); }
	}
	/// Downloads a file asynchronously from the specified URL and saves it to the specified path.
	///
	/// # Arguments
	///
	/// * `url` - The URL of the file to download.
	/// * `full_path` - The full path where the downloaded file should be saved.
	/// * `timeout` - The timeout in seconds for the request.
	/// * `progress` - A callback function that is called periodically to report the download progress.
	///   The function receives three parameters: `interrupted` (a boolean value indicating whether the download was interrupted), `current` (the number of bytes downloaded so far) and `total` (the total number of bytes to be downloaded).
	pub fn download_async(url: &str, full_path: &str, timeout: f32, mut progress: Box<dyn FnMut(bool, i64, i64) -> bool>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = progress(stack0.pop_bool().unwrap(), stack0.pop_i64().unwrap(), stack0.pop_i64().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { httpclient_download_async(crate::dora::from_string(url), crate::dora::from_string(full_path), timeout, func_id0, stack_raw0); }
	}
}