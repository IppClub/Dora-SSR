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
	node.schedule(Box::new(move |_| {
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
	node.set_touch_enabled(true);
	let paint_clone = paint.clone();
	node.slot(Slot::TAP_BEGAN, Box::new(move |_| {
		*paint_clone.borrow_mut() = dark.clone();
	}));
	let paint_clone = paint.clone();
	node.slot(Slot::TAP_ENDED, Box::new(move |_| {
		*paint_clone.borrow_mut() = light.clone();
	}));
	node.slot(Slot::TAPPED, Box::new(move |_| {
		p!("Clicked!");
	}));
}