#import <AppKit/AppKit.h>

#import <KSCrash/KSCrash.h>
#import <KSCrash/KSCrashInstallationConsole.h>
#import <KSLogger.h>

#include <QDebug>
#include <qcrashhandler.h>
#include <qcrashreporter.h>

#include <stdexcept>

class QKSCrashHandler : public QObject, public QCrashHandler
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QCrashHandlerInterface_iid FILE "plugin.json")
    Q_INTERFACES(QCrashHandler)

public:
    void install()
    {
    	// FIXME: redirect KSCrash logging to file or /dev/null
    	// kslog_setLogFilename("/tmp/kscrash.log", false);
    	qDebug() << "installing";

    	KSCrashInstallationConsole *installation = [KSCrashInstallationConsole sharedInstance];
    	[installation install];

    	installation.printAppleFormat = YES;
    	[installation sendAllReportsWithCompletion:^(NSArray* reports, BOOL completed, NSError* error) {
			if (!completed)
		     	NSLog(@"Failed to send reports: %@", error);
		}];
    }

    void except()
    {
    	throw std::invalid_argument( "received negative value" );
    }
};

#if 0

class QKSCrashReporter : public QObject, public QCrashReporter
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QCrashReporterInterface_iid FILE "plugin.json")
    Q_INTERFACES(QCrashReporter)

public:
    void report()
    {
    	qDebug() << "sweeet";
    }
};
#endif

#include "plugin.moc"