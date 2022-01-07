#include "oCommandDialog.h"
#include "ui_oCommandDialog.h"

oCommandDialog::oCommandDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::oCommandDialog)
{
    ui->setupUi(this);
}

void oCommandDialog::setCommand(const QString& command)
{
    ui->lineEdit->setText(command);
}

QString oCommandDialog::command() const
{
    return ui->lineEdit->text();
}

oCommandDialog::~oCommandDialog()
{
    delete ui;
}
