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
		public static extern int32_t controller__is_button_down(int32_t controller_id, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t controller__is_button_up(int32_t controller_id, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t controller__is_button_pressed(int32_t controller_id, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float controller__get_axis(int32_t controller_id, int64_t name);
	}
} // namespace Dora

namespace Dora
{
	/// An interface for handling game controller inputs.
	public static partial class Controller
	{
		/// Checks whether a button on the controller is currently pressed.
		///
		/// # Arguments
		///
		/// * `controller_id` - The ID of the controller to check. Starts from 0.
		/// * `name` - The name of the button to check.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the button is pressed, `false` otherwise.
		public static bool _IsButtonDown(int controller_id, string name)
		{
			return Native.controller__is_button_down(controller_id, Bridge.FromString(name)) != 0;
		}
		/// Checks whether a button on the controller is currently released.
		///
		/// # Arguments
		///
		/// * `controller_id` - The ID of the controller to check. Starts from 0.
		/// * `name` - The name of the button to check.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the button is released, `false` otherwise.
		public static bool _IsButtonUp(int controller_id, string name)
		{
			return Native.controller__is_button_up(controller_id, Bridge.FromString(name)) != 0;
		}
		/// Checks whether a button on the controller is currently being pressed.
		///
		/// # Arguments
		///
		/// * `controller_id` - The ID of the controller to check. Starts from 0.
		/// * `name` - The name of the button to check.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the button is being pressed, `false` otherwise.
		public static bool _IsButtonPressed(int controller_id, string name)
		{
			return Native.controller__is_button_pressed(controller_id, Bridge.FromString(name)) != 0;
		}
		/// Gets the value of an axis on the controller.
		///
		/// # Arguments
		///
		/// * `controller_id` - The ID of the controller to check. Starts from 0.
		/// * `name` - The name of the axis to check.
		///
		/// # Returns
		///
		/// * `f32` - The value of the axis. The value is between -1.0 and 1.0.
		public static float _GetAxis(int controller_id, string name)
		{
			return Native.controller__get_axis(controller_id, Bridge.FromString(name));
		}
	}
} // namespace Dora
