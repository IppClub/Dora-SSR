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
		public static extern int32_t charactercontroller3d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t charactercontroller3d_get_node(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t charactercontroller3d_get_world(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void charactercontroller3d_set_desired_velocity(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t charactercontroller3d_get_desired_velocity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t charactercontroller3d_get_velocity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t charactercontroller3d_get_ground_normal(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t charactercontroller3d_is_grounded(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void charactercontroller3d_set_collision_layer(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t charactercontroller3d_get_collision_layer(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void charactercontroller3d_set_collision_mask(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t charactercontroller3d_get_collision_mask(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void charactercontroller3d_jump(int64_t self, float speed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void charactercontroller3d_destroy(int64_t self);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>A virtual capsule character controller owned by a PhysicsWorld3D.</summary>
	public partial class CharacterController3D : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.charactercontroller3d_type(), From);
		}
		protected CharacterController3D(long raw) : base(raw) { }
		internal static new CharacterController3D From(long raw)
		{
			return new CharacterController3D(raw);
		}
		internal static new CharacterController3D? FromOpt(long raw)
		{
			return raw == 0 ? null : new CharacterController3D(raw);
		}
		/// <summary>The Node3D synchronized with this character.</summary>
		public Node3D? Node
		{
			get => Node3D.FromOpt(Native.charactercontroller3d_get_node(Raw));
		}
		/// <summary>The physics world that owns this character.</summary>
		public PhysicsWorld3D? World
		{
			get => PhysicsWorld3D.FromOpt(Native.charactercontroller3d_get_world(Raw));
		}
		/// <summary>The desired horizontal movement velocity.</summary>
		public Vec3 DesiredVelocity
		{
			set => Native.charactercontroller3d_set_desired_velocity(Raw, value.Raw);
			get => Vec3.From(Native.charactercontroller3d_get_desired_velocity(Raw));
		}
		/// <summary>The current world-space velocity including gravity and jumping.</summary>
		public Vec3 Velocity
		{
			get => Vec3.From(Native.charactercontroller3d_get_velocity(Raw));
		}
		/// <summary>The current supporting surface normal.</summary>
		public Vec3 GroundNormal
		{
			get => Vec3.From(Native.charactercontroller3d_get_ground_normal(Raw));
		}
		/// <summary>Whether the character is standing on walkable ground.</summary>
		public bool IsGrounded
		{
			get => Native.charactercontroller3d_is_grounded(Raw) != 0;
		}
		/// <summary>The collision layer in the range 0 through 31.</summary>
		public int CollisionLayer
		{
			set => Native.charactercontroller3d_set_collision_layer(Raw, value);
			get => Native.charactercontroller3d_get_collision_layer(Raw);
		}
		/// <summary>The bit mask of collision layers accepted by this character.</summary>
		public int CollisionMask
		{
			set => Native.charactercontroller3d_set_collision_mask(Raw, value);
			get => Native.charactercontroller3d_get_collision_mask(Raw);
		}
		/// <summary>Requests a jump with the given upward speed.</summary>
		public void Jump(float speed)
		{
			Native.charactercontroller3d_jump(Raw, speed);
		}
		/// <summary>Removes this character from its physics world.</summary>
		public void Destroy()
		{
			Native.charactercontroller3d_destroy(Raw);
		}
	}
} // namespace Dora
