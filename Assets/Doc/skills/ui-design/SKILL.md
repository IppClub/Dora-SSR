---
name: ui-design
description: Use this skill when designing, creating, or polishing UI/screens/HUDs/menus so the result is visually refined, coherent, responsive, and implemented with the correct Dora UI APIs.
---

# UI Design

Use this skill when the user asks for UI, interface, screen, HUD, menu, panel, dashboard, visual polish, or "make it look good" work.

## Target

Code runs in Dora engine. Use `Dora`, `DoraX`, ImGui, or Dora UI APIs. Do not use DOM/browser APIs.

## Design Workflow

Before editing, form a small design brief:

- Purpose: what the screen helps the user/player do.
- Mood: e.g. calm, playful, premium, cyber, minimal, arcade.
- Hierarchy: primary action, secondary actions, status/info.
- Constraints: screen size, input method, existing theme/assets.

Then implement from structure to detail:

1. Layout and information hierarchy.
2. Spacing scale and alignment.
3. Color palette and contrast.
4. Typography and iconography.
5. Interaction states and motion.
6. Empty/loading/error states.

## Visual Quality Rules

- Do not ship plain default controls unless the user explicitly asks for plain UI.
- Use a cohesive palette: 1 primary color, 1 accent color, neutrals, and semantic colors.
- Use spacing consistently. Prefer a small scale such as `4/8/12/16/24/32`.
- Make the primary action obvious; reduce competing visual emphasis.
- Prefer cards, panels, subtle borders, shadows/glow, and layered backgrounds over flat random boxes.
- Use contrast intentionally: readable text, muted secondary text, clear disabled states.
- Add hover/pressed/focus/selected/running states where the UI is interactive.
- Add subtle motion only when it communicates state; avoid noisy infinite animation.
- Keep UI responsive to window/screen size. Avoid hard-coded coordinates unless tied to `View.size` or a known container.
- If using icons, keep stroke weight/style consistent.

## Dora Runtime UI Rules

When building UI inside a Dora game/workspace:

- Follow the `dora-engine-coding` skill first.
- Prefer `.tsx` with `DoraX` when JSX layout is useful; otherwise use Dora nodes directly.
- Use `search_dora_api` before unfamiliar Dora UI APIs.
- Attach runtime UI to the correct Dora node (`Director.ui`, `Director.entry`, or the existing root) based on project conventions.
- Use `View.size` to position and scale HUD elements; support resizing where possible.
- Keep reusable UI in modules/components instead of dumping large UI code into `init.ts` when the UI has multiple sections.
- Avoid browser-only APIs: `document`, `window`, DOM events, HTML canvas, CSS files, npm UI libraries.

### Core UI Components

| Component | Use Case |
|-----------|----------|
| `Node` | Base class for all UI elements, handles transform, touch, keyboard events |
| `Sprite` | Image/texture rendering with effects, blend modes |
| `Label` | Text rendering with SDF outline, alignment, batching |
| `Menu` | Touch event management for child nodes |
| `AlignNode` | Flexbox-like layout (flexDirection, justifyContent, alignItems, padding, margin, gap) |
| `DrawNode` | Custom drawing: dots, lines, polygons, rectangles |
| `ClipNode` | Stencil-based clipping for scrollable areas |

### UI Controls (Assets/Script/Lib/UI/Control/Basic/)

| Control | Description |
|---------|-------------|
| `Button` | Parametric button with text, size, font |
| `CircleButton` | Circular button variant |
| `ScrollArea` | Scrollable container |
| `FixedLabel` | Fixed-size label |

### Director Roots

| Root | Purpose |
|------|---------|
| `Director.entry` | Root node for game scene |
| `Director.ui` | Root node for 2D UI elements |
| `Director.ui3D` | Root node for 3D-projected UI |

### DoraX JSX Elements

Use `.tsx` files with DoraX for declarative UI:

```tsx
// Intrinsic elements
<node>, <sprite>, <label>, <menu>, <align-node>
<draw-node>, <clip-node>, <grid>, <particle>, <tile-node>

// Actions
<move>, <opacity>, <scale>, <sequence>, <spawn>, <loop>
```

Use `toNode()` when the TSX tree only needs to be materialized once. For state-driven UI, mount a dynamic root with `createRoot(parent)` and render from a function that reads `signal()` values:

```tsx
const count = signal(0);
const root = createRoot(parent);
root.render(() => <label text={`Count: ${count.value}`} />);
count.value += 1;
```

For dynamic sibling lists, provide stable `key` values. Omitted keys are only safe when child order and identity do not change.

### ImGui

For debug/development UI, use ImGui:
- Windows, buttons, sliders, color pickers
- Tables, tabs, menus, plots
- Style customization

### Vector Graphics (nvg/VGNode)

For custom vector graphics:
- Paths, arcs, bezier curves
- Gradients, text rendering
- Scissoring, transforms

Suggested module split for larger Dora UI:

```text
init.ts                  # entry wiring only
src/ui/theme.ts          # colors, spacing, fonts, helper constants
src/ui/components.tsx    # buttons/cards/badges/common widgets
src/ui/MainScreen.tsx    # composed screen/HUD
```

## Implementation Checklist

Before finishing, verify:

- The correct runtime target was used.
- The UI has clear hierarchy and spacing.
- Colors are coherent and accessible enough for the background.
- Primary, secondary, disabled, loading, and error states are handled where relevant.
- Text does not overflow obvious containers.
- The code is wired into the actual entry/screen and is not orphaned.
- Build/transpile succeeds, and any per-file diagnostics are fixed.

## Final Response

Briefly state:

- What UI was added or improved.
- Which files changed.
- How to run/preview it.
- Any design decisions worth noting.
