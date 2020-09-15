#!/usr/bin/env bash

[ -z "${PANDORA_BASEDIR}" ] &&
PANDORA_BASEDIR="/var/opt/pandora"

! . "${PANDORA_BASEDIR}/lib/pandora.sh" &&
exit 1

unset erpota_dbconf

erpota_dbconf_set() {
	local conf="$1"

	[ -z "$1" ] &&
	conf="${KARTEL_BASEDIR}/lib/conf/erpota.cf"

	[ ! -r "${conf}" ] &&
	pd_errmsg "${conf}: cannot read 'erpota' database configuration file" &&
	return 1

	erpota_dbconf="${conf}"
	return 0
}
