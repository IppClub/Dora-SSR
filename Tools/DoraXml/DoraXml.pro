#-------------------------------------------------
#
# Project created by QtCreator 2015-04-15T10:34:14
#
#-------------------------------------------------
QT += core gui
CONFIG += c++11
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets
greaterThan(QT_MAJOR_VERSION, 5): QT += core5compat

TARGET = DoraXml
TEMPLATE = app

SOURCES += main.cpp\
    oSyntaxHighlighter.cpp \
    oEditor.cpp \
    oNumberBar.cpp \
    oTextEdit.cpp \
    oXmlResolver.cpp \
    oDorothyTag.cpp \
    oMainWindow.cpp

HEADERS  += \
    oEditor.h \
    oSyntaxHighlighter.h \
    oNumberBar.h \
    oTextEdit.h \
    Yard/yard.hpp \
    Yard/yard_base_grammar.hpp \
    Yard/yard_c_grammar.hpp \
    Yard/yard_char_set.hpp \
    Yard/yard_error.hpp \
    Yard/yard_heron_grammar.hpp \
    Yard/yard_io.hpp \
    Yard/yard_parser.hpp \
    Yard/yard_scheme_grammar.hpp \
    Yard/yard_tester.hpp \
    Yard/yard_text_grammar.hpp \
    Yard/yard_tree.hpp \
    Yard/yard_util.hpp \
    Yard/yard_xml_grammar.hpp \
    oXmlResolver.h \
    oDorothyTag.h \
    oDefine.h \
    oMainWindow.h

RESOURCES += \
    resourses.qrc

DISTFILES +=

FORMS += \
    oMainWindow.ui
