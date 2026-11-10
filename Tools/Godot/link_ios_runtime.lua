-- Link a verified archive into an embedded, symbol-isolated framework.
function main(...)
    local C = import("common", {rootdir = os.scriptdir()})
    local M = import("package_manifest", {rootdir = os.scriptdir()})
    local args = C.args({...}, {device = "value", ["build-dir"] = "value"})
    local device = C.choice(args.device or "simulator", {"simulator", "device"})
    local build = C.real(args["build-dir"] or path.join(C.root(), "build/godot-ios", device))
    local compiled = C.load(path.join(build, "compilation.json"))
    assert(compiled.passed and compiled.device == device, "Archive platform does not match requested framework")
    assert(compiled.source_archive_sha256 == M.source_sha256(), "Archive is from a different Godot source version")
    assert(C.digest(compiled.archive) == compiled.archive_sha256, "Archive changed after compilation")
    local source = path.join(C.root(), "Source/3rdParty/Godot")
    local package = path.join(build, "package")
    local framework = path.join(package, "DoraGodot.framework")
    os.mkdir(framework); os.tryrm(path.join(package, "manifest.json"))
    local clang = os.iorunv("xcrun", {"--find", "clang++"}):trim()
    local toolchain = path.directory(path.directory(path.directory(clang)))
    local sdk, binary = compiled.sdk, path.join(framework, "DoraGodot")
    local frameworks = {"Foundation", "UIKit", "CoreGraphics", "CoreText", "CoreVideo", "CoreMedia", "CoreMotion", "CoreHaptics",
        "GameController", "AudioToolbox", "AVFoundation", "AVFAudio", "Metal", "MetalKit", "QuartzCore", "Security",
        "SystemConfiguration", "UniformTypeIdentifiers", "Accessibility", "Photos", "PhotosUI", "VideoToolbox", "WebKit"}
    if device == "device" then table.insert(frameworks, 15, "MetalFX") end
    local command = {clang, "-target", "arm64-apple-ios14.0" .. (device == "simulator" and "-simulator" or ""), "-isysroot", sdk,
        "-dynamiclib", "-Wl,-all_load", compiled.archive, "-Wl,-dead_strip", "-Wl,-exported_symbols_list," .. path.join(source, "dora_bridge.exports"),
        "-install_name", "@rpath/DoraGodot.framework/DoraGodot", "-L" .. path.join(sdk, "usr/lib/swift"),
        "-L" .. path.join(toolchain, "usr/lib/swift", device == "simulator" and "iphonesimulator" or "iphoneos"),
        "-lc++", "-lresolv", "-lz", "-liconv", "-o", binary}
    for _, name in ipairs(frameworks) do
        assert(os.isdir(path.join(sdk, "System/Library/Frameworks", name .. ".framework")), "Missing framework: " .. name)
        table.join2(command, {name == "MetalFX" and "-weak_framework" or "-framework", name})
    end
    local log = assert(io.open(path.join(build, "link.log"), "w"))
    try {function () os.execv(command[1], table.slice(command, 2), {stdout = log, stderr = log}) end,
        finally {function (ok, errors) log:close(); if not ok then raise(errors) end end}}
    local plist = [[<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>org.ippclub.dorassr.godot.runtime</string>
<key>CFBundleExecutable</key><string>DoraGodot</string><key>CFBundleName</key><string>DoraGodot</string>
<key>CFBundlePackageType</key><string>FMWK</string><key>CFBundleShortVersionString</key><string>4.7.2</string>
<key>CFBundleVersion</key><string>1</string><key>MinimumOSVersion</key><string>14.0</string>
<key>CFBundleSupportedPlatforms</key><array><string>]] .. (device == "simulator" and "iPhoneSimulator" or "iPhoneOS") .. [[</string></array>
</dict></plist>
]]
    C.write(path.join(framework, "Info.plist"), plist)
    for origin, destination in pairs({["LICENSE.txt"] = "GODOT-LICENSE.txt", ["COPYRIGHT.txt"] = "GODOT-THIRD-PARTY-NOTICES.txt"}) do C.copy(path.join(source, origin), path.join(framework, destination)) end
    C.run("codesign", {"--force", "--timestamp=none", "--sign", "-", framework})
    C.run("codesign", {"--verify", "--strict", framework})
    local expected, exports = {}, {}
    for line in C.read(path.join(source, "dora_bridge.exports")):gmatch("[^\r\n]+") do expected[line:trim()] = true end
    for line in os.iorunv("nm", {"-gU", binary}):gmatch("[^\r\n]+") do exports[line:match("(%S+)%s*$")] = true end
    assert(C.equal(exports, expected), "Unexpected exported framework symbols")
    local metadata = os.iorunv("xcrun", {"vtool", "-show-build", binary})
    assert(metadata:match("platform%s+" .. (device == "simulator" and "IOSSIMULATOR" or "IOS") .. "%s*\n"), "Unexpected Mach-O platform")
    local record = {passed = true, scope = "iOS framework compilation/link/signature/export inspection only; no app boot or GPU acceptance",
        device = device, framework = framework, library_sha256 = C.digest(binary), source_archive_sha256 = compiled.source_archive_sha256,
        archive_sha256 = compiled.archive_sha256, command = command, exports = C.keys(exports), mach_o_build = metadata,
        ad_hoc_development_signature = true, licenses = {"DoraGodot.framework/GODOT-LICENSE.txt", "DoraGodot.framework/GODOT-THIRD-PARTY-NOTICES.txt"},
        builder = compiled.builder, build_target = compiled.build_target or "template_debug", graphics_backend = "metal", architectures = {"arm64"},
        migration_inputs_sha256 = compiled.migration_inputs_sha256 or {}, library = "DoraGodot.framework/DoraGodot"}
    C.save(path.join(package, "manifest.json"), M.seal(package, record))
    import("verify_package", {rootdir = os.scriptdir()}).verify(package)
    import("core.base.json"); print(C.serialize(record))
end
