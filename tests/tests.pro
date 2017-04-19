QT += widgets crashreporter

#CONFIG -= app_bundle
SOURCES += main.cpp
CONFIG += exceptions

CONFIG += debug
CONFIG -= release

#QMAKE_INFO_PLIST = $$PWD/Info.plist

# FIXME: qmake should do this
#QMAKE_LFLAGS += -Wl,-sectcreate,__TEXT,__info_plist,$$shell_quote($$QMAKE_INFO_PLIST)