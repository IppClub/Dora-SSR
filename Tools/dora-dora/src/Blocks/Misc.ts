import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';
import { ArgBlock, ArgContainerBlock } from './Event';

const zh = Info.locale.match(/^zh/) !== null;

const miscCategory = {
	kind: 'category',
	name: zh ? '杂项' : 'Misc',
	categorystyle: 'colour_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
};
export default miscCategory;

// print
const printBlock = {
	type: 'print_block',
	message0: zh ? '打印 %1' : 'Print %1',
	args0: [
		{
			type: 'input_value',
			name: 'ITEM',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['print_block'] = { init: function() { this.jsonInit(printBlock); } };
luaGenerator.forBlock['print_block'] = function(block: Blockly.Block) {
	const item = luaGenerator.valueToCode(block, 'ITEM', Order.ATOMIC);
	return `p(${item === '' ? '""' : item})\n`;
};
miscCategory.contents.push({
	kind: 'block',
	type: 'print_block',
	inputs: {
		ITEM: {
			shadow: {
				type: 'text',
				fields: {
					TEXT: '',
				},
			},
		},
	},
});

// Comment
const commentBlock = {
	type: 'comment_block',
	message0: zh ? '标注 %1' : 'Note %1',
	args0: [
		{
			type: 'field_input',
			name: 'NOTE',
			text: '@preview-project on nolog clear',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'text_blocks',
};
Blockly.Blocks['comment_block'] = { init: function() { this.jsonInit(commentBlock); } };
luaGenerator.forBlock['comment_block'] = function(block: Blockly.Block) {
	const note = block.getFieldValue('NOTE');
	return `-- ${note}\n`;
};
miscCategory.contents.push({
	kind: 'block',
	type: 'comment_block',
});

// Colour HSV sliders
const colourHsvSlidersBlock = {
	type: 'colour_hsv_sliders',
	message0: zh ? '颜色 %1' : 'Color %1',
	args0: [
		{
			type: 'field_colour_hsv_sliders',
			name: 'COLOUR',
			colour: '#fac03d',
		},
	],
	output: 'Color3',
	style: 'colour_blocks',
};
Blockly.Blocks['colour_hsv_sliders'] = { init: function() { this.jsonInit(colourHsvSlidersBlock); } };
luaGenerator.forBlock['colour_hsv_sliders'] = function(block: Blockly.Block) {
	const colour = block.getFieldValue('COLOUR');
	return [`Color3(0x${colour.substring(1)})`, Order.ATOMIC];
};
miscCategory.contents.push({
	kind: 'block',
	type: 'colour_hsv_sliders',
});

// require
const requireBlock = {
	type: 'require_block',
	message0: zh ? '导入模块 %1' : 'Require module %1',
	args0: [
		{
			type: 'input_value',
			name: 'MODULE',
			check: "String",
		},
	],
	output: 'Module',
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['require_block'] = { init: function() { this.jsonInit(requireBlock); } };
luaGenerator.forBlock['require_block'] = function(block: Blockly.Block) {
	const module = luaGenerator.valueToCode(block, 'MODULE', Order.NONE);
	if (block.outputConnection?.targetConnection) {
		return [`require(${module})`, Order.ATOMIC];
	}
	return `require(${module})\n`;
};
miscCategory.contents.push({
	kind: 'block',
	type: 'require_block',
	inputs: {
		MODULE: {
			shadow: {
				type: 'text',
				fields: {
					TEXT: 'module',
				},
			},
		},
	},
});

export type ExportBlock = Blockly.Block & ExportMixin;
interface ExportMixin extends ExportMixinType {
  hasReturnValue_: boolean;
}
type ExportMixinType = typeof PROCEDURES_EXPORT;

const PROCEDURES_EXPORT = {
	init: function (this: ExportBlock) {
		this.appendValueInput('VALUE').appendField(
			zh ? '从模块导出' : 'Module export',
		);
		this.setInputsInline(true);
		this.setPreviousStatement(true);
		this.setNextStatement(false);
		this.setStyle('procedure_blocks');
	},

	onchange: function (this: ExportBlock, e: Blockly.Events.Abstract) {
		if (
			((this.workspace as Blockly.WorkspaceSvg).isDragging &&
			(this.workspace as Blockly.WorkspaceSvg).isDragging()) ||
			(e.type !== Blockly.Events.BLOCK_MOVE && e.type !== Blockly.Events.BLOCK_CREATE)
		) {
			return;
		}
		let legal = true;
		// Is the block nested in a procedure?
		let block = this; // eslint-disable-line @typescript-eslint/no-this-alias
		do {
			if (this.FUNCTION_TYPES.includes(block.type)) {
				legal = false;
				break;
			}
			block = block.getSurroundParent()!;
		} while (block);
		if (legal) {
			this.setWarningText(null);
		} else {
			this.setWarningText(zh ? '导出块不能嵌套在函数块中' : 'Export block cannot be nested in a function block');
		}

		if (!this.isInFlyout) {
			try {
				Blockly.Events.setRecordUndo(false);
				this.setDisabledReason(!legal, 'UNPARENTED_EXPORT');
			} finally {
				Blockly.Events.setRecordUndo(true);
			}
		}
	},
	FUNCTION_TYPES: [
		'procedures_defnoreturn',
		'procedures_defreturn',
		'on_button_event',
		'on_keyboard_event',
		'on_tap_event',
		'on_update',
		'node_register_global_event',
		'thread',
		'nvg_begin_painting',
		'body_create',
	],
};
Blockly.Blocks['export_block'] = PROCEDURES_EXPORT;
luaGenerator.forBlock['export_block'] = function(block: Blockly.Block) {
	const value = luaGenerator.valueToCode(block, 'VALUE', Order.NONE);
	return `return ${value}\n`;
};
miscCategory.contents.push({
	kind: 'block',
	type: 'export_block',
});

export type InvokeBlock = Blockly.Block & InvokeMixin;
interface InvokeMixin extends InvokeMixinType {
	argCount_: number;
}
type InvokeMixinType = typeof INVOKE;

const INVOKE = {
	init: function (this: InvokeBlock) {
		this.setStyle('logic_blocks');
		this.argCount_ = 1;
		this.updateShape_();
		this.setPreviousStatement(true);
		this.setNextStatement(true);
		this.setOutput(true, null);
		this.setInputsInline(false);
		this.setMutator(
			new Blockly.icons.MutatorIcon(['arg_create_with_item'], this as unknown as Blockly.BlockSvg),
		);
	},
	mutationToDom: function (this: InvokeBlock): Element {
		const container = Blockly.utils.xml.createElement('mutation');
		container.setAttribute('args', String(this.argCount_));
		return container;
	},
	domToMutation: function (this: InvokeBlock, xmlElement: Element) {
		const args = xmlElement.getAttribute('args');
		if (!args) throw new TypeError('element did not have args');
		this.argCount_ = parseInt(args, 10);
		this.updateShape_();
	},
	saveExtraState: function (this: InvokeBlock): {argCount: number} {
		return {
			'argCount': this.argCount_,
		};
	},
	loadExtraState: function (this: InvokeBlock, state: any) {
		this.argCount_ = state['argCount'];
		this.updateShape_();
	},
	decompose: function (
		this: InvokeBlock,
		workspace: Blockly.Workspace,
	): ArgContainerBlock {
		const containerBlock = workspace.newBlock(
			'arg_create_with_container',
		) as ArgContainerBlock;
		(containerBlock as Blockly.BlockSvg).initSvg();
		let connection = containerBlock.getInput('STACK')!.connection;
		for (let i = 0; i < this.argCount_; i++) {
			const argBlock = workspace.newBlock(
				'arg_create_with_item',
			) as ArgBlock;
			(argBlock as Blockly.BlockSvg).initSvg();
			if (!argBlock.previousConnection) {
				throw new Error('argBlock has no previousConnection');
			}
			connection!.connect(argBlock.previousConnection);
			connection = argBlock.nextConnection;
		}
		return containerBlock;
	},
	compose: function (this: InvokeBlock, containerBlock: ArgContainerBlock) {
		let argBlock: ArgBlock | null = containerBlock.getInputTargetBlock(
			'STACK',
		) as ArgBlock;
		const connections: Blockly.Connection[] = [];
		while (argBlock) {
			if (argBlock.isInsertionMarker()) {
				argBlock = argBlock.getNextBlock() as ArgBlock | null;
				continue;
			}
			connections.push(argBlock.valueConnection_ as Blockly.Connection);
			argBlock = argBlock.getNextBlock() as ArgBlock | null;
		}
		for (let i = 0; i < this.argCount_; i++) {
			const connection = this.getInput('ADD' + i)!.connection!.targetConnection;
			if (connection && !connections.includes(connection)) {
				connection.disconnect();
			}
		}
		this.argCount_ = connections.length;
		this.updateShape_();
		for (let i = 0; i < this.argCount_; i++) {
			connections[i]?.reconnect(this, 'ADD' + i);
		}
	},
	saveConnections: function (this: InvokeBlock, containerBlock: Blockly.Block) {
		let argBlock: ArgBlock | null = containerBlock.getInputTargetBlock(
			'STACK',
		) as ArgBlock;
		let i = 0;
		while (argBlock) {
			if (argBlock.isInsertionMarker()) {
				argBlock = argBlock.getNextBlock() as ArgBlock | null;
				continue;
			}
			const input = this.getInput('ADD' + i);
			argBlock.valueConnection_ = input?.connection!
			.targetConnection as Blockly.Connection;
			argBlock = argBlock.getNextBlock() as ArgBlock | null;
			i++;
		}
	},
	updateShape_: function (this: InvokeBlock) {
		if (!this.getInput('FUNCTION')) {
			this.appendDummyInput('FUNCTION')
				.appendField(
					zh ? '调用函数' : 'Call function',
				)
				.appendField(
					new Blockly.FieldVariable('temp'),
					'FUNCTION',
				);
		}
		if (this.argCount_ && this.getInput('EMPTY')) {
			this.removeInput('EMPTY');
		} else if (!this.argCount_ && !this.getInput('EMPTY')) {
			this.appendDummyInput('EMPTY').appendField(
				zh ? '无参数' : 'no arguments',
			);
		}
		for (let i = 0; i < this.argCount_; i++) {
			if (!this.getInput('ADD' + i)) {
				const input = this.appendValueInput('ADD' + i).setAlign(Blockly.inputs.Align.RIGHT);
				if (i === 0) {
					input.appendField(zh ? '参数' : 'arguments');
				}
			}
		}
		for (let i = this.argCount_; this.getInput('ADD' + i); i++) {
			this.removeInput('ADD' + i);
		}
	},
};
Blockly.Blocks['invoke'] = INVOKE;
luaGenerator.forBlock['invoke'] = function(block: Blockly.Block) {
	const functionName = luaGenerator.getVariableName(block.getFieldValue('FUNCTION'));
	const args = [];
	for (let i = 0; i < (block as InvokeBlock).argCount_; i++) {
		const arg = luaGenerator.valueToCode(block, 'ADD' + i, Order.NONE);
		args.push(arg === '' ? 'nil' : arg);
	}
	if (block.outputConnection?.targetConnection) {
		return [`${functionName}(${args.join(', ')})`, Order.ATOMIC];
	}
	return `${functionName}(${args.join(', ')})\n`;
};
miscCategory.contents.push({
	kind: 'block',
	type: 'invoke',
});
