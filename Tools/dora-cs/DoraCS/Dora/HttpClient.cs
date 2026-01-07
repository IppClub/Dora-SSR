/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


using System.Runtime.InteropServices;
using int64_t = long;
using int32_t = int;

namespace Dora
{
	internal static partial class Native
	{
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void httpclient_post_async(int64_t url, int64_t json, float timeout, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void httpclient_post_with_headers_async(int64_t url, int64_t headers, int64_t json, float timeout, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void httpclient_post_with_headers_part_async(int64_t url, int64_t headers, int64_t json, float timeout, int32_t func0, int64_t stack0, int32_t func1, int64_t stack1);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void httpclient_get_async(int64_t url, float timeout, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void httpclient_download_async(int64_t url, int64_t fullPath, float timeout, int32_t func0, int64_t stack0);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// An HTTP client interface.
	/// </summary>
	public static partial class HttpClient
	{
		/// <summary>
		/// Sends a POST request to the specified URL and returns the response body.
		/// </summary>
		/// <param name="url">The URL to send the request to.</param>
		/// <param name="json">The JSON data to send in the request body.</param>
		/// <param name="timeout">The timeout in seconds for the request.</param>
		/// <param name="callback">A callback function that is called when the request is complete. The function receives the response body as a parameter.</param>
		public static void PostAsync(string url, string json, float timeout, System.Action<string?> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(stack0.PopOptString());
			});
			Native.httpclient_post_async(Bridge.FromString(url), Bridge.FromString(json), timeout, func_id0, stack_raw0);
		}
		/// <summary>
		/// Sends a POST request to the specified URL with custom headers and returns the response body.
		/// </summary>
		/// <param name="url">The URL to send the request to.</param>
		/// <param name="headers">A vector of headers to include in the request. Each header should be in the format `key: value`.</param>
		/// <param name="json">The JSON data to send in the request body.</param>
		/// <param name="timeout">The timeout in seconds for the request.</param>
		/// <param name="callback">A callback function that is called when the request is complete. The function receives the response body as a parameter.</param>
		public static void PostAsync(string url, IEnumerable<string> headers, string json, float timeout, System.Action<string?> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(stack0.PopOptString());
			});
			Native.httpclient_post_with_headers_async(Bridge.FromString(url), Bridge.FromArray(headers), Bridge.FromString(json), timeout, func_id0, stack_raw0);
		}
		/// <summary>
		/// Sends a POST request to the specified URL with custom headers and returns the response body.
		/// </summary>
		/// <param name="url">The URL to send the request to.</param>
		/// <param name="headers">A vector of headers to include in the request. Each header should be in the format `key: value`.</param>
		/// <param name="json">The JSON data to send in the request body.</param>
		/// <param name="timeout">The timeout in seconds for the request.</param>
		/// <param name="partCallback">A callback function that is called periodically to get part of the response content. Returns `true` to stop the request.</param>
		/// <param name="callback">A callback function that is called when the request is complete. The function receives the response body as a parameter.</param>
		public static void PostAsync(string url, IEnumerable<string> headers, string json, float timeout, Func<string, bool> partCallback, System.Action<string?> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = partCallback(stack0.PopString());
				stack0.Push(result);
			});
			var stack1 = new CallStack();
			var stack_raw1 = stack1.Raw;
			var func_id1 = Bridge.PushFunction(() =>
			{
				callback(stack1.PopOptString());
			});
			Native.httpclient_post_with_headers_part_async(Bridge.FromString(url), Bridge.FromArray(headers), Bridge.FromString(json), timeout, func_id0, stack_raw0, func_id1, stack_raw1);
		}
		/// <summary>
		/// Sends a GET request to the specified URL and returns the response body.
		/// </summary>
		/// <param name="url">The URL to send the request to.</param>
		/// <param name="timeout">The timeout in seconds for the request.</param>
		/// <param name="callback">A callback function that is called when the request is complete. The function receives the response body as a parameter.</param>
		public static void GetAsync(string url, float timeout, System.Action<string?> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(stack0.PopOptString());
			});
			Native.httpclient_get_async(Bridge.FromString(url), timeout, func_id0, stack_raw0);
		}
		/// <summary>
		/// Downloads a file asynchronously from the specified URL and saves it to the specified path.
		/// </summary>
		/// <param name="url">The URL of the file to download.</param>
		/// <param name="fullPath">The full path where the downloaded file should be saved.</param>
		/// <param name="timeout">The timeout in seconds for the request.</param>
		/// <param name="progress">A callback function that is called periodically to report the download progress.</param>
		public static void DownloadAsync(string url, string fullPath, float timeout, Func<bool, long, long, bool> progress)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = progress(stack0.PopBool(), stack0.PopI64(), stack0.PopI64());
				stack0.Push(result);
			});
			Native.httpclient_download_async(Bridge.FromString(url), Bridge.FromString(fullPath), timeout, func_id0, stack_raw0);
		}
	}
} // namespace Dora
