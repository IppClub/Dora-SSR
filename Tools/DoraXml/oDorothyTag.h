#ifndef ODOROTHYTAG_H
#define ODOROTHYTAG_H

#include "oDefine.h"

class oDorothyTag
{
public:
	oDorothyTag();
	~oDorothyTag();
	QStringList getAttributes(const QString& elementName);
	QStringList getAttributeHints(const QString& elementName, const QString& attrName);
	QStringList getSubElements(const QString& elementName);
    bool isElementNode(const QString& elementName);
	static oDorothyTag& shared();
private:
	void load();
	int getType(const QString& line);

private:
	enum
	{
		None,
		List,
		Element,
		Attribute
	};

	class oAttribute
	{
	public:
		oAttribute(const QString& name, shared_ptr<QStringList> hints);
		~oAttribute();
		QString name;
		shared_ptr<QStringList> hints;
	};

	struct oElement
	{
        bool isNode;
		QString base;
		shared_ptr<QStringList> parents;
		QStringList subElements;
		QList<shared_ptr<oAttribute>> attributes;
	};

	QHash<QString, shared_ptr<oElement>> _elements;
	QStringList elementNames;
};

#endif // ODOROTHYTAG_H
