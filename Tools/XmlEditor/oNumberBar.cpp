#include "oNumberBar.h"

oNumberBar::oNumberBar(QTextEdit* textEdit, QWidget* parent):
QWidget(parent),
_textEdit(textEdit)
{
	QWidget::setFont(textEdit->font());
    setFixedWidth(fontMetrics().boundingRect(QString("00000")).width());
	connect(_textEdit->document()->documentLayout(), SIGNAL(update(const QRectF&)), this, SLOT(update()));
	connect(_textEdit->verticalScrollBar(), SIGNAL(valueChanged(int)), this, SLOT(update()));
}

oNumberBar::~oNumberBar()
{ }

void oNumberBar::setFont(const QFont& font)
{
	QWidget::setFont(font);
    setFixedWidth(fontMetrics().boundingRect(QString("00000")).width());
}

void oNumberBar::paintEvent(QPaintEvent*)
{
	QAbstractTextDocumentLayout* layout = _textEdit->document()->documentLayout();
	int contentsY = _textEdit->verticalScrollBar()->value();
	qreal pageBottom = contentsY + _textEdit->viewport()->height();
	const QFontMetrics fm = fontMetrics();
	const int ascent = fontMetrics().ascent() + 1;
	int lineCount = 1;

	QPainter painter(this);

	for (QTextBlock block = _textEdit->document()->begin(); block.isValid(); block = block.next(), ++lineCount)
	{
		const QRectF boundingRect = layout->blockBoundingRect(block);

		QPointF position = boundingRect.topLeft();
		if (position.y() + boundingRect.height() < contentsY) continue;
		if (position.y() > pageBottom) break;

		const QString txt = QString::number(lineCount);
        painter.drawText(width()- 10 - fm.boundingRect(txt).width(), qRound(position.y()) - contentsY + ascent, txt);
	}
}


