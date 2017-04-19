/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the QtWidgets module of the Qt Toolkit.
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

#include "qsentrycrashreporter.h"

#include <QtNetwork>

QSentryCrashReporter::QSentryCrashReporter(const QString &dsnKey)
	: QCrashReporter()
    , m_networkAccessManager(new QNetworkAccessManager(this))
{
    // FIXME: Read SENTRY_DSN env variable

    QUrl url = QUrl::fromUserInput(dsnKey);
    // FIXME: Error handling

    m_publicKey = url.userName();
    m_secretKey = url.password();
    m_projectId = url.path().mid(1);
    
    m_apiUrl = url.adjusted(QUrl::RemoveUserInfo);
    m_apiUrl.setPath(QString(QLatin1String("/api/%1/store/")).arg(m_projectId));

    /*QSslConfiguration defaultSSLConfig = QSslConfiguration::defaultConfiguration();
    QList<QSslCertificate> certificates = defaultSSLConfig.caCertificates();
    QFile cert;
    cert.setFileName("/Users/torarne/.mitmproxy/mitmproxy-ca-cert.pem");
    if (cert.open(QIODevice::ReadOnly)) {
        QSslCertificate certificate(&cert, QSsl::Pem);
        certificates.append(certificate);
        qDebug() << "added custom cert";
    }
    defaultSSLConfig.setCaCertificates(certificates);
    QSslConfiguration::setDefaultConfiguration(defaultSSLConfig);
    */

#if 0
    QSslSocket::addDefaultCaCertificates(QLatin1String("/Users/torarne/.mitmproxy/mitmproxy-ca-cert.pem"));


    QNetworkProxy proxy;
 proxy.setType(QNetworkProxy::HttpProxy);
 proxy.setHostName(QLatin1String("localhost"));
 proxy.setPort(8080);
 QNetworkProxy::setApplicationProxy(proxy);
#endif

    // FIXME!!!!
#ifdef Q_OS_MACOS
    // Silence 'Error receiving trust for a CA certificate' warning
    QLoggingCategory::setFilterRules(QStringLiteral("qt.network.ssl.warning=false"));
#endif

#if 0
    QObject::connect(m_networkAccessManager, &QNetworkAccessManager::finished, [](QNetworkReply *reply) {
        qDebug() << reply->error() << reply->readAll();
    });
#endif
}

QSentryCrashReporter::~QSentryCrashReporter()
{
    delete m_networkAccessManager;
}

bool QSentryCrashReporter::report(const QCrashReport &report)
{
	qDebug() << "sentry"  << __FUNCTION__ << report.uuid();
    return true;
    
    QScopedPointer<QCoreApplication> app;
    if (!QCoreApplication::instance()) {
        qDebug() << "no app";
        static int argc = 1;
        static const char *argv[] = { "qcrashreporter", nullptr };
        app.reset(new QCoreApplication(argc, (char**)argv));
    }

    static QString authenticationHeader(QStringLiteral(
        "Sentry sentry_version=7," \
        "sentry_client=qtcrashreporter/0.1," \
        "sentry_timestamp=%1," \
        "sentry_key=%2," \
        "sentry_secret=%3"));

    QNetworkRequest request(m_apiUrl);

    {
        qint64 timestamp = QDateTime::currentMSecsSinceEpoch() / 1000;
        request.setRawHeader("X-Sentry-Auth", authenticationHeader
            .arg(timestamp).arg(m_publicKey).arg(m_secretKey).toLatin1());
    }

    request.setRawHeader("User-Agent", "qtcrashreporter/0.1");
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));

    QString uuid = QUuid::createUuid().toString();//report.uuid().toString();
    uuid.remove(0, 1);
    uuid.chop(1);
    uuid.remove('-');

    QString timestamp = report.occured().toString(Qt::ISODate);

    QJsonObject data;
    data.insert(QStringLiteral("event_id"), uuid);
    data.insert(QStringLiteral("timestamp"), timestamp);
    data.insert(QStringLiteral("logger"), QStringLiteral("my.logger.name"));
    data.insert(QStringLiteral("platform"), QStringLiteral("other"));

    QByteArray jsonData = QJsonDocument(data).toJson();
    qDebug() << jsonData.constData();
    QNetworkReply *reply = m_networkAccessManager->post(request, jsonData);

    QEventLoop eventLoop;
    QObject::connect(reply, &QNetworkReply::finished, &eventLoop, &QEventLoop::quit);
    // FIXME: Timeout (3s?), failover to console logging
    eventLoop.exec();

    QVariant httpStatus = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
    if (!httpStatus.isValid())
        qFatal("Failed to get HTTP status from Sentry request");

    if (httpStatus.toInt() != 200) {
        QByteArray sentryError = reply->rawHeader("X-Sentry-Error");
        if (sentryError.isEmpty())
            qFatal("Failed to get Sentry error for non-200 HTTP response");

        qDebug() << sentryError;
        return false;
    }

    qDebug() << reply->readAll();


#if 0
    QObject::connect(reply, &QNetworkReply::finished, [reply, report]() {
        qDebug() << reply << report.uuid();
        qDebug() << reply->error() << reply->readAll();
    });
#endif

	return true;
}
