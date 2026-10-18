// @preview-file off clear
import { DB, SQL } from 'Dora';

// Independent of the output-budget migration: renaming must not reset options.
const VERSION_KEY = 'agentLLMConfigNamesVersion';
const VERSION = 1;

export function normalizeLLMConfigName(value: unknown): string | undefined {
	if (typeof value !== 'string') return undefined;
	const name = value.trim();
	return name === '' ? undefined : name;
}

export function upgradeLLMConfigNames(): void {
	const versions = DB.query('SELECT value_num FROM Config WHERE name = ?', [VERSION_KEY]);
	if (!versions) error('Failed to read LLM configuration name version');
	if ((tonumber(versions[0]?.[0]) ?? 0) >= VERSION) return;
	const rows = DB.query('SELECT id, name FROM LLMConfig ORDER BY id');
	if (!rows) error('Failed to read LLM configuration names');
	const reserved: Record<string, boolean> = {};
	const occupied: Record<string, boolean> = {};
	for (const row of rows) {
		occupied[tostring(row[1])] = true;
		const name = normalizeLLMConfigName(row[1]);
		if (name !== undefined) reserved[name] = true;
	}
	const assigned: Record<string, boolean> = {};
	const suffixes: Record<string, number> = {};
	const changes: { id: number; name: string }[] = [];
	for (const row of rows) {
		const original = row[1] as string;
		const normalized = normalizeLLMConfigName(original);
		const base = normalized ?? 'Model';
		let name = base;
		if (assigned[name] || (normalized === undefined && reserved[name])) {
			let suffix = suffixes[base] ?? 2;
			do { name = `${base} (${suffix++})`; } while (reserved[name] || assigned[name]);
			suffixes[base] = suffix;
		}
		assigned[name] = true;
		occupied[name] = true;
		if (name !== original) changes.push({ id: row[0] as number, name });
	}

	const updates: SQL[] = [];
	// Two phases also work if an existing unique index protects untrimmed names.
	for (const change of changes) {
		let temporary = `__dora_llm_name_${change.id}__`;
		while (occupied[temporary]) temporary += '_';
		occupied[temporary] = true;
		updates.push(['UPDATE LLMConfig SET name = ? WHERE id = ?', [[temporary, change.id]]]);
	}
	for (const change of changes) {
		updates.push(['UPDATE LLMConfig SET name = ? WHERE id = ?', [[change.name, change.id]]]);
	}
	updates.push('CREATE UNIQUE INDEX IF NOT EXISTS idx_llm_config_name ON LLMConfig(name)');
	updates.push(['INSERT OR REPLACE INTO Config(name, value_num, value_str, value_bool) VALUES(?, ?, NULL, NULL)', [[VERSION_KEY, VERSION]]]);
	if (!DB.transaction(updates)) error('Failed to upgrade LLM configuration names');
}

export function checkLLMConfigName(name: string, excludeId = 0): { success: true } | { success: false; code: string; message: string } {
	const rows = DB.query('SELECT id FROM LLMConfig WHERE name = ? AND id <> ? LIMIT 1', [name, excludeId]);
	if (!rows) return { success: false, code: 'LLM_CONFIG_NAME_CHECK_FAILED', message: 'Failed to check LLM configuration name' };
	if (rows.length > 0) return { success: false, code: 'LLM_CONFIG_NAME_EXISTS', message: 'LLM configuration name already exists' };
	return { success: true };
}
