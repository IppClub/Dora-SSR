#include "oXmlResolver.h"

#include "Yard/yard.hpp"
#include "Yard/yard_error.hpp"
#include "Yard/yard_text_grammar.hpp"
#include <stack>
using std::stack;
#include <vector>
using std::vector;

static stack<string> elements;
static bool isInTag = false;
static string currentAttr;
static int currentPadding = 0;
static bool isInImport = false;
static string importModule;
static string importName;
static vector<string> imports;

namespace dorothy_xml_grammar
{
	using namespace yard;
	using namespace text_grammar;

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
	template<typename T>
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

	struct AttValEnd
	{
		template<typename ParserState_T>
		static bool Match(ParserState_T& p)
		{
			if (Char<'\"'>::Match(p))
            {
				return true;
			}
			return false;
		}
	};

    struct AttValue
    {
        template<typename ParserState_T>
        static bool Match(ParserState_T& p)
        {
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
                >::Match(p))
            {
                if (isInImport)
				{
                    if (currentAttr == "Module")
                    {
						importModule = string(p0+1, p.GetPos()-1);
                    }
                    else if (currentAttr == "Name")
                    {
						importName = string(p0+1, p.GetPos()-1);
                    }
                }
                currentAttr.clear();
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

	struct ElementStart
	{
		template<typename ParserState_T>
		static bool Match(ParserState_T& p)
		{
			const char* p0 = p.GetPos();
			if (Seq<Char<'<'>,Name>::Match(p))
            {
                string elementName(p0+1, p.GetPos());
                isInImport = (elementName == "Import");
                elements.push(elementName);
				currentPadding++;
				isInTag = true;
				return true;
			}
			return false;
		}
	};

	struct Element
	{
		template<typename ParserState_T>
		static bool Match(ParserState_T& p)
		{
            if (Seq<
                    ElementStart,
                    Or<
                        EmptyElemTag,
                        Seq<STag, Content, ETag>
                    >
                >::Match(p))
			{
				elements.pop();
				currentPadding--;
				return true;
			}
			return false;
		}
	};

	struct STag
	{
		template<typename ParserState_T>
		static bool Match(ParserState_T& p)
		{
			if (Seq<
				Star<Seq<S, Attribute> >,
				Opt<S>,
				Char<'>'>
			>::Match(p))
            {
                if (isInImport)
                {
                    if (!importName.empty())
					{
                        imports.push_back(importName);
                    }
                    else if (!importModule.empty())
                    {
						size_t pos = importModule.rfind('.');
						if (pos != string::npos)
						{
							imports.push_back(importModule.substr(pos+1));
						}
						else
						{
							imports.push_back(importModule);
						}
                    }
                    importName.clear();
                    importModule.clear();
                }
                isInTag = false;
				return true;
			}
			return false;
		}
	};

	struct AttributeStart
	{
		template<typename ParserState_T>
		static bool Match(ParserState_T& p)
		{
			const char* p0 = p.GetPos();
			if (Seq<Name,Eq>::Match(p))
			{
                currentAttr = string(p0, p.GetPos()-1);
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
						Element,
						Reference,
                        CDLua,
                        CDYue,
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

	struct EmptyElemTag
	{
		template<typename ParserState_T>
		static bool Match(ParserState_T& p)
		{
			if (Seq<
				Star<Seq<S, Attribute> >,
				Opt<S>,
				CharSeq<'/','>'>
			>::Match(p))
            {
                if (isInImport)
                {
                    if (!importName.empty())
					{
						imports.push_back(importName);
                    }
                    else if (!importModule.empty())
                    {
						size_t pos = importModule.rfind('.');
						if (pos != string::npos)
						{
							imports.push_back(importModule.substr(pos+1));
						}
						else
						{
							imports.push_back(importModule);
						}
                    }
                    importName.clear();
                    importModule.clear();
                }
				isInTag = false;
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
}

oXmlResolver::oXmlResolver():
_isInTag(false),
_currentPadding(0)
{ }

oXmlResolver::~oXmlResolver()
{ }

void oXmlResolver::resolve(const QString& text)
{
	string str = text.toStdString();
    oXmlResolver::parse(str.c_str(), int(str.length()));
}

bool oXmlResolver::parse(const char* codes, int length)
{
	yard::SimpleTextParser parser(codes, codes+length);
	bool result = parser.Parse<yard::Seq<dorothy_xml_grammar::Document, yard::EndOfInput>>();
	_isInTag = isInTag;
	_currentPadding = ::currentPadding;
	_currentElement = elements.empty() ? QString() : QString::fromStdString(elements.top());
	_currentAttribute = QString::fromStdString(currentAttr);
    _imports.clear();
    for (size_t i = 0;i < imports.size();i++)
    {
        _imports << QString::fromStdString(imports[i]);
	}
    isInImport = false;
    importModule.clear();
    importName.clear();
    imports.clear();
	isInTag = false;
	currentAttr.clear();
	::currentPadding = 0;
	for (;!elements.empty();elements.pop());
	return result;
}

const QString& oXmlResolver::currentElement()
{
	return _currentElement;
}

const QString& oXmlResolver::currentAttribute()
{
	return _currentAttribute;
}

bool oXmlResolver::isCurrentInTag()
{
	return _isInTag;
}

int oXmlResolver::currentPadding()
{
    return _currentPadding-1;
}

const QStringList& oXmlResolver::getImports()
{
    return _imports;
}
