-- Validate the completed per-input NIR distribution notice review.
function verify_review(review, provenance, require_hash)
    local C = import("common", {rootdir = os.scriptdir()})
    local J = import("ordered_json", {rootdir = os.scriptdir()})
    assert(type(review) == "table" and review.schema == 1 and review.inheritance_review_complete == true,
        "NIR license review is incomplete")
    assert(review.godot_nir_tag == provenance.godot_nir_tag and review.mesa_commit == provenance.mesa_commit,
        "NIR license review version mismatch")
    local expected_hash = provenance.license_review_sha256
    if require_hash ~= false then
        assert(type(expected_hash) == "string" and #expected_hash == 64, "NIR license review digest missing")
    end
    if expected_hash then
        assert(C.data_digest(J.encode(review) .. "\n") == expected_hash, "NIR license review integrity mismatch")
    end
    local expected, inventory, seen = {}, {}, {}
    for _, name in ipairs(provenance.files_without_notice_blocks or {}) do expected[name] = true end
    for _, row in ipairs(provenance.files or {}) do inventory[row.path] = row.sha256 end
    local rows = review.files or {}
    assert(#rows == #C.keys(expected), "NIR license review coverage mismatch")
    for _, row in ipairs(rows) do
        assert(expected[row.path] and not seen[row.path], "NIR license review coverage mismatch")
        seen[row.path] = true
        assert(row.reviewed == true and row.sha256 == inventory[row.path] and row.basis and row.basis ~= ""
            and row.evidence and (type(row.evidence) ~= "table" or not table.empty(row.evidence))
            and table.contains({"MIT", "Apache-2.0", "metadata", "build-input-only"}, row.license),
            "NIR license review entry is invalid: " .. row.path)
    end
    return true
end
