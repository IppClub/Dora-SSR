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
		public static extern int32_t sensor_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sensor_set_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sensor_is_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sensor_get_tag(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sensor_get_owner(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sensor_is_sensed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sensor_get_sensed_bodies(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sensor_contains(int64_t self, int64_t body);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct to represent a physics sensor object in the game world.
	/// </summary>
	public partial class Sensor : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.sensor_type(), From);
		}
		protected Sensor(long raw) : base(raw) { }
		internal static new Sensor From(long raw)
		{
			return new Sensor(raw);
		}
		internal static new Sensor? FromOpt(long raw)
		{
			return raw == 0 ? null : new Sensor(raw);
		}
		/// <summary>
		/// Whether the sensor is currently enabled or not.
		/// </summary>
		public bool IsEnabled
		{
			set => Native.sensor_set_enabled(Raw, value ? 1 : 0);
			get => Native.sensor_is_enabled(Raw) != 0;
		}
		/// <summary>
		/// The tag for the sensor.
		/// </summary>
		public int Tag
		{
			get => Native.sensor_get_tag(Raw);
		}
		/// <summary>
		/// The "Body" object that owns the sensor.
		/// </summary>
		public Body Owner
		{
			get => Body.From(Native.sensor_get_owner(Raw));
		}
		/// <summary>
		/// Whether the sensor is currently sensing any other "Body" objects in the game world.
		/// </summary>
		public bool IsSensed
		{
			get => Native.sensor_is_sensed(Raw) != 0;
		}
		/// <summary>
		/// The array of "Body" objects that are currently being sensed by the sensor.
		/// </summary>
		public Array SensedBodies
		{
			get => Array.From(Native.sensor_get_sensed_bodies(Raw));
		}
		/// <summary>
		/// Determines whether the specified `Body` object is currently being sensed by the sensor.
		/// </summary>
		/// <param name="body">The `Body` object to check if it is being sensed.</param>
		/// <returns>`true` if the `Body` object is being sensed by the sensor, `false` otherwise.</returns>
		public bool Contains(Body body)
		{
			return Native.sensor_contains(Raw, body.Raw) != 0;
		}
	}
} // namespace Dora
