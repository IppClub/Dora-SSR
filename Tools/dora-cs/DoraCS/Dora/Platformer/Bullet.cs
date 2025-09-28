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
		public static extern int32_t platformer_bullet_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bullet_set_target_allow(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_bullet_get_target_allow(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_bullet_is_face_right(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bullet_set_hit_stop(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_bullet_is_hit_stop(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bullet_get_emitter(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bullet_get_bullet_def(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bullet_set_face(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bullet_get_face(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_bullet_destroy(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_bullet_new(int64_t def, int64_t owner);
	}
} // namespace Dora

namespace Dora.Platformer
{
	/// A struct that defines the properties and behavior of a bullet object instance in the game.
	public partial class Bullet : Body
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.node_type(), From);
		}
		protected Bullet(long raw) : base(raw) { }
		internal static new Bullet From(long raw)
		{
			return new Bullet(raw);
		}
		internal static new Bullet? FromOpt(long raw)
		{
			return raw == 0 ? null : new Bullet(raw);
		}
		/// the value from a `Platformer.TargetAllow` object for the bullet object.
		public int TargetAllow
		{
			set => Native.platformer_bullet_set_target_allow(Raw, value);
			get => Native.platformer_bullet_get_target_allow(Raw);
		}
		/// whether the bullet object is facing right.
		public bool IsFaceRight
		{
			get => Native.platformer_bullet_is_face_right(Raw) != 0;
		}
		/// whether the bullet object should stop on impact.
		public bool IsHitStop
		{
			set => Native.platformer_bullet_set_hit_stop(Raw, value ? 1 : 0);
			get => Native.platformer_bullet_is_hit_stop(Raw) != 0;
		}
		/// the `Unit` object that fired the bullet.
		public Platformer.Unit Emitter
		{
			get => Platformer.Unit.From(Native.platformer_bullet_get_emitter(Raw));
		}
		/// the `BulletDef` object that defines the bullet's properties and behavior.
		public Platformer.BulletDef BulletDef
		{
			get => Platformer.BulletDef.From(Native.platformer_bullet_get_bullet_def(Raw));
		}
		/// the `Node` object that appears as the bullet's visual item.
		public Node Face
		{
			set => Native.platformer_bullet_set_face(Raw, value.Raw);
			get => Node.From(Native.platformer_bullet_get_face(Raw));
		}
		/// Destroys the bullet object instance.
		public void Destroy()
		{
			Native.platformer_bullet_destroy(Raw);
		}
		/// A method that creates a new `Bullet` object instance with the specified `BulletDef` and `Unit` objects.
		///
		/// # Arguments
		///
		/// * `def` - The `BulletDef` object that defines the bullet's properties and behavior.
		/// * `owner` - The `Unit` object that fired the bullet.
		///
		/// # Returns
		///
		/// * `Bullet` - The new `Bullet` object instance.
		public Bullet(Platformer.BulletDef def, Platformer.Unit owner) : this(Native.platformer_bullet_new(def.Raw, owner.Raw)) { }
	}
} // namespace Dora.Platformer
