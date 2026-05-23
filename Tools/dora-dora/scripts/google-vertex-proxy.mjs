#!/usr/bin/env node
/* global Buffer, URL, console, process */
/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { createServer } from 'node:http';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { chmodSync, existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { spawn, spawnSync } from 'node:child_process';

const defaultPort = 8877;
const defaultLocation = 'global';
const defaultModel = 'gemini-3-pro-image-preview';
const gemini3ProImageModel = 'gemini-3-pro-image-preview';
const maxBodyBytes = 24 * 1024 * 1024;
const dataUrlPattern = /^data:([^;,]+);base64,(.*)$/s;

const jsonResponse = (response, status, data) => {
	const body = JSON.stringify(data);
	response.writeHead(status, {
		'Access-Control-Allow-Origin': '*',
		'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
		'Access-Control-Allow-Headers': 'Content-Type,Authorization',
		'Content-Type': 'application/json; charset=utf-8',
		'Content-Length': Buffer.byteLength(body),
	});
	response.end(body);
};

const emptyResponse = (response, status) => {
	response.writeHead(status, {
		'Access-Control-Allow-Origin': '*',
		'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
		'Access-Control-Allow-Headers': 'Content-Type,Authorization',
	});
	response.end();
};

const readRequestBody = (request) => new Promise((resolve, reject) => {
	const chunks = [];
	let size = 0;
	request.on('data', (chunk) => {
		size += chunk.length;
		if (size > maxBodyBytes) {
			reject(new Error(`request body is larger than ${maxBodyBytes} bytes`));
			request.destroy();
			return;
		}
		chunks.push(chunk);
	});
	request.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
	request.on('error', reject);
});

const runCommand = (command, args, options = {}) => {
	const result = spawnSync(command, args, {
		encoding: 'utf8',
		stdio: ['ignore', 'pipe', 'pipe'],
		...options,
	});
	if (result.error !== undefined) {
		throw result.error;
	}
	if (result.status !== 0) {
		throw new Error(result.stderr.trim() || `${command} exited with ${result.status}`);
	}
	return result.stdout.trim();
};

const findExecutable = (candidates) => {
	for (const candidate of candidates) {
		if (candidate === undefined || candidate === '') continue;
		if (candidate.includes('/') && existsSync(candidate)) return candidate;
		if (!candidate.includes('/')) {
			const result = spawnSync('/bin/zsh', ['-lc', `command -v ${candidate}`], {
				encoding: 'utf8',
				stdio: ['ignore', 'pipe', 'ignore'],
			});
			const found = result.stdout.trim();
			if (result.status === 0 && found !== '') return found;
		}
	}
	return undefined;
};

const detectSystemProxy = () => {
	if (process.env.GOOGLE_VERTEX_HTTP_PROXY !== undefined) return process.env.GOOGLE_VERTEX_HTTP_PROXY;
	if (process.env.HTTPS_PROXY !== undefined) return process.env.HTTPS_PROXY;
	if (process.env.https_proxy !== undefined) return process.env.https_proxy;
	const result = spawnSync('scutil', ['--proxy'], {
		encoding: 'utf8',
		stdio: ['ignore', 'pipe', 'ignore'],
	});
	if (result.status !== 0) return undefined;
	const text = result.stdout;
	const enabled = /HTTPSEnable\s*:\s*1/.test(text);
	if (!enabled) return undefined;
	const host = text.match(/HTTPSProxy\s*:\s*(.+)/)?.[1]?.trim();
	const port = text.match(/HTTPSPort\s*:\s*(\d+)/)?.[1]?.trim();
	if (host === undefined || port === undefined) return undefined;
	return `http://${host}:${port}`;
};

const readConfig = () => {
	const gcloud = findExecutable([
		process.env.GCLOUD_BIN,
		'gcloud',
		'/opt/homebrew/share/google-cloud-sdk/bin/gcloud',
		'/Users/wangyue/yueangvpn/tools/google-cloud-sdk/bin/gcloud',
	]);
	if (gcloud === undefined) {
		throw new Error('gcloud was not found. Set GCLOUD_BIN or install Google Cloud SDK.');
	}
	const configuredProject = (() => {
		try {
			return runCommand(gcloud, ['config', 'get-value', 'project']).trim();
		} catch {
			return '';
		}
	})();
	const project = process.env.GOOGLE_VERTEX_PROJECT ||
		process.env.GOOGLE_CLOUD_PROJECT ||
		process.env.GCLOUD_PROJECT ||
		configuredProject;
	if (project === undefined || project === '' || project === '(unset)') {
		throw new Error('Google Cloud project is not configured. Set GOOGLE_VERTEX_PROJECT.');
	}
	return {
		gcloud,
		project,
		location: process.env.GOOGLE_VERTEX_LOCATION || defaultLocation,
		model: process.env.GOOGLE_VERTEX_MODEL || defaultModel,
		port: Number.parseInt(process.env.GOOGLE_VERTEX_PROXY_PORT || `${defaultPort}`, 10),
		proxy: detectSystemProxy(),
	};
};

const parseDataUrl = (value) => {
	const match = value.match(dataUrlPattern);
	if (match === null) return undefined;
	return {
		mimeType: match[1],
		data: match[2].replace(/\s+/g, ''),
	};
};

const normalizeInlineImageValue = (value, mimeType) => {
	if (typeof value !== 'string') return undefined;
	const parsed = parseDataUrl(value);
	if (parsed !== undefined) return parsed;
	return {
		mimeType: typeof mimeType === 'string' && mimeType !== '' ? mimeType : 'image/png',
		data: value.replace(/\s+/g, ''),
	};
};

const normalizeInlineImages = (body) => {
	if (Array.isArray(body.referenceImages)) {
		return body.referenceImages
			.map((image) => normalizeInlineImageValue(image, body.referenceImageMimeType))
			.filter((image) => image !== undefined);
	}
	if (typeof body.referenceImage === 'string') {
		const parsed = parseDataUrl(body.referenceImage);
		if (parsed !== undefined) return [parsed];
		return [{
			mimeType: body.referenceImageMimeType || 'image/png',
			data: body.referenceImage.replace(/\s+/g, ''),
		}];
	}
	if (typeof body.referenceImageBase64 === 'string') {
		return [{
			mimeType: body.referenceImageMimeType || 'image/png',
			data: body.referenceImageBase64.replace(/\s+/g, ''),
		}];
	}
	return [];
};

const createVertexRequest = (body) => {
	if (typeof body.prompt !== 'string' || body.prompt.trim() === '') {
		throw new Error('request.prompt is required');
	}
	const parts = [{ text: body.prompt }];
	const images = normalizeInlineImages(body);
	for (const image of images) {
		parts.push({
			inlineData: {
				mimeType: image.mimeType,
				data: image.data,
			},
		});
	}
	return {
		contents: [
			{
				role: 'user',
				parts,
			},
		],
		generationConfig: {
			responseModalities: ['TEXT', 'IMAGE'],
		},
	};
};

const buildProxyEnvironment = (proxy) => {
	if (proxy === undefined) return process.env;
	return {
		...process.env,
		HTTPS_PROXY: proxy,
		HTTP_PROXY: proxy,
		https_proxy: proxy,
		http_proxy: proxy,
	};
};

const callVertex = async (config, vertexRequest, modelOverride) => {
	const workDir = await mkdtemp(path.join(tmpdir(), 'dora-google-vertex-'));
	const requestPath = path.join(workDir, 'request.json');
	const responsePath = path.join(workDir, 'response.json');
	const curlConfigPath = path.join(workDir, 'curl.conf');
	try {
		const token = runCommand(config.gcloud, ['auth', 'print-access-token'], {
			env: buildProxyEnvironment(config.proxy),
		});
		const curlConfigLines = [
			config.proxy === undefined ? '' : `proxy = "${config.proxy}"`,
			`header = "Authorization: Bearer ${token}"`,
			'header = "Content-Type: application/json"',
			'max-time = 180',
			'connect-timeout = 15',
			'silent',
			'show-error',
		].filter((line) => line !== '');
		await writeFile(requestPath, JSON.stringify(vertexRequest));
		await writeFile(curlConfigPath, `${curlConfigLines.join('\n')}\n`);
		chmodSync(curlConfigPath, 0o600);
		const model = typeof modelOverride === 'string' && modelOverride !== '' ? modelOverride : config.model;
		const url = `https://aiplatform.googleapis.com/v1/projects/${config.project}/locations/${config.location}/publishers/google/models/${model}:generateContent`;
		const httpCode = await new Promise((resolve, reject) => {
			const child = spawn('curl', [
				'-K', curlConfigPath,
				'-o', responsePath,
				'-w', '%{http_code}',
				'-X', 'POST',
				url,
				'-d', `@${requestPath}`,
			], {
				stdio: ['ignore', 'pipe', 'pipe'],
			});
			let stdout = '';
			let stderr = '';
			child.stdout.on('data', (chunk) => {
				stdout += chunk.toString('utf8');
			});
			child.stderr.on('data', (chunk) => {
				stderr += chunk.toString('utf8');
			});
			child.on('error', reject);
			child.on('close', (code) => {
				if (code !== 0) {
					reject(new Error(stderr.trim() || `curl exited with ${code}`));
					return;
				}
				resolve(stdout.trim());
			});
		});
		const responseText = await readFile(responsePath, 'utf8');
		const vertexResponse = JSON.parse(responseText);
		return { httpCode, vertexResponse };
	} finally {
		await rm(workDir, { recursive: true, force: true });
	}
};

const extractImageResult = (vertexResponse) => {
	if (vertexResponse.error !== undefined) {
		return {
			success: false,
			message: vertexResponse.error.message || 'Vertex AI request failed',
			error: {
				code: vertexResponse.error.code,
				status: vertexResponse.error.status,
			},
		};
	}
	const parts = vertexResponse.candidates?.[0]?.content?.parts;
	if (!Array.isArray(parts)) {
		return {
			success: false,
			message: 'Vertex AI response did not include candidates[0].content.parts',
		};
	}
	const text = parts
		.filter((part) => typeof part.text === 'string')
		.map((part) => part.text)
		.join('\n')
		.trim();
	const imagePart = parts.find((part) => part.inlineData?.data !== undefined || part.inline_data?.data !== undefined);
	const inlineData = imagePart?.inlineData || imagePart?.inline_data;
	if (inlineData === undefined) {
		return {
			success: false,
			message: text === '' ? 'Vertex AI response did not include an image' : text,
			text,
			usage: vertexResponse.usageMetadata || vertexResponse.usage_metadata,
		};
	}
	return {
		success: true,
		text,
		mimeType: inlineData.mimeType || inlineData.mime_type || 'image/png',
		imageBase64: inlineData.data,
		usage: vertexResponse.usageMetadata || vertexResponse.usage_metadata,
	};
};

const handleGenerateFrame = async (request, response, config) => {
	const rawBody = await readRequestBody(request);
	const body = rawBody === '' ? {} : JSON.parse(rawBody);
	const vertexRequest = createVertexRequest(body);
	const { httpCode, vertexResponse } = await callVertex(config, vertexRequest);
	const result = extractImageResult(vertexResponse);
	jsonResponse(response, result.success ? 200 : Number(httpCode) || 500, result);
};

const handleGenerateSprite = async (request, response, config) => {
	const rawBody = await readRequestBody(request);
	const body = rawBody === '' ? {} : JSON.parse(rawBody);
	const vertexRequest = createVertexRequest(body);
	const { httpCode, vertexResponse } = await callVertex(config, vertexRequest, gemini3ProImageModel);
	const result = extractImageResult(vertexResponse);
	jsonResponse(response, result.success ? 200 : Number(httpCode) || 500, result);
};

const startServer = () => {
	const config = readConfig();
	const server = createServer((request, response) => {
		void (async () => {
			if (request.method === 'OPTIONS') {
				emptyResponse(response, 204);
				return;
			}
			const url = new URL(request.url || '/', `http://${request.headers.host || '127.0.0.1'}`);
			if (request.method === 'GET' && url.pathname === '/health') {
				jsonResponse(response, 200, {
					success: true,
					project: config.project,
					location: config.location,
					model: config.model,
					proxy: config.proxy === undefined ? null : config.proxy,
				});
				return;
			}
			if (request.method === 'POST' && url.pathname === '/api/google-vertex/generate-frame') {
				await handleGenerateFrame(request, response, config);
				return;
			}
			if (request.method === 'POST' && url.pathname === '/api/google-gemini/generate-sprite') {
				await handleGenerateSprite(request, response, config);
				return;
			}
			jsonResponse(response, 404, {
				success: false,
				message: 'Not found. Use POST /api/google-gemini/generate-sprite, POST /api/google-vertex/generate-frame, or GET /health.',
			});
		})().catch((error) => {
			const message = error instanceof Error ? error.message : String(error);
			jsonResponse(response, 500, {
				success: false,
				message,
			});
		});
	});
	server.listen(config.port, '127.0.0.1', () => {
		console.log(`Google Vertex Proxy listening on http://127.0.0.1:${config.port}`);
		console.log(`Project=${config.project} Location=${config.location} Model=${config.model}`);
		if (config.proxy !== undefined) {
			console.log(`HTTP proxy=${config.proxy}`);
		}
	});
};

startServer();
