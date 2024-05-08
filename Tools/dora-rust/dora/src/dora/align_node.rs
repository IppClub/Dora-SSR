/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn alignnode_type() -> i32;
	fn alignnode_css(slf: i64, style: i64);
	fn alignnode_new(is_window_root: i32) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for AlignNode { }
/// A node used for aligning layout elements.
pub struct AlignNode { raw: i64 }
crate::dora_object!(AlignNode);
impl AlignNode {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { alignnode_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(AlignNode { raw: raw }))
			}
		})
	}
	/// Sets the layout style of the node.
	///
	/// # Arguments
	///
	/// * `style` - The layout style to set.
	/// The following properties can be set through a CSS style string:
	/// ## Layout direction and alignment
	/// * direction: Sets the direction (ltr, rtl, inherit).
	/// * align-items, align-self, align-content: Sets the alignment of different items (flex-start, center, stretch, flex-end, auto).
	/// * flex-direction: Sets the layout direction (column, row, column-reverse, row-reverse).
	/// * justify-content: Sets the arrangement of child items (flex-start, center, flex-end, space-between, space-around, space-evenly).
	/// ## Flex properties
	/// * flex: Sets the overall size of the flex container.
	/// * flex-grow: Sets the flex growth value.
	/// * flex-shrink: Sets the flex shrink value.
	/// * flex-wrap: Sets whether to wrap (nowrap, wrap, wrap-reverse).
	/// * flex-basis: Sets the flex basis value or percentage.
	/// ## Margins and dimensions
	/// * margin: Can be set by a single value or multiple values separated by commas, percentages or auto for each side.
	/// * margin-top, margin-right, margin-bottom, margin-left, margin-start, margin-end: Sets the margin values, percentages or auto.
	/// * padding: Can be set by a single value or multiple values separated by commas or percentages for each side.
	/// * padding-top, padding-right, padding-bottom, padding-left: Sets the padding values or percentages.
	/// * border: Can be set by a single value or multiple values separated by commas for each side.
	/// * width, height, min-width, min-height, max-width, max-height: Sets the dimension values or percentage properties.
	/// ## Positioning
	/// * top, right, bottom, left, start, end, horizontal, vertical: Sets the positioning property values or percentages.
	/// ## Other properties
	/// * position: Sets the positioning type (absolute, relative, static).
	/// * overflow: Sets the overflow property (visible, hidden, scroll).
	/// * display: Controls whether to display (flex, none).
	pub fn css(&mut self, style: &str) {
		unsafe { alignnode_css(self.raw(), crate::dora::from_string(style)); }
	}
	/// Creates a new AlignNode object.
	///
	/// # Arguments
	///
	/// * `isWindowRoot` - Whether the node is a window root node. A window root node will automatically listen for window size change events and update the layout accordingly.
	pub fn new(is_window_root: bool) -> AlignNode {
		unsafe { return AlignNode { raw: alignnode_new(if is_window_root { 1 } else { 0 }) }; }
	}
}