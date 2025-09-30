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
		public static extern void array_swap(int64_t self, int32_t indexA, int32_t indexB);
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
	/// <summary>
	/// An array data structure that supports various operations.
	/// </summary>
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
		/// <summary>
		/// The number of items in the array.
		/// </summary>
		public long Count
		{
			get => Native.array_get_count(Raw);
		}
		/// <summary>
		/// Whether the array is empty or not.
		/// </summary>
		public bool IsEmpty
		{
			get => Native.array_is_empty(Raw) != 0;
		}
		/// <summary>
		/// Adds all items from another array to the end of this array.
		/// </summary>
		/// <param name="other">Another array object.</param>
		public void AddRange(Array other)
		{
			Native.array_add_range(Raw, other.Raw);
		}
		/// <summary>
		/// Removes all items from this array that are also in another array.
		/// </summary>
		/// <param name="other">Another array object.</param>
		public void RemoveFrom(Array other)
		{
			Native.array_remove_from(Raw, other.Raw);
		}
		/// <summary>
		/// Removes all items from the array.
		/// </summary>
		public void Clear()
		{
			Native.array_clear(Raw);
		}
		/// <summary>
		/// Reverses the order of the items in the array.
		/// </summary>
		public void Reverse()
		{
			Native.array_reverse(Raw);
		}
		/// <summary>
		/// Removes any empty slots from the end of the array.
		/// This method is used to release the unused memory this array holds.
		/// </summary>
		public void Shrink()
		{
			Native.array_shrink(Raw);
		}
		/// <summary>
		/// Swaps the items at two given indices.
		/// </summary>
		/// <param name="indexA">The first index.</param>
		/// <param name="indexB">The second index.</param>
		public void Swap(int indexA, int indexB)
		{
			Native.array_swap(Raw, indexA, indexB);
		}
		/// <summary>
		/// Removes the item at the given index.
		/// </summary>
		/// <param name="index">The index to remove.</param>
		/// <returns>`true` if an item was removed, `false` otherwise.</returns>
		public bool RemoveAt(int index)
		{
			return Native.array_remove_at(Raw, index) != 0;
		}
		/// <summary>
		/// Removes the item at the given index without preserving the order of the array.
		/// </summary>
		/// <param name="index">The index to remove.</param>
		/// <returns>`true` if an item was removed, `false` otherwise.</returns>
		public bool FastRemoveAt(int index)
		{
			return Native.array_fast_remove_at(Raw, index) != 0;
		}
		/// <summary>
		/// Creates a new array object
		/// </summary>
		public Array() : this(Native.array_new()) { }
	}
} // namespace Dora
