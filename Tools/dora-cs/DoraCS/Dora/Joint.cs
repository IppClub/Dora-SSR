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
		public static extern int32_t joint_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_distance(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_friction(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float max_force, float max_torque);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_gear(int32_t collision, int64_t joint_a, int64_t joint_b, float ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_spring(int32_t collision, int64_t body_a, int64_t body_b, int64_t linear_offset, float angular_offset, float max_force, float max_torque, float correction_factor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_move_target(int32_t collision, int64_t body, int64_t target_pos, float max_force, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_prismatic(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float lower_translation, float upper_translation, float max_motor_force, float motor_speed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_pulley(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, int64_t ground_anchor_a, int64_t ground_anchor_b, float ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_revolute(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float lower_angle, float upper_angle, float max_motor_torque, float motor_speed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_rope(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float max_length);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_weld(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_wheel(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float max_motor_torque, float motor_speed, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_get_world(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void joint_destroy(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t joint_new(int64_t def, int64_t item_dict);
	}
} // namespace Dora

namespace Dora
{
	/// A struct that can be used to connect physics bodies together.
	public partial class Joint : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.node_type(), From);
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
		/// Creates a distance joint between two physics bodies.
		///
		/// # Arguments
		///
		/// * `can_collide` - Whether or not the physics body connected to joint will collide with each other.
		/// * `body_a` - The first physics body to connect with the joint.
		/// * `body_b` - The second physics body to connect with the joint.
		/// * `anchor_a` - The position of the joint on the first physics body.
		/// * `anchor_b` - The position of the joint on the second physics body.
		/// * `frequency` - The frequency of the joint, in Hertz.
		/// * `damping` - The damping ratio of the joint.
		///
		/// # Returns
		///
		/// * `Joint` - The new distance joint.
		public static Joint Distance(bool collision, Body body_a, Body body_b, Vec2 anchor_a, Vec2 anchor_b, float frequency, float damping)
		{
			return Joint.From(Native.joint_distance(collision ? 1 : 0, body_a.Raw, body_b.Raw, anchor_a.Raw, anchor_b.Raw, frequency, damping));
		}
		/// Creates a friction joint between two physics bodies.
		///
		/// # Arguments
		///
		/// * `can_collide` - Whether or not the physics body connected to joint will collide with each other.
		/// * `body_a` - The first physics body to connect with the joint.
		/// * `body_b` - The second physics body to connect with the joint.
		/// * `world_pos` - The position of the joint in the game world.
		/// * `max_force` - The maximum force that can be applied to the joint.
		/// * `max_torque` - The maximum torque that can be applied to the joint.
		///
		/// # Returns
		///
		/// * `Joint` - The new friction joint.
		public static Joint Friction(bool collision, Body body_a, Body body_b, Vec2 world_pos, float max_force, float max_torque)
		{
			return Joint.From(Native.joint_friction(collision ? 1 : 0, body_a.Raw, body_b.Raw, world_pos.Raw, max_force, max_torque));
		}
		/// Creates a gear joint between two other joints.
		///
		/// # Arguments
		///
		/// * `can_collide` - Whether or not the physics bodies connected to the joint can collide with each other.
		/// * `joint_a` - The first joint to connect with the gear joint.
		/// * `joint_b` - The second joint to connect with the gear joint.
		/// * `ratio` - The gear ratio.
		///
		/// # Returns
		///
		/// * `Joint` - The new gear joint.
		public static Joint Gear(bool collision, Joint joint_a, Joint joint_b, float ratio)
		{
			return Joint.From(Native.joint_gear(collision ? 1 : 0, joint_a.Raw, joint_b.Raw, ratio));
		}
		/// Creates a new spring joint between the two specified bodies.
		///
		/// # Arguments
		///
		/// * `can_collide` - Whether the connected bodies should collide with each other.
		/// * `body_a` - The first body connected to the joint.
		/// * `body_b` - The second body connected to the joint.
		/// * `linear_offset` - Position of body-B minus the position of body-A, in body-A's frame.
		/// * `angular_offset` - Angle of body-B minus angle of body-A.
		/// * `max_force` - The maximum force the joint can exert.
		/// * `max_torque` - The maximum torque the joint can exert.
		/// * `correction_factor` - Correction factor. 0.0 = no correction, 1.0 = full correction.
		///
		/// # Returns
		///
		/// * `Joint` - The created joint.
		public static Joint Spring(bool collision, Body body_a, Body body_b, Vec2 linear_offset, float angular_offset, float max_force, float max_torque, float correction_factor)
		{
			return Joint.From(Native.joint_spring(collision ? 1 : 0, body_a.Raw, body_b.Raw, linear_offset.Raw, angular_offset, max_force, max_torque, correction_factor));
		}
		/// Creates a new move joint for the specified body.
		///
		/// # Arguments
		///
		/// * `can_collide` - Whether the body can collide with other bodies.
		/// * `body` - The body that the joint is attached to.
		/// * `target_pos` - The target position that the body should move towards.
		/// * `max_force` - The maximum force the joint can exert.
		/// * `frequency` - Frequency ratio.
		/// * `damping` - Damping ratio.
		///
		/// # Returns
		///
		/// * `MoveJoint` - The created move joint.
		public static MoveJoint MoveTarget(bool collision, Body body, Vec2 target_pos, float max_force, float frequency, float damping)
		{
			return MoveJoint.From(Native.joint_move_target(collision ? 1 : 0, body.Raw, target_pos.Raw, max_force, frequency, damping));
		}
		/// Creates a new prismatic joint between the two specified bodies.
		///
		/// # Arguments
		///
		/// * `can_collide` - Whether the connected bodies should collide with each other.
		/// * `body_a` - The first body connected to the joint.
		/// * `body_b` - The second body connected to the joint.
		/// * `world_pos` - The world position of the joint.
		/// * `axis_angle` - The axis angle of the joint.
		/// * `lower_translation` - Lower translation limit.
		/// * `upper_translation` - Upper translation limit.
		/// * `max_motor_force` - Maximum motor force.
		/// * `motor_speed` - Motor speed.
		///
		/// # Returns
		///
		/// * `MotorJoint` - The created prismatic joint.
		public static MotorJoint Prismatic(bool collision, Body body_a, Body body_b, Vec2 world_pos, float axis_angle, float lower_translation, float upper_translation, float max_motor_force, float motor_speed)
		{
			return MotorJoint.From(Native.joint_prismatic(collision ? 1 : 0, body_a.Raw, body_b.Raw, world_pos.Raw, axis_angle, lower_translation, upper_translation, max_motor_force, motor_speed));
		}
		/// Creates a pulley joint between two physics bodies.
		///
		/// # Arguments
		///
		/// * `can_collide` - Whether or not the connected bodies will collide with each other.
		/// * `body_a` - The first physics body to connect.
		/// * `body_b` - The second physics body to connect.
		/// * `anchor_a` - The position of the anchor point on the first body.
		/// * `anchor_b` - The position of the anchor point on the second body.
		/// * `ground_anchor_a` - The position of the ground anchor point on the first body in world coordinates.
		/// * `ground_anchor_b` - The position of the ground anchor point on the second body in world coordinates.
		/// * `ratio` - The pulley ratio.
		///
		/// # Returns
		///
		/// * `Joint` - The pulley joint.
		public static Joint Pulley(bool collision, Body body_a, Body body_b, Vec2 anchor_a, Vec2 anchor_b, Vec2 ground_anchor_a, Vec2 ground_anchor_b, float ratio)
		{
			return Joint.From(Native.joint_pulley(collision ? 1 : 0, body_a.Raw, body_b.Raw, anchor_a.Raw, anchor_b.Raw, ground_anchor_a.Raw, ground_anchor_b.Raw, ratio));
		}
		/// Creates a revolute joint between two physics bodies.
		///
		/// # Arguments
		///
		/// * `can_collide` - Whether or not the connected bodies will collide with each other.
		/// * `body_a` - The first physics body to connect.
		/// * `body_b` - The second physics body to connect.
		/// * `world_pos` - The position in world coordinates where the joint will be created.
		/// * `lower_angle` - The lower angle limit in radians.
		/// * `upper_angle` - The upper angle limit in radians.
		/// * `max_motor_torque` - The maximum torque that can be applied to the joint to achieve the target speed.
		/// * `motor_speed` - The desired speed of the joint.
		///
		/// # Returns
		///
		/// * `MotorJoint` - The revolute joint.
		public static MotorJoint Revolute(bool collision, Body body_a, Body body_b, Vec2 world_pos, float lower_angle, float upper_angle, float max_motor_torque, float motor_speed)
		{
			return MotorJoint.From(Native.joint_revolute(collision ? 1 : 0, body_a.Raw, body_b.Raw, world_pos.Raw, lower_angle, upper_angle, max_motor_torque, motor_speed));
		}
		/// Creates a rope joint between two physics bodies.
		///
		/// # Arguments
		///
		/// * `can_collide` - Whether or not the connected bodies will collide with each other.
		/// * `body_a` - The first physics body to connect.
		/// * `body_b` - The second physics body to connect.
		/// * `anchor_a` - The position of the anchor point on the first body.
		/// * `anchor_b` - The position of the anchor point on the second body.
		/// * `max_length` - The maximum distance between the anchor points.
		///
		/// # Returns
		///
		/// * `Joint` - The rope joint.
		public static Joint Rope(bool collision, Body body_a, Body body_b, Vec2 anchor_a, Vec2 anchor_b, float max_length)
		{
			return Joint.From(Native.joint_rope(collision ? 1 : 0, body_a.Raw, body_b.Raw, anchor_a.Raw, anchor_b.Raw, max_length));
		}
		/// Creates a weld joint between two bodies.
		///
		/// # Arguments
		///
		/// * `can_collide` - Whether or not the bodies connected to the joint can collide with each other.
		/// * `body_a` - The first body to be connected by the joint.
		/// * `body_b` - The second body to be connected by the joint.
		/// * `world_pos` - The position in the world to connect the bodies together.
		/// * `frequency` - The frequency at which the joint should be stiff.
		/// * `damping` - The damping rate of the joint.
		///
		/// # Returns
		///
		/// * `Joint` - The newly created weld joint.
		public static Joint Weld(bool collision, Body body_a, Body body_b, Vec2 world_pos, float frequency, float damping)
		{
			return Joint.From(Native.joint_weld(collision ? 1 : 0, body_a.Raw, body_b.Raw, world_pos.Raw, frequency, damping));
		}
		/// Creates a wheel joint between two bodies.
		///
		/// # Arguments
		///
		/// * `can_collide` - Whether or not the bodies connected to the joint can collide with each other.
		/// * `body_a` - The first body to be connected by the joint.
		/// * `body_b` - The second body to be connected by the joint.
		/// * `world_pos` - The position in the world to connect the bodies together.
		/// * `axis_angle` - The angle of the joint axis in radians.
		/// * `max_motor_torque` - The maximum torque the joint motor can exert.
		/// * `motor_speed` - The target speed of the joint motor.
		/// * `frequency` - The frequency at which the joint should be stiff.
		/// * `damping` - The damping rate of the joint.
		///
		/// # Returns
		///
		/// * `MotorJoint` - The newly created wheel joint.
		public static MotorJoint Wheel(bool collision, Body body_a, Body body_b, Vec2 world_pos, float axis_angle, float max_motor_torque, float motor_speed, float frequency, float damping)
		{
			return MotorJoint.From(Native.joint_wheel(collision ? 1 : 0, body_a.Raw, body_b.Raw, world_pos.Raw, axis_angle, max_motor_torque, motor_speed, frequency, damping));
		}
		/// the physics world that the joint belongs to.
		public PhysicsWorld World
		{
			get => PhysicsWorld.From(Native.joint_get_world(Raw));
		}
		/// Destroys the joint and removes it from the physics simulation.
		public void Destroy()
		{
			Native.joint_destroy(Raw);
		}
		/// Creates a joint instance based on the given joint definition and item dictionary containing physics bodies to be connected by joint.
		///
		/// # Arguments
		///
		/// * `def` - The joint definition.
		/// * `item_dict` - The dictionary containing all the bodies and other required items.
		///
		/// # Returns
		///
		/// * `Joint` - The newly created joint.
		public Joint(JointDef def, Dictionary item_dict) : this(Native.joint_new(def.Raw, item_dict.Raw)) { }
	}
} // namespace Dora
