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
		public static extern int32_t array_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t array_get_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t array_is_empty(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void array_add_range(int64_t self, int64_t other);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void array_remove_from(int64_t self, int64_t other);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void array_clear(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void array_reverse(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void array_shrink(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void array_swap(int64_t self, int32_t index_a, int32_t index_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t array_remove_at(int64_t self, int32_t index);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t array_fast_remove_at(int64_t self, int32_t index);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t array_new();
	}
} // namespace Dora

namespace Dora
{
	/// An array data structure that supports various operations.
	public partial class Array : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.array_type(), From);
		}
		protected Array(long raw) : base(raw) { }
		internal static new Array From(long raw)
		{
			return new Array(raw);
		}
		internal static new Array? FromOpt(long raw)
		{
			return raw == 0 ? null : new Array(raw);
		}
		/// the number of items in the array.
		public long Count
		{
			get => Native.array_get_count(Raw);
		}
		/// whether the array is empty or not.
		public bool IsEmpty
		{
			get => Native.array_is_empty(Raw) != 0;
		}
		/// Adds all items from another array to the end of this array.
		///
		/// # Arguments
		///
		/// * `other` - Another array object.
		public void AddRange(Array other)
		{
			Native.array_add_range(Raw, other.Raw);
		}
		/// Removes all items from this array that are also in another array.
		///
		/// # Arguments
		///
		/// * `other` - Another array object.
		public void RemoveFrom(Array other)
		{
			Native.array_remove_from(Raw, other.Raw);
		}
		/// Removes all items from the array.
		public void Clear()
		{
			Native.array_clear(Raw);
		}
		/// Reverses the order of the items in the array.
		public void Reverse()
		{
			Native.array_reverse(Raw);
		}
		/// Removes any empty slots from the end of the array.
		/// This method is used to release the unused memory this array holds.
		public void Shrink()
		{
			Native.array_shrink(Raw);
		}
		/// Swaps the items at two given indices.
		///
		/// # Arguments
		///
		/// * `index_a` - The first index.
		/// * `index_b` - The second index.
		public void Swap(int index_a, int index_b)
		{
			Native.array_swap(Raw, index_a, index_b);
		}
		/// Removes the item at the given index.
		///
		/// # Arguments
		///
		/// * `index` - The index to remove.
		///
		/// # Returns
		///
		/// * `bool` - `true` if an item was removed, `false` otherwise.
		public bool RemoveAt(int index)
		{
			return Native.array_remove_at(Raw, index) != 0;
		}
		/// Removes the item at the given index without preserving the order of the array.
		///
		/// # Arguments
		///
		/// * `index` - The index to remove.
		///
		/// # Returns
		///
		/// * `bool` - `true` if an item was removed, `false` otherwise.
		public bool FastRemoveAt(int index)
		{
			return Native.array_fast_remove_at(Raw, index) != 0;
		}
		/// Creates a new array object
		public Array() : this(Native.array_new()) { }
	}
} // namespace Dora
