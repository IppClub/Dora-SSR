#include "oTextEdit.h"
#include "oSyntaxHighlighter.h"
#include "oDorothyTag.h"

oTextEdit::oTextEdit(const QFont& font, QWidget* parent):
QTextEdit(parent),
_isEmptyPrefix(false),
_completer(nullptr)
{
	QTextEdit::setFont(font);
	_highlighter = new oSyntaxHighlighter(font, document());
}

oTextEdit::~oTextEdit()
{ }

void oTextEdit::setFont(const QFont& font)
{
	QTextEdit::setFont(font);
	_highlighter->setFont(font);
    _completer->popup()->setFont(font);
}

void oTextEdit::contentsChange(int pos, int del, int added)
{
	/*
	QString currentTip;
	foreach (QTextLayout::FormatRange format, textCursor().block().layout()->additionalFormats())
	{
		if (pos >= format.start && pos <= format.start + format.length)
		{
			currentTip = format.format.toolTip();
			break;
		}
	}
	*/
    if (del > 0) return;
	QString text = toPlainText();
    QString input = text.mid(pos,added);
	if (input == "<")
	{
        _resolver.resolve(text.mid(0,pos));
		QStringList words;
		if (_resolver.currentElement().isEmpty())
		{
			words = oDorothyTag::shared().getSubElements("Dorothy");
            words << _resolver.getImports() << "Dorothy";
		}
		else
		{
			words = oDorothyTag::shared().getSubElements(_resolver.currentElement());
            if (oDorothyTag::shared().isElementNode(_resolver.currentElement()) || _resolver.currentElement() == "Stencil")
			{
                words << _resolver.getImports();
            }
        }
        words.sort();
		_completer->setModel(new QStringListModel(words, _completer));
		_completer->setWidget(this);
    }
    else if (input == ">" && text.at(pos-1) != '/')
    {
        _resolver.resolve(text.mid(0,pos));
        if (_resolver.isCurrentInTag() && !_resolver.currentElement().isEmpty() && _resolver.currentAttribute().isEmpty())
        {
            QTextCursor cursor = textCursor();
            int pos = cursor.position();
            cursor.insertText("</"+_resolver.currentElement()+">");
            _highlighter->rehighlightBlock(cursor.block());
            cursor.setPosition(pos);
            setTextCursor(cursor);
        }
    }
    else if (input == "{" && text.at(pos-1) == '\"')
    {
        _resolver.resolve(text.mid(0,pos));
        if (_resolver.isCurrentInTag() && !_resolver.currentElement().isEmpty())
        {
            QTextCursor cursor = textCursor();
            int pos = cursor.position();
            cursor.insertText("  }");
            _highlighter->rehighlightBlock(cursor.block());
            cursor.setPosition(pos+1);
            setTextCursor(cursor);
            _completer->setModel(nullptr);
            _completer->setWidget(this);
        }
    }
    else if (input == " " || input == "\t" || input == "\n")
	{
		_resolver.resolve(text.mid(0,pos));
        if (_resolver.isCurrentInTag() && !_resolver.currentElement().isEmpty() && _resolver.currentAttribute().isEmpty())
		{
			QStringList words = oDorothyTag::shared().getAttributes(_resolver.currentElement());
            if (words.isEmpty())
            {
                bool importedTag = false;
                foreach (const QString& item, _resolver.getImports())
                {
                    if (_resolver.currentElement() == item)
                    {
                        importedTag = true;
                        break;
                    }
                }
                if (importedTag)
                {
                    words << "Name" << "Ref";
                }
            }
            words.sort();
			_completer->setModel(new QStringListModel(words, _completer));
		}
        else _completer->setModel(nullptr);
        _completer->setWidget(this);

        if (input == "\n")
        {
            QTextCursor cursor = textCursor();
            for (int i = 0;i < _resolver.currentPadding();i++)
            {
                cursor.insertText("\t");
            }
            setTextCursor(cursor);
            _highlighter->rehighlightBlock(cursor.block());
        }
	}
	else if (input == "=")
	{
		_resolver.resolve(text.mid(0,pos+1));
		if (_resolver.isCurrentInTag() && !_resolver.currentAttribute().isEmpty())
		{
			QTextCursor cursor = textCursor();
			int pos = cursor.position();
			cursor.insertText("\"\"");
			cursor.setPosition(pos+1);
			setTextCursor(cursor);
			_highlighter->rehighlightBlock(cursor.block());
			QStringList words = oDorothyTag::shared().getAttributeHints(_resolver.currentElement(),_resolver.currentAttribute());
            words.sort();
			_completer->setModel(new QStringListModel(words, _completer));
			_completer->setWidget(this);
		}
	}
	else if (input == "/")
	{
		_resolver.resolve(text.mid(0,pos+1));
		if (_resolver.isCurrentInTag() && _resolver.currentAttribute().isEmpty())
		{
			QTextCursor cursor = textCursor();
			cursor.insertText(">");
			setTextCursor(cursor);
            _highlighter->rehighlightBlock(cursor.block());
            _completer->setModel(nullptr);
			_completer->setWidget(this);
		}
    }
    else if (pos > 0 && text.at(pos-1) == ' ')
    {
		_resolver.resolve(text.mid(0,pos-1));
        if (_resolver.isCurrentInTag() && !_resolver.currentElement().isEmpty() && _resolver.currentAttribute().isEmpty())
        {
			QStringList words = oDorothyTag::shared().getAttributes(_resolver.currentElement());
            if (words.isEmpty())
            {
                bool importedTag = false;
                foreach (const QString& item, _resolver.getImports())
                {
                    if (_resolver.currentElement() == item)
                    {
                        importedTag = true;
                        break;
                    }
                }
                if (importedTag)
                {
                    words << "Name" << "Ref";
                }
            }
            words.sort();
			_completer->setModel(new QStringListModel(words, _completer));
			_completer->setWidget(this);
		}
    }
    else
    {
        _resolver.resolve(text.mid(0,pos+1));
        if (!_resolver.isCurrentInTag())
        {
            _completer->setModel(nullptr);
            _completer->setWidget(this);
        }
    }
}

void oTextEdit::setCompleter(QCompleter* comp)
{
	if (_completer)
	{
		_completer->popup()->hide();
		QObject::disconnect(_completer, nullptr, this, nullptr);
	}
	_completer = comp;
	if (!_completer) return;

	_completer->setWidget(this);
	_completer->setCompletionMode(QCompleter::PopupCompletion);
	_completer->setCaseSensitivity(Qt::CaseInsensitive);
    _completer->popup()->setFont(font());
	QObject::connect(_completer, SIGNAL(activated(QString)), this, SLOT(insertCompletion(QString)));
	QObject::connect(this->document(), SIGNAL(contentsChange(int,int,int)), this, SLOT(contentsChange(int,int,int)));
}

QCompleter* oTextEdit::completer() const
{
	return _completer;
}

void oTextEdit::insertCompletion(const QString& completion)
{
	if (_completer->widget() != this) return;

	QTextCursor cursor = textCursor();
	if (!_isEmptyPrefix)
	{
		cursor.select(QTextCursor::WordUnderCursor);
		QString text = cursor.selectedText();
		if (!text.isEmpty())
		{
			if (text.at(0) == '>' ||
				text.at(0) == '/' ||
				text.at(0) == '\"' ||
                text.at(0) == ' ' ||
                text.at(0) == '\t')
			{
				cursor = textCursor();
				cursor.setPosition(std::max(cursor.position()-1, 0));
				cursor.select(QTextCursor::WordUnderCursor);
			}
			else if (text.startsWith("=\"\""))
			{
				cursor.clearSelection();
				cursor.movePosition(QTextCursor::PreviousWord);
				cursor.setPosition(std::max(cursor.position()+2, 0));
			}
		}
		cursor.removeSelectedText();
	}
	cursor.insertText(completion);
	setTextCursor(cursor);
}

QString oTextEdit::textUnderCursor() const
{
	QTextCursor cursor = textCursor();
	cursor.select(QTextCursor::WordUnderCursor);
	return cursor.selectedText();
}

void oTextEdit::focusInEvent(QFocusEvent* e)
{
	if (_completer) _completer->setWidget(this);
	QTextEdit::focusInEvent(e);
}

void oTextEdit::keyPressEvent(QKeyEvent* e)
{
	if (_completer && _completer->popup()->isVisible())
	{
		switch (e->key())
		{
			case Qt::Key_Enter:
			case Qt::Key_Return:
			case Qt::Key_Escape:
			case Qt::Key_Tab:
			//case Qt::Key_Backtab:
				e->ignore();
				return; // let the _completer do default behavior
			default:
				break;
		}
	}

	bool isShortcut = ((e->modifiers() & Qt::ControlModifier) && e->key() == Qt::Key_E); // CTRL+E
	if (!_completer || !isShortcut) // do not process the shortcut when we have a completer
	{
		QTextEdit::keyPressEvent(e);
	}

	if (!_completer || (!isShortcut && e->text().isEmpty())) return;

	static QRegExp eow("\\w|<|=|\"|\\s");
	QString completionPrefix = textUnderCursor();

	if (!completionPrefix.isEmpty())
	{
		if (completionPrefix.at(0) == '=' ||
                         e->text() == " " ||
                         e->text() == "\t")
		{
			completionPrefix = "";
		}
		else if (completionPrefix.at(0) == '>' ||
			completionPrefix.at(0) == '/' ||
			completionPrefix.at(0) == '\"')
		{
			QTextCursor cursor = textCursor();
			cursor.setPosition(std::max(cursor.position()-1, 0));
			cursor.select(QTextCursor::WordUnderCursor);
			completionPrefix = cursor.selectedText();
		}
	}

	if (!isShortcut &&
		(e->text().isEmpty() ||
		 eow.indexIn(e->text().right(1)) == -1 ||
		 (completionPrefix.isEmpty() &&
		  e->text() != "<" &&
		  e->text() != "=" &&
          e->text() != " " &&
          e->text() != "\t")
		))
	{
		_completer->popup()->hide();
		return;
	}

	_isEmptyPrefix = completionPrefix.isEmpty();

	// update complete list
	if (completionPrefix != _completer->completionPrefix())
	{
		_completer->setCompletionPrefix(completionPrefix);
		_completer->popup()->setCurrentIndex(_completer->completionModel()->index(0, 0));
	}
	QRect cr = cursorRect();
	cr.setWidth(_completer->popup()->sizeHintForColumn(0)
				+ _completer->popup()->verticalScrollBar()->sizeHint().width());
	_completer->complete(cr); // popup it up!
}

oXmlResolver* oTextEdit::resolver()
{
    return &_resolver;
}

oSyntaxHighlighter* oTextEdit::highlighter()
{
    return _highlighter;
}
