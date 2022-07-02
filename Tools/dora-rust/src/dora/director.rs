use crate::dora::Node;

extern "C" {
	fn director_get_entry() -> i64;
}

pub struct Director { }

impl Director {
	pub fn get_entry() -> Node {
		Node::from(unsafe { director_get_entry() }).unwrap()
	}
}
