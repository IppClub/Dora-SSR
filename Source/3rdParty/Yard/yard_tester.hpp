// Dedicated to the public domain by Christopher Diggins
//
// This file contains helper code written for testing YARD grammars

#ifndef YARD_TESTER_HPP
#define YARD_TESTER_HPP

namespace yard_test {
template <typename Rule_T>
bool Test(const char* in) {
	const char* out = in + strlen(in);
	yard::SimpleTextParser parser(in, out);
	bool b = parser.Parse<yard::Seq<Rule_T, yard::EndOfInput>>();
	if (b) {
		printf("passed test for rule %s, on input %s\n", typeid(Rule_T).name(), in);
	} else {
		printf("FAILED test for rule %s, on input %s\n", typeid(Rule_T).name(), in);
	}
	return b;
}
} // namespace yard_test

#endif
