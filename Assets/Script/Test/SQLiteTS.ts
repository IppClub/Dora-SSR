import { DB, SQL, thread } from "dora";

const sqls: SQL[] = [
	"DROP TABLE IF EXISTS test",
	"CREATE TABLE test (id INTEGER PRIMARY KEY, value TEXT)",
	[
		"INSERT INTO test VALUES(?, ?)",
		[
			[false, "hello"],
			[false, "world"],
			[false, "ok"]
		]
	]
];

const result = DB.transaction(sqls);
print(result ? "Success" : "Failure");
print(DB.exist("test"));

p(DB.query("SELECT * FROM test", true));

print("row changed:", DB.exec("DELETE FROM test WHERE id > 1"));
print("row changed:", DB.exec("UPDATE test SET value = ? WHERE id = 1", ["hello world!"]));

thread(() => {
	print("insert async");
	const data = [];
	for (let [k] of pairs(_G)) {
		data.push([false, k]);
	}
	p(DB.insertAsync("test", data));
	print("query async...");
	const items = DB.queryAsync("SELECT value FROM test WHERE value NOT LIKE 'hello%' ORDER BY value ASC");
	const rows = [];
	for (let i = 0; i < items.length; i++) {
		const item = items[i];
		rows.push(item[0]);
	}
	p(rows);
	return false;
});

print("OK")
