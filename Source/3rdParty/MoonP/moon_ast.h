#pragma once

#include "MoonP/moon_parser.h"

namespace MoonP {

#define AST_LEAF(type, id) \
extern rule type; \
class type##_t : public ast_node \
{ \
public: \
	virtual int get_type() override { return ast_type<type##_t>(); } \
	virtual size_t getId() const override { return id; } \
	virtual const char* getName() const override { return #type; }

#define AST_NODE(type, id) \
extern rule type; \
class type##_t : public ast_container \
{ \
public: \
	virtual int get_type() override { return ast_type<type##_t>(); } \
	virtual size_t getId() const override { return id; } \
	virtual const char* getName() const override { return #type; }

#define AST_END(type) \
};

AST_LEAF(Num, "Num"_id)
AST_END(Num)

AST_LEAF(Name, "Name"_id)
AST_END(Name)

AST_NODE(Variable, "Variable"_id)
	ast_ptr<Name_t> name;
AST_END(Variable)

AST_NODE(LuaKeyword, "LuaKeyword"_id)
	ast_ptr<Name_t> name;
AST_END(LuaKeyword)

AST_LEAF(self, "self"_id)
AST_END(self)

AST_NODE(self_name, "self_name"_id)
	ast_ptr<Name_t> name;
AST_END(self_name)

AST_LEAF(self_class, "self_class"_id)
AST_END(self_class)

AST_NODE(self_class_name, "self_class_name"_id)
	ast_ptr<Name_t> name;
AST_END(self_class_name)

AST_NODE(SelfName, "SelfName"_id)
	ast_ptr<ast_node> name; // self_class_name_t | self_class_t | self_name_t | self_t
AST_END(SelfName)

AST_NODE(KeyName, "KeyName"_id)
	ast_ptr<ast_node> name; // SelfName_t | Name_t
AST_END(KeyName)

AST_LEAF(VarArg, "VarArg"_id)
AST_END(VarArg)

AST_LEAF(local_flag, "local_flag"_id)
AST_END(local_flag)

AST_LEAF(Seperator, "Seperator"_id)
AST_END(Seperator)

AST_NODE(NameList, "NameList"_id)
	ast_ptr<Seperator_t> sep;
	ast_list<Variable_t> names;
AST_END(NameList)

AST_NODE(Local, "Local"_id)
	ast_ptr<ast_node> name; // local_flag_t | NameList_t
	std::list<std::string> forceDecls;
	std::list<std::string> decls;
AST_END(Local)

AST_NODE(colon_import_name, "colon_import_name"_id)
	ast_ptr<Variable_t> name;
AST_END(colon_import_name)

class Exp_t;

AST_NODE(Import, "Import"_id)
	ast_ptr<Seperator_t> sep;
	ast_sel_list<colon_import_name_t, Variable_t> names;
	ast_ptr<Exp_t> exp;
AST_END(Import)

AST_NODE(ExpListLow, "ExpListLow"_id)
	ast_ptr<Seperator_t> sep;
	ast_list<Exp_t> exprs;
AST_END(ExpListLow)

AST_NODE(ExpList, "ExpList"_id)
	ast_ptr<Seperator_t> sep;
	ast_list<Exp_t> exprs;
AST_END(ExpList)

AST_NODE(Return, "Return"_id)
	ast_ptr<ExpListLow_t, true> valueList;
AST_END(Return)

class Assign_t;
class Body_t;

AST_NODE(With, "With"_id)
	ast_ptr<ExpList_t> valueList;
	ast_ptr<Assign_t, true> assigns;
	ast_ptr<Body_t> body;
AST_END(With)

AST_NODE(SwitchCase, "SwitchCase"_id)
	ast_ptr<ExpList_t> valueList;
	ast_ptr<Body_t> body;
AST_END(SwitchCase)

AST_NODE(Switch, "Switch"_id)
	ast_ptr<Exp_t> target;
	ast_ptr<Seperator_t> sep;
	ast_list<SwitchCase_t> branches;
	ast_ptr<Body_t, true> lastBranch;
AST_END(Switch)

AST_NODE(IfCond, "IfCond"_id)
	ast_ptr<Exp_t> condition;
	ast_ptr<Assign_t, true> assign;
AST_END(IfCond)

AST_NODE(If, "If"_id)
	ast_ptr<Seperator_t> sep;
	ast_sel_list<IfCond_t, Body_t> nodes;
AST_END(If)

AST_NODE(Unless, "Unless"_id)
	ast_ptr<Seperator_t> sep;
	ast_sel_list<IfCond_t, Body_t> nodes;
AST_END(Unless)

AST_NODE(While, "While"_id)
	ast_ptr<Exp_t> condition;
	ast_ptr<Body_t> body;
AST_END(While)

AST_NODE(for_step_value, "for_step_value"_id)
	ast_ptr<Exp_t> value;
AST_END(for_step_value)

AST_NODE(For, "For"_id)
	ast_ptr<Variable_t> varName;
	ast_ptr<Exp_t> startValue;
	ast_ptr<Exp_t> stopValue;
	ast_ptr<for_step_value_t, true> stepValue;
	ast_ptr<Body_t> body;
AST_END(For)

class AssignableNameList_t;

AST_NODE(ForEach, "ForEach"_id)
	ast_ptr<AssignableNameList_t> nameList;
	ast_ptr<ast_node> loopValue; // Exp_t | ExpList_t
	ast_ptr<Body_t> body;
AST_END(ForEach)

AST_NODE(Do, "Do"_id)
	ast_ptr<Body_t> body;
AST_END(Do)

class CompInner_t;
class Statement_t;

AST_NODE(Comprehension, "Comprehension"_id)
	ast_sel<Exp_t, Statement_t> value;
	ast_ptr<CompInner_t> forLoop;
AST_END(Comprehension)

AST_NODE(comp_value, "comp_value"_id)
	ast_ptr<Exp_t> value;
AST_END(comp_value)

AST_NODE(TblComprehension, "TblComprehension"_id)
	ast_ptr<Exp_t> key;
	ast_ptr<comp_value_t, true> value;
	ast_ptr<CompInner_t> forLoop;
AST_END(TblComprehension)

AST_NODE(star_exp, "star_exp"_id)
	ast_ptr<Exp_t> value;
AST_END(star_exp)

AST_NODE(CompForEach, "CompForEach"_id)
	ast_ptr<AssignableNameList_t> nameList;
	ast_ptr<ast_node> loopValue; // star_exp_t | Exp_t
AST_END(CompForEach)

AST_NODE(CompFor, "CompFor"_id)
	ast_ptr<Variable_t> varName;
	ast_ptr<Exp_t> startValue;
	ast_ptr<Exp_t> stopValue;
	ast_ptr<for_step_value_t, true> stepValue;
AST_END(CompFor)

AST_NODE(CompInner, "CompInner"_id)
	ast_ptr<Seperator_t> sep;
	ast_sel_list<CompFor_t, CompForEach_t, Exp_t> items;
AST_END(CompInner)

class TableBlock_t;

AST_NODE(Assign, "Assign"_id)
	ast_ptr<Seperator_t> sep;
	ast_sel_list<With_t, If_t, Switch_t, TableBlock_t, Exp_t> values;
AST_END(Assign)

AST_LEAF(update_op, "update_op"_id)
AST_END(update_op)

AST_NODE(Update, "Update"_id)
	ast_ptr<update_op_t> op;
	ast_ptr<Exp_t> value;
AST_END(Update)

AST_LEAF(BinaryOperator, "BinaryOperator"_id)
AST_END(BinaryOperator)

AST_NODE(Assignable, "Assignable"_id)
	ast_ptr<ast_node> item; // AssignableChain_t | Variable_t | SelfName_t
AST_END(Assignable)

class Value_t;

AST_NODE(exp_op_value, "exp_op_value"_id)
	ast_ptr<BinaryOperator_t> op;
	ast_ptr<Value_t> value;
AST_END(exp_op_value)

AST_NODE(Exp, "Exp"_id)
	ast_ptr<Value_t> value;
	ast_list<exp_op_value_t> opValues;
AST_END(Exp)

AST_NODE(Callable, "Callable"_id)
	ast_ptr<ast_node> item; // Variable_t | SelfName_t | VarArg_t | Parens_t
AST_END(Callable)

AST_NODE(variable_pair, "variable_pair"_id)
	ast_ptr<Variable_t> name;
AST_END(variable_pair)

AST_NODE(normal_pair, "normal_pair"_id)
	ast_ptr<ast_node> key; // KeyName_t | [Exp_t] | DoubleString_t | SingleString_t
	ast_ptr<ast_node> value; // Exp_t | TableBlock_t
AST_END(normal_pair)

AST_NODE(simple_table, "simple_table"_id)
	ast_ptr<Seperator_t> sep;
	ast_sel_list<variable_pair_t, normal_pair_t> pairs;
AST_END(simple_table)

class String_t;

AST_NODE(SimpleValue, "SimpleValue"_id)
	ast_ptr<ast_node> value; /*
	const_value_t |
	If_t | Unless_t | Switch_t | With_t | ClassDecl_t | ForEach_t | For_t | While_t | Do_t |
	unary_exp_t |
	TblComprehension_t | TableLit_t | Comprehension_t | FunLit_t | Num_t;
	*/
AST_END(SimpleValue)

AST_LEAF(LuaStringOpen, "LuaStringOpen"_id)
AST_END(LuaStringOpen)

AST_LEAF(LuaStringContent, "LuaStringContent"_id)
AST_END(LuaStringContent)

AST_LEAF(LuaStringClose, "LuaStringClose"_id)
AST_END(LuaStringClose)

AST_NODE(LuaString, "LuaString"_id)
	ast_ptr<LuaStringOpen_t> open;
	ast_ptr<LuaStringContent_t> content;
	ast_ptr<LuaStringClose_t> close;
AST_END(LuaString)

AST_LEAF(SingleString, "SingleString"_id)
AST_END(SingleString)

AST_LEAF(double_string_inner, "double_string_inner"_id)
AST_END(double_string_inner)

AST_NODE(double_string_content, "double_string_content"_id)
	ast_ptr<ast_node> content; // double_string_inner_t | Exp_t
AST_END(double_string_content)

AST_NODE(DoubleString, "DoubleString"_id)
	ast_ptr<Seperator_t> sep;
	ast_list<double_string_content_t> segments;
AST_END(DoubleString)

AST_NODE(String, "String"_id)
	ast_ptr<ast_node> str; // DoubleString_t | SingleString_t | LuaString_t
AST_END(String)

AST_NODE(DotChainItem, "DotChainItem"_id)
	ast_ptr<Name_t> name;
AST_END(DotChainItem)

AST_NODE(ColonChainItem, "ColonChainItem"_id)
	ast_ptr<ast_node> name; // LuaKeyword | Name
	bool switchToDot = false;
AST_END(ColonChainItem)

AST_NODE(Slice, "Slice"_id)
	ast_ptr<ast_node> startValue; // Exp_t | default_value_t
	ast_ptr<ast_node> stopValue; // Exp_t | default_value_t
	ast_ptr<ast_node> stepValue; // Exp_t | default_value_t
AST_END(Slice)

AST_NODE(Parens, "Parens"_id)
	ast_ptr<Exp_t> expr;
AST_END(Parens)

AST_NODE(Invoke, "Invoke"_id)
	ast_ptr<Seperator_t> sep;
	ast_sel_list<Exp_t, SingleString_t, DoubleString_t, LuaString_t> args;
AST_END(Invoke)

class InvokeArgs_t;

AST_NODE(ChainValue, "ChainValue"_id)
	ast_ptr<Seperator_t> sep;
	ast_sel_list<Callable_t, Invoke_t, DotChainItem_t, ColonChainItem_t, Slice_t, Exp_t, String_t, InvokeArgs_t> items;
AST_END(ChainValue)

AST_NODE(AssignableChain, "AssignableChain"_id)
	ast_ptr<Seperator_t> sep;
	ast_sel_list<Callable_t, Invoke_t, DotChainItem_t, ColonChainItem_t, Exp_t, String_t> items;
AST_END(AssignableChain)

AST_NODE(Value, "Value"_id)
	ast_ptr<ast_node> item; // SimpleValue_t | simple_table_t | ChainValue_t | String_t
AST_END(Value)

AST_LEAF(default_value, "default_value"_id)
AST_END(default_value)

AST_NODE(TableLit, "TableLit"_id)
	ast_ptr<Seperator_t> sep;
	ast_sel_list<variable_pair_t, normal_pair_t, Exp_t> values;
AST_END(TableLit)

AST_NODE(TableBlock, "TableBlock"_id)
	ast_ptr<Seperator_t> sep;
	ast_sel_list<variable_pair_t, normal_pair_t> values;
AST_END(TableBlock)

AST_NODE(class_member_list, "class_member_list"_id)
	ast_ptr<Seperator_t> sep;
	ast_sel_list<variable_pair_t, normal_pair_t> values;
AST_END(class_member_list)

AST_NODE(ClassBlock, "ClassBlock"_id)
	ast_ptr<Seperator_t> sep;
	ast_sel_list<class_member_list_t, Statement_t> contents;
AST_END(ClassBlock)

AST_NODE(ClassDecl, "ClassDecl"_id)
	ast_ptr<Assignable_t, true> name;
	ast_ptr<Exp_t, true> extend;
	ast_ptr<ClassBlock_t, true> body;
AST_END(ClassDecl)

AST_NODE(export_values, "export_values"_id)
	ast_ptr<NameList_t> nameList;
	ast_ptr<ExpListLow_t, true> valueList;
AST_END(export_values)

AST_LEAF(export_op, "export_op"_id)
AST_END(export_op)

AST_NODE(Export, "Export"_id)
	ast_ptr<ast_node> item; // ClassDecl_t | export_op_t | export_values_t
AST_END(Export)

AST_NODE(FnArgDef, "FnArgDef"_id)
	ast_ptr<ast_node> name; // Variable_t | SelfName_t
	ast_ptr<Exp_t, true> defaultValue;
AST_END(FnArgDef)

AST_NODE(FnArgDefList, "FnArgDefList"_id)
	ast_ptr<Seperator_t> sep;
	ast_list<FnArgDef_t> definitions;
	ast_ptr<VarArg_t, true> varArg;
AST_END(FnArgDefList)

AST_NODE(outer_var_shadow, "outer_var_shadow"_id)
	ast_ptr<NameList_t, true> varList;
AST_END(outer_var_shadow)

AST_NODE(FnArgsDef, "FnArgsDef"_id)
	ast_ptr<FnArgDefList_t, true> defList;
	ast_ptr<outer_var_shadow_t, true> shadowOption;
AST_END(FnArgsDef)

AST_LEAF(fn_arrow, "fn_arrow"_id)
AST_END(fn_arrow)

AST_NODE(FunLit, "FunLit"_id)
	ast_ptr<FnArgsDef_t, true> argsDef;
	ast_ptr<fn_arrow_t> arrow;
	ast_ptr<Body_t, true> body;
AST_END(FunLit)

AST_NODE(NameOrDestructure, "NameOrDestructure"_id)
	ast_ptr<ast_node> item; // Variable_t | TableLit_t
AST_END(NameOrDestructure)

AST_NODE(AssignableNameList, "AssignableNameList"_id)
	ast_ptr<Seperator_t> sep;
	ast_list<NameOrDestructure_t> items;
AST_END(AssignableNameList)

AST_NODE(InvokeArgs, "InvokeArgs"_id)
	ast_ptr<Seperator_t> sep;
	ast_sel_list<Exp_t, TableBlock_t> args;
AST_END(InvokeArgs)

AST_LEAF(const_value, "const_value"_id)
AST_END(const_value)

AST_NODE(unary_exp, "unary_exp"_id)
	ast_ptr<Exp_t> item;
AST_END(unary_exp)

AST_NODE(Assignment, "Assignment"_id)
	ast_ptr<ExpList_t> assignable;
	ast_ptr<ast_node> target; // Update_t | Assign_t
AST_END(Assignment)

AST_NODE(if_else_line, "if_else_line"_id)
	ast_ptr<Exp_t> condition;
	ast_ptr<ast_node> elseExpr; // Exp_t | default_value_t
AST_END(if_else_line)

AST_NODE(unless_line, "unless_line"_id)
	ast_ptr<Exp_t> condition;
AST_END(unless_line)

AST_NODE(statement_appendix, "statement_appendix"_id)
	ast_ptr<ast_node> item; // if_else_line_t | unless_line_t | CompInner_t
AST_END(statement_appendix)

AST_LEAF(BreakLoop, "BreakLoop"_id)
AST_END(BreakLoop)

AST_NODE(Statement, "Statement"_id)
	ast_sel<Import_t, While_t, For_t, ForEach_t,
		Return_t, Local_t, Export_t, BreakLoop_t,
		Assignment_t, ExpList_t> content;
	ast_ptr<statement_appendix_t, true> appendix;
AST_END(Statement)

class Block_t;

AST_NODE(Body, "Body"_id)
	ast_ptr<ast_node> content; // Block | Statement
AST_END(Body)

AST_NODE(Block, "Block"_id)
	ast_ptr<Seperator_t> sep;
	ast_list<Statement_t> statements;
AST_END(Block)

AST_NODE(File, "File"_id)
	ast_ptr<Block_t> block;
AST_END(File)

} // namespace MoonP
