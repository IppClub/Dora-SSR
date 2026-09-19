import {readFile} from 'node:fs/promises';
import ts from 'typescript';

// Generate declarations from their owners; never maintain a second DTO schema.
export async function buildAgentSessionTypes() {
  const base = new URL('../../Tools/dora-dora/src/', import.meta.url);
  const serviceText = await readFile(new URL('Service.ts', base), 'utf8');
  const reducerText = await readFile(new URL('AgentPatchBatch.ts', base), 'utf8');
  const service = ts.createSourceFile('Service.ts', serviceText, ts.ScriptTarget.Latest, true);
  const reducer = ts.createSourceFile('AgentPatchBatch.ts', reducerText, ts.ScriptTarget.Latest, true);
  const definitions = new Map(service.statements
    .filter(node => ts.isInterfaceDeclaration(node) || ts.isTypeAliasDeclaration(node))
    .map(node => [node.name.text, node]));
  const selected = new Map();
  const select = name => {
    if (selected.has(name)) return;
    const node = definitions.get(name);
    if (!node) throw new Error(`Missing upstream Agent type: ${name}`);
    selected.set(name, node);
    const visit = child => {
      if (ts.isTypeReferenceNode(child) && ts.isIdentifier(child.typeName) && definitions.has(child.typeName.text)) select(child.typeName.text);
      if (ts.isExpressionWithTypeArguments(child) && ts.isIdentifier(child.expression) && definitions.has(child.expression.text)) select(child.expression.text);
      ts.forEachChild(child, visit);
    };
    ts.forEachChild(node, visit);
  };
  const body = [];
  for (const node of reducer.statements) {
    if (!ts.isImportDeclaration(node)) { body.push(node.getText(reducer)); continue; }
    const bindings = node.importClause?.namedBindings;
    if (node.moduleSpecifier.text !== './Service' || !node.importClause?.isTypeOnly || !bindings || !ts.isNamedImports(bindings)) {
      throw new Error('Agent reducer imports changed; review declaration boundary');
    }
    for (const binding of bindings.elements) {
      if (binding.propertyName) throw new Error('Aliased Agent type requires review');
      select(binding.name.text);
    }
  }
  const file = '/studio-generated/session-patches.ts';
  select('AgentSessionDetailResponse');
  const source = [...selected.values()].map(node => node.getText(service)).join('\n') + '\n' + body.join('\n');
  const options = {target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.ESNext, strict: true, declaration: true, emitDeclarationOnly: true, noEmitOnError: true};
  const host = ts.createCompilerHost(options);
  const originalGetSource = host.getSourceFile.bind(host);
  host.getSourceFile = (name, ...args) => name === file ? ts.createSourceFile(file, source, options.target, true) : originalGetSource(name, ...args);
  let declaration;
  host.writeFile = (name, text) => { if (name.endsWith('/session-patches.d.ts')) declaration = text; };
  const program = ts.createProgram([file], options, host);
  const diagnostics = ts.getPreEmitDiagnostics(program);
  if (diagnostics.length) throw new Error(ts.formatDiagnosticsWithColorAndContext(diagnostics, {getCurrentDirectory: () => '', getCanonicalFileName: name => name, getNewLine: () => '\n'}));
  program.emit();
  if (!declaration) throw new Error('Agent session declaration emission failed');
  return declaration;
}
