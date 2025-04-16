/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "yarnflow/yarn_compiler.h"

#include "yuescript/ast.hpp"

#include <memory>
#include <sstream>
#include <stack>

using namespace std::string_view_literals;

namespace pl = parserlib;

#define _DEFER(code, line) std::shared_ptr<void> _defer_##line(nullptr, [&](auto) { \
	code; \
})
#define DEFER(code) _DEFER(code, __LINE__)

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
	namespace yarnflow { \
	class type##_t : public ast_node { \
	public: \
		virtual int get_id() const override { return COUNTER_READ; }

#define AST_NODE(type) \
	COUNTER_INC; \
	namespace yarnflow { \
	class type##_t : public ast_container { \
	public: \
		virtual int get_id() const override { return COUNTER_READ; }

#define AST_MEMBER(type, ...) \
	type##_t() { \
		add_members({__VA_ARGS__}); \
	}

#define AST_END(type, name) \
	virtual const std::string_view get_name() const override { return name; } \
	} \
	; \
	} \
	template <> \
	constexpr int id<yarnflow::type##_t>() { return COUNTER_READ; }

} // namespace parserlib

namespace parserlib {

namespace yarnflow {
class Block_t;
class Exp_t;
class Value_t;
} // namespace yarnflow

// clang-format off

AST_LEAF(Seperator)
AST_END(Seperator, "seperator"sv)

AST_LEAF(Num)
AST_END(Num, "num"sv)

AST_LEAF(Boolean)
AST_END(Boolean, "boolean"sv)

AST_LEAF(Name)
AST_END(Name, "name"sv)

AST_LEAF(SingleString)
AST_END(SingleString, "single_string"sv)

AST_LEAF(DoubleStringInner)
AST_END(DoubleStringInner, "double_string_inner"sv)

AST_NODE(DoubleStringContent)
	ast_sel<true, DoubleStringInner_t, Exp_t> content;
	AST_MEMBER(DoubleStringContent, &content)
AST_END(DoubleStringContent, "double_string_content"sv)

AST_NODE(DoubleString)
	ast_ptr<true, Seperator_t> sep;
	ast_list<false, DoubleStringContent_t> segments;
	AST_MEMBER(DoubleString, &sep, &segments)
AST_END(DoubleString, "double_string"sv)

AST_NODE(String)
	ast_sel<true, DoubleString_t, SingleString_t> str;
	AST_MEMBER(String, &str)
AST_END(String, "string"sv)

AST_LEAF(Text)
AST_END(Text, "text"sv)

AST_LEAF(Title)
AST_END(Title, "title"sv)

AST_LEAF(CharName)
AST_END(CharName, "char_name"sv)

AST_NODE(Character)
	ast_ptr<true, CharName_t> name;
	AST_MEMBER(Character, &name)
AST_END(Character, "character"sv)

AST_LEAF(AttributeValue)
AST_END(AttributeValue, "attribute_value"sv)

AST_NODE(Attribute)
	ast_ptr<true, Name_t> name;
	ast_sel<true, Value_t, String_t, AttributeValue_t> value;
	AST_MEMBER(Attribute, &name, &value)
AST_END(Attribute, "attribute"sv)

AST_LEAF(MarkupClose)
AST_END(MarkupClose, "markup_close"sv)

AST_NODE(Markup)
	ast_ptr<false, MarkupClose_t> pre;
	ast_ptr<true, Name_t> name;
	ast_sel<false, Value_t, String_t, AttributeValue_t> value;
	ast_ptr<true, Seperator_t> sep;
	ast_list<false, Attribute_t> attrs;
	ast_ptr<false, MarkupClose_t> post;
	AST_MEMBER(Markup, &pre, &name, &value, &sep, &attrs, &post)
AST_END(Markup, "markup"sv)

AST_LEAF(NumHex)
AST_END(NumHex, "num_hex"sv)

AST_NODE(TagLine)
	ast_ptr<true, NumHex_t> numHex;
	AST_MEMBER(TagLine, &numHex)
AST_END(TagLine, "tag_line"sv)

AST_NODE(TagIf)
	ast_ptr<true, Exp_t> cond;
	AST_MEMBER(TagIf, &cond)
AST_END(TagIf, "tag_if"sv)

AST_NODE(Tag)
	ast_ptr<true, Name_t> name;
	AST_MEMBER(Tag, &name)
AST_END(Tag, "tag"sv)

AST_NODE(Dialog)
	ast_ptr<false, Character_t> character;
	ast_ptr<true, Seperator_t> sep;
	ast_sel_list<true, Text_t, Markup_t, Exp_t> tokens;
	ast_ptr<true, Seperator_t> sep1;
	ast_sel_list<false, TagIf_t, TagLine_t, Tag_t> tags;
	AST_MEMBER(Dialog, &character, &sep, &tokens, &sep1, &tags)
AST_END(Dialog, "dialog"sv)

AST_NODE(Option)
	ast_ptr<true, Dialog_t> dialog;
	ast_ptr<false, Block_t> block;
	AST_MEMBER(Option, &dialog, &block)
AST_END(Option, "option"sv)

AST_NODE(OptionGroup)
	ast_ptr<true, Seperator_t> sep;
	ast_list<true, Option_t> options;
	AST_MEMBER(OptionGroup, &sep, &options)
AST_END(OptionGroup, "option_group"sv)

AST_NODE(Call)
	ast_ptr<true, Name_t> name;
	ast_ptr<true, Seperator_t> sep;
	ast_list<false, Exp_t> args;
	AST_MEMBER(Call, &name, &sep, &args)
AST_END(Call, "call"sv)

AST_NODE(Variable)
	ast_ptr<true, Name_t> name;
	AST_MEMBER(Variable, &name)
AST_END(Variable, "variable"sv)

AST_LEAF(UnaryOperator)
AST_END(UnaryOperator, "unary_operator"sv)

AST_LEAF(BinaryOperator)
AST_END(BinaryOperator, "binary_operator"sv)

AST_NODE(Func)
	ast_ptr<true, Name_t> name;
	ast_ptr<true, Seperator_t> sep;
	ast_list<false, Value_t> args;
	AST_MEMBER(Func, &name, &sep, &args)
AST_END(Func, "func"sv)

AST_NODE(Value)
	ast_sel<true, Boolean_t, Num_t, String_t, Func_t, Variable_t> value;
	AST_MEMBER(Value, &value)
AST_END(Value, "value"sv)

AST_NODE(UnaryExp)
	ast_list<false, UnaryOperator_t> ops;
	ast_list<true, Value_t> expos;
	AST_MEMBER(UnaryExp, &ops, &expos)
AST_END(UnaryExp, "unary_exp"sv)

AST_NODE(ExpOpValue)
	ast_ptr<true, BinaryOperator_t> op;
	ast_ptr<true, UnaryExp_t> expr;
	AST_MEMBER(ExpOpValue, &op, &expr)
AST_END(ExpOpValue, "exp_op_value"sv)

AST_NODE(Exp)
	ast_ptr<true, UnaryExp_t> expr;
	ast_list<false, ExpOpValue_t> opValues;
	AST_MEMBER(Exp, &expr, &opValues)
AST_END(Exp, "exp"sv)

AST_LEAF(AssignmentOp)
AST_END(AssignmentOp, "assignment_op"sv)

AST_LEAF(UpdateOp)
AST_END(UpdateOp, "update_op"sv)

AST_NODE(Assignment)
	ast_ptr<true, Variable_t> variable;
	ast_sel<true, AssignmentOp_t, UpdateOp_t> op;
	ast_ptr<true, Exp_t> value;
	AST_MEMBER(Assignment, &variable, &op, &value)
AST_END(Assignment, "assignment"sv)

AST_NODE(If)
	ast_ptr<true, Seperator_t> sep;
	ast_sel_list<true, Exp_t, Block_t> clauses;
	AST_MEMBER(If, &sep, &clauses)
AST_END(If, "if"sv)

AST_NODE(Goto)
	ast_ptr<true, Title_t> title;
	AST_MEMBER(Goto, &title)
AST_END(Goto, "goto"sv)

AST_NODE(Command)
	ast_sel<false, Assignment_t, If_t, Goto_t, Call_t> item;
	AST_MEMBER(Command, &item)
AST_END(Command, "command"sv)

AST_NODE(Block)
	ast_ptr<true, Seperator_t> sep;
	ast_sel_list<false, Dialog_t, OptionGroup_t, Command_t> statements;
	AST_MEMBER(Block, &sep, &statements)
AST_END(Block, "block"sv)

AST_NODE(File)
	ast_ptr<false, Block_t> block;
	AST_MEMBER(File, &block)
AST_END(File, "file"sv)

// clang-format on

} // namespace parserlib

namespace yarnflow {
using namespace std::string_view_literals;
using namespace std::string_literals;
using namespace parserlib;
using namespace parserlib::yarnflow;

class CompileError : public std::logic_error {
public:
	explicit CompileError(std::string_view msg, const input_range* range)
		: std::logic_error(std::string(msg))
		, line(range->m_begin.m_line)
		, col(range->m_begin.m_col) { }

	int line;
	int col;
};

#define YUEE(msg, node) throw CompileError( \
	"[File] "s + __FILE__ \
		+ ",\n[Func] "s + __FUNCTION__ \
		+ ",\n[Line] "s + std::to_string(__LINE__) \
		+ ",\n[Error] "s + msg, \
	node)

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

static std::string toLuaString(const std::string& input) {
	std::string luaStr = "\"";
	for (char c : input) {
		switch (c) {
			case '\"': luaStr += "\\\""; break;
			case '\\': luaStr += "\\\\"; break;
			case '\n': luaStr += "\\n"; break;
			case '\r': luaStr += "\\r"; break;
			case '\t': luaStr += "\\t"; break;
			default:
				luaStr += c;
				break;
		}
	}
	luaStr += "\"";
	return luaStr;
}

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

	// clang-format off
	YarnParser() {
		plain_space = *set(" \t");
		line_break = nl(-expr('\r') >> '\n');
		any_char = line_break | any();
		stop = line_break | eof();
		comment = "//" >> *(not_(set("\r\n")) >> any_char) >> and_(stop);
		space_one = set(" \t");
		space = -(and_(set(" \t/")) >> *space_one >> -comment);
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
		Num =
			"0x" >> (
				+num_lit >> (
					'.' >> +num_lit >> -num_expo_hex |
					num_expo_hex |
					true_()
				) | (
					'.' >> +num_lit >> -num_expo_hex
				)
			) |
			+num_char >> (
				'.' >> +num_char >> -num_expo |
				num_expo |
				true_()
			) |
			'.' >> +num_char >> -num_expo;

		cut = false_();
		Seperator = true_();

		empty_block_error = pl::user(true_(), [](const item_t& item) {
			throw ParserError("must be followed by a statement or an indented block"sv, item.begin);
			return false;
		});

		indentation_error = pl::user(not_(eof()), [](const item_t& item) {
			throw ParserError("unexpected indent"sv, item.begin);
			return false;
		});

		#define ensure(patt, finally) ((patt) >> (finally) | (finally) >> cut)
		#define key(str) (expr(str) >> not_alpha_num)

		check_indent = pl::user(plain_space, [](const item_t& item) {
			int indent = 0;
			for (input_it i = item.begin->m_it; i != item.end->m_it; ++i) {
				switch (*i) {
					case ' ': indent++; break;
					case '\t': indent += 4; break;
				}
			}
			State* st = reinterpret_cast<State*>(item.user_data);
			return st->indents.top() == indent;
		});
		check_indent_match = and_(check_indent);

		advance = pl::user(plain_space, [](const item_t& item) {
			int indent = 0;
			for (input_it i = item.begin->m_it; i != item.end->m_it; ++i) {
				switch (*i) {
					case ' ': indent++; break;
					case '\t': indent += 4; break;
				}
			}
			State* st = reinterpret_cast<State*>(item.user_data);
			int top = st->indents.top();
			if (top != -1 && indent > top) {
				st->indents.push(indent);
				return true;
			}
			return false;
		});
		advance_match = and_(advance);

		pop_indent = pl::user(true_(), [](const item_t& item) {
			State* st = reinterpret_cast<State*>(item.user_data);
			st->indents.pop();
			return true;
		});

		push_indent = pl::user(plain_space, [](const item_t& item) {
			int indent = 0;
			for (input_it i = item.begin->m_it; i != item.end->m_it; ++i) {
				switch (*i) {
					case ' ': indent++; break;
					case '\t': indent += 4; break;
				}
			}
			State* st = reinterpret_cast<State*>(item.user_data);
			st->indents.push(indent);
			return true;
		});

		Variable = '$' >> Name;

		Func = Name >> '(' >> Seperator >> space >> -(Value >> *(space >> ',' >> space >> Value)) >> space >> ')';

		Value = Variable | Boolean | Num | String | Func;

		single_string_inner = '\\' >> set("'\\") | not_('\'') >> any_char;
		SingleString = '\'' >> *single_string_inner >> '\'';

		double_string_plain = '\\' >> set("\"\\") | not_('"') >> any_char;
		DoubleStringInner = +double_string_plain;
		DoubleStringContent = DoubleStringInner;
		DoubleString = '"' >> Seperator >> *DoubleStringContent >> '"';
		String = DoubleString | SingleString;

		exponential_operator = '^';
		expo_value = exponential_operator >> *space_break >> space >> Value;
		expo_exp = Value >> *(space >> expo_value);

		UnaryOperator =
			'-' >> not_(set(">=") | space_one) |
			'#' | '!' |
			'~' >> not_('=' | space_one) |
			key("not");

		UnaryExp = *(UnaryOperator >> space) >> expo_exp;

		BinaryOperator =
			key("or") |
			key("and") |
			"<=" | ">=" | "~=" | "!=" | "==" |
			".." | "&&" | "||" | "//" |
			set("+-*/%><|&~");

		ExpOpValue = BinaryOperator >> *space_break >> space >> UnaryExp;

		Exp = UnaryExp >> *(space >> ExpOpValue);

		Boolean = (expr("true") | "false") >> not_alpha_num;

		AttributeValue = +(not_(line_break | space_one | ']' | "/]") >> any_char);

		Attribute = Name >> '=' >> (String | AttributeValue);

		MarkupClose = true_();

		Markup = '[' >> -('/' >> MarkupClose) >> Name >> -('=' >> (String | AttributeValue)) >> Seperator >> *(space >> Attribute) >> space >> (']' | "/]" >> MarkupClose >> -space_one);

		Text = '\\' >> set("[#{<") | +(not_(line_break | Markup | '#' | "<<" | '{') >> any_char);

		NumHex = +num_char_hex;

		TagLine = "#line:" >> space >> NumHex;

		TagIf = "<<" >> space >> "if" >> not_alpha_num >> space >> Exp >> space >> ">>";

		Tag = '#' >> Name;

		CharName = +(not_(':' | space_one | line_break) >> any_char);

		Character = CharName >> ':' >> space_one >> space;

		interp = '{' >> space >> Exp >> space >> '}';

		Dialog = -Character >> Seperator >> +(Text | Markup | interp) >> Seperator >> *(space >> (TagIf | TagLine | Tag));

		Option = "->" >> space >> Dialog >> -in_block;

		OptionGroup = Seperator >> Option >> *(line_break >> *(empty_line_break >> line_break) >> check_indent >> Option);

		AssignmentOp = '=' | key("to");
		UpdateOp = set("+-*/%&|^");

		Assignment =
			key("set") >> space >> Variable >> space >> (AssignmentOp | UpdateOp >> '=') >> space >> Exp;

		Title = (range('a', 'z') | range('A', 'Z') | '_') >> *alpha_num;

		Goto = key("jump") >> space >> Title;

		Call = not_((expr("endif") | "if" | "else" | "elseif" | "jump" | "set") >> not_alpha_num) >> Name >> space >> Seperator >> -(Exp >> *(space >> ',' >> space >> Exp));

		Command = "<<" >> space >> (
			If |
			Goto |
			Assignment |
			Call) >> space >> ">>";

		empty_line_break = (
			check_indent >> comment |
			advance >> ensure(comment, pop_indent) |
			plain_space
		) >> and_(line_break);

		if_else_if = line_break >> *(empty_line_break >> line_break) >> check_indent >> "<<" >> space >> key("elseif") >> space >> Exp >> space >> ">>" >> space_break >> *(*set(" \t") >> line_break) >> ensure(and_(push_indent) >> Block, pop_indent);
		if_else = line_break >> *(empty_line_break >> line_break) >> check_indent >> "<<" >> space >> key("else") >> space >> ">>" >> space_break >> *(*set(" \t") >> line_break) >> ensure(and_(push_indent) >> Block, pop_indent);
		If = key("if") >> space >> Seperator >> Exp >> space >> ">>" >> space_break >> *(*set(" \t") >> line_break) >> ensure(and_(push_indent) >> Block, pop_indent) >> *if_else_if >> -if_else >> line_break >> *(empty_line_break >> line_break) >> check_indent >> "<<" >> space >> key("endif");

		line = (
			empty_line_break |
			check_indent >> (Command | OptionGroup | Dialog) |
			advance_match >> ensure(space >> (OptionGroup | indentation_error), pop_indent)
		);

		in_block = space_break >> *(*set(" \t") >> line_break) >> advance_match >> ensure(Block, pop_indent);

		Block = Seperator >> line >> *(+line_break >> line);

		File = -Block >> white >> stop;
	}
	// clang-format on

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
			res.node.set(::yarnflow::parse(*(res.codes), r, errors, &state));
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
	NONE_AST_RULE(indentation_error);

	NONE_AST_RULE(check_indent);
	NONE_AST_RULE(check_indent_match);
	NONE_AST_RULE(advance);
	NONE_AST_RULE(advance_match);
	NONE_AST_RULE(push_indent);
	NONE_AST_RULE(pop_indent);
	NONE_AST_RULE(empty_line_break);
	NONE_AST_RULE(line);
	NONE_AST_RULE(exponential_operator);
	NONE_AST_RULE(expo_value);
	NONE_AST_RULE(expo_exp);
	NONE_AST_RULE(in_block);
	NONE_AST_RULE(if_else_if);
	NONE_AST_RULE(if_else);
	NONE_AST_RULE(single_string_inner);
	NONE_AST_RULE(interp);
	NONE_AST_RULE(double_string_plain);

	AST_RULE(Name);
	AST_RULE(Num);
	AST_RULE(Boolean);
	AST_RULE(Seperator);
	AST_RULE(Option);
	AST_RULE(OptionGroup);
	AST_RULE(MarkupClose);
	AST_RULE(Attribute);
	AST_RULE(AttributeValue);
	AST_RULE(Markup);
	AST_RULE(Text);
	AST_RULE(NumHex);
	AST_RULE(TagLine);
	AST_RULE(TagIf);
	AST_RULE(Tag);
	AST_RULE(CharName);
	AST_RULE(Character);
	AST_RULE(Dialog);
	AST_RULE(Command);
	AST_RULE(Block);
	AST_RULE(File);
	AST_RULE(Variable);
	AST_RULE(Func);
	AST_RULE(Value);
	AST_RULE(UnaryExp);
	AST_RULE(UnaryOperator);
	AST_RULE(BinaryOperator);
	AST_RULE(ExpOpValue);
	AST_RULE(Exp);
	AST_RULE(Title);
	AST_RULE(Goto);
	AST_RULE(Call);
	AST_RULE(Assignment);
	AST_RULE(If);
	AST_RULE(SingleString);
	AST_RULE(DoubleStringInner);
	AST_RULE(DoubleStringContent);
	AST_RULE(DoubleString);
	AST_RULE(String);
	AST_RULE(AssignmentOp);
	AST_RULE(UpdateOp);
};

using str_list = std::list<std::string>;

class YarnCompiler {

private:
	YarnParser _parser;
	int _indentOffset = 0;
	std::ostringstream _buf;
	std::ostringstream _joinBuf;
	const std::string _newLine = "\n";

	struct Scope { };
	std::list<Scope> _scopes;

public:
	YarnCompiler()
		: _parser() { }

	CompileInfo compile(std::string_view codes) {
		auto res = _parser.parse<File_t>(codes);
		if (!res.error) {
			pushScope();
			str_list temp;
			temp.push_back(indent() + "return function(title, state, command, yarn, gotoStory)"s + nl(res.node));
			pushScope();
			try {
				auto file = res.node.to<File_t>();
				if (file->block) {
					transformBlock(file->block, temp);
				}
			} catch (const CompileError& err) {
				return {
					std::string(),
					CompileInfo::Error{
						err.what(),
						err.line,
						err.col,
						res.errorMessage(err.what(), err.line, err.col)}};
			}
			temp.push_back(indent() + "return nil"s + nl(res.node));
			popScope();
			temp.push_back(indent() + "end"s + nl(res.node));
			popScope();
			return {
				join(temp)};
		}
		const auto& err = res.error.value();
		return {
			std::string(),
			CompileInfo::Error{
				err.msg,
				err.line,
				err.col,
				res.errorMessage(err.msg, err.line, err.col)}};
	}

	void incIndentOffset() {
		_indentOffset++;
	}

	void decIndentOffset() {
		_indentOffset--;
	}

	void pushScope() {
		_scopes.emplace_back();
	}

	void popScope() {
		_scopes.pop_back();
	}

	const std::string nl(ast_node* node) const {
		return " -- "s + std::to_string(node->m_begin.m_line) + _newLine;
	}

	std::string indent() const {
		return std::string(_scopes.size() + _indentOffset - 1, '\t');
	}

	std::string clearBuf() {
		std::string str = _buf.str();
		_buf.str("");
		_buf.clear();
		return str;
	}

	std::string join(const str_list& items) {
		if (items.empty())
			return std::string();
		else if (items.size() == 1)
			return items.front();
		for (const auto& item : items) {
			_joinBuf << item;
		}
		auto result = _joinBuf.str();
		_joinBuf.str("");
		_joinBuf.clear();
		return result;
	}

	std::string join(const str_list& items, std::string_view sep) {
		if (items.empty())
			return std::string();
		else if (items.size() == 1)
			return items.front();
		std::string sepStr = std::string(sep);
		auto begin = ++items.begin();
		_joinBuf << items.front();
		for (auto it = begin; it != items.end(); ++it) {
			_joinBuf << sepStr << *it;
		}
		auto result = _joinBuf.str();
		_joinBuf.str("");
		_joinBuf.clear();
		return result;
	}

	void transformBlock(Block_t* block, str_list& out) {
		if (block->statements.empty()) {
			out.push_back({});
			return;
		}
		str_list temp;
		const auto& stmts = block->statements.objects();
		for (auto it = stmts.begin(); it != stmts.end(); ++it) {
			auto stmt = *it;
			switch (stmt->get_id()) {
				case id<Dialog_t>(): {
					auto next = it;
					++next;
					transformDialog(static_cast<Dialog_t*>(stmt), temp, next != stmts.end() && (*next)->get_id() == id<OptionGroup_t>());
					temp.back() = indent() + "coroutine.yield(\"Dialog\", "s + temp.back() + ')' + nl(stmt);
					break;
				}
				case id<OptionGroup_t>(): {
					transformOptionGroup(static_cast<OptionGroup_t*>(stmt), temp);
					temp.back() = indent() + "coroutine.yield(\"Option\", "s + temp.back() + ')' + nl(stmt);
					break;
				}
				case id<Command_t>(): {
					transformCommand(static_cast<Command_t*>(stmt), temp);
					break;
				}
				default: YUEE("AST node mismatch", stmt); break;
			}
		}
		out.push_back(join(temp));
	}

	struct AttributeItem {
		std::string name;
		std::string value;
	};

	struct MarkupItem {
		std::string name;
		std::list<AttributeItem> attrs;
		std::string begin;
		std::string end;
	};

	void transformAttributeValue(ast_node* value, str_list& out) {
		switch (value->get_id()) {
			case id<Value_t>():
				transformValue(static_cast<Value_t*>(value), out);
				break;
			case id<String_t>():
				transformString(static_cast<String_t*>(value), out);
				break;
			case id<AttributeValue_t>():
				out.push_back(toLuaString(_parser.toString(value)));
				break;
			default: YUEE("AST node mismatch", value); break;
		}
	}

	void transformDialog(Dialog_t* dialog, str_list& out, bool optionsFollowed) {
		auto x = dialog;
		str_list texts;
		std::list<MarkupItem> markups;
		std::string length("0"sv);
		if (dialog->character) {
			auto& markup = markups.emplace_back();
			markup.name = "Character"s;
			auto& attr = markup.attrs.emplace_back();
			attr.name = "name"s;
			attr.value = toLuaString(_parser.toString(dialog->character->name));
		}
		std::list<TagIf_t*> ifTags;
		for (auto tag : dialog->tags.objects()) {
			if (auto ifTag = ast_cast<TagIf_t>(tag)) {
				ifTags.push_back(ifTag);
			}
		}
		if (!ifTags.empty()) {
			incIndentOffset();
			for (size_t i = 0; i < ifTags.size(); i++) {
				incIndentOffset();
			}
		}
		for (auto token : dialog->tokens.objects()) {
			switch (token->get_id()) {
				case id<Text_t>(): {
					auto text = static_cast<Text_t*>(token);
					length += " + "s + std::to_string(static_cast<int>(std::distance(token->m_begin.m_it, token->m_end.m_it)));
					auto textStr = _parser.toString(text);
					Utils::replace(textStr, "\""sv, "\\\""sv);
					texts.push_back(textStr);
					break;
				}
				case id<Exp_t>(): {
					auto exp = static_cast<Exp_t*>(token);
					str_list temp;
					transformExp(exp, temp);
					length += " + "s + "utf8.len(tostring("s + temp.back() + "))"s;
					texts.push_back("\" .. tostring("s + temp.back() + ") .. \""s);
					break;
				}
				case id<Markup_t>(): {
					auto markup = static_cast<Markup_t*>(token);
					if (markup->pre) {
						auto name = _parser.toString(markup->name);
						bool found = false;
						for (auto it = markups.rbegin(); it != markups.rend(); ++it) {
							if (it->name == name && it->end.empty()) {
								it->end = length + " - 1"s;
								found = true;
								break;
							}
						}
						if (!found) throw CompileError("no matching markup to close"sv, markup->name);
					} else {
						auto& item = markups.emplace_back();
						item.name = _parser.toString(markup->name);
						item.begin = length;
						if (markup->value) {
							str_list temp;
							transformAttributeValue(markup->value, temp);
							auto& attr = item.attrs.emplace_back();
							attr.name = item.name;
							attr.value = temp.back();
						}
						for (auto node : markup->attrs.objects()) {
							auto attrNode = static_cast<Attribute_t*>(node);
							auto& attr = item.attrs.emplace_back();
							attr.name = _parser.toString(attrNode->name);
							str_list temp;
							transformAttributeValue(attrNode->value, temp);
							attr.value = temp.back();
						}
					}
					break;
				}
				default: YUEE("AST node mismatch", token); break;
			}
		}
		for (auto& markup : markups) {
			if (!markup.begin.empty() && markup.end.empty()) {
				markup.end = length + " - 1"s;
			}
		}
		_buf << '{' << nl(x);
		incIndentOffset();
		_buf << indent() << "text = \""sv << join(texts) << "\","sv << nl(x);
		_buf << indent() << "title = title,"sv << nl(x);
		if (!markups.empty()) {
			_buf << indent() << "marks = {"sv << nl(x);
			incIndentOffset();
			for (const auto& markup : markups) {
				_buf << indent() << '{' << nl(x);
				incIndentOffset();
				_buf << indent() << "name = \""sv << markup.name << "\","sv << nl(x);
				if (!markup.begin.empty()) {
					_buf << indent() << "start = "sv << markup.begin << " + 1,"sv << nl(x);
				}
				if (!markup.end.empty()) {
					_buf << indent() << "stop = "sv << markup.end << " + 1,"sv << nl(x);
				}
				if (!markup.attrs.empty()) {
					_buf << indent() << "attrs = {"sv << nl(x);
					incIndentOffset();
					for (const auto& attr : markup.attrs) {
						_buf << indent() << "[\""sv << attr.name << "\"] = "sv << attr.value << ',' << nl(x);
					}
					decIndentOffset();
					_buf << indent() << "},"sv << nl(x);
				}
				decIndentOffset();
				_buf << indent() << "},"sv << nl(x);
			}
			decIndentOffset();
			_buf << indent() << "},"sv << nl(x);
		}
		if (optionsFollowed) {
			_buf << indent() << "optionsFollowed = true,"sv << nl(x);
		}
		decIndentOffset();
		_buf << indent() << '}';
		if (ifTags.empty()) {
			out.push_back(clearBuf());
		} else {
			decIndentOffset();
			for (size_t i = 0; i < ifTags.size(); i++) {
				decIndentOffset();
			}
			auto dialogText = clearBuf();
			str_list temp;
			temp.push_back("(function()"s + nl(x));
			pushScope();
			for (auto tag : ifTags) {
				transformExp(tag->cond, temp);
				temp.back() = indent() + "if "s + temp.back() + " then"s + nl(x);
				pushScope();
			}
			temp.push_back(indent() + "return "s + dialogText + nl(x));
			for (size_t i = 0; i < ifTags.size(); i++) {
				popScope();
				temp.push_back(indent() + "end"s + nl(x));
			}
			temp.push_back(indent() + "return false"s + nl(x));
			popScope();
			temp.push_back(indent() + "end)()"s);
			out.push_back(join(temp));
		}
	}

	void transformOptionGroup(OptionGroup_t* group, str_list& out) {
		auto x = group;
		str_list options;
		str_list branches;
		options.push_back('{' + nl(x));
		branches.push_back(indent() + '{' + nl(x));
		incIndentOffset();
		for (auto group : group->options.objects()) {
			auto option = static_cast<Option_t*>(group);
			transformDialog(option->dialog, options, false);
			options.back() = indent() + options.back() + ',' + nl(x);
			branches.push_back(indent() + "function()"s + nl(x));
			if (option->block) {
				pushScope();
				transformBlock(option->block, branches);
				branches.push_back(indent() + "return nil"s + nl(x));
				popScope();
			}
			branches.push_back(indent() + "end,"s + nl(x));
		}
		decIndentOffset();
		options.push_back(indent() + "},"s + nl(x));
		branches.push_back(indent() + '}');
		out.push_back(join(options) + join(branches));
	}

	void transformAssignment(Assignment_t* assignment, str_list& out) {
		str_list temp;
		temp.push_back("state[\""s + _parser.toString(assignment->variable->name) + "\"]"s);
		if (auto update = assignment->op.as<UpdateOp_t>()) {
			auto op = _parser.toString(update);
			temp.push_back(" = "s);
			temp.push_back(temp.front());
			temp.push_back(" "s + op + " "s);
			transformExp(assignment->value.get(), temp);
		} else {
			temp.push_back(" = "s);
			transformExp(assignment->value.get(), temp);
		}
		out.push_back(indent() + join(temp) + nl(assignment));
	}

	void transformGoto(Goto_t* gotoNode, str_list& out) {
		out.push_back(indent() + "gotoStory("s + toLuaString(_parser.toString(gotoNode->title)) + ")"s + nl(gotoNode) + indent() + "coroutine.yield(\"Goto\")"s + nl(gotoNode));
	}

	void transformCall(Call_t* call, str_list& out) {
		str_list temp;
		for (auto arg : call->args.objects()) {
			auto exp = static_cast<Exp_t*>(arg);
			transformExp(exp, temp);
		}
		out.push_back(indent() + "command[\""s + _parser.toString(call->name) + "\"]("s + join(temp, ", "sv) + ')' + nl(call));
	}

	void transformIf(If_t* ifNode, str_list& out) {
		auto x = ifNode;
		bool isInCond = false;
		bool firstCond = true;
		str_list temp;
		for (auto clause : ifNode->clauses.objects()) {
			if (auto exp = ast_cast<Exp_t>(clause)) {
				transformExp(exp, temp);
				if (firstCond) {
					temp.back() = indent() + "if "s + temp.back() + " then"s + nl(x);
					pushScope();
					firstCond = false;
				} else {
					popScope();
					temp.back() = indent() + "elseif "s + temp.back() + " then"s + nl(x);
					pushScope();
				}
				isInCond = true;
			} else {
				if (!isInCond) {
					popScope();
					temp.push_back(indent() + "else"s + nl(x));
					pushScope();
				}
				isInCond = false;
				auto block = ast_to<Block_t>(clause);
				transformBlock(block, temp);
			}
		}
		popScope();
		temp.push_back(indent() + "end"s + nl(x));
		out.push_back(join(temp));
	}

	void transformCommand(Command_t* command, str_list& out) {
		switch (command->item->get_id()) {
			case id<Assignment_t>(): {
				auto assignment = static_cast<Assignment_t*>(command->item.get());
				transformAssignment(assignment, out);
				break;
			}
			case id<If_t>(): {
				auto ifNode = static_cast<If_t*>(command->item.get());
				transformIf(ifNode, out);
				break;
			}
			case id<Goto_t>(): {
				auto gotoNode = static_cast<Goto_t*>(command->item.get());
				transformGoto(gotoNode, out);
				break;
			}
			case id<Call_t>(): {
				auto call = static_cast<Call_t*>(command->item.get());
				transformCall(call, out);
				break;
			}
			default: YUEE("AST node mismatch", command->item); break;
		}
	}

	void transformUnaryExp(UnaryExp_t* unaryExp, str_list& out) {
		if (unaryExp->ops.empty() && unaryExp->expos.size() == 1) {
			transformValue(static_cast<Value_t*>(unaryExp->expos.back()), out);
			return;
		}
		std::string unaryOp;
		for (auto op_ : unaryExp->ops.objects()) {
			std::string op = _parser.toString(op_);
			if (op == "!"sv) op = "not"s;
			unaryOp.append(op == "not"sv ? op + ' ' : op);
		}
		str_list temp;
		for (auto value_ : unaryExp->expos.objects()) {
			auto value = static_cast<Value_t*>(value_);
			transformValue(value, temp);
		}
		out.push_back(unaryOp + join(temp, " ^ "sv));
	}

	void transformExp(Exp_t* exp, str_list& out) {
		str_list temp;
		transformUnaryExp(exp->expr, temp);
		for (auto _opValue : exp->opValues.objects()) {
			auto opValue = static_cast<ExpOpValue_t*>(_opValue);
			auto opStr = _parser.toString(opValue->op);
			if (opStr == "!="sv) {
				opStr = "~="s;
			} else if (opStr == "&&"sv) {
				opStr = "and"s;
			} else if (opStr == "||"sv) {
				opStr = "or"s;
			}
			if (opStr == "+"sv && !temp.empty() && temp.back()[0] == '"') {
				opStr = ".."s;
			}
			auto& lastOP = temp.emplace_back(opStr);
			transformUnaryExp(opValue->expr, temp);
			if (lastOP == "+"sv && temp.back()[0] == '"') {
				lastOP = ".."s;
			}
		}
		out.push_back(join(temp, " "sv));
	}

	void transformFunc(Func_t* func, str_list& out) {
		auto funcName = _parser.toString(func->name);
		str_list temp;
		for (auto arg : func->args.objects()) {
			transformValue(static_cast<Value_t*>(arg), temp);
		}
		out.push_back("(yarn[\""s + funcName + "\"] or command[\""s + funcName + "\"])("s + join(temp, ", "sv) + ")"s);
	}

	void transformValue(Value_t* value, str_list& out) {
		switch (value->value->get_id()) {
			case id<Boolean_t>():
				out.push_back(_parser.toString(value->value));
				break;
			case id<Num_t>(): {
				auto num = _parser.toString(value->value);
				Utils::replace(num, "_"sv, ""sv);
				out.push_back(num);
				break;
			}
			case id<String_t>():
				transformString(static_cast<String_t*>(value->value.get()), out);
				break;
			case id<Variable_t>():
				out.push_back("state[\""s + _parser.toString(value->value.as<Variable_t>()->name) + "\"]");
				break;
			case id<Func_t>():
				transformFunc(static_cast<Func_t*>(value->value.get()), out);
				break;
			default: YUEE("AST node mismatch", value); break;
		}
	}

	void transformSingleString(SingleString_t* singleString, str_list& out) {
		throw CompileError("single quote string is not supported"sv, singleString);
		/*
		auto str = _parser.toString(singleString);
		Utils::replace(str, "\r\n"sv, "\n");
		Utils::replace(str, "\n"sv, "\\n"sv);
		out.push_back(str);
		*/
	}

	void transformDoubleString(DoubleString_t* doubleString, str_list& out) {
		str_list temp;
		for (auto seg_ : doubleString->segments.objects()) {
			auto seg = static_cast<DoubleStringContent_t*>(seg_);
			auto content = seg->content.get();
			switch (content->get_id()) {
				case id<DoubleStringInner_t>(): {
					auto str = _parser.toString(content);
					Utils::replace(str, "\r\n"sv, "\n");
					Utils::replace(str, "\n"sv, "\\n"sv);
					temp.push_back('\"' + str + '\"');
					break;
				}
				case id<Exp_t>(): {
					transformExp(static_cast<Exp_t*>(content), temp);
					temp.back() = "tostring("s + temp.back() + ')';
					break;
				}
				default: YUEE("AST node mismatch", content); break;
			}
		}
		out.push_back(temp.empty() ? "\"\""s : join(temp, " .. "sv));
	}

	void transformString(String_t* string, str_list& out) {
		auto str = string->str.get();
		switch (str->get_id()) {
			case id<SingleString_t>(): transformSingleString(static_cast<SingleString_t*>(str), out); break;
			case id<DoubleString_t>(): transformDoubleString(static_cast<DoubleString_t*>(str), out); break;
			default: YUEE("AST node mismatch", str); break;
		}
	}
};

CompileInfo compile(std::string_view codes) {
	return YarnCompiler{}.compile(codes);
}

} // namespace yarnflow
