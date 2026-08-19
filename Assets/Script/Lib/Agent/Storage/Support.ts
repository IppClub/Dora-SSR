// @preview-file off clear
import { DB } from 'Dora';

export type AgentDatabaseValue = string | number | boolean;

export function toStr(value: unknown): string {
	if (value === false || value === undefined) return "";
	return tostring(value);
}

export function queryRows(sql: string, args?: AgentDatabaseValue[]) {
	return args ? DB.query(sql, args) : DB.query(sql);
}

export function queryOne(sql: string, args?: AgentDatabaseValue[]) {
	const rows = queryRows(sql, args);
	if (!rows || rows.length === 0) return undefined;
	return rows[0];
}

export function getLastInsertRowId(): number {
	const row = queryOne("SELECT last_insert_rowid()");
	return row ? ((row[0] as number | undefined) || 0) : 0;
}
