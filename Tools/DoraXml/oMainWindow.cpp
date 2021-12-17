#include "oMainWindow.h"
#include "ui_oMainWindow.h"
#include "oEditor.h"
#include "oTextEdit.h"
#include "oXmlResolver.h"
#include "oSyntaxHighlighter.h"

#define SETTING_NAMES "DorothySSR","DoraXml"

oMainWindow::oMainWindow(QWidget *parent)
: QMainWindow(parent)
, _closingTabIndex(-1)
, ui(new Ui::oMainWindow)
{
    ui->setupUi(this);
    QObject::connect(ui->action_Open,SIGNAL(triggered()),this,SLOT(openFileEvent()));
	QObject::connect(ui->actionSave,SIGNAL(triggered()),this,SLOT(saveCurrentTab()));
	QObject::connect(ui->actionSave_All,SIGNAL(triggered()),this,SLOT(saveAllTabs()));
	QObject::connect(ui->actionClose,SIGNAL(triggered()),this,SLOT(saveAndCloseTab()));
	QObject::connect(ui->action_New,SIGNAL(triggered()),this,SLOT(newFileEvent()));
	QObject::connect(ui->actionFont,SIGNAL(triggered()),this,SLOT(fontSettingEvent()));
    QObject::connect(ui->actionColorPicker,SIGNAL(triggered()),this,SLOT(colorPickerEvent()));
    QObject::connect(ui->tabWidget,SIGNAL(tabCloseRequested(int)),this,SLOT(tabCloseEvent(int)));

    QSettings settings(QSettings::IniFormat, QSettings::UserScope, SETTING_NAMES);

	_defaultFont = settings.value("Font",_defaultFont).value<QFont>();

	QString pathStr = settings.value("LastOpened").toString();
	if (!pathStr.isEmpty())
	{
        QStringList paths = pathStr.split(";",Qt::SkipEmptyParts);
		foreach (QString path, paths)
		{
            if (QFileInfo::exists(path))
			{
				this->addTab(path);
			}
		}
	}
}

oMainWindow::~oMainWindow()
{
    delete ui;
}

void oMainWindow::addTab(const QString& filePath)
{
	oEditor* editor = new oEditor(ui->tabWidget, filePath);
	editor->setFont(_defaultFont);
	int index = ui->tabWidget->addTab(editor, QFileInfo(filePath).fileName());
	QObject::connect(editor,SIGNAL(editorChanged(oEditor*,bool)),this,SLOT(tabChanged(oEditor*,bool)));
	ui->tabWidget->setCurrentIndex(index);
	ui->tabWidget->setTabToolTip(index,editor->getFilePath());
}

void oMainWindow::colorPickerEvent()
{
    _colorPickerOptions = QColorDialog::ShowAlphaChannel;
    oEditor* editor = static_cast<oEditor*>(ui->tabWidget->currentWidget());
    if (editor)
    {
        oTextEdit* textEdit = editor->view();
        QString text = textEdit->toPlainText();
        QTextCursor cursor = textEdit->textCursor();
        oXmlResolver* resolver = textEdit->resolver();
        resolver->resolve(text.mid(0,cursor.position()));
        if (resolver->isCurrentInTag() && !resolver->currentAttribute().isEmpty())
        {
            if (resolver->currentAttribute() == "Color3")
            {
                _colorPickerOptions = 0;
            }
        }
    }
    QColorDialog* colorDialog = new QColorDialog();
    colorDialog->setOptions(QColorDialog::ColorDialogOptions(_colorPickerOptions));
    colorDialog->show();
    QObject::connect(colorDialog,SIGNAL(colorSelected(QColor)),this,SLOT(colorSelected(QColor)));
}

void oMainWindow::colorSelected(const QColor& color)
{
    QString result = _colorPickerOptions ?
                        QString("0x%1%2%3%4")
                            .arg(color.alpha(),2,16,QChar('0'))
                            .arg(color.red(),2,16,QChar('0'))
                            .arg(color.green(),2,16,QChar('0'))
                            .arg(color.blue(),2,16,QChar('0')) :
                        QString("0x%1%2%3")
                            .arg(color.red(),2,16,QChar('0'))
                            .arg(color.green(),2,16,QChar('0'))
                            .arg(color.blue(),2,16,QChar('0'));
    oEditor* editor = static_cast<oEditor*>(ui->tabWidget->currentWidget());
    if (editor)
    {
        oTextEdit* textEdit = editor->view();
        QTextCursor cursor = textEdit->textCursor();
        cursor.insertText(result);
        textEdit->highlighter()->rehighlightBlock(cursor.block());
        textEdit->setTextCursor(cursor);
    }
}

void oMainWindow::fontSettingEvent()
{
	bool ok;
	_defaultFont = QFontDialog::getFont(&ok, _defaultFont, this);
	if (ok)
	{
		QTabBar* tabBar = ui->tabWidget->tabBar();
		for (int i = 0;i < tabBar->count();i++)
		{
            oEditor* editor = static_cast<oEditor*>(ui->tabWidget->widget(i));
			editor->setFont(_defaultFont);
		}
        QSettings settings(QSettings::IniFormat, QSettings::UserScope, SETTING_NAMES);
		settings.setValue("Font", _defaultFont);
	}
}

void oMainWindow::newFileEvent()
{
	QString filePath = QFileDialog::getSaveFileName(this,"","","*.xml");
	if (!filePath.isEmpty())
	{
        if (QFileInfo(filePath).suffix().toLower() != "xml")
        {
            filePath += ".xml";
        }
		this->addTab(filePath);
	}
}

void oMainWindow::openFileEvent()
{
    QStringList filePaths = QFileDialog::getOpenFileNames(this,"","","*.xml");
    if (!filePaths.isEmpty())
    {
        foreach(QString filePath, filePaths)
        {
            QTabBar* tabBar = ui->tabWidget->tabBar();
            for (int i = 0;i < tabBar->count();i++)
            {
                if (filePath == tabBar->tabToolTip(i))
                {
                    ui->tabWidget->setCurrentIndex(i);
                    return;
                }
            }
			this->addTab(filePath);
        }
    }
}

void oMainWindow::tabChanged(oEditor* editor, bool modified)
{
    ui->tabWidget->setTabText(ui->tabWidget->indexOf(editor), (modified ? "*" : "")+editor->getFileName());
}

void oMainWindow::tabCloseEvent(int index)
{
    oEditor* editor = static_cast<oEditor*>(ui->tabWidget->widget(index));
    if (editor->isModified())
    {
        _closingTabIndex = index;
		QMessageBox* box = new QMessageBox(QMessageBox::Warning,"Closing Tab","Close the modified tab?",QMessageBox::Ok|QMessageBox::Save|QMessageBox::Cancel);
        QObject::connect(box,SIGNAL(buttonClicked(QAbstractButton*)),this,SLOT(closeModifiedTabEvent(QAbstractButton*)));
        box->show();
    }
    else ui->tabWidget->removeTab(index);
}

void oMainWindow::saveCurrentTab()
{
    oEditor* editor = static_cast<oEditor*>(ui->tabWidget->currentWidget());
    if (editor) editor->save();
}

void oMainWindow::closeModifiedTabEvent(QAbstractButton* button)
{
    if (button->text() == "OK")
    {
        ui->tabWidget->removeTab(_closingTabIndex);
    }
    else if (button->text() == "Save")
    {
        oEditor* editor = static_cast<oEditor*>(ui->tabWidget->widget(_closingTabIndex));
        editor->save();
        ui->tabWidget->removeTab(_closingTabIndex);
    }
    _closingTabIndex = -1;
}

void oMainWindow::saveAllTabs()
{
	QTabBar* tabBar = ui->tabWidget->tabBar();
	for (int i = 0;i < tabBar->count();i++)
	{
        oEditor* editor = static_cast<oEditor*>(ui->tabWidget->widget(i));
		editor->save();
	}
}

void oMainWindow::saveAndCloseTab()
{
    oEditor* editor = static_cast<oEditor*>(ui->tabWidget->currentWidget());
    if (editor)
    {
        editor->save();
        ui->tabWidget->removeTab(ui->tabWidget->indexOf(editor));
    }
}

void oMainWindow::closeEvent(QCloseEvent* event)
{
	bool needSave = false;
    QTabBar* tabBar = ui->tabWidget->tabBar();
	for (int i = 0;i < tabBar->count();i++)
	{
        oEditor* editor = static_cast<oEditor*>(ui->tabWidget->widget(i));
		if (editor->isModified())
		{
			needSave = true;
			break;
		}
	}
	if (needSave)
	{
		QMessageBox::StandardButton ret = QMessageBox::warning(this,
						tr("Application"),
						 tr("The document has been modified.\n"
							"Do you want to save your changes?"),
						 QMessageBox::Save | QMessageBox::Discard | QMessageBox::Cancel);
		if (ret == QMessageBox::Save)
		{
			saveAllTabs();
			event->accept();
		}
		else if (ret == QMessageBox::Cancel)
		{
			event->ignore();
		}
		else event->accept();
	}
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, SETTING_NAMES);
	QString paths;
	for (int i = 0;i < tabBar->count();i++)
	{
		paths += (tabBar->tabToolTip(i) + ";");
	}
	settings.setValue("LastOpened", paths);
}
