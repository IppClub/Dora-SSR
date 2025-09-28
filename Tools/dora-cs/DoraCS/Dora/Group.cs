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
		public static extern int32_t group_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t entitygroup_get_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t entitygroup_get_first(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t entitygroup_find(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t entitygroup_new(int64_t components);
	}
} // namespace Dora

namespace Dora
{
	/// A struct representing a group of entities in the ECS game systems.
	public partial class Group : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.group_type(), From);
		}
		protected Group(long raw) : base(raw) { }
		internal static new Group From(long raw)
		{
			return new Group(raw);
		}
		internal static new Group? FromOpt(long raw)
		{
			return raw == 0 ? null : new Group(raw);
		}
		/// the number of entities in the group.
		public int Count
		{
			get => Native.entitygroup_get_count(Raw);
		}
		/// the first entity in the group.
		public Entity? First
		{
			get => Entity.FromOpt(Native.entitygroup_get_first(Raw));
		}
		/// Finds the first entity in the group that satisfies a predicate function.
		///
		/// # Arguments
		///
		/// * `predicate` - The predicate function to test each entity with.
		///
		/// # Returns
		///
		/// * `Option<Entity>` - The first entity that satisfies the predicate, or None if no entity does.
		public Entity? Find(Func<Entity, bool> predicate)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = predicate((Entity)stack0.PopObject());
				stack0.Push(result);;
			});
			return Entity.FromOpt(Native.entitygroup_find(Raw, func_id0, stack_raw0));
		}
		/// A method that creates a new group with the specified component names.
		///
		/// # Arguments
		///
		/// * `components` - A vector listing the names of the components to include in the group.
		///
		/// # Returns
		///
		/// * `Group` - The new group.
		public Group(IEnumerable<string> components) : this(Native.entitygroup_new(Bridge.FromArray(components))) { }
	}
} // namespace Dora
