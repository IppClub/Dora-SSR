const path = require('node:path');
const ts = require('typescript');

// The native IDE's own locked TypeScript builds its linked shared dependency.
// A clean IDE install must not require a separate Studio install first.
const configPath = path.resolve(__dirname, '../../../Studio/packages/compiler/tsconfig.json');
const config = ts.readConfigFile(configPath, ts.sys.readFile);
if (config.error) throw new Error(ts.flattenDiagnosticMessageText(config.error.messageText, '\n'));
const parsed = ts.parseJsonConfigFileContent(config.config, ts.sys, path.dirname(configPath));
parsed.options.paths = { typescript: [require.resolve('typescript').replace(/typescript\.js$/, 'typescript.d.ts')] };
const program = ts.createProgram(parsed.fileNames, parsed.options);
const diagnostics = [...parsed.errors, ...ts.getPreEmitDiagnostics(program), ...program.emit().diagnostics];
if (diagnostics.length) {
  process.stderr.write(ts.formatDiagnosticsWithColorAndContext(diagnostics, {
    getCurrentDirectory: ts.sys.getCurrentDirectory,
    getCanonicalFileName: name => name,
    getNewLine: () => '\n',
  }));
  process.exitCode = 1;
}
