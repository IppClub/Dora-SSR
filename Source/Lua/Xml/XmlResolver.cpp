/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Lua/Xml/XmlResolver.h"

#include "Yard/yard.hpp"
#include "Yard/yard_error.hpp"
#include "Yard/yard_text_grammar.hpp"

NS_DORA_BEGIN

namespace dora_xml_grammar {
using namespace yard;
using namespace text_grammar;

struct DoraSimpleTextParser : SimpleTextParser {
	using SimpleTextParser::SimpleTextParser;
	std::stack<std::string> elements;
	bool isInTag = false;
	std::string currentAttr;
	int currentPadding = 0;
	bool isInImport = false;
	std::string importModule;
	std::string importName;
	std::list<std::string> imports;
};

struct Document;
struct S;
struct Name;
struct Names;
struct Nmtoken;
struct Nmtoken;
struct SingleQuotedEntityValueContent;
struct DoubleQuotedEntityValueContent;
struct EntityValue;
struct AttValue;
struct SystemLiteral;
struct PubidCharCharSet;
struct PubidLiteral;
struct CharDataCharSet;
struct CharDataChar;
struct CDStart;
struct CDEnd;
struct CharData;
struct CommentContent;
struct Comment;
struct PI;
struct PITarget;
struct CDSect;
struct CData;
struct Prolog;
struct XMLDecl;
struct VersionInfo;
struct Eq;
struct VersionNumCharSet;
struct VersionNum;
struct Misc;
struct DocTypeDecl;
struct DeclSep;
struct MarkupDecl;
struct ExtSubset;
struct ExtSubsetDecl;
struct YesOrNo;
struct SDDecl;
struct Element;
struct STag;
struct Attribute;
struct ETag;
struct Content;
struct EmptyElemTag;
struct ElementDecl;
struct ContentSpec;
struct Children;
struct Cp;
struct Choice;
struct XmlSeq;
struct Mixed;
struct AttlistDecl;
struct AttDef;
struct AttType;
struct StringType;
struct TokenizedType;
struct EnumeratedType;
struct NotationType;
struct Enumeration;
struct DefaultDecl;
struct ConditionalSect;
struct SectBegin;
struct SectEnd;
template <typename T>
struct Sect;
struct IncludeSect;
struct IgnoreSect;
struct IgnoreSectContents;
struct Ignore;
struct CharRef;
struct Reference;
struct EntityRef;
struct PEReference;
struct EntityDecl;
struct GEDecl;
struct PEDecl;
struct EntityDef;
struct PEDef;
struct ExternalID;
struct NDataDecl;
struct TextDecl;
struct TextParsedEnt;
struct EncodingDecl;
struct EncName;
struct NotationDecl;
struct PublicID;

// clang-format off

struct SChCharSet
	: CharSet<0x9, 0xA, 0xD, 0x20>
{ SChCharSet(){} };
struct SCh : CharSetParser<SChCharSet> { };

struct ChCharSet
	: CharSetUnion<
		SChCharSet,
		CharSetRange<0x20, 0xFF>
	>
{ ChCharSet(){} };
struct Ch : CharSetParser<ChCharSet> { };

struct LetterCharSet
	: CharSetUnion<
		CharSetUnion<
			CharSetUnion<CharSetRange<0x41, 0x5A>, CharSetRange<0x61, 0x7A> >,
			CharSetUnion<CharSetRange<0xC0, 0xD6>, CharSetRange<0xD8, 0xF6> >
		>,
		CharSetRange<0xF8, 0xFF>
	>
{ LetterCharSet(){} };
struct Letter : CharSetParser<LetterCharSet> { };

struct DigitCharSet
	: CharSetRange<0x30, 0x39>
{ DigitCharSet(){} };
struct Digit : CharSetParser<DigitCharSet> { };

struct ExtenderCharSet
	: CharSet<0xB7>
{ ExtenderCharSet(){} };
struct Extender : CharSetParser<ExtenderCharSet> { };

struct NameCharCharSet :
	CharSetUnion<
		CharSetUnion<
			LetterCharSet,
			DigitCharSet
		>,
		CharSetUnion<
			CharSet<'.','-','_',':'>,
			ExtenderCharSet
		>
	>
{ NameCharCharSet(){} };
struct NameChar :
	CharSetParser<NameCharCharSet>
{ };

struct Document :
	Seq<Prolog, Element, Star<Misc> >
{ };

struct S :
	Plus<SCh>
{ };

struct Name:
	Seq<
		Or<
			Letter,
			Char<'_'>,
			Char<':'>
		>,
		Star<NameChar>
	>
{ };

struct Names :
	Seq<Name, Star<Seq<S, Name> > >
{ };

struct Nmtoken :
	Plus<NameChar>
{ };

struct Nmtokens :
	Seq<Nmtoken, Star<Seq<S, Nmtoken> > >
{ };

struct SingleQuotedEntityValueContent :
	Or<
		AnyCharExcept<CharSet<'%','&','\''> >,
		PEReference,
		Reference
	>
{ };

struct DoubleQuotedEntityValueContent :
	Or<
		AnyCharExcept<CharSet<'%','&','\"'> >,
		PEReference,
		Reference
	>
{ };

struct EntityValue :
	Or<
		SingleQuoted<SingleQuotedEntityValueContent>,
		DoubleQuoted<DoubleQuotedEntityValueContent>
	>
{ };

struct AttValEnd {
	template<typename ParserState_T>
	static bool Match(ParserState_T& p) {
		if (Char<'\"'>::Match(p)) {
			return true;
		}
		return false;
	}
};

struct AttValue {
	template<typename ParserState_T>
	static bool Match(ParserState_T& p) {
		const char* p0 = p.GetPos();
		if (Or<
				Seq<
					Char<'\"'>,
					Or<
						Star<AnyCharExcept<CharSet<'<', '&', '\"'> > >,
						Reference
					>,
					AttValEnd
				>,
				SingleQuoted<
					Or<
						Star<AnyCharExcept<CharSet<'<', '&', '\''> > >,
						Reference
					>
				>
			>::Match(p)) {
			auto parser = s_cast<DoraSimpleTextParser*>(&p);
			if (parser->isInImport) {
				if (parser->currentAttr == "Module"sv) {
					parser->importModule = std::string(p0 + 1, p.GetPos() - 1);
				} else if (parser->currentAttr == "Name"sv) {
					parser->importName = std::string(p0+1, p.GetPos()-1);
				}
			}
			parser->currentAttr.clear();
			return true;
		}
		return false;
	}
};

struct SystemLiteral :
	Or<
		DoubleQuoted<Star<AnyCharExcept<CharSet<'"'> > > >,
		SingleQuoted<Star<AnyCharExcept<CharSet<'\''> > > >
	>
{ };

struct PubidCharSet :
	CharSetUnion<
		CharSetUnion<
			CharSet<0x20,0xD,0xA,'\''>,
			AlphaNumCharSet
		>,
		CharSet<'(',')','+',',','.','/',':','=','?',';','!','*','#','@','$','_','%','-'>
	>
{ PubidCharSet(){} };
struct PubidChar : CharSetParser<PubidCharSet> { };

struct PubidLiteral :
	Or<
		DoubleQuoted<Star<PubidChar> >,
		SingleQuoted<Star<Seq<NotAt<Char<'\''> >, PubidChar> > >
	>
{ };

struct CDStart :
	CharSeq<'<','!','[','C','D','A','T','A','['>
{ };

struct CDEnd :
	CharSeq<']',']','>'>
{ };

struct CharData :
	Star<Seq<NotAt<CDEnd>, NotAt<Char<'<'> >, NotAt<Char<'&'> >, Ch> >
{ };

struct CommentContent :
	Star<
		Or<
			Seq<NotAt<Char<'-'> >, Ch>,
			Seq<Char<'-'>, Seq<NotAt<Char<'-'> >, Ch > >
		>
	>
{ };

struct Comment :
	Seq<
		CharSeq<'<','!','-','-'>,
		CommentContent,
		CharSeq<'-','-','>'>
	>
{ };

struct PI :
	Seq<
		CharSeq<'<','?'>,
		PITarget,
		Opt<
			Seq<S, StarExcept<Ch, CharSeq<'?','>'> >  >
		>,
		CharSeq<'?','>'>
	>
{ };

struct PITarget :
	Seq<NotAt<CharSeqIgnoreCase<'x','m','l'> >, Name>
{ };

struct CDSect :
	Seq<
		CDStart,
		CData,
		CDEnd
	>
{ };

struct CData :
	StarExcept<AnyChar, CDEnd>
{ };

struct CDYueEnd :
	Seq<CharSeq<'<','/','Y','u','e'>, Opt<S>, Char<'>'>>
{ };
struct CDYue :
	Seq<
		CharSeq<'<','Y','u','e'>, Opt<S>,
		Char<'>'>,
		StarExcept<
			AnyChar,
			CDYueEnd
		>,
		CDYueEnd
	>
{ };

struct CDLuaEnd :
	Seq<CharSeq<'<','/','L','u','a'>, Opt<S>, Char<'>'>>
{ };
struct CDLua :
	Seq<
		CharSeq<'<','L','u','a'>, Opt<S>,
		Char<'>'>,
		StarExcept<
			AnyChar,
			CDLuaEnd
		>,
		CDLuaEnd
	>
{ };

struct Prolog :
	Seq<
		Opt<XMLDecl>,
		Star<Misc>,
		Opt< Seq<DocTypeDecl,Star<Misc> > >
	>
{ };

struct XMLDecl :
	Seq<
		CharSeq<'<','?','x','m','l'>,
		VersionInfo,
		Opt<EncodingDecl>,
		Opt<SDDecl>,
		Opt<S>,
		CharSeq<'?','>'>
	>
{ };

struct VersionInfo :
	Seq<
		S, CharSeq<'v','e','r','s','i','o','n'>,
		Eq,
		Or<
			SingleQuoted<VersionNum>,
			DoubleQuoted<VersionNum>
		>
	>
{ };

struct Eq :
	Seq<Opt<S>, Char<'='>, Opt<S> >
{ };

struct VersionNumCharSet :
	CharSetUnion<
		CharSetUnion<
			CharSetRange<'a','z'>,
			CharSetRange<'A','Z'>
		>,
		CharSetUnion<
			CharSetRange<'0','9'>,
			CharSet<'_','.',':','-'>
		>
	>
{ VersionNumCharSet(){} };
struct VersionNumCh : CharSetParser<VersionNumCharSet> { };

struct VersionNum :
	Plus<VersionNumCh>
{ };

struct Misc :
	Or<Comment, PI, S>
{ };

struct DocTypeDecl :
	Seq<
		CharSeq<'<','!','D','O','C','T','Y','P','E'>,
		S,
		Name,
		Opt<S>,
		Opt<
			Seq<
				ExternalID,
				Opt<S>
			>
		>,
		Opt<
			Seq<
				Char<'['>,
				Star<
					Or<MarkupDecl, DeclSep>
				>,
				Char<']'>,
				Opt<S>
			>
		>,
		Char<'>'>
	>
{ };

struct DeclSep :
	Or<PEReference, S>
{ };

struct MarkupDecl :
	Or<
		ElementDecl,
		AttlistDecl,
		EntityDecl,
		NotationDecl,
		PI,
		Comment
	>
{ };

struct ExtSubset :
	Seq<Opt<TextDecl>, ExtSubsetDecl>
{ };

struct ExtSubsetDecl :
	Star<
		Or<
			MarkupDecl,
			ConditionalSect,
			DeclSep
		>
	>
{ };

struct YesOrNo :
	Or<
		CharSeq<'y','e','s'>,
		CharSeq<'n','o'>
	>
{ };

struct SDDecl :
	Seq<
		S,
		CharSeq<'s','t','a','n','d','a','l','o','n','e'>,
		Eq,
		SingleOrDoubleQuoted<YesOrNo>
	>
{ };

struct ElementStart {
	template<typename ParserState_T>
	static bool Match(ParserState_T& p) {
		const char* p0 = p.GetPos();
		if (Seq<Char<'<'>,Name>::Match(p)) {
			std::string elementName(p0 + 1, p.GetPos());
			auto parser = s_cast<DoraSimpleTextParser*>(&p);
			parser->isInImport = (elementName == "Import"sv);
			parser->elements.push(elementName);
			parser->currentPadding++;
			parser->isInTag = true;
			return true;
		}
		return false;
	}
};

struct Element {
	template<typename ParserState_T>
	static bool Match(ParserState_T& p) {
		if (Seq<
				ElementStart,
				Or<
					EmptyElemTag,
					Seq<STag, Content, ETag>
				>
			>::Match(p)) {
			auto parser = s_cast<DoraSimpleTextParser*>(&p);
			parser->elements.pop();
			parser->currentPadding--;
			return true;
		}
		return false;
	}
};

struct STag {
	template<typename ParserState_T>
	static bool Match(ParserState_T& p) {
		if (Seq<
			Star<Seq<S, Attribute> >,
			Opt<S>,
			Char<'>'>
		>::Match(p)) {
			auto parser = s_cast<DoraSimpleTextParser*>(&p);
			if (parser->isInImport) {
				if (!parser->importName.empty()) {
					parser->imports.push_back(parser->importName);
				} else if (!parser->importModule.empty()) {
					size_t pos = parser->importModule.rfind('.');
					if (pos != std::string::npos) {
						parser->imports.push_back(parser->importModule.substr(pos + 1));
					} else {
						parser->imports.push_back(parser->importModule);
					}
				}
				parser->importName.clear();
				parser->importModule.clear();
			}
			parser->isInTag = false;
			return true;
		}
		return false;
	}
};

struct AttributeStart {
	template<typename ParserState_T>
	static bool Match(ParserState_T& p) {
		const char* p0 = p.GetPos();
		if (Seq<Name,Eq>::Match(p)) {
			auto parser = s_cast<DoraSimpleTextParser*>(&p);
			parser->currentAttr = std::string(p0, p.GetPos() - 1);
			return true;
		}
		return false;
	}
};

struct Attribute :
	Seq<AttributeStart, AttValue>
{ };

struct ETag :
	Seq<CharSeq<'<','/'>, Name, Opt<S>, Char<'>'> >
{ };

struct Content :
	Seq<
		Opt<CharData>,
		Star<
			Seq<
				Or<
					CDLua,
					CDYue,
					Element,
					Reference,
					Or<
					CDSect,
					PI,
					Comment>
				>,
				Opt<CharData>
			>
		>
	>
{ };

struct EmptyElemTag {
	template<typename ParserState_T>
	static bool Match(ParserState_T& p) {
		if (Seq<
			Star<Seq<S, Attribute> >,
			Opt<S>,
			CharSeq<'/','>'>
		>::Match(p)) {
			auto parser = s_cast<DoraSimpleTextParser*>(&p);
			if (parser->isInImport) {
				if (!parser->importName.empty()) {
					parser->imports.push_back(parser->importName);
				} else if (!parser->importModule.empty()) {
					size_t pos = parser->importModule.rfind('.');
					if (pos != std::string::npos) {
						parser->imports.push_back(parser->importModule.substr(pos+1));
					} else {
						parser->imports.push_back(parser->importModule);
					}
				}
				parser->importName.clear();
				parser->importModule.clear();
			}
			parser->isInTag = false;
			return true;
		}
		return false;
	}
};

struct ElementDecl :
	Seq<
		CharSeq<'<','!','E','L','E','M','E','N','T'>,
		S, Name, S,
		ContentSpec, Opt<S>,
		Char<'>'>
	>
{ };

struct ContentSpec :
	Or<
		CharSeq<'E','M','P','T','Y'>,
		CharSeq<'A','N','Y'>,
		Mixed,
		Children
	>
{ };

struct Children :
	Seq<
		Or<Choice, XmlSeq>,
		Opt<
			Or<
				Char<'?'>,
				Char<'*'>,
				Char<'+'>
			>
		>
	>
{ };

struct Cp :
	Seq<
		Or<Name, Choice, XmlSeq>,
		Opt<Or<Char<'?'>, Char<'*'>, Char<'+'> > >
	>
{ };

struct Choice :
	Seq<
		Char<'('>,
		Opt<S>,
		Cp,
		Plus< Seq<Opt<S>, Char<'|'>, Opt<S>, Cp> >,
		Opt<S>,
		Char<')'>
	>
{ };

struct XmlSeq :
	Seq<
		Char<'('>,
		Opt<S>,
		Cp,
		Star< Seq<Opt<S>, Char<','>, Opt<S>, Cp> >,
		Opt<S>,
		Char<')'>
	>
{ };

struct Mixed :
	Or<
		Seq<
			Char<'('>,
			Opt<S>,
			CharSeq<'#','P','C','D','A','T','A'>,
			Star< Seq<Opt<S>, Char<'|'>, Opt<S>, Name> >,
			Opt<S>,
			CharSeq<')', '*'>
		>,
		Seq<
			Char<'('>,
			Opt<S>,
			CharSeq<'#','P','C','D','A','T','A'>,
			Opt<S>,
			Char<')'>
		>
	>
{ };


struct AttlistDecl :
	Seq<
		CharSeq<'<','!','A','T','T','L','I','S','T'>,
		S, Name, Star<AttDef>, Opt<S>, Char<'>'>
	>
{ };

struct AttDef :
	Seq<
		S, Name, S, AttType, S, DefaultDecl
	>
{ };

struct AttType :
	Or<StringType, TokenizedType, EnumeratedType>
{ };

struct StringType :
	CharSeq<'C','D','A','T','A'>
{ };

struct TokenizedType :
	Or<
		CharSeq<'N','M','T','O','K','E','N','S'>,
		CharSeq<'N','M','T','O','K','E','N'>,
		CharSeq<'E','N','T','I','T','I','E','S'>,
		CharSeq<'E','N','T','I','T','Y'>,
		CharSeq<'I','D','R','E','F','S'>,
		CharSeq<'I','D','R','E','F'>
	>
{ };

struct EnumeratedType : Or<NotationType, Enumeration>
{ };

struct NotationType :
	Seq<
		CharSeq<'N','O','T','A','T','I','O','N'>,
		S, Char<'('>, Opt<S>, Name,
		Star<Seq<Opt<S>, Char<'|'>, Opt<S>, Name> >,
		Opt<S>, Char<')'>
	>
{ };

struct Enumeration :
	Seq<
		Char<'('>, Opt<S>, Nmtoken,
		Star<Seq<Opt<S>, Char<'|'>, Opt<S>, Nmtoken> >,
		Opt<S>, Char<')'>
	>
{ };

struct DefaultDecl :
	Or<
		CharSeq<'#','R','E','Q','U','I','R','E','D'>,
		CharSeq<'#','I','M','P','L','I','E','D'>,
		Seq<Opt<Seq<CharSeq<'#','F','I','X','E','D'>, S> >, AttValue>
	>
{ };

struct ConditionalSect : Or<IncludeSect, IgnoreSect>
{ };

struct SectBegin :
	CharSeq<'<','!','['>
{ };

struct SectEnd :
	CDEnd
{ };

template<typename T>
struct Sect :
	Seq<SectBegin, Opt<S>, T, SectEnd>
{ };

struct IncludeSect:
	Sect<
		Seq<
			CharSeq<'I','N','C','L','U','D','E'>,
			Opt<S>,
			Char<'['>,
			ExtSubsetDecl
		>
	>
{ };

struct IgnoreSect :
	Sect<
		Seq<
			CharSeq<'I','G','N','O','R','E'>,
			Opt<S>,
			Char<'['>,
			Star<IgnoreSectContents>
		>
	>
{ };

struct IgnoreSectContents :
	Seq<
		Ignore,
		Star<
			Seq<
				SectBegin,
				IgnoreSectContents,
				CDEnd,
				Ignore
			>
		>
	>
{ };

struct Ignore :
	StarExcept<Ch, Or<SectBegin, SectEnd> >
{ };

struct CharRef :
	Or<
		Seq<CharSeq<'&','#'>, Plus<Digit>, Char<';'> >,
		Seq<CharSeq<'&','#','x'>, Plus<Digit>, Char<';'> >
	>
{ };

struct Reference :
	Or<EntityRef, CharRef>
{ };

struct EntityRef :
	Seq<Char<'&'>, Name, Char<';'> >
{ };

struct PEReference :
	Seq<Char<'%'>, Name, Char<';'> >
{ };

struct EntityDecl :
	Or<GEDecl, PEDecl>
{ };

struct GEDecl :
	Seq<
		CharSeq<'<','!','E','N','T','I','T','Y'>,
		S, Name, S, EntityDef, Opt<S>, Char<'>'>
	>
{ };

struct PEDecl :
	Seq<
		CharSeq<'<','!','E','N','T','I','T','Y'>,
		S, Char<'%'>, S, Name, S, PEDef, Opt<S>, Char<'>'>
	>
{ };

struct EntityDef :
	Or<
		EntityValue,
		Seq<ExternalID, Opt<NDataDecl> >
	>
{ };

struct PEDef :
	Or<
		EntityValue,
		ExternalID
	>
{ };

struct ExternalID :
	Or<
		Seq<CharSeq<'S','Y','S','T','E','M'>, S, SystemLiteral>,
		Seq<CharSeq<'P','U','B','L','I','C'>, S, PubidLiteral, S, SystemLiteral>
	>
{ };

struct NDataDecl :
	Seq<S, CharSeq<'N','D','A','T','A'>, S, Name>
{ };

struct TextDecl :
	Seq<
		CharSeq<'<','?','x','m','l'>,
		Opt<VersionInfo>,
		EncodingDecl,
		Opt<S>,
		CharSeq<'?','>'>
	>
{ };

struct TextParsedEnt :
	Seq<
		Opt<TextDecl>, Content
	>
{ };

struct EncodingDecl :
	Seq<
		S,
		CharSeq<'e','n','c','o','d','i','n','g'>,
		Eq,
		SingleOrDoubleQuoted<EncName>
	>
{ };

struct EncName :
	Seq<AlphaNum, Star<Or<AlphaNum, Char<'.'>, Char<'_'>, Char<'-'> > > >
{ };

struct NotationDecl :
	Seq<
		CharSeq<'<','!','N','O','T','A','T','I','O','N'>,
		S, Name, S,
		Or<ExternalID, PublicID>,
		Opt<S>, Char<'>'>
	>
{ };

struct PublicID :
	Seq<
		CharSeq<'P','U','B','L','I','C'>,
		S, PubidLiteral
	>
{ };

// clang-format on
} // namespace dora_xml_grammar

XmlResolver::XmlResolver()
	: _isInTag(false)
	, _currentPadding(0) { }

XmlResolver::~XmlResolver() { }

void XmlResolver::resolve(String text) {
	XmlResolver::parse(text.rawData(), int(text.size()));
}

bool XmlResolver::parse(const char* codes, int length) {
	dora_xml_grammar::DoraSimpleTextParser parser(codes, codes + length);
	bool result = parser.Parse<yard::Seq<dora_xml_grammar::Document, yard::EndOfInput>>();
	_isInTag = parser.isInTag;
	_currentPadding = parser.currentPadding;
	_currentElement = parser.elements.empty() ? std::string() : parser.elements.top();
	_currentAttribute = parser.currentAttr;
	_imports.clear();
	_imports = std::move(parser.imports);
	return result;
}

const std::string& XmlResolver::getCurrentElement() {
	return _currentElement;
}

const std::string& XmlResolver::getCurrentAttribute() {
	return _currentAttribute;
}

bool XmlResolver::isCurrentInTag() {
	return _isInTag;
}

int XmlResolver::getCurrentPadding() {
	return _currentPadding - 1;
}

const std::list<std::string>& XmlResolver::getImports() {
	return _imports;
}

NS_DORA_END
