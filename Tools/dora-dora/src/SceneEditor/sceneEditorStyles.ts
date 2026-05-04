/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

export const sceneEditorColors = {
	background: '#050607',
	panel: 'rgba(18,20,23,0.72)',
	panelDeep: 'rgba(5,6,7,0.86)',
	panelHeader: 'rgba(255,255,255,0.045)',
	card: 'rgba(255,255,255,0.055)',
	line: 'rgba(255,255,255,0.10)',
	lineStrong: 'rgba(255,255,255,0.18)',
	primary: '#ffd21a',
	primaryDark: '#d6aa00',
	text: 'rgba(255,255,255,0.88)',
	muted: 'rgba(255,255,255,0.42)',
	mutedStrong: 'rgba(255,255,255,0.62)',
	selected: 'rgba(255,210,26,0.14)',
	selectedBorder: 'rgba(255,210,26,0.72)',
	grid: 'rgba(255,255,255,0.045)',
	xAxis: 'rgba(255,84,84,0.68)',
	yAxis: 'rgba(75,190,108,0.68)',
};

export const sceneEditorLayout = {
	topBarHeight: 58,
	leftWidth: 300,
	rightWidth: 380,
	statusHeight: 34,
};

export const panelSx = {
	background: `linear-gradient(180deg, ${sceneEditorColors.panel} 0%, ${sceneEditorColors.panelDeep} 100%)`,
	backdropFilter: 'blur(18px) saturate(130%)',
	WebkitBackdropFilter: 'blur(18px) saturate(130%)',
	border: `1px solid ${sceneEditorColors.line}`,
	boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.06), 0 18px 50px rgba(0,0,0,0.45)',
	borderRadius: 1.25,
	overflow: 'hidden',
};
