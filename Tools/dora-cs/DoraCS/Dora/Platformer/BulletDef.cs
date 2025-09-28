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
		public static extern int32_t platformer_bulletdef_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_tag(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bulletdef_get_tag(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_end_effect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bulletdef_get_end_effect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_life_time(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_bulletdef_get_life_time(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_damage_radius(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_bulletdef_get_damage_radius(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_high_speed_fix(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_bulletdef_is_high_speed_fix(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_gravity(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bulletdef_get_gravity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_face(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bulletdef_get_face(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bulletdef_get_body_def(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bulletdef_get_velocity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_as_circle(int64_t self, float radius);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bulletdef_set_velocity(int64_t self, float angle, float speed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bulletdef_new();
	}
} // namespace Dora

namespace Dora.Platformer
{
	/// A struct type that specifies the properties and behaviors of a bullet object in the game.
	public partial class BulletDef : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.platformer_bulletdef_type(), From);
		}
		protected BulletDef(long raw) : base(raw) { }
		internal static new BulletDef From(long raw)
		{
			return new BulletDef(raw);
		}
		internal static new BulletDef? FromOpt(long raw)
		{
			return raw == 0 ? null : new BulletDef(raw);
		}
		/// the tag for the bullet object.
		public string Tag
		{
			set => Native.platformer_bulletdef_set_tag(Raw, Bridge.FromString(value));
			get => Bridge.ToString(Native.platformer_bulletdef_get_tag(Raw));
		}
		/// the effect that occurs when the bullet object ends its life.
		public string EndEffect
		{
			set => Native.platformer_bulletdef_set_end_effect(Raw, Bridge.FromString(value));
			get => Bridge.ToString(Native.platformer_bulletdef_get_end_effect(Raw));
		}
		/// the amount of time in seconds that the bullet object remains active.
		public float LifeTime
		{
			set => Native.platformer_bulletdef_set_life_time(Raw, value);
			get => Native.platformer_bulletdef_get_life_time(Raw);
		}
		/// the radius of the bullet object's damage area.
		public float DamageRadius
		{
			set => Native.platformer_bulletdef_set_damage_radius(Raw, value);
			get => Native.platformer_bulletdef_get_damage_radius(Raw);
		}
		/// whether the bullet object should be fixed for high speeds.
		public bool IsHighSpeedFix
		{
			set => Native.platformer_bulletdef_set_high_speed_fix(Raw, value ? 1 : 0);
			get => Native.platformer_bulletdef_is_high_speed_fix(Raw) != 0;
		}
		/// the gravity vector that applies to the bullet object.
		public Vec2 Gravity
		{
			set => Native.platformer_bulletdef_set_gravity(Raw, value.Raw);
			get => Vec2.From(Native.platformer_bulletdef_get_gravity(Raw));
		}
		/// the visual item of the bullet object.
		public Platformer.Face Face
		{
			set => Native.platformer_bulletdef_set_face(Raw, value.Raw);
			get => Platformer.Face.From(Native.platformer_bulletdef_get_face(Raw));
		}
		/// the physics body definition for the bullet object.
		public BodyDef BodyDef
		{
			get => BodyDef.From(Native.platformer_bulletdef_get_body_def(Raw));
		}
		/// the velocity vector of the bullet object.
		public Vec2 Velocity
		{
			get => Vec2.From(Native.platformer_bulletdef_get_velocity(Raw));
		}
		/// Sets the bullet object's physics body as a circle.
		///
		/// # Arguments
		///
		/// * `radius` - The radius of the circle.
		public void SetAsCircle(float radius)
		{
			Native.platformer_bulletdef_set_as_circle(Raw, radius);
		}
		/// Sets the velocity of the bullet object.
		///
		/// # Arguments
		///
		/// * `angle` - The angle of the velocity in degrees.
		/// * `speed` - The speed of the velocity.
		public void SetVelocity(float angle, float speed)
		{
			Native.platformer_bulletdef_set_velocity(Raw, angle, speed);
		}
		/// Creates a new bullet object definition with default settings.
		///
		/// # Returns
		///
		/// * `BulletDef` - The new bullet object definition.
		public BulletDef() : this(Native.platformer_bulletdef_new()) { }
	}
} // namespace Dora.Platformer
