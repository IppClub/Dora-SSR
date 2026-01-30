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
    },
  };
});
