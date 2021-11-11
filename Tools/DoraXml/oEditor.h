#ifndef OEDITOR_H
#define OEDITOR_H

#include "oDefine.h"

class QHBoxLayout;
class QCompleter;

class oSyntaxHighlighter;
class oNumberBar;
class oTextEdit;

class oEditor : public QFrame
{
	Q_OBJECT
public:
    oEditor(QWidget* parent = nullptr, const QString& filePath = "");
    virtual ~oEditor();
public:
	void setFont(const QFont &);
    QString getFileName();
    const QString& getFilePath();
    bool isModified();
    oTextEdit* view();
public slots:
    void documentChanged(bool modified);
    void save();
signals:
    void editorChanged(oEditor* editor,bool modified);
private:
    QString _filePath;
    oTextEdit* _view;
    QHBoxLayout* _box;
    oNumberBar* _numberBar;
};


#endif // OEDITOR_H

