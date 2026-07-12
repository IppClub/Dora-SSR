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
		public static extern int32_t physicsworld3d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void physicsworld3d_set_gravity(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsworld3d_get_gravity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsworld3d_create_box(int64_t self, int64_t node, int64_t halfExtent, int32_t bodyType);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsworld3d_create_sphere(int64_t self, int64_t node, float radius, int32_t bodyType);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsworld3d_create_capsule(int64_t self, int64_t node, float halfHeight, float radius, int32_t bodyType);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsworld3d_create_body(int64_t self, int64_t node, int64_t shape, int32_t bodyType);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsworld3d_create_character(int64_t self, int64_t node, float halfHeight, float radius, float maxSlopeAngle, float stepHeight);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsworld3d_create_fixed_constraint(int64_t self, int64_t firstBody, int64_t secondBody, int64_t anchor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsworld3d_create_distance_constraint(int64_t self, int64_t firstBody, int64_t secondBody, int64_t firstAnchor, int64_t secondAnchor, float minDistance, float maxDistance);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsworld3d_create_hinge_constraint(int64_t self, int64_t firstBody, int64_t secondBody, int64_t anchor, int64_t axis, float minAngle, float maxAngle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void physicsworld3d_destroy_body(int64_t self, int64_t body);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void physicsworld3d_destroy_character(int64_t self, int64_t character);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void physicsworld3d_destroy_constraint(int64_t self, int64_t constraint);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t physicsworld3d_raycast(int64_t self, int64_t origin, int64_t direction, float distance, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t physicsworld3d_overlap_sphere(int64_t self, int64_t center, float radius, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t physicsworld3d_new();
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A fixed-step 3D physics world backed by Jolt Physics.
	/// </summary>
	public partial class PhysicsWorld3D : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.physicsworld3d_type(), From);
		}
		protected PhysicsWorld3D(long raw) : base(raw) { }
		internal static new PhysicsWorld3D From(long raw)
		{
			return new PhysicsWorld3D(raw);
		}
		internal static new PhysicsWorld3D? FromOpt(long raw)
		{
			return raw == 0 ? null : new PhysicsWorld3D(raw);
		}
		/// <summary>The world gravity in units per second squared.</summary>
		public Vec3 Gravity
		{
			set => Native.physicsworld3d_set_gravity(Raw, value.Raw);
			get => Vec3.From(Native.physicsworld3d_get_gravity(Raw));
		}
		/// <summary>Creates a box body using half extents.</summary>
		public Body3D CreateBox(Node3D node, Vec3 halfExtent, BodyType3D bodyType = BodyType3D.Dynamic)
		{
			return Body3D.From(Native.physicsworld3d_create_box(Raw, node.Raw, halfExtent.Raw, (int)bodyType));
		}
		/// <summary>Creates a sphere body.</summary>
		public Body3D CreateSphere(Node3D node, float radius, BodyType3D bodyType = BodyType3D.Dynamic)
		{
			return Body3D.From(Native.physicsworld3d_create_sphere(Raw, node.Raw, radius, (int)bodyType));
		}
		/// <summary>Creates a capsule body.</summary>
		public Body3D CreateCapsule(Node3D node, float halfHeight, float radius, BodyType3D bodyType = BodyType3D.Dynamic)
		{
			return Body3D.From(Native.physicsworld3d_create_capsule(Raw, node.Raw, halfHeight, radius, (int)bodyType));
		}
		/// <summary>Creates a body using a reusable built collision shape.</summary>
		public Body3D CreateBody(Node3D node, PhysicsShape3D shape, BodyType3D bodyType = BodyType3D.Dynamic)
		{
			return Body3D.From(Native.physicsworld3d_create_body(Raw, node.Raw, shape.Raw, (int)bodyType));
		}
		/// <summary>Creates a virtual capsule character whose node position represents its feet.</summary>
		public CharacterController3D CreateCharacter(Node3D node, float halfHeight, float radius, float maxSlopeAngle = 50.0f, float stepHeight = 0.4f)
		{
			return CharacterController3D.From(Native.physicsworld3d_create_character(Raw, node.Raw, halfHeight, radius, maxSlopeAngle, stepHeight));
		}
		/// <summary>Creates a fixed constraint at a world-space anchor.</summary>
		public Constraint3D CreateFixedConstraint(Body3D firstBody, Body3D secondBody, Vec3 anchor)
		{
			return Constraint3D.From(Native.physicsworld3d_create_fixed_constraint(Raw, firstBody.Raw, secondBody.Raw, anchor.Raw));
		}
		/// <summary>Creates a distance constraint between two world-space anchors.</summary>
		public Constraint3D CreateDistanceConstraint(Body3D firstBody, Body3D secondBody, Vec3 firstAnchor, Vec3 secondAnchor, float minDistance, float maxDistance)
		{
			return Constraint3D.From(Native.physicsworld3d_create_distance_constraint(Raw, firstBody.Raw, secondBody.Raw, firstAnchor.Raw, secondAnchor.Raw, minDistance, maxDistance));
		}
		/// <summary>Creates a hinge around a world-space axis with limits in degrees.</summary>
		public Constraint3D CreateHingeConstraint(Body3D firstBody, Body3D secondBody, Vec3 anchor, Vec3 axis, float minAngle, float maxAngle)
		{
			return Constraint3D.From(Native.physicsworld3d_create_hinge_constraint(Raw, firstBody.Raw, secondBody.Raw, anchor.Raw, axis.Raw, minAngle, maxAngle));
		}
		/// <summary>Removes a body from this world.</summary>
		public void DestroyBody(Body3D body)
		{
			Native.physicsworld3d_destroy_body(Raw, body.Raw);
		}
		/// <summary>Removes a character from this world.</summary>
		public void DestroyCharacter(CharacterController3D character)
		{
			Native.physicsworld3d_destroy_character(Raw, character.Raw);
		}
		/// <summary>Removes a constraint from this world.</summary>
		public void DestroyConstraint(Constraint3D constraint)
		{
			Native.physicsworld3d_destroy_constraint(Raw, constraint.Raw);
		}
		/// <summary>Casts a ray and invokes the handler for the nearest hit.</summary>
		public bool Raycast(Vec3 origin, Vec3 direction, float distance, Func<Body3D, Vec3, Vec3, float, bool> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = handler((Body3D)stack0.PopObject(), stack0.PopVec3(), stack0.PopVec3(), stack0.PopF32());
				stack0.Push(result);
			});
			return Native.physicsworld3d_raycast(Raw, origin.Raw, direction.Raw, distance, func_id0, stack_raw0) != 0;
		}
		/// <summary>Visits bodies overlapping a sphere until the handler returns true.</summary>
		public bool OverlapSphere(Vec3 center, float radius, Func<Body3D, bool> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = handler((Body3D)stack0.PopObject());
				stack0.Push(result);
			});
			return Native.physicsworld3d_overlap_sphere(Raw, center.Raw, radius, func_id0, stack_raw0) != 0;
		}
		/// <summary>Creates a 3D physics world.</summary>
		public PhysicsWorld3D() : this(Native.physicsworld3d_new()) { }
	}
} // namespace Dora
