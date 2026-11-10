-- Copy original RGBA rectangles with integer translations, without resampling.
local C = import("Tools.Godot.common", {rootdir = path.absolute(path.join(os.scriptdir(), "../../.."))})
local CELL, PADDING, PX, PY = 272, 4, 136, 248
local STATES = {"idle", "waiting", "thinking", "working", "success", "failed"}
local function median(values)
    table.sort(values); local middle = math.floor(#values / 2)
    return #values % 2 == 1 and values[middle + 1] or (values[middle] + values[middle + 1]) / 2
end
local function round(value)
    local base = math.floor(value); local fraction = value - base
    return fraction < 0.5 and base or fraction > 0.5 and base + 1 or (base % 2 == 0 and base or base + 1)
end
function components(data, width, height)
    local mask, found = {}, {}
    for index = 0, width * height - 1 do if data:byte(index * 4 + 4) >= 128 then mask[index] = true end end
    for index = 0, width * height - 1 do
        if mask[index] then
            local queue, first, count = {index}, 1, 0
            local left, top, right, bottom = width, height, 0, 0; mask[index] = nil
            while first <= #queue do
                local point = queue[first]; first = first + 1; count = count + 1
                local y, x = math.floor(point / width), point % width
                left, top, right, bottom = math.min(left, x), math.min(top, y), math.max(right, x + 1), math.max(bottom, y + 1)
                for _, neighbor in ipairs({x > 0 and point - 1 or -1, x < width - 1 and point + 1 or -1, y > 0 and point - width or -1, y < height - 1 and point + width or -1}) do
                    if mask[neighbor] then mask[neighbor] = nil; queue[#queue + 1] = neighbor end
                end
            end
            if count > 1000 then found[#found + 1] = {left, top, right, bottom} end
        end
    end
    assert(#found == 24, "Expected 24 separate characters, found " .. #found)
    table.sort(found, function (a, b) return a[2] + a[4] < b[2] + b[4] end)
    local result = {}
    for row = 0, 5 do local group = table.slice(found, row * 4 + 1, row * 4 + 4); table.sort(group, function (a, b) return a[1] < b[1] end); table.join2(result, group) end
    return result
end
function align(data, width, height)
    local frames, metadata = {}, {}
    for index, box in ipairs(components(data, width, height)) do
        local feet, last = {}, nil
        for y = box[4] - 16, box[4] - 1 do
            local left, right, count = nil, nil, 0
            for x = box[1], box[3] - 1 do if data:byte((y * width + x) * 4 + 4) >= 192 then left = left or x; right = x; count = count + 1 end end
            if count >= 6 then feet[#feet + 1] = (left + right + 1) / 2; last = y + 1 end
        end
        assert(#feet > 0, "No feet in frame")
        local pivot = {median(feet), last}
        local crop = {math.max(0, box[1] - PADDING), math.max(0, box[2] - PADDING), math.min(width, box[3] + PADDING), math.min(height, box[4] + PADDING)}
        local shift = {round(PX - pivot[1]), round(PY - pivot[2])}
        local destination = {crop[1] + shift[1], crop[2] + shift[2]}
        assert(destination[1] >= 1 and destination[2] >= 1 and destination[1] + crop[3] - crop[1] < CELL and destination[2] + crop[4] - crop[2] < CELL, "Translated frame exceeds cell")
        local rows = {}
        for y = 0, CELL - 1 do
            if y >= destination[2] and y < destination[2] + crop[4] - crop[2] then
                local source_y = crop[2] + y - destination[2]
                rows[#rows + 1] = string.rep("\0", destination[1] * 4) .. data:sub((source_y * width + crop[1]) * 4 + 1, (source_y * width + crop[3]) * 4) .. string.rep("\0", (CELL - destination[1] - crop[3] + crop[1]) * 4)
            else rows[#rows + 1] = string.rep("\0", CELL * 4) end
        end
        frames[#frames + 1] = rows
        metadata[#metadata + 1] = {state = STATES[math.floor((index - 1) / 4) + 1], frame = (index - 1) % 4,
            source_box = box, source_crop = crop, source_pivot = pivot, destination = destination, translation = shift, pivot = {pivot[1] + shift[1], pivot[2] + shift[2]}}
    end
    local rows = {}
    for row = 0, 5 do for y = 1, CELL do for col = 1, 4 do rows[#rows + 1] = frames[row * 4 + col][y] end end end
    return table.concat(rows), metadata
end
function main(...)
    local args = C.args({...}, {output = "value", ["layout-output"] = "value", evidence = "value"})
    local evidence = C.required(args, "evidence")
    local source = path.join(os.scriptdir(), "dora-remix-states.original.png")
    local default = path.join(C.root(), "Assets/Image/Mobile/dora-remix-states.png")
    local output = C.real(args.output or default)
    import("lib.detect.find_tool")
    local magick = assert(find_tool("magick"), "Mascot rebuilding requires ImageMagick 7 (magick)").program
    local dimensions = os.iorunv(magick, {"identify", "-format", "%w %h", source})
    local width, height = dimensions:match("^(%d+)%s+(%d+)$"); width, height = assert(tonumber(width)), assert(tonumber(height))
    local rawfile = os.tmpfile() .. ".rgba"
    local rgba
    try {function ()
        C.run(magick, {source, "-depth", "8", "rgba:" .. rawfile})
        rgba = C.read(rawfile)
    end, finally {function (ok, errors) os.tryrm(rawfile); if not ok then raise(errors) end end}}
    assert(#rgba == width * height * 4, "Unexpected RGBA buffer size")
    local atlas, metadata = align(rgba, width, height)
    local temporary = os.tmpfile() .. ".rgba"
    try {function () C.write(temporary, atlas); os.mkdir(path.directory(output)); C.run(magick, {"-size", "1088x1632", "-depth", "8", "rgba:" .. temporary, "-strip", output}) end,
        finally {function (ok, errors) os.tryrm(temporary); if not ok then raise(errors) end end}}
    os.mkdir(evidence)
    local pivots = {}; for _, frame in ipairs(metadata) do local value = frame.pivot[1]; pivots[#pivots + 1] = value % 1 == 0 and ("%.1f"):format(value) or tostring(value) end
    local layout = args["layout-output"] or (output == C.real(default) and path.join(C.root(), "Assets/Script/Dev/Mobile/MascotFrames.ts") or path.join(evidence, "MascotFrames.ts"))
    C.write(layout, "// Generated by Tools/Art/Mobile/rebuild_mascot.lua. Do not hand-edit.\nexport const MASCOT_CELL_SIZE = 272;\nexport const MASCOT_PIVOT_Y = 248;\nexport const MASCOT_FRAME_PIVOT_X: number[] = [" .. table.concat(pivots, ", ") .. "];\n")
    C.save(path.join(evidence, "atlas.json"), {mode = "original-rgba-alignment-only", source_sha256 = C.digest(source), atlas_sha256 = C.digest(output), cell_size = CELL, target_pivot = {PX, PY}, padding = PADDING, frames = metadata})
    local command = {output, "-background", "#242b38", "-alpha", "remove", "-alpha", "off", "-stroke", "#628472"}
    for row = 0, 5 do table.join2(command, {"-draw", ("line 0,%d 1087,%d"):format(row * CELL + PY, row * CELL + PY)}) end
    command[#command + 1] = path.join(evidence, "contact-sheet.png"); C.run(magick, command)
    print("Wrote original-RGBA atlas 1088x1632: %s", output)
end
