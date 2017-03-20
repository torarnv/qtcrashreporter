#import <AppKit/AppKit.h>

#import <KSCrash/KSCrash.h>
#import <KSCrash/KSCrashAdvanced.h>
#import <KSCrash/KSCrashInstallationConsole.h>

#include <QDebug>
#include <qcrashhandler.h>

class QKSCrashHandler : public QObject, public QCrashHandler
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QCrashHandlerInterface_iid FILE "plugin.json")
    Q_INTERFACES(QCrashHandler)

public:
    void install()
    {
    	[[KSCrashInstallationConsole sharedInstance] install];
    	[KSCrash sharedInstance].printTraceToStdout = YES;
    }
};

#include "plugin.moc"