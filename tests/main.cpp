#include <QtCore>
#include <QtWidgets>

#include <qsentrycrashreporter.h>

#include <stdexcept>

/*

	- Linking to QtCrashReporter will automatically install
	  the best available crash handler at library load

	- Unless the application installs and configures any
	  crash reporters, the default console reporter will
	  be used

	- On crash, the application is respawned and expected
	  to pick up the crash report and report it, before
	  exiting

	- If fork/exec is not allowed, this might happen on
	  next application start, where the application should
	  report, but continue on like normal.
*/

int main(int argc, char **argv)
{
#if 0
	QSentryCrashReporter sentry;
	sentry.setHost("localhost");
	sentry.setId("askjdhasdasd");
	sentry.setLogToConsole(true);
	sentry.setDeferDelivery(true);
	sentry.setDeliverOnInstall(false);
	QObject::connect(&sentry, &QCrashReporter::deliverReport, [](QCrashReporter::Report *report) {
		QDialog::exec(); // Ask for more info
	});
	sentry.install();

	sentry.deliverReports();
#endif 

	QSentryCrashReporter sentry("https://pub:priv@sentry.io/107125");
	/*QObject::connect(&sentry, &QSentryCrashReporter::reportSent, []() {
		qDebug() << "report sent";
	});*/
	sentry.install();

	QApplication app(argc, argv);

	QWidget window;
	window.resize(500, 500);
	QPushButton button("Crash", &window);
    QObject::connect(&button, &QPushButton::clicked, []() {
		qDebug() << "crashing...";
		int *ptr = 0; *ptr = 42;
	});
	
#if 0
	QMessageBox crashInformation(QMessageBox::Warning, "Crashed",
	 "The application crashed", QMessageBox::Ok);
	crashInformation.setInformativeText( "Unless the application installs and configures any" \
	  "crash reporters, the default console reporter will" \
	  "be used");
	crashInformation.exec();
#endif
	window.show();

	qDebug() << "application started";
	return app.exec();
	//int *ptr = 0; *ptr = 42;

	/*
	QCoreApplication app(argc, argv);
	QTimer::singleShot(0, []() {
		//QCrashReporter::foo();
		
		//throw std::invalid_argument( "received negative value" );
		int *ptr = 0; *ptr = 42;
	});
	*/
}
