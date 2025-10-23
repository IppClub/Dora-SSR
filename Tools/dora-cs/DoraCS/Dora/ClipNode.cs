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
		public static extern int32_t clipnode_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void clipnode_set_stencil(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t clipnode_get_stencil(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void clipnode_set_alpha_threshold(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float clipnode_get_alpha_threshold(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void clipnode_set_inverted(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t clipnode_is_inverted(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t clipnode_new(int64_t stencil);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A Node that can clip its children based on the alpha values of its stencil.
	/// </summary>
	public partial class ClipNode : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.clipnode_type(), From);
		}
		protected ClipNode(long raw) : base(raw) { }
		internal static new ClipNode From(long raw)
		{
			return new ClipNode(raw);
		}
		internal static new ClipNode? FromOpt(long raw)
		{
			return raw == 0 ? null : new ClipNode(raw);
		}
		/// <summary>
		/// The stencil Node that defines the clipping shape.
		/// </summary>
		public Node Stencil
		{
			set => Native.clipnode_set_stencil(Raw, value.Raw);
			get => Node.From(Native.clipnode_get_stencil(Raw));
		}
		/// <summary>
		/// The minimum alpha threshold for a pixel to be visible. Value ranges from 0 to 1.
		/// </summary>
		public float AlphaThreshold
		{
			set => Native.clipnode_set_alpha_threshold(Raw, value);
			get => Native.clipnode_get_alpha_threshold(Raw);
		}
		/// <summary>
		/// Whether to invert the clipping area.
		/// </summary>
		public bool IsInverted
		{
			set => Native.clipnode_set_inverted(Raw, value ? 1 : 0);
			get => Native.clipnode_is_inverted(Raw) != 0;
		}
		/// <summary>
		/// Creates a new ClipNode object.
		/// </summary>
		/// <param name="stencil">The stencil Node that defines the clipping shape.</param>
		public ClipNode(Node stencil) : this(Native.clipnode_new(stencil.Raw)) { }
	}
} // namespace Dora
