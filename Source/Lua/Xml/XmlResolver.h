#pragma once

NS_DOROTHY_BEGIN

class XmlResolver {
public:
	XmlResolver();
	~XmlResolver();
	void resolve(String text);
	const std::list<std::string>& getImports();
	const std::string& getCurrentElement();
	const std::string& getCurrentAttribute();
	bool isCurrentInTag();
	int getCurrentPadding();

private:
	bool parse(const char* codes, int length);

private:
	bool _isInTag;
	int _currentPadding;
	std::string _currentElement;
	std::string _currentAttribute;
	std::list<std::string> _imports;
};

NS_DOROTHY_END
