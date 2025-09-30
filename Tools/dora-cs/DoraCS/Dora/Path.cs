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
		public static extern int64_t path_get_ext(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_get_path(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_get_name(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_get_filename(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_get_relative(int64_t path, int64_t target);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_replace_ext(int64_t path, int64_t newExt);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_replace_filename(int64_t path, int64_t newFile);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_concat(int64_t paths);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// Helper struct for file path operations.
	/// </summary>
	public static partial class Path
	{
		/// <summary>
		/// Extracts the file extension from a given file path.
		/// # Example
		/// Input: "/a/b/c.TXT" Output: "txt"
		/// </summary>
		/// <param name="path">The input file path.</param>
		/// <returns>The extension of the input file.</returns>
		public static string GetExt(string path)
		{
			return Bridge.ToString(Native.path_get_ext(Bridge.FromString(path)));
		}
		/// <summary>
		/// Extracts the parent path from a given file path.
		/// # Example
		/// Input: "/a/b/c.TXT" Output: "/a/b"
		/// </summary>
		/// <param name="path">The input file path.</param>
		/// <returns>The parent path of the input file.</returns>
		public static string GetPath(string path)
		{
			return Bridge.ToString(Native.path_get_path(Bridge.FromString(path)));
		}
		/// <summary>
		/// Extracts the file name without extension from a given file path.
		/// # Example
		/// Input: "/a/b/c.TXT" Output: "c"
		/// </summary>
		/// <param name="path">The input file path.</param>
		/// <returns>The name of the input file without extension.</returns>
		public static string GetName(string path)
		{
			return Bridge.ToString(Native.path_get_name(Bridge.FromString(path)));
		}
		/// <summary>
		/// Extracts the file name from a given file path.
		/// # Example
		/// Input: "/a/b/c.TXT" Output: "c.TXT"
		/// </summary>
		/// <param name="path">The input file path.</param>
		/// <returns>The name of the input file.</returns>
		public static string GetFilename(string path)
		{
			return Bridge.ToString(Native.path_get_filename(Bridge.FromString(path)));
		}
		/// <summary>
		/// Computes the relative path from the target file to the input file.
		/// # Example
		/// Input: "/a/b/c.TXT", target: "/a" Output: "b/c.TXT"
		/// </summary>
		/// <param name="path">The input file path.</param>
		/// <param name="target">The target file path.</param>
		/// <returns>The relative path from the input file to the target file.</returns>
		public static string GetRelative(string path, string target)
		{
			return Bridge.ToString(Native.path_get_relative(Bridge.FromString(path), Bridge.FromString(target)));
		}
		/// <summary>
		/// Changes the file extension in a given file path.
		/// # Example
		/// Input: "/a/b/c.TXT", "lua" Output: "/a/b/c.lua"
		/// </summary>
		/// <param name="path">The input file path.</param>
		/// <param name="newExt">The new file extension to replace the old one.</param>
		/// <returns>The new file path.</returns>
		public static string ReplaceExt(string path, string newExt)
		{
			return Bridge.ToString(Native.path_replace_ext(Bridge.FromString(path), Bridge.FromString(newExt)));
		}
		/// <summary>
		/// Changes the filename in a given file path.
		/// # Example
		/// Input: "/a/b/c.TXT", "d" Output: "/a/b/d.TXT"
		/// </summary>
		/// <param name="path">The input file path.</param>
		/// <param name="newFile">The new filename to replace the old one.</param>
		/// <returns>The new file path.</returns>
		public static string ReplaceFilename(string path, string newFile)
		{
			return Bridge.ToString(Native.path_replace_filename(Bridge.FromString(path), Bridge.FromString(newFile)));
		}
		/// <summary>
		/// Joins the given segments into a new file path.
		/// # Example
		/// Input: "a", "b", "c.TXT" Output: "a/b/c.TXT"
		/// </summary>
		/// <param name="segments">The segments to be joined as a new file path.</param>
		/// <returns>The new file path.</returns>
		public static string Concat(IEnumerable<string> paths)
		{
			return Bridge.ToString(Native.path_concat(Bridge.FromArray(paths)));
		}
	}
} // namespace Dora
