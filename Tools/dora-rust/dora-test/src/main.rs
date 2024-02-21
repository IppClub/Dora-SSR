use dora_ssr::*;

fn main() {
	platformer::UnitAction::add(
		"action",
		1,
		0.1,
		0.2,
		true,
		Box::new(|_unit, _action| {
			true
		}),
		Box::new(|_unit, _action| {
			platformer::ActionUpdate::new(Box::new(|_unit, _action, _dt| {
				true
			}))
		}),
		Box::new(|_unit, _action| {
		})
	);
	p!("Hello, world!");
	let mut node = Node::new();
	p!("id: {}", node.get_id());
	p!("x: {}", node.get_x());
	node.set_x(100.5);
	node.set_tag("电风扇");
	p!("x: {}, tag: {}", node.get_position().x, node.get_tag());
	let mut i = 0;
	node.schedule(Box::new(move |dt| {
		i = i + 1;
		p!("{} {}", i, dt);
		i > 30
	}));
	node.slot("Enter", Box::new(|_| {
		p!("Entered!");
	}));
	node.slot("Event", Box::new(|args| {
		p!("MyEvent! {}, {}, {}", args.pop_i32().unwrap(), args.pop_str().unwrap(), args.pop_bool().unwrap());
	}));
	node.perform(&Action::spawn(&vec![
		Action::sequence(&vec![
			Action::delay(3.0),
			Action::event("End", "3 seconds later!")
		]),
		Action::prop(1.0, 0.0, 233.0, Property::X, EaseType::InBack)
	]));
	node.slot("End", Box::new(|args| {
		let n = args.pop_cast::<Node>().unwrap();
		p!("{} {}", args.pop_str().unwrap(), n.get_x());
	}));

	let mut entry = Director::get_entry();
	entry.add_child(&node);

	let children = entry.get_children().unwrap();
	p!("children len: {}", children.get_count());

	node.emit("Event", args!(1, "dsd", true));

	let mut arr = Array::new();
	arr.add(node.obj());
	if let Some(mut a) = arr.get(0).unwrap().cast::<Node>() {
		a.emit("Event", args!(2, "xyz", false));
	}

	let mut userdata = node.get_data();
	userdata.set("key123", arr.obj());
	let keys = userdata.get_keys();
	for i in 0 .. keys.len() {
		p!("k: {}, v: {}", keys[i], userdata.get("key123").unwrap().cast::<Array>().unwrap().raw());
	}
	p!("platform: {}", App::get_platform());

	let mut entity = Entity::new();
	entity.set("a", 123);
	entity.set("b", false);
	entity.set("c", 1.2);
	let mut group = Group::new(&vec!["a", "b", "c"]);
	if let Some(mut target) = group.find(Box::new(|e| {
		!e.get("b").unwrap().into_bool().unwrap()
	})) {
		target.set("d", "value");
	}
	group.watch(Box::new(|args| {
		let mut e = args.pop_cast::<Entity>().unwrap();
		let a = args.pop_i32().unwrap();
		let b = args.pop_bool().unwrap();
		let c = args.pop_f64().unwrap();
		p!("entity: {}, {}, {}", a, b, c);
		e.remove("a");
		e.remove("d");
		return false;
	}));
}
