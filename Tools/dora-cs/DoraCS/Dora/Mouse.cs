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
		public static extern int64_t mouse_get_position();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t mouse_is_left_button_pressed();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t mouse_is_right_button_pressed();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t mouse_is_middle_button_pressed();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t mouse_get_wheel();
	}
} // namespace Dora

namespace Dora
{
	/// An interface for handling mouse inputs.
	public static partial class Mouse
	{
		/// The position of the mouse in the visible window.
		/// You can use `Mouse::get_position() * App::get_device_pixel_ratio()` to get the coordinate in the game world.
		/// Then use `node.convertToNodeSpace()` to convert the world coordinate to the local coordinate of the node.
		///
		/// # Example
		///
		/// ```
		/// let worldPos = Mouse::get_position() * App::get_device_pixel_ratio();
		/// let nodePos = node.convert_to_node_space(&worldPos);
		/// ```
		public static Vec2 GetPosition()
		{
			return Vec2.From(Native.mouse_get_position());
		}
		/// Whether the left mouse button is currently being pressed.
		public static bool IsLeftButtonPressed()
		{
			return Native.mouse_is_left_button_pressed() != 0;
		}
		/// Whether the right mouse button is currently being pressed.
		public static bool IsRightButtonPressed()
		{
			return Native.mouse_is_right_button_pressed() != 0;
		}
		/// Whether the middle mouse button is currently being pressed.
		public static bool IsMiddleButtonPressed()
		{
			return Native.mouse_is_middle_button_pressed() != 0;
		}
		/// Gets the mouse wheel value.
		public static Vec2 GetWheel()
		{
			return Vec2.From(Native.mouse_get_wheel());
		}
	}
} // namespace Dora
