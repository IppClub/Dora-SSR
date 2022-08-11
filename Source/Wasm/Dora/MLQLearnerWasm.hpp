static int32_t qlearner_type()
{
	return DoraType<MLQLearner>();
}
static void mlqlearner_update(int64_t self, int64_t state, int32_t action, double reward)
{
	r_cast<MLQLearner*>(self)->update(s_cast<uint64_t>(state), s_cast<uint32_t>(action), reward);
}
static int32_t mlqlearner_get_best_action(int64_t self, int64_t state)
{
	return s_cast<int32_t>(r_cast<MLQLearner*>(self)->getBestAction(s_cast<uint64_t>(state)));
}
static int64_t mlqlearner_new(double gamma, double alpha, double max_q)
{
	return from_object(MLQLearner::create(gamma, alpha, max_q));
}
static void linkMLQLearner(wasm3::module& mod)
{
	mod.link_optional("*", "qlearner_type", qlearner_type);
	mod.link_optional("*", "mlqlearner_update", mlqlearner_update);
	mod.link_optional("*", "mlqlearner_get_best_action", mlqlearner_get_best_action);
	mod.link_optional("*", "mlqlearner_new", mlqlearner_new);
}