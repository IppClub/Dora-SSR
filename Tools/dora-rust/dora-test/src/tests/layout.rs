use dora_ssr::*;

/*
const root = AlignNode(true);
root.showDebug = true;

const node1 = AlignNode();
node1.css(`
	height: 250;
	margin: 10;
	padding: 10;
	align-items: flex-start;
	flex-wrap: wrap;
`);
node1.showDebug = true;
node1.addTo(root);

for (let _ of $range(1, 10)) {
	const node = AlignNode();
	node.css(`margin: 5; height: 50; width: 50;`);
	node.showDebug = true;
	node.addTo(node1);
}
*/

pub fn test() {
	let mut root = AlignNode::new(true);
	root.set_show_debug(true);

	let mut node1 = AlignNode::new(false);
	node1.css(r#"
		height: 250;
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