#ifndef OCOMMANDDIALOG_H
#define OCOMMANDDIALOG_H

#include <QDialog>

namespace Ui {
class oCommandDialog;
}

class oCommandDialog : public QDialog
{
    Q_OBJECT

public:
    explicit oCommandDialog(QWidget *parent = nullptr);
    ~oCommandDialog();
    void setCommand(const QString& command);
    QString command() const;

private:
    Ui::oCommandDialog *ui;
};

#endif // OCOMMANDDIALOG_H
