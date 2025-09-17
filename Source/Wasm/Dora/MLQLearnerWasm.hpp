/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t qlearner_type() {
	return DoraType<MLQLearner>();
}
DORA_EXPORT void mlqlearner_update(int64_t self, int64_t state, int32_t action, double reward) {
	r_cast<MLQLearner*>(self)->update(s_cast<MLQState>(state), s_cast<MLQAction>(action), reward);
}
DORA_EXPORT int32_t mlqlearner_get_best_action(int64_t self, int64_t state) {
	return s_cast<int32_t>(r_cast<MLQLearner*>(self)->getBestAction(s_cast<MLQState>(state)));
}
DORA_EXPORT void mlqlearner_visit_matrix(int64_t self, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	ML_QLearnerVisitStateActionQ(r_cast<MLQLearner*>(self), [func0, args0, deref0](MLQState state, MLQAction action, double q) {
		args0->clear();
		args0->push(s_cast<int64_t>(state));
		args0->push(s_cast<int64_t>(action));
		args0->push(q);
		SharedWasmRuntime.invoke(func0);
	});
}
DORA_EXPORT int64_t mlqlearner_pack(int64_t hints, int64_t values) {
	return s_cast<int64_t>(MLQLearner::pack(Vec_FromUint32(hints), Vec_FromUint32(values)));
}
DORA_EXPORT int64_t mlqlearner_unpack(int64_t hints, int64_t state) {
	return Vec_To(MLQLearner::unpack(Vec_FromUint32(hints), s_cast<MLQState>(state)));
}
DORA_EXPORT int64_t mlqlearner_new(double gamma, double alpha, double max_q) {
	return Object_From(MLQLearner::create(gamma, alpha, max_q));
}
} // extern "C"

static void linkMLQLearner(wasm3::module3& mod) {
	mod.link_optional("*", "qlearner_type", qlearner_type);
	mod.link_optional("*", "mlqlearner_update", mlqlearner_update);
	mod.link_optional("*", "mlqlearner_get_best_action", mlqlearner_get_best_action);
	mod.link_optional("*", "mlqlearner_visit_matrix", mlqlearner_visit_matrix);
	mod.link_optional("*", "mlqlearner_pack", mlqlearner_pack);
	mod.link_optional("*", "mlqlearner_unpack", mlqlearner_unpack);
	mod.link_optional("*", "mlqlearner_new", mlqlearner_new);
}