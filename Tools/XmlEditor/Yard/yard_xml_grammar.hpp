// This is a Grammar for Parsing ISO-8859-1 encoded XML 
// using the YARD library
// 
// Dedicated to the public domain by Christopher Diggins, October 2007
// http://www.cdiggins.com 

#include "yard_text_grammar.hpp"

namespace xml_grammar 
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

	struct Name : 
		Seq<
			Or<Letter, Char<'_'>, 
			Char<':'> >, 
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
		
	struct AttValue :
		Or<
			DoubleQuoted<
				Or<
					Star<AnyCharExcept<CharSet<'<', '&', '\"'> > >,
					Reference
				>
			>,
			SingleQuoted<
				Or<
					Star<AnyCharExcept<CharSet<'<', '&', '\''> > >,
					Reference
				>
			>
		>
	{ };

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

	struct Element :
		Or<EmptyElemTag, Seq<STag, Content, ETag> >
	{ };

	struct STag :
		Seq<
			Char<'<'>,
			Name, 
			Star<Seq<S, Attribute> >, 
			Opt<S>, 
			Char<'>'>
		>
	{ };

	struct Attribute :
		Seq<Name, Eq, AttValue>
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
						CDSect,
						PI,
						Comment
					>,
					Opt<CharData>
				>
			>			
		>
	{ };

	struct EmptyElemTag :
		Seq<
			Char<'<'>,
			Name, 
			Star<Seq<S, Attribute> >, 
			Opt<S>, 
			CharSeq<'/','>'>
		>
	{ };

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
		  
