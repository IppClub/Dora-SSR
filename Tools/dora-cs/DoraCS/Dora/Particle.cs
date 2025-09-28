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
		public static extern int32_t particle_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t particlenode_is_active(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void particlenode_start(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void particlenode_stop(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t particlenode_new(int64_t filename);
	}
} // namespace Dora

namespace Dora
{
	/// Represents a particle system node that emits and animates particles.
	public partial class Particle : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.particle_type(), From);
		}
		protected Particle(long raw) : base(raw) { }
		internal static new Particle From(long raw)
		{
			return new Particle(raw);
		}
		internal static new Particle? FromOpt(long raw)
		{
			return raw == 0 ? null : new Particle(raw);
		}
		/// whether the particle system is active.
		public bool IsActive
		{
			get => Native.particlenode_is_active(Raw) != 0;
		}
		/// Starts emitting particles.
		public void Start()
		{
			Native.particlenode_start(Raw);
		}
		/// Stops emitting particles and wait for all active particles to end their lives.
		public void Stop()
		{
			Native.particlenode_stop(Raw);
		}
		/// Creates a new Particle object from a particle system file.
		///
		/// # Arguments
		///
		/// * `filename` - The file path of the particle system file.
		///
		/// # Returns
		///
		/// * A new `Particle` object.
		public Particle(string filename) : this(Native.particlenode_new(Bridge.FromString(filename))) { }
		public static Particle? TryCreate(string filename)
		{
			var raw = Native.particlenode_new(Bridge.FromString(filename));
			return raw == 0 ? null : new Particle(raw);
		}
	}
} // namespace Dora
