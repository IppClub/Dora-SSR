/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import React, { useEffect, useRef, useState } from 'react';
import MonacoEditor from "@monaco-editor/react";
import monaco from './monacoBase';
import * as Blockly from 'blockly';
import '@blockly/field-colour-hsv-sliders';
import { luaGenerator } from 'blockly/lua';
import * as Zh from 'blockly/msg/zh-hans';
import * as En from 'blockly/msg/en';
import { useTranslation } from 'react-i18next';
import { IconButton, Tooltip, Stack } from '@mui/material';
import CodeIcon from '@mui/icons-material/Code';
import CodeOffIcon from '@mui/icons-material/CodeOff';
import SaveIcon from '@mui/icons-material/Save';
import Info from './Info';
import path from './3rdParty/Path';
import Require from './Blocks/Require';
import DeclareCategory from './Blocks/Declare';
import NodeCategory from './Blocks/Node';
import GraphicCategory from './Blocks/Graphic';
import EventCategory from './Blocks/Event';
import Vec2Category from './Blocks/Vec2';
import ActionCategory from './Blocks/Action';
import RoutineCategory from './Blocks/Routine';
import CanvasCategory from './Blocks/Canvas';
import AudioCategory from './Blocks/Audio';
import DictCategory from './Blocks/Dict';
import PhysicsCategory from './Blocks/Physics';
import MiscCategory from './Blocks/Misc';
import { EditorTheme } from './Editor';

const editorBackground = <div style={{width: '100%', height: '100%', backgroundColor:'#1a1a1a'}}/>;

interface BlocklyProps {
	width: number;
	height: number;
	file: string;
	readOnly?: boolean;

	/**
	 * Initial JSON configuration for the Blockly workspace
	 */
	initialJson?: string;

	/**
	 * Callback function triggered when the workspace content changes
	 * @param json - The JSON representation of the current workspace
	 * @param code - The Lua code generated from the current workspace
	 */
	onChange?: (json: string, code: string) => void;

	/**
	 * Callback function triggered when the save button is clicked
	 */
	onSave?: () => void;

	/**
	 * Additional configuration options for the Blockly workspace
	 */
	options?: Blockly.BlocklyOptions;
}

/**
 * A React component that wraps the Blockly library
 */
const BlocklyComponent: React.FC<BlocklyProps> = ({
	file,
	width,
	height,
	readOnly = false,
	initialJson,
	onChange,
	onSave,
	options = {},
}) => {
	const blocklyDiv = useRef<HTMLDivElement>(null);
	const workspaceRef = useRef<Blockly.WorkspaceSvg | null>(null);
	const [firstView, setFirstView] = useState(true);
	const {t} = useTranslation();
	const [showEditor, setShowEditor] = useState(false);

	// Initialize Blockly workspace
	useEffect(() => {
		const zh = Info.locale.match(/^zh/) !== null;

		if (blocklyDiv.current && !workspaceRef.current) {
			if (zh) {
				Blockly.setLocale(Zh as any);
			} else {
				Blockly.setLocale(En as any);
			}
			Blockly.Msg['VARIABLES_DEFAULT_NAME'] = 'temp';

			// Default options
			const defaultOptions: Blockly.BlocklyOptions = {
				sounds: false,
				media: '/',
				readOnly,
				theme: {
					name: 'DoraTheme',
					base: Blockly.Themes.Classic,
					startHats: true,
					fontStyle: {
						size: 10,
					},
					blockStyles: {
						dora_blocks: {
							colourPrimary: '#d2970d',
							colourSecondary: Blockly.utils.colour.blend('#d2970d', '#000000', 0.8) || '#d2970d',
						},
						math_blocks: {
							colourSecondary: Blockly.utils.colour.blend('#5b67a5', '#000000', 0.8) || '#5b67a5',
						},
						text_blocks: {
							colourSecondary: Blockly.utils.colour.blend('#5ba58c', '#000000', 0.8) || '#5ba58c',
						},
						logic_blocks: {
							colourSecondary: Blockly.utils.colour.blend('#5b80a5', '#000000', 0.8) || '#5b80a5',
						},
						procedure_blocks: {
							colourPrimary: '#995ba5',
							colourSecondary: Blockly.utils.colour.blend('#995ba5', '#000000', 0.8) || '#995ba5',
						},
						colour_blocks: {
							colourSecondary: Blockly.utils.colour.blend('#a5745b', '#000000', 0.8) || '#a5745b',
						},
						variable_blocks: {
							colourSecondary: Blockly.utils.colour.blend('#a55b80', '#000000', 0.8) || '#a55b80',
						},
						variable_dynamic_blocks: {
							colourSecondary: Blockly.utils.colour.blend('#a55b80', '#000000', 0.8) || '#a55b80',
						},
					},
					categoryStyles: {
						dora_category: {
							colour: '#d2970d',
						},
					},
					componentStyles: {
						workspaceBackgroundColour: '#1e1e1e',
						toolboxBackgroundColour: '#333',
						toolboxForegroundColour: '#fff',
						flyoutBackgroundColour: '#252526',
						flyoutForegroundColour: '#ccc',
						flyoutOpacity: 0.9,
						scrollbarColour: '#797979',
						insertionMarkerColour: '#fff',
						insertionMarkerOpacity: 0.3,
						scrollbarOpacity: 0.1,
						cursorColour: '#d0d0d0',
					}
				},
				toolbox: {
					kind: 'categoryToolbox',
					contents: [
						{
							kind: 'category',
							name: t('blockly.logic'),
							categorystyle: 'logic_category',
							contents: [
								{
									kind: 'block',
									type: 'controls_if',
								},
								{
									kind: 'block',
									type: 'logic_compare',
								},
								{
									kind: 'block',
									type: 'logic_operation',
								},
								{
									kind: 'block',
									type: 'logic_negate',
								},
								{
									kind: 'block',
									type: 'logic_boolean',
								},
								{
									kind: 'block',
									type: 'logic_null',
								},
								{
									kind: 'block',
									type: 'logic_ternary',
								},
							],
						},
						{
							kind: 'category',
							name: t('blockly.loops'),
							categorystyle: 'loop_category',
							contents: [
								{
									kind: 'block',
									type: 'controls_repeat_ext',
									inputs: {
										TIMES: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 10,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'controls_whileUntil',
								},
								{
									kind: 'block',
									type: 'controls_for',
									inputs: {
										FROM: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 1,
												},
											},
										},
										TO: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 10,
												},
											},
										},
										BY: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 1,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'controls_forEach',
									inputs: {
										LIST: {
											shadow: {
												type: 'variables_get',
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'controls_flow_statements',
								},
							],
						},
						{
							kind: 'category',
							name: t('blockly.math'),
							categorystyle: 'math_category',
							contents: [
								{
									kind: 'block',
									type: 'math_number',
									fields: {
										NUM: 123,
									},
								},
								{
									kind: 'block',
									type: 'math_arithmetic',
									inputs: {
										A: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 1,
												},
											},
										},
										B: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 1,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'math_single',
									inputs: {
										NUM: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 9,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'math_trig',
									inputs: {
										NUM: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 45,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'math_constant',
								},
								{
									kind: 'block',
									type: 'math_number_property',
									inputs: {
										NUMBER_TO_CHECK: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 0,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'math_round',
									fields: {
										OP: 'ROUND',
									},
									inputs: {
										NUM: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 3.1,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'math_on_list',
									fields: {
										OP: 'SUM',
									},
								},
								{
									kind: 'block',
									type: 'math_modulo',
									inputs: {
										DIVIDEND: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 64,
												},
											},
										},
										DIVISOR: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 10,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'math_constrain',
									inputs: {
										VALUE: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 50,
												},
											},
										},
										LOW: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 1,
												},
											},
										},
										HIGH: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 100,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'math_random_int',
									inputs: {
										FROM: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 1,
												},
											},
										},
										TO: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 100,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'math_random_float',
								},
								{
									kind: 'block',
									type: 'math_atan2',
									inputs: {
										X: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 1,
												},
											},
										},
										Y: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 1,
												},
											},
										},
									},
								},
							],
						},
						{
							kind: 'category',
							name: t('blockly.text'),
							categorystyle: 'text_category',
							contents: [
								{
									kind: 'block',
									type: 'text',
								},
								{
									kind: 'block',
									type: 'text_join',
								},
								{
									kind: 'block',
									type: 'text_append',
									inputs: {
										TEXT: {
											shadow: {
												type: 'text',
												fields: {
													TEXT: '',
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'text_length',
									inputs: {
										VALUE: {
											shadow: {
												type: 'text',
												fields: {
													TEXT: 'abc',
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'text_isEmpty',
									inputs: {
										VALUE: {
											shadow: {
												type: 'text',
												fields: {
													TEXT: '',
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'text_indexOf',
									inputs: {
										VALUE: {
											block: {
												type: 'variables_get',
											},
										},
										FIND: {
											shadow: {
												type: 'text',
												fields: {
													TEXT: 'abc',
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'text_charAt',
									inputs: {
										VALUE: {
											block: {
												type: 'variables_get',
											},
										},
										AT: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 1,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'text_getSubstring',
									inputs: {
										STRING: {
											block: {
												type: 'variables_get',
											},
										},
										AT1: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 1,
												},
											},
										},
										AT2: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 1,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'text_changeCase',
									inputs: {
										TEXT: {
											shadow: {
												type: 'text',
												fields: {
													TEXT: 'abc',
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'text_trim',
									inputs: {
										TEXT: {
											shadow: {
												type: 'text',
												fields: {
													TEXT: 'abc',
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'text_count',
									inputs: {
										SUB: {
											shadow: {
												type: 'text',
											},
										},
										TEXT: {
											shadow: {
												type: 'text',
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'text_replace',
									inputs: {
										FROM: {
											shadow: {
												type: 'text',
											},
										},
										TO: {
											shadow: {
												type: 'text',
											},
										},
										TEXT: {
											shadow: {
												type: 'text',
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'text_reverse',
									inputs: {
										TEXT: {
											shadow: {
												type: 'text',
											},
										},
									},
								},
							],
						},
						{
							kind: 'category',
							name: t('blockly.lists'),
							categorystyle: 'list_category',
							contents: [
								{
									kind: 'block',
									type: 'lists_create_with',
								},
								{
									kind: 'block',
									type: 'lists_repeat',
									inputs: {
										ITEM: {
											shadow: {
												type: 'variables_get',
											},
										},
										NUM: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 5,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'lists_length',
									inputs: {
										VALUE: {
											block: {
												type: 'variables_get',
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'lists_isEmpty',
									inputs: {
										VALUE: {
											block: {
												type: 'variables_get',
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'lists_indexOf',
									inputs: {
										VALUE: {
											block: {
												type: 'variables_get',
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'lists_getIndex',
									inputs: {
										VALUE: {
											block: {
												type: 'variables_get',
											},
										},
										AT: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 1,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'lists_setIndex',
									inputs: {
										LIST: {
											block: {
												type: 'variables_get',
											},
										},
										AT: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 1,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'lists_getSublist',
									inputs: {
										LIST: {
											block: {
												type: 'variables_get',
											},
										},
										AT1: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 1,
												},
											},
										},
										AT2: {
											shadow: {
												type: 'math_number',
												fields: {
													NUM: 1,
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'lists_split',
									inputs: {
										INPUT: {
											shadow: {
												type: 'text',
												fields: {
													TEXT: 'item1,item2,item3',
												},
											},
										},
										DELIM: {
											shadow: {
												type: 'text',
												fields: {
													TEXT: ',',
												},
											},
										},
									},
								},
								{
									kind: 'block',
									type: 'lists_sort',
								},
								{
									kind: 'block',
									type: 'lists_reverse',
									inputs: {
										LIST: {
											block: {
												type: 'variables_get',
											},
										},
									},
								},
							],
						},
						DictCategory,
						{
							kind: 'sep',
						},
						DeclareCategory,
						{
							kind: 'category',
							name: t('blockly.variables'),
							categorystyle: 'variable_category',
							custom: 'VARIABLE',
						},
						{
							kind: 'category',
							name: t('blockly.functions'),
							categorystyle: 'procedure_category',
							custom: 'PROCEDURE',
						},
						{
							kind: 'sep',
						},
						Vec2Category,
						{
							kind: 'sep',
						},
						NodeCategory,
						GraphicCategory,
						CanvasCategory,
						PhysicsCategory,
						{
							kind: 'sep',
						},
						ActionCategory,
						EventCategory,
						AudioCategory,
						{
							kind: 'sep',
						},
						RoutineCategory,
						{
							kind: 'sep',
						},
						MiscCategory,
					],
				},
				grid: {
					spacing: 20,
					length: 3,
					colour: '#666',
					snap: true,
				},
				move: {
					scrollbars: true,
					drag: true,
					wheel: true,
				},
				zoom: {
					controls: true,
					wheel: true,
					startScale: 1.0,
					maxScale: 3,
					minScale: 0.3,
					scaleSpeed: 1.2,
				},
				trashcan: true,
			};

			// Merge default options with user-provided options
			const mergedOptions = { ...defaultOptions, ...options };

			// Create the Blockly workspace
			workspaceRef.current = Blockly.inject(blocklyDiv.current, mergedOptions);

			// Load initial JSON if provided
			if (initialJson) {
				try {
					const jsonObj = JSON.parse(initialJson);
					(workspaceRef.current as any).showEditor = jsonObj.showEditor;
					Blockly.serialization.workspaces.load(jsonObj, workspaceRef.current);
					if (jsonObj.showEditor) {
						setShowEditor(true);
						setTimeout(() => {
							workspaceRef.current?.scrollCenter();
						}, 100);
					}
				} catch (e) {
					console.error('Error loading initial JSON:', e);
					Blockly.serialization.workspaces.load({}, workspaceRef.current);
				}
			}

			// Add change listener to the workspace
			if (onChange) {
				let isLoading = true;
				workspaceRef.current.addChangeListener((action) => {
					if (action.type === Blockly.Events.FINISHED_LOADING) {
						isLoading = false;
					}
					if (action.isUiEvent || isLoading) {
						return;
					}
					if (workspaceRef.current) {
						const jsonObj = Blockly.serialization.workspaces.save(workspaceRef.current);
						jsonObj.showEditor = (workspaceRef.current as any).showEditor;
						const json = JSON.stringify(jsonObj);
						Require.clear();
						const luaCode = luaGenerator.workspaceToCode(workspaceRef.current);

						// Extract function names
						const functionMatches = luaCode.match(/^function\s+([a-zA-Z0-9_]+)/gm);
						const functionNames = functionMatches ?
							functionMatches.map(match => match.replace(/^function\s+/, '')) : [];

						// Declare all functions at the beginning if any exist
						const localDeclaration = functionNames.length > 0 ?
							`local ${functionNames.join(', ')}\n` : '';

						// Replace function declarations
						const modifiedCode = luaCode.replace(/^function\s+([a-zA-Z0-9_]+)/gm, '$1 = function');

						const requireCode = Require.getCode();
						const code = `local _ENV = setmetatable({}, {__index = _G})\n` + (requireCode === '' ? '' : requireCode + "\n") + localDeclaration + modifiedCode;
						onChange(json, code);
					}
				});
			}
		}

		// Cleanup function
		return () => {
			if (workspaceRef.current) {
				workspaceRef.current.dispose();
				workspaceRef.current = null;
			}
		};
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, []);

	// Handle window resize
	useEffect(() => {
		if (blocklyDiv.current && workspaceRef.current && typeof height === 'number' && height > 0) {
			const {scrollX, scrollY} = workspaceRef.current;
			Blockly.svgResize(workspaceRef.current);
			workspaceRef.current.scroll(scrollX, scrollY);
		}
	}, [showEditor, height, width]);

	useEffect(() => {
		if (firstView && workspaceRef.current && height > 0) {
			setFirstView(false);
			workspaceRef.current.scrollCenter();
		}
	}, [firstView, height, workspaceRef]);

	return (
		<div style={{display: 'flex', position: 'relative'}}>
			<div
				ref={blocklyDiv}
				className={`blockly-component`}
				style={{width: showEditor ? width * 0.6 : width, height}}
			/>
			{showEditor && (
				<MonacoEditor
					width={width * 0.4}
					height={height}
					language='lua'
					theme={EditorTheme}
					keepCurrentModel
					loading={editorBackground}
					path={monaco.Uri.file(path.join(path.dirname(file), path.basename(file, path.extname(file)) + '.lua')).toString()}
					options={{
						readOnly: true,
						padding: {top: 16},
						wordWrap: 'on',
						wordBreak: 'keepAll',
						selectOnLineNumbers: true,
						matchBrackets: 'near',
						fontSize: 16,
						useTabStops: false,
						insertSpaces: false,
						renderWhitespace: 'all',
						tabSize: 2,
						minimap: {
							enabled: false,
						},
					}}
				/>
			)}
			<div hidden={readOnly} style={{
				position: 'absolute',
				left: '85px',
				bottom: '15px',
				zIndex: 100
			}}>
				<Stack direction="row" spacing={1}>
					<Tooltip title={showEditor ? t('blockly.hideCode') : t('blockly.showCode')}>
						<IconButton
							onClick={() => {
								setShowEditor(!showEditor);
								if (workspaceRef.current) {
									(workspaceRef.current as any).showEditor = !showEditor;
								}
								setTimeout(() => {
									workspaceRef.current?.fireChangeListener(new Blockly.Events.BlockChange());
								}, 200);
							}}
							sx={{
								backgroundColor: 'rgba(50, 50, 50, 0.7)',
								color: 'rgba(255, 255, 255, 0.4)',
								'&:hover': {
									backgroundColor: 'rgba(70, 70, 70, 0.9)',
								}
							}}
						>
							{showEditor ? <CodeOffIcon /> : <CodeIcon />}
						</IconButton>
					</Tooltip>
					<Tooltip title={t('blockly.save') || "保存"}>
						<IconButton
							onClick={onSave}
							sx={{
								backgroundColor: 'rgba(50, 50, 50, 0.7)',
								color: 'rgba(255, 255, 255, 0.4)',
								'&:hover': {
									backgroundColor: 'rgba(70, 70, 70, 0.9)',
								}
							}}
						>
							<SaveIcon />
						</IconButton>
					</Tooltip>
				</Stack>
			</div>
		</div>
	);
};

export default BlocklyComponent;
