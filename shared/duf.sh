#!/usr/bin/env bash
############################################################################
# duf.sh
#   copyright 2020-2024 OneCD.
#
# Contact:
#   one.cd.only@gmail.com
#
# This script is part of the 'duf' package
#
# For more info: [https://forum.qnap.com/viewtopic.php?f=320&t=157781]
#
# QPKG source: [https://github.com/OneCDOnly/duf]
# Project source: [https://github.com/muesli/duf]
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
# this program. If not, see http://www.gnu.org/licenses/.
############################################################################

Init()
    {

    QPKG_NAME=duf

    readonly LAUNCHER_PATHFILE=$(/sbin/getcfg duf Install_Path -f /etc/config/qpkg.conf)/duf-launch.sh
    readonly USERLINK_PATHFILE=/usr/bin/duf
    readonly SERVICE_STATUS_PATHFILE=/var/run/$QPKG_NAME.last.operation

    }

SetServiceOperationResultOK()
    {

    SetServiceOperationResult ok

    }

SetServiceOperationResultFailed()
    {

    SetServiceOperationResult failed

    }

SetServiceOperationResult()
    {

    # $1 = result of operation to recorded

    [[ -n $1 && -n $SERVICE_STATUS_PATHFILE ]] && echo "$1" > "$SERVICE_STATUS_PATHFILE"

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

FormatAsPackageName()
	{

	echo -n "'${1:-}'"

	}

Lowercase()
	{

	/bin/tr 'A-Z' 'a-z' <<< "$1"

	}

Init

case "$1" in
    start)
        if IsNotQPKGEnabled; then
            echo "$(FormatAsPackageName "$QPKG_NAME") QPKG is disabled. Please enable it first with: qpkg_service enable duf"
            SetServiceOperationResultFailed
        else
            [[ ! -L $USERLINK_PATHFILE && -e $LAUNCHER_PATHFILE ]] && ln -s "$LAUNCHER_PATHFILE" "$USERLINK_PATHFILE"

            if [[ -L $USERLINK_PATHFILE ]]; then
                echo "symlink created: $USERLINK_PATHFILE"
                SetServiceOperationResultOK
            else
                echo "error: unable to create symlink to 'duf' launcher!"
                SetServiceOperationResultFailed
            fi
        fi
        ;;
    stop)
        if [[ -L $USERLINK_PATHFILE ]]; then
            rm -f "$USERLINK_PATHFILE"
            echo "symlink removed: $USERLINK_PATHFILE"
            SetServiceOperationResultOK
        fi
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    *)
        echo "run service script as: $0 {start|stop|restart}"
        echo "to launch 'duf', type: duf"
esac

exit 0
