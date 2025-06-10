#!/usr/bin/env bash
############################################################################
# duf.sh
#   Copyright 2020-2025 OneCD
#
# Contact:
#   one.cd.only@gmail.com
#
# This script is part of the 'duf' package
#
# QPKG source: https://github.com/OneCDOnly/duf
# Project source: https://github.com/muesli/duf
# Community forum: https://forum.qnap.com/viewtopic.php?t=157781
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see http://www.gnu.org/licenses/
############################################################################

shopt -s extglob
ln -fns /proc/self/fd /dev/fd		# KLUDGE: `/dev/fd` isn't always created by QTS.

Init()
    {

    readonly QPKG_NAME=duf

    readonly LAUNCHER_PATHFILE=$(/sbin/getcfg duf Install_Path -f /etc/config/qpkg.conf)/duf-launch.sh
	readonly SERVICE_ACTION_PATHFILE=/var/log/$QPKG_NAME.action
	readonly SERVICE_RESULT_PATHFILE=/var/log/$QPKG_NAME.result
    readonly USERLINK_PATHFILE=/usr/bin/duf

    }

StartQPKG()
    {

    if IsNotQPKGEnabled; then
        echo 'This QPKG is disabled. Please enable it first with: qpkg_service enable duf'
        return 1
    else
        [[ ! -L $USERLINK_PATHFILE && -e $LAUNCHER_PATHFILE ]] && ln -s "$LAUNCHER_PATHFILE" "$USERLINK_PATHFILE"

        if [[ -L $USERLINK_PATHFILE ]]; then
            echo "symlink created: $USERLINK_PATHFILE"
        else
            echo "error: unable to create symlink to 'duf' launcher!"
            return 1
        fi
    fi

    }

StopQPKG()
    {

    if [[ -L $USERLINK_PATHFILE ]]; then
        rm -f "$USERLINK_PATHFILE"
        echo "symlink removed: $USERLINK_PATHFILE"
    else
        echo "no 'duf' symlink present"
    fi

    }

StatusQPKG()
	{

    if [[ -L $USERLINK_PATHFILE ]]; then
        echo active
        exit 0
    else
        echo inactive
        exit 1
    fi

	}

SetServiceAction()
	{

	service_action=${1:-none}
	CommitServiceAction
	SetServiceResultAsInProgress

	}

SetServiceResultAsOK()
	{

	service_result=ok
	CommitServiceResult

	}

SetServiceResultAsFailed()
	{

	service_result=failed
	CommitServiceResult

	}

SetServiceResultAsInProgress()
	{

	# Selected action is in-progress and hasn't generated a result yet.

	service_result=in-progress
	CommitServiceResult

	}

CommitServiceAction()
	{

    echo "$service_action" > "$SERVICE_ACTION_PATHFILE"

	}

CommitServiceResult()
	{

    echo "$service_result" > "$SERVICE_RESULT_PATHFILE"

	}

IsQPKGEnabled()
	{

	# input:
	#   $1 = (optional) package name to check. If unspecified, default is $QPKG_NAME

	# output:
	#   $? = 0 : true
	#   $? = 1 : false

	[[ $(Lowercase "$(/sbin/getcfg "${1:-$QPKG_NAME}" Enable -d false -f /etc/config/qpkg.conf)") = true ]]

	}

IsNotQPKGEnabled()
	{

	# input:
	#   $1 = (optional) package name to check. If unspecified, default is $QPKG_NAME

	# output:
	#   $? = 0 : true
	#   $? = 1 : false

	! IsQPKGEnabled "${1:-$QPKG_NAME}"

	}

Lowercase()
	{

	/bin/tr 'A-Z' 'a-z' <<< "$1"

	}

Init

case "$1" in
    ?(--)start)
        SetServiceAction start

        if StartQPKG; then
            SetServiceResultAsOK
        else
            SetServiceResultAsFailed
        fi
        ;;
    ?(-)s|?(--)status)
        StatusQPKG
        ;;
    ?(--)stop)
        SetServiceAction stop

        if StopQPKG; then
            SetServiceResultAsOK
        else
            SetServiceResultAsFailed
        fi
        ;;
    ?(-)r|?(--)restart)
        SetServiceAction restart

        if StopQPKG && StartQPKG; then
            SetServiceResultAsOK
        else
            SetServiceResultAsFailed
        fi
        ;;
    *)
        echo "run service script as: $0 {start|stop|restart|status}"
        echo "to launch 'duf', type: duf"
esac

exit 0
