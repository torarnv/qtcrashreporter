TEMPLATE = aux

SRCDIR = $$PWD/KSCrash
DESTDIR = $$shadowed($$SRCDIR)

submodule.commands = cd $$PWD && git submodule update --init $$SRCDIR
submodule.depends = FORCE
QMAKE_EXTRA_TARGETS += submodule

CONFIG(debug, debug|release): configuration = Debug
else: configuration = Release

kscrash_log_level = INFO

KSCRASH_TARGET = $$qtLibraryTarget(KSCrashLib)
kscrash.commands = xcodebuild -quiet \
	-workspace $$SRCDIR/Mac.xcworkspace \
	-scheme KSCrashLib build \
	SYMROOT=$$DESTDIR \
	CONFIGURATION_BUILD_DIR=$$DESTDIR \
	CONFIGURATION=$$configuration \
	TARGET_NAME=$$KSCRASH_TARGET \
	GCC_PREPROCESSOR_DEFINITIONS='KSLogger_Level=$$kscrash_log_level'
kscrash.depends = submodule FORCE
kscrash.target = lib$${KSCRASH_TARGET}.a

QMAKE_EXTRA_TARGETS += kscrash
PRE_TARGETDEPS += $${kscrash.target}