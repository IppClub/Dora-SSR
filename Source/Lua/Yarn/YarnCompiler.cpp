/* Copyright (c) 2023 Jin Li, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Lua/Yarn/YarnCompiler.h"

#include "yuescript/ast.hpp"
#include <sstream>

namespace pl = parserlib;

extern std::unordered_set<std::string> LuaKeywords;

namespace Utils {

void replace(std::string& str, std::string_view from, std::string_view to) {
	size_t start_pos = 0;
	while ((start_pos = str.find(from, start_pos)) != std::string::npos) {
		str.replace(start_pos, from.size(), to);
		start_pos += to.size();
	}
}

void trim(std::string& str) {
	if (str.empty()) return;
	str.erase(0, str.find_first_not_of(" \t\r\n"));
	str.erase(str.find_last_not_of(" \t\r\n") + 1);
}

} // namespace Utils

namespace parserlib {

#define AST_LEAF(type) \
	COUNTER_INC; \
	namespace yarn { \
	class type##_t : public ast_node { \
	public: \
		virtual int getId() const override { return COUNTER_READ; }

#define AST_NODE(type) \
	COUNTER_INC; \
	namespace yarn { \
	class type##_t : public ast_container { \
	public: \
		virtual int getId() const override { return COUNTER_READ; }

#define AST_MEMBER(type, ...) \
	type##_t() { \
		add_members({__VA_ARGS__}); \
	}

#define AST_END(type, name) \
	virtual const std::string_view getName() const override { return name; } \
	} \
	; \
	} \
	template <> \
	constexpr int id<yarn::type##_t>() { return COUNTER_READ; }

} // namespace parserlib

namespace parserlib {

// clang-format off

AST_LEAF(Seperator)
AST_END(Seperator, "seperator"sv)

AST_LEAF(Num)
AST_END(Num, "num"sv)

AST_LEAF(Name)
AST_END(Name, "name"sv)

AST_NODE(Variable)
	ast_ptr<true, Name_t> name;
	AST_MEMBER(Variable, &name)
AST_END(Variable, "variable"sv)

// clang-format on

} // namespace parserlib

namespace yarn {
using namespace std::string_view_literals;
using namespace std::string_literals;
using namespace parserlib;
using namespace parserlib::yarn;

struct ParseInfo {
	struct Error {
		std::string msg;
		int line;
		int col;
	};
	ast_ptr<false, ast_node> node;
	std::optional<Error> error;
	std::unique_ptr<input> codes;
	std::string errorMessage(std::string_view msg, int errLine, int errCol, int lineOffset = 0) const {
		const int ASCII = 255;
		int length = errLine;
		auto begin = codes->begin();
		auto end = codes->end();
		int count = 0;
		for (auto it = codes->begin(); it != codes->end(); ++it) {
			if (*it == '\n') {
				if (count + 1 == length) {
					end = it;
					break;
				} else {
					begin = it + 1;
				}
				count++;
			}
		}
		int oldCol = errCol;
		int col = std::max(0, oldCol - 1);
		auto it = begin;
		for (int i = 0; i < oldCol && it != end; ++i) {
			if (*it > ASCII) {
				++col;
			}
			++it;
		}
		auto line = Converter{}.to_bytes(std::wstring(begin, end));
		while (col < static_cast<int>(line.size())
			   && (line[col] == ' ' || line[col] == '\t')) {
			col++;
		}
		Utils::replace(line, "\t"sv, " "sv);
		std::ostringstream buf;
		buf << errLine + lineOffset << ": "sv << msg << '\n'
			<< line << '\n'
			<< std::string(col, ' ') << "^"sv;
		return buf.str();
	}
};

template <typename T>
struct identity {
	typedef T type;
};

#ifdef NDEBUG
#define NONE_AST_RULE(type) \
	rule type;

#define AST_RULE(type) \
	rule type; \
	ast<type##_t> type##_impl = type; \
	inline rule& getRule(identity<type##_t>) { return type; }
#else // NDEBUG
#define NONE_AST_RULE(type) \
	rule type{#type, rule::initTag{}};

#define AST_RULE(type) \
	rule type{#type, rule::initTag{}}; \
	ast<type##_t> type##_impl = type; \
	inline rule& getRule(identity<type##_t>) { return type; }
#endif // NDEBUG

class YarnParser {
public:
	class ParserError : public std::logic_error {
	public:
		explicit ParserError(std::string_view msg, const pos* begin)
			: std::logic_error(std::string(msg))
			, line(begin->m_line)
			, col(begin->m_col) { }

		int line;
		int col;
	};

	YarnParser() {
		plain_space = *set(" \t");
		line_break = nl(-expr('\r') >> '\n');
		any_char = line_break | any();
		stop = line_break | eof();
		comment = '#' >> *(not_(set("\r\n")) >> any_char) >> and_(stop);
		space_one = set(" \t");
		space = -(and_(set(" \t-\\")) >> *space_one >> -comment);
		space_break = space >> line_break;
		white = space >> *(line_break >> space);
		alpha_num = range('a', 'z') | range('A', 'Z') | range('0', '9') | '_';
		not_alpha_num = not_(alpha_num);
		Name = (range('a', 'z') | range('A', 'Z') | '_') >> *alpha_num;
		num_expo = set("eE") >> -set("+-") >> num_char;
		num_expo_hex = set("pP") >> -set("+-") >> num_char;
		num_char = range('0', '9') >> *(range('0', '9') | '_' >> and_(range('0', '9')));
		num_char_hex = range('0', '9') | range('a', 'f') | range('A', 'F');
		num_lit = num_char_hex >> *(num_char_hex | '_' >> and_(num_char_hex));
		Num = "0x" >> (+num_lit >> ('.' >> +num_lit >> -num_expo_hex | num_expo_hex | true_()) | ('.' >> +num_lit >> -num_expo_hex)) | +num_char >> ('.' >> +num_char >> -num_expo | num_expo | true_()) | '.' >> +num_char >> -num_expo;

		cut = false_();
		Seperator = true_();

		empty_block_error = pl::user(true_(), [](const item_t& item) {
			throw ParserError("must be followed by a statement or an indented block"sv, item.begin);
			return false;
		});

#define ensure(patt, finally) ((patt) >> (finally) | (finally) >> cut)

#define key(str) (expr(str) >> not_alpha_num)
	}

	template <class AST>
	ParseInfo parse(std::string_view codes) {
		return parse(codes, getRule<AST>());
	}

	template <class AST>
	bool match(std::string_view codes) {
		auto rEnd = rule(getRule<AST>() >> eof());
		return parse(codes, rEnd).node;
	}

	std::string toString(ast_node* node) {
		return _converter.to_bytes(std::wstring(node->m_begin.m_it, node->m_end.m_it));
	}

	std::string toString(input::iterator begin, input::iterator end) {
		return _converter.to_bytes(std::wstring(begin, end));
	}

protected:
	ParseInfo parse(std::string_view codes, rule& r) {
		ParseInfo res;
		if (codes.substr(0, 3) == "\xEF\xBB\xBF"sv) {
			codes = codes.substr(3);
		}
		try {
			if (!codes.empty()) {
				res.codes = std::make_unique<input>(_converter.from_bytes(&codes.front(), &codes.back() + 1));
			} else {
				res.codes = std::make_unique<input>();
			}
		} catch (const std::range_error&) {
			res.error = {"invalid text encoding"s, 1, 1};
			return res;
		}
		error_list errors;
		try {
			State state;
			res.node.set(::yarn::parse(*(res.codes), r, errors, &state));
		} catch (const ParserError& err) {
			res.error = {err.what(), err.line, err.col};
			return res;
		} catch (const std::logic_error& err) {
			res.error = {err.what(), 1, 1};
			return res;
		}
		if (!errors.empty()) {
			const error& err = errors.front();
			switch (err.m_type) {
				case ERROR_TYPE::ERROR_SYNTAX_ERROR:
					res.error = {"syntax error"s, err.m_begin.m_line, err.m_begin.m_col};
					break;
				case ERROR_TYPE::ERROR_INVALID_EOF:
					res.error = {"invalid EOF"s, err.m_begin.m_line, err.m_begin.m_col};
					break;
			}
		}
		return res;
	}

	struct State {
		State() {
			indents.push(0);
		}
		std::stack<int> indents;
	};

	template <class T>
	inline rule& getRule() {
		return getRule(identity<T>());
	}

private:
	Converter _converter;

	template <class T>
	inline rule& getRule(identity<T>) {
		assert(false);
		return cut;
	}

	NONE_AST_RULE(plain_space);
	NONE_AST_RULE(line_break);
	NONE_AST_RULE(any_char);
	NONE_AST_RULE(stop);
	NONE_AST_RULE(comment);
	NONE_AST_RULE(multi_line_open);
	NONE_AST_RULE(multi_line_close);
	NONE_AST_RULE(multi_line_content);
	NONE_AST_RULE(multi_line_comment);
	NONE_AST_RULE(escape_new_line);
	NONE_AST_RULE(space_one);
	NONE_AST_RULE(space);
	NONE_AST_RULE(space_break);
	NONE_AST_RULE(white);
	NONE_AST_RULE(alpha_num);
	NONE_AST_RULE(not_alpha_num);
	NONE_AST_RULE(num_expo);
	NONE_AST_RULE(num_expo_hex);
	NONE_AST_RULE(num_char);
	NONE_AST_RULE(num_char_hex);
	NONE_AST_RULE(num_lit);
	NONE_AST_RULE(cut);
	NONE_AST_RULE(empty_block_error);

	AST_RULE(Name);
	AST_RULE(Num);
	AST_RULE(Seperator);
};

} // namespace yarn
