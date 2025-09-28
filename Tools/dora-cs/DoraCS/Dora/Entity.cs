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
		public static extern int32_t entity_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t entity_get_count();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t entity_get_index(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void entity_clear();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void entity_remove(int64_t self, int64_t key);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void entity_destroy(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t entity_new();
	}
} // namespace Dora

namespace Dora
{
	/// A struct representing an entity for an ECS game system.
	public partial class Entity : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.entity_type(), From);
		}
		protected Entity(long raw) : base(raw) { }
		internal static new Entity From(long raw)
		{
			return new Entity(raw);
		}
		internal static new Entity? FromOpt(long raw)
		{
			return raw == 0 ? null : new Entity(raw);
		}
		/// the number of all running entities.
		public int Count
		{
			get => Native.entity_get_count();
		}
		/// the index of the entity.
		public int Index
		{
			get => Native.entity_get_index(Raw);
		}
		/// Clears all entities.
		public static void Clear()
		{
			Native.entity_clear();
		}
		/// Removes a property of the entity.
		///
		/// This function will trigger events for Observer objects.
		///
		/// # Arguments
		///
		/// * `key` - The name of the property to remove.
		public void Remove(string key)
		{
			Native.entity_remove(Raw, Bridge.FromString(key));
		}
		/// Destroys the entity.
		public void Destroy()
		{
			Native.entity_destroy(Raw);
		}
		/// Creates a new entity.
		public Entity() : this(Native.entity_new()) { }
	}
} // namespace Dora
