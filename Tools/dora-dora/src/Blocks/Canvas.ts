/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';
import Require from './Require';

const zh = Info.locale.match(/^zh/) !== null;

const canvasCategory = {
	kind: 'category',
	name: zh ? '画布' : 'Canvas',
	categorystyle: 'logic_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
};
export default canvasCategory;

const shadowZero = {
	shadow: {
		type: 'math_number',
		fields: {
			NUM: 0,
		},
	},
};

const shadowOne = {
	shadow: {
		type: 'math_number',
		fields: {
			NUM: 1,
		},
	},
};

const shadow100 = {
	shadow: {
		type: 'math_number',
		fields: {
			NUM: 100,
		},
	},
};

// Node begin painting
const nvgBeginPaintingBlock = {
	type: 'nvg_begin_painting',
	message0: zh ? '节点 %1 开始绘图\n %2' : 'Node %1 begins painting\n %2',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
		{
			type: 'input_statement',
			name: 'PAINT',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['nvg_begin_painting'] = { init: function() { this.jsonInit(nvgBeginPaintingBlock); } };
luaGenerator.forBlock['nvg_begin_painting'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const paint = luaGenerator.statementToCode(block, 'PAINT');
	Require.add('nvg');
	return `${node}:onRender(function()\n  nvg.ApplyTransform(${node})\n${paint}end)\n`;
};
canvasCategory.contents.push({
	kind: 'block',
	type: 'nvg_begin_painting',
});

// BeginPath block
const nvgBeginPathBlock = {
	type: 'nvg_begin_path',
	message0: zh ? '开始画新路径' : 'Begin path',
	previousStatement: null,
	nextStatement: null,
	style: 'loop_blocks',
};
Blockly.Blocks['nvg_begin_path'] = { init: function() { this.jsonInit(nvgBeginPathBlock); } };
luaGenerator.forBlock['nvg_begin_path'] = function() {
	Require.add('nvg');
	return 'nvg.BeginPath()\n';
};
canvasCategory.contents.push({
	kind: 'block',
	type: 'nvg_begin_path',
});

// MoveTo block
const nvgMoveToBlock = {
	type: 'nvg_move_to',
	message0: zh ? '移动到 X %1 Y %2 坐标' : 'Move to X %1 Y %2 position',
	args0: [
		{
			type: 'input_value',
			name: 'X',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'Y',
			check: 'Number',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['nvg_move_to'] = { init: function() { this.jsonInit(nvgMoveToBlock); } };
luaGenerator.forBlock['nvg_move_to'] = function(block: Blockly.Block) {
	const x = luaGenerator.valueToCode(block, 'X', Order.NONE);
	const y = luaGenerator.valueToCode(block, 'Y', Order.NONE);
	Require.add('nvg');
	return `nvg.MoveTo(${x === '' ? '0' : x}, ${y === '' ? '0' : y})\n`;
};
canvasCategory.contents.push({
	kind: 'block',
	type: 'nvg_move_to',
	inputs: {
		X: shadowZero,
		Y: shadowZero,
	},
});

// LineTo block
const nvgLineToBlock = {
	type: 'nvg_line_to',
	message0: zh ? '画线到 X %1 Y %2 坐标' : 'Line to X %1 Y %2 position',
	args0: [
		{
			type: 'input_value',
			name: 'X',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'Y',
			check: 'Number',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['nvg_line_to'] = { init: function() { this.jsonInit(nvgLineToBlock); } };
luaGenerator.forBlock['nvg_line_to'] = function(block: Blockly.Block) {
	const x = luaGenerator.valueToCode(block, 'X', Order.NONE);
	const y = luaGenerator.valueToCode(block, 'Y', Order.NONE);
	Require.add('nvg');
	return `nvg.LineTo(${x === '' ? '0' : x}, ${y === '' ? '0' : y})\n`;
};
canvasCategory.contents.push({
	kind: 'block',
	type: 'nvg_line_to',
	inputs: {
		X: shadow100,
		Y: shadow100,
	},
});

// BezierTo block
const nvgBezierToBlock = {
	type: 'nvg_bezier_to',
	message0: zh ?
		'画贝塞尔曲线\n控制点1 X %1 Y %2\n控制点2 X %3 Y %4\n终点 X %5 Y %6' :
		'Bezier to\ncontrol point 1 X %1 Y %2\ncontrol point 2 X %3 Y %4\nend point X %5 Y %6',
	args0: [
		{
			type: 'input_value',
			name: 'C1X',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'C1Y',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'C2X',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'C2Y',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'X',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'Y',
			check: 'Number',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['nvg_bezier_to'] = { init: function() { this.jsonInit(nvgBezierToBlock); } };
luaGenerator.forBlock['nvg_bezier_to'] = function(block: Blockly.Block) {
	const c1x = luaGenerator.valueToCode(block, 'C1X', Order.NONE);
	const c1y = luaGenerator.valueToCode(block, 'C1Y', Order.NONE);
	const c2x = luaGenerator.valueToCode(block, 'C2X', Order.NONE);
	const c2y = luaGenerator.valueToCode(block, 'C2Y', Order.NONE);
	const x = luaGenerator.valueToCode(block, 'X', Order.NONE);
	const y = luaGenerator.valueToCode(block, 'Y', Order.NONE);
	Require.add('nvg');
	return `nvg.BezierTo(${c1x === '' ? '0' : c1x}, ${c1y === '' ? '0' : c1y}, ${c2x === '' ? '0' : c2x}, ${c2y === '' ? '0' : c2y}, ${x === '' ? '0' : x}, ${y === '' ? '0' : y})\n`;
};
canvasCategory.contents.push({
	kind: 'block',
	type: 'nvg_bezier_to',
	inputs: {
		C1X: shadowZero,
		C1Y: shadowZero,
		C2X: shadowZero,
		C2Y: shadow100,
		X: shadow100,
		Y: shadow100,
	},
});

// ClosePath block
const nvgClosePathBlock = {
	type: 'nvg_close_path',
	message0: zh ? '闭合当前路径' : 'Close path',
	previousStatement: null,
	nextStatement: null,
	style: 'loop_blocks',
};
Blockly.Blocks['nvg_close_path'] = { init: function() { this.jsonInit(nvgClosePathBlock); } };
luaGenerator.forBlock['nvg_close_path'] = function() {
	Require.add('nvg');
	return 'nvg.ClosePath()\n';
};
canvasCategory.contents.push({
	kind: 'block',
	type: 'nvg_close_path',
});

// FillColor block
const nvgFillColorBlock = {
	type: 'nvg_fill_color',
	message0: zh ? '设置填充颜色 %1 不透明度 %2' : 'Set fill color %1 opacity %2',
	args0: [
		{
			type: 'input_value',
			name: 'COLOR',
			check: "Color3",
		},
		{
			type: 'input_value',
			name: 'OPACITY',
			check: "Number",
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['nvg_fill_color'] = { init: function() { this.jsonInit(nvgFillColorBlock); } };
luaGenerator.forBlock['nvg_fill_color'] = function(block: Blockly.Block) {
	const color = luaGenerator.valueToCode(block, 'COLOR', Order.NONE);
	const opacity = luaGenerator.valueToCode(block, 'OPACITY', Order.MULTIPLICATIVE);
	Require.add('nvg');
	return `nvg.FillColor(${color === '' ? '0x0' : color} | math.floor(${opacity === '' ? '1' : opacity} * 255 + 0.5) << 24)\n`;
};
canvasCategory.contents.push({
	kind: 'block',
	type: 'nvg_fill_color',
	inputs: {
		COLOR: {
			shadow: {
				type: 'colour_hsv_sliders',
			},
		},
		OPACITY: shadowOne,
	},
});

// Fill block
const nvgFillBlock = {
	type: 'nvg_fill',
	message0: zh ? '填充图形' : 'Fill color',
	previousStatement: null,
	nextStatement: null,
	style: 'colour_blocks',
};
Blockly.Blocks['nvg_fill'] = { init: function() { this.jsonInit(nvgFillBlock); } };
luaGenerator.forBlock['nvg_fill'] = function() {
	Require.add('nvg');
	return 'nvg.Fill()\n';
};
canvasCategory.contents.push({
	kind: 'block',
	type: 'nvg_fill',
});

// StrokeColor block
const nvgStrokeColorBlock = {
	type: 'nvg_stroke_color',
	message0: zh ? '设置描边颜色 %1 不透明度 %2' : 'Set stroke color %1 opacity %2',
	args0: [
		{
			type: 'input_value',
			name: 'COLOR',
			check: "Color3",
		},
		{
			type: 'input_value',
			name: 'OPACITY',
			check: "Number",
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['nvg_stroke_color'] = { init: function() { this.jsonInit(nvgStrokeColorBlock); } };
luaGenerator.forBlock['nvg_stroke_color'] = function(block: Blockly.Block) {
	const color = luaGenerator.valueToCode(block, 'COLOR', Order.NONE);
	const opacity = luaGenerator.valueToCode(block, 'OPACITY', Order.MULTIPLICATIVE);
	Require.add('nvg');
	return `nvg.StrokeColor(${color === '' ? '0x0' : color} | math.floor(${opacity === '' ? '1' : opacity} * 255 + 0.5) << 24)\n`;
};
canvasCategory.contents.push({
	kind: 'block',
	type: 'nvg_stroke_color',
	inputs: {
		COLOR: {
			shadow: {
				type: 'colour_hsv_sliders',
			},
		},
		OPACITY: shadowOne,
	},
});

// StrokeWidth block
const nvgStrokeWidthBlock = {
	type: 'nvg_stroke_width',
	message0: zh ? '设置描边宽度 %1' : 'Set stroke width %1',
	args0: [
		{
			type: 'input_value',
			name: 'WIDTH',
			check: 'Number',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['nvg_stroke_width'] = { init: function() { this.jsonInit(nvgStrokeWidthBlock); } };
luaGenerator.forBlock['nvg_stroke_width'] = function(block: Blockly.Block) {
	const width = luaGenerator.valueToCode(block, 'WIDTH', Order.NONE);
	Require.add('nvg');
	return `nvg.StrokeWidth(${width === '' ? '1' : width})\n`;
};
canvasCategory.contents.push({
	kind: 'block',
	type: 'nvg_stroke_width',
	inputs: {
		WIDTH: shadowOne,
	},
});

// Stroke block
const nvgStrokeBlock = {
	type: 'nvg_stroke',
	message0: zh ? '给图形描边' : 'Stroke path',
	previousStatement: null,
	nextStatement: null,
	style: 'colour_blocks',
};
Blockly.Blocks['nvg_stroke'] = { init: function() { this.jsonInit(nvgStrokeBlock); } };
luaGenerator.forBlock['nvg_stroke'] = function() {
	Require.add('nvg');
	return 'nvg.Stroke()\n';
};
canvasCategory.contents.push({
	kind: 'block',
	type: 'nvg_stroke',
});

// Rect block
const nvgRectBlock = {
	type: 'nvg_rect',
	message0: zh ? '画矩形\nX %1 Y %2\n宽 %3 高 %4' : 'Draw rectangle\nX %1 Y %2\nwidth %3 height %4',
	args0: [
		{
			type: 'input_value',
			name: 'X',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'Y',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'WIDTH',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'HEIGHT',
			check: 'Number',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['nvg_rect'] = { init: function() { this.jsonInit(nvgRectBlock); } };
luaGenerator.forBlock['nvg_rect'] = function(block: Blockly.Block) {
	const x = luaGenerator.valueToCode(block, 'X', Order.NONE);
	const y = luaGenerator.valueToCode(block, 'Y', Order.NONE);
	const width = luaGenerator.valueToCode(block, 'WIDTH', Order.NONE);
	const height = luaGenerator.valueToCode(block, 'HEIGHT', Order.NONE);
	Require.add('nvg');
	return `nvg.Rect(${x === '' ? '0' : x}, ${y === '' ? '0' : y}, ${width === '' ? '0' : width}, ${height === '' ? '0' : height})\n`;
};
canvasCategory.contents.push({
	kind: 'block',
	type: 'nvg_rect',
	inputs: {
		X: shadowZero,
		Y: shadowZero,
		WIDTH: shadow100,
		HEIGHT: shadow100,
	},
});

// RoundedRect block
const nvgRoundedRectBlock = {
	type: 'nvg_rounded_rect',
	message0: zh ?
		'画圆角矩形\nX %1 Y %2\n宽 %3 高 %4\n圆角 %5' :
		'Draw rounded rectangle\nX %1 Y %2\nwidth %3 height %4\nradius %5',
	args0: [
		{
			type: 'input_value',
			name: 'X',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'Y',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'WIDTH',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'HEIGHT',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'RADIUS',
			check: 'Number',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['nvg_rounded_rect'] = { init: function() { this.jsonInit(nvgRoundedRectBlock); } };
luaGenerator.forBlock['nvg_rounded_rect'] = function(block: Blockly.Block) {
	const x = luaGenerator.valueToCode(block, 'X', Order.NONE);
	const y = luaGenerator.valueToCode(block, 'Y', Order.NONE);
	const width = luaGenerator.valueToCode(block, 'WIDTH', Order.NONE);
	const height = luaGenerator.valueToCode(block, 'HEIGHT', Order.NONE);
	const radius = luaGenerator.valueToCode(block, 'RADIUS', Order.NONE);
	Require.add('nvg');
	return `nvg.RoundedRect(${x === '' ? '0' : x}, ${y === '' ? '0' : y}, ${width === '' ? '0' : width}, ${height === '' ? '0' : height}, ${radius === '' ? '0' : radius})\n`;
};
canvasCategory.contents.push({
	kind: 'block',
	type: 'nvg_rounded_rect',
	inputs: {
		X: shadowZero,
		Y: shadowZero,
		WIDTH: shadow100,
		HEIGHT: shadow100,
		RADIUS: shadowOne,
	},
});

// Ellipse block
const nvgEllipseBlock = {
	type: 'nvg_ellipse',
	message0: zh ?
		'画椭圆\n中心 X %1 中心 Y %2\n半径 X %3 半径 Y %4' :
		'Draw ellipse\ncenter X %1 center Y %2\nradius X %3 radius Y %4',
	args0: [
		{
			type: 'input_value',
			name: 'CX',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'CY',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'RX',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'RY',
			check: 'Number',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['nvg_ellipse'] = { init: function() { this.jsonInit(nvgEllipseBlock); } };
luaGenerator.forBlock['nvg_ellipse'] = function(block: Blockly.Block) {
	const cx = luaGenerator.valueToCode(block, 'CX', Order.NONE);
	const cy = luaGenerator.valueToCode(block, 'CY', Order.NONE);
	const rx = luaGenerator.valueToCode(block, 'RX', Order.NONE);
	const ry = luaGenerator.valueToCode(block, 'RY', Order.NONE);
	Require.add('nvg');
	return `nvg.Ellipse(${cx === '' ? '0' : cx}, ${cy === '' ? '0' : cy}, ${rx === '' ? '0' : rx}, ${ry === '' ? '0' : ry})\n`;
};
canvasCategory.contents.push({
	kind: 'block',
	type: 'nvg_ellipse',
	inputs: {
		CX: shadowZero,
		CY: shadowZero,
		RX: shadow100,
		RY: shadow100,
	},
});

// Circle block
const nvgCircleBlock = {
	type: 'nvg_circle',
	message0: zh ?
		'画圆\n中心 X %1 中心 Y %2\n半径 %3' :
		'Draw circle\ncenter X %1 center Y %2\nradius %3',
	args0: [
		{
			type: 'input_value',
			name: 'CX',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'CY',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'RADIUS',
			check: 'Number',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['nvg_circle'] = { init: function() { this.jsonInit(nvgCircleBlock); } };
luaGenerator.forBlock['nvg_circle'] = function(block: Blockly.Block) {
	const cx = luaGenerator.valueToCode(block, 'CX', Order.NONE);
	const cy = luaGenerator.valueToCode(block, 'CY', Order.NONE);
	const radius = luaGenerator.valueToCode(block, 'RADIUS', Order.NONE);
	Require.add('nvg');
	return `nvg.Circle(${cx === '' ? '0' : cx}, ${cy === '' ? '0' : cy}, ${radius === '' ? '0' : radius})\n`;
};
canvasCategory.contents.push({
	kind: 'block',
	type: 'nvg_circle',
	inputs: {
		CX: shadowZero,
		CY: shadowZero,
		RADIUS: shadow100,
	},
});

