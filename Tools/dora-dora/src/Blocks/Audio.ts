/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';
import Require from './Require';

const zh = Info.locale.match(/^zh/) !== null;

const audioCategory = {
	kind: 'category',
	name: zh ? '音频' : 'Audio',
	categorystyle: 'logic_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
};
export default audioCategory;

// playStream
const playStreamBlock = {
	type: 'play_stream',
	message0: zh ? '播放音乐 %1\n循环 %2\n交叉淡入时间 %3' : 'Play music %1\nloop %2\ncross fade time %3',
	args0: [
		{
			type: 'input_value',
			name: 'FILE',
			check: 'String',
		},
		{
			type: 'input_value',
			name: 'LOOP',
			check: 'Boolean',
		},
		{
			type: 'input_value',
			name: 'CROSS_FADE_TIME',
			check: 'Number',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['play_stream'] = { init: function() { this.jsonInit(playStreamBlock); } };
luaGenerator.forBlock['play_stream'] = function(block: Blockly.Block) {
	const file = luaGenerator.valueToCode(block, 'FILE', Order.NONE);
	const loop = luaGenerator.valueToCode(block, 'LOOP', Order.NONE);
	const crossFadeTime = luaGenerator.valueToCode(block, 'CROSS_FADE_TIME', Order.NONE);
	Require.add('Audio');
	return `Audio:playStream(${file === '' ? 'nil' : file}, ${loop === '' ? 'false' : loop}, ${crossFadeTime === '' ? '0' : crossFadeTime})\n`;
};
audioCategory.contents.push({
	kind: 'block',
	type: 'play_stream',
	inputs: {
		FILE: {
			shadow: {
				type: 'text',
				fields: {
					TEXT: 'Audio/Dismantlism Space.ogg',
				},
			},
		},
		LOOP: {
			shadow: {
				type: 'logic_boolean',
				fields: {
					BOOL: 'FALSE',
				},
			},
		},
		CROSS_FADE_TIME: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: '0',
				},
			},
		},
	},
});

// stopStream
const stopStreamBlock = {
	type: 'stop_stream',
	message0: zh ? '停止音乐\n淡出时间 %1' : 'Stop music\nfade time %1',
	args0: [
		{
			type: 'input_value',
			name: 'FADE_TIME',
			check: 'Number',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['stop_stream'] = { init: function() { this.jsonInit(stopStreamBlock); } };
luaGenerator.forBlock['stop_stream'] = function(block: Blockly.Block) {
	const fadeTime = luaGenerator.valueToCode(block, 'FADE_TIME', Order.NONE);
	Require.add('Audio');
	return `Audio:stopStream(${fadeTime === '' ? '0' : fadeTime})\n`;
};
audioCategory.contents.push({
	kind: 'block',
	type: 'stop_stream',
	inputs: {
		FADE_TIME: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: '0',
				},
			},
		},
	},
});

// playSound
const playSoundBlock = {
	type: 'play_sound',
	message0: zh ? '播放音效 %1\n循环 %2\n返回音频控制编号' : 'Play sound %1\nloop %2\nreturn audio control ID',
	args0: [
		{
			type: 'input_value',
			name: 'FILE',
			check: 'String',
		},
		{
			type: 'input_value',
			name: 'LOOP',
			check: 'Boolean',
		},
	],
	output: 'Number',
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['play_sound'] = { init: function() { this.jsonInit(playSoundBlock); } };
luaGenerator.forBlock['play_sound'] = function(block: Blockly.Block) {
	const file = luaGenerator.valueToCode(block, 'FILE', Order.NONE);
	const loop = luaGenerator.valueToCode(block, 'LOOP', Order.NONE);
	Require.add('Audio');
	if (block.outputConnection?.targetConnection) {
		return [`Audio:playSound(${file === '' ? 'nil' : file}, ${loop === '' ? 'false' : loop})`, Order.ATOMIC];
	}
	return `Audio:play(${file === '' ? 'nil' : file}, ${loop === '' ? 'false' : loop})\n`;
};
audioCategory.contents.push({
	kind: 'block',
	type: 'play_sound',
	inputs: {
		FILE: {
			shadow: {
				type: 'text',
				fields: {
					TEXT: 'Audio/hero_win.wav',
				},
			},
		},
		LOOP: {
			shadow: {
				type: 'logic_boolean',
				fields: {
					BOOL: 'FALSE',
				},
			},
		},
	},
});

// stopSound
const stopSoundBlock = {
	type: 'stop_sound',
	message0: zh ? '停止音效 %1' : 'Stop sound %1',
	args0: [
		{
			type: 'input_value',
			name: 'AUDIO_CONTROL_ID',
			check: 'Number',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['stop_sound'] = { init: function() { this.jsonInit(stopSoundBlock); } };
luaGenerator.forBlock['stop_sound'] = function(block: Blockly.Block) {
	const audioControlId = luaGenerator.valueToCode(block, 'AUDIO_CONTROL_ID', Order.NONE);
	Require.add('Audio');
	return `Audio:stop(${audioControlId === '' ? 'nil' : audioControlId})\n`;
};
audioCategory.contents.push({
	kind: 'block',
	type: 'stop_sound',
	inputs: {
		AUDIO_CONTROL_ID: {
			shadow: {
				type: 'variables_get',
			},
		},
	},
});
