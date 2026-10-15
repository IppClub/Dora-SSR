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
		public static extern int32_t platformer_decision_tree_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_sel(int64_t nodes);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_seq(int64_t nodes);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_con(int64_t name, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_act(int64_t actionName);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_act_dynamic(int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_accept();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_reject();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_behave(int64_t name, int64_t root);
	}
} // namespace Dora

namespace Dora.Platformer.Decision
{
	/// <summary>
	/// A decision tree framework for creating game AI structures.
	/// </summary>
	public partial class Tree : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.platformer_decision_tree_type(), From);
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
		/// Creates a selector node with the specified child nodes.
		/// A selector node will go through the child nodes until one succeeds.
		/// </summary>
		/// <param name="nodes">An array of `Leaf` nodes.</param>
		public static Platformer.Decision.Tree Sel(IEnumerable<Platformer.Decision.Tree> nodes)
		{
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_sel(Bridge.FromArray(nodes)));
		}
		/// <summary>
		/// Creates a sequence node with the specified child nodes.
		/// A sequence node will go through the child nodes until all nodes succeed.
		/// </summary>
		/// <param name="nodes">An array of `Leaf` nodes.</param>
		public static Platformer.Decision.Tree Seq(IEnumerable<Platformer.Decision.Tree> nodes)
		{
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_seq(Bridge.FromArray(nodes)));
		}
		/// <summary>
		/// Creates a condition node with the specified name and handler function.
		/// </summary>
		/// <param name="name">The name of the condition.</param>
		/// <param name="check">The check function that takes a `Unit` parameter and returns a boolean result.</param>
		public static Platformer.Decision.Tree Con(string name, Func<Platformer.Unit, bool> check)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = check((Platformer.Unit)stack0.PopObject());
				stack0.Push(result);
			});
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_con(Bridge.FromString(name), func_id0, stack_raw0));
		}
		/// <summary>
		/// Creates an action node with the specified action name.
		/// </summary>
		/// <param name="actionName">The name of the action to perform.</param>
		public static Platformer.Decision.Tree Act(string actionName)
		{
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_act(Bridge.FromString(actionName)));
		}
		/// <summary>
		/// Creates an action node with the specified handler function.
		/// </summary>
		/// <param name="handler">The handler function that takes a `Unit` parameter which is the running AI agent and returns an action.</param>
		public static Platformer.Decision.Tree ActDynamic(Func<Platformer.Unit, string> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = handler((Platformer.Unit)stack0.PopObject());
				stack0.Push(result);
			});
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_act_dynamic(func_id0, stack_raw0));
		}
		/// <summary>
		/// Creates a leaf node that represents accepting the current behavior tree.
		/// Always get success result from this node.
		/// </summary>
		public static Platformer.Decision.Tree Accept()
		{
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_accept());
		}
		/// <summary>
		/// Creates a leaf node that represents rejecting the current behavior tree.
		/// Always get failure result from this node.
		/// </summary>
		public static Platformer.Decision.Tree Reject()
		{
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_reject());
		}
		/// <summary>
		/// Creates a leaf node with the specified behavior tree as its root.
		/// It is possible to include a Behavior Tree as a node in a Decision Tree by using the Behave() function. This allows the AI to use a combination of decision-making and behavior execution to achieve its goals.
		/// </summary>
		/// <param name="name">The name of the behavior tree.</param>
		/// <param name="root">The root node of the behavior tree.</param>
		public static Platformer.Decision.Tree Behave(string name, Platformer.Behavior.Tree root)
		{
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_behave(Bridge.FromString(name), root.Raw));
		}
	}
} // namespace Dora.Platformer.Decision
