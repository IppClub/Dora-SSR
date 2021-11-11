#include "oDefine.h"
#include "oMainWindow.h"

int main(int argc, char *argv[])
{
	QApplication app(argc, argv);
    oMainWindow window;
	window.show();
	return app.exec();
}
