import { App, Content, Path, thread } from "Dora";
import { discardPackage, exportPackage, inspectPackage, installPackage } from "Dev/Mobile/Package";

// Run with the native engine; fixtures are produced by Tools/tests/mobile_package_fixtures.py.
thread(() => {
	const marker = Path(Content.appPath, "mobile-package-test.result");
	const fixtures = Path(Content.appPath, "mobile-package-fixtures");
	const root = Path(Content.writablePath, `.package-test-${App.rand}`);
	const installed: string[] = [];
	const temporary: string[] = [root];
	Content.save(marker, "running");
	try {
		assert(Content.mkdir(root));
		Content.mkdir(Path(root, ".agent"));
		Content.mkdir(Path(root, "Image"));
		Content.save(Path(root, "init.lua"), "return 'package-played'");
		Content.save(Path(root, "init.ts"), "// editable source");
		Content.save(Path(root, "Image", "data.txt"), "asset-data");
		Content.save(Path(root, ".env"), "private-test-value");
		Content.save(Path(root, ".agent", "history.json"), "private-test-history");
		const title = `分享回归-${App.rand}`;
		const exported = exportPackage({ title, workDir: root });
		temporary.push(Path.getPath(exported.path));
		Content.copy(exported.path, Path(fixtures, "roundtrip.zip"));
		Content.save(Path(root, "init.lua"), "return 'edited-later'");
		const preview = inspectPackage(exported.path);
		temporary.push(preview.stage);
		assert(preview.title === title, "Unicode title round trip");
		assert(Content.load(Path(preview.root, "init.lua")) === "return 'package-played'", "immutable export snapshot");
		assert(Content.exist(Path(preview.root, "init.ts")), "editable source preserved");
		assert(Content.load(Path(preview.root, "Image", "data.txt")) === "asset-data", "assets preserved");
		assert(!Content.exist(Path(preview.root, ".env")) && !Content.exist(Path(preview.root, ".agent")), "private state excluded");
		const first = installPackage(preview);
		installed.push(first.workDir!);
		assert(dofile(Path(first.workDir!, "init.lua")) === "package-played", "installed entry runs");
		const second = installPackage(inspectPackage(exported.path));
		installed.push(second.workDir!);
		assert(first.workDir !== second.workDir, "same-name import creates a copy");
		assert(Content.load(Path(first.workDir!, "init.lua")) === "return 'package-played'", "original is unchanged");
		const cancelled = inspectPackage(exported.path);
		discardPackage(cancelled);
		assert(!Content.exist(cancelled.stage), "cancel cleans staging");
		for (const name of ["traversal", "absolute", "backslash", "drive", "oversize", "too-many", "corrupt", "missing-init", "bad-metadata", "future-version"]) {
			let rejected = false;
			try { const unexpected = inspectPackage(Path(fixtures, name + ".zip")); discardPackage(unexpected); }
			catch (_) { rejected = true; }
			assert(rejected, `reject ${name}`);
		}
		const legacy = inspectPackage(Path(fixtures, "legacy.zip"));
		assert(Content.exist(Path(legacy.root, "init.lua")), "legacy wrapper ZIP");
		discardPackage(legacy);
		const mixed = Path(root, "mixed");
		assert(Content.unzipAsync(Path(fixtures, "mixed.zip"), mixed), "root files coexist with a same-named folder");
		assert(Content.exist(Path(mixed, "init.lua")) && Content.exist(Path(mixed, "mixed", "asset.txt")), "root stripping stays inside destination");
		Content.save(marker, "passed: snapshot, source/assets, private-state exclusion, unicode, collision, cancel, 10 invalid packages, legacy ZIP, mixed-root ZIP");
	} catch (e) {
		Content.save(marker, "failed: " + tostring(e));
	} finally {
		for (const path of installed) Content.remove(path);
		for (const path of temporary) Content.remove(path);
	}
});
