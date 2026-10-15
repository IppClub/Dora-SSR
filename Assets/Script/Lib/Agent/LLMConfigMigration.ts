// @preview-file off clear
import { DB, json, SQL, Log } from 'Dora';
import { AGENT_DEFAULTS } from 'Agent/Config';

// Data version, independent of agent.db's schema version. No tables are changed.
export const LLM_CONFIG_VERSION = 1;
const VERSION_KEY = 'agentLLMConfigVersion';

export function upgradeLLMConfig(): void {
	// A new installation may read Agent configuration before setup creates it.
	if (!DB.exist('LLMConfig')) return;
	const versions = DB.query(`SELECT value_num FROM Config WHERE name = '${VERSION_KEY}'`);
	if (!versions) error('Failed to read LLM configuration version');
	if ((tonumber(versions[0]?.[0]) ?? 0) >= LLM_CONFIG_VERSION) return;
	const rows = DB.query('SELECT id, custom_options FROM LLMConfig');
	if (!rows) error('Failed to read LLM configurations for upgrade');
	const updates: SQL[] = [];
	let invalidOptions = 0;
	for (const row of rows) {
		const text = tostring(row[1] ?? '');
		if (text === '') continue;
		const [decoded] = json.decode(text);
		// Preserve invalid legacy text so users can still list/edit/delete it.
		// One unusable configuration must not block upgrading every other row.
		if (type(decoded) !== 'table' || decoded === json.null || string.match(text, '^%s*{')[0] === undefined) {
			invalidOptions++;
			continue;
		}
		const options = decoded as Record<string, unknown>;
		const auxiliary = type(options.auxiliaryOptions) === 'table' && options.auxiliaryOptions !== json.null
			? options.auxiliaryOptions as Record<string, unknown> : undefined;
		// Do not re-encode unrelated custom options.
		if (options.max_tokens === undefined && options.max_completion_tokens === undefined
			&& auxiliary?.max_tokens === undefined && auxiliary?.max_completion_tokens === undefined) continue;
		const completion = options.max_completion_tokens;
		if (completion !== undefined && completion !== json.null) options.max_completion_tokens = AGENT_DEFAULTS.llmMaxTokens;
		if (options.max_tokens !== undefined) {
			// Preserve explicit field selection for APIs using max_completion_tokens.
			if (options.max_tokens !== json.null) options.max_tokens = AGENT_DEFAULTS.llmMaxTokens;
			else if (completion === undefined || completion === json.null) delete options.max_tokens;
		}
		if (auxiliary) {
			delete auxiliary.max_tokens;
			delete auxiliary.max_completion_tokens;
		}
		const [encoded, encodeError] = json.encode(options);
		if (!encoded) error(encodeError ?? 'Failed to encode upgraded LLM custom options');
		updates.push(['UPDATE LLMConfig SET custom_options = ? WHERE id = ?', [[encoded, row[0]]]]);
	}
	// Configuration changes and the version marker commit or roll back together.
	updates.push(`UPDATE LLMConfig SET max_tokens = ${AGENT_DEFAULTS.llmMaxTokens}`);
	updates.push(`INSERT OR REPLACE INTO Config(name, value_num, value_str, value_bool) VALUES('${VERSION_KEY}', ${LLM_CONFIG_VERSION}, NULL, NULL)`);
	if (!DB.transaction(updates)) error('Failed to upgrade LLM configurations');
	if (invalidOptions > 0) Log('Warn', `[LLMConfig] upgraded output budgets; preserved ${invalidOptions} invalid custom options for correction`);
}
