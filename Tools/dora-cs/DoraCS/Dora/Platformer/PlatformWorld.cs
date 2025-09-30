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
		public static extern int32_t platformer_platformworld_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformworld_get_camera(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformworld_move_child(int64_t self, int64_t child, int32_t newOrder);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformworld_get_layer(int64_t self, int32_t order);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformworld_set_layer_ratio(int64_t self, int32_t order, int64_t ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformworld_get_layer_ratio(int64_t self, int32_t order);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformworld_set_layer_offset(int64_t self, int32_t order, int64_t offset);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformworld_get_layer_offset(int64_t self, int32_t order);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformworld_swap_layer(int64_t self, int32_t orderA, int32_t orderB);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformworld_remove_layer(int64_t self, int32_t order);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformworld_remove_all_layers(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformworld_new();
	}
} // namespace Dora

namespace Dora.Platformer
{
	/// <summary>
	/// A struct representing a 2D platformer game world with physics simulations.
	/// </summary>
	public partial class PlatformWorld : PhysicsWorld
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.platformer_platformworld_type(), From);
		}
		protected PlatformWorld(long raw) : base(raw) { }
		internal static new PlatformWorld From(long raw)
		{
			return new PlatformWorld(raw);
		}
		internal static new PlatformWorld? FromOpt(long raw)
		{
			return raw == 0 ? null : new PlatformWorld(raw);
		}
		/// <summary>
		/// The camera used to control the view of the game world.
		/// </summary>
		public Platformer.PlatformCamera Camera
		{
			get => Platformer.PlatformCamera.From(Native.platformer_platformworld_get_camera(Raw));
		}
		/// <summary>
		/// Moves a child node to a new order for a different layer.
		/// </summary>
		/// <param name="child">The child node to be moved.</param>
		/// <param name="new_order">The new order of the child node.</param>
		public void MoveChild(Node child, int newOrder)
		{
			Native.platformer_platformworld_move_child(Raw, child.Raw, newOrder);
		}
		/// <summary>
		/// Gets the layer node at a given order.
		/// </summary>
		/// <param name="order">The order of the layer node to get.</param>
		public Node GetLayer(int order)
		{
			return Node.From(Native.platformer_platformworld_get_layer(Raw, order));
		}
		/// <summary>
		/// Sets the parallax moving ratio for a given layer to simulate 3D projection effect.
		/// </summary>
		/// <param name="order">The order of the layer to set the ratio for.</param>
		/// <param name="ratio">The new parallax ratio for the layer.</param>
		public void SetLayerRatio(int order, Vec2 ratio)
		{
			Native.platformer_platformworld_set_layer_ratio(Raw, order, ratio.Raw);
		}
		/// <summary>
		/// Gets the parallax moving ratio for a given layer.
		/// </summary>
		/// <param name="order">The order of the layer to get the ratio for.</param>
		public Vec2 GetLayerRatio(int order)
		{
			return Vec2.From(Native.platformer_platformworld_get_layer_ratio(Raw, order));
		}
		/// <summary>
		/// Sets the position offset for a given layer.
		/// </summary>
		/// <param name="order">The order of the layer to set the offset for.</param>
		/// <param name="offset">A `Vec2` representing the new position offset for the layer.</param>
		public void SetLayerOffset(int order, Vec2 offset)
		{
			Native.platformer_platformworld_set_layer_offset(Raw, order, offset.Raw);
		}
		/// <summary>
		/// Gets the position offset for a given layer.
		/// </summary>
		/// <param name="order">The order of the layer to get the offset for.</param>
		public Vec2 GetLayerOffset(int order)
		{
			return Vec2.From(Native.platformer_platformworld_get_layer_offset(Raw, order));
		}
		/// <summary>
		/// Swaps the positions of two layers.
		/// </summary>
		/// <param name="orderA">The order of the first layer to swap.</param>
		/// <param name="orderB">The order of the second layer to swap.</param>
		public void SwapLayer(int orderA, int orderB)
		{
			Native.platformer_platformworld_swap_layer(Raw, orderA, orderB);
		}
		/// <summary>
		/// Removes a layer from the game world.
		/// </summary>
		/// <param name="order">The order of the layer to remove.</param>
		public void RemoveLayer(int order)
		{
			Native.platformer_platformworld_remove_layer(Raw, order);
		}
		/// <summary>
		/// Removes all layers from the game world.
		/// </summary>
		public void RemoveAllLayers()
		{
			Native.platformer_platformworld_remove_all_layers(Raw);
		}
		/// <summary>
		/// The method to create a new instance of `PlatformWorld`.
		/// </summary>
		public PlatformWorld() : this(Native.platformer_platformworld_new()) { }
	}
} // namespace Dora.Platformer
