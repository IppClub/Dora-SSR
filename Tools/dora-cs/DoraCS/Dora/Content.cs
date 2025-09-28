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
		public static extern void content_copy_async(int64_t src_file, int64_t target_file, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_save_async(int64_t filename, int64_t content, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_zip_async(int64_t folder_path, int64_t zip_file, int32_t func0, int64_t stack0, int32_t func1, int64_t stack1);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void content_unzip_async(int64_t zip_file, int64_t folder_path, int32_t func0, int64_t stack0, int32_t func1, int64_t stack1);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t content_load_excel(int64_t filename);
	}
} // namespace Dora

namespace Dora
{
	/// The `Content` is a static struct that manages file searching,
	/// loading and other operations related to resources.
	public static partial class Content
	{
		/// an array of directories to search for resource files.
		public static string[] SearchPaths
		{
			set => Native.content_set_search_paths(Bridge.FromArray(value));
			get => Bridge.ToStringArray(Native.content_get_search_paths());
		}
		/// the path to the directory containing read-only resources. Can only be altered by the user on platform Windows, MacOS and Linux.
		public static string AssetPath
		{
			set => Native.content_set_asset_path(Bridge.FromString(value));
			get => Bridge.ToString(Native.content_get_asset_path());
		}
		/// the path to the directory where files can be written. Can only be altered by the user on platform Windows, MacOS and Linux. Default is the same as `appPath`.
		public static string WritablePath
		{
			set => Native.content_set_writable_path(Bridge.FromString(value));
			get => Bridge.ToString(Native.content_get_writable_path());
		}
		/// the path to the directory for the application storage.
		public static string AppPath
		{
			get => Bridge.ToString(Native.content_get_app_path());
		}
		/// Saves the specified content to a file with the specified filename.
		///
		/// # Arguments
		///
		/// * `filename` - The name of the file to save.
		/// * `content` - The content to save to the file.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the content saves to file successfully, `false` otherwise.
		public static bool Save(string filename, string content)
		{
			return Native.content_save(Bridge.FromString(filename), Bridge.FromString(content)) != 0;
		}
		/// Checks if a file with the specified filename exists.
		///
		/// # Arguments
		///
		/// * `filename` - The name of the file to check.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the file exists, `false` otherwise.
		public static bool Exist(string filename)
		{
			return Native.content_exist(Bridge.FromString(filename)) != 0;
		}
		/// Creates a new directory with the specified path.
		///
		/// # Arguments
		///
		/// * `path` - The path of the directory to create.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the directory was created, `false` otherwise.
		public static bool Mkdir(string path)
		{
			return Native.content_mkdir(Bridge.FromString(path)) != 0;
		}
		/// Checks if the specified path is a directory.
		///
		/// # Arguments
		///
		/// * `path` - The path to check.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the path is a directory, `false` otherwise.
		public static bool Isdir(string path)
		{
			return Native.content_isdir(Bridge.FromString(path)) != 0;
		}
		/// Checks if the specified path is an absolute path.
		///
		/// # Arguments
		///
		/// * `path` - The path to check.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the path is an absolute path, `false` otherwise.
		public static bool IsAbsolutePath(string path)
		{
			return Native.content_is_absolute_path(Bridge.FromString(path)) != 0;
		}
		/// Copies the file or directory at the specified source path to the target path.
		///
		/// # Arguments
		///
		/// * `src_path` - The path of the file or directory to copy.
		/// * `dst_path` - The path to copy the file or directory to.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the file or directory was successfully copied to the target path, `false` otherwise.
		public static bool Copy(string src, string dst)
		{
			return Native.content_copy(Bridge.FromString(src), Bridge.FromString(dst)) != 0;
		}
		/// Moves the file or directory at the specified source path to the target path.
		///
		/// # Arguments
		///
		/// * `src_path` - The path of the file or directory to move.
		/// * `dst_path` - The path to move the file or directory to.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the file or directory was successfully moved to the target path, `false` otherwise.
		public static bool MoveTo(string src, string dst)
		{
			return Native.content_move_to(Bridge.FromString(src), Bridge.FromString(dst)) != 0;
		}
		/// Removes the file or directory at the specified path.
		///
		/// # Arguments
		///
		/// * `path` - The path of the file or directory to remove.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the file or directory was successfully removed, `false` otherwise.
		public static bool Remove(string path)
		{
			return Native.content_remove(Bridge.FromString(path)) != 0;
		}
		/// Gets the full path of a file with the specified filename.
		///
		/// # Arguments
		///
		/// * `filename` - The name of the file to get the full path of.
		///
		/// # Returns
		///
		/// * `String` - The full path of the file.
		public static string GetFullPath(string filename)
		{
			return Bridge.ToString(Native.content_get_full_path(Bridge.FromString(filename)));
		}
		/// Adds a new search path to the end of the list.
		///
		/// # Arguments
		///
		/// * `path` - The search path to add.
		public static void AddSearchPath(string path)
		{
			Native.content_add_search_path(Bridge.FromString(path));
		}
		/// Inserts a search path at the specified index.
		///
		/// # Arguments
		///
		/// * `index` - The index at which to insert the search path.
		/// * `path` - The search path to insert.
		public static void InsertSearchPath(int index, string path)
		{
			Native.content_insert_search_path(index, Bridge.FromString(path));
		}
		/// Removes the specified search path from the list.
		///
		/// # Arguments
		///
		/// * `path` - The search path to remove.
		public static void RemoveSearchPath(string path)
		{
			Native.content_remove_search_path(Bridge.FromString(path));
		}
		/// Clears the search path cache of the map of relative paths to full paths.
		public static void ClearPathCache()
		{
			Native.content_clear_path_cache();
		}
		/// Gets the names of all subdirectories in the specified directory.
		///
		/// # Arguments
		///
		/// * `path` - The path of the directory to search.
		///
		/// # Returns
		///
		/// * `Vec<String>` - An array of the names of all subdirectories in the specified directory.
		public static string[] GetDirs(string path)
		{
			return Bridge.ToStringArray(Native.content_get_dirs(Bridge.FromString(path)));
		}
		/// Gets the names of all files in the specified directory.
		///
		/// # Arguments
		///
		/// * `path` - The path of the directory to search.
		///
		/// # Returns
		///
		/// * `Vec<String>` - An array of the names of all files in the specified directory.
		public static string[] GetFiles(string path)
		{
			return Bridge.ToStringArray(Native.content_get_files(Bridge.FromString(path)));
		}
		/// Gets the names of all files in the specified directory and its subdirectories.
		///
		/// # Arguments
		///
		/// * `path` - The path of the directory to search.
		///
		/// # Returns
		///
		/// * `Vec<String>` - An array of the names of all files in the specified directory and its subdirectories.
		public static string[] GetAllFiles(string path)
		{
			return Bridge.ToStringArray(Native.content_get_all_files(Bridge.FromString(path)));
		}
		/// Asynchronously loads the content of the file with the specified filename.
		///
		/// # Arguments
		///
		/// * `filename` - The name of the file to load.
		/// * `callback` - The function to call with the content of the file once it is loaded.
		///
		/// # Returns
		///
		/// * `String` - The content of the loaded file.
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
		/// Asynchronously copies a file or a folder from the source path to the destination path.
		///
		/// # Arguments
		///
		/// * `srcFile` - The path of the file or folder to copy.
		/// * `targetFile` - The destination path of the copied files.
		/// * `callback` - The function to call with a boolean indicating whether the file or folder was copied successfully.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the file or folder was copied successfully, `false` otherwise.
		public static void CopyAsync(string src_file, string target_file, System.Action<bool> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(stack0.PopBool());
			});
			Native.content_copy_async(Bridge.FromString(src_file), Bridge.FromString(target_file), func_id0, stack_raw0);
		}
		/// Asynchronously saves the specified content to a file with the specified filename.
		///
		/// # Arguments
		///
		/// * `filename` - The name of the file to save.
		/// * `content` - The content to save to the file.
		/// * `callback` - The function to call with a boolean indicating whether the content was saved successfully.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the content was saved successfully, `false` otherwise.
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
		/// Asynchronously compresses the specified folder to a ZIP archive with the specified filename.
		///
		/// # Arguments
		///
		/// * `folder_path` - The path of the folder to compress, should be under the asset writable path.
		/// * `zip_file` - The name of the ZIP archive to create.
		/// * `filter` - An optional function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.
		/// * `callback` - The function to call with a boolean indicating whether the folder was compressed successfully.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the folder was compressed successfully, `false` otherwise.
		public static void ZipAsync(string folder_path, string zip_file, Func<string, bool> filter, System.Action<bool> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = filter(stack0.PopString());
				stack0.Push(result);;
			});
			var stack1 = new CallStack();
			var stack_raw1 = stack1.Raw;
			var func_id1 = Bridge.PushFunction(() =>
			{
				callback(stack1.PopBool());
			});
			Native.content_zip_async(Bridge.FromString(folder_path), Bridge.FromString(zip_file), func_id0, stack_raw0, func_id1, stack_raw1);
		}
		/// Asynchronously decompresses a ZIP archive to the specified folder.
		///
		/// # Arguments
		///
		/// * `zip_file` - The name of the ZIP archive to decompress, should be a file under the asset writable path.
		/// * `folder_path` - The path of the folder to decompress to, should be under the asset writable path.
		/// * `filter` - An optional function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.
		/// * `callback` - The function to call with a boolean indicating whether the archive was decompressed successfully.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the folder was decompressed successfully, `false` otherwise.
		public static void UnzipAsync(string zip_file, string folder_path, Func<string, bool> filter, System.Action<bool> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = filter(stack0.PopString());
				stack0.Push(result);;
			});
			var stack1 = new CallStack();
			var stack_raw1 = stack1.Raw;
			var func_id1 = Bridge.PushFunction(() =>
			{
				callback(stack1.PopBool());
			});
			Native.content_unzip_async(Bridge.FromString(zip_file), Bridge.FromString(folder_path), func_id0, stack_raw0, func_id1, stack_raw1);
		}
		public static WorkBook LoadExcel(string filename)
		{
			return WorkBook.From(Native.content_load_excel(Bridge.FromString(filename)));
		}
	}
} // namespace Dora
