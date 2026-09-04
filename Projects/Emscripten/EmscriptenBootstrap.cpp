#include <emscripten.h>

namespace {

void mainLoop() { }

} // namespace

int main() {
	emscripten_set_main_loop(mainLoop, 0, true);
	return 0;
}
