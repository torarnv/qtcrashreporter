    #include <QtCore>
#include <qcrashreporter.h>

#include <stdexcept>

#if 0
typedef void (*cxa_throw_type)(void*, std::type_info*, void (*)(void*));

extern "C"
{
    void __cxa_throw(void* thrown_exception, std::type_info* tinfo, void (*dest)(void*)) __attribute__ ((weak));

    void __cxa_throw(void* thrown_exception, std::type_info* tinfo, void (*dest)(void*))
    {
        printf("heisan\n");
    }
}
#endif

int main(int argc, char **argv)
{
/*	QCrashHandler crashHandler;
	crashHandler.addReporter(QConsoleCrashReporter);
	crashHandler.addReporter(QSentryCrashReporter);
*/
	QCrashReporter::install();

	QCoreApplication app(argc, argv);
	QTimer::singleShot(0, []() {
		QCrashReporter::foo();
		
		//throw std::invalid_argument( "received negative value" );
		//int *ptr = 0; *ptr = 42;
	});
	return app.exec();
}
