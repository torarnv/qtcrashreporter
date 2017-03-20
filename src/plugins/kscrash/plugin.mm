#import <AppKit/AppKit.h>

#import <KSCrash/KSCrash.h>
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
    	KSCrashInstallationConsole *instance = [KSCrashInstallationConsole sharedInstance];
    	instance.printAppleFormat = YES;
    	[instance install];
    }
};

#include "plugin.moc"