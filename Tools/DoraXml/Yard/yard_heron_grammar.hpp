/*
    Author: Christopher Diggins
    License: MIT Licence 1.0
    Website: http://www.heron-language.com
    
    YARD Grammar for the JAction language
*/

#ifndef YARD_HERON_GRAMMAR_HPP
#define YARD_HERON_GRAMMAR_HPP

#include "yard_text_grammar.hpp"

namespace heron_grammar
{
    using namespace yard;
    using namespace text_grammar;

    struct Expr;
    struct TypeExpr;
    struct SimpleExpr;
    struct Statement;
    struct StatementList;
    struct CodeBlock;

    struct SymChar :
        CharSetParser<CharSet<'~','!','@','#','$','%','^','&','*','-','+','|','\\','<','>','/','?',',','.','='> > { };

    struct NewLine : 
        Or<CharSeq<'\r', '\n'>, CharSeq<'\n'> > { };

    struct LineComment : 
        Seq<CharSeq<'/', '/'>, UntilPast<NewLine> > { };
    
    struct FullComment : 
        Seq<CharSeq<'/', '*'>, UntilPast<CharSeq<'*', '/'> > >    { };

    struct Comment :
        Or<LineComment, FullComment> { };

    struct WS : 
        Star<Or<Char<' '>, Char<'\t'>, NewLine, Comment, Char<'\r'>, Char<'\v'>, Char<'\f'> > >    { };

    template<typename R>
    struct Tok : 
        Seq<R, WS> { };

    template<typename T>
    struct Keyword : 
        Tok<Seq<T, NotAlphaNum > > { };

    template<char C>
    struct CharTok :
        Seq<Char<C>, WS> { };

    struct SymName : 
        Plus<SymChar> { };

    struct AlphaName :
        Ident { };

    struct Name :
        Or<AlphaName, SymName> { };

    template<typename R, typename D>
    struct DelimitedList : 
       Or<Seq<R, Plus<Seq<D, R> > >, Opt<R> >
    { };

    template<typename First, typename T, typename Last>
    struct StoreList :
        Seq<
            First, 
            Or<
                Last, 
                Seq<
                    Store<T>, 
                    Star<
                        Seq<
                            CharTok<','>, 
                            Store<T> 
                        > 
                    >,
                    Finao<Last>
                >
            > 
        >
    { };


    template<typename R>
    struct CommaList : 
       DelimitedList<R, CharTok<','> > { };

    template<typename R>
    struct Braced : 
        Seq<CharTok<'{'>, R, CharTok<'}'> > { };

    template<typename R>
    struct BracedList : 
        Seq<CharTok<'{'>, Star<R>, CharTok<'}'> > { };

    template<typename R>
    struct StoreBracedList : 
        Seq<CharTok<'{'>, Star<Store<R> >, CharTok<'}'> > { };

    template<typename R>
    struct BracedCommaList : 
        Braced<CommaList<R> > { };

    template<typename R>
    struct Paranthesized  : 
        Seq<CharTok<'('>, R, CharTok<')'> > { };

    template<typename R>
    struct ParanthesizedCommaList : 
        Paranthesized<CommaList<R> > { };

    struct StringCharLiteral : 
        Or<Seq<Char<'\\'>, NotChar<'\n'> >, AnyCharExcept<CharSet<'\n', '\"', '\'' > > > { };

    struct CharLiteral : 
        Seq<Char<'\''>, StringCharLiteral, Char<'\''> > { };

    struct StringLiteral : 
        Seq<Char<'\"'>, Star<StringCharLiteral>, Char<'\"'> > { };

    struct BinaryDigit : 
        Or<Char<'0'>, Char<'1'> > { };

    struct BinNumber : 
        Seq<CharSeq<'0', 'b'>, Plus<BinaryDigit> > { };

    struct HexNumber : 
        Seq<CharSeq<'0', 'x'>, Plus<HexDigit> > { };

    struct DecNumber : 
        Seq<Opt<Char<'-'> >, Plus<Digit>, Opt<Seq<Char<'.'>, Star<Digit> > > > { };

    struct NEW : Keyword<CharSeq<'n','e','w'> > { };
    struct DELETE : Keyword<CharSeq<'d','e','l','e','t','e'> > { };
    struct VAR : Keyword<CharSeq<'v','a','r'> > { };
    struct ELSE : Keyword<CharSeq<'e','l','s','e'> > { };
    struct IF : Keyword<CharSeq<'i','f'> > { };
    struct FOREACH : Keyword<CharSeq<'f','o','r','e','a','c','h'> > { };
    struct FOR : Keyword<CharSeq<'f','o','r'> > { };
    struct WHILE : Keyword<CharSeq<'w','h','i','l','e'> > { };
    struct IN : Keyword<CharSeq<'i','n'> > { };
    struct CASE : Keyword<CharSeq<'c','a','s','e'> > { };
    struct BREAK : Keyword<CharSeq<'b','r','e','a','k'> > { };
    struct SWITCH : Keyword<CharSeq<'s','w','i','t','c','h'> > { };
    struct RETURN : Keyword<CharSeq<'r','e','t','u','r','n'> > { };
    struct DEFAULT : Keyword<CharSeq<'d','e','f','a','u','l','t'> > { };
    struct FUNCTION : Keyword<CharSeq<'f','u','n','c','t','i','o','n'> > { };

    struct Literal :
        Tok<
            Or<
                Store<BinNumber>, 
                Store<HexNumber>, 
                Store<DecNumber>, 
                Store<CharLiteral>, 
                Store<StringLiteral> 
            > 
        > { };

    struct TypeArgs :
        StoreList<CharTok<'<'>, TypeExpr, CharTok<'>'> > { };

    struct TypeExpr : 
        Seq<Store<Name>, WS, Opt<Store<TypeArgs> > > { };

    struct TypeDecl :
        NoFailSeq<CharTok<':'>, Store<TypeExpr> > { };

    struct Arg :
        Seq<Store<Name>, WS, Opt<TypeDecl> > { };

    struct ArgList :        
        StoreList<CharTok<'('>, Arg, CharTok<')'> > { };

    struct AnonFxn :
        Seq<FUNCTION, Store<ArgList>, Opt<TypeDecl>, Opt<WS>, Store<CodeBlock> > { };

    struct DelExpr :
        NoFailSeq<DELETE, Store<Expr> > { };

    struct ParanthesizedExpr :
        NoFailSeq<CharTok<'('>, Opt<Store<Expr> >, CharTok<')'> > { };

    struct BracketedExpr :
        NoFailSeq<CharTok<'['>, Store<Expr>, CharTok<']'> > { };

    struct NewExpr :
        NoFailSeq<NEW, Store<TypeExpr>, Store<ParanthesizedExpr> > { };

    struct SimpleExpr :
        Or<Store<NewExpr>,
            Store<DelExpr>,
            Seq<Store<Name>, WS>,
            Store<Literal>,
            Store<AnonFxn>,
            Store<ParanthesizedExpr>,
            Store<BracketedExpr>
        > { };

    // Note that unlike many other grammar designs, I have delayed 
    // prcedence handling to the AST processing mechanism.
    struct Expr :
        Plus<Store<SimpleExpr> > { };

    struct Initializer :
        Seq<CharTok<'='>, Store<Expr> > { };

    struct CodeBlock :
        NoFailSeq<CharTok<'{'>, StatementList, Finao<CharTok<'}'> > > { };

    struct Eos : 
        CharTok<';'> { };

    struct VarDecl :
        NoFailSeq<VAR, Store<Name>, WS, Opt<TypeDecl>, Opt<Initializer>, Eos > { };

    struct ElseStatement :
        NoFailSeq<ELSE, Store<Statement> > { };

    struct IfStatement :
        NoFailSeq<IF, Paranthesized<Store<Expr> >, Store<Statement>, Opt<ElseStatement> > { };

    struct ForEachStatement :
        NoFailSeq<FOREACH, CharTok<'('>, Store<Name>, WS, Opt<TypeDecl>, 
            IN, Store<Expr>, CharTok<')'>, Store<Statement> > { };

    struct ForEachIndexStatement :
        NoFailSeq<FOREACH, CharTok<'('>, Store<Name>, WS, Opt<TypeDecl>, 
            IN, Store<Expr>, CharTok<')'>, Store<Statement> > { };

    struct ForStatement :
        NoFailSeq<FOR, CharTok<'('>, Store<VarDecl>, Seq<Store<Expr>, Eos >, 
            Seq<Store<Expr>, CharTok<')'> >, Store<Statement> > { };

    struct ExprStatement :
        Seq<Store<Expr>, Eos> { };

    struct ReturnStatement :
        NoFailSeq<RETURN, Store<Expr>, Eos> { };    

    struct BreakStatement :
        NoFailSeq<BREAK, Eos> { };    

    struct CaseStatement :
        NoFailSeq<CASE, Paranthesized<Store<Expr> >, Store<CodeBlock> > { };

    struct DefaultStatement :
        NoFailSeq<DEFAULT, Store<CodeBlock> > { };

    struct SwitchStatement :
        NoFailSeq<SWITCH, Paranthesized<Store<Expr> >, CharTok<'{'>, Star<Store<CaseStatement> >, 
            Opt<Store<DefaultStatement> >, CharTok<'}'> > { };

    struct WhileStatement :
        NoFailSeq<WHILE, Paranthesized<Store<Expr> >, Store<CodeBlock> > { };
    
    struct EmptyStatement :
        Eos { };

    struct Statement :
        Or<
            Or<
                Store<CodeBlock>,
                Store<VarDecl>,
                Store<IfStatement>,
                Store<SwitchStatement>,
                Store<ForEachStatement>,
                Store<ForStatement>,
                Store<WhileStatement>
            >,
            Or<
                Store<BreakStatement>,
                Store<ReturnStatement>,
                Store<ExprStatement>,
                Store<EmptyStatement>
            >
       > { };

    struct StatementList :
        Star<Store<Statement> > { };

    struct Function :
        NoFailSeq<FUNCTION, Store<Name>, WS, Store<ArgList>, Opt<TypeDecl>, Store<CodeBlock> > { };    
    
    struct Functions : 
        Star<Store<Function> > { };    

    struct ScriptFile :
        Seq<WS, Star<Store<Function> >, Finao<EndOfInput> > { };    
}

#endif
