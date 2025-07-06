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
# Available in the MyQNAP store:
#	https://www.myqnap.org/product/duf
#
# And via the sherpa package manager:
#	https://git.io/sherpa
#
# QPKG source:
#   https://github.com/OneCDOnly/duf
#
# Application source:
#   https://github.com/muesli/duf
#
# Community forum:
#   https://community.qnap.com/t/qpkg-duf-cli/1100
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

readonly r_bin_pathfile=$(/sbin/getcfg duf Install_Path -f /etc/config/qpkg.conf)/duf.bin

# This intermediate script exists only to ensure the following environment variable is set, so `duf` displays in colour.
export COLORTERM=truecolor

if [[ -e $r_bin_pathfile ]]; then
    eval "$r_bin_pathfile" "$@"
else
    echo "error: unable to find 'duf' binary!"
    exit 1
fi

exit 0
