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
		public static extern int32_t physicsworld_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t physicsworld_query(int64_t self, int64_t rect, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t physicsworld_raycast(int64_t self, int64_t start, int64_t stop, int32_t closest, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void physicsworld_set_iterations(int64_t self, int32_t velocityIter, int32_t positionIter);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void physicsworld_set_should_contact(int64_t self, int32_t groupA, int32_t groupB, int32_t contact);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t physicsworld_get_should_contact(int64_t self, int32_t groupA, int32_t groupB);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void physicsworld_set_scale_factor(float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float physicsworld_get_scale_factor();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsworld_new();
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct that represents a physics world in the game.
	/// </summary>
	public partial class PhysicsWorld : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.physicsworld_type(), From);
		}
		protected PhysicsWorld(long raw) : base(raw) { }
		internal static new PhysicsWorld From(long raw)
		{
			return new PhysicsWorld(raw);
		}
		internal static new PhysicsWorld? FromOpt(long raw)
		{
			return raw == 0 ? null : new PhysicsWorld(raw);
		}
		/// <summary>
		/// Queries the physics world for all bodies that intersect with the specified rectangle.
		/// </summary>
		/// <param name="rect">The rectangle to query for bodies.</param>
		/// <param name="handler">A function that is called for each body found in the query. The function takes a `Body` as an argument and returns a `bool` indicating whether to continue querying for more bodies. Return `false` to continue, `true` to stop.</param>
		/// <returns>Whether the query was interrupted. `true` means interrupted, `false` otherwise.</returns>
		public bool Query(Rect rect, Func<Body, bool> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = handler((Body)stack0.PopObject());
				stack0.Push(result);
			});
			return Native.physicsworld_query(Raw, rect.Raw, func_id0, stack_raw0) != 0;
		}
		/// <summary>
		/// Casts a ray through the physics world and finds the first body that intersects with the ray.
		/// </summary>
		/// <param name="start">The starting point of the ray.</param>
		/// <param name="stop">The ending point of the ray.</param>
		/// <param name="closest">Whether to stop ray casting upon the closest body that intersects with the ray. Set `closest` to `true` to get a faster ray casting search.</param>
		/// <param name="handler">A function that is called for each body found in the raycast. The function takes a `Body`, a `Vec2` representing the point where the ray intersects with the body, and a `Vec2` representing the normal vector at the point of intersection as arguments, and returns a `bool` indicating whether to continue casting the ray for more bodies. Return `false` to continue, `true` to stop.</param>
		/// <returns>Whether the raycast was interrupted. `true` means interrupted, `false` otherwise.</returns>
		public bool Raycast(Vec2 start, Vec2 stop, bool closest, Func<Body, Vec2, Vec2, bool> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = handler((Body)stack0.PopObject(), stack0.PopVec2(), stack0.PopVec2());
				stack0.Push(result);
			});
			return Native.physicsworld_raycast(Raw, start.Raw, stop.Raw, closest ? 1 : 0, func_id0, stack_raw0) != 0;
		}
		/// <summary>
		/// Sets the number of velocity and position iterations to perform in the physics world.
		/// </summary>
		/// <param name="velocityIter">The number of velocity iterations to perform.</param>
		/// <param name="positionIter">The number of position iterations to perform.</param>
		public void SetIterations(int velocityIter, int positionIter)
		{
			Native.physicsworld_set_iterations(Raw, velocityIter, positionIter);
		}
		/// <summary>
		/// Sets whether two physics groups should make contact with each other or not.
		/// </summary>
		/// <param name="groupA">The first physics group.</param>
		/// <param name="groupB">The second physics group.</param>
		/// <param name="contact">Whether the two groups should make contact with each other.</param>
		public void SetShouldContact(int groupA, int groupB, bool contact)
		{
			Native.physicsworld_set_should_contact(Raw, groupA, groupB, contact ? 1 : 0);
		}
		/// <summary>
		/// Gets whether two physics groups should make contact with each other or not.
		/// </summary>
		/// <param name="groupA">The first physics group.</param>
		/// <param name="groupB">The second physics group.</param>
		/// <returns>Whether the two groups should make contact with each other.</returns>
		public bool GetShouldContact(int groupA, int groupB)
		{
			return Native.physicsworld_get_should_contact(Raw, groupA, groupB) != 0;
		}
		/// <summary>
		/// The factor used for converting physics engine meters value to pixel value.
		/// Default 100.0 is a good value since the physics engine can well simulate real life objects
		/// between 0.1 to 10 meters. Use value 100.0 we can simulate game objects
		/// between 10 to 1000 pixels that suite most games.
		/// You can change this value before any physics body creation.
		/// </summary>
		public float ScaleFactor
		{
			set => Native.physicsworld_set_scale_factor(value);
			get => Native.physicsworld_get_scale_factor();
		}
		/// <summary>
		/// Creates a new `PhysicsWorld` object.
		/// </summary>
		public PhysicsWorld() : this(Native.physicsworld_new()) { }
	}
} // namespace Dora
