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
		public static extern int64_t shadercompiler_compile(int64_t sourceFile, int64_t targetFile, int32_t stage);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void shadercompiler_compile_async(int64_t sourceFile, int64_t targetFile, int32_t stage, int32_t func0, int64_t stack0);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A singleton interface for compiling shader source files into binary shader files.
	/// </summary>
	public static partial class Shader
	{
		/// <summary>
		/// Compiles a shader source file and writes the compiled bytecode to the target file.
		/// </summary>
		/// <param name="sourceFile">The shader source file path.</param>
		/// <param name="targetFile">The output file path for the compiled shader bytecode. Use the <c>.bin</c> suffix.</param>
		/// <param name="stage">The shader stage.</param>
		/// <returns>An empty string on success, or an error message on failure.</returns>
		public static string Compile(string sourceFile, string targetFile, ShaderStage stage)
		{
			return Bridge.ToString(Native.shadercompiler_compile(Bridge.FromString(sourceFile), Bridge.FromString(targetFile), (int)stage));
		}
		/// <summary>
		/// Compiles a shader source file asynchronously and writes the compiled bytecode to the target file.
		/// </summary>
		/// <param name="sourceFile">The shader source file path.</param>
		/// <param name="targetFile">The output file path for the compiled shader bytecode. Use the <c>.bin</c> suffix.</param>
		/// <param name="stage">The shader stage.</param>
		/// <param name="callback">A callback function invoked when the compilation finishes. It receives an empty string on success, or an error message on failure.</param>
		public static void CompileAsync(string sourceFile, string targetFile, ShaderStage stage, System.Action<string> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(stack0.PopString());
			});
			Native.shadercompiler_compile_async(Bridge.FromString(sourceFile), Bridge.FromString(targetFile), (int)stage, func_id0, stack_raw0);
		}
	}
} // namespace Dora
