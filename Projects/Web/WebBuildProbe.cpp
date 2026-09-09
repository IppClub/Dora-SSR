#include "Platform/Web/WebTaskQueue.h"

#include <emscripten/emscripten.h>

namespace {

int probeState = 0;

}

extern "C" {

EMSCRIPTEN_KEEPALIVE int dora_web_build_probe() {
	return probeState == 2 ? 0x444f5241 : probeState;
}

}

int main() {
	probeState = 1;
	Dora::Web::postTask([]() {
		probeState = 2;
		EM_ASM({
			if (typeof Module !== "undefined" && Module.onDoraBuildProbeReady) {
				Module.onDoraBuildProbeReady(Module._dora_web_build_probe());
			}
		});
	});
	return probeState == 1 && Dora::Web::pendingTaskCount() == 1 ? 0 : 1;
}
