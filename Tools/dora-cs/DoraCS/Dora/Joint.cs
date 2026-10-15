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
		public static extern int32_t joint_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_distance(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t anchorA, int64_t anchorB, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_friction(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t worldPos, float maxForce, float maxTorque);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_gear(int32_t collision, int64_t jointA, int64_t jointB, float ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_spring(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t linearOffset, float angularOffset, float maxForce, float maxTorque, float correctionFactor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_move_target(int32_t collision, int64_t body, int64_t targetPos, float maxForce, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_prismatic(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t worldPos, float axisAngle, float lowerTranslation, float upperTranslation, float maxMotorForce, float motorSpeed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_pulley(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t anchorA, int64_t anchorB, int64_t groundAnchorA, int64_t groundAnchorB, float ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_revolute(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t worldPos, float lowerAngle, float upperAngle, float maxMotorTorque, float motorSpeed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_rope(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t anchorA, int64_t anchorB, float maxLength);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_weld(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t worldPos, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_wheel(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t worldPos, float axisAngle, float maxMotorTorque, float motorSpeed, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_get_world(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void joint_destroy(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_new(int64_t def, int64_t itemDict);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct that can be used to connect physics bodies together.
	/// </summary>
	public partial class Joint : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.joint_type(), From);
		}
		protected Joint(long raw) : base(raw) { }
		internal static new Joint From(long raw)
		{
			return new Joint(raw);
		}
		internal static new Joint? FromOpt(long raw)
		{
			return raw == 0 ? null : new Joint(raw);
		}
		/// <summary>
		/// Creates a distance joint between two physics bodies.
		/// </summary>
		/// <param name="can_collide">Whether or not the physics body connected to joint will collide with each other.</param>
		/// <param name="body_a">The first physics body to connect with the joint.</param>
		/// <param name="body_b">The second physics body to connect with the joint.</param>
		/// <param name="anchor_a">The position of the joint on the first physics body.</param>
		/// <param name="anchor_b">The position of the joint on the second physics body.</param>
		/// <param name="frequency">The frequency of the joint, in Hertz.</param>
		/// <param name="damping">The damping ratio of the joint.</param>
		/// <returns>The new distance joint.</returns>
		public static Joint Distance(bool collision, Body bodyA, Body bodyB, Vec2 anchorA, Vec2 anchorB, float frequency = 0.0f, float damping = 0.0f)
		{
			return Joint.From(Native.joint_distance(collision ? 1 : 0, bodyA.Raw, bodyB.Raw, anchorA.Raw, anchorB.Raw, frequency, damping));
		}
		/// <summary>
		/// Creates a friction joint between two physics bodies.
		/// </summary>
		/// <param name="can_collide">Whether or not the physics body connected to joint will collide with each other.</param>
		/// <param name="body_a">The first physics body to connect with the joint.</param>
		/// <param name="body_b">The second physics body to connect with the joint.</param>
		/// <param name="world_pos">The position of the joint in the game world.</param>
		/// <param name="max_force">The maximum force that can be applied to the joint.</param>
		/// <param name="max_torque">The maximum torque that can be applied to the joint.</param>
		/// <returns>The new friction joint.</returns>
		public static Joint Friction(bool collision, Body bodyA, Body bodyB, Vec2 worldPos, float maxForce, float maxTorque)
		{
			return Joint.From(Native.joint_friction(collision ? 1 : 0, bodyA.Raw, bodyB.Raw, worldPos.Raw, maxForce, maxTorque));
		}
		/// <summary>
		/// Creates a gear joint between two other joints.
		/// </summary>
		/// <param name="can_collide">Whether or not the physics bodies connected to the joint can collide with each other.</param>
		/// <param name="joint_a">The first joint to connect with the gear joint.</param>
		/// <param name="joint_b">The second joint to connect with the gear joint.</param>
		/// <param name="ratio">The gear ratio.</param>
		/// <returns>The new gear joint.</returns>
		public static Joint Gear(bool collision, Joint jointA, Joint jointB, float ratio = 1.0f)
		{
			return Joint.From(Native.joint_gear(collision ? 1 : 0, jointA.Raw, jointB.Raw, ratio));
		}
		/// <summary>
		/// Creates a new spring joint between the two specified bodies.
		/// </summary>
		/// <param name="collision">Whether the connected bodies should collide with each other.</param>
		/// <param name="bodyA">The first body connected to the joint.</param>
		/// <param name="bodyB">The second body connected to the joint.</param>
		/// <param name="linearOffset">Position of body-B minus the position of body-A, in body-A's frame.</param>
		/// <param name="angularOffset">Angle of body-B minus angle of body-A.</param>
		/// <param name="maxForce">The maximum force the joint can exert.</param>
		/// <param name="maxTorque">The maximum torque the joint can exert.</param>
		/// <param name="correctionFactor">Correction factor. 0.0 = no correction, 1.0 = full correction.</param>
		/// <returns>The created joint.</returns>
		public static Joint Spring(bool collision, Body bodyA, Body bodyB, Vec2 linearOffset, float angularOffset, float maxForce, float maxTorque, float correctionFactor = 1.0f)
		{
			return Joint.From(Native.joint_spring(collision ? 1 : 0, bodyA.Raw, bodyB.Raw, linearOffset.Raw, angularOffset, maxForce, maxTorque, correctionFactor));
		}
		/// <summary>
		/// Creates a new move joint for the specified body.
		/// </summary>
		/// <param name="collision">Whether the body can collide with other bodies.</param>
		/// <param name="body">The body that the joint is attached to.</param>
		/// <param name="targetPos">The target position that the body should move towards.</param>
		/// <param name="maxForce">The maximum force the joint can exert.</param>
		/// <param name="frequency">Frequency ratio.</param>
		/// <param name="damping">Damping ratio.</param>
		/// <returns>The created move joint.</returns>
		public static MoveJoint MoveTarget(bool collision, Body body, Vec2 targetPos, float maxForce, float frequency = 5.0f, float damping = 0.7f)
		{
			return MoveJoint.From(Native.joint_move_target(collision ? 1 : 0, body.Raw, targetPos.Raw, maxForce, frequency, damping));
		}
		/// <summary>
		/// Creates a new prismatic joint between the two specified bodies.
		/// </summary>
		/// <param name="collision">Whether the connected bodies should collide with each other.</param>
		/// <param name="bodyA">The first body connected to the joint.</param>
		/// <param name="bodyB">The second body connected to the joint.</param>
		/// <param name="worldPos">The world position of the joint.</param>
		/// <param name="axisAngle">The axis angle of the joint.</param>
		/// <param name="lowerTranslation">Lower translation limit.</param>
		/// <param name="upperTranslation">Upper translation limit.</param>
		/// <param name="maxMotorForce">Maximum motor force.</param>
		/// <param name="motorSpeed">Motor speed.</param>
		/// <returns>The created prismatic joint.</returns>
		public static MotorJoint Prismatic(bool collision, Body bodyA, Body bodyB, Vec2 worldPos, float axisAngle, float lowerTranslation = 0.0f, float upperTranslation = 0.0f, float maxMotorForce = 0.0f, float motorSpeed = 0.0f)
		{
			return MotorJoint.From(Native.joint_prismatic(collision ? 1 : 0, bodyA.Raw, bodyB.Raw, worldPos.Raw, axisAngle, lowerTranslation, upperTranslation, maxMotorForce, motorSpeed));
		}
		/// <summary>
		/// Creates a pulley joint between two physics bodies.
		/// </summary>
		/// <param name="collision">Whether or not the connected bodies will collide with each other.</param>
		/// <param name="bodyA">The first physics body to connect.</param>
		/// <param name="bodyB">The second physics body to connect.</param>
		/// <param name="anchorA">The position of the anchor point on the first body.</param>
		/// <param name="anchorB">The position of the anchor point on the second body.</param>
		/// <param name="groundAnchorA">The position of the ground anchor point on the first body in world coordinates.</param>
		/// <param name="groundAnchorB">The position of the ground anchor point on the second body in world coordinates.</param>
		/// <param name="ratio">The pulley ratio.</param>
		/// <returns>The pulley joint.</returns>
		public static Joint Pulley(bool collision, Body bodyA, Body bodyB, Vec2 anchorA, Vec2 anchorB, Vec2 groundAnchorA, Vec2 groundAnchorB, float ratio = 1.0f)
		{
			return Joint.From(Native.joint_pulley(collision ? 1 : 0, bodyA.Raw, bodyB.Raw, anchorA.Raw, anchorB.Raw, groundAnchorA.Raw, groundAnchorB.Raw, ratio));
		}
		/// <summary>
		/// Creates a revolute joint between two physics bodies.
		/// </summary>
		/// <param name="collision">Whether or not the connected bodies will collide with each other.</param>
		/// <param name="bodyA">The first physics body to connect.</param>
		/// <param name="bodyB">The second physics body to connect.</param>
		/// <param name="worldPos">The position in world coordinates where the joint will be created.</param>
		/// <param name="lowerAngle">The lower angle limit in radians.</param>
		/// <param name="upperAngle">The upper angle limit in radians.</param>
		/// <param name="maxMotorTorque">The maximum torque that can be applied to the joint to achieve the target speed.</param>
		/// <param name="motorSpeed">The desired speed of the joint.</param>
		/// <returns>The revolute joint.</returns>
		public static MotorJoint Revolute(bool collision, Body bodyA, Body bodyB, Vec2 worldPos, float lowerAngle = 0.0f, float upperAngle = 0.0f, float maxMotorTorque = 0.0f, float motorSpeed = 0.0f)
		{
			return MotorJoint.From(Native.joint_revolute(collision ? 1 : 0, bodyA.Raw, bodyB.Raw, worldPos.Raw, lowerAngle, upperAngle, maxMotorTorque, motorSpeed));
		}
		/// <summary>
		/// Creates a rope joint between two physics bodies.
		/// </summary>
		/// <param name="collision">Whether or not the connected bodies will collide with each other.</param>
		/// <param name="bodyA">The first physics body to connect.</param>
		/// <param name="bodyB">The second physics body to connect.</param>
		/// <param name="anchorA">The position of the anchor point on the first body.</param>
		/// <param name="anchorB">The position of the anchor point on the second body.</param>
		/// <param name="maxLength">The maximum distance between the anchor points.</param>
		/// <returns>The rope joint.</returns>
		public static Joint Rope(bool collision, Body bodyA, Body bodyB, Vec2 anchorA, Vec2 anchorB, float maxLength)
		{
			return Joint.From(Native.joint_rope(collision ? 1 : 0, bodyA.Raw, bodyB.Raw, anchorA.Raw, anchorB.Raw, maxLength));
		}
		/// <summary>
		/// Creates a weld joint between two bodies.
		/// </summary>
		/// <param name="collision">Whether or not the bodies connected to the joint can collide with each other.</param>
		/// <param name="bodyA">The first body to be connected by the joint.</param>
		/// <param name="bodyB">The second body to be connected by the joint.</param>
		/// <param name="worldPos">The position in the world to connect the bodies together.</param>
		/// <param name="frequency">The frequency at which the joint should be stiff.</param>
		/// <param name="damping">The damping rate of the joint.</param>
		/// <returns>The newly created weld joint.</returns>
		public static Joint Weld(bool collision, Body bodyA, Body bodyB, Vec2 worldPos, float frequency = 0.0f, float damping = 0.0f)
		{
			return Joint.From(Native.joint_weld(collision ? 1 : 0, bodyA.Raw, bodyB.Raw, worldPos.Raw, frequency, damping));
		}
		/// <summary>
		/// Creates a wheel joint between two bodies.
		/// </summary>
		/// <param name="collision">Whether or not the bodies connected to the joint can collide with each other.</param>
		/// <param name="bodyA">The first body to be connected by the joint.</param>
		/// <param name="bodyB">The second body to be connected by the joint.</param>
		/// <param name="worldPos">The position in the world to connect the bodies together.</param>
		/// <param name="axisAngle">The angle of the joint axis in radians.</param>
		/// <param name="maxMotorTorque">The maximum torque the joint motor can exert.</param>
		/// <param name="motorSpeed">The target speed of the joint motor.</param>
		/// <param name="frequency">The frequency at which the joint should be stiff.</param>
		/// <param name="damping">The damping rate of the joint.</param>
		/// <returns>The newly created wheel joint.</returns>
		public static MotorJoint Wheel(bool collision, Body bodyA, Body bodyB, Vec2 worldPos, float axisAngle, float maxMotorTorque = 0.0f, float motorSpeed = 0.0f, float frequency = 2.0f, float damping = 0.7f)
		{
			return MotorJoint.From(Native.joint_wheel(collision ? 1 : 0, bodyA.Raw, bodyB.Raw, worldPos.Raw, axisAngle, maxMotorTorque, motorSpeed, frequency, damping));
		}
		/// <summary>
		/// the physics world that the joint belongs to.
		/// </summary>
		public PhysicsWorld World
		{
			get => PhysicsWorld.From(Native.joint_get_world(Raw));
		}
		/// <summary>
		/// Destroys the joint and removes it from the physics simulation.
		/// </summary>
		public void Destroy()
		{
			Native.joint_destroy(Raw);
		}
		/// <summary>
		/// Creates a joint instance based on the given joint definition and item dictionary containing physics bodies to be connected by joint.
		/// </summary>
		/// <param name="def">The joint definition.</param>
		/// <param name="itemDict">The dictionary containing all the bodies and other required items.</param>
		/// <returns>The newly created joint.</returns>
		public Joint(JointDef def, Dictionary itemDict) : this(Native.joint_new(def.Raw, itemDict.Raw)) { }
	}
} // namespace Dora
