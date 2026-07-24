# NanoVG 文本切换到 FontManager SDF 缓存方案

## 目标

将 NanoVG 当前基于 `fontstash` 的字体和 glyph 缓存切换到 Dora 引擎统一的 `FontManager` 字体缓存体系。切换后，NanoVG 文本不再维护自己的字体 atlas，字体文件、glyph 缓存、atlas 纹理和生命周期统一由 `FontCache`/`FontManager` 管理。

最终方案采用固定 SDF 烘焙字号：

- NanoVG 注册字体时只记录字体资源名或字体文件。
- `FontManager` 为 NanoVG 文本创建固定 SDF 字号的 `FontHandle`，例如 64px。
- `nvg.FontSize()` 和 transform scale 只影响 glyph quad 与 advance 的缩放，不再产生新的 glyph bitmap size。
- `nvg.FontBlur()` 不再生成 blur bitmap，而是在 NanoVG SDF text shader 中通过扩大边缘过渡范围模拟。

## 背景

当前 NanoVG 文本路径在 `Source/3rdParty/nanovg/nanovg.cpp` 中直接持有 `FONScontext* fs`，`nvgCreateFont()`、`nvgFindFont()`、`nvgFontFace()`、`nvgText()`、`nvgTextBounds()` 等接口都依赖 `fontstash`。

`fontstash` 的缓存模型是按字体、字号、blur 和 codepoint 缓存 glyph bitmap，并把 glyph 放入 NanoVG 自己的 atlas。这个模型适合 NanoVG 原始实现，但会带来以下问题：

- 字体文件缓存和引擎 `FontCache` 重复。
- glyph atlas 和 `Label` 使用的 `FontManager` atlas 重复。
- 字体资源统计、卸载、清理不走引擎统一路径。
- `nvg::CreateFont(name)` 当前直接把 `name` 当 filename 传给 `fontstash`，没有复用 `FontCache::loadFontFile()` 的资源查找规则。

引擎侧 `FontManager` 已经具备按 `FontHandle + CodePoint` 懒加载 glyph，并返回 atlas、region、metrics 的能力。`FontCache` 已经负责字体文件查找、字体文件缓存和 `FontHandle` 创建。

## 方案选择

### 不采用动态字号 FontManager 缓存

一种直接做法是把 NanoVG 的实际字号 `state->fontSize * transformScale * devicePixelRatio` 映射为 `FontManager` 的 pixel size，每个字号创建一个 `FontHandle`。

这个方案不采用，原因是：

- NanoVG 文本常被 transform scale 影响，动态缩放动画可能不断产生新 pixel size。
- 即使沿用 NanoVG 的 0.01 scale 量化，也仍会产生较多 `FontHandle`。
- `FontManager` 当前更适合稳定字号的 `Label` 场景，`MAX_OPENED_FONT` 对动态字号路径偏紧。
- `FontBlur` 如果纳入 glyph cache key，会进一步把缓存维度扩大为 `font + size + blur + codepoint`。

### 采用固定 SDF 字号

最终采用固定 SDF base size。NanoVG 文本统一用固定像素高度烘焙 SDF glyph，实际显示大小通过顶点几何缩放实现。

推荐默认值：

- `DORA_SDF_FONT_BASE_SIZE = 64`
- `DORA_NVG_SDF_SOFTNESS =` shader 中的默认边缘宽度
- `DORA_NVG_MAX_BLUR =` 可模拟的最大 blur 范围，受 SDF padding 限制

固定 SDF 字号后，缓存 key 变为：

```text
fontName + sdfBaseSize + codepoint
```

而不是：

```text
fontName + actualPixelSize + blur + codepoint
```

这能从根上避免 NanoVG 动态字号导致的 glyph 缓存膨胀。

## 架构设计

### 字体注册

NanoVG 内部新增 Dora 字体注册表，替代 `fontstash` 的字体表。

建议结构：

```cpp
struct NVGDoraFont {
	std::string name;
	std::string fontName;
	Dora::Ref<Dora::Font> sdfFont;
	std::vector<int> fallbacks;
};
```

其中：

- `name` 是 NanoVG API 层的字体名。
- `fontName` 是传给 `FontCache` 的字体资源名。
- `sdfFont` 是固定 SDF base size 创建出的 `Font`。
- `fallbacks` 对应 `nvgAddFallbackFont*()`，首版可以保留接口并延后完整实现。

`nvgCreateFont(ctx, name, filename)` 的新行为：

1. 使用 `FontCache` 的查找规则加载字体文件。
2. 调用 `SharedFontCache.load(filename, DORA_SDF_FONT_BASE_SIZE, true)` 创建固定 SDF 字体。`DORA_SDF_FONT_BASE_SIZE` 是 `Const/Config.h` 中的引擎编译常量，供 NanoVG 和 Label 的 SDF 文本路径共享。
3. 分配 NanoVG font id，并写入 `name -> fontId`。

`nvgFontFace()` 和 `nvgFontFaceId()` 只更新 `NVGstate::fontId`，不直接接触 `FontHandle`。

### glyph 获取

绘制或测量时，根据当前 `fontId` 获取 `NVGDoraFont::sdfFont`，然后通过：

```cpp
const bgfx::GlyphInfo* glyph = SharedFontManager.getGlyphInfo(font->getHandle(), codepoint);
```

获取 glyph metrics 和 atlas region。

所有 metrics 先以 SDF base size 为单位，再按 NanoVG 当前逻辑字号缩放：

```cpp
float fontScale = state->fontSize / DORA_SDF_FONT_BASE_SIZE;
```

`state->fontSize` 只影响几何缩放和测量结果，不参与 `FontHandle` 创建。transform 与 device pixel ratio 仍由 NanoVG 的顶点变换和渲染管线处理，避免把字体 atlas 烘焙尺寸和屏幕输出尺寸重新耦合。

### quad 与 UV

每个 glyph 的 quad 由 `GlyphInfo` 计算：

```cpp
x0 = penX + glyph->offset_x * fontScale;
y0 = baseline + glyph->offset_y * fontScale;
x1 = x0 + glyph->width * fontScale;
y1 = y0 + glyph->height * fontScale;
penX += glyph->advance_x * fontScale + letterSpacing;
```

kerning 使用：

```cpp
SharedFontManager.getKerning(font->getHandle(), prevCodepoint, codepoint) * fontScale
```

UV 由 `glyph->atlas->getRegion(glyph->regionIndex)` 和 atlas texture size 计算。

### atlas 分批

`FontManager` 可能创建多个 atlas。单段文本内的 glyph 不一定落在同一张 atlas 纹理上。

因此 `nvgText()` 不能再假设整段文字绑定一个 `paint.image`。需要按 atlas texture 分批提交：

- 当前 batch 记录 `Texture2D* atlasTexture`。
- 新 glyph 的 atlas texture 与当前 batch 不同，则先 flush 当前 batch。
- 每个 batch 生成一次 `renderTriangles` 调用。

NanoVG bgfx backend 需要支持 text draw call 直接绑定外部 `bgfx::TextureHandle`，而不是通过 `paint.image` 查 `GLNVGtexture`。

建议方式：

- 给内部 text paint 或 render call 增加 `bgfx::TextureHandle textTexture`。
- `nvgRenderSetUniforms()` 中如果 draw call 带外部 texture，则直接使用该 handle。
- 普通 image paint 仍走现有 `paint.image -> GLNVGtexture` 路径。

### SDF shader

当前 NanoVG text 走 image shader，只采样 alpha。SDF 文本需要新增 shader 分支。

fragment 逻辑近似为：

```glsl
float dist = texture2D(s_tex, uv).r;
float alpha = smoothstep(edge - softness, edge + softness, dist);
```

参数：

- `edge` 默认取 SDF 中心阈值。
- `softness` 来自字号缩放和 `FontBlur` 映射。
- 输出颜色仍使用 NanoVG 当前 fill color 和 global alpha。

`FontBlur` 映射为更大的 `softness`：

```cpp
softness = baseSoftness + clamp(state->fontBlur, 0, maxBlur) * blurScale;
```

这不是 Gaussian blur 的像素级等价实现，但可以覆盖 NanoVG 常见的边缘柔化、阴影柔化和发光式模糊需求。

## 文本测量

`nvgTextBounds()`、`nvgTextBoxBounds()`、`nvgTextGlyphPositions()`、`nvgTextBreakLines()` 和 `nvgTextMetrics()` 必须使用同一套 Dora SDF text backend，不能继续调用 `fons*`。

测量规则：

- advance、kerning、glyph bounds 全部基于 `GlyphInfo` 缩放计算。
- line height 使用 `FontInfo` 的 ascender、descender、lineGap 缩放计算。
- align 行为保持 NanoVG API 语义。
- `FontBlur` 的额外 softness 可选计入 bounds。首版可以先保持几何 bounds，不把模糊扩边纳入测量；如果后续 UI 依赖精确裁剪，再补充 blur padding。

## fallback 策略

首版可以只实现 primary font。`nvgAddFallbackFontId()` 和 `nvgAddFallbackFont()` 保留接口和注册关系，但绘制时可以先不启用 fallback。

完整 fallback 需要 `FontManager` 提供“尝试获取 glyph，失败时不返回 fallback block”的能力。当前 `getGlyphInfo()` 失败会返回内部 fallback glyph，不方便判断当前字体是否真的包含该 codepoint。

建议后续增加：

```cpp
const GlyphInfo* tryGetGlyphInfo(FontHandle handle, CodePoint codePoint);
bool hasGlyph(FontHandle handle, CodePoint codePoint);
```

然后 NanoVG text backend 按 primary font、fallback fonts 顺序查找 glyph。

## 与原 fontstash 行为差异

接受以下差异：

- `FontBlur` 改为 SDF shader softness 模拟，不保证与 fontstash CPU blur 像素一致。
- 动态 transform scale 不再改变 glyph bitmap resolution，只改变 SDF glyph 几何缩放。
- 超大字号质量受固定 SDF base size 和 SDF range 限制。
- 首版 fallback 可以不完整。

需要保持以下兼容：

- `nvg.CreateFont()`、`nvg.FindFont()`、`nvg.FontFace()`、`nvg.FontFaceId()` 脚本 API 不变。
- `nvg.Text()`、`nvg.TextBox()`、`nvg.TextBounds()`、`nvg.TextBreakLines()` 的坐标和 align 语义保持 NanoVG 预期。
- 普通 shape/image 渲染路径不受影响。

## 分阶段落地

## 进度记录

状态约定：

- `[ ]` 未开始
- `[~]` 进行中
- `[x]` 已完成
- `[!]` 阻塞或需后续确认

当前进度：

- [x] 阶段 1：Dora SDF text backend 骨架
- [x] 阶段 2：文本绘制
- [x] 阶段 3：文本测量和换行
- [~] 阶段 4：FontBlur 与质量调参
- [x] 阶段 5：fallback 完整化

执行记录：

- 2026-05-22：开始实现。首个目标是增加 NanoVG 内部 Dora 字体表，让 `nvgCreateFont()`、`nvgFindFont()`、`nvgFontFace()` 和 `nvgFontFaceId()` 不再依赖 `fontstash` 字体表。
- 2026-05-22：已在 `nanovg.cpp` 增加 Dora 字体表，`nvgCreateFont()` 通过 `SharedFontCache.load(..., DORA_SDF_FONT_BASE_SIZE, true)` 创建固定 SDF 字体。`nvgText()` 改为从 `SharedFontManager.getGlyphInfo()` 获取 glyph，并按 `FontManager` atlas texture 分批提交。
- 2026-05-22：已在 `nanovg_bgfx` 增加外部 `bgfx::TextureHandle` 注册接口，用于把 `FontManager` atlas 作为 NanoVG image 绑定，且设置 `NODELETE` 避免 NanoVG 销毁引擎持有的 atlas。
- 2026-05-22：已将 `nvgTextGlyphPositions()`、`nvgTextBounds()`、`nvgTextBoxBounds()`、`nvgTextMetrics()` 和 `nvgTextBreakLines()` 的默认 Dora 字体路径切到 `FontManager` metrics。当前换行实现为基础版，后续如需严格还原 fontstash 的 word break 细节可继续调整。
- 2026-05-22：已用 `clang++ -std=c++20 -DBX_CONFIG_DEBUG=0 -fsyntax-only` 检查 `Source/3rdParty/nanovg/nanovg.cpp` 和 `Source/3rdParty/nanovg/nanovg_bgfx.cpp` 通过。尚未完成 SDF 专用 shader，因此当前 `FontBlur` 仍未映射到 shader softness，SDF glyph 也还在复用现有 alpha image shader 路径。
- 2026-05-22：用户补充了 `Source/Shader/nanovg` 下的 NanoVG 原版 shader 源码。已把 SDF text 分支应用到 `Source/Shader/nanovg/fs_nanovg_fill.sc`：新增 `u_type == 4.0`，复用 `u_params.x` 作为 SDF softness、`u_params.y` 作为 edge。C++ 侧将 FontManager atlas 注册为 SDF text image，并把 `FontBlur` 映射到 softness 参数。剩余工作是生成新的 `fs_nanovg_fill.bin.h` 并让 NanoVG backend 使用更新后的 binary。
- 2026-05-22：已为 `FontManager` 增加 `hasGlyph()`，NanoVG fallback 字体链现在会在绘制、测量、glyph positions 和换行路径中参与 glyph 选择。若 primary font 不包含 codepoint，会按 `nvgAddFallbackFont*()` 注册顺序查找 fallback。
- 2026-05-22：已将 NanoVG shader binary 切到 `Source/Shader/nanovg` 下维护，`nanovg_bgfx.cpp` 改为包含 `Shader/nanovg/vs_nanovg_fill.bin.h` 和 `Shader/nanovg/fs_nanovg_fill.bin.h`。旧的 `Source/3rdParty/nanovg/*_nanovg_fill.bin.h` 已删除，Windows、dora-cs、iOS、macOS 工程中的旧文件引用已移除。
- 2026-05-22：确认保持 NanoVG 原语义：`FontFace()` 只选择已注册字体，不做隐式加载；脚本需要先显式调用 `CreateFont()`。同时修正 SDF shader 采样 `FontManager` 灰度 atlas 的 alpha 通道，并将 SDF edge 改为匹配引擎 SDF 生成器建议值的 `0.69`。
- 2026-05-22：修复 `VGNode` 多 NanoVG context 下的字体注册问题。脚本层 `nvg.CreateFont()` 成功后会记录显式注册过的字体名，`nvg.FontFace()` 和 `nvg.FindFont()` 在当前 context 查不到时，只会把这些已显式注册字体同步注册到当前 context；不恢复任意隐式加载语义。
- 2026-05-22：修复 SDF text shader 的预乘 alpha 输出。NanoVG bgfx backend 使用预乘 alpha 混合，SDF 分支需要让 RGB 和 A 同时乘以 `alpha * scissor`，否则透明区域仍会贡献 RGB，表现为每个 glyph quad 后面有彩色矩形块。
- 2026-05-22：第一轮质量调参：SDF shader 增加 3x3 alpha 采样平均，和引擎 Label 的 SDF 路径保持一致；C++ 侧 base softness 改为随 `fontSize / sdfBaseSize` 自适应，缩小字号时扩大过渡宽度，放大字号时收窄过渡宽度。
- 2026-05-22：将 SDF base size 收敛为 `Const/Config.h` 中的 `DORA_SDF_FONT_BASE_SIZE` 编译常量，默认值为 64。`FontCache` 的 SDF 加载会统一使用该 base size 创建 `FontHandle`，`Label` 的 SDF 路径保留显示字号并通过 `_fontScale = displaySize / DORA_SDF_FONT_BASE_SIZE` 缩放 metrics、glyph quad、kerning 和 padding；bitmap 字体路径继续按实际字号创建缓存。
- 2026-05-22：修复 SDF padding 导致的排版偏移。`FontManager` 生成 SDF glyph 时会在原 bitmap 外围加 `fontSize * SDF_FONT_BUFFER_PADDING_RATIO` 的 padding，NanoVG 绘制和测量现在会把 glyph quad 起点向左上扣回该 padding，避免文字整体向右下偏移。

### 阶段 1：Dora SDF text backend 骨架

- 在 NanoVG context 中增加 Dora font table。
- `nvgCreateFont()` 改为通过 `FontCache` 加载固定 SDF 字体。
- `nvgFindFont()`、`nvgFontFace()`、`nvgFontFaceId()` 改用 Dora font table。
- 保留 `fontstash` 代码但不再作为默认文本路径，方便对比和回退。

### 阶段 2：文本绘制

- 实现 UTF-8 codepoint 迭代。
- 使用 `FontManager::getGlyphInfo()` 生成 glyph quad。
- 按 atlas texture 分 batch。
- 扩展 NanoVG bgfx backend，让 text draw call 可绑定外部 `Texture2D` handle。
- 增加 SDF text shader 分支。

### 阶段 3：文本测量和换行

- 重写 `nvgTextBounds()`。
- 重写 `nvgTextGlyphPositions()`。
- 重写 `nvgTextBreakLines()` 和 `nvgTextBoxBounds()`。
- 重写 `nvgTextMetrics()`。

### 阶段 4：FontBlur 与质量调参

- 将 `state->fontBlur` 映射到 SDF softness。
- 限制最大 blur，避免超出 SDF range 后出现裁切或失真。
- 调整 SDF base size、padding 和 shader 参数。

### 阶段 5：fallback 完整化

- 为 `FontManager` 增加 `tryGetGlyphInfo()` 或 `hasGlyph()`。
- 启用 NanoVG fallback font 链。
- 增加缺字和 fallback 的测试场景。

## 验证项

- `nvg.CreateFont()` 能按 `FontCache` 规则加载 `Font/*.ttf` 和 `Font/*.otf`。
- 同一字体在不同 `nvg.FontSize()` 下不会创建多个 NanoVG glyph atlas，也不会为每个字号创建 `FontHandle`。
- `nvg.Text()` 在普通屏幕绘制和 `VGNode` framebuffer 绘制中都正常。
- 单段文字跨多个 `FontManager` atlas 时能正确分批渲染。
- `nvg.TextBounds()` 与实际绘制位置一致。
- `nvg.TextBox()` 的换行、align 和 line height 与现有 NanoVG 行为接近。
- `nvg.FontBlur()` 能产生可控柔化效果，并在 blur 超限时稳定退化。
- 普通 NanoVG shape/image paint 不受改动影响。

## 结论

切换到 `FontManager + 固定 SDF 字号 + shader 模拟 FontBlur` 是可行且更适合引擎长期维护的方案。它避免了动态字号导致的 glyph 缓存膨胀，同时把 NanoVG 文本纳入引擎统一字体资源管理。

这个方案不是简单替换 `fontstash` 的 atlas，而是为 NanoVG 实现一条 Dora text backend。首版应优先保证字体注册、SDF glyph 绘制、测量一致性和普通文本质量；`FontBlur` 精确兼容和 fallback 完整性可以作为后续增强。
