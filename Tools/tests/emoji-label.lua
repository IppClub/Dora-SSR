-- Run this directory as a project (init.lua can require this file).
-- Assertions exercise the native Label/FontCache path in both rendering modes.
local Dora = require('Dora')
local Label, Cache, Director, Content = Dora.Label, Dora.Cache, Dora.Director, Dora.Content
local texts = {
    {'ASCII 中文 😊🤔✅', 12},
    {'1️⃣', 3},
    {'👩‍💻', 3},
    {'👍🏽', 2},
    {'🇨🇳', 2},
    {'❤️', 2},
}
local labels = {}
for mode = 1, 2 do
    for i, sample in ipairs(texts) do
        local label = assert(Label('sarasa-mono-sc-regular', 32))
        label.batched = mode == 1
        label.text = sample[1]
        assert(label.text == sample[1], 'Unicode text changed')
        -- Preserve the existing API count, which includes the terminal NUL.
        assert(label.characterCount == sample[2] + 1, 'Unicode code points were removed: ' .. sample[1])
        label.position = Dora.Vec2((mode - 1) * 400 - 200, 220 - i * 60)
        Director.entry:addChild(label)
        labels[#labels + 1] = label
    end
end
Cache:removeUnused('Font')
local frames = 0
Director.entry:schedule(function()
    frames = frames + 1
    if frames == 15 then
        Cache:unload('Font')
        Cache:removeUnused()
    elseif frames == 30 then
        for _, label in ipairs(labels) do
            local text = label.text
            label.text = text .. ' 😊'
            label.text = text
        end
    elseif frames == 60 then
        print('EMOJI_LABEL_REGRESSION_OK: Unicode indices, batched/non-batched, cache eviction')
        Content:save(Content.writablePath .. '/emoji-label-result.txt', 'EMOJI_LABEL_REGRESSION_OK')
        return true
    end
    return false
end)
return labels
