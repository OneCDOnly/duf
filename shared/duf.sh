#!/usr/bin/env bash
############################################################################
# duf.sh - (C)opyright 2020 OneCD [one.cd.only@gmail.com]
#
# This script is part of the 'duf' package
#
# For more info: [https://forum.qnap.com/viewtopic.php?f=320&t=157781]
#
# Available in the Qnapclub Store: [https://qnapclub.eu/en/qpkg/1027]
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

readonly LAUNCHER_PATHFILE=$(/sbin/getcfg duf Install_Path -f /etc/config/qpkg.conf)/duf-launch.sh
readonly USERLINK_PATHFILE=/usr/bin/duf

case "$1" in
    start)
        [[ ! -L $USERLINK_PATHFILE && -e $LAUNCHER_PATHFILE ]] && ln -s "$LAUNCHER_PATHFILE" "$USERLINK_PATHFILE"

        if [[ -L $USERLINK_PATHFILE ]]; then
            echo "symlink created: $USERLINK_PATHFILE"
        else
            echo "error: unable to create symlink to 'duf' launcher!"
        fi
        ;;
    stop)
        if [[ -L $USERLINK_PATHFILE ]]; then
            rm -f "$USERLINK_PATHFILE"
            echo "symlink removed: $USERLINK_PATHFILE"
        fi
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    *)
        echo "run init as: $0 {start|stop|restart}"
        echo "to launch 'duf', type: duf"
        ;;
esac

exit 0
