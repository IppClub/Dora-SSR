function main(options)
    assert(os.host() == "macosx", "iOS packaging requires Xcode on macOS")
    local mode = options.mode or "release"
    assert(mode == "debug" or mode == "release", "--mode must be debug or release")
    local device = options.appledev or "simulator"
    local arch = options.arch or "arm64"
    local format = options.format or (device == "device" and "ipa" or "zip")
    assert(device == "device" or device == "simulator", "--appledev must be device or simulator")
    assert(arch == "arm64" or (device == "simulator" and arch == "x86_64"), "unsupported iOS architecture")
    assert(format == "zip" or (format == "ipa" and device == "device"), "IPA packaging requires an iOS device build")
    local root = os.projectdir()
    local configdir = path.join(root, "build/ios-config", device, arch, mode)
    local envs = {XMAKE_CONFIGDIR = configdir}
    local args = {"f", "-y", "-p", "iphoneos", "-a", arch, "-m", mode,
        "--appledev=" .. (device == "simulator" and "simulator" or "iphoneos"),
        "--builddir=" .. path.join(configdir, "build"), "--ccache=n"}
    local identity = os.getenv("DORA_IOS_SIGN_IDENTITY") or "-"
    table.insert(args, "--dora_ios_sign_identity=" .. identity)
    if identity == "-" then table.insert(args, "--xcode_codesign_identity=n") end
    local provision = os.getenv("DORA_IOS_PROVISION")
    assert(device ~= "device" or identity == "-" or provision,
        "Device signing requires DORA_IOS_PROVISION (installed profile name)")
    if provision then table.insert(args, "--dora_ios_provision=" .. provision) end
    os.vrunv(os.programfile(), args, {curdir = root, envs = envs})
    os.vrunv(os.programfile(), {"build", "-j", "6", "Dora"}, {curdir = root, envs = envs})
    local app = path.join(root, "build/iphoneos", device, arch, mode, "Dora.app")
    assert(os.isfile(path.join(app, "Dora")), "missing iOS application: " .. app)
    -- Always sign during packaging: changing an identity/profile must not be
    -- hidden by xmake's cached application-resource rule. Embed the original
    -- CMS profile, not the decoded XML emitted by that rule.
    local sign_args = {"--force", "--deep", "--timestamp=none", "--sign", identity}
    local entitlements
    if device == "device" and identity ~= "-" then
        local selected, decoded
        for _, directory in ipairs({"Library/MobileDevice/Provisioning Profiles", "Library/Developer/Xcode/UserData/Provisioning Profiles"}) do
            for _, file in ipairs(os.files(path.join(os.getenv("HOME"), directory, "*.mobileprovision"))) do
                local contents = try {function () return os.iorunv("security", {"cms", "-D", "-i", file}) end}
                if contents and contents:match("<key>Name</key>%s*<string>(.-)</string>") == provision then
                    selected, decoded = file, contents
                    break
                end
            end
            if selected then break end
        end
        assert(selected, "Installed provisioning profile not found: " .. provision)
        os.cp(selected, path.join(app, "embedded.mobileprovision"))
        local decoded_path = path.join(configdir, "signing-profile.plist")
        entitlements = path.join(configdir, "signing-entitlements.plist")
        io.writefile(decoded_path, decoded)
        os.vrunv("plutil", {"-extract", "Entitlements", "xml1", "-o", entitlements, decoded_path})
        table.join2(sign_args, {"--entitlements", entitlements})
    else
        os.tryrm(path.join(app, "embedded.mobileprovision"))
    end
    table.insert(sign_args, app)
    os.vrunv("codesign", sign_args)
    os.vrunv("codesign", {"--verify", "--deep", "--strict", app})
    local destination = path.join(root, "build/package/iphoneos", device, arch, mode)
    os.mkdir(destination)
    local archive = path.join(destination, "dora-ssr-ios-" .. device .. "." .. format)
    if format == "ipa" then
        local payload = path.join(destination, "Payload")
        os.mkdir(payload)
        os.tryrm(path.join(payload, "Dora.app"))
        os.vrunv("ditto", {app, path.join(payload, "Dora.app")})
        os.tryrm(archive)
        os.vrunv("zip", {"-qry", archive, "Payload"}, {curdir = destination})
    else
        os.vrunv("ditto", {"-c", "-k", "--keepParent", app, archive})
    end
    cprint("${green}iOS application: %s${clear}", app)
    cprint("${green}iOS package: %s${clear}", archive)
    if device == "device" and identity == "-" then
        cprint("${yellow}Ad-hoc device build: not installable/distributable without an Apple signing identity and provisioning profile.${clear}")
    end
end
