#ifndef OMAINWINDOW_H
#define OMAINWINDOW_H

#include "oDefine.h"
#include <QMainWindow>
#include "oCommandDialog.h"

namespace Ui {
class oMainWindow;
}

class oEditor;

class oMainWindow : public QMainWindow
{
    Q_OBJECT
public:
    explicit oMainWindow(QWidget *parent = 0);
	~oMainWindow();
	void addTab(const QString& filePath);
	void closeEvent(QCloseEvent* event) Q_DECL_OVERRIDE;
private slots:
	void newFileEvent();
	void saveAllTabs();
	void saveAndCloseTab();
	void openFileEvent();
	void fontSettingEvent();
    void colorPickerEvent();
    void commandSettingEvent();
	void saveCurrentTab();
    void saveRunCommand();
    void runCommand();
	void tabChanged(oEditor* editor, bool modified);
	void tabCloseEvent(int index);
	void closeModifiedTabEvent(QAbstractButton* button);
    void colorSelected(const QColor& color);
private:
    int _closingTabIndex;
    QFont _defaultFont;
    QString _runCommand;
    unsigned int _colorPickerOptions;
    Ui::oMainWindow *ui;
    oCommandDialog _commandDialog;
    QProcess _process;
};

#endif // OMAINWINDOW_H
