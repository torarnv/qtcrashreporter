#include <qglobal.h>

// LIBS +=  -F/Users/torarne/dev/qt/research/qtsentry/3rdparty -framework SentrySwift -framework Foundation

#include <SentrySwift/SentrySwift.h>
#include <SentrySwift/SentrySwift-Swift.h>

static QtMessageHandler previousHandler = nullptr;

void myMessageOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    QByteArray localMsg = msg.toLocal8Bit();
    switch (type) {
    case QtDebugMsg:
        fprintf(stderr, "Debug: %s (%s:%u, %s)\n", localMsg.constData(), context.file, context.line, context.function);
        break;
    case QtInfoMsg:
        fprintf(stderr, "Info: %s (%s:%u, %s)\n", localMsg.constData(), context.file, context.line, context.function);
        break;
    case QtWarningMsg:
        fprintf(stderr, "Warning: %s (%s:%u, %s)\n", localMsg.constData(), context.file, context.line, context.function);
        break;
    case QtCriticalMsg:
        fprintf(stderr, "Critical: %s (%s:%u, %s)\n", localMsg.constData(), context.file, context.line, context.function);
        break;
    case QtFatalMsg:
        fprintf(stderr, "Fatal: %s (%s:%u, %s)\n", localMsg.constData(), context.file, context.line, context.function);
        abort();
    }

    [[SentryClient shared] captureMessage:@"Some plain message from ObjC" level:SentrySeverityInfo];

    NSError *error = [[NSError alloc] initWithDomain:@"test.domain" code:-1 userInfo:nil];
    
    Event *event = [[Event alloc] init:error.domain
                             timestamp:[NSDate date]
                                 level:SentrySeverityError
                                logger:nil
                               culprit:nil
                            serverName:nil
                               release:nil
                                  tags:nil
                               modules:nil
                                 extra:nil
                           fingerprint:nil
                                  user:nil
                             exceptions:nil
                            stacktrace:nil
                      appleCrashReport:nil];
    
    [[SentryClient shared] captureEvent:event];


    if (previousHandler)
        previousHandler(type, context, msg);
}

static void initializeLogging()
{
    previousHandler = qInstallMessageHandler(myMessageOutput);

    [SentryClient setLogLevel:SentryLogDebug];
    [SentryClient setShared:[[SentryClient alloc] initWithDsnString:@"http://85ea243e4624424c961a189e6d151733:31e23af2f80042c2acd70938f23b54fc@localhost:8000/2"]];
    [[SentryClient shared] startCrashHandler];
    [SentryClient shared].user = [[User alloc] initWithId:@"3" email:@"example@example.com" username:@"Example" extra:@{@"is_admin": @NO}];

    // A map or list of tags for this event.
    [SentryClient shared].tags = @{@"environment": @"production"};
    
    // An arbitrary mapping of additional metadata to store with the event
    [SentryClient shared].extra = @{
                                    @"a_thing": @3,
                                    @"some_things": @[@"green", @"red"],
                                    @"foobar": @{@"foo": @"bar"}
                                    };
    
    // Step 5: Add breadcrumbs to help you debug errors
    Breadcrumb *bcStart = [[Breadcrumb alloc] initWithCategory:@"test" timestamp:[NSDate new] message:nil type:nil level:SentrySeverityDebug data:@{@"navigation": @"app start"}];
    Breadcrumb *bcMain = [[Breadcrumb alloc] initWithCategory:@"test" timestamp:[NSDate new] message:nil type:nil level:SentrySeverityDebug data:@{@"navigation": @"main screen"}];
    [[SentryClient shared].breadcrumbs add:bcStart];
    [[SentryClient shared].breadcrumbs add:bcMain];
    
}

Q_CONSTRUCTOR_FUNCTION(initializeLogging);