// Public domain, by Christopher Diggins
// http://www.cdiggins.com
//
// The YARD parse engine will report only the first error which occurs.

#ifndef YARD_ERROR_HPP
#define YARD_ERROR_HPP

namespace yard {
template <typename ParserState_T>
void OutputParsingErrorLocation(ParserState_T& p) {
	typedef typename ParserState_T::Iterator Iter_T;
	Iter_T first = p.Begin();
	Iter_T last = p.End();
	Iter_T cur = p.GetPos();

	// Go the beginning of the input, and count the number of newlines,
	Iter_T tmp = first;
	Iter_T line_begin = tmp;
	int line_cnt = 1;
	while (tmp != cur) {
		if (*tmp++ == '\n') {
			line_begin = tmp;
			line_cnt++;
		}
	}

	// count how many characters between the last newline character and the current position
	int char_cnt = static_cast<int>(tmp - line_begin);
	while ((tmp <= last) && (*tmp != '\n')) {
		tmp++;
	}

	std::cerr << "error occured on line #" << line_cnt << std::endl;
	std::cerr << std::string(line_begin, tmp) << std::endl;

	// this outputs a position pointer
	std::cerr << std::string(char_cnt, ' ') << '^' << std::endl;
}

void UnexpectedEndOfFile() {
	std::cerr << "unexpected end of input" << std::endl;
	throw std::runtime_error("unexpected end of input");
}
} // namespace yard

#endif
