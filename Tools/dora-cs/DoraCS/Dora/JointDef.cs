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
		public static extern int64_t jointdef_distance(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t anchorA, int64_t anchorB, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_friction(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t worldPos, float maxForce, float maxTorque);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_gear(int32_t collision, int64_t jointA, int64_t jointB, float ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_spring(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t linearOffset, float angularOffset, float maxForce, float maxTorque, float correctionFactor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_prismatic(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t worldPos, float axisAngle, float lowerTranslation, float upperTranslation, float maxMotorForce, float motorSpeed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_pulley(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t anchorA, int64_t anchorB, int64_t groundAnchorA, int64_t groundAnchorB, float ratio);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_revolute(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t worldPos, float lowerAngle, float upperAngle, float maxMotorTorque, float motorSpeed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_rope(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t anchorA, int64_t anchorB, float maxLength);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_weld(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t worldPos, float frequency, float damping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t jointdef_wheel(int32_t collision, int64_t bodyA, int64_t bodyB, int64_t worldPos, float axisAngle, float maxMotorTorque, float motorSpeed, float frequency, float damping);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct that defines the properties of a joint to be created.
	/// </summary>
	public partial class JointDef : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.jointdef_type(), From);
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
		/// <summary>
		/// The center point of the joint, in local coordinates.
		/// </summary>
		public Vec2 Center
		{
			set => Native.jointdef_set_center(Raw, value.Raw);
			get => Vec2.From(Native.jointdef_get_center(Raw));
		}
		/// <summary>
		/// The position of the joint, in world coordinates.
		/// </summary>
		public Vec2 Position
		{
			set => Native.jointdef_set_position(Raw, value.Raw);
			get => Vec2.From(Native.jointdef_get_position(Raw));
		}
		/// <summary>
		/// The angle of the joint, in degrees.
		/// </summary>
		public float Angle
		{
			set => Native.jointdef_set_angle(Raw, value);
			get => Native.jointdef_get_angle(Raw);
		}
		/// <summary>
		/// Creates a distance joint definition.
		/// </summary>
		/// <param name="collision">Whether or not the physics body connected to joint will collide with each other.</param>
		/// <param name="bodyA">The name of first physics body to connect with the joint.</param>
		/// <param name="bodyB">The name of second physics body to connect with the joint.</param>
		/// <param name="anchorA">The position of the joint on the first physics body.</param>
		/// <param name="anchorB">The position of the joint on the second physics body.</param>
		/// <param name="frequency">The frequency of the joint, in Hertz.</param>
		/// <param name="damping">The damping ratio of the joint.</param>
		/// <returns>The new joint definition.</returns>
		public static JointDef Distance(bool collision, string bodyA, string bodyB, Vec2 anchorA, Vec2 anchorB, float frequency = 0.0f, float damping = 0.0f)
		{
			return JointDef.From(Native.jointdef_distance(collision ? 1 : 0, Bridge.FromString(bodyA), Bridge.FromString(bodyB), anchorA.Raw, anchorB.Raw, frequency, damping));
		}
		/// <summary>
		/// Creates a friction joint definition.
		/// </summary>
		/// <param name="collision">Whether or not the physics body connected to joint will collide with each other.</param>
		/// <param name="bodyA">The first physics body to connect with the joint.</param>
		/// <param name="bodyB">The second physics body to connect with the joint.</param>
		/// <param name="worldPos">The position of the joint in the game world.</param>
		/// <param name="maxForce">The maximum force that can be applied to the joint.</param>
		/// <param name="maxTorque">The maximum torque that can be applied to the joint.</param>
		/// <returns>The new friction joint definition.</returns>
		public static JointDef Friction(bool collision, string bodyA, string bodyB, Vec2 worldPos, float maxForce, float maxTorque)
		{
			return JointDef.From(Native.jointdef_friction(collision ? 1 : 0, Bridge.FromString(bodyA), Bridge.FromString(bodyB), worldPos.Raw, maxForce, maxTorque));
		}
		/// <summary>
		/// Creates a gear joint definition.
		/// </summary>
		/// <param name="collision">Whether or not the physics bodies connected to the joint can collide with each other.</param>
		/// <param name="jointA">The first joint to connect with the gear joint.</param>
		/// <param name="jointB">The second joint to connect with the gear joint.</param>
		/// <param name="ratio">The gear ratio.</param>
		/// <returns>The new gear joint definition.</returns>
		public static JointDef Gear(bool collision, string jointA, string jointB, float ratio = 1.0f)
		{
			return JointDef.From(Native.jointdef_gear(collision ? 1 : 0, Bridge.FromString(jointA), Bridge.FromString(jointB), ratio));
		}
		/// <summary>
		/// Creates a new spring joint definition.
		/// </summary>
		/// <param name="collision">Whether the connected bodies should collide with each other.</param>
		/// <param name="bodyA">The first body connected to the joint.</param>
		/// <param name="bodyB">The second body connected to the joint.</param>
		/// <param name="linearOffset">Position of body-B minus the position of body-A, in body-A's frame.</param>
		/// <param name="angularOffset">Angle of body-B minus angle of body-A.</param>
		/// <param name="maxForce">The maximum force the joint can exert.</param>
		/// <param name="maxTorque">The maximum torque the joint can exert.</param>
		/// <param name="correctionFactor">Correction factor. 0.0 = no correction, 1.0 = full correction.</param>
		/// <returns>The created joint definition.</returns>
		public static JointDef Spring(bool collision, string bodyA, string bodyB, Vec2 linearOffset, float angularOffset, float maxForce, float maxTorque, float correctionFactor = 1.0f)
		{
			return JointDef.From(Native.jointdef_spring(collision ? 1 : 0, Bridge.FromString(bodyA), Bridge.FromString(bodyB), linearOffset.Raw, angularOffset, maxForce, maxTorque, correctionFactor));
		}
		/// <summary>
		/// Creates a new prismatic joint definition.
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
		/// <returns>The created prismatic joint definition.</returns>
		public static JointDef Prismatic(bool collision, string bodyA, string bodyB, Vec2 worldPos, float axisAngle, float lowerTranslation = 0.0f, float upperTranslation = 0.0f, float maxMotorForce = 0.0f, float motorSpeed = 0.0f)
		{
			return JointDef.From(Native.jointdef_prismatic(collision ? 1 : 0, Bridge.FromString(bodyA), Bridge.FromString(bodyB), worldPos.Raw, axisAngle, lowerTranslation, upperTranslation, maxMotorForce, motorSpeed));
		}
		/// <summary>
		/// Creates a pulley joint definition.
		/// </summary>
		/// <param name="collision">Whether or not the connected bodies will collide with each other.</param>
		/// <param name="bodyA">The first physics body to connect.</param>
		/// <param name="bodyB">The second physics body to connect.</param>
		/// <param name="anchorA">The position of the anchor point on the first body.</param>
		/// <param name="anchorB">The position of the anchor point on the second body.</param>
		/// <param name="groundAnchorA">The position of the ground anchor point on the first body in world coordinates.</param>
		/// <param name="groundAnchorB">The position of the ground anchor point on the second body in world coordinates.</param>
		/// <param name="ratio">The pulley ratio.</param>
		/// <returns>The pulley joint definition.</returns>
		public static JointDef Pulley(bool collision, string bodyA, string bodyB, Vec2 anchorA, Vec2 anchorB, Vec2 groundAnchorA, Vec2 groundAnchorB, float ratio = 1.0f)
		{
			return JointDef.From(Native.jointdef_pulley(collision ? 1 : 0, Bridge.FromString(bodyA), Bridge.FromString(bodyB), anchorA.Raw, anchorB.Raw, groundAnchorA.Raw, groundAnchorB.Raw, ratio));
		}
		/// <summary>
		/// Creates a revolute joint definition.
		/// </summary>
		/// <param name="collision">Whether or not the connected bodies will collide with each other.</param>
		/// <param name="bodyA">The first physics body to connect.</param>
		/// <param name="bodyB">The second physics body to connect.</param>
		/// <param name="worldPos">The position in world coordinates where the joint will be created.</param>
		/// <param name="lowerAngle">The lower angle limit in radians.</param>
		/// <param name="upperAngle">The upper angle limit in radians.</param>
		/// <param name="maxMotorTorque">The maximum torque that can be applied to the joint to achieve the target speed.</param>
		/// <param name="motorSpeed">The desired speed of the joint.</param>
		/// <returns>The revolute joint definition.</returns>
		public static JointDef Revolute(bool collision, string bodyA, string bodyB, Vec2 worldPos, float lowerAngle = 0.0f, float upperAngle = 0.0f, float maxMotorTorque = 0.0f, float motorSpeed = 0.0f)
		{
			return JointDef.From(Native.jointdef_revolute(collision ? 1 : 0, Bridge.FromString(bodyA), Bridge.FromString(bodyB), worldPos.Raw, lowerAngle, upperAngle, maxMotorTorque, motorSpeed));
		}
		/// <summary>
		/// Creates a rope joint definition.
		/// </summary>
		/// <param name="collision">Whether or not the connected bodies will collide with each other.</param>
		/// <param name="bodyA">The first physics body to connect.</param>
		/// <param name="bodyB">The second physics body to connect.</param>
		/// <param name="anchorA">The position of the anchor point on the first body.</param>
		/// <param name="anchorB">The position of the anchor point on the second body.</param>
		/// <param name="maxLength">The maximum distance between the anchor points.</param>
		/// <returns>The rope joint definition.</returns>
		public static JointDef Rope(bool collision, string bodyA, string bodyB, Vec2 anchorA, Vec2 anchorB, float maxLength)
		{
			return JointDef.From(Native.jointdef_rope(collision ? 1 : 0, Bridge.FromString(bodyA), Bridge.FromString(bodyB), anchorA.Raw, anchorB.Raw, maxLength));
		}
		/// <summary>
		/// Creates a weld joint definition.
		/// </summary>
		/// <param name="collision">Whether or not the bodies connected to the joint can collide with each other.</param>
		/// <param name="bodyA">The first body to be connected by the joint.</param>
		/// <param name="bodyB">The second body to be connected by the joint.</param>
		/// <param name="worldPos">The position in the world to connect the bodies together.</param>
		/// <param name="frequency">The frequency at which the joint should be stiff.</param>
		/// <param name="damping">The damping rate of the joint.</param>
		/// <returns>The newly created weld joint definition.</returns>
		public static JointDef Weld(bool collision, string bodyA, string bodyB, Vec2 worldPos, float frequency = 0.0f, float damping = 0.0f)
		{
			return JointDef.From(Native.jointdef_weld(collision ? 1 : 0, Bridge.FromString(bodyA), Bridge.FromString(bodyB), worldPos.Raw, frequency, damping));
		}
		/// <summary>
		/// Creates a wheel joint definition.
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
		/// <returns>The newly created wheel joint definition.</returns>
		public static JointDef Wheel(bool collision, string bodyA, string bodyB, Vec2 worldPos, float axisAngle, float maxMotorTorque = 0.0f, float motorSpeed = 0.0f, float frequency = 2.0f, float damping = 0.7f)
		{
			return JointDef.From(Native.jointdef_wheel(collision ? 1 : 0, Bridge.FromString(bodyA), Bridge.FromString(bodyB), worldPos.Raw, axisAngle, maxMotorTorque, motorSpeed, frequency, damping));
		}
	}
} // namespace Dora
