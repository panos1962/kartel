#!/usr/bin/env bash

# Η παρούσα βιβλιοθήκη αφορά διάφορες bash functions που μπορούν να φανούν
# χρήσιμες σε bash scripts της εφαρμογής. Η ονοματοδοσία των global objects
# της βιβλιοθήκης (μεταβλητές και functions) είναι της μορφής "kartel_XXXX".
#
# Η βιβλιοθήκη συμπεριλαμβάνεται σε κάποιο bash script ως εξής:
#
#	! . "${KARTEL_BASEDIR:/var/opt/kartel}/lib/kartel.sh &&
#	exit 2
#
# By default, η συμπερίληψη της βιβλιοθήκης, συμπαρασύρει και τη συμπερίληψη
# τής βιβλιοθήκης βάσης "pandora".

[ -z "${PANDORA_BASEDIR}" ] &&
PANDORA_BASEDIR="/var/opt/pandora"

! . "${PANDORA_BASEDIR}/lib/pandora.sh" &&
exit 1

pd_seterrcode \
	"fserr" \
	"permerr" \
	"dberror" \
	"erpota12err" \
	""

unset kartel_dbconf
declare -A kartel_dbconf

kartel_dbconf_set() {
	local conf=
	local err=
	local karteldb=
	local erpotadb=
	local dbuser=
	local dbpassword=

	conf="$1"

	[ -z "${conf}" ] &&
	conf="${KARTEL_BASEDIR}/lib/conf/karteldb.cf"

	! . "${conf}" &&
	pd_errmsg "${conf}: cannot read local database configuration file" &&
	return 1

	err=

	[ -z "${karteldb}" ] &&
	pd_errmsg "local database 'kartel' undefined" >&2 &&
	err="yes"

	[ -z "${erpotadb}" ] &&
	pd_errmsg "local database 'erpota' undefined" >&2 &&
	err="yes"

	[ -z "${dbuser}" ] &&
	pd_errmsg "local database user name undefined" >&2 &&
	err="yes"

	[ -z "${dbpassword}" ] &&
	pd_errmsg "local database user password undefined" >&2 &&
	err="yes"

	[ -z "${kartelurl}" ] &&
	pd_errmsg "web application url undefined" >&2 &&
	err="yes"

	[ -n "${err}" ] &&
	return 2

	kartel_dbconf=(
		["karteldb"]="${karteldb}"
		["erpotadb"]="${erpotadb}"
		["dbuser"]="${dbuser}"
		["dbpassword"]="${dbpassword}"
		["erpota12"]="$(kartel_get_erpota12)"
		["kartelurl"]="${kartelurl}"
	)

	return 0
}

kartel_get_erpota12() {
	local fname=
	local erpota12=

	fname="${KARTEL_BASEDIR}/lib/erpota/erpota12"

	! erpota12="$(cat "${fname}")" &&
	pd_errmsg "${fname}: cannot read file" &&
	pd_exit "fserr"

	! [[ "${erpota12}" =~ ^[12]$ ]] &&
	pd_errmsg "${erpota12}: invalid 'erpota' version" &&
	pd_exit "erpota12err"

	echo "${erpota12}"
}

kartel_dbconf_debug() {
	local i=

	echo "Debug local database configuration parameters" >&2
	for i in "${!kartel_dbconf[@]}"
	do
		echo ">>${i}<< >>${kartel_dbconf["${i}"]}<<"
	done >&2
}

unset kartel_mailcf
declare -A kartel_mailcf

kartel_mailcf_set() {
	local conf="$1"
	local err=
	local domain=
	local mailer=
	local from=

	[ -z "$1" ] &&
	conf="${KARTEL_BASEDIR}/lib/conf/mail.cf"

	! . "${conf}" &&
	pd_errmsg "${conf}: cannot read mail configuration file" &&
	return 1

	err=

	[ -z "${domain}" ] &&
	pd_errmsg "mail domain undefined" >&2 &&
	err="yes"

	[ -z "${mailer}" ] &&
	pd_errmsg "mailer undefined" >&2 &&
	err="yes"

	from="${mailer}@${domain}"

	! pd_isemail "${from}" &&
	pd_errmsg "${from}: invalid email address" >&2 &&
	err="yes"

	[ -n "${err}" ] &&
	return 1

	kartel_mailcf=(
		["domain"]="${domain}"
		["mailer"]="${mailer}"
		["from"]="${from}"
	)

	return 0
}

kartel_get_begin_date() {
	local bdfile=

	bdfile="${KARTEL_BASEDIR}/lib/begin_date"

	[ ! -r "${bdfile}" ] &&
	pd_errmsg "${bdfile}: cannot read file" &&
	pd_exit "fserr"

	kartel_begin_date="$(cat "${bdfile}")"
}

kartel_get_begin_date
