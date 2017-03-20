TEMPLATE = subdirs
SUBDIRS += KSCrash.pro #CrashProbe.pro
CONFIG += ordered

system(git submodule update --init)