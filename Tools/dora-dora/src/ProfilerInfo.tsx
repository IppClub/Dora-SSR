/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

export interface ProfilerInfo {
	renderer: string;
	multiThreaded: boolean;
	backBufferX: number;
	backBufferY: number;
	drawCall: number;
	tri: number;
	line: number;
	visualSizeX: number;
	visualSizeY: number;
	vSync: boolean;
	fpsLimited: boolean;
	targetFPS: number;
	maxTargetFPS: number;
	fixedFPS: number;
	currentFPS: number;
	avgCPU: number;
	avgGPU: number;
	plotCount: number;
	cpuTimePeeks: number[];
	gpuTimePeeks: number[];
	deltaTimePeeks: number[];
	updateCosts: UpdateCost[];
	cppObject: number;
	luaObject: number;
	luaCallback: number;
	textures: number;
	fonts: number;
	audios: number;
	memoryPool: number;
	luaMemory: number;
	tealMemory: number;
	wasmMemory: number;
	textureMemory: number;
	fontMemory: number;
	audioMemory: number;
	loaderCosts?: LoaderCost[];
}

export interface LoaderCost {
	order: number;
	time: number;
	depth: number;
	moduleName: string;
}

export interface UpdateCost {
	name: string;
	value: number;
}
