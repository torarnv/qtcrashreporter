TARGET = qsentryplugin

PLUGIN_TYPE = crash
PLUGIN_EXTENDS = crashreporter
PLUGIN_CLASS_NAME = QSentryPlugin
load(qt_plugin)

QT += crashreporter

SOURCES += plugin.cpp
