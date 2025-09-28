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
		public static extern int32_t qlearner_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void mlqlearner_update(int64_t self, int64_t state, int32_t action, double reward);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t mlqlearner_get_best_action(int64_t self, int64_t state);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void mlqlearner_visit_matrix(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t mlqlearner_pack(int64_t hints, int64_t values);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t mlqlearner_unpack(int64_t hints, int64_t state);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t mlqlearner_new(double gamma, double alpha, double max_q);
	}
} // namespace Dora

namespace Dora
{
	/// A simple reinforcement learning framework that can be used to learn optimal policies for Markov decision processes using Q-learning. Q-learning is a model-free reinforcement learning algorithm that learns an optimal action-value function from experience by repeatedly updating estimates of the Q-value of state-action pairs.
	public partial class QLearner : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.node_type(), From);
		}
		protected QLearner(long raw) : base(raw) { }
		internal static new QLearner From(long raw)
		{
			return new QLearner(raw);
		}
		internal static new QLearner? FromOpt(long raw)
		{
			return raw == 0 ? null : new QLearner(raw);
		}
		/// Updates Q-value for a state-action pair based on received reward.
		///
		/// # Arguments
		///
		/// * `state` - An integer representing the state.
		/// * `action` - An integer representing the action.
		/// * `reward` - A number representing the reward received for the action in the state.
		public void Update(long state, int action, double reward)
		{
			Native.mlqlearner_update(Raw, state, action, reward);
		}
		/// Returns the best action for a given state based on the current Q-values.
		///
		/// # Arguments
		///
		/// * `state` - The current state.
		///
		/// # Returns
		///
		/// * `i32` - The action with the highest Q-value for the given state.
		public int GetBestAction(long state)
		{
			return Native.mlqlearner_get_best_action(Raw, state);
		}
		/// Visits all state-action pairs and calls the provided handler function for each pair.
		///
		/// # Arguments
		///
		/// * `handler` - A function that is called for each state-action pair.
		public void VisitMatrix(Action<long, int, double> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				handler(stack0.PopI64(), stack0.PopI32(), stack0.PopF64());
			});
			Native.mlqlearner_visit_matrix(Raw, func_id0, stack_raw0);
		}
		/// Constructs a state from given hints and condition values.
		///
		/// # Arguments
		///
		/// * `hints` - A vector of integers representing the byte length of provided values.
		/// * `values` - The condition values as discrete values.
		///
		/// # Returns
		///
		/// * `i64` - The packed state value.
		public static long Pack(IEnumerable<int> hints, IEnumerable<int> values)
		{
			return Native.mlqlearner_pack(Bridge.FromArray(hints), Bridge.FromArray(values));
		}
		/// Deconstructs a state from given hints to get condition values.
		///
		/// # Arguments
		///
		/// * `hints` - A vector of integers representing the byte length of provided values.
		/// * `state` - The state integer to unpack.
		///
		/// # Returns
		///
		/// * `Vec<i32>` - The condition values as discrete values.
		public static int[] Unpack(IEnumerable<int> hints, long state)
		{
			return Bridge.ToI32Array(Native.mlqlearner_unpack(Bridge.FromArray(hints), state));
		}
		/// Creates a new QLearner object with optional parameters for gamma, alpha, and maxQ.
		///
		/// # Arguments
		///
		/// * `gamma` - The discount factor for future rewards.
		/// * `alpha` - The learning rate for updating Q-values.
		/// * `maxQ` - The maximum Q-value. Defaults to 100.0.
		///
		/// # Returns
		///
		/// * `QLearner` - The newly created QLearner object.
		public QLearner(double gamma, double alpha, double max_q) : this(Native.mlqlearner_new(gamma, alpha, max_q)) { }
	}
} // namespace Dora
