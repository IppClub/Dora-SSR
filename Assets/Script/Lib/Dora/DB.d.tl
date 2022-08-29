local record DB
	userdata
	type Column = integer | number | string | boolean
	type Row = {Column}
	type SQL = string | {string, {Row}}
	exist: function(self: DB, tableName: string): boolean
	transaction: function(self: DB, sqls: {SQL}): boolean
	query: function(
		self: DB,
		sql: string,
		args: Row,
		withColumn?: boolean --[[false]]
	): {Row}
	query: function(
		self: DB,
		sql: string,
		withColumn?: boolean --[[false]]
	): {Row}
	insert: function(self: DB, tableName: string, values: {Row})
	exec: function(self: DB, sql: string, args: Row): integer
	exec: function(self: DB, sql: string): integer
	insertAsync: function(self: DB, tableName: string, values: {Row}): boolean
	insertAsync: function(self: DB, tableSheets: {string}, excelFile: string, startRow: integer): boolean
	insertAsync: function(self: DB, tableSheets: {{string, string}}, excelFile: string, startRow: integer): boolean
	queryAsync: function(
		self: DB,
		sql: string,
		args: Row,
		withColumn?: boolean --[[false]]
	): {Row}
	queryAsync: function(
		self: DB,
		sql: string,
		withColumn?: boolean --[[false]]
	): {Row}
	execAsync: function(self: DB, sql: string, args: Row): integer
	execAsync: function(self: DB, sql: string): integer
end
local db: DB
return db
