TARGET = qbreakpadplugin

PLUGIN_TYPE = crash
PLUGIN_EXTENDS = crashreporter
PLUGIN_CLASS_NAME = QBreakpadPlugin
load(qt_plugin)

QT += crashreporter

#SOURCES += plugin.mm

CONFIG(debug, debug|release): configuration = Debug
else: configuration = Release

BREAKPAD_SRC = $$PWD/../../3rdparty/breakpad
BREAKPAD_TARGET = $$qtLibraryTarget(breakpad)
breakpad.commands = xcodebuild -hideShellScriptEnvironment \
	-project $$BREAKPAD_SRC/src/client/mac/Breakpad.xcodeproj \
	-scheme Breakpad build \
	SYMROOT=$$OUT_PWD \
	CONFIGURATION_BUILD_DIR=$$OUT_PWD \
	CONFIGURATION=$$configuration \
	SDKROOT=macosx
#	TARGET_NAME=$$BREAKPAD_TARGET
breakpad.depends = FORCE
#breakpad.target = lib$${BREAKPAD_TARGET}.a

QMAKE_EXTRA_TARGETS += breakpad
PRE_TARGETDEPS += breakpad #$${breakpad.target}

#LIBS += -L$$OUT_PWD -l$$KSCRASH_TARGET
#INCLUDEPATH += $$OUT_PWD/include $$OUT_PWD/usr/local/include

#LIBS += -lc++ -lz -framework CoreFoundation -framework Foundation \
#	-framework AppKit -framework SystemConfiguration -ObjC
