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
		public static extern int32_t cache_load(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void cache_load_async(int64_t filename, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void cache_update_item(int64_t filename, int64_t content);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void cache_update_texture(int64_t filename, int64_t texture);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t cache_unload_item_or_type(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void cache_unload();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void cache_remove_unused();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void cache_remove_unused_by_type(int64_t type_name);
	}
} // namespace Dora

namespace Dora
{
	/// A interface for managing various game resources.
	public static partial class Cache
	{
		/// Loads a file into the cache with a blocking operation.
		///
		/// # Arguments
		///
		/// * `filename` - The name of the file to load.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the file was loaded successfully, `false` otherwise.
		public static bool Load(string filename)
		{
			return Native.cache_load(Bridge.FromString(filename)) != 0;
		}
		/// Loads a file into the cache asynchronously.
		///
		/// # Arguments
		///
		/// * `filenames` - The name of the file(s) to load. This can be a single string or a vector of strings.
		/// * `handler` - A callback function that is invoked when the file is loaded.
		public static void LoadAsync(string filename, Action<bool> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				handler(stack0.PopBool());
			});
			Native.cache_load_async(Bridge.FromString(filename), func_id0, stack_raw0);
		}
		/// Updates the content of a file loaded in the cache.
		/// If the item of filename does not exist in the cache, a new file content will be added into the cache.
		///
		/// # Arguments
		///
		/// * `filename` - The name of the file to update.
		/// * `content` - The new content for the file.
		public static void UpdateItem(string filename, string content)
		{
			Native.cache_update_item(Bridge.FromString(filename), Bridge.FromString(content));
		}
		/// Updates the texture object of the specific filename loaded in the cache.
		/// If the texture object of filename does not exist in the cache, it will be added into the cache.
		///
		/// # Arguments
		///
		/// * `filename` - The name of the texture to update.
		/// * `texture` - The new texture object for the file.
		public static void UpdateTexture(string filename, Texture2D texture)
		{
			Native.cache_update_texture(Bridge.FromString(filename), texture.Raw);
		}
		/// Unloads a resource from the cache.
		///
		/// # Arguments
		///
		/// * `name` - The type name of resource to unload, could be one of "Texture", "SVG", "Clip", "Frame", "Model", "Particle", "Shader", "Font", "Sound", "Spine". Or the name of the resource file to unload.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the resource was unloaded successfully, `false` otherwise.
		public static bool UnloadItemOrType(string name)
		{
			return Native.cache_unload_item_or_type(Bridge.FromString(name)) != 0;
		}
		/// Unloads all resources from the cache.
		public static void Unload()
		{
			Native.cache_unload();
		}
		/// Removes all unused resources (not being referenced) from the cache.
		public static void RemoveUnused()
		{
			Native.cache_remove_unused();
		}
		/// Removes all unused resources of the given type from the cache.
		///
		/// # Arguments
		///
		/// * `resource_type` - The type of resource to remove. This could be one of "Texture", "SVG", "Clip", "Frame", "Model", "Particle", "Shader", "Font", "Sound", "Spine".
		public static void RemoveUnusedByType(string type_name)
		{
			Native.cache_remove_unused_by_type(Bridge.FromString(type_name));
		}
	}
} // namespace Dora
