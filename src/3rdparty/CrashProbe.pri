crashprobe.path = $$shadowed($$PWD)/CrashProbe
QMAKE_CXXFLAGS += -F$${crashprobe.path}
LIBS += -F$${crashprobe.path} -framework CrashLib
PRE_TARGETDEPS += $${crashprobe.path}/CrashLib.framework