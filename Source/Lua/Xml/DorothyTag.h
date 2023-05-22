#pragma once

NS_DOROTHY_BEGIN

class DorothyTag {
public:
	DorothyTag();
	~DorothyTag();
	std::list<std::string> getAttributes(const std::string& elementName);
	std::list<std::string> getAttributeHints(const std::string& elementName, const std::string& attrName);
	std::list<std::string> getSubElements(const std::string& elementName);
	bool isElementNode(const std::string& elementName);
	static DorothyTag& shared();

private:
	void load();
	enum class LineType {
		None,
		List,
		Element,
		Attribute
	};
	LineType getType(const std::string& line);

private:
	class Attribute {
	public:
		Attribute(const std::string& name, std::shared_ptr<std::list<std::string>> hints);
		~Attribute();
		std::string name;
		std::shared_ptr<std::list<std::string>> hints;
	};

	struct Element {
		bool isNode;
		std::string base;
		std::shared_ptr<std::list<std::string>> parents;
		std::list<std::string> subElements;
		std::list<std::shared_ptr<Attribute>> attributes;
	};

	std::unordered_map<std::string, std::shared_ptr<Element>> _elements;
	std::list<std::string> elementNames;
};

NS_DOROTHY_END
