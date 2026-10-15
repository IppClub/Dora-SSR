# Label font fallback

When the selected Label font has no glyph for a code point, FontCache tries
`Font/NotoEmoji.ttf` at the same baked size and with the same SDF setting.
The original font is used if neither font contains that code point.
The fallback is monochrome, including for fonts that normally use color emoji.

This is **single-code-point glyph fallback**, not Unicode text shaping.
Label keeps the complete original Unicode sequence and its existing character
indices: variation selectors, ZWJ, keycap marks, skin-tone modifiers and tag
characters are not deleted. Sequences such as `1️⃣`, `👩‍💻`, flags and skin-tone
combinations are not guaranteed to render as one composed glyph. Applications
requiring composed emoji should use prepared images until the text renderer
supports shaping. Simple emoji such as `😊`, `🤔` and `✅` use the fallback font
when they are absent from the selected font.

The selected Font retains its fallback Font, so active Labels keep the fallback
atlases alive across `Cache:removeUnused()` and font-cache unloads. A full font
cache unload also clears a failed fallback-file lookup so a subsequently
installed font can be loaded.

The Web preset bundles the fallback font and its license alongside the default
font. Custom/core Web profiles without built-in libraries must include
`Font/NotoEmoji.ttf` and its license as project assets to enable this fallback.

Noto Emoji is distributed under [SIL OFL 1.1](NotoEmoji-OFL.txt).
