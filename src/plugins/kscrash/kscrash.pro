TARGET = qkscrashplugin

PLUGIN_TYPE = crash
PLUGIN_EXTENDS = crashreporter
PLUGIN_CLASS_NAME = QKSCrashPlugin
load(qt_plugin)

QT += crashreporter
CONFIG += exceptions

SOURCES += plugin.mm

CONFIG(debug, debug|release): configuration = Debug
else: configuration = Release

kscrash_log_level = INFO

KSCRASH_SRC = $$PWD/../../3rdparty/KSCrash
KSCRASH_TARGET = $$qtLibraryTarget(KSCrashLib)
kscrash.commands = xcodebuild -quiet \
	-workspace $$KSCRASH_SRC/Mac.xcworkspace \
	-scheme KSCrashLib build \
	SYMROOT=$$OUT_PWD \
	CONFIGURATION_BUILD_DIR=$$OUT_PWD \
	CONFIGURATION=$$configuration \
	TARGET_NAME=$$KSCRASH_TARGET \
	GCC_PREPROCESSOR_DEFINITIONS='KSLogger_Level=$$kscrash_log_level'
kscrash.depends = FORCE
kscrash.target = lib$${KSCRASH_TARGET}.a

QMAKE_EXTRA_TARGETS += kscrash
PRE_TARGETDEPS += $${kscrash.target}

LIBS += -L$$OUT_PWD -l$$KSCRASH_TARGET
INCLUDEPATH += $$OUT_PWD/include $$OUT_PWD/usr/local/include

LIBS += -lc++ -lz -framework CoreFoundation -framework Foundation \
	-framework AppKit -framework SystemConfiguration -ObjC
