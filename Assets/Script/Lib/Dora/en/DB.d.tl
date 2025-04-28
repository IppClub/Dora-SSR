-- A record that represents a database.
local record DB
	userdata

	-- Type definition for a database column.
	-- The boolean type is only used for representing the database NULL value with the boolean false value.
	type Column = integer | number | string | boolean

	-- Type definition for a database row.
	type Row = {Column}

	-- Type definition for an SQL query.
	-- Can be SQL string or a pair of SQL string and an array of parameters.
	type SQL = string | {string, {Row}}

	-- Checks whether an attached database exists.
	-- @param dbName (string) The name of the attached database to check.
	-- @return (boolean) Whether the attached database exists or not.
	existDB: function(self: DB, dbName: string): boolean

	-- Checks whether a table exists in the database.
	-- @param tableName (string) The name of the table to check.
	-- @param schema (string) [optional] The name of the database to check in.
	-- @return (boolean) Whether the table exists or not.
	exist: function(self: DB, tableName: string, schema?: string): boolean

	-- Executes a list of SQL statements as a single transaction.
	-- @param sqls ({SQL}) A list of SQL statements to execute.
	-- @return (boolean) Whether the transaction was successful or not.
	transaction: function(self: DB, sqls: {SQL}): boolean

	-- Executes a list of SQL statements as a single transaction asynchronously.
	-- @param sqls ({SQL}) A list of SQL statements to execute.
	-- @return (boolean) Whether the transaction was successful or not.
	transactionAsync: function(self: DB, sqls: {SQL}): boolean

	-- Executes an SQL query and returns the results as a list of rows.
	-- @param sql (string) The SQL statement to execute
	-- @param args (Row) [optional] A list of values to substitute into the SQL statement.
	-- @param withColumn (boolean) [optional] Whether to include column names in the result (default false).
	-- @return ({Row}) A list of rows returned by the query.
	query: function(
		self: DB,
		sql: string,
		args: Row,
		withColumn?: boolean --[[false]]
	): {Row}

	-- Executes an SQL query and returns the results as a list of rows.
	-- @param sql (string) The SQL statement to execute
	-- @param withColumn (boolean) [optional] Whether to include column names in the result (default false).
	-- @return ({Row} | nil) A list of rows returned by the query, or nil if the query failed.
	query: function(
		self: DB,
		sql: string,
		withColumn?: boolean --[[false]]
	): {Row} | nil

	-- Inserts a row of data into a table within a transaction.
	-- @param tableName (string) The name of the table to insert into.
	-- @param values (Row) The values to insert into the table.
	-- @return (boolean) Whether the insertion was successful or not.
	insert: function(self: DB, tableName: string, values: {Row}): boolean

	-- Executes an SQL statement and returns the number of rows affected.
	-- @param sql (string) The SQL statement to execute.
	-- @return (integer) The number of rows affected by the statement, returns -1 if the statement failed.
	exec: function(self: DB, sql: string): integer

	-- Executes an SQL statement and returns the number of rows affected.
	-- @param sql (string) The SQL statement to execute.
	-- @param values (Row) A list of values to substitute into the SQL statement.
	-- @return (integer) The number of rows affected by the statement, returns -1 if the statement failed.
	exec: function(self: DB, sql: string, values: Row): integer

	-- Executes an SQL statement with list of values and returns the number of rows affected within a transaction.
	-- @param sql (string) The SQL statement to execute.
	-- @param values ({Row}) A list of lists of values to substitute into the SQL statement.
	-- @return (integer) the number of rows affected by the statement, returns -1 if the statement failed.
	exec: function(self: DB, sql: string, values: {Row}): integer

	-- Inserts a row of data into a table within a transaction asynchronously.
	-- @param tableName (string) The name of the table to insert into.
	-- @param values ({Row}) The values to insert into the table.
	-- @return (boolean) Whether the insert was successful or not.
	insertAsync: function(self: DB, tableName: string, values: {Row}): boolean

	-- Inserts data from an Excel file into a table within a transaction asynchronously.
	-- @param tableSheets ({string}) the names of the tables to insert into.
	-- @param excelFile (string) The path to the Excel file containing the data.
	-- @param startRow (integer) The row number to start inserting data from. The row number start with 1.
	-- @return (boolean) Whether the insert was successful or not.
	insertAsync: function(self: DB, tableSheets: {string}, excelFile: string, startRow: integer): boolean

	-- Inserts data from an Excel file into a table within a transaction asynchronously.
	-- @param tableSheets ({{string, string}}) A list of table names and corresponding sheet names to insert into.
	-- @param excelFile (string) The path to the Excel file containing the data.
	-- @param startRow (integer) The row number to start inserting data from. The row number start with 1.
	-- @return (boolean) Whether the insert was successful or not.
	insertAsync: function(self: DB, tableSheets: {{string, string}}, excelFile: string, startRow: integer): boolean

	-- Executes an SQL query asynchronously and returns the results as a list of rows.
	-- @param sql (string) The SQL statement to execute.
	-- @param args (Row) [optional] A list of values to substitute into the SQL statement.
	-- @param withColumn (boolean) [optional] Whether to include column names in the result (default false).
	-- @return ({Row} | nil) A list of rows returned by the query, or nil if the query failed.
	queryAsync: function(
		self: DB,
		sql: string,
		args: Row,
		withColumn?: boolean --[[false]]
	): {Row} | nil

	-- Executes an SQL query asynchronously and returns the results as a list of rows.
	-- @param sql (string) The SQL statement to execute.
	-- @param withColumn (boolean) [optional] Whether to include column names in the result (default false).
	-- @return ({Row} | nil) A list of rows returned by the query, or nil if the query failed.
	queryAsync: function(
		self: DB,
		sql: string,
		withColumn?: boolean --[[false]]
	): {Row} | nil

	-- Executes an SQL statement with a list of values within a transaction asynchronously and returns the number of rows affected.
	-- @param sql (string) The SQL statement to execute.
	-- @param values ({Row}) A list of values to substitute into the SQL statement.
	-- @return (integer) The number of rows affected by the statement, returns -1 if the statement failed.
	execAsync: function(self: DB, sql: string, values: {Row}): integer

	-- Executes an SQL statement asynchronously and returns the number of rows affected.
	-- @param sql (string) The SQL statement to execute.
	-- @return (integer) the number of rows affected by the statement, returns -1 if the statement failed.
	execAsync: function(self: DB, sql: string): integer
end

local db: DB
return db
