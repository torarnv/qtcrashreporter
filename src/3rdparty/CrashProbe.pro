TEMPLATE = aux

DESTDIR = $$OUT_PWD/CrashProbe

crashprobe.commands = xcodebuild -project $$PWD/CrashProbe/CrashProbe.xcodeproj -target CrashLib build SYMROOT=$$DESTDIR CONFIGURATION_BUILD_DIR=$$DESTDIR INSTALL_PATH=@executable_path/../src/3rdparty/CrashProbe

crashprobe.CONFIG += phony
QMAKE_EXTRA_TARGETS += crashprobe

PRE_TARGETDEPS += crashprobe