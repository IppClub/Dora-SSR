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
		public static extern void platformer_targetallow_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_targetallow_set_terrain_allowed(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_targetallow_is_terrain_allowed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_targetallow_allow(int64_t self, int32_t relation, int32_t allow);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_targetallow_is_allow(int64_t self, int32_t relation);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_targetallow_to_value(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_targetallow_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_targetallow_with_value(int32_t value);
	}
} // namespace Dora

namespace Dora.Platformer
{
	/// <summary>
	/// A struct to specifies how a bullet object should interact with other game objects or units based on their relationship.
	/// </summary>
	public partial class TargetAllow
	{
		private TargetAllow(long raw)
		{
			if (raw == 0) throw new InvalidOperationException("failed to create TargetAllow");
			Raw = raw;
		}
		~TargetAllow()
		{
			Native.platformer_targetallow_release(Raw);
		}
		internal long Raw { get; private set; }
		internal static TargetAllow From(long raw)
		{
			return new TargetAllow(raw);
		}
		/// <summary>
		/// Whether the bullet object can collide with terrain.
		/// </summary>
		public bool IsTerrainAllowed
		{
			set => Native.platformer_targetallow_set_terrain_allowed(Raw, value ? 1 : 0);
			get => Native.platformer_targetallow_is_terrain_allowed(Raw) != 0;
		}
		/// <summary>
		/// Allows or disallows the bullet object to interact with a game object or unit, based on their relationship.
		/// </summary>
		/// <param name="relation">The relationship between the bullet object and the other game object or unit.</param>
		/// <param name="allow">Whether the bullet object should be allowed to interact.</param>
		public void Allow(Platformer.Relation relation, bool allow)
		{
			Native.platformer_targetallow_allow(Raw, (int)relation, allow ? 1 : 0);
		}
		/// <summary>
		/// Determines whether the bullet object is allowed to interact with a game object or unit, based on their relationship.
		/// </summary>
		/// <param name="relation">The relationship between the bullet object and the other game object or unit.</param>
		/// <returns>Whether the bullet object is allowed to interact.</returns>
		public bool IsAllow(Platformer.Relation relation)
		{
			return Native.platformer_targetallow_is_allow(Raw, (int)relation) != 0;
		}
		/// <summary>
		/// Converts the object to a value that can be used for interaction settings.
		/// </summary>
		/// <returns>The value that can be used for interaction settings.</returns>
		public int ToValue()
		{
			return Native.platformer_targetallow_to_value(Raw);
		}
		/// <summary>
		/// Creates a new TargetAllow object with default settings.
		/// </summary>
		public TargetAllow() : this(Native.platformer_targetallow_new()) { }
		/// <summary>
		/// Creates a new TargetAllow object with the specified value.
		/// </summary>
		/// <param name="value">The value to use for the new TargetAllow object.</param>
		public TargetAllow(int value) : this(Native.platformer_targetallow_with_value(value)) { }
	}
} // namespace Dora.Platformer
