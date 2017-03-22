#include <QDebug>
#include <qcrashreporter.h>

class QSentryReporter : public QObject, public QCrashReporter
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QCrashReporterInterface_iid FILE "plugin.json")
    Q_INTERFACES(QCrashReporter)

public:
    void report()
    {
    	qDebug() << "yeah";
    }
};

#include "plugin.moc"