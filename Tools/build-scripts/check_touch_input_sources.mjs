import assert from "node:assert/strict";
import fs from "node:fs";

const source = fs.readFileSync("Source/Input/TouchDispather.cpp", "utf8");

assert.match(
	source,
	/#if BX_PLATFORM_EMSCRIPTEN \|\| BX_PLATFORM_WINDOWS\s+Touch::FromMouseAndTouch;/,
	"Windows desktop input must accept both real mouse and touch events",
);
assert.match(
	source,
	/#elif BX_PLATFORM_OSX\s+Touch::FromMouse;/,
	"macOS must keep its mouse-only input source",
);
assert.match(
	source,
	/#else\s+Touch::FromTouch;/,
	"mobile and Linux platforms must keep their existing touch input source",
);

for (const event of ["button", "motion"]) {
	assert.match(
		source,
		new RegExp(`Touch::FromMouseAndTouch\\) && event\\.${event}\\.which == SDL_TOUCH_MOUSEID`),
		`Synthetic touch-generated ${event} events must remain filtered`,
	);
}
assert.match(
	source,
	/Touch::FromMouseAndTouch\) && event\.tfinger\.touchId == SDL_MOUSE_TOUCHID/,
	"Synthetic mouse-generated touch events must remain filtered",
);

console.log("Touch input source contract passed.");
