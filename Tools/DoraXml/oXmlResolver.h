#ifndef OXMLRESOLVER_H
#define OXMLRESOLVER_H

#include "oDefine.h"

class oXmlResolver
{
public:
	oXmlResolver();
	~oXmlResolver();
	void resolve(const QString& text);
    const QStringList& getImports();
	const QString& currentElement();
	const QString& currentAttribute();
	bool isCurrentInTag();
	int currentPadding();
private:
	bool parse(const char* codes, int length);
private:
	bool _isInTag;
	int _currentPadding;
	QString _currentElement;
	QString _currentAttribute;
    QStringList _imports;
};

#endif // OXMLRESOLVER_H
