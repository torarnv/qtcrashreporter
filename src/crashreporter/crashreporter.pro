TARGET = QtCrashReporter

SOURCES += qcrashhandler.cpp qcrashreporter.cpp
HEADERS += qcrashhandler_p.h qcrashreporter.h

# qcrashhandler.h

QT += core-private

load(qt_module)

#CONFIG += exceptions
CONFIG -= create_cmake

qtConfig(kscrash) {
	SOURCES += qcrashhandler_kscrash.mm
	HEADERS += qcrashhandler_kscrash_p.h
	include(../3rdparty/KSCrash.pri)
}
