#!/usr/bin/env bash
############################################################################
# duf.sh
#	Copyright 2020-2025 OneCD
#
# Contact:
#	one.cd.only@gmail.com
#
# Description:
#	This is the service-script for the 'duf' QPKG.
#
# Available in the MyQNAP store:
#	https://www.myqnap.org/product/duf
#
# And via the sherpa package manager:
#	https://git.io/sherpa
#
# QPKG source:
#	https://github.com/OneCDOnly/duf
#
# Application source:
#	https://github.com/muesli/duf
#
# Community forum:
#	https://community.qnap.com/t/qpkg-duf-cli/1100
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

set -o nounset -o pipefail
shopt -s extglob
[[ -L /dev/fd ]] || ln -fns /proc/self/fd /dev/fd		# KLUDGE: `/dev/fd` isn't always created by QTS.
readonly r_user_args_raw=$*

Init()
	{

	readonly r_qpkg_name=duf

	readonly r_launcher_pathfile=$(/sbin/getcfg duf Install_Path -f /etc/config/qpkg.conf)/duf-launch.sh
	readonly r_service_action_pathfile=/var/log/$r_qpkg_name.action
	readonly r_service_result_pathfile=/var/log/$r_qpkg_name.result
	readonly r_userlink_pathfile=/usr/bin/duf

	}

StartQPKG()
	{

	if IsNotQPKGEnabled; then
		echo 'This QPKG is disabled. Please enable it first with: qpkg_service enable duf'
		return 1
	else
		[[ ! -L $r_userlink_pathfile && -e $r_launcher_pathfile ]] && ln -s "$r_launcher_pathfile" "$r_userlink_pathfile"

		if [[ -L $r_userlink_pathfile ]]; then
			echo "symlink created: $r_userlink_pathfile"
		else
			echo "error: unable to create symlink to 'duf' launcher!"
			return 1
		fi
	fi

	}

StopQPKG()
	{

	if [[ -L $r_userlink_pathfile ]]; then
		rm -f "$r_userlink_pathfile"

		if [[ ! -L $r_userlink_pathfile ]]; then
			echo "symlink removed: $r_userlink_pathfile"
		else
			echo "error: unable to remove symlink to 'duf' launcher!"
			return 1
		fi
	else
		echo "no 'duf' symlink present"
	fi

	}

StatusQPKG()
	{

	if [[ -L $r_userlink_pathfile ]]; then
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

	echo "$service_action" > "$r_service_action_pathfile"

	}

CommitServiceResult()
	{

	echo "$service_result" > "$r_service_result_pathfile"

	}

IsQPKGEnabled()
	{

	# Inputs: (local)
	#	$1 = (optional) package name to check. If unspecified, default is $r_qpkg_name

	# Outputs: (local)
	#	$? = 0 : true
	#	$? = 1 : false

	[[ $(Lowercase "$(/sbin/getcfg ${1:-$r_qpkg_name} Enable -d false -f /etc/config/qpkg.conf)") = true ]]

	}

IsNotQPKGEnabled()
	{

	# Inputs: (local)
	#	$1 = (optional) package name to check. If unspecified, default is $r_qpkg_name

	# Outputs: (local)
	#	$? = 0 : true
	#	$? = 1 : false

	! IsQPKGEnabled "${1:-$r_qpkg_name}"

	}

Lowercase()
	{

	/bin/tr 'A-Z' 'a-z' <<< "${1:-}"

	}

Init

user_arg=${r_user_args_raw%% *}		# Only process first argument.

case $user_arg in
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
