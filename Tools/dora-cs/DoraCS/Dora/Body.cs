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
		public static extern int32_t body_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body_get_world(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body_get_body_def(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float body_get_mass(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t body_is_sensor(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_velocity_x(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float body_get_velocity_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_velocity_y(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float body_get_velocity_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_velocity(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body_get_velocity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_angular_rate(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float body_get_angular_rate(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_group(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t body_get_group(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_linear_damping(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float body_get_linear_damping(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_angular_damping(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float body_get_angular_damping(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_owner(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body_get_owner(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_set_receiving_contact(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t body_is_receiving_contact(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_apply_linear_impulse(int64_t self, int64_t impulse, int64_t pos);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_apply_angular_impulse(int64_t self, float impulse);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body_get_sensor_by_tag(int64_t self, int32_t tag);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t body_remove_sensor_by_tag(int64_t self, int32_t tag);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t body_remove_sensor(int64_t self, int64_t sensor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_attach(int64_t self, int64_t fixtureDef);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body_attach_sensor(int64_t self, int32_t tag, int64_t fixtureDef);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void body_on_contact_filter(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t body_new(int64_t def, int64_t world, int64_t pos, float rot);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct represents a physics body in the world.
	/// </summary>
	public partial class Body : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.body_type(), From);
		}
		protected Body(long raw) : base(raw) { }
		internal static new Body From(long raw)
		{
			return new Body(raw);
		}
		internal static new Body? FromOpt(long raw)
		{
			return raw == 0 ? null : new Body(raw);
		}
		/// <summary>
		/// The physics world that the body belongs to.
		/// </summary>
		public PhysicsWorld World
		{
			get => PhysicsWorld.From(Native.body_get_world(Raw));
		}
		/// <summary>
		/// The definition of the body.
		/// </summary>
		public BodyDef BodyDef
		{
			get => BodyDef.From(Native.body_get_body_def(Raw));
		}
		/// <summary>
		/// The mass of the body.
		/// </summary>
		public float Mass
		{
			get => Native.body_get_mass(Raw);
		}
		/// <summary>
		/// Whether the body is used as a sensor or not.
		/// </summary>
		public bool IsSensor
		{
			get => Native.body_is_sensor(Raw) != 0;
		}
		/// <summary>
		/// The x-axis velocity of the body.
		/// </summary>
		public float VelocityX
		{
			set => Native.body_set_velocity_x(Raw, value);
			get => Native.body_get_velocity_x(Raw);
		}
		/// <summary>
		/// The y-axis velocity of the body.
		/// </summary>
		public float VelocityY
		{
			set => Native.body_set_velocity_y(Raw, value);
			get => Native.body_get_velocity_y(Raw);
		}
		/// <summary>
		/// The velocity of the body as a `Vec2`.
		/// </summary>
		public Vec2 Velocity
		{
			set => Native.body_set_velocity(Raw, value.Raw);
			get => Vec2.From(Native.body_get_velocity(Raw));
		}
		/// <summary>
		/// The angular rate of the body.
		/// </summary>
		public float AngularRate
		{
			set => Native.body_set_angular_rate(Raw, value);
			get => Native.body_get_angular_rate(Raw);
		}
		/// <summary>
		/// The collision group that the body belongs to.
		/// </summary>
		public int Group
		{
			set => Native.body_set_group(Raw, value);
			get => Native.body_get_group(Raw);
		}
		/// <summary>
		/// The linear damping of the body.
		/// </summary>
		public float LinearDamping
		{
			set => Native.body_set_linear_damping(Raw, value);
			get => Native.body_get_linear_damping(Raw);
		}
		/// <summary>
		/// The angular damping of the body.
		/// </summary>
		public float AngularDamping
		{
			set => Native.body_set_angular_damping(Raw, value);
			get => Native.body_get_angular_damping(Raw);
		}
		/// <summary>
		/// The reference for an owner of the body.
		/// </summary>
		public Object Owner
		{
			set => Native.body_set_owner(Raw, value.Raw);
			get => Object.From(Native.body_get_owner(Raw));
		}
		/// <summary>
		/// Whether the body is currently receiving contact events or not.
		/// </summary>
		public bool IsReceivingContact
		{
			set => Native.body_set_receiving_contact(Raw, value ? 1 : 0);
			get => Native.body_is_receiving_contact(Raw) != 0;
		}
		/// <summary>
		/// Applies a linear impulse to the body at a specified position.
		/// </summary>
		/// <param name="impulse">The linear impulse to apply.</param>
		/// <param name="pos">The position at which to apply the impulse.</param>
		public void ApplyLinearImpulse(Vec2 impulse, Vec2 pos)
		{
			Native.body_apply_linear_impulse(Raw, impulse.Raw, pos.Raw);
		}
		/// <summary>
		/// Applies an angular impulse to the body.
		/// </summary>
		/// <param name="impulse">The angular impulse to apply.</param>
		public void ApplyAngularImpulse(float impulse)
		{
			Native.body_apply_angular_impulse(Raw, impulse);
		}
		/// <summary>
		/// Returns the sensor with the given tag.
		/// </summary>
		/// <param name="tag">The tag of the sensor to get.</param>
		/// <returns>The sensor with the given tag.</returns>
		public Sensor GetSensorByTag(int tag)
		{
			return Sensor.From(Native.body_get_sensor_by_tag(Raw, tag));
		}
		/// <summary>
		/// Removes the sensor with the specified tag from the body.
		/// </summary>
		/// <param name="tag">The tag of the sensor to remove.</param>
		/// <returns>Whether a sensor with the specified tag was found and removed.</returns>
		public bool RemoveSensorByTag(int tag)
		{
			return Native.body_remove_sensor_by_tag(Raw, tag) != 0;
		}
		/// <summary>
		/// Removes the given sensor from the body's sensor list.
		/// </summary>
		/// <param name="sensor">The sensor to remove.</param>
		/// <returns>`true` if the sensor was successfully removed, `false` otherwise.</returns>
		public bool RemoveSensor(Sensor sensor)
		{
			return Native.body_remove_sensor(Raw, sensor.Raw) != 0;
		}
		/// <summary>
		/// Attaches a fixture to the body.
		/// </summary>
		/// <param name="fixtureDef">The fixture definition for the fixture to attach.</param>
		public void Attach(FixtureDef fixtureDef)
		{
			Native.body_attach(Raw, fixtureDef.Raw);
		}
		/// <summary>
		/// Attaches a new sensor with the given tag and fixture definition to the body.
		/// </summary>
		/// <param name="tag">The tag of the sensor to attach.</param>
		/// <param name="fixtureDef">The fixture definition of the sensor.</param>
		/// <returns>The newly attached sensor.</returns>
		public Sensor AttachSensor(int tag, FixtureDef fixtureDef)
		{
			return Sensor.From(Native.body_attach_sensor(Raw, tag, fixtureDef.Raw));
		}
		/// <summary>
		/// Registers a function to be called when the body begins to receive contact events. Return `false` from this function to prevent colliding.
		/// </summary>
		/// <param name="filter">The filter function to set.</param>
		public void OnContactFilter(Func<Body, bool> filter)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = filter((Body)stack0.PopObject());
				stack0.Push(result);
			});
			Native.body_on_contact_filter(Raw, func_id0, stack_raw0);
		}
		/// <summary>
		/// Creates a new instance of `Body`.
		/// </summary>
		/// <param name="def">The definition for the body to be created.</param>
		/// <param name="world">The physics world where the body belongs.</param>
		/// <param name="pos">The initial position of the body.</param>
		/// <param name="rot">The initial rotation angle of the body in degrees.</param>
		public Body(BodyDef def, PhysicsWorld world, Vec2 pos, float rot) : this(Native.body_new(def.Raw, world.Raw, pos.Raw, rot)) { }
	}
} // namespace Dora
