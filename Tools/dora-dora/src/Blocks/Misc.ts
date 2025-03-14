import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';

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
		'nvg_begin_painting'
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
