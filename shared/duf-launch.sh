#!/usr/bin/env bash
############################################################################
# duf-launch.sh
#   Copyright 2020-2025 OneCD
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
# this program. If not, see http://www.gnu.org/licenses/
############################################################################

readonly BIN_PATHFILE=$(/sbin/getcfg duf Install_Path -f /etc/config/qpkg.conf)/duf.bin

# This intermediate script exists only to ensure the following environment variable is set, so `duf` displays in colour.
export COLORTERM=truecolor

if [[ -e $BIN_PATHFILE ]]; then
    eval "$BIN_PATHFILE" "$@"
else
    echo "error: unable to find 'duf' binary!"
    exit 1
fi

exit 0
