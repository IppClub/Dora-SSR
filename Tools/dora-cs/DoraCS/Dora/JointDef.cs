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
		public static extern int32_t jointdef_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void jointdef_set_center(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_get_center(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void jointdef_set_position(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_get_position(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void jointdef_set_angle(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float jointdef_get_angle(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_distance(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_friction(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float max_force, float max_torque);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_gear(int32_t collision, int64_t joint_a, int64_t joint_b, float ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_spring(int32_t collision, int64_t body_a, int64_t body_b, int64_t linear_offset, float angular_offset, float max_force, float max_torque, float correction_factor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_prismatic(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float lower_translation, float upper_translation, float max_motor_force, float motor_speed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_pulley(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, int64_t ground_anchor_a, int64_t ground_anchor_b, float ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_revolute(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float lower_angle, float upper_angle, float max_motor_torque, float motor_speed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_rope(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float max_length);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_weld(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_wheel(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float max_motor_torque, float motor_speed, float frequency, float damping);
	}
} // namespace Dora

namespace Dora
{
	/// A struct that defines the properties of a joint to be created.
	public partial class JointDef : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.node_type(), From);
		}
		protected JointDef(long raw) : base(raw) { }
		internal static new JointDef From(long raw)
		{
			return new JointDef(raw);
		}
		internal static new JointDef? FromOpt(long raw)
		{
			return raw == 0 ? null : new JointDef(raw);
		}
		/// the center point of the joint, in local coordinates.
		public Vec2 Center
		{
			set => Native.jointdef_set_center(Raw, value.Raw);
			get => Vec2.From(Native.jointdef_get_center(Raw));
		}
		/// the position of the joint, in world coordinates.
		public Vec2 Position
		{
			set => Native.jointdef_set_position(Raw, value.Raw);
			get => Vec2.From(Native.jointdef_get_position(Raw));
		}
		/// the angle of the joint, in degrees.
		public float Angle
		{
			set => Native.jointdef_set_angle(Raw, value);
			get => Native.jointdef_get_angle(Raw);
		}
		/// Creates a distance joint definition.
		///
		/// # Arguments
		///
		/// * `can_collide` - Whether or not the physics body connected to joint will collide with each other.
		/// * `body_a` - The name of first physics body to connect with the joint.
		/// * `body_b` - The name of second physics body to connect with the joint.
		/// * `anchor_a` - The position of the joint on the first physics body.
		/// * `anchor_b` - The position of the joint on the second physics body.
		/// * `frequency` - The frequency of the joint, in Hertz.
		/// * `damping` - The damping ratio of the joint.
		///
		/// # Returns
		///
		/// * `JointDef` - The new joint definition.
		public static JointDef Distance(bool collision, string body_a, string body_b, Vec2 anchor_a, Vec2 anchor_b, float frequency, float damping)
		{
			return JointDef.From(Native.jointdef_distance(collision ? 1 : 0, Bridge.FromString(body_a), Bridge.FromString(body_b), anchor_a.Raw, anchor_b.Raw, frequency, damping));
		}
		/// Creates a friction joint definition.
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
		/// * `Joint` - The new friction joint definition.
		public static JointDef Friction(bool collision, string body_a, string body_b, Vec2 world_pos, float max_force, float max_torque)
		{
			return JointDef.From(Native.jointdef_friction(collision ? 1 : 0, Bridge.FromString(body_a), Bridge.FromString(body_b), world_pos.Raw, max_force, max_torque));
		}
		/// Creates a gear joint definition.
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
		/// * `Joint` - The new gear joint definition.
		public static JointDef Gear(bool collision, string joint_a, string joint_b, float ratio)
		{
			return JointDef.From(Native.jointdef_gear(collision ? 1 : 0, Bridge.FromString(joint_a), Bridge.FromString(joint_b), ratio));
		}
		/// Creates a new spring joint definition.
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
		/// * `Joint` - The created joint definition.
		public static JointDef Spring(bool collision, string body_a, string body_b, Vec2 linear_offset, float angular_offset, float max_force, float max_torque, float correction_factor)
		{
			return JointDef.From(Native.jointdef_spring(collision ? 1 : 0, Bridge.FromString(body_a), Bridge.FromString(body_b), linear_offset.Raw, angular_offset, max_force, max_torque, correction_factor));
		}
		/// Creates a new prismatic joint definition.
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
		/// * `MotorJoint` - The created prismatic joint definition.
		public static JointDef Prismatic(bool collision, string body_a, string body_b, Vec2 world_pos, float axis_angle, float lower_translation, float upper_translation, float max_motor_force, float motor_speed)
		{
			return JointDef.From(Native.jointdef_prismatic(collision ? 1 : 0, Bridge.FromString(body_a), Bridge.FromString(body_b), world_pos.Raw, axis_angle, lower_translation, upper_translation, max_motor_force, motor_speed));
		}
		/// Creates a pulley joint definition.
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
		/// * `Joint` - The pulley joint definition.
		public static JointDef Pulley(bool collision, string body_a, string body_b, Vec2 anchor_a, Vec2 anchor_b, Vec2 ground_anchor_a, Vec2 ground_anchor_b, float ratio)
		{
			return JointDef.From(Native.jointdef_pulley(collision ? 1 : 0, Bridge.FromString(body_a), Bridge.FromString(body_b), anchor_a.Raw, anchor_b.Raw, ground_anchor_a.Raw, ground_anchor_b.Raw, ratio));
		}
		/// Creates a revolute joint definition.
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
		/// * `MotorJoint` - The revolute joint definition.
		public static JointDef Revolute(bool collision, string body_a, string body_b, Vec2 world_pos, float lower_angle, float upper_angle, float max_motor_torque, float motor_speed)
		{
			return JointDef.From(Native.jointdef_revolute(collision ? 1 : 0, Bridge.FromString(body_a), Bridge.FromString(body_b), world_pos.Raw, lower_angle, upper_angle, max_motor_torque, motor_speed));
		}
		/// Creates a rope joint definition.
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
		/// * `Joint` - The rope joint definition.
		public static JointDef Rope(bool collision, string body_a, string body_b, Vec2 anchor_a, Vec2 anchor_b, float max_length)
		{
			return JointDef.From(Native.jointdef_rope(collision ? 1 : 0, Bridge.FromString(body_a), Bridge.FromString(body_b), anchor_a.Raw, anchor_b.Raw, max_length));
		}
		/// Creates a weld joint definition.
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
		/// * `Joint` - The newly created weld joint definition.
		public static JointDef Weld(bool collision, string body_a, string body_b, Vec2 world_pos, float frequency, float damping)
		{
			return JointDef.From(Native.jointdef_weld(collision ? 1 : 0, Bridge.FromString(body_a), Bridge.FromString(body_b), world_pos.Raw, frequency, damping));
		}
		/// Creates a wheel joint definition.
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
		/// * `MotorJoint` - The newly created wheel joint definition.
		public static JointDef Wheel(bool collision, string body_a, string body_b, Vec2 world_pos, float axis_angle, float max_motor_torque, float motor_speed, float frequency, float damping)
		{
			return JointDef.From(Native.jointdef_wheel(collision ? 1 : 0, Bridge.FromString(body_a), Bridge.FromString(body_b), world_pos.Raw, axis_angle, max_motor_torque, motor_speed, frequency, damping));
		}
	}
} // namespace Dora
