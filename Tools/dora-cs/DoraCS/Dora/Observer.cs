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
		public static extern int32_t observer_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t entityobserver_new(int32_t event_, int64_t components);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct representing an observer of entity changes in the game systems.
	/// </summary>
	public partial class Observer : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.observer_type(), From);
		}
		protected Observer(long raw) : base(raw) { }
		internal static new Observer From(long raw)
		{
			return new Observer(raw);
		}
		internal static new Observer? FromOpt(long raw)
		{
			return raw == 0 ? null : new Observer(raw);
		}
		/// <summary>
		/// A method that creates a new observer with the specified component filter and action to watch for.
		/// </summary>
		/// <param name="event_">The type of event to watch for.</param>
		/// <param name="components">A vector listing the names of the components to filter entities by.</param>
		/// <returns>The new observer.</returns>
		public Observer(EntityEvent event_, IEnumerable<string> components) : this(Native.entityobserver_new((int)event_, Bridge.FromArray(components))) { }
	}
} // namespace Dora
