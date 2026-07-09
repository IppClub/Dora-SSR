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
		public static extern int32_t node3d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node3d_set_visible(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node3d_is_visible(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node3d_get_parent(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node3d_add_child(int64_t self, int64_t child);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node3d_remove_child(int64_t self, int64_t child, int32_t cleanup);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node3d_remove_all_children(int64_t self, int32_t cleanup);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node3d_remove_from_parent(int64_t self, int32_t cleanup);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node3d_cleanup(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node3d_set_position(int64_t self, float x, float y, float z);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node3d_set_scale(int64_t self, float x, float y, float z);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node3d_set_euler_angles(int64_t self, float x, float y, float z);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node3d_new();
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A 3D scene node with transform and hierarchy support.
	/// </summary>
	public partial class Node3D : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.node3d_type(), From);
		}
		protected Node3D(long raw) : base(raw) { }
		internal static new Node3D From(long raw)
		{
			return new Node3D(raw);
		}
		internal static new Node3D? FromOpt(long raw)
		{
			return raw == 0 ? null : new Node3D(raw);
		}
		/// <summary>
		/// Whether the node is visible.
		/// </summary>
		public bool IsVisible
		{
			set => Native.node3d_set_visible(Raw, value ? 1 : 0);
			get => Native.node3d_is_visible(Raw) != 0;
		}
		/// <summary>
		/// The parent 3D node.
		/// </summary>
		public Node3D? Parent
		{
			get => Node3D.FromOpt(Native.node3d_get_parent(Raw));
		}
		/// <summary>
		/// Adds a child node to this node.
		/// </summary>
		public void AddChild(Node3D child)
		{
			Native.node3d_add_child(Raw, child.Raw);
		}
		/// <summary>
		/// Removes a child node from this node.
		/// </summary>
		public void RemoveChild(Node3D child, bool cleanup = true)
		{
			Native.node3d_remove_child(Raw, child.Raw, cleanup ? 1 : 0);
		}
		/// <summary>
		/// Removes all child nodes from this node.
		/// </summary>
		public void RemoveAllChildren(bool cleanup = true)
		{
			Native.node3d_remove_all_children(Raw, cleanup ? 1 : 0);
		}
		/// <summary>
		/// Removes this node from its parent.
		/// </summary>
		public void RemoveFromParent(bool cleanup = true)
		{
			Native.node3d_remove_from_parent(Raw, cleanup ? 1 : 0);
		}
		/// <summary>
		/// Cleans up this node and its children.
		/// </summary>
		public void Cleanup()
		{
			Native.node3d_cleanup(Raw);
		}
		/// <summary>
		/// Sets the node position in 3D space.
		/// </summary>
		public void SetPosition(float x, float y, float z)
		{
			Native.node3d_set_position(Raw, x, y, z);
		}
		/// <summary>
		/// Sets the node scale in 3D space.
		/// </summary>
		public void SetScale(float x, float y, float z)
		{
			Native.node3d_set_scale(Raw, x, y, z);
		}
		/// <summary>
		/// Sets the node Euler angles in degrees.
		/// </summary>
		public void SetEulerAngles(float x, float y, float z)
		{
			Native.node3d_set_euler_angles(Raw, x, y, z);
		}
		/// <summary>
		/// Creates a new 3D node.
		/// </summary>
		public Node3D() : this(Native.node3d_new()) { }
	}
} // namespace Dora
