// YARD Grammar for the C language
// Dedicated to the public domain by Christopher Diggin
//
// Based on the YACC grammar found at:
// http://www.lysator.liu.se/c/ANSI-C-grammar-y.html
// 
// Some of the same problems encountered when porting YACC grammars
// to Spirit were encountered. We need to avoid infinite loops by converting 
// left-recursive rule forms to iterative forms. 
// Often this is done using the "DelimitedList" combinator.
// Generally you should not make direct self-references in the grammar. 
// See: http://spirit.sourceforge.net/old_docs/v1_6/doc/faq.html


#ifndef YARD_C_GRAMMAR_HPP
#define YARD_C_GRAMMAR_HPP

#include "yard_text_grammar.hpp"

namespace c_grammar
{
	using namespace yard;
	using namespace text_grammar;

	struct Exp;
	struct Op;
	struct PostfixExp;
	struct ArgExpList;
	struct UnaryExp;;
	struct UnaryOp;
	struct CastExp;
	struct MulExp;
	struct AddExp;
	struct ShiftExp;
	struct RelExp ;
	struct EqExp;
	struct AndExp;
	struct XorExp;
	struct InclOrExp;
	struct LogAndExp;
	struct LogOrExp;
	struct CondExp;
	struct AssExp;
	struct AssOp;
	struct Exp;
	struct ConstExp;
	struct Declaration;
	struct DeclSpecs;
	struct InitDeclList;
	struct InitDecl;
	struct StorClassSpec;
	struct TypeSpec;
	struct StructOrUnionSpec;
	struct StructOrUnion;
	struct StructDeclarationList;
	struct StructDeclaration;
	struct SpecQualList;
	struct StructDeclaratorList;
	struct StructDeclarator;
	struct EnumSpec;
	struct EnumList;
	struct Enum;
	struct TypeQual;
	struct Declarator;
	struct DirDecl;
	struct Ptr;
	struct TypeQualList;
	struct ParamTypeList;
	struct ParamList;
	struct ParamDecl;
	struct IdList;
	struct TypeName;
	struct AbsDecl;
	struct DirAbsDecl;
	struct Init;
	struct InitList;
	struct Statement;
	struct LabelStatement;
	struct CompStatement;
	struct DeclList;
	struct StatementList;
	struct ExpStatement;
	struct SelStatement;
	struct IfStatement ;
	struct SwitchStatement;
	struct IterStatement ;
	struct WhileStatement;
	struct DoStatement;
	struct ForStatement;
	struct JmpStatement;
	struct GotoStatement;
	struct ContStatement;
	struct BreakStatement;
	struct RetStatement;
	struct TransUnit;
	struct ExtDecl;
	struct FunDef;

	struct NewLine
		: Or<CharSeq<'\r', '\n'>, CharSeq<'\n'> > 
	{ };

	struct PreProcDir
		: Seq<Char<'#'>, UntilPast<NewLine> > 
	{ };

	struct LineComment 
		: Seq<CharSeq<'/', '/'>, UntilPast<NewLine> > 
	{ };

	struct FullComment 
		: Seq<CharSeq<'/', '*'>, UntilPast<CharSeq<'*', '/'> > > 
	{ };

	struct Comment : 
		Or<LineComment, FullComment> 
	{ };

	struct WS
		: Star<Or<Char<' '>, Char<'\t'>, NewLine, Comment, PreProcDir, Char<'\r'>, Char<'\v'>, Char<'\f'> > >
	{ };

	struct StringCharLiteral 
		: Or<Seq<Char<'\\'>, NotChar<'\n'> >, AnyCharExcept<CharSet<'\n', '\"', '\'' > > > { };

	struct CharLiteral 
		: Seq<Char<'\''>, StringCharLiteral, Char<'\''> >  
	{ };

	struct StringLiteral 
		: Seq<Char<'\"'>, Star<StringCharLiteral>, Char<'\"'> > 
	{ };

	struct BinaryDigit 
		: Or<Char<'0'>, Char<'1'> > 
	{ };

	struct BinNumber 
		: Seq<CharSeq<'0', 'b'>, Plus<BinaryDigit>, NotAlphaNum, WS> 
	{ };

	struct HexNumber 
		: Seq<CharSeq<'0', 'x'>, Plus<HexDigit>, NotAlphaNum, WS> 
	{ };

	struct DecNumber 
		: Seq<Opt<Char<'-'> >, Plus<Digit>, Opt<Seq<Char<'.'>, Star<Digit> > >, NotAlphaNum, WS> 
	{ };

	template<typename R>
	struct Tok
		: Seq<R, WS>
	{ };

	struct Id
		: Tok<Ident>
	{ };

	template<char C>
	struct CharTok
		: Seq<Char<C>, WS>
	{ };

	struct Literal 
		: Tok<Or<BinNumber, HexNumber, DecNumber, CharLiteral, StringLiteral > >  
	{ };		

	struct Sym 
		: CharSetParser<CharSet<'~','!','@','#','$','%','^','&','*','-','+','|','\\','<','>','/','?'> > 
	{ };

	struct LEFT_OP	: Tok<Seq<Char<'<'>,Char<'<'>, NotAt<Char<'='> > > > { };
	struct RIGHT_OP : Tok<Seq<Char<'>'>, Char<'>'>, NotAt<Char<'='> > > > { };
	struct LTEQ_OP	: Tok<Seq<Char<'<'>, Char<'='> > > { };
	struct GTEQ_OP	: Tok<Seq<Char<'>'>, Char<'='> > > { };
	struct EQ_OP	: Tok<Seq<Char<'='>, Char<'='> > > { };
	struct NEQ_OP	: Tok<Seq<Char<'!'>, Char<'='> > > { };
	struct AND_OP	: Tok<Seq<Char<'&'>, Char<'&'>, NotAt<Char<'='> > > > { };
	struct OR_OP	: Tok<Seq<Char<'|'>, Char<'|'>, NotAt<Char<'='> > > > { };
	struct BIN_AND_OP	: Tok<Seq<Char<'&'>, NotAt<Char<'='> > > > { };
	struct BIN_OR_OP	: Tok<Seq<Char<'|'>, NotAt<Char<'='> > > > { };
	struct XOR_OP	: Tok<Seq<Char<'^'>, NotAt<Char<'='> > > > { };
	struct MUL_OP	: Tok<Seq<Char<'*'>, NotAt<Char<'='> > > > { };
	struct DIV_OP	: Tok<Seq<Char<'/'>, NotAt<Char<'='> > > > { };
	struct MOD_OP	: Tok<Seq<Char<'%'>, NotAt<Char<'='> > > > { };
	struct COMPL_OP : Tok<Char<'~'> > { };
	struct NOT_OP	: Tok<Seq<Char<'!'>, NotAt<Char<'='> > > > { };
	struct DOT_OP	: Tok<Char<'.'> > { };
	struct ARROW_OP	: Tok<CharSeq<'-', '>'> > { };
	struct INC_OP	: Tok<CharSeq<'+', '+'> > { };
	struct DEC_OP	: Tok<CharSeq<'-', '-'> > { };
	struct ADD_OP	: Tok<Seq<Char<'+'>, NotAt<Or<Char<'+'>, Char<'='> > > > > { };
	struct SUB_OP	: Tok<Seq<Char<'-'>, NotAt<Or<Char<'-'>, Char<'='> > > > > { };
	struct LT_OP	: Tok<Seq<Char<'<'>, NotAt<Or<Char<'<'>, Char<'='> > > > > { };
	struct GT_OP	: Tok<Seq<Char<'>'>, NotAt<Or<Char<'>'>, Char<'='> > > > > { };

	template<typename T>
	struct Keyword :
		Tok<Seq<T, NotAlphaNum > > 
	{};

	struct CASE		: Keyword<CharSeq<'c','a','s','e'> > { };
	struct DEFAULT	: Keyword<CharSeq<'d','e','f','a','u','l','t'> > { };
	struct IF		: Keyword<CharSeq<'i', 'f' > > { };
	struct WHILE	: Keyword<CharSeq<'w','h','i','l','e' > > { };
	struct DO		: Keyword<CharSeq<'d','o' > > { };
	struct FOR		: Keyword<CharSeq<'f','o','r' > > { };
	struct BREAK	: Keyword<CharSeq<'b','r','e','a','k' > > { };
	struct CONTINUE	: Keyword<CharSeq<'c','o','n','t','i','n','u','e' > > { };
	struct SWITCH	: Keyword<CharSeq<'s','w','h','i','t','c','h' > > { };
	struct STRUCT	: Keyword<CharSeq<'s','t','r','u','c','t' > > { };
	struct UNION	: Keyword<CharSeq<'u','n','i','o','n' > > { };
	struct ENUM		: Keyword<CharSeq<'e','n','u','m' > > { };
	struct GOTO		: Keyword<CharSeq<'g','o','t','o' > > { };
	struct RETURN	: Keyword<CharSeq<'r','e','t','u','r','n' > > { };
	struct ELLIPSIS	: Keyword<CharSeq<'.','.','.' > > { };
	struct TYPEDEF	: Keyword<CharSeq<'t','y','p','e','d','e','f' > > { };
	struct REGISTER : Keyword<CharSeq<'r','e','g','i','s','t','e','r' > > { };
	struct AUTO		: Keyword<CharSeq<'a','u','t','o' > > { };
	struct STATIC	: Keyword<CharSeq<'s','t','a','t','i','c' > > { };
	struct EXTERN	: Keyword<CharSeq<'e','x','t','e','r','n' > > { };
	struct CONST	: Keyword<CharSeq<'c','o','n','s','t' > > { };
	struct VOLATILE	: Keyword<CharSeq<'v','o','l','a','t','i','l','e' > > { };
	struct LONG		: Keyword<CharSeq<'l','o','n','g' > > { };
	struct SHORT	: Keyword<CharSeq<'s','h','o','r','t' > > { };
	struct SIGNED	: Keyword<CharSeq<'s','i','g','n','e','d' > > { };
	struct UNSIGNED : Keyword<CharSeq<'u','n','s','i','g','n','e','d' > > { };
	struct SIZEOF	: Keyword<CharSeq<'s','i','z','e','o','f' > > { };
	struct ELSE		: Keyword<CharSeq<'e','l','s','e'> > { };

	struct AssOp
		: Or<
			Or<
				Tok<Seq<Char<'='>, NotAt<Char<'='> > > >, 
				Tok<CharSeq<'*', '='> >,
				Tok<CharSeq<'/', '='> >,
				Tok<CharSeq<'%', '='> >,
				Tok<CharSeq<'+', '='> >,
				Tok<CharSeq<'-', '='> >
			>,
			Or<
				Tok<CharSeq<'<', '<', '='> >,
				Tok<CharSeq<'>', '>', '='> >,
				Tok<CharSeq<'&', '='> >,
				Tok<CharSeq<'|', '='> >,
				Tok<CharSeq<'&', '&', '='> >,
				Tok<CharSeq<'|', '|', '='> >,
				Tok<CharSeq<'^', '='> >
			>
		> 
	{ };	

	template<typename R, typename D>
	struct DelimitedList
		: Seq<R, Star<Seq<D, R> > >
	{ };

	template<typename R>
	struct CommaList
		: DelimitedList<R, CharTok<','> > 
	{ };

	template<typename R>
	struct Braced
		: Seq<CharTok<'{'>, R, CharTok<'}'> >
	{ };

	template<typename R>
	struct Paranthesized
		: Seq<CharTok<'('>, R, CharTok<')'> >
	{ };

	template<typename R>
	struct Bracketed
		: Seq<CharTok<'['>, R, CharTok<']'> >
	{ };

	struct PrimaryExp 
		: Or<Id, Literal, Paranthesized<Exp> > 
	{ };

	struct PostfixSuffix
		: Or<
			Bracketed<Exp>,
			Paranthesized<Opt<ArgExpList> >,
			Seq<DOT_OP, Id>,
			Seq<ARROW_OP, Id>,
			INC_OP,
			DEC_OP
		>
	{ };

	struct PostfixExp
		: Seq<
			PrimaryExp, 
			Star<PostfixSuffix> 
		> 
	{ };

	struct ArgExpList
		: CommaList<AssExp> 
	{ };

	struct SizeofExp
		: Seq<SIZEOF, Or<Paranthesized<TypeName>, UnaryExp >  >
	{ };

	struct UnaryExpPrefix
		: Or<INC_OP, DEC_OP> 
	{ };

	// I am explicitly disallowing "sizeof sizeof expression" 
	// Which is fine, that would be just silly anyway.
	struct UnaryExp
		: Or<
			SizeofExp, 
			Seq<
				Star<UnaryExpPrefix>, 
				Or<
					Seq<UnaryOp, CastExp >, 
					PostfixExp
				> 
			>
		>
	{ };

	struct UnaryOp 
		: Or<
			BIN_AND_OP,
			MUL_OP,
			ADD_OP,
			SUB_OP,
			COMPL_OP,
			NOT_OP
		> 
	{ };

	// TODO: this is not quite correct, but it works
	struct CastExp
		: Or<
			Seq<Star<Paranthesized<TypeName> >, UnaryExp>,
			UnaryExp
		>
	{ };

	struct MulExp
		: DelimitedList<CastExp, Or<MUL_OP, DIV_OP, MOD_OP> > 
	{ };

	struct AddExp
		: DelimitedList<MulExp, Or<ADD_OP, SUB_OP> >
	{ };

	struct ShiftExp
		: DelimitedList<AddExp, Or<LEFT_OP, RIGHT_OP> > 
	{ };

	struct RelExp 
		: DelimitedList<ShiftExp, Or<LT_OP, GT_OP, LTEQ_OP, GTEQ_OP> > 
	{ };
	
	struct EqExp
		: DelimitedList<RelExp, Or<EQ_OP, NEQ_OP> > 
	{ };

	struct AndExp
		: DelimitedList<EqExp, BIN_AND_OP > 
	{ };

	struct XorExp
		: DelimitedList<AndExp, XOR_OP > 
	{ };

	struct InclOrExp
		: DelimitedList<XorExp, BIN_OR_OP > 
	{ };

	struct LogAndExp
		: DelimitedList<InclOrExp, AND_OP > 
	{ };
	
	struct LogOrExp
		: DelimitedList<LogAndExp, OR_OP > 
	{ };
	
	struct CondExp 
		: DelimitedList<LogOrExp, Seq<CharTok<'?'>, Exp, CharTok<':'> > >
	{ };
		
	struct AssExp
		: Seq<Star<Seq<UnaryExp, AssOp> >, CondExp>
	{ };	

	struct Exp
		: CommaList<AssExp> 
	{ };

	struct ConstExp
		: CondExp 
	{ };

	struct Declaration
		: Seq<DeclSpecs, Opt<InitDeclList>, CharTok<';'> >
	{ };

	struct DeclSpecs
		: Seq<Star<Or<StorClassSpec, TypeQual> >, TypeSpec> 
	{ };

	struct InitDeclList
		: CommaList<InitDecl> 
	{ };

	struct InitDecl
		: Seq<Declarator, Opt<Seq<CharTok<'='>, Init> > >
	{ };

	struct StorClassSpec
		: Or<TYPEDEF, EXTERN, STATIC, AUTO, REGISTER>
	{ };

	struct TypeSpec
		: Id
	{ };

	struct StructOrUnionSpec
		: Seq<
			StructOrUnion, 
			Or<
				Seq<Id, Braced<StructDeclarationList> >,
				Braced<StructDeclarationList>, 
				Id
			>
		> 
	{ };

	struct StructOrUnion
		: Or<STRUCT, UNION> 
	{ };

	struct StructDeclarationList
		: Plus<StructDeclaration> 
	{ };

	struct StructDeclaration
		: Seq<SpecQualList, StructDeclaratorList, CharTok<';'> > 
	{ };

	struct SpecQualList
		: Plus<Or<TypeSpec, TypeQual> > 
	{ };

	struct StructDeclaratorList
		: CommaList<StructDeclarator>
	{ };

	struct StructDeclarator
		: Or<
			Seq<Declarator, Opt<Seq<CharTok<':'>, ConstExp> > >,
			Seq<Opt<Declarator>, CharTok<':'>, ConstExp>
		> 
	{ };

	struct EnumSpec
		: Seq<
			ENUM,
			Or<
				Braced<EnumList>,
				Seq<Id, Braced<EnumList> >,
				Id
			>
		>
	{ };
	
	struct EnumList
		: CommaList<Enum> 
	{ };

	struct Enum
		: Seq<Id, Opt<Seq<CharTok<'='>, ConstExp> > >
	{ };

	// This is cheating a bit because "signed", "unsigned", and "struct" are not 
	// really type qualifiers. 
	struct TypeQual
		: Or<CONST, VOLATILE, SIGNED, UNSIGNED, STRUCT>
	{ };
	
	struct Declarator
		: Seq<Opt<Ptr> , DirDecl>
	{ };

	struct DirDeclPrefix 
		: Plus<Or<Id,Paranthesized<Declarator> > >
	{ };
		
	struct DirDeclSuffix 
		: Or<
			Bracketed<Opt<ConstExp> >,
			Paranthesized<Opt<Or<ParamTypeList, IdList> > >
		>
	{ };
		
	struct DirDecl
		: Seq<DirDeclPrefix, Opt<DirDeclSuffix> >
	{ };

	struct Ptr
		: Plus<Seq<CharTok<'*'>, Opt<TypeQualList> > >
	{ };

	struct TypeQualList
		: Star<TypeQual> { };

	struct ParamTypeList
		: Seq<Star<ParamList>, Opt<Seq<CharTok<','>, ELLIPSIS> > > 
	{ };

	struct ParamList
		: CommaList<ParamDecl>
	{ };

	struct ParamDecl
		: Seq<DeclSpecs, Opt<Or<Declarator, AbsDecl> > > 
	{ };

	struct IdList
		: CommaList<Id>
	{ };

	struct TypeName
		: Seq<SpecQualList, Opt<AbsDecl> >
	{ };
	
	struct AbsDecl
		: Seq<Opt<Ptr>, DirAbsDecl> 
	{ };

	struct DirAbsDecl
		: Or<
			Paranthesized<AbsDecl>,
			Star<
				Or<
					Paranthesized<Opt<ParamTypeList> >, 
					Bracketed<Opt<ConstExp> >
				>
			>
		>
	{ };

	struct Init
		: Or<
			AssExp,
			Braced<Seq<InitList, Opt<CharTok<','> > > >
		> { };

	struct InitList
		:  CommaList<Init>
	{ };
	
	struct Statement
		: Or<
			LabelStatement, 
			CompStatement, 
			SelStatement, 
			IterStatement, 
			JmpStatement, 
			ExpStatement
		>
	{ };

	struct LabelStatement
		: Or<
			Seq<Id, CharTok<':'>, Statement>,
			Seq<CASE, ConstExp, CharTok<':'>, Statement>,
			Seq<DEFAULT, CharTok<':'>, Statement>
		> { };

	struct CompStatement
		: Braced<Seq<Opt<DeclList>, Opt<StatementList> > >
	{ };

	struct DeclList
		: Plus<Declaration>
	{ };

	struct StatementList
		: Plus<Statement>
	{ };

	struct ExpStatement
		: Seq<Opt<Exp>, CharTok<';'> >
	{ };
	
	struct SelStatement
		: Or<IfStatement, SwitchStatement>
	{ };

	struct IfStatement 
		: Seq<IF, Paranthesized<Exp>, Statement, Opt<Seq<ELSE, Statement>  > > 
	{ };

	struct SwitchStatement
		: Seq<SWITCH, Paranthesized<Exp>, Statement> 
	{ };

	struct IterStatement 
		: Or<WhileStatement, DoStatement, ForStatement>
	{ };

	struct WhileStatement 
		: Seq<WHILE, Paranthesized<Exp>, Statement>
	{ };

	struct DoStatement 
		: Seq<DO, Statement, WHILE, Paranthesized<Exp>, CharTok<';'> > 
	{ };

	struct ForStatement
		: Seq<FOR, Paranthesized<Seq<ExpStatement, ExpStatement, Opt<Exp> > >, Statement> 
	{ };

	struct JmpStatement
		: Or<GotoStatement, ContStatement, BreakStatement, RetStatement>
	{ };

	struct GotoStatement
		: Seq<GOTO, Id, CharTok<';'> > 
	{ };

	struct ContStatement
		: Seq<CONTINUE, CharTok<';'> > 
	{ };

	struct BreakStatement
		: Seq<BREAK, CharTok<';'> > 
	{ };

	struct RetStatement
		: Seq<RETURN, Opt<Exp>, CharTok<';'> > 
	{ };

	struct TransUnit
		: Plus<ExtDecl>
	{ };

	struct ExtDecl
		: Or<FunDef, Declaration>
	{ };

	struct FunDeclSpecs
		: DeclSpecs
	{ };

	struct FunDeclarator
		: Declarator
	{ };

	struct FunDeclList
		: DeclList
	{ };

	struct FunDef
		: Seq<Opt<FunDeclSpecs>, FunDeclarator, Opt<FunDeclList>, CompStatement>
	{ };

	struct File 
		: Seq<WS, TransUnit, EndOfInput>
	{ };
}

#endif 
