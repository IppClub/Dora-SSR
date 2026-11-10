function main(...)
    local C = import("common", {rootdir = os.scriptdir()})
    local args = C.args({...}, {sdk = "value", output = "value", ["java-home"] = "value"})
    local sdk, out = C.real(C.required(args, "sdk")), C.real(C.required(args, "output"))
    local source = path.join(C.root(), "Source/3rdParty/Godot")
    local main = path.join(source, "platform/android/java/lib/src/main")
    import("vendor_source", {rootdir = os.scriptdir()}).verify_android(source)
    local config, version = path.join(source, "platform/android/java/app/config.gradle"), path.join(source, "version.py")
    local inputs = {config, version, path.join(source, "UPSTREAM.json")}
    for _, name in ipairs({"gradlew", "gradlew.bat", "gradle/wrapper/gradle-wrapper.jar", "gradle/wrapper/gradle-wrapper.properties"}) do table.insert(inputs, path.join(source, "platform/android/java", name)) end
    local function snapshot() return C.snapshot(source, table.join(C.files(main), inputs)) end
    local function setting(name) return assert(C.read(config):match(name .. "%s*:%s*'([^']+)'"), name) end
    local fields = {}; for name, value in ("\n" .. C.read(version)):gmatch("\n([%w_]+)%s*=%s*([^\n]+)") do fields[name] = value:trim():gsub('^"', ''):gsub('"$', '') end
    local library_version = table.concat({fields.major, fields.minor, fields.patch, fields.status}, ".")
    assert(library_version == "4.7.2.stable", "Unsupported vendor Java version")
    local before, project = snapshot(), path.join(out, "project")
    os.mkdir(project)
    for _, name in ipairs({"settings.gradle", "build.gradle"}) do C.copy(path.join(C.root(), "Projects/xmake/godot/android-java", name), path.join(project, name)) end
    C.write(path.join(project, "gradle.properties"), "android.useAndroidX=true\nandroid.enableJetifier=true\nandroid.enableResourceOptimizations=false\norg.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8\nkotlin.compiler.execution.strategy=in-process\n")
    C.write(path.join(project, "local.properties"), "sdk.dir=" .. sdk:gsub("\\", "\\\\"):gsub(":", "\\:") .. "\n")
    local java = args["java-home"] or os.getenv("JAVA_HOME")
    if not java and os.isdir("/Applications/Android Studio.app/Contents/jbr/Contents/Home") then java = "/Applications/Android Studio.app/Contents/jbr/Contents/Home" end
    local envs = {ANDROID_HOME = sdk, JAVA_HOME = java and C.real(java)}
    local command = {path.join(source, "platform/android/java", os.host() == "windows" and "gradlew.bat" or "gradlew"), "-p", project,
        "--no-daemon", "--max-workers=2", "-Pdora.godot.source=" .. source, "-Pdora.godot.version=" .. library_version,
        "-Pdora.godot.agp=" .. setting("androidGradlePlugin"), "-Pdora.godot.kotlin=" .. setting("kotlinVersion"), "assembleTemplateRelease"}
    C.save(path.join(out, "command.json"), {command = command, java_home = envs.JAVA_HOME, source_files = before})
    local log = assert(io.open(path.join(out, "build.log"), "w"))
    local success, errors = true, nil
    try {function () os.execv(command[1], table.slice(command, 2), {curdir = project, envs = envs, stdout = log, stderr = log}) end,
        catch {function (message) success = false; errors = message end}, finally {function () log:close() end}}
    assert(C.equal(before, snapshot()), "Gradle changed vendor Java/resources")
    C.save(path.join(out, "result.json"), {exit_code = success and 0 or 1, vendor_sources_unchanged = true})
    if not success then raise(errors) end
    local archives = os.files(path.join(project, "build/outputs/aar/*-template-release.aar"))
    assert(#archives == 1, "Expected one vendor Java AAR")
    local archive_file = path.join(out, "godot-lib.template_release.aar"); C.copy(archives[1], archive_file)
    local entries = import("zip", {rootdir = os.scriptdir()}).entries(archive_file)
    local names = {}; for _, entry in ipairs(entries) do assert(not entry.name:startswith("jni/"), "Java-only AAR includes native libraries"); names[entry.name] = true end
    assert(names["classes.jar"] and names["AndroidManifest.xml"], "Incomplete AAR")
    C.save(path.join(out, "manifest.json"), {passed = true, builder = "vendor-gradle", source_version = library_version,
        upstream_commit = "ed1daf0bf001b61586d9930840f2f1394092c079", source_files = before, vendor_sources_unchanged = true,
        source_config_sha256 = C.digest(config), source_version_sha256 = C.digest(version), source_aar = archive_file,
        source_aar_sha256 = C.digest(archive_file), agp = setting("androidGradlePlugin"), kotlin = setting("kotlinVersion"), native_entries = 0,
        scope = "Java/resources built from vendored source only; JNI loading and Android runtime acceptance remain separate"})
    print(archive_file)
end
