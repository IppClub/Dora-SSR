# Go UI controller navigation

Uses Dora's SDL-mapped controller names (Xbox-style A/B/X/Y). Gamepad navigation
shares the existing touch actions; it does not generate mouse events or send LLM
requests independently.

| Screen | Controls |
| --- | --- |
| Feed | Up/down: previous/next card; left/right: focus buttons; A: activate; X: Remix; Y: new project; LB/RB: Discover/Local; B: traditional UI |
| Remix and dialogs | D-pad/left stick: move focus; A: activate/focus input; B: dismiss input first, then return/close; right stick up/down: scroll Remix messages |
| Play | Back/Select + Start/Menu: reveal exit; repeat while visible to exit; B: collapse; auto-hides after 3 seconds |

Only the top visible Go screen handles UI actions. Focus survives redraws and
modal navigation; hidden and disabled controls are skipped. Left-stick deadzone
is 0.55 with a 0.38-second initial repeat delay and 0.13-second repeat interval.
Disconnect/background clears held navigation. Typing uses the existing platform
IME/system keyboard and clipboard controls, not a new on-screen keyboard.

During play, ordinary buttons never activate Go's exit control. Controller events
are broadcast by Dora, so the running game can also observe the exit chord.

## Testing

The regression tests and virtual-controller instructions live in the separate
Dora-Example repository under `Test/Mobile/README.md`.
