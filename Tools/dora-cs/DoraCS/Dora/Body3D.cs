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
		public static extern int32_t body3d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body3d_get_world(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body3d_get_body_def(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t body3d_get_type(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body3d_set_linear_velocity(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body3d_get_linear_velocity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body3d_set_angular_velocity(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body3d_get_angular_velocity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body3d_set_collision_layer(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t body3d_get_collision_layer(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body3d_set_collision_mask(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t body3d_get_collision_mask(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body3d_set_sensor(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t body3d_is_sensor(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body3d_apply_force(int64_t self, int64_t force);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body3d_apply_linear_impulse(int64_t self, int64_t impulse);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body3d_on_contact_enter(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body3d_on_contact_stay(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body3d_on_contact_exit(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body3d_new(int64_t bodyDef, int64_t world, int64_t position, int64_t angles);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A 3D rigid body node owned by a PhysicsWorld3D.
	/// </summary>
	public partial class Body3D : Node3D
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.body3d_type(), From);
		}
		protected Body3D(long raw) : base(raw) { }
		internal static new Body3D From(long raw)
		{
			return new Body3D(raw);
		}
		internal static new Body3D? FromOpt(long raw)
		{
			return raw == 0 ? null : new Body3D(raw);
		}
		/// <summary>The physics world that owns this body.</summary>
		public PhysicsWorld3D? World
		{
			get => PhysicsWorld3D.FromOpt(Native.body3d_get_world(Raw));
		}
		/// <summary>The definition used to create this body.</summary>
		public BodyDef3D BodyDef
		{
			get => BodyDef3D.From(Native.body3d_get_body_def(Raw));
		}
		/// <summary>The body's motion type.</summary>
		public BodyType3D Type
		{
			get => (BodyType3D)Native.body3d_get_type(Raw);
		}
		/// <summary>The world-space linear velocity.</summary>
		public Vec3 LinearVelocity
		{
			set => Native.body3d_set_linear_velocity(Raw, value.Raw);
			get => Vec3.From(Native.body3d_get_linear_velocity(Raw));
		}
		/// <summary>The world-space angular velocity in radians per second.</summary>
		public Vec3 AngularVelocity
		{
			set => Native.body3d_set_angular_velocity(Raw, value.Raw);
			get => Vec3.From(Native.body3d_get_angular_velocity(Raw));
		}
		/// <summary>The collision layer in the range 0 through 31.</summary>
		public int CollisionLayer
		{
			set => Native.body3d_set_collision_layer(Raw, value);
			get => Native.body3d_get_collision_layer(Raw);
		}
		/// <summary>The bit mask of collision layers accepted by this body.</summary>
		public int CollisionMask
		{
			set => Native.body3d_set_collision_mask(Raw, value);
			get => Native.body3d_get_collision_mask(Raw);
		}
		/// <summary>Whether this body reports contacts without collision response.</summary>
		public bool IsSensor
		{
			set => Native.body3d_set_sensor(Raw, value ? 1 : 0);
			get => Native.body3d_is_sensor(Raw) != 0;
		}
		/// <summary>Applies a continuous force at the center of mass.</summary>
		public void ApplyForce(Vec3 force)
		{
			Native.body3d_apply_force(Raw, force.Raw);
		}
		/// <summary>Applies an instantaneous impulse at the center of mass.</summary>
		public void ApplyLinearImpulse(Vec3 impulse)
		{
			Native.body3d_apply_linear_impulse(Raw, impulse.Raw);
		}
		/// <summary>Sets the persistent contact-enter callback.</summary>
		public void OnContactEnter(System.Action<Body3D, Vec3, Vec3> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				handler((Body3D)stack0.PopObject(), stack0.PopVec3(), stack0.PopVec3());
			});
			Native.body3d_on_contact_enter(Raw, func_id0, stack_raw0);
		}
		/// <summary>Sets the persistent contact-stay callback.</summary>
		public void OnContactStay(System.Action<Body3D, Vec3, Vec3> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				handler((Body3D)stack0.PopObject(), stack0.PopVec3(), stack0.PopVec3());
			});
			Native.body3d_on_contact_stay(Raw, func_id0, stack_raw0);
		}
		/// <summary>Sets the persistent contact-exit callback.</summary>
		public void OnContactExit(System.Action<Body3D, Vec3, Vec3> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				handler((Body3D)stack0.PopObject(), stack0.PopVec3(), stack0.PopVec3());
			});
			Native.body3d_on_contact_exit(Raw, func_id0, stack_raw0);
		}
		/// <summary>Creates a body at the given transform.</summary>
		public Body3D(BodyDef3D bodyDef, PhysicsWorld3D world, Vec3 position, Vec3 angles) : this(Native.body3d_new(bodyDef.Raw, world.Raw, position.Raw, angles.Raw)) { }
	}
} // namespace Dora
