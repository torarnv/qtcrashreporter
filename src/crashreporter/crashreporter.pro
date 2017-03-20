TARGET = QtCrashReporter

SOURCES += qcrashreporter.cpp
HEADERS += qcrashreporter.h qcrashhandler.h

QT += core-private

load(qt_module)

CONFIG -= create_cmake