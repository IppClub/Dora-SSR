/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

use dora_ssr::*;

pub fn test() {
	let mut root = AlignNode::new(true);
	root.set_show_debug(true);

	let mut node1 = AlignNode::new(false);
	node1.css(r#"
		height: 50%;
		margin: 10;
		padding: 10;
		align-items: flex-start;
		flex-wrap: wrap;
	"#);
	node1.set_show_debug(true);
	node1.add_to(&root);

	for _ in 1..=10 {
		let mut node = AlignNode::new(false);
		node.css(r#"
			margin: 5;
			height: 50;
			width: 50;
		"#);
		node.set_show_debug(true);
		node.add_to(&node1);
	}
}