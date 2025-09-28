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
		public static extern int32_t keyboard__is_key_down(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t keyboard__is_key_up(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t keyboard__is_key_pressed(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void keyboard_update_ime_pos_hint(int64_t win_pos);
	}
} // namespace Dora

namespace Dora
{
	/// An interface for handling keyboard inputs.
	public static partial class Keyboard
	{
		/// Checks whether a key is currently pressed.
		///
		/// # Arguments
		///
		/// * `name` - The name of the key to check.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the key is pressed, `false` otherwise.
		public static bool _IsKeyDown(string name)
		{
			return Native.keyboard__is_key_down(Bridge.FromString(name)) != 0;
		}
		/// Checks whether a key is currently released.
		///
		/// # Arguments
		///
		/// * `name` - The name of the key to check.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the key is released, `false` otherwise.
		public static bool _IsKeyUp(string name)
		{
			return Native.keyboard__is_key_up(Bridge.FromString(name)) != 0;
		}
		/// Checks whether a key is currently being pressed.
		///
		/// # Arguments
		///
		/// * `name` - The name of the key to check.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the key is being pressed, `false` otherwise.
		public static bool _IsKeyPressed(string name)
		{
			return Native.keyboard__is_key_pressed(Bridge.FromString(name)) != 0;
		}
		/// Updates the input method editor (IME) position hint.
		///
		/// # Arguments
		///
		/// * `win_pos` - The position of the keyboard window.
		public static void UpdateImePosHint(Vec2 win_pos)
		{
			Native.keyboard_update_ime_pos_hint(win_pos.Raw);
		}
	}
} // namespace Dora
