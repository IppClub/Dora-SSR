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
		public static extern int32_t bodydef_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_type(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t bodydef_get_type(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_position(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_get_position(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_angle(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float bodydef_get_angle(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_face(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_get_face(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_face_pos(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_get_face_pos(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_linear_damping(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float bodydef_get_linear_damping(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_angular_damping(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float bodydef_get_angular_damping(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_linear_acceleration(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_get_linear_acceleration(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_fixed_rotation(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t bodydef_is_fixed_rotation(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_set_bullet(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t bodydef_is_bullet(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_polygon_with_center(int64_t center, float width, float height, float angle, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_polygon(float width, float height, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_polygon_with_vertices(int64_t vertices, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_polygon_with_center(int64_t self, int64_t center, float width, float height, float angle, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_polygon(int64_t self, float width, float height, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_polygon_with_vertices(int64_t self, int64_t vertices, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_multi(int64_t vertices, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_multi(int64_t self, int64_t vertices, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_disk_with_center(int64_t center, float radius, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_disk(float radius, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_disk_with_center(int64_t self, int64_t center, float radius, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_disk(int64_t self, float radius, float density, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_chain(int64_t vertices, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_chain(int64_t self, int64_t vertices, float friction, float restitution);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_polygon_sensor(int64_t self, int32_t tag, float width, float height);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_polygon_sensor_with_center(int64_t self, int32_t tag, int64_t center, float width, float height, float angle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_polygon_sensor_with_vertices(int64_t self, int32_t tag, int64_t vertices);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_disk_sensor_with_center(int64_t self, int32_t tag, int64_t center, float radius);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void bodydef_attach_disk_sensor(int64_t self, int32_t tag, float radius);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t bodydef_new();
	}
} // namespace Dora

namespace Dora
{
	/// A struct to describe the properties of a physics body.
	public partial class BodyDef : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.bodydef_type(), From);
		}
		protected BodyDef(long raw) : base(raw) { }
		internal static new BodyDef From(long raw)
		{
			return new BodyDef(raw);
		}
		internal static new BodyDef? FromOpt(long raw)
		{
			return raw == 0 ? null : new BodyDef(raw);
		}
		/// the define for the type of the body.
		public BodyType Type
		{
			set => Native.bodydef_set_type(Raw, (int)value);
			get => (BodyType)Native.bodydef_get_type(Raw);
		}
		/// define for the position of the body.
		public Vec2 Position
		{
			set => Native.bodydef_set_position(Raw, value.Raw);
			get => Vec2.From(Native.bodydef_get_position(Raw));
		}
		/// define for the angle of the body.
		public float Angle
		{
			set => Native.bodydef_set_angle(Raw, value);
			get => Native.bodydef_get_angle(Raw);
		}
		/// define for the face image or other items accepted by creating `Face` for the body.
		public string Face
		{
			set => Native.bodydef_set_face(Raw, Bridge.FromString(value));
			get => Bridge.ToString(Native.bodydef_get_face(Raw));
		}
		/// define for the face position of the body.
		public Vec2 FacePos
		{
			set => Native.bodydef_set_face_pos(Raw, value.Raw);
			get => Vec2.From(Native.bodydef_get_face_pos(Raw));
		}
		/// define for linear damping of the body.
		public float LinearDamping
		{
			set => Native.bodydef_set_linear_damping(Raw, value);
			get => Native.bodydef_get_linear_damping(Raw);
		}
		/// define for angular damping of the body.
		public float AngularDamping
		{
			set => Native.bodydef_set_angular_damping(Raw, value);
			get => Native.bodydef_get_angular_damping(Raw);
		}
		/// define for initial linear acceleration of the body.
		public Vec2 LinearAcceleration
		{
			set => Native.bodydef_set_linear_acceleration(Raw, value.Raw);
			get => Vec2.From(Native.bodydef_get_linear_acceleration(Raw));
		}
		/// whether the body's rotation is fixed or not.
		public bool IsFixedRotation
		{
			set => Native.bodydef_set_fixed_rotation(Raw, value ? 1 : 0);
			get => Native.bodydef_is_fixed_rotation(Raw) != 0;
		}
		/// whether the body is a bullet or not.
		/// Set to true to add extra bullet movement check for the body.
		public bool IsBullet
		{
			set => Native.bodydef_set_bullet(Raw, value ? 1 : 0);
			get => Native.bodydef_is_bullet(Raw) != 0;
		}
		/// Creates a polygon fixture definition with the specified dimensions and center position.
		///
		/// # Arguments
		///
		/// * `center` - The center point of the polygon.
		/// * `width` - The width of the polygon.
		/// * `height` - The height of the polygon.
		/// * `angle` - The angle of the polygon.
		/// * `density` - The density of the polygon.
		/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
		/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.
		public static FixtureDef PolygonWithCenter(Vec2 center, float width, float height, float angle, float density, float friction, float restitution)
		{
			return FixtureDef.From(Native.bodydef_polygon_with_center(center.Raw, width, height, angle, density, friction, restitution));
		}
		/// Creates a polygon fixture definition with the specified dimensions.
		///
		/// # Arguments
		///
		/// * `width` - The width of the polygon.
		/// * `height` - The height of the polygon.
		/// * `density` - The density of the polygon.
		/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
		/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.
		public static FixtureDef Polygon(float width, float height, float density, float friction, float restitution)
		{
			return FixtureDef.From(Native.bodydef_polygon(width, height, density, friction, restitution));
		}
		/// Creates a polygon fixture definition with the specified vertices.
		///
		/// # Arguments
		///
		/// * `vertices` - The vertices of the polygon.
		/// * `density` - The density of the polygon.
		/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
		/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.0.
		public static FixtureDef PolygonWithVertices(IEnumerable<Vec2> vertices, float density, float friction, float restitution)
		{
			return FixtureDef.From(Native.bodydef_polygon_with_vertices(Bridge.FromArray(vertices), density, friction, restitution));
		}
		/// Attaches a polygon fixture definition to the body.
		///
		/// # Arguments
		///
		/// * `center` - The center point of the polygon.
		/// * `width` - The width of the polygon.
		/// * `height` - The height of the polygon.
		/// * `angle` - The angle of the polygon.
		/// * `density` - The density of the polygon.
		/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
		/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.0.
		public void AttachPolygonWithCenter(Vec2 center, float width, float height, float angle, float density, float friction, float restitution)
		{
			Native.bodydef_attach_polygon_with_center(Raw, center.Raw, width, height, angle, density, friction, restitution);
		}
		/// Attaches a polygon fixture definition to the body.
		///
		/// # Arguments
		///
		/// * `width` - The width of the polygon.
		/// * `height` - The height of the polygon.
		/// * `density` - The density of the polygon.
		/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
		/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.0.
		public void AttachPolygon(float width, float height, float density, float friction, float restitution)
		{
			Native.bodydef_attach_polygon(Raw, width, height, density, friction, restitution);
		}
		/// Attaches a polygon fixture definition to the body.
		///
		/// # Arguments
		///
		/// * `vertices` - The vertices of the polygon.
		/// * `density` - The density of the polygon.
		/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
		/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.0.
		public void AttachPolygonWithVertices(IEnumerable<Vec2> vertices, float density, float friction, float restitution)
		{
			Native.bodydef_attach_polygon_with_vertices(Raw, Bridge.FromArray(vertices), density, friction, restitution);
		}
		/// Creates a concave shape definition made of multiple convex shapes.
		///
		/// # Arguments
		///
		/// * `vertices` - A vector containing the vertices of each convex shape that makes up the concave shape. Each convex shape in the vertices vector should end with a `Vec2(0.0, 0.0)` as separator.
		/// * `density` - The density of the shape.
		/// * `friction` - The friction coefficient of the shape. Should be between 0.0 and 1.0.
		/// * `restitution` - The restitution (elasticity) of the shape. Should be between 0.0 and 1.0.
		///
		/// # Returns
		///
		/// * `FixtureDef` - The resulting fixture definition.
		public static FixtureDef Multi(IEnumerable<Vec2> vertices, float density, float friction, float restitution)
		{
			return FixtureDef.From(Native.bodydef_multi(Bridge.FromArray(vertices), density, friction, restitution));
		}
		/// Attaches a concave shape definition made of multiple convex shapes to the body.
		///
		/// # Arguments
		///
		/// * `vertices` - A vector containing the vertices of each convex shape that makes up the concave shape. Each convex shape in the vertices vector should end with a `Vec2(0.0, 0.0)` as separator.
		/// * `density` - The density of the concave shape.
		/// * `friction` - The friction of the concave shape. Should be between 0.0 and 1.0.
		/// * `restitution` - The restitution of the concave shape. Should be between 0.0 and 1.0.
		public void AttachMulti(IEnumerable<Vec2> vertices, float density, float friction, float restitution)
		{
			Native.bodydef_attach_multi(Raw, Bridge.FromArray(vertices), density, friction, restitution);
		}
		/// Creates a Disk-shape fixture definition.
		///
		/// # Arguments
		///
		/// * `center` - The center of the circle.
		/// * `radius` - The radius of the circle.
		/// * `density` - The density of the circle.
		/// * `friction` - The friction coefficient of the circle. Should be between 0.0 and 1.0.
		/// * `restitution` - The restitution (elasticity) of the circle. Should be between 0.0 and 1.0.
		///
		/// # Returns
		///
		/// * `FixtureDef` - The resulting fixture definition.
		public static FixtureDef DiskWithCenter(Vec2 center, float radius, float density, float friction, float restitution)
		{
			return FixtureDef.From(Native.bodydef_disk_with_center(center.Raw, radius, density, friction, restitution));
		}
		/// Creates a Disk-shape fixture definition.
		///
		/// # Arguments
		///
		/// * `radius` - The radius of the circle.
		/// * `density` - The density of the circle.
		/// * `friction` - The friction coefficient of the circle. Should be between 0.0 and 1.0.
		/// * `restitution` - The restitution (elasticity) of the circle. Should be between 0.0 and 1.0.
		///
		/// # Returns
		///
		/// * `FixtureDef` - The resulting fixture definition.
		public static FixtureDef Disk(float radius, float density, float friction, float restitution)
		{
			return FixtureDef.From(Native.bodydef_disk(radius, density, friction, restitution));
		}
		/// Attaches a disk fixture definition to the body.
		///
		/// # Arguments
		///
		/// * `center` - The center point of the disk.
		/// * `radius` - The radius of the disk.
		/// * `density` - The density of the disk.
		/// * `friction` - The friction of the disk. Should be between 0.0 and 1.0.
		/// * `restitution` - The restitution of the disk. Should be between 0.0 and 1.0.
		public void AttachDiskWithCenter(Vec2 center, float radius, float density, float friction, float restitution)
		{
			Native.bodydef_attach_disk_with_center(Raw, center.Raw, radius, density, friction, restitution);
		}
		/// Attaches a disk fixture definition to the body.
		///
		/// # Arguments
		///
		/// * `radius` - The radius of the disk.
		/// * `density` - The density of the disk.
		/// * `friction` - The friction of the disk. Should be between 0.0 and 1.0.
		/// * `restitution` - The restitution of the disk. Should be between 0.0 and 1.0.
		public void AttachDisk(float radius, float density, float friction, float restitution)
		{
			Native.bodydef_attach_disk(Raw, radius, density, friction, restitution);
		}
		/// Creates a Chain-shape fixture definition. This fixture is a free form sequence of line segments that has two-sided collision.
		///
		/// # Arguments
		///
		/// * `vertices` - The vertices of the chain.
		/// * `friction` - The friction coefficient of the chain. Should be between 0.0 and 1.0.
		/// * `restitution` - The restitution (elasticity) of the chain. Should be between 0.0 and 1.0.
		///
		/// # Returns
		///
		/// * `FixtureDef` - The resulting fixture definition.
		public static FixtureDef Chain(IEnumerable<Vec2> vertices, float friction, float restitution)
		{
			return FixtureDef.From(Native.bodydef_chain(Bridge.FromArray(vertices), friction, restitution));
		}
		/// Attaches a chain fixture definition to the body. The Chain fixture is a free form sequence of line segments that has two-sided collision.
		///
		/// # Arguments
		///
		/// * `vertices` - The vertices of the chain.
		/// * `friction` - The friction of the chain. Should be between 0.0 and 1.0.
		/// * `restitution` - The restitution of the chain. Should be between 0.0 and 1.0.
		public void AttachChain(IEnumerable<Vec2> vertices, float friction, float restitution)
		{
			Native.bodydef_attach_chain(Raw, Bridge.FromArray(vertices), friction, restitution);
		}
		/// Attaches a polygon sensor fixture definition to the body.
		///
		/// # Arguments
		///
		/// * `tag` - An integer tag for the sensor.
		/// * `width` - The width of the polygon.
		/// * `height` - The height of the polygon.
		public void AttachPolygonSensor(int tag, float width, float height)
		{
			Native.bodydef_attach_polygon_sensor(Raw, tag, width, height);
		}
		/// Attaches a polygon sensor fixture definition to the body.
		///
		/// # Arguments
		///
		/// * `tag` - An integer tag for the sensor.
		/// * `center` - The center point of the polygon.
		/// * `width` - The width of the polygon.
		/// * `height` - The height of the polygon.
		/// * `angle` - Optional. The angle of the polygon.
		public void AttachPolygonSensorWithCenter(int tag, Vec2 center, float width, float height, float angle)
		{
			Native.bodydef_attach_polygon_sensor_with_center(Raw, tag, center.Raw, width, height, angle);
		}
		/// Attaches a polygon sensor fixture definition to the body.
		///
		/// # Arguments
		///
		/// * `tag` - An integer tag for the sensor.
		/// * `vertices` - A vector containing the vertices of the polygon.
		public void AttachPolygonSensorWithVertices(int tag, IEnumerable<Vec2> vertices)
		{
			Native.bodydef_attach_polygon_sensor_with_vertices(Raw, tag, Bridge.FromArray(vertices));
		}
		/// Attaches a disk sensor fixture definition to the body.
		///
		/// # Arguments
		///
		/// * `tag` - An integer tag for the sensor.
		/// * `center` - The center of the disk.
		/// * `radius` - The radius of the disk.
		public void AttachDiskSensorWithCenter(int tag, Vec2 center, float radius)
		{
			Native.bodydef_attach_disk_sensor_with_center(Raw, tag, center.Raw, radius);
		}
		/// Attaches a disk sensor fixture definition to the body.
		///
		/// # Arguments
		///
		/// * `tag` - An integer tag for the sensor.
		/// * `radius` - The radius of the disk.
		public void AttachDiskSensor(int tag, float radius)
		{
			Native.bodydef_attach_disk_sensor(Raw, tag, radius);
		}
		/// Creates a new instance of `BodyDef` class.
		///
		/// # Returns
		///
		/// * A new `BodyDef` object.
		public BodyDef() : this(Native.bodydef_new()) { }
	}
} // namespace Dora
