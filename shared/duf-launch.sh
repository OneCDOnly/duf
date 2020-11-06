#!/usr/bin/env bash
############################################################################
# duf-launch.sh - (C)opyright 2020 OneCD [one.cd.only@gmail.com]
#
# This script is part of the 'duf' package
#
# For more info: []
#
# Available in the Qnapclub Store: []
# Project source: []
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

readonly THIS_QPKG_NAME=duf
readonly CONFIG_PATHFILE=/etc/config/qpkg.conf

if [[ ! -e $CONFIG_PATHFILE ]]; then
    echo "file not found [$CONFIG_PATHFILE]"
    exit 1
fi

readonly GETCFG_CMD=/sbin/getcfg
readonly QPKG_PATH=$($GETCFG_CMD $THIS_QPKG_NAME Install_Path -f "$CONFIG_PATHFILE")
readonly BIN_PATHFILE=$QPKG_PATH/duf.bin

# this intermediate script exists only to ensure this environment variable is set, so 'duf' displays in colour
export COLORTERM=truecolor

if [[ -e $BIN_PATHFILE ]]; then
    eval "$BIN_PATHFILE" "$@"
else
    echo "error: unable to find 'duf' binary!"
    exit 1
fi

exit 0
