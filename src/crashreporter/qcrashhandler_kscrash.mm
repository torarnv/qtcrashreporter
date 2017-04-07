#import <AppKit/AppKit.h>

#import <KSCrash/KSCrash.h>
#import <KSCrash/KSCrashInstallationConsole.h>
#import <KSLogger.h>

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

#include "qcrashhandler_kscrash_p.h"

#import <KSCrash/KSCrash.h>
#import <KSCrash/KSCrashInstallationConsole.h>
#import <KSLogger.h>

#include <KSCrash/KSCrashC.h>

#include <QDebug>

/*
    FIXME: Name of crash dump directory is based off CFBundleName, should fix Qt
    to support Info.plist for non-bundle apps, and/or teach KSCrash how to fall
    back to using CFBundleIdentifier or last resort the executable name.
*/

static void writeUserDataCallback(const KSCrashReportWriter* writer)
{
}

QKSCrashHandler::QKSCrashHandler() : QCrashHandler()
{
    qDebug() << "QKSCrashHandler";
}

QKSCrashHandler::~QKSCrashHandler()
{
}

void QKSCrashHandler::install()
{
    qDebug() << "installing";
    KSCrashInstallationConsole *installation = [KSCrashInstallationConsole sharedInstance];
    [installation install];

    installation.onCrash = writeUserDataCallback;

    kscrash_setReportWrittenCallback(relaunchAsCrashReporter);
}

void QKSCrashHandler::report()
{
    install();

    qDebug() << "reporting crash";
    
    KSCrashInstallationConsole *installation = [KSCrashInstallationConsole sharedInstance];
    installation.printAppleFormat = YES;

    [installation sendAllReportsWithCompletion:^(NSArray* reports, BOOL completed, NSError* error) {
        if (!completed)
            NSLog(@"Failed to send reports: %@", error);
    }];

    qDebug() << "done repoting crash";
}

