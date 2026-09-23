import assert from 'node:assert/strict';
import { build } from 'esbuild';
import { mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const directory = await mkdtemp(path.join(tmpdir(), 'dora-auth-signature-'));
try {
	const outfile = path.join(directory, 'auth-signature.mjs');
	await build({
		entryPoints: ['src/AuthSignature.ts'],
		outfile,
		bundle: true,
		platform: 'node',
		format: 'esm',
	});
	const { canonicalizeAuthPath } = await import(pathToFileURL(outfile).href);

	assert.equal(
		canonicalizeAuthPath(new URL('http://localhost:8866/upload?path=C%3A%5CUsers%5CJin%5CDesktop%5Cdora-test')),
		'/upload?path=C%3A%5CUsers%5CJin%5CDesktop%5Cdora-test',
	);
	assert.equal(
		canonicalizeAuthPath(new URL('http://localhost:8866/upload?path=%2FUsers%2FJin%2FDora%20Project')),
		'/upload?path=%2FUsers%2FJin%2FDora%20Project',
	);
	assert.equal(
		canonicalizeAuthPath(new URL('http://localhost:8866/test?z=a%2Bb&name=%E4%B8%AD%E6%96%87%5B1%5D&a=2&a=1')),
		'/test?a=1&a=2&name=%E4%B8%AD%E6%96%87%5B1%5D&z=a%2Bb',
	);
	assert.equal(
		canonicalizeAuthPath(new URL("http://localhost:8866/test?path=Project!'()*")),
		'/test?path=Project%21%27%28%29%2A',
	);
	assert.equal(canonicalizeAuthPath(new URL('http://localhost:8866/info')), '/info');
} finally {
	await rm(directory, { recursive: true, force: true });
}

console.log('Auth signature canonicalization tests passed.');
