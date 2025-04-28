-- 用于进行数据库操作的类。
local record DB
	userdata

	-- 数据库列可以存储的数据类型定义。
	-- 其中布尔类型仅支持false数值用于表示数据库中的空值（NULL）。
	type Column = integer | number | string | boolean

	-- 数据库行的类型定义。
	type Row = {Column}

	-- SQL查询的类型定义。
	-- 可以是SQL字符串或是SQL字符串加上参数列表。
	type SQL = string | {string, {Row}}

	-- 检查是否存在特定名称的附加数据库。
	-- @param dbName (string) 要检查的数据库名。
	-- @return (boolean) 数据库是否存在。
	existDB: function(self: DB, dbName: string): boolean

	-- 检查数据库中是否存在特定名称的数据表。
	-- @param tableName (string) 要检查的表名。
	-- @param schema (string) [可选] 数据库的名称。
	-- @return (boolean) 数据表是否存在。
	exist: function(self: DB, tableName: string, schema?: string): boolean

	-- 将一组SQL语句作为单个事务执行。
	-- @param sqls ({SQL}) 要执行的SQL语句列表。
	-- @return (boolean) 事务是否执行成功。
	transaction: function(self: DB, sqls: {SQL}): boolean

	-- 将一组SQL语句作为单个事务做异步的执行。
	-- @param sqls ({SQL}) 要执行的SQL语句列表。
	-- @return (boolean) 事务是否执行成功。
	transactionAsync: function(self: DB, sqls: {SQL}): boolean

	-- 执行SQL查询并将结果作为Lua表返回。
	-- @param sql (string) 要执行的SQL语句。
	-- @param args (Row) [可选] 要插入到SQL语句中的参数列表。
	-- @param withColumn (boolean) [可选] 是否在查询结果中包含列名（默认为false）。
	-- @return ({Row} | nil) 查询返回的Lua表，如果查询失败则返回nil。
	query: function(
		self: DB,
		sql: string,
		args: Row,
		withColumn?: boolean --[[false]]
	): {Row} | nil

	-- 执行SQL查询并将结果作为Lua表返回。
	-- @param sql (string) 要执行的SQL语句。
	-- @param withColumn (boolean) [可选] 是否在查询结果中包含列名（默认为false）。
	-- @return ({Row} | nil) 查询返回的Lua表，如果查询失败则返回nil。
	query: function(
		self: DB,
		sql: string,
		withColumn?: boolean --[[false]]
	): {Row} | nil

	-- 将数据行插入数据表中，插入动作会在一个事务中执行。
	-- @param tableName (string) 要插入的表名。
	-- @param values (Row) 要插入表中的值。
	-- @return (boolean) 插入是否成功。
	insert: function(self: DB, tableName: string, values: {Row}): boolean

	-- 执行SQL语句并返回受影响的行数。
	-- @param sql (string) 要执行的SQL语句。
	-- @return (integer) 语句执行影响的行数，如果语句执行失败则返回-1。
	exec: function(self: DB, sql: string): integer

	-- 执行SQL语句并返回受影响的行数
	-- @param sql (string) 要执行的SQL语句。
	-- @param values (Row) 要插入到SQL语句中的参数。
	-- @return (integer) 语句执行影响的行数，如果语句执行失败则返回-1。
	exec: function(self: DB, sql: string, values: Row): integer

	-- 在一个事务中以不同的参数多次执行SQL语句并返回受影响的行数。
	-- @param sql (string) 要执行的SQL语句。
	-- @param values ({Row}) 要插入到SQL语句中的参数列表。
	-- @return (integer) 语句执行影响的行数，如果语句执行失败则返回-1。
	exec: function(self: DB, sql: string, values: {Row}): integer

	-- 在一个事务中异步将数据行插入数据表中。
	-- @param tableName (string) 要插入的表名。
	-- @param values ({Row}) 要插入数据表的值列表。
	-- @return (boolean) 插入是否成功。
	insertAsync: function(self: DB, tableName: string, values: {Row}): boolean

	-- 在一个事务中异步从Excel文件插入数据到数据表中
	-- @param tableSheets ({string}) 要插入的数据表（和Excel表相同）的名称。
	-- @param excelFile (string) 包含插入数据的Excel文件的路径。
	-- @param startRow (integer) 开始插入数据的Excel行号，行号从1开始
	-- @return (boolean) 插入是否成功。
	insertAsync: function(self: DB, tableSheets: {string}, excelFile: string, startRow: integer): boolean

	-- 在一个事务中异步从Excel文件插入数据到数据表中。
	-- @param tableSheets ({{string, string}}) 要插入的数据表和对应Excel工作表名称的列表。
	-- @param excelFile (string) 包含插入数据的Excel文件的路径。
	-- @param startRow (integer) 开始插入数据的Excel行号，行号从1开始。
	-- @return (boolean) 插入是否成功。
	insertAsync: function(self: DB, tableSheets: {{string, string}}, excelFile: string, startRow: integer): boolean

	-- 异步执行SQL查询并将结果作为Lua表返回。
	-- @param sql (string) 要执行的SQL语句。
	-- @param args (Row) [可选] 要插入到SQL语句中的参数。
	-- @param withColumn (boolean) [可选] 是否在查询结果中包含列名（默认为false）。
	-- @return ({Row} | nil) 查询返回的Lua表，如果查询失败则返回nil。
	queryAsync: function(
		self: DB,
		sql: string,
		args: Row,
		withColumn?: boolean --[[false]]
	): {Row} | nil

	-- 异步执行SQL查询并将结果作为Lua表返回。
	-- @param sql (string) 要执行的SQL语句。
	-- @param withColumn (boolean) [可选] 是否在查询结果中包含列名（默认为false）。
	-- @return ({Row} | nil) 查询返回的Lua表，如果查询失败则返回nil。
	queryAsync: function(
		self: DB,
		sql: string,
		withColumn?: boolean --[[false]]
	): {Row} | nil

	-- 以不同的参数多次异步执行同一条SQL语句并返回受影响的行数。
	-- @param sql (string) 要执行的SQL语句。
	-- @param values ({Row}) 要插入到SQL语句中的参数列表。
	-- @return (integer) 语句执行影响的行数，如果语句执行失败则返回-1。
	execAsync: function(self: DB, sql: string, values: {Row}): integer

	-- 异步执行SQL语句并返回受影响的行数。
	-- @param sql (string) 要执行的SQL语句。
	-- @return (integer) 语句执行影响的行数，如果语句执行失败则返回-1。
	execAsync: function(self: DB, sql: string): integer
end

local db: DB
return db
