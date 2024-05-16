// @preview-file off
import {AlignNode} from 'Dora';

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
