TARGET = qkscrashplugin

PLUGIN_TYPE = crash
PLUGIN_EXTENDS = crashreporter
PLUGIN_CLASS_NAME = QKSCrashPlugin
load(qt_plugin)

QT += crashreporter

SOURCES += plugin.mm

KSCRASH_SRC = $$PWD/../../3rdparty/KSCrash
KSCRASH_TARGET = $$qtLibraryTarget(KSCrashLib)
kscrash.commands = xcodebuild -quiet \
	-workspace $$KSCRASH_SRC/Mac.xcworkspace \
	-scheme KSCrashLib build \
	SYMROOT=$$OUT_PWD \
	CONFIGURATION_BUILD_DIR=$$OUT_PWD \
	TARGET_NAME=$$KSCRASH_TARGET

QMAKE_EXTRA_TARGETS += kscrash
PRE_TARGETDEPS += kscrash #lib$${KSCRASH_TARGET}.a # FIXME: Prevent relink each time

LIBS += -L$$OUT_PWD -l$$KSCRASH_TARGET
INCLUDEPATH += $$OUT_PWD/include

LIBS += -lc++ -lz -framework CoreFoundation -framework Foundation -framework AppKit -framework SystemConfiguration -ObjC
