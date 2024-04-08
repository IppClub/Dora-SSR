// @preview-file off
import { SetCond, WindowFlag } from "ImGui";
import * as ImGui from "ImGui";
import { App, DB, SQL, Vec2, thread, threadLoop } from "dora";

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

const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.AlwaysAutoResize,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
threadLoop(() => {
	const size = App.visualSize;
	ImGui.SetNextWindowBgAlpha(0.35);
	ImGui.SetNextWindowPos(Vec2(size.width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(240, 0), SetCond.FirstUseEver);
	ImGui.Begin("SQLite", windowFlags, () => {
		ImGui.Text("SQLite (Typescript)");
		ImGui.Separator();
		ImGui.TextWrapped("Doing database operations in synchronous and asynchronous ways");
	});
	return false;
});
