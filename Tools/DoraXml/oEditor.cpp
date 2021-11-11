#include "oEditor.h"
#include "oSyntaxHighlighter.h"
#include "oNumberBar.h"
#include "oTextEdit.h"

oEditor::oEditor(QWidget* parent, const QString& filePath):
QFrame(parent),
_filePath(filePath)
{
	_view = new oTextEdit(QFont(), this);
    _view->setAcceptRichText(false);
    _view->setTabStopDistance(fontMetrics().boundingRect(QString("0000")).width());
    _view->setLineWrapMode(QTextEdit::WidgetWidth);
    _view->setFrameStyle(QFrame::NoFrame);

    _numberBar = new oNumberBar(_view, this);

    _box = new QHBoxLayout(this);
    _box->setSpacing(0);
    _box->setContentsMargins(0, 0, 0, 0);
    _box->addWidget(_numberBar);
    _box->addWidget(_view);

    QCompleter* completer = new QCompleter(this);
    completer->setModelSorting(QCompleter::CaseInsensitivelySortedModel);
    completer->setCaseSensitivity(Qt::CaseInsensitive);
    completer->setWrapAround(false);
    _view->setCompleter(completer);

    QFile file(filePath);
	file.open(QFile::ReadOnly | QFile::Text);
    QTextStream in(&file);
    _view->setPlainText(in.readAll());
    _view->document()->setModified(false);

    QObject::connect(_view->document(),SIGNAL(modificationChanged(bool)),this,SLOT(documentChanged(bool)));
}

oEditor::~oEditor()
{ }

void oEditor::setFont(const QFont& font)
{
	QFrame::setFont(font);
	_view->setFont(font);
	_numberBar->setFont(font);
}

void oEditor::documentChanged(bool modified)
{
    emit editorChanged(this, modified);
}

QString oEditor::getFileName()
{
    return QFileInfo(_filePath).fileName();
}

const QString& oEditor::getFilePath()
{
    return _filePath;
}

bool oEditor::isModified()
{
    return _view->document()->isModified();
}

void oEditor::save()
{
    if (_view->document()->isModified())
    {
        QFile file(_filePath);
        if (file.open(QFile::WriteOnly | QFile::Truncate))
        {
            QTextStream out(&file);
            out << _view->toPlainText();
            _view->document()->setModified(false);
        }
    }
}

oTextEdit* oEditor::view()
{
    return _view;
}
