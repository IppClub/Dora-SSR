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
		public static extern void platformer_unitaction_set_reaction(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_unitaction_get_reaction(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unitaction_set_recovery(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_unitaction_get_recovery(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unitaction_get_name(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_unitaction_is_doing(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unitaction_get_owner(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_unitaction_get_elapsed_time(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unitaction_clear();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unitaction_add(int64_t name, int32_t priority, float reaction, float recovery, int32_t queued, int32_t func0, int64_t stack0, int32_t func1, int64_t stack1, int32_t func2, int64_t stack2);
	}
} // namespace Dora

namespace Dora.Platformer
{
	/// <summary>
	/// A struct that represents an action that can be performed by a "Unit".
	/// </summary>
	public partial class UnitAction
	{
		private UnitAction(long raw)
		{
			if (raw == 0) throw new InvalidOperationException("failed to create UnitAction");
			Raw = raw;
		}
		internal long Raw { get; private set; }
		internal static UnitAction From(long raw)
		{
			return new UnitAction(raw);
		}
		/// <summary>
		/// The length of the reaction time for the "UnitAction", in seconds.
		/// The reaction time will affect the AI check cycling time.
		/// </summary>
		public float Reaction
		{
			set => Native.platformer_unitaction_set_reaction(Raw, value);
			get => Native.platformer_unitaction_get_reaction(Raw);
		}
		/// <summary>
		/// The length of the recovery time for the "UnitAction", in seconds.
		/// The recovery time will mainly affect how long the `Playable` animation model will do transitions between animations played by different actions.
		/// </summary>
		public float Recovery
		{
			set => Native.platformer_unitaction_set_recovery(Raw, value);
			get => Native.platformer_unitaction_get_recovery(Raw);
		}
		/// <summary>
		/// The name of the "UnitAction".
		/// </summary>
		public string Name
		{
			get => Bridge.ToString(Native.platformer_unitaction_get_name(Raw));
		}
		/// <summary>
		/// Whether the "Unit" is currently performing the "UnitAction" or not.
		/// </summary>
		public bool IsDoing
		{
			get => Native.platformer_unitaction_is_doing(Raw) != 0;
		}
		/// <summary>
		/// The "Unit" that owns this "UnitAction".
		/// </summary>
		public Platformer.Unit Owner
		{
			get => Platformer.Unit.From(Native.platformer_unitaction_get_owner(Raw));
		}
		/// <summary>
		/// The elapsed time since the "UnitAction" was started, in seconds.
		/// </summary>
		public float ElapsedTime
		{
			get => Native.platformer_unitaction_get_elapsed_time(Raw);
		}
		/// <summary>
		/// Removes all "UnitAction" objects from the "UnitActionClass".
		/// </summary>
		public static void Clear()
		{
			Native.platformer_unitaction_clear();
		}
		/// <summary>
		/// Adds a new "UnitAction" to the "UnitActionClass" with the specified name and parameters.
		/// </summary>
		/// <param name="name">The name of the "UnitAction".</param>
		/// <param name="priority">The priority level for the "UnitAction". `UnitAction` with higher priority (larger number) will replace the running lower priority `UnitAction`. If performing `UnitAction` having the same priority with the running `UnitAction` and the `UnitAction` to perform having the param 'queued' to be true, the running `UnitAction` won't be replaced.</param>
		/// <param name="reaction">The length of the reaction time for the "UnitAction", in seconds. The reaction time will affect the AI check cycling time. Set to 0.0 to make AI check run in every update.</param>
		/// <param name="recovery">The length of the recovery time for the "UnitAction", in seconds. The recovery time will mainly affect how long the `Playable` animation model will do transitions between animations played by different actions.</param>
		/// <param name="queued">Whether the "UnitAction" is currently queued or not. The queued "UnitAction" won't replace the running "UnitAction" with a same priority.</param>
		/// <param name="available">A function that takes a `Unit` object and a `UnitAction` object and returns a boolean value indicating whether the "UnitAction" is available to be performed.</param>
		/// <param name="create">A function that takes a `Unit` object and a `UnitAction` object and returns a `WasmActionUpdate` object that contains the update function for the "UnitAction".</param>
		/// <param name="stop">A function that takes a `Unit` object and a `UnitAction` object and stops the "UnitAction".</param>
		public static void Add(string name, int priority, float reaction, float recovery, bool queued, Func<Platformer.Unit, Platformer.UnitAction, bool> available, Func<Platformer.Unit, Platformer.UnitAction, Platformer.ActionUpdate> create, System.Action<Platformer.Unit, Platformer.UnitAction> stop)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = available((Platformer.Unit)stack0.PopObject(), Platformer.UnitAction.From(stack0.PopI64()));
				stack0.Push(result);
			});
			var stack1 = new CallStack();
			var stack_raw1 = stack1.Raw;
			var func_id1 = Bridge.PushFunction(() =>
			{
				var result = create((Platformer.Unit)stack1.PopObject(), Platformer.UnitAction.From(stack1.PopI64()));
				stack1.Push(result);
			});
			var stack2 = new CallStack();
			var stack_raw2 = stack2.Raw;
			var func_id2 = Bridge.PushFunction(() =>
			{
				stop((Platformer.Unit)stack2.PopObject(), Platformer.UnitAction.From(stack2.PopI64()));
			});
			Native.platformer_unitaction_add(Bridge.FromString(name), priority, reaction, recovery, queued ? 1 : 0, func_id0, stack_raw0, func_id1, stack_raw1, func_id2, stack_raw2);
		}
	}
} // namespace Dora.Platformer
