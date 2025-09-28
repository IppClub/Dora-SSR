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
		public static extern int32_t platformer_actionupdate_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_wasmactionupdate_new(int32_t func0, int64_t stack0);
	}
} // namespace Dora

namespace Dora.Platformer
{
	public partial class ActionUpdate : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.platformer_actionupdate_type(), From);
		}
		protected ActionUpdate(long raw) : base(raw) { }
		internal static new ActionUpdate From(long raw)
		{
			return new ActionUpdate(raw);
		}
		internal static new ActionUpdate? FromOpt(long raw)
		{
			return raw == 0 ? null : new ActionUpdate(raw);
		}
		private static long NewActionUpdate(Func<Platformer.Unit, Platformer.UnitAction, float, bool> update)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = update((Platformer.Unit)stack0.PopObject(), Platformer.UnitAction.From(stack0.PopI64()), stack0.PopF32());
				stack0.Push(result);;
			});
			return Native.platformer_wasmactionupdate_new(func_id0, stack_raw0);
		}
		public ActionUpdate(Func<Platformer.Unit, Platformer.UnitAction, float, bool> update) : this(NewActionUpdate(update)) { }
	}
} // namespace Dora.Platformer
