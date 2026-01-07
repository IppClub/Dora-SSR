/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn tilenode_type() -> i32;
	fn tilenode_set_depth_write(slf: i64, val: i32);
	fn tilenode_is_depth_write(slf: i64) -> i32;
	fn tilenode_set_blend_func(slf: i64, val: i64);
	fn tilenode_get_blend_func(slf: i64) -> i64;
	fn tilenode_set_effect(slf: i64, val: i64);
	fn tilenode_get_effect(slf: i64) -> i64;
	fn tilenode_set_filter(slf: i64, val: i32);
	fn tilenode_get_filter(slf: i64) -> i32;
	fn tilenode_get_layer(slf: i64, layer_name: i64) -> i64;
	fn tilenode_new(tmx_file: i64) -> i64;
	fn tilenode_with_with_layer(tmx_file: i64, layer_name: i64) -> i64;
	fn tilenode_with_with_layers(tmx_file: i64, layer_names: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for TileNode { }
/// The TileNode class to render Tilemaps from TMX file in game scene tree hierarchy.
pub struct TileNode { raw: i64 }
crate::dora_object!(TileNode);
impl TileNode {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { tilenode_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(TileNode { raw: raw }))
			}
		})
	}
	/// Sets whether the depth buffer should be written to when rendering the tilemap.
	pub fn set_depth_write(&mut self, val: bool) {
		unsafe { tilenode_set_depth_write(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the depth buffer should be written to when rendering the tilemap.
	pub fn is_depth_write(&self) -> bool {
		return unsafe { tilenode_is_depth_write(self.raw()) != 0 };
	}
	/// Sets the blend function for the tilemap.
	pub fn set_blend_func(&mut self, val: crate::dora::BlendFunc) {
		unsafe { tilenode_set_blend_func(self.raw(), val.to_value()) };
	}
	/// Gets the blend function for the tilemap.
	pub fn get_blend_func(&self) -> crate::dora::BlendFunc {
		return unsafe { crate::dora::BlendFunc::from(tilenode_get_blend_func(self.raw())) };
	}
	/// Sets the tilemap shader effect.
	pub fn set_effect(&mut self, val: &crate::dora::SpriteEffect) {
		unsafe { tilenode_set_effect(self.raw(), val.raw()) };
	}
	/// Gets the tilemap shader effect.
	pub fn get_effect(&self) -> crate::dora::SpriteEffect {
		return unsafe { crate::dora::SpriteEffect::from(tilenode_get_effect(self.raw())).unwrap() };
	}
	/// Sets the texture filtering mode for the tilemap.
	pub fn set_filter(&mut self, val: crate::dora::TextureFilter) {
		unsafe { tilenode_set_filter(self.raw(), val as i32) };
	}
	/// Gets the texture filtering mode for the tilemap.
	pub fn get_filter(&self) -> crate::dora::TextureFilter {
		return unsafe { core::mem::transmute(tilenode_get_filter(self.raw())) };
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
	pub fn get_layer(&self, layer_name: &str) -> Option<crate::dora::Dictionary> {
		unsafe { return crate::dora::Dictionary::from(tilenode_get_layer(self.raw(), crate::dora::from_string(layer_name))); }
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
	pub fn new(tmx_file: &str) -> Option<TileNode> {
		unsafe { return TileNode::from(tilenode_new(crate::dora::from_string(tmx_file))); }
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
	pub fn with_with_layer(tmx_file: &str, layer_name: &str) -> Option<TileNode> {
		unsafe { return TileNode::from(tilenode_with_with_layer(crate::dora::from_string(tmx_file), crate::dora::from_string(layer_name))); }
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
	pub fn with_with_layers(tmx_file: &str, layer_names: &Vec<&str>) -> Option<TileNode> {
		unsafe { return TileNode::from(tilenode_with_with_layers(crate::dora::from_string(tmx_file), crate::dora::Vector::from_str(layer_names))); }
	}
}