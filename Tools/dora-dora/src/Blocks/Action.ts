import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';

const zh = Info.locale.match(/^zh/) !== null;

const actionCategory = {
	kind: 'category',
	name: zh ? '动作' : 'Action',
	categorystyle: 'action_category',
	contents: [] as {kind: string, type: string}[],
};
export default actionCategory;

// 执行动作序列
const actionSequenceBlock = {
	type: 'action_sequence',
	message0: zh ? '为节点 %1 执行动作序列 %2' : 'For node %1 execute action sequence %2',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
	],
};
