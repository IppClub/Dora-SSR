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
		public static extern void content_set_search_paths(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_search_paths();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_set_asset_path(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_asset_path();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_set_writable_path(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_writable_path();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_app_path();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_save(int64_t filename, int64_t content);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_exist(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_mkdir(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_isdir(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_is_absolute_path(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_copy(int64_t src, int64_t dst);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_move_to(int64_t src, int64_t dst);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t content_remove(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_full_path(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_add_search_path(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_insert_search_path(int32_t index, int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_remove_search_path(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_clear_path_cache();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_dirs(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_files(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_get_all_files(int64_t path);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_load_async(int64_t filename, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_copy_async(int64_t srcFile, int64_t targetFile, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_save_async(int64_t filename, int64_t content, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_zip_async(int64_t folderPath, int64_t zipFile, int32_t func0, int64_t stack0, int32_t func1, int64_t stack1);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_unzip_async(int64_t zipFile, int64_t folderPath, int32_t func0, int64_t stack0, int32_t func1, int64_t stack1);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_load_excel(int64_t filename);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// The `Content` is a static struct that manages file searching,
	/// </summary>
	/// <summary>
	/// loading and other operations related to resources.
	/// </summary>
	public static partial class Content
	{
		/// <summary>
		/// An array of directories to search for resource files.
		/// </summary>
		public static string[] SearchPaths
		{
			set => Native.content_set_search_paths(Bridge.FromArray(value));
			get => Bridge.ToStringArray(Native.content_get_search_paths());
		}
		/// <summary>
		/// The path to the directory containing read-only resources. Can only be altered by the user on platform Windows, MacOS and Linux.
		/// </summary>
		public static string AssetPath
		{
			set => Native.content_set_asset_path(Bridge.FromString(value));
			get => Bridge.ToString(Native.content_get_asset_path());
		}
		/// <summary>
		/// The path to the directory where files can be written. Can only be altered by the user on platform Windows, MacOS and Linux. Default is the same as `appPath`.
		/// </summary>
		public static string WritablePath
		{
			set => Native.content_set_writable_path(Bridge.FromString(value));
			get => Bridge.ToString(Native.content_get_writable_path());
		}
		/// <summary>
		/// The path to the directory for the application storage.
		/// </summary>
		public static string AppPath
		{
			get => Bridge.ToString(Native.content_get_app_path());
		}
		/// <summary>
		/// Saves the specified content to a file with the specified filename.
		/// </summary>
		/// <param name="filename">The name of the file to save.</param>
		/// <param name="content">The content to save to the file.</param>
		/// <returns>`true` if the content saves to file successfully, `false` otherwise.</returns>
		public static bool Save(string filename, string content)
		{
			return Native.content_save(Bridge.FromString(filename), Bridge.FromString(content)) != 0;
		}
		/// <summary>
		/// Checks if a file with the specified filename exists.
		/// </summary>
		/// <param name="filename">The name of the file to check.</param>
		/// <returns>`true` if the file exists, `false` otherwise.</returns>
		public static bool Exist(string filename)
		{
			return Native.content_exist(Bridge.FromString(filename)) != 0;
		}
		/// <summary>
		/// Creates a new directory with the specified path.
		/// </summary>
		/// <param name="path">The path of the directory to create.</param>
		/// <returns>`true` if the directory was created, `false` otherwise.</returns>
		public static bool Mkdir(string path)
		{
			return Native.content_mkdir(Bridge.FromString(path)) != 0;
		}
		/// <summary>
		/// Checks if the specified path is a directory.
		/// </summary>
		/// <param name="path">The path to check.</param>
		/// <returns>`true` if the path is a directory, `false` otherwise.</returns>
		public static bool Isdir(string path)
		{
			return Native.content_isdir(Bridge.FromString(path)) != 0;
		}
		/// <summary>
		/// Checks if the specified path is an absolute path.
		/// </summary>
		/// <param name="path">The path to check.</param>
		/// <returns>`true` if the path is an absolute path, `false` otherwise.</returns>
		public static bool IsAbsolutePath(string path)
		{
			return Native.content_is_absolute_path(Bridge.FromString(path)) != 0;
		}
		/// <summary>
		/// Copies the file or directory at the specified source path to the target path.
		/// </summary>
		/// <param name="src">The path of the file or directory to copy.</param>
		/// <param name="dst">The path to copy the file or directory to.</param>
		/// <returns>`true` if the file or directory was successfully copied to the target path, `false` otherwise.</returns>
		public static bool Copy(string src, string dst)
		{
			return Native.content_copy(Bridge.FromString(src), Bridge.FromString(dst)) != 0;
		}
		/// <summary>
		/// Moves the file or directory at the specified source path to the target path.
		/// </summary>
		/// <param name="src">The path of the file or directory to move.</param>
		/// <param name="dst">The path to move the file or directory to.</param>
		/// <returns>`true` if the file or directory was successfully moved to the target path, `false` otherwise.</returns>
		public static bool MoveTo(string src, string dst)
		{
			return Native.content_move_to(Bridge.FromString(src), Bridge.FromString(dst)) != 0;
		}
		/// <summary>
		/// Removes the file or directory at the specified path.
		/// </summary>
		/// <param name="path">The path of the file or directory to remove.</param>
		/// <returns>`true` if the file or directory was successfully removed, `false` otherwise.</returns>
		public static bool Remove(string path)
		{
			return Native.content_remove(Bridge.FromString(path)) != 0;
		}
		/// <summary>
		/// Gets the full path of a file with the specified filename.
		/// </summary>
		/// <param name="filename">The name of the file to get the full path of.</param>
		/// <returns>The full path of the file.</returns>
		public static string GetFullPath(string filename)
		{
			return Bridge.ToString(Native.content_get_full_path(Bridge.FromString(filename)));
		}
		/// <summary>
		/// Adds a new search path to the end of the list.
		/// </summary>
		/// <param name="path">The search path to add.</param>
		public static void AddSearchPath(string path)
		{
			Native.content_add_search_path(Bridge.FromString(path));
		}
		/// <summary>
		/// Inserts a search path at the specified index.
		/// </summary>
		/// <param name="index">The index at which to insert the search path.</param>
		/// <param name="path">The search path to insert.</param>
		public static void InsertSearchPath(int index, string path)
		{
			Native.content_insert_search_path(index, Bridge.FromString(path));
		}
		/// <summary>
		/// Removes the specified search path from the list.
		/// </summary>
		/// <param name="path">The search path to remove.</param>
		public static void RemoveSearchPath(string path)
		{
			Native.content_remove_search_path(Bridge.FromString(path));
		}
		/// <summary>
		/// Clears the search path cache of the map of relative paths to full paths.
		/// </summary>
		public static void ClearPathCache()
		{
			Native.content_clear_path_cache();
		}
		/// <summary>
		/// Gets the names of all subdirectories in the specified directory.
		/// </summary>
		/// <param name="path">The path of the directory to search.</param>
		/// <returns>An array of the names of all subdirectories in the specified directory.</returns>
		public static string[] GetDirs(string path)
		{
			return Bridge.ToStringArray(Native.content_get_dirs(Bridge.FromString(path)));
		}
		/// <summary>
		/// Gets the names of all files in the specified directory.
		/// </summary>
		/// <param name="path">The path of the directory to search.</param>
		/// <returns>An array of the names of all files in the specified directory.</returns>
		public static string[] GetFiles(string path)
		{
			return Bridge.ToStringArray(Native.content_get_files(Bridge.FromString(path)));
		}
		/// <summary>
		/// Gets the names of all files in the specified directory and its subdirectories.
		/// </summary>
		/// <param name="path">The path of the directory to search.</param>
		/// <returns>An array of the names of all files in the specified directory and its subdirectories.</returns>
		public static string[] GetAllFiles(string path)
		{
			return Bridge.ToStringArray(Native.content_get_all_files(Bridge.FromString(path)));
		}
		/// <summary>
		/// Asynchronously loads the content of the file with the specified filename.
		/// </summary>
		/// <param name="filename">The name of the file to load.</param>
		/// <param name="callback">The function to call with the content of the file once it is loaded.</param>
		/// <returns>The content of the loaded file.</returns>
		public static void LoadAsync(string filename, System.Action<string> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(stack0.PopString());
			});
			Native.content_load_async(Bridge.FromString(filename), func_id0, stack_raw0);
		}
		/// <summary>
		/// Asynchronously copies a file or a folder from the source path to the destination path.
		/// </summary>
		/// <param name="srcFile">The path of the file or folder to copy.</param>
		/// <param name="targetFile">The destination path of the copied files.</param>
		/// <param name="callback">The function to call with a boolean indicating whether the file or folder was copied successfully.</param>
		/// <returns>`true` if the file or folder was copied successfully, `false` otherwise.</returns>
		public static void CopyAsync(string srcFile, string targetFile, System.Action<bool> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(stack0.PopBool());
			});
			Native.content_copy_async(Bridge.FromString(srcFile), Bridge.FromString(targetFile), func_id0, stack_raw0);
		}
		/// <summary>
		/// Asynchronously saves the specified content to a file with the specified filename.
		/// </summary>
		/// <param name="filename">The name of the file to save.</param>
		/// <param name="content">The content to save to the file.</param>
		/// <param name="callback">The function to call with a boolean indicating whether the content was saved successfully.</param>
		/// <returns>`true` if the content was saved successfully, `false` otherwise.</returns>
		public static void SaveAsync(string filename, string content, System.Action<bool> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(stack0.PopBool());
			});
			Native.content_save_async(Bridge.FromString(filename), Bridge.FromString(content), func_id0, stack_raw0);
		}
		/// <summary>
		/// Asynchronously compresses the specified folder to a ZIP archive with the specified filename.
		/// </summary>
		/// <param name="folderPath">The path of the folder to compress, should be under the asset writable path.</param>
		/// <param name="zipFile">The name of the ZIP archive to create.</param>
		/// <param name="filter">An optional function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.</param>
		/// <param name="callback">The function to call with a boolean indicating whether the folder was compressed successfully.</param>
		/// <returns>`true` if the folder was compressed successfully, `false` otherwise.</returns>
		public static void ZipAsync(string folderPath, string zipFile, Func<string, bool> filter, System.Action<bool> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = filter(stack0.PopString());
				stack0.Push(result);
			});
			var stack1 = new CallStack();
			var stack_raw1 = stack1.Raw;
			var func_id1 = Bridge.PushFunction(() =>
			{
				callback(stack1.PopBool());
			});
			Native.content_zip_async(Bridge.FromString(folderPath), Bridge.FromString(zipFile), func_id0, stack_raw0, func_id1, stack_raw1);
		}
		/// <summary>
		/// Asynchronously decompresses a ZIP archive to the specified folder.
		/// </summary>
		/// <param name="zipFile">The name of the ZIP archive to decompress, should be a file under the asset writable path.</param>
		/// <param name="folderPath">The path of the folder to decompress to, should be under the asset writable path.</param>
		/// <param name="filter">An optional function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.</param>
		/// <param name="callback">The function to call with a boolean indicating whether the archive was decompressed successfully.</param>
		/// <returns>`true` if the folder was decompressed successfully, `false` otherwise.</returns>
		public static void UnzipAsync(string zipFile, string folderPath, Func<string, bool> filter, System.Action<bool> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = filter(stack0.PopString());
				stack0.Push(result);
			});
			var stack1 = new CallStack();
			var stack_raw1 = stack1.Raw;
			var func_id1 = Bridge.PushFunction(() =>
			{
				callback(stack1.PopBool());
			});
			Native.content_unzip_async(Bridge.FromString(zipFile), Bridge.FromString(folderPath), func_id0, stack_raw0, func_id1, stack_raw1);
		}
		public static WorkBook LoadExcel(string filename)
		{
			return WorkBook.From(Native.content_load_excel(Bridge.FromString(filename)));
		}
	}
} // namespace Dora
