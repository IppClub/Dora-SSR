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
		public static extern int32_t platformer_behavior_tree_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_seq(int64_t nodes);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_sel(int64_t nodes);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_con(int64_t name, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_act(int64_t actionName);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_command(int64_t actionName);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_wait(double duration);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_countdown(double time, int64_t node);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_timeout(double time, int64_t node);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_repeat(int32_t times, int64_t node);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_repeat_forever(int64_t node);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_retry(int32_t times, int64_t node);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_behavior_leaf_retry_until_pass(int64_t node);
	}
} // namespace Dora

namespace Dora.Platformer.Behavior
{
	/// <summary>
	/// A behavior tree framework for creating game AI structures.
	/// </summary>
	public partial class Tree : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.platformer_behavior_tree_type(), From);
		}
		protected Tree(long raw) : base(raw) { }
		internal static new Tree From(long raw)
		{
			return new Tree(raw);
		}
		internal static new Tree? FromOpt(long raw)
		{
			return raw == 0 ? null : new Tree(raw);
		}
		/// <summary>
		/// Creates a new sequence node that executes an array of child nodes in order.
		/// </summary>
		/// <param name="nodes">A vector of child nodes.</param>
		/// <returns>A new sequence node.</returns>
		public static Platformer.Behavior.Tree Seq(IEnumerable<Platformer.Behavior.Tree> nodes)
		{
			return Platformer.Behavior.Tree.From(Native.platformer_behavior_leaf_seq(Bridge.FromArray(nodes)));
		}
		/// <summary>
		/// Creates a new selector node that selects and executes one of its child nodes that will succeed.
		/// </summary>
		/// <param name="nodes">A vector of child nodes.</param>
		/// <returns>A new selector node.</returns>
		public static Platformer.Behavior.Tree Sel(IEnumerable<Platformer.Behavior.Tree> nodes)
		{
			return Platformer.Behavior.Tree.From(Native.platformer_behavior_leaf_sel(Bridge.FromArray(nodes)));
		}
		/// <summary>
		/// Creates a new condition node that executes a check handler function when executed.
		/// </summary>
		/// <param name="name">The name of the condition.</param>
		/// <param name="check">A function that takes a blackboard object and returns a boolean value.</param>
		/// <returns>A new condition node.</returns>
		public static Platformer.Behavior.Tree Con(string name, Func<Platformer.Behavior.Blackboard, bool> check)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = check(Platformer.Behavior.Blackboard.From(stack0.PopI64()));
				stack0.Push(result);
			});
			return Platformer.Behavior.Tree.From(Native.platformer_behavior_leaf_con(Bridge.FromString(name), func_id0, stack_raw0));
		}
		/// <summary>
		/// Creates a new action node that executes an action when executed.
		/// This node will block the execution until the action finishes.
		/// </summary>
		/// <param name="actionName">The name of the action to execute.</param>
		/// <returns>A new action node.</returns>
		public static Platformer.Behavior.Tree Act(string actionName)
		{
			return Platformer.Behavior.Tree.From(Native.platformer_behavior_leaf_act(Bridge.FromString(actionName)));
		}
		/// <summary>
		/// Creates a new command node that executes a command when executed.
		/// This node will return right after the action starts.
		/// </summary>
		/// <param name="actionName">The name of the command to execute.</param>
		/// <returns>A new command node.</returns>
		public static Platformer.Behavior.Tree Command(string actionName)
		{
			return Platformer.Behavior.Tree.From(Native.platformer_behavior_leaf_command(Bridge.FromString(actionName)));
		}
		/// <summary>
		/// Creates a new wait node that waits for a specified duration when executed.
		/// </summary>
		/// <param name="duration">The duration to wait in seconds.</param>
		public static Platformer.Behavior.Tree Wait(double duration)
		{
			return Platformer.Behavior.Tree.From(Native.platformer_behavior_leaf_wait(duration));
		}
		/// <summary>
		/// Creates a new countdown node that executes a child node continuously until a timer runs out.
		/// </summary>
		/// <param name="time">The time limit in seconds.</param>
		/// <param name="node">The child node to execute.</param>
		public static Platformer.Behavior.Tree Countdown(double time, Platformer.Behavior.Tree node)
		{
			return Platformer.Behavior.Tree.From(Native.platformer_behavior_leaf_countdown(time, node.Raw));
		}
		/// <summary>
		/// Creates a new timeout node that executes a child node until a timer runs out.
		/// </summary>
		/// <param name="time">The time limit in seconds.</param>
		/// <param name="node">The child node to execute.</param>
		public static Platformer.Behavior.Tree Timeout(double time, Platformer.Behavior.Tree node)
		{
			return Platformer.Behavior.Tree.From(Native.platformer_behavior_leaf_timeout(time, node.Raw));
		}
		/// <summary>
		/// Creates a new repeat node that executes a child node a specified number of times.
		/// </summary>
		/// <param name="times">The number of times to execute the child node.</param>
		/// <param name="node">The child node to execute.</param>
		public static Platformer.Behavior.Tree Repeat(int times, Platformer.Behavior.Tree node)
		{
			return Platformer.Behavior.Tree.From(Native.platformer_behavior_leaf_repeat(times, node.Raw));
		}
		/// <summary>
		/// Creates a new repeat node that executes a child node repeatedly.
		/// </summary>
		/// <param name="node">The child node to execute.</param>
		public static Platformer.Behavior.Tree RepeatForever(Platformer.Behavior.Tree node)
		{
			return Platformer.Behavior.Tree.From(Native.platformer_behavior_leaf_repeat_forever(node.Raw));
		}
		/// <summary>
		/// Creates a new retry node that executes a child node repeatedly until it succeeds or a maximum number of retries is reached.
		/// </summary>
		/// <param name="times">The maximum number of retries.</param>
		/// <param name="node">The child node to execute.</param>
		public static Platformer.Behavior.Tree Retry(int times, Platformer.Behavior.Tree node)
		{
			return Platformer.Behavior.Tree.From(Native.platformer_behavior_leaf_retry(times, node.Raw));
		}
		/// <summary>
		/// Creates a new retry node that executes a child node repeatedly until it succeeds.
		/// </summary>
		/// <param name="node">The child node to execute.</param>
		public static Platformer.Behavior.Tree RetryUntilPass(Platformer.Behavior.Tree node)
		{
			return Platformer.Behavior.Tree.From(Native.platformer_behavior_leaf_retry_until_pass(node.Raw));
		}
	}
} // namespace Dora.Platformer.Behavior
