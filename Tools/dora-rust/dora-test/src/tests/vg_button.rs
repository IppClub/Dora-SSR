/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

use dora_ssr::*;
use std::{cell::RefCell, rc::Rc};

pub fn test() {
	let mut node = Node::new();
	node.set_size(&Size::new(100.0, 100.0));
	let font_id = Nvg::create_font("sarasa-mono-sc-regular");
	let light = Rc::new(Nvg::linear_gradient(
		0.0, 60.0, 0.0, 0.0,
		&Color::new(0xffffffff),
		&Color::new(0xff00ffff)
	));
	let dark = Rc::new(Nvg::linear_gradient(
		0.0, 60.0, 0.0, 0.0,
		&Color::new(0xffffffff), &Color::new(0xfffbc400)
	));
	let paint = Rc::new(RefCell::new(light.clone()));
	let node_clone = node.clone();
	let paint_clone = paint.clone();
	node.on_render(Box::new(move |_| {
		Nvg::apply_transform(&node_clone);
		Nvg::begin_path();
		Nvg::rounded_rect(0.0, 0.0, 100.0, 100.0, 10.0);
		Nvg::stroke_color(&Color::new(0xffffffff));
		Nvg::stroke_width(5.0);
		Nvg::stroke();
		Nvg::fill_paint(&paint_clone.borrow());
		Nvg::fill();
		Nvg::close_path();
		Nvg::font_face_id(font_id);
		Nvg::font_size(32.0);
		Nvg::fill_color(&Color::new(0xff000000));
		Nvg::scale(1.0, -1.0);
		Nvg::text(50.0, -30.0, "OK");
		false
	}));
	node.perform_def(ActionDef::sequence(&vec![
		ActionDef::prop(1.0, 0.0, 200.0, Property::X, EaseType::Linear),
		ActionDef::prop(1.0, 0.0, 360.0, Property::Angle, EaseType::Linear),
		ActionDef::scale(1.0, 1.0, 4.0, EaseType::Linear)
	]), false);
	let paint_clone = paint.clone();
	Slot::on_tap_began(&mut node, move |_| {
		*paint_clone.borrow_mut() = dark.clone();
	});
	let paint_clone = paint.clone();
	Slot::on_tap_ended(&mut node, move |_| {
		*paint_clone.borrow_mut() = light.clone();
	});
	Slot::on_tapped(&mut node, move |_| {
		p!("Clicked!");
	});
}