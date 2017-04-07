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

#include "qcrashhandler_p.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <libproc.h>
#include <unistd.h>

#include <QDebug>

static const char *kQCrashReporterReportCrash = "QCRASHREPORTER_REPORT_CRASH";

QCrashHandler::QCrashHandler()
{
}

void QCrashHandler::initialize()
{
	if (getenv(kQCrashReporterReportCrash)) {
        report();
        exit(0);
    } else {
    	install();
    	report();
    }	
}

void QCrashHandler::relaunchAsCrashReporter()
{
	printf("Crashed!\n");
    pid_t pid = fork();
    if (pid == 0) {
        // Child
        char executablePath[PROC_PIDPATHINFO_MAXSIZE];
        if (proc_pidpath(getpid(), executablePath, sizeof(executablePath)) <= 0) {
            // Failed to get path
            exit(127); //FIXME 
        }

        static char *argv [] = { "qcrashreporter", nullptr };
        setenv(kQCrashReporterReportCrash, "1", 1);
        extern char** environ;
        execve(executablePath, argv, environ);
        exit(127);
    } else {
        waitpid(pid, 0, 0);
    }

    printf("done\n");
}
