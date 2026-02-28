QT = core xml
CONFIG += c++17
TARGET = qrestbuilder
TEMPLATE = app

HEADERS += \
    restbuilder.h \
    objectbuilder.h \
    classbuilder.h \
    xmlconverter.h \
    ../../src/3rdparty/optional-lite/optional.hpp \
    ../../src/3rdparty/variant-lite/variant.hpp

SOURCES += \
    main.cpp \
    restbuilder.cpp \
    objectbuilder.cpp \
    classbuilder.cpp \
    xmlconverter.cpp

INCLUDEPATH +=  \
    ../../src/3rdparty/optional-lite \
    ../../src/3rdparty/variant-lite

DEFINES += BUILD_QRESTBUILDER
DEFINES += "TARGET=\\\"$$TARGET\\\""
DEFINES += "VERSION=\\\"2.0.0\\\""
DEFINES += "COMPANY=\\\"Skycoder42\\\""
DEFINES += "BUNDLE_PREFIX=\\\"de.skycoder42\\\""
