/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the QtCrashReporter module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or (at your option) the GNU General
** Public license version 3 or any later version approved by the KDE Free
** Qt Foundation. The licenses are as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-2.0.html and
** https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "qcrashhandler_kscrash_p.h"

#include "qcrashreporter.h"

#import <KSCrash/KSCrash.h>
#import <KSCrash/KSCrashInstallationConsole.h>
#import <KSLogger.h>

#include <KSCrash/KSCrashC.h>

#include <QDebug>

Q_LOGGING_CATEGORY(lcKSCrash, "qt.crashreporter.kscrash");
Q_LOGGING_CATEGORY(lcKSCrashInternal, "qt.crashreporter.kscrash.internal");

/*
    FIXME: Name of crash dump directory is based off CFBundleName, should fix Qt
    to support Info.plist for non-bundle apps, and/or teach KSCrash how to fall
    back to using CFBundleIdentifier or last resort the executable name.
*/

#if 0
static void writeUserDataCallback(const KSCrashReportWriter* writer)
{
}
#endif

static void kscrashRedirectedLogging(const char* const level,
                        const char* const file,
                        const int line,
                        const char* const function,
                        const char* const fmt, va_list args)
{
    QtMsgType messageType = QtDebugMsg;
    if (level) {
        switch (level[0]) {
        case 'E':
            messageType = QtCriticalMsg;
            break;
        case 'W':
            messageType = QtWarningMsg;
            break;
        case 'F':
            messageType = QtFatalMsg;
            break;
        case 'I':
            messageType = QtInfoMsg;
            break;
        case 'D':
        case 'T':
            messageType = QtDebugMsg;
            break;
        }
    }
    const QLoggingCategory &kscrash = lcKSCrashInternal();
    if (!kscrash.isEnabled(messageType))
        return;

    QMessageLogContext context(file, line, function, kscrash.categoryName());
    qt_message_output(messageType, context, QString::vasprintf(fmt, args));
}

QKSCrashHandler::QKSCrashHandler()
    : QCrashHandler()
{
    qCDebug(lcKSCrash) << "constructing";
  //  kslog_setLogToStdout(false);
    kslog_setLogFilename("/tmp/kslog.log", true);
    //kslog_setOutputFunction(kscrashRedirectedLogging);
}

QKSCrashHandler::~QKSCrashHandler()
{
}

void QKSCrashHandler::install()
{
    lcKSCrashInternal();
    qCDebug(lcKSCrash) << "installing";
    KSCrashInstallationConsole *installation = [KSCrashInstallationConsole sharedInstance];
    [installation install];
    kslog_setLogFilename("/tmp/kslog.log", false);

    //installation.onCrash = writeUserDataCallback;

    kscrash_setReportWrittenCallback(QCrashHandler::relaunchAndReport);
}

class QKSCrashReport : public QCrashReport
{
public:
    QKSCrashReport(const QJsonObject &data)
        : m_json(data)
    {
    }

    const QJsonObject data() const override {
        return m_json;
    }

    QUuid uuid() const override {
        QJsonObject details = m_json["report"].toObject();
        return QUuid(details["id"].toString());
    }

    QDateTime occured() const override {
        QJsonObject details = m_json["report"].toObject();
        return QDateTime::fromString(details["timestamp"].toString(), Qt::ISODate);
    }

private:
    QJsonObject m_json;
};

void QKSCrashHandler::report(QCrashReporter *reporter)
{
    qCDebug(lcKSCrash) << "reporting crash with reporter:" << reporter;
 
    bool failedReporing = false;

    int reportCount = kscrash_getReportCount();
    int64_t reportIDs[reportCount];
    reportCount = kscrash_getReportIDs(reportIDs, reportCount);
    for (int i = 0; i < reportCount; ++i) {
        const char *report = kscrash_readReport(reportIDs[i]);
        if (!report) {
            qCWarning(lcKSCrash) << "Failed to read report with ID" << reportIDs[i];
            continue;
        }

        QByteArray reportData = QByteArray::fromRawData(report, strlen(report));

        qCDebug(lcKSCrash) << "parsing as JSON";
        QJsonParseError parseError;
        QJsonDocument json = QJsonDocument::fromJson(reportData, &parseError);
        if (json.isNull()) {
            qCWarning(lcKSCrash) << "failed to parse JSON:" << parseError.errorString();
            continue;
        }
        
        // FIXME: Doctor report

        //qDebug() << json.toJson().constData();

        qCDebug(lcKSCrash) << "sending crash report";

        QKSCrashReport crashReport(json.object());
        if (!reporter->report(crashReport))
            failedReporing = true;
    }

    qCDebug(lcKSCrash) << "done sending all reports, failed:" << failedReporing;

    // FIXME: Delete individual reports?
    if (!failedReporing)
        ;//kscrash_deleteAllReports();
}

