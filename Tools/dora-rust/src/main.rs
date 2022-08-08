#[macro_use] pub mod dora;
use crate::dora::{Object, Node, INode, Director, Array, App, Group, Entity};

fn main() {
	println!("Hello, world!");
	let mut node = Node::new();
	println!("id: {}", node.get_id());
	println!("x: {}", node.get_x());
	node.set_x(100.5);
	node.set_tag("电风扇");
	println!("x: {}, tag: {}", node.get_position().x, node.get_tag());
	let mut i = 0;
	node.schedule(Box::new(move |dt| {
		i = i + 1;
		println!("{} {}", i, dt);
		i > 30
	}));
	node.slot("Enter", Box::new(|_| {
		println!("Entered!");
	}));
	node.slot("Event", Box::new(|args| {
		println!("MyEvent! {}, {}, {}", args.pop_i32().unwrap(), args.pop_str().unwrap(), args.pop_bool().unwrap());
	}));

	let mut entry = Director::get_entry();
	entry.add_child(&node);

	let children = entry.get_children().unwrap();
	println!("children len: {}", children.get_count());

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
		println!("k: {}, v: {}", keys[i], userdata.get("key123").unwrap().cast::<Array>().unwrap().raw());
	}
	print!("platform: {}\n", App::get_platform());

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
		print!("entity: {}, {}, {}\n", a, b, c);
		e.remove("a");
		e.remove("d");
	}));
}
