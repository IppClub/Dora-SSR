use dora_ssr::*;

fn get_str(arr: &Array, index: i32) -> Option<String> {
	arr.get(index)?.into_str()
}

fn get_i32(arr: &Array, index: i32) -> Option<i32> {
	arr.get(index)?.into_i32()
}

pub fn test() {
	let mut sqls = DBQuery::new();
	sqls.add("DROP TABLE IF EXISTS test");
	sqls.add("CREATE TABLE test (id INTEGER PRIMARY KEY, value TEXT)");
	let mut params = DBParams::new();
	let mut arr = Array::new();
	let data = ["hello", "world", "ok"];
	for i in 0..data.len() {
		arr.clear();
		arr.add(false).add(data[i]);
		params.add(&arr);
	}
	sqls.add_with_params("INSERT INTO test VALUES(?, ?)", params);

	let result = DB::transaction(sqls);
	p!("transaction result: {}", result);
	p!("table test exist: {}", DB::exist("test"));

	let mut result = DB::query("SELECT * FROM test", true);
	arr.clear();
	result.read(&arr);
	for i in 0..arr.get_count() as i32 {
		if let Some(value) = get_str(&arr, i) {
			p!("{}", value);
		}
	}
	arr.clear();
	let mut count = 0;
	while result.read(&arr) {
		if let Some(value) = get_i32(&arr, 0) {
			p!("{}", value);
		}
		if let Some(value) = get_str(&arr, 1) {
			p!("{}", value);
		}
		arr.clear();
		count += 1;
	}
	p!("result count: {}", count);


	p!("row deleted: {}", DB::exec("DELETE FROM test WHERE id > 2"));
	let mut params = DBParams::new();
	params.add(&Array::new().add("hello world!"));
	p!("row updated: {}", DB::exec_with_records("UPDATE test SET value = ? WHERE id = 1", params));

	p!("insert async");
	let mut params = DBParams::new();
	let data = ["B", "A", "D", "C", "F", "E"];
	for i in 0..data.len() {
		arr.clear();
		arr.add(false).add(data[i]);
		params.add(&arr);
	}
	DB::insert_async("test", params, Box::new(|result| {
		p!("insert async result: {}", result);
		p!("query async...");
	}));

	DB::query_with_params_async("SELECT value FROM test WHERE value NOT LIKE 'hello%' ORDER BY value ASC", &Array::new(), true, Box::new(move |mut result| {
		arr.clear();
		while result.read(&arr) {
			if let Some(value) = get_str(&arr, 0) {
				p!("{}", value);
			}
			arr.clear();
		}
	}));

	p!("OK");

	let windows_flags =
		ImGuiWindowFlag::NO_DECORATION |
		ImGuiWindowFlag::AlwaysAutoResize |
		ImGuiWindowFlag::NoSavedSettings |
		ImGuiWindowFlag::NoFocusOnAppearing |
		ImGuiWindowFlag::NO_NAV |
		ImGuiWindowFlag::NoMove;
	let mut imgui_node = Node::new();
	imgui_node.schedule(Box::new(move |_| {
		let size = App::get_visual_size();
		ImGui::set_next_window_bg_alpha(0.35);
		ImGui::set_next_window_pos_opts(&Vec2::new(size.width - 10.0, 10.0), ImGuiCond::Always, &Vec2::new(1.0, 0.0));
		ImGui::set_next_window_size_opts(&Vec2::new(240.0, 0.0), ImGuiCond::FirstUseEver);
		ImGui::begin_opts("SQLite", windows_flags, || {
			ImGui::text("SQLite (Rust)");
			ImGui::separator();
			ImGui::text_wrapped("Doing database operations in synchronous and asynchronous ways.");
		});
		false
	}));
}