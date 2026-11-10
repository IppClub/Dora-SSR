function main(...)
    local C = import("common", {rootdir = os.scriptdir()})
    local Z = import("zip", {rootdir = os.scriptdir()})
    local args = C.args({...}, {output = "value", builder = "value", sdk = "value", ["java-home"] = "value", ["vendor-build-dir"] = "value"})
    local builder = C.choice(args.builder or "vendor", {"maven", "vendor"})
    local output = C.real(args.output or path.join(C.root(), "build/godot-android/java"))
    local source_build, archive_file, expected
    if builder == "vendor" then
        local sdk = assert(args.sdk or os.getenv("ANDROID_HOME") or os.getenv("ANDROID_SDK_ROOT"), "--sdk is required for --builder vendor")
        local builddir = C.real(args["vendor-build-dir"] or path.join(C.root(), "build/godot-android/vendor-java"))
        local command = {"--sdk", sdk, "--output", builddir}
        if args["java-home"] then table.join2(command, {"--java-home", args["java-home"]}) end
        C.tool("build_android_java", command)
        source_build = C.load(path.join(builddir, "manifest.json"))
        assert(source_build.passed and source_build.vendor_sources_unchanged)
        archive_file = source_build.source_aar; expected = source_build.source_aar_sha256
    else
        archive_file = path.join(C.root(), "build/godot-android/deps/godot-4.7.2.stable.aar")
        expected = "8791eecfe7c96a4de2d188a0bccfe9b83b92589a5a6825847473416a990e8629"
        if not os.isfile(archive_file) then C.download("https://repo.maven.apache.org/maven2/org/godotengine/godot/4.7.2.stable/godot-4.7.2.stable.aar", archive_file) end
    end
    assert(C.digest(archive_file) == expected, "AAR hash mismatch")
    os.mkdir(output)
    local destination, temporary = path.join(output, "godot-java-4.7.2.stable.aar"), os.tmpfile() .. "-aar"
    local removed = {}
    try {function ()
        local inventory = Z.extract(archive_file, temporary)
        for _, entry in ipairs(inventory) do if entry.name:startswith("jni/") then removed[#removed + 1] = entry.name end end
        os.tryrm(path.join(temporary, "jni"))
        local file = path.join(temporary, "AndroidManifest.xml")
        local text, count = C.read(file):gsub('android:name="androidx%.core%.content%.FileProvider"', 'android:name="org.ippclub.dorassr.GodotFileProvider"')
        assert(count == 1, "Unexpected upstream provider declaration"); C.write(file, text)
        os.tryrm(destination); Z.archive(temporary, destination)
        for _, entry in ipairs(Z.entries(destination)) do assert(not entry.name:startswith("jni/")) end
    end, finally {function (ok, errors) os.tryrm(temporary); if not ok then raise(errors) end end}}
    C.save(path.join(output, "manifest.json"), {builder = builder, source_build = source_build, source_version = "4.7.2.stable",
        source_sha256 = expected, java_aar_sha256 = C.digest(destination), provider_class = "org.ippclub.dorassr.GodotFileProvider",
        removed_native_entries = removed, scope = "upstream Java/resources only; native runtime supplied separately by the compiled Dora bridge"})
    print(destination)
end
