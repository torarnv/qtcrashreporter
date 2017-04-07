
SRCDIR = $$PWD/KSCrash
BUILD_DIR = $$shadowed($$SRCDIR)
KSCRASH_TARGET = KSCrashLib$$qtPlatformTargetSuffix()

LIBS_PRIVATE += -L$$BUILD_DIR -l$$KSCRASH_TARGET
INCLUDEPATH += $$BUILD_DIR/include $$BUILD_DIR/usr/local/include

LIBS += -lc++ -lz -framework CoreFoundation -framework Foundation \
	-framework AppKit -framework SystemConfiguration -ObjC