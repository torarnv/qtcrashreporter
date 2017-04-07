TEMPLATE = aux

include(KSCrash.pri)

system(cd $$PWD && git submodule update --init $$SRCDIR)

qtConfig(debug_and_release): CONFIG += debug_and_release
qtConfig(build_all): CONFIG += build_all

CONFIG(debug, debug|release): configuration = Debug
else: configuration = Release

kscrash_log_level = INFO

kscrash.target = $$BUILD_DIR/lib$${KSCRASH_TARGET}.a
kscrash.commands = rm -f $${kscrash.target} && xcodebuild -quiet \
	-workspace $$SRCDIR/Mac.xcworkspace \
	-scheme KSCrashLib build \
	SYMROOT=$$BUILD_DIR \
	CONFIGURATION_BUILD_DIR=$$BUILD_DIR \
	CONFIGURATION=$$configuration \
	TARGET_NAME=$$KSCRASH_TARGET \
	GCC_PREPROCESSOR_DEFINITIONS='KSLogger_Level=$$kscrash_log_level'
kscrash_clean.commands = rm -Rf $$BUILD_DIR

# FIXME: Depend only on source files
kscrash.depends = $$files($$SRCDIR/*, true)

QMAKE_EXTRA_TARGETS += kscrash kscrash_clean
PRE_TARGETDEPS += $${kscrash.target}
CLEAN_DEPS += kscrash_clean