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
		public static extern int64_t path_replace_ext(int64_t path, int64_t new_ext);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_replace_filename(int64_t path, int64_t new_file);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t path_concat(int64_t paths);
	}
} // namespace Dora

namespace Dora
{
	/// Helper struct for file path operations.
	public static partial class Path
	{
		/// Extracts the file extension from a given file path.
		///
		/// # Example
		///
		/// Input: "/a/b/c.TXT" Output: "txt"
		///
		/// # Arguments
		///
		/// * `path` - The input file path.
		///
		/// # Returns
		///
		/// * `String` - The extension of the input file.
		public static string GetExt(string path)
		{
			return Bridge.ToString(Native.path_get_ext(Bridge.FromString(path)));
		}
		/// Extracts the parent path from a given file path.
		///
		/// # Example
		///
		/// Input: "/a/b/c.TXT" Output: "/a/b"
		///
		/// # Arguments
		///
		/// * `path` - The input file path.
		///
		/// # Returns
		///
		/// * `String` - The parent path of the input file.
		public static string GetPath(string path)
		{
			return Bridge.ToString(Native.path_get_path(Bridge.FromString(path)));
		}
		/// Extracts the file name without extension from a given file path.
		///
		/// # Example
		///
		/// Input: "/a/b/c.TXT" Output: "c"
		///
		/// # Arguments
		///
		/// * `path` - The input file path.
		///
		/// # Returns
		///
		/// * `String` - The name of the input file without extension.
		public static string GetName(string path)
		{
			return Bridge.ToString(Native.path_get_name(Bridge.FromString(path)));
		}
		/// Extracts the file name from a given file path.
		///
		/// # Example
		///
		/// Input: "/a/b/c.TXT" Output: "c.TXT"
		///
		/// # Arguments
		///
		/// * `path` - The input file path.
		///
		/// # Returns
		///
		/// * `String` - The name of the input file.
		public static string GetFilename(string path)
		{
			return Bridge.ToString(Native.path_get_filename(Bridge.FromString(path)));
		}
		/// Computes the relative path from the target file to the input file.
		///
		/// # Example
		///
		/// Input: "/a/b/c.TXT", base: "/a" Output: "b/c.TXT"
		///
		/// # Arguments
		///
		/// * `path` - The input file path.
		/// * `base` - The target file path.
		///
		/// # Returns
		///
		/// * `String` - The relative path from the input file to the target file.
		public static string GetRelative(string path, string target)
		{
			return Bridge.ToString(Native.path_get_relative(Bridge.FromString(path), Bridge.FromString(target)));
		}
		/// Changes the file extension in a given file path.
		///
		/// # Example
		///
		/// Input: "/a/b/c.TXT", "lua" Output: "/a/b/c.lua"
		///
		/// # Arguments
		///
		/// * `path` - The input file path.
		/// * `new_ext` - The new file extension to replace the old one.
		///
		/// # Returns
		///
		/// * `String` - The new file path.
		public static string ReplaceExt(string path, string new_ext)
		{
			return Bridge.ToString(Native.path_replace_ext(Bridge.FromString(path), Bridge.FromString(new_ext)));
		}
		/// Changes the filename in a given file path.
		///
		/// # Example
		///
		/// Input: "/a/b/c.TXT", "d" Output: "/a/b/d.TXT"
		///
		/// # Arguments
		///
		/// * `path` - The input file path.
		/// * `new_file` - The new filename to replace the old one.
		///
		/// # Returns
		///
		/// * `String` - The new file path.
		public static string ReplaceFilename(string path, string new_file)
		{
			return Bridge.ToString(Native.path_replace_filename(Bridge.FromString(path), Bridge.FromString(new_file)));
		}
		/// Joins the given segments into a new file path.
		///
		/// # Example
		///
		/// Input: "a", "b", "c.TXT" Output: "a/b/c.TXT"
		///
		/// # Arguments
		///
		/// * `segments` - The segments to be joined as a new file path.
		///
		/// # Returns
		///
		/// * `String` - The new file path.
		public static string Concat(IEnumerable<string> paths)
		{
			return Bridge.ToString(Native.path_concat(Bridge.FromArray(paths)));
		}
	}
} // namespace Dora
