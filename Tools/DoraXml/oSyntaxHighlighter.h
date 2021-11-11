#ifndef OSYNTAXHIGHLIGHTER_H
#define OSYNTAXHIGHLIGHTER_H

#include "oDefine.h"

class QTextDocument;

class oSyntaxHighlighter : public QSyntaxHighlighter
{
	Q_OBJECT

public:
	oSyntaxHighlighter(const QFont& defaultFont, QTextDocument* parent = nullptr);
	virtual ~oSyntaxHighlighter();

	//Enumeration for the character formats. This is used in functions which get and
	//set them.
	enum xmlCharFormat
	{
		xmlDefault,
		xmlCData,
		xmlProcInst,
		xmlDoctype,
		xmlComment,
		xmlTag,
		xmlEntity,
		xmlAttribute,
		xmlAttVal
	};
	void setFont(const QFont& font);
protected:
	virtual void highlightBlock(const QString &text) Q_DECL_OVERRIDE;

	void highlightSubBlock(const QString &text, const int startIndex, const int currState);
	void highlightLua(const QString &text, const int startIndex, const int length);

	bool isCDataTagName(const QString& tagText);
	int indexOfCDataTagName(const QString& text, int startIndex);
private:
	struct HighlightingRule
	{
		QRegExp pattern;
		QTextCharFormat format;
	};
	QVector<HighlightingRule> luaRules;
    QVector<QRegExp> cdataPatterns;
    QVector<QString> cdataEndPatterns;

	QRegExp xmlQuoteExpression1;
	QRegExp xmlQuoteExpression2;
	QRegExp xmlProcInstStartExpression;
	QRegExp xmlProcInstEndExpression;

	QRegExp xmlCDataStartExpression;
	QRegExp xmlCDataEndExpression;

	QRegExp xmlCommentStartExpression;
	QRegExp xmlCommentEndExpression;
	QRegExp xmlDoctypeStartExpression;
	QRegExp xmlDoctypeEndExpression;

    QRegExp xmlOpenTagStartExpression;
    QRegExp xmlOpenTagEndExpression;
	QRegExp xmlCloseTagStartExpression;
	QRegExp xmlCloseTagEndExpression;
	QRegExp xmlAttributeStartExpression;
	QRegExp* xmlAttributeEndExpression;
	QRegExp xmlAttValStartExpression;
	QRegExp xmlAttValEndExpression;

	QRegExp xmlAttValExpression;

	QTextCharFormat xmlDefaultFormat;
	QTextCharFormat xmlProcInstFormat;
	QTextCharFormat xmlCDataFormat;
	QTextCharFormat xmlCDataContentFormat;
	QTextCharFormat xmlDoctypeFormat;
	QTextCharFormat xmlCommentFormat;
	QTextCharFormat xmlTagFormat;
	QTextCharFormat xmlEntityFormat;
	QTextCharFormat xmlAttributeFormat;
	QTextCharFormat xmlAttValFormat;

	enum xmlState
	{
		inNothing, //Don't know if we'll need this or not.
		inCData, //<![CDATA[ and ending with ]]>
		inProcInst, //<? and ending with ?>
		inDoctypeDecl, //starting with <!DOCTYPE and ending with >
		inOpenTag, //starting with < + xmlName and ending with /?>
		inCDataTag, //cdata tag is element whose content is cdata only.
		inOpenTagName, //after < and before whitespace. Implies inOpenTag.
		//inAttribute, //if inOpenTag, starting with /s*xmlName/s*=/s*" and ending with ".
		//inAttName, //after < + xmlName + whitespace, and before =". Implies inOpenTag.
		inAttVal, //after =" and before ". May also use single quotes. Implies inOpenTag.
		inCAttVal,
		inCloseTag, //starting with </ and ending with >.
		inCloseTagName, //after </ and before >. Implies inCloseTag.
		inComment, //starting with <!-- and ending with -->. Overrides all others.
		inLuaComment,
		inLuaString
	};

	QRegExp luaCommentExpression;
	QRegExp luaMultiCommentStartExpression;
	QRegExp luaMultiCommentEndExpression;
	QRegExp luaStringExpression;
	QRegExp luaMultiStringStartExpression;
	QRegExp luaMultiStringEndExpression;
	QRegExp luaKeywordExpression;
	QRegExp luaNumberExpression;
	QRegExp luaBuiltinExpression;
	QRegExp luaBuiltinExpression1;
	QRegExp luaFunctionExpression;
	QRegExp luaOperatorExpression;
	QRegExp luaPunctuationExpression;

	QTextCharFormat luaCommentFormat;
	QTextCharFormat luaStringFormat;
	QTextCharFormat luaKeywordFormat;
	QTextCharFormat luaNumberFormat;
	QTextCharFormat luaBuiltinFormat;
	QTextCharFormat luaBuiltinFormat1;
	QTextCharFormat luaFunctionFormat;
	QTextCharFormat luaOperatorFormat;
	QTextCharFormat luaPunctuationFormat;
};

#endif // OSYNTAXHIGHLIGHTER_H
