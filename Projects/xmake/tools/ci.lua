-- Repository-owned metadata steps used by CI, without a Python dependency.
function main(command, argument)
    local root = path.absolute(path.join(os.scriptdir(), "../../.."))
    local C = import("Tools.Godot.common", {rootdir = root})
    if command == "release-version" then
        local version = "v" .. assert(C.read(path.join(root, "Source/Basic/Application.cpp")):match('#define DORA_VERSION "([%d%.]+)"'))
        if (os.getenv("GITHUB_REF") or ""):startswith("refs/tags/") then assert(os.getenv("GITHUB_REF_NAME") == version, "Tag and engine version differ") end
        local output = assert(io.open(assert(os.getenv("GITHUB_OUTPUT")), "a")); output:write("version=" .. version .. "\n"); output:close()
    elseif command == "runtime-release" then
        print("release=" .. tostring(C.load(path.join(assert(argument), "manifest.json")).build_target == "template_release"))
    elseif command == "candidate-receipt" then
        local values = {}; for _, name in ipairs({"ENGINE_SHA", "SOURCE_RUN_ID", "SOURCE_ARTIFACT_ID", "SOURCE_ARTIFACT_DIGEST"}) do values[name] = assert(os.getenv(name), name) end
        C.save(path.join(root, "build/godot-candidate-release/source.json"), values)
    else raise("Unknown CI metadata command: " .. tostring(command)) end
end
