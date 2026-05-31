import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';
import { defineConfig, loadEnv, type Plugin } from 'vite';
import react from '@vitejs/plugin-react';
import { codeInspectorPlugin } from 'code-inspector-plugin';
import monacoEditorPlugin from 'vite-plugin-monaco-editor';

const require = createRequire(import.meta.url);

type MonacoLocaleOptions = {
	languages: string[];
	defaultLanguage: string;
	logUnmatched?: boolean;
	mapLanguages?: Record<string, Record<string, string>>;
};

const monacoLocalePlugin = (options: MonacoLocaleOptions): Plugin => {
	const en = require('./config/monaco-editor-locales-plugin/lib/editor.main.nls.en.js');
	const zhCn = require('./config/monaco-editor-locales-plugin/lib/editor.main.nls.zh-cn.js');
	const mapEmbedLangName: Record<string, Record<string, unknown>> = {
		en,
		'zh-cn': zhCn,
	};
	const mapEmbedLangNameSelf: Record<string, Record<string, string>> = {
		'zh-cn': {},
	};

	const mapLangIdx: Record<string, number> = {};
	const lang: Record<string, Record<number, string>> = {};
	let langIdx = 0;

	const getLangIdx = (enKey: string) => {
		if (enKey in mapLangIdx) {
			return mapLangIdx[enKey];
		}
		const idx = langIdx;
		mapLangIdx[enKey] = idx;
		langIdx += 1;
		return idx;
	};

	const initOneLang = (
		rstObj: Record<number, string>,
		enObj: Record<string, unknown>,
		langObj: Record<string, unknown>
	) => {
		for (const key of Object.keys(enObj)) {
			const enValue = enObj[key];
			const langValue = langObj[key];
			if (typeof enValue === 'string' && typeof langValue === 'string') {
				const idx = getLangIdx(enValue);
				rstObj[idx] = langValue;
			} else if (
				enValue &&
				langValue &&
				typeof enValue === 'object' &&
				typeof langValue === 'object'
			) {
				initOneLang(
					rstObj,
					enValue as Record<string, unknown>,
					langValue as Record<string, unknown>
				);
			}
		}
	};

	const initSelfOneLang = (
		rstObj: Record<number, string>,
		obj: Record<string, string>
	) => {
		for (const key of Object.keys(obj)) {
			const idx = getLangIdx(key);
			rstObj[idx] = obj[key];
		}
	};

	for (const langKey of options.languages) {
		if (!(langKey in mapEmbedLangName)) {
			continue;
		}
		const baseObj = mapEmbedLangName[langKey];
		if (!baseObj) {
			continue;
		}
		const rstObj = lang[langKey] || (lang[langKey] = {});
		initOneLang(rstObj, mapEmbedLangName.en, baseObj);
		const selfObj = mapEmbedLangNameSelf[langKey];
		if (selfObj) {
			initSelfOneLang(rstObj, selfObj);
		}
		const customObj = options.mapLanguages?.[langKey];
		if (customObj) {
			initSelfOneLang(rstObj, customObj);
		}
	}

	const selectLangStr = (() => {
		const cleaned = options.defaultLanguage
			.replace(/'/g, "\\'")
			.replace(/\r\n/g, '\\r\\n')
			.replace(/\n/g, '\\n');
		return `'${cleaned}'`;
	})();

	return {
		name: 'monaco-editor-locales',
		enforce: 'post',
		transform(code, id) {
			if (!id.replace(/\\+/g, '/').includes('monaco-editor/esm/vs/nls.js')) {
				return null;
			}

			const endl = '\n';
			let out = code.replace('function localize', 'function _ocalize');
			out += `${endl}function localize(data, message) {`;
			out += `${endl}  if (typeof(message) === 'string') {`;
			out += `${endl}    var mapLang = localize.mapSelfLang[localize.selectLang] || {};`;
			out += `${endl}    if (typeof(mapLang[message]) === 'string') {`;
			out += `${endl}      message = mapLang[message];`;
			out += `${endl}    } else {`;
			out += `${endl}      var idx = localize.mapLangIdx[message];`;
			out += `${endl}      if (idx === undefined) {`;
			out += `${endl}        idx = -1;`;
			out += `${endl}      }`;
			out += `${endl}      var nlsLang = localize.mapNlsLang[localize.selectLang] || {};`;
			out += `${endl}      if (idx in nlsLang) {`;
			out += `${endl}        message = nlsLang[idx];`;
			out += `${endl}      }`;
			if (options.logUnmatched) {
				out += `${endl}      else {`;
				out += `${endl}        console.info('unknown lang: ' + message);`;
				out += `${endl}      }`;
			}
			out += `${endl}    }`;
			out += `${endl}  }`;
			out += `${endl}  var args = [];`;
			out += `${endl}  for(var i = 0; i < arguments.length; ++i){`;
			out += `${endl}    args.push(arguments[i]);`;
			out += `${endl}  }`;
			out += `${endl}  args[1] = message;`;
			out += `${endl}  return _ocalize.apply(this, args);`;
			out += `${endl}}`;
			out = out.replace('function localize2', 'function _ocalize2');
			out += `${endl}function localize2(data, message) {`;
			out += `${endl}  if (typeof(message) === 'string') {`;
			out += `${endl}    var mapLang = localize.mapSelfLang[localize.selectLang] || {};`;
			out += `${endl}    if (typeof(mapLang[message]) === 'string') {`;
			out += `${endl}      message = mapLang[message];`;
			out += `${endl}    } else {`;
			out += `${endl}      var idx = localize.mapLangIdx[message];`;
			out += `${endl}      if (idx === undefined) {`;
			out += `${endl}        idx = -1;`;
			out += `${endl}      }`;
			out += `${endl}      var nlsLang = localize.mapNlsLang[localize.selectLang] || {};`;
			out += `${endl}      if (idx in nlsLang) {`;
			out += `${endl}        message = nlsLang[idx];`;
			out += `${endl}      }`;
			if (options.logUnmatched) {
				out += `${endl}      else {`;
				out += `${endl}        console.info('unknown lang: ' + message);`;
				out += `${endl}      }`;
			}
			out += `${endl}    }`;
			out += `${endl}  }`;
			out += `${endl}  var args = [];`;
			out += `${endl}  for(var i = 0; i < arguments.length; ++i){`;
			out += `${endl}    args.push(arguments[i]);`;
			out += `${endl}  }`;
			out += `${endl}  args[1] = message;`;
			out += `${endl}  return _ocalize2.apply(this, args);`;
			out += `${endl}}`;
			out += `${endl}localize.selectLang = ${selectLangStr};`;
			if (selectLangStr.includes('(')) {
				out += `${endl}try { localize.selectLang = eval(localize.selectLang); } catch(ex){}`;
			}
			out += `${endl}localize.mapLangIdx = ${JSON.stringify(mapLangIdx)};`;
			out += `${endl}localize.mapNlsLang = ${JSON.stringify(lang)};`;
			out += `${endl}localize.mapSelfLang = ${JSON.stringify(options.mapLanguages || {})};`;
			out += `${endl}`;
			return out;
		},
	};
};

const rootDir = path.dirname(fileURLToPath(import.meta.url));
const emptyModule = path.join(rootDir, 'src/3rdParty/empty.ts');
const yarnEditorPublicDir = path.join(rootDir, 'src/3rdParty/YarnEditor/public');
const yarnEditorIndexHtml = path.join(yarnEditorPublicDir, 'index.html');
const codeWirePublicDir = path.join(rootDir, 'src/3rdParty/CodeWire/public');
const codeWireIndexHtml = path.join(codeWirePublicDir, 'index.html');
const codeWireVendorScripts = [
	'javascript/Dependencies/CodeMirror/codemirror.js',
	'javascript/Dependencies/CodeMirror/lua/lua.js',
	'javascript/Dependencies/jquery/jquery.js',
	'javascript/Dependencies/Konva/konva.min.js',
];
const codeWireVendorStyles = [
	'style.css',
	'codewire-bootstrap.css',
	'fontawesome/free.min.css',
	'fontawesome/free-v4-shims.min.css',
	'fontawesome/free-v4-font-face.min.css',
	'javascript/Dependencies/CodeMirror/codemirror.css',
	'javascript/Dependencies/CodeMirror/material-darker.css',
];

const readStaticFiles = (dir: string, prefix = ''): { absolutePath: string; relativePath: string }[] => {
	return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
		if (entry.name.startsWith('.')) return [];
		const relativePath = path.posix.join(prefix, entry.name);
		const absolutePath = path.join(dir, entry.name);
		if (entry.isDirectory()) {
			return readStaticFiles(absolutePath, relativePath);
		}
		return [{ absolutePath, relativePath }];
	});
};

const getContentType = (filePath: string) => {
	switch (path.extname(filePath)) {
		case '.css': return 'text/css';
		case '.html': return 'text/html';
		case '.js': return 'text/javascript';
		case '.json': return 'application/json';
		case '.png': return 'image/png';
		case '.svg': return 'image/svg+xml';
		case '.ico': return 'image/x-icon';
		case '.woff2': return 'font/woff2';
		default: return 'application/octet-stream';
	}
};

const findHtmlBundleAsset = (
	bundle: Parameters<NonNullable<Plugin['generateBundle']>>[1],
	htmlPath: string
) => {
	const htmlFileName = path.relative(rootDir, htmlPath).replace(/\\/g, '/');
	const htmlKey = Object.keys(bundle).find((key) => (
		key === htmlFileName ||
		bundle[key].fileName === htmlFileName
	));
	return htmlKey ? { key: htmlKey, asset: bundle[htmlKey] } : undefined;
};

const stripSourceMapComments = (code: string) => (
	code
		.replace(/\/\/# sourceMappingURL=.*(?:\r?\n|$)/g, '')
		.replace(/\/\*# sourceMappingURL=.*?\*\//g, '')
);

const shouldEmitCodeWireStaticFile = (relativePath: string) => {
	if (relativePath === 'index.html') return false;
	if (relativePath === 'javascript/Dependencies/CodeMirror/lua/index.html') return false;
	if (relativePath === 'bootstrap.bundle.min.js' || relativePath === 'bootstrap.min.css') return false;
	if (codeWireVendorScripts.includes(relativePath)) return false;
	if (codeWireVendorStyles.includes(relativePath)) return false;
	if (relativePath.startsWith('javascript/') && relativePath.endsWith('.js')) return false;
	return true;
};

const readCodeWireVendorBundle = () => (
	codeWireVendorScripts
		.map((relativePath) => (
			`/* ${relativePath} */\n${stripSourceMapComments(fs.readFileSync(path.join(codeWirePublicDir, relativePath), 'utf8'))}`
		))
		.join('\n;\n')
);

const readCodeWireVendorStyleBundle = () => (
	codeWireVendorStyles
		.map((relativePath) => {
			const source = stripSourceMapComments(fs.readFileSync(path.join(codeWirePublicDir, relativePath), 'utf8'))
				.replace(/url\(\.\.\/webfonts\//g, 'url(webfonts/');
			return `/* ${relativePath} */\n${source}`;
		})
		.join('\n')
);

const replaceCodeWireVendorScripts = (html: string) => {
	const vendorScriptTags = codeWireVendorScripts
		.map((relativePath) => `<script src="./${relativePath}" ></script>`)
		.join('\n');
	return html.replace(vendorScriptTags, '<script src="./vendor.js"></script>');
};

const escapeRegExp = (value: string) => (
	value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
);

const replaceCodeWireVendorStyles = (html: string) => {
	let replaced = false;
	let output = html;
	for (const relativePath of codeWireVendorStyles) {
		const pattern = new RegExp(
			`<link\\s+[^>]*href=["'](?:\\./)?${escapeRegExp(relativePath)}["'][^>]*>\\s*`,
			'g'
		);
		output = output.replace(pattern, () => {
			if (replaced) return '';
			replaced = true;
			return '<link rel="stylesheet" href="./vendor.css">\n';
		});
	}
	return output;
};

const replaceCodeWireEntryScriptForDev = (html: string) => (
	html.replace(
		'<script type="module" src="./javascript/main/main.js"></script>',
		'<script type="module" src="/src/3rdParty/CodeWire/public/javascript/main/main.js"></script>'
	)
);

const prepareCodeWireHtml = (html: string, dev = false) => {
	let output = replaceCodeWireVendorStyles(replaceCodeWireVendorScripts(html));
	if (dev) {
		output = replaceCodeWireEntryScriptForDev(output);
	}
	return output;
};

const shouldEmitYarnEditorStaticFile = (relativePath: string) => {
	if (relativePath === 'index.html' || relativePath === 'version.json') return false;
	if (relativePath === 'templates/node.html') return false;
	if (relativePath === 'plugins/index.js') return false;
	if (relativePath === 'plugins/runner.js') return false;
	if (relativePath === 'plugins/bondage/renderer.js') return false;
	return true;
};

const yarnEditorStaticPlugin = (): Plugin => ({
	name: 'yarn-editor-static',
	enforce: 'post',
	configureServer(server) {
		server.middlewares.use(async (req, res, next) => {
			const url = req.url?.split('?')[0] || '';
			if (url === '/yarn-editor/index.html' || url === '/yarn-editor/') {
				const html = fs.readFileSync(yarnEditorIndexHtml, 'utf8');
				res.setHeader('Cache-Control', 'no-store');
				res.setHeader('Content-Type', 'text/html');
				res.end(await server.transformIndexHtml(url, html));
				return;
			}
			if (!url.startsWith('/yarn-editor/public/')) {
				next();
				return;
			}
			const relativePath = decodeURIComponent(url.slice('/yarn-editor/public/'.length));
			const absolutePath = path.resolve(yarnEditorPublicDir, relativePath);
			if (!absolutePath.startsWith(yarnEditorPublicDir) || !fs.existsSync(absolutePath)) {
				next();
				return;
			}
			res.setHeader('Cache-Control', 'no-store');
			res.setHeader('Content-Type', getContentType(absolutePath));
			res.end(fs.readFileSync(absolutePath));
		});
	},
	generateBundle(_options, bundle) {
		const yarnEditorHtmlFileName = path.relative(rootDir, yarnEditorIndexHtml).replace(/\\/g, '/');
		const yarnEditorHtmlKey = Object.keys(bundle).find((key) => (
			key === yarnEditorHtmlFileName ||
			bundle[key].fileName === yarnEditorHtmlFileName
		));
		const yarnEditorHtml = yarnEditorHtmlKey ? bundle[yarnEditorHtmlKey] : undefined;
		if (yarnEditorHtml) {
			delete bundle[yarnEditorHtmlKey as string];
			yarnEditorHtml.fileName = 'yarn-editor/index.html';
			bundle[yarnEditorHtml.fileName] = yarnEditorHtml;
		}
		for (const file of readStaticFiles(yarnEditorPublicDir)) {
			if (!shouldEmitYarnEditorStaticFile(file.relativePath)) continue;
			this.emitFile({
				type: 'asset',
				fileName: `yarn-editor/public/${file.relativePath}`,
				source: fs.readFileSync(file.absolutePath),
			});
		}
	},
});

const codeWireStaticPlugin = (): Plugin => ({
	name: 'code-wire-static',
	enforce: 'post',
	configureServer(server) {
		server.middlewares.use(async (req, res, next) => {
			const url = req.url?.split('?')[0] || '';
			if (url === '/code-wire/index.html' || url === '/code-wire/') {
				const html = prepareCodeWireHtml(fs.readFileSync(codeWireIndexHtml, 'utf8'), true);
				res.setHeader('Cache-Control', 'no-store');
				res.setHeader('Content-Type', 'text/html');
				res.end(await server.transformIndexHtml(url, html));
				return;
			}
			if (url === '/code-wire/vendor.js') {
				res.setHeader('Cache-Control', 'no-store');
				res.setHeader('Content-Type', 'text/javascript');
				res.end(readCodeWireVendorBundle());
				return;
			}
			if (url === '/code-wire/vendor.css') {
				res.setHeader('Cache-Control', 'no-store');
				res.setHeader('Content-Type', 'text/css');
				res.end(readCodeWireVendorStyleBundle());
				return;
			}
			if (!url.startsWith('/code-wire/')) {
				next();
				return;
			}
			const relativePath = decodeURIComponent(url.slice('/code-wire/'.length));
			const absolutePath = path.resolve(codeWirePublicDir, relativePath);
			if (!absolutePath.startsWith(codeWirePublicDir) || !fs.existsSync(absolutePath)) {
				next();
				return;
			}
			res.setHeader('Cache-Control', 'no-store');
			res.setHeader('Content-Type', getContentType(absolutePath));
			res.end(fs.readFileSync(absolutePath));
		});
	},
	generateBundle(_options, bundle) {
		const codeWireHtml = findHtmlBundleAsset(bundle, codeWireIndexHtml);
		if (codeWireHtml) {
			delete bundle[codeWireHtml.key];
			codeWireHtml.asset.fileName = 'code-wire/index.html';
			if ('source' in codeWireHtml.asset && typeof codeWireHtml.asset.source === 'string') {
				codeWireHtml.asset.source = prepareCodeWireHtml(codeWireHtml.asset.source);
			}
			bundle[codeWireHtml.asset.fileName] = codeWireHtml.asset;
		}
		this.emitFile({
			type: 'asset',
			fileName: 'code-wire/vendor.js',
			source: readCodeWireVendorBundle(),
		});
		this.emitFile({
			type: 'asset',
			fileName: 'code-wire/vendor.css',
			source: readCodeWireVendorStyleBundle(),
		});
		for (const file of readStaticFiles(codeWirePublicDir)) {
			if (!shouldEmitCodeWireStaticFile(file.relativePath)) continue;
			this.emitFile({
				type: 'asset',
				fileName: `code-wire/${file.relativePath}`,
				source: fs.readFileSync(file.absolutePath),
			});
		}
	},
});

export default defineConfig(({ mode }) => {
	const env = loadEnv(mode, process.cwd(), '');
	const publicUrl = env.PUBLIC_URL || '/';

	return {
		base: publicUrl.endsWith('/') ? publicUrl : `${publicUrl}/`,
		publicDir: 'public',
		build: {
			outDir: 'build',
			sourcemap: env.GENERATE_SOURCEMAP !== 'false',
			rollupOptions: {
				input: {
					main: path.join(rootDir, 'index.html'),
					yarnEditor: yarnEditorIndexHtml,
					codeWire: codeWireIndexHtml,
				},
				output: {
					manualChunks(id) {
						if (id.includes('node_modules/monaco-editor')) {
							return 'monaco';
						}
						if (id.includes('node_modules/@mui/') || id.includes('node_modules/@emotion/')) {
							return 'mui';
						}
						if (id.includes('node_modules/antd')) {
							return 'antd';
						}
						if (id.includes('node_modules/react-syntax-highlighter')) {
							return 'syntax';
						}
					},
				},
			},
		},
		plugins: [
			react(),
			yarnEditorStaticPlugin(),
			codeWireStaticPlugin(),
			codeInspectorPlugin({
				bundler: 'vite',
				editor: 'code',
			}),
			monacoEditorPlugin({
				languageWorkers: ['editorWorkerService', 'typescript'],
			}),
			monacoLocalePlugin({
				languages: ['en', 'zh-cn'],
				defaultLanguage: 'window.getLanguageSetting()',
				logUnmatched: false,
				mapLanguages: {
					'zh-cn': {
						'Go to References': '转到引用',
						Peek: '查看',
						'Peek References': '查看引用',
					},
				},
			}),
		],
		resolve: {
			alias: [
				{ find: 'path', replacement: path.join(rootDir, 'src/3rdParty/Path') },
				{ find: 'fs', replacement: emptyModule },
				{ find: 'perf_hooks', replacement: emptyModule },
				{ find: 'typescript', replacement: path.join(rootDir, 'src/shims/typescript.ts') },
			],
		},
		optimizeDeps: {
			exclude: ['monaco-editor', 'typescript'],
		},
		define: {
			'process.env.NODE_ENV': JSON.stringify(mode),
		},
		server: {
			host: true,
			port: Number(env.PORT) || 3000,
			fs: {
				allow: [
					rootDir,
					path.resolve(rootDir, '../..'),
				],
			},
		},
	};
});
