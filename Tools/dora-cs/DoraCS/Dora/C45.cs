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
		public static extern void c45_build_decision_tree_async(int64_t csvData, int32_t maxDepth, int32_t func0, int64_t stack0);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// An interface for machine learning algorithms.
	/// </summary>
	public static partial class C45
	{
		/// <summary>
		/// A function that takes CSV data as input and applies the C4.5 machine learning algorithm to build a decision tree model asynchronously.
		/// C4.5 is a decision tree algorithm that uses information gain to select the best attribute to split the data at each node of the tree. The resulting decision tree can be used to make predictions on new data.
		/// </summary>
		/// <param name="csvData">The CSV training data for building the decision tree using delimiter `,`.</param>
		/// <param name="maxDepth">The maximum depth of the generated decision tree. Set to 0 to prevent limiting the generated tree depth.</param>
		/// <param name="treeVisitor">The callback function to be called for each node of the generated decision tree.</param>
		public static void BuildDecisionTreeAsync(string csvData, int maxDepth, System.Action<double, string, string, string> treeVisitor)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				treeVisitor(stack0.PopF64(), stack0.PopString(), stack0.PopString(), stack0.PopString());
			});
			Native.c45_build_decision_tree_async(Bridge.FromString(csvData), maxDepth, func_id0, stack_raw0);
		}
	}
} // namespace Dora
