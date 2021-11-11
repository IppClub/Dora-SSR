#include "oSyntaxHighlighter.h"

oSyntaxHighlighter::oSyntaxHighlighter(const QFont& defaultFont, QTextDocument* parent):
QSyntaxHighlighter(parent),
xmlAttributeEndExpression(nullptr)
{
	HighlightingRule rule;

	//Taken from W3C: <http://www.w3.org/TR/REC-xml/#sec-suggested-names>
	//These are removed: \\x10000-\\xEFFFF (we can't fit them into the \xhhhh format).
	const QString nameStartCharList = ":A-Z_a-z\\x00C0-\\x00D6\\x00D8-\\x00F6\\x00F8-\\x02FF\\x0370-\\x037D\\x037F-\\x1FFF\\x200C-\\x200D\\x2070-\\x218F\\x2C00-\\x2FEF\\x3001-\\xD7FF\\xF900-\\xFDCF\\xFDF0-\\xFFFD";

	const QString nameCharList = nameStartCharList + "\\-\\.0-9\\x00B7\\x0300-\\x036F\\x203F-\\x2040";
	const QString nameStart = "[" + nameStartCharList + "]";
	const QString nameChar = "[" + nameCharList + "]";
    const QString xmlName = nameStart + "(" + nameChar + ")*";

	xmlDefaultFormat.setFont(defaultFont);

	xmlCDataStartExpression.setPattern("<!\\[CDATA\\[");
	xmlCDataEndExpression.setPattern("\\]\\]>");
	xmlCDataFormat.setFont(defaultFont);
	xmlCDataFormat.setForeground(QColor(0x708090));

	xmlCDataContentFormat.setFont(defaultFont);
	xmlCDataContentFormat.setForeground(QColor(0x708090));

	xmlProcInstStartExpression.setPattern("<\\?");
	xmlProcInstEndExpression.setPattern("\\?>");
	xmlProcInstFormat.setFont(defaultFont);
	xmlProcInstFormat.setForeground(QColor(0x708090));

	xmlCommentStartExpression.setPattern("<!\\-\\-");
	xmlCommentEndExpression.setPattern("\\-\\->");
	xmlCommentFormat.setFont(defaultFont);
	xmlCommentFormat.setForeground(QColor(0x708090));

    xmlOpenTagStartExpression.setPattern("<" + xmlName);
    xmlOpenTagEndExpression.setPattern("/?>");

	xmlCloseTagStartExpression.setPattern("</" + xmlName);
	xmlCloseTagEndExpression.setPattern(">");

	xmlTagFormat.setFont(defaultFont);
	xmlTagFormat.setToolTip("tag");
	xmlTagFormat.setForeground(QColor(0xDD4A68));

	xmlAttributeStartExpression.setPattern("\\s*" + xmlName + "\\s*=\\s*((\\x0022)|(\\x0027))");

	xmlAttributeFormat.setFont(defaultFont);
	xmlAttributeFormat.setToolTip("attr");
	xmlAttributeFormat.setForeground(QColor(0x990055));

	xmlAttValStartExpression.setPattern("((\\x0022[^\\x0022]*)|(\\x0027[^\\x0027]*))");

	xmlAttValFormat.setFont(defaultFont);
	xmlAttValFormat.setToolTip("attrVal");
	xmlAttValFormat.setForeground(QColor(0x669900));

	xmlDoctypeStartExpression.setPattern("<!DOCTYPE");
	xmlDoctypeEndExpression.setPattern(">");
	xmlDoctypeFormat.setFont(defaultFont);
	xmlDoctypeFormat.setForeground(QColor(0x708090));

	xmlEntityFormat.setFont(defaultFont);
	xmlEntityFormat.setForeground(QColor(0xa67f59));

	xmlQuoteExpression1.setPattern("\\x0027");
	xmlQuoteExpression2.setPattern("\\x0022");

	QStringList cdataList;
    cdataList << "Lua" << "Yue";
	foreach (const QString& item, cdataList)
	{
        cdataPatterns.append(QRegExp("\\b" + item + "\\b"));
        cdataEndPatterns.append("</" + item);
	}

	luaCommentExpression.setPattern("--+.*(\\r?\\n|$)");
	luaMultiCommentStartExpression.setPattern("--\\[\\[");
	luaMultiCommentEndExpression.setPattern("\\]\\]");
	luaMultiStringStartExpression.setPattern("\\[\\[");
	luaMultiStringEndExpression.setPattern("\\]\\]");
	luaStringExpression.setPattern("(\"\")|(\".*[^\\\\]\")");
	luaStringExpression.setMinimal(true);
    luaKeywordExpression.setPattern("\\b(and|break|do|else|elseif|end|false|for|function|if|in|local|nil|not|or|repeat|return|then|true|until|while|with)\\b");
	luaNumberExpression.setPattern("\\b(([-+]?\\d+\\.?\\d*f?)|(0x[\\da-f]+)|([-+]?\\d*\\.?\\d*e-?\\d*))\\b");
	luaBuiltinExpression.setPattern("\\b(assert|collectgarbage|dofile|error|_G|getfenv|getmetatable|ipairs|load|loadfile|loadstring|next|pairs|pcall|print|rawequal|rawget|rawset|select|setfenv|setmetatable|tonumber|tostring|type|unpack|_VERSION|xpcall)\\b");
	luaBuiltinExpression1.setPattern("\\b(coroutine|string|package|table|math|debug|os|io)\\.\\w+\\b");
    luaFunctionExpression.setPattern("([a-zA-Z0-9_]+\\()|(\\\\[a-zA-Z0-9_]+)");
	luaOperatorExpression.setPattern("[-+\\*/<>,;=]|>=|<=|~=");
    luaPunctuationExpression.setPattern("[\\(\\)\\{\\}\\[\\]\\.:\\\\]");

	luaOperatorFormat.setFont(defaultFont);
	luaOperatorFormat.setForeground(QColor(0xa67f59));
	rule.pattern = luaOperatorExpression;
	rule.format = luaOperatorFormat;
	luaRules.append(rule);

	luaFunctionFormat.setFont(defaultFont);
	luaFunctionFormat.setForeground(QColor(0xDD4A68));
	rule.pattern = luaFunctionExpression;
	rule.format = luaFunctionFormat;
	luaRules.append(rule);

	luaPunctuationFormat.setFont(defaultFont);
	luaPunctuationFormat.setForeground(QColor(0x999999));
	rule.pattern = luaPunctuationExpression;
	rule.format = luaPunctuationFormat;
	luaRules.append(rule);

	luaBuiltinFormat.setFont(defaultFont);
	luaBuiltinFormat.setForeground(QColor(0x1990b8));
	rule.pattern = luaBuiltinExpression;
	rule.format = luaBuiltinFormat;
	luaRules.append(rule);

	luaBuiltinFormat1.setFont(defaultFont);
	luaBuiltinFormat1.setForeground(QColor(0x1990b8));
	rule.pattern = luaBuiltinExpression1;
	rule.format = luaBuiltinFormat1;
	luaRules.append(rule);

	luaNumberFormat.setFont(defaultFont);
	luaNumberFormat.setForeground(QColor(0x990055));
	rule.pattern = luaNumberExpression;
	rule.format = luaNumberFormat;
	luaRules.append(rule);

	luaKeywordFormat.setFont(defaultFont);
	luaKeywordFormat.setForeground(QColor(0x0077aa));
	rule.pattern = luaKeywordExpression;
	rule.format = luaKeywordFormat;
	luaRules.append(rule);

	luaStringFormat.setFont(defaultFont);
	luaStringFormat.setForeground(QColor(0x669900));
	rule.pattern = luaStringExpression;
	rule.format = luaStringFormat;
	luaRules.append(rule);

	luaCommentFormat.setFont(defaultFont);
	luaCommentFormat.setForeground(QColor(0x708090));
	rule.pattern = luaCommentExpression;
	rule.format = luaCommentFormat;
	luaRules.append(rule);
}

oSyntaxHighlighter::~oSyntaxHighlighter()
{ }

void oSyntaxHighlighter::setFont(const QFont& font)
{
	xmlDefaultFormat.setFont(font);
	xmlCDataFormat.setFont(font);
	xmlCDataContentFormat.setFont(font);
	xmlProcInstFormat.setFont(font);
	xmlCommentFormat.setFont(font);
	xmlTagFormat.setFont(font);
	xmlAttributeFormat.setFont(font);
	xmlAttValFormat.setFont(font);
	xmlDoctypeFormat.setFont(font);
	xmlEntityFormat.setFont(font);
	for (int i = 0;i < luaRules.length();i++)
	{
		luaRules[i].format.setFont(font);
	}
	this->rehighlight();
}

void oSyntaxHighlighter::highlightLua(const QString& text, const int startIndex, const int length)
{
	foreach (const HighlightingRule& rule, luaRules)
	{
		int index = rule.pattern.indexIn(text, startIndex);
		while (index >= 0 && index < startIndex+length)
		{
			int length = rule.pattern.matchedLength();
			setFormat(index, length, rule.format);
			index = rule.pattern.indexIn(text, index + length);
		}
	}
}

void oSyntaxHighlighter::highlightSubBlock(const QString& text, const int startIndex, const int currState)
{
	if (startIndex >= text.length())
	{
		setCurrentBlockState(currState);
		return;
	}
	int offset, commentOffset, cdataOffset, procInstOffset, doctypeOffset, openTagOffset, closeTagOffset;
	int matchedLength = 0;
	int lowest = -1;
	int newState = -1;

	int activeState = currState;
	if (currState < 0) activeState = inNothing;
	switch (activeState)
	{
		case inNothing:
			commentOffset = xmlCommentStartExpression.indexIn(text, startIndex);
			cdataOffset = xmlCDataStartExpression.indexIn(text, startIndex);
			procInstOffset = xmlProcInstStartExpression.indexIn(text, startIndex);
			doctypeOffset = xmlDoctypeStartExpression.indexIn(text, startIndex);
			openTagOffset = xmlOpenTagStartExpression.indexIn(text, startIndex);
			closeTagOffset = xmlCloseTagStartExpression.indexIn(text, startIndex);
			if (commentOffset > lowest)
			{
				lowest = commentOffset;
				newState = inComment;
				matchedLength = xmlCommentStartExpression.matchedLength();
			}
			if (cdataOffset > -1 && (lowest == -1 || cdataOffset < lowest))
			{
				lowest = cdataOffset;
				newState = inCData;
				matchedLength = xmlCDataStartExpression.matchedLength();
			}
			if (procInstOffset > -1 && (lowest == -1 || procInstOffset < lowest))
			{
				lowest = procInstOffset;
				newState = inProcInst;
				matchedLength = xmlProcInstStartExpression.matchedLength();
			}
			if (doctypeOffset > -1 && (lowest == -1 || doctypeOffset < lowest))
			{
				lowest = doctypeOffset;
				newState = inDoctypeDecl;
				matchedLength = xmlDoctypeStartExpression.matchedLength();
			}
			if (openTagOffset > -1 && (lowest == -1 || openTagOffset < lowest))
			{
				lowest = openTagOffset;
				matchedLength = xmlOpenTagStartExpression.matchedLength();
				bool isCDataTag = isCDataTagName(text.mid(openTagOffset, matchedLength));
				newState = isCDataTag ? inCDataTag : inOpenTag;
			}
			if (closeTagOffset > -1 && (lowest == -1 || closeTagOffset < lowest))
			{
				lowest = closeTagOffset;
				newState = inCloseTag;
				matchedLength = xmlCloseTagStartExpression.matchedLength();
			}
			switch (newState)
			{
				case -1:
					setCurrentBlockState(inNothing);
					break;
				case inComment:
					setFormat(commentOffset, matchedLength, xmlCommentFormat);
					setCurrentBlockState(inComment);
					highlightSubBlock(text, commentOffset + matchedLength, inComment);
					break;
				case inCData:
					setFormat(cdataOffset, matchedLength, xmlCDataFormat);
					setCurrentBlockState(inCData);
					highlightSubBlock(text, cdataOffset + matchedLength, inCData);
					break;
				case inProcInst:
					setFormat(procInstOffset, matchedLength, xmlProcInstFormat);
					setCurrentBlockState(inProcInst);
					highlightSubBlock(text, procInstOffset + matchedLength, inProcInst);
					break;
				case inDoctypeDecl:
					setFormat(doctypeOffset, matchedLength, xmlDoctypeFormat);
					setCurrentBlockState(inDoctypeDecl);
					highlightSubBlock(text, doctypeOffset + matchedLength, inDoctypeDecl);
					break;
				case inCDataTag:
				case inOpenTag:
				{
					setFormat(openTagOffset, matchedLength, xmlTagFormat);
					setFormat(openTagOffset, 1, xmlEntityFormat);
					setCurrentBlockState(newState);
					highlightSubBlock(text, openTagOffset + matchedLength, newState);
					break;
				}
				case inCloseTag:
					setFormat(closeTagOffset, matchedLength, xmlTagFormat);
					setFormat(closeTagOffset, 1, xmlEntityFormat);
					setCurrentBlockState(inCloseTag);
					highlightSubBlock(text, closeTagOffset + matchedLength, inCloseTag);
					break;
				default:
					break;
			}
			break;
		case inLuaComment:
			offset = luaMultiCommentEndExpression.indexIn(text, startIndex);
			matchedLength = luaMultiCommentEndExpression.matchedLength();
			if (offset > -1)
			{
				setFormat(startIndex, offset + matchedLength, luaCommentFormat);
				setCurrentBlockState(inCData);
				highlightSubBlock(text, offset + matchedLength, inCData);
			}
			else
			{
				setFormat(startIndex, text.length(), luaCommentFormat);
				setCurrentBlockState(inLuaComment);
			}
			break;
		case inLuaString:
			offset = luaMultiStringEndExpression.indexIn(text, startIndex);
			matchedLength = luaMultiStringEndExpression.matchedLength();
			if (offset > -1)
			{
				setFormat(startIndex, offset + matchedLength, luaStringFormat);
				setCurrentBlockState(inCData);
				highlightSubBlock(text, offset + matchedLength, inCData);
			}
			else
			{
				setFormat(startIndex, text.length(), luaStringFormat);
				setCurrentBlockState(inLuaString);
			}
			break;
		case inCData:
			offset = indexOfCDataTagName(text, startIndex);
			if (offset > -1)
			{
				if (offset > startIndex)
				{
					highlightLua(text, startIndex, offset - startIndex);
				}
				setCurrentBlockState(inNothing);
				highlightSubBlock(text, offset, inNothing);
			}
			else
			{
				offset = xmlCDataEndExpression.indexIn(text, startIndex);
				matchedLength = xmlCDataEndExpression.matchedLength();
				if (offset > -1)
				{
					if (offset > startIndex)
					{
						highlightLua(text, startIndex, offset - startIndex);
					}
					setFormat(offset, matchedLength, xmlCDataFormat);
					setCurrentBlockState(inNothing);
					highlightSubBlock(text, offset + matchedLength, inNothing);
				}
				else
				{
					highlightLua(text, startIndex, text.length()-startIndex);
					setCurrentBlockState(inCData);
				}
			}
			offset = luaMultiCommentStartExpression.indexIn(text, startIndex);
			matchedLength = luaMultiCommentStartExpression.matchedLength();
			if (offset > -1)
			{
				setFormat(offset, text.length(), luaCommentFormat);
				setCurrentBlockState(inLuaComment);
				highlightSubBlock(text, offset + matchedLength, inLuaComment);
			}
			else
			{
				offset = luaMultiStringStartExpression.indexIn(text, startIndex);
				matchedLength = luaMultiStringStartExpression.matchedLength();
				if (offset > -1)
				{
					setFormat(offset, text.length(), luaStringFormat);
					setCurrentBlockState(inLuaString);
					highlightSubBlock(text, offset + matchedLength, inLuaString);
				}
			}
			break;
		case inProcInst:
			offset = xmlProcInstEndExpression.indexIn(text, startIndex);
			matchedLength = xmlProcInstEndExpression.matchedLength();
			if (offset > -1)
			{
				setFormat(startIndex, (offset + matchedLength) - startIndex, xmlProcInstFormat);
				setCurrentBlockState(inNothing);
				highlightSubBlock(text, offset + matchedLength, inNothing);
			}
			else
			{
				setFormat(startIndex, text.length()-startIndex, xmlProcInstFormat);
				setCurrentBlockState(inProcInst);
			}
			break;
		case inDoctypeDecl:
			offset = xmlDoctypeEndExpression.indexIn(text, startIndex);
			matchedLength = xmlDoctypeEndExpression.matchedLength();
			if (offset > -1)
			{
				setFormat(startIndex, (offset + matchedLength) - startIndex, xmlDoctypeFormat);
				setCurrentBlockState(inNothing);
				highlightSubBlock(text, offset + matchedLength, inNothing);
			}
			else
			{
				setFormat(startIndex, text.length()-startIndex, xmlDoctypeFormat);
				setCurrentBlockState(inDoctypeDecl);
			}
			break;
		case inCDataTag:
		case inOpenTag:
		{
			int openTagEndOffset = xmlOpenTagEndExpression.indexIn(text, startIndex);
			int attStartOffset = xmlAttributeStartExpression.indexIn(text, startIndex);
			if (attStartOffset > -1)
			{
				lowest = attStartOffset;
				newState = activeState == inCDataTag ? inCAttVal : inAttVal;
				matchedLength = xmlAttributeStartExpression.matchedLength();
			}
			if (openTagEndOffset > -1 && (lowest == -1 || openTagEndOffset < lowest))
			{
				lowest = openTagEndOffset;
				newState = activeState == inCDataTag ? inCData : inNothing;
                if (newState == inCData && text.at(openTagEndOffset) == '/')
                {
                    newState = inNothing;
                }
				matchedLength = xmlOpenTagEndExpression.matchedLength();
			}
			switch (newState)
			{
				case -1:
					setCurrentBlockState(activeState);
					break;
				case inNothing:
					setFormat(openTagEndOffset, matchedLength, xmlTagFormat);
					setFormat(openTagEndOffset + matchedLength - 1, 1, xmlEntityFormat);
					setCurrentBlockState(inNothing);
					highlightSubBlock(text, openTagEndOffset + matchedLength, inNothing);
					break;
				case inCData:
					setFormat(openTagEndOffset, matchedLength, xmlTagFormat);
					setFormat(openTagEndOffset + matchedLength - 1, 1, xmlEntityFormat);
					setCurrentBlockState(inCData);
					highlightSubBlock(text, openTagEndOffset + matchedLength, inCData);
					break;
				case inCAttVal:
				case inAttVal:
				{
					QChar quote = text.at(attStartOffset + matchedLength - 1);
					setFormat(attStartOffset, matchedLength, xmlAttributeFormat);
					xmlAttributeEndExpression = quote.unicode() == 0x27 ? &xmlQuoteExpression1 : &xmlQuoteExpression2;
					setFormat(text.indexOf("=",attStartOffset), 1, xmlEntityFormat);
					setCurrentBlockState(newState);
					highlightSubBlock(text, attStartOffset + matchedLength, newState);
					break;
				}
				default:
					break;
			}
			break;
		}
		case inCAttVal:
		case inAttVal:
			offset = xmlAttributeEndExpression->indexIn(text, startIndex);
			if (offset > -1)
			{
				setFormat(startIndex, offset-startIndex, xmlAttValFormat);
				setFormat(startIndex-1, 1, xmlAttValFormat);
				setFormat(offset, 1, xmlAttValFormat);
				int toState = activeState == inCAttVal ? inCDataTag : inOpenTag;
				setCurrentBlockState(toState);
				highlightSubBlock(text, offset + 1, toState);
			}
			else
			{
				setFormat(startIndex, text.length()-startIndex, xmlAttValFormat);
				setCurrentBlockState(activeState);
			}
			break;
		case inCloseTag:
		{
			int closeTagEndOffset = xmlCloseTagEndExpression.indexIn(text, startIndex);
			matchedLength = xmlCloseTagEndExpression.matchedLength();
			if (closeTagEndOffset > -1)
			{
				setFormat(closeTagEndOffset, matchedLength, xmlTagFormat);
				setFormat(closeTagEndOffset + matchedLength - 1, 1, xmlEntityFormat);
				setCurrentBlockState(inNothing);
				highlightSubBlock(text, closeTagEndOffset + matchedLength, inNothing);
			}
			else setCurrentBlockState(inCloseTag);
			break;
		}
		case inComment:
			offset = xmlCommentEndExpression.indexIn(text, startIndex);
			matchedLength = xmlCommentEndExpression.matchedLength();
			if (offset > -1)
			{
				setFormat(startIndex, (offset + matchedLength) - startIndex, xmlCommentFormat);
				setCurrentBlockState(inNothing);
				highlightSubBlock(text, offset + matchedLength, inNothing);
			}
			else
			{
				setFormat(startIndex, text.length()-startIndex, xmlCommentFormat);
				setCurrentBlockState(inComment);
			}
			break;
	}
}

void oSyntaxHighlighter::highlightBlock(const QString& text)
{
	highlightSubBlock(text, 0, previousBlockState());
}

bool oSyntaxHighlighter::isCDataTagName(const QString& tagText)
{
    foreach (const QRegExp& pattern, cdataPatterns)
    {
        int index = pattern.indexIn(tagText);
        if (index > -1)
        {
            return true;
        }
    }
	return false;
}

int oSyntaxHighlighter::indexOfCDataTagName(const QString& text, int startIndex)
{
    foreach (const QString& pattern, cdataEndPatterns)
	{
        int index = text.indexOf(pattern, startIndex);
		if (index > -1)
		{
			return index;
		}
	}
	return -1;
}
