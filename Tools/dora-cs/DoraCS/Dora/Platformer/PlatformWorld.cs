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
		public static extern void platformer_platformworld_move_child(int64_t self, int64_t child, int32_t new_order);
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
		public static extern void platformer_platformworld_swap_layer(int64_t self, int32_t order_a, int32_t order_b);
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
	/// A struct representing a 2D platformer game world with physics simulations.
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
		/// the camera used to control the view of the game world.
		public Platformer.PlatformCamera Camera
		{
			get => Platformer.PlatformCamera.From(Native.platformer_platformworld_get_camera(Raw));
		}
		/// Moves a child node to a new order for a different layer.
		///
		/// # Arguments
		///
		/// * `child` - The child node to be moved.
		/// * `new_order` - The new order of the child node.
		public void MoveChild(Node child, int new_order)
		{
			Native.platformer_platformworld_move_child(Raw, child.Raw, new_order);
		}
		/// Gets the layer node at a given order.
		///
		/// # Arguments
		///
		/// * `order` - The order of the layer node to get.
		///
		/// # Returns
		///
		/// * The layer node at the given order.
		public Node GetLayer(int order)
		{
			return Node.From(Native.platformer_platformworld_get_layer(Raw, order));
		}
		/// Sets the parallax moving ratio for a given layer to simulate 3D projection effect.
		///
		/// # Arguments
		///
		/// * `order` - The order of the layer to set the ratio for.
		/// * `ratio` - The new parallax ratio for the layer.
		public void SetLayerRatio(int order, Vec2 ratio)
		{
			Native.platformer_platformworld_set_layer_ratio(Raw, order, ratio.Raw);
		}
		/// Gets the parallax moving ratio for a given layer.
		///
		/// # Arguments
		///
		/// * `order` - The order of the layer to get the ratio for.
		///
		/// # Returns
		///
		/// * A `Vec2` representing the parallax ratio for the layer.
		public Vec2 GetLayerRatio(int order)
		{
			return Vec2.From(Native.platformer_platformworld_get_layer_ratio(Raw, order));
		}
		/// Sets the position offset for a given layer.
		///
		/// # Arguments
		///
		/// * `order` - The order of the layer to set the offset for.
		/// * `offset` - A `Vec2` representing the new position offset for the layer.
		public void SetLayerOffset(int order, Vec2 offset)
		{
			Native.platformer_platformworld_set_layer_offset(Raw, order, offset.Raw);
		}
		/// Gets the position offset for a given layer.
		///
		/// # Arguments
		///
		/// * `order` - The order of the layer to get the offset for.
		///
		/// # Returns
		///
		/// * A `Vec2` representing the position offset for the layer.
		public Vec2 GetLayerOffset(int order)
		{
			return Vec2.From(Native.platformer_platformworld_get_layer_offset(Raw, order));
		}
		/// Swaps the positions of two layers.
		///
		/// # Arguments
		///
		/// * `order_a` - The order of the first layer to swap.
		/// * `order_b` - The order of the second layer to swap.
		public void SwapLayer(int order_a, int order_b)
		{
			Native.platformer_platformworld_swap_layer(Raw, order_a, order_b);
		}
		/// Removes a layer from the game world.
		///
		/// # Arguments
		///
		/// * `order` - The order of the layer to remove.
		public void RemoveLayer(int order)
		{
			Native.platformer_platformworld_remove_layer(Raw, order);
		}
		/// Removes all layers from the game world.
		public void RemoveAllLayers()
		{
			Native.platformer_platformworld_remove_all_layers(Raw);
		}
		/// The method to create a new instance of `PlatformWorld`.
		///
		/// # Returns
		///
		/// * A new instance of `PlatformWorld`.
		public PlatformWorld() : this(Native.platformer_platformworld_new()) { }
	}
} // namespace Dora.Platformer
