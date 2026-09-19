import { readFile } from 'node:fs/promises';
import { build } from 'esbuild';
import ts from 'typescript';

// Build-time extraction only: declarations remain owned by the native registry.
// No validators, guards or handlers are replaced by this metadata adapter.
export async function buildAgentRegistry() {
  const path = new URL('../../Assets/Script/Lib/Agent/Tool/Registry.ts', import.meta.url);
  const text = await readFile(path, 'utf8');
  const source = ts.createSourceFile(path.pathname, text, ts.ScriptTarget.Latest, true);
  const kept = [];
  let found = false;
  for (const statement of source.statements) {
    if (ts.isImportDeclaration(statement)) {
      if (statement.importClause?.isTypeOnly) continue;
      if (statement.moduleSpecifier.text !== 'Agent/Tool/ToolBudgets') continue;
    }
    if (ts.isExportDeclaration(statement)) continue;
    kept.push(statement.getText(source));
    if (ts.isVariableStatement(statement) && statement.declarationList.declarations.some(d => d.name.getText(source) === 'AGENT_TOOL_DEFINITION_SOURCES')) {
      found = true; break;
    }
  }
  if (!found) throw new Error('Agent declaration boundary changed; extraction needs review');
  const selectors = new Set(['hasRole', 'hasWorkMode', 'getToolDefinition', 'isToolCapabilityEnabled',
    'isKnownToolName', 'getAllowedToolsForRole', 'getToolDefinitionsForRole',
    'getDecisionToolDefinitionsForRole', 'buildDecisionToolSchema', 'buildDecisionToolSchemaForTools']);
  for (const statement of source.statements) {
    if (ts.isFunctionDeclaration(statement) && selectors.has(statement.name?.text)) {
      kept.push(statement.getText(source)); selectors.delete(statement.name.text);
    }
    if (ts.isVariableStatement(statement) && statement.declarationList.declarations.some(d => d.name.getText(source) === 'SUB_AGENT_REQUIRED_FINISH_PARAMS')) kept.push(statement.getText(source));
  }
  if (selectors.size) throw new Error('Agent capability selectors changed; extraction needs review');
  const result = await build({ stdin: { contents: kept.join('\n') + `
const AGENT_TOOL_DEFINITIONS = AGENT_TOOL_DEFINITION_SOURCES.map(source => ({
  ...source,
  inputSchema: source.inputSchema ?? (context => createInputSchemaFromParameters(source.parameters, context)),
  outputSchema: DEFAULT_TOOL_OUTPUT_SCHEMA,
}));
export function contracts(context) {
  return AGENT_TOOL_DEFINITION_SOURCES.map(({parameters, inputSchema, ...source}) => ({
    ...source,
    description: resolveText(source.description, context),
    rules: (source.rules ?? []).map(rule => resolveText(rule, context)),
    inputSchema: inputSchema ? inputSchema(context) : createInputSchemaFromParameters(parameters, context),
    outputSchema: DEFAULT_TOOL_OUTPUT_SCHEMA,
  }));
}`, loader: 'ts', resolveDir: new URL('../../Assets/Script/Lib/', import.meta.url).pathname },
    bundle: true, write: false, platform: 'node', format: 'esm',
    plugins: [{ name: 'agent-budget', setup(builder) {
      builder.onResolve({ filter: /^Agent\/Tool\/ToolBudgets$/ }, () => ({ path: new URL('../../Assets/Script/Lib/Agent/Tool/ToolBudgets.ts', import.meta.url).pathname }));
    } }] });
  return result.outputFiles[0].text;
}

export async function loadAgentRegistry() {
  return import(`data:text/javascript;base64,${Buffer.from(await buildAgentRegistry()).toString('base64')}`);
}

export async function loadAgentContracts(context = { searchDoraDocLimitMax: 20 }) {
  return (await loadAgentRegistry()).contracts(context);
}
