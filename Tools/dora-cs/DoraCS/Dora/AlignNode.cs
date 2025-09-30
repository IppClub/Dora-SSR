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
		public static extern int32_t alignnode_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void alignnode_css(int64_t self, int64_t style);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t alignnode_new(int32_t isWindowRoot);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A node used for aligning layout elements.
	/// </summary>
	public partial class AlignNode : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.alignnode_type(), From);
		}
		protected AlignNode(long raw) : base(raw) { }
		internal static new AlignNode From(long raw)
		{
			return new AlignNode(raw);
		}
		internal static new AlignNode? FromOpt(long raw)
		{
			return raw == 0 ? null : new AlignNode(raw);
		}
		/// <summary>
		/// Sets the layout style of the node.
		/// </summary>
		/// <param name="style">The layout style to set.</param>
		public void Css(string style)
		{
			Native.alignnode_css(Raw, Bridge.FromString(style));
		}
		/// <summary>
		/// Creates a new AlignNode object.
		/// </summary>
		/// <param name="isWindowRoot">Whether the node is a window root node. A window root node will automatically listen for window size change events and update the layout accordingly.</param>
		public AlignNode(bool isWindowRoot) : this(Native.alignnode_new(isWindowRoot ? 1 : 0)) { }
	}
} // namespace Dora
