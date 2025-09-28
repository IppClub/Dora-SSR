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
		public static extern int32_t platformer_decision_tree_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_sel(int64_t nodes);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_seq(int64_t nodes);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_con(int64_t name, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_decision_leaf_act(int64_t action_name);
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
	/// A decision tree framework for creating game AI structures.
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
		/// Creates a selector node with the specified child nodes.
		///
		/// A selector node will go through the child nodes until one succeeds.
		///
		/// # Arguments
		///
		/// * `nodes` - An array of `Leaf` nodes.
		///
		/// # Returns
		///
		/// * A `Leaf` node that represents a selector.
		public static Platformer.Decision.Tree Sel(IEnumerable<Platformer.Decision.Tree> nodes)
		{
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_sel(Bridge.FromArray(nodes)));
		}
		/// Creates a sequence node with the specified child nodes.
		///
		/// A sequence node will go through the child nodes until all nodes succeed.
		///
		/// # Arguments
		///
		/// * `nodes` - An array of `Leaf` nodes.
		///
		/// # Returns
		///
		/// * A `Leaf` node that represents a sequence.
		public static Platformer.Decision.Tree Seq(IEnumerable<Platformer.Decision.Tree> nodes)
		{
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_seq(Bridge.FromArray(nodes)));
		}
		/// Creates a condition node with the specified name and handler function.
		///
		/// # Arguments
		///
		/// * `name` - The name of the condition.
		/// * `check` - The check function that takes a `Unit` parameter and returns a boolean result.
		///
		/// # Returns
		///
		/// * A `Leaf` node that represents a condition check.
		public static Platformer.Decision.Tree Con(string name, Func<Platformer.Unit, bool> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = handler((Platformer.Unit)stack0.PopObject());
				stack0.Push(result);;
			});
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_con(Bridge.FromString(name), func_id0, stack_raw0));
		}
		/// Creates an action node with the specified action name.
		///
		/// # Arguments
		///
		/// * `action_name` - The name of the action to perform.
		///
		/// # Returns
		///
		/// * A `Leaf` node that represents an action.
		public static Platformer.Decision.Tree Act(string action_name)
		{
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_act(Bridge.FromString(action_name)));
		}
		/// Creates an action node with the specified handler function.
		///
		/// # Arguments
		///
		/// * `handler` - The handler function that takes a `Unit` parameter which is the running AI agent and returns an action.
		///
		/// # Returns
		///
		/// * A `Leaf` node that represents an action.
		public static Platformer.Decision.Tree ActDynamic(Func<Platformer.Unit, string> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = handler((Platformer.Unit)stack0.PopObject());
				stack0.Push(result);;
			});
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_act_dynamic(func_id0, stack_raw0));
		}
		/// Creates a leaf node that represents accepting the current behavior tree.
		///
		/// Always get success result from this node.
		///
		/// # Returns
		///
		/// * A `Leaf` node.
		public static Platformer.Decision.Tree Accept()
		{
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_accept());
		}
		/// Creates a leaf node that represents rejecting the current behavior tree.
		///
		/// Always get failure result from this node.
		///
		/// # Returns
		///
		/// * A `Leaf` node.
		public static Platformer.Decision.Tree Reject()
		{
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_reject());
		}
		/// Creates a leaf node with the specified behavior tree as its root.
		///
		/// It is possible to include a Behavior Tree as a node in a Decision Tree by using the Behave() function. This allows the AI to use a combination of decision-making and behavior execution to achieve its goals.
		///
		/// # Arguments
		///
		/// * `name` - The name of the behavior tree.
		/// * `root` - The root node of the behavior tree.
		///
		/// # Returns
		///
		/// * A `Leaf` node.
		public static Platformer.Decision.Tree Behave(string name, Platformer.Behavior.Tree root)
		{
			return Platformer.Decision.Tree.From(Native.platformer_decision_leaf_behave(Bridge.FromString(name), root.Raw));
		}
	}
} // namespace Dora.Platformer.Decision
