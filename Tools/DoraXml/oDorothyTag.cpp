#include "oDorothyTag.h"

oDorothyTag& oDorothyTag::shared()
{
	static oDorothyTag tag;
	return tag;
}

oDorothyTag::oAttribute::oAttribute(const QString& name, shared_ptr<QStringList> hints):
name(name),
hints(hints)
{ }

oDorothyTag::oAttribute::~oAttribute()
{ }

oDorothyTag::oDorothyTag()
{
	oDorothyTag::load();
}

oDorothyTag::~oDorothyTag()
{ }

int oDorothyTag::getType(const QString& line)
{
	if (line.trimmed().isEmpty()) return None;
	else if (line.at(0) != '\t' && line.at(0) != ' ') return line.indexOf(':') != -1 ? List : Element;
	else return Attribute;
}

void oDorothyTag::load()
{
	QFile file(":/DorothyTag.txt");
	file.open(QFile::ReadOnly);

	QHash<QString, shared_ptr<QStringList>> lists;
    QRegularExpression whiteSpaceExpression("\\s+");
	QString elementName;
	shared_ptr<oElement> element;

	while (!file.atEnd())
	{
		QString line(file.readLine());
		switch (getType(line))
		{
			case None:
				break;
			case List:
			{
				int index = line.indexOf(':');
                shared_ptr<QStringList> list(new QStringList(line.mid(index+1).replace(whiteSpaceExpression,"").split(',',Qt::SkipEmptyParts)));
				lists[line.mid(0,index)] = list;
                break;
			}
			case Element:
			{
				if (element) _elements[elementName] = element;
                elementName = line.replace(whiteSpaceExpression,"");
                element = std::make_shared<oElement>();
                element->isNode = elementName == "Node";
				elementNames.append(elementName);
				break;
			}
			case Attribute:
			{
				line = line.replace(whiteSpaceExpression,"");
				int index = line.indexOf(':');
				if (index != -1)// has hints
				{
					QString attrName = line.mid(0,index);
					QString hints = line.mid(index+1);
					if (attrName == "Base")
					{
						if (hints != "No")
                        {
                            element->isNode = elementName == "Node" ? true : _elements[hints]->isNode;
							element->base = hints;
						}
					}
					else if (attrName == "Parent")
					{
						if (hints != "No")
						{
							shared_ptr<QStringList> list;
							if (hints.indexOf(',') != -1)
							{
                                list = std::make_shared<QStringList>(hints.split(',',Qt::SkipEmptyParts));
							}
							else if (hints == "*")
							{
								list = std::make_shared<QStringList>();
							}
							else
							{
								QString listName = line.mid(index+1);
								list = lists[listName];
							}
							element->parents = list;
						}
					}
					else
					{
						shared_ptr<QStringList> list;
						if (hints.indexOf(',') != -1)
						{
                            list = std::make_shared<QStringList>(hints.split(',',Qt::SkipEmptyParts));
						}
						else
						{
							QString listName = line.mid(index+1);
							list = lists[listName];
						}
						element->attributes.append(std::make_shared<oAttribute>(attrName,list));
					}
				}
				else
				{
					element->attributes.append(std::make_shared<oAttribute>(line,nullptr));
				}
				break;
			}
			default:
				break;
		}
	}
	if (element)
	{
		_elements[elementName] = element;
		element = nullptr;
	}
	foreach (const QString& name, elementNames)
	{
		const auto& element = _elements.value(name);
		if (element->parents)
		{
			QStringList& parents = *(element->parents);
			foreach (const QString& parent, parents)
			{
				_elements[parent]->subElements.append(name);
			}
			element->parents = nullptr;
		}
		if (!element->base.isEmpty())
		{
			const auto& attributes = _elements[element->base]->attributes;
			foreach (const shared_ptr<oAttribute>& attr, attributes)
			{
				element->attributes.append(attr);
			}
		}
	}
}

QStringList oDorothyTag::getAttributes(const QString& elementName)
{
	QStringList attrs;
	auto it = _elements.find(elementName);
	if (it != _elements.end())
	{
		foreach (const shared_ptr<oAttribute>& attr, it.value()->attributes)
		{
			attrs << attr->name;
		}
	}
	return attrs;
}

QStringList oDorothyTag::getAttributeHints(const QString& elementName, const QString& attrName)
{
	auto it = _elements.find(elementName);
	if (it != _elements.end())
	{
		foreach (const shared_ptr<oAttribute>& attr, it.value()->attributes)
		{
			if (attr->name == attrName && attr->hints)
			{
				return *attr->hints;
			}
		}
	}
    else if (attrName == "Ref")
    {
        return QStringList() << "True" << "False";
    }
	return QStringList();
}

QStringList oDorothyTag::getSubElements(const QString& elementName)
{
	auto it = _elements.find(elementName);
	if (it != _elements.end())
	{
		return it.value()->subElements;
	}
	else
	{
		it = _elements.find("Node");
		if (it != _elements.end())
        {
            return QStringList(it.value()->subElements);
		}
	}
	return QStringList();
}

bool oDorothyTag::isElementNode(const QString& elementName)
{
    auto it = _elements.find(elementName);
    if (it != _elements.end())
    {
        return it.value()->isNode;
    }
	return true;
}
