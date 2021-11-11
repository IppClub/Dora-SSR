// Dedicated to the public domain by Christopher Diggins 
// This work can be used, modified, or redistributed 
// without restriction or obligation and without warrantee.

// YARD Grammar for a subset of Scheme up to the "external representation"
// http://www.cs.indiana.edu/scheme-repository/R4RS/r4rs_9.html#SEC67

#ifndef YARD_SCHEME_GRAMMAR_HPP
#define YARD_SCHEME_GRAMMAR_HPP

/*
	<token> ==> <identifier> | <boolean> | <number>
		 | <character> | <string>
		 | ( | ) | #( | ' | `{} | , | , | .
	<delimiter> ==> <whitespace> | ( | ) | " | ;
	<whitespace> ==> <space or newline>
	<comment> ==> ; \= <all subsequent characters up to a line break>
	<atmosphere> ==> <whitespace> | <comment>
	<intertoken space> ==> <atmosphere>*
	<identifier> ==> <initial> <subsequent>*
		 | <peculiar identifier>
	<initial> ==> <letter> | <special initial>
	<letter> ==> a | b | c | ... | z
	<special initial> ==> ! | \$ | \% | \verb"&" | * | / | : | < | =
		 | > | ? | \verb" " | \verb"_" | \verb"^"
	<subsequent> ==> <initial> | <digit>
		 | <special subsequent>
	<digit> ==> 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
	<special subsequent> ==> . | + | -
	<peculiar identifier> ==> + | - | ...
	<boolean> ==> #t | #f
	<character> ==> #\ <any character>
		 | #\ <character name>
	<character name> ==> space | newline
	<string> ==> " <string element>* "
	<string element> ==> <any character other than " or \>
		 | \" | \\
	<number> ==> <num 2> | <num 8>
		 | <num 10> | <num 16>

	The following rules for <num R>, <complex R>, <real R>, <ureal R>, <uinteger R>, and <prefix R> 
	should be replicated for R = 2, 8, 10, and 16. There are no rules for <decimal 2>, <decimal 8>, 
	and <decimal 16>, which means that numbers containing decimal points or exponents must be in decimal radix. 

	<num R> ==> <prefix R> <complex R>
	<complex R> ==> <real R> | <real R>  <real R>
		 | <real R> + <ureal R> i | <real R> - <ureal R> i
		 | <real R> + i | <real R> - i
		 | + <ureal R> i | - <ureal R> i | + i | - i
	<real R> ==> <sign> <ureal R>
	<ureal R> ==> <uinteger R>
		 | <uinteger R> / <uinteger R>
		 | <decimal R>
	<decimal 10> ==> <uinteger 10> <suffix>
		 | . <digit 10>+ #* <suffix>
		 | <digit 10>+ . <digit 10>* #* <suffix>
		 | <digit 10>+ #+ . #* <suffix>
	<uinteger R> ==> <digit R>+ #*
	<prefix R> ==> <radix R> <exactness>
		 | <exactness> <radix R>
	<suffix> ==> <empty>
		 | <exponent marker> <sign> <digit 10>+
	<exponent marker> ==> e | s | f | d | l
	<sign> ==> <empty>  | + |  -
	<exactness> ==> <empty> | #i | #e
	<radix 2> ==> #b
	<radix 8> ==> #o
	<radix 10> ==> <empty> | #d
	<radix 16> ==> #x
	<digit 2> ==> 0 | 1
	<digit 8> ==> 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
	<digit 10> ==> <digit>
	<digit 16> ==> <digit 10> | a | b | c | d | e | f

	External representation

	<datum> ==> <simple datum> | <compound datum>
	<simple datum> ==> <boolean> | <number>
		 | <character> | <string> |  <symbol>
	<symbol> ==> <identifier>
	<compound datum> ==> <list> | <vector>
	<list> ==> (<datum>*) | (<datum>+ . <datum>)
		 | <abbreviation>
	<abbreviation> ==> <abbrev prefix> <datum>
	<abbrev prefix> ==> ' | ` | , | ,@
	<vector> ==> #(<datum>*)
*/

#include "yard_text_grammar.hpp"

namespace scheme_grammar
{
	using namespace yard;
	using namespace text_grammar;

	struct SpecialInitialCharSet;
	struct InitialCharSet;
	struct SpecialSubsequentCharSet;
	struct SubsequentCharSet;
	struct SpecialInitial;
	struct Initial;
	struct Subsequent;
	struct PeculiarIdentifier;
	struct Identifier;
	struct NewLine;
	struct Comment;
	struct WS;
	template<typename T> struct Tok;
	template<char C> struct CharTok;
	struct OpenParan;
	struct CloseParan;
	struct Boolean;
	struct CharName; 
	struct Character; 
	struct StringElement;
	struct String;
	struct Number;
	template<int R>	struct Num;
	template<int R> struct Complex;
	template<int R> struct Real;
	template<int R> struct UReal;
	template<int N> struct Decimal;
	template<int R> struct UInteger;
	template<int R>	struct Prefix;
	struct Suffix;
	struct ExponentMarker;
	struct Sign;
	struct Exactness;
	template<int N>	struct Radix;
	template<int R> struct Digit;
	struct CompoundDatum;
	struct List;
	struct Abbreviation;
	struct AbbrevPrefix;
	struct Vector;
	struct Symbol;
	struct SimpleDatum;
	struct Datum;

	/////////////////////////////////////////////////////////////
	
	struct WS
		: Star<Or<Char<' '>, Char<'\t'>, NewLine, Char<'\r'>, Char<'\v'>, Char<'\f'> > >
	{ };

	template<typename T>
	struct Tok
		: Seq<T, WS>
	{ };

	template<char C>
	struct CharTok
		: Tok<Char<C> >
	{ };

	struct OpenParan :
		CharTok<'('>
	{ };

	struct CloseParan :
		CharTok<')'>
	{ };

	struct SpecialInitialCharSet :
		CharSet<'!', '$', '%', '&', '*', '/', ':', '<', '=', '>', '?', '^', '_', '~'> 
	{ };

	struct InitialCharSet : 
		CharSetUnion<LetterCharSet, SpecialInitialCharSet>
	{ };

	struct SpecialSubsequentCharSet :
		CharSet<'.', '+', '-'>
	{ };

	struct SubsequentCharSet :
		CharSetUnion<
			CharSetUnion<InitialCharSet, DigitCharSet>, 
			SpecialSubsequentCharSet>
	{ };

	struct SpecialInitial :
		CharSetParser<SpecialInitialCharSet>
	{ };
		
	struct Initial : 
		CharSetParser<InitialCharSet>
	{ };

	struct Subsequent :
		CharSetParser<SubsequentCharSet>
	{ };

	struct PeculiarIdentifier :
		Or<Char<'+'>, Char<'-'>, CharSeq<'.','.','.'>  >
	{ };

	struct Identifier : 
		Tok<Or<
			Seq<Initial, Star<Subsequent> >, 
			PeculiarIdentifier> >
	{ };

	struct NewLine
		: Or<CharSeq<'\r', '\n'>, CharSeq<'\n'> > 
	{ };

	struct Comment 
		: Seq<Char<';'>, UntilPast<NewLine> > 
	{ };

	template<typename T>
	struct SExp :
		Seq<OpenParan, T, CloseParan>
	{ };

	struct Boolean : 
		Tok<Or<
			CharSeq<'#','t'>, 
			CharSeq<'#','f'> > >
	{ };

	struct CharName : 
		Tok<Or<
			CharSeq<'s','p','a','c','e'>, 
			CharSeq<'n','e','w','l','i','n','e'> > >
	{ };

	struct Character : 
		Or<
			Seq<Char<'#'>, Char<'\\'>, AnyChar>, 
			Seq<Char<'#'>, Char<'\\'>, CharName> > 
	{ };

	struct StringElement : 
		Or<
			Seq<
				NotAt<Char<'\"'> >, 
				NotAt<Char<'\\'> >, 
				AnyChar >, 
			CharSeq<'\\', '\"'>, 
			CharSeq<'\\', '\\'> > 
	{ };

	struct String : 
		Tok<Seq<
			Char<'"'>, 
			Star<StringElement>, 
			Char<'"'> > >
	{ };

	struct Number : 
		Tok<Or<Num<2>, Num<8>, Num<10>, Num<16> > >
	{ };

	// The following rules are parameterized over a radix "R". 
	// This saves space, and avoids us having to 
	// write out all of the rules one by one. 
	// Try doing this with YACC :-)

	template<int R>
	struct Num : Seq<Prefix<R>, Complex<R> >
	{ };

	template<int R>
	struct Complex : 
		Or<
			Real<R>, Seq<Real<R>, Real<R> >,
			Seq<Real<R>, Char<'+'>, UReal<R>, Char<'i'> >,
			Seq<Real<R>, Char<'-'>, UReal<R>, Char<'i'> >,
			Seq<Real<R>, Char<'+'>, Char<'i'> >,
			Seq<Real<R>, Char<'-'>, Char<'i'> >,
			Seq<Char<'+'>, UReal<R>, Char<'i'> >,
			Seq<Char<'-'>, UReal<R>, Char<'i'> > >
	{ };

	template<int R>
	struct Real : Seq<Sign, UReal<R> > { };

	template<int R>
	struct UReal : 
		Or<
			UInteger<R>, 
			Seq<
				UInteger<R>, 
				Char<'/'>, 
				UInteger<R> >, 
			Decimal<R> > 
	{ };

	template<int N>
	struct Decimal {
		template<typename ParserT>
		static bool Match(ParserT& parser) {
			return false;
		}
	};

	template<>
	struct Decimal<10> : 
		Or<
			Seq<UInteger<10>, Suffix>,
			Seq<Char<'.'>, Plus<Digit<10> >, Star<Char<'#'> >, Suffix>,
			Seq<Plus<Digit<10> >, Char<'.'>, Star<Digit<10> >, CharSeq<'#', '*'>, Suffix>,
			Seq<Plus<Digit<10> >, Plus<Char<'#'> >, Char<'.'>, Star<Char<'#'> >, Suffix> >
	{ };

	template<int R>
	struct UInteger : 
		Seq<
			Plus<Digit<R> >, 
			Star<Char<'#'> > >
	{ };

	template<int R>
	struct Prefix : 
		Opt<Or<
			Seq<Radix<R>, Opt<Exactness> >, 
			Seq<Exactness, Opt<Radix<R> > > > >
	{ };

	struct Suffix : 
		Opt<Seq<
			ExponentMarker, 
			Sign, 
			Plus<Digit<10> > > > 
	{ };

	struct ExponentMarker : 
		CharSetParser<CharSet<'e', 's', 'f', 'd', 'l'> > 
	{ };

	struct Sign : 
		Opt<Or<Char<'+'>, Char<'-'> > >
	{ };

	struct Exactness : 
		Or<CharSeq<'#','i'>, CharSeq<'#','e'> > 
	{ };

	template<int N>
	struct Radix
	{
		// Compile-time error will occur.
		// This is correct because this particular Radix is undefined
	};

	template<>
	struct Radix<2> : CharSeq<'#','b'> { };

	template<>
	struct Radix<8> : CharSeq<'#', 'o'> { };

	template<>
	struct Radix<10> : CharSeq<'#', 'd'> { };

	template<>
	struct Radix<16> : CharSeq<'#', 'x'> { };

	template<int R>
	struct Digit
	{
	  // Compile-time error because Radix is undefined
	};

	template<>
	struct Digit<2> : CharSetParser<CharSet<'0', '1'> > { };

	template<>
	struct Digit<8> : CharSetParser<CharSetRange<'0', '7'> > { };

	// This will be an error: two definitions of "digit".
	template<>
	struct Digit<10> : CharSetParser<CharSetRange<'0', '9'> > { };

	template<>
	struct Digit<16> : 
		CharSetParser<
			CharSetUnion<
				CharSetRange<'0', '9'>, 
				CharSetRange<'a', 'f'> > >
	{ };

	struct CompoundDatum :
		Or<List, Vector>
	{ };

	struct List :
		Or<
			SExp<Star<Datum> >,
			SExp<Seq<Plus<Datum>, CharTok<'.'>, Datum> >,
			Abbreviation
		>
	{ };
	
	struct Abbreviation : 
		Seq<AbbrevPrefix, Datum>
	{ };

	struct AbbrevPrefix : 
		Or<Char<'\''>, Char<'`'>, CharSeq<',','@'>, Char<','> >
	{ };
	
	struct Vector :
		Seq<
			Char<'#'>, 
			OpenParan, 
			Star<Datum>, 
			CloseParan>
	{ };

	struct SimpleDatum : 
		Or<Boolean, Number, Character, String, Identifier>
	{ };

	struct Datum :
		Or<SimpleDatum, CompoundDatum>
	{ };

	struct File :
		Seq<WS, Star<Datum>, WS>
	{ };
}

#endif
