// @preview-file off clear

// Single source for the declared tool timeouts and the budgets that enforce
// them, so the registry metadata and the runtime checks cannot drift apart.
export const PREVIEW_GAME_TIMEOUT_SECONDS = 40;
export const PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS = PREVIEW_GAME_TIMEOUT_SECONDS / 2;
export const ANALYZE_IMAGE_TIMEOUT_SECONDS = 65;
// Headroom under the declared budget for parsing and bookkeeping after the HTTP call.
export const ANALYZE_IMAGE_HTTP_TIMEOUT_SECONDS = ANALYZE_IMAGE_TIMEOUT_SECONDS - 5;
