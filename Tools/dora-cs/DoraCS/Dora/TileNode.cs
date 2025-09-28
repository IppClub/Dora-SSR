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
		public static extern int32_t tilenode_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void tilenode_set_depth_write(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t tilenode_is_depth_write(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void tilenode_set_blend_func(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t tilenode_get_blend_func(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void tilenode_set_effect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t tilenode_get_effect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void tilenode_set_filter(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t tilenode_get_filter(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t tilenode_get_layer(int64_t self, int64_t layer_name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t tilenode_new(int64_t tmx_file);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t tilenode_with_with_layer(int64_t tmx_file, int64_t layer_name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t tilenode_with_with_layers(int64_t tmx_file, int64_t layer_names);
	}
} // namespace Dora

namespace Dora
{
	/// The TileNode class to render Tilemaps from TMX file in game scene tree hierarchy.
	public partial class TileNode : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.node_type(), From);
		}
		protected TileNode(long raw) : base(raw) { }
		internal static new TileNode From(long raw)
		{
			return new TileNode(raw);
		}
		internal static new TileNode? FromOpt(long raw)
		{
			return raw == 0 ? null : new TileNode(raw);
		}
		/// whether the depth buffer should be written to when rendering the tilemap.
		public bool IsDepthWrite
		{
			set => Native.tilenode_set_depth_write(Raw, value ? 1 : 0);
			get => Native.tilenode_is_depth_write(Raw) != 0;
		}
		/// the blend function for the tilemap.
		public BlendFunc BlendFunc
		{
			set => Native.tilenode_set_blend_func(Raw, value.Raw);
			get => BlendFunc.From(Native.tilenode_get_blend_func(Raw));
		}
		/// the tilemap shader effect.
		public SpriteEffect Effect
		{
			set => Native.tilenode_set_effect(Raw, value.Raw);
			get => SpriteEffect.From(Native.tilenode_get_effect(Raw));
		}
		/// the texture filtering mode for the tilemap.
		public TextureFilter Filter
		{
			set => Native.tilenode_set_filter(Raw, (int)value);
			get => (TextureFilter)Native.tilenode_get_filter(Raw);
		}
		/// Get the layer data by name from the tilemap.
		///
		/// # Arguments
		///
		/// * `layerName` - The name of the layer in the TMX file.
		///
		/// # Returns
		///
		/// * `Dictionary` - The layer data as a dictionary object.
		public Dictionary? GetLayer(string layer_name)
		{
			return Dictionary.FromOpt(Native.tilenode_get_layer(Raw, Bridge.FromString(layer_name)));
		}
		/// Creates a `TileNode` object that will render the tile layers from a TMX file.
		///
		/// # Arguments
		///
		/// * `tmxFile` - The TMX file for the tilemap. This should be a file created with the Tiled Map Editor (http://www.mapeditor.org) and must be in XML format.
		///
		/// # Returns
		///
		/// Returns a new instance of the `TileNode` class. If the tilemap file is not found, it will return `None`.
		public TileNode(string tmx_file) : this(Native.tilenode_new(Bridge.FromString(tmx_file))) { }
		public static TileNode? TryCreate(string tmx_file)
		{
			var raw = Native.tilenode_new(Bridge.FromString(tmx_file));
			return raw == 0 ? null : new TileNode(raw);
		}
		/// Creates a `TileNode` object that will render the specified tile layer from a TMX file.
		///
		/// # Arguments
		///
		/// * `tmxFile` - The TMX file for the tilemap. This should be a file created with the Tiled Map Editor (http://www.mapeditor.org) and must be in XML format.
		/// * `layerName` - The name of the layer in the TMX file.
		///
		/// # Returns
		///
		/// Returns a new instance of the `TileNode` class. If the tilemap file is not found, it will return `None`.
		public TileNode(string tmx_file, string layer_name) : this(Native.tilenode_with_with_layer(Bridge.FromString(tmx_file), Bridge.FromString(layer_name))) { }
		public static TileNode? TryCreate(string tmx_file, string layer_name)
		{
			var raw = Native.tilenode_with_with_layer(Bridge.FromString(tmx_file), Bridge.FromString(layer_name));
			return raw == 0 ? null : new TileNode(raw);
		}
		/// Creates a `TileNode` object that will render the specified tile layers from a TMX file.
		///
		/// # Arguments
		///
		/// * `tmxFile` - The TMX file for the tilemap. This should be a file created with the Tiled Map Editor (http://www.mapeditor.org) and must be in XML format.
		/// * `layerNames` - A vector of names of the layers in the TMX file.
		///
		/// # Returns
		///
		/// Returns a new instance of the `TileNode` class. If the tilemap file is not found, it will return `None`.
		public TileNode(string tmx_file, IEnumerable<string> layer_names) : this(Native.tilenode_with_with_layers(Bridge.FromString(tmx_file), Bridge.FromArray(layer_names))) { }
		public static TileNode? TryCreate(string tmx_file, IEnumerable<string> layer_names)
		{
			var raw = Native.tilenode_with_with_layers(Bridge.FromString(tmx_file), Bridge.FromArray(layer_names));
			return raw == 0 ? null : new TileNode(raw);
		}
	}
} // namespace Dora
