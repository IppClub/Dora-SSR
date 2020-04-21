/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/

#include <string>
#include <unordered_set>
#include <unordered_map>
#include <stack>
#include <vector>
#include <memory>
#include <cassert>

#include "MoonP/moon_parser.h"
#include "MoonP/moon_compiler.h"

extern "C" {

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

} // extern "C"

namespace MoonP {
using namespace std::string_view_literals;
using namespace parserlib;

#define BLOCK_START do {
#define BLOCK_END } while (false);
#define BREAK_IF(cond) if (cond) break

#define _DEFER(code,line) std::shared_ptr<void> _defer_##line(nullptr, [&](auto){code;})
#define DEFER(code) _DEFER(code,__LINE__)

typedef std::list<std::string> str_list;

inline std::string s(std::string_view sv) {
	return std::string(sv);
}

const std::string_view version() {
	return "0.3.9"sv;
}

// name of table stored in lua registry
#define MOONP_MODULE "__moon_modules__"

class MoonCompilerImpl {
public:
	MoonCompilerImpl(lua_State* sharedState,
		const std::function<void(void*)>& luaOpen,
		bool sameModule,
		std::string_view moduleName = {}):
		L(sharedState),
		_luaOpen(luaOpen),
		_moduleName(moduleName) {
		BLOCK_START
		BREAK_IF(!sameModule);
		BREAK_IF(!L);
		_sameModule = true;
		int top = lua_gettop(L);
		DEFER(lua_settop(L, top));
		lua_pushliteral(L, MOONP_MODULE); // MOONP_MODULE
		lua_rawget(L, LUA_REGISTRYINDEX); // reg[MOONP_MODULE], tb
		BREAK_IF(lua_istable(L, -1) == 0);
		int idx = static_cast<int>(lua_objlen(L, -1)); // idx = #tb, tb
		BREAK_IF(idx == 0);
		_useModule = true;
		BLOCK_END
	}

	~MoonCompilerImpl() {
		if (L && _stateOwner) {
			lua_close(L);
			L = nullptr;
		}
	}

	std::tuple<std::string,std::string,GlobalVars> compile(std::string_view codes, const MoonConfig& config) {
		_config = config;
		_info = _parser.parse<File_t>(codes);
		GlobalVars globals;
		DEFER(clear());
		if (_info.node) {
			try {
				str_list out;
				pushScope();
				_enableReturn.push(_info.moduleName.empty());
				transformBlock(_info.node.to<File_t>()->block, out,
					config.implicitReturnRoot ? ExpUsage::Return : ExpUsage::Common,
					nullptr, true);
				popScope();
				if (config.lintGlobalVariable) {
					globals = std::make_unique<std::list<GlobalVar>>();
					for (const auto& var : _globals) {
						int line,col;
						std::tie(line,col) = var.second;
						globals->push_back({var.first, line, col});
					}
				}
				return {std::move(out.back()), Empty, std::move(globals)};
			} catch (const std::logic_error& error) {
				return {Empty, error.what(), std::move(globals)};
			}
		} else {
			return {Empty, std::move(_info.error), std::move(globals)};
		}
	}

	void clear() {
		_indentOffset = 0;
		_scopes.clear();
		_codeCache.clear();
		_buf.str("");
		_buf.clear();
		_joinBuf.str("");
		_joinBuf.clear();
		_globals.clear();
		_info = {};
		_varArgs = {};
		_withVars = {};
		_continueVars = {};
		_enableReturn = {};
		if (_useModule) {
			_useModule = false;
			if (!_sameModule) {
				lua_pushliteral(L, MOONP_MODULE); // MOONP_MODULE
				lua_rawget(L, LUA_REGISTRYINDEX); // reg[MOONP_MODULE], tb
				int idx = static_cast<int>(lua_objlen(L, -1));
				lua_pushnil(L); // tb nil
				lua_rawseti(L, -2, idx); // tb[idx] = nil, tb
				lua_pop(L, 1); // empty
			}
		}
	}
private:
	bool _stateOwner = false;
	bool _useModule = false;
	bool _sameModule = false;
	lua_State* L = nullptr;
	MoonConfig _config;
	MoonParser _parser;
	ParseInfo _info;
	int _indentOffset = 0;
	std::stack<bool> _varArgs;
	std::stack<bool> _enableReturn;
	std::stack<std::string> _withVars;
	std::stack<std::string> _continueVars;
	std::list<std::unique_ptr<input>> _codeCache;
	std::unordered_map<std::string,std::pair<int,int>> _globals;
	std::ostringstream _buf;
	std::ostringstream _joinBuf;
	const std::string _newLine = "\n";
	std::function<void(void*)> _luaOpen;
	std::string _moduleName;

	enum class LocalMode {
		None = 0,
		Capital = 1,
		Any = 2
	};
	enum class GlobalMode {
		None = 0,
		Capital = 1,
		Any = 2
	};
	struct Scope {
		GlobalMode mode = GlobalMode::None;
		std::unique_ptr<std::unordered_set<std::string>> vars;
		std::unique_ptr<std::unordered_set<std::string>> allows;
		std::unique_ptr<std::unordered_set<std::string>> globals;
	};
	std::list<Scope> _scopes;
	static const std::string Empty;

	enum class MemType {
		Builtin,
		Common,
		Property
	};

	struct ClassMember {
		std::string item;
		MemType type;
		ast_node* node;
	};

	struct DestructItem {
		bool isVariable = false;
		std::string name;
		std::string structure;
	};

	struct Destructure {
		std::string value;
		std::list<DestructItem> items;
	};

	enum class ExpUsage {
		Return,
		Assignment,
		Common,
		Closure
	};

	void pushScope() {
		_scopes.emplace_back();
		_scopes.back().vars = std::make_unique<std::unordered_set<std::string>>();
	}

	void popScope() {
		_scopes.pop_back();
	}

	bool isDefined(const std::string& name) const {
		bool isDefined = false;
		int mode = int(std::isupper(name[0]) ? GlobalMode::Capital : GlobalMode::Any);
		const auto& current = _scopes.back();
		if (int(current.mode) >= mode) {
			if (current.globals) {
				if (current.globals->find(name) != current.globals->end()) {
					isDefined = true;
					current.vars->insert(name);
				}
			} else {
				isDefined = true;
				current.vars->insert(name);
			}
		}
		decltype(_scopes.back().allows.get()) allows = nullptr;
		for (auto it  = _scopes.rbegin(); it != _scopes.rend(); ++it) {
			if (it->allows) allows = it->allows.get();
		}
		bool checkShadowScopeOnly = false;
		if (allows) {
			checkShadowScopeOnly = allows->find(name) == allows->end();
		}
		for (auto it = _scopes.rbegin(); it != _scopes.rend(); ++it) {
			auto vars = it->vars.get();
			if (vars->find(name) != vars->end()) {
				isDefined = true;
				break;
			}
			if (checkShadowScopeOnly && it->allows) break;
		}
		return isDefined;
	}

	bool isSolidDefined(const std::string& name) const {
		bool isDefined = false;
		for (auto it = _scopes.rbegin(); it != _scopes.rend(); ++it) {
			auto vars = it->vars.get();
			if (vars->find(name) != vars->end()) {
				isDefined = true;
				break;
			}
		}
		return isDefined;
	}

	void markVarShadowed() {
		auto& scope = _scopes.back();
		scope.allows = std::make_unique<std::unordered_set<std::string>>();
	}

	void markVarGlobal(GlobalMode mode, bool specified) {
		auto& scope = _scopes.back();
		scope.mode = mode;
		if (specified && !scope.globals) {
			scope.globals = std::make_unique<std::unordered_set<std::string>>();
		}
	}

	void addGlobalVar(const std::string& name) {
		auto& scope = _scopes.back();
		scope.globals->insert(name);
	}

	void addToAllowList(const std::string& name) {
		auto& scope = _scopes.back();
		scope.allows->insert(name);
	}

	void forceAddToScope(const std::string& name) {
		auto& scope = _scopes.back();
		scope.vars->insert(name);
	}

	Scope& currentScope() {
		return _scopes.back();
	}

	bool addToScope(const std::string& name) {
		bool defined = isDefined(name);
		if (!defined) {
			auto& scope = currentScope();
			scope.vars->insert(name);
		}
		return !defined;
	}

	std::string getUnusedName(std::string_view name) const {
		int index = 0;
		std::string newName;
		do {
			newName = s(name) + std::to_string(index);
			index++;
		} while (isSolidDefined(newName));
		return newName;
	}

	const std::string nll(ast_node* node) const {
		if (_config.reserveLineNumber) {
			return s(" -- "sv) + std::to_string(node->m_begin.m_line + _config.lineOffset) + _newLine;
		} else {
			return _newLine;
		}
	}

	const std::string nlr(ast_node* node) const {
		if (_config.reserveLineNumber) {
			return s(" -- "sv) + std::to_string(node->m_end.m_line + _config.lineOffset) + _newLine;
		} else {
			return _newLine;
		}
	}

	void incIndentOffset() {
		_indentOffset++;
	}

	void decIndentOffset() {
		_indentOffset--;
	}

	std::string indent() const {
		if (_config.useSpaceOverTab) {
			return std::string((_scopes.size() - 1 + _indentOffset) * 2, ' ');
		} else {
			return std::string(_scopes.size() - 1 + _indentOffset, '\t');
		}
	}

	std::string indent(int offset) const {
		if (_config.useSpaceOverTab) {
			return std::string((_scopes.size() - 1 + _indentOffset + offset) * 2, ' ');
		} else {
			return std::string(_scopes.size() - 1 + _indentOffset + offset, '\t');
		}
	}

	std::string clearBuf() {
		std::string str = _buf.str();
		_buf.str("");
		_buf.clear();
		return str;
	}

	std::string join(const str_list& items) {
		if (items.empty()) return Empty;
		else if (items.size() == 1) return items.front();
		for (const auto& item : items) {
			_joinBuf << item;
		}
		auto result = _joinBuf.str();
		_joinBuf.str("");
		_joinBuf.clear();
		return result;
	}

	std::string join(const str_list& items, std::string_view sep) {
		if (items.empty()) return Empty;
		else if (items.size() == 1) return items.front();
		std::string sepStr = s(sep);
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

	Value_t* singleValueFrom(ast_node* item) const {
		Exp_t* exp = nullptr;
		switch (item->getId()) {
			case id<Exp_t>():
				exp = static_cast<Exp_t*>(item);
				break;
			case id<ExpList_t>(): {
				auto expList = static_cast<ExpList_t*>(item);
				if (expList->exprs.size() == 1) {
					exp = static_cast<Exp_t*>(expList->exprs.front());
				}
				break;
			}
			case id<ExpListLow_t>(): {
				auto expList = static_cast<ExpListLow_t*>(item);
				if (expList->exprs.size() == 1) {
					exp = static_cast<Exp_t*>(expList->exprs.front());
				}
				break;
			}
		}
		if (!exp) return nullptr;
		if (exp->opValues.empty()) {
			return exp->value.get();
		}
		return nullptr;
	}

	SimpleValue_t* simpleSingleValueFrom(ast_node* expList) const {
		auto value = singleValueFrom(expList);
		if (value && value->item.is<SimpleValue_t>()) {
			return static_cast<SimpleValue_t*>(value->item.get());
		}
		return nullptr;
	}

	Value_t* firstValueFrom(ast_node* item) const {
		Exp_t* exp = nullptr;
		if (auto expList = ast_cast<ExpList_t>(item)) {
			if (!expList->exprs.empty()) {
				exp = static_cast<Exp_t*>(expList->exprs.front());
			}
		} else {
			exp = ast_cast<Exp_t>(item);
		}
		return exp->value.get();
	}

	Statement_t* lastStatementFrom(Body_t* body) const {
		if (auto stmt = body->content.as<Statement_t>()) {
			return stmt;
		} else {
			const auto& stmts = body->content.to<Block_t>()->statements.objects();
			return stmts.empty() ? nullptr : static_cast<Statement_t*>(stmts.back());
		}
	}

	Statement_t* lastStatementFrom(Block_t* block) const {
		const auto& stmts = block->statements.objects();
		return stmts.empty() ? nullptr : static_cast<Statement_t*>(stmts.back());
	}

	template <class T>
	ast_ptr<false, T> toAst(std::string_view codes, ast_node* parent) {
		auto res = _parser.parse<T>(s(codes));
		int line = parent->m_begin.m_line;
		int col = parent->m_begin.m_line;
		res.node->traverse([&](ast_node* node) {
			node->m_begin.m_line = line;
			node->m_end.m_line = line;
			node->m_begin.m_col = col;
			node->m_end.m_col = col;
			return traversal::Continue;
		});
		_codeCache.push_back(std::move(res.codes));
		return ast_ptr<false, T>(res.node.template to<T>());
	}

	bool isChainValueCall(ChainValue_t* chainValue) const {
		return ast_is<InvokeArgs_t, Invoke_t>(chainValue->items.back());
	}

	enum class ChainType {
		Common,
		EndWithColon,
		EndWithEOP,
		HasEOP,
		HasKeyword,
		Macro
	};

	ChainType specialChainValue(ChainValue_t* chainValue) const {
		if (isMacroChain(chainValue)) {
			return ChainType::Macro;
		}
		if (ast_is<ColonChainItem_t>(chainValue->items.back())) {
			return ChainType::EndWithColon;
		}
		if (ast_is<existential_op_t>(chainValue->items.back())) {
			return ChainType::EndWithEOP;
		}
		ChainType type = ChainType::Common;
		for (auto item : chainValue->items.objects()) {
			if (auto colonChain = ast_cast<ColonChainItem_t>(item)) {
				if (ast_is<LuaKeyword_t>(colonChain->name)) {
					type = ChainType::HasKeyword;
				}
			} else if (ast_is<existential_op_t>(item)) {
				return ChainType::HasEOP;
			}
		}
		return type;
	}

	std::string singleVariableFrom(ChainValue_t* chainValue) {
		BLOCK_START
		BREAK_IF(!chainValue);
		BREAK_IF(chainValue->items.size() != 1);
		auto callable = ast_cast<Callable_t>(chainValue->items.front());
		BREAK_IF(!callable);
		ast_node* var = callable->item.as<Variable_t>();
		if (!var) {
			if (auto self = callable->item.as<SelfName_t>()) {
				var = self->name.as<self_t>();
			}
		}
		BREAK_IF(!var);
		str_list tmp;
		transformCallable(callable, tmp);
		return tmp.back();
		BLOCK_END
		return Empty;
	}

	std::string singleVariableFrom(ast_node* expList) {
		if (!ast_is<Exp_t, ExpList_t>(expList)) return Empty;
		BLOCK_START
		auto value = singleValueFrom(expList);
		BREAK_IF(!value);
		auto chainValue = value->getByPath<ChainValue_t>();
		BREAK_IF(!chainValue);
		BREAK_IF(chainValue->items.size() != 1);
		auto callable = ast_cast<Callable_t>(chainValue->items.front());
		BREAK_IF(!callable || !(callable->item.is<Variable_t>() || callable->getByPath<SelfName_t,self_t>()));
		str_list tmp;
		transformCallable(callable, tmp);
		return tmp.back();
		BLOCK_END
		return Empty;
	}

	Variable_t* variableFrom(Exp_t* exp) {
		BLOCK_START
		auto value = singleValueFrom(exp);
		BREAK_IF(!value);
		auto chainValue = value->getByPath<ChainValue_t>();
		BREAK_IF(!chainValue);
		BREAK_IF(chainValue->items.size() != 1);
		auto callable = ast_cast<Callable_t>(chainValue->items.front());
		BREAK_IF(!callable);
		return callable->item.as<Variable_t>();
		BLOCK_END
		return nullptr;
	}

	bool isAssignable(const node_container& chainItems) const {
		if (chainItems.size() == 1) {
			 auto firstItem = chainItems.back();
			 if (auto callable = ast_cast<Callable_t>(firstItem)) {
				 switch (callable->item->getId()) {
					 case id<Variable_t>():
					 case id<SelfName_t>():
						 return true;
				 }
			 } else if (firstItem->getId() == id<DotChainItem_t>()) {
				 return true;
			 }
		 } else {
			auto lastItem = chainItems.back();
			switch (lastItem->getId()) {
				case id<DotChainItem_t>():
				case id<Exp_t>():
					return true;
			}
		}
		return false;
	}

	bool isAssignable(Exp_t* exp) const {
		if (auto value = singleValueFrom(exp)) {
			auto item = value->item.get();
			switch (item->getId()) {
				case id<simple_table_t>():
					return true;
				case id<SimpleValue_t>(): {
					auto simpleValue = static_cast<SimpleValue_t*>(item);
					if (simpleValue->value.is<TableLit_t>()) {
						return true;
					}
					return false;
				}
				case id<ChainValue_t>(): {
					auto chainValue = static_cast<ChainValue_t*>(item);
					return isAssignable(chainValue->items.objects());
				}
			}
		}
		return false;
	}

	bool isAssignable(Assignable_t* assignable) const {
		if (auto assignableChain = ast_cast<AssignableChain_t>(assignable->item)) {
			return isAssignable(assignableChain->items.objects());
		}
		return true;
	}

	void checkAssignable(ExpList_t* expList) const {
		for (auto exp_ : expList->exprs.objects()) {
			Exp_t* exp = static_cast<Exp_t*>(exp_);
			if (!isAssignable(exp)) {
				throw std::logic_error(_info.errorMessage("left hand expression is not assignable"sv, exp));
			}
		}
	}

	bool isPureBackcall(Exp_t* exp) const {
		if (exp->opValues.empty()) {
			return false;
		}
		bool backcall = true;
		for (auto _opValue : exp->opValues.objects()) {
			auto opValue = static_cast<exp_op_value_t*>(_opValue);
			if (!opValue->op.is<BackcallOperator_t>()) {
				backcall = false;
				break;
			}
		}
		return backcall;
	}

	bool isMacroChain(ChainValue_t* chainValue) const {
		const auto& chainList = chainValue->items.objects();
		BLOCK_START
		auto callable = ast_cast<Callable_t>(chainList.front());
		BREAK_IF(!callable);
		BREAK_IF(!callable->item.is<MacroName_t>());
		if (chainList.size() == 1 ||
			!ast_is<Invoke_t,InvokeArgs_t>(*(++chainList.begin()))) {
			throw std::logic_error(_info.errorMessage("macro expression must be followed by arguments list"sv, callable));
		}
		return true;
		BLOCK_END
		return false;
	}

	void transformStatement(Statement_t* statement, str_list& out) {
		auto x = statement;
		if (statement->appendix) {
			if (auto assignment = assignmentFrom(statement)) {
				auto preDefine = getPredefine(assignment);
				if (!preDefine.empty()) out.push_back(preDefine + nll(statement));
			}
			auto appendix = statement->appendix.get();
			switch (appendix->item->getId()) {
				case id<if_line_t>(): {
					auto if_line = appendix->item.to<if_line_t>();
					auto ifNode = x->new_ptr<If_t>();

					auto ifCond = x->new_ptr<IfCond_t>();
					ifCond->condition.set(if_line->condition);
					ifCond->assign.set(if_line->assign);
					ifNode->nodes.push_back(ifCond);

					auto stmt = x->new_ptr<Statement_t>();
					stmt->content.set(statement->content);
					auto body = x->new_ptr<Body_t>();
					body->content.set(stmt);
					ifNode->nodes.push_back(body);

					statement->appendix.set(nullptr);
					auto simpleValue = x->new_ptr<SimpleValue_t>();
					simpleValue->value.set(ifNode);
					auto value = x->new_ptr<Value_t>();
					value->item.set(simpleValue);
					auto exp = x->new_ptr<Exp_t>();
					exp->value.set(value);
					auto expList = x->new_ptr<ExpList_t>();
					expList->exprs.push_back(exp);
					auto expListAssign = x->new_ptr<ExpListAssign_t>();
					expListAssign->expList.set(expList);
					statement->content.set(expListAssign);
					break;
				}
				case id<unless_line_t>(): {
					auto unless_line = appendix->item.to<unless_line_t>();
					auto unless = x->new_ptr<Unless_t>();

					auto ifCond = x->new_ptr<IfCond_t>();
					ifCond->condition.set(unless_line->condition);
					unless->nodes.push_back(ifCond);

					auto stmt = x->new_ptr<Statement_t>();
					stmt->content.set(statement->content);
					auto body = x->new_ptr<Body_t>();
					body->content.set(stmt);
					unless->nodes.push_back(body);

					statement->appendix.set(nullptr);
					auto simpleValue = x->new_ptr<SimpleValue_t>();
					simpleValue->value.set(unless);
					auto value = x->new_ptr<Value_t>();
					value->item.set(simpleValue);
					auto exp = x->new_ptr<Exp_t>();
					exp->value.set(value);
					auto exprList = x->new_ptr<ExpList_t>();
					exprList->exprs.push_back(exp);
					auto expListAssign = x->new_ptr<ExpListAssign_t>();
					expListAssign->expList.set(exprList);
					statement->content.set(expListAssign);
					break;
				}
				case id<CompInner_t>(): {
					auto compInner = appendix->item.to<CompInner_t>();
					auto comp = x->new_ptr<Comprehension_t>();
					comp->forLoop.set(compInner);
					auto stmt = x->new_ptr<Statement_t>();
					stmt->content.set(statement->content);
					comp->value.set(stmt);
					auto simpleValue = x->new_ptr<SimpleValue_t>();
					simpleValue->value.set(comp);
					auto value = x->new_ptr<Value_t>();
					value->item.set(simpleValue);
					auto exp = x->new_ptr<Exp_t>();
					exp->value.set(value);
					auto expList = x->new_ptr<ExpList_t>();
					expList->exprs.push_back(exp);
					auto expListAssign = x->new_ptr<ExpListAssign_t>();
					expListAssign->expList.set(expList);
					statement->content.set(expListAssign);
					statement->appendix.set(nullptr);
					break;
				}
				default: assert(false); break;
			}
		}
		auto content = statement->content.get();
		if (!content) {
			out.push_back(Empty);
			return;
		}
		switch (content->getId()) {
			case id<Import_t>(): transformImport(static_cast<Import_t*>(content), out); break;
			case id<While_t>(): transformWhile(static_cast<While_t*>(content), out); break;
			case id<For_t>(): transformFor(static_cast<For_t*>(content), out); break;
			case id<ForEach_t>(): transformForEach(static_cast<ForEach_t*>(content), out); break;
			case id<Return_t>(): transformReturn(static_cast<Return_t*>(content), out); break;
			case id<Local_t>(): transformLocal(static_cast<Local_t*>(content), out); break;
			case id<Global_t>(): transformGlobal(static_cast<Global_t*>(content), out); break;
			case id<Export_t>(): transformExport(static_cast<Export_t*>(content), out); break;
			case id<Macro_t>(): transformMacro(static_cast<Macro_t*>(content), out, false); break;
			case id<BreakLoop_t>(): transformBreakLoop(static_cast<BreakLoop_t*>(content), out); break;
			case id<Label_t>(): transformLabel(static_cast<Label_t*>(content), out); break;
			case id<Goto_t>(): transformGoto(static_cast<Goto_t*>(content), out); break;
			case id<ExpListAssign_t>(): {
				auto expListAssign = static_cast<ExpListAssign_t*>(content);
				if (expListAssign->action) {
					transformAssignment(expListAssign, out);
				} else {
					auto expList = expListAssign->expList.get();
					if (expList->exprs.objects().empty()) {
						out.push_back(Empty);
						break;
					}
					if (auto singleValue = singleValueFrom(expList)) {
						if (auto simpleValue = singleValue->item.as<SimpleValue_t>()) {
							auto value = simpleValue->value.get();
							bool specialSingleValue = true;
							switch (value->getId()) {
								case id<If_t>(): transformIf(static_cast<If_t*>(value), out, ExpUsage::Common); break;
								case id<ClassDecl_t>(): transformClassDecl(static_cast<ClassDecl_t*>(value), out, ExpUsage::Common); break;
								case id<Unless_t>(): transformUnless(static_cast<Unless_t*>(value), out, ExpUsage::Common); break;
								case id<Switch_t>(): transformSwitch(static_cast<Switch_t*>(value), out, ExpUsage::Common); break;
								case id<With_t>(): transformWith(static_cast<With_t*>(value), out); break;
								case id<ForEach_t>(): transformForEach(static_cast<ForEach_t*>(value), out); break;
								case id<For_t>(): transformFor(static_cast<For_t*>(value), out); break;
								case id<While_t>(): transformWhile(static_cast<While_t*>(value), out); break;
								case id<Do_t>(): transformDo(static_cast<Do_t*>(value), out, ExpUsage::Common); break;
								case id<Comprehension_t>(): transformCompCommon(static_cast<Comprehension_t*>(value), out); break;
								default: specialSingleValue = false; break;
							}
							if (specialSingleValue) {
								break;
							}
						}
						if (auto chainValue = singleValue->item.as<ChainValue_t>()) {
							if (isChainValueCall(chainValue)) {
								transformChainValue(chainValue, out, ExpUsage::Common);
								break;
							}
						}
					} else if (expList->exprs.size() == 1){
						auto exp = static_cast<Exp_t*>(expList->exprs.back());
						if (isPureBackcall(exp)) {
							transformExp(exp, out, ExpUsage::Common);
							break;
						}
					}
					throw std::logic_error(_info.errorMessage("expression list is not supported here"sv, expList));
				}
				break;
			}
			default: assert(false); break;
		}
	}

	str_list getAssignVars(ExpListAssign_t* assignment) {
		str_list vars;
		if (!assignment->action.is<Assign_t>()) return vars;
		for (auto exp : assignment->expList->exprs.objects()) {
			auto var = singleVariableFrom(exp);
			vars.push_back(var.empty() ? Empty : var);
		}
		return vars;
	}

	str_list getAssignVars(With_t* with) {
		str_list vars;
		for (auto exp : with->valueList->exprs.objects()) {
			auto var = singleVariableFrom(exp);
			vars.push_back(var.empty() ? Empty : var);
		}
		return vars;
	}

	str_list getAssignDefs(ExpList_t* expList) {
		str_list preDefs;
		for (auto exp_ : expList->exprs.objects()) {
			auto exp = static_cast<Exp_t*>(exp_);
			if (auto value = singleValueFrom(exp)) {
				if (auto chain = value->item.as<ChainValue_t>()) {
					BLOCK_START
					BREAK_IF(chain->items.size() != 1);
					auto callable = ast_cast<Callable_t>(chain->items.front());
					BREAK_IF(!callable);
					std::string name;
					if (auto var = callable->item.as<Variable_t>()) {
						name = _parser.toString(var);
					} else if (auto self = callable->item.as<SelfName_t>()) {
						if (self->name.is<self_t>()) name = "self"sv;
					}
					BREAK_IF(name.empty());
					if (!isDefined(name)) {
						preDefs.push_back(name);
					}
					BLOCK_END
				}
			} else {
				throw std::logic_error(_info.errorMessage("left hand expression is not assignable"sv, exp));
			}
		}
		return preDefs;
	}

	str_list transformAssignDefs(ExpList_t* expList, bool markDefined = true) {
		str_list defs;
		for (auto exp_ : expList->exprs.objects()) {
			auto exp = static_cast<Exp_t*>(exp_);
			if (auto value = singleValueFrom(exp)) {
				if (auto chain = value->item.as<ChainValue_t>()) {
					BLOCK_START
					BREAK_IF(chain->items.size() != 1);
					auto callable = ast_cast<Callable_t>(chain->items.front());
					BREAK_IF(!callable);
					std::string name;
					if (auto var = callable->item.as<Variable_t>()) {
						name = _parser.toString(var);
					} else if (auto self = callable->item.as<SelfName_t>()) {
						if (self->name.is<self_t>()) name = "self"sv;
					}
					BREAK_IF(name.empty());
					if (!markDefined || addToScope(name)) {
						defs.push_back(name);
					}
					BLOCK_END
				}
			} else {
				throw std::logic_error(_info.errorMessage("left hand expression is not assignable"sv, exp));
			}
		}
		return defs;
	}

	std::string getPredefine(const str_list& defs) {
		if (defs.empty()) return Empty;
		return indent() + s("local "sv) + join(defs, ", "sv);
	}

	std::string getDestrucureDefine(ExpListAssign_t* assignment) {
		auto info = extractDestructureInfo(assignment, true);
		if (!info.first.empty()) {
			for (const auto& destruct : info.first) {
				str_list defs;
				for (const auto& item : destruct.items) {
					if (item.isVariable && addToScope(item.name)) {
						defs.push_back(item.name);
					}
				}
				if (!defs.empty()) _buf << indent() << "local "sv << join(defs,", "sv);
			}
		}
		return clearBuf();
	}

	std::string getPredefine(ExpListAssign_t* assignment) {
		auto preDefine = getDestrucureDefine(assignment);
		if (preDefine.empty()) {
			preDefine = getPredefine(transformAssignDefs(assignment->expList));
		}
		return preDefine;
	}

	ExpList_t* expListFrom(Statement_t* statement) {
		if (auto expListAssign = statement->content.as<ExpListAssign_t>()) {
			if (!expListAssign->action) {
				return expListAssign->expList.get();
			}
		}
		return nullptr;
	}

	ExpListAssign_t* assignmentFrom(Statement_t* statement) {
		if (auto expListAssign = statement->content.as<ExpListAssign_t>()) {
			if (expListAssign->action) {
				return expListAssign;
			}
		}
		return nullptr;
	}

	void transformAssignment(ExpListAssign_t* assignment, str_list& out) {
		checkAssignable(assignment->expList);
		BLOCK_START
		auto assign = ast_cast<Assign_t>(assignment->action);
		BREAK_IF(!assign || assign->values.objects().size() != 1);
		auto value = assign->values.objects().front();
		if (ast_is<Exp_t>(value)) {
			if (auto val = simpleSingleValueFrom(value)) {
				value = val->value.get();
			}
		}
		switch (value->getId()) {
			case id<If_t>():
			case id<Unless_t>(): {
				auto expList = assignment->expList.get();
				str_list temp;
				auto defs = transformAssignDefs(expList);
				if (!defs.empty()) temp.push_back(getPredefine(defs) + nll(expList));
				switch (value->getId()) {
					case id<If_t>(): transformIf(static_cast<If_t*>(value), temp, ExpUsage::Assignment, expList); break;
					case id<Unless_t>(): transformUnless(static_cast<Unless_t*>(value), temp, ExpUsage::Assignment, expList); break;
				}
				out.push_back(join(temp));
				return;
			}
			case id<Switch_t>(): {
				auto switchNode = static_cast<Switch_t*>(value);
				auto assignList = assignment->expList.get();
				std::string preDefine = getPredefine(assignment);
				transformSwitch(switchNode, out, ExpUsage::Assignment, assignList);
				out.back().insert(0, preDefine.empty() ? Empty : preDefine + nll(assignment));
				return;
			}
			case id<With_t>(): {
				auto withNode = static_cast<With_t*>(value);
				auto expList = assignment->expList.get();
				std::string preDefine = getPredefine(assignment);
				transformWith(withNode, out, expList);
				out.back().insert(0, preDefine.empty() ? Empty : preDefine + nll(assignment));
				return;
			}
			case id<Do_t>(): {
				auto expList = assignment->expList.get();
				auto doNode = static_cast<Do_t*>(value);
				std::string preDefine = getPredefine(assignment);
				transformDo(doNode, out, ExpUsage::Assignment, expList);
				out.back().insert(0, preDefine.empty() ? Empty : preDefine + nll(assignment));
				return;
			}
			case id<Comprehension_t>(): {
				auto expList = assignment->expList.get();
				std::string preDefine = getPredefine(assignment);
				transformComprehension(static_cast<Comprehension_t*>(value), out, ExpUsage::Assignment, expList);
				out.back().insert(0, preDefine.empty() ? Empty : preDefine + nll(assignment));
				return;
			}
			case id<TblComprehension_t>(): {
				auto expList = assignment->expList.get();
				std::string preDefine = getPredefine(assignment);
				transformTblComprehension(static_cast<TblComprehension_t*>(value), out, ExpUsage::Assignment, expList);
				out.back().insert(0, preDefine.empty() ? Empty : preDefine + nll(assignment));
				return;
			}
			case id<For_t>(): {
				auto expList = assignment->expList.get();
				std::string preDefine = getPredefine(assignment);
				transformForInPlace(static_cast<For_t*>(value), out, expList);
				out.back().insert(0, preDefine.empty() ? Empty : preDefine + nll(assignment));
				return;
			}
			case id<ForEach_t>(): {
				auto expList = assignment->expList.get();
				std::string preDefine = getPredefine(assignment);
				transformForEachInPlace(static_cast<ForEach_t*>(value), out, expList);
				out.back().insert(0, preDefine.empty() ? Empty : preDefine + nll(assignment));
				return;
			}
			case id<ClassDecl_t>(): {
				auto expList = assignment->expList.get();
				std::string preDefine = getPredefine(assignment);
				transformClassDecl(static_cast<ClassDecl_t*>(value), out, ExpUsage::Assignment, expList);
				out.back().insert(0, preDefine.empty() ? Empty : preDefine + nll(assignment));
				return;
			}
			case id<While_t>(): {
				auto expList = assignment->expList.get();
				std::string preDefine = getPredefine(assignment);
				transformWhileInPlace(static_cast<While_t*>(value), out, expList);
				out.back().insert(0, preDefine.empty() ? Empty : preDefine + nll(assignment));
				return;
			}
		}
		auto exp = ast_cast<Exp_t>(value);
		BREAK_IF(!exp);
		if (isPureBackcall(exp)) {
			auto expList = assignment->expList.get();
			transformExp(exp, out, ExpUsage::Assignment, expList);
			return;
		}
		BREAK_IF(!exp->opValues.empty());
		if (auto chainValue = exp->value->item.as<ChainValue_t>()) {
			auto type = specialChainValue(chainValue);
			auto expList = assignment->expList.get();
			switch (type) {
				case ChainType::HasEOP:
				case ChainType::EndWithColon: {
					std::string preDefine = getPredefine(assignment);
					transformChainValue(chainValue, out, ExpUsage::Assignment, expList);
					out.back().insert(0, preDefine.empty() ? Empty : preDefine + nll(assignment));
					return;
				}
				case ChainType::HasKeyword:
				case ChainType::Macro:
					transformChainValue(chainValue, out, ExpUsage::Assignment, expList);
					return;
				case ChainType::Common:
				case ChainType::EndWithEOP:
					break;
			}
		}
		BLOCK_END
		auto info = extractDestructureInfo(assignment);
		if (info.first.empty()) {
			transformAssignmentCommon(assignment, out);
		} else {
			str_list temp;
			for (const auto& destruct : info.first) {
				if (destruct.items.size() == 1) {
					auto& pair = destruct.items.front();
					_buf << indent();
					if (pair.isVariable && !isDefined(pair.name)) {
						_buf << s("local "sv);
					}
					_buf << pair.name << " = "sv << info.first.front().value << pair.structure << nll(assignment);
					addToScope(pair.name);
					temp.push_back(clearBuf());
				} else if (_parser.match<Name_t>(destruct.value)) {
					str_list defs, names, values;
					for (const auto& item : destruct.items) {
						if (item.isVariable && addToScope(item.name)) {
							defs.push_back(item.name);
						}
						names.push_back(item.name);
						values.push_back(item.structure);
					}
					for (auto& v : values) v.insert(0, destruct.value);
					if (defs.empty()) {
						_buf << indent() << join(names, ", "sv) << " = "sv << join(values, ", "sv) << nll(assignment);
					} else {
						_buf << indent() << "local "sv;
						if (defs.size() != names.size()) {
							_buf << join(defs,", "sv) << nll(assignment) << indent();
						}
						_buf << join(names, ", "sv) << " = "sv << join(values, ", "sv) << nll(assignment);
					}
					temp.push_back(clearBuf());
				} else {
					str_list defs, names, values;
					for (const auto& item : destruct.items) {
						if (item.isVariable && addToScope(item.name)) {
							defs.push_back(item.name);
						}
						names.push_back(item.name);
						values.push_back(item.structure);
					}
					if (!defs.empty()) _buf << indent() << "local "sv << join(defs,", "sv) << nll(assignment);
					_buf << indent() << "do"sv << nll(assignment);
					pushScope();
					auto objVar = getUnusedName("_obj_");
					for (auto& v : values) v.insert(0, objVar);
					_buf << indent() << "local "sv << objVar << " = "sv << destruct.value << nll(assignment);
					_buf << indent() << join(names, ", "sv) << " = "sv << join(values, ", "sv) << nll(assignment);
					popScope();
					_buf << indent() << "end"sv << nll(assignment);
					temp.push_back(clearBuf());
				}
			}
			if (info.second) {
				transformAssignmentCommon(info.second, temp);
			}
			out.push_back(join(temp));
		}
	}

	void transformAssignItem(ast_node* value, str_list& out) {
		switch (value->getId()) {
			case id<With_t>(): transformWithClosure(static_cast<With_t*>(value), out); break;
			case id<If_t>(): transformIf(static_cast<If_t*>(value), out, ExpUsage::Closure); break;
			case id<Switch_t>(): transformSwitch(static_cast<Switch_t*>(value), out, ExpUsage::Closure); break;
			case id<TableBlock_t>(): transformTableBlock(static_cast<TableBlock_t*>(value), out); break;
			case id<Exp_t>(): transformExp(static_cast<Exp_t*>(value), out, ExpUsage::Closure); break;
			default: assert(false); break;
		}
	}

	std::list<DestructItem> destructFromExp(ast_node* node) {
		const node_container* tableItems = nullptr;
		if (ast_is<Exp_t>(node)) {
			auto item = singleValueFrom(node)->item.get();
			if (!item) throw std::logic_error(_info.errorMessage("invalid destructure value"sv, node));
			auto tbA = item->getByPath<TableLit_t>();
			if (tbA) {
				tableItems = &tbA->values.objects();
			} else {
				auto tbB = ast_cast<simple_table_t>(item);
				if (tbB) tableItems = &tbB->pairs.objects();
			}
		} else if (auto table = ast_cast<TableBlock_t>(node)) {
			tableItems = &table->values.objects();
		}
		std::list<DestructItem> pairs;
		int index = 0;
		for (auto pair : *tableItems) {
			switch (pair->getId()) {
				case id<Exp_t>(): {
					++index;
					if (!isAssignable(static_cast<Exp_t*>(pair)))  {
						throw std::logic_error(_info.errorMessage("can't destructure value"sv, pair));
					}
					auto value = singleValueFrom(pair);
					auto item = value->item.get();
					if (ast_is<simple_table_t>(item) ||
						item->getByPath<TableLit_t>()) {
						auto subPairs = destructFromExp(pair);
						for (auto& p : subPairs) {
							pairs.push_back({p.isVariable, p.name,
								s("["sv) + std::to_string(index) + s("]"sv) + p.structure});
						}
					} else {
						bool lintGlobal = _config.lintGlobalVariable;
						_config.lintGlobalVariable = false;
						auto exp = static_cast<Exp_t*>(pair);
						auto varName = singleVariableFrom(exp);
						bool isVariable = !varName.empty();
						if (!isVariable) {
							str_list temp;
							transformExp(exp, temp, ExpUsage::Closure);
							varName = std::move(temp.back());
						}
						_config.lintGlobalVariable = lintGlobal;
						pairs.push_back({
							isVariable,
							varName,
							s("["sv) + std::to_string(index) + s("]"sv)
						});
					}
					break;
				}
				case id<variable_pair_t>(): {
					auto vp = static_cast<variable_pair_t*>(pair);
					auto name = _parser.toString(vp->name);
					if (Keywords.find(name) != Keywords.end()) {
						pairs.push_back({true, name, s("[\""sv) + name + s("\"]"sv)});
					} else {
						pairs.push_back({true, name, s("."sv) + name});
					}
					break;
				}
				case id<normal_pair_t>(): {
					auto np = static_cast<normal_pair_t*>(pair);
					auto key = np->key->getByPath<Name_t>();
					if (!key) throw std::logic_error(_info.errorMessage("invalid key for destructure"sv, np));
					if (auto exp = np->value.as<Exp_t>()) {
						if (!isAssignable(exp)) throw std::logic_error(_info.errorMessage("can't destructure value"sv, exp));
						auto item = singleValueFrom(exp)->item.get();
						if (ast_is<simple_table_t>(item) ||
							item->getByPath<TableLit_t>()) {
							auto subPairs = destructFromExp(exp);
							auto name = _parser.toString(key);
							for (auto& p : subPairs) {
								if (Keywords.find(name) != Keywords.end()) {
									pairs.push_back({p.isVariable, p.name,
										s("[\""sv) + name + s("\"]"sv) + p.structure});
								} else {
									pairs.push_back({p.isVariable, p.name,
										s("."sv) + name + p.structure});
								}
							}
						} else {
							bool lintGlobal = _config.lintGlobalVariable;
							_config.lintGlobalVariable = false;
							auto varName = singleVariableFrom(exp);
							bool isVariable = !varName.empty();
							if (!isVariable) {
								str_list temp;
								transformExp(exp, temp, ExpUsage::Closure);
								varName = std::move(temp.back());
							}
							_config.lintGlobalVariable = lintGlobal;
							auto name = _parser.toString(key);
							if (Keywords.find(name) != Keywords.end()) {
								pairs.push_back({
									isVariable,
									varName,
									s("[\""sv) + name + s("\"]"sv)
								});
							} else {
								pairs.push_back({
									isVariable,
									varName,
									s("."sv) + name
								});
							}
						}
						break;
					}
					if (np->value.is<TableBlock_t>()) {
						auto subPairs = destructFromExp(pair);
						for (auto& p : subPairs) {
							pairs.push_back({p.isVariable, p.name,
								s("."sv) + _parser.toString(key) + p.structure});
						}
					}
					break;
				}
				default: assert(false); break;
			}
		}
		return pairs;
	}

	std::pair<std::list<Destructure>, ast_ptr<false, ExpListAssign_t>>
		extractDestructureInfo(ExpListAssign_t* assignment, bool varDefOnly = false) {
		auto x = assignment;
		std::list<Destructure> destructs;
		if (!assignment->action.is<Assign_t>()) return { destructs, nullptr };
		auto exprs = assignment->expList->exprs.objects();
		auto values = assignment->action.to<Assign_t>()->values.objects();
		size_t size = std::max(exprs.size(),values.size());
		ast_ptr<false, Exp_t> var;
		if (exprs.size() < size) {
			var = toAst<Exp_t>("_"sv, x);
			while (exprs.size() < size) exprs.emplace_back(var);
		}
		ast_ptr<false, Exp_t> nullNode;
		if (values.size() < size) {
			nullNode = toAst<Exp_t>("nil"sv, x);
			while (values.size() < size) values.emplace_back(nullNode);
		}
		using iter = node_container::iterator;
		std::vector<std::pair<iter,iter>> destructPairs;
		str_list temp;
		for (auto i = exprs.begin(), j = values.begin(); i != exprs.end(); ++i, ++j) {
			auto expr = *i;
			ast_node* destructNode = expr->getByPath<Value_t, SimpleValue_t, TableLit_t>();
			if (destructNode || (destructNode = expr->getByPath<Value_t, simple_table_t>())) {
				destructPairs.push_back({i,j});
				auto& destruct = destructs.emplace_back();
				if (!varDefOnly) {
					pushScope();
					transformAssignItem(*j, temp);
					destruct.value = temp.back();
					temp.pop_back();
					popScope();
				}
				auto pairs = destructFromExp(expr);
				destruct.items = std::move(pairs);
			}
		}
		for (const auto& p : destructPairs) {
			exprs.erase(p.first);
			values.erase(p.second);
		}
		ast_ptr<false, ExpListAssign_t> newAssignment;
		if (!destructPairs.empty() && !exprs.empty()) {
			auto x = assignment;
			auto expList = x->new_ptr<ExpList_t>();
			auto newAssign = x->new_ptr<ExpListAssign_t>();
			newAssign->expList.set(expList);
			for (auto expr : exprs) expList->exprs.push_back(expr);
			auto assign = x->new_ptr<Assign_t>();
			for (auto value : values) assign->values.push_back(value);
			newAssign->action.set(assign);
			newAssignment = newAssign;
		}
		return {std::move(destructs), newAssignment};
	}

	void transformAssignmentCommon(ExpListAssign_t* assignment, str_list& out) {
		auto x = assignment;
		str_list temp;
		auto expList = assignment->expList.get();
		auto action = assignment->action.get();
		switch (action->getId()) {
			case id<Update_t>(): {
				if (expList->exprs.size() > 1) throw std::logic_error(_info.errorMessage("can not apply update to multiple values"sv, expList));
				auto update = static_cast<Update_t*>(action);
				auto leftExp = static_cast<Exp_t*>(expList->exprs.objects().front());
				auto leftValue = singleValueFrom(leftExp);
				if (!leftValue) throw std::logic_error(_info.errorMessage("left hand expression is not assignable"sv, leftExp));
				if (auto chain = leftValue->getByPath<ChainValue_t>()) {
					auto tmpChain = x->new_ptr<ChainValue_t>();
					for (auto item : chain->items.objects()) {
						bool itemAdded = false;
						BLOCK_START
						auto exp = ast_cast<Exp_t>(item);
						BREAK_IF(!exp);
						auto var = singleVariableFrom(exp);
						BREAK_IF(!var.empty());
						auto upVar = getUnusedName("_update_"sv);
						auto assignment = x->new_ptr<ExpListAssign_t>();
						assignment->expList.set(toAst<ExpList_t>(upVar, x));
						auto assign = x->new_ptr<Assign_t>();
						assign->values.push_back(exp);
						assignment->action.set(assign);
						transformAssignment(assignment, temp);
						tmpChain->items.push_back(toAst<Exp_t>(upVar, x));
						itemAdded = true;
						BLOCK_END
						if (!itemAdded) tmpChain->items.push_back(item);
					}
					chain->items.clear();
					chain->items.dup(tmpChain->items);
				}
				transformValue(leftValue, temp);
				auto left = std::move(temp.back());
				temp.pop_back();
				transformExp(update->value, temp, ExpUsage::Closure);
				auto right = std::move(temp.back());
				temp.pop_back();
				if (!singleValueFrom(update->value)) {
					right = s("("sv) + right + s(")"sv);
				}
				_buf << join(temp) << indent() << left << " = "sv << left <<
					" "sv << _parser.toString(update->op) << " "sv << right << nll(assignment);
				out.push_back(clearBuf());
				break;
			}
			case id<Assign_t>(): {
				bool oneLined = true;
				auto assign = static_cast<Assign_t*>(action);
				for (auto val : assign->values.objects()) {
					if (auto value = singleValueFrom(val)) {
						if (auto spValue = value->item.as<SimpleValue_t>()) {
							if (spValue->value.is<FunLit_t>()) {
								oneLined = false;
								break;
							}
						}
					}
				}
				auto defs = getAssignDefs(expList);
				if (oneLined && defs.size() == expList->exprs.objects().size()) {
					for (auto value : assign->values.objects()) {
						transformAssignItem(value, temp);
					}
					std::string preDefine = getPredefine(defs);
					for (const auto& def : defs) {
						addToScope(def);
					}
					if (preDefine.empty()) {
						transformExpList(expList, temp);
						std::string left = std::move(temp.back());
						temp.pop_back();
						out.push_back(indent() + left + s(" = "sv) + join(temp, ", "sv) + nll(assignment));
					} else {
						out.push_back(preDefine + s(" = "sv) + join(temp, ", "sv) + nll(assignment));
					}
				} else {
					std::string preDefine = getPredefine(defs);
					for (const auto& def : defs) {
						addToScope(def);
					}
					transformExpList(expList, temp);
					std::string left = temp.back();
					temp.pop_back();
					for (auto value : assign->values.objects()) {
						transformAssignItem(value, temp);
					}
					out.push_back((preDefine.empty() ? Empty : preDefine + nll(assignment)) + indent() + left + s(" = "sv) + join(temp, ", "sv) + nll(assignment));
				}
				break;
			}
			default: assert(false); break;
		}
	}

	void transformCond(const node_container& nodes, str_list& out, ExpUsage usage, bool unless, ExpList_t* assignList) {
		std::vector<ast_ptr<false, ast_node>> ns(false);
		for (auto it = nodes.rbegin(); it != nodes.rend(); ++it) {
			ns.push_back(*it);
			if (auto cond = ast_cast<IfCond_t>(*it)) {
				if (*it != nodes.front() && cond->assign) {
					auto x = *it;
					auto newIf = x->new_ptr<If_t>();
					for (auto j = ns.rbegin(); j != ns.rend(); ++j) {
						newIf->nodes.push_back(*j);
					}
					ns.clear();
					auto simpleValue = x->new_ptr<SimpleValue_t>();
					simpleValue->value.set(newIf);
					auto value = x->new_ptr<Value_t>();
					value->item.set(simpleValue);
					auto exp = x->new_ptr<Exp_t>();
					exp->value.set(value);
					auto expList = x->new_ptr<ExpList_t>();
					expList->exprs.push_back(exp);
					auto expListAssign = x->new_ptr<ExpListAssign_t>();
					expListAssign->expList.set(expList);
					auto stmt = x->new_ptr<Statement_t>();
					stmt->content.set(expListAssign);
					auto body = x->new_ptr<Body_t>();
					body->content.set(stmt);
					ns.push_back(body.get());
				}
			}
		}
		if (nodes.size() != ns.size()) {
			auto x = ns.back();
			auto newIf = x->new_ptr<If_t>();
			for (auto j = ns.rbegin(); j != ns.rend(); ++j) {
				newIf->nodes.push_back(*j);
			}
			transformCond(newIf->nodes.objects(), out, usage, unless, assignList);
			return;
		}
		str_list temp;
		if (usage == ExpUsage::Closure) {
			temp.push_back(s("(function()"sv) + nll(nodes.front()));
			pushScope();
		}
		std::list<std::pair<IfCond_t*, Body_t*>> ifCondPairs;
		ifCondPairs.emplace_back();
		for (auto node : nodes) {
			switch (node->getId()) {
				case id<IfCond_t>():
					ifCondPairs.back().first = static_cast<IfCond_t*>(node);
					break;
				case id<Body_t>():
					ifCondPairs.back().second = static_cast<Body_t*>(node);
					ifCondPairs.emplace_back();
					break;
				default: assert(false); break;
			}
		}
		auto assign = ifCondPairs.front().first->assign.get();
		bool storingValue = false;
		ast_ptr<false, ExpListAssign_t> extraAssignment;
		if (assign) {
			auto exp = ifCondPairs.front().first->condition.get();
			auto x = exp;
			auto var = singleVariableFrom(exp);
			if (var.empty()) {
				storingValue = true;
				auto desVar = getUnusedName("_des_"sv);
				if (assign->values.objects().size() == 1) {
					auto var = singleVariableFrom(assign->values.objects().front());
					if (!var.empty()) {
						desVar = var;
						storingValue = false;
					}
				}
				if (storingValue) {
					if (usage != ExpUsage::Closure) {
						temp.push_back(indent() + s("do"sv) + nll(assign));
						pushScope();
					}
					auto expList = toAst<ExpList_t>(desVar, x);
					auto assignment = x->new_ptr<ExpListAssign_t>();
					assignment->expList.set(expList);
					assignment->action.set(assign);
					transformAssignment(assignment, temp);
				}
				{
					auto expList = x->new_ptr<ExpList_t>();
					expList->exprs.push_back(exp);
					auto assignOne = x->new_ptr<Assign_t>();
					auto valExp = toAst<Exp_t>(desVar, x);
					assignOne->values.push_back(valExp);
					auto assignment = x->new_ptr<ExpListAssign_t>();
					assignment->expList.set(expList);
					assignment->action.set(assignOne);
					extraAssignment.set(assignment);
					ifCondPairs.front().first->condition.set(valExp);
				}
			} else {
				if (!isDefined(var)) {
					storingValue = true;
					if (usage != ExpUsage::Closure) {
						temp.push_back(indent() + s("do"sv) + nll(assign));
						pushScope();
					}
				}
				auto expList = x->new_ptr<ExpList_t>();
				expList->exprs.push_back(exp);
				auto assignment = x->new_ptr<ExpListAssign_t>();
				assignment->expList.set(expList);
				assignment->action.set(assign);
				transformAssignment(assignment, temp);
			}
		}
		for (const auto& pair : ifCondPairs) {
			if (pair.first) {
				str_list tmp;
				auto condition = pair.first->condition.get();
				if (unless) {
					if (auto value = singleValueFrom(condition)) {
						transformValue(value, tmp);
					} else {
						transformExp(condition, tmp, ExpUsage::Closure);
						tmp.back() = s("("sv) + tmp.back() + s(")"sv);
					}
					tmp.back().insert(0, s("not "sv));
					unless = false;
				} else {
					transformExp(condition, tmp, ExpUsage::Closure);
				}
				_buf << indent();
				if (pair != ifCondPairs.front()) {
					_buf << "else"sv;
				}
				_buf << "if "sv << tmp.back() << " then"sv << nll(condition);
				temp.push_back(clearBuf());
			}
			if (pair.second) {
				if (!pair.first) {
					temp.push_back(indent() + s("else"sv) + nll(pair.second));
				}
				pushScope();
				if (pair == ifCondPairs.front() && extraAssignment) {
					transformAssignment(extraAssignment, temp);
				}
				transformBody(pair.second, temp, usage, assignList);
				popScope();
			}
			if (!pair.first) {
				temp.push_back(indent() + s("end"sv) + nll(nodes.front()));
				break;
			}
		}
		if (storingValue && usage != ExpUsage::Closure) {
			popScope();
			temp.push_back(indent() + s("end"sv) + nlr(nodes.front()));
		}
		if (usage == ExpUsage::Closure) {
			popScope();
			temp.push_back(indent() + s("end)()"sv));
		}
		out.push_back(join(temp));
	}

	void transformIf(If_t* ifNode, str_list& out, ExpUsage usage, ExpList_t* assignList = nullptr) {
		transformCond(ifNode->nodes.objects(), out, usage, false, assignList);
	}

	void transformUnless(Unless_t* unless, str_list& out, ExpUsage usage, ExpList_t* assignList = nullptr) {
		transformCond(unless->nodes.objects(), out, usage, true, assignList);
	}

	void transformExpList(ExpList_t* expList, str_list& out) {
		str_list temp;
		for (auto exp : expList->exprs.objects()) {
			transformExp(static_cast<Exp_t*>(exp), temp, ExpUsage::Closure);
		}
		out.push_back(join(temp, ", "sv));
	}

	void transformExpListLow(ExpListLow_t* expListLow, str_list& out) {
		str_list temp;
		for (auto exp : expListLow->exprs.objects()) {
			transformExp(static_cast<Exp_t*>(exp), temp, ExpUsage::Closure);
		}
		out.push_back(join(temp, ", "sv));
	}

	void transformExp(Exp_t* exp, str_list& out, ExpUsage usage, ExpList_t* assignList = nullptr) {
		auto x = exp;
		const auto& opValues = exp->opValues.objects();
		for (auto it = opValues.begin(); it != opValues.end(); ++it) {
			auto opValue = static_cast<exp_op_value_t*>(*it);
			if (opValue->op.is<BackcallOperator_t>()) {
				if (auto chainValue = opValue->value->item.as<ChainValue_t>()) {
					auto newExp = x->new_ptr<Exp_t>();
					{
						auto arg = x->new_ptr<Exp_t>();
						arg->value.set(exp->value);
						for (auto i = opValues.begin(); i != it; ++i) {
							arg->opValues.push_back(*i);
						}
						auto next = it; ++next;
						for (auto i = next; i != opValues.end(); ++i) {
							newExp->opValues.push_back(*i);
						}
						if (isChainValueCall(chainValue)) {
							auto last = chainValue->items.back();
							_ast_list* args = nullptr;
							if (auto invoke = ast_cast<InvokeArgs_t>(last)) {
								args = &invoke->args;
							} else {
								args = &(ast_to<Invoke_t>(last)->args);
							}
							bool findPlaceHolder = false;
							for (auto a : args->objects()) {
								bool lintGlobal = _config.lintGlobalVariable;
								_config.lintGlobalVariable = false;
								auto name = singleVariableFrom(a);
								_config.lintGlobalVariable = lintGlobal;
								if (name == "_"sv) {
									if (!findPlaceHolder) {
										args->swap(a, arg);
										findPlaceHolder = true;
									} else {
										throw std::logic_error(_info.errorMessage("backcall placeholder can be used only in one place"sv, a));
									}
								}
							}
							if (!findPlaceHolder) {
								args->push_front(arg);
							}
						} else {
							auto invoke = x->new_ptr<Invoke_t>();
							invoke->args.push_front(arg);
							chainValue->items.push_back(invoke);
						}
						auto value = x->new_ptr<Value_t>();
						value->item.set(chainValue);
						newExp->value.set(value);
					}
					if (newExp->opValues.size() == 0) {
						if (usage == ExpUsage::Assignment) {
							auto assign = x->new_ptr<Assign_t>();
							assign->values.push_back(newExp);
							auto assignment = x->new_ptr<ExpListAssign_t>();
							assignment->expList.set(assignList);
							assignment->action.set(assign);
							transformAssignment(assignment, out);
						} else {
							transformChainValue(chainValue, out, usage);
						}
					} else {
						transformExp(newExp, out, usage, assignList);
					}
					return;
				} else {
					throw std::logic_error(_info.errorMessage("backcall operator must be followed by chain value"sv, opValue->value));
				}
			}
		}
		str_list temp;
		transformValue(exp->value, temp);
		for (auto _opValue : exp->opValues.objects()) {
			auto opValue = static_cast<exp_op_value_t*>(_opValue);
			if (auto op = opValue->op.as<BinaryOperator_t>()) {
				transformBinaryOperator(op, temp);
			} else {
				temp.push_back(s("|>"sv));
			}
			transformValue(opValue->value, temp);
		}
		out.push_back(join(temp, " "sv));
	}

	void transformValue(Value_t* value, str_list& out) {
		auto item = value->item.get();
		switch (item->getId()) {
			case id<SimpleValue_t>(): transformSimpleValue(static_cast<SimpleValue_t*>(item), out); break;
			case id<simple_table_t>(): transform_simple_table(static_cast<simple_table_t*>(item), out); break;
			case id<ChainValue_t>(): {
				auto chainValue = static_cast<ChainValue_t*>(item);
				transformChainValue(chainValue, out, ExpUsage::Closure);
				break;
			}
			case id<String_t>(): transformString(static_cast<String_t*>(item), out); break;
			default: assert(false); break;
		}
	}

	void transformCallable(Callable_t* callable, str_list& out, const ast_sel<false,Invoke_t,InvokeArgs_t>& invoke = {}) {
		auto item = callable->item.get();
		switch (item->getId()) {
			case id<Variable_t>(): {
				transformVariable(static_cast<Variable_t*>(item), out);
				if (_config.lintGlobalVariable && !isDefined(out.back())) {
					if (_globals.find(out.back()) == _globals.end()) {
						_globals[out.back()] = {item->m_begin.m_line, item->m_begin.m_col};
					}
				}
				break;
			}
			case id<SelfName_t>(): {
				transformSelfName(static_cast<SelfName_t*>(item), out, invoke);
				if (_config.lintGlobalVariable) {
					std::string self("self"sv);
					if (!isDefined(self)) {
						if (_globals.find(self) == _globals.end()) {
							_globals[self] = {item->m_begin.m_line, item->m_begin.m_col};
						}
					}
				}
				break;
			}
			case id<VarArg_t>():
				if (_varArgs.empty() || !_varArgs.top()) {
					throw std::logic_error(_info.errorMessage("cannot use '...' outside a vararg function near '...'"sv, item));
				}
				out.push_back(s("..."sv));
				break;
			case id<Parens_t>(): transformParens(static_cast<Parens_t*>(item), out); break;
			default: assert(false); break;
		}
	}

	void transformParens(Parens_t* parans, str_list& out) {
		str_list temp;
		transformExp(parans->expr, temp, ExpUsage::Closure);
		out.push_back(s("("sv) + temp.front() + s(")"sv));
	}

	void transformSimpleValue(SimpleValue_t* simpleValue, str_list& out) {
		auto value = simpleValue->value.get();
		switch (value->getId()) {
			case id<const_value_t>(): transform_const_value(static_cast<const_value_t*>(value), out); break;
			case id<If_t>(): transformIf(static_cast<If_t*>(value), out, ExpUsage::Closure); break;
			case id<Unless_t>(): transformUnless(static_cast<Unless_t*>(value), out, ExpUsage::Closure); break;
			case id<Switch_t>(): transformSwitch(static_cast<Switch_t*>(value), out, ExpUsage::Closure); break;
			case id<With_t>(): transformWithClosure(static_cast<With_t*>(value), out); break;
			case id<ClassDecl_t>(): transformClassDeclClosure(static_cast<ClassDecl_t*>(value), out); break;
			case id<ForEach_t>(): transformForEachClosure(static_cast<ForEach_t*>(value), out); break;
			case id<For_t>(): transformForClosure(static_cast<For_t*>(value), out); break;
			case id<While_t>(): transformWhileClosure(static_cast<While_t*>(value), out); break;
			case id<Do_t>(): transformDo(static_cast<Do_t*>(value), out, ExpUsage::Closure); break;
			case id<unary_exp_t>(): transform_unary_exp(static_cast<unary_exp_t*>(value), out); break;
			case id<TblComprehension_t>(): transformTblComprehension(static_cast<TblComprehension_t*>(value), out, ExpUsage::Closure); break;
			case id<TableLit_t>(): transformTableLit(static_cast<TableLit_t*>(value), out); break;
			case id<Comprehension_t>(): transformComprehension(static_cast<Comprehension_t*>(value), out, ExpUsage::Closure); break;
			case id<FunLit_t>(): transformFunLit(static_cast<FunLit_t*>(value), out); break;
			case id<Num_t>(): transformNum(static_cast<Num_t*>(value), out); break;
			default: assert(false); break;
		}
	}

	void transformFunLit(FunLit_t* funLit, str_list& out) {
		_enableReturn.push(true);
		_varArgs.push(false);
		str_list temp;
		bool isFatArrow = _parser.toString(funLit->arrow) == "=>"sv;
		pushScope();
		if (isFatArrow) {
			forceAddToScope(s("self"sv));
		}
		if (auto argsDef = funLit->argsDef.get()) {
			transformFnArgsDef(argsDef, temp);
			if (funLit->body) {
				transformBody(funLit->body, temp, ExpUsage::Return);
			} else {
				temp.push_back(Empty);
			}
			auto it = temp.begin();
			auto& args = *it;
			auto& initArgs = *(++it);
			auto& bodyCodes = *(++it);
			_buf << "function("sv <<
				(isFatArrow ? s("self, "sv) : Empty) <<
				args << ')';
			if (!initArgs.empty() || !bodyCodes.empty()) {
				_buf << nlr(argsDef) << initArgs << bodyCodes;
				popScope();
				_buf << indent() << "end"sv;
			} else {
				popScope();
				_buf << " end"sv;
			}
		} else {
			if (funLit->body) {
				transformBody(funLit->body, temp, ExpUsage::Return);
			} else {
				temp.push_back(Empty);
			}
			auto& bodyCodes = temp.back();
			_buf << "function("sv <<
				(isFatArrow ? s("self"sv) : Empty) <<
				')';
			if (!bodyCodes.empty()) {
				_buf << nll(funLit) << bodyCodes;
				popScope();
				_buf << indent() << "end"sv;
			} else {
				popScope();
				_buf << " end"sv;
			}
		}
		out.push_back(clearBuf());
		_enableReturn.pop();
		_varArgs.pop();
	}

	void transformBody(Body_t* body, str_list& out, ExpUsage usage, ExpList_t* assignList = nullptr) {
		auto x = body;
		if (auto stmt = body->content.as<Statement_t>()) {
			auto block = x->new_ptr<Block_t>();
			block->statements.push_back(stmt);
			transformBlock(block, out, usage, assignList);
		} else {
			transformBlock(body->content.to<Block_t>(), out, usage, assignList);
		}
	}

	void transformBlock(Block_t* block, str_list& out, ExpUsage usage, ExpList_t* assignList = nullptr, bool isRoot = false) {
		const auto& nodes = block->statements.objects();
		LocalMode mode = LocalMode::None;
		Local_t* any = nullptr, *capital = nullptr;
		for (auto it = nodes.begin(); it != nodes.end(); ++it) {
			auto node = *it;
			auto stmt = static_cast<Statement_t*>(node);
			if (auto backcall = stmt->content.as<Backcall_t>()) {
				auto x = *nodes.begin();
				auto newBlock = x->new_ptr<Block_t>();
				if (it != nodes.begin()) {
					for (auto i = nodes.begin(); i != it; ++i) {
						newBlock->statements.push_back(*i);
					}
				}
				x = backcall;
				auto arg = x->new_ptr<Exp_t>();
				{
					auto block = x->new_ptr<Block_t>();
					auto next = it; ++next;
					if (next != nodes.end()) {
						for (auto i = next; i != nodes.end(); ++i) {
							block->statements.push_back(*i);
						}
					}
					auto body = x->new_ptr<Body_t>();
					body->content.set(block);
					auto funLit = x->new_ptr<FunLit_t>();
					funLit->argsDef.set(backcall->argsDef);
					auto arrow = _parser.toString(backcall->arrow);
					funLit->arrow.set(toAst<fn_arrow_t>(arrow == "<-"sv ? "->"sv : "=>"sv, x));
					funLit->body.set(body);
					auto simpleValue = x->new_ptr<SimpleValue_t>();
					simpleValue->value.set(funLit);
					auto value = x->new_ptr<Value_t>();
					value->item.set(simpleValue);
					arg->value.set(value);
				}
				if (isChainValueCall(backcall->value)) {
					auto last = backcall->value->items.back();
					_ast_list* args = nullptr;
					if (auto invoke = ast_cast<InvokeArgs_t>(last)) {
						args = &invoke->args;
					} else {
						args = &(ast_to<Invoke_t>(last)->args);
					}
					bool findPlaceHolder = false;
					for (auto a : args->objects()) {
						bool lintGlobal = _config.lintGlobalVariable;
						_config.lintGlobalVariable = false;
						auto name = singleVariableFrom(a);
						_config.lintGlobalVariable = lintGlobal;
						if (name == "_"sv) {
							if (!findPlaceHolder) {
								args->swap(a, arg);
								findPlaceHolder = true;
							} else {
								throw std::logic_error(_info.errorMessage("backcall placeholder can be used only in one place"sv, a));
							}
						}
					}
					if (!findPlaceHolder) {
						args->push_back(arg);
					}
				} else {
					auto invoke = x->new_ptr<Invoke_t>();
					invoke->args.push_back(arg);
					backcall->value->items.push_back(invoke);
				}
				auto newStmt = x->new_ptr<Statement_t>();
				{
					auto chainValue = backcall->value.get();
					auto value = x->new_ptr<Value_t>();
					value->item.set(chainValue);
					auto exp = x->new_ptr<Exp_t>();
					exp->value.set(value);
					auto expList = x->new_ptr<ExpList_t>();
					expList->exprs.push_back(exp);
					auto expListAssign = x->new_ptr<ExpListAssign_t>();
					expListAssign->expList.set(expList);
					newStmt->content.set(expListAssign);
					newStmt->appendix.set(stmt->appendix);
					newBlock->statements.push_back(newStmt);
				}
				transformBlock(newBlock, out, usage, assignList, isRoot);
				return;
			}
			if (auto local = stmt->content.as<Local_t>()) {
				switch (local->item->getId()) {
					case id<local_flag_t>(): {
						auto flag = local->item.to<local_flag_t>();
						LocalMode newMode = _parser.toString(flag) == "*"sv ? LocalMode::Any : LocalMode::Capital;
						if (int(newMode) > int(mode)) {
							mode = newMode;
						}
						if (mode == LocalMode::Any) {
							if (!any) any = local;
							if (!capital) capital = local;
						} else {
							if (!capital) capital = local;
						}
						break;
					}
					case id<local_values_t>(): {
						auto values = local->item.to<local_values_t>();
						for (auto name : values->nameList->names.objects()) {
							local->forceDecls.push_back(_parser.toString(name));
						}
						break;
					}
				}
			} else if (mode != LocalMode::None) {
				ClassDecl_t* classDecl = nullptr;
				if (auto assignment = assignmentFrom(stmt)) {
					auto vars = getAssignVars(assignment);
					for (const auto& var : vars) {
						if (var.empty()) continue;
						if (std::isupper(var[0]) && capital) {
							capital->decls.push_back(var);
						} else if (any) {
							any->decls.push_back(var);
						}
					}
					auto info = extractDestructureInfo(assignment, true);
					if (!info.first.empty()) {
						for (const auto& destruct : info.first)
							for (const auto& item : destruct.items)
								if (item.isVariable) {
									if (std::isupper(item.name[0]) && capital) { capital->decls.push_back(item.name);
									} else if (any) {
										any->decls.push_back(item.name);
									}
								}
					}
					if (info.second) {
						auto defs = transformAssignDefs(info.second->expList, false);
						for (const auto& def : defs) {
							if (std::isupper(def[0]) && capital) { capital->decls.push_back(def);
							} else if (any) {
								any->decls.push_back(def);
							}
						}
					}
					BLOCK_START
					auto assign = assignment->action.as<Assign_t>();
					BREAK_IF(!assign);
					BREAK_IF(assign->values.objects().size() != 1);
					auto exp = ast_cast<Exp_t>(assign->values.objects().front());
					BREAK_IF(!exp);
					auto value = singleValueFrom(exp);
					classDecl = value->getByPath<SimpleValue_t, ClassDecl_t>();
					BLOCK_END
				} else if (auto expList = expListFrom(stmt)) {
					auto value = singleValueFrom(expList);
					classDecl = value->getByPath<SimpleValue_t, ClassDecl_t>();
				}
				if (classDecl) {
					if (auto variable = classDecl->name->item.as<Variable_t>()) {
						auto className = _parser.toString(variable);
						if (!className.empty()) {
							if (std::isupper(className[0]) && capital) {
								capital->decls.push_back(className);
							} else if (any) {
								any->decls.push_back(className);
							}
						}
					}
				}
			}
		}
		if (isRoot && !_info.moduleName.empty()) {
			block->statements.push_front(toAst<Statement_t>(_info.moduleName + s(_info.exportDefault ? "=nil"sv : "={}"sv), block));
		}
		switch (usage) {
			case ExpUsage::Closure:
			case ExpUsage::Return: {
				BLOCK_START
				BREAK_IF(isRoot && !_info.moduleName.empty());
				BREAK_IF(nodes.empty());
				auto last = static_cast<Statement_t*>(nodes.back());
				auto x = last;
				auto expList = expListFrom(last);
				BREAK_IF(!expList ||
					(last->appendix &&
						last->appendix->item.is<CompInner_t>()));
				auto expListLow = x->new_ptr<ExpListLow_t>();
				expListLow->exprs.dup(expList->exprs);
				auto returnNode = x->new_ptr<Return_t>();
				returnNode->valueList.set(expListLow);
				returnNode->allowBlockMacroReturn = true;
				last->content.set(returnNode);
				BLOCK_END
				break;
			}
			case ExpUsage::Assignment: {
				auto last = lastStatementFrom(block);
				if (!last) return;
				bool lastAssignable = expListFrom(last) || ast_is<For_t, ForEach_t, While_t>(last->content);
				if (lastAssignable) {
					auto x = last;
					auto newAssignment = x->new_ptr<ExpListAssign_t>();
					newAssignment->expList.set(assignList);
					auto assign = x->new_ptr<Assign_t>();
					if (auto valueList = last->content.as<ExpListAssign_t>()) {
						assign->values.dup(valueList->expList->exprs);
					} else {
						auto simpleValue = x->new_ptr<SimpleValue_t>();
						simpleValue->value.set(last->content);
						auto value = x->new_ptr<Value_t>();
						value->item.set(simpleValue);
						auto exp = x->new_ptr<Exp_t>();
						exp->value.set(value);
						assign->values.push_back(exp);
					}
					newAssignment->action.set(assign);
					last->content.set(newAssignment);
				}
				break;
			}
			default: break;
		}
		if (!nodes.empty()) {
			str_list temp;
			for (auto node : nodes) {
				transformStatement(static_cast<Statement_t*>(node), temp);
			}
			out.push_back(join(temp));
		} else {
			out.push_back(Empty);
		}
		if (isRoot && !_info.moduleName.empty()) {
			out.back().append(indent() + s("return "sv) + _info.moduleName + nlr(block));
		}
	}

	void pushCurrentModule() {
		if (_useModule) {
			lua_pushliteral(L, MOONP_MODULE); // MOONP_MODULE
			lua_rawget(L, LUA_REGISTRYINDEX); // reg[MOONP_MODULE], tb
			int idx = static_cast<int>(lua_objlen(L, -1)); // idx = #tb, tb
			lua_rawgeti(L, -1, idx); // tb[idx], tb cur
			lua_remove(L, -2); // cur
			return;
		}
		_useModule = true;
		if (!L) {
			L = luaL_newstate();
			if (_luaOpen) {
				_luaOpen(static_cast<void*>(L));
			}
			_stateOwner = true;
		}
		lua_pushliteral(L, MOONP_MODULE); // MOONP_MODULE
		lua_rawget(L, LUA_REGISTRYINDEX); // reg[MOONP_MODULE], tb
		if (lua_isnil(L, -1) != 0) { // tb == nil
			lua_pop(L, 1);
			lua_newtable(L); // tb
			lua_pushliteral(L, MOONP_MODULE); // tb MOONP_MODULE
			lua_pushvalue(L, -2); // tb MOONP_MODULE tb
			lua_rawset(L, LUA_REGISTRYINDEX); // reg[MOONP_MODULE] = tb, tb
		} // tb
		int idx = static_cast<int>(lua_objlen(L, -1)); // idx = #tb, tb
		lua_newtable(L); // tb cur
		lua_pushvalue(L, -1); // tb cur cur
		lua_rawseti(L, -3, idx + 1); // tb[idx + 1] = cur, tb cur
		lua_remove(L, -2); // cur
	}

	void pushMoonp(std::string_view name) {
		lua_getglobal(L, "package"); // package
		lua_getfield(L, -1, "loaded"); // package loaded
		lua_getfield(L, -1, "moonp"); // package loaded moonp
		lua_pushlstring(L, &name.front(), name.size()); // package loaded moonp name
		lua_gettable(L, -2); // loaded[name], package loaded moonp item
		lua_insert(L, -4); // item package loaded moonp
		lua_pop(L, 3); // item
	}

	bool isModuleLoaded(std::string_view name) {
		int top = lua_gettop(L);
		DEFER(lua_settop(L, top));
		lua_pushliteral(L, MOONP_MODULE); // MOONP_MODULE
		lua_rawget(L, LUA_REGISTRYINDEX); // modules
		lua_pushlstring(L, &name.front(), name.size());
		lua_rawget(L, -2); // modules module
		if (lua_isnil(L, -1) != 0) {
			return false;
		}
		return true;
	}

	void pushModuleTable(std::string_view name) {
		lua_pushliteral(L, MOONP_MODULE); // MOONP_MODULE
		lua_rawget(L, LUA_REGISTRYINDEX); // modules
		lua_pushlstring(L, &name.front(), name.size());
		lua_rawget(L, -2); // modules module
		if (lua_isnil(L, -1) != 0) {
			lua_pop(L, 1);
			lua_newtable(L); // modules module
			lua_pushlstring(L, &name.front(), name.size());
			lua_pushvalue(L, -2); // modules module name module
			lua_rawset(L, -4); // modules[name] = module, modules module
		}
		lua_remove(L, -2); // module
	}

	void pushOptions(int lineOffset) {
		lua_newtable(L);
		lua_pushliteral(L, "lint_global");
		lua_pushboolean(L, 0);
		lua_rawset(L, -3);
		lua_pushliteral(L, "implicit_return_root");
		lua_pushboolean(L, 1);
		lua_rawset(L, -3);
		lua_pushliteral(L, "reserve_line_number");
		lua_pushboolean(L, 1);
		lua_rawset(L, -3);
		lua_pushliteral(L, "same_module");
		lua_pushboolean(L, 1);
		lua_rawset(L, -3);
		lua_pushliteral(L, "line_offset");
		lua_pushinteger(L, lineOffset);
		lua_rawset(L, -3);
	}

	void transformMacro(Macro_t* macro, str_list& out, bool exporting) {
		if (_scopes.size() > 1) {
			throw std::logic_error(_info.errorMessage("can not define macro outside the root block"sv, macro));
		}
		auto type = _parser.toString(macro->type);
		auto macroName = _parser.toString(macro->name);
		auto argsDef = macro->macroLit->argsDef.get();
		str_list newArgs;
		if (argsDef) {
			for (auto def_ : argsDef->definitions.objects()) {
				auto def = static_cast<FnArgDef_t*>(def_);
				if (def->name.is<SelfName_t>()) {
					throw std::logic_error(_info.errorMessage("self name is not supported for macro function argument"sv, def->name));
				} else {
					std::string defVal;
					if (def->defaultValue) {
						defVal = _parser.toString(def->defaultValue);
						Utils::trim(defVal);
						defVal.insert(0, "=[==========["sv);
						defVal.append("]==========]"sv);
					}
					newArgs.emplace_back(_parser.toString(def->name) + defVal);
				}
			}
			if (argsDef->varArg) {
				newArgs.emplace_back(_parser.toString(argsDef->varArg));
			}
		}
		_buf << "fmacro = ("sv << join(newArgs, ","sv) << ")->"sv;
		_buf << _parser.toString(macro->macroLit->body) << '\n';
		_buf << "{fmacro, \"" << type << "\"}"sv;
		auto macroCodes = clearBuf();
		_buf << "=(macro "sv << macroName << ")";
		auto chunkName = clearBuf();
		pushCurrentModule(); // cur
		int top = lua_gettop(L) - 1;
		DEFER(lua_settop(L, top));
		pushMoonp("loadstring"sv); // cur loadstring
		lua_pushlstring(L, macroCodes.c_str(), macroCodes.size()); // cur loadstring codes
		lua_pushlstring(L, chunkName.c_str(), chunkName.size()); // cur loadstring codes chunk
		pushOptions(macro->m_begin.m_line - 1); // cur loadstring codes chunk options
		if (lua_pcall(L, 3, 2, 0) != 0) { // loadstring(codes,chunk,options), cur f err
			std::string err = lua_tostring(L, -1);
			throw std::logic_error(_info.errorMessage(s("fail to load macro codes\n"sv) + err, macro->macroLit));
		} // cur f err
		if (lua_isnil(L, -2) != 0) { // f == nil, cur f err
			std::string err = lua_tostring(L, -1);
			throw std::logic_error(_info.errorMessage(s("fail to load macro codes, at (macro "sv) + macroName + s("): "sv) + err, macro->macroLit));
		}
		lua_pop(L, 1); // cur f
		pushMoonp("pcall"sv); // cur f pcall
		lua_insert(L, -2); // cur pcall f
		if (lua_pcall(L, 1, 2, 0) != 0) { // f(), cur success macro
			std::string err = lua_tostring(L, -1);
			throw std::logic_error(_info.errorMessage(s("fail to generate macro function\n"sv) + err, macro->macroLit));
		} // cur success res
		if (lua_toboolean(L, -2) == 0) {
			std::string err = lua_tostring(L, -1);
			throw std::logic_error(_info.errorMessage(s("fail to generate macro function\n"sv) + err, macro->macroLit));
		} // cur true macro
		lua_remove(L, -2); // cur macro
		if (exporting && !_moduleName.empty()) {
			pushModuleTable(_moduleName); // cur macro module
			lua_pushlstring(L, macroName.c_str(), macroName.size()); // cur macro module name
			lua_pushvalue(L, -3); // cur macro module name macro
			lua_rawset(L, -3); // cur macro module
			lua_pop(L, 1);
		} // cur macro
		lua_pushlstring(L, macroName.c_str(), macroName.size()); // cur macro name
		lua_insert(L, -2); // cur name macro
		lua_rawset(L, -3); // cur[name] = macro, cur
		out.push_back(Empty);
	}

	void transformReturn(Return_t* returnNode, str_list& out) {
		if (!_enableReturn.top()) {
			ast_node* target = returnNode->valueList.get();
			if (!target) target = returnNode;
			throw std::logic_error(_info.errorMessage("illegal return statement here"sv, target));
		}
		if (auto valueList = returnNode->valueList.get()) {
			if (valueList->exprs.size() == 1) {
				auto exp = static_cast<Exp_t*>(valueList->exprs.back());
				if (isPureBackcall(exp)) {
					transformExp(exp, out, ExpUsage::Return);
					return;
				}
			}
			if (auto singleValue = singleValueFrom(valueList)) {
				if (auto simpleValue = singleValue->item.as<SimpleValue_t>()) {
					auto value = simpleValue->value.get();
					switch (value->getId()) {
						case id<Comprehension_t>():
							transformComprehension(static_cast<Comprehension_t*>(value), out, ExpUsage::Return);
							return;
						case id<TblComprehension_t>():
							transformTblComprehension(static_cast<TblComprehension_t*>(value), out, ExpUsage::Return);
							return;
						case id<With_t>():
							transformWith(static_cast<With_t*>(value), out, nullptr, true);
							return;
						case id<ClassDecl_t>():
							transformClassDecl(static_cast<ClassDecl_t*>(value), out, ExpUsage::Return);
							return;
						case id<Do_t>():
							transformDo(static_cast<Do_t*>(value), out, ExpUsage::Return);
							return;
						case id<Switch_t>():
							transformSwitch(static_cast<Switch_t*>(value), out, ExpUsage::Return);
							return;
						case id<While_t>():
							transformWhileInPlace(static_cast<While_t*>(value), out);
							return;
						case id<For_t>():
							transformForInPlace(static_cast<For_t*>(value), out);
							return;
						case id<ForEach_t>():
							transformForEachInPlace(static_cast<ForEach_t*>(value), out);
							return;
						case id<If_t>():
							transformIf(static_cast<If_t*>(value), out, ExpUsage::Return);
							return;
						case id<Unless_t>():
							transformUnless(static_cast<Unless_t*>(value), out, ExpUsage::Return);
							return;
					}
				} else if (auto chainValue = singleValue->item.as<ChainValue_t>()) {
					if (specialChainValue(chainValue) != ChainType::Common) {
						transformChainValue(chainValue, out, ExpUsage::Return, nullptr, returnNode->allowBlockMacroReturn);
						return;
					}
				}
				transformValue(singleValue, out);
				out.back() = indent() + s("return "sv) + out.back() + nlr(returnNode);
				return;
			} else {
				str_list temp;
				transformExpListLow(valueList, temp);
				out.push_back(indent() + s("return "sv) + temp.back() + nlr(returnNode));
			}
		} else {
			out.push_back(indent() + s("return"sv) + nll(returnNode));
		}
	}

	void transformFnArgsDef(FnArgsDef_t* argsDef, str_list& out) {
		if (!argsDef->defList) {
			out.push_back(Empty);
			out.push_back(Empty);
		} else {
			transformFnArgDefList(argsDef->defList, out);
		}
		if (argsDef->shadowOption) {
			transform_outer_var_shadow(argsDef->shadowOption);
		}
	}

	void transform_outer_var_shadow(outer_var_shadow_t* shadow) {
		markVarShadowed();
		if (shadow->varList) {
			for (auto name : shadow->varList->names.objects()) {
				addToAllowList(_parser.toString(name));
			}
		}
	}

	void transformFnArgDefList(FnArgDefList_t* argDefList, str_list& out) {
		auto x = argDefList;
		struct ArgItem {
			std::string name;
			std::string assignSelf;
		};
		std::list<ArgItem> argItems;
		str_list temp;
		std::string varNames;
		bool assignSelf = false;
		for (auto _def : argDefList->definitions.objects()) {
			auto def = static_cast<FnArgDef_t*>(_def);
			auto& arg = argItems.emplace_back();
			switch (def->name->getId()) {
				case id<Variable_t>(): arg.name = _parser.toString(def->name); break;
				case id<SelfName_t>(): {
					assignSelf = true;
					auto selfName = static_cast<SelfName_t*>(def->name.get());
					switch (selfName->name->getId()) {
						case id<self_class_name_t>(): {
							auto clsName = static_cast<self_class_name_t*>(selfName->name.get());
							arg.name = _parser.toString(clsName->name);
							arg.assignSelf = s("self.__class."sv) + arg.name;
							break;
						}
						case id<self_class_t>():
							arg.name = "self.__class"sv;
							break;
						case id<self_name_t>(): {
							auto sfName = static_cast<self_name_t*>(selfName->name.get());
							arg.name = _parser.toString(sfName->name);
							arg.assignSelf = s("self."sv) + arg.name;
							break;
						}
						case id<self_t>():
							arg.name = "self"sv;
							break;
						default: assert(false); break;
					}
					break;
				}
				default: assert(false); break;
			}
			forceAddToScope(arg.name);
			if (def->defaultValue) {
				pushScope();
				auto expList = toAst<ExpList_t>(arg.name, x);
				auto assign = x->new_ptr<Assign_t>();
				assign->values.push_back(def->defaultValue.get());
				auto assignment = x->new_ptr<ExpListAssign_t>();
				assignment->expList.set(expList);
				assignment->action.set(assign);
				transformAssignment(assignment, temp);
				popScope();
				_buf << indent() << "if "sv << arg.name << " == nil then"sv << nll(def);
				_buf << temp.back();
				_buf << indent() << "end"sv << nll(def);
				temp.back() = clearBuf();
			}
			if (varNames.empty()) varNames = arg.name;
			else varNames.append(s(", "sv) + arg.name);
		}
		if (argDefList->varArg) {
			auto& arg = argItems.emplace_back();
			arg.name = "..."sv;
			if (varNames.empty()) varNames = arg.name;
			else varNames.append(s(", "sv) + arg.name);
			_varArgs.top() = true;
		}
		std::string initCodes = join(temp);
		if (assignSelf) {
			auto sjoin = [](const decltype(argItems)& items, int index) {
				std::string result;
				for (auto it = items.begin(); it != items.end(); ++it) {
					if (it->assignSelf.empty()) continue;
					if (result.empty()) result = (&it->name)[index];
					else result.append(s(", "sv) + (&it->name)[index]);
				}
				return result;
			};
			std::string sleft = sjoin(argItems, 1);
			std::string sright = sjoin(argItems, 0);
			initCodes.append(indent() + sleft + s(" = "sv) + sright + nll(argDefList));
		}
		out.push_back(varNames);
		out.push_back(initCodes);
	}

	void transformSelfName(SelfName_t* selfName, str_list& out, const ast_sel<false,Invoke_t,InvokeArgs_t>& invoke = {}) {
		auto x = selfName;
		auto name = selfName->name.get();
		switch (name->getId()) {
			case id<self_class_name_t>(): {
				auto clsName = static_cast<self_class_name_t*>(name);
				auto nameStr = _parser.toString(clsName->name);
				if (LuaKeywords.find(nameStr) != LuaKeywords.end()) {
					out.push_back(s("self.__class[\""sv) + nameStr + s("\"]"sv));
					if (invoke) {
						if (auto invokePtr = invoke.as<Invoke_t>()) {
							invokePtr->args.push_front(toAst<Exp_t>("self.__class"sv, x));
						} else {
							auto invokeArgsPtr = invoke.as<InvokeArgs_t>();
							invokeArgsPtr->args.push_front(toAst<Exp_t>("self.__class"sv, x));
						}
					}
				} else {
					out.push_back(s("self.__class"sv) + s(invoke ? ":"sv : "."sv) + nameStr);
				}
				break;
			}
			case id<self_class_t>():
				out.push_back(s("self.__class"sv));
				break;
			case id<self_name_t>(): {
				auto sfName = static_cast<self_class_name_t*>(name);
				auto nameStr = _parser.toString(sfName->name);
				if (LuaKeywords.find(nameStr) != LuaKeywords.end()) {
					out.push_back(s("self[\""sv) + nameStr + s("\"]"sv));
					if (invoke) {
						if (auto invokePtr = invoke.as<Invoke_t>()) {
							invokePtr->args.push_front(toAst<Exp_t>("self"sv, x));
						} else {
							auto invokeArgsPtr = invoke.as<InvokeArgs_t>();
							invokeArgsPtr->args.push_front(toAst<Exp_t>("self"sv, x));
						}
					}
				} else {
					out.push_back(s("self"sv) + s(invoke ? ":"sv : "."sv) + nameStr);
				}
				break;
			}
			case id<self_t>():
				out.push_back(s("self"sv));
				break;
			default: assert(false); break;
		}
	}

	bool transformChainEndWithEOP(const node_container& chainList, str_list& out, ExpUsage usage, ExpList_t* assignList) {
		auto x = chainList.front();
		if (ast_is<existential_op_t>(chainList.back())) {
			auto parens = x->new_ptr<Parens_t>();
			{
				auto chainValue = x->new_ptr<ChainValue_t>();
				for (auto item : chainList) {
					chainValue->items.push_back(item);
				}
				chainValue->items.pop_back();
				auto value = x->new_ptr<Value_t>();
				value->item.set(chainValue);
				auto opValue = x->new_ptr<exp_op_value_t>();
				opValue->op.set(toAst<BinaryOperator_t>("!="sv, x));
				opValue->value.set(toAst<Value_t>("nil"sv, x));
				auto exp = x->new_ptr<Exp_t>();
				exp->value.set(value);
				exp->opValues.push_back(opValue);
				parens->expr.set(exp);
			}
			switch (usage) {
				case ExpUsage::Assignment: {
					auto callable = x->new_ptr<Callable_t>();
					callable->item.set(parens);
					auto chainValue = x->new_ptr<ChainValue_t>();
					chainValue->items.push_back(callable);
					auto value = x->new_ptr<Value_t>();
					value->item.set(chainValue);
					auto exp = x->new_ptr<Exp_t>();
					exp->value.set(value);
					auto assignment = x->new_ptr<ExpListAssign_t>();
					assignment->expList.set(assignList);
					auto assign = x->new_ptr<Assign_t>();
					assign->values.push_back(exp);
					assignment->action.set(assign);
					transformAssignment(assignment, out);
					break;
				}
				case ExpUsage::Return:
					transformParens(parens, out);
					out.back().insert(0, indent() + s("return "sv));
					out.back().append(nlr(x));
					break;
				default:
					transformParens(parens, out);
					break;
			}
			return true;
		}
		return false;
	}

	bool transformChainWithEOP(const node_container& chainList, str_list& out, ExpUsage usage, ExpList_t* assignList) {
		auto opIt = std::find_if(chainList.begin(), chainList.end(), [](ast_node* node) { return ast_is<existential_op_t>(node); });
		if (opIt != chainList.end()) {
			auto x = chainList.front();
			str_list temp;
			if (usage == ExpUsage::Closure) {
				temp.push_back(s("(function()"sv) + nll(x));
				pushScope();
			}
			auto partOne = x->new_ptr<ChainValue_t>();
			for (auto it = chainList.begin();it != opIt;++it) {
				partOne->items.push_back(*it);
			}
			BLOCK_START
			auto back = ast_cast<Callable_t>(partOne->items.back());
			BREAK_IF(!back);
			auto selfName = ast_cast<SelfName_t>(back->item);
			BREAK_IF(!selfName);
			if (auto sname = ast_cast<self_name_t>(selfName->name)) {
				auto colonItem = x->new_ptr<ColonChainItem_t>();
				colonItem->name.set(sname->name);
				partOne->items.pop_back();
				partOne->items.push_back(toAst<Callable_t>("@"sv, x));
				partOne->items.push_back(colonItem);
				break;
			}
			if (auto cname = ast_cast<self_class_name_t>(selfName->name)) {
				auto colonItem = x->new_ptr<ColonChainItem_t>();
				colonItem->name.set(cname->name);
				partOne->items.pop_back();
				partOne->items.push_back(toAst<Callable_t>("@@"sv, x));
				partOne->items.push_back(colonItem);
				break;
			}
			BLOCK_END
			auto objVar = singleVariableFrom(partOne);
			if (objVar.empty()) {
				objVar = getUnusedName("_obj_"sv);
				if (auto colonItem = ast_cast<ColonChainItem_t>(partOne->items.back())) {
					auto chainValue = x->new_ptr<ChainValue_t>();
					chainValue->items.dup(partOne->items);
					chainValue->items.pop_back();
					if (chainValue->items.empty()) {
						if (_withVars.empty()) {
							throw std::logic_error(_info.errorMessage("short dot/colon syntax must be called within a with block"sv, x));
						}
					chainValue->items.push_back(toAst<Callable_t>(_withVars.top(), x));
					}
					auto newObj = singleVariableFrom(chainValue);
					if (!newObj.empty()) {
						objVar = newObj;
					} else {
						auto value = x->new_ptr<Value_t>();
						value->item.set(chainValue);
						auto exp = x->new_ptr<Exp_t>();
						exp->value.set(value);
						auto assign = x->new_ptr<Assign_t>();
						assign->values.push_back(exp);
						auto expListAssign = x->new_ptr<ExpListAssign_t>();
						expListAssign->expList.set(toAst<ExpList_t>(objVar, x));
						expListAssign->action.set(assign);
						transformAssignment(expListAssign, temp);
					}
					auto dotItem = x->new_ptr<DotChainItem_t>();
					auto name = colonItem->name.get();
					if (auto keyword = ast_cast<LuaKeyword_t>(name)) {
						name = keyword->name.get();
					}
					dotItem->name.set(name);
					partOne->items.clear();
					partOne->items.push_back(toAst<Callable_t>(objVar, x));
					partOne->items.push_back(dotItem);
					auto it = opIt; ++it;
					if (it != chainList.end() && ast_is<Invoke_t, InvokeArgs_t>(*it)) {

						if (auto invoke = ast_cast<Invoke_t>(*it)) {
							invoke->args.push_front(toAst<Exp_t>(objVar, x));
						} else {
							auto invokeArgs = static_cast<InvokeArgs_t*>(*it);
							invokeArgs->args.push_front(toAst<Exp_t>(objVar, x));
						}
					}
					objVar = getUnusedName("_obj_"sv);
				}
				auto value = x->new_ptr<Value_t>();
				value->item.set(partOne);
				auto exp = x->new_ptr<Exp_t>();
				exp->value.set(value);
				auto assign = x->new_ptr<Assign_t>();
				assign->values.push_back(exp);
				auto expListAssign = x->new_ptr<ExpListAssign_t>();
				expListAssign->expList.set(toAst<ExpList_t>(objVar, x));
				expListAssign->action.set(assign);
				transformAssignment(expListAssign, temp);
			}
			_buf << indent() << "if "sv << objVar << " ~= nil then"sv << nll(x);
			temp.push_back(clearBuf());
			pushScope();
			auto partTwo = x->new_ptr<ChainValue_t>();
			partTwo->items.push_back(toAst<Callable_t>(objVar, x));
			for (auto it = ++opIt;it != chainList.end();++it) {
				partTwo->items.push_back(*it);
			}
			switch (usage) {
				case ExpUsage::Common:
					transformChainValue(partTwo, temp, ExpUsage::Common);
					break;
				case ExpUsage::Assignment: {
					auto value = x->new_ptr<Value_t>();
					value->item.set(partTwo);
					auto exp = x->new_ptr<Exp_t>();
					exp->value.set(value);
					auto assign = x->new_ptr<Assign_t>();
					assign->values.push_back(exp);
					auto assignment = x->new_ptr<ExpListAssign_t>();
					assignment->expList.set(assignList);
					assignment->action.set(assign);
					transformAssignment(assignment, temp);
					break;
				}
				case ExpUsage::Return:
				case ExpUsage::Closure: {
					auto value = x->new_ptr<Value_t>();
					value->item.set(partTwo);
					auto exp = x->new_ptr<Exp_t>();
					exp->value.set(value);
					auto ret = x->new_ptr<Return_t>();
					auto expListLow = x->new_ptr<ExpListLow_t>();
					expListLow->exprs.push_back(exp);
					ret->valueList.set(expListLow);
					transformReturn(ret, temp);
					break;
				}
			}
			popScope();
			temp.push_back(indent() + s("end"sv) + nlr(x));
			switch (usage) {
				case ExpUsage::Return:
					temp.push_back(indent() + s("return nil"sv) + nlr(x));
					break;
				case ExpUsage::Closure:
					temp.push_back(indent() + s("return nil"sv) + nlr(x));
					popScope();
					temp.push_back(indent() + s("end)()"sv));
					break;
				default:
					break;
			}
			out.push_back(join(temp));
			return true;
		}
		return false;
	}

	bool transformChainEndWithColonItem(const node_container& chainList, str_list& out, ExpUsage usage, ExpList_t* assignList) {
		if (ast_is<ColonChainItem_t>(chainList.back())) {
			auto x = chainList.front();
			str_list temp;
			switch (usage) {
				case ExpUsage::Assignment:
					temp.push_back(indent() + s("do"sv) + nll(x));
					pushScope();
					break;
				case ExpUsage::Closure:
					temp.push_back(s("(function()"sv) + nll(x));
					pushScope();
					break;
				default:
					break;
			}
			auto baseChain = x->new_ptr<ChainValue_t>();
			switch (chainList.front()->getId()) {
				case id<DotChainItem_t>():
				case id<ColonChainItem_t>():
					if (_withVars.empty()) {
						throw std::logic_error(_info.errorMessage("short dot/colon syntax must be called within a with block"sv, chainList.front()));
					} else {
						baseChain->items.push_back(toAst<Callable_t>(_withVars.top(), x));
					}
					break;
			}
			auto end = --chainList.end();
			for (auto it = chainList.begin(); it != end; ++it) {
				baseChain->items.push_back(*it);
			}
			auto colonChainItem = static_cast<ColonChainItem_t*>(chainList.back());
			auto funcName = _parser.toString(colonChainItem->name);
			auto baseVar = getUnusedName("_base_"sv);
			auto fnVar = getUnusedName("_fn_"sv);
			{
				auto value = x->new_ptr<Value_t>();
				value->item.set(baseChain);
				auto exp = x->new_ptr<Exp_t>();
				exp->value.set(value);
				auto assign = x->new_ptr<Assign_t>();
				assign->values.push_back(exp);
				auto assignment = x->new_ptr<ExpListAssign_t>();
				assignment->expList.set(toAst<ExpList_t>(baseVar, x));
				assignment->action.set(assign);
				transformAssignment(assignment, temp);
			}
			{
				auto assign = x->new_ptr<Assign_t>();
				assign->values.push_back(toAst<Exp_t>(baseVar + "." + funcName, x));
				auto assignment = x->new_ptr<ExpListAssign_t>();
				assignment->expList.set(toAst<ExpList_t>(fnVar, x));
				assignment->action.set(assign);
				transformAssignment(assignment, temp);
			}
			auto funLit = toAst<Exp_t>(fnVar + s(" and (...)-> "sv) + fnVar + s(" "sv) + baseVar + s(", ..."sv), x);
			switch (usage) {
				case ExpUsage::Closure:
				case ExpUsage::Return: {
					auto returnNode = x->new_ptr<Return_t>();
					auto expListLow = x->new_ptr<ExpListLow_t>();
					expListLow->exprs.push_back(funLit);
					returnNode->valueList.set(expListLow);
					transformReturn(returnNode, temp);
					break;
				}
				case ExpUsage::Assignment: {
					auto assign = x->new_ptr<Assign_t>();
					assign->values.push_back(funLit);
					auto assignment = x->new_ptr<ExpListAssign_t>();
					assignment->expList.set(assignList);
					assignment->action.set(assign);
					transformAssignment(assignment, temp);
					break;
				}
				default:
					break;
			}
			switch (usage) {
				case ExpUsage::Assignment:
					popScope();
					temp.push_back(indent() + s("end"sv) + nlr(x));
					break;
				case ExpUsage::Closure:
					popScope();
					temp.push_back(indent() + s("end)()"sv));
					break;
				default:
					break;
			}
			out.push_back(join(temp));
			return true;
		}
		return false;
	}

	void transformChainList(const node_container& chainList, str_list& out, ExpUsage usage, ExpList_t* assignList = nullptr) {
		auto x = chainList.front();
		str_list temp;
		switch (x->getId()) {
			case id<DotChainItem_t>():
			case id<ColonChainItem_t>():
				if (_withVars.empty()) {
					throw std::logic_error(_info.errorMessage("short dot/colon syntax must be called within a with block"sv, x));
				} else {
					temp.push_back(_withVars.top());
				}
				break;
		}
		for (auto it = chainList.begin(); it != chainList.end(); ++it) {
			auto item = *it;
			switch (item->getId()) {
				case id<Invoke_t>():
					transformInvoke(static_cast<Invoke_t*>(item), temp);
					break;
				case id<DotChainItem_t>():
					transformDotChainItem(static_cast<DotChainItem_t*>(item), temp);
					break;
				case id<ColonChainItem_t>(): {
					auto colonItem = static_cast<ColonChainItem_t*>(item);
					auto current = it;
					auto next = current; ++next;
					auto followItem = next != chainList.end() ? *next : nullptr;
					if (current != chainList.begin()) {
						--current;
						if (!ast_is<existential_op_t>(*current)) {
							++current;
						}
					}
					if (ast_is<existential_op_t>(followItem)) {
						++next;
						followItem = next != chainList.end() ? *next : nullptr;
						--next;
					}
					if (!ast_is<Invoke_t, InvokeArgs_t>(followItem)) {
						throw std::logic_error(_info.errorMessage("colon chain item must be followed by invoke arguments"sv, colonItem));
					}
					if (colonItem->name.is<LuaKeyword_t>()) {
						std::string callVar;
						auto block = x->new_ptr<Block_t>();
						{
							auto chainValue = x->new_ptr<ChainValue_t>();
							switch (chainList.front()->getId()) {
								case id<DotChainItem_t>():
								case id<ColonChainItem_t>():
								chainValue->items.push_back(toAst<Callable_t>(_withVars.top(), x));
									break;
							}
							for (auto i = chainList.begin(); i != current; ++i) {
								chainValue->items.push_back(*i);
							}
							auto value = x->new_ptr<Value_t>();
							value->item.set(chainValue);
							auto exp = x->new_ptr<Exp_t>();
							exp->value.set(value);
							callVar = singleVariableFrom(exp);
							if (callVar.empty()) {
								callVar = getUnusedName(s("_call_"sv));
								auto assignment = x->new_ptr<ExpListAssign_t>();
								assignment->expList.set(toAst<ExpList_t>(callVar, x));
								auto assign = x->new_ptr<Assign_t>();
								assign->values.push_back(exp);
								assignment->action.set(assign);
								auto stmt = x->new_ptr<Statement_t>();
								stmt->content.set(assignment);
								block->statements.push_back(stmt);
							}
						}
						{
							auto name = _parser.toString(colonItem->name);
							auto chainValue = x->new_ptr<ChainValue_t>();
							chainValue->items.push_back(toAst<Callable_t>(callVar, x));
							if (ast_is<existential_op_t>(*current)) {
								chainValue->items.push_back(x->new_ptr<existential_op_t>());
							}
							chainValue->items.push_back(toAst<Exp_t>(s("\""sv) + name + s("\""sv), x));
							if (auto invoke = ast_cast<Invoke_t>(followItem)) {
								invoke->args.push_front(toAst<Exp_t>(callVar, x));
							} else {
								auto invokeArgs = static_cast<InvokeArgs_t*>(followItem);
								invokeArgs->args.push_front(toAst<Exp_t>(callVar, x));
							}
							for (auto i = next; i != chainList.end(); ++i) {
								chainValue->items.push_back(*i);
							}
							auto value = x->new_ptr<Value_t>();
							value->item.set(chainValue);
							auto exp = x->new_ptr<Exp_t>();
							exp->value.set(value);
							auto expList = x->new_ptr<ExpList_t>();
							expList->exprs.push_back(exp);
							auto expListAssign = x->new_ptr<ExpListAssign_t>();
							expListAssign->expList.set(expList);
							auto stmt = x->new_ptr<Statement_t>();
							stmt->content.set(expListAssign);
							block->statements.push_back(stmt);
						}
						switch (usage) {
							case ExpUsage::Common:
							case ExpUsage::Return:
								transformBlock(block, out, usage);
								return;
							case ExpUsage::Assignment: {
								transformBlock(block, out, ExpUsage::Assignment, assignList);
								return;
							}
							default:
								break;
						}
						auto body = x->new_ptr<Body_t>();
						body->content.set(block);
						auto funLit = toAst<FunLit_t>("->"sv, x);
						funLit->body.set(body);
						auto simpleValue = x->new_ptr<SimpleValue_t>();
						simpleValue->value.set(funLit);
						auto value = x->new_ptr<Value_t>();
						value->item.set(simpleValue);
						auto exp = x->new_ptr<Exp_t>();
						exp->value.set(value);
						auto paren = x->new_ptr<Parens_t>();
						paren->expr.set(exp);
						auto callable = x->new_ptr<Callable_t>();
						callable->item.set(paren);
						auto chainValue = x->new_ptr<ChainValue_t>();
						chainValue->items.push_back(callable);
						auto invoke = x->new_ptr<Invoke_t>();
						chainValue->items.push_back(invoke);
						transformChainValue(chainValue, out, ExpUsage::Closure);
						return;
					}
					transformColonChainItem(colonItem, temp);
					break;
				}
				case id<Slice_t>():
					transformSlice(static_cast<Slice_t*>(item), temp);
					break;
				case id<Callable_t>(): {
					auto next = it; ++next;
					auto followItem = next != chainList.end() ? *next : nullptr;
					ast_sel<false, Invoke_t, InvokeArgs_t> invoke;
					if (ast_is<Invoke_t, InvokeArgs_t>(followItem)) {
						invoke.set(followItem);
					}
					transformCallable(static_cast<Callable_t*>(item), temp, invoke);
					break;
				}
				case id<String_t>():
					transformString(static_cast<String_t*>(item), temp);
					temp.back() = s("("sv) + temp.back() + s(")"sv);
					break;
				case id<Exp_t>():
					transformExp(static_cast<Exp_t*>(item), temp, ExpUsage::Closure);
					temp.back() = s("["sv) + temp.back() + s("]"sv);
					break;
				case id<InvokeArgs_t>(): transformInvokeArgs(static_cast<InvokeArgs_t*>(item), temp); break;
				default: assert(false); break;
			}
		}
		switch (usage) {
			case ExpUsage::Common:
				out.push_back(indent() + join(temp) + nll(chainList.front()));
				break;
			case ExpUsage::Return:
				out.push_back(indent() + s("return "sv) + join(temp) + nll(chainList.front()));
				break;
			default:
				out.push_back(join(temp));
				break;
		}
	}

	std::pair<std::string,std::string> expandMacroStr(ChainValue_t* chainValue) {
		const auto& chainList = chainValue->items.objects();
		auto x = ast_to<Callable_t>(chainList.front())->item.to<MacroName_t>();
		auto macroName = _parser.toString(x->name);
		if (!_useModule) {
			throw std::logic_error(_info.errorMessage("can not resolve macro"sv, x));
		}
		pushCurrentModule(); // cur
		int top = lua_gettop(L) - 1;
		DEFER(lua_settop(L, top));
		lua_pushlstring(L, macroName.c_str(), macroName.size()); // cur macroName
		lua_rawget(L, -2); // cur[macroName], cur macro
		if (lua_istable(L, -1) == 0) {
			throw std::logic_error(_info.errorMessage("can not resolve macro"sv, x));
		}
		lua_rawgeti(L, -1, 1); // cur macro func
		pushMoonp("pcall"sv); // cur macro func pcall
		lua_insert(L, -2); // cur macro pcall func
		auto item = *(++chainList.begin());
		const node_container* args = nullptr;
		if (auto invoke = ast_cast<Invoke_t>(item)) {
			args = &invoke->args.objects();
		} else {
			args = &ast_to<InvokeArgs_t>(item)->args.objects();
		}
		for (auto arg : *args) {
			std::string str;
			if (auto exp = ast_cast<Exp_t>(arg)) {
				// patch for backcall operator support
				BLOCK_START
				BREAK_IF(arg->m_begin.m_line != arg->m_end.m_line ||
					arg->m_begin.m_col != arg->m_end.m_col);
				BREAK_IF(!exp->opValues.empty());
				auto chainValue = exp->getByPath<Value_t, ChainValue_t>();
				BREAK_IF(!chainValue);
				BREAK_IF(!isMacroChain(chainValue));
				BREAK_IF(chainValue->items.size() != 2);
				std::string type, codes;
				std::tie(type, codes) = expandMacroStr(chainValue);
				str = codes;
				BLOCK_END
				if (str.empty()) {
					bool multiLineStr = false;
					BLOCK_START
					auto value = singleValueFrom(exp);
					BREAK_IF(!value);
					auto lstr = value->getByPath<String_t, LuaString_t>();
					BREAK_IF(!lstr);
					str = _parser.toString(lstr->content);
					multiLineStr = true;
					BLOCK_END
					if (!multiLineStr) {
						// convert sub nodes to strings in case exp is assembled
						// in transform stage, the toString() function won't be able
						// to convert its whole content
						str = _parser.toString(exp->value);
						for (auto opVal : exp->opValues.objects()) {
							str += _parser.toString(opVal);
						}
					}
				}
			} else str = _parser.toString(arg);
			Utils::trim(str);
			Utils::replace(str, "\r\n"sv, "\n"sv);
			lua_pushlstring(L, str.c_str(), str.size());
		} // cur macro pcall func args...
		bool success = lua_pcall(L, static_cast<int>(args->size()) + 1, 2, 0) == 0;
		if (!success) { // cur macro err
			std::string err = lua_tostring(L, -1);
			throw std::logic_error(_info.errorMessage(s("fail to expand macro: "sv) + err, x));
		} // cur macro success res
		if (lua_toboolean(L, -2) == 0) {
			std::string err = lua_tostring(L, -1);
			throw std::logic_error(_info.errorMessage(s("fail to expand macro: "sv) + err, x));
		}
		lua_remove(L, -2); // cur macro res
		if (lua_isstring(L, -1) == 0) {
			throw std::logic_error(_info.errorMessage(s("macro function must return string with expanded codes"sv), x));
		} // cur macro codes
		lua_rawgeti(L, -2, 2); // cur macro codes type
		std::string type = lua_tostring(L, -1);
		std::string codes = lua_tostring(L, -2);
		return {type, codes};
	}

	std::tuple<ast_ptr<false,ast_node>, std::unique_ptr<input>, std::string> expandMacro(ChainValue_t* chainValue, ExpUsage usage, bool allowBlockMacroReturn) {
		auto x = ast_to<Callable_t>(chainValue->items.front())->item.to<MacroName_t>();
		const auto& chainList = chainValue->items.objects();
		std::string type, codes;
		std::tie(type, codes) = expandMacroStr(chainValue);
		std::string targetType(usage != ExpUsage::Common || chainList.size() > 2 ? "expr"sv : "block"sv);
		if (type == "lua"sv) {
			if (targetType != "block"sv) {
				throw std::logic_error(_info.errorMessage("lua macro can only be placed where block macro is allowed"sv, x));
			}
			auto macroChunk = s("=(macro "sv) + _parser.toString(x->name) + ')';
			int top = lua_gettop(L);
			DEFER(lua_settop(L, top));
			if (luaL_loadbuffer(L, codes.c_str(), codes.size(), macroChunk.c_str()) != 0) {
				std::string err = lua_tostring(L, -1);
				throw std::logic_error(_info.errorMessage(err, x));
			}
			return {nullptr, nullptr, std::move(codes)};
		} else if (!allowBlockMacroReturn && type != targetType) {
			throw std::logic_error(_info.errorMessage(s("macro type mismatch, "sv) + targetType + s(" expected, got "sv) + type, x));
		}
		ParseInfo info;
		if (usage == ExpUsage::Common) {
			if (codes.empty()) {
				return {x->new_ptr<Block_t>().get(), std::move(info.codes), Empty};
			}
			if (type == "expr"sv) {
				info = _parser.parse<Exp_t>(codes);
			} else {
				info = _parser.parse<Block_t>(codes);
			}
		} else if (allowBlockMacroReturn) {
			if (type == "expr"sv) {
				info = _parser.parse<Exp_t>(codes);
			} else {
				info = _parser.parse<Block_t>(codes);
			}
		} else {
			info = _parser.parse<Exp_t>(codes);
		}
		if (!info.node) {
			info.error = info.error.substr(info.error.find(':') + 2);
			throw std::logic_error(_info.errorMessage("fail to parse expanded codes: " + info.error, x));
		}
		int line = x->m_begin.m_line;
		int col = x->m_begin.m_col;
		info.node->traverse([&](ast_node* node) {
			node->m_begin.m_line = line;
			node->m_end.m_line = line;
			node->m_begin.m_col = col;
			node->m_end.m_col = col;
			return traversal::Continue;
		});
		if (type == "expr"sv) {
			ast_ptr<false, Exp_t> exp;
			exp.set(info.node);
			if (!exp->opValues.empty() || chainList.size() > 2) {
				auto paren = x->new_ptr<Parens_t>();
				paren->expr.set(exp);
				auto callable = x->new_ptr<Callable_t>();
				callable->item.set(paren);
				auto newChain = x->new_ptr<ChainValue_t>();
				newChain->items.push_back(callable);
				auto it = chainList.begin();
				it++; it++;
				for (; it != chainList.end(); ++it) {
					newChain->items.push_back(*it);
				}
				auto value = x->new_ptr<Value_t>();
				value->item.set(newChain);
				exp = x->new_ptr<Exp_t>();
				exp->value.set(value);
			}
			if (usage == ExpUsage::Common) {
				auto expList = x->new_ptr<ExpList_t>();
				expList->exprs.push_back(exp);
				auto exps = x->new_ptr<ExpListAssign_t>();
				exps->expList.set(expList);
				auto stmt = x->new_ptr<Statement_t>();
				stmt->content.set(exps);
				auto block = x->new_ptr<Block_t>();
				block->statements.push_back(stmt);
				info.node.set(block);
			} else {
				info.node.set(exp);
			}
		}
		return {info.node, std::move(info.codes), Empty};
	}

	void transformChainValue(ChainValue_t* chainValue, str_list& out, ExpUsage usage, ExpList_t* assignList = nullptr, bool allowBlockMacroReturn = false) {
		if (isMacroChain(chainValue)) {
			ast_ptr<false,ast_node> node;
			std::unique_ptr<input> codes;
			std::string luaCodes;
			std::tie(node, codes, luaCodes) = expandMacro(chainValue, usage, allowBlockMacroReturn);
			Utils::replace(luaCodes, "\r\n"sv, "\n"sv);
			Utils::trim(luaCodes);
			if (!node && !codes) {
				if (!luaCodes.empty()) {
					if (_config.reserveLineNumber) {
						luaCodes.insert(0, nll(chainValue).substr(1));
					}
					luaCodes.append(nlr(chainValue));
				}
				out.push_back(luaCodes);
				return;
			}
			if (usage == ExpUsage::Common || (usage == ExpUsage::Return && node.is<Block_t>())) {
				transformBlock(node.to<Block_t>(), out, usage, assignList);
			} else {
				auto x = chainValue;
				switch (usage) {
					case ExpUsage::Assignment: {
						auto assign = x->new_ptr<Assign_t>();
						assign->values.push_back(node);
						auto assignment = x->new_ptr<ExpListAssign_t>();
						assignment->expList.set(assignList);
						assignment->action.set(assign);
						transformAssignment(assignment, out);
						break;
					}
					case ExpUsage::Return: {
						auto expListLow = x->new_ptr<ExpListLow_t>();
						expListLow->exprs.push_back(node);
						auto returnNode = x->new_ptr<Return_t>();
						returnNode->valueList.set(expListLow);
						transformReturn(returnNode, out);
						break;
					}
					default:
						transformExp(node.to<Exp_t>(), out, usage);
						break;
				}
			}
			return;
		}
		const auto& chainList = chainValue->items.objects();
		if (transformChainEndWithEOP(chainList, out, usage, assignList)) {
			return;
		}
		if (transformChainWithEOP(chainList, out, usage, assignList)) {
			return;
		}
		if (transformChainEndWithColonItem(chainList, out, usage, assignList)) {
			return;
		}
		transformChainList(chainList, out, usage, assignList);
	}

	void transformAssignableChain(AssignableChain_t* chain, str_list& out) {
		transformChainList(chain->items.objects(), out, ExpUsage::Closure);
	}

	void transformDotChainItem(DotChainItem_t* dotChainItem, str_list& out) {
		auto name = _parser.toString(dotChainItem->name);
		if (Keywords.find(name) != Keywords.end()) {
			out.push_back(s("[\""sv) + name + s("\"]"sv));
		} else {
			out.push_back(s("."sv) + name);
		}
	}

	void transformColonChainItem(ColonChainItem_t* colonChainItem, str_list& out) {
		auto name = _parser.toString(colonChainItem->name);
		out.push_back(s(colonChainItem->switchToDot ? "."sv : ":"sv) + name);
	}

	void transformSlice(Slice_t* slice, str_list&) {
		throw std::logic_error(_info.errorMessage("slice syntax not supported here"sv, slice));
	}

	void transformInvoke(Invoke_t* invoke, str_list& out) {
		str_list temp;
		for (auto arg : invoke->args.objects()) {
			switch (arg->getId()) {
				case id<Exp_t>(): transformExp(static_cast<Exp_t*>(arg), temp, ExpUsage::Closure); break;
				case id<SingleString_t>(): transformSingleString(static_cast<SingleString_t*>(arg), temp); break;
				case id<DoubleString_t>(): transformDoubleString(static_cast<DoubleString_t*>(arg), temp); break;
				case id<LuaString_t>(): transformLuaString(static_cast<LuaString_t*>(arg), temp); break;
				default: assert(false); break;
			}
		}
		out.push_back(s("("sv) + join(temp, ", "sv) + s(")"sv));
	}

	void transform_unary_exp(unary_exp_t* unary_exp, str_list& out) {
		std::string op = _parser.toString(unary_exp->m_begin.m_it, unary_exp->item->m_begin.m_it);
		str_list temp{op + (op == "not"sv ? s(" "sv) : Empty)};
		transformExp(unary_exp->item, temp, ExpUsage::Closure);
		out.push_back(join(temp));
	}

	void transformVariable(Variable_t* name, str_list& out) {
		out.push_back(_parser.toString(name));
	}

	void transformNum(Num_t* num, str_list& out) {
		out.push_back(_parser.toString(num));
	}

	void transformTableLit(TableLit_t* table, str_list& out) {
		transformTable(table, table->values.objects(), out);
	}

	void transformCompCommon(Comprehension_t* comp, str_list& out) {
		str_list temp;
		auto x = comp;
		auto compInner = comp->forLoop.get();
		for (auto item : compInner->items.objects()) {
			switch (item->getId()) {
				case id<CompForEach_t>():
					transformCompForEach(static_cast<CompForEach_t*>(item), temp);
					break;
				case id<CompFor_t>():
					transformCompFor(static_cast<CompFor_t*>(item), temp);
					break;
				case id<Exp_t>():
					transformExp(static_cast<Exp_t*>(item), temp, ExpUsage::Closure);
					temp.back() = indent() + s("if "sv) + temp.back() + s(" then"sv) + nll(item);
					pushScope();
					break;
				default: assert(false); break;
			}
		}
		if (auto stmt = comp->value.as<Statement_t>()) {
			transformStatement(stmt, temp);
		} else if (auto exp = comp->value.as<Exp_t>()) {
			auto expList = x->new_ptr<ExpList_t>();
			expList->exprs.push_back(exp);
			auto expListAssign = x->new_ptr<ExpListAssign_t>();
			expListAssign->expList.set(expList);
			auto statement = x->new_ptr<Statement_t>();
			statement->content.set(expListAssign);
			transformStatement(statement, temp);
		}
		auto value = temp.back();
		temp.pop_back();
		_buf << join(temp) << value;
		for (size_t i = 0; i < compInner->items.objects().size(); ++i) {
			popScope();
			_buf << indent() << "end"sv << nll(comp);
		}
		out.push_back(clearBuf());
	}

	void transformComprehension(Comprehension_t* comp, str_list& out, ExpUsage usage, ExpList_t* assignList = nullptr) {
		auto x = comp;
		switch (usage) {
			case ExpUsage::Closure:
			case ExpUsage::Assignment:
				pushScope();
				break;
			default:
				break;
		}
		str_list temp;
		std::string accumVar = getUnusedName("_accum_"sv);
		std::string lenVar = getUnusedName("_len_"sv);
		addToScope(accumVar);
		addToScope(lenVar);
		auto compInner = comp->forLoop.get();
		for (auto item : compInner->items.objects()) {
			switch (item->getId()) {
				case id<CompForEach_t>():
					transformCompForEach(static_cast<CompForEach_t*>(item), temp);
					break;
				case id<CompFor_t>():
					transformCompFor(static_cast<CompFor_t*>(item), temp);
					break;
				case id<Exp_t>():
					transformExp(static_cast<Exp_t*>(item), temp, ExpUsage::Closure);
					temp.back() = indent() + s("if "sv) + temp.back() + s(" then"sv) + nll(item);
					pushScope();
					break;
				default: assert(false); break;
			}
		}
		{
			auto assignLeft = toAst<ExpList_t>(accumVar + s("["sv) + lenVar + s("]"sv), x);
			auto assign = x->new_ptr<Assign_t>();
			assign->values.push_back(comp->value);
			auto assignment = x->new_ptr<ExpListAssign_t>();
			assignment->expList.set(assignLeft);
			assignment->action.set(assign);
			transformAssignment(assignment, temp);
		}
		auto assignStr = temp.back();
		temp.pop_back();
		for (size_t i = 0; i < compInner->items.objects().size(); ++i) {
			popScope();
		}
		_buf << indent() << "local "sv << accumVar << " = { }"sv << nll(comp);
		_buf << indent() << "local "sv << lenVar << " = 1"sv << nll(comp);
		_buf << join(temp);
		_buf << assignStr;
		_buf << indent(int(temp.size())) << lenVar << " = "sv << lenVar << " + 1"sv << nll(comp);
		for (int ind = int(temp.size()) - 1; ind > -1; --ind) {
			_buf << indent(ind) << "end"sv << nll(comp);
		}
		switch (usage) {
			case ExpUsage::Common:
				break;
			case ExpUsage::Closure: {
				out.push_back(clearBuf());
				out.back().append(indent() + s("return "sv) + accumVar + nlr(comp));
				popScope();
				out.back().insert(0, s("(function()"sv) + nll(comp));
				out.back().append(indent() + s("end)()"sv));
				break;
			}
			case ExpUsage::Assignment: {
				out.push_back(clearBuf());
				auto assign = x->new_ptr<Assign_t>();
				assign->values.push_back(toAst<Exp_t>(accumVar, x));
				auto assignment = x->new_ptr<ExpListAssign_t>();
				assignment->expList.set(assignList);
				assignment->action.set(assign);
				transformAssignment(assignment, temp);
				popScope();
				out.back() = indent() + s("do"sv) + nll(comp) +
					out.back() + temp.back() +
					indent() + s("end"sv) + nlr(comp);
				break;
			}
			case ExpUsage::Return:
				out.push_back(clearBuf());
				out.back().append(indent() + s("return "sv) + accumVar + nlr(comp));
				break;
			default:
				break;
		}
	}

	void transformForEachHead(AssignableNameList_t* nameList, ast_node* loopTarget, str_list& out) {
		auto x = nameList;
		str_list temp;
		str_list vars;
		str_list varBefore, varAfter;
		std::list<std::pair<ast_node*, ast_ptr<false, ast_node>>> destructPairs;
		for (auto _item : nameList->items.objects()) {
			auto item = static_cast<NameOrDestructure_t*>(_item)->item.get();
			switch (item->getId()) {
				case id<Variable_t>():
					transformVariable(static_cast<Variable_t*>(item), vars);
					varAfter.push_back(vars.back());
					break;
				case id<TableLit_t>(): {
					auto desVar = getUnusedName("_des_"sv);
					destructPairs.emplace_back(item, toAst<Exp_t>(desVar, x));
					vars.push_back(desVar);
					varAfter.push_back(desVar);
					break;
				}
				default: assert(false); break;
			}
		}
		switch (loopTarget->getId()) {
			case id<star_exp_t>(): {
				auto star_exp = static_cast<star_exp_t*>(loopTarget);
				auto listVar = singleVariableFrom(star_exp->value);
				auto indexVar = getUnusedName("_index_"sv);
				varAfter.push_back(indexVar);
				auto value = singleValueFrom(star_exp->value);
				if (!value) throw std::logic_error(_info.errorMessage("invalid star syntax"sv, star_exp));
				bool endWithSlice = false;
				BLOCK_START
				auto chainValue = value->item.as<ChainValue_t>();
				BREAK_IF(!chainValue);
				auto chainList = chainValue->items.objects();
				auto slice = ast_cast<Slice_t>(chainList.back());
				BREAK_IF(!slice);
				endWithSlice = true;
				if (listVar.empty() && chainList.size() == 2 &&
					ast_is<Callable_t>(chainList.front())) {
					transformCallable(static_cast<Callable_t*>(chainList.front()), temp);
					listVar = temp.back();
					temp.pop_back();
				}
				chainList.pop_back();
				auto chain = x->new_ptr<ChainValue_t>();
				for (auto item : chainList) {
					chain->items.push_back(item);
				}
				std::string startValue("1"sv);
				if (auto exp = slice->startValue.as<Exp_t>()) {
					transformExp(exp, temp, ExpUsage::Closure);
					startValue = temp.back();
					temp.pop_back();
				}
				std::string stopValue;
				if (auto exp = slice->stopValue.as<Exp_t>()) {
					transformExp(exp, temp, ExpUsage::Closure);
					stopValue = temp.back();
					temp.pop_back();
				}
				std::string stepValue;
				if (auto exp = slice->stepValue.as<Exp_t>()) {
					transformExp(exp, temp, ExpUsage::Closure);
					stepValue = temp.back();
					temp.pop_back();
				}
				if (listVar.empty()) {
					listVar = getUnusedName("_list_"sv);
					varBefore.push_back(listVar);
					transformChainValue(chain, temp, ExpUsage::Closure);
					_buf << indent() << "local "sv << listVar << " = "sv << temp.back() << nll(nameList);
				}
				std::string maxVar;
				if (!stopValue.empty()) {
					maxVar = getUnusedName("_max_"sv);
					varBefore.push_back(maxVar);
					_buf << indent() << "local "sv << maxVar << " = "sv << stopValue << nll(nameList);
				}
				_buf << indent() << "for "sv << indexVar << " = "sv;
				_buf << startValue << ", "sv;
				if (stopValue.empty()) {
					_buf << "#"sv << listVar;
				} else {
					_buf << maxVar << " < 0 and #"sv << listVar << " + "sv << maxVar << " or "sv << maxVar;
				}
				if (!stepValue.empty()) {
					_buf << ", "sv << stepValue;
				}
				_buf << " do"sv << nlr(loopTarget);
				_buf << indent(1) << "local "sv << join(vars, ", "sv) << " = "sv << listVar << "["sv << indexVar << "]"sv << nll(nameList);
				out.push_back(clearBuf());
				BLOCK_END
				bool newListVal = false;
				if (listVar.empty()) {
					newListVal = true;
					listVar = getUnusedName("_list_"sv);
					varBefore.push_back(listVar);
				}
				if (!endWithSlice) {
					transformExp(star_exp->value, temp, ExpUsage::Closure);
					if (newListVal) _buf << indent() << "local "sv << listVar << " = "sv << temp.back() << nll(nameList);
					_buf << indent() << "for "sv << indexVar << " = 1, #"sv << listVar << " do"sv << nlr(loopTarget);
					_buf << indent(1) << "local "sv << join(vars) << " = "sv << listVar << "["sv << indexVar << "]"sv << nll(nameList);
					out.push_back(clearBuf());
				}
				break;
			}
			case id<Exp_t>():
				transformExp(static_cast<Exp_t*>(loopTarget), temp, ExpUsage::Closure);
				_buf << indent() << "for "sv << join(vars, ", "sv) << " in "sv << temp.back() << " do"sv << nlr(loopTarget);
				out.push_back(clearBuf());
				break;
			case id<ExpList_t>():
				transformExpList(static_cast<ExpList_t*>(loopTarget), temp);
				_buf << indent() << "for "sv << join(vars, ", "sv) << " in "sv << temp.back() << " do"sv << nlr(loopTarget);
				out.push_back(clearBuf());
				break;
			default: assert(false); break;
		}
		for (auto& var : varBefore) addToScope(var);
		pushScope();
		for (auto& var : varAfter) addToScope(var);
		if (!destructPairs.empty()) {
			temp.clear();
			for (auto& pair : destructPairs) {
				auto sValue = x->new_ptr<SimpleValue_t>();
				sValue->value.set(pair.first);
				auto value = x->new_ptr<Value_t>();
				value->item.set(sValue);
				auto exp = x->new_ptr<Exp_t>();
				exp->value.set(value);
				auto expList = x->new_ptr<ExpList_t>();
				expList->exprs.push_back(exp);
				auto assign = x->new_ptr<Assign_t>();
				assign->values.push_back(pair.second);
				auto assignment = x->new_ptr<ExpListAssign_t>();
				assignment->expList.set(expList);
				assignment->action.set(assign);
				transformAssignment(assignment, temp);
			}
			out.back().append(join(temp));
		}
	}

	void transformCompForEach(CompForEach_t* comp, str_list& out) {
		transformForEachHead(comp->nameList, comp->loopValue, out);
	}

	void transformInvokeArgs(InvokeArgs_t* invokeArgs, str_list& out) {
		str_list temp;
		for (auto arg : invokeArgs->args.objects()) {
			switch (arg->getId()) {
				case id<Exp_t>(): transformExp(static_cast<Exp_t*>(arg), temp, ExpUsage::Closure); break;
				case id<TableBlock_t>(): transformTableBlock(static_cast<TableBlock_t*>(arg), temp); break;
				default: assert(false); break;
			}
		}
		out.push_back(s("("sv) + join(temp, ", "sv) + s(")"sv));
	}

	void transformForHead(For_t* forNode, str_list& out) {
		str_list temp;
		std::string varName = _parser.toString(forNode->varName);
		transformExp(forNode->startValue, temp, ExpUsage::Closure);
		transformExp(forNode->stopValue, temp, ExpUsage::Closure);
		if (forNode->stepValue) {
			transformExp(forNode->stepValue->value, temp, ExpUsage::Closure);
		} else {
			temp.emplace_back();
		}
		auto it = temp.begin();
		const auto& start = *it;
		const auto& stop = *(++it);
		const auto& step = *(++it);
		_buf << indent() << "for "sv << varName << " = "sv << start << ", "sv << stop << (step.empty() ? Empty : s(", "sv) + step) << " do"sv << nll(forNode);
		pushScope();
		addToScope(varName);
		out.push_back(clearBuf());
	}

	void transformLoopBody(Body_t* body, str_list& out, const std::string& appendContent, ExpUsage usage, ExpList_t* assignList = nullptr) {
		str_list temp;
		bool withContinue = traversal::Stop == body->traverse([&](ast_node* node) {
			switch (node->getId()) {
				case id<For_t>():
				case id<ForEach_t>():
					return traversal::Return;
				case id<BreakLoop_t>(): {
					return _parser.toString(node) == "continue"sv ?
						traversal::Stop : traversal::Return;
				}
				default:
					return traversal::Continue;
			}
		});
		if (withContinue) {
			auto continueVar = getUnusedName("_continue_"sv);
			addToScope(continueVar);
			_buf << indent() << "local "sv << continueVar << " = false"sv << nll(body);
			_buf << indent() << "repeat"sv << nll(body);
			temp.push_back(clearBuf());
			_continueVars.push(continueVar);
			pushScope();
		}
		transformBody(body, temp, usage, assignList);
		if (withContinue) {
			if (!appendContent.empty()) {
				_buf << indent() << appendContent;
			}
			_buf << indent() << _continueVars.top() << " = true"sv << nll(body);
			popScope();
			_buf << indent() << "until true"sv << nlr(body);
			_buf << indent() << "if not "sv << _continueVars.top() << " then"sv << nlr(body);
			_buf << indent(1) << "break"sv << nlr(body);
			_buf << indent() << "end"sv << nlr(body);
			temp.push_back(clearBuf());
			_continueVars.pop();
		} else if (!appendContent.empty()) {
			temp.back().append(indent() + appendContent);
		}
		out.push_back(join(temp));
	}

	void transformFor(For_t* forNode, str_list& out) {
		str_list temp;
		transformForHead(forNode, temp);
		transformLoopBody(forNode->body, temp, Empty, ExpUsage::Common);
		popScope();
		out.push_back(join(temp) + indent() + s("end"sv) + nlr(forNode));
	}

	std::string transformForInner(For_t* forNode, str_list& out) {
		auto x = forNode;
		std::string accum = getUnusedName("_accum_"sv);
		addToScope(accum);
		std::string len = getUnusedName("_len_"sv);
		addToScope(len);
		_buf << indent() << "local "sv << accum << " = { }"sv << nll(forNode);
		_buf << indent() << "local "sv << len << " = 1"sv << nll(forNode);
		out.push_back(clearBuf());
		transformForHead(forNode, out);
		auto expList = toAst<ExpList_t>(accum + s("["sv) + len + s("]"sv), x);
		auto lenLine = len + s(" = "sv) + len + s(" + 1"sv) + nlr(forNode->body);
		transformLoopBody(forNode->body, out, lenLine, ExpUsage::Assignment, expList);
		popScope();
		out.push_back(indent() + s("end"sv) + nlr(forNode));
		return accum;
	}

	void transformForClosure(For_t* forNode, str_list& out) {
		str_list temp;
		_buf << "(function()"sv << nll(forNode);
		pushScope();
		auto accum = transformForInner(forNode, temp);
		temp.push_back(indent() + s("return "sv) + accum + nlr(forNode));
		popScope();
		temp.push_back(indent() + s("end)()"sv));
		out.push_back(join(temp));
	}

	void transformForInPlace(For_t* forNode,  str_list& out, ExpList_t* assignExpList = nullptr) {
		auto x = forNode;
		str_list temp;
		if (assignExpList) {
			_buf << indent() << "do"sv << nll(forNode);
			pushScope();
			auto accum = transformForInner(forNode, temp);
			auto assign = x->new_ptr<Assign_t>();
			assign->values.push_back(toAst<Exp_t>(accum, x));
			auto assignment = x->new_ptr<ExpListAssign_t>();
			assignment->expList.set(assignExpList);
			assignment->action.set(assign);
			transformAssignment(assignment, temp);
			popScope();
			temp.push_back(indent() + s("end"sv) + nlr(forNode));
		} else {
			auto accum = transformForInner(forNode, temp);
			auto returnNode = x->new_ptr<Return_t>();
			auto expListLow = toAst<ExpListLow_t>(accum, x);
			returnNode->valueList.set(expListLow);
			transformReturn(returnNode, temp);
		}
		out.push_back(join(temp));
	}

	void transformBinaryOperator(BinaryOperator_t* node, str_list& out) {
		auto op = _parser.toString(node);
		out.push_back(op == "!="sv ? s("~="sv) : op);
	}

	void transformForEach(ForEach_t* forEach, str_list& out) {
		str_list temp;
		transformForEachHead(forEach->nameList, forEach->loopValue, temp);
		transformLoopBody(forEach->body, temp, Empty, ExpUsage::Common);
		popScope();
		out.push_back(temp.front() + temp.back() + indent() + s("end"sv) + nlr(forEach));
	}

	std::string transformForEachInner(ForEach_t* forEach, str_list& out) {
		auto x = forEach;
		std::string accum = getUnusedName("_accum_"sv);
		addToScope(accum);
		std::string len = getUnusedName("_len_"sv);
		addToScope(len);
		_buf << indent() << "local "sv << accum << " = { }"sv << nll(forEach);
		_buf << indent() << "local "sv << len << " = 1"sv << nll(forEach);
		out.push_back(clearBuf());
		transformForEachHead(forEach->nameList, forEach->loopValue, out);
		auto expList = toAst<ExpList_t>(accum + s("["sv) + len + s("]"sv), x);
		auto lenLine = len + s(" = "sv) + len + s(" + 1"sv) + nlr(forEach->body);
		transformLoopBody(forEach->body, out, lenLine, ExpUsage::Assignment, expList);
		popScope();
		out.push_back(indent() + s("end"sv) + nlr(forEach));
		return accum;
	}

	void transformForEachClosure(ForEach_t* forEach, str_list& out) {
		str_list temp;
		_buf << "(function()"sv << nll(forEach);
		pushScope();
		auto accum = transformForEachInner(forEach, temp);
		temp.push_back(indent() + s("return "sv) + accum + nlr(forEach));
		popScope();
		temp.push_back(indent() + s("end)()"sv));
		out.push_back(join(temp));
	}

	void transformForEachInPlace(ForEach_t* forEach,  str_list& out, ExpList_t* assignExpList = nullptr) {
		auto x = forEach;
		str_list temp;
		if (assignExpList) {
			_buf << indent() << "do"sv << nll(forEach);
			pushScope();
			auto accum = transformForEachInner(forEach, temp);
			auto assign = x->new_ptr<Assign_t>();
			assign->values.push_back(toAst<Exp_t>(accum, x));
			auto assignment = x->new_ptr<ExpListAssign_t>();
			assignment->expList.set(assignExpList);
			assignment->action.set(assign);
			transformAssignment(assignment, temp);
			popScope();
			temp.push_back(indent() + s("end"sv) + nlr(forEach));
		} else {
			auto accum = transformForEachInner(forEach, temp);
			auto returnNode = x->new_ptr<Return_t>();
			auto expListLow = toAst<ExpListLow_t>(accum, x);
			returnNode->valueList.set(expListLow);
			transformReturn(returnNode, temp);
		}
		out.push_back(join(temp));
	}

	void transform_variable_pair(variable_pair_t* pair, str_list& out) {
		auto name = _parser.toString(pair->name);
		out.push_back(name + s(" = "sv) + name);
	}

	void transform_normal_pair(normal_pair_t* pair, str_list& out) {
		auto key = pair->key.get();
		str_list temp;
		switch (key->getId()) {
			case id<KeyName_t>(): {
				transformKeyName(static_cast<KeyName_t*>(key), temp);
				if (LuaKeywords.find(temp.back()) != LuaKeywords.end()) {
					temp.back() = s("[\""sv) + temp.back() + s("\"]");
				}
				break;
			}
			case id<Exp_t>():
				transformExp(static_cast<Exp_t*>(key), temp, ExpUsage::Closure);
				temp.back() = s("["sv) + temp.back() + s("]"sv);
				break;
			case id<DoubleString_t>():
				transformDoubleString(static_cast<DoubleString_t*>(key), temp);
				temp.back() = s("["sv) + temp.back() + s("]"sv);
				break;
			case id<SingleString_t>(): transformSingleString(static_cast<SingleString_t*>(key), temp);
				temp.back() = s("["sv) + temp.back() + s("]"sv);
				break;
			default: assert(false); break;
		}
		auto value = pair->value.get();
		switch (value->getId()) {
			case id<Exp_t>(): transformExp(static_cast<Exp_t*>(value), temp, ExpUsage::Closure); break;
			case id<TableBlock_t>(): transformTableBlock(static_cast<TableBlock_t*>(value), temp); break;
			default: assert(false); break;
		}
		out.push_back(temp.front() + s(" = "sv) + temp.back());
	}

	void transformKeyName(KeyName_t* keyName, str_list& out) {
		auto name = keyName->name.get();
		switch (name->getId()) {
			case id<SelfName_t>(): transformSelfName(static_cast<SelfName_t*>(name), out); break;
			case id<Name_t>(): out.push_back(_parser.toString(name)); break;
			default: assert(false); break;
		}
	}

	void transformLuaString(LuaString_t* luaString, str_list& out) {
		auto content = _parser.toString(luaString->content);
		Utils::replace(content, "\r\n"sv, "\n");
		if (content[0] == '\n') content.erase(content.begin());
		out.push_back(_parser.toString(luaString->open) + content + _parser.toString(luaString->close));
	}

	void transformSingleString(SingleString_t* singleString, str_list& out) {
		auto str = _parser.toString(singleString);
		Utils::replace(str, "\r\n"sv, "\n");
		Utils::replace(str, "\n"sv, "\\n"sv);
		out.push_back(str);
	}

	void transformDoubleString(DoubleString_t* doubleString, str_list& out) {
		str_list temp;
		for (auto _seg : doubleString->segments.objects()) {
			auto seg = static_cast<double_string_content_t*>(_seg);
			auto content = seg->content.get();
			switch (content->getId()) {
				case id<double_string_inner_t>(): {
					auto str = _parser.toString(content);
					Utils::replace(str, "\r\n"sv, "\n");
					Utils::replace(str, "\n"sv, "\\n"sv);
					temp.push_back(s("\""sv) + str + s("\""sv));
					break;
				}
				case id<Exp_t>():
					transformExp(static_cast<Exp_t*>(content), temp, ExpUsage::Closure);
					temp.back() = s("tostring("sv) + temp.back() + s(")"sv);
					break;
				default: assert(false); break;
			}
		}
		out.push_back(temp.empty() ? s("\"\""sv) : join(temp, " .. "sv));
	}

	void transformString(String_t* string, str_list& out) {
		auto str = string->str.get();
		switch (str->getId()) {
			case id<SingleString_t>(): transformSingleString(static_cast<SingleString_t*>(str), out); break;
			case id<DoubleString_t>(): transformDoubleString(static_cast<DoubleString_t*>(str), out); break;
			case id<LuaString_t>(): transformLuaString(static_cast<LuaString_t*>(str), out); break;
			default: assert(false); break;
		}
	}

	std::pair<std::string,bool> defineClassVariable(Assignable_t* assignable) {
		if (auto variable = assignable->item.as<Variable_t>()) {
			auto name = _parser.toString(variable);
			if (addToScope(name)) {
				return {name, true};
			} else {
				return {name, false};
			}
		}
		return {Empty, false};
	}

	void transformClassDeclClosure(ClassDecl_t* classDecl, str_list& out) {
		str_list temp;
		temp.push_back(s("(function()"sv) + nll(classDecl));
		pushScope();
		transformClassDecl(classDecl, temp, ExpUsage::Return);
		popScope();
		temp.push_back(s("end)()"sv));
		out.push_back(join(temp));
	}

	void transformClassDecl(ClassDecl_t* classDecl, str_list& out, ExpUsage usage, ExpList_t* expList = nullptr) {
		str_list temp;
		auto x = classDecl;
		auto body = classDecl->body.get();
		auto assignable = classDecl->name.get();
		auto extend = classDecl->extend.get();
		std::string className;
		std::string assignItem;
		if (assignable) {
			if (!isAssignable(assignable)) {
				throw std::logic_error(_info.errorMessage("left hand expression is not assignable"sv, assignable));
			}
			bool newDefined = false;
			std::tie(className, newDefined) = defineClassVariable(assignable);
			if (newDefined) {
				temp.push_back(indent() + s("local "sv) + className + nll(classDecl));
			}
			if (className.empty()) {
				if (auto chain = ast_cast<AssignableChain_t>(assignable->item)) {
					if (auto dotChain = ast_cast<DotChainItem_t>(chain->items.back())) {
						className = s("\""sv) + _parser.toString(dotChain->name) + s("\""sv);
					} else if (auto index = ast_cast<Exp_t>(chain->items.back())) {
						if (auto name = index->getByPath<Value_t, String_t>()) {
							transformString(name, temp);
							className = temp.back();
							temp.pop_back();
						}
					}
				}
			} else {
				className = s("\""sv) + className + s("\""sv);
			}
			pushScope();
			transformAssignable(assignable, temp);
			popScope();
			assignItem = temp.back();
			temp.pop_back();
		} else if (expList) {
			auto name = singleVariableFrom(expList);
			if (!name.empty()) {
				className = s("\""sv) + name + s("\""sv);
			}
		}
		temp.push_back(indent() + s("do"sv) + nll(classDecl));
		pushScope();
		auto classVar = getUnusedName("_class_"sv);
		addToScope(classVar);
		temp.push_back(indent() + s("local "sv) + classVar + nll(classDecl));
		if (body) {
			str_list varDefs;
			for (auto item : body->contents.objects()) {
				if (auto statement = ast_cast<Statement_t>(item)) {
					ClassDecl_t* clsDecl = nullptr;
					if (auto assignment = assignmentFrom(statement)) {
						auto names = transformAssignDefs(assignment->expList.get());
						varDefs.insert(varDefs.end(), names.begin(), names.end());
						auto info = extractDestructureInfo(assignment, true);
						if (!info.first.empty()) {
							for (const auto& destruct : info.first)
								for (const auto& item : destruct.items)
									if (item.isVariable && addToScope(item.name))
										varDefs.push_back(item.name);
						}
						BLOCK_START
						auto assign = assignment->action.as<Assign_t>();
						BREAK_IF(!assign);
						BREAK_IF(assign->values.objects().size() != 1);
						auto exp = ast_cast<Exp_t>(assign->values.objects().front());
						BREAK_IF(!exp);
						auto value = singleValueFrom(exp);
						clsDecl = value->getByPath<SimpleValue_t, ClassDecl_t>();
						BLOCK_END
					} else if (auto expList = expListFrom(statement)) {
						auto value = singleValueFrom(expList);
						clsDecl = value->getByPath<SimpleValue_t, ClassDecl_t>();
					}
					if (clsDecl) {
						std::string clsName;
						bool newDefined = false;
						std::tie(clsName,newDefined) = defineClassVariable(clsDecl->name);
						if (newDefined) varDefs.push_back(clsName);
					}
				}
			}
			if (!varDefs.empty()) {
				temp.push_back(indent() + s("local "sv) + join(varDefs, ", "sv) + nll(body));
			}
		}
		std::string parent, parentVar;
		if (extend) {
			parentVar = getUnusedName("_parent_"sv);
			addToScope(parentVar);
			transformExp(extend, temp, ExpUsage::Closure);
			parent = temp.back();
			temp.pop_back();
			temp.push_back(indent() + s("local "sv) + parentVar + s(" = "sv) + parent + nll(classDecl));
		}
		auto baseVar = getUnusedName("_base_"sv);
		addToScope(baseVar);
		temp.push_back(indent() + s("local "sv) + baseVar + s(" = "sv));
		str_list builtins;
		str_list commons;
		str_list statements;
		if (body) {
			std::list<ClassMember> members;
			for (auto content : classDecl->body->contents.objects()) {
				switch (content->getId()) {
					case id<class_member_list_t>(): {
						size_t inc = transform_class_member_list(static_cast<class_member_list_t*>(content), members, classVar);
						auto it = members.end();
						for (size_t i = 0; i < inc; ++i, --it);
						for (; it != members.end(); ++it) {
							auto& member = *it;
							if (member.type == MemType::Property) {
								statements.push_back(indent() + member.item + nll(content));
							} else {
								member.item = indent(1) + member.item;
							}
						}
						break;
					}
					case id<Statement_t>():
						transformStatement(static_cast<Statement_t*>(content), statements);
						break;
					default: assert(false); break;
				}
			}
			for (auto& member : members) {
				switch (member.type) {
					case MemType::Common:
						commons.push_back((commons.empty() ? Empty : s(","sv) + nll(member.node)) + member.item);
						break;
					case MemType::Builtin:
						builtins.push_back((builtins.empty() ? Empty : s(","sv) + nll(member.node)) + member.item);
						break;
					default: break;
				}
			}
			if (!commons.empty()) {
				temp.back() += s("{"sv) + nll(body);
				temp.push_back(join(commons) + nll(body));
				temp.push_back(indent() + s("}"sv) + nll(body));
			} else {
				temp.back() += s("{ }"sv) + nll(body);
			}
		} else {
			temp.back() += s("{ }"sv) + nll(classDecl);
		}
		temp.push_back(indent() + baseVar + s(".__index = "sv) + baseVar + nll(classDecl));
		str_list tmp;
		if (usage == ExpUsage::Assignment) {
			auto assign = x->new_ptr<Assign_t>();
			assign->values.push_back(toAst<Exp_t>(classVar, x));
			auto assignment = x->new_ptr<ExpListAssign_t>();
			assignment->expList.set(expList);
			assignment->action.set(assign);
			transformAssignment(assignment, tmp);
		}
		if (extend) {
			_buf << indent() << "setmetatable("sv << baseVar << ", "sv << parentVar << ".__base)"sv << nll(classDecl);
		}
		_buf << indent() << classVar << " = setmetatable({"sv << nll(classDecl);
		if (!builtins.empty()) {
			_buf << join(builtins) << ","sv << nll(classDecl);
		} else {
			if (extend) {
				_buf << indent(1) << "__init = function(self, ...)"sv << nll(classDecl);
				_buf << indent(2) << "return _class_0.__parent.__init(self, ...)"sv << nll(classDecl);
    			_buf << indent(1) << "end,"sv << nll(classDecl);
			} else {
				_buf << indent(1) << "__init = function() end,"sv << nll(classDecl);
			}
		}
		_buf << indent(1) << "__base = "sv << baseVar;
    	if (!className.empty()) {
    		_buf << ","sv << nll(classDecl) << indent(1) << "__name = "sv << className << (extend ? s(","sv) : Empty) << nll(classDecl);
		} else {
			_buf << nll(classDecl);
		}
		if (extend) {
			_buf << indent(1) << "__parent = "sv << parentVar << nll(classDecl);
		}
		_buf << indent() << "}, {"sv << nll(classDecl);
		if (extend) {
			_buf << indent(1) << "__index = function(cls, name)"sv << nll(classDecl);
			_buf << indent(2) << "local val = rawget("sv << baseVar << ", name)"sv << nll(classDecl);
			_buf << indent(2) << "if val == nil then"sv << nll(classDecl);
			_buf << indent(3) << "local parent = rawget(cls, \"__parent\")"sv << nll(classDecl);
			_buf << indent(3) << "if parent then"sv << nll(classDecl);
			_buf << indent(4) << "return parent[name]"sv << nll(classDecl);
			_buf << indent(3) << "end"sv << nll(classDecl);
			_buf << indent(2) << "else"sv << nll(classDecl);
			_buf << indent(3) << "return val"sv << nll(classDecl);
			_buf << indent(2) << "end"sv << nll(classDecl);
			_buf << indent(1) << "end,"sv << nll(classDecl);
		} else {
			_buf << indent(1) << "__index = "sv << baseVar << ","sv << nll(classDecl);
		}
		_buf << indent(1) << "__call = function(cls, ...)"sv << nll(classDecl);
		pushScope();
		auto selfVar = getUnusedName("_self_"sv);
		addToScope(selfVar);
		_buf << indent(1) << "local "sv << selfVar << " = setmetatable({}, "sv << baseVar << ")"sv << nll(classDecl);
		_buf << indent(1) << "cls.__init("sv << selfVar << ", ...)"sv << nll(classDecl);
		_buf << indent(1) << "return "sv << selfVar << nll(classDecl);
		popScope();
		_buf << indent(1) << "end"sv << nll(classDecl);
		_buf << indent() << "})"sv << nll(classDecl);
		_buf << indent() << baseVar << ".__class = "sv << classVar << nll(classDecl);
		if (!statements.empty()) _buf << indent() << "local self = "sv << classVar << nll(classDecl);
		_buf << join(statements);
		if (extend) {
			_buf << indent() << "if "sv << parentVar << ".__inherited then"sv << nll(classDecl);
			_buf << indent(1) << parentVar << ".__inherited("sv << parentVar << ", "sv << classVar << ")"sv << nll(classDecl);
			_buf << indent() << "end"sv << nll(classDecl);
		}
  		if (!assignItem.empty()) {
  			_buf << indent() << assignItem << " = "sv << classVar << nll(classDecl);
		}
		switch (usage) {
			case ExpUsage::Return: {
				_buf << indent() << "return "sv << classVar << nlr(classDecl);
				break;
			}
			case ExpUsage::Assignment: {
				_buf << tmp.back();
				break;
			}
			default: break;
		}
		temp.push_back(clearBuf());
		popScope();
		temp.push_back(indent() + s("end"sv) + nlr(classDecl));
		out.push_back(join(temp));
	}

	size_t transform_class_member_list(class_member_list_t* class_member_list, std::list<ClassMember>& out, const std::string& classVar) {
		str_list temp;
		size_t count = 0;
		for (auto keyValue : class_member_list->values.objects()) {
			MemType type = MemType::Common;
			BLOCK_START
			auto normal_pair = ast_cast<normal_pair_t>(keyValue);
			BREAK_IF(!normal_pair);
			auto keyName = normal_pair->key.as<KeyName_t>();
			BREAK_IF(!keyName);
			std::string newSuperCall;
			auto selfName = keyName->name.as<SelfName_t>();
			if (selfName) {
				type = MemType::Property;
				auto name = ast_cast<self_name_t>(selfName->name);
				if (!name) throw std::logic_error(_info.errorMessage("invalid class poperty name"sv, selfName->name));
				newSuperCall = classVar + s(".__parent."sv) + _parser.toString(name->name);
			} else {
				auto x = keyName;
				auto nameNode = keyName->name.as<Name_t>();
				if (!nameNode) break;
				auto name = _parser.toString(nameNode);
				if (name == "new"sv) {
					type = MemType::Builtin;
					keyName->name.set(toAst<Name_t>("__init"sv, x));
					newSuperCall = classVar + s(".__parent.__init"sv);
				} else {
					newSuperCall = classVar + s(".__parent.__base."sv) + name;
				}
			}
			normal_pair->value->traverse([&](ast_node* node) {
				if (node->getId() == id<ClassDecl_t>()) return traversal::Return;
				if (auto chainValue = ast_cast<ChainValue_t>(node)) {
					if (auto callable = ast_cast<Callable_t>(chainValue->items.front())) {
						auto var = callable->item.get();
						if (_parser.toString(var) == "super"sv) {
							auto insertSelfToArguments = [&](ast_node* item) {
								auto x = item;
								switch (item->getId()) {
									case id<InvokeArgs_t>(): {
										auto invoke = static_cast<InvokeArgs_t*>(item);
										invoke->args.push_front(toAst<Exp_t>("self"sv, x));
										return true;
									}
									case id<Invoke_t>(): {
										auto invoke = static_cast<Invoke_t*>(item);
										invoke->args.push_front(toAst<Exp_t>("self"sv, x));
										return true;
									}
									default:
										return false;
								}
							};
							const auto& chainList = chainValue->items.objects();
							if (chainList.size() >= 2) {
								auto it = chainList.begin();
								auto secondItem = *(++it);
								if (!insertSelfToArguments(secondItem)) {
									if (auto colonChainItem = ast_cast<ColonChainItem_t>(secondItem)) {
										if (chainList.size() > 2 && insertSelfToArguments(*(++it))) {
											colonChainItem->switchToDot = true;
										}
									}
									newSuperCall = classVar + s(".__parent"sv);
								}
							} else {
								newSuperCall = classVar + s(".__parent"sv);
							}
							auto newChain = toAst<ChainValue_t>(newSuperCall, chainValue);
							chainValue->items.pop_front();
							const auto& items = newChain->items.objects();
							for (auto it = items.rbegin(); it != items.rend(); ++it) {
								chainValue->items.push_front(*it);
							}
						}
					}
				}
				return traversal::Continue;
			});
			BLOCK_END
			pushScope();
			if (type == MemType::Property) {
				decIndentOffset();
			}
			switch (keyValue->getId()) {
				case id<variable_pair_t>():
					transform_variable_pair(static_cast<variable_pair_t*>(keyValue), temp);
					break;
				case id<normal_pair_t>():
					transform_normal_pair(static_cast<normal_pair_t*>(keyValue), temp);
					break;
				default: assert(false); break;
			}
			if (type == MemType::Property) {
				incIndentOffset();
			}
			popScope();
			out.push_back({temp.back(), type, keyValue});
			temp.clear();
			++count;
		}
		return count;
	}

	void transformAssignable(Assignable_t* assignable, str_list& out) {
		auto item = assignable->item.get();
		switch (item->getId()) {
			case id<AssignableChain_t>(): transformAssignableChain(static_cast<AssignableChain_t*>(item), out); break;
			case id<Variable_t>(): transformVariable(static_cast<Variable_t*>(item), out); break;
			case id<SelfName_t>(): transformSelfName(static_cast<SelfName_t*>(item), out); break;
			default: assert(false); break;
		}
	}

	void transformWithClosure(With_t* with, str_list& out) {
		str_list temp;
		temp.push_back(s("(function()"sv) + nll(with));
		pushScope();
		transformWith(with, temp, nullptr, true);
		popScope();
		temp.push_back(indent() + s("end)()"sv));
		out.push_back(join(temp));
	}

	void transformWith(With_t* with, str_list& out, ExpList_t* assignList = nullptr, bool returnValue = false) {
		auto x = with;
		str_list temp;
		std::string withVar;
		bool scoped = false;
		if (with->assigns) {
			checkAssignable(with->valueList);
			auto vars = getAssignVars(with);
			if (vars.front().empty()) {
				if (with->assigns->values.objects().size() == 1) {
					auto var = singleVariableFrom(with->assigns->values.objects().front());
					if (!var.empty()) {
						withVar = var;
					}
				}
				if (withVar.empty()) {
					withVar = getUnusedName("_with_"sv);
					auto assignment = x->new_ptr<ExpListAssign_t>();
					assignment->expList.set(toAst<ExpList_t>(withVar, x));
					auto assign = x->new_ptr<Assign_t>();
					assign->values.push_back(with->assigns->values.objects().front());
					assignment->action.set(assign);
					if (!returnValue) {
						scoped = true;
						temp.push_back(indent() + s("do"sv) + nll(with));
						pushScope();
					}
					transformAssignment(assignment, temp);
				}
				auto assignment = x->new_ptr<ExpListAssign_t>();
				assignment->expList.set(with->valueList);
				auto assign = x->new_ptr<Assign_t>();
				assign->values.push_back(toAst<Exp_t>(withVar, x));
				bool skipFirst = true;
				for (auto value : with->assigns->values.objects()) {
					if (skipFirst) {
						skipFirst = false;
						continue;
					}
					assign->values.push_back(value);
				}
				assignment->action.set(assign);
				transformAssignment(assignment, temp);
			} else {
				withVar = vars.front();
				auto assignment = x->new_ptr<ExpListAssign_t>();
				assignment->expList.set(with->valueList);
				assignment->action.set(with->assigns);
				if (!returnValue) {
					scoped = true;
					temp.push_back(indent() + s("do"sv) + nll(with));
					pushScope();
				}
				transformAssignment(assignment, temp);
			}
		} else {
			withVar = singleVariableFrom(with->valueList);
			if (withVar.empty()) {
				withVar = getUnusedName("_with_"sv);
				auto assignment = x->new_ptr<ExpListAssign_t>();
				assignment->expList.set(toAst<ExpList_t>(withVar, x));
				auto assign = x->new_ptr<Assign_t>();
				assign->values.dup(with->valueList->exprs);
				assignment->action.set(assign);
				if (!returnValue) {
					scoped = true;
					temp.push_back(indent() + s("do"sv) + nll(with));
					pushScope();
				}
				transformAssignment(assignment, temp);
			}
		}
		if (!scoped && !returnValue) {
			pushScope();
			scoped = traversal::Stop == with->body->traverse([&](ast_node* node) {
				if (auto statement = ast_cast<Statement_t>(node)) {
					ClassDecl_t* clsDecl = nullptr;
					if (auto assignment = assignmentFrom(statement)) {
						auto names = getAssignDefs(assignment->expList.get());
						if (!names.empty()) {
							return traversal::Stop;
						}
						auto info = extractDestructureInfo(assignment, true);
						if (!info.first.empty()) {
							for (const auto& destruct : info.first)
								for (const auto& item : destruct.items)
									if (item.isVariable && !isDefined(item.name))
										return traversal::Stop;
						}
						BLOCK_START
						auto assign = assignment->action.as<Assign_t>();
						BREAK_IF(!assign);
						BREAK_IF(assign->values.objects().size() != 1);
						auto exp = ast_cast<Exp_t>(assign->values.objects().front());
						BREAK_IF(!exp);
						if (auto value = singleValueFrom(exp)) {
							clsDecl = value->getByPath<SimpleValue_t, ClassDecl_t>();
						}
						BLOCK_END
					} else if (auto expList = expListFrom(statement)) {
						auto value = singleValueFrom(expList);
						clsDecl = value->getByPath<SimpleValue_t, ClassDecl_t>();
					}
					if (clsDecl) {
						auto variable = clsDecl->name.as<Variable_t>();
						if (!isDefined(_parser.toString(variable))) return traversal::Stop;
					}
					return traversal::Return;
				}
				return traversal::Continue;
			});
			popScope();
			if (scoped) {
				temp.push_back(indent() + s("do"sv) + nll(with));
				pushScope();
			}
		}
		_withVars.push(withVar);
		transformBody(with->body, temp, ExpUsage::Common);
		_withVars.pop();
		if (assignList) {
			auto assignment = x->new_ptr<ExpListAssign_t>();
			assignment->expList.set(assignList);
			auto assign = x->new_ptr<Assign_t>();
			assign->values.push_back(toAst<Exp_t>(withVar, x));
			assignment->action.set(assign);
			transformAssignment(assignment, temp);
		}
		if (returnValue) {
			auto last = lastStatementFrom(with->body);
			if (last && !last->content.is<Return_t>()) {
				temp.push_back(indent() + s("return "sv) + withVar + nll(with));
			}
		}
		if (scoped) {
			popScope();
			temp.push_back(indent() + s("end"sv) + nll(with));
		}
		out.push_back(join(temp));
	}

	void transform_const_value(const_value_t* const_value, str_list& out) {
		out.push_back(_parser.toString(const_value));
	}

	void transformGlobal(Global_t* global, str_list& out) {
		auto x = global;
		auto item = global->item.get();
		switch (item->getId()) {
			case id<ClassDecl_t>(): {
				auto classDecl = static_cast<ClassDecl_t*>(item);
				if (classDecl->name && classDecl->name->item->getId() == id<Variable_t>()) {
					markVarGlobal(GlobalMode::Any, true);
					addGlobalVar(_parser.toString(classDecl->name->item));
				}
				transformClassDecl(classDecl, out, ExpUsage::Common);
				break;
			}
			case id<global_op_t>():
				if (_parser.toString(item) == "*"sv) {
					markVarGlobal(GlobalMode::Any, false);
				} else {
					markVarGlobal(GlobalMode::Capital, false);
				}
				break;
			case id<global_values_t>(): {
				markVarGlobal(GlobalMode::Any, true);
				auto values = global->item.to<global_values_t>();
				if (values->valueList) {
					auto expList = x->new_ptr<ExpList_t>();
					for (auto name : values->nameList->names.objects()) {
						addGlobalVar(_parser.toString(name));
						auto callable = x->new_ptr<Callable_t>();
						callable->item.set(name);
						auto chainValue = x->new_ptr<ChainValue_t>();
						chainValue->items.push_back(callable);
						auto value = x->new_ptr<Value_t>();
						value->item.set(chainValue);
						auto exp = x->new_ptr<Exp_t>();
						exp->value.set(value);
						expList->exprs.push_back(exp);
					}
					auto assignment = x->new_ptr<ExpListAssign_t>();
					assignment->expList.set(expList);
					auto assign = x->new_ptr<Assign_t>();
					assign->values.dup(values->valueList->exprs);
					assignment->action.set(assign);
					transformAssignment(assignment, out);
				} else {
					for (auto name : values->nameList->names.objects()) {
						addGlobalVar(_parser.toString(name));
					}
				}
				break;
			}
			default: assert(false); break;
		}
	}

	void transformExport(Export_t* exportNode, str_list& out) {
		auto x = exportNode;
		if (_scopes.size() > 1) {
			throw std::logic_error(_info.errorMessage("can not do module export outside the root block"sv, exportNode));
		}
		if (exportNode->assign) {
			auto expList = exportNode->target.to<ExpList_t>();
			if (expList->exprs.size() != exportNode->assign->values.size()) {
				throw std::logic_error(_info.errorMessage("left and right expressions must be matched in export statement"sv, x));
			}
			for (auto _exp : expList->exprs.objects()) {
				auto exp = static_cast<Exp_t*>(_exp);
				if (!variableFrom(exp) &&
					!exp->getByPath<Value_t, SimpleValue_t, TableLit_t>() &&
					!exp->getByPath<Value_t, simple_table_t>()) {
					throw std::logic_error(_info.errorMessage("left hand expressions must be variables in export statement"sv, x));
				}
			}
			auto assignment = x->new_ptr<ExpListAssign_t>();
			assignment->expList.set(expList);
			assignment->action.set(exportNode->assign);
			transformAssignment(assignment, out);
			str_list names = transformAssignDefs(expList, false);
			auto info = extractDestructureInfo(assignment, true);
			if (!info.first.empty()) {
				for (const auto& destruct : info.first)
					for (const auto& item : destruct.items)
						if (item.isVariable)
							names.push_back(item.name);
			}
			if (_info.exportDefault) {
				out.back().append(indent() + _info.moduleName + s(" = "sv) + names.back() + nlr(exportNode));
			} else {
				str_list lefts, rights;
				for (const auto& name : names) {
					lefts.push_back(_info.moduleName + s("[\""sv) + name + s("\"]"sv));
					rights.push_back(name);
				}
				out.back().append(indent() + join(lefts,", "sv) + s(" = "sv) + join(rights, ", "sv) + nlr(exportNode));
			}
		} else {
			if (auto macro = exportNode->target.as<Macro_t>()) {
				transformMacro(macro, out, true);
			} else if (_info.exportDefault) {
				auto exp = exportNode->target.to<Exp_t>();
				auto assignment = x->new_ptr<ExpListAssign_t>();
				assignment->expList.set(toAst<ExpList_t>(_info.moduleName, x));
				auto assign = x->new_ptr<Assign_t>();
				assign->values.push_back(exp);
				assignment->action.set(assign);
				transformAssignment(assignment, out);
			} else {
				str_list temp;
				auto expList = exportNode->target.to<ExpList_t>();
				auto assignment = x->new_ptr<ExpListAssign_t>();
				auto assignList = toAst<ExpList_t>(_info.moduleName + s("[#"sv) + _info.moduleName + s("+1]"sv), x);
				assignment->expList.set(assignList);
				for (auto exp : expList->exprs.objects()) {
					if (auto classDecl = exp->getByPath<Value_t, SimpleValue_t, ClassDecl_t>()) {
						if (classDecl->name && classDecl->name->item->getId() == id<Variable_t>()) {
							transformClassDecl(classDecl, temp, ExpUsage::Common);
							auto name = _parser.toString(classDecl->name->item);
							assignment->expList.set(toAst<ExpList_t>(_info.moduleName + s("[\""sv) + name + s("\"]"sv), x));
							auto assign = x->new_ptr<Assign_t>();
							assign->values.push_back(toAst<Exp_t>(name, x));
							assignment->action.set(assign);
							transformAssignment(assignment, temp);
							assignment->expList.set(assignList);
							continue;
						}
					}
					auto assign = x->new_ptr<Assign_t>();
					assign->values.push_back(exp);
					assignment->action.set(assign);
					transformAssignment(assignment, temp);
				}
				out.push_back(join(temp));
			}
		}
	}

	void transformTable(ast_node* table, const node_container& pairs, str_list& out) {
		if (pairs.empty()) {
			out.push_back(s("{ }"sv));
			return;
		}
		str_list temp;
		incIndentOffset();
		for (auto pair : pairs) {
			switch (pair->getId()) {
				case id<Exp_t>(): transformExp(static_cast<Exp_t*>(pair), temp, ExpUsage::Closure); break;
				case id<variable_pair_t>(): transform_variable_pair(static_cast<variable_pair_t*>(pair), temp); break;
				case id<normal_pair_t>(): transform_normal_pair(static_cast<normal_pair_t*>(pair), temp); break;
				default: assert(false); break;
			}
			temp.back() = indent() + temp.back() + (pair == pairs.back() ? Empty : s(","sv)) + nll(pair);
		}
		out.push_back(s("{"sv) + nll(table) + join(temp));
		decIndentOffset();
		out.back() += (indent() + s("}"sv));
	}

	void transform_simple_table(simple_table_t* table, str_list& out) {
		transformTable(table, table->pairs.objects(), out);
	}

	void transformTblComprehension(TblComprehension_t* comp, str_list& out, ExpUsage usage, ExpList_t* assignList = nullptr) {
		switch (usage) {
			case ExpUsage::Closure:
			case ExpUsage::Assignment:
				pushScope();
				break;
			default:
				break;
		}
		auto x = comp;
		str_list kv;
		std::string tbl = getUnusedName("_tbl_"sv);
		addToScope(tbl);
		str_list temp;
		auto compInner = comp->forLoop.get();
		for (auto item : compInner->items.objects()) {
			switch (item->getId()) {
				case id<CompForEach_t>():
					transformCompForEach(static_cast<CompForEach_t*>(item), temp);
					break;
				case id<CompFor_t>():
					transformCompFor(static_cast<CompFor_t*>(item), temp);
					break;
				case id<Exp_t>():
					transformExp(static_cast<Exp_t*>(item), temp, ExpUsage::Closure);
					temp.back() = indent() + s("if "sv) + temp.back() + s(" then"sv) + nll(item);
					pushScope();
					break;
				default: assert(false); break;
			}
		}
		transformExp(comp->key, kv, ExpUsage::Closure);
		if (comp->value) {
			transformExp(comp->value->value, kv, ExpUsage::Closure);
		}
		for (size_t i = 0; i < compInner->items.objects().size(); ++i) {
			popScope();
		}
		_buf << indent() << "local "sv << tbl << " = { }"sv << nll(comp);
		_buf << join(temp);
		pushScope();
		if (!comp->value) {
			auto keyVar = getUnusedName("_key_"sv);
			auto valVar = getUnusedName("_val_"sv);
			_buf << indent(int(temp.size()) - 1) << "local "sv << keyVar << ", "sv << valVar << " = "sv << kv.front() << nll(comp);
			kv.front() = keyVar;
			kv.push_back(valVar);
		}
		_buf << indent(int(temp.size()) - 1) << tbl << "["sv << kv.front() << "] = "sv << kv.back() << nll(comp);
		for (int ind = int(temp.size()) - 2; ind > -1 ; --ind) {
			_buf << indent(ind) << "end"sv << nll(comp);
		}
		popScope();
		_buf << indent() << "end"sv << nll(comp);
		switch (usage) {
			case ExpUsage::Closure:
				out.push_back(clearBuf() + indent() + s("return "sv) + tbl + nlr(comp));
				popScope();
				out.back().insert(0, s("(function()"sv) + nll(comp));
				out.back().append(indent() + s("end)()"sv));
				break;
			case ExpUsage::Assignment: {
				out.push_back(clearBuf());
				auto assign = x->new_ptr<Assign_t>();
				assign->values.push_back(toAst<Exp_t>(tbl, x));
				auto assignment = x->new_ptr<ExpListAssign_t>();
				assignment->expList.set(assignList);
				assignment->action.set(assign);
				transformAssignment(assignment, temp);
				out.back().append(temp.back());
				popScope();
				out.back().insert(0, indent() + s("do"sv) + nll(comp));
				out.back().append(indent() + s("end"sv) + nlr(comp));
				break;
			}
			case ExpUsage::Return:
				out.push_back(clearBuf() + indent() + s("return "sv) + tbl + nlr(comp));
				break;
			default:
				break;
		}
	}

	void transformCompFor(CompFor_t* comp, str_list& out) {
		str_list temp;
		std::string varName = _parser.toString(comp->varName);
		transformExp(comp->startValue, temp, ExpUsage::Closure);
		transformExp(comp->stopValue, temp, ExpUsage::Closure);
		if (comp->stepValue) {
			transformExp(comp->stepValue->value, temp, ExpUsage::Closure);
		} else {
			temp.emplace_back();
		}
		auto it = temp.begin();
		const auto& start = *it;
		const auto& stop = *(++it);
		const auto& step = *(++it);
		_buf << indent() << "for "sv << varName << " = "sv << start << ", "sv << stop << (step.empty() ? Empty : s(", "sv) + step) << " do"sv << nll(comp);
		out.push_back(clearBuf());
		pushScope();
		addToScope(varName);
	}

	void transformTableBlock(TableBlock_t* table, str_list& out) {
		transformTable(table, table->values.objects(), out);
	}

	void transformDo(Do_t* doNode, str_list& out, ExpUsage usage, ExpList_t* assignList = nullptr) {
		str_list temp;
		if (usage == ExpUsage::Closure) {
			temp.push_back(s("(function()"sv) + nll(doNode));
		} else {
			temp.push_back(indent() + s("do"sv) + nll(doNode));
		}
		pushScope();
		transformBody(doNode->body, temp, usage, assignList);
		popScope();
		if (usage == ExpUsage::Closure) {
			temp.push_back(indent() + s("end)()"sv));
		} else {
			temp.push_back(indent() + s("end"sv) + nlr(doNode));
		}
		out.push_back(join(temp));
	}

	void transformImportFrom(ImportFrom_t* import, str_list& out) {
		str_list temp;
		auto x = import;
		auto objVar = singleVariableFrom(import->exp);
		ast_ptr<false, ExpListAssign_t> objAssign;
		if (objVar.empty()) {
			objVar = getUnusedName("_obj_"sv);
			auto expList = toAst<ExpList_t>(objVar, x);
			auto assign = x->new_ptr<Assign_t>();
			assign->values.push_back(import->exp);
			auto assignment = x->new_ptr<ExpListAssign_t>();
			assignment->expList.set(expList);
			assignment->action.set(assign);
			objAssign.set(assignment);
		}
		auto expList = x->new_ptr<ExpList_t>();
		auto assign = x->new_ptr<Assign_t>();
		for (auto name : import->names.objects()) {
			switch (name->getId()) {
				case id<Variable_t>(): {
					auto var = ast_to<Variable_t>(name);
					{
						auto callable = toAst<Callable_t>(objVar, x);
						auto dotChainItem = x->new_ptr<DotChainItem_t>();
						dotChainItem->name.set(var->name);
						auto chainValue = x->new_ptr<ChainValue_t>();
						chainValue->items.push_back(callable);
						chainValue->items.push_back(dotChainItem);
						auto value = x->new_ptr<Value_t>();
						value->item.set(chainValue);
						auto exp = x->new_ptr<Exp_t>();
						exp->value.set(value);
						assign->values.push_back(exp);
					}
					auto callable = x->new_ptr<Callable_t>();
					callable->item.set(var);
					auto chainValue = x->new_ptr<ChainValue_t>();
					chainValue->items.push_back(callable);
					auto value = x->new_ptr<Value_t>();
					value->item.set(chainValue);
					auto exp = x->new_ptr<Exp_t>();
					exp->value.set(value);
					expList->exprs.push_back(exp);
					break;
				}
				case id<colon_import_name_t>(): {
					auto var = static_cast<colon_import_name_t*>(name)->name.get();
					{
						auto nameNode = var->name.get();
						auto callable = toAst<Callable_t>(objVar, x);
						auto colonChain = x->new_ptr<ColonChainItem_t>();
						colonChain->name.set(nameNode);
						auto chainValue = x->new_ptr<ChainValue_t>();
						chainValue->items.push_back(callable);
						chainValue->items.push_back(colonChain);
						auto value = x->new_ptr<Value_t>();
						value->item.set(chainValue);
						auto exp = x->new_ptr<Exp_t>();
						exp->value.set(value);
						assign->values.push_back(exp);
					}
					auto callable = x->new_ptr<Callable_t>();
					callable->item.set(var);
					auto chainValue = x->new_ptr<ChainValue_t>();
					chainValue->items.push_back(callable);
					auto value = x->new_ptr<Value_t>();
					value->item.set(chainValue);
					auto exp = x->new_ptr<Exp_t>();
					exp->value.set(value);
					expList->exprs.push_back(exp);
					break;
				}
				default: assert(false); break;
			}
		}
		if (objAssign) {
			auto preDef = getPredefine(transformAssignDefs(expList));
			if (!preDef.empty()) {
				temp.push_back(preDef + nll(import));
			}
			temp.push_back(indent() + s("do"sv) + nll(import));
			pushScope();
			transformAssignment(objAssign, temp);
		}
		auto assignment = x->new_ptr<ExpListAssign_t>();
		assignment->expList.set(expList);
		assignment->action.set(assign);
		transformAssignment(assignment, temp);
		if (objAssign) {
			popScope();
			temp.push_back(indent() + s("end"sv) + nlr(import));
		}
		out.push_back(join(temp));
	}

	std::string moduleNameFrom(ImportLiteral_t* literal) {
		auto name = _parser.toString(literal->inners.back());
		Utils::replace(name, "-"sv, "_"sv);
		Utils::replace(name, " "sv, "_"sv);
		return name;
	}

	void transformImportAs(ImportAs_t* import, str_list& out) {
		auto x = import;
		if (!import->target) {
			auto name = moduleNameFrom(import->literal);
			import->target.set(toAst<Variable_t>(name, x));
		}
		if (auto tableLit = import->target.as<TableLit_t>()) {
			auto newTab = x->new_ptr<TableLit_t>();
			std::list<std::pair<std::string,std::string>> macroPairs;
			for (auto item : tableLit->values.objects()) {
				switch (item->getId()) {
					case id<MacroName_t>(): {
						auto macroName = static_cast<MacroName_t*>(item);
						auto name = _parser.toString(macroName->name);
						macroPairs.emplace_back(name, name);
						break;
					}
					case id<macro_name_pair_t>(): {
						auto pair = static_cast<macro_name_pair_t*>(item);
					macroPairs.emplace_back(_parser.toString(pair->value->name), _parser.toString(pair->key->name));
						break;
					}
					default:
						newTab->values.push_back(item);
						break;
				}
			}
			if (!macroPairs.empty()) {
				auto moduleName = _parser.toString(import->literal);
				Utils::replace(moduleName, "'"sv, ""sv);
				Utils::replace(moduleName, "\""sv, ""sv);
				Utils::trim(moduleName);
				pushCurrentModule(); // cur
				int top = lua_gettop(L) - 1;
				DEFER(lua_settop(L, top));
				pushMoonp("find_modulepath"sv); // cur find_modulepath
				lua_pushlstring(L, moduleName.c_str(), moduleName.size()); // cur find_modulepath moduleName
				if (lua_pcall(L, 1, 1, 0) != 0) {
					std::string err = lua_tostring(L, -1);
					throw std::logic_error(_info.errorMessage(s("fail to resolve module path\n"sv) + err, x));
				}
				if (lua_isnil(L, -1) != 0) {
					throw std::logic_error(_info.errorMessage(s("fail to find module '"sv) + moduleName + '\'', x));
				}
				std::string moduleFullName = lua_tostring(L, -1);
				lua_pop(L, 1); // cur
				if (!isModuleLoaded(moduleFullName)) {
					pushMoonp("read_file"sv); // cur read_file
					lua_pushlstring(L, moduleFullName.c_str(), moduleFullName.size()); // cur load_text moduleFullName
					if (lua_pcall(L, 1, 1, 0) != 0) {
						std::string err = lua_tostring(L, -1);
						throw std::logic_error(_info.errorMessage(s("fail to read module file\n"sv) + err, x));
					} // cur text
					if (lua_isnil(L, -1) != 0) {
						throw std::logic_error(_info.errorMessage("fail to get module text"sv, x));
					} // cur text
					std::string text = lua_tostring(L, -1);
					auto compiler = MoonCompilerImpl(L, _luaOpen, false, moduleFullName);
					MoonConfig config;
					config.lineOffset = 0;
					config.lintGlobalVariable = false;
					config.reserveLineNumber = false;
					config.implicitReturnRoot = _config.implicitReturnRoot;
					std::string codes, err;
					GlobalVars globals;
					std::tie(codes, err, globals) = compiler.compile(text, config);
					if (codes.empty() && !err.empty()) {
						throw std::logic_error(_info.errorMessage(s("fail to compile module '"sv) + moduleName + s("\': "sv) + err, x));
					}
					lua_pop(L, 1); // cur
				}
				pushModuleTable(moduleFullName); // cur module
				for (const auto& pair : macroPairs) {
					lua_getfield(L, -1, pair.first.c_str());
					lua_setfield(L, -3, pair.second.c_str());
				}
			}
			if (newTab->values.empty()) {
				out.push_back(Empty);
				return;
			} else {
				import->target.set(newTab);
			}
		}
		auto target = import->target.get();
		auto value = x->new_ptr<Value_t>();
		if (auto var = ast_cast<Variable_t>(target)) {
			auto callable = x->new_ptr<Callable_t>();
			callable->item.set(var);
			auto chainValue = x->new_ptr<ChainValue_t>();
			chainValue->items.push_back(callable);
			value->item.set(chainValue);
		} else {
			auto tableLit = ast_to<TableLit_t>(target);
			auto simpleValue = x->new_ptr<SimpleValue_t>();
			simpleValue->value.set(tableLit);
			value->item.set(simpleValue);
		}
		auto exp = x->new_ptr<Exp_t>();
		exp->value.set(value);
		auto assignList = x->new_ptr<ExpList_t>();
		assignList->exprs.push_back(exp);
		auto assign = x->new_ptr<Assign_t>();
		assign->values.push_back(toAst<Exp_t>(s("require "sv) + _parser.toString(import->literal), x));
		auto assignment = x->new_ptr<ExpListAssign_t>();
		assignment->expList.set(assignList);
		assignment->action.set(assign);
		transformAssignment(assignment, out);
	}

	void transformImport(Import_t* import, str_list& out) {
		auto content = import->content.get();
		switch (content->getId()) {
			case id<ImportAs_t>():
				transformImportAs(static_cast<ImportAs_t*>(content), out);
				break;
			case id<ImportFrom_t>():
				transformImportFrom(static_cast<ImportFrom_t*>(content), out);
				break;
			default: assert(false); break;
		}
	}

	void transformWhileInPlace(While_t* whileNode, str_list& out, ExpList_t* expList = nullptr) {
		auto x = whileNode;
		str_list temp;
		if (expList) {
			temp.push_back(indent() + s("do"sv) + nll(whileNode));
		}
		pushScope();
		auto accumVar = getUnusedName("_accum_"sv);
		addToScope(accumVar);
		auto lenVar = getUnusedName("_len_"sv);
		addToScope(lenVar);
		temp.push_back(indent() + s("local "sv) + accumVar + s(" = { }"sv) + nll(whileNode));
		temp.push_back(indent() + s("local "sv) + lenVar + s(" = 1"sv) + nll(whileNode));
		transformExp(whileNode->condition, temp, ExpUsage::Closure);
		temp.back() = indent() + s("while "sv) + temp.back() + s(" do"sv) + nll(whileNode);
		pushScope();
		auto assignLeft = toAst<ExpList_t>(accumVar + s("["sv) + lenVar + s("]"sv), x);
		auto lenLine = lenVar + s(" = "sv) + lenVar + s(" + 1"sv) + nlr(whileNode);
		transformLoopBody(whileNode->body, temp, lenLine, ExpUsage::Assignment, assignLeft);
		popScope();
		temp.push_back(indent() + s("end"sv) + nlr(whileNode));
		if (expList) {
			auto assign = x->new_ptr<Assign_t>();
			assign->values.push_back(toAst<Exp_t>(accumVar, x));
			auto assignment = x->new_ptr<ExpListAssign_t>();
			assignment->expList.set(expList);
			assignment->action.set(assign);
			transformAssignment(assignment, temp);
		} else {
			temp.push_back(indent() + s("return "sv) + accumVar + nlr(whileNode));
		}
		popScope();
		if (expList) {
			temp.push_back(indent() + s("end"sv) + nlr(whileNode));
		}
		out.push_back(join(temp));
	}

	void transformWhileClosure(While_t* whileNode, str_list& out) {
		auto x = whileNode;
		str_list temp;
		temp.push_back(s("(function() "sv) + nll(whileNode));
		pushScope();
		auto accumVar = getUnusedName("_accum_"sv);
		addToScope(accumVar);
		auto lenVar = getUnusedName("_len_"sv);
		addToScope(lenVar);
		temp.push_back(indent() + s("local "sv) + accumVar + s(" = { }"sv) + nll(whileNode));
		temp.push_back(indent() + s("local "sv) + lenVar + s(" = 1"sv) + nll(whileNode));
		transformExp(whileNode->condition, temp, ExpUsage::Closure);
		temp.back() = indent() + s("while "sv) + temp.back() + s(" do"sv) + nll(whileNode);
		pushScope();
		auto assignLeft = toAst<ExpList_t>(accumVar + s("["sv) + lenVar + s("]"sv), x);
		auto lenLine = lenVar + s(" = "sv) + lenVar + s(" + 1"sv) + nlr(whileNode);
		transformLoopBody(whileNode->body, temp, lenLine, ExpUsage::Assignment, assignLeft);
		popScope();
		temp.push_back(indent() + s("end"sv) + nlr(whileNode));
		temp.push_back(indent() + s("return "sv) + accumVar + nlr(whileNode));
		popScope();
		temp.push_back(indent() + s("end)()"sv));
		out.push_back(join(temp));
	}

	void transformWhile(While_t* whileNode, str_list& out) {
		str_list temp;
		pushScope();
		transformExp(whileNode->condition, temp, ExpUsage::Closure);
		transformLoopBody(whileNode->body, temp, Empty, ExpUsage::Common);
		popScope();
		_buf << indent() << "while "sv << temp.front() << " do"sv << nll(whileNode);
		_buf << temp.back();
		_buf << indent() << "end"sv << nlr(whileNode);
		out.push_back(clearBuf());
	}

	void transformSwitch(Switch_t* switchNode, str_list& out, ExpUsage usage, ExpList_t* assignList = nullptr) {
		str_list temp;
		if (usage == ExpUsage::Closure) {
			temp.push_back(s("(function()"sv) + nll(switchNode));
			pushScope();
		}
		auto objVar = singleVariableFrom(switchNode->target);
		if (objVar.empty()) {
			objVar = getUnusedName("_exp_"sv);
			addToScope(objVar);
			transformExp(switchNode->target, temp, ExpUsage::Closure);
			_buf << indent() << "local "sv << objVar << " = "sv << temp.back() << nll(switchNode);
			temp.back() = clearBuf();
		}
		const auto& branches = switchNode->branches.objects();
		for (auto branch_ : branches) {
			auto branch = static_cast<SwitchCase_t*>(branch_);
			temp.push_back(indent() + s(branches.front() == branch ? "if"sv : "elseif"sv));
			str_list tmp;
			const auto& exprs = branch->valueList->exprs.objects();
			for (auto exp_ : exprs) {
				auto exp = static_cast<Exp_t*>(exp_);
				transformExp(exp, tmp, ExpUsage::Closure);
				if (!singleValueFrom(exp)) {
					tmp.back() = s("("sv) + tmp.back() + s(")"sv);
				}
				temp.back().append(s(" "sv) + tmp.back() + s(" == "sv) + objVar +
					s(exp == exprs.back() ? ""sv : " or"sv));
			}
			temp.back().append(s(" then"sv) + nll(branch));
			pushScope();
			transformBody(branch->body, temp, usage, assignList);
			popScope();
		}
		if (switchNode->lastBranch) {
			temp.push_back(indent() + s("else"sv) + nll(switchNode->lastBranch));
			pushScope();
			transformBody(switchNode->lastBranch, temp, usage, assignList);
			popScope();
		}
		temp.push_back(indent() + s("end"sv) + nlr(switchNode));
		if (usage == ExpUsage::Closure) {
			popScope();
			temp.push_back(indent() + s("end)()"sv));
		}
		out.push_back(join(temp));
	}

	void transformLocal(Local_t* local, str_list& out) {
		str_list temp;
		if (!local->forceDecls.empty() || !local->decls.empty()) {
			str_list defs;
			for (const auto& decl : local->forceDecls) {
				forceAddToScope(decl);
				defs.push_back(decl);
			}
			for (const auto& decl : local->decls) {
				if (addToScope(decl)) {
					defs.push_back(decl);
				}
			}
			auto preDefine = getPredefine(defs);
			if (!preDefine.empty()) {
				temp.push_back(preDefine + nll(local));
			}
		}
		if (auto values = local->item.as<local_values_t>()) {
			if (values->valueList) {
				auto x = local;
				auto expList = x->new_ptr<ExpList_t>();
				for (auto name : values->nameList->names.objects()) {
					auto callable = x->new_ptr<Callable_t>();
					callable->item.set(name);
					auto chainValue = x->new_ptr<ChainValue_t>();
					chainValue->items.push_back(callable);
					auto value = x->new_ptr<Value_t>();
					value->item.set(chainValue);
					auto exp = x->new_ptr<Exp_t>();
					exp->value.set(value);
					expList->exprs.push_back(exp);
				}
				auto assignment = x->new_ptr<ExpListAssign_t>();
				assignment->expList.set(expList);
				auto assign = x->new_ptr<Assign_t>();
				assign->values.dup(values->valueList->exprs);
				assignment->action.set(assign);
				transformAssignment(assignment, temp);
			}
		}
		out.push_back(join(temp));
	}

	void transformBreakLoop(BreakLoop_t* breakLoop, str_list& out) {
		auto keyword = _parser.toString(breakLoop);
		if (keyword == "break"sv) {
			out.push_back(indent() + keyword + nll(breakLoop));
			return;
		}
		if (_continueVars.empty()) throw std::logic_error(_info.errorMessage("continue is not inside a loop"sv, breakLoop));
		_buf << indent() << _continueVars.top() << " = true"sv << nll(breakLoop);
		_buf << indent() << "break"sv << nll(breakLoop);
		out.push_back(clearBuf());
	}

	void transformLabel(Label_t* label, str_list& out) {
		out.push_back(indent() + s("::"sv) + _parser.toString(label->label) + s("::"sv) + nll(label));
	}

	void transformGoto(Goto_t* gotoNode, str_list& out) {
		out.push_back(indent() + s("goto "sv) + _parser.toString(gotoNode->label) + nll(gotoNode));
	}
};

const std::string MoonCompilerImpl::Empty;

MoonCompiler::MoonCompiler(void* sharedState,
	const std::function<void(void*)>& luaOpen,
	bool sameModule):
_compiler(std::make_unique<MoonCompilerImpl>(static_cast<lua_State*>(sharedState), luaOpen, sameModule)) {}

MoonCompiler::~MoonCompiler() {}

std::tuple<std::string,std::string,GlobalVars> MoonCompiler::compile(std::string_view codes, const MoonConfig& config) {
	return _compiler->compile(codes, config);
}

} // namespace MoonP
