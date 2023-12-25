/*
MIT License

Copyright (c) 2021 septbr, modified by Li Jin, 2021

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
#pragma once

#include "Const/Header.h"
#include "tinyxml2/tinyxml2.h"
#include "ZipUtils.h"

#include <cstring>
#include <string>
#include <vector>
#include <map>
#include <memory>
#include <variant>

namespace xlsxtext
{
	class reference
	{
	public:
		unsigned row;
		unsigned col;

		reference() noexcept : reference(0, 0) {}
		reference(unsigned row, unsigned col) noexcept : row(row), col(col) {}
		reference(const std::string &value) noexcept { this->value(value); }

		void value(const std::string &value) noexcept
		{
			row = col = 0;
			for (std::string::size_type i = 0; i < value.size(); ++i)
			{
				auto c = value[i];
				if (row == 0 && 'A' <= c && c <= 'Z')
					col = col * 26 + (c - 'A') + 1;
				else if (col > 0 && '0' <= c && c <= '9')
					row = row * 10 + (c - '0');
				else
				{
					row = col = 0;
					break;
				}
			}
		}
		std::string value() const noexcept
		{
			std::string value = "";
			if (row > 0 && col > 0)
			{
				auto col_ = col;
				while (col_ > 0)
				{
					char c = (col_ - 1) % 26 + 'A';
					value = c + value;
					col_ = (col_ - (c - 'A' + 1)) / 26;
				}
				value += std::to_string(row);
			}
			return value;
		}

		operator bool() const noexcept { return row > 0 && col > 0; }
	};

	class cell
	{
	public:
		reference refer;
		long string_id;
		std::string value;
		cell(reference reference, const std::string& value, long string_id = -1) noexcept : refer(reference), value(value), string_id(string_id) {}
		cell(std::string reference, const std::string& value, long string_id = -1) noexcept : refer(reference), value(value), string_id(string_id) {}
		cell(unsigned row, unsigned col, const std::string& value, long string_id = -1) noexcept : refer(row, col), value(value), string_id(string_id) {}
	};

	class worksheet
	{
	protected:
		struct package
		{
			std::unique_ptr<ZipFile> archive;
			std::vector<std::string> shared_strings{}; // text
			virtual ~package() { }
		};

	protected:
		std::shared_ptr<package> _package;

	private:
		unsigned _max_col;
		unsigned _max_row;
		std::string _part;
		std::string _name;
		std::vector<std::vector<cell>> _rows;

	protected:
		worksheet(std::shared_ptr<package> package) noexcept : _package(package), _max_col(0), _max_row(0) {}
		worksheet(const std::string &name, const std::string &part, std::shared_ptr<package> package) noexcept : _name(name), _part(part), _package(package), _max_col(0), _max_row(0) {}
		static worksheet create(const std::string &name, const std::string &part, std::shared_ptr<package> package) noexcept { return worksheet(name, part, package); }

	private:
		std::variant<std::string, long> read_value(const std::string &v, const std::string &t, const std::string &s, std::string &error) const
		{
			if (t == "s"sv)
			{
				long index = std::stol(v);
				if (index < s_cast<long>(_package->shared_strings.size()))
					return index;
				else
					return "";
			}
			else if (t == "d"sv)
			{
				error = "date type is not supported";
			}
			else if (t == "e"sv)
			{
				error = "cell error";
			}
			return Slice(v).trimSpace().toString();
		}

	public:
		const std::string& name() const noexcept { return _name; }
		std::map<std::string, std::string> read()
		{
			_rows.clear();

			std::map<std::string, std::string> errors;

			auto buffer = _package->archive->getFileData(_part.c_str());
			if (buffer.first)
			{
				/**
				 * <xsd:simpleType name="ST_Xstring">
				 *	 <xsd:restriction base="xsd:string"/>
				 * </xsd:simpleType>
				 * <xsd:complexType name="CT_RElt">
				 *	 <xsd:sequence>
				 *		 <xsd:element name="t" type="s:ST_Xstring" minOccurs="1" maxOccurs="1"/>
				 *	 </xsd:sequence>
				 * </xsd:complexType>
				 * <xsd:complexType name="CT_Rst">
				 *	 <xsd:sequence>
				 *		 <xsd:element name="t" type="s:ST_Xstring" minOccurs="0" maxOccurs="1"/>
				 *		 <xsd:element name="r" type="CT_RElt" minOccurs="0" maxOccurs="unbounded"/>
				 *	 </xsd:sequence>
				 * </xsd:complexType>
				 * <xsd:simpleType name="ST_CellRef">
				 *	 <xsd:restriction base="xsd:string"/>
				 * </xsd:simpleType>
				 * <xsd:simpleType name="ST_CellType">
				 *	 <xsd:restriction base="xsd:string">
				 *		 <xsd:enumeration value="b"/>
				 *		 <xsd:enumeration value="d"/>
				 *		 <xsd:enumeration value="n"/>
				 *		 <xsd:enumeration value="e"/>
				 *		 <xsd:enumeration value="s"/>
				 *		 <xsd:enumeration value="str"/>
				 *		 <xsd:enumeration value="inlineStr"/>
				 *	 </xsd:restriction>
				 * </xsd:simpleType>
				 * <xsd:complexType name="CT_Cell">
				 *	 <xsd:sequence>
				 *		 <xsd:element name="f" type="CT_CellFormula" minOccurs="0" maxOccurs="1"/>
				 *		 <xsd:element name="v" type="s:ST_Xstring" minOccurs="0" maxOccurs="1"/>
				 *		 <xsd:element name="is" type="CT_Rst" minOccurs="0" maxOccurs="1"/>
				 *	 </xsd:sequence>
				 *	 <xsd:attribute name="r" type="ST_CellRef" use="optional"/>
				 *	 <xsd:attribute name="s" type="xsd:unsignedInt" use="optional" default="0"/>
				 *	 <xsd:attribute name="t" type="ST_CellType" use="optional" default="n"/>
				 * </xsd:complexType>
				 * <xsd:complexType name="CT_Row">
				 *	 <xsd:sequence>
				 *		 <xsd:element name="c" type="CT_Cell" minOccurs="0" maxOccurs="unbounded"/>
				 *	 </xsd:sequence>
				 *	 <xsd:attribute name="r" type="xsd:unsignedInt" use="optional"/>
				 *	 <xsd:attribute name="spans" type="ST_CellSpans" use="optional"/>
				 *	 <xsd:attribute name="s" type="xsd:unsignedInt" use="optional" default="0"/>
				 * </xsd:complexType>
				 * <xsd:complexType name="CT_SheetData">
				 *	 <xsd:sequence>
				 *		 <xsd:element name="row" type="CT_Row" minOccurs="0" maxOccurs="unbounded"/>
				 *	 </xsd:sequence>
				 * </xsd:complexType>
				 * <xsd:simpleType name="ST_Ref">
				 *	 <xsd:restriction base="xsd:string"/>
				 * </xsd:simpleType>
				 * <xsd:complexType name="CT_MergeCell">
				 *	 <xsd:attribute name="ref" type="ST_Ref" use="required"/>
				 * </xsd:complexType>
				 * <xsd:complexType name="CT_MergeCells">
				 *	 <xsd:sequence>
				 *		 <xsd:element name="mergeCell" type="CT_MergeCell" minOccurs="1" maxOccurs="unbounded"/>
				 *	 </xsd:sequence>
				 *	 <xsd:attribute name="count" type="xsd:unsignedInt" use="optional"/>
				 * </xsd:complexType>
				 * <xsd:complexType name="CT_Worksheet">
				 *	 <xsd:sequence>
				 *		 <xsd:element name="sheetData" type="CT_SheetData" minOccurs="1" maxOccurs="1"/>
				 *		 <xsd:element name="mergeCells" type="CT_MergeCells" minOccurs="0" maxOccurs="1"/>
				 *	 </xsd:sequence>
				 * </xsd:complexType>
				 * <xsd:element name="worksheet" type="CT_Worksheet"/>
				 *
				 * <worksheet>
				 *	 <sheetData>
				 *		 <row r="1">
				 *			 <c r="A1" s="11"><v>2</v></c>
				 *			 <c r="B1" s="11"><v>3</v></c>
				 *			 <c r="C1" s="11"><v>4</v></c>
				 *			 <c r="D1" t="s"><v>0</v></c>
				 *			 <c r="E1" t="inlineStr"><is><t>This is inline string example</t></is></c>
				 *			 <c r="D1" t="d"><v>1976-11-22T08:30</v></c>
				 *			 <c r="G1"><f>SUM(A1:A3)</f><v>9</v></c>
				 *			 <c r="H1" s="11"/>
				 *		 </row>
				 *	 </sheetData>
				 *	 <mergeCells count="5">
				 *		 <mergeCell ref="A1:B2"/>
				 *		 <mergeCell ref="C1:E5"/>
				 *		 <mergeCell ref="A3:B6"/>
				 *		 <mergeCell ref="A7:C7"/>
				 *		 <mergeCell ref="A8:XFD9"/>
				 *	 </mergeCells>
				 * <worksheet>
				 */
				tinyxml2::XMLDocument doc;
				auto xml = Slice(r_cast<char*>(buffer.first.get()), buffer.second).toString();
				auto result = doc.Parse(xml.c_str(), xml.size());
				if (result != tinyxml2::XML_SUCCESS)
				{
					errors[_name] = "workseet open failed";
					return errors;
				}
				unsigned row_index = 0;
				for (auto row = doc.FirstChildElement("worksheet")->FirstChildElement("sheetData")->FirstChildElement("row"); row; row = row->NextSiblingElement("row"))
				{
					std::string r = row->Attribute("r");
					row_index = r == "" ? row_index + 1 : std::stol(r);
					if (row_index > _max_row)
						_max_row = row_index;
					unsigned col_index = 0;

					std::vector<cell> cells;
					for (auto c = row->FirstChildElement("c"); c; c = c->NextSiblingElement("c"))
					{
						reference refer(c->Attribute("r")); // "r" is optional
						if (!refer)
						{
							refer.row = row_index;
							refer.col = ++col_index;
						}
						col_index = refer.col;
						if (col_index > _max_col)
							_max_col = col_index;

						if (refer.row != row_index) // Error in Microsoft Excel
							continue;

						auto fv = c->FirstChildElement("v");
						std::string v = Slice(fv ? fv->GetText() : nullptr).toString(), t = Slice(c->Attribute("t")).toString(), s = Slice(c->Attribute("s")).toString();
						/**
						 * (Ecma Office Open XML Part 1)
						 * 
						 * when the cell's type t is inlineStr then only the element is is allowed as a child element.
						 * 
						 * Cell containing an (inline) rich string, i.e., one not in the shared string table. If this cell type is used, then the cell value is in the is element rather than the v element in the cell (c element).
						 */
						if (t == "inlineStr")
						{
							v = "";
							auto is = c->FirstChildElement("is");
							if (auto isr = is->FirstChildElement("r"))
							{
								for (; isr; isr = isr->NextSiblingElement("r"))
									if (auto rt = isr->FirstChildElement("t"))
										v += rt->GetText();
							}
							else if (auto ist = is->FirstChildElement("t"))
								v = ist->GetText();
						}

						std::string error, value;
						long string_id = -1;
						if (c->FirstChildElement("f"))
							value = v;
						else
						{
							auto val = read_value(v, t, s, error);
							if (std::holds_alternative<long>(val))
								string_id = std::get<long>(val);
							else
								value = std::get<std::string>(val);
						}
						if (error != "")
							errors[refer.value()] = error;
						cells.push_back(cell(refer, value, string_id));
					}

					if (cells.size())
						_rows.push_back(std::move(cells));
				}
			}
			return errors;
		}

		unsigned max_col() const noexcept { return _max_col; }
		unsigned max_row() const noexcept { return _max_row; }
		const std::vector<std::vector<cell>> &rows() const noexcept { return _rows; }
		std::vector<std::vector<cell>>::const_iterator begin() const noexcept { return _rows.begin(); }
		std::vector<std::vector<cell>>::const_iterator end() const noexcept { return _rows.end(); }
		friend class workbook;
	};

	class workbook
	{
	private:
		std::shared_ptr<worksheet::package> _package;
		std::vector<worksheet> _worksheets;

	public:
		workbook(const std::string &path) noexcept : _package(std::make_shared<worksheet::package>()) {
			_package->archive = std::make_unique<ZipFile>(SharedContent.getFullPath(path));
		}
		workbook(std::pair<Dora::OwnArray<uint8_t>,size_t>&& data) noexcept : _package(std::make_shared<worksheet::package>()) {
			_package->archive = std::make_unique<ZipFile>(std::move(data));
		}

		bool read() noexcept
		{
			if (!_package->archive->isOK())
				return false;

			_worksheets.clear();

			std::string workbook_part = "xl/workbook.xml";
			std::string shared_strings_part = "xl/sharedStrings.xml";

			std::map<std::string, std::string> sheets; // Id Target

			tinyxml2::XMLDocument doc;
			auto buffer = _package->archive->getFileData("_rels/.rels");
			if (buffer.first)
			{
				/**
				 * <xsd:complexType name="CT_Relationship">
				 *	 <xsd:simpleContent>
				 *		 <xsd:extension base="xsd:string">
				 *			 <xsd:attribute name="Target" type="xsd:anyURI" use="required"/>
				 *			 <xsd:attribute name="Type" type="xsd:anyURI" use="required"/>
				 *			 <xsd:attribute name="Id" type="xsd:ID" use="required"/>
				 *		 </xsd:extension>
				 *	 </xsd:simpleContent>
				 * </xsd:complexType>
				 * <xsd:complexType name="CT_Relationships">
				 *	 <xsd:sequence>
				 *		 <xsd:element ref="Relationship" minOccurs="0" maxOccurs="unbounded"/>
				 *	 </xsd:sequence>
				 * </xsd:complexType>
				 * <xsd:element name="Relationship" type="CT_Relationship"/>
				 * <xsd:element name="Relationships" type="CT_Relationships"/>
				 *
				 * <Relationships>
				 *	 <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
				 * </Relationships>
				 */
				auto xml = Slice(r_cast<char*>(buffer.first.get()), buffer.second).toString();
				auto result = doc.Parse(xml.c_str());
				if (result != tinyxml2::XML_SUCCESS)
					return false;

				for (auto res = doc.FirstChildElement("Relationships")->FirstChildElement("Relationship"); res; res = res->NextSiblingElement("Relationship"))
				{
					if (auto type = res->Attribute("Type"), target = res->Attribute("Target");
						type && target && !std::strcmp(type, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"))
					{
						workbook_part = target;
						break;
					}
				}
			}
			buffer = _package->archive->getFileData("xl/_rels/workbook.xml.rels");
			if (buffer.first)
			{
				/**
				 * <xsd:complexType name="CT_Relationship">
				 *	 <xsd:simpleContent>
				 *		 <xsd:extension base="xsd:string">
				 *			 <xsd:attribute name="Target" type="xsd:anyURI" use="required"/>
				 *			 <xsd:attribute name="Type" type="xsd:anyURI" use="required"/>
				 *			 <xsd:attribute name="Id" type="xsd:ID" use="required"/>
				 *		 </xsd:extension>
				 *	 </xsd:simpleContent>
				 * </xsd:complexType>
				 * <xsd:complexType name="CT_Relationships">
				 *	 <xsd:sequence>
				 *		 <xsd:element ref="Relationship" minOccurs="0" maxOccurs="unbounded"/>
				 *	 </xsd:sequence>
				 * </xsd:complexType>
				 * <xsd:element name="Relationship" type="CT_Relationship"/>
				 * <xsd:element name="Relationships" type="CT_Relationships"/>
				 * 
				 * <Relationships>
				 *	 <Relationship Id="rId4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>
				 *	 <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
				 *	 <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet2.xml"/>
				 *	 <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
				 * </Relationships>
				 */
				auto xml = Slice(r_cast<char*>(buffer.first.get()), buffer.second).toString();
				auto result = doc.Parse(xml.c_str());
				if (result != tinyxml2::XML_SUCCESS)
					return false;

				shared_strings_part = ""; // styles_part = "";
				for (auto res = doc.FirstChildElement("Relationships")->FirstChildElement("Relationship"); res; res = res->NextSiblingElement("Relationship"))
				{
					if (auto id = res->Attribute("Id"), type = res->Attribute("Type"), target = res->Attribute("Target");
						id && type && target)
					{
						if (!std::strcmp(type, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings"))
							shared_strings_part = std::string("xl/") + target;
						else if (!std::strcmp(type, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"))
							sheets[id] = std::string("xl/") + target;
					}
				}
			}
			if (shared_strings_part.empty())
				buffer = {nullptr, 0};
			else
				buffer = _package->archive->getFileData(shared_strings_part);
			if (buffer.first)
			{
				/**
				 * <xsd:simpleType name="ST_Xstring">
				 *	 <xsd:restriction base="xsd:string"/>
				 * </xsd:simpleType>
				 * <xsd:complexType name="CT_RElt">
				 *	 <xsd:sequence>
				 *		 <xsd:element name="t" type="s:ST_Xstring" minOccurs="1" maxOccurs="1"/>
				 *	 </xsd:sequence>
				 * </xsd:complexType>
				 * <xsd:complexType name="CT_Rst">
				 *	 <xsd:sequence>
				 *		 <xsd:element name="t" type="s:ST_Xstring" minOccurs="0" maxOccurs="1"/>
				 *		 <xsd:element name="r" type="CT_RElt" minOccurs="0" maxOccurs="unbounded"/>
				 *	 </xsd:sequence>
				 * </xsd:complexType>
				 * <xsd:complexType name="CT_Sst">
				 *	 <xsd:sequence>
				 *		 <xsd:element name="si" type="CT_Rst" minOccurs="0" maxOccurs="unbounded"/>
				 *	 </xsd:sequence>
				 *	 <xsd:attribute name="count" type="xsd:unsignedInt" use="optional"/>
				 *	 <xsd:attribute name="uniqueCount" type="xsd:unsignedInt" use="optional"/>
				 * </xsd:complexType>
				 * <xsd:element name="sst" type="CT_Sst"/>
				 *
				 * <sst count="2" uniqueCount="2">
				 *	 <si><t>23  &#10;		&#10;		 as</t></si>
				 *	 <si>
				 *		 <r><t>a</t></r>
				 *		 <r><t>b</t></r>
				 *		 <r><t>c</t></r>
				 *	 </si>
				 *	 <si><t>cd</t></si>
				 * </sst>
				 */
				auto xml = Slice(r_cast<char*>(buffer.first.get()), buffer.second).toString();
				auto result = doc.Parse(xml.c_str());
				if (result != tinyxml2::XML_SUCCESS)
					return false;

				for (auto si = doc.FirstChildElement("sst")->FirstChildElement("si"); si; si = si->NextSiblingElement("si"))
				{
					std::string t;
					if (auto r = si->FirstChildElement("r"))
					{
						for (; r; r = r->NextSiblingElement("r"))
						{
							if (auto tt = r->FirstChildElement("t"))
								t += Slice(tt->GetText()).toString();
						}
						t = Slice(t).trimSpace().toString();
					}
					else if (auto sit = si->FirstChildElement("t"))
					{
						t = Slice(sit->GetText()).trimSpace().toString();
					}
					_package->shared_strings.push_back(t);
				}
			}
			buffer = _package->archive->getFileData(workbook_part);
			if (buffer.first)
			{
				/**
				 * <xsd:simpleType name="ST_Xstring">
				 *	 <xsd:restriction base="xsd:string"/>
				 * </xsd:simpleType>
				 * <xsd:complexType name="CT_Sheet">
				 *	 <xsd:attribute name="name" type="s:ST_Xstring" use="required"/>
				 *	 <xsd:attribute name="sheetId" type="xsd:unsignedInt" use="required"/>
				 *	 <xsd:attribute ref="r:id" use="required"/>
				 * </xsd:complexType>
				 * <xsd:complexType name="CT_Sheets">
				 *	 <xsd:sequence>
				 *		 <xsd:element name="sheet" type="CT_Sheet" minOccurs="1" maxOccurs="unbounded"/>
				 *	 </xsd:sequence>
				 * </xsd:complexType>
				 * <xsd:complexType name="CT_Workbook">
				 *	 <xsd:sequence>
				 *		 <xsd:element name="sheets" type="CT_Sheets" minOccurs="1" maxOccurs="1"/>
				 *	 </xsd:sequence>
				 * </xsd:complexType>
				 * <xsd:element name="workbook" type="CT_Workbook"/>
				 * 
				 * <workbook>
				 *	 <sheets>
				 *		 <sheet name="Sheet1" sheetId="1" r:id="rId1"/>
				 *		 <sheet name="Sheet2" sheetId="2" r:id="rId2"/>
				 *	 </sheets>
				 * </workbook>
				 */
				auto xml = Slice(r_cast<char*>(buffer.first.get()), buffer.second).toString();
				auto result = doc.Parse(xml.c_str());
				if (result != tinyxml2::XML_SUCCESS)
					return false;

				for (auto sheet = doc.FirstChildElement("workbook")->FirstChildElement("sheets")->FirstChildElement("sheet"); sheet; sheet = sheet->NextSiblingElement("sheet"))
				{
					if (auto name = sheet->Attribute("name"), rid = sheet->Attribute("r:id"); name && rid && sheets.find(rid) != sheets.end())
					{
						const auto &part = sheets[rid];
						if (_package->archive->fileExists(part))
							_worksheets.push_back(worksheet::create(name, part, _package));
					}
				}
			}

			return true;
		}

		const std::vector<std::string> &shared_strings() const noexcept { return _package->shared_strings; }
		const std::vector<worksheet> &worksheets() const noexcept { return _worksheets; }
		std::vector<worksheet>::const_iterator begin() const noexcept { return _worksheets.begin(); }
		std::vector<worksheet>::const_iterator end() const noexcept { return _worksheets.end(); }
		std::vector<worksheet>::iterator begin() noexcept { return _worksheets.begin(); }
		std::vector<worksheet>::iterator end() noexcept { return _worksheets.end(); }
	};
} // namespace xlsxtext
