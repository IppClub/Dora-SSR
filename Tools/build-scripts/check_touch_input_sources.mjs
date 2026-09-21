import assert from "node:assert/strict";
import fs from "node:fs";

const source = fs.readFileSync("Source/Input/TouchDispather.cpp", "utf8");

assert.match(
	source,
	/#if BX_PLATFORM_EMSCRIPTEN\s+Touch::FromMouseAndTouch;/,
	"Web input must accept both real mouse and touch events",
);
assert.match(
	source,
	/#elif BX_PLATFORM_OSX\s+Touch::FromMouse;/,
	"macOS must keep its mouse-only input source",
);
assert.match(
	source,
	/#else\s+Touch::FromTouch;/,
	"Windows, mobile, and Linux must use SDL's touch input path",
);

for (const event of ["button", "motion"]) {
	assert.match(
		source,
		new RegExp(`Touch::FromMouseAndTouch\\) == Touch::FromMouseAndTouch && event\\.${event}\\.which == SDL_TOUCH_MOUSEID`),
		`Synthetic touch-generated ${event} events must remain filtered`,
	);
}
assert.match(
	source,
	/Touch::FromMouseAndTouch\) == Touch::FromMouseAndTouch && event\.tfinger\.touchId == SDL_MOUSE_TOUCHID/,
	"Synthetic mouse-generated touch events must remain filtered",
);
assert.doesNotMatch(
	source,
	/Touch::FromMouseAndTouch\) && event\./,
	"Single-source input must not discard SDL's synthesized compatibility events",
);
assert.equal(
	(source.match(/Touch::FromMouseAndTouch\) == Touch::FromMouseAndTouch && event\./g) ?? []).length,
	6,
	"All down, up, and move duplicate guards must require dual-source input",
);

console.log("Touch input source contract passed.");
