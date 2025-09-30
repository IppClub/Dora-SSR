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
		public static extern int32_t controller__is_button_down(int32_t controllerId, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t controller__is_button_up(int32_t controllerId, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t controller__is_button_pressed(int32_t controllerId, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float controller__get_axis(int32_t controllerId, int64_t name);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// An interface for handling game controller inputs.
	/// </summary>
	public static partial class Controller
	{
		/// <summary>
		/// Checks whether a button on the controller is currently pressed.
		/// </summary>
		/// <param name="controllerId">The ID of the controller to check. Starts from 0.</param>
		/// <param name="name">The name of the button to check.</param>
		/// <returns>`true` if the button is pressed, `false` otherwise.</returns>
		public static bool _IsButtonDown(int controllerId, string name)
		{
			return Native.controller__is_button_down(controllerId, Bridge.FromString(name)) != 0;
		}
		/// <summary>
		/// Checks whether a button on the controller is currently released.
		/// </summary>
		/// <param name="controllerId">The ID of the controller to check. Starts from 0.</param>
		/// <param name="name">The name of the button to check.</param>
		/// <returns>`true` if the button is released, `false` otherwise.</returns>
		public static bool _IsButtonUp(int controllerId, string name)
		{
			return Native.controller__is_button_up(controllerId, Bridge.FromString(name)) != 0;
		}
		/// <summary>
		/// Checks whether a button on the controller is currently being pressed.
		/// </summary>
		/// <param name="controllerId">The ID of the controller to check. Starts from 0.</param>
		/// <param name="name">The name of the button to check.</param>
		/// <returns>`true` if the button is being pressed, `false` otherwise.</returns>
		public static bool _IsButtonPressed(int controllerId, string name)
		{
			return Native.controller__is_button_pressed(controllerId, Bridge.FromString(name)) != 0;
		}
		/// <summary>
		/// Gets the value of an axis on the controller.
		/// </summary>
		/// <param name="controllerId">The ID of the controller to check. Starts from 0.</param>
		/// <param name="name">The name of the axis to check.</param>
		/// <returns>The value of the axis. The value is between -1.0 and 1.0.</returns>
		public static float _GetAxis(int controllerId, string name)
		{
			return Native.controller__get_axis(controllerId, Bridge.FromString(name));
		}
	}
} // namespace Dora
