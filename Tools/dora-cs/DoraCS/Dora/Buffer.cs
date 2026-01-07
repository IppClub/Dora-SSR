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
		public static extern int32_t buffer_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void buffer_set_text(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t buffer_get_text(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void buffer_resize(int64_t self, int32_t size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void buffer_zero_memory(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t buffer_get_size(int64_t self);
	}
} // namespace Dora

namespace Dora
{
	public partial class Buffer : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.buffer_type(), From);
		}
		protected Buffer(long raw) : base(raw) { }
		internal static new Buffer From(long raw)
		{
			return new Buffer(raw);
		}
		internal static new Buffer? FromOpt(long raw)
		{
			return raw == 0 ? null : new Buffer(raw);
		}

		public string Text
		{
			set => Native.buffer_set_text(Raw, Bridge.FromString(value));
			get => Bridge.ToString(Native.buffer_get_text(Raw));
		}
		public void Resize(int size)
		{
			Native.buffer_resize(Raw, size);
		}
		public void ZeroMemory()
		{
			Native.buffer_zero_memory(Raw);
		}
		public int GetSize()
		{
			return Native.buffer_get_size(Raw);
		}
	}
} // namespace Dora
