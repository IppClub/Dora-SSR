/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

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
		public static extern int32_t dictionary_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t dictionary_get_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dictionary_get_keys(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void dictionary_clear(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dictionary_new();
	}
} // namespace Dora

namespace Dora
{
	/// A struct for storing pairs of string keys and various values.
	public partial class Dictionary : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.dictionary_type(), From);
		}
		protected Dictionary(long raw) : base(raw) { }
		internal static new Dictionary From(long raw)
		{
			return new Dictionary(raw);
		}
		internal static new Dictionary? FromOpt(long raw)
		{
			return raw == 0 ? null : new Dictionary(raw);
		}
		/// the number of items in the dictionary.
		public int Count
		{
			get => Native.dictionary_get_count(Raw);
		}
		/// the keys of the items in the dictionary.
		public string[] Keys
		{
			get => Bridge.ToStringArray(Native.dictionary_get_keys(Raw));
		}
		/// Removes all the items from the dictionary.
		public void Clear()
		{
			Native.dictionary_clear(Raw);
		}
		/// Creates instance of the "Dictionary".
		public Dictionary() : this(Native.dictionary_new()) { }
	}
} // namespace Dora
