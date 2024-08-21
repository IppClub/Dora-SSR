/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn httpclient_post_async(url: i64, json: i64, timeout: f32, func: i32, stack: i64);
	fn httpclient_get_async(url: i64, timeout: f32, func: i32, stack: i64);
	fn httpclient_download_async(url: i64, full_path: i64, func: i32, stack: i64);
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
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			callback(stack.pop_str())
		}));
		unsafe { httpclient_post_async(crate::dora::from_string(url), crate::dora::from_string(json), timeout, func_id, stack_raw); }
	}
	/// Sends a GET request to the specified URL and returns the response body.
	///
	/// # Arguments
	///
	/// * `url` - The URL to send the request to.
	/// * `timeout` - The timeout in seconds for the request.
	/// * `callback` - A callback function that is called when the request is complete. The function receives the response body as a parameter.
	pub fn get_async(url: &str, timeout: f32, mut callback: Box<dyn FnMut(Option<String>)>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			callback(stack.pop_str())
		}));
		unsafe { httpclient_get_async(crate::dora::from_string(url), timeout, func_id, stack_raw); }
	}
	/// Downloads a file asynchronously from the specified URL and saves it to the specified path.
	///
	/// # Arguments
	///
	/// * `url` - The URL of the file to download.
	/// * `full_path` - The full path where the downloaded file should be saved.
	/// * `progress` - A callback function that is called periodically to report the download progress.
	///   The function receives three parameters: `interrupted` (a boolean value indicating whether the download was interrupted), `current` (the number of bytes downloaded so far) and `total` (the total number of bytes to be downloaded).
	pub fn download_async(url: &str, full_path: &str, mut progress: Box<dyn FnMut(bool, i64, i64) -> bool>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = progress(stack.pop_bool().unwrap(), stack.pop_i64().unwrap(), stack.pop_i64().unwrap());
			stack.push_bool(result);
		}));
		unsafe { httpclient_download_async(crate::dora::from_string(url), crate::dora::from_string(full_path), func_id, stack_raw); }
	}
}