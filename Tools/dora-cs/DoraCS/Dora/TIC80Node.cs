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
		public static extern int32_t tic80node_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t tic80node_new(int64_t cartFile);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A class that represents a TIC-80 virtual machine node.
	/// </summary>
	public partial class TIC80Node : Sprite
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.tic80node_type(), From);
		}
		protected TIC80Node(long raw) : base(raw) { }
		internal static new TIC80Node From(long raw)
		{
			return new TIC80Node(raw);
		}
		internal static new TIC80Node? FromOpt(long raw)
		{
			return raw == 0 ? null : new TIC80Node(raw);
		}
		/// <summary>
		/// Creates a new TIC80Node object for running a TIC-80 cart.
		/// </summary>
		/// <param name="cartFile">
		/// The path to the TIC-80 cart file. It should be a valid TIC-80 cart file (`.tic` or `.png` format).
		/// <para>
		/// The TIC-80 cart file contains the complete game or program that will run in the TIC-80 virtual machine.<br/>
		/// <b>Supported features:</b><br/>
		/// - Full TIC-80 API support (drawing, sound, input, etc.).<br/>
		/// - Keyboard, controller, and touch input handling.<br/>
		/// - Audio playback through the TIC-80 sound engine.<br/>
		/// - Runs at TIC-80's native resolution (240x136 pixels).<br/>
		/// - Fixed frame rate matching TIC-80's specification (60 FPS).<br/>
		/// </para>
		/// </param>
		/// <returns>
		/// The created TIC80Node instance.
		/// </returns>
		public TIC80Node(string cartFile) : this(Native.tic80node_new(Bridge.FromString(cartFile))) { }
		public static TIC80Node? TryCreate(string cartFile)
		{
			var raw = Native.tic80node_new(Bridge.FromString(cartFile));
			return raw == 0 ? null : new TIC80Node(raw);
		}
	}
} // namespace Dora
