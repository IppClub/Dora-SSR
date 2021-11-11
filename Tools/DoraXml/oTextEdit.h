#ifndef OTEXTEDIT_H
#define OTEXTEDIT_H

#include "oDefine.h"
#include "oXmlResolver.h"

class QCompleter;
class oSyntaxHighlighter;

class oTextEdit : public QTextEdit
{
	Q_OBJECT

public:
	explicit oTextEdit(const QFont& font, QWidget* parent = nullptr);
	virtual ~oTextEdit();

	void setCompleter(QCompleter* comp);
	QCompleter* completer() const;

	void setFont(const QFont& font);

    oXmlResolver* resolver();
    oSyntaxHighlighter* highlighter();
protected:
	virtual void keyPressEvent(QKeyEvent *e) Q_DECL_OVERRIDE;
	virtual void focusInEvent(QFocusEvent *e) Q_DECL_OVERRIDE;

protected slots:
	void insertCompletion(const QString& completion);
	void contentsChange(int pos, int removed, int added);
private:
	QString textUnderCursor() const;

private:
	bool _isEmptyPrefix;
	QCompleter* _completer;
	oSyntaxHighlighter* _highlighter;
	oXmlResolver _resolver;
};

#endif // OTEXTEDIT_H
