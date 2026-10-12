/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

import { getDiagnosticMessage, transpileTypescript, warmupTypescriptTranspiler } from './TranspileTS';
import type { TranspileTSVirtualFile } from './Service';
import Info from './Info';
import Path from './3rdParty/Path';

type CompilerJob = {
	id: number;
	file: string;
	content: string;
	projectRoot?: string;
	files?: TranspileTSVirtualFile[];
};

type PollResponse = {
	success: boolean;
	job?: CompilerJob;
};

const post = async <T>(path: string, body: object = {}): Promise<T> => {
	const response = await fetch(path, {
		method: 'POST',
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(body),
		cache: 'no-store',
	});
	if (!response.ok) {
		throw new Error(`${path} failed with HTTP ${response.status}`);
	}
	return await response.json() as T;
};

const delay = (milliseconds: number) => new Promise<void>((resolve) => {
	setTimeout(resolve, milliseconds);
});

const runJob = async (job: CompilerJob) => {
	try {
		const { success, luaCode, diagnostics } = await transpileTypescript(
			job.file,
			job.content,
			job.projectRoot,
			job.files,
		);
		const message = success ? '' : await getDiagnosticMessage(job.file, diagnostics);
		await post('/compiler/result', {
			id: job.id,
			success,
			file: job.file,
			luaCode: success ? luaCode : '',
			message,
		});
	} catch (error) {
		const message = error instanceof Error ? error.message : String(error);
		await post('/compiler/result', {
			id: job.id,
			success: false,
			file: job.file,
			luaCode: '',
			message,
		});
	}
};

const main = async () => {
	// The compiler page does not load the IDE's index.tsx bootstrap. Select
	// paths from the engine platform before warming up the shared TSTL module.
	const { platform } = await post<{ platform: string }>('/status');
	Info.platform = platform;
	Info.path = platform === 'Windows' ? Path.win32 : Path.posix;
	Path.setPath(Info.path);
	console.info('Dora compiler warmup started');
	await warmupTypescriptTranspiler();
	console.info('Dora compiler warmup completed');
	await post('/compiler/ready');
	console.info('Dora compiler is ready');
	for (;;) {
		try {
			const response = await post<PollResponse>('/compiler/poll');
			if (!response.success) return;
			if (response.job) {
				await runJob(response.job);
			}
			// The server holds idle polls. Avoid background WebView timer
			// throttling between jobs while keeping idle requests bounded.
			continue;
		} catch (error) {
			console.error('Compiler polling failed:', error);
		}
		await delay(100);
	}
};

void main().catch(async (error) => {
	console.error('Failed to initialize the Dora TypeScript compiler:', error);
	try {
		await post('/compiler/failure', {
			message: error instanceof Error ? error.message : String(error),
		});
	} catch (reportError) {
		console.error('Failed to report compiler initialization failure:', reportError);
	}
});
