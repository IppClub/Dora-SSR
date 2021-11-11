#ifndef ONUMBERBAR_H
#define ONUMBERBAR_H

#include "oDefine.h"

class QTextEdit;

class oNumberBar : public QWidget
{
	Q_OBJECT

public:
	oNumberBar(QTextEdit* textEdit, QWidget* parent = nullptr);
	virtual ~oNumberBar();
	virtual void paintEvent(QPaintEvent* ev) Q_DECL_OVERRIDE;
	void setFont(const QFont& font);

private:
	QTextEdit* _textEdit;
};

#endif // ONUMBERBAR_H
